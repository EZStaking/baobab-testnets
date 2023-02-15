#!/bin/bash

TMP_HOME=$1
MNEMONIC="$2"

./setup_genesis.sh $TMP_HOME "$MNEMONIC"

baobabd tendermint unsafe-reset-all --home /home/ezstakingtools/.baobab

cp $TMP_HOME/config/genesis.json .baobab/config/genesis.json
cp $TMP_HOME/config/node_key.json .baobab/config/node_key.json
cp $TMP_HOME/config/priv_validator_key.json .baobab/config/priv_validator_key.json

rm -rf .baobab/config/gentx
rm -rf .baobab/keyring-test

cp $TMP_HOME/config/gentx .baobab/config/ -r
cp $TMP_HOME/keyring-test .baobab/ -r

rm -rf $TMP_HOME
