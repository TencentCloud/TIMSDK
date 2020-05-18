/**
 * Module Dependencies
 */

var co = require('co');
var slice = [].slice;

/**
 * Expose `unyield`
 */

module.exports = unyield;

/**
 * Unyield
 *
 * @param {Generator} gen
 * @return {Function}
 * @api public
 */

function unyield(gen) {
  return function() {
    var args = slice.call(arguments);
    var last = args[args.length - 1];
    var fn = 'function' == typeof last && last;

    return fn
      ? co(gen).apply(this, arguments)
      : gen.apply(this, arguments);
  }
}
