var assert = require('assert');
var absolute = require('../');

assert(absolute('/home/dave') === true);
assert(absolute('/something') === true);
assert(absolute('./myfile') === false);
assert(absolute('temp') === false);
