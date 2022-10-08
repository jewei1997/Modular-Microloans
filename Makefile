# include .env file and export its env vars
# (-include to ignore error if it does not exist)
-include .env

deploy 	:; 	forge script script/Deploy.s.sol:Deploy --rpc-url ${ETH_RPC_URL} --private-keys ${ETH_KEYSTORE} --private-keys ${ADDRESS_USER} --private-keys ${ADDRESS_USER_2} --legacy --broadcast -vvvv
deploy-check-expiration 	:; 	forge script script/CheckExpirationDeploy.s.sol:CheckExpirationDeploy --rpc-url ${ETH_RPC_URL} --private-key ${ETH_KEYSTORE} --legacy --broadcast -vvvv
