
# ICES

ICES (Internet Computer Event System) is a canister custom event log storage and analysis service on Dfinity.Provide and implement automatic expansion solutions for large amounts of data storage.

# Concept
* Proxy Canister: Log data write and query entry. dispatch log data to stroage canister
* Storage Canister: Canister for storing data

![ices](./ices.png)

# Features and Roadmap
- [x] Storage Canister automatic expansion of storage
- [x] Proxy Canister dispatch log data to stroage canister
- [ ] Proxy Canister adds a queue mechanism to ensure data is stored in storage
- [ ] Proxy Canister stores data to achieve automatic expansion
- [ ] Provides motoko and rust sdk


# Running the project locally

If you want to test your project locally, you can use the following commands:

```bash
# Starts the replica, running in the background
dfx start --background

# Deploys your canisters to the replica and generates your candid interface
dfx deploy
```

# How to test

```bash
# Run the file test.sh
./test.sh

```