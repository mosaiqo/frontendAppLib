stopableModules = []

###
Module Manager
===============

Utility to register application modules and start/stop them
###
module.exports =

  ###
  Start all the stoppable application modules (modules that don't start automatically)
  ###
  startApplicationModules: ->
    module.start() for module in stopableModules


  ###
  Stop all the stoppable application modules
  ###
  stopApplicationModules: ->
    module.stop() for module in stopableModules


  ###
  Recursive function to setup the nested modules

  @param  {Marionette.Application} app
  @param  {Marionnnette.Module} module   The module to register
  @param  {String} parentModuleId        The parent module id
  ###
  registerAppModule: (app, module, parentModuleId = '') ->

    # compose the module id
    # on nested modules it will be parentModuleId.childModuleId
    moduleId = if parentModuleId then parentModuleId + '.' + module.id else module.id

    # register the module
    app.module(moduleId, module.class or {})

    # some modules are not autostarted
    # keep track of them
    stopableModules.push app.module(moduleId) if app.module(moduleId).meta?.stopable


    # if the module has submodules, init them (this is recursive)
    if module.submodules?.length
      @registerAppModule app, submodule, moduleId for submodule in module.submodules


  ###
  Application submodules management

  Right now loading and starting them all, but this can be changed if the
  modules are loaded conditionally according to the user privileges, or
  something like that

  @param {Marionette.Application} app
  ###
  registerAppModules: (app) ->
    if app.modulesRegistry
      @registerAppModule app, module for module in app.modulesRegistry
