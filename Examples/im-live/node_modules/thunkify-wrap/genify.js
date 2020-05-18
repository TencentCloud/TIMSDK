/*!
 * node-thunkify-wrap - genify.js
 * Copyright(c) 2014 dead_horse <dead_horse@qq.com>
 * MIT Licensed
 */

'use strict';

/**
 * Module dependencies.
 */

module.exports = function createGenify(thunkify) {
  return function genify(fn, ctx) {
    if (isGeneratorFunction(fn)) {
      return fn;
    }

    function* genify() {
      var thunk = thunkify(fn);
      return yield thunk.apply(ctx || this, arguments);
    }
    return genify;
  };
};

function isGeneratorFunction(fn) {
  return typeof fn === 'function' && fn.constructor.name === 'GeneratorFunction';
}
