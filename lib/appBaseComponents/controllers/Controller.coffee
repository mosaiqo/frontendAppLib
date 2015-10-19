Marionette = require 'backbone.marionette'
channel    = require 'lib/utilities/appChannel'


module.exports = class Controller extends Marionette.Controller

  # application global Radio channel
  appChannel: channel
