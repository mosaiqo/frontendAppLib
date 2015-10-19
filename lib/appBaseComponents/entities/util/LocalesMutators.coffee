# Dependencies
# -------------------------
_        = require 'underscore'
Backbone = require 'backbone'


###
Getters/setters for the locales
================================

Used top ease the use of the locales in the views

@class

###
module.exports = class LocalesMutators

  ###
  Default locale virtual attribute

  The default locale is intended to be used when listing all the
  collection models, showing them in the default language or the
  first available language. So, its intended to be used on admin
  pages, not end users facing pages.
  ###
  @deserializeDefaultLocale: (defaultLang) ->
    locales     = @get 'locales'
    localeModel = null

    if locales and locales instanceof Backbone.Collection
      localeModel = locales.get(defaultLang) or locales.first()

    if localeModel
      return localeModel.toJSON()
    else
      return {}



  ###
  Reformats the locales to a JSON suitable for the views
  ###
  @deserializeLocales = (defaultLang, allLangs) ->
    locales = @get 'locales'
    ret     = {}

    if locales and locales instanceof Backbone.Collection
      locales.each (locale) ->
        localeKey = locale.get 'id'
        localeVal = locale.toJSON()

        if locale.id is defaultLang
          localeVal.active = true

        # add locale name
        localeVal.localeName = allLangs[locale.id]

        ret[localeKey] = localeVal
    ret
