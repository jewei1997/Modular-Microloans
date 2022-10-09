# include .env file and export its env vars
# (-include to ignore error if it does not exist)
-include .env

deploy 						:; 	forge script script/Deploy.s.sol:Deploy --rpc-url ${ETH_RPC_URL} --private-keys ${ETH_KEYSTORE} --private-keys ${ADDRESS_USER} --private-keys ${ADDRESS_USER_2} --legacy --broadcast -vvvv
deploy-automatic-checks 	:; 	forge script script/DeployAutomaticChecks.s.sol:DeployAutomaticChecks --rpc-url ${ETH_RPC_URL} --private-key ${ETH_KEYSTORE} --legacy --broadcast -vvvv
mint-usdc 					:; 	forge script script/MintMockUSDC.s.sol:MintMockUSDC --rpc-url ${ETH_RPC_URL} --private-key ${ETH_KEYSTORE} --legacy --broadcast -vvvv
flatten						:; 	forge flatten ./src/PreCommitManager.sol -o ./out/flat/PreCommitManager.sol && forge flatten ./src/CheckExpiring.sol -o ./out/flat/CheckExpiring.sol && forge flatten ./src/CheckExpired.sol -o ./out/flat/CheckExpired.sol
