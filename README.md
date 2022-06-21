# GrabCoinClub Contract  

# Setup

```shell
yarn install
```

# Bscscan verification

To try out Bscscan verification, you first need to deploy a contract to a Binance network that's supported by Bscscan, such as testnet and mainnet.

In this project, copy the .env.example file to a file named .env, and then edit it to fill in the details. Enter your Bscscan API key, and the private key of the account which will send the deployment transaction. With a valid .env file in place, first deploy your contract:

For mainnet:
```shell
hardhat run --network mainnet scripts/deploy.ts
```

For testnet:
```shell
hardhat run --network testnet scripts/deploy.ts
```

Then, copy the deployment addresses and paste it in to replace `DEPLOYED_CONTRACT_ADDRESS` in this command:

```shell
npx hardhat verify --network mainnet DEPLOYED_CONTRACT_ADDRESS
```

You have to verify 2 contracts(Gold and Token).