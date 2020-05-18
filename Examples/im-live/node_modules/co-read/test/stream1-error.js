var test = require('tape');
var read = require('..');
var co = require('co');
var through = require('through');

test('error', function(t) {
  t.plan(2);

  co(function*() {
    var stream = through();

    process.nextTick(function() {
      stream.emit('error', new Error('bad'));
    });

    try {
      yield read(stream);
    } catch(err) {
      t.ok(err);
    }
  }, t.error.bind(t));
});
