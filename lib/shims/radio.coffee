Marionette = require 'backbone.marionette'
Radio      = require 'backbone.radio'
_          = require 'underscore'


# A shim to replace Backbone.Wreqr with Backbone.Radio in Marionette
Marionette.Application::_initChannel = ->
  @channelName = _.result(this, 'channelName') or 'global'
  @channel = _.result(this, 'channel') or Radio.channel(@channelName)
  return

module.exports = {}
