-include .env

.PHONY: all test deploy report

test:; forge test -vv

test-mt:
	@read -p "Enter test name: " name; \
	forge test --match-test $$name -vvvv

report:
	forge coverage --report lcov && \
	awk '/^SF:/{file=$$0} /^DA:/ {split($$0,a,","); if (a[2]==0) print substr(file,4) ": line " a[1] " not covered"}' lcov.info


