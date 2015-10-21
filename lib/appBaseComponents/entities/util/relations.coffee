_        = require 'underscore'
Backbone = require 'backbone'


module.exports =

  ###
  Relation attributes filters

  When saving a model to the server, the nested attributes that contain entities
  are serialized callig to JSON. This allows to filter which attributes to send
  when a nested entity is serialized
  ###
  applyRelationsFilters: (method, entity, options = {}) ->
    if !options.attrs or !entity.relations
      return

    attrs = options.attrs

    entity.relations.forEach (relation) ->
      relationAttr = attrs[relation.key]

      if relation.saveFilterAttributes and relationAttr
        if relation.type is Backbone.One
          console.log 'one', relation.type, relationAttr
          # relationAttr is a model
          filtered = _.pick relationAttr, relation.saveFilterAttributes
        else
          console.log 'multi', relation.type, relationAttr
          # relationAttr is a collection
          filtered = relationAttr.reduce((memo, model) ->
            memo.push _.pick(model, relation.saveFilterAttributes)
            memo
          , [])

        options.attrs[relation.key] = filtered



  setupRelations: ->
    @listenTo @, 'beforeSync', @applyRelationsFilters
