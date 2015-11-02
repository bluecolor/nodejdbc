PATH := ./node_modules/.bin:${PATH}

.PHONY : init clean build test

init:
	npm install

docs:
	codo -t nodejdbc

clean-docs:
	rm -rf docs/

clean: 
	clean-docs
	rm -fr lib/ test/*.js

build:
	coffee -o lib/ -c src/ && coffee -c test/test.coffee

test:
	cd test && mocha test.js && cd ../

# dist: 
# 	clean init docs build test

# publish: 
# 	dist
# 	npm publish