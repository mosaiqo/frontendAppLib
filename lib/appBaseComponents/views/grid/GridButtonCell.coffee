# Dependencies
# -----------------------
Backgrid = require 'backgrid'


###
Grid button cell
=================

@class
@augments Backgrid.Cell

###
module.exports = Backgrid.ButtonCell = Backgrid.Cell.extend

  ###
  @property {String} css class applied to the table cell
  ###
  className: 'button-cell'


  ###
  @property {Boolean} disable sorting on the column
  ###
  sortable: false


  ###
  @property {Object} handlers config. for UI elements
  ###
  events:
    'click .btn': 'handleClick'


  ###
  Render method
  ###
  render: ->
    # use btnLabel as the button text or the column label/model attr if not deffined
    btnLabel = @column.get('btnLabel')

    unless btnLabel
      # this cell can be associated to a model attribute or not
      columnName = @column.get 'name'

      if columnName
        btnLabel = @formatter.fromRaw(@model.get(columnName), @model)
      else
        btnLabel = @column.get 'label'

    # css classes applied to the button
    btnClass = @column.get 'buttonClass' or ''

    # handler
    content = "<button type=\"button\" class=\"#{btnClass}\">#{btnLabel}</button>"
    @$el.empty().html content
    @delegateEvents()
    this


  ###
  Handler executed when the button is clicked

  It just fires an event with the name deffined on the column configuration with
  an object as an argument with the properties 'view', 'model' and 'collection'
  (consistent with the Marionette triggers)
  ###
  handleClick: ->
    ev = @column.get 'clickEvent'
    if ev
      @$el.trigger ev,
        view:       @
        model:      @model
        collection: null
