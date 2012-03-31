#!/bin/sh

coffee -o dist/ -cb src/
uglifyjs dist/backbone.datalink.js > dist/backbone.datalink.min.js
