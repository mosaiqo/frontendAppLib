_ = require 'underscore'
$ = require 'jquery'


###
Model/collection fetch callbacks util
======================================
###
module.exports = (Module, App, Backbone, Marionette, $, _) ->

  ###
  Execute something after some entities have been fetched

  @param {Backbone.Model|Backbone.Collection} entities  Entities to fetch, arrays are accepted
  @param {Function} callback
  ###
  App.channel.reply 'when:fetched', (entities, callback) ->
    xhrs = _.chain([entities]).flatten().pluck('_fetch').value()

    $.when(xhrs...).done ->
      callback()
