def get_agent_config_artifact(plan, agent_config_json):
    if len(agent_config_json) == 0:
        return plan.upload_files(
            src="github.com/kurtosis-tech/hyperlane-package/artifacts/agent_config.json", 
            name="config_file",
        )
    else:
        return plan.render_templates(config={
                "agent_config.json": struct(
                    template=str(agent_config_json),
                    data={},
                ),
            },
            name="config_file",
        )