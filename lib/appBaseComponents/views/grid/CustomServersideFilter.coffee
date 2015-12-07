Backbone = require 'backbone'
Backgrid = require 'backgrid'
Filter   = require 'backgrid-filter'


CustomServerSideFilter = Backgrid.Extension.ServerSideFilter.extend

  showClearButtonMaybe: () ->
    $clearButton = @clearButton()
    hasFilter    = @collection.hasQueryFilter @name
    searchTerms  = this.searchBox().val()

    if hasFilter or searchTerms
      $clearButton.show()
    else
      $clearButton.hide()


  search: (e) ->
    if (e) then e.preventDefault()

    query      = @query()
    collection = @collection

    collection.removeQueryFilter @name

    if query then collection.addQueryFilter @name, query

    # go back to the first page on search
    if collection instanceof Backbone.PageableCollection
      collection.getFirstPage {reset: true, fetch: true}
    else
      collection.fetch {reset: true}


  clear: (e) ->
    if (e) then e.preventDefault()

    collection = @collection
    hasFilter  = collection.hasQueryFilter @name

    @clearSearchBox()

    if hasFilter
      collection.removeQueryFilter @name

      # go back to the first page on clear
      if collection instanceof Backbone.PageableCollection
        collection.getFirstPage {reset: true, fetch: true}
      else
        collection.fetch {reset: true}


module.exports = CustomServerSideFilter