_          = require 'underscore'
BaseObject = require '../appBaseComponents/Object'


module.exports = class CategorizableModelControllerHelper extends BaseObject

  defaults:
    categoryModelAttribute: 'category'
    categoryFactory:        null


  initialize: (args) ->
    { @model, @collection, @formView, options } = args

    options ?= {}
    @options = _.defaults options, @defaults

    @setupListeners()


  ###
  Category hanling setup

  The tags attribute is a little bit special because it contains a collection,
  so its necessary to perform some actions when savinf the model
  ###
  setupListeners: () ->
    categoryAttr = @options.categoryModelAttribute

    # process the category when the form is submitted (before the model is saved)
    @listenTo @formView, 'form:submit', (data) =>
      data[categoryAttr] = @processCategory data

    # update the categories collection with any new category
    # so the new category get available for other entities
    @listenTo @model, 'created, updated', =>
      modelCategory = @model.get categoryAttr
      @collection.add modelCategory




  ###
  Category processing before the model is saved

  When saving the model, Syphon returns the `category` field value
  as a string, but the model `category` attribute contains a model.
  The method updates the model from the category name.

  @param {Object} data    The serialized form
  ###
  processCategory: (data) ->
    categoryAttr = @options.categoryModelAttribute

    # the new category to assign
    requestedCategory = if data[categoryAttr] then data[categoryAttr] else ''

    # current model category
    modelCategory = @model.get categoryAttr

    # retrieve the category model
    categoryModel = @findCategoryByDefaultName requestedCategory

    # if nothing found, create a new category
    unless categoryModel
      categoryFactory = @options.categoryFactory

      if categoryFactory
        categoryModel = @appChannel.request categoryFactory

        # set the name on the default locale (the model is new,
        # so the locales collection should contain only one locale)
        locales  = categoryModel.get 'locales'
        locale   = locales.at 0
        locale.set 'name', requestedCategory
      else
        categoryModel = null

    data[categoryAttr] = categoryModel


  ###
  Find a category by the name attribute of its default locale

  @param  {String} categoryName
  @return {Model} The category model, or null if nothing found
  ###
  findCategoryByDefaultName: (categoryName) ->
    ret = null
    @collection.forEach (category) ->
      locale = category.get 'defaultLocale'

      if locale and locale.name is categoryName
        ret = category
    ret
