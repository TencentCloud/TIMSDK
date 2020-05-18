
/**
 * Module dependencies.
 */

var read = require('co-read');

/**
 * Create a co generator stream from a node stream.
 *
 * @param {Stream} stream
 * @return {GeneratorFunction}
 * @api public
 */

module.exports = function(stream){
  return function*(end){
    if (end) {
      if (stream.end) stream.end();
      else if (stream.close) stream.close();
      else if (stream.destroy) stream.destroy();
      return;
    }
    return yield read(stream);
  };
};
