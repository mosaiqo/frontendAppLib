describe 'lib/utilities/httpErrorHandler', ->
  httpErrorHandler = require 'lib/utilities/httpErrorHandler'
  Application      = require 'lib/appBaseComponents/Application'
  $                = require 'jquery'
  mockjax          = require('jquery-mockjax')($)


  app = null

  before (done) ->
    app = new Application
      channelName: 'MosaiqoApp'

    # attach the httpErrorHandler
    app.module 'Utilities', httpErrorHandler

    # mock a fake server
    $.mockjaxSettings.logging = false

    $.mockjax
      url:          '/error/404'
      status:       404
      responseText: 'Ups!!!'

    $.mockjax
      url:          '/error/500'
      status:       500
      responseText: 'Ups!!!'

    done()


  after (done) ->
    $.mockjax.clear()
    app._destroy()
    done()


  it 'should trigger a custom appplication event on 500 http error', (done) ->
    app.channel.on 'http:error', (err) ->
      expect(err).to.have.property 'textStatus'
      expect(err).to.have.property 'errorThrown'
      done()
    $.get '/error/500'


  it 'should trigger a custom appplication event on 404 http error', (done) ->
    app.channel.on 'http:error', (err) ->
      expect(err).to.have.property 'textStatus'
      expect(err).to.have.property 'errorThrown'
      done()
    $.get '/error/404'
