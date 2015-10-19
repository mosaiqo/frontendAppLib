Marionette = require 'backbone.marionette'


###
Collapsible module navigation behaviour
========================================
###
module.exports = class CollapsibleModuleItems extends Marionette.Behavior

  ###
  @property {Object} Default options
  ###
  defaults:
    ###
    @property {String} The menu block (that will be toggled)
    ###
    navBlock:   '#moduleItems'

    ###
    @property {String} The element that when clicked will toggle the menu
    ###
    navToggler: '#moduleItemsToggler'

    ###
    @property {Boolean} Auto toggle the menu when the content region
                        is rendered or emptied
    ###
    autoToggle: false

    ###
    @property {String} The content region. This is only required
                       if `autoToggle` is enabled
    ###
    contentRegion: ''

    ###
    @property {Number} Auto toggling can be restricted to happen only if
                       the viewport width is less or equal some given width
    ###
    autoToggleOnlyIfWidthLessThan: null


  ###
  @property {Object} DOM elements
  ###
  ui: ->
    navBlock :  @options.navBlock
    navToggler: @options.navToggler


  ###
  @property {Object} handlers config. for UI elements
  ###
  events:
    'click @ui.navToggler' : 'toggleNav'


  ###
  Toggle the navigation block

  @param {Object} e    click event
  @param {Boolean} val
  ###
  toggleNav: (e, val) ->
    if e
      e.preventDefault()
    @ui.navBlock.toggleClass 'collapsed', val


  ###
  onRender handler
  ###
  onRender: ->
    # Setup the auto toggling
    if @options.autoToggle and @options.contentRegion
      region = @view.getRegion @options.contentRegion

      if @options.autoToggleOnlyIfWidthLessThan
        @setupAutoResponsiveToggling region
      else
        @setupAutoToggling region


  ###
  Auto toggle thw navigation when the content region is rendered or emptied

  @param {Marionette.Region} contentRegion
  ###
  setupAutoToggling: (contentRegion) ->
    @listenTo contentRegion, 'before:show', (view)  => @toggleNav null, true
    @listenTo contentRegion, 'before:empty', (view) => @toggleNav null, false


  ###
  Responsive version of setupAutoToggling

  Does exactly the same than the previous method,
  but only if the viewport width is less or equal some given width

  @param {Marionette.Region} contentRegion
  ###
  setupAutoResponsiveToggling: (contentRegion) ->
    viewport = $(window)

    @listenTo contentRegion, 'before:show', (view) =>
      if viewport.width() <= @options.autoToggleOnlyIfWidthLessThan
        @toggleNav null, true

    @listenTo contentRegion, 'before:empty', (view) =>
      if viewport.width() <= @options.autoToggleOnlyIfWidthLessThan
        @toggleNav null, false
