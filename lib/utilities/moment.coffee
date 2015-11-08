Moment = require 'moment'


###
HTTP error handler
===================

Trigger custom errors on HTTP errors

###
module.exports = (Module, App, Backbone, Marionette, $, _) ->

  @listenTo App.channel, 'locale:loaded', (lang) ->
    if lang
      Moment.locale lang