CONNECTION_URL = "connection_url"
VALIDATOR_KEY = "validator_key"
ORIGIN_CHAIN = "origin_chain"

def run(plan, args):
    if args.get(VALIDATOR_KEY) != None:
        validator_key = args.get(VALIDATOR_KEY)
    
    if args.get(CONNECTION_URL) != None:
        connection_url = args.get(CONNECTION_URL)    
    if args.get(ORIGIN_CHAIN) != None:
        origin_chain = args.get(ORIGIN_CHAIN)

    # to do - add deploy step
    config_file = plan.upload_files(
        src="github.com/kurtosis-tech/hyperlane/artifacts/agent_config.json", 
        name="config_file"
    )

    validator_cmd = "./validator --reorgPeriod 1 --originChainName %s --validator.key  %s --checkpointSyncer.type localStorage --checkpointSyncer.path /tmp/signature --chains.%s.signer.key %s --chains.%s.connection.url %s" % (origin_chain, validator_key, origin_chain, validator_key, origin_chain, connection_url)
    service = ServiceConfig(
        image="gcr.io/abacus-labs-dev/hyperlane-agent:1fff74e-20230614-005705",
        files={
            "/tmp/artifact": config_file,
        },
        env_vars={
            "CONFIG_FILES": "/tmp/artifact/agent_config.json"
        },
        entrypoint=["/bin/sh", "-c", validator_cmd]
    )

    plan.add_service(name="validator", config=service)

