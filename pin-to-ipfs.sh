#!/bin/sh
set -x
ipfs init
find . -name public
CID=$(ipfs add -Q -r public)
echo "${CID}"
ipfs pin remote service add pinata https://api.pinata.cloud/psa "${PINATA_JWT}"
ipfs pin remote add --service=pinata "${CID}"
