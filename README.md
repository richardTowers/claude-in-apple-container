claude-in-apple-container
=========================

An example running [Claude Code] inside an [apple/container]

<img alt="A rustic wooden crate filled with red apples and straw sitting on a wooden table. The orange, geometric Claude AI starburst logo rests prominently in the center of the crate among the fruit." src="./claude-in-apple-container.png" width="320px">

## Prerequisites

You'll need:
- an Apple Silicon device that's newfangled enough to run [apple/container]
- a [Claude Code] subscription
- VSCode with at least version 0.437 of the Dev Containers extension, with `Experimental Apple Container Support` enabled in the settings

## Tutorial

1) Make sure the `apple/container` runtime is running with `container system start`
2) Pull the pre-built container image (if you trust me):
   ```
   container image pull ghcr.io/richardtowers/claude-in-apple-container/devcontainer:latest
   container image tag ghcr.io/richardtowers/claude-in-apple-container/devcontainer:latest claude-code-devcontainer:latest
   ```
   Or, if you prefer to build it yourself:
   ```
   container build --tag claude-code-devcontainer --file .devcontainer/Dockerfile .devcontainer
   ```
3) From your project directory, run the container:
   ```
   container run --name claude-code --memory 8g \
     --volume "$(pwd):/workspace" \
     --volume claude-code-bashhistory:/commandhistory \
     --volume claude-code-config:/home/node/.claude \
     --detach --rm claude-code-devcontainer:latest sleep infinity
   ```
   The named volumes persist shell history and Claude configuration across container restarts.
4) Run the `Dev Containers: Attach to Running Apple Container...` command in VSCode
5) Use VSCode's built-in terminal to run yourself some Claude instances!

You might feel okay using `--dangerously-skip-permissions` mode, as at least your local machine should be protected from what goes on inside the container by the virtualization framework. You still have to be careful with any keys you give processes inside the container though — as soon as you log in to Claude there's at least one valuable secret in the environment: your Claude session token.

[Claude Code]: https://code.claude.com/docs/en/overview
[apple/container]: https://github.com/apple/container