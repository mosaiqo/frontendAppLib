_             = require 'underscore'
Marionette    = require 'backbone.marionette'
BaseViewMixin = require './BaseView'


module.exports = class CollectionView extends Marionette.CollectionView
  _.extend(@::, BaseViewMixin)
