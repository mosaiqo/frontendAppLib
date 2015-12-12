_       = require 'underscore'
bootbox = require 'bootbox'


###
Dialogs (alerts, prompts, ...) component
=========================================

Basically a wrapper around Bootbox

###
module.exports = (Module, App, Backbone, Marionette, $, _) ->

  # bootbox already has its own locale system,
  # but does not include catalan
  bootbox.addLocale 'ca',
    OK      : 'OK'
    CANCEL  : 'Cancelar'
    CONFIRM : 'Acceptar'

  # set the default locale
  locale = App.channel.request 'locale:get'
  bootbox.setLocale locale

  # listen for locale changes
  @listenTo App.channel, 'locale:loaded', (locale) ->
    bootbox.setLocale locale



  App.channel.reply 'dialogs:alert', (args...) ->
    bootbox.alert args...

  App.channel.reply 'dialogs:prompt', (args...) ->
    bootbox.prompt args...

  App.channel.reply 'dialogs:confirm', (args...) ->
    bootbox.confirm args...

  App.channel.reply 'dialogs:dialog', (args...) ->
    bootbox.dialog args...
