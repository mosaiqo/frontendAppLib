_          = require 'underscore'
Marionette = require 'backbone.marionette'


###
Template helpers for Handlebars templates

The `templateHelpers` property in Marionette views is designed
for Underscore templates. In order to use this feature with
Handlebars, the `mixinTemplateHelpers` method must be overrided

@see http://mikefowler.me/2014/02/20/template-helpers-handlebars-backbone-marionette/
###
Marionette.View::mixinTemplateHelpers = (target) ->
  self = @
  templateHelpers = Marionette.getOption self, 'templateHelpers'
  result = {}

  target = target or {}

  if _.isFunction templateHelpers
    templateHelpers = templateHelpers.call self

  # This _.each block is what we're adding
  _.each templateHelpers, (helper, index) ->
    if _.isFunction helper
      result[index] = helper.call self
    else
      result[index] = helper

  _.extend target, result
