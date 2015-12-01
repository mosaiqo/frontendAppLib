# Dependencies
# -----------------------
Backgrid = require 'backgrid'


###
Grid html cell
=================

@class
@augments Backgrid.Cell

###
module.exports = Backgrid.HtmlCell = Backgrid.Cell.extend

  ###
  @property {String} css class applied to the table cell
  ###
  className: 'html-cell'


  ###
  Render method
  ###
  render: ->
    content = @formatter.fromRaw(@model.get(@column.get("name")), @.model)
    @$el.empty().html content
    @