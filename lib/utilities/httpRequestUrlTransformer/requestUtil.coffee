###
HTTP request utilities
=======================
###
module.exports =

  ###
  Base URL setter

  Used to override the API network calls
  (for example to call to another domain or to add a base to the URLs)

  @param {String} url                    The original url
  @param {String|RegExp} replaceFragment Url fragment to be replaced with the new base
  @param {String} rootURL                The new base
  @return {String}                       The new URL with the applied base
  ###
  setUrlRoot : (url, replaceFragment, rootURL) ->
    url.replace replaceFragment, rootURL
