/**!
 * enable - index.js
 *
 * Copyright(c) 2014 fengmk2 and other contributors.
 * MIT Licensed
 *
 * Authors:
 *   fengmk2 <fengmk2@gmail.com> (http://fengmk2.github.com)
 *   dead_horse <dead_horse@qq.com> (http://github.com/dead-horse)
 *   hemanth.hm <hemanth.hm@gmail.com> (http://h3manth.com)
 */

'use strict';

/**
* Helper functions.
*/

function isFunction(attr) {
  return typeof attr === 'function';
}

function isNumber(attr) {
  return typeof attr === 'number';
}

/**
 * Module dependencies.
 */

// generator

try {
  eval('(function* () {})()');
  exports.generator = true;
} catch (_) {
  exports.generator = false;
}

// let

try {
  eval('let a = 1;');
  exports.let = true;
} catch (_) {
  exports.let = false;
}

// const
try {
  eval('(function () { const fubar = 42; return typeof fubar === "number"; }())');
  exports.const = true;
} catch (_) {
  exports.const = false;
}

// Object.{is,assign,getOwnPropertySymbols,setPrototypeOf}
exports.Object = {
  is: isFunction(Object.is),
  assign: isFunction(Object.assign),
  getOwnPropertySymbols: isFunction(Object.getOwnPropertySymbols),
  setPrototypeOf: isFunction(Object.setPrototypeOf)
};

// String methods.
exports.String = {
  raw: isFunction(String.raw),
  fromCodePoint: isFunction(String.fromCodePoint),
  prototype:{
    codePointAt: isFunction(String.prototype.codePointAt),
    normalize: isFunction(String.prototype.normalize),
    repeat: isFunction(String.prototype.repeat),
    startsWith: isFunction(String.prototype.startsWith),
    endsWith: isFunction(String.prototype.endsWith),
    contains: isFunction(String.prototype.contains)
  }
};

exports.Number = {
  isFinite: isFunction(Number.isFinite),
  isInteger: isFunction(Number.isInteger),	
  isSafeInteger: isFunction(Number.isSafeInteger),
  isNaN: isFunction(Number.isNaN),
  EPSILON: isNumber(Number.EPSILON),
  MIN_SAFE_INTEGER: isNumber(Number.MIN_SAFE_INTEGER),
  MAX_SAFE_INTEGER: isNumber(Number.MAX_SAFE_INTEGER)
};

exports.Math = {
  clz32: isFunction(Math.clz32),
  imul: isFunction(Math.imul),
  sign: isFunction(Math.sign),
  log10: isFunction(Math.log10),
  log2: isFunction(Math.log2),
  log1p: isFunction(Math.log1p),
  expm1: isFunction(Math.expm1),
  cosh: isFunction(Math.cosh),
  sinh: isFunction(Math.sinh),
  tanh: isFunction(Math.tanh),	
  acosh: isFunction(Math.acosh),	
  asinh: isFunction(Math.asinh),	
  atanh: isFunction(Math.atanh),
  hypot: isFunction(Math.hypot),	
  trunc: isFunction(Math.trunc),	
  fround: isFunction(Math.fround),	
  cbrt: isFunction(Math.cbrt)
}