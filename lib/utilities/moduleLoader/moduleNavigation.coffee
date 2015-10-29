_ = require 'underscore'


###
Application nav. config builder
=================================

Generates the navigation configuration from the application modules
###
module.exports =

  ###
  Recursive function to generate the modules navigation

  @param  {Marionette.Application} app
  @param  {Marionette.Module} module   The module to get the nav. options from
  @param  {String} parentModuleId      The module parents module id
  @return {Object}                     The module navigation item config.
  ###
  getModuleNav: (app, module, parentModuleId = '') ->
    moduleNav = null

    # compose the module id
    # on nested modules it will be parentModuleId.childModuleId
    moduleId = if parentModuleId then parentModuleId + '.' + module.id else module.id

    # get the module instance
    moduleObj = app.module moduleId

    if moduleObj.meta?.showInModuleNavigation
      moduleNav =
        label:  moduleObj.meta?.title() ? ''
        icon:   moduleObj.meta?.icon    ? ''
        route:  moduleObj.meta?.rootUrl ? '#'

      if module.submodules?.length
        moduleNav.sections = module.submodules.map (module) =>
          @getModuleNav app, module, moduleId

        # remove empty nodes
        moduleNav.sections = _.compact moduleNav.sections

    moduleNav


  ###
  Application navigation initialization from the registered modules

  @param  {Marionette.Application} app
  @return {Array}  Array with the application modules that can be injected in a
                   Backbone collection in order to build the app navigation
                   Each array item contains som module attributes, like the name
                   the icon and others
  ###
  getApplicationModulesNavigation: (app) ->
    nav = []

    # build the modules nav
    if app.modulesRegistry
      nav.push @getModuleNav app, module for module in app.modulesRegistry

    # remove empty nodes
    _.compact nav
