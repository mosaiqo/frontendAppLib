_        = require 'underscore'
Backgrid = require 'backgrid'

###
Helper function, returns some localized attribute
###
module.exports = (attr, transform = null) ->
  _.extend {}, Backgrid.CellFormatter.prototype,
    fromRaw: (rawValue, model) ->
      ret    = null
      locale = model.get 'defaultLocale'

      if locale
        ret = locale[attr]

      if transform
        ret = transform ret

      ret
