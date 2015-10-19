_             = require 'underscore'
expandsParser = require './expandsParser'

module.exports =

  # model relations to expand when calling the server
  # by default the class level expandedRelations,
  # but can be overrided at the instance level
  addExpandsToRequestUrl: (method, entity, options) ->
    expandedRelations = @expandedRelations or @constructor.expandedRelations

    if expandedRelations
      parsed = expandsParser.toUriComponent expandedRelations
      expand = $.param 'include': parsed

      # add the expand options to the url
      url       = options.url or _.result(@, 'url')
      separator = if /\?/.test(url) then '&' else '?'
      options.url = [url, expand].join separator


  setupExpands: ->
    @listenTo @, 'beforeSync', @addExpandsToRequestUrl
