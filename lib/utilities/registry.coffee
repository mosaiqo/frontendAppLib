_ = require 'underscore'


###
Controller registry
=====================

Utility to keep track of the instantiated controllers
###
module.exports = (Module, App, Backbone, Marionette, $, _) ->

  API =

    ###
    Register some controller

    @param {ModuleController} instance The controller instance
    @param {String} id                 A unique id for the controller
    ###
    register: (instance, id) ->
      App._registry ?= {}
      App._registry[id] = instance


    ###
    Unregister some controller

    @param {ModuleController} instance The controller instance
    @param {String} id                 A unique id for the controller
    ###
    unregister: (instance, id) ->
      delete App._registry[id]


    ###
    Destroy all the registered controllers
    ###
    resetRegistry: ->
      oldCount = @getRegistrySize()
      for key, controller of App._registry
        if controller.region
          controller.region.destroy()
        else
          controller.destroy()

      ret =
        count: @getRegistrySize()
        previous: oldCount
        msg: "There were #{oldCount} controllers in the registry, there are now #{@getRegistrySize()}"

      console.info ret


    ###
    Registry size getter

    @return {Number} the amount of registered controllers
    ###
    getRegistrySize: ->
      _.size(App._registry)



  App.channel.reply 'register:instance', (instance, id) ->
    API.register instance, id if App.environment is 'development'

  App.channel.reply 'unregister:instance', (instance, id) ->
    API.unregister instance, id if App.environment is 'development'

  App.channel.reply 'reset:registry', ->
    API.resetRegistry()

  App.channel.reply 'registry:size', ->
    API.getRegistrySize()
