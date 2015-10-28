$    = require 'jquery'
i18n = require 'i18next-client'


###
HTTP error handler
===================

Trigger custom errors on HTTP errors

###
module.exports = (Module, App, Backbone, Marionette, $, _) ->

  $.ajaxPrefilter (opts, originalOpts, jqXHR) ->

    # trigger a custom error if the server returns a 500 or a 404 error
    _error = opts.error
    opts.error = (jqXHR, textStatus, errorThrown) ->

      # The 0 status code happens if the request could not be done
      # When doing CORS requests, if the server throws a 500 on the
      # OPTIONS request, the actual one can not be performed
      if [0,500,422,404,401].indexOf(jqXHR.status) > -1
        error =
          textStatus:  textStatus
          errorThrown: errorThrown

        if jqXHR.status is 422
          error.errorThrown = i18n.t('Validation error')

        # On a CORS request, if the preflight request fails,
        # the errorThrown is empty
        if jqXHR.status is 0
          error.errorThrown = i18n.t('Error communicating with the server')
          error.corsError   = true

        App.channel.trigger 'http:error', error

      # fire the original callback
      if _.isFunction _error then _error(jqXHR, textStatus, errorThrown)
