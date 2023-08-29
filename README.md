Hyperlane package
=================

# Getting started

You'll need the following set of args, which you can write to a JSON file like `args.json`
```
{
  "origin_chain_url": "https://base-goerli.gateway.tenderly.co",
  "origin_chain_name": "base",
  "validator_key": "<HYPERLANE_VALIDATOR_KEY",
  "aws_access_key_id": "<AWS_ACCESS_KEY_ID>",
  "aws_secret_access_key": "<AWS_SECRET_ACCESS_KEY>",
  "aws_bucket_region": "us-east-1",
  "aws_bucket_name": "<AWS_BUCKET_NAME>",
  "remote_chains": {
    "goerli":"https://goerli-rollup.arbitrum.io/rpc"
  }
}
```

The origin chain and remote chains should reference the ones listed in [agent_config.json](./artifacts/agent_config.json). If you want to use custom ones, be sure to add their info into this file also.

An AWS user key and S3 bucket is required when running locally so that the validator service can persist data to it. When running the package on Kurtosis Cloud, the `aws_env` part becomes optional because Kurtosis Cloud automatically provides this information to the package via its environment variable.

With the arguments JSON file, the package can be run with:
```
kurtosis run ./ "$(cat args.json)"
```
