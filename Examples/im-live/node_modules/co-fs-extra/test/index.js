var co = require('co');
var fs = require('..');
var assert = require('assert');

describe('co-fs methods', function () {
  it('should be exports', function () {
    return co(function* () {
      var ret = yield fs.exists('test/fixtures/msg.json');
      assert(true === ret);
    });
  });
});

describe('fs-extra methods', function () {
  it('should be wrapped', function () {
    return co(function* () {
      var data = yield fs.readJson('test/fixtures/msg.json');
      assert('hello' === data.msg);
    });
  });
});
