Marionette = require 'backbone.marionette'


###
Editor behaviour
=================

Behaviour for views with elements that should be transformed
into text editors. The text editing/formating stuff is not
implemented in the app, instead, an external library (like
Redactor, for example) should be used. This behaviour just
triggers 'global' DOM events so a listener deffined somewhere
can transform the textareas or whatever into something more
advanced.
###
module.exports = class EditorBehaviour extends Marionette.Behavior

  ###
  @property {Object} Default options
  ###
  defaults:
    editors : 'textarea.editor'


  ###
  @property {Object} DOM elements to transform
  ###
  ui: ->
    'editors' : @options.editors


  ###
  Trigger DOM events on the root Dom node (`document`)

  Useful to listen to app events from outside the app

  @param {String} eventName Event name to trigger
  @param {Object} args      Event arguments
  ###
  triggerGlobalDOMEvent: (eventName, args...) ->
    $(document).trigger eventName, args


  ###
  onRender handler

  Trigger a custom event when the view is rendered
  so the editors can be initialized
  ###
  onRender: () ->
    @triggerGlobalDOMEvent 'MOSAIQO.editor.rendered', @ui.editors


  ###
  onBeforeDestroy handler

  Trigger a custom event before destroying the view
  so the editors can be destroyed or something
  ###
  onBeforeDestroy: () ->
    @triggerGlobalDOMEvent 'MOSAIQO.editor.beforeDestroy', @ui.editors
