_ = require 'underscore'

module.exports =

  toUriComponent: (expands) ->
    if _.isArray expands
      return expands.map (expand) =>
        if _.isString expand then expand else @parseExpandOptions expand


  parseExpandOptions: (expand = {}) ->
    ret = ''
    if expand.attribute
      ret += expand.attribute

      if expand.page  then ret += ":page(#{expand.page})"
      if expand.limit then ret += ":per_page(#{expand.limit})"
      if expand.order
        order = @parseSortOptions expand.order
        ret += ":order(#{order})"
    ret


  parseSortOptions: (sort) ->
    ret = ''
    if _.isString sort
      ret = sort
    else
      ret = _.pairs(sort).map((kvPair) -> kvPair.join '|').join ','
    ret
