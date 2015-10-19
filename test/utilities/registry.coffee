describe 'lib/utilities/registry', ->
  Application    = require 'lib/appBaseComponents/Application'
  ViewController = require 'lib/appBaseComponents/controllers/ViewController'
  Registry       = require 'lib/utilities/registry'

  app = null


  beforeEach (done) ->
    app = new Application
      channelName: 'MosaiqoApp'

    # attach the controller registry
    app.module 'Utilities', Registry
    done()


  afterEach (done) ->
    app._destroy()
    done()



  it 'should register a controller when instantiated', (done) ->
    controller   = new ViewController()
    registrySize = app.channel.request 'registry:size'
    expect(registrySize).to.equal(1)

    controller.destroy()

    done()



  it 'should deregister a controller when requested', (done) ->
    controller = new ViewController()

    controller.destroy()

    registrySize = app.channel.request 'registry:size'
    expect(registrySize).to.equal(0)

    done()


  it 'should destroy all the registered controllers when requested', (done) ->

    controller1 = new ViewController()
    controller2 = new ViewController()

    app.channel.request 'reset:registry'

    registrySize = app.channel.request 'registry:size'
    expect(registrySize).to.equal(0)

    done()


  it 'should return the total amount of controllers registered', (done) ->
    controller1 = new ViewController()
    controller2 = new ViewController()

    registrySize = app.channel.request 'registry:size'
    expect(registrySize).to.equal(2)

    controller1.destroy()
    controller2.destroy()

    done()
