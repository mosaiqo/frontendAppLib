ItemView = require '../../appBaseComponents/views/ItemView'


module.exports = class LoadingView extends ItemView
  template:  require './templates/spinner.hbs'
  className: 'loading-container'
