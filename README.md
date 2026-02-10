claude-in-apple-container
=========================

An example running [Claude Code] inside an [apple/container]

![A rustic wooden crate filled with red apples and straw sitting on a wooden table. The orange, geometric Claude AI starburst logo rests prominently in the center of the crate among the fruit.](./claude-in-apple-container.png)

## Prerequisites

You'll need:
- an Apple Silicone device that's newfangled enough to run [apple/container]
- a [Claude Code] subscription
- VSCode with at least version 0.437 of the Dev Containers extension, with `Experimental Apple Container Support` enabled in the settings

## Tutorial

0) Make sure the `apple/container` runtime is running with `container system start`
1) Change into the `.devcontainer` directory
2) Build the container image from [https://github.com/anthropics/claude-code/tree/main/.devcontainer](https://github.com/anthropics/claude-code/tree/main/.devcontainer) with `container build --tag claude-code-devcontainer --file Dockerfile .`
3) Run the container with `container run --name claude-code --memory 8g --volume ${YOUR_PROJECT_DIR}:/code --detach --rm claude-code-devcontainer sleep infinity`
4) Run the `Dev Containers: Attach to Running Apple Container...` command in VSCode
5) Use VSCode's built in terminal to run yourself some claude instances!

You might feel okay using `--yolo` mode, as at least your local machine should be protected from what goes on inside the devcontainer
by the virtualization framework. You still have to be careful with any keys you give processes inside the container though - as soon as you log in to Claude there's at least one valuable secret in the environment: your Claude session token.

[Claude Code]: https://code.claude.com/docs/en/overview
[apple/container]: https://github.com/apple/container