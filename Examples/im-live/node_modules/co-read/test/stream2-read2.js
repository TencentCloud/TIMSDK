var test = require('tape');
var read = require('..');
var co = require('co');
var Readable = require('stream').Readable;

test('read2', function(t) {
  var times = 3;
  t.plan(2 + (times * 2));

  co(function*() {
    var stream = Readable();
    stream._read = function() {
      setTimeout(function() {
        if (times-- > 0) {
          stream.push('foo');
          stream.push('bar');
        } else {
          stream.push(null);
        }
      }, 10);
    };

    var chunk;
    while (chunk = yield read(stream)) {
      t.ok(/foo|bar/.test(chunk.toString()), 'data event');
    }

    t.ok(true, 'ended');
  }, t.error.bind(t));
});
