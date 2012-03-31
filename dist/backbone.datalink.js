/*
Backbone DataLink Library v0.2
Copyright 2012, Pascal Hartig
Dual licensed under the MIT or GPL Version 3 licenses.
*/
(function(root, factory) {
  if (typeof exports !== 'undefined') {
    return factory(root, exports, require('synapse'));
  } else if (typeof define === 'function' && define.amd) {
    return define('datalink', ['synapse', 'exports'], function(synapse, exports) {
      return factory(root, exports, synapse);
    });
  } else {
    return root.DataLink = factory(root, {}, root.Synapse);
  }
})(this, function(root, DataLink, Synapse) {
  var checkView;
  checkView = function(view) {
    if (view.model == null) {
      throw new Error("View " + (view.toString()) + " must be bound to a model!");
    }
  };
  return {
    version: "0.2",
    defaultOptions: {
      bind: 'syncWith',
      attribute: 'data-bind',
      ignoreEmpty: false,
      prefill: true,
      triggerOnBind: false
    },
    linkView: function(view, elements, defaultOptions, elementOptions) {
      var $element, bind, checkElement, customSyncWith, defaults, element, findElement, localElementOptions, observer, prefill, syncOptions, _i, _len, _results;
      defaults = _.defaults(defaultOptions || {}, this.defaultOptions);
      checkView(view);
      observer = new Synapse(view.model);
      syncOptions = {
        triggerOnBind: defaults.triggerOnBind
      };
      customSyncWith = function(observed) {
        return observer.observe(observed, syncOptions).notify(observed, syncOptions);
      };
      prefill = function(observed, localElementOptions) {
        var attribute, interface;
        if ((localElementOptions != null ? localElementOptions.prefill : void 0) === false) {
          return;
        }
        if (!defaults.prefill && (localElementOptions != null ? localElementOptions.prefill : void 0) !== true) {
          return;
        }
        attribute = observed.hook.detectOtherInterface(observed.raw);
        interface = observed.hook.detectInterface(observed.raw);
        observed.hook.setHandler(observed.raw, interface, view.model.get(attribute));
        return observed.set(attribute, observed);
      };
      bind = function($element, localElementOptions) {
        var customBind, observeFn, observeFnName, observed;
        if (customBind = localElementOptions != null ? localElementOptions.bind : void 0) {
          observeFnName = customBind;
        } else {
          observeFnName = defaults.bind;
        }
        if (observeFnName === 'syncWith') {
          observeFn = customSyncWith;
        } else {
          observeFn = observer[observeFnName];
        }
        observed = new Synapse($element);
        prefill(observed, localElementOptions);
        return observeFn.call(observer, observed);
      };
      checkElement = function($element, selector, localElementOptions) {
        if (!$element.length) {
          if ((localElementOptions != null ? localElementOptions.ignoreEmpty : void 0) === true) {
            return;
          }
          if (!defaults.ignoreEmpty && (localElementOptions != null ? localElementOptions.ignoreEmpty : void 0) !== false) {
            throw new Error("No matching element found\nfor selector " + selector + "!");
          }
        }
      };
      findElement = function(element, localElementOptions) {
        var $element, attribute, selector;
        attribute = (localElementOptions != null ? localElementOptions.attribute : void 0) || defaults.attribute;
        selector = "[" + attribute + "=" + element + "]";
        $element = view.$(selector);
        checkElement($element, selector, localElementOptions);
        return $element;
      };
      _results = [];
      for (_i = 0, _len = elements.length; _i < _len; _i++) {
        element = elements[_i];
        localElementOptions = elementOptions != null ? elementOptions[element] : void 0;
        $element = findElement(element, localElementOptions);
        _results.push(bind($element, localElementOptions));
      }
      return _results;
    }
  };
});
