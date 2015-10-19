moduleUtil    = require './moduleManager'
moduleNavUtil = require './moduleNavigation'


###
Modules loader
================
###
module.exports = (Module, App, Backbone, Marionette, $, _) ->

  App.channel.reply 'app:navigation', ->
    moduleNavUtil.getApplicationModulesNavigation App

  # most application modules (all of them except the User module that handles
  # the authentification, the Entities module, and some purely UI modules) are
  # not autostarted and should not start untill the user is authenticated
  @listenTo App.channel, 'auth:authenticated', ->
    moduleUtil.startApplicationModules()

  @listenTo App.channel, 'auth:unauthenticated', ->
    moduleUtil.stopApplicationModules()

  # register the modules
  moduleUtil.registerAppModules App
