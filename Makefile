.PHONY: test

TEST_FILES?=modulus nvidia/compile
test:
	@shellcheck $(TEST_FILES)
