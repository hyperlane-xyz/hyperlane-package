constants = import_module("./constants.star")

DEFAULT_SIGNER_KEY = "HYP_CHAINS_%s_SIGNER_KEY"
ORIGIN_CHAIN = "origin_chain"

def run(plan, config_file, origin_chain, rpc_urls, aws_env, validator_image, log_level):
    env_vars = {
        "HYP_GASPAYMENTENFORCEMENT": '[{"type": "none"}]'
    }

    chain = origin_chain["chain_name"]
    signer_id = origin_chain["signer_id"]
    
    env_vars[DEFAULT_SIGNER_KEY % chain] = signer_id

    if chain in rpc_urls:
        env_vars[constants.DEFAULT_ORIGIN_CHAIN_URL % chain] = rpc_urls[chain]
    
    env_vars["HYP_CHECKPOINTSYNCER_TYPE"] = "s3"
    env_vars["HYP_CHECKPOINTSYNCER_REGION"] = aws_env.bucket_region 
    env_vars["HYP_CHECKPOINTSYNCER_BUCKET"] = aws_env.bucket_name 
    env_vars["HYP_CHECKPOINTSYNCER_FOLDER"] = aws_env.bucket_user_folder
    env_vars["HYP_VALIDATOR_KEY"] = signer_id
    env_vars["HYP_ORIGINCHAINNAME"] = chain
    env_vars["HYP_VALIDATOR_REORGPERIOD"] = "1"
    env_vars["HYP_DB"] = constants.DB_FOLDER
    env_vars["CONFIG_FILES"] = "{}{}".format(constants.CONFIG_FILE_FOLDER, constants.CONFIG_FILE_NAME)
    env_vars["AWS_ACCESS_KEY_ID"] = aws_env.access_key_id 
    env_vars["AWS_SECRET_ACCESS_KEY"] = aws_env.secret_access_key
    env_vars["HYP_TRACING_LEVEL"] = log_level

    validator_service_config = ServiceConfig(
        image=validator_image,
        env_vars=env_vars,
        ports = {
            "metrics": PortSpec(
                number=9090,
                transport_protocol="TCP",
                application_protocol="http",
            )
        },
        entrypoint=["/bin/sh", "-c", "./validator"],
        files={
            constants.CONFIG_FILE_FOLDER: config_file,
            constants.DB_FOLDER: Directory(
                persistent_key="validator-db"
            ),
        }
    )

    return plan.add_service(name="validator", config=validator_service_config)
