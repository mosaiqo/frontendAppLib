$              = require 'jquery'
_              = require 'underscore'
_s             = require 'underscore.string'
Backbone       = require 'backbone'
Computedfields = require 'backbone-computedfields'
Associations   = require 'backbone-associations'
Validator      = require 'backbone-validation'
customSync     = require './util/sync'


module.exports = class Model extends Backbone.AssociatedModel
  _.extend @::, Validator.mixin
  _.extend @::, require './util/timestamps'
  _.extend @::, require './util/computed'
  _.extend @::, require './util/expands'
  _.extend @::, require './util/relations'


  ###
  @property {String} default id attribute
  ###
  idAttribute: 'id'


  constructor: (attributes = {}, options = {}) ->
    # parse by default
    if _.isUndefined options.parse
      options.parse = true

    # initialize the mixins:
    # each one can register some ev. handlers, or whatever
    @setupTimestamps attributes, options
    @setupComputed   attributes, options
    @setupExpands    attributes, options
    @setupRelations  attributes, options

    super attributes, options


  initialize: (attributes = {}, options = {}) ->
    # init Backbone.ComputedFields
    @computedFields = new Backbone.ComputedFields @

    if @relations
      @relations.forEach (relation) =>
        if relation.type is Backbone.Many
          entity = @get relation.key
          @listenTo entity, 'update', =>
            @changed[relation.key] = entity


    # let the mixins do their work
    @trigger 'initialize', attributes, options


  ###
  Parses the server response when it returns data (fetch/save)
  ###
  parse: (response, options) ->
    # unwrap the API response
    response = response.data || response

    # apply any registered transform to the data
    @trigger 'parse', response, options

    response


  ###
  Custom sync
  ###
  sync: (method, entity, options = {}) =>
    # apply any registered transform to the options
    @trigger 'beforeSync', method, entity, options

    # trigger the original sync
    customSync(method, entity, options)



  destroy: (options = {}) ->
    _.defaults options,
      wait: true

    @set '_destroy': true
    super options



  isDestroyed: ->
    @get '_destroy'


  patch: (data, options = {}) ->
    options.patch = true

    # weird empty key...
    data = _.omit data, ''


    # Backbone associations performs 'smart' sets on nested entities
    # so the regural set does not clear them with empty or null values
    nestedEntityChanges = {}

    if @relations
      @relations.forEach (relation) =>
        attr = relation.key

        unless _.isUndefined data[attr]
          if relation.type is Backbone.Many
            if _.isArray(data[attr]) and _.isEmpty(data[attr])
              @unset attr
              nestedEntityChanges[attr] = data[attr]
              delete data[attr]

          else
            if data[attr] is null
              @unset attr
              nestedEntityChanges[attr] = data[attr]
              delete data[attr]


    # update the attributes
    # calling set instead of save(data) in order to run any custom setter
    @set data

    # the previous set resets the @changed hash, so restore any changes
    # performed on the relations
    _.extend @changed, nestedEntityChanges

    if @isNew()
      @save null, options
    else
      # retrieve the changes
      changed = @changedAttributes()

      # omit the transient attrs
      if changed
        if @computed
          virtuals = _.omit @computed, 'transient'
          changed  = _.omit(changed, _.keys virtuals)

          # if there are no left attrs., set the obj to false
          # so it behaves as @changedAttributes()
          unless _.keys(changed).length then changed = false

      if changed
        @save changed, options
      else
        # if nothing changed, don't send a request to the server
        # and just execute the registered callback, if any
        if options.callback
          options.callback()



  save: (data, options = {}) ->
    data  = data or null
    isNew = @isNew()

    _.defaults options,
      wait: true
      success:  _.bind(@saveSuccess, @, isNew, options.collection, options.callback)
      error:    _.bind(@saveError, @)

    # apply any registered transform to the data
    @trigger 'beforeSave', data, options

    # clear previous errors
    @unset '_errors'

    super data, options



  saveSuccess: (isNew, collection, callback) =>
    if isNew ## model is being created
      collection?.add @
      collection?.trigger 'model:created', @
      @trigger 'created', @
    else ## model is being updated
      collection ?= @collection ## if model has collection property defined, use that if no collection option exists
      collection?.trigger 'model:updated', @
      @trigger 'updated', @

    callback?()


  saveError: (model, xhr, options) =>
    @trigger 'sync:stop'

    ## set errors directly on the model
    try
      response = $.parseJSON xhr.responseText
    catch error
      response = {}

    if response.errors
      @set _errors: response.errors



  ###
  Custom validation error dispatcher
  @param {Object} err
  ###
  dispatchCustomValidationError: (err) ->
    # the error values should be arrays
    error = _.mapObject err, (val, key) ->
      if _.isArray(val) then val else [val]

    @trigger 'validation:customError', error



  ###
  Label getter
  @param  {String} attribute
  @return {String}           a custom label for that attribute
  ###
  @label: (attribute) ->
    if @labels and @labels[attribute]
      if _.isFunction @labels[attribute]
        return @labels[attribute]()
      else
        return @labels[attribute]
    else
      return _s.humanize attribute


  ###
  Returns a reference to the last xhr object created during sync
  ###
  getDeferred: -> @_xhr


  ###
  Querystring params
  ###
  queryParams: {}  


  ###
  Add support for querystring parameters on fetch
  ###
  fetch: (options = {}) ->
    unless _.isEmpty @queryParams
      options.data = @queryParams
    super options


  ###
  Add a filter for the fetch operations
  ###
  addQueryFilter: (filterName, value) ->
    currentFilters = @queryParams.filter
    filters = if currentFilters then currentFilters.split(',') else []

    newFilter = filterName
    unless _.isUndefined value
      newFilter += ":#{value}"

    filters.push newFilter
    @queryParams.filter = filters.join ','


  ###
  Remove a filter
  ###
  removeQueryFilter: (filterName) ->
    currentFilters = @queryParams.filter
    filters = if currentFilters then currentFilters.split(',') else []

    if filters.length
      newFilters = _.reject filters, (filter) ->
        filter.split(':')[0] is filterName

      @queryParams.filter = newFilters.join ','
