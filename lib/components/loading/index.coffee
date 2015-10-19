LoadingController = require './LoadingController'
channel           = require 'lib/utilities/appChannel'


module.exports = (Module, App, Backbone, Marionette, $, _) ->

  channel.reply 'show:loading', (view, options) ->
    new LoadingController
      view:   view
      region: options.region
      config: options.loading
