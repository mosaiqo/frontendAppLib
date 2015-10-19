describe 'lib/appBaseComponents/modules/Module', ->
  Application = require 'lib/appBaseComponents/Application'
  Module      = require 'lib/appBaseComponents/modules/Module'
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
    module = app.module 'foo', Module

    expect(module).to.have.property 'appChannel'
    expect(module.appChannel).to.be.an.instanceof Radio.Channel
    expect(module.appChannel.channelName).to.equal app.channel.channelName

    done()


  it 'should not autostart', (done) ->
    module = app.module 'foo', Module
    module.on 'start', -> should.fail()
    app.start()

    done()
