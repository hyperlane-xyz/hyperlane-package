validator = import_module("github.com/kurtosis-tech/hyperlane/validator.star")
relayer = import_module("github.com/kurtosis-tech/hyperlane/relayer.star")

def run(plan, origin_chain, remote_chains, aws_env={}):
    aws_env = get_aws_user_info(plan, aws_env)

    # ADD DEPLOY STEP HERE

    config_file = plan.upload_files(
        src="github.com/kurtosis-tech/hyperlane/artifacts/agent_config.json", 
        name="config_file"
    )
    validator.run(plan, config_file, origin_chain, remote_chains, aws_env)
    relayer.run(plan, config_file, origin_chain, remote_chains, aws_env)


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
