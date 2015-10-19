# Libs/generic stuff:
_          = require 'underscore'
i18n       = require 'i18next-client'
Backbone   = require 'backbone'
Marionette = require 'backbone.marionette'
tabTmpl    = require './templates/tab.hbs'


###
Localised view behaviour
=========================

Behaviour for view than handle localised models using a tabbed interface.

@class

###
module.exports = class Localised extends Marionette.Behavior

  _rendered: false

  ###
  @property {Object} Default options
  ###
  defaults: ->
    tabMenu:          '.localesMenu'
    localeMenu:       '.localesManagementMenu'
    addLocaleBtns:    '.addLocale'
    removeLocaleBtns: '.localesMenu .close'


  ###
  @property {Object} DOM elements
  ###
  ui: ->
    tabMenu:          @options.tabMenu
    localeMenu:       @options.localeMenu
    addLocaleBtns:    @options.addLocaleBtns
    removeLocaleBtns: @options.removeLocaleBtns


  ###
  @property {Object} handlers config. for UI elements
  ###
  events:
    'click @ui.addLocaleBtns':    'addLocale'
    'click @ui.removeLocaleBtns': 'removeLocale'


  ###
  @property {Object} handlers config. for the collection
  ###
  collectionEvents:
    'add':              'createLocaleTab'
    'remove':           'destroyLocaleTab'
    'add remove reset': 'updateLocaleMenu'


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
    @view.serializationDefaults = _.defaults serializationDefaults,
      lcl: {}

    ###
    View collection override

    Overrides the view collection property with a clone of the model
    'locales' attribute. This is implemented here instead of the views or
    controllers to avoid code repetition. The collection overriding is done
    just before the view rendering in order to ensure the entity has been
    fetched and the locales collection is available.

    The collection is cloned so it can be manipulated without persisting the
    changes on the server until the model is saved.
    ###
    @listenTo @view, 'before:render', =>
      locales = @view.model.get 'locales'

      if locales
        localesClone     = locales.deepClone true
        @view.collection = localesClone

        # bind again the collectionEvents
        @bindEntityEvents localesClone, @collectionEvents


  ###
  Handler executed when the view is rendered
  ###
  onRender: ->
    @_rendered = true
    @activateLocaleTab()
    @updateLocaleMenu()


  ###
  Add a new locale to the views model locales collection
  ###
  addLocale: (e) ->
    e.preventDefault()
    lang = @$(e.currentTarget).data 'value'

    if lang
      @view.collection.addLocale lang


  ###
  Remove a new locale from the views model locales collection
  ###
  removeLocale: (e) ->
    e.preventDefault()
    e.stopPropagation()
    if window.confirm(i18n.t 'Are you sure you want to delete this?')
      lang = @$(e.currentTarget).parent('a').data 'value'

      if lang
        @view.collection.removeLocale lang


  ###
  Create a locale tab

  The tab content is automatically added by Marionette (this behaviour is applied
  to a composite view) when the collection is updated, but the tab itself must be
  added separatelly in order to avoid innecessary complications (that should
  require a layout view and multiple additional views)

  @param {EntityLocale} the locale model that has been added
  ###
  createLocaleTab: (model) ->
    unless @_rendered then return

    lang = model.get 'id'

    # args passed to the template
    tmplArgs =
      label:     lang
      target:    "locale-#{lang}"
      closeable: true
      value:     lang

    # create the tab
    tab  = tabTmpl tmplArgs

    # append it to the DOM
    if @ui.localeMenu.length
      @ui.localeMenu.before tab
    else
      @ui.tabMenu.append tab

    @activateLocaleTab lang


  ###
  Remove a locale tab

  @param {EntityLocale} the locale model that has been removed
  ###
  destroyLocaleTab: (model) ->
    unless @_rendered then return

    lang = model.get 'id'
    @ui.tabMenu.find("[href=#locale-#{lang}]").parent('li').remove()
    @activateLocaleTab()


  ###
  Toggle the add locale menu options

  Disable the options that are already active and enable the others
  ###
  updateLocaleMenu: ->
    unless @_rendered then return

    locales = @view.collection

    if locales
      activeLocales = _.pluck locales.toJSON(), 'id'

      @ui.addLocaleBtns.each (i, n) =>
        opt    = @$(n)
        optVal = opt.data 'value'

        if activeLocales.indexOf(optVal) > -1
          opt.attr 'disabled', 'disabled'
          opt.parent('li').addClass 'disabled'
        else
          opt.removeAttr 'disabled'
          opt.parent('li').removeClass 'disabled'


  ###
  Show some locale tab

  @param {String} lang the tab locale
  ###
  activateLocaleTab: (lang) ->
    localeTab = if lang then "a[href=#locale-#{lang}]" else "a:first"

    setTimeout(=>
      if @ui.tabMenu instanceof $
        @ui.tabMenu.find(localeTab).tab 'show'
    , 500)
