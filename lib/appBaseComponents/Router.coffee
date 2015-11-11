Backbone   = require 'backbone'
Marionette = require 'backbone.marionette'


module.exports = class Router extends Marionette.AppRouter

  active: false

  initialize: (options) ->
    rootUrl = options.rootUrl ? ''

    # Initialize the appRoutes
    if @prefixedAppRoutes? then @_setupPrefixedAppRoutes rootUrl

    # The application might be composed by multiple routers
    # for the different modules. Trigger an event on the router
    # controller whenever the router becomes active (one of the
    # router routes is matched) or inactive, so the controller
    # can initialize or cleanup stuff.
    if rootUrl and options.controller
      @_setupNavigationHandlers rootUrl, options.controller


  _setupPrefixedAppRoutes: (moduleUrl) ->
    for route, action of @prefixedAppRoutes
      @appRoute moduleUrl + route, action


  _setupNavigationHandlers: (moduleUrl, controller) ->
    @listenTo Backbone.history, 'route', =>
      url     = Backbone.history.getFragment()
      regex   = @_getRouteRegex moduleUrl
      matches = regex.test url

      if matches and not @active
        @active = true
        Marionette.triggerMethodOn controller, 'active'

      if not matches and @active
        @active = false
        Marionette.triggerMethodOn controller, 'inactive'


  _getRouteRegex: (moduleUrl) -> new RegExp '^' + moduleUrl