describe 'lib/appBaseComponents/Router', ->
  Application = require 'lib/appBaseComponents/Application'
  Router      = require 'lib/appBaseComponents/Router'
  Backbone    = require 'backbone'
  Marionette  = require 'backbone.marionette'
  sinon       = require 'sinon'


  app = null


  beforeEach (done) ->
    # create an empty app
    app = new Application
      channelName: 'MosaiqoApp'
    done()


  afterEach (done) ->
    app._destroy()
    done()


  it 'should expand the prefixedAppRoutes to appRoutes prefixed with the provided rootUrl', (done) ->
    spy = sinon.spy()

    class CustomController extends Marionette.Controller
      bar: spy

    class CustomRouter extends Router
      prefixedAppRoutes:
        '/bar' : 'bar'

    moduleRouter = new CustomRouter
      controller: new CustomController()
      rootUrl:    'foo'

    Backbone.history.start()
    Backbone.history.navigate 'foo/bar', {trigger: true}

    expect( spy.calledOnce ).to.be.true

    # reset to avoid interfering with other tests
    Backbone.history.navigate null, {trigger: true}
    Backbone.history.stop()

    done()
