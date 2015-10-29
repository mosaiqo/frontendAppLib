describe 'lib/utilities/moduleLoader/ModuleNavigation', ->
  Application = require 'lib/appBaseComponents/Application'
  ModuleNav   = require 'lib/utilities/moduleLoader/moduleNavigation'

  app = null


  before (done) ->
    app = new Application()
    done()


  afterEach (done) ->
    app.modulesRegistry = null
    delete app.modulesRegistry
    done()


  after (done) ->
    app._destroy()
    done()


  describe 'getModuleNav', ->

    it 'should return nothing if the module does not have the
    "showInModuleNavigation" attribute', (done) ->
      module = app.module 'Foo'

      module.meta = {}

      moduleNavData = ModuleNav.getModuleNav app,
        id: 'Foo'

      expect(moduleNavData).to.be.null
      done()


    it 'should return the necessary information to add a module in the nav if
    it has the "showInModuleNavigation" attr.', (done) ->
      module      = app.module 'Foo'
      module.meta =
        title: 'Foo'
        icon:  'some-icon'
        rootUrl: 'foo'
        showInModuleNavigation: true

      moduleNavData = ModuleNav.getModuleNav app,
        id: module.moduleName

      expect(moduleNavData).to.be.an 'object'
      expect(moduleNavData).to.have.property 'label'
      expect(moduleNavData).to.have.property 'icon'
      expect(moduleNavData).to.have.property 'route'

      expect(moduleNavData.icon).to.equal module.meta.icon
      expect(moduleNavData.route).to.equal module.meta.rootUrl

      done()


    it 'should return some defaults if the module has some missing information', (done) ->
      module      = app.module 'Foo'
      module.meta =
        showInModuleNavigation: true

      moduleNavData = ModuleNav.getModuleNav app,
        id: 'Foo'

      expect(moduleNavData.icon).to.equal  ''
      expect(moduleNavData.route).to.equal '#'
      done()


    it 'should return the information of the nested modules', (done) ->

      module      = app.module 'Foo'
      module.meta =
        title: 'Foo'
        icon:  'some-icon'
        rootUrl: 'foo'
        showInModuleNavigation: true

      submodule      = app.module 'Foo.Bar'
      submodule.meta =
        title: 'Bar'
        icon:  'some-icon'
        rootUrl: 'bar'
        showInModuleNavigation: true

      moduleNavData = ModuleNav.getModuleNav app,
        id: module.moduleName
        submodules: [
          id: 'Bar'
        ]

      expect(moduleNavData).to.have.property 'sections'
      expect(moduleNavData.sections).to.be.instanceof Array
      expect(moduleNavData.sections[0]).to.be.an 'object'
      expect(moduleNavData.sections[0]).to.have.property 'label'
      expect(moduleNavData.sections[0]).to.have.property 'icon'
      expect(moduleNavData.sections[0]).to.have.property 'route'

      done()


  describe 'getApplicationModulesNavigation', ->

    appModulesFixture = require 'test/app/fixtures/other/appModules'
    ModuleLoader      = require 'lib/utilities/moduleLoader/ModuleManager'

    # not sure if this is a Unit test or a Integration test
    it 'should return the navigation info for all the registered navigable modules', (done) ->
      # register some fake modules
      app.modulesRegistry = appModulesFixture
      ModuleLoader.registerAppModules app

      navItems = ModuleNav.getApplicationModulesNavigation app

      expect(navItems).to.be.instanceof Array
      expect(navItems).to.have.length.above 0
      expect(navItems[0]).to.be.an 'object'
      expect(navItems[0]).to.have.property 'label'
      expect(navItems[0]).to.have.property 'icon'
      expect(navItems[0]).to.have.property 'route'
      done()
