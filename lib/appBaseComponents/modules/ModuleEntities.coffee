# Dependencies
# -----------------------
_             = require 'underscore'
globalFactory = require 'lib/utilities/factory'

# Base class
Module        = require './Module'



###
Module entities submodule
==========================

Handles the instantiation of the entities exposed by some module.
###
module.exports = class ModuleEntities extends Module

  ###
  @property {String} Factory id

  When dealing with relations, in some circumstances there may be circular
  references between the related models, and this is very problematic with
  browserify/node require method.

  So, instead, there's a global application factory object that handles the
  instantiation of entities avoiding direct references.

  The 'global' factory methods are namespaced to make it scalable.
  So, for example, in 'blog:entities|TagsCollection', 'blog:entities' is th NS.
  ###
  factoryId: null


  ###
  @property {Object} Maps the identifiers to the classes

  Override it on the subclasses
  ###
  factoryClassMap: {}


  ###
  @property {Function} the factory method
  ###
  factory: (entity, args = {}, opts = {}) =>
    @factoryClassMap[entity] or null


  ###
  Usually, when an entity is needed, it needs to be initialized with some defaults
  or with some state. This methods centralize this functionality here instead of
  disseminating it across multiple controllers and other files.
  ###
  handlers: {}

  registerHandlers: ->
    handlers = if _.isFunction(@handlers) then @handlers() else @handlers

    _.each handlers, (callback, key) =>
      @appChannel.reply key, callback


  ###
  Init method, initializes the factory and the radio handlers
  ###
  initialize: ->
    globalFactory.register @factoryId, @factory
    @registerHandlers()


  ###
  Initialize some entity and its state
  ###
  initializeEntityWithOptions: (entity, options = {}) ->
    if options.customExpands
      entity.expandedRelations = options.customExpands

    if options.state and _.isFunction entity.setState
      entity.setState options.state


  ###
  Init some model

  Instantiates a model with the appropiate options and fetches it

  @param  {String}  factoryId the identifier for the class used by the factory
  @param  {Integer} id        the Model id
  @param  {Object}  options
  @return {Model}
  ###
  initializeModel: (factoryId, id, options = {}) ->
    entity = globalFactory.invoke factoryId
    model  = new entity
      id: id

    @initializeEntityWithOptions model, options
    model.fetch()
    model


  ###
  Get a new (empty) Model

  @param  {String} factoryId the identifier for the class used by the factory
  @param  {Object} defaults  initial attributes
  @return {Model}
  ###
  initializeEmptyModel: (factoryId, defaults = {}) ->
    entity = globalFactory.invoke factoryId
    new entity defaults


  ###
  Init some collection

  Instantiates the collection with the appropiate options and fetches it

  @param  {String} factoryId the identifier for the class used by the factory
  @param  {Object} options
  @return {Collection}
  ###
  initializeCollection: (factoryId, options = {}) ->
    entity     = globalFactory.invoke factoryId
    collection = new entity

    @initializeEntityWithOptions collection, options
    collection.fetch
      reset: true
    collection
