CONFIG_FILES="/tmp/agent_config.json"
DEFAULT_CHAIN_VARIABLE = "HYP_BASE_CHAINS_%s_CONNECTION_URL"

def run(plan, config_file, origin_chain, remote_chains, aws_env):
    env_vars = {}
    relay_chains = []

    url = origin_chain["url"]
    chain_name = origin_chain["chain_name"]
    signer_id = origin_chain["signer_id"]

    for chain in remote_chains:
        relay_chains.append(chain)
        env_var_name = DEFAULT_CHAIN_VARIABLE % chain
        env_vars[env_var_name] = remote_chains[chain]

    relay_chains.append(chain_name)
    env_vars[DEFAULT_CHAIN_VARIABLE % chain_name] = url 

    env_vars["CONFIG_FILES"] = CONFIG_FILES
    env_vars["HYP_BASE_DEFAULTSIGNER_KEY"] = signer_id
    env_vars["AWS_ACCESS_KEY_ID"] = aws_env.access_key_id
    env_vars["AWS_SECRET_ACCESS_KEY"] = aws_env.secret_access_key
    env_vars["HYP_BASE_RELAYCHAINS"]=",".join(relay_chains)
    
    relay_service_config = ServiceConfig(
        image="gcr.io/abacus-labs-dev/hyperlane-agent:478826b-20230828-150025",
        env_vars=env_vars,
        entrypoint=["/bin/sh", "-c", "./relayer"],
        files={
            "/tmp": config_file,
        }
    )

    plan.add_service(name="relayer", config=relay_service_config)
