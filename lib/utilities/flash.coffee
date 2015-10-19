_      = require 'underscore'
toastr = require 'toastr'


###
Flash messaging component
===========================

###
module.exports = (Module, App, Backbone, Marionette, $, _) ->

  API =

    ###
    Message options parser

    Parses the options and merges in some defaults

    @param  {Object} opts  the original options
    @return {Object}       the new options
    ###
    parseOptions: (opts) ->
      opts = _.defaults opts,
        timeOut: 4000
        progressBar: true

      if opts.persist
        opts.timeOut = 0
        progressBar  = false

      opts


    ###
    Remove any active messages
    ###
    clear: ->
      toastr.clear()


    ###
    Create a message

    @param  {String} level    Message level ('info'|'success'|'warn'|'error')
    @param  {String} message  Message to show
    @param  {String} title    Message title
    @param  {Object} options  Flash options
    ###
    flash: (level, message = '', title = '', options = {}) ->
      opts = @parseOptions options
      toastr[level] message, title, opts



  App.channel.reply 'flash:clear', ->
    API.clear()

  App.channel.reply 'flash:info', (message = '', title = '', options = {}) ->
    API.flash 'info', message, title, options

  App.channel.reply 'flash:success', (message = '', title = '', options = {}) ->
    API.flash 'success', message, title, options

  App.channel.reply 'flash:error', (message = '', title = '', options = {}) ->
    API.flash 'error', message, title, options

  App.channel.reply 'flash:warn', (message = '', title = '', options = {}) ->
    API.flash 'warning', message, title, options
