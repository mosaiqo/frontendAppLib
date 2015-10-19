describe 'lib/utilities/i18n', ->
  i18nUtil    = require 'lib/utilities/i18n'
  Application = require 'lib/appBaseComponents/Application'
  sinon       = require 'sinon'


  app    = null
  server = null


  before (done) ->

    # mock the server
    server = sinon.fakeServer.create()

    server.respondWith 'GET', /\/assets\/locales\/*/, (req) ->
      status  = 200
      headers = { 'Content-Type': 'application/json' }
      body    = '{}'

      req.respond status, headers, body

    # create an empty app
    app = new Application
      channelName: 'MosaiqoApp'

    # attach the httpErrorHandler
    app.module 'i18n', i18nUtil

    done()


  after (done) ->
    server.restore()
    app._destroy()
    done()


  it 'should trigger an event when the locale is loaded', (done) ->
    app.listenTo app.channel, 'locale:loaded', ->
      app.stopListening app.channel, 'locale:loaded'
      done()
    server.respond()


  it 'should return the current locale when requested', (done) ->
    lang = app.channel.request 'locale:get'
    server.respond()
    expect(lang).to.be.a 'string'
    done()


  it 'should load the requested language', (done) ->
    app.channel.request 'locale:set', 'ca'
    server.respond()

    lang = app.channel.request 'locale:get'
    expect(lang).to.be.equal 'ca'
    done()


  it 'should return an array ob language configurations when requested', (done) ->
    langs = app.channel.request 'locale:entities'

    expect(langs).to.be.instanceof Array
    expect(langs).to.have.length.at.least 1

    expect(langs[0]).to.have.property 'lang'
    expect(langs[0]).to.have.property 'label'

    expect(langs[0].lang).to.be.a 'string'
    expect(langs[0].label).to.be.a 'string'
    done()


  it 'should load all the deffined module namespaces', (done) ->
    ModuleLoader      = require 'lib/utilities/moduleLoader'
    appModulesFixture = require 'test/app/fixtures/other/appModules'

    # register some fake modules
    app.modulesRegistry = appModulesFixture

    # attach the module loader
    app.module 'Utilities', ModuleLoader

    app.listenTo app.channel, 'locales:loaded', ->
      app.stopListening app.channel, 'locales:loaded'
      done()

    app.channel.request 'locale:loadModulesNS', app.modulesRegistry
    server.respond()
