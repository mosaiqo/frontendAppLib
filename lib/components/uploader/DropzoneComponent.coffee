$           = require 'jquery'
_           = require 'underscore'
Dropzone    = require 'dropzone'
i18n        = require 'i18next-client'
Object      = require '../../appBaseComponents/Object'
UploadModel = require './entities/Upload'

# prevent Dropzone autoinitialization
Dropzone.autoDiscover = false


module.exports = class DropzoneFile extends Object

  ###
  @propperty {Boolean} single or multiple files accepted
  ###
  multiple: false

  ###
  @property {String} Default container template
  ###
  tmpl: '<div class="dropzone uploader"></div>'

  ###
  @property {Object} DropzoneJS options

  All options can be overrided if defined
  in the options parameter on the constructor
  ###
  defaults =
    url:       '/api/uploads'
    paramName: 'file'

    # limit to 1 be default, can also be overrided adding
    # a data-max-files attribute to the html field element
    maxFiles: 1

    # limit to 1 be default, can also be overrided adding
    # a data-accepted-files attribute to the html field element
    acceptedFiles: 'image/*'


  ###
  DropzoneJS initialization

  @param {jQuery} elem    element to convert into a dropzone
  @param {Object} options DropzoneJS options
  @param {Array}  data    initial data (previous uploads)
  ###
  initialize: (elem, options = {}, data = []) ->
    @field = elem

    # parse the options
    opts = @parseOptions elem, options

    # init the DOM
    dzElem = @createDropzoneElement  elem, opts

    # initialize the DropzoneJS component
    @dz = new Dropzone dzElem.get(0), opts

    # start the listeners
    @initializeEventHandlers(opts)

    # if there's any previous data, display it
    @populatePreviousUploads(data)

    # set the initial value
    setTimeout(=>
      @updateFieldValue()
    , 1000)


  ###
  Getter for the wrapped DropzoneJS instance
  (useful to attach event listeners from outside the component)
  ###
  get: -> @dz


  ###
  Initialize the DOM

  Hides the original form field and creates a div where the files can be dropped
  @return {jQuery} a ref. to the jQuery wrapped DOM element for the dropzone
  ###
  createDropzoneElement: (elem, options = {}) ->
    tmpl = options.tmpl or @tmpl

    elem.hide()
    $(tmpl).insertAfter elem


  ###
  Options parsing
  ###
  parseOptions: (elem, options = {}) ->

    # copy the provided options
    settings = _.extend {}, options

    # retrieve any overrides defined on the element as data-* attrs.
    elemData     = elem.data()
    domOverrides = _.pick elemData, 'maxFiles', 'acceptedFiles'

    _.extend settings, domOverrides

    # apply the default setting (for the undefined values)
    _.defaults settings, defaults

    # apply any required transform to the URL
    settings.url = @applyUrlTransforms settings.url

    # add auth. headers, if necessary
    headers = settings.headers or {}
    settings.headers = _.defaults headers, @getAuthHeaders()

    # add the locales (if not defined already)
    _.defaults settings, @getLocales()

    # update the `multiple` flag
    if settings.maxFiles > 1 then @multiple = true

    # the settings object contains mostly DropzoneJS params,
    # but also allows to override the serialize and deserialize methods
    if settings.serialize and _.isFunction(settings.serialize)
      @serialize = settings.serialize

    if settings.deserialize and _.isFunction(settings.deserialize)
      @deserialize = settings.deserialize

    _.omit settings, 'serialize', 'deserialize'


  ###
  Locales initialization
  ###
  getLocales: (options) ->
    locales = {}

    # coffeelint: disable=max_line_length
    # The text used before any files are dropped
    locales.dictDefaultMessage = i18n.t "uploader::Click or drop files here to upload"

    # The text that replaces the default message text it the browser is not supported
    locales.dictFallbackMessage = i18n.t "uploader::Your browser does not support drag'n'drop file uploads."

    # The text that will be added before the fallback form
    # If null, no text will be added at all.
    locales.dictFallbackText = i18n.t "uploader::Please use the fallback form below to upload your files like in the olden days."

    # If the filesize is too big.
    locales.dictFileTooBig = i18n.t "uploader::File is too big ({{filesize}}MiB). Max filesize: {{maxFilesize}}MiB."

    # If the file doesn't match the file type.
    locales.dictInvalidFileType = i18n.t "uploader::You can't upload files of this type."

    # If the server response was invalid.
    locales.dictResponseError = i18n.t "uploader::Server responded with {{statusCode}} code."

    # If used, the text to be used for the cancel upload link.
    locales.dictCancelUpload = i18n.t "uploader::Cancel upload"

    # If used, the text to be used for confirmation when cancelling upload.
    locales.dictCancelUploadConfirmation = i18n.t "uploader::Are you sure you want to cancel this upload?"

    # If used, the text to be used to remove a file.
    locales.dictRemoveFile = i18n.t "uploader::Remove file"

    # If this is not null, then the user will be prompted before removing a file.
    locales.dictRemoveFileConfirmation = i18n.t "uploader::Are you sure you want to delete this?"

    # Displayed when the maxFiles have been exceeded
    # You can use {{maxFiles}} here, which will be replaced by the option.
    locales.dictMaxFilesExceeded = i18n.t "uploader::Only {{maxFiles}} files can be uploaded here."
    # coffeelint: enable=max_line_length

    locales


  ###
  Apply transformations on the URL

  DropzoneJS does not use the jQuery ajax methods, so any prefilters
  defined in the app will not be applied. So, request any transforms
  (this triggers an event, if there's no response nothing will be
  transformed) and apply them.
  ###
  applyUrlTransforms: (url) ->
    normalisedUrl = @appChannel.request 'api:url:setBase', url
    normalisedUrl or url


  ###
  Add authorization headers to the requests

  (usually implemented with a jQuery ajax prefilter, but DropzoneJS
  does not use jQuery ajax)
  ###
  getAuthHeaders: ->
    headers = {}
    session = @appChannel.request 'user:session:entity'

    if session
      token = session.get 'token'
      if token
        headers.authorization = "Bearer #{token}"

    headers


  ###
  Value getter
  ###
  getValue: ->
    value = _.map @dz.getAcceptedFiles(), @serialize

    unless @multiple
      value = if value.length >= 1 then value[0] or null

    value


  ###
  Serialize method

  Used to filter out the fields, by default it returns just the upload URLs (the paths)
  but can be easily overrided
  ###
  serialize: (file) ->
    file.uploadModel?.get 'url'


  ###
  Update the field with the value
  ###
  updateFieldValue: ->
    rawValue = @getValue()
    strValue = if rawValue then JSON.stringify(rawValue) else ''
    @field.val strValue


  ###
  Widget population with preassigned data

  Used for example when editing an existing record
  ###
  populatePreviousUploads: (data = []) ->
    unless _.isArray data then return

    data.forEach (dataObj) =>
      mockFile = @deserialize dataObj

      # attach a the upload model to handle the deletion
      if mockFile.upload and mockFile.upload.id
        mockFile.uploadModel = new UploadModel mockFile.upload

      # Call the default addedfile event handler
      @dz.emit 'addedfile', mockFile

      # And optionally show the thumbnail of the file:
      ext = mockFile.url?.split('.').pop()

      if ['jpg', 'jpeg', 'png', 'gif'].indexOf(ext) > -1
        @dz.emit 'thumbnail', mockFile, mockFile.url

      # Make sure that there is no progress bar, etc...
      @dz.emit 'complete', mockFile

      mockFile.accepted = true
      @dz.files.push mockFile


  ###
  Deserialize method

  Used to  populate the data
  Override it to add additional attributes
  (useful when used with a custom template, or when not dealing with raw Upload
  models, but instead with something that wraps them like a Image or Document model)
  ###
  deserialize: (obj) ->
    # required fields
    name:     obj.path?.split('/').pop()
    size:     obj.size,
    type:     obj.contentType
    url:      obj.url

    # upload data (this allows the file removal)
    upload:   obj


  ###
  Event handlers initialization
  ###
  initializeEventHandlers: (settings) ->
    unless _.has(settings, 'success')
      @dz.on 'success', @handleSuccess

    unless _.has(settings, 'removedfile')
      @dz.on 'removedfile', @handleRemoval

    if _.has(settings, 'clickedfile') and _.isFunction(settings.clickedfile)
      @dz.on 'addedfile', @bindElementClick


  ###
  Attach a click handler to each file block
  ###
  bindElementClick: (file) =>
    elem = file.previewElement
    elem.className = elem.className + ' clickable'

    # add a set method to make it easier manipulating the file
    # and triggering the appropiate events
    instance = @
    file.set = (key, val) ->
      if key is 'name'
        @name = val
        node.textContent = val for node in @previewElement.querySelectorAll '[data-dz-name]'
      else if key is 'upload'
        if _.isObject(val) then @uploadModel.set val
      else
        @[key] = val
      instance.updateFieldValue()

    elem.addEventListener 'click', =>
      @dz.options.clickedfile file, elem


  ###
  Success callback
  ###
  handleSuccess: (file, response) =>
    # create the model
    model = new UploadModel response.data

    # link it to the file object so it can be destroyed when the file is deleted
    file.uploadModel = model

    # update the original field
    @updateFieldValue()



  ###
  Delete callback
  ###
  handleRemoval: (file) =>
    if file.uploadModel
      file.uploadModel.destroy
        success: => @updateFieldValue()
