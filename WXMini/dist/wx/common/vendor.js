global.webpackJsonpMpvue([0],[
/* 0 */
/***/ (function(module, exports, __webpack_require__) {

/* WEBPACK VAR INJECTION */(function(global) {// fix env
try {
  if (!global) global = {};
  global.process = global.process || {};
  global.process.env = global.process.env || {};
  global.App = global.App || App;
  global.Page = global.Page || Page;
  global.Component = global.Component || Component;
  global.getApp = global.getApp || getApp;

  if (typeof wx !== 'undefined') {
    global.mpvue = wx;
    global.mpvuePlatform = 'wx';
  } else if (typeof swan !== 'undefined') {
    global.mpvue = swan;
    global.mpvuePlatform = 'swan';
  }else if (typeof tt !== 'undefined') {
    global.mpvue = tt;
    global.mpvuePlatform = 'tt';
  }else if (typeof my !== 'undefined') {
    global.mpvue = my;
    global.mpvuePlatform = 'my';
  }
} catch (e) {}

(function (global, factory) {
	 true ? module.exports = factory() :
	typeof define === 'function' && define.amd ? define(factory) :
	(global.Vue = factory());
}(this, (function () { 'use strict';

/*  */

// these helpers produces better vm code in JS engines due to their
// explicitness and function inlining
function isUndef (v) {
  return v === undefined || v === null
}

function isDef (v) {
  return v !== undefined && v !== null
}

function isTrue (v) {
  return v === true
}

function isFalse (v) {
  return v === false
}

/**
 * Check if value is primitive
 */
function isPrimitive (value) {
  return typeof value === 'string' || typeof value === 'number'
}

/**
 * Quick object check - this is primarily used to tell
 * Objects from primitive values when we know the value
 * is a JSON-compliant type.
 */
function isObject (obj) {
  return obj !== null && typeof obj === 'object'
}

var _toString = Object.prototype.toString;

/**
 * Strict object type check. Only returns true
 * for plain JavaScript objects.
 */
function isPlainObject (obj) {
  return _toString.call(obj) === '[object Object]'
}

function isRegExp (v) {
  return _toString.call(v) === '[object RegExp]'
}

/**
 * Check if val is a valid array index.
 */
function isValidArrayIndex (val) {
  var n = parseFloat(val);
  return n >= 0 && Math.floor(n) === n && isFinite(val)
}

/**
 * Convert a value to a string that is actually rendered.
 */
function toString (val) {
  return val == null
    ? ''
    : typeof val === 'object'
      ? JSON.stringify(val, null, 2)
      : String(val)
}

/**
 * Convert a input value to a number for persistence.
 * If the conversion fails, return original string.
 */
function toNumber (val) {
  var n = parseFloat(val);
  return isNaN(n) ? val : n
}

/**
 * Make a map and return a function for checking if a key
 * is in that map.
 */
function makeMap (
  str,
  expectsLowerCase
) {
  var map = Object.create(null);
  var list = str.split(',');
  for (var i = 0; i < list.length; i++) {
    map[list[i]] = true;
  }
  return expectsLowerCase
    ? function (val) { return map[val.toLowerCase()]; }
    : function (val) { return map[val]; }
}

/**
 * Check if a tag is a built-in tag.
 */
var isBuiltInTag = makeMap('slot,component', true);

/**
 * Check if a attribute is a reserved attribute.
 */
var isReservedAttribute = makeMap('key,ref,slot,is');

/**
 * Remove an item from an array
 */
function remove (arr, item) {
  if (arr.length) {
    var index = arr.indexOf(item);
    if (index > -1) {
      return arr.splice(index, 1)
    }
  }
}

/**
 * Check whether the object has the property.
 */
var hasOwnProperty = Object.prototype.hasOwnProperty;
function hasOwn (obj, key) {
  return hasOwnProperty.call(obj, key)
}

/**
 * Create a cached version of a pure function.
 */
function cached (fn) {
  var cache = Object.create(null);
  return (function cachedFn (str) {
    var hit = cache[str];
    return hit || (cache[str] = fn(str))
  })
}

/**
 * Camelize a hyphen-delimited string.
 */
var camelizeRE = /-(\w)/g;
var camelize = cached(function (str) {
  return str.replace(camelizeRE, function (_, c) { return c ? c.toUpperCase() : ''; })
});

/**
 * Capitalize a string.
 */
var capitalize = cached(function (str) {
  return str.charAt(0).toUpperCase() + str.slice(1)
});

/**
 * Hyphenate a camelCase string.
 */
var hyphenateRE = /([^-])([A-Z])/g;
var hyphenate = cached(function (str) {
  return str
    .replace(hyphenateRE, '$1-$2')
    .replace(hyphenateRE, '$1-$2')
    .toLowerCase()
});

/**
 * Simple bind, faster than native
 */
function bind (fn, ctx) {
  function boundFn (a) {
    var l = arguments.length;
    return l
      ? l > 1
        ? fn.apply(ctx, arguments)
        : fn.call(ctx, a)
      : fn.call(ctx)
  }
  // record original fn length
  boundFn._length = fn.length;
  return boundFn
}

/**
 * Convert an Array-like object to a real Array.
 */
function toArray (list, start) {
  start = start || 0;
  var i = list.length - start;
  var ret = new Array(i);
  while (i--) {
    ret[i] = list[i + start];
  }
  return ret
}

/**
 * Mix properties into target object.
 */
function extend (to, _from) {
  for (var key in _from) {
    to[key] = _from[key];
  }
  return to
}

/**
 * Merge an Array of Objects into a single Object.
 */
function toObject (arr) {
  var res = {};
  for (var i = 0; i < arr.length; i++) {
    if (arr[i]) {
      extend(res, arr[i]);
    }
  }
  return res
}

/**
 * Perform no operation.
 * Stubbing args to make Flow happy without leaving useless transpiled code
 * with ...rest (https://flow.org/blog/2017/05/07/Strict-Function-Call-Arity/)
 */
function noop (a, b, c) {}

/**
 * Always return false.
 */
var no = function (a, b, c) { return false; };

/**
 * Return same value
 */
var identity = function (_) { return _; };

/**
 * Generate a static keys string from compiler modules.
 */


/**
 * Check if two values are loosely equal - that is,
 * if they are plain objects, do they have the same shape?
 */
function looseEqual (a, b) {
  var isObjectA = isObject(a);
  var isObjectB = isObject(b);
  if (isObjectA && isObjectB) {
    try {
      return JSON.stringify(a) === JSON.stringify(b)
    } catch (e) {
      // possible circular reference
      return a === b
    }
  } else if (!isObjectA && !isObjectB) {
    return String(a) === String(b)
  } else {
    return false
  }
}

function looseIndexOf (arr, val) {
  for (var i = 0; i < arr.length; i++) {
    if (looseEqual(arr[i], val)) { return i }
  }
  return -1
}

/**
 * Ensure a function is called only once.
 */
function once (fn) {
  var called = false;
  return function () {
    if (!called) {
      called = true;
      fn.apply(this, arguments);
    }
  }
}

var SSR_ATTR = 'data-server-rendered';

var ASSET_TYPES = [
  'component',
  'directive',
  'filter'
];

var LIFECYCLE_HOOKS = [
  'beforeCreate',
  'created',
  'beforeMount',
  'mounted',
  'beforeUpdate',
  'updated',
  'beforeDestroy',
  'destroyed',
  'activated',
  'deactivated', 'onLaunch',
  'onLoad',
  'onShow',
  'onReady',
  'onHide',
  'onUnload',
  'onPullDownRefresh',
  'onReachBottom',
  'onShareAppMessage',
  'onPageScroll',
  'onTabItemTap',
  'attached',
  'ready',
  'moved',
  'detached'
];

/*  */

var config = ({
  /**
   * Option merge strategies (used in core/util/options)
   */
  optionMergeStrategies: Object.create(null),

  /**
   * Whether to suppress warnings.
   */
  silent: false,

  /**
   * Show production mode tip message on boot?
   */
  productionTip: "production" !== 'production',

  /**
   * Whether to enable devtools
   */
  devtools: "production" !== 'production',

  /**
   * Whether to record perf
   */
  performance: false,

  /**
   * Error handler for watcher errors
   */
  errorHandler: null,

  /**
   * Warn handler for watcher warns
   */
  warnHandler: null,

  /**
   * Ignore certain custom elements
   */
  ignoredElements: [],

  /**
   * Custom user key aliases for v-on
   */
  keyCodes: Object.create(null),

  /**
   * Check if a tag is reserved so that it cannot be registered as a
   * component. This is platform-dependent and may be overwritten.
   */
  isReservedTag: no,

  /**
   * Check if an attribute is reserved so that it cannot be used as a component
   * prop. This is platform-dependent and may be overwritten.
   */
  isReservedAttr: no,

  /**
   * Check if a tag is an unknown element.
   * Platform-dependent.
   */
  isUnknownElement: no,

  /**
   * Get the namespace of an element
   */
  getTagNamespace: noop,

  /**
   * Parse the real tag name for the specific platform.
   */
  parsePlatformTagName: identity,

  /**
   * Check if an attribute must be bound using property, e.g. value
   * Platform-dependent.
   */
  mustUseProp: no,

  /**
   * Exposed for legacy reasons
   */
  _lifecycleHooks: LIFECYCLE_HOOKS
});

/*  */

var emptyObject = Object.freeze({});

/**
 * Check if a string starts with $ or _
 */
function isReserved (str) {
  var c = (str + '').charCodeAt(0);
  return c === 0x24 || c === 0x5F
}

/**
 * Define a property.
 */
function def (obj, key, val, enumerable) {
  Object.defineProperty(obj, key, {
    value: val,
    enumerable: !!enumerable,
    writable: true,
    configurable: true
  });
}

/**
 * Parse simple path.
 */
var bailRE = /[^\w.$]/;
function parsePath (path) {
  if (bailRE.test(path)) {
    return
  }
  var segments = path.split('.');
  return function (obj) {
    for (var i = 0; i < segments.length; i++) {
      if (!obj) { return }
      obj = obj[segments[i]];
    }
    return obj
  }
}

/*  */

var warn = noop;

var formatComponentName = (null); // work around flow check

/*  */

function handleError (err, vm, info) {
  if (config.errorHandler) {
    config.errorHandler.call(null, err, vm, info);
  } else {
    if (inBrowser && typeof console !== 'undefined') {
      console.error(err);
    } else {
      throw err
    }
  }
}

/*  */

// can we use __proto__?
var hasProto = '__proto__' in {};

// Browser environment sniffing
var inBrowser = typeof window !== 'undefined';
var UA = ['mpvue-runtime'].join();
var isIE = UA && /msie|trident/.test(UA);
var isIE9 = UA && UA.indexOf('msie 9.0') > 0;
var isEdge = UA && UA.indexOf('edge/') > 0;
var isAndroid = UA && UA.indexOf('android') > 0;
var isIOS = UA && /iphone|ipad|ipod|ios/.test(UA);
var isChrome = UA && /chrome\/\d+/.test(UA) && !isEdge;

// Firefix has a "watch" function on Object.prototype...
var nativeWatch = ({}).watch;

var supportsPassive = false;
if (inBrowser) {
  try {
    var opts = {};
    Object.defineProperty(opts, 'passive', ({
      get: function get () {
        /* istanbul ignore next */
        supportsPassive = true;
      }
    })); // https://github.com/facebook/flow/issues/285
    window.addEventListener('test-passive', null, opts);
  } catch (e) {}
}

// this needs to be lazy-evaled because vue may be required before
// vue-server-renderer can set VUE_ENV
var _isServer;
var isServerRendering = function () {
  if (_isServer === undefined) {
    /* istanbul ignore if */
    if (!inBrowser && typeof global !== 'undefined') {
      // detect presence of vue-server-renderer and avoid
      // Webpack shimming the process
      _isServer = global['process'].env.VUE_ENV === 'server';
    } else {
      _isServer = false;
    }
  }
  return _isServer
};

// detect devtools
var devtools = inBrowser && window.__VUE_DEVTOOLS_GLOBAL_HOOK__;

/* istanbul ignore next */
function isNative (Ctor) {
  return typeof Ctor === 'function' && /native code/.test(Ctor.toString())
}

var hasSymbol =
  typeof Symbol !== 'undefined' && isNative(Symbol) &&
  typeof Reflect !== 'undefined' && isNative(Reflect.ownKeys);

/**
 * Defer a task to execute it asynchronously.
 */
var nextTick = (function () {
  var callbacks = [];
  var pending = false;
  var timerFunc;

  function nextTickHandler () {
    pending = false;
    var copies = callbacks.slice(0);
    callbacks.length = 0;
    for (var i = 0; i < copies.length; i++) {
      copies[i]();
    }
  }

  // the nextTick behavior leverages the microtask queue, which can be accessed
  // via either native Promise.then or MutationObserver.
  // MutationObserver has wider support, however it is seriously bugged in
  // UIWebView in iOS >= 9.3.3 when triggered in touch event handlers. It
  // completely stops working after triggering a few times... so, if native
  // Promise is available, we will use it:
  /* istanbul ignore if */
  if (typeof Promise !== 'undefined' && isNative(Promise)) {
    var p = Promise.resolve();
    var logError = function (err) { console.error(err); };
    timerFunc = function () {
      p.then(nextTickHandler).catch(logError);
      // in problematic UIWebViews, Promise.then doesn't completely break, but
      // it can get stuck in a weird state where callbacks are pushed into the
      // microtask queue but the queue isn't being flushed, until the browser
      // needs to do some other work, e.g. handle a timer. Therefore we can
      // "force" the microtask queue to be flushed by adding an empty timer.
      if (isIOS) { setTimeout(noop); }
    };
  // } else if (typeof MutationObserver !== 'undefined' && (
  //   isNative(MutationObserver) ||
  //   // PhantomJS and iOS 7.x
  //   MutationObserver.toString() === '[object MutationObserverConstructor]'
  // )) {
  //   // use MutationObserver where native Promise is not available,
  //   // e.g. PhantomJS IE11, iOS7, Android 4.4
  //   var counter = 1
  //   var observer = new MutationObserver(nextTickHandler)
  //   var textNode = document.createTextNode(String(counter))
  //   observer.observe(textNode, {
  //     characterData: true
  //   })
  //   timerFunc = () => {
  //     counter = (counter + 1) % 2
  //     textNode.data = String(counter)
  //   }
  } else {
    // fallback to setTimeout
    /* istanbul ignore next */
    timerFunc = function () {
      setTimeout(nextTickHandler, 0);
    };
  }

  return function queueNextTick (cb, ctx) {
    var _resolve;
    callbacks.push(function () {
      if (cb) {
        try {
          cb.call(ctx);
        } catch (e) {
          handleError(e, ctx, 'nextTick');
        }
      } else if (_resolve) {
        _resolve(ctx);
      }
    });
    if (!pending) {
      pending = true;
      timerFunc();
    }
    if (!cb && typeof Promise !== 'undefined') {
      return new Promise(function (resolve, reject) {
        _resolve = resolve;
      })
    }
  }
})();

var _Set;
/* istanbul ignore if */
if (typeof Set !== 'undefined' && isNative(Set)) {
  // use native Set when available.
  _Set = Set;
} else {
  // a non-standard Set polyfill that only works with primitive keys.
  _Set = (function () {
    function Set () {
      this.set = Object.create(null);
    }
    Set.prototype.has = function has (key) {
      return this.set[key] === true
    };
    Set.prototype.add = function add (key) {
      this.set[key] = true;
    };
    Set.prototype.clear = function clear () {
      this.set = Object.create(null);
    };

    return Set;
  }());
}

/*  */


var uid$1 = 0;

/**
 * A dep is an observable that can have multiple
 * directives subscribing to it.
 */
var Dep = function Dep () {
  this.id = uid$1++;
  this.subs = [];
};

Dep.prototype.addSub = function addSub (sub) {
  this.subs.push(sub);
};

Dep.prototype.removeSub = function removeSub (sub) {
  remove(this.subs, sub);
};

Dep.prototype.depend = function depend () {
  if (Dep.target) {
    Dep.target.addDep(this);
  }
};

Dep.prototype.notify = function notify () {
  // stabilize the subscriber list first
  var subs = this.subs.slice();
  for (var i = 0, l = subs.length; i < l; i++) {
    subs[i].update();
  }
};

// the current target watcher being evaluated.
// this is globally unique because there could be only one
// watcher being evaluated at any time.
Dep.target = null;
var targetStack = [];

function pushTarget (_target) {
  if (Dep.target) { targetStack.push(Dep.target); }
  Dep.target = _target;
}

function popTarget () {
  Dep.target = targetStack.pop();
}

/*
 * not type checking this file because flow doesn't play well with
 * dynamically accessing methods on Array prototype
 */

var arrayProto = Array.prototype;
var arrayMethods = Object.create(arrayProto);[
  'push',
  'pop',
  'shift',
  'unshift',
  'splice',
  'sort',
  'reverse'
]
.forEach(function (method) {
  // cache original method
  var original = arrayProto[method];
  def(arrayMethods, method, function mutator () {
    var args = [], len = arguments.length;
    while ( len-- ) args[ len ] = arguments[ len ];

    var result = original.apply(this, args);
    var ob = this.__ob__;
    var inserted;
    switch (method) {
      case 'push':
      case 'unshift':
        inserted = args;
        break
      case 'splice':
        inserted = args.slice(2);
        break
    }
    if (inserted) { ob.observeArray(inserted); }
    // notify change
    ob.dep.notify();
    return result
  });
});

/*  */

var arrayKeys = Object.getOwnPropertyNames(arrayMethods);

/**
 * By default, when a reactive property is set, the new value is
 * also converted to become reactive. However when passing down props,
 * we don't want to force conversion because the value may be a nested value
 * under a frozen data structure. Converting it would defeat the optimization.
 */
var observerState = {
  shouldConvert: true
};

/**
 * Observer class that are attached to each observed
 * object. Once attached, the observer converts target
 * object's property keys into getter/setters that
 * collect dependencies and dispatches updates.
 */
var Observer = function Observer (value, key) {
  this.value = value;
  this.dep = new Dep();
  this.vmCount = 0;
  if (key) {
    this.key = key;
  }
  def(value, '__ob__', this);
  if (Array.isArray(value)) {
    var augment = hasProto
      ? protoAugment
      : copyAugment;
    augment(value, arrayMethods, arrayKeys);
    this.observeArray(value);
  } else {
    this.walk(value);
  }
};

/**
 * Walk through each property and convert them into
 * getter/setters. This method should only be called when
 * value type is Object.
 */
Observer.prototype.walk = function walk (obj) {
  var keys = Object.keys(obj);
  for (var i = 0; i < keys.length; i++) {
    defineReactive$$1(obj, keys[i], obj[keys[i]]);
  }
};

/**
 * Observe a list of Array items.
 */
Observer.prototype.observeArray = function observeArray (items) {
  for (var i = 0, l = items.length; i < l; i++) {
    observe(items[i]);
  }
};

// helpers

/**
 * Augment an target Object or Array by intercepting
 * the prototype chain using __proto__
 */
function protoAugment (target, src, keys) {
  /* eslint-disable no-proto */
  target.__proto__ = src;
  /* eslint-enable no-proto */
}

/**
 * Augment an target Object or Array by defining
 * hidden properties.
 */
/* istanbul ignore next */
function copyAugment (target, src, keys) {
  for (var i = 0, l = keys.length; i < l; i++) {
    var key = keys[i];
    def(target, key, src[key]);
  }
}

/**
 * Attempt to create an observer instance for a value,
 * returns the new observer if successfully observed,
 * or the existing observer if the value already has one.
 */
function observe (value, asRootData, key) {
  if (!isObject(value)) {
    return
  }
  var ob;
  if (hasOwn(value, '__ob__') && value.__ob__ instanceof Observer) {
    ob = value.__ob__;
  } else if (
    observerState.shouldConvert &&
    !isServerRendering() &&
    (Array.isArray(value) || isPlainObject(value)) &&
    Object.isExtensible(value) &&
    !value._isVue
  ) {
    ob = new Observer(value, key);
  }
  if (asRootData && ob) {
    ob.vmCount++;
  }
  return ob
}

/**
 * Define a reactive property on an Object.
 */
function defineReactive$$1 (
  obj,
  key,
  val,
  customSetter,
  shallow
) {
  var dep = new Dep();

  var property = Object.getOwnPropertyDescriptor(obj, key);
  if (property && property.configurable === false) {
    return
  }

  // cater for pre-defined getter/setters
  var getter = property && property.get;
  var setter = property && property.set;

  var childOb = !shallow && observe(val, undefined, key);
  Object.defineProperty(obj, key, {
    enumerable: true,
    configurable: true,
    get: function reactiveGetter () {
      var value = getter ? getter.call(obj) : val;
      if (Dep.target) {
        dep.depend();
        if (childOb) {
          childOb.dep.depend();
        }
        if (Array.isArray(value)) {
          dependArray(value);
        }
      }
      return value
    },
    set: function reactiveSetter (newVal) {
      var value = getter ? getter.call(obj) : val;
      /* eslint-disable no-self-compare */
      if (newVal === value || (newVal !== newVal && value !== value)) {
        return
      }

      /* eslint-enable no-self-compare */
      if (false) {
        customSetter();
      }
      if (setter) {
        setter.call(obj, newVal);
      } else {
        val = newVal;
      }
      childOb = !shallow && observe(newVal, undefined, key);
      dep.notify();

      if (!obj.__keyPath) {
        def(obj, '__keyPath', {}, false);
      }
      obj.__keyPath[key] = true;
      if (newVal instanceof Object && !(newVal instanceof Array)) {
        // 标记是否是通过this.Obj = {} 赋值印发的改动，解决少更新问题#1305
        def(newVal, '__newReference', true, false);
      }
    }
  });
}

/**
 * Set a property on an object. Adds the new property and
 * triggers change notification if the property doesn't
 * already exist.
 */
function set (target, key, val) {
  if (Array.isArray(target) && isValidArrayIndex(key)) {
    target.length = Math.max(target.length, key);
    target.splice(key, 1, val);
    return val
  }
  if (hasOwn(target, key)) {
    target[key] = val;
    return val
  }
  var ob = (target).__ob__;
  if (target._isVue || (ob && ob.vmCount)) {
    "production" !== 'production' && warn(
      'Avoid adding reactive properties to a Vue instance or its root $data ' +
      'at runtime - declare it upfront in the data option.'
    );
    return val
  }
  if (!ob) {
    target[key] = val;
    return val
  }
  defineReactive$$1(ob.value, key, val);
  // Vue.set 添加对象属性，渲染时候把 val 传给小程序渲染
  if (!target.__keyPath) {
    def(target, '__keyPath', {}, false);
  }
  target.__keyPath[key] = true;
  ob.dep.notify();
  return val
}

/**
 * Delete a property and trigger change if necessary.
 */
function del (target, key) {
  if (Array.isArray(target) && isValidArrayIndex(key)) {
    target.splice(key, 1);
    return
  }
  var ob = (target).__ob__;
  if (target._isVue || (ob && ob.vmCount)) {
    "production" !== 'production' && warn(
      'Avoid deleting properties on a Vue instance or its root $data ' +
      '- just set it to null.'
    );
    return
  }
  if (!hasOwn(target, key)) {
    return
  }
  delete target[key];
  if (!ob) {
    return
  }
  if (!target.__keyPath) {
    def(target, '__keyPath', {}, false);
  }
  // Vue.del 删除对象属性，渲染时候把这个属性设置为 undefined
  target.__keyPath[key] = 'del';
  ob.dep.notify();
}

/**
 * Collect dependencies on array elements when the array is touched, since
 * we cannot intercept array element access like property getters.
 */
function dependArray (value) {
  for (var e = (void 0), i = 0, l = value.length; i < l; i++) {
    e = value[i];
    e && e.__ob__ && e.__ob__.dep.depend();
    if (Array.isArray(e)) {
      dependArray(e);
    }
  }
}

/*  */

/**
 * Option overwriting strategies are functions that handle
 * how to merge a parent option value and a child option
 * value into the final value.
 */
var strats = config.optionMergeStrategies;

/**
 * Options with restrictions
 */
/**
 * Helper that recursively merges two data objects together.
 */
function mergeData (to, from) {
  if (!from) { return to }
  var key, toVal, fromVal;
  var keys = Object.keys(from);
  for (var i = 0; i < keys.length; i++) {
    key = keys[i];
    toVal = to[key];
    fromVal = from[key];
    if (!hasOwn(to, key)) {
      set(to, key, fromVal);
    } else if (isPlainObject(toVal) && isPlainObject(fromVal)) {
      mergeData(toVal, fromVal);
    }
  }
  return to
}

/**
 * Data
 */
function mergeDataOrFn (
  parentVal,
  childVal,
  vm
) {
  if (!vm) {
    // in a Vue.extend merge, both should be functions
    if (!childVal) {
      return parentVal
    }
    if (!parentVal) {
      return childVal
    }
    // when parentVal & childVal are both present,
    // we need to return a function that returns the
    // merged result of both functions... no need to
    // check if parentVal is a function here because
    // it has to be a function to pass previous merges.
    return function mergedDataFn () {
      return mergeData(
        typeof childVal === 'function' ? childVal.call(this) : childVal,
        parentVal.call(this)
      )
    }
  } else if (parentVal || childVal) {
    return function mergedInstanceDataFn () {
      // instance merge
      var instanceData = typeof childVal === 'function'
        ? childVal.call(vm)
        : childVal;
      var defaultData = typeof parentVal === 'function'
        ? parentVal.call(vm)
        : undefined;
      if (instanceData) {
        return mergeData(instanceData, defaultData)
      } else {
        return defaultData
      }
    }
  }
}

strats.data = function (
  parentVal,
  childVal,
  vm
) {
  if (!vm) {
    if (childVal && typeof childVal !== 'function') {
      "production" !== 'production' && warn(
        'The "data" option should be a function ' +
        'that returns a per-instance value in component ' +
        'definitions.',
        vm
      );

      return parentVal
    }
    return mergeDataOrFn.call(this, parentVal, childVal)
  }

  return mergeDataOrFn(parentVal, childVal, vm)
};

/**
 * Hooks and props are merged as arrays.
 */
function mergeHook (
  parentVal,
  childVal
) {
  return childVal
    ? parentVal
      ? parentVal.concat(childVal)
      : Array.isArray(childVal)
        ? childVal
        : [childVal]
    : parentVal
}

LIFECYCLE_HOOKS.forEach(function (hook) {
  strats[hook] = mergeHook;
});

/**
 * Assets
 *
 * When a vm is present (instance creation), we need to do
 * a three-way merge between constructor options, instance
 * options and parent options.
 */
function mergeAssets (parentVal, childVal) {
  var res = Object.create(parentVal || null);
  return childVal
    ? extend(res, childVal)
    : res
}

ASSET_TYPES.forEach(function (type) {
  strats[type + 's'] = mergeAssets;
});

/**
 * Watchers.
 *
 * Watchers hashes should not overwrite one
 * another, so we merge them as arrays.
 */
strats.watch = function (parentVal, childVal) {
  // work around Firefox's Object.prototype.watch...
  if (parentVal === nativeWatch) { parentVal = undefined; }
  if (childVal === nativeWatch) { childVal = undefined; }
  /* istanbul ignore if */
  if (!childVal) { return Object.create(parentVal || null) }
  if (!parentVal) { return childVal }
  var ret = {};
  extend(ret, parentVal);
  for (var key in childVal) {
    var parent = ret[key];
    var child = childVal[key];
    if (parent && !Array.isArray(parent)) {
      parent = [parent];
    }
    ret[key] = parent
      ? parent.concat(child)
      : Array.isArray(child) ? child : [child];
  }
  return ret
};

/**
 * Other object hashes.
 */
strats.props =
strats.methods =
strats.inject =
strats.computed = function (parentVal, childVal) {
  if (!childVal) { return Object.create(parentVal || null) }
  if (!parentVal) { return childVal }
  var ret = Object.create(null);
  extend(ret, parentVal);
  extend(ret, childVal);
  return ret
};
strats.provide = mergeDataOrFn;

/**
 * Default strategy.
 */
var defaultStrat = function (parentVal, childVal) {
  return childVal === undefined
    ? parentVal
    : childVal
};

/**
 * Ensure all props option syntax are normalized into the
 * Object-based format.
 */
function normalizeProps (options) {
  var props = options.props;
  if (!props) { return }
  var res = {};
  var i, val, name;
  if (Array.isArray(props)) {
    i = props.length;
    while (i--) {
      val = props[i];
      if (typeof val === 'string') {
        name = camelize(val);
        res[name] = { type: null };
      } else {}
    }
  } else if (isPlainObject(props)) {
    for (var key in props) {
      val = props[key];
      name = camelize(key);
      res[name] = isPlainObject(val)
        ? val
        : { type: val };
    }
  }
  options.props = res;
}

/**
 * Normalize all injections into Object-based format
 */
function normalizeInject (options) {
  var inject = options.inject;
  if (Array.isArray(inject)) {
    var normalized = options.inject = {};
    for (var i = 0; i < inject.length; i++) {
      normalized[inject[i]] = inject[i];
    }
  }
}

/**
 * Normalize raw function directives into object format.
 */
function normalizeDirectives (options) {
  var dirs = options.directives;
  if (dirs) {
    for (var key in dirs) {
      var def = dirs[key];
      if (typeof def === 'function') {
        dirs[key] = { bind: def, update: def };
      }
    }
  }
}

/**
 * Merge two option objects into a new one.
 * Core utility used in both instantiation and inheritance.
 */
function mergeOptions (
  parent,
  child,
  vm
) {
  if (typeof child === 'function') {
    child = child.options;
  }

  normalizeProps(child);
  normalizeInject(child);
  normalizeDirectives(child);
  var extendsFrom = child.extends;
  if (extendsFrom) {
    parent = mergeOptions(parent, extendsFrom, vm);
  }
  if (child.mixins) {
    for (var i = 0, l = child.mixins.length; i < l; i++) {
      parent = mergeOptions(parent, child.mixins[i], vm);
    }
  }
  var options = {};
  var key;
  for (key in parent) {
    mergeField(key);
  }
  for (key in child) {
    if (!hasOwn(parent, key)) {
      mergeField(key);
    }
  }
  function mergeField (key) {
    var strat = strats[key] || defaultStrat;
    options[key] = strat(parent[key], child[key], vm, key);
  }
  return options
}

/**
 * Resolve an asset.
 * This function is used because child instances need access
 * to assets defined in its ancestor chain.
 */
function resolveAsset (
  options,
  type,
  id,
  warnMissing
) {
  /* istanbul ignore if */
  if (typeof id !== 'string') {
    return
  }
  var assets = options[type];
  // check local registration variations first
  if (hasOwn(assets, id)) { return assets[id] }
  var camelizedId = camelize(id);
  if (hasOwn(assets, camelizedId)) { return assets[camelizedId] }
  var PascalCaseId = capitalize(camelizedId);
  if (hasOwn(assets, PascalCaseId)) { return assets[PascalCaseId] }
  // fallback to prototype chain
  var res = assets[id] || assets[camelizedId] || assets[PascalCaseId];
  if (false) {
    warn(
      'Failed to resolve ' + type.slice(0, -1) + ': ' + id,
      options
    );
  }
  return res
}

/*  */

function validateProp (
  key,
  propOptions,
  propsData,
  vm
) {
  var prop = propOptions[key];
  var absent = !hasOwn(propsData, key);
  var value = propsData[key];
  // handle boolean props
  if (isType(Boolean, prop.type)) {
    if (absent && !hasOwn(prop, 'default')) {
      value = false;
    } else if (!isType(String, prop.type) && (value === '' || value === hyphenate(key))) {
      value = true;
    }
  }
  // check default value
  if (value === undefined) {
    value = getPropDefaultValue(vm, prop, key);
    // since the default value is a fresh copy,
    // make sure to observe it.
    var prevShouldConvert = observerState.shouldConvert;
    observerState.shouldConvert = true;
    observe(value);
    observerState.shouldConvert = prevShouldConvert;
  }
  return value
}

/**
 * Get the default value of a prop.
 */
function getPropDefaultValue (vm, prop, key) {
  // no default, return undefined
  if (!hasOwn(prop, 'default')) {
    return undefined
  }
  var def = prop.default;
  // warn against non-factory defaults for Object & Array
  if (false) {
    warn(
      'Invalid default value for prop "' + key + '": ' +
      'Props with type Object/Array must use a factory function ' +
      'to return the default value.',
      vm
    );
  }
  // the raw prop value was also undefined from previous render,
  // return previous default value to avoid unnecessary watcher trigger
  if (vm && vm.$options.propsData &&
    vm.$options.propsData[key] === undefined &&
    vm._props[key] !== undefined
  ) {
    return vm._props[key]
  }
  // call factory function for non-Function types
  // a value is Function if its prototype is function even across different execution context
  return typeof def === 'function' && getType(prop.type) !== 'Function'
    ? def.call(vm)
    : def
}

/**
 * Use function string name to check built-in types,
 * because a simple equality check will fail when running
 * across different vms / iframes.
 */
function getType (fn) {
  var match = fn && fn.toString().match(/^\s*function (\w+)/);
  return match ? match[1] : ''
}

function isType (type, fn) {
  if (!Array.isArray(fn)) {
    return getType(fn) === getType(type)
  }
  for (var i = 0, len = fn.length; i < len; i++) {
    if (getType(fn[i]) === getType(type)) {
      return true
    }
  }
  /* istanbul ignore next */
  return false
}

/*  */

/* not type checking this file because flow doesn't play well with Proxy */

var mark;
var measure;

/*  */

var VNode = function VNode (
  tag,
  data,
  children,
  text,
  elm,
  context,
  componentOptions,
  asyncFactory
) {
  this.tag = tag;
  this.data = data;
  this.children = children;
  this.text = text;
  this.elm = elm;
  this.ns = undefined;
  this.context = context;
  this.functionalContext = undefined;
  this.key = data && data.key;
  this.componentOptions = componentOptions;
  this.componentInstance = undefined;
  this.parent = undefined;
  this.raw = false;
  this.isStatic = false;
  this.isRootInsert = true;
  this.isComment = false;
  this.isCloned = false;
  this.isOnce = false;
  this.asyncFactory = asyncFactory;
  this.asyncMeta = undefined;
  this.isAsyncPlaceholder = false;
};

var prototypeAccessors = { child: {} };

// DEPRECATED: alias for componentInstance for backwards compat.
/* istanbul ignore next */
prototypeAccessors.child.get = function () {
  return this.componentInstance
};

Object.defineProperties( VNode.prototype, prototypeAccessors );

var createEmptyVNode = function (text) {
  if ( text === void 0 ) text = '';

  var node = new VNode();
  node.text = text;
  node.isComment = true;
  return node
};

function createTextVNode (val) {
  return new VNode(undefined, undefined, undefined, String(val))
}

// optimized shallow clone
// used for static nodes and slot nodes because they may be reused across
// multiple renders, cloning them avoids errors when DOM manipulations rely
// on their elm reference.
function cloneVNode (vnode) {
  var cloned = new VNode(
    vnode.tag,
    vnode.data,
    vnode.children,
    vnode.text,
    vnode.elm,
    vnode.context,
    vnode.componentOptions,
    vnode.asyncFactory
  );
  cloned.ns = vnode.ns;
  cloned.isStatic = vnode.isStatic;
  cloned.key = vnode.key;
  cloned.isComment = vnode.isComment;
  cloned.isCloned = true;
  return cloned
}

function cloneVNodes (vnodes) {
  var len = vnodes.length;
  var res = new Array(len);
  for (var i = 0; i < len; i++) {
    res[i] = cloneVNode(vnodes[i]);
  }
  return res
}

/*  */

var normalizeEvent = cached(function (name) {
  var passive = name.charAt(0) === '&';
  name = passive ? name.slice(1) : name;
  var once$$1 = name.charAt(0) === '~'; // Prefixed last, checked first
  name = once$$1 ? name.slice(1) : name;
  var capture = name.charAt(0) === '!';
  name = capture ? name.slice(1) : name;
  return {
    name: name,
    once: once$$1,
    capture: capture,
    passive: passive
  }
});

function createFnInvoker (fns) {
  function invoker () {
    var arguments$1 = arguments;

    var fns = invoker.fns;
    if (Array.isArray(fns)) {
      var cloned = fns.slice();
      for (var i = 0; i < cloned.length; i++) {
        cloned[i].apply(null, arguments$1);
      }
    } else {
      // return handler return value for single handlers
      return fns.apply(null, arguments)
    }
  }
  invoker.fns = fns;
  return invoker
}

function updateListeners (
  on,
  oldOn,
  add,
  remove$$1,
  vm
) {
  var name, cur, old, event;
  for (name in on) {
    cur = on[name];
    old = oldOn[name];
    event = normalizeEvent(name);
    if (isUndef(cur)) {
      "production" !== 'production' && warn(
        "Invalid handler for event \"" + (event.name) + "\": got " + String(cur),
        vm
      );
    } else if (isUndef(old)) {
      if (isUndef(cur.fns)) {
        cur = on[name] = createFnInvoker(cur);
      }
      add(event.name, cur, event.once, event.capture, event.passive);
    } else if (cur !== old) {
      old.fns = cur;
      on[name] = old;
    }
  }
  for (name in oldOn) {
    if (isUndef(on[name])) {
      event = normalizeEvent(name);
      remove$$1(event.name, oldOn[name], event.capture);
    }
  }
}

/*  */

/*  */

function extractPropsFromVNodeData (
  data,
  Ctor,
  tag
) {
  // we are only extracting raw values here.
  // validation and default values are handled in the child
  // component itself.
  var propOptions = Ctor.options.props;
  if (isUndef(propOptions)) {
    return
  }
  var res = {};
  var attrs = data.attrs;
  var props = data.props;
  if (isDef(attrs) || isDef(props)) {
    for (var key in propOptions) {
      var altKey = hyphenate(key);
      checkProp(res, props, key, altKey, true) ||
      checkProp(res, attrs, key, altKey, false);
    }
  }
  return res
}

function checkProp (
  res,
  hash,
  key,
  altKey,
  preserve
) {
  if (isDef(hash)) {
    if (hasOwn(hash, key)) {
      res[key] = hash[key];
      if (!preserve) {
        delete hash[key];
      }
      return true
    } else if (hasOwn(hash, altKey)) {
      res[key] = hash[altKey];
      if (!preserve) {
        delete hash[altKey];
      }
      return true
    }
  }
  return false
}

/*  */

// The template compiler attempts to minimize the need for normalization by
// statically analyzing the template at compile time.
//
// For plain HTML markup, normalization can be completely skipped because the
// generated render function is guaranteed to return Array<VNode>. There are
// two cases where extra normalization is needed:

// 1. When the children contains components - because a functional component
// may return an Array instead of a single root. In this case, just a simple
// normalization is needed - if any child is an Array, we flatten the whole
// thing with Array.prototype.concat. It is guaranteed to be only 1-level deep
// because functional components already normalize their own children.
function simpleNormalizeChildren (children) {
  for (var i = 0; i < children.length; i++) {
    if (Array.isArray(children[i])) {
      return Array.prototype.concat.apply([], children)
    }
  }
  return children
}

// 2. When the children contains constructs that always generated nested Arrays,
// e.g. <template>, <slot>, v-for, or when the children is provided by user
// with hand-written render functions / JSX. In such cases a full normalization
// is needed to cater to all possible types of children values.
function normalizeChildren (children) {
  return isPrimitive(children)
    ? [createTextVNode(children)]
    : Array.isArray(children)
      ? normalizeArrayChildren(children)
      : undefined
}

function isTextNode (node) {
  return isDef(node) && isDef(node.text) && isFalse(node.isComment)
}

function normalizeArrayChildren (children, nestedIndex) {
  var res = [];
  var i, c, last;
  for (i = 0; i < children.length; i++) {
    c = children[i];
    if (isUndef(c) || typeof c === 'boolean') { continue }
    last = res[res.length - 1];
    //  nested
    if (Array.isArray(c)) {
      res.push.apply(res, normalizeArrayChildren(c, ((nestedIndex || '') + "_" + i)));
    } else if (isPrimitive(c)) {
      if (isTextNode(last)) {
        // merge adjacent text nodes
        // this is necessary for SSR hydration because text nodes are
        // essentially merged when rendered to HTML strings
        (last).text += String(c);
      } else if (c !== '') {
        // convert primitive to vnode
        res.push(createTextVNode(c));
      }
    } else {
      if (isTextNode(c) && isTextNode(last)) {
        // merge adjacent text nodes
        res[res.length - 1] = createTextVNode(last.text + c.text);
      } else {
        // default key for nested array children (likely generated by v-for)
        if (isTrue(children._isVList) &&
          isDef(c.tag) &&
          isUndef(c.key) &&
          isDef(nestedIndex)) {
          c.key = "__vlist" + nestedIndex + "_" + i + "__";
        }
        res.push(c);
      }
    }
  }
  return res
}

/*  */

function ensureCtor (comp, base) {
  if (comp.__esModule && comp.default) {
    comp = comp.default;
  }
  return isObject(comp)
    ? base.extend(comp)
    : comp
}

function createAsyncPlaceholder (
  factory,
  data,
  context,
  children,
  tag
) {
  var node = createEmptyVNode();
  node.asyncFactory = factory;
  node.asyncMeta = { data: data, context: context, children: children, tag: tag };
  return node
}

function resolveAsyncComponent (
  factory,
  baseCtor,
  context
) {
  if (isTrue(factory.error) && isDef(factory.errorComp)) {
    return factory.errorComp
  }

  if (isDef(factory.resolved)) {
    return factory.resolved
  }

  if (isTrue(factory.loading) && isDef(factory.loadingComp)) {
    return factory.loadingComp
  }

  if (isDef(factory.contexts)) {
    // already pending
    factory.contexts.push(context);
  } else {
    var contexts = factory.contexts = [context];
    var sync = true;

    var forceRender = function () {
      for (var i = 0, l = contexts.length; i < l; i++) {
        contexts[i].$forceUpdate();
      }
    };

    var resolve = once(function (res) {
      // cache resolved
      factory.resolved = ensureCtor(res, baseCtor);
      // invoke callbacks only if this is not a synchronous resolve
      // (async resolves are shimmed as synchronous during SSR)
      if (!sync) {
        forceRender();
      }
    });

    var reject = once(function (reason) {
      "production" !== 'production' && warn(
        "Failed to resolve async component: " + (String(factory)) +
        (reason ? ("\nReason: " + reason) : '')
      );
      if (isDef(factory.errorComp)) {
        factory.error = true;
        forceRender();
      }
    });

    var res = factory(resolve, reject);

    if (isObject(res)) {
      if (typeof res.then === 'function') {
        // () => Promise
        if (isUndef(factory.resolved)) {
          res.then(resolve, reject);
        }
      } else if (isDef(res.component) && typeof res.component.then === 'function') {
        res.component.then(resolve, reject);

        if (isDef(res.error)) {
          factory.errorComp = ensureCtor(res.error, baseCtor);
        }

        if (isDef(res.loading)) {
          factory.loadingComp = ensureCtor(res.loading, baseCtor);
          if (res.delay === 0) {
            factory.loading = true;
          } else {
            setTimeout(function () {
              if (isUndef(factory.resolved) && isUndef(factory.error)) {
                factory.loading = true;
                forceRender();
              }
            }, res.delay || 200);
          }
        }

        if (isDef(res.timeout)) {
          setTimeout(function () {
            if (isUndef(factory.resolved)) {
              reject(
                null
              );
            }
          }, res.timeout);
        }
      }
    }

    sync = false;
    // return in case resolved synchronously
    return factory.loading
      ? factory.loadingComp
      : factory.resolved
  }
}

/*  */

function getFirstComponentChild (children) {
  if (Array.isArray(children)) {
    for (var i = 0; i < children.length; i++) {
      var c = children[i];
      if (isDef(c) && isDef(c.componentOptions)) {
        return c
      }
    }
  }
}

/*  */

/*  */

function initEvents (vm) {
  vm._events = Object.create(null);
  vm._hasHookEvent = false;
  // init parent attached events
  var listeners = vm.$options._parentListeners;
  if (listeners) {
    updateComponentListeners(vm, listeners);
  }
}

var target;

function add (event, fn, once$$1) {
  if (once$$1) {
    target.$once(event, fn);
  } else {
    target.$on(event, fn);
  }
}

function remove$1 (event, fn) {
  target.$off(event, fn);
}

function updateComponentListeners (
  vm,
  listeners,
  oldListeners
) {
  target = vm;
  updateListeners(listeners, oldListeners || {}, add, remove$1, vm);
}

function eventsMixin (Vue) {
  var hookRE = /^hook:/;
  Vue.prototype.$on = function (event, fn) {
    var this$1 = this;

    var vm = this;
    if (Array.isArray(event)) {
      for (var i = 0, l = event.length; i < l; i++) {
        this$1.$on(event[i], fn);
      }
    } else {
      (vm._events[event] || (vm._events[event] = [])).push(fn);
      // optimize hook:event cost by using a boolean flag marked at registration
      // instead of a hash lookup
      if (hookRE.test(event)) {
        vm._hasHookEvent = true;
      }
    }
    return vm
  };

  Vue.prototype.$once = function (event, fn) {
    var vm = this;
    function on () {
      vm.$off(event, on);
      fn.apply(vm, arguments);
    }
    on.fn = fn;
    vm.$on(event, on);
    return vm
  };

  Vue.prototype.$off = function (event, fn) {
    var this$1 = this;

    var vm = this;
    // all
    if (!arguments.length) {
      vm._events = Object.create(null);
      return vm
    }
    // array of events
    if (Array.isArray(event)) {
      for (var i$1 = 0, l = event.length; i$1 < l; i$1++) {
        this$1.$off(event[i$1], fn);
      }
      return vm
    }
    // specific event
    var cbs = vm._events[event];
    if (!cbs) {
      return vm
    }
    if (arguments.length === 1) {
      vm._events[event] = null;
      return vm
    }
    // specific handler
    var cb;
    var i = cbs.length;
    while (i--) {
      cb = cbs[i];
      if (cb === fn || cb.fn === fn) {
        cbs.splice(i, 1);
        break
      }
    }
    return vm
  };

  Vue.prototype.$emit = function (event) {
    var vm = this;
    var cbs = vm._events[event];
    if (cbs) {
      cbs = cbs.length > 1 ? toArray(cbs) : cbs;
      var args = toArray(arguments, 1);
      for (var i = 0, l = cbs.length; i < l; i++) {
        try {
          cbs[i].apply(vm, args);
        } catch (e) {
          handleError(e, vm, ("event handler for \"" + event + "\""));
        }
      }
    }
    return vm
  };
}

/*  */

/**
 * Runtime helper for resolving raw children VNodes into a slot object.
 */
function resolveSlots (
  children,
  context
) {
  var slots = {};
  if (!children) {
    return slots
  }
  var defaultSlot = [];
  for (var i = 0, l = children.length; i < l; i++) {
    var child = children[i];
    // named slots should only be respected if the vnode was rendered in the
    // same context.
    if ((child.context === context || child.functionalContext === context) &&
      child.data && child.data.slot != null
    ) {
      var name = child.data.slot;
      var slot = (slots[name] || (slots[name] = []));
      if (child.tag === 'template') {
        slot.push.apply(slot, child.children);
      } else {
        slot.push(child);
      }
    } else {
      defaultSlot.push(child);
    }
  }
  // ignore whitespace
  if (!defaultSlot.every(isWhitespace)) {
    slots.default = defaultSlot;
  }
  return slots
}

function isWhitespace (node) {
  return node.isComment || node.text === ' '
}

function resolveScopedSlots (
  fns, // see flow/vnode
  res
) {
  res = res || {};
  for (var i = 0; i < fns.length; i++) {
    if (Array.isArray(fns[i])) {
      resolveScopedSlots(fns[i], res);
    } else {
      res[fns[i].key] = fns[i].fn;
    }
  }
  return res
}

/*  */

var activeInstance = null;


function initLifecycle (vm) {
  var options = vm.$options;

  // locate first non-abstract parent
  var parent = options.parent;
  if (parent && !options.abstract) {
    while (parent.$options.abstract && parent.$parent) {
      parent = parent.$parent;
    }
    parent.$children.push(vm);
  }

  vm.$parent = parent;
  vm.$root = parent ? parent.$root : vm;

  vm.$children = [];
  vm.$refs = {};

  vm._watcher = null;
  vm._inactive = null;
  vm._directInactive = false;
  vm._isMounted = false;
  vm._isDestroyed = false;
  vm._isBeingDestroyed = false;
}

function lifecycleMixin (Vue) {
  Vue.prototype._update = function (vnode, hydrating) {
    var vm = this;
    if (vm._isMounted) {
      callHook(vm, 'beforeUpdate');
    }
    var prevEl = vm.$el;
    var prevVnode = vm._vnode;
    var prevActiveInstance = activeInstance;
    activeInstance = vm;
    vm._vnode = vnode;
    // Vue.prototype.__patch__ is injected in entry points
    // based on the rendering backend used.
    if (!prevVnode) {
      // initial render
      vm.$el = vm.__patch__(
        vm.$el, vnode, hydrating, false /* removeOnly */,
        vm.$options._parentElm,
        vm.$options._refElm
      );
      // no need for the ref nodes after initial patch
      // this prevents keeping a detached DOM tree in memory (#5851)
      vm.$options._parentElm = vm.$options._refElm = null;
    } else {
      // updates
      vm.$el = vm.__patch__(prevVnode, vnode);
    }
    activeInstance = prevActiveInstance;
    // update __vue__ reference
    if (prevEl) {
      prevEl.__vue__ = null;
    }
    if (vm.$el) {
      vm.$el.__vue__ = vm;
    }
    // if parent is an HOC, update its $el as well
    if (vm.$vnode && vm.$parent && vm.$vnode === vm.$parent._vnode) {
      vm.$parent.$el = vm.$el;
    }
    // updated hook is called by the scheduler to ensure that children are
    // updated in a parent's updated hook.
  };

  Vue.prototype.$forceUpdate = function () {
    var vm = this;
    if (vm._watcher) {
      vm._watcher.update();
    }
  };

  Vue.prototype.$destroy = function () {
    var vm = this;
    if (vm._isBeingDestroyed) {
      return
    }
    callHook(vm, 'beforeDestroy');
    vm._isBeingDestroyed = true;
    // remove self from parent
    var parent = vm.$parent;
    if (parent && !parent._isBeingDestroyed && !vm.$options.abstract) {
      remove(parent.$children, vm);
    }
    // teardown watchers
    if (vm._watcher) {
      vm._watcher.teardown();
    }
    var i = vm._watchers.length;
    while (i--) {
      vm._watchers[i].teardown();
    }
    // remove reference from data ob
    // frozen object may not have observer.
    if (vm._data.__ob__) {
      vm._data.__ob__.vmCount--;
    }
    // call the last hook...
    vm._isDestroyed = true;
    // invoke destroy hooks on current rendered tree
    vm.__patch__(vm._vnode, null);
    // fire destroyed hook
    callHook(vm, 'destroyed');
    // turn off all instance listeners.
    vm.$off();
    // remove __vue__ reference
    if (vm.$el) {
      vm.$el.__vue__ = null;
    }
  };
}

function mountComponent (
  vm,
  el,
  hydrating
) {
  vm.$el = el;
  if (!vm.$options.render) {
    vm.$options.render = createEmptyVNode;
    
  }
  callHook(vm, 'beforeMount');

  var updateComponent;
  /* istanbul ignore if */
  if (false) {
    updateComponent = function () {
      var name = vm._name;
      var id = vm._uid;
      var startTag = "vue-perf-start:" + id;
      var endTag = "vue-perf-end:" + id;

      mark(startTag);
      var vnode = vm._render();
      mark(endTag);
      measure((name + " render"), startTag, endTag);

      mark(startTag);
      vm._update(vnode, hydrating);
      mark(endTag);
      measure((name + " patch"), startTag, endTag);
    };
  } else {
    updateComponent = function () {
      vm._update(vm._render(), hydrating);
    };
  }

  vm._watcher = new Watcher(vm, updateComponent, noop);
  hydrating = false;

  // manually mounted instance, call mounted on self
  // mounted is called for render-created child components in its inserted hook
  if (vm.$vnode == null) {
    vm._isMounted = true;
    callHook(vm, 'mounted');
  }
  return vm
}

function updateChildComponent (
  vm,
  propsData,
  listeners,
  parentVnode,
  renderChildren
) {
  var hasChildren = !!(
    renderChildren ||               // has new static slots
    vm.$options._renderChildren ||  // has old static slots
    parentVnode.data.scopedSlots || // has new scoped slots
    vm.$scopedSlots !== emptyObject // has old scoped slots
  );

  vm.$options._parentVnode = parentVnode;
  vm.$vnode = parentVnode; // update vm's placeholder node without re-render

  if (vm._vnode) { // update child tree's parent
    vm._vnode.parent = parentVnode;
  }
  vm.$options._renderChildren = renderChildren;

  // update $attrs and $listensers hash
  // these are also reactive so they may trigger child update if the child
  // used them during render
  vm.$attrs = parentVnode.data && parentVnode.data.attrs;
  vm.$listeners = listeners;

  // update props
  if (propsData && vm.$options.props) {
    observerState.shouldConvert = false;
    var props = vm._props;
    var propKeys = vm.$options._propKeys || [];
    for (var i = 0; i < propKeys.length; i++) {
      var key = propKeys[i];
      props[key] = validateProp(key, vm.$options.props, propsData, vm);
    }
    observerState.shouldConvert = true;
    // keep a copy of raw propsData
    vm.$options.propsData = propsData;
  }

  // update listeners
  if (listeners) {
    var oldListeners = vm.$options._parentListeners;
    vm.$options._parentListeners = listeners;
    updateComponentListeners(vm, listeners, oldListeners);
  }
  // resolve slots + force update if has children
  if (hasChildren) {
    vm.$slots = resolveSlots(renderChildren, parentVnode.context);
    vm.$forceUpdate();
  }

  
}

function isInInactiveTree (vm) {
  while (vm && (vm = vm.$parent)) {
    if (vm._inactive) { return true }
  }
  return false
}

function activateChildComponent (vm, direct) {
  if (direct) {
    vm._directInactive = false;
    if (isInInactiveTree(vm)) {
      return
    }
  } else if (vm._directInactive) {
    return
  }
  if (vm._inactive || vm._inactive === null) {
    vm._inactive = false;
    for (var i = 0; i < vm.$children.length; i++) {
      activateChildComponent(vm.$children[i]);
    }
    callHook(vm, 'activated');
  }
}

function deactivateChildComponent (vm, direct) {
  if (direct) {
    vm._directInactive = true;
    if (isInInactiveTree(vm)) {
      return
    }
  }
  if (!vm._inactive) {
    vm._inactive = true;
    for (var i = 0; i < vm.$children.length; i++) {
      deactivateChildComponent(vm.$children[i]);
    }
    callHook(vm, 'deactivated');
  }
}

function callHook (vm, hook) {
  var handlers = vm.$options[hook];
  if (handlers) {
    for (var i = 0, j = handlers.length; i < j; i++) {
      try {
        handlers[i].call(vm);
      } catch (e) {
        handleError(e, vm, (hook + " hook"));
      }
    }
  }
  if (vm._hasHookEvent) {
    vm.$emit('hook:' + hook);
  }
}

/*  */


var MAX_UPDATE_COUNT = 100;

var queue = [];
var activatedChildren = [];
var has = {};
var circular = {};
var waiting = false;
var flushing = false;
var index = 0;

/**
 * Reset the scheduler's state.
 */
function resetSchedulerState () {
  index = queue.length = activatedChildren.length = 0;
  has = {};
  waiting = flushing = false;
}

/**
 * Flush both queues and run the watchers.
 */
function flushSchedulerQueue () {
  flushing = true;
  var watcher, id;

  // Sort queue before flush.
  // This ensures that:
  // 1. Components are updated from parent to child. (because parent is always
  //    created before the child)
  // 2. A component's user watchers are run before its render watcher (because
  //    user watchers are created before the render watcher)
  // 3. If a component is destroyed during a parent component's watcher run,
  //    its watchers can be skipped.
  queue.sort(function (a, b) { return a.id - b.id; });

  // do not cache length because more watchers might be pushed
  // as we run existing watchers
  for (index = 0; index < queue.length; index++) {
    watcher = queue[index];
    id = watcher.id;
    has[id] = null;
    watcher.run();
    // in dev build, check and stop circular updates.
    if (false) {
      circular[id] = (circular[id] || 0) + 1;
      if (circular[id] > MAX_UPDATE_COUNT) {
        warn(
          'You may have an infinite update loop ' + (
            watcher.user
              ? ("in watcher with expression \"" + (watcher.expression) + "\"")
              : "in a component render function."
          ),
          watcher.vm
        );
        break
      }
    }
  }

  // keep copies of post queues before resetting state
  var activatedQueue = activatedChildren.slice();
  var updatedQueue = queue.slice();

  resetSchedulerState();

  // call component updated and activated hooks
  callActivatedHooks(activatedQueue);
  callUpdatedHooks(updatedQueue);

  // devtool hook
  /* istanbul ignore if */
  if (devtools && config.devtools) {
    devtools.emit('flush');
  }
}

function callUpdatedHooks (queue) {
  var i = queue.length;
  while (i--) {
    var watcher = queue[i];
    var vm = watcher.vm;
    if (vm._watcher === watcher && vm._isMounted) {
      callHook(vm, 'updated');
    }
  }
}

/**
 * Queue a kept-alive component that was activated during patch.
 * The queue will be processed after the entire tree has been patched.
 */
function queueActivatedComponent (vm) {
  // setting _inactive to false here so that a render function can
  // rely on checking whether it's in an inactive tree (e.g. router-view)
  vm._inactive = false;
  activatedChildren.push(vm);
}

function callActivatedHooks (queue) {
  for (var i = 0; i < queue.length; i++) {
    queue[i]._inactive = true;
    activateChildComponent(queue[i], true /* true */);
  }
}

/**
 * Push a watcher into the watcher queue.
 * Jobs with duplicate IDs will be skipped unless it's
 * pushed when the queue is being flushed.
 */
function queueWatcher (watcher) {
  var id = watcher.id;
  if (has[id] == null) {
    has[id] = true;
    if (!flushing) {
      queue.push(watcher);
    } else {
      // if already flushing, splice the watcher based on its id
      // if already past its id, it will be run next immediately.
      var i = queue.length - 1;
      while (i > index && queue[i].id > watcher.id) {
        i--;
      }
      queue.splice(i + 1, 0, watcher);
    }
    // queue the flush
    if (!waiting) {
      waiting = true;
      nextTick(flushSchedulerQueue);
    }
  }
}

/*  */

var uid$2 = 0;

/**
 * A watcher parses an expression, collects dependencies,
 * and fires callback when the expression value changes.
 * This is used for both the $watch() api and directives.
 */
var Watcher = function Watcher (
  vm,
  expOrFn,
  cb,
  options
) {
  this.vm = vm;
  vm._watchers.push(this);
  // options
  if (options) {
    this.deep = !!options.deep;
    this.user = !!options.user;
    this.lazy = !!options.lazy;
    this.sync = !!options.sync;
  } else {
    this.deep = this.user = this.lazy = this.sync = false;
  }
  this.cb = cb;
  this.id = ++uid$2; // uid for batching
  this.active = true;
  this.dirty = this.lazy; // for lazy watchers
  this.deps = [];
  this.newDeps = [];
  this.depIds = new _Set();
  this.newDepIds = new _Set();
  this.expression = '';
  // parse expression for getter
  if (typeof expOrFn === 'function') {
    this.getter = expOrFn;
  } else {
    this.getter = parsePath(expOrFn);
    if (!this.getter) {
      this.getter = function () {};
      "production" !== 'production' && warn(
        "Failed watching path: \"" + expOrFn + "\" " +
        'Watcher only accepts simple dot-delimited paths. ' +
        'For full control, use a function instead.',
        vm
      );
    }
  }
  this.value = this.lazy
    ? undefined
    : this.get();
};

/**
 * Evaluate the getter, and re-collect dependencies.
 */
Watcher.prototype.get = function get () {
  pushTarget(this);
  var value;
  var vm = this.vm;
  try {
    value = this.getter.call(vm, vm);
  } catch (e) {
    if (this.user) {
      handleError(e, vm, ("getter for watcher \"" + (this.expression) + "\""));
    } else {
      throw e
    }
  } finally {
    // "touch" every property so they are all tracked as
    // dependencies for deep watching
    if (this.deep) {
      traverse(value);
    }
    popTarget();
    this.cleanupDeps();
  }
  return value
};

/**
 * Add a dependency to this directive.
 */
Watcher.prototype.addDep = function addDep (dep) {
  var id = dep.id;
  if (!this.newDepIds.has(id)) {
    this.newDepIds.add(id);
    this.newDeps.push(dep);
    if (!this.depIds.has(id)) {
      dep.addSub(this);
    }
  }
};

/**
 * Clean up for dependency collection.
 */
Watcher.prototype.cleanupDeps = function cleanupDeps () {
    var this$1 = this;

  var i = this.deps.length;
  while (i--) {
    var dep = this$1.deps[i];
    if (!this$1.newDepIds.has(dep.id)) {
      dep.removeSub(this$1);
    }
  }
  var tmp = this.depIds;
  this.depIds = this.newDepIds;
  this.newDepIds = tmp;
  this.newDepIds.clear();
  tmp = this.deps;
  this.deps = this.newDeps;
  this.newDeps = tmp;
  this.newDeps.length = 0;
};

/**
 * Subscriber interface.
 * Will be called when a dependency changes.
 */
Watcher.prototype.update = function update () {
  /* istanbul ignore else */
  if (this.lazy) {
    this.dirty = true;
  } else if (this.sync) {
    this.run();
  } else {
    queueWatcher(this);
  }
};

/**
 * Scheduler job interface.
 * Will be called by the scheduler.
 */
Watcher.prototype.run = function run () {
  if (this.active) {
    var value = this.get();
    if (
      value !== this.value ||
      // Deep watchers and watchers on Object/Arrays should fire even
      // when the value is the same, because the value may
      // have mutated.
      isObject(value) ||
      this.deep
    ) {
      // set new value
      var oldValue = this.value;
      this.value = value;
      if (this.user) {
        try {
          this.cb.call(this.vm, value, oldValue);
        } catch (e) {
          handleError(e, this.vm, ("callback for watcher \"" + (this.expression) + "\""));
        }
      } else {
        this.cb.call(this.vm, value, oldValue);
      }
    }
  }
};

/**
 * Evaluate the value of the watcher.
 * This only gets called for lazy watchers.
 */
Watcher.prototype.evaluate = function evaluate () {
  this.value = this.get();
  this.dirty = false;
};

/**
 * Depend on all deps collected by this watcher.
 */
Watcher.prototype.depend = function depend () {
    var this$1 = this;

  var i = this.deps.length;
  while (i--) {
    this$1.deps[i].depend();
  }
};

/**
 * Remove self from all dependencies' subscriber list.
 */
Watcher.prototype.teardown = function teardown () {
    var this$1 = this;

  if (this.active) {
    // remove self from vm's watcher list
    // this is a somewhat expensive operation so we skip it
    // if the vm is being destroyed.
    if (!this.vm._isBeingDestroyed) {
      remove(this.vm._watchers, this);
    }
    var i = this.deps.length;
    while (i--) {
      this$1.deps[i].removeSub(this$1);
    }
    this.active = false;
  }
};

/**
 * Recursively traverse an object to evoke all converted
 * getters, so that every nested property inside the object
 * is collected as a "deep" dependency.
 */
var seenObjects = new _Set();
function traverse (val) {
  seenObjects.clear();
  _traverse(val, seenObjects);
}

function _traverse (val, seen) {
  var i, keys;
  var isA = Array.isArray(val);
  if ((!isA && !isObject(val)) || !Object.isExtensible(val)) {
    return
  }
  if (val.__ob__) {
    var depId = val.__ob__.dep.id;
    if (seen.has(depId)) {
      return
    }
    seen.add(depId);
  }
  if (isA) {
    i = val.length;
    while (i--) { _traverse(val[i], seen); }
  } else {
    keys = Object.keys(val);
    i = keys.length;
    while (i--) { _traverse(val[keys[i]], seen); }
  }
}

/*  */

var sharedPropertyDefinition = {
  enumerable: true,
  configurable: true,
  get: noop,
  set: noop
};

function proxy (target, sourceKey, key) {
  sharedPropertyDefinition.get = function proxyGetter () {
    return this[sourceKey][key]
  };
  sharedPropertyDefinition.set = function proxySetter (val) {
    this[sourceKey][key] = val;
  };
  Object.defineProperty(target, key, sharedPropertyDefinition);
}

function initState (vm) {
  vm._watchers = [];
  var opts = vm.$options;
  if (opts.props) { initProps(vm, opts.props); }
  if (opts.methods) { initMethods(vm, opts.methods); }
  if (opts.data) {
    initData(vm);
  } else {
    observe(vm._data = {}, true /* asRootData */);
  }
  if (opts.computed) { initComputed(vm, opts.computed); }
  if (opts.watch && opts.watch !== nativeWatch) {
    initWatch(vm, opts.watch);
  }
}

function checkOptionType (vm, name) {
  var option = vm.$options[name];
  if (!isPlainObject(option)) {
    warn(
      ("component option \"" + name + "\" should be an object."),
      vm
    );
  }
}

function initProps (vm, propsOptions) {
  var propsData = vm.$options.propsData || {};
  var props = vm._props = {};
  // cache prop keys so that future props updates can iterate using Array
  // instead of dynamic object key enumeration.
  var keys = vm.$options._propKeys = [];
  var isRoot = !vm.$parent;
  // root instance props should be converted
  observerState.shouldConvert = isRoot;
  var loop = function ( key ) {
    keys.push(key);
    var value = validateProp(key, propsOptions, propsData, vm);
    /* istanbul ignore else */
    {
      defineReactive$$1(props, key, value);
    }
    // static props are already proxied on the component's prototype
    // during Vue.extend(). We only need to proxy props defined at
    // instantiation here.
    if (!(key in vm)) {
      proxy(vm, "_props", key);
    }
  };

  for (var key in propsOptions) loop( key );
  observerState.shouldConvert = true;
}

function initData (vm) {
  var data = vm.$options.data;
  data = vm._data = typeof data === 'function'
    ? getData(data, vm)
    : data || {};
  if (!isPlainObject(data)) {
    data = {};
    "production" !== 'production' && warn(
      'data functions should return an object:\n' +
      'https://vuejs.org/v2/guide/components.html#data-Must-Be-a-Function',
      vm
    );
  }
  // proxy data on instance
  var keys = Object.keys(data);
  var props = vm.$options.props;
  var methods = vm.$options.methods;
  var i = keys.length;
  while (i--) {
    var key = keys[i];
    if (props && hasOwn(props, key)) {
      "production" !== 'production' && warn(
        "The data property \"" + key + "\" is already declared as a prop. " +
        "Use prop default value instead.",
        vm
      );
    } else if (!isReserved(key)) {
      proxy(vm, "_data", key);
    }
  }
  // observe data
  observe(data, true /* asRootData */);
}

function getData (data, vm) {
  try {
    return data.call(vm)
  } catch (e) {
    handleError(e, vm, "data()");
    return {}
  }
}

var computedWatcherOptions = { lazy: true };

function initComputed (vm, computed) {
  "production" !== 'production' && checkOptionType(vm, 'computed');
  var watchers = vm._computedWatchers = Object.create(null);

  for (var key in computed) {
    var userDef = computed[key];
    var getter = typeof userDef === 'function' ? userDef : userDef.get;
    watchers[key] = new Watcher(vm, getter, noop, computedWatcherOptions);

    // component-defined computed properties are already defined on the
    // component prototype. We only need to define computed properties defined
    // at instantiation here.
    if (!(key in vm)) {
      defineComputed(vm, key, userDef);
    } else {}
  }
}

function defineComputed (target, key, userDef) {
  if (typeof userDef === 'function') {
    sharedPropertyDefinition.get = createComputedGetter(key);
    sharedPropertyDefinition.set = noop;
  } else {
    sharedPropertyDefinition.get = userDef.get
      ? userDef.cache !== false
        ? createComputedGetter(key)
        : userDef.get
      : noop;
    sharedPropertyDefinition.set = userDef.set
      ? userDef.set
      : noop;
  }
  Object.defineProperty(target, key, sharedPropertyDefinition);
}

function createComputedGetter (key) {
  return function computedGetter () {
    var watcher = this._computedWatchers && this._computedWatchers[key];
    if (watcher) {
      if (watcher.dirty) {
        watcher.evaluate();
      }
      if (Dep.target) {
        watcher.depend();
      }
      return watcher.value
    }
  }
}

function initMethods (vm, methods) {
  "production" !== 'production' && checkOptionType(vm, 'methods');
  var props = vm.$options.props;
  for (var key in methods) {
    vm[key] = methods[key] == null ? noop : bind(methods[key], vm);
    
  }
}

function initWatch (vm, watch) {
  "production" !== 'production' && checkOptionType(vm, 'watch');
  for (var key in watch) {
    var handler = watch[key];
    if (Array.isArray(handler)) {
      for (var i = 0; i < handler.length; i++) {
        createWatcher(vm, key, handler[i]);
      }
    } else {
      createWatcher(vm, key, handler);
    }
  }
}

function createWatcher (
  vm,
  keyOrFn,
  handler,
  options
) {
  if (isPlainObject(handler)) {
    options = handler;
    handler = handler.handler;
  }
  if (typeof handler === 'string') {
    handler = vm[handler];
  }
  return vm.$watch(keyOrFn, handler, options)
}

function stateMixin (Vue) {
  // flow somehow has problems with directly declared definition object
  // when using Object.defineProperty, so we have to procedurally build up
  // the object here.
  var dataDef = {};
  dataDef.get = function () { return this._data };
  var propsDef = {};
  propsDef.get = function () { return this._props };
  Object.defineProperty(Vue.prototype, '$data', dataDef);
  Object.defineProperty(Vue.prototype, '$props', propsDef);

  Vue.prototype.$set = set;
  Vue.prototype.$delete = del;

  Vue.prototype.$watch = function (
    expOrFn,
    cb,
    options
  ) {
    var vm = this;
    if (isPlainObject(cb)) {
      return createWatcher(vm, expOrFn, cb, options)
    }
    options = options || {};
    options.user = true;
    var watcher = new Watcher(vm, expOrFn, cb, options);
    if (options.immediate) {
      cb.call(vm, watcher.value);
    }
    return function unwatchFn () {
      watcher.teardown();
    }
  };
}

/*  */

function initProvide (vm) {
  var provide = vm.$options.provide;
  if (provide) {
    vm._provided = typeof provide === 'function'
      ? provide.call(vm)
      : provide;
  }
}

function initInjections (vm) {
  var result = resolveInject(vm.$options.inject, vm);
  if (result) {
    observerState.shouldConvert = false;
    Object.keys(result).forEach(function (key) {
      /* istanbul ignore else */
      {
        defineReactive$$1(vm, key, result[key]);
      }
    });
    observerState.shouldConvert = true;
  }
}

function resolveInject (inject, vm) {
  if (inject) {
    // inject is :any because flow is not smart enough to figure out cached
    var result = Object.create(null);
    var keys = hasSymbol
        ? Reflect.ownKeys(inject)
        : Object.keys(inject);

    for (var i = 0; i < keys.length; i++) {
      var key = keys[i];
      var provideKey = inject[key];
      var source = vm;
      while (source) {
        if (source._provided && provideKey in source._provided) {
          result[key] = source._provided[provideKey];
          break
        }
        source = source.$parent;
      }
      if (false) {
        warn(("Injection \"" + key + "\" not found"), vm);
      }
    }
    return result
  }
}

/*  */

function createFunctionalComponent (
  Ctor,
  propsData,
  data,
  context,
  children
) {
  var props = {};
  var propOptions = Ctor.options.props;
  if (isDef(propOptions)) {
    for (var key in propOptions) {
      props[key] = validateProp(key, propOptions, propsData || {});
    }
  } else {
    if (isDef(data.attrs)) { mergeProps(props, data.attrs); }
    if (isDef(data.props)) { mergeProps(props, data.props); }
  }
  // ensure the createElement function in functional components
  // gets a unique context - this is necessary for correct named slot check
  var _context = Object.create(context);
  var h = function (a, b, c, d) { return createElement(_context, a, b, c, d, true); };
  var vnode = Ctor.options.render.call(null, h, {
    data: data,
    props: props,
    children: children,
    parent: context,
    listeners: data.on || {},
    injections: resolveInject(Ctor.options.inject, context),
    slots: function () { return resolveSlots(children, context); }
  });
  if (vnode instanceof VNode) {
    vnode.functionalContext = context;
    vnode.functionalOptions = Ctor.options;
    if (data.slot) {
      (vnode.data || (vnode.data = {})).slot = data.slot;
    }
  }
  return vnode
}

function mergeProps (to, from) {
  for (var key in from) {
    to[camelize(key)] = from[key];
  }
}

/*  */

// hooks to be invoked on component VNodes during patch
var componentVNodeHooks = {
  init: function init (
    vnode,
    hydrating,
    parentElm,
    refElm
  ) {
    if (!vnode.componentInstance || vnode.componentInstance._isDestroyed) {
      var child = vnode.componentInstance = createComponentInstanceForVnode(
        vnode,
        activeInstance,
        parentElm,
        refElm
      );
      child.$mount(hydrating ? vnode.elm : undefined, hydrating);
    } else if (vnode.data.keepAlive) {
      // kept-alive components, treat as a patch
      var mountedNode = vnode; // work around flow
      componentVNodeHooks.prepatch(mountedNode, mountedNode);
    }
  },

  prepatch: function prepatch (oldVnode, vnode) {
    var options = vnode.componentOptions;
    var child = vnode.componentInstance = oldVnode.componentInstance;
    updateChildComponent(
      child,
      options.propsData, // updated props
      options.listeners, // updated listeners
      vnode, // new parent vnode
      options.children // new children
    );
  },

  insert: function insert (vnode) {
    var context = vnode.context;
    var componentInstance = vnode.componentInstance;

    if (!componentInstance._isMounted) {
      componentInstance._isMounted = true;
      callHook(componentInstance, 'mounted');
    }
    if (vnode.data.keepAlive) {
      if (context._isMounted) {
        // vue-router#1212
        // During updates, a kept-alive component's child components may
        // change, so directly walking the tree here may call activated hooks
        // on incorrect children. Instead we push them into a queue which will
        // be processed after the whole patch process ended.
        queueActivatedComponent(componentInstance);
      } else {
        activateChildComponent(componentInstance, true /* direct */);
      }
    }
  },

  destroy: function destroy (vnode) {
    var componentInstance = vnode.componentInstance;
    if (!componentInstance._isDestroyed) {
      if (!vnode.data.keepAlive) {
        componentInstance.$destroy();
      } else {
        deactivateChildComponent(componentInstance, true /* direct */);
      }
    }
  }
};

var hooksToMerge = Object.keys(componentVNodeHooks);

function createComponent (
  Ctor,
  data,
  context,
  children,
  tag
) {
  if (isUndef(Ctor)) {
    return
  }

  var baseCtor = context.$options._base;

  // plain options object: turn it into a constructor
  if (isObject(Ctor)) {
    Ctor = baseCtor.extend(Ctor);
  }

  // if at this stage it's not a constructor or an async component factory,
  // reject.
  if (typeof Ctor !== 'function') {
    return
  }

  // async component
  var asyncFactory;
  if (isUndef(Ctor.cid)) {
    asyncFactory = Ctor;
    Ctor = resolveAsyncComponent(asyncFactory, baseCtor, context);
    if (Ctor === undefined) {
      // return a placeholder node for async component, which is rendered
      // as a comment node but preserves all the raw information for the node.
      // the information will be used for async server-rendering and hydration.
      return createAsyncPlaceholder(
        asyncFactory,
        data,
        context,
        children,
        tag
      )
    }
  }

  data = data || {};

  // resolve constructor options in case global mixins are applied after
  // component constructor creation
  resolveConstructorOptions(Ctor);

  // transform component v-model data into props & events
  if (isDef(data.model)) {
    transformModel(Ctor.options, data);
  }

  // extract props
  var propsData = extractPropsFromVNodeData(data, Ctor, tag);

  // functional component
  if (isTrue(Ctor.options.functional)) {
    return createFunctionalComponent(Ctor, propsData, data, context, children)
  }

  // keep listeners
  var listeners = data.on;

  if (isTrue(Ctor.options.abstract)) {
    // abstract components do not keep anything
    // other than props & listeners & slot

    // work around flow
    var slot = data.slot;
    data = {};
    if (slot) {
      data.slot = slot;
    }
  }

  // merge component management hooks onto the placeholder node
  mergeHooks(data);

  // return a placeholder vnode
  var name = Ctor.options.name || tag;
  var vnode = new VNode(
    ("vue-component-" + (Ctor.cid) + (name ? ("-" + name) : '')),
    data, undefined, undefined, undefined, context,
    { Ctor: Ctor, propsData: propsData, listeners: listeners, tag: tag, children: children },
    asyncFactory
  );
  return vnode
}

function createComponentInstanceForVnode (
  vnode, // we know it's MountedComponentVNode but flow doesn't
  parent, // activeInstance in lifecycle state
  parentElm,
  refElm
) {
  var vnodeComponentOptions = vnode.componentOptions;
  var options = {
    _isComponent: true,
    parent: parent,
    propsData: vnodeComponentOptions.propsData,
    _componentTag: vnodeComponentOptions.tag,
    _parentVnode: vnode,
    _parentListeners: vnodeComponentOptions.listeners,
    _renderChildren: vnodeComponentOptions.children,
    _parentElm: parentElm || null,
    _refElm: refElm || null
  };
  // check inline-template render functions
  var inlineTemplate = vnode.data.inlineTemplate;
  if (isDef(inlineTemplate)) {
    options.render = inlineTemplate.render;
    options.staticRenderFns = inlineTemplate.staticRenderFns;
  }
  return new vnodeComponentOptions.Ctor(options)
}

function mergeHooks (data) {
  if (!data.hook) {
    data.hook = {};
  }
  for (var i = 0; i < hooksToMerge.length; i++) {
    var key = hooksToMerge[i];
    var fromParent = data.hook[key];
    var ours = componentVNodeHooks[key];
    data.hook[key] = fromParent ? mergeHook$1(ours, fromParent) : ours;
  }
}

function mergeHook$1 (one, two) {
  return function (a, b, c, d) {
    one(a, b, c, d);
    two(a, b, c, d);
  }
}

// transform component v-model info (value and callback) into
// prop and event handler respectively.
function transformModel (options, data) {
  var prop = (options.model && options.model.prop) || 'value';
  var event = (options.model && options.model.event) || 'input';(data.props || (data.props = {}))[prop] = data.model.value;
  var on = data.on || (data.on = {});
  if (isDef(on[event])) {
    on[event] = [data.model.callback].concat(on[event]);
  } else {
    on[event] = data.model.callback;
  }
}

/*  */

var SIMPLE_NORMALIZE = 1;
var ALWAYS_NORMALIZE = 2;

// wrapper function for providing a more flexible interface
// without getting yelled at by flow
function createElement (
  context,
  tag,
  data,
  children,
  normalizationType,
  alwaysNormalize
) {
  if (Array.isArray(data) || isPrimitive(data)) {
    normalizationType = children;
    children = data;
    data = undefined;
  }
  if (isTrue(alwaysNormalize)) {
    normalizationType = ALWAYS_NORMALIZE;
  }
  return _createElement(context, tag, data, children, normalizationType)
}

function _createElement (
  context,
  tag,
  data,
  children,
  normalizationType
) {
  if (isDef(data) && isDef((data).__ob__)) {
    "production" !== 'production' && warn(
      "Avoid using observed data object as vnode data: " + (JSON.stringify(data)) + "\n" +
      'Always create fresh vnode data objects in each render!',
      context
    );
    return createEmptyVNode()
  }
  // object syntax in v-bind
  if (isDef(data) && isDef(data.is)) {
    tag = data.is;
  }
  if (!tag) {
    // in case of component :is set to falsy value
    return createEmptyVNode()
  }
  // warn against non-primitive key
  if (false
  ) {
    warn(
      'Avoid using non-primitive value as key, ' +
      'use string/number value instead.',
      context
    );
  }
  // support single function children as default scoped slot
  if (Array.isArray(children) &&
    typeof children[0] === 'function'
  ) {
    data = data || {};
    data.scopedSlots = { default: children[0] };
    children.length = 0;
  }
  if (normalizationType === ALWAYS_NORMALIZE) {
    children = normalizeChildren(children);
  } else if (normalizationType === SIMPLE_NORMALIZE) {
    children = simpleNormalizeChildren(children);
  }
  var vnode, ns;
  if (typeof tag === 'string') {
    var Ctor;
    ns = config.getTagNamespace(tag);
    if (config.isReservedTag(tag)) {
      // platform built-in elements
      vnode = new VNode(
        config.parsePlatformTagName(tag), data, children,
        undefined, undefined, context
      );
    } else if (isDef(Ctor = resolveAsset(context.$options, 'components', tag))) {
      // component
      vnode = createComponent(Ctor, data, context, children, tag);
    } else {
      // unknown or unlisted namespaced elements
      // check at runtime because it may get assigned a namespace when its
      // parent normalizes children
      vnode = new VNode(
        tag, data, children,
        undefined, undefined, context
      );
    }
  } else {
    // direct component options / constructor
    vnode = createComponent(tag, data, context, children);
  }
  if (isDef(vnode)) {
    if (ns) { applyNS(vnode, ns); }
    return vnode
  } else {
    return createEmptyVNode()
  }
}

function applyNS (vnode, ns) {
  vnode.ns = ns;
  if (vnode.tag === 'foreignObject') {
    // use default namespace inside foreignObject
    return
  }
  if (isDef(vnode.children)) {
    for (var i = 0, l = vnode.children.length; i < l; i++) {
      var child = vnode.children[i];
      if (isDef(child.tag) && isUndef(child.ns)) {
        applyNS(child, ns);
      }
    }
  }
}

/*  */

/**
 * Runtime helper for rendering v-for lists.
 */
function renderList (
  val,
  render
) {
  var ret, i, l, keys, key;
  if (Array.isArray(val) || typeof val === 'string') {
    ret = new Array(val.length);
    for (i = 0, l = val.length; i < l; i++) {
      ret[i] = render(val[i], i);
    }
  } else if (typeof val === 'number') {
    ret = new Array(val);
    for (i = 0; i < val; i++) {
      ret[i] = render(i + 1, i);
    }
  } else if (isObject(val)) {
    keys = Object.keys(val);
    ret = new Array(keys.length);
    for (i = 0, l = keys.length; i < l; i++) {
      key = keys[i];
      ret[i] = render(val[key], key, i);
    }
  }
  if (isDef(ret)) {
    (ret)._isVList = true;
  }
  return ret
}

/*  */

/**
 * Runtime helper for rendering <slot>
 */
function renderSlot (
  name,
  fallback,
  props,
  bindObject
) {
  var scopedSlotFn = this.$scopedSlots[name];
  if (scopedSlotFn) { // scoped slot
    props = props || {};
    if (bindObject) {
      props = extend(extend({}, bindObject), props);
    }
    return scopedSlotFn(props) || fallback
  } else {
    var slotNodes = this.$slots[name];
    // warn duplicate slot usage
    if (slotNodes && "production" !== 'production') {
      slotNodes._rendered && warn(
        "Duplicate presence of slot \"" + name + "\" found in the same render tree " +
        "- this will likely cause render errors.",
        this
      );
      slotNodes._rendered = true;
    }
    return slotNodes || fallback
  }
}

/*  */

/**
 * Runtime helper for resolving filters
 */
function resolveFilter (id) {
  return resolveAsset(this.$options, 'filters', id, true) || identity
}

/*  */

/**
 * Runtime helper for checking keyCodes from config.
 */
function checkKeyCodes (
  eventKeyCode,
  key,
  builtInAlias
) {
  var keyCodes = config.keyCodes[key] || builtInAlias;
  if (Array.isArray(keyCodes)) {
    return keyCodes.indexOf(eventKeyCode) === -1
  } else {
    return keyCodes !== eventKeyCode
  }
}

/*  */

/**
 * Runtime helper for merging v-bind="object" into a VNode's data.
 */
function bindObjectProps (
  data,
  tag,
  value,
  asProp,
  isSync
) {
  if (value) {
    if (!isObject(value)) {
      "production" !== 'production' && warn(
        'v-bind without argument expects an Object or Array value',
        this
      );
    } else {
      if (Array.isArray(value)) {
        value = toObject(value);
      }
      var hash;
      var loop = function ( key ) {
        if (
          key === 'class' ||
          key === 'style' ||
          isReservedAttribute(key)
        ) {
          hash = data;
        } else {
          var type = data.attrs && data.attrs.type;
          hash = asProp || config.mustUseProp(tag, type, key)
            ? data.domProps || (data.domProps = {})
            : data.attrs || (data.attrs = {});
        }
        if (!(key in hash)) {
          hash[key] = value[key];

          if (isSync) {
            var on = data.on || (data.on = {});
            on[("update:" + key)] = function ($event) {
              value[key] = $event;
            };
          }
        }
      };

      for (var key in value) loop( key );
    }
  }
  return data
}

/*  */

/**
 * Runtime helper for rendering static trees.
 */
function renderStatic (
  index,
  isInFor
) {
  var tree = this._staticTrees[index];
  // if has already-rendered static tree and not inside v-for,
  // we can reuse the same tree by doing a shallow clone.
  if (tree && !isInFor) {
    return Array.isArray(tree)
      ? cloneVNodes(tree)
      : cloneVNode(tree)
  }
  // otherwise, render a fresh tree.
  tree = this._staticTrees[index] =
    this.$options.staticRenderFns[index].call(this._renderProxy);
  markStatic(tree, ("__static__" + index), false);
  return tree
}

/**
 * Runtime helper for v-once.
 * Effectively it means marking the node as static with a unique key.
 */
function markOnce (
  tree,
  index,
  key
) {
  markStatic(tree, ("__once__" + index + (key ? ("_" + key) : "")), true);
  return tree
}

function markStatic (
  tree,
  key,
  isOnce
) {
  if (Array.isArray(tree)) {
    for (var i = 0; i < tree.length; i++) {
      if (tree[i] && typeof tree[i] !== 'string') {
        markStaticNode(tree[i], (key + "_" + i), isOnce);
      }
    }
  } else {
    markStaticNode(tree, key, isOnce);
  }
}

function markStaticNode (node, key, isOnce) {
  node.isStatic = true;
  node.key = key;
  node.isOnce = isOnce;
}

/*  */

function bindObjectListeners (data, value) {
  if (value) {
    if (!isPlainObject(value)) {
      "production" !== 'production' && warn(
        'v-on without argument expects an Object value',
        this
      );
    } else {
      var on = data.on = data.on ? extend({}, data.on) : {};
      for (var key in value) {
        var existing = on[key];
        var ours = value[key];
        on[key] = existing ? [].concat(ours, existing) : ours;
      }
    }
  }
  return data
}

/*  */

function initRender (vm) {
  vm._vnode = null; // the root of the child tree
  vm._staticTrees = null;
  var parentVnode = vm.$vnode = vm.$options._parentVnode; // the placeholder node in parent tree
  var renderContext = parentVnode && parentVnode.context;
  vm.$slots = resolveSlots(vm.$options._renderChildren, renderContext);
  vm.$scopedSlots = emptyObject;
  // bind the createElement fn to this instance
  // so that we get proper render context inside it.
  // args order: tag, data, children, normalizationType, alwaysNormalize
  // internal version is used by render functions compiled from templates
  vm._c = function (a, b, c, d) { return createElement(vm, a, b, c, d, false); };
  // normalization is always applied for the public version, used in
  // user-written render functions.
  vm.$createElement = function (a, b, c, d) { return createElement(vm, a, b, c, d, true); };

  // $attrs & $listeners are exposed for easier HOC creation.
  // they need to be reactive so that HOCs using them are always updated
  var parentData = parentVnode && parentVnode.data;
  /* istanbul ignore else */
  {
    defineReactive$$1(vm, '$attrs', parentData && parentData.attrs, null, true);
    defineReactive$$1(vm, '$listeners', parentData && parentData.on, null, true);
  }
}

function renderMixin (Vue) {
  Vue.prototype.$nextTick = function (fn) {
    return nextTick(fn, this)
  };

  Vue.prototype._render = function () {
    var vm = this;
    var ref = vm.$options;
    var render = ref.render;
    var staticRenderFns = ref.staticRenderFns;
    var _parentVnode = ref._parentVnode;

    if (vm._isMounted) {
      // clone slot nodes on re-renders
      for (var key in vm.$slots) {
        vm.$slots[key] = cloneVNodes(vm.$slots[key]);
      }
    }

    vm.$scopedSlots = (_parentVnode && _parentVnode.data.scopedSlots) || emptyObject;

    if (staticRenderFns && !vm._staticTrees) {
      vm._staticTrees = [];
    }
    // set parent vnode. this allows render functions to have access
    // to the data on the placeholder node.
    vm.$vnode = _parentVnode;
    // render self
    var vnode;
    try {
      vnode = render.call(vm._renderProxy, vm.$createElement);
    } catch (e) {
      handleError(e, vm, "render function");
      // return error render result,
      // or previous vnode to prevent render error causing blank component
      /* istanbul ignore else */
      {
        vnode = vm._vnode;
      }
    }
    // return empty vnode in case the render function errored out
    if (!(vnode instanceof VNode)) {
      if (false) {
        warn(
          'Multiple root nodes returned from render function. Render function ' +
          'should return a single root node.',
          vm
        );
      }
      vnode = createEmptyVNode();
    }
    // set parent
    vnode.parent = _parentVnode;
    return vnode
  };

  // internal render helpers.
  // these are exposed on the instance prototype to reduce generated render
  // code size.
  Vue.prototype._o = markOnce;
  Vue.prototype._n = toNumber;
  Vue.prototype._s = toString;
  Vue.prototype._l = renderList;
  Vue.prototype._t = renderSlot;
  Vue.prototype._q = looseEqual;
  Vue.prototype._i = looseIndexOf;
  Vue.prototype._m = renderStatic;
  Vue.prototype._f = resolveFilter;
  Vue.prototype._k = checkKeyCodes;
  Vue.prototype._b = bindObjectProps;
  Vue.prototype._v = createTextVNode;
  Vue.prototype._e = createEmptyVNode;
  Vue.prototype._u = resolveScopedSlots;
  Vue.prototype._g = bindObjectListeners;
}

/*  */

var uid = 0;

function initMixin (Vue) {
  Vue.prototype._init = function (options) {
    var vm = this;
    // a uid
    vm._uid = uid++;

    var startTag, endTag;
    /* istanbul ignore if */
    if (false) {
      startTag = "vue-perf-init:" + (vm._uid);
      endTag = "vue-perf-end:" + (vm._uid);
      mark(startTag);
    }

    // a flag to avoid this being observed
    vm._isVue = true;
    // merge options
    if (options && options._isComponent) {
      // optimize internal component instantiation
      // since dynamic options merging is pretty slow, and none of the
      // internal component options needs special treatment.
      initInternalComponent(vm, options);
    } else {
      vm.$options = mergeOptions(
        resolveConstructorOptions(vm.constructor),
        options || {},
        vm
      );
    }
    /* istanbul ignore else */
    {
      vm._renderProxy = vm;
    }
    // expose real self
    vm._self = vm;
    initLifecycle(vm);
    initEvents(vm);
    initRender(vm);
    callHook(vm, 'beforeCreate');
    initInjections(vm); // resolve injections before data/props
    initState(vm);
    initProvide(vm); // resolve provide after data/props
    callHook(vm, 'created');

    /* istanbul ignore if */
    if (false) {
      vm._name = formatComponentName(vm, false);
      mark(endTag);
      measure(((vm._name) + " init"), startTag, endTag);
    }

    if (vm.$options.el) {
      vm.$mount(vm.$options.el);
    }
  };
}

function initInternalComponent (vm, options) {
  var opts = vm.$options = Object.create(vm.constructor.options);
  // doing this because it's faster than dynamic enumeration.
  opts.parent = options.parent;
  opts.propsData = options.propsData;
  opts._parentVnode = options._parentVnode;
  opts._parentListeners = options._parentListeners;
  opts._renderChildren = options._renderChildren;
  opts._componentTag = options._componentTag;
  opts._parentElm = options._parentElm;
  opts._refElm = options._refElm;
  if (options.render) {
    opts.render = options.render;
    opts.staticRenderFns = options.staticRenderFns;
  }
}

function resolveConstructorOptions (Ctor) {
  var options = Ctor.options;
  if (Ctor.super) {
    var superOptions = resolveConstructorOptions(Ctor.super);
    var cachedSuperOptions = Ctor.superOptions;
    if (superOptions !== cachedSuperOptions) {
      // super option changed,
      // need to resolve new options.
      Ctor.superOptions = superOptions;
      // check if there are any late-modified/attached options (#4976)
      var modifiedOptions = resolveModifiedOptions(Ctor);
      // update base extend options
      if (modifiedOptions) {
        extend(Ctor.extendOptions, modifiedOptions);
      }
      options = Ctor.options = mergeOptions(superOptions, Ctor.extendOptions);
      if (options.name) {
        options.components[options.name] = Ctor;
      }
    }
  }
  return options
}

function resolveModifiedOptions (Ctor) {
  var modified;
  var latest = Ctor.options;
  var extended = Ctor.extendOptions;
  var sealed = Ctor.sealedOptions;
  for (var key in latest) {
    if (latest[key] !== sealed[key]) {
      if (!modified) { modified = {}; }
      modified[key] = dedupe(latest[key], extended[key], sealed[key]);
    }
  }
  return modified
}

function dedupe (latest, extended, sealed) {
  // compare latest and sealed to ensure lifecycle hooks won't be duplicated
  // between merges
  if (Array.isArray(latest)) {
    var res = [];
    sealed = Array.isArray(sealed) ? sealed : [sealed];
    extended = Array.isArray(extended) ? extended : [extended];
    for (var i = 0; i < latest.length; i++) {
      // push original options and not sealed options to exclude duplicated options
      if (extended.indexOf(latest[i]) >= 0 || sealed.indexOf(latest[i]) < 0) {
        res.push(latest[i]);
      }
    }
    return res
  } else {
    return latest
  }
}

function Vue$3 (options) {
  if (false
  ) {
    warn('Vue is a constructor and should be called with the `new` keyword');
  }
  this._init(options);
}

initMixin(Vue$3);
stateMixin(Vue$3);
eventsMixin(Vue$3);
lifecycleMixin(Vue$3);
renderMixin(Vue$3);

/*  */

function initUse (Vue) {
  Vue.use = function (plugin) {
    var installedPlugins = (this._installedPlugins || (this._installedPlugins = []));
    if (installedPlugins.indexOf(plugin) > -1) {
      return this
    }

    // additional parameters
    var args = toArray(arguments, 1);
    args.unshift(this);
    if (typeof plugin.install === 'function') {
      plugin.install.apply(plugin, args);
    } else if (typeof plugin === 'function') {
      plugin.apply(null, args);
    }
    installedPlugins.push(plugin);
    return this
  };
}

/*  */

function initMixin$1 (Vue) {
  Vue.mixin = function (mixin) {
    this.options = mergeOptions(this.options, mixin);
    return this
  };
}

/*  */

function initExtend (Vue) {
  /**
   * Each instance constructor, including Vue, has a unique
   * cid. This enables us to create wrapped "child
   * constructors" for prototypal inheritance and cache them.
   */
  Vue.cid = 0;
  var cid = 1;

  /**
   * Class inheritance
   */
  Vue.extend = function (extendOptions) {
    extendOptions = extendOptions || {};
    var Super = this;
    var SuperId = Super.cid;
    var cachedCtors = extendOptions._Ctor || (extendOptions._Ctor = {});
    if (cachedCtors[SuperId]) {
      return cachedCtors[SuperId]
    }

    var name = extendOptions.name || Super.options.name;
    var Sub = function VueComponent (options) {
      this._init(options);
    };
    Sub.prototype = Object.create(Super.prototype);
    Sub.prototype.constructor = Sub;
    Sub.cid = cid++;
    Sub.options = mergeOptions(
      Super.options,
      extendOptions
    );
    Sub['super'] = Super;

    // For props and computed properties, we define the proxy getters on
    // the Vue instances at extension time, on the extended prototype. This
    // avoids Object.defineProperty calls for each instance created.
    if (Sub.options.props) {
      initProps$1(Sub);
    }
    if (Sub.options.computed) {
      initComputed$1(Sub);
    }

    // allow further extension/mixin/plugin usage
    Sub.extend = Super.extend;
    Sub.mixin = Super.mixin;
    Sub.use = Super.use;

    // create asset registers, so extended classes
    // can have their private assets too.
    ASSET_TYPES.forEach(function (type) {
      Sub[type] = Super[type];
    });
    // enable recursive self-lookup
    if (name) {
      Sub.options.components[name] = Sub;
    }

    // keep a reference to the super options at extension time.
    // later at instantiation we can check if Super's options have
    // been updated.
    Sub.superOptions = Super.options;
    Sub.extendOptions = extendOptions;
    Sub.sealedOptions = extend({}, Sub.options);

    // cache constructor
    cachedCtors[SuperId] = Sub;
    return Sub
  };
}

function initProps$1 (Comp) {
  var props = Comp.options.props;
  for (var key in props) {
    proxy(Comp.prototype, "_props", key);
  }
}

function initComputed$1 (Comp) {
  var computed = Comp.options.computed;
  for (var key in computed) {
    defineComputed(Comp.prototype, key, computed[key]);
  }
}

/*  */

function initAssetRegisters (Vue) {
  /**
   * Create asset registration methods.
   */
  ASSET_TYPES.forEach(function (type) {
    Vue[type] = function (
      id,
      definition
    ) {
      if (!definition) {
        return this.options[type + 's'][id]
      } else {
        /* istanbul ignore if */
        if (type === 'component' && isPlainObject(definition)) {
          definition.name = definition.name || id;
          definition = this.options._base.extend(definition);
        }
        if (type === 'directive' && typeof definition === 'function') {
          definition = { bind: definition, update: definition };
        }
        this.options[type + 's'][id] = definition;
        return definition
      }
    };
  });
}

/*  */

var patternTypes = [String, RegExp, Array];

function getComponentName (opts) {
  return opts && (opts.Ctor.options.name || opts.tag)
}

function matches (pattern, name) {
  if (Array.isArray(pattern)) {
    return pattern.indexOf(name) > -1
  } else if (typeof pattern === 'string') {
    return pattern.split(',').indexOf(name) > -1
  } else if (isRegExp(pattern)) {
    return pattern.test(name)
  }
  /* istanbul ignore next */
  return false
}

function pruneCache (cache, current, filter) {
  for (var key in cache) {
    var cachedNode = cache[key];
    if (cachedNode) {
      var name = getComponentName(cachedNode.componentOptions);
      if (name && !filter(name)) {
        if (cachedNode !== current) {
          pruneCacheEntry(cachedNode);
        }
        cache[key] = null;
      }
    }
  }
}

function pruneCacheEntry (vnode) {
  if (vnode) {
    vnode.componentInstance.$destroy();
  }
}

var KeepAlive = {
  name: 'keep-alive',
  abstract: true,

  props: {
    include: patternTypes,
    exclude: patternTypes
  },

  created: function created () {
    this.cache = Object.create(null);
  },

  destroyed: function destroyed () {
    var this$1 = this;

    for (var key in this$1.cache) {
      pruneCacheEntry(this$1.cache[key]);
    }
  },

  watch: {
    include: function include (val) {
      pruneCache(this.cache, this._vnode, function (name) { return matches(val, name); });
    },
    exclude: function exclude (val) {
      pruneCache(this.cache, this._vnode, function (name) { return !matches(val, name); });
    }
  },

  render: function render () {
    var vnode = getFirstComponentChild(this.$slots.default);
    var componentOptions = vnode && vnode.componentOptions;
    if (componentOptions) {
      // check pattern
      var name = getComponentName(componentOptions);
      if (name && (
        (this.include && !matches(this.include, name)) ||
        (this.exclude && matches(this.exclude, name))
      )) {
        return vnode
      }
      var key = vnode.key == null
        // same constructor may get registered as different local components
        // so cid alone is not enough (#3269)
        ? componentOptions.Ctor.cid + (componentOptions.tag ? ("::" + (componentOptions.tag)) : '')
        : vnode.key;
      if (this.cache[key]) {
        vnode.componentInstance = this.cache[key].componentInstance;
      } else {
        this.cache[key] = vnode;
      }
      vnode.data.keepAlive = true;
    }
    return vnode
  }
};

var builtInComponents = {
  KeepAlive: KeepAlive
};

/*  */

function initGlobalAPI (Vue) {
  // config
  var configDef = {};
  configDef.get = function () { return config; };
  Object.defineProperty(Vue, 'config', configDef);

  // exposed util methods.
  // NOTE: these are not considered part of the public API - avoid relying on
  // them unless you are aware of the risk.
  Vue.util = {
    warn: warn,
    extend: extend,
    mergeOptions: mergeOptions,
    defineReactive: defineReactive$$1
  };

  Vue.set = set;
  Vue.delete = del;
  Vue.nextTick = nextTick;

  Vue.options = Object.create(null);
  ASSET_TYPES.forEach(function (type) {
    Vue.options[type + 's'] = Object.create(null);
  });

  // this is used to identify the "base" constructor to extend all plain-object
  // components with in Weex's multi-instance scenarios.
  Vue.options._base = Vue;

  extend(Vue.options.components, builtInComponents);

  initUse(Vue);
  initMixin$1(Vue);
  initExtend(Vue);
  initAssetRegisters(Vue);
}

initGlobalAPI(Vue$3);

Object.defineProperty(Vue$3.prototype, '$isServer', {
  get: isServerRendering
});

Object.defineProperty(Vue$3.prototype, '$ssrContext', {
  get: function get () {
    /* istanbul ignore next */
    return this.$vnode && this.$vnode.ssrContext
  }
});

Vue$3.version = '2.4.1';
Vue$3.mpvueVersion = '2.0.6';

/* globals renderer */



var isReservedTag = makeMap(
  'template,script,style,element,content,slot,link,meta,svg,view,' +
  'a,div,img,image,text,span,richtext,input,switch,textarea,spinner,select,' +
  'slider,slider-neighbor,indicator,trisition,trisition-group,canvas,' +
  'list,cell,header,loading,loading-indicator,refresh,scrollable,scroller,' +
  'video,web,embed,tabbar,tabheader,datepicker,timepicker,marquee,countdown',
  true
);

// these are reserved for web because they are directly compiled away
// during template compilation
var isReservedAttr = makeMap('style,class');

// Elements that you can, intentionally, leave open (and which close themselves)
// more flexable than web
var canBeLeftOpenTag = makeMap(
  'web,spinner,switch,video,textarea,canvas,' +
  'indicator,marquee,countdown',
  true
);

var isUnaryTag = makeMap(
  'embed,img,image,input,link,meta',
  true
);

function mustUseProp () { /* console.log('mustUseProp') */ }
function getTagNamespace () { /* console.log('getTagNamespace') */ }
function isUnknownElement () { /* console.log('isUnknownElement') */ }



function getComKey (vm) {
  return vm && vm.$attrs ? vm.$attrs['mpcomid'] : '0'
}

// 用于小程序的 event type 到 web 的 event
var eventTypeMap = {
  tap: ['tap', 'click'],
  touchstart: ['touchstart'],
  touchmove: ['touchmove'],
  touchcancel: ['touchcancel'],
  touchend: ['touchend'],
  longtap: ['longtap'],
  input: ['input'],
  blur: ['change', 'blur'],
  submit: ['submit'],
  focus: ['focus'],
  scrolltoupper: ['scrolltoupper'],
  scrolltolower: ['scrolltolower'],
  scroll: ['scroll']
};

/*  */

// import { namespaceMap } from 'mp/util/index'

var obj = {};

function createElement$1 (tagName, vnode) {
  return obj
}

function createElementNS (namespace, tagName) {
  return obj
}

function createTextNode (text) {
  return obj
}

function createComment (text) {
  return obj
}

function insertBefore (parentNode, newNode, referenceNode) {}

function removeChild (node, child) {}

function appendChild (node, child) {}

function parentNode (node) {
  return obj
}

function nextSibling (node) {
  return obj
}

function tagName (node) {
  return 'div'
}

function setTextContent (node, text) {
  return obj
}

function setAttribute (node, key, val) {
  return obj
}


var nodeOps = Object.freeze({
	createElement: createElement$1,
	createElementNS: createElementNS,
	createTextNode: createTextNode,
	createComment: createComment,
	insertBefore: insertBefore,
	removeChild: removeChild,
	appendChild: appendChild,
	parentNode: parentNode,
	nextSibling: nextSibling,
	tagName: tagName,
	setTextContent: setTextContent,
	setAttribute: setAttribute
});

/*  */

var ref = {
  create: function create (_, vnode) {
    registerRef(vnode);
  },
  update: function update (oldVnode, vnode) {
    if (oldVnode.data.ref !== vnode.data.ref) {
      registerRef(oldVnode, true);
      registerRef(vnode);
    }
  },
  destroy: function destroy (vnode) {
    registerRef(vnode, true);
  }
};

function registerRef (vnode, isRemoval) {
  var key = vnode.data.ref;
  if (!key) { return }

  var vm = vnode.context;
  var ref = vnode.componentInstance || vnode.elm;
  var refs = vm.$refs;
  if (isRemoval) {
    if (Array.isArray(refs[key])) {
      remove(refs[key], ref);
    } else if (refs[key] === ref) {
      refs[key] = undefined;
    }
  } else {
    if (vnode.data.refInFor) {
      if (!Array.isArray(refs[key])) {
        refs[key] = [ref];
      } else if (refs[key].indexOf(ref) < 0) {
        // $flow-disable-line
        refs[key].push(ref);
      }
    } else {
      refs[key] = ref;
    }
  }
}

/**
 * Virtual DOM patching algorithm based on Snabbdom by
 * Simon Friis Vindum (@paldepind)
 * Licensed under the MIT License
 * https://github.com/paldepind/snabbdom/blob/master/LICENSE
 *
 * modified by Evan You (@yyx990803)
 *

/*
 * Not type-checking this because this file is perf-critical and the cost
 * of making flow understand it is not worth it.
 */

var emptyNode = new VNode('', {}, []);

var hooks = ['create', 'activate', 'update', 'remove', 'destroy'];

function sameVnode (a, b) {
  return (
    a.key === b.key && (
      (
        a.tag === b.tag &&
        a.isComment === b.isComment &&
        isDef(a.data) === isDef(b.data) &&
        sameInputType(a, b)
      ) || (
        isTrue(a.isAsyncPlaceholder) &&
        a.asyncFactory === b.asyncFactory &&
        isUndef(b.asyncFactory.error)
      )
    )
  )
}

// Some browsers do not support dynamically changing type for <input>
// so they need to be treated as different nodes
function sameInputType (a, b) {
  if (a.tag !== 'input') { return true }
  var i;
  var typeA = isDef(i = a.data) && isDef(i = i.attrs) && i.type;
  var typeB = isDef(i = b.data) && isDef(i = i.attrs) && i.type;
  return typeA === typeB
}

function createKeyToOldIdx (children, beginIdx, endIdx) {
  var i, key;
  var map = {};
  for (i = beginIdx; i <= endIdx; ++i) {
    key = children[i].key;
    if (isDef(key)) { map[key] = i; }
  }
  return map
}

function createPatchFunction (backend) {
  var i, j;
  var cbs = {};

  var modules = backend.modules;
  var nodeOps = backend.nodeOps;

  for (i = 0; i < hooks.length; ++i) {
    cbs[hooks[i]] = [];
    for (j = 0; j < modules.length; ++j) {
      if (isDef(modules[j][hooks[i]])) {
        cbs[hooks[i]].push(modules[j][hooks[i]]);
      }
    }
  }

  function emptyNodeAt (elm) {
    return new VNode(nodeOps.tagName(elm).toLowerCase(), {}, [], undefined, elm)
  }

  function createRmCb (childElm, listeners) {
    function remove$$1 () {
      if (--remove$$1.listeners === 0) {
        removeNode(childElm);
      }
    }
    remove$$1.listeners = listeners;
    return remove$$1
  }

  function removeNode (el) {
    var parent = nodeOps.parentNode(el);
    // element may have already been removed due to v-html / v-text
    if (isDef(parent)) {
      nodeOps.removeChild(parent, el);
    }
  }

  var inPre = 0;
  function createElm (vnode, insertedVnodeQueue, parentElm, refElm, nested) {
    vnode.isRootInsert = !nested; // for transition enter check
    if (createComponent(vnode, insertedVnodeQueue, parentElm, refElm)) {
      return
    }

    var data = vnode.data;
    var children = vnode.children;
    var tag = vnode.tag;
    if (isDef(tag)) {
      vnode.elm = vnode.ns
        ? nodeOps.createElementNS(vnode.ns, tag)
        : nodeOps.createElement(tag, vnode);
      setScope(vnode);

      /* istanbul ignore if */
      {
        createChildren(vnode, children, insertedVnodeQueue);
        if (isDef(data)) {
          invokeCreateHooks(vnode, insertedVnodeQueue);
        }
        insert(parentElm, vnode.elm, refElm);
      }

      if (false) {
        inPre--;
      }
    } else if (isTrue(vnode.isComment)) {
      vnode.elm = nodeOps.createComment(vnode.text);
      insert(parentElm, vnode.elm, refElm);
    } else {
      vnode.elm = nodeOps.createTextNode(vnode.text);
      insert(parentElm, vnode.elm, refElm);
    }
  }

  function createComponent (vnode, insertedVnodeQueue, parentElm, refElm) {
    var i = vnode.data;
    if (isDef(i)) {
      var isReactivated = isDef(vnode.componentInstance) && i.keepAlive;
      if (isDef(i = i.hook) && isDef(i = i.init)) {
        i(vnode, false /* hydrating */, parentElm, refElm);
      }
      // after calling the init hook, if the vnode is a child component
      // it should've created a child instance and mounted it. the child
      // component also has set the placeholder vnode's elm.
      // in that case we can just return the element and be done.
      if (isDef(vnode.componentInstance)) {
        initComponent(vnode, insertedVnodeQueue);
        if (isTrue(isReactivated)) {
          reactivateComponent(vnode, insertedVnodeQueue, parentElm, refElm);
        }
        return true
      }
    }
  }

  function initComponent (vnode, insertedVnodeQueue) {
    if (isDef(vnode.data.pendingInsert)) {
      insertedVnodeQueue.push.apply(insertedVnodeQueue, vnode.data.pendingInsert);
      vnode.data.pendingInsert = null;
    }
    vnode.elm = vnode.componentInstance.$el;
    if (isPatchable(vnode)) {
      invokeCreateHooks(vnode, insertedVnodeQueue);
      setScope(vnode);
    } else {
      // empty component root.
      // skip all element-related modules except for ref (#3455)
      registerRef(vnode);
      // make sure to invoke the insert hook
      insertedVnodeQueue.push(vnode);
    }
  }

  function reactivateComponent (vnode, insertedVnodeQueue, parentElm, refElm) {
    var i;
    // hack for #4339: a reactivated component with inner transition
    // does not trigger because the inner node's created hooks are not called
    // again. It's not ideal to involve module-specific logic in here but
    // there doesn't seem to be a better way to do it.
    var innerNode = vnode;
    while (innerNode.componentInstance) {
      innerNode = innerNode.componentInstance._vnode;
      if (isDef(i = innerNode.data) && isDef(i = i.transition)) {
        for (i = 0; i < cbs.activate.length; ++i) {
          cbs.activate[i](emptyNode, innerNode);
        }
        insertedVnodeQueue.push(innerNode);
        break
      }
    }
    // unlike a newly created component,
    // a reactivated keep-alive component doesn't insert itself
    insert(parentElm, vnode.elm, refElm);
  }

  function insert (parent, elm, ref$$1) {
    if (isDef(parent)) {
      if (isDef(ref$$1)) {
        if (ref$$1.parentNode === parent) {
          nodeOps.insertBefore(parent, elm, ref$$1);
        }
      } else {
        nodeOps.appendChild(parent, elm);
      }
    }
  }

  function createChildren (vnode, children, insertedVnodeQueue) {
    if (Array.isArray(children)) {
      for (var i = 0; i < children.length; ++i) {
        createElm(children[i], insertedVnodeQueue, vnode.elm, null, true);
      }
    } else if (isPrimitive(vnode.text)) {
      nodeOps.appendChild(vnode.elm, nodeOps.createTextNode(vnode.text));
    }
  }

  function isPatchable (vnode) {
    while (vnode.componentInstance) {
      vnode = vnode.componentInstance._vnode;
    }
    return isDef(vnode.tag)
  }

  function invokeCreateHooks (vnode, insertedVnodeQueue) {
    for (var i$1 = 0; i$1 < cbs.create.length; ++i$1) {
      cbs.create[i$1](emptyNode, vnode);
    }
    i = vnode.data.hook; // Reuse variable
    if (isDef(i)) {
      if (isDef(i.create)) { i.create(emptyNode, vnode); }
      if (isDef(i.insert)) { insertedVnodeQueue.push(vnode); }
    }
  }

  // set scope id attribute for scoped CSS.
  // this is implemented as a special case to avoid the overhead
  // of going through the normal attribute patching process.
  function setScope (vnode) {
    var i;
    var ancestor = vnode;
    while (ancestor) {
      if (isDef(i = ancestor.context) && isDef(i = i.$options._scopeId)) {
        nodeOps.setAttribute(vnode.elm, i, '');
      }
      ancestor = ancestor.parent;
    }
    // for slot content they should also get the scopeId from the host instance.
    if (isDef(i = activeInstance) &&
      i !== vnode.context &&
      isDef(i = i.$options._scopeId)
    ) {
      nodeOps.setAttribute(vnode.elm, i, '');
    }
  }

  function addVnodes (parentElm, refElm, vnodes, startIdx, endIdx, insertedVnodeQueue) {
    for (; startIdx <= endIdx; ++startIdx) {
      createElm(vnodes[startIdx], insertedVnodeQueue, parentElm, refElm);
    }
  }

  function invokeDestroyHook (vnode) {
    var i, j;
    var data = vnode.data;
    if (isDef(data)) {
      if (isDef(i = data.hook) && isDef(i = i.destroy)) { i(vnode); }
      for (i = 0; i < cbs.destroy.length; ++i) { cbs.destroy[i](vnode); }
    }
    if (isDef(i = vnode.children)) {
      for (j = 0; j < vnode.children.length; ++j) {
        invokeDestroyHook(vnode.children[j]);
      }
    }
  }

  function removeVnodes (parentElm, vnodes, startIdx, endIdx) {
    for (; startIdx <= endIdx; ++startIdx) {
      var ch = vnodes[startIdx];
      if (isDef(ch)) {
        if (isDef(ch.tag)) {
          removeAndInvokeRemoveHook(ch);
          invokeDestroyHook(ch);
        } else { // Text node
          removeNode(ch.elm);
        }
      }
    }
  }

  function removeAndInvokeRemoveHook (vnode, rm) {
    if (isDef(rm) || isDef(vnode.data)) {
      var i;
      var listeners = cbs.remove.length + 1;
      if (isDef(rm)) {
        // we have a recursively passed down rm callback
        // increase the listeners count
        rm.listeners += listeners;
      } else {
        // directly removing
        rm = createRmCb(vnode.elm, listeners);
      }
      // recursively invoke hooks on child component root node
      if (isDef(i = vnode.componentInstance) && isDef(i = i._vnode) && isDef(i.data)) {
        removeAndInvokeRemoveHook(i, rm);
      }
      for (i = 0; i < cbs.remove.length; ++i) {
        cbs.remove[i](vnode, rm);
      }
      if (isDef(i = vnode.data.hook) && isDef(i = i.remove)) {
        i(vnode, rm);
      } else {
        rm();
      }
    } else {
      removeNode(vnode.elm);
    }
  }

  function updateChildren (parentElm, oldCh, newCh, insertedVnodeQueue, removeOnly) {
    var oldStartIdx = 0;
    var newStartIdx = 0;
    var oldEndIdx = oldCh.length - 1;
    var oldStartVnode = oldCh[0];
    var oldEndVnode = oldCh[oldEndIdx];
    var newEndIdx = newCh.length - 1;
    var newStartVnode = newCh[0];
    var newEndVnode = newCh[newEndIdx];
    var oldKeyToIdx, idxInOld, elmToMove, refElm;

    // removeOnly is a special flag used only by <transition-group>
    // to ensure removed elements stay in correct relative positions
    // during leaving transitions
    var canMove = !removeOnly;

    while (oldStartIdx <= oldEndIdx && newStartIdx <= newEndIdx) {
      if (isUndef(oldStartVnode)) {
        oldStartVnode = oldCh[++oldStartIdx]; // Vnode has been moved left
      } else if (isUndef(oldEndVnode)) {
        oldEndVnode = oldCh[--oldEndIdx];
      } else if (sameVnode(oldStartVnode, newStartVnode)) {
        patchVnode(oldStartVnode, newStartVnode, insertedVnodeQueue);
        oldStartVnode = oldCh[++oldStartIdx];
        newStartVnode = newCh[++newStartIdx];
      } else if (sameVnode(oldEndVnode, newEndVnode)) {
        patchVnode(oldEndVnode, newEndVnode, insertedVnodeQueue);
        oldEndVnode = oldCh[--oldEndIdx];
        newEndVnode = newCh[--newEndIdx];
      } else if (sameVnode(oldStartVnode, newEndVnode)) { // Vnode moved right
        patchVnode(oldStartVnode, newEndVnode, insertedVnodeQueue);
        canMove && nodeOps.insertBefore(parentElm, oldStartVnode.elm, nodeOps.nextSibling(oldEndVnode.elm));
        oldStartVnode = oldCh[++oldStartIdx];
        newEndVnode = newCh[--newEndIdx];
      } else if (sameVnode(oldEndVnode, newStartVnode)) { // Vnode moved left
        patchVnode(oldEndVnode, newStartVnode, insertedVnodeQueue);
        canMove && nodeOps.insertBefore(parentElm, oldEndVnode.elm, oldStartVnode.elm);
        oldEndVnode = oldCh[--oldEndIdx];
        newStartVnode = newCh[++newStartIdx];
      } else {
        if (isUndef(oldKeyToIdx)) { oldKeyToIdx = createKeyToOldIdx(oldCh, oldStartIdx, oldEndIdx); }
        idxInOld = isDef(newStartVnode.key) ? oldKeyToIdx[newStartVnode.key] : null;
        if (isUndef(idxInOld)) { // New element
          createElm(newStartVnode, insertedVnodeQueue, parentElm, oldStartVnode.elm);
          newStartVnode = newCh[++newStartIdx];
        } else {
          elmToMove = oldCh[idxInOld];
          /* istanbul ignore if */
          if (false) {
            warn(
              'It seems there are duplicate keys that is causing an update error. ' +
              'Make sure each v-for item has a unique key.'
            );
          }
          if (sameVnode(elmToMove, newStartVnode)) {
            patchVnode(elmToMove, newStartVnode, insertedVnodeQueue);
            oldCh[idxInOld] = undefined;
            canMove && nodeOps.insertBefore(parentElm, elmToMove.elm, oldStartVnode.elm);
            newStartVnode = newCh[++newStartIdx];
          } else {
            // same key but different element. treat as new element
            createElm(newStartVnode, insertedVnodeQueue, parentElm, oldStartVnode.elm);
            newStartVnode = newCh[++newStartIdx];
          }
        }
      }
    }
    if (oldStartIdx > oldEndIdx) {
      refElm = isUndef(newCh[newEndIdx + 1]) ? null : newCh[newEndIdx + 1].elm;
      addVnodes(parentElm, refElm, newCh, newStartIdx, newEndIdx, insertedVnodeQueue);
    } else if (newStartIdx > newEndIdx) {
      removeVnodes(parentElm, oldCh, oldStartIdx, oldEndIdx);
    }
  }

  function patchVnode (oldVnode, vnode, insertedVnodeQueue, removeOnly) {
    if (oldVnode === vnode) {
      return
    }

    var elm = vnode.elm = oldVnode.elm;

    if (isTrue(oldVnode.isAsyncPlaceholder)) {
      if (isDef(vnode.asyncFactory.resolved)) {
        hydrate(oldVnode.elm, vnode, insertedVnodeQueue);
      } else {
        vnode.isAsyncPlaceholder = true;
      }
      return
    }

    // reuse element for static trees.
    // note we only do this if the vnode is cloned -
    // if the new node is not cloned it means the render functions have been
    // reset by the hot-reload-api and we need to do a proper re-render.
    if (isTrue(vnode.isStatic) &&
      isTrue(oldVnode.isStatic) &&
      vnode.key === oldVnode.key &&
      (isTrue(vnode.isCloned) || isTrue(vnode.isOnce))
    ) {
      vnode.componentInstance = oldVnode.componentInstance;
      return
    }

    var i;
    var data = vnode.data;
    if (isDef(data) && isDef(i = data.hook) && isDef(i = i.prepatch)) {
      i(oldVnode, vnode);
    }

    var oldCh = oldVnode.children;
    var ch = vnode.children;
    if (isDef(data) && isPatchable(vnode)) {
      for (i = 0; i < cbs.update.length; ++i) { cbs.update[i](oldVnode, vnode); }
      if (isDef(i = data.hook) && isDef(i = i.update)) { i(oldVnode, vnode); }
    }
    if (isUndef(vnode.text)) {
      if (isDef(oldCh) && isDef(ch)) {
        if (oldCh !== ch) { updateChildren(elm, oldCh, ch, insertedVnodeQueue, removeOnly); }
      } else if (isDef(ch)) {
        if (isDef(oldVnode.text)) { nodeOps.setTextContent(elm, ''); }
        addVnodes(elm, null, ch, 0, ch.length - 1, insertedVnodeQueue);
      } else if (isDef(oldCh)) {
        removeVnodes(elm, oldCh, 0, oldCh.length - 1);
      } else if (isDef(oldVnode.text)) {
        nodeOps.setTextContent(elm, '');
      }
    } else if (oldVnode.text !== vnode.text) {
      nodeOps.setTextContent(elm, vnode.text);
    }
    if (isDef(data)) {
      if (isDef(i = data.hook) && isDef(i = i.postpatch)) { i(oldVnode, vnode); }
    }
  }

  function invokeInsertHook (vnode, queue, initial) {
    // delay insert hooks for component root nodes, invoke them after the
    // element is really inserted
    if (isTrue(initial) && isDef(vnode.parent)) {
      vnode.parent.data.pendingInsert = queue;
    } else {
      for (var i = 0; i < queue.length; ++i) {
        queue[i].data.hook.insert(queue[i]);
      }
    }
  }

  var bailed = false;
  // list of modules that can skip create hook during hydration because they
  // are already rendered on the client or has no need for initialization
  var isRenderedModule = makeMap('attrs,style,class,staticClass,staticStyle,key');

  // Note: this is a browser-only function so we can assume elms are DOM nodes.
  function hydrate (elm, vnode, insertedVnodeQueue) {
    if (isTrue(vnode.isComment) && isDef(vnode.asyncFactory)) {
      vnode.elm = elm;
      vnode.isAsyncPlaceholder = true;
      return true
    }
    vnode.elm = elm;
    var tag = vnode.tag;
    var data = vnode.data;
    var children = vnode.children;
    if (isDef(data)) {
      if (isDef(i = data.hook) && isDef(i = i.init)) { i(vnode, true /* hydrating */); }
      if (isDef(i = vnode.componentInstance)) {
        // child component. it should have hydrated its own tree.
        initComponent(vnode, insertedVnodeQueue);
        return true
      }
    }
    if (isDef(tag)) {
      if (isDef(children)) {
        // empty element, allow client to pick up and populate children
        if (!elm.hasChildNodes()) {
          createChildren(vnode, children, insertedVnodeQueue);
        } else {
          var childrenMatch = true;
          var childNode = elm.firstChild;
          for (var i$1 = 0; i$1 < children.length; i$1++) {
            if (!childNode || !hydrate(childNode, children[i$1], insertedVnodeQueue)) {
              childrenMatch = false;
              break
            }
            childNode = childNode.nextSibling;
          }
          // if childNode is not null, it means the actual childNodes list is
          // longer than the virtual children list.
          if (!childrenMatch || childNode) {
            if (false
            ) {
              bailed = true;
              console.warn('Parent: ', elm);
              console.warn('Mismatching childNodes vs. VNodes: ', elm.childNodes, children);
            }
            return false
          }
        }
      }
      if (isDef(data)) {
        for (var key in data) {
          if (!isRenderedModule(key)) {
            invokeCreateHooks(vnode, insertedVnodeQueue);
            break
          }
        }
      }
    } else if (elm.data !== vnode.text) {
      elm.data = vnode.text;
    }
    return true
  }

  return function patch (oldVnode, vnode, hydrating, removeOnly, parentElm, refElm) {
    if (isUndef(vnode)) {
      if (isDef(oldVnode)) { invokeDestroyHook(oldVnode); }
      return
    }

    var isInitialPatch = false;
    var insertedVnodeQueue = [];

    if (isUndef(oldVnode)) {
      // empty mount (likely as component), create new root element
      isInitialPatch = true;
      createElm(vnode, insertedVnodeQueue, parentElm, refElm);
    } else {
      var isRealElement = isDef(oldVnode.nodeType);
      if (!isRealElement && sameVnode(oldVnode, vnode)) {
        // patch existing root node
        patchVnode(oldVnode, vnode, insertedVnodeQueue, removeOnly);
      } else {
        if (isRealElement) {
          // mounting to a real element
          // check if this is server-rendered content and if we can perform
          // a successful hydration.
          if (oldVnode.nodeType === 1 && oldVnode.hasAttribute(SSR_ATTR)) {
            oldVnode.removeAttribute(SSR_ATTR);
            hydrating = true;
          }
          if (isTrue(hydrating)) {
            if (hydrate(oldVnode, vnode, insertedVnodeQueue)) {
              invokeInsertHook(vnode, insertedVnodeQueue, true);
              return oldVnode
            } else {}
          }
          // either not server-rendered, or hydration failed.
          // create an empty node and replace it
          oldVnode = emptyNodeAt(oldVnode);
        }
        // replacing existing element
        var oldElm = oldVnode.elm;
        var parentElm$1 = nodeOps.parentNode(oldElm);
        createElm(
          vnode,
          insertedVnodeQueue,
          // extremely rare edge case: do not insert if old element is in a
          // leaving transition. Only happens when combining transition +
          // keep-alive + HOCs. (#4590)
          oldElm._leaveCb ? null : parentElm$1,
          nodeOps.nextSibling(oldElm)
        );

        if (isDef(vnode.parent)) {
          // component root element replaced.
          // update parent placeholder node element, recursively
          var ancestor = vnode.parent;
          while (ancestor) {
            ancestor.elm = vnode.elm;
            ancestor = ancestor.parent;
          }
          if (isPatchable(vnode)) {
            for (var i = 0; i < cbs.create.length; ++i) {
              cbs.create[i](emptyNode, vnode.parent);
            }
          }
        }

        if (isDef(parentElm$1)) {
          removeVnodes(parentElm$1, [oldVnode], 0, 0);
        } else if (isDef(oldVnode.tag)) {
          invokeDestroyHook(oldVnode);
        }
      }
    }

    invokeInsertHook(vnode, insertedVnodeQueue, isInitialPatch);
    return vnode.elm
  }
}

/*  */

// import baseModules from 'core/vdom/modules/index'
// const platformModules = []
// import platformModules from 'web/runtime/modules/index'

// the directive module should be applied last, after all
// built-in modules have been applied.
// const modules = platformModules.concat(baseModules)
var modules = [ref];

var corePatch = createPatchFunction({ nodeOps: nodeOps, modules: modules });

function patch () {
  corePatch.apply(this, arguments);
  this.$updateDataToMP();
}

function callHook$1 (vm, hook, params) {
  var handlers = vm.$options[hook];
  if (hook === 'onError' && handlers) {
    handlers = [handlers];
  } else if (hook === 'onPageNotFound' && handlers) {
    handlers = [handlers];
  }

  var ret;
  if (handlers) {
    for (var i = 0, j = handlers.length; i < j; i++) {
      try {
        ret = handlers[i].call(vm, params);
      } catch (e) {
        handleError(e, vm, (hook + " hook"));
      }
    }
  }
  if (vm._hasHookEvent) {
    vm.$emit('hook:' + hook);
  }

  // for child
  if (vm.$children.length) {
    vm.$children.forEach(function (v) { return callHook$1(v, hook, params); });
  }

  return ret
}

// mpType 小程序实例的类型，可能的值是 'app', 'page'
// rootVueVM 是 vue 的根组件实例，子组件中访问 this.$root 可得
function getGlobalData (app, rootVueVM) {
  var mp = rootVueVM.$mp;
  if (app && app.globalData) {
    mp.appOptions = app.globalData.appOptions;
  }
}

// 格式化 properties 属性，并给每个属性加上 observer 方法

// properties 的 一些类型 https://developers.weixin.qq.com/miniprogram/dev/framework/custom-component/component.html
// properties: {
//   paramA: Number,
//   myProperty: { // 属性名
//     type: String, // 类型（必填），目前接受的类型包括：String, Number, Boolean, Object, Array, null（表示任意类型）
//     value: '', // 属性初始值（可选），如果未指定则会根据类型选择一个
//     observer: function(newVal, oldVal, changedPath) {
//        // 属性被改变时执行的函数（可选），也可以写成在methods段中定义的方法名字符串, 如：'_propertyChange'
//        // 通常 newVal 就是新设置的数据， oldVal 是旧数据
//     }
//   },
// }

// props 的一些类型 https://cn.vuejs.org/v2/guide/components-props.html#ad
// props: {
//   // 基础的类型检查 (`null` 匹配任何类型)
//   propA: Number,
//   // 多个可能的类型
//   propB: [String, Number],
//   // 必填的字符串
//   propC: {
//     type: String,
//     required: true
//   },
//   // 带有默认值的数字
//   propD: {
//     type: Number,
//     default: 100
//   },
//   // 带有默认值的对象
//   propE: {
//     type: Object,
//     // 对象或数组且一定会从一个工厂函数返回默认值
//     default: function () {
//       return { message: 'hello' }
//     }
//   },
//   // 自定义验证函数
//   propF: {
//     validator: function (value) {
//       // 这个值必须匹配下列字符串中的一个
//       return ['success', 'warning', 'danger'].indexOf(value) !== -1
//     }
//   }
// }

// core/util/options
function normalizeProps$1 (props, res, vm) {
  if (!props) { return }
  var i, val, name;
  if (Array.isArray(props)) {
    i = props.length;
    while (i--) {
      val = props[i];
      if (typeof val === 'string') {
        name = camelize(val);
        res[name] = { type: null };
      } else {}
    }
  } else if (isPlainObject(props)) {
    for (var key in props) {
      val = props[key];
      name = camelize(key);
      res[name] = isPlainObject(val)
        ? val
        : { type: val };
    }
  }

  // fix vueProps to properties
  for (var key$1 in res) {
    if (res.hasOwnProperty(key$1)) {
      var item = res[key$1];
      if (item.default) {
        item.value = item.default;
      }
      var oldObserver = item.observer;
      item.observer = function (newVal, oldVal) {
        vm[name] = newVal;
        // 先修改值再触发原始的 observer，跟 watch 行为保持一致
        if (typeof oldObserver === 'function') {
          oldObserver.call(vm, newVal, oldVal);
        }
      };
    }
  }

  return res
}

function normalizeProperties (vm) {
  var properties = vm.$options.properties;
  var vueProps = vm.$options.props;
  var res = {};

  normalizeProps$1(properties, res, vm);
  normalizeProps$1(vueProps, res, vm);

  return res
}

/**
 * 把 properties 中的属性 proxy 到 vm 上
 */
function initMpProps (vm) {
  var mpProps = vm._mpProps = {};
  var keys = Object.keys(vm.$options.properties || {});
  keys.forEach(function (key) {
    if (!(key in vm)) {
      proxy(vm, '_mpProps', key);
      mpProps[key] = undefined; // for observe
    }
  });
  observe(mpProps, true);
}

function initMP (mpType, next) {
  var rootVueVM = this.$root;
  if (!rootVueVM.$mp) {
    rootVueVM.$mp = {};
  }

  var mp = rootVueVM.$mp;

  // Please do not register multiple Pages
  // if (mp.registered) {
  if (mp.status) {
    // 处理子组件的小程序生命周期
    if (mpType === 'app') {
      callHook$1(this, 'onLaunch', mp.appOptions);
    } else {
      callHook$1(this, 'onLoad', mp.query);
      callHook$1(this, 'onReady');
    }
    return next()
  }
  // mp.registered = true

  mp.mpType = mpType;
  mp.status = 'register';

  if (mpType === 'app') {
    global.App({
      // 页面的初始数据
      globalData: {
        appOptions: {}
      },

      handleProxy: function handleProxy (e) {
        return rootVueVM.$handleProxyWithVue(e)
      },

      // Do something initial when launch.
      onLaunch: function onLaunch (options) {
        if ( options === void 0 ) options = {};

        mp.app = this;
        mp.status = 'launch';
        this.globalData.appOptions = mp.appOptions = options;
        callHook$1(rootVueVM, 'onLaunch', options);
        next();
      },

      // Do something when app show.
      onShow: function onShow (options) {
        if ( options === void 0 ) options = {};

        mp.status = 'show';
        this.globalData.appOptions = mp.appOptions = options;
        callHook$1(rootVueVM, 'onShow', options);
      },

      // Do something when app hide.
      onHide: function onHide () {
        mp.status = 'hide';
        callHook$1(rootVueVM, 'onHide');
      },

      onError: function onError (err) {
        callHook$1(rootVueVM, 'onError', err);
      },

      onPageNotFound: function onPageNotFound (err) {
        callHook$1(rootVueVM, 'onPageNotFound', err);
      }
    });
  } else if (mpType === 'component') {
    initMpProps(rootVueVM);

    global.Component({
      // 小程序原生的组件属性
      properties: normalizeProperties(rootVueVM),
      // 页面的初始数据
      data: {
        $root: {}
      },
      methods: {
        handleProxy: function handleProxy (e) {
          return rootVueVM.$handleProxyWithVue(e)
        }
      },
      // mp lifecycle for vue
      // 组件生命周期函数，在组件实例进入页面节点树时执行，注意此时不能调用 setData
      created: function created () {
        mp.status = 'created';
        mp.page = this;
      },
      // 组件生命周期函数，在组件实例进入页面节点树时执行
      attached: function attached () {
        mp.status = 'attached';
        callHook$1(rootVueVM, 'attached');
      },
      // 组件生命周期函数，在组件布局完成后执行，此时可以获取节点信息（使用 SelectorQuery ）
      ready: function ready () {
        mp.status = 'ready';

        callHook$1(rootVueVM, 'ready');
        next();

        // 只有页面需要 setData
        rootVueVM.$nextTick(function () {
          rootVueVM._initDataToMP();
        });
      },
      // 组件生命周期函数，在组件实例被移动到节点树另一个位置时执行
      moved: function moved () {
        callHook$1(rootVueVM, 'moved');
      },
      // 组件生命周期函数，在组件实例被从页面节点树移除时执行
      detached: function detached () {
        mp.status = 'detached';
        callHook$1(rootVueVM, 'detached');
      }
    });
  } else {
    var app = global.getApp();
    global.Page({
      // 页面的初始数据
      data: {
        $root: {}
      },

      handleProxy: function handleProxy (e) {
        return rootVueVM.$handleProxyWithVue(e)
      },

      // mp lifecycle for vue
      // 生命周期函数--监听页面加载
      onLoad: function onLoad (query) {
        mp.page = this;
        mp.query = query;
        mp.status = 'load';
        getGlobalData(app, rootVueVM);
        callHook$1(rootVueVM, 'onLoad', query);
      },

      // 生命周期函数--监听页面显示
      onShow: function onShow () {
        mp.page = this;
        mp.status = 'show';
        callHook$1(rootVueVM, 'onShow');

        // 只有页面需要 setData
        rootVueVM.$nextTick(function () {
          rootVueVM._initDataToMP();
        });
      },

      // 生命周期函数--监听页面初次渲染完成
      onReady: function onReady () {
        mp.status = 'ready';

        callHook$1(rootVueVM, 'onReady');
        next();
      },

      // 生命周期函数--监听页面隐藏
      onHide: function onHide () {
        mp.status = 'hide';
        callHook$1(rootVueVM, 'onHide');
        mp.page = null;
      },

      // 生命周期函数--监听页面卸载
      onUnload: function onUnload () {
        mp.status = 'unload';
        callHook$1(rootVueVM, 'onUnload');
        mp.page = null;
      },

      // 页面相关事件处理函数--监听用户下拉动作
      onPullDownRefresh: function onPullDownRefresh () {
        callHook$1(rootVueVM, 'onPullDownRefresh');
      },

      // 页面上拉触底事件的处理函数
      onReachBottom: function onReachBottom () {
        callHook$1(rootVueVM, 'onReachBottom');
      },

      // 用户点击右上角分享
      onShareAppMessage: rootVueVM.$options.onShareAppMessage
        ? function (options) { return callHook$1(rootVueVM, 'onShareAppMessage', options); } : null,

      // Do something when page scroll
      onPageScroll: function onPageScroll (options) {
        callHook$1(rootVueVM, 'onPageScroll', options);
      },

      // 当前是 tab 页时，点击 tab 时触发
      onTabItemTap: function onTabItemTap (options) {
        callHook$1(rootVueVM, 'onTabItemTap', options);
      }
    });
  }
}

var updateDataTotal = 0; // 总共更新的数据量
function diffLog (updateData) {
  updateData = JSON.stringify(updateData);
  if (!Vue$3._mpvueTraceTimer) {
    Vue$3._mpvueTraceTimer = setTimeout(function () {
      clearTimeout(Vue$3._mpvueTraceTimer);
      updateDataTotal = (updateDataTotal / 1024).toFixed(1);
      console.log('这次操作引发500ms内数据更新量:' + updateDataTotal + 'kb');
      Vue$3._mpvueTraceTimer = 0;
      updateDataTotal = 0;
    }, 500);
  } else if (Vue$3._mpvueTraceTimer) {
    updateData = updateData.replace(/[^\u0000-\u00ff]/g, 'aa'); // 中文占2字节，中文替换成两个字母计算占用空间
    updateDataTotal += updateData.length;
  }
}

var KEY_SEP$1 = '_';

function getDeepData (keyList, viewData) {
  if (keyList.length > 1) {
    var _key = keyList.splice(0, 1);
    var _viewData = viewData[_key];
    if (_viewData) {
      return getDeepData(keyList, _viewData)
    } else {
      return null
    }
  } else {
    if (viewData[keyList[0]]) {
      return viewData[keyList[0]]
    } else {
      return null
    }
  }
}

function compareAndSetDeepData (key, newData, vm, data, forceUpdate) {
  // 比较引用类型数据
  try {
    var keyList = key.split('.');
    // page.__viewData__老版小程序不存在，使用mpvue里绑的data比对
    var oldData = getDeepData(keyList, vm.$root.$mp.page.data);
    if (oldData === null || JSON.stringify(oldData) !== JSON.stringify(newData) || forceUpdate) {
      data[key] = newData;
    } else {
      var keys = Object.keys(oldData);
      keys.forEach(function (_key) {
        var properties = Object.getOwnPropertyDescriptor(oldData, _key);
        if (!properties['get'] && !properties['set']) {
          data[key + '.' + _key] = newData[_key];
        }
      });
    }
  } catch (e) {
    console.log(e, key, newData, vm);
  }
}

function cleanKeyPath (vm) {
  if (vm.__mpKeyPath) {
    Object.keys(vm.__mpKeyPath).forEach(function (_key) {
      delete vm.__mpKeyPath[_key]['__keyPath'];
    });
  }
}

function minifyDeepData (rootKey, originKey, vmData, data, _mpValueSet, vm) {
  try {
    if (vmData instanceof Array) {
       // 数组
      compareAndSetDeepData(rootKey + '.' + originKey, vmData, vm, data, true);
    } else {
      // Object
      var _keyPathOnThis = {}; // 存储这层对象的keyPath
      if (vmData.__keyPath && !vmData.__newReference) {
        // 有更新列表 ，按照更新列表更新
        _keyPathOnThis = vmData.__keyPath;
        Object.keys(vmData).forEach(function (_key) {
          if (vmData[_key] instanceof Object) {
            // 引用类型 递归
            if (_key === '__keyPath') {
              return
            }
            minifyDeepData(rootKey + '.' + originKey, _key, vmData[_key], data, null, vm);
          } else {
            // 更新列表中的 加入data
            if (_keyPathOnThis[_key] === true) {
              if (originKey) {
                data[rootKey + '.' + originKey + '.' + _key] = vmData[_key];
              } else {
                data[rootKey + '.' + _key] = vmData[_key];
              }
            }
          }
        });
         // 根节点可能有父子引用同一个引用类型数据，依赖树都遍历完后清理
        vm['__mpKeyPath'] = vm['__mpKeyPath'] || {};
        vm['__mpKeyPath'][vmData.__ob__.dep.id] = vmData;
      } else {
        // 没有更新列表
        compareAndSetDeepData(rootKey + '.' + originKey, vmData, vm, data);
      }
      // 标记是否是通过this.Obj = {} 赋值印发的改动，解决少更新问题#1305
      def(vmData, '__newReference', false, false);
    }
  } catch (e) {
    console.log(e, rootKey, originKey, vmData, data);
  }
}

function getRootKey (vm, rootKey) {
  if (!vm.$parent.$attrs) {
    rootKey = '$root.0' + KEY_SEP$1 + rootKey;
    return rootKey
  } else {
    rootKey = vm.$parent.$attrs.mpcomid + KEY_SEP$1 + rootKey;
    return getRootKey(vm.$parent, rootKey)
  }
}

function diffData (vm, data) {
  var vmData = vm._data || {};
  var vmProps = vm._props || {};
  var rootKey = '';
  if (!vm.$attrs) {
    rootKey = '$root.0';
  } else {
    rootKey = getRootKey(vm, vm.$attrs.mpcomid);
  }
  Vue$3.nextTick(function () {
    cleanKeyPath(vm);
  });
  // console.log(rootKey)

  // 值类型变量不考虑优化，还是直接更新
  var __keyPathOnThis = vmData.__keyPath || vm.__keyPath || {};
  delete vm.__keyPath;
  delete vmData.__keyPath;
  delete vmProps.__keyPath;
  if (vm._mpValueSet === 'done') {
    // 第二次赋值才进行缩减操作
    Object.keys(vmData).forEach(function (vmDataItemKey) {
      if (vmData[vmDataItemKey] instanceof Object) {
        // 引用类型
        minifyDeepData(rootKey, vmDataItemKey, vmData[vmDataItemKey], data, vm._mpValueSet, vm);
      } else if (vmData[vmDataItemKey] !== undefined) {
        // _data上的值属性只有要更新的时候才赋值
        if (__keyPathOnThis[vmDataItemKey] === true) {
          data[rootKey + '.' + vmDataItemKey] = vmData[vmDataItemKey];
        }
      }
    });

    Object.keys(vmProps).forEach(function (vmPropsItemKey) {
      if (vmProps[vmPropsItemKey] instanceof Object) {
        // 引用类型
        minifyDeepData(rootKey, vmPropsItemKey, vmProps[vmPropsItemKey], data, vm._mpValueSet, vm);
      } else if (vmProps[vmPropsItemKey] !== undefined) {
        data[rootKey + '.' + vmPropsItemKey] = vmProps[vmPropsItemKey];
      }
      // _props上的值属性只有要更新的时候才赋值
    });

    // 检查完data和props,最后补上_mpProps & _computedWatchers
    var vmMpProps = vm._mpProps || {};
    var vmComputedWatchers = vm._computedWatchers || {};
    Object.keys(vmMpProps).forEach(function (mpItemKey) {
      data[rootKey + '.' + mpItemKey] = vm[mpItemKey];
    });
    Object.keys(vmComputedWatchers).forEach(function (computedItemKey) {
      data[rootKey + '.' + computedItemKey] = vm[computedItemKey];
    });
    // 更新的时候要删除$root.0:{},否则会覆盖原正确数据
    delete data[rootKey];
  }
  if (vm._mpValueSet === undefined) {
    // 第一次设置数据成功后，标记位置true,再更新到这个节点如果没有keyPath数组认为不需要更新
    vm._mpValueSet = 'done';
  }
  if (Vue$3.config._mpTrace) {
    // console.log('更新VM节点', vm)
    // console.log('实际传到Page.setData数据', data)
    diffLog(data);
  }
}

// 节流方法，性能优化
// 全局的命名约定，为了节省编译的包大小一律采取形象的缩写，说明如下。
// $c === $child
// $k === $comKey

// 新型的被拍平的数据结构
// {
//   $root: {
//     '1-1'{
//       // ... data
//     },
//     '1.2-1': {
//       // ... data1
//     },
//     '1.2-2': {
//       // ... data2
//     }
//   }
// }

var KEY_SEP = '_';

function getVmData (vm) {
  // 确保当前 vm 所有数据被同步
  var dataKeys = [].concat(
    Object.keys(vm._data || {}),
    Object.keys(vm._props || {}),
    Object.keys(vm._mpProps || {}),
    Object.keys(vm._computedWatchers || {})
  );
  return dataKeys.reduce(function (res, key) {
    res[key] = vm[key];
    return res
  }, {})
}

function getParentComKey (vm, res) {
  if ( res === void 0 ) res = [];

  var ref = vm || {};
  var $parent = ref.$parent;
  if (!$parent) { return res }
  res.unshift(getComKey($parent));
  if ($parent.$parent) {
    return getParentComKey($parent, res)
  }
  return res
}

function formatVmData (vm) {
  var $p = getParentComKey(vm).join(KEY_SEP);
  var $k = $p + ($p ? KEY_SEP : '') + getComKey(vm);

  // getVmData 这儿获取当前组件内的所有数据，包含 props、computed 的数据
  // 改动 vue.runtime 所获的的核心能力
  var data = Object.assign(getVmData(vm), { $k: $k, $kk: ("" + $k + KEY_SEP), $p: $p });
  var key = '$root.' + $k;
  var res = {};
  res[key] = data;
  return res
}

function collectVmData (vm, res) {
  if ( res === void 0 ) res = {};

  var vms = vm.$children;
  if (vms && vms.length) {
    vms.forEach(function (v) { return collectVmData(v, res); });
  }
  return Object.assign(res, formatVmData(vm))
}

/**
 * 频率控制 返回函数连续调用时，func 执行频率限定为 次 / wait
 * 自动合并 data
 *
 * @param  {function}   func      传入函数
 * @param  {number}     wait      表示时间窗口的间隔
 * @param  {object}     options   如果想忽略开始边界上的调用，传入{leading: false}。
 *                                如果想忽略结尾边界上的调用，传入{trailing: false}
 * @return {function}             返回客户调用函数
 */
function throttle (func, wait, options) {
  var context, args, result;
  var timeout = null;
  // 上次执行时间点
  var previous = 0;
  if (!options) { options = {}; }
  // 延迟执行函数
  function later () {
    // 若设定了开始边界不执行选项，上次执行时间始终为0
    previous = options.leading === false ? 0 : Date.now();
    timeout = null;
    result = func.apply(context, args);
    if (!timeout) { context = args = null; }
  }
  return function (handle, data) {
    var now = Date.now();
    // 首次执行时，如果设定了开始边界不执行选项，将上次执行时间设定为当前时间。
    if (!previous && options.leading === false) { previous = now; }
    // 延迟执行时间间隔
    var remaining = wait - (now - previous);
    context = this;
    args = args ? [handle, Object.assign(args[1], data)] : [handle, data];
    // 延迟时间间隔remaining小于等于0，表示上次执行至此所间隔时间已经超过一个时间窗口
    // remaining大于时间窗口wait，表示客户端系统时间被调整过
    if (remaining <= 0 || remaining > wait) {
      clearTimeout(timeout);
      timeout = null;
      previous = now;
      result = func.apply(context, args);
      if (!timeout) { context = args = null; }
    // 如果延迟执行不存在，且没有设定结尾边界不执行选项
    } else if (!timeout && options.trailing !== false) {
      timeout = setTimeout(later, remaining);
    }
    return result
  }
}

// 优化频繁的 setData: https://mp.weixin.qq.com/debug/wxadoc/dev/framework/performance/tips.html
var throttleSetData = throttle(function (handle, data) {
  handle(data);
}, 50);

function getPage (vm) {
  var rootVueVM = vm.$root;
  var ref = rootVueVM.$mp || {};
  var mpType = ref.mpType; if ( mpType === void 0 ) mpType = '';
  var page = ref.page;

  // 优化后台态页面进行 setData: https://mp.weixin.qq.com/debug/wxadoc/dev/framework/performance/tips.html
  if (mpType === 'app' || !page || typeof page.setData !== 'function') {
    return
  }
  return page
}

// 优化js变量动态变化时候引起全量更新
// 优化每次 setData 都传递大量新数据
function updateDataToMP () {
  var page = getPage(this);
  if (!page) {
    return
  }

  var data = formatVmData(this);
  diffData(this, data);
  throttleSetData(page.setData.bind(page), data);
}

function initDataToMP () {
  var page = getPage(this);
  if (!page) {
    return
  }

  var data = collectVmData(this.$root);
  page.setData(data);
}

// 虚拟dom的compid与真实dom的comkey匹配，多层嵌套的先补齐虚拟dom的compid直到完全匹配为止
function isVmKeyMatchedCompkey (k, comkey) {
  if (!k || !comkey) {
    return false
  }
  // 完全匹配 comkey = '1_0_1', k = '1_0_1'
  // 部分匹配 comkey = '1_0_10_1', k = '1_0_10'
  // k + KEY_SEP防止k = '1_0_1'误匹配comkey = '1_0_10_1'
  return comkey === k || comkey.indexOf(k + KEY_SEP$2) === 0
}

function getVM (vm, comkeys) {
  if ( comkeys === void 0 ) comkeys = [];

  var keys = comkeys.slice(1);
  if (!keys.length) { return vm }

  // bugfix #1375: 虚拟dom的compid和真实dom的comkey在组件嵌套时匹配出错，comid会丢失前缀，需要从父节点补充
  var comkey = keys.join(KEY_SEP$2);
  var comidPrefix = '';
  return keys.reduce(function (res, key) {
    var len = res.$children.length;
    for (var i = 0; i < len; i++) {
      var v = res.$children[i];
      var k = getComKey(v);
      if (comidPrefix) {
        k = comidPrefix + KEY_SEP$2 + k;
      }
      // 找到匹配的父节点
      if (isVmKeyMatchedCompkey(k, comkey)) {
        comidPrefix = k;
        res = v;
        return res
      }
    }
    return res
  }, vm)
}

function getHandle (vnode, eventid, eventTypes) {
  if ( eventTypes === void 0 ) eventTypes = [];

  var res = [];
  if (!vnode || !vnode.tag) {
    return res
  }

  var ref = vnode || {};
  var data = ref.data; if ( data === void 0 ) data = {};
  var children = ref.children; if ( children === void 0 ) children = [];
  var componentInstance = ref.componentInstance;
  if (componentInstance) {
    // 增加 slot 情况的处理
    // Object.values 会多增加几行编译后的代码
    Object.keys(componentInstance.$slots).forEach(function (slotKey) {
      var slot = componentInstance.$slots[slotKey];
      var slots = Array.isArray(slot) ? slot : [slot];
      slots.forEach(function (node) {
        res = res.concat(getHandle(node, eventid, eventTypes));
      });
    });
  } else {
    // 避免遍历超出当前组件的 vm
    children.forEach(function (node) {
      res = res.concat(getHandle(node, eventid, eventTypes));
    });
  }

  var attrs = data.attrs;
  var on = data.on;
  if (attrs && on && attrs['eventid'] === eventid) {
    eventTypes.forEach(function (et) {
      var h = on[et];
      if (typeof h === 'function') {
        res.push(h);
      } else if (Array.isArray(h)) {
        res = res.concat(h);
      }
    });
    return res
  }

  return res
}

function getWebEventByMP (e) {
  var type = e.type;
  var timeStamp = e.timeStamp;
  var touches = e.touches;
  var detail = e.detail; if ( detail === void 0 ) detail = {};
  var target = e.target; if ( target === void 0 ) target = {};
  var currentTarget = e.currentTarget; if ( currentTarget === void 0 ) currentTarget = {};
  var x = detail.x;
  var y = detail.y;
  var event = {
    mp: e,
    type: type,
    timeStamp: timeStamp,
    x: x,
    y: y,
    target: Object.assign({}, target, detail),
    currentTarget: currentTarget,
    stopPropagation: noop,
    preventDefault: noop
  };

  if (touches && touches.length) {
    Object.assign(event, touches[0]);
    event.touches = touches;
  }
  return event
}

var KEY_SEP$2 = '_';
function handleProxyWithVue (e) {
  var rootVueVM = this.$root;
  var type = e.type;
  var target = e.target; if ( target === void 0 ) target = {};
  var currentTarget = e.currentTarget;
  var ref = currentTarget || target;
  var dataset = ref.dataset; if ( dataset === void 0 ) dataset = {};
  var comkey = dataset.comkey; if ( comkey === void 0 ) comkey = '';
  var eventid = dataset.eventid;
  var vm = getVM(rootVueVM, comkey.split(KEY_SEP$2));

  if (!vm) {
    return
  }

  var webEventTypes = eventTypeMap[type] || [type];
  var handles = getHandle(vm._vnode, eventid, webEventTypes);

  // TODO, enevt 还需要处理更多
  // https://developer.mozilla.org/zh-CN/docs/Web/API/Event
  if (handles.length) {
    var event = getWebEventByMP(e);
    if (handles.length === 1) {
      var result = handles[0](event);
      return result
    }
    handles.forEach(function (h) { return h(event); });
  }
}

// for platforms
// import config from 'core/config'
// install platform specific utils
Vue$3.config.mustUseProp = mustUseProp;
Vue$3.config.isReservedTag = isReservedTag;
Vue$3.config.isReservedAttr = isReservedAttr;
Vue$3.config.getTagNamespace = getTagNamespace;
Vue$3.config.isUnknownElement = isUnknownElement;

// install platform patch function
Vue$3.prototype.__patch__ = patch;

// public mount method
Vue$3.prototype.$mount = function (el, hydrating) {
  var this$1 = this;

  // el = el && inBrowser ? query(el) : undefined
  // return mountComponent(this, el, hydrating)

  // 初始化小程序生命周期相关
  var options = this.$options;

  if (options && (options.render || options.mpType)) {
    var mpType = options.mpType; if ( mpType === void 0 ) mpType = 'page';
    return this._initMP(mpType, function () {
      return mountComponent(this$1, undefined, undefined)
    })
  } else {
    return mountComponent(this, undefined, undefined)
  }
};

// for mp
Vue$3.prototype._initMP = initMP;

Vue$3.prototype.$updateDataToMP = updateDataToMP;
Vue$3.prototype._initDataToMP = initDataToMP;

Vue$3.prototype.$handleProxyWithVue = handleProxyWithVue;

/*  */

return Vue$3;

})));

/* WEBPACK VAR INJECTION */}.call(exports, __webpack_require__(8)))

/***/ }),
/* 1 */
/***/ (function(module, exports) {

/* globals __VUE_SSR_CONTEXT__ */

// this module is a runtime utility for cleaner component module output and will
// be included in the final webpack user bundle

module.exports = function normalizeComponent (
  rawScriptExports,
  compiledTemplate,
  injectStyles,
  scopeId,
  moduleIdentifier /* server only */
) {
  var esModule
  var scriptExports = rawScriptExports = rawScriptExports || {}

  // ES6 modules interop
  var type = typeof rawScriptExports.default
  if (type === 'object' || type === 'function') {
    esModule = rawScriptExports
    scriptExports = rawScriptExports.default
  }

  // Vue.extend constructor export interop
  var options = typeof scriptExports === 'function'
    ? scriptExports.options
    : scriptExports

  // render functions
  if (compiledTemplate) {
    options.render = compiledTemplate.render
    options.staticRenderFns = compiledTemplate.staticRenderFns
  }

  // scopedId
  if (scopeId) {
    options._scopeId = scopeId
  }

  var hook
  if (moduleIdentifier) { // server build
    hook = function (context) {
      // 2.3 injection
      context =
        context || // cached call
        (this.$vnode && this.$vnode.ssrContext) || // stateful
        (this.parent && this.parent.$vnode && this.parent.$vnode.ssrContext) // functional
      // 2.2 with runInNewContext: true
      if (!context && typeof __VUE_SSR_CONTEXT__ !== 'undefined') {
        context = __VUE_SSR_CONTEXT__
      }
      // inject component styles
      if (injectStyles) {
        injectStyles.call(this, context)
      }
      // register component module identifier for async chunk inferrence
      if (context && context._registeredComponents) {
        context._registeredComponents.add(moduleIdentifier)
      }
    }
    // used by ssr in case component is cached and beforeCreate
    // never gets called
    options._ssrRegister = hook
  } else if (injectStyles) {
    hook = injectStyles
  }

  if (hook) {
    var functional = options.functional
    var existing = functional
      ? options.render
      : options.beforeCreate
    if (!functional) {
      // inject component registration as beforeCreate hook
      options.beforeCreate = existing
        ? [].concat(existing, hook)
        : [hook]
    } else {
      // register for functioal component in vue file
      options.render = function renderWithStyleInjection (h, context) {
        hook.call(context)
        return existing(h, context)
      }
    }
  }

  return {
    esModule: esModule,
    exports: scriptExports,
    options: options
  }
}


/***/ }),
/* 2 */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* WEBPACK VAR INJECTION */(function(global) {/* unused harmony export Store */
/* unused harmony export install */
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "b", function() { return mapState; });
/* unused harmony export mapMutations */
/* unused harmony export mapGetters */
/* unused harmony export mapActions */
/* unused harmony export createNamespacedHelpers */
/**
 * vuex v3.1.1
 * (c) 2019 Evan You
 * @license MIT
 */
function applyMixin (Vue) {
  var version = Number(Vue.version.split('.')[0]);

  if (version >= 2) {
    Vue.mixin({ beforeCreate: vuexInit });
  } else {
    // override init and inject vuex init procedure
    // for 1.x backwards compatibility.
    var _init = Vue.prototype._init;
    Vue.prototype._init = function (options) {
      if ( options === void 0 ) options = {};

      options.init = options.init
        ? [vuexInit].concat(options.init)
        : vuexInit;
      _init.call(this, options);
    };
  }

  /**
   * Vuex init hook, injected into each instances init hooks list.
   */

  function vuexInit () {
    var options = this.$options;
    // store injection
    if (options.store) {
      this.$store = typeof options.store === 'function'
        ? options.store()
        : options.store;
    } else if (options.parent && options.parent.$store) {
      this.$store = options.parent.$store;
    }
  }
}

var target = typeof window !== 'undefined'
  ? window
  : typeof global !== 'undefined'
    ? global
    : {};
var devtoolHook = target.__VUE_DEVTOOLS_GLOBAL_HOOK__;

function devtoolPlugin (store) {
  if (!devtoolHook) { return }

  store._devtoolHook = devtoolHook;

  devtoolHook.emit('vuex:init', store);

  devtoolHook.on('vuex:travel-to-state', function (targetState) {
    store.replaceState(targetState);
  });

  store.subscribe(function (mutation, state) {
    devtoolHook.emit('vuex:mutation', mutation, state);
  });
}

/**
 * Get the first item that pass the test
 * by second argument function
 *
 * @param {Array} list
 * @param {Function} f
 * @return {*}
 */

/**
 * forEach for object
 */
function forEachValue (obj, fn) {
  Object.keys(obj).forEach(function (key) { return fn(obj[key], key); });
}

function isObject (obj) {
  return obj !== null && typeof obj === 'object'
}

function isPromise (val) {
  return val && typeof val.then === 'function'
}

function assert (condition, msg) {
  if (!condition) { throw new Error(("[vuex] " + msg)) }
}

function partial (fn, arg) {
  return function () {
    return fn(arg)
  }
}

// Base data struct for store's module, package with some attribute and method
var Module = function Module (rawModule, runtime) {
  this.runtime = runtime;
  // Store some children item
  this._children = Object.create(null);
  // Store the origin module object which passed by programmer
  this._rawModule = rawModule;
  var rawState = rawModule.state;

  // Store the origin module's state
  this.state = (typeof rawState === 'function' ? rawState() : rawState) || {};
};

var prototypeAccessors = { namespaced: { configurable: true } };

prototypeAccessors.namespaced.get = function () {
  return !!this._rawModule.namespaced
};

Module.prototype.addChild = function addChild (key, module) {
  this._children[key] = module;
};

Module.prototype.removeChild = function removeChild (key) {
  delete this._children[key];
};

Module.prototype.getChild = function getChild (key) {
  return this._children[key]
};

Module.prototype.update = function update (rawModule) {
  this._rawModule.namespaced = rawModule.namespaced;
  if (rawModule.actions) {
    this._rawModule.actions = rawModule.actions;
  }
  if (rawModule.mutations) {
    this._rawModule.mutations = rawModule.mutations;
  }
  if (rawModule.getters) {
    this._rawModule.getters = rawModule.getters;
  }
};

Module.prototype.forEachChild = function forEachChild (fn) {
  forEachValue(this._children, fn);
};

Module.prototype.forEachGetter = function forEachGetter (fn) {
  if (this._rawModule.getters) {
    forEachValue(this._rawModule.getters, fn);
  }
};

Module.prototype.forEachAction = function forEachAction (fn) {
  if (this._rawModule.actions) {
    forEachValue(this._rawModule.actions, fn);
  }
};

Module.prototype.forEachMutation = function forEachMutation (fn) {
  if (this._rawModule.mutations) {
    forEachValue(this._rawModule.mutations, fn);
  }
};

Object.defineProperties( Module.prototype, prototypeAccessors );

var ModuleCollection = function ModuleCollection (rawRootModule) {
  // register root module (Vuex.Store options)
  this.register([], rawRootModule, false);
};

ModuleCollection.prototype.get = function get (path) {
  return path.reduce(function (module, key) {
    return module.getChild(key)
  }, this.root)
};

ModuleCollection.prototype.getNamespace = function getNamespace (path) {
  var module = this.root;
  return path.reduce(function (namespace, key) {
    module = module.getChild(key);
    return namespace + (module.namespaced ? key + '/' : '')
  }, '')
};

ModuleCollection.prototype.update = function update$1 (rawRootModule) {
  update([], this.root, rawRootModule);
};

ModuleCollection.prototype.register = function register (path, rawModule, runtime) {
    var this$1 = this;
    if ( runtime === void 0 ) runtime = true;

  if (true) {
    assertRawModule(path, rawModule);
  }

  var newModule = new Module(rawModule, runtime);
  if (path.length === 0) {
    this.root = newModule;
  } else {
    var parent = this.get(path.slice(0, -1));
    parent.addChild(path[path.length - 1], newModule);
  }

  // register nested modules
  if (rawModule.modules) {
    forEachValue(rawModule.modules, function (rawChildModule, key) {
      this$1.register(path.concat(key), rawChildModule, runtime);
    });
  }
};

ModuleCollection.prototype.unregister = function unregister (path) {
  var parent = this.get(path.slice(0, -1));
  var key = path[path.length - 1];
  if (!parent.getChild(key).runtime) { return }

  parent.removeChild(key);
};

function update (path, targetModule, newModule) {
  if (true) {
    assertRawModule(path, newModule);
  }

  // update target module
  targetModule.update(newModule);

  // update nested modules
  if (newModule.modules) {
    for (var key in newModule.modules) {
      if (!targetModule.getChild(key)) {
        if (true) {
          console.warn(
            "[vuex] trying to add a new module '" + key + "' on hot reloading, " +
            'manual reload is needed'
          );
        }
        return
      }
      update(
        path.concat(key),
        targetModule.getChild(key),
        newModule.modules[key]
      );
    }
  }
}

var functionAssert = {
  assert: function (value) { return typeof value === 'function'; },
  expected: 'function'
};

var objectAssert = {
  assert: function (value) { return typeof value === 'function' ||
    (typeof value === 'object' && typeof value.handler === 'function'); },
  expected: 'function or object with "handler" function'
};

var assertTypes = {
  getters: functionAssert,
  mutations: functionAssert,
  actions: objectAssert
};

function assertRawModule (path, rawModule) {
  Object.keys(assertTypes).forEach(function (key) {
    if (!rawModule[key]) { return }

    var assertOptions = assertTypes[key];

    forEachValue(rawModule[key], function (value, type) {
      assert(
        assertOptions.assert(value),
        makeAssertionMessage(path, key, type, value, assertOptions.expected)
      );
    });
  });
}

function makeAssertionMessage (path, key, type, value, expected) {
  var buf = key + " should be " + expected + " but \"" + key + "." + type + "\"";
  if (path.length > 0) {
    buf += " in module \"" + (path.join('.')) + "\"";
  }
  buf += " is " + (JSON.stringify(value)) + ".";
  return buf
}

var Vue; // bind on install

var Store = function Store (options) {
  var this$1 = this;
  if ( options === void 0 ) options = {};

  // Auto install if it is not done yet and `window` has `Vue`.
  // To allow users to avoid auto-installation in some cases,
  // this code should be placed here. See #731
  if (!Vue && typeof window !== 'undefined' && window.Vue) {
    install(window.Vue);
  }

  if (true) {
    assert(Vue, "must call Vue.use(Vuex) before creating a store instance.");
    assert(typeof Promise !== 'undefined', "vuex requires a Promise polyfill in this browser.");
    assert(this instanceof Store, "store must be called with the new operator.");
  }

  var plugins = options.plugins; if ( plugins === void 0 ) plugins = [];
  var strict = options.strict; if ( strict === void 0 ) strict = false;

  // store internal state
  this._committing = false;
  this._actions = Object.create(null);
  this._actionSubscribers = [];
  this._mutations = Object.create(null);
  this._wrappedGetters = Object.create(null);
  this._modules = new ModuleCollection(options);
  this._modulesNamespaceMap = Object.create(null);
  this._subscribers = [];
  this._watcherVM = new Vue();

  // bind commit and dispatch to self
  var store = this;
  var ref = this;
  var dispatch = ref.dispatch;
  var commit = ref.commit;
  this.dispatch = function boundDispatch (type, payload) {
    return dispatch.call(store, type, payload)
  };
  this.commit = function boundCommit (type, payload, options) {
    return commit.call(store, type, payload, options)
  };

  // strict mode
  this.strict = strict;

  var state = this._modules.root.state;

  // init root module.
  // this also recursively registers all sub-modules
  // and collects all module getters inside this._wrappedGetters
  installModule(this, state, [], this._modules.root);

  // initialize the store vm, which is responsible for the reactivity
  // (also registers _wrappedGetters as computed properties)
  resetStoreVM(this, state);

  // apply plugins
  plugins.forEach(function (plugin) { return plugin(this$1); });

  var useDevtools = options.devtools !== undefined ? options.devtools : Vue.config.devtools;
  if (useDevtools) {
    devtoolPlugin(this);
  }
};

var prototypeAccessors$1 = { state: { configurable: true } };

prototypeAccessors$1.state.get = function () {
  return this._vm._data.$$state
};

prototypeAccessors$1.state.set = function (v) {
  if (true) {
    assert(false, "use store.replaceState() to explicit replace store state.");
  }
};

Store.prototype.commit = function commit (_type, _payload, _options) {
    var this$1 = this;

  // check object-style commit
  var ref = unifyObjectStyle(_type, _payload, _options);
    var type = ref.type;
    var payload = ref.payload;
    var options = ref.options;

  var mutation = { type: type, payload: payload };
  var entry = this._mutations[type];
  if (!entry) {
    if (true) {
      console.error(("[vuex] unknown mutation type: " + type));
    }
    return
  }
  this._withCommit(function () {
    entry.forEach(function commitIterator (handler) {
      handler(payload);
    });
  });
  this._subscribers.forEach(function (sub) { return sub(mutation, this$1.state); });

  if (
    "development" !== 'production' &&
    options && options.silent
  ) {
    console.warn(
      "[vuex] mutation type: " + type + ". Silent option has been removed. " +
      'Use the filter functionality in the vue-devtools'
    );
  }
};

Store.prototype.dispatch = function dispatch (_type, _payload) {
    var this$1 = this;

  // check object-style dispatch
  var ref = unifyObjectStyle(_type, _payload);
    var type = ref.type;
    var payload = ref.payload;

  var action = { type: type, payload: payload };
  var entry = this._actions[type];
  if (!entry) {
    if (true) {
      console.error(("[vuex] unknown action type: " + type));
    }
    return
  }

  try {
    this._actionSubscribers
      .filter(function (sub) { return sub.before; })
      .forEach(function (sub) { return sub.before(action, this$1.state); });
  } catch (e) {
    if (true) {
      console.warn("[vuex] error in before action subscribers: ");
      console.error(e);
    }
  }

  var result = entry.length > 1
    ? Promise.all(entry.map(function (handler) { return handler(payload); }))
    : entry[0](payload);

  return result.then(function (res) {
    try {
      this$1._actionSubscribers
        .filter(function (sub) { return sub.after; })
        .forEach(function (sub) { return sub.after(action, this$1.state); });
    } catch (e) {
      if (true) {
        console.warn("[vuex] error in after action subscribers: ");
        console.error(e);
      }
    }
    return res
  })
};

Store.prototype.subscribe = function subscribe (fn) {
  return genericSubscribe(fn, this._subscribers)
};

Store.prototype.subscribeAction = function subscribeAction (fn) {
  var subs = typeof fn === 'function' ? { before: fn } : fn;
  return genericSubscribe(subs, this._actionSubscribers)
};

Store.prototype.watch = function watch (getter, cb, options) {
    var this$1 = this;

  if (true) {
    assert(typeof getter === 'function', "store.watch only accepts a function.");
  }
  return this._watcherVM.$watch(function () { return getter(this$1.state, this$1.getters); }, cb, options)
};

Store.prototype.replaceState = function replaceState (state) {
    var this$1 = this;

  this._withCommit(function () {
    this$1._vm._data.$$state = state;
  });
};

Store.prototype.registerModule = function registerModule (path, rawModule, options) {
    if ( options === void 0 ) options = {};

  if (typeof path === 'string') { path = [path]; }

  if (true) {
    assert(Array.isArray(path), "module path must be a string or an Array.");
    assert(path.length > 0, 'cannot register the root module by using registerModule.');
  }

  this._modules.register(path, rawModule);
  installModule(this, this.state, path, this._modules.get(path), options.preserveState);
  // reset store to update getters...
  resetStoreVM(this, this.state);
};

Store.prototype.unregisterModule = function unregisterModule (path) {
    var this$1 = this;

  if (typeof path === 'string') { path = [path]; }

  if (true) {
    assert(Array.isArray(path), "module path must be a string or an Array.");
  }

  this._modules.unregister(path);
  this._withCommit(function () {
    var parentState = getNestedState(this$1.state, path.slice(0, -1));
    Vue.delete(parentState, path[path.length - 1]);
  });
  resetStore(this);
};

Store.prototype.hotUpdate = function hotUpdate (newOptions) {
  this._modules.update(newOptions);
  resetStore(this, true);
};

Store.prototype._withCommit = function _withCommit (fn) {
  var committing = this._committing;
  this._committing = true;
  fn();
  this._committing = committing;
};

Object.defineProperties( Store.prototype, prototypeAccessors$1 );

function genericSubscribe (fn, subs) {
  if (subs.indexOf(fn) < 0) {
    subs.push(fn);
  }
  return function () {
    var i = subs.indexOf(fn);
    if (i > -1) {
      subs.splice(i, 1);
    }
  }
}

function resetStore (store, hot) {
  store._actions = Object.create(null);
  store._mutations = Object.create(null);
  store._wrappedGetters = Object.create(null);
  store._modulesNamespaceMap = Object.create(null);
  var state = store.state;
  // init all modules
  installModule(store, state, [], store._modules.root, true);
  // reset vm
  resetStoreVM(store, state, hot);
}

function resetStoreVM (store, state, hot) {
  var oldVm = store._vm;

  // bind store public getters
  store.getters = {};
  var wrappedGetters = store._wrappedGetters;
  var computed = {};
  forEachValue(wrappedGetters, function (fn, key) {
    // use computed to leverage its lazy-caching mechanism
    // direct inline function use will lead to closure preserving oldVm.
    // using partial to return function with only arguments preserved in closure enviroment.
    computed[key] = partial(fn, store);
    Object.defineProperty(store.getters, key, {
      get: function () { return store._vm[key]; },
      enumerable: true // for local getters
    });
  });

  // use a Vue instance to store the state tree
  // suppress warnings just in case the user has added
  // some funky global mixins
  var silent = Vue.config.silent;
  Vue.config.silent = true;
  store._vm = new Vue({
    data: {
      $$state: state
    },
    computed: computed
  });
  Vue.config.silent = silent;

  // enable strict mode for new vm
  if (store.strict) {
    enableStrictMode(store);
  }

  if (oldVm) {
    if (hot) {
      // dispatch changes in all subscribed watchers
      // to force getter re-evaluation for hot reloading.
      store._withCommit(function () {
        oldVm._data.$$state = null;
      });
    }
    Vue.nextTick(function () { return oldVm.$destroy(); });
  }
}

function installModule (store, rootState, path, module, hot) {
  var isRoot = !path.length;
  var namespace = store._modules.getNamespace(path);

  // register in namespace map
  if (module.namespaced) {
    store._modulesNamespaceMap[namespace] = module;
  }

  // set state
  if (!isRoot && !hot) {
    var parentState = getNestedState(rootState, path.slice(0, -1));
    var moduleName = path[path.length - 1];
    store._withCommit(function () {
      Vue.set(parentState, moduleName, module.state);
    });
  }

  var local = module.context = makeLocalContext(store, namespace, path);

  module.forEachMutation(function (mutation, key) {
    var namespacedType = namespace + key;
    registerMutation(store, namespacedType, mutation, local);
  });

  module.forEachAction(function (action, key) {
    var type = action.root ? key : namespace + key;
    var handler = action.handler || action;
    registerAction(store, type, handler, local);
  });

  module.forEachGetter(function (getter, key) {
    var namespacedType = namespace + key;
    registerGetter(store, namespacedType, getter, local);
  });

  module.forEachChild(function (child, key) {
    installModule(store, rootState, path.concat(key), child, hot);
  });
}

/**
 * make localized dispatch, commit, getters and state
 * if there is no namespace, just use root ones
 */
function makeLocalContext (store, namespace, path) {
  var noNamespace = namespace === '';

  var local = {
    dispatch: noNamespace ? store.dispatch : function (_type, _payload, _options) {
      var args = unifyObjectStyle(_type, _payload, _options);
      var payload = args.payload;
      var options = args.options;
      var type = args.type;

      if (!options || !options.root) {
        type = namespace + type;
        if ("development" !== 'production' && !store._actions[type]) {
          console.error(("[vuex] unknown local action type: " + (args.type) + ", global type: " + type));
          return
        }
      }

      return store.dispatch(type, payload)
    },

    commit: noNamespace ? store.commit : function (_type, _payload, _options) {
      var args = unifyObjectStyle(_type, _payload, _options);
      var payload = args.payload;
      var options = args.options;
      var type = args.type;

      if (!options || !options.root) {
        type = namespace + type;
        if ("development" !== 'production' && !store._mutations[type]) {
          console.error(("[vuex] unknown local mutation type: " + (args.type) + ", global type: " + type));
          return
        }
      }

      store.commit(type, payload, options);
    }
  };

  // getters and state object must be gotten lazily
  // because they will be changed by vm update
  Object.defineProperties(local, {
    getters: {
      get: noNamespace
        ? function () { return store.getters; }
        : function () { return makeLocalGetters(store, namespace); }
    },
    state: {
      get: function () { return getNestedState(store.state, path); }
    }
  });

  return local
}

function makeLocalGetters (store, namespace) {
  var gettersProxy = {};

  var splitPos = namespace.length;
  Object.keys(store.getters).forEach(function (type) {
    // skip if the target getter is not match this namespace
    if (type.slice(0, splitPos) !== namespace) { return }

    // extract local getter type
    var localType = type.slice(splitPos);

    // Add a port to the getters proxy.
    // Define as getter property because
    // we do not want to evaluate the getters in this time.
    Object.defineProperty(gettersProxy, localType, {
      get: function () { return store.getters[type]; },
      enumerable: true
    });
  });

  return gettersProxy
}

function registerMutation (store, type, handler, local) {
  var entry = store._mutations[type] || (store._mutations[type] = []);
  entry.push(function wrappedMutationHandler (payload) {
    handler.call(store, local.state, payload);
  });
}

function registerAction (store, type, handler, local) {
  var entry = store._actions[type] || (store._actions[type] = []);
  entry.push(function wrappedActionHandler (payload, cb) {
    var res = handler.call(store, {
      dispatch: local.dispatch,
      commit: local.commit,
      getters: local.getters,
      state: local.state,
      rootGetters: store.getters,
      rootState: store.state
    }, payload, cb);
    if (!isPromise(res)) {
      res = Promise.resolve(res);
    }
    if (store._devtoolHook) {
      return res.catch(function (err) {
        store._devtoolHook.emit('vuex:error', err);
        throw err
      })
    } else {
      return res
    }
  });
}

function registerGetter (store, type, rawGetter, local) {
  if (store._wrappedGetters[type]) {
    if (true) {
      console.error(("[vuex] duplicate getter key: " + type));
    }
    return
  }
  store._wrappedGetters[type] = function wrappedGetter (store) {
    return rawGetter(
      local.state, // local state
      local.getters, // local getters
      store.state, // root state
      store.getters // root getters
    )
  };
}

function enableStrictMode (store) {
  store._vm.$watch(function () { return this._data.$$state }, function () {
    if (true) {
      assert(store._committing, "do not mutate vuex store state outside mutation handlers.");
    }
  }, { deep: true, sync: true });
}

function getNestedState (state, path) {
  return path.length
    ? path.reduce(function (state, key) { return state[key]; }, state)
    : state
}

function unifyObjectStyle (type, payload, options) {
  if (isObject(type) && type.type) {
    options = payload;
    payload = type;
    type = type.type;
  }

  if (true) {
    assert(typeof type === 'string', ("expects string as the type, but found " + (typeof type) + "."));
  }

  return { type: type, payload: payload, options: options }
}

function install (_Vue) {
  if (Vue && _Vue === Vue) {
    if (true) {
      console.error(
        '[vuex] already installed. Vue.use(Vuex) should be called only once.'
      );
    }
    return
  }
  Vue = _Vue;
  applyMixin(Vue);
}

/**
 * Reduce the code which written in Vue.js for getting the state.
 * @param {String} [namespace] - Module's namespace
 * @param {Object|Array} states # Object's item can be a function which accept state and getters for param, you can do something for state and getters in it.
 * @param {Object}
 */
var mapState = normalizeNamespace(function (namespace, states) {
  var res = {};
  normalizeMap(states).forEach(function (ref) {
    var key = ref.key;
    var val = ref.val;

    res[key] = function mappedState () {
      var state = this.$store.state;
      var getters = this.$store.getters;
      if (namespace) {
        var module = getModuleByNamespace(this.$store, 'mapState', namespace);
        if (!module) {
          return
        }
        state = module.context.state;
        getters = module.context.getters;
      }
      return typeof val === 'function'
        ? val.call(this, state, getters)
        : state[val]
    };
    // mark vuex getter for devtools
    res[key].vuex = true;
  });
  return res
});

/**
 * Reduce the code which written in Vue.js for committing the mutation
 * @param {String} [namespace] - Module's namespace
 * @param {Object|Array} mutations # Object's item can be a function which accept `commit` function as the first param, it can accept anthor params. You can commit mutation and do any other things in this function. specially, You need to pass anthor params from the mapped function.
 * @return {Object}
 */
var mapMutations = normalizeNamespace(function (namespace, mutations) {
  var res = {};
  normalizeMap(mutations).forEach(function (ref) {
    var key = ref.key;
    var val = ref.val;

    res[key] = function mappedMutation () {
      var args = [], len = arguments.length;
      while ( len-- ) args[ len ] = arguments[ len ];

      // Get the commit method from store
      var commit = this.$store.commit;
      if (namespace) {
        var module = getModuleByNamespace(this.$store, 'mapMutations', namespace);
        if (!module) {
          return
        }
        commit = module.context.commit;
      }
      return typeof val === 'function'
        ? val.apply(this, [commit].concat(args))
        : commit.apply(this.$store, [val].concat(args))
    };
  });
  return res
});

/**
 * Reduce the code which written in Vue.js for getting the getters
 * @param {String} [namespace] - Module's namespace
 * @param {Object|Array} getters
 * @return {Object}
 */
var mapGetters = normalizeNamespace(function (namespace, getters) {
  var res = {};
  normalizeMap(getters).forEach(function (ref) {
    var key = ref.key;
    var val = ref.val;

    // The namespace has been mutated by normalizeNamespace
    val = namespace + val;
    res[key] = function mappedGetter () {
      if (namespace && !getModuleByNamespace(this.$store, 'mapGetters', namespace)) {
        return
      }
      if ("development" !== 'production' && !(val in this.$store.getters)) {
        console.error(("[vuex] unknown getter: " + val));
        return
      }
      return this.$store.getters[val]
    };
    // mark vuex getter for devtools
    res[key].vuex = true;
  });
  return res
});

/**
 * Reduce the code which written in Vue.js for dispatch the action
 * @param {String} [namespace] - Module's namespace
 * @param {Object|Array} actions # Object's item can be a function which accept `dispatch` function as the first param, it can accept anthor params. You can dispatch action and do any other things in this function. specially, You need to pass anthor params from the mapped function.
 * @return {Object}
 */
var mapActions = normalizeNamespace(function (namespace, actions) {
  var res = {};
  normalizeMap(actions).forEach(function (ref) {
    var key = ref.key;
    var val = ref.val;

    res[key] = function mappedAction () {
      var args = [], len = arguments.length;
      while ( len-- ) args[ len ] = arguments[ len ];

      // get dispatch function from store
      var dispatch = this.$store.dispatch;
      if (namespace) {
        var module = getModuleByNamespace(this.$store, 'mapActions', namespace);
        if (!module) {
          return
        }
        dispatch = module.context.dispatch;
      }
      return typeof val === 'function'
        ? val.apply(this, [dispatch].concat(args))
        : dispatch.apply(this.$store, [val].concat(args))
    };
  });
  return res
});

/**
 * Rebinding namespace param for mapXXX function in special scoped, and return them by simple object
 * @param {String} namespace
 * @return {Object}
 */
var createNamespacedHelpers = function (namespace) { return ({
  mapState: mapState.bind(null, namespace),
  mapGetters: mapGetters.bind(null, namespace),
  mapMutations: mapMutations.bind(null, namespace),
  mapActions: mapActions.bind(null, namespace)
}); };

/**
 * Normalize the map
 * normalizeMap([1, 2, 3]) => [ { key: 1, val: 1 }, { key: 2, val: 2 }, { key: 3, val: 3 } ]
 * normalizeMap({a: 1, b: 2, c: 3}) => [ { key: 'a', val: 1 }, { key: 'b', val: 2 }, { key: 'c', val: 3 } ]
 * @param {Array|Object} map
 * @return {Object}
 */
function normalizeMap (map) {
  return Array.isArray(map)
    ? map.map(function (key) { return ({ key: key, val: key }); })
    : Object.keys(map).map(function (key) { return ({ key: key, val: map[key] }); })
}

/**
 * Return a function expect two param contains namespace and map. it will normalize the namespace and then the param's function will handle the new namespace and the map.
 * @param {Function} fn
 * @return {Function}
 */
function normalizeNamespace (fn) {
  return function (namespace, map) {
    if (typeof namespace !== 'string') {
      map = namespace;
      namespace = '';
    } else if (namespace.charAt(namespace.length - 1) !== '/') {
      namespace += '/';
    }
    return fn(namespace, map)
  }
}

/**
 * Search a special module from store by namespace. if module not exist, print error message.
 * @param {Object} store
 * @param {String} helper
 * @param {String} namespace
 * @return {Object}
 */
function getModuleByNamespace (store, helper, namespace) {
  var module = store._modulesNamespaceMap[namespace];
  if ("development" !== 'production' && !module) {
    console.error(("[vuex] module namespace not found in " + helper + "(): " + namespace));
  }
  return module
}

var index_esm = {
  Store: Store,
  install: install,
  version: '3.1.1',
  mapState: mapState,
  mapMutations: mapMutations,
  mapGetters: mapGetters,
  mapActions: mapActions,
  createNamespacedHelpers: createNamespacedHelpers
};

/* harmony default export */ __webpack_exports__["a"] = (index_esm);


/* WEBPACK VAR INJECTION */}.call(__webpack_exports__, __webpack_require__(8)))

/***/ }),
/* 3 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;

var _assign = __webpack_require__(81);

var _assign2 = _interopRequireDefault(_assign);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

exports.default = _assign2.default || function (target) {
  for (var i = 1; i < arguments.length; i++) {
    var source = arguments[i];

    for (var key in source) {
      if (Object.prototype.hasOwnProperty.call(source, key)) {
        target[key] = source[key];
      }
    }
  }

  return target;
};

/***/ }),
/* 4 */
/***/ (function(module, exports, __webpack_require__) {

var store = __webpack_require__(32)('wks');
var uid = __webpack_require__(33);
var Symbol = __webpack_require__(5).Symbol;
var USE_SYMBOL = typeof Symbol == 'function';

var $exports = module.exports = function (name) {
  return store[name] || (store[name] =
    USE_SYMBOL && Symbol[name] || (USE_SYMBOL ? Symbol : uid)('Symbol.' + name));
};

$exports.store = store;


/***/ }),
/* 5 */
/***/ (function(module, exports) {

// https://github.com/zloirock/core-js/issues/86#issuecomment-115759028
var global = module.exports = typeof window != 'undefined' && window.Math == Math
  ? window : typeof self != 'undefined' && self.Math == Math ? self
  // eslint-disable-next-line no-new-func
  : Function('return this')();
if (typeof __g == 'number') __g = global; // eslint-disable-line no-undef


/***/ }),
/* 6 */
/***/ (function(module, exports) {

var core = module.exports = { version: '2.6.9' };
if (typeof __e == 'number') __e = core; // eslint-disable-line no-undef


/***/ }),
/* 7 */
/***/ (function(module, exports, __webpack_require__) {

// Thank's IE8 for his funny defineProperty
module.exports = !__webpack_require__(18)(function () {
  return Object.defineProperty({}, 'a', { get: function () { return 7; } }).a != 7;
});


/***/ }),
/* 8 */
/***/ (function(module, exports) {

var g;

// This works in non-strict mode
g = (function() { return typeof global !== 'undefined' ? global : this; })();

try {
	// This works if eval is allowed (see CSP)
	g = g || Function("return this")() || (1,eval)("this");
} catch(e) {
	// This works if the window reference is available
	if(typeof window === "object")
		g = window;
}

// g can still be undefined, but nothing to do about it...
// We return undefined, instead of nothing here, so it's
// easier to handle this case. if(!global) { ...}

module.exports = g;


/***/ }),
/* 9 */
/***/ (function(module, exports, __webpack_require__) {

var dP = __webpack_require__(10);
var createDesc = __webpack_require__(19);
module.exports = __webpack_require__(7) ? function (object, key, value) {
  return dP.f(object, key, createDesc(1, value));
} : function (object, key, value) {
  object[key] = value;
  return object;
};


/***/ }),
/* 10 */
/***/ (function(module, exports, __webpack_require__) {

var anObject = __webpack_require__(11);
var IE8_DOM_DEFINE = __webpack_require__(52);
var toPrimitive = __webpack_require__(53);
var dP = Object.defineProperty;

exports.f = __webpack_require__(7) ? Object.defineProperty : function defineProperty(O, P, Attributes) {
  anObject(O);
  P = toPrimitive(P, true);
  anObject(Attributes);
  if (IE8_DOM_DEFINE) try {
    return dP(O, P, Attributes);
  } catch (e) { /* empty */ }
  if ('get' in Attributes || 'set' in Attributes) throw TypeError('Accessors not supported!');
  if ('value' in Attributes) O[P] = Attributes.value;
  return O;
};


/***/ }),
/* 11 */
/***/ (function(module, exports, __webpack_require__) {

var isObject = __webpack_require__(17);
module.exports = function (it) {
  if (!isObject(it)) throw TypeError(it + ' is not an object!');
  return it;
};


/***/ }),
/* 12 */
/***/ (function(module, exports) {

var hasOwnProperty = {}.hasOwnProperty;
module.exports = function (it, key) {
  return hasOwnProperty.call(it, key);
};


/***/ }),
/* 13 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


exports.__esModule = true;

var _from = __webpack_require__(46);

var _from2 = _interopRequireDefault(_from);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

exports.default = function (arr) {
  if (Array.isArray(arr)) {
    for (var i = 0, arr2 = Array(arr.length); i < arr.length; i++) {
      arr2[i] = arr[i];
    }

    return arr2;
  } else {
    return (0, _from2.default)(arr);
  }
};

/***/ }),
/* 14 */
/***/ (function(module, exports) {

// 7.1.4 ToInteger
var ceil = Math.ceil;
var floor = Math.floor;
module.exports = function (it) {
  return isNaN(it = +it) ? 0 : (it > 0 ? floor : ceil)(it);
};


/***/ }),
/* 15 */
/***/ (function(module, exports) {

// 7.2.1 RequireObjectCoercible(argument)
module.exports = function (it) {
  if (it == undefined) throw TypeError("Can't call method on  " + it);
  return it;
};


/***/ }),
/* 16 */
/***/ (function(module, exports, __webpack_require__) {

var global = __webpack_require__(5);
var core = __webpack_require__(6);
var ctx = __webpack_require__(25);
var hide = __webpack_require__(9);
var has = __webpack_require__(12);
var PROTOTYPE = 'prototype';

var $export = function (type, name, source) {
  var IS_FORCED = type & $export.F;
  var IS_GLOBAL = type & $export.G;
  var IS_STATIC = type & $export.S;
  var IS_PROTO = type & $export.P;
  var IS_BIND = type & $export.B;
  var IS_WRAP = type & $export.W;
  var exports = IS_GLOBAL ? core : core[name] || (core[name] = {});
  var expProto = exports[PROTOTYPE];
  var target = IS_GLOBAL ? global : IS_STATIC ? global[name] : (global[name] || {})[PROTOTYPE];
  var key, own, out;
  if (IS_GLOBAL) source = name;
  for (key in source) {
    // contains in native
    own = !IS_FORCED && target && target[key] !== undefined;
    if (own && has(exports, key)) continue;
    // export native or passed
    out = own ? target[key] : source[key];
    // prevent global pollution for namespaces
    exports[key] = IS_GLOBAL && typeof target[key] != 'function' ? source[key]
    // bind timers to global for call from export context
    : IS_BIND && own ? ctx(out, global)
    // wrap global constructors for prevent change them in library
    : IS_WRAP && target[key] == out ? (function (C) {
      var F = function (a, b, c) {
        if (this instanceof C) {
          switch (arguments.length) {
            case 0: return new C();
            case 1: return new C(a);
            case 2: return new C(a, b);
          } return new C(a, b, c);
        } return C.apply(this, arguments);
      };
      F[PROTOTYPE] = C[PROTOTYPE];
      return F;
    // make static versions for prototype methods
    })(out) : IS_PROTO && typeof out == 'function' ? ctx(Function.call, out) : out;
    // export proto methods to core.%CONSTRUCTOR%.methods.%NAME%
    if (IS_PROTO) {
      (exports.virtual || (exports.virtual = {}))[key] = out;
      // export proto methods to core.%CONSTRUCTOR%.prototype.%NAME%
      if (type & $export.R && expProto && !expProto[key]) hide(expProto, key, out);
    }
  }
};
// type bitmap
$export.F = 1;   // forced
$export.G = 2;   // global
$export.S = 4;   // static
$export.P = 8;   // proto
$export.B = 16;  // bind
$export.W = 32;  // wrap
$export.U = 64;  // safe
$export.R = 128; // real proto method for `library`
module.exports = $export;


/***/ }),
/* 17 */
/***/ (function(module, exports) {

module.exports = function (it) {
  return typeof it === 'object' ? it !== null : typeof it === 'function';
};


/***/ }),
/* 18 */
/***/ (function(module, exports) {

module.exports = function (exec) {
  try {
    return !!exec();
  } catch (e) {
    return true;
  }
};


/***/ }),
/* 19 */
/***/ (function(module, exports) {

module.exports = function (bitmap, value) {
  return {
    enumerable: !(bitmap & 1),
    configurable: !(bitmap & 2),
    writable: !(bitmap & 4),
    value: value
  };
};


/***/ }),
/* 20 */
/***/ (function(module, exports) {

module.exports = {};


/***/ }),
/* 21 */
/***/ (function(module, exports, __webpack_require__) {

var shared = __webpack_require__(32)('keys');
var uid = __webpack_require__(33);
module.exports = function (key) {
  return shared[key] || (shared[key] = uid(key));
};


/***/ }),
/* 22 */
/***/ (function(module, exports, __webpack_require__) {

// 7.1.13 ToObject(argument)
var defined = __webpack_require__(15);
module.exports = function (it) {
  return Object(defined(it));
};


/***/ }),
/* 23 */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (immutable) */ __webpack_exports__["a"] = formatTime;
/* harmony export (immutable) */ __webpack_exports__["b"] = throttle;
function formatNumber(n) {
  var str = n.toString();
  return str[1] ? str : '0' + str;
}

function formatTime(date) {
  var year = date.getFullYear();
  var month = date.getMonth() + 1;
  var day = date.getDate();

  var hour = date.getHours();
  var minute = date.getMinutes();

  var t1 = [year, month, day].map(formatNumber).join('-');
  var t2 = [hour, minute].map(formatNumber).join(':');

  return t1 + ' ' + t2;
}

function throttle(func, wait) {
  var timeout = void 0;
  return function () {
    var that = this;
    var args = arguments;

    if (!timeout) {
      timeout = setTimeout(function () {
        timeout = null;
        func.apply(that, args);
      }, wait);
    }
  };
}

/* unused harmony default export */ var _unused_webpack_default_export = ({
  formatNumber: formatNumber,
  formatTime: formatTime,
  throttle: throttle
});

/***/ }),
/* 24 */
/***/ (function(module, exports) {

module.exports = true;


/***/ }),
/* 25 */
/***/ (function(module, exports, __webpack_require__) {

// optional / simple context binding
var aFunction = __webpack_require__(51);
module.exports = function (fn, that, length) {
  aFunction(fn);
  if (that === undefined) return fn;
  switch (length) {
    case 1: return function (a) {
      return fn.call(that, a);
    };
    case 2: return function (a, b) {
      return fn.call(that, a, b);
    };
    case 3: return function (a, b, c) {
      return fn.call(that, a, b, c);
    };
  }
  return function (/* ...args */) {
    return fn.apply(that, arguments);
  };
};


/***/ }),
/* 26 */
/***/ (function(module, exports, __webpack_require__) {

var isObject = __webpack_require__(17);
var document = __webpack_require__(5).document;
// typeof document.createElement is 'object' in old IE
var is = isObject(document) && isObject(document.createElement);
module.exports = function (it) {
  return is ? document.createElement(it) : {};
};


/***/ }),
/* 27 */
/***/ (function(module, exports, __webpack_require__) {

// 19.1.2.14 / 15.2.3.14 Object.keys(O)
var $keys = __webpack_require__(58);
var enumBugKeys = __webpack_require__(34);

module.exports = Object.keys || function keys(O) {
  return $keys(O, enumBugKeys);
};


/***/ }),
/* 28 */
/***/ (function(module, exports, __webpack_require__) {

// to indexed object, toObject with fallback for non-array-like ES3 strings
var IObject = __webpack_require__(29);
var defined = __webpack_require__(15);
module.exports = function (it) {
  return IObject(defined(it));
};


/***/ }),
/* 29 */
/***/ (function(module, exports, __webpack_require__) {

// fallback for non-array-like ES3 and non-enumerable old V8 strings
var cof = __webpack_require__(30);
// eslint-disable-next-line no-prototype-builtins
module.exports = Object('z').propertyIsEnumerable(0) ? Object : function (it) {
  return cof(it) == 'String' ? it.split('') : Object(it);
};


/***/ }),
/* 30 */
/***/ (function(module, exports) {

var toString = {}.toString;

module.exports = function (it) {
  return toString.call(it).slice(8, -1);
};


/***/ }),
/* 31 */
/***/ (function(module, exports, __webpack_require__) {

// 7.1.15 ToLength
var toInteger = __webpack_require__(14);
var min = Math.min;
module.exports = function (it) {
  return it > 0 ? min(toInteger(it), 0x1fffffffffffff) : 0; // pow(2, 53) - 1 == 9007199254740991
};


/***/ }),
/* 32 */
/***/ (function(module, exports, __webpack_require__) {

var core = __webpack_require__(6);
var global = __webpack_require__(5);
var SHARED = '__core-js_shared__';
var store = global[SHARED] || (global[SHARED] = {});

(module.exports = function (key, value) {
  return store[key] || (store[key] = value !== undefined ? value : {});
})('versions', []).push({
  version: core.version,
  mode: __webpack_require__(24) ? 'pure' : 'global',
  copyright: '© 2019 Denis Pushkarev (zloirock.ru)'
});


/***/ }),
/* 33 */
/***/ (function(module, exports) {

var id = 0;
var px = Math.random();
module.exports = function (key) {
  return 'Symbol('.concat(key === undefined ? '' : key, ')_', (++id + px).toString(36));
};


/***/ }),
/* 34 */
/***/ (function(module, exports) {

// IE 8- don't enum bug keys
module.exports = (
  'constructor,hasOwnProperty,isPrototypeOf,propertyIsEnumerable,toLocaleString,toString,valueOf'
).split(',');


/***/ }),
/* 35 */
/***/ (function(module, exports, __webpack_require__) {

var def = __webpack_require__(10).f;
var has = __webpack_require__(12);
var TAG = __webpack_require__(4)('toStringTag');

module.exports = function (it, tag, stat) {
  if (it && !has(it = stat ? it : it.prototype, TAG)) def(it, TAG, { configurable: true, value: tag });
};


/***/ }),
/* 36 */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "c", function() { return emojiUrl; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return emojiMap; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "b", function() { return emojiName; });
var emojiUrl = 'https://webim-1252463788.file.myqcloud.com/assets/emoji/';
var emojiMap = {
  '[NO]': 'emoji_0@2x.png',
  '[OK]': 'emoji_1@2x.png',
  '[下雨]': 'emoji_2@2x.png',
  '[么么哒]': 'emoji_3@2x.png',
  '[乒乓]': 'emoji_4@2x.png',
  '[便便]': 'emoji_5@2x.png',
  '[信封]': 'emoji_6@2x.png',
  '[偷笑]': 'emoji_7@2x.png',
  '[傲慢]': 'emoji_8@2x.png',
  '[再见]': 'emoji_9@2x.png',
  '[冷汗]': 'emoji_10@2x.png',
  '[凋谢]': 'emoji_11@2x.png',
  '[刀]': 'emoji_12@2x.png',
  '[删除]': 'emoji_13@2x.png',
  '[勾引]': 'emoji_14@2x.png',
  '[发呆]': 'emoji_15@2x.png',
  '[发抖]': 'emoji_16@2x.png',
  '[可怜]': 'emoji_17@2x.png',
  '[可爱]': 'emoji_18@2x.png',
  '[右哼哼]': 'emoji_19@2x.png',
  '[右太极]': 'emoji_20@2x.png',
  '[右车头]': 'emoji_21@2x.png',
  '[吐]': 'emoji_22@2x.png',
  '[吓]': 'emoji_23@2x.png',
  '[咒骂]': 'emoji_24@2x.png',
  '[咖啡]': 'emoji_25@2x.png',
  '[啤酒]': 'emoji_26@2x.png',
  '[嘘]': 'emoji_27@2x.png',
  '[回头]': 'emoji_28@2x.png',
  '[困]': 'emoji_29@2x.png',
  '[坏笑]': 'emoji_30@2x.png',
  '[多云]': 'emoji_31@2x.png',
  '[大兵]': 'emoji_32@2x.png',
  '[大哭]': 'emoji_33@2x.png',
  '[太阳]': 'emoji_34@2x.png',
  '[奋斗]': 'emoji_35@2x.png',
  '[奶瓶]': 'emoji_36@2x.png',
  '[委屈]': 'emoji_37@2x.png',
  '[害羞]': 'emoji_38@2x.png',
  '[尴尬]': 'emoji_39@2x.png',
  '[左哼哼]': 'emoji_40@2x.png',
  '[左太极]': 'emoji_41@2x.png',
  '[左车头]': 'emoji_42@2x.png',
  '[差劲]': 'emoji_43@2x.png',
  '[弱]': 'emoji_44@2x.png',
  '[强]': 'emoji_45@2x.png',
  '[彩带]': 'emoji_46@2x.png',
  '[彩球]': 'emoji_47@2x.png',
  '[得意]': 'emoji_48@2x.png',
  '[微笑]': 'emoji_49@2x.png',
  '[心碎了]': 'emoji_50@2x.png',
  '[快哭了]': 'emoji_51@2x.png',
  '[怄火]': 'emoji_52@2x.png',
  '[怒]': 'emoji_53@2x.png',
  '[惊恐]': 'emoji_54@2x.png',
  '[惊讶]': 'emoji_55@2x.png',
  '[憨笑]': 'emoji_56@2x.png',
  '[手枪]': 'emoji_57@2x.png',
  '[打哈欠]': 'emoji_58@2x.png',
  '[抓狂]': 'emoji_59@2x.png',
  '[折磨]': 'emoji_60@2x.png',
  '[抠鼻]': 'emoji_61@2x.png',
  '[抱抱]': 'emoji_62@2x.png',
  '[抱拳]': 'emoji_63@2x.png',
  '[拳头]': 'emoji_64@2x.png',
  '[挥手]': 'emoji_65@2x.png',
  '[握手]': 'emoji_66@2x.png',
  '[撇嘴]': 'emoji_67@2x.png',
  '[擦汗]': 'emoji_68@2x.png',
  '[敲打]': 'emoji_69@2x.png',
  '[晕]': 'emoji_70@2x.png',
  '[月亮]': 'emoji_71@2x.png',
  '[棒棒糖]': 'emoji_72@2x.png',
  '[汽车]': 'emoji_73@2x.png',
  '[沙发]': 'emoji_74@2x.png',
  '[流汗]': 'emoji_75@2x.png',
  '[流泪]': 'emoji_76@2x.png',
  '[激动]': 'emoji_77@2x.png',
  '[灯泡]': 'emoji_78@2x.png',
  '[炸弹]': 'emoji_79@2x.png',
  '[熊猫]': 'emoji_80@2x.png',
  '[爆筋]': 'emoji_81@2x.png',
  '[爱你]': 'emoji_82@2x.png',
  '[爱心]': 'emoji_83@2x.png',
  '[爱情]': 'emoji_84@2x.png',
  '[猪头]': 'emoji_85@2x.png',
  '[猫咪]': 'emoji_86@2x.png',
  '[献吻]': 'emoji_87@2x.png',
  '[玫瑰]': 'emoji_88@2x.png',
  '[瓢虫]': 'emoji_89@2x.png',
  '[疑问]': 'emoji_90@2x.png',
  '[白眼]': 'emoji_91@2x.png',
  '[皮球]': 'emoji_92@2x.png',
  '[睡觉]': 'emoji_93@2x.png',
  '[磕头]': 'emoji_94@2x.png',
  '[示爱]': 'emoji_95@2x.png',
  '[礼品袋]': 'emoji_96@2x.png',
  '[礼物]': 'emoji_97@2x.png',
  '[篮球]': 'emoji_98@2x.png',
  '[米饭]': 'emoji_99@2x.png',
  '[糗大了]': 'emoji_100@2x.png',
  '[红双喜]': 'emoji_101@2x.png',
  '[红灯笼]': 'emoji_102@2x.png',
  '[纸巾]': 'emoji_103@2x.png',
  '[胜利]': 'emoji_104@2x.png',
  '[色]': 'emoji_105@2x.png',
  '[药]': 'emoji_106@2x.png',
  '[菜刀]': 'emoji_107@2x.png',
  '[蛋糕]': 'emoji_108@2x.png',
  '[蜡烛]': 'emoji_109@2x.png',
  '[街舞]': 'emoji_110@2x.png',
  '[衰]': 'emoji_111@2x.png',
  '[西瓜]': 'emoji_112@2x.png',
  '[调皮]': 'emoji_113@2x.png',
  '[象棋]': 'emoji_114@2x.png',
  '[跳绳]': 'emoji_115@2x.png',
  '[跳跳]': 'emoji_116@2x.png',
  '[车厢]': 'emoji_117@2x.png',
  '[转圈]': 'emoji_118@2x.png',
  '[鄙视]': 'emoji_119@2x.png',
  '[酷]': 'emoji_120@2x.png',
  '[钞票]': 'emoji_121@2x.png',
  '[钻戒]': 'emoji_122@2x.png',
  '[闪电]': 'emoji_123@2x.png',
  '[闭嘴]': 'emoji_124@2x.png',
  '[闹钟]': 'emoji_125@2x.png',
  '[阴险]': 'emoji_126@2x.png',
  '[难过]': 'emoji_127@2x.png',
  '[雨伞]': 'emoji_128@2x.png',
  '[青蛙]': 'emoji_129@2x.png',
  '[面条]': 'emoji_130@2x.png',
  '[鞭炮]': 'emoji_131@2x.png',
  '[风车]': 'emoji_132@2x.png',
  '[飞吻]': 'emoji_133@2x.png',
  '[飞机]': 'emoji_134@2x.png',
  '[饥饿]': 'emoji_135@2x.png',
  '[香蕉]': 'emoji_136@2x.png',
  '[骷髅]': 'emoji_137@2x.png',
  '[麦克风]': 'emoji_138@2x.png',
  '[麻将]': 'emoji_139@2x.png',
  '[鼓掌]': 'emoji_140@2x.png',
  '[龇牙]': 'emoji_141@2x.png'
};
var emojiName = ['[龇牙]', '[调皮]', '[流汗]', '[偷笑]', '[再见]', '[敲打]', '[擦汗]', '[猪头]', '[玫瑰]', '[流泪]', '[大哭]', '[嘘]', '[酷]', '[抓狂]', '[委屈]', '[便便]', '[炸弹]', '[菜刀]', '[可爱]', '[色]', '[害羞]', '[得意]', '[吐]', '[微笑]', '[怒]', '[尴尬]', '[惊恐]', '[冷汗]', '[爱心]', '[示爱]', '[白眼]', '[傲慢]', '[难过]', '[惊讶]', '[疑问]', '[困]', '[么么哒]', '[憨笑]', '[爱情]', '[衰]', '[撇嘴]', '[阴险]', '[奋斗]', '[发呆]', '[右哼哼]', '[抱抱]', '[坏笑]', '[飞吻]', '[鄙视]', '[晕]', '[大兵]', '[可怜]', '[强]', '[弱]', '[握手]', '[胜利]', '[抱拳]', '[凋谢]', '[米饭]', '[蛋糕]', '[西瓜]', '[啤酒]', '[瓢虫]', '[勾引]', '[OK]', '[爱你]', '[咖啡]', '[月亮]', '[刀]', '[发抖]', '[差劲]', '[拳头]', '[心碎了]', '[太阳]', '[礼物]', '[皮球]', '[骷髅]', '[挥手]', '[闪电]', '[饥饿]', '[困]', '[咒骂]', '[折磨]', '[抠鼻]', '[鼓掌]', '[糗大了]', '[左哼哼]', '[打哈欠]', '[快哭了]', '[吓]', '[篮球]', '[乒乓]', '[NO]', '[跳跳]', '[怄火]', '[转圈]', '[磕头]', '[回头]', '[跳绳]', '[激动]', '[街舞]', '[献吻]', '[左太极]', '[右太极]', '[闭嘴]', '[猫咪]', '[红双喜]', '[鞭炮]', '[红灯笼]', '[麻将]', '[麦克风]', '[礼品袋]', '[信封]', '[象棋]', '[彩带]', '[蜡烛]', '[爆筋]', '[棒棒糖]', '[奶瓶]', '[面条]', '[香蕉]', '[飞机]', '[左车头]', '[车厢]', '[右车头]', '[多云]', '[下雨]', '[钞票]', '[熊猫]', '[灯泡]', '[风车]', '[闹钟]', '[雨伞]', '[彩球]', '[钻戒]', '[沙发]', '[纸巾]', '[手枪]', '[青蛙]'];

/***/ }),
/* 37 */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "a", function() { return _SDKAPPID; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "b", function() { return genTestUserSig; });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__lib_generate_test_usersig_es_min_js__ = __webpack_require__(75);
/*eslint-disable*/


const _SDKAPPID = 1400187352;
const _SECRETKEY = '61cbf613d0cea4b302958e39c7b74acaaed0956fe8c494eda1c45912c324ecab';
/*
 * Module:   GenerateTestUserSig
 *
 * Function: 用于生成测试用的 UserSig，UserSig 是腾讯云为其云服务设计的一种安全保护签名。
 *           其计算方法是对 SDKAppID、UserID 和 EXPIRETIME 进行加密，加密算法为 HMAC-SHA256。
 *
 * Attention: 请不要将如下代码发布到您的线上正式版本的 App 中，原因如下：
 *
 *            本文件中的代码虽然能够正确计算出 UserSig，但仅适合快速调通 SDK 的基本功能，不适合线上产品，
 *            这是因为客户端代码中的 SECRETKEY 很容易被反编译逆向破解，尤其是 Web 端的代码被破解的难度几乎为零。
 *            一旦您的密钥泄露，攻击者就可以计算出正确的 UserSig 来盗用您的腾讯云流量。
 *
 *            正确的做法是将 UserSig 的计算代码和加密密钥放在您的业务服务器上，然后由 App 按需向您的服务器获取实时算出的 UserSig。
 *            由于破解服务器的成本要高于破解客户端 App，所以服务器计算的方案能够更好地保护您的加密密钥。
 *
 * Reference：https://cloud.tencent.com/document/product/647/17275#Server
 */
function genTestUserSig(userID) {
  /**
   * 腾讯云 SDKAppId，需要替换为您自己账号下的 SDKAppId。
   *
   * 进入腾讯云实时音视频[控制台](https://console.cloud.tencent.com/rav ) 创建应用，即可看到 SDKAppId，
   * 它是腾讯云用于区分客户的唯一标识。
   */
  var SDKAPPID = _SDKAPPID;

  /**
   * 签名过期时间，建议不要设置的过短
   * <p>
   * 时间单位：秒
   * 默认时间：7 x 24 x 60 x 60 = 604800 = 7 天
   */
  var EXPIRETIME = 604800;


  /**
   * 计算签名用的加密密钥，获取步骤如下：
   *
   * step1. 进入腾讯云实时音视频[控制台](https://console.cloud.tencent.com/rav )，如果还没有应用就创建一个，
   * step2. 单击“应用配置”进入基础配置页面，并进一步找到“帐号体系集成”部分。
   * step3. 点击“查看密钥”按钮，就可以看到计算 UserSig 使用的加密的密钥了，请将其拷贝并复制到如下的变量中
   *
   * 注意：该方案仅适用于调试Demo，正式上线前请将 UserSig 计算代码和密钥迁移到您的后台服务器上，以避免加密密钥泄露导致的流量盗用。
   * 文档：https://cloud.tencent.com/document/product/647/17275#Server
   */
  var SECRETKEY = _SECRETKEY;
  
  var generator = new __WEBPACK_IMPORTED_MODULE_0__lib_generate_test_usersig_es_min_js__["a" /* default */](SDKAPPID, SECRETKEY, EXPIRETIME);
  var userSig = generator.genTestUserSig(userID);
  return {
    sdkappid: SDKAPPID,
    userSig: userSig
  };
}




/***/ }),
/* 38 */,
/* 39 */,
/* 40 */,
/* 41 */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (immutable) */ __webpack_exports__["a"] = listToStyles;
/**
 * Translates the list format produced by css-loader into something
 * easier to manipulate.
 */
function listToStyles (parentId, list) {
  var styles = []
  var newStyles = {}
  for (var i = 0; i < list.length; i++) {
    var item = list[i]
    var id = item[0]
    var css = item[1]
    var media = item[2]
    var sourceMap = item[3]
    var part = {
      id: parentId + ':' + i,
      css: css,
      media: media,
      sourceMap: sourceMap
    }
    if (!newStyles[id]) {
      styles.push(newStyles[id] = { id: id, parts: [part] })
    } else {
      newStyles[id].parts.push(part)
    }
  }
  return styles
}


/***/ }),
/* 42 */,
/* 43 */
/***/ (function(module, exports, __webpack_require__) {

/* WEBPACK VAR INJECTION */(function(global) {!function(e,t){ true?module.exports=t():"function"==typeof define&&define.amd?define(t):(e=e||self).TIM=t()}(this,function(){var e={SDK_READY:"sdkStateReady",SDK_NOT_READY:"sdkStateNotReady",SDK_DESTROY:"sdkDestroy",MESSAGE_SENDING:"onMessageSending",MESSAGE_SEND_SUCCESS:"onMessageSendSuccess",MESSAGE_SEND_FAIL:"onMessageSendFail",MESSAGE_RECEIVED:"onMessageReceived",APPLY_ADD_FRIEND_SUCCESS:"addFriendApplySendSuccess",APPLY_ADD_FRIEND_FAIL:"addFriendApplySendFail",GET_PENDENCY_SUCCESS:"getPendencySuccess",GET_PENDENCY_FAIL:"getPendencyFail",DELETE_PENDENCY_SUCCESS:"deletePendencySuccess",DELETE_PENDENCY_FAIL:"deletePendencyFail",REPLY_PENDENCY_SUCCESS:"replyPendencySuccess",REPLY_PENDENCY_FAIL:"replyPendencyFail",CONVERSATION_LIST_UPDATED:"onConversationListUpdated",GROUP_LIST_UPDATED:"onGroupListUpdated",GROUP_SYSTEM_NOTICE_RECEIVED:"receiveGroupSystemNotice",LOGIN_CHANGE:"loginStatusChange",LOGOUT_SUCCESS:"logoutSuccess",PROFILE_GET_SUCCESS:"getProfileSuccess",PROFILE_GET_FAIL:"getProfileFail",PROFILE_UPDATED:"onProfileUpdated",PROFILE_UPDATE_MY_PROFILE_FAIL:"updateMyProfileFail",FRIENDLIST_GET_SUCCESS:"getFriendListSuccess",FRIENDLIST_GET_FAIL:"getFriendsFail",FRIEND_DELETE_SUCCESS:"deleteFriendSuccess",FRIEND_DELETE_FAIL:"deleteFriendFail",BLACKLIST_ADD_SUCCESS:"addBlacklistSuccess",BLACKLIST_ADD_FAIL:"addBlacklistFail",BLACKLIST_GET_SUCCESS:"getBlacklistSuccess",BLACKLIST_GET_FAIL:"getBlacklistFail",BLACKLIST_UPDATED:"blacklistUpdated",BLACKLIST_DELETE_FAIL:"deleteBlacklistFail",KICKED_OUT:"kickedOut",ERROR:"error"},t={MSG_TEXT:"TIMTextElem",MSG_IMAGE:"TIMImageElem",MSG_SOUND:"TIMSoundElem",MSG_AUDIO:"TIMSoundElem",MSG_FILE:"TIMFileElem",MSG_FACE:"TIMFaceElem",MSG_VIDEO:"TIMVideoFileElem",MSG_GEO:"TIMLocationElem",MSG_GRP_TIP:"TIMGroupTipElem",MSG_GRP_SYS_NOTICE:"TIMGroupSystemNoticeElem",MSG_CUSTOM:"TIMCustomElem",CONV_C2C:"C2C",CONV_GROUP:"GROUP",CONV_SYSTEM:"@TIM#SYSTEM",GRP_PRIVATE:"Private",GRP_PUBLIC:"Public",GRP_CHATROOM:"ChatRoom",GRP_AVCHATROOM:"AVChatRoom",GRP_MBR_ROLE_OWNER:"Owner",GRP_MBR_ROLE_ADMIN:"Admin",GRP_MBR_ROLE_MEMBER:"Member",GRP_TIP_MBR_JOIN:1,GRP_TIP_MBR_QUIT:2,GRP_TIP_MBR_KICKED_OUT:3,GRP_TIP_MBR_SET_ADMIN:4,GRP_TIP_MBR_CANCELED_ADMIN:5,GRP_TIP_GRP_PROFILE_UPDATED:6,GRP_TIP_MBR_PROFILE_UPDATED:7,MSG_REMIND_ACPT_AND_NOTE:"AcceptAndNotify",MSG_REMIND_ACPT_NOT_NOTE:"AcceptNotNotify",MSG_REMIND_DISCARD:"Discard",GENDER_UNKNOWN:"Gender_Type_Unknown",GENDER_FEMALE:"Gender_Type_Female",GENDER_MALE:"Gender_Type_Male",KICKED_OUT_MULT_ACCOUNT:"mutipleAccount",KICKED_OUT_MULT_DEVICE:"mutipleDevice",ALLOW_TYPE_ALLOW_ANY:"AllowType_Type_AllowAny",ALLOW_TYPE_NEED_CONFIRM:"AllowType_Type_NeedConfirm",ALLOW_TYPE_DENY_ANY:"AllowType_Type_DenyAny",FORBID_TYPE_NONE:"AdminForbid_Type_None",FORBID_TYPE_SEND_OUT:"AdminForbid_Type_SendOut",JOIN_OPTIONS_FREE_ACCESS:"FreeAccess",JOIN_OPTIONS_NEED_PERMISSION:"NeedPermission",JOIN_OPTIONS_DISABLE_APPLY:"DisableApply",JOIN_STATUS_SUCCESS:"JoinedSuccess",JOIN_STATUS_ALREADY_IN_GROUP:"AlreadyInGroup",JOIN_STATUS_WAIT_APPROVAL:"WaitAdminApproval",GRP_PROFILE_OWNER_ID:"ownerID",GRP_PROFILE_CREATE_TIME:"createTime",GRP_PROFILE_LAST_INFO_TIME:"lastInfoTime",GRP_PROFILE_MEMBER_NUM:"memberNum",GRP_PROFILE_MAX_MEMBER_NUM:"maxMemberNum",GRP_PROFILE_JOIN_OPTION:"joinOption",GRP_PROFILE_INTRODUCTION:"introduction",GRP_PROFILE_NOTIFICATION:"notification"};function n(e){return(n="function"==typeof Symbol&&"symbol"==typeof Symbol.iterator?function(e){return typeof e}:function(e){return e&&"function"==typeof Symbol&&e.constructor===Symbol&&e!==Symbol.prototype?"symbol":typeof e})(e)}function r(e,t){if(!(e instanceof t))throw new TypeError("Cannot call a class as a function")}function o(e,t){for(var n=0;n<t.length;n++){var r=t[n];r.enumerable=r.enumerable||0,r.configurable=1,"value"in r&&(r.writable=1),Object.defineProperty(e,r.key,r)}}function i(e,t,n){return t&&o(e.prototype,t),n&&o(e,n),e}function a(e,t,n){return t in e?Object.defineProperty(e,t,{value:n,enumerable:1,configurable:1,writable:1}):e[t]=n,e}function s(e,t){var n=Object.keys(e);if(Object.getOwnPropertySymbols){var r=Object.getOwnPropertySymbols(e);t&&(r=r.filter(function(t){return Object.getOwnPropertyDescriptor(e,t).enumerable})),n.push.apply(n,r)}return n}function u(e){for(var t=1;t<arguments.length;t++){var n=null!=arguments[t]?arguments[t]:{};t%2?s(n,1).forEach(function(t){a(e,t,n[t])}):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(n)):s(n).forEach(function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(n,t))})}return e}function c(e,t){if("function"!=typeof t&&null!==t)throw new TypeError("Super expression must either be null or a function");e.prototype=Object.create(t&&t.prototype,{constructor:{value:e,writable:1,configurable:1}}),t&&p(e,t)}function l(e){return(l=Object.setPrototypeOf?Object.getPrototypeOf:function(e){return e.__proto__||Object.getPrototypeOf(e)})(e)}function p(e,t){return(p=Object.setPrototypeOf||function(e,t){return e.__proto__=t,e})(e,t)}function h(e,t,n){return(h=function(){if("undefined"==typeof Reflect||!Reflect.construct)return 0;if(Reflect.construct.sham)return 0;if("function"==typeof Proxy)return 1;try{return Date.prototype.toString.call(Reflect.construct(Date,[],function(){})),1}catch(e){return 0}}()?Reflect.construct:function(e,t,n){var r=[null];r.push.apply(r,t);var o=new(Function.bind.apply(e,r));return n&&p(o,n.prototype),o}).apply(null,arguments)}function f(e){var t="function"==typeof Map?new Map:void 0;return(f=function(e){if(null===e||(n=e,-1===Function.toString.call(n).indexOf("[native code]")))return e;var n;if("function"!=typeof e)throw new TypeError("Super expression must either be null or a function");if(void 0!==t){if(t.has(e))return t.get(e);t.set(e,r)}function r(){return h(e,arguments,l(this).constructor)}return r.prototype=Object.create(e.prototype,{constructor:{value:r,enumerable:0,writable:1,configurable:1}}),p(r,e)})(e)}function _(e){if(void 0===e)throw new ReferenceError("this hasn't been initialised - super() hasn't been called");return e}function g(e,t){return!t||"object"!=typeof t&&"function"!=typeof t?_(e):t}function d(e,t){return function(e){if(Array.isArray(e))return e}(e)||function(e,t){var n=[],r=1,o=0,i=void 0;try{for(var a,s=e[Symbol.iterator]();!(r=(a=s.next()).done)&&(n.push(a.value),!t||n.length!==t);r=1);}catch(u){o=1,i=u}finally{try{r||null==s.return||s.return()}finally{if(o)throw i}}return n}(e,t)||function(){throw new TypeError("Invalid attempt to destructure non-iterable instance")}()}function m(e){return function(e){if(Array.isArray(e)){for(var t=0,n=new Array(e.length);t<e.length;t++)n[t]=e[t];return n}}(e)||function(e){if(Symbol.iterator in Object(e)||"[object Arguments]"===Object.prototype.toString.call(e))return Array.from(e)}(e)||function(){throw new TypeError("Invalid attempt to spread non-iterable instance")}()}var E=function(){function e(){r(this,e),this.cache=[],this.options=null}return i(e,[{key:"use",value:function(e){if("function"!=typeof e)throw"middleware must be a function";return this.cache.push(e),this}},{key:"next",value:function(e){if(this.middlewares&&this.middlewares.length>0)return this.middlewares.shift().call(this,this.options,this.next.bind(this))}},{key:"run",value:function(e){return this.middlewares=this.cache.map(function(e){return e}),this.options=e,this.next()}}]),e}(),y="undefined"!=typeof globalThis?globalThis:"undefined"!=typeof window?window:"undefined"!=typeof global?global:"undefined"!=typeof self?self:{};function v(e,t){return e(t={exports:{}},t.exports),t.exports}var I=v(function(e,t){var n,r,o,i,a,s,u,c,l,p,h,f,_,g,d,m,E,v,I,S;e.exports=(n="function"==typeof Promise,r="object"==typeof self?self:y,o="undefined"!=typeof Symbol,i="undefined"!=typeof Map,a="undefined"!=typeof Set,s="undefined"!=typeof WeakMap,u="undefined"!=typeof WeakSet,c="undefined"!=typeof DataView,l=o&&void 0!==Symbol.iterator,p=o&&void 0!==Symbol.toStringTag,h=a&&"function"==typeof Set.prototype.entries,f=i&&"function"==typeof Map.prototype.entries,_=h&&Object.getPrototypeOf((new Set).entries()),g=f&&Object.getPrototypeOf((new Map).entries()),d=l&&"function"==typeof Array.prototype[Symbol.iterator],m=d&&Object.getPrototypeOf([][Symbol.iterator]()),E=l&&"function"==typeof String.prototype[Symbol.iterator],v=E&&Object.getPrototypeOf(""[Symbol.iterator]()),I=8,S=-1,function(e){var t=typeof e;if("object"!==t)return t;if(null===e)return"null";if(e===r)return"global";if(Array.isArray(e)&&(0==p||!(Symbol.toStringTag in e)))return"Array";if("object"==typeof window&&null!==window){if("object"==typeof window.location&&e===window.location)return"Location";if("object"==typeof window.document&&e===window.document)return"Document";if("object"==typeof window.navigator){if("object"==typeof window.navigator.mimeTypes&&e===window.navigator.mimeTypes)return"MimeTypeArray";if("object"==typeof window.navigator.plugins&&e===window.navigator.plugins)return"PluginArray"}if(("function"==typeof window.HTMLElement||"object"==typeof window.HTMLElement)&&e instanceof window.HTMLElement){if("BLOCKQUOTE"===e.tagName)return"HTMLQuoteElement";if("TD"===e.tagName)return"HTMLTableDataCellElement";if("TH"===e.tagName)return"HTMLTableHeaderCellElement"}}var o=p&&e[Symbol.toStringTag];if("string"==typeof o)return o;var l=Object.getPrototypeOf(e);return l===RegExp.prototype?"RegExp":l===Date.prototype?"Date":n&&l===Promise.prototype?"Promise":a&&l===Set.prototype?"Set":i&&l===Map.prototype?"Map":u&&l===WeakSet.prototype?"WeakSet":s&&l===WeakMap.prototype?"WeakMap":c&&l===DataView.prototype?"DataView":i&&l===g?"Map Iterator":a&&l===_?"Set Iterator":d&&l===m?"Array Iterator":E&&l===v?"String Iterator":null===l?"Object":Object.prototype.toString.call(e).slice(I,S)})}),S=Object.prototype.hasOwnProperty,C=Object.prototype.toString;function T(e){if(null==e)return 1;if("boolean"==typeof e)return 0;if("number"==typeof e)return 0===e;if("string"==typeof e)return 0===e.length;if("function"==typeof e)return 0===e.length;if(Array.isArray(e))return 0===e.length;if(e instanceof Error)return""===e.message;if(e.toString===C)switch(e.toString()){case"[object File]":case"[object Map]":case"[object Set]":return 0===e.size;case"[object Object]":for(var t in e)if(S.call(e,t))return 0;return 1}return 0}var M,D,O="undefined"!=typeof global?global:"undefined"!=typeof self?self:"undefined"!=typeof window?window:{};M="undefined"!=typeof console?console:void 0!==O&&O.console?O.console:"undefined"!=typeof window&&window.console?window.console:{};for(var A=function(){},N=["assert","clear","count","debug","dir","dirxml","error","exception","group","groupCollapsed","groupEnd","info","log","markTimeline","profile","profileEnd","table","time","timeEnd","timeStamp","trace","warn"],L=N.length;L--;)D=N[L],console[D]||(M[D]=A);M.methods=N;var R=M;function P(e,t,n){if(void 0===t)return 1;var r=1;if("object"===I(t).toLowerCase())Object.keys(t).forEach(function(o){var i=1===e.length?e[0][o]:void 0;r=G(i,t[o],n,o)?r:0});else if("array"===I(t).toLowerCase())for(var o=0;o<t.length;o++)r=G(e[o],t[o],n,t[o].name)?r:0;if(r)return r;throw new Error("Params validate failed.")}function G(e,t,n,r){if(void 0===t)return 1;var o=1;return t.required&&T(e)&&(R.error("TIM [".concat(n,'] Missing required params: "').concat(r,'".')),o=0),T(e)||I(e).toLowerCase()===t.type.toLowerCase()||(R.error("TIM [".concat(n,'] Invalid params: type check failed for "').concat(r,'".Expected ').concat(t.type,".")),o=0),t.validator&&!t.validator(e)&&(R.error("TIM [".concat(n,"] Invalid params: custom validator check failed for params.")),o=0),o}var k,w="undefined"!=typeof window,b="undefined"!=typeof wx&&"function"==typeof wx.getSystemInfoSync&&"function"==typeof wx.canIUse,U=w&&window.navigator&&window.navigator.userAgent||"",F=/AppleWebKit\/([\d.]+)/i.exec(U),q=(F&&parseFloat(F.pop()),/iPad/i.test(U)),x=(/iPhone/i.test(U),/iPod/i.test(U),(k=U.match(/OS (\d+)_/i))&&k[1]&&k[1],/Android/i.test(U)),H=function(){var e=U.match(/Android (\d+)(?:\.(\d+))?(?:\.(\d+))*/i);if(!e)return null;var t=e[1]&&parseFloat(e[1]),n=e[2]&&parseFloat(e[2]);return t&&n?parseFloat(e[1]+"."+e[2]):t||null}(),K=(x&&/webkit/i.test(U),/Firefox/i.test(U),/Edge/i.test(U)),B=!K&&/Chrome/i.test(U),V=(function(){var e=U.match(/Chrome\/(\d+)/);e&&e[1]&&parseFloat(e[1])}(),/MSIE/.test(U)),Y=(/MSIE\s8\.0/.test(U),function(){var e=/MSIE\s(\d+)\.\d/.exec(U),t=e&&parseFloat(e[1]);return!t&&/Trident\/7.0/i.test(U)&&/rv:11.0/.test(U)&&(t=11),t}()),j=(/Safari/i.test(U),/TBS\/\d+/i.test(U)),z=(function(){var e=U.match(/TBS\/(\d+)/i);if(e&&e[1])e[1]}(),!j&&/MQQBrowser\/\d+/i.test(U),!j&&/ QQBrowser\/\d+/i.test(U),/(micromessenger|webbrowser)/i.test(U),/Windows/i.test(U),/MAC OS X/i.test(U),/MicroMessenger/i.test(U),-1),W=function(){if(b){var e=wx.getSystemInfoSync().SDKVersion;if(void 0===e||void 0===wx.getLogManager)return 0;if(function(e,t){e=e.split("."),t=t.split(".");var n=Math.max(e.length,t.length);for(;e.length<n;)e.push("0");for(;t.length<n;)t.push("0");for(var r=0;r<n;r++){var o=parseInt(e[r]),i=parseInt(t[r]);if(o>i)return 1;if(o<i)return-1}return 0}(e,"2.1.0")>=0)return wx.getLogManager().log("I can use wx log. SDKVersion="+e),1}return 0}(),X=new Map;function J(){var e=new Date;return"TIM "+e.toLocaleTimeString("en-US",{hour12:0})+"."+function(e){var t;switch(e.toString().length){case 1:t="00"+e;break;case 2:t="0"+e;break;default:t=e}return t}(e.getMilliseconds())+":"}var Q={_data:[],_length:0,_visible:0,arguments2String:function(e){var t;if(1===e.length)t=J()+e[0];else{t=J();for(var n=0,r=e.length;n<r;n++)re(e[n])?oe(e[n])?t+=ce(e[n]):t+=JSON.stringify(e[n]):t+=e[n],t+=" "}return t},debug:function(){if(z<=-1){var e=this.arguments2String(arguments);Q.record(e,"debug"),R.debug(e),W&&wx.getLogManager().debug(e)}},log:function(){if(z<=0){var e=this.arguments2String(arguments);Q.record(e,"log"),R.log(e),W&&wx.getLogManager().log(e)}},info:function(){if(z<=1){var e=this.arguments2String(arguments);Q.record(e,"info"),R.info(e),W&&wx.getLogManager().info(e)}},warn:function(){if(z<=2){var e=this.arguments2String(arguments);Q.record(e,"warn"),R.warn(e),W&&wx.getLogManager().warn(e)}},error:function(){if(z<=3){var e=this.arguments2String(arguments);Q.record(e,"error"),R.error(e),W&&wx.getLogManager().warn(e)}},time:function(e){X.set(e,se.now())},timeEnd:function(e){if(X.has(e)){var t=se.now()-X.get(e);return X.delete(e),t}return R.warn("未找到对应label: ".concat(e,", 请在调用 logger.timeEnd 前，调用 logger.time")),0},setLevel:function(e){e<4&&R.log(J()+"set level from "+z+" to "+e),z=e},record:function(e,t){W||(1100===Q._length&&(Q._data.splice(0,100),Q._length=1e3),Q._length++,Q._data.push("".concat(e," [").concat(t,"] \n")))},getLog:function(){return Q._data}},Z=function(e){return null!==e&&("number"==typeof e&&!isNaN(e-0)||"object"===n(e)&&e.constructor===Number)},$=function(e){return"string"==typeof e},ee=function(e){return null!==e&&"object"===n(e)},te=function(e){return"function"==typeof Array.isArray?Array.isArray(e):"array"===this.getType(e)},ne=function(e){return void 0===e},re=function(e){return te(e)||ee(e)},oe=function(e){return e instanceof Error},ie=function(e){if("string"!=typeof e)return 0;var t=e[0];return/[^a-zA-Z0-9]/.test(t)?0:1},ae=0;Date.now||(Date.now=function(){return(new Date).getTime()});var se={now:function(){0===ae&&(ae=Date.now()-1);var e=Date.now()-ae;return e>4294967295?(ae+=4294967295,Date.now()-ae):e},utc:function(){return Math.round(Date.now()/1e3)}},ue=function e(t,n,r,o){if(!re(t)||!re(n))return 0;for(var i,a=0,s=Object.keys(n),u=0,c=s.length;u<c;u++)if(i=s[u],!(ne(n[i])||r&&r.includes(i)))if(re(t[i])&&re(n[i]))a+=e(t[i],n[i],r,o);else{if(o&&o.includes(n[i]))continue;t[i]!==n[i]&&(t[i]=n[i],a+=1)}return a},ce=function(e){return JSON.stringify(e,["message","code"])},le=function(e){if(0===e.length)return 0;for(var t=0,n=0,r="undefined"!=typeof document&&void 0!==document.characterSet?document.characterSet:"UTF-8";void 0!==e[t];)n+=e[t++].charCodeAt[t]<=255?1:0==r?3:2;return n},pe=function(e){var t=e||99999999;return Math.round(Math.random()*t)},he="0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",fe=he.length,_e=function(e,t){for(var n in e)if(e[n]===t)return 1;return 0},ge={},de=function(e){return e===t.GRP_PUBLIC},me=function(e){return e===t.GRP_AVCHATROOM};function Ee(e,t){var n={};return Object.keys(e).forEach(function(r){n[r]=t(e[r],r)}),n}var ye={login:{userID:{type:"String",required:1},userSig:{type:"String",required:1}},addToBlacklist:{userIDList:{type:"Array",required:1}},mutilParam:[{name:"paramName",type:"Number",required:1},{name:"paramName",type:"String",required:1}],on:[{name:"eventName",type:"String",required:1},{name:"listener",type:"Function",required:0}],sendMessage:[{name:"message",type:"Object",required:1}],getMessageList:{conversationID:{type:"String",required:1},nextReqMessageID:{type:"String"},count:{type:"Number",validator:function(e){return ne(e)||/^[1-9][0-9]*$/.test(e)?1:(console.warn("getMessageList 接口的 count 参数必须为正整数"),0)}}},getConversationProfile:[{name:"conversationID",type:"String",required:1}],deleteConversation:[{name:"conversationID",type:"String",required:1}],getGroupList:{groupProfileFilter:{type:"Array"}},getGroupProfile:{groupID:{type:"String",required:1},groupCustomFieldFilter:{type:"Array"},memberCustomFieldFilter:{type:"Array"}},getGroupProfileAdvance:{groupIDList:{type:"Array",required:1}},createGroup:{name:{type:"String",required:1}},joinGroup:{groupID:{type:"String",required:1},type:{type:"String"},applyMessage:{type:"String"}},quitGroup:[{name:"groupID",type:"String",required:1}],handleApplication:{message:{type:"Object",required:1},handleAction:{type:"String",required:1},handleMessage:{type:"String"}},changeGroupOwner:{groupID:{type:"String",required:1},newOwnerID:{type:"String",required:1}},updateGroupProfile:{groupID:{type:"String",required:1}},dismissGroup:[{name:"groupID",type:"String",required:1}],searchGroupByID:[{name:"groupID",type:"String",required:1}],getGroupMemberList:{groupID:{type:"String",required:1},offset:{type:"Number"},count:{type:"Number"}},addGroupMemeber:{groupID:{type:"String",required:1},userIDList:{type:"Array",required:1}},setGroupMemberRole:{groupID:{type:"String",required:1},userID:{type:"String",required:1},role:{type:"String",required:1}},setGroupMemberMuteTime:{groupID:{type:"String",required:1},userID:{type:"String"},muteTime:{type:"Number",validator:function(e){return e>=0}}},setGroupMemberNameCard:{groupID:{type:"String",required:1},userID:{type:"String"},nameCard:{type:"String",required:1,validator:function(e){return 1==/^\s+$/.test(e)?0:1}}},setMessageRemindType:{groupID:{type:"String",required:1},messageRemindType:{type:"String",required:1}},setGroupMemberCustomField:{groupID:{type:"String",required:1},userID:{type:"String"},memberCustomField:{type:"Array",required:1}},deleteGroupMember:{groupID:{type:"String",required:1}},createTextMessage:{to:{type:"String",required:1},conversationType:{type:"String",required:1},payload:{type:"Object",required:1}},createCustomMessage:{to:{type:"String",required:1},conversationType:{type:"String",required:1},payload:{type:"Object",required:1}},createImageMessage:{to:{type:"String",required:1},conversationType:{type:"String",required:1},payload:{type:"Object",required:1}},createAudioMessage:{to:{type:"String",required:1},conversationType:{type:"String",required:1},payload:{type:"Object",required:1}},createFileMessage:{to:{type:"String",required:1},conversationType:{type:"String",required:1},payload:{type:"Object",required:1}}},ve={login:"login",logout:"logout",on:"on",once:"once",off:"off",setLogLevel:"setLogLevel",downloadLog:"downloadLog",registerPlugin:"registerPlugin",destroy:"destroy",createTextMessage:"createTextMessage",createFileMessage:"createFileMessage",createAudioMessage:"createAudioMessage",createImageMessage:"createImageMessage",createCustomMessage:"createCustomMessage",sendMessage:"sendMessage",resendMessage:"resendMessage",getMessageList:"getMessageList",setMessageRead:"setMessageRead",getConversationList:"getConversationList",getConversationProfile:"getConversationProfile",deleteConversation:"deleteConversation",getGroupList:"getGroupList",getGroupProfile:"getGroupProfile",createGroup:"createGroup",joinGroup:"joinGroup",updateGroupProfile:"updateGroupProfile",quitGroup:"quitGroup",dismissGroup:"dismissGroup",changeGroupOwner:"changeGroupOwner",searchGroupByID:"searchGroupByID",setMessageRemindType:"setMessageRemindType",handleGroupApplication:"handleGroupApplication",getGroupMemberList:"getGroupMemberList",addGroupMember:"addGroupMember",deleteGroupMember:"deleteGroupMember",setGroupMemberNameCard:"setGroupMemberNameCard",setGroupMemberMuteTime:"setGroupMemberMuteTime",setGroupMemberRole:"setGroupMemberRole",setGroupMemberCustomField:"setGroupMemberCustomField",getMyProfile:"getMyProfile",getUserProfile:"getUserProfile",updateMyProfile:"updateMyProfile",getBlacklist:"getBlacklist",addToBlacklist:"addToBlacklist",removeFromBlacklist:"removeFromBlacklist",getFriendList:"getFriendList"},Ie={NO_SDKAPPID:2e3,NO_ACCOUNT_TYPE:2001,NO_IDENTIFIER:2002,NO_USERSIG:2003,NO_SDK_INSTANCE:2004,REQ_GET_ACCESS_LAYER_FAILED:2020,REQ_LOGIN_FAILED:2021,NO_TINYID:2022,NO_A2KEY:2023,MESSAGE_SEND_FAIL:2100,MESSAGE_UNKNOW_ROMA_LIST_END_FLAG_FIELD:2101,MESSAGE_ELEMENT_METHOD_UNDEFINED:2102,MESSAGE_LIST_CONSTRUCTOR_NEED_OPTIONS:2103,MESSAGE_PARAMETER_MISSING_TO_ACCOUNT:2104,MESSAGE_SEND_NEED_MESSAGE_INSTANCE:2105,MESSAGE_SEND_INVALID_CONVERSATION_TYPE:2106,MESSAGE_RESEND_FILE_UNSUPPORTED:2107,MESSAGE_FILE_IS_EMPTY:2108,MESSAGE_IMAGE_UPLOAD_FAIL:2250,MESSAGE_IMAGE_SELECT_FILE_FIRST:2251,MESSAGE_IMAGE_TYPES_LIMIT:2252,MESSAGE_IMAGE_SIZE_LIMIT:2253,MESSAGE_AUDIO_UPLOAD_FAIL:2300,MESSAGE_AUDIO_SIZE_LIMIT:2301,MESSAGE_FILE_SELECT_FILE_FIRST:2401,MESSAGE_FILE_SIZE_LIMIT:2402,MESSAGE_FILE_URL_IS_EMPTY:2403,MESSAGE_FILE_WECHAT_MINIAPP_NOT_SUPPORT:2404,CONVERSATION_NOT_FOUND:2500,USER_OR_GROUP_NOT_FOUND:2501,CONVERSATION_UN_RECORDED_TYPE:2502,ILLEGAL_GROUP_TYPE:2600,CANNOT_JOIN_PRIVATE:2601,CANNOT_CHANGE_OWNER_IN_AVCHATROOM:2620,CANNOT_CHANGE_OWNER_TO_SELF:2621,CANNOT_DISMISS_PRIVATE:2622,JOIN_GROUP_FAIL:2660,CANNOT_ADD_MEMBER_IN_AVCHATROOM:2661,CANNOT_KICK_MEMBER_IN_AVCHATROOM:2680,NOT_OWNER:2681,CANNOT_SET_MEMBER_ROLE_IN_PRIVATE_AND_AVCHATROOM:2682,INVALID_MEMBER_ROLE:2683,CANNOT_SET_SELF_MEMBER_ROLE:2684,DEL_FRIEND_INVALID_PARAM:2700,GET_PROFILE_INVALID_PARAM:2720,UPDATE_PROFILE_INVALID_PARAM:2721,ADD_BLACKLIST_INVALID_PARAM:2740,DEL_BLACKLIST_INVALID_PARAM:2741,CANNOT_ADD_SELF_TO_BLACKLIST:2742,NETWORK_ERROR:2800,NETWORK_TIMEOUT:2801,NETWORK_BASE_OPTIONS_NO_URL:2802,NETWORK_UNDEFINED_SERVER_NAME:2803,NETWORK_PACKAGE_UNDEFINED:2804,SOCKET_NOT_SUPPORTED:2850,CONVERTOR_IRREGULAR_PARAMS:2900,NOTICE_RUNLOOP_UNEXPECTED_CONDITION:2901,NOTICE_RUNLOOP_OFFSET_LOST:2902,UNCAUGHT_ERROR:2903,SDK_IS_NOT_READY:2999,SSO_LOG_MODEL_INIT_ERROR:3e3,LONG_POLL_KICK_OUT:91101},Se={NO_SDKAPPID:"无 SDKAppID",NO_ACCOUNT_TYPE:"无 accountType",NO_IDENTIFIER:"无 userID",NO_USERSIG:"无 usersig",NO_SDK_INSTANCE:"无 SDK 实例",REQ_GET_ACCESS_LAYER_FAILED:"获取沙箱请求失败",REQ_LOGIN_FAILED:"登录请求失败",NO_TINYID:"无tinyid",NO_A2KEY:"无a2key",MESSAGE_SEND_FAIL:"消息发送失败",MESSAGE_UNKNOW_ROMA_LIST_END_FLAG_FIELD:"未知的漫游消息结束字段",MESSAGE_ELEMENT_METHOD_UNDEFINED:"消息元素未创建，因为方法未定义",MESSAGE_LIST_CONSTRUCTOR_NEED_OPTIONS:"MessageController.constructor() 需要参数 options",MESSAGE_PARAMETER_MISSING_TO_ACCOUNT:"需要 toAccount 参数",MESSAGE_SEND_NEED_MESSAGE_INSTANCE:"需要 Message 的实例",MESSAGE_SEND_INVALID_CONVERSATION_TYPE:'Message.conversationType 只能为 "C2C"或"GROUP" ',MESSAGE_RESEND_FILE_UNSUPPORTED:"文件类消息不能使用 SDK.resendMessage() 函数重发",MESSAGE_FILE_IS_EMPTY:"无法发送空文件",MESSAGE_IMAGE_UPLOAD_FAIL:"图片上传失败",MESSAGE_IMAGE_SELECT_FILE_FIRST:"请先选择一个图片",MESSAGE_IMAGE_TYPES_LIMIT:"图片类型受限",MESSAGE_IMAGE_SIZE_LIMIT:"图片大小受限",MESSAGE_AUDIO_UPLOAD_FAIL:"语音上传失败",MESSAGE_AUDIO_SIZE_LIMIT:"语音大小受限",MESSAGE_FILE_SELECT_FILE_FIRST:"请先选择一个文件",MESSAGE_FILE_SIZE_LIMIT:"文件大小受限 ",MESSAGE_FILE_URL_IS_EMPTY:"缺少必要的参数文件 URL",MESSAGE_FILE_WECHAT_MINIAPP_NOT_SUPPORT:"微信小程序暂时不支持文件选择功能",CONVERSATION_NOT_FOUND:"没有找到相应的会话，请检查传入参数",USER_OR_GROUP_NOT_FOUND:"没有找到相应的用户或群组，请检查传入参数",CONVERSATION_UN_RECORDED_TYPE:"未记录的会话类型",ILLEGAL_GROUP_TYPE:"非法的群类型，请检查传入参数",CANNOT_JOIN_PRIVATE:"不能加入 Private 类型的群组",CANNOT_CHANGE_OWNER_IN_AVCHATROOM:"AVChatRoom 类型的群组不能转让群主",CANNOT_CHANGE_OWNER_TO_SELF:"不能把群主转让给自己",CANNOT_DISMISS_PRIVATE:"不能解散 Private 类型的群组",JOIN_GROUP_FAIL:"加群失败，请检查传入参数或重试",CANNOT_ADD_MEMBER_IN_AVCHATROOM:"AVChatRoom 类型的群不支持邀请群成员",CANNOT_KICK_MEMBER_IN_AVCHATROOM:"不能在 AVChatRoom 类型的群组踢人",NOT_OWNER:"你不是群主，只有群主才有权限操作",CANNOT_SET_MEMBER_ROLE_IN_PRIVATE_AND_AVCHATROOM:"不能在 Private / AVChatRoom 类型的群中设置群成员身份",INVALID_MEMBER_ROLE:"不合法的群成员身份，请检查传入参数",CANNOT_SET_SELF_MEMBER_ROLE:"不能设置自己的群成员身份，请检查传入参数",DEL_FRIEND_INVALID_PARAM:"传入 deleteFriend 接口的参数无效",GET_PROFILE_INVALID_PARAM:"传入 getUserProfile 接口的参数无效",UPDATE_PROFILE_INVALID_PARAM:"传入 updateMyProfile 接口的参数无效",ADD_BLACKLIST_INVALID_PARAM:"传入 addToBlacklist 接口的参数无效",DEL_BLACKLIST_INVALID_PARAM:"传入 removeFromBlacklist 接口的参数无效",CANNOT_ADD_SELF_TO_BLACKLIST:"不能拉黑自己",NETWORK_ERROR:"网络错误",NETWORK_TIMEOUT:"请求超时",NETWORK_BASE_OPTIONS_NO_URL:"网络层初始化错误，缺少 URL 参数",NETWORK_UNDEFINED_SERVER_NAME:"打包错误，未定义的 serverName",NETWORK_PACKAGE_UNDEFINED:"未定义的 packageConfig",SOCKET_NOT_SUPPORTED:"当前浏览器不支持 WebSocket",CONVERTOR_IRREGULAR_PARAMS:"不规范的参数名称",NOTICE_RUNLOOP_UNEXPECTED_CONDITION:"意料外的通知条件",NOTICE_RUNLOOP_OFFSET_LOST:"_syncOffset 丢失",UNCAUGHT_ERROR:"未经明确定义的错误",SDK_IS_NOT_READY:"接口调用时机不合理，等待 SDK 处于 ready 状态后再调用（监听 TIM.EVENT.SDK_READY 事件）",LONG_POLL_KICK_OUT:"检测到多个 web 实例登录，消息通道下线",SSO_LOG_MODEL_INIT_ERROR:"SSOLogData 数据模型初始化错误"},Ce=function(e){function t(e){var n;return r(this,t),(n=g(this,l(t).call(this))).code=e.code,n.message=e.message,n.data=e.data||{},n}return c(t,f(Error)),t}(),Te="1.7.3",Me="537048168",De="10",Oe="protobuf",Ae="json",Ne={HOST:{TYPE:3,ACCESS_LAYER_TYPES:{SANDBOX:1,TEST:2,PRODUCTION:3},CURRENT:{COMMON:"https://webim.tim.qq.com",PIC:"https://pic.tim.qq.com",COS:"https://yun.tim.qq.com"},PRODUCTION:{COMMON:"https://webim.tim.qq.com",PIC:"https://pic.tim.qq.com",COS:"https://yun.tim.qq.com"},SANDBOX:{COMMON:"https://events.tim.qq.com",PIC:"https://pic.tim.qq.com",COS:"https://yun.tim.qq.com"},TEST:{COMMON:"https://test.tim.qq.com",PIC:"https://pic.tim.qq.com",COS:"https://yun.tim.qq.com"},setCurrent:function(){var e=arguments.length>0&&void 0!==arguments[0]?arguments[0]:3;switch(e){case this.ACCESS_LAYER_TYPES.SANDBOX:this.CURRENT=this.SANDBOX,this.TYPE=this.ACCESS_LAYER_TYPES.SANDBOX;break;case this.ACCESS_LAYER_TYPES.TEST:this.CURRENT=this.TEST,this.TYPE=this.ACCESS_LAYER_TYPES.TEST;break;default:this.CURRENT=this.PRODUCTION,this.TYPE=this.ACCESS_LAYER_TYPES.PRODUCTION}}},NAME:{OPEN_IM:"openim",GROUP:"group_open_http_svc",FRIEND:"sns",PROFILE:"profile",RECENT_CONTACT:"recentcontact",PIC:"openpic",BIG_GROUP_NO_AUTH:"group_open_http_noauth_svc",BIG_GROUP_LONG_POLLING_NO_AUTH:"group_open_long_polling_http_noauth_svc",IM_OPEN_STAT:"imopenstat",WEB_IM:"webim",IM_COS_SIGN:"im_cos_sign_svr"},CMD:{ACCESS_LAYER:"accesslayer",LOGIN:"login",LOGOUT_LONG_POLL:"longpollinglogout",LOGOUT_ALL:"logout",PORTRAIT_GET:"portrait_get",PORTRAIT_SET:"portrait_set",GET_LONG_POLL_ID:"getlongpollingid",LONG_POLL:"longpolling",AVCHATROOM_LONG_POLL:"get_msg",FRIEND_ADD:"friend_add",FRIEND_GET_ALL:"friend_get_all",FRIEND_DELETE:"friend_delete",RESPONSE_PENDENCY:"friend_response",GET_PENDENCY:"pendency_get",DELETE_PENDENCY:"pendency_delete",GET_BLACKLIST:"black_list_get",ADD_BLACKLIST:"black_list_add",DELETE_BLACKLIST:"black_list_delete",CREATE_GROUP:"create_group",GET_JOINED_GROUPS:"get_joined_group_list",SEND_MESSAGE:"sendmsg",SEND_GROUP_MESSAGE:"send_group_msg",GET_GROUP_INFO:"get_group_info",GET_GROUP_MEMBER_INFO:"get_group_member_info",QUIT_GROUP:"quit_group",CHANGE_GROUP_OWNER:"change_group_owner",DESTROY_GROUP:"destroy_group",ADD_GROUP_MEMBER:"add_group_member",DELETE_GROUP_MEMBER:"delete_group_member",SEARCH_GROUP_BY_ID:"get_group_public_info",APPLY_JOIN_GROUP:"apply_join_group",HANDLE_APPLY_JOIN_GROUP:"handle_apply_join_group",MODIFY_GROUP_INFO:"modify_group_base_info",MODIFY_GROUP_MEMBER_INFO:"modify_group_member_info",DELETE_GROUP_SYSTEM_MESSAGE:"deletemsg",GET_CONVERSATION_LIST:"get",DELETE_CONVERSATION:"delete",GET_MESSAGES:"getmsg",GET_C2C_ROAM_MESSAGES:"getroammsg",GET_GROUP_ROAM_MESSAGES:"group_msg_get",SET_C2C_MESSAGE_READ:"msgreaded",SET_GROUP_MESSAGE_READ:"msg_read_report",FILE_READ_AND_WRITE_AUTHKEY:"authkey",FILE_UPLOAD:"pic_up",COS_SIGN:"cos",TIM_WEB_REPORT:"tim_web_report"},CHANNEL:{SOCKET:1,XHR:2,AUTO:0},NAME_VERSION:{openim:"v4",group_open_http_svc:"v4",sns:"v4",profile:"v4",recentcontact:"v4",openpic:"v4",group_open_http_noauth_svc:"v1",group_open_long_polling_http_noauth_svc:"v1",imopenstat:"v4",im_cos_sign_svr:"v4",webim:"v3"}};Ne.HOST.setCurrent(Ne.HOST.ACCESS_LAYER_TYPES.PRODUCTION);var Le={request:{toAccount:"To_Account",fromAccount:"From_Account",to:"To_Account",from:"From_Account",groupID:"GroupId",avatar:"FaceUrl"},response:{GroupId:"groupID",Member_Account:"userID",MsgList:"messageList",SyncFlag:"syncFlag",To_Account:"to",From_Account:"from",MsgSeq:"sequence",MsgRandom:"random",MsgTimeStamp:"time",MsgContent:"content",MsgBody:"elements",MsgType:"type",MsgShow:"messageShow",NextMsgSeq:"nextMessageSeq",FaceUrl:"avatar",ProfileDataMod:"profileModify",Profile_Account:"userID",ValueBytes:"value",ValueNum:"value",NoticeSeq:"noticeSequence",NotifySeq:"notifySequence",Operator_Account:"operatorID",OpType:"operationType",ReportType:"operationType",UserId:"userID",User_Account:"userID",List_Account:"userIDList",MsgOperatorMemberExtraInfo:"operatorInfo",MsgMemberExtraInfo:"memberInfoList",ImageUrl:"avatar",NickName:"nick",MsgGroupNewInfo:"newGroupProfile",Owner_Account:"ownerID",GroupName:"name",GroupFaceUrl:"avatar",GroupIntroduction:"introduction",GroupNotification:"notification",GroupApplyJoinOption:"joinOption",MsgKey:"messageKey",GroupInfo:"groupProfile",Desc:"description",Ext:"extension"},ignoreKeyWord:["C2C","ID","USP"]},Re={CONTEXT_UPDATED:"_contextWasUpdated",CONTEXT_RESET:"_contextWasReset",CONTEXT_A2KEY_AND_TINYID_UPDATED:"_a2KeyAndTinyIDUpdated",RUNNING_STATE_CHANGE:"_runningStateChange",SYNC_MESSAGE_C2C_START:"_noticeSynchronizationStart",SYNC_MESSAGE_C2C_PROCESSING:"_noticeIsSynchronizing",SYNC_MESSAGE_C2C_FINISHED:"_noticeIsSynchronized",SYNC_MESSAGE_GROUP_SYSTEM_NOTICE_FINISHED:"_groupSystemNoticeSyncFinished",MESSAGE_SENDING:"_sendingMessage",MESSAGE_C2C_SEND_SUCCESS:"_sendC2CMessageSuccess",MESSAGE_C2C_SEND_FAIL:"_sendC2CMessageFail",MESSAGE_SYNC_PROCESSING:"_syncMessageProcessing",MESSAGE_SYNC_FINISHED:"_syncMessageFinished",MESSAGE_C2C_INSTANT_RECEIVED:"_receiveInstantMessage",MESSAGE_C2C_RECEIVE_ROAMING_SUCCESS:"_receiveC2CRoamingMessageSuccess",MESSAGE_C2C_RECEIVE_ROAMING_FAIL:"_receiveC2CRoamingMessageFail",MESSAGE_GROUP_SEND_SUCCESS:"_sendGroupMessageSuccess",MESSAGE_GROUP_SEND_FAIL:"_sendGroupMessageFail",MESSAGE_GROUP_RECEIVE_ROAMING_SUCCESS:"_receiveGroupRoamingMessageSuccess",MESSAGE_GROUP_RECEIVE_ROAMING_FAIL:"_receiveGroupRoamingMessageFail",MESSAGE_GROUP_INSTANT_RECEIVED:"_receiveGroupInstantMessage",MESSAGE_GROUP_SYSTEM_NOTICE_RECEIVED:"_receveGroupSystemNotice",NOTICE_LONGPOLL_GETID_SUCCESS:"_getLongPollIDSuccess",NOTICE_LONGPOLL_GETID_FAIL:"_getLongPollIDFail",NOTICE_LONGPOLL_START:"_longPollStart",NOTICE_LONGPOLL_IN_POLLING:"_longPollInPolling",NOTICE_LONGPOLL_REQUEST_ARRIVED:"_longPollInArrived",NOTICE_LONGPOLL_REQUEST_NOT_ARRIVED:"_longPollInNotArrived",NOTICE_LONGPOLL_JITTER:"_longPollJitter",NOTICE_LONGPOLL_SOON_RECONNECT:"_longPollSoonReconnect",NOTICE_LONGPOLL_LONG_RECONNECT:"_longPollLongReconnect",NOTICE_LONGPOLL_DISCONNECT:"_longpollChannelDisconnect",NOTICE_LONGPOLL_STOPPED:"_longPollStopped",NOTICE_LONGPOLL_KICKED_OUT:"_longPollKickedOut",NOTICE_LONGPOLL_MUTIPLE_DEVICE_KICKED_OUT:"_longPollMitipuleDeviceKickedOut",NOTICE_LONGPOLL_NEW_C2C_NOTICE:"_longPollGetNewC2CNotice",NOTICE_LONGPOLL_NEW_C2C_MESSAGES:"_longPollGetNewC2CMessages",NOTICE_LONGPOLL_NEW_GROUP_MESSAGES:"_longPollGetNewGroupMessages",NOTICE_LONGPOLL_NEW_GROUP_TIPS:"_longPollGetNewGroupTips",NOTICE_LONGPOLL_NEW_GROUP_NOTICE:"_longPollGetNewGroupNotice",NOTICE_LONGPOLL_NEW_FRIEND_MESSAGES:"_longPollGetNewFriendMessages",NOTICE_LONGPOLL_SEQUENCE_UPDATE:"_longPollNoticeSequenceUpdate",NOTICE_LONGPOLL_PROFILE_MODIFIED:"_longPollProfileModified",NOTICE_LONGPOLL_RECEIVE_SYSTEM_ORDERS:"_longPollNoticeReceiveSystemOrders",NOTICE_LONGPOLL_RESTART:"_longpollRestart",APPLY_ADD_FRIEND_SUCCESS:"_addFriendApplySendSucess",APPLY_ADD_FRIEND_FAIL:"_addFriendApplySendFail",APPLY_GET_PENDENCY_SUCCESS:"_applyGetPendenciesSucess",APPLY_GET_PENDENCY_FAIL:"_applyGetPendenciesFail",APPLY_DELETE_SUCCESS:"_applyDeletedSucess",APPLY_DELETE_FAIL:"_applyDeletedFail",GROUP_CREATE_SUCCESS:"_createGroupSuccess",GROUP_CREATE_FAIL:"_createGroupFail",GROUP_LIST_UPDATED:"_onGroupListUpdated",SIGN_LOGIN_CHANGE:"_loginStatusChange",SIGN_LOGIN:"_login",SIGN_LOGIN_SUCCESS:"_loginSuccess",SIGN_LOGIN_FAIL:"_loginFail",SIGN_LOGININFO_UPDATED:"_signLoginInfoUpdated",SIGN_LOGOUT_EXECUTING:"_signLogoutExcuting",SIGN_LOGOUT_SUCCESS:"_logoutSuccess",SIGN_GET_ACCESS_LAYER_CHANGE:"_getAccessLayerStatusChange",SIGN_GET_ACCESS_LAYER_SUCCESS:"_getAccessLayerSuccess",SIGN_GET_ACCESS_LAYER_FAIL:"_getAccessLayerFail",ERROR_DETECTED:"_errorHasBeenDetected",CONVERSATION_LIST_UPDATED:"_onConversationListUpdated",CONVERSATION_LIST_PROFILE_UPDATED:"_onConversationListProfileUpdated",CONVERSATION_DELETED:"_conversationDeleted",PROFILE_UPDATED:"onProfileUpdated",FRIEND_GET_SUCCESS:"_getFriendsSuccess",FRIEND_GET_FAIL:"_getFriendsFail",FRIEND_DELETE_SUCCESS:"_deleteFriendSuccess",FRIEND_DELETE_FAIL:"_deleteFriendFail",BLACKLIST_ADD_SUCCESS:"_addBlacklistSuccess",BLACKLIST_ADD_FAIL:"_addBlacklistFail",BLACKLIST_GET_SUCCESS:"_getBlacklistSuccess",BLACKLIST_GET_FAIL:"_getBlacklistFail",AVCHATROOM_OPTIONS_UPDATED:"_AVChatRoomOptionsUpdated",AVCHATROOM_JOIN_SUCCESS:"joinAVChatRoomSuccess",SDK_MEMORY_STATUS_UPDATE:"_sdkMemoryStatusUpdate",SDK_READY:"_sdkStateReady",SDK_SSO_LOGGER:"_sdkSSOLogger"};function Pe(e,t){if("string"!=typeof e&&!Array.isArray(e))throw new TypeError("Expected the input to be `string | string[]`");t=Object.assign({pascalCase:0},t);var n;return 0===(e=Array.isArray(e)?e.map(function(e){return e.trim()}).filter(function(e){return e.length}).join("-"):e.trim()).length?"":1===e.length?t.pascalCase?e.toUpperCase():e.toLowerCase():(e!==e.toLowerCase()&&(e=Ge(e)),e=e.replace(/^[_.\- ]+/,"").toLowerCase().replace(/[_.\- ]+(\w|$)/g,function(e,t){return t.toUpperCase()}).replace(/\d+(\w|$)/g,function(e){return e.toUpperCase()}),n=e,t.pascalCase?n.charAt(0).toUpperCase()+n.slice(1):n)}var Ge=function(e){for(var t=0,n=0,r=0,o=0;o<e.length;o++){var i=e[o];t&&/[a-zA-Z]/.test(i)&&i.toUpperCase()===i?(e=e.slice(0,o)+"-"+e.slice(o),t=0,r=n,n=1,o++):n&&r&&/[a-zA-Z]/.test(i)&&i.toLowerCase()===i?(e=e.slice(0,o-1)+"-"+e.slice(o-1),r=n,n=0,t=1):(t=i.toLowerCase()===i&&i.toUpperCase()!==i,r=n,n=i.toUpperCase()===i&&i.toLowerCase()!==i)}return e};function ke(e,t,n){var r=[],o=0,i=function e(t,n){if(++o>10)return o--,t;if(te(t)){var i=t.map(function(t){return ee(t)?e(t,n):t});return o--,i}if(ee(t)){var a=(s=t,u=function(e,t){if(!ie(t))return 0;if((a=t)!==Pe(a)){for(var o=1,i=0;i<Le.ignoreKeyWord.length;i++)if(t.includes(Le.ignoreKeyWord[i])){o=0;break}o&&r.push(t)}var a;return ne(n[t])?function(e){return e[0].toUpperCase()+Pe(e).slice(1)}(t):n[t]},c=Object.create(null),Object.keys(s).forEach(function(e){var t=u(s[e],e);t&&(c[t]=s[e])}),c);return a=Ee(a,function(t,r){return te(t)||ee(t)?e(t,n):t}),o--,a}var s,u,c}(e,t=u({},Le.request,{},t));return r.length>0&&n.innerEmitter.emit(Re.ERROR_DETECTED,{code:Ie.CONVERTOR_IRREGULAR_PARAMS,message:Ie.CONVERTOR_IRREGULAR_PARAMS}),i}function we(e,t){if(t=u({},Le.response,{},t),te(e))return e.map(function(e){return ee(e)?we(e,t):e});if(ee(e)){var n=(r=e,o=function(e,n){return ne(t[n])?Pe(n):t[n]},i={},Object.keys(r).forEach(function(e){i[o(r[e],e)]=r[e]}),i);return n=Ee(n,function(e){return te(e)||ee(e)?we(e,t):e})}var r,o,i}var be=function(){function e(t,n){var o=this;if(r(this,e),void 0===n)throw new Ce({code:Ie.NO_SDK_INSTANCE,message:Se.NO_SDK_INSTANCE});this.tim=n,this.method=t.method||"POST",this._initializeServerMap(),this._initializeURL(t),this._initializeRequestData(t),this.callback=function(e){return we(e=t.decode(e),o._getResponseMap(t))}}return i(e,[{key:"_initializeServerMap",value:function(){this._serverMap=Object.create(null);var e="";for(var t in Ne.NAME)if(Object.prototype.hasOwnProperty.call(Ne.NAME,t))switch(e=Ne.NAME[t]){case Ne.NAME.PIC:this._serverMap[e]=Ne.HOST.CURRENT.PIC;break;case Ne.NAME.IM_COS_SIGN:this._serverMap[e]=Ne.HOST.CURRENT.COS;break;default:this._serverMap[e]=Ne.HOST.CURRENT.COMMON}}},{key:"_getHost",value:function(e){if(void 0!==this._serverMap[e])return this._serverMap[e];throw new Ce({code:Ie.NETWORK_UNDEFINED_SERVER_NAME,message:Se.NETWORK_UNDEFINED_SERVER_NAME})}},{key:"_initializeURL",value:function(e){var t=e.serverName,n=e.cmd,r=this._getHost(t),o="".concat(r,"/").concat(Ne.NAME_VERSION[t],"/").concat(t,"/").concat(n);o+="?".concat(this._getQueryString(e.queryString)),this.url=o}},{key:"getUrl",value:function(){return this.url.replace(/&reqtime=(\d+)/,"&reqtime=".concat(Math.ceil(+new Date/1e3)))}},{key:"_initializeRequestData",value:function(e){var t,n=e.requestData;t=this._requestDataCleaner(n),this.requestData=e.encode(t)}},{key:"_requestDataCleaner",value:function(e){var t=Array.isArray(e)?[]:Object.create(null);for(var r in e)Object.prototype.hasOwnProperty.call(e,r)&&ie(r)&&null!==e[r]&&("object"!==n(e[r])?t[r]=e[r]:t[r]=this._requestDataCleaner.bind(this)(e[r]));return t}},{key:"_getQueryString",value:function(e){var t=[];for(var n in e)Object.prototype.hasOwnProperty.call(e,n)&&("function"!=typeof e[n]?t.push("".concat(n,"=").concat(e[n])):t.push("".concat(n,"=").concat(e[n]())));return t.join("&")}},{key:"_getResponseMap",value:function(e){if(e.keyMaps&&e.keyMaps.response&&Object.keys(e.keyMaps.response).length>0)return e.keyMaps.response}}]),e}();function Ue(e){this.mixin(e)}Ue.mixin=function(e){var t=e.prototype||e;t._isReady=0,t.ready=function(e){var t=arguments.length>1&&void 0!==arguments[1]?arguments[1]:0;if(e)return this._isReady?void(t?e.call(this):setTimeout(e,1)):(this._readyQueue=this._readyQueue||[],void this._readyQueue.push(e))},t.triggerReady=function(){var e=this;this._isReady=1,setTimeout(function(){var t=e._readyQueue;e._readyQueue=[],t&&t.length>0&&t.forEach(function(e){e.call(this)},e)},1)},t.resetReady=function(){this._isReady=0,this._readyQueue=[]},t.isReady=function(){return this._isReady}};var Fe=function(){function e(t){if(r(this,e),0==!!t)throw new Ce({code:Ie.NO_SDK_INSTANCE,message:Se.NO_SDK_INSTANCE});Ue.mixin(this),this.tim=t,this.innerEmitter=t.innerEmitter,this.connectionController=t.connectionController,this.packageConfig=t.packageConfig,this.packageConfig.update(t)}return i(e,[{key:"createPackage",value:function(e){var t=this.packageConfig.get(e);return t?new be(t,this.tim):0}},{key:"reset",value:function(){Q.warn(["method: IMController.reset() method must be implemented"].join())}},{key:"destroy",value:function(){Q.warn("destory")}}]),e}(),qe=function(){function e(t,n){r(this,e),this.data=t,this.tim=n,this.defaultData={},Object.assign(this.defaultData,t),this.initGetterAndSetter()}return i(e,[{key:"initGetterAndSetter",value:function(){var e=this,t=this.tim,n=function(n,r){Object.defineProperty(e,n,{enumerable:1,configurable:1,get:function(){return e.data[n]},set:function(r){e.data[n]=r,e.onChange.bind(e)(t.context,n,r)}})};for(var r in e.data)Object.prototype.hasOwnProperty.call(e.data,r)&&n(r,e.data[r])}},{key:"onChange",value:function(e,t,n){this.tim.innerEmitter.emit(Re.CONTEXT_UPDATED,{data:{context:e,key:t,value:n}})}},{key:"reset",value:function(){var e=this.tim;for(var t in this.data)Object.prototype.hasOwnProperty.call(this.data,t)&&(this.data[t]=this.defaultData.hasOwnProperty(t)?this.defaultData[t]:null);this.tim.innerEmitter.emit(Re.CONTEXT_RESET,{data:e.context})}}]),e}(),xe={SUCCESS:"JoinedSuccess",WAIT_APPROVAL:"WaitAdminApproval"},He={COMMON:{SUCCESS:"OK",FAIL:"FAIL"},REQUEST:{SUCCESS:0},ACCESS_LAYER:{PRODUCTION:0,TEST:1},LOGIN:{IS_LOGIN:1,IS_NOT_LOGIN:0},SYNC_MESSAGE:{SYNCHRONIZATION_START:0,SYNCHRONIZING:1,SYNCHRONIZED:2},MESSAGE_STATUS:{UNSEND:"unSend",SUCCESS:"success",FAIL:"fail"},GET_HISTORY_MESSAGE_STATUS:{C2C_IS_FINISHED:1,C2C_IS_NOT_FINISHED:0,GROUP_IS_FINISHED:1,GROUP_IS_NOT_FINISHED:0},ACCOUNT_STATUS:{SIGN_IN:1,SIGN_OUT:0},CHANNEL_STATUS:{ONLINE:1,OFFLINE:0},JOIN_GROUP_STATUS:xe,UPLOAD:{FINISHED:1,UPLOADING:0}},Ke=function(e){function t(e){var n;return r(this,t),(n=g(this,l(t).call(this,e)))._initContext(),n._initListener(),n}return c(t,Fe),i(t,[{key:"reset",value:function(){this.tim.context.reset()}},{key:"_IAmReady",value:function(){this.triggerReady()}},{key:"_initListener",value:function(){this.tim.innerEmitter.on(Re.SIGN_LOGIN_SUCCESS,this._updateA2KeyAndTinyID,this)}},{key:"_updateA2KeyAndTinyID",value:function(e){var t=e.data,n=t.a2Key,r=t.tinyID;this.set("a2Key",n),this.set("tinyID",r),this.tim.innerEmitter.emit(Re.CONTEXT_A2KEY_AND_TINYID_UPDATED,{data:{context:this.tim.context}}),this._IAmReady()}},{key:"get",value:function(e){return this.tim.context[e]}},{key:"set",value:function(e,t){this.tim.context[e]=t}},{key:"_initContext",value:function(){var e=this.tim.loginInfo;this.tim.context=new qe({login:He.LOGIN.IS_NOT_LOGIN,SDKAppID:e.SDKAppID,appIDAt3rd:null,accountType:e.accountType,identifier:e.identifier,tinyID:null,identifierNick:e.identifierNick,userSig:e.userSig,a2Key:null,contentType:"json",apn:1},this.tim),this.tim.innerEmitter.on(Re.CONTEXT_UPDATED,this._onContextMemberChange.bind(this))}},{key:"_onContextMemberChange",value:function(e){var t=e.data,n=t.key,r=t.value;switch(n){case"tinyID":r.length<=0?this.tim.context.login=He.LOGIN.IS_NOT_LOGIN:this.tim.context.login=null!==this.tim.context.a2Key?He.LOGIN.IS_LOGIN:He.LOGIN.IS_NOT_LOGIN;break;case"a2Key":r.length<=0?this.tim.context.login=He.LOGIN.IS_NOT_LOGIN:this.tim.context.login=null!==this.tim.context.tinyID?He.LOGIN.IS_LOGIN:He.LOGIN.IS_NOT_LOGIN}}}]),t}(),Be={JSON:{TYPE:{C2C:{NOTICE:1,COMMON:9,EVENT:10},GROUP:{COMMON:3,TIP:4,SYSTEM:5,TIP2:6},FRIEND:{NOTICE:7},PROFILE:{NOTICE:8}},SUBTYPE:{C2C:{COMMON:0,READED:92,KICKEDOUT:96},GROUP:{COMMON:0,LOVEMESSAGE:1,TIP:2,REDPACKET:3}},OPTIONS:{GROUP:{JOIN:1,QUIT:2,KICK:3,SET_ADMIN:4,CANCEL_ADMIN:5,MODIFY_GROUP_INFO:6,MODIFY_MEMBER_INFO:7}}},PROTOBUF:{},IMAGE_TYPES:{ORIGIN:1,LARGE:2,SMALL:3},IMAGE_FORMAT:{JPG:1,JPEG:1,GIF:2,PNG:3,BMP:4,UNKNOWN:255}},Ve=1,Ye=2,je=3,ze=4,We=5,Xe=7,Je=8,Qe=9,Ze=10,$e=15,et=255,tt=2,nt=0,rt=1,ot={NICK:"Tag_Profile_IM_Nick",GENDER:"Tag_Profile_IM_Gender",BIRTHDAY:"Tag_Profile_IM_BirthDay",LOCATION:"Tag_Profile_IM_Location",SELFSIGNATURE:"Tag_Profile_IM_SelfSignature",ALLOWTYPE:"Tag_Profile_IM_AllowType",LANGUAGE:"Tag_Profile_IM_Language",AVATAR:"Tag_Profile_IM_Image",MESSAGESETTINGS:"Tag_Profile_IM_MsgSettings",ADMINFORBIDTYPE:"Tag_Profile_IM_AdminForbidType",LEVEL:"Tag_Profile_IM_Level",ROLE:"Tag_Profile_IM_Role"},it={UNKNOWN:"Gender_Type_Unknown",FEMALE:"Gender_Type_Female",MALE:"Gender_Type_Male"},at={NONE:"AdminForbid_Type_None",SEND_OUT:"AdminForbid_Type_SendOut"},st={NEED_CONFIRM:"AllowType_Type_NeedConfirm",ALLOW_ANY:"AllowType_Type_AllowAny",DENY_ANY:"AllowType_Type_DenyAny"},ut=function e(t){r(this,e),this.code=0,this.data=t||{}},ct=null,lt=function(e){ct=e},pt=function(e){return e instanceof ut?(Q.warn("IMPromise.resolve 此函数会自动用options创建IMResponse实例，调用侧不需创建，建议修改！"),Promise.resolve(e)):Promise.resolve(new ut(e))},ht=function(t){var n=arguments.length>1&&void 0!==arguments[1]?arguments[1]:0;if(t instanceof Ce)return n&&null!==ct&&ct.emit(e.ERROR,t),Promise.reject(t);if(t instanceof Error){Q.warn("IMPromise.reject options not instanceof IMError! details:",t);var r=new Ce({code:Ie.UNCAUGHT_ERROR,message:t.message});return n&&null!==ct&&ct.emit(e.ERROR,r),Promise.reject(r)}if(ne(t)||ne(t.code)||ne(t.message))Q.error("IMPromise.reject 必须指定code(错误码)和message(错误信息)!!!");else{if(Z(t.code)&&$(t.message)){var o=new Ce(t);return n&&null!==ct&&ct.emit(e.ERROR,o),Promise.reject(o)}Q.error("IMPromise.reject code(错误码)必须为数字，message(错误信息)必须为字符串!!!")}},ft="sdkReady",_t="login",gt="initConversationList",dt="initGroupList",mt="upload",Et=function(n){function o(e){var t;return r(this,o),(t=g(this,l(o).call(this,e))).devLoginTips='new TIM({\n      SDKAppID: "必填",\n      accountType: "必填",\n      identifier: "必填",\n      userSig: "必填",\n      identifierNick: "可选"\n    })\n    ',t._initializeListener(),t}return c(o,Fe),i(o,[{key:"login",value:function(e){if(1==this._isLogin()&&this._isLoginCurrentUser(e.identifier))return this.tim.innerEmitter.emit(Re.NOTICE_LONGPOLL_RESTART),pt(new ut("重启消息通道"));if(this._isLogin()){var t="您已经登录账号".concat(e.identifier,"！如需切换账号登录，请先调用 logout 接口登出，再调用 login 接口登录。");return Q.warn(t),pt(new ut(t))}Q.log("SignController.login userID=",e.identifier),Q.time(_t);var n=this._checkLoginInfo(e);return T(n)?(this.tim.context.identifier=e.identifier,this.tim.context.userSig=e.userSig,this.tim.context.SDKAppID=e.SDKAppID,this.tim.context.accountType=e.accountType,this.tim.context.identifier&&this.tim.context.userSig?(this.tim.innerEmitter.emit(Re.SIGN_LOGIN),this._accessLayer()):void 0):ht(n)}},{key:"_isLogin",value:function(){return!!this.tim.context.a2Key}},{key:"_isLoginCurrentUser",value:function(e){return this.tim.context.identifier===e}},{key:"_initializeListener",value:function(){this.innerEmitter.on(Re.NOTICE_LONGPOLL_KICKED_OUT,this._onKickedOut,this),this.innerEmitter.on(Re.NOTICE_LONGPOLL_MUTIPLE_DEVICE_KICKED_OUT,this._onMultipleDeviceKickedOut,this)}},{key:"_accessLayer",value:function(){var e=this;Q.log("SignController._accessLayer.");var t=this.createPackage({name:"accessLayer",action:"query"});return this.tim.connectionController.request(t).then(function(t){return Q.log("SignController._accessLayer ok. webImAccessLayer=",t.data.webImAccessLayer),1===t.data.webImAccessLayer&&Ne.HOST.setCurrent(t.data.webImAccessLayer),e._login()}).catch(function(e){return Q.error("SignController._accessLayer error:",e),ht(e,1)})}},{key:"_login",value:function(){var t=this,n=this.createPackage({name:"login",action:"query"});return this.connectionController.request(n).then(function(n){if(0==!!n.data.tinyID)throw new Ce({code:Ie.NO_TINYID,message:Se.NO_TINYID});if(0==!!n.data.a2Key)throw new Ce({code:Ie.NO_A2KEY,message:Se.NO_A2KEY});return Q.log("SignController.login ok. userID=".concat(t.tim.loginInfo.identifier," loginCost=").concat(Q.timeEnd(_t),"ms")),t.tim.innerEmitter.emit(Re.SIGN_LOGIN_SUCCESS,{data:{a2Key:n.data.a2Key,tinyID:n.data.tinyID}}),t.tim.outerEmitter.emit(e.LOGIN_SUCCESS),pt(n.data)}).catch(function(e){return Q.error("SignController.login error:",e),ht(e)})}},{key:"logout",value:function(){return Q.info("SignController.logout"),this.tim.innerEmitter.emit(Re.SIGN_LOGOUT_EXECUTING),Promise.all(this._logout(rt),this._logout(nt)).then(this._emitLogoutSuccess.bind(this)).catch(this._emitLogoutSuccess.bind(this))}},{key:"_logout",value:function(e){var t=this.tim.notificationController,n=e===nt?"logout":"longPollLogout",r=e===nt?{name:n,action:"query"}:{name:n,action:"query",param:{longPollID:t.getLongPollID()}},o=this.createPackage(r);return this.connectionController.request(o).catch(function(e){return Q.error("SignController._logout error:",e),ht(e)})}},{key:"_checkLoginInfo",value:function(e){var t=0,n="";return null===e.SDKAppID?(t=Ie.NO_SDKAPPID,n=Se.NO_SDKAPPID):null===e.accountType?(t=Ie.NO_ACCOUNT_TYPE,n=Se.NO_ACCOUNT_TYPE):null===e.identifier?(t=Ie.NO_IDENTIFIER,n=Se.NO_IDENTIFIER):null===e.userSig&&(t=Ie.NO_USERSIG,n=Se.NO_USERSIG),T(t)||T(n)?{}:{code:t,message:n}}},{key:"_emitLogoutSuccess",value:function(){return this.tim.innerEmitter.emit(Re.SIGN_LOGOUT_SUCCESS),pt({})}},{key:"_onKickedOut",value:function(){var n=this;this.tim.logout().then(function(){Q.warn("SignController._onKickedOut kicked out.       userID=".concat(n.tim.loginInfo.identifier)),n.tim.outerEmitter.emit(e.KICKED_OUT,{type:t.KICKED_OUT_MULT_ACCOUNT})})}},{key:"_onMultipleDeviceKickedOut",value:function(){var n=this;this.tim.logout().then(function(){Q.warn("SignController._onKickedOut kicked out.       userID=".concat(n.tim.loginInfo.identifier)),n.tim.outerEmitter.emit(e.KICKED_OUT,{type:t.KICKED_OUT_MULT_DEVICE})})}},{key:"reset",value:function(){}}]),o}(),yt=function(e,t){return function(){for(var n=new Array(arguments.length),r=0;r<n.length;r++)n[r]=arguments[r];return e.apply(t,n)}},vt=Object.prototype.toString;function It(e){return"[object Array]"===vt.call(e)}function St(e){return null!==e&&"object"==typeof e}function Ct(e){return"[object Function]"===vt.call(e)}function Tt(e,t){if(null!=e)if("object"!=typeof e&&(e=[e]),It(e))for(var n=0,r=e.length;n<r;n++)t.call(null,e[n],n,e);else for(var o in e)Object.prototype.hasOwnProperty.call(e,o)&&t.call(null,e[o],o,e)}var Mt={isArray:It,isArrayBuffer:function(e){return"[object ArrayBuffer]"===vt.call(e)},isBuffer:function(e){return null!=e&&null!=e.constructor&&"function"==typeof e.constructor.isBuffer&&e.constructor.isBuffer(e)},isFormData:function(e){return"undefined"!=typeof FormData&&e instanceof FormData},isArrayBufferView:function(e){return"undefined"!=typeof ArrayBuffer&&ArrayBuffer.isView?ArrayBuffer.isView(e):e&&e.buffer&&e.buffer instanceof ArrayBuffer},isString:function(e){return"string"==typeof e},isNumber:function(e){return"number"==typeof e},isObject:St,isUndefined:function(e){return void 0===e},isDate:function(e){return"[object Date]"===vt.call(e)},isFile:function(e){return"[object File]"===vt.call(e)},isBlob:function(e){return"[object Blob]"===vt.call(e)},isFunction:Ct,isStream:function(e){return St(e)&&Ct(e.pipe)},isURLSearchParams:function(e){return"undefined"!=typeof URLSearchParams&&e instanceof URLSearchParams},isStandardBrowserEnv:function(){return"undefined"==typeof navigator||"ReactNative"!==navigator.product&&"NativeScript"!==navigator.product&&"NS"!==navigator.product?"undefined"!=typeof window&&"undefined"!=typeof document:0},forEach:Tt,merge:function e(){var t={};function n(n,r){"object"==typeof t[r]&&"object"==typeof n?t[r]=e(t[r],n):t[r]=n}for(var r=0,o=arguments.length;r<o;r++)Tt(arguments[r],n);return t},deepMerge:function e(){var t={};function n(n,r){"object"==typeof t[r]&&"object"==typeof n?t[r]=e(t[r],n):t[r]="object"==typeof n?e({},n):n}for(var r=0,o=arguments.length;r<o;r++)Tt(arguments[r],n);return t},extend:function(e,t,n){return Tt(t,function(t,r){e[r]=n&&"function"==typeof t?yt(t,n):t}),e},trim:function(e){return e.replace(/^\s*/,"").replace(/\s*$/,"")}};function Dt(e){return encodeURIComponent(e).replace(/%40/gi,"@").replace(/%3A/gi,":").replace(/%24/g,"$").replace(/%2C/gi,",").replace(/%20/g,"+").replace(/%5B/gi,"[").replace(/%5D/gi,"]")}var Ot=function(e,t,n){if(!t)return e;var r;if(n)r=n(t);else if(Mt.isURLSearchParams(t))r=t.toString();else{var o=[];Mt.forEach(t,function(e,t){null!=e&&(Mt.isArray(e)?t+="[]":e=[e],Mt.forEach(e,function(e){Mt.isDate(e)?e=e.toISOString():Mt.isObject(e)&&(e=JSON.stringify(e)),o.push(Dt(t)+"="+Dt(e))}))}),r=o.join("&")}if(r){var i=e.indexOf("#");-1!==i&&(e=e.slice(0,i)),e+=(-1===e.indexOf("?")?"?":"&")+r}return e};function At(){this.handlers=[]}At.prototype.use=function(e,t){return this.handlers.push({fulfilled:e,rejected:t}),this.handlers.length-1},At.prototype.eject=function(e){this.handlers[e]&&(this.handlers[e]=null)},At.prototype.forEach=function(e){Mt.forEach(this.handlers,function(t){null!==t&&e(t)})};var Nt=At,Lt=function(e,t,n){return Mt.forEach(n,function(n){e=n(e,t)}),e},Rt=function(e){return!(!e||!e.__CANCEL__)};function Pt(){throw new Error("setTimeout has not been defined")}function Gt(){throw new Error("clearTimeout has not been defined")}var kt=Pt,wt=Gt;function bt(e){if(kt===setTimeout)return setTimeout(e,0);if((kt===Pt||!kt)&&setTimeout)return kt=setTimeout,setTimeout(e,0);try{return kt(e,0)}catch(t){try{return kt.call(null,e,0)}catch(t){return kt.call(this,e,0)}}}"function"==typeof O.setTimeout&&(kt=setTimeout),"function"==typeof O.clearTimeout&&(wt=clearTimeout);var Ut,Ft=[],qt=0,xt=-1;function Ht(){qt&&Ut&&(qt=0,Ut.length?Ft=Ut.concat(Ft):xt=-1,Ft.length&&Kt())}function Kt(){if(!qt){var e=bt(Ht);qt=1;for(var t=Ft.length;t;){for(Ut=Ft,Ft=[];++xt<t;)Ut&&Ut[xt].run();xt=-1,t=Ft.length}Ut=null,qt=0,function(e){if(wt===clearTimeout)return clearTimeout(e);if((wt===Gt||!wt)&&clearTimeout)return wt=clearTimeout,clearTimeout(e);try{wt(e)}catch(t){try{return wt.call(null,e)}catch(t){return wt.call(this,e)}}}(e)}}function Bt(e,t){this.fun=e,this.array=t}Bt.prototype.run=function(){this.fun.apply(null,this.array)};function Vt(){}var Yt=Vt,jt=Vt,zt=Vt,Wt=Vt,Xt=Vt,Jt=Vt,Qt=Vt;var Zt=O.performance||{},$t=Zt.now||Zt.mozNow||Zt.msNow||Zt.oNow||Zt.webkitNow||function(){return(new Date).getTime()};var en=new Date;var tn={nextTick:function(e){var t=new Array(arguments.length-1);if(arguments.length>1)for(var n=1;n<arguments.length;n++)t[n-1]=arguments[n];Ft.push(new Bt(e,t)),1!==Ft.length||qt||bt(Kt)},title:"browser",browser:1,env:{},argv:[],version:"",versions:{},on:Yt,addListener:jt,once:zt,off:Wt,removeListener:Xt,removeAllListeners:Jt,emit:Qt,binding:function(e){throw new Error("process.binding is not supported")},cwd:function(){return"/"},chdir:function(e){throw new Error("process.chdir is not supported")},umask:function(){return 0},hrtime:function(e){var t=.001*$t.call(Zt),n=Math.floor(t),r=Math.floor(t%1*1e9);return e&&(n-=e[0],(r-=e[1])<0&&(n--,r+=1e9)),[n,r]},platform:"browser",release:{},config:{},uptime:function(){return(new Date-en)/1e3}},nn=function(e,t){Mt.forEach(e,function(n,r){r!==t&&r.toUpperCase()===t.toUpperCase()&&(e[t]=n,delete e[r])})},rn=function(e,t,n,r,o){return function(e,t,n,r,o){return e.config=t,n&&(e.code=n),e.request=r,e.response=o,e.isAxiosError=1,e.toJSON=function(){return{message:this.message,name:this.name,description:this.description,number:this.number,fileName:this.fileName,lineNumber:this.lineNumber,columnNumber:this.columnNumber,stack:this.stack,config:this.config,code:this.code}},e}(new Error(e),t,n,r,o)},on=["age","authorization","content-length","content-type","etag","expires","from","host","if-modified-since","if-unmodified-since","last-modified","location","max-forwards","proxy-authorization","referer","retry-after","user-agent"],an=Mt.isStandardBrowserEnv()?function(){var e,t=/(msie|trident)/i.test(navigator.userAgent),n=document.createElement("a");function r(e){var r=e;return t&&(n.setAttribute("href",r),r=n.href),n.setAttribute("href",r),{href:n.href,protocol:n.protocol?n.protocol.replace(/:$/,""):"",host:n.host,search:n.search?n.search.replace(/^\?/,""):"",hash:n.hash?n.hash.replace(/^#/,""):"",hostname:n.hostname,port:n.port,pathname:"/"===n.pathname.charAt(0)?n.pathname:"/"+n.pathname}}return e=r(window.location.href),function(t){var n=Mt.isString(t)?r(t):t;return n.protocol===e.protocol&&n.host===e.host}}():function(){return 1},sn=Mt.isStandardBrowserEnv()?{write:function(e,t,n,r,o,i){var a=[];a.push(e+"="+encodeURIComponent(t)),Mt.isNumber(n)&&a.push("expires="+new Date(n).toGMTString()),Mt.isString(r)&&a.push("path="+r),Mt.isString(o)&&a.push("domain="+o),1==i&&a.push("secure"),document.cookie=a.join("; ")},read:function(e){var t=document.cookie.match(new RegExp("(^|;\\s*)("+e+")=([^;]*)"));return t?decodeURIComponent(t[3]):null},remove:function(e){this.write(e,"",Date.now()-864e5)}}:{write:function(){},read:function(){return null},remove:function(){}},un=function(e){return new Promise(function(t,n){var r=e.data,o=e.headers;Mt.isFormData(r)&&delete o["Content-Type"];var i=new XMLHttpRequest;if(e.auth){var a=e.auth.username||"",s=e.auth.password||"";o.Authorization="Basic "+btoa(a+":"+s)}if(i.open(e.method.toUpperCase(),Ot(e.url,e.params,e.paramsSerializer),1),i.timeout=e.timeout,i.onreadystatechange=function(){if(i&&4===i.readyState&&(0!==i.status||i.responseURL&&0===i.responseURL.indexOf("file:"))){var r,o,a,s,u,c="getAllResponseHeaders"in i?(r=i.getAllResponseHeaders(),u={},r?(Mt.forEach(r.split("\n"),function(e){if(s=e.indexOf(":"),o=Mt.trim(e.substr(0,s)).toLowerCase(),a=Mt.trim(e.substr(s+1)),o){if(u[o]&&on.indexOf(o)>=0)return;u[o]="set-cookie"===o?(u[o]?u[o]:[]).concat([a]):u[o]?u[o]+", "+a:a}}),u):u):null,l={data:e.responseType&&"text"!==e.responseType?i.response:i.responseText,status:i.status,statusText:i.statusText,headers:c,config:e,request:i};!function(e,t,n){var r=n.config.validateStatus;!r||r(n.status)?e(n):t(rn("Request failed with status code "+n.status,n.config,null,n.request,n))}(t,n,l),i=null}},i.onabort=function(){i&&(n(rn("Request aborted",e,"ECONNABORTED",i)),i=null)},i.onerror=function(){n(rn("Network Error",e,null,i)),i=null},i.ontimeout=function(){n(rn("timeout of "+e.timeout+"ms exceeded",e,"ECONNABORTED",i)),i=null},Mt.isStandardBrowserEnv()){var u=sn,c=(e.withCredentials||an(e.url))&&e.xsrfCookieName?u.read(e.xsrfCookieName):void 0;c&&(o[e.xsrfHeaderName]=c)}if("setRequestHeader"in i&&Mt.forEach(o,function(e,t){void 0===r&&"content-type"===t.toLowerCase()?delete o[t]:i.setRequestHeader(t,e)}),e.withCredentials&&(i.withCredentials=1),e.responseType)try{i.responseType=e.responseType}catch(l){if("json"!==e.responseType)throw l}"function"==typeof e.onDownloadProgress&&i.addEventListener("progress",e.onDownloadProgress),"function"==typeof e.onUploadProgress&&i.upload&&i.upload.addEventListener("progress",e.onUploadProgress),e.cancelToken&&e.cancelToken.promise.then(function(e){i&&(i.abort(),n(e),i=null)}),void 0===r&&(r=null),i.send(r)})},cn={"Content-Type":"application/x-www-form-urlencoded"};function ln(e,t){!Mt.isUndefined(e)&&Mt.isUndefined(e["Content-Type"])&&(e["Content-Type"]=t)}var pn,hn={adapter:(void 0!==tn&&"[object process]"===Object.prototype.toString.call(tn)?pn=un:"undefined"!=typeof XMLHttpRequest&&(pn=un),pn),transformRequest:[function(e,t){return nn(t,"Accept"),nn(t,"Content-Type"),Mt.isFormData(e)||Mt.isArrayBuffer(e)||Mt.isBuffer(e)||Mt.isStream(e)||Mt.isFile(e)||Mt.isBlob(e)?e:Mt.isArrayBufferView(e)?e.buffer:Mt.isURLSearchParams(e)?(ln(t,"application/x-www-form-urlencoded;charset=utf-8"),e.toString()):Mt.isObject(e)?(ln(t,"application/json;charset=utf-8"),JSON.stringify(e)):e}],transformResponse:[function(e){if("string"==typeof e)try{e=JSON.parse(e)}catch(t){}return e}],timeout:0,xsrfCookieName:"XSRF-TOKEN",xsrfHeaderName:"X-XSRF-TOKEN",maxContentLength:-1,validateStatus:function(e){return e>=200&&e<300}};hn.headers={common:{Accept:"application/json, text/plain, */*"}},Mt.forEach(["delete","get","head"],function(e){hn.headers[e]={}}),Mt.forEach(["post","put","patch"],function(e){hn.headers[e]=Mt.merge(cn)});var fn=hn;function _n(e){e.cancelToken&&e.cancelToken.throwIfRequested()}var gn=function(e){var t,n,r;return _n(e),e.baseURL&&(r=e.url,!/^([a-z][a-z\d\+\-\.]*:)?\/\//i.test(r))&&(e.url=(t=e.baseURL,(n=e.url)?t.replace(/\/+$/,"")+"/"+n.replace(/^\/+/,""):t)),e.headers=e.headers||{},e.data=Lt(e.data,e.headers,e.transformRequest),e.headers=Mt.merge(e.headers.common||{},e.headers[e.method]||{},e.headers||{}),Mt.forEach(["delete","get","head","post","put","patch","common"],function(t){delete e.headers[t]}),(e.adapter||fn.adapter)(e).then(function(t){return _n(e),t.data=Lt(t.data,t.headers,e.transformResponse),t},function(t){return Rt(t)||(_n(e),t&&t.response&&(t.response.data=Lt(t.response.data,t.response.headers,e.transformResponse))),Promise.reject(t)})},dn=function(e,t){t=t||{};var n={};return Mt.forEach(["url","method","params","data"],function(e){void 0!==t[e]&&(n[e]=t[e])}),Mt.forEach(["headers","auth","proxy"],function(r){Mt.isObject(t[r])?n[r]=Mt.deepMerge(e[r],t[r]):void 0!==t[r]?n[r]=t[r]:Mt.isObject(e[r])?n[r]=Mt.deepMerge(e[r]):void 0!==e[r]&&(n[r]=e[r])}),Mt.forEach(["baseURL","transformRequest","transformResponse","paramsSerializer","timeout","withCredentials","adapter","responseType","xsrfCookieName","xsrfHeaderName","onUploadProgress","onDownloadProgress","maxContentLength","validateStatus","maxRedirects","httpAgent","httpsAgent","cancelToken","socketPath"],function(r){void 0!==t[r]?n[r]=t[r]:void 0!==e[r]&&(n[r]=e[r])}),n};function mn(e){this.defaults=e,this.interceptors={request:new Nt,response:new Nt}}mn.prototype.request=function(e){"string"==typeof e?(e=arguments[1]||{}).url=arguments[0]:e=e||{},(e=dn(this.defaults,e)).method=e.method?e.method.toLowerCase():"get";var t=[gn,void 0],n=Promise.resolve(e);for(this.interceptors.request.forEach(function(e){t.unshift(e.fulfilled,e.rejected)}),this.interceptors.response.forEach(function(e){t.push(e.fulfilled,e.rejected)});t.length;)n=n.then(t.shift(),t.shift());return n},mn.prototype.getUri=function(e){return e=dn(this.defaults,e),Ot(e.url,e.params,e.paramsSerializer).replace(/^\?/,"")},Mt.forEach(["delete","get","head","options"],function(e){mn.prototype[e]=function(t,n){return this.request(Mt.merge(n||{},{method:e,url:t}))}}),Mt.forEach(["post","put","patch"],function(e){mn.prototype[e]=function(t,n,r){return this.request(Mt.merge(r||{},{method:e,url:t,data:n}))}});var En=mn;function yn(e){this.message=e}yn.prototype.toString=function(){return"Cancel"+(this.message?": "+this.message:"")},yn.prototype.__CANCEL__=1;var vn=yn;function In(e){if("function"!=typeof e)throw new TypeError("executor must be a function.");var t;this.promise=new Promise(function(e){t=e});var n=this;e(function(e){n.reason||(n.reason=new vn(e),t(n.reason))})}In.prototype.throwIfRequested=function(){if(this.reason)throw this.reason},In.source=function(){var e;return{token:new In(function(t){e=t}),cancel:e}};var Sn=In;function Cn(e){var t=new En(e),n=yt(En.prototype.request,t);return Mt.extend(n,En.prototype,t),Mt.extend(n,t),n}var Tn=Cn(fn);Tn.Axios=En,Tn.create=function(e){return Cn(dn(Tn.defaults,e))},Tn.Cancel=vn,Tn.CancelToken=Sn,Tn.isCancel=Rt,Tn.all=function(e){return Promise.all(e)},Tn.spread=function(e){return function(t){return e.apply(null,t)}};var Mn=Tn,Dn=Tn;Mn.default=Dn;var On=Mn,An=On.create({timeout:6e3,headers:{"Content-Type":"application/x-www-form-urlencoded;charset=UTF-8"}});An.interceptors.response.use(function(e){var t=e.data,n=t.error_code,r=t.ErrorCode;return Z(n)&&(r=n),r!==He.REQUEST.SUCCESS&&(e.data.ErrorCode=Number(r)),e},function(e){return"Network Error"===e.message&&(1==An.defaults.withCredentials&&Q.warn("Network Error, try to close `IMAxios.defaults.withCredentials` to false. (IMAxios.js)"),An.defaults.withCredentials=0),Promise.reject(e)});var Nn=function(){function e(){r(this,e)}return i(e,[{key:"request",value:function(e){console.warn("请注意： ConnectionBase.request() 方法必须被派生类重写:"),console.log("参数如下：\n    * @param {String} options.url string 是 开发者服务器接口地址\n    * @param {*} options.data - string/object/ArrayBuffer 否 请求的参数\n    * @param {Object} options.header - Object 否 设置请求的 header，\n    * @param {String} options.method - string GET 否 HTTP 请求方法\n    * @param {String} options.dataType - string json 否 返回的数据格式\n    * @param {String} options.responseType - string text 否 响应的数据类型\n    * @param {Boolean} isRetry - string text false 是否为重试的请求\n   ")}},{key:"_checkOptions",value:function(e){if(0==!!e.url)throw new Ce({code:Ie.NETWORK_BASE_OPTIONS_NO_URL,message:Se.NETWORK_BASE_OPTIONS_NO_URL})}},{key:"_initOptions",value:function(e){e.method=["POST","GET","PUT","DELETE","OPTION"].indexOf(e.method)>=0?e.method:"POST",e.dataType=e.dataType||"json",e.responseType=e.responseType||"json"}}]),e}(),Ln=function(e){function t(){var e;return r(this,t),(e=g(this,l(t).call(this))).retry=1,e}return c(t,Nn),i(t,[{key:"request",value:function(e){return this._checkOptions(e),this._initOptions(e),this._requestWithRetry({url:e.url,data:e.data,method:e.method})}},{key:"_requestWithRetry",value:function(e){var t=this,n=arguments.length>1&&void 0!==arguments[1]?arguments[1]:0;return An(e).catch(function(r){return t.retry&&n<t.retry?t._requestWithRetry(e,++n):ht(r)})}}]),t}(),Rn=[],Pn=[],Gn="undefined"!=typeof Uint8Array?Uint8Array:Array,kn=0;function wn(){kn=1;for(var e="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/",t=0,n=e.length;t<n;++t)Rn[t]=e[t],Pn[e.charCodeAt(t)]=t;Pn["-".charCodeAt(0)]=62,Pn["_".charCodeAt(0)]=63}function bn(e,t,n){for(var r,o,i=[],a=t;a<n;a+=3)r=(e[a]<<16)+(e[a+1]<<8)+e[a+2],i.push(Rn[(o=r)>>18&63]+Rn[o>>12&63]+Rn[o>>6&63]+Rn[63&o]);return i.join("")}function Un(e){var t;kn||wn();for(var n=e.length,r=n%3,o="",i=[],a=0,s=n-r;a<s;a+=16383)i.push(bn(e,a,a+16383>s?s:a+16383));return 1===r?(t=e[n-1],o+=Rn[t>>2],o+=Rn[t<<4&63],o+="=="):2===r&&(t=(e[n-2]<<8)+e[n-1],o+=Rn[t>>10],o+=Rn[t>>4&63],o+=Rn[t<<2&63],o+="="),i.push(o),i.join("")}function Fn(e,t,n,r,o){var i,a,s=8*o-r-1,u=(1<<s)-1,c=u>>1,l=-7,p=n?o-1:0,h=n?-1:1,f=e[t+p];for(p+=h,i=f&(1<<-l)-1,f>>=-l,l+=s;l>0;i=256*i+e[t+p],p+=h,l-=8);for(a=i&(1<<-l)-1,i>>=-l,l+=r;l>0;a=256*a+e[t+p],p+=h,l-=8);if(0===i)i=1-c;else{if(i===u)return a?NaN:Infinity*(f?-1:1);a+=Math.pow(2,r),i-=c}return(f?-1:1)*a*Math.pow(2,i-r)}function qn(e,t,n,r,o,i){var a,s,u,c=8*i-o-1,l=(1<<c)-1,p=l>>1,h=23===o?Math.pow(2,-24)-Math.pow(2,-77):0,f=r?0:i-1,_=r?1:-1,g=t<0||0===t&&1/t<0?1:0;for(t=Math.abs(t),isNaN(t)||Infinity===t?(s=isNaN(t)?1:0,a=l):(a=Math.floor(Math.log(t)/Math.LN2),t*(u=Math.pow(2,-a))<1&&(a--,u*=2),(t+=a+p>=1?h/u:h*Math.pow(2,1-p))*u>=2&&(a++,u/=2),a+p>=l?(s=0,a=l):a+p>=1?(s=(t*u-1)*Math.pow(2,o),a+=p):(s=t*Math.pow(2,p-1)*Math.pow(2,o),a=0));o>=8;e[n+f]=255&s,f+=_,s/=256,o-=8);for(a=a<<o|s,c+=o;c>0;e[n+f]=255&a,f+=_,a/=256,c-=8);e[n+f-_]|=128*g}var xn={}.toString,Hn=Array.isArray||function(e){return"[object Array]"==xn.call(e)};function Kn(){return Vn.TYPED_ARRAY_SUPPORT?2147483647:1073741823}function Bn(e,t){if(Kn()<t)throw new RangeError("Invalid typed array length");return Vn.TYPED_ARRAY_SUPPORT?(e=new Uint8Array(t)).__proto__=Vn.prototype:(null===e&&(e=new Vn(t)),e.length=t),e}function Vn(e,t,n){if(!(Vn.TYPED_ARRAY_SUPPORT||this instanceof Vn))return new Vn(e,t,n);if("number"==typeof e){if("string"==typeof t)throw new Error("If encoding is specified then the first argument must be a string");return zn(this,e)}return Yn(this,e,t,n)}function Yn(e,t,n,r){if("number"==typeof t)throw new TypeError('"value" argument must not be a number');return"undefined"!=typeof ArrayBuffer&&t instanceof ArrayBuffer?function(e,t,n,r){if(t.byteLength,n<0||t.byteLength<n)throw new RangeError("'offset' is out of bounds");if(t.byteLength<n+(r||0))throw new RangeError("'length' is out of bounds");t=void 0===n&&void 0===r?new Uint8Array(t):void 0===r?new Uint8Array(t,n):new Uint8Array(t,n,r);Vn.TYPED_ARRAY_SUPPORT?(e=t).__proto__=Vn.prototype:e=Wn(e,t);return e}(e,t,n,r):"string"==typeof t?function(e,t,n){"string"==typeof n&&""!==n||(n="utf8");if(!Vn.isEncoding(n))throw new TypeError('"encoding" must be a valid string encoding');var r=0|Qn(t,n),o=(e=Bn(e,r)).write(t,n);o!==r&&(e=e.slice(0,o));return e}(e,t,n):function(e,t){if(Jn(t)){var n=0|Xn(t.length);return 0===(e=Bn(e,n)).length?e:(t.copy(e,0,0,n),e)}if(t){if("undefined"!=typeof ArrayBuffer&&t.buffer instanceof ArrayBuffer||"length"in t)return"number"!=typeof t.length||(r=t.length)!=r?Bn(e,0):Wn(e,t);if("Buffer"===t.type&&Hn(t.data))return Wn(e,t.data)}var r;throw new TypeError("First argument must be a string, Buffer, ArrayBuffer, Array, or array-like object.")}(e,t)}function jn(e){if("number"!=typeof e)throw new TypeError('"size" argument must be a number');if(e<0)throw new RangeError('"size" argument must not be negative')}function zn(e,t){if(jn(t),e=Bn(e,t<0?0:0|Xn(t)),!Vn.TYPED_ARRAY_SUPPORT)for(var n=0;n<t;++n)e[n]=0;return e}function Wn(e,t){var n=t.length<0?0:0|Xn(t.length);e=Bn(e,n);for(var r=0;r<n;r+=1)e[r]=255&t[r];return e}function Xn(e){if(e>=Kn())throw new RangeError("Attempt to allocate Buffer larger than maximum size: 0x"+Kn().toString(16)+" bytes");return 0|e}function Jn(e){return!(null==e||!e._isBuffer)}function Qn(e,t){if(Jn(e))return e.length;if("undefined"!=typeof ArrayBuffer&&"function"==typeof ArrayBuffer.isView&&(ArrayBuffer.isView(e)||e instanceof ArrayBuffer))return e.byteLength;"string"!=typeof e&&(e=""+e);var n=e.length;if(0===n)return 0;for(var r=0;;)switch(t){case"ascii":case"latin1":case"binary":return n;case"utf8":case"utf-8":case void 0:return Tr(e).length;case"ucs2":case"ucs-2":case"utf16le":case"utf-16le":return 2*n;case"hex":return n>>>1;case"base64":return Mr(e).length;default:if(r)return Tr(e).length;t=(""+t).toLowerCase(),r=1}}function Zn(e,t,n){var r=0;if((void 0===t||t<0)&&(t=0),t>this.length)return"";if((void 0===n||n>this.length)&&(n=this.length),n<=0)return"";if((n>>>=0)<=(t>>>=0))return"";for(e||(e="utf8");;)switch(e){case"hex":return fr(this,t,n);case"utf8":case"utf-8":return cr(this,t,n);case"ascii":return pr(this,t,n);case"latin1":case"binary":return hr(this,t,n);case"base64":return ur(this,t,n);case"ucs2":case"ucs-2":case"utf16le":case"utf-16le":return _r(this,t,n);default:if(r)throw new TypeError("Unknown encoding: "+e);e=(e+"").toLowerCase(),r=1}}function $n(e,t,n){var r=e[t];e[t]=e[n],e[n]=r}function er(e,t,n,r,o){if(0===e.length)return-1;if("string"==typeof n?(r=n,n=0):n>2147483647?n=2147483647:n<-2147483648&&(n=-2147483648),n=+n,isNaN(n)&&(n=o?0:e.length-1),n<0&&(n=e.length+n),n>=e.length){if(o)return-1;n=e.length-1}else if(n<0){if(!o)return-1;n=0}if("string"==typeof t&&(t=Vn.from(t,r)),Jn(t))return 0===t.length?-1:tr(e,t,n,r,o);if("number"==typeof t)return t&=255,Vn.TYPED_ARRAY_SUPPORT&&"function"==typeof Uint8Array.prototype.indexOf?o?Uint8Array.prototype.indexOf.call(e,t,n):Uint8Array.prototype.lastIndexOf.call(e,t,n):tr(e,[t],n,r,o);throw new TypeError("val must be string, number or Buffer")}function tr(e,t,n,r,o){var i,a=1,s=e.length,u=t.length;if(void 0!==r&&("ucs2"===(r=String(r).toLowerCase())||"ucs-2"===r||"utf16le"===r||"utf-16le"===r)){if(e.length<2||t.length<2)return-1;a=2,s/=2,u/=2,n/=2}function c(e,t){return 1===a?e[t]:e.readUInt16BE(t*a)}if(o){var l=-1;for(i=n;i<s;i++)if(c(e,i)===c(t,-1===l?0:i-l)){if(-1===l&&(l=i),i-l+1===u)return l*a}else-1!==l&&(i-=i-l),l=-1}else for(n+u>s&&(n=s-u),i=n;i>=0;i--){for(var p=1,h=0;h<u;h++)if(c(e,i+h)!==c(t,h)){p=0;break}if(p)return i}return-1}function nr(e,t,n,r){n=Number(n)||0;var o=e.length-n;r?(r=Number(r))>o&&(r=o):r=o;var i=t.length;if(i%2!=0)throw new TypeError("Invalid hex string");r>i/2&&(r=i/2);for(var a=0;a<r;++a){var s=parseInt(t.substr(2*a,2),16);if(isNaN(s))return a;e[n+a]=s}return a}function rr(e,t,n,r){return Dr(Tr(t,e.length-n),e,n,r)}function or(e,t,n,r){return Dr(function(e){for(var t=[],n=0;n<e.length;++n)t.push(255&e.charCodeAt(n));return t}(t),e,n,r)}function ir(e,t,n,r){return or(e,t,n,r)}function ar(e,t,n,r){return Dr(Mr(t),e,n,r)}function sr(e,t,n,r){return Dr(function(e,t){for(var n,r,o,i=[],a=0;a<e.length&&!((t-=2)<0);++a)n=e.charCodeAt(a),r=n>>8,o=n%256,i.push(o),i.push(r);return i}(t,e.length-n),e,n,r)}function ur(e,t,n){return 0===t&&n===e.length?Un(e):Un(e.slice(t,n))}function cr(e,t,n){n=Math.min(e.length,n);for(var r=[],o=t;o<n;){var i,a,s,u,c=e[o],l=null,p=c>239?4:c>223?3:c>191?2:1;if(o+p<=n)switch(p){case 1:c<128&&(l=c);break;case 2:128==(192&(i=e[o+1]))&&(u=(31&c)<<6|63&i)>127&&(l=u);break;case 3:i=e[o+1],a=e[o+2],128==(192&i)&&128==(192&a)&&(u=(15&c)<<12|(63&i)<<6|63&a)>2047&&(u<55296||u>57343)&&(l=u);break;case 4:i=e[o+1],a=e[o+2],s=e[o+3],128==(192&i)&&128==(192&a)&&128==(192&s)&&(u=(15&c)<<18|(63&i)<<12|(63&a)<<6|63&s)>65535&&u<1114112&&(l=u)}null===l?(l=65533,p=1):l>65535&&(l-=65536,r.push(l>>>10&1023|55296),l=56320|1023&l),r.push(l),o+=p}return function(e){var t=e.length;if(t<=lr)return String.fromCharCode.apply(String,e);var n="",r=0;for(;r<t;)n+=String.fromCharCode.apply(String,e.slice(r,r+=lr));return n}(r)}Vn.TYPED_ARRAY_SUPPORT=void 0!==O.TYPED_ARRAY_SUPPORT?O.TYPED_ARRAY_SUPPORT:1,Vn.poolSize=8192,Vn._augment=function(e){return e.__proto__=Vn.prototype,e},Vn.from=function(e,t,n){return Yn(null,e,t,n)},Vn.TYPED_ARRAY_SUPPORT&&(Vn.prototype.__proto__=Uint8Array.prototype,Vn.__proto__=Uint8Array),Vn.alloc=function(e,t,n){return function(e,t,n,r){return jn(t),t<=0?Bn(e,t):void 0!==n?"string"==typeof r?Bn(e,t).fill(n,r):Bn(e,t).fill(n):Bn(e,t)}(null,e,t,n)},Vn.allocUnsafe=function(e){return zn(null,e)},Vn.allocUnsafeSlow=function(e){return zn(null,e)},Vn.isBuffer=function(e){return null!=e&&(!!e._isBuffer||Or(e)||function(e){return"function"==typeof e.readFloatLE&&"function"==typeof e.slice&&Or(e.slice(0,0))}(e))},Vn.compare=function(e,t){if(!Jn(e)||!Jn(t))throw new TypeError("Arguments must be Buffers");if(e===t)return 0;for(var n=e.length,r=t.length,o=0,i=Math.min(n,r);o<i;++o)if(e[o]!==t[o]){n=e[o],r=t[o];break}return n<r?-1:r<n?1:0},Vn.isEncoding=function(e){switch(String(e).toLowerCase()){case"hex":case"utf8":case"utf-8":case"ascii":case"latin1":case"binary":case"base64":case"ucs2":case"ucs-2":case"utf16le":case"utf-16le":return 1;default:return 0}},Vn.concat=function(e,t){if(!Hn(e))throw new TypeError('"list" argument must be an Array of Buffers');if(0===e.length)return Vn.alloc(0);var n;if(void 0===t)for(t=0,n=0;n<e.length;++n)t+=e[n].length;var r=Vn.allocUnsafe(t),o=0;for(n=0;n<e.length;++n){var i=e[n];if(!Jn(i))throw new TypeError('"list" argument must be an Array of Buffers');i.copy(r,o),o+=i.length}return r},Vn.byteLength=Qn,Vn.prototype._isBuffer=1,Vn.prototype.swap16=function(){var e=this.length;if(e%2!=0)throw new RangeError("Buffer size must be a multiple of 16-bits");for(var t=0;t<e;t+=2)$n(this,t,t+1);return this},Vn.prototype.swap32=function(){var e=this.length;if(e%4!=0)throw new RangeError("Buffer size must be a multiple of 32-bits");for(var t=0;t<e;t+=4)$n(this,t,t+3),$n(this,t+1,t+2);return this},Vn.prototype.swap64=function(){var e=this.length;if(e%8!=0)throw new RangeError("Buffer size must be a multiple of 64-bits");for(var t=0;t<e;t+=8)$n(this,t,t+7),$n(this,t+1,t+6),$n(this,t+2,t+5),$n(this,t+3,t+4);return this},Vn.prototype.toString=function(){var e=0|this.length;return 0===e?"":0===arguments.length?cr(this,0,e):Zn.apply(this,arguments)},Vn.prototype.equals=function(e){if(!Jn(e))throw new TypeError("Argument must be a Buffer");return this===e?1:0===Vn.compare(this,e)},Vn.prototype.inspect=function(){var e="";return this.length>0&&(e=this.toString("hex",0,50).match(/.{2}/g).join(" "),this.length>50&&(e+=" ... ")),"<Buffer "+e+">"},Vn.prototype.compare=function(e,t,n,r,o){if(!Jn(e))throw new TypeError("Argument must be a Buffer");if(void 0===t&&(t=0),void 0===n&&(n=e?e.length:0),void 0===r&&(r=0),void 0===o&&(o=this.length),t<0||n>e.length||r<0||o>this.length)throw new RangeError("out of range index");if(r>=o&&t>=n)return 0;if(r>=o)return-1;if(t>=n)return 1;if(this===e)return 0;for(var i=(o>>>=0)-(r>>>=0),a=(n>>>=0)-(t>>>=0),s=Math.min(i,a),u=this.slice(r,o),c=e.slice(t,n),l=0;l<s;++l)if(u[l]!==c[l]){i=u[l],a=c[l];break}return i<a?-1:a<i?1:0},Vn.prototype.includes=function(e,t,n){return-1!==this.indexOf(e,t,n)},Vn.prototype.indexOf=function(e,t,n){return er(this,e,t,n,1)},Vn.prototype.lastIndexOf=function(e,t,n){return er(this,e,t,n,0)},Vn.prototype.write=function(e,t,n,r){if(void 0===t)r="utf8",n=this.length,t=0;else if(void 0===n&&"string"==typeof t)r=t,n=this.length,t=0;else{if(!isFinite(t))throw new Error("Buffer.write(string, encoding, offset[, length]) is no longer supported");t|=0,isFinite(n)?(n|=0,void 0===r&&(r="utf8")):(r=n,n=void 0)}var o=this.length-t;if((void 0===n||n>o)&&(n=o),e.length>0&&(n<0||t<0)||t>this.length)throw new RangeError("Attempt to write outside buffer bounds");r||(r="utf8");for(var i=0;;)switch(r){case"hex":return nr(this,e,t,n);case"utf8":case"utf-8":return rr(this,e,t,n);case"ascii":return or(this,e,t,n);case"latin1":case"binary":return ir(this,e,t,n);case"base64":return ar(this,e,t,n);case"ucs2":case"ucs-2":case"utf16le":case"utf-16le":return sr(this,e,t,n);default:if(i)throw new TypeError("Unknown encoding: "+r);r=(""+r).toLowerCase(),i=1}},Vn.prototype.toJSON=function(){return{type:"Buffer",data:Array.prototype.slice.call(this._arr||this,0)}};var lr=4096;function pr(e,t,n){var r="";n=Math.min(e.length,n);for(var o=t;o<n;++o)r+=String.fromCharCode(127&e[o]);return r}function hr(e,t,n){var r="";n=Math.min(e.length,n);for(var o=t;o<n;++o)r+=String.fromCharCode(e[o]);return r}function fr(e,t,n){var r=e.length;(!t||t<0)&&(t=0),(!n||n<0||n>r)&&(n=r);for(var o="",i=t;i<n;++i)o+=Cr(e[i]);return o}function _r(e,t,n){for(var r=e.slice(t,n),o="",i=0;i<r.length;i+=2)o+=String.fromCharCode(r[i]+256*r[i+1]);return o}function gr(e,t,n){if(e%1!=0||e<0)throw new RangeError("offset is not uint");if(e+t>n)throw new RangeError("Trying to access beyond buffer length")}function dr(e,t,n,r,o,i){if(!Jn(e))throw new TypeError('"buffer" argument must be a Buffer instance');if(t>o||t<i)throw new RangeError('"value" argument is out of bounds');if(n+r>e.length)throw new RangeError("Index out of range")}function mr(e,t,n,r){t<0&&(t=65535+t+1);for(var o=0,i=Math.min(e.length-n,2);o<i;++o)e[n+o]=(t&255<<8*(r?o:1-o))>>>8*(r?o:1-o)}function Er(e,t,n,r){t<0&&(t=4294967295+t+1);for(var o=0,i=Math.min(e.length-n,4);o<i;++o)e[n+o]=t>>>8*(r?o:3-o)&255}function yr(e,t,n,r,o,i){if(n+r>e.length)throw new RangeError("Index out of range");if(n<0)throw new RangeError("Index out of range")}function vr(e,t,n,r,o){return o||yr(e,0,n,4),qn(e,t,n,r,23,4),n+4}function Ir(e,t,n,r,o){return o||yr(e,0,n,8),qn(e,t,n,r,52,8),n+8}Vn.prototype.slice=function(e,t){var n,r=this.length;if((e=~~e)<0?(e+=r)<0&&(e=0):e>r&&(e=r),(t=void 0===t?r:~~t)<0?(t+=r)<0&&(t=0):t>r&&(t=r),t<e&&(t=e),Vn.TYPED_ARRAY_SUPPORT)(n=this.subarray(e,t)).__proto__=Vn.prototype;else{var o=t-e;n=new Vn(o,void 0);for(var i=0;i<o;++i)n[i]=this[i+e]}return n},Vn.prototype.readUIntLE=function(e,t,n){e|=0,t|=0,n||gr(e,t,this.length);for(var r=this[e],o=1,i=0;++i<t&&(o*=256);)r+=this[e+i]*o;return r},Vn.prototype.readUIntBE=function(e,t,n){e|=0,t|=0,n||gr(e,t,this.length);for(var r=this[e+--t],o=1;t>0&&(o*=256);)r+=this[e+--t]*o;return r},Vn.prototype.readUInt8=function(e,t){return t||gr(e,1,this.length),this[e]},Vn.prototype.readUInt16LE=function(e,t){return t||gr(e,2,this.length),this[e]|this[e+1]<<8},Vn.prototype.readUInt16BE=function(e,t){return t||gr(e,2,this.length),this[e]<<8|this[e+1]},Vn.prototype.readUInt32LE=function(e,t){return t||gr(e,4,this.length),(this[e]|this[e+1]<<8|this[e+2]<<16)+16777216*this[e+3]},Vn.prototype.readUInt32BE=function(e,t){return t||gr(e,4,this.length),16777216*this[e]+(this[e+1]<<16|this[e+2]<<8|this[e+3])},Vn.prototype.readIntLE=function(e,t,n){e|=0,t|=0,n||gr(e,t,this.length);for(var r=this[e],o=1,i=0;++i<t&&(o*=256);)r+=this[e+i]*o;return r>=(o*=128)&&(r-=Math.pow(2,8*t)),r},Vn.prototype.readIntBE=function(e,t,n){e|=0,t|=0,n||gr(e,t,this.length);for(var r=t,o=1,i=this[e+--r];r>0&&(o*=256);)i+=this[e+--r]*o;return i>=(o*=128)&&(i-=Math.pow(2,8*t)),i},Vn.prototype.readInt8=function(e,t){return t||gr(e,1,this.length),128&this[e]?-1*(255-this[e]+1):this[e]},Vn.prototype.readInt16LE=function(e,t){t||gr(e,2,this.length);var n=this[e]|this[e+1]<<8;return 32768&n?4294901760|n:n},Vn.prototype.readInt16BE=function(e,t){t||gr(e,2,this.length);var n=this[e+1]|this[e]<<8;return 32768&n?4294901760|n:n},Vn.prototype.readInt32LE=function(e,t){return t||gr(e,4,this.length),this[e]|this[e+1]<<8|this[e+2]<<16|this[e+3]<<24},Vn.prototype.readInt32BE=function(e,t){return t||gr(e,4,this.length),this[e]<<24|this[e+1]<<16|this[e+2]<<8|this[e+3]},Vn.prototype.readFloatLE=function(e,t){return t||gr(e,4,this.length),Fn(this,e,1,23,4)},Vn.prototype.readFloatBE=function(e,t){return t||gr(e,4,this.length),Fn(this,e,0,23,4)},Vn.prototype.readDoubleLE=function(e,t){return t||gr(e,8,this.length),Fn(this,e,1,52,8)},Vn.prototype.readDoubleBE=function(e,t){return t||gr(e,8,this.length),Fn(this,e,0,52,8)},Vn.prototype.writeUIntLE=function(e,t,n,r){(e=+e,t|=0,n|=0,r)||dr(this,e,t,n,Math.pow(2,8*n)-1,0);var o=1,i=0;for(this[t]=255&e;++i<n&&(o*=256);)this[t+i]=e/o&255;return t+n},Vn.prototype.writeUIntBE=function(e,t,n,r){(e=+e,t|=0,n|=0,r)||dr(this,e,t,n,Math.pow(2,8*n)-1,0);var o=n-1,i=1;for(this[t+o]=255&e;--o>=0&&(i*=256);)this[t+o]=e/i&255;return t+n},Vn.prototype.writeUInt8=function(e,t,n){return e=+e,t|=0,n||dr(this,e,t,1,255,0),Vn.TYPED_ARRAY_SUPPORT||(e=Math.floor(e)),this[t]=255&e,t+1},Vn.prototype.writeUInt16LE=function(e,t,n){return e=+e,t|=0,n||dr(this,e,t,2,65535,0),Vn.TYPED_ARRAY_SUPPORT?(this[t]=255&e,this[t+1]=e>>>8):mr(this,e,t,1),t+2},Vn.prototype.writeUInt16BE=function(e,t,n){return e=+e,t|=0,n||dr(this,e,t,2,65535,0),Vn.TYPED_ARRAY_SUPPORT?(this[t]=e>>>8,this[t+1]=255&e):mr(this,e,t,0),t+2},Vn.prototype.writeUInt32LE=function(e,t,n){return e=+e,t|=0,n||dr(this,e,t,4,4294967295,0),Vn.TYPED_ARRAY_SUPPORT?(this[t+3]=e>>>24,this[t+2]=e>>>16,this[t+1]=e>>>8,this[t]=255&e):Er(this,e,t,1),t+4},Vn.prototype.writeUInt32BE=function(e,t,n){return e=+e,t|=0,n||dr(this,e,t,4,4294967295,0),Vn.TYPED_ARRAY_SUPPORT?(this[t]=e>>>24,this[t+1]=e>>>16,this[t+2]=e>>>8,this[t+3]=255&e):Er(this,e,t,0),t+4},Vn.prototype.writeIntLE=function(e,t,n,r){if(e=+e,t|=0,!r){var o=Math.pow(2,8*n-1);dr(this,e,t,n,o-1,-o)}var i=0,a=1,s=0;for(this[t]=255&e;++i<n&&(a*=256);)e<0&&0===s&&0!==this[t+i-1]&&(s=1),this[t+i]=(e/a>>0)-s&255;return t+n},Vn.prototype.writeIntBE=function(e,t,n,r){if(e=+e,t|=0,!r){var o=Math.pow(2,8*n-1);dr(this,e,t,n,o-1,-o)}var i=n-1,a=1,s=0;for(this[t+i]=255&e;--i>=0&&(a*=256);)e<0&&0===s&&0!==this[t+i+1]&&(s=1),this[t+i]=(e/a>>0)-s&255;return t+n},Vn.prototype.writeInt8=function(e,t,n){return e=+e,t|=0,n||dr(this,e,t,1,127,-128),Vn.TYPED_ARRAY_SUPPORT||(e=Math.floor(e)),e<0&&(e=255+e+1),this[t]=255&e,t+1},Vn.prototype.writeInt16LE=function(e,t,n){return e=+e,t|=0,n||dr(this,e,t,2,32767,-32768),Vn.TYPED_ARRAY_SUPPORT?(this[t]=255&e,this[t+1]=e>>>8):mr(this,e,t,1),t+2},Vn.prototype.writeInt16BE=function(e,t,n){return e=+e,t|=0,n||dr(this,e,t,2,32767,-32768),Vn.TYPED_ARRAY_SUPPORT?(this[t]=e>>>8,this[t+1]=255&e):mr(this,e,t,0),t+2},Vn.prototype.writeInt32LE=function(e,t,n){return e=+e,t|=0,n||dr(this,e,t,4,2147483647,-2147483648),Vn.TYPED_ARRAY_SUPPORT?(this[t]=255&e,this[t+1]=e>>>8,this[t+2]=e>>>16,this[t+3]=e>>>24):Er(this,e,t,1),t+4},Vn.prototype.writeInt32BE=function(e,t,n){return e=+e,t|=0,n||dr(this,e,t,4,2147483647,-2147483648),e<0&&(e=4294967295+e+1),Vn.TYPED_ARRAY_SUPPORT?(this[t]=e>>>24,this[t+1]=e>>>16,this[t+2]=e>>>8,this[t+3]=255&e):Er(this,e,t,0),t+4},Vn.prototype.writeFloatLE=function(e,t,n){return vr(this,e,t,1,n)},Vn.prototype.writeFloatBE=function(e,t,n){return vr(this,e,t,0,n)},Vn.prototype.writeDoubleLE=function(e,t,n){return Ir(this,e,t,1,n)},Vn.prototype.writeDoubleBE=function(e,t,n){return Ir(this,e,t,0,n)},Vn.prototype.copy=function(e,t,n,r){if(n||(n=0),r||0===r||(r=this.length),t>=e.length&&(t=e.length),t||(t=0),r>0&&r<n&&(r=n),r===n)return 0;if(0===e.length||0===this.length)return 0;if(t<0)throw new RangeError("targetStart out of bounds");if(n<0||n>=this.length)throw new RangeError("sourceStart out of bounds");if(r<0)throw new RangeError("sourceEnd out of bounds");r>this.length&&(r=this.length),e.length-t<r-n&&(r=e.length-t+n);var o,i=r-n;if(this===e&&n<t&&t<r)for(o=i-1;o>=0;--o)e[o+t]=this[o+n];else if(i<1e3||!Vn.TYPED_ARRAY_SUPPORT)for(o=0;o<i;++o)e[o+t]=this[o+n];else Uint8Array.prototype.set.call(e,this.subarray(n,n+i),t);return i},Vn.prototype.fill=function(e,t,n,r){if("string"==typeof e){if("string"==typeof t?(r=t,t=0,n=this.length):"string"==typeof n&&(r=n,n=this.length),1===e.length){var o=e.charCodeAt(0);o<256&&(e=o)}if(void 0!==r&&"string"!=typeof r)throw new TypeError("encoding must be a string");if("string"==typeof r&&!Vn.isEncoding(r))throw new TypeError("Unknown encoding: "+r)}else"number"==typeof e&&(e&=255);if(t<0||this.length<t||this.length<n)throw new RangeError("Out of range index");if(n<=t)return this;var i;if(t>>>=0,n=void 0===n?this.length:n>>>0,e||(e=0),"number"==typeof e)for(i=t;i<n;++i)this[i]=e;else{var a=Jn(e)?e:Tr(new Vn(e,r).toString()),s=a.length;for(i=0;i<n-t;++i)this[i+t]=a[i%s]}return this};var Sr=/[^+\/0-9A-Za-z-_]/g;function Cr(e){return e<16?"0"+e.toString(16):e.toString(16)}function Tr(e,t){var n;t=t||Infinity;for(var r=e.length,o=null,i=[],a=0;a<r;++a){if((n=e.charCodeAt(a))>55295&&n<57344){if(!o){if(n>56319){(t-=3)>-1&&i.push(239,191,189);continue}if(a+1===r){(t-=3)>-1&&i.push(239,191,189);continue}o=n;continue}if(n<56320){(t-=3)>-1&&i.push(239,191,189),o=n;continue}n=65536+(o-55296<<10|n-56320)}else o&&(t-=3)>-1&&i.push(239,191,189);if(o=null,n<128){if((t-=1)<0)break;i.push(n)}else if(n<2048){if((t-=2)<0)break;i.push(n>>6|192,63&n|128)}else if(n<65536){if((t-=3)<0)break;i.push(n>>12|224,n>>6&63|128,63&n|128)}else{if(!(n<1114112))throw new Error("Invalid code point");if((t-=4)<0)break;i.push(n>>18|240,n>>12&63|128,n>>6&63|128,63&n|128)}}return i}function Mr(e){return function(e){var t,n,r,o,i,a;kn||wn();var s=e.length;if(s%4>0)throw new Error("Invalid string. Length must be a multiple of 4");i="="===e[s-2]?2:"="===e[s-1]?1:0,a=new Gn(3*s/4-i),r=i>0?s-4:s;var u=0;for(t=0,n=0;t<r;t+=4,n+=3)o=Pn[e.charCodeAt(t)]<<18|Pn[e.charCodeAt(t+1)]<<12|Pn[e.charCodeAt(t+2)]<<6|Pn[e.charCodeAt(t+3)],a[u++]=o>>16&255,a[u++]=o>>8&255,a[u++]=255&o;return 2===i?(o=Pn[e.charCodeAt(t)]<<2|Pn[e.charCodeAt(t+1)]>>4,a[u++]=255&o):1===i&&(o=Pn[e.charCodeAt(t)]<<10|Pn[e.charCodeAt(t+1)]<<4|Pn[e.charCodeAt(t+2)]>>2,a[u++]=o>>8&255,a[u++]=255&o),a}(function(e){if((e=function(e){return e.trim?e.trim():e.replace(/^\s+|\s+$/g,"")}(e).replace(Sr,"")).length<2)return"";for(;e.length%4!=0;)e+="=";return e}(e))}function Dr(e,t,n,r){for(var o=0;o<r&&!(o+n>=t.length||o>=e.length);++o)t[o+n]=e[o];return o}function Or(e){return!!e.constructor&&"function"==typeof e.constructor.isBuffer&&e.constructor.isBuffer(e)}var Ar=function(e){function t(){var e;return r(this,t),(e=g(this,l(t).call(this)))._request=e.promisify(wx.request),e}return c(t,Nn),i(t,[{key:"request",value:function(e){return this._checkOptions(e),this._initOptions(e),e=u({},e,{responseType:"text"}),this._request(e).then(this._handleResolve).catch(this._handleReject)}},{key:"_handleResolve",value:function(e){var t=e.data,n=t.error_code,r=t.ErrorCode;return"number"==typeof n&&(r=n),r!==He.REQUEST.SUCCESS&&(e.data.ErrorCode=Number("".concat(r))),e}},{key:"_handleReject",value:function(e){if($(e.errMsg)){if(e.errMsg.includes("abort"))return pt({});if(e.errMsg.includes("timeout"))return ht(new Ce({code:Ie.NETWORK_TIMEOUT,message:e.errMsg}));if(e.errMsg.includes("fail"))return ht(new Ce({code:Ie.NETWORK_ERROR,message:e.errMsg}))}return ht(new Ce(u({code:Ie.UNCAUGHT_ERROR,message:e.message},e)))}},{key:"promisify",value:function(e){return function(t){return new Promise(function(n,r){var o=e(Object.assign({},t,{success:n,fail:r}));t.updateAbort&&t.updateAbort(function(){return o.abort()})})}}}]),t}(),Nr=function(){function e(){r(this,e),this.request=0,this.success=0,this.fail=0,this.reportRate=10,this.requestTimeCost=[]}return i(e,[{key:"report",value:function(){if(1!==this.request){if(this.request%this.reportRate!=0)return null;var e=this.avgRequestTime(),t="runLoop reports: success=".concat(this.success,",fail=").concat(this.fail,",total=").concat(this.request,",avg=").concat(e,",cur=").concat(this.requestTimeCost[this.requestTimeCost.length-1],",max=").concat(Math.max.apply(null,this.requestTimeCost),",min=").concat(Math.min.apply(null,this.requestTimeCost));Q.log(t)}}},{key:"setRequestTime",value:function(e,t){var n=Math.abs(t-e);100===this.requestTimeCost.length&&this.requestTimeCost.shift(),this.requestTimeCost.push(n)}},{key:"avgRequestTime",value:function(){for(var e,t=this.requestTimeCost.length,n=0,r=0;r<t;r++)n+=this.requestTimeCost[r];return e=n/t,Math.round(100*e)/100}}]),e}(),Lr=On.CancelToken,Rr=function(){function e(t){r(this,e),this._initializeOptions(t),this._initializeMembers(),this.status=new Nr}return i(e,[{key:"destructor",value:function(){clearTimeout(this._seedID);var e=this._index();for(var t in this)Object.prototype.hasOwnProperty.call(this,t)&&(this[t]=null);return e}},{key:"setIndex",value:function(e){this._index=e}},{key:"getIndex",value:function(){return this._index}},{key:"isRunning",value:function(){return!this._stoped}},{key:"_initializeOptions",value:function(e){this.options=e}},{key:"_initializeMembers",value:function(){this._index=-1,this._seedID=0,this._requestStatus=0,this._stoped=0,this._intervalTime=0,this._intervalIncreaseStep=1e3,this._intervalDecreaseStep=1e3,this._intervalTimeMax=5e3,this._protectTimeout=3e3,this._getNoticeSeq=this.options.getNoticeSeq,this._retryCount=0,this._responseTime=Date.now(),this._responseTimeThreshold=2e3,this.requestor=An,this.abort=null}},{key:"start",value:function(){0===this._seedID?(this._stoped=0,this._send()):Q.log('XHRRunLoop.start(), XHRRunLoop is running now, if you want to restart runLoop , please run "stop()" first.')}},{key:"_reset",value:function(){Q.log("XHRRunLoop._reset(), reset long poll _intervalTime",this._intervalTime),this.stop(),this.start()}},{key:"_intervalTimeIncrease",value:function(){this._intervalTime!==this._responseTimeThreshold&&(this._intervalTime<this._responseTimeThreshold&&(this._intervalTime+=this._intervalIncreaseStep),this._intervalTime>this._responseTimeThreshold&&(this._intervalTime=this._responseTimeThreshold))}},{key:"_intervalTimeDecrease",value:function(){0!==this._intervalTime&&(this._intervalTime>0&&(this._intervalTime-=this._intervalDecreaseStep),this._intervalTime<0&&(this._intervalTime=0))}},{key:"_intervalTimeAdjustment",value:function(){var e=Date.now();100*Math.floor((e-this._responseTime)/100)<=this._responseTimeThreshold?this._intervalTimeIncrease():this._intervalTimeDecrease(),this._responseTime=e}},{key:"_intervalTimeAdjustmentBaseOnResponseData",value:function(e){e.ErrorCode===He.REQUEST.SUCCESS?this._intervalTimeDecrease():this._intervalTimeIncrease()}},{key:"_send",value:function(){var e=this;if(1!=this._requestStatus){this._requestStatus=1,this.status.request++,"function"==typeof this.options.before&&this.options.before(this.options.pack.requestData);var t=Date.now(),n=0;this.requestor.request({url:this.options.pack.getUrl(),data:this.options.pack.requestData,method:this.options.pack.method,cancelToken:new Lr(function(t){e.abort=t})}).then(function(r){if(e._intervalTimeAdjustmentBaseOnResponseData.bind(e)(r.data),e._retryCount>0&&(e._retryCount=0),e.status.success++,"function"==typeof e.options.success)try{e.options.success({pack:e.options.pack,error:0,data:e.options.pack.callback(r.data)})}catch(o){Q.warn("XHRRunLoop._send(), error:",o)}e._requestStatus=0,0==e._stoped&&(e._seedID=setTimeout(e._send.bind(e),e._intervalTime)),n=Date.now(),e.status.setRequestTime(t,n),e.status.report()}).catch(function(r){if(e.status.fail++,e._retryCount++,e._intervalTimeAdjustment.bind(e)(),0==e._stoped&&(e._seedID=setTimeout(e._send.bind(e),e._intervalTime)),e._requestStatus=0,"function"==typeof e.options.fail&&void 0!==r.request)try{e.options.fail({pack:e.options.pack,error:r,data:0})}catch(o){Q.warn("XHRRunLoop._send(), fail callback error:"),Q.error(o)}n=Date.now(),e.status.setRequestTime(t,n),e.status.report()})}}},{key:"stop",value:function(){this._clearAllTimeOut(),this._stoped=1}},{key:"_clearAllTimeOut",value:function(){clearTimeout(this._seedID),this._seedID=0}}]),e}(),Pr=function(){function e(t){r(this,e),this._initializeOptions(t),this._initializeMembers(),this.status=new Nr}return i(e,[{key:"destructor",value:function(){clearTimeout(this._seedID);var e=this._index();for(var t in this)Object.prototype.hasOwnProperty.call(this,t)&&(this[t]=null);return e}},{key:"setIndex",value:function(e){this._index=e}},{key:"isRunning",value:function(){return!this._stoped}},{key:"getIndex",value:function(){return this._index}},{key:"_initializeOptions",value:function(e){this.options=e}},{key:"_initializeMembers",value:function(){this._index=-1,this._seedID=0,this._requestStatus=0,this._stoped=0,this._intervalTime=0,this._intervalIncreaseStep=1e3,this._intervalDecreaseStep=1e3,this._intervalTimeMax=5e3,this._protectTimeout=3e3,this._getNoticeSeq=this.options.getNoticeSeq,this._retryCount=0,this._responseTime=Date.now(),this._responseTimeThreshold=2e3,this.requestor=new Ar,this.abort=null}},{key:"start",value:function(){0===this._seedID?(this._stoped=0,this._send()):Q.log('WXRunLoop.start(): WXRunLoop is running now, if you want to restart runLoop , please run "stop()" first.')}},{key:"_reset",value:function(){Q.log("WXRunLoop.reset(), long poll _intervalMaxRate",this._intervalMaxRate),this.stop(),this.start()}},{key:"_intervalTimeIncrease",value:function(){this._intervalTime!==this._responseTimeThreshold&&(this._intervalTime<this._responseTimeThreshold&&(this._intervalTime+=this._intervalIncreaseStep),this._intervalTime>this._responseTimeThreshold&&(this._intervalTime=this._responseTimeThreshold))}},{key:"_intervalTimeDecrease",value:function(){0!==this._intervalTime&&(this._intervalTime>0&&(this._intervalTime-=this._intervalDecreaseStep),this._intervalTime<0&&(this._intervalTime=0))}},{key:"_intervalTimeAdjustment",value:function(){var e=Date.now();100*Math.floor((e-this._responseTime)/100)<=this._responseTimeThreshold?this._intervalTimeIncrease():this._intervalTimeDecrease(),this._responseTime=e}},{key:"_intervalTimeAdjustmentBaseOnResponseData",value:function(e){e.ErrorCode===He.REQUEST.SUCCESS?this._intervalTimeDecrease():this._intervalTimeIncrease()}},{key:"_send",value:function(){var e=this;if(1!=this._requestStatus){var t=this;this._requestStatus=1,this.status.request++,"function"==typeof this.options.before&&this.options.before(t.options.pack.requestData);var n=Date.now(),r=0;this.requestor.request({url:t.options.pack.getUrl(),data:t.options.pack.requestData,method:t.options.pack.method,updateAbort:function(t){e.abort=t}}).then(function(o){if(t._intervalTimeAdjustmentBaseOnResponseData.bind(e)(o.data),t._retryCount>0&&(t._retryCount=0),e.status.success++,"function"==typeof t.options.success)try{e.options.success({pack:e.options.pack,error:0,data:e.options.pack.callback(o.data)})}catch(i){Q.warn("WXRunLoop._send(), error:",i)}t._requestStatus=0,0==t._stoped&&(t._seedID=setTimeout(t._send.bind(t),t._intervalTime)),r=Date.now(),e.status.setRequestTime(n,r),e.status.report()}).catch(function(o){if(e.status.fail++,t._retryCount++,t._intervalTimeAdjustment.bind(e)(),0==t._stoped&&(t._seedID=setTimeout(t._send.bind(t),t._intervalTime)),t._requestStatus=0,"function"==typeof t.options.fail)try{e.options.fail({pack:e.options.pack,error:o,data:0})}catch(i){Q.warn("WXRunLoop._send(), fail callback error:"),Q.error(i)}r=Date.now(),e.status.setRequestTime(n,r),e.status.report()})}}},{key:"stop",value:function(){this._clearAllTimeOut(),this._stoped=1}},{key:"_clearAllTimeOut",value:function(){clearTimeout(this._seedID),this._seedID=0}}]),e}(),Gr=function(e){function t(e){var n;return r(this,t),(n=g(this,l(t).call(this,e))).context=e.context,n.httpConnection=n._getHttpconnection(),n.keepAliveConnections=[],n}return c(t,Fe),i(t,[{key:"initializeListener",value:function(){this.tim.innerEmitter.on(Re.SIGN_LOGOUT_EXECUTING,this._stopAllRunLoop,this)}},{key:"request",value:function(e){var t={url:e.url,data:e.requestData,method:e.method,callback:e.callback};return this.httpConnection.request(t).then(function(t){return t.data=e.callback(t.data),t.data.errorCode!==He.REQUEST.SUCCESS?ht(new Ce({code:t.data.errorCode,message:t.data.errorInfo})):t})}},{key:"createRunLoop",value:function(e){var t=this.createKeepAliveConnection(e);return t.setIndex(this.keepAliveConnections.push(t)-1),t}},{key:"stopRunLoop",value:function(e){e.stop()}},{key:"_stopAllRunLoop",value:function(){for(var e=this.keepAliveConnections.length,t=0;t<e;t++)this.keepAliveConnections[t].stop()}},{key:"destroyRunLoop",value:function(e){e.stop();var t=e.destructor();this.keepAliveConnections.slice(t,1)}},{key:"startRunLoopExclusive",value:function(e){for(var t=e.getIndex(),n=0;n<this.keepAliveConnections.length;n++)n!==t&&this.keepAliveConnections[n].stop();e.start()}},{key:"_getHttpconnection",value:function(){return b?new Ar:new Ln}},{key:"createKeepAliveConnection",value:function(e){return b?new Pr(e):this.tim.options.runLoopNetType===tt?new Rr(e):(this.tim.options.runLoopNetType,"function"==typeof window.WebSocket&&window.WebSocket.prototype.send,new Rr(e))}},{key:"clearAll",value:function(){this.conn.cancelAll()}},{key:"reset",value:function(){this.keepAliveConnections=[]}}]),t}();void 0===console.table&&(console.table=console.log);var kr=function(e,t){e.code?Q.warn("Oops! code: ".concat(e.code),"message: ".concat(e.message),"stack: ".concat(e.stack)):Q.warn("Oops! message: ".concat(e.message),"stack: ".concat(e.stack))},wr={f9999998:function(e){kr(e)},f9999999:function(e){kr(e)},f:function(e){kr(e),"未定义的错误:".concat(e.code," , ").concat(e.message)},f20000:function(e){kr(e)},f20001:function(e){kr(e)},f20002:function(e){kr(e)},f30000:function(e){kr(e)},f40004:function(e){kr(e)},f40005:function(e){kr(e)},f40006:function(e){kr(e)},f40007:function(e){kr(e)},f40008:function(e){kr(e)},f50070003:function(e){e.code.replace("500","");kr(e)},f50030001:function(e){kr(e)},f50070221:function(e){kr(e)}};wr.echo=kr;var br=function(){function t(e){r(this,t),this.methods=wr,this.tim=e,this._initielizeListener()}return i(t,[{key:"_initielizeListener",value:function(){this.tim.innerEmitter.on(Re.ERROR_DETECTED,this._onErrorDetected,this)}},{key:"ask",value:function(e){var t=["f",e.code].join(""),n=wr.echo;this.methods.hasOwnProperty(t)?this.methods[t](e):n(e)}},{key:"_onErrorDetected",value:function(t){this.ask(t),this.tim.outerEmitter.emit(e.ERROR,t)}}]),t}(),Ur=["jpg","jpeg","gif","png"],Fr=function(){function e(n){r(this,e),T(n)||(this.userID=n.userID||"",this.nick=n.nick||"",this.gender=n.gender||"",this.birthday=n.birthday||0,this.location=n.location||"",this.selfSignature=n.selfSignature||"",this.allowType=n.allowType||t.ALLOW_TYPE_ALLOW_ANY,this.language=n.language||0,this.avatar=n.avatar||"",this.messageSettings=n.messageSettings||0,this.adminForbidType=n.adminForbidType||t.FORBID_TYPE_NONE,this.level=n.level||0,this.role=n.role||0,this.lastUpdatedTime=0)}return i(e,[{key:"validate",value:function(e){var t=1,n="";for(var r in T(e)&&(t=0,n="empty options"),e)if(Object.prototype.hasOwnProperty.call(e,r)){if(T(e[r])&&!$(e[r])&&!Z(e[r])){n="key:"+r+", invalid value:"+e[r],t=0;continue}switch(r){case"nick":$(e[r])||(n="nick should be a string",t=0),le(e[r])>500&&(n="nick name limited: must less than or equal to ".concat(500," bytes, current size: ").concat(le(e[r])," bytes"),t=0);break;case"gender":_e(it,e.gender)||(n="key:gender, invalid value:"+e.gender,t=0);break;case"birthday":Z(e.birthday)||(n="birthday should be a number",t=0);break;case"location":$(e.location)||(n="location should be a string",t=0);break;case"selfSignature":$(e.selfSignature)||(n="selfSignature should be a string",t=0);break;case"allowType":_e(st,e.allowType)||(n="key:allowType, invalid value:"+e.allowType,t=0);break;case"language":Z(e.language)||(n="language should be a number",t=0);break;case"avatar":$(e.avatar)||(n="avatar should be a string",t=0);break;case"messageSettings":0!==e.messageSettings&&1!==e.messageSettings&&(n="messageSettings should be 0 or 1",t=0);break;case"adminForbidType":_e(at,e.adminForbidType)||(n="key:adminForbidType, invalid value:"+e.adminForbidType,t=0);break;case"level":Z(e.level)||(n="level should be a number",t=0);break;case"role":Z(e.role)||(n="role should be a number",t=0);break;default:n="unknown key:"+r,t=0}}return{valid:t,tips:n}}}]),e}(),qr=function(){function t(e){r(this,t),this.uc=e,this.TAG="profile",this.Actions={Q:"query",U:"update"},this.accountProfileMap=new Map,this.expirationTime=864e5}return i(t,[{key:"setExpirationTime",value:function(e){this.expirationTime=e}},{key:"getUserProfile",value:function(t){var n=this,r=this.uc.tim,o=r.connectionController,i=r.outerEmitter,a=t.userIDList;if(!te(a))return Q.error("ProfileHandler.getUserProfile options.userIDList 必需是数组"),ht({code:Ie.GET_PROFILE_INVALID_PARAM,message:Se.GET_PROFILE_INVALID_PARAM});t.fromAccount=this.uc.getMyAccount(),a.length>100&&(Q.warn("ProfileHandler.getUserProfile 获取用户资料人数不能超过100人"),a.length=100);for(var s,u=[],c=[],l=0,p=a.length;l<p;l++)s=a[l],this.uc.isMyFriend(s)&&this._containsAccount(s)?c.push(this._getProfileFromMap(s)):u.push(s);if(0===u.length)return i.emit(e.PROFILE_GET_SUCCESS,c),pt(c);t.toAccount=u;var h=t.bFromGetMyProfile||0,f=this.uc.makeCapsule(this.TAG,this.Actions.Q,t);return o.request(f).then(function(t){Q.info("ProfileHandler.getUserProfile ok");var r=n._handleResponse(t).concat(c);return i.emit(e.PROFILE_GET_SUCCESS,r),h?(n.uc.onGotMyProfile(),new ut(r[0])):new ut(r)}).catch(function(e){return Q.error("ProfileHandler.getUserProfile error:",e),ht(e,1)})}},{key:"getMyProfile",value:function(){var t=this.uc.getMyAccount();if(Q.log("ProfileHandler.getMyProfile myAccount="+t),this._fillMap(),this._containsAccount(t)){var n=this._getProfileFromMap(t);return Q.debug("ProfileHandler.getMyProfile from cache, myProfile:"+JSON.stringify(n)),this.uc.tim.outerEmitter.emit(e.PROFILE_GET_SUCCESS,[n]),this.uc.onGotMyProfile(),pt(n)}return this.getUserProfile({fromAccount:t,userIDList:[t],bFromGetMyProfile:1})}},{key:"_handleResponse",value:function(e){for(var t,n,r=se.now(),o=e.data.userProfileItem,i=[],a=0,s=o.length;a<s;a++)"@TLS#NOT_FOUND"!==o[a].to&&""!==o[a].to&&(t=o[a].to,n=this._updateMap(t,this._getLatestProfileFromResponse(t,o[a].profileItem)),i.push(n));return Q.log("ProfileHandler._handleResponse cost "+(se.now()-r)+" ms"),i}},{key:"_getLatestProfileFromResponse",value:function(e,t){var n={};if(n.userID=e,!T(t))for(var r=0,o=t.length;r<o;r++)switch(t[r].tag){case ot.NICK:n.nick=t[r].value;break;case ot.GENDER:n.gender=t[r].value;break;case ot.BIRTHDAY:n.birthday=t[r].value;break;case ot.LOCATION:n.location=t[r].value;break;case ot.SELFSIGNATURE:n.selfSignature=t[r].value;break;case ot.ALLOWTYPE:n.allowType=t[r].value;break;case ot.LANGUAGE:n.language=t[r].value;break;case ot.AVATAR:n.avatar=t[r].value;break;case ot.MESSAGESETTINGS:n.messageSettings=t[r].value;break;case ot.ADMINFORBIDTYPE:n.adminForbidType=t[r].value;break;case ot.LEVEL:n.level=t[r].value;break;case ot.ROLE:n.role=t[r].value;break;default:Q.warn("ProfileHandler._handleResponse unkown tag->",t[r].tag)}return n}},{key:"updateMyProfile",value:function(t){var n=this,r=this.uc.tim,o=r.connectionController,i=r.outerEmitter,a=(new Fr).validate(t);if(!a.valid)return Q.error("ProfileHandler.updateMyProfile info:"+a.tips),ht({code:Ie.UPDATE_PROFILE_INVALID_PARAM,message:Se.UPDATE_PROFILE_INVALID_PARAM});var s=[];for(var u in t)Object.prototype.hasOwnProperty.call(t,u)&&s.push({tag:ot[u.toUpperCase()],value:t[u]});var c=this.uc.makeCapsule(this.TAG,this.Actions.U,{fromAccount:this.uc.getMyAccount(),profileItem:s});return o.request(c).then(function(r){Q.info("ProfileHandler.updateMyProfile ok");var o=n._updateMap(n.uc.getMyAccount(),t);return i.emit(e.PROFILE_UPDATED,[o]),pt(o)}).catch(function(e){return Q.error("ProfileHandler.updateMyProfile error:",e),ht(e,1)})}},{key:"onProfileModified",value:function(t){var n=t.data;if(!T(n)){var r,o,i=n.length;Q.info("ProfileHandler.onProfileModified length="+i);for(var a=[],s=0;s<i;s++)r=n[s].userID,o=this._updateMap(r,this._getLatestProfileFromResponse(r,n[s].profileList)),a.push(o);var u=this.uc.tim,c=u.innerEmitter,l=u.outerEmitter;c.emit(Re.PROFILE_UPDATED,{data:a}),l.emit(e.PROFILE_UPDATED,a)}}},{key:"_fillMap",value:function(){if(0===this.accountProfileMap.size){for(var e=this._getCachedProfiles(),t=Date.now(),n=0,r=e.length;n<r;n++)t-e[n].lastUpdatedTime<this.expirationTime&&this.accountProfileMap.set(e[n].userID,e[n]);Q.log("ProfileHandler._fillMap from chache, map.size="+this.accountProfileMap.size)}}},{key:"_updateMap",value:function(e,t){var n,r=Date.now();return this._containsAccount(e)?(n=this._getProfileFromMap(e),ue(n,t),n.lastUpdatedTime=r):(n=new Fr(t),(this.uc.isMyFriend(e)||e===this.uc.getMyAccount())&&(n.lastUpdatedTime=r,this.accountProfileMap.set(e,n))),this._flushMap(),n}},{key:"_flushMap",value:function(){this._cacheProfiles(m(this.accountProfileMap.values()))}},{key:"_containsAccount",value:function(e){return this.accountProfileMap.has(e)}},{key:"_getProfileFromMap",value:function(e){return this.accountProfileMap.get(e)}},{key:"_getCachedProfiles",value:function(){var e=this.uc.tim.storage.getItem(this.TAG);return T(e)?[]:e}},{key:"_cacheProfiles",value:function(e){var t=this.uc.tim.storage;Q.debug("ProfileHandler._cacheProfiles length="+e.length),t.setItem(this.TAG,e)}},{key:"onConversationsProfileUpdated",value:function(e){for(var t,n,r,o=[],i=0,a=e.length;i<a;i++)n=(t=e[i]).userID,this._containsAccount(n)?(r=this._getProfileFromMap(n),ue(r,t)>0&&o.push(n)):o.push(t.userID);0!==o.length&&(Q.info("ProfileHandler.onConversationsProfileUpdated toAccount:",o),this.getUserProfile({userIDList:o}))}},{key:"reset",value:function(){this._flushMap(),this.accountProfileMap.clear()}}]),t}(),xr=function(){function e(t){r(this,e),this.options=t?t.options:{enablePointer:1},this.pointsList={},this.reportText={},this.maxNameLen=0,this.gapChar="-",this.log=console.log,this.currentTask=""}return i(e,[{key:"newTask",value:function(e){0!=this.options.enablePointer&&(e||(e=["task",this._timeFormat()].join("-")),this.pointsList[e]=[],this.currentTask=e,console.log("Pointer new Task : ".concat(this.currentTask)))}},{key:"deleteTask",value:function(e){0!=this.options.enablePointer&&(e||(e=this.currentTask),this.pointsList[e].length=0,delete this.pointsList[e])}},{key:"dot",value:function(){var e=arguments.length>0&&void 0!==arguments[0]?arguments[0]:"",t=arguments.length>1?arguments[1]:void 0;if(0!=this.options.enablePointer){t=t||this.currentTask;var n=+new Date;this.maxNameLen=this.maxNameLen<e.length?e.length:this.maxNameLen,this.flen=this.maxNameLen+10,this.pointsList[t].push({pointerName:e,time:n})}}},{key:"_analisys",value:function(e){if(0!=this.options.enablePointer){e=e||this.currentTask;for(var t=this.pointsList[e],n=t.length,r=[],o=[],i=0;i<n;i++)0!==i&&(o=this._analisysTowPoints(t[i-1],t[i]),r.push(o.join("")));return o=this._analisysTowPoints(t[0],t[n-1],1),r.push(o.join("")),r.join("")}}},{key:"_analisysTowPoints",value:function(e,t){var n=arguments.length>2&&void 0!==arguments[2]?arguments[2]:0;if(0!=this.options.enablePointer){var r=this.flen,o=t.time-e.time,i=o.toString(),a=e.pointerName+this.gapChar.repeat(r-e.pointerName.length),s=t.pointerName+this.gapChar.repeat(r-t.pointerName.length),u=this.gapChar.repeat(4-i.length)+i,c=n?["%c",a,s,u,"ms\n%c"]:[a,s,u,"ms\n"];return c}}},{key:"report",value:function(e){if(0!=this.options.enablePointer){e=e||this.currentTask;var t=this._analisys(e);this.pointsList=[];var n=this._timeFormat(),r="Pointer[".concat(e,"(").concat(n,")]"),o=4*this.maxNameLen,i=(o-r.length)/2;console.log(["-".repeat(i),r,"-".repeat(i)].join("")),console.log("%c"+t,"color:#66a","color:red","color:#66a"),console.log("-".repeat(o))}}},{key:"_timeFormat",value:function(){var e=new Date,t=this.zeroFix(e.getMonth()+1,2),n=this.zeroFix(e.getDate(),2);return"".concat(t,"-").concat(n," ").concat(e.getHours(),":").concat(e.getSeconds(),":").concat(e.getMinutes(),"~").concat(e.getMilliseconds())}},{key:"zeroFix",value:function(e,t){return("000000000"+e).slice(-t)}},{key:"reportAll",value:function(){if(0!=this.options.enablePointer)for(var e in this.pointsList)Object.prototype.hasOwnProperty.call(this.pointsList,e)&&this.eport(e)}}]),e}(),Hr=function e(t,n){r(this,e),this.userID=t;var o={};if(o.userID=t,!T(n))for(var i=0,a=n.length;i<a;i++)switch(n[i].tag){case ot.NICK:o.nick=n[i].value;break;case ot.GENDER:o.gender=n[i].value;break;case ot.BIRTHDAY:o.birthday=n[i].value;break;case ot.LOCATION:o.location=n[i].value;break;case ot.SELFSIGNATURE:o.selfSignature=n[i].value;break;case ot.ALLOWTYPE:o.allowType=n[i].value;break;case ot.LANGUAGE:o.language=n[i].value;break;case ot.AVATAR:o.avatar=n[i].value;break;case ot.MESSAGESETTINGS:o.messageSettings=n[i].value;break;case ot.ADMINFORBIDTYPE:o.adminForbidType=n[i].value;break;case ot.LEVEL:o.level=n[i].value;break;case ot.ROLE:o.role=n[i].value;break;default:Q.warn("snsProfileItem unkown tag->",n[i].tag)}this.profile=new Fr(o)},Kr=function(){function t(e){r(this,t),this.uc=e,this.TAG="friend",this.Actions={G:"get",D:"delete"},this.friends=new Map,this.pointer=new xr}return i(t,[{key:"isMyFriend",value:function(e){var t=this.friends.has(e);return t||Q.debug("FriendHandler.isMyFriend "+e+" is not my friend"),t}},{key:"_transformFriendList",value:function(e){if(!T(e)&&!T(e.infoItem)){Q.info("FriendHandler._transformFriendList friendNum="+e.friendNum);for(var t,n,r=e.infoItem,o=0,i=r.length;o<i;o++)n=r[o].infoAccount,t=new Hr(n,r[o].snsProfileItem),this.friends.set(n,t)}}},{key:"_friends2map",value:function(e){var t=new Map;for(var n in e)Object.prototype.hasOwnProperty.call(e,n)&&t.set(n,e[n]);return t}},{key:"getFriendList",value:function(){var t=this,n=this.uc.tim,r=n.connectionController,o=n.outerEmitter,i={};i.fromAccount=this.uc.getMyAccount(),Q.info("FriendHandler.getFriendList myAccount="+i.fromAccount);var a=this.uc.makeCapsule(this.TAG,this.Actions.G,i);return r.request(a).then(function(n){Q.info("FriendHandler.getFriendList ok"),t._transformFriendList(n.data);var r=m(t.friends.values());return o.emit(e.FRIENDLIST_GET_SUCCESS,r),pt(r)}).catch(function(e){return Q.error("FriendHandler.getFriendList error:",JSON.stringify(e)),ht(e,1)})}},{key:"deleteFriend",value:function(t){if(!Array.isArray(t.toAccount))return Q.error("FriendHandler.deleteFriend options.toAccount 必需是数组"),ht({code:Ie.DEL_FRIEND_INVALID_PARAM,message:Se.DEL_FRIEND_INVALID_PARAM});t.toAccount.length>1e3&&(Q.warn("FriendHandler.deleteFriend 删除好友人数不能超过1000人"),t.toAccount.length=1e3);var n=this.uc.tim,r=n.connectionController,o=n.outerEmitter,i=this.uc.makeCapsule(this.TAG,this.Actions.D,t);return r.request(i).then(function(t){return Q.info("FriendHandler.deleteFriend ok"),o.emit(e.FRIEND_DELETE_SUCCESS),pt()}).catch(function(e){return Q.error("FriendHandler.deleteFriend error:",e),ht(e,1)})}}]),t}(),Br=function e(t){r(this,e),T||(this.userID=t.userID||"",this.timeStamp=t.timeStamp||0)},Vr=function(){function t(e){r(this,t),this.uc=e,this.TAG="blacklist",this.Actions={G:"get",C:"create",D:"delete"},this.blacklistMap=new Map,this.startIndex=0,this.maxLimited=100,this.curruentSequence=0}return i(t,[{key:"getBlacklist",value:function(){var e=this,t=this.uc.tim.connectionController,n={};n.fromAccount=this.uc.getMyAccount(),n.maxLimited=this.maxLimited,n.startIndex=0,n.lastSequence=this.curruentSequence;var r=this.uc.makeCapsule(this.TAG,this.Actions.G,n);return t.request(r).then(function(t){return Q.info("BlacklistHandler.getBlacklist ok"),e.curruentSequence=t.data.curruentSequence,e._handleResponse(t.data.blackListItem,1),e._onBlacklistUpdated()}).catch(function(e){return Q.error("BlacklistHandler.getBlacklist error:",e),ht(e,1)})}},{key:"addBlacklist",value:function(e){var t=this;if(!te(e.userIDList))return Q.error("BlacklistHandler.addBlacklist options.userIDList 必需是数组"),ht({code:Ie.ADD_BLACKLIST_INVALID_PARAM,message:Se.ADD_BLACKLIST_INVALID_PARAM});var n=this.uc.tim.loginInfo.identifier;if(1===e.userIDList.length&&e.userIDList[0]===n)return Q.error("BlacklistHandler.addBlacklist 不能把自己拉黑"),ht({code:Ie.CANNOT_ADD_SELF_TO_BLACKLIST,message:Se.CANNOT_ADD_SELF_TO_BLACKLIST});e.userIDList.includes(n)&&(e.userIDList=e.userIDList.filter(function(e){return e!==n}),Q.warn("BlacklistHandler.addBlacklist 不能把自己拉黑，已过滤"));var r=this.uc.tim.connectionController;e.fromAccount=this.uc.getMyAccount(),e.toAccount=e.userIDList;var o=this.uc.makeCapsule(this.TAG,this.Actions.C,e);return r.request(o).then(function(e){return Q.info("BlacklistHandler.addBlacklist ok"),t._handleResponse(e.data.resultItem,1),t._onBlacklistUpdated()}).catch(function(e){return Q.error("BlacklistHandler.addBlacklist error:",e),ht(e,1)})}},{key:"_handleResponse",value:function(e,t){if(!T(e))for(var n,r,o,i=0,a=e.length;i<a;i++)r=e[i].to,o=e[i].resultCode,(ne(o)||0===o)&&(t?((n=this.blacklistMap.has(r)?this.blacklistMap.get(r):new Br).userID=r,!T(e[i].addBlackTimeStamp)&&(n.timeStamp=e[i].addBlackTimeStamp),this.blacklistMap.set(r,n)):this.blacklistMap.has(r)&&(n=this.blacklistMap.get(r),this.blacklistMap.delete(r)));Q.log("BlacklistHandler._handleResponse total="+this.blacklistMap.size+" bAdd="+t)}},{key:"deleteBlacklist",value:function(e){var t=this;if(!te(e.userIDList))return Q.error("BlacklistHandler.deleteBlacklist options.userIDList 必需是数组"),ht({code:Ie.DEL_BLACKLIST_INVALID_PARAM,message:Se.DEL_BLACKLIST_INVALID_PARAM});var n=this.uc.tim.connectionController;e.fromAccount=this.uc.getMyAccount(),e.toAccount=e.userIDList;var r=this.uc.makeCapsule(this.TAG,this.Actions.D,e);return n.request(r).then(function(e){return Q.info("BlacklistHandler.deleteBlacklist ok"),t._handleResponse(e.data.resultItem,0),t._onBlacklistUpdated()}).catch(function(e){return Q.error("BlacklistHandler.deleteBlacklist error:",e),ht(e,1)})}},{key:"_onBlacklistUpdated",value:function(){var t=this.uc.tim.outerEmitter,n=m(this.blacklistMap.keys());return t.emit(e.BLACKLIST_UPDATED,n),pt(n)}},{key:"handleBlackListDelAccount",value:function(t){for(var n,r=[],o=0,i=t.length;o<i;o++)n=t[o],this.blacklistMap.has(n)&&(this.blacklistMap.delete(n),r.push(n));r.length>0&&(Q.log("BlacklistHandler.handleBlackListDelAccount delCount="+r.length+" : "+r.join(",")),this.tim.outerEmitter.emit(e.BLACKLIST_UPDATED,m(this.blacklistMap.keys())))}},{key:"handleBlackListAddAccount",value:function(t){for(var n,r=[],o=0,i=t.length;o<i;o++)n=t[o],this.blacklistMap.has(n)||(this.blacklistMap.set(n,new Br({userID:n})),r.push(n));r.length>0&&(Q.log("BlacklistHandler.handleBlackListAddAccount addCount="+r.length+" : "+r.join(",")),this.tim.outerEmitter.emit(e.BLACKLIST_UPDATED,m(this.blacklistMap.keys())))}},{key:"reset",value:function(){this.blacklistMap.clear(),this.startIndex=0,this.maxLimited=100,this.curruentSequence=0}}]),t}(),Yr=function(){function t(e){r(this,t),this.uc=e,this.TAG="applyC2C",this.Actions={C:"create",G:"get",D:"delete",U:"update"}}return i(t,[{key:"applyAddFriend",value:function(t){var n=this,r=this.uc.tim,o=r.outerEmitter,i=r.connectionController,a=this.uc.makeCapsule(this.TAG,this.Actions.C,t),s=i.request(a);return s.then(function(t){n.uc.isActionSuccessful("applyAddFriend",n.Actions.C,t)?o.emit(e.APPLY_ADD_FRIEND_SUCCESS,{data:t.data}):o.emit(e.APPLY_ADD_FRIEND_FAIL,{data:t.data})}).catch(function(t){o.emit(e.APPLY_ADD_FRIEND_FAIL,{data:t})}),s}},{key:"getPendency",value:function(t){var n=this,r=this.tim,o=r.connectionController,i=r.outerEmitter,a=this.uc.makeCapsule(this.TAG,this.Actions.G,t),s=o.request(a);return s.then(function(t){n.uc.isActionSuccessful("getPendency",n.Actions.G,t)?i.emit(e.GET_PENDENCY_SUCCESS,{data:t.data}):i.emit(e.GET_PENDENCY_FAIL,{data:t.data})}).catch(function(t){i.emit(e.GET_PENDENCY_FAIL,{data:t})}),s}},{key:"deletePendency",value:function(t){var n=this,r=this.tim,o=r.connectionController,i=r.outerEmitter,a=this.uc.makeCapsule(this.TAG,this.Actions.D,t),s=o.request(a);return s.then(function(t){n.uc.isActionSuccessful("deletePendency",n.Actions.D,t)?i.emit(e.DELETE_PENDENCY_SUCCESS,{data:t.data}):i.emit(e.DELETE_PENDENCY_FAIL,{data:t.data})}).catch(function(t){i.emit(e.DELETE_PENDENCY_FAIL,{data:t})}),s}},{key:"replyPendency",value:function(){var t=this,n=arguments.length>0&&void 0!==arguments[0]?arguments[0]:{},r=this.tim,o=r.connectionController,i=r.outerEmitter,a=this.uc.makeCapsule(this.TAG,this.Actions.U,n),s=o.request(a);return s.then(function(n){t.uc.isActionSuccessful("replyPendency",t.Actions.U,n)?i.emit(e.REPLY_PENDENCY_SUCCESS,{data:n.data}):i.emit(e.REPLY_PENDENCY_FAIL,{data:n.data})}).catch(function(t){i.emit(e.REPLY_PENDENCY_FAIL,{data:t})}),s}}]),t}(),jr=function(e){function t(e){var n;return r(this,t),(n=g(this,l(t).call(this,e))).profileHandler=new qr(_(n)),n.friendHandler=new Kr(_(n)),n.blacklistHandler=new Vr(_(n)),n.applyC2CHandler=new Yr(_(n)),n._initializeListener(),n}return c(t,Fe),i(t,[{key:"_initializeListener",value:function(e){var t=this.tim.innerEmitter;t.on(Re.CONTEXT_A2KEY_AND_TINYID_UPDATED,this.onContextUpdated,this),t.on(Re.NOTICE_LONGPOLL_PROFILE_MODIFIED,this.onProfileModified,this),t.on(Re.NOTICE_LONGPOLL_NEW_FRIEND_MESSAGES,this.onNewFriendMessages,this),t.on(Re.CONVERSATION_LIST_PROFILE_UPDATED,this.onConversationsProfileUpdated,this)}},{key:"onContextUpdated",value:function(e){var t=e.data.context;0!=!!t.a2Key&&0!=!!t.tinyID&&(this.profileHandler.getMyProfile(),this.friendHandler.getFriendList(),this.blacklistHandler.getBlacklist())}},{key:"onGotMyProfile",value:function(){this.triggerReady()}},{key:"onProfileModified",value:function(e){this.profileHandler.onProfileModified(e)}},{key:"onNewFriendMessages",value:function(e){Q.debug("onNewFriendMessages",JSON.stringify(e.data)),T(e.data.blackListDelAccount)||this.blacklistHandler.handleBlackListDelAccount(e.data.blackListDelAccount),T(e.data.blackListAddAccount)||this.blacklistHandler.handleBlackListAddAccount(e.data.blackListAddAccount)}},{key:"onConversationsProfileUpdated",value:function(e){this.profileHandler.onConversationsProfileUpdated(e.data)}},{key:"getMyAccount",value:function(){return this.tim.context.identifier}},{key:"isMyFriend",value:function(e){return this.friendHandler.isMyFriend(e)}},{key:"makeCapsule",value:function(e,t,n){return this.createPackage({name:e,action:t,param:n})}},{key:"getMyProfile",value:function(){return this.profileHandler.getMyProfile()}},{key:"getUserProfile",value:function(e){return this.profileHandler.getUserProfile(e)}},{key:"updateMyProfile",value:function(e){return this.profileHandler.updateMyProfile(e)}},{key:"getFriendList",value:function(){return this.friendHandler.getFriendList()}},{key:"deleteFriend",value:function(e){return this.friendHandler.deleteFriend(e)}},{key:"getBlacklist",value:function(){return this.blacklistHandler.getBlacklist()}},{key:"addBlacklist",value:function(e){return this.blacklistHandler.addBlacklist(e)}},{key:"deleteBlacklist",value:function(e){return this.blacklistHandler.deleteBlacklist(e)}},{key:"applyAddFriend",value:function(e){return this.applyC2CHandler.applyAddFriend(e)}},{key:"getPendency",value:function(e){return this.applyC2CHandler.getPendency(e)}},{key:"deletePendency",value:function(e){return this.applyC2CHandler.deletePendency(e)}},{key:"replyPendency",value:function(e){return this.applyC2CHandler.replyPendency(e)}},{key:"reset",value:function(){Q.warn("UserController.reset"),this.resetReady(),this.profileHandler.reset(),this.blacklistHandler.reset(),this.checkTimes=0}}]),t}(),zr=function(){function e(n){r(this,e),this.type=t.MSG_TEXT,this.content={text:n.text||""}}return i(e,[{key:"setText",value:function(e){this.content.text=e}},{key:"isEmpty",value:function(){return 0===this.content.text.length?1:0}}]),e}(),Wr=function(){function e(n){r(this,e),this._imageMemoryURL="",this._file=n.file,b?this.createImageDataASURLInWXMiniApp(n.file):this.createImageDataASURLInWeb(n.file),this._initImageInfoModel(),this.type=t.MSG_IMAGE,this._percent=0,this.content={imageFormat:Be.IMAGE_FORMAT[n.imageFormat]||Be.IMAGE_FORMAT.UNKNOWN,uuid:n.uuid,imageInfoArray:[]},this.initImageInfoArray(n.imageInfoArray),this._defaultImage="http://imgcache.qq.com/open/qcloud/video/act/webim-images/default.jpg",this._autoFixUrl()}return i(e,[{key:"_initImageInfoModel",value:function(){var e=this;this._ImageInfoModel=function(t){this.instanceID=pe(9999999),this.sizeType=t.type||0,this.size=t.size||0,this.width=t.width||0,this.height=t.height||0,this.imageUrl=t.url||"",this.url=t.url||e._imageMemoryURL||e._defaultImage},this._ImageInfoModel.prototype={setSizeType:function(e){this.sizeType=e},setImageUrl:function(e){e&&(this.imageUrl=e)},getImageUrl:function(){return this.imageUrl}}}},{key:"initImageInfoArray",value:function(e){for(var t=2,n=null,r=null;t>=0;)r=void 0===e||void 0===e[t]?{type:0,size:0,width:0,height:0,url:""}:e[t],(n=new this._ImageInfoModel(r)).setSizeType(t+1),this.addImageInfo(n),t--}},{key:"updateImageInfoArray",value:function(e){for(var t,n=this.content.imageInfoArray.length,r=0;r<n;r++)t=this.content.imageInfoArray[r],e.size&&(t.size=e.size),e.url&&t.setImageUrl(e.url),e.width&&(t.width=e.width),e.height&&(t.height=e.height)}},{key:"_autoFixUrl",value:function(){for(var e=this.content.imageInfoArray.length,t="",n="",r=["http","https"],o=null,i=0;i<e;i++)this.content.imageInfoArray[i].url&&""!==(o=this.content.imageInfoArray[i]).imageUrl&&(n=o.imageUrl.slice(0,o.imageUrl.indexOf("://")+1),t=o.imageUrl.slice(o.imageUrl.indexOf("://")+1),r.indexOf(n)<0&&(n="https:"),this.content.imageInfoArray[i].setImageUrl([n,t].join("")))}},{key:"updatePercent",value:function(e){this._percent=e,this._percent>1&&(this._percent=1)}},{key:"updateImageFormat",value:function(e){this.content.imageFormat=e}},{key:"createImageDataASURLInWeb",value:function(e){void 0!==e&&e.files.length>0&&(this._imageMemoryURL=window.URL.createObjectURL(e.files[0]))}},{key:"createImageDataASURLInWXMiniApp",value:function(e){e&&e.url&&(this._imageMemoryURL=e.url)}},{key:"replaceImageInfo",value:function(e,t){this.content.imageInfoArray[t]instanceof this._ImageInfoModel||(this.content.imageInfoArray[t]=e)}},{key:"addImageInfo",value:function(e){this.content.imageInfoArray.length>=3||this.content.imageInfoArray.push(e)}},{key:"isEmpty",value:function(){return 0===this.content.imageInfoArray.length?1:""===this.content.imageInfoArray[0].imageUrl?1:0===this.content.imageInfoArray[0].size?1:0}}]),e}(),Xr=function(){function e(n){r(this,e),this.type=t.MSG_FACE,this.content=n||null}return i(e,[{key:"isEmpty",value:function(){return null===this.content?1:0}}]),e}(),Jr=function(){function e(n){r(this,e),this.type=t.MSG_AUDIO,this.content={downloadFlag:2,second:n.second,size:n.size,url:n.url,remoteAudioUrl:"",uuid:n.uuid}}return i(e,[{key:"updateAudioUrl",value:function(e){this.content.remoteAudioUrl=e}},{key:"isEmpty",value:function(){return""===this.content.remoteAudioUrl?1:0}}]),e}(),Qr={from:1,groupID:1,groupName:1,to:1},Zr=function(){function e(n){r(this,e),this.type=t.MSG_GRP_TIP,this.content={},this._initContent(n)}return i(e,[{key:"_initContent",value:function(e){var t=this;Object.keys(e).forEach(function(n){switch(n){case"remarkInfo":break;case"groupProfile":t.content.groupProfile={},t._initGroupProfile(e[n]);break;case"operatorInfo":case"memberInfoList":break;default:t.content[n]=e[n]}}),this.content.userIDList||(this.content.userIDList=[this.content.operatorID])}},{key:"_initGroupProfile",value:function(e){for(var t=Object.keys(e),n=0;n<t.length;n++){var r=t[n];Qr[r]&&(this.content.groupProfile[r]=e[r])}}}]),e}(),$r={from:1,groupID:1,name:1,to:1},eo=function(){function e(n){r(this,e),this.type=t.MSG_GRP_SYS_NOTICE,this.content={},this._initContent(n)}return i(e,[{key:"_initContent",value:function(e){var t=this;Object.keys(e).forEach(function(n){switch(n){case"memberInfoList":break;case"remarkInfo":t.content.handleMessage=e[n];break;case"groupProfile":t.content.groupProfile={},t._initGroupProfile(e[n]);break;default:t.content[n]=e[n]}})}},{key:"_initGroupProfile",value:function(e){for(var t=Object.keys(e),n=0;n<t.length;n++){var r=t[n];$r[r]&&(this.content.groupProfile[r]=e[r])}}}]),e}(),to=function(){function e(n){r(this,e);var o=this._check(n);if(o instanceof Ce)throw o;this.type=t.MSG_FILE,this._percent=0;var i=this._getFileInfo(n);this.content={downloadFlag:2,fileUrl:n.url||"",uuid:n.uuid,fileName:i.name||"",fileSize:i.size||0}}return i(e,[{key:"_getFileInfo",value:function(e){if(e.fileName&&e.fileSize)return{size:e.fileSize,name:e.fileName};if(b)return{};var t=e.file.files[0];return{size:t.size,name:t.name,type:t.type.slice(t.type.lastIndexOf("/")+1).toUpperCase()}}},{key:"updatePercent",value:function(e){this._percent=e,this._percent>1&&(this._percent=1)}},{key:"updateFileUrl",value:function(e){this.content.fileUrl=e}},{key:"_check",value:function(e){if(e.size>20971520)return new Ce({code:Ie.MESSAGE_FILE_SIZE_LIMIT,message:"".concat(Se.MESSAGE_FILE_SIZE_LIMIT,": ").concat(20971520," bytes")})}},{key:"isEmpty",value:function(){return""===this.content.fileUrl?1:""===this.content.fileName?1:0===this.content.fileSize?1:0}}]),e}(),no=function(){function e(n){r(this,e),this.type=t.MSG_CUSTOM,this.content={data:n.data||"",description:n.description||"",extension:n.extension||""}}return i(e,[{key:"setData",value:function(e){return this.content.data=e,this}},{key:"setDescription",value:function(e){return this.content.description=e,this}},{key:"setExtension",value:function(e){return this.content.extension=e,this}},{key:"isEmpty",value:function(){return 0===this.content.data.length&&0===this.content.description.length&&0===this.content.extension.length?1:0}}]),e}(),ro=function e(n){r(this,e),this.type=t.MSG_VIDEO,this.content={videoFormat:n.videoFormat,videoSecond:n.videoSecond,videoSize:n.videoSize,videoUrl:n.videoUrl,videoDownloadFlag:n.videoDownloadFlag,uuid:n.uuid,thumbSize:n.thumbSize,thumbWidth:n.thumbWidth,thumbHeight:n.thumbHeight,thumbDownloadFlag:n.thumbDownloadFlag,thumbUrl:n.thumbUrl}},oo=function(){function e(n){r(this,e),this.ID="",this.conversationID=n.conversationID||null,this.conversationType=n.conversationType||t.CONV_C2C,this.conversationSubType=n.conversationSubType,this.time=n.time||Math.ceil(Date.now()/1e3),this.sequence=n.sequence||0,this.clientSequence=n.clientSequence||n.sequence||0,this.random=n.random||pe(),this.messagePriority=n.messagePriority||0,this._elements=[],this.isPlaceMessage=0,this.geo={},this.from=n.from||null,this.to=n.to||null,this.flow="",this.isSystemMessage=n.isSystemMessage||0,this.protocol=n.protocol||"JSON",this.isResend=0,this.isRead=0,this.status=n.status||He.MESSAGE_STATUS.SUCCESS,this._error=0,this._errorInfo="",this.reInitialize(n.currentUser),this.extractGroupInfo(n.groupProfile||null)}return i(e,[{key:"getElements",value:function(){return this._elements}},{key:"setError",value:function(e,t){"number"==typeof e&&(this._error=e),this._errorInfo=t||"message elements error!"}},{key:"extractGroupInfo",value:function(e){if(null!==e){var t=e.messageFromAccountExtraInformation;this.nick="","string"==typeof e.fromAccountNick&&(this.nick=e.fromAccountNick),this.avatar="","string"==typeof e.fromAccountHeadurl&&(this.avatar=e.fromAccountHeadurl),this.nameCard="","object"===n(t)&&t.hasOwnProperty("nameCard")&&(this.nameCard=t.nameCard)}}},{key:"isError",value:function(){return 0===this._error?0:1}},{key:"getIMError",value:function(){return new Ce({code:this._error,message:this._errorInfo})}},{key:"_initProxy",value:function(){this.payload=this._elements[0].content,this.type=this._elements[0].type}},{key:"afterOperated",value:function(e){this._onOperatedHandle=null,"function"==typeof e&&(this._onOperatedHandle=e),1==this.isSendable()&&this.triggerOperated()}},{key:"triggerOperated",value:function(){null!==this._onOperatedHandle&&"function"==typeof this._onOperatedHandle&&this._onOperatedHandle(this)}},{key:"reInitialize",value:function(e){e&&(this.status=this.from?He.MESSAGE_STATUS.SUCCESS:He.MESSAGE_STATUS.UNSEND,!this.from&&(this.from=e),this.isRead=1),this._initFlow(e),this._initielizeSequence(e),this._concactConversationID(e),this.generateMessageID(e)}},{key:"isSendable",value:function(){return 0===this._elements.length?0:"function"!=typeof this._elements[0].isEmpty?(Q.warn("".concat(this._elements[0].type,' need "boolean : isEmpty()" method')),0):1==this._elements[0].isEmpty()?0:1}},{key:"_initTo",value:function(e){this.conversationType===t.CONV_GROUP&&(this.to=e.groupID)}},{key:"_initielizeSequence",value:function(e){0===this.clientSequence&&e&&(this.clientSequence=function(e){if(!e)return Q.error("autoincrementIndex(string: key) need key parameter"),0;if(void 0===ge[e]){var t=new Date,n="3".concat(t.getHours()).slice(-2),r="0".concat(t.getMinutes()).slice(-2),o="0".concat(t.getSeconds()).slice(-2);ge[e]=parseInt([n,r,o,"0001"].join("")),n=null,r=null,o=null,Q.warn("utils.autoincrementIndex() create new sequence : ".concat(e," = ").concat(ge[e]))}return ge[e]++}(e)),0===this.sequence&&this.conversationType===t.CONV_C2C&&(this.sequence=this.clientSequence)}},{key:"generateMessageID",value:function(e){var t=e===this.from?1:0,n=this.sequence>0?this.sequence:this.clientSequence;this.ID="".concat(this.conversationID,"-").concat(n,"-").concat(this.random,"-").concat(t)}},{key:"_initFlow",value:function(e){""!==e&&(this.flow=e===this.from?"out":"in")}},{key:"_concactConversationID",value:function(e){var n=this.to,r="",o=this.conversationType;o!==t.CONV_SYSTEM?(r=o===t.CONV_C2C?e===this.from?n:this.from:this.to,this.conversationID="".concat(o).concat(r)):this.conversationID=t.CONV_SYSTEM}},{key:"isElement",value:function(e){return e instanceof zr||e instanceof Wr||e instanceof Xr||e instanceof Jr||e instanceof to||e instanceof Zr||e instanceof eo||e instanceof no}},{key:"setElement",value:function(e){var n=this;if(this.isElement(e))return this._elements=[e],void this._initProxy();var r=function(e){switch(e.type){case t.MSG_TEXT:n.setTextElement(e.content);break;case t.MSG_IMAGE:n.setImageElement(e.content);break;case t.MSG_AUDIO:n.setAudioElement(e.content);break;case t.MSG_FILE:n.setFileElement(e.content);break;case t.MSG_VIDEO:n.setVideoElement(e.content);break;case t.MSG_CUSTOM:n.setCustomElement(e.content);break;case t.MSG_GEO:n.setGEOElement(e.content);break;case t.MSG_GRP_TIP:n.setGroupTipElement(e.content);break;case t.MSG_GRP_SYS_NOTICE:n.setGroupSystemNoticeElement(e.content);break;case t.MSG_FACE:n.setFaceElement(e.content);break;default:Q.warn(e.type,e.content,"no operation......")}};if(Array.isArray(e))for(var o=0;o<e.length;o++)r(e[o]);else r(e);this._initProxy()}},{key:"setTextElement",value:function(e){var t="string"==typeof e?e:e.text,n=new zr({text:t});this._elements.push(n)}},{key:"setImageElement",value:function(e){var t=new Wr(e);this._elements.push(t)}},{key:"setAudioElement",value:function(e){var t=new Jr(e);this._elements.push(t)}},{key:"setFileElement",value:function(e){var t=new to(e);this._elements.push(t)}},{key:"setVideoElement",value:function(e){var t=new ro(e);this._elements.push(t)}},{key:"setGEOElement",value:function(e){}},{key:"setCustomElement",value:function(e){var t=new no(e);this._elements.push(t)}},{key:"setGroupTipElement",value:function(e){var t=new Zr(e);this._elements.push(t)}},{key:"setGroupSystemNoticeElement",value:function(e){var t=new eo(e);this._elements.push(t)}},{key:"setFaceElement",value:function(e){var t=new Xr(e);this._elements.push(t)}},{key:"elements",get:function(){return Q.warn("！！！此属性即将废弃，请尽快修改。使用 type 和 payload 属性处理单条消息，兼容组合消息使用 _elements 属性！！！"),this._elements}}]),e}(),io=["groupID","name","avatar","type","introduction","notification","ownerID","selfInfo","createTime","infoSequence","lastInfoTime","lastMessage","nextMessageSeq","memberNum","maxMemberNum","memberList","joinOption","groupCustomField"],ao=function(){function e(t){r(this,e),this.groupID="",this.name="",this.avatar="",this.type="",this.introduction="",this.notification="",this.ownerID="",this.createTime="",this.infoSequence="",this.lastInfoTime="",this.selfInfo={messageRemindType:"",joinTime:"",nameCard:"",role:""},this.lastMessage={lastTime:"",lastSequence:"",fromAccount:"",messageForShow:""},this.nextMessageSeq="",this.memberNum="",this.maxMemberNum="",this.joinOption="",this.groupCustomField=[],this._initGroup(t)}return i(e,[{key:"_initGroup",value:function(e){for(var t in e)io.indexOf(t)<0||(this[t]=e[t])}},{key:"updateGroup",value:function(e){e.lastMsgTime&&(this.lastMessage.lastTime=e.lastMsgTime),ue(this,e,["members","errorCode","lastMsgTime"])}}]),e}(),so=function(e,n){if(ne(n))return"";switch(e){case t.MSG_TEXT:return n.text;case t.MSG_IMAGE:return"[图片]";case t.MSG_GEO:return"[位置]";case t.MSG_AUDIO:return"[语音]";case t.MSG_VIDEO:return"[视频]";case t.MSG_FILE:return"[文件]";case t.MSG_CUSTOM:return"[自定义消息]";case t.MSG_GRP_TIP:return"[群提示消息]";case t.MSG_GRP_SYS_NOTICE:return"[群系统通知]";default:return""}},uo=function(e){return ne(e)?{lastTime:0,lastSequence:0,fromAccount:0,messageForShow:"",payload:null,type:""}:e instanceof oo?{lastTime:e.time||0,lastSequence:e.sequence||0,fromAccount:e.from||"",messageForShow:so(e.type,e.payload),payload:e.payload||null,type:e.type||null}:u({},e,{messageForShow:so(e.type,e.payload)})},co=function(){function e(t){r(this,e),this.conversationID=t.conversationID||"",this.unreadCount=t.unreadCount||0,this.type=t.type||"",this.subType=t.subType||"",this.lastMessage=uo(t.lastMessage),this._isInfoCompleted=0,this._initProfile(t)}return i(e,[{key:"_initProfile",value:function(e){var n=this;Object.keys(e).forEach(function(t){switch(t){case"userProfile":n.userProfile=e.userProfile;break;case"groupProfile":n.groupProfile=e.groupProfile}}),ne(this.userProfile)&&this.type===t.CONV_C2C?this.userProfile=new Fr({userID:e.conversationID.replace("C2C","")}):ne(this.groupProfile)&&this.type===t.CONV_GROUP&&(this.groupProfile=new ao({groupID:e.conversationID.replace("GROUP","")}))}},{key:"toAccount",get:function(){return this.conversationID.replace("C2C","").replace("GROUP","")}}]),e}(),lo=function(n){function o(e){var t;return r(this,o),(t=g(this,l(o).call(this,e))).conversationMap=new Map,t.hasLocalConversationList=0,t.tempGroupList=[],t._initListeners(),t}return c(o,Fe),i(o,[{key:"createLocalConversation",value:function(e){return this.conversationMap.has(e)?this.conversationMap.get(e):new co({conversationID:e,type:e.slice(0,3)===t.CONV_C2C?t.CONV_C2C:t.CONV_GROUP})}},{key:"hasLocalConversation",value:function(e){return this.conversationMap.has(e)}},{key:"getConversationList",value:function(){var e=this,t=arguments.length>0&&void 0!==arguments[0]?arguments[0]:0,n=!t,r=this.createPackage({name:"conversation",action:"query"});return Q.log("ConversationController.getConversationList."),this.tim.connectionController.request(r).then(function(r){var o=r.data.conversations,i=void 0===o?[]:o,a=e._getConversationOptions(i);return t&&e._conversationMapTreeShaking(a),e._updateLocalConversationList(a,1),e._setStorageConversationList(),e.tempGroupList.length>0&&(e._onUpdateConversationGroupProfile(e.tempGroupList),e.tempGroupList=[]),e._isReady&&e._emitConversationUpdate(n),e.triggerReady(),Q.log("ConversationController.getConversationList ok."),pt({conversationList:e.getLocalConversationList()})}).catch(function(e){return Q.error("ConversationController.getConversationList error:",e),ht(e)})}},{key:"getConversationProfile",value:function(e){var n=this.conversationMap.has(e)?this.conversationMap.get(e):this.createLocalConversation(e);return n._isInfoCompleted||n.type===t.CONV_SYSTEM?pt({conversation:n}):(Q.log("ConversationController.getConversationProfile. conversationID:",e),this._updateUserOrGroupProfileCompletely(n).then(function(t){return Q.log("ConversationController.getConversationProfile ok. conversationID:",e),t}).catch(function(e){return Q.error("ConversationController.getConversationProfile error:",e),ht(e,1)}))}},{key:"deleteConversation",value:function(e){var n=this,r={};if(!this.conversationMap.has(e)){var o=new Ce({code:Ie.CONVERSATION_NOT_FOUND,message:Se.CONVERSATION_NOT_FOUND});return ht(o)}switch(this.conversationMap.get(e).type){case t.CONV_C2C:r.type=1,r.toAccount=e.slice(3);break;case t.CONV_GROUP:r.type=2,r.toGroupID=e.slice(5);break;case t.CONV_SYSTEM:return this.tim.groupController.deleteGroupSystemNotice({messageList:this.tim.messageController.getLocalMessageList(e)}),this._deleteLocalConversation(e),pt({conversationID:e});default:var i=new Ce({code:Ie.CONVERSATION_UN_RECORDED_TYPE,message:Se.CONVERSATION_UN_RECORDED_TYPE});return ht(i)}Q.log("ConversationController.deleteConversation. conversationID:",e);var a=this.createPackage({name:"conversation",action:"delete",param:r});return this.tim.setMessageRead({conversationID:e}).then(function(){return n.connectionController.request(a)}).then(function(){return Q.log("ConversationController.deleteConversation ok. conversationID:",e),n._deleteLocalConversation(e),pt({conversationID:e})}).catch(function(e){return Q.error("ConversationController.deleteConversation error:",e),ht(e,1)})}},{key:"getLocalConversationList",value:function(){return m(this.conversationMap.values())}},{key:"getLocalConversation",value:function(e){return this.conversationMap.get(e)}},{key:"_initLocalConversationList",value:function(){Q.time(gt),Q.log("ConversationController._initLocalConversationList init");var e=this._getStorageConversationList();if(this.hasLocalConversationList=null!==e&&0!==e.length,this.hasLocalConversationList){for(var t=0,n=e.length;t<n;t++)this.conversationMap.set(e[t].conversationID,new co(e[t]));this._emitConversationUpdate(1,0)}this.getConversationList(1).then(function(){Q.log("ConversationController._initLocalConversationList init ok. initCost=".concat(Q.timeEnd(gt),"ms"))})}},{key:"_getStorageConversationList",value:function(){return this.tim.storage.getItem("conversationMap")}},{key:"_setStorageConversationList",value:function(){var e=[];this.conversationMap.forEach(function(t){var n=t.conversationID,r=t.type,o=t.subType,i=t.lastMessage,a=t.groupProfile,s=t.userProfile;e.push({conversationID:n,type:r,subType:o,lastMessage:i,groupProfile:a,userProfile:s})}),this.tim.storage.setItem("conversationMap",e)}},{key:"_initListeners",value:function(){this.tim.innerEmitter.once(Re.CONTEXT_A2KEY_AND_TINYID_UPDATED,this._initLocalConversationList,this),this.tim.innerEmitter.on(Re.MESSAGE_SENDING,this._onSendOrReceiveMessage,this),this.tim.innerEmitter.on(Re.MESSAGE_SENDINGSEND_SUCCESS,this._onSendOrReceiveMessage,this),this.tim.innerEmitter.on(Re.MESSAGE_GROUP_SEND_SUCCESS,this._onSendOrReceiveMessage,this),this.tim.innerEmitter.on(Re.MESSAGE_SYNC_PROCESSING,this._handleSyncMessages,this),this.tim.innerEmitter.on(Re.MESSAGE_SYNC_FINISHED,this._handleSyncMessages,this),this.tim.innerEmitter.on(Re.MESSAGE_C2C_INSTANT_RECEIVED,this._onSendOrReceiveMessage,this),this.tim.innerEmitter.on(Re.MESSAGE_GROUP_INSTANT_RECEIVED,this._onSendOrReceiveMessage,this),this.tim.innerEmitter.on(Re.MESSAGE_GROUP_SYSTEM_NOTICE_RECEIVED,this._onSendOrReceiveMessage,this),this.tim.innerEmitter.on(Re.GROUP_LIST_UPDATED,this._onUpdateConversationGroupProfile,this),this.tim.innerEmitter.on(Re.PROFILE_UPDATED,this._onUpdateConversationUserProfile,this)}},{key:"_onUpdateConversationGroupProfile",value:function(e){var t=this;this.hasLocalConversationList||(this.tempGroupList=e),e.forEach(function(e){var n="GROUP".concat(e.groupID);if(t.conversationMap.has(n)){var r=t.conversationMap.get(n);r.groupProfile=e,r.lastMessage.lastSequence=e.nextMessageSeq-1,r.subType||(r.subType=e.type)}}),this._emitConversationUpdate(1,0)}},{key:"_onUpdateConversationUserProfile",value:function(e){var t=this;e.data.forEach(function(e){var n="C2C".concat(e.userID);t.conversationMap.has(n)&&(t.conversationMap.get(n).userProfile=e)}),this._emitConversationUpdate(1,0)}},{key:"_handleSyncMessages",value:function(e){this._onSendOrReceiveMessage(e,1)}},{key:"_onSendOrReceiveMessage",value:function(e){var t=this,n=arguments.length>1&&void 0!==arguments[1]?arguments[1]:0,r=e.data.eventDataList;this._isReady?0!==r.length&&(this._updateLocalConversationList(r,0,n),this._setStorageConversationList(),this._emitConversationUpdate()):this.ready(function(){t._onSendOrReceiveMessage(e,n)})}},{key:"_updateLocalConversationList",value:function(e,t,n){var r;r=this._updateTempConversations(e,t,n),this.conversationMap=new Map(this._sortConversations([].concat(m(r.conversations),m(this.conversationMap)))),this._updateUserOrGroupProfile(r.newerConversations)}},{key:"_updateTempConversations",value:function(e,t,n){for(var r=[],o=[],i=0,a=e.length;i<a;i++){var s=new co(e[i]),u=this.conversationMap.get(s.conversationID);if(this.conversationMap.has(s.conversationID)){var c=["unreadCount","allowType","adminForbidType","payload"];n&&c.push("lastMessage"),ue(u,s,c,[null,void 0,"",0,NaN]),u.unreadCount=this._updateUnreadCount(u,s,t),n||(u.lastMessage.payload=e[i].lastMessage.payload),this.conversationMap.delete(u.conversationID),r.push([u.conversationID,u])}else o.push(s),r.push([s.conversationID,s])}return{conversations:r,newerConversations:o}}},{key:"_updateUnreadCount",value:function(e,n,r){if([t.GRP_CHATROOM,t.GRP_AVCHATROOM].includes(e.subType))return 0;if(r){if(e.type===t.CONV_C2C)return e.unreadCount;if(e.type===t.CONV_GROUP)return n.unreadCount}return n.unreadCount+e.unreadCount}},{key:"_sortConversations",value:function(e){return e.sort(function(e,t){return t[1].lastMessage.lastTime-e[1].lastMessage.lastTime})}},{key:"_updateUserOrGroupProfile",value:function(e){var n=this,r=[],o=[];return e.forEach(function(e){if(e.type===t.CONV_C2C)r.push(e.toAccount);else if(e.type===t.CONV_GROUP){var i=e.toAccount;n.tim.groupController.hasLocalGroup(i)?e.groupProfile=n.tim.groupController.getLocalGroupProfile(i):o.push(i)}}),r.length>0?this.tim.getUserProfile({userIDList:r}).then(function(e){var t=e.data;te(t)?t.forEach(function(e){n.conversationMap.get("C2C".concat(e.userID)).userProfile=e}):n.conversationMap.get("C2C".concat(t.userID)).userProfile=t}):o.length>0?this.tim.groupController.getGroupProfileAdvance({groupIDList:o,responseFilter:{groupBaseInfoFilter:["Type","Name","FaceUrl"]}}).then(function(e){e.data.successGroupList.forEach(function(e){var t="GROUP".concat(e.groupID);if(n.conversationMap.has(t)){var r=n.conversationMap.get(t);ue(r.groupProfile,e,[],[null,void 0,"",0,NaN]),!r.subType&&e.type&&(r.subType=e.type)}})}):void 0}},{key:"_updateUserOrGroupProfileCompletely",value:function(e){var n=this;return e.type===t.CONV_C2C?this.tim.getUserProfile({userIDList:[e.toAccount]}).then(function(t){var r=t.data;return 0===r.length?ht(new Ce({code:Ie.USER_OR_GROUP_NOT_FOUND,message:Se.USER_OR_GROUP_NOT_FOUND})):(e.userProfile=r[0],e._isInfoCompleted=1,n._unshiftConversation(e),pt({conversation:e}))}):this.tim.getGroupProfile({groupID:e.toAccount}).then(function(t){return e.groupProfile=t.data.group,e._isInfoCompleted=1,n._unshiftConversation(e),pt({conversation:e})})}},{key:"_unshiftConversation",value:function(e){e instanceof co&&!this.conversationMap.has(e.conversationID)&&(this.conversationMap=new Map([[e.conversationID,e]].concat(m(this.conversationMap))),this._setStorageConversationList(),this._emitConversationUpdate(1,0))}},{key:"_deleteLocalConversation",value:function(e){return this.conversationMap.delete(e),this._setStorageConversationList(),this.tim.innerEmitter.emit(Re.CONVERSATION_DELETED,e),this._emitConversationUpdate(1,0),this.conversationMap.has(e)}},{key:"_getConversationOptions",value:function(e){var t=[],n=e.map(function(e){if(1===e.type){var n={userID:e.userID,nick:e.c2CNick,avatar:e.c2CImage};return t.push(n),{conversationID:"C2C".concat(e.userID),type:"C2C",lastMessage:{lastTime:e.time,lastSequence:e.sequence,fromAccount:e.lastC2CMsgFromAccount,messageForShow:e.messageShow,type:e.lastMsg.elements[0]?e.lastMsg.elements[0].type:null,payload:e.lastMsg.elements[0]?e.lastMsg.elements[0].content:null},userProfile:new Fr(n)}}return{conversationID:"GROUP".concat(e.groupID),type:"GROUP",lastMessage:{lastTime:e.time,lastSequence:e.messageReadSeq+e.unreadCount,fromAccount:e.msgGroupFromAccount,messageForShow:e.messageShow,type:e.lastMsg.elements[0]?e.lastMsg.elements[0].type:null,payload:e.lastMsg.elements[0]?e.lastMsg.elements[0].content:null},groupProfile:new ao({groupID:e.groupID,name:e.groupNick,avatar:e.groupImage}),unreadCount:e.unreadCount}});return t.length>0&&this.tim.innerEmitter.emit(Re.CONVERSATION_LIST_PROFILE_UPDATED,{data:t}),n}},{key:"_emitConversationUpdate",value:function(){var t=arguments.length>0&&void 0!==arguments[0]?arguments[0]:1,n=arguments.length>1&&void 0!==arguments[1]?arguments[1]:1,r=m(this.conversationMap.values());n&&this.tim.innerEmitter.emit(Re.CONVERSATION_LIST_UPDATED,r),t&&this.tim.outerEmitter.emit(e.CONVERSATION_LIST_UPDATED,r)}},{key:"_conversationMapTreeShaking",value:function(e){var n=this,r=new Map(m(this.conversationMap));e.forEach(function(e){return r.delete(e.conversationID)}),r.has(t.CONV_SYSTEM)&&r.delete(t.CONV_SYSTEM),this.tim.groupController.AVChatRoomHandler.isJoined&&r.delete("".concat(t.CONV_GROUP).concat(this.tim.groupController.AVChatRoomHandler.group.groupID)),m(r.keys()).forEach(function(e){return n.conversationMap.delete(e)})}},{key:"reset",value:function(){this.conversationMap.clear(),this.hasLocalConversationList=0,this.resetReady(),this.tim.innerEmitter.once(Re.CONTEXT_A2KEY_AND_TINYID_UPDATED,this._initLocalConversationList,this)}}]),o}(),po=function(){function e(t){if(r(this,e),void 0===t)throw new Ce({code:Ie.MESSAGE_LIST_CONSTRUCTOR_NEED_OPTIONS,message:Se.MESSAGE_LIST_CONSTRUCTOR_NEED_OPTIONS});if(void 0===t.tim)throw new Ce({code:Ie.MESSAGE_LIST_CONSTRUCTOR_NEED_OPTIONS,message:"".concat(Se.MESSAGE_LIST_CONSTRUCTOR_NEED_OPTIONS,".tim")});this.list=new Map,this.tim=t.tim,this._initializeOptions(t)}return i(e,[{key:"getLocalOldestMessageByConversationID",value:function(e){if(!e)return null;if(!this.list.has(e))return null;var t=this.list.get(e).values();return t?t.next().value:null}},{key:"_initializeOptions",value:function(e){this.options={};var t={memory:{maxDatasPerKey:100,maxBytesPerData:256,maxKeys:0},cache:{maxDatasPerKey:10,maxBytesPerData:256,maxKeys:0}};for(var n in t)if(Object.prototype.hasOwnProperty.call(t,n)){if(void 0===e[n]){this.options[n]=t[n];continue}var r=t[n];for(var o in r)if(Object.prototype.hasOwnProperty.call(r,o)){if(void 0===e[n][o]){this.options[n][o]=r[o];continue}this.options[n][o]=e[n][o]}}}},{key:"_parseMessageFormLikeKeyValue",value:function(e){return[e.conversationID,e]}},{key:"pushIn",value:function(e){var t=this._parseMessageFormLikeKeyValue(e),n=0;return void 0===this.list.get(t[0])&&this.list.set(t[0],new Map),this.list.has(e.conversationID)&&this.list.get(e.conversationID).has(t[1].ID)&&(n=1),this.list.get(t[0]).set(t[1].ID,t[1]),n?null:e}},{key:"shiftIn",value:function(e){Array.isArray(e)?0!==e.length&&this._shiftInMultipleMessages(e):this._shiftSingleMessage(e)}},{key:"_shiftSingleMessage",value:function(e){var t=this._parseMessageFormLikeKeyValue(e);if(void 0===this.list.get(t[0]))return this.list.set(t[0],new Map),void this.list.get(t[0]).set(t[1].ID,t[1]);var n=Array.from(this.list.get(t[0]));n.unshift([t[1].ID,t[1]]),this.list.set(t[0],new Map(n))}},{key:"_shiftInMultipleMessages",value:function(e){for(var t=e.length,n=[],r=e[0].conversationID,o=this.list.has(r)?Array.from(this.list.get(r)):[],i=0;i<t;i++)n.push([e[i].ID,e[i]]);this.list.set(r,new Map(n.concat(o)))}},{key:"remove",value:function(e){var t=e.conversationID,n=e.ID;this.list.get(t).delete(n)}},{key:"removeByConversationID",value:function(e){this.list.has(e)&&this.list.delete(e)}},{key:"hasLocalMessageList",value:function(e){return this.list.has(e)}},{key:"getLocalMessageList",value:function(e){return this.hasLocalMessageList(e)?m(this.list.get(e).values()):[]}},{key:"hasLocalMessage",value:function(e,t){return this.hasLocalMessageList(e)?this.list.get(e).has(t):0}},{key:"getLocalMessage",value:function(e,t){return this.hasLocalMessage(e,t)?this.list.get(e).get(t):null}},{key:"reset",value:function(){this.list.clear()}}]),e}(),ho=function(){function e(t){r(this,e),this.tim=t}return i(e,[{key:"setMessageRead",value:function(e){var n=e.conversationID,r=e.messageID,o=this.tim.conversationController.getLocalConversation(n);if(!o||0===o.unreadCount)return pt();var i=r?this.tim.messageController.getLocalMessage(n,r):null;switch(o.type){case t.CONV_C2C:return this._setC2CMessageRead({conversationID:n,lastMessageTime:i?i.time:o.lastMessage.lastTime});case t.CONV_GROUP:return this._setGroupMessageRead({conversationID:n,lastMessageSeq:i?i.sequence:o.lastMessage.lastSequence});case t.CONV_SYSTEM:return o.unreadCount=0,pt();default:return pt()}}},{key:"_setC2CMessageRead",value:function(e){var t=this,n=e.conversationID,r=e.lastMessageTime,o=this.tim.messageController.createPackage({name:"conversation",action:"setC2CMessageRead",param:{C2CMsgReaded:{cookie:"",C2CMsgReadedItem:[{toAccount:n.replace("C2C",""),lastMessageTime:r}]}}});return this._updateIsReadAfterReadReport({conversationID:n,lastMessageTime:r}),this._updateUnreadCount(n),this.tim.connectionController.request(o).then(function(){return new ut}).catch(function(e){return t.tim.innerEmitter.emit(Re.ERROR_DETECTED,e),Promise.reject(new ut(e))})}},{key:"_setGroupMessageRead",value:function(e){var t=this,n=e.conversationID,r=e.lastMessageSeq,o=this.tim.messageController.createPackage({name:"conversation",action:"setGroupMessageRead",param:{groupID:n.replace("GROUP",""),messageReadSeq:r}});return this._updateIsReadAfterReadReport({conversationID:n,lastMessageSeq:r}),this._updateUnreadCount(n),this.tim.connectionController.request(o).then(function(){return new ut}).catch(function(e){return t.tim.innerEmitter.emit(Re.ERROR_DETECTED,e),Promise.reject(new ut(e))})}},{key:"_updateUnreadCount",value:function(e){var t=this.tim,n=t.conversationController,r=t.messageController,o=n.getLocalConversation(e),i=r.getLocalMessageList(e);o&&(o.unreadCount=i.filter(function(e){return!e.isRead}).length)}},{key:"_updateIsReadAfterReadReport",value:function(e){var t=e.conversationID,n=e.lastMessageSeq,r=e.lastMessageTime,o=this.tim.messageController.getLocalMessageList(t);if(0!==o.length)for(var i=o.length-1;i>=0;i--){var a=o[i];if(!(r&&a.time>r||n&&a.sequence>n)){if("in"===a.flow&&a.isRead)break;a.isRead=1}}}},{key:"updateIsRead",value:function(e){var n=this.tim,r=n.conversationController,o=n.messageController,i=r.getLocalConversation(e),a=o.getLocalMessageList(e);if(i&&0!==a.length&&[t.CONV_C2C,t.CONV_GROUP].includes(i.type))for(var s=0;s<a.length-i.unreadCount&&!a[s].isRead;s++)a[s].isRead=1}}]),e}(),fo=function(){function e(t){var n=t.tim,o=t.messageController;r(this,e),this.tim=n,this.messageController=o,this.completedMap=new Map,this._initListener()}return i(e,[{key:"getMessageList",value:function(e){var t=this,n=e.conversationID,r=e.nextReqMessageID,o=e.count;(ne(o)||o>15)&&(o=15);var i=this._computeLeftCount({conversationID:n,nextReqMessageID:r});return this._needGetHistory({conversationID:n,leftCount:i,count:o})?this.messageController.getHistoryMessages({conversationID:n,count:20}).then(function(){return i=t._computeLeftCount({conversationID:n,nextReqMessageID:r}),new ut(t._computeResult({conversationID:n,nextReqMessageID:r,count:o,leftCount:i}))}):pt(this._computeResult({conversationID:n,nextReqMessageID:r,count:o,leftCount:i}))}},{key:"setCompleted",value:function(e){this.completedMap.set(e,1)}},{key:"deleteCompletedItem",value:function(e){this.completedMap.delete(e)}},{key:"_initListener",value:function(){var e=this;this.tim.innerEmitter.on(Re.SDK_READY,function(){e.completedMap.set(t.CONV_SYSTEM,1)}),this.tim.innerEmitter.on(Re.AVCHATROOM_JOIN_SUCCESS,function(n){var r=n.data;e.completedMap.set("".concat(t.CONV_GROUP).concat(r),1)})}},{key:"_getMessageListSize",value:function(e){return this.messageController.getLocalMessageList(e).length}},{key:"_needGetHistory",value:function(e){var n=e.conversationID,r=e.leftCount,o=e.count,i=this.tim.conversationController.getLocalConversation(n),a=i?i.type===t.CONV_SYSTEM:0,s=i?i.subType===t.GRP_AVCHATROOM:0;return a||s?0:r<o&&!this.completedMap.has(n)}},{key:"_computeResult",value:function(e){var t=e.conversationID,n=e.nextReqMessageID,r=e.count,o=e.leftCount,i=this._computeMessageList({conversationID:t,nextReqMessageID:n,count:r}),a=this._computeIsCompleted({conversationID:t,leftCount:o,count:r});return{messageList:i,nextReqMessageID:this._computeNextReqMessageID({messageList:i,isCompleted:a,conversationID:t}),isCompleted:a}}},{key:"_computeNextReqMessageID",value:function(e){var t=e.messageList,n=e.isCompleted,r=e.conversationID;if(!n)return 0===t.length?"":t[0].ID;var o=this.messageController.getLocalMessageList(r);return 0===o.length?"":o[0].ID}},{key:"_computeMessageList",value:function(e){var t=e.conversationID,n=e.nextReqMessageID,r=e.count,o=this.messageController.getLocalMessageList(t),i=this._computeIndexEnd({nextReqMessageID:n,messageList:o}),a=this._computeIndexStart({indexEnd:i,count:r});return o.slice(a,i)}},{key:"_computeIndexEnd",value:function(e){var t=e.messageList,n=void 0===t?[]:t,r=e.nextReqMessageID;return r?n.findIndex(function(e){return e.ID===r}):n.length}},{key:"_computeIndexStart",value:function(e){var t=e.indexEnd,n=e.count;return t>n?t-n:0}},{key:"_computeLeftCount",value:function(e){var t=e.conversationID,n=e.nextReqMessageID;return n?this.messageController.getLocalMessageList(t).findIndex(function(e){return e.ID===n}):this._getMessageListSize(t)}},{key:"_computeIsCompleted",value:function(e){var t=e.conversationID;return e.leftCount<=e.count&&this.completedMap.has(t)?1:0}},{key:"reset",value:function(){this.completedMap.clear()}}]),e}(),_o=function(){function e(t,n){r(this,e),this.options=n||{enablePointer:1},this.taskName=t||["task",this._timeFormat()].join("-"),this.pointsList=[],this.reportText="",this.gapChar="…",this.currentTask=""}return i(e,[{key:"dot",value:function(e){if("string"==typeof e)if(0!==e.length){var t=Date.now();this.pointsList.push({pointerName:e,time:t})}else Q.error("PointerTask.dot(pointerName), need param: pointerName");else Q.error("PointerTask.dot(pointerName), pointerName must be string")}},{key:"_analisys",value:function(){for(var e=this.pointsList,t=e.length,n=[],r=[],o=0;o<t;o++)0!==o&&(r=this._analisysTowPoints(e[o-1],e[o]),n.push(r.join("")));return r=this._analisysTowPoints(e[0],e[t-1],1),n.push(r.join("")),n.join("")}},{key:"_analisysTowPoints",value:function(e,t){var n=(t.time-e.time).toString();return["(",e.pointerName,")->(",t.pointerName,")=",n,"ms;"]}},{key:"report",value:function(){0!=this.options.enablePointer&&Q.log(this.reportString())}},{key:"reportString",value:function(){return 1==!!this.reportText?this.reportText:0===this.pointsList.length?"":(this.reportText="".concat(this.taskName," report：").concat(this._analisys()),this.reportText)}},{key:"_timeFormat",value:function(){var e=new Date,t=this.zeroFix(e.getMonth()+1,2),n=this.zeroFix(e.getDate(),2);return"".concat(t,"-").concat(n," ").concat(e.getHours(),":").concat(e.getSeconds(),":").concat(e.getMinutes(),".").concat(e.getMilliseconds())}},{key:"zeroFix",value:function(e,t){return Number.isInteger(t)?t<0?(Q.error('PointerTask.zeroFix(num, length); param "length" must greater then zero'),""):("000000000"+e).slice(t=1+~t):(Q.error('PointerTask.zeroFix(num, length); param "length" should be an integer'),"")}}]),e}(),go=function(e,t){return new _o(e,t)},mo=function e(t){r(this,e),this.value=t,this.next=null},Eo=function(){function e(t){r(this,e),this.MAX_LENGTH=t,this.pTail=null,this.pNodeToDel=null,this.map=new Map,Q.log("SinglyLinkedList init MAX_LENGTH=".concat(this.MAX_LENGTH))}return i(e,[{key:"pushIn",value:function(e){var t=new mo(e);if(this.map.size<this.MAX_LENGTH)null===this.pTail?(this.pTail=t,this.pNodeToDel=t):(this.pTail.next=t,this.pTail=t),this.map.set(e,1);else{var n=this.pNodeToDel;this.pNodeToDel=this.pNodeToDel.next,this.map.delete(n.value),n.next=null,n=null,this.pTail.next=t,this.pTail=t,this.map.set(e,1)}}},{key:"has",value:function(e){return this.map.has(e)}},{key:"reset",value:function(){for(var e;null!==this.pNodeToDel;)e=this.pNodeToDel,this.pNodeToDel=this.pNodeToDel.next,e.next=null,e=null;this.pTail=null,this.map.clear()}}]),e}(),yo=function(n){function o(e){var t;return r(this,o),(t=g(this,l(o).call(this,e)))._initializeMembers(),t._initializeListener(),t._initialzeHandlers(),t}return c(o,Fe),i(o,[{key:"_initializeMembers",value:function(){this.messagesList=new po({tim:this.tim}),this.currentMessageKey={},this.singlyLinkedList=new Eo(100)}},{key:"_initialzeHandlers",value:function(){this.readReportHandler=new ho(this.tim),this.getMessageHandler=new fo({messageController:this,tim:this.tim})}},{key:"reset",value:function(){this.messagesList.reset(),this.currentMessageKey={},this.getMessageHandler.reset(),this.singlyLinkedList.reset()}},{key:"_initializeListener",value:function(){var e=this.tim.innerEmitter;e.on(Re.NOTICE_LONGPOLL_NEW_C2C_NOTICE,this._onReceiveC2CMessage,this),e.on(Re.SYNC_MESSAGE_C2C_PROCESSING,this._onSyncMessagesProcessing,this),e.on(Re.SYNC_MESSAGE_C2C_FINISHED,this._onSyncMessagesFinished,this),e.on(Re.NOTICE_LONGPOLL_NEW_GROUP_MESSAGES,this._onReceiveGroupMessage,this),e.on(Re.NOTICE_LONGPOLL_NEW_GROUP_TIPS,this._onReceiveGroupTips,this),e.on(Re.NOTICE_LONGPOLL_NEW_GROUP_NOTICE,this._onReceiveSystemNotice,this),e.on(Re.CONVERSATION_DELETED,this._clearConversationMessages,this)}},{key:"sendMessageInstance",value:function(e){var n=this,r=go("MessageController.sendMessageInstance(), ".concat(e.ID),this.tim.options),o=this.tim.innerEmitter;if(1==e.isError()){r.dot("message error"),r.report();var i=e.getIMError();return this._onSendMessageFailed(e,i),ht(i)}if(0==e.isSendable()){r.dot("message unsendable"),r.report();var a=new Ce({code:Ie.MESSAGE_FILE_IS_EMPTY,message:Se.MESSAGE_FILE_IS_EMPTY});return this._onSendMessageFailed(e,a),ht(a)}var s=null,u=null;switch(r.dot("innerEmitter ".concat(Re.MESSAGE_SENDING)),o.emit(Re.MESSAGE_SENDING,{data:{eventDataList:[{conversationID:e.conversationID,unreadCount:0,type:e.conversationType,subType:e.conversationSubType,lastMessage:e}]}}),r.dot("init handles ".concat(e.conversationType)),e.conversationType){case t.CONV_C2C:s=this._createC2CMessagePack(e),u=this._handleOnSendC2CMessageSuccess.bind(this);break;case t.CONV_GROUP:s=this._createGroupMessagePack(e),u=this._handleOnSendGroupMessageSuccess.bind(this);break;default:return r.dot("error ".concat(e.conversationType)),r.report(),ht(new Ce({code:Ie.MESSAGE_SEND_INVALID_CONVERSATION_TYPE,message:Se.MESSAGE_SEND_INVALID_CONVERSATION_TYPE}))}return this.singlyLinkedList.pushIn(e.random),this.tim.connectionController.request(s).then(function(o){return r.dot("send success"),e.conversationType===t.CONV_GROUP&&(r.dot("updateID"),e.sequence=o.data.sequence,e.time=o.data.time,e.generateMessageID(n.tim.context.identifier)),r.dot("pushIn"),n.messagesList.pushIn(e),u(e,o.data),r.report(),new ut({message:e})}).catch(function(t){return n._onSendMessageFailed(e,t),r.dot("send fail"),Q.error("MessageController.sendMessageInstance() error:",t),r.report(),ht(new Ce({code:Ie.MESSAGE_SEND_FAIL,message:Se.MESSAGE_SEND_FAIL,data:{message:e}}))})}},{key:"resendMessage",value:function(e){return 1==this._isFileLikeMessage(e)?(Q.warn("MessageController.resendMessage(), file like message can not resendBy SDK.resendMessage()"),ht(new Ce({code:Ie.MESSAGE_RESEND_FILE_UNSUPPORTED,message:Se.MESSAGE_RESEND_FILE_UNSUPPORTED}))):(e.isResend=1,e.status=He.MESSAGE_STATUS.UNSEND,this.sendMessageInstance(e))}},{key:"_isFileLikeMessage",value:function(e){return[t.MSG_IMAGE,t.MSG_FILE,t.MSG_AUDIO,t.MSG_VIDEO].indexOf(e.type)>=0?1:0}},{key:"_resendBinaryTypeMessage",value:function(){}},{key:"_createC2CMessagePack",value:function(e){return this.createPackage({name:"c2cMessage",action:"create",param:{toAccount:e.to,msgBody:e.getElements(),msgSeq:e.sequence,msgRandom:e.random,offlinePushInfo:{desc:"offline message push",ext:"offline message push"}}})}},{key:"_handleOnSendC2CMessageSuccess",value:function(t,n){var r=this.tim,o=r.innerEmitter,i=r.outerEmitter;t.status=He.MESSAGE_STATUS.SUCCESS,t.time=n.time,o.emit(Re.MESSAGE_C2C_SEND_SUCCESS,{data:{eventDataList:[{conversationID:t.conversationID,unreadCount:0,type:t.conversationType,subType:t.conversationSubType,lastMessage:t}]}}),i.emit(e.MESSAGE_SEND_SUCCESS,t)}},{key:"_createGroupMessagePack",value:function(e){return this.createPackage({name:"groupMessage",action:"create",param:{groupID:e.to,msgBody:e.getElements(),random:e.random,clientSequence:e.clientSequence,offlinePushInfo:{desc:"offline message push",ext:"offline message push"}}})}},{key:"_handleOnSendGroupMessageSuccess",value:function(t,n){var r=this.tim,o=r.innerEmitter,i=r.outerEmitter;t.sequence=n.sequence,t.time=n.time,t.status=He.MESSAGE_STATUS.SUCCESS,o.emit(Re.MESSAGE_GROUP_SEND_SUCCESS,{data:{eventDataList:[{conversationID:t.conversationID,unreadCount:0,type:t.conversationType,subType:t.conversationSubType,lastMessage:t}]}}),i.emit(e.MESSAGE_SEND_SUCCESS,t)}},{key:"_onSendMessageFailed",value:function(t,n){var r=this.tim,o=r.innerEmitter,i=r.outerEmitter;t.status=He.MESSAGE_STATUS.FAIL,o.emit(Re.ERROR_DETECTED,n),i.emit(e.MESSAGE_SEND_FAIL,t)}},{key:"_onReceiveC2CMessage",value:function(n){var r=this.tim,o=r.innerEmitter,i=r.outerEmitter;Q.log("MessageController._onReceiveC2CMessage(), get new messages");var a=this._newC2CMessageStoredAndSummary({notifiesList:n.data,type:t.CONV_C2C,C2CRemainingUnreadList:n.C2CRemainingUnreadList}),s=a.eventDataList,u=a.result;o.emit(Re.MESSAGE_C2C_INSTANT_RECEIVED,{data:{eventDataList:s,result:u},resource:this}),u.length>0&&i.emit(e.MESSAGE_RECEIVED,u)}},{key:"_onReceiveGroupMessage",value:function(t){var n=this.tim,r=n.outerEmitter,o=n.innerEmitter,i=this._newGroupMessageStoredAndSummary(t.data),a=i.eventDataList,s=i.result;a.length>0&&(Q.log("MessageController._onReceiveGroupMessage()"),o.emit(Re.MESSAGE_GROUP_INSTANT_RECEIVED,{data:{eventDataList:a,result:s,isGroupTip:0}})),s.length>0&&r.emit(e.MESSAGE_RECEIVED,s)}},{key:"_onReceiveGroupTips",value:function(n){var r=this.tim,o=r.outerEmitter,i=r.innerEmitter,a=n.data,s=this._newGroupTipsStoredAndSummary(a,t.CONV_GROUP),u=s.eventDataList,c=s.result;Q.log("MessageController._onReceiveGroupTips()"),i.emit(Re.MESSAGE_GROUP_INSTANT_RECEIVED,{data:{eventDataList:u,result:c,isGroupTip:1}}),c.length>0&&o.emit(e.MESSAGE_RECEIVED,c)}},{key:"_onReceiveSystemNotice",value:function(t){var n=this.tim,r=n.outerEmitter,o=n.innerEmitter,i=t.data,a=i.groupSystemNotices,s=i.type,u=this._newSystemNoticeStoredAndSummary({notifiesList:a,type:s}),c=u.eventDataList,l=u.result;o.emit(Re.MESSAGE_GROUP_SYSTEM_NOTICE_RECEIVED,{data:{eventDataList:c,result:l,type:s}}),l.length>0&&r.emit(e.MESSAGE_RECEIVED,l)}},{key:"_clearConversationMessages",value:function(e){this.messagesList.removeByConversationID(e),this.getMessageHandler.deleteCompletedItem(e)}},{key:"_pushIntoNoticeResult",value:function(e,t){var n=this.messagesList.pushIn(t),r=this.singlyLinkedList.has(t.random);null!==n&&0==r&&e.push(t)}},{key:"_newC2CMessageStoredAndSummary",value:function(e){for(var t=e.notifiesList,n=e.type,r=e.C2CRemainingUnreadList,o=e.isFromSync,i=null,a=[],s=[],u={},c=0,l=t.length;c<l;c++){var p=t[c];p.currentUser=this.tim.context.identifier,p.conversationType=n,p.isSystemMessage=!!p.isSystemMessage,(i=new oo(p)).setElement(p.elements),o||this._pushIntoNoticeResult(s,i),void 0===u[i.conversationID]?u[i.conversationID]=a.push({conversationID:i.conversationID,unreadCount:"out"===i.flow?0:1,type:i.conversationType,subType:i.conversationSubType,lastMessage:i})-1:(a[u[i.conversationID]].type=i.conversationType,a[u[i.conversationID]].subType=i.conversationSubType,a[u[i.conversationID]].lastMessage=i,"in"===i.flow&&a[u[i.conversationID]].unreadCount++)}if(te(r))for(var h=function(e,t){var n=a.find(function(t){return t.conversationID==="C2C".concat(r[e].from)});n&&(n.unreadCount+=r[e].count)},f=0,_=r.length;f<_;f++)h(f);return{eventDataList:a,result:s}}},{key:"_newGroupMessageStoredAndSummary",value:function(e){for(var n=null,r=[],o={},i=[],a=t.CONV_GROUP,s=0,u=e.length;s<u;s++){var c=e[s];c.currentUser=this.tim.context.identifier,c.conversationType=a,c.isSystemMessage=!!c.isSystemMessage,(n=new oo(c)).setElement(c.elements),this._pushIntoNoticeResult(i,n),void 0===o[n.conversationID]?o[n.conversationID]=r.push({conversationID:n.conversationID,unreadCount:"out"===n.flow?0:1,type:n.conversationType,subType:n.conversationSubType,lastMessage:n})-1:(r[o[n.conversationID]].type=n.conversationType,r[o[n.conversationID]].subType=n.conversationSubType,r[o[n.conversationID]].lastMessage=n,"in"===n.flow&&r[o[n.conversationID]].unreadCount++)}return{eventDataList:r,result:i}}},{key:"_newGroupTipsStoredAndSummary",value:function(e,n){for(var r=null,o=[],i=[],a={},s=0,c=e.length;s<c;s++){var l=e[s];l.currentUser=this.tim.context.identifier,l.conversationType=n,(r=new oo(l)).setElement({type:t.MSG_GRP_TIP,content:u({},l.elements,{groupProfile:l.groupProfile})}),r.isSystemMessage=0;var p=this.messagesList.pushIn(r);p&&i.push(p),void 0===a[r.conversationID]?a[r.conversationID]=o.push({conversationID:r.conversationID,unreadCount:"out"===r.flow?0:1,type:r.conversationType,subType:r.conversationSubType,lastMessage:r})-1:(o[a[r.conversationID]].type=r.conversationType,o[a[r.conversationID]].subType=r.conversationSubType,o[a[r.conversationID]].lastMessage=r,"in"===r.flow&&o[a[r.conversationID]].unreadCount++)}return{eventDataList:o,result:i}}},{key:"_newSystemNoticeStoredAndSummary",value:function(e){var n=e.notifiesList,r=e.type,o=null,i=n.length,a=0,s=[],c={conversationID:t.CONV_SYSTEM,unreadCount:0,type:t.CONV_SYSTEM,subType:null,lastMessage:null};for(a=0;a<i;a++){var l=n[a];if(l.elements.operationType!==$e){l.currentUser=this.tim.context.identifier,l.conversationType=t.CONV_SYSTEM,l.conversationID=t.CONV_SYSTEM,(o=new oo(l)).setElement({type:t.MSG_GRP_SYS_NOTICE,content:u({},l.elements,{groupProfile:l.groupProfile})}),o.isRead=1,o.isSystemMessage=1;var p=this.messagesList.pushIn(o);p&&(s.push(p),"poll"===r&&c.unreadCount++),c.subType=o.conversationSubType}}return c.lastMessage=s[s.length-1],{eventDataList:s.length>0?[c]:[],result:s}}},{key:"_onSyncMessagesProcessing",value:function(e){var n=this._newC2CMessageStoredAndSummary({notifiesList:e.data,type:t.CONV_C2C,isFromSync:1,C2CRemainingUnreadList:e.C2CRemainingUnreadList}),r=n.eventDataList,o=n.result;this.tim.innerEmitter.emit(Re.MESSAGE_SYNC_PROCESSING,{data:{eventDataList:r,result:o},resource:this})}},{key:"_onSyncMessagesFinished",value:function(e){this.triggerReady();var n=this._newC2CMessageStoredAndSummary({notifiesList:e.data,type:t.CONV_C2C,isFromSync:1,C2CRemainingUnreadList:e.C2CRemainingUnreadList}),r=n.eventDataList,o=n.result;this.tim.innerEmitter.emit(Re.MESSAGE_SYNC_FINISHED,{data:{eventDataList:r,result:o},resource:this})}},{key:"getHistoryMessages",value:function(e){if(e.conversationID===t.CONV_SYSTEM)return pt();!e.count&&(e.count=15),e.count>20&&(e.count=20);var n=this.messagesList.getLocalOldestMessageByConversationID(e.conversationID);n||((n={}).time=0,n.sequence=0,0===e.conversationID.indexOf(t.CONV_C2C)?(n.to=e.conversationID.replace(t.CONV_C2C,""),n.conversationType=t.CONV_C2C):0===e.conversationID.indexOf(t.CONV_GROUP)&&(n.to=e.conversationID.replace(t.CONV_GROUP,""),n.conversationType=t.CONV_GROUP));var r="";switch(n.conversationType){case t.CONV_C2C:return r=e.conversationID.replace(t.CONV_C2C,""),this.getC2CRoamMessages({conversationID:e.conversationID,peerAccount:r,count:e.count,lastMessageTime:void 0===this.currentMessageKey[e.conversationID]?0:n.time});case t.CONV_GROUP:return this.getGroupRoamMessages({conversationID:e.conversationID,groupID:n.to,count:e.count,sequence:n.sequence-1});default:return pt()}}},{key:"getC2CRoamMessages",value:function(e){var n=this,r=this.tim,o=r.connectionController,i=r.innerEmitter,a=void 0!==this.currentMessageKey[e.conversationID]?this.currentMessageKey[e.conversationID]:"",s=this.createPackage({name:"c2cMessage",action:"query",param:{peerAccount:e.peerAccount,count:e.count||15,lastMessageTime:e.lastMessageTime||0,messageKey:a}});return o.request(s).then(function(r){var o=r.data,i=o.complete,a=o.messageList;1===i&&n.getMessageHandler.setCompleted(e.conversationID);var s=n._roamMessageStore(a,t.CONV_C2C,e.conversationID);return n.readReportHandler.updateIsRead(e.conversationID),n.currentMessageKey[e.conversationID]=r.data.messageKey,s}).catch(function(e){return i.emit(Re.ERROR_DETECTED,e),Promise.reject(e)})}},{key:"getC2CRoamMessagesSliced",value:function(e){var n=this.tim.connectionController,r=this;return function(e){return new Promise(function(o,i){!function e(o,i,a){var s=arguments.length>3&&void 0!==arguments[3]?arguments[3]:[],u=r.createPackage({name:"c2cMessage",action:"query",param:{peerAccount:o.peerAccount,count:o.count||15,lastMessageTime:o.lastMessageTime||0,messageKey:o.messageKey||""}}),c=n.request(u).then(function(n){var u=n.data.messageList,c=r._roamMessageStore(u,t.CONV_C2C);s.push.apply(s,m(c)),n.data.complete===He.GET_HISTORY_MESSAGE_STATUS.C2C_IS_NOT_FINISHED?(o.messageKey=n.data.messageKey,e(o,i,s)):n.data.complete===He.GET_HISTORY_MESSAGE_STATUS.C2C_IS_FINISHED?(Q.log("getC2CRoamMessages finised..."),i(new ut(s))):a(new Ce({code:Ie.MESSAGE_UNKNOW_ROMA_LIST_END_FLAG_FIELD,message:Se.MESSAGE_UNKNOW_ROMA_LIST_END_FLAG_FIELD}))}).reject(function(e){Q.log("getC2CRoamMessages fail..."),a(e)});return c}(e,o,i,[])})}(e)}},{key:"getGroupRoamMessages",value:function(e){var n=this,r=this.tim,o=r.connectionController,i=r.groupController,a=e.sequence>=0?e.sequence:i.getLocalGroupLastSequence(e.groupID);if(a<0)return pt([]);var s=this.createPackage({name:"groupMessage",action:"query",param:{groupID:e.groupID,count:e.count,sequence:a}});return o.request(s).then(function(r){var o=r.data.messagesList,i="GROUP".concat(e.groupID);Array.isArray(o)&&o.length<e.count&&n.getMessageHandler.setCompleted(i);var a=n._roamMessageStore(o,t.CONV_GROUP,i);return n.readReportHandler.updateIsRead(i),Q.log("getGroupRoamMessages finished..."),a}).catch(function(e){return n.tim.exceptionController.ask(e),Q.log("getGroupRoamMessages error..."),Promise.reject(e)})}},{key:"_roamMessageStore",value:function(){var e=arguments.length>0&&void 0!==arguments[0]?arguments[0]:[],n=arguments.length>1?arguments[1]:void 0,r=arguments.length>2?arguments[2]:void 0,o=null,i=[],a=0,s=e.length,c=null,l=n===t.CONV_GROUP,p=function(){a=l?e.length-1:0,s=l?0:e.length},h=function(){l?--a:++a},f=function(){return l?a>=s:a<s};for(l&&0===e.length&&this.getMessageHandler.setCompleted(r),p();f();h())0!==e[a].elements.length||0!==e[a].time?(l&&1===e[a].sequence&&this.getMessageHandler.setCompleted(r),(o=new oo(e[a])).to=e[a].to,o.isSystemMessage=!!e[a].isSystemMessage,o.conversationType=n,c=e[a].event===Be.JSON.TYPE.GROUP.TIP?{type:t.MSG_GRP_TIP,content:u({},e[a].elements,{groupProfile:e[a].groupProfile})}:e[a].elements[0],o.setElement(c),o.reInitialize(this.tim.context.identifier),i.push(o)):this.getMessageHandler.setCompleted(r);return this.messagesList.shiftIn(i),p=h=f=null,i}},{key:"getLocalMessageList",value:function(e){return this.messagesList.getLocalMessageList(e)}},{key:"getLocalMessage",value:function(e,t){return this.messagesList.getLocalMessage(e,t)}},{key:"setMessageRead",value:function(e){var t=this;return new Promise(function(n,r){t.ready(function(){t.readReportHandler.setMessageRead(e).then(n).catch(r)})})}},{key:"getMessageList",value:function(e){return this.getMessageHandler.getMessageList(e)}},{key:"createTextMessage",value:function(e){e.currentUser=this.tim.context.identifier;var t=new oo(e),n="string"==typeof e.payload?e.payload:e.payload.text,r=new zr({text:n});return t.setElement(r),t}},{key:"createCustomMessage",value:function(e){e.currentUser=this.tim.context.identifier;var t=new oo(e),n=new no({data:e.payload.data,description:e.payload.description,extension:e.payload.extension});return t.setElement(n),t}},{key:"createImageMessage",value:function(e){var t=this.tim.uploadController;e.currentUser=this.tim.context.identifier;var n=new oo(e);if(b){var r=e.payload.file,o=r.tempFilePaths[0],i={url:o,name:o.slice(o.lastIndexOf("/")+1),size:r.tempFiles[0].size,type:o.slice(o.lastIndexOf(".")+1).toUpperCase()};e.payload.file=i}var a=new Wr({imageFormat:"UNKNOWN",uuid:this._generateUUID(),file:e.payload.file});return t.uploadImage({file:e.payload.file,to:e.to,onProgress:function(t){a.updatePercent.bind(a)(t),"function"==typeof e.onProgress&&e.onProgress(t)}}).then(function(e){var t,n=["https://",e.location].join("");return a.updateImageFormat(e.fileType),a.updateImageInfoArray({size:e.fileSize,url:n}),t=a._imageMemoryURL,b?new Promise(function(e,n){wx.getImageInfo({src:t,success:function(t){e({width:t.width,height:t.height})},fail:function(){e({width:0,height:0})}})}):V&&9===Y?Promise.resolve({width:0,height:0}):new Promise(function(e,n){var r=new Image;r.onload=function(){e({width:this.width,height:this.height}),r=null},r.onerror=function(){e({width:0,height:0}),r=null},r.src=t})}).then(function(e){0!==e.width&&0!==e.height&&(Q.log("MessageController.probeImageWidthHeight width=".concat(e.width," height=").concat(e.height)),a.updateImageInfoArray({width:e.width,height:e.height})),n.triggerOperated()}).catch(function(e){n.status=He.MESSAGE_STATUS.FAIL,Q.warn("MessageController.createImageMessage(), error:",JSON.stringify(e))}),n.setElement(a),n}},{key:"createFileMessage",value:function(e){if(b)return ht({code:Ie.MESSAGE_FILE_WECHAT_MINIAPP_NOT_SUPPORT,message:Se.MESSAGE_FILE_WECHAT_MINIAPP_NOT_SUPPORT});var t=this.tim.uploadController;e.currentUser=this.tim.context.identifier;var n=new oo(e),r=new to({uuid:this._generateUUID(),file:e.payload.file});return t.uploadFile({file:e.payload.file,to:e.to,onProgress:function(t){r.updatePercent.bind(r)(t),"function"==typeof e.onProgress&&e.onProgress(t)}}).then(function(e){var t=["https://",e.location].join("");r.updateFileUrl(t),Q.log("MessageController.createFileMessage(), file upload success, URL: ".concat(t)),n.triggerOperated()}).catch(function(e){n.status=He.MESSAGE_STATUS.FAIL,e.code===Ie.MESSAGE_FILE_SIZE_LIMIT&&n.setError(e.code,e.message),Q.warn("MessageController.createFileMessage(), file upload fail, error response: ",e),n.triggerOperated()}),n.setElement(r),n}},{key:"createAudioMessage",value:function(e){if(b){var t=this.tim.uploadController,n=e.payload.file;if(b){var r={url:n.tempFilePath,name:n.tempFilePath.slice(n.tempFilePath.lastIndexOf("/")+1),size:n.fileSize,second:parseInt(n.duration)/1e3,type:n.tempFilePath.slice(n.tempFilePath.lastIndexOf(".")+1).toUpperCase()};e.payload.file=r}e.currentUser=this.tim.context.identifier;var o=new oo(e),i=new Jr({second:Math.floor(n.duration/1e3),size:n.fileSize,url:n.tempFilePath,uuid:this._generateUUID()});return t.uploadAudio({file:e.payload.file,to:e.to}).then(function(e){var t,n=-1===(t=e.location).indexOf("http://")||-1===t.indexOf("https://")?"https://"+t:t.replace(/https|http/,"https");i.updateAudioUrl(n),o.triggerOperated()}).catch(function(e){o.status=He.MESSAGE_STATUS.FAIL,Q.warn("MessageController.createAudioMessage(), error:",e),o.triggerOperated()}),o.setElement(i),o}Q.warn("createAudioMessage 目前只支持微信小程序发语音消息")}},{key:"createFaceMessage",value:function(e){e.currentUser=this.tim.context.identifier;var t=new oo(e),n="string"==typeof e.payload?e.payload:e.payload.text,r=new zr({text:n});return t.setElement(r),t}},{key:"_generateUUID",value:function(){var e=this.tim.context;return"".concat(e.SDKAppID,"-").concat(e.identifier,"-").concat(function(){for(var e="",t=32;t>0;--t)e+=he[Math.floor(Math.random()*fe)];return e}())}}]),o}(),vo=function(){function e(t){r(this,e),this.userID="",this.avatar="",this.nick="",this.role="",this.joinTime="",this.lastSendMsgTime="",this.nameCard="",this.muteUntil=0,this.memberCustomField=[],this._initMember(t)}return i(e,[{key:"_initMember",value:function(e){this.updateMember(e)}},{key:"updateMember",value:function(e){ue(this,e,[],[null,void 0,"",0,NaN])}},{key:"updateRole",value:function(e){["Owner","Admin","Member"].indexOf(e)<0||(this.role=e)}},{key:"updateMemberCustomField",value:function(e){ue(this.memberCustomField,e)}}]),e}(),Io=function(){function e(t){r(this,e),this.tim=t.tim,this.groupController=t.groupController,this._initListeners()}return i(e,[{key:"_initListeners",value:function(){this.tim.innerEmitter.on(Re.MESSAGE_GROUP_INSTANT_RECEIVED,this._onReceivedGroupTips,this)}},{key:"_onReceivedGroupTips",value:function(e){var t=this,n=e.data,r=n.result;n.isGroupTip&&r.forEach(function(e){switch(e.payload.operationType){case 1:t._onNewMemberComeIn(e);break;case 2:t._onMemberQuit(e);break;case 3:t._onMemberKickedOut(e);break;case 4:t._onMemberSetAdmin(e);break;case 5:t._onMemberCancelledAdmin(e);break;case 6:t._onGroupProfileModified(e);break;case 7:t._onMemberInfoModified(e);break;default:Q.warn("GroupTipsHandler._onReceivedGroupTips Unhandled groupTips. operationType=",e.payload.operationType)}})}},{key:"_onNewMemberComeIn",value:function(e){var t=0,n=e.payload.groupProfile.groupID,r=e.payload.userIDList;if(this.groupController.hasLocalGroupMemberMap(n))for(var o=0;o<r.length;o++){var i=r[0];if(!this.groupController.getLocalGroupMemberInfo(n,i)){t=1;break}}t&&this.groupController.updateGroupMemberList({groupID:n})}},{key:"_onMemberQuit",value:function(e){var t=e.payload.groupProfile.groupID;this.groupController._deleteLocalGroupMembers(t,e.payload.userIDList)}},{key:"_onMemberKickedOut",value:function(e){var t=e.payload.groupProfile.groupID;this.groupController._deleteLocalGroupMembers(t,e.payload.userIDList)}},{key:"_onMemberSetAdmin",value:function(e){var n=this,r=e.payload.groupProfile.groupID;e.payload.userIDList.forEach(function(e){var o=n.groupController.getLocalGroupMemberInfo(r,e);o&&o.updateRole(t.GRP_MBR_ROLE_ADMIN)})}},{key:"_onMemberCancelledAdmin",value:function(e){var n=this,r=e.payload.groupProfile.groupID;e.payload.userIDList.forEach(function(e){var o=n.groupController.getLocalGroupMemberInfo(r,e);o&&o.updateRole(t.GRP_MBR_ROLE_MEMBER)})}},{key:"_onGroupProfileModified",value:function(e){var t=this,n=e.payload.newGroupProfile,r=e.payload.groupProfile.groupID,o=this.groupController.getLocalGroupProfile(r);Object.keys(n).forEach(function(e){switch(e){case"ownerID":t._ownerChaged(o,n);break;default:o[e]=n[e]}}),this.groupController._emitGroupUpdate(1,1)}},{key:"_ownerChaged",value:function(e,n){var r=e.groupID,o=this.groupController.getLocalGroupProfile(r),i=this.tim.context.identifier;if(i===n.ownerID){o.updateGroup({selfInfo:{role:t.GRP_MBR_ROLE_OWNER}});var a=this.groupController.getLocalGroupMemberInfo(r,i),s=this.groupController.getLocalGroupProfile(r).ownerID,u=this.groupController.getLocalGroupMemberInfo(r,s);a&&a.updateRole(t.GRP_MBR_ROLE_OWNER),u&&u.updateRole(t.GRP_MBR_ROLE_MEMBER)}}},{key:"_onMemberInfoModified",value:function(e){var t=this,n=e.payload.groupProfile.groupID;e.payload.msgMemberInfo.forEach(function(e){var r=t.groupController.getLocalGroupMemberInfo(n,e.userAccount);r&&e.shutupTime&&(r.shutUpUntil=(Date.now()+1e3*e.shutupTime)/1e3)})}}]),e}(),So=function(){function n(e){r(this,n),this.groupController=e.groupController,this.tim=e.tim,this._initLiceners()}return i(n,[{key:"_initLiceners",value:function(){this.tim.innerEmitter.on(Re.MESSAGE_GROUP_SYSTEM_NOTICE_RECEIVED,this._onReceivedGroupSystemNotice,this)}},{key:"_onReceivedGroupSystemNotice",value:function(t){var n=this,r=t.data,o=r.result;"sync"!==r.type&&o.forEach(function(t){switch(t.payload.operationType){case 1:n._onApplyGroupRequest(t);break;case 2:n._onApplyGroupRequestAgreed(t);break;case 3:n._onApplyGroupRequestRefused(t);break;case 4:n._onMemberKicked(t);break;case 5:n._onGroupDismissed(t);break;case 6:break;case 7:n._onInviteGroup(t);break;case 8:n._onQuitGroup(t);break;case 9:n._onSetManager(t);break;case 10:n._onDeleteManager(t);break;case 11:case 12:case 15:break;case 255:n.tim.outerEmitter.emit(e.GROUP_SYSTEM_NOTICE_RECEIVED,{message:t,type:et})}})}},{key:"_onApplyGroupRequest",value:function(t){this.tim.outerEmitter.emit(e.GROUP_SYSTEM_NOTICE_RECEIVED,{message:t,type:Ve})}},{key:"_onApplyGroupRequestAgreed",value:function(t){var n=t.payload.groupProfile.groupID;this.groupController.hasLocalGroup(n)||this.groupController.getGroupList(),this.tim.outerEmitter.emit(e.GROUP_SYSTEM_NOTICE_RECEIVED,{message:t,type:Ye})}},{key:"_onApplyGroupRequestRefused",value:function(t){this.tim.outerEmitter.emit(e.GROUP_SYSTEM_NOTICE_RECEIVED,{message:t,type:je})}},{key:"_onMemberKicked",value:function(t){var n=t.payload.groupProfile.groupID;this.groupController.hasLocalGroup(n)&&(this.groupController._deleteLocalGroup(n),this.tim.conversationController._deleteLocalConversation("GROUP".concat(n))),this.groupController._emitGroupUpdate(1,0),this.tim.outerEmitter.emit(e.GROUP_SYSTEM_NOTICE_RECEIVED,{message:t,type:ze})}},{key:"_onGroupDismissed",value:function(t){var n=t.payload.groupProfile.groupID;this.groupController._deleteLocalGroup(n),this.tim.conversationController._deleteLocalConversation("GROUP".concat(n)),this.groupController._emitGroupUpdate(1,0),this.tim.outerEmitter.emit(e.GROUP_SYSTEM_NOTICE_RECEIVED,{message:t,type:We})}},{key:"_onInviteGroup",value:function(t){var n=t.payload.groupProfile.groupID;this.groupController.hasLocalGroup(n)||this.groupController.getGroupList(),this.tim.outerEmitter.emit(e.GROUP_SYSTEM_NOTICE_RECEIVED,{message:t,type:Xe})}},{key:"_onQuitGroup",value:function(t){var n=t.payload.groupProfile.groupID;this.groupController.hasLocalGroup(n)&&(this.groupController._deleteLocalGroup(n),this.tim.conversationController._deleteLocalConversation("GROUP".concat(n)),this.groupController._emitGroupUpdate(1,0)),this.tim.outerEmitter.emit(e.GROUP_SYSTEM_NOTICE_RECEIVED,{message:t,type:Je})}},{key:"_onSetManager",value:function(n){var r=n.payload.groupProfile,o=r.to,i=r.groupID,a=this.groupController.getLocalGroupMemberInfo(i,o);a&&a.updateRole(t.GRP_MBR_ROLE_ADMIN),this.tim.outerEmitter.emit(e.GROUP_SYSTEM_NOTICE_RECEIVED,{message:n,type:Qe})}},{key:"_onDeleteManager",value:function(n){var r=n.payload.groupProfile,o=r.to,i=r.groupID,a=this.groupController.getLocalGroupMemberInfo(i,o);a&&a.updateRole(t.GRP_MBR_ROLE_MEMBER),this.tim.outerEmitter.emit(e.GROUP_SYSTEM_NOTICE_RECEIVED,{message:n,type:Ze})}}]),n}(),Co=function(){function e(t){var n=t.tim,o=t.groupController;r(this,e),this.tim=n,this.groupController=o,this.AVChatRoomLoop=null,this.key="",this.startSeq=1,this.errorCount=0,this.group={}}return i(e,[{key:"_updateProperties",value:function(e){var t=this;Object.keys(e).forEach(function(n){t[n]=e[n]})}},{key:"start",value:function(){var e={key:this.key,startSeq:this.startSeq};if(null===this.AVChatRoomLoop){var t=this.tim.notificationController.createPackage({name:"AVChatRoom",action:"startLongPoll",param:e});this.AVChatRoomLoop=this.tim.connectionController.createRunLoop({pack:t,before:this._updateRequestData.bind(this),success:this._handleSuccess.bind(this),fail:this._handleFailure.bind(this)}),this.AVChatRoomLoop.start()}else this.AVChatRoomLoop._stoped&&this.AVChatRoomLoop.start()}},{key:"stop",value:function(){null===this.AVChatRoomLoop||this.AVChatRoomLoop._stoped||(this.AVChatRoomLoop.abort(),this.AVChatRoomLoop.stop(),this.group={})}},{key:"applyJoinAVChatRoom",value:function(e){return this._checkBeforeJoinGroup(e),this.tim.context.a2Key&&this.tim.context.tinyID?this._joinWithAuth(e):this._joinWithoutAuth(e)}},{key:"_joinWithAuth",value:function(e){var t=this;return this.groupController.applyJoinGroup(e).then(function(n){return t.tim.innerEmitter.emit(Re.AVCHATROOM_JOIN_SUCCESS,{data:e.groupID}),t._updateProperties({key:n.data.longPollingKey,startSeq:1,group:t.groupController.groupMap.get(e.groupID)}),t.start(),n}).catch(function(e){return Promise.reject(e)})}},{key:"_joinWithoutAuth",value:function(e){var t=this,n=this.groupController.createPackage({name:"group",action:"applyJoinAVChatRoom",param:e});return this.tim.connectionController.request(n).then(function(n){var r=n.data.longPollingKey;return Q.log("AVChatRoomHandler.applyJoinAVChatRoom ok. groupID:",e.groupID),t.tim.innerEmitter.emit(Re.AVCHATROOM_JOIN_SUCCESS,{data:e.groupID}),t._updateProperties({key:r,startSeq:1,group:t.groupController.getLocalGroupProfile(e.groupID)}),t.start(),new ut({status:xe.SUCCESS,group:t.groupController.getLocalGroupProfile(e.groupID)})}).catch(function(t){return Q.error("AVChatRoomHandler.applyJoinAVChatRoom error:".concat(t.message,". groupID:").concat(e.groupID)),ht(t,1)})}},{key:"_checkBeforeJoinGroup",value:function(e){if(this.isJoined){if(e.groupID===this.group.groupID)return;this.group.selfInfo.role===t.GRP_MBR_ROLE_OWNER?(this.groupController._deleteLocalGroup(this.group.groupID),this.tim.conversationController._deleteLocalConversation("GROUP".concat(this.group.groupID)),this.groupController._emitGroupUpdate(1,0)):this.groupController.quitGroup(this.group.groupID)}null!==this.AVChatRoomLoop&&!this.AVChatRoomLoop._stoped&&this.stop()}},{key:"_updateRequestData",value:function(e){e.StartSeq=this.startSeq,e.Key=this.key}},{key:"_handleSuccess",value:function(e){this.startSeq=e.data.nextSeq,this.key=e.data.key,Array.isArray(e.data.rspMsgList)&&e.data.rspMsgList.forEach(function(e){e.to=e.groupID}),e.data.rspMsgList&&e.data.rspMsgList.length>0&&this.tim.notificationController._eachEventArray(e.data.rspMsgList)}},{key:"_handleFailure",value:function(e){e.error&&(this.errorCount++,this.errorCount>=5&&(this.stop(),this.errorCount=0),this.tim.innerEmitter.emit(Re.ERROR_DETECTED,e.error))}},{key:"isJoined",get:function(){return!ne(this.group.groupID)}}]),e}(),To=function(n){function o(e){var t;return r(this,o),(t=g(this,l(o).call(this,e))).groupMap=new Map,t.groupMemberListMap=new Map,t.hasLocalGroupList=0,t.groupNoticeHandler=new So({tim:e,groupController:_(t)}),t.groupTipsHandler=new Io({tim:e,groupController:_(t)}),t.AVChatRoomHandler=new Co({tim:e,groupController:_(t)}),t._initListeners(),t}return c(o,Fe),i(o,[{key:"createGroup",value:function(e){var n=this;if(!["Public","Private","ChatRoom","AVChatRoom"].includes(e.type)){var r=new Ce({code:Ie.ILLEGAL_GROUP_TYPE,message:Se.ILLEGAL_GROUP_TYPE});return ht(r,1)}me(e.type)&&!ne(e.memberList)&&e.memberList.length>0&&(Q.warn("GroupController.createGroup 创建AVChatRoom时不能添加群成员，自动忽略该字段"),e.memberList=void 0),de(e.type)||ne(e.joinOption)||(Q.warn("GroupController.createGroup 创建Private/ChatRoom/AVChatRoom群时不能设置字段：joinOption，自动忽略该字段"),e.joinOption=void 0);var o=this.createPackage({name:"group",action:"create",param:e});return Q.log("GroupController.createGroup."),this.tim.connectionController.request(o).then(function(r){if(Q.log("GroupController.createGroup ok. groupID:",r.data.groupID),n._updateLocalGroupListAndGroupMemberList([u({},e,{groupID:r.data.groupID})]),e.type!==t.GRP_AVCHATROOM){var o=n.tim.createCustomMessage({to:r.data.groupID,conversationType:t.CONV_GROUP,payload:{data:"group_create",extension:"".concat(n.tim.context.identifier,"创建群组")}});n.tim.sendMessage(o)}return n._emitGroupUpdate(),n.getGroupProfile({groupID:r.data.groupID})}).then(function(e){var r=e.data.group.groupID;return n.getLocalGroupProfile(r).selfInfo.messageRemindType=t.MSG_REMIND_ACPT_AND_NOTE,e}).catch(function(e){return Q.error("GroupController.createGroup error:",e),ht(e,1)})}},{key:"joinGroup",value:function(e){if(this.hasLocalGroup(e.groupID)){var n={status:t.JOIN_STATUS_ALREADY_IN_GROUP};return pt(n)}if(e.type===t.GRP_PRIVATE){var r=new Ce({code:Ie.CANNOT_JOIN_PRIVATE,message:Se.CANNOT_JOIN_PRIVATE});return this.tim.innerEmitter.emit(Re.ERROR_DETECTED,r),ht(r,1)}return Q.log("GroupController.joinGroup. groupID:",e.groupID),e.type===t.GRP_AVCHATROOM?this.applyJoinAVChatRoom(e):this.applyJoinGroup(e)}},{key:"quitGroup",value:function(e){var t=this;this.AVChatRoomHandler.group.groupID===e&&this.AVChatRoomHandler.stop();var n=this.createPackage({name:"group",action:"quitGroup",param:{groupID:e}});return Q.log("GroupController.quitGroup. groupID:",e),this.tim.connectionController.request(n).then(function(){return Q.log("GroupController.quitGroup ok. groupID:",e),t._deleteLocalGroup(e),t.tim.conversationController._deleteLocalConversation("GROUP".concat(e)),t._emitGroupUpdate(1,0),new ut({groupID:e})}).catch(function(t){return Q.error("GroupController.quitGroup error.  error:".concat(t,". groupID:").concat(e)),ht(t,1)})}},{key:"changeGroupOwner",value:function(e){var n=this;if(this.hasLocalGroup(e.groupID)&&this.getLocalGroupProfile(e.groupID).type===t.GRP_AVCHATROOM)return ht(new Ce({code:Ie.CANNOT_CHANGE_OWNER_IN_AVCHATROOM,message:Se.CANNOT_CHANGE_OWNER_IN_AVCHATROOM}),1);if(e.newOwnerID===this.tim.loginInfo.identifier)return ht(new Ce({code:Ie.CANNOT_CHANGE_OWNER_TO_SELF,message:Se.CANNOT_CHANGE_OWNER_TO_SELF}),1);var r=this.createPackage({name:"group",action:"changeGroupOwner",param:e});return Q.log("GroupController.changeGroupOwner. groupID:",e.groupID),this.tim.connectionController.request(r).then(function(){Q.log("GroupController.changeGroupOwner ok. groupID:",e.groupID);var t=e.groupID,r=e.newOwnerID;n.groupMap.get(t).ownerID=r;var o=n.groupMemberListMap.get(t);if(o instanceof Map){var i=o.get(n.tim.loginInfo.identifier);ne(i)||(i.updateRole("Member"),n.groupMap.get(t).selfInfo.role="Member");var a=o.get(r);ne(a)||a.updateRole("Owner")}return n._emitGroupUpdate(1,0),new ut({group:n.groupMap.get(t)})}).catch(function(t){return Q.error("GroupController.changeGroupOwner error:".concat(t,". groupID:").concat(e.groupID)),ht(t,1)})}},{key:"dismissGroup",value:function(e){var n=this;if(this.hasLocalGroup(e)&&this.getLocalGroupProfile(e).type===t.GRP_PRIVATE)return ht(new Ce({code:Ie.CANNOT_DISMISS_PRIVATE,message:Se.CANNOT_DISMISS_PRIVATE}),1);var r=this.createPackage({name:"group",action:"destroyGroup",param:{groupID:e}});return Q.log("GroupController.dismissGroup. groupID:".concat(e)),this.tim.connectionController.request(r).then(function(){return Q.log("GroupController.dismissGroup ok. groupID:".concat(e)),n._deleteLocalGroup(e),n.tim.conversationController._deleteLocalConversation("GROUP".concat(e)),n._emitGroupUpdate(1,0),new ut({groupID:e})}).catch(function(t){return Q.error("GroupController.dismissGroup error:".concat(t,". groupID:").concat(e)),ht(t,1)})}},{key:"updateGroupProfile",value:function(e){var t=this;!this.hasLocalGroup(e.groupID)||de(this.getLocalGroupProfile(e.groupID).type)||ne(e.joinOption)||(Q.warn("GroupController.modifyGroup: Private/ChatRoom/AVChatRoom群不能设置字段：joinOption，自动忽略该字段"),e.joinOption=void 0);var n=this.createPackage({name:"group",action:"updateGroupProfile",param:e});return Q.log("GroupController.modifyGroup. groupID:",e.groupID),this.tim.connectionController.request(n).then(function(){(Q.log("GroupController.modifyGroup ok. groupID:",e.groupID),t.hasLocalGroup(e.groupID))&&(t.groupMap.get(e.groupID).updateGroup(e),t._setLocalGroupList(t.groupMap));return new ut({group:t.groupMap.get(e.groupID)})}).catch(function(t){return Q.log("GroupController.modifyGroup error. error:".concat(t," groupID:").concat(e.groupID)),ht(t,1)})}},{key:"setGroupMemberRole",value:function(e){var n=this,r=this.groupMap.get(e.groupID);if(r.selfInfo.role!==t.GRP_MBR_ROLE_OWNER)return ht(new Ce({code:Ie.NOT_OWNER,message:Se.NOT_OWNER}),1);if([t.GRP_PRIVATE,t.GRP_AVCHATROOM].includes(r.type))return ht(new Ce({code:Ie.CANNOT_SET_MEMBER_ROLE_IN_PRIVATE_AND_AVCHATROOM,message:Se.CANNOT_SET_MEMBER_ROLE_IN_PRIVATE_AND_AVCHATROOM}),1);if([t.GRP_MBR_ROLE_ADMIN,t.GRP_MBR_ROLE_MEMBER].indexOf(e.role)<0)return ht(new Ce({code:Ie.INVALID_MEMBER_ROLE,message:Se.INVALID_MEMBER_ROLE}),1);if(e.userID===this.tim.loginInfo.identifier)return ht(new Ce({code:Ie.CANNOT_SET_SELF_MEMBER_ROLE,message:Se.CANNOT_SET_SELF_MEMBER_ROLE}),1);Q.log("GroupController.setGroupMemberRole. groupID:".concat(e.groupID,". userID: ").concat(e.userID));var o=e.groupID,i=e.userID,a=e.role;return this._modifyGroupMemberInfo({groupID:o,userID:i,role:a}).then(function(){Q.log("GroupController.setGroupMemberRole ok. groupID:".concat(e.groupID,". userID: ").concat(e.userID));var t=n.groupMemberListMap.get(e.groupID);return void 0!==t&&void 0!==t.get(e.userID)&&t.get(e.userID).updateRole(e.role),new ut({group:n.groupMap.get(e.groupID)})}).catch(function(t){return Q.error("GroupController.setGroupMemberRole error:".concat(t,". groupID:").concat(e.groupID,". userID:").concat(e.userID)),ht(t,1)})}},{key:"setGroupMemberMuteTime",value:function(e){var t=this;Q.log("GroupController.setGroupMemberMuteTime. groupID:".concat(e.groupID,". userID: ").concat(e.userID));var n=e.groupID,r=e.userID,o=e.muteTime;return this._modifyGroupMemberInfo({groupID:n,userID:r,muteTime:o}).then(function(){return Q.log("GroupController.setGroupMemberMuteTime ok. groupID:".concat(e.groupID,". userID: ").concat(e.userID)),t.updateGroupMemberList({groupID:n})}).then(function(){return new ut({group:t.groupMap.get(e.groupID)})}).catch(function(t){return Q.error("GroupController.setGroupMemberMuteTime error:".concat(t,". groupID:").concat(e.groupID,". userID:").concat(e.userID)),ht(t,1)})}},{key:"setMessageRemindType",value:function(e){var t=this;Q.log("GroupController.setMessageRemindType. groupID:".concat(e.groupID,". userID: ").concat(e.userID||this.tim.loginInfo.identifier));var n=e.groupID,r=e.messageRemindType;return this._modifyGroupMemberInfo({groupID:n,messageRemindType:r,userID:this.tim.loginInfo.identifier}).then(function(){Q.log("GroupController.setMessageRemindType ok. groupID:".concat(e.groupID,". userID: ").concat(e.userID||t.tim.loginInfo.identifier));var n=t.groupMap.get(e.groupID);return n.selfInfo.messageRemindType=r,new ut({group:n})}).catch(function(n){return Q.error("GroupController.setMessageRemindType error:".concat(n,". groupID:").concat(e.groupID,". userID:").concat(e.userID||t.tim.loginInfo.identifier)),ht(n,1)})}},{key:"setGroupMemberNameCard",value:function(e){var t=this;Q.log("GroupController.setGroupMemberNameCard. groupID:".concat(e.groupID,". userID: ").concat(e.userID||this.tim.loginInfo.identifier));var n=e.groupID,r=e.userID,o=void 0===r?this.tim.loginInfo.identifier:r,i=e.nameCard;return this._modifyGroupMemberInfo({groupID:n,userID:o,nameCard:i}).then(function(){Q.log("GroupController.setGroupMemberNameCard ok. groupID:".concat(e.groupID,". userID: ").concat(e.userID||t.tim.loginInfo.identifier));var r=t.groupMemberListMap.get(n);return void 0!==r&&void 0!==r.get(o)&&r.get(o).updateMember({nameCard:i}),o===t.tim.loginInfo.identifier&&t.hasLocalGroup(n)&&(t.getLocalGroupProfile(n).selfInfo.nameCard=i),new ut({group:t.groupMap.get(n)})}).catch(function(n){return Q.error("GroupController.setGroupMemberNameCard error:".concat(n,". groupID:").concat(e.groupID,". userID:").concat(e.userID||t.tim.loginInfo.identifier)),ht(n,1)})}},{key:"setGroupMemberCustomField",value:function(e){var t=this;Q.log("GroupController.setGroupMemberCustomField. groupID:".concat(e.groupID,". userID: ").concat(e.userID||this.tim.loginInfo.identifier));var n=e.groupID,r=e.userID,o=e.memberCustomField;return this._modifyGroupMemberInfo({groupID:n,userID:r||this.tim.loginInfo.identifier,memberCustomField:o}).then(function(){return Q.log("GroupController.setGroupMemberCustomField ok. groupID:".concat(e.groupID,". userID: ").concat(e.userID||t.tim.loginInfo.identifier)),t.groupMemberListMap.has(n)&&t.groupMemberListMap.get(n).has(r)&&t.groupMemberListMap.get(n).get(r).updateMemberCustomField(o),new ut({group:t.groupMap.get(n)})}).catch(function(n){return Q.error("GroupController.setGroupMemberCustomField error:".concat(n,". groupID:").concat(e.groupID,". userID:").concat(e.userID||t.tim.loginInfo.identifier)),ht(n,1)})}},{key:"getGroupList",value:function(e){var t=this;Q.log("GroupController.getGroupList");var n={introduction:"Introduction",notification:"Notification",createTime:"CreateTime",ownerID:"Owner_Account",lastInfoTime:"LastInfoTime",memberNum:"MemberNum",maxMemberNum:"MaxMemberNum",joinOption:"ApplyJoinOption"},r=["Type","Name","FaceUrl","NextMsgSeq","LastMsgTime"];e&&e.groupProfileFilter&&e.groupProfileFilter.forEach(function(e){n[e]&&r.push(n[e])});var o=this.createPackage({name:"group",action:"list",param:{responseFilter:{groupBaseInfoFilter:r,selfInfoFilter:["Role","JoinTime","MsgFlag"]}}});return this.tim.connectionController.request(o).then(function(e){var n=e.data.groups;return Q.log("GroupController.getGroupList ok"),t._groupListTreeShaking(n),t._updateLocalGroupListAndGroupMemberList(n),t.hasLocalGroupList=1,t.tempConversationList&&(t._handleUpdateGroupLastMessage(t.tempConversationList),t.tempConversationList=null),t._emitGroupUpdate(),new ut({groupList:t.getLocalGroups()})}).catch(function(e){return Q.error("GroupController.getGroupList error: ",e),ht(e,1)})}},{key:"getGroupMemberList",value:function(e){var t=this,n=e.groupID,r=e.offset,o=void 0===r?0:r,i=e.count,a=void 0===i?15:i;Q.log("GroupController.getGroupMemberList groupID: ".concat(n," offset: ").concat(o," count: ").concat(a));var s=this.createPackage({name:"group",action:"getGroupMemberList",param:{groupID:n,offset:o,limit:a>100?100:a,memberInfoFilter:["Account","Role","JoinTime","LastSendMsgTime","NameCard","ShutUpUntil"]}}),u=[];return this.connectionController.request(s).then(function(e){var r=e.data,o=r.members,i=r.memberNum;return te(o)&&0!==o.length?(t.hasLocalGroup(n)&&(t.getLocalGroupProfile(n).memberNum=i),u=t._updateLocalGroupMemberList(n,o),t.tim.getUserProfile({userIDList:o.map(function(e){return e.userID})})):Promise.resolve([])}).then(function(e){var r=e.data;if(!te(r)||0===r.length)return pt({memberList:[]});var o=r.map(function(e){return{userID:e.userID,nick:e.nick,avatar:e.avatar}});return t._updateLocalGroupMemberList(n,o),Q.log("GroupController.getGroupMemberList ok."),new ut({memberList:u})}).catch(function(e){return Q.error("GroupController.getGroupMemberList error: ",e),ht(e)})}},{key:"getLocalGroups",value:function(){return m(this.groupMap.values())}},{key:"getLocalGroupProfile",value:function(e){return this.groupMap.get(e)}},{key:"hasLocalGroup",value:function(e){return this.groupMap.has(e)}},{key:"getLocalGroupMemberInfo",value:function(e,t){return this.groupMemberListMap.has(e)?this.groupMemberListMap.get(e).get(t):0}},{key:"hasLocalGroupMember",value:function(e,t){return this.groupMemberListMap.has(e)&&this.groupMemberListMap.get(e).has(t)}},{key:"hasLocalGroupMemberMap",value:function(e){return this.groupMemberListMap.has(e)}},{key:"getGroupProfile",value:function(e){var t=this;Q.log("GroupController.getGroupProfile. groupID:",e.groupID);var n=e.groupID,r=e.groupCustomFieldFilter,o=e.memberCustomFieldFilter,i={groupIDList:[n],responseFilter:{groupBaseInfoFilter:["Type","Name","Introduction","Notification","FaceUrl","Owner_Account","CreateTime","InfoSeq","LastInfoTime","LastMsgTime","MemberNum","MaxMemberNum","ApplyJoinOption","NextMsgSeq"],groupCustomFieldFilter:r,memberCustomFieldFilter:o}};return this.getGroupProfileAdvance(i).then(function(r){var o=r.data,i=o.successGroupList,a=o.failureGroupList;if(Q.log("GroupController.getGroupProfile ok. groupID:",e.groupID),a.length>0)return ht(a[0],1);var s=[];return t._updateLocalGroupListAndGroupMemberList(i,1),t.groupMemberListMap.has(n)&&t.groupMemberListMap.get(n).forEach(function(e){var t=e.userID;s.push(t)}),t._emitGroupUpdate(),t.tim.getUserProfile({userIDList:s,tagList:["Tag_Profile_IM_Nick","Tag_Profile_IM_Image"]})}).then(function(e){return e.data.forEach(function(e){var r=t.getLocalGroupMemberInfo(n,e.userID);r&&r.updateMember({nick:e.nick,avatar:e.avatar})}),new ut({group:t.groupMap.get(n)})}).catch(function(t){return Q.error("GroupController.getGroupProfile error:".concat(t,". groupID:").concat(e.groupID)),ht(t,1)})}},{key:"addGroupMember",value:function(e){var t=this,n=this.getLocalGroupProfile(e.groupID);if(me(n.type)){var r=new Ce({code:Ie.CANNOT_ADD_MEMBER_IN_AVCHATROOM,message:Se.CANNOT_ADD_MEMBER_IN_AVCHATROOM});return ht(r,1)}e.userIDList=e.userIDList.map(function(e){return{userID:e}});var o=this.createPackage({name:"group",action:"addGroupMember",param:e});return Q.log("GroupController.addGroupMember. groupID:",e.groupID),this.connectionController.request(o).then(function(r){var o=r.data.members;Q.log("GroupController.addGroupMember ok. groupID:",e.groupID);var i=o.filter(function(e){return 1===e.result}).map(function(e){return e.userID}),a=o.filter(function(e){return 0===e.result}).map(function(e){return e.userID}),s=o.filter(function(e){return 2===e.result}).map(function(e){return e.userID});return 0===i.length?new ut({successUserIDList:i,failureUserIDList:a,existedUserIDList:s}):(t.updateGroupMemberList(e),new ut({successUserIDList:i,failureUserIDList:a,existedUserIDList:s,group:n}))}).catch(function(t){return Q.error("GroupController.addGroupMember error:".concat(t,", groupID:").concat(e.groupID)),ht(t,1)})}},{key:"deleteGroupMember",value:function(e){var n=this,r=this.groupMap.get(e.groupID);if(r.type===t.GRP_AVCHATROOM)return ht(new Ce({code:Ie.CANNOT_KICK_MEMBER_IN_AVCHATROOM,message:Se.CANNOT_KICK_MEMBER_IN_AVCHATROOM}),1);var o=this.createPackage({name:"group",action:"deleteGroupMember",param:e});return this.connectionController.request(o).then(function(){return n._deleteLocalGroupMembers(e.groupID,e.userIDList),n._emitGroupUpdate(),new ut({group:r,userIDList:e.userIDList})}).catch(function(e){n._promiseCatch.bind(n)(e)})}},{key:"searchGroupByID",value:function(e){var t={groupIDList:[e]},n=this.createPackage({name:"group",action:"searchGroupByID",param:t});return Q.log("GroupController.searchGroupByID. groupID:".concat(e)),this.connectionController.request(n).then(function(t){var n=t.data.groupProfile;if(Q.log("GroupController.searchGroupByID ok. groupID:".concat(e)),n[0].errorCode!==He.REQUEST.SUCCESS)throw new Ce({code:n[0].errorCode,message:n[0].errorInfo});return new ut({group:new ao(n[0])})}).catch(function(t){return Q.error("GroupController.searchGroupByID error:".concat(t,", groupID:").concat(e)),ht(t,1)})}},{key:"applyJoinGroup",value:function(e){var t=this,n=this.createPackage({name:"group",action:"applyJoinGroup",param:e});return this.connectionController.request(n).then(function(n){var r=n.data,o=r.joinedStatus,i=r.longPollingKey;switch(Q.log("GroupController.joinGroup ok. groupID:",e.groupID),o){case xe.WAIT_APPROVAL:return new ut({status:xe.WAIT_APPROVAL});case xe.SUCCESS:return t.getGroupProfile({groupID:e.groupID}).then(function(e){var t={status:xe.SUCCESS,group:e.data.group};return ne(i)||(t.longPollingKey=i),new ut(t)});default:var a=new Ce({code:Ie.JOIN_GROUP_FAIL,message:Se.JOIN_GROUP_FAIL});return Q.error("GroupController.joinGroup error:".concat(a,". groupID:").concat(e.groupID)),ht(a,1)}}).catch(function(t){return Q.error("GroupController.joinGroup error:".concat(t,". groupID:").concat(e.groupID)),ht(t,1)})}},{key:"applyJoinAVChatRoom",value:function(e){return this.AVChatRoomHandler.applyJoinAVChatRoom(e)}},{key:"handleGroupApplication",value:function(e){var t=this,n=e.message.payload,r=n.groupProfile.groupID,o=n.authentication,i=n.messageKey,a=n.operatorID,s=this.createPackage({name:"group",action:"handleApplyJoinGroup",param:u({},e,{applicant:a,groupID:r,authentication:o,messageKey:i})});return Q.log("GroupController.handleApplication. groupID:",r),this.connectionController.request(s).then(function(){return Q.log("GroupController.handleApplication ok. groupID:",r),t.updateGroupMemberList({groupID:r})}).then(function(e){return new ut({group:e})}).catch(function(e){return Q.error("GroupController.handleApplication error.  error:".concat(e,". groupID:").concat(r)),ht(e,1)})}},{key:"deleteGroupSystemNotice",value:function(e){var n=this.createPackage({name:"group",action:"deleteGroupSystemNotice",param:{messageListToDelete:e.messageList.map(function(e){return{from:t.CONV_SYSTEM,messageSeq:e.clientSequence,messageRandom:e.random}})}});return this.connectionController.request(n).then(function(){return new ut}).catch(this._promiseCatch.bind(this))}},{key:"updateGroupMemberList",value:function(e){var t=this,n=e.groupID,r=e.memberCustomFieldFilter,o=e.memberInfoFilter,i={groupIDList:[n],responseFilter:{memberInfoFilter:o||["Account","Role","JoinTime","LastSendMsgTime","NameCard","ShutUpUntil"],memberCustomFieldFilter:r}};return this.getGroupProfileAdvance(i).then(function(e){var r=e.data,o=r.successGroupList,i=r.failureGroupList;if(i.length>0)return ht(i[0],1);var a=[];return t._updateLocalGroupMemberList(o[0].groupID,o[0].members),t.groupMemberListMap.get(n).forEach(function(e){var t=e.userID;a.push(t)}),t.tim.getUserProfile({userIDList:a,tagList:["Tag_Profile_IM_Nick","Tag_Profile_IM_Image"]})}).then(function(e){var r=e.data.map(function(e){return{userID:e.userID,nick:e.nick,avatar:e.avatar}});return t._updateLocalGroupMemberList(n,r),t._emitGroupUpdate(),t.groupMap.get(n)})}},{key:"getLocalGroupLastSequence",value:function(e){if(!this.groupMap.has(e))return 0;var t=this.groupMap.get(e);return t.lastMessage.lastSequence?t.lastMessage.lastSequence:t.nextMessageSeq-1}},{key:"_promiseCatch",value:function(e){return ht(e,1)}},{key:"getGroupProfileAdvance",value:function(e){Q.log("GroupController.getGroupProfileAdvance. groupIDList:",e.groupIDList);var t=this.createPackage({name:"group",action:"query",param:e});return this.tim.connectionController.request(t).then(function(e){Q.log("GroupController.getGroupProfileAdvance ok.");var t=e.data.groups,n=t.filter(function(e){return ne(e.errorCode)||e.errorCode===He.REQUEST.SUCCESS}),r=t.filter(function(e){return e.errorCode&&e.errorCode!==He.REQUEST.SUCCESS}).map(function(e){return new Ce({code:Number("500".concat(e.errorCode)),message:e.errorInfo,data:{groupID:e.groupID}})});return new ut({successGroupList:n,failureGroupList:r})}).catch(function(t){return Q.error("GroupController.getGroupProfile error:".concat(t,". groupID:").concat(e.groupID)),ht(t,1)})}},{key:"_deleteLocalGroup",value:function(e){return this.groupMap.delete(e),this.groupMemberListMap.delete(e),this._setLocalGroupList(this.groupMap),this.groupMap.has(e)&&this.groupMemberListMap.has(e)}},{key:"_initGroupList",value:function(){var e=this;(Q.time(dt),Q.log("GroupController._initGroupList"),this.hasLocalGroupList=this._hasLocalGroupList(),this.hasLocalGroupList)&&(this._getLocalGroups().forEach(function(t){e.groupMap.set(t[0],new ao(t[1]))}),this._emitGroupUpdate(1,0));this.triggerReady(),Q.log("GroupController._initGroupList ok. initCost=".concat(Q.timeEnd(dt),"ms")),this.getGroupList()}},{key:"_initListeners",value:function(){var e=this.tim.innerEmitter;e.once(Re.CONTEXT_A2KEY_AND_TINYID_UPDATED,this._initGroupList,this),e.on(Re.CONVERSATION_LIST_UPDATED,this._handleUpdateGroupLastMessage,this),e.on(Re.MESSAGE_GROUP_INSTANT_RECEIVED,this._handleReceivedGroupMessage,this),e.on(Re.PROFILE_UPDATED,this._handleProfileUpdated,this)}},{key:"_emitGroupUpdate",value:function(){var t=arguments.length>0&&void 0!==arguments[0]?arguments[0]:1,n=arguments.length>1&&void 0!==arguments[1]?arguments[1]:1,r=this.getLocalGroups();n&&this.tim.innerEmitter.emit(Re.GROUP_LIST_UPDATED,r),t&&this.tim.outerEmitter.emit(e.GROUP_LIST_UPDATED,r)}},{key:"_handleReceivedGroupMessage",value:function(e){var n=this,r=e.data.eventDataList;Array.isArray(r)&&r.forEach(function(e){var r=e.conversationID.replace(t.CONV_GROUP,"");n.groupMap.has(r)&&(n.groupMap.get(r).nextMessageSeq=e.lastMessage.sequence+1)})}},{key:"_onReceivedGroupSystemNotice",value:function(e){var t=e.data;this.groupNoticeHandler._onReceivedGroupNotice(t)}},{key:"_handleUpdateGroupLastMessage",value:function(e){if(this.hasLocalGroupList){for(var n=0,r=0;r<e.length;r++){var o=e[r],i=o.type===t.CONV_GROUP;if(o.conversationID&&i){var a=o.conversationID.split(/^GROUP/)[1],s=this.getLocalGroupProfile(a);s&&(s.lastMessage=o.lastMessage,n=1)}}n&&(this.groupMap=this._sortLocalGroupList(this.groupMap),this._emitGroupUpdate(1,0))}else this.tempConversationList=e}},{key:"_sortLocalGroupList",value:function(e){var t=m(e).filter(function(e){var t=d(e,2);t[0];return!T(t[1].lastMessage)});return t.sort(function(e,t){return t[1].lastMessage.lastTime-e[1].lastMessage.lastTime}),new Map([].concat(m(t),m(e)))}},{key:"_getLocalGroups",value:function(){return this.tim.storage.getItem("groupMap")}},{key:"_hasLocalGroupList",value:function(){var e=this.tim.storage.getItem("groupMap");return null!==e&&0!==e.length}},{key:"_setLocalGroupList",value:function(e){var t=[];e.forEach(function(e,n){var r=e.name,o=e.avatar,i=e.type;t.push([n,{groupID:n,name:r,avatar:o,type:i}])}),this.tim.storage.setItem("groupMap",t)}},{key:"_updateLocalGroupListAndGroupMemberList",value:function(e,t){var n=this;e.forEach(function(e){n.groupMap.has(e.groupID)?n.groupMap.get(e.groupID).updateGroup(e):n.groupMap.set(e.groupID,new ao(e)),n._updateLocalGroupMemberList(e.groupID,e.members||e.memberList,t)}),this._setLocalGroupList(this.groupMap)}},{key:"_updateLocalGroupMemberList",value:function(e,t){var n=this,r=arguments.length>2&&void 0!==arguments[2]?arguments[2]:0;if(!t)return[];var o=this.groupMemberListMap.has(e)&&0==r?this.groupMemberListMap.get(e):new Map,i=t.map(function(t){if(t.userID===n.tim.context.identifier){var r=[null,void 0,"",0,NaN],i={role:t.role,joinTime:t.joinTime,nameCard:t.nameCard};ue(n.groupMap.get(e).selfInfo,i,[],r)}return o.has(t.userID)?o.get(t.userID).updateMember(t):o.set(t.userID,new vo(t)),o.get(t.userID)});return this.groupMemberListMap.set(e,o),i}},{key:"_deleteLocalGroupMembers",value:function(e,t){var n=this.groupMemberListMap.get(e);void 0!==n&&(t.forEach(function(e){n.delete(e)}),this.groupMap.get(e).memberList=m(n.values()))}},{key:"_modifyGroupMemberInfo",value:function(e){var t=this.createPackage({name:"group",action:"modifyGroupMemberInfo",param:e});return this.tim.connectionController.request(t)}},{key:"_groupListTreeShaking",value:function(e){for(var t=new Map(m(this.groupMap)),n=0,r=e.length;n<r;n++)t.delete(e[n].groupID);this.AVChatRoomHandler.isJoined&&t.delete(this.AVChatRoomHandler.group.groupID);for(var o=m(t.keys()),i=0,a=o.length;i<a;i++)this.groupMap.delete(o[i])}},{key:"_handleProfileUpdated",value:function(e){for(var t=this,n=e.data,r=function(e){var r=n[e];t.groupMemberListMap.forEach(function(e){e.has(r.userID)&&e.get(r.userID).updateMember({nick:r.nick,avatar:r.avatar})})},o=0;o<n.length;o++)r(o)}},{key:"reset",value:function(){this.groupMap.clear(),this.groupMemberListMap.clear(),this.hasLocalGroupList=0,this.resetReady(),this.tim.innerEmitter.once(Re.CONTEXT_A2KEY_AND_TINYID_UPDATED,this._initGroupList,this)}}]),o}(),Mo=function(){for(var e=[],t=Do(arguments),n=0;n<arguments.length;n++)Number.isInteger(arguments[n])?e.push(arguments[n]):e.push(1==!!arguments[n]?"1":"0");return e.join(t)},Do=function(e){var t=e.length,n=e[t-1];if("string"!=typeof n)return"";if(n.length>1)return"";var r=e[t-1];return delete e[t-1],e.length-=t===e.length?1:0,r},Oo=function(t){function n(e){var t;return r(this,n),(t=g(this,l(n).call(this,e)))._initializeMembers(),t._initializeStatus(),t._initializeListener(),t}return c(n,Fe),i(n,[{key:"_initializeMembers",value:function(){this.normalTimeout=300,this.realtimeNoticeTimeout=11e4,this.channelMaxTimeout=3e5,this._memoryUsed=0,this._memoryUsedThreshold=.9,this._onMemoryWarning=null}},{key:"_initializeStatus",value:function(){this._initializeAccountStatus(),this._initializeChannelStatus()}},{key:"_initializeAccountStatus",value:function(){this.accountStatus={lastSignInTime:0,status:He.ACCOUNT_STATUS.SIGN_OUT}}},{key:"_initializeChannelStatus",value:function(){this.channelStatus={startTime:0,offlineTime:0,failCount:0,lastRequestTime:0,lastJitterTime:0,jitterCount:0,jitters:[],status:He.CHANNEL_STATUS.OFFLINE}}},{key:"_onMemoryRunningLow",value:function(e){Q.warn("memory running low : ",e)}},{key:"getChannelStatus",value:function(){return this.channelStatus.status}},{key:"_channelStatusJittersUpdate",value:function(e){this.channelStatus.jitterCount++,this.channelStatus.lastJitterTime=e,this.channelStatus.jitters.push(e),this.channelStatus.jitters.length>5&&this.channelStatus.jitters.pop()}},{key:"_initializeListener",value:function(){var e=this.tim.innerEmitter;e.on(Re.NOTICE_LONGPOLL_START,this._onChannelStart,this),e.on(Re.NOTICE_LONGPOLL_REQUEST_ARRIVED,this._onChannelRequestSuccess,this),e.on(Re.NOTICE_LONGPOLL_REQUEST_NOT_ARRIVED,this._onChannelFail,this)}},{key:"_onChannelStart",value:function(){this.channelStatus.startTime=+new Date,this.channelStatus.status=He.CHANNEL_STATUS.ONLINE}},{key:"_getMemoryUsed",value:function(){var e="disabled",t=0;return"undefined"!=typeof window&&void 0!==window.performance&&(t=window.performance.memory.usedJSHeapSize/window.performance.memory.jsHeapSizeLimit,this._memoryUsed=t,e=[Math.round(1e5*this._memoryUsed)/1e3,"%"].join("")),e}},{key:"_onChannelRequestSuccess",value:function(){var t=this.tim,n=t.innerEmitter,r=t.outerEmitter,o=Date.now(),i=o-(this.channelStatus.lastRequestTime>0?this.channelStatus.lastRequestTime:Date.now()+100),a=Mo(i<this.realtimeNoticeTimeout,i<this.channelMaxTimeout);switch(this.channelStatus.status=He.CHANNEL_STATUS.ONLINE,this.channelStatus.failCount=0,a){case"11":break;case"01":n.emit(Re.NOTICE_LONGPOLL_SOON_RECONNECT),r.emit(e.NOTICE_LONGPOLL_RECONNECT);break;case"00":n.emit(Re.NOTICE_LONGPOLL_LONG_RECONNECT)}this.channelStatus.lastRequestTime=o}},{key:"_onChannelFail",value:function(e){var t=this.tim.innerEmitter,n=Date.now();this.channelStatus.status=He.CHANNEL_STATUS.OFFLINE;var r=n-(0===this.channelStatus.offlineTime?this.channelStatus.lastRequestTime:this.channelStatus.offlineTime);this.channelStatus.offlineTime=n,this.channelStatus.failCount++,Q.log("_onChannelFail count : ".concat(this.channelStatus.failCount,"  time diff: ").concat(r,";")),this.channelStatus.failCount>5&&r<5e3&&(t.emit(Re.NOTICE_LONGPOLL_DISCONNECT),Q.error("Detected notice channel offline, please check your network!"))}}]),n}();function Ao(){return null}var No=function(){function e(t){r(this,e),this.tim=t,this.isWX=b,this.storageQueue=new Map,this.checkTimes=0,this.checkTimer=setInterval(this._onCheckTimer.bind(this),1e3),this._prefix="",this._initListeners(),this._errorTolerantHandle()}return i(e,[{key:"_errorTolerantHandle",value:function(){!this.isWX&&ne(window.localStorage)&&(this.getItem=Ao,this.setItem=Ao,this.removeItem=Ao,this.clear=Ao)}},{key:"_onCheckTimer",value:function(){if(this.checkTimes++,this.checkTimes%20==0){if(0===this.storageQueue.size)return;this._doFlush()}}},{key:"_doFlush",value:function(){try{var e=1,t=0,n=void 0;try{for(var r,o=this.storageQueue[Symbol.iterator]();!(e=(r=o.next()).done);e=1){var i=d(r.value,2),a=i[0],s=i[1];this.isWX?wx.setStorageSync(this._getKey(a),s):localStorage.setItem(this._getKey(a),JSON.stringify(s))}}catch(u){t=1,n=u}finally{try{e||null==o.return||o.return()}finally{if(t)throw n}}this.storageQueue.clear()}catch(c){Q.error("Storage._doFlush error",c)}}},{key:"_initListeners",value:function(){this.tim.innerEmitter.once(Re.CONTEXT_A2KEY_AND_TINYID_UPDATED,this._updatePrefix,this)}},{key:"_updatePrefix",value:function(){var e=this.tim.loginInfo,t=e.SDKAppID,n=e.identifier;this._prefix="TIM_".concat(t,"_").concat(n,"_")}},{key:"getItem",value:function(e){try{return this.isWX?wx.getStorageSync(this._getKey(e)):JSON.parse(localStorage.getItem(this._getKey(e)))}catch(t){Q.error("Storage.getItem error:",t)}}},{key:"setItem",value:function(e,t){this.storageQueue.set(e,t)}},{key:"clear",value:function(){try{this.isWX?wx.clearStorageSync():localStorage.clear()}catch(e){Q.error("Storage.clear error:",e)}}},{key:"removeItem",value:function(e){try{this.isWX?wx.removeStorageSync(this._getKey(e)):localStorage.removeItem(this._getKey(e))}catch(t){Q.error("Storage.removeItem error:",t)}}},{key:"getSize",value:function(e){var t=this,n=arguments.length>1&&void 0!==arguments[1]?arguments[1]:"b";try{var r={size:0,limitSize:5242880,unit:n};if(Object.defineProperty(r,"leftSize",{enumerable:1,get:function(){return r.limitSize-r.size}}),this.isWX&&(r.limitSize=1024*wx.getStorageInfoSync().limitSize),e)r.size=JSON.stringify(this.getItem(e)).length+this._getKey(e).length;else if(this.isWX){var o=wx.getStorageInfoSync(),i=o.keys;i.forEach(function(e){r.size+=JSON.stringify(wx.getStorageSync(e)).length+t._getKey(e).length})}else for(var a in localStorage)localStorage.hasOwnProperty(a)&&(r.size+=localStorage.getItem(a).length+a.length);return this._convertUnit(r)}catch(s){Q.error("Storage.getSize error:",s)}}},{key:"_convertUnit",value:function(e){var t={},n=e.unit;for(var r in t.unit=n,e)"number"==typeof e[r]&&("kb"===n.toLowerCase()?t[r]=Math.round(e[r]/1024):"mb"===n.toLowerCase()?t[r]=Math.round(e[r]/1024/1024):t[r]=e[r]);return t}},{key:"_getKey",value:function(e){return"".concat(this._prefix).concat(e)}},{key:"reset",value:function(){this._doFlush(),this.checkTimes=0,this._prefix="",this.tim.innerEmitter.once(Re.CONTEXT_A2KEY_AND_TINYID_UPDATED,this._updatePrefix,this)}}]),e}(),Lo=v(function(e){var t=Object.prototype.hasOwnProperty,n="~";function r(){}function o(e,t,n){this.fn=e,this.context=t,this.once=n||0}function i(e,t,r,i,a){if("function"!=typeof r)throw new TypeError("The listener must be a function");var s=new o(r,i||e,a),u=n?n+t:t;return e._events[u]?e._events[u].fn?e._events[u]=[e._events[u],s]:e._events[u].push(s):(e._events[u]=s,e._eventsCount++),e}function a(e,t){0==--e._eventsCount?e._events=new r:delete e._events[t]}function s(){this._events=new r,this._eventsCount=0}Object.create&&(r.prototype=Object.create(null),(new r).__proto__||(n=0)),s.prototype.eventNames=function(){var e,r,o=[];if(0===this._eventsCount)return o;for(r in e=this._events)t.call(e,r)&&o.push(n?r.slice(1):r);return Object.getOwnPropertySymbols?o.concat(Object.getOwnPropertySymbols(e)):o},s.prototype.listeners=function(e){var t=n?n+e:e,r=this._events[t];if(!r)return[];if(r.fn)return[r.fn];for(var o=0,i=r.length,a=new Array(i);o<i;o++)a[o]=r[o].fn;return a},s.prototype.listenerCount=function(e){var t=n?n+e:e,r=this._events[t];return r?r.fn?1:r.length:0},s.prototype.emit=function(e,t,r,o,i,a){var s=n?n+e:e;if(!this._events[s])return 0;var u,c,l=this._events[s],p=arguments.length;if(l.fn){switch(l.once&&this.removeListener(e,l.fn,void 0,1),p){case 1:return l.fn.call(l.context),1;case 2:return l.fn.call(l.context,t),1;case 3:return l.fn.call(l.context,t,r),1;case 4:return l.fn.call(l.context,t,r,o),1;case 5:return l.fn.call(l.context,t,r,o,i),1;case 6:return l.fn.call(l.context,t,r,o,i,a),1}for(c=1,u=new Array(p-1);c<p;c++)u[c-1]=arguments[c];l.fn.apply(l.context,u)}else{var h,f=l.length;for(c=0;c<f;c++)switch(l[c].once&&this.removeListener(e,l[c].fn,void 0,1),p){case 1:l[c].fn.call(l[c].context);break;case 2:l[c].fn.call(l[c].context,t);break;case 3:l[c].fn.call(l[c].context,t,r);break;case 4:l[c].fn.call(l[c].context,t,r,o);break;default:if(!u)for(h=1,u=new Array(p-1);h<p;h++)u[h-1]=arguments[h];l[c].fn.apply(l[c].context,u)}}return 1},s.prototype.on=function(e,t,n){return i(this,e,t,n,0)},s.prototype.once=function(e,t,n){return i(this,e,t,n,1)},s.prototype.removeListener=function(e,t,r,o){var i=n?n+e:e;if(!this._events[i])return this;if(!t)return a(this,i),this;var s=this._events[i];if(s.fn)s.fn!==t||o&&!s.once||r&&s.context!==r||a(this,i);else{for(var u=0,c=[],l=s.length;u<l;u++)(s[u].fn!==t||o&&!s[u].once||r&&s[u].context!==r)&&c.push(s[u]);c.length?this._events[i]=1===c.length?c[0]:c:a(this,i)}return this},s.prototype.removeAllListeners=function(e){var t;return e?(t=n?n+e:e,this._events[t]&&a(this,t)):(this._events=new r,this._eventsCount=0),this},s.prototype.off=s.prototype.removeListener,s.prototype.addListener=s.prototype.on,s.prefixed=n,s.EventEmitter=s,e.exports=s}),Ro=function(e){var t,n,r,o,i;return T(e.context)?(t="",n=0,r=0,o=0,i=1):(t=e.context.a2Key,n=e.context.tinyID,r=e.context.SDKAppID,o=e.context.contentType,i=e.context.apn),{platform:De,websdkappid:Me,v:Te,a2:t,tinyid:n,sdkappid:r,contentType:o,apn:i,reqtime:function(){return+new Date}}},Po=function(){function e(t){r(this,e),this.isReady=0,this.tim=t,this.context=t.context,this._initList(),this._updateWhenCTXIsReady()}return i(e,[{key:"_updateWhenCTXIsReady",value:function(){this.tim.innerEmitter.on(Re.CONTEXT_UPDATED,this.update,this),this.tim.innerEmitter.on(Re.CONTEXT_RESET,this.reset,this)}},{key:"update",value:function(e){var t=e.context;this.context=t,this._initList()}},{key:"reset",value:function(e){this.context=e.data,this._initList()}},{key:"get",value:function(e){var t=e.name,r=e.action,o=e.param;if(void 0===this.config[t])throw new Ce({code:Ie.NETWORK_PACKAGE_UNDEFINED,message:"".concat(Se.NETWORK_PACKAGE_UNDEFINED,": PackageConfig.").concat(t)});if(void 0===this.config[t][r])throw new Ce({code:Ie.NETWORK_PACKAGE_UNDEFINED,message:"".concat(Se.NETWORK_PACKAGE_UNDEFINED,": PackageConfig.").concat(t,".").concat(r)});var i=function e(t){if(0===Object.getOwnPropertyNames(t).length)return Object.create(null);var r=Array.isArray(t)?[]:Object.create(null),o="";for(var i in t)null!==t[i]?void 0!==t[i]?(o=n(t[i]),["string","number","function","boolean"].indexOf(o)>=0?r[i]=t[i]:r[i]=e(t[i])):r[i]=void 0:r[i]=null;return r}(this.config[t][r]);return i.requestData=this._initRequestData(o,i),i.encode=this._initEncoder(i),i.decode=this._initDecoder(i),i}},{key:"set",value:function(e){var t=e.key,r=e.value;if(0!=!!t){var o=t.split(".");if(!(o.length<=0)){!function e(t,r,o,i){var a=r[o];"object"===n(t[a])?e(t[a],r,o+1,i):t[a]=i}(this.config,o,0,r)}}}},{key:"_initList",value:function(){var e;this.config={},this.config.accessLayer=(e=this.tim,{create:null,query:{serverName:Ne.NAME.WEB_IM,cmd:Ne.CMD.ACCESS_LAYER,channel:Ne.CHANNEL.XHR,protocol:Ae,method:"POST",queryString:{platform:De,identifier:e.loginInfo.identifier,usersig:e.loginInfo.userSig,contentType:e.loginInfo.contentType,apn:null!==e.context?e.context.apn:1,websdkappid:Me,v:Te},requestData:{}},update:null,delete:null}),this.config.login=function(e){return{create:null,query:{serverName:Ne.NAME.OPEN_IM,cmd:Ne.CMD.LOGIN,channel:Ne.CHANNEL.XHR,protocol:Ae,method:"POST",queryString:{websdkappid:Me,v:Te,platform:De,identifier:e.loginInfo.identifier,usersig:e.loginInfo.userSig,sdkappid:e.loginInfo.SDKAppID,accounttype:e.loginInfo.accountType,contentType:null!==e.context?e.context.contentType:0,apn:null!==e.context?e.context.apn:1,reqtime:+new Date/1e3},requestData:{state:"Online"},keyMaps:{request:{tinyID:"tinyId"},response:{TinyId:"tinyID"}}},update:null,delete:null}}(this.tim),this.config.logout=function(e){return{create:null,query:{serverName:Ne.NAME.OPEN_IM,cmd:Ne.CMD.LOGOUT_ALL,channel:Ne.CHANNEL.XHR,protocol:Ae,method:"POST",queryString:{websdkappid:Me,v:Te,platform:De,a2:null!==e.context?e.context.a2Key:"",tinyid:null!==e.context?e.context.tinyID:"",sdkappid:null!==e.loginInfo?e.loginInfo.SDKAppID:0,contentType:null!==e.context?e.context.contentType:0,apn:null!==e.context?e.context.apn:"",reqtime:+new Date/1e3},requestData:{}},update:null,delete:null}}(this.tim),this.config.longPollLogout=function(e){return{create:null,query:{serverName:Ne.NAME.OPEN_IM,cmd:Ne.CMD.LOGOUT_LONG_POLL,channel:Ne.CHANNEL.XHR,protocol:Ae,method:"POST",queryString:{websdkappid:Me,v:Te,platform:De,a2:null!==e.context?e.context.a2Key:"",tinyid:null!==e.context?e.context.tinyID:0,sdkappid:null!==e.context?e.context.SDKAppID:0,contentType:null!==e.context?e.context.contentType:0,apn:null!==e.context?e.context.apn:1,reqtime:function(){return Date.now()}},requestData:{longPollID:""},keyMaps:{request:{longPollID:"LongPollingId"}}},update:null,delete:null}}(this.tim),this.config.profile=function(e){var t=Ro(e),n=Ne.NAME.PROFILE,r=Ne.CHANNEL.XHR,o=Ae,i=[];for(var a in ot)Object.prototype.hasOwnProperty.call(ot,a)&&i.push(ot[a]);return{query:{serverName:n,cmd:Ne.CMD.PORTRAIT_GET,channel:r,protocol:o,method:"POST",queryString:t,requestData:{fromAccount:"",toAccount:[],tagList:i}},update:{serverName:n,cmd:Ne.CMD.PORTRAIT_SET,channel:r,protocol:o,method:"POST",queryString:t,requestData:{fromAccount:"",profileItem:[{tag:ot.NICK,value:""},{tag:ot.GENDER,value:""},{tag:ot.ALLOWTYPE,value:""},{tag:ot.AVATAR,value:""}]}}}}(this.tim),this.config.group=function(e){var n={websdkappid:Me,v:Te,platform:De,a2:null!==e.context&&e.context.a2Key?e.context.a2Key:void 0,tinyid:null!==e.context&&e.context.tinyID?e.context.tinyID:void 0,sdkappid:null!==e.context?e.context.SDKAppID:0,contentType:null!==e.context?e.context.contentType:0,accounttype:null!==e.context?e.context.accountType:0},r={request:{ownerID:"Owner_Account",userID:"Member_Account",newOwnerID:"NewOwner_Account",maxMemberNum:"MaxMemberCount",groupCustomField:"AppDefinedData",memberCustomField:"AppMemberDefinedData",groupCustomFieldFilter:"AppDefinedDataFilter_Group",memberCustomFieldFilter:"AppDefinedDataFilter_GroupMember",messageRemindType:"MsgFlag",userIDList:"MemberList",groupIDList:"GroupIdList",applyMessage:"ApplyMsg",muteTime:"ShutUpTime",joinOption:"ApplyJoinOption"},response:{GroupIdList:"groups",MsgFlag:"messageRemindType",AppDefinedData:"groupCustomField",AppMemberDefinedData:"memberCustomField",AppDefinedDataFilter_Group:"groupCustomFieldFilter",AppDefinedDataFilter_GroupMember:"memberCustomFieldFilter",InfoSeq:"infoSequence",MemberList:"members",GroupInfo:"groups",ShutUpUntil:"muteUntil",ApplyJoinOption:"joinOption"}};return{create:{serverName:Ne.NAME.GROUP,cmd:Ne.CMD.CREATE_GROUP,channel:Ne.CHANNEL.XHR,protocol:Ae,queryString:n,requestData:{type:t.GRP_PRIVATE,name:void 0,groupID:void 0,ownerID:e.loginInfo.identifier,introduction:void 0,notification:void 0,avatar:void 0,maxMemberNum:void 0,joinOption:void 0,memberList:void 0,groupCustomField:void 0},keyMaps:r},list:{serverName:Ne.NAME.GROUP,cmd:Ne.CMD.GET_JOINED_GROUPS,channel:Ne.CHANNEL.XHR,protocol:Ae,queryString:n,requestData:{userID:e.loginInfo.identifier,limit:void 0,offset:void 0,groupType:void 0,responseFilter:void 0},keyMaps:r},query:{serverName:Ne.NAME.GROUP,cmd:Ne.CMD.GET_GROUP_INFO,channel:Ne.CHANNEL.XHR,protocol:Ae,queryString:n,requestData:{groupIDList:void 0,responseFilter:void 0},keyMaps:r},getGroupMemberList:{serverName:Ne.NAME.GROUP,cmd:Ne.CMD.GET_GROUP_MEMBER_INFO,channel:Ne.CHANNEL.XHR,protocol:Ae,queryString:n,requestData:{groupID:void 0,limit:0,offset:0,memberRoleFilter:void 0,memberInfoFilter:void 0},keyMaps:r},quitGroup:{serverName:Ne.NAME.GROUP,cmd:Ne.CMD.QUIT_GROUP,channel:Ne.CHANNEL.XHR,protocol:Ae,queryString:n,requestData:{groupID:void 0}},changeGroupOwner:{serverName:Ne.NAME.GROUP,cmd:Ne.CMD.CHANGE_GROUP_OWNER,channel:Ne.CHANNEL.XHR,protocol:Ae,queryString:n,requestData:{groupID:void 0,newOwnerID:void 0},keyMaps:r},destroyGroup:{serverName:Ne.NAME.GROUP,cmd:Ne.CMD.DESTROY_GROUP,channel:Ne.CHANNEL.XHR,protocol:Ae,queryString:n,requestData:{groupID:void 0}},updateGroupProfile:{serverName:Ne.NAME.GROUP,cmd:Ne.CMD.MODIFY_GROUP_INFO,channel:Ne.CHANNEL.XHR,protocol:Ae,queryString:n,requestData:{groupID:void 0,name:void 0,introduction:void 0,notification:void 0,avatar:void 0,maxMemberNum:void 0,joinOption:void 0,groupCustomField:void 0},keyMaps:{request:u({},r.request,{groupCustomField:"AppDefinedData"}),response:r.response}},modifyGroupMemberInfo:{serverName:Ne.NAME.GROUP,cmd:Ne.CMD.MODIFY_GROUP_MEMBER_INFO,channel:Ne.CHANNEL.XHR,protocol:Ae,queryString:n,requestData:{groupID:void 0,userID:void 0,messageRemindType:void 0,nameCard:void 0,role:void 0,memberCustomField:void 0,muteTime:void 0},keyMaps:r},addGroupMember:{serverName:Ne.NAME.GROUP,cmd:Ne.CMD.ADD_GROUP_MEMBER,channel:Ne.CHANNEL.XHR,protocol:Ae,queryString:n,requestData:{groupID:void 0,silence:void 0,userIDList:void 0},keyMaps:r},deleteGroupMember:{serverName:Ne.NAME.GROUP,cmd:Ne.CMD.DELETE_GROUP_MEMBER,channel:Ne.CHANNEL.XHR,protocol:Ae,queryString:n,requestData:{groupID:void 0,userIDList:void 0,reason:void 0},keyMaps:{request:{userIDList:"MemberToDel_Account"}}},searchGroupByID:{serverName:Ne.NAME.GROUP,cmd:Ne.CMD.SEARCH_GROUP_BY_ID,channel:Ne.CHANNEL.XHR,protocol:Ae,queryString:n,requestData:{groupIDList:void 0,responseFilter:{groupBasePublicInfoFilter:["Type","Name","Introduction","Notification","FaceUrl","CreateTime","Owner_Account","LastInfoTime","LastMsgTime","NextMsgSeq","MemberNum","MaxMemberNum","ApplyJoinOption"]}},keyMaps:{request:{groupIDList:"GroupIdList"}}},applyJoinGroup:{serverName:Ne.NAME.GROUP,cmd:Ne.CMD.APPLY_JOIN_GROUP,channel:Ne.CHANNEL.XHR,protocol:Ae,queryString:n,requestData:{groupID:void 0,applyMessage:void 0,userDefinedField:void 0},keyMaps:r},applyJoinAVChatRoom:{serverName:Ne.NAME.BIG_GROUP_NO_AUTH,cmd:Ne.CMD.APPLY_JOIN_GROUP,channel:Ne.CHANNEL.XHR,protocol:Ae,queryString:{websdkappid:Me,v:Te,platform:De,sdkappid:null!==e.context?e.context.SDKAppID:0,contentType:null!==e.context?e.context.contentType:0,accounttype:null!==e.context?e.context.accountType:0},requestData:{groupID:void 0,applyMessage:void 0,userDefinedField:void 0},keyMaps:r},handleApplyJoinGroup:{serverName:Ne.NAME.GROUP,cmd:Ne.CMD.HANDLE_APPLY_JOIN_GROUP,channel:Ne.CHANNEL.XHR,protocol:Ae,queryString:n,requestData:{groupID:void 0,applicant:void 0,handleAction:void 0,handleMessage:void 0,authentication:void 0,messageKey:void 0,userDefinedField:void 0},keyMaps:{request:{applicant:"Applicant_Account",handleAction:"HandleMsg",handleMessage:"ApprovalMsg",messageKey:"MsgKey"},response:{MsgKey:"messageKey"}}},deleteGroupSystemNotice:{serverName:Ne.NAME.OPEN_IM,cmd:Ne.CMD.DELETE_GROUP_SYSTEM_MESSAGE,channel:Ne.CHANNEL.XHR,protocol:Ae,queryString:n,requestData:{messageListToDelete:void 0},keyMaps:{request:{messageListToDelete:"DelMsgList",messageSeq:"MsgSeq",messageRandom:"MsgRandom"}}}}}(this.tim),this.config.longPollID=function(e){return{create:{},query:{serverName:Ne.NAME.OPEN_IM,cmd:Ne.CMD.GET_LONG_POLL_ID,channel:Ne.CHANNEL.XHR,protocol:Ae,queryString:{websdkappid:Me,v:Te,platform:De,a2:null!==e.context?e.context.a2Key:"",tinyid:null!==e.context?e.context.tinyID:0,sdkappid:null!==e.context?e.context.SDKAppID:0,contentType:null!==e.context?e.context.contentType:0,apn:null!==e.context?e.context.apn:1,reqtime:+new Date/1e3},requestData:{},keyMaps:{response:{LongPollingId:"longPollingID"}}},update:{},delete:{}}}(this.tim),this.config.longPoll=function(e){var t={websdkappid:Me,v:Te,platform:De,a2:null!==e.context?e.context.a2Key:"",tinyid:null!==e.context?e.context.tinyID:0,sdkappid:null!==e.context?e.context.SDKAppID:0,contentType:null!==e.context?e.context.contentType:0,accounttype:null!==e.context?e.loginInfo.accountType:0,apn:null!==e.context?e.context.apn:1,reqtime:Math.ceil(+new Date/1e3)};return{create:{},query:{serverName:Ne.NAME.OPEN_IM,cmd:Ne.CMD.LONG_POLL,channel:Ne.CHANNEL.AUTO,protocol:Ae,queryString:t,requestData:{timeout:null,cookie:{notifySeq:0,noticeSeq:0,longPollingID:0}},keyMaps:{response:{C2cMsgArray:"C2CMessageArray",GroupMsgArray:"groupMessageArray",GroupTips:"groupTips",C2cNotifyMsgArray:"C2CNotifyMessageArray",ClientSeq:"clientSequence",MsgPriority:"messagePriority",NoticeSeq:"noticeSequence",MsgContent:"content",MsgType:"type",MsgBody:"elements",ToGroupId:"to",Desc:"description",Ext:"extension",MsgFrom_AccountExtraInfo:"messageFromAccountExtraInformation"}}},update:{},delete:{}}}(this.tim),this.config.applyC2C=function(e){var t=Ro(e),n=Ne.NAME.FRIEND,r=Ne.CHANNEL.XHR,o=Ae;return{create:{serverName:n,cmd:Ne.CMD.FRIEND_ADD,channel:r,protocol:o,queryString:t,requestData:{fromAccount:"",addFriendItem:[]}},get:{serverName:n,cmd:Ne.CMD.GET_PENDENCY,channel:r,protocol:o,queryString:t,requestData:{fromAccount:"",pendencyType:"Pendency_Type_ComeIn"}},update:{serverName:n,cmd:Ne.CMD.RESPONSE_PENDENCY,channel:r,protocol:o,queryString:t,requestData:{fromAccount:"",responseFriendItem:[]}},delete:{serverName:n,cmd:Ne.CMD.DELETE_PENDENCY,channel:r,protocol:o,queryString:t,requestData:{fromAccount:"",toAccount:[],pendencyType:"Pendency_Type_ComeIn"}}}}(this.tim),this.config.friend=function(e){var t=Ro(e),n=Ne.NAME.FRIEND,r=Ne.CHANNEL.XHR,o=Ae;return{get:{serverName:n,cmd:Ne.CMD.FRIEND_GET_ALL,channel:r,protocol:o,method:"POST",queryString:t,requestData:{fromAccount:"",timeStamp:0,startIndex:0,getCount:100,lastStandardSequence:0,tagList:["Tag_Profile_IM_Nick","Tag_SNS_IM_Remark"]},keyMaps:{request:{},response:{}}},delete:{serverName:n,cmd:Ne.CMD.FRIEND_DELETE,channel:r,protocol:o,method:"POST",queryString:t,requestData:{fromAccount:"",toAccount:[],deleteType:"Delete_Type_Single"}}}}(this.tim),this.config.blacklist=function(e){var t=Ro(e);return{create:{serverName:Ne.NAME.FRIEND,cmd:Ne.CMD.ADD_BLACKLIST,channel:Ne.CHANNEL.XHR,protocol:Ae,method:"POST",queryString:t,requestData:{fromAccount:"",toAccount:[]}},get:{serverName:Ne.NAME.FRIEND,cmd:Ne.CMD.GET_BLACKLIST,channel:Ne.CHANNEL.XHR,protocol:Ae,method:"POST",queryString:t,requestData:{fromAccount:"",startIndex:0,maxLimited:30,lastSequence:0}},delete:{serverName:Ne.NAME.FRIEND,cmd:Ne.CMD.DELETE_BLACKLIST,channel:Ne.CHANNEL.XHR,protocol:Ae,method:"POST",queryString:t,requestData:{fromAccount:"",toAccount:[]}},update:{}}}(this.tim),this.config.c2cMessage=function(e){var t={platform:De,websdkappid:Me,v:Te,a2:null!==e.context?e.context.a2Key:"",tinyid:null!==e.context?e.context.tinyID:0,sdkappid:null!==e.context?e.context.SDKAppID:0,contentType:null!==e.context?e.context.contentType:0,apn:null!==e.context?e.context.apn:1,reqtime:function(){return+new Date}},n={request:{fromAccount:"From_Account",toAccount:"To_Account",msgTimeStamp:"MsgTimeStamp",msgSeq:"MsgSeq",msgRandom:"MsgRandom",msgBody:"MsgBody",count:"MaxCnt",lastMessageTime:"LastMsgTime",messageKey:"MsgKey",peerAccount:"Peer_Account",data:"Data",description:"Desc",extension:"Ext",type:"MsgType",content:"MsgContent",sizeType:"Type",uuid:"UUID",imageUrl:"URL",fileUrl:"Url",remoteAudioUrl:"Url",downloadFlag:"Download_Flag"},response:{MsgContent:"content",MsgTime:"time",Data:"data",Desc:"description",Ext:"extension",MsgKey:"messageKey",MsgType:"type",MsgBody:"elements",Download_Flag:"downloadFlag"}};return{create:{serverName:Ne.NAME.OPEN_IM,cmd:Ne.CMD.SEND_MESSAGE,channel:Ne.CHANNEL.XHR,protocol:Ae,method:"POST",queryString:t,requestData:{fromAccount:e.loginInfo.identifier,toAccount:"",msgTimeStamp:Math.ceil(+new Date/1e3),msgSeq:0,msgRandom:0,msgBody:[]},keyMaps:n},query:{serverName:Ne.NAME.OPEN_IM,cmd:Ne.CMD.GET_C2C_ROAM_MESSAGES,channel:Ne.CHANNEL.XHR,protocol:Ae,method:"POST",queryString:t,requestData:{peerAccount:"",count:15,lastMessageTime:0,messageKey:""},keyMaps:n},update:null,delete:null}}(this.tim),this.config.groupMessage=function(e){var t={platform:De,websdkappid:Me,v:Te,a2:null!==e.context?e.context.a2Key:"",tinyid:null!==e.context?e.context.tinyID:0,sdkappid:null!==e.context?e.context.SDKAppID:0,contentType:null!==e.context?e.context.contentType:0,apn:null!==e.context?e.context.apn:1,reqtime:function(){return+new Date}},n={request:{to:"GroupId",extension:"Ext",data:"Data",description:"Desc",random:"Random",sequence:"ReqMsgSeq",count:"ReqMsgNumber",type:"MsgType",content:"MsgContent",elements:"MsgBody",sizeType:"Type",uuid:"UUID",imageUrl:"URL",fileUrl:"Url",remoteAudioUrl:"Url",downloadFlag:"Download_Flag",clientSequence:"ClientSeq"},response:{Random:"random",MsgTime:"time",MsgSeq:"sequence",ReqMsgSeq:"sequence",RspMsgList:"messagesList",IsPlaceMsg:"isPlaceMessage",IsSystemMsg:"isSystemMessage",ToGroupId:"to",MsgFrom_AccountExtraInfo:"messageFromAccountExtraInformation",EnumFrom_AccountType:"fromAccountType",EnumTo_AccountType:"toAccountType",GroupCode:"groupCode",MsgFlag:"messageRemindType",MsgPriority:"messagePriority",MsgBody:"elements",MsgType:"type",MsgContent:"content",IsFinished:"complete",Download_Flag:"downloadFlag",ClientSeq:"clientSequence"}};return{create:{serverName:Ne.NAME.GROUP,cmd:Ne.CMD.SEND_GROUP_MESSAGE,channel:Ne.CHANNEL.XHR,protocol:Ae,method:"POST",queryString:t,requestData:{groupID:"",fromAccount:e.loginInfo.identifier,random:0,clientSequence:0,msgBody:[]},keyMaps:n},query:{serverName:Ne.NAME.GROUP,cmd:Ne.CMD.GET_GROUP_ROAM_MESSAGES,channel:Ne.CHANNEL.XHR,protocol:Ae,method:"POST",queryString:t,requestData:{groupID:"",count:15,sequence:""},keyMaps:n},update:null,delete:null}}(this.tim),this.config.conversation=function(e){var t={platform:De,websdkappid:Me,v:Te,a2:null!==e.context?e.context.a2Key:"",tinyid:null!==e.context?e.context.tinyID:0,sdkappid:null!==e.context?e.context.SDKAppID:0,contentType:null!==e.context?e.context.contentType:0,apn:null!==e.context?e.context.apn:1};return{query:{serverName:Ne.NAME.RECENT_CONTACT,cmd:Ne.CMD.GET_CONVERSATION_LIST,channel:Ne.CHANNEL.XHR,protocol:Ae,method:"POST",queryString:t,requestData:{fromAccount:e.loginInfo.identifier,count:0},keyMaps:{request:{},response:{SessionItem:"conversations",ToAccount:"groupID",To_Account:"userID",UnreadMsgCount:"unreadCount",MsgGroupReadedSeq:"messageReadSeq"}}},delete:{serverName:Ne.NAME.RECENT_CONTACT,cmd:Ne.CMD.DELETE_CONVERSATION,channel:Ne.CHANNEL.XHR,protocol:Ae,method:"POST",queryString:t,requestData:{fromAccount:e.loginInfo.identifier,toAccount:void 0,type:1,toGroupID:void 0},keyMaps:{request:{toGroupID:"ToGroupid"}}},setC2CMessageRead:{serverName:Ne.NAME.OPEN_IM,cmd:Ne.CMD.SET_C2C_MESSAGE_READ,channel:Ne.CHANNEL.XHR,protocol:Ae,method:"POST",queryString:t,requestData:{C2CMsgReaded:void 0},keyMaps:{request:{lastMessageTime:"LastedMsgTime"}}},setGroupMessageRead:{serverName:Ne.NAME.GROUP,cmd:Ne.CMD.SET_GROUP_MESSAGE_READ,channel:Ne.CHANNEL.XHR,protocol:Ae,method:"POST",queryString:t,requestData:{groupID:void 0,messageReadSeq:void 0},keyMaps:{request:{messageReadSeq:"MsgReadedSeq"}}}}}(this.tim),this.config.syncMessage=function(e){var t={platform:De,websdkappid:Me,v:Te,a2:null!==e.context?e.context.a2Key:"",tinyid:null!==e.context?e.context.tinyID:0,sdkappid:null!==e.context?e.context.SDKAppID:0,contentType:null!==e.context?e.context.contentType:0,apn:null!==e.context?e.context.apn:1,reqtime:function(){return[Math.ceil(+new Date),Math.random()].join("")}};return{create:null,query:{serverName:Ne.NAME.OPEN_IM,cmd:Ne.CMD.GET_MESSAGES,channel:Ne.CHANNEL.XHR,protocol:Ae,method:"POST",queryString:t,requestData:{cookie:"",syncFlag:0,needAbstract:1},keyMaps:{request:{fromAccount:"From_Account",toAccount:"To_Account",from:"From_Account",to:"To_Account",time:"MsgTimeStamp",sequence:"MsgSeq",random:"MsgRandom",elements:"MsgBody"},response:{MsgList:"messageList",SyncFlag:"syncFlag",To_Account:"to",From_Account:"from",ClientSeq:"clientSequence",MsgSeq:"sequence",NoticeSeq:"noticeSequence",NotifySeq:"notifySequence",MsgRandom:"random",MsgTimeStamp:"time",MsgContent:"content",ToGroupId:"groupID",MsgKey:"messageKey",GroupTips:"groupTips",MsgBody:"elements",MsgType:"type",C2CRemainingUnreadCount:"C2CRemainingUnreadList"}}},update:null,delete:null}}(this.tim),this.config.AVChatRoom=function(e){return{startLongPoll:{serverName:Ne.NAME.BIG_GROUP_LONG_POLLING_NO_AUTH,cmd:Ne.CMD.AVCHATROOM_LONG_POLL,channel:Ne.CHANNEL.XHR,protocol:Ae,method:"POST",queryString:{websdkappid:Me,v:Te,platform:De,sdkappid:e.loginInfo.SDKAppID,accounttype:"792",apn:null!==e.context?e.context.apn:1,reqtime:function(){return+new Date}},requestData:{USP:1,startSeq:1,holdTime:90,key:void 0},keyMaps:{request:{USP:"USP"},response:{ToGroupId:"groupID"}}}}}(this.tim),this.config.cosUpload=function(e){var t={platform:De,websdkappid:Me,v:Te,a2:null!==e.context?e.context.a2Key:"",tinyid:null!==e.context?e.context.tinyID:0,sdkappid:null!==e.context?e.context.SDKAppID:0,contentType:null!==e.context?e.context.contentType:0,apn:null!==e.context?e.context.apn:1,reqtime:function(){return Date.now()}};return{create:{serverName:Ne.NAME.OPEN_IM,cmd:Ne.CMD.FILE_UPLOAD,channel:Ne.CHANNEL.XHR,protocol:Ae,method:"POST",queryString:t,requestData:{appVersion:"2.1",fromAccount:"",toAccount:"",sequence:0,time:function(){return Math.ceil(Date.now()/1e3)},random:function(){return pe()},fileStrMd5:"",fileSize:"",serverVer:1,authKey:"",busiId:1,pkgFlag:1,sliceOffset:0,sliceSize:0,sliceData:"",contentType:"application/x-www-form-urlencoded"},keyMaps:{request:{},response:{}}},update:null,delete:null}}(this.tim),this.config.cosSig=function(e){var t={sdkappid:function(){return e.loginInfo.SDKAppID},identifier:function(){return e.loginInfo.identifier},userSig:function(){return e.context.userSig}};return{create:null,query:{serverName:Ne.NAME.IM_COS_SIGN,cmd:Ne.CMD.COS_SIGN,channel:Ne.CHANNEL.XHR,protocol:Ae,method:"POST",queryString:t,requestData:{cmd:"open_im_cos_svc",subCmd:"get_cos_token",duration:300,version:1},keyMaps:{request:{userSig:"usersig",subCmd:"sub_cmd",cmd:"cmd",duration:"duration",version:"version"},response:{expired_time:"expiredTime",bucket_name:"bucketName",session_token:"sessionToken",tmp_secret_id:"secretId",tmp_secret_key:"secretKey"}}},update:null,delete:null}}(this.tim)}},{key:"_initRequestData",value:function(e,t){if(void 0===e)return ke(t.requestData,this._getRequestMap(t),this.tim);var n=t.requestData,r=Object.create(null);for(var o in n)if(Object.prototype.hasOwnProperty.call(n,o)){if(r[o]="function"==typeof n[o]?n[o]():n[o],void 0===e[o])continue;r[o]=e[o]}return r=ke(r,this._getRequestMap(t),this.tim)}},{key:"_getRequestMap",value:function(e){if(e.keyMaps&&e.keyMaps.request&&Object.keys(e.keyMaps.request).length>0)return e.keyMaps.request}},{key:"_initEncoder",value:function(e){switch(e.protocol){case Ae:return function(e){if("string"===n(e))try{return JSON.parse(e)}catch(t){return e}return e};case Oe:return function(e){return e};default:return function(e){return Q.warn("PackageConfig._initEncoder(), unknow response type, data: ",JSON.stringify(e)),e}}}},{key:"_initDecoder",value:function(e){switch(e.protocol){case Ae:return function(e){if("string"===n(e))try{return JSON.parse(e)}catch(t){return e}return e};case Oe:return function(e){return e};default:return function(e){return Q.warn("PackageConfig._initDecoder(), unknow response type, data: ",e),e}}}}]),e}(),Go=function(t){function n(e){var t;return r(this,n),(t=g(this,l(n).call(this,e)))._initialization(),t}return c(n,Fe),i(n,[{key:"_initialization",value:function(){this._syncOffset="",this._syncNoticeList=[],this._syncEventArray=[],this._syncMessagesIsRunning=0,this._syncMessagesFinished=0,this._isLongPoll=0,this._longPollID=0,this._noticeSequence=0,this._initializeListener(),this._runLoop=null}},{key:"getLongPollID",value:function(){return this._longPollID}},{key:"_IAmReady",value:function(){this.triggerReady()}},{key:"reset",value:function(){this._noticeSequence=0,this._resetSync(),this.closeNoticeChannel()}},{key:"_resetSync",value:function(){this._syncOffset="",this._syncNoticeList=[],this._syncEventArray=[],this._syncMessagesIsRunning=0,this._syncMessagesFinished=0}},{key:"_setNoticeSeqInRequestData",value:function(e){e.Cookie.NoticeSeq=this._noticeSequence}},{key:"_updatenoticeSequence",value:function(e){if(e){var t=e[e.length-1].noticeSequence;!t||"number"!=typeof t||t<this._noticeSequence?this._noticeSequence++:this._noticeSequence=t}else this._noticeSequence++}},{key:"_initializeListener",value:function(){var e=this.tim.innerEmitter;e.on(Re.NOTICE_LONGPOLL_RESTART,this.restartNoticeChannel,this),e.on(Re.CONTEXT_A2KEY_AND_TINYID_UPDATED,this._startSyncMessages,this),e.on(Re.SYNC_MESSAGE_C2C_FINISHED,this.openNoticeChannel,this),e.on(Re.SIGN_LOGOUT_SUCCESS,this.closeNoticeChannel,this),e.on(Re.NOTICE_LONGPOLL_SOON_RECONNECT,this._onChannelReconnect,this),e.on(Re.NOTICE_LONGPOLL_DISCONNECT,this._onChannelDisconnected,this)}},{key:"openNoticeChannel",value:function(){Q.log("NotificationController.openNoticeChannel"),this._getLongPollID()}},{key:"closeNoticeChannel",value:function(){Q.log("NotificationController.closeNoticeChannel()"),(this._runLoop instanceof Rr||this._runLoop instanceof Pr)&&(this._runLoop.abort(),this._runLoop.stop()),this._longPollID=0,this._isLongPoll=0,this.tim.innerEmitter.emit(Re.NOTICE_LONGPOLL_STOPPED),this.tim.outerEmitter.emit(e.NOTICE_LONGPOLL_STOPPED)}},{key:"restartNoticeChannel",value:function(){this.closeNoticeChannel(),this.openNoticeChannel()}},{key:"_getLongPollID",value:function(){var e=this,t=this.tim,n=t.innerEmitter,r=t.connectionController;if(0===this._longPollID){var o=this.createPackage({name:"longPollID",action:"query"});r.request(o).then(function(t){t.data.errorCode===He.REQUEST.SUCCESS?e._onGetLongPollIDSuccess({data:t.data.longPollingID}):e._onGetLongPollIDFail({data:t.data})}).catch(function(e){n.emit(Re.NOTICE_LONGPOLL_GETID_FAIL,e)})}else this._onGetLongPollIDSuccess({data:this._longPollID})}},{key:"_onGetLongPollIDSuccess",value:function(e){this.tim.packageConfig.set({key:"long_poll_logout.query.requestData.longPollingID",value:e.data}),this.tim.packageConfig.set({key:"longPoll.query.requestData.cookie.longPollingID",value:e.data}),this._longPollID=e.data,this._startLongPoll(),this._IAmReady()}},{key:"_onGetLongPollIDFail",value:function(e){Q.warn("Notification._onGetLongPollIDFail",e)}},{key:"_startLongPoll",value:function(){if(1!=this._isLongPoll){Q.log("NotificationController._startLongPoll...");var e=this.tim,t=e.connectionController,n=e.innerEmitter,r=this.createPackage({name:"longPoll",action:"query"});this._isLongPoll=1,n.emit(Re.NOTICE_LONGPOLL_START,{data:Date.now()}),this._runLoop=t.createRunLoop({pack:r,before:this._setNoticeSeqInRequestData.bind(this),success:this._onNoticeReceived.bind(this),fail:this._onNoticeFail.bind(this)}),this._runLoop.start()}else Q.log("NotificationController._startLongPoll is running...")}},{key:"_onChannelReconnect",value:function(e){this.closeNoticeChannel(),this.syncMessage()}},{key:"_onChannelDisconnected",value:function(){}},{key:"_onNoticeReceived",value:function(e){var t=this.tim,n=t.innerEmitter,r=t.statusController,o=e.data,i=!r.getChannelStatus();if(n.emit(Re.NOTICE_LONGPOLL_REQUEST_ARRIVED,{data:Date.now()}),o.errorCode!==He.REQUEST.SUCCESS){if(o.errorCode===Ie.LONG_POLL_KICK_OUT)return n.emit(Re.NOTICE_LONGPOLL_KICKED_OUT),Q.log("NotificationController._onNoticeReceived(), longPollingID was kicked"),void this.closeNoticeChannel();Q.log("NotificationController._onNoticeReceived(), error: ".concat(o.errorCode,", errorInfo: ").concat(o.errorInfo)),n.emit(Re.ERROR_DETECTED,{code:o.errorCode,message:o.errorInfo})}e.data.eventArray&&1!=i&&this._eachEventArray(e.data.eventArray)}},{key:"_onNoticeFail",value:function(e){this.tim.innerEmitter.emit(Re.ERROR_DETECTED,e.error),this.tim.innerEmitter.emit(Re.NOTICE_LONGPOLL_REQUEST_NOT_ARRIVED,{data:Date.now()})}},{key:"_eachEventArray",value:function(e){var t=arguments.length>1&&void 0!==arguments[1]?arguments[1]:"poll";if(te(e)){var n=go("NotificationController._eachEventArray()");n.dot("start");for(var r=this.tim.innerEmitter,o=null,i="",a="",s=0,u=e.length;s<u;s++){o=e[s];var c=this._confirmCarrierType(o);n.dot("type ".concat(c));var l=Mo(o.event,c,",");switch(n.dot("condition ".concat(l)),l){case"9,1":this._updatenoticeSequence(o.C2CMessageArray),r.emit(Re.NOTICE_LONGPOLL_NEW_C2C_NOTICE,{data:o.C2CMessageArray,type:t}),n.dot("emit ".concat(Re.NOTICE_LONGPOLL_NEW_C2C_NOTICE));break;case"3,2":this._updatenoticeSequence(o.groupMessageArray),r.emit(Re.NOTICE_LONGPOLL_NEW_GROUP_MESSAGES,{data:o.groupMessageArray}),n.dot("emit ".concat(Re.NOTICE_LONGPOLL_NEW_GROUP_MESSAGES));break;case"4,3":this._updatenoticeSequence(o.groupTips),r.emit(Re.NOTICE_LONGPOLL_NEW_GROUP_TIPS,{data:o.groupTips}),n.dot("emit ".concat(Re.NOTICE_LONGPOLL_NEW_GROUP_TIPS));break;case"5,3":this._updatenoticeSequence(o.groupTips),r.emit(Re.NOTICE_LONGPOLL_NEW_GROUP_NOTICE,{data:{groupSystemNotices:o.groupTips,type:t}}),n.dot("emit ".concat(Re.NOTICE_LONGPOLL_NEW_GROUP_NOTICE));break;case"7,7":this._updatenoticeSequence(o.friendListMod),r.emit(Re.NOTICE_LONGPOLL_NEW_FRIEND_MESSAGES,{data:o.friendListMod}),n.dot("emit ".concat(Re.NOTICE_LONGPOLL_NEW_FRIEND_MESSAGES));break;case"8,6":this._updatenoticeSequence(o.profileModify),r.emit(Re.NOTICE_LONGPOLL_PROFILE_MODIFIED,{data:o.profileModify}),n.dot("emit ".concat(Re.NOTICE_LONGPOLL_PROFILE_MODIFIED));break;case"10,5":if(this._updatenoticeSequence(o.C2CNotifyMessageArray),this._isKickedoutNotice(o.C2CNotifyMessageArray))return void r.emit(Re.NOTICE_LONGPOLL_MUTIPLE_DEVICE_KICKED_OUT);if(this._isSysCmdMsgNotify(o.C2CNotifyMessageArray))return void r.emit(Re.NOTICE_LONGPOLL_RECEIVE_SYSTEM_ORDERS);Q.warn("NotificationController._eachEventArray() get Event condition : ".concat(l,", only increase noticeSequence"));break;case"3,0":r.emit(Re.NOTICE_LONGPOLL_NEW_GROUP_MESSAGES,{data:[o]}),n.dot("emit ".concat(Re.NOTICE_LONGPOLL_NEW_GROUP_MESSAGES));break;case"6,0":r.emit(Re.NOTICE_LONGPOLL_NEW_GROUP_TIPS,{data:[o]}),n.dot("emit ".concat(Re.NOTICE_LONGPOLL_NEW_GROUP_TIPS));break;case"5,0":r.emit(Re.NOTICE_LONGPOLL_NEW_GROUP_NOTICE,{data:{groupSystemNotices:[o],type:t}}),n.dot("emit ".concat(Re.NOTICE_LONGPOLL_NEW_GROUP_NOTICE));break;default:this._updatenoticeSequence(),i="".concat(Ie.NOTICE_RUNLOOP_UNEXPECTED_CONDITION),a="".concat(Se.NOTICE_RUNLOOP_UNEXPECTED_CONDITION,": ").concat(l),r.emit(Re.ERROR_DETECTED,new Ce({code:i,message:a,data:{condition:l,eventItem:o}})),n.dot("".concat(Re.ERROR_DETECTED,":").concat(i)),i=a=""}n.report()}}}},{key:"_confirmCarrierType",value:function(e){var t={C2CMessageArray:1,groupMessageArray:2,groupTips:3,messageList:4,C2CNotifyMessageArray:5,profileModify:6,friendListMod:7},n="";for(var r in e)if(t.hasOwnProperty(r)){n=r;break}return""===n?0:t.hasOwnProperty(n)?t[n]:0}},{key:"_isKickedoutNotice",value:function(e){return e[0].hasOwnProperty("kickoutMsgNotify")?1:0}},{key:"_isSysCmdMsgNotify",value:function(e){return e[0]&&e[0].hasOwnProperty("sysCmdMsgNotify")?1:0}},{key:"_startSyncMessages",value:function(e){1!=this._syncMessagesFinished&&this.syncMessage()}},{key:"syncMessage",value:function(){var e=this,t=arguments.length>0&&void 0!==arguments[0]?arguments[0]:"",n=arguments.length>1&&void 0!==arguments[1]?arguments[1]:0,r=this.tim,o=r.connectionController,i=r.innerEmitter;this._syncMessagesIsRunning=1;var a=this.createPackage({name:"syncMessage",action:"query",param:{cookie:t,syncFlag:n}});o.request(a).then(function(t){var n=t.data;switch(Mo(n.cookie,n.syncFlag)){case"00":case"01":i.emit(Re.ERROR_DETECTED,{code:Ie.NOTICE_RUNLOOP_OFFSET_LOST,message:Se.NOTICE_RUNLOOP_OFFSET_LOST});break;case"10":case"11":n.eventArray&&e._eachEventArray(n.eventArray,"sync"),e._syncNoticeList=e._syncNoticeList.concat(n.messageList),i.emit(Re.SYNC_MESSAGE_C2C_PROCESSING,{data:n.messageList,C2CRemainingUnreadList:n.C2CRemainingUnreadList}),e._syncOffset=n.cookie,e.syncMessage(n.cookie,n.syncFlag);break;case"12":n.eventArray&&e._eachEventArray(n.eventArray,"sync"),e._syncNoticeList=e._syncNoticeList.concat(n.messageList),i.emit(Re.SYNC_MESSAGE_C2C_FINISHED,{data:n.messageList,C2CRemainingUnreadList:n.C2CRemainingUnreadList}),e._syncOffset=n.cookie,e._syncNoticeList=[],e._syncMessagesIsRunning=0,e._syncMessagesFinished=1}}).catch(function(t){e._syncMessagesIsRunning=0,Q.error("NotificationController.syncMessage() failed, error:",JSON.stringify(t))})}}]),n}(),ko=function(e){function t(e){var n;return r(this,t),(n=g(this,l(t).call(this,e)))._initializeListener(),n}return c(t,Fe),i(t,[{key:"_initializeMembers",value:function(e){this.expiredTimeLimit=300,this.appid=e.appid||"",this.bucketName=e.bucketName||"",this.expiredTimeOut=e.expiredTimeOut||this.expiredTimeLimit,this.region="ap-shanghai",this.cos=null,this.cosOptions={secretId:e.secretId,secretKey:e.secretKey,sessionToken:e.sessionToken,expiredTime:e.expiredTime},this._initUploaderMethod()}},{key:"_expiredTimer",value:function(){var e=this,t=setInterval(function(){Math.ceil(Date.now()/1e3)>=e.cosOptions.expiredTime-20&&(e._isReady=0,e._getAuthorizationKey(),clearInterval(t))},1e4)}},{key:"_initializeListener",value:function(){this.tim.innerEmitter.on(Re.CONTEXT_A2KEY_AND_TINYID_UPDATED,this._initialization,this)}},{key:"_initialization",value:function(){this._initCOSSDKPlugin(),this.COSSDK?(this._initializeMembers({}),this._getAuthorizationKey()):Q.warn("UploadController 没有检测到上传插件，将无法发送图片、音频、视频、文件等类型的消息。")}},{key:"_getAuthorizationKey",value:function(){var e=this,t=Math.ceil(Date.now()/1e3),n=this.createPackage({name:"cosSig",action:"query",param:{duration:this.expiredTimeLimit}});this.tim.connectionController.request(n).then(function(n){n.data.expiredTimeOut=n.data.expiredTime-t,Q.log("UploadController._getAuthorizationKey timeout=".concat(n.data.expiredTimeOut,"s")),e._initializeMembers(n.data),e._expiredTimer(),e._initUploaderMethod()}).catch(function(e){Q.warn(e)})}},{key:"_initCOSSDKPlugin",value:function(){var e=b?"cos-wx-sdk":"cos-js-sdk";this.COSSDK=this.tim.getPlugin(e)}},{key:"_initUploaderMethod",value:function(){var e=this;this.appid&&(this.cos=b?new this.COSSDK({ForcePathStyle:1,getAuthorization:this._getAuthorization.bind(this)}):new this.COSSDK({getAuthorization:this._getAuthorization.bind(this)}),this._cosUploadMethod=b?function(t,n){e.cos.postObject(t,n)}:function(t,n){e.cos.uploadFiles(t,n)},this._IAmReady())}},{key:"_getAuthorization",value:function(e,t){t({TmpSecretId:this.cosOptions.secretId,TmpSecretKey:this.cosOptions.secretKey,XCosSecurityToken:this.cosOptions.sessionToken,ExpiredTime:this.cosOptions.expiredTime})}},{key:"_IAmReady",value:function(){this.triggerReady()}},{key:"uploadImage",value:function(e){if(!e.file)return ht(new Ce({code:Ie.MESSAGE_IMAGE_SELECT_FILE_FIRST,message:Se.MESSAGE_IMAGE_SELECT_FILE_FIRST}));var t=this._checkImageType(e.file);if(1!=t)return t;var n=this._checkImageMime(e.file);if(1!=n)return n;var r=this._checkImageSize(e.file);return 1!=r?r:this.upload(e)}},{key:"_checkImageType",value:function(e){var t="";return t=b?e.url.slice(e.url.lastIndexOf(".")+1):e.files[0].name.slice(e.files[0].name.lastIndexOf(".")+1),Ur.indexOf(t.toLowerCase())>=0?1:ht(new Ce({coe:Ie.MESSAGE_IMAGE_TYPES_LIMIT,message:Se.MESSAGE_IMAGE_TYPES_LIMIT}))}},{key:"_checkImageMime",value:function(e){return 1}},{key:"_checkImageSize",value:function(e){return(b?e.size:e.files[0].size)<20971520?1:ht(new Ce({coe:Ie.MESSAGE_IMAGE_SIZE_LIMIT,message:"".concat(Se.MESSAGE_IMAGE_SIZE_LIMIT,": ").concat(20971520," bytes")}))}},{key:"uploadFile",value:function(e){var t=null;return e.file?e.file.files[0].size>20971520?(t=new Ce({code:Ie.MESSAGE_FILE_SIZE_LIMIT,message:"".concat(Se.MESSAGE_FILE_SIZE_LIMIT,": ").concat(20971520," bytes")}),ht(t)):this.upload(e):(t=new Ce({code:Ie.MESSAGE_FILE_SELECT_FILE_FIRST,message:Se.MESSAGE_FILE_SELECT_FILE_FIRST}),ht(t))}},{key:"uploadVideo",value:function(e){return e.file?this.upload(e):ht()}},{key:"uploadAudio",value:function(e){return e.file?e.file.size>20971520?ht(new Ce({code:Ie.MESSAGE_AUDIO_SIZE_LIMIT,message:"".concat(Se.MESSAGE_AUDIO_SIZE_LIMIT,": ").concat(20971520," bytes")})):this.upload(e):ht(new Ce({code:Ie.MESSAGE_AUDIO_UPLOAD_FAIL,message:Se.MESSAGE_AUDIO_UPLOAD_FAIL}))}},{key:"upload",value:function(e){var t=this;Q.time(mt);var n=b?e.file:e.file.files[0];return new Promise(function(r,o){var i=b?t._createCosOptionsWXMiniApp(e):t._createCosOptionsWeb(e),a=t;t._cosUploadMethod(i,function(e,i){var s=Object.create(null);if(i){if(t._isUploadError(i,e))return o(i.files[0].error),void Q.warn("UploadController.upload failed, network error:".concat(i.files[0].error.error));s.fileName=n.name,s.fileSize=n.size,s.fileType=n.type.slice(n.type.indexOf("/")+1).toUpperCase(),s.location=b?i.Location:i.files[0].data.Location;var u=Q.timeEnd(mt),c=a._formatFileSize(n.size),l=a._formatSpeed(1e3*n.size/u),p="UploadController.upload success name=".concat(n.name,",size=").concat(c,",time=").concat(u,"ms,speed=").concat(l);return Q.log(p),void r(s)}Q.warn("UploadController.upload failed, error:".concat(e)),o(e)})})}},{key:"_isUploadError",value:function(e,t){return b?t?1:0:null!==e.files[0].error?1:0}},{key:"_formatFileSize",value:function(e){return e<1024?e+"B":e<1048576?Math.floor(e/1024)+"KB":Math.floor(e/1048576)+"MB"}},{key:"_formatSpeed",value:function(e){return e<=1048576?(e/1024).toFixed(1)+"KB/s":(e/1048576).toFixed(1)+"MB/s"}},{key:"_createCosOptionsWeb",value:function(e){var t=this.tim.context.identifier;return{files:[{Bucket:"".concat(this.bucketName,"-").concat(this.appid),Region:this.region,Key:"imfiles/".concat(t,"/").concat(e.to,"-").concat(pe(9999999),"-").concat(e.file.files[0].name),Body:e.file.files[0]}],SliceSize:1048576,onProgress:function(t){if("function"==typeof e.onProgress)try{e.onProgress(t.percent)}catch(n){Q.warn("onProgress callback error:"),Q.error(n)}},onFileFinish:function(e,t,n){}}}},{key:"_createCosOptionsWXMiniApp",value:function(e){var t=this.tim.context.identifier,n=e.file.url;return{Bucket:"".concat(this.bucketName,"-").concat(this.appid),Region:this.region,Key:"imfiles/".concat(t,"/").concat(e.to,"-").concat(e.file.name),FilePath:n,onProgress:function(t){if(Q.log(JSON.stringify(t)),"function"==typeof e.onProgress)try{e.onProgress(t.percent)}catch(n){Q.warn("onProgress callback error:"),Q.error(n)}}}}}]),t}(),wo={app_id:"",event_id:"",api_base:"https://pingtas.qq.com/pingd",prefix:"_mta_",version:"1.3.9",stat_share_app:0,stat_pull_down_fresh:0,stat_reach_bottom:0,stat_param:1};function bo(){try{var e="s"+Uo();return wx.setStorageSync(wo.prefix+"ssid",e),e}catch(t){}}function Uo(e){for(var t=[0,1,2,3,4,5,6,7,8,9],n=10;1<n;n--){var r=Math.floor(10*Math.random()),o=t[r];t[r]=t[n-1],t[n-1]=o}for(n=r=0;5>n;n++)r=10*r+t[n];return(e||"")+(r+"")+ +new Date}function Fo(){try{var e=getCurrentPages(),t="/";return 0<e.length&&(t=e.pop().__route__),t}catch(n){console.log("get current page path error:"+n)}}function qo(){var e,t={dm:"wechat.apps.xx",url:encodeURIComponent(Fo()+Ko(Bo.Data.pageQuery)),pvi:"",si:"",ty:0};return t.pvi=((e=function(){try{return wx.getStorageSync(wo.prefix+"auid")}catch(t){}}())||(e=function(){try{var t=Uo();return wx.setStorageSync(wo.prefix+"auid",t),t}catch(e){}}(),t.ty=1),e),t.si=function(){var e=function(){try{return wx.getStorageSync(wo.prefix+"ssid")}catch(e){}}();return e||(e=bo()),e}(),t}function xo(){var e=function(){var e=wx.getSystemInfoSync();return{adt:encodeURIComponent(e.model),scl:e.pixelRatio,scr:e.windowWidth+"x"+e.windowHeight,lg:e.language,fl:e.version,jv:encodeURIComponent(e.system),tz:encodeURIComponent(e.platform)}}();return function(e){wx.getNetworkType({success:function(t){e(t.networkType)}})}(function(e){try{wx.setStorageSync(wo.prefix+"ntdata",e)}catch(t){}}),e.ct=wx.getStorageSync(wo.prefix+"ntdata")||"4g",e}function Ho(){var e,t=Bo.Data.userInfo,n=[];for(e in t)t.hasOwnProperty(e)&&n.push(e+"="+t[e]);return t=n.join(";"),{r2:wo.app_id,r4:"wx",ext:"v="+wo.version+(null!==t&&""!==t?";ui="+encodeURIComponent(t):"")}}function Ko(e){if(!wo.stat_param||!e)return"";e=function(e){if(1>wo.ignore_params.length)return e;var t,n={};for(t in e)0<=wo.ignore_params.indexOf(t)||(n[t]=e[t]);return n}(e);var t,n=[];for(t in e)n.push(t+"="+e[t]);return 0<n.length?"?"+n.join("&"):""}var Bo={App:{init:function(e){"appID"in e&&(wo.app_id=e.appID),"eventID"in e&&(wo.event_id=e.eventID),"statShareApp"in e&&(wo.stat_share_app=e.statShareApp),"statPullDownFresh"in e&&(wo.stat_pull_down_fresh=e.statPullDownFresh),"statReachBottom"in e&&(wo.stat_reach_bottom=e.statReachBottom),"ignoreParams"in e&&(wo.ignore_params=e.ignoreParams),"statParam"in e&&(wo.stat_param=e.statParam),bo();try{"lauchOpts"in e&&(Bo.Data.lanchInfo=e.lauchOpts,Bo.Data.lanchInfo.landing=1)}catch(t){}"autoReport"in e&&e.autoReport&&function(){var e=Page;Page=function(t){var n=t.onLoad;t.onLoad=function(e){n&&n.call(this,e),Bo.Data.lastPageQuery=Bo.Data.pageQuery,Bo.Data.pageQuery=e,Bo.Data.lastPageUrl=Bo.Data.pageUrl,Bo.Data.pageUrl=Fo(),Bo.Data.show=0,Bo.Page.init()},e(t)}}()}},Page:{init:function(){var e,t=getCurrentPages()[getCurrentPages().length-1];t.onShow&&(e=t.onShow,t.onShow=function(){if(1==Bo.Data.show){var t=Bo.Data.lastPageQuery;Bo.Data.lastPageQuery=Bo.Data.pageQuery,Bo.Data.pageQuery=t,Bo.Data.lastPageUrl=Bo.Data.pageUrl,Bo.Data.pageUrl=Fo()}Bo.Data.show=1,Bo.Page.stat(),e.apply(this,arguments)}),wo.stat_pull_down_fresh&&t.onPullDownRefresh&&function(){var e=t.onPullDownRefresh;t.onPullDownRefresh=function(){Bo.Event.stat(wo.prefix+"pulldownfresh",{url:t.__route__}),e.apply(this,arguments)}}(),wo.stat_reach_bottom&&t.onReachBottom&&function(){var e=t.onReachBottom;t.onReachBottom=function(){Bo.Event.stat(wo.prefix+"reachbottom",{url:t.__route__}),e.apply(this,arguments)}}(),wo.stat_share_app&&t.onShareAppMessage&&function(){var e=t.onShareAppMessage;t.onShareAppMessage=function(){return Bo.Event.stat(wo.prefix+"shareapp",{url:t.__route__}),e.apply(this,arguments)}}()},multiStat:function(e,t){if(1==t)Bo.Page.stat(e);else{var n=getCurrentPages()[getCurrentPages().length-1];n.onShow&&function(){var t=n.onShow;n.onShow=function(){Bo.Page.stat(e),t.call(this,arguments)}}()}},stat:function(e){if(""!=wo.app_id){var t=[],n=Ho();if(e&&(n.r2=e),e=[qo(),n,xo()],Bo.Data.lanchInfo){e.push({ht:Bo.Data.lanchInfo.scene}),Bo.Data.pageQuery&&Bo.Data.pageQuery._mta_ref_id&&e.push({rarg:Bo.Data.pageQuery._mta_ref_id});try{1==Bo.Data.lanchInfo.landing&&(n.ext+=";lp=1",Bo.Data.lanchInfo.landing=0)}catch(i){}}e.push({rdm:"/",rurl:0>=Bo.Data.lastPageUrl.length?Bo.Data.pageUrl+Ko(Bo.Data.lastPageQuery):encodeURIComponent(Bo.Data.lastPageUrl+Ko(Bo.Data.lastPageQuery))}),e.push({rand:+new Date}),n=0;for(var r=e.length;n<r;n++)for(var o in e[n])e[n].hasOwnProperty(o)&&t.push(o+"="+(void 0===e[n][o]?"":e[n][o]));wx.request({url:wo.api_base+"?"+t.join("&").toLowerCase()})}}},Event:{stat:function(e,t){if(""!=wo.event_id){var n=[],r=qo(),o=Ho();r.dm="wxapps.click",r.url=e,o.r2=wo.event_id;var i,a=void 0===t?{}:t,s=[];for(i in a)a.hasOwnProperty(i)&&s.push(encodeURIComponent(i)+"="+encodeURIComponent(a[i]));for(a=s.join(";"),o.r5=a,a=0,o=(r=[r,o,xo(),{rand:+new Date}]).length;a<o;a++)for(var u in r[a])r[a].hasOwnProperty(u)&&n.push(u+"="+(void 0===r[a][u]?"":r[a][u]));wx.request({url:wo.api_base+"?"+n.join("&").toLowerCase()})}}},Data:{userInfo:null,lanchInfo:null,pageQuery:null,lastPageQuery:null,pageUrl:"",lastPageUrl:"",show:0}},Vo=Bo,Yo=function(){function e(){r(this,e),this.cache=[],this.MtaWX=null,this._init()}return i(e,[{key:"report",value:function(e,t){var n=this;try{w?window.MtaH5?(window.MtaH5.clickStat(e,t),this.cache.forEach(function(e){var t=e.name,r=e.param;window.MtaH5.clickStat(t,r),n.cache.shift()})):this.cache.push({name:e,param:t}):b&&(this.MtaWX?(this.MtaWX.Event.stat(e,t),this.cache.forEach(function(e){var t=e.name,r=e.param;n.MtaWX.stat(t,r),n.cache.shift()})):this.cache.push({name:e,param:t}))}catch(r){}}},{key:"stat",value:function(){try{w&&window.MtaH5?window.MtaH5.pgv():b&&this.MtaWX&&this.MtaWX.Page.stat()}catch(e){}}},{key:"_init",value:function(){try{if(w){window._mtac={autoReport:0};var e=document.createElement("script"),t=function(){if(b)return"https:";var e=window.location.protocol;return["http:","https:"].indexOf(e)<0&&(e="http:"),e}();e.src="".concat(t,"//pingjs.qq.com/h5/stats.js?v2.0.4"),e.setAttribute("name","MTAH5"),e.setAttribute("sid","500690998"),e.setAttribute("cid","500691017");var n=document.getElementsByTagName("script")[0];n.parentNode.insertBefore(e,n)}else b&&(this.MtaWX=Vo,this.MtaWX.App.init({appID:"500690995",eventID:"500691014",autoReport:0,statParam:1}))}catch(r){}}}]),e}(),jo=function(e){function t(e){var n;return r(this,t),(n=g(this,l(t).call(this,e))).tim=e,n.MTA=new Yo,n._initListener(),n}return c(t,Fe),i(t,[{key:"_initListener",value:function(){var e=this,t=this.tim.innerEmitter;this._sendMessageSuccessRateReport(),this._loginSuccessRateReport(),t.on(Re.SDK_READY,function(){e.MTA.report("sdkappid",{value:e.tim.context.SDKAppID}),e.MTA.report("version",{value:Zo.VERSION}),e.MTA.stat()})}},{key:"_sendMessageSuccessRateReport",value:function(){var e=this,t=this.tim.innerEmitter;t.on(Re.MESSAGE_SENDING,function(){e.MTA.report("sendmessage",{send:1})}),t.on(Re.MESSAGE_C2C_SEND_SUCCESS,function(){e.MTA.report("sendmessage",{success:1})}),t.on(Re.MESSAGE_C2C_SEND_FAIL,function(){e.MTA.report("sendmessage",{fail:1})}),t.on(Re.MESSAGE_GROUP_SEND_SUCCESS,function(){e.MTA.report("sendmessage",{success:1})}),t.on(Re.MESSAGE_GROUP_SEND_FAIL,function(){e.MTA.report("sendmessage",{fail:1})})}},{key:"_loginSuccessRateReport",value:function(){var e=this,t=this.tim.innerEmitter;t.on(Re.SIGN_LOGIN,function(){e.MTA.report("login",{login:1})}),t.on(Re.SIGN_LOGIN_SUCCESS,function(){e.MTA.report("login",{success:1})}),t.on(Re.SIGN_LOGIN_FAIL,function(){e.MTA.report("login",{fail:1})})}}]),t}(),zo=new(function(){function e(){r(this,e),this.map=new Map,this.thresholdValue=10}return i(e,[{key:"push",value:function(e,t){if(this.map.has(e)){var n=this.map.get(e);n.push(t),this.needReport(n)&&(this.report(n,e),this.map.delete(e))}else this.map.set(e,[t])}},{key:"needReport",value:function(e){return e.length===this.thresholdValue}},{key:"report",value:function(e,t){var n=e.reduce(function(e,t){return e+t})/e.length,r=Math.min.apply(null,e),o=Math.max.apply(null,e);Q.log("AverageCalculator.report ".concat(t," count=").concat(e.length," average=").concat(n,"ms max=").concat(o,"ms min=").concat(r,"ms"))}},{key:"reset",value:function(){this.map.clear()}}]),e}()),Wo=function(){function t(e){r(this,t),Ue.mixin(this),this.setLogLevel(0),this._initOptions(e),this._initMemberVariables(),this._initControllers(),this._initListener(),Q.info("SDK inWxMiniApp:".concat(b,", SDKAppID:").concat(e.SDKAppID)),Q.info("UserAgent:".concat(U))}return i(t,[{key:"login",value:function(e){return Q.time(ft),this.loginInfo.identifier=e.identifier||e.userID,this.loginInfo.userSig=e.userSig,this.signController.login(this.loginInfo)}},{key:"logout",value:function(){var e=this.signController.logout();return this.resetSDK(),e}},{key:"on",value:function(e,t,n){Q.debug("on","eventName:".concat(e)),this.outerEmitter.on(e,t,n||this)}},{key:"once",value:function(e,t,n){Q.debug("once","eventName:".concat(e)),this.outerEmitter.once(e,t,n||this)}},{key:"off",value:function(e,t,n,r){Q.debug("off","eventName:".concat(e)),this.outerEmitter.off(e,t,n,r)}},{key:"registerPlugin",value:function(e){var t=this;this.plugins||(this.plugins={}),Object.keys(e).forEach(function(n){t.plugins[n]=e[n]})}},{key:"getPlugin",value:function(e){return this.plugins[e]||void 0}},{key:"setLogLevel",value:function(e){Q.setLevel(e)}},{key:"downloadLog",value:function(){var e=document.createElement("a"),t=new Date,n=new Blob(this.getLog());e.download="TIM-"+t.getFullYear()+"-"+(t.getMonth()+1)+"-"+t.getDate()+"-"+this.loginInfo.SDKAppID+"-"+this.context.identifier+".txt",e.href=URL.createObjectURL(n),e.click(),URL.revokeObjectURL(n)}},{key:"destroy",value:function(){this.logout(),this.outerEmitter.emit(e.SDK_DESTROY,{SDKAppID:this.loginInfo.SDKAppID})}},{key:"createTextMessage",value:function(e){return this.messageController.createTextMessage(e)}},{key:"createImageMessage",value:function(e){return this.messageController.createImageMessage(e)}},{key:"createAudioMessage",value:function(e){return this.messageController.createAudioMessage(e)}},{key:"createFileMessage",value:function(e){return b?ht({code:Ie.MESSAGE_FILE_WECHAT_MINIAPP_NOT_SUPPORT,message:Se.MESSAGE_FILE_WECHAT_MINIAPP_NOT_SUPPORT}):this.messageController.createFileMessage(e)}},{key:"createFaceMessage",value:function(e){return this.messageController.createFaceMessage(e)}},{key:"createCustomMessage",value:function(e){return this.messageController.createCustomMessage(e)}},{key:"sendMessage",value:function(e){var t=this;return e instanceof oo?new Promise(function(n,r){e.afterOperated(function(e){t.messageController.sendMessageInstance(e).then(function(e){n(e)}).catch(function(e){r(e)})})}):ht(new Ce({code:Ie.MESSAGE_SEND_NEED_MESSAGE_INSTANCE,message:Se.MESSAGE_SEND_NEED_MESSAGE_INSTANCE}))}},{key:"resendMessage",value:function(e){return this.messageController.resendMessage(e)}},{key:"getMessageList",value:function(e){return this.messageController.getMessageList(e)}},{key:"setMessageRead",value:function(e){return this.messageController.setMessageRead(e)}},{key:"getConversationList",value:function(){return this.conversationController.getConversationList()}},{key:"getConversationProfile",value:function(e){return this.conversationController.getConversationProfile(e)}},{key:"deleteConversation",value:function(e){return this.conversationController.deleteConversation(e)}},{key:"getMyProfile",value:function(){return this.userController.getMyProfile()}},{key:"getUserProfile",value:function(e){return this.userController.getUserProfile(e)}},{key:"updateMyProfile",value:function(e){return this.userController.updateMyProfile(e)}},{key:"getFriendList",value:function(){return this.userController.getFriendList()}},{key:"deleteFriend",value:function(e){return this.userController.deleteFriend(e)}},{key:"getBlacklist",value:function(){return this.userController.getBlacklist()}},{key:"addToBlacklist",value:function(e){return this.userController.addBlacklist(e)}},{key:"removeFromBlacklist",value:function(e){return this.userController.deleteBlacklist(e)}},{key:"getGroupList",value:function(e){return this.groupController.getGroupList(e)}},{key:"getGroupProfile",value:function(e){return this.groupController.getGroupProfile(e)}},{key:"createGroup",value:function(e){return this.groupController.createGroup(e)}},{key:"dismissGroup",value:function(e){return this.groupController.dismissGroup(e)}},{key:"updateGroupProfile",value:function(e){return this.groupController.updateGroupProfile(e)}},{key:"joinGroup",value:function(e){return this.groupController.joinGroup(e)}},{key:"quitGroup",value:function(e){return this.groupController.quitGroup(e)}},{key:"searchGroupByID",value:function(e){return this.groupController.searchGroupByID(e)}},{key:"changeGroupOwner",value:function(e){return this.groupController.changeGroupOwner(e)}},{key:"handleGroupApplication",value:function(e){return this.groupController.handleGroupApplication(e)}},{key:"setMessageRemindType",value:function(e){return this.groupController.setMessageRemindType(e)}},{key:"getGroupMemberList",value:function(e){return this.groupController.getGroupMemberList(e)}},{key:"addGroupMember",value:function(e){return this.groupController.addGroupMember(e)}},{key:"deleteGroupMember",value:function(e){return this.groupController.deleteGroupMember(e)}},{key:"setGroupMemberMuteTime",value:function(e){return this.groupController.setGroupMemberMuteTime(e)}},{key:"setGroupMemberRole",value:function(e){return this.groupController.setGroupMemberRole(e)}},{key:"setGroupMemberNameCard",value:function(e){return this.groupController.setGroupMemberNameCard(e)}},{key:"setGroupMemberCustomField",value:function(e){return this.groupController.setGroupMemberCustomField(e)}},{key:"_initOptions",value:function(e){this.plugins={},this.loginInfo={SDKAppID:e.SDKAppID||null,accountType:pe(),identifier:null,userSig:null},this.options={runLoopNetType:e.runLoopNetType||tt,enablePointer:e.enablePointer||0}}},{key:"_initMemberVariables",value:function(){this.context=null,this.innerEmitter=new Lo,this.outerEmitter=new Lo,lt(this.outerEmitter),this.packageConfig=new Po(this),this.storage=new No(this),this.outerEmitter._emit=this.outerEmitter.emit,this.outerEmitter.emit=function(e,t){var n=arguments[0],r=[n,{name:arguments[0],data:arguments[1]}];Q.debug("emit ".concat(n),r[1]),this.outerEmitter._emit.apply(this.outerEmitter,r)}.bind(this)}},{key:"_initControllers",value:function(){this.exceptionController=new br(this),this.connectionController=new Gr(this),this.contextController=new Ke(this),this.signController=new Et(this),this.messageController=new yo(this),this.conversationController=new lo(this),this.userController=new jr(this),this.groupController=new To(this),this.notificationController=new Go(this),this.statusController=new Oo(this),this.uploadController=new ko(this),this.reporterController=new jo(this),this._initReadyListener()}},{key:"_initListener",value:function(){this.innerEmitter.on(Re.NOTICE_LONGPOLL_LONG_RECONNECT,this._onNoticeChannelReconnectedAfterLongTime,this)}},{key:"_initReadyListener",value:function(){for(var e=this,t=this.readyList,n=0,r=t.length;n<r;n++)this[t[n]].ready(function(){return e._readyHandle()})}},{key:"_onNoticeChannelReconnectedAfterLongTime",value:function(e){Q.log("reconnect after long time...",e),this.notificationController.closeNoticeChannel(),this.resetSDK(),this.login(this.loginInfo)}},{key:"resetSDK",value:function(){var t=this;this.initList.forEach(function(e){t[e].reset&&t[e].reset()}),this.storage.reset(),zo.reset(),this.resetReady(),this._initReadyListener(),this.outerEmitter.emit(e.SDK_NOT_READY)}},{key:"_readyHandle",value:function(){for(var t=this.readyList,n=1,r=0,o=t.length;r<o;r++)if(!this[t[r]].isReady()){n=0;break}n&&(Q.warn("SDK is ready. cost=".concat(Q.timeEnd(ft),"ms")),this.triggerReady(),this.innerEmitter.emit(Re.SDK_READY),this.outerEmitter.emit(e.SDK_READY))}}]),t}();Wo.prototype.readyList=["conversationController"],Wo.prototype.initList=["exceptionController","connectionController","signController","contextController","messageController","conversationController","userController","groupController","notificationController"];var Xo={login:"login",on:"on",off:"off",ready:"ready",setLogLevel:"setLogLevel",joinGroup:"joinGroup",registerPlugin:"registerPlugin"};function Jo(e,t,n){if(e||void 0!==Xo[t])return 1;n.innerEmitter.emit(Re.ERROR_DETECTED,new Ce({code:Ie.SDK_IS_NOT_READY,message:"".concat(Se.SDK_IS_NOT_READY," ").concat(t)}))}var Qo={},Zo={};return Zo.create=function(t){if(t.SDKAppID&&Qo[t.SDKAppID])return Qo[t.SDKAppID];Q.log("TIM.create");var n=new Wo(t);n.on(e.SDK_DESTROY,function(e){Qo[e.data.SDKAppID]=null,delete Qo[e.data.SDKAppID]});var r=function(e){var t=Object.create(null);return Object.keys(ve).forEach(function(n){if(e[n]){var r=ve[n],o=new E;t[r]=function(){var t=Array.from(arguments);return o.use(function(t,r){if(Jo(e.isReady(),n,e))return r()}).use(function(e,t){if(1==P(e,ye[n],r))return t()}).use(function(t,r){return e[n].apply(e,t)}),o.run(t)}}}),t}(n);return Qo[t.SDKAppID]=r,Q.log("TIM.create ok"),r},Zo.TYPES=t,Zo.EVENT=e,Zo.VERSION="2.1.3",Q.log("TIM.VERSION: ".concat(Zo.VERSION)),Zo});

/* WEBPACK VAR INJECTION */}.call(exports, __webpack_require__(8)))

/***/ }),
/* 44 */,
/* 45 */,
/* 46 */
/***/ (function(module, exports, __webpack_require__) {

module.exports = { "default": __webpack_require__(47), __esModule: true };

/***/ }),
/* 47 */
/***/ (function(module, exports, __webpack_require__) {

__webpack_require__(48);
__webpack_require__(63);
module.exports = __webpack_require__(6).Array.from;


/***/ }),
/* 48 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

var $at = __webpack_require__(49)(true);

// 21.1.3.27 String.prototype[@@iterator]()
__webpack_require__(50)(String, 'String', function (iterated) {
  this._t = String(iterated); // target
  this._i = 0;                // next index
// 21.1.5.2.1 %StringIteratorPrototype%.next()
}, function () {
  var O = this._t;
  var index = this._i;
  var point;
  if (index >= O.length) return { value: undefined, done: true };
  point = $at(O, index);
  this._i += point.length;
  return { value: point, done: false };
});


/***/ }),
/* 49 */
/***/ (function(module, exports, __webpack_require__) {

var toInteger = __webpack_require__(14);
var defined = __webpack_require__(15);
// true  -> String#at
// false -> String#codePointAt
module.exports = function (TO_STRING) {
  return function (that, pos) {
    var s = String(defined(that));
    var i = toInteger(pos);
    var l = s.length;
    var a, b;
    if (i < 0 || i >= l) return TO_STRING ? '' : undefined;
    a = s.charCodeAt(i);
    return a < 0xd800 || a > 0xdbff || i + 1 === l || (b = s.charCodeAt(i + 1)) < 0xdc00 || b > 0xdfff
      ? TO_STRING ? s.charAt(i) : a
      : TO_STRING ? s.slice(i, i + 2) : (a - 0xd800 << 10) + (b - 0xdc00) + 0x10000;
  };
};


/***/ }),
/* 50 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

var LIBRARY = __webpack_require__(24);
var $export = __webpack_require__(16);
var redefine = __webpack_require__(54);
var hide = __webpack_require__(9);
var Iterators = __webpack_require__(20);
var $iterCreate = __webpack_require__(55);
var setToStringTag = __webpack_require__(35);
var getPrototypeOf = __webpack_require__(62);
var ITERATOR = __webpack_require__(4)('iterator');
var BUGGY = !([].keys && 'next' in [].keys()); // Safari has buggy iterators w/o `next`
var FF_ITERATOR = '@@iterator';
var KEYS = 'keys';
var VALUES = 'values';

var returnThis = function () { return this; };

module.exports = function (Base, NAME, Constructor, next, DEFAULT, IS_SET, FORCED) {
  $iterCreate(Constructor, NAME, next);
  var getMethod = function (kind) {
    if (!BUGGY && kind in proto) return proto[kind];
    switch (kind) {
      case KEYS: return function keys() { return new Constructor(this, kind); };
      case VALUES: return function values() { return new Constructor(this, kind); };
    } return function entries() { return new Constructor(this, kind); };
  };
  var TAG = NAME + ' Iterator';
  var DEF_VALUES = DEFAULT == VALUES;
  var VALUES_BUG = false;
  var proto = Base.prototype;
  var $native = proto[ITERATOR] || proto[FF_ITERATOR] || DEFAULT && proto[DEFAULT];
  var $default = $native || getMethod(DEFAULT);
  var $entries = DEFAULT ? !DEF_VALUES ? $default : getMethod('entries') : undefined;
  var $anyNative = NAME == 'Array' ? proto.entries || $native : $native;
  var methods, key, IteratorPrototype;
  // Fix native
  if ($anyNative) {
    IteratorPrototype = getPrototypeOf($anyNative.call(new Base()));
    if (IteratorPrototype !== Object.prototype && IteratorPrototype.next) {
      // Set @@toStringTag to native iterators
      setToStringTag(IteratorPrototype, TAG, true);
      // fix for some old engines
      if (!LIBRARY && typeof IteratorPrototype[ITERATOR] != 'function') hide(IteratorPrototype, ITERATOR, returnThis);
    }
  }
  // fix Array#{values, @@iterator}.name in V8 / FF
  if (DEF_VALUES && $native && $native.name !== VALUES) {
    VALUES_BUG = true;
    $default = function values() { return $native.call(this); };
  }
  // Define iterator
  if ((!LIBRARY || FORCED) && (BUGGY || VALUES_BUG || !proto[ITERATOR])) {
    hide(proto, ITERATOR, $default);
  }
  // Plug for library
  Iterators[NAME] = $default;
  Iterators[TAG] = returnThis;
  if (DEFAULT) {
    methods = {
      values: DEF_VALUES ? $default : getMethod(VALUES),
      keys: IS_SET ? $default : getMethod(KEYS),
      entries: $entries
    };
    if (FORCED) for (key in methods) {
      if (!(key in proto)) redefine(proto, key, methods[key]);
    } else $export($export.P + $export.F * (BUGGY || VALUES_BUG), NAME, methods);
  }
  return methods;
};


/***/ }),
/* 51 */
/***/ (function(module, exports) {

module.exports = function (it) {
  if (typeof it != 'function') throw TypeError(it + ' is not a function!');
  return it;
};


/***/ }),
/* 52 */
/***/ (function(module, exports, __webpack_require__) {

module.exports = !__webpack_require__(7) && !__webpack_require__(18)(function () {
  return Object.defineProperty(__webpack_require__(26)('div'), 'a', { get: function () { return 7; } }).a != 7;
});


/***/ }),
/* 53 */
/***/ (function(module, exports, __webpack_require__) {

// 7.1.1 ToPrimitive(input [, PreferredType])
var isObject = __webpack_require__(17);
// instead of the ES6 spec version, we didn't implement @@toPrimitive case
// and the second argument - flag - preferred type is a string
module.exports = function (it, S) {
  if (!isObject(it)) return it;
  var fn, val;
  if (S && typeof (fn = it.toString) == 'function' && !isObject(val = fn.call(it))) return val;
  if (typeof (fn = it.valueOf) == 'function' && !isObject(val = fn.call(it))) return val;
  if (!S && typeof (fn = it.toString) == 'function' && !isObject(val = fn.call(it))) return val;
  throw TypeError("Can't convert object to primitive value");
};


/***/ }),
/* 54 */
/***/ (function(module, exports, __webpack_require__) {

module.exports = __webpack_require__(9);


/***/ }),
/* 55 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

var create = __webpack_require__(56);
var descriptor = __webpack_require__(19);
var setToStringTag = __webpack_require__(35);
var IteratorPrototype = {};

// 25.1.2.1.1 %IteratorPrototype%[@@iterator]()
__webpack_require__(9)(IteratorPrototype, __webpack_require__(4)('iterator'), function () { return this; });

module.exports = function (Constructor, NAME, next) {
  Constructor.prototype = create(IteratorPrototype, { next: descriptor(1, next) });
  setToStringTag(Constructor, NAME + ' Iterator');
};


/***/ }),
/* 56 */
/***/ (function(module, exports, __webpack_require__) {

// 19.1.2.2 / 15.2.3.5 Object.create(O [, Properties])
var anObject = __webpack_require__(11);
var dPs = __webpack_require__(57);
var enumBugKeys = __webpack_require__(34);
var IE_PROTO = __webpack_require__(21)('IE_PROTO');
var Empty = function () { /* empty */ };
var PROTOTYPE = 'prototype';

// Create object with fake `null` prototype: use iframe Object with cleared prototype
var createDict = function () {
  // Thrash, waste and sodomy: IE GC bug
  var iframe = __webpack_require__(26)('iframe');
  var i = enumBugKeys.length;
  var lt = '<';
  var gt = '>';
  var iframeDocument;
  iframe.style.display = 'none';
  __webpack_require__(61).appendChild(iframe);
  iframe.src = 'javascript:'; // eslint-disable-line no-script-url
  // createDict = iframe.contentWindow.Object;
  // html.removeChild(iframe);
  iframeDocument = iframe.contentWindow.document;
  iframeDocument.open();
  iframeDocument.write(lt + 'script' + gt + 'document.F=Object' + lt + '/script' + gt);
  iframeDocument.close();
  createDict = iframeDocument.F;
  while (i--) delete createDict[PROTOTYPE][enumBugKeys[i]];
  return createDict();
};

module.exports = Object.create || function create(O, Properties) {
  var result;
  if (O !== null) {
    Empty[PROTOTYPE] = anObject(O);
    result = new Empty();
    Empty[PROTOTYPE] = null;
    // add "__proto__" for Object.getPrototypeOf polyfill
    result[IE_PROTO] = O;
  } else result = createDict();
  return Properties === undefined ? result : dPs(result, Properties);
};


/***/ }),
/* 57 */
/***/ (function(module, exports, __webpack_require__) {

var dP = __webpack_require__(10);
var anObject = __webpack_require__(11);
var getKeys = __webpack_require__(27);

module.exports = __webpack_require__(7) ? Object.defineProperties : function defineProperties(O, Properties) {
  anObject(O);
  var keys = getKeys(Properties);
  var length = keys.length;
  var i = 0;
  var P;
  while (length > i) dP.f(O, P = keys[i++], Properties[P]);
  return O;
};


/***/ }),
/* 58 */
/***/ (function(module, exports, __webpack_require__) {

var has = __webpack_require__(12);
var toIObject = __webpack_require__(28);
var arrayIndexOf = __webpack_require__(59)(false);
var IE_PROTO = __webpack_require__(21)('IE_PROTO');

module.exports = function (object, names) {
  var O = toIObject(object);
  var i = 0;
  var result = [];
  var key;
  for (key in O) if (key != IE_PROTO) has(O, key) && result.push(key);
  // Don't enum bug & hidden keys
  while (names.length > i) if (has(O, key = names[i++])) {
    ~arrayIndexOf(result, key) || result.push(key);
  }
  return result;
};


/***/ }),
/* 59 */
/***/ (function(module, exports, __webpack_require__) {

// false -> Array#indexOf
// true  -> Array#includes
var toIObject = __webpack_require__(28);
var toLength = __webpack_require__(31);
var toAbsoluteIndex = __webpack_require__(60);
module.exports = function (IS_INCLUDES) {
  return function ($this, el, fromIndex) {
    var O = toIObject($this);
    var length = toLength(O.length);
    var index = toAbsoluteIndex(fromIndex, length);
    var value;
    // Array#includes uses SameValueZero equality algorithm
    // eslint-disable-next-line no-self-compare
    if (IS_INCLUDES && el != el) while (length > index) {
      value = O[index++];
      // eslint-disable-next-line no-self-compare
      if (value != value) return true;
    // Array#indexOf ignores holes, Array#includes - not
    } else for (;length > index; index++) if (IS_INCLUDES || index in O) {
      if (O[index] === el) return IS_INCLUDES || index || 0;
    } return !IS_INCLUDES && -1;
  };
};


/***/ }),
/* 60 */
/***/ (function(module, exports, __webpack_require__) {

var toInteger = __webpack_require__(14);
var max = Math.max;
var min = Math.min;
module.exports = function (index, length) {
  index = toInteger(index);
  return index < 0 ? max(index + length, 0) : min(index, length);
};


/***/ }),
/* 61 */
/***/ (function(module, exports, __webpack_require__) {

var document = __webpack_require__(5).document;
module.exports = document && document.documentElement;


/***/ }),
/* 62 */
/***/ (function(module, exports, __webpack_require__) {

// 19.1.2.9 / 15.2.3.2 Object.getPrototypeOf(O)
var has = __webpack_require__(12);
var toObject = __webpack_require__(22);
var IE_PROTO = __webpack_require__(21)('IE_PROTO');
var ObjectProto = Object.prototype;

module.exports = Object.getPrototypeOf || function (O) {
  O = toObject(O);
  if (has(O, IE_PROTO)) return O[IE_PROTO];
  if (typeof O.constructor == 'function' && O instanceof O.constructor) {
    return O.constructor.prototype;
  } return O instanceof Object ? ObjectProto : null;
};


/***/ }),
/* 63 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

var ctx = __webpack_require__(25);
var $export = __webpack_require__(16);
var toObject = __webpack_require__(22);
var call = __webpack_require__(64);
var isArrayIter = __webpack_require__(65);
var toLength = __webpack_require__(31);
var createProperty = __webpack_require__(66);
var getIterFn = __webpack_require__(67);

$export($export.S + $export.F * !__webpack_require__(69)(function (iter) { Array.from(iter); }), 'Array', {
  // 22.1.2.1 Array.from(arrayLike, mapfn = undefined, thisArg = undefined)
  from: function from(arrayLike /* , mapfn = undefined, thisArg = undefined */) {
    var O = toObject(arrayLike);
    var C = typeof this == 'function' ? this : Array;
    var aLen = arguments.length;
    var mapfn = aLen > 1 ? arguments[1] : undefined;
    var mapping = mapfn !== undefined;
    var index = 0;
    var iterFn = getIterFn(O);
    var length, result, step, iterator;
    if (mapping) mapfn = ctx(mapfn, aLen > 2 ? arguments[2] : undefined, 2);
    // if object isn't iterable or it's array with default iterator - use simple case
    if (iterFn != undefined && !(C == Array && isArrayIter(iterFn))) {
      for (iterator = iterFn.call(O), result = new C(); !(step = iterator.next()).done; index++) {
        createProperty(result, index, mapping ? call(iterator, mapfn, [step.value, index], true) : step.value);
      }
    } else {
      length = toLength(O.length);
      for (result = new C(length); length > index; index++) {
        createProperty(result, index, mapping ? mapfn(O[index], index) : O[index]);
      }
    }
    result.length = index;
    return result;
  }
});


/***/ }),
/* 64 */
/***/ (function(module, exports, __webpack_require__) {

// call something on iterator step with safe closing on error
var anObject = __webpack_require__(11);
module.exports = function (iterator, fn, value, entries) {
  try {
    return entries ? fn(anObject(value)[0], value[1]) : fn(value);
  // 7.4.6 IteratorClose(iterator, completion)
  } catch (e) {
    var ret = iterator['return'];
    if (ret !== undefined) anObject(ret.call(iterator));
    throw e;
  }
};


/***/ }),
/* 65 */
/***/ (function(module, exports, __webpack_require__) {

// check on default Array iterator
var Iterators = __webpack_require__(20);
var ITERATOR = __webpack_require__(4)('iterator');
var ArrayProto = Array.prototype;

module.exports = function (it) {
  return it !== undefined && (Iterators.Array === it || ArrayProto[ITERATOR] === it);
};


/***/ }),
/* 66 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

var $defineProperty = __webpack_require__(10);
var createDesc = __webpack_require__(19);

module.exports = function (object, index, value) {
  if (index in object) $defineProperty.f(object, index, createDesc(0, value));
  else object[index] = value;
};


/***/ }),
/* 67 */
/***/ (function(module, exports, __webpack_require__) {

var classof = __webpack_require__(68);
var ITERATOR = __webpack_require__(4)('iterator');
var Iterators = __webpack_require__(20);
module.exports = __webpack_require__(6).getIteratorMethod = function (it) {
  if (it != undefined) return it[ITERATOR]
    || it['@@iterator']
    || Iterators[classof(it)];
};


/***/ }),
/* 68 */
/***/ (function(module, exports, __webpack_require__) {

// getting tag from 19.1.3.6 Object.prototype.toString()
var cof = __webpack_require__(30);
var TAG = __webpack_require__(4)('toStringTag');
// ES3 wrong here
var ARG = cof(function () { return arguments; }()) == 'Arguments';

// fallback for IE11 Script Access Denied error
var tryGet = function (it, key) {
  try {
    return it[key];
  } catch (e) { /* empty */ }
};

module.exports = function (it) {
  var O, T, B;
  return it === undefined ? 'Undefined' : it === null ? 'Null'
    // @@toStringTag case
    : typeof (T = tryGet(O = Object(it), TAG)) == 'string' ? T
    // builtinTag case
    : ARG ? cof(O)
    // ES3 arguments fallback
    : (B = cof(O)) == 'Object' && typeof O.callee == 'function' ? 'Arguments' : B;
};


/***/ }),
/* 69 */
/***/ (function(module, exports, __webpack_require__) {

var ITERATOR = __webpack_require__(4)('iterator');
var SAFE_CLOSING = false;

try {
  var riter = [7][ITERATOR]();
  riter['return'] = function () { SAFE_CLOSING = true; };
  // eslint-disable-next-line no-throw-literal
  Array.from(riter, function () { throw 2; });
} catch (e) { /* empty */ }

module.exports = function (exec, skipClosing) {
  if (!skipClosing && !SAFE_CLOSING) return false;
  var safe = false;
  try {
    var arr = [7];
    var iter = arr[ITERATOR]();
    iter.next = function () { return { done: safe = true }; };
    arr[ITERATOR] = function () { return iter; };
    exec(arr);
  } catch (e) { /* empty */ }
  return safe;
};


/***/ }),
/* 70 */,
/* 71 */,
/* 72 */,
/* 73 */,
/* 74 */
/***/ (function(module, exports, __webpack_require__) {

!function(e,t){ true?module.exports=t():"function"==typeof define&&define.amd?define([],t):"object"==typeof exports?exports.COS=t():e.COS=t()}(this,function(){return function(e){function t(r){if(n[r])return n[r].exports;var o=n[r]={i:r,l:!1,exports:{}};return e[r].call(o.exports,o,o.exports,t),o.l=!0,o.exports}var n={};return t.m=e,t.c=n,t.i=function(e){return e},t.d=function(e,n,r){t.o(e,n)||Object.defineProperty(e,n,{configurable:!1,enumerable:!0,get:r})},t.n=function(e){var n=e&&e.__esModule?function(){return e.default}:function(){return e};return t.d(n,"a",n),n},t.o=function(e,t){return Object.prototype.hasOwnProperty.call(e,t)},t.p="D:\\github\\cos-wx-sdk-v5\\demo\\lib",t(t.s=4)}([function(e,t,n){"use strict";function r(e){return encodeURIComponent(e).replace(/!/g,"%21").replace(/'/g,"%27").replace(/\(/g,"%28").replace(/\)/g,"%29").replace(/\*/g,"%2A")}function o(e){return u(e,function(e){return"object"==typeof e?o(e):e})}function i(e,t){return c(t,function(n,r){e[r]=t[r]}),e}function a(e){return e instanceof Array}function s(e,t){for(var n=!1,r=0;r<e.length;r++)if(t===e[r]){n=!0;break}return n}function c(e,t){for(var n in e)e.hasOwnProperty(n)&&t(e[n],n)}function u(e,t){var n=a(e)?[]:{};for(var r in e)e.hasOwnProperty(r)&&(n[r]=t(e[r],r));return n}function l(e,t){var n=a(e),r=n?[]:{};for(var o in e)e.hasOwnProperty(o)&&t(e[o],o)&&(n?r.push(e[o]):r[o]=e[o]);return r}var d=n(8),f=n(6),h=n(10),p=n(7),m=n(5),g=m.btoa,y=function(e){e=e||{};var t=e.SecretId,n=e.SecretKey,i=(e.method||e.Method||"get").toLowerCase(),a=o(e.Query||e.params||{}),s=o(e.Headers||e.headers||{}),c=e.Pathname||"/"+(e.Key||"");if(!t)return console.error("missing param SecretId");if(!n)return console.error("missing param SecretKey");var u=function(e){var t=[];for(var n in e)e.hasOwnProperty(n)&&t.push(n);return t.sort(function(e,t){return e=e.toLowerCase(),t=t.toLowerCase(),e===t?0:e>t?1:-1})},l=function(e){var t,n,o,i=[],a=u(e);for(t=0;t<a.length;t++)n=a[t],o=void 0===e[n]||null===e[n]?"":""+e[n],n=n.toLowerCase(),n=r(n),o=r(o)||"",i.push(n+"="+o);return i.join("&")},d=Math.round(_(e.SystemClockOffset)/1e3)-1,h=d,p=e.Expires||e.expires;h+=void 0===p?900:1*p||0;var m=t,g=d+";"+h,y=d+";"+h,C=u(s).join(";").toLowerCase(),v=u(a).join(";").toLowerCase(),x=f.HmacSHA1(y,n).toString(),k=[i,c,l(a),l(s),""].join("\n"),S=["sha1",g,f.SHA1(k).toString(),""].join("\n");return["q-sign-algorithm=sha1","q-ak="+m,"q-sign-time="+g,"q-key-time="+y,"q-header-list="+C,"q-url-param-list="+v,"q-signature="+f.HmacSHA1(S,x).toString()].join("&")},C=function(){},v=function(e){var t={};for(var n in e)e.hasOwnProperty(n)&&void 0!==e[n]&&null!==e[n]&&(t[n]=e[n]);return t},x=function(e,t){var n,r=new FileReader;FileReader.prototype.readAsBinaryString?(n=FileReader.prototype.readAsBinaryString,r.onload=function(){t(this.result)}):FileReader.prototype.readAsArrayBuffer?n=function(e){var n="",r=new FileReader;r.onload=function(e){for(var o=new Uint8Array(r.result),i=o.byteLength,a=0;a<i;a++)n+=String.fromCharCode(o[a]);t(n)},r.readAsArrayBuffer(e)}:console.error("FileReader not support readAsBinaryString"),n.call(r,e)},k=function(e,t){x(e,function(e){var n=d(e,!0);t(null,n)})},S=function(e){var t,n,r,o="";for(t=0,n=e.length/2;t<n;t++)r=parseInt(e[2*t]+e[2*t+1],16),o+=String.fromCharCode(r);return g(o)},A=function(){var e=function(){return(65536*(1+Math.random())|0).toString(16).substring(1)};return e()+e()+"-"+e()+"-"+e()+"-"+e()+"-"+e()+e()+e()},b=function(e,t){var n=t.Bucket,r=t.Region,o=t.Key;if(e.indexOf("Bucket")>-1||"deleteMultipleObject"===e||"multipartList"===e||"listObjectVersions"===e){if(!n)return"Bucket";if(!r)return"Region"}else if(e.indexOf("Object")>-1||e.indexOf("multipart")>-1||"sliceUploadFile"===e||"abortUploadTask"===e){if(!n)return"Bucket";if(!r)return"Region";if(!o)return"Key"}return!1},R=function(e,t){if(t=i({},t),"getAuth"!==e&&"getV4Auth"!==e&&"getObjectUrl"!==e){var n=t.Headers||{};if(t&&"object"==typeof t){!function(){for(var e in t)t.hasOwnProperty(e)&&e.indexOf("x-cos-")>-1&&(n[e]=t[e])}();var r={"x-cos-mfa":"MFA","Content-MD5":"ContentMD5","Content-Length":"ContentLength","Content-Type":"ContentType",Expect:"Expect",Expires:"Expires","Cache-Control":"CacheControl","Content-Disposition":"ContentDisposition","Content-Encoding":"ContentEncoding",Range:"Range","If-Modified-Since":"IfModifiedSince","If-Unmodified-Since":"IfUnmodifiedSince","If-Match":"IfMatch","If-None-Match":"IfNoneMatch","x-cos-copy-source":"CopySource","x-cos-copy-source-Range":"CopySourceRange","x-cos-metadata-directive":"MetadataDirective","x-cos-copy-source-If-Modified-Since":"CopySourceIfModifiedSince","x-cos-copy-source-If-Unmodified-Since":"CopySourceIfUnmodifiedSince","x-cos-copy-source-If-Match":"CopySourceIfMatch","x-cos-copy-source-If-None-Match":"CopySourceIfNoneMatch","x-cos-acl":"ACL","x-cos-grant-read":"GrantRead","x-cos-grant-write":"GrantWrite","x-cos-grant-full-control":"GrantFullControl","x-cos-grant-read-acp":"GrantReadAcp","x-cos-grant-write-acp":"GrantWriteAcp","x-cos-storage-class":"StorageClass","x-cos-server-side-encryption-customer-algorithm":"SSECustomerAlgorithm","x-cos-server-side-encryption-customer-key":"SSECustomerKey","x-cos-server-side-encryption-customer-key-MD5":"SSECustomerKeyMD5","x-cos-server-side-encryption":"ServerSideEncryption","x-cos-server-side-encryption-cos-kms-key-id":"SSEKMSKeyId","x-cos-server-side-encryption-context":"SSEContext"};N.each(r,function(e,r){void 0!==t[e]&&(n[r]=t[e])}),t.Headers=v(n)}}return t},T=function(e,t){return function(n,r){"function"==typeof n&&(r=n,n={}),n=R(e,n);var o=function(e){return e&&e.headers&&(e.headers["x-cos-version-id"]&&(e.VersionId=e.headers["x-cos-version-id"]),e.headers["x-cos-delete-marker"]&&(e.DeleteMarker=e.headers["x-cos-delete-marker"])),e},i=function(e,t){r&&r(o(e),o(t))};if("getService"!==e&&"abortUploadTask"!==e){var a;if(a=b(e,n))return void i({error:"missing param "+a});if(n.Region){if(n.Region.indexOf("cos.")>-1)return void i({error:'param Region should not be start with "cos."'});if(!/^([a-z\d-]+)$/.test(n.Region))return void i({error:"Region format error."});this.options.CompatibilityMode||-1!==n.Region.indexOf("-")||"yfb"===n.Region||"default"===n.Region||console.warn("warning: param Region format error, find help here: https://cloud.tencent.com/document/product/436/6224")}if(n.Bucket){if(!/^([a-z\d-]+)-(\d+)$/.test(n.Bucket))if(n.AppId)n.Bucket=n.Bucket+"-"+n.AppId;else{if(!this.options.AppId)return void i({error:'Bucket should format as "test-1250000000".'});n.Bucket=n.Bucket+"-"+this.options.AppId}n.AppId&&(console.warn('warning: AppId has been deprecated, Please put it at the end of parameter Bucket(E.g Bucket:"test-1250000000" ).'),delete n.AppId)}}var s=t.call(this,n,i);if("getAuth"===e||"getObjectUrl"===e)return s}},w=function(e,t){function n(){if(o=0,t&&"function"==typeof t){r=Date.now();var n,i=Math.max(0,Math.round((s-a)/((r-c)/1e3)*100)/100);n=0===s&&0===e?1:Math.round(s/e*100)/100||0,c=r,a=s;try{t({loaded:s,total:e,speed:i,percent:n})}catch(e){}}}var r,o,i=this,a=0,s=0,c=Date.now();return function(t,r){if(t&&(s=t.loaded,e=t.total),r)clearTimeout(o),n();else{if(o)return;o=setTimeout(n,i.options.ProgressInterval)}}},E=function(e,t,n){var r;if("string"==typeof t.Body&&(t.Body=new Blob([t.Body],{type:"text/plain"})),!t.Body||!(t.Body instanceof Blob||"[object File]"===t.Body.toString()||"[object Blob]"===t.Body.toString()))return void n({error:"params body format error, Only allow File|Blob|String."});r=t.Body.size,t.ContentLength=r,n(null,r)},_=function(e){return Date.now()+(e||0)},N={noop:C,formatParams:R,apiWrapper:T,xml2json:h,json2xml:p,md5:d,clearKey:v,getFileMd5:k,binaryBase64:S,extend:i,isArray:a,isInArray:s,each:c,map:u,filter:l,clone:o,uuid:A,camSafeUrlEncode:r,throttleOnProgress:w,getFileSize:E,getSkewTime:_,getAuth:y,isBrowser:!0};N.fileSlice=function(e,t,n){return e.slice?e.slice(t,n):e.mozSlice?e.mozSlice(t,n):e.webkitSlice?e.webkitSlice(t,n):void 0},N.getFileUUID=function(e,t){return e.name&&e.size&&e.lastModifiedDate&&t?N.md5([e.name,e.size,e.lastModifiedDate,t].join("::")):null},N.getBodyMd5=function(e,t,n){n=n||C,e&&"string"==typeof t?n(N.md5(t,!0)):n()},e.exports=N},function(e,t){function n(e,t){for(var n in e)t[n]=e[n]}function r(e,t){function r(){}var o=e.prototype;if(Object.create){var i=Object.create(t.prototype);o.__proto__=i}o instanceof t||(r.prototype=t.prototype,r=new r,n(o,r),e.prototype=o=r),o.constructor!=e&&("function"!=typeof e&&console.error("unknow Class:"+e),o.constructor=e)}function o(e,t){if(t instanceof Error)var n=t;else n=this,Error.call(this,oe[e]),this.message=oe[e],Error.captureStackTrace&&Error.captureStackTrace(this,o);return n.code=e,t&&(this.message=this.message+": "+t),n}function i(){}function a(e,t){this._node=e,this._refresh=t,s(this)}function s(e){var t=e._node._inc||e._node.ownerDocument._inc;if(e._inc!=t){var r=e._refresh(e._node);K(e,"length",r.length),n(r,e),e._inc=t}}function c(){}function u(e,t){for(var n=e.length;n--;)if(e[n]===t)return n}function l(e,t,n,r){if(r?t[u(t,r)]=n:t[t.length++]=n,e){n.ownerElement=e;var o=e.ownerDocument;o&&(r&&C(o,e,r),y(o,e,n))}}function d(e,t,n){var r=u(t,n);if(!(r>=0))throw o(ae,new Error(e.tagName+"@"+n));for(var i=t.length-1;r<i;)t[r]=t[++r];if(t.length=i,e){var a=e.ownerDocument;a&&(C(a,e,n),n.ownerElement=null)}}function f(e){if(this._features={},e)for(var t in e)this._features=e[t]}function h(){}function p(e){return"<"==e&&"&lt;"||">"==e&&"&gt;"||"&"==e&&"&amp;"||'"'==e&&"&quot;"||"&#"+e.charCodeAt()+";"}function m(e,t){if(t(e))return!0;if(e=e.firstChild)do{if(m(e,t))return!0}while(e=e.nextSibling)}function g(){}function y(e,t,n){e&&e._inc++,"http://www.w3.org/2000/xmlns/"==n.namespaceURI&&(t._nsMap[n.prefix?n.localName:""]=n.value)}function C(e,t,n,r){e&&e._inc++,"http://www.w3.org/2000/xmlns/"==n.namespaceURI&&delete t._nsMap[n.prefix?n.localName:""]}function v(e,t,n){if(e&&e._inc){e._inc++;var r=t.childNodes;if(n)r[r.length++]=n;else{for(var o=t.firstChild,i=0;o;)r[i++]=o,o=o.nextSibling;r.length=i}}}function x(e,t){var n=t.previousSibling,r=t.nextSibling;return n?n.nextSibling=r:e.firstChild=r,r?r.previousSibling=n:e.lastChild=n,v(e.ownerDocument,e),t}function k(e,t,n){var r=t.parentNode;if(r&&r.removeChild(t),t.nodeType===te){var o=t.firstChild;if(null==o)return t;var i=t.lastChild}else o=i=t;var a=n?n.previousSibling:e.lastChild;o.previousSibling=a,i.nextSibling=n,a?a.nextSibling=o:e.firstChild=o,null==n?e.lastChild=i:n.previousSibling=i;do{o.parentNode=e}while(o!==i&&(o=o.nextSibling));return v(e.ownerDocument||e,e),t.nodeType==te&&(t.firstChild=t.lastChild=null),t}function S(e,t){var n=t.parentNode;if(n){var r=e.lastChild;n.removeChild(t);var r=e.lastChild}var r=e.lastChild;return t.parentNode=e,t.previousSibling=r,t.nextSibling=null,r?r.nextSibling=t:e.firstChild=t,e.lastChild=t,v(e.ownerDocument,e,t),t}function A(){this._nsMap={}}function b(){}function R(){}function T(){}function w(){}function E(){}function _(){}function N(){}function B(){}function D(){}function O(){}function P(){}function I(){}function M(e,t){var n=[],r=9==this.nodeType?this.documentElement:this,o=r.prefix,i=r.namespaceURI;if(i&&null==o){var o=r.lookupPrefix(i);if(null==o)var a=[{namespace:i,prefix:null}]}return F(this,n,e,t,a),n.join("")}function L(e,t,n){var r=e.prefix||"",o=e.namespaceURI;if(!r&&!o)return!1;if("xml"===r&&"http://www.w3.org/XML/1998/namespace"===o||"http://www.w3.org/2000/xmlns/"==o)return!1;for(var i=n.length;i--;){var a=n[i];if(a.prefix==r)return a.namespace!=o}return!0}function F(e,t,n,r,o){if(r){if(!(e=r(e)))return;if("string"==typeof e)return void t.push(e)}switch(e.nodeType){case q:o||(o=[]);var i=(o.length,e.attributes),a=i.length,s=e.firstChild,c=e.tagName;n=z===e.namespaceURI||n,t.push("<",c);for(var u=0;u<a;u++){var l=i.item(u);"xmlns"==l.prefix?o.push({prefix:l.localName,namespace:l.value}):"xmlns"==l.nodeName&&o.push({prefix:"",namespace:l.value})}for(var u=0;u<a;u++){var l=i.item(u);if(L(l,n,o)){var d=l.prefix||"",f=l.namespaceURI,h=d?" xmlns:"+d:" xmlns";t.push(h,'="',f,'"'),o.push({prefix:d,namespace:f})}F(l,t,n,r,o)}if(L(e,n,o)){var d=e.prefix||"",f=e.namespaceURI,h=d?" xmlns:"+d:" xmlns";t.push(h,'="',f,'"'),o.push({prefix:d,namespace:f})}if(s||n&&!/^(?:meta|link|img|br|hr|input)$/i.test(c)){if(t.push(">"),n&&/^script$/i.test(c))for(;s;)s.data?t.push(s.data):F(s,t,n,r,o),s=s.nextSibling;else for(;s;)F(s,t,n,r,o),s=s.nextSibling;t.push("</",c,">")}else t.push("/>");return;case J:case te:for(var s=e.firstChild;s;)F(s,t,n,r,o),s=s.nextSibling;return;case V:return t.push(" ",e.name,'="',e.value.replace(/[<&"]/g,p),'"');case X:return t.push(e.data.replace(/[<&]/g,p));case $:return t.push("<![CDATA[",e.data,"]]>");case Y:return t.push("\x3c!--",e.data,"--\x3e");case ee:var m=e.publicId,g=e.systemId;if(t.push("<!DOCTYPE ",e.name),m)t.push(' PUBLIC "',m),g&&"."!=g&&t.push('" "',g),t.push('">');else if(g&&"."!=g)t.push(' SYSTEM "',g,'">');else{var y=e.internalSubset;y&&t.push(" [",y,"]"),t.push(">")}return;case Z:return t.push("<?",e.target," ",e.data,"?>");case W:return t.push("&",e.nodeName,";");default:t.push("??",e.nodeName)}}function U(e,t,n){var r;switch(t.nodeType){case q:r=t.cloneNode(!1),r.ownerDocument=e;case te:break;case V:n=!0}if(r||(r=t.cloneNode(!1)),r.ownerDocument=e,r.parentNode=null,n)for(var o=t.firstChild;o;)r.appendChild(U(e,o,n)),o=o.nextSibling;return r}function j(e,t,n){var r=new t.constructor;for(var o in t){var a=t[o];"object"!=typeof a&&a!=r[o]&&(r[o]=a)}switch(t.childNodes&&(r.childNodes=new i),r.ownerDocument=e,r.nodeType){case q:var s=t.attributes,u=r.attributes=new c,l=s.length;u._ownerElement=r;for(var d=0;d<l;d++)r.setAttributeNode(j(e,s.item(d),!0));break;case V:n=!0}if(n)for(var f=t.firstChild;f;)r.appendChild(j(e,f,n)),f=f.nextSibling;return r}function K(e,t,n){e[t]=n}function H(e){switch(e.nodeType){case q:case te:var t=[];for(e=e.firstChild;e;)7!==e.nodeType&&8!==e.nodeType&&t.push(H(e)),e=e.nextSibling;return t.join("");default:return e.nodeValue}}var z="http://www.w3.org/1999/xhtml",G={},q=G.ELEMENT_NODE=1,V=G.ATTRIBUTE_NODE=2,X=G.TEXT_NODE=3,$=G.CDATA_SECTION_NODE=4,W=G.ENTITY_REFERENCE_NODE=5,Q=G.ENTITY_NODE=6,Z=G.PROCESSING_INSTRUCTION_NODE=7,Y=G.COMMENT_NODE=8,J=G.DOCUMENT_NODE=9,ee=G.DOCUMENT_TYPE_NODE=10,te=G.DOCUMENT_FRAGMENT_NODE=11,ne=G.NOTATION_NODE=12,re={},oe={},ie=(re.INDEX_SIZE_ERR=(oe[1]="Index size error",1),re.DOMSTRING_SIZE_ERR=(oe[2]="DOMString size error",2),re.HIERARCHY_REQUEST_ERR=(oe[3]="Hierarchy request error",3)),ae=(re.WRONG_DOCUMENT_ERR=(oe[4]="Wrong document",4),re.INVALID_CHARACTER_ERR=(oe[5]="Invalid character",5),re.NO_DATA_ALLOWED_ERR=(oe[6]="No data allowed",6),re.NO_MODIFICATION_ALLOWED_ERR=(oe[7]="No modification allowed",7),re.NOT_FOUND_ERR=(oe[8]="Not found",8)),se=(re.NOT_SUPPORTED_ERR=(oe[9]="Not supported",9),re.INUSE_ATTRIBUTE_ERR=(oe[10]="Attribute in use",10));re.INVALID_STATE_ERR=(oe[11]="Invalid state",11),re.SYNTAX_ERR=(oe[12]="Syntax error",12),re.INVALID_MODIFICATION_ERR=(oe[13]="Invalid modification",13),re.NAMESPACE_ERR=(oe[14]="Invalid namespace",14),re.INVALID_ACCESS_ERR=(oe[15]="Invalid access",15);o.prototype=Error.prototype,n(re,o),i.prototype={length:0,item:function(e){return this[e]||null},toString:function(e,t){for(var n=[],r=0;r<this.length;r++)F(this[r],n,e,t);return n.join("")}},a.prototype.item=function(e){return s(this),this[e]},r(a,i),c.prototype={length:0,item:i.prototype.item,getNamedItem:function(e){for(var t=this.length;t--;){var n=this[t];if(n.nodeName==e)return n}},setNamedItem:function(e){var t=e.ownerElement;if(t&&t!=this._ownerElement)throw new o(se);var n=this.getNamedItem(e.nodeName);return l(this._ownerElement,this,e,n),n},setNamedItemNS:function(e){var t,n=e.ownerElement;if(n&&n!=this._ownerElement)throw new o(se);return t=this.getNamedItemNS(e.namespaceURI,e.localName),l(this._ownerElement,this,e,t),t},removeNamedItem:function(e){var t=this.getNamedItem(e);return d(this._ownerElement,this,t),t},removeNamedItemNS:function(e,t){var n=this.getNamedItemNS(e,t);return d(this._ownerElement,this,n),n},getNamedItemNS:function(e,t){for(var n=this.length;n--;){var r=this[n];if(r.localName==t&&r.namespaceURI==e)return r}return null}},f.prototype={hasFeature:function(e,t){var n=this._features[e.toLowerCase()];return!(!n||t&&!(t in n))},createDocument:function(e,t,n){var r=new g;if(r.implementation=this,r.childNodes=new i,r.doctype=n,n&&r.appendChild(n),t){var o=r.createElementNS(e,t);r.appendChild(o)}return r},createDocumentType:function(e,t,n){var r=new _;return r.name=e,r.nodeName=e,r.publicId=t,r.systemId=n,r}},h.prototype={firstChild:null,lastChild:null,previousSibling:null,nextSibling:null,attributes:null,parentNode:null,childNodes:null,ownerDocument:null,nodeValue:null,namespaceURI:null,prefix:null,localName:null,insertBefore:function(e,t){return k(this,e,t)},replaceChild:function(e,t){this.insertBefore(e,t),t&&this.removeChild(t)},removeChild:function(e){return x(this,e)},appendChild:function(e){return this.insertBefore(e,null)},hasChildNodes:function(){return null!=this.firstChild},cloneNode:function(e){return j(this.ownerDocument||this,this,e)},normalize:function(){for(var e=this.firstChild;e;){var t=e.nextSibling;t&&t.nodeType==X&&e.nodeType==X?(this.removeChild(t),e.appendData(t.data)):(e.normalize(),e=t)}},isSupported:function(e,t){return this.ownerDocument.implementation.hasFeature(e,t)},hasAttributes:function(){return this.attributes.length>0},lookupPrefix:function(e){for(var t=this;t;){var n=t._nsMap;if(n)for(var r in n)if(n[r]==e)return r;t=t.nodeType==V?t.ownerDocument:t.parentNode}return null},lookupNamespaceURI:function(e){for(var t=this;t;){var n=t._nsMap;if(n&&e in n)return n[e];t=t.nodeType==V?t.ownerDocument:t.parentNode}return null},isDefaultNamespace:function(e){return null==this.lookupPrefix(e)}},n(G,h),n(G,h.prototype),g.prototype={nodeName:"#document",nodeType:J,doctype:null,documentElement:null,_inc:1,insertBefore:function(e,t){if(e.nodeType==te){for(var n=e.firstChild;n;){var r=n.nextSibling;this.insertBefore(n,t),n=r}return e}return null==this.documentElement&&e.nodeType==q&&(this.documentElement=e),k(this,e,t),e.ownerDocument=this,e},removeChild:function(e){return this.documentElement==e&&(this.documentElement=null),x(this,e)},importNode:function(e,t){return U(this,e,t)},getElementById:function(e){var t=null;return m(this.documentElement,function(n){if(n.nodeType==q&&n.getAttribute("id")==e)return t=n,!0}),t},createElement:function(e){var t=new A;return t.ownerDocument=this,t.nodeName=e,t.tagName=e,t.childNodes=new i,(t.attributes=new c)._ownerElement=t,t},createDocumentFragment:function(){var e=new O;return e.ownerDocument=this,e.childNodes=new i,e},createTextNode:function(e){var t=new T;return t.ownerDocument=this,t.appendData(e),t},createComment:function(e){var t=new w;return t.ownerDocument=this,t.appendData(e),t},createCDATASection:function(e){var t=new E;return t.ownerDocument=this,t.appendData(e),t},createProcessingInstruction:function(e,t){var n=new P;return n.ownerDocument=this,n.tagName=n.target=e,n.nodeValue=n.data=t,n},createAttribute:function(e){var t=new b;return t.ownerDocument=this,t.name=e,t.nodeName=e,t.localName=e,t.specified=!0,t},createEntityReference:function(e){var t=new D;return t.ownerDocument=this,t.nodeName=e,t},createElementNS:function(e,t){var n=new A,r=t.split(":"),o=n.attributes=new c;return n.childNodes=new i,n.ownerDocument=this,n.nodeName=t,n.tagName=t,n.namespaceURI=e,2==r.length?(n.prefix=r[0],n.localName=r[1]):n.localName=t,o._ownerElement=n,n},createAttributeNS:function(e,t){var n=new b,r=t.split(":");return n.ownerDocument=this,n.nodeName=t,n.name=t,n.namespaceURI=e,n.specified=!0,2==r.length?(n.prefix=r[0],n.localName=r[1]):n.localName=t,n}},r(g,h),A.prototype={nodeType:q,hasAttribute:function(e){return null!=this.getAttributeNode(e)},getAttribute:function(e){var t=this.getAttributeNode(e);return t&&t.value||""},getAttributeNode:function(e){return this.attributes.getNamedItem(e)},setAttribute:function(e,t){var n=this.ownerDocument.createAttribute(e);n.value=n.nodeValue=""+t,this.setAttributeNode(n)},removeAttribute:function(e){var t=this.getAttributeNode(e);t&&this.removeAttributeNode(t)},appendChild:function(e){return e.nodeType===te?this.insertBefore(e,null):S(this,e)},setAttributeNode:function(e){return this.attributes.setNamedItem(e)},setAttributeNodeNS:function(e){return this.attributes.setNamedItemNS(e)},removeAttributeNode:function(e){return this.attributes.removeNamedItem(e.nodeName)},removeAttributeNS:function(e,t){var n=this.getAttributeNodeNS(e,t);n&&this.removeAttributeNode(n)},hasAttributeNS:function(e,t){return null!=this.getAttributeNodeNS(e,t)},getAttributeNS:function(e,t){var n=this.getAttributeNodeNS(e,t);return n&&n.value||""},setAttributeNS:function(e,t,n){var r=this.ownerDocument.createAttributeNS(e,t);r.value=r.nodeValue=""+n,this.setAttributeNode(r)},getAttributeNodeNS:function(e,t){return this.attributes.getNamedItemNS(e,t)},getElementsByTagName:function(e){return new a(this,function(t){var n=[];return m(t,function(r){r===t||r.nodeType!=q||"*"!==e&&r.tagName!=e||n.push(r)}),n})},getElementsByTagNameNS:function(e,t){return new a(this,function(n){var r=[];return m(n,function(o){o===n||o.nodeType!==q||"*"!==e&&o.namespaceURI!==e||"*"!==t&&o.localName!=t||r.push(o)}),r})}},g.prototype.getElementsByTagName=A.prototype.getElementsByTagName,g.prototype.getElementsByTagNameNS=A.prototype.getElementsByTagNameNS,r(A,h),b.prototype.nodeType=V,r(b,h),R.prototype={data:"",substringData:function(e,t){return this.data.substring(e,e+t)},appendData:function(e){e=this.data+e,this.nodeValue=this.data=e,this.length=e.length},insertData:function(e,t){this.replaceData(e,0,t)},appendChild:function(e){throw new Error(oe[ie])},deleteData:function(e,t){this.replaceData(e,t,"")},replaceData:function(e,t,n){n=this.data.substring(0,e)+n+this.data.substring(e+t),this.nodeValue=this.data=n,this.length=n.length}},r(R,h),T.prototype={nodeName:"#text",nodeType:X,splitText:function(e){var t=this.data,n=t.substring(e);t=t.substring(0,e),this.data=this.nodeValue=t,this.length=t.length;var r=this.ownerDocument.createTextNode(n);return this.parentNode&&this.parentNode.insertBefore(r,this.nextSibling),r}},r(T,R),w.prototype={nodeName:"#comment",nodeType:Y},r(w,R),E.prototype={nodeName:"#cdata-section",nodeType:$},r(E,R),_.prototype.nodeType=ee,r(_,h),N.prototype.nodeType=ne,r(N,h),B.prototype.nodeType=Q,r(B,h),D.prototype.nodeType=W,r(D,h),O.prototype.nodeName="#document-fragment",O.prototype.nodeType=te,r(O,h),P.prototype.nodeType=Z,r(P,h),I.prototype.serializeToString=function(e,t,n){return M.call(e,t,n)},h.prototype.toString=M;try{Object.defineProperty&&(Object.defineProperty(a.prototype,"length",{get:function(){return s(this),this.$$length}}),Object.defineProperty(h.prototype,"textContent",{get:function(){return H(this)},set:function(e){switch(this.nodeType){case q:case te:for(;this.firstChild;)this.removeChild(this.firstChild);(e||String(e))&&this.appendChild(this.ownerDocument.createTextNode(e));break;default:this.data=e,this.value=e,this.nodeValue=e}}}),K=function(e,t,n){e["$$"+t]=n})}catch(e){}t.DOMImplementation=f,t.XMLSerializer=I},function(e,t){var n=function(e){var t={},n=function(e){return!t[e]&&(t[e]=[]),t[e]};e.on=function(e,t){n(e).push(t)},e.off=function(e,t){for(var r=n(e),o=r.length-1;o>=0;o--)t===r[o]&&r.splice(o,1)},e.emit=function(e,t){for(var r=n(e).map(function(e){return e}),o=0;o<r.length;o++)r[o](t)}},r=function(){n(this)};e.exports.init=n,e.exports.EventProxy=r},function(e,t,n){"use strict";var r=n(0),o=n(2),i=n(16),a=n(15),s=n(13),c={SecretId:"",SecretKey:"",XCosSecurityToken:"",FileParallelLimit:3,ChunkParallelLimit:3,ChunkSize:1048576,SliceSize:1048576,CopyChunkParallelLimit:20,CopyChunkSize:10485760,CopySliceSize:10485760,MaxPartNumber:1e4,ProgressInterval:1e3,UploadQueueSize:1e4,Domain:"",ServiceDomain:"",Protocol:"",CompatibilityMode:!1,ForcePathStyle:!1,CorrectClockSkew:!0,SystemClockOffset:0},u=function(e){this.options=r.extend(r.clone(c),e||{}),this.options.FileParallelLimit=Math.max(1,this.options.FileParallelLimit),this.options.ChunkParallelLimit=Math.max(1,this.options.ChunkParallelLimit),this.options.ChunkRetryTimes=Math.max(0,this.options.ChunkRetryTimes),this.options.ChunkSize=Math.max(1048576,this.options.ChunkSize),this.options.CopyChunkParallelLimit=Math.max(1,this.options.CopyChunkParallelLimit),this.options.CopyChunkSize=Math.max(1048576,this.options.CopyChunkSize),this.options.CopySliceSize=Math.max(0,this.options.CopySliceSize),this.options.MaxPartNumber=Math.max(1024,Math.min(1e4,this.options.MaxPartNumber)),this.options.Timeout=Math.max(0,this.options.Timeout),this.options.AppId&&console.warn('warning: AppId has been deprecated, Please put it at the end of parameter Bucket(E.g: "test-1250000000").'),o.init(this),i.init(this)};a.init(u,i),s.init(u,i),u.getAuthorization=r.getAuth,u.version="0.7.3",e.exports=u},function(e,t,n){var r=n(3);e.exports=r},function(e,t){var n=function(e){e=e||{};var t,n=e.Base64,r="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/",o=function(e){for(var t={},n=0,r=e.length;n<r;n++)t[e.charAt(n)]=n;return t}(r),i=String.fromCharCode,a=function(e){if(e.length<2){var t=e.charCodeAt(0);return t<128?e:t<2048?i(192|t>>>6)+i(128|63&t):i(224|t>>>12&15)+i(128|t>>>6&63)+i(128|63&t)}var t=65536+1024*(e.charCodeAt(0)-55296)+(e.charCodeAt(1)-56320);return i(240|t>>>18&7)+i(128|t>>>12&63)+i(128|t>>>6&63)+i(128|63&t)},s=/[\uD800-\uDBFF][\uDC00-\uDFFFF]|[^\x00-\x7F]/g,c=function(e){return e.replace(s,a)},u=function(e){var t=[0,2,1][e.length%3],n=e.charCodeAt(0)<<16|(e.length>1?e.charCodeAt(1):0)<<8|(e.length>2?e.charCodeAt(2):0);return[r.charAt(n>>>18),r.charAt(n>>>12&63),t>=2?"=":r.charAt(n>>>6&63),t>=1?"=":r.charAt(63&n)].join("")},l=e.btoa?function(t){return e.btoa(t)}:function(e){return e.replace(/[\s\S]{1,3}/g,u)},d=t?function(e){return(e.constructor===t.constructor?e:new t(e)).toString("base64")}:function(e){return l(c(e))},f=function(e,t){return t?d(String(e)).replace(/[+\/]/g,function(e){return"+"==e?"-":"_"}).replace(/=/g,""):d(String(e))},h=function(e){return f(e,!0)},p=new RegExp(["[À-ß][-¿]","[à-ï][-¿]{2}","[ð-÷][-¿]{3}"].join("|"),"g"),m=function(e){switch(e.length){case 4:var t=(7&e.charCodeAt(0))<<18|(63&e.charCodeAt(1))<<12|(63&e.charCodeAt(2))<<6|63&e.charCodeAt(3),n=t-65536;return i(55296+(n>>>10))+i(56320+(1023&n));case 3:return i((15&e.charCodeAt(0))<<12|(63&e.charCodeAt(1))<<6|63&e.charCodeAt(2));default:return i((31&e.charCodeAt(0))<<6|63&e.charCodeAt(1))}},g=function(e){return e.replace(p,m)},y=function(e){var t=e.length,n=t%4,r=(t>0?o[e.charAt(0)]<<18:0)|(t>1?o[e.charAt(1)]<<12:0)|(t>2?o[e.charAt(2)]<<6:0)|(t>3?o[e.charAt(3)]:0),a=[i(r>>>16),i(r>>>8&255),i(255&r)];return a.length-=[0,0,2,1][n],a.join("")},C=e.atob?function(t){return e.atob(t)}:function(e){return e.replace(/[\s\S]{1,4}/g,y)},v=t?function(e){return(e.constructor===t.constructor?e:new t(e,"base64")).toString()}:function(e){return g(C(e))},x=function(e){return v(String(e).replace(/[-_]/g,function(e){return"-"==e?"+":"/"}).replace(/[^A-Za-z0-9\+\/]/g,""))};return{VERSION:"2.1.9",atob:C,btoa:l,fromBase64:x,toBase64:f,utob:c,encode:f,encodeURI:h,btou:g,decode:x,noConflict:function(){var t=e.Base64;return e.Base64=n,t}}}();e.exports=n},function(e,t){var n=n||function(e,t){var n={},r=n.lib={},o=function(){},i=r.Base={extend:function(e){o.prototype=this;var t=new o;return e&&t.mixIn(e),t.hasOwnProperty("init")||(t.init=function(){t.$super.init.apply(this,arguments)}),t.init.prototype=t,t.$super=this,t},create:function(){var e=this.extend();return e.init.apply(e,arguments),e},init:function(){},mixIn:function(e){for(var t in e)e.hasOwnProperty(t)&&(this[t]=e[t]);e.hasOwnProperty("toString")&&(this.toString=e.toString)},clone:function(){return this.init.prototype.extend(this)}},a=r.WordArray=i.extend({init:function(e,t){e=this.words=e||[],this.sigBytes=void 0!=t?t:4*e.length},toString:function(e){return(e||c).stringify(this)},concat:function(e){var t=this.words,n=e.words,r=this.sigBytes;if(e=e.sigBytes,this.clamp(),r%4)for(var o=0;o<e;o++)t[r+o>>>2]|=(n[o>>>2]>>>24-o%4*8&255)<<24-(r+o)%4*8;else if(65535<n.length)for(o=0;o<e;o+=4)t[r+o>>>2]=n[o>>>2];else t.push.apply(t,n);return this.sigBytes+=e,this},clamp:function(){var t=this.words,n=this.sigBytes;t[n>>>2]&=4294967295<<32-n%4*8,t.length=e.ceil(n/4)},clone:function(){var e=i.clone.call(this);return e.words=this.words.slice(0),e},random:function(t){for(var n=[],r=0;r<t;r+=4)n.push(4294967296*e.random()|0);return new a.init(n,t)}}),s=n.enc={},c=s.Hex={stringify:function(e){var t=e.words;e=e.sigBytes;for(var n=[],r=0;r<e;r++){var o=t[r>>>2]>>>24-r%4*8&255;n.push((o>>>4).toString(16)),n.push((15&o).toString(16))}return n.join("")},parse:function(e){for(var t=e.length,n=[],r=0;r<t;r+=2)n[r>>>3]|=parseInt(e.substr(r,2),16)<<24-r%8*4;return new a.init(n,t/2)}},u=s.Latin1={stringify:function(e){var t=e.words;e=e.sigBytes;for(var n=[],r=0;r<e;r++)n.push(String.fromCharCode(t[r>>>2]>>>24-r%4*8&255));return n.join("")},parse:function(e){for(var t=e.length,n=[],r=0;r<t;r++)n[r>>>2]|=(255&e.charCodeAt(r))<<24-r%4*8;return new a.init(n,t)}},l=s.Utf8={stringify:function(e){try{return decodeURIComponent(escape(u.stringify(e)))}catch(e){throw Error("Malformed UTF-8 data")}},parse:function(e){return u.parse(unescape(encodeURIComponent(e)))}},d=r.BufferedBlockAlgorithm=i.extend({reset:function(){this._data=new a.init,this._nDataBytes=0},_append:function(e){"string"==typeof e&&(e=l.parse(e)),this._data.concat(e),this._nDataBytes+=e.sigBytes},_process:function(t){var n=this._data,r=n.words,o=n.sigBytes,i=this.blockSize,s=o/(4*i),s=t?e.ceil(s):e.max((0|s)-this._minBufferSize,0);if(t=s*i,o=e.min(4*t,o),t){for(var c=0;c<t;c+=i)this._doProcessBlock(r,c);c=r.splice(0,t),n.sigBytes-=o}return new a.init(c,o)},clone:function(){var e=i.clone.call(this);return e._data=this._data.clone(),e},_minBufferSize:0});r.Hasher=d.extend({cfg:i.extend(),init:function(e){this.cfg=this.cfg.extend(e),this.reset()},reset:function(){d.reset.call(this),this._doReset()},update:function(e){return this._append(e),this._process(),this},finalize:function(e){return e&&this._append(e),this._doFinalize()},blockSize:16,_createHelper:function(e){return function(t,n){return new e.init(n).finalize(t)}},_createHmacHelper:function(e){return function(t,n){return new f.HMAC.init(e,n).finalize(t)}}});var f=n.algo={};return n}(Math);!function(){var e=n,t=e.lib,r=t.WordArray,o=t.Hasher,i=[],t=e.algo.SHA1=o.extend({_doReset:function(){this._hash=new r.init([1732584193,4023233417,2562383102,271733878,3285377520])},_doProcessBlock:function(e,t){for(var n=this._hash.words,r=n[0],o=n[1],a=n[2],s=n[3],c=n[4],u=0;80>u;u++){if(16>u)i[u]=0|e[t+u];else{var l=i[u-3]^i[u-8]^i[u-14]^i[u-16];i[u]=l<<1|l>>>31}l=(r<<5|r>>>27)+c+i[u],l=20>u?l+(1518500249+(o&a|~o&s)):40>u?l+(1859775393+(o^a^s)):60>u?l+((o&a|o&s|a&s)-1894007588):l+((o^a^s)-899497514),c=s,s=a,a=o<<30|o>>>2,o=r,r=l}n[0]=n[0]+r|0,n[1]=n[1]+o|0,n[2]=n[2]+a|0,n[3]=n[3]+s|0,n[4]=n[4]+c|0},_doFinalize:function(){var e=this._data,t=e.words,n=8*this._nDataBytes,r=8*e.sigBytes;return t[r>>>5]|=128<<24-r%32,t[14+(r+64>>>9<<4)]=Math.floor(n/4294967296),t[15+(r+64>>>9<<4)]=n,e.sigBytes=4*t.length,this._process(),this._hash},clone:function(){var e=o.clone.call(this);return e._hash=this._hash.clone(),e}});e.SHA1=o._createHelper(t),e.HmacSHA1=o._createHmacHelper(t)}(),function(){var e=n,t=e.enc.Utf8;e.algo.HMAC=e.lib.Base.extend({init:function(e,n){e=this._hasher=new e.init,"string"==typeof n&&(n=t.parse(n));var r=e.blockSize,o=4*r;n.sigBytes>o&&(n=e.finalize(n)),n.clamp();for(var i=this._oKey=n.clone(),a=this._iKey=n.clone(),s=i.words,c=a.words,u=0;u<r;u++)s[u]^=1549556828,c[u]^=909522486;i.sigBytes=a.sigBytes=o,this.reset()},reset:function(){var e=this._hasher;e.reset(),e.update(this._iKey)},update:function(e){return this._hasher.update(e),this},finalize:function(e){var t=this._hasher;return e=t.finalize(e),t.reset(),t.finalize(this._oKey.clone().concat(e))}})}(),function(){var e=n,t=e.lib,r=t.WordArray,o=e.enc;o.Base64={stringify:function(e){var t=e.words,n=e.sigBytes,r=this._map;e.clamp();for(var o=[],i=0;i<n;i+=3)for(var a=t[i>>>2]>>>24-i%4*8&255,s=t[i+1>>>2]>>>24-(i+1)%4*8&255,c=t[i+2>>>2]>>>24-(i+2)%4*8&255,u=a<<16|s<<8|c,l=0;l<4&&i+.75*l<n;l++)o.push(r.charAt(u>>>6*(3-l)&63));var d=r.charAt(64);if(d)for(;o.length%4;)o.push(d);return o.join("")},parse:function(e){var t=e.length,n=this._map,o=n.charAt(64);if(o){var i=e.indexOf(o);-1!=i&&(t=i)}for(var a=[],s=0,c=0;c<t;c++)if(c%4){var u=n.indexOf(e.charAt(c-1))<<c%4*2,l=n.indexOf(e.charAt(c))>>>6-c%4*2;a[s>>>2]|=(u|l)<<24-s%4*8,s++}return r.create(a,s)},_map:"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/="}}(),e.exports=n},function(e,t){function n(e){return(""+e).replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/'/g,"&apos;").replace(/"/g,"&quot;").replace(o,"")}var r=new RegExp("^([^a-zA-Z_À-ÖØ-öø-ÿͰ-ͽͿ-῿‌-‍⁰-↏Ⰰ-⿿、-퟿豈-﷏ﷰ-�])|^((x|X)(m|M)(l|L))|([^a-zA-Z_À-ÖØ-öø-ÿͰ-ͽͿ-῿‌-‍⁰-↏Ⰰ-⿿、-퟿豈-﷏ﷰ-�-.0-9·̀-ͯ‿⁀])","g"),o=/[^\x09\x0A\x0D\x20-\xFF\x85\xA0-\uD7FF\uE000-\uFDCF\uFDE0-\uFFFD]/gm,i=function(e){var t=[];if(e instanceof Object)for(var n in e)e.hasOwnProperty(n)&&t.push(n);return t},a=function(e,t){var o=function(e,n,o,i,a){var s=void 0!==t.indent?t.indent:"\t",c=t.prettyPrint?"\n"+new Array(i).join(s):"";t.removeIllegalNameCharacters&&(e=e.replace(r,"_"));var u=[c,"<",e,o||""];return n&&n.length>0?(u.push(">"),u.push(n),a&&u.push(c),u.push("</"),u.push(e),u.push(">")):u.push("/>"),u.join("")};return function e(r,a,s){var c=typeof r;switch((Array.isArray?Array.isArray(r):r instanceof Array)?c="array":r instanceof Date&&(c="date"),c){case"array":var u=[];return r.map(function(t){u.push(e(t,1,s+1))}),t.prettyPrint&&u.push("\n"),u.join("");case"date":return r.toJSON?r.toJSON():r+"";case"object":var l=[];for(var d in r)if(r[d]instanceof Array)for(var f in r[d])l.push(o(d,e(r[d][f],0,s+1),null,s+1,i(r[d][f]).length));else l.push(o(d,e(r[d],0,s+1),null,s+1));return t.prettyPrint&&l.length>0&&l.push("\n"),l.join("");case"function":return r();default:return t.escape?n(r):""+r}}(e,0,0)},s=function(e){var t=['<?xml version="1.0" encoding="UTF-8"'];return e&&t.push(' standalone="yes"'),t.push("?>"),t.join("")},c=function(e,t){if(t||(t={xmlHeader:{standalone:!0},prettyPrint:!0,indent:"  "}),"string"==typeof e)try{e=JSON.parse(e.toString())}catch(e){return!1}var n="",r="";return t&&("object"==typeof t?(t.xmlHeader&&(n=s(!!t.xmlHeader.standalone)),void 0!==t.docType&&(r="<!DOCTYPE "+t.docType+">")):n=s()),t=t||{},[n,t.prettyPrint&&r?"\n":"",r,a(e,t)].join("").replace(/\n{2,}/g,"\n").replace(/\s+$/g,"")};e.exports=c},function(e,t){var n=function(e){function t(e,t){return e<<t|e>>>32-t}function n(e,t){var n,r,o,i,a;return o=2147483648&e,i=2147483648&t,n=1073741824&e,r=1073741824&t,a=(1073741823&e)+(1073741823&t),n&r?2147483648^a^o^i:n|r?1073741824&a?3221225472^a^o^i:1073741824^a^o^i:a^o^i}function r(e,t,n){return e&t|~e&n}function o(e,t,n){return e&n|t&~n}function i(e,t,n){return e^t^n}function a(e,t,n){return t^(e|~n)}function s(e,o,i,a,s,c,u){return e=n(e,n(n(r(o,i,a),s),u)),n(t(e,c),o)}function c(e,r,i,a,s,c,u){return e=n(e,n(n(o(r,i,a),s),u)),n(t(e,c),r)}function u(e,r,o,a,s,c,u){return e=n(e,n(n(i(r,o,a),s),u)),n(t(e,c),r)}function l(e,r,o,i,s,c,u){return e=n(e,n(n(a(r,o,i),s),u)),n(t(e,c),r)}function d(e){var t,n,r="",o="";for(n=0;n<=3;n++)t=e>>>8*n&255,o="0"+t.toString(16),r+=o.substr(o.length-2,2);return r}var f,h,p,m,g,y,C,v,x,k=Array();for(e=function(e){e=e.replace(/\r\n/g,"\n");for(var t="",n=0;n<e.length;n++){var r=e.charCodeAt(n);r<128?t+=String.fromCharCode(r):r>127&&r<2048?(t+=String.fromCharCode(r>>6|192),t+=String.fromCharCode(63&r|128)):(t+=String.fromCharCode(r>>12|224),t+=String.fromCharCode(r>>6&63|128),t+=String.fromCharCode(63&r|128))}return t}(e),k=function(e){for(var t,n=e.length,r=n+8,o=(r-r%64)/64,i=16*(o+1),a=Array(i-1),s=0,c=0;c<n;)t=(c-c%4)/4,s=c%4*8,a[t]=a[t]|e.charCodeAt(c)<<s,c++;return t=(c-c%4)/4,s=c%4*8,a[t]=a[t]|128<<s,a[i-2]=n<<3,a[i-1]=n>>>29,a}(e),y=1732584193,C=4023233417,v=2562383102,x=271733878,f=0;f<k.length;f+=16)h=y,p=C,m=v,g=x,y=s(y,C,v,x,k[f+0],7,3614090360),x=s(x,y,C,v,k[f+1],12,3905402710),v=s(v,x,y,C,k[f+2],17,606105819),C=s(C,v,x,y,k[f+3],22,3250441966),y=s(y,C,v,x,k[f+4],7,4118548399),x=s(x,y,C,v,k[f+5],12,1200080426),v=s(v,x,y,C,k[f+6],17,2821735955),C=s(C,v,x,y,k[f+7],22,4249261313),y=s(y,C,v,x,k[f+8],7,1770035416),x=s(x,y,C,v,k[f+9],12,2336552879),v=s(v,x,y,C,k[f+10],17,4294925233),C=s(C,v,x,y,k[f+11],22,2304563134),y=s(y,C,v,x,k[f+12],7,1804603682),x=s(x,y,C,v,k[f+13],12,4254626195),v=s(v,x,y,C,k[f+14],17,2792965006),C=s(C,v,x,y,k[f+15],22,1236535329),y=c(y,C,v,x,k[f+1],5,4129170786),x=c(x,y,C,v,k[f+6],9,3225465664),v=c(v,x,y,C,k[f+11],14,643717713),C=c(C,v,x,y,k[f+0],20,3921069994),y=c(y,C,v,x,k[f+5],5,3593408605),x=c(x,y,C,v,k[f+10],9,38016083),v=c(v,x,y,C,k[f+15],14,3634488961),C=c(C,v,x,y,k[f+4],20,3889429448),y=c(y,C,v,x,k[f+9],5,568446438),x=c(x,y,C,v,k[f+14],9,3275163606),v=c(v,x,y,C,k[f+3],14,4107603335),C=c(C,v,x,y,k[f+8],20,1163531501),y=c(y,C,v,x,k[f+13],5,2850285829),x=c(x,y,C,v,k[f+2],9,4243563512),v=c(v,x,y,C,k[f+7],14,1735328473),C=c(C,v,x,y,k[f+12],20,2368359562),y=u(y,C,v,x,k[f+5],4,4294588738),x=u(x,y,C,v,k[f+8],11,2272392833),v=u(v,x,y,C,k[f+11],16,1839030562),C=u(C,v,x,y,k[f+14],23,4259657740),y=u(y,C,v,x,k[f+1],4,2763975236),x=u(x,y,C,v,k[f+4],11,1272893353),v=u(v,x,y,C,k[f+7],16,4139469664),C=u(C,v,x,y,k[f+10],23,3200236656),y=u(y,C,v,x,k[f+13],4,681279174),x=u(x,y,C,v,k[f+0],11,3936430074),v=u(v,x,y,C,k[f+3],16,3572445317),C=u(C,v,x,y,k[f+6],23,76029189),y=u(y,C,v,x,k[f+9],4,3654602809),x=u(x,y,C,v,k[f+12],11,3873151461),v=u(v,x,y,C,k[f+15],16,530742520),C=u(C,v,x,y,k[f+2],23,3299628645),y=l(y,C,v,x,k[f+0],6,4096336452),x=l(x,y,C,v,k[f+7],10,1126891415),v=l(v,x,y,C,k[f+14],15,2878612391),C=l(C,v,x,y,k[f+5],21,4237533241),y=l(y,C,v,x,k[f+12],6,1700485571),x=l(x,y,C,v,k[f+3],10,2399980690),v=l(v,x,y,C,k[f+10],15,4293915773),C=l(C,v,x,y,k[f+1],21,2240044497),y=l(y,C,v,x,k[f+8],6,1873313359),x=l(x,y,C,v,k[f+15],10,4264355552),v=l(v,x,y,C,k[f+6],15,2734768916),C=l(C,v,x,y,k[f+13],21,1309151649),y=l(y,C,v,x,k[f+4],6,4149444226),x=l(x,y,C,v,k[f+11],10,3174756917),v=l(v,x,y,C,k[f+2],15,718787259),C=l(C,v,x,y,k[f+9],21,3951481745),y=n(y,h),C=n(C,p),v=n(v,m),x=n(x,g);return(d(y)+d(C)+d(v)+d(x)).toLowerCase()};e.exports=n},function(e,t){var n=function(e){var t,n,r,o=[],i=Object.keys(e);for(t=0;t<i.length;t++)n=i[t],r=e[n]||"",o.push(n+"="+encodeURIComponent(r));return o.join("&")},r=function(e,t){var r,o=e.filePath,i=e.headers||{},a=e.url,s=e.method,c=e.onProgress,u=function(e,n){t(e,{statusCode:n.statusCode,headers:n.header},n.data)};if(o){var l,d=a.match(/^(https?:\/\/[^\/]+\/)([^\/]*\/?)(.*)$/);e.pathStyle?(l=decodeURIComponent(d[3]||""),a=d[1]+d[2]):(l=decodeURIComponent(d[2]+d[3]||""),a=d[1]);var f={key:l,success_action_status:200,Signature:i.Authorization},h=["Cache-Control","Content-Type","Content-Disposition","Content-Encoding","Expires","x-cos-storage-class","x-cos-security-token"];for(var p in e.headers)e.headers.hasOwnProperty(p)&&(p.indexOf("x-cos-meta-")>-1||h.indexOf(p)>-1)&&(f[p]=e.headers[p]);i["x-cos-acl"]&&(f.acl=i["x-cos-acl"]),!f["Content-Type"]&&(f["Content-Type"]=""),r=wx.uploadFile({url:a,method:s,name:"file",filePath:o,formData:f,success:function(e){u(null,e)},fail:function(e){u(e.errMsg,e)}}),r.onProgressUpdate(function(e){c({loaded:e.totalBytesSent,total:e.totalBytesExpectedToSend,progress:e.progress/100})})}else{var m=e.qs&&n(e.qs)||"";m&&(a+=(a.indexOf("?")>-1?"&":"?")+m),i["Content-Length"]&&delete i["Content-Length"],wx.request({url:a,method:s,header:i,dataType:"text",data:e.body,success:function(e){u(null,e)},fail:function(e){u(e.errMsg,e)}})}return r};e.exports=r},function(e,t,n){var r=n(11).DOMParser,o=function(e){"use strict";function t(e){var t=e.localName;return null==t&&(t=e.baseName),null!=t&&""!=t||(t=e.nodeName),t}function n(e){return e.prefix}function o(e){return"string"==typeof e?e.replace(/&/g,"&amp;").replace(/</g,"&lt;").replace(/>/g,"&gt;").replace(/"/g,"&quot;").replace(/'/g,"&apos;"):e}function i(e,t,n,r){for(var o=0;o<e.length;o++){var i=e[o];if("string"==typeof i){if(i==r)break}else if(i instanceof RegExp){if(i.test(r))break}else if("function"==typeof i&&i(t,n,r))break}return o!=e.length}function a(t,n,r){switch(e.arrayAccessForm){case"property":t[n]instanceof Array?t[n+"_asArray"]=t[n]:t[n+"_asArray"]=[t[n]]}!(t[n]instanceof Array)&&e.arrayAccessFormPaths.length>0&&i(e.arrayAccessFormPaths,t,n,r)&&(t[n]=[t[n]])}function s(e){var t=e.split(/[-T:+Z]/g),n=new Date(t[0],t[1]-1,t[2]),r=t[5].split(".");if(n.setHours(t[3],t[4],r[0]),r.length>1&&n.setMilliseconds(r[1]),t[6]&&t[7]){var o=60*t[6]+Number(t[7]);o=0+("-"==(/\d\d-\d\d:\d\d$/.test(e)?"-":"+")?-1*o:o),n.setMinutes(n.getMinutes()-o-n.getTimezoneOffset())}else-1!==e.indexOf("Z",e.length-1)&&(n=new Date(Date.UTC(n.getFullYear(),n.getMonth(),n.getDate(),n.getHours(),n.getMinutes(),n.getSeconds(),n.getMilliseconds())));return n}function c(t,n,r){if(e.datetimeAccessFormPaths.length>0){var o=r.split(".#")[0];return i(e.datetimeAccessFormPaths,t,n,o)?s(t):t}return t}function u(t,n,r,o){return!(n==A.ELEMENT_NODE&&e.xmlElementsFilter.length>0)||i(e.xmlElementsFilter,t,r,o)}function l(r,o){if(r.nodeType==A.DOCUMENT_NODE){for(var i=new Object,s=r.childNodes,d=0;d<s.length;d++){var f=s.item(d);if(f.nodeType==A.ELEMENT_NODE){var h=t(f);i[h]=l(f,h)}}return i}if(r.nodeType==A.ELEMENT_NODE){var i=new Object;i.__cnt=0;for(var s=r.childNodes,d=0;d<s.length;d++){var f=s.item(d),h=t(f);if(f.nodeType!=A.COMMENT_NODE){var p=o+"."+h;u(i,f.nodeType,h,p)&&(i.__cnt++,null==i[h]?(i[h]=l(f,p),a(i,h,p)):(null!=i[h]&&(i[h]instanceof Array||(i[h]=[i[h]],a(i,h,p))),i[h][i[h].length]=l(f,p)))}}for(var m=0;m<r.attributes.length;m++){var g=r.attributes.item(m);i.__cnt++,i[e.attributePrefix+g.name]=g.value}var y=n(r);return null!=y&&""!=y&&(i.__cnt++,i.__prefix=y),null!=i["#text"]&&(i.__text=i["#text"],i.__text instanceof Array&&(i.__text=i.__text.join("\n")),e.stripWhitespaces&&(i.__text=i.__text.trim()),delete i["#text"],"property"==e.arrayAccessForm&&delete i["#text_asArray"],i.__text=c(i.__text,h,o+"."+h)),null!=i["#cdata-section"]&&(i.__cdata=i["#cdata-section"],delete i["#cdata-section"],"property"==e.arrayAccessForm&&delete i["#cdata-section_asArray"]),0==i.__cnt&&"text"==e.emptyNodeForm?i="":1==i.__cnt&&null!=i.__text?i=i.__text:1!=i.__cnt||null==i.__cdata||e.keepCData?i.__cnt>1&&null!=i.__text&&e.skipEmptyTextNodesForObj&&(e.stripWhitespaces&&""==i.__text||""==i.__text.trim())&&delete i.__text:i=i.__cdata,delete i.__cnt,!e.enableToStringFunc||null==i.__text&&null==i.__cdata||(i.toString=function(){return(null!=this.__text?this.__text:"")+(null!=this.__cdata?this.__cdata:"")}),i}if(r.nodeType==A.TEXT_NODE||r.nodeType==A.CDATA_SECTION_NODE)return r.nodeValue}function d(t,n,r,i){var a="<"+(null!=t&&null!=t.__prefix?t.__prefix+":":"")+n;if(null!=r)for(var s=0;s<r.length;s++){var c=r[s],u=t[c];e.escapeMode&&(u=o(u)),a+=" "+c.substr(e.attributePrefix.length)+"=",e.useDoubleQuotes?a+='"'+u+'"':a+="'"+u+"'"}return a+=i?"/>":">"}function f(e,t){return"</"+(null!=e.__prefix?e.__prefix+":":"")+t+">"}function h(e,t){return-1!==e.indexOf(t,e.length-t.length)}function p(t,n){return!!("property"==e.arrayAccessForm&&h(n.toString(),"_asArray")||0==n.toString().indexOf(e.attributePrefix)||0==n.toString().indexOf("__")||t[n]instanceof Function)}function m(e){var t=0;if(e instanceof Object)for(var n in e)p(e,n)||t++;return t}function g(t,n,r){return 0==e.jsonPropertiesFilter.length||""==r||i(e.jsonPropertiesFilter,t,n,r)}function y(t){var n=[];if(t instanceof Object)for(var r in t)-1==r.toString().indexOf("__")&&0==r.toString().indexOf(e.attributePrefix)&&n.push(r);return n}function C(t){var n="";return null!=t.__cdata&&(n+="<![CDATA["+t.__cdata+"]]>"),null!=t.__text&&(e.escapeMode?n+=o(t.__text):n+=t.__text),n}function v(t){var n="";return t instanceof Object?n+=C(t):null!=t&&(e.escapeMode?n+=o(t):n+=t),n}function x(e,t){return""===e?t:e+"."+t}function k(e,t,n,r){var o="";if(0==e.length)o+=d(e,t,n,!0);else for(var i=0;i<e.length;i++)o+=d(e[i],t,y(e[i]),!1),o+=S(e[i],x(r,t)),o+=f(e[i],t);return o}function S(e,t){var n="";if(m(e)>0)for(var r in e)if(!p(e,r)&&(""==t||g(e,r,x(t,r)))){var o=e[r],i=y(o);if(null==o||void 0==o)n+=d(o,r,i,!0);else if(o instanceof Object)if(o instanceof Array)n+=k(o,r,i,t);else if(o instanceof Date)n+=d(o,r,i,!1),n+=o.toISOString(),n+=f(o,r);else{var a=m(o);a>0||null!=o.__text||null!=o.__cdata?(n+=d(o,r,i,!1),n+=S(o,x(t,r)),n+=f(o,r)):n+=d(o,r,i,!0)}else n+=d(o,r,i,!1),n+=v(o),n+=f(o,r)}return n+=v(e)}e=e||{},function(){void 0===e.escapeMode&&(e.escapeMode=!0),e.attributePrefix=e.attributePrefix||"_",e.arrayAccessForm=e.arrayAccessForm||"none",e.emptyNodeForm=e.emptyNodeForm||"text",void 0===e.enableToStringFunc&&(e.enableToStringFunc=!0),e.arrayAccessFormPaths=e.arrayAccessFormPaths||[],void 0===e.skipEmptyTextNodesForObj&&(e.skipEmptyTextNodesForObj=!0),void 0===e.stripWhitespaces&&(e.stripWhitespaces=!0),e.datetimeAccessFormPaths=e.datetimeAccessFormPaths||[],void 0===e.useDoubleQuotes&&(e.useDoubleQuotes=!1),e.xmlElementsFilter=e.xmlElementsFilter||[],e.jsonPropertiesFilter=e.jsonPropertiesFilter||[],void 0===e.keepCData&&(e.keepCData=!1)}();var A={ELEMENT_NODE:1,TEXT_NODE:3,CDATA_SECTION_NODE:4,COMMENT_NODE:8,DOCUMENT_NODE:9};this.parseXmlString=function(e){if(void 0===e)return null;var t;if(r){var n=new r,o=null;try{o=n.parseFromString("INVALID","text/xml").getElementsByTagName("parsererror")[0].namespaceURI}catch(e){o=null}try{t=n.parseFromString(e,"text/xml"),null!=o&&t.getElementsByTagNameNS(o,"parsererror").length>0&&(t=null)}catch(e){t=null}}else 0==e.indexOf("<?")&&(e=e.substr(e.indexOf("?>")+2)),t=new ActiveXObject("Microsoft.XMLDOM"),t.async="false",t.loadXML(e);return t},this.asArray=function(e){return void 0===e||null==e?[]:e instanceof Array?e:[e]},this.toXmlDateTime=function(e){return e instanceof Date?e.toISOString():"number"==typeof e?new Date(e).toISOString():null},this.asDateTime=function(e){return"string"==typeof e?s(e):e},this.xml2json=function(e){return l(e)},this.xml_str2json=function(e){var t=this.parseXmlString(e);return null!=t?this.xml2json(t):null},this.json2xml_str=function(e){return S(e,"")},this.json2xml=function(e){var t=this.json2xml_str(e);return this.parseXmlString(t)},this.getVersion=function(){return"1.2.0"}},i=function(e){if(!e)return null;var t=new r,n=t.parseFromString(e,"text/xml"),i=new o,a=i.xml2json(n);return a.html&&a.getElementsByTagName("parsererror").length?null:a};e.exports=i},function(e,t,n){function r(e){this.options=e||{locator:{}}}function o(e,t,n){function r(t){var r=e[t];!r&&a&&(r=2==e.length?function(n){e(t,n)}:e),o[t]=r&&function(e){r("[xmldom "+t+"]\t"+e+s(n))}||function(){}}if(!e){if(t instanceof i)return t;e=t}var o={},a=e instanceof Function;return n=n||{},r("warning"),r("error"),r("fatalError"),o}function i(){this.cdata=!1}function a(e,t){t.lineNumber=e.lineNumber,t.columnNumber=e.columnNumber}function s(e){if(e)return"\n@"+(e.systemId||"")+"#[line:"+e.lineNumber+",col:"+e.columnNumber+"]"}function c(e,t,n){return"string"==typeof e?e.substr(t,n):e.length>=t+n||t?new java.lang.String(e,t,n)+"":e}function u(e,t){e.currentElement?e.currentElement.appendChild(t):e.doc.appendChild(t)}r.prototype.parseFromString=function(e,t){var n=this.options,r=new l,a=n.domBuilder||new i,s=n.errorHandler,c=n.locator,u=n.xmlns||{},d={lt:"<",gt:">",amp:"&",quot:'"',apos:"'"};return c&&a.setDocumentLocator(c),r.errorHandler=o(s,a,c),r.domBuilder=n.domBuilder||a,/\/x?html?$/.test(t)&&(d.nbsp=" ",d.copy="©",u[""]="http://www.w3.org/1999/xhtml"),u.xml=u.xml||"http://www.w3.org/XML/1998/namespace",e?r.parse(e,u,d):r.errorHandler.error("invalid doc source"),a.doc},i.prototype={startDocument:function(){this.doc=(new d).createDocument(null,null,null),this.locator&&(this.doc.documentURI=this.locator.systemId)},startElement:function(e,t,n,r){var o=this.doc,i=o.createElementNS(e,n||t),s=r.length;u(this,i),this.currentElement=i,this.locator&&a(this.locator,i);for(var c=0;c<s;c++){var e=r.getURI(c),l=r.getValue(c),n=r.getQName(c),d=o.createAttributeNS(e,n);this.locator&&a(r.getLocator(c),d),d.value=d.nodeValue=l,i.setAttributeNode(d)}},endElement:function(e,t,n){var r=this.currentElement;r.tagName;this.currentElement=r.parentNode},startPrefixMapping:function(e,t){},endPrefixMapping:function(e){},processingInstruction:function(e,t){var n=this.doc.createProcessingInstruction(e,t);this.locator&&a(this.locator,n),u(this,n)},ignorableWhitespace:function(e,t,n){},characters:function(e,t,n){if(e=c.apply(this,arguments)){if(this.cdata)var r=this.doc.createCDATASection(e);else var r=this.doc.createTextNode(e);this.currentElement?this.currentElement.appendChild(r):/^\s*$/.test(e)&&this.doc.appendChild(r),this.locator&&a(this.locator,r)}},skippedEntity:function(e){},endDocument:function(){this.doc.normalize()},setDocumentLocator:function(e){(this.locator=e)&&(e.lineNumber=0)},comment:function(e,t,n){e=c.apply(this,arguments);var r=this.doc.createComment(e);this.locator&&a(this.locator,r),u(this,r)},startCDATA:function(){this.cdata=!0},endCDATA:function(){this.cdata=!1},startDTD:function(e,t,n){var r=this.doc.implementation;if(r&&r.createDocumentType){var o=r.createDocumentType(e,t,n);this.locator&&a(this.locator,o),u(this,o)}},warning:function(e){console.warn("[xmldom warning]\t"+e,s(this.locator))},error:function(e){console.error("[xmldom error]\t"+e,s(this.locator))},fatalError:function(e){throw console.error("[xmldom fatalError]\t"+e,s(this.locator)),e}},"endDTD,startEntity,endEntity,attributeDecl,elementDecl,externalEntityDecl,internalEntityDecl,resolveEntity,getExternalSubset,notationDecl,unparsedEntityDecl".replace(/\w+/g,function(e){i.prototype[e]=function(){return null}});var l=n(12).XMLReader,d=t.DOMImplementation=n(1).DOMImplementation;t.XMLSerializer=n(1).XMLSerializer,t.DOMParser=r},function(e,t){function n(){}function r(e,t,n,r,u){function h(e){if(e>65535){e-=65536;var t=55296+(e>>10),n=56320+(1023&e);return String.fromCharCode(t,n)}return String.fromCharCode(e)}function p(e){var t=e.slice(1,-1);return t in n?n[t]:"#"===t.charAt(0)?h(parseInt(t.substr(1).replace("x","0x"))):(u.error("entity not found:"+e),e)}function m(t){if(t>A){var n=e.substring(A,t).replace(/&#?\w+;/g,p);x&&g(A),r.characters(n,0,t-A),A=t}}function g(t,n){for(;t>=C&&(n=v.exec(e));)y=n.index,C=y+n[0].length,x.lineNumber++;x.columnNumber=t-y+1}for(var y=0,C=0,v=/.*(?:\r\n?|\n)|.*$/g,x=r.locator,k=[{currentNSMap:t}],S={},A=0;;){try{var b=e.indexOf("<",A);if(b<0){if(!e.substr(A).match(/^\s*$/)){var R=r.doc,T=R.createTextNode(e.substr(A));R.appendChild(T),r.currentElement=T}return}switch(b>A&&m(b),e.charAt(b+1)){case"/":var w=e.indexOf(">",b+3),E=e.substring(b+2,w),_=k.pop();w<0?(E=e.substring(b+2).replace(/[\s<].*/,""),u.error("end tag name: "+E+" is not complete:"+_.tagName),w=b+1+E.length):E.match(/\s</)&&(E=E.replace(/[\s<].*/,""),u.error("end tag name: "+E+" maybe not complete"),w=b+1+E.length);var N=_.localNSMap,B=_.tagName==E;if(B||_.tagName&&_.tagName.toLowerCase()==E.toLowerCase()){if(r.endElement(_.uri,_.localName,E),N)for(var D in N)r.endPrefixMapping(D);B||u.fatalError("end tag name: "+E+" is not match the current start tagName:"+_.tagName)}else k.push(_);w++;break;case"?":x&&g(b),w=d(e,b,r);break;case"!":x&&g(b),w=l(e,b,r,u);break;default:x&&g(b);var O=new f,P=k[k.length-1].currentNSMap,w=i(e,b,O,P,p,u),I=O.length;if(!O.closed&&c(e,w,O.tagName,S)&&(O.closed=!0,n.nbsp||u.warning("unclosed xml attribute")),x&&I){for(var M=o(x,{}),L=0;L<I;L++){var F=O[L];g(F.offset),F.locator=o(x,{})}r.locator=M,a(O,r,P)&&k.push(O),r.locator=x}else a(O,r,P)&&k.push(O);"http://www.w3.org/1999/xhtml"!==O.uri||O.closed?w++:w=s(e,w,O.tagName,p,r)}}catch(e){u.error("element parse error: "+e),w=-1}w>A?A=w:m(Math.max(b,A)+1)}}function o(e,t){return t.lineNumber=e.lineNumber,t.columnNumber=e.columnNumber,t}function i(e,t,n,r,o,i){for(var a,s,c=++t,u=C;;){var l=e.charAt(c);switch(l){case"=":if(u===v)a=e.slice(t,c),u=k;else{if(u!==x)throw new Error("attribute equal must after attrName");u=k}break;case"'":case'"':if(u===k||u===v){if(u===v&&(i.warning('attribute value must after "="'),a=e.slice(t,c)),t=c+1,!((c=e.indexOf(l,t))>0))throw new Error("attribute value no end '"+l+"' match");s=e.slice(t,c).replace(/&#?\w+;/g,o),n.add(a,s,t-1),u=A}else{if(u!=S)throw new Error('attribute value must after "="');s=e.slice(t,c).replace(/&#?\w+;/g,o),n.add(a,s,t),i.warning('attribute "'+a+'" missed start quot('+l+")!!"),t=c+1,u=A}break;case"/":switch(u){case C:n.setTagName(e.slice(t,c));case A:case b:case R:u=R,n.closed=!0;case S:case v:case x:break;default:throw new Error("attribute invalid close char('/')")}break;case"":return i.error("unexpected end of input"),u==C&&n.setTagName(e.slice(t,c)),c;case">":switch(u){case C:n.setTagName(e.slice(t,c));case A:case b:case R:break;case S:case v:s=e.slice(t,c),"/"===s.slice(-1)&&(n.closed=!0,s=s.slice(0,-1));case x:u===x&&(s=a),u==S?(i.warning('attribute "'+s+'" missed quot(")!!'),n.add(a,s.replace(/&#?\w+;/g,o),t)):("http://www.w3.org/1999/xhtml"===r[""]&&s.match(/^(?:disabled|checked|selected)$/i)||i.warning('attribute "'+s+'" missed value!! "'+s+'" instead!!'),n.add(s,s,t));break;case k:throw new Error("attribute value missed!!")}return c;case"":l=" ";default:if(l<=" ")switch(u){case C:n.setTagName(e.slice(t,c)),u=b;break;case v:a=e.slice(t,c),u=x;break;case S:var s=e.slice(t,c).replace(/&#?\w+;/g,o);i.warning('attribute "'+s+'" missed quot(")!!'),n.add(a,s,t);case A:u=b}else switch(u){case x:n.tagName;"http://www.w3.org/1999/xhtml"===r[""]&&a.match(/^(?:disabled|checked|selected)$/i)||i.warning('attribute "'+a+'" missed value!! "'+a+'" instead2!!'),n.add(a,a,t),t=c,u=v;break;case A:i.warning('attribute space is required"'+a+'"!!');case b:u=v,t=c;break;case k:u=S,t=c;break;case R:throw new Error("elements closed character '/' and '>' must be connected to")}}c++}}function a(e,t,n){for(var r=e.tagName,o=null,i=e.length;i--;){var a=e[i],s=a.qName,c=a.value,l=s.indexOf(":");if(l>0)var d=a.prefix=s.slice(0,l),f=s.slice(l+1),h="xmlns"===d&&f;else f=s,d=null,h="xmlns"===s&&"";a.localName=f,!1!==h&&(null==o&&(o={},u(n,n={})),n[h]=o[h]=c,a.uri="http://www.w3.org/2000/xmlns/",t.startPrefixMapping(h,c))}for(var i=e.length;i--;){a=e[i];var d=a.prefix;d&&("xml"===d&&(a.uri="http://www.w3.org/XML/1998/namespace"),"xmlns"!==d&&(a.uri=n[d||""]))}var l=r.indexOf(":");l>0?(d=e.prefix=r.slice(0,l),f=e.localName=r.slice(l+1)):(d=null,f=e.localName=r);var p=e.uri=n[d||""];if(t.startElement(p,f,r,e),!e.closed)return e.currentNSMap=n,e.localNSMap=o,!0;if(t.endElement(p,f,r),o)for(d in o)t.endPrefixMapping(d)}function s(e,t,n,r,o){if(/^(?:script|textarea)$/i.test(n)){var i=e.indexOf("</"+n+">",t),a=e.substring(t+1,i);if(/[&<]/.test(a))return/^script$/i.test(n)?(o.characters(a,0,a.length),i):(a=a.replace(/&#?\w+;/g,r),o.characters(a,0,a.length),i)}return t+1}function c(e,t,n,r){var o=r[n];return null==o&&(o=e.lastIndexOf("</"+n+">"),o<t&&(o=e.lastIndexOf("</"+n)),r[n]=o),o<t}function u(e,t){for(var n in e)t[n]=e[n]}function l(e,t,n,r){switch(e.charAt(t+2)){case"-":if("-"===e.charAt(t+3)){var o=e.indexOf("--\x3e",t+4);return o>t?(n.comment(e,t+4,o-t-4),o+3):(r.error("Unclosed comment"),-1)}return-1;default:if("CDATA["==e.substr(t+3,6)){var o=e.indexOf("]]>",t+9);return n.startCDATA(),n.characters(e,t+9,o-t-9),n.endCDATA(),o+3}var i=p(e,t),a=i.length;if(a>1&&/!doctype/i.test(i[0][0])){var s=i[1][0],c=a>3&&/^public$/i.test(i[2][0])&&i[3][0],u=a>4&&i[4][0],l=i[a-1];return n.startDTD(s,c&&c.replace(/^(['"])(.*?)\1$/,"$2"),u&&u.replace(/^(['"])(.*?)\1$/,"$2")),n.endDTD(),l.index+l[0].length}}return-1}function d(e,t,n){var r=e.indexOf("?>",t);if(r){var o=e.substring(t,r).match(/^<\?(\S*)\s*([\s\S]*?)\s*$/);if(o){o[0].length;return n.processingInstruction(o[1],o[2]),r+2}return-1}return-1}function f(e){}function h(e,t){return e.__proto__=t,e}function p(e,t){var n,r=[],o=/'[^']+'|"[^"]+"|[^\s<>\/=]+=?|(\/?\s*>|<)/g;for(o.lastIndex=t,o.exec(e);n=o.exec(e);)if(r.push(n),n[1])return r}var m=/[A-Z_a-z\xC0-\xD6\xD8-\xF6\u00F8-\u02FF\u0370-\u037D\u037F-\u1FFF\u200C-\u200D\u2070-\u218F\u2C00-\u2FEF\u3001-\uD7FF\uF900-\uFDCF\uFDF0-\uFFFD]/,g=new RegExp("[\\-\\.0-9"+m.source.slice(1,-1)+"\\u00B7\\u0300-\\u036F\\u203F-\\u2040]"),y=new RegExp("^"+m.source+g.source+"*(?::"+m.source+g.source+"*)?$"),C=0,v=1,x=2,k=3,S=4,A=5,b=6,R=7;n.prototype={parse:function(e,t,n){var o=this.domBuilder;o.startDocument(),u(t,t={}),r(e,t,n,o,this.errorHandler),o.endDocument()}},f.prototype={setTagName:function(e){if(!y.test(e))throw new Error("invalid tagName:"+e);this.tagName=e},add:function(e,t,n){if(!y.test(e))throw new Error("invalid attribute:"+e);this[this.length++]={qName:e,value:t,offset:n}},length:0,getLocalName:function(e){return this[e].localName},getLocator:function(e){return this[e].locator},getQName:function(e){return this[e].qName},getURI:function(e){return this[e].uri},getValue:function(e){return this[e].value}},h({},h.prototype)instanceof h||(h=function(e,t){function n(){}n.prototype=t,n=new n;for(t in e)n[t]=e[t];return n}),t.XMLReader=n},function(e,t,n){function r(e,t){var n=e.Bucket,r=e.Region,a=e.Key,s=e.UploadId,c=e.Level||"task",l=e.AsyncLimit,d=this,f=new u;if(f.on("error",function(e){return t(e)}),f.on("get_abort_array",function(i){o.call(d,{Bucket:n,Region:r,Key:a,Headers:e.Headers,AsyncLimit:l,AbortArray:i},function(e,n){if(e)return t(e);t(null,n)})}),"bucket"===c)i.call(d,{Bucket:n,Region:r},function(e,n){if(e)return t(e);f.emit("get_abort_array",n.UploadList||[])});else if("file"===c){if(!a)return t({error:"abort_upload_task_no_key"});i.call(d,{Bucket:n,Region:r,Key:a},function(e,n){if(e)return t(e);f.emit("get_abort_array",n.UploadList||[])})}else{if("task"!==c)return t({error:"abort_unknown_level"});if(!s)return t({error:"abort_upload_task_no_id"});if(!a)return t({error:"abort_upload_task_no_key"});f.emit("get_abort_array",[{Key:a,UploadId:s}])}}function o(e,t){var n=e.Bucket,r=e.Region,o=e.Key,i=e.AbortArray,a=e.AsyncLimit||1,s=this,u=0,l=new Array(i.length);c.eachLimit(i,a,function(t,i){var a=u;if(o&&o!==t.Key)return l[a]={error:{KeyNotMatch:!0}},void i(null);var c=t.UploadId||t.UploadID;s.multipartAbort({Bucket:n,Region:r,Key:t.Key,Headers:e.Headers,UploadId:c},function(e,o){var s={Bucket:n,Region:r,Key:t.Key,UploadId:c};l[a]={error:e,task:s},i(null)}),u++},function(e){if(e)return t(e);for(var n=[],r=[],o=0,i=l.length;o<i;o++){var a=l[o];a.task&&(a.error?r.push(a.task):n.push(a.task))}return t(null,{successList:n,errorList:r})})}function i(e,t){var n=this,r=[],o={Bucket:e.Bucket,Region:e.Region,Prefix:e.Key},i=function(){n.multipartList(o,function(e,n){if(e)return t(e);r.push.apply(r,n.Upload||[]),"true"==n.IsTruncated?(o.KeyMarker=n.NextKeyMarker,o.UploadIdMarker=n.NextUploadIdMarker,i()):t(null,{UploadList:r})})};i()}function a(e,t){var n=new u,r=this,o=e.Bucket,i=e.Region,a=e.Key,d=e.CopySource,f=d.match(/^([^.]+-\d+)\.cos(v6)?\.([^.]+)\.[^\/]+\/(.+)$/);if(!f)return void t({error:"CopySource format error"});var h=f[1],p=f[3],m=decodeURIComponent(f[4]),g=void 0===e.SliceSize?r.options.CopySliceSize:e.SliceSize;g=Math.max(0,Math.min(g,5368709120));var y,C,v=e.ChunkSize||this.options.CopyChunkSize,x=this.options.CopyChunkParallelLimit,k=0;n.on("copy_slice_complete",function(e){r.multipartComplete({Bucket:o,Region:i,Key:a,UploadId:e.UploadId,Parts:e.PartList},function(e,n){if(e)return C(null,!0),t(e);C({loaded:y,total:y},!0),t(null,n)})}),n.on("get_copy_data_finish",function(e){c.eachLimit(e.PartList,x,function(t,n){var c=t.PartNumber,u=t.CopySourceRange,l=t.end-t.start,f=0;s.call(r,{Bucket:o,Region:i,Key:a,CopySource:d,UploadId:e.UploadId,PartNumber:c,CopySourceRange:u,onProgress:function(e){k+=e.loaded-f,f=e.loaded,C({loaded:k,total:y})}},function(e,r){if(e)return n(e);C({loaded:k,total:y}),k+=l-f,t.ETag=r.ETag,n(e||null,r)})},function(r){if(r)return C(null,!0),t(r);n.emit("copy_slice_complete",e)})}),n.on("get_file_size_finish",function(s){!function(){for(var t=[1,2,4,8,16,32,64,128,256,512,1024,2048,4096,5120],n=1048576,o=0;o<t.length&&(n=1024*t[o]*1024,!(y/n<=r.options.MaxPartNumber));o++);e.ChunkSize=v=Math.max(v,n);for(var i=Math.ceil(y/v),a=[],s=1;s<=i;s++){var c=(s-1)*v,u=s*v<y?s*v-1:y-1,l={PartNumber:s,start:c,end:u,CopySourceRange:"bytes="+c+"-"+u};a.push(l)}e.PartList=a}();var c;c="Replaced"===e.Headers["x-cos-metadata-directive"]?e.Headers:s,c["x-cos-storage-class"]=e.Headers["x-cos-storage-class"]||s["x-cos-storage-class"],c=l.clearKey(c),r.multipartInit({Bucket:o,Region:i,Key:a,Headers:c},function(r,o){if(r)return t(r);e.UploadId=o.UploadId,n.emit("get_copy_data_finish",e)})}),r.headObject({Bucket:h,Region:p,Key:m},function(o,i){if(o)return void t(o.statusCode&&404===o.statusCode?{ErrorStatus:m+" Not Exist"}:o);if(void 0===(y=e.FileSize=i.headers["content-length"])||!y)return void t({error:'get Content-Length error, please add "Content-Length" to CORS ExposeHeader setting.'});if(C=l.throttleOnProgress.call(r,y,e.onProgress),y<=g)e.Headers["x-cos-metadata-directive"]||(e.Headers["x-cos-metadata-directive"]="Copy"),r.putObjectCopy(e,function(e,n){if(e)return C(null,!0),t(e);C({loaded:y,total:y},!0),t(e,n)});else{var a=i.headers,s={"Cache-Control":a["cache-control"],"Content-Disposition":a["content-disposition"],"Content-Encoding":a["content-encoding"],"Content-Type":a["content-type"],Expires:a.expires,"x-cos-storage-class":a["x-cos-storage-class"]};l.each(a,function(e,t){0===t.indexOf("x-cos-meta-")&&t.length>"x-cos-meta-".length&&(s[t]=e)}),n.emit("get_file_size_finish",s)}})}function s(e,t){var n=e.TaskId,r=e.Bucket,o=e.Region,i=e.Key,a=e.CopySource,s=e.UploadId,u=1*e.PartNumber,l=e.CopySourceRange,d=this.options.ChunkRetryTimes+1,f=this;c.retry(d,function(t){f.uploadPartCopy({TaskId:n,Bucket:r,Region:o,Key:i,CopySource:a,UploadId:s,PartNumber:u,CopySourceRange:l,onProgress:e.onProgress},function(e,n){t(e||null,n)})},function(e,n){return t(e,n)})}var c=n(14),u=n(2).EventProxy,l=n(0),d={abortUploadTask:r,sliceCopyFile:a};e.exports.init=function(e,t){l.each(d,function(t,n){e.prototype[n]=l.apiWrapper(n,t)})}},function(e,t){var n=function(e,t,n,r){if(r=r||function(){},!e.length||t<=0)return r();var o=0,i=0,a=0;!function s(){if(o>=e.length)return r();for(;a<t&&i<e.length;)i+=1,a+=1,n(e[i-1],function(t){t?(r(t),r=function(){}):(o+=1,a-=1,o>=e.length?r():s())})}()},r=function(e,t,n){var r=function(o){t(function(t,i){t&&o<e?r(o+1):n(t,i)})};e<1?n():r(1)},o={eachLimit:n,retry:r};e.exports=o},function(e,t,n){"use strict";function r(e,t){"function"==typeof e&&(t=e,e={});var n=this.options.ServiceDomain,r=e.AppId||this.options.appId;n?(n=n.replace(/\{\{AppId\}\}/gi,r||"").replace(/\{\{.*?\}\}/gi,""),/^[a-zA-Z]+:\/\//.test(n)||(n="https://"+n),"/"===n.slice(-1)&&(n=n.slice(0,-1))):n="https://service.cos.myqcloud.com",ee.call(this,{Action:"name/cos:GetService",url:n+"/",method:"GET"},function(e,n){if(e)return t(e);var r=n&&n.ListAllMyBucketsResult&&n.ListAllMyBucketsResult.Buckets&&n.ListAllMyBucketsResult.Buckets.Bucket||[];r=re.isArray(r)?r:[r],t(null,{Buckets:r,statusCode:n.statusCode,headers:n.headers})})}function o(e,t){ee.call(this,{Action:"name/cos:HeadBucket",Bucket:e.Bucket,Region:e.Region,headers:e.Headers,method:"HEAD"},function(e,n){t(e,n)})}function i(e,t){var n={};n.prefix=e.Prefix||"",n.delimiter=e.Delimiter,n.marker=e.Marker,n["max-keys"]=e.MaxKeys,n["encoding-type"]=e.EncodingType,ee.call(this,{Action:"name/cos:GetBucket",ResourceKey:n.prefix,method:"GET",Bucket:e.Bucket,Region:e.Region,headers:e.Headers,qs:n},function(e,n){if(e)return t(e);var r=n.ListBucketResult||{},o=r.Contents||[],i=r.CommonPrefixes||[];o=re.isArray(o)?o:[o],i=re.isArray(i)?i:[i];var a=re.clone(r);re.extend(a,{Contents:o,CommonPrefixes:i,statusCode:n.statusCode,headers:n.headers}),t(null,a)})}function a(e,t){var n=this,r={};r["x-cos-acl"]=e.ACL,r["x-cos-grant-read"]=e.GrantRead,r["x-cos-grant-write"]=e.GrantWrite,r["x-cos-grant-read-acp"]=e.GrantReadAcp,r["x-cos-grant-write-acp"]=e.GrantWriteAcp,r["x-cos-grant-full-control"]=e.GrantFullControl,ee.call(this,{Action:"name/cos:PutBucket",method:"PUT",Bucket:e.Bucket,Region:e.Region,headers:r},function(r,o){if(r)return t(r);var i=Z({domain:n.options.Domain,bucket:e.Bucket,region:e.Region,isLocation:!0});t(null,{Location:i,statusCode:o.statusCode,headers:o.headers})})}function s(e,t){ee.call(this,{Action:"name/cos:DeleteBucket",Bucket:e.Bucket,Region:e.Region,headers:e.Headers,method:"DELETE"},function(e,n){return e&&204===e.statusCode?t(null,{statusCode:e.statusCode}):e?t(e):void t(null,{statusCode:n.statusCode,headers:n.headers})})}function c(e,t){ee.call(this,{Action:"name/cos:GetBucketACL",method:"GET",Bucket:e.Bucket,Region:e.Region,headers:e.Headers,action:"acl"},function(e,n){if(e)return t(e);var r=n.AccessControlPolicy||{},o=r.Owner||{},i=r.AccessControlList.Grant||[];i=re.isArray(i)?i:[i];var a=W(r);n.headers&&n.headers["x-cos-acl"]&&(a.ACL=n.headers["x-cos-acl"]),a=re.extend(a,{Owner:o,Grants:i,statusCode:n.statusCode,headers:n.headers}),t(null,a)})}function u(e,t){var n=e.Headers,r="";if(e.AccessControlPolicy){var o=re.clone(e.AccessControlPolicy||{}),i=o.Grants||o.Grant;i=re.isArray(i)?i:[i],delete o.Grant,delete o.Grants,o.AccessControlList={Grant:i},r=re.json2xml({AccessControlPolicy:o}),n["Content-Type"]="application/xml",n["Content-MD5"]=re.binaryBase64(re.md5(r))}re.each(n,function(e,t){0===t.indexOf("x-cos-grant-")&&(n[t]=Q(n[t]))}),ee.call(this,{Action:"name/cos:PutBucketACL",method:"PUT",Bucket:e.Bucket,Region:e.Region,headers:n,action:"acl",body:r},function(e,n){if(e)return t(e);t(null,{statusCode:n.statusCode,headers:n.headers})})}function l(e,t){ee.call(this,{Action:"name/cos:GetBucketCORS",method:"GET",Bucket:e.Bucket,Region:e.Region,headers:e.Headers,action:"cors"},function(e,n){if(e)if(404===e.statusCode&&e.error&&"NoSuchCORSConfiguration"===e.error.Code){var r={CORSRules:[],statusCode:e.statusCode};e.headers&&(r.headers=e.headers),t(null,r)}else t(e);else{var o=n.CORSConfiguration||{},i=o.CORSRules||o.CORSRule||[];i=re.clone(re.isArray(i)?i:[i]),re.each(i,function(e){re.each(["AllowedOrigin","AllowedHeader","AllowedMethod","ExposeHeader"],function(t,n){var r=t+"s",o=e[r]||e[t]||[];delete e[t],e[r]=re.isArray(o)?o:[o]})}),t(null,{CORSRules:i,statusCode:n.statusCode,headers:n.headers})}})}function d(e,t){var n=e.CORSConfiguration||{},r=n.CORSRules||e.CORSRules||[];r=re.clone(re.isArray(r)?r:[r]),re.each(r,function(e){re.each(["AllowedOrigin","AllowedHeader","AllowedMethod","ExposeHeader"],function(t,n){var r=t+"s",o=e[r]||e[t]||[];delete e[r],e[t]=re.isArray(o)?o:[o]})});var o=re.json2xml({CORSConfiguration:{CORSRule:r}}),i=e.Headers;i["Content-Type"]="application/xml",i["Content-MD5"]=re.binaryBase64(re.md5(o)),ee.call(this,{Action:"name/cos:PutBucketCORS",method:"PUT",Bucket:e.Bucket,Region:e.Region,body:o,action:"cors",headers:i},function(e,n){if(e)return t(e);t(null,{statusCode:n.statusCode,headers:n.headers})})}function f(e,t){ee.call(this,{Action:"name/cos:DeleteBucketCORS",method:"DELETE",Bucket:e.Bucket,Region:e.Region,headers:e.Headers,action:"cors"},function(e,n){return e&&204===e.statusCode?t(null,{statusCode:e.statusCode}):e?t(e):void t(null,{statusCode:n.statusCode||e.statusCode,headers:n.headers})})}function h(e,t){var n=e.Policy,r=n;try{"string"==typeof n?n=JSON.parse(r):r=JSON.stringify(n)}catch(e){t({error:"Policy format error"})}var o=e.Headers;o["Content-Type"]="application/json",o["Content-MD5"]=re.binaryBase64(re.md5(r)),ee.call(this,{Action:"name/cos:PutBucketPolicy",method:"PUT",Bucket:e.Bucket,Region:e.Region,action:"policy",body:re.isBrowser?r:n,headers:o,json:!0},function(e,n){return e&&204===e.statusCode?t(null,{statusCode:e.statusCode}):e?t(e):void t(null,{statusCode:n.statusCode,headers:n.headers})})}function p(e,t){ee.call(this,{Action:"name/cos:DeleteBucketPolicy",method:"DELETE",Bucket:e.Bucket,Region:e.Region,headers:e.Headers,action:"policy"},function(e,n){return e&&204===e.statusCode?t(null,{statusCode:e.statusCode}):e?t(e):void t(null,{statusCode:n.statusCode||e.statusCode,headers:n.headers})})}function m(e,t){ee.call(this,{Action:"name/cos:GetBucketLocation",method:"GET",Bucket:e.Bucket,Region:e.Region,headers:e.Headers,action:"location"},function(e,n){if(e)return t(e);t(null,n)})}function g(e,t){ee.call(this,{Action:"name/cos:GetBucketPolicy",method:"GET",Bucket:e.Bucket,Region:e.Region,headers:e.Headers,action:"policy",rawBody:!0},function(e,n){if(e)return t(e.statusCode&&403===e.statusCode?{ErrorStatus:"Access Denied"}:e.statusCode&&405===e.statusCode?{ErrorStatus:"Method Not Allowed"}:e.statusCode&&404===e.statusCode?{ErrorStatus:"Policy Not Found"}:e);var r={};try{r=JSON.parse(n.body)}catch(e){}t(null,{Policy:r,statusCode:n.statusCode,headers:n.headers})})}function y(e,t){ee.call(this,{Action:"name/cos:GetBucketTagging",method:"GET",Bucket:e.Bucket,Region:e.Region,headers:e.Headers,action:"tagging"},function(e,n){if(e)if(404!==e.statusCode||!e.error||"Not Found"!==e.error&&"NoSuchTagSet"!==e.error.Code)t(e);else{var r={Tags:[],statusCode:e.statusCode};e.headers&&(r.headers=e.headers),t(null,r)}else{var o=[];try{o=n.Tagging.TagSet.Tag||[]}catch(e){}o=re.clone(re.isArray(o)?o:[o]),t(null,{Tags:o,statusCode:n.statusCode,headers:n.headers})}})}function C(e,t){var n=e.Tagging||{},r=n.TagSet||n.Tags||e.Tags||[];r=re.clone(re.isArray(r)?r:[r]);var o=re.json2xml({Tagging:{TagSet:{Tag:r}}}),i=e.Headers;i["Content-Type"]="application/xml",i["Content-MD5"]=re.binaryBase64(re.md5(o)),ee.call(this,{Action:"name/cos:PutBucketTagging",method:"PUT",Bucket:e.Bucket,Region:e.Region,body:o,action:"tagging",headers:i},function(e,n){return e&&204===e.statusCode?t(null,{statusCode:e.statusCode}):e?t(e):void t(null,{statusCode:n.statusCode,headers:n.headers})})}function v(e,t){ee.call(this,{Action:"name/cos:DeleteBucketTagging",method:"DELETE",Bucket:e.Bucket,Region:e.Region,headers:e.Headers,action:"tagging"},function(e,n){return e&&204===e.statusCode?t(null,{statusCode:e.statusCode}):e?t(e):void t(null,{statusCode:n.statusCode,headers:n.headers})})}function x(e,t){var n=e.LifecycleConfiguration||{},r=n.Rules||[];r=re.clone(r);var o=re.json2xml({LifecycleConfiguration:{Rule:r}}),i=e.Headers;i["Content-Type"]="application/xml",i["Content-MD5"]=re.binaryBase64(re.md5(o)),ee.call(this,{Action:"name/cos:PutBucketLifecycle",method:"PUT",Bucket:e.Bucket,Region:e.Region,body:o,action:"lifecycle",headers:i},function(e,n){return e&&204===e.statusCode?t(null,{statusCode:e.statusCode}):e?t(e):void t(null,{statusCode:n.statusCode,headers:n.headers})})}function k(e,t){ee.call(this,{Action:"name/cos:GetBucketLifecycle",method:"GET",Bucket:e.Bucket,Region:e.Region,headers:e.Headers,action:"lifecycle"},function(e,n){if(e)if(404===e.statusCode&&e.error&&"NoSuchLifecycleConfiguration"===e.error.Code){var r={Rules:[],statusCode:e.statusCode};e.headers&&(r.headers=e.headers),t(null,r)}else t(e);else{var o=[];try{o=n.LifecycleConfiguration.Rule||[]}catch(e){}o=re.clone(re.isArray(o)?o:[o]),t(null,{Rules:o,statusCode:n.statusCode,headers:n.headers})}})}function S(e,t){ee.call(this,{Action:"name/cos:DeleteBucketLifecycle",method:"DELETE",Bucket:e.Bucket,Region:e.Region,headers:e.Headers,action:"lifecycle"},function(e,n){return e&&204===e.statusCode?t(null,{statusCode:e.statusCode}):e?t(e):void t(null,{statusCode:n.statusCode,headers:n.headers})})}function A(e,t){if(!e.VersioningConfiguration)return void t({error:"missing param VersioningConfiguration"});var n=e.VersioningConfiguration||{},r=re.json2xml({VersioningConfiguration:n}),o=e.Headers;o["Content-Type"]="application/xml",o["Content-MD5"]=re.binaryBase64(re.md5(r)),ee.call(this,{Action:"name/cos:PutBucketVersioning",method:"PUT",Bucket:e.Bucket,Region:e.Region,body:r,action:"versioning",headers:o},function(e,n){return e&&204===e.statusCode?t(null,{statusCode:e.statusCode}):e?t(e):void t(null,{statusCode:n.statusCode,headers:n.headers})})}function b(e,t){ee.call(this,{Action:"name/cos:GetBucketVersioning",method:"GET",Bucket:e.Bucket,Region:e.Region,headers:e.Headers,action:"versioning"},function(e,n){e||!n.VersioningConfiguration&&(n.VersioningConfiguration={}),t(e,n)})}function R(e,t){var n=re.clone(e.ReplicationConfiguration),r=re.json2xml({ReplicationConfiguration:n});r=r.replace(/<(\/?)Rules>/gi,"<$1Rule>"),r=r.replace(/<(\/?)Tags>/gi,"<$1Tag>");var o=e.Headers;o["Content-Type"]="application/xml",o["Content-MD5"]=re.binaryBase64(re.md5(r)),ee.call(this,{Action:"name/cos:PutBucketReplication",method:"PUT",Bucket:e.Bucket,Region:e.Region,body:r,action:"replication",headers:o},function(e,n){return e&&204===e.statusCode?t(null,{statusCode:e.statusCode}):e?t(e):void t(null,{statusCode:n.statusCode,headers:n.headers})})}function T(e,t){ee.call(this,{Action:"name/cos:GetBucketReplication",method:"GET",Bucket:e.Bucket,Region:e.Region,headers:e.Headers,action:"replication"},function(e,n){if(e)if(404!==e.statusCode||!e.error||"Not Found"!==e.error&&"ReplicationConfigurationnotFoundError"!==e.error.Code)t(e);else{var r={ReplicationConfiguration:{Rules:[]},statusCode:e.statusCode};e.headers&&(r.headers=e.headers),t(null,r)}else e||!n.ReplicationConfiguration&&(n.ReplicationConfiguration={}),n.ReplicationConfiguration.Rule&&(n.ReplicationConfiguration.Rules=n.ReplicationConfiguration.Rule,delete n.ReplicationConfiguration.Rule),t(e,n)})}function w(e,t){ee.call(this,{Action:"name/cos:DeleteBucketReplication",method:"DELETE",Bucket:e.Bucket,Region:e.Region,headers:e.Headers,action:"replication"},function(e,n){return e&&204===e.statusCode?t(null,{statusCode:e.statusCode}):e?t(e):void t(null,{statusCode:n.statusCode,headers:n.headers})})}function E(e,t){ee.call(this,{Action:"name/cos:HeadObject",method:"HEAD",Bucket:e.Bucket,Region:e.Region,Key:e.Key,VersionId:e.VersionId,headers:e.Headers},function(n,r){if(n){var o=n.statusCode;return e.Headers["If-Modified-Since"]&&o&&304===o?t(null,{NotModified:!0,statusCode:o}):t(n)}r.headers&&r.headers.etag&&(r.ETag=r.headers&&r.headers.etag),t(null,r)})}function _(e,t){var n={};n.prefix=e.Prefix||"",n.delimiter=e.Delimiter,n["key-marker"]=e.KeyMarker,n["version-id-marker"]=e.VersionIdMarker,n["max-keys"]=e.MaxKeys,n["encoding-type"]=e.EncodingType,ee.call(this,{Action:"name/cos:GetBucketObjectVersions",ResourceKey:n.prefix,method:"GET",Bucket:e.Bucket,Region:e.Region,headers:e.Headers,qs:n,action:"versions"},function(e,n){if(e)return t(e);var r=n.ListVersionsResult||{},o=r.DeleteMarker||[];o=re.isArray(o)?o:[o];var i=r.Version||[];i=re.isArray(i)?i:[i];var a=re.clone(r);delete a.DeleteMarker,delete a.Version,re.extend(a,{DeleteMarkers:o,Versions:i,statusCode:n.statusCode,headers:n.headers}),t(null,a)})}function N(e,t){var n={};n["response-content-type"]=e.ResponseContentType,n["response-content-language"]=e.ResponseContentLanguage,n["response-expires"]=e.ResponseExpires,n["response-cache-control"]=e.ResponseCacheControl,n["response-content-disposition"]=e.ResponseContentDisposition,n["response-content-encoding"]=e.ResponseContentEncoding,ee.call(this,{Action:"name/cos:GetObject",method:"GET",Bucket:e.Bucket,Region:e.Region,Key:e.Key,VersionId:e.VersionId,headers:e.Headers,qs:n,rawBody:!0},function(n,r){if(n){var o=n.statusCode;return e.Headers["If-Modified-Since"]&&o&&304===o?t(null,{NotModified:!0}):t(n)}var i={};i.Body=r.body,r.headers&&r.headers.etag&&(i.ETag=r.headers&&r.headers.etag),re.extend(i,{statusCode:r.statusCode,headers:r.headers}),t(null,i)})}function B(e,t){var n=this,r=e.ContentLength,o=re.throttleOnProgress.call(n,r,e.onProgress);re.getBodyMd5(n.options.UploadCheckContentMd5,e.Body,function(i){i&&(e.Headers["Content-MD5"]=re.binaryBase64(i)),void 0!==e.ContentLength&&(e.Headers["Content-Length"]=e.ContentLength),ee.call(n,{Action:"name/cos:PutObject",TaskId:e.TaskId,method:"PUT",Bucket:e.Bucket,Region:e.Region,Key:e.Key,headers:e.Headers,body:e.Body,onProgress:o},function(i,a){if(i)return o(null,!0),t(i);if(o({loaded:r,total:r},!0),a&&a.headers&&a.headers.etag){var s=Z({ForcePathStyle:n.options.ForcePathStyle,protocol:n.options.Protocol,domain:n.options.Domain,bucket:e.Bucket,region:e.Region,object:e.Key});return s=s.substr(s.indexOf("://")+3),t(null,{Location:s,ETag:a.headers.etag,statusCode:a.statusCode,headers:a.headers})}t(null,a)})})}function D(e,t){var n=this,r={};r["Cache-Control"]=e.CacheControl,r["Content-Disposition"]=e.ContentDisposition,r["Content-Encoding"]=e.ContentEncoding,r["Content-MD5"]=e.ContentMD5,r["Content-Length"]=e.ContentLength,r["Content-Type"]=e.ContentType,r.Expect=e.Expect,r.Expires=e.Expires,r["x-cos-acl"]=e.ACL,r["x-cos-grant-read"]=e.GrantRead,r["x-cos-grant-write"]=e.GrantWrite,r["x-cos-grant-full-control"]=e.GrantFullControl,r["x-cos-storage-class"]=e.StorageClass;var o=e.FilePath;for(var i in e)i.indexOf("x-cos-meta-")>-1&&(r[i]=e[i]);var a=re.throttleOnProgress.call(n,r["Content-Length"],e.onProgress);ee.call(this,{Action:"name/cos:PostObject",method:"POST",Bucket:e.Bucket,Region:e.Region,Key:e.Key,headers:r,filePath:o,onProgress:a},function(r,o){if(a(null,!0),r)return t(r);if(o){var i=Z({ForcePathStyle:n.options.ForcePathStyle,protocol:n.options.Protocol,domain:n.options.Domain,bucket:e.Bucket,region:e.Region,object:e.Key,isLocation:!0});return t(null,{Location:i,statusCode:o.statusCode})}t(null,o)})}function O(e,t){ee.call(this,{Action:"name/cos:DeleteObject",method:"DELETE",Bucket:e.Bucket,Region:e.Region,Key:e.Key,headers:e.Headers,VersionId:e.VersionId},function(e,n){if(e){var r=e.statusCode;return r&&204===r?t(null,{statusCode:r}):r&&404===r?t(null,{BucketNotFound:!0,statusCode:r}):t(e)}t(null,{statusCode:n.statusCode,headers:n.headers})})}function P(e,t){ee.call(this,{Action:"name/cos:GetObjectACL",method:"GET",Bucket:e.Bucket,Region:e.Region,Key:e.Key,headers:e.Headers,action:"acl"},function(e,n){if(e)return t(e);var r=n.AccessControlPolicy||{},o=r.Owner||{},i=r.AccessControlList&&r.AccessControlList.Grant||[];i=re.isArray(i)?i:[i];var a=W(r);n.headers&&n.headers["x-cos-acl"]&&(a.ACL=n.headers["x-cos-acl"]),a=re.extend(a,{Owner:o,Grants:i,statusCode:n.statusCode,headers:n.headers}),t(null,a)})}function I(e,t){var n=e.Headers,r="";if(e.AccessControlPolicy){var o=re.clone(e.AccessControlPolicy||{}),i=o.Grants||o.Grant;i=re.isArray(i)?i:[i],delete o.Grant,delete o.Grants,o.AccessControlList={Grant:i},r=re.json2xml({AccessControlPolicy:o}),n["Content-Type"]="application/xml",n["Content-MD5"]=re.binaryBase64(re.md5(r))}re.each(n,function(e,t){0===t.indexOf("x-cos-grant-")&&(n[t]=Q(n[t]))}),ee.call(this,{Action:"name/cos:PutObjectACL",method:"PUT",Bucket:e.Bucket,Region:e.Region,Key:e.Key,action:"acl",headers:n,body:r},function(e,n){if(e)return t(e);t(null,{statusCode:n.statusCode,headers:n.headers})})}function M(e,t){var n=e.Headers;n.Origin=e.Origin,n["Access-Control-Request-Method"]=e.AccessControlRequestMethod,n["Access-Control-Request-Headers"]=e.AccessControlRequestHeaders,ee.call(this,{Action:"name/cos:OptionsObject",method:"OPTIONS",Bucket:e.Bucket,Region:e.Region,Key:e.Key,headers:n},function(e,n){if(e)return e.statusCode&&403===e.statusCode?t(null,{OptionsForbidden:!0,statusCode:e.statusCode}):t(e);var r=n.headers||{};t(null,{AccessControlAllowOrigin:r["access-control-allow-origin"],AccessControlAllowMethods:r["access-control-allow-methods"],AccessControlAllowHeaders:r["access-control-allow-headers"],AccessControlExposeHeaders:r["access-control-expose-headers"],AccessControlMaxAge:r["access-control-max-age"],statusCode:n.statusCode,headers:n.headers})})}function L(e,t){var n=e.CopySource||"",r=n.match(/^([^.]+-\d+)\.cos(v6)?\.([^.]+)\.[^\/]+\/(.+)$/);if(!r)return void t({error:"CopySource format error"});var o=r[1],i=r[3],a=decodeURIComponent(r[4]);ee.call(this,{Scope:[{action:"name/cos:GetObject",bucket:o,region:i,prefix:a},{action:"name/cos:PutObject",bucket:e.Bucket,region:e.Region,prefix:e.Key}],method:"PUT",Bucket:e.Bucket,Region:e.Region,Key:e.Key,VersionId:e.VersionId,headers:e.Headers},function(e,n){if(e)return t(e);var r=re.clone(n.CopyObjectResult||{});re.extend(r,{statusCode:n.statusCode,headers:n.headers}),t(null,r)})}function F(e,t){var n=e.CopySource||"",r=n.match(/^([^.]+-\d+)\.cos(v6)?\.([^.]+)\.[^\/]+\/(.+)$/);if(!r)return void t({error:"CopySource format error"});var o=r[1],i=r[3],a=decodeURIComponent(r[4]);ee.call(this,{Scope:[{action:"name/cos:GetObject",bucket:o,region:i,prefix:a},{action:"name/cos:PutObject",bucket:e.Bucket,region:e.Region,prefix:e.Key}],method:"PUT",Bucket:e.Bucket,Region:e.Region,Key:e.Key,VersionId:e.VersionId,qs:{partNumber:e.PartNumber,uploadId:e.UploadId},headers:e.Headers},function(e,n){if(e)return t(e);var r=re.clone(n.CopyPartResult||{});re.extend(r,{statusCode:n.statusCode,headers:n.headers}),t(null,r)})}function U(e,t){var n=e.Objects||[],r=e.Quiet;n=re.isArray(n)?n:[n];var o=re.json2xml({Delete:{Object:n,Quiet:r||!1}}),i=e.Headers;i["Content-Type"]="application/xml",i["Content-MD5"]=re.binaryBase64(re.md5(o));var a=re.map(n,function(t){return{action:"name/cos:DeleteObject",bucket:e.Bucket,region:e.Region,prefix:t.Key}});ee.call(this,{Scope:a,method:"POST",Bucket:e.Bucket,Region:e.Region,body:o,action:"delete",headers:i},function(e,n){if(e)return t(e);var r=n.DeleteResult||{},o=r.Deleted||[],i=r.Error||[];o=re.isArray(o)?o:[o],i=re.isArray(i)?i:[i];var a=re.clone(r);re.extend(a,{Error:i,Deleted:o,statusCode:n.statusCode,headers:n.headers}),t(null,a)})}function j(e,t){var n=e.Headers;if(!e.RestoreRequest)return void t({error:"missing param RestoreRequest"});var r=e.RestoreRequest||{},o=re.json2xml({RestoreRequest:r});n["Content-Type"]="application/xml",n["Content-MD5"]=re.binaryBase64(re.md5(o)),ee.call(this,{Action:"name/cos:RestoreObject",method:"POST",Bucket:e.Bucket,Region:e.Region,Key:e.Key,VersionId:e.VersionId,body:o,action:"restore",headers:n},function(e,n){t(e,n)})}function K(e,t){ee.call(this,{Action:"name/cos:InitiateMultipartUpload",method:"POST",Bucket:e.Bucket,Region:e.Region,Key:e.Key,action:"uploads",headers:e.Headers},function(e,n){return e?t(e):(n=re.clone(n||{}))&&n.InitiateMultipartUploadResult?t(null,re.extend(n.InitiateMultipartUploadResult,{statusCode:n.statusCode,headers:n.headers})):void t(null,n)})}function H(e,t){var n=this;re.getFileSize("multipartUpload",e,function(){re.getBodyMd5(n.options.UploadCheckContentMd5,e.Body,function(r){r&&(e.Headers["Content-MD5"]=re.binaryBase64(r)),ee.call(n,{Action:"name/cos:UploadPart",TaskId:e.TaskId,method:"PUT",Bucket:e.Bucket,Region:e.Region,Key:e.Key,qs:{partNumber:e.PartNumber,uploadId:e.UploadId},headers:e.Headers,onProgress:e.onProgress,body:e.Body||null},function(e,n){if(e)return t(e);n.headers=n.headers||{},t(null,{ETag:n.headers.etag||"",statusCode:n.statusCode,headers:n.headers})})})})}function z(e,t){for(var n=this,r=e.UploadId,o=e.Parts,i=0,a=o.length;i<a;i++)0!==o[i].ETag.indexOf('"')&&(o[i].ETag='"'+o[i].ETag+'"');var s=re.json2xml({CompleteMultipartUpload:{Part:o}}),c=e.Headers;c["Content-Type"]="application/xml",c["Content-MD5"]=re.binaryBase64(re.md5(s)),ee.call(this,{Action:"name/cos:CompleteMultipartUpload",method:"POST",Bucket:e.Bucket,Region:e.Region,Key:e.Key,qs:{uploadId:r},body:s,headers:c},function(r,o){if(r)return t(r);var i=Z({ForcePathStyle:n.options.ForcePathStyle,protocol:n.options.Protocol,domain:n.options.Domain,bucket:e.Bucket,region:e.Region,object:e.Key,isLocation:!0}),a=o.CompleteMultipartUploadResult||{},s=re.extend(a,{Location:i,statusCode:o.statusCode,headers:o.headers});t(null,s)})}function G(e,t){var n={};n.delimiter=e.Delimiter,n["encoding-type"]=e.EncodingType,n.prefix=e.Prefix||"",n["max-uploads"]=e.MaxUploads,n["key-marker"]=e.KeyMarker,n["upload-id-marker"]=e.UploadIdMarker,n=re.clearKey(n),ee.call(this,{Action:"name/cos:ListMultipartUploads",ResourceKey:n.prefix,method:"GET",Bucket:e.Bucket,Region:e.Region,headers:e.Headers,qs:n,action:"uploads"},function(e,n){if(e)return t(e);if(n&&n.ListMultipartUploadsResult){var r=n.ListMultipartUploadsResult.Upload||[],o=n.ListMultipartUploadsResult.CommonPrefixes||[];o=re.isArray(o)?o:[o],r=re.isArray(r)?r:[r],n.ListMultipartUploadsResult.Upload=r,n.ListMultipartUploadsResult.CommonPrefixes=o}var i=re.clone(n.ListMultipartUploadsResult||{});re.extend(i,{statusCode:n.statusCode,headers:n.headers}),t(null,i)})}function q(e,t){var n={};n.uploadId=e.UploadId,n["encoding-type"]=e.EncodingType,n["max-parts"]=e.MaxParts,n["part-number-marker"]=e.PartNumberMarker,ee.call(this,{Action:"name/cos:ListParts",method:"GET",Bucket:e.Bucket,Region:e.Region,Key:e.Key,headers:e.Headers,qs:n},function(e,n){if(e)return t(e);var r=n.ListPartsResult||{},o=r.Part||[];o=re.isArray(o)?o:[o],r.Part=o;var i=re.clone(r);re.extend(i,{statusCode:n.statusCode,headers:n.headers}),t(null,i)})}function V(e,t){var n={};n.uploadId=e.UploadId,ee.call(this,{Action:"name/cos:AbortMultipartUpload",method:"DELETE",Bucket:e.Bucket,Region:e.Region,Key:e.Key,headers:e.Headers,qs:n},function(e,n){if(e)return t(e);t(null,{statusCode:n.statusCode,headers:n.headers})})}function X(e){var t=this;return re.getAuth({SecretId:e.SecretId||this.options.SecretId||"",SecretKey:e.SecretKey||this.options.SecretKey||"",Method:e.Method,Key:e.Key,Query:e.Query,Headers:e.Headers,Expires:e.Expires,SystemClockOffset:t.options.SystemClockOffset})}function $(e,t){var n=this,r=Z({ForcePathStyle:n.options.ForcePathStyle,protocol:e.Protocol||n.options.Protocol,domain:n.options.Domain,bucket:e.Bucket,region:e.Region,object:e.Key});if(void 0!==e.Sign&&!e.Sign)return t(null,{Url:r}),r;var o=Y.call(this,{Action:"PUT"===(e.Method||"").toUpperCase()?"name/cos:PutObject":"name/cos:GetObject",Bucket:e.Bucket||"",Region:e.Region||"",Method:e.Method||"get",Key:e.Key,Expires:e.Expires},function(e,n){if(t){if(e)return void t(e);var o=r;o+="?"+(n.Authorization.indexOf("q-signature")>-1?n.Authorization:"sign="+encodeURIComponent(n.Authorization)),n.XCosSecurityToken&&(o+="&x-cos-security-token="+n.XCosSecurityToken),n.ClientIP&&(o+="&clientIP="+n.ClientIP),n.ClientUA&&(o+="&clientUA="+n.ClientUA),n.Token&&(o+="&token="+n.Token),setTimeout(function(){t(null,{Url:o})})}});return o?r+"?"+o.Authorization+(o.XCosSecurityToken?"&x-cos-security-token="+o.XCosSecurityToken:""):r}function W(e){var t={GrantFullControl:[],GrantWrite:[],GrantRead:[],GrantReadAcp:[],GrantWriteAcp:[],ACL:""},n={FULL_CONTROL:"GrantFullControl",WRITE:"GrantWrite",READ:"GrantRead",READ_ACP:"GrantReadAcp",WRITE_ACP:"GrantWriteAcp"},r=e.AccessControlList.Grant;r&&(r=re.isArray(r)?r:[r]);var o={READ:0,WRITE:0,FULL_CONTROL:0};return r.length&&re.each(r,function(r){"qcs::cam::anyone:anyone"===r.Grantee.ID||"http://cam.qcloud.com/groups/global/AllUsers"===r.Grantee.URI?o[r.Permission]=1:r.Grantee.ID!==e.Owner.ID&&t[n[r.Permission]].push('id="'+r.Grantee.ID+'"')}),o.FULL_CONTROL||o.WRITE&&o.READ?t.ACL="public-read-write":o.READ?t.ACL="public-read":t.ACL="private",re.each(n,function(e){t[e]=Q(t[e].join(","))}),t}function Q(e){var t,n,r=e.split(","),o={};for(t=0;t<r.length;)n=r[t].trim(),o[n]?r.splice(t,1):(o[n]=!0,r[t]=n,t++);return r.join(",")}function Z(e){var t=e.bucket,n=t.substr(0,t.lastIndexOf("-")),r=t.substr(t.lastIndexOf("-")+1),o=e.domain,i=e.region,a=e.object;o||(o=["cn-south","cn-south-2","cn-north","cn-east","cn-southwest","sg"].indexOf(i)>-1?"{Region}.myqcloud.com":"cos.{Region}.myqcloud.com",e.ForcePathStyle||(o="{Bucket}."+o)),o=o.replace(/\{\{AppId\}\}/gi,r).replace(/\{\{Bucket\}\}/gi,n).replace(/\{\{Region\}\}/gi,i).replace(/\{\{.*?\}\}/gi,""),o=o.replace(/\{AppId\}/gi,r).replace(/\{BucketName\}/gi,n).replace(/\{Bucket\}/gi,t).replace(/\{Region\}/gi,i).replace(/\{.*?\}/gi,""),/^[a-zA-Z]+:\/\//.test(o)||(o="https://"+o),"/"===o.slice(-1)&&(o=o.slice(0,-1));var s=o;return e.ForcePathStyle&&(s+="/"+t),s+="/",a&&(s+=re.camSafeUrlEncode(a).replace(/%2F/g,"/")),e.isLocation&&(s=s.replace(/^https?:\/\//,"")),s}function Y(e,t){var n=re.clone(e.Headers);delete n["Content-Type"],delete n["Cache-Control"],re.each(n,function(e,t){""===e&&delete n[t]});var r=function(e){var n=!1,r=e.Authorization;if(r)if(r.indexOf(" ")>-1)n=!1;else if(r.indexOf("q-sign-algorithm=")>-1&&r.indexOf("q-ak=")>-1&&r.indexOf("q-sign-time=")>-1&&r.indexOf("q-key-time=")>-1&&r.indexOf("q-url-param-list=")>-1)n=!0;else try{r=atob(r),r.indexOf("a=")>-1&&r.indexOf("k=")>-1&&r.indexOf("t=")>-1&&r.indexOf("r=")>-1&&r.indexOf("b=")>-1&&(n=!0)}catch(e){}n?t&&t(null,e):t&&t("authorization error")},o=this,i=e.Bucket||"",a=e.Region||"",s="name/cos:PostObject"!==e.Action&&e.Key?e.Key:"";o.options.ForcePathStyle&&i&&(s=i+"/"+s);var c="/"+s,u={},l=e.Scope;if(!l){var d=e.Action||"",f=e.ResourceKey||e.Key||"";l=e.Scope||[{action:d,bucket:i,region:a,prefix:f}]}var h=re.md5(JSON.stringify(l));o._StsCache=o._StsCache||[],function(){var e,t;for(e=o._StsCache.length-1;e>=0;e--){t=o._StsCache[e];var n=Math.round(re.getSkewTime(o.options.SystemClockOffset)/1e3)+30;if(t.StartTime&&n<t.StartTime||n>=t.ExpiredTime)o._StsCache.splice(e,1);else if(!t.ScopeLimit||t.ScopeLimit&&t.ScopeKey===h){u=t;break}}}();var p=function(){var t=re.getAuth({SecretId:u.TmpSecretId,SecretKey:u.TmpSecretKey,Method:e.Method,Pathname:c,Query:e.Query,Headers:n,Expires:e.Expires,SystemClockOffset:o.options.SystemClockOffset}),i={Authorization:t,XCosSecurityToken:u.XCosSecurityToken||"",Token:u.Token||"",ClientIP:u.ClientIP||"",ClientUA:u.ClientUA||""};r(i)};if(u.ExpiredTime&&u.ExpiredTime-re.getSkewTime(o.options.SystemClockOffset)/1e3>60)p();else if(o.options.getAuthorization)o.options.getAuthorization.call(o,{Bucket:i,Region:a,Method:e.Method,Key:s,Pathname:c,Query:e.Query,Headers:n,Scope:l},function(e){"string"==typeof e&&(e={Authorization:e}),e.TmpSecretId&&e.TmpSecretKey&&e.XCosSecurityToken&&e.ExpiredTime?(u=e||{},u.Scope=l,u.ScopeKey=h,o._StsCache.push(u),p()):r(e)});else{if(!o.options.getSTS)return function(){var t=re.getAuth({SecretId:e.SecretId||o.options.SecretId,SecretKey:e.SecretKey||o.options.SecretKey,Method:e.Method,Pathname:c,Query:e.Query,Headers:n,Expires:e.Expires,SystemClockOffset:o.options.SystemClockOffset}),i={Authorization:t,XCosSecurityToken:o.options.XCosSecurityToken};return r(i),i}();o.options.getSTS.call(o,{Bucket:i,Region:a},function(e){u=e||{},u.Scope=l,u.ScopeKey=h,u.TmpSecretId=u.SecretId,u.TmpSecretKey=u.SecretKey,o._StsCache.push(u),p()})}return""}function J(e){var t=!1,n=!1,r=e.headers&&(e.headers.date||e.headers.Date)||"";try{var o=e.error.Code,i=e.error.Message;("RequestTimeTooSkewed"===o||"AccessDenied"===o&&"Request has expired"===i)&&(n=!0)}catch(e){}if(e)if(n&&r){var a=Date.parse(r);this.options.CorrectClockSkew&&Math.abs(re.getSkewTime(this.options.SystemClockOffset)-a)>=3e4&&(console.error("error: Local time is too skewed."),this.options.SystemClockOffset=a-Date.now(),t=!0)}else 5===Math.round(e.statusCode/100)&&(t=!0);return t}function ee(e,t){var n=this;!e.headers&&(e.headers={}),!e.qs&&(e.qs={}),e.VersionId&&(e.qs.versionId=e.VersionId),e.qs=re.clearKey(e.qs),e.headers&&(e.headers=re.clearKey(e.headers)),e.qs&&(e.qs=re.clearKey(e.qs));var r=re.clone(e.qs);e.action&&(r[e.action]="");var o=function(i){var a=n.options.SystemClockOffset;Y.call(n,{Bucket:e.Bucket||"",Region:e.Region||"",Method:e.method,Key:e.Key,Query:r,Headers:e.headers,Action:e.Action,ResourceKey:e.ResourceKey,Scope:e.Scope},function(r,s){e.AuthData=s,te.call(n,e,function(r,s){r&&i<2&&(a!==n.options.SystemClockOffset||J.call(n,r))?(e.headers&&(delete e.headers.Authorization,delete e.headers.token,delete e.headers.clientIP,delete e.headers.clientUA,delete e.headers["x-cos-security-token"]),o(i+1)):t(r,s)})})};o(0)}function te(e,t){var n=this,r=e.TaskId;if(!r||n._isRunningTask(r)){var o=e.Bucket,i=e.Region,a=e.Key,s=e.method||"GET",c=e.url,u=e.body,l=e.json,d=e.rawBody;c=c||Z({ForcePathStyle:n.options.ForcePathStyle,protocol:n.options.Protocol,domain:n.options.Domain,bucket:o,region:i,object:a}),e.action&&(c=c+"?"+e.action);var f={method:s,url:c,headers:e.headers,qs:e.qs,filePath:e.filePath,body:u,json:l};f.headers.Authorization=e.AuthData.Authorization,e.AuthData.Token&&(f.headers.token=e.AuthData.Token),e.AuthData.ClientIP&&(f.headers.clientIP=e.AuthData.ClientIP),e.AuthData.ClientUA&&(f.headers.clientUA=e.AuthData.ClientUA),e.AuthData.XCosSecurityToken&&(f.headers["x-cos-security-token"]=e.AuthData.XCosSecurityToken),f.headers&&(f.headers=re.clearKey(f.headers)),f=re.clearKey(f),e.onProgress&&"function"==typeof e.onProgress&&(f.onProgress=function(t){if(!r||n._isRunningTask(r)){var o=t?t.loaded:0;e.onProgress({loaded:o,total:t.total})}}),n.options.ForcePathStyle&&(f.pathStyle=n.options.ForcePathStyle);var h=ne(f,function(e,o,i){var a,s=function(e,i){if(r&&n.off("inner-kill-task",p),!a){a=!0;var s={};o&&o.statusCode&&(s.statusCode=o.statusCode),o&&o.headers&&(s.headers=o.headers),e?(e=re.extend(e||{},s),t(e,null)):(i=re.extend(i||{},s),t(null,i))}};if(e)return void s({error:e});var c;try{c=re.xml2json(i)||{}}catch(e){c=i||{}}var u=o.statusCode;return 2!==Math.floor(u/100)?void s({error:c.Error||c}):(d&&(c={},c.body=i),c.Error?void s({error:c.Error}):void s(null,c))}),p=function(e){e.TaskId===r&&(h&&h.abort&&h.abort(),n.off("inner-kill-task",p))};r&&n.on("inner-kill-task",p)}}var ne=n(9),re=n(0),oe={getService:r,putBucket:a,getBucket:i,headBucket:o,deleteBucket:s,getBucketAcl:c,putBucketAcl:u,getBucketCors:l,putBucketCors:d,deleteBucketCors:f,getBucketLocation:m,putBucketTagging:C,getBucketTagging:y,deleteBucketTagging:v,getBucketPolicy:g,putBucketPolicy:h,deleteBucketPolicy:p,getBucketLifecycle:k,putBucketLifecycle:x,deleteBucketLifecycle:S,putBucketVersioning:A,getBucketVersioning:b,putBucketReplication:R,getBucketReplication:T,deleteBucketReplication:w,getObject:N,headObject:E,listObjectVersions:_,putObject:B,postObject:D,deleteObject:O,getObjectAcl:P,putObjectAcl:I,optionsObject:M,putObjectCopy:L,deleteMultipleObject:U,restoreObject:j,uploadPartCopy:F,multipartInit:K,multipartUpload:H,multipartComplete:z,multipartList:G,multipartListPart:q,multipartAbort:V,getObjectUrl:$,getAuth:X};e.exports.init=function(e,t){t.transferToTaskMethod(oe,"postObject"),re.each(oe,function(t,n){e.prototype[n]=re.apiWrapper(n,t)})}},function(e,t,n){var r=n(0),o={},i=function(e,t){o[t]=e[t],e[t]=function(e,n){e.SkipTask?o[t].call(this,e,n):this._addTask(t,e,n)}},a=function(e){var t=[],n={},i=0,a=0,s=function(e){var t={id:e.id,Bucket:e.Bucket,Region:e.Region,Key:e.Key,FilePath:e.FilePath,state:e.state,loaded:e.loaded,size:e.size,speed:e.speed,percent:e.percent,hashPercent:e.hashPercent,error:e.error};return e.FilePath&&(t.FilePath=e.FilePath),t},c=function(){e.emit("list-update",{list:r.map(t,s)})},u=function(){if(t.length>e.options.UploadQueueSize){var n;for(n=0;n<t.length&&t.length>e.options.UploadQueueSize&&n<a;n++)t[n]&&"waiting"===t[n].state||(t.splice(n,1),a--)}},l=function(){if(a<t.length&&i<e.options.FileParallelLimit){var n=t[a];if("waiting"===n.state){i++,n.state="checking";var s=r.formatParams(n.api,n.params);o[n.api].call(e,s,function(t,r){e._isRunningTask(n.id)&&("checking"!==n.state&&"uploading"!==n.state||(n.state=t?"error":"success",t&&(n.error=t),i--,c(),l(e),n.callback&&n.callback(t,r),"success"===n.state&&(n.params&&(delete n.params.Body,delete n.params),delete n.callback)),u())}),c()}a++,l(e)}},d=function(t,r){var o=n[t];if(o){var a=o&&"waiting"===o.state,s=o&&("checking"===o.state||"uploading"===o.state);if("canceled"===r&&"canceled"!==o.state||"paused"===r&&a||"paused"===r&&s){if("paused"===r&&o.params.Body&&"function"==typeof o.params.Body.pipe)return void console.error("stream not support pause");o.state=r,e.emit("inner-kill-task",{TaskId:t,toState:r}),c(),s&&(i--,l(e)),"canceled"===r&&(o.params&&(delete o.params.Body,delete o.params),delete o.callback)}u()}};e._addTasks=function(t){r.each(t,function(t){e._addTask(t.api,t.params,t.callback,!0)}),c()},e._addTask=function(o,i,a,s){i=r.formatParams(o,i);var d=r.uuid();i.TaskId=d,i.TaskReady&&i.TaskReady(d);var f={params:i,callback:a,api:o,index:t.length,id:d,Bucket:i.Bucket,Region:i.Region,Key:i.Key,FilePath:i.FilePath||"",state:"waiting",loaded:0,size:0,speed:0,percent:0,hashPercent:0,error:null},h=i.onHashProgress;i.onHashProgress=function(t){e._isRunningTask(f.id)&&(f.hashPercent=t.percent,h&&h(t),c())};var p=i.onProgress;return i.onProgress=function(t){e._isRunningTask(f.id)&&("checking"===f.state&&(f.state="uploading"),f.loaded=t.loaded,f.size=t.total,f.speed=t.speed,f.percent=t.percent,p&&p(t),c())},function(){n[d]=f,t.push(f),f.size=i.FileSize,!s&&c(),l(e),u()}(),d},e._isRunningTask=function(e){var t=n[e];return!(!t||"checking"!==t.state&&"uploading"!==t.state)},e.getTaskList=function(){return r.map(t,s)},e.cancelTask=function(e){d(e,"canceled")},e.pauseTask=function(e){d(e,"paused")},e.restartTask=function(e){var t=n[e];!t||"paused"!==t.state&&"error"!==t.state||(t.state="waiting",c(),a=Math.min(a,t.index),l())}};e.exports.transferToTaskMethod=i,e.exports.init=a}])});

/***/ }),
/* 75 */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* WEBPACK VAR INJECTION */(function(global) {/*eslint-disable*/
var e="undefined"!=typeof global?global:"undefined"!=typeof self?self:"undefined"!=typeof window?window:{},t=[],r=[],n="undefined"!=typeof Uint8Array?Uint8Array:Array,i=!1;function o(){i=!0;for(var e="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/",n=0,o=e.length;n<o;++n)t[n]=e[n],r[e.charCodeAt(n)]=n;r["-".charCodeAt(0)]=62,r["_".charCodeAt(0)]=63}function a(e,r,n){for(var i,o,a=[],s=r;s<n;s+=3)i=(e[s]<<16)+(e[s+1]<<8)+e[s+2],a.push(t[(o=i)>>18&63]+t[o>>12&63]+t[o>>6&63]+t[63&o]);return a.join("")}function s(e){var r;i||o();for(var n=e.length,s=n%3,h="",l=[],f=0,c=n-s;f<c;f+=16383)l.push(a(e,f,f+16383>c?c:f+16383));return 1===s?(r=e[n-1],h+=t[r>>2],h+=t[r<<4&63],h+="=="):2===s&&(r=(e[n-2]<<8)+e[n-1],h+=t[r>>10],h+=t[r>>4&63],h+=t[r<<2&63],h+="="),l.push(h),l.join("")}function h(e,t,r,n,i){var o,a,s=8*i-n-1,h=(1<<s)-1,l=h>>1,f=-7,c=r?i-1:0,u=r?-1:1,d=e[t+c];for(c+=u,o=d&(1<<-f)-1,d>>=-f,f+=s;f>0;o=256*o+e[t+c],c+=u,f-=8);for(a=o&(1<<-f)-1,o>>=-f,f+=n;f>0;a=256*a+e[t+c],c+=u,f-=8);if(0===o)o=1-l;else{if(o===h)return a?NaN:1/0*(d?-1:1);a+=Math.pow(2,n),o-=l}return(d?-1:1)*a*Math.pow(2,o-n)}function l(e,t,r,n,i,o){var a,s,h,l=8*o-i-1,f=(1<<l)-1,c=f>>1,u=23===i?Math.pow(2,-24)-Math.pow(2,-77):0,d=n?0:o-1,p=n?1:-1,_=t<0||0===t&&1/t<0?1:0;for(t=Math.abs(t),isNaN(t)||t===1/0?(s=isNaN(t)?1:0,a=f):(a=Math.floor(Math.log(t)/Math.LN2),t*(h=Math.pow(2,-a))<1&&(a--,h*=2),(t+=a+c>=1?u/h:u*Math.pow(2,1-c))*h>=2&&(a++,h/=2),a+c>=f?(s=0,a=f):a+c>=1?(s=(t*h-1)*Math.pow(2,i),a+=c):(s=t*Math.pow(2,c-1)*Math.pow(2,i),a=0));i>=8;e[r+d]=255&s,d+=p,s/=256,i-=8);for(a=a<<i|s,l+=i;l>0;e[r+d]=255&a,d+=p,a/=256,l-=8);e[r+d-p]|=128*_}var f={}.toString,c=Array.isArray||function(e){return"[object Array]"==f.call(e)};function u(){return p.TYPED_ARRAY_SUPPORT?2147483647:1073741823}function d(e,t){if(u()<t)throw new RangeError("Invalid typed array length");return p.TYPED_ARRAY_SUPPORT?(e=new Uint8Array(t)).__proto__=p.prototype:(null===e&&(e=new p(t)),e.length=t),e}function p(e,t,r){if(!(p.TYPED_ARRAY_SUPPORT||this instanceof p))return new p(e,t,r);if("number"==typeof e){if("string"==typeof t)throw new Error("If encoding is specified then the first argument must be a string");return v(this,e)}return _(this,e,t,r)}function _(e,t,r,n){if("number"==typeof t)throw new TypeError('"value" argument must not be a number');return"undefined"!=typeof ArrayBuffer&&t instanceof ArrayBuffer?function(e,t,r,n){if(t.byteLength,r<0||t.byteLength<r)throw new RangeError("'offset' is out of bounds");if(t.byteLength<r+(n||0))throw new RangeError("'length' is out of bounds");t=void 0===r&&void 0===n?new Uint8Array(t):void 0===n?new Uint8Array(t,r):new Uint8Array(t,r,n);p.TYPED_ARRAY_SUPPORT?(e=t).__proto__=p.prototype:e=w(e,t);return e}(e,t,r,n):"string"==typeof t?function(e,t,r){"string"==typeof r&&""!==r||(r="utf8");if(!p.isEncoding(r))throw new TypeError('"encoding" must be a valid string encoding');var n=0|m(t,r),i=(e=d(e,n)).write(t,r);i!==n&&(e=e.slice(0,i));return e}(e,t,r):function(e,t){if(y(t)){var r=0|b(t.length);return 0===(e=d(e,r)).length?e:(t.copy(e,0,0,r),e)}if(t){if("undefined"!=typeof ArrayBuffer&&t.buffer instanceof ArrayBuffer||"length"in t)return"number"!=typeof t.length||(n=t.length)!=n?d(e,0):w(e,t);if("Buffer"===t.type&&c(t.data))return w(e,t.data)}var n;throw new TypeError("First argument must be a string, Buffer, ArrayBuffer, Array, or array-like object.")}(e,t)}function g(e){if("number"!=typeof e)throw new TypeError('"size" argument must be a number');if(e<0)throw new RangeError('"size" argument must not be negative')}function v(e,t){if(g(t),e=d(e,t<0?0:0|b(t)),!p.TYPED_ARRAY_SUPPORT)for(var r=0;r<t;++r)e[r]=0;return e}function w(e,t){var r=t.length<0?0:0|b(t.length);e=d(e,r);for(var n=0;n<r;n+=1)e[n]=255&t[n];return e}function b(e){if(e>=u())throw new RangeError("Attempt to allocate Buffer larger than maximum size: 0x"+u().toString(16)+" bytes");return 0|e}function y(e){return!(null==e||!e._isBuffer)}function m(e,t){if(y(e))return e.length;if("undefined"!=typeof ArrayBuffer&&"function"==typeof ArrayBuffer.isView&&(ArrayBuffer.isView(e)||e instanceof ArrayBuffer))return e.byteLength;"string"!=typeof e&&(e=""+e);var r=e.length;if(0===r)return 0;for(var n=!1;;)switch(t){case"ascii":case"latin1":case"binary":return r;case"utf8":case"utf-8":case void 0:return q(e).length;case"ucs2":case"ucs-2":case"utf16le":case"utf-16le":return 2*r;case"hex":return r>>>1;case"base64":return V(e).length;default:if(n)return q(e).length;t=(""+t).toLowerCase(),n=!0}}function k(e,t,r){var n=!1;if((void 0===t||t<0)&&(t=0),t>this.length)return"";if((void 0===r||r>this.length)&&(r=this.length),r<=0)return"";if((r>>>=0)<=(t>>>=0))return"";for(e||(e="utf8");;)switch(e){case"hex":return O(this,t,r);case"utf8":case"utf-8":return C(this,t,r);case"ascii":return I(this,t,r);case"latin1":case"binary":return P(this,t,r);case"base64":return M(this,t,r);case"ucs2":case"ucs-2":case"utf16le":case"utf-16le":return U(this,t,r);default:if(n)throw new TypeError("Unknown encoding: "+e);e=(e+"").toLowerCase(),n=!0}}function E(e,t,r){var n=e[t];e[t]=e[r],e[r]=n}function S(e,t,r,n,i){if(0===e.length)return-1;if("string"==typeof r?(n=r,r=0):r>2147483647?r=2147483647:r<-2147483648&&(r=-2147483648),r=+r,isNaN(r)&&(r=i?0:e.length-1),r<0&&(r=e.length+r),r>=e.length){if(i)return-1;r=e.length-1}else if(r<0){if(!i)return-1;r=0}if("string"==typeof t&&(t=p.from(t,n)),y(t))return 0===t.length?-1:x(e,t,r,n,i);if("number"==typeof t)return t&=255,p.TYPED_ARRAY_SUPPORT&&"function"==typeof Uint8Array.prototype.indexOf?i?Uint8Array.prototype.indexOf.call(e,t,r):Uint8Array.prototype.lastIndexOf.call(e,t,r):x(e,[t],r,n,i);throw new TypeError("val must be string, number or Buffer")}function x(e,t,r,n,i){var o,a=1,s=e.length,h=t.length;if(void 0!==n&&("ucs2"===(n=String(n).toLowerCase())||"ucs-2"===n||"utf16le"===n||"utf-16le"===n)){if(e.length<2||t.length<2)return-1;a=2,s/=2,h/=2,r/=2}function l(e,t){return 1===a?e[t]:e.readUInt16BE(t*a)}if(i){var f=-1;for(o=r;o<s;o++)if(l(e,o)===l(t,-1===f?0:o-f)){if(-1===f&&(f=o),o-f+1===h)return f*a}else-1!==f&&(o-=o-f),f=-1}else for(r+h>s&&(r=s-h),o=r;o>=0;o--){for(var c=!0,u=0;u<h;u++)if(l(e,o+u)!==l(t,u)){c=!1;break}if(c)return o}return-1}function R(e,t,r,n){r=Number(r)||0;var i=e.length-r;n?(n=Number(n))>i&&(n=i):n=i;var o=t.length;if(o%2!=0)throw new TypeError("Invalid hex string");n>o/2&&(n=o/2);for(var a=0;a<n;++a){var s=parseInt(t.substr(2*a,2),16);if(isNaN(s))return a;e[r+a]=s}return a}function A(e,t,r,n){return G(q(t,e.length-r),e,r,n)}function B(e,t,r,n){return G(function(e){for(var t=[],r=0;r<e.length;++r)t.push(255&e.charCodeAt(r));return t}(t),e,r,n)}function z(e,t,r,n){return B(e,t,r,n)}function L(e,t,r,n){return G(V(t),e,r,n)}function T(e,t,r,n){return G(function(e,t){for(var r,n,i,o=[],a=0;a<e.length&&!((t-=2)<0);++a)r=e.charCodeAt(a),n=r>>8,i=r%256,o.push(i),o.push(n);return o}(t,e.length-r),e,r,n)}function M(e,t,r){return 0===t&&r===e.length?s(e):s(e.slice(t,r))}function C(e,t,r){r=Math.min(e.length,r);for(var n=[],i=t;i<r;){var o,a,s,h,l=e[i],f=null,c=l>239?4:l>223?3:l>191?2:1;if(i+c<=r)switch(c){case 1:l<128&&(f=l);break;case 2:128==(192&(o=e[i+1]))&&(h=(31&l)<<6|63&o)>127&&(f=h);break;case 3:o=e[i+1],a=e[i+2],128==(192&o)&&128==(192&a)&&(h=(15&l)<<12|(63&o)<<6|63&a)>2047&&(h<55296||h>57343)&&(f=h);break;case 4:o=e[i+1],a=e[i+2],s=e[i+3],128==(192&o)&&128==(192&a)&&128==(192&s)&&(h=(15&l)<<18|(63&o)<<12|(63&a)<<6|63&s)>65535&&h<1114112&&(f=h)}null===f?(f=65533,c=1):f>65535&&(f-=65536,n.push(f>>>10&1023|55296),f=56320|1023&f),n.push(f),i+=c}return function(e){var t=e.length;if(t<=D)return String.fromCharCode.apply(String,e);var r="",n=0;for(;n<t;)r+=String.fromCharCode.apply(String,e.slice(n,n+=D));return r}(n)}p.TYPED_ARRAY_SUPPORT=void 0===e.TYPED_ARRAY_SUPPORT||e.TYPED_ARRAY_SUPPORT,p.poolSize=8192,p._augment=function(e){return e.__proto__=p.prototype,e},p.from=function(e,t,r){return _(null,e,t,r)},p.TYPED_ARRAY_SUPPORT&&(p.prototype.__proto__=Uint8Array.prototype,p.__proto__=Uint8Array),p.alloc=function(e,t,r){return function(e,t,r,n){return g(t),t<=0?d(e,t):void 0!==r?"string"==typeof n?d(e,t).fill(r,n):d(e,t).fill(r):d(e,t)}(null,e,t,r)},p.allocUnsafe=function(e){return v(null,e)},p.allocUnsafeSlow=function(e){return v(null,e)},p.isBuffer=$,p.compare=function(e,t){if(!y(e)||!y(t))throw new TypeError("Arguments must be Buffers");if(e===t)return 0;for(var r=e.length,n=t.length,i=0,o=Math.min(r,n);i<o;++i)if(e[i]!==t[i]){r=e[i],n=t[i];break}return r<n?-1:n<r?1:0},p.isEncoding=function(e){switch(String(e).toLowerCase()){case"hex":case"utf8":case"utf-8":case"ascii":case"latin1":case"binary":case"base64":case"ucs2":case"ucs-2":case"utf16le":case"utf-16le":return!0;default:return!1}},p.concat=function(e,t){if(!c(e))throw new TypeError('"list" argument must be an Array of Buffers');if(0===e.length)return p.alloc(0);var r;if(void 0===t)for(t=0,r=0;r<e.length;++r)t+=e[r].length;var n=p.allocUnsafe(t),i=0;for(r=0;r<e.length;++r){var o=e[r];if(!y(o))throw new TypeError('"list" argument must be an Array of Buffers');o.copy(n,i),i+=o.length}return n},p.byteLength=m,p.prototype._isBuffer=!0,p.prototype.swap16=function(){var e=this.length;if(e%2!=0)throw new RangeError("Buffer size must be a multiple of 16-bits");for(var t=0;t<e;t+=2)E(this,t,t+1);return this},p.prototype.swap32=function(){var e=this.length;if(e%4!=0)throw new RangeError("Buffer size must be a multiple of 32-bits");for(var t=0;t<e;t+=4)E(this,t,t+3),E(this,t+1,t+2);return this},p.prototype.swap64=function(){var e=this.length;if(e%8!=0)throw new RangeError("Buffer size must be a multiple of 64-bits");for(var t=0;t<e;t+=8)E(this,t,t+7),E(this,t+1,t+6),E(this,t+2,t+5),E(this,t+3,t+4);return this},p.prototype.toString=function(){var e=0|this.length;return 0===e?"":0===arguments.length?C(this,0,e):k.apply(this,arguments)},p.prototype.equals=function(e){if(!y(e))throw new TypeError("Argument must be a Buffer");return this===e||0===p.compare(this,e)},p.prototype.inspect=function(){var e="";return this.length>0&&(e=this.toString("hex",0,50).match(/.{2}/g).join(" "),this.length>50&&(e+=" ... ")),"<Buffer "+e+">"},p.prototype.compare=function(e,t,r,n,i){if(!y(e))throw new TypeError("Argument must be a Buffer");if(void 0===t&&(t=0),void 0===r&&(r=e?e.length:0),void 0===n&&(n=0),void 0===i&&(i=this.length),t<0||r>e.length||n<0||i>this.length)throw new RangeError("out of range index");if(n>=i&&t>=r)return 0;if(n>=i)return-1;if(t>=r)return 1;if(this===e)return 0;for(var o=(i>>>=0)-(n>>>=0),a=(r>>>=0)-(t>>>=0),s=Math.min(o,a),h=this.slice(n,i),l=e.slice(t,r),f=0;f<s;++f)if(h[f]!==l[f]){o=h[f],a=l[f];break}return o<a?-1:a<o?1:0},p.prototype.includes=function(e,t,r){return-1!==this.indexOf(e,t,r)},p.prototype.indexOf=function(e,t,r){return S(this,e,t,r,!0)},p.prototype.lastIndexOf=function(e,t,r){return S(this,e,t,r,!1)},p.prototype.write=function(e,t,r,n){if(void 0===t)n="utf8",r=this.length,t=0;else if(void 0===r&&"string"==typeof t)n=t,r=this.length,t=0;else{if(!isFinite(t))throw new Error("Buffer.write(string, encoding, offset[, length]) is no longer supported");t|=0,isFinite(r)?(r|=0,void 0===n&&(n="utf8")):(n=r,r=void 0)}var i=this.length-t;if((void 0===r||r>i)&&(r=i),e.length>0&&(r<0||t<0)||t>this.length)throw new RangeError("Attempt to write outside buffer bounds");n||(n="utf8");for(var o=!1;;)switch(n){case"hex":return R(this,e,t,r);case"utf8":case"utf-8":return A(this,e,t,r);case"ascii":return B(this,e,t,r);case"latin1":case"binary":return z(this,e,t,r);case"base64":return L(this,e,t,r);case"ucs2":case"ucs-2":case"utf16le":case"utf-16le":return T(this,e,t,r);default:if(o)throw new TypeError("Unknown encoding: "+n);n=(""+n).toLowerCase(),o=!0}},p.prototype.toJSON=function(){return{type:"Buffer",data:Array.prototype.slice.call(this._arr||this,0)}};var D=4096;function I(e,t,r){var n="";r=Math.min(e.length,r);for(var i=t;i<r;++i)n+=String.fromCharCode(127&e[i]);return n}function P(e,t,r){var n="";r=Math.min(e.length,r);for(var i=t;i<r;++i)n+=String.fromCharCode(e[i]);return n}function O(e,t,r){var n=e.length;(!t||t<0)&&(t=0),(!r||r<0||r>n)&&(r=n);for(var i="",o=t;o<r;++o)i+=X(e[o]);return i}function U(e,t,r){for(var n=e.slice(t,r),i="",o=0;o<n.length;o+=2)i+=String.fromCharCode(n[o]+256*n[o+1]);return i}function H(e,t,r){if(e%1!=0||e<0)throw new RangeError("offset is not uint");if(e+t>r)throw new RangeError("Trying to access beyond buffer length")}function F(e,t,r,n,i,o){if(!y(e))throw new TypeError('"buffer" argument must be a Buffer instance');if(t>i||t<o)throw new RangeError('"value" argument is out of bounds');if(r+n>e.length)throw new RangeError("Index out of range")}function N(e,t,r,n){t<0&&(t=65535+t+1);for(var i=0,o=Math.min(e.length-r,2);i<o;++i)e[r+i]=(t&255<<8*(n?i:1-i))>>>8*(n?i:1-i)}function Z(e,t,r,n){t<0&&(t=4294967295+t+1);for(var i=0,o=Math.min(e.length-r,4);i<o;++i)e[r+i]=t>>>8*(n?i:3-i)&255}function j(e,t,r,n,i,o){if(r+n>e.length)throw new RangeError("Index out of range");if(r<0)throw new RangeError("Index out of range")}function W(e,t,r,n,i){return i||j(e,0,r,4),l(e,t,r,n,23,4),r+4}function Y(e,t,r,n,i){return i||j(e,0,r,8),l(e,t,r,n,52,8),r+8}p.prototype.slice=function(e,t){var r,n=this.length;if((e=~~e)<0?(e+=n)<0&&(e=0):e>n&&(e=n),(t=void 0===t?n:~~t)<0?(t+=n)<0&&(t=0):t>n&&(t=n),t<e&&(t=e),p.TYPED_ARRAY_SUPPORT)(r=this.subarray(e,t)).__proto__=p.prototype;else{var i=t-e;r=new p(i,void 0);for(var o=0;o<i;++o)r[o]=this[o+e]}return r},p.prototype.readUIntLE=function(e,t,r){e|=0,t|=0,r||H(e,t,this.length);for(var n=this[e],i=1,o=0;++o<t&&(i*=256);)n+=this[e+o]*i;return n},p.prototype.readUIntBE=function(e,t,r){e|=0,t|=0,r||H(e,t,this.length);for(var n=this[e+--t],i=1;t>0&&(i*=256);)n+=this[e+--t]*i;return n},p.prototype.readUInt8=function(e,t){return t||H(e,1,this.length),this[e]},p.prototype.readUInt16LE=function(e,t){return t||H(e,2,this.length),this[e]|this[e+1]<<8},p.prototype.readUInt16BE=function(e,t){return t||H(e,2,this.length),this[e]<<8|this[e+1]},p.prototype.readUInt32LE=function(e,t){return t||H(e,4,this.length),(this[e]|this[e+1]<<8|this[e+2]<<16)+16777216*this[e+3]},p.prototype.readUInt32BE=function(e,t){return t||H(e,4,this.length),16777216*this[e]+(this[e+1]<<16|this[e+2]<<8|this[e+3])},p.prototype.readIntLE=function(e,t,r){e|=0,t|=0,r||H(e,t,this.length);for(var n=this[e],i=1,o=0;++o<t&&(i*=256);)n+=this[e+o]*i;return n>=(i*=128)&&(n-=Math.pow(2,8*t)),n},p.prototype.readIntBE=function(e,t,r){e|=0,t|=0,r||H(e,t,this.length);for(var n=t,i=1,o=this[e+--n];n>0&&(i*=256);)o+=this[e+--n]*i;return o>=(i*=128)&&(o-=Math.pow(2,8*t)),o},p.prototype.readInt8=function(e,t){return t||H(e,1,this.length),128&this[e]?-1*(255-this[e]+1):this[e]},p.prototype.readInt16LE=function(e,t){t||H(e,2,this.length);var r=this[e]|this[e+1]<<8;return 32768&r?4294901760|r:r},p.prototype.readInt16BE=function(e,t){t||H(e,2,this.length);var r=this[e+1]|this[e]<<8;return 32768&r?4294901760|r:r},p.prototype.readInt32LE=function(e,t){return t||H(e,4,this.length),this[e]|this[e+1]<<8|this[e+2]<<16|this[e+3]<<24},p.prototype.readInt32BE=function(e,t){return t||H(e,4,this.length),this[e]<<24|this[e+1]<<16|this[e+2]<<8|this[e+3]},p.prototype.readFloatLE=function(e,t){return t||H(e,4,this.length),h(this,e,!0,23,4)},p.prototype.readFloatBE=function(e,t){return t||H(e,4,this.length),h(this,e,!1,23,4)},p.prototype.readDoubleLE=function(e,t){return t||H(e,8,this.length),h(this,e,!0,52,8)},p.prototype.readDoubleBE=function(e,t){return t||H(e,8,this.length),h(this,e,!1,52,8)},p.prototype.writeUIntLE=function(e,t,r,n){(e=+e,t|=0,r|=0,n)||F(this,e,t,r,Math.pow(2,8*r)-1,0);var i=1,o=0;for(this[t]=255&e;++o<r&&(i*=256);)this[t+o]=e/i&255;return t+r},p.prototype.writeUIntBE=function(e,t,r,n){(e=+e,t|=0,r|=0,n)||F(this,e,t,r,Math.pow(2,8*r)-1,0);var i=r-1,o=1;for(this[t+i]=255&e;--i>=0&&(o*=256);)this[t+i]=e/o&255;return t+r},p.prototype.writeUInt8=function(e,t,r){return e=+e,t|=0,r||F(this,e,t,1,255,0),p.TYPED_ARRAY_SUPPORT||(e=Math.floor(e)),this[t]=255&e,t+1},p.prototype.writeUInt16LE=function(e,t,r){return e=+e,t|=0,r||F(this,e,t,2,65535,0),p.TYPED_ARRAY_SUPPORT?(this[t]=255&e,this[t+1]=e>>>8):N(this,e,t,!0),t+2},p.prototype.writeUInt16BE=function(e,t,r){return e=+e,t|=0,r||F(this,e,t,2,65535,0),p.TYPED_ARRAY_SUPPORT?(this[t]=e>>>8,this[t+1]=255&e):N(this,e,t,!1),t+2},p.prototype.writeUInt32LE=function(e,t,r){return e=+e,t|=0,r||F(this,e,t,4,4294967295,0),p.TYPED_ARRAY_SUPPORT?(this[t+3]=e>>>24,this[t+2]=e>>>16,this[t+1]=e>>>8,this[t]=255&e):Z(this,e,t,!0),t+4},p.prototype.writeUInt32BE=function(e,t,r){return e=+e,t|=0,r||F(this,e,t,4,4294967295,0),p.TYPED_ARRAY_SUPPORT?(this[t]=e>>>24,this[t+1]=e>>>16,this[t+2]=e>>>8,this[t+3]=255&e):Z(this,e,t,!1),t+4},p.prototype.writeIntLE=function(e,t,r,n){if(e=+e,t|=0,!n){var i=Math.pow(2,8*r-1);F(this,e,t,r,i-1,-i)}var o=0,a=1,s=0;for(this[t]=255&e;++o<r&&(a*=256);)e<0&&0===s&&0!==this[t+o-1]&&(s=1),this[t+o]=(e/a>>0)-s&255;return t+r},p.prototype.writeIntBE=function(e,t,r,n){if(e=+e,t|=0,!n){var i=Math.pow(2,8*r-1);F(this,e,t,r,i-1,-i)}var o=r-1,a=1,s=0;for(this[t+o]=255&e;--o>=0&&(a*=256);)e<0&&0===s&&0!==this[t+o+1]&&(s=1),this[t+o]=(e/a>>0)-s&255;return t+r},p.prototype.writeInt8=function(e,t,r){return e=+e,t|=0,r||F(this,e,t,1,127,-128),p.TYPED_ARRAY_SUPPORT||(e=Math.floor(e)),e<0&&(e=255+e+1),this[t]=255&e,t+1},p.prototype.writeInt16LE=function(e,t,r){return e=+e,t|=0,r||F(this,e,t,2,32767,-32768),p.TYPED_ARRAY_SUPPORT?(this[t]=255&e,this[t+1]=e>>>8):N(this,e,t,!0),t+2},p.prototype.writeInt16BE=function(e,t,r){return e=+e,t|=0,r||F(this,e,t,2,32767,-32768),p.TYPED_ARRAY_SUPPORT?(this[t]=e>>>8,this[t+1]=255&e):N(this,e,t,!1),t+2},p.prototype.writeInt32LE=function(e,t,r){return e=+e,t|=0,r||F(this,e,t,4,2147483647,-2147483648),p.TYPED_ARRAY_SUPPORT?(this[t]=255&e,this[t+1]=e>>>8,this[t+2]=e>>>16,this[t+3]=e>>>24):Z(this,e,t,!0),t+4},p.prototype.writeInt32BE=function(e,t,r){return e=+e,t|=0,r||F(this,e,t,4,2147483647,-2147483648),e<0&&(e=4294967295+e+1),p.TYPED_ARRAY_SUPPORT?(this[t]=e>>>24,this[t+1]=e>>>16,this[t+2]=e>>>8,this[t+3]=255&e):Z(this,e,t,!1),t+4},p.prototype.writeFloatLE=function(e,t,r){return W(this,e,t,!0,r)},p.prototype.writeFloatBE=function(e,t,r){return W(this,e,t,!1,r)},p.prototype.writeDoubleLE=function(e,t,r){return Y(this,e,t,!0,r)},p.prototype.writeDoubleBE=function(e,t,r){return Y(this,e,t,!1,r)},p.prototype.copy=function(e,t,r,n){if(r||(r=0),n||0===n||(n=this.length),t>=e.length&&(t=e.length),t||(t=0),n>0&&n<r&&(n=r),n===r)return 0;if(0===e.length||0===this.length)return 0;if(t<0)throw new RangeError("targetStart out of bounds");if(r<0||r>=this.length)throw new RangeError("sourceStart out of bounds");if(n<0)throw new RangeError("sourceEnd out of bounds");n>this.length&&(n=this.length),e.length-t<n-r&&(n=e.length-t+r);var i,o=n-r;if(this===e&&r<t&&t<n)for(i=o-1;i>=0;--i)e[i+t]=this[i+r];else if(o<1e3||!p.TYPED_ARRAY_SUPPORT)for(i=0;i<o;++i)e[i+t]=this[i+r];else Uint8Array.prototype.set.call(e,this.subarray(r,r+o),t);return o},p.prototype.fill=function(e,t,r,n){if("string"==typeof e){if("string"==typeof t?(n=t,t=0,r=this.length):"string"==typeof r&&(n=r,r=this.length),1===e.length){var i=e.charCodeAt(0);i<256&&(e=i)}if(void 0!==n&&"string"!=typeof n)throw new TypeError("encoding must be a string");if("string"==typeof n&&!p.isEncoding(n))throw new TypeError("Unknown encoding: "+n)}else"number"==typeof e&&(e&=255);if(t<0||this.length<t||this.length<r)throw new RangeError("Out of range index");if(r<=t)return this;var o;if(t>>>=0,r=void 0===r?this.length:r>>>0,e||(e=0),"number"==typeof e)for(o=t;o<r;++o)this[o]=e;else{var a=y(e)?e:q(new p(e,n).toString()),s=a.length;for(o=0;o<r-t;++o)this[o+t]=a[o%s]}return this};var K=/[^+\/0-9A-Za-z-_]/g;function X(e){return e<16?"0"+e.toString(16):e.toString(16)}function q(e,t){var r;t=t||1/0;for(var n=e.length,i=null,o=[],a=0;a<n;++a){if((r=e.charCodeAt(a))>55295&&r<57344){if(!i){if(r>56319){(t-=3)>-1&&o.push(239,191,189);continue}if(a+1===n){(t-=3)>-1&&o.push(239,191,189);continue}i=r;continue}if(r<56320){(t-=3)>-1&&o.push(239,191,189),i=r;continue}r=65536+(i-55296<<10|r-56320)}else i&&(t-=3)>-1&&o.push(239,191,189);if(i=null,r<128){if((t-=1)<0)break;o.push(r)}else if(r<2048){if((t-=2)<0)break;o.push(r>>6|192,63&r|128)}else if(r<65536){if((t-=3)<0)break;o.push(r>>12|224,r>>6&63|128,63&r|128)}else{if(!(r<1114112))throw new Error("Invalid code point");if((t-=4)<0)break;o.push(r>>18|240,r>>12&63|128,r>>6&63|128,63&r|128)}}return o}function V(e){return function(e){var t,a,s,h,l,f;i||o();var c=e.length;if(c%4>0)throw new Error("Invalid string. Length must be a multiple of 4");l="="===e[c-2]?2:"="===e[c-1]?1:0,f=new n(3*c/4-l),s=l>0?c-4:c;var u=0;for(t=0,a=0;t<s;t+=4,a+=3)h=r[e.charCodeAt(t)]<<18|r[e.charCodeAt(t+1)]<<12|r[e.charCodeAt(t+2)]<<6|r[e.charCodeAt(t+3)],f[u++]=h>>16&255,f[u++]=h>>8&255,f[u++]=255&h;return 2===l?(h=r[e.charCodeAt(t)]<<2|r[e.charCodeAt(t+1)]>>4,f[u++]=255&h):1===l&&(h=r[e.charCodeAt(t)]<<10|r[e.charCodeAt(t+1)]<<4|r[e.charCodeAt(t+2)]>>2,f[u++]=h>>8&255,f[u++]=255&h),f}(function(e){if((e=function(e){return e.trim?e.trim():e.replace(/^\s+|\s+$/g,"")}(e).replace(K,"")).length<2)return"";for(;e.length%4!=0;)e+="=";return e}(e))}function G(e,t,r,n){for(var i=0;i<n&&!(i+r>=t.length||i>=e.length);++i)t[i+r]=e[i];return i}function $(e){return null!=e&&(!!e._isBuffer||J(e)||function(e){return"function"==typeof e.readFloatLE&&"function"==typeof e.slice&&J(e.slice(0,0))}(e))}function J(e){return!!e.constructor&&"function"==typeof e.constructor.isBuffer&&e.constructor.isBuffer(e)}"undefined"!=typeof globalThis?globalThis:"undefined"!=typeof window?window:"undefined"!=typeof global?global:"undefined"!=typeof self&&self;function Q(e,t){return e(t={exports:{}},t.exports),t.exports}var ee=Q(function(e,t){var r;e.exports=(r=r||function(e,t){var r=Object.create||function(){function e(){}return function(t){var r;return e.prototype=t,r=new e,e.prototype=null,r}}(),n={},i=n.lib={},o=i.Base={extend:function(e){var t=r(this);return e&&t.mixIn(e),t.hasOwnProperty("init")&&this.init!==t.init||(t.init=function(){t.$super.init.apply(this,arguments)}),t.init.prototype=t,t.$super=this,t},create:function(){var e=this.extend();return e.init.apply(e,arguments),e},init:function(){},mixIn:function(e){for(var t in e)e.hasOwnProperty(t)&&(this[t]=e[t]);e.hasOwnProperty("toString")&&(this.toString=e.toString)},clone:function(){return this.init.prototype.extend(this)}},a=i.WordArray=o.extend({init:function(e,t){e=this.words=e||[],this.sigBytes=null!=t?t:4*e.length},toString:function(e){return(e||h).stringify(this)},concat:function(e){var t=this.words,r=e.words,n=this.sigBytes,i=e.sigBytes;if(this.clamp(),n%4)for(var o=0;o<i;o++){var a=r[o>>>2]>>>24-o%4*8&255;t[n+o>>>2]|=a<<24-(n+o)%4*8}else for(var o=0;o<i;o+=4)t[n+o>>>2]=r[o>>>2];return this.sigBytes+=i,this},clamp:function(){var t=this.words,r=this.sigBytes;t[r>>>2]&=4294967295<<32-r%4*8,t.length=e.ceil(r/4)},clone:function(){var e=o.clone.call(this);return e.words=this.words.slice(0),e},random:function(t){for(var r,n=[],i=function(t){var t=t,r=987654321,n=4294967295;return function(){var i=((r=36969*(65535&r)+(r>>16)&n)<<16)+(t=18e3*(65535&t)+(t>>16)&n)&n;return i/=4294967296,(i+=.5)*(e.random()>.5?1:-1)}},o=0;o<t;o+=4){var s=i(4294967296*(r||e.random()));r=987654071*s(),n.push(4294967296*s()|0)}return new a.init(n,t)}}),s=n.enc={},h=s.Hex={stringify:function(e){for(var t=e.words,r=e.sigBytes,n=[],i=0;i<r;i++){var o=t[i>>>2]>>>24-i%4*8&255;n.push((o>>>4).toString(16)),n.push((15&o).toString(16))}return n.join("")},parse:function(e){for(var t=e.length,r=[],n=0;n<t;n+=2)r[n>>>3]|=parseInt(e.substr(n,2),16)<<24-n%8*4;return new a.init(r,t/2)}},l=s.Latin1={stringify:function(e){for(var t=e.words,r=e.sigBytes,n=[],i=0;i<r;i++){var o=t[i>>>2]>>>24-i%4*8&255;n.push(String.fromCharCode(o))}return n.join("")},parse:function(e){for(var t=e.length,r=[],n=0;n<t;n++)r[n>>>2]|=(255&e.charCodeAt(n))<<24-n%4*8;return new a.init(r,t)}},f=s.Utf8={stringify:function(e){try{return decodeURIComponent(escape(l.stringify(e)))}catch(e){throw new Error("Malformed UTF-8 data")}},parse:function(e){return l.parse(unescape(encodeURIComponent(e)))}},c=i.BufferedBlockAlgorithm=o.extend({reset:function(){this._data=new a.init,this._nDataBytes=0},_append:function(e){"string"==typeof e&&(e=f.parse(e)),this._data.concat(e),this._nDataBytes+=e.sigBytes},_process:function(t){var r=this._data,n=r.words,i=r.sigBytes,o=this.blockSize,s=4*o,h=i/s,l=(h=t?e.ceil(h):e.max((0|h)-this._minBufferSize,0))*o,f=e.min(4*l,i);if(l){for(var c=0;c<l;c+=o)this._doProcessBlock(n,c);var u=n.splice(0,l);r.sigBytes-=f}return new a.init(u,f)},clone:function(){var e=o.clone.call(this);return e._data=this._data.clone(),e},_minBufferSize:0}),u=(i.Hasher=c.extend({cfg:o.extend(),init:function(e){this.cfg=this.cfg.extend(e),this.reset()},reset:function(){c.reset.call(this),this._doReset()},update:function(e){return this._append(e),this._process(),this},finalize:function(e){e&&this._append(e);var t=this._doFinalize();return t},blockSize:16,_createHelper:function(e){return function(t,r){return new e.init(r).finalize(t)}},_createHmacHelper:function(e){return function(t,r){return new u.HMAC.init(e,r).finalize(t)}}}),n.algo={});return n}(Math),r)}),te=(Q(function(e,t){var r,n,i,o,a,s;e.exports=(i=(n=r=ee).lib,o=i.Base,a=i.WordArray,(s=n.x64={}).Word=o.extend({init:function(e,t){this.high=e,this.low=t}}),s.WordArray=o.extend({init:function(e,t){e=this.words=e||[],this.sigBytes=null!=t?t:8*e.length},toX32:function(){for(var e=this.words,t=e.length,r=[],n=0;n<t;n++){var i=e[n];r.push(i.high),r.push(i.low)}return a.create(r,this.sigBytes)},clone:function(){for(var e=o.clone.call(this),t=e.words=this.words.slice(0),r=t.length,n=0;n<r;n++)t[n]=t[n].clone();return e}}),r)}),Q(function(e,t){var r;e.exports=(r=ee,function(){if("function"==typeof ArrayBuffer){var e=r.lib.WordArray,t=e.init;(e.init=function(e){if(e instanceof ArrayBuffer&&(e=new Uint8Array(e)),(e instanceof Int8Array||"undefined"!=typeof Uint8ClampedArray&&e instanceof Uint8ClampedArray||e instanceof Int16Array||e instanceof Uint16Array||e instanceof Int32Array||e instanceof Uint32Array||e instanceof Float32Array||e instanceof Float64Array)&&(e=new Uint8Array(e.buffer,e.byteOffset,e.byteLength)),e instanceof Uint8Array){for(var r=e.byteLength,n=[],i=0;i<r;i++)n[i>>>2]|=e[i]<<24-i%4*8;t.call(this,n,r)}else t.apply(this,arguments)}).prototype=e}}(),r.lib.WordArray)}),Q(function(e,t){var r;e.exports=(r=ee,function(){var e=r,t=e.lib.WordArray,n=e.enc;function i(e){return e<<8&4278255360|e>>>8&16711935}n.Utf16=n.Utf16BE={stringify:function(e){for(var t=e.words,r=e.sigBytes,n=[],i=0;i<r;i+=2){var o=t[i>>>2]>>>16-i%4*8&65535;n.push(String.fromCharCode(o))}return n.join("")},parse:function(e){for(var r=e.length,n=[],i=0;i<r;i++)n[i>>>1]|=e.charCodeAt(i)<<16-i%2*16;return t.create(n,2*r)}},n.Utf16LE={stringify:function(e){for(var t=e.words,r=e.sigBytes,n=[],o=0;o<r;o+=2){var a=i(t[o>>>2]>>>16-o%4*8&65535);n.push(String.fromCharCode(a))}return n.join("")},parse:function(e){for(var r=e.length,n=[],o=0;o<r;o++)n[o>>>1]|=i(e.charCodeAt(o)<<16-o%2*16);return t.create(n,2*r)}}}(),r.enc.Utf16)}),Q(function(e,t){var r,n,i;e.exports=(i=(n=r=ee).lib.WordArray,n.enc.Base64={stringify:function(e){var t=e.words,r=e.sigBytes,n=this._map;e.clamp();for(var i=[],o=0;o<r;o+=3)for(var a=(t[o>>>2]>>>24-o%4*8&255)<<16|(t[o+1>>>2]>>>24-(o+1)%4*8&255)<<8|t[o+2>>>2]>>>24-(o+2)%4*8&255,s=0;s<4&&o+.75*s<r;s++)i.push(n.charAt(a>>>6*(3-s)&63));var h=n.charAt(64);if(h)for(;i.length%4;)i.push(h);return i.join("")},parse:function(e){var t=e.length,r=this._map,n=this._reverseMap;if(!n){n=this._reverseMap=[];for(var o=0;o<r.length;o++)n[r.charCodeAt(o)]=o}var a=r.charAt(64);if(a){var s=e.indexOf(a);-1!==s&&(t=s)}return function(e,t,r){for(var n=[],o=0,a=0;a<t;a++)if(a%4){var s=r[e.charCodeAt(a-1)]<<a%4*2,h=r[e.charCodeAt(a)]>>>6-a%4*2;n[o>>>2]|=(s|h)<<24-o%4*8,o++}return i.create(n,o)}(e,t,n)},_map:"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/="},r.enc.Base64)}),Q(function(e,t){var r;e.exports=(r=ee,function(e){var t=r,n=t.lib,i=n.WordArray,o=n.Hasher,a=t.algo,s=[];!function(){for(var t=0;t<64;t++)s[t]=4294967296*e.abs(e.sin(t+1))|0}();var h=a.MD5=o.extend({_doReset:function(){this._hash=new i.init([1732584193,4023233417,2562383102,271733878])},_doProcessBlock:function(e,t){for(var r=0;r<16;r++){var n=t+r,i=e[n];e[n]=16711935&(i<<8|i>>>24)|4278255360&(i<<24|i>>>8)}var o=this._hash.words,a=e[t+0],h=e[t+1],d=e[t+2],p=e[t+3],_=e[t+4],g=e[t+5],v=e[t+6],w=e[t+7],b=e[t+8],y=e[t+9],m=e[t+10],k=e[t+11],E=e[t+12],S=e[t+13],x=e[t+14],R=e[t+15],A=o[0],B=o[1],z=o[2],L=o[3];A=l(A,B,z,L,a,7,s[0]),L=l(L,A,B,z,h,12,s[1]),z=l(z,L,A,B,d,17,s[2]),B=l(B,z,L,A,p,22,s[3]),A=l(A,B,z,L,_,7,s[4]),L=l(L,A,B,z,g,12,s[5]),z=l(z,L,A,B,v,17,s[6]),B=l(B,z,L,A,w,22,s[7]),A=l(A,B,z,L,b,7,s[8]),L=l(L,A,B,z,y,12,s[9]),z=l(z,L,A,B,m,17,s[10]),B=l(B,z,L,A,k,22,s[11]),A=l(A,B,z,L,E,7,s[12]),L=l(L,A,B,z,S,12,s[13]),z=l(z,L,A,B,x,17,s[14]),A=f(A,B=l(B,z,L,A,R,22,s[15]),z,L,h,5,s[16]),L=f(L,A,B,z,v,9,s[17]),z=f(z,L,A,B,k,14,s[18]),B=f(B,z,L,A,a,20,s[19]),A=f(A,B,z,L,g,5,s[20]),L=f(L,A,B,z,m,9,s[21]),z=f(z,L,A,B,R,14,s[22]),B=f(B,z,L,A,_,20,s[23]),A=f(A,B,z,L,y,5,s[24]),L=f(L,A,B,z,x,9,s[25]),z=f(z,L,A,B,p,14,s[26]),B=f(B,z,L,A,b,20,s[27]),A=f(A,B,z,L,S,5,s[28]),L=f(L,A,B,z,d,9,s[29]),z=f(z,L,A,B,w,14,s[30]),A=c(A,B=f(B,z,L,A,E,20,s[31]),z,L,g,4,s[32]),L=c(L,A,B,z,b,11,s[33]),z=c(z,L,A,B,k,16,s[34]),B=c(B,z,L,A,x,23,s[35]),A=c(A,B,z,L,h,4,s[36]),L=c(L,A,B,z,_,11,s[37]),z=c(z,L,A,B,w,16,s[38]),B=c(B,z,L,A,m,23,s[39]),A=c(A,B,z,L,S,4,s[40]),L=c(L,A,B,z,a,11,s[41]),z=c(z,L,A,B,p,16,s[42]),B=c(B,z,L,A,v,23,s[43]),A=c(A,B,z,L,y,4,s[44]),L=c(L,A,B,z,E,11,s[45]),z=c(z,L,A,B,R,16,s[46]),A=u(A,B=c(B,z,L,A,d,23,s[47]),z,L,a,6,s[48]),L=u(L,A,B,z,w,10,s[49]),z=u(z,L,A,B,x,15,s[50]),B=u(B,z,L,A,g,21,s[51]),A=u(A,B,z,L,E,6,s[52]),L=u(L,A,B,z,p,10,s[53]),z=u(z,L,A,B,m,15,s[54]),B=u(B,z,L,A,h,21,s[55]),A=u(A,B,z,L,b,6,s[56]),L=u(L,A,B,z,R,10,s[57]),z=u(z,L,A,B,v,15,s[58]),B=u(B,z,L,A,S,21,s[59]),A=u(A,B,z,L,_,6,s[60]),L=u(L,A,B,z,k,10,s[61]),z=u(z,L,A,B,d,15,s[62]),B=u(B,z,L,A,y,21,s[63]),o[0]=o[0]+A|0,o[1]=o[1]+B|0,o[2]=o[2]+z|0,o[3]=o[3]+L|0},_doFinalize:function(){var t=this._data,r=t.words,n=8*this._nDataBytes,i=8*t.sigBytes;r[i>>>5]|=128<<24-i%32;var o=e.floor(n/4294967296),a=n;r[15+(i+64>>>9<<4)]=16711935&(o<<8|o>>>24)|4278255360&(o<<24|o>>>8),r[14+(i+64>>>9<<4)]=16711935&(a<<8|a>>>24)|4278255360&(a<<24|a>>>8),t.sigBytes=4*(r.length+1),this._process();for(var s=this._hash,h=s.words,l=0;l<4;l++){var f=h[l];h[l]=16711935&(f<<8|f>>>24)|4278255360&(f<<24|f>>>8)}return s},clone:function(){var e=o.clone.call(this);return e._hash=this._hash.clone(),e}});function l(e,t,r,n,i,o,a){var s=e+(t&r|~t&n)+i+a;return(s<<o|s>>>32-o)+t}function f(e,t,r,n,i,o,a){var s=e+(t&n|r&~n)+i+a;return(s<<o|s>>>32-o)+t}function c(e,t,r,n,i,o,a){var s=e+(t^r^n)+i+a;return(s<<o|s>>>32-o)+t}function u(e,t,r,n,i,o,a){var s=e+(r^(t|~n))+i+a;return(s<<o|s>>>32-o)+t}t.MD5=o._createHelper(h),t.HmacMD5=o._createHmacHelper(h)}(Math),r.MD5)}),Q(function(e,t){var r,n,i,o,a,s,h,l;e.exports=(i=(n=r=ee).lib,o=i.WordArray,a=i.Hasher,s=n.algo,h=[],l=s.SHA1=a.extend({_doReset:function(){this._hash=new o.init([1732584193,4023233417,2562383102,271733878,3285377520])},_doProcessBlock:function(e,t){for(var r=this._hash.words,n=r[0],i=r[1],o=r[2],a=r[3],s=r[4],l=0;l<80;l++){if(l<16)h[l]=0|e[t+l];else{var f=h[l-3]^h[l-8]^h[l-14]^h[l-16];h[l]=f<<1|f>>>31}var c=(n<<5|n>>>27)+s+h[l];c+=l<20?1518500249+(i&o|~i&a):l<40?1859775393+(i^o^a):l<60?(i&o|i&a|o&a)-1894007588:(i^o^a)-899497514,s=a,a=o,o=i<<30|i>>>2,i=n,n=c}r[0]=r[0]+n|0,r[1]=r[1]+i|0,r[2]=r[2]+o|0,r[3]=r[3]+a|0,r[4]=r[4]+s|0},_doFinalize:function(){var e=this._data,t=e.words,r=8*this._nDataBytes,n=8*e.sigBytes;return t[n>>>5]|=128<<24-n%32,t[14+(n+64>>>9<<4)]=Math.floor(r/4294967296),t[15+(n+64>>>9<<4)]=r,e.sigBytes=4*t.length,this._process(),this._hash},clone:function(){var e=a.clone.call(this);return e._hash=this._hash.clone(),e}}),n.SHA1=a._createHelper(l),n.HmacSHA1=a._createHmacHelper(l),r.SHA1)}),Q(function(e,t){var r;e.exports=(r=ee,function(e){var t=r,n=t.lib,i=n.WordArray,o=n.Hasher,a=t.algo,s=[],h=[];!function(){function t(t){for(var r=e.sqrt(t),n=2;n<=r;n++)if(!(t%n))return!1;return!0}function r(e){return 4294967296*(e-(0|e))|0}for(var n=2,i=0;i<64;)t(n)&&(i<8&&(s[i]=r(e.pow(n,.5))),h[i]=r(e.pow(n,1/3)),i++),n++}();var l=[],f=a.SHA256=o.extend({_doReset:function(){this._hash=new i.init(s.slice(0))},_doProcessBlock:function(e,t){for(var r=this._hash.words,n=r[0],i=r[1],o=r[2],a=r[3],s=r[4],f=r[5],c=r[6],u=r[7],d=0;d<64;d++){if(d<16)l[d]=0|e[t+d];else{var p=l[d-15],_=(p<<25|p>>>7)^(p<<14|p>>>18)^p>>>3,g=l[d-2],v=(g<<15|g>>>17)^(g<<13|g>>>19)^g>>>10;l[d]=_+l[d-7]+v+l[d-16]}var w=n&i^n&o^i&o,b=(n<<30|n>>>2)^(n<<19|n>>>13)^(n<<10|n>>>22),y=u+((s<<26|s>>>6)^(s<<21|s>>>11)^(s<<7|s>>>25))+(s&f^~s&c)+h[d]+l[d];u=c,c=f,f=s,s=a+y|0,a=o,o=i,i=n,n=y+(b+w)|0}r[0]=r[0]+n|0,r[1]=r[1]+i|0,r[2]=r[2]+o|0,r[3]=r[3]+a|0,r[4]=r[4]+s|0,r[5]=r[5]+f|0,r[6]=r[6]+c|0,r[7]=r[7]+u|0},_doFinalize:function(){var t=this._data,r=t.words,n=8*this._nDataBytes,i=8*t.sigBytes;return r[i>>>5]|=128<<24-i%32,r[14+(i+64>>>9<<4)]=e.floor(n/4294967296),r[15+(i+64>>>9<<4)]=n,t.sigBytes=4*r.length,this._process(),this._hash},clone:function(){var e=o.clone.call(this);return e._hash=this._hash.clone(),e}});t.SHA256=o._createHelper(f),t.HmacSHA256=o._createHmacHelper(f)}(Math),r.SHA256)}),Q(function(e,t){var r,n,i,o,a,s;e.exports=(i=(n=r=ee).lib.WordArray,o=n.algo,a=o.SHA256,s=o.SHA224=a.extend({_doReset:function(){this._hash=new i.init([3238371032,914150663,812702999,4144912697,4290775857,1750603025,1694076839,3204075428])},_doFinalize:function(){var e=a._doFinalize.call(this);return e.sigBytes-=4,e}}),n.SHA224=a._createHelper(s),n.HmacSHA224=a._createHmacHelper(s),r.SHA224)}),Q(function(e,t){var r;e.exports=(r=ee,function(){var e=r,t=e.lib.Hasher,n=e.x64,i=n.Word,o=n.WordArray,a=e.algo;function s(){return i.create.apply(i,arguments)}var h=[s(1116352408,3609767458),s(1899447441,602891725),s(3049323471,3964484399),s(3921009573,2173295548),s(961987163,4081628472),s(1508970993,3053834265),s(2453635748,2937671579),s(2870763221,3664609560),s(3624381080,2734883394),s(310598401,1164996542),s(607225278,1323610764),s(1426881987,3590304994),s(1925078388,4068182383),s(2162078206,991336113),s(2614888103,633803317),s(3248222580,3479774868),s(3835390401,2666613458),s(4022224774,944711139),s(264347078,2341262773),s(604807628,2007800933),s(770255983,1495990901),s(1249150122,1856431235),s(1555081692,3175218132),s(1996064986,2198950837),s(2554220882,3999719339),s(2821834349,766784016),s(2952996808,2566594879),s(3210313671,3203337956),s(3336571891,1034457026),s(3584528711,2466948901),s(113926993,3758326383),s(338241895,168717936),s(666307205,1188179964),s(773529912,1546045734),s(1294757372,1522805485),s(1396182291,2643833823),s(1695183700,2343527390),s(1986661051,1014477480),s(2177026350,1206759142),s(2456956037,344077627),s(2730485921,1290863460),s(2820302411,3158454273),s(3259730800,3505952657),s(3345764771,106217008),s(3516065817,3606008344),s(3600352804,1432725776),s(4094571909,1467031594),s(275423344,851169720),s(430227734,3100823752),s(506948616,1363258195),s(659060556,3750685593),s(883997877,3785050280),s(958139571,3318307427),s(1322822218,3812723403),s(1537002063,2003034995),s(1747873779,3602036899),s(1955562222,1575990012),s(2024104815,1125592928),s(2227730452,2716904306),s(2361852424,442776044),s(2428436474,593698344),s(2756734187,3733110249),s(3204031479,2999351573),s(3329325298,3815920427),s(3391569614,3928383900),s(3515267271,566280711),s(3940187606,3454069534),s(4118630271,4000239992),s(116418474,1914138554),s(174292421,2731055270),s(289380356,3203993006),s(460393269,320620315),s(685471733,587496836),s(852142971,1086792851),s(1017036298,365543100),s(1126000580,2618297676),s(1288033470,3409855158),s(1501505948,4234509866),s(1607167915,987167468),s(1816402316,1246189591)],l=[];!function(){for(var e=0;e<80;e++)l[e]=s()}();var f=a.SHA512=t.extend({_doReset:function(){this._hash=new o.init([new i.init(1779033703,4089235720),new i.init(3144134277,2227873595),new i.init(1013904242,4271175723),new i.init(2773480762,1595750129),new i.init(1359893119,2917565137),new i.init(2600822924,725511199),new i.init(528734635,4215389547),new i.init(1541459225,327033209)])},_doProcessBlock:function(e,t){for(var r=this._hash.words,n=r[0],i=r[1],o=r[2],a=r[3],s=r[4],f=r[5],c=r[6],u=r[7],d=n.high,p=n.low,_=i.high,g=i.low,v=o.high,w=o.low,b=a.high,y=a.low,m=s.high,k=s.low,E=f.high,S=f.low,x=c.high,R=c.low,A=u.high,B=u.low,z=d,L=p,T=_,M=g,C=v,D=w,I=b,P=y,O=m,U=k,H=E,F=S,N=x,Z=R,j=A,W=B,Y=0;Y<80;Y++){var K=l[Y];if(Y<16)var X=K.high=0|e[t+2*Y],q=K.low=0|e[t+2*Y+1];else{var V=l[Y-15],G=V.high,$=V.low,J=(G>>>1|$<<31)^(G>>>8|$<<24)^G>>>7,Q=($>>>1|G<<31)^($>>>8|G<<24)^($>>>7|G<<25),ee=l[Y-2],te=ee.high,re=ee.low,ne=(te>>>19|re<<13)^(te<<3|re>>>29)^te>>>6,ie=(re>>>19|te<<13)^(re<<3|te>>>29)^(re>>>6|te<<26),oe=l[Y-7],ae=oe.high,se=oe.low,he=l[Y-16],le=he.high,fe=he.low;X=(X=(X=J+ae+((q=Q+se)>>>0<Q>>>0?1:0))+ne+((q+=ie)>>>0<ie>>>0?1:0))+le+((q+=fe)>>>0<fe>>>0?1:0),K.high=X,K.low=q}var ce,ue=O&H^~O&N,de=U&F^~U&Z,pe=z&T^z&C^T&C,_e=L&M^L&D^M&D,ge=(z>>>28|L<<4)^(z<<30|L>>>2)^(z<<25|L>>>7),ve=(L>>>28|z<<4)^(L<<30|z>>>2)^(L<<25|z>>>7),we=(O>>>14|U<<18)^(O>>>18|U<<14)^(O<<23|U>>>9),be=(U>>>14|O<<18)^(U>>>18|O<<14)^(U<<23|O>>>9),ye=h[Y],me=ye.high,ke=ye.low,Ee=j+we+((ce=W+be)>>>0<W>>>0?1:0),Se=ve+_e;j=N,W=Z,N=H,Z=F,H=O,F=U,O=I+(Ee=(Ee=(Ee=Ee+ue+((ce+=de)>>>0<de>>>0?1:0))+me+((ce+=ke)>>>0<ke>>>0?1:0))+X+((ce+=q)>>>0<q>>>0?1:0))+((U=P+ce|0)>>>0<P>>>0?1:0)|0,I=C,P=D,C=T,D=M,T=z,M=L,z=Ee+(ge+pe+(Se>>>0<ve>>>0?1:0))+((L=ce+Se|0)>>>0<ce>>>0?1:0)|0}p=n.low=p+L,n.high=d+z+(p>>>0<L>>>0?1:0),g=i.low=g+M,i.high=_+T+(g>>>0<M>>>0?1:0),w=o.low=w+D,o.high=v+C+(w>>>0<D>>>0?1:0),y=a.low=y+P,a.high=b+I+(y>>>0<P>>>0?1:0),k=s.low=k+U,s.high=m+O+(k>>>0<U>>>0?1:0),S=f.low=S+F,f.high=E+H+(S>>>0<F>>>0?1:0),R=c.low=R+Z,c.high=x+N+(R>>>0<Z>>>0?1:0),B=u.low=B+W,u.high=A+j+(B>>>0<W>>>0?1:0)},_doFinalize:function(){var e=this._data,t=e.words,r=8*this._nDataBytes,n=8*e.sigBytes;return t[n>>>5]|=128<<24-n%32,t[30+(n+128>>>10<<5)]=Math.floor(r/4294967296),t[31+(n+128>>>10<<5)]=r,e.sigBytes=4*t.length,this._process(),this._hash.toX32()},clone:function(){var e=t.clone.call(this);return e._hash=this._hash.clone(),e},blockSize:32});e.SHA512=t._createHelper(f),e.HmacSHA512=t._createHmacHelper(f)}(),r.SHA512)}),Q(function(e,t){var r,n,i,o,a,s,h,l;e.exports=(i=(n=r=ee).x64,o=i.Word,a=i.WordArray,s=n.algo,h=s.SHA512,l=s.SHA384=h.extend({_doReset:function(){this._hash=new a.init([new o.init(3418070365,3238371032),new o.init(1654270250,914150663),new o.init(2438529370,812702999),new o.init(355462360,4144912697),new o.init(1731405415,4290775857),new o.init(2394180231,1750603025),new o.init(3675008525,1694076839),new o.init(1203062813,3204075428)])},_doFinalize:function(){var e=h._doFinalize.call(this);return e.sigBytes-=16,e}}),n.SHA384=h._createHelper(l),n.HmacSHA384=h._createHmacHelper(l),r.SHA384)}),Q(function(e,t){var r;e.exports=(r=ee,function(e){var t=r,n=t.lib,i=n.WordArray,o=n.Hasher,a=t.x64.Word,s=t.algo,h=[],l=[],f=[];!function(){for(var e=1,t=0,r=0;r<24;r++){h[e+5*t]=(r+1)*(r+2)/2%64;var n=(2*e+3*t)%5;e=t%5,t=n}for(e=0;e<5;e++)for(t=0;t<5;t++)l[e+5*t]=t+(2*e+3*t)%5*5;for(var i=1,o=0;o<24;o++){for(var s=0,c=0,u=0;u<7;u++){if(1&i){var d=(1<<u)-1;d<32?c^=1<<d:s^=1<<d-32}128&i?i=i<<1^113:i<<=1}f[o]=a.create(s,c)}}();var c=[];!function(){for(var e=0;e<25;e++)c[e]=a.create()}();var u=s.SHA3=o.extend({cfg:o.cfg.extend({outputLength:512}),_doReset:function(){for(var e=this._state=[],t=0;t<25;t++)e[t]=new a.init;this.blockSize=(1600-2*this.cfg.outputLength)/32},_doProcessBlock:function(e,t){for(var r=this._state,n=this.blockSize/2,i=0;i<n;i++){var o=e[t+2*i],a=e[t+2*i+1];o=16711935&(o<<8|o>>>24)|4278255360&(o<<24|o>>>8),a=16711935&(a<<8|a>>>24)|4278255360&(a<<24|a>>>8),(B=r[i]).high^=a,B.low^=o}for(var s=0;s<24;s++){for(var u=0;u<5;u++){for(var d=0,p=0,_=0;_<5;_++)d^=(B=r[u+5*_]).high,p^=B.low;var g=c[u];g.high=d,g.low=p}for(u=0;u<5;u++){var v=c[(u+4)%5],w=c[(u+1)%5],b=w.high,y=w.low;for(d=v.high^(b<<1|y>>>31),p=v.low^(y<<1|b>>>31),_=0;_<5;_++)(B=r[u+5*_]).high^=d,B.low^=p}for(var m=1;m<25;m++){var k=(B=r[m]).high,E=B.low,S=h[m];S<32?(d=k<<S|E>>>32-S,p=E<<S|k>>>32-S):(d=E<<S-32|k>>>64-S,p=k<<S-32|E>>>64-S);var x=c[l[m]];x.high=d,x.low=p}var R=c[0],A=r[0];for(R.high=A.high,R.low=A.low,u=0;u<5;u++)for(_=0;_<5;_++){var B=r[m=u+5*_],z=c[m],L=c[(u+1)%5+5*_],T=c[(u+2)%5+5*_];B.high=z.high^~L.high&T.high,B.low=z.low^~L.low&T.low}B=r[0];var M=f[s];B.high^=M.high,B.low^=M.low}},_doFinalize:function(){var t=this._data,r=t.words,n=(this._nDataBytes,8*t.sigBytes),o=32*this.blockSize;r[n>>>5]|=1<<24-n%32,r[(e.ceil((n+1)/o)*o>>>5)-1]|=128,t.sigBytes=4*r.length,this._process();for(var a=this._state,s=this.cfg.outputLength/8,h=s/8,l=[],f=0;f<h;f++){var c=a[f],u=c.high,d=c.low;u=16711935&(u<<8|u>>>24)|4278255360&(u<<24|u>>>8),d=16711935&(d<<8|d>>>24)|4278255360&(d<<24|d>>>8),l.push(d),l.push(u)}return new i.init(l,s)},clone:function(){for(var e=o.clone.call(this),t=e._state=this._state.slice(0),r=0;r<25;r++)t[r]=t[r].clone();return e}});t.SHA3=o._createHelper(u),t.HmacSHA3=o._createHmacHelper(u)}(Math),r.SHA3)}),Q(function(e,t){var r;e.exports=(r=ee,function(e){var t=r,n=t.lib,i=n.WordArray,o=n.Hasher,a=t.algo,s=i.create([0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,7,4,13,1,10,6,15,3,12,0,9,5,2,14,11,8,3,10,14,4,9,15,8,1,2,7,0,6,13,11,5,12,1,9,11,10,0,8,12,4,13,3,7,15,14,5,6,2,4,0,5,9,7,12,2,10,14,1,3,8,11,6,15,13]),h=i.create([5,14,7,0,9,2,11,4,13,6,15,8,1,10,3,12,6,11,3,7,0,13,5,10,14,15,8,12,4,9,1,2,15,5,1,3,7,14,6,9,11,8,12,2,10,0,4,13,8,6,4,1,3,11,15,0,5,12,2,13,9,7,10,14,12,15,10,4,1,5,8,7,6,2,13,14,0,3,9,11]),l=i.create([11,14,15,12,5,8,7,9,11,13,14,15,6,7,9,8,7,6,8,13,11,9,7,15,7,12,15,9,11,7,13,12,11,13,6,7,14,9,13,15,14,8,13,6,5,12,7,5,11,12,14,15,14,15,9,8,9,14,5,6,8,6,5,12,9,15,5,11,6,8,13,12,5,12,13,14,11,8,5,6]),f=i.create([8,9,9,11,13,15,15,5,7,7,8,11,14,14,12,6,9,13,15,7,12,8,9,11,7,7,12,7,6,15,13,11,9,7,15,11,8,6,6,14,12,13,5,14,13,13,7,5,15,5,8,11,14,14,6,14,6,9,12,9,12,5,15,8,8,5,12,9,12,5,14,6,8,13,6,5,15,13,11,11]),c=i.create([0,1518500249,1859775393,2400959708,2840853838]),u=i.create([1352829926,1548603684,1836072691,2053994217,0]),d=a.RIPEMD160=o.extend({_doReset:function(){this._hash=i.create([1732584193,4023233417,2562383102,271733878,3285377520])},_doProcessBlock:function(e,t){for(var r=0;r<16;r++){var n=t+r,i=e[n];e[n]=16711935&(i<<8|i>>>24)|4278255360&(i<<24|i>>>8)}var o,a,d,y,m,k,E,S,x,R,A,B=this._hash.words,z=c.words,L=u.words,T=s.words,M=h.words,C=l.words,D=f.words;for(k=o=B[0],E=a=B[1],S=d=B[2],x=y=B[3],R=m=B[4],r=0;r<80;r+=1)A=o+e[t+T[r]]|0,A+=r<16?p(a,d,y)+z[0]:r<32?_(a,d,y)+z[1]:r<48?g(a,d,y)+z[2]:r<64?v(a,d,y)+z[3]:w(a,d,y)+z[4],A=(A=b(A|=0,C[r]))+m|0,o=m,m=y,y=b(d,10),d=a,a=A,A=k+e[t+M[r]]|0,A+=r<16?w(E,S,x)+L[0]:r<32?v(E,S,x)+L[1]:r<48?g(E,S,x)+L[2]:r<64?_(E,S,x)+L[3]:p(E,S,x)+L[4],A=(A=b(A|=0,D[r]))+R|0,k=R,R=x,x=b(S,10),S=E,E=A;A=B[1]+d+x|0,B[1]=B[2]+y+R|0,B[2]=B[3]+m+k|0,B[3]=B[4]+o+E|0,B[4]=B[0]+a+S|0,B[0]=A},_doFinalize:function(){var e=this._data,t=e.words,r=8*this._nDataBytes,n=8*e.sigBytes;t[n>>>5]|=128<<24-n%32,t[14+(n+64>>>9<<4)]=16711935&(r<<8|r>>>24)|4278255360&(r<<24|r>>>8),e.sigBytes=4*(t.length+1),this._process();for(var i=this._hash,o=i.words,a=0;a<5;a++){var s=o[a];o[a]=16711935&(s<<8|s>>>24)|4278255360&(s<<24|s>>>8)}return i},clone:function(){var e=o.clone.call(this);return e._hash=this._hash.clone(),e}});function p(e,t,r){return e^t^r}function _(e,t,r){return e&t|~e&r}function g(e,t,r){return(e|~t)^r}function v(e,t,r){return e&r|t&~r}function w(e,t,r){return e^(t|~r)}function b(e,t){return e<<t|e>>>32-t}t.RIPEMD160=o._createHelper(d),t.HmacRIPEMD160=o._createHmacHelper(d)}(),r.RIPEMD160)}),Q(function(e,t){var r,n,i,o,a,s;e.exports=(n=(r=ee).lib,i=n.Base,o=r.enc,a=o.Utf8,s=r.algo,void(s.HMAC=i.extend({init:function(e,t){e=this._hasher=new e.init,"string"==typeof t&&(t=a.parse(t));var r=e.blockSize,n=4*r;t.sigBytes>n&&(t=e.finalize(t)),t.clamp();for(var i=this._oKey=t.clone(),o=this._iKey=t.clone(),s=i.words,h=o.words,l=0;l<r;l++)s[l]^=1549556828,h[l]^=909522486;i.sigBytes=o.sigBytes=n,this.reset()},reset:function(){var e=this._hasher;e.reset(),e.update(this._iKey)},update:function(e){return this._hasher.update(e),this},finalize:function(e){var t=this._hasher,r=t.finalize(e);t.reset();var n=t.finalize(this._oKey.clone().concat(r));return n}})))}),Q(function(e,t){var r,n,i,o,a,s,h,l,f;e.exports=(i=(n=r=ee).lib,o=i.Base,a=i.WordArray,s=n.algo,h=s.SHA1,l=s.HMAC,f=s.PBKDF2=o.extend({cfg:o.extend({keySize:4,hasher:h,iterations:1}),init:function(e){this.cfg=this.cfg.extend(e)},compute:function(e,t){for(var r=this.cfg,n=l.create(r.hasher,e),i=a.create(),o=a.create([1]),s=i.words,h=o.words,f=r.keySize,c=r.iterations;s.length<f;){var u=n.update(t).finalize(o);n.reset();for(var d=u.words,p=d.length,_=u,g=1;g<c;g++){_=n.finalize(_),n.reset();for(var v=_.words,w=0;w<p;w++)d[w]^=v[w]}i.concat(u),h[0]++}return i.sigBytes=4*f,i}}),n.PBKDF2=function(e,t,r){return f.create(r).compute(e,t)},r.PBKDF2)}),Q(function(e,t){var r,n,i,o,a,s,h,l;e.exports=(i=(n=r=ee).lib,o=i.Base,a=i.WordArray,s=n.algo,h=s.MD5,l=s.EvpKDF=o.extend({cfg:o.extend({keySize:4,hasher:h,iterations:1}),init:function(e){this.cfg=this.cfg.extend(e)},compute:function(e,t){for(var r=this.cfg,n=r.hasher.create(),i=a.create(),o=i.words,s=r.keySize,h=r.iterations;o.length<s;){l&&n.update(l);var l=n.update(e).finalize(t);n.reset();for(var f=1;f<h;f++)l=n.finalize(l),n.reset();i.concat(l)}return i.sigBytes=4*s,i}}),n.EvpKDF=function(e,t,r){return l.create(r).compute(e,t)},r.EvpKDF)}),Q(function(e,t){var r,n,i,o,a,s,h,l,f,c,u,d,p,_,g,v,w,b,y,m,k,E,S,x;e.exports=void((r=ee).lib.Cipher||(i=r,o=i.lib,a=o.Base,s=o.WordArray,h=o.BufferedBlockAlgorithm,l=i.enc,l.Utf8,f=l.Base64,c=i.algo,u=c.EvpKDF,d=o.Cipher=h.extend({cfg:a.extend(),createEncryptor:function(e,t){return this.create(this._ENC_XFORM_MODE,e,t)},createDecryptor:function(e,t){return this.create(this._DEC_XFORM_MODE,e,t)},init:function(e,t,r){this.cfg=this.cfg.extend(r),this._xformMode=e,this._key=t,this.reset()},reset:function(){h.reset.call(this),this._doReset()},process:function(e){return this._append(e),this._process()},finalize:function(e){e&&this._append(e);var t=this._doFinalize();return t},keySize:4,ivSize:4,_ENC_XFORM_MODE:1,_DEC_XFORM_MODE:2,_createHelper:function(){function e(e){return"string"==typeof e?x:k}return function(t){return{encrypt:function(r,n,i){return e(n).encrypt(t,r,n,i)},decrypt:function(r,n,i){return e(n).decrypt(t,r,n,i)}}}}()}),o.StreamCipher=d.extend({_doFinalize:function(){var e=this._process(!0);return e},blockSize:1}),p=i.mode={},_=o.BlockCipherMode=a.extend({createEncryptor:function(e,t){return this.Encryptor.create(e,t)},createDecryptor:function(e,t){return this.Decryptor.create(e,t)},init:function(e,t){this._cipher=e,this._iv=t}}),g=p.CBC=function(){var e=_.extend();function t(e,t,r){var i=this._iv;if(i){var o=i;this._iv=n}else var o=this._prevBlock;for(var a=0;a<r;a++)e[t+a]^=o[a]}return e.Encryptor=e.extend({processBlock:function(e,r){var n=this._cipher,i=n.blockSize;t.call(this,e,r,i),n.encryptBlock(e,r),this._prevBlock=e.slice(r,r+i)}}),e.Decryptor=e.extend({processBlock:function(e,r){var n=this._cipher,i=n.blockSize,o=e.slice(r,r+i);n.decryptBlock(e,r),t.call(this,e,r,i),this._prevBlock=o}}),e}(),v=i.pad={},w=v.Pkcs7={pad:function(e,t){for(var r=4*t,n=r-e.sigBytes%r,i=n<<24|n<<16|n<<8|n,o=[],a=0;a<n;a+=4)o.push(i);var h=s.create(o,n);e.concat(h)},unpad:function(e){var t=255&e.words[e.sigBytes-1>>>2];e.sigBytes-=t}},o.BlockCipher=d.extend({cfg:d.cfg.extend({mode:g,padding:w}),reset:function(){d.reset.call(this);var e=this.cfg,t=e.iv,r=e.mode;if(this._xformMode==this._ENC_XFORM_MODE)var n=r.createEncryptor;else{var n=r.createDecryptor;this._minBufferSize=1}this._mode&&this._mode.__creator==n?this._mode.init(this,t&&t.words):(this._mode=n.call(r,this,t&&t.words),this._mode.__creator=n)},_doProcessBlock:function(e,t){this._mode.processBlock(e,t)},_doFinalize:function(){var e=this.cfg.padding;if(this._xformMode==this._ENC_XFORM_MODE){e.pad(this._data,this.blockSize);var t=this._process(!0)}else{var t=this._process(!0);e.unpad(t)}return t},blockSize:4}),b=o.CipherParams=a.extend({init:function(e){this.mixIn(e)},toString:function(e){return(e||this.formatter).stringify(this)}}),y=i.format={},m=y.OpenSSL={stringify:function(e){var t=e.ciphertext,r=e.salt;if(r)var n=s.create([1398893684,1701076831]).concat(r).concat(t);else var n=t;return n.toString(f)},parse:function(e){var t=f.parse(e),r=t.words;if(1398893684==r[0]&&1701076831==r[1]){var n=s.create(r.slice(2,4));r.splice(0,4),t.sigBytes-=16}return b.create({ciphertext:t,salt:n})}},k=o.SerializableCipher=a.extend({cfg:a.extend({format:m}),encrypt:function(e,t,r,n){n=this.cfg.extend(n);var i=e.createEncryptor(r,n),o=i.finalize(t),a=i.cfg;return b.create({ciphertext:o,key:r,iv:a.iv,algorithm:e,mode:a.mode,padding:a.padding,blockSize:e.blockSize,formatter:n.format})},decrypt:function(e,t,r,n){n=this.cfg.extend(n),t=this._parse(t,n.format);var i=e.createDecryptor(r,n).finalize(t.ciphertext);return i},_parse:function(e,t){return"string"==typeof e?t.parse(e,this):e}}),E=i.kdf={},S=E.OpenSSL={execute:function(e,t,r,n){n||(n=s.random(8));var i=u.create({keySize:t+r}).compute(e,n),o=s.create(i.words.slice(t),4*r);return i.sigBytes=4*t,b.create({key:i,iv:o,salt:n})}},x=o.PasswordBasedCipher=k.extend({cfg:k.cfg.extend({kdf:S}),encrypt:function(e,t,r,n){var i=(n=this.cfg.extend(n)).kdf.execute(r,e.keySize,e.ivSize);n.iv=i.iv;var o=k.encrypt.call(this,e,t,i.key,n);return o.mixIn(i),o},decrypt:function(e,t,r,n){n=this.cfg.extend(n),t=this._parse(t,n.format);var i=n.kdf.execute(r,e.keySize,e.ivSize,t.salt);n.iv=i.iv;var o=k.decrypt.call(this,e,t,i.key,n);return o}})))}),Q(function(e,t){var r;e.exports=((r=ee).mode.CFB=function(){var e=r.lib.BlockCipherMode.extend();function t(e,t,r,n){var i=this._iv;if(i){var o=i.slice(0);this._iv=void 0}else o=this._prevBlock;n.encryptBlock(o,0);for(var a=0;a<r;a++)e[t+a]^=o[a]}return e.Encryptor=e.extend({processBlock:function(e,r){var n=this._cipher,i=n.blockSize;t.call(this,e,r,i,n),this._prevBlock=e.slice(r,r+i)}}),e.Decryptor=e.extend({processBlock:function(e,r){var n=this._cipher,i=n.blockSize,o=e.slice(r,r+i);t.call(this,e,r,i,n),this._prevBlock=o}}),e}(),r.mode.CFB)}),Q(function(e,t){var r,n,i;e.exports=((r=ee).mode.CTR=(n=r.lib.BlockCipherMode.extend(),i=n.Encryptor=n.extend({processBlock:function(e,t){var r=this._cipher,n=r.blockSize,i=this._iv,o=this._counter;i&&(o=this._counter=i.slice(0),this._iv=void 0);var a=o.slice(0);r.encryptBlock(a,0),o[n-1]=o[n-1]+1|0;for(var s=0;s<n;s++)e[t+s]^=a[s]}}),n.Decryptor=i,n),r.mode.CTR)}),Q(function(e,t){var r;e.exports=((r=ee).mode.CTRGladman=function(){var e=r.lib.BlockCipherMode.extend();function t(e){if(255==(e>>24&255)){var t=e>>16&255,r=e>>8&255,n=255&e;255===t?(t=0,255===r?(r=0,255===n?n=0:++n):++r):++t,e=0,e+=t<<16,e+=r<<8,e+=n}else e+=1<<24;return e}var n=e.Encryptor=e.extend({processBlock:function(e,r){var n=this._cipher,i=n.blockSize,o=this._iv,a=this._counter;o&&(a=this._counter=o.slice(0),this._iv=void 0),function(e){0===(e[0]=t(e[0]))&&(e[1]=t(e[1]))}(a);var s=a.slice(0);n.encryptBlock(s,0);for(var h=0;h<i;h++)e[r+h]^=s[h]}});return e.Decryptor=n,e}(),r.mode.CTRGladman)}),Q(function(e,t){var r,n,i;e.exports=((r=ee).mode.OFB=(n=r.lib.BlockCipherMode.extend(),i=n.Encryptor=n.extend({processBlock:function(e,t){var r=this._cipher,n=r.blockSize,i=this._iv,o=this._keystream;i&&(o=this._keystream=i.slice(0),this._iv=void 0),r.encryptBlock(o,0);for(var a=0;a<n;a++)e[t+a]^=o[a]}}),n.Decryptor=i,n),r.mode.OFB)}),Q(function(e,t){var r,n;e.exports=((r=ee).mode.ECB=((n=r.lib.BlockCipherMode.extend()).Encryptor=n.extend({processBlock:function(e,t){this._cipher.encryptBlock(e,t)}}),n.Decryptor=n.extend({processBlock:function(e,t){this._cipher.decryptBlock(e,t)}}),n),r.mode.ECB)}),Q(function(e,t){var r;e.exports=((r=ee).pad.AnsiX923={pad:function(e,t){var r=e.sigBytes,n=4*t,i=n-r%n,o=r+i-1;e.clamp(),e.words[o>>>2]|=i<<24-o%4*8,e.sigBytes+=i},unpad:function(e){var t=255&e.words[e.sigBytes-1>>>2];e.sigBytes-=t}},r.pad.Ansix923)}),Q(function(e,t){var r;e.exports=((r=ee).pad.Iso10126={pad:function(e,t){var n=4*t,i=n-e.sigBytes%n;e.concat(r.lib.WordArray.random(i-1)).concat(r.lib.WordArray.create([i<<24],1))},unpad:function(e){var t=255&e.words[e.sigBytes-1>>>2];e.sigBytes-=t}},r.pad.Iso10126)}),Q(function(e,t){var r;e.exports=((r=ee).pad.Iso97971={pad:function(e,t){e.concat(r.lib.WordArray.create([2147483648],1)),r.pad.ZeroPadding.pad(e,t)},unpad:function(e){r.pad.ZeroPadding.unpad(e),e.sigBytes--}},r.pad.Iso97971)}),Q(function(e,t){var r;e.exports=((r=ee).pad.ZeroPadding={pad:function(e,t){var r=4*t;e.clamp(),e.sigBytes+=r-(e.sigBytes%r||r)},unpad:function(e){for(var t=e.words,r=e.sigBytes-1;!(t[r>>>2]>>>24-r%4*8&255);)r--;e.sigBytes=r+1}},r.pad.ZeroPadding)}),Q(function(e,t){var r;e.exports=((r=ee).pad.NoPadding={pad:function(){},unpad:function(){}},r.pad.NoPadding)}),Q(function(e,t){var r,n,i,o;e.exports=(i=(n=r=ee).lib.CipherParams,o=n.enc.Hex,n.format.Hex={stringify:function(e){return e.ciphertext.toString(o)},parse:function(e){var t=o.parse(e);return i.create({ciphertext:t})}},r.format.Hex)}),Q(function(e,t){var r;e.exports=(r=ee,function(){var e=r,t=e.lib.BlockCipher,n=e.algo,i=[],o=[],a=[],s=[],h=[],l=[],f=[],c=[],u=[],d=[];!function(){for(var e=[],t=0;t<256;t++)e[t]=t<128?t<<1:t<<1^283;var r=0,n=0;for(t=0;t<256;t++){var p=n^n<<1^n<<2^n<<3^n<<4;p=p>>>8^255&p^99,i[r]=p,o[p]=r;var _=e[r],g=e[_],v=e[g],w=257*e[p]^16843008*p;a[r]=w<<24|w>>>8,s[r]=w<<16|w>>>16,h[r]=w<<8|w>>>24,l[r]=w,w=16843009*v^65537*g^257*_^16843008*r,f[p]=w<<24|w>>>8,c[p]=w<<16|w>>>16,u[p]=w<<8|w>>>24,d[p]=w,r?(r=_^e[e[e[v^_]]],n^=e[e[n]]):r=n=1}}();var p=[0,1,2,4,8,16,32,64,128,27,54],_=n.AES=t.extend({_doReset:function(){if(!this._nRounds||this._keyPriorReset!==this._key){for(var e=this._keyPriorReset=this._key,t=e.words,r=e.sigBytes/4,n=4*((this._nRounds=r+6)+1),o=this._keySchedule=[],a=0;a<n;a++)if(a<r)o[a]=t[a];else{var s=o[a-1];a%r?r>6&&a%r==4&&(s=i[s>>>24]<<24|i[s>>>16&255]<<16|i[s>>>8&255]<<8|i[255&s]):(s=i[(s=s<<8|s>>>24)>>>24]<<24|i[s>>>16&255]<<16|i[s>>>8&255]<<8|i[255&s],s^=p[a/r|0]<<24),o[a]=o[a-r]^s}for(var h=this._invKeySchedule=[],l=0;l<n;l++)a=n-l,s=l%4?o[a]:o[a-4],h[l]=l<4||a<=4?s:f[i[s>>>24]]^c[i[s>>>16&255]]^u[i[s>>>8&255]]^d[i[255&s]]}},encryptBlock:function(e,t){this._doCryptBlock(e,t,this._keySchedule,a,s,h,l,i)},decryptBlock:function(e,t){var r=e[t+1];e[t+1]=e[t+3],e[t+3]=r,this._doCryptBlock(e,t,this._invKeySchedule,f,c,u,d,o),r=e[t+1],e[t+1]=e[t+3],e[t+3]=r},_doCryptBlock:function(e,t,r,n,i,o,a,s){for(var h=this._nRounds,l=e[t]^r[0],f=e[t+1]^r[1],c=e[t+2]^r[2],u=e[t+3]^r[3],d=4,p=1;p<h;p++){var _=n[l>>>24]^i[f>>>16&255]^o[c>>>8&255]^a[255&u]^r[d++],g=n[f>>>24]^i[c>>>16&255]^o[u>>>8&255]^a[255&l]^r[d++],v=n[c>>>24]^i[u>>>16&255]^o[l>>>8&255]^a[255&f]^r[d++],w=n[u>>>24]^i[l>>>16&255]^o[f>>>8&255]^a[255&c]^r[d++];l=_,f=g,c=v,u=w}_=(s[l>>>24]<<24|s[f>>>16&255]<<16|s[c>>>8&255]<<8|s[255&u])^r[d++],g=(s[f>>>24]<<24|s[c>>>16&255]<<16|s[u>>>8&255]<<8|s[255&l])^r[d++],v=(s[c>>>24]<<24|s[u>>>16&255]<<16|s[l>>>8&255]<<8|s[255&f])^r[d++],w=(s[u>>>24]<<24|s[l>>>16&255]<<16|s[f>>>8&255]<<8|s[255&c])^r[d++],e[t]=_,e[t+1]=g,e[t+2]=v,e[t+3]=w},keySize:8});e.AES=t._createHelper(_)}(),r.AES)}),Q(function(e,t){var r;e.exports=(r=ee,function(){var e=r,t=e.lib,n=t.WordArray,i=t.BlockCipher,o=e.algo,a=[57,49,41,33,25,17,9,1,58,50,42,34,26,18,10,2,59,51,43,35,27,19,11,3,60,52,44,36,63,55,47,39,31,23,15,7,62,54,46,38,30,22,14,6,61,53,45,37,29,21,13,5,28,20,12,4],s=[14,17,11,24,1,5,3,28,15,6,21,10,23,19,12,4,26,8,16,7,27,20,13,2,41,52,31,37,47,55,30,40,51,45,33,48,44,49,39,56,34,53,46,42,50,36,29,32],h=[1,2,4,6,8,10,12,14,15,17,19,21,23,25,27,28],l=[{0:8421888,268435456:32768,536870912:8421378,805306368:2,1073741824:512,1342177280:8421890,1610612736:8389122,1879048192:8388608,2147483648:514,2415919104:8389120,2684354560:33280,2952790016:8421376,3221225472:32770,3489660928:8388610,3758096384:0,4026531840:33282,134217728:0,402653184:8421890,671088640:33282,939524096:32768,1207959552:8421888,1476395008:512,1744830464:8421378,2013265920:2,2281701376:8389120,2550136832:33280,2818572288:8421376,3087007744:8389122,3355443200:8388610,3623878656:32770,3892314112:514,4160749568:8388608,1:32768,268435457:2,536870913:8421888,805306369:8388608,1073741825:8421378,1342177281:33280,1610612737:512,1879048193:8389122,2147483649:8421890,2415919105:8421376,2684354561:8388610,2952790017:33282,3221225473:514,3489660929:8389120,3758096385:32770,4026531841:0,134217729:8421890,402653185:8421376,671088641:8388608,939524097:512,1207959553:32768,1476395009:8388610,1744830465:2,2013265921:33282,2281701377:32770,2550136833:8389122,2818572289:514,3087007745:8421888,3355443201:8389120,3623878657:0,3892314113:33280,4160749569:8421378},{0:1074282512,16777216:16384,33554432:524288,50331648:1074266128,67108864:1073741840,83886080:1074282496,100663296:1073758208,117440512:16,134217728:540672,150994944:1073758224,167772160:1073741824,184549376:540688,201326592:524304,218103808:0,234881024:16400,251658240:1074266112,8388608:1073758208,25165824:540688,41943040:16,58720256:1073758224,75497472:1074282512,92274688:1073741824,109051904:524288,125829120:1074266128,142606336:524304,159383552:0,176160768:16384,192937984:1074266112,209715200:1073741840,226492416:540672,243269632:1074282496,260046848:16400,268435456:0,285212672:1074266128,301989888:1073758224,318767104:1074282496,335544320:1074266112,352321536:16,369098752:540688,385875968:16384,402653184:16400,419430400:524288,436207616:524304,452984832:1073741840,469762048:540672,486539264:1073758208,503316480:1073741824,520093696:1074282512,276824064:540688,293601280:524288,310378496:1074266112,327155712:16384,343932928:1073758208,360710144:1074282512,377487360:16,394264576:1073741824,411041792:1074282496,427819008:1073741840,444596224:1073758224,461373440:524304,478150656:0,494927872:16400,511705088:1074266128,528482304:540672},{0:260,1048576:0,2097152:67109120,3145728:65796,4194304:65540,5242880:67108868,6291456:67174660,7340032:67174400,8388608:67108864,9437184:67174656,10485760:65792,11534336:67174404,12582912:67109124,13631488:65536,14680064:4,15728640:256,524288:67174656,1572864:67174404,2621440:0,3670016:67109120,4718592:67108868,5767168:65536,6815744:65540,7864320:260,8912896:4,9961472:256,11010048:67174400,12058624:65796,13107200:65792,14155776:67109124,15204352:67174660,16252928:67108864,16777216:67174656,17825792:65540,18874368:65536,19922944:67109120,20971520:256,22020096:67174660,23068672:67108868,24117248:0,25165824:67109124,26214400:67108864,27262976:4,28311552:65792,29360128:67174400,30408704:260,31457280:65796,32505856:67174404,17301504:67108864,18350080:260,19398656:67174656,20447232:0,21495808:65540,22544384:67109120,23592960:256,24641536:67174404,25690112:65536,26738688:67174660,27787264:65796,28835840:67108868,29884416:67109124,30932992:67174400,31981568:4,33030144:65792},{0:2151682048,65536:2147487808,131072:4198464,196608:2151677952,262144:0,327680:4198400,393216:2147483712,458752:4194368,524288:2147483648,589824:4194304,655360:64,720896:2147487744,786432:2151678016,851968:4160,917504:4096,983040:2151682112,32768:2147487808,98304:64,163840:2151678016,229376:2147487744,294912:4198400,360448:2151682112,425984:0,491520:2151677952,557056:4096,622592:2151682048,688128:4194304,753664:4160,819200:2147483648,884736:4194368,950272:4198464,1015808:2147483712,1048576:4194368,1114112:4198400,1179648:2147483712,1245184:0,1310720:4160,1376256:2151678016,1441792:2151682048,1507328:2147487808,1572864:2151682112,1638400:2147483648,1703936:2151677952,1769472:4198464,1835008:2147487744,1900544:4194304,1966080:64,2031616:4096,1081344:2151677952,1146880:2151682112,1212416:0,1277952:4198400,1343488:4194368,1409024:2147483648,1474560:2147487808,1540096:64,1605632:2147483712,1671168:4096,1736704:2147487744,1802240:2151678016,1867776:4160,1933312:2151682048,1998848:4194304,2064384:4198464},{0:128,4096:17039360,8192:262144,12288:536870912,16384:537133184,20480:16777344,24576:553648256,28672:262272,32768:16777216,36864:537133056,40960:536871040,45056:553910400,49152:553910272,53248:0,57344:17039488,61440:553648128,2048:17039488,6144:553648256,10240:128,14336:17039360,18432:262144,22528:537133184,26624:553910272,30720:536870912,34816:537133056,38912:0,43008:553910400,47104:16777344,51200:536871040,55296:553648128,59392:16777216,63488:262272,65536:262144,69632:128,73728:536870912,77824:553648256,81920:16777344,86016:553910272,90112:537133184,94208:16777216,98304:553910400,102400:553648128,106496:17039360,110592:537133056,114688:262272,118784:536871040,122880:0,126976:17039488,67584:553648256,71680:16777216,75776:17039360,79872:537133184,83968:536870912,88064:17039488,92160:128,96256:553910272,100352:262272,104448:553910400,108544:0,112640:553648128,116736:16777344,120832:262144,124928:537133056,129024:536871040},{0:268435464,256:8192,512:270532608,768:270540808,1024:268443648,1280:2097152,1536:2097160,1792:268435456,2048:0,2304:268443656,2560:2105344,2816:8,3072:270532616,3328:2105352,3584:8200,3840:270540800,128:270532608,384:270540808,640:8,896:2097152,1152:2105352,1408:268435464,1664:268443648,1920:8200,2176:2097160,2432:8192,2688:268443656,2944:270532616,3200:0,3456:270540800,3712:2105344,3968:268435456,4096:268443648,4352:270532616,4608:270540808,4864:8200,5120:2097152,5376:268435456,5632:268435464,5888:2105344,6144:2105352,6400:0,6656:8,6912:270532608,7168:8192,7424:268443656,7680:270540800,7936:2097160,4224:8,4480:2105344,4736:2097152,4992:268435464,5248:268443648,5504:8200,5760:270540808,6016:270532608,6272:270540800,6528:270532616,6784:8192,7040:2105352,7296:2097160,7552:0,7808:268435456,8064:268443656},{0:1048576,16:33555457,32:1024,48:1049601,64:34604033,80:0,96:1,112:34603009,128:33555456,144:1048577,160:33554433,176:34604032,192:34603008,208:1025,224:1049600,240:33554432,8:34603009,24:0,40:33555457,56:34604032,72:1048576,88:33554433,104:33554432,120:1025,136:1049601,152:33555456,168:34603008,184:1048577,200:1024,216:34604033,232:1,248:1049600,256:33554432,272:1048576,288:33555457,304:34603009,320:1048577,336:33555456,352:34604032,368:1049601,384:1025,400:34604033,416:1049600,432:1,448:0,464:34603008,480:33554433,496:1024,264:1049600,280:33555457,296:34603009,312:1,328:33554432,344:1048576,360:1025,376:34604032,392:33554433,408:34603008,424:0,440:34604033,456:1049601,472:1024,488:33555456,504:1048577},{0:134219808,1:131072,2:134217728,3:32,4:131104,5:134350880,6:134350848,7:2048,8:134348800,9:134219776,10:133120,11:134348832,12:2080,13:0,14:134217760,15:133152,2147483648:2048,2147483649:134350880,2147483650:134219808,2147483651:134217728,2147483652:134348800,2147483653:133120,2147483654:133152,2147483655:32,2147483656:134217760,2147483657:2080,2147483658:131104,2147483659:134350848,2147483660:0,2147483661:134348832,2147483662:134219776,2147483663:131072,16:133152,17:134350848,18:32,19:2048,20:134219776,21:134217760,22:134348832,23:131072,24:0,25:131104,26:134348800,27:134219808,28:134350880,29:133120,30:2080,31:134217728,2147483664:131072,2147483665:2048,2147483666:134348832,2147483667:133152,2147483668:32,2147483669:134348800,2147483670:134217728,2147483671:134219808,2147483672:134350880,2147483673:134217760,2147483674:134219776,2147483675:0,2147483676:133120,2147483677:2080,2147483678:131104,2147483679:134350848}],f=[4160749569,528482304,33030144,2064384,129024,8064,504,2147483679],c=o.DES=i.extend({_doReset:function(){for(var e=this._key.words,t=[],r=0;r<56;r++){var n=a[r]-1;t[r]=e[n>>>5]>>>31-n%32&1}for(var i=this._subKeys=[],o=0;o<16;o++){var l=i[o]=[],f=h[o];for(r=0;r<24;r++)l[r/6|0]|=t[(s[r]-1+f)%28]<<31-r%6,l[4+(r/6|0)]|=t[28+(s[r+24]-1+f)%28]<<31-r%6;for(l[0]=l[0]<<1|l[0]>>>31,r=1;r<7;r++)l[r]=l[r]>>>4*(r-1)+3;l[7]=l[7]<<5|l[7]>>>27}var c=this._invSubKeys=[];for(r=0;r<16;r++)c[r]=i[15-r]},encryptBlock:function(e,t){this._doCryptBlock(e,t,this._subKeys)},decryptBlock:function(e,t){this._doCryptBlock(e,t,this._invSubKeys)},_doCryptBlock:function(e,t,r){this._lBlock=e[t],this._rBlock=e[t+1],u.call(this,4,252645135),u.call(this,16,65535),d.call(this,2,858993459),d.call(this,8,16711935),u.call(this,1,1431655765);for(var n=0;n<16;n++){for(var i=r[n],o=this._lBlock,a=this._rBlock,s=0,h=0;h<8;h++)s|=l[h][((a^i[h])&f[h])>>>0];this._lBlock=a,this._rBlock=o^s}var c=this._lBlock;this._lBlock=this._rBlock,this._rBlock=c,u.call(this,1,1431655765),d.call(this,8,16711935),d.call(this,2,858993459),u.call(this,16,65535),u.call(this,4,252645135),e[t]=this._lBlock,e[t+1]=this._rBlock},keySize:2,ivSize:2,blockSize:2});function u(e,t){var r=(this._lBlock>>>e^this._rBlock)&t;this._rBlock^=r,this._lBlock^=r<<e}function d(e,t){var r=(this._rBlock>>>e^this._lBlock)&t;this._lBlock^=r,this._rBlock^=r<<e}e.DES=i._createHelper(c);var p=o.TripleDES=i.extend({_doReset:function(){var e=this._key.words;this._des1=c.createEncryptor(n.create(e.slice(0,2))),this._des2=c.createEncryptor(n.create(e.slice(2,4))),this._des3=c.createEncryptor(n.create(e.slice(4,6)))},encryptBlock:function(e,t){this._des1.encryptBlock(e,t),this._des2.decryptBlock(e,t),this._des3.encryptBlock(e,t)},decryptBlock:function(e,t){this._des3.decryptBlock(e,t),this._des2.encryptBlock(e,t),this._des1.decryptBlock(e,t)},keySize:6,ivSize:2,blockSize:2});e.TripleDES=i._createHelper(p)}(),r.TripleDES)}),Q(function(e,t){var r;e.exports=(r=ee,function(){var e=r,t=e.lib.StreamCipher,n=e.algo,i=n.RC4=t.extend({_doReset:function(){for(var e=this._key,t=e.words,r=e.sigBytes,n=this._S=[],i=0;i<256;i++)n[i]=i;i=0;for(var o=0;i<256;i++){var a=i%r,s=t[a>>>2]>>>24-a%4*8&255;o=(o+n[i]+s)%256;var h=n[i];n[i]=n[o],n[o]=h}this._i=this._j=0},_doProcessBlock:function(e,t){e[t]^=o.call(this)},keySize:8,ivSize:0});function o(){for(var e=this._S,t=this._i,r=this._j,n=0,i=0;i<4;i++){r=(r+e[t=(t+1)%256])%256;var o=e[t];e[t]=e[r],e[r]=o,n|=e[(e[t]+e[r])%256]<<24-8*i}return this._i=t,this._j=r,n}e.RC4=t._createHelper(i);var a=n.RC4Drop=i.extend({cfg:i.cfg.extend({drop:192}),_doReset:function(){i._doReset.call(this);for(var e=this.cfg.drop;e>0;e--)o.call(this)}});e.RC4Drop=t._createHelper(a)}(),r.RC4)}),Q(function(e,t){var r;e.exports=(r=ee,function(){var e=r,t=e.lib.StreamCipher,n=e.algo,i=[],o=[],a=[],s=n.Rabbit=t.extend({_doReset:function(){for(var e=this._key.words,t=this.cfg.iv,r=0;r<4;r++)e[r]=16711935&(e[r]<<8|e[r]>>>24)|4278255360&(e[r]<<24|e[r]>>>8);var n=this._X=[e[0],e[3]<<16|e[2]>>>16,e[1],e[0]<<16|e[3]>>>16,e[2],e[1]<<16|e[0]>>>16,e[3],e[2]<<16|e[1]>>>16],i=this._C=[e[2]<<16|e[2]>>>16,4294901760&e[0]|65535&e[1],e[3]<<16|e[3]>>>16,4294901760&e[1]|65535&e[2],e[0]<<16|e[0]>>>16,4294901760&e[2]|65535&e[3],e[1]<<16|e[1]>>>16,4294901760&e[3]|65535&e[0]];for(this._b=0,r=0;r<4;r++)h.call(this);for(r=0;r<8;r++)i[r]^=n[r+4&7];if(t){var o=t.words,a=o[0],s=o[1],l=16711935&(a<<8|a>>>24)|4278255360&(a<<24|a>>>8),f=16711935&(s<<8|s>>>24)|4278255360&(s<<24|s>>>8),c=l>>>16|4294901760&f,u=f<<16|65535&l;for(i[0]^=l,i[1]^=c,i[2]^=f,i[3]^=u,i[4]^=l,i[5]^=c,i[6]^=f,i[7]^=u,r=0;r<4;r++)h.call(this)}},_doProcessBlock:function(e,t){var r=this._X;h.call(this),i[0]=r[0]^r[5]>>>16^r[3]<<16,i[1]=r[2]^r[7]>>>16^r[5]<<16,i[2]=r[4]^r[1]>>>16^r[7]<<16,i[3]=r[6]^r[3]>>>16^r[1]<<16;for(var n=0;n<4;n++)i[n]=16711935&(i[n]<<8|i[n]>>>24)|4278255360&(i[n]<<24|i[n]>>>8),e[t+n]^=i[n]},blockSize:4,ivSize:2});function h(){for(var e=this._X,t=this._C,r=0;r<8;r++)o[r]=t[r];for(t[0]=t[0]+1295307597+this._b|0,t[1]=t[1]+3545052371+(t[0]>>>0<o[0]>>>0?1:0)|0,t[2]=t[2]+886263092+(t[1]>>>0<o[1]>>>0?1:0)|0,t[3]=t[3]+1295307597+(t[2]>>>0<o[2]>>>0?1:0)|0,t[4]=t[4]+3545052371+(t[3]>>>0<o[3]>>>0?1:0)|0,t[5]=t[5]+886263092+(t[4]>>>0<o[4]>>>0?1:0)|0,t[6]=t[6]+1295307597+(t[5]>>>0<o[5]>>>0?1:0)|0,t[7]=t[7]+3545052371+(t[6]>>>0<o[6]>>>0?1:0)|0,this._b=t[7]>>>0<o[7]>>>0?1:0,r=0;r<8;r++){var n=e[r]+t[r],i=65535&n,s=n>>>16,h=((i*i>>>17)+i*s>>>15)+s*s,l=((4294901760&n)*n|0)+((65535&n)*n|0);a[r]=h^l}e[0]=a[0]+(a[7]<<16|a[7]>>>16)+(a[6]<<16|a[6]>>>16)|0,e[1]=a[1]+(a[0]<<8|a[0]>>>24)+a[7]|0,e[2]=a[2]+(a[1]<<16|a[1]>>>16)+(a[0]<<16|a[0]>>>16)|0,e[3]=a[3]+(a[2]<<8|a[2]>>>24)+a[1]|0,e[4]=a[4]+(a[3]<<16|a[3]>>>16)+(a[2]<<16|a[2]>>>16)|0,e[5]=a[5]+(a[4]<<8|a[4]>>>24)+a[3]|0,e[6]=a[6]+(a[5]<<16|a[5]>>>16)+(a[4]<<16|a[4]>>>16)|0,e[7]=a[7]+(a[6]<<8|a[6]>>>24)+a[5]|0}e.Rabbit=t._createHelper(s)}(),r.Rabbit)}),Q(function(e,t){var r;e.exports=(r=ee,function(){var e=r,t=e.lib.StreamCipher,n=e.algo,i=[],o=[],a=[],s=n.RabbitLegacy=t.extend({_doReset:function(){var e=this._key.words,t=this.cfg.iv,r=this._X=[e[0],e[3]<<16|e[2]>>>16,e[1],e[0]<<16|e[3]>>>16,e[2],e[1]<<16|e[0]>>>16,e[3],e[2]<<16|e[1]>>>16],n=this._C=[e[2]<<16|e[2]>>>16,4294901760&e[0]|65535&e[1],e[3]<<16|e[3]>>>16,4294901760&e[1]|65535&e[2],e[0]<<16|e[0]>>>16,4294901760&e[2]|65535&e[3],e[1]<<16|e[1]>>>16,4294901760&e[3]|65535&e[0]];this._b=0;for(var i=0;i<4;i++)h.call(this);for(i=0;i<8;i++)n[i]^=r[i+4&7];if(t){var o=t.words,a=o[0],s=o[1],l=16711935&(a<<8|a>>>24)|4278255360&(a<<24|a>>>8),f=16711935&(s<<8|s>>>24)|4278255360&(s<<24|s>>>8),c=l>>>16|4294901760&f,u=f<<16|65535&l;for(n[0]^=l,n[1]^=c,n[2]^=f,n[3]^=u,n[4]^=l,n[5]^=c,n[6]^=f,n[7]^=u,i=0;i<4;i++)h.call(this)}},_doProcessBlock:function(e,t){var r=this._X;h.call(this),i[0]=r[0]^r[5]>>>16^r[3]<<16,i[1]=r[2]^r[7]>>>16^r[5]<<16,i[2]=r[4]^r[1]>>>16^r[7]<<16,i[3]=r[6]^r[3]>>>16^r[1]<<16;for(var n=0;n<4;n++)i[n]=16711935&(i[n]<<8|i[n]>>>24)|4278255360&(i[n]<<24|i[n]>>>8),e[t+n]^=i[n]},blockSize:4,ivSize:2});function h(){for(var e=this._X,t=this._C,r=0;r<8;r++)o[r]=t[r];for(t[0]=t[0]+1295307597+this._b|0,t[1]=t[1]+3545052371+(t[0]>>>0<o[0]>>>0?1:0)|0,t[2]=t[2]+886263092+(t[1]>>>0<o[1]>>>0?1:0)|0,t[3]=t[3]+1295307597+(t[2]>>>0<o[2]>>>0?1:0)|0,t[4]=t[4]+3545052371+(t[3]>>>0<o[3]>>>0?1:0)|0,t[5]=t[5]+886263092+(t[4]>>>0<o[4]>>>0?1:0)|0,t[6]=t[6]+1295307597+(t[5]>>>0<o[5]>>>0?1:0)|0,t[7]=t[7]+3545052371+(t[6]>>>0<o[6]>>>0?1:0)|0,this._b=t[7]>>>0<o[7]>>>0?1:0,r=0;r<8;r++){var n=e[r]+t[r],i=65535&n,s=n>>>16,h=((i*i>>>17)+i*s>>>15)+s*s,l=((4294901760&n)*n|0)+((65535&n)*n|0);a[r]=h^l}e[0]=a[0]+(a[7]<<16|a[7]>>>16)+(a[6]<<16|a[6]>>>16)|0,e[1]=a[1]+(a[0]<<8|a[0]>>>24)+a[7]|0,e[2]=a[2]+(a[1]<<16|a[1]>>>16)+(a[0]<<16|a[0]>>>16)|0,e[3]=a[3]+(a[2]<<8|a[2]>>>24)+a[1]|0,e[4]=a[4]+(a[3]<<16|a[3]>>>16)+(a[2]<<16|a[2]>>>16)|0,e[5]=a[5]+(a[4]<<8|a[4]>>>24)+a[3]|0,e[6]=a[6]+(a[5]<<16|a[5]>>>16)+(a[4]<<16|a[4]>>>16)|0,e[7]=a[7]+(a[6]<<8|a[6]>>>24)+a[5]|0}e.RabbitLegacy=t._createHelper(s)}(),r.RabbitLegacy)}),Q(function(e,t){e.exports=ee}));function re(){throw new Error("setTimeout has not been defined")}function ne(){throw new Error("clearTimeout has not been defined")}var ie=re,oe=ne;function ae(e){if(ie===setTimeout)return setTimeout(e,0);if((ie===re||!ie)&&setTimeout)return ie=setTimeout,setTimeout(e,0);try{return ie(e,0)}catch(t){try{return ie.call(null,e,0)}catch(t){return ie.call(this,e,0)}}}"function"==typeof e.setTimeout&&(ie=setTimeout),"function"==typeof e.clearTimeout&&(oe=clearTimeout);var se,he=[],le=!1,fe=-1;function ce(){le&&se&&(le=!1,se.length?he=se.concat(he):fe=-1,he.length&&ue())}function ue(){if(!le){var e=ae(ce);le=!0;for(var t=he.length;t;){for(se=he,he=[];++fe<t;)se&&se[fe].run();fe=-1,t=he.length}se=null,le=!1,function(e){if(oe===clearTimeout)return clearTimeout(e);if((oe===ne||!oe)&&clearTimeout)return oe=clearTimeout,clearTimeout(e);try{oe(e)}catch(t){try{return oe.call(null,e)}catch(t){return oe.call(this,e)}}}(e)}}function de(e){var t=new Array(arguments.length-1);if(arguments.length>1)for(var r=1;r<arguments.length;r++)t[r-1]=arguments[r];he.push(new pe(e,t)),1!==he.length||le||ae(ue)}function pe(e,t){this.fun=e,this.array=t}pe.prototype.run=function(){this.fun.apply(null,this.array)};var _e=e.performance||{};_e.now||_e.mozNow||_e.msNow||_e.oNow||_e.webkitNow;function ge(){}function ve(){ve.init.call(this)}function we(e){return void 0===e._maxListeners?ve.defaultMaxListeners:e._maxListeners}function be(e,t,r){if(t)e.call(r);else for(var n=e.length,i=Ae(e,n),o=0;o<n;++o)i[o].call(r)}function ye(e,t,r,n){if(t)e.call(r,n);else for(var i=e.length,o=Ae(e,i),a=0;a<i;++a)o[a].call(r,n)}function me(e,t,r,n,i){if(t)e.call(r,n,i);else for(var o=e.length,a=Ae(e,o),s=0;s<o;++s)a[s].call(r,n,i)}function ke(e,t,r,n,i,o){if(t)e.call(r,n,i,o);else for(var a=e.length,s=Ae(e,a),h=0;h<a;++h)s[h].call(r,n,i,o)}function Ee(e,t,r,n){if(t)e.apply(r,n);else for(var i=e.length,o=Ae(e,i),a=0;a<i;++a)o[a].apply(r,n)}function Se(e,t,r,n){var i,o,a,s;if("function"!=typeof r)throw new TypeError('"listener" argument must be a function');if((o=e._events)?(o.newListener&&(e.emit("newListener",t,r.listener?r.listener:r),o=e._events),a=o[t]):(o=e._events=new ge,e._eventsCount=0),a){if("function"==typeof a?a=o[t]=n?[r,a]:[a,r]:n?a.unshift(r):a.push(r),!a.warned&&(i=we(e))&&i>0&&a.length>i){a.warned=!0;var h=new Error("Possible EventEmitter memory leak detected. "+a.length+" "+t+" listeners added. Use emitter.setMaxListeners() to increase limit");h.name="MaxListenersExceededWarning",h.emitter=e,h.type=t,h.count=a.length,s=h,"function"==typeof console.warn?console.warn(s):console.log(s)}}else a=o[t]=r,++e._eventsCount;return e}function xe(e,t,r){var n=!1;function i(){e.removeListener(t,i),n||(n=!0,r.apply(e,arguments))}return i.listener=r,i}function Re(e){var t=this._events;if(t){var r=t[e];if("function"==typeof r)return 1;if(r)return r.length}return 0}function Ae(e,t){for(var r=new Array(t);t--;)r[t]=e[t];return r}ge.prototype=Object.create(null),ve.EventEmitter=ve,ve.usingDomains=!1,ve.prototype.domain=void 0,ve.prototype._events=void 0,ve.prototype._maxListeners=void 0,ve.defaultMaxListeners=10,ve.init=function(){this.domain=null,ve.usingDomains&&(void 0).active&&(void 0).Domain,this._events&&this._events!==Object.getPrototypeOf(this)._events||(this._events=new ge,this._eventsCount=0),this._maxListeners=this._maxListeners||void 0},ve.prototype.setMaxListeners=function(e){if("number"!=typeof e||e<0||isNaN(e))throw new TypeError('"n" argument must be a positive number');return this._maxListeners=e,this},ve.prototype.getMaxListeners=function(){return we(this)},ve.prototype.emit=function(e){var t,r,n,i,o,a,s,h="error"===e;if(a=this._events)h=h&&null==a.error;else if(!h)return!1;if(s=this.domain,h){if(t=arguments[1],!s){if(t instanceof Error)throw t;var l=new Error('Uncaught, unspecified "error" event. ('+t+")");throw l.context=t,l}return t||(t=new Error('Uncaught, unspecified "error" event')),t.domainEmitter=this,t.domain=s,t.domainThrown=!1,s.emit("error",t),!1}if(!(r=a[e]))return!1;var f="function"==typeof r;switch(n=arguments.length){case 1:be(r,f,this);break;case 2:ye(r,f,this,arguments[1]);break;case 3:me(r,f,this,arguments[1],arguments[2]);break;case 4:ke(r,f,this,arguments[1],arguments[2],arguments[3]);break;default:for(i=new Array(n-1),o=1;o<n;o++)i[o-1]=arguments[o];Ee(r,f,this,i)}return!0},ve.prototype.addListener=function(e,t){return Se(this,e,t,!1)},ve.prototype.on=ve.prototype.addListener,ve.prototype.prependListener=function(e,t){return Se(this,e,t,!0)},ve.prototype.once=function(e,t){if("function"!=typeof t)throw new TypeError('"listener" argument must be a function');return this.on(e,xe(this,e,t)),this},ve.prototype.prependOnceListener=function(e,t){if("function"!=typeof t)throw new TypeError('"listener" argument must be a function');return this.prependListener(e,xe(this,e,t)),this},ve.prototype.removeListener=function(e,t){var r,n,i,o,a;if("function"!=typeof t)throw new TypeError('"listener" argument must be a function');if(!(n=this._events))return this;if(!(r=n[e]))return this;if(r===t||r.listener&&r.listener===t)0==--this._eventsCount?this._events=new ge:(delete n[e],n.removeListener&&this.emit("removeListener",e,r.listener||t));else if("function"!=typeof r){for(i=-1,o=r.length;o-- >0;)if(r[o]===t||r[o].listener&&r[o].listener===t){a=r[o].listener,i=o;break}if(i<0)return this;if(1===r.length){if(r[0]=void 0,0==--this._eventsCount)return this._events=new ge,this;delete n[e]}else!function(e,t){for(var r=t,n=r+1,i=e.length;n<i;r+=1,n+=1)e[r]=e[n];e.pop()}(r,i);n.removeListener&&this.emit("removeListener",e,a||t)}return this},ve.prototype.removeAllListeners=function(e){var t,r;if(!(r=this._events))return this;if(!r.removeListener)return 0===arguments.length?(this._events=new ge,this._eventsCount=0):r[e]&&(0==--this._eventsCount?this._events=new ge:delete r[e]),this;if(0===arguments.length){for(var n,i=Object.keys(r),o=0;o<i.length;++o)"removeListener"!==(n=i[o])&&this.removeAllListeners(n);return this.removeAllListeners("removeListener"),this._events=new ge,this._eventsCount=0,this}if("function"==typeof(t=r[e]))this.removeListener(e,t);else if(t)do{this.removeListener(e,t[t.length-1])}while(t[0]);return this},ve.prototype.listeners=function(e){var t,r=this._events;return r&&(t=r[e])?"function"==typeof t?[t.listener||t]:function(e){for(var t=new Array(e.length),r=0;r<t.length;++r)t[r]=e[r].listener||e[r];return t}(t):[]},ve.listenerCount=function(e,t){return"function"==typeof e.listenerCount?e.listenerCount(t):Re.call(e,t)},ve.prototype.listenerCount=Re,ve.prototype.eventNames=function(){return this._eventsCount>0?Reflect.ownKeys(this._events):[]};var Be="function"==typeof Object.create?function(e,t){e.super_=t,e.prototype=Object.create(t.prototype,{constructor:{value:e,enumerable:!1,writable:!0,configurable:!0}})}:function(e,t){e.super_=t;var r=function(){};r.prototype=t.prototype,e.prototype=new r,e.prototype.constructor=e},ze=/%[sdj%]/g;function Le(e){if(!Ze(e)){for(var t=[],r=0;r<arguments.length;r++)t.push(De(arguments[r]));return t.join(" ")}r=1;for(var n=arguments,i=n.length,o=String(e).replace(ze,function(e){if("%%"===e)return"%";if(r>=i)return e;switch(e){case"%s":return String(n[r++]);case"%d":return Number(n[r++]);case"%j":try{return JSON.stringify(n[r++])}catch(e){return"[Circular]"}default:return e}}),a=n[r];r<i;a=n[++r])Ne(a)||!Ye(a)?o+=" "+a:o+=" "+De(a);return o}function Te(t,r){if(je(e.process))return function(){return Te(t,r).apply(this,arguments)};var n=!1;return function(){return n||(console.error(r),n=!0),t.apply(this,arguments)}}var Me,Ce={};function De(e,t){var r={seen:[],stylize:Pe};return arguments.length>=3&&(r.depth=arguments[2]),arguments.length>=4&&(r.colors=arguments[3]),Fe(t)?r.showHidden=t:t&&function(e,t){if(!t||!Ye(t))return e;var r=Object.keys(t),n=r.length;for(;n--;)e[r[n]]=t[r[n]]}(r,t),je(r.showHidden)&&(r.showHidden=!1),je(r.depth)&&(r.depth=2),je(r.colors)&&(r.colors=!1),je(r.customInspect)&&(r.customInspect=!0),r.colors&&(r.stylize=Ie),Oe(r,e,r.depth)}function Ie(e,t){var r=De.styles[t];return r?"["+De.colors[r][0]+"m"+e+"["+De.colors[r][1]+"m":e}function Pe(e,t){return e}function Oe(e,t,r){if(e.customInspect&&t&&qe(t.inspect)&&t.inspect!==De&&(!t.constructor||t.constructor.prototype!==t)){var n=t.inspect(r,e);return Ze(n)||(n=Oe(e,n,r)),n}var i=function(e,t){if(je(t))return e.stylize("undefined","undefined");if(Ze(t)){var r="'"+JSON.stringify(t).replace(/^"|"$/g,"").replace(/'/g,"\\'").replace(/\\"/g,'"')+"'";return e.stylize(r,"string")}if(n=t,"number"==typeof n)return e.stylize(""+t,"number");var n;if(Fe(t))return e.stylize(""+t,"boolean");if(Ne(t))return e.stylize("null","null")}(e,t);if(i)return i;var o=Object.keys(t),a=function(e){var t={};return e.forEach(function(e,r){t[e]=!0}),t}(o);if(e.showHidden&&(o=Object.getOwnPropertyNames(t)),Xe(t)&&(o.indexOf("message")>=0||o.indexOf("description")>=0))return Ue(t);if(0===o.length){if(qe(t)){var s=t.name?": "+t.name:"";return e.stylize("[Function"+s+"]","special")}if(We(t))return e.stylize(RegExp.prototype.toString.call(t),"regexp");if(Ke(t))return e.stylize(Date.prototype.toString.call(t),"date");if(Xe(t))return Ue(t)}var h,l,f="",c=!1,u=["{","}"];(h=t,Array.isArray(h)&&(c=!0,u=["[","]"]),qe(t))&&(f=" [Function"+(t.name?": "+t.name:"")+"]");return We(t)&&(f=" "+RegExp.prototype.toString.call(t)),Ke(t)&&(f=" "+Date.prototype.toUTCString.call(t)),Xe(t)&&(f=" "+Ue(t)),0!==o.length||c&&0!=t.length?r<0?We(t)?e.stylize(RegExp.prototype.toString.call(t),"regexp"):e.stylize("[Object]","special"):(e.seen.push(t),l=c?function(e,t,r,n,i){for(var o=[],a=0,s=t.length;a<s;++a)Ge(t,String(a))?o.push(He(e,t,r,n,String(a),!0)):o.push("");return i.forEach(function(i){i.match(/^\d+$/)||o.push(He(e,t,r,n,i,!0))}),o}(e,t,r,a,o):o.map(function(n){return He(e,t,r,a,n,c)}),e.seen.pop(),function(e,t,r){if(e.reduce(function(e,t){return t.indexOf("\n"),e+t.replace(/\u001b\[\d\d?m/g,"").length+1},0)>60)return r[0]+(""===t?"":t+"\n ")+" "+e.join(",\n  ")+" "+r[1];return r[0]+t+" "+e.join(", ")+" "+r[1]}(l,f,u)):u[0]+f+u[1]}function Ue(e){return"["+Error.prototype.toString.call(e)+"]"}function He(e,t,r,n,i,o){var a,s,h;if((h=Object.getOwnPropertyDescriptor(t,i)||{value:t[i]}).get?s=h.set?e.stylize("[Getter/Setter]","special"):e.stylize("[Getter]","special"):h.set&&(s=e.stylize("[Setter]","special")),Ge(n,i)||(a="["+i+"]"),s||(e.seen.indexOf(h.value)<0?(s=Ne(r)?Oe(e,h.value,null):Oe(e,h.value,r-1)).indexOf("\n")>-1&&(s=o?s.split("\n").map(function(e){return"  "+e}).join("\n").substr(2):"\n"+s.split("\n").map(function(e){return"   "+e}).join("\n")):s=e.stylize("[Circular]","special")),je(a)){if(o&&i.match(/^\d+$/))return s;(a=JSON.stringify(""+i)).match(/^"([a-zA-Z_][a-zA-Z_0-9]*)"$/)?(a=a.substr(1,a.length-2),a=e.stylize(a,"name")):(a=a.replace(/'/g,"\\'").replace(/\\"/g,'"').replace(/(^"|"$)/g,"'"),a=e.stylize(a,"string"))}return a+": "+s}function Fe(e){return"boolean"==typeof e}function Ne(e){return null===e}function Ze(e){return"string"==typeof e}function je(e){return void 0===e}function We(e){return Ye(e)&&"[object RegExp]"===Ve(e)}function Ye(e){return"object"==typeof e&&null!==e}function Ke(e){return Ye(e)&&"[object Date]"===Ve(e)}function Xe(e){return Ye(e)&&("[object Error]"===Ve(e)||e instanceof Error)}function qe(e){return"function"==typeof e}function Ve(e){return Object.prototype.toString.call(e)}function Ge(e,t){return Object.prototype.hasOwnProperty.call(e,t)}function $e(){this.head=null,this.tail=null,this.length=0}De.colors={bold:[1,22],italic:[3,23],underline:[4,24],inverse:[7,27],white:[37,39],grey:[90,39],black:[30,39],blue:[34,39],cyan:[36,39],green:[32,39],magenta:[35,39],red:[31,39],yellow:[33,39]},De.styles={special:"cyan",number:"yellow",boolean:"yellow",undefined:"grey",null:"bold",string:"green",date:"magenta",regexp:"red"},$e.prototype.push=function(e){var t={data:e,next:null};this.length>0?this.tail.next=t:this.head=t,this.tail=t,++this.length},$e.prototype.unshift=function(e){var t={data:e,next:this.head};0===this.length&&(this.tail=t),this.head=t,++this.length},$e.prototype.shift=function(){if(0!==this.length){var e=this.head.data;return 1===this.length?this.head=this.tail=null:this.head=this.head.next,--this.length,e}},$e.prototype.clear=function(){this.head=this.tail=null,this.length=0},$e.prototype.join=function(e){if(0===this.length)return"";for(var t=this.head,r=""+t.data;t=t.next;)r+=e+t.data;return r},$e.prototype.concat=function(e){if(0===this.length)return p.alloc(0);if(1===this.length)return this.head.data;for(var t=p.allocUnsafe(e>>>0),r=this.head,n=0;r;)r.data.copy(t,n),n+=r.data.length,r=r.next;return t};var Je=p.isEncoding||function(e){switch(e&&e.toLowerCase()){case"hex":case"utf8":case"utf-8":case"ascii":case"binary":case"base64":case"ucs2":case"ucs-2":case"utf16le":case"utf-16le":case"raw":return!0;default:return!1}};function Qe(e){switch(this.encoding=(e||"utf8").toLowerCase().replace(/[-_]/,""),function(e){if(e&&!Je(e))throw new Error("Unknown encoding: "+e)}(e),this.encoding){case"utf8":this.surrogateSize=3;break;case"ucs2":case"utf16le":this.surrogateSize=2,this.detectIncompleteChar=tt;break;case"base64":this.surrogateSize=3,this.detectIncompleteChar=rt;break;default:return void(this.write=et)}this.charBuffer=new p(6),this.charReceived=0,this.charLength=0}function et(e){return e.toString(this.encoding)}function tt(e){this.charReceived=e.length%2,this.charLength=this.charReceived?2:0}function rt(e){this.charReceived=e.length%3,this.charLength=this.charReceived?3:0}Qe.prototype.write=function(e){for(var t="";this.charLength;){var r=e.length>=this.charLength-this.charReceived?this.charLength-this.charReceived:e.length;if(e.copy(this.charBuffer,this.charReceived,0,r),this.charReceived+=r,this.charReceived<this.charLength)return"";if(e=e.slice(r,e.length),!((i=(t=this.charBuffer.slice(0,this.charLength).toString(this.encoding)).charCodeAt(t.length-1))>=55296&&i<=56319)){if(this.charReceived=this.charLength=0,0===e.length)return t;break}this.charLength+=this.surrogateSize,t=""}this.detectIncompleteChar(e);var n=e.length;this.charLength&&(e.copy(this.charBuffer,0,e.length-this.charReceived,n),n-=this.charReceived);var i;n=(t+=e.toString(this.encoding,0,n)).length-1;if((i=t.charCodeAt(n))>=55296&&i<=56319){var o=this.surrogateSize;return this.charLength+=o,this.charReceived+=o,this.charBuffer.copy(this.charBuffer,o,0,o),e.copy(this.charBuffer,0,0,o),t.substring(0,n)}return t},Qe.prototype.detectIncompleteChar=function(e){for(var t=e.length>=3?3:e.length;t>0;t--){var r=e[e.length-t];if(1==t&&r>>5==6){this.charLength=2;break}if(t<=2&&r>>4==14){this.charLength=3;break}if(t<=3&&r>>3==30){this.charLength=4;break}}this.charReceived=t},Qe.prototype.end=function(e){var t="";if(e&&e.length&&(t=this.write(e)),this.charReceived){var r=this.charReceived,n=this.charBuffer,i=this.encoding;t+=n.slice(0,r).toString(i)}return t},ot.ReadableState=it;var nt=function(e){je(Me)&&(Me=""),e=e.toUpperCase(),Ce[e]||(new RegExp("\\b"+e+"\\b","i").test(Me)?Ce[e]=function(){var t=Le.apply(null,arguments);console.error("%s %d: %s",e,0,t)}:Ce[e]=function(){});return Ce[e]}("stream");function it(e,t){e=e||{},this.objectMode=!!e.objectMode,t instanceof Ct&&(this.objectMode=this.objectMode||!!e.readableObjectMode);var r=e.highWaterMark,n=this.objectMode?16:16384;this.highWaterMark=r||0===r?r:n,this.highWaterMark=~~this.highWaterMark,this.buffer=new $e,this.length=0,this.pipes=null,this.pipesCount=0,this.flowing=null,this.ended=!1,this.endEmitted=!1,this.reading=!1,this.sync=!0,this.needReadable=!1,this.emittedReadable=!1,this.readableListening=!1,this.resumeScheduled=!1,this.defaultEncoding=e.defaultEncoding||"utf8",this.ranOut=!1,this.awaitDrain=0,this.readingMore=!1,this.decoder=null,this.encoding=null,e.encoding&&(this.decoder=new Qe(e.encoding),this.encoding=e.encoding)}function ot(e){if(!(this instanceof ot))return new ot(e);this._readableState=new it(e,this),this.readable=!0,e&&"function"==typeof e.read&&(this._read=e.read),ve.call(this)}function at(e,t,r,n,i){var o=function(e,t){var r=null;$(t)||"string"==typeof t||null==t||e.objectMode||(r=new TypeError("Invalid non-string/buffer chunk"));return r}(t,r);if(o)e.emit("error",o);else if(null===r)t.reading=!1,function(e,t){if(t.ended)return;if(t.decoder){var r=t.decoder.end();r&&r.length&&(t.buffer.push(r),t.length+=t.objectMode?1:r.length)}t.ended=!0,lt(e)}(e,t);else if(t.objectMode||r&&r.length>0)if(t.ended&&!i){var a=new Error("stream.push() after EOF");e.emit("error",a)}else if(t.endEmitted&&i){var s=new Error("stream.unshift() after end event");e.emit("error",s)}else{var h;!t.decoder||i||n||(r=t.decoder.write(r),h=!t.objectMode&&0===r.length),i||(t.reading=!1),h||(t.flowing&&0===t.length&&!t.sync?(e.emit("data",r),e.read(0)):(t.length+=t.objectMode?1:r.length,i?t.buffer.unshift(r):t.buffer.push(r),t.needReadable&&lt(e))),function(e,t){t.readingMore||(t.readingMore=!0,de(ct,e,t))}(e,t)}else i||(t.reading=!1);return function(e){return!e.ended&&(e.needReadable||e.length<e.highWaterMark||0===e.length)}(t)}Be(ot,ve),ot.prototype.push=function(e,t){var r=this._readableState;return r.objectMode||"string"!=typeof e||(t=t||r.defaultEncoding)!==r.encoding&&(e=p.from(e,t),t=""),at(this,r,e,t,!1)},ot.prototype.unshift=function(e){return at(this,this._readableState,e,"",!0)},ot.prototype.isPaused=function(){return!1===this._readableState.flowing},ot.prototype.setEncoding=function(e){return this._readableState.decoder=new Qe(e),this._readableState.encoding=e,this};var st=8388608;function ht(e,t){return e<=0||0===t.length&&t.ended?0:t.objectMode?1:e!=e?t.flowing&&t.length?t.buffer.head.data.length:t.length:(e>t.highWaterMark&&(t.highWaterMark=function(e){return e>=st?e=st:(e--,e|=e>>>1,e|=e>>>2,e|=e>>>4,e|=e>>>8,e|=e>>>16,e++),e}(e)),e<=t.length?e:t.ended?t.length:(t.needReadable=!0,0))}function lt(e){var t=e._readableState;t.needReadable=!1,t.emittedReadable||(nt("emitReadable",t.flowing),t.emittedReadable=!0,t.sync?de(ft,e):ft(e))}function ft(e){nt("emit readable"),e.emit("readable"),pt(e)}function ct(e,t){for(var r=t.length;!t.reading&&!t.flowing&&!t.ended&&t.length<t.highWaterMark&&(nt("maybeReadMore read 0"),e.read(0),r!==t.length);)r=t.length;t.readingMore=!1}function ut(e){nt("readable nexttick read 0"),e.read(0)}function dt(e,t){t.reading||(nt("resume read 0"),e.read(0)),t.resumeScheduled=!1,t.awaitDrain=0,e.emit("resume"),pt(e),t.flowing&&!t.reading&&e.read(0)}function pt(e){var t=e._readableState;for(nt("flow",t.flowing);t.flowing&&null!==e.read(););}function _t(e,t){return 0===t.length?null:(t.objectMode?r=t.buffer.shift():!e||e>=t.length?(r=t.decoder?t.buffer.join(""):1===t.buffer.length?t.buffer.head.data:t.buffer.concat(t.length),t.buffer.clear()):r=function(e,t,r){var n;e<t.head.data.length?(n=t.head.data.slice(0,e),t.head.data=t.head.data.slice(e)):n=e===t.head.data.length?t.shift():r?function(e,t){var r=t.head,n=1,i=r.data;e-=i.length;for(;r=r.next;){var o=r.data,a=e>o.length?o.length:e;if(a===o.length?i+=o:i+=o.slice(0,e),0===(e-=a)){a===o.length?(++n,r.next?t.head=r.next:t.head=t.tail=null):(t.head=r,r.data=o.slice(a));break}++n}return t.length-=n,i}(e,t):function(e,t){var r=p.allocUnsafe(e),n=t.head,i=1;n.data.copy(r),e-=n.data.length;for(;n=n.next;){var o=n.data,a=e>o.length?o.length:e;if(o.copy(r,r.length-e,0,a),0===(e-=a)){a===o.length?(++i,n.next?t.head=n.next:t.head=t.tail=null):(t.head=n,n.data=o.slice(a));break}++i}return t.length-=i,r}(e,t);return n}(e,t.buffer,t.decoder),r);var r}function gt(e){var t=e._readableState;if(t.length>0)throw new Error('"endReadable()" called on non-empty stream');t.endEmitted||(t.ended=!0,de(vt,t,e))}function vt(e,t){e.endEmitted||0!==e.length||(e.endEmitted=!0,t.readable=!1,t.emit("end"))}function wt(e,t){for(var r=0,n=e.length;r<n;r++)if(e[r]===t)return r;return-1}function bt(){}function yt(e,t,r){this.chunk=e,this.encoding=t,this.callback=r,this.next=null}function mt(e,t){Object.defineProperty(this,"buffer",{get:Te(function(){return this.getBuffer()},"_writableState.buffer is deprecated. Use _writableState.getBuffer instead.")}),e=e||{},this.objectMode=!!e.objectMode,t instanceof Ct&&(this.objectMode=this.objectMode||!!e.writableObjectMode);var r=e.highWaterMark,n=this.objectMode?16:16384;this.highWaterMark=r||0===r?r:n,this.highWaterMark=~~this.highWaterMark,this.needDrain=!1,this.ending=!1,this.ended=!1,this.finished=!1;var i=!1===e.decodeStrings;this.decodeStrings=!i,this.defaultEncoding=e.defaultEncoding||"utf8",this.length=0,this.writing=!1,this.corked=0,this.sync=!0,this.bufferProcessing=!1,this.onwrite=function(e){!function(e,t){var r=e._writableState,n=r.sync,i=r.writecb;if(function(e){e.writing=!1,e.writecb=null,e.length-=e.writelen,e.writelen=0}(r),t)!function(e,t,r,n,i){--t.pendingcb,r?de(i,n):i(n);e._writableState.errorEmitted=!0,e.emit("error",n)}(e,r,n,t,i);else{var o=Rt(r);o||r.corked||r.bufferProcessing||!r.bufferedRequest||xt(e,r),n?de(St,e,r,o,i):St(e,r,o,i)}}(t,e)},this.writecb=null,this.writelen=0,this.bufferedRequest=null,this.lastBufferedRequest=null,this.pendingcb=0,this.prefinished=!1,this.errorEmitted=!1,this.bufferedRequestCount=0,this.corkedRequestsFree=new zt(this)}function kt(e){if(!(this instanceof kt||this instanceof Ct))return new kt(e);this._writableState=new mt(e,this),this.writable=!0,e&&("function"==typeof e.write&&(this._write=e.write),"function"==typeof e.writev&&(this._writev=e.writev)),ve.call(this)}function Et(e,t,r,n,i,o,a){t.writelen=n,t.writecb=a,t.writing=!0,t.sync=!0,r?e._writev(i,t.onwrite):e._write(i,o,t.onwrite),t.sync=!1}function St(e,t,r,n){r||function(e,t){0===t.length&&t.needDrain&&(t.needDrain=!1,e.emit("drain"))}(e,t),t.pendingcb--,n(),Bt(e,t)}function xt(e,t){t.bufferProcessing=!0;var r=t.bufferedRequest;if(e._writev&&r&&r.next){var n=t.bufferedRequestCount,i=new Array(n),o=t.corkedRequestsFree;o.entry=r;for(var a=0;r;)i[a]=r,r=r.next,a+=1;Et(e,t,!0,t.length,i,"",o.finish),t.pendingcb++,t.lastBufferedRequest=null,o.next?(t.corkedRequestsFree=o.next,o.next=null):t.corkedRequestsFree=new zt(t)}else{for(;r;){var s=r.chunk,h=r.encoding,l=r.callback;if(Et(e,t,!1,t.objectMode?1:s.length,s,h,l),r=r.next,t.writing)break}null===r&&(t.lastBufferedRequest=null)}t.bufferedRequestCount=0,t.bufferedRequest=r,t.bufferProcessing=!1}function Rt(e){return e.ending&&0===e.length&&null===e.bufferedRequest&&!e.finished&&!e.writing}function At(e,t){t.prefinished||(t.prefinished=!0,e.emit("prefinish"))}function Bt(e,t){var r=Rt(t);return r&&(0===t.pendingcb?(At(e,t),t.finished=!0,e.emit("finish")):At(e,t)),r}function zt(e){var t=this;this.next=null,this.entry=null,this.finish=function(r){var n=t.entry;for(t.entry=null;n;){var i=n.callback;e.pendingcb--,i(r),n=n.next}e.corkedRequestsFree?e.corkedRequestsFree.next=t:e.corkedRequestsFree=t}}ot.prototype.read=function(e){nt("read",e),e=parseInt(e,10);var t=this._readableState,r=e;if(0!==e&&(t.emittedReadable=!1),0===e&&t.needReadable&&(t.length>=t.highWaterMark||t.ended))return nt("read: emitReadable",t.length,t.ended),0===t.length&&t.ended?gt(this):lt(this),null;if(0===(e=ht(e,t))&&t.ended)return 0===t.length&&gt(this),null;var n,i=t.needReadable;return nt("need readable",i),(0===t.length||t.length-e<t.highWaterMark)&&nt("length less than watermark",i=!0),t.ended||t.reading?nt("reading or ended",i=!1):i&&(nt("do read"),t.reading=!0,t.sync=!0,0===t.length&&(t.needReadable=!0),this._read(t.highWaterMark),t.sync=!1,t.reading||(e=ht(r,t))),null===(n=e>0?_t(e,t):null)?(t.needReadable=!0,e=0):t.length-=e,0===t.length&&(t.ended||(t.needReadable=!0),r!==e&&t.ended&&gt(this)),null!==n&&this.emit("data",n),n},ot.prototype._read=function(e){this.emit("error",new Error("not implemented"))},ot.prototype.pipe=function(e,t){var r=this,n=this._readableState;switch(n.pipesCount){case 0:n.pipes=e;break;case 1:n.pipes=[n.pipes,e];break;default:n.pipes.push(e)}n.pipesCount+=1,nt("pipe count=%d opts=%j",n.pipesCount,t);var i=!t||!1!==t.end?a:l;function o(e){nt("onunpipe"),e===r&&l()}function a(){nt("onend"),e.end()}n.endEmitted?de(i):r.once("end",i),e.on("unpipe",o);var s=function(e){return function(){var t=e._readableState;nt("pipeOnDrain",t.awaitDrain),t.awaitDrain&&t.awaitDrain--,0===t.awaitDrain&&e.listeners("data").length&&(t.flowing=!0,pt(e))}}(r);e.on("drain",s);var h=!1;function l(){nt("cleanup"),e.removeListener("close",d),e.removeListener("finish",p),e.removeListener("drain",s),e.removeListener("error",u),e.removeListener("unpipe",o),r.removeListener("end",a),r.removeListener("end",l),r.removeListener("data",c),h=!0,!n.awaitDrain||e._writableState&&!e._writableState.needDrain||s()}var f=!1;function c(t){nt("ondata"),f=!1,!1!==e.write(t)||f||((1===n.pipesCount&&n.pipes===e||n.pipesCount>1&&-1!==wt(n.pipes,e))&&!h&&(nt("false write response, pause",r._readableState.awaitDrain),r._readableState.awaitDrain++,f=!0),r.pause())}function u(t){var r;nt("onerror",t),_(),e.removeListener("error",u),0===(r="error",e.listeners(r).length)&&e.emit("error",t)}function d(){e.removeListener("finish",p),_()}function p(){nt("onfinish"),e.removeListener("close",d),_()}function _(){nt("unpipe"),r.unpipe(e)}return r.on("data",c),function(e,t,r){if("function"==typeof e.prependListener)return e.prependListener(t,r);e._events&&e._events[t]?Array.isArray(e._events[t])?e._events[t].unshift(r):e._events[t]=[r,e._events[t]]:e.on(t,r)}(e,"error",u),e.once("close",d),e.once("finish",p),e.emit("pipe",r),n.flowing||(nt("pipe resume"),r.resume()),e},ot.prototype.unpipe=function(e){var t=this._readableState;if(0===t.pipesCount)return this;if(1===t.pipesCount)return e&&e!==t.pipes?this:(e||(e=t.pipes),t.pipes=null,t.pipesCount=0,t.flowing=!1,e&&e.emit("unpipe",this),this);if(!e){var r=t.pipes,n=t.pipesCount;t.pipes=null,t.pipesCount=0,t.flowing=!1;for(var i=0;i<n;i++)r[i].emit("unpipe",this);return this}var o=wt(t.pipes,e);return-1===o?this:(t.pipes.splice(o,1),t.pipesCount-=1,1===t.pipesCount&&(t.pipes=t.pipes[0]),e.emit("unpipe",this),this)},ot.prototype.on=function(e,t){var r=ve.prototype.on.call(this,e,t);if("data"===e)!1!==this._readableState.flowing&&this.resume();else if("readable"===e){var n=this._readableState;n.endEmitted||n.readableListening||(n.readableListening=n.needReadable=!0,n.emittedReadable=!1,n.reading?n.length&&lt(this):de(ut,this))}return r},ot.prototype.addListener=ot.prototype.on,ot.prototype.resume=function(){var e=this._readableState;return e.flowing||(nt("resume"),e.flowing=!0,function(e,t){t.resumeScheduled||(t.resumeScheduled=!0,de(dt,e,t))}(this,e)),this},ot.prototype.pause=function(){return nt("call pause flowing=%j",this._readableState.flowing),!1!==this._readableState.flowing&&(nt("pause"),this._readableState.flowing=!1,this.emit("pause")),this},ot.prototype.wrap=function(e){var t=this._readableState,r=!1,n=this;for(var i in e.on("end",function(){if(nt("wrapped end"),t.decoder&&!t.ended){var e=t.decoder.end();e&&e.length&&n.push(e)}n.push(null)}),e.on("data",function(i){(nt("wrapped data"),t.decoder&&(i=t.decoder.write(i)),t.objectMode&&null==i)||(t.objectMode||i&&i.length)&&(n.push(i)||(r=!0,e.pause()))}),e)void 0===this[i]&&"function"==typeof e[i]&&(this[i]=function(t){return function(){return e[t].apply(e,arguments)}}(i));return function(e,t){for(var r=0,n=e.length;r<n;r++)t(e[r],r)}(["error","close","destroy","pause","resume"],function(t){e.on(t,n.emit.bind(n,t))}),n._read=function(t){nt("wrapped _read",t),r&&(r=!1,e.resume())},n},ot._fromList=_t,kt.WritableState=mt,Be(kt,ve),mt.prototype.getBuffer=function(){for(var e=this.bufferedRequest,t=[];e;)t.push(e),e=e.next;return t},kt.prototype.pipe=function(){this.emit("error",new Error("Cannot pipe, not readable"))},kt.prototype.write=function(e,t,r){var n=this._writableState,i=!1;return"function"==typeof t&&(r=t,t=null),p.isBuffer(e)?t="buffer":t||(t=n.defaultEncoding),"function"!=typeof r&&(r=bt),n.ended?function(e,t){var r=new Error("write after end");e.emit("error",r),de(t,r)}(this,r):function(e,t,r,n){var i=!0,o=!1;return null===r?o=new TypeError("May not write null values to stream"):p.isBuffer(r)||"string"==typeof r||void 0===r||t.objectMode||(o=new TypeError("Invalid non-string/buffer chunk")),o&&(e.emit("error",o),de(n,o),i=!1),i}(this,n,e,r)&&(n.pendingcb++,i=function(e,t,r,n,i){r=function(e,t,r){return e.objectMode||!1===e.decodeStrings||"string"!=typeof t||(t=p.from(t,r)),t}(t,r,n),p.isBuffer(r)&&(n="buffer");var o=t.objectMode?1:r.length;t.length+=o;var a=t.length<t.highWaterMark;a||(t.needDrain=!0);if(t.writing||t.corked){var s=t.lastBufferedRequest;t.lastBufferedRequest=new yt(r,n,i),s?s.next=t.lastBufferedRequest:t.bufferedRequest=t.lastBufferedRequest,t.bufferedRequestCount+=1}else Et(e,t,!1,o,r,n,i);return a}(this,n,e,t,r)),i},kt.prototype.cork=function(){this._writableState.corked++},kt.prototype.uncork=function(){var e=this._writableState;e.corked&&(e.corked--,e.writing||e.corked||e.finished||e.bufferProcessing||!e.bufferedRequest||xt(this,e))},kt.prototype.setDefaultEncoding=function(e){if("string"==typeof e&&(e=e.toLowerCase()),!(["hex","utf8","utf-8","ascii","binary","base64","ucs2","ucs-2","utf16le","utf-16le","raw"].indexOf((e+"").toLowerCase())>-1))throw new TypeError("Unknown encoding: "+e);return this._writableState.defaultEncoding=e,this},kt.prototype._write=function(e,t,r){r(new Error("not implemented"))},kt.prototype._writev=null,kt.prototype.end=function(e,t,r){var n=this._writableState;"function"==typeof e?(r=e,e=null,t=null):"function"==typeof t&&(r=t,t=null),null!=e&&this.write(e,t),n.corked&&(n.corked=1,this.uncork()),n.ending||n.finished||function(e,t,r){t.ending=!0,Bt(e,t),r&&(t.finished?de(r):e.once("finish",r));t.ended=!0,e.writable=!1}(this,n,r)},Be(Ct,ot);for(var Lt=Object.keys(kt.prototype),Tt=0;Tt<Lt.length;Tt++){var Mt=Lt[Tt];Ct.prototype[Mt]||(Ct.prototype[Mt]=kt.prototype[Mt])}function Ct(e){if(!(this instanceof Ct))return new Ct(e);ot.call(this,e),kt.call(this,e),e&&!1===e.readable&&(this.readable=!1),e&&!1===e.writable&&(this.writable=!1),this.allowHalfOpen=!0,e&&!1===e.allowHalfOpen&&(this.allowHalfOpen=!1),this.once("end",Dt)}function Dt(){this.allowHalfOpen||this._writableState.ended||de(It,this)}function It(e){e.end()}function Pt(e){this.afterTransform=function(t,r){return function(e,t,r){var n=e._transformState;n.transforming=!1;var i=n.writecb;if(!i)return e.emit("error",new Error("no writecb in Transform class"));n.writechunk=null,n.writecb=null,null!=r&&e.push(r);i(t);var o=e._readableState;o.reading=!1,(o.needReadable||o.length<o.highWaterMark)&&e._read(o.highWaterMark)}(e,t,r)},this.needTransform=!1,this.transforming=!1,this.writecb=null,this.writechunk=null,this.writeencoding=null}function Ot(e){if(!(this instanceof Ot))return new Ot(e);Ct.call(this,e),this._transformState=new Pt(this);var t=this;this._readableState.needReadable=!0,this._readableState.sync=!1,e&&("function"==typeof e.transform&&(this._transform=e.transform),"function"==typeof e.flush&&(this._flush=e.flush)),this.once("prefinish",function(){"function"==typeof this._flush?this._flush(function(e){Ut(t,e)}):Ut(t)})}function Ut(e,t){if(t)return e.emit("error",t);var r=e._writableState,n=e._transformState;if(r.length)throw new Error("Calling transform done when ws.length != 0");if(n.transforming)throw new Error("Calling transform done when still transforming");return e.push(null)}function Ht(e){if(!(this instanceof Ht))return new Ht(e);Ot.call(this,e)}function Ft(){ve.call(this)}Be(Ot,Ct),Ot.prototype.push=function(e,t){return this._transformState.needTransform=!1,Ct.prototype.push.call(this,e,t)},Ot.prototype._transform=function(e,t,r){throw new Error("Not implemented")},Ot.prototype._write=function(e,t,r){var n=this._transformState;if(n.writecb=r,n.writechunk=e,n.writeencoding=t,!n.transforming){var i=this._readableState;(n.needTransform||i.needReadable||i.length<i.highWaterMark)&&this._read(i.highWaterMark)}},Ot.prototype._read=function(e){var t=this._transformState;null!==t.writechunk&&t.writecb&&!t.transforming?(t.transforming=!0,this._transform(t.writechunk,t.writeencoding,t.afterTransform)):t.needTransform=!0},Be(Ht,Ot),Ht.prototype._transform=function(e,t,r){r(null,e)},Be(Ft,ve),Ft.Readable=ot,Ft.Writable=kt,Ft.Duplex=Ct,Ft.Transform=Ot,Ft.PassThrough=Ht,Ft.Stream=Ft,Ft.prototype.pipe=function(e,t){var r=this;function n(t){e.writable&&!1===e.write(t)&&r.pause&&r.pause()}function i(){r.readable&&r.resume&&r.resume()}r.on("data",n),e.on("drain",i),e._isStdio||t&&!1===t.end||(r.on("end",a),r.on("close",s));var o=!1;function a(){o||(o=!0,e.end())}function s(){o||(o=!0,"function"==typeof e.destroy&&e.destroy())}function h(e){if(l(),0===ve.listenerCount(this,"error"))throw e}function l(){r.removeListener("data",n),e.removeListener("drain",i),r.removeListener("end",a),r.removeListener("close",s),r.removeListener("error",h),e.removeListener("error",h),r.removeListener("end",l),r.removeListener("close",l),e.removeListener("close",l)}return r.on("error",h),e.on("error",h),r.on("end",l),r.on("close",l),e.on("close",l),e.emit("pipe",r),e};var Nt={2:"need dictionary",1:"stream end",0:"","-1":"file error","-2":"stream error","-3":"data error","-4":"insufficient memory","-5":"buffer error","-6":"incompatible version"};function Zt(){this.input=null,this.next_in=0,this.avail_in=0,this.total_in=0,this.output=null,this.next_out=0,this.avail_out=0,this.total_out=0,this.msg="",this.state=null,this.data_type=2,this.adler=0}function jt(e,t,r,n,i){if(t.subarray&&e.subarray)e.set(t.subarray(r,r+n),i);else for(var o=0;o<n;o++)e[i+o]=t[r+o]}var Wt=Uint8Array,Yt=Uint16Array,Kt=Int32Array,Xt=4,qt=0,Vt=1,Gt=2;function $t(e){for(var t=e.length;--t>=0;)e[t]=0}var Jt=0,Qt=1,er=2,tr=29,rr=256,nr=rr+1+tr,ir=30,or=19,ar=2*nr+1,sr=15,hr=16,lr=7,fr=256,cr=16,ur=17,dr=18,pr=[0,0,0,0,0,0,0,0,1,1,1,1,2,2,2,2,3,3,3,3,4,4,4,4,5,5,5,5,0],_r=[0,0,0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9,10,10,11,11,12,12,13,13],gr=[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,3,7],vr=[16,17,18,0,8,7,9,6,10,5,11,4,12,3,13,2,14,1,15],wr=new Array(2*(nr+2));$t(wr);var br=new Array(2*ir);$t(br);var yr=new Array(512);$t(yr);var mr=new Array(256);$t(mr);var kr=new Array(tr);$t(kr);var Er,Sr,xr,Rr=new Array(ir);function Ar(e,t,r,n,i){this.static_tree=e,this.extra_bits=t,this.extra_base=r,this.elems=n,this.max_length=i,this.has_stree=e&&e.length}function Br(e,t){this.dyn_tree=e,this.max_code=0,this.stat_desc=t}function zr(e){return e<256?yr[e]:yr[256+(e>>>7)]}function Lr(e,t){e.pending_buf[e.pending++]=255&t,e.pending_buf[e.pending++]=t>>>8&255}function Tr(e,t,r){e.bi_valid>hr-r?(e.bi_buf|=t<<e.bi_valid&65535,Lr(e,e.bi_buf),e.bi_buf=t>>hr-e.bi_valid,e.bi_valid+=r-hr):(e.bi_buf|=t<<e.bi_valid&65535,e.bi_valid+=r)}function Mr(e,t,r){Tr(e,r[2*t],r[2*t+1])}function Cr(e,t){var r=0;do{r|=1&e,e>>>=1,r<<=1}while(--t>0);return r>>>1}function Dr(e,t,r){var n,i,o=new Array(sr+1),a=0;for(n=1;n<=sr;n++)o[n]=a=a+r[n-1]<<1;for(i=0;i<=t;i++){var s=e[2*i+1];0!==s&&(e[2*i]=Cr(o[s]++,s))}}function Ir(e){var t;for(t=0;t<nr;t++)e.dyn_ltree[2*t]=0;for(t=0;t<ir;t++)e.dyn_dtree[2*t]=0;for(t=0;t<or;t++)e.bl_tree[2*t]=0;e.dyn_ltree[2*fr]=1,e.opt_len=e.static_len=0,e.last_lit=e.matches=0}function Pr(e){e.bi_valid>8?Lr(e,e.bi_buf):e.bi_valid>0&&(e.pending_buf[e.pending++]=e.bi_buf),e.bi_buf=0,e.bi_valid=0}function Or(e,t,r,n){var i=2*t,o=2*r;return e[i]<e[o]||e[i]===e[o]&&n[t]<=n[r]}function Ur(e,t,r){for(var n=e.heap[r],i=r<<1;i<=e.heap_len&&(i<e.heap_len&&Or(t,e.heap[i+1],e.heap[i],e.depth)&&i++,!Or(t,n,e.heap[i],e.depth));)e.heap[r]=e.heap[i],r=i,i<<=1;e.heap[r]=n}function Hr(e,t,r){var n,i,o,a,s=0;if(0!==e.last_lit)do{n=e.pending_buf[e.d_buf+2*s]<<8|e.pending_buf[e.d_buf+2*s+1],i=e.pending_buf[e.l_buf+s],s++,0===n?Mr(e,i,t):(Mr(e,(o=mr[i])+rr+1,t),0!==(a=pr[o])&&Tr(e,i-=kr[o],a),Mr(e,o=zr(--n),r),0!==(a=_r[o])&&Tr(e,n-=Rr[o],a))}while(s<e.last_lit);Mr(e,fr,t)}function Fr(e,t){var r,n,i,o=t.dyn_tree,a=t.stat_desc.static_tree,s=t.stat_desc.has_stree,h=t.stat_desc.elems,l=-1;for(e.heap_len=0,e.heap_max=ar,r=0;r<h;r++)0!==o[2*r]?(e.heap[++e.heap_len]=l=r,e.depth[r]=0):o[2*r+1]=0;for(;e.heap_len<2;)o[2*(i=e.heap[++e.heap_len]=l<2?++l:0)]=1,e.depth[i]=0,e.opt_len--,s&&(e.static_len-=a[2*i+1]);for(t.max_code=l,r=e.heap_len>>1;r>=1;r--)Ur(e,o,r);i=h;do{r=e.heap[1],e.heap[1]=e.heap[e.heap_len--],Ur(e,o,1),n=e.heap[1],e.heap[--e.heap_max]=r,e.heap[--e.heap_max]=n,o[2*i]=o[2*r]+o[2*n],e.depth[i]=(e.depth[r]>=e.depth[n]?e.depth[r]:e.depth[n])+1,o[2*r+1]=o[2*n+1]=i,e.heap[1]=i++,Ur(e,o,1)}while(e.heap_len>=2);e.heap[--e.heap_max]=e.heap[1],function(e,t){var r,n,i,o,a,s,h=t.dyn_tree,l=t.max_code,f=t.stat_desc.static_tree,c=t.stat_desc.has_stree,u=t.stat_desc.extra_bits,d=t.stat_desc.extra_base,p=t.stat_desc.max_length,_=0;for(o=0;o<=sr;o++)e.bl_count[o]=0;for(h[2*e.heap[e.heap_max]+1]=0,r=e.heap_max+1;r<ar;r++)(o=h[2*h[2*(n=e.heap[r])+1]+1]+1)>p&&(o=p,_++),h[2*n+1]=o,n>l||(e.bl_count[o]++,a=0,n>=d&&(a=u[n-d]),s=h[2*n],e.opt_len+=s*(o+a),c&&(e.static_len+=s*(f[2*n+1]+a)));if(0!==_){do{for(o=p-1;0===e.bl_count[o];)o--;e.bl_count[o]--,e.bl_count[o+1]+=2,e.bl_count[p]--,_-=2}while(_>0);for(o=p;0!==o;o--)for(n=e.bl_count[o];0!==n;)(i=e.heap[--r])>l||(h[2*i+1]!==o&&(e.opt_len+=(o-h[2*i+1])*h[2*i],h[2*i+1]=o),n--)}}(e,t),Dr(o,l,e.bl_count)}function Nr(e,t,r){var n,i,o=-1,a=t[1],s=0,h=7,l=4;for(0===a&&(h=138,l=3),t[2*(r+1)+1]=65535,n=0;n<=r;n++)i=a,a=t[2*(n+1)+1],++s<h&&i===a||(s<l?e.bl_tree[2*i]+=s:0!==i?(i!==o&&e.bl_tree[2*i]++,e.bl_tree[2*cr]++):s<=10?e.bl_tree[2*ur]++:e.bl_tree[2*dr]++,s=0,o=i,0===a?(h=138,l=3):i===a?(h=6,l=3):(h=7,l=4))}function Zr(e,t,r){var n,i,o=-1,a=t[1],s=0,h=7,l=4;for(0===a&&(h=138,l=3),n=0;n<=r;n++)if(i=a,a=t[2*(n+1)+1],!(++s<h&&i===a)){if(s<l)do{Mr(e,i,e.bl_tree)}while(0!=--s);else 0!==i?(i!==o&&(Mr(e,i,e.bl_tree),s--),Mr(e,cr,e.bl_tree),Tr(e,s-3,2)):s<=10?(Mr(e,ur,e.bl_tree),Tr(e,s-3,3)):(Mr(e,dr,e.bl_tree),Tr(e,s-11,7));s=0,o=i,0===a?(h=138,l=3):i===a?(h=6,l=3):(h=7,l=4)}}$t(Rr);var jr=!1;function Wr(e){jr||(!function(){var e,t,r,n,i,o=new Array(sr+1);for(r=0,n=0;n<tr-1;n++)for(kr[n]=r,e=0;e<1<<pr[n];e++)mr[r++]=n;for(mr[r-1]=n,i=0,n=0;n<16;n++)for(Rr[n]=i,e=0;e<1<<_r[n];e++)yr[i++]=n;for(i>>=7;n<ir;n++)for(Rr[n]=i<<7,e=0;e<1<<_r[n]-7;e++)yr[256+i++]=n;for(t=0;t<=sr;t++)o[t]=0;for(e=0;e<=143;)wr[2*e+1]=8,e++,o[8]++;for(;e<=255;)wr[2*e+1]=9,e++,o[9]++;for(;e<=279;)wr[2*e+1]=7,e++,o[7]++;for(;e<=287;)wr[2*e+1]=8,e++,o[8]++;for(Dr(wr,nr+1,o),e=0;e<ir;e++)br[2*e+1]=5,br[2*e]=Cr(e,5);Er=new Ar(wr,pr,rr+1,nr,sr),Sr=new Ar(br,_r,0,ir,sr),xr=new Ar(new Array(0),gr,0,or,lr)}(),jr=!0),e.l_desc=new Br(e.dyn_ltree,Er),e.d_desc=new Br(e.dyn_dtree,Sr),e.bl_desc=new Br(e.bl_tree,xr),e.bi_buf=0,e.bi_valid=0,Ir(e)}function Yr(e,t,r,n){Tr(e,(Jt<<1)+(n?1:0),3),function(e,t,r,n){Pr(e),n&&(Lr(e,r),Lr(e,~r)),jt(e.pending_buf,e.window,t,r,e.pending),e.pending+=r}(e,t,r,!0)}function Kr(e){Tr(e,Qt<<1,3),Mr(e,fr,wr),function(e){16===e.bi_valid?(Lr(e,e.bi_buf),e.bi_buf=0,e.bi_valid=0):e.bi_valid>=8&&(e.pending_buf[e.pending++]=255&e.bi_buf,e.bi_buf>>=8,e.bi_valid-=8)}(e)}function Xr(e,t,r,n){var i,o,a=0;e.level>0?(e.strm.data_type===Gt&&(e.strm.data_type=function(e){var t,r=4093624447;for(t=0;t<=31;t++,r>>>=1)if(1&r&&0!==e.dyn_ltree[2*t])return qt;if(0!==e.dyn_ltree[18]||0!==e.dyn_ltree[20]||0!==e.dyn_ltree[26])return Vt;for(t=32;t<rr;t++)if(0!==e.dyn_ltree[2*t])return Vt;return qt}(e)),Fr(e,e.l_desc),Fr(e,e.d_desc),a=function(e){var t;for(Nr(e,e.dyn_ltree,e.l_desc.max_code),Nr(e,e.dyn_dtree,e.d_desc.max_code),Fr(e,e.bl_desc),t=or-1;t>=3&&0===e.bl_tree[2*vr[t]+1];t--);return e.opt_len+=3*(t+1)+5+5+4,t}(e),i=e.opt_len+3+7>>>3,(o=e.static_len+3+7>>>3)<=i&&(i=o)):i=o=r+5,r+4<=i&&-1!==t?Yr(e,t,r,n):e.strategy===Xt||o===i?(Tr(e,(Qt<<1)+(n?1:0),3),Hr(e,wr,br)):(Tr(e,(er<<1)+(n?1:0),3),function(e,t,r,n){var i;for(Tr(e,t-257,5),Tr(e,r-1,5),Tr(e,n-4,4),i=0;i<n;i++)Tr(e,e.bl_tree[2*vr[i]+1],3);Zr(e,e.dyn_ltree,t-1),Zr(e,e.dyn_dtree,r-1)}(e,e.l_desc.max_code+1,e.d_desc.max_code+1,a+1),Hr(e,e.dyn_ltree,e.dyn_dtree)),Ir(e),n&&Pr(e)}function qr(e,t,r){return e.pending_buf[e.d_buf+2*e.last_lit]=t>>>8&255,e.pending_buf[e.d_buf+2*e.last_lit+1]=255&t,e.pending_buf[e.l_buf+e.last_lit]=255&r,e.last_lit++,0===t?e.dyn_ltree[2*r]++:(e.matches++,t--,e.dyn_ltree[2*(mr[r]+rr+1)]++,e.dyn_dtree[2*zr(t)]++),e.last_lit===e.lit_bufsize-1}function Vr(e,t,r,n){for(var i=65535&e|0,o=e>>>16&65535|0,a=0;0!==r;){r-=a=r>2e3?2e3:r;do{o=o+(i=i+t[n++]|0)|0}while(--a);i%=65521,o%=65521}return i|o<<16|0}var Gr=function(){for(var e,t=[],r=0;r<256;r++){e=r;for(var n=0;n<8;n++)e=1&e?3988292384^e>>>1:e>>>1;t[r]=e}return t}();function $r(e,t,r,n){var i=Gr,o=n+r;e^=-1;for(var a=n;a<o;a++)e=e>>>8^i[255&(e^t[a])];return-1^e}var Jr,Qr=0,en=1,tn=3,rn=4,nn=5,on=0,an=1,sn=-2,hn=-3,ln=-5,fn=-1,cn=1,un=2,dn=3,pn=4,_n=2,gn=8,vn=9,wn=286,bn=30,yn=19,mn=2*wn+1,kn=15,En=3,Sn=258,xn=Sn+En+1,Rn=32,An=42,Bn=69,zn=73,Ln=91,Tn=103,Mn=113,Cn=666,Dn=1,In=2,Pn=3,On=4,Un=3;function Hn(e,t){return e.msg=Nt[t],t}function Fn(e){return(e<<1)-(e>4?9:0)}function Nn(e){for(var t=e.length;--t>=0;)e[t]=0}function Zn(e){var t=e.state,r=t.pending;r>e.avail_out&&(r=e.avail_out),0!==r&&(jt(e.output,t.pending_buf,t.pending_out,r,e.next_out),e.next_out+=r,t.pending_out+=r,e.total_out+=r,e.avail_out-=r,t.pending-=r,0===t.pending&&(t.pending_out=0))}function jn(e,t){Xr(e,e.block_start>=0?e.block_start:-1,e.strstart-e.block_start,t),e.block_start=e.strstart,Zn(e.strm)}function Wn(e,t){e.pending_buf[e.pending++]=t}function Yn(e,t){e.pending_buf[e.pending++]=t>>>8&255,e.pending_buf[e.pending++]=255&t}function Kn(e,t){var r,n,i=e.max_chain_length,o=e.strstart,a=e.prev_length,s=e.nice_match,h=e.strstart>e.w_size-xn?e.strstart-(e.w_size-xn):0,l=e.window,f=e.w_mask,c=e.prev,u=e.strstart+Sn,d=l[o+a-1],p=l[o+a];e.prev_length>=e.good_match&&(i>>=2),s>e.lookahead&&(s=e.lookahead);do{if(l[(r=t)+a]===p&&l[r+a-1]===d&&l[r]===l[o]&&l[++r]===l[o+1]){o+=2,r++;do{}while(l[++o]===l[++r]&&l[++o]===l[++r]&&l[++o]===l[++r]&&l[++o]===l[++r]&&l[++o]===l[++r]&&l[++o]===l[++r]&&l[++o]===l[++r]&&l[++o]===l[++r]&&o<u);if(n=Sn-(u-o),o=u-Sn,n>a){if(e.match_start=t,a=n,n>=s)break;d=l[o+a-1],p=l[o+a]}}}while((t=c[t&f])>h&&0!=--i);return a<=e.lookahead?a:e.lookahead}function Xn(e){var t,r,n,i,o,a,s,h,l,f,c=e.w_size;do{if(i=e.window_size-e.lookahead-e.strstart,e.strstart>=c+(c-xn)){jt(e.window,e.window,c,c,0),e.match_start-=c,e.strstart-=c,e.block_start-=c,t=r=e.hash_size;do{n=e.head[--t],e.head[t]=n>=c?n-c:0}while(--r);t=r=c;do{n=e.prev[--t],e.prev[t]=n>=c?n-c:0}while(--r);i+=c}if(0===e.strm.avail_in)break;if(a=e.strm,s=e.window,h=e.strstart+e.lookahead,l=i,f=void 0,(f=a.avail_in)>l&&(f=l),r=0===f?0:(a.avail_in-=f,jt(s,a.input,a.next_in,f,h),1===a.state.wrap?a.adler=Vr(a.adler,s,f,h):2===a.state.wrap&&(a.adler=$r(a.adler,s,f,h)),a.next_in+=f,a.total_in+=f,f),e.lookahead+=r,e.lookahead+e.insert>=En)for(o=e.strstart-e.insert,e.ins_h=e.window[o],e.ins_h=(e.ins_h<<e.hash_shift^e.window[o+1])&e.hash_mask;e.insert&&(e.ins_h=(e.ins_h<<e.hash_shift^e.window[o+En-1])&e.hash_mask,e.prev[o&e.w_mask]=e.head[e.ins_h],e.head[e.ins_h]=o,o++,e.insert--,!(e.lookahead+e.insert<En)););}while(e.lookahead<xn&&0!==e.strm.avail_in)}function qn(e,t){for(var r,n;;){if(e.lookahead<xn){if(Xn(e),e.lookahead<xn&&t===Qr)return Dn;if(0===e.lookahead)break}if(r=0,e.lookahead>=En&&(e.ins_h=(e.ins_h<<e.hash_shift^e.window[e.strstart+En-1])&e.hash_mask,r=e.prev[e.strstart&e.w_mask]=e.head[e.ins_h],e.head[e.ins_h]=e.strstart),0!==r&&e.strstart-r<=e.w_size-xn&&(e.match_length=Kn(e,r)),e.match_length>=En)if(n=qr(e,e.strstart-e.match_start,e.match_length-En),e.lookahead-=e.match_length,e.match_length<=e.max_lazy_match&&e.lookahead>=En){e.match_length--;do{e.strstart++,e.ins_h=(e.ins_h<<e.hash_shift^e.window[e.strstart+En-1])&e.hash_mask,r=e.prev[e.strstart&e.w_mask]=e.head[e.ins_h],e.head[e.ins_h]=e.strstart}while(0!=--e.match_length);e.strstart++}else e.strstart+=e.match_length,e.match_length=0,e.ins_h=e.window[e.strstart],e.ins_h=(e.ins_h<<e.hash_shift^e.window[e.strstart+1])&e.hash_mask;else n=qr(e,0,e.window[e.strstart]),e.lookahead--,e.strstart++;if(n&&(jn(e,!1),0===e.strm.avail_out))return Dn}return e.insert=e.strstart<En-1?e.strstart:En-1,t===rn?(jn(e,!0),0===e.strm.avail_out?Pn:On):e.last_lit&&(jn(e,!1),0===e.strm.avail_out)?Dn:In}function Vn(e,t){for(var r,n,i;;){if(e.lookahead<xn){if(Xn(e),e.lookahead<xn&&t===Qr)return Dn;if(0===e.lookahead)break}if(r=0,e.lookahead>=En&&(e.ins_h=(e.ins_h<<e.hash_shift^e.window[e.strstart+En-1])&e.hash_mask,r=e.prev[e.strstart&e.w_mask]=e.head[e.ins_h],e.head[e.ins_h]=e.strstart),e.prev_length=e.match_length,e.prev_match=e.match_start,e.match_length=En-1,0!==r&&e.prev_length<e.max_lazy_match&&e.strstart-r<=e.w_size-xn&&(e.match_length=Kn(e,r),e.match_length<=5&&(e.strategy===cn||e.match_length===En&&e.strstart-e.match_start>4096)&&(e.match_length=En-1)),e.prev_length>=En&&e.match_length<=e.prev_length){i=e.strstart+e.lookahead-En,n=qr(e,e.strstart-1-e.prev_match,e.prev_length-En),e.lookahead-=e.prev_length-1,e.prev_length-=2;do{++e.strstart<=i&&(e.ins_h=(e.ins_h<<e.hash_shift^e.window[e.strstart+En-1])&e.hash_mask,r=e.prev[e.strstart&e.w_mask]=e.head[e.ins_h],e.head[e.ins_h]=e.strstart)}while(0!=--e.prev_length);if(e.match_available=0,e.match_length=En-1,e.strstart++,n&&(jn(e,!1),0===e.strm.avail_out))return Dn}else if(e.match_available){if((n=qr(e,0,e.window[e.strstart-1]))&&jn(e,!1),e.strstart++,e.lookahead--,0===e.strm.avail_out)return Dn}else e.match_available=1,e.strstart++,e.lookahead--}return e.match_available&&(n=qr(e,0,e.window[e.strstart-1]),e.match_available=0),e.insert=e.strstart<En-1?e.strstart:En-1,t===rn?(jn(e,!0),0===e.strm.avail_out?Pn:On):e.last_lit&&(jn(e,!1),0===e.strm.avail_out)?Dn:In}function Gn(e,t,r,n,i){this.good_length=e,this.max_lazy=t,this.nice_length=r,this.max_chain=n,this.func=i}function $n(){this.strm=null,this.status=0,this.pending_buf=null,this.pending_buf_size=0,this.pending_out=0,this.pending=0,this.wrap=0,this.gzhead=null,this.gzindex=0,this.method=gn,this.last_flush=-1,this.w_size=0,this.w_bits=0,this.w_mask=0,this.window=null,this.window_size=0,this.prev=null,this.head=null,this.ins_h=0,this.hash_size=0,this.hash_bits=0,this.hash_mask=0,this.hash_shift=0,this.block_start=0,this.match_length=0,this.prev_match=0,this.match_available=0,this.strstart=0,this.match_start=0,this.lookahead=0,this.prev_length=0,this.max_chain_length=0,this.max_lazy_match=0,this.level=0,this.strategy=0,this.good_match=0,this.nice_match=0,this.dyn_ltree=new Yt(2*mn),this.dyn_dtree=new Yt(2*(2*bn+1)),this.bl_tree=new Yt(2*(2*yn+1)),Nn(this.dyn_ltree),Nn(this.dyn_dtree),Nn(this.bl_tree),this.l_desc=null,this.d_desc=null,this.bl_desc=null,this.bl_count=new Yt(kn+1),this.heap=new Yt(2*wn+1),Nn(this.heap),this.heap_len=0,this.heap_max=0,this.depth=new Yt(2*wn+1),Nn(this.depth),this.l_buf=0,this.lit_bufsize=0,this.last_lit=0,this.d_buf=0,this.opt_len=0,this.static_len=0,this.matches=0,this.insert=0,this.bi_buf=0,this.bi_valid=0}function Jn(e){var t,r=function(e){var t;return e&&e.state?(e.total_in=e.total_out=0,e.data_type=_n,(t=e.state).pending=0,t.pending_out=0,t.wrap<0&&(t.wrap=-t.wrap),t.status=t.wrap?An:Mn,e.adler=2===t.wrap?0:1,t.last_flush=Qr,Wr(t),on):Hn(e,sn)}(e);return r===on&&((t=e.state).window_size=2*t.w_size,Nn(t.head),t.max_lazy_match=Jr[t.level].max_lazy,t.good_match=Jr[t.level].good_length,t.nice_match=Jr[t.level].nice_length,t.max_chain_length=Jr[t.level].max_chain,t.strstart=0,t.block_start=0,t.lookahead=0,t.insert=0,t.match_length=t.prev_length=En-1,t.match_available=0,t.ins_h=0),r}function Qn(e,t){var r,n,i,o;if(!e||!e.state||t>nn||t<0)return e?Hn(e,sn):sn;if(n=e.state,!e.output||!e.input&&0!==e.avail_in||n.status===Cn&&t!==rn)return Hn(e,0===e.avail_out?ln:sn);if(n.strm=e,r=n.last_flush,n.last_flush=t,n.status===An)if(2===n.wrap)e.adler=0,Wn(n,31),Wn(n,139),Wn(n,8),n.gzhead?(Wn(n,(n.gzhead.text?1:0)+(n.gzhead.hcrc?2:0)+(n.gzhead.extra?4:0)+(n.gzhead.name?8:0)+(n.gzhead.comment?16:0)),Wn(n,255&n.gzhead.time),Wn(n,n.gzhead.time>>8&255),Wn(n,n.gzhead.time>>16&255),Wn(n,n.gzhead.time>>24&255),Wn(n,9===n.level?2:n.strategy>=un||n.level<2?4:0),Wn(n,255&n.gzhead.os),n.gzhead.extra&&n.gzhead.extra.length&&(Wn(n,255&n.gzhead.extra.length),Wn(n,n.gzhead.extra.length>>8&255)),n.gzhead.hcrc&&(e.adler=$r(e.adler,n.pending_buf,n.pending,0)),n.gzindex=0,n.status=Bn):(Wn(n,0),Wn(n,0),Wn(n,0),Wn(n,0),Wn(n,0),Wn(n,9===n.level?2:n.strategy>=un||n.level<2?4:0),Wn(n,Un),n.status=Mn);else{var a=gn+(n.w_bits-8<<4)<<8;a|=(n.strategy>=un||n.level<2?0:n.level<6?1:6===n.level?2:3)<<6,0!==n.strstart&&(a|=Rn),a+=31-a%31,n.status=Mn,Yn(n,a),0!==n.strstart&&(Yn(n,e.adler>>>16),Yn(n,65535&e.adler)),e.adler=1}if(n.status===Bn)if(n.gzhead.extra){for(i=n.pending;n.gzindex<(65535&n.gzhead.extra.length)&&(n.pending!==n.pending_buf_size||(n.gzhead.hcrc&&n.pending>i&&(e.adler=$r(e.adler,n.pending_buf,n.pending-i,i)),Zn(e),i=n.pending,n.pending!==n.pending_buf_size));)Wn(n,255&n.gzhead.extra[n.gzindex]),n.gzindex++;n.gzhead.hcrc&&n.pending>i&&(e.adler=$r(e.adler,n.pending_buf,n.pending-i,i)),n.gzindex===n.gzhead.extra.length&&(n.gzindex=0,n.status=zn)}else n.status=zn;if(n.status===zn)if(n.gzhead.name){i=n.pending;do{if(n.pending===n.pending_buf_size&&(n.gzhead.hcrc&&n.pending>i&&(e.adler=$r(e.adler,n.pending_buf,n.pending-i,i)),Zn(e),i=n.pending,n.pending===n.pending_buf_size)){o=1;break}o=n.gzindex<n.gzhead.name.length?255&n.gzhead.name.charCodeAt(n.gzindex++):0,Wn(n,o)}while(0!==o);n.gzhead.hcrc&&n.pending>i&&(e.adler=$r(e.adler,n.pending_buf,n.pending-i,i)),0===o&&(n.gzindex=0,n.status=Ln)}else n.status=Ln;if(n.status===Ln)if(n.gzhead.comment){i=n.pending;do{if(n.pending===n.pending_buf_size&&(n.gzhead.hcrc&&n.pending>i&&(e.adler=$r(e.adler,n.pending_buf,n.pending-i,i)),Zn(e),i=n.pending,n.pending===n.pending_buf_size)){o=1;break}o=n.gzindex<n.gzhead.comment.length?255&n.gzhead.comment.charCodeAt(n.gzindex++):0,Wn(n,o)}while(0!==o);n.gzhead.hcrc&&n.pending>i&&(e.adler=$r(e.adler,n.pending_buf,n.pending-i,i)),0===o&&(n.status=Tn)}else n.status=Tn;if(n.status===Tn&&(n.gzhead.hcrc?(n.pending+2>n.pending_buf_size&&Zn(e),n.pending+2<=n.pending_buf_size&&(Wn(n,255&e.adler),Wn(n,e.adler>>8&255),e.adler=0,n.status=Mn)):n.status=Mn),0!==n.pending){if(Zn(e),0===e.avail_out)return n.last_flush=-1,on}else if(0===e.avail_in&&Fn(t)<=Fn(r)&&t!==rn)return Hn(e,ln);if(n.status===Cn&&0!==e.avail_in)return Hn(e,ln);if(0!==e.avail_in||0!==n.lookahead||t!==Qr&&n.status!==Cn){var s=n.strategy===un?function(e,t){for(var r;;){if(0===e.lookahead&&(Xn(e),0===e.lookahead)){if(t===Qr)return Dn;break}if(e.match_length=0,r=qr(e,0,e.window[e.strstart]),e.lookahead--,e.strstart++,r&&(jn(e,!1),0===e.strm.avail_out))return Dn}return e.insert=0,t===rn?(jn(e,!0),0===e.strm.avail_out?Pn:On):e.last_lit&&(jn(e,!1),0===e.strm.avail_out)?Dn:In}(n,t):n.strategy===dn?function(e,t){for(var r,n,i,o,a=e.window;;){if(e.lookahead<=Sn){if(Xn(e),e.lookahead<=Sn&&t===Qr)return Dn;if(0===e.lookahead)break}if(e.match_length=0,e.lookahead>=En&&e.strstart>0&&(n=a[i=e.strstart-1])===a[++i]&&n===a[++i]&&n===a[++i]){o=e.strstart+Sn;do{}while(n===a[++i]&&n===a[++i]&&n===a[++i]&&n===a[++i]&&n===a[++i]&&n===a[++i]&&n===a[++i]&&n===a[++i]&&i<o);e.match_length=Sn-(o-i),e.match_length>e.lookahead&&(e.match_length=e.lookahead)}if(e.match_length>=En?(r=qr(e,1,e.match_length-En),e.lookahead-=e.match_length,e.strstart+=e.match_length,e.match_length=0):(r=qr(e,0,e.window[e.strstart]),e.lookahead--,e.strstart++),r&&(jn(e,!1),0===e.strm.avail_out))return Dn}return e.insert=0,t===rn?(jn(e,!0),0===e.strm.avail_out?Pn:On):e.last_lit&&(jn(e,!1),0===e.strm.avail_out)?Dn:In}(n,t):Jr[n.level].func(n,t);if(s!==Pn&&s!==On||(n.status=Cn),s===Dn||s===Pn)return 0===e.avail_out&&(n.last_flush=-1),on;if(s===In&&(t===en?Kr(n):t!==nn&&(Yr(n,0,0,!1),t===tn&&(Nn(n.head),0===n.lookahead&&(n.strstart=0,n.block_start=0,n.insert=0))),Zn(e),0===e.avail_out))return n.last_flush=-1,on}return t!==rn?on:n.wrap<=0?an:(2===n.wrap?(Wn(n,255&e.adler),Wn(n,e.adler>>8&255),Wn(n,e.adler>>16&255),Wn(n,e.adler>>24&255),Wn(n,255&e.total_in),Wn(n,e.total_in>>8&255),Wn(n,e.total_in>>16&255),Wn(n,e.total_in>>24&255)):(Yn(n,e.adler>>>16),Yn(n,65535&e.adler)),Zn(e),n.wrap>0&&(n.wrap=-n.wrap),0!==n.pending?on:an)}Jr=[new Gn(0,0,0,0,function(e,t){var r=65535;for(r>e.pending_buf_size-5&&(r=e.pending_buf_size-5);;){if(e.lookahead<=1){if(Xn(e),0===e.lookahead&&t===Qr)return Dn;if(0===e.lookahead)break}e.strstart+=e.lookahead,e.lookahead=0;var n=e.block_start+r;if((0===e.strstart||e.strstart>=n)&&(e.lookahead=e.strstart-n,e.strstart=n,jn(e,!1),0===e.strm.avail_out))return Dn;if(e.strstart-e.block_start>=e.w_size-xn&&(jn(e,!1),0===e.strm.avail_out))return Dn}return e.insert=0,t===rn?(jn(e,!0),0===e.strm.avail_out?Pn:On):(e.strstart>e.block_start&&(jn(e,!1),e.strm.avail_out),Dn)}),new Gn(4,4,8,4,qn),new Gn(4,5,16,8,qn),new Gn(4,6,32,32,qn),new Gn(4,4,16,16,Vn),new Gn(8,16,32,32,Vn),new Gn(8,16,128,128,Vn),new Gn(8,32,128,256,Vn),new Gn(32,128,258,1024,Vn),new Gn(32,258,258,4096,Vn)];var ei=30,ti=12;function ri(e,t){var r,n,i,o,a,s,h,l,f,c,u,d,p,_,g,v,w,b,y,m,k,E,S,x,R;r=e.state,n=e.next_in,x=e.input,i=n+(e.avail_in-5),o=e.next_out,R=e.output,a=o-(t-e.avail_out),s=o+(e.avail_out-257),h=r.dmax,l=r.wsize,f=r.whave,c=r.wnext,u=r.window,d=r.hold,p=r.bits,_=r.lencode,g=r.distcode,v=(1<<r.lenbits)-1,w=(1<<r.distbits)-1;e:do{p<15&&(d+=x[n++]<<p,p+=8,d+=x[n++]<<p,p+=8),b=_[d&v];t:for(;;){if(d>>>=y=b>>>24,p-=y,0===(y=b>>>16&255))R[o++]=65535&b;else{if(!(16&y)){if(0==(64&y)){b=_[(65535&b)+(d&(1<<y)-1)];continue t}if(32&y){r.mode=ti;break e}e.msg="invalid literal/length code",r.mode=ei;break e}m=65535&b,(y&=15)&&(p<y&&(d+=x[n++]<<p,p+=8),m+=d&(1<<y)-1,d>>>=y,p-=y),p<15&&(d+=x[n++]<<p,p+=8,d+=x[n++]<<p,p+=8),b=g[d&w];r:for(;;){if(d>>>=y=b>>>24,p-=y,!(16&(y=b>>>16&255))){if(0==(64&y)){b=g[(65535&b)+(d&(1<<y)-1)];continue r}e.msg="invalid distance code",r.mode=ei;break e}if(k=65535&b,p<(y&=15)&&(d+=x[n++]<<p,(p+=8)<y&&(d+=x[n++]<<p,p+=8)),(k+=d&(1<<y)-1)>h){e.msg="invalid distance too far back",r.mode=ei;break e}if(d>>>=y,p-=y,k>(y=o-a)){if((y=k-y)>f&&r.sane){e.msg="invalid distance too far back",r.mode=ei;break e}if(E=0,S=u,0===c){if(E+=l-y,y<m){m-=y;do{R[o++]=u[E++]}while(--y);E=o-k,S=R}}else if(c<y){if(E+=l+c-y,(y-=c)<m){m-=y;do{R[o++]=u[E++]}while(--y);if(E=0,c<m){m-=y=c;do{R[o++]=u[E++]}while(--y);E=o-k,S=R}}}else if(E+=c-y,y<m){m-=y;do{R[o++]=u[E++]}while(--y);E=o-k,S=R}for(;m>2;)R[o++]=S[E++],R[o++]=S[E++],R[o++]=S[E++],m-=3;m&&(R[o++]=S[E++],m>1&&(R[o++]=S[E++]))}else{E=o-k;do{R[o++]=R[E++],R[o++]=R[E++],R[o++]=R[E++],m-=3}while(m>2);m&&(R[o++]=R[E++],m>1&&(R[o++]=R[E++]))}break}}break}}while(n<i&&o<s);n-=m=p>>3,d&=(1<<(p-=m<<3))-1,e.next_in=n,e.next_out=o,e.avail_in=n<i?i-n+5:5-(n-i),e.avail_out=o<s?s-o+257:257-(o-s),r.hold=d,r.bits=p}var ni=15,ii=852,oi=592,ai=0,si=1,hi=2,li=[3,4,5,6,7,8,9,10,11,13,15,17,19,23,27,31,35,43,51,59,67,83,99,115,131,163,195,227,258,0,0],fi=[16,16,16,16,16,16,16,16,17,17,17,17,18,18,18,18,19,19,19,19,20,20,20,20,21,21,21,21,16,72,78],ci=[1,2,3,4,5,7,9,13,17,25,33,49,65,97,129,193,257,385,513,769,1025,1537,2049,3073,4097,6145,8193,12289,16385,24577,0,0],ui=[16,16,16,16,17,17,18,18,19,19,20,20,21,21,22,22,23,23,24,24,25,25,26,26,27,27,28,28,29,29,64,64];function di(e,t,r,n,i,o,a,s){var h,l,f,c,u,d,p,_,g,v=s.bits,w=0,b=0,y=0,m=0,k=0,E=0,S=0,x=0,R=0,A=0,B=null,z=0,L=new Yt(ni+1),T=new Yt(ni+1),M=null,C=0;for(w=0;w<=ni;w++)L[w]=0;for(b=0;b<n;b++)L[t[r+b]]++;for(k=v,m=ni;m>=1&&0===L[m];m--);if(k>m&&(k=m),0===m)return i[o++]=20971520,i[o++]=20971520,s.bits=1,0;for(y=1;y<m&&0===L[y];y++);for(k<y&&(k=y),x=1,w=1;w<=ni;w++)if(x<<=1,(x-=L[w])<0)return-1;if(x>0&&(e===ai||1!==m))return-1;for(T[1]=0,w=1;w<ni;w++)T[w+1]=T[w]+L[w];for(b=0;b<n;b++)0!==t[r+b]&&(a[T[t[r+b]]++]=b);if(e===ai?(B=M=a,d=19):e===si?(B=li,z-=257,M=fi,C-=257,d=256):(B=ci,M=ui,d=-1),A=0,b=0,w=y,u=o,E=k,S=0,f=-1,c=(R=1<<k)-1,e===si&&R>ii||e===hi&&R>oi)return 1;for(;;){p=w-S,a[b]<d?(_=0,g=a[b]):a[b]>d?(_=M[C+a[b]],g=B[z+a[b]]):(_=96,g=0),h=1<<w-S,y=l=1<<E;do{i[u+(A>>S)+(l-=h)]=p<<24|_<<16|g|0}while(0!==l);for(h=1<<w-1;A&h;)h>>=1;if(0!==h?(A&=h-1,A+=h):A=0,b++,0==--L[w]){if(w===m)break;w=t[r+a[b]]}if(w>k&&(A&c)!==f){for(0===S&&(S=k),u+=y,x=1<<(E=w-S);E+S<m&&!((x-=L[E+S])<=0);)E++,x<<=1;if(R+=1<<E,e===si&&R>ii||e===hi&&R>oi)return 1;i[f=A&c]=k<<24|E<<16|u-o|0}}return 0!==A&&(i[u+A]=w-S<<24|64<<16|0),s.bits=k,0}var pi=0,_i=1,gi=2,vi=4,wi=5,bi=6,yi=0,mi=1,ki=2,Ei=-2,Si=-3,xi=-4,Ri=-5,Ai=8,Bi=1,zi=2,Li=3,Ti=4,Mi=5,Ci=6,Di=7,Ii=8,Pi=9,Oi=10,Ui=11,Hi=12,Fi=13,Ni=14,Zi=15,ji=16,Wi=17,Yi=18,Ki=19,Xi=20,qi=21,Vi=22,Gi=23,$i=24,Ji=25,Qi=26,eo=27,to=28,ro=29,no=30,io=31,oo=32,ao=852,so=592;function ho(e){return(e>>>24&255)+(e>>>8&65280)+((65280&e)<<8)+((255&e)<<24)}function lo(){this.mode=0,this.last=!1,this.wrap=0,this.havedict=!1,this.flags=0,this.dmax=0,this.check=0,this.total=0,this.head=null,this.wbits=0,this.wsize=0,this.whave=0,this.wnext=0,this.window=null,this.hold=0,this.bits=0,this.length=0,this.offset=0,this.extra=0,this.lencode=null,this.distcode=null,this.lenbits=0,this.distbits=0,this.ncode=0,this.nlen=0,this.ndist=0,this.have=0,this.next=null,this.lens=new Yt(320),this.work=new Yt(288),this.lendyn=null,this.distdyn=null,this.sane=0,this.back=0,this.was=0}function fo(e){var t;return e&&e.state?((t=e.state).wsize=0,t.whave=0,t.wnext=0,function(e){var t;return e&&e.state?(t=e.state,e.total_in=e.total_out=t.total=0,e.msg="",t.wrap&&(e.adler=1&t.wrap),t.mode=Bi,t.last=0,t.havedict=0,t.dmax=32768,t.head=null,t.hold=0,t.bits=0,t.lencode=t.lendyn=new Kt(ao),t.distcode=t.distdyn=new Kt(so),t.sane=1,t.back=-1,yi):Ei}(e)):Ei}function co(e,t){var r,n;return e?(n=new lo,e.state=n,n.window=null,(r=function(e,t){var r,n;return e&&e.state?(n=e.state,t<0?(r=0,t=-t):(r=1+(t>>4),t<48&&(t&=15)),t&&(t<8||t>15)?Ei:(null!==n.window&&n.wbits!==t&&(n.window=null),n.wrap=r,n.wbits=t,fo(e))):Ei}(e,t))!==yi&&(e.state=null),r):Ei}var uo,po,_o=!0;function go(e){if(_o){var t;for(uo=new Kt(512),po=new Kt(32),t=0;t<144;)e.lens[t++]=8;for(;t<256;)e.lens[t++]=9;for(;t<280;)e.lens[t++]=7;for(;t<288;)e.lens[t++]=8;for(di(_i,e.lens,0,288,uo,0,e.work,{bits:9}),t=0;t<32;)e.lens[t++]=5;di(gi,e.lens,0,32,po,0,e.work,{bits:5}),_o=!1}e.lencode=uo,e.lenbits=9,e.distcode=po,e.distbits=5}function vo(e,t){var r,n,i,o,a,s,h,l,f,c,u,d,p,_,g,v,w,b,y,m,k,E,S,x,R=0,A=new Wt(4),B=[16,17,18,0,8,7,9,6,10,5,11,4,12,3,13,2,14,1,15];if(!e||!e.state||!e.output||!e.input&&0!==e.avail_in)return Ei;(r=e.state).mode===Hi&&(r.mode=Fi),a=e.next_out,i=e.output,h=e.avail_out,o=e.next_in,n=e.input,s=e.avail_in,l=r.hold,f=r.bits,c=s,u=h,E=yi;e:for(;;)switch(r.mode){case Bi:if(0===r.wrap){r.mode=Fi;break}for(;f<16;){if(0===s)break e;s--,l+=n[o++]<<f,f+=8}if(2&r.wrap&&35615===l){r.check=0,A[0]=255&l,A[1]=l>>>8&255,r.check=$r(r.check,A,2,0),l=0,f=0,r.mode=zi;break}if(r.flags=0,r.head&&(r.head.done=!1),!(1&r.wrap)||(((255&l)<<8)+(l>>8))%31){e.msg="incorrect header check",r.mode=no;break}if((15&l)!==Ai){e.msg="unknown compression method",r.mode=no;break}if(f-=4,k=8+(15&(l>>>=4)),0===r.wbits)r.wbits=k;else if(k>r.wbits){e.msg="invalid window size",r.mode=no;break}r.dmax=1<<k,e.adler=r.check=1,r.mode=512&l?Oi:Hi,l=0,f=0;break;case zi:for(;f<16;){if(0===s)break e;s--,l+=n[o++]<<f,f+=8}if(r.flags=l,(255&r.flags)!==Ai){e.msg="unknown compression method",r.mode=no;break}if(57344&r.flags){e.msg="unknown header flags set",r.mode=no;break}r.head&&(r.head.text=l>>8&1),512&r.flags&&(A[0]=255&l,A[1]=l>>>8&255,r.check=$r(r.check,A,2,0)),l=0,f=0,r.mode=Li;case Li:for(;f<32;){if(0===s)break e;s--,l+=n[o++]<<f,f+=8}r.head&&(r.head.time=l),512&r.flags&&(A[0]=255&l,A[1]=l>>>8&255,A[2]=l>>>16&255,A[3]=l>>>24&255,r.check=$r(r.check,A,4,0)),l=0,f=0,r.mode=Ti;case Ti:for(;f<16;){if(0===s)break e;s--,l+=n[o++]<<f,f+=8}r.head&&(r.head.xflags=255&l,r.head.os=l>>8),512&r.flags&&(A[0]=255&l,A[1]=l>>>8&255,r.check=$r(r.check,A,2,0)),l=0,f=0,r.mode=Mi;case Mi:if(1024&r.flags){for(;f<16;){if(0===s)break e;s--,l+=n[o++]<<f,f+=8}r.length=l,r.head&&(r.head.extra_len=l),512&r.flags&&(A[0]=255&l,A[1]=l>>>8&255,r.check=$r(r.check,A,2,0)),l=0,f=0}else r.head&&(r.head.extra=null);r.mode=Ci;case Ci:if(1024&r.flags&&((d=r.length)>s&&(d=s),d&&(r.head&&(k=r.head.extra_len-r.length,r.head.extra||(r.head.extra=new Array(r.head.extra_len)),jt(r.head.extra,n,o,d,k)),512&r.flags&&(r.check=$r(r.check,n,d,o)),s-=d,o+=d,r.length-=d),r.length))break e;r.length=0,r.mode=Di;case Di:if(2048&r.flags){if(0===s)break e;d=0;do{k=n[o+d++],r.head&&k&&r.length<65536&&(r.head.name+=String.fromCharCode(k))}while(k&&d<s);if(512&r.flags&&(r.check=$r(r.check,n,d,o)),s-=d,o+=d,k)break e}else r.head&&(r.head.name=null);r.length=0,r.mode=Ii;case Ii:if(4096&r.flags){if(0===s)break e;d=0;do{k=n[o+d++],r.head&&k&&r.length<65536&&(r.head.comment+=String.fromCharCode(k))}while(k&&d<s);if(512&r.flags&&(r.check=$r(r.check,n,d,o)),s-=d,o+=d,k)break e}else r.head&&(r.head.comment=null);r.mode=Pi;case Pi:if(512&r.flags){for(;f<16;){if(0===s)break e;s--,l+=n[o++]<<f,f+=8}if(l!==(65535&r.check)){e.msg="header crc mismatch",r.mode=no;break}l=0,f=0}r.head&&(r.head.hcrc=r.flags>>9&1,r.head.done=!0),e.adler=r.check=0,r.mode=Hi;break;case Oi:for(;f<32;){if(0===s)break e;s--,l+=n[o++]<<f,f+=8}e.adler=r.check=ho(l),l=0,f=0,r.mode=Ui;case Ui:if(0===r.havedict)return e.next_out=a,e.avail_out=h,e.next_in=o,e.avail_in=s,r.hold=l,r.bits=f,ki;e.adler=r.check=1,r.mode=Hi;case Hi:if(t===wi||t===bi)break e;case Fi:if(r.last){l>>>=7&f,f-=7&f,r.mode=eo;break}for(;f<3;){if(0===s)break e;s--,l+=n[o++]<<f,f+=8}switch(r.last=1&l,f-=1,3&(l>>>=1)){case 0:r.mode=Ni;break;case 1:if(go(r),r.mode=Xi,t===bi){l>>>=2,f-=2;break e}break;case 2:r.mode=Wi;break;case 3:e.msg="invalid block type",r.mode=no}l>>>=2,f-=2;break;case Ni:for(l>>>=7&f,f-=7&f;f<32;){if(0===s)break e;s--,l+=n[o++]<<f,f+=8}if((65535&l)!=(l>>>16^65535)){e.msg="invalid stored block lengths",r.mode=no;break}if(r.length=65535&l,l=0,f=0,r.mode=Zi,t===bi)break e;case Zi:r.mode=ji;case ji:if(d=r.length){if(d>s&&(d=s),d>h&&(d=h),0===d)break e;jt(i,n,o,d,a),s-=d,o+=d,h-=d,a+=d,r.length-=d;break}r.mode=Hi;break;case Wi:for(;f<14;){if(0===s)break e;s--,l+=n[o++]<<f,f+=8}if(r.nlen=257+(31&l),l>>>=5,f-=5,r.ndist=1+(31&l),l>>>=5,f-=5,r.ncode=4+(15&l),l>>>=4,f-=4,r.nlen>286||r.ndist>30){e.msg="too many length or distance symbols",r.mode=no;break}r.have=0,r.mode=Yi;case Yi:for(;r.have<r.ncode;){for(;f<3;){if(0===s)break e;s--,l+=n[o++]<<f,f+=8}r.lens[B[r.have++]]=7&l,l>>>=3,f-=3}for(;r.have<19;)r.lens[B[r.have++]]=0;if(r.lencode=r.lendyn,r.lenbits=7,S={bits:r.lenbits},E=di(pi,r.lens,0,19,r.lencode,0,r.work,S),r.lenbits=S.bits,E){e.msg="invalid code lengths set",r.mode=no;break}r.have=0,r.mode=Ki;case Ki:for(;r.have<r.nlen+r.ndist;){for(;v=(R=r.lencode[l&(1<<r.lenbits)-1])>>>16&255,w=65535&R,!((g=R>>>24)<=f);){if(0===s)break e;s--,l+=n[o++]<<f,f+=8}if(w<16)l>>>=g,f-=g,r.lens[r.have++]=w;else{if(16===w){for(x=g+2;f<x;){if(0===s)break e;s--,l+=n[o++]<<f,f+=8}if(l>>>=g,f-=g,0===r.have){e.msg="invalid bit length repeat",r.mode=no;break}k=r.lens[r.have-1],d=3+(3&l),l>>>=2,f-=2}else if(17===w){for(x=g+3;f<x;){if(0===s)break e;s--,l+=n[o++]<<f,f+=8}f-=g,k=0,d=3+(7&(l>>>=g)),l>>>=3,f-=3}else{for(x=g+7;f<x;){if(0===s)break e;s--,l+=n[o++]<<f,f+=8}f-=g,k=0,d=11+(127&(l>>>=g)),l>>>=7,f-=7}if(r.have+d>r.nlen+r.ndist){e.msg="invalid bit length repeat",r.mode=no;break}for(;d--;)r.lens[r.have++]=k}}if(r.mode===no)break;if(0===r.lens[256]){e.msg="invalid code -- missing end-of-block",r.mode=no;break}if(r.lenbits=9,S={bits:r.lenbits},E=di(_i,r.lens,0,r.nlen,r.lencode,0,r.work,S),r.lenbits=S.bits,E){e.msg="invalid literal/lengths set",r.mode=no;break}if(r.distbits=6,r.distcode=r.distdyn,S={bits:r.distbits},E=di(gi,r.lens,r.nlen,r.ndist,r.distcode,0,r.work,S),r.distbits=S.bits,E){e.msg="invalid distances set",r.mode=no;break}if(r.mode=Xi,t===bi)break e;case Xi:r.mode=qi;case qi:if(s>=6&&h>=258){e.next_out=a,e.avail_out=h,e.next_in=o,e.avail_in=s,r.hold=l,r.bits=f,ri(e,u),a=e.next_out,i=e.output,h=e.avail_out,o=e.next_in,n=e.input,s=e.avail_in,l=r.hold,f=r.bits,r.mode===Hi&&(r.back=-1);break}for(r.back=0;v=(R=r.lencode[l&(1<<r.lenbits)-1])>>>16&255,w=65535&R,!((g=R>>>24)<=f);){if(0===s)break e;s--,l+=n[o++]<<f,f+=8}if(v&&0==(240&v)){for(b=g,y=v,m=w;v=(R=r.lencode[m+((l&(1<<b+y)-1)>>b)])>>>16&255,w=65535&R,!(b+(g=R>>>24)<=f);){if(0===s)break e;s--,l+=n[o++]<<f,f+=8}l>>>=b,f-=b,r.back+=b}if(l>>>=g,f-=g,r.back+=g,r.length=w,0===v){r.mode=Qi;break}if(32&v){r.back=-1,r.mode=Hi;break}if(64&v){e.msg="invalid literal/length code",r.mode=no;break}r.extra=15&v,r.mode=Vi;case Vi:if(r.extra){for(x=r.extra;f<x;){if(0===s)break e;s--,l+=n[o++]<<f,f+=8}r.length+=l&(1<<r.extra)-1,l>>>=r.extra,f-=r.extra,r.back+=r.extra}r.was=r.length,r.mode=Gi;case Gi:for(;v=(R=r.distcode[l&(1<<r.distbits)-1])>>>16&255,w=65535&R,!((g=R>>>24)<=f);){if(0===s)break e;s--,l+=n[o++]<<f,f+=8}if(0==(240&v)){for(b=g,y=v,m=w;v=(R=r.distcode[m+((l&(1<<b+y)-1)>>b)])>>>16&255,w=65535&R,!(b+(g=R>>>24)<=f);){if(0===s)break e;s--,l+=n[o++]<<f,f+=8}l>>>=b,f-=b,r.back+=b}if(l>>>=g,f-=g,r.back+=g,64&v){e.msg="invalid distance code",r.mode=no;break}r.offset=w,r.extra=15&v,r.mode=$i;case $i:if(r.extra){for(x=r.extra;f<x;){if(0===s)break e;s--,l+=n[o++]<<f,f+=8}r.offset+=l&(1<<r.extra)-1,l>>>=r.extra,f-=r.extra,r.back+=r.extra}if(r.offset>r.dmax){e.msg="invalid distance too far back",r.mode=no;break}r.mode=Ji;case Ji:if(0===h)break e;if(d=u-h,r.offset>d){if((d=r.offset-d)>r.whave&&r.sane){e.msg="invalid distance too far back",r.mode=no;break}d>r.wnext?(d-=r.wnext,p=r.wsize-d):p=r.wnext-d,d>r.length&&(d=r.length),_=r.window}else _=i,p=a-r.offset,d=r.length;d>h&&(d=h),h-=d,r.length-=d;do{i[a++]=_[p++]}while(--d);0===r.length&&(r.mode=qi);break;case Qi:if(0===h)break e;i[a++]=r.length,h--,r.mode=qi;break;case eo:if(r.wrap){for(;f<32;){if(0===s)break e;s--,l|=n[o++]<<f,f+=8}if(u-=h,e.total_out+=u,r.total+=u,u&&(e.adler=r.check=r.flags?$r(r.check,i,u,a-u):Vr(r.check,i,u,a-u)),u=h,(r.flags?l:ho(l))!==r.check){e.msg="incorrect data check",r.mode=no;break}l=0,f=0}r.mode=to;case to:if(r.wrap&&r.flags){for(;f<32;){if(0===s)break e;s--,l+=n[o++]<<f,f+=8}if(l!==(4294967295&r.total)){e.msg="incorrect length check",r.mode=no;break}l=0,f=0}r.mode=ro;case ro:E=mi;break e;case no:E=Si;break e;case io:return xi;case oo:default:return Ei}return e.next_out=a,e.avail_out=h,e.next_in=o,e.avail_in=s,r.hold=l,r.bits=f,(r.wsize||u!==e.avail_out&&r.mode<no&&(r.mode<eo||t!==vi))&&function(e,t,r,n){var i,o=e.state;null===o.window&&(o.wsize=1<<o.wbits,o.wnext=0,o.whave=0,o.window=new Wt(o.wsize)),n>=o.wsize?(jt(o.window,t,r-o.wsize,o.wsize,0),o.wnext=0,o.whave=o.wsize):((i=o.wsize-o.wnext)>n&&(i=n),jt(o.window,t,r-n,i,o.wnext),(n-=i)?(jt(o.window,t,r-n,n,0),o.wnext=n,o.whave=o.wsize):(o.wnext+=i,o.wnext===o.wsize&&(o.wnext=0),o.whave<o.wsize&&(o.whave+=i)))}(e,e.output,e.next_out,u-e.avail_out),c-=e.avail_in,u-=e.avail_out,e.total_in+=c,e.total_out+=u,r.total+=u,r.wrap&&u&&(e.adler=r.check=r.flags?$r(r.check,i,u,e.next_out-u):Vr(r.check,i,u,e.next_out-u)),e.data_type=r.bits+(r.last?64:0)+(r.mode===Hi?128:0)+(r.mode===Xi||r.mode===Zi?256:0),(0===c&&0===u||t===vi)&&E===yi&&(E=Ri),E}var wo,bo=1,yo=7;function mo(e){if(e<bo||e>yo)throw new TypeError("Bad argument");this.mode=e,this.init_done=!1,this.write_in_progress=!1,this.pending_close=!1,this.windowBits=0,this.level=0,this.memLevel=0,this.strategy=0,this.dictionary=null}function ko(e,t){for(var r=0;r<e.length;r++)this[t+r]=e[r]}mo.prototype.init=function(e,t,r,n,i){var o;switch(this.windowBits=e,this.level=t,this.memLevel=r,this.strategy=n,3!==this.mode&&4!==this.mode||(this.windowBits+=16),this.mode===yo&&(this.windowBits+=32),5!==this.mode&&6!==this.mode||(this.windowBits=-this.windowBits),this.strm=new Zt,this.mode){case bo:case 3:case 5:o=function(e,t,r,n,i,o){if(!e)return sn;var a=1;if(t===fn&&(t=6),n<0?(a=0,n=-n):n>15&&(a=2,n-=16),i<1||i>vn||r!==gn||n<8||n>15||t<0||t>9||o<0||o>pn)return Hn(e,sn);8===n&&(n=9);var s=new $n;return e.state=s,s.strm=e,s.wrap=a,s.gzhead=null,s.w_bits=n,s.w_size=1<<s.w_bits,s.w_mask=s.w_size-1,s.hash_bits=i+7,s.hash_size=1<<s.hash_bits,s.hash_mask=s.hash_size-1,s.hash_shift=~~((s.hash_bits+En-1)/En),s.window=new Wt(2*s.w_size),s.head=new Yt(s.hash_size),s.prev=new Yt(s.w_size),s.lit_bufsize=1<<i+6,s.pending_buf_size=4*s.lit_bufsize,s.pending_buf=new Wt(s.pending_buf_size),s.d_buf=1*s.lit_bufsize,s.l_buf=3*s.lit_bufsize,s.level=t,s.strategy=o,s.method=r,Jn(e)}(this.strm,this.level,8,this.windowBits,this.memLevel,this.strategy);break;case 2:case 4:case 6:case yo:o=co(this.strm,this.windowBits);break;default:throw new Error("Unknown mode "+this.mode)}0===o?(this.write_in_progress=!1,this.init_done=!0):this._error(o)},mo.prototype.params=function(){throw new Error("deflateParams Not supported")},mo.prototype._writeCheck=function(){if(!this.init_done)throw new Error("write before init");if(0===this.mode)throw new Error("already finalized");if(this.write_in_progress)throw new Error("write already in progress");if(this.pending_close)throw new Error("close is pending")},mo.prototype.write=function(e,t,r,n,i,o,a){this._writeCheck(),this.write_in_progress=!0;var s=this;return de(function(){s.write_in_progress=!1;var h=s._write(e,t,r,n,i,o,a);s.callback(h[0],h[1]),s.pending_close&&s.close()}),this},mo.prototype.writeSync=function(e,t,r,n,i,o,a){return this._writeCheck(),this._write(e,t,r,n,i,o,a)},mo.prototype._write=function(e,t,r,n,i,o,a){if(this.write_in_progress=!0,0!==e&&1!==e&&2!==e&&3!==e&&4!==e&&5!==e)throw new Error("Invalid flush value");null==t&&(t=new p(0),n=0,r=0),i._set?i.set=i._set:i.set=ko;var s,h=this.strm;switch(h.avail_in=n,h.input=t,h.next_in=r,h.avail_out=a,h.output=i,h.next_out=o,this.mode){case bo:case 3:case 5:s=Qn(h,e);break;case yo:case 2:case 4:case 6:s=vo(h,e);break;default:throw new Error("Unknown mode "+this.mode)}return 1!==s&&0!==s&&this._error(s),this.write_in_progress=!1,[h.avail_in,h.avail_out]},mo.prototype.close=function(){this.write_in_progress?this.pending_close=!0:(this.pending_close=!1,this.mode===bo||3===this.mode||5===this.mode?function(e){var t;e&&e.state&&((t=e.state.status)!==An&&t!==Bn&&t!==zn&&t!==Ln&&t!==Tn&&t!==Mn&&t!==Cn?Hn(e,sn):(e.state=null,t===Mn&&Hn(e,hn)))}(this.strm):function(e){if(!e||!e.state)return Ei;var t=e.state;t.window&&(t.window=null),e.state=null}(this.strm),this.mode=0)},mo.prototype.reset=function(){switch(this.mode){case bo:case 5:wo=Jn(this.strm);break;case 2:case 6:wo=fo(this.strm)}0!==wo&&this._error(wo)},mo.prototype._error=function(e){this.onerror(Nt[e]+": "+this.strm.msg,e),this.write_in_progress=!1,this.pending_close&&this.close()};var Eo=Object.freeze({NONE:0,DEFLATE:bo,INFLATE:2,GZIP:3,GUNZIP:4,DEFLATERAW:5,INFLATERAW:6,UNZIP:yo,Z_NO_FLUSH:0,Z_PARTIAL_FLUSH:1,Z_SYNC_FLUSH:2,Z_FULL_FLUSH:3,Z_FINISH:4,Z_BLOCK:5,Z_TREES:6,Z_OK:0,Z_STREAM_END:1,Z_NEED_DICT:2,Z_ERRNO:-1,Z_STREAM_ERROR:-2,Z_DATA_ERROR:-3,Z_BUF_ERROR:-5,Z_NO_COMPRESSION:0,Z_BEST_SPEED:1,Z_BEST_COMPRESSION:9,Z_DEFAULT_COMPRESSION:-1,Z_FILTERED:1,Z_HUFFMAN_ONLY:2,Z_RLE:3,Z_FIXED:4,Z_DEFAULT_STRATEGY:0,Z_BINARY:0,Z_TEXT:1,Z_UNKNOWN:2,Z_DEFLATED:8,Zlib:mo});var So={};Object.keys(Eo).forEach(function(e){So[e]=Eo[e]}),So.Z_MIN_WINDOWBITS=8,So.Z_MAX_WINDOWBITS=15,So.Z_DEFAULT_WINDOWBITS=15,So.Z_MIN_CHUNK=64,So.Z_MAX_CHUNK=1/0,So.Z_DEFAULT_CHUNK=16384,So.Z_MIN_MEMLEVEL=1,So.Z_MAX_MEMLEVEL=9,So.Z_DEFAULT_MEMLEVEL=8,So.Z_MIN_LEVEL=-1,So.Z_MAX_LEVEL=9,So.Z_DEFAULT_LEVEL=So.Z_DEFAULT_COMPRESSION;var xo={Z_OK:So.Z_OK,Z_STREAM_END:So.Z_STREAM_END,Z_NEED_DICT:So.Z_NEED_DICT,Z_ERRNO:So.Z_ERRNO,Z_STREAM_ERROR:So.Z_STREAM_ERROR,Z_DATA_ERROR:So.Z_DATA_ERROR,Z_MEM_ERROR:So.Z_MEM_ERROR,Z_BUF_ERROR:So.Z_BUF_ERROR,Z_VERSION_ERROR:So.Z_VERSION_ERROR};function Ro(e,t,r){var n=[],i=0;function o(){for(var t;null!==(t=e.read());)n.push(t),i+=t.length;e.once("readable",o)}function a(){var t=p.concat(n,i);n=[],r(null,t),e.close()}e.on("error",function(t){e.removeListener("end",a),e.removeListener("readable",o),r(t)}),e.on("end",a),e.end(t),o()}function Ao(e,t){if("string"==typeof t&&(t=new p(t)),!$(t))throw new TypeError("Not a string or buffer");var r=So.Z_FINISH;return e._processChunk(t,r)}function Bo(e){if(!(this instanceof Bo))return new Bo(e);Io.call(this,e,So.DEFLATE)}function zo(e){if(!(this instanceof zo))return new zo(e);Io.call(this,e,So.INFLATE)}function Lo(e){if(!(this instanceof Lo))return new Lo(e);Io.call(this,e,So.GZIP)}function To(e){if(!(this instanceof To))return new To(e);Io.call(this,e,So.GUNZIP)}function Mo(e){if(!(this instanceof Mo))return new Mo(e);Io.call(this,e,So.DEFLATERAW)}function Co(e){if(!(this instanceof Co))return new Co(e);Io.call(this,e,So.INFLATERAW)}function Do(e){if(!(this instanceof Do))return new Do(e);Io.call(this,e,So.UNZIP)}function Io(e,t){if(this._opts=e=e||{},this._chunkSize=e.chunkSize||So.Z_DEFAULT_CHUNK,Ot.call(this,e),e.flush&&e.flush!==So.Z_NO_FLUSH&&e.flush!==So.Z_PARTIAL_FLUSH&&e.flush!==So.Z_SYNC_FLUSH&&e.flush!==So.Z_FULL_FLUSH&&e.flush!==So.Z_FINISH&&e.flush!==So.Z_BLOCK)throw new Error("Invalid flush flag: "+e.flush);if(this._flushFlag=e.flush||So.Z_NO_FLUSH,e.chunkSize&&(e.chunkSize<So.Z_MIN_CHUNK||e.chunkSize>So.Z_MAX_CHUNK))throw new Error("Invalid chunk size: "+e.chunkSize);if(e.windowBits&&(e.windowBits<So.Z_MIN_WINDOWBITS||e.windowBits>So.Z_MAX_WINDOWBITS))throw new Error("Invalid windowBits: "+e.windowBits);if(e.level&&(e.level<So.Z_MIN_LEVEL||e.level>So.Z_MAX_LEVEL))throw new Error("Invalid compression level: "+e.level);if(e.memLevel&&(e.memLevel<So.Z_MIN_MEMLEVEL||e.memLevel>So.Z_MAX_MEMLEVEL))throw new Error("Invalid memLevel: "+e.memLevel);if(e.strategy&&e.strategy!=So.Z_FILTERED&&e.strategy!=So.Z_HUFFMAN_ONLY&&e.strategy!=So.Z_RLE&&e.strategy!=So.Z_FIXED&&e.strategy!=So.Z_DEFAULT_STRATEGY)throw new Error("Invalid strategy: "+e.strategy);if(e.dictionary&&!$(e.dictionary))throw new Error("Invalid dictionary: it should be a Buffer instance");this._binding=new So.Zlib(t);var r=this;this._hadError=!1,this._binding.onerror=function(e,t){r._binding=null,r._hadError=!0;var n=new Error(e);n.errno=t,n.code=So.codes[t],r.emit("error",n)};var n=So.Z_DEFAULT_COMPRESSION;"number"==typeof e.level&&(n=e.level);var i=So.Z_DEFAULT_STRATEGY;"number"==typeof e.strategy&&(i=e.strategy),this._binding.init(e.windowBits||So.Z_DEFAULT_WINDOWBITS,n,e.memLevel||So.Z_DEFAULT_MEMLEVEL,i,e.dictionary),this._buffer=new p(this._chunkSize),this._offset=0,this._closed=!1,this._level=n,this._strategy=i,this.once("end",this.close)}Object.keys(xo).forEach(function(e){xo[xo[e]]=e}),Be(Io,Ot),Io.prototype.params=function(e,t,r){if(e<So.Z_MIN_LEVEL||e>So.Z_MAX_LEVEL)throw new RangeError("Invalid compression level: "+e);if(t!=So.Z_FILTERED&&t!=So.Z_HUFFMAN_ONLY&&t!=So.Z_RLE&&t!=So.Z_FIXED&&t!=So.Z_DEFAULT_STRATEGY)throw new TypeError("Invalid strategy: "+t);if(this._level!==e||this._strategy!==t){var n=this;this.flush(So.Z_SYNC_FLUSH,function(){n._binding.params(e,t),n._hadError||(n._level=e,n._strategy=t,r&&r())})}else de(r)},Io.prototype.reset=function(){return this._binding.reset()},Io.prototype._flush=function(e){this._transform(new p(0),"",e)},Io.prototype.flush=function(e,t){var r=this._writableState;if(("function"==typeof e||void 0===e&&!t)&&(t=e,e=So.Z_FULL_FLUSH),r.ended)t&&de(t);else if(r.ending)t&&this.once("end",t);else if(r.needDrain){var n=this;this.once("drain",function(){n.flush(t)})}else this._flushFlag=e,this.write(new p(0),"",t)},Io.prototype.close=function(e){if(e&&de(e),!this._closed){this._closed=!0,this._binding.close();var t=this;de(function(){t.emit("close")})}},Io.prototype._transform=function(e,t,r){var n,i=this._writableState,o=(i.ending||i.ended)&&(!e||i.length===e.length);if(null===!e&&!$(e))return r(new Error("invalid input"));o?n=So.Z_FINISH:(n=this._flushFlag,e.length>=i.length&&(this._flushFlag=this._opts.flush||So.Z_NO_FLUSH)),this._processChunk(e,n,r)},Io.prototype._processChunk=function(e,t,r){var n=e&&e.length,i=this._chunkSize-this._offset,o=0,a=this,s="function"==typeof r;if(!s){var h,l=[],f=0;this.on("error",function(e){h=e});do{var c=this._binding.writeSync(t,e,o,n,this._buffer,this._offset,i)}while(!this._hadError&&_(c[0],c[1]));if(this._hadError)throw h;var u=p.concat(l,f);return this.close(),u}var d=this._binding.write(t,e,o,n,this._buffer,this._offset,i);function _(h,c){if(!a._hadError){var u=i-c;if(function(e,t){if(!e)throw new Error(t)}(u>=0,"have should not go down"),u>0){var d=a._buffer.slice(a._offset,a._offset+u);a._offset+=u,s?a.push(d):(l.push(d),f+=d.length)}if((0===c||a._offset>=a._chunkSize)&&(i=a._chunkSize,a._offset=0,a._buffer=new p(a._chunkSize)),0===c){if(o+=n-h,n=h,!s)return!0;var g=a._binding.write(t,e,o,n,a._buffer,a._offset,a._chunkSize);return g.callback=_,void(g.buffer=e)}if(!s)return!1;r()}}d.buffer=e,d.callback=_},Be(Bo,Io),Be(zo,Io),Be(Lo,Io),Be(To,Io),Be(Mo,Io),Be(Co,Io),Be(Do,Io);var Po={codes:xo,createDeflate:function(e){return new Bo(e)},createInflate:function(e){return new zo(e)},createDeflateRaw:function(e){return new Mo(e)},createInflateRaw:function(e){return new Co(e)},createGzip:function(e){return new Lo(e)},createGunzip:function(e){return new To(e)},createUnzip:function(e){return new Do(e)},deflate:function(e,t,r){return"function"==typeof t&&(r=t,t={}),Ro(new Bo(t),e,r)},deflateSync:function(e,t){return Ao(new Bo(t),e)},gzip:function(e,t,r){return"function"==typeof t&&(r=t,t={}),Ro(new Lo(t),e,r)},gzipSync:function(e,t){return Ao(new Lo(t),e)},deflateRaw:function(e,t,r){return"function"==typeof t&&(r=t,t={}),Ro(new Mo(t),e,r)},deflateRawSync:function(e,t){return Ao(new Mo(t),e)},unzip:function(e,t,r){return"function"==typeof t&&(r=t,t={}),Ro(new Do(t),e,r)},unzipSync:function(e,t){return Ao(new Do(t),e)},inflate:function(e,t,r){return"function"==typeof t&&(r=t,t={}),Ro(new zo(t),e,r)},inflateSync:function(e,t){return Ao(new zo(t),e)},gunzip:function(e,t,r){return"function"==typeof t&&(r=t,t={}),Ro(new To(t),e,r)},gunzipSync:function(e,t){return Ao(new To(t),e)},inflateRaw:function(e,t,r){return"function"==typeof t&&(r=t,t={}),Ro(new Co(t),e,r)},inflateRawSync:function(e,t){return Ao(new Co(t),e)},Deflate:Bo,Inflate:zo,Gzip:Lo,Gunzip:To,DeflateRaw:Mo,InflateRaw:Co,Unzip:Do,Zlib:Io};/* harmony default export */ __webpack_exports__["a"] = (class{constructor(e,t,r){this.SDKAPPID=e,this.EXPIRETIME=r,this.PRIVATEKEY=t}genTestUserSig(e){return this._isNumber(this.SDKAPPID)?this._isString(this.PRIVATEKEY)?this._isString(e)?this._isNumber(this.EXPIRETIME)?(console.log("SDKAppID="+this.SDKAPPID+" key="+this.PRIVATEKEY+" userID="+e+" expire="+this.EXPIRETIME),this.genSigWithUserbuf(e,this.EXPIRETIME,null)):(console.error("expireTime must be a number"),""):(console.error("userID must be a string"),""):(console.error("privateKey must be a string"),""):(console.error("SDKAppID must be a number"),"")}newBuffer(e,t){return p.from?p.from(e,t):new p(e,t)}unescape(e){return e.replace(/_/g,"=").replace(/\-/g,"/").replace(/\*/g,"+")}escape(e){return e.replace(/\+/g,"*").replace(/\//g,"-").replace(/=/g,"_")}encode(e){return this.escape(this.newBuffer(e).toString("base64"))}decode(e){return this.newBuffer(this.unescape(e),"base64")}base64encode(e){return this.newBuffer(e).toString("base64")}base64decode(e){return this.newBuffer(e,"base64").toString()}_hmacsha256(e,t,r,n){let i="TLS.identifier:"+e+"\n";i+="TLS.sdkappid:"+this.SDKAPPID+"\n",i+="TLS.time:"+t+"\n",i+="TLS.expire:"+r+"\n",null!=n&&(i+="TLS.userbuf:"+n+"\n");let o=te.HmacSHA256(i,this.PRIVATEKEY);return te.enc.Base64.stringify(o)}_utc(){return Math.round(Date.now()/1e3)}_isNumber(e){return null!==e&&("number"==typeof e&&!isNaN(e-0)||"object"==typeof e&&e.constructor===Number)}_isString(e){return"string"==typeof e}genSigWithUserbuf(e,t,r){let n=this._utc(),i={"TLS.ver":"2.0","TLS.identifier":e,"TLS.sdkappid":this.SDKAPPID,"TLS.time":n,"TLS.expire":t},o="";if(null!=r){let a=this.base64encode(r);i["TLS.userbuf"]=a,o=this._hmacsha256(e,n,t,a)}else o=this._hmacsha256(e,n,t,null);i["TLS.sig"]=o;let a=JSON.stringify(i),s=Po.deflateSync(this.newBuffer(a)).toString("base64"),h=this.escape(s);return console.log("ret="+h),h}validate(e){let t=this.decode(e),r=Po.inflateSync(t);console.log("validate ret="+r)}});

/* WEBPACK VAR INJECTION */}.call(__webpack_exports__, __webpack_require__(8)))

/***/ }),
/* 76 */,
/* 77 */,
/* 78 */,
/* 79 */,
/* 80 */,
/* 81 */
/***/ (function(module, exports, __webpack_require__) {

module.exports = { "default": __webpack_require__(82), __esModule: true };

/***/ }),
/* 82 */
/***/ (function(module, exports, __webpack_require__) {

__webpack_require__(83);
module.exports = __webpack_require__(6).Object.assign;


/***/ }),
/* 83 */
/***/ (function(module, exports, __webpack_require__) {

// 19.1.3.1 Object.assign(target, source)
var $export = __webpack_require__(16);

$export($export.S + $export.F, 'Object', { assign: __webpack_require__(84) });


/***/ }),
/* 84 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";

// 19.1.2.1 Object.assign(target, source, ...)
var DESCRIPTORS = __webpack_require__(7);
var getKeys = __webpack_require__(27);
var gOPS = __webpack_require__(85);
var pIE = __webpack_require__(86);
var toObject = __webpack_require__(22);
var IObject = __webpack_require__(29);
var $assign = Object.assign;

// should work with symbols and should have deterministic property order (V8 bug)
module.exports = !$assign || __webpack_require__(18)(function () {
  var A = {};
  var B = {};
  // eslint-disable-next-line no-undef
  var S = Symbol();
  var K = 'abcdefghijklmnopqrst';
  A[S] = 7;
  K.split('').forEach(function (k) { B[k] = k; });
  return $assign({}, A)[S] != 7 || Object.keys($assign({}, B)).join('') != K;
}) ? function assign(target, source) { // eslint-disable-line no-unused-vars
  var T = toObject(target);
  var aLen = arguments.length;
  var index = 1;
  var getSymbols = gOPS.f;
  var isEnum = pIE.f;
  while (aLen > index) {
    var S = IObject(arguments[index++]);
    var keys = getSymbols ? getKeys(S).concat(getSymbols(S)) : getKeys(S);
    var length = keys.length;
    var j = 0;
    var key;
    while (length > j) {
      key = keys[j++];
      if (!DESCRIPTORS || isEnum.call(S, key)) T[key] = S[key];
    }
  } return T;
} : $assign;


/***/ }),
/* 85 */
/***/ (function(module, exports) {

exports.f = Object.getOwnPropertySymbols;


/***/ }),
/* 86 */
/***/ (function(module, exports) {

exports.f = {}.propertyIsEnumerable;


/***/ }),
/* 87 */,
/* 88 */,
/* 89 */,
/* 90 */,
/* 91 */,
/* 92 */,
/* 93 */,
/* 94 */,
/* 95 */,
/* 96 */,
/* 97 */,
/* 98 */,
/* 99 */,
/* 100 */,
/* 101 */,
/* 102 */,
/* 103 */,
/* 104 */,
/* 105 */,
/* 106 */,
/* 107 */,
/* 108 */,
/* 109 */,
/* 110 */,
/* 111 */,
/* 112 */,
/* 113 */,
/* 114 */,
/* 115 */,
/* 116 */,
/* 117 */,
/* 118 */,
/* 119 */,
/* 120 */,
/* 121 */,
/* 122 */,
/* 123 */,
/* 124 */,
/* 125 */,
/* 126 */,
/* 127 */,
/* 128 */,
/* 129 */,
/* 130 */,
/* 131 */,
/* 132 */,
/* 133 */,
/* 134 */,
/* 135 */,
/* 136 */,
/* 137 */,
/* 138 */,
/* 139 */,
/* 140 */,
/* 141 */,
/* 142 */,
/* 143 */,
/* 144 */,
/* 145 */,
/* 146 */,
/* 147 */,
/* 148 */,
/* 149 */,
/* 150 */,
/* 151 */,
/* 152 */,
/* 153 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


/*
  MIT License http://www.opensource.org/licenses/mit-license.php
  Author Tobias Koppers @sokra
*/
// css base code, injected by the css-loader
// eslint-disable-next-line func-names
module.exports = function (useSourceMap) {
  var list = []; // return the list of modules as css string

  list.toString = function toString() {
    return this.map(function (item) {
      var content = cssWithMappingToString(item, useSourceMap);

      if (item[2]) {
        return "@media ".concat(item[2], "{").concat(content, "}");
      }

      return content;
    }).join('');
  }; // import a list of modules into the list
  // eslint-disable-next-line func-names


  list.i = function (modules, mediaQuery) {
    if (typeof modules === 'string') {
      // eslint-disable-next-line no-param-reassign
      modules = [[null, modules, '']];
    }

    var alreadyImportedModules = {};

    for (var i = 0; i < this.length; i++) {
      // eslint-disable-next-line prefer-destructuring
      var id = this[i][0];

      if (id != null) {
        alreadyImportedModules[id] = true;
      }
    }

    for (var _i = 0; _i < modules.length; _i++) {
      var item = modules[_i]; // skip already imported module
      // this implementation is not 100% perfect for weird media query combinations
      // when a module is imported multiple times with different media queries.
      // I hope this will never occur (Hey this way we have smaller bundles)

      if (item[0] == null || !alreadyImportedModules[item[0]]) {
        if (mediaQuery && !item[2]) {
          item[2] = mediaQuery;
        } else if (mediaQuery) {
          item[2] = "(".concat(item[2], ") and (").concat(mediaQuery, ")");
        }

        list.push(item);
      }
    }
  };

  return list;
};

function cssWithMappingToString(item, useSourceMap) {
  var content = item[1] || ''; // eslint-disable-next-line prefer-destructuring

  var cssMapping = item[3];

  if (!cssMapping) {
    return content;
  }

  if (useSourceMap && typeof btoa === 'function') {
    var sourceMapping = toComment(cssMapping);
    var sourceURLs = cssMapping.sources.map(function (source) {
      return "/*# sourceURL=".concat(cssMapping.sourceRoot).concat(source, " */");
    });
    return [content].concat(sourceURLs).concat([sourceMapping]).join('\n');
  }

  return [content].join('\n');
} // Adapted from convert-source-map (MIT)


function toComment(sourceMap) {
  // eslint-disable-next-line no-undef
  var base64 = btoa(unescape(encodeURIComponent(JSON.stringify(sourceMap))));
  var data = "sourceMappingURL=data:application/json;charset=utf-8;base64,".concat(base64);
  return "/*# ".concat(data, " */");
}

/***/ }),
/* 154 */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
/* harmony export (immutable) */ __webpack_exports__["default"] = addStylesClient;
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__listToStyles__ = __webpack_require__(41);
/*
  MIT License http://www.opensource.org/licenses/mit-license.php
  Author Tobias Koppers @sokra
  Modified by Evan You @yyx990803
*/



var hasDocument = typeof document !== 'undefined'

if (typeof DEBUG !== 'undefined' && DEBUG) {
  if (!hasDocument) {
    throw new Error(
    'vue-style-loader cannot be used in a non-browser environment. ' +
    "Use { target: 'node' } in your Webpack config to indicate a server-rendering environment."
  ) }
}

/*
type StyleObject = {
  id: number;
  parts: Array<StyleObjectPart>
}

type StyleObjectPart = {
  css: string;
  media: string;
  sourceMap: ?string
}
*/

var stylesInDom = {/*
  [id: number]: {
    id: number,
    refs: number,
    parts: Array<(obj?: StyleObjectPart) => void>
  }
*/}

var head = hasDocument && (document.head || document.getElementsByTagName('head')[0])
var singletonElement = null
var singletonCounter = 0
var isProduction = false
var noop = function () {}
var options = null
var ssrIdKey = 'data-vue-ssr-id'

// Force single-tag solution on IE6-9, which has a hard limit on the # of <style>
// tags it will allow on a page
var isOldIE = typeof navigator !== 'undefined' && /msie [6-9]\b/.test(navigator.userAgent.toLowerCase())

function addStylesClient (parentId, list, _isProduction, _options) {
  isProduction = _isProduction

  options = _options || {}

  var styles = Object(__WEBPACK_IMPORTED_MODULE_0__listToStyles__["a" /* default */])(parentId, list)
  addStylesToDom(styles)

  return function update (newList) {
    var mayRemove = []
    for (var i = 0; i < styles.length; i++) {
      var item = styles[i]
      var domStyle = stylesInDom[item.id]
      domStyle.refs--
      mayRemove.push(domStyle)
    }
    if (newList) {
      styles = Object(__WEBPACK_IMPORTED_MODULE_0__listToStyles__["a" /* default */])(parentId, newList)
      addStylesToDom(styles)
    } else {
      styles = []
    }
    for (var i = 0; i < mayRemove.length; i++) {
      var domStyle = mayRemove[i]
      if (domStyle.refs === 0) {
        for (var j = 0; j < domStyle.parts.length; j++) {
          domStyle.parts[j]()
        }
        delete stylesInDom[domStyle.id]
      }
    }
  }
}

function addStylesToDom (styles /* Array<StyleObject> */) {
  for (var i = 0; i < styles.length; i++) {
    var item = styles[i]
    var domStyle = stylesInDom[item.id]
    if (domStyle) {
      domStyle.refs++
      for (var j = 0; j < domStyle.parts.length; j++) {
        domStyle.parts[j](item.parts[j])
      }
      for (; j < item.parts.length; j++) {
        domStyle.parts.push(addStyle(item.parts[j]))
      }
      if (domStyle.parts.length > item.parts.length) {
        domStyle.parts.length = item.parts.length
      }
    } else {
      var parts = []
      for (var j = 0; j < item.parts.length; j++) {
        parts.push(addStyle(item.parts[j]))
      }
      stylesInDom[item.id] = { id: item.id, refs: 1, parts: parts }
    }
  }
}

function createStyleElement () {
  var styleElement = document.createElement('style')
  styleElement.type = 'text/css'
  head.appendChild(styleElement)
  return styleElement
}

function addStyle (obj /* StyleObjectPart */) {
  var update, remove
  var styleElement = document.querySelector('style[' + ssrIdKey + '~="' + obj.id + '"]')

  if (styleElement) {
    if (isProduction) {
      // has SSR styles and in production mode.
      // simply do nothing.
      return noop
    } else {
      // has SSR styles but in dev mode.
      // for some reason Chrome can't handle source map in server-rendered
      // style tags - source maps in <style> only works if the style tag is
      // created and inserted dynamically. So we remove the server rendered
      // styles and inject new ones.
      styleElement.parentNode.removeChild(styleElement)
    }
  }

  if (isOldIE) {
    // use singleton mode for IE9.
    var styleIndex = singletonCounter++
    styleElement = singletonElement || (singletonElement = createStyleElement())
    update = applyToSingletonTag.bind(null, styleElement, styleIndex, false)
    remove = applyToSingletonTag.bind(null, styleElement, styleIndex, true)
  } else {
    // use multi-style-tag mode in all other cases
    styleElement = createStyleElement()
    update = applyToTag.bind(null, styleElement)
    remove = function () {
      styleElement.parentNode.removeChild(styleElement)
    }
  }

  update(obj)

  return function updateStyle (newObj /* StyleObjectPart */) {
    if (newObj) {
      if (newObj.css === obj.css &&
          newObj.media === obj.media &&
          newObj.sourceMap === obj.sourceMap) {
        return
      }
      update(obj = newObj)
    } else {
      remove()
    }
  }
}

var replaceText = (function () {
  var textStore = []

  return function (index, replacement) {
    textStore[index] = replacement
    return textStore.filter(Boolean).join('\n')
  }
})()

function applyToSingletonTag (styleElement, index, remove, obj) {
  var css = remove ? '' : obj.css

  if (styleElement.styleSheet) {
    styleElement.styleSheet.cssText = replaceText(index, css)
  } else {
    var cssNode = document.createTextNode(css)
    var childNodes = styleElement.childNodes
    if (childNodes[index]) styleElement.removeChild(childNodes[index])
    if (childNodes.length) {
      styleElement.insertBefore(cssNode, childNodes[index])
    } else {
      styleElement.appendChild(cssNode)
    }
  }
}

function applyToTag (styleElement, obj) {
  var css = obj.css
  var media = obj.media
  var sourceMap = obj.sourceMap

  if (media) {
    styleElement.setAttribute('media', media)
  }
  if (options.ssrId) {
    styleElement.setAttribute(ssrIdKey, obj.id)
  }

  if (sourceMap) {
    // https://developer.chrome.com/devtools/docs/javascript-debugging
    // this makes source maps inside style tags work properly in Chrome
    css += '\n/*# sourceURL=' + sourceMap.sources[0] + ' */'
    // http://stackoverflow.com/a/26603875
    css += '\n/*# sourceMappingURL=data:application/json;base64,' + btoa(unescape(encodeURIComponent(JSON.stringify(sourceMap)))) + ' */'
  }

  if (styleElement.styleSheet) {
    styleElement.styleSheet.cssText = css
  } else {
    while (styleElement.firstChild) {
      styleElement.removeChild(styleElement.firstChild)
    }
    styleElement.appendChild(document.createTextNode(css))
  }
}


/***/ })
]);