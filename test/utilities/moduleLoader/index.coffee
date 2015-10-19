describe 'lib/utilities/moduleLoader', ->
  Application       = require 'lib/appBaseComponents/Application'
  Module            = require 'lib/appBaseComponents/modules/Module'
  ModuleLoader      = require 'lib/utilities/moduleLoader'
  appModulesFixture = require 'test/app/fixtures/other/appModules'

  app = null


  before (done) ->
    app = new Application
      channelName: 'MosaiqoApp'

    # register some fake modules
    app.modulesRegistry = appModulesFixture

    # attach the module loader
    app.module 'Utilities', ModuleLoader
    done()


  after (done) ->
    app._destroy()
    done()


  it 'should attach all the modules to the app', (done) ->
    for module in appModulesFixture
      expect(app.submodules).to.have.property module.id
      expect(app).to.have.property module.id
      expect(app[module.id] instanceof Module).to.be.true

    done()


  it 'should attach any nested module to their parent modules', (done) ->
    # see the fixture
    expect(app.FakeModule2).to.have.property 'FakeModule3'
    expect(app.FakeModule2.submodules).to.have.property 'FakeModule3'
    expect(app).to.not.have.property 'FakeModule3'
    expect(app.submodules).to.not.have.property 'FakeModule3'
    expect(app.FakeModule2.FakeModule3 instanceof Module).to.be.true

    expect(app.FakeModule2).to.have.property 'FakeModule4'
    expect(app.FakeModule2.submodules).to.have.property 'FakeModule4'
    expect(app).to.not.have.property 'FakeModule4'
    expect(app.submodules).to.not.have.property 'FakeModule4'
    expect(app.FakeModule2.FakeModule4 instanceof Module).to.be.true

    done()


  it 'should return the navigation structure for the modules when requested', (done) ->
    navItems = app.channel.request 'app:navigation'
    expect(navItems).to.be.instanceof Array
    done()


  describe 'Auth events for modules with a startWithParent:false attribute', ->

    it 'should start the modules when a "auth:authenticated" event is fired', (done) ->
      # the modules don't hace any attribute to check if they're running
      # so is necessary to use events to check the module state
      app.FakeModule2.on 'start', ->
        done()

      app.channel.trigger 'auth:authenticated'

    it 'should stop the modules when a "auth:unauthenticated" event is fired', (done) ->
      app.FakeModule2.on 'stop', ->
        done()

      app.FakeModule2.start()
      app.channel.trigger 'auth:unauthenticated'
