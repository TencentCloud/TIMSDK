var test = require('tape');
var read = require('..');
var co = require('co');
var Readable = require('stream').Readable;

test('read', function(t) {
  var times = 3;
  t.plan(2 + times);

  co(function*() {
    var stream = Readable();
    stream._read = function() {
      if (times--) {
        setTimeout(function() {
          stream.push('foo');
        }, 10);
      } else {
        stream.push(null);
      }
    };

    var chunk;
    while (chunk = yield read(stream)) {
      t.equal(chunk.toString(), 'foo', 'data event');
    }

    t.ok(true, 'ended');
  }, t.error.bind(t));
});
