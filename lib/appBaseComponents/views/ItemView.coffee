_             = require 'underscore'
Marionette    = require 'backbone.marionette'
BaseViewMixin = require './BaseView'


module.exports = class ItemView extends Marionette.ItemView
  _.extend(@::, BaseViewMixin)
