channel = require 'lib/utilities/appChannel'

###
Ultra simple global factory using a backbone.radio channel, used to instantiate
deppendencies without referencing them directly to avoid circular dependencies
###
module.exports =

  ###
  Register some factory
  @param {String}   path     used to compose the request, will be prefixed with 'factory:'
  @param {Function} callback the factory method
  ###
  register: (path, callback) ->
    channel.reply "factory:#{path}", (args...) -> callback args...

  ###
  Invoke the factory
  ###
  invoke: (path, args...) ->
    reqParts = path.split '|'
    path     = 'factory:' + reqParts.shift()
    entity   = reqParts.join '|'
    channel.request path, entity, args...
