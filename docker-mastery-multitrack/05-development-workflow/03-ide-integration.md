# Use an editor without changing the runtime contract

## Learning objectives

Separate source editing and debugging conveniences from the deployable image.

## Prerequisites

The development workflow experiment.

## Exercise

Open the repository in your preferred editor. Use its integrated Bash terminal to run the same Compose commands from the previous lesson. Keep the working directory visible; a terminal opened in the wrong directory can use the wrong Compose project.

Edit the host source and verify the response over HTTP. For Python/Rust development, source is bind-mounted read-only into the container. For Java, rebuild the image. Keep host build outputs and virtual environments out of the build context.

A debugger is an optional local development tool. Before adding one, determine its runtime, listen address, port and authentication behaviour. A published debugger may grant code execution. Bind it to loopback for local use and put debugging settings in a development-only configuration.

Record the shortest repeatable edit → run → inspect loop for your track. You should be able to reproduce it from a terminal without editor-specific state.

## Check your understanding

Show another learner how to repeat your workflow. Identify which files constitute the application build and which settings belong only to your editor.
