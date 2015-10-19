describe 'lib/utilities/navigation', ->
  navigation  = require 'lib/utilities/navigation'
  Application = require 'lib/appBaseComponents/Application'
  Marionette  = require 'backbone.marionette'
  sinon       = require 'sinon'


  app         = null
  router      = null
  fooRouteSpy = null
  barRouteSpy = null


  beforeEach (done) ->
    # create an empty app
    app = new Application
      channelName: 'MosaiqoApp'

    # attach the module
    app.module 'utils', navigation

    # register some dummy routes
    spy = sinon.spy()

    fooRouteSpy = sinon.spy()
    barRouteSpy = sinon.spy()

    router = new Marionette.AppRouter
      routes:
        'foo' : fooRouteSpy
        'bar' : barRouteSpy

    done()


  afterEach (done) ->
    app.stopHistory()
    router = null
    app._destroy()
    done()


  it 'should start Backbone.history', (done) ->
    app.startHistory()

    # backbone.history does not expose any `started` attribute or something
    # but throws an error when trying to start it if it is already started
    expect( app.startHistory ).to.throw Error

    done()


  it 'should return the current route', (done) ->
    app.startHistory()

    # initial route
    expect( app.getCurrentRoute() ).to.be.null

    # naviate to some route
    app.navigate 'foo'
    expect( app.getCurrentRoute() ).to.equal 'foo'

    done()


  it 'should navigate to some route', (done) ->
    app.startHistory()

    nav = app.navigate 'foo'
    expect( fooRouteSpy.calledOnce ).to.be.true

    done()


  it 'should stop Backbone.history', (done) ->
    app.startHistory()

    nav = app.navigate 'foo'
    expect(nav).not.to.be.false
    expect( app.getCurrentRoute() ).to.equal 'foo'

    app.stopHistory()

    nav = app.navigate 'bar'
    expect(nav).to.be.false
    expect( app.getCurrentRoute() ).to.not.equal 'bar'

    done()


  it 'should reload the current route', (done) ->
    app.startHistory()
    app.navigate 'foo'
    app.reloadRoute()

    expect( fooRouteSpy.calledTwice ).to.be.true
    done()
