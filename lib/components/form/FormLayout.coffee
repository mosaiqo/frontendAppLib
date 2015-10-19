_          = require 'underscore'
$          = require 'jquery'
LayoutView = require '../../appBaseComponents/views/LayoutView'
Validator  = require 'backbone-validation'


module.exports = class FormLayout extends LayoutView
  template: require './templates/form.hbs'

  tagName: 'form'
  attributes: ->
    'data-type': @getFormDataType()
    'class':     @getFormCssClass()


  regions:
    formContentRegion: '#form-content-region'


  ui:
    buttonContainer: '.form-actions>div'


  triggers:
    'submit'                             : 'form:submit'
    'click [data-form-button="cancel"]'  : 'form:cancel'


  events:
    'click [data-form-button]' : 'formActionButtonClicked'


  formActionButtonClicked: (e) =>
    formButtonType = $(e.currentTarget).data 'formButton'

    if formButtonType isnt 'submit' and
    formButtonType isnt 'cancel' and
    formButtonType isnt 'primary'
      @trigger 'form:otherAction', formButtonType


  modelEvents:
    'change:_errors'   : 'changeErrors'
    'sync:start'       : 'syncStart'
    'sync:stop'        : 'syncStop'


  initialize: ->
    { @config, @buttons } = @options


  serializeData: ->
    ret =
      footer: @config.footer

    if @buttons
      ret.buttons =
        primaryActions:   @buttons.primaryActions?.toJSON() ? false
        secondaryActions: @buttons.secondaryActions?.toJSON() ? false
    ret


  onShow: ->
    _.defer =>
      @focusFirstInput() if @config.focusFirstInput

    Validator.bind @,
      valid: (view, attr, selector) =>
        @removeError "[name='" + attr + "']"

      invalid: (view, attr, error, selector) =>
        @addError attr, error

    # listener for custom errors
    # TODO: find a way to trigger proper validation errors
    @listenTo @model, 'validation:customError', (errors) ->
      @addErrors errors


  focusFirstInput: ->
    @$(':text:visible:enabled:first').focus()


  getFormDataType: ->
    if @model.isNew() then 'new' else 'edit'


  getFormCssClass: ->
    @options.config?.formCssClass


  changeErrors: (model, errors, options) ->
    if @config.errors
      if _.isEmpty(errors) then @removeErrors() else @addErrors errors


  removeErrors: ->
    @removeError '.has-error'


  removeError: (selector) ->
    @$(selector).each (i, el) =>
      el    = @$(el)
      group = el.closest(".form-group")
      helpBlockSelector = ".help-block"

      if group.length
        group.removeClass "has-error"
      else
        group = el
        helpBlockSelector = ">" + helpBlockSelector

      group.find(helpBlockSelector).html("").addClass "hidden"


  addErrors: (errors = {}) ->
    for name, array of errors
      @addError name, array[0]


  addError: (name, error) ->
    el = @$("[name='" + name + "']")
    group = el.closest(".form-group")
    helpBlockSelector = ".help-block"

    if group.length
      group.addClass "has-error"
    else
      group = el
      helpBlockSelector = ">" + helpBlockSelector

    group.find(helpBlockSelector).html(error).removeClass "hidden"


  syncStart: (model) ->
    @addOpacityWrapper() if @config.syncing


  syncStop: (model) ->
    @addOpacityWrapper(false) if @config.syncing


  onDestroy: ->
    @addOpacityWrapper(false) if @config.syncing
