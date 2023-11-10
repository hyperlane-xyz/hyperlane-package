constants = import_module("./constants.star")

def run(plan, config_file, origin_chain, rpc_urls, aws_env, relayer_image, log_level):
    env_vars = {}
    relay_chains = []

    chain_name = origin_chain["chain_name"]
    signer_id = origin_chain["signer_id"]

    for chain in rpc_urls:
        relay_chains.append(chain)
        env_var_name = constants.DEFAULT_ORIGIN_CHAIN_URL % chain
        env_vars[env_var_name] = rpc_urls[chain]

    relay_chains.append(chain_name)
    env_vars[constants.DEFAULT_ORIGIN_CHAIN_URL % chain_name] = rpc_urls[chain_name]

    env_vars["HYP_BASE_DEFAULTSIGNER_KEY"] = signer_id
    env_vars["HYP_BASE_RELAYCHAINS"]=",".join(relay_chains)
    env_vars["HYP_BASE_DB"] = constants.DB_FOLDER
    env_vars["CONFIG_FILES"] = "{}{}".format(constants.CONFIG_FILE_FOLDER, constants.CONFIG_FILE_NAME)
    env_vars["AWS_ACCESS_KEY_ID"] = aws_env.access_key_id
    env_vars["AWS_SECRET_ACCESS_KEY"] = aws_env.secret_access_key
    env_vars["HYP_BASE_TRACING_LEVEL"] = log_level
    
    relay_service_config = ServiceConfig(
        image=relayer_image,
        env_vars=env_vars,
        entrypoint=["/bin/sh", "-c", "./relayer"],
        files={
            constants.CONFIG_FILE_FOLDER: config_file,
            constants.DB_FOLDER: Directory(
                persistent_key="relayer-db"
            ),
        }
    )

    plan.add_service(name="relayer", config=relay_service_config)
