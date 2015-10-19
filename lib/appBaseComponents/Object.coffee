Marionette = require 'backbone.marionette'
channel    = require '../utilities/appChannel'


module.exports = class Object extends Marionette.Object

  # application global Radio channel
  appChannel: channel
