/*
Backbone DataLink Library v0.2
Copyright 2012, Pascal Hartig
Dual licensed under the MIT or GPL Version 3 licenses.
*/
(function(root, factory) {
  if (typeof exports !== 'undefined') {
    return factory(root, exports, require('synapse'), require('underscore'));
  } else if (typeof define === 'function' && define.amd) {
    return define('datalink', ['synapse', 'underscore', 'exports'], function(synapse, underscore, exports) {
      return factory(root, exports, synapse, underscore);
    });
  } else {
    return root.DataLink = factory(root, {}, root.Synapse);
  }
})(this, function(root, DataLink, Synapse, _) {
  var checkView;
  _ || (_ = window._);
  checkView = function(view) {
    if (view.model == null) {
      throw new Error("View " + (view.toString()) + " must be bound to a model!");
    }
  };
  _.extend(DataLink, {
    version: "0.2",
    defaultOptions: {
      bind: 'syncWith',
      attribute: 'data-bind',
      ignoreEmpty: false,
      prefill: true,
      triggerOnBind: false
    },
    _getLocalOptions: function(elements, defaultOptions, elementOptions) {
      var defaults, element, locals, _i, _len;
      defaults = _.defaults(defaultOptions || {}, this.defaultOptions);
      locals = {};
      for (_i = 0, _len = elements.length; _i < _len; _i++) {
        element = elements[_i];
        locals[element] = _.defaults((elementOptions != null ? elementOptions[element] : void 0) || {}, defaults);
      }
      return locals;
    },
    linkView: function(view, elements, defaultOptions, elementOptions) {
      var $element, bind, checkElement, customSyncWith, element, findElement, localElementOptions, localOptions, observer, prefill, _i, _len, _results;
      localOptions = this._getLocalOptions(elements, defaultOptions, elementOptions);
      checkView(view);
      observer = new Synapse(view.model);
      customSyncWith = function(observed, syncOptions) {
        return observer.observe(observed, syncOptions).notify(observed, syncOptions);
      };
      prefill = function(observed, localElementOptions) {
        var attribute, interface;
        if (localElementOptions.prefill === false) return;
        attribute = observed.hook.detectOtherInterface(observed.raw);
        interface = observed.hook.detectInterface(observed.raw);
        observed.hook.setHandler(observed.raw, interface, view.model.get(attribute));
        return observed.set(attribute, observed);
      };
      bind = function($element, localElementOptions) {
        var observeFn, observeFnName, observed, syncOptions;
        observeFnName = localElementOptions.bind;
        if (observeFnName === 'syncWith') {
          observeFn = customSyncWith;
        } else {
          observeFn = observer[observeFnName];
        }
        syncOptions = {
          triggerOnBind: localElementOptions.triggerOnBind
        };
        observed = new Synapse($element);
        prefill(observed, localElementOptions);
        return observeFn.call(observer, observed, syncOptions);
      };
      checkElement = function($element, selector, localElementOptions) {
        if (!($element.length || localElementOptions.ignoreEmpty)) {
          throw new Error("No matching element found\nfor selector " + selector + "!");
        }
      };
      findElement = function(element, localElementOptions) {
        var $element, attribute, selector;
        attribute = localElementOptions.attribute;
        selector = "[" + attribute + "=" + element + "]";
        $element = view.$(selector);
        checkElement($element, selector, localElementOptions);
        return $element;
      };
      _results = [];
      for (_i = 0, _len = elements.length; _i < _len; _i++) {
        element = elements[_i];
        localElementOptions = localOptions[element];
        $element = findElement(element, localElementOptions);
        _results.push(bind($element, localElementOptions));
      }
      return _results;
    }
  });
  return DataLink;
});
