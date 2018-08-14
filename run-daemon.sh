#! /usr/bin/env bash

set -e

export IPFS_PATH=$(pwd)/.ipfs

# TODO find a way of applying this
# ulimit -n unlimited

ipfs daemon --enable-pubsub-experiment --enable-namesys-pubsub
