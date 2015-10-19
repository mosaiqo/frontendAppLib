# Dependencies
# -------------------------

# Base class (extends Backbone.Collection)
Collection = require './Collection'


module.exports = class EntityLocalesCollection extends Collection
  comparator: 'id'

  ###
  Adds an empty locale model to the locales collection
  @param {String} lang  the lang. code
  ###
  addLocale: (lang) ->
    @add { id: lang }


  ###
  Removes some locale from the locales collection
  @param {String} lang  the lang. code
  ###
  removeLocale: (lang) ->
    @remove @get(lang)
