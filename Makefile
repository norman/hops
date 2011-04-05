.PHONY: test spec

test:
	@tsc test/*.lua
	
spec:
	@tsc -f test/*.lua
	
