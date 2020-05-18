var path = require('path');

module.exports = path.isAbsolute ? path.isAbsolute.bind(path) : absolute;

function absolute(s) {
  return path.resolve(s) === s;
}
