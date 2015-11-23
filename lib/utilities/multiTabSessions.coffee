_ = require 'underscore'

###
Multiple tabs session storage sync

@see http://blog.guya.net/2015/06/12/sharing-sessionstorage-between-tabs-for-secure-multi-tab-authentication/
###

# transfers sessionStorage from one tab to another
sessionStorage_transfer = (callback, event) ->
  if !event
    event = window.event
  # ie suq
  if !event.newValue
    return

  # do nothing if no value to work with
  if event.key == 'getSessionStorage'
    # another tab asked for the sessionStorage -> send it
    localStorage.setItem 'sessionStorage', JSON.stringify(sessionStorage)
    # the other tab should now have it, so we're done with it.
    localStorage.removeItem 'sessionStorage'
    # <- could do short timeout as well.
  else if event.key == 'sessionStorage' and !sessionStorage.length
    # another tab sent data <- get it
    data = JSON.parse(event.newValue)
    for key of data
      sessionStorage.setItem key, data[key]
      console.log '----callback----'
    callback()
  return


module.exports =
  initialize: (callback = _.noop) ->
    sessionTransfer = _.partial sessionStorage_transfer, callback

    if !sessionStorage.length
      console.info '!sessionStorage.length'

      # Ask other tabs for session storage
      localStorage.setItem 'getSessionStorage', Date.now()

      # If there's no session available on other tabs/windows
      # execute the callback after a short delay
      setTimeout callback, 100
    else
      console.info 'sessionStorage.length'
      callback()

    # listen for changes to localStorage
    if window.addEventListener
      window.addEventListener 'storage', sessionTransfer, false
    else
      window.attachEvent 'onstorage', sessionTransfer
