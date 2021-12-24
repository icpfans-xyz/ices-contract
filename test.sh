#!/bin/bash

# set -e

# clear
# dfx stop
# rm -rf .dfx

# dfx start --clean --background --emulator
dfx build --check
dfx canister --no-wallet create --all
dfx canister --no-wallet install ices -m reinstall 
dfx canister --no-wallet install ices-example-motoko -m reinstall 
dfx canister --no-wallet install ices-example-rs -m reinstall 
echo canister installed

dfx identity use default

DEFAULT_ID=$(dfx identity get-principal)
echo default principal = $DEFAULT_ID


ICES=$(dfx canister id ices)
echo ICES id: $ICES

MOTOKO_ID=$(dfx canister id ices-example-motoko)
echo motoko example id: $MOTOKO_ID

RUST_ID=$(dfx canister id ices-example-rs)
echo rust example  id: $RUST_ID


echo -----example motoko test------


echo  setting motoko  ices canister = $( \
        eval dfx canister --no-wallet call  $MOTOKO_ID setICESCanister "'(\"$ICES\")'"
)

echo Register Motoko Project = $( \
    eval dfx canister call $MOTOKO_ID register
)

echo emit motoko example login

eval dfx canister --no-wallet call  $MOTOKO_ID login "'(\"param1_motoko_login\", \"param1_motoko_login\")'"

echo emit motoko example eventLogExample 

eval dfx canister --no-wallet call  $MOTOKO_ID eventLogExample "'(\"param1_motoko\", \"param1_motoko\")'"


echo -----example rust test------

echo  setting rust  ices canister = $( \
        eval dfx canister --no-wallet call  $RUST_ID set_ces_canister "'(\"$ICES\")'"
)

echo Register Rust Project = $( \
    eval dfx canister call $RUST_ID register
)

echo emit rust example login

eval dfx canister --no-wallet call  $RUST_ID login "'(\"rust_rust_login\")'"

echo -----ICES Query-----

echo getStorageList = $( \
    eval dfx canister call $ICES getStorageList 
)

echo getLogSize = $( \
    eval dfx canister call $ICES getLogSize 
)

echo getEventLogs = $( \
    eval dfx canister call $ICES getEventLogs "'( 1:nat, 8:nat)'"
)


# echo dfx setController = $( \
#     eval dfx canister --no-wallet update-settings ICES --controller $ICES
#     \
# )

# echo status = $( \
#     eval dfx canister --no-wallet call $ICES getCanisterStatus
#     \
# )

# echo canister setController = $( \
#     eval dfx canister --no-wallet call $ICES setController "'(principal \"$DEFAULT_ID\")'"
#     \
# )

# echo status = $( \
#     eval dfx canister --no-wallet call $ICES getCanisterStatus
#     \
# )






echo ---finish---


# dfx stop
