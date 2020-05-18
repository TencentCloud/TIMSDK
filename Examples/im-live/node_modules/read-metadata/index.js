
var fs = require('fs');
var extname = require('path').extname;
var yaml = require('yaml-js');

/**
 * Expose `readMetadata`.
 */

module.exports = exports = readMetadata;

/**
 * Read a metadata file by `path` and callback `done(err, obj)`.
 *
 * @param {String} path
 * @param {Function} done
 */

function readMetadata(path, done) {
  fs.readFile(path, 'utf-8', function(err, data){
    if (err) return done(err);
    var parse = parser(path);
    if (!parse) return done(new Error('Invalid metadata file type.'));
    done(null, parse(data));
  });
};

/**
 * Read a metadata file synchronously by `path`.
 *
 * @param {String} path
 * @return {Object}
 */

exports.sync = function(path) {
  var parse = parser(path);
  if (!parse) throw new Error('Invalid metadata file type.');
  var data = fs.readFileSync(path, 'utf-8');
  return parse(data);
};

/**
 * Return a parser for a given `file`.
 *
 * @param {String} file
 * @return {Function}
 */

function parser(file) {
  switch (extname(file)) {
    case '.json':
      return JSON.parse;
    case '.yaml':
    case '.yml':
      return yaml.load;
  }
}