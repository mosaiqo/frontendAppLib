Backbone   = require 'backbone'
Marionette = require 'backbone.marionette'


module.exports = class Router extends Marionette.AppRouter

  active: false

  initialize: (options) ->
    rootUrl = options.rootUrl ? ''

    # Initialize the appRoutes
    if @prefixedAppRoutes?
      for route, action of @prefixedAppRoutes
        @appRoute rootUrl + route, action

    # The application might be composed by multiple routers
    # for the different modules. Trigger an event on the router
    # controller whenever the router becomes active (one of the
    # router routes is matched) or inactive, so the controller
    # can initialize or cleanup stuff.
    if rootUrl and options.controller
      @listenTo Backbone.history, 'route', =>
        url     = Backbone.history.getFragment()
        regex   = new RegExp '^' + rootUrl
        matches = regex.test url

        if matches and not @active
          @active = true
          Marionette.triggerMethodOn options.controller, 'active'

        if not matches and @active
          @active = false
          Marionette.triggerMethodOn options.controller, 'inactive'
