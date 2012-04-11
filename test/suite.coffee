mocha = require('mocha')
assert = require('chai').assert
datalink = require('../src/backbone.datalink')

suite 'DataLink', ->
    suite 'local options', ->
        elements = ['test1', 'test2']

        test 'should override default options with local options', ->
            defaults =
                attribute: 'id'
                prefill: false

            local =
                test1:
                    attribute: 'class'

            options = datalink._getLocalOptions(elements, defaults, local)

            # Global defaults are preserved
            assert.equal(options.test1.bind, 'syncWith')

            # Global default override
            assert.isFalse(options.test1.prefill)

            # Local override
            assert.equal(options.test1.attribute, 'class')
            assert.equal(options.test2.attribute, 'id')

        test 'should work with just global defaults', ->
            options = datalink._getLocalOptions(elements)
            assert.isTrue(options.test1.prefill)
