$          = require 'jquery'
_          = require 'underscore'
Marionette = require 'backbone.marionette'
require './helpers/mixinTemplateHelpers'
require './helpers/handlebarsHelpers'
require 'lib/jquery/toggleWrapper'


# backup the original method
_remove = Marionette.View::remove


module.exports =

  ###
  Adds a 'blocker' to the view displayed while its entities are synced
  ###
  addOpacityWrapper: (init = true, options = {}) ->
    _.defaults options,
      className: 'opacity'

    @$el.toggleWrapper options, @cid, init


  ###
  View remove

  Overrides the original method, adding a fadeout to the view
  (colored if the view entity has been destroyed)
  ###
  remove: (args...) ->
    # console.log "removing", @
    fadeOutTime = 300

    if @model?.isDestroyed?()

      wrapper = @addOpacityWrapper true,
        backgroundColor: 'red'

      wrapper.fadeOut fadeOutTime, ->
        $(@).remove()

      @$el.fadeOut fadeOutTime, =>
        _remove.apply @, args
    else
      _remove.apply @, args


  ###
  Global template helpers
  ###
  templateHelpers: require './helpers/templateHelpers'
