var load = require('..');
var assert = require('assert');

describe('read-metadata', function () {

  describe('loading sync', function () {
    it('should load json files', function (done) {
      var data = load.sync('test/fixtures/metadata.json');
      assert.equal(data.name, 'Batman');
      done();
    });
    it('should load yaml files', function (done) {
      var data = load.sync('test/fixtures/metadata.yaml');
      assert.equal(data.name, 'Batman');
      done();
    });
    it('should load yml files', function (done) {
      var data = load.sync('test/fixtures/metadata.yml');
      assert.equal(data.name, 'Batman');
      done();
    });
  });

  describe('loading async', function () {
    it('should load json files', function (done) {
      load('test/fixtures/metadata.json', function(err, data){
        assert.equal(data.name, 'Batman');
        done();
      });
    });
    it('should load yaml files', function (done) {
      load('test/fixtures/metadata.yaml', function(err, data){
        assert.equal(data.name, 'Batman');
        done();
      });
    });
    it('should load yml files', function (done) {
      load('test/fixtures/metadata.yml', function(err, data){
        assert.equal(data.name, 'Batman');
        done();
      });
    });
    it('should throw an error if the file is missing', function (done) {
      load('test/fixtures/metadata2.yaml', function(err, data){
        assert(err != null);
        done();
      });
    });
    it('should throw an error if the file is not supported', function (done) {
      load('test/fixtures/metadata.xml', function(err, data){
        assert(err != null);
        done();
      });
    });
  });

});