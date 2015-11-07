_          = require 'underscore'
BaseObject = require '../appBaseComponents/Object'
I18nModel  = require '../appBaseComponents/entities/I18nModel'


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

  The category attribute is a little bit special because it contains a model,
  so its necessary to perform some actions when saving the model
  ###
  setupListeners: () ->
    categoryAttr = @options.categoryModelAttribute

    # process the category when the form is submitted (before the model is saved)
    @listenTo @formView, 'form:submit', (data) => @processCategory data

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

    unless data[categoryAttr]
      data[categoryAttr] = null
    else
      # the new category to assign
      requestedCategory = data[categoryAttr]

      # current model category
      modelCategory = @model.get categoryAttr

      # retrieve the category model
      categoryModel = @findCategoryByName requestedCategory

      # if nothing found, create a new category
      unless categoryModel
        categoryFactory = @options.categoryFactory

        if categoryFactory
          categoryModel = @appChannel.request categoryFactory
          @_setCategoryName categoryModel, requestedCategory
        else
          categoryModel = null

      data[categoryAttr] = categoryModel


  ###
  Find a category by its name
  (if the Category has locales, the nam of the default locale)

  @param  {String} categoryName
  @return {Model} The category model, or null if nothing found
  ###
  findCategoryByName: (categoryName) ->
    ret = null
    @collection.forEach (category) =>
      if @_getCategoryName(category) is categoryName
        ret = category
    ret



  ###
  @return {String} The name of some category model
  ###
  _getCategoryName: (model) ->
    if model instanceof I18nModel
      defaultLocale = model.get 'defaultLocale'
      categoryName  = defaultLocale.name
    else
      categoryName  = model.name

    categoryName


  ###
  @param {Category} model The model
  @param {String}   name  The new name
  ###
  _setCategoryName: (model, name) ->
    if model instanceof I18nModel
      # set the name on the default locale (the model is new,
      # so the locales collection should contain only one locale)
      locales  = model.get 'locales'
      locale   = locales.at 0
      locale.set 'name', name

    else
      model.set 'name', name