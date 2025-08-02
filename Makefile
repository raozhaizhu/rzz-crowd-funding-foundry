-include .env

.PHONY: all test deploy report

test:; forge test -vv

test-fork:
	@forge test --fork-url $(SEPOLIA_RPC_URL) -vvvv

test-mt:
	@read -p "Enter test name: " name; \
	forge test --match-test $$name -vvvv

report:
	forge coverage --report lcov && \
	awk '/^SF:/{file=$$0} /^DA:/ {split($$0,a,","); if (a[2]==0) print substr(file,4) ": line " a[1] " not covered"}' lcov.info

NETWORK_ARGS := --rpc-url http://127.0.0.1:8545 --private-key $(DEFAULT_ANVIL_KEY) --broadcast

ifeq ($(findstring --network sepolia,$(ARGS)),--network sepolia)
	NETWORK_ARGS := --rpc-url $(SEPOLIA_RPC_URL) --private-key $(PRIVATE_KEY) --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv
endif

deploy:
	@forge script script/DeployCrowdFunding.s.sol:DeployCrowdFunding $(NETWORK_ARGS)

	