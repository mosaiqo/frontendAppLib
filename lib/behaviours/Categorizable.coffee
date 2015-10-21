_          = require 'underscore'
Backbone   = require 'backbone'
Marionette = require 'backbone.marionette'


###
Taggable behaviour
========================================
###
module.exports = class Categorizable extends Marionette.Behavior

  ###
  @property {Object} Default options
  ###
  defaults: ->
    categoryField:          '[name="category"]'
    categoryModelAttribute: 'category'



  ###
  @property {Object} DOM elements
  ###
  ui: ->
    categoryField: @options.categoryField


  ###
  Behaviour initialization
  ###
  initialize: ->
    # When the views are serialized, the form controller returns
    # the result of backbone.syphon serialization, merged with
    # an optional defaults deffined in the view.
    # So inject an additional key to the defaults, to make sure
    # the locales are always parsed (even if the user removes them
    # all from the view)
    serializationDefaults = @view.serializationDefaults or {}

    newDefaults = {}
    newDefaults[@options.categoryModelAttribute] = null
    @view.serializationDefaults = _.defaults serializationDefaults, newDefaults



  ###
  Handler executed when the view is rendered
  ###
  onRender: ->
    # wait a little so syphon can do their stuff
    setTimeout(=>
      if _.isString @ui.categoryField then return

      # by default, using syphon to populate the form, it will set a JSON as a value
      # change the value to something that selectize can interpret correctly
      category = @view.model.get @options.categoryModelAttribute

      if category and category instanceof Backbone.Model
        defaultLocale = category.get 'defaultLocale'
        @ui.categoryField.val defaultLocale.name

      # setup the widget
      @setUpCategoriesWidget @view.availableCategories
    , 200)



  ###
  Converts the categories input field (just a text input) into a categories widget

  @param {Collection} availableCategories  Tags Collection used to autocomplete
                                           while the user types. The user can still
                                           create new categories (not on the autocomplete)
  ###
  setUpCategoriesWidget: (availableCategories) ->
    @ui.categoryField.selectize
      persist: true
      maxItems: 1
      options: @buildOptions availableCategories
      createOnBlur: true,
      create: true
      allowEmptyOption: true
      closeAfterSelect: true



  ###
  Converts the tags collection into an array usable by the widget

  @param {Collection} categories  Tags Collection used to autocomplete
  ###
  buildOptions: (categories) ->
    unless categories
      return []

    categories.reduce((memo, category) ->
      locale  = category.get 'defaultLocale'

      if locale
        categoryName = locale.name
        memo.push { text: categoryName, value: categoryName }
      memo
    , [])
