module.exports =

  ###
  Category hanling setup

  The tags attribute is a little bit special because it contains a collection,
  so its necessary to perform some actions when savinf the model
  ###
  setupNestedCategory: (formView, model, allCategories) ->

    # process the category when the form is submitted (before the model is saved)
    @listenTo formView, 'form:submit', (data) =>
      data.category = @processCategory data, model, allCategories

    # update the allCategories collection with any new category
    # so the new category get available for other articles
    @listenTo model, 'created, updated', ->
      modelCategory = model.get 'category'
      allCategories.add modelCategory




  ###
  Category processing before the model is saved

  When saving the model, Syphon returns the `category` field value
  as a string, but the model `category` attribute contains a model.
  The method updates the model from the category name.

  @param {Object}         data    The serialized form
  @param {Model}          model   The model
  @param {TagsCollection} allTags All the user tags (for any article)
  ###
  processCategory: (data, model, allCategories) ->
    # the new category to assign
    requestedCategory = if data.category then data.category else ''

    # current model category
    modelCategory = model.get 'category'

    # retrieve the category model
    categoryModel = @findCategoryByDefaultName allCategories, requestedCategory

    # if nothing found, create a new category
    unless categoryModel
      categoryModel = @appChannel.request 'new:blog:categories:entity'

      # set the name on the default locale (the model is new,
      # so the locales collection should contain only one locale)
      locales  = categoryModel.get 'locales'
      locale   = locales.at 0
      locale.set 'name', requestedCategory

    data.category = categoryModel


  ###
  Find a category by the name attribute of its default locale

  @param  {Collection} categories
  @param  {String} categoryName
  @return {Model} The category model, or null if nothing found
  ###
  findCategoryByDefaultName: (categories, categoryName) ->
    ret = null
    categories.forEach (tag) ->
      locale = tag.get 'defaultLocale'

      if locale and locale.name is categoryName
        ret = tag
    ret
