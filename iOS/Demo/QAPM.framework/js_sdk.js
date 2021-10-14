(function webpackUniversalModuleDefinition(root, factory) {
    if(typeof exports === 'object' && typeof module === 'object')
        module.exports = factory();
    else if(typeof define === 'function' && define.amd)
        define([], factory);
    else if(typeof exports === 'object')
        exports["QAPMMonitorJS"] = factory();
    else
        root["QAPMMonitorJS"] = factory();
})(this, function() {
return /******/ (function(modules) { // webpackBootstrap
/******/     // The module cache
/******/     var installedModules = {};
/******/
/******/     // The require function
/******/     function __webpack_require__(moduleId) {
/******/
/******/         // Check if module is in cache
/******/         if(installedModules[moduleId]) {
/******/             return installedModules[moduleId].exports;
/******/         }
/******/         // Create a new module (and put it into the cache)
/******/         var module = installedModules[moduleId] = {
/******/             i: moduleId,
/******/             l: false,
/******/             exports: {}
/******/         };
/******/
/******/         // Execute the module function
/******/         modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/         // Flag the module as loaded
/******/         module.l = true;
/******/
/******/         // Return the exports of the module
/******/         return module.exports;
/******/     }
/******/
/******/
/******/     // expose the modules object (__webpack_modules__)
/******/     __webpack_require__.m = modules;
/******/
/******/     // expose the module cache
/******/     __webpack_require__.c = installedModules;
/******/
/******/     // define getter function for harmony exports
/******/     __webpack_require__.d = function(exports, name, getter) {
/******/         if(!__webpack_require__.o(exports, name)) {
/******/             Object.defineProperty(exports, name, { enumerable: true, get: getter });
/******/         }
/******/     };
/******/
/******/     // define __esModule on exports
/******/     __webpack_require__.r = function(exports) {
/******/         if(typeof Symbol !== 'undefined' && Symbol.toStringTag) {
/******/             Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' });
/******/         }
/******/         Object.defineProperty(exports, '__esModule', { value: true });
/******/     };
/******/
/******/     // create a fake namespace object
/******/     // mode & 1: value is a module id, require it
/******/     // mode & 2: merge all properties of value into the ns
/******/     // mode & 4: return value when already ns object
/******/     // mode & 8|1: behave like require
/******/     __webpack_require__.t = function(value, mode) {
/******/         if(mode & 1) value = __webpack_require__(value);
/******/         if(mode & 8) return value;
/******/         if((mode & 4) && typeof value === 'object' && value && value.__esModule) return value;
/******/         var ns = Object.create(null);
/******/         __webpack_require__.r(ns);
/******/         Object.defineProperty(ns, 'default', { enumerable: true, value: value });
/******/         if(mode & 2 && typeof value != 'string') for(var key in value) __webpack_require__.d(ns, key, function(key) { return value[key]; }.bind(null, key));
/******/         return ns;
/******/     };
/******/
/******/     // getDefaultExport function for compatibility with non-harmony modules
/******/     __webpack_require__.n = function(module) {
/******/         var getter = module && module.__esModule ?
/******/             function getDefault() { return module['default']; } :
/******/             function getModuleExports() { return module; };
/******/         __webpack_require__.d(getter, 'a', getter);
/******/         return getter;
/******/     };
/******/
/******/     // Object.prototype.hasOwnProperty.call
/******/     __webpack_require__.o = function(object, property) { return Object.prototype.hasOwnProperty.call(object, property); };
/******/
/******/     // __webpack_public_path__
/******/     __webpack_require__.p = "";
/******/
/******/
/******/     // Load entry module and return exports
/******/     return __webpack_require__(__webpack_require__.s = "./src/index.js");
/******/ })
/************************************************************************/
/******/ ({

/***/ "../../node_modules/dom-utils/index.js":
/*!************************************************************************************************!*\
  !*** /Users/nickyliu/code/QAPM/javascript_monitor/qapm-sentry/node_modules/dom-utils/index.js ***!
  \************************************************************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.parseUrl = exports.parents = exports.matches = exports.getAttributes = exports.dispatch = exports.delegate = exports.closest = undefined;

var _closest = __webpack_require__(/*! ./lib/closest */ "../../node_modules/dom-utils/lib/closest.js");

var _closest2 = _interopRequireDefault(_closest);

var _delegate = __webpack_require__(/*! ./lib/delegate */ "../../node_modules/dom-utils/lib/delegate.js");

var _delegate2 = _interopRequireDefault(_delegate);

var _dispatch = __webpack_require__(/*! ./lib/dispatch */ "../../node_modules/dom-utils/lib/dispatch.js");

var _dispatch2 = _interopRequireDefault(_dispatch);

var _getAttributes = __webpack_require__(/*! ./lib/get-attributes */ "../../node_modules/dom-utils/lib/get-attributes.js");

var _getAttributes2 = _interopRequireDefault(_getAttributes);

var _matches = __webpack_require__(/*! ./lib/matches */ "../../node_modules/dom-utils/lib/matches.js");

var _matches2 = _interopRequireDefault(_matches);

var _parents = __webpack_require__(/*! ./lib/parents */ "../../node_modules/dom-utils/lib/parents.js");

var _parents2 = _interopRequireDefault(_parents);

var _parseUrl = __webpack_require__(/*! ./lib/parse-url */ "../../node_modules/dom-utils/lib/parse-url.js");

var _parseUrl2 = _interopRequireDefault(_parseUrl);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

exports.closest = _closest2.default;
exports.delegate = _delegate2.default;
exports.dispatch = _dispatch2.default;
exports.getAttributes = _getAttributes2.default;
exports.matches = _matches2.default;
exports.parents = _parents2.default;
exports.parseUrl = _parseUrl2.default;

/***/ }),

/***/ "../../node_modules/dom-utils/lib/closest.js":
/*!******************************************************************************************************!*\
  !*** /Users/nickyliu/code/QAPM/javascript_monitor/qapm-sentry/node_modules/dom-utils/lib/closest.js ***!
  \******************************************************************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = closest;

var _matches = __webpack_require__(/*! ./matches */ "../../node_modules/dom-utils/lib/matches.js");

var _matches2 = _interopRequireDefault(_matches);

var _parents = __webpack_require__(/*! ./parents */ "../../node_modules/dom-utils/lib/parents.js");

var _parents2 = _interopRequireDefault(_parents);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

/**
 * Gets the closest parent element that matches the passed selector.
 * @param {Element} element The element whose parents to check.
 * @param {string} selector The CSS selector to match against.
 * @param {boolean=} shouldCheckSelf True if the selector should test against
 *     the passed element itself.
 * @return {Element|undefined} The matching element or undefined.
 */
function closest(element, selector) {
  var shouldCheckSelf = arguments.length > 2 && arguments[2] !== undefined ? arguments[2] : false;

  if (!(element && element.nodeType == 1 && selector)) return;
  var parentElements = (shouldCheckSelf ? [element] : []).concat((0, _parents2.default)(element));

  for (var i = 0, parent; parent = parentElements[i]; i++) {
    if ((0, _matches2.default)(parent, selector)) return parent;
  }
}

/***/ }),

/***/ "../../node_modules/dom-utils/lib/delegate.js":
/*!*******************************************************************************************************!*\
  !*** /Users/nickyliu/code/QAPM/javascript_monitor/qapm-sentry/node_modules/dom-utils/lib/delegate.js ***!
  \*******************************************************************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = delegate;

var _closest = __webpack_require__(/*! ./closest */ "../../node_modules/dom-utils/lib/closest.js");

var _closest2 = _interopRequireDefault(_closest);

var _matches = __webpack_require__(/*! ./matches */ "../../node_modules/dom-utils/lib/matches.js");

var _matches2 = _interopRequireDefault(_matches);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

/**
 * Delegates the handling of events for an element matching a selector to an
 * ancestor of the matching element.
 * @param {!Node} ancestor The ancestor element to add the listener to.
 * @param {string} eventType The event type to listen to.
 * @param {string} selector A CSS selector to match against child elements.
 * @param {!Function} callback A function to run any time the event happens.
 * @param {Object=} opts A configuration options object. The available options:
 *     - useCapture<boolean>: If true, bind to the event capture phase.
 *     - deep<boolean>: If true, delegate into shadow trees.
 * @return {Object} The delegate object. It contains a destroy method.
 */
function delegate(ancestor, eventType, selector, callback) {
  var opts = arguments.length > 4 && arguments[4] !== undefined ? arguments[4] : {};

  // Defines the event listener.
  var listener = function listener(event) {
    var delegateTarget = void 0;

    // If opts.composed is true and the event originated from inside a Shadow
    // tree, check the composed path nodes.
    if (opts.composed && typeof event.composedPath == 'function') {
      var composedPath = event.composedPath();
      for (var i = 0, node; node = composedPath[i]; i++) {
        if (node.nodeType == 1 && (0, _matches2.default)(node, selector)) {
          delegateTarget = node;
        }
      }
    } else {
      // Otherwise check the parents.
      delegateTarget = (0, _closest2.default)(event.target, selector, true);
    }

    if (delegateTarget) {
      callback.call(delegateTarget, event, delegateTarget);
    }
  };

  ancestor.addEventListener(eventType, listener, opts.useCapture);

  return {
    destroy: function destroy() {
      ancestor.removeEventListener(eventType, listener, opts.useCapture);
    }
  };
}

/***/ }),

/***/ "../../node_modules/dom-utils/lib/dispatch.js":
/*!*******************************************************************************************************!*\
  !*** /Users/nickyliu/code/QAPM/javascript_monitor/qapm-sentry/node_modules/dom-utils/lib/dispatch.js ***!
  \*******************************************************************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
  value: true
});

var _typeof = typeof Symbol === "function" && typeof Symbol.iterator === "symbol" ? function (obj) { return typeof obj; } : function (obj) { return obj && typeof Symbol === "function" && obj.constructor === Symbol && obj !== Symbol.prototype ? "symbol" : typeof obj; };

exports.default = dispatch;
/**
 * Dispatches an event on the passed element.
 * @param {!Element} element The DOM element to dispatch the event on.
 * @param {string} eventType The type of event to dispatch.
 * @param {Object|string=} eventName A string name of the event constructor
 *     to use. Defaults to 'Event' if nothing is passed or 'CustomEvent' if
 *     a value is set on `initDict.detail`. If eventName is given an object
 *     it is assumed to be initDict and thus reassigned.
 * @param {Object=} initDict The initialization attributes for the
 *     event. A `detail` property can be used here to pass custom data.
 * @return {boolean} The return value of `element.dispatchEvent`, which will
 *     be false if any of the event listeners called `preventDefault`.
 */
function dispatch(element, eventType) {
  var eventName = arguments.length > 2 && arguments[2] !== undefined ? arguments[2] : 'Event';
  var initDict = arguments.length > 3 && arguments[3] !== undefined ? arguments[3] : {};

  var event = void 0;
  var isCustom = void 0;

  // eventName is optional
  if ((typeof eventName === 'undefined' ? 'undefined' : _typeof(eventName)) == 'object') {
    initDict = eventName;
    eventName = 'Event';
  }

  initDict.bubbles = initDict.bubbles || false;
  initDict.cancelable = initDict.cancelable || false;
  initDict.composed = initDict.composed || false;

  // If a detail property is passed, this is a custom event.
  if ('detail' in initDict) isCustom = true;
  eventName = isCustom ? 'CustomEvent' : eventName;

  // Tries to create the event using constructors, if that doesn't work,
  // fallback to `document.createEvent()`.
  try {
    event = new window[eventName](eventType, initDict);
  } catch (err) {
    event = document.createEvent(eventName);
    var initMethod = 'init' + (isCustom ? 'Custom' : '') + 'Event';
    event[initMethod](eventType, initDict.bubbles, initDict.cancelable, initDict.detail);
  }

  return element.dispatchEvent(event);
}

/***/ }),

/***/ "../../node_modules/dom-utils/lib/get-attributes.js":
/*!*************************************************************************************************************!*\
  !*** /Users/nickyliu/code/QAPM/javascript_monitor/qapm-sentry/node_modules/dom-utils/lib/get-attributes.js ***!
  \*************************************************************************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = getAttributes;
/**
 * Gets all attributes of an element as a plain JavaScriot object.
 * @param {Element} element The element whose attributes to get.
 * @return {!Object} An object whose keys are the attribute keys and whose
 *     values are the attribute values. If no attributes exist, an empty
 *     object is returned.
 */
function getAttributes(element) {
  var attrs = {};

  // Validate input.
  if (!(element && element.nodeType == 1)) return attrs;

  // Return an empty object if there are no attributes.
  var map = element.attributes;
  if (map.length === 0) return {};

  for (var i = 0, attr; attr = map[i]; i++) {
    attrs[attr.name] = attr.value;
  }
  return attrs;
}

/***/ }),

/***/ "../../node_modules/dom-utils/lib/matches.js":
/*!******************************************************************************************************!*\
  !*** /Users/nickyliu/code/QAPM/javascript_monitor/qapm-sentry/node_modules/dom-utils/lib/matches.js ***!
  \******************************************************************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = matches;
var proto = window.Element.prototype;
var nativeMatches = proto.matches || proto.matchesSelector || proto.webkitMatchesSelector || proto.mozMatchesSelector || proto.msMatchesSelector || proto.oMatchesSelector;

/**
 * Tests if a DOM elements matches any of the test DOM elements or selectors.
 * @param {Element} element The DOM element to test.
 * @param {Element|string|Array<Element|string>} test A DOM element, a CSS
 *     selector, or an array of DOM elements or CSS selectors to match against.
 * @return {boolean} True of any part of the test matches.
 */
function matches(element, test) {
  // Validate input.
  if (element && element.nodeType == 1 && test) {
    // if test is a string or DOM element test it.
    if (typeof test == 'string' || test.nodeType == 1) {
      return element == test || matchesSelector(element, /** @type {string} */test);
    } else if ('length' in test) {
      // if it has a length property iterate over the items
      // and return true if any match.
      for (var i = 0, item; item = test[i]; i++) {
        if (element == item || matchesSelector(element, item)) return true;
      }
    }
  }
  // Still here? Return false
  return false;
}

/**
 * Tests whether a DOM element matches a selector. This polyfills the native
 * Element.prototype.matches method across browsers.
 * @param {!Element} element The DOM element to test.
 * @param {string} selector The CSS selector to test element against.
 * @return {boolean} True if the selector matches.
 */
function matchesSelector(element, selector) {
  if (typeof selector != 'string') return false;
  if (nativeMatches) return nativeMatches.call(element, selector);
  var nodes = element.parentNode.querySelectorAll(selector);
  for (var i = 0, node; node = nodes[i]; i++) {
    if (node == element) return true;
  }
  return false;
}

/***/ }),

/***/ "../../node_modules/dom-utils/lib/parents.js":
/*!******************************************************************************************************!*\
  !*** /Users/nickyliu/code/QAPM/javascript_monitor/qapm-sentry/node_modules/dom-utils/lib/parents.js ***!
  \******************************************************************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = parents;
/**
 * Returns an array of a DOM element's parent elements.
 * @param {!Element} element The DOM element whose parents to get.
 * @return {!Array} An array of all parent elemets, or an empty array if no
 *     parent elements are found.
 */
function parents(element) {
  var list = [];
  while (element && element.parentNode && element.parentNode.nodeType == 1) {
    element = /** @type {!Element} */element.parentNode;
    list.push(element);
  }
  return list;
}

/***/ }),

/***/ "../../node_modules/dom-utils/lib/parse-url.js":
/*!********************************************************************************************************!*\
  !*** /Users/nickyliu/code/QAPM/javascript_monitor/qapm-sentry/node_modules/dom-utils/lib/parse-url.js ***!
  \********************************************************************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = parseUrl;
var HTTP_PORT = '80';
var HTTPS_PORT = '443';
var DEFAULT_PORT = RegExp(':(' + HTTP_PORT + '|' + HTTPS_PORT + ')$');

var a = document.createElement('a');
var cache = {};

/**
 * Parses the given url and returns an object mimicing a `Location` object.
 * @param {string} url The url to parse.
 * @return {!Object} An object with the same properties as a `Location`.
 */
function parseUrl(url) {
  // All falsy values (as well as ".") should map to the current URL.
  url = !url || url == '.' ? location.href : url;

  if (cache[url]) return cache[url];

  a.href = url;

  // When parsing file relative paths (e.g. `../index.html`), IE will correctly
  // resolve the `href` property but will keep the `..` in the `path` property.
  // It will also not include the `host` or `hostname` properties. Furthermore,
  // IE will sometimes return no protocol or just a colon, especially for things
  // like relative protocol URLs (e.g. "//google.com").
  // To workaround all of these issues, we reparse with the full URL from the
  // `href` property.
  if (url.charAt(0) == '.' || url.charAt(0) == '/') return parseUrl(a.href);

  // Don't include default ports.
  var port = a.port == HTTP_PORT || a.port == HTTPS_PORT ? '' : a.port;

  // PhantomJS sets the port to "0" when using the file: protocol.
  port = port == '0' ? '' : port;

  // Sometimes IE incorrectly includes a port for default ports
  // (e.g. `:80` or `:443`) even when no port is specified in the URL.
  // http://bit.ly/1rQNoMg
  var host = a.host.replace(DEFAULT_PORT, '');

  // Not all browser support `origin` so we have to build it.
  var origin = a.origin ? a.origin : a.protocol + '//' + host;

  // Sometimes IE doesn't include the leading slash for pathname.
  // http://bit.ly/1rQNoMg
  var pathname = a.pathname.charAt(0) == '/' ? a.pathname : '/' + a.pathname;

  return cache[url] = {
    hash: a.hash,
    host: host,
    hostname: a.hostname,
    href: a.href,
    origin: origin,
    pathname: pathname,
    port: port,
    protocol: a.protocol,
    search: a.search
  };
}

/***/ }),

/***/ "../../node_modules/process/browser.js":
/*!************************************************************************************************!*\
  !*** /Users/nickyliu/code/QAPM/javascript_monitor/qapm-sentry/node_modules/process/browser.js ***!
  \************************************************************************************************/
/*! no static exports found */
/***/ (function(module, exports) {

// shim for using process in browser
var process = module.exports = {};

// cached from whatever global is present so that test runners that stub it
// don't break things.  But we need to wrap it in a try catch in case it is
// wrapped in strict mode code which doesn't define any globals.  It's inside a
// function because try/catches deoptimize in certain engines.

var cachedSetTimeout;
var cachedClearTimeout;

function defaultSetTimout() {
    throw new Error('setTimeout has not been defined');
}
function defaultClearTimeout() {
    throw new Error('clearTimeout has not been defined');
}
(function () {
    try {
        if (typeof setTimeout === 'function') {
            cachedSetTimeout = setTimeout;
        } else {
            cachedSetTimeout = defaultSetTimout;
        }
    } catch (e) {
        cachedSetTimeout = defaultSetTimout;
    }
    try {
        if (typeof clearTimeout === 'function') {
            cachedClearTimeout = clearTimeout;
        } else {
            cachedClearTimeout = defaultClearTimeout;
        }
    } catch (e) {
        cachedClearTimeout = defaultClearTimeout;
    }
})();
function runTimeout(fun) {
    if (cachedSetTimeout === setTimeout) {
        //normal enviroments in sane situations
        return setTimeout(fun, 0);
    }
    // if setTimeout wasn't available but was latter defined
    if ((cachedSetTimeout === defaultSetTimout || !cachedSetTimeout) && setTimeout) {
        cachedSetTimeout = setTimeout;
        return setTimeout(fun, 0);
    }
    try {
        // when when somebody has screwed with setTimeout but no I.E. maddness
        return cachedSetTimeout(fun, 0);
    } catch (e) {
        try {
            // When we are in I.E. but the script has been evaled so I.E. doesn't trust the global object when called normally
            return cachedSetTimeout.call(null, fun, 0);
        } catch (e) {
            // same as above but when it's a version of I.E. that must have the global object for 'this', hopfully our context correct otherwise it will throw a global error
            return cachedSetTimeout.call(this, fun, 0);
        }
    }
}
function runClearTimeout(marker) {
    if (cachedClearTimeout === clearTimeout) {
        //normal enviroments in sane situations
        return clearTimeout(marker);
    }
    // if clearTimeout wasn't available but was latter defined
    if ((cachedClearTimeout === defaultClearTimeout || !cachedClearTimeout) && clearTimeout) {
        cachedClearTimeout = clearTimeout;
        return clearTimeout(marker);
    }
    try {
        // when when somebody has screwed with setTimeout but no I.E. maddness
        return cachedClearTimeout(marker);
    } catch (e) {
        try {
            // When we are in I.E. but the script has been evaled so I.E. doesn't  trust the global object when called normally
            return cachedClearTimeout.call(null, marker);
        } catch (e) {
            // same as above but when it's a version of I.E. that must have the global object for 'this', hopfully our context correct otherwise it will throw a global error.
            // Some versions of I.E. have different rules for clearTimeout vs setTimeout
            return cachedClearTimeout.call(this, marker);
        }
    }
}
var queue = [];
var draining = false;
var currentQueue;
var queueIndex = -1;

function cleanUpNextTick() {
    if (!draining || !currentQueue) {
        return;
    }
    draining = false;
    if (currentQueue.length) {
        queue = currentQueue.concat(queue);
    } else {
        queueIndex = -1;
    }
    if (queue.length) {
        drainQueue();
    }
}

function drainQueue() {
    if (draining) {
        return;
    }
    var timeout = runTimeout(cleanUpNextTick);
    draining = true;

    var len = queue.length;
    while (len) {
        currentQueue = queue;
        queue = [];
        while (++queueIndex < len) {
            if (currentQueue) {
                currentQueue[queueIndex].run();
            }
        }
        queueIndex = -1;
        len = queue.length;
    }
    currentQueue = null;
    draining = false;
    runClearTimeout(timeout);
}

process.nextTick = function (fun) {
    var args = new Array(arguments.length - 1);
    if (arguments.length > 1) {
        for (var i = 1; i < arguments.length; i++) {
            args[i - 1] = arguments[i];
        }
    }
    queue.push(new Item(fun, args));
    if (queue.length === 1 && !draining) {
        runTimeout(drainQueue);
    }
};

// v8 likes predictible objects
function Item(fun, array) {
    this.fun = fun;
    this.array = array;
}
Item.prototype.run = function () {
    this.fun.apply(null, this.array);
};
process.title = 'browser';
process.browser = true;
process.env = {};
process.argv = [];
process.version = ''; // empty string to avoid regexp issues
process.versions = {};

function noop() {}

process.on = noop;
process.addListener = noop;
process.once = noop;
process.off = noop;
process.removeListener = noop;
process.removeAllListeners = noop;
process.emit = noop;
process.prependListener = noop;
process.prependOnceListener = noop;

process.listeners = function (name) {
    return [];
};

process.binding = function (name) {
    throw new Error('process.binding is not supported');
};

process.cwd = function () {
    return '/';
};
process.chdir = function (dir) {
    throw new Error('process.chdir is not supported');
};
process.umask = function () {
    return 0;
};

/***/ }),

/***/ "../../node_modules/tslib/tslib.es6.js":
/*!************************************************************************************************!*\
  !*** /Users/nickyliu/code/QAPM/javascript_monitor/qapm-sentry/node_modules/tslib/tslib.es6.js ***!
  \************************************************************************************************/
/*! exports provided: __extends, __assign, __rest, __decorate, __param, __metadata, __awaiter, __generator, __exportStar, __values, __read, __spread, __spreadArrays, __await, __asyncGenerator, __asyncDelegator, __asyncValues, __makeTemplateObject, __importStar, __importDefault, __classPrivateFieldGet, __classPrivateFieldSet */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "__extends", function() { return __extends; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "__assign", function() { return __assign; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "__rest", function() { return __rest; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "__decorate", function() { return __decorate; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "__param", function() { return __param; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "__metadata", function() { return __metadata; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "__awaiter", function() { return __awaiter; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "__generator", function() { return __generator; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "__exportStar", function() { return __exportStar; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "__values", function() { return __values; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "__read", function() { return __read; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "__spread", function() { return __spread; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "__spreadArrays", function() { return __spreadArrays; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "__await", function() { return __await; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "__asyncGenerator", function() { return __asyncGenerator; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "__asyncDelegator", function() { return __asyncDelegator; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "__asyncValues", function() { return __asyncValues; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "__makeTemplateObject", function() { return __makeTemplateObject; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "__importStar", function() { return __importStar; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "__importDefault", function() { return __importDefault; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "__classPrivateFieldGet", function() { return __classPrivateFieldGet; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "__classPrivateFieldSet", function() { return __classPrivateFieldSet; });
/*! *****************************************************************************
Copyright (c) Microsoft Corporation.

Permission to use, copy, modify, and/or distribute this software for any
purpose with or without fee is hereby granted.

THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
PERFORMANCE OF THIS SOFTWARE.
***************************************************************************** */
/* global Reflect, Promise */

var extendStatics = function (d, b) {
    extendStatics = Object.setPrototypeOf || { __proto__: [] } instanceof Array && function (d, b) {
        d.__proto__ = b;
    } || function (d, b) {
        for (var p in b) if (b.hasOwnProperty(p)) d[p] = b[p];
    };
    return extendStatics(d, b);
};

function __extends(d, b) {
    extendStatics(d, b);
    function __() {
        this.constructor = d;
    }
    d.prototype = b === null ? Object.create(b) : (__.prototype = b.prototype, new __());
}

var __assign = function () {
    __assign = Object.assign || function __assign(t) {
        for (var s, i = 1, n = arguments.length; i < n; i++) {
            s = arguments[i];
            for (var p in s) if (Object.prototype.hasOwnProperty.call(s, p)) t[p] = s[p];
        }
        return t;
    };
    return __assign.apply(this, arguments);
};

function __rest(s, e) {
    var t = {};
    for (var p in s) if (Object.prototype.hasOwnProperty.call(s, p) && e.indexOf(p) < 0) t[p] = s[p];
    if (s != null && typeof Object.getOwnPropertySymbols === "function") for (var i = 0, p = Object.getOwnPropertySymbols(s); i < p.length; i++) {
        if (e.indexOf(p[i]) < 0 && Object.prototype.propertyIsEnumerable.call(s, p[i])) t[p[i]] = s[p[i]];
    }
    return t;
}

function __decorate(decorators, target, key, desc) {
    var c = arguments.length,
        r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc,
        d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
}

function __param(paramIndex, decorator) {
    return function (target, key) {
        decorator(target, key, paramIndex);
    };
}

function __metadata(metadataKey, metadataValue) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(metadataKey, metadataValue);
}

function __awaiter(thisArg, _arguments, P, generator) {
    function adopt(value) {
        return value instanceof P ? value : new P(function (resolve) {
            resolve(value);
        });
    }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) {
            try {
                step(generator.next(value));
            } catch (e) {
                reject(e);
            }
        }
        function rejected(value) {
            try {
                step(generator["throw"](value));
            } catch (e) {
                reject(e);
            }
        }
        function step(result) {
            result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected);
        }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
}

function __generator(thisArg, body) {
    var _ = { label: 0, sent: function () {
            if (t[0] & 1) throw t[1];return t[1];
        }, trys: [], ops: [] },
        f,
        y,
        t,
        g;
    return g = { next: verb(0), "throw": verb(1), "return": verb(2) }, typeof Symbol === "function" && (g[Symbol.iterator] = function () {
        return this;
    }), g;
    function verb(n) {
        return function (v) {
            return step([n, v]);
        };
    }
    function step(op) {
        if (f) throw new TypeError("Generator is already executing.");
        while (_) try {
            if (f = 1, y && (t = op[0] & 2 ? y["return"] : op[0] ? y["throw"] || ((t = y["return"]) && t.call(y), 0) : y.next) && !(t = t.call(y, op[1])).done) return t;
            if (y = 0, t) op = [op[0] & 2, t.value];
            switch (op[0]) {
                case 0:case 1:
                    t = op;break;
                case 4:
                    _.label++;return { value: op[1], done: false };
                case 5:
                    _.label++;y = op[1];op = [0];continue;
                case 7:
                    op = _.ops.pop();_.trys.pop();continue;
                default:
                    if (!(t = _.trys, t = t.length > 0 && t[t.length - 1]) && (op[0] === 6 || op[0] === 2)) {
                        _ = 0;continue;
                    }
                    if (op[0] === 3 && (!t || op[1] > t[0] && op[1] < t[3])) {
                        _.label = op[1];break;
                    }
                    if (op[0] === 6 && _.label < t[1]) {
                        _.label = t[1];t = op;break;
                    }
                    if (t && _.label < t[2]) {
                        _.label = t[2];_.ops.push(op);break;
                    }
                    if (t[2]) _.ops.pop();
                    _.trys.pop();continue;
            }
            op = body.call(thisArg, _);
        } catch (e) {
            op = [6, e];y = 0;
        } finally {
            f = t = 0;
        }
        if (op[0] & 5) throw op[1];return { value: op[0] ? op[1] : void 0, done: true };
    }
}

function __exportStar(m, exports) {
    for (var p in m) if (!exports.hasOwnProperty(p)) exports[p] = m[p];
}

function __values(o) {
    var s = typeof Symbol === "function" && Symbol.iterator,
        m = s && o[s],
        i = 0;
    if (m) return m.call(o);
    if (o && typeof o.length === "number") return {
        next: function () {
            if (o && i >= o.length) o = void 0;
            return { value: o && o[i++], done: !o };
        }
    };
    throw new TypeError(s ? "Object is not iterable." : "Symbol.iterator is not defined.");
}

function __read(o, n) {
    var m = typeof Symbol === "function" && o[Symbol.iterator];
    if (!m) return o;
    var i = m.call(o),
        r,
        ar = [],
        e;
    try {
        while ((n === void 0 || n-- > 0) && !(r = i.next()).done) ar.push(r.value);
    } catch (error) {
        e = { error: error };
    } finally {
        try {
            if (r && !r.done && (m = i["return"])) m.call(i);
        } finally {
            if (e) throw e.error;
        }
    }
    return ar;
}

function __spread() {
    for (var ar = [], i = 0; i < arguments.length; i++) ar = ar.concat(__read(arguments[i]));
    return ar;
}

function __spreadArrays() {
    for (var s = 0, i = 0, il = arguments.length; i < il; i++) s += arguments[i].length;
    for (var r = Array(s), k = 0, i = 0; i < il; i++) for (var a = arguments[i], j = 0, jl = a.length; j < jl; j++, k++) r[k] = a[j];
    return r;
};

function __await(v) {
    return this instanceof __await ? (this.v = v, this) : new __await(v);
}

function __asyncGenerator(thisArg, _arguments, generator) {
    if (!Symbol.asyncIterator) throw new TypeError("Symbol.asyncIterator is not defined.");
    var g = generator.apply(thisArg, _arguments || []),
        i,
        q = [];
    return i = {}, verb("next"), verb("throw"), verb("return"), i[Symbol.asyncIterator] = function () {
        return this;
    }, i;
    function verb(n) {
        if (g[n]) i[n] = function (v) {
            return new Promise(function (a, b) {
                q.push([n, v, a, b]) > 1 || resume(n, v);
            });
        };
    }
    function resume(n, v) {
        try {
            step(g[n](v));
        } catch (e) {
            settle(q[0][3], e);
        }
    }
    function step(r) {
        r.value instanceof __await ? Promise.resolve(r.value.v).then(fulfill, reject) : settle(q[0][2], r);
    }
    function fulfill(value) {
        resume("next", value);
    }
    function reject(value) {
        resume("throw", value);
    }
    function settle(f, v) {
        if (f(v), q.shift(), q.length) resume(q[0][0], q[0][1]);
    }
}

function __asyncDelegator(o) {
    var i, p;
    return i = {}, verb("next"), verb("throw", function (e) {
        throw e;
    }), verb("return"), i[Symbol.iterator] = function () {
        return this;
    }, i;
    function verb(n, f) {
        i[n] = o[n] ? function (v) {
            return (p = !p) ? { value: __await(o[n](v)), done: n === "return" } : f ? f(v) : v;
        } : f;
    }
}

function __asyncValues(o) {
    if (!Symbol.asyncIterator) throw new TypeError("Symbol.asyncIterator is not defined.");
    var m = o[Symbol.asyncIterator],
        i;
    return m ? m.call(o) : (o = typeof __values === "function" ? __values(o) : o[Symbol.iterator](), i = {}, verb("next"), verb("throw"), verb("return"), i[Symbol.asyncIterator] = function () {
        return this;
    }, i);
    function verb(n) {
        i[n] = o[n] && function (v) {
            return new Promise(function (resolve, reject) {
                v = o[n](v), settle(resolve, reject, v.done, v.value);
            });
        };
    }
    function settle(resolve, reject, d, v) {
        Promise.resolve(v).then(function (v) {
            resolve({ value: v, done: d });
        }, reject);
    }
}

function __makeTemplateObject(cooked, raw) {
    if (Object.defineProperty) {
        Object.defineProperty(cooked, "raw", { value: raw });
    } else {
        cooked.raw = raw;
    }
    return cooked;
};

function __importStar(mod) {
    if (mod && mod.__esModule) return mod;
    var result = {};
    if (mod != null) for (var k in mod) if (Object.hasOwnProperty.call(mod, k)) result[k] = mod[k];
    result.default = mod;
    return result;
}

function __importDefault(mod) {
    return mod && mod.__esModule ? mod : { default: mod };
}

function __classPrivateFieldGet(receiver, privateMap) {
    if (!privateMap.has(receiver)) {
        throw new TypeError("attempted to get private field on non-instance");
    }
    return privateMap.get(receiver);
}

function __classPrivateFieldSet(receiver, privateMap, value) {
    if (!privateMap.has(receiver)) {
        throw new TypeError("attempted to set private field on non-instance");
    }
    privateMap.set(receiver, value);
    return value;
}

/***/ }),

/***/ "../../node_modules/webpack/buildin/global.js":
/*!***********************************!*\
  !*** (webpack)/buildin/global.js ***!
  \***********************************/
/*! no static exports found */
/***/ (function(module, exports) {

var g;

// This works in non-strict mode
g = function () {
    return this;
}();

try {
    // This works if eval is allowed (see CSP)
    g = g || new Function("return this")();
} catch (e) {
    // This works if the window reference is available
    if (typeof window === "object") g = window;
}

// g can still be undefined, but nothing to do about it...
// We return undefined, instead of nothing here, so it's
// easier to handle this case. if(!global) { ...}

module.exports = g;

/***/ }),

/***/ "../../node_modules/webpack/buildin/harmony-module.js":
/*!*******************************************!*\
  !*** (webpack)/buildin/harmony-module.js ***!
  \*******************************************/
/*! no static exports found */
/***/ (function(module, exports) {

module.exports = function (originalModule) {
    if (!originalModule.webpackPolyfill) {
        var module = Object.create(originalModule);
        // module.parent = undefined by default
        if (!module.children) module.children = [];
        Object.defineProperty(module, "loaded", {
            enumerable: true,
            get: function () {
                return module.l;
            }
        });
        Object.defineProperty(module, "id", {
            enumerable: true,
            get: function () {
                return module.i;
            }
        });
        Object.defineProperty(module, "exports", {
            enumerable: true
        });
        module.webpackPolyfill = 1;
    }
    return module;
};

/***/ }),

/***/ "../athena/src/binds/h5.js":
/*!*********************************!*\
  !*** ../athena/src/binds/h5.js ***!
  \*********************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
    value: true
});
exports.H5Binds = undefined;

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

var _track = __webpack_require__(/*! ../track */ "../athena/src/track.js");

var _constants = __webpack_require__(/*! ../constants */ "../athena/src/constants.js");

var _hook = __webpack_require__(/*! ../util/hook */ "../athena/src/util/hook.js");

var _utilities = __webpack_require__(/*! ../util/utilities */ "../athena/src/util/utilities.js");

var _check = __webpack_require__(/*! ../util/check */ "../athena/src/util/check.js");

var _dom = __webpack_require__(/*! ../util/dom */ "../athena/src/util/dom.js");

var _methodChain = __webpack_require__(/*! ../util/method-chain */ "../athena/src/util/method-chain.js");

var _methodChain2 = _interopRequireDefault(_methodChain);

var _pageVisibility = __webpack_require__(/*! ../util/page-visibility */ "../athena/src/util/page-visibility.js");

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

var H5Binds = exports.H5Binds = function () {
    function H5Binds() {
        _classCallCheck(this, H5Binds);

        this.opts = {
            scrollThreshold: 10
        };
        this.refs = {};
        this.state = {
            isFirstPageInit: false,
            isFirstPageReady: false,
            scrollPercentageLast: 0
        };
        this.actionMapping = {
            "click": _constants.UI_ACTION_TYPES.CLICK,
            "longpress": _constants.UI_ACTION_TYPES.LONG_PRESS
        };
        this.urlTransformer = null;

        this.handleUrlChange = this.handleUrlChange.bind(this);
        this.pushStateOverride = this.pushStateOverride.bind(this);
        this.replaceStateOverride = this.replaceStateOverride.bind(this);
        this.handlePopState = this.handlePopState.bind(this);
        this.handleScroll = (0, _utilities.debounce)(this.handleScroll.bind(this), 500);

        _methodChain2.default.add(history, 'pushState', this.pushStateOverride);
        _methodChain2.default.add(history, 'replaceState', this.replaceStateOverride);
        window.addEventListener('popstate', this.handlePopState);

        this.handleVisibilityChange = this.handleVisibilityChange.bind(this);
        _pageVisibility.pageVisibility.addEventListener(this.handleVisibilityChange, false);

        this.init();
    }

    _createClass(H5Binds, [{
        key: "init",
        value: function init() {
            this.impl();
        }
    }, {
        key: "impl",
        value: function impl() {
            (0, _track.provideImpl)(_constants.IMPL.GET_CURRENT_PAGE_URL, this.implGetCurrentPageUrl.bind(this));
            (0, _track.provideImpl)(_constants.IMPL.GET_CURRENT_PAGE_IDENTIFY, this.implGetCurrentPageIdentify.bind(this));
            (0, _track.provideImpl)(_constants.IMPL.GET_PAGE_ID, this.implGetPageId.bind(this));
            (0, _track.provideImpl)(_constants.IMPL.ON_START, this.implOnStart.bind(this));
            (0, _track.provideImpl)(_constants.IMPL.CONFIG_BIND, this.implConfigBind.bind(this));
            (0, _track.provideImpl)(_constants.IMPL.GET_DEVICE_INFO, this.implGetDeviceInfo.bind(this));

            (0, _track.provideImpl)(_constants.IMPL.HTTP_REQUEST, this.implHttpRequest.bind(this));
            (0, _track.provideImpl)(_constants.IMPL.STORE_GET, H5Binds.implStoreGet.bind(this));
            (0, _track.provideImpl)(_constants.IMPL.STORE_PUT, H5Binds.implStorePut.bind(this));
        }
    }, {
        key: "hook",
        value: function hook() {
            this.hookError();
            this.hookConsoleError();
            this.hookXHR();
        }

        /**
         * 网络请求接口
         * @param {*} requestConfig 请求相关配置
         * requestConfig = {
         *  method:'',
         *  url:'',
         *  data:{},
         *  config:{
         *      headers:{},
         *      dataType:''
         *
         *  }
         * }
         * @param {*} callback 请求回调
         * callback={
         *  onSuccess:func,
         *  onError:func,
         *  onFinally:func
         * }
         *
         */

    }, {
        key: "hookError",
        value: function hookError() {
            var hooks = {
                "onerror": function onerror(msg, source, line, col, err) {
                    (0, _track.trigger)(_constants.PLUGINS.APP_TRACKER, 'onAppScriptError', msg, source, line, col, err !== null ? err.stack : "");
                }
            };
            (0, _hook.hookMethods)("ErrorCatch", window, hooks);
        }
    }, {
        key: "hookConsoleError",
        value: function hookConsoleError() {
            var hooks = {
                "error": function error() {
                    for (var _len = arguments.length, args = Array(_len), _key = 0; _key < _len; _key++) {
                        args[_key] = arguments[_key];
                    }

                    (0, _track.trigger)(_constants.PLUGINS.CONSOLE_TRACKER, 'onConsoleError', args.join(' '));
                }
            };
            if (!this.refs.console) {
                (0, _hook.hookMethods)("Console", console, hooks);
                this.refs.console = console;
            }
        }
    }, {
        key: "hookXHR",
        value: function hookXHR() {
            var _this = this;
            if (!_this.refs.xhrOpen) {
                _this.refs.xhrOpen = XMLHttpRequest.prototype.open;

                XMLHttpRequest.prototype.open = function (method, url) {
                    for (var _len2 = arguments.length, theArgs = Array(_len2 > 2 ? _len2 - 2 : 0), _key2 = 2; _key2 < _len2; _key2++) {
                        theArgs[_key2 - 2] = arguments[_key2];
                    }

                    var reqId = (0, _utilities.uuid)();
                    (0, _track.trigger)(_constants.PLUGINS.REQUEST_TRACKER, 'onRequestBegin', reqId, method || "GET", url);
                    this.addEventListener('load', function () {
                        (0, _track.trigger)(_constants.PLUGINS.REQUEST_TRACKER, 'onRequestComplete', reqId, method || "GET", url, this.status, this.responseText);
                    });
                    _this.refs.xhrOpen.apply(this, arguments);
                };
            }
        }
    }, {
        key: "implHttpRequest",
        value: function implHttpRequest(requestConfig, callback) {
            var xhr = new XMLHttpRequest();
            var code = -1;
            xhr.onreadystatechange = function () {
                try {
                    if (xhr.readyState === XMLHttpRequest.DONE) {
                        code = xhr.status; // In the event of a communication error (such as the server going down), an exception will be thrown in the onreadystatechange method when accessing the response status
                        if (callback.hasOwnProperty('onSuccess')) {
                            callback.onSuccess({
                                statusCode: code,
                                header: xhr.getAllResponseHeaders(),
                                data: xhr.response
                            });
                        }
                    }
                } catch (e) {
                    if (callback.hasOwnProperty('onError')) {
                        callback.onError({
                            statusCode: code,
                            header: xhr.getAllResponseHeaders(),
                            data: e
                        });
                    }
                }
                if (callback.hasOwnProperty('onFinally')) {
                    callback.onFinally({
                        statusCode: code,
                        header: xhr.getAllResponseHeaders(),
                        data: xhr.response
                    });
                }
            };
            xhr.open(requestConfig.method, requestConfig.url, true);
            xhr.setRequestHeader('Content-Type', 'application/json');

            // 如果为对象, 需要 dump 为 JSON
            if (typeof requestConfig.data === 'string') {
                xhr.send(requestConfig.data);
            } else {
                xhr.send(JSON.stringify(requestConfig.data));
            }
        }
    }, {
        key: "getTransformedUrl",
        value: function getTransformedUrl() {
            if (this.urlTransformer && (0, _check.isFunction)(this.urlTransformer)) {
                return this.urlTransformer(this.getCurrentUrl());
            }
            return this.getCurrentUrl();
        }
    }, {
        key: "implGetCurrentPageUrl",
        value: function implGetCurrentPageUrl() {
            if (_pageVisibility.pageVisibility.isBackground()) {
                return _constants.PAGE_BACKGROUND;
            }
            return this.getCurrentUrl();
        }
    }, {
        key: "implGetPageId",
        value: function implGetPageId() {
            if (_pageVisibility.pageVisibility.isBackground()) {
                return _constants.PAGE_BACKGROUND;
            }
            return this.getTransformedUrl();
        }
    }, {
        key: "implGetCurrentPageIdentify",
        value: function implGetCurrentPageIdentify() {
            return this.getTransformedUrl();
        }
    }, {
        key: "implConfigBind",
        value: function implConfigBind(configs) {
            if (configs.urlTransformer) {
                this.urlTransformer = configs.urlTransformer;
            }
        }
    }, {
        key: "getCurrentUrl",
        value: function getCurrentUrl() {
            var location = window.top.location;
            return location.protocol + "//" + location.hostname + location.pathname + location.search;
        }
    }, {
        key: "bindTrackers",
        value: function bindTrackers() {
            var _this2 = this;

            var _this = this;
            // APP_TRACKER.onPageNotFound 对 H5 不可用
            // load start
            {
                if (!_this.state.isFirstPageInit) {
                    _this.state.isFirstPageInit = true;
                    (0, _track.trigger)(_constants.PLUGINS.APP_TRACKER, 'onFirstPageInit');
                }
                (0, _track.trigger)(_constants.PLUGINS.APP_TRACKER, 'onLaunchBegin', this.getCurrentUrl());
                (0, _track.trigger)(_constants.PLUGINS.APP_TRACKER, 'onGetRefer', document.referrer, "");
                (0, _track.trigger)(_constants.PLUGINS.PAGE_TRACKER, 'onPageInit');
            }

            var onPageReady = function onPageReady() {
                if (!_this.state.isFirstPageReady) {
                    _this.state.isFirstPageReady = true;
                    (0, _track.trigger)(_constants.PLUGINS.APP_TRACKER, 'onFirstPageReady');
                }
                (0, _track.trigger)(_constants.PLUGINS.PAGE_TRACKER, 'onPageReady');
                (0, _track.trigger)(_constants.PLUGINS.PAGE_TRACKER, 'onPageShow');
            };

            if (document.readyState !== "complete") {
                window.addEventListener('load', function () {
                    onPageReady();
                });
            } else {
                onPageReady();
            }

            window.addEventListener('unload', function () {
                (0, _track.trigger)(_constants.PLUGINS.PAGE_TRACKER, 'onPageHide');
            });

            _this.hook();

            // UI action
            var uiActionOpts = (0, _track.trigger)(_constants.PLUGINS.UI_ACTION_TRACKER, 'getOpts');
            this.opts.scrollThreshold = uiActionOpts.scrollThreshold || this.opts.scrollThreshold;
            if (uiActionOpts && uiActionOpts.eventTypes) {
                uiActionOpts.eventTypes.forEach(function (eventType) {
                    if (eventType === "scroll") {
                        _this2.listenForScrollChanges();
                        return;
                    }
                    var onEvent = function onEvent(event, element) {
                        var mapType = _this.actionMapping[event.type];
                        if (!mapType) {
                            return;
                        }
                        var viewTag = (0, _dom.getXPathFromElement)(element);
                        var viewText = (0, _dom.getCleanTextFromElement)(element);
                        var rect = element.getBoundingClientRect();
                        // absX, absY, clientX, clientY
                        (0, _track.trigger)(_constants.PLUGINS.UI_ACTION_TRACKER, 'onBindTrigger', mapType, viewTag, viewText, {
                            absX: rect.left + window.scrollX,
                            absY: rect.top + window.scrollY,
                            clientX: rect.left,
                            clientY: rect.top
                        });
                    };
                    (0, _dom.domDelegate)(document, eventType, onEvent, true);
                });
            }
        }
    }, {
        key: "handleUrlChange",
        value: function handleUrlChange() {
            this.state.scrollPercentageLast = 0;
            (0, _track.trigger)(_constants.PLUGINS.PAGE_TRACKER, 'onPageShow');
        }
    }, {
        key: "pushStateOverride",
        value: function pushStateOverride(originalMethod) {
            var _this3 = this;

            return function () {
                originalMethod.apply(undefined, arguments);
                _this3.handleUrlChange();
            };
        }
    }, {
        key: "replaceStateOverride",
        value: function replaceStateOverride(originalMethod) {
            var _this4 = this;

            return function () {
                originalMethod.apply(undefined, arguments);
                _this4.handleUrlChange();
            };
        }
    }, {
        key: "handlePopState",
        value: function handlePopState() {
            this.handleUrlChange();
        }
    }, {
        key: "handleVisibilityChange",
        value: function handleVisibilityChange() {
            if (_pageVisibility.pageVisibility.isBackground()) {
                (0, _track.trigger)(_constants.PLUGINS.PAGE_TRACKER, 'onPageHide');
            } else {
                this.handleUrlChange();
            }
        }
    }, {
        key: "handleScroll",
        value: function handleScroll() {
            var pageHeight = getPageHeight();
            var scrollPos = window.pageYOffset; // scrollY isn't supported in IE.
            var windowHeight = window.innerHeight;
            var scrollPercentage = Math.min(100, Math.max(0, Math.round(100 * (scrollPos / (pageHeight - windowHeight)))));

            var lastPercentage = this.state.scrollPercentageLast;
            var increaseAmount = Math.abs(scrollPercentage - lastPercentage);
            if (scrollPercentage === 100 || scrollPercentage === 0 || increaseAmount >= this.opts.scrollThreshold) {
                this.state.scrollPercentageLast = scrollPercentage;
                (0, _track.trigger)(_constants.PLUGINS.UI_ACTION_TRACKER, 'onBindTrigger', _constants.UI_ACTION_TYPES.SCROLL, (0, _dom.getXPathFromElement)(document), "scrollbar", {
                    startPoint: "0," + lastPercentage,
                    endPoint: "0," + scrollPercentage,
                    startAbsPoint: "0," + lastPercentage,
                    endAbsPoint: "0," + scrollPercentage
                });
            }
        }

        /**
         * Adds a scroll event listener if the scroll percentage for the
         * current page isn't already at 100%.
         */

    }, {
        key: "listenForScrollChanges",
        value: function listenForScrollChanges() {
            var scrollPercentage = this.state.scrollPercentageLast || 0;
            if (scrollPercentage < 100) {
                addEventListener('scroll', this.handleScroll);
            }
        }
    }, {
        key: "implGetDeviceInfo",
        value: function implGetDeviceInfo() {
            return {
                display: window.screen.width + ',' + window.screen.height
            };
        }
    }, {
        key: "implOnStart",
        value: function implOnStart() {
            this.bindTrackers();
        }
    }], [{
        key: "implStorePut",
        value: function implStorePut(key, value) {
            return localStorage.setItem(key, value);
        }
    }, {
        key: "implStoreGet",
        value: function implStoreGet(key) {
            return localStorage.getItem(key);
        }
    }]);

    return H5Binds;
}();

/**
 * Gets the maximum height of the page including scrollable area.
 * @return {number}
 */


var getPageHeight = function getPageHeight() {
    var html = document.documentElement;
    var body = document.body;
    return Math.max(html.offsetHeight, html.scrollHeight, body.offsetHeight, body.scrollHeight);
};

/***/ }),

/***/ "../athena/src/constants.js":
/*!**********************************!*\
  !*** ../athena/src/constants.js ***!
  \**********************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
    value: true
});
var EVENTS = exports.EVENTS = {
    PAGE_CHANGE: 1,
    UI_ACTION: 2,
    CONSOLE_ERROR: 3,
    PERF_PAGE_LOAD: 4,
    PERF_REQUEST: 5,
    REQUEST_NETWORK_ERROR: 6,
    REQUEST_LOGIC_ERROR: 7,
    PERF_APP_LAUNCH: 8,
    LAUNCH_REFER: 9,
    APP_SCRIPT_ERROR: 10,
    PAGE_NOT_FOUND_ERROR: 11,
    WEB_VIEW_LOAD_ERROR: 12
};

var PLUGINS = exports.PLUGINS = {
    APP_TRACKER: "appTracker",
    CONSOLE_TRACKER: "consoleTracker",
    PAGE_TRACKER: "pageTracker",
    REQUEST_TRACKER: "requestTracker",
    WEB_VIEW_TRACKER: "webViewTracker",
    UI_ACTION_TRACKER: "uiActionTracker"
};

var CONFIG_FIELDS = exports.CONFIG_FIELDS = {
    LOG_LEVEL: "log_level"
};

var IMPL = exports.IMPL = {
    GET_CURRENT_PAGE_URL: "getCurrentPageUrl",
    GET_CURRENT_PAGE_IDENTIFY: "getCurrentPageIdentify",
    GET_PAGE_ID: "getPageId",
    STORE_PUT: "implStorePut",
    STORE_GET: "implStoreGet",
    HTTP_REQUEST: "httpRequest",
    GET_DEVICE_INFO: "getDeviceInfo", // {display: "1024,768"}
    ON_START: "onStart",
    CONFIG_BIND: "configBind"
};

var UI_ACTION_TYPES = exports.UI_ACTION_TYPES = {
    CLICK: 1,
    LONG_PRESS: 2,
    SCROLL: 3,
    KEY: 4,
    SCREEN_ROTATION: 5,
    ZOOM: 6,
    INPUT: 7,
    REFRESH: 8,
    EXPOSE: 9,
    OTHERS: 100
};

var PAGE_BACKGROUND = exports.PAGE_BACKGROUND = "_background_";

/***/ }),

/***/ "../athena/src/eventcon/AthenaEnum.js":
/*!********************************************!*\
  !*** ../athena/src/eventcon/AthenaEnum.js ***!
  \********************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
    value: true
});
// 事件主题
// 必须指定值，并且这些值不可以改变
var EventTopic = {
    EVENT_BASE: 1,
    EVENT_APP: 2,
    // Athena 内部事件
    EVENT_UI_ACTION: 3,
    EVENT_PAGE_CHANGE: 4,
    EVENT_TAG: 5,
    EVENT_TRACE: 6,
    EVENT_CAL: 7,
    EVENT_RDM_CRASH: 8, // 废弃, 使用 EVENT_EXTERNAL_* 代替
    EVENT_QAPM_PERF: 9, // 废弃, 使用 EVENT_EXTERNAL_* 代替
    // 第三方平台事件, header 部分
    EVENT_EXTERNAL_HEADER: 1000,
    // 第三方平台事件, body 部分
    EVENT_EXTERNAL_QAPM_SIGKILL: 1001, // QAPM Sigkill 事件
    EVENT_EXTERNAL_QAPM_LAG: 1002 // QAPM 卡顿事件
};
Object.freeze(EventTopic);

// 标记第三方平台 SDK 是否打开的
// 必须指定值，并且这些值不可以改变
var FunctionFlag = {
    RESERVED: 1, // 保留
    QAPM: 2, // QAPM 已启用 (此项QAPM iOS 目前不会设置)
    QAPM_SIGKILL: 4, // QAPM_SIGKILL 已启用
    QAPM_LAG: 8 // QAPM_LAG 已启用
};
Object.freeze(FunctionFlag);

// 用户可设置字段
var Field = {
    APP_ID: 'app_id', // Athena App ID
    USER_ID: 'user_id', // 用户 ID
    VERSION: 'version', // App 版本号
    BUILD_ID: 'build_id', // 构建 ID
    BUCKETS: 'buckets', // A/B Test 分桶
    ATHENA_BASE_URL: 'athena_base_url', // 上报地址
    DEVICE_ID: 'device_id', // 构建 ID
    ENABLE_UPLOAD_ATHENA: 'enable_upload_athena', // 是否允许上报到 Athena
    UPLOAD_PERIOD: 'upload_period'
};
Object.freeze(Field);

// UI操作
// 必须指定值，并且这些值不可以改变
var UiAction = {
    CLICK: 1, // 点击
    LONG_PRESS: 2, // 长按
    SCROLL: 3, // 滑动
    KEY: 4, // 按键
    SCREEN_ROTATION: 5, // 屏幕旋转
    ZOOM: 6, // 双指缩放
    INPUT: 7, // 文本输入
    OTHERS: 100 // 未识别出UI操作类型
};
Object.freeze(UiAction);

exports.EventTopic = EventTopic;
exports.FunctionFlag = FunctionFlag;
exports.Field = Field;
exports.UiAction = UiAction;

/***/ }),

/***/ "../athena/src/eventcon/EventConConfig.js":
/*!************************************************!*\
  !*** ../athena/src/eventcon/EventConConfig.js ***!
  \************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
    value: true
});
exports.EventConConfig = undefined;

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

var _eventcon = __webpack_require__(/*! ./eventcon.js */ "../athena/src/eventcon/eventcon.js");

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

var EventConConfig = function () {
    function EventConConfig() {
        _classCallCheck(this, EventConConfig);

        this.uploadPeriod = 900000; // 单位：ms, 默认 15 分钟上报一次
        this.enableUploadAthena = true;
        this.athenaBaseUrl = 'https://athena.qq.com/';

        this.netConfig = {
            headers: {
                'Content-Type': 'application/json' // application/x-www-form-urlencoded | application/json
            }
        };
    }

    _createClass(EventConConfig, [{
        key: 'AthenaUrl',
        get: function get() {
            var baseUrl = this.athenaBaseUrl;
            if (!baseUrl.endsWith("/")) {
                baseUrl += "/";
            }

            return baseUrl + 'entrance/uploadJson/' + _eventcon.EventCon.getInstance().app_id + '/' + _eventcon.EventCon.getInstance().version + '/?format=2&user_id=' + _eventcon.EventCon.getInstance().user_id;
        }
    }]);

    return EventConConfig;
}();

exports.EventConConfig = EventConConfig;

/***/ }),

/***/ "../athena/src/eventcon/EventConMeta.js":
/*!**********************************************!*\
  !*** ../athena/src/eventcon/EventConMeta.js ***!
  \**********************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
    value: true
});
exports.EventConMeta = undefined;

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

var _log = __webpack_require__(/*! ../util/log */ "../athena/src/util/log.js");

var _utilities = __webpack_require__(/*! ../util/utilities */ "../athena/src/util/utilities.js");

var _check = __webpack_require__(/*! ../util/check */ "../athena/src/util/check.js");

var _track = __webpack_require__(/*! ../track */ "../athena/src/track.js");

var _constants = __webpack_require__(/*! ../constants */ "../athena/src/constants.js");

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

var ConstUnknown = 'unknown';

var EventConMeta = function () {
    function EventConMeta() {
        _classCallCheck(this, EventConMeta);

        this.app_id = ConstUnknown;
        this.user_id = ConstUnknown;
        this.version = ConstUnknown;
        this.build_id = ConstUnknown;
        this.device_id = ConstUnknown;
        this.display = ConstUnknown; // 这个字段设置在这里好像意义不大, 因为窗口大小会变的, 不过还是填上做参考吧
        this.buckets = [];
        this.flag = 0;

        this._init();
    }

    _createClass(EventConMeta, [{
        key: '_init',
        value: function _init() {
            if (this.device_id === ConstUnknown) {
                this.device_id = EventConMeta.getDeviceId();
            }
            _log.Log.log("EventConMeta, device_id:", this.device_id);
            // this.display = window.screen.width + ',' + window.screen.height;
            this.display = '1,1'; //todo 小程序需要适配
        }
    }, {
        key: 'toJsonString',
        value: function toJsonString() {
            return JSON.stringify(this);
        }
    }, {
        key: 'userId',
        get: function get() {
            if ((0, _check.isFunction)(this.user_id)) {
                return this.user_id();
            } else {
                return this.user_id;
            }
        }

        // 因为userid是值或func，不符合json结构，会导致上报时格式错误
        // 上报接口用，标准json结构

    }, {
        key: 'metaObj',
        get: function get() {
            return {
                'app_id': this.app_id,
                'user_id': this.userId,
                'version': this.version,
                'build_id': this.build_id,
                'device_id': this.device_id,
                'display': ((0, _track.callImpl)(_constants.IMPL.GET_DEVICE_INFO) || {}).display,
                'buckets': this.buckets,
                'flag': this.flag
            };
        }
    }], [{
        key: 'getDeviceId',
        value: function getDeviceId() {
            var deviceId = (0, _track.callImpl)(_constants.IMPL.STORE_GET, 'eventcon.device_id');
            if ((0, _check.isEmpty)(deviceId)) {
                deviceId = (0, _utilities.uuid)();
                (0, _track.callImpl)(_constants.IMPL.STORE_PUT, 'eventcon.device_id', deviceId);
            }
            return deviceId;
        }
    }]);

    return EventConMeta;
}();

exports.EventConMeta = EventConMeta;

/***/ }),

/***/ "../athena/src/eventcon/EventHandler.js":
/*!**********************************************!*\
  !*** ../athena/src/eventcon/EventHandler.js ***!
  \**********************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
    value: true
});

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

var _log = __webpack_require__(/*! ../util/log */ "../athena/src/util/log.js");

var _eventcon = __webpack_require__(/*! ./eventcon */ "../athena/src/eventcon/eventcon.js");

var _check = __webpack_require__(/*! ../util/check */ "../athena/src/util/check.js");

var _track = __webpack_require__(/*! ../track */ "../athena/src/track.js");

var _constants = __webpack_require__(/*! ../constants */ "../athena/src/constants.js");

var _filestore = __webpack_require__(/*! ./filestore */ "../athena/src/eventcon/filestore.js");

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

/**
 * event事件的handler
 * 负责管理event队列
 * */
var EventHandler = function () {
    function EventHandler() {
        _classCallCheck(this, EventHandler);
    }

    _createClass(EventHandler, [{
        key: "offerEvent",
        value: function offerEvent(event) {
            _filestore.FileStore.appendString("athena-events", JSON.stringify(event) + "#$#");
        }

        /**
         * 获取原始事件
         */

    }, {
        key: "getCurrentEvents",
        value: function getCurrentEvents() {
            return _filestore.FileStore.readAll("athena-events").split("#$#").filter(function (e) {
                return e !== "";
            }).map(function (e) {
                try {
                    return JSON.parse(e);
                } catch (e) {
                    return {};
                }
            });
        }
    }, {
        key: "uploadEvents",
        value: function uploadEvents() {
            var url = _eventcon.EventCon.getInstance().config.AthenaUrl;
            var config = _eventcon.EventCon.getInstance().config.netConfig;

            var events = EventHandler.getInstance().getCurrentEvents();
            _filestore.FileStore.remove("athena-events"); // 这里获取到事件, 直接删除原始数据了, 不进行失败重试

            if (events.length === 0) {
                return;
            }

            // 上报时 check 字段 app_id, version, device_id, display
            var meta = _eventcon.EventCon.getInstance().meta_json;
            if ((0, _check.isEmpty)(meta.app_id) || (0, _check.isEmpty)(meta.version) || (0, _check.isEmpty)(meta.device_id) || (0, _check.isEmpty)(meta.display)) {
                _log.Log.error('uploadEvents', "one of app_id(" + meta.app_id + "), version(" + meta.version + "), device_id(" + meta.device_id + "), display(" + meta.display + ") is empty !");
                return;
            }

            // 从缓存队列里取event上报
            var payload = {
                'meta': meta,
                'events': events
            };

            _log.Log.log('config', config);
            _log.Log.log('upload url', url);
            _log.Log.log('payload', payload);

            var requestConfig = {
                method: 'POST',
                url: url,
                data: payload,
                config: {
                    headers: config.headers
                }
            };

            (0, _track.callImpl)(_constants.IMPL.HTTP_REQUEST, requestConfig, {
                onSuccess: function onSuccess(res) {
                    _log.Log.log('success', res);
                    if (res.statusCode == 200) {
                        _log.Log.log('onSuccess', res.data);
                        switch (res.data.code) {
                            case 1000:
                                break;
                            default:
                                break;
                        }
                    } else if (res.statusCode == 504) {
                        // 因为网络问题造成的上报失败 (Status Code: 504|...允许重传最多 N 次(N <= 3)

                    } else {
                        _log.Log.error('onSuccess', 'statusCode:', res.statusCode);
                    }
                },
                onError: function onError(res) {
                    _log.Log.error('error', res);
                },
                onFinally: function onFinally(res) {
                    _log.Log.log('finally', res);
                }
            });
        }
    }], [{
        key: "getInstance",
        value: function getInstance() {
            if (!this.instance) {
                this.instance = new EventHandler();
            }
            return this.instance;
        }
    }]);

    return EventHandler;
}();

exports.default = EventHandler;

/***/ }),

/***/ "../athena/src/eventcon/EventModel.js":
/*!********************************************!*\
  !*** ../athena/src/eventcon/EventModel.js ***!
  \********************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
    value: true
});
exports.EventCAL = exports.EventUiAction = exports.EventPageChange = exports.EventApp = exports.EventBase = undefined;

var _get = function get(object, property, receiver) { if (object === null) object = Function.prototype; var desc = Object.getOwnPropertyDescriptor(object, property); if (desc === undefined) { var parent = Object.getPrototypeOf(object); if (parent === null) { return undefined; } else { return get(parent, property, receiver); } } else if ("value" in desc) { return desc.value; } else { var getter = desc.get; if (getter === undefined) { return undefined; } return getter.call(receiver); } };

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

var _AthenaEnum = __webpack_require__(/*! ./AthenaEnum */ "../athena/src/eventcon/AthenaEnum.js");

var _utilities = __webpack_require__(/*! ../util/utilities */ "../athena/src/util/utilities.js");

var _check = __webpack_require__(/*! ../util/check */ "../athena/src/util/check.js");

var _track = __webpack_require__(/*! ../track */ "../athena/src/track.js");

var _constants = __webpack_require__(/*! ../constants */ "../athena/src/constants.js");

function _possibleConstructorReturn(self, call) { if (!self) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return call && (typeof call === "object" || typeof call === "function") ? call : self; }

function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

var EventBase = function () {
    function EventBase() {
        _classCallCheck(this, EventBase);

        this.id = (0, _utilities.uuid)();
        this.time = new Date().toISOString();
        this.topic = _AthenaEnum.EventTopic.EVENT_BASE;
        this.extra = '';
        this.tags = {};
        this.values = {};
    }

    // 参考 EventCon 文档, 注意时区为 UTC


    _createClass(EventBase, [{
        key: 'setTime',
        value: function setTime(ms) {
            this.time = new Date(ms).toISOString();
        }
    }, {
        key: 'check',


        /**
         * check id, time, topic 非空
         * @returns true : id, time, topic is not null
         */
        value: function check() {
            // todo 在 EventCon.sendEvent() 之后立即触发检查
            return !((0, _check.isEmpty)(this.id) || (0, _check.isEmpty)(this.time) || (0, _check.isEmpty)(this.topic));
        }
    }, {
        key: 'jsonstr',
        get: function get() {
            return JSON.stringify(this);
        }
    }]);

    return EventBase;
}();

var EventApp = function (_EventBase) {
    _inherits(EventApp, _EventBase);

    function EventApp() {
        _classCallCheck(this, EventApp);

        var _this = _possibleConstructorReturn(this, (EventApp.__proto__ || Object.getPrototypeOf(EventApp)).call(this));

        _this.topic = _AthenaEnum.EventTopic.EVENT_APP;
        return _this;
    }

    return EventApp;
}(EventBase);

var EventPageChange = function (_EventApp) {
    _inherits(EventPageChange, _EventApp);

    function EventPageChange() {
        _classCallCheck(this, EventPageChange);

        var _this2 = _possibleConstructorReturn(this, (EventPageChange.__proto__ || Object.getPrototypeOf(EventPageChange)).call(this));

        _this2.topic = _AthenaEnum.EventTopic.EVENT_PAGE_CHANGE;
        _this2.pre_page_id = '';
        _this2.pre_page = '';
        _this2.page_id = '';
        _this2.page = '';
        _this2.pre_page_start = 0;
        _this2.pre_page_end = 0;
        _this2.page_start = 0;
        return _this2;
    }

    /**
     * check pre_page_id, pre_page, page_id, page, pre_page_start, pre_page_end, page_start 非空
     * @returns true: pre_page_id, pre_page, page_id, page, pre_page_start, pre_page_end, page_start 非空
     */


    _createClass(EventPageChange, [{
        key: 'check',
        value: function check() {
            return _get(EventPageChange.prototype.__proto__ || Object.getPrototypeOf(EventPageChange.prototype), 'check', this).call(this) && !((0, _check.isEmpty)(this.pre_page_id) || (0, _check.isEmpty)(this.pre_page) || (0, _check.isEmpty)(this.page_id) || (0, _check.isEmpty)(this.page) || (0, _check.isEmpty)(this.pre_page_start) || (0, _check.isEmpty)(this.pre_page_end) || (0, _check.isEmpty)(this.pre_page_start));
        }
    }]);

    return EventPageChange;
}(EventApp);

var EventUiAction = function (_EventApp2) {
    _inherits(EventUiAction, _EventApp2);

    function EventUiAction() {
        _classCallCheck(this, EventUiAction);

        var _this3 = _possibleConstructorReturn(this, (EventUiAction.__proto__ || Object.getPrototypeOf(EventUiAction)).call(this));

        _this3.topic = _AthenaEnum.EventTopic.EVENT_UI_ACTION;
        _this3.op = -1; // UI操作的类型，例如 UiAction.Click, UiAction.Scroll
        _this3.data = {};
        _this3.view_pos = '';
        _this3.view_type = '';
        _this3.view_tag = '';
        _this3.view_text = '';
        _this3.view_desc = '';
        _this3.view_super = '';
        _this3.page = '';
        _this3.page_id = '';

        return _this3;
    }

    /**
     * check page, page_id, op, view_tag 非空
     * @returns true:page, page_id, op, view_tag 非空
     */


    _createClass(EventUiAction, [{
        key: 'check',
        value: function check() {
            return _get(EventUiAction.prototype.__proto__ || Object.getPrototypeOf(EventUiAction.prototype), 'check', this).call(this) && !((0, _check.isEmpty)(this.page) || (0, _check.isEmpty)(this.page_id) || (0, _check.isEmpty)(this.op) || (0, _check.isEmpty)(this.view_tag));
        }
    }]);

    return EventUiAction;
}(EventApp);

var EventCAL = function (_EventApp3) {
    _inherits(EventCAL, _EventApp3);

    function EventCAL(extra) {
        _classCallCheck(this, EventCAL);

        var _this4 = _possibleConstructorReturn(this, (EventCAL.__proto__ || Object.getPrototypeOf(EventCAL)).call(this));

        _this4.topic = _AthenaEnum.EventTopic.EVENT_CAL;
        _this4.category = '';
        _this4.state = '';
        _this4.action = '';
        _this4.label = '';
        _this4.value = 1;
        _this4.extra = extra;
        return _this4;
    }

    /**
     * check category 非空
     * @returns true:category 非空
     */


    _createClass(EventCAL, [{
        key: 'check',
        value: function check() {
            if (this.state === '') {
                this.state = (0, _track.callImpl)(_constants.IMPL.GET_PAGE_ID);
            }
            return _get(EventCAL.prototype.__proto__ || Object.getPrototypeOf(EventCAL.prototype), 'check', this).call(this) && !(0, _check.isEmpty)(this.category);
        }
    }]);

    return EventCAL;
}(EventApp);

exports.EventBase = EventBase;
exports.EventApp = EventApp;
exports.EventPageChange = EventPageChange;
exports.EventUiAction = EventUiAction;
exports.EventCAL = EventCAL;

/***/ }),

/***/ "../athena/src/eventcon/eventcon.js":
/*!******************************************!*\
  !*** ../athena/src/eventcon/eventcon.js ***!
  \******************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.EventCon = undefined;

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

var _log = __webpack_require__(/*! ../util/log */ "../athena/src/util/log.js");

var _EventConMeta = __webpack_require__(/*! ./EventConMeta */ "../athena/src/eventcon/EventConMeta.js");

var _EventConConfig = __webpack_require__(/*! ./EventConConfig */ "../athena/src/eventcon/EventConConfig.js");

var _check = __webpack_require__(/*! ../util/check */ "../athena/src/util/check.js");

var _AthenaEnum = __webpack_require__(/*! ./AthenaEnum */ "../athena/src/eventcon/AthenaEnum.js");

var _EventHandler = __webpack_require__(/*! ./EventHandler */ "../athena/src/eventcon/EventHandler.js");

var _EventHandler2 = _interopRequireDefault(_EventHandler);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

var EventCon = exports.EventCon = function () {
  function EventCon() {
    _classCallCheck(this, EventCon);

    this._meta = new _EventConMeta.EventConMeta();
    // this.localStorage = window.localStorage ? window.localStorage : undefined;
    this.config = new _EventConConfig.EventConConfig();
    this.subscribeCallbacks = []; // 事件订阅
  }

  _createClass(EventCon, [{
    key: 'setField',


    /**
     * 用户设置字段
     * @param {Field} key key值只能是Field值
     * @param {*} value
     */
    value: function setField(key, value) {
      switch (key) {
        case _AthenaEnum.Field.APP_ID:
          this._meta.app_id = value;
          break;
        case _AthenaEnum.Field.USER_ID:
          this._meta.user_id = value;
          break;
        case _AthenaEnum.Field.VERSION:
          this._meta.version = value;
          break;
        case _AthenaEnum.Field.BUILD_ID:
          this._meta.build_id = value;
          break;
        case _AthenaEnum.Field.BUCKETS:
          this._meta.buckets = value;
          break;
        case _AthenaEnum.Field.ATHENA_BASE_URL:
          this.config.athenaBaseUrl = value;
          break;
        case _AthenaEnum.Field.ENABLE_UPLOAD_ATHENA:
          this.config.enableUploadAthena = value;
          break;
        case _AthenaEnum.Field.UPLOAD_PERIOD:
          this.config.uploadPeriod = value;
          break;
        case _AthenaEnum.Field.DEVICE_ID:
          this._meta.device_id = value;
          break;
        default:
          _log.Log.error('EventCon.setField, key MUST NOT be', key);
      }
      return this;
    }

    /**
     * 32位整型, 每一个 bit 指示某一个 SDK 功能的开启情况, 参见 FunctionFlag
     * @param {FunctionFlag} functionFlag
     * @param {boolean} enabled
     */

  }, {
    key: 'setFunctionFlag',
    value: function setFunctionFlag(functionFlag, enabled) {
      this._meta.flag = enabled ? this._meta.flag | functionFlag : this._meta.flag & ~functionFlag;
    }

    /**
     * 返回EvenconMeta对象
     */

  }, {
    key: 'checkConfig',
    value: function checkConfig() {
      // 这里只检查上报接口必填字段
      return !((0, _check.isEmpty)(this.user_id) || (0, _check.isEmpty)(this.app_id) || (0, _check.isEmpty)(this.version) || (0, _check.isEmpty)(this.meta.device_id));
    }

    /**
     * 开始上报轮询
     */

  }, {
    key: 'start',
    value: function start() {
      if (this.checkConfig()) {
        if (this.timer) {
          _log.Log.error('looper is already exits ');
          this.stop();
        }
        _log.Log.debug('begin event loop ');
        this.timer = setInterval(function () {
          _EventHandler2.default.getInstance().uploadEvents();
          localStorage.setItem('athena-last-upload', Math.floor(Date.now() / 1000).toString());
        }, this.config.uploadPeriod);

        // 启动时如果超过最大间隔时限, 则立即上报
        var lastUploadStamp = parseInt(localStorage.getItem('athena-last-upload') || '0');
        console.log('lastUploadStamp', lastUploadStamp);
        if (lastUploadStamp < Math.floor(Date.now() / 1000) - this.config.uploadPeriod / 1000) {
          setTimeout(_EventHandler2.default.getInstance().uploadEvents(), 5000); // 延迟 5 秒, 以考虑到首次启动情况
          localStorage.setItem('athena-last-upload', Math.floor(Date.now() / 1000).toString());
        }
      } else {
        _log.Log.error('please init, some field is empty !');
      }
    }
  }, {
    key: 'stop',
    value: function stop() {
      if (this.timer) {
        clearInterval(this.timer);
        _log.Log.debug('end event loop ');
      }
    }

    /**
     * 对外接口，用于记录事件，会定时上报
     * @param {EventBase} event 继承EventBase的事件
     * @param {boolean} immediately 无视上报周期，立即上报
     */

  }, {
    key: 'sendEvent',
    value: function sendEvent(event, immediately) {
      if (event.check()) {
        this.applySubscribe(event);

        if (this.config.enableUploadAthena) {
          _EventHandler2.default.getInstance().offerEvent(event);
          if (immediately) {
            _EventHandler2.default.getInstance().uploadEvents();
          }
        }
      } else {
        _log.Log.error('sendEvent', 'some field of event is null! =>', event);
      }
      return event.id;
    }

    /**
     * 这个是浏览器提供的专门用来在网页关闭事件unload后发送请求的，一般请求会被close掉
     * @param {*} event
     */

  }, {
    key: 'sendTerminally',
    value: function sendTerminally(event) {
      var url = EventCon.getInstance().config.AthenaUrl;
      var meta = EventCon.getInstance().meta;
      if ((0, _check.isEmpty)(meta.app_id) || (0, _check.isEmpty)(meta.version) || (0, _check.isEmpty)(meta.device_id) || (0, _check.isEmpty)(meta.display)) {
        _log.Log.error('uploadEvents', 'one of app_id, version, device_id, display is empty !');
        return;
      }
      var payload = {
        'meta': meta,
        'events': [event]
      };
      var blob = new Blob([JSON.stringify(payload)], { type: 'text/plain' });
      navigator.sendBeacon(url, blob);
    }
  }, {
    key: 'subscribe',
    value: function subscribe(callback) {
      if (!isFunction(callback)) {
        _log.Log.error('EventCon.subscribe, error, param "callback" MUST be function');
      }
      if (this.subscribeCallbacks.indexOf(callback) > -1) {
        _log.Log.log('EventCon.subscribe, already subscribed,', callback);
      } else {
        this.subscribeCallbacks.push(callback);
      }
    }
  }, {
    key: 'applySubscribe',
    value: function applySubscribe(event) {
      this.subscribeCallbacks.forEach(function (callback) {
        var warpEvent = {
          meta: EventCon.getInstance().meta_json,
          event: event
        };
        if (isFunction(callback)) {
          try {
            callback(warpEvent);
          } catch (e) {
            _log.Log.error('EventCon.applySubscribe, user callback failed', callback, e);
          }
        }
      });
    }
  }, {
    key: 'meta',
    get: function get() {
      return this._meta;
    }

    /**
     * 返回meta的json对象
     */

  }, {
    key: 'meta_json',
    get: function get() {
      return this._meta.metaObj;
    }
  }, {
    key: 'user_id',
    get: function get() {
      return this.meta.userId;
    }
  }, {
    key: 'app_id',
    get: function get() {
      return this.meta.app_id;
    }
  }, {
    key: 'version',
    get: function get() {
      return this.meta.version;
    }
  }], [{
    key: 'getInstance',
    value: function getInstance() {
      if (!this.instance) {
        this.instance = new EventCon();
      }
      return this.instance;
    }
  }]);

  return EventCon;
}();

/***/ }),

/***/ "../athena/src/eventcon/filestore.js":
/*!*******************************************!*\
  !*** ../athena/src/eventcon/filestore.js ***!
  \*******************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
    value: true
});

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

var FileStore = exports.FileStore = function () {
    function FileStore() {
        _classCallCheck(this, FileStore);
    }

    _createClass(FileStore, null, [{
        key: "indexName",

        /**
         * Store files with "localStorage" API
         *
         * FileStore.appendString("events", '{"field": "value"}\n')
         * FileStore.appendString("events", '{"field": "value2"}\n')
         * FileStore.readAll("events")
         * FileStore.remove("events")
         * FileStore.readAll("events")
         * */

        value: function indexName(name) {
            return "fs-" + name + "-index";
        }
    }, {
        key: "contentKey",
        value: function contentKey(name, index) {
            return "fs-" + name + "-" + index;
        }
    }, {
        key: "getIndex",
        value: function getIndex(name) {
            var indexName = FileStore.indexName(name);

            var index = localStorage.getItem(indexName);
            if (index == null) {
                index = -1;
            }
            return parseInt(index);
        }
    }, {
        key: "appendString",
        value: function appendString(name, content) {
            var index = FileStore.getIndex(name);
            index += 1;
            localStorage.setItem(FileStore.contentKey(name, index), content);
            localStorage.setItem(FileStore.indexName(name), index);
        }
    }, {
        key: "readAll",
        value: function readAll(name) {
            var content = "";
            var index = FileStore.getIndex(name);
            if (index >= 0) {
                for (var i = 0; i <= index; i++) {
                    if (localStorage.getItem(FileStore.contentKey(name, i)) !== null) {
                        content += localStorage.getItem(FileStore.contentKey(name, i));
                    }
                }
            }
            return content;
        }
    }, {
        key: "remove",
        value: function remove(name) {
            var index = FileStore.getIndex(name);
            if (index >= 0) {
                for (var i = 0; i <= index; i++) {
                    localStorage.removeItem(FileStore.contentKey(name, i));
                }
            }
            localStorage.removeItem(FileStore.indexName(name));
        }
    }]);

    return FileStore;
}();

/***/ }),

/***/ "../athena/src/index-h5.js":
/*!*********************************!*\
  !*** ../athena/src/index-h5.js ***!
  \*********************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
    value: true
});

var _track = __webpack_require__(/*! ./track */ "../athena/src/track.js");

__webpack_require__(/*! ./plugins/app-tracker */ "../athena/src/plugins/app-tracker.js");

__webpack_require__(/*! ./plugins/console-tracker */ "../athena/src/plugins/console-tracker.js");

__webpack_require__(/*! ./plugins/page-tracker */ "../athena/src/plugins/page-tracker.js");

__webpack_require__(/*! ./plugins/request-tracker */ "../athena/src/plugins/request-tracker.js");

__webpack_require__(/*! ./plugins/uiaction-tracker */ "../athena/src/plugins/uiaction-tracker.js");

var _urlTransformer = __webpack_require__(/*! ./util/url-transformer */ "../athena/src/util/url-transformer.js");

var _EventModel = __webpack_require__(/*! ./eventcon/EventModel */ "../athena/src/eventcon/EventModel.js");

var _h = __webpack_require__(/*! ./binds/h5 */ "../athena/src/binds/h5.js");

// import all trackers
exports.default = {
    Track: _track.Track,
    transformerFilterParams: _urlTransformer.transformerFilterParams,
    transformerPickParams: _urlTransformer.transformerPickParams,
    transformerAppendParams: _urlTransformer.transformerAppendParams,
    transformerExcludeParams: _urlTransformer.transformerExcludeParams,
    transformerPickPathAndSearch: _urlTransformer.transformerPickPathAndSearch,
    EventBase: _EventModel.EventBase,
    EventCAL: _EventModel.EventCAL,
    EventPageChange: _EventModel.EventPageChange,
    EventUiAction: _EventModel.EventUiAction
};

// bind for platform

new _h.H5Binds();

/***/ }),

/***/ "../athena/src/plugins/app-tracker.js":
/*!********************************************!*\
  !*** ../athena/src/plugins/app-tracker.js ***!
  \********************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
    value: true
});

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

var _tracker = __webpack_require__(/*! ../tracker */ "../athena/src/tracker.js");

var _track = __webpack_require__(/*! ../track */ "../athena/src/track.js");

var _constants = __webpack_require__(/*! ../constants */ "../athena/src/constants.js");

var _log = __webpack_require__(/*! ../util/log */ "../athena/src/util/log.js");

var _utilities = __webpack_require__(/*! ../util/utilities */ "../athena/src/util/utilities.js");

var _EventModel = __webpack_require__(/*! ../eventcon/EventModel */ "../athena/src/eventcon/EventModel.js");

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _possibleConstructorReturn(self, call) { if (!self) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return call && (typeof call === "object" || typeof call === "function") ? call : self; }

function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; }

var AppTracker = function (_Tracker) {
    _inherits(AppTracker, _Tracker);

    /**
     * @param {string} track, Track实例
     * @param {Object} opts, 一组参数
        opts.urlTransformer, 一个函数, 进行 url 格式变换, function(url) {return url};
           预定义:
             - opts.urlTransformer = track.transformerPickParams(["param1"]); // 页面 url query params 仅留下 param1, 其他去掉
             - opts.urlTransformer = track.transformerPickPathAndSearch(); // 页面 url 去掉协议和域名
             - opts.urlTransformer = track.transformerExcludeParams(["param1"]); // 页面 url query params 去掉参数 param1
             - opts.urlTransformer = track.transformerAppendParams("param1", "value1"); // 页面 url query 增加 &param1=value1, 其中值部分传参可为函数, 会自动求值
            当然可以自定义:
               opts.urlTransformer = function(url) {
                   let newUrl = url;
                   // ... 一些处理
                   return newUrl;
               }
            也可以组装预定义的 urlTransformer
               opts.urlTransformer = function (url) {
                    let pickParamsFunc = track.transformerPickParams([]); // 页面 url 去掉所有 query params
                    let pickPathAndSearch = track.transformerPickPathAndSearch(); // 页面 url 去掉域名及协议
                    return pickPathAndSearch(pickParamsFunc(url));
                };
     */
    function AppTracker(track, opts) {
        _classCallCheck(this, AppTracker);

        var defaultOpts = {
            urlTransformer: null
        };

        var _this = _possibleConstructorReturn(this, (AppTracker.__proto__ || Object.getPrototypeOf(AppTracker)).call(this, track, (0, _utilities.assign)(defaultOpts, opts)));

        _this.name = _constants.PLUGINS.APP_TRACKER;
        _this.state = {
            url: null
        };

        (0, _track.callImpl)(_constants.IMPL.CONFIG_BIND, { urlTransformer: _this.opts.urlTransformer });
        return _this;
    }

    _createClass(AppTracker, [{
        key: 'onLaunchBegin',
        value: function onLaunchBegin(url) {
            this.state.launchTime = (0, _utilities.now)();
            this.state.url = url;
            _log.Log.log("AppTracker, onLaunchBegin,", url);
        }
    }, {
        key: 'onFirstPageInit',
        value: function onFirstPageInit() {
            this.state.firstInitTime = (0, _utilities.now)();
            _log.Log.log("AppTracker, onFirstPageInit,");
        }
    }, {
        key: 'onFirstPageReady',
        value: function onFirstPageReady() {
            this.state.firstReadyTime = (0, _utilities.now)();

            var e = new _EventModel.EventCAL();
            e.category = "_WEB.PERF_APP_LAUNCH";
            e.state = (0, _track.callImpl)(_constants.IMPL.GET_PAGE_ID);
            e.page = (0, _track.callImpl)(_constants.IMPL.GET_CURRENT_PAGE_URL);
            e.tags.launch_time = "" + this.state.launchTime;
            e.tags.first_init_time = "" + this.state.firstInitTime;
            e.tags.first_ready_time = "" + this.state.firstReadyTime;
            e.values.launch_cost = this.state.firstReadyTime - this.state.launchTime;

            this.deliver({
                type: _constants.EVENTS.PERF_APP_LAUNCH,
                event: e
            });
            _log.Log.log("AppTracker, onFirstPageReady,");
        }
    }, {
        key: 'onAppScriptError',
        value: function onAppScriptError(message, source, line, col, stack) {
            var e = new _EventModel.EventCAL();
            e.category = "_WEB.APP_SCRIPT_ERROR";
            e.state = (0, _track.callImpl)(_constants.IMPL.GET_PAGE_ID);
            e.page = (0, _track.callImpl)(_constants.IMPL.GET_CURRENT_PAGE_URL);
            e.label = message;
            e.tags.message = message;
            e.tags.source = source;
            e.tags.line = "" + line;
            e.tags.col = "" + col;
            e.tags.stack = stack;

            this.deliver({
                type: _constants.EVENTS.APP_SCRIPT_ERROR,
                event: e
            });
        }
    }, {
        key: 'onGetRefer',
        value: function onGetRefer(referId, referData) {
            var e = new _EventModel.EventCAL();
            e.category = "_WEB.LAUNCH_REFER";
            e.state = (0, _track.callImpl)(_constants.IMPL.GET_PAGE_ID);
            e.page = (0, _track.callImpl)(_constants.IMPL.GET_CURRENT_PAGE_URL);
            e.label = referId;
            e.tags.refer_data = referData;

            this.deliver({
                type: _constants.EVENTS.LAUNCH_REFER,
                event: e
            });
        }
    }, {
        key: 'onPageNotFound',
        value: function onPageNotFound(url) {
            var e = new _EventModel.EventCAL();
            e.category = "_WEB.PAGE_NOT_FOUND_ERROR";
            e.state = url;
            e.page = url;

            this.deliver({
                type: _constants.EVENTS.PAGE_NOT_FOUND_ERROR,
                event: e
            });
        }
    }]);

    return AppTracker;
}(_tracker.Tracker);

(0, _track.provide)(_constants.PLUGINS.APP_TRACKER, AppTracker);

exports.default = AppTracker;

/***/ }),

/***/ "../athena/src/plugins/console-tracker.js":
/*!************************************************!*\
  !*** ../athena/src/plugins/console-tracker.js ***!
  \************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
    value: true
});

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

var _tracker = __webpack_require__(/*! ../tracker */ "../athena/src/tracker.js");

var _track = __webpack_require__(/*! ../track */ "../athena/src/track.js");

var _constants = __webpack_require__(/*! ../constants */ "../athena/src/constants.js");

var _EventModel = __webpack_require__(/*! ../eventcon/EventModel */ "../athena/src/eventcon/EventModel.js");

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _possibleConstructorReturn(self, call) { if (!self) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return call && (typeof call === "object" || typeof call === "function") ? call : self; }

function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; }

var ConsoleTracker = function (_Tracker) {
    _inherits(ConsoleTracker, _Tracker);

    function ConsoleTracker(track, opts) {
        _classCallCheck(this, ConsoleTracker);

        var _this = _possibleConstructorReturn(this, (ConsoleTracker.__proto__ || Object.getPrototypeOf(ConsoleTracker)).call(this, track, opts));

        _this.name = _constants.PLUGINS.CONSOLE_TRACKER;
        _this.onConsoleError = _this.onConsoleError.bind(_this);
        return _this;
    }

    _createClass(ConsoleTracker, [{
        key: 'onConsoleError',
        value: function onConsoleError(content) {
            var e = new _EventModel.EventCAL();
            e.category = "_WEB.CONSOLE";
            e.state = (0, _track.callImpl)(_constants.IMPL.GET_PAGE_ID);
            e.page = (0, _track.callImpl)(_constants.IMPL.GET_CURRENT_PAGE_URL);
            e.action = "error";
            e.label = content;
            e.tags.init_time = "" + r.initTime;
            e.tags.ready_time = "" + r.readyTime;
            e.values.load_cost = r.loadCost;

            this.deliver({
                type: _constants.EVENTS.CONSOLE_ERROR,
                event: e
            });
        }
    }]);

    return ConsoleTracker;
}(_tracker.Tracker);

(0, _track.provide)(_constants.PLUGINS.CONSOLE_TRACKER, ConsoleTracker);

exports.default = ConsoleTracker;

/***/ }),

/***/ "../athena/src/plugins/page-tracker.js":
/*!*********************************************!*\
  !*** ../athena/src/plugins/page-tracker.js ***!
  \*********************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
    value: true
});

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

var _tracker = __webpack_require__(/*! ../tracker */ "../athena/src/tracker.js");

var _track = __webpack_require__(/*! ../track */ "../athena/src/track.js");

var _constants = __webpack_require__(/*! ../constants */ "../athena/src/constants.js");

var _log = __webpack_require__(/*! ../util/log */ "../athena/src/util/log.js");

var _utilities = __webpack_require__(/*! ../util/utilities */ "../athena/src/util/utilities.js");

var _EventModel = __webpack_require__(/*! ../eventcon/EventModel */ "../athena/src/eventcon/EventModel.js");

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _possibleConstructorReturn(self, call) { if (!self) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return call && (typeof call === "object" || typeof call === "function") ? call : self; }

function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; }

var PageTracker = function (_Tracker) {
    _inherits(PageTracker, _Tracker);

    function PageTracker(track, opts) {
        _classCallCheck(this, PageTracker);

        var _this = _possibleConstructorReturn(this, (PageTracker.__proto__ || Object.getPrototypeOf(PageTracker)).call(this, track, opts));

        _this.name = _constants.PLUGINS.PAGE_TRACKER;
        _this.pageRecords = {};
        _this.onPageControllerShowPage = _this.onPageControllerShowPage.bind(_this);
        _this.onPageControllerHidePage = _this.onPageControllerHidePage.bind(_this);
        return _this;
    }

    _createClass(PageTracker, [{
        key: 'onPageControllerShowPage',
        value: function onPageControllerShowPage(pageId, pageUrl) {
            var ps = PageTracker.ps; // get ps

            _log.Log.debug("PageTracker, onPageControllerShowPage:", pageId, "currentPageId:", ps.currentPageId);

            if (pageId !== ps.currentPageId) {
                var timeNow = (0, _utilities.now)();

                ps.lastPageUrl = ps.currentPageUrl;
                ps.lastPageId = ps.currentPageId;
                ps.lastPageStart = ps.currentPageStart;
                ps.lastPageEnd = ps.currentPageEnd || timeNow;
                ps.currentPageUrl = pageUrl;
                ps.currentPageId = pageId;
                ps.currentPageStart = timeNow;
                ps.currentPageEnd = null;

                PageTracker.ps = ps; // set ps

                var e = new _EventModel.EventPageChange();
                e.pre_page_id = ps.lastPageId;
                e.pre_page = ps.lastPageUrl;
                e.pre_page_start = (0, _utilities.epoch2String)(ps.lastPageStart);
                e.pre_page_end = (0, _utilities.epoch2String)(ps.lastPageEnd);
                e.page_id = ps.currentPageId;
                e.page = ps.currentPageUrl;
                e.page_start = (0, _utilities.epoch2String)(ps.currentPageStart);

                this.deliver({
                    type: _constants.EVENTS.PAGE_CHANGE,
                    event: e
                });
            }
        }
    }, {
        key: 'onPageControllerHidePage',
        value: function onPageControllerHidePage(pageId) {
            if (pageId === PageTracker.ps.currentPageId) {
                PageTracker.ps.currentPageEnd = (0, _utilities.now)();
            } else {
                _log.Log.error("PageTracker.onPageReady, page will 'hide', but not found record for 'show'", (0, _track.callImpl)(_constants.IMPL.GET_CURRENT_PAGE_IDENTIFY));
            }
        }
    }, {
        key: 'getPageRecord',
        value: function getPageRecord() {
            var pageIdentify = (0, _track.callImpl)(_constants.IMPL.GET_CURRENT_PAGE_IDENTIFY);
            this.pageRecords[pageIdentify] = this.pageRecords[pageIdentify] || {};
            return this.pageRecords[pageIdentify];
        }

        // 页面初始化

    }, {
        key: 'onPageInit',
        value: function onPageInit() {
            var pageIdentify = (0, _track.callImpl)(_constants.IMPL.GET_CURRENT_PAGE_IDENTIFY);
            this.pageRecords[pageIdentify] = {
                initTime: (0, _utilities.now)()
            };
            _log.Log.log("PageTracker.onPageInit:", pageIdentify, this.pageRecords[pageIdentify]);
        }

        // 页面已经渲染完成, onPageInit + onPageReady -> PerfPageLoad Event

    }, {
        key: 'onPageReady',
        value: function onPageReady() {
            var r = this.getPageRecord();
            r.readyTime = (0, _utilities.now)();

            if (r.initTime) {
                r.loadCost = r.readyTime - r.initTime; // ms

                var e = new _EventModel.EventCAL();
                e.category = "_WEB.PERF_PAGE_LOAD";
                e.state = (0, _track.callImpl)(_constants.IMPL.GET_PAGE_ID);
                e.page = (0, _track.callImpl)(_constants.IMPL.GET_CURRENT_PAGE_URL);
                e.tags.init_time = "" + r.initTime;
                e.tags.ready_time = "" + r.readyTime;
                e.values.load_cost = r.loadCost;

                this.deliver({
                    type: _constants.EVENTS.PERF_PAGE_LOAD,
                    event: e
                });
                _log.Log.log("PageTracker.onPageReady:", (0, _track.callImpl)(_constants.IMPL.GET_CURRENT_PAGE_IDENTIFY), r, "load time(ms):", r.loadTime);
            } else {
                _log.Log.error("PageTracker.onPageReady, page is ready, but not found record for init.");
            }
        }

        // 页面进入前台

    }, {
        key: 'onPageShow',
        value: function onPageShow() {
            var pageId = (0, _track.callImpl)(_constants.IMPL.GET_PAGE_ID);
            _log.Log.debug("PageTracker, onPageShow:", pageId);
            var r = this.getPageRecord();
            r.showTime = (0, _utilities.now)();

            this.onPageControllerShowPage(pageId, (0, _track.callImpl)(_constants.IMPL.GET_CURRENT_PAGE_URL));

            _log.Log.log("PageTracker.onPageShow:", (0, _track.callImpl)(_constants.IMPL.GET_CURRENT_PAGE_IDENTIFY), r);
        }

        /*
        * onPageShow + onPageHide -> PageChange Event
        * 页面退后台, 引发退后台事件, {page} -> `_background_`
        * 如果 `Hide` 之后紧接着 `Show` (间隔 1 秒内), 则认为是界面跳转
        * 并且忽略 `_background_`
        */

    }, {
        key: 'onPageHide',
        value: function onPageHide() {
            var pageId = (0, _track.callImpl)(_constants.IMPL.GET_PAGE_ID);
            _log.Log.debug("PageTracker, onPageHide:", pageId);
            var r = this.getPageRecord();
            r.hideTime = (0, _utilities.now)();

            this.onPageControllerHidePage(pageId);

            _log.Log.log("PageTracker.onPageHide:", (0, _track.callImpl)(_constants.IMPL.GET_CURRENT_PAGE_IDENTIFY), r);
        }
    }, {
        key: 'onAppBackground',
        value: function onAppBackground() {
            this.onPageControllerShowPage(_constants.PAGE_BACKGROUND);
            _log.Log.log("PageTracker.onAppBackground.");
        }

        // 开始绘制

    }, {
        key: 'onRenderBegin',
        value: function onRenderBegin() {}
        // TODO, 暂不实现

        // 绘制结束, onRenderBegin + onRenderEnd -> PerfPageRender Event

    }, {
        key: 'onRenderEnd',
        value: function onRenderEnd() {}
        // TODO, 暂不实现


        // 在设置 Data 更新页面时使用

    }, {
        key: 'onUpdateWithData',
        value: function onUpdateWithData(data) {
            // TODO, 暂不实现
        }
    }], [{
        key: 'ps',
        get: function get() {
            var ps = (0, _track.callImpl)(_constants.IMPL.STORE_GET, "pageTracker.ps");
            if (ps) {
                ps = JSON.parse(ps);
            }
            if (!ps) {
                ps = {
                    lastPageUrl: null,
                    lastPageId: null,
                    lastPageStart: null,
                    lastPageEnd: null,
                    currentPageUrl: _constants.PAGE_BACKGROUND,
                    currentPageId: _constants.PAGE_BACKGROUND,
                    currentPageStart: (0, _utilities.now)(),
                    currentPageEnd: null
                };
            }
            _log.Log.debug("PageTracker, get ps:", ps);
            return ps;
        },
        set: function set(value) {
            _log.Log.debug("PageTracker, set ps:", value);
            (0, _track.callImpl)(_constants.IMPL.STORE_PUT, "pageTracker.ps", JSON.stringify(value));
        }
    }]);

    return PageTracker;
}(_tracker.Tracker);

(0, _track.provide)(_constants.PLUGINS.PAGE_TRACKER, PageTracker);

exports.default = PageTracker;

/***/ }),

/***/ "../athena/src/plugins/request-tracker.js":
/*!************************************************!*\
  !*** ../athena/src/plugins/request-tracker.js ***!
  \************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
    value: true
});

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

var _tracker = __webpack_require__(/*! ../tracker */ "../athena/src/tracker.js");

var _track = __webpack_require__(/*! ../track */ "../athena/src/track.js");

var _constants = __webpack_require__(/*! ../constants */ "../athena/src/constants.js");

var _utilities = __webpack_require__(/*! ../util/utilities */ "../athena/src/util/utilities.js");

var _log = __webpack_require__(/*! ../util/log */ "../athena/src/util/log.js");

var _EventModel = __webpack_require__(/*! ../eventcon/EventModel */ "../athena/src/eventcon/EventModel.js");

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _possibleConstructorReturn(self, call) { if (!self) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return call && (typeof call === "object" || typeof call === "function") ? call : self; }

function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; }

var RequestTracker = function (_Tracker) {
    _inherits(RequestTracker, _Tracker);

    /**
     * @param {string} track, Track实例
     * @param {Object} opts, 一组参数
         opts.excludePatterns, list, 采集时排除特定的 url 模式
            例子: 如设置为 ['/web/exclude', '/web/exclude2'], 将不会采集 url 包含 /web/exclude 或者 /web/exclude2 的请求
         opts.isRequestStatusOk, bool function(method, url, statusCode);
            业务方自定义 HTTP StatusCode 为成功的逻辑
            默认 `statusCode >= 200 && statusCode < 400` 标记为失败
         opts.isRequestLogicOk, bool function(method, url, statusCode, data);
            业务方自定义 API 在逻辑上是成功的逻辑, 业务方若使用此功能必须设置判断数据是否成功的回调函数
            默认所有请求在逻辑上都是成功
     */
    function RequestTracker(track, opts) {
        _classCallCheck(this, RequestTracker);

        var defaultOpts = {
            excludePatterns: [],
            isRequestStatusOk: RequestTracker.defaultIsRequestStatusOk,
            isRequestLogicOk: RequestTracker.defaultIsRequestLogicOk
        };

        var _this = _possibleConstructorReturn(this, (RequestTracker.__proto__ || Object.getPrototypeOf(RequestTracker)).call(this, track, (0, _utilities.assign)(defaultOpts, opts)));

        _this.opts.excludePatterns.push("entrance/upload"); // Athena 相关的不采集
        _this.name = _constants.PLUGINS.REQUEST_TRACKER;
        _this.reqRecords = {};
        _this.isRequestStatusOk = opts.isRequestStatusOk || RequestTracker.defaultIsRequestStatusOk;
        _this.isRequestLogicOk = opts.isRequestLogicOk || RequestTracker.defaultIsRequestLogicOk;
        return _this;
    }

    _createClass(RequestTracker, [{
        key: 'isExcludeUrl',
        value: function isExcludeUrl(url) {
            return this.opts.excludePatterns.some(function (p) {
                return url.includes(p);
            });
        }
    }, {
        key: 'onRequestBegin',
        value: function onRequestBegin(id, method, url) {
            if (this.isExcludeUrl(url)) return;

            this.reqRecords[id] = {
                startTime: (0, _utilities.now)(),
                url: url
            };
            _log.Log.log("RequestTracker.onRequestBegin:", id, this.reqRecords[id]);
        }
    }, {
        key: 'onRequestComplete',
        value: function onRequestComplete(id, method, url, httpStatus, data) {
            if (this.isExcludeUrl(url)) return;

            _log.Log.log("RequestTracker.onRequestComplete:", id, this.reqRecords[id]);

            var r = this.reqRecords[id];
            if (!r) {
                console.error("RequestTracker.onRequestComplete, request 'end', but not found 'begin'", id, url);
            }

            r.endTime = (0, _utilities.now)();

            // 性能事件
            if (r.startTime) {
                r.cost = r.endTime - r.startTime;
            } else {
                console.error("RequestTracker.onRequestComplete, request 'end', but not found '.startTime'", id, url);
            }

            var common = {
                state: (0, _track.callImpl)(_constants.IMPL.GET_PAGE_ID),
                page: (0, _track.callImpl)(_constants.IMPL.GET_CURRENT_PAGE_URL),
                label: url,
                values: {
                    // 暂时不开, 后台不支持 long 数据类型
                    // start_time: r.startTime,
                    // end_time: r.endTime,
                    cost: r.cost || 0,
                    http_status: httpStatus
                }
            };

            var e = new _EventModel.EventCAL();
            e.category = "_WEB.PERF_REQUEST";
            this.deliver({ type: _constants.EVENTS.PERF_REQUEST, event: (0, _utilities.assign)(e, common) });

            // 网络错误
            var isRequestStatusOk = this.isRequestStatusOk(method, url, httpStatus);
            if (!isRequestStatusOk) {
                var _e = new _EventModel.EventCAL();
                _e.category = "_WEB.REQUEST_NETWORK_ERROR";
                this.deliver({ type: _constants.EVENTS.REQUEST_NETWORK_ERROR, event: (0, _utilities.assign)(_e, common) });
            }

            // 逻辑错误
            var logic = this.isRequestLogicOk(method, url, httpStatus, data);
            if (!logic.ok) {
                var _e2 = new _EventModel.EventCAL();
                _e2.category = "_WEB.REQUEST_LOGIC_ERROR";
                _e2.tags.logic_code = (logic.code || 0).toString();
                _e2.tags.logic_msg = logic.msg;
                this.deliver({ type: _constants.EVENTS.REQUEST_LOGIC_ERROR, event: (0, _utilities.assign)(_e2, common) });
            }
        }
    }], [{
        key: 'defaultIsRequestStatusOk',
        value: function defaultIsRequestStatusOk(method, url, statusCode) {
            return statusCode >= 200 && statusCode < 400;
        }
    }, {
        key: 'defaultIsRequestLogicOk',
        value: function defaultIsRequestLogicOk(method, url, statusCode, data) {
            return {
                ok: true,
                code: "0",
                msg: "ok"
            };
        }
    }]);

    return RequestTracker;
}(_tracker.Tracker);

(0, _track.provide)(_constants.PLUGINS.REQUEST_TRACKER, RequestTracker);

exports.default = RequestTracker;

/***/ }),

/***/ "../athena/src/plugins/uiaction-tracker.js":
/*!*************************************************!*\
  !*** ../athena/src/plugins/uiaction-tracker.js ***!
  \*************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
    value: true
});

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

var _tracker = __webpack_require__(/*! ../tracker */ "../athena/src/tracker.js");

var _track = __webpack_require__(/*! ../track */ "../athena/src/track.js");

var _constants = __webpack_require__(/*! ../constants */ "../athena/src/constants.js");

var _utilities = __webpack_require__(/*! ../util/utilities */ "../athena/src/util/utilities.js");

var _EventModel = __webpack_require__(/*! ../eventcon/EventModel */ "../athena/src/eventcon/EventModel.js");

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

function _possibleConstructorReturn(self, call) { if (!self) { throw new ReferenceError("this hasn't been initialised - super() hasn't been called"); } return call && (typeof call === "object" || typeof call === "function") ? call : self; }

function _inherits(subClass, superClass) { if (typeof superClass !== "function" && superClass !== null) { throw new TypeError("Super expression must either be null or a function, not " + typeof superClass); } subClass.prototype = Object.create(superClass && superClass.prototype, { constructor: { value: subClass, enumerable: false, writable: true, configurable: true } }); if (superClass) Object.setPrototypeOf ? Object.setPrototypeOf(subClass, superClass) : subClass.__proto__ = superClass; }

var UiActionTracker = function (_Tracker) {
    _inherits(UiActionTracker, _Tracker);

    /**
     * @param {string} track, Track实例
     * @param {Object} opts, 一组参数
         opts.eventTypes, list, 设置采集的事件列表, 可选
             - `click`: 点击事件
             - `scroll`: 滚动事件
            默认为全部开启.
         opts.scrollThreshold, int, 页面滚动触发上报阈值, 当距离上次上报累计滚动超过 `scrollThreshold` 时, 将会再次上报滚动事件
            默认为 10, 即滚动累计超过 10% 上报
     */
    function UiActionTracker(track, opts) {
        _classCallCheck(this, UiActionTracker);

        var defaultOpts = {
            eventTypes: ["click", "scroll"],
            scrollThreshold: 10 // 每滚动 10% 触发一次事件
        };

        var _this = _possibleConstructorReturn(this, (UiActionTracker.__proto__ || Object.getPrototypeOf(UiActionTracker)).call(this, track, (0, _utilities.assign)(defaultOpts, opts)));

        _this.name = _constants.PLUGINS.UI_ACTION_TRACKER;
        return _this;
    }

    _createClass(UiActionTracker, [{
        key: 'onBindTrigger',
        value: function onBindTrigger(type, name, text, extra) {
            // type must be `UI_ACTION_TYPES`
            var e = new _EventModel.EventUiAction();
            e.op = type;
            e.page_id = (0, _track.callImpl)(_constants.IMPL.GET_PAGE_ID);
            e.page = (0, _track.callImpl)(_constants.IMPL.GET_CURRENT_PAGE_URL);
            e.view_tag = (name || "").slice(0, 31);
            e.view_text = (text.replace(/[\d.]/gi, '*') || "").slice(0, 31);
            e.data = {};

            if (type === _constants.UI_ACTION_TYPES.CLICK || type === _constants.UI_ACTION_TYPES.LONG_PRESS) {
                e.data.p0 = (parseInt(extra.clientX) || -1) + "," + (parseInt(extra.clientY) || -1);
                e.data.p1 = (parseInt(extra.absX) || -1) + "," + (parseInt(extra.absY) || -1);
            } else if (type === _constants.UI_ACTION_TYPES.SCROLL) {
                e.data.p0 = extra.startPoint;
                e.data.p1 = extra.endPoint;
                e.data.p2 = extra.startAbsPoint;
                e.data.p3 = extra.endAbsPoint;
            } else {
                Log.log("UiActionTracker.onBindTrigger, not handled action type:", type);
            }
            this.deliver({ type: _constants.EVENTS.UI_ACTION, event: e });
        }
    }]);

    return UiActionTracker;
}(_tracker.Tracker);

(0, _track.provide)(_constants.PLUGINS.UI_ACTION_TRACKER, UiActionTracker);

exports.default = UiActionTracker;

/***/ }),

/***/ "../athena/src/track.js":
/*!******************************!*\
  !*** ../athena/src/track.js ***!
  \******************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
    value: true
});
exports.Track = undefined;

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

exports.provide = provide;
exports.trigger = trigger;
exports.provideImpl = provideImpl;
exports.callImpl = callImpl;

var _log = __webpack_require__(/*! ./util/log */ "../athena/src/util/log.js");

var _constants = __webpack_require__(/*! ./constants */ "../athena/src/constants.js");

var _AthenaEnum = __webpack_require__(/*! ./eventcon/AthenaEnum */ "../athena/src/eventcon/AthenaEnum.js");

var _eventcon = __webpack_require__(/*! ./eventcon/eventcon */ "../athena/src/eventcon/eventcon.js");

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

var Track = exports.Track = function () {
    function Track() {
        _classCallCheck(this, Track);

        this.instance = null;
        this.conf = {
            appId: "",
            version: "",
            userId: ""
        };
        this.plugins = {};
        this.pluginInstances = {};
        this.impl = {
            getCurrentPageUrl: null,
            getPageId: null,
            getPageMark: null,
            storePut: null,
            storeGet: null,
            httpRequest: null,
            getDeviceInfo: null, // {width: 210, height: 340, deviceId: "32712878-898989-9090-90901"}
            onStart: null,
            configBind: null // { urlTransformer: function, }
        };
    }

    _createClass(Track, [{
        key: "setField",
        value: function setField(field, value) {
            var eventConFields = [_AthenaEnum.Field.APP_ID, _AthenaEnum.Field.USER_ID, _AthenaEnum.Field.VERSION, _AthenaEnum.Field.BUILD_ID, _AthenaEnum.Field.BUCKETS, _AthenaEnum.Field.ATHENA_BASE_URL, _AthenaEnum.Field.ENABLE_UPLOAD_ATHENA, _AthenaEnum.Field.DEVICE_ID, _AthenaEnum.Field.UPLOAD_PERIOD];
            if (eventConFields.indexOf(field) > -1) {
                _eventcon.EventCon.getInstance().setField(field, value);
            } else {
                switch (field) {
                    case _constants.CONFIG_FIELDS.LOG_LEVEL:
                        _log.Log.logLevel = value;
                        break;
                    default:
                        _log.Log.error("Track.setField, can not accept field:", field);
                }
            }
        }
    }, {
        key: "enableTracker",


        // 开启 Tracker, 并配置参数
        value: function enableTracker(trackerName, opts) {
            var tracker = this.plugins[trackerName];
            if (tracker) {
                var inst = new tracker(Track.getInstance(), opts);
                this.pluginInstances[trackerName] = inst;
                inst.init();
                inst.start();
            } else {
                _log.Log.error("tracker not exists:", trackerName);
            }
        }

        // 开启 Tracker, 并配置参数

    }, {
        key: "enableAllTracker",
        value: function enableAllTracker(trackerOpts) {
            trackerOpts = trackerOpts || {};
            var _this = this;
            Object.keys(_constants.PLUGINS).forEach(function (tracker) {
                _this.enableTracker(_constants.PLUGINS[tracker], trackerOpts[tracker] || {});
            });
        }
    }, {
        key: "start",
        value: function start() {
            callImpl(_constants.IMPL.ON_START);
            _eventcon.EventCon.getInstance().start();
        }
    }], [{
        key: "getInstance",
        value: function getInstance() {
            if (!this.instance) {
                this.instance = new Track();
            }
            return this.instance;
        }
    }, {
        key: "customTrack",
        value: function customTrack(event) {
            return _eventcon.EventCon.getInstance().sendEvent(event);
        }
    }]);

    return Track;
}();

// 注册插件


function provide(pluginName, pluginConstructor) {
    var t = Track.getInstance();
    if (t.plugins[pluginName]) {
        _log.Log.error("provide, the plugin already exists:", pluginName);
        return;
    }
    t.plugins[pluginName] = pluginConstructor;
}

// 触发插件协议接口
function trigger(pluginName, functionName) {
    var tracker = Track.getInstance().pluginInstances[pluginName];
    if (!tracker) {
        // Log.error("trigger, the plugin instances not exists:", pluginName, Object.keys(Track.getInstance().pluginInstances));
        return;
    }

    var func = tracker[functionName];
    if (!func) {
        _log.Log.error("trigger, the function '" + functionName + "' of plugin '" + pluginName + "' not exists");
        return;
    }

    try {
        for (var _len = arguments.length, args = Array(_len > 2 ? _len - 2 : 0), _key = 2; _key < _len; _key++) {
            args[_key - 2] = arguments[_key];
        }

        return func.call.apply(func, [tracker].concat(args));
    } catch (e) {
        _log.Log.error("trigger, " + pluginName + "." + functionName + " exception:", e);
    }
}

// 注册平台相关实现
function provideImpl(func, impl) {
    var t = Track.getInstance();
    if (t.impl[func]) {
        _log.Log.error("provideImpl, already exists:", func);
        return;
    }
    t.impl[func] = impl;
}

// 调用平台相关实现
function callImpl(func) {
    var t = Track.getInstance();
    var f = t.impl[func];
    if (!f) {
        _log.Log.error("Track.callImpl, func ${func} not implement:", func);
        return;
    }

    for (var _len2 = arguments.length, rest = Array(_len2 > 1 ? _len2 - 1 : 0), _key2 = 1; _key2 < _len2; _key2++) {
        rest[_key2 - 1] = arguments[_key2];
    }

    return f.apply(this, rest);
}

/***/ }),

/***/ "../athena/src/tracker.js":
/*!********************************!*\
  !*** ../athena/src/tracker.js ***!
  \********************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
    value: true
});
exports.Tracker = undefined;

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

var _log = __webpack_require__(/*! ./util/log */ "../athena/src/util/log.js");

var _eventcon = __webpack_require__(/*! ./eventcon/eventcon */ "../athena/src/eventcon/eventcon.js");

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

var Tracker = exports.Tracker = function () {
    function Tracker(track, opts) {
        _classCallCheck(this, Tracker);

        this.opts = opts;
        this.track = track;
        this.name = "Tracker";
    }

    _createClass(Tracker, [{
        key: "getOpts",
        value: function getOpts() {
            return this.opts;
        }
    }, {
        key: "init",
        value: function init() {
            _log.Log.log(this.name + ", init with opts:", this.opts);
        }
    }, {
        key: "start",
        value: function start() {
            _log.Log.log(this.name + ", start ...");
        }
    }, {
        key: "deliver",
        value: function deliver(event) {
            _log.Log.debug(this.name + ", deliver event:", JSON.stringify(event));
            _eventcon.EventCon.getInstance().sendEvent(event.event);
        }
    }, {
        key: "stop",
        value: function stop() {}
    }, {
        key: "remove",
        value: function remove() {}
    }]);

    return Tracker;
}();

/***/ }),

/***/ "../athena/src/util/check.js":
/*!***********************************!*\
  !*** ../athena/src/util/check.js ***!
  \***********************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
  value: true
});

var _typeof = typeof Symbol === "function" && typeof Symbol.iterator === "symbol" ? function (obj) { return typeof obj; } : function (obj) { return obj && typeof Symbol === "function" && obj.constructor === Symbol && obj !== Symbol.prototype ? "symbol" : typeof obj; };

var isFunction = exports.isFunction = function isFunction(f) {
  return !!(f && f.constructor && f.call && f.apply);
};

var class2type = {
  'Boolean': 1,
  'Number': 1,
  'String': 1,
  'Function': 1,
  'Array': 1,
  'Date': 1,
  'RegExp': 1,
  'Object': 1,
  'Error': 1
};
var toString = Object.prototype.toString;

/**
 * Get the type of input.
 *
 * @param {Object} object .
 * @return {string} type .
 */
var type = exports.type = function type(object) {
  if (object == null) {
    return String(object);
  }

  // Support: Safari <= 5.1 (functionish RegExp)
  var t = typeof object === 'undefined' ? 'undefined' : _typeof(object);
  var objType = 'object';
  if (t === objType || t === 'function') {
    t = toString.call(object).slice(8, -1);
    return class2type[t] ? t.toLowerCase() : objType;
  }

  return typeof object === 'undefined' ? 'undefined' : _typeof(object);
};

/**
 * is Array
 *
 * @param {Object} arr .
 * @return {boolean} isArray or not .
 */
var isArray = exports.isArray = function isArray(arr) {
  return type(arr) === 'array';
};

var isEmpty = exports.isEmpty = function isEmpty(obj) {
  if (typeof obj === 'string') {
    obj = obj.trim();
  }
  return obj === null || obj === undefined || obj === '' || obj === 'unknown';
};

/***/ }),

/***/ "../athena/src/util/dom.js":
/*!*********************************!*\
  !*** ../athena/src/util/dom.js ***!
  \*********************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
    value: true
});
var getXPathFromElement = exports.getXPathFromElement = function getXPathFromElement(element) {
    if (element.id !== '' && element.id) return 'id("' + element.id + '")';
    if (element === document.body) return element.tagName;
    if (element === document) return 'document';
    var ix = 0;
    if (element.parentNode) {
        var siblings = element.parentNode.childNodes;
        for (var i = 0; i < siblings.length; i++) {
            var sibling = siblings[i];
            if (sibling === element) return getXPathFromElement(element.parentNode) + '/' + element.tagName + '[' + (ix + 1) + ']';
            if (sibling.nodeType === 1 && sibling.tagName === element.tagName) ix++;
        }
    }
};

var getTextFromElement = exports.getTextFromElement = function getTextFromElement(elem) {
    var ret = '';
    var nodeType = elem.nodeType;

    if (nodeType === 1 || nodeType === 9 || nodeType === 11) {
        // Use textContent for elements
        // innerText usage removed for consistency of new lines (jQuery #11153)
        if (typeof elem.textContent === 'string') {
            return elem.textContent;
        }

        // Traverse its children
        for (elem = elem.firstChild; elem; elem = elem.nextSibling) {
            ret += getText(elem);
        }
    } else if (nodeType === 3 || nodeType === 4) {
        return elem.nodeValue;
    }
    // Do not include comment or processing instruction nodes
    return ret;
};

var getCleanTextFromElement = exports.getCleanTextFromElement = function getCleanTextFromElement(elem) {
    return getTextFromElement(elem).replace(/^\s+|\s+$/g, "").slice(0, 24);
};

var domDelegate = exports.domDelegate = function domDelegate(ancestor, eventType, callback) {
    var useCapture = arguments.length > 3 && arguments[3] !== undefined ? arguments[3] : true;

    var listener = function listener(event) {
        var delegateTarget = document.documentElement;
        if (delegateTarget) {
            callback.call(delegateTarget, event, event.target);
        }
    };

    ancestor.addEventListener(eventType, listener, useCapture);

    return {
        destroy: function destroy() {
            ancestor.removeEventListener(eventType, listener, useCapture);
        }
    };
};

/***/ }),

/***/ "../athena/src/util/hook.js":
/*!**********************************!*\
  !*** ../athena/src/util/hook.js ***!
  \**********************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
    value: true
});
exports.hookMethods = hookMethods;
exports.hookAllMethods = hookAllMethods;

var _log = __webpack_require__(/*! ./log */ "../athena/src/util/log.js");

var _check = __webpack_require__(/*! ./check */ "../athena/src/util/check.js");

function hookMethods(name, obj, hooks) {
    Object.keys(hooks).forEach(function (method) {
        var oriFunc = obj[method];
        if (!(0, _check.isFunction)(oriFunc)) return;
        obj[method] = function () {
            try {
                hooks[method].apply(this, arguments);
            } catch (e) {
                _log.Log.error("hookMethods, exec hook method " + method + " of obj " + name + " raise exception", e);
            }
            if (oriFunc) {
                return oriFunc.apply(this, arguments);
            }
        };
    });
}

function hookAllMethods(name, obj, hook) {
    Object.keys(obj).filter(function (key) {
        return (0, _check.isFunction)(obj[key]);
    }).forEach(function (method) {
        var oriFunc = obj[method];
        obj[method] = function () {
            try {
                hook.apply(this, [method].concat(Array.prototype.slice.call(arguments)));
            } catch (e) {
                _log.Log.error("hookAllMethods, exec hook method " + method + " of obj " + name + " raise exception", e);
            }
            if (oriFunc) {
                return oriFunc.apply(this, arguments);
            }
        };
    });
}

/***/ }),

/***/ "../athena/src/util/log.js":
/*!*********************************!*\
  !*** ../athena/src/util/log.js ***!
  \*********************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
    value: true
});
var Log = {
    logLevel: "debug", // none|debug|info|log|warn|error|none
    levelMap: {
        "debug": 1,
        "info": 2,
        "log": 3,
        "warn": 4,
        "error": 5,
        "none": 6
    },

    enableLogLevel: function enableLogLevel(level) {
        var checkLevel = this.levelMap[level];
        if (checkLevel == null || checkLevel === undefined) {
            return false;
        }
        var enableLevel = this.levelMap[this.logLevel];
        if (level == null || level === undefined) {
            return false;
        }
        return checkLevel >= enableLevel;
    },


    debug: function debug() {
        if (this.enableLogLevel("debug")) {
            var _console;

            for (var _len = arguments.length, args = Array(_len), _key = 0; _key < _len; _key++) {
                args[_key] = arguments[_key];
            }

            (_console = console).debug.apply(_console, ["track.js,"].concat(args));
        }
    },
    log: function log() {
        if (this.enableLogLevel("log")) {
            var _console2;

            for (var _len2 = arguments.length, args = Array(_len2), _key2 = 0; _key2 < _len2; _key2++) {
                args[_key2] = arguments[_key2];
            }

            (_console2 = console).log.apply(_console2, ["track.js,"].concat(args));
        }
    },
    error: function error() {
        if (this.enableLogLevel("error")) {
            var _console3;

            for (var _len3 = arguments.length, args = Array(_len3), _key3 = 0; _key3 < _len3; _key3++) {
                args[_key3] = arguments[_key3];
            }

            (_console3 = console).error.apply(_console3, ["track.js,"].concat(args));
        }
    }
};

exports.Log = Log;

/***/ }),

/***/ "../athena/src/util/method-chain.js":
/*!******************************************!*\
  !*** ../athena/src/util/method-chain.js ***!
  \******************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
    value: true
});

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

/**
 * Copyright 2017 Google Inc. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

/**
 * @fileoverview
 * The functions exported by this module make it easier (and safer) to override
 * foreign object methods (in a modular way) and respond to or modify their
 * invocation. The primary feature is the ability to override a method without
 * worrying if it's already been overridden somewhere else in the codebase. It
 * also allows for safe restoring of an overridden method by only fully
 * restoring a method once all overrides have been removed.
 */

var instances = [];

/**
 * A class that wraps a foreign object method and emit events before and
 * after the original method is called.
 */

var MethodChain = function () {
    _createClass(MethodChain, null, [{
        key: "add",

        /**
         * Adds the passed override method to the list of method chain overrides.
         * @param {!Object} context The object containing the method to chain.
         * @param {string} methodName The name of the method on the object.
         * @param {!Function} methodOverride The override method to add.
         */
        value: function add(context, methodName, methodOverride) {
            getOrCreateMethodChain(context, methodName).add(methodOverride);
        }

        /**
         * Removes a method chain added via `add()`. If the override is the
         * only override added, the original method is restored. If the method
         * chain does not exist, nothing happens.
         * @param {!Object} context The object containing the method to unchain.
         * @param {string} methodName The name of the method on the object.
         * @param {!Function} methodOverride The override method to remove.
         */

    }, {
        key: "remove",
        value: function remove(context, methodName, methodOverride) {
            var methodChain = getMethodChain(context, methodName);
            if (methodChain) {
                methodChain.remove(methodOverride);
            }
        }

        /**
         * Wraps a foreign object method and overrides it. Also stores a reference
         * to the original method so it can be restored later.
         * @param {!Object} context The object containing the method.
         * @param {string} methodName The name of the method on the object.
         */

    }]);

    function MethodChain(context, methodName) {
        var _this = this;

        _classCallCheck(this, MethodChain);

        this.context = context;
        this.methodName = methodName;
        this.isTask = /Task$/.test(methodName);

        this.originalMethodReference = this.isTask ? context.get(methodName) : context[methodName];

        this.methodChain = [];
        this.boundMethodChain = [];

        // Wraps the original method.
        this.wrappedMethod = function () {
            var lastBoundMethod = _this.boundMethodChain[_this.boundMethodChain.length - 1];

            return lastBoundMethod.apply(undefined, arguments);
        };

        // Override original method with the wrapped one.
        if (this.isTask) {
            context.set(methodName, this.wrappedMethod);
        } else {
            context[methodName] = this.wrappedMethod;
        }
    }

    /**
     * Adds a method to the method chain.
     * @param {!Function} overrideMethod The override method to add.
     */


    _createClass(MethodChain, [{
        key: "add",
        value: function add(overrideMethod) {
            this.methodChain.push(overrideMethod);
            this.rebindMethodChain();
        }

        /**
         * Removes a method from the method chain and restores the prior order.
         * @param {!Function} overrideMethod The override method to remove.
         */

    }, {
        key: "remove",
        value: function remove(overrideMethod) {
            var index = this.methodChain.indexOf(overrideMethod);
            if (index > -1) {
                this.methodChain.splice(index, 1);
                if (this.methodChain.length > 0) {
                    this.rebindMethodChain();
                } else {
                    this.destroy();
                }
            }
        }

        /**
         * Loops through the method chain array and recreates the bound method
         * chain array. This is necessary any time a method is added or removed
         * to ensure proper original method context and order.
         */

    }, {
        key: "rebindMethodChain",
        value: function rebindMethodChain() {
            this.boundMethodChain = [];
            for (var method, i = 0; method = this.methodChain[i]; i++) {
                var previousMethod = this.boundMethodChain[i - 1] || this.originalMethodReference.bind(this.context);
                this.boundMethodChain.push(method(previousMethod));
            }
        }

        /**
         * Calls super and destroys the instance if no registered handlers remain.
         */

    }, {
        key: "destroy",
        value: function destroy() {
            var index = instances.indexOf(this);
            if (index > -1) {
                instances.splice(index, 1);
                if (this.isTask) {
                    this.context.set(this.methodName, this.originalMethodReference);
                } else {
                    this.context[this.methodName] = this.originalMethodReference;
                }
            }
        }
    }]);

    return MethodChain;
}();

/**
 * Gets a MethodChain instance for the passed object and method.
 * @param {!Object} context The object containing the method.
 * @param {string} methodName The name of the method on the object.
 * @return {!MethodChain|undefined}
 */


exports.default = MethodChain;
function getMethodChain(context, methodName) {
    return instances.filter(function (h) {
        return h.context == context && h.methodName == methodName;
    })[0];
}

/**
 * Gets a MethodChain instance for the passed object and method. If the method
 * has already been wrapped via an existing MethodChain instance, that
 * instance is returned.
 * @param {!Object} context The object containing the method.
 * @param {string} methodName The name of the method on the object.
 * @return {!MethodChain}
 */
function getOrCreateMethodChain(context, methodName) {
    var methodChain = getMethodChain(context, methodName);

    if (!methodChain) {
        methodChain = new MethodChain(context, methodName);
        instances.push(methodChain);
    }
    return methodChain;
}

/***/ }),

/***/ "../athena/src/util/page-visibility.js":
/*!*********************************************!*\
  !*** ../athena/src/util/page-visibility.js ***!
  \*********************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
    value: true
});

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

/**
 * h5 only
 */

var PageVisibility = function () {
    function PageVisibility() {
        _classCallCheck(this, PageVisibility);

        this.hidden = null;
        this.visibilityChange = null;
        if (typeof document.hidden !== "undefined") {
            // Opera 12.10 and Firefox 18 and later support
            this.hidden = "hidden";
            this.visibilityChange = "visibilitychange";
        } else if (typeof document.msHidden !== "undefined") {
            this.hidden = "msHidden";
            this.visibilityChange = "msvisibilitychange";
        } else if (typeof document.webkitHidden !== "undefined") {
            this.hidden = "webkitHidden";
            this.visibilityChange = "webkitvisibilitychange";
        }
    }

    _createClass(PageVisibility, [{
        key: "isBackground",
        value: function isBackground() {
            return document[this.hidden] === true;
        }
    }, {
        key: "isVisible",
        value: function isVisible() {
            return document.visibilityState === "visible";
        }
    }, {
        key: "addEventListener",
        value: function addEventListener(handleVisibilityChange, useCapture) {
            document.addEventListener(this.visibilityChange, handleVisibilityChange, useCapture);
        }
    }]);

    return PageVisibility;
}();

var pageVisibility = new PageVisibility();

exports.pageVisibility = pageVisibility;
exports.PageVisibility = PageVisibility;

/***/ }),

/***/ "../athena/src/util/url-transformer.js":
/*!*********************************************!*\
  !*** ../athena/src/util/url-transformer.js ***!
  \*********************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
    value: true
});
exports.transformerPickPathAndSearch = exports.transformerAppendParams = exports.transformerExcludeParams = exports.transformerPickParams = exports.transformerFilterParams = undefined;

var _url = __webpack_require__(/*! ./url */ "../athena/src/util/url.js");

var transformerFilterParams = exports.transformerFilterParams = function transformerFilterParams(filterFunc) {
    return function (url) {
        var urlPath = (0, _url.getUrlPath)(url);
        var queryObj = (0, _url.parseQueryStringToObj)(url);
        var pickObj = {};
        Object.keys(queryObj).forEach(function (param) {
            if (filterFunc(param)) {
                pickObj[param] = queryObj[param];
            }
        });
        var queryString = (0, _url.buildQueryStringFromObj)(pickObj);
        return urlPath + (queryString ? "?" + queryString : "");
    };
};

var transformerPickParams = exports.transformerPickParams = function transformerPickParams(pickParams) {
    return transformerFilterParams(function (param) {
        return pickParams.indexOf(param) > -1;
    });
};

var transformerExcludeParams = exports.transformerExcludeParams = function transformerExcludeParams(excludeParams) {
    return transformerFilterParams(function (param) {
        return excludeParams.indexOf(param) === -1;
    });
};

var transformerAppendParams = exports.transformerAppendParams = function transformerAppendParams(param, valueDelegate) {
    return function (url) {
        if (!param) {
            // 字段名为空
            return url;
        }
        var urlPath = (0, _url.getUrlPath)(url);
        var queryObj = (0, _url.parseQueryStringToObj)(url);
        queryObj[param] = isFunction(valueDelegate) ? valueDelegate() : valueDelegate;
        return urlPath + "?" + (0, _url.buildQueryStringFromObj)(queryObj);
    };
};

var transformerPickPathAndSearch = exports.transformerPickPathAndSearch = function transformerPickPathAndSearch() {
    return function (url) {
        return (0, _url.getUrlPathAndSearch)(url);
    };
};

/***/ }),

/***/ "../athena/src/util/url.js":
/*!*********************************!*\
  !*** ../athena/src/util/url.js ***!
  \*********************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
    value: true
});
exports.getUrlPathAndSearch = exports.escapeReg = exports.getUrlPath = exports.parseHash = exports.buildQueryStringFromObj = exports.parseQueryStringToObj = exports.isUrlMatch = exports.getCurrentUrl = exports.getPath = exports.parseUrl = undefined;

var _log = __webpack_require__(/*! ./log */ "../athena/src/util/log.js");

var _check = __webpack_require__(/*! ./check */ "../athena/src/util/check.js");

var _domUtils = __webpack_require__(/*! dom-utils */ "../../node_modules/dom-utils/index.js");

exports.parseUrl = _domUtils.parseUrl;
var getPath = exports.getPath = function getPath() {
    var location = window.top.location;
    return location.pathname + location.search;
};

var getCurrentUrl = exports.getCurrentUrl = function getCurrentUrl() {
    var location = window.top.location;
    return location.protocol + "//" + location.hostname + location.pathname + location.search;
};

var isUrlMatch = exports.isUrlMatch = function isUrlMatch(url, urlFilter) {
    url = url || getCurrentUrl();
    try {
        if (urlFilter instanceof RegExp) {
            // RE 匹配
            return url.match(urlFilter) !== null;
        } else if (typeof urlFilter === 'string' || urlFilter instanceof String) {
            // URL 前缀匹配
            if (urlFilter.startsWith("http")) {
                return url.startsWith(urlFilter);
            } else {
                var parts = (0, _domUtils.parseUrl)(url);
                var urlPath = parts.pathname;
                return urlPath.startsWith(urlFilter);
            }
        } else {
            _log.Log.error("isUrlMatch, the urlFilter MUST be: RegExp | string,", urlFilter);
            return false;
        }
    } catch (e) {
        _log.Log.error("isUrlMatch, exception,", url, urlFilter, e);
    }
};

/**
 * Get all querys value .
 *
 * @param {string} url URL location
 * @return {Object.<string, string|Array.<string>>} all querys.
 */
var parseQueryStringToObj = exports.parseQueryStringToObj = function parseQueryStringToObj(url) {
    var match = parseHash(url);
    if (match) {
        url = match[1];
    }

    var result = {};
    if (!url) {
        return result;
    }

    var reg = /(?:&|\?)?([^\?&]+)=([^&]*)(?:&|$)/g;
    while (match = reg.exec(url)) {
        var key = decodeQuery(match[1]);
        var value = decodeQuery(match[2]);
        var oldValue = result[key];
        if (typeof oldValue === 'string') {
            result[key] = [oldValue];
            result[key][1] = value;
        } else if (oldValue) {
            oldValue[oldValue.length] = value;
        } else {
            result[key] = value;
        }
    }

    return result;
};

/**
 * json => params
 * @param {Object} json params object
 * @return {string}
 */
var buildQueryStringFromObj = exports.buildQueryStringFromObj = function buildQueryStringFromObj(json) {
    if (!json) {
        return '';
    }

    var s = [];
    var rbracket = /\[\]$/;
    var encode = encodeURIComponent;
    var add = function add(k, v) {
        v = typeof v === 'function' ? v() : v == null ? '' : v;
        s[s.length] = encode(k) + '=' + encode(v);
    };
    var buildParams = function buildParams(prefix, obj) {
        var i;
        var key;
        var l;

        switch ((0, _check.type)(obj)) {
            case 'array':
                if (prefix) {
                    for (i = 0, l = obj.length; i < l; i++) {
                        if (rbracket.test(prefix)) {
                            add(prefix, obj[i]);
                        } else {
                            var subKey = (0, _check.type)(obj[i]) === 'object' ? i : '';
                            buildParams(prefix + '[' + subKey + ']', obj[i]);
                        }
                    }
                } else {
                    for (i = 0, l = obj.length; i < l; i++) {
                        buildParams(obj[i]['key'], obj[i]['value']);
                    }
                }
                break;
            case 'object':
                for (key in obj) {
                    if (obj.hasOwnProperty(key)) {
                        buildParams(prefix ? prefix + '[' + key + ']' : key, obj[key]);
                    }
                }
                break;
            default:
                // stringify
                obj = '' + obj;
                if (prefix) {
                    add(prefix, obj);
                } else {
                    s[s.length] = obj;
                }
                break;
        }
        return s;
    };

    return buildParams('', json).join('&').replace(/%20/g, '+');
};

/**
 * Parse url without '#'
 *
 * @param {string} url URL location
 * @return {Array.<string>} match result.
 */
var parseHash = exports.parseHash = function parseHash(url) {
    return url.match(/(.*?)(#.*)/);
};

/**
 * decodeURIComponent and replace '+' to ' '.
 *
 * @param {string} value query value.
 * @return {string} value or empty string.
 */
var decodeQuery = function decodeQuery(value) {
    // replacing addition symbol with a space
    value = value.replace(/\+/g, ' ');
    // decodeURIComponent
    return decodeURIComponent(value);
};

/**
 * Get query value of url
 *
 * @param {string} url URL location
 * @param {string} key key name
 * @return {string|Array.<string>} value or empty string.
 */
var getQuery = function getQuery(url, key) {
    var match = parseHash(url);
    if (match) {
        url = match[1];
    }

    if (!url) {
        return '';
    }

    var reg = new RegExp('(?:&|\\?)?' + escapeReg(encodeURIComponent(key)) + '=([^&]*)(?:&|$)', 'g');
    var result = [];
    while (match = reg.exec(url)) {
        result.push(decodeQuery(match[1]));
    }

    return result.length <= 1 ? result[0] || '' : result;
};

/**
 * Has query or not.
 *
 * @param {string} url URL location.
 * @param {string} key key name.
 * @return {boolean} has this query or not.
 */
var hasQuery = function hasQuery(url, key, value) {
    var match = parseHash(url);
    if (match) {
        url = match[1];
    }

    if (!url) {
        return false;
    }
    if (value) {
        var reg = new RegExp('(?:&|\\?)?' + escapeReg(encodeURIComponent(key)) + '=' + escapeReg(encodeURIComponent(value)) + '(?:&|$)', '');
    } else {
        var reg = new RegExp('(?:&|\\?)?' + escapeReg(encodeURIComponent(key)) + '=([^&]*)(?:&|$)', '');
    }

    return reg.test(url);
};

var getUrlPath = exports.getUrlPath = function getUrlPath(url) {
    var match = parseHash(url);
    if (match) {
        // url = 'http://baidu.com#hash' => 'http://baidu.com'
        url = match[1];
    }

    if (!url) {
        // url = '#hash'
        return '';
    }
    if (url.indexOf("?") !== -1) {
        url = url.split("?")[0];
    }
    return url;
};

var escapeReg = exports.escapeReg = function escapeReg(input) {
    return String(input).replace(new RegExp('([.*+?^=!:${}()|[\\]\/\\\\-])', 'g'), '\\$1');
};

var getUrlPathAndSearch = exports.getUrlPathAndSearch = function getUrlPathAndSearch(url) {
    var parts = (0, _domUtils.parseUrl)(url);
    return parts.pathname + (parts.search ? "?" + parts.search : "");
};

/***/ }),

/***/ "../athena/src/util/utilities.js":
/*!***************************************!*\
  !*** ../athena/src/util/utilities.js ***!
  \***************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
    value: true
});
exports.debounce = debounce;
exports.now = now;
/**
 * Returns a function, that, as long as it continues to be called, will not
 * actually run. The function will only run after it stops being called for
 * `wait` milliseconds.
 * @param {!Function} fn The function to debounce.
 * @param {number} wait The debounce wait timeout in ms.
 * @return {!Function} The debounced function.
 */
function debounce(fn, wait) {
    var timeout = void 0;
    return function () {
        for (var _len = arguments.length, args = Array(_len), _key = 0; _key < _len; _key++) {
            args[_key] = arguments[_key];
        }

        clearTimeout(timeout);
        timeout = setTimeout(function () {
            return fn.apply(undefined, args);
        }, wait);
    };
}

var assign = exports.assign = Object.assign || function (target) {
    for (var _len2 = arguments.length, sources = Array(_len2 > 1 ? _len2 - 1 : 0), _key2 = 1; _key2 < _len2; _key2++) {
        sources[_key2 - 1] = arguments[_key2];
    }

    for (var i = 0, len = sources.length; i < len; i++) {
        var source = Object(sources[i]);
        for (var key in source) {
            if (Object.prototype.hasOwnProperty.call(source, key)) {
                target[key] = source[key];
            }
        }
    }
    return target;
};

/**
 * @return {number} The current date timestamp
 */
function now() {
    return +new Date();
}

/*eslint-disable */
// https://gist.github.com/jed/982883
/** @param {?=} a */
var uuid = exports.uuid = function b(a) {
    return a ? (a ^ Math.random() * 16 >> a / 4).toString(16) : ([1e7] + -1e3 + -4e3 + -8e3 + -1e11).replace(/[018]/g, b);
};
/* eslint-enable */

var epoch2String = exports.epoch2String = function epoch2String(ms) {
    return new Date(ms).toISOString();
};

/***/ }),

/***/ "../browser/esm/backend.js":
/*!*********************************!*\
  !*** ../browser/esm/backend.js ***!
  \*********************************/
/*! exports provided: BrowserBackend */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "BrowserBackend", function() { return BrowserBackend; });
/* harmony import */ var tslib__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! tslib */ "../../node_modules/tslib/tslib.es6.js");
/* harmony import */ var _sentry_core__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! @sentry/core */ "../core/esm/index.js");
/* harmony import */ var _sentry_types__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! @sentry/types */ "../types/esm/index.js");
/* harmony import */ var _sentry_utils__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! @sentry/utils */ "../utils/esm/index.js");
/* harmony import */ var _parsers__WEBPACK_IMPORTED_MODULE_4__ = __webpack_require__(/*! ./parsers */ "../browser/esm/parsers.js");
/* harmony import */ var _tracekit__WEBPACK_IMPORTED_MODULE_5__ = __webpack_require__(/*! ./tracekit */ "../browser/esm/tracekit.js");
/* harmony import */ var _transports__WEBPACK_IMPORTED_MODULE_6__ = __webpack_require__(/*! ./transports */ "../browser/esm/transports/index.js");







/**
 * The Sentry Browser SDK Backend.
 * @hidden
 */
var BrowserBackend = /** @class */function (_super) {
    Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__extends"])(BrowserBackend, _super);
    function BrowserBackend() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    /**
     * @inheritDoc
     */
    BrowserBackend.prototype._setupTransport = function () {
        if (!this._options.dsn) {
            // We return the noop transport here in case there is no Dsn.
            return _super.prototype._setupTransport.call(this);
        }
        var transportOptions = this._options.transportOptions ? this._options.transportOptions : { dsn: this._options.dsn };
        if (this._options.transport) {
            return new this._options.transport(transportOptions);
        }
        if (Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_3__["supportsFetch"])()) {
            return new _transports__WEBPACK_IMPORTED_MODULE_6__["FetchTransport"](transportOptions);
        }
        return new _transports__WEBPACK_IMPORTED_MODULE_6__["XHRTransport"](transportOptions);
    };
    /**
     * @inheritDoc
     */
    BrowserBackend.prototype.eventFromException = function (exception, hint) {
        var _this = this;
        var event;
        if (Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_3__["isErrorEvent"])(exception) && exception.error) {
            // If it is an ErrorEvent with `error` property, extract it to get actual Error
            var errorEvent = exception;
            exception = errorEvent.error; // tslint:disable-line:no-parameter-reassignment
            event = Object(_parsers__WEBPACK_IMPORTED_MODULE_4__["eventFromStacktrace"])(Object(_tracekit__WEBPACK_IMPORTED_MODULE_5__["_computeStackTrace"])(exception));
            return _sentry_utils__WEBPACK_IMPORTED_MODULE_3__["SyncPromise"].resolve(this._buildEvent(event, hint));
        }
        if (Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_3__["isDOMError"])(exception) || Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_3__["isDOMException"])(exception)) {
            // If it is a DOMError or DOMException (which are legacy APIs, but still supported in some browsers)
            // then we just extract the name and message, as they don't provide anything else
            // https://developer.mozilla.org/en-US/docs/Web/API/DOMError
            // https://developer.mozilla.org/en-US/docs/Web/API/DOMException
            var domException = exception;
            var name_1 = domException.name || (Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_3__["isDOMError"])(domException) ? 'DOMError' : 'DOMException');
            var message_1 = domException.message ? name_1 + ": " + domException.message : name_1;
            return this.eventFromMessage(message_1, _sentry_types__WEBPACK_IMPORTED_MODULE_2__["Severity"].Error, hint).then(function (messageEvent) {
                Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_3__["addExceptionTypeValue"])(messageEvent, message_1);
                return _sentry_utils__WEBPACK_IMPORTED_MODULE_3__["SyncPromise"].resolve(_this._buildEvent(messageEvent, hint));
            });
        }
        if (Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_3__["isError"])(exception)) {
            // we have a real Error object, do nothing
            event = Object(_parsers__WEBPACK_IMPORTED_MODULE_4__["eventFromStacktrace"])(Object(_tracekit__WEBPACK_IMPORTED_MODULE_5__["_computeStackTrace"])(exception));
            return _sentry_utils__WEBPACK_IMPORTED_MODULE_3__["SyncPromise"].resolve(this._buildEvent(event, hint));
        }
        if (Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_3__["isPlainObject"])(exception) && hint && hint.syntheticException) {
            // If it is plain Object, serialize it manually and extract options
            // This will allow us to group events based on top-level keys
            // which is much better than creating new group when any key/value change
            var objectException = exception;
            event = Object(_parsers__WEBPACK_IMPORTED_MODULE_4__["eventFromPlainObject"])(objectException, hint.syntheticException);
            Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_3__["addExceptionTypeValue"])(event, 'Custom Object', undefined, {
                handled: true,
                synthetic: true,
                type: 'generic'
            });
            event.level = _sentry_types__WEBPACK_IMPORTED_MODULE_2__["Severity"].Error;
            return _sentry_utils__WEBPACK_IMPORTED_MODULE_3__["SyncPromise"].resolve(this._buildEvent(event, hint));
        }
        // If none of previous checks were valid, then it means that
        // it's not a DOMError/DOMException
        // it's not a plain Object
        // it's not a valid ErrorEvent (one with an error property)
        // it's not an Error
        // So bail out and capture it as a simple message:
        var stringException = exception;
        return this.eventFromMessage(stringException, undefined, hint).then(function (messageEvent) {
            Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_3__["addExceptionTypeValue"])(messageEvent, "" + stringException, undefined, {
                handled: true,
                synthetic: true,
                type: 'generic'
            });
            messageEvent.level = _sentry_types__WEBPACK_IMPORTED_MODULE_2__["Severity"].Error;
            return _sentry_utils__WEBPACK_IMPORTED_MODULE_3__["SyncPromise"].resolve(_this._buildEvent(messageEvent, hint));
        });
    };
    /**
     * This is an internal helper function that creates an event.
     */
    BrowserBackend.prototype._buildEvent = function (event, hint) {
        return Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__assign"])(Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__assign"])({}, event), { event_id: hint && hint.event_id });
    };
    /**
     * @inheritDoc
     */
    BrowserBackend.prototype.eventFromMessage = function (message, level, hint) {
        if (level === void 0) {
            level = _sentry_types__WEBPACK_IMPORTED_MODULE_2__["Severity"].Info;
        }
        var event = {
            event_id: hint && hint.event_id,
            level: level,
            message: message
        };
        if (this._options.attachStacktrace && hint && hint.syntheticException) {
            var stacktrace = Object(_tracekit__WEBPACK_IMPORTED_MODULE_5__["_computeStackTrace"])(hint.syntheticException);
            var frames_1 = Object(_parsers__WEBPACK_IMPORTED_MODULE_4__["prepareFramesForEvent"])(stacktrace.stack);
            event.stacktrace = {
                frames: frames_1
            };
        }
        return _sentry_utils__WEBPACK_IMPORTED_MODULE_3__["SyncPromise"].resolve(event);
    };
    return BrowserBackend;
}(_sentry_core__WEBPACK_IMPORTED_MODULE_1__["BaseBackend"]);

//# sourceMappingURL=backend.js.map

/***/ }),

/***/ "../browser/esm/client.js":
/*!********************************!*\
  !*** ../browser/esm/client.js ***!
  \********************************/
/*! exports provided: BrowserClient */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "BrowserClient", function() { return BrowserClient; });
/* harmony import */ var tslib__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! tslib */ "../../node_modules/tslib/tslib.es6.js");
/* harmony import */ var _sentry_core__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! @sentry/core */ "../core/esm/index.js");
/* harmony import */ var _sentry_utils__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! @sentry/utils */ "../utils/esm/index.js");
/* harmony import */ var _backend__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! ./backend */ "../browser/esm/backend.js");
/* harmony import */ var _version__WEBPACK_IMPORTED_MODULE_4__ = __webpack_require__(/*! ./version */ "../browser/esm/version.js");





/**
 * The Sentry Browser SDK Client.
 *
 * @see BrowserOptions for documentation on configuration options.
 * @see SentryClient for usage documentation.
 */
var BrowserClient = /** @class */function (_super) {
    Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__extends"])(BrowserClient, _super);
    /**
     * Creates a new Browser SDK instance.
     *
     * @param options Configuration options for this SDK.
     */
    function BrowserClient(options) {
        if (options === void 0) {
            options = {};
        }
        return _super.call(this, _backend__WEBPACK_IMPORTED_MODULE_3__["BrowserBackend"], options) || this;
    }
    /**
     * @inheritDoc
     */
    BrowserClient.prototype._prepareEvent = function (event, scope, hint) {
        event.platform = event.platform || 'javascript';
        event.sdk = Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__assign"])(Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__assign"])({}, event.sdk), { name: _version__WEBPACK_IMPORTED_MODULE_4__["SDK_NAME"], packages: Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__spread"])(event.sdk && event.sdk.packages || [], [{
                name: 'npm:@sentry/browser',
                version: _version__WEBPACK_IMPORTED_MODULE_4__["SDK_VERSION"]
            }]), version: _version__WEBPACK_IMPORTED_MODULE_4__["SDK_VERSION"] });
        return _super.prototype._prepareEvent.call(this, event, scope, hint);
    };
    /**
     * Show a report dialog to the user to send feedback to a specific event.
     *
     * @param options Set individual options for the dialog
     */
    BrowserClient.prototype.showReportDialog = function (options) {
        if (options === void 0) {
            options = {};
        }
        // doesn't work without a document (React Native)
        var document = Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_2__["getGlobalObject"])().document;
        if (!document) {
            return;
        }
        if (!this._isEnabled()) {
            _sentry_utils__WEBPACK_IMPORTED_MODULE_2__["logger"].error('Trying to call showReportDialog with Sentry Client is disabled');
            return;
        }
        var dsn = options.dsn || this.getDsn();
        if (!options.eventId) {
            _sentry_utils__WEBPACK_IMPORTED_MODULE_2__["logger"].error('Missing `eventId` option in showReportDialog call');
            return;
        }
        if (!dsn) {
            _sentry_utils__WEBPACK_IMPORTED_MODULE_2__["logger"].error('Missing `Dsn` option in showReportDialog call');
            return;
        }
        var script = document.createElement('script');
        script.async = true;
        script.src = new _sentry_core__WEBPACK_IMPORTED_MODULE_1__["API"](dsn).getReportDialogEndpoint(options);
        if (options.onLoad) {
            script.onload = options.onLoad;
        }
        (document.head || document.body).appendChild(script);
    };
    return BrowserClient;
}(_sentry_core__WEBPACK_IMPORTED_MODULE_1__["BaseClient"]);

//# sourceMappingURL=client.js.map

/***/ }),

/***/ "../browser/esm/helpers.js":
/*!*********************************!*\
  !*** ../browser/esm/helpers.js ***!
  \*********************************/
/*! exports provided: shouldIgnoreOnError, ignoreNextOnError, wrap, breadcrumbEventHandler, keypressEventHandler */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "shouldIgnoreOnError", function() { return shouldIgnoreOnError; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "ignoreNextOnError", function() { return ignoreNextOnError; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "wrap", function() { return wrap; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "breadcrumbEventHandler", function() { return breadcrumbEventHandler; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "keypressEventHandler", function() { return keypressEventHandler; });
/* harmony import */ var tslib__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! tslib */ "../../node_modules/tslib/tslib.es6.js");
/* harmony import */ var _sentry_core__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! @sentry/core */ "../core/esm/index.js");
/* harmony import */ var _sentry_utils__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! @sentry/utils */ "../utils/esm/index.js");



var debounceDuration = 1000;
var keypressTimeout;
var lastCapturedEvent;
var ignoreOnError = 0;
/**
 * @hidden
 */
function shouldIgnoreOnError() {
    return ignoreOnError > 0;
}
/**
 * @hidden
 */
function ignoreNextOnError() {
    // onerror should trigger before setTimeout
    ignoreOnError += 1;
    setTimeout(function () {
        ignoreOnError -= 1;
    });
}
/**
 * Instruments the given function and sends an event to Sentry every time the
 * function throws an exception.
 *
 * @param fn A function to wrap.
 * @returns The wrapped function.
 * @hidden
 */
function wrap(fn, options, before) {
    if (options === void 0) {
        options = {};
    }
    // tslint:disable-next-line:strict-type-predicates
    if (typeof fn !== 'function') {
        return fn;
    }
    try {
        // We don't wanna wrap it twice
        if (fn.__sentry__) {
            return fn;
        }
        // If this has already been wrapped in the past, return that wrapped function
        if (fn.__sentry_wrapped__) {
            return fn.__sentry_wrapped__;
        }
    } catch (e) {
        // Just accessing custom props in some Selenium environments
        // can cause a "Permission denied" exception (see raven-js#495).
        // Bail on wrapping and return the function as-is (defers to window.onerror).
        return fn;
    }
    var sentryWrapped = function () {
        // tslint:disable-next-line:strict-type-predicates
        if (before && typeof before === 'function') {
            before.apply(this, arguments);
        }
        var args = Array.prototype.slice.call(arguments);
        // tslint:disable:no-unsafe-any
        try {
            // Attempt to invoke user-land function
            // NOTE: If you are a Sentry user, and you are seeing this stack frame, it
            //       means Raven caught an error invoking your application code. This is
            //       expected behavior and NOT indicative of a bug with Raven.js.
            var wrappedArguments = args.map(function (arg) {
                return wrap(arg, options);
            });
            if (fn.handleEvent) {
                return fn.handleEvent.apply(this, wrappedArguments);
            }
            return fn.apply(this, wrappedArguments);
            // tslint:enable:no-unsafe-any
        } catch (ex) {
            ignoreNextOnError();
            Object(_sentry_core__WEBPACK_IMPORTED_MODULE_1__["withScope"])(function (scope) {
                scope.addEventProcessor(function (event) {
                    var processedEvent = Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__assign"])({}, event);
                    if (options.mechanism) {
                        Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_2__["addExceptionTypeValue"])(processedEvent, undefined, undefined, options.mechanism);
                    }
                    processedEvent.extra = Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__assign"])(Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__assign"])({}, processedEvent.extra), { arguments: Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_2__["normalize"])(args, 3) });
                    return processedEvent;
                });
                Object(_sentry_core__WEBPACK_IMPORTED_MODULE_1__["captureException"])(ex);
            });
            throw ex;
        }
    };
    // Accessing some objects may throw
    // ref: https://github.com/getsentry/sentry-javascript/issues/1168
    try {
        for (var property in fn) {
            if (Object.prototype.hasOwnProperty.call(fn, property)) {
                sentryWrapped[property] = fn[property];
            }
        }
    } catch (_oO) {} // tslint:disable-line:no-empty
    fn.prototype = fn.prototype || {};
    sentryWrapped.prototype = fn.prototype;
    Object.defineProperty(fn, '__sentry_wrapped__', {
        enumerable: false,
        value: sentryWrapped
    });
    // Signal that this function has been wrapped/filled already
    // for both debugging and to prevent it to being wrapped/filled twice
    Object.defineProperties(sentryWrapped, {
        __sentry__: {
            enumerable: false,
            value: true
        },
        __sentry_original__: {
            enumerable: false,
            value: fn
        }
    });
    // Restore original function name (not all browsers allow that)
    try {
        Object.defineProperty(sentryWrapped, 'name', {
            get: function () {
                return fn.name;
            }
        });
    } catch (_oO) {
        /*no-empty*/
    }
    return sentryWrapped;
}
var debounceTimer = 0;
/**
 * Wraps addEventListener to capture UI breadcrumbs
 * @param eventName the event name (e.g. "click")
 * @returns wrapped breadcrumb events handler
 * @hidden
 */
function breadcrumbEventHandler(eventName, debounce) {
    if (debounce === void 0) {
        debounce = false;
    }
    return function (event) {
        // reset keypress timeout; e.g. triggering a 'click' after
        // a 'keypress' will reset the keypress debounce so that a new
        // set of keypresses can be recorded
        keypressTimeout = undefined;
        // It's possible this handler might trigger multiple times for the same
        // event (e.g. event propagation through node ancestors). Ignore if we've
        // already captured the event.
        if (!event || lastCapturedEvent === event) {
            return;
        }
        lastCapturedEvent = event;
        var captureBreadcrumb = function () {
            // try/catch both:
            // - accessing event.target (see getsentry/raven-js#838, #768)
            // - `htmlTreeAsString` because it's complex, and just accessing the DOM incorrectly
            //   can throw an exception in some circumstances.
            var target;
            try {
                target = event.target ? _htmlTreeAsString(event.target) : _htmlTreeAsString(event);
            } catch (e) {
                target = '<unknown>';
            }
            if (target.length === 0) {
                return;
            }
            Object(_sentry_core__WEBPACK_IMPORTED_MODULE_1__["getCurrentHub"])().addBreadcrumb({
                category: "ui." + eventName,
                message: target
            }, {
                event: event,
                name: eventName
            });
        };
        if (debounceTimer) {
            clearTimeout(debounceTimer);
        }
        if (debounce) {
            debounceTimer = setTimeout(captureBreadcrumb);
        } else {
            captureBreadcrumb();
        }
    };
}
/**
 * Wraps addEventListener to capture keypress UI events
 * @returns wrapped keypress events handler
 * @hidden
 */
function keypressEventHandler() {
    // TODO: if somehow user switches keypress target before
    //       debounce timeout is triggered, we will only capture
    //       a single breadcrumb from the FIRST target (acceptable?)
    return function (event) {
        var target;
        try {
            target = event.target;
        } catch (e) {
            // just accessing event properties can throw an exception in some rare circumstances
            // see: https://github.com/getsentry/raven-js/issues/838
            return;
        }
        var tagName = target && target.tagName;
        // only consider keypress events on actual input elements
        // this will disregard keypresses targeting body (e.g. tabbing
        // through elements, hotkeys, etc)
        if (!tagName || tagName !== 'INPUT' && tagName !== 'TEXTAREA' && !target.isContentEditable) {
            return;
        }
        // record first keypress in a series, but ignore subsequent
        // keypresses until debounce clears
        if (!keypressTimeout) {
            breadcrumbEventHandler('input')(event);
        }
        clearTimeout(keypressTimeout);
        keypressTimeout = setTimeout(function () {
            keypressTimeout = undefined;
        }, debounceDuration);
    };
}
/**
 * Given a child DOM element, returns a query-selector statement describing that
 * and its ancestors
 * e.g. [HTMLElement] => body > div > input#foo.btn[name=baz]
 * @returns generated DOM path
 */
function _htmlTreeAsString(elem) {
    var currentElem = elem;
    var MAX_TRAVERSE_HEIGHT = 5;
    var MAX_OUTPUT_LEN = 80;
    var out = [];
    var height = 0;
    var len = 0;
    var separator = ' > ';
    var sepLength = separator.length;
    var nextStr;
    while (currentElem && height++ < MAX_TRAVERSE_HEIGHT) {
        nextStr = _htmlElementAsString(currentElem);
        // bail out if
        // - nextStr is the 'html' element
        // - the length of the string that would be created exceeds MAX_OUTPUT_LEN
        //   (ignore this limit if we are on the first iteration)
        if (nextStr === 'html' || height > 1 && len + out.length * sepLength + nextStr.length >= MAX_OUTPUT_LEN) {
            break;
        }
        out.push(nextStr);
        len += nextStr.length;
        currentElem = currentElem.parentNode;
    }
    return out.reverse().join(separator);
}
/**
 * Returns a simple, query-selector representation of a DOM element
 * e.g. [HTMLElement] => input#foo.btn[name=baz]
 * @returns generated DOM path
 */
function _htmlElementAsString(elem) {
    var out = [];
    var className;
    var classes;
    var key;
    var attr;
    var i;
    if (!elem || !elem.tagName) {
        return '';
    }
    out.push(elem.tagName.toLowerCase());
    if (elem.id) {
        out.push("#" + elem.id);
    }
    className = elem.className;
    if (className && Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_2__["isString"])(className)) {
        classes = className.split(/\s+/);
        for (i = 0; i < classes.length; i++) {
            out.push("." + classes[i]);
        }
    }
    var attrWhitelist = ['type', 'name', 'title', 'alt'];
    for (i = 0; i < attrWhitelist.length; i++) {
        key = attrWhitelist[i];
        attr = elem.getAttribute(key);
        if (attr) {
            out.push("[" + key + "=\"" + attr + "\"]");
        }
    }
    return out.join('');
}
//# sourceMappingURL=helpers.js.map

/***/ }),

/***/ "../browser/esm/index.js":
/*!*******************************!*\
  !*** ../browser/esm/index.js ***!
  \*******************************/
/*! exports provided: Severity, Status, addGlobalEventProcessor, addBreadcrumb, captureException, captureEvent, captureMessage, configureScope, withScope, getHubFromCarrier, getCurrentHub, Hub, Scope, BrowserClient, defaultIntegrations, forceLoad, init, lastEventId, onLoad, showReportDialog, flush, close, wrap, SDK_NAME, SDK_VERSION, Integrations, Transports */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "Integrations", function() { return INTEGRATIONS; });
/* harmony import */ var tslib__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! tslib */ "../../node_modules/tslib/tslib.es6.js");
/* harmony import */ var _sentry_types__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! @sentry/types */ "../types/esm/index.js");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "Severity", function() { return _sentry_types__WEBPACK_IMPORTED_MODULE_1__["Severity"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "Status", function() { return _sentry_types__WEBPACK_IMPORTED_MODULE_1__["Status"]; });

/* harmony import */ var _sentry_core__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! @sentry/core */ "../core/esm/index.js");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "addGlobalEventProcessor", function() { return _sentry_core__WEBPACK_IMPORTED_MODULE_2__["addGlobalEventProcessor"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "addBreadcrumb", function() { return _sentry_core__WEBPACK_IMPORTED_MODULE_2__["addBreadcrumb"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "captureException", function() { return _sentry_core__WEBPACK_IMPORTED_MODULE_2__["captureException"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "captureEvent", function() { return _sentry_core__WEBPACK_IMPORTED_MODULE_2__["captureEvent"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "captureMessage", function() { return _sentry_core__WEBPACK_IMPORTED_MODULE_2__["captureMessage"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "configureScope", function() { return _sentry_core__WEBPACK_IMPORTED_MODULE_2__["configureScope"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "withScope", function() { return _sentry_core__WEBPACK_IMPORTED_MODULE_2__["withScope"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "getHubFromCarrier", function() { return _sentry_core__WEBPACK_IMPORTED_MODULE_2__["getHubFromCarrier"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "getCurrentHub", function() { return _sentry_core__WEBPACK_IMPORTED_MODULE_2__["getCurrentHub"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "Hub", function() { return _sentry_core__WEBPACK_IMPORTED_MODULE_2__["Hub"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "Scope", function() { return _sentry_core__WEBPACK_IMPORTED_MODULE_2__["Scope"]; });

/* harmony import */ var _client__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! ./client */ "../browser/esm/client.js");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "BrowserClient", function() { return _client__WEBPACK_IMPORTED_MODULE_3__["BrowserClient"]; });

/* harmony import */ var _sdk__WEBPACK_IMPORTED_MODULE_4__ = __webpack_require__(/*! ./sdk */ "../browser/esm/sdk.js");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "defaultIntegrations", function() { return _sdk__WEBPACK_IMPORTED_MODULE_4__["defaultIntegrations"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "forceLoad", function() { return _sdk__WEBPACK_IMPORTED_MODULE_4__["forceLoad"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "init", function() { return _sdk__WEBPACK_IMPORTED_MODULE_4__["init"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "lastEventId", function() { return _sdk__WEBPACK_IMPORTED_MODULE_4__["lastEventId"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "onLoad", function() { return _sdk__WEBPACK_IMPORTED_MODULE_4__["onLoad"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "showReportDialog", function() { return _sdk__WEBPACK_IMPORTED_MODULE_4__["showReportDialog"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "flush", function() { return _sdk__WEBPACK_IMPORTED_MODULE_4__["flush"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "close", function() { return _sdk__WEBPACK_IMPORTED_MODULE_4__["close"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "wrap", function() { return _sdk__WEBPACK_IMPORTED_MODULE_4__["wrap"]; });

/* harmony import */ var _version__WEBPACK_IMPORTED_MODULE_5__ = __webpack_require__(/*! ./version */ "../browser/esm/version.js");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "SDK_NAME", function() { return _version__WEBPACK_IMPORTED_MODULE_5__["SDK_NAME"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "SDK_VERSION", function() { return _version__WEBPACK_IMPORTED_MODULE_5__["SDK_VERSION"]; });

/* harmony import */ var _sentry_utils__WEBPACK_IMPORTED_MODULE_6__ = __webpack_require__(/*! @sentry/utils */ "../utils/esm/index.js");
/* harmony import */ var _integrations__WEBPACK_IMPORTED_MODULE_7__ = __webpack_require__(/*! ./integrations */ "../browser/esm/integrations/index.js");
/* harmony import */ var _transports__WEBPACK_IMPORTED_MODULE_8__ = __webpack_require__(/*! ./transports */ "../browser/esm/transports/index.js");
/* harmony reexport (module object) */ __webpack_require__.d(__webpack_exports__, "Transports", function() { return _transports__WEBPACK_IMPORTED_MODULE_8__; });










var windowIntegrations = {};
// This block is needed to add compatibility with the integrations packages when used with a CDN
// tslint:disable: no-unsafe-any
var _window = Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_6__["getGlobalObject"])();
if (_window.Sentry && _window.Sentry.Integrations) {
    windowIntegrations = _window.Sentry.Integrations;
}
// tslint:enable: no-unsafe-any
var INTEGRATIONS = Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__assign"])(Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__assign"])(Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__assign"])({}, windowIntegrations), _sentry_core__WEBPACK_IMPORTED_MODULE_2__["Integrations"]), _integrations__WEBPACK_IMPORTED_MODULE_7__);

//# sourceMappingURL=index.js.map

/***/ }),

/***/ "../browser/esm/integrations/breadcrumbs.js":
/*!**************************************************!*\
  !*** ../browser/esm/integrations/breadcrumbs.js ***!
  \**************************************************/
/*! exports provided: Breadcrumbs */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "Breadcrumbs", function() { return Breadcrumbs; });
/* harmony import */ var tslib__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! tslib */ "../../node_modules/tslib/tslib.es6.js");
/* harmony import */ var _sentry_core__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! @sentry/core */ "../core/esm/index.js");
/* harmony import */ var _sentry_types__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! @sentry/types */ "../types/esm/index.js");
/* harmony import */ var _sentry_utils__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! @sentry/utils */ "../utils/esm/index.js");
/* harmony import */ var _helpers__WEBPACK_IMPORTED_MODULE_4__ = __webpack_require__(/*! ../helpers */ "../browser/esm/helpers.js");





var global = Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_3__["getGlobalObject"])();
var lastHref;
/** Default Breadcrumbs instrumentations */
var Breadcrumbs = /** @class */function () {
    /**
     * @inheritDoc
     */
    function Breadcrumbs(options) {
        /**
         * @inheritDoc
         */
        this.name = Breadcrumbs.id;
        this._options = Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__assign"])({ console: true, dom: true, fetch: true, history: true, sentry: true, xhr: true }, options);
    }
    /** JSDoc */
    Breadcrumbs.prototype._instrumentConsole = function () {
        if (!('console' in global)) {
            return;
        }
        ['debug', 'info', 'warn', 'error', 'log', 'assert'].forEach(function (level) {
            if (!(level in global.console)) {
                return;
            }
            Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_3__["fill"])(global.console, level, function (originalConsoleLevel) {
                return function () {
                    var args = [];
                    for (var _i = 0; _i < arguments.length; _i++) {
                        args[_i] = arguments[_i];
                    }
                    var breadcrumbData = {
                        category: 'console',
                        data: {
                            extra: {
                                arguments: Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_3__["normalize"])(args, 3)
                            },
                            logger: 'console'
                        },
                        level: _sentry_types__WEBPACK_IMPORTED_MODULE_2__["Severity"].fromString(level),
                        message: Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_3__["safeJoin"])(args, ' ')
                    };
                    if (level === 'assert') {
                        if (args[0] === false) {
                            breadcrumbData.message = "Assertion failed: " + (Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_3__["safeJoin"])(args.slice(1), ' ') || 'console.assert');
                            breadcrumbData.data.extra.arguments = Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_3__["normalize"])(args.slice(1), 3);
                        }
                    }
                    Breadcrumbs.addBreadcrumb(breadcrumbData, {
                        input: args,
                        level: level
                    });
                    // this fails for some browsers. :(
                    if (originalConsoleLevel) {
                        Function.prototype.apply.call(originalConsoleLevel, global.console, args);
                    }
                };
            });
        });
    };
    /** JSDoc */
    Breadcrumbs.prototype._instrumentDOM = function () {
        if (!('document' in global)) {
            return;
        }
        // Capture breadcrumbs from any click that is unhandled / bubbled up all the way
        // to the document. Do this before we instrument addEventListener.
        global.document.addEventListener('click', Object(_helpers__WEBPACK_IMPORTED_MODULE_4__["breadcrumbEventHandler"])('click'), false);
        global.document.addEventListener('keypress', Object(_helpers__WEBPACK_IMPORTED_MODULE_4__["keypressEventHandler"])(), false);
        // After hooking into document bubbled up click and keypresses events, we also hook into user handled click & keypresses.
        ['EventTarget', 'Node'].forEach(function (target) {
            var proto = global[target] && global[target].prototype;
            if (!proto || !proto.hasOwnProperty || !proto.hasOwnProperty('addEventListener')) {
                return;
            }
            Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_3__["fill"])(proto, 'addEventListener', function (original) {
                return function (eventName, fn, options) {
                    if (fn && fn.handleEvent) {
                        if (eventName === 'click') {
                            Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_3__["fill"])(fn, 'handleEvent', function (innerOriginal) {
                                return function (event) {
                                    Object(_helpers__WEBPACK_IMPORTED_MODULE_4__["breadcrumbEventHandler"])('click')(event);
                                    return innerOriginal.call(this, event);
                                };
                            });
                        }
                        if (eventName === 'keypress') {
                            Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_3__["fill"])(fn, 'handleEvent', Object(_helpers__WEBPACK_IMPORTED_MODULE_4__["keypressEventHandler"])());
                        }
                    } else {
                        if (eventName === 'click') {
                            Object(_helpers__WEBPACK_IMPORTED_MODULE_4__["breadcrumbEventHandler"])('click', true)(this);
                        }
                        if (eventName === 'keypress') {
                            Object(_helpers__WEBPACK_IMPORTED_MODULE_4__["keypressEventHandler"])()(this);
                        }
                    }
                    return original.call(this, eventName, fn, options);
                };
            });
            Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_3__["fill"])(proto, 'removeEventListener', function (original) {
                return function (eventName, fn, options) {
                    var callback = fn;
                    try {
                        callback = callback && (callback.__sentry_wrapped__ || callback);
                    } catch (e) {
                        // ignore, accessing __sentry_wrapped__ will throw in some Selenium environments
                    }
                    return original.call(this, eventName, callback, options);
                };
            });
        });
    };
    /** JSDoc */
    Breadcrumbs.prototype._instrumentFetch = function () {
        if (!Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_3__["supportsNativeFetch"])()) {
            return;
        }
        Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_3__["fill"])(global, 'fetch', function (originalFetch) {
            return function () {
                var args = [];
                for (var _i = 0; _i < arguments.length; _i++) {
                    args[_i] = arguments[_i];
                }
                var fetchInput = args[0];
                var method = 'GET';
                var url;
                if (typeof fetchInput === 'string') {
                    url = fetchInput;
                } else if ('Request' in global && fetchInput instanceof Request) {
                    url = fetchInput.url;
                    if (fetchInput.method) {
                        method = fetchInput.method;
                    }
                } else {
                    url = String(fetchInput);
                }
                if (args[1] && args[1].method) {
                    method = args[1].method;
                }
                var client = Object(_sentry_core__WEBPACK_IMPORTED_MODULE_1__["getCurrentHub"])().getClient();
                var dsn = client && client.getDsn();
                if (dsn) {
                    var filterUrl = new _sentry_core__WEBPACK_IMPORTED_MODULE_1__["API"](dsn).getStoreEndpoint();
                    // if Sentry key appears in URL, don't capture it as a request
                    // but rather as our own 'sentry' type breadcrumb
                    if (filterUrl && url.includes(filterUrl)) {
                        if (method === 'POST' && args[1] && args[1].body) {
                            addSentryBreadcrumb(args[1].body);
                        }
                        return originalFetch.apply(global, args);
                    }
                }
                var fetchData = {
                    method: method,
                    url: url
                };
                return originalFetch.apply(global, args).then(function (response) {
                    fetchData.status_code = response.status;
                    Breadcrumbs.addBreadcrumb({
                        category: 'fetch',
                        data: fetchData,
                        type: 'http'
                    }, {
                        input: args,
                        response: response
                    });
                    return response;
                }).catch(function (error) {
                    Breadcrumbs.addBreadcrumb({
                        category: 'fetch',
                        data: fetchData,
                        level: _sentry_types__WEBPACK_IMPORTED_MODULE_2__["Severity"].Error,
                        type: 'http'
                    }, {
                        error: error,
                        input: args
                    });
                    throw error;
                });
            };
        });
    };
    /** JSDoc */
    Breadcrumbs.prototype._instrumentHistory = function () {
        var _this = this;
        if (!Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_3__["supportsHistory"])()) {
            return;
        }
        var captureUrlChange = function (from, to) {
            var parsedLoc = Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_3__["parseUrl"])(global.location.href);
            var parsedTo = Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_3__["parseUrl"])(to);
            var parsedFrom = Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_3__["parseUrl"])(from);
            // Initial pushState doesn't provide `from` information
            if (!parsedFrom.path) {
                parsedFrom = parsedLoc;
            }
            // because onpopstate only tells you the "new" (to) value of location.href, and
            // not the previous (from) value, we need to track the value of the current URL
            // state ourselves
            lastHref = to;
            // Use only the path component of the URL if the URL matches the current
            // document (almost all the time when using pushState)
            if (parsedLoc.protocol === parsedTo.protocol && parsedLoc.host === parsedTo.host) {
                // tslint:disable-next-line:no-parameter-reassignment
                to = parsedTo.relative;
            }
            if (parsedLoc.protocol === parsedFrom.protocol && parsedLoc.host === parsedFrom.host) {
                // tslint:disable-next-line:no-parameter-reassignment
                from = parsedFrom.relative;
            }
            Breadcrumbs.addBreadcrumb({
                category: 'navigation',
                data: {
                    from: from,
                    to: to
                }
            });
        };
        // record navigation (URL) changes
        var oldOnPopState = global.onpopstate;
        global.onpopstate = function () {
            var args = [];
            for (var _i = 0; _i < arguments.length; _i++) {
                args[_i] = arguments[_i];
            }
            var currentHref = global.location.href;
            captureUrlChange(lastHref, currentHref);
            if (oldOnPopState) {
                return oldOnPopState.apply(_this, args);
            }
        };
        /**
         * @hidden
         */
        function historyReplacementFunction(originalHistoryFunction) {
            // note history.pushState.length is 0; intentionally not declaring
            // params to preserve 0 arity
            return function () {
                var args = [];
                for (var _i = 0; _i < arguments.length; _i++) {
                    args[_i] = arguments[_i];
                }
                var url = args.length > 2 ? args[2] : undefined;
                // url argument is optional
                if (url) {
                    // coerce to string (this is what pushState does)
                    captureUrlChange(lastHref, String(url));
                }
                return originalHistoryFunction.apply(this, args);
            };
        }
        Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_3__["fill"])(global.history, 'pushState', historyReplacementFunction);
        Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_3__["fill"])(global.history, 'replaceState', historyReplacementFunction);
    };
    /** JSDoc */
    Breadcrumbs.prototype._instrumentXHR = function () {
        if (!('XMLHttpRequest' in global)) {
            return;
        }
        /**
         * @hidden
         */
        function wrapProp(prop, xhr) {
            // TODO: Fix XHR types
            if (prop in xhr && typeof xhr[prop] === 'function') {
                Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_3__["fill"])(xhr, prop, function (original) {
                    return Object(_helpers__WEBPACK_IMPORTED_MODULE_4__["wrap"])(original, {
                        mechanism: {
                            data: {
                                function: prop,
                                handler: original && original.name || '<anonymous>'
                            },
                            handled: true,
                            type: 'instrument'
                        }
                    });
                });
            }
        }
        var xhrproto = XMLHttpRequest.prototype;
        Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_3__["fill"])(xhrproto, 'open', function (originalOpen) {
            return function () {
                var args = [];
                for (var _i = 0; _i < arguments.length; _i++) {
                    args[_i] = arguments[_i];
                }
                var url = args[1];
                this.__sentry_xhr__ = {
                    method: args[0],
                    url: args[1]
                };
                var client = Object(_sentry_core__WEBPACK_IMPORTED_MODULE_1__["getCurrentHub"])().getClient();
                var dsn = client && client.getDsn();
                if (dsn) {
                    var filterUrl = new _sentry_core__WEBPACK_IMPORTED_MODULE_1__["API"](dsn).getStoreEndpoint();
                    // if Sentry key appears in URL, don't capture it as a request
                    // but rather as our own 'sentry' type breadcrumb
                    if (Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_3__["isString"])(url) && filterUrl && url.includes(filterUrl)) {
                        this.__sentry_own_request__ = true;
                    }
                }
                return originalOpen.apply(this, args);
            };
        });
        Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_3__["fill"])(xhrproto, 'send', function (originalSend) {
            return function () {
                var args = [];
                for (var _i = 0; _i < arguments.length; _i++) {
                    args[_i] = arguments[_i];
                }
                var xhr = this; // tslint:disable-line:no-this-assignment
                if (xhr.__sentry_own_request__) {
                    addSentryBreadcrumb(args[0]);
                }
                /**
                 * @hidden
                 */
                function onreadystatechangeHandler() {
                    if (xhr.readyState === 4) {
                        if (xhr.__sentry_own_request__) {
                            return;
                        }
                        try {
                            // touching statusCode in some platforms throws
                            // an exception
                            if (xhr.__sentry_xhr__) {
                                xhr.__sentry_xhr__.status_code = xhr.status;
                            }
                        } catch (e) {
                            /* do nothing */
                        }
                        Breadcrumbs.addBreadcrumb({
                            category: 'xhr',
                            data: xhr.__sentry_xhr__,
                            type: 'http'
                        }, {
                            xhr: xhr
                        });
                    }
                }
                ['onload', 'onerror', 'onprogress'].forEach(function (prop) {
                    wrapProp(prop, xhr);
                });
                if ('onreadystatechange' in xhr && typeof xhr.onreadystatechange === 'function') {
                    Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_3__["fill"])(xhr, 'onreadystatechange', function (original) {
                        return Object(_helpers__WEBPACK_IMPORTED_MODULE_4__["wrap"])(original, {
                            mechanism: {
                                data: {
                                    function: 'onreadystatechange',
                                    handler: original && original.name || '<anonymous>'
                                },
                                handled: true,
                                type: 'instrument'
                            }
                        }, onreadystatechangeHandler);
                    });
                } else {
                    // if onreadystatechange wasn't actually set by the page on this xhr, we
                    // are free to set our own and capture the breadcrumb
                    xhr.onreadystatechange = onreadystatechangeHandler;
                }
                return originalSend.apply(this, args);
            };
        });
    };
    /**
     * Helper that checks if integration is enabled on the client.
     * @param breadcrumb Breadcrumb
     * @param hint BreadcrumbHint
     */
    Breadcrumbs.addBreadcrumb = function (breadcrumb, hint) {
        if (Object(_sentry_core__WEBPACK_IMPORTED_MODULE_1__["getCurrentHub"])().getIntegration(Breadcrumbs)) {
            Object(_sentry_core__WEBPACK_IMPORTED_MODULE_1__["getCurrentHub"])().addBreadcrumb(breadcrumb, hint);
        }
    };
    /**
     * Instrument browser built-ins w/ breadcrumb capturing
     *  - Console API
     *  - DOM API (click/typing)
     *  - XMLHttpRequest API
     *  - Fetch API
     *  - History API
     */
    Breadcrumbs.prototype.setupOnce = function () {
        if (this._options.console) {
            this._instrumentConsole();
        }
        if (this._options.dom) {
            this._instrumentDOM();
        }
        if (this._options.xhr) {
            this._instrumentXHR();
        }
        if (this._options.fetch) {
            this._instrumentFetch();
        }
        if (this._options.history) {
            this._instrumentHistory();
        }
    };
    /**
     * @inheritDoc
     */
    Breadcrumbs.id = 'Breadcrumbs';
    return Breadcrumbs;
}();

/** JSDoc */
function addSentryBreadcrumb(serializedData) {
    // There's always something that can go wrong with deserialization...
    try {
        var event_1 = JSON.parse(serializedData);
        Breadcrumbs.addBreadcrumb({
            category: 'sentry',
            event_id: event_1.event_id,
            level: event_1.level || _sentry_types__WEBPACK_IMPORTED_MODULE_2__["Severity"].fromString('error'),
            message: Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_3__["getEventDescription"])(event_1)
        }, {
            event: event_1
        });
    } catch (_oO) {
        _sentry_utils__WEBPACK_IMPORTED_MODULE_3__["logger"].error('Error while adding sentry type breadcrumb');
    }
}
//# sourceMappingURL=breadcrumbs.js.map

/***/ }),

/***/ "../browser/esm/integrations/globalhandlers.js":
/*!*****************************************************!*\
  !*** ../browser/esm/integrations/globalhandlers.js ***!
  \*****************************************************/
/*! exports provided: GlobalHandlers */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "GlobalHandlers", function() { return GlobalHandlers; });
/* harmony import */ var tslib__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! tslib */ "../../node_modules/tslib/tslib.es6.js");
/* harmony import */ var _sentry_core__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! @sentry/core */ "../core/esm/index.js");
/* harmony import */ var _sentry_utils__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! @sentry/utils */ "../utils/esm/index.js");
/* harmony import */ var _helpers__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! ../helpers */ "../browser/esm/helpers.js");
/* harmony import */ var _parsers__WEBPACK_IMPORTED_MODULE_4__ = __webpack_require__(/*! ../parsers */ "../browser/esm/parsers.js");
/* harmony import */ var _tracekit__WEBPACK_IMPORTED_MODULE_5__ = __webpack_require__(/*! ../tracekit */ "../browser/esm/tracekit.js");






/** Global handlers */
var GlobalHandlers = /** @class */function () {
    /** JSDoc */
    function GlobalHandlers(options) {
        /**
         * @inheritDoc
         */
        this.name = GlobalHandlers.id;
        this._options = Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__assign"])({ onerror: true, onunhandledrejection: true }, options);
    }
    /**
     * @inheritDoc
     */
    GlobalHandlers.prototype.setupOnce = function () {
        Error.stackTraceLimit = 50;
        Object(_tracekit__WEBPACK_IMPORTED_MODULE_5__["_subscribe"])(function (stack, _, error) {
            // TODO: use stack.context to get a valuable information from TraceKit, eg.
            // [
            //   0: "  })"
            //   1: ""
            //   2: "  function foo () {"
            //   3: "    Sentry.captureException('some error')"
            //   4: "    Sentry.captureMessage('some message')"
            //   5: "    throw 'foo'"
            //   6: "  }"
            //   7: ""
            //   8: "  function bar () {"
            //   9: "    foo();"
            //   10: "  }"
            // ]
            if (Object(_helpers__WEBPACK_IMPORTED_MODULE_3__["shouldIgnoreOnError"])()) {
                return;
            }
            var self = Object(_sentry_core__WEBPACK_IMPORTED_MODULE_1__["getCurrentHub"])().getIntegration(GlobalHandlers);
            if (self) {
                Object(_sentry_core__WEBPACK_IMPORTED_MODULE_1__["getCurrentHub"])().captureEvent(self._eventFromGlobalHandler(stack), {
                    data: { stack: stack },
                    originalException: error
                });
            }
        });
        if (this._options.onerror) {
            _sentry_utils__WEBPACK_IMPORTED_MODULE_2__["logger"].log('Global Handler attached: onerror');
            Object(_tracekit__WEBPACK_IMPORTED_MODULE_5__["_installGlobalHandler"])();
        }
        if (this._options.onunhandledrejection) {
            _sentry_utils__WEBPACK_IMPORTED_MODULE_2__["logger"].log('Global Handler attached: onunhandledrejection');
            Object(_tracekit__WEBPACK_IMPORTED_MODULE_5__["_installGlobalUnhandledRejectionHandler"])();
        }
    };
    /**
     * This function creates an Event from an TraceKitStackTrace.
     *
     * @param stacktrace TraceKitStackTrace to be converted to an Event.
     */
    GlobalHandlers.prototype._eventFromGlobalHandler = function (stacktrace) {
        if (!Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_2__["isString"])(stacktrace.message) && stacktrace.mechanism !== 'onunhandledrejection') {
            // There are cases where stacktrace.message is an Event object
            // https://github.com/getsentry/sentry-javascript/issues/1949
            // In this specific case we try to extract stacktrace.message.error.message
            var message = stacktrace.message;
            stacktrace.message = message.error && Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_2__["isString"])(message.error.message) ? message.error.message : 'No error message';
        }
        var event = Object(_parsers__WEBPACK_IMPORTED_MODULE_4__["eventFromStacktrace"])(stacktrace);
        var data = {
            mode: stacktrace.mode
        };
        if (stacktrace.message) {
            data.message = stacktrace.message;
        }
        if (stacktrace.name) {
            data.name = stacktrace.name;
        }
        var client = Object(_sentry_core__WEBPACK_IMPORTED_MODULE_1__["getCurrentHub"])().getClient();
        var maxValueLength = client && client.getOptions().maxValueLength || 250;
        var fallbackValue = stacktrace.original ? Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_2__["truncate"])(JSON.stringify(Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_2__["normalize"])(stacktrace.original)), maxValueLength) : '';
        var fallbackType = stacktrace.mechanism === 'onunhandledrejection' ? 'UnhandledRejection' : 'Error';
        // This makes sure we have type/value in every exception
        Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_2__["addExceptionTypeValue"])(event, fallbackValue, fallbackType, {
            data: data,
            handled: false,
            type: stacktrace.mechanism
        });
        return event;
    };
    /**
     * @inheritDoc
     */
    GlobalHandlers.id = 'GlobalHandlers';
    return GlobalHandlers;
}();

//# sourceMappingURL=globalhandlers.js.map

/***/ }),

/***/ "../browser/esm/integrations/index.js":
/*!********************************************!*\
  !*** ../browser/esm/integrations/index.js ***!
  \********************************************/
/*! exports provided: GlobalHandlers, TryCatch, Breadcrumbs, LinkedErrors, UserAgent */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var _globalhandlers__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./globalhandlers */ "../browser/esm/integrations/globalhandlers.js");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "GlobalHandlers", function() { return _globalhandlers__WEBPACK_IMPORTED_MODULE_0__["GlobalHandlers"]; });

/* harmony import */ var _trycatch__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./trycatch */ "../browser/esm/integrations/trycatch.js");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "TryCatch", function() { return _trycatch__WEBPACK_IMPORTED_MODULE_1__["TryCatch"]; });

/* harmony import */ var _breadcrumbs__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ./breadcrumbs */ "../browser/esm/integrations/breadcrumbs.js");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "Breadcrumbs", function() { return _breadcrumbs__WEBPACK_IMPORTED_MODULE_2__["Breadcrumbs"]; });

/* harmony import */ var _linkederrors__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! ./linkederrors */ "../browser/esm/integrations/linkederrors.js");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "LinkedErrors", function() { return _linkederrors__WEBPACK_IMPORTED_MODULE_3__["LinkedErrors"]; });

/* harmony import */ var _useragent__WEBPACK_IMPORTED_MODULE_4__ = __webpack_require__(/*! ./useragent */ "../browser/esm/integrations/useragent.js");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "UserAgent", function() { return _useragent__WEBPACK_IMPORTED_MODULE_4__["UserAgent"]; });






//# sourceMappingURL=index.js.map

/***/ }),

/***/ "../browser/esm/integrations/linkederrors.js":
/*!***************************************************!*\
  !*** ../browser/esm/integrations/linkederrors.js ***!
  \***************************************************/
/*! exports provided: LinkedErrors */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "LinkedErrors", function() { return LinkedErrors; });
/* harmony import */ var tslib__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! tslib */ "../../node_modules/tslib/tslib.es6.js");
/* harmony import */ var _sentry_core__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! @sentry/core */ "../core/esm/index.js");
/* harmony import */ var _parsers__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ../parsers */ "../browser/esm/parsers.js");
/* harmony import */ var _tracekit__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! ../tracekit */ "../browser/esm/tracekit.js");




var DEFAULT_KEY = 'cause';
var DEFAULT_LIMIT = 5;
/** Adds SDK info to an event. */
var LinkedErrors = /** @class */function () {
    /**
     * @inheritDoc
     */
    function LinkedErrors(options) {
        if (options === void 0) {
            options = {};
        }
        /**
         * @inheritDoc
         */
        this.name = LinkedErrors.id;
        this._key = options.key || DEFAULT_KEY;
        this._limit = options.limit || DEFAULT_LIMIT;
    }
    /**
     * @inheritDoc
     */
    LinkedErrors.prototype.setupOnce = function () {
        Object(_sentry_core__WEBPACK_IMPORTED_MODULE_1__["addGlobalEventProcessor"])(function (event, hint) {
            var self = Object(_sentry_core__WEBPACK_IMPORTED_MODULE_1__["getCurrentHub"])().getIntegration(LinkedErrors);
            if (self) {
                return self._handler(event, hint);
            }
            return event;
        });
    };
    /**
     * @inheritDoc
     */
    LinkedErrors.prototype._handler = function (event, hint) {
        if (!event.exception || !event.exception.values || !hint || !(hint.originalException instanceof Error)) {
            return event;
        }
        var linkedErrors = this._walkErrorTree(hint.originalException, this._key);
        event.exception.values = Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__spread"])(linkedErrors, event.exception.values);
        return event;
    };
    /**
     * @inheritDoc
     */
    LinkedErrors.prototype._walkErrorTree = function (error, key, stack) {
        if (stack === void 0) {
            stack = [];
        }
        if (!(error[key] instanceof Error) || stack.length + 1 >= this._limit) {
            return stack;
        }
        var stacktrace = Object(_tracekit__WEBPACK_IMPORTED_MODULE_3__["_computeStackTrace"])(error[key]);
        var exception = Object(_parsers__WEBPACK_IMPORTED_MODULE_2__["exceptionFromStacktrace"])(stacktrace);
        return this._walkErrorTree(error[key], key, Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__spread"])([exception], stack));
    };
    /**
     * @inheritDoc
     */
    LinkedErrors.id = 'LinkedErrors';
    return LinkedErrors;
}();

//# sourceMappingURL=linkederrors.js.map

/***/ }),

/***/ "../browser/esm/integrations/trycatch.js":
/*!***********************************************!*\
  !*** ../browser/esm/integrations/trycatch.js ***!
  \***********************************************/
/*! exports provided: TryCatch */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "TryCatch", function() { return TryCatch; });
/* harmony import */ var _sentry_utils__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! @sentry/utils */ "../utils/esm/index.js");
/* harmony import */ var _helpers__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ../helpers */ "../browser/esm/helpers.js");


/** Wrap timer functions and event targets to catch errors and provide better meta data */
var TryCatch = /** @class */function () {
    function TryCatch() {
        /** JSDoc */
        this._ignoreOnError = 0;
        /**
         * @inheritDoc
         */
        this.name = TryCatch.id;
    }
    /** JSDoc */
    TryCatch.prototype._wrapTimeFunction = function (original) {
        return function () {
            var args = [];
            for (var _i = 0; _i < arguments.length; _i++) {
                args[_i] = arguments[_i];
            }
            var originalCallback = args[0];
            args[0] = Object(_helpers__WEBPACK_IMPORTED_MODULE_1__["wrap"])(originalCallback, {
                mechanism: {
                    data: { function: getFunctionName(original) },
                    handled: true,
                    type: 'instrument'
                }
            });
            return original.apply(this, args);
        };
    };
    /** JSDoc */
    TryCatch.prototype._wrapRAF = function (original) {
        return function (callback) {
            return original(Object(_helpers__WEBPACK_IMPORTED_MODULE_1__["wrap"])(callback, {
                mechanism: {
                    data: {
                        function: 'requestAnimationFrame',
                        handler: getFunctionName(original)
                    },
                    handled: true,
                    type: 'instrument'
                }
            }));
        };
    };
    /** JSDoc */
    TryCatch.prototype._wrapEventTarget = function (target) {
        var global = Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_0__["getGlobalObject"])();
        var proto = global[target] && global[target].prototype;
        if (!proto || !proto.hasOwnProperty || !proto.hasOwnProperty('addEventListener')) {
            return;
        }
        Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_0__["fill"])(proto, 'addEventListener', function (original) {
            return function (eventName, fn, options) {
                try {
                    fn.handleEvent = Object(_helpers__WEBPACK_IMPORTED_MODULE_1__["wrap"])(fn.handleEvent.bind(fn), {
                        mechanism: {
                            data: {
                                function: 'handleEvent',
                                handler: getFunctionName(fn),
                                target: target
                            },
                            handled: true,
                            type: 'instrument'
                        }
                    });
                } catch (err) {
                    // can sometimes get 'Permission denied to access property "handle Event'
                }
                return original.call(this, eventName, Object(_helpers__WEBPACK_IMPORTED_MODULE_1__["wrap"])(fn, {
                    mechanism: {
                        data: {
                            function: 'addEventListener',
                            handler: getFunctionName(fn),
                            target: target
                        },
                        handled: true,
                        type: 'instrument'
                    }
                }), options);
            };
        });
        Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_0__["fill"])(proto, 'removeEventListener', function (original) {
            return function (eventName, fn, options) {
                var callback = fn;
                try {
                    callback = callback && (callback.__sentry_wrapped__ || callback);
                } catch (e) {
                    // ignore, accessing __sentry_wrapped__ will throw in some Selenium environments
                }
                return original.call(this, eventName, callback, options);
            };
        });
    };
    /**
     * Wrap timer functions and event targets to catch errors
     * and provide better metadata.
     */
    TryCatch.prototype.setupOnce = function () {
        this._ignoreOnError = this._ignoreOnError;
        var global = Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_0__["getGlobalObject"])();
        Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_0__["fill"])(global, 'setTimeout', this._wrapTimeFunction.bind(this));
        Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_0__["fill"])(global, 'setInterval', this._wrapTimeFunction.bind(this));
        Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_0__["fill"])(global, 'requestAnimationFrame', this._wrapRAF.bind(this));
        ['EventTarget', 'Window', 'Node', 'ApplicationCache', 'AudioTrackList', 'ChannelMergerNode', 'CryptoOperation', 'EventSource', 'FileReader', 'HTMLUnknownElement', 'IDBDatabase', 'IDBRequest', 'IDBTransaction', 'KeyOperation', 'MediaController', 'MessagePort', 'ModalWindow', 'Notification', 'SVGElementInstance', 'Screen', 'TextTrack', 'TextTrackCue', 'TextTrackList', 'WebSocket', 'WebSocketWorker', 'Worker', 'XMLHttpRequest', 'XMLHttpRequestEventTarget', 'XMLHttpRequestUpload'].forEach(this._wrapEventTarget.bind(this));
    };
    /**
     * @inheritDoc
     */
    TryCatch.id = 'TryCatch';
    return TryCatch;
}();

/**
 * Safely extract function name from itself
 */
function getFunctionName(fn) {
    try {
        return fn && fn.name || '<anonymous>';
    } catch (e) {
        // Just accessing custom props in some Selenium environments
        // can cause a "Permission denied" exception (see raven-js#495).
        return '<anonymous>';
    }
}
//# sourceMappingURL=trycatch.js.map

/***/ }),

/***/ "../browser/esm/integrations/useragent.js":
/*!************************************************!*\
  !*** ../browser/esm/integrations/useragent.js ***!
  \************************************************/
/*! exports provided: UserAgent */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "UserAgent", function() { return UserAgent; });
/* harmony import */ var tslib__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! tslib */ "../../node_modules/tslib/tslib.es6.js");
/* harmony import */ var _sentry_core__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! @sentry/core */ "../core/esm/index.js");
/* harmony import */ var _sentry_utils__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! @sentry/utils */ "../utils/esm/index.js");



var global = Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_2__["getGlobalObject"])();
/** UserAgent */
var UserAgent = /** @class */function () {
    function UserAgent() {
        /**
         * @inheritDoc
         */
        this.name = UserAgent.id;
    }
    /**
     * @inheritDoc
     */
    UserAgent.prototype.setupOnce = function () {
        Object(_sentry_core__WEBPACK_IMPORTED_MODULE_1__["addGlobalEventProcessor"])(function (event) {
            if (Object(_sentry_core__WEBPACK_IMPORTED_MODULE_1__["getCurrentHub"])().getIntegration(UserAgent)) {
                if (!global.navigator || !global.location) {
                    return event;
                }
                // HTTP Interface: https://docs.sentry.io/clientdev/interfaces/http/?platform=javascript
                var request = event.request || {};
                request.url = request.url || global.location.href;
                request.headers = request.headers || {};
                request.headers['User-Agent'] = global.navigator.userAgent;
                return Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__assign"])(Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__assign"])({}, event), { request: request });
            }
            return event;
        });
    };
    /**
     * @inheritDoc
     */
    UserAgent.id = 'UserAgent';
    return UserAgent;
}();

//# sourceMappingURL=useragent.js.map

/***/ }),

/***/ "../browser/esm/parsers.js":
/*!*********************************!*\
  !*** ../browser/esm/parsers.js ***!
  \*********************************/
/*! exports provided: exceptionFromStacktrace, eventFromPlainObject, eventFromStacktrace, prepareFramesForEvent */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "exceptionFromStacktrace", function() { return exceptionFromStacktrace; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "eventFromPlainObject", function() { return eventFromPlainObject; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "eventFromStacktrace", function() { return eventFromStacktrace; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "prepareFramesForEvent", function() { return prepareFramesForEvent; });
/* harmony import */ var _sentry_utils__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! @sentry/utils */ "../utils/esm/index.js");
/* harmony import */ var _tracekit__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./tracekit */ "../browser/esm/tracekit.js");


var STACKTRACE_LIMIT = 50;
/**
 * This function creates an exception from an TraceKitStackTrace
 * @param stacktrace TraceKitStackTrace that will be converted to an exception
 * @hidden
 */
function exceptionFromStacktrace(stacktrace) {
    var frames = prepareFramesForEvent(stacktrace.stack);
    var exception = {
        type: stacktrace.name,
        value: stacktrace.message
    };
    if (frames && frames.length) {
        exception.stacktrace = { frames: frames };
    }
    // tslint:disable-next-line:strict-type-predicates
    if (exception.type === undefined && exception.value === '') {
        exception.value = 'Unrecoverable error caught';
    }
    return exception;
}
/**
 * @hidden
 */
function eventFromPlainObject(exception, syntheticException) {
    var exceptionKeys = Object.keys(exception).sort();
    var event = {
        extra: {
            __serialized__: Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_0__["normalizeToSize"])(exception)
        },
        message: "Non-Error exception captured with keys: " + Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_0__["keysToEventMessage"])(exceptionKeys)
    };
    if (syntheticException) {
        var stacktrace = Object(_tracekit__WEBPACK_IMPORTED_MODULE_1__["_computeStackTrace"])(syntheticException);
        var frames_1 = prepareFramesForEvent(stacktrace.stack);
        event.stacktrace = {
            frames: frames_1
        };
    }
    return event;
}
/**
 * @hidden
 */
function eventFromStacktrace(stacktrace) {
    var exception = exceptionFromStacktrace(stacktrace);
    return {
        exception: {
            values: [exception]
        }
    };
}
/**
 * @hidden
 */
function prepareFramesForEvent(stack) {
    if (!stack || !stack.length) {
        return [];
    }
    var localStack = stack;
    var firstFrameFunction = localStack[0].func || '';
    var lastFrameFunction = localStack[localStack.length - 1].func || '';
    // If stack starts with one of our API calls, remove it (starts, meaning it's the top of the stack - aka last call)
    if (firstFrameFunction.includes('captureMessage') || firstFrameFunction.includes('captureException')) {
        localStack = localStack.slice(1);
    }
    // If stack ends with one of our internal API calls, remove it (ends, meaning it's the bottom of the stack - aka top-most call)
    if (lastFrameFunction.includes('sentryWrapped')) {
        localStack = localStack.slice(0, -1);
    }
    // The frame where the crash happened, should be the last entry in the array
    return localStack.map(function (frame) {
        return {
            colno: frame.column,
            filename: frame.url || localStack[0].url,
            function: frame.func || '?',
            in_app: true,
            lineno: frame.line
        };
    }).slice(0, STACKTRACE_LIMIT).reverse();
}
//# sourceMappingURL=parsers.js.map

/***/ }),

/***/ "../browser/esm/sdk.js":
/*!*****************************!*\
  !*** ../browser/esm/sdk.js ***!
  \*****************************/
/*! exports provided: defaultIntegrations, init, showReportDialog, lastEventId, forceLoad, onLoad, flush, close, wrap */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "defaultIntegrations", function() { return defaultIntegrations; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "init", function() { return init; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "showReportDialog", function() { return showReportDialog; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "lastEventId", function() { return lastEventId; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "forceLoad", function() { return forceLoad; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "onLoad", function() { return onLoad; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "flush", function() { return flush; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "close", function() { return close; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "wrap", function() { return wrap; });
/* harmony import */ var _sentry_core__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! @sentry/core */ "../core/esm/index.js");
/* harmony import */ var _client__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./client */ "../browser/esm/client.js");
/* harmony import */ var _helpers__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ./helpers */ "../browser/esm/helpers.js");
/* harmony import */ var _integrations__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! ./integrations */ "../browser/esm/integrations/index.js");




var defaultIntegrations = [new _sentry_core__WEBPACK_IMPORTED_MODULE_0__["Integrations"].InboundFilters(), new _sentry_core__WEBPACK_IMPORTED_MODULE_0__["Integrations"].FunctionToString(), new _integrations__WEBPACK_IMPORTED_MODULE_3__["TryCatch"](), new _integrations__WEBPACK_IMPORTED_MODULE_3__["Breadcrumbs"](), new _integrations__WEBPACK_IMPORTED_MODULE_3__["GlobalHandlers"](), new _integrations__WEBPACK_IMPORTED_MODULE_3__["LinkedErrors"](), new _integrations__WEBPACK_IMPORTED_MODULE_3__["UserAgent"]()];
/**
 * The Sentry Browser SDK Client.
 *
 * To use this SDK, call the {@link init} function as early as possible when
 * loading the web page. To set context information or send manual events, use
 * the provided methods.
 *
 * @example
 *
 * ```
 *
 * import { init } from '@sentry/browser';
 *
 * init({
 *   dsn: '__DSN__',
 *   // ...
 * });
 * ```
 *
 * @example
 * ```
 *
 * import { configureScope } from '@sentry/browser';
 * configureScope((scope: Scope) => {
 *   scope.setExtra({ battery: 0.7 });
 *   scope.setTag({ user_mode: 'admin' });
 *   scope.setUser({ id: '4711' });
 * });
 * ```
 *
 * @example
 * ```
 *
 * import { addBreadcrumb } from '@sentry/browser';
 * addBreadcrumb({
 *   message: 'My Breadcrumb',
 *   // ...
 * });
 * ```
 *
 * @example
 *
 * ```
 *
 * import * as Sentry from '@sentry/browser';
 * Sentry.captureMessage('Hello, world!');
 * Sentry.captureException(new Error('Good bye'));
 * Sentry.captureEvent({
 *   message: 'Manual',
 *   stacktrace: [
 *     // ...
 *   ],
 * });
 * ```
 *
 * @see {@link BrowserOptions} for documentation on configuration options.
 */
function init(options) {
    if (options === void 0) {
        options = {};
    }
    if (options.defaultIntegrations === undefined) {
        options.defaultIntegrations = defaultIntegrations;
    }
    Object(_sentry_core__WEBPACK_IMPORTED_MODULE_0__["initAndBind"])(_client__WEBPACK_IMPORTED_MODULE_1__["BrowserClient"], options);
}
/**
 * Present the user with a report dialog.
 *
 * @param options Everything is optional, we try to fetch all info need from the global scope.
 */
function showReportDialog(options) {
    if (options === void 0) {
        options = {};
    }
    if (!options.eventId) {
        options.eventId = Object(_sentry_core__WEBPACK_IMPORTED_MODULE_0__["getCurrentHub"])().lastEventId();
    }
    var client = Object(_sentry_core__WEBPACK_IMPORTED_MODULE_0__["getCurrentHub"])().getClient();
    if (client) {
        client.showReportDialog(options);
    }
}
/**
 * This is the getter for lastEventId.
 *
 * @returns The last event id of a captured event.
 */
function lastEventId() {
    return Object(_sentry_core__WEBPACK_IMPORTED_MODULE_0__["getCurrentHub"])().lastEventId();
}
/**
 * This function is here to be API compatible with the loader.
 * @hidden
 */
function forceLoad() {}
// Noop

/**
 * This function is here to be API compatible with the loader.
 * @hidden
 */
function onLoad(callback) {
    callback();
}
/**
 * A promise that resolves when all current events have been sent.
 * If you provide a timeout and the queue takes longer to drain the promise returns false.
 *
 * @param timeout Maximum time in ms the client should wait.
 */
function flush(timeout) {
    var client = Object(_sentry_core__WEBPACK_IMPORTED_MODULE_0__["getCurrentHub"])().getClient();
    if (client) {
        return client.flush(timeout);
    }
    return Promise.reject(false);
}
/**
 * A promise that resolves when all current events have been sent.
 * If you provide a timeout and the queue takes longer to drain the promise returns false.
 *
 * @param timeout Maximum time in ms the client should wait.
 */
function close(timeout) {
    var client = Object(_sentry_core__WEBPACK_IMPORTED_MODULE_0__["getCurrentHub"])().getClient();
    if (client) {
        return client.close(timeout);
    }
    return Promise.reject(false);
}
/**
 * Wrap code within a try/catch block so the SDK is able to capture errors.
 *
 * @param fn A function to wrap.
 */
function wrap(fn) {
    // tslint:disable-next-line: no-unsafe-any
    Object(_helpers__WEBPACK_IMPORTED_MODULE_2__["wrap"])(fn)();
}
//# sourceMappingURL=sdk.js.map

/***/ }),

/***/ "../browser/esm/tracekit.js":
/*!**********************************!*\
  !*** ../browser/esm/tracekit.js ***!
  \**********************************/
/*! exports provided: _subscribe, _installGlobalHandler, _installGlobalUnhandledRejectionHandler, _computeStackTrace */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "_subscribe", function() { return _subscribe; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "_installGlobalHandler", function() { return _installGlobalHandler; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "_installGlobalUnhandledRejectionHandler", function() { return _installGlobalUnhandledRejectionHandler; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "_computeStackTrace", function() { return _computeStackTrace; });
/* harmony import */ var tslib__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! tslib */ "../../node_modules/tslib/tslib.es6.js");
/* harmony import */ var _sentry_utils__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! @sentry/utils */ "../utils/esm/index.js");
// tslint:disable


/**
 * TraceKit - Cross brower stack traces
 *
 * This was originally forked from github.com/occ/TraceKit, but has since been
 * largely modified and is now maintained as part of Sentry JS SDK.
 *
 * NOTE: Last merge with upstream repository
 * Jul 11,2018 - #f03357c
 *
 * https://github.com/csnover/TraceKit
 * @license MIT
 * @namespace TraceKit
 */
var window = Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_1__["getGlobalObject"])();
var TraceKit = {
    _report: false,
    _collectWindowErrors: false,
    _computeStackTrace: false,
    _linesOfContext: false
};
// var TraceKit: TraceKitInterface = {};
// var TraceKit = {};
// global reference to slice
var UNKNOWN_FUNCTION = '?';
// https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Error#Error_types
var ERROR_TYPES_RE = /^(?:[Uu]ncaught (?:exception: )?)?(?:((?:Eval|Internal|Range|Reference|Syntax|Type|URI|)Error): )?(.*)$/;
/**
 * A better form of hasOwnProperty<br/>
 * Example: `_has(MainHostObject, property) === true/false`
 *
 * @param {Object} object to check property
 * @param {string} key to check
 * @return {Boolean} true if the object has the key and it is not inherited
 */
function _has(object, key) {
    return Object.prototype.hasOwnProperty.call(object, key);
}
/**
 * A safe form of location.href<br/>
 *
 * @return {string} location.href
 */
function getLocationHref() {
    if (typeof document === 'undefined' || document.location == null) return '';
    return document.location.href;
}
/**
 * Cross-browser processing of unhandled exceptions
 *
 * Syntax:
 * ```js
 *   TraceKit.report.subscribe(function(stackInfo) { ... })
 *   TraceKit.report(exception)
 *   try { ...code... } catch(ex) { TraceKit.report(ex); }
 * ```
 *
 * Supports:
 *   - Firefox: full stack trace with line numbers, plus column number
 *     on top frame; column number is not guaranteed
 *   - Opera: full stack trace with line and column numbers
 *   - Chrome: full stack trace with line and column numbers
 *   - Safari: line and column number for the top frame only; some frames
 *     may be missing, and column number is not guaranteed
 *   - IE: line and column number for the top frame only; some frames
 *     may be missing, and column number is not guaranteed
 *
 * In theory, TraceKit should work on all of the following versions:
 *   - IE5.5+ (only 8.0 tested)
 *   - Firefox 0.9+ (only 3.5+ tested)
 *   - Opera 7+ (only 10.50 tested; versions 9 and earlier may require
 *     Exceptions Have Stacktrace to be enabled in opera:config)
 *   - Safari 3+ (only 4+ tested)
 *   - Chrome 1+ (only 5+ tested)
 *   - Konqueror 3.5+ (untested)
 *
 * Requires TraceKit._computeStackTrace.
 *
 * Tries to catch all unhandled exceptions and report them to the
 * subscribed handlers. Please note that TraceKit.report will rethrow the
 * exception. This is REQUIRED in order to get a useful stack trace in IE.
 * If the exception does not reach the top of the browser, you will only
 * get a stack trace from the point where TraceKit.report was called.
 *
 * Handlers receive a TraceKit.StackTrace object as described in the
 * TraceKit._computeStackTrace docs.
 *
 * @memberof TraceKit
 * @namespace
 */
TraceKit._report = function reportModuleWrapper() {
    var handlers = [],
        lastException = null,
        lastExceptionStack = null;
    /**
     * Add a crash handler.
     * @param {Function} handler
     * @memberof TraceKit.report
     */
    function _subscribe(handler) {
        // NOTE: We call both handlers manually in browser/integrations/globalhandler.ts
        // So user can choose which one he wants to attach
        // installGlobalHandler();
        // installGlobalUnhandledRejectionHandler();
        handlers.push(handler);
    }
    /**
     * Dispatch stack information to all handlers.
     * @param {TraceKit.StackTrace} stack
     * @param {boolean} isWindowError Is this a top-level window error?
     * @param {Error=} error The error that's being handled (if available, null otherwise)
     * @memberof TraceKit.report
     * @throws An exception if an error occurs while calling an handler.
     */
    function _notifyHandlers(stack, isWindowError, error) {
        var exception = null;
        if (isWindowError && !TraceKit._collectWindowErrors) {
            return;
        }
        for (var i in handlers) {
            if (_has(handlers, i)) {
                try {
                    handlers[i](stack, isWindowError, error);
                } catch (inner) {
                    exception = inner;
                }
            }
        }
        if (exception) {
            throw exception;
        }
    }
    var _oldOnerrorHandler, _onErrorHandlerInstalled;
    /**
     * Ensures all global unhandled exceptions are recorded.
     * Supported by Gecko and IE.
     * @param {string} message Error message.
     * @param {string} url URL of script that generated the exception.
     * @param {(number|string)} lineNo The line number at which the error occurred.
     * @param {(number|string)=} columnNo The column number at which the error occurred.
     * @param {Error=} errorObj The actual Error object.
     * @memberof TraceKit.report
     */
    function _traceKitWindowOnError(message, url, lineNo, columnNo, errorObj) {
        var stack = null;
        // If 'errorObj' is ErrorEvent, get real Error from inside
        errorObj = Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_1__["isErrorEvent"])(errorObj) ? errorObj.error : errorObj;
        // If 'message' is ErrorEvent, get real message from inside
        message = Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_1__["isErrorEvent"])(message) ? message.message : message;
        if (lastExceptionStack) {
            TraceKit._computeStackTrace._augmentStackTraceWithInitialElement(lastExceptionStack, url, lineNo, message);
            processLastException();
        } else if (errorObj && Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_1__["isError"])(errorObj)) {
            stack = TraceKit._computeStackTrace(errorObj);
            stack.mechanism = 'onerror';
            _notifyHandlers(stack, true, errorObj);
        } else {
            var location = {
                url: url,
                line: lineNo,
                column: columnNo
            };
            var name;
            var msg = message; // must be new var or will modify original `arguments`
            if ({}.toString.call(message) === '[object String]') {
                var groups = message.match(ERROR_TYPES_RE);
                if (groups) {
                    name = groups[1];
                    msg = groups[2];
                }
            }
            location.func = UNKNOWN_FUNCTION;
            location.context = null;
            stack = {
                name: name,
                message: msg,
                mode: 'onerror',
                mechanism: 'onerror',
                stack: [Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__assign"])(Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__assign"])({}, location), {
                    // Firefox sometimes doesn't return url correctly and this is an old behavior
                    // that I prefer to port here as well.
                    // It can be altered only here, as previously it's using `location.url` for other things — Kamil
                    url: location.url || getLocationHref() })]
            };
            _notifyHandlers(stack, true, null);
        }
        if (_oldOnerrorHandler) {
            // @ts-ignore
            return _oldOnerrorHandler.apply(this, arguments);
        }
        return false;
    }
    /**
     * Ensures all unhandled rejections are recorded.
     * @param {PromiseRejectionEvent} e event.
     * @memberof TraceKit.report
     * @see https://developer.mozilla.org/en-US/docs/Web/API/WindowEventHandlers/onunhandledrejection
     * @see https://developer.mozilla.org/en-US/docs/Web/API/PromiseRejectionEvent
     */
    function _traceKitWindowOnUnhandledRejection(e) {
        var err = e && (e.detail ? e.detail.reason : e.reason) || e;
        var stack = TraceKit._computeStackTrace(err);
        stack.mechanism = 'onunhandledrejection';
        if (!stack.message) {
            stack.message = JSON.stringify(Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_1__["normalize"])(err));
        }
        _notifyHandlers(stack, true, err);
    }
    /**
     * Install a global onerror handler
     * @memberof TraceKit.report
     */
    function _installGlobalHandler() {
        if (_onErrorHandlerInstalled === true) {
            return;
        }
        _oldOnerrorHandler = window.onerror;
        window.onerror = _traceKitWindowOnError;
        _onErrorHandlerInstalled = true;
    }
    /**
     * Install a global onunhandledrejection handler
     * @memberof TraceKit.report
     */
    function _installGlobalUnhandledRejectionHandler() {
        window.onunhandledrejection = _traceKitWindowOnUnhandledRejection;
    }
    /**
     * Process the most recent exception
     * @memberof TraceKit.report
     */
    function processLastException() {
        var _lastExceptionStack = lastExceptionStack,
            _lastException = lastException;
        lastExceptionStack = null;
        lastException = null;
        _notifyHandlers(_lastExceptionStack, false, _lastException);
    }
    /**
     * Reports an unhandled Error to TraceKit.
     * @param {Error} ex
     * @memberof TraceKit.report
     * @throws An exception if an incomplete stack trace is detected (old IE browsers).
     */
    function _report(ex) {
        if (lastExceptionStack) {
            if (lastException === ex) {
                return; // already caught by an inner catch block, ignore
            } else {
                processLastException();
            }
        }
        var stack = TraceKit._computeStackTrace(ex);
        lastExceptionStack = stack;
        lastException = ex;
        // If the stack trace is incomplete, wait for 2 seconds for
        // slow slow IE to see if onerror occurs or not before reporting
        // this exception; otherwise, we will end up with an incomplete
        // stack trace
        setTimeout(function () {
            if (lastException === ex) {
                processLastException();
            }
        }, stack.incomplete ? 2000 : 0);
        throw ex; // re-throw to propagate to the top level (and cause window.onerror)
    }
    _report._subscribe = _subscribe;
    _report._installGlobalHandler = _installGlobalHandler;
    _report._installGlobalUnhandledRejectionHandler = _installGlobalUnhandledRejectionHandler;
    return _report;
}();
/**
 * An object representing a single stack frame.
 * @typedef {Object} StackFrame
 * @property {string} url The JavaScript or HTML file URL.
 * @property {string} func The function name, or empty for anonymous functions (if guessing did not work).
 * @property {string[]?} args The arguments passed to the function, if known.
 * @property {number=} line The line number, if known.
 * @property {number=} column The column number, if known.
 * @property {string[]} context An array of source code lines; the middle element corresponds to the correct line#.
 * @memberof TraceKit
 */
/**
 * An object representing a JavaScript stack trace.
 * @typedef {Object} StackTrace
 * @property {string} name The name of the thrown exception.
 * @property {string} message The exception error message.
 * @property {TraceKit.StackFrame[]} stack An array of stack frames.
 * @property {string} mode 'stack', 'stacktrace', 'multiline', 'callers', 'onerror', or 'failed' -- method used to collect the stack trace.
 * @memberof TraceKit
 */
/**
 * TraceKit._computeStackTrace: cross-browser stack traces in JavaScript
 *
 * Syntax:
 *   ```js
 *   s = TraceKit._computeStackTrace(exception) // consider using TraceKit.report instead (see below)
 *   ```
 *
 * Supports:
 *   - Firefox:  full stack trace with line numbers and unreliable column
 *               number on top frame
 *   - Opera 10: full stack trace with line and column numbers
 *   - Opera 9-: full stack trace with line numbers
 *   - Chrome:   full stack trace with line and column numbers
 *   - Safari:   line and column number for the topmost stacktrace element
 *               only
 *   - IE:       no line numbers whatsoever
 *
 * Tries to guess names of anonymous functions by looking for assignments
 * in the source code. In IE and Safari, we have to guess source file names
 * by searching for function bodies inside all page scripts. This will not
 * work for scripts that are loaded cross-domain.
 * Here be dragons: some function names may be guessed incorrectly, and
 * duplicate functions may be mismatched.
 *
 * TraceKit._computeStackTrace should only be used for tracing purposes.
 * Logging of unhandled exceptions should be done with TraceKit.report,
 * which builds on top of TraceKit._computeStackTrace and provides better
 * IE support by utilizing the window.onerror event to retrieve information
 * about the top of the stack.
 *
 * Note: In IE and Safari, no stack trace is recorded on the Error object,
 * so computeStackTrace instead walks its *own* chain of callers.
 * This means that:
 *  * in Safari, some methods may be missing from the stack trace;
 *  * in IE, the topmost function in the stack trace will always be the
 *    caller of computeStackTrace.
 *
 * This is okay for tracing (because you are likely to be calling
 * computeStackTrace from the function you want to be the topmost element
 * of the stack trace anyway), but not okay for logging unhandled
 * exceptions (because your catch block will likely be far away from the
 * inner function that actually caused the exception).
 *
 * @memberof TraceKit
 * @namespace
 */
TraceKit._computeStackTrace = function _computeStackTraceWrapper() {
    // Contents of Exception in various browsers.
    //
    // SAFARI:
    // ex.message = Can't find variable: qq
    // ex.line = 59
    // ex.sourceId = 580238192
    // ex.sourceURL = http://...
    // ex.expressionBeginOffset = 96
    // ex.expressionCaretOffset = 98
    // ex.expressionEndOffset = 98
    // ex.name = ReferenceError
    //
    // FIREFOX:
    // ex.message = qq is not defined
    // ex.fileName = http://...
    // ex.lineNumber = 59
    // ex.columnNumber = 69
    // ex.stack = ...stack trace... (see the example below)
    // ex.name = ReferenceError
    //
    // CHROME:
    // ex.message = qq is not defined
    // ex.name = ReferenceError
    // ex.type = not_defined
    // ex.arguments = ['aa']
    // ex.stack = ...stack trace...
    //
    // INTERNET EXPLORER:
    // ex.message = ...
    // ex.name = ReferenceError
    //
    // OPERA:
    // ex.message = ...message... (see the example below)
    // ex.name = ReferenceError
    // ex.opera#sourceloc = 11  (pretty much useless, duplicates the info in ex.message)
    // ex.stacktrace = n/a; see 'opera:config#UserPrefs|Exceptions Have Stacktrace'
    /**
     * Computes stack trace information from the stack property.
     * Chrome and Gecko use this property.
     * @param {Error} ex
     * @return {?TraceKit.StackTrace} Stack trace information.
     * @memberof TraceKit._computeStackTrace
     */
    function _computeStackTraceFromStackProp(ex) {
        if (!ex || !ex.stack) {
            return null;
        }
        // Chromium based browsers: Chrome, Brave, new Opera, new Edge
        var chrome = /^\s*at (?:(.*?) ?\()?((?:file|https?|blob|chrome-extension|native|eval|webpack|<anonymous>|[a-z]:|\/).*?)(?::(\d+))?(?::(\d+))?\)?\s*$/i,

        // gecko regex: `(?:bundle|\d+\.js)`: `bundle` is for react native, `\d+\.js` also but specifically for ram bundles because it
        // generates filenames without a prefix like `file://` the filenames in the stacktrace are just 42.js
        // We need this specific case for now because we want no other regex to match.
        gecko = /^\s*(.*?)(?:\((.*?)\))?(?:^|@)?((?:file|https?|blob|chrome|webpack|resource|moz-extension).*?:\/.*?|\[native code\]|[^@]*(?:bundle|\d+\.js))(?::(\d+))?(?::(\d+))?\s*$/i,
            winjs = /^\s*at (?:((?:\[object object\])?.+) )?\(?((?:file|ms-appx|https?|webpack|blob):.*?):(\d+)(?::(\d+))?\)?\s*$/i,

        // Used to additionally parse URL/line/column from eval frames
        isEval,
            geckoEval = /(\S+) line (\d+)(?: > eval line \d+)* > eval/i,
            chromeEval = /\((\S*)(?::(\d+))(?::(\d+))\)/,
            lines = ex.stack.split('\n'),
            stack = [],
            submatch,
            parts,
            element,
            reference = /^(.*) is undefined$/.exec(ex.message);
        for (var i = 0, j = lines.length; i < j; ++i) {
            if (parts = chrome.exec(lines[i])) {
                var isNative = parts[2] && parts[2].indexOf('native') === 0; // start of line
                isEval = parts[2] && parts[2].indexOf('eval') === 0; // start of line
                if (isEval && (submatch = chromeEval.exec(parts[2]))) {
                    // throw out eval line/column and use top-most line/column number
                    parts[2] = submatch[1]; // url
                    parts[3] = submatch[2]; // line
                    parts[4] = submatch[3]; // column
                }
                element = {
                    url: parts[2],
                    func: parts[1] || UNKNOWN_FUNCTION,
                    args: isNative ? [parts[2]] : [],
                    line: parts[3] ? +parts[3] : null,
                    column: parts[4] ? +parts[4] : null
                };
            } else if (parts = winjs.exec(lines[i])) {
                element = {
                    url: parts[2],
                    func: parts[1] || UNKNOWN_FUNCTION,
                    args: [],
                    line: +parts[3],
                    column: parts[4] ? +parts[4] : null
                };
            } else if (parts = gecko.exec(lines[i])) {
                isEval = parts[3] && parts[3].indexOf(' > eval') > -1;
                if (isEval && (submatch = geckoEval.exec(parts[3]))) {
                    // throw out eval line/column and use top-most line number
                    parts[1] = parts[1] || "eval";
                    parts[3] = submatch[1];
                    parts[4] = submatch[2];
                    parts[5] = ''; // no column when eval
                } else if (i === 0 && !parts[5] && ex.columnNumber !== void 0) {
                    // FireFox uses this awesome columnNumber property for its top frame
                    // Also note, Firefox's column number is 0-based and everything else expects 1-based,
                    // so adding 1
                    // NOTE: this hack doesn't work if top-most frame is eval
                    stack[0].column = ex.columnNumber + 1;
                }
                element = {
                    url: parts[3],
                    func: parts[1] || UNKNOWN_FUNCTION,
                    args: parts[2] ? parts[2].split(',') : [],
                    line: parts[4] ? +parts[4] : null,
                    column: parts[5] ? +parts[5] : null
                };
            } else {
                continue;
            }
            if (!element.func && element.line) {
                element.func = UNKNOWN_FUNCTION;
            }
            element.context = null;
            stack.push(element);
        }
        if (!stack.length) {
            return null;
        }
        if (stack[0] && stack[0].line && !stack[0].column && reference) {
            stack[0].column = null;
        }
        return {
            mode: 'stack',
            name: ex.name,
            message: ex.message,
            stack: stack
        };
    }
    /**
     * Computes stack trace information from the stacktrace property.
     * Opera 10+ uses this property.
     * @param {Error} ex
     * @return {?TraceKit.StackTrace} Stack trace information.
     * @memberof TraceKit._computeStackTrace
     */
    function _computeStackTraceFromStacktraceProp(ex) {
        // Access and store the stacktrace property before doing ANYTHING
        // else to it because Opera is not very good at providing it
        // reliably in other circumstances.
        var stacktrace = ex.stacktrace;
        if (!stacktrace) {
            return;
        }
        var opera10Regex = / line (\d+).*script (?:in )?(\S+)(?:: in function (\S+))?$/i,
            opera11Regex = / line (\d+), column (\d+)\s*(?:in (?:<anonymous function: ([^>]+)>|([^\)]+))\((.*)\))? in (.*):\s*$/i,
            lines = stacktrace.split('\n'),
            stack = [],
            parts;
        for (var line = 0; line < lines.length; line += 2) {
            var element = null;
            if (parts = opera10Regex.exec(lines[line])) {
                element = {
                    url: parts[2],
                    line: +parts[1],
                    column: null,
                    func: parts[3],
                    args: []
                };
            } else if (parts = opera11Regex.exec(lines[line])) {
                element = {
                    url: parts[6],
                    line: +parts[1],
                    column: +parts[2],
                    func: parts[3] || parts[4],
                    args: parts[5] ? parts[5].split(',') : []
                };
            }
            if (element) {
                if (!element.func && element.line) {
                    element.func = UNKNOWN_FUNCTION;
                }
                if (element.line) {
                    element.context = null;
                }
                if (!element.context) {
                    element.context = [lines[line + 1]];
                }
                stack.push(element);
            }
        }
        if (!stack.length) {
            return null;
        }
        return {
            mode: 'stacktrace',
            name: ex.name,
            message: ex.message,
            stack: stack
        };
    }
    /**
     * NOT TESTED.
     * Computes stack trace information from an error message that includes
     * the stack trace.
     * Opera 9 and earlier use this method if the option to show stack
     * traces is turned on in opera:config.
     * @param {Error} ex
     * @return {?TraceKit.StackTrace} Stack information.
     * @memberof TraceKit._computeStackTrace
     */
    function _computeStackTraceFromOperaMultiLineMessage(ex) {
        // TODO: Clean this function up
        // Opera includes a stack trace into the exception message. An example is:
        //
        // Statement on line 3: Undefined variable: undefinedFunc
        // Backtrace:
        //   Line 3 of linked script file://localhost/Users/andreyvit/Projects/TraceKit/javascript-client/sample.js: In function zzz
        //         undefinedFunc(a);
        //   Line 7 of inline#1 script in file://localhost/Users/andreyvit/Projects/TraceKit/javascript-client/sample.html: In function yyy
        //           zzz(x, y, z);
        //   Line 3 of inline#1 script in file://localhost/Users/andreyvit/Projects/TraceKit/javascript-client/sample.html: In function xxx
        //           yyy(a, a, a);
        //   Line 1 of function script
        //     try { xxx('hi'); return false; } catch(ex) { TraceKit.report(ex); }
        //   ...
        var lines = ex.message.split('\n');
        if (lines.length < 4) {
            return null;
        }
        var lineRE1 = /^\s*Line (\d+) of linked script ((?:file|https?|blob)\S+)(?:: in function (\S+))?\s*$/i,
            lineRE2 = /^\s*Line (\d+) of inline#(\d+) script in ((?:file|https?|blob)\S+)(?:: in function (\S+))?\s*$/i,
            lineRE3 = /^\s*Line (\d+) of function script\s*$/i,
            stack = [],
            scripts = window && window.document && window.document.getElementsByTagName('script'),
            inlineScriptBlocks = [],
            parts;
        for (var s in scripts) {
            if (_has(scripts, s) && !scripts[s].src) {
                inlineScriptBlocks.push(scripts[s]);
            }
        }
        for (var line = 2; line < lines.length; line += 2) {
            var item = null;
            if (parts = lineRE1.exec(lines[line])) {
                item = {
                    url: parts[2],
                    func: parts[3],
                    args: [],
                    line: +parts[1],
                    column: null
                };
            } else if (parts = lineRE2.exec(lines[line])) {
                item = {
                    url: parts[3],
                    func: parts[4],
                    args: [],
                    line: +parts[1],
                    column: null
                };
            } else if (parts = lineRE3.exec(lines[line])) {
                var url = getLocationHref().replace(/#.*$/, '');
                item = {
                    url: url,
                    func: '',
                    args: [],
                    line: parts[1],
                    column: null
                };
            }
            if (item) {
                if (!item.func) {
                    item.func = UNKNOWN_FUNCTION;
                }
                // if (context) alert("Context mismatch. Correct midline:\n" + lines[i+1] + "\n\nMidline:\n" + midline + "\n\nContext:\n" + context.join("\n") + "\n\nURL:\n" + item.url);
                item.context = [lines[line + 1]];
                stack.push(item);
            }
        }
        if (!stack.length) {
            return null; // could not parse multiline exception message as Opera stack trace
        }
        return {
            mode: 'multiline',
            name: ex.name,
            message: lines[0],
            stack: stack
        };
    }
    /**
     * Adds information about the first frame to incomplete stack traces.
     * Safari and IE require this to get complete data on the first frame.
     * @param {TraceKit.StackTrace} stackInfo Stack trace information from
     * one of the compute* methods.
     * @param {string} url The URL of the script that caused an error.
     * @param {(number|string)} lineNo The line number of the script that
     * caused an error.
     * @param {string=} message The error generated by the browser, which
     * hopefully contains the name of the object that caused the error.
     * @return {boolean} Whether or not the stack information was
     * augmented.
     * @memberof TraceKit._computeStackTrace
     */
    function _augmentStackTraceWithInitialElement(stackInfo, url, lineNo, message) {
        var initial = {
            url: url,
            line: lineNo
        };
        if (initial.url && initial.line) {
            stackInfo.incomplete = false;
            if (!initial.func) {
                initial.func = UNKNOWN_FUNCTION;
            }
            if (!initial.context) {
                initial.context = null;
            }
            var reference = / '([^']+)' /.exec(message);
            if (reference) {
                initial.column = null;
            }
            if (stackInfo.stack.length > 0) {
                if (stackInfo.stack[0].url === initial.url) {
                    if (stackInfo.stack[0].line === initial.line) {
                        return false; // already in stack trace
                    } else if (!stackInfo.stack[0].line && stackInfo.stack[0].func === initial.func) {
                        stackInfo.stack[0].line = initial.line;
                        stackInfo.stack[0].context = initial.context;
                        return false;
                    }
                }
            }
            stackInfo.stack.unshift(initial);
            stackInfo.partial = true;
            return true;
        } else {
            stackInfo.incomplete = true;
        }
        return false;
    }
    /**
     * Computes stack trace information by walking the arguments.caller
     * chain at the time the exception occurred. This will cause earlier
     * frames to be missed but is the only way to get any stack trace in
     * Safari and IE. The top frame is restored by
     * {@link augmentStackTraceWithInitialElement}.
     * @param {Error} ex
     * @return {TraceKit.StackTrace=} Stack trace information.
     * @memberof TraceKit._computeStackTrace
     */
    function _computeStackTraceByWalkingCallerChain(ex, depth) {
        var functionName = /function\s+([_$a-zA-Z\xA0-\uFFFF][_$a-zA-Z0-9\xA0-\uFFFF]*)?\s*\(/i,
            stack = [],
            funcs = {},
            recursion = false,
            parts,
            item;
        for (var curr = _computeStackTraceByWalkingCallerChain.caller; curr && !recursion; curr = curr.caller) {
            if (curr === _computeStackTrace || curr === TraceKit._report) {
                continue;
            }
            item = {
                url: null,
                func: UNKNOWN_FUNCTION,
                args: [],
                line: null,
                column: null
            };
            if (curr.name) {
                item.func = curr.name;
            } else if (parts = functionName.exec(curr.toString())) {
                item.func = parts[1];
            }
            if (typeof item.func === 'undefined') {
                try {
                    item.func = parts.input.substring(0, parts.input.indexOf('{'));
                } catch (e) {}
            }
            if (funcs['' + curr]) {
                recursion = true;
            } else {
                funcs['' + curr] = true;
            }
            stack.push(item);
        }
        if (depth) {
            stack.splice(0, depth);
        }
        var result = {
            mode: 'callers',
            name: ex.name,
            message: ex.message,
            stack: stack
        };
        _augmentStackTraceWithInitialElement(result, ex.sourceURL || ex.fileName, ex.line || ex.lineNumber, ex.message || ex.description);
        return result;
    }
    /**
     * Computes a stack trace for an exception.
     * @param {Error} ex
     * @param {(string|number)=} depth
     * @memberof TraceKit._computeStackTrace
     */
    function computeStackTrace(ex, depth) {
        var stack = null;
        depth = depth == null ? 0 : +depth;
        try {
            // This must be tried first because Opera 10 *destroys*
            // its stacktrace property if you try to access the stack
            // property first!!
            stack = _computeStackTraceFromStacktraceProp(ex);
            if (stack) {
                return stack;
            }
        } catch (e) {}
        try {
            stack = _computeStackTraceFromStackProp(ex);
            if (stack) {
                return stack;
            }
        } catch (e) {}
        try {
            stack = _computeStackTraceFromOperaMultiLineMessage(ex);
            if (stack) {
                return stack;
            }
        } catch (e) {}
        try {
            stack = _computeStackTraceByWalkingCallerChain(ex, depth + 1);
            if (stack) {
                return stack;
            }
        } catch (e) {}
        return {
            original: ex,
            name: ex.name,
            message: ex.message,
            mode: 'failed'
        };
    }
    computeStackTrace._augmentStackTraceWithInitialElement = _augmentStackTraceWithInitialElement;
    computeStackTrace._computeStackTraceFromStackProp = _computeStackTraceFromStackProp;
    return computeStackTrace;
}();
TraceKit._collectWindowErrors = true;
TraceKit._linesOfContext = 11;
var _subscribe = TraceKit._report._subscribe;
var _installGlobalHandler = TraceKit._report._installGlobalHandler;
var _installGlobalUnhandledRejectionHandler = TraceKit._report._installGlobalUnhandledRejectionHandler;
var _computeStackTrace = TraceKit._computeStackTrace;

//# sourceMappingURL=tracekit.js.map

/***/ }),

/***/ "../browser/esm/transports/base.js":
/*!*****************************************!*\
  !*** ../browser/esm/transports/base.js ***!
  \*****************************************/
/*! exports provided: BaseTransport */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "BaseTransport", function() { return BaseTransport; });
/* harmony import */ var _sentry_core__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! @sentry/core */ "../core/esm/index.js");
/* harmony import */ var _sentry_utils__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! @sentry/utils */ "../utils/esm/index.js");


/** Base Transport class implementation */
var BaseTransport = /** @class */function () {
    function BaseTransport(options) {
        this.options = options;
        /** A simple buffer holding all requests. */
        this._buffer = new _sentry_utils__WEBPACK_IMPORTED_MODULE_1__["PromiseBuffer"](30);
        this.url = new _sentry_core__WEBPACK_IMPORTED_MODULE_0__["API"](this.options.dsn).getStoreEndpointWithUrlEncodedAuth();
    }
    /**
     * @inheritDoc
     */
    BaseTransport.prototype.sendEvent = function (_) {
        throw new _sentry_utils__WEBPACK_IMPORTED_MODULE_1__["SentryError"]('Transport Class has to implement `sendEvent` method');
    };
    /**
     * @inheritDoc
     */
    BaseTransport.prototype.close = function (timeout) {
        return this._buffer.drain(timeout);
    };
    return BaseTransport;
}();

//# sourceMappingURL=base.js.map

/***/ }),

/***/ "../browser/esm/transports/fetch.js":
/*!******************************************!*\
  !*** ../browser/esm/transports/fetch.js ***!
  \******************************************/
/*! exports provided: FetchTransport */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "FetchTransport", function() { return FetchTransport; });
/* harmony import */ var tslib__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! tslib */ "../../node_modules/tslib/tslib.es6.js");
/* harmony import */ var _sentry_types__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! @sentry/types */ "../types/esm/index.js");
/* harmony import */ var _sentry_utils__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! @sentry/utils */ "../utils/esm/index.js");
/* harmony import */ var _base__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! ./base */ "../browser/esm/transports/base.js");




var global = Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_2__["getGlobalObject"])();
/** `fetch` based transport */
var FetchTransport = /** @class */function (_super) {
    Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__extends"])(FetchTransport, _super);
    function FetchTransport() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    /**
     * @inheritDoc
     */
    FetchTransport.prototype.sendEvent = function (event) {
        var defaultOptions = {
            body: JSON.stringify(event),
            method: 'POST',
            // Despite all stars in the sky saying that Edge supports old draft syntax, aka 'never', 'always', 'origin' and 'default
            // https://caniuse.com/#feat=referrer-policy
            // It doesn't. And it throw exception instead of ignoring this parameter...
            // REF: https://github.com/getsentry/raven-js/issues/1233
            referrerPolicy: Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_2__["supportsReferrerPolicy"])() ? 'origin' : ''
        };
        return this._buffer.add(global.fetch(this.url, defaultOptions).then(function (response) {
            return {
                status: _sentry_types__WEBPACK_IMPORTED_MODULE_1__["Status"].fromHttpCode(response.status)
            };
        }));
    };
    return FetchTransport;
}(_base__WEBPACK_IMPORTED_MODULE_3__["BaseTransport"]);

//# sourceMappingURL=fetch.js.map

/***/ }),

/***/ "../browser/esm/transports/index.js":
/*!******************************************!*\
  !*** ../browser/esm/transports/index.js ***!
  \******************************************/
/*! exports provided: BaseTransport, FetchTransport, XHRTransport */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var _base__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./base */ "../browser/esm/transports/base.js");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "BaseTransport", function() { return _base__WEBPACK_IMPORTED_MODULE_0__["BaseTransport"]; });

/* harmony import */ var _fetch__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./fetch */ "../browser/esm/transports/fetch.js");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "FetchTransport", function() { return _fetch__WEBPACK_IMPORTED_MODULE_1__["FetchTransport"]; });

/* harmony import */ var _xhr__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ./xhr */ "../browser/esm/transports/xhr.js");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "XHRTransport", function() { return _xhr__WEBPACK_IMPORTED_MODULE_2__["XHRTransport"]; });




//# sourceMappingURL=index.js.map

/***/ }),

/***/ "../browser/esm/transports/xhr.js":
/*!****************************************!*\
  !*** ../browser/esm/transports/xhr.js ***!
  \****************************************/
/*! exports provided: XHRTransport */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "XHRTransport", function() { return XHRTransport; });
/* harmony import */ var tslib__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! tslib */ "../../node_modules/tslib/tslib.es6.js");
/* harmony import */ var _sentry_types__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! @sentry/types */ "../types/esm/index.js");
/* harmony import */ var _base__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ./base */ "../browser/esm/transports/base.js");



/** `XHR` based transport */
var XHRTransport = /** @class */function (_super) {
    Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__extends"])(XHRTransport, _super);
    function XHRTransport() {
        return _super !== null && _super.apply(this, arguments) || this;
    }
    /**
     * @inheritDoc
     */
    XHRTransport.prototype.sendEvent = function (event) {
        var _this = this;
        return this._buffer.add(new Promise(function (resolve, reject) {
            var request = new XMLHttpRequest();
            request.onreadystatechange = function () {
                if (request.readyState !== 4) {
                    return;
                }
                if (request.status === 200) {
                    resolve({
                        status: _sentry_types__WEBPACK_IMPORTED_MODULE_1__["Status"].fromHttpCode(request.status)
                    });
                }
                reject(request);
            };
            request.open('POST', _this.url);
            request.send(JSON.stringify(event));
        }));
    };
    return XHRTransport;
}(_base__WEBPACK_IMPORTED_MODULE_2__["BaseTransport"]);

//# sourceMappingURL=xhr.js.map

/***/ }),

/***/ "../browser/esm/version.js":
/*!*********************************!*\
  !*** ../browser/esm/version.js ***!
  \*********************************/
/*! exports provided: SDK_NAME, SDK_VERSION */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "SDK_NAME", function() { return SDK_NAME; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "SDK_VERSION", function() { return SDK_VERSION; });
var SDK_NAME = 'sentry.javascript.browser';
var SDK_VERSION = '5.3.0';
//# sourceMappingURL=version.js.map

/***/ }),

/***/ "../core/esm/api.js":
/*!**************************!*\
  !*** ../core/esm/api.js ***!
  \**************************/
/*! exports provided: API */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "API", function() { return API; });
/* harmony import */ var _dsn__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./dsn */ "../core/esm/dsn.js");

var SENTRY_API_VERSION = '7';
/** Helper class to provide urls to different Sentry endpoints. */
var API = /** @class */function () {
    /** Create a new instance of API */
    function API(dsn) {
        this.dsn = dsn;
        this._dsnObject = new _dsn__WEBPACK_IMPORTED_MODULE_0__["Dsn"](dsn);
    }
    /** Returns the Dsn object. */
    API.prototype.getDsn = function () {
        return this._dsnObject;
    };
    /** Returns a string with auth headers in the url to the store endpoint. */
    API.prototype.getStoreEndpoint = function () {
        return "" + this._getBaseUrl() + this.getStoreEndpointPath();
    };
    /** Returns the store endpoint with auth added in url encoded. */
    API.prototype.getStoreEndpointWithUrlEncodedAuth = function () {
        // Auth is intentionally sent as part of query string (NOT as custom HTTP header)
        // to avoid preflight CORS requests
        return "" + this.getStoreEndpoint();
    };
    /** Returns the base path of the url including the port. */
    API.prototype._getBaseUrl = function () {
        var dsn = this._dsnObject;
        var protocol = dsn.protocol ? dsn.protocol + ":" : '';
        var port = dsn.port ? ":" + dsn.port : '';
        return protocol + "//" + dsn.host + port;
    };
    /** Returns only the path component for the store endpoint. */
    API.prototype.getStoreEndpointPath = function () {
        var dsn = this._dsnObject;
        return "/entrance/" + dsn.projectId + "/uploadJson/?p_id=" + dsn.projectId + "&plugin=" + dsn.plugin + "&version=" + dsn.version + "&a=1";
    };
    /** Returns an object that can be used in request headers. */
    API.prototype.getRequestHeaders = function (clientName, clientVersion) {
        var dsn = this._dsnObject;
        var header = ["Sentry sentry_version=" + SENTRY_API_VERSION];
        header.push("sentry_timestamp=" + new Date().getTime());
        header.push("sentry_client=" + clientName + "/" + clientVersion);
        header.push("sentry_key=" + dsn.user);
        return {
            'Content-Type': 'application/json',
            'X-Sentry-Auth': header.join(', ')
        };
    };
    /** Returns the url to the report dialog endpoint. */
    API.prototype.getReportDialogEndpoint = function (dialogOptions) {
        if (dialogOptions === void 0) {
            dialogOptions = {};
        }
        var dsn = this._dsnObject;
        // todo: 处理上报dialog的逻辑
        var endpoint = this._getBaseUrl() + "/api/embed/error-page/";
        var encodedOptions = [];
        encodedOptions.push("dsn=" + dsn.toString());
        for (var key in dialogOptions) {
            if (key === 'user') {
                if (!dialogOptions.user) {
                    continue;
                }
                if (dialogOptions.user.name) {
                    encodedOptions.push("name=" + encodeURIComponent(dialogOptions.user.name));
                }
                if (dialogOptions.user.email) {
                    encodedOptions.push("email=" + encodeURIComponent(dialogOptions.user.email));
                }
            } else {
                encodedOptions.push(encodeURIComponent(key) + "=" + encodeURIComponent(dialogOptions[key]));
            }
        }
        if (encodedOptions.length) {
            return endpoint + "?" + encodedOptions.join('&');
        }
        return endpoint;
    };
    return API;
}();

//# sourceMappingURL=api.js.map

/***/ }),

/***/ "../core/esm/basebackend.js":
/*!**********************************!*\
  !*** ../core/esm/basebackend.js ***!
  \**********************************/
/*! exports provided: BaseBackend */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "BaseBackend", function() { return BaseBackend; });
/* harmony import */ var _sentry_utils__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! @sentry/utils */ "../utils/esm/index.js");
/* harmony import */ var _transports_noop__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./transports/noop */ "../core/esm/transports/noop.js");


/**
 * This is the base implemention of a Backend.
 * @hidden
 */
var BaseBackend = /** @class */function () {
    /** Creates a new backend instance. */
    function BaseBackend(options) {
        this._options = options;
        if (!this._options.dsn) {
            _sentry_utils__WEBPACK_IMPORTED_MODULE_0__["logger"].warn('No DSN provided, backend will not do anything.');
        }
        this._transport = this._setupTransport();
    }
    /**
     * Sets up the transport so it can be used later to send requests.
     */
    BaseBackend.prototype._setupTransport = function () {
        return new _transports_noop__WEBPACK_IMPORTED_MODULE_1__["NoopTransport"]();
    };
    /**
     * @inheritDoc
     */
    BaseBackend.prototype.eventFromException = function (_exception, _hint) {
        throw new _sentry_utils__WEBPACK_IMPORTED_MODULE_0__["SentryError"]('Backend has to implement `eventFromException` method');
    };
    /**
     * @inheritDoc
     */
    BaseBackend.prototype.eventFromMessage = function (_message, _level, _hint) {
        throw new _sentry_utils__WEBPACK_IMPORTED_MODULE_0__["SentryError"]('Backend has to implement `eventFromMessage` method');
    };
    /**
     * @inheritDoc
     */
    BaseBackend.prototype.sendEvent = function (event) {
        this._transport.sendEvent(event).catch(function (reason) {
            _sentry_utils__WEBPACK_IMPORTED_MODULE_0__["logger"].error("Error while sending event: " + reason);
        });
    };
    /**
     * @inheritDoc
     */
    BaseBackend.prototype.getTransport = function () {
        return this._transport;
    };
    return BaseBackend;
}();

//# sourceMappingURL=basebackend.js.map

/***/ }),

/***/ "../core/esm/baseclient.js":
/*!*********************************!*\
  !*** ../core/esm/baseclient.js ***!
  \*********************************/
/*! exports provided: BaseClient */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "BaseClient", function() { return BaseClient; });
/* harmony import */ var tslib__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! tslib */ "../../node_modules/tslib/tslib.es6.js");
/* harmony import */ var _sentry_utils__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! @sentry/utils */ "../utils/esm/index.js");
/* harmony import */ var _dsn__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ./dsn */ "../core/esm/dsn.js");
/* harmony import */ var _integration__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! ./integration */ "../core/esm/integration.js");




/**
 * Base implementation for all JavaScript SDK clients.
 *
 * Call the constructor with the corresponding backend constructor and options
 * specific to the client subclass. To access these options later, use
 * {@link Client.getOptions}. Also, the Backend instance is available via
 * {@link Client.getBackend}.
 *
 * If a Dsn is specified in the options, it will be parsed and stored. Use
 * {@link Client.getDsn} to retrieve the Dsn at any moment. In case the Dsn is
 * invalid, the constructor will throw a {@link SentryException}. Note that
 * without a valid Dsn, the SDK will not send any events to Sentry.
 *
 * Before sending an event via the backend, it is passed through
 * {@link BaseClient.prepareEvent} to add SDK information and scope data
 * (breadcrumbs and context). To add more custom information, override this
 * method and extend the resulting prepared event.
 *
 * To issue automatically created events (e.g. via instrumentation), use
 * {@link Client.captureEvent}. It will prepare the event and pass it through
 * the callback lifecycle. To issue auto-breadcrumbs, use
 * {@link Client.addBreadcrumb}.
 *
 * @example
 * class NodeClient extends BaseClient<NodeBackend, NodeOptions> {
 *   public constructor(options: NodeOptions) {
 *     super(NodeBackend, options);
 *   }
 *
 *   // ...
 * }
 */
var BaseClient = /** @class */function () {
    /**
     * Initializes this client instance.
     *
     * @param backendClass A constructor function to create the backend.
     * @param options Options for the client.
     */
    function BaseClient(backendClass, options) {
        /** Is the client still processing a call? */
        this._processing = false;
        this._backend = new backendClass(options);
        this._options = options;
        if (options.dsn) {
            this._dsn = new _dsn__WEBPACK_IMPORTED_MODULE_2__["Dsn"](options.dsn);
        }
        this._integrations = Object(_integration__WEBPACK_IMPORTED_MODULE_3__["setupIntegrations"])(this._options);
    }
    /**
     * @inheritDoc
     */
    BaseClient.prototype.captureException = function (exception, hint, scope) {
        var _this = this;
        var eventId = hint && hint.event_id;
        this._processing = true;
        this._getBackend().eventFromException(exception, hint).then(function (event) {
            return _this._processEvent(event, hint, scope);
        }).then(function (finalEvent) {
            // We need to check for finalEvent in case beforeSend returned null
            eventId = finalEvent && finalEvent.event_id;
            _this._processing = false;
        }).catch(function (reason) {
            _sentry_utils__WEBPACK_IMPORTED_MODULE_1__["logger"].error(reason);
            _this._processing = false;
        });
        return eventId;
    };
    /**
     * @inheritDoc
     */
    BaseClient.prototype.captureMessage = function (message, level, hint, scope) {
        var _this = this;
        var eventId = hint && hint.event_id;
        this._processing = true;
        var promisedEvent = Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_1__["isPrimitive"])(message) ? this._getBackend().eventFromMessage("" + message, level, hint) : this._getBackend().eventFromException(message, hint);
        promisedEvent.then(function (event) {
            return _this._processEvent(event, hint, scope);
        }).then(function (finalEvent) {
            // We need to check for finalEvent in case beforeSend returned null
            eventId = finalEvent && finalEvent.event_id;
            _this._processing = false;
        }).catch(function (reason) {
            _sentry_utils__WEBPACK_IMPORTED_MODULE_1__["logger"].error(reason);
            _this._processing = false;
        });
        return eventId;
    };
    /**
     * @inheritDoc
     */
    BaseClient.prototype.captureEvent = function (event, hint, scope) {
        var _this = this;
        var eventId = hint && hint.event_id;
        this._processing = true;
        this._processEvent(event, hint, scope).then(function (finalEvent) {
            // We need to check for finalEvent in case beforeSend returned null
            eventId = finalEvent && finalEvent.event_id;
            _this._processing = false;
        }).catch(function (reason) {
            _sentry_utils__WEBPACK_IMPORTED_MODULE_1__["logger"].error(reason);
            _this._processing = false;
        });
        return eventId;
    };
    /**
     * @inheritDoc
     */
    BaseClient.prototype.getDsn = function () {
        return this._dsn;
    };
    /**
     * @inheritDoc
     */
    BaseClient.prototype.getOptions = function () {
        return this._options;
    };
    /**
     * @inheritDoc
     */
    BaseClient.prototype.flush = function (timeout) {
        var _this = this;
        return this._isClientProcessing(timeout).then(function (clientReady) {
            if (_this._processingInterval) {
                clearInterval(_this._processingInterval);
            }
            return _this._getBackend().getTransport().close(timeout).then(function (transportFlushed) {
                return clientReady && transportFlushed;
            });
        });
    };
    /**
     * @inheritDoc
     */
    BaseClient.prototype.close = function (timeout) {
        var _this = this;
        return this.flush(timeout).then(function (result) {
            _this.getOptions().enabled = false;
            return result;
        });
    };
    /**
     * @inheritDoc
     */
    BaseClient.prototype.getIntegrations = function () {
        return this._integrations || {};
    };
    /**
     * @inheritDoc
     */
    BaseClient.prototype.getIntegration = function (integration) {
        try {
            return this._integrations[integration.id] || null;
        } catch (_oO) {
            _sentry_utils__WEBPACK_IMPORTED_MODULE_1__["logger"].warn("Cannot retrieve integration " + integration.id + " from the current Client");
            return null;
        }
    };
    /** Waits for the client to be done with processing. */
    BaseClient.prototype._isClientProcessing = function (timeout) {
        var _this = this;
        return new Promise(function (resolve) {
            var ticked = 0;
            var tick = 1;
            if (_this._processingInterval) {
                clearInterval(_this._processingInterval);
            }
            _this._processingInterval = setInterval(function () {
                if (!_this._processing) {
                    resolve(true);
                } else {
                    ticked += tick;
                    if (timeout && ticked >= timeout) {
                        resolve(false);
                    }
                }
            }, tick);
        });
    };
    /** Returns the current backend. */
    BaseClient.prototype._getBackend = function () {
        return this._backend;
    };
    /** Determines whether this SDK is enabled and a valid Dsn is present. */
    BaseClient.prototype._isEnabled = function () {
        return this.getOptions().enabled !== false && this._dsn !== undefined;
    };
    /**
     * Adds common information to events.
     *
     * The information includes release and environment from `options`,
     * breadcrumbs and context (extra, tags and user) from the scope.
     *
     * Information that is already present in the event is never overwritten. For
     * nested objects, such as the context, keys are merged.
     *
     * @param event The original event.
     * @param hint May contain additional informartion about the original exception.
     * @param scope A scope containing event metadata.
     * @returns A new event with more information.
     */
    BaseClient.prototype._prepareEvent = function (event, scope, hint) {
        var _a = this.getOptions(),
            environment = _a.environment,
            release = _a.release,
            dist = _a.dist,
            _b = _a.maxValueLength,
            maxValueLength = _b === void 0 ? 250 : _b;
        var prepared = Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__assign"])({}, event);
        if (prepared.environment === undefined && environment !== undefined) {
            prepared.environment = environment;
        }
        if (prepared.release === undefined && release !== undefined) {
            prepared.release = release;
        }
        if (prepared.dist === undefined && dist !== undefined) {
            prepared.dist = dist;
        }
        if (prepared.message) {
            prepared.message = Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_1__["truncate"])(prepared.message, maxValueLength);
        }
        var exception = prepared.exception && prepared.exception.values && prepared.exception.values[0];
        if (exception && exception.value) {
            exception.value = Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_1__["truncate"])(exception.value, maxValueLength);
        }
        var request = prepared.request;
        if (request && request.url) {
            request.url = Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_1__["truncate"])(request.url, maxValueLength);
        }
        if (prepared.event_id === undefined) {
            prepared.event_id = Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_1__["uuid4"])();
        }
        this._addIntegrations(prepared.sdk);
        // We prepare the result here with a resolved Event.
        var result = _sentry_utils__WEBPACK_IMPORTED_MODULE_1__["SyncPromise"].resolve(prepared);
        // This should be the last thing called, since we want that
        // {@link Hub.addEventProcessor} gets the finished prepared event.
        if (scope) {
            // In case we have a hub we reassign it.
            result = scope.applyToEvent(prepared, hint);
        }
        return result;
    };
    /**
     * This function adds all used integrations to the SDK info in the event.
     * @param sdkInfo The sdkInfo of the event that will be filled with all integrations.
     */
    BaseClient.prototype._addIntegrations = function (sdkInfo) {
        var integrationsArray = Object.keys(this._integrations);
        if (sdkInfo && integrationsArray.length > 0) {
            sdkInfo.integrations = integrationsArray;
        }
    };
    /**
     * Processes an event (either error or message) and sends it to Sentry.
     *
     * This also adds breadcrumbs and context information to the event. However,
     * platform specific meta data (such as the User's IP address) must be added
     * by the SDK implementor.
     *
     *
     * @param event The event to send to Sentry.
     * @param hint May contain additional informartion about the original exception.
     * @param scope A scope containing event metadata.
     * @returns A SyncPromise that resolves with the event or rejects in case event was/will not be send.
     */
    BaseClient.prototype._processEvent = function (event, hint, scope) {
        var _this = this;
        var _a = this.getOptions(),
            beforeSend = _a.beforeSend,
            sampleRate = _a.sampleRate;
        if (!this._isEnabled()) {
            return _sentry_utils__WEBPACK_IMPORTED_MODULE_1__["SyncPromise"].reject('SDK not enabled, will not send event.');
        }
        // 1.0 === 100% events are sent
        // 0.0 === 0% events are sent
        if (typeof sampleRate === 'number' && Math.random() > sampleRate) {
            return _sentry_utils__WEBPACK_IMPORTED_MODULE_1__["SyncPromise"].reject('This event has been sampled, will not send event.');
        }
        return new _sentry_utils__WEBPACK_IMPORTED_MODULE_1__["SyncPromise"](function (resolve, reject) {
            _this._prepareEvent(event, scope, hint).then(function (prepared) {
                if (prepared === null) {
                    reject('An event processor returned null, will not send event.');
                    return;
                }
                var finalEvent = prepared;
                try {
                    var isInternalException = hint && hint.data && hint.data.__sentry__ === true;
                    if (isInternalException || !beforeSend) {
                        _this._getBackend().sendEvent(finalEvent);
                        resolve(finalEvent);
                        return;
                    }
                    var beforeSendResult = beforeSend(prepared, hint);
                    if (typeof beforeSendResult === 'undefined') {
                        _sentry_utils__WEBPACK_IMPORTED_MODULE_1__["logger"].error('`beforeSend` method has to return `null` or a valid event.');
                    } else if (Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_1__["isThenable"])(beforeSendResult)) {
                        _this._handleAsyncBeforeSend(beforeSendResult, resolve, reject);
                    } else {
                        finalEvent = beforeSendResult;
                        if (finalEvent === null) {
                            _sentry_utils__WEBPACK_IMPORTED_MODULE_1__["logger"].log('`beforeSend` returned `null`, will not send event.');
                            resolve(null);
                            return;
                        }
                        // From here on we are really async
                        _this._getBackend().sendEvent(finalEvent);
                        resolve(finalEvent);
                    }
                } catch (exception) {
                    _this.captureException(exception, {
                        data: {
                            __sentry__: true
                        },
                        originalException: exception
                    });
                    reject('`beforeSend` throw an error, will not send event.');
                }
            });
        });
    };
    /**
     * Resolves before send Promise and calls resolve/reject on parent SyncPromise.
     */
    BaseClient.prototype._handleAsyncBeforeSend = function (beforeSend, resolve, reject) {
        var _this = this;
        beforeSend.then(function (processedEvent) {
            if (processedEvent === null) {
                reject('`beforeSend` returned `null`, will not send event.');
                return;
            }
            // From here on we are really async
            _this._getBackend().sendEvent(processedEvent);
            resolve(processedEvent);
        }).catch(function (e) {
            reject("beforeSend rejected with " + e);
        });
    };
    return BaseClient;
}();

//# sourceMappingURL=baseclient.js.map

/***/ }),

/***/ "../core/esm/dsn.js":
/*!**************************!*\
  !*** ../core/esm/dsn.js ***!
  \**************************/
/*! exports provided: Dsn */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "Dsn", function() { return Dsn; });
/* harmony import */ var tslib__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! tslib */ "../../node_modules/tslib/tslib.es6.js");
/* harmony import */ var _sentry_utils__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! @sentry/utils */ "../utils/esm/index.js");


/** Regular expression used to parse a Dsn. */
var DSN_REGEX = /^(?:(\w+):)\/\/(?:(\w+-\w+)(?::(\w+))?(?::(.+))?(?::(\w+))@)([\w\.-]+)(?::(\d+))?/;
/** Error message */
var ERROR_MESSAGE = 'Invalid Dsn';
/** The Sentry Dsn, identifying a Sentry instance and project. */
var Dsn = /** @class */function () {
    /** Creates a new Dsn component */
    function Dsn(from) {
        if (typeof from === 'string') {
            this._fromString(from);
        } else {
            this._fromComponents(from);
        }
        this._validate();
    }
    /**
     * Renders the string representation of this Dsn.
     *
     * By default, this will render the public representation without the password
     * component. To get the deprecated private _representation, set `withPassword`
     * to true.
     *
     */
    Dsn.prototype.toString = function () {
        // tslint:disable-next-line:no-this-assignment
        var _a = this,
            host = _a.host,
            port = _a.port,
            protocol = _a.protocol;
        return protocol + "://" + ("" + host + (port ? ":" + port : '') + "/");
    };
    /** Parses a string into this Dsn. */
    Dsn.prototype._fromString = function (str) {
        var match = DSN_REGEX.exec(str);
        if (!match) {
            throw new _sentry_utils__WEBPACK_IMPORTED_MODULE_1__["SentryError"](ERROR_MESSAGE);
        }
        var _a = Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__read"])(match.slice(1), 7),
            protocol = _a[0],
            productKey = _a[1],
            _b = _a[2],
            user = _b === void 0 ? '10000' : _b,
            _c = _a[3],
            version = _c === void 0 ? '' : _c,
            plugin = _a[4],
            host = _a[5],
            _d = _a[6],
            port = _d === void 0 ? '' : _d;
        var appKey = '';
        var projectId = '';
        var split = productKey.split('-');
        if (split.length > 1) {
            projectId = split.pop();
            appKey = split.pop();
        }
        Object.assign(this, { host: host, version: version, appKey: appKey, projectId: projectId, port: port, protocol: protocol, user: user, plugin: plugin });
    };
    /** Maps Dsn components into this instance. */
    Dsn.prototype._fromComponents = function (components) {
        this.protocol = components.protocol;
        this.user = components.user || '10000';
        this.appKey = components.appKey;
        this.host = components.host;
        this.port = components.port || '';
        this.version = components.version || '';
        this.projectId = components.projectId;
        this.plugin = components.plugin;
    };
    /** Validates this Dsn and throws on error. */
    Dsn.prototype._validate = function () {
        var _this = this;
        ['protocol', 'user', 'host', 'projectId', 'appKey', 'plugin'].forEach(function (component) {
            if (!_this[component]) {
                throw new _sentry_utils__WEBPACK_IMPORTED_MODULE_1__["SentryError"](ERROR_MESSAGE);
            }
        });
        if (this.protocol !== 'http' && this.protocol !== 'https') {
            throw new _sentry_utils__WEBPACK_IMPORTED_MODULE_1__["SentryError"](ERROR_MESSAGE);
        }
        if (this.port && Number.isNaN(parseInt(this.port, 10))) {
            throw new _sentry_utils__WEBPACK_IMPORTED_MODULE_1__["SentryError"](ERROR_MESSAGE);
        }
    };
    return Dsn;
}();

//# sourceMappingURL=dsn.js.map

/***/ }),

/***/ "../core/esm/index.js":
/*!****************************!*\
  !*** ../core/esm/index.js ***!
  \****************************/
/*! exports provided: addBreadcrumb, captureException, captureEvent, captureMessage, configureScope, withScope, addGlobalEventProcessor, getCurrentHub, Hub, getHubFromCarrier, Scope, API, BaseClient, BaseBackend, Dsn, initAndBind, NoopTransport, Integrations */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var _sentry_minimal__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! @sentry/minimal */ "../minimal/esm/index.js");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "addBreadcrumb", function() { return _sentry_minimal__WEBPACK_IMPORTED_MODULE_0__["addBreadcrumb"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "captureException", function() { return _sentry_minimal__WEBPACK_IMPORTED_MODULE_0__["captureException"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "captureEvent", function() { return _sentry_minimal__WEBPACK_IMPORTED_MODULE_0__["captureEvent"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "captureMessage", function() { return _sentry_minimal__WEBPACK_IMPORTED_MODULE_0__["captureMessage"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "configureScope", function() { return _sentry_minimal__WEBPACK_IMPORTED_MODULE_0__["configureScope"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "withScope", function() { return _sentry_minimal__WEBPACK_IMPORTED_MODULE_0__["withScope"]; });

/* harmony import */ var _sentry_hub__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! @sentry/hub */ "../hub/esm/index.js");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "addGlobalEventProcessor", function() { return _sentry_hub__WEBPACK_IMPORTED_MODULE_1__["addGlobalEventProcessor"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "getCurrentHub", function() { return _sentry_hub__WEBPACK_IMPORTED_MODULE_1__["getCurrentHub"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "Hub", function() { return _sentry_hub__WEBPACK_IMPORTED_MODULE_1__["Hub"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "getHubFromCarrier", function() { return _sentry_hub__WEBPACK_IMPORTED_MODULE_1__["getHubFromCarrier"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "Scope", function() { return _sentry_hub__WEBPACK_IMPORTED_MODULE_1__["Scope"]; });

/* harmony import */ var _api__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ./api */ "../core/esm/api.js");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "API", function() { return _api__WEBPACK_IMPORTED_MODULE_2__["API"]; });

/* harmony import */ var _baseclient__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! ./baseclient */ "../core/esm/baseclient.js");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "BaseClient", function() { return _baseclient__WEBPACK_IMPORTED_MODULE_3__["BaseClient"]; });

/* harmony import */ var _basebackend__WEBPACK_IMPORTED_MODULE_4__ = __webpack_require__(/*! ./basebackend */ "../core/esm/basebackend.js");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "BaseBackend", function() { return _basebackend__WEBPACK_IMPORTED_MODULE_4__["BaseBackend"]; });

/* harmony import */ var _dsn__WEBPACK_IMPORTED_MODULE_5__ = __webpack_require__(/*! ./dsn */ "../core/esm/dsn.js");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "Dsn", function() { return _dsn__WEBPACK_IMPORTED_MODULE_5__["Dsn"]; });

/* harmony import */ var _sdk__WEBPACK_IMPORTED_MODULE_6__ = __webpack_require__(/*! ./sdk */ "../core/esm/sdk.js");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "initAndBind", function() { return _sdk__WEBPACK_IMPORTED_MODULE_6__["initAndBind"]; });

/* harmony import */ var _transports_noop__WEBPACK_IMPORTED_MODULE_7__ = __webpack_require__(/*! ./transports/noop */ "../core/esm/transports/noop.js");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "NoopTransport", function() { return _transports_noop__WEBPACK_IMPORTED_MODULE_7__["NoopTransport"]; });

/* harmony import */ var _integrations__WEBPACK_IMPORTED_MODULE_8__ = __webpack_require__(/*! ./integrations */ "../core/esm/integrations/index.js");
/* harmony reexport (module object) */ __webpack_require__.d(__webpack_exports__, "Integrations", function() { return _integrations__WEBPACK_IMPORTED_MODULE_8__; });










//# sourceMappingURL=index.js.map

/***/ }),

/***/ "../core/esm/integration.js":
/*!**********************************!*\
  !*** ../core/esm/integration.js ***!
  \**********************************/
/*! exports provided: installedIntegrations, getIntegrationsToSetup, setupIntegration, setupIntegrations */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "installedIntegrations", function() { return installedIntegrations; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "getIntegrationsToSetup", function() { return getIntegrationsToSetup; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "setupIntegration", function() { return setupIntegration; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "setupIntegrations", function() { return setupIntegrations; });
/* harmony import */ var tslib__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! tslib */ "../../node_modules/tslib/tslib.es6.js");
/* harmony import */ var _sentry_hub__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! @sentry/hub */ "../hub/esm/index.js");
/* harmony import */ var _sentry_utils__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! @sentry/utils */ "../utils/esm/index.js");



var installedIntegrations = [];
/** Gets integration to install */
function getIntegrationsToSetup(options) {
    var defaultIntegrations = options.defaultIntegrations && Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__spread"])(options.defaultIntegrations) || [];
    var userIntegrations = options.integrations;
    var integrations = [];
    if (Array.isArray(userIntegrations)) {
        var userIntegrationsNames_1 = userIntegrations.map(function (i) {
            return i.name;
        });
        var pickedIntegrationsNames_1 = [];
        // Leave only unique default integrations, that were not overridden with provided user integrations
        defaultIntegrations.forEach(function (defaultIntegration) {
            if (userIntegrationsNames_1.indexOf(defaultIntegration.name) === -1 && pickedIntegrationsNames_1.indexOf(defaultIntegration.name) === -1) {
                integrations.push(defaultIntegration);
                pickedIntegrationsNames_1.push(defaultIntegration.name);
            }
        });
        // Don't add same user integration twice
        userIntegrations.forEach(function (userIntegration) {
            if (pickedIntegrationsNames_1.indexOf(userIntegration.name) === -1) {
                integrations.push(userIntegration);
                pickedIntegrationsNames_1.push(userIntegration.name);
            }
        });
    } else if (typeof userIntegrations === 'function') {
        integrations = userIntegrations(defaultIntegrations);
        integrations = Array.isArray(integrations) ? integrations : [integrations];
    } else {
        return Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__spread"])(defaultIntegrations);
    }
    return integrations;
}
/** Setup given integration */
function setupIntegration(integration) {
    if (installedIntegrations.indexOf(integration.name) !== -1) {
        return;
    }
    integration.setupOnce(_sentry_hub__WEBPACK_IMPORTED_MODULE_1__["addGlobalEventProcessor"], _sentry_hub__WEBPACK_IMPORTED_MODULE_1__["getCurrentHub"]);
    installedIntegrations.push(integration.name);
    _sentry_utils__WEBPACK_IMPORTED_MODULE_2__["logger"].log("Integration installed: " + integration.name);
}
/**
 * Given a list of integration instances this installs them all. When `withDefaults` is set to `true` then all default
 * integrations are added unless they were already provided before.
 * @param integrations array of integration instances
 * @param withDefault should enable default integrations
 */
function setupIntegrations(options) {
    var integrations = {};
    getIntegrationsToSetup(options).forEach(function (integration) {
        integrations[integration.name] = integration;
        setupIntegration(integration);
    });
    return integrations;
}
//# sourceMappingURL=integration.js.map

/***/ }),

/***/ "../core/esm/integrations/functiontostring.js":
/*!****************************************************!*\
  !*** ../core/esm/integrations/functiontostring.js ***!
  \****************************************************/
/*! exports provided: FunctionToString */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "FunctionToString", function() { return FunctionToString; });
var originalFunctionToString;
/** Patch toString calls to return proper name for wrapped functions */
var FunctionToString = /** @class */function () {
    function FunctionToString() {
        /**
         * @inheritDoc
         */
        this.name = FunctionToString.id;
    }
    /**
     * @inheritDoc
     */
    FunctionToString.prototype.setupOnce = function () {
        originalFunctionToString = Function.prototype.toString;
        Function.prototype.toString = function () {
            var args = [];
            for (var _i = 0; _i < arguments.length; _i++) {
                args[_i] = arguments[_i];
            }
            var context = this.__sentry__ ? this.__sentry_original__ : this;
            // tslint:disable-next-line:no-unsafe-any
            return originalFunctionToString.apply(context, args);
        };
    };
    /**
     * @inheritDoc
     */
    FunctionToString.id = 'FunctionToString';
    return FunctionToString;
}();

//# sourceMappingURL=functiontostring.js.map

/***/ }),

/***/ "../core/esm/integrations/inboundfilters.js":
/*!**************************************************!*\
  !*** ../core/esm/integrations/inboundfilters.js ***!
  \**************************************************/
/*! exports provided: InboundFilters */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "InboundFilters", function() { return InboundFilters; });
/* harmony import */ var tslib__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! tslib */ "../../node_modules/tslib/tslib.es6.js");
/* harmony import */ var _sentry_hub__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! @sentry/hub */ "../hub/esm/index.js");
/* harmony import */ var _sentry_utils__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! @sentry/utils */ "../utils/esm/index.js");



// "Script error." is hard coded into browsers for errors that it can't read.
// this is the result of a script being pulled in from an external domain and CORS.
var DEFAULT_IGNORE_ERRORS = [/^Script error\.?$/, /^Javascript error: Script error\.? on line 0$/];
/** Inbound filters configurable by the user */
var InboundFilters = /** @class */function () {
    function InboundFilters(_options) {
        if (_options === void 0) {
            _options = {};
        }
        this._options = _options;
        /**
         * @inheritDoc
         */
        this.name = InboundFilters.id;
    }
    /**
     * @inheritDoc
     */
    InboundFilters.prototype.setupOnce = function () {
        Object(_sentry_hub__WEBPACK_IMPORTED_MODULE_1__["addGlobalEventProcessor"])(function (event) {
            var hub = Object(_sentry_hub__WEBPACK_IMPORTED_MODULE_1__["getCurrentHub"])();
            if (!hub) {
                return event;
            }
            var self = hub.getIntegration(InboundFilters);
            if (self) {
                var client = hub.getClient();
                var clientOptions = client ? client.getOptions() : {};
                var options = self._mergeOptions(clientOptions);
                if (self._shouldDropEvent(event, options)) {
                    return null;
                }
            }
            return event;
        });
    };
    /** JSDoc */
    InboundFilters.prototype._shouldDropEvent = function (event, options) {
        if (this._isSentryError(event, options)) {
            _sentry_utils__WEBPACK_IMPORTED_MODULE_2__["logger"].warn("Event dropped due to being internal Sentry Error.\nEvent: " + Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_2__["getEventDescription"])(event));
            return true;
        }
        if (this._isIgnoredError(event, options)) {
            _sentry_utils__WEBPACK_IMPORTED_MODULE_2__["logger"].warn("Event dropped due to being matched by `ignoreErrors` option.\nEvent: " + Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_2__["getEventDescription"])(event));
            return true;
        }
        if (this._isBlacklistedUrl(event, options)) {
            _sentry_utils__WEBPACK_IMPORTED_MODULE_2__["logger"].warn("Event dropped due to being matched by `blacklistUrls` option.\nEvent: " + Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_2__["getEventDescription"])(event) + ".\nUrl: " + this._getEventFilterUrl(event));
            return true;
        }
        if (!this._isWhitelistedUrl(event, options)) {
            _sentry_utils__WEBPACK_IMPORTED_MODULE_2__["logger"].warn("Event dropped due to not being matched by `whitelistUrls` option.\nEvent: " + Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_2__["getEventDescription"])(event) + ".\nUrl: " + this._getEventFilterUrl(event));
            return true;
        }
        return false;
    };
    /** JSDoc */
    InboundFilters.prototype._isSentryError = function (event, options) {
        if (options === void 0) {
            options = {};
        }
        if (!options.ignoreInternal) {
            return false;
        }
        try {
            // tslint:disable-next-line:no-unsafe-any
            return event.exception.values[0].type === 'SentryError';
        } catch (_oO) {
            return false;
        }
    };
    /** JSDoc */
    InboundFilters.prototype._isIgnoredError = function (event, options) {
        if (options === void 0) {
            options = {};
        }
        if (!options.ignoreErrors || !options.ignoreErrors.length) {
            return false;
        }
        return this._getPossibleEventMessages(event).some(function (message) {
            // Not sure why TypeScript complains here...
            return options.ignoreErrors.some(function (pattern) {
                return Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_2__["isMatchingPattern"])(message, pattern);
            });
        });
    };
    /** JSDoc */
    InboundFilters.prototype._isBlacklistedUrl = function (event, options) {
        if (options === void 0) {
            options = {};
        }
        // TODO: Use Glob instead?
        if (!options.blacklistUrls || !options.blacklistUrls.length) {
            return false;
        }
        var url = this._getEventFilterUrl(event);
        return !url ? false : options.blacklistUrls.some(function (pattern) {
            return Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_2__["isMatchingPattern"])(url, pattern);
        });
    };
    /** JSDoc */
    InboundFilters.prototype._isWhitelistedUrl = function (event, options) {
        if (options === void 0) {
            options = {};
        }
        // TODO: Use Glob instead?
        if (!options.whitelistUrls || !options.whitelistUrls.length) {
            return true;
        }
        var url = this._getEventFilterUrl(event);
        return !url ? true : options.whitelistUrls.some(function (pattern) {
            return Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_2__["isMatchingPattern"])(url, pattern);
        });
    };
    /** JSDoc */
    InboundFilters.prototype._mergeOptions = function (clientOptions) {
        if (clientOptions === void 0) {
            clientOptions = {};
        }
        return {
            blacklistUrls: Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__spread"])(this._options.blacklistUrls || [], clientOptions.blacklistUrls || []),
            ignoreErrors: Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__spread"])(this._options.ignoreErrors || [], clientOptions.ignoreErrors || [], DEFAULT_IGNORE_ERRORS),
            ignoreInternal: typeof this._options.ignoreInternal !== 'undefined' ? this._options.ignoreInternal : true,
            whitelistUrls: Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__spread"])(this._options.whitelistUrls || [], clientOptions.whitelistUrls || [])
        };
    };
    /** JSDoc */
    InboundFilters.prototype._getPossibleEventMessages = function (event) {
        if (event.message) {
            return [event.message];
        }
        if (event.exception) {
            try {
                // tslint:disable-next-line:no-unsafe-any
                var _a = event.exception.values[0],
                    type = _a.type,
                    value = _a.value;
                return ["" + value, type + ": " + value];
            } catch (oO) {
                _sentry_utils__WEBPACK_IMPORTED_MODULE_2__["logger"].error("Cannot extract message for event " + Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_2__["getEventDescription"])(event));
                return [];
            }
        }
        return [];
    };
    /** JSDoc */
    InboundFilters.prototype._getEventFilterUrl = function (event) {
        try {
            if (event.stacktrace) {
                // tslint:disable:no-unsafe-any
                var frames_1 = event.stacktrace.frames;
                return frames_1[frames_1.length - 1].filename;
            }
            if (event.exception) {
                // tslint:disable:no-unsafe-any
                var frames_2 = event.exception.values[0].stacktrace.frames;
                return frames_2[frames_2.length - 1].filename;
            }
            return null;
        } catch (oO) {
            _sentry_utils__WEBPACK_IMPORTED_MODULE_2__["logger"].error("Cannot extract url for event " + Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_2__["getEventDescription"])(event));
            return null;
        }
    };
    /**
     * @inheritDoc
     */
    InboundFilters.id = 'InboundFilters';
    return InboundFilters;
}();

//# sourceMappingURL=inboundfilters.js.map

/***/ }),

/***/ "../core/esm/integrations/index.js":
/*!*****************************************!*\
  !*** ../core/esm/integrations/index.js ***!
  \*****************************************/
/*! exports provided: FunctionToString, InboundFilters */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var _functiontostring__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./functiontostring */ "../core/esm/integrations/functiontostring.js");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "FunctionToString", function() { return _functiontostring__WEBPACK_IMPORTED_MODULE_0__["FunctionToString"]; });

/* harmony import */ var _inboundfilters__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./inboundfilters */ "../core/esm/integrations/inboundfilters.js");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "InboundFilters", function() { return _inboundfilters__WEBPACK_IMPORTED_MODULE_1__["InboundFilters"]; });



//# sourceMappingURL=index.js.map

/***/ }),

/***/ "../core/esm/sdk.js":
/*!**************************!*\
  !*** ../core/esm/sdk.js ***!
  \**************************/
/*! exports provided: initAndBind */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "initAndBind", function() { return initAndBind; });
/* harmony import */ var _sentry_hub__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! @sentry/hub */ "../hub/esm/index.js");
/* harmony import */ var _sentry_utils__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! @sentry/utils */ "../utils/esm/index.js");


/**
 * Internal function to create a new SDK client instance. The client is
 * installed and then bound to the current scope.
 *
 * @param clientClass The client class to instanciate.
 * @param options Options to pass to the client.
 */
function initAndBind(clientClass, options) {
    if (options.debug === true) {
        _sentry_utils__WEBPACK_IMPORTED_MODULE_1__["logger"].enable();
    }
    Object(_sentry_hub__WEBPACK_IMPORTED_MODULE_0__["getCurrentHub"])().bindClient(new clientClass(options));
}
//# sourceMappingURL=sdk.js.map

/***/ }),

/***/ "../core/esm/transports/noop.js":
/*!**************************************!*\
  !*** ../core/esm/transports/noop.js ***!
  \**************************************/
/*! exports provided: NoopTransport */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "NoopTransport", function() { return NoopTransport; });
/* harmony import */ var _sentry_types__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! @sentry/types */ "../types/esm/index.js");

/** Noop transport */
var NoopTransport = /** @class */function () {
    function NoopTransport() {}
    /**
     * @inheritDoc
     */
    NoopTransport.prototype.sendEvent = function (_) {
        return Promise.resolve({
            reason: "NoopTransport: Event has been skipped because no Dsn is configured.",
            status: _sentry_types__WEBPACK_IMPORTED_MODULE_0__["Status"].Skipped
        });
    };
    /**
     * @inheritDoc
     */
    NoopTransport.prototype.close = function (_) {
        return Promise.resolve(true);
    };
    return NoopTransport;
}();

//# sourceMappingURL=noop.js.map

/***/ }),

/***/ "../hub/esm/hub.js":
/*!*************************!*\
  !*** ../hub/esm/hub.js ***!
  \*************************/
/*! exports provided: API_VERSION, Hub, getMainCarrier, makeMain, getCurrentHub, getHubFromCarrier, setHubOnCarrier */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* WEBPACK VAR INJECTION */(function(module) {/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "API_VERSION", function() { return API_VERSION; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "Hub", function() { return Hub; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "getMainCarrier", function() { return getMainCarrier; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "makeMain", function() { return makeMain; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "getCurrentHub", function() { return getCurrentHub; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "getHubFromCarrier", function() { return getHubFromCarrier; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "setHubOnCarrier", function() { return setHubOnCarrier; });
/* harmony import */ var tslib__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! tslib */ "../../node_modules/tslib/tslib.es6.js");
/* harmony import */ var _sentry_utils__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! @sentry/utils */ "../utils/esm/index.js");
/* harmony import */ var _scope__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ./scope */ "../hub/esm/scope.js");



/**
 * API compatibility version of this hub.
 *
 * WARNING: This number should only be incresed when the global interface
 * changes a and new methods are introduced.
 *
 * @hidden
 */
var API_VERSION = 3;
/**
 * Default maximum number of breadcrumbs added to an event. Can be overwritten
 * with {@link Options.maxBreadcrumbs}.
 */
var DEFAULT_BREADCRUMBS = 30;
/**
 * Absolute maximum number of breadcrumbs added to an event. The
 * `maxBreadcrumbs` option cannot be higher than this value.
 */
var MAX_BREADCRUMBS = 100;
/**
 * @inheritDoc
 */
var Hub = /** @class */function () {
    /**
     * Creates a new instance of the hub, will push one {@link Layer} into the
     * internal stack on creation.
     *
     * @param client bound to the hub.
     * @param scope bound to the hub.
     * @param version number, higher number means higher priority.
     */
    function Hub(client, scope, _version) {
        if (scope === void 0) {
            scope = new _scope__WEBPACK_IMPORTED_MODULE_2__["Scope"]();
        }
        if (_version === void 0) {
            _version = API_VERSION;
        }
        this._version = _version;
        /** Is a {@link Layer}[] containing the client and scope */
        this._stack = [];
        this._stack.push({ client: client, scope: scope });
    }
    /**
     * Internal helper function to call a method on the top client if it exists.
     *
     * @param method The method to call on the client.
     * @param args Arguments to pass to the client function.
     */
    Hub.prototype._invokeClient = function (method) {
        var _a;
        var args = [];
        for (var _i = 1; _i < arguments.length; _i++) {
            args[_i - 1] = arguments[_i];
        }
        var top = this.getStackTop();
        if (top && top.client && top.client[method]) {
            (_a = top.client)[method].apply(_a, Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__spread"])(args, [top.scope]));
        }
    };
    /**
     * @inheritDoc
     */
    Hub.prototype.isOlderThan = function (version) {
        return this._version < version;
    };
    /**
     * @inheritDoc
     */
    Hub.prototype.bindClient = function (client) {
        var top = this.getStackTop();
        top.client = client;
    };
    /**
     * @inheritDoc
     */
    Hub.prototype.pushScope = function () {
        // We want to clone the content of prev scope
        var stack = this.getStack();
        var parentScope = stack.length > 0 ? stack[stack.length - 1].scope : undefined;
        var scope = _scope__WEBPACK_IMPORTED_MODULE_2__["Scope"].clone(parentScope);
        this.getStack().push({
            client: this.getClient(),
            scope: scope
        });
        return scope;
    };
    /**
     * @inheritDoc
     */
    Hub.prototype.popScope = function () {
        return this.getStack().pop() !== undefined;
    };
    /**
     * @inheritDoc
     */
    Hub.prototype.withScope = function (callback) {
        var scope = this.pushScope();
        try {
            callback(scope);
        } finally {
            this.popScope();
        }
    };
    /**
     * @inheritDoc
     */
    Hub.prototype.getClient = function () {
        return this.getStackTop().client;
    };
    /** Returns the scope of the top stack. */
    Hub.prototype.getScope = function () {
        return this.getStackTop().scope;
    };
    /** Returns the scope stack for domains or the process. */
    Hub.prototype.getStack = function () {
        return this._stack;
    };
    /** Returns the topmost scope layer in the order domain > local > process. */
    Hub.prototype.getStackTop = function () {
        return this._stack[this._stack.length - 1];
    };
    /**
     * @inheritDoc
     */
    Hub.prototype.captureException = function (exception, hint) {
        var eventId = this._lastEventId = Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_1__["uuid4"])();
        this._invokeClient('captureException', exception, Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__assign"])(Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__assign"])({}, hint), { event_id: eventId }));
        return eventId;
    };
    /**
     * @inheritDoc
     */
    Hub.prototype.captureMessage = function (message, level, hint) {
        var eventId = this._lastEventId = Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_1__["uuid4"])();
        this._invokeClient('captureMessage', message, level, Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__assign"])(Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__assign"])({}, hint), { event_id: eventId }));
        return eventId;
    };
    /**
     * @inheritDoc
     */
    Hub.prototype.captureEvent = function (event, hint) {
        var eventId = this._lastEventId = Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_1__["uuid4"])();
        this._invokeClient('captureEvent', event, Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__assign"])(Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__assign"])({}, hint), { event_id: eventId }));
        return eventId;
    };
    /**
     * @inheritDoc
     */
    Hub.prototype.lastEventId = function () {
        return this._lastEventId;
    };
    /**
     * @inheritDoc
     */
    Hub.prototype.addBreadcrumb = function (breadcrumb, hint) {
        var top = this.getStackTop();
        if (!top.scope || !top.client) {
            return;
        }
        var _a = top.client.getOptions && top.client.getOptions() || {},
            _b = _a.beforeBreadcrumb,
            beforeBreadcrumb = _b === void 0 ? null : _b,
            _c = _a.maxBreadcrumbs,
            maxBreadcrumbs = _c === void 0 ? DEFAULT_BREADCRUMBS : _c;
        if (maxBreadcrumbs <= 0) {
            return;
        }
        var timestamp = new Date().getTime() / 1000;
        var mergedBreadcrumb = Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__assign"])({ timestamp: timestamp }, breadcrumb);
        var finalBreadcrumb = beforeBreadcrumb ? Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_1__["consoleSandbox"])(function () {
            return beforeBreadcrumb(mergedBreadcrumb, hint);
        }) : mergedBreadcrumb;
        if (finalBreadcrumb === null) {
            return;
        }
        top.scope.addBreadcrumb(finalBreadcrumb, Math.min(maxBreadcrumbs, MAX_BREADCRUMBS));
    };
    /**
     * @inheritDoc
     */
    Hub.prototype.configureScope = function (callback) {
        var top = this.getStackTop();
        if (top.scope && top.client) {
            // TODO: freeze flag
            callback(top.scope);
        }
    };
    /**
     * @inheritDoc
     */
    Hub.prototype.run = function (callback) {
        var oldHub = makeMain(this);
        try {
            callback(this);
        } finally {
            makeMain(oldHub);
        }
    };
    /**
     * @inheritDoc
     */
    Hub.prototype.getIntegration = function (integration) {
        var client = this.getClient();
        if (!client) {
            return null;
        }
        try {
            return client.getIntegration(integration);
        } catch (_oO) {
            _sentry_utils__WEBPACK_IMPORTED_MODULE_1__["logger"].warn("Cannot retrieve integration " + integration.id + " from the current Hub");
            return null;
        }
    };
    /**
     * @inheritDoc
     */
    Hub.prototype.traceHeaders = function () {
        var top = this.getStackTop();
        if (top.scope && top.client) {
            var span = top.scope.getSpan();
            if (span) {
                return {
                    'sentry-trace': span.toTraceparent()
                };
            }
        }
        return {};
    };
    return Hub;
}();

/** Returns the global shim registry. */
function getMainCarrier() {
    var carrier = Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_1__["getGlobalObject"])();
    carrier.__SENTRY__ = carrier.__SENTRY__ || {
        hub: undefined
    };
    return carrier;
}
/**
 * Replaces the current main hub with the passed one on the global object
 *
 * @returns The old replaced hub
 */
function makeMain(hub) {
    var registry = getMainCarrier();
    var oldHub = getHubFromCarrier(registry);
    setHubOnCarrier(registry, hub);
    return oldHub;
}
/**
 * Returns the default hub instance.
 *
 * If a hub is already registered in the global carrier but this module
 * contains a more recent version, it replaces the registered version.
 * Otherwise, the currently registered hub will be returned.
 */
function getCurrentHub() {
    // Get main carrier (global for every environment)
    var registry = getMainCarrier();
    // If there's no hub, or its an old API, assign a new one
    if (!hasHubOnCarrier(registry) || getHubFromCarrier(registry).isOlderThan(API_VERSION)) {
        setHubOnCarrier(registry, new Hub());
    }
    // Prefer domains over global if they are there
    try {
        // We need to use `dynamicRequire` because `require` on it's own will be optimized by webpack.
        // We do not want this to happen, we need to try to `require` the domain node module and fail if we are in browser
        // for example so we do not have to shim it and use `getCurrentHub` universally.
        var domain = Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_1__["dynamicRequire"])(module, 'domain');
        var activeDomain = domain.active;
        // If there no active domain, just return global hub
        if (!activeDomain) {
            return getHubFromCarrier(registry);
        }
        // If there's no hub on current domain, or its an old API, assign a new one
        if (!hasHubOnCarrier(activeDomain) || getHubFromCarrier(activeDomain).isOlderThan(API_VERSION)) {
            var registryHubTopStack = getHubFromCarrier(registry).getStackTop();
            setHubOnCarrier(activeDomain, new Hub(registryHubTopStack.client, _scope__WEBPACK_IMPORTED_MODULE_2__["Scope"].clone(registryHubTopStack.scope)));
        }
        // Return hub that lives on a domain
        return getHubFromCarrier(activeDomain);
    } catch (_Oo) {
        // Return hub that lives on a global object
        return getHubFromCarrier(registry);
    }
}
/**
 * This will tell whether a carrier has a hub on it or not
 * @param carrier object
 */
function hasHubOnCarrier(carrier) {
    if (carrier && carrier.__SENTRY__ && carrier.__SENTRY__.hub) {
        return true;
    }
    return false;
}
/**
 * This will create a new {@link Hub} and add to the passed object on
 * __SENTRY__.hub.
 * @param carrier object
 * @hidden
 */
function getHubFromCarrier(carrier) {
    if (carrier && carrier.__SENTRY__ && carrier.__SENTRY__.hub) {
        return carrier.__SENTRY__.hub;
    }
    carrier.__SENTRY__ = carrier.__SENTRY__ || {};
    carrier.__SENTRY__.hub = new Hub();
    return carrier.__SENTRY__.hub;
}
/**
 * This will set passed {@link Hub} on the passed object's __SENTRY__.hub attribute
 * @param carrier object
 * @param hub Hub
 */
function setHubOnCarrier(carrier, hub) {
    if (!carrier) {
        return false;
    }
    carrier.__SENTRY__ = carrier.__SENTRY__ || {};
    carrier.__SENTRY__.hub = hub;
    return true;
}
//# sourceMappingURL=hub.js.map
/* WEBPACK VAR INJECTION */}.call(this, __webpack_require__(/*! ./../../../node_modules/webpack/buildin/harmony-module.js */ "../../node_modules/webpack/buildin/harmony-module.js")(module)))

/***/ }),

/***/ "../hub/esm/index.js":
/*!***************************!*\
  !*** ../hub/esm/index.js ***!
  \***************************/
/*! exports provided: addGlobalEventProcessor, Scope, getCurrentHub, getHubFromCarrier, getMainCarrier, Hub, makeMain, setHubOnCarrier, Span, TRACEPARENT_REGEXP */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var _scope__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./scope */ "../hub/esm/scope.js");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "addGlobalEventProcessor", function() { return _scope__WEBPACK_IMPORTED_MODULE_0__["addGlobalEventProcessor"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "Scope", function() { return _scope__WEBPACK_IMPORTED_MODULE_0__["Scope"]; });

/* harmony import */ var _hub__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./hub */ "../hub/esm/hub.js");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "getCurrentHub", function() { return _hub__WEBPACK_IMPORTED_MODULE_1__["getCurrentHub"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "getHubFromCarrier", function() { return _hub__WEBPACK_IMPORTED_MODULE_1__["getHubFromCarrier"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "getMainCarrier", function() { return _hub__WEBPACK_IMPORTED_MODULE_1__["getMainCarrier"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "Hub", function() { return _hub__WEBPACK_IMPORTED_MODULE_1__["Hub"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "makeMain", function() { return _hub__WEBPACK_IMPORTED_MODULE_1__["makeMain"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "setHubOnCarrier", function() { return _hub__WEBPACK_IMPORTED_MODULE_1__["setHubOnCarrier"]; });

/* harmony import */ var _span__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ./span */ "../hub/esm/span.js");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "Span", function() { return _span__WEBPACK_IMPORTED_MODULE_2__["Span"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "TRACEPARENT_REGEXP", function() { return _span__WEBPACK_IMPORTED_MODULE_2__["TRACEPARENT_REGEXP"]; });




//# sourceMappingURL=index.js.map

/***/ }),

/***/ "../hub/esm/scope.js":
/*!***************************!*\
  !*** ../hub/esm/scope.js ***!
  \***************************/
/*! exports provided: Scope, addGlobalEventProcessor */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "Scope", function() { return Scope; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "addGlobalEventProcessor", function() { return addGlobalEventProcessor; });
/* harmony import */ var tslib__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! tslib */ "../../node_modules/tslib/tslib.es6.js");
/* harmony import */ var _sentry_utils__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! @sentry/utils */ "../utils/esm/index.js");
/* harmony import */ var _span__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ./span */ "../hub/esm/span.js");



/**
 * Holds additional event information. {@link Scope.applyToEvent} will be
 * called by the client before an event will be sent.
 */
var Scope = /** @class */function () {
    function Scope() {
        /** Flag if notifiying is happening. */
        this._notifyingListeners = false;
        /** Callback for client to receive scope changes. */
        this._scopeListeners = [];
        /** Callback list that will be called after {@link applyToEvent}. */
        this._eventProcessors = [];
        /** Array of breadcrumbs. */
        this._breadcrumbs = [];
        /** User */
        this._user = {};
        /** Tags */
        this._tags = {};
        /** Extra */
        this._extra = {};
        /** Contexts */
        this._context = {};
    }
    /**
     * Add internal on change listener. Used for sub SDKs that need to store the scope.
     * @hidden
     */
    Scope.prototype.addScopeListener = function (callback) {
        this._scopeListeners.push(callback);
    };
    /**
     * @inheritDoc
     */
    Scope.prototype.addEventProcessor = function (callback) {
        this._eventProcessors.push(callback);
        return this;
    };
    /**
     * This will be called on every set call.
     */
    Scope.prototype._notifyScopeListeners = function () {
        var _this = this;
        if (!this._notifyingListeners) {
            this._notifyingListeners = true;
            setTimeout(function () {
                _this._scopeListeners.forEach(function (callback) {
                    callback(_this);
                });
                _this._notifyingListeners = false;
            });
        }
    };
    /**
     * This will be called after {@link applyToEvent} is finished.
     */
    Scope.prototype._notifyEventProcessors = function (processors, event, hint, index) {
        var _this = this;
        if (index === void 0) {
            index = 0;
        }
        return new _sentry_utils__WEBPACK_IMPORTED_MODULE_1__["SyncPromise"](function (resolve, reject) {
            var processor = processors[index];
            // tslint:disable-next-line:strict-type-predicates
            if (event === null || typeof processor !== 'function') {
                resolve(event);
            } else {
                var result = processor(Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__assign"])({}, event), hint);
                if (Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_1__["isThenable"])(result)) {
                    result.then(function (final) {
                        return _this._notifyEventProcessors(processors, final, hint, index + 1).then(resolve);
                    }).catch(reject);
                } else {
                    _this._notifyEventProcessors(processors, result, hint, index + 1).then(resolve).catch(reject);
                }
            }
        });
    };
    /**
     * @inheritDoc
     */
    Scope.prototype.setUser = function (user) {
        this._user = Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_1__["normalize"])(user);
        this._notifyScopeListeners();
        return this;
    };
    /**
     * @inheritDoc
     */
    Scope.prototype.setTags = function (tags) {
        this._tags = Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__assign"])(Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__assign"])({}, this._tags), Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_1__["normalize"])(tags));
        this._notifyScopeListeners();
        return this;
    };
    /**
     * @inheritDoc
     */
    Scope.prototype.setTag = function (key, value) {
        var _a;
        this._tags = Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__assign"])(Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__assign"])({}, this._tags), (_a = {}, _a[key] = Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_1__["normalize"])(value), _a));
        this._notifyScopeListeners();
        return this;
    };
    /**
     * @inheritDoc
     */
    Scope.prototype.setExtras = function (extra) {
        this._extra = Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__assign"])(Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__assign"])({}, this._extra), Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_1__["normalize"])(extra));
        this._notifyScopeListeners();
        return this;
    };
    /**
     * @inheritDoc
     */
    Scope.prototype.setExtra = function (key, extra) {
        var _a;
        this._extra = Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__assign"])(Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__assign"])({}, this._extra), (_a = {}, _a[key] = Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_1__["normalize"])(extra), _a));
        this._notifyScopeListeners();
        return this;
    };
    /**
     * @inheritDoc
     */
    Scope.prototype.setFingerprint = function (fingerprint) {
        this._fingerprint = Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_1__["normalize"])(fingerprint);
        this._notifyScopeListeners();
        return this;
    };
    /**
     * @inheritDoc
     */
    Scope.prototype.setLevel = function (level) {
        this._level = Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_1__["normalize"])(level);
        this._notifyScopeListeners();
        return this;
    };
    /**
     * @inheritDoc
     */
    Scope.prototype.setTransaction = function (transaction) {
        this._transaction = transaction;
        this._notifyScopeListeners();
        return this;
    };
    /**
     * @inheritDoc
     */
    Scope.prototype.setContext = function (name, context) {
        this._context[name] = context ? Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_1__["normalize"])(context) : undefined;
        this._notifyScopeListeners();
        return this;
    };
    /**
     * @inheritDoc
     */
    Scope.prototype.setSpan = function (span) {
        this._span = span;
        this._notifyScopeListeners();
        return this;
    };
    /**
     * @inheritDoc
     */
    Scope.prototype.startSpan = function () {
        var span = new _span__WEBPACK_IMPORTED_MODULE_2__["Span"]();
        this.setSpan(span);
        return span;
    };
    /**
     * Internal getter for Span, used in Hub.
     * @hidden
     */
    Scope.prototype.getSpan = function () {
        return this._span;
    };
    /**
     * Inherit values from the parent scope.
     * @param scope to clone.
     */
    Scope.clone = function (scope) {
        var newScope = new Scope();
        Object.assign(newScope, scope, {
            _scopeListeners: []
        });
        if (scope) {
            newScope._breadcrumbs = Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__spread"])(scope._breadcrumbs);
            newScope._tags = Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__assign"])({}, scope._tags);
            newScope._extra = Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__assign"])({}, scope._extra);
            newScope._context = Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__assign"])({}, scope._context);
            newScope._user = scope._user;
            newScope._level = scope._level;
            newScope._span = scope._span;
            newScope._transaction = scope._transaction;
            newScope._fingerprint = scope._fingerprint;
            newScope._eventProcessors = Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__spread"])(scope._eventProcessors);
        }
        return newScope;
    };
    /**
     * @inheritDoc
     */
    Scope.prototype.clear = function () {
        this._breadcrumbs = [];
        this._tags = {};
        this._extra = {};
        this._user = {};
        this._context = {};
        this._level = undefined;
        this._transaction = undefined;
        this._fingerprint = undefined;
        this._span = undefined;
        this._notifyScopeListeners();
        return this;
    };
    /**
     * @inheritDoc
     */
    Scope.prototype.addBreadcrumb = function (breadcrumb, maxBreadcrumbs) {
        var timestamp = new Date().getTime() / 1000;
        var mergedBreadcrumb = Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__assign"])({ timestamp: timestamp }, breadcrumb);
        this._breadcrumbs = maxBreadcrumbs !== undefined && maxBreadcrumbs >= 0 ? Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__spread"])(this._breadcrumbs, [Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_1__["normalize"])(mergedBreadcrumb)]).slice(-maxBreadcrumbs) : Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__spread"])(this._breadcrumbs, [Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_1__["normalize"])(mergedBreadcrumb)]);
        this._notifyScopeListeners();
        return this;
    };
    /**
     * @inheritDoc
     */
    Scope.prototype.clearBreadcrumbs = function () {
        this._breadcrumbs = [];
        this._notifyScopeListeners();
        return this;
    };
    /**
     * Applies fingerprint from the scope to the event if there's one,
     * uses message if there's one instead or get rid of empty fingerprint
     */
    Scope.prototype._applyFingerprint = function (event) {
        // Make sure it's an array first and we actually have something in place
        event.fingerprint = event.fingerprint ? Array.isArray(event.fingerprint) ? event.fingerprint : [event.fingerprint] : [];
        // If we have something on the scope, then merge it with event
        if (this._fingerprint) {
            event.fingerprint = event.fingerprint.concat(this._fingerprint);
        }
        // If we have no data at all, remove empty array default
        if (event.fingerprint && !event.fingerprint.length) {
            delete event.fingerprint;
        }
    };
    /**
     * Applies the current context and fingerprint to the event.
     * Note that breadcrumbs will be added by the client.
     * Also if the event has already breadcrumbs on it, we do not merge them.
     * @param event Event
     * @param hint May contain additional informartion about the original exception.
     * @param maxBreadcrumbs number of max breadcrumbs to merged into event.
     * @hidden
     */
    Scope.prototype.applyToEvent = function (event, hint) {
        if (this._extra && Object.keys(this._extra).length) {
            event.extra = Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__assign"])(Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__assign"])({}, this._extra), event.extra);
        }
        if (this._tags && Object.keys(this._tags).length) {
            event.tags = Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__assign"])(Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__assign"])({}, this._tags), event.tags);
        }
        if (this._user && Object.keys(this._user).length) {
            event.user = Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__assign"])(Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__assign"])({}, this._user), event.user);
        }
        if (this._context && Object.keys(this._context).length) {
            event.contexts = Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__assign"])(Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__assign"])({}, this._context), event.contexts);
        }
        if (this._level) {
            event.level = this._level;
        }
        if (this._transaction) {
            event.transaction = this._transaction;
        }
        if (this._span) {
            event.contexts = event.contexts || {};
            event.contexts.trace = this._span;
        }
        this._applyFingerprint(event);
        event.breadcrumbs = Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__spread"])(event.breadcrumbs || [], this._breadcrumbs);
        event.breadcrumbs = event.breadcrumbs.length > 0 ? event.breadcrumbs : undefined;
        return this._notifyEventProcessors(Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__spread"])(getGlobalEventProcessors(), this._eventProcessors), event, hint);
    };
    return Scope;
}();

/**
 * Retruns the global event processors.
 */
function getGlobalEventProcessors() {
    var global = Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_1__["getGlobalObject"])();
    global.__SENTRY__ = global.__SENTRY__ || {};
    global.__SENTRY__.globalEventProcessors = global.__SENTRY__.globalEventProcessors || [];
    return global.__SENTRY__.globalEventProcessors;
}
/**
 * Add a EventProcessor to be kept globally.
 * @param callback EventProcessor to add
 */
function addGlobalEventProcessor(callback) {
    getGlobalEventProcessors().push(callback);
}
//# sourceMappingURL=scope.js.map

/***/ }),

/***/ "../hub/esm/span.js":
/*!**************************!*\
  !*** ../hub/esm/span.js ***!
  \**************************/
/*! exports provided: TRACEPARENT_REGEXP, Span */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "TRACEPARENT_REGEXP", function() { return TRACEPARENT_REGEXP; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "Span", function() { return Span; });
/* harmony import */ var _sentry_utils__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! @sentry/utils */ "../utils/esm/index.js");

var TRACEPARENT_REGEXP = /([0-9a-f]{2})-([0-9a-f]{32})-([0-9a-f]{16})-([0-9a-f]{2})/;
/**
 * Span containg all data about a span
 */
var Span = /** @class */function () {
    function Span(_traceId, _spanId, _recorded, _parent) {
        if (_traceId === void 0) {
            _traceId = Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_0__["uuid4"])();
        }
        if (_spanId === void 0) {
            _spanId = Object(_sentry_utils__WEBPACK_IMPORTED_MODULE_0__["uuid4"])().substring(16);
        }
        if (_recorded === void 0) {
            _recorded = false;
        }
        this._traceId = _traceId;
        this._spanId = _spanId;
        this._recorded = _recorded;
        this._parent = _parent;
    }
    /**
     * Continues a trace
     * @param traceparent Traceparent string
     */
    Span.fromTraceparent = function (traceparent) {
        var matches = traceparent.match(TRACEPARENT_REGEXP);
        if (matches) {
            var parent_1 = new Span(matches[2], matches[3], matches[4] === '01' ? true : false);
            return new Span(matches[2], undefined, undefined, parent_1);
        }
        return undefined;
    };
    /**
     * @inheritDoc
     */
    Span.prototype.toTraceparent = function () {
        return "00-" + this._traceId + "-" + this._spanId + "-" + (this._recorded ? '01' : '00');
    };
    /**
     * @inheritDoc
     */
    Span.prototype.toJSON = function () {
        return {
            parent: this._parent && this._parent.toJSON() || undefined,
            span_id: this._spanId,
            trace_id: this._traceId
        };
    };
    return Span;
}();

//# sourceMappingURL=span.js.map

/***/ }),

/***/ "../minimal/esm/index.js":
/*!*******************************!*\
  !*** ../minimal/esm/index.js ***!
  \*******************************/
/*! exports provided: captureException, captureMessage, captureEvent, addBreadcrumb, configureScope, withScope, _callOnClient */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "captureException", function() { return captureException; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "captureMessage", function() { return captureMessage; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "captureEvent", function() { return captureEvent; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "addBreadcrumb", function() { return addBreadcrumb; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "configureScope", function() { return configureScope; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "withScope", function() { return withScope; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "_callOnClient", function() { return _callOnClient; });
/* harmony import */ var tslib__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! tslib */ "../../node_modules/tslib/tslib.es6.js");
/* harmony import */ var _sentry_hub__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! @sentry/hub */ "../hub/esm/index.js");


/**
 * This calls a function on the current hub.
 * @param method function to call on hub.
 * @param args to pass to function.
 */
function callOnHub(method) {
    var args = [];
    for (var _i = 1; _i < arguments.length; _i++) {
        args[_i - 1] = arguments[_i];
    }
    var hub = Object(_sentry_hub__WEBPACK_IMPORTED_MODULE_1__["getCurrentHub"])();
    if (hub && hub[method]) {
        // tslint:disable-next-line:no-unsafe-any
        return hub[method].apply(hub, Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__spread"])(args));
    }
    throw new Error("No hub defined or " + method + " was not found on the hub, please open a bug report.");
}
/**
 * Captures an exception event and sends it to Sentry.
 *
 * @param exception An exception-like object.
 * @returns The generated eventId.
 */
function captureException(exception) {
    var syntheticException;
    try {
        throw new Error('Sentry syntheticException');
    } catch (exception) {
        syntheticException = exception;
    }
    return callOnHub('captureException', exception, {
        originalException: exception,
        syntheticException: syntheticException
    });
}
/**
 * Captures a message event and sends it to Sentry.
 *
 * @param message The message to send to Sentry.
 * @param level Define the level of the message.
 * @returns The generated eventId.
 */
function captureMessage(message, level) {
    var syntheticException;
    try {
        throw new Error(message);
    } catch (exception) {
        syntheticException = exception;
    }
    return callOnHub('captureMessage', message, level, {
        originalException: message,
        syntheticException: syntheticException
    });
}
/**
 * Captures a manually created event and sends it to Sentry.
 *
 * @param event The event to send to Sentry.
 * @returns The generated eventId.
 */
function captureEvent(event) {
    return callOnHub('captureEvent', event);
}
/**
 * Records a new breadcrumb which will be attached to future events.
 *
 * Breadcrumbs will be added to subsequent events to provide more context on
 * user's actions prior to an error or crash.
 *
 * @param breadcrumb The breadcrumb to record.
 */
function addBreadcrumb(breadcrumb) {
    callOnHub('addBreadcrumb', breadcrumb);
}
/**
 * Callback to set context information onto the scope.
 * @param callback Callback function that receives Scope.
 */
function configureScope(callback) {
    callOnHub('configureScope', callback);
}
/**
 * Creates a new scope with and executes the given operation within.
 * The scope is automatically removed once the operation
 * finishes or throws.
 *
 * This is essentially a convenience function for:
 *
 *     pushScope();
 *     callback();
 *     popScope();
 *
 * @param callback that will be enclosed into push/popScope.
 */
function withScope(callback) {
    callOnHub('withScope', callback);
}
/**
 * Calls a function on the latest client. Use this with caution, it's meant as
 * in "internal" helper so we don't need to expose every possible function in
 * the shim. It is not guaranteed that the client actually implements the
 * function.
 *
 * @param method The method to call on the client/client.
 * @param args Arguments to pass to the client/fontend.
 */
function _callOnClient(method) {
    var args = [];
    for (var _i = 1; _i < arguments.length; _i++) {
        args[_i - 1] = arguments[_i];
    }
    callOnHub.apply(void 0, Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__spread"])(['_invokeClient', method], args));
}
//# sourceMappingURL=index.js.map

/***/ }),

/***/ "../types/esm/index.js":
/*!*****************************!*\
  !*** ../types/esm/index.js ***!
  \*****************************/
/*! exports provided: LogLevel, Severity, Status */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var _loglevel__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./loglevel */ "../types/esm/loglevel.js");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "LogLevel", function() { return _loglevel__WEBPACK_IMPORTED_MODULE_0__["LogLevel"]; });

/* harmony import */ var _severity__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./severity */ "../types/esm/severity.js");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "Severity", function() { return _severity__WEBPACK_IMPORTED_MODULE_1__["Severity"]; });

/* harmony import */ var _status__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ./status */ "../types/esm/status.js");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "Status", function() { return _status__WEBPACK_IMPORTED_MODULE_2__["Status"]; });




//# sourceMappingURL=index.js.map

/***/ }),

/***/ "../types/esm/loglevel.js":
/*!********************************!*\
  !*** ../types/esm/loglevel.js ***!
  \********************************/
/*! exports provided: LogLevel */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "LogLevel", function() { return LogLevel; });
/** Console logging verbosity for the SDK. */
var LogLevel;
(function (LogLevel) {
    /** No logs will be generated. */
    LogLevel[LogLevel["None"] = 0] = "None";
    /** Only SDK internal errors will be logged. */
    LogLevel[LogLevel["Error"] = 1] = "Error";
    /** Information useful for debugging the SDK will be logged. */
    LogLevel[LogLevel["Debug"] = 2] = "Debug";
    /** All SDK actions will be logged. */
    LogLevel[LogLevel["Verbose"] = 3] = "Verbose";
})(LogLevel || (LogLevel = {}));
//# sourceMappingURL=loglevel.js.map

/***/ }),

/***/ "../types/esm/severity.js":
/*!********************************!*\
  !*** ../types/esm/severity.js ***!
  \********************************/
/*! exports provided: Severity */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "Severity", function() { return Severity; });
/** JSDoc */
var Severity;
(function (Severity) {
    /** JSDoc */
    Severity["Fatal"] = "fatal";
    /** JSDoc */
    Severity["Error"] = "error";
    /** JSDoc */
    Severity["Warning"] = "warning";
    /** JSDoc */
    Severity["Log"] = "log";
    /** JSDoc */
    Severity["Info"] = "info";
    /** JSDoc */
    Severity["Debug"] = "debug";
    /** JSDoc */
    Severity["Critical"] = "critical";
})(Severity || (Severity = {}));
// tslint:disable:completed-docs
// tslint:disable:no-unnecessary-qualifier no-namespace
(function (Severity) {
    /**
     * Converts a string-based level into a {@link Severity}.
     *
     * @param level string representation of Severity
     * @returns Severity
     */
    function fromString(level) {
        switch (level) {
            case 'debug':
                return Severity.Debug;
            case 'info':
                return Severity.Info;
            case 'warn':
            case 'warning':
                return Severity.Warning;
            case 'error':
                return Severity.Error;
            case 'fatal':
                return Severity.Fatal;
            case 'critical':
                return Severity.Critical;
            case 'log':
            default:
                return Severity.Log;
        }
    }
    Severity.fromString = fromString;
})(Severity || (Severity = {}));
//# sourceMappingURL=severity.js.map

/***/ }),

/***/ "../types/esm/status.js":
/*!******************************!*\
  !*** ../types/esm/status.js ***!
  \******************************/
/*! exports provided: Status */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "Status", function() { return Status; });
/** The status of an event. */
var Status;
(function (Status) {
    /** The status could not be determined. */
    Status["Unknown"] = "unknown";
    /** The event was skipped due to configuration or callbacks. */
    Status["Skipped"] = "skipped";
    /** The event was sent to Sentry successfully. */
    Status["Success"] = "success";
    /** The client is currently rate limited and will try again later. */
    Status["RateLimit"] = "rate_limit";
    /** The event could not be processed. */
    Status["Invalid"] = "invalid";
    /** A server-side error ocurred during submission. */
    Status["Failed"] = "failed";
})(Status || (Status = {}));
// tslint:disable:completed-docs
// tslint:disable:no-unnecessary-qualifier no-namespace
(function (Status) {
    /**
     * Converts a HTTP status code into a {@link Status}.
     *
     * @param code The HTTP response status code.
     * @returns The send status or {@link Status.Unknown}.
     */
    function fromHttpCode(code) {
        if (code >= 200 && code < 300) {
            return Status.Success;
        }
        if (code === 429) {
            return Status.RateLimit;
        }
        if (code >= 400 && code < 500) {
            return Status.Invalid;
        }
        if (code >= 500) {
            return Status.Failed;
        }
        return Status.Unknown;
    }
    Status.fromHttpCode = fromHttpCode;
})(Status || (Status = {}));
//# sourceMappingURL=status.js.map

/***/ }),

/***/ "../utils/esm/async.js":
/*!*****************************!*\
  !*** ../utils/esm/async.js ***!
  \*****************************/
/*! exports provided: forget, filterAsync */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "forget", function() { return forget; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "filterAsync", function() { return filterAsync; });
/* harmony import */ var tslib__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! tslib */ "../../node_modules/tslib/tslib.es6.js");

/**
 * Consumes the promise and logs the error when it rejects.
 * @param promise A promise to forget.
 */
function forget(promise) {
    promise.catch(function (e) {
        // TODO: Use a better logging mechanism
        console.error(e);
    });
}
/**
 * Helper to filter an array with asynchronous callbacks.
 *
 * @param array An array containing items to filter.
 * @param predicate An async predicate evaluated on every item.
 * @param thisArg Optional value passed as "this" into the callback.
 * @returns An array containing only values where the callback returned true.
 */
function filterAsync(array, predicate, thisArg) {
    return Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__awaiter"])(this, void 0, void 0, function () {
        var verdicts;
        return Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__generator"])(this, function (_a) {
            switch (_a.label) {
                case 0:
                    return [4 /*yield*/, Promise.all(array.map(predicate, thisArg))];
                case 1:
                    verdicts = _a.sent();
                    return [2 /*return*/, array.filter(function (_, index) {
                        return verdicts[index];
                    })];
            }
        });
    });
}
//# sourceMappingURL=async.js.map

/***/ }),

/***/ "../utils/esm/error.js":
/*!*****************************!*\
  !*** ../utils/esm/error.js ***!
  \*****************************/
/*! exports provided: SentryError */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "SentryError", function() { return SentryError; });
/* harmony import */ var tslib__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! tslib */ "../../node_modules/tslib/tslib.es6.js");

/** An error emitted by Sentry SDKs and related utilities. */
var SentryError = /** @class */function (_super) {
    Object(tslib__WEBPACK_IMPORTED_MODULE_0__["__extends"])(SentryError, _super);
    function SentryError(message) {
        var _newTarget = this.constructor;
        var _this = _super.call(this, message) || this;
        _this.message = message;
        // tslint:disable:no-unsafe-any
        _this.name = _newTarget.prototype.constructor.name;
        Object.setPrototypeOf(_this, _newTarget.prototype);
        return _this;
    }
    return SentryError;
}(Error);

//# sourceMappingURL=error.js.map

/***/ }),

/***/ "../utils/esm/index.js":
/*!*****************************!*\
  !*** ../utils/esm/index.js ***!
  \*****************************/
/*! exports provided: forget, filterAsync, SentryError, isError, isErrorEvent, isDOMError, isDOMException, isString, isPrimitive, isPlainObject, isRegExp, isThenable, isSyntheticEvent, logger, Memo, dynamicRequire, isNodeEnv, getGlobalObject, uuid4, parseUrl, getEventDescription, consoleSandbox, addExceptionTypeValue, fill, urlEncode, normalizeToSize, walk, normalize, resolve, relative, normalizePath, isAbsolute, join, dirname, basename, PromiseBuffer, truncate, snipLine, safeJoin, keysToEventMessage, isMatchingPattern, supportsErrorEvent, supportsDOMError, supportsDOMException, supportsFetch, supportsNativeFetch, supportsReportingObserver, supportsReferrerPolicy, supportsHistory, SyncPromise */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var _async__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./async */ "../utils/esm/async.js");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "forget", function() { return _async__WEBPACK_IMPORTED_MODULE_0__["forget"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "filterAsync", function() { return _async__WEBPACK_IMPORTED_MODULE_0__["filterAsync"]; });

/* harmony import */ var _error__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./error */ "../utils/esm/error.js");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "SentryError", function() { return _error__WEBPACK_IMPORTED_MODULE_1__["SentryError"]; });

/* harmony import */ var _is__WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ./is */ "../utils/esm/is.js");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "isError", function() { return _is__WEBPACK_IMPORTED_MODULE_2__["isError"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "isErrorEvent", function() { return _is__WEBPACK_IMPORTED_MODULE_2__["isErrorEvent"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "isDOMError", function() { return _is__WEBPACK_IMPORTED_MODULE_2__["isDOMError"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "isDOMException", function() { return _is__WEBPACK_IMPORTED_MODULE_2__["isDOMException"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "isString", function() { return _is__WEBPACK_IMPORTED_MODULE_2__["isString"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "isPrimitive", function() { return _is__WEBPACK_IMPORTED_MODULE_2__["isPrimitive"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "isPlainObject", function() { return _is__WEBPACK_IMPORTED_MODULE_2__["isPlainObject"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "isRegExp", function() { return _is__WEBPACK_IMPORTED_MODULE_2__["isRegExp"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "isThenable", function() { return _is__WEBPACK_IMPORTED_MODULE_2__["isThenable"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "isSyntheticEvent", function() { return _is__WEBPACK_IMPORTED_MODULE_2__["isSyntheticEvent"]; });

/* harmony import */ var _logger__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! ./logger */ "../utils/esm/logger.js");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "logger", function() { return _logger__WEBPACK_IMPORTED_MODULE_3__["logger"]; });

/* harmony import */ var _memo__WEBPACK_IMPORTED_MODULE_4__ = __webpack_require__(/*! ./memo */ "../utils/esm/memo.js");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "Memo", function() { return _memo__WEBPACK_IMPORTED_MODULE_4__["Memo"]; });

/* harmony import */ var _misc__WEBPACK_IMPORTED_MODULE_5__ = __webpack_require__(/*! ./misc */ "../utils/esm/misc.js");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "dynamicRequire", function() { return _misc__WEBPACK_IMPORTED_MODULE_5__["dynamicRequire"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "isNodeEnv", function() { return _misc__WEBPACK_IMPORTED_MODULE_5__["isNodeEnv"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "getGlobalObject", function() { return _misc__WEBPACK_IMPORTED_MODULE_5__["getGlobalObject"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "uuid4", function() { return _misc__WEBPACK_IMPORTED_MODULE_5__["uuid4"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "parseUrl", function() { return _misc__WEBPACK_IMPORTED_MODULE_5__["parseUrl"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "getEventDescription", function() { return _misc__WEBPACK_IMPORTED_MODULE_5__["getEventDescription"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "consoleSandbox", function() { return _misc__WEBPACK_IMPORTED_MODULE_5__["consoleSandbox"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "addExceptionTypeValue", function() { return _misc__WEBPACK_IMPORTED_MODULE_5__["addExceptionTypeValue"]; });

/* harmony import */ var _object__WEBPACK_IMPORTED_MODULE_6__ = __webpack_require__(/*! ./object */ "../utils/esm/object.js");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "fill", function() { return _object__WEBPACK_IMPORTED_MODULE_6__["fill"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "urlEncode", function() { return _object__WEBPACK_IMPORTED_MODULE_6__["urlEncode"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "normalizeToSize", function() { return _object__WEBPACK_IMPORTED_MODULE_6__["normalizeToSize"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "walk", function() { return _object__WEBPACK_IMPORTED_MODULE_6__["walk"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "normalize", function() { return _object__WEBPACK_IMPORTED_MODULE_6__["normalize"]; });

/* harmony import */ var _path__WEBPACK_IMPORTED_MODULE_7__ = __webpack_require__(/*! ./path */ "../utils/esm/path.js");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "resolve", function() { return _path__WEBPACK_IMPORTED_MODULE_7__["resolve"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "relative", function() { return _path__WEBPACK_IMPORTED_MODULE_7__["relative"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "normalizePath", function() { return _path__WEBPACK_IMPORTED_MODULE_7__["normalizePath"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "isAbsolute", function() { return _path__WEBPACK_IMPORTED_MODULE_7__["isAbsolute"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "join", function() { return _path__WEBPACK_IMPORTED_MODULE_7__["join"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "dirname", function() { return _path__WEBPACK_IMPORTED_MODULE_7__["dirname"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "basename", function() { return _path__WEBPACK_IMPORTED_MODULE_7__["basename"]; });

/* harmony import */ var _promisebuffer__WEBPACK_IMPORTED_MODULE_8__ = __webpack_require__(/*! ./promisebuffer */ "../utils/esm/promisebuffer.js");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "PromiseBuffer", function() { return _promisebuffer__WEBPACK_IMPORTED_MODULE_8__["PromiseBuffer"]; });

/* harmony import */ var _string__WEBPACK_IMPORTED_MODULE_9__ = __webpack_require__(/*! ./string */ "../utils/esm/string.js");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "truncate", function() { return _string__WEBPACK_IMPORTED_MODULE_9__["truncate"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "snipLine", function() { return _string__WEBPACK_IMPORTED_MODULE_9__["snipLine"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "safeJoin", function() { return _string__WEBPACK_IMPORTED_MODULE_9__["safeJoin"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "keysToEventMessage", function() { return _string__WEBPACK_IMPORTED_MODULE_9__["keysToEventMessage"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "isMatchingPattern", function() { return _string__WEBPACK_IMPORTED_MODULE_9__["isMatchingPattern"]; });

/* harmony import */ var _supports__WEBPACK_IMPORTED_MODULE_10__ = __webpack_require__(/*! ./supports */ "../utils/esm/supports.js");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "supportsErrorEvent", function() { return _supports__WEBPACK_IMPORTED_MODULE_10__["supportsErrorEvent"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "supportsDOMError", function() { return _supports__WEBPACK_IMPORTED_MODULE_10__["supportsDOMError"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "supportsDOMException", function() { return _supports__WEBPACK_IMPORTED_MODULE_10__["supportsDOMException"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "supportsFetch", function() { return _supports__WEBPACK_IMPORTED_MODULE_10__["supportsFetch"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "supportsNativeFetch", function() { return _supports__WEBPACK_IMPORTED_MODULE_10__["supportsNativeFetch"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "supportsReportingObserver", function() { return _supports__WEBPACK_IMPORTED_MODULE_10__["supportsReportingObserver"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "supportsReferrerPolicy", function() { return _supports__WEBPACK_IMPORTED_MODULE_10__["supportsReferrerPolicy"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "supportsHistory", function() { return _supports__WEBPACK_IMPORTED_MODULE_10__["supportsHistory"]; });

/* harmony import */ var _syncpromise__WEBPACK_IMPORTED_MODULE_11__ = __webpack_require__(/*! ./syncpromise */ "../utils/esm/syncpromise.js");
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "SyncPromise", function() { return _syncpromise__WEBPACK_IMPORTED_MODULE_11__["SyncPromise"]; });













//# sourceMappingURL=index.js.map

/***/ }),

/***/ "../utils/esm/is.js":
/*!**************************!*\
  !*** ../utils/esm/is.js ***!
  \**************************/
/*! exports provided: isError, isErrorEvent, isDOMError, isDOMException, isString, isPrimitive, isPlainObject, isRegExp, isThenable, isSyntheticEvent */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "isError", function() { return isError; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "isErrorEvent", function() { return isErrorEvent; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "isDOMError", function() { return isDOMError; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "isDOMException", function() { return isDOMException; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "isString", function() { return isString; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "isPrimitive", function() { return isPrimitive; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "isPlainObject", function() { return isPlainObject; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "isRegExp", function() { return isRegExp; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "isThenable", function() { return isThenable; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "isSyntheticEvent", function() { return isSyntheticEvent; });
/**
 * Checks whether given value's type is one of a few Error or Error-like
 * {@link isError}.
 *
 * @param wat A value to be checked.
 * @returns A boolean representing the result.
 */
function isError(wat) {
    switch (Object.prototype.toString.call(wat)) {
        case '[object Error]':
            return true;
        case '[object Exception]':
            return true;
        case '[object DOMException]':
            return true;
        default:
            return wat instanceof Error;
    }
}
/**
 * Checks whether given value's type is ErrorEvent
 * {@link isErrorEvent}.
 *
 * @param wat A value to be checked.
 * @returns A boolean representing the result.
 */
function isErrorEvent(wat) {
    return Object.prototype.toString.call(wat) === '[object ErrorEvent]';
}
/**
 * Checks whether given value's type is DOMError
 * {@link isDOMError}.
 *
 * @param wat A value to be checked.
 * @returns A boolean representing the result.
 */
function isDOMError(wat) {
    return Object.prototype.toString.call(wat) === '[object DOMError]';
}
/**
 * Checks whether given value's type is DOMException
 * {@link isDOMException}.
 *
 * @param wat A value to be checked.
 * @returns A boolean representing the result.
 */
function isDOMException(wat) {
    return Object.prototype.toString.call(wat) === '[object DOMException]';
}
/**
 * Checks whether given value's type is a string
 * {@link isString}.
 *
 * @param wat A value to be checked.
 * @returns A boolean representing the result.
 */
function isString(wat) {
    return Object.prototype.toString.call(wat) === '[object String]';
}
/**
 * Checks whether given value's is a primitive (undefined, null, number, boolean, string)
 * {@link isPrimitive}.
 *
 * @param wat A value to be checked.
 * @returns A boolean representing the result.
 */
function isPrimitive(wat) {
    return wat === null || typeof wat !== 'object' && typeof wat !== 'function';
}
/**
 * Checks whether given value's type is an object literal
 * {@link isPlainObject}.
 *
 * @param wat A value to be checked.
 * @returns A boolean representing the result.
 */
function isPlainObject(wat) {
    return Object.prototype.toString.call(wat) === '[object Object]';
}
/**
 * Checks whether given value's type is an regexp
 * {@link isRegExp}.
 *
 * @param wat A value to be checked.
 * @returns A boolean representing the result.
 */
function isRegExp(wat) {
    return Object.prototype.toString.call(wat) === '[object RegExp]';
}
/**
 * Checks whether given value has a then function.
 * @param wat A value to be checked.
 */
function isThenable(wat) {
    // tslint:disable:no-unsafe-any
    return Boolean(wat && wat.then && typeof wat.then === 'function');
    // tslint:enable:no-unsafe-any
}
/**
 * Checks whether given value's type is a SyntheticEvent
 * {@link isSyntheticEvent}.
 *
 * @param wat A value to be checked.
 * @returns A boolean representing the result.
 */
function isSyntheticEvent(wat) {
    // tslint:disable-next-line:no-unsafe-any
    return isPlainObject(wat) && 'nativeEvent' in wat && 'preventDefault' in wat && 'stopPropagation' in wat;
}
//# sourceMappingURL=is.js.map

/***/ }),

/***/ "../utils/esm/logger.js":
/*!******************************!*\
  !*** ../utils/esm/logger.js ***!
  \******************************/
/*! exports provided: logger */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "logger", function() { return logger; });
/* harmony import */ var _misc__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./misc */ "../utils/esm/misc.js");

// TODO: Implement different loggers for different environments
var global = Object(_misc__WEBPACK_IMPORTED_MODULE_0__["getGlobalObject"])();
/** Prefix for logging strings */
var PREFIX = 'Sentry Logger ';
/** JSDoc */
var Logger = /** @class */function () {
    /** JSDoc */
    function Logger() {
        this._enabled = false;
    }
    /** JSDoc */
    Logger.prototype.disable = function () {
        this._enabled = false;
    };
    /** JSDoc */
    Logger.prototype.enable = function () {
        this._enabled = true;
    };
    /** JSDoc */
    Logger.prototype.log = function () {
        var args = [];
        for (var _i = 0; _i < arguments.length; _i++) {
            args[_i] = arguments[_i];
        }
        if (!this._enabled) {
            return;
        }
        Object(_misc__WEBPACK_IMPORTED_MODULE_0__["consoleSandbox"])(function () {
            global.console.log(PREFIX + "[Log]: " + args.join(' ')); // tslint:disable-line:no-console
        });
    };
    /** JSDoc */
    Logger.prototype.warn = function () {
        var args = [];
        for (var _i = 0; _i < arguments.length; _i++) {
            args[_i] = arguments[_i];
        }
        if (!this._enabled) {
            return;
        }
        Object(_misc__WEBPACK_IMPORTED_MODULE_0__["consoleSandbox"])(function () {
            global.console.warn(PREFIX + "[Warn]: " + args.join(' ')); // tslint:disable-line:no-console
        });
    };
    /** JSDoc */
    Logger.prototype.error = function () {
        var args = [];
        for (var _i = 0; _i < arguments.length; _i++) {
            args[_i] = arguments[_i];
        }
        if (!this._enabled) {
            return;
        }
        Object(_misc__WEBPACK_IMPORTED_MODULE_0__["consoleSandbox"])(function () {
            global.console.error(PREFIX + "[Error]: " + args.join(' ')); // tslint:disable-line:no-console
        });
    };
    return Logger;
}();
// Ensure we only have a single logger instance, even if multiple versions of @sentry/utils are being used
global.__SENTRY__ = global.__SENTRY__ || {};
var logger = global.__SENTRY__.logger || (global.__SENTRY__.logger = new Logger());

//# sourceMappingURL=logger.js.map

/***/ }),

/***/ "../utils/esm/memo.js":
/*!****************************!*\
  !*** ../utils/esm/memo.js ***!
  \****************************/
/*! exports provided: Memo */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "Memo", function() { return Memo; });
// tslint:disable:no-unsafe-any
/**
 * Memo class used for decycle json objects. Uses WeakSet if available otherwise array.
 */
var Memo = /** @class */function () {
    function Memo() {
        // tslint:disable-next-line
        this._hasWeakSet = typeof WeakSet === 'function';
        this._inner = this._hasWeakSet ? new WeakSet() : [];
    }
    /**
     * Sets obj to remember.
     * @param obj Object to remember
     */
    Memo.prototype.memoize = function (obj) {
        if (this._hasWeakSet) {
            if (this._inner.has(obj)) {
                return true;
            }
            this._inner.add(obj);
            return false;
        }
        // tslint:disable-next-line:prefer-for-of
        for (var i = 0; i < this._inner.length; i++) {
            var value = this._inner[i];
            if (value === obj) {
                return true;
            }
        }
        this._inner.push(obj);
        return false;
    };
    /**
     * Removes object from internal storage.
     * @param obj Object to forget
     */
    Memo.prototype.unmemoize = function (obj) {
        if (this._hasWeakSet) {
            this._inner.delete(obj);
        } else {
            for (var i = 0; i < this._inner.length; i++) {
                if (this._inner[i] === obj) {
                    this._inner.splice(i, 1);
                    break;
                }
            }
        }
    };
    return Memo;
}();

//# sourceMappingURL=memo.js.map

/***/ }),

/***/ "../utils/esm/misc.js":
/*!****************************!*\
  !*** ../utils/esm/misc.js ***!
  \****************************/
/*! exports provided: dynamicRequire, isNodeEnv, getGlobalObject, uuid4, parseUrl, getEventDescription, consoleSandbox, addExceptionTypeValue */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* WEBPACK VAR INJECTION */(function(process, global) {/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "dynamicRequire", function() { return dynamicRequire; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "isNodeEnv", function() { return isNodeEnv; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "getGlobalObject", function() { return getGlobalObject; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "uuid4", function() { return uuid4; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "parseUrl", function() { return parseUrl; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "getEventDescription", function() { return getEventDescription; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "consoleSandbox", function() { return consoleSandbox; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "addExceptionTypeValue", function() { return addExceptionTypeValue; });
/**
 * Requires a module which is protected _against bundler minification.
 *
 * @param request The module path to resolve
 */
function dynamicRequire(mod, request) {
    // tslint:disable-next-line: no-unsafe-any
    return mod.require(request);
}
/**
 * Checks whether we're in the Node.js or Browser environment
 *
 * @returns Answer to given question
 */
function isNodeEnv() {
    // tslint:disable:strict-type-predicates
    return Object.prototype.toString.call(typeof process !== 'undefined' ? process : 0) === '[object process]';
}
var fallbackGlobalObject = {};
/**
 * Safely get global scope object
 *
 * @returns Global scope object
 */
function getGlobalObject() {
    return isNodeEnv() ? global : typeof window !== 'undefined' ? window : typeof self !== 'undefined' ? self : fallbackGlobalObject;
}
/**
 * UUID4 generator
 *
 * @returns string Generated UUID4.
 */
function uuid4() {
    var global = getGlobalObject();
    var crypto = global.crypto || global.msCrypto;
    if (!(crypto === void 0) && crypto.getRandomValues) {
        // Use window.crypto API if available
        var arr = new Uint16Array(8);
        crypto.getRandomValues(arr);
        // set 4 in byte 7
        // tslint:disable-next-line:no-bitwise
        arr[3] = arr[3] & 0xfff | 0x4000;
        // set 2 most significant bits of byte 9 to '10'
        // tslint:disable-next-line:no-bitwise
        arr[4] = arr[4] & 0x3fff | 0x8000;
        var pad = function (num) {
            var v = num.toString(16);
            while (v.length < 4) {
                v = "0" + v;
            }
            return v;
        };
        return pad(arr[0]) + pad(arr[1]) + pad(arr[2]) + pad(arr[3]) + pad(arr[4]) + pad(arr[5]) + pad(arr[6]) + pad(arr[7]);
    }
    // http://stackoverflow.com/questions/105034/how-to-create-a-guid-uuid-in-javascript/2117523#2117523
    return 'xxxxxxxxxxxx4xxxyxxxxxxxxxxxxxxx'.replace(/[xy]/g, function (c) {
        // tslint:disable-next-line:no-bitwise
        var r = Math.random() * 16 | 0;
        // tslint:disable-next-line:no-bitwise
        var v = c === 'x' ? r : r & 0x3 | 0x8;
        return v.toString(16);
    });
}
/**
 * Parses string form of URL into an object
 * // borrowed from https://tools.ietf.org/html/rfc3986#appendix-B
 * // intentionally using regex and not <a/> href parsing trick because React Native and other
 * // environments where DOM might not be available
 * @returns parsed URL object
 */
function parseUrl(url) {
    if (!url) {
        return {};
    }
    var match = url.match(/^(([^:\/?#]+):)?(\/\/([^\/?#]*))?([^?#]*)(\?([^#]*))?(#(.*))?$/);
    if (!match) {
        return {};
    }
    // coerce to undefined values to empty string so we don't get 'undefined'
    var query = match[6] || '';
    var fragment = match[8] || '';
    return {
        host: match[4],
        path: match[5],
        protocol: match[2],
        relative: match[5] + query + fragment
    };
}
/**
 * Extracts either message or type+value from an event that can be used for user-facing logs
 * @returns event's description
 */
function getEventDescription(event) {
    if (event.message) {
        return event.message;
    }
    if (event.exception && event.exception.values && event.exception.values[0]) {
        var exception = event.exception.values[0];
        if (exception.type && exception.value) {
            return exception.type + ": " + exception.value;
        }
        return exception.type || exception.value || event.event_id || '<unknown>';
    }
    return event.event_id || '<unknown>';
}
/** JSDoc */
function consoleSandbox(callback) {
    var global = getGlobalObject();
    var levels = ['debug', 'info', 'warn', 'error', 'log', 'assert'];
    if (!('console' in global)) {
        return callback();
    }
    var originalConsole = global.console;
    var wrappedLevels = {};
    // Restore all wrapped console methods
    levels.forEach(function (level) {
        if (level in global.console && originalConsole[level].__sentry__) {
            wrappedLevels[level] = originalConsole[level].__sentry_wrapped__;
            originalConsole[level] = originalConsole[level].__sentry_original__;
        }
    });
    // Perform callback manipulations
    var result = callback();
    // Revert restoration to wrapped state
    Object.keys(wrappedLevels).forEach(function (level) {
        originalConsole[level] = wrappedLevels[level];
    });
    return result;
}
/**
 * Adds exception values, type and value to an synthetic Exception.
 * @param event The event to modify.
 * @param value Value of the exception.
 * @param type Type of the exception.
 * @param mechanism Mechanism of the exception.
 * @hidden
 */
function addExceptionTypeValue(event, value, type, mechanism) {
    if (mechanism === void 0) {
        mechanism = {
            handled: true,
            type: 'generic'
        };
    }
    event.exception = event.exception || {};
    event.exception.values = event.exception.values || [];
    event.exception.values[0] = event.exception.values[0] || {};
    event.exception.values[0].value = event.exception.values[0].value || value || '';
    event.exception.values[0].type = event.exception.values[0].type || type || 'Error';
    event.exception.values[0].mechanism = event.exception.values[0].mechanism || mechanism;
}
//# sourceMappingURL=misc.js.map
/* WEBPACK VAR INJECTION */}.call(this, __webpack_require__(/*! ./../../../node_modules/process/browser.js */ "../../node_modules/process/browser.js"), __webpack_require__(/*! ./../../../node_modules/webpack/buildin/global.js */ "../../node_modules/webpack/buildin/global.js")))

/***/ }),

/***/ "../utils/esm/object.js":
/*!******************************!*\
  !*** ../utils/esm/object.js ***!
  \******************************/
/*! exports provided: fill, urlEncode, normalizeToSize, walk, normalize */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* WEBPACK VAR INJECTION */(function(global) {/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "fill", function() { return fill; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "urlEncode", function() { return urlEncode; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "normalizeToSize", function() { return normalizeToSize; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "walk", function() { return walk; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "normalize", function() { return normalize; });
/* harmony import */ var _is__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./is */ "../utils/esm/is.js");
/* harmony import */ var _memo__WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./memo */ "../utils/esm/memo.js");


/**
 * Wrap a given object method with a higher-order function
 *
 * @param source An object that contains a method to be wrapped.
 * @param name A name of method to be wrapped.
 * @param replacement A function that should be used to wrap a given method.
 * @returns void
 */
function fill(source, name, replacement) {
    if (!(name in source)) {
        return;
    }
    var original = source[name];
    var wrapped = replacement(original);
    // Make sure it's a function first, as we need to attach an empty prototype for `defineProperties` to work
    // otherwise it'll throw "TypeError: Object.defineProperties called on non-object"
    // tslint:disable-next-line:strict-type-predicates
    if (typeof wrapped === 'function') {
        try {
            wrapped.prototype = wrapped.prototype || {};
            Object.defineProperties(wrapped, {
                __sentry__: {
                    enumerable: false,
                    value: true
                },
                __sentry_original__: {
                    enumerable: false,
                    value: original
                },
                __sentry_wrapped__: {
                    enumerable: false,
                    value: wrapped
                }
            });
        } catch (_Oo) {
            // This can throw if multiple fill happens on a global object like XMLHttpRequest
            // Fixes https://github.com/getsentry/sentry-javascript/issues/2043
        }
    }
    source[name] = wrapped;
}
/**
 * Encodes given object into url-friendly format
 *
 * @param object An object that contains serializable values
 * @returns string Encoded
 */
function urlEncode(object) {
    return Object.keys(object).map(
    // tslint:disable-next-line:no-unsafe-any
    function (key) {
        return encodeURIComponent(key) + "=" + encodeURIComponent(object[key]);
    }).join('&');
}
/**
 * Transforms Error object into an object literal with all it's attributes
 * attached to it.
 *
 * Based on: https://github.com/ftlabs/js-abbreviate/blob/fa709e5f139e7770a71827b1893f22418097fbda/index.js#L95-L106
 *
 * @param error An Error containing all relevant information
 * @returns An object with all error properties
 */
function objectifyError(error) {
    // These properties are implemented as magical getters and don't show up in `for-in` loop
    var err = {
        message: error.message,
        name: error.name,
        stack: error.stack
    };
    for (var i in error) {
        if (Object.prototype.hasOwnProperty.call(error, i)) {
            err[i] = error[i];
        }
    }
    return err;
}
/** Calculates bytes size of input string */
function utf8Length(value) {
    // tslint:disable-next-line:no-bitwise
    return ~-encodeURI(value).split(/%..|./).length;
}
/** Calculates bytes size of input object */
function jsonSize(value) {
    return utf8Length(JSON.stringify(value));
}
/** JSDoc */
function normalizeToSize(object,
// Default Node.js REPL depth
depth,
// 100kB, as 200kB is max payload size, so half sounds reasonable
maxSize) {
    if (depth === void 0) {
        depth = 3;
    }
    if (maxSize === void 0) {
        maxSize = 100 * 1024;
    }
    var serialized = normalize(object, depth);
    if (jsonSize(serialized) > maxSize) {
        return normalizeToSize(object, depth - 1, maxSize);
    }
    return serialized;
}
/** Transforms any input value into a string form, either primitive value or a type of the input */
function serializeValue(value) {
    var type = Object.prototype.toString.call(value);
    // Node.js REPL notation
    if (typeof value === 'string') {
        return value;
    }
    if (type === '[object Object]') {
        return '[Object]';
    }
    if (type === '[object Array]') {
        return '[Array]';
    }
    var normalized = normalizeValue(value);
    return Object(_is__WEBPACK_IMPORTED_MODULE_0__["isPrimitive"])(normalized) ? normalized : type;
}
/**
 * normalizeValue()
 *
 * Takes unserializable input and make it serializable friendly
 *
 * - translates undefined/NaN values to "[undefined]"/"[NaN]" respectively,
 * - serializes Error objects
 * - filter global objects
 */
function normalizeValue(value, key) {
    if (key === 'domain' && typeof value === 'object' && value._events) {
        return '[Domain]';
    }
    if (key === 'domainEmitter') {
        return '[DomainEmitter]';
    }
    if (typeof global !== 'undefined' && value === global) {
        return '[Global]';
    }
    if (typeof window !== 'undefined' && value === window) {
        return '[Window]';
    }
    if (typeof document !== 'undefined' && value === document) {
        return '[Document]';
    }
    // tslint:disable-next-line:strict-type-predicates
    if (typeof Event !== 'undefined' && value instanceof Event) {
        return Object.getPrototypeOf(value) ? value.constructor.name : 'Event';
    }
    // React's SyntheticEvent thingy
    if (Object(_is__WEBPACK_IMPORTED_MODULE_0__["isSyntheticEvent"])(value)) {
        return '[SyntheticEvent]';
    }
    if (Number.isNaN(value)) {
        return '[NaN]';
    }
    if (value === void 0) {
        return '[undefined]';
    }
    if (typeof value === 'function') {
        return "[Function: " + (value.name || '<unknown-function-name>') + "]";
    }
    return value;
}
/**
 * Walks an object to perform a normalization on it
 *
 * @param key of object that's walked in current iteration
 * @param value object to be walked
 * @param depth Optional number indicating how deep should walking be performed
 * @param memo Optional Memo class handling decycling
 */
function walk(key, value, depth, memo) {
    if (depth === void 0) {
        depth = +Infinity;
    }
    if (memo === void 0) {
        memo = new _memo__WEBPACK_IMPORTED_MODULE_1__["Memo"]();
    }
    // If we reach the maximum depth, serialize whatever has left
    if (depth === 0) {
        return serializeValue(value);
    }
    // If value implements `toJSON` method, call it and return early
    // tslint:disable:no-unsafe-any
    if (value !== null && value !== undefined && typeof value.toJSON === 'function') {
        return value.toJSON();
    }
    // tslint:enable:no-unsafe-any
    // If normalized value is a primitive, there are no branches left to walk, so we can just bail out, as theres no point in going down that branch any further
    var normalized = normalizeValue(value, key);
    if (Object(_is__WEBPACK_IMPORTED_MODULE_0__["isPrimitive"])(normalized)) {
        return normalized;
    }
    // Create source that we will use for next itterations, either objectified error object (Error type with extracted keys:value pairs) or the input itself
    var source = Object(_is__WEBPACK_IMPORTED_MODULE_0__["isError"])(value) ? objectifyError(value) : value;
    // Create an accumulator that will act as a parent for all future itterations of that branch
    var acc = Array.isArray(value) ? [] : {};
    // If we already walked that branch, bail out, as it's circular reference
    if (memo.memoize(value)) {
        return '[Circular ~]';
    }
    // Walk all keys of the source
    for (var innerKey in source) {
        // Avoid iterating over fields in the prototype if they've somehow been exposed to enumeration.
        if (!Object.prototype.hasOwnProperty.call(source, innerKey)) {
            continue;
        }
        // Recursively walk through all the child nodes
        acc[innerKey] = walk(innerKey, source[innerKey], depth - 1, memo);
    }
    // Once walked through all the branches, remove the parent from memo storage
    memo.unmemoize(value);
    // Return accumulated values
    return acc;
}
/**
 * normalize()
 *
 * - Creates a copy to prevent original input mutation
 * - Skip non-enumerablers
 * - Calls `toJSON` if implemented
 * - Removes circular references
 * - Translates non-serializeable values (undefined/NaN/Functions) to serializable format
 * - Translates known global objects/Classes to a string representations
 * - Takes care of Error objects serialization
 * - Optionally limit depth of final output
 */
function normalize(input, depth) {
    try {
        // tslint:disable-next-line:no-unsafe-any
        return JSON.parse(JSON.stringify(input, function (key, value) {
            return walk(key, value, depth);
        }));
    } catch (_oO) {
        return '**non-serializable**';
    }
}
//# sourceMappingURL=object.js.map
/* WEBPACK VAR INJECTION */}.call(this, __webpack_require__(/*! ./../../../node_modules/webpack/buildin/global.js */ "../../node_modules/webpack/buildin/global.js")))

/***/ }),

/***/ "../utils/esm/path.js":
/*!****************************!*\
  !*** ../utils/esm/path.js ***!
  \****************************/
/*! exports provided: resolve, relative, normalizePath, isAbsolute, join, dirname, basename */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "resolve", function() { return resolve; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "relative", function() { return relative; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "normalizePath", function() { return normalizePath; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "isAbsolute", function() { return isAbsolute; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "join", function() { return join; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "dirname", function() { return dirname; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "basename", function() { return basename; });
// Slightly modified (no IE8 support, ES6) and transcribed to TypeScript
// https://raw.githubusercontent.com/calvinmetcalf/rollup-plugin-node-builtins/master/src/es6/path.js
/** JSDoc */
function normalizeArray(parts, allowAboveRoot) {
    // if the path tries to go above the root, `up` ends up > 0
    var up = 0;
    for (var i = parts.length - 1; i >= 0; i--) {
        var last = parts[i];
        if (last === '.') {
            parts.splice(i, 1);
        } else if (last === '..') {
            parts.splice(i, 1);
            up++;
        } else if (up) {
            parts.splice(i, 1);
            up--;
        }
    }
    // if the path is allowed to go above the root, restore leading ..s
    if (allowAboveRoot) {
        for (; up--; up) {
            parts.unshift('..');
        }
    }
    return parts;
}
// Split a filename into [root, dir, basename, ext], unix version
// 'root' is just a slash, or nothing.
var splitPathRe = /^(\/?|)([\s\S]*?)((?:\.{1,2}|[^\/]+?|)(\.[^.\/]*|))(?:[\/]*)$/;
/** JSDoc */
function splitPath(filename) {
    var parts = splitPathRe.exec(filename);
    return parts ? parts.slice(1) : [];
}
// path.resolve([from ...], to)
// posix version
/** JSDoc */
function resolve() {
    var args = [];
    for (var _i = 0; _i < arguments.length; _i++) {
        args[_i] = arguments[_i];
    }
    var resolvedPath = '';
    var resolvedAbsolute = false;
    for (var i = args.length - 1; i >= -1 && !resolvedAbsolute; i--) {
        var path = i >= 0 ? args[i] : '/';
        // Skip empty entries
        if (!path) {
            continue;
        }
        resolvedPath = path + "/" + resolvedPath;
        resolvedAbsolute = path.charAt(0) === '/';
    }
    // At this point the path should be resolved to a full absolute path, but
    // handle relative paths to be safe (might happen when process.cwd() fails)
    // Normalize the path
    resolvedPath = normalizeArray(resolvedPath.split('/').filter(function (p) {
        return !!p;
    }), !resolvedAbsolute).join('/');
    return (resolvedAbsolute ? '/' : '') + resolvedPath || '.';
}
/** JSDoc */
function trim(arr) {
    var start = 0;
    for (; start < arr.length; start++) {
        if (arr[start] !== '') {
            break;
        }
    }
    var end = arr.length - 1;
    for (; end >= 0; end--) {
        if (arr[end] !== '') {
            break;
        }
    }
    if (start > end) {
        return [];
    }
    return arr.slice(start, end - start + 1);
}
// path.relative(from, to)
// posix version
/** JSDoc */
function relative(from, to) {
    // tslint:disable:no-parameter-reassignment
    from = resolve(from).substr(1);
    to = resolve(to).substr(1);
    var fromParts = trim(from.split('/'));
    var toParts = trim(to.split('/'));
    var length = Math.min(fromParts.length, toParts.length);
    var samePartsLength = length;
    for (var i = 0; i < length; i++) {
        if (fromParts[i] !== toParts[i]) {
            samePartsLength = i;
            break;
        }
    }
    var outputParts = [];
    for (var i = samePartsLength; i < fromParts.length; i++) {
        outputParts.push('..');
    }
    outputParts = outputParts.concat(toParts.slice(samePartsLength));
    return outputParts.join('/');
}
// path.normalize(path)
// posix version
/** JSDoc */
function normalizePath(path) {
    var isPathAbsolute = isAbsolute(path);
    var trailingSlash = path.substr(-1) === '/';
    // Normalize the path
    var normalizedPath = normalizeArray(path.split('/').filter(function (p) {
        return !!p;
    }), !isPathAbsolute).join('/');
    if (!normalizedPath && !isPathAbsolute) {
        normalizedPath = '.';
    }
    if (normalizedPath && trailingSlash) {
        normalizedPath += '/';
    }
    return (isPathAbsolute ? '/' : '') + normalizedPath;
}
// posix version
/** JSDoc */
function isAbsolute(path) {
    return path.charAt(0) === '/';
}
// posix version
/** JSDoc */
function join() {
    var args = [];
    for (var _i = 0; _i < arguments.length; _i++) {
        args[_i] = arguments[_i];
    }
    return normalizePath(args.join('/'));
}
/** JSDoc */
function dirname(path) {
    var result = splitPath(path);
    var root = result[0];
    var dir = result[1];
    if (!root && !dir) {
        // No dirname whatsoever
        return '.';
    }
    if (dir) {
        // It has a dirname, strip trailing slash
        dir = dir.substr(0, dir.length - 1);
    }
    return root + dir;
}
/** JSDoc */
function basename(path, ext) {
    var f = splitPath(path)[2];
    if (ext && f.substr(ext.length * -1) === ext) {
        f = f.substr(0, f.length - ext.length);
    }
    return f;
}
//# sourceMappingURL=path.js.map

/***/ }),

/***/ "../utils/esm/promisebuffer.js":
/*!*************************************!*\
  !*** ../utils/esm/promisebuffer.js ***!
  \*************************************/
/*! exports provided: PromiseBuffer */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "PromiseBuffer", function() { return PromiseBuffer; });
/* harmony import */ var _error__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./error */ "../utils/esm/error.js");

/** A simple queue that holds promises. */
var PromiseBuffer = /** @class */function () {
    function PromiseBuffer(_limit) {
        this._limit = _limit;
        /** Internal set of queued Promises */
        this._buffer = [];
    }
    /**
     * Says if the buffer is ready to take more requests
     */
    PromiseBuffer.prototype.isReady = function () {
        return this._limit === undefined || this.length() < this._limit;
    };
    /**
     * Add a promise to the queue.
     *
     * @param task Can be any Promise<T>
     * @returns The original promise.
     */
    PromiseBuffer.prototype.add = function (task) {
        var _this = this;
        if (!this.isReady()) {
            return Promise.reject(new _error__WEBPACK_IMPORTED_MODULE_0__["SentryError"]('Not adding Promise due to buffer limit reached.'));
        }
        if (this._buffer.indexOf(task) === -1) {
            this._buffer.push(task);
        }
        task.then(function () {
            return _this.remove(task);
        }).catch(function () {
            return _this.remove(task).catch(function () {
                // We have to add this catch here otherwise we have an unhandledPromiseRejection
                // because it's a new Promise chain.
            });
        });
        return task;
    };
    /**
     * Remove a promise to the queue.
     *
     * @param task Can be any Promise<T>
     * @returns Removed promise.
     */
    PromiseBuffer.prototype.remove = function (task) {
        var removedTask = this._buffer.splice(this._buffer.indexOf(task), 1)[0];
        return removedTask;
    };
    /**
     * This function returns the number of unresolved promises in the queue.
     */
    PromiseBuffer.prototype.length = function () {
        return this._buffer.length;
    };
    /**
     * This will drain the whole queue, returns true if queue is empty or drained.
     * If timeout is provided and the queue takes longer to drain, the promise still resolves but with false.
     *
     * @param timeout Number in ms to wait until it resolves with false.
     */
    PromiseBuffer.prototype.drain = function (timeout) {
        var _this = this;
        return new Promise(function (resolve) {
            var capturedSetTimeout = setTimeout(function () {
                if (timeout && timeout > 0) {
                    resolve(false);
                }
            }, timeout);
            Promise.all(_this._buffer).then(function () {
                clearTimeout(capturedSetTimeout);
                resolve(true);
            }).catch(function () {
                resolve(true);
            });
        });
    };
    return PromiseBuffer;
}();

//# sourceMappingURL=promisebuffer.js.map

/***/ }),

/***/ "../utils/esm/string.js":
/*!******************************!*\
  !*** ../utils/esm/string.js ***!
  \******************************/
/*! exports provided: truncate, snipLine, safeJoin, keysToEventMessage, isMatchingPattern */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "truncate", function() { return truncate; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "snipLine", function() { return snipLine; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "safeJoin", function() { return safeJoin; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "keysToEventMessage", function() { return keysToEventMessage; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "isMatchingPattern", function() { return isMatchingPattern; });
/* harmony import */ var _is__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./is */ "../utils/esm/is.js");

/**
 * Truncates given string to the maximum characters count
 *
 * @param str An object that contains serializable values
 * @param max Maximum number of characters in truncated string
 * @returns string Encoded
 */
function truncate(str, max) {
    if (max === void 0) {
        max = 0;
    }
    // tslint:disable-next-line:strict-type-predicates
    if (typeof str !== 'string' || max === 0) {
        return str;
    }
    return str.length <= max ? str : str.substr(0, max) + "...";
}
/**
 * This is basically just `trim_line` from
 * https://github.com/getsentry/sentry/blob/master/src/sentry/lang/javascript/processor.py#L67
 *
 * @param str An object that contains serializable values
 * @param max Maximum number of characters in truncated string
 * @returns string Encoded
 */
function snipLine(line, colno) {
    var newLine = line;
    var ll = newLine.length;
    if (ll <= 150) {
        return newLine;
    }
    if (colno > ll) {
        colno = ll; // tslint:disable-line:no-parameter-reassignment
    }
    var start = Math.max(colno - 60, 0);
    if (start < 5) {
        start = 0;
    }
    var end = Math.min(start + 140, ll);
    if (end > ll - 5) {
        end = ll;
    }
    if (end === ll) {
        start = Math.max(end - 140, 0);
    }
    newLine = newLine.slice(start, end);
    if (start > 0) {
        newLine = "'{snip} " + newLine;
    }
    if (end < ll) {
        newLine += ' {snip}';
    }
    return newLine;
}
/**
 * Join values in array
 * @param input array of values to be joined together
 * @param delimiter string to be placed in-between values
 * @returns Joined values
 */
function safeJoin(input, delimiter) {
    if (!Array.isArray(input)) {
        return '';
    }
    var output = [];
    // tslint:disable-next-line:prefer-for-of
    for (var i = 0; i < input.length; i++) {
        var value = input[i];
        try {
            output.push(String(value));
        } catch (e) {
            output.push('[value cannot be serialized]');
        }
    }
    return output.join(delimiter);
}
/** Merges provided array of keys into */
function keysToEventMessage(keys, maxLength) {
    if (maxLength === void 0) {
        maxLength = 40;
    }
    if (!keys.length) {
        return '[object has no keys]';
    }
    if (keys[0].length >= maxLength) {
        return truncate(keys[0], maxLength);
    }
    for (var includedKeys = keys.length; includedKeys > 0; includedKeys--) {
        var serialized = keys.slice(0, includedKeys).join(', ');
        if (serialized.length > maxLength) {
            continue;
        }
        if (includedKeys === keys.length) {
            return serialized;
        }
        return truncate(serialized, maxLength);
    }
    return '';
}
/**
 * Checks if the value matches a regex or includes the string
 * @param value The string value to be checked against
 * @param pattern Either a regex or a string that must be contained in value
 */
function isMatchingPattern(value, pattern) {
    if (Object(_is__WEBPACK_IMPORTED_MODULE_0__["isRegExp"])(pattern)) {
        return pattern.test(value);
    }
    if (typeof pattern === 'string') {
        return value.includes(pattern);
    }
    return false;
}
//# sourceMappingURL=string.js.map

/***/ }),

/***/ "../utils/esm/supports.js":
/*!********************************!*\
  !*** ../utils/esm/supports.js ***!
  \********************************/
/*! exports provided: supportsErrorEvent, supportsDOMError, supportsDOMException, supportsFetch, supportsNativeFetch, supportsReportingObserver, supportsReferrerPolicy, supportsHistory */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "supportsErrorEvent", function() { return supportsErrorEvent; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "supportsDOMError", function() { return supportsDOMError; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "supportsDOMException", function() { return supportsDOMException; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "supportsFetch", function() { return supportsFetch; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "supportsNativeFetch", function() { return supportsNativeFetch; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "supportsReportingObserver", function() { return supportsReportingObserver; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "supportsReferrerPolicy", function() { return supportsReferrerPolicy; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "supportsHistory", function() { return supportsHistory; });
/* harmony import */ var _misc__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./misc */ "../utils/esm/misc.js");

/**
 * Tells whether current environment supports ErrorEvent objects
 * {@link supportsErrorEvent}.
 *
 * @returns Answer to the given question.
 */
function supportsErrorEvent() {
    try {
        // tslint:disable:no-unused-expression
        new ErrorEvent('');
        return true;
    } catch (e) {
        return false;
    }
}
/**
 * Tells whether current environment supports DOMError objects
 * {@link supportsDOMError}.
 *
 * @returns Answer to the given question.
 */
function supportsDOMError() {
    try {
        // It really needs 1 argument, not 0.
        // Chrome: VM89:1 Uncaught TypeError: Failed to construct 'DOMError':
        // 1 argument required, but only 0 present.
        // @ts-ignore
        // tslint:disable:no-unused-expression
        new DOMError('');
        return true;
    } catch (e) {
        return false;
    }
}
/**
 * Tells whether current environment supports DOMException objects
 * {@link supportsDOMException}.
 *
 * @returns Answer to the given question.
 */
function supportsDOMException() {
    try {
        // tslint:disable:no-unused-expression
        new DOMException('');
        return true;
    } catch (e) {
        return false;
    }
}
/**
 * Tells whether current environment supports Fetch API
 * {@link supportsFetch}.
 *
 * @returns Answer to the given question.
 */
function supportsFetch() {
    if (!('fetch' in Object(_misc__WEBPACK_IMPORTED_MODULE_0__["getGlobalObject"])())) {
        return false;
    }
    try {
        // tslint:disable-next-line:no-unused-expression
        new Headers();
        // tslint:disable-next-line:no-unused-expression
        new Request('');
        // tslint:disable-next-line:no-unused-expression
        new Response();
        return true;
    } catch (e) {
        return false;
    }
}
/**
 * Tells whether current environment supports Fetch API natively
 * {@link supportsNativeFetch}.
 *
 * @returns Answer to the given question.
 */
function supportsNativeFetch() {
    if (!supportsFetch()) {
        return false;
    }
    var global = Object(_misc__WEBPACK_IMPORTED_MODULE_0__["getGlobalObject"])();
    return global.fetch.toString().indexOf('native') !== -1;
}
/**
 * Tells whether current environment supports ReportingObserver API
 * {@link supportsReportingObserver}.
 *
 * @returns Answer to the given question.
 */
function supportsReportingObserver() {
    // tslint:disable-next-line: no-unsafe-any
    return 'ReportingObserver' in Object(_misc__WEBPACK_IMPORTED_MODULE_0__["getGlobalObject"])();
}
/**
 * Tells whether current environment supports Referrer Policy API
 * {@link supportsReferrerPolicy}.
 *
 * @returns Answer to the given question.
 */
function supportsReferrerPolicy() {
    // Despite all stars in the sky saying that Edge supports old draft syntax, aka 'never', 'always', 'origin' and 'default
    // https://caniuse.com/#feat=referrer-policy
    // It doesn't. And it throw exception instead of ignoring this parameter...
    // REF: https://github.com/getsentry/raven-js/issues/1233
    if (!supportsFetch()) {
        return false;
    }
    try {
        // tslint:disable:no-unused-expression
        new Request('_', {
            referrerPolicy: 'origin'
        });
        return true;
    } catch (e) {
        return false;
    }
}
/**
 * Tells whether current environment supports History API
 * {@link supportsHistory}.
 *
 * @returns Answer to the given question.
 */
function supportsHistory() {
    // NOTE: in Chrome App environment, touching history.pushState, *even inside
    //       a try/catch block*, will cause Chrome to output an error to console.error
    // borrowed from: https://github.com/angular/angular.js/pull/13945/files
    var global = Object(_misc__WEBPACK_IMPORTED_MODULE_0__["getGlobalObject"])();
    var chrome = global.chrome;
    // tslint:disable-next-line:no-unsafe-any
    var isChromePackagedApp = chrome && chrome.app && chrome.app.runtime;
    var hasHistoryApi = 'history' in global && !!global.history.pushState && !!global.history.replaceState;
    return !isChromePackagedApp && hasHistoryApi;
}
//# sourceMappingURL=supports.js.map

/***/ }),

/***/ "../utils/esm/syncpromise.js":
/*!***********************************!*\
  !*** ../utils/esm/syncpromise.js ***!
  \***********************************/
/*! exports provided: SyncPromise */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "SyncPromise", function() { return SyncPromise; });
/* harmony import */ var _is__WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./is */ "../utils/esm/is.js");

/** SyncPromise internal states */
var States;
(function (States) {
    /** Pending */
    States["PENDING"] = "PENDING";
    /** Resolved / OK */
    States["RESOLVED"] = "RESOLVED";
    /** Rejected / Error */
    States["REJECTED"] = "REJECTED";
})(States || (States = {}));
/** JSDoc */
var SyncPromise = /** @class */function () {
    function SyncPromise(callback) {
        var _this = this;
        /** JSDoc */
        this._state = States.PENDING;
        /** JSDoc */
        this._handlers = [];
        /** JSDoc */
        this._resolve = function (value) {
            _this._setResult(value, States.RESOLVED);
        };
        /** JSDoc */
        this._reject = function (reason) {
            _this._setResult(reason, States.REJECTED);
        };
        /** JSDoc */
        this._setResult = function (value, state) {
            if (_this._state !== States.PENDING) {
                return;
            }
            if (Object(_is__WEBPACK_IMPORTED_MODULE_0__["isThenable"])(value)) {
                value.then(_this._resolve, _this._reject);
                return;
            }
            _this._value = value;
            _this._state = state;
            _this._executeHandlers();
        };
        /** JSDoc */
        this._executeHandlers = function () {
            if (_this._state === States.PENDING) {
                return;
            }
            if (_this._state === States.REJECTED) {
                // tslint:disable-next-line:no-unsafe-any
                _this._handlers.forEach(function (h) {
                    return h.onFail && h.onFail(_this._value);
                });
            } else {
                // tslint:disable-next-line:no-unsafe-any
                _this._handlers.forEach(function (h) {
                    return h.onSuccess && h.onSuccess(_this._value);
                });
            }
            _this._handlers = [];
            return;
        };
        /** JSDoc */
        this._attachHandler = function (handler) {
            _this._handlers = _this._handlers.concat(handler);
            _this._executeHandlers();
        };
        try {
            callback(this._resolve, this._reject);
        } catch (e) {
            this._reject(e);
        }
    }
    /** JSDoc */
    SyncPromise.prototype.then = function (onfulfilled, onrejected) {
        var _this = this;
        // public then<U>(onSuccess?: HandlerOnSuccess<T, U>, onFail?: HandlerOnFail<U>): SyncPromise<T | U> {
        return new SyncPromise(function (resolve, reject) {
            _this._attachHandler({
                onFail: function (reason) {
                    if (!onrejected) {
                        reject(reason);
                        return;
                    }
                    try {
                        resolve(onrejected(reason));
                        return;
                    } catch (e) {
                        reject(e);
                        return;
                    }
                },
                onSuccess: function (result) {
                    if (!onfulfilled) {
                        resolve(result);
                        return;
                    }
                    try {
                        resolve(onfulfilled(result));
                        return;
                    } catch (e) {
                        reject(e);
                        return;
                    }
                }
            });
        });
    };
    /** JSDoc */
    SyncPromise.prototype.catch = function (onFail) {
        // tslint:disable-next-line:no-unsafe-any
        return this.then(function (val) {
            return val;
        }, onFail);
    };
    /** JSDoc */
    SyncPromise.prototype.toString = function () {
        return "[object SyncPromise]";
    };
    /** JSDoc */
    SyncPromise.resolve = function (value) {
        return new SyncPromise(function (resolve) {
            resolve(value);
        });
    };
    /** JSDoc */
    SyncPromise.reject = function (reason) {
        return new SyncPromise(function (_, reject) {
            reject(reason);
        });
    };
    return SyncPromise;
}();

//# sourceMappingURL=syncpromise.js.map

/***/ }),

/***/ "./src/constants/boss/index.js":
/*!*************************************!*\
  !*** ./src/constants/boss/index.js ***!
  \*************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
  value: true
});
var CANMODIFYKEYS = exports.CANMODIFYKEYS = ['s_path', 's_uuid', 's_traceid', 's_guid', 's_appid', 's_vuserid', 'hc_pgv_pvid', 's_omgid', 'err_desc'];

/***/ }),

/***/ "./src/constants/config/index.js":
/*!***************************************!*\
  !*** ./src/constants/config/index.js ***!
  \***************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
  value: true
});
var CDNQUALITY = exports.CDNQUALITY = {
  duration: 'delay',
  name: 'resurl',
  type: 'type'
};

var DEBUG = exports.DEBUG = "false" === 'true';

var REPORTTYPES = exports.REPORTTYPES = ['css', 'script', 'img', 'video', 'audio'];

var NOREPORTTYPES = exports.NOREPORTTYPES = ['cdn', 'cgi'];

var baseUrl = exports.baseUrl = 'https://sngapm.qq.com';

var token = false;
var getToken = exports.getToken = function getToken() {
  return token;
};
var setToken = exports.setToken = function setToken(value) {
  token = value;
};

var isSlow = 2000;
var setThreshold = exports.setThreshold = function setThreshold(threshold) {
  isSlow = threshold;
};
var getThreshold = exports.getThreshold = function getThreshold() {
  return isSlow;
};

/***/ }),

/***/ "./src/index.js":
/*!**********************!*\
  !*** ./src/index.js ***!
  \**********************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.trace = exports.resetUin = exports.setQAPMUUID = exports.getParts = exports.getCdnTiming = exports.getPfTiming = exports.getRcTiming = exports.resetConfig = exports.qapmJsStart = exports.initQAPMJs = undefined;

var _createClass = function () { function defineProperties(target, props) { for (var i = 0; i < props.length; i++) { var descriptor = props[i]; descriptor.enumerable = descriptor.enumerable || false; descriptor.configurable = true; if ("value" in descriptor) descriptor.writable = true; Object.defineProperty(target, descriptor.key, descriptor); } } return function (Constructor, protoProps, staticProps) { if (protoProps) defineProperties(Constructor.prototype, protoProps); if (staticProps) defineProperties(Constructor, staticProps); return Constructor; }; }();

var _slicedToArray = function () { function sliceIterator(arr, i) { var _arr = []; var _n = true; var _d = false; var _e = undefined; try { for (var _i = arr[Symbol.iterator](), _s; !(_n = (_s = _i.next()).done); _n = true) { _arr.push(_s.value); if (i && _arr.length === i) break; } } catch (err) { _d = true; _e = err; } finally { try { if (!_n && _i["return"]) _i["return"](); } finally { if (_d) throw _e; } } return _arr; } return function (arr, i) { if (Array.isArray(arr)) { return arr; } else if (Symbol.iterator in Object(arr)) { return sliceIterator(arr, i); } else { throw new TypeError("Invalid attempt to destructure non-iterable instance"); } }; }(); /* eslint-disable func-names */


var _browser = __webpack_require__(/*! @sentry/browser */ "../browser/esm/index.js");

var Sentry = _interopRequireWildcard(_browser);

var _athena = __webpack_require__(/*! @tencent/athena */ "../athena/src/index-h5.js");

var _athena2 = _interopRequireDefault(_athena);

var _utils = __webpack_require__(/*! ./utils */ "./src/utils/index.js");

var _performance = __webpack_require__(/*! ./performance */ "./src/performance/index.js");

var _parts = __webpack_require__(/*! ./performance/parts */ "./src/performance/parts.js");

var _config = __webpack_require__(/*! ./constants/config */ "./src/constants/config/index.js");

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

function _interopRequireWildcard(obj) { if (obj && obj.__esModule) { return obj; } else { var newObj = {}; if (obj != null) { for (var key in obj) { if (Object.prototype.hasOwnProperty.call(obj, key)) newObj[key] = obj[key]; } } newObj.default = obj; return newObj; } }

function _toConsumableArray(arr) { if (Array.isArray(arr)) { for (var i = 0, arr2 = Array(arr.length); i < arr.length; i++) { arr2[i] = arr[i]; } return arr2; } else { return Array.from(arr); } }

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

window.QAPM = {};
// 初始化参数
// TODO, change this, pid,默认为ios的配置
var appId = '0';
// TODO, change this, 产品自身的版本号
var version = '1.0';
// TODO, change this, 当前登录的用户标识, 如 QQ 号, openid, 企业员工名字等
var userId = '10000';
// TODO, change this, 设备id
var deviceId = 'test';
// TODO, change this, appkey,默认为ios的配置
var appKey = '0-0';
// TODO, change this, athena上报的url
var athenaUrl = 'https://athena.qq.com/';
// TODO, change this, apm上报的域名
var qapmDamon = 'sngapm.qq.com';
var qapmProtol = 'https://';
var qapmUrl = '' + qapmProtol + qapmDamon;
// 上报间隔时间
var breadCrumbUploadInterval = 15;
var breadCrumbBuckets = '';
// TODO, change this, webview上报的白名单
var whiteUrlList = ['sngapm.qq.com', 'ten.sngapm.qq.com', 'qapm.qq.com', 'mbank.95559.com.cn', '182.119.80.192'];
// emonitor的参数
window.onerror = true;
var isTimingReported = false;

var jsErrorEnable = (0, _utils.isiOS)() || (0, _utils.isAndroid)();
var webMonitorEnable = (0, _utils.isiOS)();
var breadCrumbEnable = jsErrorEnable || webMonitorEnable;

var breadCrumbSetting = null;

var logLevel = 'debug';

if (_config.DEBUG) {
  appId = '770';
  version = '1.0';
  userId = '10000';
  deviceId = 'test';
  // appKey = '53416939-770';
  appKey = '0de5866b-770';
  jsErrorEnable = true;
  webMonitorEnable = true;
  breadCrumbEnable = true;
}

window.QAPMAndroidBreadCrumb = function () {
  if (breadCrumbEnable) {
    return (0, _utils.getBreadcrumbId)('_APM.LAG');
  } else {
    return '';
  }
};

var splitQAPMUrl = function splitQAPMUrl(url) {
  var urlList = url.split('//');
  if (urlList.length <= 1) {
    qapmProtol = '';
    qapmDamon = '';
    qapmUrl = '';
  } else {
    var _urlList = _slicedToArray(urlList, 2);

    qapmProtol = _urlList[0];
    qapmDamon = _urlList[1];

    qapmProtol += '//';
  }
};

var setQAPMUUID = function setQAPMUUID(uuid) {
  window.QAPM_UUID = uuid;
};

var resetUin = function resetUin(uin) {
  userId = uin;
  (0, _utils.resetCommonUin)(uin);
  var trackH5 = _athena2.default.Track.getInstance();
  trackH5.setField('user_id', userId);
};

var resetConfig = function resetConfig() {
  if ((0, _utils.isiOS)()) {
    try {
      // eslint-disable-next-line prefer-destructuring
      userId = window.qapmBaseInfo.userId;
      // eslint-disable-next-line prefer-destructuring
      deviceId = window.qapmBaseInfo.deviceId;
      // eslint-disable-next-line prefer-destructuring
      appKey = window.qapmBaseInfo.appKey;
      // eslint-disable-next-line prefer-destructuring
      appId = appKey.split('-')[1];
      // eslint-disable-next-line prefer-destructuring
      version = window.qapmBaseInfo.version;
      // eslint-disable-next-line prefer-destructuring
      jsErrorEnable = window.qapmBaseInfo.jsErrorEnable;
      // eslint-disable-next-line prefer-destructuring
      webMonitorEnable = window.qapmBaseInfo.webMonitorEnable;
      // eslint-disable-next-line prefer-destructuring
      breadCrumbEnable = window.qapmBaseInfo.breadCrumbEnable;
      // eslint-disable-next-line prefer-destructuring
      athenaUrl = window.qapmBaseInfo.athenaUrl;
      // eslint-disable-next-line prefer-destructuring
      qapmUrl = window.qapmBaseInfo.qapmUrl;
      // eslint-disable-next-line prefer-destructuring
      breadCrumbUploadInterval = window.qapmBaseInfo.breadCrumbUploadInterval;
      // eslint-disable-next-line prefer-destructuring
      breadCrumbBuckets = window.qapmBaseInfo.breadCrumbBuckets;
      splitQAPMUrl(qapmUrl);
      if (athenaUrl !== '') {
        whiteUrlList.push(athenaUrl);
      }
      if (qapmDamon !== '') {
        whiteUrlList.push(qapmDamon);
      }
    } catch (e) {
      console.log(e.toString());
    }
  }

  if ((0, _utils.isAndroid)()) {
    try {
      userId = window.QAPMAndroidJsBridge.getUin();
      deviceId = window.QAPMAndroidJsBridge.getDeviceId();
      appKey = window.QAPMAndroidJsBridge.getAppkey();
      // eslint-disable-next-line prefer-destructuring
      appId = appKey.split('-')[1];
      version = window.QAPMAndroidJsBridge.getVersion();
      jsErrorEnable = window.QAPMAndroidJsBridge.getJsErrorEnable();
      webMonitorEnable = window.QAPMAndroidJsBridge.getWebMonitorEnable();
      breadCrumbEnable = window.QAPMAndroidJsBridge.getBreadCrumbEnable();
      athenaUrl = window.QAPMAndroidJsBridge.getAthenaUrl();
      qapmUrl = window.QAPMAndroidJsBridge.getQAPMUrl();
      breadCrumbUploadInterval = window.QAPMAndroidJsBridge.getBreadCrumbUploadInterval();
      breadCrumbBuckets = window.QAPMAndroidJsBridge.getBreadCrumbBuckets();
      splitQAPMUrl(qapmUrl);
      if (athenaUrl !== '') {
        whiteUrlList.push(athenaUrl);
      }
      if (qapmDamon !== '') {
        whiteUrlList.push(qapmDamon);
      }
    } catch (e) {
      console.log(e.toString());
    }
  }
};

var initQAPMJs = function initQAPMJs(option) {
  var pAppKey = option.pAppKey,
      pUserId = option.pUserId,
      pUUID = option.pUUID,
      _option$pDeviceId = option.pDeviceId,
      pDeviceId = _option$pDeviceId === undefined ? '' : _option$pDeviceId,
      _option$pQAPMUrl = option.pQAPMUrl,
      pQAPMUrl = _option$pQAPMUrl === undefined ? qapmUrl : _option$pQAPMUrl,
      _option$pAthenaUrl = option.pAthenaUrl,
      pAthenaUrl = _option$pAthenaUrl === undefined ? athenaUrl : _option$pAthenaUrl,
      _option$pJsErrorEnabl = option.pJsErrorEnable,
      pJsErrorEnable = _option$pJsErrorEnabl === undefined ? true : _option$pJsErrorEnabl,
      _option$pWebMonitorEn = option.pWebMonitorEnable,
      pWebMonitorEnable = _option$pWebMonitorEn === undefined ? true : _option$pWebMonitorEn,
      _option$pBreadCrumbEn = option.pBreadCrumbEnable,
      pBreadCrumbEnable = _option$pBreadCrumbEn === undefined ? true : _option$pBreadCrumbEn,
      _option$pBreadCrumbSe = option.pBreadCrumbSetting,
      pBreadCrumbSetting = _option$pBreadCrumbSe === undefined ? null : _option$pBreadCrumbSe,
      _option$pLogLevel = option.pLogLevel,
      pLogLevel = _option$pLogLevel === undefined ? 'debug' : _option$pLogLevel;

  userId = pUserId;
  deviceId = pDeviceId;
  appKey = pAppKey;
  // eslint-disable-next-line prefer-destructuring
  appId = appKey.split('-')[1];
  jsErrorEnable = pJsErrorEnable;
  webMonitorEnable = pWebMonitorEnable;
  breadCrumbEnable = pBreadCrumbEnable;
  window.QAPM_UUID = pUUID;
  athenaUrl = pAthenaUrl;
  qapmUrl = pQAPMUrl;
  breadCrumbSetting = pBreadCrumbSetting;
  splitQAPMUrl(qapmUrl);
  if (athenaUrl !== '') {
    whiteUrlList.push(athenaUrl);
  }
  if (qapmDamon !== '') {
    whiteUrlList.push(qapmDamon);
  }
  logLevel = pLogLevel;
};

var Monitor = function () {
  function Monitor() {
    var qapmBaseUrl = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : '';
    var _ref = arguments[1];
    var qapm = _ref.qapm,
        config = _ref.config;

    _classCallCheck(this, Monitor);

    (0, _config.setToken)(false);
    this.qapm = qapm;
    (0, _config.setThreshold)(config.is_slow);
    var debounceReport = (0, _utils.debounce)(_utils.doReport, 0, function () {});
    var key = (0, _utils.getKey)(qapm.app_key);
    var context = this;
    context.qapm.p_id = key.p_id;
    if (qapmBaseUrl === '') qapmBaseUrl = _config.baseUrl;
    this.qapmBaseUrl = qapmBaseUrl;
    debounceReport({
      baseUrl: this.qapmBaseUrl,
      data: { app_key: key.private_app_key, p_id: key.p_id },
      method: 'GET'
    });
    // TODO 调用JS桥进行传入设备数据
    //  initByJsBridge
  }

  _createClass(Monitor, [{
    key: 'config',
    value: function config() {
      var opts = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : {};

      for (var op in opts) {
        this[op] = opts[op];
        // if (
        //   ['baseUrl', 'delay', 'name'].indexOf(
        //     String(op),
        //   ) !== -1
        // ) {
        //   this[op] = opts[op];
        // }
      }
      return this;
    }
  }, {
    key: 'send',
    value: function send() {
      var debounceReport = (0, _utils.debounce)(_utils.doReport, 2000, function () {});
      var partData = (0, _parts.getParts)(whiteUrlList, breadCrumbEnable);
      if (!partData.parts || partData.parts.length === 0) {
        return;
      }
      var mergeData = Object.assign({}, Object.assign({}, this.qapm, partData), { uin: userId });
      debounceReport({
        baseUrl: this.qapmBaseUrl,
        data: mergeData,
        method: 'POST'
      });
    }
  }]);

  return Monitor;
}();

// Very happy integration that'll prepend and append very happy stick figure to the message
// class HappyIntegration {
//   constructor() {
//     this.name = 'HappyIntegration';
//   }
//
//   setupOnce() {
//     Sentry.addGlobalEventProcessor(event => {
//       const self = Sentry.getCurrentHub().getIntegration(HappyIntegration);
//       // Run the integration ONLY when it was installed on the current Hub
//       if (self) {
//         if (event.message === 'Happy Message') {
//           event.message = `\\o/ ${event.message} \\o/`;
//         }
//       }
//       return event;
//     });
//   }
// }

// class HappyTransport extends Sentry.Transports.BaseTransport {
//   sendEvent(event) {
//     console.log(
//       `This is the place where you'd implement your own sending logic. It'd get url: ${this.url} and an event itself:`,
//       event,
//     );
//
//     return {
//       status: 'success',
//     };
//   }
// }


var initEmonitor = function initEmonitor() {
  var qapmBaseUrl = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : '';

  var _ref2 = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : {},
      qapm = _ref2.qapm,
      config = _ref2.config;

  return new Monitor(qapmBaseUrl, {
    qapm: qapm,
    config: config
  });
};

var initAnthena = function initAnthena(interval) {
  // TrackJS
  var urlTransformer = function urlTransformer(url) {
    var pickParamsFunc = _athena2.default.transformerPickParams([]); // 页面 url 去掉所有 query params
    var pickPathAndSearch = _athena2.default.transformerPickPathAndSearch(); // 页面 url 去掉域名及协议
    return pickPathAndSearch(pickParamsFunc(url));
  };

  var trackH5 = _athena2.default.Track.getInstance();
  if (breadCrumbSetting !== null) {
    for (var setting in breadCrumbSetting) {
      trackH5.enableTracker(setting, breadCrumbSetting[setting]);
    }
  } else {
    trackH5.enableTracker('appTracker', { urlTransformer: urlTransformer });
    trackH5.enableTracker('pageTracker', {});
    trackH5.enableTracker('requestTracker', {});
    trackH5.enableTracker('uiActionTracker', {});
    // trackH5.enableTracker("consoleTracker", {});
  }
  trackH5.setField('app_id', appId);
  trackH5.setField('version', version);
  trackH5.setField('user_id', userId);
  trackH5.setField('device_id', deviceId);
  trackH5.setField('athena_base_url', athenaUrl);
  trackH5.setField('buckets', breadCrumbBuckets.split(';'));
  trackH5.setField('log_level', logLevel);
  if ((0, _utils.isAndroid)() || (0, _utils.isiOS)()) {
    trackH5.setField('upload_period', interval * 60 * 1000);
  } else {
    trackH5.setField('upload_period', 5000);
  }
  trackH5.start();
};

var initSentry = function initSentry() {
  var unusedFiled = ['breadcrumbs', 'sdk', 'platform', 'request', 'release', 'environment', 'extra'];
  var filed = (0, _utils.getCommonFiled)(_utils.PLUGIN.JS_ERROR);
  Sentry.init({
    // Client's DSN.
    //  协议结构类型protocol, productKey, user='10000', version = '', host, port = ''
    dsn: '' + qapmProtol + appKey + ':' + userId + ':' + version + ':' + filed.plugin + '@' + qapmDamon,
    // An array of strings or regexps that'll be used to ignore specific errors based on their type/message
    // ignoreErrors: [/PickleRick_\d\d/, 'RangeError'],
    // An array of strings or regexps that'll be used to ignore specific errors based on their origin url
    blacklistUrls: ['external-lib.js'],
    // An array of strings or regexps that'll be used to allow specific errors based on their origin url
    // whitelistUrls: ['http://localhost:5000', 'https://browser.sentry-cdn', 'file://'],
    // Debug mode with valuable initialization/lifecycle informations.
    debug: true,
    // Whether SDK should be enabled or not.
    enabled: true,
    // Custom integrations callback
    integrations: function integrations(_integrations) {
      return [].concat(_toConsumableArray(_integrations));
    },

    // A release identifier.
    release: '1537345109360',
    // An environment identifier.
    environment: 'staging',
    // Custom event transport that will be used to send things to Sentry
    // transport: HappyTransport,
    // Method called for every captured event
    // async beforeSend(event, hint) {
    //   // Because beforeSend and beforeBreadcrumb are async, user can fetch some data
    //   // return a promise, or whatever he wants
    //   // Our CustomError defined in errors.js has `someMethodAttachedToOurCustomError`
    //   // which can mimick something like a network request to grab more detailed error info or something.
    //   // hint is original exception that was triggered, so we check for our CustomError name
    //   // if (hint.originalException.name === 'CustomError') {
    //   //   const serverData = await hint.originalException.someMethodAttachedToOurCustomError();
    //   //   event.extra = {
    //   //     ...event.extra,
    //   //     serverData,
    //   //   };
    //   // }
    //   console.log(event);
    //   return event;
    // },
    // 在上报之前修改上报内容
    // eslint-disable-next-line no-unused-vars
    beforeSend: function beforeSend(event, hint) {
      var cur_filed = (0, _utils.getCommonFiled)(_utils.PLUGIN.JS_ERROR);
      event.url = event.request.url;
      event.headers = 'User-Agent: ' + event.request.headers['User-Agent'];
      if (breadCrumbEnable) {
        event.bread_crumb_id = (0, _utils.getBreadcrumbId)('_APM.JS_ERROR');
      } else {
        event.bread_crumb_id = '';
      }
      // 目前level固定为error, 后期用户可使用captureMessage(message, level）设置等级
      event.level = 'error';
      for (var i = 0; i < unusedFiled.length; i++) {
        delete event[unusedFiled[i]];
      }
      event.p_id = appId;
      cur_filed.apn_type = (0, _utils.getNetworkType)();
      event.browser = (0, _utils.getBrowserInfo)();
      Object.assign(event, cur_filed);
      return event;
    }
  });
  console.log('init js error finished');
};

var qapmJsStart = function qapmJsStart() {
  if (appId === '0') {
    console.log('qapm', 'appid not init');
    return;
  }
  (0, _utils.initCommonFiled)({
    uin: userId,
    version: version,
    app_key: '' + appKey,
    deviceid: deviceId
  });

  if (jsErrorEnable) {
    initSentry();
  }

  var emonitorIns = null;
  if (webMonitorEnable) {
    emonitorIns = initEmonitor(qapmUrl, {
      qapm: (0, _utils.getCommonFiled)(_utils.PLUGIN.WEBVIEW),
      config: {
        is_slow: 2000
      }
    });
    console.log('init web monitor finished');
  }

  if (document.readyState === 'complete') {
    if (breadCrumbEnable) {
      initAnthena(breadCrumbUploadInterval);
    }
    setTimeout(function () {
      if (!isTimingReported) {
        if (emonitorIns !== null) {
          emonitorIns.send();
        }
        isTimingReported = true;
      }
    }, 2000);
  } else {
    window.addEventListener('load', function () {
      if (breadCrumbEnable) {
        initAnthena(breadCrumbUploadInterval);
      }
      setTimeout(function () {
        if (!isTimingReported) {
          if (typeof onLoad === 'function') {
            // eslint-disable-next-line no-undef
            onLoad();
          } else if (emonitorIns !== null) {
            emonitorIns.send();
          }
          isTimingReported = true;
        }
      }, 0);
    }, false);
  }
};

resetConfig();

// 提供给用户的接口
window.QAPM.QAPMCaptureMessage = function (message, level) {
  Sentry.captureMessage(message, level);
};
window.QAPM.QAPMCaptureException = function (error) {
  Sentry.captureException(error);
};
window.QAPM.QAPMCaptureEvent = function (event) {
  Sentry.captureEvent(event);
};
window.QAPM.initQAPMJs = initQAPMJs;
window.QAPM.qapmJsStart = qapmJsStart;
window.QAPM.setQAPMUUID = setQAPMUUID;
window.QAPM.resetConfig = resetConfig;
window.QAPM.resetUin = resetUin;

exports.initQAPMJs = initQAPMJs;
exports.qapmJsStart = qapmJsStart;
exports.resetConfig = resetConfig;
exports.getRcTiming = _performance.getRcTiming;
exports.getPfTiming = _performance.getPfTiming;
exports.getCdnTiming = _performance.getCdnTiming;
exports.getParts = _parts.getParts;
exports.setQAPMUUID = setQAPMUUID;
exports.resetUin = resetUin;
exports.trace = _athena2.default;

/***/ }),

/***/ "./src/performance/data.js":
/*!*********************************!*\
  !*** ./src/performance/data.js ***!
  \*********************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
  value: true
});
var getOtherData = function getOtherData() {
  var otherData = {
    fps_json_arr: [],
    cup_info_json_arr: [],
    memory_info_json_arr: [],
    network_info_json_arr: [],
    gpu_info_json_arr: [],
    proxy_type: 0,
    socket_reuse_pro: 0,
    qproxy_strategy: 0,
    hostcount: 0,
    apn_type: 4,
    version: 'V1',
    quic_pro: 0,
    frame_start_time: 0,
    frame_end_time: 0,
    layer_num: 0,
    total_layer_mem: 0,
    min_layer_size: 0,
    max_layer_size: 0,
    base_time: 0
  };
  return otherData;
};

exports.getOtherData = getOtherData;

/***/ }),

/***/ "./src/performance/index.js":
/*!**********************************!*\
  !*** ./src/performance/index.js ***!
  \**********************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.getRecData = exports.getCdnTiming = exports.getSingletonTiming = exports.getRcTiming = exports.getPfTiming = undefined;

var _utils = __webpack_require__(/*! ../utils */ "./src/utils/index.js");

var _config = __webpack_require__(/*! ../constants/config */ "./src/constants/config/index.js");

var _untils = __webpack_require__(/*! ./untils */ "./src/performance/untils.js");

// 计算加载时间

var getPfTiming = function getPfTiming() {
  try {
    var _performance = window.performance || window.webkitPerformance || window.msPerformance || window.mozPerformance;

    if (_performance === undefined) {
      return false;
    }
    var timing = _performance.timing;

    var times = {};

    times.first_word = timing.responseStart - timing.fetchStart;
    times.first_screen = timing.responseEnd - timing.fetchStart;
    times.page_finish = timing.loadEventEnd - timing.fetchStart;
    times.dom_loading = timing.domLoading - timing.fetchStart;
    times.dom_interactive = timing.domInteractive - timing.fetchStart;
    // eslint-disable-next-line max-len
    times.dom_content_loaded_event = timing.domContentLoadedEventEnd - timing.fetchStart;
    times.dom_complete = timing.domComplete - timing.fetchStart;

    return times;
  } catch (err) {
    console.warn('err', err);
    return {};
  }
};

var calculateTime = function calculateTime(domTime, origin) {
  return domTime + origin <= 0 ? 0 : Math.round(domTime + origin);
};
// 统计页面资源性能
var getRecData = function getRecData(whiteUrlList) {
  try {
    if (!window.performance || !window.performance.getEntries) {
      console.warn('prerformance is not supported');
      return [];
    }
    var _window = window,
        _performance2 = _window.performance;

    var resource = _performance2.getEntries();
    if (!resource && !resource.length) {
      return [];
    }
    var mainResource = {};
    var subResourceJsonArr = [];
    try {
      resource.forEach(function (item) {
        // 过滤白名单
        var isWhite = false;
        whiteUrlList.forEach(function (url) {
          if (item.name.indexOf(url) !== -1) {
            isWhite = true;
          }
        });
        if (isWhite) {
          return;
        }
        // 顺序不可变
        var origin = _performance2.timing.navigationStart;
        var json = {
          shortUrl: item.name,
          resource_type: _untils.TYPE[item.initiatorType],
          proxy_type: item.nextHopProtocol,
          qProxyStrategy: 0,
          website_address: ':0',
          dns_end: calculateTime(item.domainLookupEnd, origin),
          dns_start: calculateTime(item.domainLookupStart, origin),
          connect_end: calculateTime(item.connectEnd, origin),
          connect_start: calculateTime(item.connectStart, origin),
          ssl_handshake_end: item.secureConnectionStart === 0 ? 0 : calculateTime(item.connectEnd, origin),
          ssl_handshake_start: item.secureConnectionStart === 0 ? 0 : calculateTime(item.secureConnectionStart, origin),
          send_end: calculateTime(item.responseStart, origin),
          send_start: calculateTime(item.requestStart, origin),
          recv_end: calculateTime(item.responseEnd, origin),
          recv_start: calculateTime(item.responseStart, origin),
          zero: 0,
          recv_bytes: item.encodedBodySize !== undefined ? item.encodedBodySize : 0,
          session_resumption: 0,
          cipher_suit: 0,
          proxy_data: 0,
          socket_reused: 0,
          was_cached: 0,
          expired_time: 86400000,
          error_id: 0,
          resourceRequestTriggerTime: calculateTime(item.requestStart, origin),
          resourceRequestHandleTime: calculateTime(item.domainLookupEnd, origin),
          status_code: 200,
          connectInfo: 0,
          redirect_end_time: item.redirectEnd === 0 ? 0 : calculateTime(item.redirectEnd, origin),
          redirect_start_time: item.redirectStart === 0 ? 0 : calculateTime(item.redirectEnd, origin),
          redirect_times: item.redirectStart !== 0 ? 2 : 1,
          is_first_screen_resource: 0,
          sent_bytes: 0,
          http_method: 'GET',
          content_encoding: ''
        };
        //   Object.assign(json, getRecOtherData); 添加其他信息
        if (typeof json.resource_type !== 'undefined') {
          if (item instanceof PerformanceResourceTiming) {
            subResourceJsonArr.push(json);
          } else {
            mainResource.push(json);
          }
        }
      });
    } catch (err) {
      console.error('get resourceTiming err::::', err);
    }
    if (JSON.stringify(mainResource) === '{}') {
      var timing = _performance2.timing;

      mainResource = {
        shortUrl: window.location.href,
        resource_type: 0,
        proxy_type: 0,
        qProxyStrategy: 0,
        website: ':0',
        dns_end: timing.domainLookupEnd,
        dns_start: timing.domainLookupStart,
        connect_end: timing.connectEnd,
        connect_start: timing.connectStart,
        ssl_handshake_end: timing.secureConnectionStart === 0 ? 0 : timing.connectEnd,
        ssl_handshake_start: timing.secureConnectionStart,
        send_end: timing.responseStart,
        send_start: timing.requestStart,
        recv_end: timing.responseEnd,
        recv_start: timing.responseStart,
        zero: 0,
        recv_bytes: 0,
        session_resumption: 0,
        cipher_suit: 0,
        proxy_data: 0,
        socket_reused: 0,
        was_cached: 0,
        expired_time: 86400000,
        error_id: 0,
        resourceRequestTriggerTime: timing.requestStart,
        resourceRequestHandleTime: timing.domainLookupEnd,
        status_code: 200,
        connectInfo: 0,
        redirect_end_time: timing.redirectEnd,
        redirect_start_time: timing.redirectStart,
        redirect_times: _performance2.navigation.redirectCount + 1,
        is_first_screen_resource: 0,
        sent_bytes: 0,
        http_method: 'GET',
        content_encoding: ''
      };
    }
    var data = {
      main_resource: (0, _untils.changMainSrcString)(mainResource),
      sub_resource_json_arr: (0, _untils.changToString)(subResourceJsonArr)
    };
    return data;
  } catch (err) {
    console.warn('get performance happen error');
    return [];
  }
};
var getSingletonTiming = function getSingletonTiming() {
  try {
    var _performance3 = window.performance || window.webkitPerformance || window.msPerformance || window.mozPerformance;

    if (_performance3 === undefined) {
      return false;
    }
    var timing = _performance3.timing;

    var data = {};
    data.first_screen = timing.loadEventStart;
    data.dom_loading = timing.domLoading;
    data.page_finish = timing.loadEventEnd;
    data.dom_interactive = timing.domInteractive;
    data.dom_complete = timing.domComplete;
    data.first_word = timing.responseStart;
    data.dom_content_loaded_event_start = timing.domContentLoadedEventStart;
    data.dom_content_loaded_event_end = timing.domContentLoadedEventEnd;
    // 首字时间
    data.first_word_stamp = timing.domLoading;
    // 首屏时间
    data.first_screen_stamp = timing.loadEventEnd;
    // 首字节时间
    data.first_byte_stamp = timing.responseStart;
    data.frame_start_time = 0;
    data.frame_end_time = 0;
    // 解析耗时
    data.parser_elapsed = timing.domInteractive;
    // 渲染耗时
    data.render_elapsed = timing.domContentLoadedEventEnd;
    // 上屏耗时
    data.layout_elapsed = timing.loadEventEnd;
    data.page_start = timing.fetchStart;
    data.is_system_kernel = (0, _utils.DeviceInfo)();
    data.start_monitor_time = timing.navigationStart;
    data.stop_monitor_time = timing.loadEventEnd;
    return data;
  } catch (err) {
    console.warn('err', err);
    return {};
  }
};
var getRcTiming = function getRcTiming() {
  var _ref = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : {},
      name = _ref.name,
      type = _ref.type;

  try {
    if (!window.performance && !window.performance.getEntries) {
      console.warn('prerformance is not supported');
      return [];
    }
    var resource = performance.getEntries();
    var resourceList = [];
    if (!resource && !resource.length) {
      return resourceList;
    }
    try {
      resource.forEach(function (item) {
        var json = {
          name: item.name,
          time_redirect: item.redirectEnd - item.redirectStart,
          time_dns: item.domainLookupEnd - item.domainLookupStart,
          time_requestTime: item.responseEnd - item.requestStart,
          time_tcp: item.connectEnd - item.connectStart,
          type: item.initiatorType,
          starttime: Math.floor(item.startTime),
          entryType: item.entryType,
          duration: Math.floor(item.duration) || 0,
          decodedBodySize: item.decodedBodySize || 0,
          nextHopProtocol: item.nextHopProtocol,
          json_entries: JSON.stringify(item)
        };
        resourceList.push(json);
      });
    } catch (err) {
      console.error('get resourceTiming err::::', err);
    }
    var match = [];
    if (name) {
      match = resourceList.filter(function (r) {
        return r.name === name;
      });
      return match[0];
    }
    if (type) {
      match = resourceList.filter(function (r) {
        return r.type === type;
      });
      return match;
    }
    return resourceList;
  } catch (err) {
    console.warn('get performance happen error');
    return [];
  }
};

var getCdnTiming = function getCdnTiming() {
  var CDNRCININFO = {};
  _config.REPORTTYPES.forEach(function (type) {
    CDNRCININFO[type] = (0, _utils.transformRc)(getRcTiming({
      type: type
    }));
  });
  return CDNRCININFO;
};
exports.getPfTiming = getPfTiming;
exports.getRcTiming = getRcTiming;
exports.getSingletonTiming = getSingletonTiming;
exports.getCdnTiming = getCdnTiming;
exports.getRecData = getRecData;

/***/ }),

/***/ "./src/performance/network.js":
/*!************************************!*\
  !*** ./src/performance/network.js ***!
  \************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
  value: true
});
var getNetWork = function getNetWork() {
  if (!document) {
    return {};
  }
  var data = {
    url: document.URL ? document.URL : '',
    referer: document.referrer,
    qproxy_strategy: 0
  };
  return data;
};

exports.getNetWork = getNetWork;

/***/ }),

/***/ "./src/performance/parts.js":
/*!**********************************!*\
  !*** ./src/performance/parts.js ***!
  \**********************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.getParts = undefined;

var _index = __webpack_require__(/*! ./index */ "./src/performance/index.js");

var _config = __webpack_require__(/*! ../constants/config */ "./src/constants/config/index.js");

var _network = __webpack_require__(/*! ./network */ "./src/performance/network.js");

var _data = __webpack_require__(/*! ./data */ "./src/performance/data.js");

var _utils = __webpack_require__(/*! ../utils */ "./src/utils/index.js");

var getParts = function getParts(whiteUrlList, breadCrumbEnable) {
  var partData = {
    parts: []
  };
  var data = {
    category: 'webview_x5_metrics',
    is_slow: 0,
    url: '',
    apn_type: 0,
    first_word: 0,
    first_screen: 0,
    page_finish: 0,
    dom_loading: 0,
    dom_interactive: 0,
    dom_content_loaded_event: 0,
    dom_complete: 0

  };
  Object.assign(data, (0, _index.getPfTiming)(), (0, _network.getNetWork)());
  if (data.page_finish < 0 || data.page_finish > 2147483647) {
    return partData;
  }
  if (data.page_finish > (0, _config.getThreshold)()) {
    data.is_slow = 1;
  }
  partData.parts.push(data);
  if (data.page_finish > (0, _config.getThreshold)()) {
    var singleton = {
      category: 'webview_x5_singleton'
    };
    Object.assign(singleton, (0, _index.getSingletonTiming)(), (0, _index.getRecData)(whiteUrlList), (0, _network.getNetWork)(), (0, _data.getOtherData)());

    // 如果个例里面主资源不存在则表示数据异常不用上报
    if (!singleton.main_resource) {
      return partData;
    }
    // 添加用户行为上报
    var breadcrumbs = { bread_crumb_id: '' };
    if (breadCrumbEnable) {
      breadcrumbs.bread_crumb_id = (0, _utils.getBreadcrumbId)('_APM.LAG');
    } else {
      breadcrumbs.bread_crumb_id = '';
    }

    Object.assign(singleton, breadcrumbs);
    partData.parts.push(singleton);
  }
  return partData;
  // TO-DO
};

exports.getParts = getParts;

/***/ }),

/***/ "./src/performance/untils.js":
/*!***********************************!*\
  !*** ./src/performance/untils.js ***!
  \***********************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
  value: true
});
var TYPE = {
  default: -1,
  mianframe: 0,
  subframe: 1,
  css: 2,
  script: 3,
  img: 4,
  FONT_RESOURCE: 5,
  SUB_RESOURCE: 6,
  OBJECT: 7,
  audio: 8,
  video: 8,
  media: 8,
  WORKER: 9,
  SHARED_WORKER: 10,
  fetch: 11,
  FAVICON: 12,
  xmlhttprequest: 13,
  RESOURCE_TYPE_PING: 14,
  RESOURCE_TYPE_SERVICE_WORKER: 15,
  RESOURCE_TYPE_CSP_REPORT: 16,
  RESOURCE_TYPE_PLUGIN_RESOURCE: 17,
  RESOURCE_TYPE_LAST_TYPE: 18,
  LAST_TYPE: 19,
  navigation: 0
};

var changMainSrcString = function changMainSrcString(data) {
  if (!data) return '';
  var array = Object.keys(data).map(function (e) {
    return data[e];
  });
  var result = array[0];
  for (var i = 1, len = array.length; i < len; i++) {
    result += '||' + array[i];
  }
  return result;
};

var changToString = function changToString(json) {
  if (!json) return '';
  var result = [];
  for (var i = 0, len = json.length; i < len; i++) {
    result.push(changMainSrcString(json[i]));
  }
  return result;
};

exports.TYPE = TYPE;
exports.changToString = changToString;
exports.changMainSrcString = changMainSrcString;

/***/ }),

/***/ "./src/utils/index.js":
/*!****************************!*\
  !*** ./src/utils/index.js ***!
  \****************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.getCommonFiled = exports.initCommonFiled = exports.resetCommonUin = exports.PLUGIN = exports.getBreadcrumbId = exports.getNetworkType = exports.getBrowserInfo = exports.isAndroid = exports.isiOS = exports.DeviceInfo = exports.getKey = exports.autoRetain = exports.filterCgiResp = exports.getRetCodeOrMsg = exports.traversal = exports.getLocalUniqueId = exports.merge = exports.transformRc = exports.isNumeric = exports.doReport = exports.formatParams = exports.debounce = exports.isReport = exports.getCookie = exports.getUrlParam = exports.processStackMsg = exports.emptyFunction = undefined;

var _athena = __webpack_require__(/*! @tencent/athena */ "../athena/src/index-h5.js");

var _athena2 = _interopRequireDefault(_athena);

var _index = __webpack_require__(/*! ./types/index */ "./src/utils/types/index.js");

var _index2 = __webpack_require__(/*! ./url/index */ "./src/utils/url/index.js");

var _index3 = __webpack_require__(/*! ../constants/config/index */ "./src/constants/config/index.js");

var _index4 = __webpack_require__(/*! ../constants/boss/index */ "./src/constants/boss/index.js");

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

/* eslint-disable */
var TYPE_UNKNOWN = 0x000;
var TYPE_NET = 0x001;
var TYPE_WAP = 0x002;
var TYPE_WIFI = 0x004;
var T_APN_CMWAP = 0x008; // 移动wap
var T_APN_3GWAP = 0x010; // 联通3G-wap
var T_APN_UNIWAP = 0x020; // 联通wap
var T_APN_CTWAP = 0x040; // 电信wap
var T_APN_CTNET = 0x080; // 电信3G net
var T_APN_UNINET = 0x100; // 联通net
var T_APN_3GNET = 0x200; // 联通3G-net
var T_APN_CMNET = 0x400; // 移动net
var T_APN_CTLTE = 0x800; // 电信4G
var T_APN_WONET = 0x1000; // 联通4G
var T_APN_CMLTE = 0x2000; // 移动4G
/* eslint-enable */

var emptyFunction = exports.emptyFunction = function emptyFunction() {};
// https://developer.mozilla.org/zh-CN/docs/Web/API/Network_Information_API
// http://www.honglei.net/?p=340
var processStackMsg = exports.processStackMsg = function processStackMsg(error) {
  var stack = error.stack.replace(/\n/gi, '').replace(/\bat\b/gi, '@').split('@').slice(0, 9).map(function (v) {
    return v.replace(/^\s*|\s*$/g, '');
  }).join('~').replace(/\?[^:]+/gi, '');
  var msg = error.toString();
  if (stack.indexOf(msg) < 0) {
    stack = msg + '@' + stack;
  }
  return stack;
};
var getUrlParam = exports.getUrlParam = function getUrlParam(_ref) {
  var name = _ref.name,
      _ref$url = _ref.url,
      url = _ref$url === undefined ? window.location.href : _ref$url;

  // eslint-disable-next-line no-useless-escape
  name = name.replace(/[\[\]]/g, '\\$&');
  var regex = new RegExp('[?&]' + name + '(=([^&#]*)|&|#|$)');
  var results = regex.exec(url);
  if (!results) {
    return '';
  }
  if (!results[2]) {
    return '';
  }
  return decodeURIComponent(results[2].replace(/\+/g, ' '));
};
var getCookie = exports.getCookie = function getCookie(name) {
  var nameEQ = encodeURIComponent(name) + '=';
  var ca = document.cookie.split(';');
  for (var i = 0; i < ca.length; i++) {
    var c = ca[i];
    while (c.charAt(0) === ' ') {
      c = c.substring(1, c.length);
    }if (c.indexOf(nameEQ) === 0) {
      return decodeURIComponent(c.substring(nameEQ.length, c.length));
    }
  }

  return null;
};
var isReport = exports.isReport = function isReport() {
  var sampling = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : 1;
  return Math.random() <= sampling;
};
var debounce = exports.debounce = function debounce(func, delay, callback) {
  var timer = null;
  // eslint-disable-next-line func-names
  return function () {
    for (var _len = arguments.length, rest = Array(_len), _key = 0; _key < _len; _key++) {
      rest[_key] = arguments[_key];
    }

    var context = this;
    clearTimeout(timer);
    timer = setTimeout(function () {
      func.apply(context, rest);
      if (typeof callback === 'function') {
        callback();
      }
    }, delay);
  };
};
var formatParams = exports.formatParams = function formatParams(data) {
  var arr = [];
  for (var name in data) {
    arr.push(encodeURIComponent(name) + '=' + encodeURIComponent(data[name]));
  }
  return arr.join('&');
};

var doReport = exports.doReport = function doReport(_ref2) {
  var baseUrl = _ref2.baseUrl,
      data = _ref2.data,
      _ref2$method = _ref2.method,
      method = _ref2$method === undefined ? 'GET' : _ref2$method;

  if (method === 'GET') {
    var _xmlhttp = null;
    if (window.XMLHttpRequest) {
      _xmlhttp = new XMLHttpRequest();
    } else {
      // eslint-disable-next-line no-undef
      _xmlhttp = new ActiveXObject('Microsoft.XMLHTTP');
    }
    _xmlhttp.open('GET', baseUrl + '/entrance/' + data.p_id + '/authorize/?' + formatParams(data), true);
    _xmlhttp.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
    _xmlhttp.send();
    _xmlhttp.onreadystatechange = function () {
      if (_xmlhttp.readyState === 4 && _xmlhttp.status === 200) {
        (0, _index3.setToken)(true);
      }
    };
  } else if (method === 'POST') {
    if (!(0, _index3.getToken)()) {
      return;
    }
    var params = {
      plugin: data.plugin,
      p_id: data.p_id,
      uin: data.uin,
      arch: data.arch,
      version: data.version,
      device: data.device,
      q: 0
    };
    var _xmlhttp2 = null;
    if (window.XMLHttpRequest) {
      _xmlhttp2 = new XMLHttpRequest();
    } else {
      // eslint-disable-next-line no-undef
      _xmlhttp2 = new ActiveXObject('Microsoft.XMLHTTP');
    }
    _xmlhttp2.open('POST', baseUrl + '/entrance/' + params.p_id + '/uploadJson/?' + formatParams(params), true);

    _xmlhttp2.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
    _xmlhttp2.send(JSON.stringify(data));
  }
};

var isNumeric = exports.isNumeric = function isNumeric(n) {
  return !isNaN(parseFloat(n)) && isFinite(n);
};

var transformRc = exports.transformRc = function transformRc(source) {
  var returnedArr = [];
  if ((0, _index.isArray)(source)) {
    source.forEach(function (item) {
      var returnedVal = {};
      for (var sr in item) {
        if (_index3.CDNQUALITY[sr]) {
          returnedVal[_index3.CDNQUALITY[sr]] = item[sr];
          if (_index3.CDNQUALITY[sr] === 'resurl') {
            var _parseLink = (0, _index2.parseLink)(item[sr]),
                hostname = _parseLink.hostname,
                path = _parseLink.path;

            returnedVal.reshost = hostname;
            returnedVal.respath = path;
            returnedVal.httpcode = 200;
          }
        }
      }
      returnedArr.push(returnedVal);
    });
  }
  return returnedArr;
};

var merge = exports.merge = function merge(mergeData) {
  var opts = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : {};

  var mergeOpts = {};
  var changedKey = [];
  if ((0, _index.isObject)(opts)) {
    for (var op in opts) {
      if (_index4.CANMODIFYKEYS.indexOf(String(op)) !== -1) {
        mergeOpts[op] = opts[op];
        changedKey.push(op);
      } else {
        console.warn(op, 'could not be modify.');
      }
    }
  }
  return Object.assign({}, mergeData, mergeOpts);
};

var getLocalUniqueId = exports.getLocalUniqueId = function getLocalUniqueId() {
  var localUniqueId = '';
  try {
    localUniqueId = window.localStorage.getItem('emonitor.hc_pgv_pvid');
    if (localUniqueId) {
      return localUniqueId;
    }
    var genUIdTime = new Date().getTime();
    localUniqueId = 'ek' + [genUIdTime, Math.floor(genUIdTime * Math.random() * Math.random()).toString().slice(-5)].join('');
    window.localStorage.setItem('emonitor.hc_pgv_pvid', localUniqueId);
    return localUniqueId;
  } catch (err) {
    console.warn('emonitor.hc_pgv_pvid get error', err);
    return localUniqueId;
  }
};

/**
 * 遍历并获取指定值
 * @param {Object} data 响应信息
 * @param {String|Array} data 要过滤的响应信息字段
 * @param {String} defaultValue 默认值
 */
var traversal = exports.traversal = function traversal(data, path) {
  var defaultValue = arguments.length > 2 && arguments[2] !== undefined ? arguments[2] : '';

  // eslint-disable-next-line no-void
  var returnedValue = void 0;
  String(path).split('.').forEach(function (key) {
    try {
      if (typeof returnedValue !== 'undefined') {
        returnedValue = returnedValue[key];
      } else {
        returnedValue = data[key];
      }
    } catch (err) {
      // eslint-disable-next-line no-void
      returnedValue = void 0;
    }
  });
  if (typeof returnedValue === 'undefined') {
    return defaultValue;
  }
  return returnedValue;
};
/**
 * 获取响应状态码和信息
 * @param {Object} param 过滤前响应信息和要过滤的字段
 * @param {Object} param.data 响应信息
 * @param {String|Array} param.path 要过滤的响应信息字段
 */
var getRetCodeOrMsg = exports.getRetCodeOrMsg = function getRetCodeOrMsg(_ref3) {
  var _ref3$data = _ref3.data,
      data = _ref3$data === undefined ? {} : _ref3$data,
      _ref3$path = _ref3.path,
      path = _ref3$path === undefined ? '' : _ref3$path;

  // eslint-disable-next-line no-void
  var finalReturnedValue = void 0;
  if ((0, _index.isObject)(data)) {
    if ((0, _index.isString)(path)) {
      return traversal(data, path, '');
    } else if ((0, _index.isArray)(path)) {
      path.forEach(function (pk) {
        if (traversal(data, pk, '') !== '') {
          finalReturnedValue = traversal(data, pk);
          return false;
        } else {
          finalReturnedValue = '';
        }
      });
      return finalReturnedValue;
    }
  }
  return '';
};

/**
 * 过滤cgi响应信息（响应状态码和响应信息）
 * @param {String|Object} curResponseText 服务器返回的文本数据
 * @return {Object} resp 响应状态码和响应信息
 * @return {Number|String} resp.bizcode 响应状态码
 * @return {String} resp.bizmsg 响应信息
 */
var filterCgiResp = exports.filterCgiResp = function filterCgiResp(curResponseText) {
  var cgiOptions = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : {};

  var cgiCfg = cgiOptions || {};
  var code = cgiCfg.code,
      msg = cgiCfg.msg;

  var responseData = {};
  if ((0, _index.isObject)(curResponseText)) {
    responseData = curResponseText;
  } else {
    try {
      responseData = JSON.parse(curResponseText);
    } catch (err) {
      responseData = {};
    }
  }
  var bizcode = getRetCodeOrMsg({
    data: responseData,
    path: code
  });
  var bizmsg = getRetCodeOrMsg({
    data: responseData,
    path: msg
  });
  return { bizcode: bizcode, bizmsg: bizmsg };
};

// 自动从url或者cookie中获取对应name的值

var autoRetain = exports.autoRetain = function autoRetain(name) {
  var returnedValue = '';
  if (!(0, _index.isString)(name)) {
    console.warn('name is not string');
    return returnedValue;
  }
  try {
    returnedValue = getUrlParam({
      name: name
    });
    if (returnedValue.length === 0) {
      returnedValue = getCookie(name) || '';
    }
    return returnedValue;
  } catch (err) {
    console.error('Automatically get the value of the corresponding name from the url or cookie ' + err);
    return returnedValue;
  }
};

var getKey = exports.getKey = function getKey(appKey) {
  var data = {
    private_app_key: appKey.split('-')[0],
    p_id: appKey.split('-')[1]
  };
  return data;
};

// export const initByJsBridge = data => {
//   data.os = qapmJsBridge.get();
//   return data;
// };

var DeviceInfo = exports.DeviceInfo = function DeviceInfo() {
  var isMac = navigator.platform === 'Mac68K' || navigator.platform === 'MacPPC' || navigator.platform === 'Macintosh' || navigator.platform === 'MacIntel';
  if (isMac) return 1;
  return 0;
};
var isiOS = exports.isiOS = function isiOS() {
  var u = navigator.userAgent;
  return !!u.match(/\(i[^;]+;( U;)? CPU.+Mac OS X/); // ios终端
};
var isAndroid = exports.isAndroid = function isAndroid() {
  var u = navigator.userAgent;
  return u.indexOf('Android') > -1 || u.indexOf('Adr') > -1; // android终端
};
// 获取浏览器信息
var getBrowserInfo = exports.getBrowserInfo = function getBrowserInfo() {
  var res = '';
  try {
    var ua = navigator.userAgent.toLowerCase();
    var re = /(msie|firefox|chrome|opera|mobile).*?([\w.]+)/;
    var m = ua.match(re);
    res = m[1].replace(/version/, 'safari') + ' ' + m[2];
  } catch (e) {
    console.log(e.toString());
  }
  return res; // 浏览器 版本号
};

// 目前无法区分运营商，区分需要依赖第三方接口
var getNetworkType = exports.getNetworkType = function getNetworkType() {
  var ua = navigator.userAgent;
  var networkStr = ua.match(/NetType\/\w+/) ? ua.match(/NetType\/\w+/)[0] : 'NetType/other';
  networkStr = networkStr.toLowerCase().replace('nettype/', '');
  var networkType = void 0;
  switch (networkStr) {
    case 'wifi':
      networkType = TYPE_WIFI;
      break;
    case '4g':
      networkType = T_APN_CTLTE;
      break;
    case '3g':
      networkType = T_APN_3GWAP;
      break;
    case '3gnet':
      networkType = T_APN_CTNET;
      break;
    case '2g':
      networkType = T_APN_CMWAP;
      break;
    default:
      networkType = TYPE_UNKNOWN;
  }
  return networkType;
};

var getBreadcrumbId = exports.getBreadcrumbId = function getBreadcrumbId(tag) {
  var e = new _athena2.default.EventCAL();
  e.category = tag; // 类别, 必填, 推荐全部大些, 用前缀管理一下, 但不强制
  return _athena2.default.Track.customTrack(e);
};

var COMMON_FILED = {
  uin: '',
  arch: 'web',
  version: '1.0.0',
  device: 'web',
  app_key: '',
  plugin: '',
  api_ver: '1',
  plugin_ver: '1',
  client_identify: '1',
  os: '1.0.0',
  deviceid: '',
  manu: 'web',
  rdmuuid: window.QAPM_UUID ? window.QAPM_UUID : '0',
  sdk_ver: '1.0.0'
};
var PLUGIN = exports.PLUGIN = {
  WEBVIEW: 41,
  JS_ERROR: 43
};

var resetCommonUin = exports.resetCommonUin = function resetCommonUin(uin) {
  COMMON_FILED.uin = uin;
};

var initCommonFiled = exports.initCommonFiled = function initCommonFiled(filed) {
  if (isAndroid()) {
    Object.keys(PLUGIN).forEach(function (key) {
      PLUGIN[key] += 100;
    });
  }
  Object.assign(COMMON_FILED, filed);
};
var getCommonFiled = exports.getCommonFiled = function getCommonFiled(plugin) {
  var res = {};
  Object.assign(res, COMMON_FILED, { plugin: plugin, rdmuuid: window.QAPM_UUID ? window.QAPM_UUID : '0' });
  return res;
};

/***/ }),

/***/ "./src/utils/types/index.js":
/*!**********************************!*\
  !*** ./src/utils/types/index.js ***!
  \**********************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
  value: true
});
var nativeToString = exports.nativeToString = Object.prototype.toString;
var nativeHasOwn = exports.nativeHasOwn = Object.prototype.hasOwnProperty;
var isArray = exports.isArray = function isArray(obj) {
  return nativeToString.call(obj) === '[object Array]';
};
var isObject = exports.isObject = function isObject(obj) {
  return nativeToString.call(obj) === '[object Object]';
};
var isString = exports.isString = function isString(obj) {
  return typeof obj === 'string';
};
var isUndefined = exports.isUndefined = function isUndefined(obj) {
  return typeof obj === 'undefined';
};
var isFunction = exports.isFunction = function isFunction(func) {
  return typeof func === 'function';
};
var hasProp = exports.hasProp = function hasProp(obj, key) {
  return nativeHasOwn.call(obj, key);
};

/***/ }),

/***/ "./src/utils/url/index.js":
/*!********************************!*\
  !*** ./src/utils/url/index.js ***!
  \********************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


Object.defineProperty(exports, "__esModule", {
  value: true
});
var parseLink = exports.parseLink = function parseLink(url) {
  if (!url) {
    return {};
  }
  var aTag = document.createElement('a');
  aTag.href = url;
  return {
    host: aTag.host,
    path: aTag.pathname,
    hostname: aTag.hostname,
    protocol: aTag.protocol.slice(0, -1)
  };
};

/***/ })

/******/ });
});
