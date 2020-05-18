var test = require('tape');
var read = require('..');
var co = require('co');
var through = require('through');

test('read', function(t) {
  var times = 3;
  t.plan(2 + times);

  co(function*() {
    var stream = through();

    process.nextTick(function() {
      (function next() {
        stream.queue('foo');
        if (--times) setTimeout(next, 10);
        else stream.end();
      })();
    });

    var chunk;
    while (chunk = yield read(stream)) {
      t.equal(chunk, 'foo', 'data event');
    }

    t.ok(true, 'ended');
  }, t.error.bind(t));
});

