###
Multiple tabs session storage sync

@see http://blog.guya.net/2015/06/12/sharing-sessionstorage-between-tabs-for-secure-multi-tab-authentication/
###

module.exports = (Module, App, Backbone, Marionette, $, _) ->

  # transfers sessionStorage from one tab to another
  sessionStorage_transfer = (event) ->
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
    return

  App.channel.reply 'session:enableMultiTabSupport', ->
    # listen for changes to localStorage
    if window.addEventListener
      window.addEventListener 'storage', sessionStorage_transfer, false
    else
      window.attachEvent 'onstorage', sessionStorage_transfer