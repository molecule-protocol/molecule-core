source ./.env

FOUNDRY_PROFILE=default forge script script/DeployContracts.s.sol --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvvv --legacy