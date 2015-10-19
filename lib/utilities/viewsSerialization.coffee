Backbone = require 'backbone'


###
backbone.syphon configuration
==================================
###
module.exports = (Module, App, Backbone, Marionette, $, _) ->

  Backbone.Syphon.KeySplitter = (key) ->
    key.split '.'

  Backbone.Syphon.KeyJoiner = (parentKey, childKey) ->
    parentKey + '.' + childKey
