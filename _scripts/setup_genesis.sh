#!/bin/bash

NODE_HOME="${HOME}/${1}"
PASSWORD="*•*•*•*••_\\°_°//_••bã0bªb_įs_fkñ_stròng••_\\°_°//_••*•*•*•*"
MNEMONIC=$2
ACCOUNT_NAME="EZStaking"
KEYRING="--keyring-backend test"
STAKE="ubaobab"
FEE="uusdcx"
CHAIN_ID=baobab-1
MONIKER="EZStaking.io"
TIMEOUT_COMMIT="5s"
BLOCK_GAS_LIMIT=10000000
VOTING_PERIOD=$((5*60))

echo "Configured Block Gas Limit: $BLOCK_GAS_LIMIT"
echo "Configured Voting Period: $VOTING_PERIOD"

# generate the genesis file
GENESIS_FILE="${NODE_HOME}/config/genesis.json"
echo "Generating $GENESIS_FILE..."
baobabd init --chain-id "$CHAIN_ID" "$MONIKER" --home $NODE_HOME

# recover account
echo "$MNEMONIC" | baobabd keys add $ACCOUNT_NAME --recover $KEYRING --home $NODE_HOME

# add ica-config
baobabd add-ica-config --home $NODE_HOME

# staking/governance token is hardcoded in config, change this
sed -i "s/\"stake\"/\"$STAKE\"/" "$GENESIS_FILE"

# this is essential for sub-1s block times (or header times go crazy)
sed -i 's/"time_iota_ms": "1000"/"time_iota_ms": "10"/' "$GENESIS_FILE"

# change gas limit to mainnet value
sed -i 's/"max_gas": "-1"/"max_gas": "'"$BLOCK_GAS_LIMIT"'"/' "$GENESIS_FILE"

# change voting_period to 5mn
sed -i 's/"voting_period": "172800s"/"voting_period": "'"${VOTING_PERIOD}s"'"/' "$GENESIS_FILE"

# change default keyring-backend to test
sed -i 's/keyring-backend = "os"/keyring-backend = "test"/' "${NODE_HOME}/config/client.toml"

APP_TOML_CONFIG="${NODE_HOME}/config/app.toml"
APP_TOML_CONFIG_NEW="${NODE_HOME}/config/app_new.toml"
CONFIG_TOML_CONFIG="${NODE_HOME}/config/config.toml"

# speed up block times for testing environments
sed -i "s/timeout_commit = \"5s\"/timeout_commit = \"$TIMEOUT_COMMIT\"/" "$CONFIG_TOML_CONFIG"

# add accounts
echo "$PASSWORD" | baobabd add-genesis-account $ACCOUNT_NAME "1000000000000$STAKE,1000000000000$FEE" $KEYRING --home $NODE_HOME

#  for addr in "$@"; do
#    echo $addr
#    baobabd add-genesis-account "$addr" "1000000000000$STAKE,1000000000000$FEE"
#  done

# submit a genesis validator tx
# (echo "$PASSWORD"; echo "$PASSWORD"; echo "$PASSWORD") | baobabd gentx $ACCOUNT_NAME "250000000$STAKE" --chain-id="$CHAIN_ID"
(echo "$PASSWORD"; echo "$PASSWORD"; echo "$PASSWORD") | baobabd gentx $ACCOUNT_NAME "250000000$STAKE" \
  --chain-id="$CHAIN_ID" \
  --amount="250000000$STAKE" \
  --moniker="$MONIKER" \
  --details="Enterprise grade infrastructure. High end security and 24/7 monitoring." \
  --identity="1534523421A364DB" \
  --security-contact="contact@ezstaking.io" \
  --website="https://ezstaking.io" \
  --amount="1000000ubaobab" \
  --min-self-delegation=1 \
  --commission-max-change-rate=0.05 \
  --commission-max-rate=0.2 \
  --commission-rate=0.05 \
  --home $NODE_HOME \
  --node="tcp://127.0.0.1:26656" \
  $KEYRING

baobabd collect-gentxs --home $NODE_HOME
