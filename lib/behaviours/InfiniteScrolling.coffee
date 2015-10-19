Marionette = require 'backbone.marionette'

###
Infinite scrolling behaviour
==============================

Infinite scrolling behaviour for CompositeViews or CollectionViews
with a paginated collection (a collection extending PageableCollection)
###
module.exports = class InfiniteScrollingBehaviour extends Marionette.Behavior

  ###
  @property {Boolean} Collection loading status
  ###
  loading: false


  collectionEvents:
    'sync:start' :  'syncStart'
    'sync:stop'  :  'syncStop'


  ui:
    itemsList:           '.items'
    scrollableContainer: '.itemsContainer'


  # Ev, handler executed when the collection starts syncing with the server
  syncStart: ->
    @loading = true
    @ui.scrollableContainer.addClass 'loading'


  # Ev, handler executed when the collection finishes syncing with the server
  syncStop: ->
    @loading = false
    @ui.scrollableContainer.removeClass 'loading'


  # Init it when the view DOM is ready
  onRender: ->

    # the ui events hash uses $.delegate, but the scroll event does not bubble
    # so
    #
    # ```
    #   events:
    #     'scroll @ui.scrollableContainer': 'scrollHandler'
    # ```
    #
    # will not work
    #
    @ui.scrollableContainer.on 'scrollstop', @scrollHandler


  # Unbind everything
  onBeforeDestroy: ->
    @ui.scrollableContainer.off()


  # Infinite scrolling handler
  scrollHandler: () =>
    if @loading
      return

    offset             = 100
    containerScrollTop = @ui.scrollableContainer.scrollTop()
    containerHeight    = @ui.scrollableContainer.height()
    listHeight         = @ui.itemsList.height()

    if containerScrollTop + containerHeight > listHeight - offset
      if @view.collection.hasNextPage()
        @view.collection.getNextPage
          remove: false

