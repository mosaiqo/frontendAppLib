$          = require 'jquery'
Handlebars = require 'handlebars/runtime'

###
Handlebars helpers
====================
###

# Swag helpers library
Swag = require 'swag'

Swag.registerHelpers Handlebars


# Strip HTML helper
Handlebars.registerHelper 'stripHTML', (htmlStr) ->
  $('<p>' + htmlStr + '</p>').text()


# Chainable helpers
Handlebars.registerHelper 'chain', ->
  helpers = []
  args = Array::slice.call(arguments)
  argsLength = args.length
  index = undefined
  arg = undefined
  index = 0
  arg = args[index]

  while index < argsLength
    if Handlebars.helpers[arg]
      helpers.push Handlebars.helpers[arg]
    else
      args = args.slice(index)
      break
    arg = args[++index]
  args = [ helpers.pop().apply(Handlebars.helpers, args) ]  while helpers.length
  args.shift()


# i18n helper
i18n = require 'i18next-client'

Handlebars.registerHelper "t", (i18n_key) ->
  result = i18n.t(i18n_key)
  new Handlebars.SafeString(result)



module.exports = Handlebars
