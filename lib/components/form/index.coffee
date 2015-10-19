_              = require 'underscore'
$              = require 'jquery'
Backbone       = require 'backbone'
Marionette     = require 'backbone.marionette'
FormController = require './FormController'
Entities       = require './entities'


module.exports = (Module, App, Backbone, Marionette, $, _) ->

  # register the component entities
  App.module 'Entities', Entities

  App.channel.reply 'form:component', (contentView, options = {}) ->
    throw new Error 'Form Component requires a contentView to be passed in' if not contentView

    options.contentView = contentView
    new FormController options
