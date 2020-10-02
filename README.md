# Usage

To build a new `fluentd` image:

    make build

To push the `fluentd` image to Docker Hub:

    make apply

To deploy `fluentd` chart:

    make install

To combine all actions above:

    make

To remove existing `fluentd` chart if it exists in the Kubernetes cluster:

    make delete

Additionally, you can also check the logs for one of the containers in the chart:

    make logs

Or exec into it:

    make exec
