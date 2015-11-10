_                  = require 'underscore'
Backbone           = require 'backbone'
PageableCollection = require 'backbone.paginator'
customSync         = require './util/sync'
expandsParser      = require './util/expandsParser'
channel            = require '../../utilities/appChannel'


module.exports = class Collection extends PageableCollection
  sync: customSync

  initialize: ->
    if @initialSort then @setSorting @initialSort
    super arguments


  ###
  Patch the set method because the associations lib. has a bug
  (well, not sure if this is a bug or a change in the backbone API)
  that adds an empty model when creating the collection
  ###
  set: (models, options) ->
    if _.isArray(models) and (models.length is 0)
      models = null

    super models, options



  ###
  Returns the nodes to 'expand' when calling the API

  By default the API returns the nested elements 'collapsed' (it only
  returns a `meta` node with metadata). When calling the API with the
  `include` parameter, the values will be expanded to the full objects

  @return {Array}
  ###
  getExpansions: ->
    # model relations to expand when fetching
    expandedRelations = null

    # by default, return the instance expandedRelations
    if @expandedRelations
      expandedRelations = @expandedRelations

    # if they are not deffinned, check if there're class level expandedRelations
    else if @constructor.expandedRelations
      expandedRelations = @constructor.expandedRelations

    # else check if the model has class level expandedRelations
    else
      expandedRelations = @model?.expandedRelations

    expandedRelations


  # Pagination stuff:
  # ----------------------------------------------------------------

  ###
  Extracts the `state` (pagination info) from the API responses
  ###
  parseState: (resp, queryParams, state, options) ->
    ret = {}
    paginator = resp.meta?.paginator
    total     = resp.meta?.count
    url       = resp.meta?.url

    # overwrite the url with the one received from the API
    if url
      normalizedUrl = channel.request 'cleanUrl', url
      @url = normalizedUrl or url

    if paginator
      if paginator.page          then ret.currentPage = paginator.page
      if paginator.per_page      then ret.pageSize = paginator.per_page
      if paginator.total_pages   then ret.totalPages = paginator.total_pages
      if paginator.total_entries then ret.totalRecords = paginator.total_entries
      if paginator.sort          then ret.sort = paginator.sort
    else if total
      ret.totalRecords = total
    ret


  ###
  `state` setter
  ###
  setState: (meta, options = {}) ->
    # wrap the state into a response object so the
    # original `parseState` method can be reused
    resp =
      meta: meta

    newState = @parseState(resp, _.clone(@queryParams), _.clone(@state), options)
    if newState then this.state = @_checkState(_.extend({}, @state, newState))


  ###
  Extracts the data from the API responses (the data is wrapped)
  ###
  parseRecords: (resp) ->
    if resp.data
      resp.data
    else
      # the nesed entity is not expanded
      @pending = true
      []


  ###
  Parameters used by backbone.paginator when building the querystring
  ###
  queryParams:
    # override some default backbone.paginator params
    totalPages:   null
    totalRecords: null
    order:        null
    sortKey:      null

    # add some custom params
    sort:    -> @getSorting()
    include: -> expandsParser.toUriComponent @getExpansions()


  ###
  Add a filter for the fetch operations
  ###
  addQueryFilter: (filterName, value) ->
    filters = (@queryParams.filter or '').split ','

    newFilter = filterName
    unless _.isUndefined value
      newFilter += ":#{value}"

    filters.push newFilter
    @queryParams.filter = filters.join ','


  ###
  Remove a filter
  ###
  removeQueryFilter: (filterName) ->
    filters = (@queryParams.filter or '').split ','

    if filters.length
      newFilters = _.reject filters, (filter) ->
        filter.split(:)[0] is filterName

      @queryParams.filter = newFilters.join ','



  ###
  @return {string} the sorting parameters, as a string
  ###
  getSorting: ->
    ret = undefined
    sort = @state.sort

    if sort
      ret = _.pairs(sort).map((param) ->
        param.pop() unless param[1]
        param.join('|')
      ).join(',')
    ret


  ###
  Sorting options setter (overrides the backbone.paginator method)
  @param {mixed} criterias  an object like `{keyToSort:direction}` or a string
                            like `keyToSort` or `keyToSort|direction`. Accepts
                            multiple values. If no value is provided it will
                            reset the sorting options
  ###
  setSorting: (criterias...) ->
    ret = {}

    # don't break the default behaviour
    if (arguments.length is 3) and
    (_.isString(arguments[0]) or _.isNull(arguments[0])) and
    (_.isNumber(arguments[1]) or _.isNull(arguments[1])) and
    _.isObject(arguments[2])
      super arguments
      ret[arguments[0]] = @_normalizeSortOrder arguments[1]
    else

      criterias.forEach (criteria) =>
        if _.isObject criteria
          _.pairs(criteria).forEach (k) =>
            ret[k[0]] = @_normalizeSortOrder k[1]
        else
          [k,v] = criteria.split '|'
          ret[k] = @_normalizeSortOrder v

    @state.sort = ret


  ###
  Sort direction normalization
  @param  {mixed} val  the sort direction
  @return {string}
  ###
  _normalizeSortOrder: (val) ->
    order = 'asc'
    sortOptions =
      'asc': 'asc'
      'desc': 'desc'
      '1': 'asc'
      '-1': 'desc'

    if val
      val = if isNaN(val) then val.toLowerCase() else val+''
      order = sortOptions[val] or order
    order


  ###
  Label getter for model attributes
  @param  {String} attribute
  @return {String}           a custom label for that attribute
  ###
  label: (attribute) ->
    unless @model
      return attribute
    else
      return @model.label attribute


  ###
  Creates a a new collection with an identical list of models, and state

  It's similar to the backbone clone method, but cloning also some other attributes
  @param {Boolean} fresh If true, the models will be a copy of the original
                        collection ones, instead of references to them

  @return {Collection}
  ###
  deepClone: (fresh) ->
    data = if fresh then @toJSON() else @models

    options =
      model:      @model
      comparator: @comparator

    clone = new @constructor data, options

    clone.setState @state

    if @url
      clone.url = @url

    clone



  ###
  Returns a reference to the last xhr object created during sync
  ###
  getDeferred: -> @_xhr
