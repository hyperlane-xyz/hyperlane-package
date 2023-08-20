
CONFIG_FILES="/tmp/agent_config.json"
DEFAULT_SIGNER_KEY = "HYP_BASE_CHAINS_%s_SIGNER_KEY"
DEFAULT_ORIGIN_CHAIN_URL = "HYP_BASE_CHAINS_%s_CONNECTION_URL"
ORIGIN_CHAIN = "origin_chain"

def run(plan, config_file, args):
    env_vars = {}
    value = args.get(ORIGIN_CHAIN, {})
    aws_secret_key_id = args.get("aws_key_id", "")
    aws_secret_access_key = args.get("aws_access_key", "")

    url = value["url"]
    region = value["region"]  
    chain = value["chain_name"]
    signer_id = value["signer_id"]
    bucket_name = value["bucket_name"]
    
    env_vars[DEFAULT_SIGNER_KEY % chain] = signer_id
    env_vars[DEFAULT_ORIGIN_CHAIN_URL % chain] = url
    
    env_vars["HYP_BASE_CHECKPOINTSYNCER_TYPE"] = "s3"
    env_vars["HYP_BASE_CHECKPOINTSYNCER_REGION"] = region
    env_vars["HYP_BASE_CHECKPOINTSYNCER_BUCKET"] = bucket_name
    env_vars["HYP_BASE_VALIDATOR_KEY"] = signer_id
    env_vars["HYP_BASE_ORIGINCHAINNAME"] = chain
    env_vars["HYP_VALIDATOR_REORGPERIOD"] = "1"
    env_vars["CONFIG_FILES"] = CONFIG_FILES
    env_vars["AWS_ACCESS_KEY_ID"] = aws_secret_key_id
    env_vars["AWS_SECRET_ACCESS_KEY"] = aws_secret_access_key

    validator_service_config = ServiceConfig(
        image="gcr.io/abacus-labs-dev/hyperlane-agent:1fff74e-20230614-005705",
        env_vars=env_vars,
        entrypoint=["/bin/sh", "-c", "./validator"],
        files={
            "/tmp": config_file
        }
    )

    plan.add_service(name="validator", config=validator_service_config)






    
