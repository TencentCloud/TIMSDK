
/**
 * Module dependencies.
 */

var thunkify = require('thunkify-wrap');
var stream = require('co-from-stream');
var methods = require('./methods');
var fs = require('fs-extra');


for (var key in fs) {
  exports[key] = fs[key];
}

// .exists is still messed

exports.exists = function (path) {
  return function (done) {
    fs.stat(path, function(err, res){
      done(null, !err);
    });
  };
};

// .createReadStream

exports.createReadStream = function () {
  return stream(fs.createReadStream.apply(null, arguments));
};

thunkify(module.exports, methods);
