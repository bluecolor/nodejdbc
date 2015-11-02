PATH := ./node_modules/.bin:${PATH}

#.PHONY : init clean-docs clean build test dist publish

init:
	npm install

# use codo
# docs:
# 	docco --layout linear src/*.coffee

clean-docs:
	rm -rf docs/

clean: 
	clean-docs
	rm -fr lib/ test/*.js

build:
	coffee -o lib/ -c src/ && coffee -c test/x.coffee

test:
	nodeunit test/x.js

dist: 
	clean init docs build test

publish: 
	dist
	npm publish