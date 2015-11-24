_              = require 'underscore'
_s             = require 'underscore.string'
Backbone       = require 'backbone'
ViewController = require '../../appBaseComponents/controllers/ViewController'
FormLayout     = require './FormLayout'


module.exports = class FormController extends ViewController

  defaults: ->
    footer: true
    focusFirstInput: true
    errors: true
    syncing: true
    proxy: false
    onFormSubmit: ->
    onFormCancel: ->
    onFormSuccess: ->

  initialize: (options = {}) ->
    { @contentView } = options

    @model      = @getModel options
    @collection = @getCollection options

    config = @getConfig options

    @formLayout = @getFormLayout config
    @setMainView @formLayout

    @parseProxys config.proxy if config.proxy
    @createListeners config

  createListeners: (config) ->
    @listenTo @formLayout, 'show', @formContentRegion
    @listenTo @formLayout, 'form:submit', => @formSubmit(config)
    @listenTo @formLayout, 'form:cancel', => @formCancel(config)
    @listenTo @formLayout, 'form:otherAction', (action) => @formOtherAction(config, action)

  getConfig: (options) ->
    form = _.result @contentView, 'form'

    config = @mergeDefaultsInto(form)

    _.extend config, _(options).omit('contentView', 'model', 'collection')

  getModel: (options) ->
    ## pull model off of contentView by default
    ## allow options.model to override
    ## or instantiate a new model if nothing is present
    model = options.model or @contentView.model
    if options.model is false
      model = new Backbone.Model()
      @_saveModel = false
    model

  getCollection: (options) ->
    options.collection or @contentView.collection

  parseProxys: (proxys) ->
    for proxy in _([proxys]).flatten()
      @formLayout[proxy] = _.result @contentView, proxy

  formCancel: (config) ->
    config.onFormCancel()
    @trigger 'form:cancel'


  serializeForm: ->
    # don't parse disabled fields
    Backbone.Syphon.ignoredTypes.push('[disabled]')

    ## pull data off of form
    data = Backbone.Syphon.serialize @formLayout

    # Merge the serialized values with any defaults deffined on the view.
    # This defaults can be used to deffine additional propperties not present
    # on the view, or to force a default value if the correspondent field
    # is empty, removed, can't be parsed or whatever
    viewDefaults = @contentView.serializationDefaults or {}
    _.defaults data, viewDefaults


  formSubmit: (config) ->
    data = @serializeForm()

    ## notify our controller instance in case things are listening to it
    @trigger('form:submit', data)

    setTimeout(=>
      @processModelSave(data, config) unless @_shouldNotProcessModelSave(config, data)
    ,200)

  formOtherAction: (config, action) ->
    action = config['onForm' + _s.capitalize action]

    if action and _.isFunction action
      action()

  _shouldNotProcessModelSave: (config, data) ->
    @_saveModel is false or config.onFormSubmit is false or config.onFormSubmit?(data) is false

  processModelSave: (data, config) ->
    @model.patch data,
      collection: @collection
      callback: config.onFormSuccess

  formContentRegion: ->
    @show @contentView, region: @formLayout.formContentRegion

    # use serializeData() instead of model.toJSON() because serializeData
    # lets apply transforms needed for some input types (like transforming
    # timestamps to dates, etc)
    # Anyway, you should probably use mutator on the model (or maybe not)
    Backbone.Syphon.deserialize @formLayout, @contentView.serializeData()

  getFormLayout: (config) ->
    new FormLayout
      config: config
      model: @model
      buttons:
        primaryActions:   @getButtons config.buttons.primaryActions
        secondaryActions: @getButtons config.buttons.secondaryActions

  getButtons: (buttons = {}) ->
    @appChannel.request('form:button:entities', buttons, @contentView.model) unless buttons is false
