_          = require 'underscore'
i18n       = require 'i18next-client'
Validation = require 'backbone-validation'


###
backbone.validation configuration
==================================
###
module.exports = (Module, App, Backbone, Marionette, $, _) ->

  # Add some custom validators
  _.extend Validation.validators,

    ###
    Length validators for collection objects
    The default length validators only workwith strings.
    This additional validators work with arrays, objects and also vackbone collections
    ###
    collectionLength: (collection, attr, requiredLength, model) ->
      if _.size(collection) != requiredLength
        @format Validation.messages.collectionLength, @formatLabel(attr, model), requiredLength

    collectionMinLength: (collection, attr, requiredLength, model) ->
      if _.size(collection) < requiredLength
        @format Validation.messages.collectionMinLength, @formatLabel(attr, model), requiredLength

    collectionMaxLength: (collection, attr, requiredLength, model) ->
      if _.size(collection) > requiredLength
        @format Validation.messages.collectionMaxLength, @formatLabel(attr, model), requiredLength

    collectionRangeLength: (collection, attr, range, model) ->
      size = _.size(collection)
      if size < range[0] or size > range[1]
        @format Validation.messages.collectionRangeLength, @formatLabel(attr, model), range[0], range[1]



  # Set a custom label formatter
  _.extend Validation.labelFormatters,
    customLabelFormatter : (attrName, model) ->
      # on I18n enabled forms, the locale fields
      # are prefixed with 'lcl.{lang}.'
      # remove the prefix when displaying the error
      label = attrName.replace /^lcl\.[a-z]{2}\./, ''
      model.constructor.label label


  Validation.configure
    labelFormatter: 'customLabelFormatter'


  # Overwrite the default backbone.validation messages with the localized ones.
  # This must be done after the locale is loaded
  @listenTo App.channel, 'locale:loaded', ->
    _.extend Validation.messages,
      required     : i18n.t 'validation::{0} is required'
      acceptance   : i18n.t 'validation::{0} must be accepted'
      min          : i18n.t 'validation::{0} must be greater than or equal to {1}'
      max          : i18n.t 'validation::{0} must be less than or equal to {1}'
      range        : i18n.t 'validation::{0} must be between {1} and {2}'
      length       : i18n.t 'validation::{0} must be {1} characters'
      minLength    : i18n.t 'validation::{0} must be at least {1} characters'
      maxLength    : i18n.t 'validation::{0} must be at most {1} characters'
      rangeLength  : i18n.t 'validation::{0} must be between {1} and {2} characters'
      oneOf        : i18n.t 'validation::{0} must be one of: {1}'
      equalTo      : i18n.t 'validation::{0} must be the same as {1}'
      digits       : i18n.t 'validation::{0} must only contain digits'
      number       : i18n.t 'validation::{0} must be a number'
      email        : i18n.t 'validation::{0} must be a valid email'
      url          : i18n.t 'validation::{0} must be a valid url'
      inlinePattern: i18n.t 'validation::{0} is invalid'
      collectionLength      : i18n.t 'validation::{0} must contain {1} items'
      collectionMinLength   : i18n.t 'validation::{0} must contain at least {1} items'
      collectionMaxLength   : i18n.t 'validation::{0} must contain at most {1} items'
      collectionRangeLength : i18n.t 'validation::{0} must contain between {1} and {2} items'
