$           = require 'jquery'
requestUtil = require './requestUtil'


###
Utility to setup HTTP request headers
======================================
###
module.exports = (Module, App, Backbone, Marionette, $, _) ->

  _.extend App,

    ###
    HTTP request transformer

    Overrides the URLs and adds the appropiate headers.

    @param {String} urlRoot     original URL base
    @param {String} newUrlRoot  new URL base
    ###
    httpRequestUrlTransform: (urlRoot, newUrlRoot) ->
      baseUrl = new RegExp '^' + urlRoot

      $.ajaxPrefilter (opts, originalOpts, jqXHR) ->
        if baseUrl.test opts.url

          # backup the original one (in order to do checks or anything)
          opts.originalUrl = opts.url

          # overwrite the url with the new base
          opts.url = requestUtil.setUrlRoot opts.url, baseUrl, newUrlRoot

          opts
