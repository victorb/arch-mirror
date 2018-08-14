#! /usr/bin/env bash

set -e
set -x

echo "## Initializing IPFS Repository"

export IPFS_PATH=$(pwd)/.ipfs
ipfs init --profile=badgerds || true

echo "## Setting IPFS config"
ipfs config Addresses.API "/ip4/127.0.0.1/tcp/7001"
ipfs config Addresses.Gateway "/ip4/127.0.0.1/tcp/7002"
ipfs config Addresses.Swarm --json '["/ip4/0.0.0.0/tcp/7000"]'
ipfs config --json Experimental.ShardingEnabled true
ipfs config --json Experimental.FilestoreEnabled true
ipfs config --json Datastore.NoSync true

echo "## Generate IPNS key"
ipfs key gen --type=rsa --size=2048 "arch-repository" || true

echo "Adding 'arch-repository/' to IPFS"

# TODO should be with --nocopy but bug in the way...
# ipfs add -r --raw-leaves --local --nocopy ./arch-repository | tee hash-list
ipfs add -r --raw-leaves --local ./arch-repository | tee hash-list
HASH="$(tail -n1 hash-list | cut -d ' ' -f2)"

echo "Final hash is $HASH, publishing on IPNS"
ipfs name publish --key="arch-repository" /ipfs/$HASH

export APIKEY=$GANDI_API_KEY
export ZONE=$GANDI_ZONE
export RECORD=$GANDI_RECORD

if [[ -z "${APIKEY}" ]]; then
  echo "The env var GANDI_API_KEY was not set so skipping update of DNS records"
else
  curl -X PUT -H "Content-Type: application/json" -H "X-Api-Key: $APIKEY" -d "{\"rrset_values\": [\"dnslink=/ipfs/$HASH\"]}" https://dns.api.gandi.net/api/v5/domains/$ZONE/records/$RECORD/TXT | jq .
fi

