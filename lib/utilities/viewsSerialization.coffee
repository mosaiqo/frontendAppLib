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


  Backbone.Syphon.InputReaders.register 'checkbox', ($el) ->
    name = $el.prop 'name'
    if /\[\]$/.test(name) then $el.val() else $el.prop 'checked'


  Backbone.Syphon.KeyAssignmentValidators.register 'checkbox', ($el, key, value) ->
    name = $el.prop 'name'
    if /\[\]$/.test(name) then $el.prop 'checked' else true
