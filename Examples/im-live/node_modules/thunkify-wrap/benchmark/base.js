/**!
 * node-thunkify-wrap - benchmark/base.js
 *
 * Copyright(c) fengmk2 and other contributors.
 * MIT Licensed
 *
 * Authors:
 *   fengmk2 <fengmk2@gmail.com> (http://fengmk2.github.com)
 */

'use strict';

/**
 * Module dependencies.
 */

var co = require('co');
var thunkify = require('../');

function async(foo, bar, callback) {
  setImmediate(function () {
    callback(null, {foo: foo, bar: bar});
  });
}

var n = 1000000;

var asyncThunk = thunkify(async);
var asyncGen = thunkify.genify(async);

console.log('\n  thunkify benchmark\n  node version: %s, date: %s\n  Starting...\n',
    process.version, Date());

co(function* () {
  var start = Date.now();
  for (var i = 0; i < n; i++) {
    yield asyncThunk('a', 1);
  }
  var use = Date.now() - start;
  console.log("  yield asyncThunk('a', 1) %d times, use: %sms, qps: %s", n, use, n / use * 1000);

  var start = Date.now();
  for (var i = 0; i < n; i++) {
    yield asyncGen('a', 1);
  }
  var use = Date.now() - start;
  console.log("  yield asyncGen('a', 1) %d times, use: %sms, qps: %s", n, use, n / use * 1000);

  var start = Date.now();
  for (var i = 0; i < n; i++) {
    yield* asyncGen('a', 1);
  }
  var use = Date.now() - start;
  console.log("  yield* asyncGen('a', 1) %d times, use: %sms, qps: %s", n, use, n / use * 1000);
})();

// $ node --harmony benchmark/base.js
//
//   thunkify benchmark
//   node version: v0.11.12, date: Thu Jul 10 2014 22:53:10 GMT+0800 (CST)
//   Starting...
//
//   yield asyncThunk('a', 1) 1000000 times, use: 5578ms, qps: 179275.72606669058
//   yield asyncGen('a', 1) 1000000 times, use: 12610ms, qps: 79302.14115781126
//   yield* asyncGen('a', 1) 1000000 times, use: 6817ms, qps: 146692.09329617134
