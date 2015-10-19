_             = require 'underscore'
Marionette    = require 'backbone.marionette'
BaseViewMixin = require './BaseView'


module.exports = class Layout extends Marionette.LayoutView
  _.extend(@::, BaseViewMixin)
