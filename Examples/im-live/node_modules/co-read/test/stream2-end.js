var test = require('tape');
var read = require('..');
var co = require('co');
var Readable = require('stream').Readable;
var wait = require('co-wait');

test('end', function(t) {
  t.plan(4);

  co(function*() {
    var stream = Readable();
    stream.push(null);
    
    var chunk = yield read(stream);
    t.notOk(chunk);
    chunk = yield read(stream);
    t.notOk(chunk);
    
    t.ok(true, 'ended');
  }, t.error.bind(t));
});
