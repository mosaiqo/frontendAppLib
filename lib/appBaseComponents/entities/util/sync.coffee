_        = require 'underscore'
Backbone = require 'backbone'

# backup the original method
_sync      = Backbone.sync
customSync = null

do (Backbone) ->

  customSync = (method, entity, options = {}) ->
    _.defaults options,
      beforeSend:  _.bind(methods.beforeSend, entity)
      complete:    _.bind(methods.complete,   entity)

    sync = _sync(method, entity, options)

    # save a reference to the xhr object so it can be retrieved
    # to defer other actions, like when calling collection.create
    entity._xhr = sync

    if !entity._fetch and method is 'read'
      entity._fetch = sync

    # return the result (it returns a xhr object)
    sync

  methods =
    beforeSend: ->
      @trigger "sync:start", @
    complete: ->
      @trigger "sync:stop", @


module.exports = customSync
