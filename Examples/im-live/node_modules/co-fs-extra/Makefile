
install:
	@npm install --registry=http://registry.npm.taobao.org

test:
	@./node_modules/.bin/mocha \
		--require should \
		--reporter spec \
		--slow 2s \
		--harmony \
		--bail

autod: install
	@./node_modules/.bin/autod -w --prefix="~"
	@$(MAKE) install

.PHONY: test
