_          = require 'underscore'
Backbone   = require 'backbone'
Marionette = require 'backbone.marionette'
I18nModel  = require '../appBaseComponents/entities/I18nModel'


###
Taggable behaviour
========================================
###
module.exports = class Taggable extends Marionette.Behavior

  ###
  @property {Object} Default options
  ###
  defaults: ->
    tagsField:          '[name="tags"]'
    tagsModelAttribute: 'tags'



  ###
  @property {Object} DOM elements
  ###
  ui: ->
    tagsField: @options.tagsField



  ###
  Behaviour initialization
  ###
  initialize: ->
    # When the views are serialized, the form controller returns
    # the result of backbone.syphon serialization, merged with
    # an optional defaults deffined in the view.
    # So inject an additional key to the defaults, to make sure
    # the tags are always parsed (even if the user removes them
    # all from the view)
    serializationDefaults = @view.serializationDefaults or {}

    newDefaults = {}
    newDefaults[@options.tagsModelAttribute] = []
    @view.serializationDefaults = _.defaults serializationDefaults, newDefaults



  ###
  Handler executed when the view is rendered
  ###
  onRender: ->
    # wait a little so syphon can do their stuff
    setTimeout(=>
      if _.isString @ui.tagsField then return

      # by default, using syphon to populate the form, it will set a JSON as a value
      # change the value to something that selectize can interpret correctly
      tags = @view.model.get @options.tagsModelAttribute

      if tags and tags instanceof Backbone.Collection
        parsed   = @buildTagOptions tags
        tagNames = _.pluck(parsed, 'text').join ','
        @ui.tagsField.val tagNames

      # setup the widget
      @setUpTagsWidget @view.availableTags
    , 200)



  ###
  Converts the tags input field (just a text input) into a tags widget

  @param {Collection} availableTags  Tags Collection used to autocomplete
                                     while the user types. The user can still
                                     create new tags (not on the autocomplete)
  ###
  setUpTagsWidget: (availableTags) ->
    @ui.tagsField.selectize
      plugins: ['remove_button']
      persist: true
      delimiter: ','
      maxItems: null
      options: @buildTagOptions availableTags
      createOnBlur: true,
      create: true



  ###
  Converts the tags collection into an array usable by the widget

  @param {Collection} availableTags  Tags Collection used to autocomplete
  ###
  buildTagOptions: (tags) ->
    unless tags
      return []

    tags.reduce((memo, tag) =>
      tagName = @_getTagName tag

      if tagName
        memo.push { text: tagName, value: tagName }
      memo
    , [])


  ###
  @return {String} The name of some tag model
  ###
  _getTagName: (model) ->
    if model instanceof I18nModel
      defaultLocale = model.get 'defaultLocale'
      tagName       = defaultLocale.name
    else
      tagName       = model.name

    tagName