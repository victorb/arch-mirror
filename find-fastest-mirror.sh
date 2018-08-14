#! /usr/bin/env bash

set -e

curl https://www.archlinux.org/mirrorlist/all/https/ > mirrorlist.default

sed -i 's/^#Server/Server/' mirrorlist.default

./rankmirrors.sh -v -n 10 mirrorlist.default > mirrorlist.fastest
