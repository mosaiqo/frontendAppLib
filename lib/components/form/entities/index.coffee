_                 = require 'underscore'
ButtonsCollection = require './ButtonsCollection'
i18n              = require 'i18next-client'


module.exports = (Module, App, Backbone, Marionette, $, _) ->

  API =
    getDefaultButton: (buttonConfig, model) ->
      _.defaults buttonConfig,
        type:       'primary'
        className:  'btn btn-primary'
        buttonType: 'submit'
        text:       if model.isNew() then i18n.t('Create') else i18n.t('Update')


    getCancelButton: (buttonConfig) ->
      _.defaults buttonConfig,
        type:       'cancel'
        className:  'btn btn-default'
        text:       -> i18n.t 'Cancel'


    getGenericButton: (buttonConfig) ->
      _.defaults buttonConfig,
        className:  'btn btn-default'
        text:       '{btn}'


    getFormButtons: (buttons, model) ->
      btnArray = []

      for btn, btnConf of buttons

        # default buttons
        if btn is 'primary'
          btnArray.push @getDefaultButton btnConf, model

        else if btn is 'cancel'
          btnArray.push @getCancelButton btnConf

        # custom buttons
        else
          btnArray.push @getGenericButton btnConf

      new ButtonsCollection btnArray


  App.channel.reply 'form:button:entities', (buttons = {}, model) ->
    API.getFormButtons buttons, model
