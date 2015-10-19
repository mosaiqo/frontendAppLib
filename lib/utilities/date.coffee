_      = require 'underscore'
moment = require 'moment'


###
Date/time utils
=================
###
module.exports =

  ###
  Timestamp splitter

  @param  {Number} date  A timestamp
  @return {Object}       An object with a 'date' and time 'attributes'
                         for example:
                         {date: "2015-05-23", time: "18:17:56"}
  ###
  splitDateTime: (date) ->
    splitedDateTime =
      date: null
      time: null

    formattedDate = moment date

    if formattedDate.isValid()
      splitedDateTime.date = formattedDate.format 'YYYY-MM-DD'
      splitedDateTime.time = formattedDate.format 'HH:mm:ss'

    splitedDateTime


  ###
  Date/time to timestamp converter

  @param  {Object} dateObj  An object with a 'date' and time 'attributes'
  @return {Number}          A timestamp
  ###
  mergeDateTime: (dateObj) ->
    retDate = null

    if _.isObject(dateObj) and dateObj.date
      localDate = dateObj.date

      if dateObj.time
        localDate += ' ' + dateObj.time

      retDate = moment(localDate).valueOf()

    retDate
