
# thunkify-wrap [![Build Status](https://secure.travis-ci.org/node-modules/node-thunkify-wrap.svg)](http://travis-ci.org/node-modules/node-thunkify-wrap)

  Turn each node function in an object return a thunk.
  Turn a regular node function into one which returns a thunk,
  useful for generator-based flow control such as [co](https://github.com/visionmedia/co).

## Installation

[![NPM](https://nodei.co/npm/thunkify-wrap.svg?downloads=true)](https://nodei.co/npm/thunkify-wrap/)

## Example

```js
// the same as thunkify
var thunkify = require('thunkify-wrap');
var fs = require('fs');

fs.readFile = thunkify(fs.readFile);

fs.readFile('package.json', 'utf8')(function(err, str){

});

// thunkfiy an object
var user = {
  add: function () {},
  show: function () {},
  list: function () {}
}

module.exports = thunkify(user);
// module.exports = thunkify(user, ['add', 'show']);
// module.exports = thunkify(user, 'add');
```

## genify

Wrap every function return a `GeneratorFunction`,
that will be easy to write codes in only one way: `yield* fn()`.

```js
var genify = require('thunkify-wrap').genify;
var fs = require('fs');

fs.readFile = genify(fs.readFile);

var content = yield* fs.readFile(__filename, 'utf8');
```

## event support

you can pass an event object, give end event name list, wrap event to thunk like this

```
var e = new EventEmitter();
var end = thunkify.event(e, 'finish');

yield end();
or
yield.end(['close', 'end']); // will cover `finish` event
```

when specified events emitted, this generator will go on. see more in the source code.

## ctx

also you can pass `ctx` as contenxt into thunkify, and `thunkify(object)` will use object as the context by default.

```js
var thunkify = require('thunkify-wrap');
var Cal = function (a, b) {
  this.a = a;
  this.b = b;
};

Cal.prototype.plus = function(callback) {
  var self = this;
  setTimeout(function () {
    callback(null, self.a + self.b);
  }, 5);
};

Cal.prototype.minus = function (callback) {
  var self = this;
  setTimeout(function () {
    callback(null, self.a - self.b);
  }, 5);
};

module.exports = Cal;

exports.create1 = function (a, b) {
  return thunkify(new Cal(a, b));
};

// or
exports.create2 = function (a, b) {
  var cal = new Cal(a, b);
  cal.plus = thunkify(cal.plus, cal);
  cal.minus = thunkify(cal.minus, cal);
};
```

### methods

by pass `methods` list, support only thunkify a part of methods in an object.

```
exports.create3 = function (a, b) {
  var cal = new Cal(a, b);
  thunkify(cal, cal, ['plus']);
  // or
  thunkify(cal, ['plus']);
};
```

# License

  MIT
