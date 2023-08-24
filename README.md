Hyperlane package
=================

# Getting started

You'll need the following set of args, which you can write to a JSON file like `args.json`
```
{
  "origin_chain": {
    "url": "https://base-goerli.gateway.tenderly.co",
    "chain_name": "base",
    "signer_id": "ADD_THE_SIGNER_ID_HERE"
  },
  "remote_chains": {
    "goerli":"https://goerli-rollup.arbitrum.io/rpc"
  },
  "aws_env": {
    "aws_access_key_id": "AWS_USER_ACCESS_KEY_ID",
    "aws_secret_access_key": "AWS_USER_SECRET_ACCESS_KEY",
    "aws_bucket_region": "us-east-1",
    "aws_bucket_name": "BUCKET_TO_READ_AND_WRITE_DATA",
    "aws_bucket_folder": "OPTIONAL_FOLDER_INSIDE_BUCKET_TO_USE"
  }
}
```

The origin chain and remote chains should reference the ones listed in [agent_config.json](./artifacts/agent_config.json). If you want to use custom ones, be sure to add their info into this file also.

An AWS user key and S3 bucket is required when running locally so that the validator service can persist data to it. When running the package on Kurtosis Cloud, the `aws_env` part becomes optional because Kurtosis Cloud automatically provides this information to the package via its environment variable.

With the arguments JSON file, the package can be run with:
```
kurtosis run ./ "$(cat args.json)"
```
