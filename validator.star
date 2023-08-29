CONFIG_FILES="/tmp/agent_config.json"
DEFAULT_SIGNER_KEY = "HYP_BASE_CHAINS_%s_SIGNER_KEY"
DEFAULT_ORIGIN_CHAIN_URL = "HYP_BASE_CHAINS_%s_CONNECTION_URL"
ORIGIN_CHAIN = "origin_chain"

def run(plan, config_file, origin_chain, remote_chains, aws_env):
    env_vars = {}

    url = origin_chain["url"]
    chain = origin_chain["chain_name"]
    signer_id = origin_chain["signer_id"]
    
    env_vars[DEFAULT_SIGNER_KEY % chain] = signer_id
    env_vars[DEFAULT_ORIGIN_CHAIN_URL % chain] = url
    
    env_vars["HYP_BASE_CHECKPOINTSYNCER_TYPE"] = "s3"
    env_vars["HYP_BASE_CHECKPOINTSYNCER_REGION"] = aws_env.bucket_region 
    env_vars["HYP_BASE_CHECKPOINTSYNCER_BUCKET"] = aws_env.bucket_name 
    env_vars["HYP_BASE_CHECKPOINTSYNCER_FOLDER"] = aws_env.bucket_user_folder
    env_vars["HYP_BASE_VALIDATOR_KEY"] = signer_id
    env_vars["HYP_BASE_ORIGINCHAINNAME"] = chain
    env_vars["HYP_VALIDATOR_REORGPERIOD"] = "1"
    env_vars["CONFIG_FILES"] = CONFIG_FILES
    env_vars["AWS_ACCESS_KEY_ID"] = aws_env.access_key_id 
    env_vars["AWS_SECRET_ACCESS_KEY"] = aws_env.secret_access_key

    validator_service_config = ServiceConfig(
        image="gcr.io/abacus-labs-dev/hyperlane-agent:478826b-20230828-150025",
        env_vars=env_vars,
        entrypoint=["/bin/sh", "-c", "./validator"],
        files={
            "/tmp": config_file,
        }
    )

    plan.add_service(name="validator", config=validator_service_config)
