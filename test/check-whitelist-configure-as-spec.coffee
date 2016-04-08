http = require 'http'
CheckWhitelistConfigureAs = require '../'

describe 'CheckWhitelistConfigureAs', ->
  beforeEach ->
    @whitelistManager =
      checkConfigureAs: sinon.stub()

    @sut = new CheckWhitelistConfigureAs
      whitelistManager: @whitelistManager

  describe '->do', ->
    describe 'when called with a valid job with no as', ->
      beforeEach (done) ->
        job =
          metadata:
            auth:
              uuid: 'green-blue'
              token: 'blue-purple'
            responseId: 'yellow-green'
        @sut.do job, (error, @newJob) => done error

      it 'should get have the responseId', ->
        expect(@newJob.metadata.responseId).to.equal 'yellow-green'

      it 'should get have the status code of 204', ->
        expect(@newJob.metadata.code).to.equal 204

      it 'should get have the status of ', ->
        expect(@newJob.metadata.status).to.equal http.STATUS_CODES[204]

    describe 'when called with a valid job that has an as', ->
      beforeEach (done) ->
        @whitelistManager.checkConfigureAs.yields null, true
        job =
          metadata:
            auth:
              uuid: 'device'
              as: 'impersonator'
            responseId: 'purple-green'
        @sut.do job, (error, @newJob) => done error

      it 'should call the whitelistmanager with the correct arguments', ->
        expect(@whitelistManager.checkConfigureAs).to.have.been.calledWith emitter: 'impersonator', subscriber: 'device'

      it 'should get have the responseId', ->
        expect(@newJob.metadata.responseId).to.equal 'purple-green'

      it 'should get have the status code of 204', ->
        expect(@newJob.metadata.code).to.equal 204

      it 'should get have the status of OK', ->
        expect(@newJob.metadata.status).to.equal http.STATUS_CODES[204]

    describe 'when called with a job that with a device that has an invalid whitelist', ->
      beforeEach (done) ->
        @whitelistManager.checkConfigureAs.yields null, false
        job =
          metadata:
            auth:
              uuid: 'device'
              as: 'imposter'
            responseId: 'purple-green'
        @sut.do job, (error, @newJob) => done error

      it 'should call the whitelistmanager with the correct arguments', ->
        expect(@whitelistManager.checkConfigureAs).to.have.been.calledWith emitter: 'imposter', subscriber: 'device'

      it 'should get have the responseId', ->
        expect(@newJob.metadata.responseId).to.equal 'purple-green'

      it 'should get have the status code of 403', ->
        expect(@newJob.metadata.code).to.equal 403

      it 'should get have the status of Forbidden', ->
        expect(@newJob.metadata.status).to.equal http.STATUS_CODES[403]

    describe 'when called and the checkConfigureAs yields an error', ->
      beforeEach (done) ->
        @whitelistManager.checkConfigureAs.yields new Error "black-n-black"
        job =
          metadata:
            auth:
              uuid: 'device'
              as:   'trouble-maker'
            responseId: 'purple-green'
        @sut.do job, (error, @newJob) => done error

      it 'should call the whitelistmanager with the correct arguments', ->
        expect(@whitelistManager.checkConfigureAs).to.have.been.calledWith
          emitter: 'trouble-maker'
          subscriber: 'device'

      it 'should get have the responseId', ->
        expect(@newJob.metadata.responseId).to.equal 'purple-green'

      it 'should get have the status code of 500', ->
        expect(@newJob.metadata.code).to.equal 500

      it 'should get have the status of Forbidden', ->
        expect(@newJob.metadata.status).to.equal http.STATUS_CODES[500]
