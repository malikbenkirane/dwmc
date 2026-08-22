#!/bin/sh -ex

CONTAINER_RUNTIME="${CONTAINER_RUNTIME:-container}"

"$CONTAINER_RUNTIME" build -t dwmc:tools ./tools
"$CONTAINER_RUNTIME" build -t dwmc:bookworm .
"$CONTAINER_RUNTIME" build -t dwmc:core ./core
"$CONTAINER_RUNTIME" build -t dwmc:golang ./golang
