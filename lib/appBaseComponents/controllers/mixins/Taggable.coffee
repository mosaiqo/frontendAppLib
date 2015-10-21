module.exports =

  ###
  Tags hanling setup

  The tags attribute is a little bit special because it contains a collection,
  so its necessary to perform some actions when savinf the model
  ###
  setupNestedTags: (formView, model, allTags) ->

    # process the tags when the form is submitted (before the model is saved)
    @listenTo formView, 'form:submit', (data) =>
      data.tags = @processTags data, model, allTags

    # update the allTags collection with any new tag
    # so the new tags get available for other articles
    @listenTo model, 'created, updated', ->
      modelTags = model.get 'tags'
      allTags.add modelTags.models




  ###
  Tags processing before the model is saved

  When saving the model, Syphon returns the `tags` field value
  as a string, but the model `tags` attribute contains a collection.
  The method updates the collection from the tags names.

  @param {Object}         data    The serialized form
  @param {Model}          model   The model
  @param {TagsCollection} allTags All the user tags (for any article)
  ###
  processTags: (data, model, allTags) ->
    # the new tags to assign, as 'tag1,tag2,tagN'
    requestedTags = if data.tags then data.tags.split(',') else []

    # When determining if the tag should be created, by default check the
    # `allTags` parameter, that should contain all the user tags.
    # If the `allTags` is not provided, check just the model tags (this is just
    # for extra flexibility, for the article tags this should not be necessary)
    allTags or= model.get 'tags'

    # current model tags
    modelTags = model.get 'tags'

    # the tag models array that will be used to reset the entity `tags`collection
    newTags = requestedTags.map (tagName) =>
      # retrieve the tag model
      tagModel = @findTagByDefaultName allTags, tagName

      # if nothing found, create a new tag
      unless tagModel
        tagModel =  @appChannel.request 'new:blog:tags:entity'

        # set the name on the default locale (the model is new,
        # so the locales collection should contain only one locale)
        locales  = tagModel.get 'locales'
        locale   = locales.at 0
        locale.set 'name', tagName
      tagModel

    data.tags = newTags


  ###
  Find a tag by the name attribute of its default locale

  @param  {Collection} tags
  @param  {String} tagName
  @return {Model} The tag model, or null if nothing found
  ###
  findTagByDefaultName: (tags, tagName) ->
    ret = null
    tags.forEach (tag) ->
      locale = tag.get 'defaultLocale'

      if locale and locale.name is tagName
        ret = tag
    ret
