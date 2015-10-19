describe 'lib/utilities/httpRequestUrlTransformer', ->
  Application = require 'lib/appBaseComponents/Application'
  requestUtil = require 'lib/utilities/httpRequestUrlTransformer'
  sinon       = require 'sinon'

  app    = null
  server = null


  before (done) ->
    app = new Application()

    # attach the module
    app.module 'Utilities', requestUtil

    # mock the API server
    server = sinon.fakeServer.create()

    server.respondWith 'GET', '/api/v1/foo', (req) ->
      status  = 200
      headers = { 'Content-Type': 'application/json' }
      body    = '{}'
      req.respond status, headers, body

    done()


  after (done) ->
    server.restore()
    app._destroy()
    done()


  it 'should override the API communication with the appropiate options', (done) ->
    app.httpRequestUrlTransform '/api', '/api/v1'

    $.getJSON '/api/foo', (response) ->
      done()

    server.respond()

    # restore
    app.httpRequestUrlTransform '/api/v1', '/api'
