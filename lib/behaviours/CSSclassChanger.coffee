Marionette = require 'backbone.marionette'


###
CSS class changer
==================

Changes some element CSS class based on a radiobutton group value
###
module.exports = class CSSclassChangeBehaviour extends Marionette.Behavior

  ###
  @property {Object} Default options
  ###
  defaults:
    input:      ''
    target:     ''
    cssClasses: {}


  ###
  @property {Object} DOM elements
  ###
  ui: ->
    'input'  : @options.input
    'target' : @options.target


  ###
  @property {Object} handlers config. for UI elements
  ###
  events:
    'change @ui.input' : 'changeClassHandler'


  changeClassHandler: (e) =>
    @updateTargetClasses e.currentTarget.value


  ###
  onRender handler

  @todo the timeout is required oon some views where the input values are
        assigned on render (for example on forms using Backbone.Syphon)
        i think this is not really elegant, it should be better to
        listen to some event or something
  ###
  onRender: =>
    setTimeout (=>
      if @ui.input.is # sometimes an error is thrown, saying .is is not a function (WTF)
        window.input = @ui.input
        if @ui.input.is(':radio')
          val = @ui.input.filter(':checked').val()
        else
          val = @ui.input.val()

        @updateTargetClasses val

    ), 100


  ###
  Update the target element css classes

  @param {String} val  cssClasses object key for the classes to apply
  ###
  updateTargetClasses : (val) =>
    newCssClass = @options.cssClasses[val]
    @ui.target.attr 'class', newCssClass
