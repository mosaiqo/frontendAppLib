describe 'lib/appBaseComponents/Application', ->
  Application = require 'lib/appBaseComponents/Application'
  Marionette  = require 'backbone.marionette'
  Radio       = require 'backbone.radio'


  app = null


  beforeEach (done) ->
    # create an empty app
    app = new Application()
    done()


  afterEach (done) ->
    app._destroy()
    done()


  it 'should have a default environment', (done) ->
    expect(app).to.have.property 'environment'
    expect(app.environment).to.equal 'development'
    done()


  it 'should have a backbone.radio channel', (done) ->
    expect(app).to.have.property 'channel'
    expect(app.channel).to.be.an.instanceof Radio.Channel

    expect(app).to.not.have.property 'reqres'
    expect(app).to.not.have.property 'commands'

    done()


  it 'should remove all the application modules when calling _destroy', (done) ->
    # register some dummy modules
    app.module 'foo', -> {}
    app.module 'bar', -> {}

    expect(app.foo).to.be.instanceof Marionette.Module
    expect(app.bar).to.be.instanceof Marionette.Module

    app._destroy()

    expect(app.foo).not.to.be.instanceof Marionette.Module
    expect(app.bar).not.to.be.instanceof Marionette.Module

    expect(app.foo).to.be.undefined
    expect(app.bar).to.be.undefined

    done()


  it 'should remove all the application modules when calling _destroy', (done) ->
    app.channel.on    'foo', -> should.fail()
    app.channel.reply 'bar', -> should.fail()

    app._destroy()

    app.channel.trigger 'foo'
    app.channel.request 'bar'

    done()
