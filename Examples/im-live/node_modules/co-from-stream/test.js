var co = require('co');
var fs = require('fs');
var fromStream = require('./');
var assert = require('assert');

describe('fromStream(stream)', function(){
  it('should create a co generator stream', function(done){
    co(function*(){
      var read = fromStream(fs.createReadStream('index.js', 'utf8'));
      var file = '';
      var chunk;
      while (chunk = yield read()) file += chunk;
      assert(file == fs.readFileSync('index.js', 'utf8'))
    })(done);
  });
});
