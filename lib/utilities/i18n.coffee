$       = require 'jquery'
_       = require 'underscore'
i18n    = require 'i18next-client'
conf    = require('../config').get().locales


###
App localization
===================
###
module.exports = (Module, App, Backbone, Marionette, $, _) ->

  ###
  @property {Object} i18next options
  ###
  opts =
    ###
    @property {String} Key to override the lang using the querystring
    ###
    detectLngQS:         'lang'

    ###
    @property {String} Cookie name to persist the lang
    ###
    cookieName:          'lang'

    ###
    @property {String} Path for the locale files
    ###
    resGetPath:          '/assets/locales/__lng__/__ns__.json'

    ###
    @property {String} Dont't load country specific files (for example, load `en` instead of `en-us`)
    ###
    load:                'unspecific'

    ###
    @property {Object} Locale namespaces (files).
                       Only the main one is deffined, the additonal ones (one per module,
                       for example, will be added at runtime)
    ###
    ns:
      ###
      @property {Array} namespaces to load
      ###
      namespaces:        ['app']

      ###
      @property {String} default namespace
      ###
      defaultNs:         'app'

    ###
    @property {String} Fallback NS
    ###
    fallbackNS:          'app'

    ###
    @property {Boolean} Use the fallbackNS when requesting a non existant key from some NS
    ###
    fallbackToDefaultNS: true

    ###
    @property {String} Fallback language, used when requesting a non localised key
    ###
    fallbackLng:         'en'

    ###
    @property {String} namespace separator for the keys (in this case: `i18n "ns:::key"`)
    ###
    nsseparator:         ':::'

    ###
    @property {String} key separator for the keys (in this case: `i18n "group::key"`)
    ###
    keyseparator:        '::'



  ###
  Aux. recursive function that retrieves any locale namespace from the app modules

  @param  {Object} module
  @param  {String} parentModuleId
  @return {Array}
  ###
  getModuleLocales = (module, parentModuleId = '') ->
    locales = []

    # compose the module id
    # on nested modules it will be parentModuleId.childModuleId
    moduleId = if parentModuleId then parentModuleId + '.' + module.id else module.id

    # get the module instance
    moduleObj = App.module moduleId

    if moduleObj.meta?.localeNS
      locales.push moduleObj.meta.localeNS

    if module.submodules?.length
      module.submodules.forEach (module) ->
        locales.push getModuleLocales module, moduleId

    locales



  # Handlers
  # -------------------

  ###
  Loads any locale namespace file needed by the app modules

  @param {Array} modules  application modules
  ###
  App.channel.reply 'locale:loadModulesNS', (modules) ->
    moduleLocaleNameSpaces = []

    for module in modules
      moduleLocaleNameSpaces.push getModuleLocales module

    moduleLocaleNameSpaces = _.flatten moduleLocaleNameSpaces

    if moduleLocaleNameSpaces.length
      i18n.loadNamespaces moduleLocaleNameSpaces, ->
        App.channel.trigger 'locales:loaded'
    else
      # nothing to load
      setTimeout(->
        App.channel.trigger 'locales:loaded'
      , 100)



  ###
  Change the current language
  ###
  App.channel.reply 'locale:set', (locale) ->
    i18n.setLng locale, ->
      $('html').attr 'lang', locale
      App.channel.trigger 'locale:loaded', locale



  ###
  Get the current language

  @return {String} the currently set language
  ###
  App.channel.reply 'locale:get', ->
    i18n.detectLanguage()



  ###
  Getter for the locales conf

  @return {Array} the available languages
  ###
  App.channel.reply 'locale:entities', ->
    ret = []
    for k, v of conf
      ret.push
        label: v
        lang:  k
    ret



  # init
  i18n.init opts, ->
    locale = i18n.detectLanguage()
    $('html').attr 'lang', locale
    App.channel.trigger 'locale:loaded', locale
