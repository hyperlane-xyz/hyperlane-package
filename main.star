validator = import_module("github.com/kurtosis-tech/hyperlane-package/validator.star")
relayer = import_module("github.com/kurtosis-tech/hyperlane-package/relayer.star")
utils = import_module("github.com/kurtosis-tech/hyperlane-package/utils.star")

def run(
    plan,
    origin_chain_name, #type: string
    origin_chain_url,  #type: string
    validator_key,     #type: string
    remote_chains,
    aws_access_key_id="",  #type: string
    aws_secret_access_key="", #type: string
    aws_bucket_region="", #type: string
    aws_bucket_name="", #type: string
    aws_bucket_folder="", #type: string
    agent_config_json="", #type: string
):
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
        aws_env["aws_bucket_folder"] = aws_bucket_folder

    env_aws = get_aws_user_info(plan, aws_env)

    origin_chain = {
        "url": origin_chain_url,
        "chain_name": origin_chain_name,
        "signer_id": validator_key
    }

    # ADD DEPLOY STEP HERE
    config_file = utils.get_agent_config_artifact(plan, agent_config_json) 
    validator.run(plan, config_file, origin_chain, remote_chains, env_aws)
    relayer.run(plan, config_file, origin_chain, remote_chains, env_aws)

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
