#!/bin/sh -ex

container build -t dwmc:bookworm .
container build -t dwmc:core ./core
