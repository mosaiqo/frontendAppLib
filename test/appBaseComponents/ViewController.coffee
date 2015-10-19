describe 'lib/appBaseComponents/controllers/ViewController', ->
  Application    = require 'lib/appBaseComponents/Application'
  ViewController = require 'lib/appBaseComponents/controllers/ViewController'
  Marionette     = require 'backbone.marionette'
  sinon          = require 'sinon'
  $              = require 'jquery'


  app = null


  beforeEach (done) ->
    # create an empty app
    app = new Application
      channelName: 'MosaiqoApp'
    done()


  afterEach (done) ->
    app._destroy()
    done()


  it 'should have an unique id', (done) ->
    controller1 = new ViewController()
    controller2 = new ViewController()

    expect(controller1).to.have.property '_instance_id'
    expect(controller1._instance_id).to.not.equal controller2._instance_id

    controller1.destroy()
    controller2.destroy()
    done()


  it 'should have a region if provided', (done) ->
    controllerRegion = new Marionette.Region
      el: '#foo'

    controller = new ViewController
      region: controllerRegion

    expect(controller).to.have.property 'region'
    expect(controller.region).to.be.instanceof Marionette.Region

    controller.destroy()
    done()


  it 'should have a default region if region is not provided', (done) ->
    app.channel.reply 'default:region', ->
      new Marionette.Region
        el: '#foo'

    controller = new ViewController()

    expect(controller).to.have.property 'region'
    expect(controller.region).to.be.instanceof Marionette.Region

    controller.destroy()
    done()


  it 'should should auto register itself when instantiating', (done) ->
    spy = sinon.spy()
    app.channel.reply 'register:instance', spy

    controller = new ViewController()

    expect( spy.calledOnce ).to.be.true

    done()


  it 'should should auto deregister itself when instantiating', (done) ->
    spy = sinon.spy()
    app.channel.reply 'unregister:instance', spy

    controller = new ViewController()
    controller.destroy()

    expect( spy.calledOnce ).to.be.true
    done()


  it 'should render a view to the controller region', (done) ->
    el = $('<div id="foo" />').appendTo 'body'

    app.channel.reply 'default:region', ->
      new Marionette.Region
        el: '#foo'

    controller = new ViewController()
    view       = new Marionette.View()

    controller.show view

    expect( controller.region.hasView() ).to.be.true

    el.remove()
    done()


  it 'should destroy tself if the view is destroyed', (done) ->
    el = $('<div id="foo" />').appendTo 'body'

    app.channel.reply 'default:region', ->
      new Marionette.Region
        el: '#foo'

    controller = new ViewController()
    view       = new Marionette.View()

    controller.show view

    spy = sinon.spy()
    app.channel.reply 'unregister:instance', spy

    view.destroy()

    expect( spy.calledOnce ).to.be.true
    el.remove()
    done()
