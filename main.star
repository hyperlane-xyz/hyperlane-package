validator = import_module("github.com/kurtosis-tech/hyperlane-package/validator.star")
relayer = import_module("github.com/kurtosis-tech/hyperlane-package/relayer.star")
utils = import_module("github.com/kurtosis-tech/hyperlane-package/utils.star")

def run(
    plan,
    origin_chain_name, # type: string
    origin_chain_url,  # type: string
    validator_key,     # type: string
    remote_chains,
    agent_config_json,
    custom_validator_image="gcr.io/abacus-labs-dev/hyperlane-agent:9612623-20230829-154513", # type: string
    custom_relayer_image="gcr.io/abacus-labs-dev/hyperlane-agent:9612623-20230829-154513",   # type: string
    log_level="info",         # type: string
    aws_access_key_id="",     # type: string
    aws_secret_access_key="", # type: string
    aws_bucket_region="",     # type: string
    aws_bucket_name="",       # type: string
    aws_bucket_folder="",     # type: string
):
    """Runs an Hyperlane validator and relayer

    Args:
        origin_chain_name (string): The name of the origin chain
        origin_chain_url (string): The RPC url of the origin chain
        validator_key (string): The private key to be used by the validator
        remote_chains: The information about the remote chains
        agent_config_json: The agent config used by Hyperlane validator and relayer
        custom_validator_image (string): A custom image to use to run the the validator
        custom_relayer_image (string): A custom image to use to run the the relayer
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

    env_aws = get_aws_user_info(plan, aws_env)

    origin_chain = {
        "url": origin_chain_url,
        "chain_name": origin_chain_name,
        "signer_id": validator_key,
    }

    # ONCE THE BUG IS FIXED, I WILL REMOVE THIS
    if log_level == "":
        log_level = "info"

    # ADD DEPLOY STEP HERE
    config_file = utils.get_agent_config_artifact(plan, agent_config_json) 
    validator.run(plan, config_file, origin_chain, remote_chains, env_aws, custom_validator_image, log_level)
    relayer.run(plan, config_file, origin_chain, remote_chains, env_aws, custom_relayer_image, log_level)

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
