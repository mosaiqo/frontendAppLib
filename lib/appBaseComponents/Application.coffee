Marionette = require 'backbone.marionette'
Radio      = require 'backbone.radio'

# Apply the radio shim so backbone.radio is used instead of backbone.wreqr
require '../shims/radio'



module.exports = class Application extends Marionette.Application

  ###
  @property {String} App environment
  ###
  environment: 'development'


  ###
  @property {String} Default channel used by backbone.radio
  ###
  channelName: 'global'


  ###
  Application destroy method

  Stops and deregisters the modules and resets the radio channels
  Only used in the tests
  ###
  _destroy: =>
    for moduleName, module of @submodules
      @module(moduleName).stop()
      delete @submodules[moduleName]
      delete @[moduleName]

    Radio.reset()
