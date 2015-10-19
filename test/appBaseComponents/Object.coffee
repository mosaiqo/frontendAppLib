describe 'lib/appBaseComponents/Object', ->
  Application = require 'lib/appBaseComponents/Application'
  AppObject   = require 'lib/appBaseComponents/Object'
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
    obj = new AppObject()

    expect(obj).to.have.property 'appChannel'
    expect(obj.appChannel).to.be.an.instanceof Radio.Channel
    expect(obj.appChannel.channelName).to.equal app.channel.channelName

    done()
