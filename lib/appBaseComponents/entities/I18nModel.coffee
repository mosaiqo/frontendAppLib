# Dependencies
# -------------------------
$              = require 'jquery'
_              = require 'underscore'
Model          = require './Model'
LocaleMutators = require './util/LocalesMutators'
channel        = require 'lib/utilities/appChannel'
Validator      = require 'backbone-validation'


###
Translatable model
===================

Model with l18n attributes.
Those translatable attributes are not deffined directly on the model. instead
it has a `locales` attribute, wich is a relation to a collection that extends
EntityLocalesCollection.
This model has some virtual attributes to make easier and cleaner the locales
editing on the views that use backbone.syphon and backbone-validation.

@class
@augments Model

###
module.exports = class I18nModel extends Model

  initialize: (attributes = {}, options = {}) ->

    # Create some getters/setters for the locales
    @_setupLocalesMutators()

    # Call the parent initialize method
    super attributes, options

    # Propagate the locale validation rules to the model.
    # This is only used on the views.
    @_setupLocalesValidation()

    super attributes, options



  ###
  Virtual attributes initialization

  Attach some mutators (getters/setters) to the model to make it easier
  and cleaner the use of this model and related locales on the views

  @private
  ###
  _setupLocalesMutators: ->

    # Declare the computed fields property if the model does not have one
    unless @computed
      @computed = {}

    defaultLang    = @_getDefaultLanguage()
    availableLangs = @_getAvailableLanguages()

    # internal funct. used for the virtual attributes
    # that deppend on the locales collection
    # see: https://github.com/alexbeletsky/backbone-computedfields/issues/8
    localesDependencyGetter = (callback) =>
      locales = @get 'locales'
      if locales
        locales.on 'add remove update reset change', callback


    _.extend @computed,

      # Getter for the default locale:
      # Returns the locale for the default language (or any other available
      # if the default does not exist). This is intended to be used in lists
      # in the admin area (not on end-users facing pages) so all the model
      # instances can be listed, regardless of the models available locales.
      defaultLocale:
        transient: true
        depends:   ['locales', localesDependencyGetter]
        get:       _.partial(LocaleMutators.deserializeDefaultLocale, defaultLang)

      # Getter, provides an object with a list of available locales, like:
      # {
      #   'en' : 'English',
      #   'de' : 'Deutsch'
      # }
      # In the returned ogject, the key is the language code (the lang. code
      # is also used as ID on the locale models), and the value is the language
      # name, to be used on a view or whatever.
      availableLocales:
        transient: true
        get: (fields) -> availableLangs

      # Locales relation getter/setter
      # Provides a getter and setter for the locales collection to make it easier
      # the use of the locale models on the views.
      lcl:
        transient: true
        depends:   ['locales', localesDependencyGetter]
        get:       _.partial(LocaleMutators.deserializeLocales, defaultLang, availableLangs)



  ###
  @return {String} the default locale id (something like 'en')
  @private
  ###
  _getDefaultLanguage: ->
    channel.request 'languages:default'



  ###
  @return {Object} the available locales
  @private
  ###
  _getAvailableLanguages: ->
    channel.request 'languages:all'



  ###
  Override the patch method

  Parse the 'lcl' virtual attribute and handle the locales entities individually
  ###
  patch: (data, options = {}) ->
    # array of changed locale entities operations
    # it will be used to delay the main model save
    # until the nested entities are processed
    pendingLocaleOperations = []

    if data.lcl
      # process the locale models
      # this should return an array of deferred objects
      pendingLocaleOperations = @_processLocales data.lcl

      # remove 'lcl' from the data object before calling the parent method
      delete data.lcl

    # if there are operations on the nested models,
    # wait until they finish before saving the main model
    if pendingLocaleOperations.length

      # if any of the operations has failed before sending the request to
      # the server, it should contain a falsy value
      failed = _.contains(pendingLocaleOperations, false)

      if failed
        @trigger 'sync:stop', @
        return false
      else
        # trigger sync:start event (this is usually triggered when the model
        # starts syncing, but in this case it will not be triggered until the
        # locales operations ends. Force it to treat the model and its locales
        # as a unit)
        @trigger 'sync:start', @

        successCb = =>
          # call the parent class 'patch' method
          # super does not work here...
          @constructor.__super__.patch.call @, data, options

        errorCb = =>
          @trigger 'sync:stop', @

        $.when(pendingLocaleOperations...).done(successCb).fail(errorCb)

    else
      super data, options



  ###
  Parse the locale actions and run them
  @return {Array} a list of locale models operations (as deferred objects)
                  that must complete before the main model can be processed.
                  Any falsy value should be considered as an error.
  @private
  ###
  _processLocales: (data) ->
    actions = @_parseLocales data

    # Prevalidate everything before any locale models individual actions:
    # Prevent any locale model being altered if any of them is not valid.
    # Also, if the collection has any additional validation (like a minimum
    # or maximum length), check it first before altering anything.
    if @_preValidateLocalesCollection(actions) and @_prevalidateLocaleModels(actions)
      processed = _.reduce actions, @_processLocaleAction, []
      processed
    else
      [false]



  ###
  Lcl parsing

  Parses the lcl attribute retrieved form the view in order to determine
  the needed actions to perform on the nested locale models

  @private
  ###
  _parseLocales: (value) ->
    allLangs = @_getAvailableLanguages()
    locales  = @get 'locales'
    actions  = []
    isNew    = @isNew()

    _.keys(allLangs).forEach (lang) ->

      localeModel = locales.get lang
      newAttrs    = value[lang]

      if newAttrs
        # update/create the model

        if localeModel
          # the locale already exists, update it
          actions.push
            action: 'update'
            entity: localeModel
            args:   newAttrs

        else
          # new locale, create the model
          newModelAttrs = _.extend newAttrs, { id: lang }
          actions.push
            action: 'create'
            args:   newModelAttrs

      else
        if localeModel
          # no data, delete the model
          actions.push
            action: 'delete'
            entity: localeModel

    # add some common parameters to the actions
    _.map actions, (action) ->
      action.isNew      = isNew
      action.collection = locales

    actions



  ###
  Processes some action over a nested locale

  @return {Array} This is intended to be used as a callback with _.reduce.
                  The memo array will hold references to the locale operations
                  as promises, only when the model is not new and needs to perform
                  a server operation.
                  If the model is new all the operations are performed locally.
                  The array can also contain falsy values, that should be treated
                  as errors.
  @private
  ###
  _processLocaleAction: (memo, actionParams) ->
    action     = actionParams.action
    entity     = actionParams.entity
    args       = actionParams.args
    collection = actionParams.collection
    isNew      = actionParams.isNew

    switch action
      when 'create'
        # modelId is a special option, not used by backbone,
        # and its purpose is just to help identify the model
        # that triggered some error (the 'invalid' Backbone
        # event contains all the options as one of its params)
        opts =
          validate: true
          modelId:  args.id

        if isNew
          result = collection.add args, opts

          # error...
          unless result then memo.push(false)

        else
          opts.wait = true
          newLocale = collection.create args, opts
          result    = if newLocale then newLocale.getDeferred() else false
          memo.push result

      when 'update'
        result = entity.set args, { validate: true }

        # error...
        unless result then memo.push(false)

        unless isNew
          if entity.hasChanged()
            # restore the attrs. because the patch checks the changes
            # and it won't be detected so the model will not be saved
            # on the server. Setting/unsetting the values instead of
            # comparing the args with the model attributes because
            # the model might have some custom setters or whatever
            entity.set entity.previousAttributes(), { silent: true }

            result = entity.patch args
            memo.push result

      when 'delete'
        if isNew
          collection.remove entity
        else
          result = entity.destroy { wait: true }
          memo.push result

    memo



  ###
  Nested locales validation setup
  ###
  _setupLocalesValidation: ->
    locales = @get 'locales'

    # validation models errors:

    @listenTo locales, 'invalid', (collection, err, opts = {}) =>
      if opts.modelId
        @_triggerLocaleError opts.modelId, err

    @listenTo locales, 'validated:invalid', (locale, err) =>
      @_triggerLocaleError locale.id, err


    # validation for the collection (to ensure a min. length for example):

    @listenTo locales, 'update', -> @validate 'locales'
    @listenTo @, 'invalid', (model, err = {}, opts) ->
      if err.locales
        # bubble up the error
        @dispatchCustomValidationError err



  ###
  Creates a copy of the error object with the error keys transformed,
  so it can be used on the view with Syphon or whatever
  ###
  _triggerLocaleError: (localeId, err) ->
    newErr = {}
    prefix = "lcl.#{localeId}"

    _.each err, (v, k) ->
      newErr["#{prefix}.#{k}"] = v

    # bubble up the error
    @dispatchCustomValidationError newErr


  ###
  Locales collection prevalidation

  Runs any deffined validation for the locales attribute.
  It fakes the value by creating a new array with the same
  length as the locales collection once the locale entities
  are processed. This is executed before actually altering
  anything.

  The only validations that make sense applied to the 'locales'
  attribute (and to any collection in general) are the ones
  related to its length (the validations related to the locale
  attributes should be defined inside the model)
  ###
  _preValidateLocalesCollection: (actions) ->
    valid = true
    localesValidationRules = @validation.locales

    if localesValidationRules
      insertActions = _.where(actions, {action: 'create'}).length
      deleteActions = _.where(actions, {action: 'delete'}).length
      currentLength = @get('locales').length
      newLength     = currentLength - deleteActions + insertActions

      # create a fake collection
      # the validations applied to collections just check its length,
      # so an empty array is enough
      fakeCollection = new Array(newLength)

      err = @preValidate('locales', fakeCollection)

      if err
        valid = false
        @trigger 'invalid', @,
          locales: err

      valid



  ###
  Locale models prevalidation

  Prevalidate all the actions that should be applied to the models
  in the 'locales' collection before performing any alteration on the
  models. This allows to ensure everything is valid and no single model
  is altered untill they all are valid
  ###
  _prevalidateLocaleModels: (actions) ->
    valid = true
    localeModel = @get('locales').model

    errors = _.reduce actions, ((memo, actionParams) ->
      action = actionParams.action
      args   = actionParams.args

      # only check the create and update actions;
      # the delete ones are not necessary
      if action is 'create' or action is 'update'
        # create a tmp model with the required attributes
        tmpModel = new localeModel args,
          validate: true

        # retrieve any validation error
        err = tmpModel.validationError

        # destroy the tmp model (not necessary anymore)
        tmpModel.destroy()

        if err
          id = if action is 'create' then args.id else actionParams.entity.id
          memo.push
            id:    id
            error: err

      memo
    ), []

    if errors.length
      valid = false

      # trigger some errors
      _.each errors, (err) => @_triggerLocaleError err.id, err.error

    valid
