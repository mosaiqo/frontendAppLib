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
  @property {String} Default preview template
  ###
  # coffeelint: disable=max_line_length
  previewTmpl: """
  <div class="dz-preview dz-file-preview">
    <div class="dz-image">
      <div data-dz-custom-thumbnail class="dz-image-inner"></div>
    </div>
    <div class="dz-details">
      <div class="dz-size"><span data-dz-size></span></div>
      <div class="dz-filename"><span data-dz-name></span></div>
      <div class="dz-preview-link">
        <a href="#" target="_blank" dz-preview-link-url>
          <i class="icon icon-cloud-download" aria-hidden="true"></i>
        </a>
      </div>
    </div>
    <div class="dz-progress"><span class="dz-upload" data-dz-uploadprogress></span></div>
    <div class="dz-error-message"><span data-dz-errormessage></span></div>
    <div class="dz-success-mark">
      <svg width="54px" height="54px" viewBox="0 0 54 54" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:sketch="http://www.bohemiancoding.com/sketch/ns">
        <title>Check</title>
        <defs></defs>
        <g id="Page-1" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd" sketch:type="MSPage">
          <path d="M23.5,31.8431458 L17.5852419,25.9283877 C16.0248253,24.3679711 13.4910294,24.366835 11.9289322,25.9289322 C10.3700136,27.4878508 10.3665912,30.0234455 11.9283877,31.5852419 L20.4147581,40.0716123 C20.5133999,40.1702541 20.6159315,40.2626649 20.7218615,40.3488435 C22.2835669,41.8725651 24.794234,41.8626202 26.3461564,40.3106978 L43.3106978,23.3461564 C44.8771021,21.7797521 44.8758057,19.2483887 43.3137085,17.6862915 C41.7547899,16.1273729 39.2176035,16.1255422 37.6538436,17.6893022 L23.5,31.8431458 Z M27,53 C41.3594035,53 53,41.3594035 53,27 C53,12.6405965 41.3594035,1 27,1 C12.6405965,1 1,12.6405965 1,27 C1,41.3594035 12.6405965,53 27,53 Z" id="Oval-2" stroke-opacity="0.198794158" stroke="#747474" fill-opacity="0.816519475" fill="#FFFFFF" sketch:type="MSShapeGroup"></path>
        </g>
      </svg>
    </div>
    <div class="dz-error-mark">
      <svg width="54px" height="54px" viewBox="0 0 54 54" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:sketch="http://www.bohemiancoding.com/sketch/ns">
        <title>Error</title>
        <defs></defs>
        <g id="Page-1" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd" sketch:type="MSPage">
          <g id="Check-+-Oval-2" sketch:type="MSLayerGroup" stroke="#747474" stroke-opacity="0.198794158" fill="#FFFFFF" fill-opacity="0.816519475">
            <path d="M32.6568542,29 L38.3106978,23.3461564 C39.8771021,21.7797521 39.8758057,19.2483887 38.3137085,17.6862915 C36.7547899,16.1273729 34.2176035,16.1255422 32.6538436,17.6893022 L27,23.3431458 L21.3461564,17.6893022 C19.7823965,16.1255422 17.2452101,16.1273729 15.6862915,17.6862915 C14.1241943,19.2483887 14.1228979,21.7797521 15.6893022,23.3461564 L21.3431458,29 L15.6893022,34.6538436 C14.1228979,36.2202479 14.1241943,38.7516113 15.6862915,40.3137085 C17.2452101,41.8726271 19.7823965,41.8744578 21.3461564,40.3106978 L27,34.6568542 L32.6538436,40.3106978 C34.2176035,41.8744578 36.7547899,41.8726271 38.3137085,40.3137085 C39.8758057,38.7516113 39.8771021,36.2202479 38.3106978,34.6538436 L32.6568542,29 Z M27,53 C41.3594035,53 53,41.3594035 53,27 C53,12.6405965 41.3594035,1 27,1 C12.6405965,1 1,12.6405965 1,27 C1,41.3594035 12.6405965,53 27,53 Z" id="Oval-2" sketch:type="MSShapeGroup"></path>
          </g>
        </g>
      </svg>
    </div>
  </div>
  """
  # coffeelint: enable=max_line_length

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

    # set the default template (if not overriden)
    unless settings.previewTemplate
      settings.previewTemplate = @previewTmpl

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
    strValue = if _.isObject(rawValue) then JSON.stringify(rawValue) else rawValue
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

    if !@multiple and settings.deleteOnReplace
      @dz.on 'addedfile', @replacePreviousFile

    # the default component template overrides the DropzoneJS one
    # and does not use a img element to display the preview, instead
    # it uses a div and sets the img as a background (to control the
    # sizing, because the css rule object-fit is not widely supported)
    @dz.on 'thumbnail', @setThumbnail

    # add a link to preview/download the file
    @dz.on 'addedfile', @setLinkToFile


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
  Custom thumbnail method
  ###
  setThumbnail: (file, dataUrl) ->
    if file.previewElement
      file.previewElement.classList.remove "dz-file-preview"
      for thumbnailElement in file.previewElement.querySelectorAll("[data-dz-custom-thumbnail]")
        thumbnailElement.style.backgroundImage = "url(#{dataUrl})"

  ###
  Add a link to the file
  ###
  setLinkToFile: (file) ->
    if file.previewElement
      for thumbnailElement in file.previewElement.querySelectorAll("[dz-preview-link-url]")
        thumbnailElement.href = file.url

        # prevent the click on the link to trigger other actions
        thumbnailElement.onclick = (e) -> e.stopPropagation()


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


  ###
  When the widget accepts only one file, ask the user if he wants to
  replace it when adding a file with a preexisting one selected
  ###
  replacePreviousFile: (file) =>
    # previous file + the one added
    currentFiles = @dz.files

    if currentFiles.length > 1
      q  = i18n.t "uploader::There's already a file selected. Do you want to replace it?"
      cb = (replace) =>
        unless replace
          # remove the new one
          @dz.removeFile currentFiles[1]
        else
          # remove the old one
          @dz.removeFile currentFiles[0]

          # This handler is only used when the dropbox accepts only 1 file
          # so when the new file was added, an error class was set on the
          # preview and the file was not actually processed.
          # So, if replacing, cleanup the preview and process the file.
          newFile = currentFiles[1]

          newFile.previewElement.classList.remove 'dz-error'
          @dz.processFile newFile

      @_confirm q, cb


  ###
  Aux confirm method

  Displays a confirm using Bootbox (or any custom dialog system),
  or falls back to a native one
  ###
  _confirm: (text, callback = _.noop) ->
    customConfirm = @appChannel.request 'dialogs:confirm', text, callback

    # fallback to plain confirm
    unless customConfirm
      window.confirm text, callback

