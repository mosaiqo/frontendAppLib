describe 'lib/utilities/httpRequestUrlTransformer/requestUtil', ->
  requestUtil = require 'lib/utilities/httpRequestUrlTransformer/requestUtil'


  it 'should add provided new url base', (done) ->
    modelURL      = '/api/whatever'
    apiBaseURL    = '/api'
    newApiBaseURL = '/api/v1'
    newModelURL   = requestUtil.setUrlRoot(modelURL, apiBaseURL, newApiBaseURL)

    expect(newModelURL).to.be.equal '/api/v1/whatever'

    modelURL      = '/api/whatever/api/foo'
    apiBaseURL    = /^\/api/
    newApiBaseURL = 'http://someotherhost:8080/API'
    newModelURL   = requestUtil.setUrlRoot(modelURL, apiBaseURL, newApiBaseURL)

    expect(newModelURL).to.be.equal 'http://someotherhost:8080/API/whatever/api/foo'

    done()
