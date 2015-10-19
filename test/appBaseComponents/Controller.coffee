describe 'lib/appBaseComponents/controllers/Controller', ->
  Application = require 'lib/appBaseComponents/Application'
  Controller  = require 'lib/appBaseComponents/controllers/Controller'
  Marionette  = require 'backbone.marionette'
  Radio       = require 'backbone.radio'


  app = null


  beforeEach (done) ->
    # create an empty app
    app = new Application
      channelName: 'MosaiqoApp'
    done()


  afterEach (done) ->
    app._destroy()
    done()


  it 'should have an appChannel', (done) ->
    controller = new Controller()

    expect(controller).to.have.property 'appChannel'
    expect(controller.appChannel).to.be.an.instanceof Radio.Channel
    expect(controller.appChannel.channelName).to.equal app.channel.channelName

    controller.destroy()
    done()
