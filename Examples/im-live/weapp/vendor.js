
var window = { Number: Number, Array: Array, Date: Date, Error: Error, Math: Math, Object: Object, Function: Function, RegExp: RegExp, String: String, TypeError: TypeError, parseInt: parseInt, parseFloat: parseFloat, isNaN: isNaN };
var global = window;
var process = { env: {} };
(function(modules) {
   // The module cache
   var installedModules = {};
   // The require function
   function __wepy_require(moduleId) {
       // Check if module is in cache
       if(installedModules[moduleId])
           return installedModules[moduleId].exports;
       // Create a new module (and put it into the cache)
       var module = installedModules[moduleId] = {
           exports: {},
           id: moduleId,
           loaded: false
       };
       // Execute the module function
       modules[moduleId].call(module.exports, module, module.exports, __wepy_require);
       // Flag the module as loaded
       module.loaded = true;
       // Return the exports of the module
       return module.exports;
   }
   // expose the modules object (__webpack_modules__)
   __wepy_require.m = modules;
   // expose the module cache
   __wepy_require.c = installedModules;
   // __webpack_public_path__
   __wepy_require.p = "/";
   // Load entry module and return exports
   module.exports = __wepy_require;
   return __wepy_require;
})([
/***** module 0 start *****/
/***** /Users/xingchenhe/Documents/work/git.code.oa.com/live-demo-component/node_modules/regenerator-runtime/runtime.js *****/
function(module, exports, __wepy_require) {/**
 * Copyright (c) 2014-present, Facebook, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

var runtime = (function (exports) {
  "use strict";

  var Op = Object.prototype;
  var hasOwn = Op.hasOwnProperty;
  var undefined; // More compressible than void 0.
  var $Symbol = typeof Symbol === "function" ? Symbol : {};
  var iteratorSymbol = $Symbol.iterator || "@@iterator";
  var asyncIteratorSymbol = $Symbol.asyncIterator || "@@asyncIterator";
  var toStringTagSymbol = $Symbol.toStringTag || "@@toStringTag";

  function wrap(innerFn, outerFn, self, tryLocsList) {
    // If outerFn provided and outerFn.prototype is a Generator, then outerFn.prototype instanceof Generator.
    var protoGenerator = outerFn && outerFn.prototype instanceof Generator ? outerFn : Generator;
    var generator = Object.create(protoGenerator.prototype);
    var context = new Context(tryLocsList || []);

    // The ._invoke method unifies the implementations of the .next,
    // .throw, and .return methods.
    generator._invoke = makeInvokeMethod(innerFn, self, context);

    return generator;
  }
  exports.wrap = wrap;

  // Try/catch helper to minimize deoptimizations. Returns a completion
  // record like context.tryEntries[i].completion. This interface could
  // have been (and was previously) designed to take a closure to be
  // invoked without arguments, but in all the cases we care about we
  // already have an existing method we want to call, so there's no need
  // to create a new function object. We can even get away with assuming
  // the method takes exactly one argument, since that happens to be true
  // in every case, so we don't have to touch the arguments object. The
  // only additional allocation required is the completion record, which
  // has a stable shape and so hopefully should be cheap to allocate.
  function tryCatch(fn, obj, arg) {
    try {
      return { type: "normal", arg: fn.call(obj, arg) };
    } catch (err) {
      return { type: "throw", arg: err };
    }
  }

  var GenStateSuspendedStart = "suspendedStart";
  var GenStateSuspendedYield = "suspendedYield";
  var GenStateExecuting = "executing";
  var GenStateCompleted = "completed";

  // Returning this object from the innerFn has the same effect as
  // breaking out of the dispatch switch statement.
  var ContinueSentinel = {};

  // Dummy constructor functions that we use as the .constructor and
  // .constructor.prototype properties for functions that return Generator
  // objects. For full spec compliance, you may wish to configure your
  // minifier not to mangle the names of these two functions.
  function Generator() {}
  function GeneratorFunction() {}
  function GeneratorFunctionPrototype() {}

  // This is a polyfill for %IteratorPrototype% for environments that
  // don't natively support it.
  var IteratorPrototype = {};
  IteratorPrototype[iteratorSymbol] = function () {
    return this;
  };

  var getProto = Object.getPrototypeOf;
  var NativeIteratorPrototype = getProto && getProto(getProto(values([])));
  if (NativeIteratorPrototype &&
      NativeIteratorPrototype !== Op &&
      hasOwn.call(NativeIteratorPrototype, iteratorSymbol)) {
    // This environment has a native %IteratorPrototype%; use it instead
    // of the polyfill.
    IteratorPrototype = NativeIteratorPrototype;
  }

  var Gp = GeneratorFunctionPrototype.prototype =
    Generator.prototype = Object.create(IteratorPrototype);
  GeneratorFunction.prototype = Gp.constructor = GeneratorFunctionPrototype;
  GeneratorFunctionPrototype.constructor = GeneratorFunction;
  GeneratorFunctionPrototype[toStringTagSymbol] =
    GeneratorFunction.displayName = "GeneratorFunction";

  // Helper for defining the .next, .throw, and .return methods of the
  // Iterator interface in terms of a single ._invoke method.
  function defineIteratorMethods(prototype) {
    ["next", "throw", "return"].forEach(function(method) {
      prototype[method] = function(arg) {
        return this._invoke(method, arg);
      };
    });
  }

  exports.isGeneratorFunction = function(genFun) {
    var ctor = typeof genFun === "function" && genFun.constructor;
    return ctor
      ? ctor === GeneratorFunction ||
        // For the native GeneratorFunction constructor, the best we can
        // do is to check its .name property.
        (ctor.displayName || ctor.name) === "GeneratorFunction"
      : false;
  };

  exports.mark = function(genFun) {
    if (Object.setPrototypeOf) {
      Object.setPrototypeOf(genFun, GeneratorFunctionPrototype);
    } else {
      genFun.__proto__ = GeneratorFunctionPrototype;
      if (!(toStringTagSymbol in genFun)) {
        genFun[toStringTagSymbol] = "GeneratorFunction";
      }
    }
    genFun.prototype = Object.create(Gp);
    return genFun;
  };

  // Within the body of any async function, `await x` is transformed to
  // `yield regeneratorRuntime.awrap(x)`, so that the runtime can test
  // `hasOwn.call(value, "__await")` to determine if the yielded value is
  // meant to be awaited.
  exports.awrap = function(arg) {
    return { __await: arg };
  };

  function AsyncIterator(generator, PromiseImpl) {
    function invoke(method, arg, resolve, reject) {
      var record = tryCatch(generator[method], generator, arg);
      if (record.type === "throw") {
        reject(record.arg);
      } else {
        var result = record.arg;
        var value = result.value;
        if (value &&
            typeof value === "object" &&
            hasOwn.call(value, "__await")) {
          return PromiseImpl.resolve(value.__await).then(function(value) {
            invoke("next", value, resolve, reject);
          }, function(err) {
            invoke("throw", err, resolve, reject);
          });
        }

        return PromiseImpl.resolve(value).then(function(unwrapped) {
          // When a yielded Promise is resolved, its final value becomes
          // the .value of the Promise<{value,done}> result for the
          // current iteration.
          result.value = unwrapped;
          resolve(result);
        }, function(error) {
          // If a rejected Promise was yielded, throw the rejection back
          // into the async generator function so it can be handled there.
          return invoke("throw", error, resolve, reject);
        });
      }
    }

    var previousPromise;

    function enqueue(method, arg) {
      function callInvokeWithMethodAndArg() {
        return new PromiseImpl(function(resolve, reject) {
          invoke(method, arg, resolve, reject);
        });
      }

      return previousPromise =
        // If enqueue has been called before, then we want to wait until
        // all previous Promises have been resolved before calling invoke,
        // so that results are always delivered in the correct order. If
        // enqueue has not been called before, then it is important to
        // call invoke immediately, without waiting on a callback to fire,
        // so that the async generator function has the opportunity to do
        // any necessary setup in a predictable way. This predictability
        // is why the Promise constructor synchronously invokes its
        // executor callback, and why async functions synchronously
        // execute code before the first await. Since we implement simple
        // async functions in terms of async generators, it is especially
        // important to get this right, even though it requires care.
        previousPromise ? previousPromise.then(
          callInvokeWithMethodAndArg,
          // Avoid propagating failures to Promises returned by later
          // invocations of the iterator.
          callInvokeWithMethodAndArg
        ) : callInvokeWithMethodAndArg();
    }

    // Define the unified helper method that is used to implement .next,
    // .throw, and .return (see defineIteratorMethods).
    this._invoke = enqueue;
  }

  defineIteratorMethods(AsyncIterator.prototype);
  AsyncIterator.prototype[asyncIteratorSymbol] = function () {
    return this;
  };
  exports.AsyncIterator = AsyncIterator;

  // Note that simple async functions are implemented on top of
  // AsyncIterator objects; they just return a Promise for the value of
  // the final result produced by the iterator.
  exports.async = function(innerFn, outerFn, self, tryLocsList, PromiseImpl) {
    if (PromiseImpl === void 0) PromiseImpl = Promise;

    var iter = new AsyncIterator(
      wrap(innerFn, outerFn, self, tryLocsList),
      PromiseImpl
    );

    return exports.isGeneratorFunction(outerFn)
      ? iter // If outerFn is a generator, return the full iterator.
      : iter.next().then(function(result) {
          return result.done ? result.value : iter.next();
        });
  };

  function makeInvokeMethod(innerFn, self, context) {
    var state = GenStateSuspendedStart;

    return function invoke(method, arg) {
      if (state === GenStateExecuting) {
        throw new Error("Generator is already running");
      }

      if (state === GenStateCompleted) {
        if (method === "throw") {
          throw arg;
        }

        // Be forgiving, per 25.3.3.3.3 of the spec:
        // https://people.mozilla.org/~jorendorff/es6-draft.html#sec-generatorresume
        return doneResult();
      }

      context.method = method;
      context.arg = arg;

      while (true) {
        var delegate = context.delegate;
        if (delegate) {
          var delegateResult = maybeInvokeDelegate(delegate, context);
          if (delegateResult) {
            if (delegateResult === ContinueSentinel) continue;
            return delegateResult;
          }
        }

        if (context.method === "next") {
          // Setting context._sent for legacy support of Babel's
          // function.sent implementation.
          context.sent = context._sent = context.arg;

        } else if (context.method === "throw") {
          if (state === GenStateSuspendedStart) {
            state = GenStateCompleted;
            throw context.arg;
          }

          context.dispatchException(context.arg);

        } else if (context.method === "return") {
          context.abrupt("return", context.arg);
        }

        state = GenStateExecuting;

        var record = tryCatch(innerFn, self, context);
        if (record.type === "normal") {
          // If an exception is thrown from innerFn, we leave state ===
          // GenStateExecuting and loop back for another invocation.
          state = context.done
            ? GenStateCompleted
            : GenStateSuspendedYield;

          if (record.arg === ContinueSentinel) {
            continue;
          }

          return {
            value: record.arg,
            done: context.done
          };

        } else if (record.type === "throw") {
          state = GenStateCompleted;
          // Dispatch the exception by looping back around to the
          // context.dispatchException(context.arg) call above.
          context.method = "throw";
          context.arg = record.arg;
        }
      }
    };
  }

  // Call delegate.iterator[context.method](context.arg) and handle the
  // result, either by returning a { value, done } result from the
  // delegate iterator, or by modifying context.method and context.arg,
  // setting context.delegate to null, and returning the ContinueSentinel.
  function maybeInvokeDelegate(delegate, context) {
    var method = delegate.iterator[context.method];
    if (method === undefined) {
      // A .throw or .return when the delegate iterator has no .throw
      // method always terminates the yield* loop.
      context.delegate = null;

      if (context.method === "throw") {
        // Note: ["return"] must be used for ES3 parsing compatibility.
        if (delegate.iterator["return"]) {
          // If the delegate iterator has a return method, give it a
          // chance to clean up.
          context.method = "return";
          context.arg = undefined;
          maybeInvokeDelegate(delegate, context);

          if (context.method === "throw") {
            // If maybeInvokeDelegate(context) changed context.method from
            // "return" to "throw", let that override the TypeError below.
            return ContinueSentinel;
          }
        }

        context.method = "throw";
        context.arg = new TypeError(
          "The iterator does not provide a 'throw' method");
      }

      return ContinueSentinel;
    }

    var record = tryCatch(method, delegate.iterator, context.arg);

    if (record.type === "throw") {
      context.method = "throw";
      context.arg = record.arg;
      context.delegate = null;
      return ContinueSentinel;
    }

    var info = record.arg;

    if (! info) {
      context.method = "throw";
      context.arg = new TypeError("iterator result is not an object");
      context.delegate = null;
      return ContinueSentinel;
    }

    if (info.done) {
      // Assign the result of the finished delegate to the temporary
      // variable specified by delegate.resultName (see delegateYield).
      context[delegate.resultName] = info.value;

      // Resume execution at the desired location (see delegateYield).
      context.next = delegate.nextLoc;

      // If context.method was "throw" but the delegate handled the
      // exception, let the outer generator proceed normally. If
      // context.method was "next", forget context.arg since it has been
      // "consumed" by the delegate iterator. If context.method was
      // "return", allow the original .return call to continue in the
      // outer generator.
      if (context.method !== "return") {
        context.method = "next";
        context.arg = undefined;
      }

    } else {
      // Re-yield the result returned by the delegate method.
      return info;
    }

    // The delegate iterator is finished, so forget it and continue with
    // the outer generator.
    context.delegate = null;
    return ContinueSentinel;
  }

  // Define Generator.prototype.{next,throw,return} in terms of the
  // unified ._invoke helper method.
  defineIteratorMethods(Gp);

  Gp[toStringTagSymbol] = "Generator";

  // A Generator should always return itself as the iterator object when the
  // @@iterator function is called on it. Some browsers' implementations of the
  // iterator prototype chain incorrectly implement this, causing the Generator
  // object to not be returned from this call. This ensures that doesn't happen.
  // See https://github.com/facebook/regenerator/issues/274 for more details.
  Gp[iteratorSymbol] = function() {
    return this;
  };

  Gp.toString = function() {
    return "[object Generator]";
  };

  function pushTryEntry(locs) {
    var entry = { tryLoc: locs[0] };

    if (1 in locs) {
      entry.catchLoc = locs[1];
    }

    if (2 in locs) {
      entry.finallyLoc = locs[2];
      entry.afterLoc = locs[3];
    }

    this.tryEntries.push(entry);
  }

  function resetTryEntry(entry) {
    var record = entry.completion || {};
    record.type = "normal";
    delete record.arg;
    entry.completion = record;
  }

  function Context(tryLocsList) {
    // The root entry object (effectively a try statement without a catch
    // or a finally block) gives us a place to store values thrown from
    // locations where there is no enclosing try statement.
    this.tryEntries = [{ tryLoc: "root" }];
    tryLocsList.forEach(pushTryEntry, this);
    this.reset(true);
  }

  exports.keys = function(object) {
    var keys = [];
    for (var key in object) {
      keys.push(key);
    }
    keys.reverse();

    // Rather than returning an object with a next method, we keep
    // things simple and return the next function itself.
    return function next() {
      while (keys.length) {
        var key = keys.pop();
        if (key in object) {
          next.value = key;
          next.done = false;
          return next;
        }
      }

      // To avoid creating an additional object, we just hang the .value
      // and .done properties off the next function object itself. This
      // also ensures that the minifier will not anonymize the function.
      next.done = true;
      return next;
    };
  };

  function values(iterable) {
    if (iterable) {
      var iteratorMethod = iterable[iteratorSymbol];
      if (iteratorMethod) {
        return iteratorMethod.call(iterable);
      }

      if (typeof iterable.next === "function") {
        return iterable;
      }

      if (!isNaN(iterable.length)) {
        var i = -1, next = function next() {
          while (++i < iterable.length) {
            if (hasOwn.call(iterable, i)) {
              next.value = iterable[i];
              next.done = false;
              return next;
            }
          }

          next.value = undefined;
          next.done = true;

          return next;
        };

        return next.next = next;
      }
    }

    // Return an iterator with no values.
    return { next: doneResult };
  }
  exports.values = values;

  function doneResult() {
    return { value: undefined, done: true };
  }

  Context.prototype = {
    constructor: Context,

    reset: function(skipTempReset) {
      this.prev = 0;
      this.next = 0;
      // Resetting context._sent for legacy support of Babel's
      // function.sent implementation.
      this.sent = this._sent = undefined;
      this.done = false;
      this.delegate = null;

      this.method = "next";
      this.arg = undefined;

      this.tryEntries.forEach(resetTryEntry);

      if (!skipTempReset) {
        for (var name in this) {
          // Not sure about the optimal order of these conditions:
          if (name.charAt(0) === "t" &&
              hasOwn.call(this, name) &&
              !isNaN(+name.slice(1))) {
            this[name] = undefined;
          }
        }
      }
    },

    stop: function() {
      this.done = true;

      var rootEntry = this.tryEntries[0];
      var rootRecord = rootEntry.completion;
      if (rootRecord.type === "throw") {
        throw rootRecord.arg;
      }

      return this.rval;
    },

    dispatchException: function(exception) {
      if (this.done) {
        throw exception;
      }

      var context = this;
      function handle(loc, caught) {
        record.type = "throw";
        record.arg = exception;
        context.next = loc;

        if (caught) {
          // If the dispatched exception was caught by a catch block,
          // then let that catch block handle the exception normally.
          context.method = "next";
          context.arg = undefined;
        }

        return !! caught;
      }

      for (var i = this.tryEntries.length - 1; i >= 0; --i) {
        var entry = this.tryEntries[i];
        var record = entry.completion;

        if (entry.tryLoc === "root") {
          // Exception thrown outside of any try block that could handle
          // it, so set the completion value of the entire function to
          // throw the exception.
          return handle("end");
        }

        if (entry.tryLoc <= this.prev) {
          var hasCatch = hasOwn.call(entry, "catchLoc");
          var hasFinally = hasOwn.call(entry, "finallyLoc");

          if (hasCatch && hasFinally) {
            if (this.prev < entry.catchLoc) {
              return handle(entry.catchLoc, true);
            } else if (this.prev < entry.finallyLoc) {
              return handle(entry.finallyLoc);
            }

          } else if (hasCatch) {
            if (this.prev < entry.catchLoc) {
              return handle(entry.catchLoc, true);
            }

          } else if (hasFinally) {
            if (this.prev < entry.finallyLoc) {
              return handle(entry.finallyLoc);
            }

          } else {
            throw new Error("try statement without catch or finally");
          }
        }
      }
    },

    abrupt: function(type, arg) {
      for (var i = this.tryEntries.length - 1; i >= 0; --i) {
        var entry = this.tryEntries[i];
        if (entry.tryLoc <= this.prev &&
            hasOwn.call(entry, "finallyLoc") &&
            this.prev < entry.finallyLoc) {
          var finallyEntry = entry;
          break;
        }
      }

      if (finallyEntry &&
          (type === "break" ||
           type === "continue") &&
          finallyEntry.tryLoc <= arg &&
          arg <= finallyEntry.finallyLoc) {
        // Ignore the finally entry if control is not jumping to a
        // location outside the try/catch block.
        finallyEntry = null;
      }

      var record = finallyEntry ? finallyEntry.completion : {};
      record.type = type;
      record.arg = arg;

      if (finallyEntry) {
        this.method = "next";
        this.next = finallyEntry.finallyLoc;
        return ContinueSentinel;
      }

      return this.complete(record);
    },

    complete: function(record, afterLoc) {
      if (record.type === "throw") {
        throw record.arg;
      }

      if (record.type === "break" ||
          record.type === "continue") {
        this.next = record.arg;
      } else if (record.type === "return") {
        this.rval = this.arg = record.arg;
        this.method = "return";
        this.next = "end";
      } else if (record.type === "normal" && afterLoc) {
        this.next = afterLoc;
      }

      return ContinueSentinel;
    },

    finish: function(finallyLoc) {
      for (var i = this.tryEntries.length - 1; i >= 0; --i) {
        var entry = this.tryEntries[i];
        if (entry.finallyLoc === finallyLoc) {
          this.complete(entry.completion, entry.afterLoc);
          resetTryEntry(entry);
          return ContinueSentinel;
        }
      }
    },

    "catch": function(tryLoc) {
      for (var i = this.tryEntries.length - 1; i >= 0; --i) {
        var entry = this.tryEntries[i];
        if (entry.tryLoc === tryLoc) {
          var record = entry.completion;
          if (record.type === "throw") {
            var thrown = record.arg;
            resetTryEntry(entry);
          }
          return thrown;
        }
      }

      // The context.catch method must only be called with a location
      // argument that corresponds to a known catch block.
      throw new Error("illegal catch attempt");
    },

    delegateYield: function(iterable, resultName, nextLoc) {
      this.delegate = {
        iterator: values(iterable),
        resultName: resultName,
        nextLoc: nextLoc
      };

      if (this.method === "next") {
        // Deliberately forget the last sent value so that we don't
        // accidentally pass it on to the delegate.
        this.arg = undefined;
      }

      return ContinueSentinel;
    }
  };

  // Regardless of whether this script is executing as a CommonJS module
  // or not, return the runtime object so that we can declare the variable
  // regeneratorRuntime in the outer scope, which allows this module to be
  // injected easily by `bin/regenerator --include-runtime script.js`.
  return exports;

}(
  // If this script is executing as a CommonJS module, use module.exports
  // as the regeneratorRuntime namespace. Otherwise create a new empty
  // object. Either way, the resulting object will be used to initialize
  // the regeneratorRuntime variable at the top of this file.
  typeof module === "object" ? module.exports : {}
));

try {
  regeneratorRuntime = runtime;
} catch (accidentalStrictMode) {
  // This module should not be running in strict mode, so the above
  // assignment should always work unless something is misconfigured. Just
  // in case runtime.js accidentally runs in strict mode, we can escape
  // strict mode using a global Function call. This could conceivably fail
  // if a Content Security Policy forbids using Function, but in that case
  // the proper solution is to fix the accidental strict mode problem. If
  // you've misconfigured your bundler to force strict mode and applied a
  // CSP to forbid Function, and you're not willing to fix either of those
  // problems, please detail your unique predicament in a GitHub issue.
  Function("r", "regeneratorRuntime = r")(runtime);
}

},/***** module 0 end *****/


/***** module 1 start *****/
/***** /Users/xingchenhe/Documents/work/git.code.oa.com/live-demo-component/node_modules/@wepy/redux/dist/index.js *****/
function(module, exports, __wepy_require) {'use strict';

Object.defineProperty(exports, '__esModule', { value: true });

function normalizeMap(map) {
  if (typeof map === 'string') { map = [map]; }
  return Array.isArray(map) ? map.map(function (k) { return ({ key: k, val: k }); }) : Object.keys(map).map(function (k) { return ({ key: k, val: map[k] }); });
}

var mapState = function(states) {
  var res = Object.create(null);
  var resValueMap = Object.create(null);
  normalizeMap(states).forEach(function (ref) {
    var key = ref.key;
    var val = ref.val;

    /**
     * resValueMap 记录由 mapState 产生的值
     * 在初始化时将其变成 observer 的
     */
    resValueMap[key] = Object.preventExtensions({ value: undefined });
    res[key] = function mappedState() {
      var state = this.$store.getState();
      var value = typeof val === 'function' ? val.call(this, state) : state[val];

      // 利用 redux state 每次改变都会返回一个新 state 的特性，只需做引用比较
      var resValueMap = res[key][this.$id];
      if (resValueMap[key].value !== value) {
        resValueMap[key] = Object.preventExtensions({ value: value });
      }
      return resValueMap[key].value;
    };
    res[key].redux = true;
    res[key].resValueMap = resValueMap;
  });
  return res;
};

var mapActions = function(actions) {
  var res = {};
  normalizeMap(actions).forEach(function (ref) {
    var key = ref.key;
    var val = ref.val;

    res[key] = function mappedAction() {
      var args = [], len = arguments.length;
      while ( len-- ) args[ len ] = arguments[ len ];

      if (!this.$store) {
        // eslint-disable-next-line
        console.warn(("[@wepy/redux] action \"" + key + "\" do not work, if store is not defined."));
        return;
      }
      var dispatchParam;
      if (typeof val === 'string') {
        dispatchParam = {
          type: val,
          payload: args.length > 1 ? args : args[0]
        };
      } else {
        dispatchParam = typeof val === 'function' ? val.apply(this.$store, args) : val;
      }
      return this.$store.dispatch(dispatchParam);
    };
  });
  return res;
};

function wepyInstall(wepy) {
  wepy.mixin({
    beforeCreate: function beforeCreate() {
      var this$1 = this;

      var options = this.$options;
      if (options.store) {
        this.$store = typeof options.store === 'function' ? options.store() : options.store;
      } else if (options.parent && options.parent.$store) {
        this.$store = options.parent.$store;
      }
      if (checkReduxComputed(this.$options)) {
        if (!this.$store) {
          // eslint-disable-next-line
          console.warn("[@wepy/redux] state do not work, if store is not defined.");
          return;
        }
        var ref = this.$options;
        var computed = ref.computed;
        var keys = Object.keys(computed);
        var resValueMap;
        for (var i = 0; i < keys.length; i++) {
          if ('resValueMap' in computed[keys[i]]) {
            if (!resValueMap) {
              resValueMap = Object.assign({}, computed[keys[i]].resValueMap);
            }
            computed[keys[i]][this$1.$id] = resValueMap;
          }
        }
        wepy.observe({
          vm: this,
          key: '',
          value: resValueMap,
          parent: '',
          root: true
        });
      }
    },

    created: function created() {
      var this$1 = this;

      if (!checkReduxComputed(this.$options)) {
        return;
      }
      var store = this.$store;
      var ref = this.$options;
      var computed = ref.computed;
      this.$unsubscribe = store.subscribe(function () {
        var keys = Object.keys(computed);
        for (var i = 0; i < keys.length; i++) {
          if ('redux' in computed[keys[i]]) {
            this$1._computedWatchers[keys[i]].get();
          }
        }
      });
    },

    detached: function detached() {
      this.$unsubscribe && this.$unsubscribe();
    }
  });
}

function checkReduxComputed(options) {
  if (!('computed' in options)) {
    return false;
  }
  var computed = options.computed;
  var keys = Object.keys(computed);
  for (var i = 0; i < keys.length; i++) {
    if ('redux' in computed[keys[i]]) {
      return true;
    }
  }
  return false;
}

var index = {
  install: wepyInstall,
  version: "2.0.1"
};

exports.default = index;
exports.mapState = mapState;
exports.mapActions = mapActions;

},/***** module 1 end *****/


/***** module 2 start *****/
/***** /Users/xingchenhe/Documents/work/git.code.oa.com/live-demo-component/node_modules/@wepy/core/dist/wepy.js *****/
function(module, exports, __wepy_require) {'use strict';

// can we use __proto__?
function getHasProto() {
  var hasProto = false;
  if ('__proto__' in {}) {
    var fn = function () {};
    var arr = [];
    arr.__proto__ = { push: fn };
    hasProto = fn === arr.push;
  }
  return hasProto;
}
var hasProto = getHasProto();

var _Set; // $flow-disable-line
/* istanbul ignore if */ if (typeof Set !== 'undefined' && isNative(Set)) {
  // use native Set when available.
  _Set = Set;
} else {
  // a non-standard Set polyfill that only works with primitive keys.
  _Set = /*@__PURE__*/(function () {
    function Set() {
      this.set = Object.create(null);
    }
    Set.prototype.has = function has (key) {
      return this.set[key] === true;
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

/* istanbul ignore next */
function isNative(Ctor) {
  return typeof Ctor === 'function' && /native code/.test(Ctor.toString());
}

/**
 * String type check
 */
var isStr = function (v) { return typeof v === 'string'; };
/**
 * Number type check
 */
var isNum = function (v) { return typeof v === 'number'; };
/**
 * Array type check
 */
var isArr = Array.isArray;
/**
 * undefined type check
 */
var isUndef = function (v) { return v === undefined; };
/**
 * Function type check
 */
var isFunc = function (v) { return typeof v === 'function'; };
/**
 * Quick object check - this is primarily used to tell
 * Objects from primitive values when we know the value
 * is a JSON-compliant type.
 */
function isObject(obj) {
  return obj !== null && typeof obj === 'object';
}

var isObj = isObject;
/**
 * Strict object type check. Only returns true
 * for plain JavaScript objects.
 */
var _toString = Object.prototype.toString;
function isPlainObject(obj) {
  return _toString.call(obj) === '[object Object]';
}

/**
 * Check whether the object has the property.
 */
var hasOwnProperty = Object.prototype.hasOwnProperty;
function hasOwn(obj, key) {
  return hasOwnProperty.call(obj, key);
}

/**
 * Perform no operation.
 * Stubbing args to make Flow happy without leaving useless transpiled code
 * with ...rest (https://flow.org/blog/2017/05/07/Strict-Function-Call-Arity/)
 */
// eslint-disable-next-line
function noop(a, b, c) {}

/**
 * Check if val is a valid array index.
 */
function isValidArrayIndex(val) {
  var n = parseFloat(String(val));
  return n >= 0 && Math.floor(n) === n && isFinite(val);
}

/**
 * Convert an Array-lik object to a real Array
 */
function toArray(list, start) {
  if ( start === void 0 ) start = 0;

  var i = list.length - start;
  var rst = new Array(i);
  while (i--) {
    rst[i] = list[i + start];
  }
  return rst;
}

/*
 * extend objects
 * e.g.
 * extend({}, {a: 1}) : extend {a: 1} to {}
 * extend(true, [], [1,2,3]) : deep extend [1,2,3] to an empty array
 * extend(true, {}, {a: 1}, {b: 2}) : deep extend two objects to {}
 */
function extend() {
  var arguments$1 = arguments;

  var options,
    name,
    src,
    copy,
    copyIsArray,
    clone,
    target = arguments[0] || {},
    i = 1,
    length = arguments.length,
    deep = false;

  // Handle a deep copy situation
  if (typeof target === 'boolean') {
    deep = target;

    // Skip the boolean and the target
    target = arguments[i] || {};
    i++;
  }

  // Handle case when target is a string or something (possible in deep copy)
  if (typeof target !== 'object' && !(typeof target === 'function')) {
    target = {};
  }

  // Extend jQuery itself if only one argument is passed
  if (i === length) {
    target = this;
    i--;
  }

  for (; i < length; i++) {
    // Only deal with non-null/undefined values
    if ((options = arguments$1[i])) {
      // Extend the base object
      for (name in options) {
        src = target[name];
        copy = options[name];

        // Prevent never-ending loop
        if (target === copy) {
          continue;
        }

        // Recurse if we're merging plain objects or arrays
        if (deep && copy && (isPlainObject(copy) || (copyIsArray = Array.isArray(copy)))) {
          if (copyIsArray) {
            copyIsArray = false;
            clone = src && Array.isArray(src) ? src : [];
          } else {
            clone = src && isPlainObject(src) ? src : {};
          }

          // Never move original objects, clone them
          target[name] = extend(deep, clone, copy);

          // Don't bring in undefined values => bring undefined values
        } else {
          target[name] = copy;
        }
      }
    }
  }

  // Return the modified object
  return target;
}

/*
 * clone objects, return a cloned object default to use deep clone
 * e.g.
 * clone({a: 1})
 * clone({a: b: {c : 1}}, false);
 */
function clone(sth, deep) {
  if ( deep === void 0 ) deep = true;

  if (isArr(sth)) {
    return extend(deep, [], sth);
  } else if ('' + sth === 'null') {
    return sth;
  } else if (isPlainObject(sth)) {
    return extend(deep, {}, sth);
  } else {
    return sth;
  }
}

var WEAPP_APP_LIFECYCLE = ['onLaunch', 'onShow', 'onHide', 'onError', 'onPageNotFound'];

var WEAPP_PAGE_LIFECYCLE = [
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
  'onResize'
];

var WEAPP_COMPONENT_LIFECYCLE = ['beforeCreate', 'created', 'attached', 'ready', 'moved', 'detached'];

var WEAPP_LIFECYCLE = []
  .concat(WEAPP_APP_LIFECYCLE)
  .concat(WEAPP_PAGE_LIFECYCLE)
  .concat(WEAPP_COMPONENT_LIFECYCLE);

var config = {};

var warn = noop;

var generateComponentTrace = function(vm) {
  return ("Found in component: \"" + (vm.$is) + "\"");
};

{
  var hasConsole = typeof console !== 'undefined';
  // TODO
  warn = function (msg, vm) {
    if (hasConsole && !config.silent) {
      // eslint-disable-next-line
      console.error("[WePY warn]: " + msg + (vm ? generateComponentTrace(vm) : ''));
    }
  };
}

function handleError(err, vm, info) {
  if (vm) {
    var cur = vm;
    while ((cur = cur.$parent)) {
      var hooks = cur.$options.errorCaptured;
      if (hooks) {
        for (var i = 0; i < hooks.length; i++) {
          try {
            var capture = hooks[i].call(cur, err, vm, info) === false;
            if (capture) { return; }
          } catch (e) {
            globalHandleError(e, cur, 'errorCaptured hook');
          }
        }
      }
    }
  }
  globalHandleError(err, vm, info);
}

function globalHandleError(err, vm, info) {
  if (config.errorHandler) {
    try {
      return config.errorHandler.call(null, err, vm, info);
    } catch (e) {
      logError(e, null, 'config.errorHandler');
    }
  }
  logError(err, vm, info);
}

function logError(err, vm, info) {
  {
    warn(("Error in " + info + ": \"" + (err.toString()) + "\""), vm);
  }
  /* istanbul ignore else */
  if (typeof console !== 'undefined') {
    // eslint-disable-next-line
    console.error(err);
  } else {
    throw err;
  }
}

var callbacks = [];
var pending = false;

function flushCallbacks() {
  pending = false;
  var copies = callbacks.slice(0);
  callbacks.length = 0;
  for (var i = 0; i < copies.length; i++) {
    copies[i]();
  }
}

// Here we have async deferring wrappers using both micro and macro tasks.
// In < 2.4 we used micro tasks everywhere, but there are some scenarios where
// micro tasks have too high a priority and fires in between supposedly
// sequential events (e.g. #4521, #6690) or even between bubbling of the same
// event (#6566). However, using macro tasks everywhere also has subtle problems
// when state is changed right before repaint (e.g. #6813, out-in transitions).
// Here we use micro task by default, but expose a way to force macro task when
// needed (e.g. in event handlers attached by v-on).
var microTimerFunc;
var macroTimerFunc;
var useMacroTask = false;

// Determine (macro) Task defer implementation.
// Technically setImmediate should be the ideal choice, but it's only available
// in IE. The only polyfill that consistently queues the callback after all DOM
// events triggered in the same loop is by using MessageChannel.
/* istanbul ignore if */
if (typeof setImmediate !== 'undefined' && isNative(setImmediate)) {
  macroTimerFunc = function () {
    setImmediate(flushCallbacks);
  };
} else if (
  /* eslint-disable no-undef */
  typeof MessageChannel !== 'undefined' &&
  (isNative(MessageChannel) ||
    // PhantomJS
    MessageChannel.toString() === '[object MessageChannelConstructor]')
) {
  var channel = new MessageChannel();
  var port = channel.port2;
  channel.port1.onmessage = flushCallbacks;
  macroTimerFunc = function () {
    port.postMessage(1);
  };
  /* eslint-enable no-undef */
} else {
  /* istanbul ignore next */
  macroTimerFunc = function () {
    setTimeout(flushCallbacks, 0);
  };
}

// Determine MicroTask defer implementation.
/* istanbul ignore next, $flow-disable-line */
if (typeof Promise !== 'undefined' && isNative(Promise)) {
  var p = Promise.resolve();
  microTimerFunc = function () {
    p.then(flushCallbacks);
    // in problematic UIWebViews, Promise.then doesn't completely break, but
    // it can get stuck in a weird state where callbacks are pushed into the
    // microtask queue but the queue isn't being flushed, until the browser
    // needs to do some other work, e.g. handle a timer. Therefore we can
    // "force" the microtask queue to be flushed by adding an empty timer.
    // if (isIOS) setTimeout(noop)
  };
} else {
  // fallback to macro
  microTimerFunc = macroTimerFunc;
}

function nextTick(cb, ctx) {
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
    if (useMacroTask) {
      macroTimerFunc();
    } else {
      microTimerFunc();
    }
  }
  // $flow-disable-line
  if (!cb && typeof Promise !== 'undefined') {
    return new Promise(function (resolve) {
      _resolve = resolve;
    });
  }
}

var renderCallbacks = [];

function renderFlushCallbacks() {
  var copies = renderCallbacks.slice(0);
  renderCallbacks.length = 0;
  for (var i = 0; i < copies.length; i++) {
    copies[i]();
  }
}

function renderNextTick(cb, ctx) {
  var _resolve;
  renderCallbacks.push(function () {
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

  if (!cb && typeof Promise !== 'undefined') {
    return new Promise(function (resolve) {
      _resolve = resolve;
    });
  }
}

/**
 * Parse a v-model expression into a base path and a final key segment.
 * Handles both dot-path and possible square brackets.
 *
 * Possible cases:
 *
 * - test
 * - test[key]
 * - test[test1[key]]
 * - test["a"][key]
 * - xxx.test[a[a].test1[key]]
 * - test.xxx.a["asa"][test1[key]]
 *
 */

/**
 * Remove an item from an array
 */
function remove(arr, item) {
  if (arr.length) {
    var index = arr.indexOf(item);
    if (index > -1) {
      return arr.splice(index, 1);
    }
  }
}

/**
 * Define a property.
 */
function def(obj, key, val, enumerable) {
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
function parsePath(path) {
  if (bailRE.test(path)) {
    return;
  }
  var segments = path.split('.');
  return function(obj) {
    for (var i = 0; i < segments.length; i++) {
      if (!obj) { return; }
      obj = obj[segments[i]];
    }
    return obj;
  };
}

// import type Watcher from './watcher'

var uid = 0;

/**
 * A dep is an observable that can have multiple
 * directives subscribing to it.
 */
var Dep = function Dep() {
  this.id = uid++;
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

function pushTarget(_target) {
  if (Dep.target) { targetStack.push(Dep.target); }
  Dep.target = _target;
}

function popTarget() {
  Dep.target = targetStack.pop();
}

/**
 * @desc ObserverPath 类以及相关处理函数
 * Observer 所在位置对应在整棵 data tree 的路径集合
 * @createDate 2019-07-21
 */

/**
 * 生成完整路径
 * @param key  {String|Number} 当为字符串时，说明是属性名，当为数字时，说明是索引
 * @param parentPath {String} 父路径
 * @return {string}
 */
var setPath = function (key, parentPath) {
  return isNum(key) ? (parentPath + "[" + key + "]") : (parentPath + "." + key);
};

/**
 * 得到 ObserverPath
 * @param value 被观察对象
 * @return {ObserverPath|null}
 */
var pickOp = function (value) {
  return isObject(value) && hasOwn(value, '__ob__') ? value.__ob__.op : null;
};

var ObserverPath = function ObserverPath(key, ob, parentOp) {
  this.ob = ob;
  // eslint-disable-next-line eqeqeq
  if (parentOp) {
    var ref = getPathMap(key, parentOp.pathKeys, parentOp.pathMap);
    var combinePathKeys = ref.combinePathKeys;
    var combinePathMap = ref.combinePathMap;
    this.pathKeys = combinePathKeys;
    this.pathMap = combinePathMap;
  } else {
    this.pathKeys = null;
    this.pathMap = null;
  }
};

ObserverPath.prototype.traverseOp = function traverseOp (key, pathKeys, pathMap, handler) {
  // 得到 newKey 和 pathMap 组合的路径集合
  var ref = getPathMap(key, pathKeys, pathMap);
    var combinePathMap = ref.combinePathMap;
    var combinePathKeys = ref.combinePathKeys;
  var handlePathKeys = [];
  var handlePathMap = {};
  var hasChange = false;

  // 遍历 combinePathMap
  for (var i = 0; i < combinePathKeys.length; i++) {
    var pathObj = handler(combinePathMap[combinePathKeys[i]], this);
    if (pathObj) {
      hasChange = true;
      handlePathKeys.push(pathObj.path);
      handlePathMap[pathObj.path] = pathObj;
    }
  }

  if (hasChange) {
    var value = this.ob.value;
    if (Array.isArray(value)) {
      for (var i$1 = 0; i$1 < value.length; i$1++) {
        var op = pickOp(value[i$1]);
        op && op.traverseOp(i$1, handlePathKeys, handlePathMap, handler);
      }
    } else {
      var keys = Object.keys(value);
      for (var i$2 = 0; i$2 < keys.length; i$2++) {
        var key$1 = keys[i$2];
        var op$1 = pickOp(value[key$1]);
        op$1 && op$1.traverseOp(key$1, handlePathKeys, handlePathMap, handler);
      }
    }
  }
};

ObserverPath.prototype.addPath = function addPath (pathObj) {
  this.pathKeys.push(pathObj.path);
  this.pathMap[pathObj.path] = pathObj;
};

ObserverPath.prototype.delPath = function delPath (path) {
  remove(this.pathKeys, path);
  delete this.pathMap[path];
};

/**
 * 添加新的 __ob__ 的 path
 */
function addPaths(newKey, op, parentOp) {
  op.traverseOp(newKey, parentOp.pathKeys, parentOp.pathMap, handler);

  function handler(pathObj, op) {
    if (!(pathObj.path in op.pathMap)) {
      // 新增一条 path
      op.addPath(pathObj);
      return pathObj;
    } else {
      return null;
    }
  }
}

/**
 * 删除指定的 __ob__ 的 path
 */
function cleanPaths(oldKey, op, parentOp) {
  op.traverseOp(oldKey, parentOp.pathKeys, parentOp.pathMap, handler);

  function handler(pathObj, op) {
    // 删除一条 path
    op.delPath(pathObj.path);
    return pathObj;
  }
}

/**
 * 得到 pathMap 与 key 组合后的路径集合
 */
function getPathMap(key, pathKeys, pathMap) {
  var obj;

  if (pathMap) {
    // console.log('pathMap', pathMap)
    var combinePathKeys = [];
    var combinePathMap = {};
    for (var i = 0; i < pathKeys.length; i++) {
      var path = setPath(key, pathMap[pathKeys[i]].path);
      combinePathKeys.push(path);
      combinePathMap[path] = { key: key, root: pathMap[pathKeys[i]].root, path: path };
    }
    return { combinePathKeys: combinePathKeys, combinePathMap: combinePathMap };
  } else {
    return {
      combinePathKeys: [key],
      combinePathMap: ( obj = {}, obj[key] = { key: key, root: key, path: key }, obj)
    };
  }
}

/*
 * not type checking this file because flow doesn't play well with
 * dynamically accessing methods on Array prototype
 */

var arrayProto = Array.prototype;
var arrayMethods = Object.create(arrayProto);

var methodsToPatch = ['push', 'pop', 'shift', 'unshift', 'splice', 'sort', 'reverse'];

/**
 * Intercept mutating methods and emit events
 */
methodsToPatch.forEach(function(method) {
  // cache original method
  var original = arrayProto[method];
  def(arrayMethods, method, function mutator() {
    var args = [], len$1 = arguments.length;
    while ( len$1-- ) args[ len$1 ] = arguments[ len$1 ];

    var len = this.length;
    // 清除已经失效的 paths
    if (len > 0) {
      switch (method) {
        case 'pop':
          delInvalidPaths(len - 1, this[len - 1], this);
          break;
        case 'shift':
          delInvalidPaths(0, this[0], this);
          break;
        case 'splice':
        case 'sort':
        case 'reverse':
          for (var i = 0; i < this.length; i++) {
            delInvalidPaths(i, this[i], this);
          }
      }
    }

    var result = original.apply(this, args);
    var ob = this.__ob__;
    var vm = ob.vm;

    // push parent key to dirty, wait to setData
    if (vm.$dirty) {
      if (method === 'push') {
        var lastIndex = ob.value.length - 1;
        vm.$dirty.set(ob.op, lastIndex, ob.value[lastIndex]);
      } else {
        vm.$dirty.set(ob.op, null, ob.value);
      }
    }

    // 这里和 vue 不一样，所有变异方法都需要更新 path
    ob.observeArray(ob.key, ob.value);

    // notify change
    ob.dep.notify();
    return result;
  });
});

function delInvalidPaths(key, value, parent) {
  if (isObject(value) && hasOwn(value, '__ob__')) {
    // delete invalid paths
    cleanPaths(key, value.__ob__.op, parent.__ob__.op);
  }
}

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
var Observer = function Observer(ref) {
  var vm = ref.vm;
  var key = ref.key;
  var value = ref.value;
  var parent = ref.parent;

  this.value = value;
  this.dep = new Dep();
  this.vmCount = 0;
  this.vm = vm;
  this.op = new ObserverPath(key, this, parent && parent.__ob__ && parent.__ob__.op);

  def(value, '__ob__', this);
  if (Array.isArray(value)) {
    var augment = hasProto ? protoAugment : copyAugment;
    augment(value, arrayMethods, arrayKeys);
    this.observeArray(key, value);
  } else {
    this.walk(key, value);
  }
};

/**
 * Walk through each property and convert them into
 * getter/setters. This method should only be called when
 * value type is Object.
 */
Observer.prototype.walk = function walk (key, obj) {
  var keys = Object.keys(obj);
  for (var i = 0; i < keys.length; i++) {
    defineReactive({ vm: this.vm, obj: obj, key: keys[i], value: obj[keys[i]], parent: obj });
    //defineReactive(this.vm, obj, keys[i], obj[keys[i]]);
  }
};

/**
 * Observe a list of Array items.
 */
Observer.prototype.observeArray = function observeArray (key, items) {
  for (var i = 0, l = items.length; i < l; i++) {
    observe({ vm: this.vm, key: i, value: items[i], parent: items });
  }
};

/**
 * Check if path exsit in vm
 */
Observer.prototype.hasPath = function hasPath (path) {
  var value = this.vm;
  var key = '';
  var i = 0;
  while (i < path.length) {
    if (path[i] !== '.' && path[i] !== '[' && path[i] !== ']') {
      key += path[i];
    } else if (key.length !== 0) {
      value = value[key];
      key = '';
      if (!isObject(value)) {
        return false;
      }
    }
    i++;
  }
  return true;
};

/**
 * Is this path value equal
 */
Observer.prototype.isPathEq = function isPathEq (path, value) {
  var objValue = this.vm;
  var key = '';
  var i = 0;
  while (i < path.length) {
    if (path[i] !== '.' && path[i] !== '[' && path[i] !== ']') {
      key += path[i];
    } else if (key.length !== 0) {
      objValue = objValue[key];
      key = '';
      if (!isObject(objValue)) {
        return false;
      }
    }
    i++;
  }
  if (key.length !== 0) {
    objValue = objValue[key];
  }
  return value === objValue;
};

// helpers

/**
 * Augment an target Object or Array by intercepting
 * the prototype chain using __proto__
 */
function protoAugment(target, src) {
  /* eslint-disable no-proto */
  target.__proto__ = src;
  /* eslint-enable no-proto */
}

/**
 * Augment an target Object or Array by defining
 * hidden properties.
 */
/* istanbul ignore next */
function copyAugment(target, src, keys) {
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
function observe(ref) {
  var vm = ref.vm;
  var key = ref.key;
  var value = ref.value;
  var parent = ref.parent;
  var root = ref.root;

  if (!isObject(value)) {
    return;
  }
  var ob;
  if (hasOwn(value, '__ob__') && value.__ob__ instanceof Observer) {
    ob = value.__ob__;
    var op = ob.op;
    addPaths(key, op, parent.__ob__.op);
  } else if (
    observerState.shouldConvert &&
    (Array.isArray(value) || isPlainObject(value)) &&
    Object.isExtensible(value) &&
    !value._isVue
  ) {
    ob = new Observer({ vm: vm, key: key, value: value, parent: parent });
  }
  if (root && ob) {
    ob.vmCount++;
  }
  return ob;
}

/**
 * Define a reactive property on an Object.
 */
function defineReactive(ref) {
  var vm = ref.vm;
  var obj = ref.obj;
  var key = ref.key;
  var value = ref.value;
  var parent = ref.parent;
  var customSetter = ref.customSetter;
  var shallow = ref.shallow;

  var dep = new Dep();

  var property = Object.getOwnPropertyDescriptor(obj, key);
  if (property && property.configurable === false) {
    return;
  }

  // cater for pre-defined getter/setters
  var getter = property && property.get;
  if (!getter && arguments.length === 2) {
    value = obj[key];
  }
  var setter = property && property.set;

  var childOb = !shallow && observe({ vm: vm, key: key, value: value, parent: obj });
  Object.defineProperty(obj, key, {
    enumerable: true,
    configurable: true,
    get: function reactiveGetter() {
      var val = getter ? getter.call(obj) : value;
      if (Dep.target) {
        dep.depend();
        if (childOb) {
          childOb.dep.depend();
          if (Array.isArray(val)) {
            dependArray(val);
          }
        }
      }
      return val;
    },
    set: function reactiveSetter(newVal) {
      var val = getter ? getter.call(obj) : value;
      /* eslint-disable no-self-compare */
      if (newVal === val || (newVal !== newVal && val !== val)) {
        return;
      }

      if (isObject(value) && hasOwn(value, '__ob__')) {
        /**
         * 删掉无效的 paths
         * 注意：即使 path 只有一个也要删掉，因为其子节点可能有多个 path
         */
        cleanPaths(key, value.__ob__.op, parent.__ob__.op);
      }

      /* eslint-enable no-self-compare */
      if ("development" !== 'production' && customSetter) {
        customSetter();
      }
      if (setter) {
        setter.call(obj, newVal);
      } else {
        value = newVal;
      }

      // Have to set dirty after value assigned, otherwise the dirty key is incrrect.
      if (vm) {
        // push parent key to dirty, wait to setData
        if (vm.$dirty) {
          vm.$dirty.set(obj.__ob__.op, key, newVal);
        }
      }
      childOb = !shallow && observe({ vm: vm, key: key, value: newVal, parent: parent });
      dep.notify();
    }
  });
}

/**
 * Set a property on an object. Adds the new property and
 * triggers change notification if the property doesn't
 * already exist.
 */
function set(vm, target, key, val) {
  if (Array.isArray(target) && isValidArrayIndex(key)) {
    target.length = Math.max(target.length, key);
    target.splice(key, 1, val);
    return val;
  }

  if (key in target && !(key in Object.prototype)) {
    target[key] = val;
    return val;
  }

  var ob = target.__ob__;
  if (target._isVue || (ob && ob.vmCount)) {
    "development" !== 'production' &&
      warn(
        'Avoid adding reactive properties to a Vue instance or its root $data ' +
          'at runtime - declare it upfront in the data option.'
      );
    return val;
  }

  if (!ob) {
    target[key] = val;
    return val;
  }

  if (isObject(target[key]) && hasOwn(target[key], '__ob__')) {
    // delete invalid paths
    cleanPaths(key, target[key].__ob__.op, ob.op);
  }
  defineReactive({ vm: vm, obj: ob.value, key: key, value: val, parent: ob.value });
  if (vm) {
    // push parent key to dirty, wait to setData
    if (vm.$dirty && hasOwn(target, '__ob__')) {
      vm.$dirty.set(target.__ob__.op, key, val);
    }
  }
  ob.dep.notify();
  return val;
}

/**
 * Delete a property and trigger change if necessary.
 */
function del(target, key) {
  if (Array.isArray(target) && isValidArrayIndex(key)) {
    target.splice(key, 1);
    return;
  }

  var ob = target.__ob__;
  if (target._isVue || (ob && ob.vmCount)) {
    "development" !== 'production' &&
      warn('Avoid deleting properties on a Vue instance or its root $data ' + '- just set it to null.');
    return;
  }

  if (!hasOwn(target, key)) {
    return;
  }

  // set $dirty
  target[key] = null;
  delete target[key];
  if (!ob) {
    return;
  }
  ob.dep.notify();
}

/**
 * Collect dependencies on array elements when the array is touched, since
 * we cannot intercept array element access like property getters.
 */
function dependArray(value) {
  for (var e = (void 0), i = 0, l = value.length; i < l; i++) {
    e = value[i];
    e && e.__ob__ && e.__ob__.dep.depend();
    if (Array.isArray(e)) {
      dependArray(e);
    }
  }
}

var Base = function Base() {
  this._events = {};
  this._watchers = [];
};

Base.prototype.$set = function $set (target, key, val) {
  return set(this, target, key, val);
};

Base.prototype.$delete = function $delete (target, key) {
  return del(target, key);
};

Base.prototype.$on = function $on (event, fn) {
    var this$1 = this;

  if (isArr(event)) {
    event.forEach(function (item) {
      if (isStr(item)) {
        this$1.$on(item, fn);
      } else if (isObj(item)) {
        this$1.$on(item.event, item.fn);
      }
    });
  } else {
    (this._events[event] || (this._events[event] = [])).push(fn);
  }
  return this;
};

Base.prototype.$once = function $once () {};

Base.prototype.$off = function $off (event, fn) {
    var this$1 = this;

  if (!event && !fn) {
    this._events = Object.create(null);
    return this;
  }

  if (isArr(event)) {
    event.forEach(function (item) {
      if (isStr(item)) {
        this$1.$off(item, fn);
      } else if (isObj(item)) {
        this$1.$off(item.event, item.fn);
      }
    });
    return this;
  }
  if (!this._events[event]) { return this; }

  if (!fn) {
    this._events[event] = null;
    return this;
  }

  if (fn) {
    var fns = this._events[event];
    var i = fns.length;
    while (i--) {
      var tmp = fns[i];
      if (tmp === fn || tmp.fn === fn) {
        fns.splice(i, 1);
        break;
      }
    }
  }
  return this;
};

Base.prototype.$emit = function $emit (event) {
    var this$1 = this;

  var vm = this;
  var lowerCaseEvent = event.toLowerCase();
  var fns = this._events[event] || [];
  if (lowerCaseEvent !== event && vm._events[lowerCaseEvent]) {
    // TODO: handler warn
  }
  var args = toArray(arguments, 1);
  fns.forEach(function (fn) {
    try {
      fn.apply(this$1, args);
    } catch (e) {
      handleError(e, vm, ("event handler for \"" + event + "\""));
    }
  });
  return this;
};

var seenObjects = new _Set();

/**
 * Recursively traverse an object to evoke all converted
 * getters, so that every nested property inside the object
 * is collected as a "deep" dependency.
 */
function traverse(val) {
  _traverse(val, seenObjects);
  seenObjects.clear();
}

function _traverse(val, seen) {
  var i, keys;
  var isA = Array.isArray(val);
  if ((!isA && !isObject(val)) || Object.isFrozen(val)) {
    return;
  }
  if (val.__ob__) {
    var depId = val.__ob__.dep.id;
    if (seen.has(depId)) {
      return;
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

//import { callHook, activateChildComponent } from '../instance/lifecycle';

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
function resetSchedulerState() {
  index = queue.length = activatedChildren.length = 0;
  has = {};
  {
    circular = {};
  }
  waiting = flushing = false;
}

/**
 * Flush both queues and run the watchers.
 */
function flushSchedulerQueue(times) {
  if ( times === void 0 ) times = 0;

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
  times === 0 && queue.sort(function (a, b) { return a.id - b.id; });

  // do not cache length because more watchers might be pushed
  // as we run existing watchers
  // there would be mutilple renderWatcher in the queue.
  var renderWatcher = [];
  if (times === 0) {
    index = 0;
  }
  for (; index < queue.length; index++) {
    // if it's renderWatcher, run it in the end
    watcher = queue[index];
    if (watcher && watcher.isRenderWatcher) {
      renderWatcher.push(watcher);
      continue;
    }
    id = watcher.id;
    has[id] = null;
    watcher.run();
    // in dev build, check and stop circular updates.
    // eslint-disable-next-line
    if ("development" !== 'production' && has[id] != null) {
      circular[id] = (circular[id] || 0) + 1;
      if (circular[id] > MAX_UPDATE_COUNT) {
        warn(
          'You may have an infinite update loop ' +
            (watcher.user ? ("in watcher with expression \"" + (watcher.expression) + "\"") : "in a component render function."),
          watcher.vm
        );
        resetSchedulerState();
        return;
      }
    }
  }
  // Run renderWatcher in the end.
  if (renderWatcher.length) {
    renderWatcher.forEach(function (watcher) {
      has[watcher.id] = null;
      watcher.run();
    });
  }

  // It may added new watcher to the queue in render watcher
  var pendingQueue = queue.slice(index);

  if (pendingQueue.length) {
    flushSchedulerQueue(times + 1);
  } else {
    // keep copies of post queues before resetting state
    // const activatedQueue = activatedChildren.slice()
    // const updatedQueue = queue.slice()

    resetSchedulerState();

    // call component updated and activated hooks
    // callActivatedHooks(activatedQueue)
    // callUpdatedHooks(updatedQueue)

    // devtool hook
    /* istanbul ignore if */
    /*
    if (devtools && config.devtools) {
      devtools.emit('flush')
    }*/
  }
}

/*
function callActivatedHooks(queue) {
  for (let i = 0; i < queue.length; i++) {
    queue[i]._inactive = true;
    activateChildComponent(queue[i], true);
  }
}
*/

/**
 * Push a watcher into the watcher queue.
 * Jobs with duplicate IDs will be skipped unless it's
 * pushed when the queue is being flushed.
 */
function queueWatcher(watcher) {
  var id = watcher.id;
  // eslint-disable-next-line
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

//import { SimpleSet } from '../util/index';

var uid$1 = 0;

/**
 * A watcher parses an expression, collects dependencies,
 * and fires callback when the expression value changes.
 * This is used for both the $watch() api and directives.
 */
var Watcher = function Watcher(vm, expOrFn, cb, options, isRenderWatcher) {
  this.vm = vm;
  if (isRenderWatcher) {
    vm._watcher = this;
  }
  vm._watchers.push(this);
  // options
  if (options) {
    this.deep = !!options.deep;
    this.user = !!options.user;
    this.computed = !!options.computed;
    this.sync = !!options.sync;
  } else {
    this.deep = this.user = this.computed = this.sync = false;
  }
  this.cb = cb;
  this.id = ++uid$1; // uid for batching
  this.active = true;
  this.dirty = this.computed; // for computed watchers
  this.deps = [];
  this.newDeps = [];
  this.depIds = new _Set();
  this.newDepIds = new _Set();
  this.isRenderWatcher = isRenderWatcher;
  this.expression = expOrFn.toString();
  // parse expression for getter
  if (typeof expOrFn === 'function') {
    this.getter = expOrFn;
  } else {
    this.getter = parsePath(expOrFn);
    if (!this.getter) {
      this.getter = function() {};
      "development" !== 'production' &&
        warn(
          "Failed watching path: \"" + expOrFn + "\" " +
            'Watcher only accepts simple dot-delimited paths. ' +
            'For full control, use a function instead.',
          vm
        );
    }
  }
  this.value = this.computed ? undefined : this.get();
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
      throw e;
    }
  } finally {
    // "touch" every property so they are all tracked as
    // dependencies for deep watching
    if (this.deep) {
      traverse(value);
    }
    popTarget();
    if (!this.isRenderWatcher) { this.cleanupDeps(); }
  }
  return value;
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
  var i = this.deps.length;
  while (i--) {
    var dep = this.deps[i];
    if (!this.newDepIds.has(dep.id)) {
      dep.removeSub(this);
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
  if (this.computed) {
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
 * This only gets called for computed watchers.
 */
Watcher.prototype.evaluate = function evaluate () {
  this.value = this.get();
  if (this.vm.$dirty) {
    var keyVal =
      this._computedWatchers && this._computedWatchers[this.key]
        ? this.vm._computedWatchers[this.key].value
        : this.value;
    this.vm.$dirty.push(this.key, this.key, keyVal, this.value);
  }
  this.dirty = false;
  return this.value;
};

/**
 * Depend on all deps collected by this watcher.
 */
Watcher.prototype.depend = function depend () {
  if (Dep.target) {
    var i = this.deps.length;
    while (i--) {
      this.deps[i].depend();
    }
  }
};

/**
 * Remove self from all dependencies' subscriber list.
 */
Watcher.prototype.teardown = function teardown () {
  if (this.active) {
    // remove self from vm's watcher list
    // this is a somewhat expensive operation so we skip it
    // if the vm is being destroyed.
    if (!this.vm._isBeingDestroyed) {
      remove(this.vm._watchers, this);
    }
    var i = this.deps.length;
    while (i--) {
      this.deps[i].removeSub(this);
    }
    this.active = false;
  }
};

var WepyComponent = /*@__PURE__*/(function (Base$$1) {
  function WepyComponent () {
    Base$$1.apply(this, arguments);
  }

  if ( Base$$1 ) WepyComponent.__proto__ = Base$$1;
  WepyComponent.prototype = Object.create( Base$$1 && Base$$1.prototype );
  WepyComponent.prototype.constructor = WepyComponent;

  WepyComponent.prototype.$watch = function $watch (expOrFn, cb, options) {
    var this$1 = this;

    var vm = this;
    if (isArr(cb)) {
      cb.forEach(function (handler) {
        this$1.$watch(expOrFn, handler, options);
      });
    }
    if (isPlainObject(cb)) {
      var handler = cb;
      options = handler;
      handler = handler.handler;
      if (typeof handler === 'string') { handler = this[handler]; }
      return this.$watch(expOrFn, handler, options);
    }

    options = options || {};
    options.user = true;
    var watcher = new Watcher(vm, expOrFn, cb, options);
    if (options.immediate) {
      cb.call(vm, watcher.value);
    }
    return function unwatchFn() {
      watcher.teardown();
    };
  };

  WepyComponent.prototype.$forceUpdate = function $forceUpdate () {
    if (this._watcher) {
      this._watcher.update();
    }
  };

  return WepyComponent;
}(Base));

WepyComponent.prototype.$nextTick = renderNextTick;

var sharedPropertyDefinition = {
  enumerable: true,
  configurable: true,
  get: noop,
  set: noop
};

function proxy(target, sourceKey, key) {
  sharedPropertyDefinition.get = function proxyGetter() {
    return this[sourceKey][key];
  };
  sharedPropertyDefinition.set = function proxySetter(val) {
    this[sourceKey][key] = val;
  };
  Object.defineProperty(target, key, sharedPropertyDefinition);
}

/*
 * patch data option
 */
function patchData(output, data) {
  if (!data) {
    data = {};
  }
  output.data = data;
}

/*
 * init data
 */
function initData(vm, data) {
  if (!data) {
    data = {};
  }
  var _data;
  if (typeof data === 'function') {
    _data = data.call(vm);
  } else {
    _data = clone(data);
  }
  vm._data = _data;
  Object.keys(_data).forEach(function (key) {
    proxy(vm, '_data', key);
  });

  observe({
    vm: vm,
    key: '',
    value: _data,
    parent: '',
    root: true
  });
  //observe(vm, _data, null, true);
}

function initWatch(vm, watch) {
  if (watch) {
    Object.keys(watch).forEach(function (key) {
      vm.$watch(key, watch[key]);
    });
  }
}

function createComputedGetter(key) {
  return function computedGetter() {
    var watcher = this._computedWatchers && this._computedWatchers[key];
    if (watcher) {
      watcher.key = key;
      if (watcher.dirty) {
        watcher.evaluate();
      }
      if (Dep.target) {
        watcher.depend();
      }
      return watcher.value;
    }
  };
}

/*
 * init computed
 */
function initComputed(vm, computed) {
  if (!computed) {
    return;
  }
  var watchers = (vm._computedWatchers = Object.create(null));
  var computedWatcherOptions = { computed: true };

  Object.keys(computed).forEach(function (key) {
    var def = computed[key];
    var getter = typeof def === 'object' ? def.get : def;

    if (!getter || typeof getter !== 'function') {
      // eslint-disable-next-line
      console.error(("Getter is missing for computed property \"" + key + "\""));
    }

    // push to dirty after dep called.
    watchers[key] = new Watcher(
      vm,
      getter || function() {},
      function() {
        // evaluate will set dirty
        // vm.$dirty.push(key, key, newv);
      },
      computedWatcherOptions
    );

    if (typeof def === 'function') {
      sharedPropertyDefinition.get = createComputedGetter(key);
      sharedPropertyDefinition.set = function() {};
    } else {
      sharedPropertyDefinition.get = def.cache !== false ? createComputedGetter(key) : def.get;
      sharedPropertyDefinition.set = def.set;
    }

    Object.defineProperty(vm, key, sharedPropertyDefinition);
  });
}

var WepyConstructor = /*@__PURE__*/(function (WepyComponent$$1) {
  function WepyConstructor(opt) {
    if ( opt === void 0 ) opt = {};

    var vm = new WepyComponent$$1();

    // Only need data and watchers for a empty WepyComponent
    if (opt.data) {
      initData(vm, opt.data);
    }
    initWatch(vm);

    initComputed(vm, opt.computed);
    return vm;
  }

  if ( WepyComponent$$1 ) WepyConstructor.__proto__ = WepyComponent$$1;
  WepyConstructor.prototype = Object.create( WepyComponent$$1 && WepyComponent$$1.prototype );
  WepyConstructor.prototype.constructor = WepyConstructor;

  return WepyConstructor;
}(WepyComponent));

var $global = Object.create(null);

function use(plugin) {
  var args = [], len = arguments.length - 1;
  while ( len-- > 0 ) args[ len ] = arguments[ len + 1 ];

  if (plugin.installed) {
    return this;
  }

  var install = plugin.install || plugin;

  if (isFunc(install)) {
    install.apply(plugin, [this].concat(args));
  }

  plugin.installed = 1;
}

function mixin(options) {
  if ( options === void 0 ) options = {};

  $global.mixin = ($global.mixin || []).concat(options);
}

var WepyApp = /*@__PURE__*/(function (Base$$1) {
  function WepyApp() {
    Base$$1.call(this);
  }

  if ( Base$$1 ) WepyApp.__proto__ = Base$$1;
  WepyApp.prototype = Object.create( Base$$1 && Base$$1.prototype );
  WepyApp.prototype.constructor = WepyApp;

  return WepyApp;
}(Base));

var WepyPage = /*@__PURE__*/(function (WepyComponent$$1) {
  function WepyPage () {
    WepyComponent$$1.apply(this, arguments);
  }

  if ( WepyComponent$$1 ) WepyPage.__proto__ = WepyComponent$$1;
  WepyPage.prototype = Object.create( WepyComponent$$1 && WepyComponent$$1.prototype );
  WepyPage.prototype.constructor = WepyPage;

  WepyPage.prototype.$launch = function $launch (url, params) {
    this.$route('reLaunch', url, params);
  };
  WepyPage.prototype.$navigate = function $navigate (url, params) {
    this.$route('navigate', url, params);
  };

  WepyPage.prototype.$redirect = function $redirect (url, params) {
    this.$route('redirect', url, params);
  };

  WepyPage.prototype.$back = function $back (p) {
    if ( p === void 0 ) p = {};

    if (isNum(p)) { p = { delta: p }; }

    if (!p.delta) { p.delta = 1; }

    return wx.navigateBack(p);
  };

  WepyPage.prototype.$route = function $route (type, url, params) {
    if ( params === void 0 ) params = {};

    var wxparams;
    if (isStr(url)) {
      var paramsList = [];
      if (isObj(params)) {
        for (var k in params) {
          if (!isUndef(params[k])) {
            paramsList.push((k + "=" + (encodeURIComponent(params[k]))));
          }
        }
      }
      if (paramsList.length) { url = url + '?' + paramsList.join('&'); }

      wxparams = { url: url };
    } else {
      wxparams = url;
    }
    var fn = wx[type] || wx[type + 'To'];
    if (isFunc(fn)) {
      return fn(wxparams);
    }
  };

  return WepyPage;
}(WepyComponent));

function callUserHook(vm, hookName, arg) {
  var pageHook = vm.hooks ? vm.hooks[hookName] : null;
  var appHook = vm.$app && vm.$app.hooks ? vm.$app.hooks[hookName] : null;

  if (!vm.$app) {
    warn('$app is not initialized in this Component', vm);
  }

  var result = arg;

  // First run page hook, and then run app hook
  // Pass page hook result to app hook
  // If return undefined, then return default argument
  [pageHook, appHook].forEach(function (fn) {
    if (isFunc(fn)) {
      result = fn.call(vm, result);
      if (isUndef(result)) {
        result = arg;
      }
    }
  });

  return result;
}

function initHooks(vm, hooks) {
  if ( hooks === void 0 ) hooks = {};

  vm.hooks = hooks;
}

var AllowedTypes = [String, Number, Boolean, Object, Array, null];

var observerFn = function() {
  return function(newVal, oldVal, changedPaths) {
    var vm = this.$wepy;

    // changedPaths 长度大于 1，说明是由内部赋值改变的 prop
    if (changedPaths.length > 1) {
      return;
    }
    var _data = newVal;
    if (typeof _data === 'function') {
      _data = _data.call(vm);
    }
    vm[changedPaths[0]] = _data;
  };
};
/*
 * patch props option
 */
function patchProps(output, props) {
  var newProps = {};
  if (isStr(props)) {
    newProps = [props];
  }
  if (isArr(props)) {
    props.forEach(function (prop) {
      newProps[prop] = {
        type: null,
        observer: observerFn(output, props, prop)
      };
    });
  } else if (isObj(props)) {
    for (var k in props) {
      var prop = props[k];
      var newProp = {};

      // props.type
      if (isUndef(prop.type)) {
        newProp.type = null;
      } else if (isArr(prop.type)) {
        newProp.type = null;
        // eslint-disable-next-line
        console.warn(("In mini-app, mutiple type is not allowed. The type of \"" + k + "\" will changed to \"null\""));
      } else if (AllowedTypes.indexOf(prop.type) === -1) {
        newProp.type = null;
        // eslint-disable-next-line
        console.warn(
          ("Type property of props \"" + k + "\" is invalid. Only String/Number/Boolean/Object/Array/null is allowed in weapp Component")
        );
      } else {
        newProp.type = prop.type;
      }

      // props.default
      if (!isUndef(prop.default)) {
        if (isFunc(prop.default)) {
          newProp.value = prop.default.call(output);
        } else {
          newProp.value = prop.default;
        }
      }
      // TODO
      // props.validator
      // props.required

      newProp.observer = observerFn(output, props, prop);

      newProps[k] = newProp;
    }
  }

  // eslint-disable-next-line
  Object.keys(newProps).forEach(function (prop) {});

  output.properties = newProps;
}

/*
 * init props
 */
function initProps(vm, properties) {
  vm._props = {};

  if (!properties) {
    return;
  }

  Object.keys(properties).forEach(function (key) {
    vm._props[key] = properties[key].value;
    proxy(vm, '_props', key);
  });

  observe({
    vm: vm,
    key: '',
    value: vm._props,
    root: true
  });
}

function initRender(vm, keys, computedKeys) {
  vm._init = false;
  var dirtyFromAttach = null;
  return new Watcher(
    vm,
    function() {
      if (!vm._init) {
        keys.forEach(function (key) { return clone(vm[key]); });
      }

      if (vm.$dirty.length() || dirtyFromAttach) {
        var keys$1 = vm.$dirty.get('key');
        computedKeys.forEach(function (key) { return vm[key]; });
        var dirty = vm.$dirty.pop();

        // TODO: reset subs
        Object.keys(keys$1).forEach(function (key) { return clone(vm[key]); });

        if (vm._init) {
          dirty = callUserHook(vm, 'before-setData', dirty);
        }

        // vm._fromSelf = true;
        if (dirty || dirtyFromAttach) {
          // init render is in lifecycle, setData in lifecycle will not work, so cacheData is needed.
          if (!vm._init) {
            if (dirtyFromAttach === null) {
              dirtyFromAttach = {};
            }
            Object.assign(dirtyFromAttach, dirty);
          } else if (dirtyFromAttach) {
            // setData in attached
            vm.$wx.setData(Object.assign(dirtyFromAttach, dirty || {}), renderFlushCallbacks);
            dirtyFromAttach = null;
          } else {
            vm.$wx.setData(dirty, renderFlushCallbacks);
          }
        }
      }
      vm._init = true;
    },
    function() {},
    null,
    true
  );
}

var Event = function Event(e) {
  var detail = e.detail;
  var target = e.target;
  var currentTarget = e.currentTarget;
  this.$wx = e;
  this.type = e.type;
  this.timeStamp = e.timeStamp;
  if (detail) {
    this.x = detail.x;
    this.y = detail.y;
  }

  this.target = target;
  this.currentTarget = currentTarget;
  this.touches = e.touches;
  this.changedTouches = e.changedTouches;
};

var proxyHandler = function(e) {
  var vm = this.$wepy;
  var type = e.type;
  // touchstart do not have currentTarget
  var dataset = (e.currentTarget || e.target).dataset;
  var evtid = dataset.wpyEvt;
  var modelId = dataset.modelId;
  var rel = vm.$rel || {};
  var handlers = rel.handlers ? rel.handlers[evtid] || {} : {};
  var fn = handlers[type];
  var model = rel.models[modelId];

  if (!fn && !model) {
    return;
  }

  var $event = new Event(e);

  var i = 0;
  var params = [];
  var modelParams = [];

  var noParams = false;
  var noModelParams = !model;
  while (i++ < 26 && (!noParams || !noModelParams)) {
    var alpha = String.fromCharCode(64 + i);
    if (!noParams) {
      var key = 'wpy' + type + alpha;
      if (!(key in dataset)) {
        // it can be undefined;
        noParams = true;
      } else {
        params.push(dataset[key]);
      }
    }
    if (!noModelParams && model) {
      var modelKey = 'model' + alpha;
      if (!(modelKey in dataset)) {
        noModelParams = true;
      } else {
        modelParams.push(dataset[modelKey]);
      }
    }
  }

  if (model) {
    if (type === model.type) {
      if (isFunc(model.handler)) {
        model.handler.call(vm, e.detail.value, modelParams);
      }
    }
  }
  if (isFunc(fn)) {
    var paramsWithEvent = params.concat($event);
    var hookRes = callUserHook(vm, 'before-event', {
      event: $event,
      params: paramsWithEvent
    });

    if (hookRes === false) {
      // Event cancelled.
      return;
    }
    return fn.apply(vm, params.concat($event));
  } else if (!model) {
    throw new Error('Unrecognized event');
  }
};

/*
 * initialize page methods, also the app
 */
function initMethods(vm, methods) {
  if (methods) {
    Object.keys(methods).forEach(function (method) {
      vm[method] = methods[method];
    });
  }
}

/*
 * patch method option
 */
function patchMethods(output, methods) {
  output.methods = {};
  var target = output.methods;

  target._initComponent = function(e) {
    var child = e.detail;
    var ref$1 = e.target.dataset;
    var ref = ref$1.ref;
    var wpyEvt = ref$1.wpyEvt;
    var vm = this.$wepy;
    vm.$children.push(child);
    if (ref) {
      if (vm.$refs[ref]) {
        warn('duplicate ref "' + ref + '" will be covered by the last instance.\n', vm);
      }
      vm.$refs[ref] = child;
    }
    child.$evtId = wpyEvt;
    child.$parent = vm;
    child.$app = vm.$app;
    child.$root = vm.$root;
    return vm;
  };
  target._proxy = proxyHandler;

  // TODO: perf
  // Only orginal component method goes to target. no need to add all methods.
  if (methods) {
    Object.keys(methods).forEach(function (method) {
      target[method] = methods[method];
    });
  }
}

/*
 * initialize events
 */
function initEvents(vm) {
  var parent = vm.$parent;
  var rel = parent.$rel;
  vm._events = {};
  var on = rel.info.on;
  var evtId = vm.$evtId;
  if (!evtId) { return; }

  var evtNames = on[evtId];

  evtNames.forEach(function (evtName) {
    vm.$on(evtName, function() {
      var fn = rel.handlers[evtId][evtName];
      fn.apply(parent, arguments);
    });
  });
}

var Dirty = function Dirty(type) {
  this.reset();

  // path||key
  this.type = type || 'path';
};

Dirty.prototype.push = function push (key, path, keyValue, pathValue) {
  if (pathValue === undefined) {
    return;
  }
  this._keys[key] = keyValue;
  this._path[path] = pathValue;
  this._length++;
};

Dirty.prototype.pop = function pop () {
  var data = Object.create(null);
  if (this.type === 'path') {
    data = this._path;
  } else if (this.type === 'key') {
    data = this._keys;
  }
  this.reset();
  return data;
};

Dirty.prototype.get = function get (type) {
  return type === 'path' ? this._path : this._keys;
};

/**
 * Set dirty from a ObserverPath
 */
Dirty.prototype.set = function set (op, key, value) {
  var pathMap;
  var pathKeys;
  // eslint-disable-next-line eqeqeq
  if (key != null) {
    var ref = getPathMap(key, op.pathKeys, op.pathMap);
      var combinePathKeys = ref.combinePathKeys;
      var combinePathMap = ref.combinePathMap;
    pathKeys = combinePathKeys;
    pathMap = combinePathMap;
  } else {
    pathKeys = op.pathKeys;
    pathMap = op.pathMap;
  }
  /**
   * 出于性能考虑，使用 usingComponents 时， setData 内容不会被直接深复制，
   * 即 this.setData({ field: obj }) 后 this.data.field === obj 。
   * 因此不需要所有 path 都 setData 。
   */
  var ref$1 = pathMap[pathKeys[0]];
    var root = ref$1.root;
    var path = ref$1.path;
  this.push(root, path, root === path ? value : op.ob.vm[root], value);
};

Dirty.prototype.reset = function reset () {
  this._keys = {};
  this._path = {};
  this._length = 0;
  return this;
};

Dirty.prototype.length = function length () {
  return this._length;
};

var comid = 0;
var app;

var callUserMethod = function(vm, userOpt, method, args) {
  var result;
  var methods = userOpt[method];
  if (isFunc(methods)) {
    result = userOpt[method].apply(vm, args);
  } else if (isArr(methods)) {
    for (var i in methods) {
      if (isFunc(methods[i])) {
        result = methods[i].apply(vm, args);
      }
    }
  }
  return result;
};

var getLifecycycle = function (defaultLifecycle, rel, type) {
  var lifecycle = defaultLifecycle.concat([]);
  if (rel && rel.lifecycle && rel.lifecycle[type]) {
    var userDefinedLifecycle = [];
    if (isFunc(rel.lifecycle[type])) {
      userDefinedLifecycle = rel.lifecycle[type].call(null, lifecycle);
    }
    userDefinedLifecycle.forEach(function (u) {
      if (lifecycle.indexOf(u) > -1) {
        warn(("'" + u + "' is already implemented in current version, please remove it from your lifecycel config"));
      } else {
        lifecycle.push(u);
      }
    });
  }
  return lifecycle;
};

/*
 * patch app lifecyle
 */
function patchAppLifecycle(appConfig, options, rel) {
  if ( rel === void 0 ) rel = {};

  appConfig.onLaunch = function() {
    var args = [], len = arguments.length;
    while ( len-- ) args[ len ] = arguments[ len ];

    var vm = new WepyApp();
    app = vm;
    vm.$options = options;
    vm.$route = {};
    vm.$rel = rel;

    vm.$wx = this;
    this.$wepy = vm;

    initHooks(vm, options.hooks);

    initMethods(vm, options.methods);

    return callUserMethod(vm, vm.$options, 'onLaunch', args);
  };

  var lifecycle = getLifecycycle(WEAPP_APP_LIFECYCLE, rel, 'app');

  lifecycle.forEach(function (k) {
    // it's not defined aready && user defined it && it's an array or function
    if (!appConfig[k] && options[k] && (isFunc(options[k]) || isArr(options[k]))) {
      appConfig[k] = function() {
        var args = [], len = arguments.length;
        while ( len-- ) args[ len ] = arguments[ len ];

        return callUserMethod(app, app.$options, k, args);
      };
    }
  });
}

function patchLifecycle(output, options, rel, isComponent) {
  var initClass = isComponent ? WepyComponent : WepyPage;
  var initLifecycle = function() {
    var args = [], len = arguments.length;
    while ( len-- ) args[ len ] = arguments[ len ];

    var vm = new initClass();

    vm.$dirty = new Dirty('path');
    vm.$children = [];
    vm.$refs = {};

    this.$wepy = vm;
    vm.$wx = this;
    vm.$is = this.is;
    vm.$options = options;
    vm.$rel = rel;
    vm._watchers = [];
    if (!isComponent) {
      vm.$root = vm;
      vm.$app = app;
    }
    if (this.is === 'custom-tab-bar/index') {
      vm.$app = app;
      vm.$parent = app;
    }

    vm.$id = ++comid + (isComponent ? '.1' : '.0');

    callUserMethod(vm, vm.$options, 'beforeCreate', args);

    initHooks(vm, options.hooks);

    initProps(vm, output.properties);

    initData(vm, output.data, isComponent);

    initMethods(vm, options.methods);

    initComputed(vm, options.computed, true);

    initWatch(vm, options.watch);

    // create render watcher
    initRender(
      vm,
      Object.keys(vm._data)
        .concat(Object.keys(vm._props))
        .concat(Object.keys(vm._computedWatchers || {})),
      Object.keys(vm._computedWatchers || {})
    );

    return callUserMethod(vm, vm.$options, 'created', args);
  };

  output.created = initLifecycle;
  if (isComponent) {
    output.attached = function() {
      var args = [], len = arguments.length;
      while ( len-- ) args[ len ] = arguments[ len ];

      // Component attached
      var outProps = output.properties || {};
      // this.propperties are includes datas
      var acceptProps = this.properties;
      var vm = this.$wepy;

      this.triggerEvent('_init', vm);

      // created 不能调用 setData，如果有 dirty 在此更新
      vm.$forceUpdate();

      initEvents(vm);

      Object.keys(outProps).forEach(function (k) { return (vm[k] = acceptProps[k]); });

      return callUserMethod(vm, vm.$options, 'attached', args);
    };
  } else {
    output.attached = function() {
      var args = [], len = arguments.length;
      while ( len-- ) args[ len ] = arguments[ len ];

      // Page attached
      var vm = this.$wepy;
      var app = vm.$app;
      // eslint-disable-next-line
      var pages = getCurrentPages();
      var currentPage = pages[pages.length - 1];
      var path = currentPage.__route__;
      var webViewId = currentPage.__wxWebviewId__;

      var refs = rel.refs || [];
      var query = wx.createSelectorQuery();

      refs.forEach(function (item) {
        // {
        //   id: { name: 'hello', bind: true },
        //   ref: { name: 'value', bind: false }
        // }
        var idAttr = item.id;
        var refAttr = item.ref;
        var actualAttrIdName = idAttr.name;
        var actualAttrRefName = refAttr.name;
        var selector = "#" + actualAttrIdName;

        if (idAttr.bind) {
          // if id is a bind attr
          actualAttrIdName = vm[idAttr.name];
          selector = "#" + actualAttrIdName;
          vm.$watch(idAttr.name, function(newAttrName) {
            actualAttrIdName = newAttrName;
            selector = "#" + actualAttrIdName;
            vm.$refs[actualAttrRefName] = query.select(selector);
          });
        }

        if (refAttr.bind) {
          // if ref is a bind attr
          actualAttrRefName = vm[refAttr.name];

          vm.$watch(refAttr.name, function(newAttrName, oldAttrName) {
            actualAttrRefName = newAttrName;
            vm.$refs[oldAttrName] = null;
            vm.$refs[newAttrName] = query.select(selector);
          });
        }
        vm.$refs[actualAttrRefName] = query.select(selector);
      });

      // created 不能调用 setData，如果有 dirty 在此更新
      vm.$forceUpdate();

      if (app.$route.path !== path) {
        app.$route.path = path;
        app.$route.webViewId = webViewId;
        vm.routed && vm.routed();
      }

      // TODO: page attached
      return callUserMethod(vm, vm.$options, 'attached', args);
    };
    // Page lifecycle will be called under methods
    // e.g:
    // Component({
    //   methods: {
    //     onLoad () {
    //       console.log('page onload')
    //     }
    //   }
    // })

    var lifecycle$1 = getLifecycycle(WEAPP_PAGE_LIFECYCLE, rel, 'page');

    lifecycle$1.forEach(function (k) {
      if (!output[k] && options[k] && (isFunc(options[k]) || isArr(options[k]))) {
        output.methods[k] = function() {
          var args = [], len = arguments.length;
          while ( len-- ) args[ len ] = arguments[ len ];

          return callUserMethod(this.$wepy, this.$wepy.$options, k, args);
        };
      }
    });
  }
  var lifecycle = getLifecycycle(WEAPP_COMPONENT_LIFECYCLE, rel, 'component');

  lifecycle.forEach(function (k) {
    // beforeCreate is not a real lifecycle
    if (!output[k] && k !== 'beforeCreate' && (isFunc(options[k]) || isArr(options[k]))) {
      output[k] = function() {
        var args = [], len = arguments.length;
        while ( len-- ) args[ len ] = arguments[ len ];

        return callUserMethod(this.$wepy, this.$wepy.$options, k, args);
      };
    }
  });
}

var config$1 = {
  optionMergeStrategies: {},
  constants: {
    WEAPP_LIFECYCLE: WEAPP_LIFECYCLE,
    WEAPP_APP_LIFECYCLE: WEAPP_APP_LIFECYCLE,
    WEAPP_PAGE_LIFECYCLE: WEAPP_PAGE_LIFECYCLE,
    WEAPP_COMPONENT_LIFECYCLE: WEAPP_COMPONENT_LIFECYCLE
  }
};

// [Default Strategy]
// Update if it's not exist in output. Can be replaced by option[key].
// e.g.
// export default {
//   myCustomMethod () {
//     // doSomething
//   }
// }
//
// [Merge Strategy]
// Replaced by the latest mixins property.
// e.g.
// export default {
//   data: {
//     a: 1
//   }
// }
//
// [Lifecycle Strategy]
// Extend lifecycle. update lifecycle to an array.
// e.g.
// export default {
//   onShow: {
//     console.log('onShow');
//   }
// }
var globalMixinPatched = false;

var strats = null;

function getStrategy(key) {
  if (!strats) {
    initStrats();
  }
  if (strats[key]) {
    return strats[key];
  } else {
    return defaultStrat;
  }
}
function defaultStrat(output, option, key, data) {
  if (!output[key]) {
    output[key] = data;
  }
}

function simpleMerge(parentVal, childVal) {
  return !parentVal || !childVal ? parentVal || childVal : Object.assign({}, parentVal, childVal);
}

function initStrats() {
  if (strats) { return strats; }

  strats = config$1.optionMergeStrategies;

  strats.data = strats.props = strats.methods = strats.computed = strats.watch = strats.hooks = function mergeStrategy(
    output,
    option,
    key,
    data
  ) {
    option[key] = simpleMerge(option[key], data);
  };

  WEAPP_LIFECYCLE.forEach(function (lifecycle) {
    if (!strats[lifecycle]) {
      strats[lifecycle] = function lifeCycleStrategy(output, option, key, data) {
        if (!option[key]) {
          option[key] = isArr(data) ? data : [data];
        } else {
          option[key] = [data].concat(option[key]);
        }
      };
    }
  });
}

function patchMixins(output, option, mixins) {
  if (!mixins && !$global.mixin) {
    return;
  }

  if (!globalMixinPatched) {
    var globalMixin = $global.mixin || [];

    mixins = globalMixin.concat(mixins);
    globalMixinPatched = true;
  }

  if (isArr(mixins)) {
    mixins.forEach(function (mixin) { return patchMixins(output, option, mixin); });
    globalMixinPatched = false;
  } else {
    if (!strats) {
      initStrats();
    }
    for (var k in mixins) {
      strat = getStrategy(k);
      var strat = strats[k] || defaultStrat;
      strat(output, option, k, mixins[k]);
    }
  }
}

function patchRelations(output, relations) {
  if (!relations) {
    relations = {};
  }
  output.relations = relations;
}

function app$1(option, rel) {
  var appConfig = {};

  patchMixins(appConfig, option, option.mixins);
  patchAppLifecycle(appConfig, option, rel);

  return App(appConfig);
}

function component(opt, rel) {
  if ( opt === void 0 ) opt = {};

  var compConfig = {
    externalClasses: opt.externalClasses || [],
    // support component options property
    // example: options: {addGlobalClass:true}
    options: opt.options || {}
  };

  patchMixins(compConfig, opt, opt.mixins);

  if (opt.properties) {
    compConfig.properties = opt.properties;
    if (opt.props) {
      // eslint-disable-next-line no-console
      console.warn("props will be ignore, if properties is set");
    }
  } else if (opt.props) {
    patchProps(compConfig, opt.props);
  }

  patchMethods(compConfig, opt.methods, true);

  patchData(compConfig, opt.data, true);

  patchRelations(compConfig, opt.relations);

  patchLifecycle(compConfig, opt, rel, true);

  return Component(compConfig);
}

function page(opt, rel) {
  if ( opt === void 0 ) opt = {};

  var pageConfig = {
    externalClasses: opt.externalClasses || [],
    // support component options property
    // example: options: {addGlobalClass:true}
    options: opt.options || {}
  };

  patchMixins(pageConfig, opt, opt.mixins);

  if (opt.properties) {
    pageConfig.properties = opt.properties;
    if (opt.props) {
      // eslint-disable-next-line
      console.warn("props will be ignore, if properties is set");
    }
  } else if (opt.props) {
    patchProps(pageConfig, opt.props);
  }

  patchMethods(pageConfig, opt.methods);

  patchData(pageConfig, opt.data);

  patchLifecycle(pageConfig, opt, rel);

  return Component(pageConfig);
}

function initGlobalAPI(wepy) {
  wepy.use = use;
  wepy.mixin = mixin;

  wepy.set = function(target, key, val) {
    set.apply(wepy, [undefined, target, key, val]);
  };

  wepy.delete = del;

  wepy.observe = observe;

  wepy.nextTick = renderNextTick;

  wepy.app = app$1;
  wepy.page = page;
  wepy.component = component;

  return wepy;
}

var wepy = initGlobalAPI(WepyConstructor);

wepy.config = config$1;
wepy.global = $global;
wepy.version = "2.0.0-alpha.13";

module.exports = wepy;

},/***** module 2 end *****/


/***** module 3 start *****/
/***** /Users/xingchenhe/Documents/work/git.code.oa.com/live-demo-component/node_modules/tim-wx-sdk/tim-wx.js *****/
function(module, exports, __wepy_require) {!function(e,t){"object"==typeof exports&&"undefined"!=typeof module?module.exports=t():"function"==typeof define&&define.amd?define(t):(e=e||self).TIM=t()}(this,(function(){var e={SDK_READY:"sdkStateReady",SDK_NOT_READY:"sdkStateNotReady",SDK_DESTROY:"sdkDestroy",MESSAGE_RECEIVED:"onMessageReceived",MESSAGE_REVOKED:"onMessageRevoked",CONVERSATION_LIST_UPDATED:"onConversationListUpdated",GROUP_LIST_UPDATED:"onGroupListUpdated",GROUP_SYSTEM_NOTICE_RECEIVED:"receiveGroupSystemNotice",PROFILE_UPDATED:"onProfileUpdated",BLACKLIST_UPDATED:"blacklistUpdated",KICKED_OUT:"kickedOut",ERROR:"error",NET_STATE_CHANGE:"netStateChange"},t={MSG_TEXT:"TIMTextElem",MSG_IMAGE:"TIMImageElem",MSG_SOUND:"TIMSoundElem",MSG_AUDIO:"TIMSoundElem",MSG_FILE:"TIMFileElem",MSG_FACE:"TIMFaceElem",MSG_VIDEO:"TIMVideoFileElem",MSG_GEO:"TIMLocationElem",MSG_GRP_TIP:"TIMGroupTipElem",MSG_GRP_SYS_NOTICE:"TIMGroupSystemNoticeElem",MSG_CUSTOM:"TIMCustomElem",MSG_PRIORITY_HIGH:"High",MSG_PRIORITY_NORMAL:"Normal",MSG_PRIORITY_LOW:"Low",MSG_PRIORITY_LOWEST:"Lowest",CONV_C2C:"C2C",CONV_GROUP:"GROUP",CONV_SYSTEM:"@TIM#SYSTEM",GRP_PRIVATE:"Private",GRP_PUBLIC:"Public",GRP_CHATROOM:"ChatRoom",GRP_AVCHATROOM:"AVChatRoom",GRP_MBR_ROLE_OWNER:"Owner",GRP_MBR_ROLE_ADMIN:"Admin",GRP_MBR_ROLE_MEMBER:"Member",GRP_TIP_MBR_JOIN:1,GRP_TIP_MBR_QUIT:2,GRP_TIP_MBR_KICKED_OUT:3,GRP_TIP_MBR_SET_ADMIN:4,GRP_TIP_MBR_CANCELED_ADMIN:5,GRP_TIP_GRP_PROFILE_UPDATED:6,GRP_TIP_MBR_PROFILE_UPDATED:7,MSG_REMIND_ACPT_AND_NOTE:"AcceptAndNotify",MSG_REMIND_ACPT_NOT_NOTE:"AcceptNotNotify",MSG_REMIND_DISCARD:"Discard",GENDER_UNKNOWN:"Gender_Type_Unknown",GENDER_FEMALE:"Gender_Type_Female",GENDER_MALE:"Gender_Type_Male",KICKED_OUT_MULT_ACCOUNT:"multipleAccount",KICKED_OUT_MULT_DEVICE:"multipleDevice",KICKED_OUT_USERSIG_EXPIRED:"userSigExpired",ALLOW_TYPE_ALLOW_ANY:"AllowType_Type_AllowAny",ALLOW_TYPE_NEED_CONFIRM:"AllowType_Type_NeedConfirm",ALLOW_TYPE_DENY_ANY:"AllowType_Type_DenyAny",FORBID_TYPE_NONE:"AdminForbid_Type_None",FORBID_TYPE_SEND_OUT:"AdminForbid_Type_SendOut",JOIN_OPTIONS_FREE_ACCESS:"FreeAccess",JOIN_OPTIONS_NEED_PERMISSION:"NeedPermission",JOIN_OPTIONS_DISABLE_APPLY:"DisableApply",JOIN_STATUS_SUCCESS:"JoinedSuccess",JOIN_STATUS_ALREADY_IN_GROUP:"AlreadyInGroup",JOIN_STATUS_WAIT_APPROVAL:"WaitAdminApproval",GRP_PROFILE_OWNER_ID:"ownerID",GRP_PROFILE_CREATE_TIME:"createTime",GRP_PROFILE_LAST_INFO_TIME:"lastInfoTime",GRP_PROFILE_MEMBER_NUM:"memberNum",GRP_PROFILE_MAX_MEMBER_NUM:"maxMemberNum",GRP_PROFILE_JOIN_OPTION:"joinOption",GRP_PROFILE_INTRODUCTION:"introduction",GRP_PROFILE_NOTIFICATION:"notification",NET_STATE_CONNECTED:"connected",NET_STATE_CONNECTING:"connecting",NET_STATE_DISCONNECTED:"disconnected"};function n(e){return(n="function"==typeof Symbol&&"symbol"==typeof Symbol.iterator?function(e){return typeof e}:function(e){return e&&"function"==typeof Symbol&&e.constructor===Symbol&&e!==Symbol.prototype?"symbol":typeof e})(e)}function r(e,t){if(!(e instanceof t))throw new TypeError("Cannot call a class as a function")}function o(e,t){for(var n=0;n<t.length;n++){var r=t[n];r.enumerable=r.enumerable||!1,r.configurable=!0,"value"in r&&(r.writable=!0),Object.defineProperty(e,r.key,r)}}function i(e,t,n){return t&&o(e.prototype,t),n&&o(e,n),e}function s(e,t,n){return t in e?Object.defineProperty(e,t,{value:n,enumerable:!0,configurable:!0,writable:!0}):e[t]=n,e}function a(e,t){var n=Object.keys(e);if(Object.getOwnPropertySymbols){var r=Object.getOwnPropertySymbols(e);t&&(r=r.filter((function(t){return Object.getOwnPropertyDescriptor(e,t).enumerable}))),n.push.apply(n,r)}return n}function u(e){for(var t=1;t<arguments.length;t++){var n=null!=arguments[t]?arguments[t]:{};t%2?a(Object(n),!0).forEach((function(t){s(e,t,n[t])})):Object.getOwnPropertyDescriptors?Object.defineProperties(e,Object.getOwnPropertyDescriptors(n)):a(Object(n)).forEach((function(t){Object.defineProperty(e,t,Object.getOwnPropertyDescriptor(n,t))}))}return e}function c(e,t){if("function"!=typeof t&&null!==t)throw new TypeError("Super expression must either be null or a function");e.prototype=Object.create(t&&t.prototype,{constructor:{value:e,writable:!0,configurable:!0}}),t&&p(e,t)}function l(e){return(l=Object.setPrototypeOf?Object.getPrototypeOf:function(e){return e.__proto__||Object.getPrototypeOf(e)})(e)}function p(e,t){return(p=Object.setPrototypeOf||function(e,t){return e.__proto__=t,e})(e,t)}function h(){if("undefined"==typeof Reflect||!Reflect.construct)return!1;if(Reflect.construct.sham)return!1;if("function"==typeof Proxy)return!0;try{return Date.prototype.toString.call(Reflect.construct(Date,[],(function(){}))),!0}catch(e){return!1}}function f(e,t,n){return(f=h()?Reflect.construct:function(e,t,n){var r=[null];r.push.apply(r,t);var o=new(Function.bind.apply(e,r));return n&&p(o,n.prototype),o}).apply(null,arguments)}function d(e){var t="function"==typeof Map?new Map:void 0;return(d=function(e){if(null===e||(n=e,-1===Function.toString.call(n).indexOf("[native code]")))return e;var n;if("function"!=typeof e)throw new TypeError("Super expression must either be null or a function");if(void 0!==t){if(t.has(e))return t.get(e);t.set(e,r)}function r(){return f(e,arguments,l(this).constructor)}return r.prototype=Object.create(e.prototype,{constructor:{value:r,enumerable:!1,writable:!0,configurable:!0}}),p(r,e)})(e)}function g(e){if(void 0===e)throw new ReferenceError("this hasn't been initialised - super() hasn't been called");return e}function m(e,t){return!t||"object"!=typeof t&&"function"!=typeof t?g(e):t}function y(e){return function(){var t,n=l(e);if(h()){var r=l(this).constructor;t=Reflect.construct(n,arguments,r)}else t=n.apply(this,arguments);return m(this,t)}}function v(e,t){return function(e){if(Array.isArray(e))return e}(e)||function(e,t){if("undefined"==typeof Symbol||!(Symbol.iterator in Object(e)))return;var n=[],r=!0,o=!1,i=void 0;try{for(var s,a=e[Symbol.iterator]();!(r=(s=a.next()).done)&&(n.push(s.value),!t||n.length!==t);r=!0);}catch(u){o=!0,i=u}finally{try{r||null==a.return||a.return()}finally{if(o)throw i}}return n}(e,t)||C(e,t)||function(){throw new TypeError("Invalid attempt to destructure non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method.")}()}function _(e){return function(e){if(Array.isArray(e))return I(e)}(e)||function(e){if("undefined"!=typeof Symbol&&Symbol.iterator in Object(e))return Array.from(e)}(e)||C(e)||function(){throw new TypeError("Invalid attempt to spread non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method.")}()}function C(e,t){if(e){if("string"==typeof e)return I(e,t);var n=Object.prototype.toString.call(e).slice(8,-1);return"Object"===n&&e.constructor&&(n=e.constructor.name),"Map"===n||"Set"===n?Array.from(n):"Arguments"===n||/^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n)?I(e,t):void 0}}function I(e,t){(null==t||t>e.length)&&(t=e.length);for(var n=0,r=new Array(t);n<t;n++)r[n]=e[n];return r}function M(e){if("undefined"==typeof Symbol||null==e[Symbol.iterator]){if(Array.isArray(e)||(e=C(e))){var t=0,n=function(){};return{s:n,n:function(){return t>=e.length?{done:!0}:{done:!1,value:e[t++]}},e:function(e){throw e},f:n}}throw new TypeError("Invalid attempt to iterate non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method.")}var r,o,i=!0,s=!1;return{s:function(){r=e[Symbol.iterator]()},n:function(){var e=r.next();return i=e.done,e},e:function(e){s=!0,o=e},f:function(){try{i||null==r.return||r.return()}finally{if(s)throw o}}}}var S=function(){function e(){r(this,e),this.cache=[],this.options=null}return i(e,[{key:"use",value:function(e){if("function"!=typeof e)throw"middleware must be a function";return this.cache.push(e),this}},{key:"next",value:function(e){if(this.middlewares&&this.middlewares.length>0)return this.middlewares.shift().call(this,this.options,this.next.bind(this))}},{key:"run",value:function(e){return this.middlewares=this.cache.map((function(e){return e})),this.options=e,this.next()}}]),e}(),D="undefined"!=typeof globalThis?globalThis:"undefined"!=typeof window?window:"undefined"!=typeof global?global:"undefined"!=typeof self?self:{};function T(e,t){return e(t={exports:{}},t.exports),t.exports}var E,k,w,A=T((function(e,t){var n,r,o,i,s,a,u,c,l,p,h,f,d,g,m,y,v,_;e.exports=(n="function"==typeof Promise,r="object"==typeof self?self:D,o="undefined"!=typeof Symbol,i="undefined"!=typeof Map,s="undefined"!=typeof Set,a="undefined"!=typeof WeakMap,u="undefined"!=typeof WeakSet,c="undefined"!=typeof DataView,l=o&&void 0!==Symbol.iterator,p=o&&void 0!==Symbol.toStringTag,h=s&&"function"==typeof Set.prototype.entries,f=i&&"function"==typeof Map.prototype.entries,d=h&&Object.getPrototypeOf((new Set).entries()),g=f&&Object.getPrototypeOf((new Map).entries()),m=l&&"function"==typeof Array.prototype[Symbol.iterator],y=m&&Object.getPrototypeOf([][Symbol.iterator]()),v=l&&"function"==typeof String.prototype[Symbol.iterator],_=v&&Object.getPrototypeOf(""[Symbol.iterator]()),function(e){var t=typeof e;if("object"!==t)return t;if(null===e)return"null";if(e===r)return"global";if(Array.isArray(e)&&(!1===p||!(Symbol.toStringTag in e)))return"Array";if("object"==typeof window&&null!==window){if("object"==typeof window.location&&e===window.location)return"Location";if("object"==typeof window.document&&e===window.document)return"Document";if("object"==typeof window.navigator){if("object"==typeof window.navigator.mimeTypes&&e===window.navigator.mimeTypes)return"MimeTypeArray";if("object"==typeof window.navigator.plugins&&e===window.navigator.plugins)return"PluginArray"}if(("function"==typeof window.HTMLElement||"object"==typeof window.HTMLElement)&&e instanceof window.HTMLElement){if("BLOCKQUOTE"===e.tagName)return"HTMLQuoteElement";if("TD"===e.tagName)return"HTMLTableDataCellElement";if("TH"===e.tagName)return"HTMLTableHeaderCellElement"}}var o=p&&e[Symbol.toStringTag];if("string"==typeof o)return o;var l=Object.getPrototypeOf(e);return l===RegExp.prototype?"RegExp":l===Date.prototype?"Date":n&&l===Promise.prototype?"Promise":s&&l===Set.prototype?"Set":i&&l===Map.prototype?"Map":u&&l===WeakSet.prototype?"WeakSet":a&&l===WeakMap.prototype?"WeakMap":c&&l===DataView.prototype?"DataView":i&&l===g?"Map Iterator":s&&l===d?"Set Iterator":m&&l===y?"Array Iterator":v&&l===_?"String Iterator":null===l?"Object":Object.prototype.toString.call(e).slice(8,-1)})})),R="undefined"!=typeof window,O="undefined"!=typeof wx&&"function"==typeof wx.getSystemInfoSync,L=R&&window.navigator&&window.navigator.userAgent||"",N=/AppleWebKit\/([\d.]+)/i.exec(L),b=(N&&parseFloat(N.pop()),/iPad/i.test(L)),P=(/iPhone/i.test(L),/iPod/i.test(L),(E=L.match(/OS (\d+)_/i))&&E[1]&&E[1],/Android/i.test(L)),G=function(){var e=L.match(/Android (\d+)(?:\.(\d+))?(?:\.(\d+))*/i);if(!e)return null;var t=e[1]&&parseFloat(e[1]),n=e[2]&&parseFloat(e[2]);return t&&n?parseFloat(e[1]+"."+e[2]):t||null}(),U=(P&&/webkit/i.test(L),/Firefox/i.test(L),/Edge/i.test(L)),q=!U&&/Chrome/i.test(L),x=(function(){var e=L.match(/Chrome\/(\d+)/);e&&e[1]&&parseFloat(e[1])}(),/MSIE/.test(L)),F=(/MSIE\s8\.0/.test(L),function(){var e=/MSIE\s(\d+)\.\d/.exec(L),t=e&&parseFloat(e[1]);return!t&&/Trident\/7.0/i.test(L)&&/rv:11.0/.test(L)&&(t=11),t}()),H=(/Safari/i.test(L),/TBS\/\d+/i.test(L)),B=(function(){var e=L.match(/TBS\/(\d+)/i);if(e&&e[1])e[1]}(),!H&&/MQQBrowser\/\d+/i.test(L),!H&&/ QQBrowser\/\d+/i.test(L),/(micromessenger|webbrowser)/i.test(L)),V=(/Windows/i.test(L),/MAC OS X/i.test(L),/MicroMessenger/i.test(L),"undefined"!=typeof global?global:"undefined"!=typeof self?self:"undefined"!=typeof window?window:{});k="undefined"!=typeof console?console:void 0!==V&&V.console?V.console:"undefined"!=typeof window&&window.console?window.console:{};for(var K=function(){},j=["assert","clear","count","debug","dir","dirxml","error","exception","group","groupCollapsed","groupEnd","info","log","markTimeline","profile","profileEnd","table","time","timeEnd","timeStamp","trace","warn"],$=j.length;$--;)w=j[$],console[w]||(k[w]=K);k.methods=j;var Y=k,z=0,W=new Map;function X(){var e=new Date;return"TIM "+e.toLocaleTimeString("en-US",{hour12:!1})+"."+function(e){var t;switch(e.toString().length){case 1:t="00"+e;break;case 2:t="0"+e;break;default:t=e}return t}(e.getMilliseconds())+":"}var J={_data:[],_length:0,_visible:!1,arguments2String:function(e){var t;if(1===e.length)t=X()+e[0];else{t=X();for(var n=0,r=e.length;n<r;n++)ie(e[n])?ae(e[n])?t+=fe(e[n]):t+=JSON.stringify(e[n]):t+=e[n],t+=" "}return t},debug:function(){if(z<=-1){var e=this.arguments2String(arguments);J.record(e,"debug"),Y.debug(e)}},log:function(){if(z<=0){var e=this.arguments2String(arguments);J.record(e,"log"),Y.log(e)}},info:function(){if(z<=1){var e=this.arguments2String(arguments);J.record(e,"info"),Y.info(e)}},warn:function(){if(z<=2){var e=this.arguments2String(arguments);J.record(e,"warn"),Y.warn(e)}},error:function(){if(z<=3){var e=this.arguments2String(arguments);J.record(e,"error"),Y.error(e)}},time:function(e){W.set(e,pe.now())},timeEnd:function(e){if(W.has(e)){var t=pe.now()-W.get(e);return W.delete(e),t}return Y.warn("未找到对应label: ".concat(e,", 请在调用 logger.timeEnd 前，调用 logger.time")),0},setLevel:function(e){e<4&&Y.log(X()+"set level from "+z+" to "+e),z=e},record:function(e,t){1100===J._length&&(J._data.splice(0,100),J._length=1e3),J._length++,J._data.push("".concat(e," [").concat(t,"] \n"))},getLog:function(){return J._data}},Q=function(e){return"file"===ue(e)},Z=function(e){return null!==e&&("number"==typeof e&&!isNaN(e-0)||"object"===n(e)&&e.constructor===Number)},ee=function(e){return"string"==typeof e},te=function(e){return null!==e&&"object"===n(e)},ne=function(e){if("object"!==n(e)||null===e)return!1;var t=Object.getPrototypeOf(e);if(null===t)return!0;for(var r=t;null!==Object.getPrototypeOf(r);)r=Object.getPrototypeOf(r);return t===r},re=function(e){return"function"==typeof Array.isArray?Array.isArray(e):"array"===ue(e)},oe=function(e){return void 0===e},ie=function(e){return re(e)||te(e)},se=function(e){return"function"==typeof e},ae=function(e){return e instanceof Error},ue=function(e){return Object.prototype.toString.call(e).match(/^\[object (.*)\]$/)[1].toLowerCase()},ce=function(e){if("string"!=typeof e)return!1;var t=e[0];return!/[^a-zA-Z0-9]/.test(t)},le=0;Date.now||(Date.now=function(){return(new Date).getTime()});var pe={now:function(){0===le&&(le=Date.now()-1);var e=Date.now()-le;return e>4294967295?(le+=4294967295,Date.now()-le):e},utc:function(){return Math.round(Date.now()/1e3)}},he=function e(t,n,r,o){if(!ie(t)||!ie(n))return 0;for(var i,s=0,a=Object.keys(n),u=0,c=a.length;u<c;u++)if(i=a[u],!(oe(n[i])||r&&r.includes(i)))if(ie(t[i])&&ie(n[i]))s+=e(t[i],n[i],r,o);else{if(o&&o.includes(n[i]))continue;t[i]!==n[i]&&(t[i]=n[i],s+=1)}return s},fe=function(e){return JSON.stringify(e,["message","code"])},de=function(){var e=new Date,t=e.toISOString(),n=e.getTimezoneOffset()/60,r="";return r=n<0?n>-10?"+0"+Math.abs(100*n):"+"+Math.abs(100*n):n>=10?"-"+100*n:"-0"+100*n,t.replace("Z",r)},ge=function(e){if(0===e.length)return 0;for(var t=0,n=0,r="undefined"!=typeof document&&void 0!==document.characterSet?document.characterSet:"UTF-8";void 0!==e[t];)n+=e[t++].charCodeAt[t]<=255?1:!1===r?3:2;return n},me=function(e){var t=e||99999999;return Math.round(Math.random()*t)},ye="0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",ve=ye.length,_e=function(e,t){for(var n in e)if(e[n]===t)return!0;return!1},Ce={},Ie=function(){if(O)return"https:";var e=window.location.protocol;return["http:","https:"].indexOf(e)<0&&(e="http:"),e},Me=function(e){return-1===e.indexOf("http://")||-1===e.indexOf("https://")?"https://"+e:e.replace(/https|http/,"https")};function Se(e,t){re(e)&&re(t)?t.forEach((function(t){var n=t.key,r=t.value,o=e.find((function(e){return e.key===n}));o?o.value=r:e.push({key:n,value:r})})):J.warn("updateCustomField target 或 source 不是数组，忽略此次更新。")}var De=function(e){return e===t.GRP_PUBLIC},Te=function(e){return e===t.GRP_AVCHATROOM},Ee=function(e){return ee(e)&&e===t.CONV_SYSTEM};function ke(e,t){var n={};return Object.keys(e).forEach((function(r){n[r]=t(e[r],r)})),n}var we=Object.prototype.hasOwnProperty;function Ae(e){if(null==e)return!0;if("boolean"==typeof e)return!1;if("number"==typeof e)return 0===e;if("string"==typeof e)return 0===e.length;if("function"==typeof e)return 0===e.length;if(Array.isArray(e))return 0===e.length;if(e instanceof Error)return""===e.message;if(ne(e)){for(var t in e)if(we.call(e,t))return!1;return!0}return!("map"!==ue(e)&&!function(e){return"set"===ue(e)}(e)&&!Q(e))&&0===e.size}function Re(e,t,n){if(void 0===t)return!0;var r=!0;if("object"===A(t).toLowerCase())Object.keys(t).forEach((function(o){var i=1===e.length?e[0][o]:void 0;r=!!Oe(i,t[o],n,o)&&r}));else if("array"===A(t).toLowerCase())for(var o=0;o<t.length;o++)r=!!Oe(e[o],t[o],n,t[o].name)&&r;if(r)return r;throw new Error("Params validate failed.")}function Oe(e,t,n,r){if(void 0===t)return!0;var o=!0;return t.required&&Ae(e)&&(Y.error("TIM [".concat(n,'] Missing required params: "').concat(r,'".')),o=!1),Ae(e)||A(e).toLowerCase()===t.type.toLowerCase()||(Y.error("TIM [".concat(n,'] Invalid params: type check failed for "').concat(r,'".Expected ').concat(t.type,".")),o=!1),t.validator&&!t.validator(e)&&(Y.error("TIM [".concat(n,"] Invalid params: custom validator check failed for params.")),o=!1),o}var Le={SUCCESS:"JoinedSuccess",WAIT_APPROVAL:"WaitAdminApproval"},Ne={SUCCESS:0},be={IS_LOGIN:1,IS_NOT_LOGIN:0},Pe={UNSEND:"unSend",SUCCESS:"success",FAIL:"fail"},Ge={NOT_START:"notStart",PENDING:"pengding",RESOLVED:"resolved",REJECTED:"rejected"},Ue=function(){function e(n){r(this,e),this.type=t.MSG_TEXT,this.content={text:n.text||""}}return i(e,[{key:"setText",value:function(e){this.content.text=e}},{key:"sendable",value:function(){return 0!==this.content.text.length}}]),e}(),qe={JSON:{TYPE:{C2C:{NOTICE:1,COMMON:9,EVENT:10},GROUP:{COMMON:3,TIP:4,SYSTEM:5,TIP2:6},FRIEND:{NOTICE:7},PROFILE:{NOTICE:8}},SUBTYPE:{C2C:{COMMON:0,READED:92,KICKEDOUT:96},GROUP:{COMMON:0,LOVEMESSAGE:1,TIP:2,REDPACKET:3}},OPTIONS:{GROUP:{JOIN:1,QUIT:2,KICK:3,SET_ADMIN:4,CANCEL_ADMIN:5,MODIFY_GROUP_INFO:6,MODIFY_MEMBER_INFO:7}}},PROTOBUF:{},IMAGE_TYPES:{ORIGIN:1,LARGE:2,SMALL:3},IMAGE_FORMAT:{JPG:1,JPEG:1,GIF:2,PNG:3,BMP:4,UNKNOWN:255}},xe=1,Fe=2,He=3,Be=4,Ve=5,Ke=7,je=8,$e=9,Ye=10,ze=15,We=255,Xe=2,Je=0,Qe=1,Ze={NICK:"Tag_Profile_IM_Nick",GENDER:"Tag_Profile_IM_Gender",BIRTHDAY:"Tag_Profile_IM_BirthDay",LOCATION:"Tag_Profile_IM_Location",SELFSIGNATURE:"Tag_Profile_IM_SelfSignature",ALLOWTYPE:"Tag_Profile_IM_AllowType",LANGUAGE:"Tag_Profile_IM_Language",AVATAR:"Tag_Profile_IM_Image",MESSAGESETTINGS:"Tag_Profile_IM_MsgSettings",ADMINFORBIDTYPE:"Tag_Profile_IM_AdminForbidType",LEVEL:"Tag_Profile_IM_Level",ROLE:"Tag_Profile_IM_Role"},et={UNKNOWN:"Gender_Type_Unknown",FEMALE:"Gender_Type_Female",MALE:"Gender_Type_Male"},tt={NONE:"AdminForbid_Type_None",SEND_OUT:"AdminForbid_Type_SendOut"},nt={NEED_CONFIRM:"AllowType_Type_NeedConfirm",ALLOW_ANY:"AllowType_Type_AllowAny",DENY_ANY:"AllowType_Type_DenyAny"},rt=function(){function e(n){r(this,e),this._imageMemoryURL="",this._file=n.file,O?this.createImageDataASURLInWXMiniApp(n.file):this.createImageDataASURLInWeb(n.file),this._initImageInfoModel(),this.type=t.MSG_IMAGE,this._percent=0,this.content={imageFormat:qe.IMAGE_FORMAT[n.imageFormat]||qe.IMAGE_FORMAT.UNKNOWN,uuid:n.uuid,imageInfoArray:[]},this.initImageInfoArray(n.imageInfoArray),this._defaultImage="http://imgcache.qq.com/open/qcloud/video/act/webim-images/default.jpg",this._autoFixUrl()}return i(e,[{key:"_initImageInfoModel",value:function(){var e=this;this._ImageInfoModel=function(t){this.instanceID=me(9999999),this.sizeType=t.type||0,this.size=t.size||0,this.width=t.width||0,this.height=t.height||0,this.imageUrl=t.url||"",this.url=t.url||e._imageMemoryURL||e._defaultImage},this._ImageInfoModel.prototype={setSizeType:function(e){this.sizeType=e},setImageUrl:function(e){e&&(this.imageUrl=e)},getImageUrl:function(){return this.imageUrl}}}},{key:"initImageInfoArray",value:function(e){for(var t=2,n=null,r=null;t>=0;)r=void 0===e||void 0===e[t]?{type:0,size:0,width:0,height:0,url:""}:e[t],(n=new this._ImageInfoModel(r)).setSizeType(t+1),this.addImageInfo(n),t--}},{key:"updateImageInfoArray",value:function(e){for(var t,n=this.content.imageInfoArray.length,r=0;r<n;r++)t=this.content.imageInfoArray[r],e.size&&(t.size=e.size),e.url&&t.setImageUrl(e.url),e.width&&(t.width=e.width),e.height&&(t.height=e.height)}},{key:"_autoFixUrl",value:function(){for(var e=this.content.imageInfoArray.length,t="",n="",r=["http","https"],o=null,i=0;i<e;i++)this.content.imageInfoArray[i].url&&""!==(o=this.content.imageInfoArray[i]).imageUrl&&(n=o.imageUrl.slice(0,o.imageUrl.indexOf("://")+1),t=o.imageUrl.slice(o.imageUrl.indexOf("://")+1),r.indexOf(n)<0&&(n="https:"),this.content.imageInfoArray[i].setImageUrl([n,t].join("")))}},{key:"updatePercent",value:function(e){this._percent=e,this._percent>1&&(this._percent=1)}},{key:"updateImageFormat",value:function(e){this.content.imageFormat=e}},{key:"createImageDataASURLInWeb",value:function(e){void 0!==e&&e.files.length>0&&(this._imageMemoryURL=window.URL.createObjectURL(e.files[0]))}},{key:"createImageDataASURLInWXMiniApp",value:function(e){e&&e.url&&(this._imageMemoryURL=e.url)}},{key:"replaceImageInfo",value:function(e,t){this.content.imageInfoArray[t]instanceof this._ImageInfoModel||(this.content.imageInfoArray[t]=e)}},{key:"addImageInfo",value:function(e){this.content.imageInfoArray.length>=3||this.content.imageInfoArray.push(e)}},{key:"sendable",value:function(){return 0!==this.content.imageInfoArray.length&&(""!==this.content.imageInfoArray[0].imageUrl&&0!==this.content.imageInfoArray[0].size)}}]),e}(),ot=function(){function e(n){r(this,e),this.type=t.MSG_FACE,this.content=n||null}return i(e,[{key:"sendable",value:function(){return null!==this.content}}]),e}(),it=function(){function e(n){r(this,e),this.type=t.MSG_AUDIO,this._percent=0,this.content={downloadFlag:2,second:n.second,size:n.size,url:n.url,remoteAudioUrl:"",uuid:n.uuid}}return i(e,[{key:"updatePercent",value:function(e){this._percent=e,this._percent>1&&(this._percent=1)}},{key:"updateAudioUrl",value:function(e){this.content.remoteAudioUrl=e}},{key:"sendable",value:function(){return""!==this.content.remoteAudioUrl}}]),e}(),st={from:!0,groupID:!0,groupName:!0,to:!0},at=function(){function e(n){r(this,e),this.type=t.MSG_GRP_TIP,this.content={},this._initContent(n)}return i(e,[{key:"_initContent",value:function(e){var t=this;Object.keys(e).forEach((function(n){switch(n){case"remarkInfo":break;case"groupProfile":t.content.groupProfile={},t._initGroupProfile(e[n]);break;case"operatorInfo":case"memberInfoList":break;case"msgMemberInfo":t.content.memberList=e[n],Object.defineProperty(t.content,"msgMemberInfo",{get:function(){return J.warn("!!! 禁言的群提示消息中的 payload.msgMemberInfo 属性即将废弃，请使用 payload.memberList 属性替代。 \n","msgMemberInfo 中的 shutupTime 属性对应更改为 memberList 中的 muteTime 属性，表示禁言时长。 \n","参考：群提示消息 https://imsdk-1252463788.file.myqcloud.com/IM_DOC/Web/Message.html#.GroupTipPayload"),t.content.memberList.map((function(e){return{userID:e.userID,shutupTime:e.muteTime}}))}});break;default:t.content[n]=e[n]}})),this.content.userIDList||(this.content.userIDList=[this.content.operatorID])}},{key:"_initGroupProfile",value:function(e){for(var t=Object.keys(e),n=0;n<t.length;n++){var r=t[n];st[r]&&(this.content.groupProfile[r]=e[r])}}}]),e}(),ut={from:!0,groupID:!0,name:!0,to:!0},ct=function(){function e(n){r(this,e),this.type=t.MSG_GRP_SYS_NOTICE,this.content={},this._initContent(n)}return i(e,[{key:"_initContent",value:function(e){var t=this;Object.keys(e).forEach((function(n){switch(n){case"memberInfoList":break;case"remarkInfo":t.content.handleMessage=e[n];break;case"groupProfile":t.content.groupProfile={},t._initGroupProfile(e[n]);break;default:t.content[n]=e[n]}}))}},{key:"_initGroupProfile",value:function(e){for(var t=Object.keys(e),n=0;n<t.length;n++){var r=t[n];ut[r]&&(this.content.groupProfile[r]=e[r])}}}]),e}(),lt={70001:"UserSig 已过期，请重新生成。建议 UserSig 有效期设置不小于24小时。",70002:"UserSig 长度为0，请检查传入的 UserSig 是否正确。",70003:"UserSig 非法，请使用官网提供的 API 重新生成 UserSig(https://cloud.tencent.com/document/product/269/32688)。",70005:"UserSig 非法，请使用官网提供的 API 重新生成 UserSig(https://cloud.tencent.com/document/product/269/32688)。",70009:"UserSig 验证失败，可能因为生成 UserSig 时混用了其他 SDKAppID 的私钥或密钥导致，请使用对应 SDKAppID 下的私钥或密钥重新生成 UserSig(https://cloud.tencent.com/document/product/269/32688)。",70013:"请求中的 UserID 与生成 UserSig 时使用的 UserID 不匹配，您可以在即时通信 IM 控制台的【开发辅助工具(https://console.cloud.tencent.com/im-detail/tool-usersig)】页面校验 UserSig。",70014:"请求中的 SDKAppID 与生成 UserSig 时使用的 SDKAppID 不匹配，您可以在即时通信 IM 控制台的【开发辅助工具(https://console.cloud.tencent.com/im-detail/tool-usersig)】页面校验 UserSig。",70016:"密钥不存在，UserSig 验证失败，请在即时通信 IM 控制台获取密钥(https://cloud.tencent.com/document/product/269/32578#.E8.8E.B7.E5.8F.96.E5.AF.86.E9.92.A5)。",70020:"SDKAppID 未找到，请在即时通信 IM 控制台确认应用信息。",70050:"UserSig 验证次数过于频繁。请检查 UserSig 是否正确，并于1分钟后重新验证。您可以在即时通信 IM 控制台的【开发辅助工具(https://console.cloud.tencent.com/im-detail/tool-usersig)】页面校验 UserSig。",70051:"帐号被拉入黑名单。",70052:"UserSig 已经失效，请重新生成，再次尝试。",70107:"因安全原因被限制登录，请不要频繁登录。",70169:"请求的用户帐号不存在。",70114:"服务端内部超时，请稍后重试。",70202:"服务端内部超时，请稍后重试。",70206:"请求中批量数量不合法。",70402:"参数非法，请检查必填字段是否填充，或者字段的填充是否满足协议要求。",70403:"请求失败，需要 App 管理员权限。",70398:"帐号数超限。如需创建多于100个帐号，请将应用升级为专业版，具体操作指引请参见购买指引(https://cloud.tencent.com/document/product/269/32458)。",70500:"服务端内部错误，请稍后重试。",71e3:"删除帐号失败。仅支持删除体验版帐号，您当前应用为专业版，暂不支持帐号删除。",20001:"请求包非法。",20002:"UserSig 或 A2 失效。",20003:"消息发送方或接收方 UserID 无效或不存在，请检查 UserID 是否已导入即时通信 IM。",20004:"网络异常，请重试。",20005:"服务端内部错误，请重试。",20006:"触发发送单聊消息之前回调，App 后台返回禁止下发该消息。",20007:"发送单聊消息，被对方拉黑，禁止发送。消息发送状态默认展示为失败，您可以登录控制台修改该场景下的消息发送状态展示结果，具体操作请参见消息保留设置(https://cloud.tencent.com/document/product/269/38656)。",20009:"消息发送双方互相不是好友，禁止发送（配置单聊消息校验好友关系才会出现）。",20010:"发送单聊消息，自己不是对方的好友（单向关系），禁止发送。",20011:"发送单聊消息，对方不是自己的好友（单向关系），禁止发送。",20012:"发送方被禁言，该条消息被禁止发送。",20016:"消息撤回超过了时间限制（默认2分钟）。",20018:"删除漫游内部错误。",90001:"JSON 格式解析失败，请检查请求包是否符合 JSON 规范。",90002:"JSON 格式请求包中 MsgBody 不符合消息格式描述，或者 MsgBody 不是 Array 类型，请参考 TIMMsgElement 对象的定义(https://cloud.tencent.com/document/product/269/2720#.E6.B6.88.E6.81.AF.E5.85.83.E7.B4.A0-timmsgelement)。",90003:"JSON 格式请求包体中缺少 To_Account 字段或者 To_Account 帐号不存在。",90005:"JSON 格式请求包体中缺少 MsgRandom 字段或者 MsgRandom 字段不是 Integer 类型。",90006:"JSON 格式请求包体中缺少 MsgTimeStamp 字段或者 MsgTimeStamp 字段不是 Integer 类型。",90007:"JSON 格式请求包体中 MsgBody 类型不是 Array 类型，请将其修改为 Array 类型。",90008:"JSON 格式请求包体中缺少 From_Account 字段或者 From_Account 帐号不存在。",90009:"请求需要 App 管理员权限。",90010:"JSON 格式请求包不符合消息格式描述，请参考 TIMMsgElement 对象的定义(https://cloud.tencent.com/document/product/269/2720#.E6.B6.88.E6.81.AF.E5.85.83.E7.B4.A0-timmsgelement)。",90011:"批量发消息目标帐号超过500，请减少 To_Account 中目标帐号数量。",90012:"To_Account 没有注册或不存在，请确认 To_Account 是否导入即时通信 IM 或者是否拼写错误。",90026:"消息离线存储时间错误（最多不能超过7天）。",90031:"JSON 格式请求包体中 SyncOtherMachine 字段不是 Integer 类型。",90044:"JSON 格式请求包体中 MsgLifeTime 字段不是 Integer 类型。",90048:"请求的用户帐号不存在。",90054:"撤回请求中的 MsgKey 不合法。",90994:"服务内部错误，请重试。",90995:"服务内部错误，请重试。",91e3:"服务内部错误，请重试。",90992:"服务内部错误，请重试；如果所有请求都返回该错误码，且 App 配置了第三方回调，请检查 App 服务端是否正常向即时通信 IM 后台服务端返回回调结果。",93e3:"JSON 数据包超长，消息包体请不要超过8k。",91101:"Web 端长轮询被踢（Web 端同时在线实例个数超出限制）。",10002:"服务端内部错误，请重试。",10003:"请求中的接口名称错误，请核对接口名称并重试。",10004:"参数非法，请根据错误描述检查请求是否正确。",10005:"请求包体中携带的帐号数量过多。",10006:"操作频率限制，请尝试降低调用的频率。",10007:"操作权限不足，例如 Public 群组中普通成员尝试执行踢人操作，但只有 App 管理员才有权限。",10008:"请求非法，可能是请求中携带的签名信息验证不正确，请再次尝试。",10009:"该群不允许群主主动退出。",10010:"群组不存在，或者曾经存在过，但是目前已经被解散。",10011:"解析 JSON 包体失败，请检查包体的格式是否符合 JSON 格式。",10012:"发起操作的 UserID 非法，请检查发起操作的用户 UserID 是否填写正确。",10013:"被邀请加入的用户已经是群成员。",10014:"群已满员，无法将请求中的用户加入群组，如果是批量加人，可以尝试减少加入用户的数量。",10015:"找不到指定 ID 的群组。",10016:"App 后台通过第三方回调拒绝本次操作。",10017:"因被禁言而不能发送消息，请检查发送者是否被设置禁言。",10018:"应答包长度超过最大包长（1MB），请求的内容过多，请尝试减少单次请求的数据量。",10019:"请求的用户帐号不存在。",10021:"群组 ID 已被使用，请选择其他的群组 ID。",10023:"发消息的频率超限，请延长两次发消息时间的间隔。",10024:"此邀请或者申请请求已经被处理。",10025:"群组 ID 已被使用，并且操作者为群主，可以直接使用。",10026:"该 SDKAppID 请求的命令字已被禁用。",10030:"请求撤回的消息不存在。",10031:"消息撤回超过了时间限制（默认2分钟）。",10032:"请求撤回的消息不支持撤回操作。",10033:"群组类型不支持消息撤回操作。",10034:"该消息类型不支持删除操作。",10035:"音视频聊天室和在线成员广播大群不支持删除消息。",10036:"音视频聊天室创建数量超过了限制，请参考价格说明(https://cloud.tencent.com/document/product/269/11673)购买预付费套餐“IM音视频聊天室”。",10037:"单个用户可创建和加入的群组数量超过了限制，请参考价格说明(https://cloud.tencent.com/document/product/269/11673)购买或升级预付费套餐“单人可创建与加入群组数”。",10038:"群成员数量超过限制，请参考价格说明(https://cloud.tencent.com/document/product/269/11673)购买或升级预付费套餐“扩展群人数上限”。",10041:"该应用（SDKAppID）已配置不支持群消息撤回。"},pt=function(e){c(n,e);var t=y(n);function n(e){var o;return r(this,n),(o=t.call(this)).code=e.code,o.message=lt[e.code]||e.message,o.data=e.data||{},o}return n}(d(Error)),ht=2e3,ft=2001,dt=2002,gt=2003,mt=2022,yt=2023,vt=2040,_t=2100,Ct=2103,It=2105,Mt=2106,St=2108,Dt=2109,Tt=2110,Et=2251,kt=2252,wt=2253,At=2300,Rt=2301,Ot=2350,Lt=2351,Nt=2352,bt=2400,Pt=2401,Gt=2402,Ut=2403,qt=2500,xt=2501,Ft=2502,Ht=2600,Bt=2601,Vt=2620,Kt=2621,jt=2622,$t=2660,Yt=2661,zt=2662,Wt=2680,Xt=2681,Jt=2682,Qt=2683,Zt=2684,en=2685,tn=2700,nn=2721,rn=2722,on=2740,sn=2741,an=2742,un=2800,cn=2801,ln=2802,pn=2803,hn=2804,fn=2805,dn=2900,gn=2901,mn=2902,yn=2903,vn=2904,_n=2999,Cn=91101,In=20002,Mn=70001,Sn="无 SDKAppID",Dn="无 accountType",Tn="无 userID",En="无 userSig",kn="无 tinyID",wn="无 a2key",An="未检测到 COS 上传插件",Rn="消息发送失败",On="MessageController.constructor() 需要参数 options",Ln="需要 Message 的实例",Nn='Message.conversationType 只能为 "C2C" 或 "GROUP"',bn="无法发送空文件",Pn="回调函数运行时遇到错误，请检查接入侧代码",Gn="消息撤回失败",Un="请先选择一个图片",qn="只允许上传 jpg png jpeg gif 格式的图片",xn="图片大小超过20M，无法发送",Fn="语音上传失败",Hn="语音大小大于20M，无法发送",Bn="视频上传失败",Vn="视频大小超过100M，无法发送",Kn="只允许上传 mp4 格式的视频",jn="文件上传失败",$n="请先选择一个文件",Yn="文件大小超过100M，无法发送 ",zn="缺少必要的参数文件 URL",Wn="没有找到相应的会话，请检查传入参数",Xn="没有找到相应的用户或群组，请检查传入参数",Jn="未记录的会话类型",Qn="非法的群类型，请检查传入参数",Zn="不能加入 Private 类型的群组",er="AVChatRoom 类型的群组不能转让群主",tr="不能把群主转让给自己",nr="不能解散 Private 类型的群组",rr="加群失败，请检查传入参数或重试",or="AVChatRoom 类型的群不支持邀请群成员",ir="非 AVChatRoom 类型的群组不允许匿名加群，请先登录后再加群",sr="不能在 AVChatRoom 类型的群组踢人",ar="你不是群主，只有群主才有权限操作",ur="不能在 Private / AVChatRoom 类型的群中设置群成员身份",cr="不合法的群成员身份，请检查传入参数",lr="不能设置自己的群成员身份，请检查传入参数",pr="不能将自己禁言，请检查传入参数",hr="传入 deleteFriend 接口的参数无效",fr="传入 updateMyProfile 接口的参数无效",dr="updateMyProfile 无标配资料字段或自定义资料字段",gr="传入 addToBlacklist 接口的参数无效",mr="传入 removeFromBlacklist 接口的参数无效",yr="不能拉黑自己",vr="网络层初始化错误，缺少 URL 参数",_r="打包错误，未定义的 serverName",Cr="未定义的 packageConfig",Ir="未连接到网络",Mr="不规范的参数名称",Sr="意料外的通知条件",Dr="_syncOffset 丢失",Tr="获取 longpolling id 失败",Er="接口需要 SDK 处于 ready 状态后才能调用",kr=["jpg","jpeg","gif","png"],wr=["mp4"],Ar=function(){function e(n){r(this,e);var o=this._check(n);if(o instanceof pt)throw o;this.type=t.MSG_FILE,this._percent=0;var i=this._getFileInfo(n);this.content={downloadFlag:2,fileUrl:n.url||"",uuid:n.uuid,fileName:i.name||"",fileSize:i.size||0}}return i(e,[{key:"_getFileInfo",value:function(e){if(e.fileName&&e.fileSize)return{size:e.fileSize,name:e.fileName};if(O)return{};var t=e.file.files[0];return{size:t.size,name:t.name,type:t.type.slice(t.type.lastIndexOf("/")+1).toLowerCase()}}},{key:"updatePercent",value:function(e){this._percent=e,this._percent>1&&(this._percent=1)}},{key:"updateFileUrl",value:function(e){this.content.fileUrl=e}},{key:"_check",value:function(e){if(e.size>104857600)return new pt({code:Gt,message:"".concat(Yn,": ").concat(104857600," bytes")})}},{key:"sendable",value:function(){return""!==this.content.fileUrl&&(""!==this.content.fileName&&0!==this.content.fileSize)}}]),e}(),Rr=function(){function e(n){r(this,e),this.type=t.MSG_CUSTOM,this.content={data:n.data||"",description:n.description||"",extension:n.extension||""}}return i(e,[{key:"setData",value:function(e){return this.content.data=e,this}},{key:"setDescription",value:function(e){return this.content.description=e,this}},{key:"setExtension",value:function(e){return this.content.extension=e,this}},{key:"sendable",value:function(){return 0!==this.content.data.length||0!==this.content.description.length||0!==this.content.extension.length}}]),e}(),Or=function(){function e(n){r(this,e),this.type=t.MSG_VIDEO,this._percent=0,this.content={remoteVideoUrl:n.remoteVideoUrl,videoFormat:n.videoFormat,videoSecond:parseInt(n.videoSecond,10),videoSize:n.videoSize,videoUrl:n.videoUrl,videoDownloadFlag:2,videoUUID:n.videoUUID,thumbUUID:n.thumbUUID,thumbFormat:n.thumbFormat,thumbWidth:n.thumbWidth,thumbHeight:n.thumbHeight,thumbSize:n.thumbSize,thumbDownloadFlag:2,thumbUrl:n.thumbUrl}}return i(e,[{key:"updatePercent",value:function(e){this._percent=e,this._percent>1&&(this._percent=1)}},{key:"updateVideoUrl",value:function(e){e&&(this.content.remoteVideoUrl=e)}},{key:"sendable",value:function(){return""!==this.content.remoteVideoUrl}}]),e}(),Lr=function e(n){r(this,e),this.type=t.MSG_GEO,this.content=n},Nr={1:t.MSG_PRIORITY_HIGH,2:t.MSG_PRIORITY_NORMAL,3:t.MSG_PRIORITY_LOW,4:t.MSG_PRIORITY_LOWEST},br=function(){function e(n){r(this,e),this.ID="",this.conversationID=n.conversationID||null,this.conversationType=n.conversationType||t.CONV_C2C,this.conversationSubType=n.conversationSubType,this.time=n.time||Math.ceil(Date.now()/1e3),this.sequence=n.sequence||0,this.clientSequence=n.clientSequence||n.sequence||0,this.random=n.random||me(),this.priority=this._computePriority(n.priority),this.nick="",this.avatar="",this._elements=[],this.isPlaceMessage=n.isPlaceMessage||0,this.isRevoked=2===n.isPlaceMessage||8===n.msgFlagBits,this.geo={},this.from=n.from||null,this.to=n.to||null,this.flow="",this.isSystemMessage=n.isSystemMessage||!1,this.protocol=n.protocol||"JSON",this.isResend=!1,this.isRead=!1,this.status=n.status||Pe.SUCCESS,this.reInitialize(n.currentUser),this.extractGroupInfo(n.groupProfile||null)}return i(e,[{key:"getElements",value:function(){return this._elements}},{key:"extractGroupInfo",value:function(e){null!==e&&(ee(e.fromAccountNick)&&(this.nick=e.fromAccountNick),ee(e.fromAccountHeadurl)&&(this.avatar=e.fromAccountHeadurl))}},{key:"_initProxy",value:function(){this.payload=this._elements[0].content,this.type=this._elements[0].type}},{key:"reInitialize",value:function(e){e&&(this.status=this.from?Pe.SUCCESS:Pe.UNSEND,!this.from&&(this.from=e)),this._initFlow(e),this._initielizeSequence(e),this._concactConversationID(e),this.generateMessageID(e)}},{key:"isSendable",value:function(){return 0!==this._elements.length&&("function"!=typeof this._elements[0].sendable?(J.warn("".concat(this._elements[0].type,' need "boolean : sendable()" method')),!1):this._elements[0].sendable())}},{key:"_initTo",value:function(e){this.conversationType===t.CONV_GROUP&&(this.to=e.groupID)}},{key:"_initielizeSequence",value:function(e){0===this.clientSequence&&e&&(this.clientSequence=function(e){if(!e)return J.error("autoincrementIndex(string: key) need key parameter"),!1;if(void 0===Ce[e]){var t=new Date,n="3".concat(t.getHours()).slice(-2),r="0".concat(t.getMinutes()).slice(-2),o="0".concat(t.getSeconds()).slice(-2);Ce[e]=parseInt([n,r,o,"0001"].join("")),n=null,r=null,o=null,J.warn("utils.autoincrementIndex() create new sequence : ".concat(e," = ").concat(Ce[e]))}return Ce[e]++}(e)),0===this.sequence&&this.conversationType===t.CONV_C2C&&(this.sequence=this.clientSequence)}},{key:"generateMessageID",value:function(e){var t=e===this.from?1:0,n=this.sequence>0?this.sequence:this.clientSequence;this.ID="".concat(this.conversationID,"-").concat(n,"-").concat(this.random,"-").concat(t)}},{key:"_initFlow",value:function(e){""!==e&&(e===this.from?(this.flow="out",this.isRead=!0):this.flow="in")}},{key:"_concactConversationID",value:function(e){var n=this.to,r="",o=this.conversationType;o!==t.CONV_SYSTEM?(r=o===t.CONV_C2C?e===this.from?n:this.from:this.to,this.conversationID="".concat(o).concat(r)):this.conversationID=t.CONV_SYSTEM}},{key:"isElement",value:function(e){return e instanceof Ue||e instanceof rt||e instanceof ot||e instanceof it||e instanceof Ar||e instanceof Or||e instanceof at||e instanceof ct||e instanceof Rr||e instanceof Lr}},{key:"setElement",value:function(e){var n=this;if(this.isElement(e))return this._elements=[e],void this._initProxy();var r=function(e){switch(e.type){case t.MSG_TEXT:n.setTextElement(e.content);break;case t.MSG_IMAGE:n.setImageElement(e.content);break;case t.MSG_AUDIO:n.setAudioElement(e.content);break;case t.MSG_FILE:n.setFileElement(e.content);break;case t.MSG_VIDEO:n.setVideoElement(e.content);break;case t.MSG_CUSTOM:n.setCustomElement(e.content);break;case t.MSG_GEO:n.setGEOElement(e.content);break;case t.MSG_GRP_TIP:n.setGroupTipElement(e.content);break;case t.MSG_GRP_SYS_NOTICE:n.setGroupSystemNoticeElement(e.content);break;case t.MSG_FACE:n.setFaceElement(e.content);break;default:J.warn(e.type,e.content,"no operation......")}};if(Array.isArray(e))for(var o=0;o<e.length;o++)r(e[o]);else r(e);this._initProxy()}},{key:"setTextElement",value:function(e){var t="string"==typeof e?e:e.text,n=new Ue({text:t});this._elements.push(n)}},{key:"setImageElement",value:function(e){var t=new rt(e);this._elements.push(t)}},{key:"setAudioElement",value:function(e){var t=new it(e);this._elements.push(t)}},{key:"setFileElement",value:function(e){var t=new Ar(e);this._elements.push(t)}},{key:"setVideoElement",value:function(e){var t=new Or(e);this._elements.push(t)}},{key:"setGEOElement",value:function(e){var t=new Lr(e);this._elements.push(t)}},{key:"setCustomElement",value:function(e){var t=new Rr(e);this._elements.push(t)}},{key:"setGroupTipElement",value:function(e){if(e.operatorInfo){var t=e.operatorInfo,n=t.nick,r=t.avatar;ee(n)&&(this.nick=n),ee(r)&&(this.avatar=r)}var o=new at(e);this._elements.push(o)}},{key:"setGroupSystemNoticeElement",value:function(e){var t=new ct(e);this._elements.push(t)}},{key:"setFaceElement",value:function(e){var t=new ot(e);this._elements.push(t)}},{key:"setIsRead",value:function(e){this.isRead=e}},{key:"_computePriority",value:function(e){if(oe(e))return t.MSG_PRIORITY_NORMAL;if(ee(e)&&-1!==Object.values(Nr).indexOf(e))return e;if(Z(e)){var n=""+e;if(-1!==Object.keys(Nr).indexOf(n))return Nr[n]}return t.MSG_PRIORITY_NORMAL}},{key:"elements",get:function(){return J.warn("！！！Message 实例的 elements 属性即将废弃，请尽快修改。使用 type 和 payload 属性处理单条消息，兼容组合消息使用 _elements 属性！！！"),this._elements}}]),e}(),Pr=function(e){return!!e&&(!!(function(e){return ee(e)&&e.slice(0,3)===t.CONV_C2C}(e)||function(e){return ee(e)&&e.slice(0,5)===t.CONV_GROUP}(e)||Ee(e))||(console.warn("非法的会话 ID:".concat(e,"。会话 ID 组成方式：\n  C2C + userID（单聊）\n  GROUP + groupID（群聊）\n  @TIM#SYSTEM（系统通知会话）")),!1))},Gr={login:{userID:{type:"String",required:!0},userSig:{type:"String",required:!0}},addToBlacklist:{userIDList:{type:"Array",required:!0}},mutilParam:[{name:"paramName",type:"Number",required:!0},{name:"paramName",type:"String",required:!0}],on:[{name:"eventName",type:"String",validator:function(e){return"string"==typeof e&&0!==e.length||(console.warn("on 接口的 eventName 参数必须是 String 类型，且不能为空。"),!1)}},{name:"handler",type:"Function",validator:function(e){return"function"!=typeof e?(console.warn("on 接口的 handler 参数必须是 Function 类型。"),!1):(""===e.name&&console.warn("on 接口的 handler 参数推荐使用具名函数。具名函数可以使用 off 接口取消订阅，匿名函数无法取消订阅。"),!0)}}],once:[{name:"eventName",type:"String",validator:function(e){return"string"==typeof e&&0!==e.length||(console.warn("once 接口的 eventName 参数必须是 String 类型，且不能为空。"),!1)}},{name:"handler",type:"Function",validator:function(e){return"function"!=typeof e?(console.warn("once 接口的 handler 参数必须是 Function 类型。"),!1):(""===e.name&&console.warn("once 接口的 handler 参数推荐使用具名函数。"),!0)}}],off:[{name:"eventName",type:"String",validator:function(e){return"string"==typeof e&&0!==e.length||(console.warn("off 接口的 eventName 参数必须是 String 类型，且不能为空。"),!1)}},{name:"handler",type:"Function",validator:function(e){return"function"!=typeof e?(console.warn("off 接口的 handler 参数必须是 Function 类型。"),!1):(""===e.name&&console.warn("off 接口的 handler 参数为匿名函数，无法取消订阅。"),!0)}}],sendMessage:[{name:"message",type:"Object",required:!0}],getMessageList:{conversationID:{type:"String",required:!0,validator:function(e){return Pr(e)}},nextReqMessageID:{type:"String"},count:{type:"Number",validator:function(e){return!(!oe(e)&&!/^[1-9][0-9]*$/.test(e))||(console.warn("getMessageList 接口的 count 参数必须为正整数"),!1)}}},setMessageRead:{conversationID:{type:"String",required:!0,validator:function(e){return Pr(e)}}},getConversationProfile:[{name:"conversationID",type:"String",required:!0,validator:function(e){return Pr(e)}}],deleteConversation:[{name:"conversationID",type:"String",required:!0,validator:function(e){return Pr(e)}}],getGroupList:{groupProfileFilter:{type:"Array"}},getGroupProfile:{groupID:{type:"String",required:!0},groupCustomFieldFilter:{type:"Array"},memberCustomFieldFilter:{type:"Array"}},getGroupProfileAdvance:{groupIDList:{type:"Array",required:!0}},createGroup:{name:{type:"String",required:!0}},joinGroup:{groupID:{type:"String",required:!0},type:{type:"String"},applyMessage:{type:"String"}},quitGroup:[{name:"groupID",type:"String",required:!0}],handleApplication:{message:{type:"Object",required:!0},handleAction:{type:"String",required:!0},handleMessage:{type:"String"}},changeGroupOwner:{groupID:{type:"String",required:!0},newOwnerID:{type:"String",required:!0}},updateGroupProfile:{groupID:{type:"String",required:!0}},dismissGroup:[{name:"groupID",type:"String",required:!0}],searchGroupByID:[{name:"groupID",type:"String",required:!0}],getGroupMemberList:{groupID:{type:"String",required:!0},offset:{type:"Number"},count:{type:"Number"}},getGroupMemberProfile:{groupID:{type:"String",required:!0},userIDList:{type:"Array",required:!0},memberCustomFieldFilter:{type:"Array"}},addGroupMemeber:{groupID:{type:"String",required:!0},userIDList:{type:"Array",required:!0}},setGroupMemberRole:{groupID:{type:"String",required:!0},userID:{type:"String",required:!0},role:{type:"String",required:!0}},setGroupMemberMuteTime:{groupID:{type:"String",required:!0},userID:{type:"String",required:!0},muteTime:{type:"Number",validator:function(e){return e>=0}}},setGroupMemberNameCard:{groupID:{type:"String",required:!0},userID:{type:"String"},nameCard:{type:"String",required:!0,validator:function(e){return!0!==/^\s+$/.test(e)}}},setMessageRemindType:{groupID:{type:"String",required:!0},messageRemindType:{type:"String",required:!0}},setGroupMemberCustomField:{groupID:{type:"String",required:!0},userID:{type:"String"},memberCustomField:{type:"Array",required:!0}},deleteGroupMember:{groupID:{type:"String",required:!0}},createTextMessage:{to:{type:"String",required:!0},conversationType:{type:"String",required:!0},payload:{type:"Object",required:!0,validator:function(e){return ee(e.text)?0!==e.text.length||(console.warn("createTextMessage 消息内容不能为空。请参考 https://imsdk-1252463788.file.myqcloud.com/IM_DOC/Web/SDK.html#createTextMessage"),!1):(console.warn("createTextMessage payload.text 类型必须为字符串。请参考 https://imsdk-1252463788.file.myqcloud.com/IM_DOC/Web/SDK.html#createTextMessage"),!1)}}},createCustomMessage:{to:{type:"String",required:!0},conversationType:{type:"String",required:!0},payload:{type:"Object",required:!0}},createImageMessage:{to:{type:"String",required:!0},conversationType:{type:"String",required:!0},payload:{type:"Object",required:!0,validator:function(e){if(oe(e.file))return console.warn("createImageMessage payload.file 不能为 undefined。请参考 https://imsdk-1252463788.file.myqcloud.com/IM_DOC/Web/SDK.html#createImageMessage"),!1;if(R){if(!(e.file instanceof HTMLInputElement||Q(e.file)))return console.warn("createImageMessage payload.file 的类型必须是 HTMLInputElement 或 File。请参考 https://imsdk-1252463788.file.myqcloud.com/IM_DOC/Web/SDK.html#createImageMessage"),!1;if(e.file instanceof HTMLInputElement&&0===e.file.files.length)return console.warn("createImageMessage 您没有选择文件，无法发送。请参考 https://imsdk-1252463788.file.myqcloud.com/IM_DOC/Web/SDK.html#createImageMessage"),!1}return!0},onProgress:{type:"Function",required:!1,validator:function(e){return oe(e)&&console.warn("createImageMessage 没有 onProgress 回调，您将无法获取图片上传进度。请参考 https://imsdk-1252463788.file.myqcloud.com/IM_DOC/Web/SDK.html#createImageMessage"),!0}}}},createAudioMessage:{to:{type:"String",required:!0},conversationType:{type:"String",required:!0},payload:{type:"Object",required:!0},onProgress:{type:"Function",required:!1,validator:function(e){return oe(e)&&console.warn("createAudioMessage 没有 onProgress 回调，您将无法获取音频上传进度。请参考 https://imsdk-1252463788.file.myqcloud.com/IM_DOC/Web/SDK.html#createAudioMessage"),!0}}},createVideoMessage:{to:{type:"String",required:!0},conversationType:{type:"String",required:!0},payload:{type:"Object",required:!0,validator:function(e){if(oe(e.file))return console.warn("createVideoMessage payload.file 不能为 undefined。请参考 https://imsdk-1252463788.file.myqcloud.com/IM_DOC/Web/SDK.html#createVideoMessage"),!1;if(R){if(!(e.file instanceof HTMLInputElement||Q(e.file)))return console.warn("createVideoMessage payload.file 的类型必须是 HTMLInputElement 或 File。请参考 https://imsdk-1252463788.file.myqcloud.com/IM_DOC/Web/SDK.html#createVideoMessage"),!1;if(e.file instanceof HTMLInputElement&&0===e.file.files.length)return console.warn("createVideoMessage 您没有选择文件，无法发送。请参考 https://imsdk-1252463788.file.myqcloud.com/IM_DOC/Web/SDK.html#createVideoMessage"),!1}return!0}},onProgress:{type:"Function",required:!1,validator:function(e){return oe(e)&&console.warn("createVideoMessage 没有 onProgress 回调，您将无法获取视频上传进度。请参考 https://imsdk-1252463788.file.myqcloud.com/IM_DOC/Web/SDK.html#createVideoMessage"),!0}}},createFaceMessage:{to:{type:"String",required:!0},conversationType:{type:"String",required:!0},payload:{type:"Object",required:!0,validator:function(e){return!!ne(e)&&(Z(e.index)?!!ee(e.data)||(console.warn("createFaceMessage payload.data 类型必须为 String！"),!1):(console.warn("createFaceMessage payload.index 类型必须为 Number！"),!1))}}},createFileMessage:{to:{type:"String",required:!0},conversationType:{type:"String",required:!0},payload:{type:"Object",required:!0,validator:function(e){if(oe(e.file))return console.warn("createFileMessage payload.file 不能为 undefined。请参考 https://imsdk-1252463788.file.myqcloud.com/IM_DOC/Web/SDK.html#createFileMessage"),!1;if(R){if(!(e.file instanceof HTMLInputElement||Q(e.file)))return console.warn("createFileMessage payload.file 的类型必须是 HTMLInputElement 或 File。请参考 https://imsdk-1252463788.file.myqcloud.com/IM_DOC/Web/SDK.html#createFileMessage"),!1;if(e.file instanceof HTMLInputElement&&0===e.file.files.length)return console.warn("createFileMessage 您没有选择文件，无法发送。请参考 https://imsdk-1252463788.file.myqcloud.com/IM_DOC/Web/SDK.html#createFileMessage"),!1}return!0}},onProgress:{type:"Function",required:!1,validator:function(e){return oe(e)&&console.warn("createFileMessage 没有 onProgress 回调，您将无法获取文件上传进度。请参考 https://imsdk-1252463788.file.myqcloud.com/IM_DOC/Web/SDK.html#createFileMessage"),!0}}},revokeMessage:[{name:"message",type:"Object",required:!0,validator:function(e){return e instanceof br?e.conversationType===t.CONV_SYSTEM?(console.warn("revokeMessage 不能撤回系统会话消息，只能撤回单聊消息或群消息"),!1):!0!==e.isRevoked||(console.warn("revokeMessage 消息已经被撤回，请勿重复操作"),!1):(console.warn("revokeMessage 参数 message 必须为 Message(https://imsdk-1252463788.file.myqcloud.com/IM_DOC/Web/Message.html) 实例。"),!1)}}],getUserProfile:{userIDList:{type:"Array",validator:function(e){return re(e)?(0===e.length&&console.warn("getUserProfile userIDList 不能为空数组，请参考 https://imsdk-1252463788.file.myqcloud.com/IM_DOC/Web/SDK.html#getUserProfile"),!0):(console.warn("getUserProfile userIDList 必须为数组，请参考 https://imsdk-1252463788.file.myqcloud.com/IM_DOC/Web/SDK.html#getUserProfile"),!1)}}},updateMyProfile:{profileCustomField:{type:"Array",validator:function(e){return!!oe(e)||(!!re(e)||(console.warn("updateMyProfile profileCustomField 必须为数组，请参考 https://imsdk-1252463788.file.myqcloud.com/IM_DOC/Web/SDK.html#updateMyProfile"),!1))}}}},Ur={login:"login",logout:"logout",on:"on",once:"once",off:"off",setLogLevel:"setLogLevel",downloadLog:"downloadLog",registerPlugin:"registerPlugin",destroy:"destroy",createTextMessage:"createTextMessage",createImageMessage:"createImageMessage",createAudioMessage:"createAudioMessage",createVideoMessage:"createVideoMessage",createCustomMessage:"createCustomMessage",createFaceMessage:"createFaceMessage",createFileMessage:"createFileMessage",sendMessage:"sendMessage",resendMessage:"resendMessage",getMessageList:"getMessageList",setMessageRead:"setMessageRead",revokeMessage:"revokeMessage",getConversationList:"getConversationList",getConversationProfile:"getConversationProfile",deleteConversation:"deleteConversation",getGroupList:"getGroupList",getGroupProfile:"getGroupProfile",createGroup:"createGroup",joinGroup:"joinGroup",updateGroupProfile:"updateGroupProfile",quitGroup:"quitGroup",dismissGroup:"dismissGroup",changeGroupOwner:"changeGroupOwner",searchGroupByID:"searchGroupByID",setMessageRemindType:"setMessageRemindType",handleGroupApplication:"handleGroupApplication",getGroupMemberProfile:"getGroupMemberProfile",getGroupMemberList:"getGroupMemberList",addGroupMember:"addGroupMember",deleteGroupMember:"deleteGroupMember",setGroupMemberNameCard:"setGroupMemberNameCard",setGroupMemberMuteTime:"setGroupMemberMuteTime",setGroupMemberRole:"setGroupMemberRole",setGroupMemberCustomField:"setGroupMemberCustomField",getMyProfile:"getMyProfile",getUserProfile:"getUserProfile",updateMyProfile:"updateMyProfile",getBlacklist:"getBlacklist",addToBlacklist:"addToBlacklist",removeFromBlacklist:"removeFromBlacklist",getFriendList:"getFriendList"},qr="1.7.3",xr="537048168",Fr="10",Hr="protobuf",Br="json",Vr={HOST:{TYPE:3,ACCESS_LAYER_TYPES:{SANDBOX:1,TEST:2,PRODUCTION:3},CURRENT:{COMMON:"https://webim.tim.qq.com",PIC:"https://pic.tim.qq.com",COS:"https://yun.tim.qq.com"},PRODUCTION:{COMMON:"https://webim.tim.qq.com",PIC:"https://pic.tim.qq.com",COS:"https://yun.tim.qq.com"},SANDBOX:{COMMON:"https://events.tim.qq.com",PIC:"https://pic.tim.qq.com",COS:"https://yun.tim.qq.com"},TEST:{COMMON:"https://test.tim.qq.com",PIC:"https://pic.tim.qq.com",COS:"https://test.tim.qq.com"},setCurrent:function(){var e=arguments.length>0&&void 0!==arguments[0]?arguments[0]:3;switch(e){case this.ACCESS_LAYER_TYPES.SANDBOX:this.CURRENT=this.SANDBOX,this.TYPE=this.ACCESS_LAYER_TYPES.SANDBOX;break;case this.ACCESS_LAYER_TYPES.TEST:this.CURRENT=this.TEST,this.TYPE=this.ACCESS_LAYER_TYPES.TEST;break;default:this.CURRENT=this.PRODUCTION,this.TYPE=this.ACCESS_LAYER_TYPES.PRODUCTION}}},NAME:{OPEN_IM:"openim",GROUP:"group_open_http_svc",FRIEND:"sns",PROFILE:"profile",RECENT_CONTACT:"recentcontact",PIC:"openpic",BIG_GROUP_NO_AUTH:"group_open_http_noauth_svc",BIG_GROUP_LONG_POLLING_NO_AUTH:"group_open_long_polling_http_noauth_svc",IM_OPEN_STAT:"imopenstat",WEB_IM:"webim",IM_COS_SIGN:"im_cos_sign_svr"},CMD:{ACCESS_LAYER:"accesslayer",LOGIN:"login",LOGOUT_LONG_POLL:"longpollinglogout",LOGOUT_ALL:"logout",PORTRAIT_GET:"portrait_get_all",PORTRAIT_SET:"portrait_set",GET_LONG_POLL_ID:"getlongpollingid",LONG_POLL:"longpolling",AVCHATROOM_LONG_POLL:"get_msg",FRIEND_ADD:"friend_add",FRIEND_GET_ALL:"friend_get_all",FRIEND_DELETE:"friend_delete",RESPONSE_PENDENCY:"friend_response",GET_PENDENCY:"pendency_get",DELETE_PENDENCY:"pendency_delete",GET_GROUP_PENDENCY:"get_pendency",GET_BLACKLIST:"black_list_get",ADD_BLACKLIST:"black_list_add",DELETE_BLACKLIST:"black_list_delete",CREATE_GROUP:"create_group",GET_JOINED_GROUPS:"get_joined_group_list",SEND_MESSAGE:"sendmsg",REVOKE_C2C_MESSAGE:"msgwithdraw",SEND_GROUP_MESSAGE:"send_group_msg",REVOKE_GROUP_MESSAGE:"group_msg_recall",GET_GROUP_INFO:"get_group_info",GET_GROUP_MEMBER_INFO:"get_specified_group_member_info",GET_GROUP_MEMBER_LIST:"get_group_member_info",QUIT_GROUP:"quit_group",CHANGE_GROUP_OWNER:"change_group_owner",DESTROY_GROUP:"destroy_group",ADD_GROUP_MEMBER:"add_group_member",DELETE_GROUP_MEMBER:"delete_group_member",SEARCH_GROUP_BY_ID:"get_group_public_info",APPLY_JOIN_GROUP:"apply_join_group",HANDLE_APPLY_JOIN_GROUP:"handle_apply_join_group",MODIFY_GROUP_INFO:"modify_group_base_info",MODIFY_GROUP_MEMBER_INFO:"modify_group_member_info",DELETE_GROUP_SYSTEM_MESSAGE:"deletemsg",GET_CONVERSATION_LIST:"get",PAGING_GET_CONVERSATION_LIST:"page_get",DELETE_CONVERSATION:"delete",GET_MESSAGES:"getmsg",GET_C2C_ROAM_MESSAGES:"getroammsg",GET_GROUP_ROAM_MESSAGES:"group_msg_get",SET_C2C_MESSAGE_READ:"msgreaded",SET_GROUP_MESSAGE_READ:"msg_read_report",FILE_READ_AND_WRITE_AUTHKEY:"authkey",FILE_UPLOAD:"pic_up",COS_SIGN:"cos",TIM_WEB_REPORT:"tim_web_report",BIG_DATA_HALLWAY_AUTH_KEY:"authkey"},CHANNEL:{SOCKET:1,XHR:2,AUTO:0},NAME_VERSION:{openim:"v4",group_open_http_svc:"v4",sns:"v4",profile:"v4",recentcontact:"v4",openpic:"v4",group_open_http_noauth_svc:"v1",group_open_long_polling_http_noauth_svc:"v1",imopenstat:"v4",im_cos_sign_svr:"v4",webim:"v4"}};Vr.HOST.setCurrent(Vr.HOST.ACCESS_LAYER_TYPES.PRODUCTION);var Kr={request:{toAccount:"To_Account",fromAccount:"From_Account",to:"To_Account",from:"From_Account",groupID:"GroupId",avatar:"FaceUrl"},response:{GroupId:"groupID",Member_Account:"userID",MsgList:"messageList",SyncFlag:"syncFlag",To_Account:"to",From_Account:"from",MsgSeq:"sequence",MsgRandom:"random",MsgTimeStamp:"time",MsgContent:"content",MsgBody:"elements",GroupWithdrawInfoArray:"revokedInfos",WithdrawC2cMsgNotify:"c2cMessageRevokedNotify",C2cWithdrawInfoArray:"revokedInfos",MsgRand:"random",MsgType:"type",MsgShow:"messageShow",NextMsgSeq:"nextMessageSeq",FaceUrl:"avatar",ProfileDataMod:"profileModify",Profile_Account:"userID",ValueBytes:"value",ValueNum:"value",NoticeSeq:"noticeSequence",NotifySeq:"notifySequence",MsgFrom_AccountExtraInfo:"messageFromAccountExtraInformation",Operator_Account:"operatorID",OpType:"operationType",ReportType:"operationType",UserId:"userID",User_Account:"userID",List_Account:"userIDList",MsgOperatorMemberExtraInfo:"operatorInfo",MsgMemberExtraInfo:"memberInfoList",ImageUrl:"avatar",NickName:"nick",MsgGroupNewInfo:"newGroupProfile",MsgAppDefinedData:"groupCustomField",Owner_Account:"ownerID",GroupName:"name",GroupFaceUrl:"avatar",GroupIntroduction:"introduction",GroupNotification:"notification",GroupApplyJoinOption:"joinOption",MsgKey:"messageKey",GroupInfo:"groupProfile",ShutupTime:"muteTime",Desc:"description",Ext:"extension"},ignoreKeyWord:["C2C","ID","USP"]},jr="_contextWasUpdated",$r="_contextWasReset",Yr="_a2KeyAndTinyIDUpdated",zr="_specifiedConfigUpdated",Wr="_noticeIsSynchronizing",Xr="_noticeIsSynchronized",Jr="_messageSent",Qr="_syncMessageProcessing",Zr="_syncMessageFinished",eo="_receiveInstantMessage",to="_receiveGroupInstantMessage",no="_receveGroupSystemNotice",ro="_messageRevoked",oo="_longPollGetIDFailed",io="_longPollRequestFailed",so="_longPollResponseOK",ao="_longPollFastStart",uo="_longPollSlowStart",co="_longPollKickedOut",lo="_longPollMitipuleDeviceKickedOut",po="_longPollGetNewC2CNotice",ho="_longPollGetNewGroupMessages",fo="_longPollGetNewGroupTips",go="_longPollGetNewGroupNotice",mo="_longPollGetNewFriendMessages",yo="_longPollProfileModified",vo="_longPollNoticeReceiveSystemOrders",_o=" _longpollGroupMessageRevoked",Co="_longpollC2CMessageRevoked",Io="_avlongPollRequestFailed",Mo="_avlongPollResponseOK",So="_onGroupListUpdated",Do="_loginSuccess",To="_signLogoutExcuting",Eo="_logoutSuccess",ko="_a2keyExpired",wo="_errorHasBeenDetected",Ao="_onConversationListUpdated",Ro="_onConversationListProfileUpdated",Oo="_conversationDeleted",Lo="onProfileUpdated",No="joinAVChatRoomSuccess",bo="joinAVChatRoomSuccessNoAuth",Po="_sdkStateReady";function Go(e,t){if("string"!=typeof e&&!Array.isArray(e))throw new TypeError("Expected the input to be `string | string[]`");t=Object.assign({pascalCase:!1},t);var n;return 0===(e=Array.isArray(e)?e.map((function(e){return e.trim()})).filter((function(e){return e.length})).join("-"):e.trim()).length?"":1===e.length?t.pascalCase?e.toUpperCase():e.toLowerCase():(e!==e.toLowerCase()&&(e=Uo(e)),e=e.replace(/^[_.\- ]+/,"").toLowerCase().replace(/[_.\- ]+(\w|$)/g,(function(e,t){return t.toUpperCase()})).replace(/\d+(\w|$)/g,(function(e){return e.toUpperCase()})),n=e,t.pascalCase?n.charAt(0).toUpperCase()+n.slice(1):n)}var Uo=function(e){for(var t=!1,n=!1,r=!1,o=0;o<e.length;o++){var i=e[o];t&&/[a-zA-Z]/.test(i)&&i.toUpperCase()===i?(e=e.slice(0,o)+"-"+e.slice(o),t=!1,r=n,n=!0,o++):n&&r&&/[a-zA-Z]/.test(i)&&i.toLowerCase()===i?(e=e.slice(0,o-1)+"-"+e.slice(o-1),r=n,n=!1,t=!0):(t=i.toLowerCase()===i&&i.toUpperCase()!==i,r=n,n=i.toUpperCase()===i&&i.toLowerCase()!==i)}return e};function qo(e,t,n){var r=[],o=0,i=function e(t,n){if(++o>10)return o--,t;if(re(t)){var i=t.map((function(t){return te(t)?e(t,n):t}));return o--,i}if(te(t)){var s=(a=t,u=function(e,t){if(!ce(t))return!1;if((s=t)!==Go(s)){for(var o=!0,i=0;i<Kr.ignoreKeyWord.length;i++)if(t.includes(Kr.ignoreKeyWord[i])){o=!1;break}o&&r.push(t)}var s;return oe(n[t])?function(e){return e[0].toUpperCase()+Go(e).slice(1)}(t):n[t]},c=Object.create(null),Object.keys(a).forEach((function(e){var t=u(a[e],e);t&&(c[t]=a[e])})),c);return s=ke(s,(function(t,r){return re(t)||te(t)?e(t,n):t})),o--,s}var a,u,c}(e,t=u({},Kr.request,{},t));return r.length>0&&n.innerEmitter.emit(wo,{code:dn,message:Mr}),i}function xo(e,t){if(t=u({},Kr.response,{},t),re(e))return e.map((function(e){return te(e)?xo(e,t):e}));if(te(e)){var n=(r=e,o=function(e,n){return oe(t[n])?Go(n):t[n]},i={},Object.keys(r).forEach((function(e){i[o(r[e],e)]=r[e]})),i);return n=ke(n,(function(e){return re(e)||te(e)?xo(e,t):e}))}var r,o,i}var Fo=function(){function e(t){var n=this;r(this,e),this.url="",this.requestData=null,this.method=t.method||"POST",this.callback=function(e){return xo(e=t.decode(e),n._getResponseMap(t))},this._initializeServerMap(),this._initializeURL(t),this._initializeRequestData(t)}return i(e,[{key:"_initializeServerMap",value:function(){this._serverMap=Object.create(null);var e="";for(var t in Vr.NAME)if(Object.prototype.hasOwnProperty.call(Vr.NAME,t))switch(e=Vr.NAME[t]){case Vr.NAME.PIC:this._serverMap[e]=Vr.HOST.CURRENT.PIC;break;case Vr.NAME.IM_COS_SIGN:this._serverMap[e]=Vr.HOST.CURRENT.COS;break;default:this._serverMap[e]=Vr.HOST.CURRENT.COMMON}}},{key:"_getHost",value:function(e){if(void 0!==this._serverMap[e])return this._serverMap[e];throw new pt({code:pn,message:_r})}},{key:"_initializeURL",value:function(e){var t=e.serverName,n=e.cmd,r=this._getHost(t),o="".concat(r,"/").concat(Vr.NAME_VERSION[t],"/").concat(t,"/").concat(n);o+="?".concat(this._getQueryString(e.queryString)),this.url=o}},{key:"getUrl",value:function(){return this.url.replace(/&reqtime=(\d+)/,"&reqtime=".concat(Math.ceil(+new Date/1e3)))}},{key:"_initializeRequestData",value:function(e){var t,n=e.requestData;t=this._requestDataCleaner(n),this.requestData=e.encode(t)}},{key:"_requestDataCleaner",value:function(e){var t=Array.isArray(e)?[]:Object.create(null);for(var r in e)Object.prototype.hasOwnProperty.call(e,r)&&ce(r)&&null!==e[r]&&("object"!==n(e[r])?t[r]=e[r]:t[r]=this._requestDataCleaner.bind(this)(e[r]));return t}},{key:"_getQueryString",value:function(e){var t=[];for(var n in e)Object.prototype.hasOwnProperty.call(e,n)&&("function"!=typeof e[n]?t.push("".concat(n,"=").concat(e[n])):t.push("".concat(n,"=").concat(e[n]())));return t.join("&")}},{key:"_getResponseMap",value:function(e){if(e.keyMaps&&e.keyMaps.response&&Object.keys(e.keyMaps.response).length>0)return e.keyMaps.response}}]),e}();function Ho(e){this.mixin(e)}Ho.mixin=function(e){var t=e.prototype||e;t._isReady=!1,t.ready=function(e){var t=arguments.length>1&&void 0!==arguments[1]&&arguments[1];if(e)return this._isReady?void(t?e.call(this):setTimeout(e,1)):(this._readyQueue=this._readyQueue||[],void this._readyQueue.push(e))},t.triggerReady=function(){var e=this;this._isReady=!0,setTimeout((function(){var t=e._readyQueue;e._readyQueue=[],t&&t.length>0&&t.forEach((function(e){e.call(this)}),e)}),1)},t.resetReady=function(){this._isReady=!1,this._readyQueue=[]},t.isReady=function(){return this._isReady}};var Bo=function(){function e(t){r(this,e),Ho.mixin(this),this.tim=t}return i(e,[{key:"isLoggedIn",value:function(){return this.tim.context.login===be.IS_LOGIN||!!this.tim.context.a2Key}},{key:"createTransportCapsule",value:function(e){var t=this.tim.packageConfig.get(e);return t?new Fo(t):null}},{key:"request",value:function(e){var t=this.createTransportCapsule(e);return t||J.error("unknown transport capsule, please check!",e),this.tim.connectionController.request(t)}},{key:"emitInnerEvent",value:function(e,t){this.tim.innerEmitter.emit(e,t)}},{key:"emitOuterEvent",value:function(e,t){this.tim.outerEmitter.emit(e,t)}},{key:"reset",value:function(){J.warn(["method: IMController.reset() method must be implemented"].join())}},{key:"probeNetwork",value:function(){return this.tim.netMonitor.probe()}},{key:"getNetworkType",value:function(){return this.tim.netMonitor.getNetworkType()}},{key:"getPlatform",value:function(){var e="web";return B?e="wechat":O&&(e="wxmp"),e}}]),e}(),Vo=function(){function e(t,n){r(this,e),this.data=t,this._innerEmitter=n,this.defaultData={},Object.assign(this.defaultData,t),this.initGetterAndSetter()}return i(e,[{key:"initGetterAndSetter",value:function(){var e=this,t=function(t){Object.defineProperty(e,t,{enumerable:!0,configurable:!0,get:function(){return e.data[t]},set:function(n){e.data[t]!==n&&(e.data[t]=n,e.onChange.bind(e)(t,n))}})};for(var n in e.data)Object.prototype.hasOwnProperty.call(e.data,n)&&t(n)}},{key:"onChange",value:function(e,t){this._innerEmitter.emit(jr,{key:e,value:t})}},{key:"reset",value:function(){for(var e in J.log("Context.reset"),this.data)Object.prototype.hasOwnProperty.call(this.data,e)&&(this.data[e]=this.defaultData.hasOwnProperty(e)?this.defaultData[e]:null)}}]),e}(),Ko=function(e){c(n,e);var t=y(n);function n(e){var o;r(this,n);var i=(o=t.call(this,e)).tim.loginInfo;return o._context=new Vo({login:be.IS_NOT_LOGIN,SDKAppID:i.SDKAppID,appIDAt3rd:null,accountType:i.accountType,identifier:i.identifier,tinyID:null,identifierNick:i.identifierNick,userSig:i.userSig,a2Key:null,contentType:"json",apn:1},o.tim.innerEmitter),o._initListener(),o}return i(n,[{key:"reset",value:function(){this._context.reset(),this.emitInnerEvent($r)}},{key:"_initListener",value:function(){this.tim.innerEmitter.on(jr,this._onContextMemberChange,this),this.tim.innerEmitter.on(Do,this._updateA2KeyAndTinyID,this)}},{key:"_updateA2KeyAndTinyID",value:function(e){var t=e.data,n=t.a2Key,r=t.tinyID;this._context.a2Key=n,this._context.tinyID=r,this.emitInnerEvent(Yr),this.triggerReady()}},{key:"getContext",value:function(){return this._context}},{key:"_onContextMemberChange",value:function(e){var t=e.data,n=t.key,r=t.value;("tinyID"===n||"a2Key"===n)&&(r.length<=0?this._context.login=be.IS_NOT_LOGIN:this._context.login=null!==this._context.a2Key?be.IS_LOGIN:be.IS_NOT_LOGIN)}}]),n}(Bo),jo=function e(t){r(this,e),this.code=0,this.data=t||{}},$o=null,Yo=function(e){$o=e},zo=function(e){return e instanceof jo?(J.warn("IMPromise.resolve 此函数会自动用options创建IMResponse实例，调用侧不需创建，建议修改！"),Promise.resolve(e)):Promise.resolve(new jo(e))},Wo=function(t){var n=arguments.length>1&&void 0!==arguments[1]&&arguments[1];if(t instanceof pt)return n&&null!==$o&&$o.emit(e.ERROR,t),Promise.reject(t);if(t instanceof Error){var r=new pt({code:yn,message:t.message});return n&&null!==$o&&$o.emit(e.ERROR,r),Promise.reject(r)}if(oe(t)||oe(t.code)||oe(t.message))J.error("IMPromise.reject 必须指定code(错误码)和message(错误信息)!!!");else{if(Z(t.code)&&ee(t.message)){var o=new pt(t);return n&&null!==$o&&$o.emit(e.ERROR,o),Promise.reject(o)}J.error("IMPromise.reject code(错误码)必须为数字，message(错误信息)必须为字符串!!!")}},Xo="sdkReady",Jo="login",Qo="longpolling",Zo="longpollingAV",ei="sendMessage",ti="initConversationList",ni="initGroupList",ri="upload",oi=function(){function e(){r(this,e),this.SDKAppID="",this.version="",this.tinyID="",this.userID="",this.platform="",this.method="",this.time="",this.startts=0,this.endts=0,this.timespan=0,this.codeint=0,this.message="",this.text="",this.msgType="",this.networkType="",this.platform="",this._sentFlag=!1}return i(e,[{key:"setCommonInfo",value:function(e,t,n,r,o){this.SDKAppID="".concat(e),this.version="".concat(t),this.tinyID=n,this.userID=r,this.platform=o,this.time=de(),this.startts&&this.endts&&!this.timespan&&(this.timespan=Math.abs(this.endts-this.startts))}},{key:"setMethod",value:function(e){return this.method=e,this}},{key:"setStart",value:function(){this.startts=Date.now()}},{key:"setEnd",value:function(){var e=this,t=arguments.length>0&&void 0!==arguments[0]&&arguments[0];this._sentFlag||(this.endts=Date.now(),t?(this._sentFlag=!0,this._eventStatController.pushIn(this)):setTimeout((function(){e._sentFlag=!0,e._eventStatController.pushIn(e)}),0))}},{key:"setError",value:function(e,t,n){return e instanceof Error?(this._sentFlag||(this.setNetworkType(n),t?(e.code&&this.setCode(e.code),e.message&&this.setMessage(e.message)):(this.setCode(fn),this.setMessage(Ir))),this):(J.warn("SSOLogData.setError value not instanceof Error, please check!"),this)}},{key:"setCode",value:function(e){return oe(e)||this._sentFlag||(Z(e)?this.codeint=e:J.warn("SSOLogData.setCode value not a number, please check!")),this}},{key:"setMessage",value:function(e){return oe(e)||this._sentFlag?this:ee(e)?(this.message=e,this):this}},{key:"setText",value:function(e){return Z(e)?this.text=e.toString():ee(e)&&(this.text=e),this}},{key:"setMessageType",value:function(e){return this.msgType=e,this}},{key:"setNetworkType",value:function(e){return oe(e)?J.warn("SSOLogData.setNetworkType value is undefined, please check!"):this.networkType=e,this}}],[{key:"bindController",value:function(t){e.prototype._eventStatController=t}}]),e}(),ii="sdkConstruct",si="sdkReady",ai="accessLayer",ui="login",ci="getCosAuthKey",li="upload",pi="sendMessage",hi="getC2CRoamingMessages",fi="getGroupRoamingMessages",di="revokeMessage",gi="setC2CMessageRead",mi="setGroupMessageRead",yi="getConversationList",vi="getConversationListInStorage",_i="syncConversationList",Ci="createGroup",Ii="applyJoinGroup",Mi="quitGroup",Si="changeGroupOwner",Di="dismissGroup",Ti="updateGroupProfile",Ei="getGroupList",ki="getGroupListInStorage",wi="getGroupLastSequence",Ai="setGroupMemberMuteTime",Ri="setGroupMemberNameCard",Oi="setGroupMemberRole",Li="setGroupMemberCustomField",Ni="getLongPollID",bi="longPollingError",Pi="networkJitter",Gi="fastStart",Ui="slowStart",qi="getUserProfile",xi="getBlacklist",Fi="mpHideToShow",Hi=function(n){c(s,n);var o=y(s);function s(e){var t;return r(this,s),(t=o.call(this,e))._initializeListener(),t}return i(s,[{key:"login",value:function(e){if(this.isLoggedIn()){var t="您已经登录账号".concat(e.identifier,"！如需切换账号登录，请先调用 logout 接口登出，再调用 login 接口登录。");return J.warn(t),zo({actionStatus:"OK",errorCode:0,errorInfo:t,repeatLogin:!0})}J.log("SignController.login userID=",e.identifier),J.time(Jo);var n=this._checkLoginInfo(e);return Ae(n)?(this.tim.context.identifier=e.identifier,this.tim.context.userSig=e.userSig,this.tim.context.identifier&&this.tim.context.userSig?this._accessLayer():void 0):Wo(n)}},{key:"_isLoginCurrentUser",value:function(e){return this.tim.context.identifier===e}},{key:"_initializeListener",value:function(){var e=this.tim.innerEmitter;e.on(co,this._onKickedOut,this),e.on(lo,this._onMultipleDeviceKickedOut,this),e.on(ko,this._onUserSigExpired,this)}},{key:"_accessLayer",value:function(){var e=this,t=new oi;return t.setMethod(ai).setStart(),J.log("SignController._accessLayer."),this.request({name:"accessLayer",action:"query"}).then((function(n){return t.setCode(0).setNetworkType(e.getNetworkType()).setText(n.data.webImAccessLayer).setEnd(),J.log("SignController._accessLayer ok. webImAccessLayer=".concat(n.data.webImAccessLayer)),1===n.data.webImAccessLayer&&Vr.HOST.setCurrent(n.data.webImAccessLayer),e._login()})).catch((function(n){return e.probeNetwork().then((function(r){var o=v(r,2),i=o[0],s=o[1];t.setError(n,i,s).setEnd(!0),e.tim.eventStatController.reportAtOnce()})),J.error("SignController._accessLayer failed. error:".concat(n)),Wo(n)}))}},{key:"_login",value:function(){var e=this,t=new oi;return t.setMethod(ui).setStart(),this.request({name:"login",action:"query"}).then((function(n){var r=null;if(!n.data.tinyID)throw r=new pt({code:mt,message:kn}),t.setError(r,!0,e.getNetworkType()).setEnd(),r;if(!n.data.a2Key)throw r=new pt({code:yt,message:wn}),t.setError(r,!0,e.getNetworkType()).setEnd(),r;return t.setCode(0).setNetworkType(e.getNetworkType()).setText("".concat(e.tim.loginInfo.identifier)).setEnd(),J.log("SignController.login ok. userID=".concat(e.tim.loginInfo.identifier," loginCost=").concat(J.timeEnd(Jo),"ms")),e.emitInnerEvent(Do,{a2Key:n.data.a2Key,tinyID:n.data.tinyID}),zo(n.data)})).catch((function(n){return e.probeNetwork().then((function(e){var r=v(e,2),o=r[0],i=r[1];t.setError(n,o,i).setEnd(!0)})),J.error("SignController.login failed. error:".concat(n)),Wo(n)}))}},{key:"logout",value:function(){return J.info("SignController.logout"),this.emitInnerEvent(To),this._logout(Qe).then(this._emitLogoutSuccess.bind(this)).catch(this._emitLogoutSuccess.bind(this))}},{key:"_logout",value:function(e){var t=this.tim.notificationController,n=e===Je?"logout":"longPollLogout",r=e===Je?{name:n,action:"query"}:{name:n,action:"query",param:{longPollID:t.getLongPollID()}};return this.request(r).catch((function(e){return J.error("SignController._logout error:",e),Wo(e)}))}},{key:"_checkLoginInfo",value:function(e){var t=0,n="";return null===e.SDKAppID?(t=ht,n=Sn):null===e.accountType?(t=ft,n=Dn):null===e.identifier?(t=dt,n=Tn):null===e.userSig&&(t=gt,n=En),Ae(t)||Ae(n)?{}:{code:t,message:n}}},{key:"_emitLogoutSuccess",value:function(){return this.emitInnerEvent(Eo),zo({})}},{key:"_onKickedOut",value:function(){var n=this;J.warn("SignController._onKickedOut kicked out. userID=".concat(this.tim.loginInfo.identifier)),this.tim.logout().then((function(){n.emitOuterEvent(e.KICKED_OUT,{type:t.KICKED_OUT_MULT_ACCOUNT})}))}},{key:"_onMultipleDeviceKickedOut",value:function(){var n=this;J.warn("SignController._onMultipleDeviceKickedOut kicked out. userID=".concat(this.tim.loginInfo.identifier)),this.tim.logout().then((function(){n.emitOuterEvent(e.KICKED_OUT,{type:t.KICKED_OUT_MULT_DEVICE})}))}},{key:"_onUserSigExpired",value:function(){J.warn("SignController._onUserSigExpired: userSig 签名过期被踢下线"),this.emitOuterEvent(e.KICKED_OUT,{type:t.KICKED_OUT_USERSIG_EXPIRED}),this.tim.resetSDK()}},{key:"reset",value:function(){J.info("SignController.reset")}}]),s}(Bo),Bi=function(e,t){return function(){for(var n=new Array(arguments.length),r=0;r<n.length;r++)n[r]=arguments[r];return e.apply(t,n)}},Vi=Object.prototype.toString;function Ki(e){return"[object Array]"===Vi.call(e)}function ji(e){return void 0===e}function $i(e){return null!==e&&"object"==typeof e}function Yi(e){return"[object Function]"===Vi.call(e)}function zi(e,t){if(null!=e)if("object"!=typeof e&&(e=[e]),Ki(e))for(var n=0,r=e.length;n<r;n++)t.call(null,e[n],n,e);else for(var o in e)Object.prototype.hasOwnProperty.call(e,o)&&t.call(null,e[o],o,e)}var Wi={isArray:Ki,isArrayBuffer:function(e){return"[object ArrayBuffer]"===Vi.call(e)},isBuffer:function(e){return null!==e&&!ji(e)&&null!==e.constructor&&!ji(e.constructor)&&"function"==typeof e.constructor.isBuffer&&e.constructor.isBuffer(e)},isFormData:function(e){return"undefined"!=typeof FormData&&e instanceof FormData},isArrayBufferView:function(e){return"undefined"!=typeof ArrayBuffer&&ArrayBuffer.isView?ArrayBuffer.isView(e):e&&e.buffer&&e.buffer instanceof ArrayBuffer},isString:function(e){return"string"==typeof e},isNumber:function(e){return"number"==typeof e},isObject:$i,isUndefined:ji,isDate:function(e){return"[object Date]"===Vi.call(e)},isFile:function(e){return"[object File]"===Vi.call(e)},isBlob:function(e){return"[object Blob]"===Vi.call(e)},isFunction:Yi,isStream:function(e){return $i(e)&&Yi(e.pipe)},isURLSearchParams:function(e){return"undefined"!=typeof URLSearchParams&&e instanceof URLSearchParams},isStandardBrowserEnv:function(){return("undefined"==typeof navigator||"ReactNative"!==navigator.product&&"NativeScript"!==navigator.product&&"NS"!==navigator.product)&&("undefined"!=typeof window&&"undefined"!=typeof document)},forEach:zi,merge:function e(){var t={};function n(n,r){"object"==typeof t[r]&&"object"==typeof n?t[r]=e(t[r],n):t[r]=n}for(var r=0,o=arguments.length;r<o;r++)zi(arguments[r],n);return t},deepMerge:function e(){var t={};function n(n,r){"object"==typeof t[r]&&"object"==typeof n?t[r]=e(t[r],n):t[r]="object"==typeof n?e({},n):n}for(var r=0,o=arguments.length;r<o;r++)zi(arguments[r],n);return t},extend:function(e,t,n){return zi(t,(function(t,r){e[r]=n&&"function"==typeof t?Bi(t,n):t})),e},trim:function(e){return e.replace(/^\s*/,"").replace(/\s*$/,"")}};function Xi(e){return encodeURIComponent(e).replace(/%40/gi,"@").replace(/%3A/gi,":").replace(/%24/g,"$").replace(/%2C/gi,",").replace(/%20/g,"+").replace(/%5B/gi,"[").replace(/%5D/gi,"]")}var Ji=function(e,t,n){if(!t)return e;var r;if(n)r=n(t);else if(Wi.isURLSearchParams(t))r=t.toString();else{var o=[];Wi.forEach(t,(function(e,t){null!=e&&(Wi.isArray(e)?t+="[]":e=[e],Wi.forEach(e,(function(e){Wi.isDate(e)?e=e.toISOString():Wi.isObject(e)&&(e=JSON.stringify(e)),o.push(Xi(t)+"="+Xi(e))})))})),r=o.join("&")}if(r){var i=e.indexOf("#");-1!==i&&(e=e.slice(0,i)),e+=(-1===e.indexOf("?")?"?":"&")+r}return e};function Qi(){this.handlers=[]}Qi.prototype.use=function(e,t){return this.handlers.push({fulfilled:e,rejected:t}),this.handlers.length-1},Qi.prototype.eject=function(e){this.handlers[e]&&(this.handlers[e]=null)},Qi.prototype.forEach=function(e){Wi.forEach(this.handlers,(function(t){null!==t&&e(t)}))};var Zi=Qi,es=function(e,t,n){return Wi.forEach(n,(function(n){e=n(e,t)})),e},ts=function(e){return!(!e||!e.__CANCEL__)};function ns(){throw new Error("setTimeout has not been defined")}function rs(){throw new Error("clearTimeout has not been defined")}var os=ns,is=rs;function ss(e){if(os===setTimeout)return setTimeout(e,0);if((os===ns||!os)&&setTimeout)return os=setTimeout,setTimeout(e,0);try{return os(e,0)}catch(t){try{return os.call(null,e,0)}catch(t){return os.call(this,e,0)}}}"function"==typeof V.setTimeout&&(os=setTimeout),"function"==typeof V.clearTimeout&&(is=clearTimeout);var as,us=[],cs=!1,ls=-1;function ps(){cs&&as&&(cs=!1,as.length?us=as.concat(us):ls=-1,us.length&&hs())}function hs(){if(!cs){var e=ss(ps);cs=!0;for(var t=us.length;t;){for(as=us,us=[];++ls<t;)as&&as[ls].run();ls=-1,t=us.length}as=null,cs=!1,function(e){if(is===clearTimeout)return clearTimeout(e);if((is===rs||!is)&&clearTimeout)return is=clearTimeout,clearTimeout(e);try{is(e)}catch(t){try{return is.call(null,e)}catch(t){return is.call(this,e)}}}(e)}}function fs(e,t){this.fun=e,this.array=t}fs.prototype.run=function(){this.fun.apply(null,this.array)};function ds(){}var gs=ds,ms=ds,ys=ds,vs=ds,_s=ds,Cs=ds,Is=ds;var Ms=V.performance||{},Ss=Ms.now||Ms.mozNow||Ms.msNow||Ms.oNow||Ms.webkitNow||function(){return(new Date).getTime()};var Ds=new Date;var Ts={nextTick:function(e){var t=new Array(arguments.length-1);if(arguments.length>1)for(var n=1;n<arguments.length;n++)t[n-1]=arguments[n];us.push(new fs(e,t)),1!==us.length||cs||ss(hs)},title:"browser",browser:!0,env:{},argv:[],version:"",versions:{},on:gs,addListener:ms,once:ys,off:vs,removeListener:_s,removeAllListeners:Cs,emit:Is,binding:function(e){throw new Error("process.binding is not supported")},cwd:function(){return"/"},chdir:function(e){throw new Error("process.chdir is not supported")},umask:function(){return 0},hrtime:function(e){var t=.001*Ss.call(Ms),n=Math.floor(t),r=Math.floor(t%1*1e9);return e&&(n-=e[0],(r-=e[1])<0&&(n--,r+=1e9)),[n,r]},platform:"browser",release:{},config:{},uptime:function(){return(new Date-Ds)/1e3}},Es=function(e,t){Wi.forEach(e,(function(n,r){r!==t&&r.toUpperCase()===t.toUpperCase()&&(e[t]=n,delete e[r])}))},ks=function(e,t,n,r,o){return function(e,t,n,r,o){return e.config=t,n&&(e.code=n),e.request=r,e.response=o,e.isAxiosError=!0,e.toJSON=function(){return{message:this.message,name:this.name,description:this.description,number:this.number,fileName:this.fileName,lineNumber:this.lineNumber,columnNumber:this.columnNumber,stack:this.stack,config:this.config,code:this.code}},e}(new Error(e),t,n,r,o)},ws=["age","authorization","content-length","content-type","etag","expires","from","host","if-modified-since","if-unmodified-since","last-modified","location","max-forwards","proxy-authorization","referer","retry-after","user-agent"],As=Wi.isStandardBrowserEnv()?function(){var e,t=/(msie|trident)/i.test(navigator.userAgent),n=document.createElement("a");function r(e){var r=e;return t&&(n.setAttribute("href",r),r=n.href),n.setAttribute("href",r),{href:n.href,protocol:n.protocol?n.protocol.replace(/:$/,""):"",host:n.host,search:n.search?n.search.replace(/^\?/,""):"",hash:n.hash?n.hash.replace(/^#/,""):"",hostname:n.hostname,port:n.port,pathname:"/"===n.pathname.charAt(0)?n.pathname:"/"+n.pathname}}return e=r(window.location.href),function(t){var n=Wi.isString(t)?r(t):t;return n.protocol===e.protocol&&n.host===e.host}}():function(){return!0},Rs=Wi.isStandardBrowserEnv()?{write:function(e,t,n,r,o,i){var s=[];s.push(e+"="+encodeURIComponent(t)),Wi.isNumber(n)&&s.push("expires="+new Date(n).toGMTString()),Wi.isString(r)&&s.push("path="+r),Wi.isString(o)&&s.push("domain="+o),!0===i&&s.push("secure"),document.cookie=s.join("; ")},read:function(e){var t=document.cookie.match(new RegExp("(^|;\\s*)("+e+")=([^;]*)"));return t?decodeURIComponent(t[3]):null},remove:function(e){this.write(e,"",Date.now()-864e5)}}:{write:function(){},read:function(){return null},remove:function(){}},Os=function(e){return new Promise((function(t,n){var r=e.data,o=e.headers;Wi.isFormData(r)&&delete o["Content-Type"];var i=new XMLHttpRequest;if(e.auth){var s=e.auth.username||"",a=e.auth.password||"";o.Authorization="Basic "+btoa(s+":"+a)}var u,c,l=(u=e.baseURL,c=e.url,u&&!/^([a-z][a-z\d\+\-\.]*:)?\/\//i.test(c)?function(e,t){return t?e.replace(/\/+$/,"")+"/"+t.replace(/^\/+/,""):e}(u,c):c);if(i.open(e.method.toUpperCase(),Ji(l,e.params,e.paramsSerializer),!0),i.timeout=e.timeout,i.onreadystatechange=function(){if(i&&4===i.readyState&&(0!==i.status||i.responseURL&&0===i.responseURL.indexOf("file:"))){var r,o,s,a,u,c="getAllResponseHeaders"in i?(r=i.getAllResponseHeaders(),u={},r?(Wi.forEach(r.split("\n"),(function(e){if(a=e.indexOf(":"),o=Wi.trim(e.substr(0,a)).toLowerCase(),s=Wi.trim(e.substr(a+1)),o){if(u[o]&&ws.indexOf(o)>=0)return;u[o]="set-cookie"===o?(u[o]?u[o]:[]).concat([s]):u[o]?u[o]+", "+s:s}})),u):u):null,l={data:e.responseType&&"text"!==e.responseType?i.response:i.responseText,status:i.status,statusText:i.statusText,headers:c,config:e,request:i};!function(e,t,n){var r=n.config.validateStatus;!r||r(n.status)?e(n):t(ks("Request failed with status code "+n.status,n.config,null,n.request,n))}(t,n,l),i=null}},i.onabort=function(){i&&(n(ks("Request aborted",e,"ECONNABORTED",i)),i=null)},i.onerror=function(){n(ks("Network Error",e,null,i)),i=null},i.ontimeout=function(){var t="timeout of "+e.timeout+"ms exceeded";e.timeoutErrorMessage&&(t=e.timeoutErrorMessage),n(ks(t,e,"ECONNABORTED",i)),i=null},Wi.isStandardBrowserEnv()){var p=Rs,h=(e.withCredentials||As(l))&&e.xsrfCookieName?p.read(e.xsrfCookieName):void 0;h&&(o[e.xsrfHeaderName]=h)}if("setRequestHeader"in i&&Wi.forEach(o,(function(e,t){void 0===r&&"content-type"===t.toLowerCase()?delete o[t]:i.setRequestHeader(t,e)})),Wi.isUndefined(e.withCredentials)||(i.withCredentials=!!e.withCredentials),e.responseType)try{i.responseType=e.responseType}catch(f){if("json"!==e.responseType)throw f}"function"==typeof e.onDownloadProgress&&i.addEventListener("progress",e.onDownloadProgress),"function"==typeof e.onUploadProgress&&i.upload&&i.upload.addEventListener("progress",e.onUploadProgress),e.cancelToken&&e.cancelToken.promise.then((function(e){i&&(i.abort(),n(e),i=null)})),void 0===r&&(r=null),i.send(r)}))},Ls={"Content-Type":"application/x-www-form-urlencoded"};function Ns(e,t){!Wi.isUndefined(e)&&Wi.isUndefined(e["Content-Type"])&&(e["Content-Type"]=t)}var bs,Ps={adapter:(("undefined"!=typeof XMLHttpRequest||void 0!==Ts&&"[object process]"===Object.prototype.toString.call(Ts))&&(bs=Os),bs),transformRequest:[function(e,t){return Es(t,"Accept"),Es(t,"Content-Type"),Wi.isFormData(e)||Wi.isArrayBuffer(e)||Wi.isBuffer(e)||Wi.isStream(e)||Wi.isFile(e)||Wi.isBlob(e)?e:Wi.isArrayBufferView(e)?e.buffer:Wi.isURLSearchParams(e)?(Ns(t,"application/x-www-form-urlencoded;charset=utf-8"),e.toString()):Wi.isObject(e)?(Ns(t,"application/json;charset=utf-8"),JSON.stringify(e)):e}],transformResponse:[function(e){if("string"==typeof e)try{e=JSON.parse(e)}catch(t){}return e}],timeout:0,xsrfCookieName:"XSRF-TOKEN",xsrfHeaderName:"X-XSRF-TOKEN",maxContentLength:-1,validateStatus:function(e){return e>=200&&e<300}};Ps.headers={common:{Accept:"application/json, text/plain, */*"}},Wi.forEach(["delete","get","head"],(function(e){Ps.headers[e]={}})),Wi.forEach(["post","put","patch"],(function(e){Ps.headers[e]=Wi.merge(Ls)}));var Gs=Ps;function Us(e){e.cancelToken&&e.cancelToken.throwIfRequested()}var qs=function(e){return Us(e),e.headers=e.headers||{},e.data=es(e.data,e.headers,e.transformRequest),e.headers=Wi.merge(e.headers.common||{},e.headers[e.method]||{},e.headers),Wi.forEach(["delete","get","head","post","put","patch","common"],(function(t){delete e.headers[t]})),(e.adapter||Gs.adapter)(e).then((function(t){return Us(e),t.data=es(t.data,t.headers,e.transformResponse),t}),(function(t){return ts(t)||(Us(e),t&&t.response&&(t.response.data=es(t.response.data,t.response.headers,e.transformResponse))),Promise.reject(t)}))},xs=function(e,t){t=t||{};var n={},r=["url","method","params","data"],o=["headers","auth","proxy"],i=["baseURL","url","transformRequest","transformResponse","paramsSerializer","timeout","withCredentials","adapter","responseType","xsrfCookieName","xsrfHeaderName","onUploadProgress","onDownloadProgress","maxContentLength","validateStatus","maxRedirects","httpAgent","httpsAgent","cancelToken","socketPath"];Wi.forEach(r,(function(e){void 0!==t[e]&&(n[e]=t[e])})),Wi.forEach(o,(function(r){Wi.isObject(t[r])?n[r]=Wi.deepMerge(e[r],t[r]):void 0!==t[r]?n[r]=t[r]:Wi.isObject(e[r])?n[r]=Wi.deepMerge(e[r]):void 0!==e[r]&&(n[r]=e[r])})),Wi.forEach(i,(function(r){void 0!==t[r]?n[r]=t[r]:void 0!==e[r]&&(n[r]=e[r])}));var s=r.concat(o).concat(i),a=Object.keys(t).filter((function(e){return-1===s.indexOf(e)}));return Wi.forEach(a,(function(r){void 0!==t[r]?n[r]=t[r]:void 0!==e[r]&&(n[r]=e[r])})),n};function Fs(e){this.defaults=e,this.interceptors={request:new Zi,response:new Zi}}Fs.prototype.request=function(e){"string"==typeof e?(e=arguments[1]||{}).url=arguments[0]:e=e||{},(e=xs(this.defaults,e)).method?e.method=e.method.toLowerCase():this.defaults.method?e.method=this.defaults.method.toLowerCase():e.method="get";var t=[qs,void 0],n=Promise.resolve(e);for(this.interceptors.request.forEach((function(e){t.unshift(e.fulfilled,e.rejected)})),this.interceptors.response.forEach((function(e){t.push(e.fulfilled,e.rejected)}));t.length;)n=n.then(t.shift(),t.shift());return n},Fs.prototype.getUri=function(e){return e=xs(this.defaults,e),Ji(e.url,e.params,e.paramsSerializer).replace(/^\?/,"")},Wi.forEach(["delete","get","head","options"],(function(e){Fs.prototype[e]=function(t,n){return this.request(Wi.merge(n||{},{method:e,url:t}))}})),Wi.forEach(["post","put","patch"],(function(e){Fs.prototype[e]=function(t,n,r){return this.request(Wi.merge(r||{},{method:e,url:t,data:n}))}}));var Hs=Fs;function Bs(e){this.message=e}Bs.prototype.toString=function(){return"Cancel"+(this.message?": "+this.message:"")},Bs.prototype.__CANCEL__=!0;var Vs=Bs;function Ks(e){if("function"!=typeof e)throw new TypeError("executor must be a function.");var t;this.promise=new Promise((function(e){t=e}));var n=this;e((function(e){n.reason||(n.reason=new Vs(e),t(n.reason))}))}Ks.prototype.throwIfRequested=function(){if(this.reason)throw this.reason},Ks.source=function(){var e;return{token:new Ks((function(t){e=t})),cancel:e}};var js=Ks;function $s(e){var t=new Hs(e),n=Bi(Hs.prototype.request,t);return Wi.extend(n,Hs.prototype,t),Wi.extend(n,t),n}var Ys=$s(Gs);Ys.Axios=Hs,Ys.create=function(e){return $s(xs(Ys.defaults,e))},Ys.Cancel=Vs,Ys.CancelToken=js,Ys.isCancel=ts,Ys.all=function(e){return Promise.all(e)},Ys.spread=function(e){return function(t){return e.apply(null,t)}};var zs=Ys,Ws=Ys;zs.default=Ws;var Xs=zs,Js=Xs.create({timeout:3e4,headers:{"Content-Type":"application/x-www-form-urlencoded;charset=UTF-8"}});Js.interceptors.response.use((function(e){var t=e.data,n=t.error_code,r=t.ErrorCode;return Z(n)&&(r=n),r!==Ne.SUCCESS&&(e.data.ErrorCode=Number(r)),e}),(function(e){return"Network Error"===e.message&&(!0===Js.defaults.withCredentials&&J.warn("Network Error, try to close `IMAxios.defaults.withCredentials` to false. (IMAxios.js)"),Js.defaults.withCredentials=!1),Promise.reject(e)}));var Qs=function(){function e(){r(this,e)}return i(e,[{key:"request",value:function(e){console.warn("请注意： ConnectionBase.request() 方法必须被派生类重写:"),console.log("参数如下：\n    * @param {String} options.url string 是 开发者服务器接口地址\n    * @param {*} options.data - string/object/ArrayBuffer 否 请求的参数\n    * @param {Object} options.header - Object 否 设置请求的 header，\n    * @param {String} options.method - string GET 否 HTTP 请求方法\n    * @param {String} options.dataType - string json 否 返回的数据格式\n    * @param {String} options.responseType - string text 否 响应的数据类型\n    * @param {Boolean} isRetry - string text false 是否为重试的请求\n   ")}},{key:"_checkOptions",value:function(e){if(!1==!!e.url)throw new pt({code:ln,message:vr})}},{key:"_initOptions",value:function(e){e.method=["POST","GET","PUT","DELETE","OPTION"].indexOf(e.method)>=0?e.method:"POST",e.dataType=e.dataType||"json",e.responseType=e.responseType||"json"}}]),e}(),Zs=function(e){c(n,e);var t=y(n);function n(){var e;return r(this,n),(e=t.call(this)).retry=2,e}return i(n,[{key:"request",value:function(e){return this._checkOptions(e),this._initOptions(e),this._requestWithRetry({url:e.url,data:e.data,method:e.method})}},{key:"_requestWithRetry",value:function(e){var t=this,n=arguments.length>1&&void 0!==arguments[1]?arguments[1]:0;return Js(e).catch((function(r){return t.retry&&n<t.retry?t._requestWithRetry(e,++n):Wo(new pt({code:r.code||"",message:r.message||""}))}))}}]),n}(Qs),ea=[],ta=[],na="undefined"!=typeof Uint8Array?Uint8Array:Array,ra=!1;function oa(){ra=!0;for(var e="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/",t=0,n=e.length;t<n;++t)ea[t]=e[t],ta[e.charCodeAt(t)]=t;ta["-".charCodeAt(0)]=62,ta["_".charCodeAt(0)]=63}function ia(e,t,n){for(var r,o,i=[],s=t;s<n;s+=3)r=(e[s]<<16)+(e[s+1]<<8)+e[s+2],i.push(ea[(o=r)>>18&63]+ea[o>>12&63]+ea[o>>6&63]+ea[63&o]);return i.join("")}function sa(e){var t;ra||oa();for(var n=e.length,r=n%3,o="",i=[],s=0,a=n-r;s<a;s+=16383)i.push(ia(e,s,s+16383>a?a:s+16383));return 1===r?(t=e[n-1],o+=ea[t>>2],o+=ea[t<<4&63],o+="=="):2===r&&(t=(e[n-2]<<8)+e[n-1],o+=ea[t>>10],o+=ea[t>>4&63],o+=ea[t<<2&63],o+="="),i.push(o),i.join("")}function aa(e,t,n,r,o){var i,s,a=8*o-r-1,u=(1<<a)-1,c=u>>1,l=-7,p=n?o-1:0,h=n?-1:1,f=e[t+p];for(p+=h,i=f&(1<<-l)-1,f>>=-l,l+=a;l>0;i=256*i+e[t+p],p+=h,l-=8);for(s=i&(1<<-l)-1,i>>=-l,l+=r;l>0;s=256*s+e[t+p],p+=h,l-=8);if(0===i)i=1-c;else{if(i===u)return s?NaN:Infinity*(f?-1:1);s+=Math.pow(2,r),i-=c}return(f?-1:1)*s*Math.pow(2,i-r)}function ua(e,t,n,r,o,i){var s,a,u,c=8*i-o-1,l=(1<<c)-1,p=l>>1,h=23===o?Math.pow(2,-24)-Math.pow(2,-77):0,f=r?0:i-1,d=r?1:-1,g=t<0||0===t&&1/t<0?1:0;for(t=Math.abs(t),isNaN(t)||Infinity===t?(a=isNaN(t)?1:0,s=l):(s=Math.floor(Math.log(t)/Math.LN2),t*(u=Math.pow(2,-s))<1&&(s--,u*=2),(t+=s+p>=1?h/u:h*Math.pow(2,1-p))*u>=2&&(s++,u/=2),s+p>=l?(a=0,s=l):s+p>=1?(a=(t*u-1)*Math.pow(2,o),s+=p):(a=t*Math.pow(2,p-1)*Math.pow(2,o),s=0));o>=8;e[n+f]=255&a,f+=d,a/=256,o-=8);for(s=s<<o|a,c+=o;c>0;e[n+f]=255&s,f+=d,s/=256,c-=8);e[n+f-d]|=128*g}var ca={}.toString,la=Array.isArray||function(e){return"[object Array]"==ca.call(e)};function pa(){return fa.TYPED_ARRAY_SUPPORT?2147483647:1073741823}function ha(e,t){if(pa()<t)throw new RangeError("Invalid typed array length");return fa.TYPED_ARRAY_SUPPORT?(e=new Uint8Array(t)).__proto__=fa.prototype:(null===e&&(e=new fa(t)),e.length=t),e}function fa(e,t,n){if(!(fa.TYPED_ARRAY_SUPPORT||this instanceof fa))return new fa(e,t,n);if("number"==typeof e){if("string"==typeof t)throw new Error("If encoding is specified then the first argument must be a string");return ma(this,e)}return da(this,e,t,n)}function da(e,t,n,r){if("number"==typeof t)throw new TypeError('"value" argument must not be a number');return"undefined"!=typeof ArrayBuffer&&t instanceof ArrayBuffer?function(e,t,n,r){if(t.byteLength,n<0||t.byteLength<n)throw new RangeError("'offset' is out of bounds");if(t.byteLength<n+(r||0))throw new RangeError("'length' is out of bounds");t=void 0===n&&void 0===r?new Uint8Array(t):void 0===r?new Uint8Array(t,n):new Uint8Array(t,n,r);fa.TYPED_ARRAY_SUPPORT?(e=t).__proto__=fa.prototype:e=ya(e,t);return e}(e,t,n,r):"string"==typeof t?function(e,t,n){"string"==typeof n&&""!==n||(n="utf8");if(!fa.isEncoding(n))throw new TypeError('"encoding" must be a valid string encoding');var r=0|Ca(t,n),o=(e=ha(e,r)).write(t,n);o!==r&&(e=e.slice(0,o));return e}(e,t,n):function(e,t){if(_a(t)){var n=0|va(t.length);return 0===(e=ha(e,n)).length||t.copy(e,0,0,n),e}if(t){if("undefined"!=typeof ArrayBuffer&&t.buffer instanceof ArrayBuffer||"length"in t)return"number"!=typeof t.length||(r=t.length)!=r?ha(e,0):ya(e,t);if("Buffer"===t.type&&la(t.data))return ya(e,t.data)}var r;throw new TypeError("First argument must be a string, Buffer, ArrayBuffer, Array, or array-like object.")}(e,t)}function ga(e){if("number"!=typeof e)throw new TypeError('"size" argument must be a number');if(e<0)throw new RangeError('"size" argument must not be negative')}function ma(e,t){if(ga(t),e=ha(e,t<0?0:0|va(t)),!fa.TYPED_ARRAY_SUPPORT)for(var n=0;n<t;++n)e[n]=0;return e}function ya(e,t){var n=t.length<0?0:0|va(t.length);e=ha(e,n);for(var r=0;r<n;r+=1)e[r]=255&t[r];return e}function va(e){if(e>=pa())throw new RangeError("Attempt to allocate Buffer larger than maximum size: 0x"+pa().toString(16)+" bytes");return 0|e}function _a(e){return!(null==e||!e._isBuffer)}function Ca(e,t){if(_a(e))return e.length;if("undefined"!=typeof ArrayBuffer&&"function"==typeof ArrayBuffer.isView&&(ArrayBuffer.isView(e)||e instanceof ArrayBuffer))return e.byteLength;"string"!=typeof e&&(e=""+e);var n=e.length;if(0===n)return 0;for(var r=!1;;)switch(t){case"ascii":case"latin1":case"binary":return n;case"utf8":case"utf-8":case void 0:return $a(e).length;case"ucs2":case"ucs-2":case"utf16le":case"utf-16le":return 2*n;case"hex":return n>>>1;case"base64":return Ya(e).length;default:if(r)return $a(e).length;t=(""+t).toLowerCase(),r=!0}}function Ia(e,t,n){var r=!1;if((void 0===t||t<0)&&(t=0),t>this.length)return"";if((void 0===n||n>this.length)&&(n=this.length),n<=0)return"";if((n>>>=0)<=(t>>>=0))return"";for(e||(e="utf8");;)switch(e){case"hex":return Pa(this,t,n);case"utf8":case"utf-8":return La(this,t,n);case"ascii":return Na(this,t,n);case"latin1":case"binary":return ba(this,t,n);case"base64":return Oa(this,t,n);case"ucs2":case"ucs-2":case"utf16le":case"utf-16le":return Ga(this,t,n);default:if(r)throw new TypeError("Unknown encoding: "+e);e=(e+"").toLowerCase(),r=!0}}function Ma(e,t,n){var r=e[t];e[t]=e[n],e[n]=r}function Sa(e,t,n,r,o){if(0===e.length)return-1;if("string"==typeof n?(r=n,n=0):n>2147483647?n=2147483647:n<-2147483648&&(n=-2147483648),n=+n,isNaN(n)&&(n=o?0:e.length-1),n<0&&(n=e.length+n),n>=e.length){if(o)return-1;n=e.length-1}else if(n<0){if(!o)return-1;n=0}if("string"==typeof t&&(t=fa.from(t,r)),_a(t))return 0===t.length?-1:Da(e,t,n,r,o);if("number"==typeof t)return t&=255,fa.TYPED_ARRAY_SUPPORT&&"function"==typeof Uint8Array.prototype.indexOf?o?Uint8Array.prototype.indexOf.call(e,t,n):Uint8Array.prototype.lastIndexOf.call(e,t,n):Da(e,[t],n,r,o);throw new TypeError("val must be string, number or Buffer")}function Da(e,t,n,r,o){var i,s=1,a=e.length,u=t.length;if(void 0!==r&&("ucs2"===(r=String(r).toLowerCase())||"ucs-2"===r||"utf16le"===r||"utf-16le"===r)){if(e.length<2||t.length<2)return-1;s=2,a/=2,u/=2,n/=2}function c(e,t){return 1===s?e[t]:e.readUInt16BE(t*s)}if(o){var l=-1;for(i=n;i<a;i++)if(c(e,i)===c(t,-1===l?0:i-l)){if(-1===l&&(l=i),i-l+1===u)return l*s}else-1!==l&&(i-=i-l),l=-1}else for(n+u>a&&(n=a-u),i=n;i>=0;i--){for(var p=!0,h=0;h<u;h++)if(c(e,i+h)!==c(t,h)){p=!1;break}if(p)return i}return-1}function Ta(e,t,n,r){n=Number(n)||0;var o=e.length-n;r?(r=Number(r))>o&&(r=o):r=o;var i=t.length;if(i%2!=0)throw new TypeError("Invalid hex string");r>i/2&&(r=i/2);for(var s=0;s<r;++s){var a=parseInt(t.substr(2*s,2),16);if(isNaN(a))return s;e[n+s]=a}return s}function Ea(e,t,n,r){return za($a(t,e.length-n),e,n,r)}function ka(e,t,n,r){return za(function(e){for(var t=[],n=0;n<e.length;++n)t.push(255&e.charCodeAt(n));return t}(t),e,n,r)}function wa(e,t,n,r){return ka(e,t,n,r)}function Aa(e,t,n,r){return za(Ya(t),e,n,r)}function Ra(e,t,n,r){return za(function(e,t){for(var n,r,o,i=[],s=0;s<e.length&&!((t-=2)<0);++s)n=e.charCodeAt(s),r=n>>8,o=n%256,i.push(o),i.push(r);return i}(t,e.length-n),e,n,r)}function Oa(e,t,n){return 0===t&&n===e.length?sa(e):sa(e.slice(t,n))}function La(e,t,n){n=Math.min(e.length,n);for(var r=[],o=t;o<n;){var i,s,a,u,c=e[o],l=null,p=c>239?4:c>223?3:c>191?2:1;if(o+p<=n)switch(p){case 1:c<128&&(l=c);break;case 2:128==(192&(i=e[o+1]))&&(u=(31&c)<<6|63&i)>127&&(l=u);break;case 3:i=e[o+1],s=e[o+2],128==(192&i)&&128==(192&s)&&(u=(15&c)<<12|(63&i)<<6|63&s)>2047&&(u<55296||u>57343)&&(l=u);break;case 4:i=e[o+1],s=e[o+2],a=e[o+3],128==(192&i)&&128==(192&s)&&128==(192&a)&&(u=(15&c)<<18|(63&i)<<12|(63&s)<<6|63&a)>65535&&u<1114112&&(l=u)}null===l?(l=65533,p=1):l>65535&&(l-=65536,r.push(l>>>10&1023|55296),l=56320|1023&l),r.push(l),o+=p}return function(e){var t=e.length;if(t<=4096)return String.fromCharCode.apply(String,e);var n="",r=0;for(;r<t;)n+=String.fromCharCode.apply(String,e.slice(r,r+=4096));return n}(r)}fa.TYPED_ARRAY_SUPPORT=void 0===V.TYPED_ARRAY_SUPPORT||V.TYPED_ARRAY_SUPPORT,fa.poolSize=8192,fa._augment=function(e){return e.__proto__=fa.prototype,e},fa.from=function(e,t,n){return da(null,e,t,n)},fa.TYPED_ARRAY_SUPPORT&&(fa.prototype.__proto__=Uint8Array.prototype,fa.__proto__=Uint8Array),fa.alloc=function(e,t,n){return function(e,t,n,r){return ga(t),t<=0?ha(e,t):void 0!==n?"string"==typeof r?ha(e,t).fill(n,r):ha(e,t).fill(n):ha(e,t)}(null,e,t,n)},fa.allocUnsafe=function(e){return ma(null,e)},fa.allocUnsafeSlow=function(e){return ma(null,e)},fa.isBuffer=function(e){return null!=e&&(!!e._isBuffer||Wa(e)||function(e){return"function"==typeof e.readFloatLE&&"function"==typeof e.slice&&Wa(e.slice(0,0))}(e))},fa.compare=function(e,t){if(!_a(e)||!_a(t))throw new TypeError("Arguments must be Buffers");if(e===t)return 0;for(var n=e.length,r=t.length,o=0,i=Math.min(n,r);o<i;++o)if(e[o]!==t[o]){n=e[o],r=t[o];break}return n<r?-1:r<n?1:0},fa.isEncoding=function(e){switch(String(e).toLowerCase()){case"hex":case"utf8":case"utf-8":case"ascii":case"latin1":case"binary":case"base64":case"ucs2":case"ucs-2":case"utf16le":case"utf-16le":return!0;default:return!1}},fa.concat=function(e,t){if(!la(e))throw new TypeError('"list" argument must be an Array of Buffers');if(0===e.length)return fa.alloc(0);var n;if(void 0===t)for(t=0,n=0;n<e.length;++n)t+=e[n].length;var r=fa.allocUnsafe(t),o=0;for(n=0;n<e.length;++n){var i=e[n];if(!_a(i))throw new TypeError('"list" argument must be an Array of Buffers');i.copy(r,o),o+=i.length}return r},fa.byteLength=Ca,fa.prototype._isBuffer=!0,fa.prototype.swap16=function(){var e=this.length;if(e%2!=0)throw new RangeError("Buffer size must be a multiple of 16-bits");for(var t=0;t<e;t+=2)Ma(this,t,t+1);return this},fa.prototype.swap32=function(){var e=this.length;if(e%4!=0)throw new RangeError("Buffer size must be a multiple of 32-bits");for(var t=0;t<e;t+=4)Ma(this,t,t+3),Ma(this,t+1,t+2);return this},fa.prototype.swap64=function(){var e=this.length;if(e%8!=0)throw new RangeError("Buffer size must be a multiple of 64-bits");for(var t=0;t<e;t+=8)Ma(this,t,t+7),Ma(this,t+1,t+6),Ma(this,t+2,t+5),Ma(this,t+3,t+4);return this},fa.prototype.toString=function(){var e=0|this.length;return 0===e?"":0===arguments.length?La(this,0,e):Ia.apply(this,arguments)},fa.prototype.equals=function(e){if(!_a(e))throw new TypeError("Argument must be a Buffer");return this===e||0===fa.compare(this,e)},fa.prototype.inspect=function(){var e="";return this.length>0&&(e=this.toString("hex",0,50).match(/.{2}/g).join(" "),this.length>50&&(e+=" ... ")),"<Buffer "+e+">"},fa.prototype.compare=function(e,t,n,r,o){if(!_a(e))throw new TypeError("Argument must be a Buffer");if(void 0===t&&(t=0),void 0===n&&(n=e?e.length:0),void 0===r&&(r=0),void 0===o&&(o=this.length),t<0||n>e.length||r<0||o>this.length)throw new RangeError("out of range index");if(r>=o&&t>=n)return 0;if(r>=o)return-1;if(t>=n)return 1;if(this===e)return 0;for(var i=(o>>>=0)-(r>>>=0),s=(n>>>=0)-(t>>>=0),a=Math.min(i,s),u=this.slice(r,o),c=e.slice(t,n),l=0;l<a;++l)if(u[l]!==c[l]){i=u[l],s=c[l];break}return i<s?-1:s<i?1:0},fa.prototype.includes=function(e,t,n){return-1!==this.indexOf(e,t,n)},fa.prototype.indexOf=function(e,t,n){return Sa(this,e,t,n,!0)},fa.prototype.lastIndexOf=function(e,t,n){return Sa(this,e,t,n,!1)},fa.prototype.write=function(e,t,n,r){if(void 0===t)r="utf8",n=this.length,t=0;else if(void 0===n&&"string"==typeof t)r=t,n=this.length,t=0;else{if(!isFinite(t))throw new Error("Buffer.write(string, encoding, offset[, length]) is no longer supported");t|=0,isFinite(n)?(n|=0,void 0===r&&(r="utf8")):(r=n,n=void 0)}var o=this.length-t;if((void 0===n||n>o)&&(n=o),e.length>0&&(n<0||t<0)||t>this.length)throw new RangeError("Attempt to write outside buffer bounds");r||(r="utf8");for(var i=!1;;)switch(r){case"hex":return Ta(this,e,t,n);case"utf8":case"utf-8":return Ea(this,e,t,n);case"ascii":return ka(this,e,t,n);case"latin1":case"binary":return wa(this,e,t,n);case"base64":return Aa(this,e,t,n);case"ucs2":case"ucs-2":case"utf16le":case"utf-16le":return Ra(this,e,t,n);default:if(i)throw new TypeError("Unknown encoding: "+r);r=(""+r).toLowerCase(),i=!0}},fa.prototype.toJSON=function(){return{type:"Buffer",data:Array.prototype.slice.call(this._arr||this,0)}};function Na(e,t,n){var r="";n=Math.min(e.length,n);for(var o=t;o<n;++o)r+=String.fromCharCode(127&e[o]);return r}function ba(e,t,n){var r="";n=Math.min(e.length,n);for(var o=t;o<n;++o)r+=String.fromCharCode(e[o]);return r}function Pa(e,t,n){var r=e.length;(!t||t<0)&&(t=0),(!n||n<0||n>r)&&(n=r);for(var o="",i=t;i<n;++i)o+=ja(e[i]);return o}function Ga(e,t,n){for(var r=e.slice(t,n),o="",i=0;i<r.length;i+=2)o+=String.fromCharCode(r[i]+256*r[i+1]);return o}function Ua(e,t,n){if(e%1!=0||e<0)throw new RangeError("offset is not uint");if(e+t>n)throw new RangeError("Trying to access beyond buffer length")}function qa(e,t,n,r,o,i){if(!_a(e))throw new TypeError('"buffer" argument must be a Buffer instance');if(t>o||t<i)throw new RangeError('"value" argument is out of bounds');if(n+r>e.length)throw new RangeError("Index out of range")}function xa(e,t,n,r){t<0&&(t=65535+t+1);for(var o=0,i=Math.min(e.length-n,2);o<i;++o)e[n+o]=(t&255<<8*(r?o:1-o))>>>8*(r?o:1-o)}function Fa(e,t,n,r){t<0&&(t=4294967295+t+1);for(var o=0,i=Math.min(e.length-n,4);o<i;++o)e[n+o]=t>>>8*(r?o:3-o)&255}function Ha(e,t,n,r,o,i){if(n+r>e.length)throw new RangeError("Index out of range");if(n<0)throw new RangeError("Index out of range")}function Ba(e,t,n,r,o){return o||Ha(e,0,n,4),ua(e,t,n,r,23,4),n+4}function Va(e,t,n,r,o){return o||Ha(e,0,n,8),ua(e,t,n,r,52,8),n+8}fa.prototype.slice=function(e,t){var n,r=this.length;if((e=~~e)<0?(e+=r)<0&&(e=0):e>r&&(e=r),(t=void 0===t?r:~~t)<0?(t+=r)<0&&(t=0):t>r&&(t=r),t<e&&(t=e),fa.TYPED_ARRAY_SUPPORT)(n=this.subarray(e,t)).__proto__=fa.prototype;else{var o=t-e;n=new fa(o,void 0);for(var i=0;i<o;++i)n[i]=this[i+e]}return n},fa.prototype.readUIntLE=function(e,t,n){e|=0,t|=0,n||Ua(e,t,this.length);for(var r=this[e],o=1,i=0;++i<t&&(o*=256);)r+=this[e+i]*o;return r},fa.prototype.readUIntBE=function(e,t,n){e|=0,t|=0,n||Ua(e,t,this.length);for(var r=this[e+--t],o=1;t>0&&(o*=256);)r+=this[e+--t]*o;return r},fa.prototype.readUInt8=function(e,t){return t||Ua(e,1,this.length),this[e]},fa.prototype.readUInt16LE=function(e,t){return t||Ua(e,2,this.length),this[e]|this[e+1]<<8},fa.prototype.readUInt16BE=function(e,t){return t||Ua(e,2,this.length),this[e]<<8|this[e+1]},fa.prototype.readUInt32LE=function(e,t){return t||Ua(e,4,this.length),(this[e]|this[e+1]<<8|this[e+2]<<16)+16777216*this[e+3]},fa.prototype.readUInt32BE=function(e,t){return t||Ua(e,4,this.length),16777216*this[e]+(this[e+1]<<16|this[e+2]<<8|this[e+3])},fa.prototype.readIntLE=function(e,t,n){e|=0,t|=0,n||Ua(e,t,this.length);for(var r=this[e],o=1,i=0;++i<t&&(o*=256);)r+=this[e+i]*o;return r>=(o*=128)&&(r-=Math.pow(2,8*t)),r},fa.prototype.readIntBE=function(e,t,n){e|=0,t|=0,n||Ua(e,t,this.length);for(var r=t,o=1,i=this[e+--r];r>0&&(o*=256);)i+=this[e+--r]*o;return i>=(o*=128)&&(i-=Math.pow(2,8*t)),i},fa.prototype.readInt8=function(e,t){return t||Ua(e,1,this.length),128&this[e]?-1*(255-this[e]+1):this[e]},fa.prototype.readInt16LE=function(e,t){t||Ua(e,2,this.length);var n=this[e]|this[e+1]<<8;return 32768&n?4294901760|n:n},fa.prototype.readInt16BE=function(e,t){t||Ua(e,2,this.length);var n=this[e+1]|this[e]<<8;return 32768&n?4294901760|n:n},fa.prototype.readInt32LE=function(e,t){return t||Ua(e,4,this.length),this[e]|this[e+1]<<8|this[e+2]<<16|this[e+3]<<24},fa.prototype.readInt32BE=function(e,t){return t||Ua(e,4,this.length),this[e]<<24|this[e+1]<<16|this[e+2]<<8|this[e+3]},fa.prototype.readFloatLE=function(e,t){return t||Ua(e,4,this.length),aa(this,e,!0,23,4)},fa.prototype.readFloatBE=function(e,t){return t||Ua(e,4,this.length),aa(this,e,!1,23,4)},fa.prototype.readDoubleLE=function(e,t){return t||Ua(e,8,this.length),aa(this,e,!0,52,8)},fa.prototype.readDoubleBE=function(e,t){return t||Ua(e,8,this.length),aa(this,e,!1,52,8)},fa.prototype.writeUIntLE=function(e,t,n,r){(e=+e,t|=0,n|=0,r)||qa(this,e,t,n,Math.pow(2,8*n)-1,0);var o=1,i=0;for(this[t]=255&e;++i<n&&(o*=256);)this[t+i]=e/o&255;return t+n},fa.prototype.writeUIntBE=function(e,t,n,r){(e=+e,t|=0,n|=0,r)||qa(this,e,t,n,Math.pow(2,8*n)-1,0);var o=n-1,i=1;for(this[t+o]=255&e;--o>=0&&(i*=256);)this[t+o]=e/i&255;return t+n},fa.prototype.writeUInt8=function(e,t,n){return e=+e,t|=0,n||qa(this,e,t,1,255,0),fa.TYPED_ARRAY_SUPPORT||(e=Math.floor(e)),this[t]=255&e,t+1},fa.prototype.writeUInt16LE=function(e,t,n){return e=+e,t|=0,n||qa(this,e,t,2,65535,0),fa.TYPED_ARRAY_SUPPORT?(this[t]=255&e,this[t+1]=e>>>8):xa(this,e,t,!0),t+2},fa.prototype.writeUInt16BE=function(e,t,n){return e=+e,t|=0,n||qa(this,e,t,2,65535,0),fa.TYPED_ARRAY_SUPPORT?(this[t]=e>>>8,this[t+1]=255&e):xa(this,e,t,!1),t+2},fa.prototype.writeUInt32LE=function(e,t,n){return e=+e,t|=0,n||qa(this,e,t,4,4294967295,0),fa.TYPED_ARRAY_SUPPORT?(this[t+3]=e>>>24,this[t+2]=e>>>16,this[t+1]=e>>>8,this[t]=255&e):Fa(this,e,t,!0),t+4},fa.prototype.writeUInt32BE=function(e,t,n){return e=+e,t|=0,n||qa(this,e,t,4,4294967295,0),fa.TYPED_ARRAY_SUPPORT?(this[t]=e>>>24,this[t+1]=e>>>16,this[t+2]=e>>>8,this[t+3]=255&e):Fa(this,e,t,!1),t+4},fa.prototype.writeIntLE=function(e,t,n,r){if(e=+e,t|=0,!r){var o=Math.pow(2,8*n-1);qa(this,e,t,n,o-1,-o)}var i=0,s=1,a=0;for(this[t]=255&e;++i<n&&(s*=256);)e<0&&0===a&&0!==this[t+i-1]&&(a=1),this[t+i]=(e/s>>0)-a&255;return t+n},fa.prototype.writeIntBE=function(e,t,n,r){if(e=+e,t|=0,!r){var o=Math.pow(2,8*n-1);qa(this,e,t,n,o-1,-o)}var i=n-1,s=1,a=0;for(this[t+i]=255&e;--i>=0&&(s*=256);)e<0&&0===a&&0!==this[t+i+1]&&(a=1),this[t+i]=(e/s>>0)-a&255;return t+n},fa.prototype.writeInt8=function(e,t,n){return e=+e,t|=0,n||qa(this,e,t,1,127,-128),fa.TYPED_ARRAY_SUPPORT||(e=Math.floor(e)),e<0&&(e=255+e+1),this[t]=255&e,t+1},fa.prototype.writeInt16LE=function(e,t,n){return e=+e,t|=0,n||qa(this,e,t,2,32767,-32768),fa.TYPED_ARRAY_SUPPORT?(this[t]=255&e,this[t+1]=e>>>8):xa(this,e,t,!0),t+2},fa.prototype.writeInt16BE=function(e,t,n){return e=+e,t|=0,n||qa(this,e,t,2,32767,-32768),fa.TYPED_ARRAY_SUPPORT?(this[t]=e>>>8,this[t+1]=255&e):xa(this,e,t,!1),t+2},fa.prototype.writeInt32LE=function(e,t,n){return e=+e,t|=0,n||qa(this,e,t,4,2147483647,-2147483648),fa.TYPED_ARRAY_SUPPORT?(this[t]=255&e,this[t+1]=e>>>8,this[t+2]=e>>>16,this[t+3]=e>>>24):Fa(this,e,t,!0),t+4},fa.prototype.writeInt32BE=function(e,t,n){return e=+e,t|=0,n||qa(this,e,t,4,2147483647,-2147483648),e<0&&(e=4294967295+e+1),fa.TYPED_ARRAY_SUPPORT?(this[t]=e>>>24,this[t+1]=e>>>16,this[t+2]=e>>>8,this[t+3]=255&e):Fa(this,e,t,!1),t+4},fa.prototype.writeFloatLE=function(e,t,n){return Ba(this,e,t,!0,n)},fa.prototype.writeFloatBE=function(e,t,n){return Ba(this,e,t,!1,n)},fa.prototype.writeDoubleLE=function(e,t,n){return Va(this,e,t,!0,n)},fa.prototype.writeDoubleBE=function(e,t,n){return Va(this,e,t,!1,n)},fa.prototype.copy=function(e,t,n,r){if(n||(n=0),r||0===r||(r=this.length),t>=e.length&&(t=e.length),t||(t=0),r>0&&r<n&&(r=n),r===n)return 0;if(0===e.length||0===this.length)return 0;if(t<0)throw new RangeError("targetStart out of bounds");if(n<0||n>=this.length)throw new RangeError("sourceStart out of bounds");if(r<0)throw new RangeError("sourceEnd out of bounds");r>this.length&&(r=this.length),e.length-t<r-n&&(r=e.length-t+n);var o,i=r-n;if(this===e&&n<t&&t<r)for(o=i-1;o>=0;--o)e[o+t]=this[o+n];else if(i<1e3||!fa.TYPED_ARRAY_SUPPORT)for(o=0;o<i;++o)e[o+t]=this[o+n];else Uint8Array.prototype.set.call(e,this.subarray(n,n+i),t);return i},fa.prototype.fill=function(e,t,n,r){if("string"==typeof e){if("string"==typeof t?(r=t,t=0,n=this.length):"string"==typeof n&&(r=n,n=this.length),1===e.length){var o=e.charCodeAt(0);o<256&&(e=o)}if(void 0!==r&&"string"!=typeof r)throw new TypeError("encoding must be a string");if("string"==typeof r&&!fa.isEncoding(r))throw new TypeError("Unknown encoding: "+r)}else"number"==typeof e&&(e&=255);if(t<0||this.length<t||this.length<n)throw new RangeError("Out of range index");if(n<=t)return this;var i;if(t>>>=0,n=void 0===n?this.length:n>>>0,e||(e=0),"number"==typeof e)for(i=t;i<n;++i)this[i]=e;else{var s=_a(e)?e:$a(new fa(e,r).toString()),a=s.length;for(i=0;i<n-t;++i)this[i+t]=s[i%a]}return this};var Ka=/[^+\/0-9A-Za-z-_]/g;function ja(e){return e<16?"0"+e.toString(16):e.toString(16)}function $a(e,t){var n;t=t||Infinity;for(var r=e.length,o=null,i=[],s=0;s<r;++s){if((n=e.charCodeAt(s))>55295&&n<57344){if(!o){if(n>56319){(t-=3)>-1&&i.push(239,191,189);continue}if(s+1===r){(t-=3)>-1&&i.push(239,191,189);continue}o=n;continue}if(n<56320){(t-=3)>-1&&i.push(239,191,189),o=n;continue}n=65536+(o-55296<<10|n-56320)}else o&&(t-=3)>-1&&i.push(239,191,189);if(o=null,n<128){if((t-=1)<0)break;i.push(n)}else if(n<2048){if((t-=2)<0)break;i.push(n>>6|192,63&n|128)}else if(n<65536){if((t-=3)<0)break;i.push(n>>12|224,n>>6&63|128,63&n|128)}else{if(!(n<1114112))throw new Error("Invalid code point");if((t-=4)<0)break;i.push(n>>18|240,n>>12&63|128,n>>6&63|128,63&n|128)}}return i}function Ya(e){return function(e){var t,n,r,o,i,s;ra||oa();var a=e.length;if(a%4>0)throw new Error("Invalid string. Length must be a multiple of 4");i="="===e[a-2]?2:"="===e[a-1]?1:0,s=new na(3*a/4-i),r=i>0?a-4:a;var u=0;for(t=0,n=0;t<r;t+=4,n+=3)o=ta[e.charCodeAt(t)]<<18|ta[e.charCodeAt(t+1)]<<12|ta[e.charCodeAt(t+2)]<<6|ta[e.charCodeAt(t+3)],s[u++]=o>>16&255,s[u++]=o>>8&255,s[u++]=255&o;return 2===i?(o=ta[e.charCodeAt(t)]<<2|ta[e.charCodeAt(t+1)]>>4,s[u++]=255&o):1===i&&(o=ta[e.charCodeAt(t)]<<10|ta[e.charCodeAt(t+1)]<<4|ta[e.charCodeAt(t+2)]>>2,s[u++]=o>>8&255,s[u++]=255&o),s}(function(e){if((e=function(e){return e.trim?e.trim():e.replace(/^\s+|\s+$/g,"")}(e).replace(Ka,"")).length<2)return"";for(;e.length%4!=0;)e+="=";return e}(e))}function za(e,t,n,r){for(var o=0;o<r&&!(o+n>=t.length||o>=e.length);++o)t[o+n]=e[o];return o}function Wa(e){return!!e.constructor&&"function"==typeof e.constructor.isBuffer&&e.constructor.isBuffer(e)}var Xa=function(e){c(n,e);var t=y(n);function n(){var e;return r(this,n),(e=t.call(this)).retry=2,e._request=e.promisify(wx.request),e}return i(n,[{key:"request",value:function(e){return this._checkOptions(e),this._initOptions(e),e=u({},e,{responseType:"text"}),this._requestWithRetry(e)}},{key:"_requestWithRetry",value:function(e){var t=this,n=arguments.length>1&&void 0!==arguments[1]?arguments[1]:0;return this._request(e).then(this._handleResolve).catch((function(r){if(ee(r.errMsg)){if(r.errMsg.includes("abort"))return zo({});if(r.errMsg.includes("timeout"))return t.retry>0&&n<t.retry?t._requestWithRetry(e,++n):Wo(new pt({code:cn,message:r.errMsg}));if(r.errMsg.includes("fail"))return t.retry>0&&n<t.retry?t._requestWithRetry(e,++n):Wo(new pt({code:un,message:r.errMsg}))}return Wo(new pt(u({code:yn,message:r.message},r)))}))}},{key:"_handleResolve",value:function(e){var t=e.data,n=t.error_code,r=t.ErrorCode;return"number"==typeof n&&(r=n),r!==Ne.SUCCESS&&(e.data.ErrorCode=Number("".concat(r))),e}},{key:"promisify",value:function(e){return function(t){return new Promise((function(n,r){var o=e(Object.assign({},t,{success:n,fail:r}));t.updateAbort&&t.updateAbort((function(){o&&se(o.abort)&&o.abort()}))}))}}}]),n}(Qs),Ja=function(){function e(){r(this,e),this.request=0,this.success=0,this.fail=0,this.reportRate=10,this.requestTimeCost=[]}return i(e,[{key:"report",value:function(){if(1!==this.request){if(this.request%this.reportRate!=0)return null;var e=this.avgRequestTime(),t="runLoop reports: success=".concat(this.success,",fail=").concat(this.fail,",total=").concat(this.request,",avg=").concat(e,",cur=").concat(this.requestTimeCost[this.requestTimeCost.length-1],",max=").concat(Math.max.apply(null,this.requestTimeCost),",min=").concat(Math.min.apply(null,this.requestTimeCost));J.log(t)}}},{key:"setRequestTime",value:function(e,t){var n=Math.abs(t-e);100===this.requestTimeCost.length&&this.requestTimeCost.shift(),this.requestTimeCost.push(n)}},{key:"avgRequestTime",value:function(){for(var e,t=this.requestTimeCost.length,n=0,r=0;r<t;r++)n+=this.requestTimeCost[r];return e=n/t,Math.round(100*e)/100}}]),e}(),Qa=Xs.create({timeout:6e3,headers:{"Content-Type":"application/x-www-form-urlencoded;charset=UTF-8"}});Qa.interceptors.response.use((function(e){var t=e.data,n=t.error_code,r=t.ErrorCode;return Z(n)&&(r=n),r!==Ne.SUCCESS&&(e.data.ErrorCode=Number(r)),e}),(function(e){return"Network Error"===e.message&&(!0===Qa.defaults.withCredentials&&J.warn("Network Error, try to close `IMAxiosAVChatroom.defaults.withCredentials` to false. (IMAxiosAVChatroom.js)"),Qa.defaults.withCredentials=!1),Promise.reject(e)}));var Za=Xs.CancelToken,eu=function(){function e(t){r(this,e),this._initializeOptions(t),this._initializeMembers(),this.status=new Ja}return i(e,[{key:"destructor",value:function(){clearTimeout(this._seedID);var e=this._index();for(var t in this)Object.prototype.hasOwnProperty.call(this,t)&&(this[t]=null);return e}},{key:"setIndex",value:function(e){this._index=e}},{key:"getIndex",value:function(){return this._index}},{key:"isRunning",value:function(){return!this._stoped}},{key:"_initializeOptions",value:function(e){this.options=e}},{key:"_initializeMembers",value:function(){this._index=-1,this._seedID=0,this._requestStatus=!1,this._stoped=!1,this._intervalTime=0,this._intervalIncreaseStep=1e3,this._intervalDecreaseStep=1e3,this._intervalTimeMax=5e3,this._protectTimeout=3e3,this._getNoticeSeq=this.options.getNoticeSeq,this._retryCount=0,this._responseTime=Date.now(),this._responseTimeThreshold=2e3,this.options.isAVChatRoomLoop?this.requestor=Qa:this.requestor=Js,J.log("XHRRunLoop._initializeMembers isAVChatRoomLoop=".concat(!!this.options.isAVChatRoomLoop)),this.abort=null}},{key:"start",value:function(){0===this._seedID?(this._stoped=!1,this._send()):J.log('XHRRunLoop.start(), XHRRunLoop is running now, if you want to restart runLoop , please run "stop()" first.')}},{key:"_reset",value:function(){J.log("XHRRunLoop._reset(), reset long poll _intervalTime",this._intervalTime),this.stop(),this.start()}},{key:"_intervalTimeIncrease",value:function(){this._intervalTime!==this._responseTimeThreshold&&(this._intervalTime<this._responseTimeThreshold&&(this._intervalTime+=this._intervalIncreaseStep),this._intervalTime>this._responseTimeThreshold&&(this._intervalTime=this._responseTimeThreshold))}},{key:"_intervalTimeDecrease",value:function(){0!==this._intervalTime&&(this._intervalTime>0&&(this._intervalTime-=this._intervalDecreaseStep),this._intervalTime<0&&(this._intervalTime=0))}},{key:"_intervalTimeAdjustment",value:function(){var e=Date.now();100*Math.floor((e-this._responseTime)/100)<=this._responseTimeThreshold?this._intervalTimeIncrease():this._intervalTimeDecrease(),this._responseTime=e}},{key:"_intervalTimeAdjustmentBaseOnResponseData",value:function(e){e.ErrorCode===Ne.SUCCESS?this._intervalTimeDecrease():this._intervalTimeIncrease()}},{key:"_send",value:function(){var e=this;if(!0!==this._requestStatus){this._requestStatus=!0,this.status.request++,"function"==typeof this.options.before&&this.options.before(this.options.pack.requestData);var t=Date.now(),n=0;this.requestor.request({url:this.options.pack.getUrl(),data:this.options.pack.requestData,method:this.options.pack.method,cancelToken:new Za((function(t){e.abort=t}))}).then((function(r){if(e._intervalTimeAdjustmentBaseOnResponseData.bind(e)(r.data),e._retryCount>0&&(e._retryCount=0),e.status.success++,n=Date.now(),e.status.setRequestTime(t,n),r.data.timecost=n-t,"function"==typeof e.options.success)try{e.options.success({pack:e.options.pack,error:!1,data:e.options.pack.callback(r.data)})}catch(o){J.warn("XHRRunLoop._send(), error:",o)}e._requestStatus=!1,!1===e._stoped&&(e._seedID=setTimeout(e._send.bind(e),e._intervalTime)),e.status.report()})).catch((function(r){if(e.status.fail++,e._retryCount++,e._intervalTimeAdjustment.bind(e)(),!1===e._stoped&&(e._seedID=setTimeout(e._send.bind(e),e._intervalTime)),e._requestStatus=!1,"function"==typeof e.options.fail&&void 0!==r.request)try{e.options.fail({pack:e.options.pack,error:r,data:!1})}catch(o){J.warn("XHRRunLoop._send(), fail callback error:"),J.error(o)}n=Date.now(),e.status.setRequestTime(t,n),e.status.report()}))}}},{key:"stop",value:function(){this._clearAllTimeOut(),this._stoped=!0}},{key:"_clearAllTimeOut",value:function(){clearTimeout(this._seedID),this._seedID=0}}]),e}(),tu=function(){function e(t){r(this,e),this._initializeOptions(t),this._initializeMembers(),this.status=new Ja}return i(e,[{key:"destructor",value:function(){clearTimeout(this._seedID);var e=this._index();for(var t in this)Object.prototype.hasOwnProperty.call(this,t)&&(this[t]=null);return e}},{key:"setIndex",value:function(e){this._index=e}},{key:"isRunning",value:function(){return!this._stoped}},{key:"getIndex",value:function(){return this._index}},{key:"_initializeOptions",value:function(e){this.options=e}},{key:"_initializeMembers",value:function(){this._index=-1,this._seedID=0,this._requestStatus=!1,this._stoped=!1,this._intervalTime=0,this._intervalIncreaseStep=1e3,this._intervalDecreaseStep=1e3,this._intervalTimeMax=5e3,this._protectTimeout=3e3,this._getNoticeSeq=this.options.getNoticeSeq,this._retryCount=0,this._responseTime=Date.now(),this._responseTimeThreshold=2e3,this.requestor=new Xa,this.abort=null}},{key:"start",value:function(){0===this._seedID?(this._stoped=!1,this._send()):J.log('WXRunLoop.start(): WXRunLoop is running now, if you want to restart runLoop , please run "stop()" first.')}},{key:"_reset",value:function(){J.log("WXRunLoop.reset(), long poll _intervalMaxRate",this._intervalMaxRate),this.stop(),this.start()}},{key:"_intervalTimeIncrease",value:function(){this._intervalTime!==this._responseTimeThreshold&&(this._intervalTime<this._responseTimeThreshold&&(this._intervalTime+=this._intervalIncreaseStep),this._intervalTime>this._responseTimeThreshold&&(this._intervalTime=this._responseTimeThreshold))}},{key:"_intervalTimeDecrease",value:function(){0!==this._intervalTime&&(this._intervalTime>0&&(this._intervalTime-=this._intervalDecreaseStep),this._intervalTime<0&&(this._intervalTime=0))}},{key:"_intervalTimeAdjustment",value:function(){var e=Date.now();100*Math.floor((e-this._responseTime)/100)<=this._responseTimeThreshold?this._intervalTimeIncrease():this._intervalTimeDecrease(),this._responseTime=e}},{key:"_intervalTimeAdjustmentBaseOnResponseData",value:function(e){e.ErrorCode===Ne.SUCCESS?this._intervalTimeDecrease():this._intervalTimeIncrease()}},{key:"_send",value:function(){var e=this;if(!0!==this._requestStatus){var t=this;this._requestStatus=!0,this.status.request++,"function"==typeof this.options.before&&this.options.before(t.options.pack.requestData);var n=Date.now(),r=0;this.requestor.request({url:t.options.pack.getUrl(),data:t.options.pack.requestData,method:t.options.pack.method,updateAbort:function(t){e.abort=t}}).then((function(o){if(t._intervalTimeAdjustmentBaseOnResponseData.bind(e)(o.data),t._retryCount>0&&(t._retryCount=0),e.status.success++,r=Date.now(),e.status.setRequestTime(n,r),o.data.timecost=r-n,"function"==typeof t.options.success)try{e.options.success({pack:e.options.pack,error:!1,data:e.options.pack.callback(o.data)})}catch(i){J.warn("WXRunLoop._send(), error:",i)}t._requestStatus=!1,!1===t._stoped&&(t._seedID=setTimeout(t._send.bind(t),t._intervalTime)),e.status.report()})).catch((function(o){if(e.status.fail++,t._retryCount++,t._intervalTimeAdjustment.bind(e)(),!1===t._stoped&&(t._seedID=setTimeout(t._send.bind(t),t._intervalTime)),t._requestStatus=!1,"function"==typeof t.options.fail)try{e.options.fail({pack:e.options.pack,error:o,data:!1})}catch(i){J.warn("WXRunLoop._send(), fail callback error:"),J.error(i)}r=Date.now(),e.status.setRequestTime(n,r),e.status.report()}))}}},{key:"stop",value:function(){this._clearAllTimeOut(),this._stoped=!0}},{key:"_clearAllTimeOut",value:function(){clearTimeout(this._seedID),this._seedID=0}}]),e}(),nu=function(){function e(t){r(this,e),this.tim=t,this.httpConnection=O?new Xa:new Zs,this.keepAliveConnections=[]}return i(e,[{key:"initializeListener",value:function(){this.tim.innerEmitter.on(To,this._stopAllRunLoop,this)}},{key:"request",value:function(e){var t={url:e.url,data:e.requestData,method:e.method,callback:e.callback};return this.httpConnection.request(t).then((function(t){return t.data=e.callback(t.data),t.data.errorCode!==Ne.SUCCESS?Wo(new pt({code:t.data.errorCode,message:t.data.errorInfo})):t}))}},{key:"createRunLoop",value:function(e){var t=this.createKeepAliveConnection(e);return t.setIndex(this.keepAliveConnections.push(t)-1),t}},{key:"stopRunLoop",value:function(e){e.stop()}},{key:"_stopAllRunLoop",value:function(){for(var e=this.keepAliveConnections.length,t=0;t<e;t++)this.keepAliveConnections[t].stop()}},{key:"destroyRunLoop",value:function(e){e.stop();var t=e.destructor();this.keepAliveConnections.slice(t,1)}},{key:"startRunLoopExclusive",value:function(e){for(var t=e.getIndex(),n=0;n<this.keepAliveConnections.length;n++)n!==t&&this.keepAliveConnections[n].stop();e.start()}},{key:"createKeepAliveConnection",value:function(e){return O?new tu(e):(this.tim.options.runLoopNetType===Xe||this.tim.options.runLoopNetType,new eu(e))}},{key:"clearAll",value:function(){this.conn.cancelAll()}},{key:"reset",value:function(){this.keepAliveConnections=[]}}]),e}(),ru=function(){function t(e){r(this,t),this.tim=e,this.tim.innerEmitter.on(wo,this._onErrorDetected,this)}return i(t,[{key:"_onErrorDetected",value:function(t){var n=t.data;n.code?J.warn("Oops! code:".concat(n.code," message:").concat(n.message)):J.warn("Oops! message:".concat(n.message," stack:").concat(n.stack)),this.tim.outerEmitter.emit(e.ERROR,n)}}]),t}(),ou=function(){function e(n){var o=this;r(this,e),Ae(n)||(this.userID=n.userID||"",this.nick=n.nick||"",this.gender=n.gender||"",this.birthday=n.birthday||0,this.location=n.location||"",this.selfSignature=n.selfSignature||"",this.allowType=n.allowType||t.ALLOW_TYPE_ALLOW_ANY,this.language=n.language||0,this.avatar=n.avatar||"",this.messageSettings=n.messageSettings||0,this.adminForbidType=n.adminForbidType||t.FORBID_TYPE_NONE,this.level=n.level||0,this.role=n.role||0,this.lastUpdatedTime=0,this.profileCustomField=[],Ae(n.profileCustomField)||n.profileCustomField.forEach((function(e){o.profileCustomField.push({key:e.key,value:e.value})})))}return i(e,[{key:"validate",value:function(e){var t=!0,n="";if(Ae(e))return{valid:!1,tips:"empty options"};if(e.profileCustomField)for(var r=e.profileCustomField.length,o=null,i=0;i<r;i++){if(o=e.profileCustomField[i],!ee(o.key)||-1===o.key.indexOf("Tag_Profile_Custom"))return{valid:!1,tips:"自定义资料字段的前缀必须是 Tag_Profile_Custom"};if(!ee(o.value))return{valid:!1,tips:"自定义资料字段的 value 必须是字符串"}}for(var s in e)if(Object.prototype.hasOwnProperty.call(e,s)){if("profileCustomField"===s)continue;if(Ae(e[s])&&!ee(e[s])&&!Z(e[s])){n="key:"+s+", invalid value:"+e[s],t=!1;continue}switch(s){case"nick":ee(e[s])||(n="nick should be a string",t=!1),ge(e[s])>500&&(n="nick name limited: must less than or equal to ".concat(500," bytes, current size: ").concat(ge(e[s])," bytes"),t=!1);break;case"gender":_e(et,e.gender)||(n="key:gender, invalid value:"+e.gender,t=!1);break;case"birthday":Z(e.birthday)||(n="birthday should be a number",t=!1);break;case"location":ee(e.location)||(n="location should be a string",t=!1);break;case"selfSignature":ee(e.selfSignature)||(n="selfSignature should be a string",t=!1);break;case"allowType":_e(nt,e.allowType)||(n="key:allowType, invalid value:"+e.allowType,t=!1);break;case"language":Z(e.language)||(n="language should be a number",t=!1);break;case"avatar":ee(e.avatar)||(n="avatar should be a string",t=!1);break;case"messageSettings":0!==e.messageSettings&&1!==e.messageSettings&&(n="messageSettings should be 0 or 1",t=!1);break;case"adminForbidType":_e(tt,e.adminForbidType)||(n="key:adminForbidType, invalid value:"+e.adminForbidType,t=!1);break;case"level":Z(e.level)||(n="level should be a number",t=!1);break;case"role":Z(e.role)||(n="role should be a number",t=!1);break;default:n="unknown key:"+s+"  "+e[s],t=!1}}return{valid:t,tips:n}}}]),e}(),iu=function(){function t(e){r(this,t),this.userController=e,this.TAG="profile",this.Actions={Q:"query",U:"update"},this.accountProfileMap=new Map,this.expirationTime=864e5}return i(t,[{key:"setExpirationTime",value:function(e){this.expirationTime=e}},{key:"getUserProfile",value:function(e){var t=this,n=e.userIDList;e.fromAccount=this.userController.getMyAccount(),n.length>100&&(J.warn("ProfileHandler.getUserProfile 获取用户资料人数不能超过100人"),n.length=100);for(var r,o=[],i=[],s=0,a=n.length;s<a;s++)r=n[s],this.userController.isMyFriend(r)&&this._containsAccount(r)?i.push(this._getProfileFromMap(r)):o.push(r);if(0===o.length)return zo(i);e.toAccount=o;var u=e.bFromGetMyProfile||!1,c=[];e.toAccount.forEach((function(e){c.push({toAccount:e,standardSequence:0,customSequence:0})})),e.userItem=c;var l=new oi;l.setMethod(qi).setStart();var p=this.userController.generateConfig(this.TAG,this.Actions.Q,e);return this.userController.request(p).then((function(e){l.setCode(0).setNetworkType(t.userController.getNetworkType()).setText(e.data.userProfileItem.length).setEnd(),J.info("ProfileHandler.getUserProfile ok");var n=t._handleResponse(e).concat(i);return u?(t.userController.onGotMyProfile(),new jo(n[0])):new jo(n)})).catch((function(e){return t.userController.probeNetwork().then((function(t){var n=v(t,2),r=n[0],o=n[1];l.setError(e,r,o).setEnd()})),J.error("ProfileHandler.getUserProfile error:",e),Wo(e)}))}},{key:"getMyProfile",value:function(){var e=this.userController.getMyAccount();if(J.log("ProfileHandler.getMyProfile myAccount="+e),this._fillMap(),this._containsAccount(e)){var t=this._getProfileFromMap(e);return J.debug("ProfileHandler.getMyProfile from cache, myProfile:"+JSON.stringify(t)),this.userController.onGotMyProfile(),zo(t)}return this.getUserProfile({fromAccount:e,userIDList:[e],bFromGetMyProfile:!0})}},{key:"_handleResponse",value:function(e){for(var t,n,r=pe.now(),o=e.data.userProfileItem,i=[],s=0,a=o.length;s<a;s++)"@TLS#NOT_FOUND"!==o[s].to&&""!==o[s].to&&(t=o[s].to,n=this._updateMap(t,this._getLatestProfileFromResponse(t,o[s].profileItem)),i.push(n));return J.log("ProfileHandler._handleResponse cost "+(pe.now()-r)+" ms"),i}},{key:"_getLatestProfileFromResponse",value:function(e,t){var n={};if(n.userID=e,n.profileCustomField=[],!Ae(t))for(var r=0,o=t.length;r<o;r++)if(t[r].tag.indexOf("Tag_Profile_Custom")>-1)n.profileCustomField.push({key:t[r].tag,value:t[r].value});else switch(t[r].tag){case Ze.NICK:n.nick=t[r].value;break;case Ze.GENDER:n.gender=t[r].value;break;case Ze.BIRTHDAY:n.birthday=t[r].value;break;case Ze.LOCATION:n.location=t[r].value;break;case Ze.SELFSIGNATURE:n.selfSignature=t[r].value;break;case Ze.ALLOWTYPE:n.allowType=t[r].value;break;case Ze.LANGUAGE:n.language=t[r].value;break;case Ze.AVATAR:n.avatar=t[r].value;break;case Ze.MESSAGESETTINGS:n.messageSettings=t[r].value;break;case Ze.ADMINFORBIDTYPE:n.adminForbidType=t[r].value;break;case Ze.LEVEL:n.level=t[r].value;break;case Ze.ROLE:n.role=t[r].value;break;default:J.warn("ProfileHandler._handleResponse unkown tag->",t[r].tag,t[r].value)}return n}},{key:"updateMyProfile",value:function(t){var n=this,r=(new ou).validate(t);if(!r.valid)return J.error("ProfileHandler.updateMyProfile info:".concat(r.tips,"，请参考 https://imsdk-1252463788.file.myqcloud.com/IM_DOC/Web/SDK.html#updateMyProfile")),Wo({code:nn,message:fr});var o=[];for(var i in t)Object.prototype.hasOwnProperty.call(t,i)&&("profileCustomField"===i?t.profileCustomField.forEach((function(e){o.push({tag:e.key,value:e.value})})):o.push({tag:Ze[i.toUpperCase()],value:t[i]}));if(0===o.length)return J.error("ProfileHandler.updateMyProfile info:".concat(dr,"，请参考 https://imsdk-1252463788.file.myqcloud.com/IM_DOC/Web/SDK.html#updateMyProfile")),Wo({code:rn,message:dr});var s=this.userController.generateConfig(this.TAG,this.Actions.U,{fromAccount:this.userController.getMyAccount(),profileItem:o});return this.userController.request(s).then((function(r){J.info("ProfileHandler.updateMyProfile ok");var o=n._updateMap(n.userController.getMyAccount(),t);return n.userController.emitOuterEvent(e.PROFILE_UPDATED,[o]),zo(o)})).catch((function(e){return J.error("ProfileHandler.updateMyProfile error:",e),Wo(e)}))}},{key:"onProfileModified",value:function(t){var n=t.data;if(!Ae(n)){var r,o,i=n.length;J.info("ProfileHandler.onProfileModified length="+i);for(var s=[],a=0;a<i;a++)r=n[a].userID,o=this._updateMap(r,this._getLatestProfileFromResponse(r,n[a].profileList)),s.push(o);this.userController.emitInnerEvent(Lo,s),this.userController.emitOuterEvent(e.PROFILE_UPDATED,s)}}},{key:"_fillMap",value:function(){if(0===this.accountProfileMap.size){for(var e=this._getCachedProfiles(),t=Date.now(),n=0,r=e.length;n<r;n++)t-e[n].lastUpdatedTime<this.expirationTime&&this.accountProfileMap.set(e[n].userID,e[n]);J.log("ProfileHandler._fillMap from cache, map.size="+this.accountProfileMap.size)}}},{key:"_updateMap",value:function(e,t){var n,r=Date.now();return this._containsAccount(e)?(n=this._getProfileFromMap(e),t.profileCustomField&&Se(n.profileCustomField,t.profileCustomField),he(n,t,["profileCustomField"]),n.lastUpdatedTime=r):(n=new ou(t),(this.userController.isMyFriend(e)||e===this.userController.getMyAccount())&&(n.lastUpdatedTime=r,this.accountProfileMap.set(e,n))),this._flushMap(e===this.userController.getMyAccount()),n}},{key:"_flushMap",value:function(e){var t=_(this.accountProfileMap.values()),n=this.userController.tim.storage;J.debug("ProfileHandler._flushMap length=".concat(t.length," flushAtOnce=").concat(e)),n.setItem(this.TAG,t,e)}},{key:"_containsAccount",value:function(e){return this.accountProfileMap.has(e)}},{key:"_getProfileFromMap",value:function(e){return this.accountProfileMap.get(e)}},{key:"_getCachedProfiles",value:function(){var e=this.userController.tim.storage.getItem(this.TAG);return Ae(e)?[]:e}},{key:"onConversationsProfileUpdated",value:function(e){for(var t,n,r,o=[],i=0,s=e.length;i<s;i++)n=(t=e[i]).userID,this.userController.isMyFriend(n)&&(this._containsAccount(n)?(r=this._getProfileFromMap(n),he(r,t)>0&&o.push(n)):o.push(t.userID));0!==o.length&&(J.info("ProfileHandler.onConversationsProfileUpdated toAccount:",o),this.getUserProfile({userIDList:o}))}},{key:"reset",value:function(){this._flushMap(!0),this.accountProfileMap.clear()}}]),t}(),su=function(){function e(t){r(this,e),this.options=t?t.options:{enablePointer:!0},this.pointsList={},this.reportText={},this.maxNameLen=0,this.gapChar="-",this.log=console.log,this.currentTask=""}return i(e,[{key:"newTask",value:function(e){!1!==this.options.enablePointer&&(e||(e=["task",this._timeFormat()].join("-")),this.pointsList[e]=[],this.currentTask=e,console.log("Pointer new Task : ".concat(this.currentTask)))}},{key:"deleteTask",value:function(e){!1!==this.options.enablePointer&&(e||(e=this.currentTask),this.pointsList[e].length=0,delete this.pointsList[e])}},{key:"dot",value:function(){var e=arguments.length>0&&void 0!==arguments[0]?arguments[0]:"",t=arguments.length>1?arguments[1]:void 0;if(!1!==this.options.enablePointer){t=t||this.currentTask;var n=+new Date;this.maxNameLen=this.maxNameLen<e.length?e.length:this.maxNameLen,this.flen=this.maxNameLen+10,this.pointsList[t].push({pointerName:e,time:n})}}},{key:"_analisys",value:function(e){if(!1!==this.options.enablePointer){e=e||this.currentTask;for(var t=this.pointsList[e],n=t.length,r=[],o=[],i=0;i<n;i++)0!==i&&(o=this._analisysTowPoints(t[i-1],t[i]),r.push(o.join("")));return o=this._analisysTowPoints(t[0],t[n-1],!0),r.push(o.join("")),r.join("")}}},{key:"_analisysTowPoints",value:function(e,t){var n=arguments.length>2&&void 0!==arguments[2]&&arguments[2];if(!1!==this.options.enablePointer){var r=this.flen,o=t.time-e.time,i=o.toString(),s=e.pointerName+this.gapChar.repeat(r-e.pointerName.length),a=t.pointerName+this.gapChar.repeat(r-t.pointerName.length),u=this.gapChar.repeat(4-i.length)+i,c=n?["%c",s,a,u,"ms\n%c"]:[s,a,u,"ms\n"];return c}}},{key:"report",value:function(e){if(!1!==this.options.enablePointer){e=e||this.currentTask;var t=this._analisys(e);this.pointsList=[];var n=this._timeFormat(),r="Pointer[".concat(e,"(").concat(n,")]"),o=4*this.maxNameLen,i=(o-r.length)/2;console.log(["-".repeat(i),r,"-".repeat(i)].join("")),console.log("%c"+t,"color:#66a","color:red","color:#66a"),console.log("-".repeat(o))}}},{key:"_timeFormat",value:function(){var e=new Date,t=this.zeroFix(e.getMonth()+1,2),n=this.zeroFix(e.getDate(),2);return"".concat(t,"-").concat(n," ").concat(e.getHours(),":").concat(e.getSeconds(),":").concat(e.getMinutes(),"~").concat(e.getMilliseconds())}},{key:"zeroFix",value:function(e,t){return("000000000"+e).slice(-t)}},{key:"reportAll",value:function(){if(!1!==this.options.enablePointer)for(var e in this.pointsList)Object.prototype.hasOwnProperty.call(this.pointsList,e)&&this.eport(e)}}]),e}(),au=function e(t,n){r(this,e),this.userID=t;var o={};if(o.userID=t,!Ae(n))for(var i=0,s=n.length;i<s;i++)switch(n[i].tag){case Ze.NICK:o.nick=n[i].value;break;case Ze.GENDER:o.gender=n[i].value;break;case Ze.BIRTHDAY:o.birthday=n[i].value;break;case Ze.LOCATION:o.location=n[i].value;break;case Ze.SELFSIGNATURE:o.selfSignature=n[i].value;break;case Ze.ALLOWTYPE:o.allowType=n[i].value;break;case Ze.LANGUAGE:o.language=n[i].value;break;case Ze.AVATAR:o.avatar=n[i].value;break;case Ze.MESSAGESETTINGS:o.messageSettings=n[i].value;break;case Ze.ADMINFORBIDTYPE:o.adminForbidType=n[i].value;break;case Ze.LEVEL:o.level=n[i].value;break;case Ze.ROLE:o.role=n[i].value;break;default:J.debug("snsProfileItem unkown tag->",n[i].tag)}this.profile=new ou(o)},uu=function(){function e(t){r(this,e),this.userController=t,this.TAG="friend",this.Actions={G:"get",D:"delete"},this.friends=new Map,this.pointer=new su}return i(e,[{key:"isMyFriend",value:function(e){var t=this.friends.has(e);return t||J.debug("FriendHandler.isMyFriend "+e+" is not my friend"),t}},{key:"_transformFriendList",value:function(e){if(!Ae(e)&&!Ae(e.infoItem)){J.info("FriendHandler._transformFriendList friendNum="+e.friendNum);for(var t,n,r=e.infoItem,o=0,i=r.length;o<i;o++)n=r[o].infoAccount,t=new au(n,r[o].snsProfileItem),this.friends.set(n,t)}}},{key:"_friends2map",value:function(e){var t=new Map;for(var n in e)Object.prototype.hasOwnProperty.call(e,n)&&t.set(n,e[n]);return t}},{key:"getFriendList",value:function(){var e=this,t={};t.fromAccount=this.userController.getMyAccount(),J.info("FriendHandler.getFriendList myAccount="+t.fromAccount);var n=this.userController.generateConfig(this.TAG,this.Actions.G,t);return this.userController.request(n).then((function(t){J.info("FriendHandler.getFriendList ok"),e._transformFriendList(t.data);var n=_(e.friends.values());return zo(n)})).catch((function(e){return J.error("FriendHandler.getFriendList error:",JSON.stringify(e)),Wo(e)}))}},{key:"deleteFriend",value:function(e){if(!Array.isArray(e.toAccount))return J.error("FriendHandler.deleteFriend options.toAccount 必需是数组"),Wo({code:tn,message:hr});e.toAccount.length>1e3&&(J.warn("FriendHandler.deleteFriend 删除好友人数不能超过1000人"),e.toAccount.length=1e3);var t=this.userController.generateConfig(this.TAG,this.Actions.D,e);return this.userController.request(t).then((function(e){return J.info("FriendHandler.deleteFriend ok"),zo()})).catch((function(e){return J.error("FriendHandler.deleteFriend error:",e),Wo(e)}))}}]),e}(),cu=function e(t){r(this,e),Ae||(this.userID=t.userID||"",this.timeStamp=t.timeStamp||0)},lu=function(){function t(e){r(this,t),this.userController=e,this.TAG="blacklist",this.Actions={G:"get",C:"create",D:"delete"},this.blacklistMap=new Map,this.startIndex=0,this.maxLimited=100,this.curruentSequence=0}return i(t,[{key:"getBlacklist",value:function(){var e=this,t={};t.fromAccount=this.userController.getMyAccount(),t.maxLimited=this.maxLimited,t.startIndex=0,t.lastSequence=this.curruentSequence;var n=new oi;n.setMethod(xi).setStart();var r=this.userController.generateConfig(this.TAG,this.Actions.G,t);return this.userController.request(r).then((function(t){var r=Ae(t.data.blackListItem)?0:t.data.blackListItem.length;return n.setCode(0).setNetworkType(e.userController.getNetworkType()).setText(r).setEnd(),J.info("BlacklistHandler.getBlacklist ok"),e.curruentSequence=t.data.curruentSequence,e._handleResponse(t.data.blackListItem,!0),e._onBlacklistUpdated()})).catch((function(t){return e.userController.probeNetwork().then((function(e){var r=v(e,2),o=r[0],i=r[1];n.setError(t,o,i).setEnd()})),J.error("BlacklistHandler.getBlacklist error:",t),Wo(t)}))}},{key:"addBlacklist",value:function(e){var t=this;if(!re(e.userIDList))return J.error("BlacklistHandler.addBlacklist options.userIDList 必需是数组"),Wo({code:on,message:gr});var n=this.userController.tim.loginInfo.identifier;if(1===e.userIDList.length&&e.userIDList[0]===n)return J.error("BlacklistHandler.addBlacklist 不能把自己拉黑"),Wo({code:an,message:yr});e.userIDList.includes(n)&&(e.userIDList=e.userIDList.filter((function(e){return e!==n})),J.warn("BlacklistHandler.addBlacklist 不能把自己拉黑，已过滤")),e.fromAccount=this.userController.getMyAccount(),e.toAccount=e.userIDList;var r=this.userController.generateConfig(this.TAG,this.Actions.C,e);return this.userController.request(r).then((function(e){return J.info("BlacklistHandler.addBlacklist ok"),t._handleResponse(e.data.resultItem,!0),t._onBlacklistUpdated()})).catch((function(e){return J.error("BlacklistHandler.addBlacklist error:",e),Wo(e)}))}},{key:"_handleResponse",value:function(e,t){if(!Ae(e))for(var n,r,o,i=0,s=e.length;i<s;i++)r=e[i].to,o=e[i].resultCode,(oe(o)||0===o)&&(t?((n=this.blacklistMap.has(r)?this.blacklistMap.get(r):new cu).userID=r,!Ae(e[i].addBlackTimeStamp)&&(n.timeStamp=e[i].addBlackTimeStamp),this.blacklistMap.set(r,n)):this.blacklistMap.has(r)&&(n=this.blacklistMap.get(r),this.blacklistMap.delete(r)));J.log("BlacklistHandler._handleResponse total="+this.blacklistMap.size+" bAdd="+t)}},{key:"deleteBlacklist",value:function(e){var t=this;if(!re(e.userIDList))return J.error("BlacklistHandler.deleteBlacklist options.userIDList 必需是数组"),Wo({code:sn,message:mr});e.fromAccount=this.userController.getMyAccount(),e.toAccount=e.userIDList;var n=this.userController.generateConfig(this.TAG,this.Actions.D,e);return this.userController.request(n).then((function(e){return J.info("BlacklistHandler.deleteBlacklist ok"),t._handleResponse(e.data.resultItem,!1),t._onBlacklistUpdated()})).catch((function(e){return J.error("BlacklistHandler.deleteBlacklist error:",e),Wo(e)}))}},{key:"_onBlacklistUpdated",value:function(){var t=_(this.blacklistMap.keys());return this.userController.emitOuterEvent(e.BLACKLIST_UPDATED,t),zo(t)}},{key:"handleBlackListDelAccount",value:function(t){for(var n,r=[],o=0,i=t.length;o<i;o++)n=t[o],this.blacklistMap.has(n)&&(this.blacklistMap.delete(n),r.push(n));r.length>0&&(J.log("BlacklistHandler.handleBlackListDelAccount delCount="+r.length+" : "+r.join(",")),this.userController.emitOuterEvent(e.BLACKLIST_UPDATED,_(this.blacklistMap.keys())))}},{key:"handleBlackListAddAccount",value:function(t){for(var n,r=[],o=0,i=t.length;o<i;o++)n=t[o],this.blacklistMap.has(n)||(this.blacklistMap.set(n,new cu({userID:n})),r.push(n));r.length>0&&(J.log("BlacklistHandler.handleBlackListAddAccount addCount="+r.length+" : "+r.join(",")),this.userController.emitOuterEvent(e.BLACKLIST_UPDATED,_(this.blacklistMap.keys())))}},{key:"reset",value:function(){this.blacklistMap.clear(),this.startIndex=0,this.maxLimited=100,this.curruentSequence=0}}]),t}(),pu=function(){function e(t){r(this,e),this.userController=t,this.TAG="applyC2C",this.Actions={C:"create",G:"get",D:"delete",U:"update"}}return i(e,[{key:"applyAddFriend",value:function(e){var t=this,n=this.userController.generateConfig(this.TAG,this.Actions.C,e),r=this.userController.request(n);return r.then((function(e){t.userController.isActionSuccessful("applyAddFriend",t.Actions.C,e)})).catch((function(e){})),r}},{key:"getPendency",value:function(e){var t=this,n=this.userController.generateConfig(this.TAG,this.Actions.G,e),r=this.userController.request(n);return r.then((function(e){t.userController.isActionSuccessful("getPendency",t.Actions.G,e)})).catch((function(e){})),r}},{key:"deletePendency",value:function(e){var t=this,n=this.userController.generateConfig(this.TAG,this.Actions.D,e),r=this.userController.request(n);return r.then((function(e){t.userController.isActionSuccessful("deletePendency",t.Actions.D,e)})).catch((function(e){})),r}},{key:"replyPendency",value:function(){var e=this,t=arguments.length>0&&void 0!==arguments[0]?arguments[0]:{},n=this.userController.generateConfig(this.TAG,this.Actions.U,t),r=this.userController.request(n);return r.then((function(t){e.userController.isActionSuccessful("replyPendency",e.Actions.U,t)})).catch((function(e){})),r}}]),e}(),hu=function(e){c(n,e);var t=y(n);function n(e){var o;return r(this,n),(o=t.call(this,e)).profileHandler=new iu(g(o)),o.friendHandler=new uu(g(o)),o.blacklistHandler=new lu(g(o)),o.applyC2CHandler=new pu(g(o)),o._initializeListener(),o}return i(n,[{key:"_initializeListener",value:function(e){var t=this.tim.innerEmitter;t.on(Yr,this.onContextUpdated,this),t.on(yo,this.onProfileModified,this),t.on(mo,this.onNewFriendMessages,this),t.on(Ro,this.onConversationsProfileUpdated,this)}},{key:"onContextUpdated",value:function(e){var t=this.tim.context;!1!=!!t.a2Key&&!1!=!!t.tinyID&&(this.profileHandler.getMyProfile(),this.friendHandler.getFriendList(),this.blacklistHandler.getBlacklist())}},{key:"onGotMyProfile",value:function(){this.triggerReady()}},{key:"onProfileModified",value:function(e){this.profileHandler.onProfileModified(e)}},{key:"onNewFriendMessages",value:function(e){J.debug("onNewFriendMessages",JSON.stringify(e.data)),Ae(e.data.blackListDelAccount)||this.blacklistHandler.handleBlackListDelAccount(e.data.blackListDelAccount),Ae(e.data.blackListAddAccount)||this.blacklistHandler.handleBlackListAddAccount(e.data.blackListAddAccount)}},{key:"onConversationsProfileUpdated",value:function(e){this.profileHandler.onConversationsProfileUpdated(e.data)}},{key:"getMyAccount",value:function(){return this.tim.context.identifier}},{key:"isMyFriend",value:function(e){return this.friendHandler.isMyFriend(e)}},{key:"generateConfig",value:function(e,t,n){return{name:e,action:t,param:n}}},{key:"getMyProfile",value:function(){return this.profileHandler.getMyProfile()}},{key:"getUserProfile",value:function(e){return this.profileHandler.getUserProfile(e)}},{key:"updateMyProfile",value:function(e){return this.profileHandler.updateMyProfile(e)}},{key:"getFriendList",value:function(){return this.friendHandler.getFriendList()}},{key:"deleteFriend",value:function(e){return this.friendHandler.deleteFriend(e)}},{key:"getBlacklist",value:function(){return this.blacklistHandler.getBlacklist()}},{key:"addBlacklist",value:function(e){return this.blacklistHandler.addBlacklist(e)}},{key:"deleteBlacklist",value:function(e){return this.blacklistHandler.deleteBlacklist(e)}},{key:"applyAddFriend",value:function(e){return this.applyC2CHandler.applyAddFriend(e)}},{key:"getPendency",value:function(e){return this.applyC2CHandler.getPendency(e)}},{key:"deletePendency",value:function(e){return this.applyC2CHandler.deletePendency(e)}},{key:"replyPendency",value:function(e){return this.applyC2CHandler.replyPendency(e)}},{key:"reset",value:function(){J.info("UserController.reset"),this.resetReady(),this.profileHandler.reset(),this.blacklistHandler.reset(),this.checkTimes=0}}]),n}(Bo),fu=["groupID","name","avatar","type","introduction","notification","ownerID","selfInfo","createTime","infoSequence","lastInfoTime","lastMessage","nextMessageSeq","memberNum","maxMemberNum","memberList","joinOption","groupCustomField"],du=function(){function e(t){r(this,e),this.groupID="",this.name="",this.avatar="",this.type="",this.introduction="",this.notification="",this.ownerID="",this.createTime="",this.infoSequence="",this.lastInfoTime="",this.selfInfo={messageRemindType:"",joinTime:"",nameCard:"",role:""},this.lastMessage={lastTime:"",lastSequence:"",fromAccount:"",messageForShow:""},this.nextMessageSeq="",this.memberNum="",this.maxMemberNum="",this.joinOption="",this.groupCustomField=[],this._initGroup(t)}return i(e,[{key:"_initGroup",value:function(e){for(var t in e)fu.indexOf(t)<0||("selfInfo"!==t?this[t]=e[t]:this.updateSelfInfo(e[t]))}},{key:"updateGroup",value:function(e){e.lastMsgTime&&(this.lastMessage.lastTime=e.lastMsgTime),e.groupCustomField&&Se(this.groupCustomField,e.groupCustomField),he(this,e,["members","errorCode","lastMsgTime","groupCustomField"])}},{key:"updateSelfInfo",value:function(e){var t=e.nameCard,n=e.joinTime,r=e.role,o=e.messageRemindType;he(this.selfInfo,{nameCard:t,joinTime:n,role:r,messageRemindType:o},[],["",null,void 0,0,NaN])}},{key:"setSelfNameCard",value:function(e){this.selfInfo.nameCard=e}}]),e}(),gu=function(e,n){if(oe(n))return"";switch(e){case t.MSG_TEXT:return n.text;case t.MSG_IMAGE:return"[图片]";case t.MSG_GEO:return"[位置]";case t.MSG_AUDIO:return"[语音]";case t.MSG_VIDEO:return"[视频]";case t.MSG_FILE:return"[文件]";case t.MSG_CUSTOM:return"[自定义消息]";case t.MSG_GRP_TIP:return"[群提示消息]";case t.MSG_GRP_SYS_NOTICE:return"[群系统通知]";case t.MSG_FACE:return"[动画表情]";default:return""}},mu=function(){function e(t){var n;r(this,e),this.conversationID=t.conversationID||"",this.unreadCount=t.unreadCount||0,this.type=t.type||"",this.lastMessage=(n=t.lastMessage,oe(n)?{lastTime:0,lastSequence:0,fromAccount:0,messageForShow:"",payload:null,type:"",isRevoked:!1}:n instanceof br?{lastTime:n.time||0,lastSequence:n.sequence||0,fromAccount:n.from||"",messageForShow:gu(n.type,n.payload),payload:n.payload||null,type:n.type||null,isRevoked:!1}:u({},n,{isRevoked:!1,messageForShow:gu(n.type,n.payload)})),this._isInfoCompleted=!1,this._initProfile(t)}return i(e,[{key:"_initProfile",value:function(e){var n=this;Object.keys(e).forEach((function(t){switch(t){case"userProfile":n.userProfile=e.userProfile;break;case"groupProfile":n.groupProfile=e.groupProfile}})),oe(this.userProfile)&&this.type===t.CONV_C2C?this.userProfile=new ou({userID:e.conversationID.replace("C2C","")}):oe(this.groupProfile)&&this.type===t.CONV_GROUP&&(this.groupProfile=new du({groupID:e.conversationID.replace("GROUP","")}))}},{key:"updateUnreadCount",value:function(e,n){oe(e)||(this.subType===t.GRP_CHATROOM||Te(this.subType)?this.unreadCount=0:n&&this.type===t.CONV_GROUP?this.unreadCount=e:this.unreadCount=this.unreadCount+e)}},{key:"reduceUnreadCount",value:function(){this.unreadCount>=1&&(this.unreadCount-=1)}},{key:"isLastMessageRevoked",value:function(e){var n=e.sequence,r=e.time;return this.type===t.CONV_C2C&&n===this.lastMessage.lastSequence&&r===this.lastMessage.lastTime||this.type===t.CONV_GROUP&&n===this.lastMessage.lastSequence}},{key:"setLastMessageRevoked",value:function(e){this.lastMessage.isRevoked=e}},{key:"toAccount",get:function(){return this.conversationID.replace("C2C","").replace("GROUP","")}},{key:"subType",get:function(){return this.groupProfile?this.groupProfile.type:""}}]),e}(),yu=function(n){c(s,n);var o=y(s);function s(e){var t;return r(this,s),(t=o.call(this,e)).pagingStatus=Ge.NOT_START,t.pagingTimeStamp=0,t.conversationMap=new Map,t.tempGroupList=[],t._initListeners(),t}return i(s,[{key:"hasLocalConversationMap",value:function(){return this.conversationMap.size>0}},{key:"createLocalConversation",value:function(e){return this.conversationMap.has(e)?this.conversationMap.get(e):new mu({conversationID:e,type:e.slice(0,3)===t.CONV_C2C?t.CONV_C2C:t.CONV_GROUP})}},{key:"hasLocalConversation",value:function(e){return this.conversationMap.has(e)}},{key:"getConversationList",value:function(){var e=this;J.log("ConversationController.getConversationList."),this.pagingStatus===Ge.REJECTED&&(J.log("ConversationController.getConversationList. continue to sync conversationList"),this._syncConversationList());var t=new oi;return t.setMethod(yi).setStart(),this.request({name:"conversation",action:"query"}).then((function(n){var r=n.data.conversations,o=void 0===r?[]:r,i=e._getConversationOptions(o);return e._updateLocalConversationList(i,!0),e._setStorageConversationList(),t.setCode(0).setText(o.length).setNetworkType(e.getNetworkType()).setEnd(),J.log("ConversationController.getConversationList ok."),zo({conversationList:e.getLocalConversationList()})})).catch((function(n){return e.probeNetwork().then((function(e){var r=v(e,2),o=r[0],i=r[1];t.setError(n,o,i).setEnd()})),J.error("ConversationController.getConversationList error:",n),Wo(n)}))}},{key:"_syncConversationList",value:function(){var e=this,t=new oi;return t.setMethod(_i).setStart(),this.pagingStatus===Ge.NOT_START&&this.conversationMap.clear(),this._autoPagingSyncConversationList().then((function(n){return e.pagingStatus=Ge.RESOLVED,e._setStorageConversationList(),t.setCode(0).setText("".concat(e.conversationMap.size)).setNetworkType(e.getNetworkType()).setEnd(),n})).catch((function(n){return e.pagingStatus=Ge.REJECTED,t.setText(e.pagingTimeStamp),e.probeNetwork().then((function(e){var r=v(e,2),o=r[0],i=r[1];t.setError(n,o,i).setEnd()})),Wo(n)}))}},{key:"_autoPagingSyncConversationList",value:function(){var e=this;return this.pagingStatus=Ge.PENDING,this.request({name:"conversation",action:"pagingQuery",param:{fromAccount:this.tim.context.identifier,timeStamp:this.pagingTimeStamp,orderType:1}}).then((function(t){var n=t.data,r=n.completeFlag,o=n.conversations,i=void 0===o?[]:o,s=n.timeStamp;if(J.log("ConversationController._autoPagingSyncConversationList completeFlag=".concat(r," nums=").concat(i.length)),i.length>0){var a=e._getConversationOptions(i);e._updateLocalConversationList(a,!0)}return e._isReady?e._emitConversationUpdate():e.triggerReady(),e.pagingTimeStamp=s,1!==r?e._autoPagingSyncConversationList():zo()}))}},{key:"getConversationProfile",value:function(e){var n=this.conversationMap.has(e)?this.conversationMap.get(e):this.createLocalConversation(e);return n._isInfoCompleted||n.type===t.CONV_SYSTEM?zo({conversation:n}):(J.log("ConversationController.getConversationProfile. conversationID:",e),this._updateUserOrGroupProfileCompletely(n).then((function(t){return J.log("ConversationController.getConversationProfile ok. conversationID:",e),t})).catch((function(e){return J.error("ConversationController.getConversationProfile error:",e),Wo(e)})))}},{key:"deleteConversation",value:function(e){var n=this,r={};if(!this.conversationMap.has(e)){var o=new pt({code:qt,message:Wn});return Wo(o)}switch(this.conversationMap.get(e).type){case t.CONV_C2C:r.type=1,r.toAccount=e.slice(3);break;case t.CONV_GROUP:r.type=2,r.toGroupID=e.slice(5);break;case t.CONV_SYSTEM:return this.tim.groupController.deleteGroupSystemNotice({messageList:this.tim.messageController.getLocalMessageList(e)}),this.deleteLocalConversation(e),zo({conversationID:e});default:var i=new pt({code:Ft,message:Jn});return Wo(i)}return J.log("ConversationController.deleteConversation. conversationID:",e),this.tim.setMessageRead({conversationID:e}).then((function(){return n.request({name:"conversation",action:"delete",param:r})})).then((function(){return J.log("ConversationController.deleteConversation ok. conversationID:",e),n.deleteLocalConversation(e),zo({conversationID:e})})).catch((function(e){return J.error("ConversationController.deleteConversation error:",e),Wo(e)}))}},{key:"getLocalConversationList",value:function(){return _(this.conversationMap.values())}},{key:"getLocalConversation",value:function(e){return this.conversationMap.get(e)}},{key:"_initLocalConversationList",value:function(){var e=new oi;e.setMethod(vi).setStart(),J.time(ti),J.log("ConversationController._initLocalConversationList init");var t=this._getStorageConversationList();if(t){for(var n=t.length,r=0;r<n;r++)this.conversationMap.set(t[r].conversationID,new mu(t[r]));this._emitConversationUpdate(!0,!1),e.setCode(0).setNetworkType(this.getNetworkType()).setText(n).setEnd()}else e.setCode(0).setNetworkType(this.getNetworkType()).setText(0).setEnd();this._syncConversationList()}},{key:"_getStorageConversationList",value:function(){return this.tim.storage.getItem("conversationMap")}},{key:"_setStorageConversationList",value:function(){var e=this.getLocalConversationList().slice(0,20).map((function(e){return{conversationID:e.conversationID,type:e.type,subType:e.subType,lastMessage:e.lastMessage,groupProfile:e.groupProfile,userProfile:e.userProfile}}));this.tim.storage.setItem("conversationMap",e)}},{key:"_initListeners",value:function(){var e=this;this.tim.innerEmitter.once(Yr,this._initLocalConversationList,this),this.tim.innerEmitter.on(Jr,this._onSendOrReceiveMessage,this),this.tim.innerEmitter.on(Qr,this._handleSyncMessages,this),this.tim.innerEmitter.on(Zr,this._handleSyncMessages,this),this.tim.innerEmitter.on(eo,this._onSendOrReceiveMessage,this),this.tim.innerEmitter.on(to,this._onSendOrReceiveMessage,this),this.tim.innerEmitter.on(no,this._onSendOrReceiveMessage,this),this.tim.innerEmitter.on(So,this._onGroupListUpdated,this),this.tim.innerEmitter.on(Lo,this._updateConversationUserProfile,this),this.tim.innerEmitter.on(ro,this._onMessageRevoked,this),this.ready((function(){e.tempGroupList.length>0&&(e._updateConversationGroupProfile(e.tempGroupList),e.tempGroupList.length=0)}))}},{key:"_onGroupListUpdated",value:function(e){this._updateConversationGroupProfile(e.data)}},{key:"_updateConversationGroupProfile",value:function(e){var t=this;re(e)&&0===e.length||(this.hasLocalConversationMap()?(e.forEach((function(e){var n="GROUP".concat(e.groupID);if(t.conversationMap.has(n)){var r=t.conversationMap.get(n);r.groupProfile=e,r.lastMessage.lastSequence=e.nextMessageSeq-1,r.subType||(r.subType=e.type)}})),this._emitConversationUpdate(!0,!1)):this.tempGroupList=e)}},{key:"_updateConversationUserProfile",value:function(e){var t=this;e.data.forEach((function(e){var n="C2C".concat(e.userID);t.conversationMap.has(n)&&(t.conversationMap.get(n).userProfile=e)})),this._emitConversationUpdate(!0,!1)}},{key:"_onMessageRevoked",value:function(e){var t=this,n=e.data;if(0!==n.length){var r=null,o=!1;n.forEach((function(e){(r=t.conversationMap.get(e.conversationID))&&r.isLastMessageRevoked(e)&&(o=!0,r.setLastMessageRevoked(!0))})),o&&this._emitConversationUpdate(!0,!1)}}},{key:"_handleSyncMessages",value:function(e){this._onSendOrReceiveMessage(e,!0)}},{key:"_onSendOrReceiveMessage",value:function(e){var t=this,n=arguments.length>1&&void 0!==arguments[1]&&arguments[1],r=e.data.eventDataList;this._isReady?0!==r.length&&(this._updateLocalConversationList(r,!1,n),this._setStorageConversationList(),this._emitConversationUpdate()):this.ready((function(){t._onSendOrReceiveMessage(e,n)}))}},{key:"_updateLocalConversationList",value:function(e,t,n){var r;r=this._updateTempConversations(e,t,n),this.conversationMap=new Map(this._sortConversations([].concat(_(r.conversations),_(this.conversationMap)))),t||this._updateUserOrGroupProfile(r.newerConversations)}},{key:"_updateTempConversations",value:function(e,n,r){for(var o=[],i=[],s=0,a=e.length;s<a;s++){var u=new mu(e[s]),c=this.conversationMap.get(u.conversationID);if(this.conversationMap.has(u.conversationID)){var l=["unreadCount","allowType","adminForbidType","payload"];r&&l.push("lastMessage"),he(c,u,l,[null,void 0,"",0,NaN]),c.updateUnreadCount(u.unreadCount,n),r||(c.lastMessage.payload=e[s].lastMessage.payload),this.conversationMap.delete(c.conversationID),o.push([c.conversationID,c])}else{if(u.type===t.CONV_GROUP){var p=u.groupProfile.groupID,h=this.tim.groupController.getLocalGroupProfile(p);h&&(u.groupProfile=h,u.updateUnreadCount(0))}i.push(u),o.push([u.conversationID,u])}}return{conversations:o,newerConversations:i}}},{key:"_sortConversations",value:function(e){return e.sort((function(e,t){return t[1].lastMessage.lastTime-e[1].lastMessage.lastTime}))}},{key:"_updateUserOrGroupProfile",value:function(e){var n=this;if(0!==e.length){var r=[],o=[];e.forEach((function(e){if(e.type===t.CONV_C2C)r.push(e.toAccount);else if(e.type===t.CONV_GROUP){var i=e.toAccount;n.tim.groupController.hasLocalGroup(i)?e.groupProfile=n.tim.groupController.getLocalGroupProfile(i):o.push(i)}})),r.length>0&&this.tim.getUserProfile({userIDList:r}).then((function(e){var t=e.data;re(t)?t.forEach((function(e){n.conversationMap.get("C2C".concat(e.userID)).userProfile=e})):n.conversationMap.get("C2C".concat(t.userID)).userProfile=t})),o.length>0&&this.tim.groupController.getGroupProfileAdvance({groupIDList:o,responseFilter:{groupBaseInfoFilter:["Type","Name","FaceUrl"]}}).then((function(e){e.data.successGroupList.forEach((function(e){var t="GROUP".concat(e.groupID);if(n.conversationMap.has(t)){var r=n.conversationMap.get(t);he(r.groupProfile,e,[],[null,void 0,"",0,NaN]),!r.subType&&e.type&&(r.subType=e.type)}}))}))}}},{key:"_updateUserOrGroupProfileCompletely",value:function(e){var n=this;return e.type===t.CONV_C2C?this.tim.getUserProfile({userIDList:[e.toAccount]}).then((function(t){var r=t.data;return 0===r.length?Wo(new pt({code:xt,message:Xn})):(e.userProfile=r[0],e._isInfoCompleted=!0,n._unshiftConversation(e),zo({conversation:e}))})):this.tim.getGroupProfile({groupID:e.toAccount}).then((function(t){return e.groupProfile=t.data.group,e._isInfoCompleted=!0,n._unshiftConversation(e),zo({conversation:e})}))}},{key:"_unshiftConversation",value:function(e){e instanceof mu&&!this.conversationMap.has(e.conversationID)&&(this.conversationMap=new Map([[e.conversationID,e]].concat(_(this.conversationMap))),this._setStorageConversationList(),this._emitConversationUpdate(!0,!1))}},{key:"deleteLocalConversation",value:function(e){return this.conversationMap.delete(e),this._setStorageConversationList(),this.emitInnerEvent(Oo,e),this._emitConversationUpdate(!0,!1),this.conversationMap.has(e)}},{key:"_getConversationOptions",value:function(e){var t=[],n=e.filter((function(e){var t=e.lastMsg;return ne(t)})).map((function(e){if(1===e.type){var n={userID:e.userID,nick:e.c2CNick,avatar:e.c2CImage};return t.push(n),{conversationID:"C2C".concat(e.userID),type:"C2C",lastMessage:{lastTime:e.time,lastSequence:e.sequence,fromAccount:e.lastC2CMsgFromAccount,messageForShow:e.messageShow,type:e.lastMsg.elements[0]?e.lastMsg.elements[0].type:null,payload:e.lastMsg.elements[0]?e.lastMsg.elements[0].content:null},userProfile:new ou(n)}}return{conversationID:"GROUP".concat(e.groupID),type:"GROUP",lastMessage:{lastTime:e.time,lastSequence:e.messageReadSeq+e.unreadCount,fromAccount:e.msgGroupFromAccount,messageForShow:e.messageShow,type:e.lastMsg.elements[0]?e.lastMsg.elements[0].type:null,payload:e.lastMsg.elements[0]?e.lastMsg.elements[0].content:null},groupProfile:new du({groupID:e.groupID,name:e.groupNick,avatar:e.groupImage}),unreadCount:e.unreadCount}}));return t.length>0&&this.emitInnerEvent(Ro,t),n}},{key:"_emitConversationUpdate",value:function(){var t=!(arguments.length>0&&void 0!==arguments[0])||arguments[0],n=!(arguments.length>1&&void 0!==arguments[1])||arguments[1],r=_(this.conversationMap.values());n&&this.emitInnerEvent(Ao,r),t&&this.emitOuterEvent(e.CONVERSATION_LIST_UPDATED,r)}},{key:"_conversationMapTreeShaking",value:function(e){var n=this,r=new Map(_(this.conversationMap));e.forEach((function(e){return r.delete(e.conversationID)})),r.has(t.CONV_SYSTEM)&&r.delete(t.CONV_SYSTEM);var o=this.tim.groupController.getJoinedAVChatRoom();o&&r.delete("".concat(t.CONV_GROUP).concat(o.groupID)),_(r.keys()).forEach((function(e){return n.conversationMap.delete(e)}))}},{key:"reset",value:function(){this.pagingStatus=Ge.NOT_START,this.pagingTimeStamp=0,this.conversationMap.clear(),this.resetReady(),this.tim.innerEmitter.once(Yr,this._initLocalConversationList,this)}}]),s}(Bo),vu=function(){function e(t){if(r(this,e),void 0===t)throw new pt({code:Ct,message:On});if(void 0===t.tim)throw new pt({code:Ct,message:"".concat(On,".tim")});this.list=new Map,this.tim=t.tim,this._initializeOptions(t)}return i(e,[{key:"getLocalOldestMessageByConversationID",value:function(e){if(!e)return null;if(!this.list.has(e))return null;var t=this.list.get(e).values();return t?t.next().value:null}},{key:"_initializeOptions",value:function(e){this.options={};var t={memory:{maxDatasPerKey:100,maxBytesPerData:256,maxKeys:0},cache:{maxDatasPerKey:10,maxBytesPerData:256,maxKeys:0}};for(var n in t)if(Object.prototype.hasOwnProperty.call(t,n)){if(void 0===e[n]){this.options[n]=t[n];continue}var r=t[n];for(var o in r)if(Object.prototype.hasOwnProperty.call(r,o)){if(void 0===e[n][o]){this.options[n][o]=r[o];continue}this.options[n][o]=e[n][o]}}}},{key:"pushIn",value:function(e){var t=e.conversationID,n=e.ID,r=!0;return this.list.has(t)||this.list.set(t,new Map),this.list.has(t)&&this.list.get(t).has(n)?r=!1:this.list.get(t).set(n,e),r}},{key:"unshift",value:function(e){re(e)?e.length>0&&this._unshiftMultipleMessages(e):this._unshiftSingleMessage(e)}},{key:"_unshiftSingleMessage",value:function(e){var t=e.conversationID,n=e.ID;if(!this.list.has(t))return this.list.set(t,new Map),void this.list.get(t).set(n,e);var r=Array.from(this.list.get(t));r.unshift([n,e]),this.list.set(t,new Map(r))}},{key:"_unshiftMultipleMessages",value:function(e){for(var t=e.length,n=[],r=e[0].conversationID,o=this.list.has(r)?Array.from(this.list.get(r)):[],i=0;i<t;i++)n.push([e[i].ID,e[i]]);this.list.set(r,new Map(n.concat(o)))}},{key:"remove",value:function(e){var t=e.conversationID,n=e.ID;this.list.has(t)&&this.list.get(t).delete(n)}},{key:"revoke",value:function(e,t,n){if(J.debug("revoke message",e,t,n),this.list.has(e)){var r,o=M(this.list.get(e));try{for(o.s();!(r=o.n()).done;){var i=v(r.value,2)[1];if(i.sequence===t&&!i.isRevoked&&(oe(n)||i.random===n))return i.isRevoked=!0,i}}catch(s){o.e(s)}finally{o.f()}}return null}},{key:"removeByConversationID",value:function(e){this.list.has(e)&&this.list.delete(e)}},{key:"hasLocalMessageList",value:function(e){return this.list.has(e)}},{key:"getLocalMessageList",value:function(e){return this.hasLocalMessageList(e)?_(this.list.get(e).values()):[]}},{key:"hasLocalMessage",value:function(e,t){return!!this.hasLocalMessageList(e)&&this.list.get(e).has(t)}},{key:"getLocalMessage",value:function(e,t){return this.hasLocalMessage(e,t)?this.list.get(e).get(t):null}},{key:"reset",value:function(){this.list.clear()}}]),e}(),_u=function(){function e(t){r(this,e),this.tim=t}return i(e,[{key:"setMessageRead",value:function(e){var n=e.conversationID,r=e.messageID,o=this.tim.conversationController.getLocalConversation(n);if(J.log("ReadReportHandler.setMessageRead conversationID=".concat(n," unreadCount=").concat(o?o.unreadCount:0)),!o||0===o.unreadCount)return zo();var i=r?this.tim.messageController.getLocalMessage(n,r):null;switch(o.type){case t.CONV_C2C:return this._setC2CMessageRead({conversationID:n,lastMessageTime:i?i.time:o.lastMessage.lastTime});case t.CONV_GROUP:return this._setGroupMessageRead({conversationID:n,lastMessageSeq:i?i.sequence:o.lastMessage.lastSequence});case t.CONV_SYSTEM:return o.unreadCount=0,zo();default:return zo()}}},{key:"_setC2CMessageRead",value:function(e){var t=this,n=e.conversationID,r=e.lastMessageTime;J.log("ReadReportHandler._setC2CMessageRead conversationID=".concat(n," lastMessageTime=").concat(r)),Z(r)||J.warn("ReadReportHandler._setC2CMessageRead 请勿修改 Conversation.lastMessage.lastTime，否则可能会导致已读上报结果不准确");var o=new oi;return o.setMethod(gi).setText("".concat(n,"-").concat(r)).setStart(),this.tim.messageController.request({name:"conversation",action:"setC2CMessageRead",param:{C2CMsgReaded:{cookie:"",C2CMsgReadedItem:[{toAccount:n.replace("C2C",""),lastMessageTime:r}]}}}).then((function(){return o.setCode(0).setNetworkType(t.tim.netMonitor.getNetworkType()).setEnd(),J.log("ReadReportHandler._setC2CMessageRead ok."),t._updateIsReadAfterReadReport({conversationID:n,lastMessageTime:r}),t._updateUnreadCount(n),new jo})).catch((function(e){return t.tim.netMonitor.probe().then((function(t){var n=v(t,2),r=n[0],i=n[1];o.setError(e,r,i).setEnd()})),J.log("ReadReportHandler._setC2CMessageRead failed. ".concat(fe(e))),Wo(e)}))}},{key:"_setGroupMessageRead",value:function(e){var t=this,n=e.conversationID,r=e.lastMessageSeq;J.log("ReadReportHandler._setGroupMessageRead conversationID=".concat(n," lastMessageSeq=").concat(r)),Z(r)||J.warn("ReadReportHandler._setGroupMessageRead 请勿修改 Conversation.lastMessage.lastSequence，否则可能会导致已读上报结果不准确");var o=new oi;return o.setMethod(mi).setText("".concat(n,"-").concat(r)).setStart(),this.tim.messageController.request({name:"conversation",action:"setGroupMessageRead",param:{groupID:n.replace("GROUP",""),messageReadSeq:r}}).then((function(){return o.setCode(0).setNetworkType(t.tim.netMonitor.getNetworkType()).setEnd(),J.log("ReadReportHandler._setGroupMessageRead ok."),t._updateIsReadAfterReadReport({conversationID:n,lastMessageSeq:r}),t._updateUnreadCount(n),new jo})).catch((function(e){return t.tim.netMonitor.probe().then((function(t){var n=v(t,2),r=n[0],i=n[1];o.setError(e,r,i).setEnd()})),J.log("ReadReportHandler._setGroupMessageRead failed. ".concat(fe(e))),Wo(e)}))}},{key:"_updateUnreadCount",value:function(e){var t=this.tim,n=t.conversationController,r=t.messageController,o=n.getLocalConversation(e),i=r.getLocalMessageList(e);o&&(o.unreadCount=i.filter((function(e){return!e.isRead})).length,J.log("ReadReportHandler._updateUnreadCount conversationID=".concat(o.conversationID," unreadCount=").concat(o.unreadCount)))}},{key:"_updateIsReadAfterReadReport",value:function(e){var t=e.conversationID,n=e.lastMessageSeq,r=e.lastMessageTime,o=this.tim.messageController.getLocalMessageList(t);if(0!==o.length)for(var i,s=o.length-1;s>=0;s--)if(i=o[s],!(r&&i.time>r||n&&i.sequence>n)){if("in"===i.flow&&i.isRead)break;i.setIsRead(!0)}}},{key:"updateIsRead",value:function(e){var n=this.tim,r=n.conversationController,o=n.messageController,i=r.getLocalConversation(e),s=o.getLocalMessageList(e);if(i&&0!==s.length&&!Ee(i.type)){for(var a=[],u=0;u<s.length;u++)"in"!==s[u].flow?"out"!==s[u].flow||s[u].isRead||s[u].setIsRead(!0):a.push(s[u]);var c=0;if(i.type===t.CONV_C2C){var l=a.slice(-i.unreadCount).filter((function(e){return e.isRevoked})).length;c=a.length-i.unreadCount-l}else c=a.length-i.unreadCount;for(var p=0;p<c&&!a[p].isRead;p++)a[p].setIsRead(!0)}}}]),e}(),Cu=function(){function e(t){var n=t.tim,o=t.messageController;r(this,e),this.tim=n,this.messageController=o,this.completedMap=new Map,this._initListener()}return i(e,[{key:"getMessageList",value:function(e){var t=this,n=e.conversationID,r=e.nextReqMessageID,o=e.count;if(this.tim.groupController.checkJoinedAVChatRoomByID(n.replace("GROUP","")))return J.log("GetMessageHandler.getMessageList not available in avchatroom. conversationID=".concat(n)),zo({messageList:[],nextReqMessageID:"",isCompleted:!0});(oe(o)||o>15)&&(o=15);var i=this._computeLeftCount({conversationID:n,nextReqMessageID:r});return J.log("GetMessageHandler.getMessageList. conversationID=".concat(n," leftCount=").concat(i," count=").concat(o," nextReqMessageID=").concat(r)),this._needGetHistory({conversationID:n,leftCount:i,count:o})?this.messageController.getHistoryMessages({conversationID:n,count:20}).then((function(){return i=t._computeLeftCount({conversationID:n,nextReqMessageID:r}),new jo(t._computeResult({conversationID:n,nextReqMessageID:r,count:o,leftCount:i}))})):(J.log("GetMessageHandler.getMessageList. get messagelist from memory"),zo(this._computeResult({conversationID:n,nextReqMessageID:r,count:o,leftCount:i})))}},{key:"setCompleted",value:function(e){J.log("GetMessageHandler.setCompleted. conversationID=".concat(e)),this.completedMap.set(e,!0)}},{key:"deleteCompletedItem",value:function(e){J.log("GetMessageHandler.deleteCompletedItem. conversationID=".concat(e)),this.completedMap.delete(e)}},{key:"_initListener",value:function(){var e=this;this.tim.innerEmitter.on(Po,(function(){e.setCompleted(t.CONV_SYSTEM)})),this.tim.innerEmitter.on(No,(function(n){var r=n.data;e.setCompleted("".concat(t.CONV_GROUP).concat(r))}))}},{key:"_getMessageListSize",value:function(e){return this.messageController.getLocalMessageList(e).length}},{key:"_needGetHistory",value:function(e){var n=e.conversationID,r=e.leftCount,o=e.count,i=this.tim.conversationController.getLocalConversation(n),s=!!i&&i.type===t.CONV_SYSTEM,a=!!i&&i.subType===t.GRP_AVCHATROOM;return!s&&!a&&(r<o&&!this.completedMap.has(n))}},{key:"_computeResult",value:function(e){var t=e.conversationID,n=e.nextReqMessageID,r=e.count,o=e.leftCount,i=this._computeMessageList({conversationID:t,nextReqMessageID:n,count:r}),s=this._computeIsCompleted({conversationID:t,leftCount:o,count:r}),a=this._computeNextReqMessageID({messageList:i,isCompleted:s,conversationID:t});return J.log("GetMessageHandler._computeResult. conversationID=".concat(t," leftCount=").concat(o," count=").concat(r," nextReqMessageID=").concat(a," nums=").concat(i.length," isCompleted=").concat(s)),{messageList:i,nextReqMessageID:a,isCompleted:s}}},{key:"_computeNextReqMessageID",value:function(e){var t=e.messageList,n=e.isCompleted,r=e.conversationID;if(!n)return 0===t.length?"":t[0].ID;var o=this.messageController.getLocalMessageList(r);return 0===o.length?"":o[0].ID}},{key:"_computeMessageList",value:function(e){var t=e.conversationID,n=e.nextReqMessageID,r=e.count,o=this.messageController.getLocalMessageList(t),i=this._computeIndexEnd({nextReqMessageID:n,messageList:o}),s=this._computeIndexStart({indexEnd:i,count:r});return o.slice(s,i)}},{key:"_computeIndexEnd",value:function(e){var t=e.messageList,n=void 0===t?[]:t,r=e.nextReqMessageID;return r?n.findIndex((function(e){return e.ID===r})):n.length}},{key:"_computeIndexStart",value:function(e){var t=e.indexEnd,n=e.count;return t>n?t-n:0}},{key:"_computeLeftCount",value:function(e){var t=e.conversationID,n=e.nextReqMessageID;return n?this.messageController.getLocalMessageList(t).findIndex((function(e){return e.ID===n})):this._getMessageListSize(t)}},{key:"_computeIsCompleted",value:function(e){var t=e.conversationID;return!!(e.leftCount<=e.count&&this.completedMap.has(t))}},{key:"reset",value:function(){J.log("GetMessageHandler.reset"),this.completedMap.clear()}}]),e}(),Iu=function e(t){r(this,e),this.value=t,this.next=null},Mu=function(){function e(t){r(this,e),this.MAX_LENGTH=t,this.pTail=null,this.pNodeToDel=null,this.map=new Map,J.log("SinglyLinkedList init MAX_LENGTH=".concat(this.MAX_LENGTH))}return i(e,[{key:"pushIn",value:function(e){var t=new Iu(e);if(this.map.size<this.MAX_LENGTH)null===this.pTail?(this.pTail=t,this.pNodeToDel=t):(this.pTail.next=t,this.pTail=t),this.map.set(e,1);else{var n=this.pNodeToDel;this.pNodeToDel=this.pNodeToDel.next,this.map.delete(n.value),n.next=null,n=null,this.pTail.next=t,this.pTail=t,this.map.set(e,1)}}},{key:"has",value:function(e){return this.map.has(e)}},{key:"reset",value:function(){for(var e;null!==this.pNodeToDel;)e=this.pNodeToDel,this.pNodeToDel=this.pNodeToDel.next,e.next=null,e=null;this.pTail=null,this.map.clear()}}]),e}(),Su=function(){function e(t){r(this,e),this.tim=t}return i(e,[{key:"upload",value:function(e){switch(e.type){case t.MSG_IMAGE:return this._uploadImage(e);case t.MSG_FILE:return this._uploadFile(e);case t.MSG_AUDIO:return this._uploadAudio(e);case t.MSG_VIDEO:return this._uploadVideo(e);default:return Promise.resolve()}}},{key:"_uploadImage",value:function(e){var t=this.tim,n=t.uploadController,r=t.messageController,o=e.getElements()[0],i=r.getMessageOptionByID(e.messageID);return n.uploadImage({file:i.payload.file,to:i.to,onProgress:function(e){if(o.updatePercent(e),se(i.onProgress))try{i.onProgress(e)}catch(t){return Wo(new pt({code:Dt,message:"".concat(Pn)}))}}}).then((function(e){var t,n=e.location,r=e.fileType,i=e.fileSize,s=Me(n);return o.updateImageFormat(r),o.updateImageInfoArray({size:i,url:s}),t=o._imageMemoryURL,O?new Promise((function(e,n){wx.getImageInfo({src:t,success:function(t){e({width:t.width,height:t.height})},fail:function(){e({width:0,height:0})}})})):x&&9===F?Promise.resolve({width:0,height:0}):new Promise((function(e,n){var r=new Image;r.onload=function(){e({width:this.width,height:this.height}),r=null},r.onerror=function(){e({width:0,height:0}),r=null},r.src=t}))})).then((function(t){var n=t.width,r=t.height;return o.updateImageInfoArray({width:n,height:r}),e}))}},{key:"_uploadFile",value:function(e){var t=this.tim,n=t.uploadController,r=t.messageController,o=e.getElements()[0],i=r.getMessageOptionByID(e.messageID);return n.uploadFile({file:i.payload.file,to:i.to,onProgress:function(e){if(o.updatePercent(e),se(i.onProgress))try{i.onProgress(e)}catch(t){return Wo(new pt({code:Dt,message:"".concat(Pn)}))}}}).then((function(t){var n=t.location,r=Me(n);return o.updateFileUrl(r),e}))}},{key:"_uploadAudio",value:function(e){var t=this.tim,n=t.uploadController,r=t.messageController,o=e.getElements()[0],i=r.getMessageOptionByID(e.messageID);return n.uploadAudio({file:i.payload.file,to:i.to,onProgress:function(e){if(o.updatePercent(e),se(i.onProgress))try{i.onProgress(e)}catch(t){return Wo(new pt({code:Dt,message:"".concat(Pn)}))}}}).then((function(t){var n=t.location,r=Me(n);return o.updateAudioUrl(r),e}))}},{key:"_uploadVideo",value:function(e){var t=this.tim,n=t.uploadController,r=t.messageController,o=e.getElements()[0],i=r.getMessageOptionByID(e.messageID);return n.uploadVideo({file:i.payload.file,to:i.to,onProgress:function(e){if(o.updatePercent(e),se(i.onProgress))try{i.onProgress(e)}catch(t){return Wo(new pt({code:Dt,message:"".concat(Pn)}))}}}).then((function(t){var n=Me(t.location);return o.updateVideoUrl(n),e}))}}]),e}(),Du=function(n){c(s,n);var o=y(s);function s(e){var t;return r(this,s),(t=o.call(this,e))._initializeMembers(),t._initializeListener(),t._initialzeHandlers(),t.messageOptionMap=new Map,t}return i(s,[{key:"_initializeMembers",value:function(){this.messagesList=new vu({tim:this.tim}),this.currentMessageKey={},this.singlyLinkedList=new Mu(100)}},{key:"_initialzeHandlers",value:function(){this.readReportHandler=new _u(this.tim,this),this.getMessageHandler=new Cu({messageController:this,tim:this.tim}),this.uploadFileHandler=new Su(this.tim)}},{key:"reset",value:function(){this.messagesList.reset(),this.currentMessageKey={},this.getMessageHandler.reset(),this.singlyLinkedList.reset(),this.messageOptionMap.clear()}},{key:"_initializeListener",value:function(){var e=this.tim.innerEmitter;e.on(po,this._onReceiveC2CMessage,this),e.on(Wr,this._onSyncMessagesProcessing,this),e.on(Xr,this._onSyncMessagesFinished,this),e.on(ho,this._onReceiveGroupMessage,this),e.on(fo,this._onReceiveGroupTips,this),e.on(go,this._onReceiveSystemNotice,this),e.on(_o,this._onReceiveGroupMessageRevokedNotice,this),e.on(Co,this._onReceiveC2CMessageRevokedNotice,this),e.on(Oo,this._clearConversationMessages,this)}},{key:"sendMessageInstance",value:function(e){var n,r=this,o=this.tim.sumStatController,i=null;switch(e.conversationType){case t.CONV_C2C:i=this._handleOnSendC2CMessageSuccess.bind(this);break;case t.CONV_GROUP:i=this._handleOnSendGroupMessageSuccess.bind(this);break;default:return Wo(new pt({code:Mt,message:Nn}))}return this.singlyLinkedList.pushIn(e.random),this.uploadFileHandler.upload(e).then((function(){var i=null;return e.isSendable()?(o.addTotalCount(ei),n=Date.now(),e.conversationType===t.CONV_C2C?i=r._createC2CMessagePack(e):e.conversationType===t.CONV_GROUP&&(i=r._createGroupMessagePack(e)),r.request(i)):Wo({code:Ut,message:zn})})).then((function(s){return o.addSuccessCount(ei),o.addCost(ei,Math.abs(Date.now()-n)),e.conversationType===t.CONV_GROUP&&(e.sequence=s.data.sequence,e.time=s.data.time,e.generateMessageID(r.tim.context.identifier)),r.messagesList.pushIn(e),i(e,s.data),r.messageOptionMap.delete(e.messageID),r.emitInnerEvent(Jr,{eventDataList:[{conversationID:e.conversationID,unreadCount:0,type:e.conversationType,subType:e.conversationSubType,lastMessage:e}]}),new jo({message:e})})).catch((function(t){e.status=Pe.FAIL;var n=new oi;return n.setMethod(pi).setMessageType(e.type).setText("".concat(r._generateTjgID(e),"-").concat(e.type,"-").concat(e.from,"-").concat(e.to)).setStart(),r.probeNetwork().then((function(e){var r=v(e,2),o=r[0],i=r[1];n.setError(t,o,i).setEnd()})),J.error("MessageController.sendMessageInstance error:",t),Wo(new pt({code:t&&t.code?t.code:_t,message:t&&t.message?t.message:Rn,data:{message:e}}))}))}},{key:"resendMessage",value:function(e){return e.isResend=!0,e.status=Pe.UNSEND,this.sendMessageInstance(e)}},{key:"_isFileLikeMessage",value:function(e){return[t.MSG_IMAGE,t.MSG_FILE,t.MSG_AUDIO,t.MSG_VIDEO].indexOf(e.type)>=0}},{key:"_resendBinaryTypeMessage",value:function(){}},{key:"_createC2CMessagePack",value:function(e){return{name:"c2cMessage",action:"create",tjgID:this._generateTjgID(e),param:{toAccount:e.to,msgBody:e.getElements(),msgSeq:e.sequence,msgRandom:e.random}}}},{key:"_handleOnSendC2CMessageSuccess",value:function(e,t){e.status=Pe.SUCCESS,e.time=t.time}},{key:"_createGroupMessagePack",value:function(e){return{name:"groupMessage",action:"create",tjgID:this._generateTjgID(e),param:{groupID:e.to,msgBody:e.getElements(),random:e.random,priority:e.priority,clientSequence:e.clientSequence}}}},{key:"_handleOnSendGroupMessageSuccess",value:function(e,t){e.sequence=t.sequence,e.time=t.time,e.status=Pe.SUCCESS}},{key:"_onReceiveC2CMessage",value:function(n){J.debug("MessageController._onReceiveC2CMessage nums=".concat(n.data.length));var r=this._newC2CMessageStoredAndSummary({notifiesList:n.data,type:t.CONV_C2C,C2CRemainingUnreadList:n.C2CRemainingUnreadList}),o=r.eventDataList,i=r.result;o.length>0&&this.emitInnerEvent(eo,{eventDataList:o,result:i}),i.length>0&&this.emitOuterEvent(e.MESSAGE_RECEIVED,i)}},{key:"_onReceiveGroupMessage",value:function(t){J.debug("MessageController._onReceiveGroupMessage nums=".concat(t.data.length));var n=this.newGroupMessageStoredAndSummary(t.data),r=n.eventDataList,o=n.result;r.length>0&&this.emitInnerEvent(to,{eventDataList:r,result:o,isGroupTip:!1}),o.length>0&&this.emitOuterEvent(e.MESSAGE_RECEIVED,o)}},{key:"_onReceiveGroupTips",value:function(t){var n=t.data;J.debug("MessageController._onReceiveGroupTips nums=".concat(n.length));var r=this.newGroupTipsStoredAndSummary(n),o=r.eventDataList,i=r.result;o.length>0&&this.emitInnerEvent(to,{eventDataList:o,result:i,isGroupTip:!0}),i.length>0&&this.emitOuterEvent(e.MESSAGE_RECEIVED,i)}},{key:"_onReceiveSystemNotice",value:function(t){var n=t.data,r=n.groupSystemNotices,o=n.type;J.debug("MessageController._onReceiveSystemNotice nums=".concat(r.length));var i=this.newSystemNoticeStoredAndSummary({notifiesList:r,type:o}),s=i.eventDataList,a=i.result;s.length>0&&this.emitInnerEvent(no,{eventDataList:s,result:a,type:o}),a.length>0&&"poll"===o&&this.emitOuterEvent(e.MESSAGE_RECEIVED,a)}},{key:"_onReceiveGroupMessageRevokedNotice",value:function(t){var n=this;J.debug("MessageController._onReceiveGroupMessageRevokedNotice nums=".concat(t.data.length));var r=[],o=null;t.data.forEach((function(e){e.elements.revokedInfos.forEach((function(e){(o=n.messagesList.revoke("GROUP".concat(e.groupID),e.sequence))&&r.push(o)}))})),0!==r.length&&(this.emitInnerEvent(ro,r),this.emitOuterEvent(e.MESSAGE_REVOKED,r))}},{key:"_onReceiveC2CMessageRevokedNotice",value:function(t){var n=this;J.debug("MessageController._onReceiveC2CMessageRevokedNotice nums=".concat(t.data.length));var r=[],o=null;t.data.forEach((function(e){e.c2cMessageRevokedNotify.revokedInfos.forEach((function(e){var t=n.tim.context.identifier===e.from?"C2C".concat(e.to):"C2C".concat(e.from);(o=n.messagesList.revoke(t,e.sequence,e.random))&&r.push(o)}))})),0!==r.length&&(this.emitInnerEvent(ro,r),this.emitOuterEvent(e.MESSAGE_REVOKED,r))}},{key:"_clearConversationMessages",value:function(e){var t=e.data;this.messagesList.removeByConversationID(t),this.getMessageHandler.deleteCompletedItem(t)}},{key:"_pushIntoNoticeResult",value:function(e,t){var n=this.messagesList.pushIn(t),r=this.singlyLinkedList.has(t.random);return!(!n||!1!==r)&&(e.push(t),!0)}},{key:"_newC2CMessageStoredAndSummary",value:function(e){for(var n=e.notifiesList,r=e.type,o=e.C2CRemainingUnreadList,i=e.isFromSync,s=null,a=[],u=[],c={},l=this.tim.bigDataHallwayController,p=0,h=n.length;p<h;p++){var f=n[p];if(f.currentUser=this.tim.context.identifier,f.conversationType=r,f.isSystemMessage=!!f.isSystemMessage,s=new br(f),f.elements=l.parseElements(f.elements,f.from),s.setElement(f.elements),!i)if(!this._pushIntoNoticeResult(u,s))continue;void 0===c[s.conversationID]?c[s.conversationID]=a.push({conversationID:s.conversationID,unreadCount:"out"===s.flow?0:1,type:s.conversationType,subType:s.conversationSubType,lastMessage:s})-1:(a[c[s.conversationID]].type=s.conversationType,a[c[s.conversationID]].subType=s.conversationSubType,a[c[s.conversationID]].lastMessage=s,"in"===s.flow&&a[c[s.conversationID]].unreadCount++)}if(re(o))for(var d=function(e,n){var r=a.find((function(t){return t.conversationID==="C2C".concat(o[e].from)}));r?r.unreadCount+=o[e].count:a.push({conversationID:"C2C".concat(o[e].from),unreadCount:o[e].count,type:t.CONV_C2C})},g=0,m=o.length;g<m;g++)d(g);return{eventDataList:a,result:u}}},{key:"newGroupMessageStoredAndSummary",value:function(e){for(var n=null,r=[],o={},i=[],s=t.CONV_GROUP,a=this.tim.bigDataHallwayController,u=0,c=e.length;u<c;u++){var l=e[u];if(l.currentUser=this.tim.context.identifier,l.conversationType=s,l.isSystemMessage=!!l.isSystemMessage,n=new br(l),l.elements=a.parseElements(l.elements,l.from),n.setElement(l.elements),!this._isMessageFromAVChatroom(n))this._pushIntoNoticeResult(i,n)&&(void 0===o[n.conversationID]?o[n.conversationID]=r.push({conversationID:n.conversationID,unreadCount:"out"===n.flow?0:1,type:n.conversationType,subType:n.conversationSubType,lastMessage:n})-1:(r[o[n.conversationID]].type=n.conversationType,r[o[n.conversationID]].subType=n.conversationSubType,r[o[n.conversationID]].lastMessage=n,"in"===n.flow&&r[o[n.conversationID]].unreadCount++))}return{eventDataList:r,result:i}}},{key:"_isMessageFromAVChatroom",value:function(e){var t=e.conversationID.slice(5);return this.tim.groupController.checkJoinedAVChatRoomByID(t)}},{key:"newGroupTipsStoredAndSummary",value:function(e){for(var n=null,r=[],o=[],i={},s=0,a=e.length;s<a;s++){var c=e[s];if(c.currentUser=this.tim.context.identifier,c.conversationType=t.CONV_GROUP,(n=new br(c)).setElement({type:t.MSG_GRP_TIP,content:u({},c.elements,{groupProfile:c.groupProfile})}),n.isSystemMessage=!1,!this._isMessageFromAVChatroom(n))this._pushIntoNoticeResult(o,n)&&(void 0===i[n.conversationID]?i[n.conversationID]=r.push({conversationID:n.conversationID,unreadCount:"out"===n.flow?0:1,type:n.conversationType,subType:n.conversationSubType,lastMessage:n})-1:(r[i[n.conversationID]].type=n.conversationType,r[i[n.conversationID]].subType=n.conversationSubType,r[i[n.conversationID]].lastMessage=n,"in"===n.flow&&r[i[n.conversationID]].unreadCount++))}return{eventDataList:r,result:o}}},{key:"newSystemNoticeStoredAndSummary",value:function(e){var n=e.notifiesList,r=e.type,o=null,i=n.length,s=0,a=[],c={conversationID:t.CONV_SYSTEM,unreadCount:0,type:t.CONV_SYSTEM,subType:null,lastMessage:null};for(s=0;s<i;s++){var l=n[s];if(l.elements.operationType!==ze)l.currentUser=this.tim.context.identifier,l.conversationType=t.CONV_SYSTEM,l.conversationID=t.CONV_SYSTEM,(o=new br(l)).setElement({type:t.MSG_GRP_SYS_NOTICE,content:u({},l.elements,{groupProfile:l.groupProfile})}),o.isSystemMessage=!0,(1===o.sequence&&1===o.random||2===o.sequence&&2===o.random)&&(o.sequence=me(),o.random=me(),o.generateMessageID(l.currentUser),J.log("MessageController.newSystemNoticeStoredAndSummary sequence and random maybe duplicated, regenerate. ID=".concat(o.ID))),this._pushIntoNoticeResult(a,o)&&("poll"===r?c.unreadCount++:"sync"===r&&o.setIsRead(!0),c.subType=o.conversationSubType)}return c.lastMessage=a[a.length-1],{eventDataList:a.length>0?[c]:[],result:a}}},{key:"_onSyncMessagesProcessing",value:function(e){var n=this._newC2CMessageStoredAndSummary({notifiesList:e.data,type:t.CONV_C2C,isFromSync:!0,C2CRemainingUnreadList:e.C2CRemainingUnreadList}),r=n.eventDataList,o=n.result;this.emitInnerEvent(Qr,{eventDataList:r,result:o})}},{key:"_onSyncMessagesFinished",value:function(e){this.triggerReady();var n=this._newC2CMessageStoredAndSummary({notifiesList:e.data.messageList,type:t.CONV_C2C,isFromSync:!0,C2CRemainingUnreadList:e.data.C2CRemainingUnreadList}),r=n.eventDataList,o=n.result;this.emitInnerEvent(Zr,{eventDataList:r,result:o})}},{key:"getHistoryMessages",value:function(e){if(e.conversationID===t.CONV_SYSTEM)return zo();!e.count&&(e.count=15),e.count>20&&(e.count=20);var n=this.messagesList.getLocalOldestMessageByConversationID(e.conversationID);n||((n={}).time=0,n.sequence=0,0===e.conversationID.indexOf(t.CONV_C2C)?(n.to=e.conversationID.replace(t.CONV_C2C,""),n.conversationType=t.CONV_C2C):0===e.conversationID.indexOf(t.CONV_GROUP)&&(n.to=e.conversationID.replace(t.CONV_GROUP,""),n.conversationType=t.CONV_GROUP));var r="";switch(n.conversationType){case t.CONV_C2C:return r=e.conversationID.replace(t.CONV_C2C,""),this.getC2CRoamMessages({conversationID:e.conversationID,peerAccount:r,count:e.count,lastMessageTime:void 0===this.currentMessageKey[e.conversationID]?0:n.time});case t.CONV_GROUP:return this.getGroupRoamMessages({conversationID:e.conversationID,groupID:n.to,count:e.count,sequence:n.sequence-1});default:return zo()}}},{key:"getC2CRoamMessages",value:function(e){var n=this,r=void 0!==this.currentMessageKey[e.conversationID]?this.currentMessageKey[e.conversationID]:"";J.log("MessageController.getC2CRoamMessages toAccount=".concat(e.peerAccount," count=").concat(e.count||15," lastMessageTime=").concat(e.lastMessageTime||0," messageKey=").concat(r));var o=new oi;return o.setMethod(hi).setStart(),this.request({name:"c2cMessage",action:"query",param:{peerAccount:e.peerAccount,count:e.count||15,lastMessageTime:e.lastMessageTime||0,messageKey:r}}).then((function(i){var s=i.data,a=s.complete,u=s.messageList;oe(u)?J.log("MessageController.getC2CRoamMessages ok. complete=".concat(a," but messageList is undefined!")):J.log("MessageController.getC2CRoamMessages ok. complete=".concat(a," nums=").concat(u.length)),o.setCode(0).setNetworkType(n.getNetworkType()).setText("".concat(e.peerAccount,"-").concat(e.count||15,"-").concat(e.lastMessageTime||0,"-").concat(r,"-").concat(a,"-").concat(u?u.length:"undefined")).setEnd(),1===a&&n.getMessageHandler.setCompleted(e.conversationID);var c=n._roamMessageStore(u,t.CONV_C2C,e.conversationID);return n.readReportHandler.updateIsRead(e.conversationID),n.currentMessageKey[e.conversationID]=i.data.messageKey,c})).catch((function(t){return n.probeNetwork().then((function(n){var i=v(n,2),s=i[0],a=i[1];o.setError(t,s,a).setText("".concat(e.peerAccount,"-").concat(e.count||15,"-").concat(e.lastMessageTime||0,"-").concat(r)).setEnd()})),J.warn("MessageController.getC2CRoamMessages failed. ".concat(t)),Wo(t)}))}},{key:"_computeLastSequence",value:function(e){return e.sequence>=0?Promise.resolve(e.sequence):this.tim.groupController.getGroupLastSequence(e.groupID)}},{key:"getGroupRoamMessages",value:function(e){var n=this,r=new oi,o=0;return this._computeLastSequence(e).then((function(t){return o=t,J.log("MessageController.getGroupRoamMessages groupID=".concat(e.groupID," lastSequence=").concat(o)),r.setMethod(fi).setStart(),n.request({name:"groupMessage",action:"query",param:{groupID:e.groupID,count:21,sequence:o}})})).then((function(i){var s=i.data,a=s.messageList,u=s.complete;oe(a)?J.log("MessageController.getGroupRoamMessages ok. complete=".concat(u," but messageList is undefined!")):J.log("MessageController.getGroupRoamMessages ok. complete=".concat(u," nums=").concat(a.length)),r.setCode(0).setNetworkType(n.getNetworkType()).setText("".concat(e.groupID,"-").concat(o,"-").concat(u,"-").concat(a?a.length:"undefined")).setEnd();var c="GROUP".concat(e.groupID);if(2===u||Ae(a))return n.getMessageHandler.setCompleted(c),[];var l=n._roamMessageStore(a,t.CONV_GROUP,c);return n.readReportHandler.updateIsRead(c),l})).catch((function(t){return n.probeNetwork().then((function(n){var i=v(n,2),s=i[0],a=i[1];r.setError(t,s,a).setText("".concat(e.groupID,"-").concat(o)).setEnd()})),J.warn("MessageController.getGroupRoamMessages failed. ".concat(t)),Wo(t)}))}},{key:"_roamMessageStore",value:function(){var e=arguments.length>0&&void 0!==arguments[0]?arguments[0]:[],n=arguments.length>1?arguments[1]:void 0,r=arguments.length>2?arguments[2]:void 0,o=null,i=[],s=0,a=e.length,c=null,l=n===t.CONV_GROUP,p=this.tim.bigDataHallwayController,h=function(){s=l?e.length-1:0,a=l?0:e.length},f=function(){l?--s:++s},d=function(){return l?s>=a:s<a};for(h();d();f())l&&1===e[s].sequence&&this.getMessageHandler.setCompleted(r),1!==e[s].isPlaceMessage&&((o=new br(e[s])).to=e[s].to,o.isSystemMessage=!!e[s].isSystemMessage,o.conversationType=n,e[s].event===qe.JSON.TYPE.GROUP.TIP?c={type:t.MSG_GRP_TIP,content:u({},e[s].elements,{groupProfile:e[s].groupProfile})}:(e[s].elements=p.parseElements(e[s].elements,e[s].from),c=e[s].elements),o.setElement(c),o.reInitialize(this.tim.context.identifier),i.push(o));return this.messagesList.unshift(i),h=f=d=null,i}},{key:"getLocalMessageList",value:function(e){return this.messagesList.getLocalMessageList(e)}},{key:"getLocalMessage",value:function(e,t){return this.messagesList.getLocalMessage(e,t)}},{key:"hasLocalMessage",value:function(e,t){return this.messagesList.hasLocalMessage(e,t)}},{key:"deleteLocalMessage",value:function(e){e instanceof br&&this.messagesList.remove(e)}},{key:"revokeMessage",value:function(e){var n,r=this;e.conversationType===t.CONV_C2C?n={name:"c2cMessageWillBeRevoked",action:"create",param:{msgInfo:{fromAccount:e.from,toAccount:e.to,msgSeq:e.sequence,msgRandom:e.random,msgTimeStamp:e.time}}}:e.conversationType===t.CONV_GROUP&&(n={name:"groupMessageWillBeRevoked",action:"create",param:{to:e.to,msgSeqList:[{msgSeq:e.sequence}]}});var o=new oi;return o.setMethod(di).setMessageType(e.type).setText("".concat(this._generateTjgID(e),"-").concat(e.type,"-").concat(e.from,"-").concat(e.to)).setStart(),this.request(n).then((function(t){var n=t.data.recallRetList;if(!Ae(n)&&0!==n[0].retCode){var i=new pt({code:n[0].retCode,message:lt[n[0].retCode]||Gn,data:{message:e}});return o.setCode(i.code).setMessage(i.message).setEnd(),Wo(i)}return J.info("MessageController.revokeMessage ok. ID=".concat(e.ID)),e.isRevoked=!0,o.setCode(0).setEnd(),r.emitInnerEvent(ro,[e]),new jo({message:e})})).catch((function(t){r.probeNetwork().then((function(e){var n=v(e,2),r=n[0],i=n[1];o.setError(t,r,i).setEnd()}));var n=new pt({code:t&&t.code?t.code:Tt,message:t&&t.message?t.message:Gn,data:{message:e}});return J.warn("MessageController.revokeMessage failed. ID=".concat(e.ID," code=").concat(n.code," message=").concat(n.message)),Wo(n)}))}},{key:"setMessageRead",value:function(e){var t=this;return new Promise((function(n,r){t.ready((function(){t.readReportHandler.setMessageRead(e).then(n).catch(r)}))}))}},{key:"getMessageList",value:function(e){return this.getMessageHandler.getMessageList(e)}},{key:"createTextMessage",value:function(e){e.currentUser=this.tim.context.identifier;var t=new br(e),n="string"==typeof e.payload?e.payload:e.payload.text,r=new Ue({text:n});return t.setElement(r),t}},{key:"createCustomMessage",value:function(e){e.currentUser=this.tim.context.identifier;var t=new br(e),n=new Rr({data:e.payload.data,description:e.payload.description,extension:e.payload.extension});return t.setElement(n),t}},{key:"createImageMessage",value:function(e){e.currentUser=this.tim.context.identifier;var t=new br(e);if(O){var n=e.payload.file;if(Q(n))return void J.warn("微信小程序环境下调用 createImageMessage 接口时，payload.file 不支持传入 File 对象");var r=n.tempFilePaths[0],o={url:r,name:r.slice(r.lastIndexOf("/")+1),size:n.tempFiles[0].size,type:r.slice(r.lastIndexOf(".")+1).toLowerCase()};e.payload.file=o}else if(R&&Q(e.payload.file)){var i=e.payload.file;e.payload.file={files:[i]}}var s=new rt({imageFormat:"UNKNOWN",uuid:this._generateUUID(),file:e.payload.file});return t.setElement(s),this.messageOptionMap.set(t.messageID,e),t}},{key:"createFileMessage",value:function(e){if(!O){if(R&&Q(e.payload.file)){var t=e.payload.file;e.payload.file={files:[t]}}e.currentUser=this.tim.context.identifier;var n=new br(e),r=new Ar({uuid:this._generateUUID(),file:e.payload.file});return n.setElement(r),this.messageOptionMap.set(n.messageID,e),n}J.warn("微信小程序目前不支持选择文件， createFileMessage 接口不可用！")}},{key:"createAudioMessage",value:function(e){if(O){var t=e.payload.file;if(O){var n={url:t.tempFilePath,name:t.tempFilePath.slice(t.tempFilePath.lastIndexOf("/")+1),size:t.fileSize,second:parseInt(t.duration)/1e3,type:t.tempFilePath.slice(t.tempFilePath.lastIndexOf(".")+1).toLowerCase()};e.payload.file=n}e.currentUser=this.tim.context.identifier;var r=new br(e),o=new it({second:Math.floor(t.duration/1e3),size:t.fileSize,url:t.tempFilePath,uuid:this._generateUUID()});return r.setElement(o),this.messageOptionMap.set(r.messageID,e),r}J.warn("createAudioMessage 目前只支持微信小程序发语音消息")}},{key:"createVideoMessage",value:function(e){e.currentUser=this.tim.context.identifier,e.payload.file.thumbUrl="https://webim-1252463788.cos.ap-shanghai.myqcloud.com/assets/images/transparent.png",e.payload.file.thumbSize=1668;var t={};if(O){if(Q(e.payload.file))return void J.warn("微信小程序环境下调用 createVideoMessage 接口时，payload.file 不支持传入 File 对象");var n=e.payload.file;t.url=n.tempFilePath,t.name=n.tempFilePath.slice(n.tempFilePath.lastIndexOf("/")+1),t.size=n.size,t.second=n.duration,t.type=n.tempFilePath.slice(n.tempFilePath.lastIndexOf(".")+1).toLowerCase()}else if(R){if(Q(e.payload.file)){var r=e.payload.file;e.payload.file.files=[r]}var o=e.payload.file;t.url=window.URL.createObjectURL(o.files[0]),t.name=o.files[0].name,t.size=o.files[0].size,t.second=o.files[0].duration||0,t.type=o.files[0].type.split("/")[1]}e.payload.file.videoFile=t;var i=new br(e),s=new Or({videoFormat:t.type,videoSecond:Number(t.second.toFixed(0)),videoSize:t.size,remoteVideoUrl:"",videoUrl:t.url,videoUUID:this._generateUUID(),thumbUUID:this._generateUUID(),thumbWidth:e.payload.file.width||200,thumbHeight:e.payload.file.height||200,thumbUrl:e.payload.file.thumbUrl,thumbSize:e.payload.file.thumbSize,thumbFormat:e.payload.file.thumbUrl.slice(e.payload.file.thumbUrl.lastIndexOf(".")+1).toLowerCase()});return i.setElement(s),this.messageOptionMap.set(i.messageID,e),i}},{key:"createFaceMessage",value:function(e){e.currentUser=this.tim.context.identifier;var t=new br(e),n=new ot(e.payload);return t.setElement(n),t}},{key:"_generateUUID",value:function(){var e=this.tim.context;return"".concat(e.SDKAppID,"-").concat(e.identifier,"-").concat(function(){for(var e="",t=32;t>0;--t)e+=ye[Math.floor(Math.random()*ve)];return e}())}},{key:"_generateTjgID",value:function(e){return this.tim.context.tinyID+"-"+e.random}},{key:"getMessageOptionByID",value:function(e){return this.messageOptionMap.get(e)}}]),s}(Bo),Tu=function(){function e(t){r(this,e),this.userID="",this.avatar="",this.nick="",this.role="",this.joinTime="",this.lastSendMsgTime="",this.nameCard="",this.muteUntil=0,this.memberCustomField=[],this._initMember(t)}return i(e,[{key:"_initMember",value:function(e){this.updateMember(e)}},{key:"updateMember",value:function(e){var t=[null,void 0,"",0,NaN];e.memberCustomField&&Se(this.memberCustomField,e.memberCustomField),he(this,e,["memberCustomField"],t)}},{key:"updateRole",value:function(e){["Owner","Admin","Member"].indexOf(e)<0||(this.role=e)}},{key:"updateMuteUntil",value:function(e){oe(e)||(this.muteUntil=Math.floor((Date.now()+1e3*e)/1e3))}},{key:"updateNameCard",value:function(e){oe(e)||(this.nameCard=e)}},{key:"updateMemberCustomField",value:function(e){e&&Se(this.memberCustomField,e)}}]),e}(),Eu=function(){function e(t){r(this,e),this.tim=t.tim,this.groupController=t.groupController,this._initListeners()}return i(e,[{key:"_initListeners",value:function(){this.tim.innerEmitter.on(to,this._onReceivedGroupTips,this)}},{key:"_onReceivedGroupTips",value:function(e){var t=this,n=e.data,r=n.result;n.isGroupTip&&r.forEach((function(e){switch(e.payload.operationType){case 1:t._onNewMemberComeIn(e);break;case 2:t._onMemberQuit(e);break;case 3:t._onMemberKickedOut(e);break;case 4:t._onMemberSetAdmin(e);break;case 5:t._onMemberCancelledAdmin(e);break;case 6:t._onGroupProfileModified(e);break;case 7:t._onMemberInfoModified(e);break;default:J.warn("GroupTipsHandler._onReceivedGroupTips Unhandled groupTips. operationType=",e.payload.operationType)}}))}},{key:"_onNewMemberComeIn",value:function(e){var t=e.payload,n=t.memberNum,r=t.groupProfile.groupID,o=this.groupController.getLocalGroupProfile(r);o&&Z(n)&&(o.memberNum=n)}},{key:"_onMemberQuit",value:function(e){var t=e.payload,n=t.memberNum,r=t.groupProfile.groupID,o=this.groupController.getLocalGroupProfile(r);o&&Z(n)&&(o.memberNum=n),this.groupController.deleteLocalGroupMembers(r,e.payload.userIDList)}},{key:"_onMemberKickedOut",value:function(e){var t=e.payload,n=t.memberNum,r=t.groupProfile.groupID,o=this.groupController.getLocalGroupProfile(r);o&&Z(n)&&(o.memberNum=n),this.groupController.deleteLocalGroupMembers(r,e.payload.userIDList)}},{key:"_onMemberSetAdmin",value:function(e){var n=this,r=e.payload.groupProfile.groupID;e.payload.userIDList.forEach((function(e){var o=n.groupController.getLocalGroupMemberInfo(r,e);o&&o.updateRole(t.GRP_MBR_ROLE_ADMIN)}))}},{key:"_onMemberCancelledAdmin",value:function(e){var n=this,r=e.payload.groupProfile.groupID;e.payload.userIDList.forEach((function(e){var o=n.groupController.getLocalGroupMemberInfo(r,e);o&&o.updateRole(t.GRP_MBR_ROLE_MEMBER)}))}},{key:"_onGroupProfileModified",value:function(e){var t=this,n=e.payload.newGroupProfile,r=e.payload.groupProfile.groupID,o=this.groupController.getLocalGroupProfile(r);Object.keys(n).forEach((function(e){switch(e){case"ownerID":t._ownerChaged(o,n);break;default:o[e]=n[e]}})),this.groupController.emitGroupListUpdate(!0,!0)}},{key:"_ownerChaged",value:function(e,n){var r=e.groupID,o=this.groupController.getLocalGroupProfile(r),i=this.tim.context.identifier;if(i===n.ownerID){o.updateGroup({selfInfo:{role:t.GRP_MBR_ROLE_OWNER}});var s=this.groupController.getLocalGroupMemberInfo(r,i),a=this.groupController.getLocalGroupProfile(r).ownerID,u=this.groupController.getLocalGroupMemberInfo(r,a);s&&s.updateRole(t.GRP_MBR_ROLE_OWNER),u&&u.updateRole(t.GRP_MBR_ROLE_MEMBER)}}},{key:"_onMemberInfoModified",value:function(e){var t=this,n=e.payload.groupProfile.groupID;e.payload.memberList.forEach((function(e){var r=t.groupController.getLocalGroupMemberInfo(n,e.userID);r&&e.muteTime&&r.updateMuteUntil(e.muteTime)}))}}]),e}(),ku=function(){function n(e){r(this,n),this.groupController=e.groupController,this.tim=e.tim,this.pendencyMap=new Map,this._initLiceners()}return i(n,[{key:"_initLiceners",value:function(){this.tim.innerEmitter.on(no,this._onReceivedGroupSystemNotice,this),this.tim.innerEmitter.on(Xr,this._clearGroupSystemNotice,this)}},{key:"_clearGroupSystemNotice",value:function(){var e=this;this.getPendencyList().then((function(n){n.forEach((function(t){e.pendencyMap.set("".concat(t.from,"_").concat(t.groupID,"_").concat(t.to),t)}));var r=e.tim.messageController.getLocalMessageList(t.CONV_SYSTEM),o=[];r.forEach((function(t){var n=t.payload,r=n.operatorID,i=n.operationType,s=n.groupProfile;if(i===xe){var a="".concat(r,"_").concat(s.groupID,"_").concat(s.to),u=e.pendencyMap.get(a);u&&Z(u.handled)&&0!==u.handled&&o.push(t)}})),e.groupController.deleteGroupSystemNotice({messageList:o})}))}},{key:"getPendencyList",value:function(e){var t=this;return this.groupController.request({name:"group",action:"getGroupPendency",param:{startTime:e&&e.startTime?e.startTime:0,limit:e&&e.limit?e.limit:10,handleAccount:this.tim.context.identifier}}).then((function(e){var n=e.data,r=n.pendencyList;return 0!==n.nextStartTime?t.getPendencyList({startTime:n.nextStartTime}).then((function(e){return[].concat(_(r),_(e))})):r}))}},{key:"_onReceivedGroupSystemNotice",value:function(t){var n=this,r=t.data,o=r.result;"sync"!==r.type&&o.forEach((function(t){switch(t.payload.operationType){case 1:n._onApplyGroupRequest(t);break;case 2:n._onApplyGroupRequestAgreed(t);break;case 3:n._onApplyGroupRequestRefused(t);break;case 4:n._onMemberKicked(t);break;case 5:n._onGroupDismissed(t);break;case 6:break;case 7:n._onInviteGroup(t);break;case 8:n._onQuitGroup(t);break;case 9:n._onSetManager(t);break;case 10:n._onDeleteManager(t);break;case 11:case 12:case 15:break;case 255:n.groupController.emitOuterEvent(e.GROUP_SYSTEM_NOTICE_RECEIVED,{message:t,type:We})}}))}},{key:"_onApplyGroupRequest",value:function(t){this.groupController.emitOuterEvent(e.GROUP_SYSTEM_NOTICE_RECEIVED,{message:t,type:xe})}},{key:"_onApplyGroupRequestAgreed",value:function(t){var n=this,r=t.payload.groupProfile.groupID;this.groupController.hasLocalGroup(r)||this.groupController.getGroupProfile({groupID:r}).then((function(e){var t=e.data.group;t&&(n.groupController.updateGroupMap([t]),n.groupController.emitGroupListUpdate())})),this.groupController.emitOuterEvent(e.GROUP_SYSTEM_NOTICE_RECEIVED,{message:t,type:Fe})}},{key:"_onApplyGroupRequestRefused",value:function(t){this.groupController.emitOuterEvent(e.GROUP_SYSTEM_NOTICE_RECEIVED,{message:t,type:He})}},{key:"_onMemberKicked",value:function(t){var n=t.payload.groupProfile.groupID;this.groupController.hasLocalGroup(n)&&this.groupController.deleteLocalGroupAndConversation(n),this.groupController.emitOuterEvent(e.GROUP_SYSTEM_NOTICE_RECEIVED,{message:t,type:Be})}},{key:"_onGroupDismissed",value:function(t){var n=t.payload.groupProfile.groupID,r=this.groupController.hasLocalGroup(n),o=this.groupController.AVChatRoomHandler;r&&this.groupController.deleteLocalGroupAndConversation(n),o.checkJoinedAVChatRoomByID(n)&&o.reset(),this.groupController.emitOuterEvent(e.GROUP_SYSTEM_NOTICE_RECEIVED,{message:t,type:Ve})}},{key:"_onInviteGroup",value:function(t){var n=this,r=t.payload.groupProfile.groupID;this.groupController.hasLocalGroup(r)||this.groupController.getGroupProfile({groupID:r}).then((function(e){var t=e.data.group;t&&(n.groupController.updateGroupMap([t]),n.groupController.emitGroupListUpdate())})),this.groupController.emitOuterEvent(e.GROUP_SYSTEM_NOTICE_RECEIVED,{message:t,type:Ke})}},{key:"_onQuitGroup",value:function(t){var n=t.payload.groupProfile.groupID;this.groupController.hasLocalGroup(n)&&this.groupController.deleteLocalGroupAndConversation(n),this.groupController.emitOuterEvent(e.GROUP_SYSTEM_NOTICE_RECEIVED,{message:t,type:je})}},{key:"_onSetManager",value:function(n){var r=n.payload.groupProfile,o=r.to,i=r.groupID,s=this.groupController.getLocalGroupMemberInfo(i,o);s&&s.updateRole(t.GRP_MBR_ROLE_ADMIN),this.groupController.emitOuterEvent(e.GROUP_SYSTEM_NOTICE_RECEIVED,{message:n,type:$e})}},{key:"_onDeleteManager",value:function(n){var r=n.payload.groupProfile,o=r.to,i=r.groupID,s=this.groupController.getLocalGroupMemberInfo(i,o);s&&s.updateRole(t.GRP_MBR_ROLE_MEMBER),this.groupController.emitOuterEvent(e.GROUP_SYSTEM_NOTICE_RECEIVED,{message:n,type:Ye})}},{key:"reset",value:function(){this.pendencyMap.clear()}}]),n}(),wu={3:!0,4:!0,5:!0,6:!0},Au=function(){function n(e){var t=e.tim,o=e.groupController;r(this,n),this.tim=t,this.groupController=o,this.AVChatRoomLoop=null,this.key="",this.startSeq=0,this.group={}}return i(n,[{key:"hasJoinedAVChatRoom",value:function(){return!(!this.group||oe(this.group.groupID))}},{key:"checkJoinedAVChatRoomByID",value:function(e){return!(!this.group&&oe(this.group.groupID))&&e===this.group.groupID}},{key:"getJoinedAVChatRoom",value:function(){return this.hasJoinedAVChatRoom()?this.group:null}},{key:"_updateProperties",value:function(e){var t=this;Object.keys(e).forEach((function(n){t[n]=e[n]}))}},{key:"start",value:function(){var e={key:this.key,startSeq:this.startSeq};if(null===this.AVChatRoomLoop){var t=this.groupController.createTransportCapsule({name:"AVChatRoom",action:"startLongPoll",param:e});this.AVChatRoomLoop=this.tim.connectionController.createRunLoop({pack:t,before:this._updateRequestData.bind(this),success:this._handleSuccess.bind(this),fail:this._handleFailure.bind(this),isAVChatRoomLoop:!0}),this.AVChatRoomLoop.start(),J.log("AVChatRoomHandler.start message channel started")}else this.AVChatRoomLoop.isRunning()||this.AVChatRoomLoop.start()}},{key:"stop",value:function(){null!==this.AVChatRoomLoop&&this.AVChatRoomLoop.isRunning()&&(this.AVChatRoomLoop.abort(),this.AVChatRoomLoop.stop(),J.log("AVChatRoomHandler.stop message channel stopped"))}},{key:"startRunLoop",value:function(e){var t=this;return this._precheck().then((function(){var n=e.longPollingKey,r=e.group;return t._updateProperties({key:n,startSeq:0,group:r||{}}),t.groupController.updateGroupMap([r]),t.groupController.emitGroupListUpdate(!0,!1),t.start(),t.groupController.isLoggedIn()?zo({status:Le.SUCCESS,group:r}):zo({status:Le.SUCCESS})}))}},{key:"joinWithoutAuth",value:function(e){var t=this;return this.groupController.request({name:"group",action:"applyJoinAVChatRoom",param:e}).then((function(n){var r=n.data.longPollingKey;if(oe(r))return Wo(new pt({code:zt,message:ir}));J.log("AVChatRoomHandler.joinWithoutAuth ok. groupID:",e.groupID),t.groupController.emitInnerEvent(bo),t.groupController.emitInnerEvent(No,e.groupID);var o=new du({groupID:e.groupID});return t.startRunLoop({group:o,longPollingKey:r}),new jo({status:Le.SUCCESS})})).catch((function(t){return J.error("AVChatRoomHandler.joinWithoutAuth error:".concat(t.message,". groupID:").concat(e.groupID)),Wo(t)}))}},{key:"_precheck",value:function(){if(!this.hasJoinedAVChatRoom())return Promise.resolve();if(this.groupController.isLoggedIn()){if(!(this.group.selfInfo.role===t.GRP_MBR_ROLE_OWNER||this.group.ownerID===this.tim.loginInfo.identifier))return this.groupController.quitGroup(this.group.groupID);this.groupController.deleteLocalGroupAndConversation(this.group.groupID)}else this.groupController.deleteLocalGroupAndConversation(this.group.groupID);return this.reset(),Promise.resolve()}},{key:"_updateRequestData",value:function(e){e.StartSeq=this.startSeq,e.Key=this.key,this.tim.sumStatController.addTotalCount(Zo)}},{key:"_handleSuccess",value:function(e){this.tim.sumStatController.addSuccessCount(Zo),this.tim.sumStatController.addCost(Zo,e.data.timecost),this.startSeq=e.data.nextSeq,this.key=e.data.key,Array.isArray(e.data.rspMsgList)&&e.data.rspMsgList.forEach((function(e){e.to=e.groupID})),e.data.rspMsgList&&e.data.rspMsgList.length>0&&this._dispatchNotice(e.data.rspMsgList),this.groupController.emitInnerEvent(Mo)}},{key:"_handleFailure",value:function(e){if(e.error)if("ECONNABORTED"===e.error.code||e.error.code===cn)if(e.error.config){var t=e.error.config.url,n=e.error.config.data;J.log("AVChatRoomHandler._handleFailure request timed out. url=".concat(t," data=").concat(n))}else J.log("AVChatRoomHandler._handleFailure request timed out");else J.log("AVChatRoomHandler._handleFailure request failed due to network error");this.groupController.emitInnerEvent(Io)}},{key:"_dispatchNotice",value:function(n){if(re(n)&&0!==n.length){for(var r=null,o=[],i=[],s=0;s<n.length;s++)wu[n[s].event]?(r=this.packMessage(n[s],n[s].event),this.tim.messageController.hasLocalMessage(r.conversationID,r.ID)||(r.conversationType===t.CONV_SYSTEM&&i.push(r),o.push(r))):J.warn("AVChatRoomHandler._dispatchMessage 未处理的 event 类型：",n[s].event);if(i.length>0&&this.groupController.emitInnerEvent(no,{result:i,eventDataList:[],type:"poll"}),0!==o.length){var a=this.packConversationOption(o);a.length>0&&this.groupController.emitInnerEvent(to,{eventDataList:a,type:"poll"}),J.debug("AVChatRoomHandler._dispatchNotice nums=".concat(o.length)),this.groupController.emitOuterEvent(e.MESSAGE_RECEIVED,o)}}}},{key:"packMessage",value:function(e,n){e.currentUser=this.tim.context.identifier,e.conversationType=5===n?t.CONV_SYSTEM:t.CONV_GROUP,e.isSystemMessage=!!e.isSystemMessage;var r=new br(e),o=this.packElements(e,n);return r.setElement(o),r}},{key:"packElements",value:function(e,n){return 4===n||6===n?{type:t.MSG_GRP_TIP,content:u({},e.elements,{groupProfile:e.groupProfile})}:5===n?{type:t.MSG_GRP_SYS_NOTICE,content:u({},e.elements,{groupProfile:e.groupProfile})}:this.tim.bigDataHallwayController.parseElements(e.elements,e.from)}},{key:"packConversationOption",value:function(e){for(var t=new Map,n=0;n<e.length;n++){var r=e[n],o=r.conversationID;if(t.has(o)){var i=t.get(o);i.lastMessage=r,"in"===r.flow&&i.unreadCount++}else t.set(o,{conversationID:r.conversationID,unreadCount:"out"===r.flow?0:1,type:r.conversationType,subType:r.conversationSubType,lastMessage:r})}return _(t.values())}},{key:"reset",value:function(){null!==this.AVChatRoomLoop&&(J.log("AVChatRoomHandler.reset"),this.stop(),this.AVChatRoomLoop=null,this.key="",this.startSeq=0,this.group={})}}]),n}(),Ru=function(n){c(s,n);var o=y(s);function s(e){var t;return r(this,s),(t=o.call(this,e)).groupMap=new Map,t.groupMemberListMap=new Map,t.groupNoticeHandler=new ku({tim:e,groupController:g(t)}),t.groupTipsHandler=new Eu({tim:e,groupController:g(t)}),t.AVChatRoomHandler=new Au({tim:e,groupController:g(t)}),t._initListeners(),t}return i(s,[{key:"createGroup",value:function(e){var n=this;if(!["Public","Private","ChatRoom","AVChatRoom"].includes(e.type)){var r=new pt({code:Ht,message:Qn});return Wo(r)}Te(e.type)&&!oe(e.memberList)&&e.memberList.length>0&&(J.warn("GroupController.createGroup 创建AVChatRoom时不能添加群成员，自动忽略该字段"),e.memberList=void 0),De(e.type)||oe(e.joinOption)||(J.warn("GroupController.createGroup 创建Private/ChatRoom/AVChatRoom群时不能设置字段：joinOption，自动忽略该字段"),e.joinOption=void 0);var o=new oi;return o.setMethod(Ci).setStart(),J.log("GroupController.createGroup."),this.request({name:"group",action:"create",param:e}).then((function(r){if(o.setCode(0).setNetworkType(n.getNetworkType()).setText("groupType=".concat(e.type," groupID=").concat(r.data.groupID)).setEnd(),J.log("GroupController.createGroup ok. groupID:",r.data.groupID),e.type===t.GRP_AVCHATROOM)return n.getGroupProfile({groupID:r.data.groupID});n.updateGroupMap([u({},e,{groupID:r.data.groupID})]);var i=n.tim.createCustomMessage({to:r.data.groupID,conversationType:t.CONV_GROUP,payload:{data:"group_create",extension:"".concat(n.tim.context.identifier,"创建群组")}});return n.tim.sendMessage(i),n.emitGroupListUpdate(),n.getGroupProfile({groupID:r.data.groupID})})).then((function(e){var n=e.data.group;return n.selfInfo.messageRemindType=t.MSG_REMIND_ACPT_AND_NOTE,n.selfInfo.role=t.GRP_MBR_ROLE_OWNER,e})).catch((function(t){return o.setText("groupType=".concat(e.type)),n.probeNetwork().then((function(e){var n=v(e,2),r=n[0],i=n[1];o.setError(t,r,i).setEnd()})),J.error("GroupController.createGroup error:",t),Wo(t)}))}},{key:"joinGroup",value:function(e){if(this.hasLocalGroup(e.groupID)){var n={status:t.JOIN_STATUS_ALREADY_IN_GROUP};return zo(n)}if(e.type===t.GRP_PRIVATE){var r=new pt({code:Bt,message:Zn});return Wo(r)}return J.log("GroupController.joinGroup. groupID:",e.groupID),this.isLoggedIn()?this.applyJoinGroup(e):this.AVChatRoomHandler.joinWithoutAuth(e)}},{key:"quitGroup",value:function(e){var t=this;J.log("GroupController.quitGroup. groupID:",e);var n=this.AVChatRoomHandler.checkJoinedAVChatRoomByID(e);if(n&&!this.isLoggedIn())return J.log("GroupController.quitGroup anonymously ok. groupID:",e),this.deleteLocalGroupAndConversation(e),this.AVChatRoomHandler.reset(),zo({groupID:e});var r=new oi;return r.setMethod(Mi).setStart(),this.request({name:"group",action:"quitGroup",param:{groupID:e}}).then((function(){return r.setCode(0).setNetworkType(t.getNetworkType()).setText("groupID=".concat(e)).setEnd(),J.log("GroupController.quitGroup ok. groupID:",e),n&&t.AVChatRoomHandler.reset(),t.deleteLocalGroupAndConversation(e),new jo({groupID:e})})).catch((function(n){return r.setText("groupID=".concat(e)),t.probeNetwork().then((function(e){var t=v(e,2),o=t[0],i=t[1];r.setError(n,o,i).setEnd()})),J.error("GroupController.quitGroup error.  error:".concat(n,". groupID:").concat(e)),Wo(n)}))}},{key:"changeGroupOwner",value:function(e){var n=this;if(this.hasLocalGroup(e.groupID)&&this.getLocalGroupProfile(e.groupID).type===t.GRP_AVCHATROOM)return Wo(new pt({code:Vt,message:er}));if(e.newOwnerID===this.tim.loginInfo.identifier)return Wo(new pt({code:Kt,message:tr}));var r=new oi;return r.setMethod(Si).setStart(),J.log("GroupController.changeGroupOwner. groupID:",e.groupID),this.request({name:"group",action:"changeGroupOwner",param:e}).then((function(){r.setCode(0).setNetworkType(n.getNetworkType()).setText("groupID=".concat(e.groupID)).setEnd(),J.log("GroupController.changeGroupOwner ok. groupID:",e.groupID);var t=e.groupID,o=e.newOwnerID;n.groupMap.get(t).ownerID=o;var i=n.groupMemberListMap.get(t);if(i instanceof Map){var s=i.get(n.tim.loginInfo.identifier);oe(s)||(s.updateRole("Member"),n.groupMap.get(t).selfInfo.role="Member");var a=i.get(o);oe(a)||a.updateRole("Owner")}return n.emitGroupListUpdate(!0,!1),new jo({group:n.groupMap.get(t)})})).catch((function(t){return r.setText("groupID=".concat(e.groupID)),n.probeNetwork().then((function(e){var n=v(e,2),o=n[0],i=n[1];r.setError(t,o,i).setEnd()})),J.error("GroupController.changeGroupOwner error:".concat(t,". groupID:").concat(e.groupID)),Wo(t)}))}},{key:"dismissGroup",value:function(e){var n=this;if(this.hasLocalGroup(e)&&this.getLocalGroupProfile(e).type===t.GRP_PRIVATE)return Wo(new pt({code:jt,message:nr}));var r=new oi;return r.setMethod(Di).setStart(),J.log("GroupController.dismissGroup. groupID:".concat(e)),this.request({name:"group",action:"destroyGroup",param:{groupID:e}}).then((function(){return r.setCode(0).setNetworkType(n.getNetworkType()).setText("groupID=".concat(e)).setEnd(),J.log("GroupController.dismissGroup ok. groupID:".concat(e)),n.deleteLocalGroupAndConversation(e),n.checkJoinedAVChatRoomByID(e)&&n.AVChatRoomHandler.reset(),new jo({groupID:e})})).catch((function(t){return r.setText("groupID=".concat(e)),n.probeNetwork().then((function(e){var n=v(e,2),o=n[0],i=n[1];r.setError(t,o,i).setEnd()})),J.error("GroupController.dismissGroup error:".concat(t,". groupID:").concat(e)),Wo(t)}))}},{key:"updateGroupProfile",value:function(e){var t=this;!this.hasLocalGroup(e.groupID)||De(this.getLocalGroupProfile(e.groupID).type)||oe(e.joinOption)||(J.warn("GroupController.updateGroupProfile Private/ChatRoom/AVChatRoom群不能设置字段：joinOption，自动忽略该字段"),e.joinOption=void 0);var n=new oi;return n.setMethod(Ti).setStart(),n.setText("groupID=".concat(e.groupID)),J.log("GroupController.updateGroupProfile. groupID:",e.groupID),this.request({name:"group",action:"updateGroupProfile",param:e}).then((function(){(n.setCode(0).setNetworkType(t.getNetworkType()).setEnd(),J.log("GroupController.updateGroupProfile ok. groupID:",e.groupID),t.hasLocalGroup(e.groupID))&&(t.groupMap.get(e.groupID).updateGroup(e),t._setStorageGroupList());return new jo({group:t.groupMap.get(e.groupID)})})).catch((function(r){return t.probeNetwork().then((function(e){var t=v(e,2),o=t[0],i=t[1];n.setError(r,o,i).setEnd()})),J.log("GroupController.updateGroupProfile failed. error:".concat(fe(r)," groupID:").concat(e.groupID)),Wo(r)}))}},{key:"setGroupMemberRole",value:function(e){var n=this,r=e.groupID,o=e.userID,i=e.role,s=this.groupMap.get(r);if(s.selfInfo.role!==t.GRP_MBR_ROLE_OWNER)return Wo(new pt({code:Xt,message:ar}));if([t.GRP_PRIVATE,t.GRP_AVCHATROOM].includes(s.type))return Wo(new pt({code:Jt,message:ur}));if([t.GRP_MBR_ROLE_ADMIN,t.GRP_MBR_ROLE_MEMBER].indexOf(i)<0)return Wo(new pt({code:Qt,message:cr}));if(o===this.tim.loginInfo.identifier)return Wo(new pt({code:Zt,message:lr}));var a=new oi;return a.setMethod(Oi).setStart(),a.setText("groupID=".concat(r," userID=").concat(o," role=").concat(i)),J.log("GroupController.setGroupMemberRole. groupID:".concat(r,". userID: ").concat(o)),this._modifyGroupMemberInfo({groupID:r,userID:o,role:i}).then((function(e){return a.setCode(0).setNetworkType(n.getNetworkType()).setEnd(),J.log("GroupController.setGroupMemberRole ok. groupID:".concat(r,". userID: ").concat(o)),new jo({group:s,member:e})})).catch((function(e){return n.probeNetwork().then((function(t){var n=v(t,2),r=n[0],o=n[1];a.setError(e,r,o).setEnd()})),J.error("GroupController.setGroupMemberRole error:".concat(e,". groupID:").concat(r,". userID:").concat(o)),Wo(e)}))}},{key:"setGroupMemberMuteTime",value:function(e){var t=this,n=e.groupID,r=e.userID,o=e.muteTime;if(r===this.tim.loginInfo.identifier)return Wo(new pt({code:en,message:pr}));J.log("GroupController.setGroupMemberMuteTime. groupID:".concat(n,". userID: ").concat(r));var i=new oi;return i.setMethod(Ai).setStart(),i.setText("groupID=".concat(n," userID=").concat(r," muteTime=").concat(o)),this._modifyGroupMemberInfo({groupID:n,userID:r,muteTime:o}).then((function(e){return i.setCode(0).setNetworkType(t.getNetworkType()).setEnd(),J.log("GroupController.setGroupMemberMuteTime ok. groupID:".concat(n,". userID: ").concat(r)),new jo({group:t.getLocalGroupProfile(n),member:e})})).catch((function(e){return t.probeNetwork().then((function(t){var n=v(t,2),r=n[0],o=n[1];i.setError(e,r,o).setEnd()})),J.error("GroupController.setGroupMemberMuteTime error:".concat(e,". groupID:").concat(n,". userID:").concat(r)),Wo(e)}))}},{key:"setMessageRemindType",value:function(e){var t=this;J.log("GroupController.setMessageRemindType. groupID:".concat(e.groupID,". userID: ").concat(e.userID||this.tim.loginInfo.identifier));var n=e.groupID,r=e.messageRemindType;return this._modifyGroupMemberInfo({groupID:n,messageRemindType:r,userID:this.tim.loginInfo.identifier}).then((function(){J.log("GroupController.setMessageRemindType ok. groupID:".concat(e.groupID,". userID: ").concat(e.userID||t.tim.loginInfo.identifier));var n=t.getLocalGroupProfile(e.groupID);return n&&(n.selfInfo.messageRemindType=r),new jo({group:n})})).catch((function(n){return J.error("GroupController.setMessageRemindType error:".concat(n,". groupID:").concat(e.groupID,". userID:").concat(e.userID||t.tim.loginInfo.identifier)),Wo(n)}))}},{key:"setGroupMemberNameCard",value:function(e){var t=this,n=e.groupID,r=e.userID,o=void 0===r?this.tim.loginInfo.identifier:r,i=e.nameCard;J.log("GroupController.setGroupMemberNameCard. groupID:".concat(n,". userID: ").concat(o));var s=new oi;return s.setMethod(Ri).setStart(),s.setText("groupID=".concat(n," userID=").concat(o," nameCard=").concat(i)),this._modifyGroupMemberInfo({groupID:n,userID:o,nameCard:i}).then((function(e){J.log("GroupController.setGroupMemberNameCard ok. groupID:".concat(n,". userID: ").concat(o)),s.setCode(0).setNetworkType(t.getNetworkType()).setEnd();var r=t.getLocalGroupProfile(n);return o===t.tim.loginInfo.identifier&&r&&r.setSelfNameCard(i),new jo({group:r,member:e})})).catch((function(e){return t.probeNetwork().then((function(t){var n=v(t,2),r=n[0],o=n[1];s.setError(e,r,o).setEnd()})),J.error("GroupController.setGroupMemberNameCard error:".concat(e,". groupID:").concat(n,". userID:").concat(o)),Wo(e)}))}},{key:"setGroupMemberCustomField",value:function(e){var t=this,n=e.groupID,r=e.userID,o=void 0===r?this.tim.loginInfo.identifier:r,i=e.memberCustomField;J.log("GroupController.setGroupMemberCustomField. groupID:".concat(n,". userID: ").concat(o));var s=new oi;return s.setMethod(Li).setStart(),s.setText("groupID=".concat(n," userID=").concat(o," memberCustomField=").concat(i)),this._modifyGroupMemberInfo({groupID:n,userID:o,memberCustomField:i}).then((function(e){return s.setCode(0).setNetworkType(t.getNetworkType()).setEnd(),J.log("GroupController.setGroupMemberCustomField ok. groupID:".concat(n,". userID: ").concat(o)),new jo({group:t.groupMap.get(n),member:e})})).catch((function(e){return t.probeNetwork().then((function(t){var n=v(t,2),r=n[0],o=n[1];s.setError(e,r,o).setEnd()})),J.error("GroupController.setGroupMemberCustomField error:".concat(e,". groupID:").concat(n,". userID:").concat(o)),Wo(e)}))}},{key:"getGroupList",value:function(e){var t=this,n=new oi;n.setMethod(Ei).setStart(),J.log("GroupController.getGroupList");var r={introduction:"Introduction",notification:"Notification",createTime:"CreateTime",ownerID:"Owner_Account",lastInfoTime:"LastInfoTime",memberNum:"MemberNum",maxMemberNum:"MaxMemberNum",joinOption:"ApplyJoinOption"},o=["Type","Name","FaceUrl","NextMsgSeq","LastMsgTime"];return e&&e.groupProfileFilter&&e.groupProfileFilter.forEach((function(e){r[e]&&o.push(r[e])})),this.request({name:"group",action:"list",param:{responseFilter:{groupBaseInfoFilter:o,selfInfoFilter:["Role","JoinTime","MsgFlag"]}}}).then((function(e){var r=e.data.groups;return n.setCode(0).setNetworkType(t.getNetworkType()).setText(r.length).setEnd(),J.log("GroupController.getGroupList ok. nums=".concat(r.length)),t._groupListTreeShaking(r),t.updateGroupMap(r),t.tempConversationList&&(J.log("GroupController.getGroupList update last message with tempConversationList, nums=".concat(t.tempConversationList.length)),t._handleUpdateGroupLastMessage({data:t.tempConversationList}),t.tempConversationList=null),t.emitGroupListUpdate(),new jo({groupList:t.getLocalGroups()})})).catch((function(e){return t.probeNetwork().then((function(t){var r=v(t,2),o=r[0],i=r[1];n.setError(e,o,i).setEnd()})),J.error("GroupController.getGroupList error: ",e),Wo(e)}))}},{key:"getGroupMemberList",value:function(e){var t=this,n=e.groupID,r=e.offset,o=void 0===r?0:r,i=e.count,s=void 0===i?15:i;J.log("GroupController.getGroupMemberList groupID: ".concat(n," offset: ").concat(o," count: ").concat(s));var a=[];return this.request({name:"group",action:"getGroupMemberList",param:{groupID:n,offset:o,limit:s>100?100:s,memberInfoFilter:["Role","NameCard"]}}).then((function(e){var r=e.data,o=r.members,i=r.memberNum;return re(o)&&0!==o.length?(t.hasLocalGroup(n)&&(t.getLocalGroupProfile(n).memberNum=i),a=t._updateLocalGroupMemberMap(n,o),t.tim.getUserProfile({userIDList:o.map((function(e){return e.userID})),tagList:[Ze.NICK,Ze.AVATAR]})):Promise.resolve([])})).then((function(e){var r=e.data;if(!re(r)||0===r.length)return zo({memberList:[]});var o=r.map((function(e){return{userID:e.userID,nick:e.nick,avatar:e.avatar}}));return t._updateLocalGroupMemberMap(n,o),J.log("GroupController.getGroupMemberList ok."),new jo({memberList:a})})).catch((function(e){return J.error("GroupController.getGroupMemberList error: ",e),Wo(e)}))}},{key:"getLocalGroups",value:function(){return _(this.groupMap.values())}},{key:"getLocalGroupProfile",value:function(e){return this.groupMap.get(e)}},{key:"hasLocalGroup",value:function(e){return this.groupMap.has(e)}},{key:"getLocalGroupMemberInfo",value:function(e,t){return this.groupMemberListMap.has(e)?this.groupMemberListMap.get(e).get(t):null}},{key:"setLocalGroupMember",value:function(e,t){if(this.groupMemberListMap.has(e))this.groupMemberListMap.get(e).set(t.userID,t);else{var n=(new Map).set(t.userID,t);this.groupMemberListMap.set(e,n)}}},{key:"hasLocalGroupMember",value:function(e,t){return this.groupMemberListMap.has(e)&&this.groupMemberListMap.get(e).has(t)}},{key:"hasLocalGroupMemberMap",value:function(e){return this.groupMemberListMap.has(e)}},{key:"getGroupProfile",value:function(e){var t=this;J.log("GroupController.getGroupProfile. groupID:",e.groupID);var n=e.groupID,r=e.groupCustomFieldFilter,o={groupIDList:[n],responseFilter:{groupBaseInfoFilter:["Type","Name","Introduction","Notification","FaceUrl","Owner_Account","CreateTime","InfoSeq","LastInfoTime","LastMsgTime","MemberNum","MaxMemberNum","ApplyJoinOption","NextMsgSeq"],groupCustomFieldFilter:r}};return this.getGroupProfileAdvance(o).then((function(r){var o,i=r.data,s=i.successGroupList,a=i.failureGroupList;return J.log("GroupController.getGroupProfile ok. groupID:",e.groupID),a.length>0?Wo(a[0]):(Te(s[0].type)&&!t.hasLocalGroup(n)?o=new du(s[0]):(t.updateGroupMap(s),o=t.getLocalGroupProfile(n)),o&&o.selfInfo&&!o.selfInfo.nameCard?t.updateSelfInfo(o).then((function(e){return new jo({group:e})})):new jo({group:o}))})).catch((function(t){return J.error("GroupController.getGroupProfile error:".concat(t,". groupID:").concat(e.groupID)),Wo(t)}))}},{key:"getGroupMemberProfile",value:function(e){var t=this;J.log("GroupController.getGroupMemberProfile groupID:".concat(e.groupID," userIDList:").concat(e.userIDList.join(","))),e.userIDList.length>50&&(e.userIDList=e.userIDList.slice(0,50));var n=e.groupID,r=e.userIDList;return this._getGroupMemberProfileAdvance(u({},e,{userIDList:r})).then((function(e){var r=e.data.members;return re(r)&&0!==r.length?(t._updateLocalGroupMemberMap(n,r),t.tim.getUserProfile({userIDList:r.map((function(e){return e.userID})),tagList:[Ze.NICK,Ze.AVATAR]})):zo([])})).then((function(e){var o=e.data.map((function(e){return{userID:e.userID,nick:e.nick,avatar:e.avatar}}));t._updateLocalGroupMemberMap(n,o);var i=r.filter((function(e){return t.hasLocalGroupMember(n,e)})).map((function(e){return t.getLocalGroupMemberInfo(n,e)}));return new jo({memberList:i})}))}},{key:"_getGroupMemberProfileAdvance",value:function(e){return this.request({name:"group",action:"getGroupMemberProfile",param:u({},e,{memberInfoFilter:e.memberInfoFilter?e.memberInfoFilter:["Role","JoinTime","NameCard","ShutUpUntil"]})})}},{key:"updateSelfInfo",value:function(e){var t=e.groupID;J.log("GroupController.updateSelfInfo groupID:",t);var n={groupID:t,userIDList:[this.tim.loginInfo.identifier]};return this.getGroupMemberProfile(n).then((function(n){var r=n.data.memberList;return J.log("GroupController.updateSelfInfo ok. groupID:",t),e&&0!==r.length&&e.updateSelfInfo(r[0]),e}))}},{key:"addGroupMember",value:function(e){var t=this.getLocalGroupProfile(e.groupID);if(Te(t.type)){var n=new pt({code:Yt,message:or});return Wo(n)}return e.userIDList=e.userIDList.map((function(e){return{userID:e}})),J.log("GroupController.addGroupMember. groupID:",e.groupID),this.request({name:"group",action:"addGroupMember",param:e}).then((function(n){var r=n.data.members;J.log("GroupController.addGroupMember ok. groupID:",e.groupID);var o=r.filter((function(e){return 1===e.result})).map((function(e){return e.userID})),i=r.filter((function(e){return 0===e.result})).map((function(e){return e.userID})),s=r.filter((function(e){return 2===e.result})).map((function(e){return e.userID}));return 0===o.length?new jo({successUserIDList:o,failureUserIDList:i,existedUserIDList:s}):(t.memberNum+=o.length,new jo({successUserIDList:o,failureUserIDList:i,existedUserIDList:s,group:t}))})).catch((function(t){return J.error("GroupController.addGroupMember error:".concat(t,", groupID:").concat(e.groupID)),Wo(t)}))}},{key:"deleteGroupMember",value:function(e){var n=this;J.log("GroupController.deleteGroupMember groupID:".concat(e.groupID," userIDList:").concat(e.userIDList));var r=this.getLocalGroupProfile(e.groupID);return r.type===t.GRP_AVCHATROOM?Wo(new pt({code:Wt,message:sr})):this.request({name:"group",action:"deleteGroupMember",param:e}).then((function(){return J.log("GroupController.deleteGroupMember ok"),r.memberNum--,n.deleteLocalGroupMembers(e.groupID,e.userIDList),new jo({group:r,userIDList:e.userIDList})})).catch((function(t){return J.error("GroupController.deleteGroupMember error:".concat(t.code,", groupID:").concat(e.groupID)),Wo(t)}))}},{key:"searchGroupByID",value:function(e){var t={groupIDList:[e]};return J.log("GroupController.searchGroupByID. groupID:".concat(e)),this.request({name:"group",action:"searchGroupByID",param:t}).then((function(t){var n=t.data.groupProfile;if(n[0].errorCode!==Ne.SUCCESS)throw new pt({code:n[0].errorCode,message:n[0].errorInfo});return J.log("GroupController.searchGroupByID ok. groupID:".concat(e)),new jo({group:new du(n[0])})})).catch((function(t){return J.warn("GroupController.searchGroupByID error:".concat(fe(t),", groupID:").concat(e)),Wo(t)}))}},{key:"applyJoinGroup",value:function(e){var t=this,n=new oi;return n.setMethod(Ii).setStart(),this.request({name:"group",action:"applyJoinGroup",param:e}).then((function(r){var o=r.data,i=o.joinedStatus,s=o.longPollingKey;switch(n.setCode(0).setNetworkType(t.getNetworkType()).setText("groupID=".concat(e.groupID," joinedStatus=").concat(i)).setEnd(),J.log("GroupController.joinGroup ok. groupID:",e.groupID),i){case Le.WAIT_APPROVAL:return new jo({status:Le.WAIT_APPROVAL});case Le.SUCCESS:return t.getGroupProfile({groupID:e.groupID}).then((function(n){var r=n.data.group,o={status:Le.SUCCESS,group:r};return oe(s)?new jo(o):(t.emitInnerEvent(No,e.groupID),t.AVChatRoomHandler.startRunLoop({longPollingKey:s,group:r}))}));default:var a=new pt({code:$t,message:rr});return J.error("GroupController.joinGroup error:".concat(a,". groupID:").concat(e.groupID)),Wo(a)}})).catch((function(r){return n.setText("groupID=".concat(e.groupID)),t.probeNetwork().then((function(e){var t=v(e,2),o=t[0],i=t[1];n.setError(r,o,i).setEnd()})),J.error("GroupController.joinGroup error:".concat(r,". groupID:").concat(e.groupID)),Wo(r)}))}},{key:"applyJoinAVChatRoom",value:function(e){return this.AVChatRoomHandler.applyJoinAVChatRoom(e)}},{key:"handleGroupApplication",value:function(e){var t=this,n=e.message.payload,r=n.groupProfile.groupID,o=n.authentication,i=n.messageKey,s=n.operatorID;return J.log("GroupController.handleApplication. groupID:",r),this.request({name:"group",action:"handleApplyJoinGroup",param:u({},e,{applicant:s,groupID:r,authentication:o,messageKey:i})}).then((function(){return J.log("GroupController.handleApplication ok. groupID:",r),t.deleteGroupSystemNotice({messageList:[e.message]}),new jo({group:t.getLocalGroupProfile(r)})})).catch((function(e){return J.error("GroupController.handleApplication error.  error:".concat(e,". groupID:").concat(r)),Wo(e)}))}},{key:"deleteGroupSystemNotice",value:function(e){var n=this;return re(e.messageList)&&0!==e.messageList.length?(J.log("GroupController.deleteGroupSystemNotice "+e.messageList.map((function(e){return e.ID}))),this.request({name:"group",action:"deleteGroupSystemNotice",param:{messageListToDelete:e.messageList.map((function(e){return{from:t.CONV_SYSTEM,messageSeq:e.clientSequence,messageRandom:e.random}}))}}).then((function(){return J.log("GroupController.deleteGroupSystemNotice ok"),e.messageList.forEach((function(e){n.tim.messageController.deleteLocalMessage(e)})),new jo})).catch((function(e){return J.error("GroupController.deleteGroupSystemNotice error:",e),Wo(e)}))):zo()}},{key:"getGroupProfileAdvance",value:function(e){return re(e.groupIDList)&&e.groupIDList.length>50&&(J.warn("GroupController.getGroupProfileAdvance 获取群资料的数量不能超过50个"),e.groupIDList.length=50),J.log("GroupController.getGroupProfileAdvance. groupIDList:",e.groupIDList),this.request({name:"group",action:"query",param:e}).then((function(e){J.log("GroupController.getGroupProfileAdvance ok.");var t=e.data.groups,n=t.filter((function(e){return oe(e.errorCode)||e.errorCode===Ne.SUCCESS})),r=t.filter((function(e){return e.errorCode&&e.errorCode!==Ne.SUCCESS})).map((function(e){return new pt({code:Number("500".concat(e.errorCode)),message:e.errorInfo,data:{groupID:e.groupID}})}));return new jo({successGroupList:n,failureGroupList:r})})).catch((function(t){return J.error("GroupController.getGroupProfileAdvance error:".concat(t,". groupID:").concat(e.groupID)),Wo(t)}))}},{key:"_deleteLocalGroup",value:function(e){return this.groupMap.delete(e),this.groupMemberListMap.delete(e),this._setStorageGroupList(),this.groupMap.has(e)&&this.groupMemberListMap.has(e)}},{key:"_initGroupList",value:function(){var e=this,t=new oi;t.setMethod(ki).setStart(),J.time(ni),J.log("GroupController._initGroupList");var n=this._getStorageGroupList();re(n)&&n.length>0?(n.forEach((function(t){e.groupMap.set(t.groupID,new du(t))})),this.emitGroupListUpdate(!0,!1),t.setCode(0).setNetworkType(this.getNetworkType()).setText(this.groupMap.size).setEnd()):t.setCode(0).setNetworkType(this.getNetworkType()).setText(0).setEnd(),this.triggerReady(),J.log("GroupController._initGroupList ok. initCost=".concat(J.timeEnd(ni),"ms")),this.getGroupList()}},{key:"_initListeners",value:function(){var e=this.tim.innerEmitter;e.once(Yr,this._initGroupList,this),e.on(Ao,this._handleUpdateGroupLastMessage,this),e.on(to,this._handleReceivedGroupMessage,this),e.on(Lo,this._handleProfileUpdated,this)}},{key:"emitGroupListUpdate",value:function(){var t=!(arguments.length>0&&void 0!==arguments[0])||arguments[0],n=!(arguments.length>1&&void 0!==arguments[1])||arguments[1],r=this.getLocalGroups();n&&this.emitInnerEvent(So,r),t&&this.emitOuterEvent(e.GROUP_LIST_UPDATED,r)}},{key:"_handleReceivedGroupMessage",value:function(e){var n=this,r=e.data.eventDataList;Array.isArray(r)&&r.forEach((function(e){var r=e.conversationID.replace(t.CONV_GROUP,"");n.groupMap.has(r)&&(n.groupMap.get(r).nextMessageSeq=e.lastMessage.sequence+1)}))}},{key:"_onReceivedGroupSystemNotice",value:function(e){var t=e.data;this.groupNoticeHandler._onReceivedGroupNotice(t)}},{key:"_handleUpdateGroupLastMessage",value:function(e){var n=e.data;if(J.log("GroupController._handleUpdateGroupLastMessage convNums=".concat(n.length," groupNums=").concat(this.groupMap.size)),0!==this.groupMap.size){for(var r,o,i,s=!1,a=0,u=n.length;a<u;a++)(r=n[a]).conversationID&&r.type!==t.CONV_GROUP&&(o=r.conversationID.split(/^GROUP/)[1],(i=this.getLocalGroupProfile(o))&&(i.lastMessage=r.lastMessage,s=!0));s&&(this.groupMap=this._sortLocalGroupList(this.groupMap),this.emitGroupListUpdate(!0,!1))}else this.tempConversationList=n}},{key:"_sortLocalGroupList",value:function(e){var t=_(e).filter((function(e){var t=v(e,2);t[0];return!Ae(t[1].lastMessage)}));return t.sort((function(e,t){return t[1].lastMessage.lastTime-e[1].lastMessage.lastTime})),new Map([].concat(_(t),_(e)))}},{key:"_getStorageGroupList",value:function(){return this.tim.storage.getItem("groupMap")}},{key:"_setStorageGroupList",value:function(){var e=this.getLocalGroups().filter((function(e){var t=e.type;return!Te(t)})).slice(0,20).map((function(e){return{groupID:e.groupID,name:e.name,avatar:e.avatar,type:e.type}}));this.tim.storage.setItem("groupMap",e)}},{key:"updateGroupMap",value:function(e){var t=this;e.forEach((function(e){t.groupMap.has(e.groupID)?t.groupMap.get(e.groupID).updateGroup(e):t.groupMap.set(e.groupID,new du(e))})),this._setStorageGroupList()}},{key:"_updateLocalGroupMemberMap",value:function(e,t){var n=this;return re(t)&&0!==t.length?t.map((function(t){return n.hasLocalGroupMember(e,t.userID)?n.getLocalGroupMemberInfo(e,t.userID).updateMember(t):n.setLocalGroupMember(e,new Tu(t)),n.getLocalGroupMemberInfo(e,t.userID)})):[]}},{key:"deleteLocalGroupMembers",value:function(e,t){var n=this.groupMemberListMap.get(e);n&&t.forEach((function(e){n.delete(e)}))}},{key:"_modifyGroupMemberInfo",value:function(e){var t=this,n=e.groupID,r=e.userID;return this.request({name:"group",action:"modifyGroupMemberInfo",param:e}).then((function(){if(t.hasLocalGroupMember(n,r)){var o=t.getLocalGroupMemberInfo(n,r);return oe(e.muteTime)||o.updateMuteUntil(e.muteTime),oe(e.role)||o.updateRole(e.role),oe(e.nameCard)||o.updateNameCard(e.nameCard),oe(e.memberCustomField)||o.updateMemberCustomField(e.memberCustomField),o}return t.getGroupMemberProfile({groupID:n,userIDList:[r]}).then((function(e){return v(e.data.memberList,1)[0]}))}))}},{key:"_groupListTreeShaking",value:function(e){for(var t=new Map(_(this.groupMap)),n=0,r=e.length;n<r;n++)t.delete(e[n].groupID);this.AVChatRoomHandler.hasJoinedAVChatRoom()&&t.delete(this.AVChatRoomHandler.group.groupID);for(var o=_(t.keys()),i=0,s=o.length;i<s;i++)this.groupMap.delete(o[i])}},{key:"_handleProfileUpdated",value:function(e){for(var t=this,n=e.data,r=function(e){var r=n[e];t.groupMemberListMap.forEach((function(e){e.has(r.userID)&&e.get(r.userID).updateMember({nick:r.nick,avatar:r.avatar})}))},o=0;o<n.length;o++)r(o)}},{key:"getJoinedAVChatRoom",value:function(){return this.AVChatRoomHandler.getJoinedAVChatRoom()}},{key:"deleteLocalGroupAndConversation",value:function(e){this._deleteLocalGroup(e),this.tim.conversationController.deleteLocalConversation("GROUP".concat(e)),this.emitGroupListUpdate(!0,!1)}},{key:"checkJoinedAVChatRoomByID",value:function(e){return this.AVChatRoomHandler.checkJoinedAVChatRoomByID(e)}},{key:"getGroupLastSequence",value:function(e){var t=this,n=new oi;n.setMethod(wi).setStart();var r=0;if(this.hasLocalGroup(e)){var o=this.getLocalGroupProfile(e);if(o.lastMessage.lastSequence>0)return r=o.lastMessage.lastSequence,J.log("GroupController.getGroupLastSequence got lastSequence=".concat(r," from local group profile[lastMessage.lastSequence]. groupID=").concat(e)),n.setCode(0).setNetworkType(this.getNetworkType()).setText("got lastSequence=".concat(r," from local group profile[lastMessage.lastSequence]. groupID=").concat(e)).setEnd(),Promise.resolve(r);if(o.nextMessageSeq>1)return r=o.nextMessageSeq-1,J.log("GroupController.getGroupLastSequence got lastSequence=".concat(r," from local group profile[nextMessageSeq]. groupID=").concat(e)),n.setCode(0).setNetworkType(this.getNetworkType()).setText("got lastSequence=".concat(r," from local group profile[nextMessageSeq]. groupID=").concat(e)).setEnd(),Promise.resolve(r)}var i="GROUP".concat(e),s=this.tim.conversationController.getLocalConversation(i);if(s&&s.lastMessage.lastSequence)return r=s.lastMessage.lastSequence,J.log("GroupController.getGroupLastSequence got lastSequence=".concat(r," from local conversation profile[lastMessage.lastSequence]. groupID=").concat(e)),n.setCode(0).setNetworkType(this.getNetworkType()).setText("got lastSequence=".concat(r," from local conversation profile[lastMessage.lastSequence]. groupID=").concat(e)).setEnd(),Promise.resolve(r);var a={groupIDList:[e],responseFilter:{groupBaseInfoFilter:["NextMsgSeq"]}};return this.getGroupProfileAdvance(a).then((function(o){var i=o.data.successGroupList;return Ae(i)?J.log("GroupController.getGroupLastSequence successGroupList is empty. groupID=".concat(e)):(r=i[0].nextMessageSeq-1,J.log("GroupController.getGroupLastSequence got lastSequence=".concat(r," from getGroupProfileAdvance. groupID=").concat(e))),n.setCode(0).setNetworkType(t.getNetworkType()).setText("got lastSequence=".concat(r," from getGroupProfileAdvance. groupID=").concat(e)).setEnd(),r})).catch((function(r){return t.probeNetwork().then((function(t){var o=v(t,2),i=o[0],s=o[1];n.setError(r,i,s).setText("get lastSequence failed from getGroupProfileAdvance. groupID=".concat(e)).setEnd()})),J.warn("GroupController.getGroupLastSequence failed. ".concat(r)),Wo(r)}))}},{key:"reset",value:function(){this.groupMap.clear(),this.groupMemberListMap.clear(),this.resetReady(),this.groupNoticeHandler.reset(),this.AVChatRoomHandler.reset(),this.tim.innerEmitter.once(Yr,this._initGroupList,this)}}]),s}(Bo),Ou=function(n){c(s,n);var o=y(s);function s(e){var n;r(this,s),(n=o.call(this,e)).REALTIME_MESSAGE_TIMEOUT=11e4,n.LONGPOLLING_ID_TIMEOUT=3e5,n._currentState=t.NET_STATE_CONNECTED,n._status={OPENIM:{lastResponseReceivedTime:0,jitterCount:0,failedCount:0},AVCHATROOM:{lastResponseReceivedTime:0,jitterCount:0,failedCount:0}};var i=n.tim.innerEmitter;return i.on(oo,n._onGetLongPollIDFailed,g(n)),i.on(so,n._onOpenIMResponseOK,g(n)),i.on(io,n._onOpenIMRequestFailed,g(n)),i.on(Mo,n._onAVChatroomResponseOK,g(n)),i.on(Io,n._onAVChatroomRequestFailed,g(n)),n}return i(s,[{key:"_onGetLongPollIDFailed",value:function(){this._currentState!==t.NET_STATE_DISCONNECTED&&this._emitNetStateChangeEvent(t.NET_STATE_DISCONNECTED)}},{key:"_onOpenIMResponseOK",value:function(){this._onResponseOK("OPENIM")}},{key:"_onOpenIMRequestFailed",value:function(){this._onRequestFailed("OPENIM")}},{key:"_onAVChatroomResponseOK",value:function(){this.isLoggedIn()||this._onResponseOK("AVCHATROOM")}},{key:"_onAVChatroomRequestFailed",value:function(){this.isLoggedIn()||this._onRequestFailed("AVCHATROOM")}},{key:"_onResponseOK",value:function(e){var n=this._status[e],r=Date.now();if(0!==n.lastResponseReceivedTime){var o=r-n.lastResponseReceivedTime;if(J.debug("StatusController._onResponseOK key=".concat(e," currentState=").concat(this._currentState," interval=").concat(o," failedCount=").concat(n.failedCount," jitterCount=").concat(n.jitterCount)),n.failedCount>0&&(n.failedCount=0,n.jitterCount+=1,this._currentState!==t.NET_STATE_CONNECTED&&this._emitNetStateChangeEvent(t.NET_STATE_CONNECTED)),o<=this.REALTIME_MESSAGE_TIMEOUT){if(n.jitterCount>=3){var i=new oi;i.setMethod(Pi).setStart(),i.setCode(0).setText("".concat(e,"-").concat(o,"-").concat(n.jitterCount)).setNetworkType(this.getNetworkType()).setEnd(),n.jitterCount=0}}else if(o>=this.REALTIME_MESSAGE_TIMEOUT&&o<this.LONGPOLLING_ID_TIMEOUT){var s=new oi;s.setMethod(Gi).setStart(),s.setCode(0).setText("".concat(e,"-").concat(o)).setNetworkType(this.getNetworkType()).setEnd(),J.warn("StatusController._onResponseOK, fast start. key=".concat(e," interval=").concat(o," ms")),this.emitInnerEvent(ao)}else if(o>=this.LONGPOLLING_ID_TIMEOUT){var a=new oi;a.setMethod(Ui).setStart(),a.setCode(0).setText("".concat(e,"-").concat(o)).setNetworkType(this.getNetworkType()).setEnd(),J.warn("StatusController._onResponseOK, slow start. key=".concat(e," interval=").concat(o," ms")),this.emitInnerEvent(uo)}n.lastResponseReceivedTime=r}else n.lastResponseReceivedTime=r}},{key:"_onRequestFailed",value:function(e){var n=this,r=this._status[e];Date.now()-r.lastResponseReceivedTime>=this.LONGPOLLING_ID_TIMEOUT?this._currentState!==t.NET_STATE_DISCONNECTED&&(J.warn("StatusController._onRequestFailed, disconnected, longpolling unavailable more than 5min. key=".concat(e," networkType=").concat(this.getNetworkType())),this._emitNetStateChangeEvent(t.NET_STATE_DISCONNECTED)):(r.failedCount+=1,r.failedCount>5?this.probeNetwork().then((function(o){var i=v(o,2),s=i[0],a=i[1];s?(n._currentState!==t.NET_STATE_CONNECTING&&n._emitNetStateChangeEvent(t.NET_STATE_CONNECTING),J.warn("StatusController._onRequestFailed, connecting, network jitter. key=".concat(e," networkType=").concat(a))):(n._currentState!==t.NET_STATE_DISCONNECTED&&n._emitNetStateChangeEvent(t.NET_STATE_DISCONNECTED),J.warn("StatusController._onRequestFailed, disconnected, longpolling unavailable. key=".concat(e," networkType=").concat(a))),r.failedCount=0,r.jitterCount=0})):this._currentState===t.NET_STATE_CONNECTED&&this._emitNetStateChangeEvent(t.NET_STATE_CONNECTING))}},{key:"_emitNetStateChangeEvent",value:function(t){J.log("StatusController._emitNetStateChangeEvent net state changed from ".concat(this._currentState," to ").concat(t)),this._currentState=t,this.emitOuterEvent(e.NET_STATE_CHANGE,{state:t})}},{key:"reset",value:function(){J.log("StatusController.reset"),this._currentState=t.NET_STATE_CONNECTED,this._status={OPENIM:{lastResponseReceivedTime:0,jitterCount:0,failedCount:0},AVCHATROOM:{lastResponseReceivedTime:0,jitterCount:0,failedCount:0}}}}]),s}(Bo);function Lu(){return null}var Nu=function(){function e(t){r(this,e),this.tim=t,this.isWX=O,this.storageQueue=new Map,this.checkTimes=0,this.checkTimer=setInterval(this._onCheckTimer.bind(this),1e3),this._errorTolerantHandle()}return i(e,[{key:"_errorTolerantHandle",value:function(){!this.isWX&&oe(window.localStorage)&&(this.getItem=Lu,this.setItem=Lu,this.removeItem=Lu,this.clear=Lu)}},{key:"_onCheckTimer",value:function(){if(this.checkTimes++,this.checkTimes%20==0){if(0===this.storageQueue.size)return;this._doFlush()}}},{key:"_doFlush",value:function(){try{var e,t=M(this.storageQueue);try{for(t.s();!(e=t.n()).done;){var n=v(e.value,2),r=n[0],o=n[1];this.isWX?wx.setStorageSync(this._getKey(r),o):localStorage.setItem(this._getKey(r),JSON.stringify(o))}}catch(i){t.e(i)}finally{t.f()}this.storageQueue.clear()}catch(s){J.warn("Storage._doFlush error",s)}}},{key:"_getPrefix",value:function(){var e=this.tim.loginInfo,t=e.SDKAppID,n=e.identifier;return"TIM_".concat(t,"_").concat(n,"_")}},{key:"getItem",value:function(e){var t=!(arguments.length>1&&void 0!==arguments[1])||arguments[1];try{var n=t?this._getKey(e):e;return this.isWX?wx.getStorageSync(n):JSON.parse(localStorage.getItem(n))}catch(r){J.warn("Storage.getItem error:",r)}}},{key:"setItem",value:function(e,t){var n=arguments.length>2&&void 0!==arguments[2]&&arguments[2],r=!(arguments.length>3&&void 0!==arguments[3])||arguments[3];if(n){var o=r?this._getKey(e):e;this.isWX?wx.setStorageSync(o,t):localStorage.setItem(o,JSON.stringify(t))}else this.storageQueue.set(e,t)}},{key:"clear",value:function(){try{this.isWX?wx.clearStorageSync():localStorage.clear()}catch(e){J.warn("Storage.clear error:",e)}}},{key:"removeItem",value:function(e){var t=!(arguments.length>1&&void 0!==arguments[1])||arguments[1];try{var n=t?this._getKey(e):e;this.isWX?wx.removeStorageSync(n):localStorage.removeItem(n)}catch(r){J.warn("Storage.removeItem error:",r)}}},{key:"getSize",value:function(e){var t=this,n=arguments.length>1&&void 0!==arguments[1]?arguments[1]:"b";try{var r={size:0,limitSize:5242880,unit:n};if(Object.defineProperty(r,"leftSize",{enumerable:!0,get:function(){return r.limitSize-r.size}}),this.isWX&&(r.limitSize=1024*wx.getStorageInfoSync().limitSize),e)r.size=JSON.stringify(this.getItem(e)).length+this._getKey(e).length;else if(this.isWX){var o=wx.getStorageInfoSync(),i=o.keys;i.forEach((function(e){r.size+=JSON.stringify(wx.getStorageSync(e)).length+t._getKey(e).length}))}else for(var s in localStorage)localStorage.hasOwnProperty(s)&&(r.size+=localStorage.getItem(s).length+s.length);return this._convertUnit(r)}catch(a){J.warn("Storage.getSize error:",a)}}},{key:"_convertUnit",value:function(e){var t={},n=e.unit;for(var r in t.unit=n,e)"number"==typeof e[r]&&("kb"===n.toLowerCase()?t[r]=Math.round(e[r]/1024):"mb"===n.toLowerCase()?t[r]=Math.round(e[r]/1024/1024):t[r]=e[r]);return t}},{key:"_getKey",value:function(e){return"".concat(this._getPrefix()).concat(e)}},{key:"reset",value:function(){this._doFlush(),this.checkTimes=0}}]),e}(),bu=T((function(e){var t=Object.prototype.hasOwnProperty,n="~";function r(){}function o(e,t,n){this.fn=e,this.context=t,this.once=n||!1}function i(e,t,r,i,s){if("function"!=typeof r)throw new TypeError("The listener must be a function");var a=new o(r,i||e,s),u=n?n+t:t;return e._events[u]?e._events[u].fn?e._events[u]=[e._events[u],a]:e._events[u].push(a):(e._events[u]=a,e._eventsCount++),e}function s(e,t){0==--e._eventsCount?e._events=new r:delete e._events[t]}function a(){this._events=new r,this._eventsCount=0}Object.create&&(r.prototype=Object.create(null),(new r).__proto__||(n=!1)),a.prototype.eventNames=function(){var e,r,o=[];if(0===this._eventsCount)return o;for(r in e=this._events)t.call(e,r)&&o.push(n?r.slice(1):r);return Object.getOwnPropertySymbols?o.concat(Object.getOwnPropertySymbols(e)):o},a.prototype.listeners=function(e){var t=n?n+e:e,r=this._events[t];if(!r)return[];if(r.fn)return[r.fn];for(var o=0,i=r.length,s=new Array(i);o<i;o++)s[o]=r[o].fn;return s},a.prototype.listenerCount=function(e){var t=n?n+e:e,r=this._events[t];return r?r.fn?1:r.length:0},a.prototype.emit=function(e,t,r,o,i,s){var a=n?n+e:e;if(!this._events[a])return!1;var u,c,l=this._events[a],p=arguments.length;if(l.fn){switch(l.once&&this.removeListener(e,l.fn,void 0,!0),p){case 1:return l.fn.call(l.context),!0;case 2:return l.fn.call(l.context,t),!0;case 3:return l.fn.call(l.context,t,r),!0;case 4:return l.fn.call(l.context,t,r,o),!0;case 5:return l.fn.call(l.context,t,r,o,i),!0;case 6:return l.fn.call(l.context,t,r,o,i,s),!0}for(c=1,u=new Array(p-1);c<p;c++)u[c-1]=arguments[c];l.fn.apply(l.context,u)}else{var h,f=l.length;for(c=0;c<f;c++)switch(l[c].once&&this.removeListener(e,l[c].fn,void 0,!0),p){case 1:l[c].fn.call(l[c].context);break;case 2:l[c].fn.call(l[c].context,t);break;case 3:l[c].fn.call(l[c].context,t,r);break;case 4:l[c].fn.call(l[c].context,t,r,o);break;default:if(!u)for(h=1,u=new Array(p-1);h<p;h++)u[h-1]=arguments[h];l[c].fn.apply(l[c].context,u)}}return!0},a.prototype.on=function(e,t,n){return i(this,e,t,n,!1)},a.prototype.once=function(e,t,n){return i(this,e,t,n,!0)},a.prototype.removeListener=function(e,t,r,o){var i=n?n+e:e;if(!this._events[i])return this;if(!t)return s(this,i),this;var a=this._events[i];if(a.fn)a.fn!==t||o&&!a.once||r&&a.context!==r||s(this,i);else{for(var u=0,c=[],l=a.length;u<l;u++)(a[u].fn!==t||o&&!a[u].once||r&&a[u].context!==r)&&c.push(a[u]);c.length?this._events[i]=1===c.length?c[0]:c:s(this,i)}return this},a.prototype.removeAllListeners=function(e){var t;return e?(t=n?n+e:e,this._events[t]&&s(this,t)):(this._events=new r,this._eventsCount=0),this},a.prototype.off=a.prototype.removeListener,a.prototype.addListener=a.prototype.on,a.prefixed=n,a.EventEmitter=a,e.exports=a})),Pu=function(e){var t,n,r,o,i;return Ae(e.context)?(t="",n=0,r=0,o=0,i=1):(t=e.context.a2Key,n=e.context.tinyID,r=e.context.SDKAppID,o=e.context.contentType,i=e.context.apn),{platform:Fr,websdkappid:xr,v:qr,a2:t,tinyid:n,sdkappid:r,contentType:o,apn:i,reqtime:function(){return+new Date}}},Gu=function(){function e(t){r(this,e),this.tim=t,this.tim.innerEmitter.on(jr,this._update,this),this.tim.innerEmitter.on($r,this._update,this),this.tim.innerEmitter.on(zr,this._updateSpecifiedConfig,this),this._initConfig()}return i(e,[{key:"_update",value:function(e){this._initConfig()}},{key:"_updateSpecifiedConfig",value:function(e){var t=this;e.data.forEach((function(e){t._set(e)}))}},{key:"get",value:function(e){var t=e.name,r=e.action,o=e.param,i=e.tjgID;if(oe(this.config[t])||oe(this.config[t][r]))throw new pt({code:hn,message:"".concat(Cr,": PackageConfig.").concat(t)});var s=function e(t){if(0===Object.getOwnPropertyNames(t).length)return Object.create(null);var r=Array.isArray(t)?[]:Object.create(null),o="";for(var i in t)null!==t[i]?void 0!==t[i]?(o=n(t[i]),["string","number","function","boolean"].indexOf(o)>=0?r[i]=t[i]:r[i]=e(t[i])):r[i]=void 0:r[i]=null;return r}(this.config[t][r]);return s.requestData=this._initRequestData(o,s),s.encode=this._initEncoder(s),s.decode=this._initDecoder(s),i&&(s.queryString.tjg_id=i),s}},{key:"_set",value:function(e){var t=e.key,r=e.value;if(!1!=!!t){var o=t.split(".");if(!(o.length<=0)){!function e(t,r,o,i){var s=r[o];"object"===n(t[s])?e(t[s],r,o+1,i):t[s]=i}(this.config,o,0,r)}}}},{key:"_initConfig",value:function(){var e;this.config={},this.config.accessLayer=(e=this.tim,{create:null,query:{serverName:Vr.NAME.WEB_IM,cmd:Vr.CMD.ACCESS_LAYER,channel:Vr.CHANNEL.XHR,protocol:Br,method:"POST",queryString:{platform:Fr,identifier:e.context.identifier,usersig:e.context.userSig,contentType:e.context.contentType,apn:null!==e.context?e.context.apn:1,websdkappid:xr,v:qr},requestData:{}},update:null,delete:null}),this.config.login=function(e){return{create:null,query:{serverName:Vr.NAME.OPEN_IM,cmd:Vr.CMD.LOGIN,channel:Vr.CHANNEL.XHR,protocol:Br,method:"POST",queryString:{websdkappid:xr,v:qr,platform:Fr,identifier:e.loginInfo.identifier,usersig:e.loginInfo.userSig,sdkappid:e.loginInfo.SDKAppID,accounttype:e.loginInfo.accountType,contentType:null!==e.context?e.context.contentType:0,apn:null!==e.context?e.context.apn:1,reqtime:+new Date/1e3},requestData:{state:"Online"},keyMaps:{request:{tinyID:"tinyId"},response:{TinyId:"tinyID"}}},update:null,delete:null}}(this.tim),this.config.logout=function(e){return{create:null,query:{serverName:Vr.NAME.OPEN_IM,cmd:Vr.CMD.LOGOUT_ALL,channel:Vr.CHANNEL.XHR,protocol:Br,method:"POST",queryString:{websdkappid:xr,v:qr,platform:Fr,a2:null!==e.context?e.context.a2Key:"",tinyid:null!==e.context?e.context.tinyID:"",sdkappid:null!==e.loginInfo?e.loginInfo.SDKAppID:0,contentType:null!==e.context?e.context.contentType:0,apn:null!==e.context?e.context.apn:"",reqtime:+new Date/1e3},requestData:{}},update:null,delete:null}}(this.tim),this.config.longPollLogout=function(e){return{create:null,query:{serverName:Vr.NAME.OPEN_IM,cmd:Vr.CMD.LOGOUT_LONG_POLL,channel:Vr.CHANNEL.XHR,protocol:Br,method:"POST",queryString:{websdkappid:xr,v:qr,platform:Fr,a2:null!==e.context?e.context.a2Key:"",tinyid:null!==e.context?e.context.tinyID:0,sdkappid:null!==e.context?e.context.SDKAppID:0,contentType:null!==e.context?e.context.contentType:0,apn:null!==e.context?e.context.apn:1,reqtime:function(){return Date.now()}},requestData:{longPollID:""},keyMaps:{request:{longPollID:"LongPollingId"}}},update:null,delete:null}}(this.tim),this.config.profile=function(e){var t=Pu(e),n=Vr.NAME.PROFILE,r=Vr.CHANNEL.XHR,o=Br;return{query:{serverName:n,cmd:Vr.CMD.PORTRAIT_GET,channel:r,protocol:o,method:"POST",queryString:t,requestData:{fromAccount:"",userItem:[]},keyMaps:{request:{toAccount:"To_Account",standardSequence:"StandardSequence",customSequence:"CustomSequence"}}},update:{serverName:n,cmd:Vr.CMD.PORTRAIT_SET,channel:r,protocol:o,method:"POST",queryString:t,requestData:{fromAccount:"",profileItem:[{tag:Ze.NICK,value:""},{tag:Ze.GENDER,value:""},{tag:Ze.ALLOWTYPE,value:""},{tag:Ze.AVATAR,value:""}]}}}}(this.tim),this.config.group=function(e){var n={websdkappid:xr,v:qr,platform:Fr,a2:null!==e.context&&e.context.a2Key?e.context.a2Key:void 0,tinyid:null!==e.context&&e.context.tinyID?e.context.tinyID:void 0,sdkappid:null!==e.context?e.context.SDKAppID:0,contentType:null!==e.context?e.context.contentType:0,accounttype:null!==e.context?e.context.accountType:0},r={request:{ownerID:"Owner_Account",userID:"Member_Account",newOwnerID:"NewOwner_Account",maxMemberNum:"MaxMemberCount",groupCustomField:"AppDefinedData",memberCustomField:"AppMemberDefinedData",groupCustomFieldFilter:"AppDefinedDataFilter_Group",memberCustomFieldFilter:"AppDefinedDataFilter_GroupMember",messageRemindType:"MsgFlag",userIDList:"MemberList",groupIDList:"GroupIdList",applyMessage:"ApplyMsg",muteTime:"ShutUpTime",joinOption:"ApplyJoinOption"},response:{GroupIdList:"groups",MsgFlag:"messageRemindType",AppDefinedData:"groupCustomField",AppMemberDefinedData:"memberCustomField",AppDefinedDataFilter_Group:"groupCustomFieldFilter",AppDefinedDataFilter_GroupMember:"memberCustomFieldFilter",InfoSeq:"infoSequence",MemberList:"members",GroupInfo:"groups",ShutUpUntil:"muteUntil",ApplyJoinOption:"joinOption"}};return{create:{serverName:Vr.NAME.GROUP,cmd:Vr.CMD.CREATE_GROUP,channel:Vr.CHANNEL.XHR,protocol:Br,queryString:n,requestData:{type:t.GRP_PRIVATE,name:void 0,groupID:void 0,ownerID:e.loginInfo.identifier,introduction:void 0,notification:void 0,avatar:void 0,maxMemberNum:void 0,joinOption:void 0,memberList:void 0,groupCustomField:void 0},keyMaps:r},list:{serverName:Vr.NAME.GROUP,cmd:Vr.CMD.GET_JOINED_GROUPS,channel:Vr.CHANNEL.XHR,protocol:Br,queryString:n,requestData:{userID:e.loginInfo.identifier,limit:void 0,offset:void 0,groupType:void 0,responseFilter:void 0},keyMaps:r},query:{serverName:Vr.NAME.GROUP,cmd:Vr.CMD.GET_GROUP_INFO,channel:Vr.CHANNEL.XHR,protocol:Br,queryString:n,requestData:{groupIDList:void 0,responseFilter:void 0},keyMaps:r},getGroupMemberProfile:{serverName:Vr.NAME.GROUP,cmd:Vr.CMD.GET_GROUP_MEMBER_INFO,channel:Vr.CHANNEL.XHR,protocol:Br,queryString:n,requestData:{groupID:void 0,userIDList:void 0,memberInfoFilter:void 0,memberCustomFieldFilter:void 0},keyMaps:{request:u({},r.request,{userIDList:"Member_List_Account"}),response:r.response}},getGroupMemberList:{serverName:Vr.NAME.GROUP,cmd:Vr.CMD.GET_GROUP_MEMBER_LIST,channel:Vr.CHANNEL.XHR,protocol:Br,queryString:n,requestData:{groupID:void 0,limit:0,offset:0,memberRoleFilter:void 0,memberInfoFilter:void 0},keyMaps:r},quitGroup:{serverName:Vr.NAME.GROUP,cmd:Vr.CMD.QUIT_GROUP,channel:Vr.CHANNEL.XHR,protocol:Br,queryString:n,requestData:{groupID:void 0}},changeGroupOwner:{serverName:Vr.NAME.GROUP,cmd:Vr.CMD.CHANGE_GROUP_OWNER,channel:Vr.CHANNEL.XHR,protocol:Br,queryString:n,requestData:{groupID:void 0,newOwnerID:void 0},keyMaps:r},destroyGroup:{serverName:Vr.NAME.GROUP,cmd:Vr.CMD.DESTROY_GROUP,channel:Vr.CHANNEL.XHR,protocol:Br,queryString:n,requestData:{groupID:void 0}},updateGroupProfile:{serverName:Vr.NAME.GROUP,cmd:Vr.CMD.MODIFY_GROUP_INFO,channel:Vr.CHANNEL.XHR,protocol:Br,queryString:n,requestData:{groupID:void 0,name:void 0,introduction:void 0,notification:void 0,avatar:void 0,maxMemberNum:void 0,joinOption:void 0,groupCustomField:void 0},keyMaps:{request:u({},r.request,{groupCustomField:"AppDefinedData"}),response:r.response}},modifyGroupMemberInfo:{serverName:Vr.NAME.GROUP,cmd:Vr.CMD.MODIFY_GROUP_MEMBER_INFO,channel:Vr.CHANNEL.XHR,protocol:Br,queryString:n,requestData:{groupID:void 0,userID:void 0,messageRemindType:void 0,nameCard:void 0,role:void 0,memberCustomField:void 0,muteTime:void 0},keyMaps:r},addGroupMember:{serverName:Vr.NAME.GROUP,cmd:Vr.CMD.ADD_GROUP_MEMBER,channel:Vr.CHANNEL.XHR,protocol:Br,queryString:n,requestData:{groupID:void 0,silence:void 0,userIDList:void 0},keyMaps:r},deleteGroupMember:{serverName:Vr.NAME.GROUP,cmd:Vr.CMD.DELETE_GROUP_MEMBER,channel:Vr.CHANNEL.XHR,protocol:Br,queryString:n,requestData:{groupID:void 0,userIDList:void 0,reason:void 0},keyMaps:{request:{userIDList:"MemberToDel_Account"}}},searchGroupByID:{serverName:Vr.NAME.GROUP,cmd:Vr.CMD.SEARCH_GROUP_BY_ID,channel:Vr.CHANNEL.XHR,protocol:Br,queryString:n,requestData:{groupIDList:void 0,responseFilter:{groupBasePublicInfoFilter:["Type","Name","Introduction","Notification","FaceUrl","CreateTime","Owner_Account","LastInfoTime","LastMsgTime","NextMsgSeq","MemberNum","MaxMemberNum","ApplyJoinOption"]}},keyMaps:{request:{groupIDList:"GroupIdList"}}},applyJoinGroup:{serverName:Vr.NAME.GROUP,cmd:Vr.CMD.APPLY_JOIN_GROUP,channel:Vr.CHANNEL.XHR,protocol:Br,queryString:n,requestData:{groupID:void 0,applyMessage:void 0,userDefinedField:void 0},keyMaps:r},applyJoinAVChatRoom:{serverName:Vr.NAME.BIG_GROUP_NO_AUTH,cmd:Vr.CMD.APPLY_JOIN_GROUP,channel:Vr.CHANNEL.XHR,protocol:Br,queryString:{websdkappid:xr,v:qr,platform:Fr,sdkappid:null!==e.context?e.context.SDKAppID:0,contentType:null!==e.context?e.context.contentType:0,accounttype:null!==e.context?e.context.accountType:0},requestData:{groupID:void 0,applyMessage:void 0,userDefinedField:void 0},keyMaps:r},handleApplyJoinGroup:{serverName:Vr.NAME.GROUP,cmd:Vr.CMD.HANDLE_APPLY_JOIN_GROUP,channel:Vr.CHANNEL.XHR,protocol:Br,queryString:n,requestData:{groupID:void 0,applicant:void 0,handleAction:void 0,handleMessage:void 0,authentication:void 0,messageKey:void 0,userDefinedField:void 0},keyMaps:{request:{applicant:"Applicant_Account",handleAction:"HandleMsg",handleMessage:"ApprovalMsg",messageKey:"MsgKey"},response:{MsgKey:"messageKey"}}},deleteGroupSystemNotice:{serverName:Vr.NAME.OPEN_IM,cmd:Vr.CMD.DELETE_GROUP_SYSTEM_MESSAGE,channel:Vr.CHANNEL.XHR,protocol:Br,queryString:n,requestData:{messageListToDelete:void 0},keyMaps:{request:{messageListToDelete:"DelMsgList",messageSeq:"MsgSeq",messageRandom:"MsgRandom"}}},getGroupPendency:{serverName:Vr.NAME.GROUP,cmd:Vr.CMD.GET_GROUP_PENDENCY,channel:Vr.CHANNEL.XHR,protocol:Br,queryString:n,requestData:{startTime:void 0,limit:void 0,handleAccount:void 0},keyMaps:{request:{handleAccount:"Handle_Account"}}}}}(this.tim),this.config.longPollID=function(e){return{create:{},query:{serverName:Vr.NAME.OPEN_IM,cmd:Vr.CMD.GET_LONG_POLL_ID,channel:Vr.CHANNEL.XHR,protocol:Br,queryString:{websdkappid:xr,v:qr,platform:Fr,a2:null!==e.context?e.context.a2Key:"",tinyid:null!==e.context?e.context.tinyID:0,sdkappid:null!==e.context?e.context.SDKAppID:0,contentType:null!==e.context?e.context.contentType:0,apn:null!==e.context?e.context.apn:1,reqtime:+new Date/1e3},requestData:{},keyMaps:{response:{LongPollingId:"longPollingID"}}},update:{},delete:{}}}(this.tim),this.config.longPoll=function(e){var t={websdkappid:xr,v:qr,platform:Fr,a2:null!==e.context?e.context.a2Key:"",tinyid:null!==e.context?e.context.tinyID:0,sdkappid:null!==e.context?e.context.SDKAppID:0,contentType:null!==e.context?e.context.contentType:0,accounttype:null!==e.context?e.loginInfo.accountType:0,apn:null!==e.context?e.context.apn:1,reqtime:Math.ceil(+new Date/1e3)};return{create:{},query:{serverName:Vr.NAME.OPEN_IM,cmd:Vr.CMD.LONG_POLL,channel:Vr.CHANNEL.AUTO,protocol:Br,queryString:t,requestData:{timeout:null,cookie:{notifySeq:0,noticeSeq:0,longPollingID:0}},keyMaps:{response:{C2cMsgArray:"C2CMessageArray",GroupMsgArray:"groupMessageArray",GroupTips:"groupTips",C2cNotifyMsgArray:"C2CNotifyMessageArray",ClientSeq:"clientSequence",MsgPriority:"priority",NoticeSeq:"noticeSequence",MsgContent:"content",MsgType:"type",MsgBody:"elements",ToGroupId:"to",Desc:"description",Ext:"extension"}}},update:{},delete:{}}}(this.tim),this.config.applyC2C=function(e){var t=Pu(e),n=Vr.NAME.FRIEND,r=Vr.CHANNEL.XHR,o=Br;return{create:{serverName:n,cmd:Vr.CMD.FRIEND_ADD,channel:r,protocol:o,queryString:t,requestData:{fromAccount:"",addFriendItem:[]}},get:{serverName:n,cmd:Vr.CMD.GET_PENDENCY,channel:r,protocol:o,queryString:t,requestData:{fromAccount:"",pendencyType:"Pendency_Type_ComeIn"}},update:{serverName:n,cmd:Vr.CMD.RESPONSE_PENDENCY,channel:r,protocol:o,queryString:t,requestData:{fromAccount:"",responseFriendItem:[]}},delete:{serverName:n,cmd:Vr.CMD.DELETE_PENDENCY,channel:r,protocol:o,queryString:t,requestData:{fromAccount:"",toAccount:[],pendencyType:"Pendency_Type_ComeIn"}}}}(this.tim),this.config.friend=function(e){var t=Pu(e),n=Vr.NAME.FRIEND,r=Vr.CHANNEL.XHR,o=Br;return{get:{serverName:n,cmd:Vr.CMD.FRIEND_GET_ALL,channel:r,protocol:o,method:"POST",queryString:t,requestData:{fromAccount:"",timeStamp:0,startIndex:0,getCount:100,lastStandardSequence:0,tagList:["Tag_Profile_IM_Nick","Tag_SNS_IM_Remark"]},keyMaps:{request:{},response:{}}},delete:{serverName:n,cmd:Vr.CMD.FRIEND_DELETE,channel:r,protocol:o,method:"POST",queryString:t,requestData:{fromAccount:"",toAccount:[],deleteType:"Delete_Type_Single"}}}}(this.tim),this.config.blacklist=function(e){var t=Pu(e);return{create:{serverName:Vr.NAME.FRIEND,cmd:Vr.CMD.ADD_BLACKLIST,channel:Vr.CHANNEL.XHR,protocol:Br,method:"POST",queryString:t,requestData:{fromAccount:"",toAccount:[]}},get:{serverName:Vr.NAME.FRIEND,cmd:Vr.CMD.GET_BLACKLIST,channel:Vr.CHANNEL.XHR,protocol:Br,method:"POST",queryString:t,requestData:{fromAccount:"",startIndex:0,maxLimited:30,lastSequence:0}},delete:{serverName:Vr.NAME.FRIEND,cmd:Vr.CMD.DELETE_BLACKLIST,channel:Vr.CHANNEL.XHR,protocol:Br,method:"POST",queryString:t,requestData:{fromAccount:"",toAccount:[]}},update:{}}}(this.tim),this.config.c2cMessage=function(e){var t={platform:Fr,websdkappid:xr,v:qr,a2:null!==e.context?e.context.a2Key:"",tinyid:null!==e.context?e.context.tinyID:0,sdkappid:null!==e.context?e.context.SDKAppID:0,contentType:null!==e.context?e.context.contentType:0,apn:null!==e.context?e.context.apn:1,reqtime:function(){return+new Date}},n={request:{fromAccount:"From_Account",toAccount:"To_Account",msgTimeStamp:"MsgTimeStamp",msgSeq:"MsgSeq",msgRandom:"MsgRandom",msgBody:"MsgBody",count:"MaxCnt",lastMessageTime:"LastMsgTime",messageKey:"MsgKey",peerAccount:"Peer_Account",data:"Data",description:"Desc",extension:"Ext",type:"MsgType",content:"MsgContent",sizeType:"Type",uuid:"UUID",imageUrl:"URL",fileUrl:"Url",remoteAudioUrl:"Url",remoteVideoUrl:"VideoUrl",thumbUUID:"ThumbUUID",videoUUID:"VideoUUID",videoUrl:"",downloadFlag:"Download_Flag"},response:{MsgContent:"content",MsgTime:"time",Data:"data",Desc:"description",Ext:"extension",MsgKey:"messageKey",MsgType:"type",MsgBody:"elements",Download_Flag:"downloadFlag",ThumbUUID:"thumbUUID",VideoUUID:"videoUUID"}};return{create:{serverName:Vr.NAME.OPEN_IM,cmd:Vr.CMD.SEND_MESSAGE,channel:Vr.CHANNEL.XHR,protocol:Br,method:"POST",queryString:t,requestData:{fromAccount:e.loginInfo.identifier,toAccount:"",msgTimeStamp:Math.ceil(+new Date/1e3),msgSeq:0,msgRandom:0,msgBody:[]},keyMaps:n},query:{serverName:Vr.NAME.OPEN_IM,cmd:Vr.CMD.GET_C2C_ROAM_MESSAGES,channel:Vr.CHANNEL.XHR,protocol:Br,method:"POST",queryString:t,requestData:{peerAccount:"",count:15,lastMessageTime:0,messageKey:"",withRecalledMsg:1},keyMaps:n},update:null,delete:null}}(this.tim),this.config.c2cMessageWillBeRevoked=function(e){var t={platform:Fr,websdkappid:xr,v:qr,a2:null!==e.context?e.context.a2Key:"",tinyid:null!==e.context?e.context.tinyID:0,sdkappid:null!==e.context?e.context.SDKAppID:0,contentType:null!==e.context?e.context.contentType:0,apn:null!==e.context?e.context.apn:1,reqtime:function(){return+new Date}};return{create:{serverName:Vr.NAME.OPEN_IM,cmd:Vr.CMD.REVOKE_C2C_MESSAGE,channel:Vr.CHANNEL.XHR,protocol:Br,method:"POST",queryString:t,requestData:{msgInfo:{fromAccount:"",toAccount:"",msgTimeStamp:Math.ceil(+new Date/1e3),msgSeq:0,msgRandom:0}},keyMaps:{request:{msgInfo:"MsgInfo",fromAccount:"From_Account",toAccount:"To_Account",msgTimeStamp:"MsgTimeStamp",msgSeq:"MsgSeq",msgRandom:"MsgRandom",msgBody:"MsgBody"}}}}}(this.tim),this.config.groupMessage=function(e){var t={platform:Fr,websdkappid:xr,v:qr,a2:null!==e.context?e.context.a2Key:"",tinyid:null!==e.context?e.context.tinyID:0,sdkappid:null!==e.context?e.context.SDKAppID:0,contentType:null!==e.context?e.context.contentType:0,apn:null!==e.context?e.context.apn:1,reqtime:function(){return+new Date}},n={request:{to:"GroupId",extension:"Ext",data:"Data",description:"Desc",random:"Random",sequence:"ReqMsgSeq",count:"ReqMsgNumber",type:"MsgType",priority:"MsgPriority",content:"MsgContent",elements:"MsgBody",sizeType:"Type",uuid:"UUID",imageUrl:"URL",fileUrl:"Url",remoteAudioUrl:"Url",remoteVideoUrl:"VideoUrl",thumbUUID:"ThumbUUID",videoUUID:"VideoUUID",videoUrl:"",downloadFlag:"Download_Flag",clientSequence:"ClientSeq"},response:{Random:"random",MsgTime:"time",MsgSeq:"sequence",ReqMsgSeq:"sequence",RspMsgList:"messageList",IsPlaceMsg:"isPlaceMessage",IsSystemMsg:"isSystemMessage",ToGroupId:"to",EnumFrom_AccountType:"fromAccountType",EnumTo_AccountType:"toAccountType",GroupCode:"groupCode",MsgPriority:"priority",MsgBody:"elements",MsgType:"type",MsgContent:"content",IsFinished:"complete",Download_Flag:"downloadFlag",ClientSeq:"clientSequence",ThumbUUID:"thumbUUID",VideoUUID:"videoUUID"}};return{create:{serverName:Vr.NAME.GROUP,cmd:Vr.CMD.SEND_GROUP_MESSAGE,channel:Vr.CHANNEL.XHR,protocol:Br,method:"POST",queryString:t,requestData:{groupID:"",fromAccount:e.loginInfo.identifier,random:0,clientSequence:0,priority:"",msgBody:[]},keyMaps:n},query:{serverName:Vr.NAME.GROUP,cmd:Vr.CMD.GET_GROUP_ROAM_MESSAGES,channel:Vr.CHANNEL.XHR,protocol:Br,method:"POST",queryString:t,requestData:{withRecalledMsg:1,groupID:"",count:15,sequence:""},keyMaps:n},update:null,delete:null}}(this.tim),this.config.groupMessageWillBeRevoked=function(e){var t={platform:Fr,websdkappid:xr,v:qr,a2:null!==e.context?e.context.a2Key:"",tinyid:null!==e.context?e.context.tinyID:0,sdkappid:null!==e.context?e.context.SDKAppID:0,contentType:null!==e.context?e.context.contentType:0,apn:null!==e.context?e.context.apn:1,reqtime:function(){return+new Date}};return{create:{serverName:Vr.NAME.GROUP,cmd:Vr.CMD.REVOKE_GROUP_MESSAGE,channel:Vr.CHANNEL.XHR,protocol:Br,method:"POST",queryString:t,requestData:{to:"",msgSeqList:[]},keyMaps:{request:{to:"GroupId",msgSeqList:"MsgSeqList",msgSeq:"MsgSeq"}}}}}(this.tim),this.config.conversation=function(e){var t={platform:Fr,websdkappid:xr,v:qr,a2:null!==e.context?e.context.a2Key:"",tinyid:null!==e.context?e.context.tinyID:0,sdkappid:null!==e.context?e.context.SDKAppID:0,contentType:null!==e.context?e.context.contentType:0,apn:null!==e.context?e.context.apn:1};return{query:{serverName:Vr.NAME.RECENT_CONTACT,cmd:Vr.CMD.GET_CONVERSATION_LIST,channel:Vr.CHANNEL.XHR,protocol:Br,method:"POST",queryString:t,requestData:{fromAccount:e.loginInfo.identifier,count:0},keyMaps:{request:{},response:{SessionItem:"conversations",ToAccount:"groupID",To_Account:"userID",UnreadMsgCount:"unreadCount",MsgGroupReadedSeq:"messageReadSeq"}}},pagingQuery:{serverName:Vr.NAME.RECENT_CONTACT,cmd:Vr.CMD.PAGING_GET_CONVERSATION_LIST,channel:Vr.CHANNEL.XHR,protocol:Br,method:"POST",queryString:t,requestData:{fromAccount:void 0,timeStamp:void 0,orderType:void 0},keyMaps:{request:{},response:{SessionItem:"conversations",ToAccount:"groupID",To_Account:"userID",UnreadMsgCount:"unreadCount",MsgGroupReadedSeq:"messageReadSeq"}}},delete:{serverName:Vr.NAME.RECENT_CONTACT,cmd:Vr.CMD.DELETE_CONVERSATION,channel:Vr.CHANNEL.XHR,protocol:Br,method:"POST",queryString:t,requestData:{fromAccount:e.loginInfo.identifier,toAccount:void 0,type:1,toGroupID:void 0},keyMaps:{request:{toGroupID:"ToGroupid"}}},setC2CMessageRead:{serverName:Vr.NAME.OPEN_IM,cmd:Vr.CMD.SET_C2C_MESSAGE_READ,channel:Vr.CHANNEL.XHR,protocol:Br,method:"POST",queryString:t,requestData:{C2CMsgReaded:void 0},keyMaps:{request:{lastMessageTime:"LastedMsgTime"}}},setGroupMessageRead:{serverName:Vr.NAME.GROUP,cmd:Vr.CMD.SET_GROUP_MESSAGE_READ,channel:Vr.CHANNEL.XHR,protocol:Br,method:"POST",queryString:t,requestData:{groupID:void 0,messageReadSeq:void 0},keyMaps:{request:{messageReadSeq:"MsgReadedSeq"}}}}}(this.tim),this.config.syncMessage=function(e){var t={platform:Fr,websdkappid:xr,v:qr,a2:null!==e.context?e.context.a2Key:"",tinyid:null!==e.context?e.context.tinyID:0,sdkappid:null!==e.context?e.context.SDKAppID:0,contentType:null!==e.context?e.context.contentType:0,apn:null!==e.context?e.context.apn:1,reqtime:function(){return[Math.ceil(+new Date),Math.random()].join("")}};return{create:null,query:{serverName:Vr.NAME.OPEN_IM,cmd:Vr.CMD.GET_MESSAGES,channel:Vr.CHANNEL.XHR,protocol:Br,method:"POST",queryString:t,requestData:{cookie:"",syncFlag:0,needAbstract:1},keyMaps:{request:{fromAccount:"From_Account",toAccount:"To_Account",from:"From_Account",to:"To_Account",time:"MsgTimeStamp",sequence:"MsgSeq",random:"MsgRandom",elements:"MsgBody"},response:{MsgList:"messageList",SyncFlag:"syncFlag",To_Account:"to",From_Account:"from",ClientSeq:"clientSequence",MsgSeq:"sequence",NoticeSeq:"noticeSequence",NotifySeq:"notifySequence",MsgRandom:"random",MsgTimeStamp:"time",MsgContent:"content",ToGroupId:"groupID",MsgKey:"messageKey",GroupTips:"groupTips",MsgBody:"elements",MsgType:"type",C2CRemainingUnreadCount:"C2CRemainingUnreadList"}}},update:null,delete:null}}(this.tim),this.config.AVChatRoom=function(e){return{startLongPoll:{serverName:Vr.NAME.BIG_GROUP_LONG_POLLING_NO_AUTH,cmd:Vr.CMD.AVCHATROOM_LONG_POLL,channel:Vr.CHANNEL.XHR,protocol:Br,method:"POST",queryString:{websdkappid:xr,v:qr,platform:Fr,sdkappid:e.loginInfo.SDKAppID,accounttype:"792",apn:null!==e.context?e.context.apn:1,reqtime:function(){return+new Date}},requestData:{USP:1,startSeq:1,holdTime:90,key:void 0},keyMaps:{request:{USP:"USP"},response:{ToGroupId:"groupID",MsgPriority:"priority"}}}}}(this.tim),this.config.cosUpload=function(e){var t={platform:Fr,websdkappid:xr,v:qr,a2:null!==e.context?e.context.a2Key:"",tinyid:null!==e.context?e.context.tinyID:0,sdkappid:null!==e.context?e.context.SDKAppID:0,contentType:null!==e.context?e.context.contentType:0,apn:null!==e.context?e.context.apn:1,reqtime:function(){return Date.now()}};return{create:{serverName:Vr.NAME.OPEN_IM,cmd:Vr.CMD.FILE_UPLOAD,channel:Vr.CHANNEL.XHR,protocol:Br,method:"POST",queryString:t,requestData:{appVersion:"2.1",fromAccount:"",toAccount:"",sequence:0,time:function(){return Math.ceil(Date.now()/1e3)},random:function(){return me()},fileStrMd5:"",fileSize:"",serverVer:1,authKey:"",busiId:1,pkgFlag:1,sliceOffset:0,sliceSize:0,sliceData:"",contentType:"application/x-www-form-urlencoded"},keyMaps:{request:{},response:{}}},update:null,delete:null}}(this.tim),this.config.cosSig=function(e){var t={sdkappid:function(){return e.loginInfo.SDKAppID},identifier:function(){return e.loginInfo.identifier},userSig:function(){return e.context.userSig}};return{create:null,query:{serverName:Vr.NAME.IM_COS_SIGN,cmd:Vr.CMD.COS_SIGN,channel:Vr.CHANNEL.XHR,protocol:Br,method:"POST",queryString:t,requestData:{cmd:"open_im_cos_svc",subCmd:"get_cos_token",duration:300,version:2},keyMaps:{request:{userSig:"usersig",subCmd:"sub_cmd",cmd:"cmd",duration:"duration",version:"version"},response:{expired_time:"expiredTime",bucket_name:"bucketName",session_token:"sessionToken",tmp_secret_id:"secretId",tmp_secret_key:"secretKey"}}},update:null,delete:null}}(this.tim),this.config.bigDataHallwayAuthKey=function(e){return{create:null,query:{serverName:Vr.NAME.OPEN_IM,cmd:Vr.CMD.BIG_DATA_HALLWAY_AUTH_KEY,channel:Vr.CHANNEL.XHR,protocol:Br,method:"POST",queryString:{websdkappid:xr,v:qr,platform:Fr,sdkappid:e.loginInfo.SDKAppID,accounttype:"792",apn:null!==e.context?e.context.apn:1,reqtime:function(){return+new Date}},requestData:{}}}}(this.tim),this.config.ssoEventStat=function(e){var t={sdkappid:e.loginInfo.SDKAppID,reqtime:Math.ceil(+new Date/1e3)};return{create:{serverName:Vr.NAME.IM_OPEN_STAT,cmd:Vr.CMD.TIM_WEB_REPORT,channel:Vr.CHANNEL.AUTO,protocol:Br,queryString:t,requestData:{table:"",report:[]},keyMaps:{request:{table:"table",report:"report",SDKAppID:"sdkappid",version:"version",tinyID:"tinyid",userID:"userid",platform:"platform",method:"method",time:"time",start:"start",end:"end",cost:"cost",status:"status",codeint:"codeint",message:"message",pointer:"pointer",text:"text",msgType:"msgtype",networkType:"networktype",startts:"startts",endts:"endts",timespan:"timespan"}}},query:{},update:{},delete:{}}}(this.tim),this.config.ssoSumStat=function(e){var t=null;null!==e.context&&(t={sdkappid:e.context.SDKAppID,reqtime:Math.ceil(+new Date/1e3)});return{create:{serverName:Vr.NAME.IM_OPEN_STAT,cmd:Vr.CMD.TIM_WEB_REPORT,channel:Vr.CHANNEL.AUTO,protocol:Br,queryString:t,requestData:{table:"",report:[]},keyMaps:{request:{table:"table",report:"report",SDKAppID:"sdkappid",version:"version",tinyID:"tinyid",userID:"userid",item:"item",lpID:"lpid",platform:"platform",networkType:"networktype",total:"total",successRate:"successrate",avg:"avg",timespan:"timespan",time:"time"}}},query:{},update:{},delete:{}}}(this.tim)}},{key:"_initRequestData",value:function(e,t){if(void 0===e)return qo(t.requestData,this._getRequestMap(t),this.tim);var n=t.requestData,r=Object.create(null);for(var o in n)if(Object.prototype.hasOwnProperty.call(n,o)){if(r[o]="function"==typeof n[o]?n[o]():n[o],void 0===e[o])continue;r[o]=e[o]}return r=qo(r,this._getRequestMap(t),this.tim)}},{key:"_getRequestMap",value:function(e){if(e.keyMaps&&e.keyMaps.request&&Object.keys(e.keyMaps.request).length>0)return e.keyMaps.request}},{key:"_initEncoder",value:function(e){switch(e.protocol){case Br:return function(e){if("string"===n(e))try{return JSON.parse(e)}catch(t){return e}return e};case Hr:return function(e){return e};default:return function(e){return J.warn("PackageConfig._initEncoder(), unknow response type, data: ",JSON.stringify(e)),e}}}},{key:"_initDecoder",value:function(e){switch(e.protocol){case Br:return function(e){if("string"===n(e))try{return JSON.parse(e)}catch(t){return e}return e};case Hr:return function(e){return e};default:return function(e){return J.warn("PackageConfig._initDecoder(), unknow response type, data: ",e),e}}}}]),e}(),Uu=function(){for(var e=[],t=qu(arguments),n=0;n<arguments.length;n++)Number.isInteger(arguments[n])?e.push(arguments[n]):e.push(!0==!!arguments[n]?"1":"0");return e.join(t)},qu=function(e){var t=e.length,n=e[t-1];if("string"!=typeof n)return"";if(n.length>1)return"";var r=e[t-1];return delete e[t-1],e.length-=t===e.length?1:0,r},xu={C2CMessageArray:1,groupMessageArray:1,groupTips:1,C2CNotifyMessageArray:1,profileModify:1,friendListMod:1},Fu=function(e){c(n,e);var t=y(n);function n(e){var o;return r(this,n),(o=t.call(this,e))._initialization(),o}return i(n,[{key:"_initialization",value:function(){this._syncOffset="",this._syncNoticeList=[],this._syncEventArray=[],this._syncMessagesIsRunning=!1,this._syncMessagesFinished=!1,this._isLongPoll=!1,this._longPollID=0,this._noticeSequence=0,this._initializeListener(),this._runLoop=null,this._initShuntChannels()}},{key:"_initShuntChannels",value:function(){this._shuntChannels=Object.create(null),this._shuntChannels.C2CMessageArray=this._C2CMessageArrayChannel.bind(this),this._shuntChannels.groupMessageArray=this._groupMessageArrayChannel.bind(this),this._shuntChannels.groupTips=this._groupTipsChannel.bind(this),this._shuntChannels.C2CNotifyMessageArray=this._C2CNotifyMessageArrayChannel.bind(this),this._shuntChannels.profileModify=this._profileModifyChannel.bind(this),this._shuntChannels.friendListMod=this._friendListModChannel.bind(this)}},{key:"_C2CMessageArrayChannel",value:function(e,t,n){this.emitInnerEvent(po,t)}},{key:"_groupMessageArrayChannel",value:function(e,t,n){this.emitInnerEvent(ho,t)}},{key:"_groupTipsChannel",value:function(e,t,n){var r=this;switch(e){case 4:case 6:this.emitInnerEvent(fo,t);break;case 5:t.forEach((function(e){re(e.elements.revokedInfos)?r.emitInnerEvent(_o,t):r.emitInnerEvent(go,{groupSystemNotices:t,type:n})}));break;default:J.log("NotificationController._groupTipsChannel unknown event=".concat(e," type=").concat(n),t)}}},{key:"_C2CNotifyMessageArrayChannel",value:function(e,t,n){this._isKickedoutNotice(t)?this.emitInnerEvent(lo):this._isSysCmdMsgNotify(t)?this.emitInnerEvent(vo):this._isC2CMessageRevokedNotify(t)&&this.emitInnerEvent(Co,t)}},{key:"_profileModifyChannel",value:function(e,t,n){this.emitInnerEvent(yo,t)}},{key:"_friendListModChannel",value:function(e,t,n){this.emitInnerEvent(mo,t)}},{key:"_dispatchNotice",value:function(e){var t=arguments.length>1&&void 0!==arguments[1]?arguments[1]:"poll";if(re(e))for(var n=null,r=null,o="",i="",s="",a=0,u=0,c=e.length;u<c;u++)a=(n=e[u]).event,o=Object.keys(n).find((function(e){return void 0!==xu[e]})),se(this._shuntChannels[o])?(r=n[o],"poll"===t&&this._updatenoticeSequence(r),this._shuntChannels[o](a,r,t)):("poll"===t&&this._updatenoticeSequence(),i="".concat(gn),s="".concat(Sr,": ").concat(a,", ").concat(o),this.emitInnerEvent(wo,new pt({code:i,message:s,data:{payloadName:o,event:a}})),i="",s="")}},{key:"getLongPollID",value:function(){return this._longPollID}},{key:"_IAmReady",value:function(){this.triggerReady()}},{key:"reset",value:function(){this._noticeSequence=0,this._resetSync(),this.closeNoticeChannel()}},{key:"_resetSync",value:function(){this._syncOffset="",this._syncNoticeList=[],this._syncEventArray=[],this._syncMessagesIsRunning=!1,this._syncMessagesFinished=!1}},{key:"_setNoticeSeqInRequestData",value:function(e){e.Cookie.NoticeSeq=this._noticeSequence,this.tim.sumStatController.addTotalCount(Qo)}},{key:"_updatenoticeSequence",value:function(e){if(e){var t=e[e.length-1].noticeSequence;t&&"number"==typeof t?t<=this._noticeSequence||(this._noticeSequence=t):this._noticeSequence++}else this._noticeSequence++}},{key:"_initializeListener",value:function(){var e=this.tim.innerEmitter;e.on(Yr,this._startSyncMessages,this),e.on(Eo,this.closeNoticeChannel,this),e.on(ao,this._onFastStart,this)}},{key:"openNoticeChannel",value:function(){J.log("NotificationController.openNoticeChannel"),this._getLongPollID()}},{key:"closeNoticeChannel",value:function(){J.log("NotificationController.closeNoticeChannel"),(this._runLoop instanceof eu||this._runLoop instanceof tu)&&(this._runLoop.abort(),this._runLoop.stop()),this._longPollID=0,this._isLongPoll=!1}},{key:"_getLongPollID",value:function(){var e=this;if(0===this._longPollID){var t=new oi;t.setMethod(Ni).setStart(),this.request({name:"longPollID",action:"query"}).then((function(n){var r=n.data.longPollingID;e._onGetLongPollIDSuccess(r),t.setCode(0).setText("longPollingID=".concat(r)).setNetworkType(e.getNetworkType()).setEnd()})).catch((function(n){var r=new pt({code:n.code||vn,message:n.message||Tr});e.emitInnerEvent(oo),e.emitInnerEvent(wo,r),e.probeNetwork().then((function(e){var n=v(e,2),o=n[0],i=n[1];t.setError(r,o,i).setEnd()}))}))}else this._onGetLongPollIDSuccess(this._longPollID)}},{key:"_onGetLongPollIDSuccess",value:function(e){this.emitInnerEvent(zr,[{key:"long_poll_logout.query.requestData.longPollingID",value:e},{key:"longPoll.query.requestData.cookie.longPollingID",value:e}]),this._longPollID=e,this._startLongPoll(),this._IAmReady(),this.tim.sumStatController.recordLongPollingID(this._longPollID)}},{key:"_startLongPoll",value:function(){if(!0!==this._isLongPoll){J.log("NotificationController._startLongPoll...");var e=this.tim.connectionController,t=this.createTransportCapsule({name:"longPoll",action:"query"});this._isLongPoll=!0,this._runLoop=e.createRunLoop({pack:t,before:this._setNoticeSeqInRequestData.bind(this),success:this._onNoticeReceived.bind(this),fail:this._onNoticeFail.bind(this)}),this._runLoop.start()}else J.log("NotificationController._startLongPoll is running...")}},{key:"_onFastStart",value:function(){this.closeNoticeChannel(),this.syncMessage()}},{key:"_onNoticeReceived",value:function(e){var t=e.data;if(t.errorCode!==Ne.SUCCESS){var n=new oi;n.setMethod(bi).setStart(),n.setMessage(t.errorInfo).setCode(t.errorCode).setNetworkType(this.getNetworkType()).setEnd(),this._onResponseError(t)}else this.emitInnerEvent(so);this.tim.sumStatController.addSuccessCount(Qo),this.tim.sumStatController.addCost(Qo,t.timecost),e.data.eventArray&&this._dispatchNotice(e.data.eventArray)}},{key:"_onResponseError",value:function(e){switch(e.errorCode){case Cn:J.warn("NotificationController._onResponseError, longPollingID=".concat(this._longPollID," was kicked out")),this.emitInnerEvent(co),this.closeNoticeChannel();break;case In:case Mn:this.emitInnerEvent(ko);break;default:this.emitInnerEvent(wo,new pt({code:e.errorCode,message:e.errorInfo}))}}},{key:"_onNoticeFail",value:function(e){if(e.error)if("ECONNABORTED"===e.error.code||e.error.code===cn)if(e.error.config){var t=e.error.config.url,n=e.error.config.data;J.log("NotificationController._onNoticeFail request timed out. url=".concat(t," data=").concat(n))}else J.log("NotificationController._onNoticeFail request timed out.");else J.log("NotificationController._onNoticeFail request failed due to network error");this.emitInnerEvent(io)}},{key:"_isKickedoutNotice",value:function(e){return!!e[0].hasOwnProperty("kickoutMsgNotify")}},{key:"_isSysCmdMsgNotify",value:function(e){if(!e[0])return!1;var t=e[0];return!!Object.prototype.hasOwnProperty.call(t,"sysCmdMsgNotify")}},{key:"_isC2CMessageRevokedNotify",value:function(e){var t=e[0];return!!Object.prototype.hasOwnProperty.call(t,"c2cMessageRevokedNotify")}},{key:"_startSyncMessages",value:function(e){!0!==this._syncMessagesFinished&&this.syncMessage()}},{key:"syncMessage",value:function(){var e=this,t=arguments.length>0&&void 0!==arguments[0]?arguments[0]:"",n=arguments.length>1&&void 0!==arguments[1]?arguments[1]:0;this._syncMessagesIsRunning=!0,this.request({name:"syncMessage",action:"query",param:{cookie:t,syncFlag:n}}).then((function(t){var n=t.data;switch(Uu(n.cookie,n.syncFlag)){case"00":case"01":e.emitInnerEvent(wo,{code:mn,message:Dr});break;case"10":case"11":n.eventArray&&e._dispatchNotice(n.eventArray,"sync"),e._syncNoticeList=e._syncNoticeList.concat(n.messageList),e.emitInnerEvent(Wr,{data:n.messageList,C2CRemainingUnreadList:n.C2CRemainingUnreadList}),e._syncOffset=n.cookie,e.syncMessage(n.cookie,n.syncFlag);break;case"12":n.eventArray&&e._dispatchNotice(n.eventArray,"sync"),e.openNoticeChannel(),e._syncNoticeList=e._syncNoticeList.concat(n.messageList),e.emitInnerEvent(Xr,{messageList:n.messageList,C2CRemainingUnreadList:n.C2CRemainingUnreadList}),e._syncOffset=n.cookie,e._syncNoticeList=[],e._syncMessagesIsRunning=!1,e._syncMessagesFinished=!0}})).catch((function(t){e._syncMessagesIsRunning=!1,J.error("NotificationController.syncMessage failed. error:".concat(t))}))}}]),n}(Bo),Hu=function(e){c(n,e);var t=y(n);function n(e){var o;return r(this,n),(o=t.call(this,e)).COSSDK=null,o._cosUploadMethod=null,o.expiredTimeLimit=300,o.appid=0,o.bucketName="",o.ciUrl="",o.directory="",o.downloadUrl="",o.uploadUrl="",o.expiredTimeOut=o.expiredTimeLimit,o.region="ap-shanghai",o.cos=null,o.cosOptions={secretId:"",secretKey:"",sessionToken:"",expiredTime:0},o._timer=0,o.tim.innerEmitter.on(Yr,o._init,g(o)),o.triggerReady(),o}return i(n,[{key:"_expiredTimer",value:function(){var e=this;this._timer=setInterval((function(){Math.ceil(Date.now()/1e3)>=e.cosOptions.expiredTime-60&&(e._getAuthorizationKey(),clearInterval(e._timer))}),3e4)}},{key:"_init",value:function(){var e=O?"cos-wx-sdk":"cos-js-sdk";this.COSSDK=this.tim.getPlugin(e),this.COSSDK?this._getAuthorizationKey():J.warn("UploadController._init 没有检测到上传插件，将无法发送图片、音频、视频、文件等类型的消息。详细请参考 https://imsdk-1252463788.file.myqcloud.com/IM_DOC/Web/SDK.html#registerPlugin")}},{key:"_getAuthorizationKey",value:function(){var e=this,t=Math.ceil(Date.now()/1e3),n=new oi;n.setMethod(ci).setStart(),this.request({name:"cosSig",action:"query",param:{duration:this.expiredTimeLimit}}).then((function(r){J.log("UploadController._getAuthorizationKey ok. data:",r.data);var o=r.data,i=o.expiredTime-t;n.setCode(0).setText("timeout=".concat(i,"s")).setNetworkType(e.getNetworkType()).setEnd(),e.appid=o.appid,e.bucketName=o.bucketName,e.ciUrl=o.ciUrl,e.directory=o.directory,e.downloadUrl=o.downloadUrl,e.uploadUrl=o.uploadUrl,e.expiredTimeOut=i,e.cosOptions={secretId:o.secretId,secretKey:o.secretKey,sessionToken:o.sessionToken,expiredTime:o.expiredTime},e._initUploaderMethod(),e._expiredTimer()})).catch((function(t){e.probeNetwork().then((function(n){var r=v(n,2),o=r[0],i=r[1];e.setError(t,o,i).setEnd()})),J.warn("UploadController._getAuthorizationKey failed. error:",t)}))}},{key:"_initUploaderMethod",value:function(){var e=this;this.appid&&(this.cos=O?new this.COSSDK({ForcePathStyle:!0,getAuthorization:this._getAuthorization.bind(this)}):new this.COSSDK({getAuthorization:this._getAuthorization.bind(this)}),this._cosUploadMethod=O?function(t,n){e.cos.postObject(t,n)}:function(t,n){e.cos.uploadFiles(t,n)})}},{key:"_getAuthorization",value:function(e,t){t({TmpSecretId:this.cosOptions.secretId,TmpSecretKey:this.cosOptions.secretKey,XCosSecurityToken:this.cosOptions.sessionToken,ExpiredTime:this.cosOptions.expiredTime})}},{key:"uploadImage",value:function(e){if(!e.file)return Wo(new pt({code:Et,message:Un}));var t=this._checkImageType(e.file);if(!0!==t)return t;var n=this._checkImageMime(e.file);if(!0!==n)return n;var r=this._checkImageSize(e.file);return!0!==r?r:this.upload(e)}},{key:"_checkImageType",value:function(e){var t="";return t=O?e.url.slice(e.url.lastIndexOf(".")+1):e.files[0].name.slice(e.files[0].name.lastIndexOf(".")+1),kr.indexOf(t.toLowerCase())>=0||Wo(new pt({coe:kt,message:qn}))}},{key:"_checkImageMime",value:function(e){return!0}},{key:"_checkImageSize",value:function(e){var t=0;return 0===(t=O?e.size:e.files[0].size)?Wo(new pt({code:St,message:"".concat(bn)})):t<20971520||Wo(new pt({coe:wt,message:"".concat(xn)}))}},{key:"uploadFile",value:function(e){var t=null;return e.file?e.file.files[0].size>104857600?(t=new pt({code:Gt,message:Yn}),Wo(t)):0===e.file.files[0].size?(t=new pt({code:St,message:"".concat(bn)}),Wo(t)):this.upload(e):(t=new pt({code:Pt,message:$n}),Wo(t))}},{key:"uploadVideo",value:function(e){return e.file.videoFile.size>104857600?Wo(new pt({code:Lt,message:"".concat(Vn)})):0===e.file.videoFile.size?Wo(new pt({code:St,message:"".concat(bn)})):-1===wr.indexOf(e.file.videoFile.type)?Wo(new pt({code:Nt,message:"".concat(Kn)})):O?this.handleVideoUpload({file:e.file.videoFile}):R?this.handleVideoUpload(e):void 0}},{key:"handleVideoUpload",value:function(e){var t=this;return new Promise((function(n,r){t.upload(e).then((function(e){n(e)})).catch((function(){t.upload(e).then((function(e){n(e)})).catch((function(){r(new pt({code:Ot,message:Bn}))}))}))}))}},{key:"uploadAudio",value:function(e){return e.file?e.file.size>20971520?Wo(new pt({code:Rt,message:"".concat(Hn)})):0===e.file.size?Wo(new pt({code:St,message:"".concat(bn)})):this.upload(e):Wo(new pt({code:At,message:Fn}))}},{key:"upload",value:function(e){var t=this;if(!se(this._cosUploadMethod))return J.warn("UploadController.upload 没有检测到上传插件，将无法发送图片、音频、视频、文件等类型的消息。详细请参考 https://imsdk-1252463788.file.myqcloud.com/IM_DOC/Web/SDK.html#registerPlugin"),Wo(new pt({code:vt,message:An}));var n=new oi;n.setMethod(li).setStart(),J.time(ri);var r=O?e.file:e.file.files[0];return new Promise((function(o,i){var s=O?t._createCosOptionsWXMiniApp(e):t._createCosOptionsWeb(e),a=t;t._cosUploadMethod(s,(function(e,s){var u=Object.create(null);if(s){if(e||re(s.files)&&s.files[0].error){var c=new pt({code:bt,message:jn});return n.setError(c,!0,t.getNetworkType()).setEnd(),J.log("UploadController.upload failed, error:",s.files[0].error),403===s.files[0].error.statusCode&&(J.warn("UploadController.upload failed. cos AccessKeyId was invalid, regain auth key!"),t._getAuthorizationKey()),void i(c)}u.fileName=r.name,u.fileSize=r.size,u.fileType=r.type.slice(r.type.indexOf("/")+1).toLowerCase(),u.location=O?s.Location:s.files[0].data.Location;var l=J.timeEnd(ri),p=a._formatFileSize(r.size),h=a._formatSpeed(1e3*r.size/l),f="size=".concat(p,",time=").concat(l,"ms,speed=").concat(h);return J.log("UploadController.upload success name=".concat(r.name,",").concat(f)),o(u),void n.setCode(0).setNetworkType(t.getNetworkType()).setText(f).setEnd()}var d=new pt({code:bt,message:jn});n.setError(d,!0,a.getNetworkType()).setEnd(),J.warn("UploadController.upload failed, error:",e),403===e.statusCode&&(J.warn("UploadController.upload failed. cos AccessKeyId was invalid, regain auth key!"),t._getAuthorizationKey()),i(d)}))}))}},{key:"_formatFileSize",value:function(e){return e<1024?e+"B":e<1048576?Math.floor(e/1024)+"KB":Math.floor(e/1048576)+"MB"}},{key:"_formatSpeed",value:function(e){return e<=1048576?(e/1024).toFixed(1)+"KB/s":(e/1048576).toFixed(1)+"MB/s"}},{key:"_createCosOptionsWeb",value:function(e){var t=this.tim.context.identifier,n=this._genFileName(t,e.to,e.file.files[0].name);return{files:[{Bucket:"".concat(this.bucketName,"-").concat(this.appid),Region:this.region,Key:"".concat(this.directory,"/").concat(n),Body:e.file.files[0]}],SliceSize:1048576,onProgress:function(t){if("function"==typeof e.onProgress)try{e.onProgress(t.percent)}catch(n){J.warn("onProgress callback error:"),J.error(n)}},onFileFinish:function(e,t,n){}}}},{key:"_createCosOptionsWXMiniApp",value:function(e){var t=this.tim.context.identifier,n=this._genFileName(t,e.to,e.file.name),r=e.file.url;return{Bucket:"".concat(this.bucketName,"-").concat(this.appid),Region:this.region,Key:"".concat(this.directory,"/").concat(n),FilePath:r,onProgress:function(t){if(J.log(JSON.stringify(t)),"function"==typeof e.onProgress)try{e.onProgress(t.percent)}catch(n){J.warn("onProgress callback error:"),J.error(n)}}}}},{key:"_genFileName",value:function(e,t,n){return"".concat(e,"-").concat(t,"-").concat(me(99999),"-").concat(n)}},{key:"reset",value:function(){this._timer&&(clearInterval(this._timer),this._timer=0)}}]),n}(Bo),Bu=function(e){c(o,e);var n=y(o);function o(e){var t;return r(this,o),(t=n.call(this,e)).FILETYPE={SOUND:2106,FILE:2107,VIDEO:2113},t._bdh_download_server="grouptalk.c2c.qq.com",t._BDHBizID=10001,t._authKey="",t._expireTime=0,t.tim.innerEmitter.on(Yr,t._getAuthKey,g(t)),t}return i(o,[{key:"_getAuthKey",value:function(){var e=this;this.request({name:"bigDataHallwayAuthKey",action:"query"}).then((function(t){t.data.authKey&&(e._authKey=t.data.authKey,e._expireTime=parseInt(t.data.expireTime))}))}},{key:"_isFromOlderVersion",value:function(e){return 2!==e.content.downloadFlag}},{key:"parseElements",value:function(e,t){if(!re(e)||!t)return[];for(var n=[],r=null,o=0;o<e.length;o++)r=e[o],this._needParse(r)?n.push(this._parseElement(r,t)):n.push(e[o]);return n}},{key:"_needParse",value:function(e){return!(!this._isFromOlderVersion(e)||e.type!==t.MSG_AUDIO&&e.type!==t.MSG_FILE&&e.type!==t.MSG_VIDEO)}},{key:"_parseElement",value:function(e,n){switch(e.type){case t.MSG_AUDIO:return this._parseAudioElement(e,n);case t.MSG_FILE:return this._parseFileElement(e,n);case t.MSG_VIDEO:return this._parseVideoElement(e,n)}}},{key:"_parseAudioElement",value:function(e,t){return e.content.url=this._genAudioUrl(e.content.uuid,t),e}},{key:"_parseFileElement",value:function(e,t){return e.content.url=this._genFileUrl(e.content.uuid,t,e.content.fileName),e}},{key:"_parseVideoElement",value:function(e,t){return e.content.url=this._genVideoUrl(e.content.uuid,t),e}},{key:"_genAudioUrl",value:function(e,t){return""===this._authKey?(J.warn("BigDataHallwayController._genAudioUrl no authKey!"),""):"https://".concat(this._bdh_download_server,"/asn.com/stddownload_common_file?authkey=").concat(this._authKey,"&bid=").concat(this._BDHBizID,"&subbid=").concat(this.tim.context.SDKAppID,"&fileid=").concat(e,"&filetype=").concat(this.FILETYPE.SOUND,"&openid=").concat(t,"&ver=0")}},{key:"_genFileUrl",value:function(e,t,n){return""===this._authKey?(J.warn("BigDataHallwayController._genFileUrl no authKey!"),""):(n||(n="".concat(Math.floor(1e5*Math.random()),"-").concat(Date.now())),"https://".concat(this._bdh_download_server,"/asn.com/stddownload_common_file?authkey=").concat(this._authKey,"&bid=").concat(this._BDHBizID,"&subbid=").concat(this.tim.context.SDKAppID,"&fileid=").concat(e,"&filetype=").concat(this.FILETYPE.FILE,"&openid=").concat(t,"&ver=0&filename=").concat(encodeURIComponent(n)))}},{key:"_genVideoUrl",value:function(e,t){return""===this._authKey?(J.warn("BigDataHallwayController._genVideoUrl no authKey!"),""):"https://".concat(this._bdh_download_server,"/asn.com/stddownload_common_file?authkey=").concat(this._authKey,"&bid=").concat(this._BDHBizID,"&subbid=").concat(this.tim.context.SDKAppID,"&fileid=").concat(e,"&filetype=").concat(this.FILETYPE.VIDEO,"&openid=").concat(t,"&ver=0")}},{key:"reset",value:function(){this._authKey="",this.expireTime=0}}]),o}(Bo),Vu={app_id:"",event_id:"",api_base:"https://pingtas.qq.com/pingd",prefix:"_mta_",version:"1.3.9",stat_share_app:!1,stat_pull_down_fresh:!1,stat_reach_bottom:!1,stat_param:!0};function Ku(){try{var e="s"+ju();return wx.setStorageSync(Vu.prefix+"ssid",e),e}catch(t){}}function ju(e){for(var t=[0,1,2,3,4,5,6,7,8,9],n=10;1<n;n--){var r=Math.floor(10*Math.random()),o=t[r];t[r]=t[n-1],t[n-1]=o}for(n=r=0;5>n;n++)r=10*r+t[n];return(e||"")+(r+"")+ +new Date}function $u(){try{var e=getCurrentPages(),t="/";return 0<e.length&&(t=e.pop().__route__),t}catch(n){console.log("get current page path error:"+n)}}function Yu(){var e,t={dm:"wechat.apps.xx",url:encodeURIComponent($u()+Xu(Ju.Data.pageQuery)),pvi:"",si:"",ty:0};return t.pvi=((e=function(){try{return wx.getStorageSync(Vu.prefix+"auid")}catch(t){}}())||(e=function(){try{var t=ju();return wx.setStorageSync(Vu.prefix+"auid",t),t}catch(e){}}(),t.ty=1),e),t.si=function(){var e=function(){try{return wx.getStorageSync(Vu.prefix+"ssid")}catch(e){}}();return e||(e=Ku()),e}(),t}function zu(){var e=function(){var e=wx.getSystemInfoSync();return{adt:encodeURIComponent(e.model),scl:e.pixelRatio,scr:e.windowWidth+"x"+e.windowHeight,lg:e.language,fl:e.version,jv:encodeURIComponent(e.system),tz:encodeURIComponent(e.platform)}}();return function(e){wx.getNetworkType({success:function(t){e(t.networkType)}})}((function(e){try{wx.setStorageSync(Vu.prefix+"ntdata",e)}catch(t){}})),e.ct=wx.getStorageSync(Vu.prefix+"ntdata")||"4g",e}function Wu(){var e,t=Ju.Data.userInfo,n=[];for(e in t)t.hasOwnProperty(e)&&n.push(e+"="+t[e]);return t=n.join(";"),{r2:Vu.app_id,r4:"wx",ext:"v="+Vu.version+(null!==t&&""!==t?";ui="+encodeURIComponent(t):"")}}function Xu(e){if(!Vu.stat_param||!e)return"";e=function(e){if(1>Vu.ignore_params.length)return e;var t,n={};for(t in e)0<=Vu.ignore_params.indexOf(t)||(n[t]=e[t]);return n}(e);var t,n=[];for(t in e)n.push(t+"="+e[t]);return 0<n.length?"?"+n.join("&"):""}var Ju={App:{init:function(e){"appID"in e&&(Vu.app_id=e.appID),"eventID"in e&&(Vu.event_id=e.eventID),"statShareApp"in e&&(Vu.stat_share_app=e.statShareApp),"statPullDownFresh"in e&&(Vu.stat_pull_down_fresh=e.statPullDownFresh),"statReachBottom"in e&&(Vu.stat_reach_bottom=e.statReachBottom),"ignoreParams"in e&&(Vu.ignore_params=e.ignoreParams),"statParam"in e&&(Vu.stat_param=e.statParam),Ku();try{"lauchOpts"in e&&(Ju.Data.lanchInfo=e.lauchOpts,Ju.Data.lanchInfo.landing=1)}catch(t){}"autoReport"in e&&e.autoReport&&function(){var e=Page;Page=function(t){var n=t.onLoad;t.onLoad=function(e){n&&n.call(this,e),Ju.Data.lastPageQuery=Ju.Data.pageQuery,Ju.Data.pageQuery=e,Ju.Data.lastPageUrl=Ju.Data.pageUrl,Ju.Data.pageUrl=$u(),Ju.Data.show=!1,Ju.Page.init()},e(t)}}()}},Page:{init:function(){var e,t=getCurrentPages()[getCurrentPages().length-1];t.onShow&&(e=t.onShow,t.onShow=function(){if(!0===Ju.Data.show){var t=Ju.Data.lastPageQuery;Ju.Data.lastPageQuery=Ju.Data.pageQuery,Ju.Data.pageQuery=t,Ju.Data.lastPageUrl=Ju.Data.pageUrl,Ju.Data.pageUrl=$u()}Ju.Data.show=!0,Ju.Page.stat(),e.apply(this,arguments)}),Vu.stat_pull_down_fresh&&t.onPullDownRefresh&&function(){var e=t.onPullDownRefresh;t.onPullDownRefresh=function(){Ju.Event.stat(Vu.prefix+"pulldownfresh",{url:t.__route__}),e.apply(this,arguments)}}(),Vu.stat_reach_bottom&&t.onReachBottom&&function(){var e=t.onReachBottom;t.onReachBottom=function(){Ju.Event.stat(Vu.prefix+"reachbottom",{url:t.__route__}),e.apply(this,arguments)}}(),Vu.stat_share_app&&t.onShareAppMessage&&function(){var e=t.onShareAppMessage;t.onShareAppMessage=function(){return Ju.Event.stat(Vu.prefix+"shareapp",{url:t.__route__}),e.apply(this,arguments)}}()},multiStat:function(e,t){if(1==t)Ju.Page.stat(e);else{var n=getCurrentPages()[getCurrentPages().length-1];n.onShow&&function(){var t=n.onShow;n.onShow=function(){Ju.Page.stat(e),t.call(this,arguments)}}()}},stat:function(e){if(""!=Vu.app_id){var t=[],n=Wu();if(e&&(n.r2=e),e=[Yu(),n,zu()],Ju.Data.lanchInfo){e.push({ht:Ju.Data.lanchInfo.scene}),Ju.Data.pageQuery&&Ju.Data.pageQuery._mta_ref_id&&e.push({rarg:Ju.Data.pageQuery._mta_ref_id});try{1==Ju.Data.lanchInfo.landing&&(n.ext+=";lp=1",Ju.Data.lanchInfo.landing=0)}catch(i){}}e.push({rdm:"/",rurl:0>=Ju.Data.lastPageUrl.length?Ju.Data.pageUrl+Xu(Ju.Data.lastPageQuery):encodeURIComponent(Ju.Data.lastPageUrl+Xu(Ju.Data.lastPageQuery))}),e.push({rand:+new Date}),n=0;for(var r=e.length;n<r;n++)for(var o in e[n])e[n].hasOwnProperty(o)&&t.push(o+"="+(void 0===e[n][o]?"":e[n][o]));wx.request({url:Vu.api_base+"?"+t.join("&").toLowerCase()})}}},Event:{stat:function(e,t){if(""!=Vu.event_id){var n=[],r=Yu(),o=Wu();r.dm="wxapps.click",r.url=e,o.r2=Vu.event_id;var i,s=void 0===t?{}:t,a=[];for(i in s)s.hasOwnProperty(i)&&a.push(encodeURIComponent(i)+"="+encodeURIComponent(s[i]));for(s=a.join(";"),o.r5=s,s=0,o=(r=[r,o,zu(),{rand:+new Date}]).length;s<o;s++)for(var u in r[s])r[s].hasOwnProperty(u)&&n.push(u+"="+(void 0===r[s][u]?"":r[s][u]));wx.request({url:Vu.api_base+"?"+n.join("&").toLowerCase()})}}},Data:{userInfo:null,lanchInfo:null,pageQuery:null,lastPageQuery:null,pageUrl:"",lastPageUrl:"",show:!1}},Qu=Ju,Zu=function(){function e(){r(this,e),this.cache=[],this.MtaWX=null,this._init()}return i(e,[{key:"report",value:function(e,t){var n=this;try{R?window.MtaH5?(window.MtaH5.clickStat(e,t),this.cache.forEach((function(e){var t=e.name,r=e.param;window.MtaH5.clickStat(t,r),n.cache.shift()}))):this.cache.push({name:e,param:t}):O&&(this.MtaWX?(this.MtaWX.Event.stat(e,t),this.cache.forEach((function(e){var t=e.name,r=e.param;n.MtaWX.stat(t,r),n.cache.shift()}))):this.cache.push({name:e,param:t}))}catch(r){}}},{key:"stat",value:function(){try{R&&window.MtaH5?window.MtaH5.pgv():O&&this.MtaWX&&this.MtaWX.Page.stat()}catch(e){}}},{key:"_init",value:function(){try{if(R){window._mtac={autoReport:0};var e=document.createElement("script"),t=Ie();e.src="".concat(t,"//pingjs.qq.com/h5/stats.js?v2.0.4"),e.setAttribute("name","MTAH5"),e.setAttribute("sid","500690998"),e.setAttribute("cid","500691017");var n=document.getElementsByTagName("script")[0];n.parentNode.insertBefore(e,n)}else O&&(this.MtaWX=Qu,this.MtaWX.App.init({appID:"500690995",eventID:"500691014",autoReport:!1,statParam:!0}))}catch(r){}}}]),e}(),ec=function(e){c(n,e);var t=y(n);function n(e){var o;r(this,n),(o=t.call(this,e)).MTA=new Zu;var i=o.tim.innerEmitter;return i.on(Po,o._stat,g(o)),i.on(bo,o._stat,g(o)),o}return i(n,[{key:"_stat",value:function(){this.MTA.report("sdkappid",{value:this.tim.context.SDKAppID}),this.MTA.report("version",{value:dc.VERSION}),this.MTA.stat()}}]),n}(Bo),tc=function(){function e(t){r(this,e),this._table="timwebii",this._report=[]}return i(e,[{key:"pushIn",value:function(e){J.debug("SSOLogBody.pushIn",this._report.length,e),this._report.push(e)}},{key:"backfill",value:function(e){var t;re(e)&&0!==e.length&&(J.debug("SSOLogBody.backfill",this._report.length,e.length),(t=this._report).unshift.apply(t,_(e)))}},{key:"getLogsNumInMemory",value:function(){return this._report.length}},{key:"isEmpty",value:function(){return 0===this._report.length}},{key:"_reset",value:function(){this._report.length=0,this._report=[]}},{key:"getTable",value:function(){return this._table}},{key:"getLogsInMemory",value:function(){var e=this._report.slice();return this._reset(),e}}]),e}(),nc=function(e){c(n,e);var t=y(n);function n(e){var o;return r(this,n),(o=t.call(this,e)).TAG="im-ssolog-event",o._reportBody=new tc,o._version="2.6.1",o.MIN_THRESHOLD=20,o.MAX_THRESHOLD=100,o.WAITING_TIME=6e4,o.INTERVAL=2e4,o._timerID=0,o._resetLastReportTime(),o._startReportTimer(),o._retryCount=0,o.MAX_RETRY_COUNT=3,o.tim.innerEmitter.on(Do,o._onLoginSuccess,g(o)),o}return i(n,[{key:"reportAtOnce",value:function(){J.debug("EventStatController.reportAtOnce"),this._report()}},{key:"_onLoginSuccess",value:function(){var e=this,t=this.tim.storage,n=t.getItem(this.TAG,!1);Ae(n)||(J.log("EventStatController._onLoginSuccess get ssolog in storage, nums="+n.length),n.forEach((function(t){e._reportBody.pushIn(t)})),t.removeItem(this.TAG,!1))}},{key:"pushIn",value:function(e){e instanceof oi&&(e.setCommonInfo(this.tim.context.SDKAppID,this._version,this.tim.context.tinyID,this.tim.loginInfo.identifier,this.getPlatform()),this._reportBody.pushIn(e),this._reportBody.getLogsNumInMemory()>=this.MIN_THRESHOLD&&this._report())}},{key:"_resetLastReportTime",value:function(){this._lastReportTime=Date.now()}},{key:"_startReportTimer",value:function(){var e=this;this._timerID=setInterval((function(){Date.now()<e._lastReportTime+e.WAITING_TIME||e._reportBody.isEmpty()||e._report()}),this.INTERVAL)}},{key:"_stopReportTimer",value:function(){this._timerID>0&&(clearInterval(this._timerID),this._timerID=0)}},{key:"_report",value:function(){var e=this;if(!this._reportBody.isEmpty()){var t=this._reportBody.getLogsInMemory();this.request({name:"ssoEventStat",action:"create",param:{table:this._reportBody.getTable(),report:t}}).then((function(){e._resetLastReportTime(),e._retryCount>0&&(J.debug("EventStatController.report retry success"),e._retryCount=0)})).catch((function(n){if(J.warn("EventStatController.report, online:".concat(e.getNetworkType()," error:").concat(n)),e._reportBody.backfill(t),e._reportBody.getLogsNumInMemory()>e.MAX_THRESHOLD||e._retryCount===e.MAX_RETRY_COUNT||0===e._timerID)return e._retryCount=0,void e._flushAtOnce();e._retryCount+=1}))}}},{key:"_flushAtOnce",value:function(){var e=this.tim.storage,t=e.getItem(this.TAG,!1),n=this._reportBody.getLogsInMemory();if(Ae(t))J.log("EventStatController._flushAtOnce nums="+n.length),e.setItem(this.TAG,n,!0,!1);else{var r=n.concat(t);r.length>this.MAX_THRESHOLD&&(r=r.slice(0,this.MAX_THRESHOLD)),J.log("EventStatController._flushAtOnce nums="+r.length),e.setItem(this.TAG,r,!0,!1)}}},{key:"reset",value:function(){J.log("EventStatController.reset"),this._stopReportTimer(),this._report()}}]),n}(Bo),rc="none",oc="online",ic=function(){function e(){r(this,e),this._networkType="",this.maxWaitTime=3e3}return i(e,[{key:"start",value:function(){var e=this;O?(wx.getNetworkType({success:function(t){e._networkType=t.networkType,t.networkType===rc?J.warn("NetMonitor no network, please check!"):J.info("NetMonitor networkType:".concat(t.networkType))}}),wx.onNetworkStatusChange(this._onWxNetworkStatusChange.bind(this))):this._networkType=oc}},{key:"_onWxNetworkStatusChange",value:function(e){this._networkType=e.networkType,e.isConnected?J.info("NetMonitor networkType:".concat(e.networkType)):J.warn("NetMonitor no network, please check!")}},{key:"probe",value:function(){var e=this;return new Promise((function(t,n){if(O)wx.getNetworkType({success:function(n){e._networkType=n.networkType,n.networkType===rc?(J.warn("NetMonitor no network, please check!"),t([!1,n.networkType])):(J.info("NetMonitor networkType:".concat(n.networkType)),t([!0,n.networkType]))}});else if(window&&window.fetch)fetch("".concat(Ie(),"//webim-1252463788.file.myqcloud.com/assets/test/speed.xml?random=").concat(Math.random())).then((function(e){e.ok?t([!0,oc]):t([!1,rc])})).catch((function(e){t([!1,rc])}));else{var r=new XMLHttpRequest,o=setTimeout((function(){J.warn("NetMonitor fetch timeout. Probably no network, please check!"),r.abort(),e._networkType=rc,t([!1,rc])}),e.maxWaitTime);r.onreadystatechange=function(){4===r.readyState&&(clearTimeout(o),200===r.status||304===r.status?(this._networkType=oc,t([!0,oc])):(J.warn("NetMonitor fetch status:".concat(r.status,". Probably no network, please check!")),this._networkType=rc,t([!1,rc])))},r.open("GET","".concat(Ie(),"//webim-1252463788.file.myqcloud.com/assets/test/speed.xml?random=").concat(Math.random())),r.send()}}))}},{key:"getNetworkType",value:function(){return this._networkType}},{key:"reset",value:function(){this._networkType=""}}]),e}(),sc=function(){function e(t){var n=this;r(this,e),re(t)?(this._map=new Map,t.forEach((function(e){n._map.set(e,[])}))):J.warn("AverageCalculator.constructor need keys")}return i(e,[{key:"push",value:function(e,t){return!(oe(e)||!this._map.has(e)||!Z(t))&&(this._map.get(e).push(t),!0)}},{key:"getSize",value:function(e){return oe(e)||!this._map.has(e)?-1:this._map.get(e).length}},{key:"getAvg",value:function(e){if(oe(e)||!this._map.has(e))return-1;var t=this._map.get(e),n=t.length;if(0===n)return 0;var r=0;return t.forEach((function(e){r+=e})),t.length=0,this._map.set(e,[]),parseInt(r/n)}},{key:"getMax",value:function(e){return oe(e)||!this._map.has(e)?-1:Math.max.apply(null,this._map.get(e))}},{key:"getMin",value:function(e){return oe(e)||!this._map.has(e)?-1:Math.min.apply(null,this._map.get(e))}},{key:"reset",value:function(){this._map.forEach((function(e){e.length=0}))}}]),e}(),ac=function(){function e(t){var n=this;r(this,e),re(t)?(this._map=new Map,t.forEach((function(e){n._map.set(e,{totalCount:0,successCount:0})}))):J.warn("SuccessRateCalculator.constructor need keys")}return i(e,[{key:"addTotalCount",value:function(e){return!(oe(e)||!this._map.has(e))&&(this._map.get(e).totalCount+=1,!0)}},{key:"addSuccessCount",value:function(e){return!(oe(e)||!this._map.has(e))&&(this._map.get(e).successCount+=1,!0)}},{key:"getSuccessRate",value:function(e){if(oe(e)||!this._map.has(e))return-1;var t=this._map.get(e);if(0===t.totalCount)return 1;var n=parseFloat((t.successCount/t.totalCount).toFixed(2));return t.totalCount=t.successCount=0,n}},{key:"getTotalCount",value:function(e){return oe(e)||!this._map.has(e)?-1:this._map.get(e).totalCount}},{key:"reset",value:function(){this._map.forEach((function(e){e.totalCount=0,e.successCount=0}))}}]),e}(),uc=function(e){c(n,e);var t=y(n);function n(e){var o;return r(this,n),(o=t.call(this,e)).TABLE="timwebsum",o.TAG="im-ssolog-sumstat",o._items=[Qo,Zo,ei],o._thresholdMap=new Map,o._thresholdMap.set(Qo,100),o._thresholdMap.set(Zo,150),o._thresholdMap.set(ei,15),o._lpID="",o._platform=o.getPlatform(),o._lastReportTime=0,o._statInfoArr=[],o._retryCount=0,o._avgCalc=new sc(o._items),o._successRateCalc=new ac(o._items),o.tim.innerEmitter.on(Do,o._onLoginSuccess,g(o)),o}return i(n,[{key:"_onLoginSuccess",value:function(){var e=this,t=this.tim.storage,n=t.getItem(this.TAG,!1);Ae(n)||(J.log("SumStatController._onLoginSuccess get sumstatlog in storage, nums="+n.length),n.forEach((function(t){e._statInfoArr.pushIn(t)})),t.removeItem(this.TAG,!1))}},{key:"recordLongPollingID",value:function(e){this._lpID=e}},{key:"addTotalCount",value:function(e){this._successRateCalc.addTotalCount(e)?1===this._successRateCalc.getTotalCount(e)&&(this._lastReportTime=Date.now()):J.warn("SumStatController.addTotalCount invalid key:",e)}},{key:"addSuccessCount",value:function(e){this._successRateCalc.addSuccessCount(e)||J.warn("SumStatController.addSuccessCount invalid key:",e)}},{key:"addCost",value:function(e,t){this._avgCalc.push(e,t)?(J.debug("SumStatController.addCost",e,t,this._avgCalc.getSize(e)),this._avgCalc.getSize(e)>=this._thresholdMap.get(e)&&this._report(e)):J.warn("SumStatController.addCost invalid key or cost:",e,t)}},{key:"_getItemNum",value:function(e){switch(e){case Qo:return 1;case Zo:return 2;case ei:return 3;default:return 100}}},{key:"_getStatInfo",value:function(e){var t=null;return this._avgCalc.getSize(e)>0&&(t={SDKAppID:"".concat(this.tim.context.SDKAppID),version:"".concat("2.6.1"),tinyID:this.tim.context.tinyID,userID:this.tim.loginInfo.identifier,item:this._getItemNum(e),lpID:e===Qo?this._lpID:"",platform:this._platform,networkType:this.getNetworkType(),total:this._successRateCalc.getTotalCount(e),successRate:this._successRateCalc.getSuccessRate(e),avg:this._avgCalc.getAvg(e),timespan:Date.now()-this._lastReportTime,time:de()}),t}},{key:"_report",value:function(e){var t=this,n=[],r=null;oe(e)?this._items.forEach((function(e){null!==(r=t._getStatInfo(e))&&n.push(r)})):null!==(r=this._getStatInfo(e))&&n.push(r),J.debug("SumStatController._report",n),this._statInfoArr.length>0&&(n=n.concat(this.statInfoArr),this._statInfoArr=[]),this._doReport(n)}},{key:"_doReport",value:function(e){var t=this;Ae(e)?J.warn("SumStatController._doReport statInfoArr is empty, do nothing"):this.request({name:"ssoSumStat",action:"create",param:{table:this.TABLE,report:e}}).then((function(){t._lastReportTime=Date.now(),t._retryCount>0&&(J.debug("SumStatController._doReport retry success"),t._retryCount=0)})).catch((function(n){J.warn("SumStatController._doReport, online:".concat(t.getNetworkType()," error:"),n,e),t._retryCount<=1?setTimeout((function(){J.info("SumStatController._doReport retry",e),t._retryCount+=1,t._doReport(e)}),5e3):(t._retryCount=0,t._statInfoArr=t._statInfoArr.concat(e),t._flusgAtOnce())}))}},{key:"_flushAtOnce",value:function(){var e=this.tim.storage,t=e.getItem(this.TAG,!1),n=this._statInfoArr;if(Ae(t))J.log("SumStatController._flushAtOnce nums="+n.length),e.setItem(this.TAG,n,!0,!1);else{var r=n.concat(t);r.length>10&&(r=r.slice(0,10)),J.log("SumStatController._flushAtOnce nums="+r.length),e.setItem(this.TAG,r,!0,!1)}this._statInfoArr=[]}},{key:"reset",value:function(){J.info("SumStatController.reset"),this._report(),this._avgCalc.reset(),this._successRateCalc.reset()}}]),n}(Bo),cc=function(){function e(){r(this,e),this._funcMap=new Map}return i(e,[{key:"defense",value:function(e,t){var n=arguments.length>2&&void 0!==arguments[2]?arguments[2]:void 0;if("string"!=typeof e)return null;if(0===e.length)return null;if("function"!=typeof t)return null;if(this._funcMap.has(e)&&this._funcMap.get(e).has(t))return this._funcMap.get(e).get(t);this._funcMap.has(e)||this._funcMap.set(e,new Map);var r=null;return this._funcMap.get(e).has(t)?r=this._funcMap.get(e).get(t):(r=this._pack(t,n),this._funcMap.get(e).set(t,r)),r}},{key:"defenseOnce",value:function(e){var t=arguments.length>1&&void 0!==arguments[1]?arguments[1]:void 0;return"function"!=typeof e?null:this._pack(e,t)}},{key:"find",value:function(e,t){return"string"!=typeof e||0===e.length||"function"!=typeof t?null:this._funcMap.has(e)?this._funcMap.get(e).has(t)?this._funcMap.get(e).get(t):(J.log("SafetyCallback.find: 找不到 func —— ".concat(e,"/").concat(""!==t.name?t.name:"[anonymous]")),null):(J.log("SafetyCallback.find: 找不到 eventName-".concat(e," 对应的 func")),null)}},{key:"delete",value:function(e,t){return"function"==typeof t&&(!!this._funcMap.has(e)&&(!!this._funcMap.get(e).has(t)&&(this._funcMap.get(e).delete(t),0===this._funcMap.get(e).size&&this._funcMap.delete(e),!0)))}},{key:"_pack",value:function(e,t){return function(){try{e.apply(t,Array.from(arguments))}catch(n){console.error(n)}}}}]),e}(),lc=function(){function t(e){r(this,t);var n=new oi;n.setMethod(ii).setStart(),Ho.mixin(this),this._initOptions(e),this._initMemberVariables(),this._initControllers(),this._initListener(),oi.bindController(this.eventStatController),n.setCode(0).setText("mp=".concat(O,"-ua=").concat(L)).setEnd(),J.info("SDK inWxMiniApp:".concat(O,", SDKAppID:").concat(e.SDKAppID,", UserAgent:").concat(L)),this._safetyCallbackFactory=new cc}return i(t,[{key:"login",value:function(e){return J.time(Xo),this._ssoLog=new oi,this._ssoLog.setMethod(si).setStart(),this.netMonitor.start(),this.loginInfo.identifier=e.identifier||e.userID,this.loginInfo.userSig=e.userSig,this.signController.login(this.loginInfo)}},{key:"logout",value:function(){var e=this.signController.logout();return this.resetSDK(),e}},{key:"on",value:function(t,n,r){t===e.GROUP_SYSTEM_NOTICE_RECEIVED&&J.warn("！！！TIM.EVENT.GROUP_SYSTEM_NOTICE_RECEIVED v2.6.0起弃用，为了更好的体验，请在 TIM.EVENT.MESSAGE_RECEIVED 事件回调内接收处理群系统通知，详细请参考：https://imsdk-1252463788.file.myqcloud.com/IM_DOC/Web/Message.html#.GroupSystemNoticePayload"),J.debug("on","eventName:".concat(t)),this.outerEmitter.on(t,this._safetyCallbackFactory.defense(t,n,r),r)}},{key:"once",value:function(e,t,n){J.debug("once","eventName:".concat(e)),this.outerEmitter.once(e,this._safetyCallbackFactory.defenseOnce(t,n),n||this)}},{key:"off",value:function(e,t,n,r){J.debug("off","eventName:".concat(e));var o=this._safetyCallbackFactory.find(e,t);null!==o&&(this.outerEmitter.off(e,o,n,r),this._safetyCallbackFactory.delete(e,t))}},{key:"registerPlugin",value:function(e){var t=this;this.plugins||(this.plugins={}),Object.keys(e).forEach((function(n){t.plugins[n]=e[n]}))}},{key:"getPlugin",value:function(e){return this.plugins[e]||void 0}},{key:"setLogLevel",value:function(e){if(e<=0){console.log([""," ________  ______  __       __  __       __  ________  _______","|        \\|      \\|  \\     /  \\|  \\  _  |  \\|        \\|       \\"," \\$$$$$$$$ \\$$$$$$| $$\\   /  $$| $$ / \\ | $$| $$$$$$$$| $$$$$$$\\","   | $$     | $$  | $$$\\ /  $$$| $$/  $\\| $$| $$__    | $$__/ $$","   | $$     | $$  | $$$$\\  $$$$| $$  $$$\\ $$| $$  \\   | $$    $$","   | $$     | $$  | $$\\$$ $$ $$| $$ $$\\$$\\$$| $$$$$   | $$$$$$$\\","   | $$    _| $$_ | $$ \\$$$| $$| $$$$  \\$$$$| $$_____ | $$__/ $$","   | $$   |   $$ \\| $$  \\$ | $$| $$$    \\$$$| $$     \\| $$    $$","    \\$$    \\$$$$$$ \\$$      \\$$ \\$$      \\$$ \\$$$$$$$$ \\$$$$$$$","",""].join("\n")),console.log("%cIM 智能客服，随时随地解决您的问题 →_→ https://cloud.tencent.com/act/event/smarty-service?from=im-doc","color:#ff0000");console.log(["","参考以下文档，会更快解决问题哦！(#^.^#)\n","SDK 更新日志: https://cloud.tencent.com/document/product/269/38492\n","SDK 接口文档: https://imsdk-1252463788.file.myqcloud.com/IM_DOC/Web/SDK.html\n","常见问题: https://imsdk-1252463788.file.myqcloud.com/IM_DOC/Web/tutorial-01-faq.html\n","反馈问题？戳我提 issue: https://github.com/tencentyun/TIMSDK/issues\n","如果您需要在生产环境关闭上面的日志，请 tim.setLogLevel(1)\n"].join("\n"))}J.setLevel(e)}},{key:"downloadLog",value:function(){var e=document.createElement("a"),t=new Date,n=new Blob(this.getLog());e.download="TIM-"+t.getFullYear()+"-"+(t.getMonth()+1)+"-"+t.getDate()+"-"+this.loginInfo.SDKAppID+"-"+this.context.identifier+".txt",e.href=URL.createObjectURL(n),e.click(),URL.revokeObjectURL(n)}},{key:"destroy",value:function(){this.logout(),this.outerEmitter.emit(e.SDK_DESTROY,{SDKAppID:this.loginInfo.SDKAppID})}},{key:"createTextMessage",value:function(e){return this.messageController.createTextMessage(e)}},{key:"createImageMessage",value:function(e){return this.messageController.createImageMessage(e)}},{key:"createAudioMessage",value:function(e){return this.messageController.createAudioMessage(e)}},{key:"createVideoMessage",value:function(e){return this.messageController.createVideoMessage(e)}},{key:"createCustomMessage",value:function(e){return this.messageController.createCustomMessage(e)}},{key:"createFaceMessage",value:function(e){return this.messageController.createFaceMessage(e)}},{key:"createFileMessage",value:function(e){return this.messageController.createFileMessage(e)}},{key:"sendMessage",value:function(e){return e instanceof br?this.messageController.sendMessageInstance(e):Wo(new pt({code:It,message:Ln}))}},{key:"revokeMessage",value:function(e){return this.messageController.revokeMessage(e)}},{key:"resendMessage",value:function(e){return this.messageController.resendMessage(e)}},{key:"getMessageList",value:function(e){return this.messageController.getMessageList(e)}},{key:"setMessageRead",value:function(e){return this.messageController.setMessageRead(e)}},{key:"getConversationList",value:function(){return this.conversationController.getConversationList()}},{key:"getConversationProfile",value:function(e){return this.conversationController.getConversationProfile(e)}},{key:"deleteConversation",value:function(e){return this.conversationController.deleteConversation(e)}},{key:"getMyProfile",value:function(){return this.userController.getMyProfile()}},{key:"getUserProfile",value:function(e){return this.userController.getUserProfile(e)}},{key:"updateMyProfile",value:function(e){return this.userController.updateMyProfile(e)}},{key:"getFriendList",value:function(){return this.userController.getFriendList()}},{key:"deleteFriend",value:function(e){return this.userController.deleteFriend(e)}},{key:"getBlacklist",value:function(){return this.userController.getBlacklist()}},{key:"addToBlacklist",value:function(e){return this.userController.addBlacklist(e)}},{key:"removeFromBlacklist",value:function(e){return this.userController.deleteBlacklist(e)}},{key:"getGroupList",value:function(e){return this.groupController.getGroupList(e)}},{key:"getGroupProfile",value:function(e){return this.groupController.getGroupProfile(e)}},{key:"createGroup",value:function(e){return this.groupController.createGroup(e)}},{key:"dismissGroup",value:function(e){return this.groupController.dismissGroup(e)}},{key:"updateGroupProfile",value:function(e){return this.groupController.updateGroupProfile(e)}},{key:"joinGroup",value:function(e){return this.groupController.joinGroup(e)}},{key:"quitGroup",value:function(e){return this.groupController.quitGroup(e)}},{key:"searchGroupByID",value:function(e){return this.groupController.searchGroupByID(e)}},{key:"changeGroupOwner",value:function(e){return this.groupController.changeGroupOwner(e)}},{key:"handleGroupApplication",value:function(e){return this.groupController.handleGroupApplication(e)}},{key:"setMessageRemindType",value:function(e){return this.groupController.setMessageRemindType(e)}},{key:"getGroupMemberList",value:function(e){return this.groupController.getGroupMemberList(e)}},{key:"getGroupMemberProfile",value:function(e){return this.groupController.getGroupMemberProfile(e)}},{key:"addGroupMember",value:function(e){return this.groupController.addGroupMember(e)}},{key:"deleteGroupMember",value:function(e){return this.groupController.deleteGroupMember(e)}},{key:"setGroupMemberMuteTime",value:function(e){return this.groupController.setGroupMemberMuteTime(e)}},{key:"setGroupMemberRole",value:function(e){return this.groupController.setGroupMemberRole(e)}},{key:"setGroupMemberNameCard",value:function(e){return this.groupController.setGroupMemberNameCard(e)}},{key:"setGroupMemberCustomField",value:function(e){return this.groupController.setGroupMemberCustomField(e)}},{key:"_initOptions",value:function(e){this.plugins={};var t=e.SDKAppID||0,n=me();this.context={SDKAppID:t,accountType:n},this.loginInfo={SDKAppID:t,accountType:n,identifier:null,userSig:null},this.options={runLoopNetType:e.runLoopNetType||Xe,enablePointer:e.enablePointer||!1}}},{key:"_initMemberVariables",value:function(){this.innerEmitter=new bu,this.outerEmitter=new bu,Yo(this.outerEmitter),this.packageConfig=new Gu(this),this.storage=new Nu(this),this.netMonitor=new ic,this.outerEmitter._emit=this.outerEmitter.emit,this.outerEmitter.emit=function(e,t){var n=arguments[0],r=[n,{name:arguments[0],data:arguments[1]}];J.debug("emit outer event:".concat(n),r[1]),this.outerEmitter._emit.apply(this.outerEmitter,r)}.bind(this),this.innerEmitter._emit=this.innerEmitter.emit,this.innerEmitter.emit=function(e,t){var n;ne(arguments[1])&&arguments[1].data?(J.warn("inner eventData has data property, please check!"),n=[e,{name:arguments[0],data:arguments[1].data}]):n=[e,{name:arguments[0],data:arguments[1]}],J.debug("emit inner event:".concat(e),n[1]),this.innerEmitter._emit.apply(this.innerEmitter,n)}.bind(this)}},{key:"_initControllers",value:function(){this.exceptionController=new ru(this),this.connectionController=new nu(this),this.contextController=new Ko(this),this.context=this.contextController.getContext(),this.signController=new Hi(this),this.messageController=new Du(this),this.conversationController=new yu(this),this.userController=new hu(this),this.groupController=new Ru(this),this.notificationController=new Fu(this),this.bigDataHallwayController=new Bu(this),this.statusController=new Ou(this),this.uploadController=new Hu(this),this.eventStatController=new nc(this),this.sumStatController=new uc(this),this.mtaReportController=new ec(this),this._initReadyListener()}},{key:"_initListener",value:function(){var e=this;if(this.innerEmitter.on(uo,this._onSlowStart,this),O&&"function"==typeof wx.onAppShow&&"function"==typeof wx.onAppHide){var t=null;wx.onAppHide((function(){(t=new oi).setMethod(Fi).setStart()})),wx.onAppShow((function(){null!==t&&t.setCode(0).setNetworkType(e.netMonitor.getNetworkType()).setEnd()}))}}},{key:"_initReadyListener",value:function(){for(var e=this,t=this.readyList,n=0,r=t.length;n<r;n++)this[t[n]].ready((function(){return e._readyHandle()}))}},{key:"_onSlowStart",value:function(){J.log("slow start longpolling..."),this.resetSDK(),this.login(this.loginInfo)}},{key:"resetSDK",value:function(){var t=this;this.initList.forEach((function(e){t[e].reset&&t[e].reset()})),this.netMonitor.reset(),this.storage.reset(),this.resetReady(),this._initReadyListener(),this.outerEmitter.emit(e.SDK_NOT_READY)}},{key:"_readyHandle",value:function(){for(var t=this.readyList,n=!0,r=0,o=t.length;r<o;r++)if(!this[t[r]].isReady()){n=!1;break}if(n){var i=J.timeEnd(Xo);J.warn("SDK is ready. cost=".concat(i,"ms")),this.triggerReady(),this.innerEmitter.emit(Po),this.outerEmitter.emit(e.SDK_READY),this._ssoLog.setCode(0).setNetworkType(this.netMonitor.getNetworkType()).setText(i).setEnd()}}}]),t}();lc.prototype.readyList=["conversationController"],lc.prototype.initList=["exceptionController","connectionController","signController","contextController","messageController","conversationController","userController","groupController","notificationController","eventStatController","sumStatController"];var pc={login:"login",on:"on",off:"off",ready:"ready",setLogLevel:"setLogLevel",joinGroup:"joinGroup",quitGroup:"quitGroup",registerPlugin:"registerPlugin"};function hc(e,t){return!(!e.isReady()&&void 0===pc[t])||(e.innerEmitter.emit(wo,new pt({code:_n,message:"".concat(t," ").concat(Er,"，请参考 https://imsdk-1252463788.file.myqcloud.com/IM_DOC/Web/module-EVENT.html#.SDK_READY")})),!1)}var fc={},dc={};return dc.create=function(t){if(t.SDKAppID&&fc[t.SDKAppID])return fc[t.SDKAppID];J.log("TIM.create");var n=new lc(t);n.on(e.SDK_DESTROY,(function(e){fc[e.data.SDKAppID]=null,delete fc[e.data.SDKAppID]}));var r=function(e){var t=Object.create(null);return Object.keys(Ur).forEach((function(n){if(e[n]){var r=Ur[n],o=new S;t[r]=function(){var t=Array.from(arguments);return o.use((function(t,r){if(hc(e,n))return r()})).use((function(e,t){if(!0===Re(e,Gr[n],r))return t()})).use((function(t,r){return e[n].apply(e,t)})),o.run(t)}}})),t}(n);return fc[t.SDKAppID]=r,J.log("TIM.create ok"),r},dc.TYPES=t,dc.EVENT=e,dc.VERSION="2.6.1",J.log("TIM.VERSION: ".concat(dc.VERSION)),dc}));

},/***** module 3 end *****/


/***** module 4 start *****/
/***** /Users/xingchenhe/Documents/work/git.code.oa.com/live-demo-component/node_modules/qs/lib/parse.js *****/
function(module, exports, __wepy_require) {'use strict';

var utils = __wepy_require(6);

var has = Object.prototype.hasOwnProperty;
var isArray = Array.isArray;

var defaults = {
    allowDots: false,
    allowPrototypes: false,
    arrayLimit: 20,
    charset: 'utf-8',
    charsetSentinel: false,
    comma: false,
    decoder: utils.decode,
    delimiter: '&',
    depth: 5,
    ignoreQueryPrefix: false,
    interpretNumericEntities: false,
    parameterLimit: 1000,
    parseArrays: true,
    plainObjects: false,
    strictNullHandling: false
};

var interpretNumericEntities = function (str) {
    return str.replace(/&#(\d+);/g, function ($0, numberStr) {
        return String.fromCharCode(parseInt(numberStr, 10));
    });
};

var parseArrayValue = function (val, options) {
    if (val && typeof val === 'string' && options.comma && val.indexOf(',') > -1) {
        return val.split(',');
    }

    return val;
};

var maybeMap = function maybeMap(val, fn) {
    if (isArray(val)) {
        var mapped = [];
        for (var i = 0; i < val.length; i += 1) {
            mapped.push(fn(val[i]));
        }
        return mapped;
    }
    return fn(val);
};

// This is what browsers will submit when the ✓ character occurs in an
// application/x-www-form-urlencoded body and the encoding of the page containing
// the form is iso-8859-1, or when the submitted form has an accept-charset
// attribute of iso-8859-1. Presumably also with other charsets that do not contain
// the ✓ character, such as us-ascii.
var isoSentinel = 'utf8=%26%2310003%3B'; // encodeURIComponent('&#10003;')

// These are the percent-encoded utf-8 octets representing a checkmark, indicating that the request actually is utf-8 encoded.
var charsetSentinel = 'utf8=%E2%9C%93'; // encodeURIComponent('✓')

var parseValues = function parseQueryStringValues(str, options) {
    var obj = {};
    var cleanStr = options.ignoreQueryPrefix ? str.replace(/^\?/, '') : str;
    var limit = options.parameterLimit === Infinity ? undefined : options.parameterLimit;
    var parts = cleanStr.split(options.delimiter, limit);
    var skipIndex = -1; // Keep track of where the utf8 sentinel was found
    var i;

    var charset = options.charset;
    if (options.charsetSentinel) {
        for (i = 0; i < parts.length; ++i) {
            if (parts[i].indexOf('utf8=') === 0) {
                if (parts[i] === charsetSentinel) {
                    charset = 'utf-8';
                } else if (parts[i] === isoSentinel) {
                    charset = 'iso-8859-1';
                }
                skipIndex = i;
                i = parts.length; // The eslint settings do not allow break;
            }
        }
    }

    for (i = 0; i < parts.length; ++i) {
        if (i === skipIndex) {
            continue;
        }
        var part = parts[i];

        var bracketEqualsPos = part.indexOf(']=');
        var pos = bracketEqualsPos === -1 ? part.indexOf('=') : bracketEqualsPos + 1;

        var key, val;
        if (pos === -1) {
            key = options.decoder(part, defaults.decoder, charset, 'key');
            val = options.strictNullHandling ? null : '';
        } else {
            key = options.decoder(part.slice(0, pos), defaults.decoder, charset, 'key');
            val = maybeMap(
                parseArrayValue(part.slice(pos + 1), options),
                function (encodedVal) {
                    return options.decoder(encodedVal, defaults.decoder, charset, 'value');
                }
            );
        }

        if (val && options.interpretNumericEntities && charset === 'iso-8859-1') {
            val = interpretNumericEntities(val);
        }

        if (part.indexOf('[]=') > -1) {
            val = isArray(val) ? [val] : val;
        }

        if (has.call(obj, key)) {
            obj[key] = utils.combine(obj[key], val);
        } else {
            obj[key] = val;
        }
    }

    return obj;
};

var parseObject = function (chain, val, options, valuesParsed) {
    var leaf = valuesParsed ? val : parseArrayValue(val, options);

    for (var i = chain.length - 1; i >= 0; --i) {
        var obj;
        var root = chain[i];

        if (root === '[]' && options.parseArrays) {
            obj = [].concat(leaf);
        } else {
            obj = options.plainObjects ? Object.create(null) : {};
            var cleanRoot = root.charAt(0) === '[' && root.charAt(root.length - 1) === ']' ? root.slice(1, -1) : root;
            var index = parseInt(cleanRoot, 10);
            if (!options.parseArrays && cleanRoot === '') {
                obj = { 0: leaf };
            } else if (
                !isNaN(index)
                && root !== cleanRoot
                && String(index) === cleanRoot
                && index >= 0
                && (options.parseArrays && index <= options.arrayLimit)
            ) {
                obj = [];
                obj[index] = leaf;
            } else {
                obj[cleanRoot] = leaf;
            }
        }

        leaf = obj; // eslint-disable-line no-param-reassign
    }

    return leaf;
};

var parseKeys = function parseQueryStringKeys(givenKey, val, options, valuesParsed) {
    if (!givenKey) {
        return;
    }

    // Transform dot notation to bracket notation
    var key = options.allowDots ? givenKey.replace(/\.([^.[]+)/g, '[$1]') : givenKey;

    // The regex chunks

    var brackets = /(\[[^[\]]*])/;
    var child = /(\[[^[\]]*])/g;

    // Get the parent

    var segment = options.depth > 0 && brackets.exec(key);
    var parent = segment ? key.slice(0, segment.index) : key;

    // Stash the parent if it exists

    var keys = [];
    if (parent) {
        // If we aren't using plain objects, optionally prefix keys that would overwrite object prototype properties
        if (!options.plainObjects && has.call(Object.prototype, parent)) {
            if (!options.allowPrototypes) {
                return;
            }
        }

        keys.push(parent);
    }

    // Loop through children appending to the array until we hit depth

    var i = 0;
    while (options.depth > 0 && (segment = child.exec(key)) !== null && i < options.depth) {
        i += 1;
        if (!options.plainObjects && has.call(Object.prototype, segment[1].slice(1, -1))) {
            if (!options.allowPrototypes) {
                return;
            }
        }
        keys.push(segment[1]);
    }

    // If there's a remainder, just add whatever is left

    if (segment) {
        keys.push('[' + key.slice(segment.index) + ']');
    }

    return parseObject(keys, val, options, valuesParsed);
};

var normalizeParseOptions = function normalizeParseOptions(opts) {
    if (!opts) {
        return defaults;
    }

    if (opts.decoder !== null && opts.decoder !== undefined && typeof opts.decoder !== 'function') {
        throw new TypeError('Decoder has to be a function.');
    }

    if (typeof opts.charset !== 'undefined' && opts.charset !== 'utf-8' && opts.charset !== 'iso-8859-1') {
        throw new TypeError('The charset option must be either utf-8, iso-8859-1, or undefined');
    }
    var charset = typeof opts.charset === 'undefined' ? defaults.charset : opts.charset;

    return {
        allowDots: typeof opts.allowDots === 'undefined' ? defaults.allowDots : !!opts.allowDots,
        allowPrototypes: typeof opts.allowPrototypes === 'boolean' ? opts.allowPrototypes : defaults.allowPrototypes,
        arrayLimit: typeof opts.arrayLimit === 'number' ? opts.arrayLimit : defaults.arrayLimit,
        charset: charset,
        charsetSentinel: typeof opts.charsetSentinel === 'boolean' ? opts.charsetSentinel : defaults.charsetSentinel,
        comma: typeof opts.comma === 'boolean' ? opts.comma : defaults.comma,
        decoder: typeof opts.decoder === 'function' ? opts.decoder : defaults.decoder,
        delimiter: typeof opts.delimiter === 'string' || utils.isRegExp(opts.delimiter) ? opts.delimiter : defaults.delimiter,
        // eslint-disable-next-line no-implicit-coercion, no-extra-parens
        depth: (typeof opts.depth === 'number' || opts.depth === false) ? +opts.depth : defaults.depth,
        ignoreQueryPrefix: opts.ignoreQueryPrefix === true,
        interpretNumericEntities: typeof opts.interpretNumericEntities === 'boolean' ? opts.interpretNumericEntities : defaults.interpretNumericEntities,
        parameterLimit: typeof opts.parameterLimit === 'number' ? opts.parameterLimit : defaults.parameterLimit,
        parseArrays: opts.parseArrays !== false,
        plainObjects: typeof opts.plainObjects === 'boolean' ? opts.plainObjects : defaults.plainObjects,
        strictNullHandling: typeof opts.strictNullHandling === 'boolean' ? opts.strictNullHandling : defaults.strictNullHandling
    };
};

module.exports = function (str, opts) {
    var options = normalizeParseOptions(opts);

    if (str === '' || str === null || typeof str === 'undefined') {
        return options.plainObjects ? Object.create(null) : {};
    }

    var tempObj = typeof str === 'string' ? parseValues(str, options) : str;
    var obj = options.plainObjects ? Object.create(null) : {};

    // Iterate over the keys and setup the new object

    var keys = Object.keys(tempObj);
    for (var i = 0; i < keys.length; ++i) {
        var key = keys[i];
        var newObj = parseKeys(key, tempObj[key], options, typeof str === 'string');
        obj = utils.merge(obj, newObj, options);
    }

    return utils.compact(obj);
};

},/***** module 4 end *****/


/***** module 5 start *****/
/***** /Users/xingchenhe/Documents/work/git.code.oa.com/live-demo-component/node_modules/qs/lib/formats.js *****/
function(module, exports, __wepy_require) {'use strict';

var replace = String.prototype.replace;
var percentTwenties = /%20/g;

var util = __wepy_require(6);

var Format = {
    RFC1738: 'RFC1738',
    RFC3986: 'RFC3986'
};

module.exports = util.assign(
    {
        'default': Format.RFC3986,
        formatters: {
            RFC1738: function (value) {
                return replace.call(value, percentTwenties, '+');
            },
            RFC3986: function (value) {
                return String(value);
            }
        }
    },
    Format
);

},/***** module 5 end *****/


/***** module 6 start *****/
/***** /Users/xingchenhe/Documents/work/git.code.oa.com/live-demo-component/node_modules/qs/lib/utils.js *****/
function(module, exports, __wepy_require) {'use strict';

var has = Object.prototype.hasOwnProperty;
var isArray = Array.isArray;

var hexTable = (function () {
    var array = [];
    for (var i = 0; i < 256; ++i) {
        array.push('%' + ((i < 16 ? '0' : '') + i.toString(16)).toUpperCase());
    }

    return array;
}());

var compactQueue = function compactQueue(queue) {
    while (queue.length > 1) {
        var item = queue.pop();
        var obj = item.obj[item.prop];

        if (isArray(obj)) {
            var compacted = [];

            for (var j = 0; j < obj.length; ++j) {
                if (typeof obj[j] !== 'undefined') {
                    compacted.push(obj[j]);
                }
            }

            item.obj[item.prop] = compacted;
        }
    }
};

var arrayToObject = function arrayToObject(source, options) {
    var obj = options && options.plainObjects ? Object.create(null) : {};
    for (var i = 0; i < source.length; ++i) {
        if (typeof source[i] !== 'undefined') {
            obj[i] = source[i];
        }
    }

    return obj;
};

var merge = function merge(target, source, options) {
    /* eslint no-param-reassign: 0 */
    if (!source) {
        return target;
    }

    if (typeof source !== 'object') {
        if (isArray(target)) {
            target.push(source);
        } else if (target && typeof target === 'object') {
            if ((options && (options.plainObjects || options.allowPrototypes)) || !has.call(Object.prototype, source)) {
                target[source] = true;
            }
        } else {
            return [target, source];
        }

        return target;
    }

    if (!target || typeof target !== 'object') {
        return [target].concat(source);
    }

    var mergeTarget = target;
    if (isArray(target) && !isArray(source)) {
        mergeTarget = arrayToObject(target, options);
    }

    if (isArray(target) && isArray(source)) {
        source.forEach(function (item, i) {
            if (has.call(target, i)) {
                var targetItem = target[i];
                if (targetItem && typeof targetItem === 'object' && item && typeof item === 'object') {
                    target[i] = merge(targetItem, item, options);
                } else {
                    target.push(item);
                }
            } else {
                target[i] = item;
            }
        });
        return target;
    }

    return Object.keys(source).reduce(function (acc, key) {
        var value = source[key];

        if (has.call(acc, key)) {
            acc[key] = merge(acc[key], value, options);
        } else {
            acc[key] = value;
        }
        return acc;
    }, mergeTarget);
};

var assign = function assignSingleSource(target, source) {
    return Object.keys(source).reduce(function (acc, key) {
        acc[key] = source[key];
        return acc;
    }, target);
};

var decode = function (str, decoder, charset) {
    var strWithoutPlus = str.replace(/\+/g, ' ');
    if (charset === 'iso-8859-1') {
        // unescape never throws, no try...catch needed:
        return strWithoutPlus.replace(/%[0-9a-f]{2}/gi, unescape);
    }
    // utf-8
    try {
        return decodeURIComponent(strWithoutPlus);
    } catch (e) {
        return strWithoutPlus;
    }
};

var encode = function encode(str, defaultEncoder, charset) {
    // This code was originally written by Brian White (mscdex) for the io.js core querystring library.
    // It has been adapted here for stricter adherence to RFC 3986
    if (str.length === 0) {
        return str;
    }

    var string = str;
    if (typeof str === 'symbol') {
        string = Symbol.prototype.toString.call(str);
    } else if (typeof str !== 'string') {
        string = String(str);
    }

    if (charset === 'iso-8859-1') {
        return escape(string).replace(/%u[0-9a-f]{4}/gi, function ($0) {
            return '%26%23' + parseInt($0.slice(2), 16) + '%3B';
        });
    }

    var out = '';
    for (var i = 0; i < string.length; ++i) {
        var c = string.charCodeAt(i);

        if (
            c === 0x2D // -
            || c === 0x2E // .
            || c === 0x5F // _
            || c === 0x7E // ~
            || (c >= 0x30 && c <= 0x39) // 0-9
            || (c >= 0x41 && c <= 0x5A) // a-z
            || (c >= 0x61 && c <= 0x7A) // A-Z
        ) {
            out += string.charAt(i);
            continue;
        }

        if (c < 0x80) {
            out = out + hexTable[c];
            continue;
        }

        if (c < 0x800) {
            out = out + (hexTable[0xC0 | (c >> 6)] + hexTable[0x80 | (c & 0x3F)]);
            continue;
        }

        if (c < 0xD800 || c >= 0xE000) {
            out = out + (hexTable[0xE0 | (c >> 12)] + hexTable[0x80 | ((c >> 6) & 0x3F)] + hexTable[0x80 | (c & 0x3F)]);
            continue;
        }

        i += 1;
        c = 0x10000 + (((c & 0x3FF) << 10) | (string.charCodeAt(i) & 0x3FF));
        out += hexTable[0xF0 | (c >> 18)]
            + hexTable[0x80 | ((c >> 12) & 0x3F)]
            + hexTable[0x80 | ((c >> 6) & 0x3F)]
            + hexTable[0x80 | (c & 0x3F)];
    }

    return out;
};

var compact = function compact(value) {
    var queue = [{ obj: { o: value }, prop: 'o' }];
    var refs = [];

    for (var i = 0; i < queue.length; ++i) {
        var item = queue[i];
        var obj = item.obj[item.prop];

        var keys = Object.keys(obj);
        for (var j = 0; j < keys.length; ++j) {
            var key = keys[j];
            var val = obj[key];
            if (typeof val === 'object' && val !== null && refs.indexOf(val) === -1) {
                queue.push({ obj: obj, prop: key });
                refs.push(val);
            }
        }
    }

    compactQueue(queue);

    return value;
};

var isRegExp = function isRegExp(obj) {
    return Object.prototype.toString.call(obj) === '[object RegExp]';
};

var isBuffer = function isBuffer(obj) {
    if (!obj || typeof obj !== 'object') {
        return false;
    }

    return !!(obj.constructor && obj.constructor.isBuffer && obj.constructor.isBuffer(obj));
};

var combine = function combine(a, b) {
    return [].concat(a, b);
};

module.exports = {
    arrayToObject: arrayToObject,
    assign: assign,
    combine: combine,
    compact: compact,
    decode: decode,
    encode: encode,
    isBuffer: isBuffer,
    isRegExp: isRegExp,
    merge: merge
};

},/***** module 6 end *****/


/***** module 7 start *****/
/***** /Users/xingchenhe/Documents/work/git.code.oa.com/live-demo-component/node_modules/qs/lib/stringify.js *****/
function(module, exports, __wepy_require) {'use strict';

var utils = __wepy_require(6);
var formats = __wepy_require(5);
var has = Object.prototype.hasOwnProperty;

var arrayPrefixGenerators = {
    brackets: function brackets(prefix) {
        return prefix + '[]';
    },
    comma: 'comma',
    indices: function indices(prefix, key) {
        return prefix + '[' + key + ']';
    },
    repeat: function repeat(prefix) {
        return prefix;
    }
};

var isArray = Array.isArray;
var push = Array.prototype.push;
var pushToArray = function (arr, valueOrArray) {
    push.apply(arr, isArray(valueOrArray) ? valueOrArray : [valueOrArray]);
};

var toISO = Date.prototype.toISOString;

var defaultFormat = formats['default'];
var defaults = {
    addQueryPrefix: false,
    allowDots: false,
    charset: 'utf-8',
    charsetSentinel: false,
    delimiter: '&',
    encode: true,
    encoder: utils.encode,
    encodeValuesOnly: false,
    format: defaultFormat,
    formatter: formats.formatters[defaultFormat],
    // deprecated
    indices: false,
    serializeDate: function serializeDate(date) {
        return toISO.call(date);
    },
    skipNulls: false,
    strictNullHandling: false
};

var isNonNullishPrimitive = function isNonNullishPrimitive(v) {
    return typeof v === 'string'
        || typeof v === 'number'
        || typeof v === 'boolean'
        || typeof v === 'symbol'
        || typeof v === 'bigint';
};

var stringify = function stringify(
    object,
    prefix,
    generateArrayPrefix,
    strictNullHandling,
    skipNulls,
    encoder,
    filter,
    sort,
    allowDots,
    serializeDate,
    formatter,
    encodeValuesOnly,
    charset
) {
    var obj = object;
    if (typeof filter === 'function') {
        obj = filter(prefix, obj);
    } else if (obj instanceof Date) {
        obj = serializeDate(obj);
    } else if (generateArrayPrefix === 'comma' && isArray(obj)) {
        obj = obj.join(',');
    }

    if (obj === null) {
        if (strictNullHandling) {
            return encoder && !encodeValuesOnly ? encoder(prefix, defaults.encoder, charset, 'key') : prefix;
        }

        obj = '';
    }

    if (isNonNullishPrimitive(obj) || utils.isBuffer(obj)) {
        if (encoder) {
            var keyValue = encodeValuesOnly ? prefix : encoder(prefix, defaults.encoder, charset, 'key');
            return [formatter(keyValue) + '=' + formatter(encoder(obj, defaults.encoder, charset, 'value'))];
        }
        return [formatter(prefix) + '=' + formatter(String(obj))];
    }

    var values = [];

    if (typeof obj === 'undefined') {
        return values;
    }

    var objKeys;
    if (isArray(filter)) {
        objKeys = filter;
    } else {
        var keys = Object.keys(obj);
        objKeys = sort ? keys.sort(sort) : keys;
    }

    for (var i = 0; i < objKeys.length; ++i) {
        var key = objKeys[i];

        if (skipNulls && obj[key] === null) {
            continue;
        }

        if (isArray(obj)) {
            pushToArray(values, stringify(
                obj[key],
                typeof generateArrayPrefix === 'function' ? generateArrayPrefix(prefix, key) : prefix,
                generateArrayPrefix,
                strictNullHandling,
                skipNulls,
                encoder,
                filter,
                sort,
                allowDots,
                serializeDate,
                formatter,
                encodeValuesOnly,
                charset
            ));
        } else {
            pushToArray(values, stringify(
                obj[key],
                prefix + (allowDots ? '.' + key : '[' + key + ']'),
                generateArrayPrefix,
                strictNullHandling,
                skipNulls,
                encoder,
                filter,
                sort,
                allowDots,
                serializeDate,
                formatter,
                encodeValuesOnly,
                charset
            ));
        }
    }

    return values;
};

var normalizeStringifyOptions = function normalizeStringifyOptions(opts) {
    if (!opts) {
        return defaults;
    }

    if (opts.encoder !== null && opts.encoder !== undefined && typeof opts.encoder !== 'function') {
        throw new TypeError('Encoder has to be a function.');
    }

    var charset = opts.charset || defaults.charset;
    if (typeof opts.charset !== 'undefined' && opts.charset !== 'utf-8' && opts.charset !== 'iso-8859-1') {
        throw new TypeError('The charset option must be either utf-8, iso-8859-1, or undefined');
    }

    var format = formats['default'];
    if (typeof opts.format !== 'undefined') {
        if (!has.call(formats.formatters, opts.format)) {
            throw new TypeError('Unknown format option provided.');
        }
        format = opts.format;
    }
    var formatter = formats.formatters[format];

    var filter = defaults.filter;
    if (typeof opts.filter === 'function' || isArray(opts.filter)) {
        filter = opts.filter;
    }

    return {
        addQueryPrefix: typeof opts.addQueryPrefix === 'boolean' ? opts.addQueryPrefix : defaults.addQueryPrefix,
        allowDots: typeof opts.allowDots === 'undefined' ? defaults.allowDots : !!opts.allowDots,
        charset: charset,
        charsetSentinel: typeof opts.charsetSentinel === 'boolean' ? opts.charsetSentinel : defaults.charsetSentinel,
        delimiter: typeof opts.delimiter === 'undefined' ? defaults.delimiter : opts.delimiter,
        encode: typeof opts.encode === 'boolean' ? opts.encode : defaults.encode,
        encoder: typeof opts.encoder === 'function' ? opts.encoder : defaults.encoder,
        encodeValuesOnly: typeof opts.encodeValuesOnly === 'boolean' ? opts.encodeValuesOnly : defaults.encodeValuesOnly,
        filter: filter,
        formatter: formatter,
        serializeDate: typeof opts.serializeDate === 'function' ? opts.serializeDate : defaults.serializeDate,
        skipNulls: typeof opts.skipNulls === 'boolean' ? opts.skipNulls : defaults.skipNulls,
        sort: typeof opts.sort === 'function' ? opts.sort : null,
        strictNullHandling: typeof opts.strictNullHandling === 'boolean' ? opts.strictNullHandling : defaults.strictNullHandling
    };
};

module.exports = function (object, opts) {
    var obj = object;
    var options = normalizeStringifyOptions(opts);

    var objKeys;
    var filter;

    if (typeof options.filter === 'function') {
        filter = options.filter;
        obj = filter('', obj);
    } else if (isArray(options.filter)) {
        filter = options.filter;
        objKeys = filter;
    }

    var keys = [];

    if (typeof obj !== 'object' || obj === null) {
        return '';
    }

    var arrayFormat;
    if (opts && opts.arrayFormat in arrayPrefixGenerators) {
        arrayFormat = opts.arrayFormat;
    } else if (opts && 'indices' in opts) {
        arrayFormat = opts.indices ? 'indices' : 'repeat';
    } else {
        arrayFormat = 'indices';
    }

    var generateArrayPrefix = arrayPrefixGenerators[arrayFormat];

    if (!objKeys) {
        objKeys = Object.keys(obj);
    }

    if (options.sort) {
        objKeys.sort(options.sort);
    }

    for (var i = 0; i < objKeys.length; ++i) {
        var key = objKeys[i];

        if (options.skipNulls && obj[key] === null) {
            continue;
        }
        pushToArray(keys, stringify(
            obj[key],
            key,
            generateArrayPrefix,
            options.strictNullHandling,
            options.skipNulls,
            options.encode ? options.encoder : null,
            options.filter,
            options.sort,
            options.allowDots,
            options.serializeDate,
            options.formatter,
            options.encodeValuesOnly,
            options.charset
        ));
    }

    var joined = keys.join(options.delimiter);
    var prefix = options.addQueryPrefix === true ? '?' : '';

    if (options.charsetSentinel) {
        if (options.charset === 'iso-8859-1') {
            // encodeURIComponent('&#10003;'), the "numeric entity" representation of a checkmark
            prefix += 'utf8=%26%2310003%3B&';
        } else {
            // encodeURIComponent('✓')
            prefix += 'utf8=%E2%9C%93&';
        }
    }

    return joined.length > 0 ? prefix + joined : '';
};

},/***** module 7 end *****/


/***** module 8 start *****/
/***** /Users/xingchenhe/Documents/work/git.code.oa.com/live-demo-component/node_modules/qs/lib/index.js *****/
function(module, exports, __wepy_require) {'use strict';

var stringify = __wepy_require(7);
var parse = __wepy_require(4);
var formats = __wepy_require(5);

module.exports = {
    formats: formats,
    parse: parse,
    stringify: stringify
};

}/***** module 8 end *****/


]);