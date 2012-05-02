###
Backbone DataLink Library v0.3
Copyright 2012, Pascal Hartig
Dual licensed under the MIT or GPL Version 3 licenses.
###

((root, factory) ->
    if typeof exports isnt 'undefined'
        # Node/CommonJS
        factory(root, exports, require('synapse'), require('underscore'))
    else if typeof define is 'function' and define.amd
        # AMD
        define('datalink', ['synapse', 'underscore', 'exports'],
            (synapse, underscore, exports) ->
                factory(root, exports, synapse, underscore))
    else
        # Browser globals
        root.DataLink = factory(root, {}, root.Synapse)
)(this, (root, DataLink, Synapse, _) ->

    # To make underscore work in both browsers and in node environments
    _ or= window._

    checkView = (view) ->
        unless view.model?
            throw new Error "View #{view.toString()} must be bound to a model!"

    _.extend(DataLink, {
        version: "0.2"

        defaultOptions:
            # Binding function. One of syncWith, observe, notify.
            bind: 'syncWith'
            # Attribute to look for to map elements
            attribute: 'data-bind'
            # Ignore elements that could not be bound.
            ignoreEmpty: false
            # Fill observed elements with model data
            prefill: true
            # Fire event on directly bind
            triggerOnBind: false

        _getLocalOptions: (elements, defaultOptions, elementOptions) ->
            defaults = _.defaults(defaultOptions or {}, @defaultOptions)
            locals = {}

            for element in elements
                locals[element] = _.defaults(elementOptions?[element] or {}, defaults)

            return locals

        linkView: (view, elements, defaultOptions, elementOptions) ->
            # Build local default options
            localOptions = @_getLocalOptions(elements,
                defaultOptions, elementOptions)

            checkView(view)
            observer = new Synapse(view.model)

            customSyncWith = (observed, syncOptions) ->
                observer
                    .observe(observed, syncOptions)
                    .notify(observed, syncOptions)

            prefill = (observed, localElementOptions) ->
                if localElementOptions.prefill is false
                    return

                attribute = observed.hook.detectOtherInterface(observed.raw)
                iface = observed.hook.detectInterface(observed.raw)
                observed.hook.setHandler(observed.raw, iface,
                    view.model.get(attribute))
                observed.set(attribute, observed)

            bind = ($element, localElementOptions) ->
                observeFnName = localElementOptions.bind

                if observeFnName == 'syncWith'
                    observeFn = customSyncWith
                else
                    observeFn = observer[observeFnName]

                syncOptions =
                    triggerOnBind: localElementOptions.triggerOnBind

                observed = new Synapse($element)
                prefill(observed, localElementOptions)
                observeFn.call(observer, observed, syncOptions)

            checkElement = ($element, selector, localElementOptions) ->
                # Throw error if so desired.
                if not $element.length and localElementOptions.ignoreEmpty is false
                        throw new Error("""No matching element found
                            for selector #{selector}!""")

            findElement = (element, localElementOptions) ->
                attribute = localElementOptions.attribute
                selector = "[#{attribute}=#{element}]"
                $element = view.$(selector)
                checkElement($element, selector, localElementOptions)

                return $element

            for element in elements
                localElementOptions = localOptions[element]
                # Build jQuery object
                $element = findElement(element, localElementOptions)
                bind($element, localElementOptions)
    })

    return DataLink
)
