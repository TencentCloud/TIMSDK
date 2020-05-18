
/**
 * Expose `read`.
 */

module.exports = read;

/**
 * Read from a readable `stream`.
 *
 * @param {Stream} stream
 * @return {Function}
 */

function read(stream) {
  return typeof stream.read == 'function'
    ? read2(stream)
    : read1(stream);
}

/**
 * Read from a readable streams1 `stream`.
 *
 * @param {Stream} stream
 * @return {Function}
 */

function* read1(stream) {
  var err;
  var data;

  stream.on('data', ondata);
  stream.on('error', onerror);
  stream.resume();

  function ondata(_data) {
    stream.pause();
    data = _data;
  }

  function onerror(_err) {
    err = _err;
  }

  yield function (done) {
    if (err || data || !stream.readable) return done();

    stream.on('data', onevent);
    stream.on('end', onevent);
    stream.on('error', onevent);

    function onevent() {
      stream.removeListener('data', onevent);
      stream.removeListener('end', onevent);
      stream.removeListener('error', onevent);
      done();
    }
  };

  stream.removeListener('data', ondata);
  stream.removeListener('error', onerror);

  if (err) throw err;
  return data;
}

/**
 * Read from a readable streams2 `stream`.
 *
 * @param {Stream} stream
 * @return {Function}
 */

function read2(stream) {
  return function(done) {
    if (!stream.readable) {
      return done();
    }

    function onreadable() {
      cleanup();
      check();
    }

    function onend() {
      cleanup();
      done(null, null);
    }

    function onerror(err) {
      cleanup();
      done(err);
    }

    function listen() {
      stream.on('readable', onreadable);
      stream.on('end', onend);
      stream.on('error', onerror);
    }

    function cleanup() {
      stream.removeListener('readable', onreadable);
      stream.removeListener('end', onend);
      stream.removeListener('error', onerror);
    }

    function check() {
      var buf = stream.read();
      if (buf) {
        done(null, buf);
      } else {
        listen();
      }
    }

    check();
  };
}
