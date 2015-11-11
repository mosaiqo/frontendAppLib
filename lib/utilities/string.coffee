_ = require 'underscore'


module.exports =
  ###
  Custom search query scaping, to avoid conflicts with other params
  ###

  _escapeMap: do() ->
    (':;.,()[]'.split('').reduce (memo, k) ->
      memo[k+''] = '\\' + k.charCodeAt()
      memo
    , {})


  _escape: (str, mapObj) ->
    strRe = _.keys(mapObj).map((k) ->
      '\\' + k
    ).join('|')

    re = new RegExp(strRe,'gi')

    str.replace re, (match) => mapObj[match.toLowerCase()]


  escapeQueryParam: (str) ->
    @_escape str, @_escapeMap


  unescapeQueryParam: (str) ->
    @_escape str, _.invert(@_escapeMap)