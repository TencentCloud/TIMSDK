var test = require('tape');
var read = require('..');
var co = require('co');
var Readable = require('stream').Readable;

test('error', function(t) {
  t.plan(2);

  co(function*() {
    var stream = Readable();
    stream._read = function() {
      stream.emit('error', new Error('bad'));
    };

    try {
      yield read(stream);
    } catch(err) {
      t.ok(err);
    }
  }, t.error.bind(t));
});
