###
Backbone DataLink Library v0.2
Copyright 2012, Pascal Hartig
Dual licensed under the MIT or GPL Version 3 licenses.
###

((root, factory) ->
    if typeof exports isnt 'undefined'
        # Node/CommonJS
        factory(root, exports, require('synapse'))
    else if typeof define is 'function' and define.amd
        # AMD
        define('datalink', ['synapse', 'exports'], (synapse, exports) ->
            factory(root, exports, synapse))
    else
        # Browser globals
        root.DataLink = factory(root, {}, root.Synapse)
)(this, (root, DataLink, Synapse) ->

    checkView = (view) ->
        unless view.model?
            throw new Error "View #{view.toString()} must be bound to a model!"

    return {
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

        linkView: (view, elements, defaultOptions, elementOptions) ->
            # Build local default options
            defaults = _.defaults(defaultOptions or {}, @defaultOptions)

            checkView(view)
            observer = new Synapse(view.model)

            syncOptions = {
                triggerOnBind: defaults.triggerOnBind
            }

            customSyncWith = (observed) ->
                observer
                    .observe(observed, syncOptions)
                    .notify(observed, syncOptions)

            prefill = (observed, localElementOptions) ->
                if localElementOptions?.prefill is false
                    return

                # Check if the options have explicitly been set.
                if not defaults.prefill and
                    localElementOptions?.prefill isnt true
                        return

                attribute = observed.hook.detectOtherInterface(observed.raw)
                interface = observed.hook.detectInterface(observed.raw)
                observed.hook.setHandler(observed.raw, interface,
                    view.model.get(attribute))
                observed.set(attribute, observed)

            bind = ($element, localElementOptions) ->
                if customBind = localElementOptions?.bind
                    observeFnName = customBind
                else
                    observeFnName = defaults.bind

                if observeFnName == 'syncWith'
                    observeFn = customSyncWith
                else
                    observeFn = observer[observeFnName]

                observed = new Synapse($element)
                prefill(observed, localElementOptions)
                observeFn.call(observer, observed)

            checkElement = ($element, selector, localElementOptions) ->
                # Throw error if so desired.
                unless $element.length
                    # Exlicitly set
                    if localElementOptions?.ignoreEmpty is true
                        return

                    if not defaults.ignoreEmpty and
                        localElementOptions?.ignoreEmpty isnt false

                            throw new Error("""No matching element found
                                for selector #{selector}!""")

            findElement = (element, localElementOptions) ->
                attribute = localElementOptions?.attribute or defaults.attribute
                selector = "[#{attribute}=#{element}]"
                $element = view.$(selector)
                checkElement($element, selector, localElementOptions)

                return $element

            for element in elements
                localElementOptions = elementOptions?[element]
                # Build jQuery object
                $element = findElement(element, localElementOptions)
                bind($element, localElementOptions)
    }
)
