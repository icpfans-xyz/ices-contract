#!/bin/bash

# set -e

# clear
# dfx stop
# rm -rf .dfx

# dfx start --clean --background --emulator
dfx build --check
dfx canister --no-wallet create --all
dfx canister --no-wallet install ces-example-rs -m reinstall
echo canister installed

dfx identity use default

DEFAULT_ID=$(dfx identity get-principal)
echo default principal = $DEFAULT_ID

CANISTER_ID=$(dfx canister id ces-example-rs)
echo CANISTER_ID id: $CANISTER_ID

echo login = $( \
    eval dfx canister --no-wallet call  ces-example-rs login "'(principal \"rrkah-fqaaa-aaaaa-aaaaq-cai\", \"CAS_USER\")'" 
    \
)

echo query = $( \
    eval dfx canister --no-wallet call  ces-example-rs get_count 
    \
)




echo ---finish---


# dfx stop
