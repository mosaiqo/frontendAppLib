_             = require 'underscore'
Backgrid      = require 'backgrid'
BaseViewMixin = require '../BaseView'


module.exports = class GridRow extends Backgrid.Row
  _.extend(@::, BaseViewMixin)
