Radio   = require 'backbone.radio'
config = require('../config').get()



###
Default application Radio channel
===================================

Each module can deffine their own channels, too

###
module.exports = Radio.channel(config.appChannel)
