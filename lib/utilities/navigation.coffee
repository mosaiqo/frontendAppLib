_        = require 'underscore'
Backbone = require 'backbone'

###
App navigation utils
=====================
###
module.exports = (Module, App, Backbone, Marionette, $, _) ->

  _.extend App,

    ###
    Navigate to some route

    @param {String} route
    @param {Object} optins
    ###
    navigate: (route, options = {}) ->
      Backbone.history.navigate route, options


    ###
    Current route getter

    @return {String}
    ###
    getCurrentRoute: ->
      frag = Backbone.history.fragment
      if _.isEmpty(frag) then null else frag


    ###
    Start the backbone history object
    ###
    startHistory: ->
      if Backbone.history
        Backbone.history.start()


    ###
    Stop the backbone history object
    ###
    stopHistory: ->
      if Backbone.history
        Backbone.history.stop()


    ###
    Force reload the current route
    ###
    reloadRoute: ->
      Backbone.history.loadUrl(Backbone.history.fragment)
