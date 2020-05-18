
test: node_modules
	@node_modules/.bin/mocha \
		--require should \
		--recursive

node_modules: package.json
	@npm install

.PHONY: test
