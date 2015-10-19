Marionette = require 'backbone.marionette'
channel    = require '../../utilities/appChannel'


module.exports = class Module extends Marionette.Module

  # Don't automatically start the module
  # Instead, init it manually for more control
  startWithParent: false

  # application global Radio channel
  appChannel: channel
