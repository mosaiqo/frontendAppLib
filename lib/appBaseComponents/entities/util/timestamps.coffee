_ = require 'underscore'


module.exports =

  ###
  @property {Array} timestamps:
                    js represents timestamps in miliseconds but the API
                    represents that in seconds. This fields will be
                    automatically converted when fetching/saving.
  ###
  timestampFields: ['created_at', 'updated_at']


  parseTimestampFields: (response, options) ->
    for field in @timestampFields
      if response[field]
        if String(response[field]).length is 10
          response[field] *=1000


  restoreTimestampFields: (data = {}, options) ->
    _data = _.extend({}, @attributes, data)

    for field in @timestampFields
      if data[field]
        # convert it back to a unix timestamp (seconds)
        if String(data[field]).length is 13
          data[field] = parseInt((new Date _data[field])/1000, 10)



  setupTimestamps: ->
    @listenTo @, 'parse',      @parseTimestampFields
    @listenTo @, 'beforeSave', @restoreTimestampFields
