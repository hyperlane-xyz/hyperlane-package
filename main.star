validator = import_module("./validator.star")
relayer = import_module("./relayer.star")
utils = import_module("./utils.star")
prometheus = import_module("github.com/kurtosis-tech/prometheus-package/main.star")
grafana = import_module("github.com/kurtosis-tech/grafana-package/main.star")

def run(
        plan,
        origin_chain_name,
        validator_key,
        agent_config_json,
        relay_chains,
        rpc_urls={},
        custom_validator_image="gcr.io/abacus-labs-dev/hyperlane-agent:a888cf7-20231214-180118",
        custom_relayer_image="gcr.io/abacus-labs-dev/hyperlane-agent:a888cf7-20231214-180118",
        log_level="info",
        aws_access_key_id="",
        aws_secret_access_key="",
        aws_bucket_region="",
        aws_bucket_name="",
        aws_bucket_folder="",
):
    """Runs a Hyperlane validator and relayer

    Args:
        origin_chain_name (string): The name of the origin chain
        origin_chain_url (string): The RPC url of the origin chain
        validator_key (string): The private key (0x-prefixed) to be used by the validator
        relay_chains (string): comma separated list of chains to relay between
        agent_config_json: The agent config used by Hyperlane validator and relayer
        rpc_urls (dict[string, string]): Mapping of chainName => rpcURL
        custom_validator_image (string): A custom image to use to run the validator
        custom_relayer_image (string): A custom image to use to run the relayer
        log_level (string): Custom logging level. Defaults to "info"
        aws_access_key_id (string): A custom AWS access key ID to use for accessing the AWS bucket
        aws_secret_access_key (string): A custom AWS secret access key to use for accessing the AWS bucket
        aws_bucket_region (string): The region of the custom bucket to be used
        aws_bucket_name (string): The name of the custom bucket to be used
        aws_bucket_folder (string): The folder inside the bucket to use
    """
    aws_env = {}
    if len(aws_access_key_id) > 0:
        aws_env["aws_access_key_id"] = aws_access_key_id

    if len(aws_secret_access_key) > 0:
        aws_env["aws_secret_access_key"] = aws_secret_access_key

    if len(aws_bucket_region) > 0:
        aws_env["aws_bucket_region"] = aws_bucket_region

    if len(aws_bucket_name) > 0:
        aws_env["aws_bucket_name"] = aws_bucket_name

    if len(aws_bucket_folder) > 0:
        aws_env["aws_bucket_user_folder"] = aws_bucket_folder

    relay_chains = [chain.strip() for chain in relay_chains.split(',')]
    if len(relay_chains) < 2:
        fail("At least two chains must be provided to relay between")

    if len(validator_key) < 64:
        fail("Invalid validator key provided")
    validator_key = validator_key if validator_key.startswith("0x") else "0x" + validator_key

    env_aws = get_aws_user_info(plan, aws_env)

    origin_chain = {
        "chain_name": origin_chain_name,
        "signer_id": validator_key,
    }

    # ONCE THE BUG IS FIXED, I WILL REMOVE THIS
    if log_level == "":
        log_level = "info"

    # ADD DEPLOY STEP HERE
    config_file = utils.get_agent_config_artifact(plan, agent_config_json)
    validator_service = validator.run(plan, config_file, origin_chain, rpc_urls, env_aws, custom_validator_image, log_level)
    relayer_servce = relayer.run(plan, config_file, relay_chains, validator_key, rpc_urls, env_aws, custom_relayer_image, log_level)

    # setup prometheus and grafana dashboards for agents
    validator_metrics_job = {
        "Name": "validater metrics", 
        "Endpoint": "{0}:{1}".format(validator_service.ip_address, validator_service.ports["metrics"].number),
        "Labels": {},
        "ScrapeInterval": "5s",
    }
    prometheus_url = prometheus.run(plan, metrics_jobs=[validator_metrics_job])
    grafana.run(plan, prometheus_url, "github.com/kurtosis-tech/hyperlane-package/artifacts/dashboards")

def get_aws_user_info(plan, aws_env):
    if len(aws_env) > 0:
        # use this instead of potential values passed via the `kurtosis` module
        return struct(
            access_key_id=aws_env["aws_access_key_id"],
            secret_access_key=aws_env["aws_secret_access_key"],
            bucket_region=aws_env["aws_bucket_region"],
            bucket_name=aws_env["aws_bucket_name"],
            bucket_user_folder=aws_env["aws_bucket_user_folder"] if "aws_bucket_user_folder" in aws_env else ""
        )
    else:
        # the AWS values should be provided as env variables to the package. Otherwise this package cannot run
        return struct(
            access_key_id=kurtosis.aws_access_key_id,
            secret_access_key=kurtosis.aws_secret_access_key,
            bucket_region=kurtosis.aws_bucket_region,
            bucket_name=kurtosis.aws_bucket_name,
            bucket_user_folder=kurtosis.aws_bucket_user_folder
        )
