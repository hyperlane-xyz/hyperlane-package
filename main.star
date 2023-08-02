validator = import_module("github.com/kurtosis-tech/hyperlane/validator.star")
relayer = import_module("github.com/kurtosis-tech/hyperlane/relayer.star")

def run(plan, args):

    # CREATE S3 BUCKET AND RELEVANT KEYS BY CALLING NECESSARY PACKAGE

    # ADD DEPLOY STEP HERE

    config_file = plan.upload_files(
        src="github.com/kurtosis-tech/hyperlane/artifacts/agent_config.json", 
        name="config_file"
    )

    validator.run(plan, config_file, args)
    relayer.run(plan, config_file, args)











