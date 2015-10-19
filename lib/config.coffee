_ = require 'underscore'

# Module shared defaults
# -----------------------
#
# To override anything, import this file before anything else
# and call the "extend" method with the values to override
config =
  appChannel: 'appChannel'
  locales: {}

module.exports =
  get: -> config
  extend: (overrides...) ->
    config = _.extend {}, overrides...
