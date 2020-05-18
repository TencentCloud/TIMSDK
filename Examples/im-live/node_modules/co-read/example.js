var http = require('http');
var co = require('co');
var read = require('./');

co(function*() {
  var server = http.createServer(function(req, res) {
    res.write('  foo');
    res.end('  bar');
  });
  server.listen(8744);

  console.log('');
  console.log('streams2 stream');
  console.log('');

  var res = yield request('http://localhost:8744/');
  var buf;
  while(buf = yield read(res)) {
    console.log(buf.toString());
  }

  console.log('');
  console.log('streams1 stream');
  console.log('');

  var res = yield request('http://localhost:8744/');
  res.pause(); // force streams1 stream
  var buf;
  while(buf = yield read(res)) {
    console.log(buf.toString());
  }

  console.log('');
  server.close();
});

function request(url) {
  return function(done) {
    var req = http.get(url)
    req.on('response', function(res) {
      done(null, res);
    });
    req.on('error', function(err) {
      done(err);
    });
  }
}

