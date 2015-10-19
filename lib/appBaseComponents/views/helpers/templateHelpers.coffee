###
Global template helpers
###
module.exports =

  ###
  @return {Boolean} returns whether the view model exists on the server
  ###
  _isNew: () ->
    if @model then @model.isNew() else true
