DropzoneComponent = require './DropzoneComponent'

module.exports = (Module, App, Backbone, Marionette, $, _) ->

  App.channel.reply 'uploader:component', (elem, options = {}, data = []) ->
    throw new Error 'Uploader Component requires an element to be passed in' if not elem

    new DropzoneComponent elem, options, data