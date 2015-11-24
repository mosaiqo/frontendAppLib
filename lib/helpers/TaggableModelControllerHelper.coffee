_          = require 'underscore'
BaseObject = require '../appBaseComponents/Object'
I18nModel  = require '../appBaseComponents/entities/I18nModel'


module.exports = class TaggableModelControllerHelper extends BaseObject

  defaults:
    tagsModelAttribute: 'tags'
    tagFactory:         null



  initialize: (args) ->
    { @model, @collection, @formView, options } = args

    options ?= {}
    @options = _.defaults options, @defaults

    @setupListeners()


  ###
  Tags hanling setup

  The tags attribute is a little bit special because it contains a collection,
  so its necessary to perform some actions when saving the model
  ###
  setupListeners: () ->
    tagsAttr = @options.tagsModelAttribute

    # process the tags when the form is submitted (before the model is saved)
    @listenTo @formView, 'form:submit', (data) => @processTags data

    # update the allTags collection with any new tag
    # so the new tags get available for other entities
    @listenTo @model, 'created, updated', =>
      modelTags = @model.get tagsAttr
      @collection.add modelTags



  ###
  Tags processing before the model is saved

  When saving the model, Syphon returns the `tags` field value
  as a string, but the model `tags` attribute contains a collection.
  The method updates the collection from the tags names.

  @param {Object} data    The serialized form
  ###
  processTags: (data) ->
    tagsAttr = @options.tagsModelAttribute

    # the new tags to assign, as 'tag1,tag2,tagN'
    requestedTags = if data[tagsAttr] then data[tagsAttr].split(',') else []

    # current model tags
    modelTags = @model.get [tagsAttr]

    # the tag models array that will be used to reset the entity `tags`collection
    newTags = requestedTags.map (tagName) =>
      # retrieve the tag model
      tagModel = @findTagByName tagName

      # if nothing found, create a new tag
      unless tagModel
        tagFactory = @options.tagFactory

        if tagFactory
          tagModel =  @appChannel.request tagFactory
          @_setTagName tagModel, tagName
        else
          tagModel = null
      tagModel

    data[tagsAttr] = newTags


  ###
  Find a Tag by its name
  (if the Tag has locales, the nam of the default locale)

  @param  {String} tagName
  @return {Model} The tag model, or null if nothing found
  ###
  findTagByName: (tagName) ->
    ret = null
    @collection.forEach (tag) =>
      if @_getTagName(tag) is tagName
        ret = tag
    ret


  ###
  @return {String} The name of some tag model
  ###
  _getTagName: (model) ->
    if model instanceof I18nModel
      defaultLocale = model.get 'defaultLocale'
      tagName       = defaultLocale.name
    else
      tagName       = model.get 'name'

    tagName


  ###
  @param {Tag}    model The model
  @param {String} name  The new name
  ###
  _setTagName: (model, name) ->
    if model instanceof I18nModel
      # set the name on the default locale (the model is new,
      # so the locales collection should contain only one locale)
      locales  = model.get 'locales'
      locale   = locales.at 0
      locale.set 'name', name

    else
      model.set 'name', name