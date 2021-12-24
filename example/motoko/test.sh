#!/bin/bash

# set -e

# clear
# dfx stop
# rm -rf .dfx

# dfx start --clean --background --emulator
dfx canister --no-wallet create --all
dfx build --check
dfx canister --no-wallet install cas_call -m reinstall --all
echo canister installed


CAS_CALL=$(dfx canister id cas_call)
echo cas_call id: $CAS_CALL



echo call login example = $( \
    eval dfx canister call $CAS_CALL login "'(\"param1\", \"param2\",)'"
    \
)


echo call eventLogExample = $( \
    eval dfx canister call $CAS_CALL eventLogExample "'(\"param1\", \"param2\",)'"
    \
)


echo ---finish---


# dfx stop
