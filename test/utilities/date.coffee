describe 'lib/utilities/date', ->
  dateUtil = require 'lib/utilities/date'


  it 'should convert a valid date to an object with date and time attributes', (done) ->
    date    = new Date().getTime()
    dateObj = dateUtil.splitDateTime date

    expect(dateObj).to.have.property 'date'
    expect(dateObj).to.have.property 'time'

    dateParts = dateObj.date.split '-'
    timeParts = dateObj.time.split ':'

    expect(dateParts).to.have.length 3
    expect(timeParts).to.have.length 3

    day     = parseInt dateParts[2], 10
    month   = parseInt dateParts[1], 10
    year    = parseInt dateParts[0], 10
    hour    = parseInt timeParts[0], 10
    minutes = parseInt timeParts[1], 10
    seconds = parseInt timeParts[2], 10

    expect(day).to.be.within   1,31
    expect(month).to.be.within 1,12
    expect(year).to.be.a 'number'
    expect(year.toString()).to.have.length.at.least 4

    expect(hour).to.be.within    0,23
    expect(minutes).to.be.within 0,59
    expect(seconds).to.be.within 0,59

    done()


  it 'should convert an invalid date to an object with date and time attributes with null values', (done) ->
    date    = null
    dateObj = dateUtil.splitDateTime date

    expect(dateObj).to.have.property 'date'
    expect(dateObj).to.have.property 'time'

    expect(dateObj.date).to.be.null
    expect(dateObj.time).to.be.null
    done()
