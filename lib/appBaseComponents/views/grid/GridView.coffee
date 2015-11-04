# Dependencies
# -----------------------

# Libs/generic stuff:
i18n       = require 'i18next-client'
_          = require 'underscore'
Backgrid   = require 'backgrid'

# Base class
LayoutView = require '../LayoutView'

# Custom cell and row classes
ButtonCell = require './GridButtonCell'
GridRow    = require './GridRow'
MomentCell = require 'backgrid-moment-cell'




###
Grid view
===========

View used to display some collection in a grid (table) using Backgrid.
Extends LayoutView because Backgrid creates views for the grid and the
pagination. The template used on the view should deffine the regions to
attach those components (if there should be no pagination, just don't
deffine the region)

@class
@augments LayoutView

###
module.exports = class GridView extends LayoutView

  ###
  @property {Object} layout regions
  ###
  regions:
    grid:       null
    pagination: null


  ###
  @property {Array} grid columns (see Backgrid documentation)
  ###
  columns: []


  ###
  @property {String} css classes applied to the grid
  ###
  gridCssClasses: 'table'


  ###
  @property {String} css classes applied to the pagination
  ###
  paginationCssClasses: 'pagination'


  ###
  @property {Boolean} Backgrid can be rendered with an empty collection, optionally
                      with a message inside the grid (see Backgrid documentation).
                      In some circustances it should be preferable to not display
                      the grid at all.
  ###
  renderGridWithEmptyCollection: true



  ###
  Initialize method
  ###
  initialize: ->
    # When renderGridWithEmptyCollection is false, rerender the view if the
    # collection is emptied, so a custom message deffined on the templat can
    # be displayed, or something like that.
    unless @renderGridWithEmptyCollection
      @listenTo @collection, 'reset update', =>
        length = @collection.length
        if length is 0 then @render()



  ###
  Creates the grid

  The grid is a special view, a Backgrid instance.
  The method creates the view and shows it in the appropiate region.
  ###
  createGrid: ->
    gridRegion = @getRegion 'grid'

    if gridRegion
      gridOptions = _.defaults @gridOptions or {},
        collection: @collection
        columns:    @parseColumns @columns
        row:        GridRow

      grid = new Backgrid.Grid gridOptions

      gridRegion.show grid

      if @gridCssClasses
        cssClass = _.flatten([@gridCssClasses]).join(' ')
        grid.$el.addClass cssClass


  ###
  Grid columns preparsing

  Applies some defaults to the columns
  ###
  parseColumns: (columns) ->
    columns.map (col) =>
      ret = col

      # get the label if is not deffined
      unless col.label
        col.label = @collection.label col.name

      # backgrid makes the cells editable by default, which is weird,
      # so disable it unless explicetelly deffined
      unless col.editable
        col.editable = false

      ret


  ###
  Creates the grid pagination

  The pagination is a special view, a Backgrid.Extension.Paginator instance.
  The method creates the view and shows it in the appropiate region.
  ###
  createPagination: ->
    paginationRegion = @getRegion 'pagination'

    if paginationRegion
      unless @collection.state?.totalPages > 1
        paginationRegion.$el.hide()
      else
        paginator = new Backgrid.Extension.Paginator
          collection: @collection
          controls:
            rewind:
              label: '<i class="icon icon-angle-double-left"></i>'
              title: i18n.t 'pagination::First'
            back:
              label: '<i class="icon icon-angle-left"></i>'
              title: i18n.t 'pagination::Previous'
            forward:
              label: '<i class="icon icon-angle-right"></i>'
              title: i18n.t 'pagination::Next'
            fastForward:
              label: '<i class="icon icon-angle-double-right"></i>'
              title: i18n.t 'pagination::Last'
        paginationRegion.show paginator

        if @paginationCssClasses
          cssClass = _.flatten([@paginationCssClasses]).join(' ')

          # the widget is rerendered when the collection changes,
          # so is necessary to reapply the classes on refresh
          applyPaginatorClasses = -> paginator.$el.find('>ul').addClass cssClass
          @listenTo @collection, 'reset update', applyPaginatorClasses
          applyPaginatorClasses()



  ###
  Before show handler: creates the regions with the grid and the pagination
  ###
  onBeforeShow: ->
    if @collection
      if @collection.length or @renderGridWithEmptyCollection
        @createGrid()
        @createPagination()
