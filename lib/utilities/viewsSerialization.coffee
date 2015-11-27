$        = require 'jquery'
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

    if /\[\]$/.test(name)
      ctx = $el.parents('form').first()
      $elems = if ctx then ctx.find('[name="' + name + '"]') else $('[name="' + name + '"]')
      return $elems.serializeArray().map (o) -> o.value
    else
      return $el.prop 'checked'


  Backbone.Syphon.KeyAssignmentValidators.register 'checkbox', ($el, key, value) ->
    name = $el.prop 'name'
    if /\[\]$/.test(name) then $el.prop 'checked' else true
