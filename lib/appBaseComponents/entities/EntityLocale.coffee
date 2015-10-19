# Dependencies
# -------------------------

# Base class (extends Backbone.Model)
Model = require './Model'


module.exports = class EntityLocale extends Model

  ###
  @return {Boolean} True if the model has been saved on the server

  Overrides the default isNew method (the original backbone method just
  checks if the model has an id, but this models might have an id passed
  to the constructor)
  ###
  isNew: ->
    !@get('created_at')
