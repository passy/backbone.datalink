=================
Backbone.DataLink
=================

Simple wrapper around Synapse to keep data between your Backbone models and
views in sync.

Example
=======

To sync the elements title and description of your model with the
corresponding input fields in your rendered view, add this after your
rendering is done::

    datalink.linkView(this, ['title', 'description'])

Your template may look like this::

    <input data-bind=title>
    <textarea data-bind=description>

To override the default settings, provide a hash as third parameter::

    datalink.linkView(this, ['title', 'description'], {prefill: false})

To override certain settings for specific elements, provide a third element::

    datalink.linkView(this, ['title', 'description'], {prefill: true}, {
        'title': {attribute: "name"},
        'description': {prefill: false}
    })

Options
=======

    * ``bind``, default ``syncWith``
        * Binding function. One of 'syncWith', 'observe' or 'notify'.
    * ``attribute``, default ``data-bind``
        * HTML attribute to look for to map model attributes.
    * ``ignoreEmpty``, default ``false``
        * If false, raises an exception if an element could not be bound.
    * ``prefill``, default ``true``
        * Fill observed elements with model data on load.
    * ``triggerOnBind``, default ``false``
        * Fire change event after binding.

License
=======

Dual licensed under the MIT or GPL Version 3 licenses.
