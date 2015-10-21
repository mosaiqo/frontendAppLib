_        = require 'underscore'
Backbone = require 'backbone'


module.exports =

  ###
  Relation attributes filters

  When saving a model to the server, the nested attributes that contain entities
  are serialized callig to JSON. This allows to filter which attributes to send
  when a nested entity is serialized
  ###
  _applyRelationsFilters: (method, entity, options = {}) ->
    if !options.attrs or !entity.relations
      return

    attrs = options.attrs

    entity.relations.forEach (relation) =>
      relationAttr = attrs[relation.key]

      if relation.saveFilterAttributes and relationAttr
        if relation.type is Backbone.One

          # relationAttr is a model
          if relationAttr instanceof Backbone.Model
            relationAttr = relationAttr.toJSON()
          
          filtered = @_filterRelationEntity relationAttr, relation.saveFilterAttributes
          
        else
          # relationAttr is a collection
          filtered = relationAttr.reduce((memo, model) =>
            memo.push @_filterRelationEntity(model, relation.saveFilterAttributes)
            memo
          , [])

        options.attrs[relation.key] = filtered


  ###
  Aux method, retrieves only the selected entity attributes
  ###
  _filterRelationEntity: (entity, attributes) ->
    if entity instanceof Backbone.Model
      entity = entity.toJSON()

    _.pick entity, attributes


  setupRelations: ->
    @listenTo @, 'beforeSync', @_applyRelationsFilters
