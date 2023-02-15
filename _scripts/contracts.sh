#!/bin/bash

cd junomint-cw20/contracts
./baobab-store_contracts.sh

cd
./instantiate_contracts.sh
