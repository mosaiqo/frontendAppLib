_ = require 'underscore'
$ = require 'jquery'


$.fn.toggleWrapper = (obj = {}, cid, init) ->
  methods =
    getWrapperByCid: (cid) ->
      $("[data-wrapper='#{cid}']")

    isTransparent: (bg) ->
      /transparent|rgba/.test bg

    setBackgroundColor: (bg) ->
      if @isTransparent(bg) then "white" else bg

  _.defaults obj,
    className: ""
    backgroundColor: methods.setBackgroundColor @css("backgroundColor")
    zIndex: if @css("zIndex") is "auto" or 0 then 1000 else (Number) @css("zIndex")

  $offset = @offset()
  $width  = @outerWidth(false)
  $height = @outerHeight(false)

  if init
    ## don't add another wrapper if one is already present
    return if methods.getWrapperByCid(cid).length

    overlay = """
    <div class="formLoadingOverlay">
      <div class="spinner">
        <div class="bounce1"></div>
        <div class="bounce2"></div>
        <div class="bounce3"></div>
      </div>
    </div>
    """

    ## add the wrapper
    $(overlay)
      .appendTo("body")
        .addClass(obj.className)
          .attr("data-wrapper", cid)
            .css
              width: $width
              height: $height
              top: $offset.top
              left: $offset.left
              position: "absolute"
              zIndex: obj.zIndex + 1
              backgroundColor: obj.backgroundColor
  else
    ## remove the wrapper
    methods.getWrapperByCid(cid).remove()
