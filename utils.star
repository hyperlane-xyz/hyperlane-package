def get_agent_config_artifact(plan, agent_config_json):
    if agent_config_json == "":
        return plan.upload_files(
            src="github.com/kurtosis-tech/hyperlane-package/artifacts/agent_config.json", 
            name="config_file",
        )
    else:
        return plan.render_templates(config={
                "agent_config.json": struct(
                    template=agent_config_json,
                    data={},
                ),
            },
            name="config_file",
        )