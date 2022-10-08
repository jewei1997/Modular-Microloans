# include .env file and export its env vars
# (-include to ignore error if it does not exist)
-include .env

deploy : forge script script/Deploy.s.sol:Deploy --rpc-url ${ETH_RPC_URL} --private-key ${ETH_KEYSTORE} --legacy --broadcast -vvvv