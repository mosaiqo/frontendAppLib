_             = require 'underscore'
Marionette    = require 'backbone.marionette'
BaseViewMixin = require './BaseView'


module.exports = class CompositeView extends Marionette.CompositeView
  _.extend(@::, BaseViewMixin)
