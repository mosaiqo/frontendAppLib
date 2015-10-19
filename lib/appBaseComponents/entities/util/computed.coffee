_ = require 'underscore'


module.exports =

  # don't send to the server virtual attributes
  clearTransientVirtuals: (method, entity, options) ->
    if method is 'create' or method is 'update' or method is 'patch'
      keysToRemove  = @getTransientVirtuals()
      attrs         = options.attrs or entity.toJSON()
      options.attrs = _.omit attrs, keysToRemove


  getTransientVirtuals: ->
    ret = []
    if @computed
      for computedKey, mutator of @computed
        if mutator.transient
          ret.push computedKey
    ret


  setupComputed: ->
    @listenTo @, 'beforeSync', @clearTransientVirtuals
