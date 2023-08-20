ORIGIN_CHAIN = "origin_chain"
REMOTE_CHAINS = "remote_chains"
CONFIG_FILES="/tmp/agent_config.json"
DEFAULT_CHAIN_VARIABLE = "HYP_BASE_CHAINS_%s_CONNECTION_URL"

def run(plan, config_file, args):
    env_vars = {}
    relay_chains = []

    value = args.get(ORIGIN_CHAIN, {})
    url = value["url"]
    region = value["region"]  
    chain_name = value["chain_name"]
    signer_id = value["signer_id"]
    remote_chains = args.get(REMOTE_CHAINS, {})

    for chain in remote_chains:
        relay_chains.append(chain)
        env_var_name = DEFAULT_CHAIN_VARIABLE % chain
        env_vars[env_var_name] = remote_chains[chain]

    aws_secret_key_id = args.get("aws_key_id", "")
    aws_secret_access_key = args.get("aws_access_key", "")

    relay_chains.append(chain_name)
    env_vars[DEFAULT_CHAIN_VARIABLE % chain_name] = url 

    env_vars["CONFIG_FILES"] = CONFIG_FILES
    env_vars["HYP_BASE_DEFAULTSIGNER_KEY"] = signer_id
    env_vars["AWS_ACCESS_KEY_ID"] = aws_secret_key_id
    env_vars["AWS_SECRET_ACCESS_KEY"] = aws_secret_access_key
    env_vars["HYP_BASE_RELAYCHAINS"]=",".join(relay_chains)
    
    relay_service_config = ServiceConfig(
        image="gcr.io/abacus-labs-dev/hyperlane-agent:1fff74e-20230614-005705",
        env_vars=env_vars,
        entrypoint=["/bin/sh", "-c", "./relayer"],
        files={
            "/tmp": config_file
        }
    )

    plan.add_service(name="relayer", config=relay_service_config)
