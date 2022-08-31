/**
 *  ====================================================================
 * @tencent/aegis-mp-sdk@1.34.75 (c) 2021 Tencent Application Monitor.
 * Author pumpkincai.
 * Last Release Time Tue Dec 07 2021 14:47:12 GMT+0800 (GMT+08:00).
 * Released under the MIT License.
 * Thanks for supporting TAM & Aegis!
 * ====================================================================
 **/
!(function (e, t) {
  'object' === typeof exports && 'undefined' !== typeof module ? module.exports = t() : 'function' === typeof define && define.amd ? define(t) : (e = 'undefined' !== typeof globalThis ? globalThis : e || self).Aegis = t();
}(this, () => {
  'use strict';var i = function (e, t) {
    return (i = Object.setPrototypeOf || { __proto__: [] } instanceof Array && function (e, t) {
      e.__proto__ = t;
    } || function (e, t) {
      for (const n in t)Object.prototype.hasOwnProperty.call(t, n) && (e[n] = t[n]);
    })(e, t);
  };function e(e, t) {
    function n() {
      this.constructor = e;
    }i(e, t), e.prototype = null === t ? Object.create(t) : (n.prototype = t.prototype, new n);
  } var a = function () {
    return (a = Object.assign || function (e) {
      for (var t, n = 1, i = arguments.length;n < i;n++) for (const o in t = arguments[n])Object.prototype.hasOwnProperty.call(t, o) && (e[o] = t[o]);return e;
    }).apply(this, arguments);
  };function s() {
    for (var e = 0, t = 0, n = arguments.length;t < n;t++)e += arguments[t].length;for (var i = Array(e), o = 0, t = 0;t < n;t++) for (let r = arguments[t], s = 0, a = r.length;s < a;s++, o++)i[o] = r[s];return i;
  }Object.assign || Object.defineProperty(Object, 'assign', { enumerable: !1, configurable: !0, writable: !0, value(e) {
    if (null == e) throw new TypeError('Cannot convert first argument to object');for (var t = Object(e), n = 1;n < arguments.length;n++) if (null != (i = arguments[n])) for (var i = Object(i), o = Object.keys(Object(i)), r = 0, s = o.length;r < s;r++) {
      const a = o[r]; const l = Object.getOwnPropertyDescriptor(i, a);null != l && l.enumerable && (t[a] = i[a]);
    } return t;
  } });function o(t) {
    try {
      return encodeURIComponent(decodeURIComponent(t));
    } catch (e) {
      return t;
    }
  } const h = (n.prototype.indexOf = function (e, t) {
    for (let n = 0;n < e.length;n++) if (e[n].callback === t) return n;return -1;
  }, n.prototype.on = function (e, t, n) {
    if (void 0 === n && (n = 0), this) {
      let i = this.eventsList[e];return (i || (this.eventsList[e] = [], i = this.eventsList[e]), -1 !== this.indexOf(i, t)) ? this : (i.push({ name: e, type: n || 0, callback: t }), this);
    }
  }, n.prototype.one = function (e, t) {
    this.on(e, t, 1);
  }, n.prototype.remove = function (e, t) {
    if (this) {
      const n = this.eventsList[e];if (!n) return null;if (t) return n.length && (t = this.indexOf(n, t), n.splice(t, 1)), this;try {
        delete this.eventsList[e];
      } catch (e) {} return null;
    }
  }, n.prototype.clear = function () {
    this.eventsList = {};
  }, n); const t = function (e) {
    return (e = Array.isArray(e) ? e : [e]).map((t, n) => Object.getOwnPropertyNames(t).map(e => `${o(e)}[${n}]=${void 0 === t[e] ? '' : o(t[e])}`)
      .join('&')).join('&') + (e.length ? `&count=${e.length}` : '');
  };function n() {
    const s = this;this.emit = function (e, t) {
      if (s) {
        let n;if (null != (i = s.eventsList[e]) && i.length) for (var i = i.slice(), o = 0;o < i.length;o++) {
          n = i[o];try {
            const r = n.callback.apply(s, [t]);if (1 === n.type && s.remove(e, n.callback), !1 === r) break;
          } catch (e) {
            throw e;
          }
        } return s;
      }
    }, this.eventsList = {};
  } function l(e, t) {
    return 'string' === typeof e ? e.split('?')[t ? 1 : 0] || '' : e;
  } function u(e) {
    return 'string' === typeof e && e.startsWith('//') ? 'undefined' !== typeof location && 'https:' === location.protocol : /^https/.test(e);
  } function c(e, t, n) {
    let i;try {
      if ('function' === typeof (null == t ? void 0 : t.retCodeHandler)) {
        const o = t.retCodeHandler(e, null == n ? void 0 : n.url, null == n ? void 0 : n.ctx) || {};return { code: void 0 === (r = o.code) ? 'unknown' : r, isErr: o.isErr };
      }'string' === typeof e && (e = JSON.parse(e)), 'function' === typeof (null === (i = null == t ? void 0 : t.ret) || void 0 === i ? void 0 : i.join) && (v = [].concat(t.ret.map(e => e.toLowerCase())));let r; const s = Object.getOwnPropertyNames(e).filter(e => -1 !== v.indexOf(e.toLowerCase()));return s.length ? { code: `${r = Number(e[s[0]])}`, isErr: 0 !== r } : { code: 'unknown', isErr: !1 };
    } catch (e) {
      return { code: 'unknown', isErr: !1 };
    }
  } function f(r, s) {
    void 0 === s && (s = 3);let o; let a; let l; let u = '';return Array.isArray(r) ? (u += '[', o = r.length, r.forEach((e, t) => {
      let n; let i;u += 'object' === typeof e && 1 < s ? f(e, s - 1) : (i = '', i += 'undefined' == (e = typeof (n = e)) || 'symbol' == e || 'function' == e ? 'null' : 'string' == e || 'object' == e ? `"${n}"` : n), u += t === o - 1 ? '' : ',';
    }), u += ']') : r instanceof Object ? (u = '{', a = Object.keys(r), l = a.length, a.forEach((e, t) => {
      let n; let i; let o;'object' === typeof r[e] && 1 < s ? u += `"${e}":${f(r[e], s - 1)}` : u += (i = r[n = e], o = '', 'string' == (e = typeof i) || 'object' == e ? o += `"${n}":"${i}"` : 'function' === typeof i ? o += `"${n}":"function ${i.name}"` : 'symbol' === typeof i ? o += `"${n}":"symbol"` : 'number' !== typeof i && 'boolean' != e || (o += `"${n}": ${i}`), o), u += t === l - 1 || t < l - 1 && void 0 === r[a[t + 1]] ? '' : ',';
    }), u += '}') : u += r, u;
  } let g; let p; let d; let m; let y; var v = ['ret', 'retcode', 'code', 'errcode']; const b = function (e) {
    if ('string' === typeof e) return e;try {
      return (JSON.stringify(e, (i = [], o = [], function (e, t) {
        if (t instanceof Error) return `Error.message: ${t.message} \n  Error.stack: ${t.stack}`;if ('object' === typeof t && null !== t) {
          const n = i.indexOf(t);if (-1 !== n) return `[Circular ${o[n]}]`;i.push(t), o.push(e || 'root');
        } return t;
      }), 4) || 'undefined').replace(/"/gim, '');
    } catch (e) {
      return `error happen when aegis stringify: \n ${e.message} \n ${e.stack}`;
    } let i; let o;
  };(V = g = g || {}).INFO_ALL = '-1', V.API_RESPONSE = '1', V.INFO = '2', V.ERROR = '4', V.PROMISE_ERROR = '8', V.AJAX_ERROR = '16', V.SCRIPT_ERROR = '32', V.IMAGE_ERROR = '64', V.CSS_ERROR = '128', V.CONSOLE_ERROR = '256', V.MEDIA_ERROR = '512', V.RET_ERROR = '1024', V.REPORT = '2048', V.PV = '4096', V.EVENT = '8192', (W = p = p || {})[W.android = 1] = 'android', W[W.ios = 2] = 'ios', W[W.windows = 3] = 'windows', W[W.macos = 4] = 'macos', W[W.linux = 5] = 'linux', W[W.devtools = 6] = 'devtools', W[W.other = 100] = 'other', (G = d = d || {})[G.unknown = 100] = 'unknown', G[G.wifi = 1] = 'wifi', G[G.net2g = 2] = 'net2g', G[G.net3g = 3] = 'net3g', G[G.net4g = 4] = 'net4g', G[G.net5g = 5] = 'net5g', G[G.net6g = 6] = 'net6g', ($ = m = m || {}).LOG = 'log', $.SPEED = 'speed', $.PERFORMANCE = 'performance', $.OFFLINE = 'offline', $.WHITE_LIST = 'whiteList', $.VITALS = 'vitals', $.PV = 'pv', $.CUSTOM_PV = 'customPV', $.EVENT = 'event', $.CUSTOM = 'custom', $.SDK_ERROR = 'sdkError', (ee = y = y || {}).production = 'production', ee.gray = 'gray', ee.pre = 'pre', ee.daily = 'daily', ee.local = 'local', ee.others = 'others';function w(e, n) {
    let i; let o = []; const r = e.config;return e.lifeCycle.on('destroy', () => {
      o.length = 0;
    }), function (e, t) {
      if (o.push(e), n && o.length >= n) return o = A(o), t(o.splice(0, o.length)), void (i && clearTimeout(i));i && clearTimeout(i), i = setTimeout(() => {
        i = null, 0 < (o = A(o)).length && t(o.splice(0, o.length));
      }, r.delay);
    };
  } function O(e, t) {
    return Array.isArray(e) ? t(e.map(e => a(a({}, e), { msg: 'string' === typeof e.msg ? e.msg : [].concat(e.msg).map(b)
      .join(' ') }))) : t(a(a({}, e), { msg: 'string' === typeof e.msg ? e.msg : b(e.msg) }));
  } function R(r, s) {
    return function (e, t) {
      const n = Array.isArray(e); let i = n ? e : [e];r.lifeCycle.emit('beforeRequest', e);const o = r.config.beforeRequest;(i = 'function' === typeof o ? i.map((t) => {
        try {
          const e = o({ logs: t, logType: s });return (null == e ? void 0 : e.logType) === s && null != e && e.logs ? e.logs : !1 !== e && t;
        } catch (e) {
          return t;
        }
      }).filter(e => !1 !== e) : i).length && (i = (function (e, t) {
        if (!Array.isArray(e) || e.length <= 1) return e;const n = []; let i = [];return !(i = 'string' === typeof t ? [t] : t) || i.length <= 0 || (i.forEach((t) => {
          e.forEach((e) => {
            null != e && e[t] && n.push(t);
          });
        }), 0 < n.length && (e = e.map((e) => {
          const t = {};return n.forEach((e) => {
            t[e] = '';
          }), a(a({}, t), e);
        }))), e;
      }(i, ['ext1', 'ext2', 'ext3'])), t(n ? i : i[0]));
    };
  } function P(o) {
    return function (e, t) {
      o.lifeCycle.emit('modifyRequest', e);const n = o.config.modifyRequest;if ('function' === typeof n) try {
        const i = n(e);'object' === typeof i && 'url' in i && (e = i);
      } catch (e) {
        console.error(e);
      }t(e);
    };
  } function E(i) {
    return function (e, t) {
      i.lifeCycle.emit('afterRequest', e);const n = i.config.afterRequest;'function' === typeof n && !1 === n(e) || t(e);
    };
  } function S(n) {
    if (!n || !n.reduce || !n.length) throw new TypeError('createPipeline need at least one function param');return 1 === n.length ? function (e, t) {
      n[0](e, t || q);
    } : n.reduce((n, i) => function (e, t) {
      return void 0 === t && (t = q), n(e, e => (null == i ? void 0 : i(e, t)));
    });
  } function x(t, n) {
    Object.getOwnPropertyNames(t).forEach((e) => {
      'function' === typeof t[e] && 'constructor' !== e && (n ? n[e] = 'sendPipeline' === e ? function () {
        return function () {};
      } : function () {} : t[e] = function () {});
    });
  } function T() {
    try {
      const e = getCurrentPages();return (e[e.length - 1] || {}).route || '';
    } catch (e) {
      return '';
    }
  } function L(e) {
    return (function (e, t) {
      if ('string' === typeof e) {
        if (e === t) return 1;for (let n = e.split('.'), i = t.split('.'), o = Math.max(n.length, i.length), r = 0;r < o;r++) {
          const s = ~~n[r]; const a = ~~i[r];if (s < a) return;if (a < s) return 1;
        }
      }
    }(H.getSystemInfoSync().SDKVersion, '1.1.1')) && H.canIUse ? H.canIUse(e) : !!H[e];
  } function C(e) {
    for (var t, n = { unknown: /unknown|none/i, wifi: /wifi/i, net2g: /2g/i, net3g: /3g/i, net4g: /4g/i, net5g: /5g/i, net6g: /6g/i }, i = d.unknown, o = 0;o < Object.keys(n).length;o++) {
      const r = Object.keys(n)[o];if (null !== (t = n[r]) && void 0 !== t && t.test(e)) {
        i = d[r];break;
      }
    } return i;
  } function k(e) {
    return r ? r.addCallback(e) : r = new X(e), r;
  } let r; let N; let U; let j; var A = function (e) {
    return e.filter((n, i) => 'static' !== n.type || !e.find((e, t) => i !== t && n.url === e.url && 200 === n.status));
  }; const I = function (e) {
    e.level === g.INFO_ALL && (e.level = g.INFO);
  }; const _ = function (i) {
    return function (e) {
      return i.sendPipeline([function (e, n) {
        return n({ url: i.config.url || '', data: t(e), method: 'post', contentType: 'application/x-www-form-urlencoded', type: m.LOG, log: e, success() {
          const t = i.config.onReport;'function' === typeof t && e.forEach((e) => {
            t(e);
          }), 'function' === typeof n && n([]);
        }, fail(e) {
          '403 forbidden' === e && i.destroy();
        } });
      }], m.LOG)(e);
    };
  }; var q = function () {}; var F = (Object.defineProperty(ae.prototype, '__version__', { get() {
    return console.warn('__version__ has discard, please use version'), '1.34.75';
  }, enumerable: !1, configurable: !0 }), Object.defineProperty(ae.prototype, 'LogType', { get() {
    return console.warn('LogType has discard, please use logType'), g;
  }, enumerable: !1, configurable: !0 }), ae.prototype.init = function (e) {
    this.setConfig(e);for (let t = 0;t < ae.installedPlugins.length;t++) try {
      ae.installedPlugins[t].patch(this);
    } catch (e) {
      this.sendSDKError(e);
    } this.lifeCycle.emit('onInited');
  }, ae.prototype.setConfig = function (e) {
    Object.assign(this.config, e);var t = this.config; const n = t.id; const i = t.uin; const o = t.version; const r = t.ext1; const s = t.ext2; const a = t.ext3; var e = t.aid; var t = t.env; const l = void 0 === t ? 'production' : t; var t = this.bean.id !== n || this.bean.uin !== i || this.bean.aid !== e;return this.bean.id = n || '', this.bean.uin = i || '', this.bean.version = o || '1.34.75', this.bean.aid = e || '', this.bean.env = (function () {
      switch (l) {
        case y.production:case y.gray:case y.pre:case y.daily:case y.local:case y.others:return 1;default:return;
      }
    }()) ? l : y.others, r && (this.bean.ext1 = encodeURIComponent(r)), s && (this.bean.ext2 = encodeURIComponent(s)), a && (this.bean.ext3 = encodeURIComponent(a)), t && this.lifeCycle.emit('onConfigChange', this.config), this.config;
  }, ae.use = function (e) {
    -1 === ae.installedPlugins.indexOf(e) && e.aegisPlugin && ae.installedPlugins.push(e);
  }, ae.unuse = function (e) {
    e = ae.installedPlugins.indexOf(e);-1 !== e && ae.installedPlugins.splice(e, 1);
  }, ae.prototype.info = function () {
    for (var e = [], t = 0;t < arguments.length;t++)e[t] = arguments[t];const n = { level: g.INFO, msg: e };1 === e.length && e[0].msg && Object.assign(n, a({}, e[0]), { level: g.INFO }), this.normalLogPipeline(n);
  }, ae.prototype.infoAll = function () {
    for (var e = [], t = 0;t < arguments.length;t++)e[t] = arguments[t];const n = { level: g.INFO_ALL, msg: e };1 === e.length && e[0].msg && Object.assign(n, a({}, e[0]), { level: g.INFO_ALL }), this.normalLogPipeline(n);
  }, ae.prototype.report = function () {
    for (var e = [], t = 0;t < arguments.length;t++)e[t] = arguments[t];const n = { level: g.REPORT, msg: e };1 === e.length && e[0].msg && Object.assign(n, a({}, e[0])), this.normalLogPipeline(n);
  }, ae.prototype.error = function () {
    for (var e = [], t = 0;t < arguments.length;t++)e[t] = arguments[t];const n = { level: g.ERROR, msg: e };1 === e.length && e[0].msg && Object.assign(n, a({}, e[0]), { level: g.ERROR }), this.normalLogPipeline(n);
  }, ae.prototype.speedLogPipeline = function (e) {
    throw new Error('You need to override "speedLogPipeline" method');
  }, ae.prototype.reportPv = function (n) {
    let i; const o = this;n && (console.warn('reportPv is deprecated, please use reportEvent'), i = `${Object.getOwnPropertyNames(this.bean).filter(e => 'id' !== e)
      .map(e => `${e}=${o.bean[e]}`)
      .join('&')}`, this.sendPipeline([function (e, t) {
      t({ url: `${o.config.url}/${n}?${i}`, addBean: !1, type: m.CUSTOM_PV, fail(e) {
        '403 forbidden' === e && o.destroy();
      } });
    }], m.CUSTOM_PV)(null));
  }, ae.prototype.reportEvent = function (e) {
    e && ((e = 'string' === typeof e ? { name: e, ext1: this.config.ext1 || '', ext2: this.config.ext2 || '', ext3: this.config.ext3 || '' } : e).name ? this.eventPipeline(e) : console.warn('reportEvent params error'));
  }, ae.prototype.reportTime = function (e, t) {
    if ('object' === typeof e) return this.reportT(e);'string' === typeof e ? 'number' === typeof t ? t < 0 || 6e4 < t ? console.warn('reportTime: duration must between 0 and 60000') : this.submitCustomTime(e, t) : console.warn('reportTime: second param must be number') : console.warn('reportTime: first param must be a string');
  }, ae.prototype.reportT = function (e) {
    const t = e.name; const n = e.duration; var i = e.ext1; const o = void 0 === i ? '' : i; var r = e.ext2; var i = void 0 === r ? '' : r; var r = e.ext3; var r = void 0 === r ? '' : r; var e = e.from;if ('string' === typeof t && 'number' === typeof n && 'string' === typeof o && 'string' === typeof i && 'string' === typeof r) {
      if (!(n < 0 || 6e4 < n)) return this.submitCustomTime(t, n, o, i, r, void 0 === e ? '' : e);console.warn('reportTime: duration must between 0 and 60000');
    } else console.warn('reportTime: params error');
  }, ae.prototype.time = function (e) {
    'string' === typeof e ? this.timeMap[e] ? console.warn(`Timer ${e} already exists`) : this.timeMap[e] = Date.now() : console.warn('time: first param must be a string');
  }, ae.prototype.timeEnd = function (e) {
    'string' === typeof e ? this.timeMap[e] ? (this.submitCustomTime(e, Date.now() - this.timeMap[e]), delete this.timeMap[e]) : console.warn(`Timer ${e} does not exist`) : console.warn('timeEnd: first param must be a string');
  }, ae.prototype.submitCustomTime = function (e, t, n, i, o, r) {
    this.customTimePipeline({ name: e, duration: t, ext1: n || this.config.ext1, ext2: i || this.config.ext2, ext3: o || this.config.ext3, from: r || void 0 });
  }, ae.prototype.extendBean = function (e, t) {
    this.bean[e] = t;
  }, ae.prototype.sendPipeline = function (e, t) {
    let n; const r = this;return S(s([function (e, t) {
      if ('number' !== typeof n.config.random && (console.warn('random must in [0, 1], default is 1.'), n.config.random = 1), !n.isHidden || !n.isGetSample) if (n.isGetSample)n.isHidden || t(e);else {
        if (n.isGetSample = !0, Math.random() < n.config.random) return n.isHidden = !1, t(e);n.isHidden = !0;
      }
    }, R(n = this, t)], e, [P(this), function (i, o) {
      r.request(i, function () {
        for (var e, t = [], n = 0;n < arguments.length;n++)t[n] = arguments[n];o({ isErr: !1, result: t, logType: null == i ? void 0 : i.type, logs: null == i ? void 0 : i.log }), null === (e = null == i ? void 0 : i.success) || void 0 === e || e.call.apply(e, s([i], t));
      }, function () {
        for (var e, t = [], n = 0;n < arguments.length;n++)t[n] = arguments[n];o({ isErr: !0, result: t, logType: null == i ? void 0 : i.type, logs: null == i ? void 0 : i.log }), null === (e = null == i ? void 0 : i.fail) || void 0 === e || e.call.apply(e, s([i], t));
      });
    }, E(this)]));
  }, ae.prototype.send = function (e, o, r) {
    const t = this;return S([P(this), function (n, i) {
      t.request(n, function () {
        for (var e = [], t = 0;t < arguments.length;t++)e[t] = arguments[t];i({ isErr: !1, result: e, logType: n.type, logs: n.log }), null == o || o.apply(void 0, e);
      }, function () {
        for (var e = [], t = 0;t < arguments.length;t++)e[t] = arguments[t];i({ isErr: !0, result: e, logType: n.type, logs: n.log }), null == r || r.apply(void 0, e);
      });
    }, E(this)])(e);
  }, ae.prototype.request = function (e, t, n) {
    throw new Error('You need to override "request" method');
  }, ae.prototype.sendSDKError = function (e) {
    const n = this;this.sendPipeline([function (e, t) {
      t({ url: `${n.config.url}?id=1085&msg[0]=${encodeURIComponent(b(e))}&level[0]=2&from=${n.config.id}&count=1&version=${n.config.id}(1.34.75)`, addBean: !1, method: 'get', type: m.SDK_ERROR, log: e });
    }], m.SDK_ERROR)(e);
  }, ae.prototype.destroy = function (e) {
    void 0 === e && (e = !1);let t; let n; const i = ae.instances.indexOf(this);-1 !== i && ae.instances.splice(i, 1);for (let o = ae.installedPlugins.length - 1;0 <= o;o--) try {
      ae.installedPlugins[o].unpatch(this);
    } catch (e) {
      this.sendSDKError(e);
    } if (this.lifeCycle.emit('destroy'), this.lifeCycle.clear(), e)t = this, n = Object.getOwnPropertyDescriptors(t), Object.keys(n).forEach((e) => {
      n[e].writable && (t[e] = null);
    }), Object.setPrototypeOf(this, null);else {
      for (let r = this;r.constructor !== Object && x(r, this), r = Object.getPrototypeOf(r););0 === ae.instances.length && (e = Object.getPrototypeOf(this).constructor, x(e), x(ae));
    }
  }, ae.version = '1.34.75', ae.instances = [], ae.logType = g, ae.environment = y, ae.installedPlugins = [], ae); var D = (se.prototype.patch = function (e) {
    this.canUse(e) && this.exist(e) && (this.instances.push(e), this.triggerInit(e), this.triggerOnNewAegis(e));
  }, se.prototype.unpatch = function (e) {
    e = this.instances.indexOf(e);-1 !== e && this.instances.splice(e, 1);
  }, se.prototype.countInstance = function () {
    return this.instances.length;
  }, se.prototype.uninstall = function () {
    let e;null === (e = null === (e = this.option) || void 0 === e ? void 0 : e.destroy) || void 0 === e || e.apply(this);
  }, se.prototype.walk = function (n) {
    const i = this;this.instances.forEach((e) => {
      const t = i.canUse(e);t && n(e, t);
    });
  }, se.prototype.canUse = function (e) {
    e = this.getConfig(e);return !(!e || 'object' !== typeof e) || !!e;
  }, se.prototype.getConfig = function (e) {
    return null === (e = e.config) || void 0 === e ? void 0 : e[this.name];
  }, se.prototype.exist = function (e) {
    return -1 === this.instances.indexOf(e);
  }, se.prototype.triggerInit = function (e) {
    let t;this.inited || (this.inited = !0, null === (t = null === (t = this.option) || void 0 === t ? void 0 : t.init) || void 0 === t || t.call(this.option, this.getConfig(e)));
  }, se.prototype.triggerOnNewAegis = function (e) {
    let t;null === (t = null === (t = this.option) || void 0 === t ? void 0 : t.onNewAegis) || void 0 === t || t.call(this.option, e, this.getConfig(e));
  }, se); var H = wx || qq; const M = new D({ name: 'offlineLog', onNewAegis(o) {
    if (H.getFileSystemManager) try {
      const e = o.config; const t = e.id; const r = void 0 === t ? '' : t; const n = e.uin; const s = void 0 === n ? 0 : n; const i = e.offlineUrl; const a = void 0 === i ? '' : i; const l = e.offlineLogLimit; const u = new B({ limit: l });o.lifeCycle.on('beforeWrite', (e) => {
        u.save2Offline(e = void 0 === e ? [] : e, o.config);
      }), u.ready((t) => {
        const e = (o.bean || {}).aid; const i = void 0 === e ? '' : e;!t && r && (s || i) && o.send({ url: `${a}/offlineAuto`, type: m.OFFLINE, log: m.OFFLINE }, (e) => {
          const n = (null == e ? void 0 : e.data).secretKey;n && (t || u.getLogs({ id: r, uin: s }, (e, t) => {
            e ? console.error(e) : o.send({ url: `${a}/offlineLog`, data: { logs: t, secretKey: n, id: r, uin: s, aid: i }, method: 'post', type: m.OFFLINE, log: t }, () => {
              u.clearLogs();
            });
          }));
        });
      });
    } catch (o) {
      console.error(o);
    } else console.warn('[aegis-mp-sdk]unsupport getFileSystemManager offline log not work!');
  } }); var B = (re.prototype.getLogs = function (e, t) {
    const n = this.fileSystem; const i = this.filePath;n.readFile({ filePath: i, encoding: 'utf8', fail(e) {
      console.error(e);
    }, success(e) {
      e = e.data, e = (void 0 === e ? '' : e).toString().split('\n')
        .filter(e => e)
        .map(e => JSON.parse(e));t(null, e);
    } });
  }, re.prototype.checkLimit = function (o, r) {
    void 0 === r && (r = function () {});const s = this.fileSystem; const a = this.filePath; const l = this.limitSize;s.readFile({ filePath: a, encoding: 'utf8', success(e) {
      e = e.data, e = void 0 === e ? '' : e;if ((e = e.toString() + o).length > l) {
        for (var t = e.split('\n'), n = '', i = t.length - 1;0 <= i && !(t[i] && (n = `${t[i]}\n${n}`).length > l);i--);s.writeFile({ filePath: a, data: n, success: r });
      } else s.appendFile({ data: o, filePath: a, encoding: 'utf8', success: r, fail(e) {
        console.error(e);
      } });
    } });
  }, re); var V = new D({ name: 'device', onNewAegis(l) {
    return e = this, u = function () {
      return n = this, i = function (e) {
        return this.setSystemInfo(l), this.refreshNetwork(l), this.setNetworkChange(l), [2];
      }, a = { label: 0, sent() {
        if (1 & s[0]) throw s[1];return s[1];
      }, trys: [], ops: [] }, t = { next: e(0), throw: e(1), return: e(2) }, 'function' === typeof Symbol && (t[Symbol.iterator] = function () {
        return this;
      }), t;function e(t) {
        return function (e) {
          return (function (t) {
            if (o) throw new TypeError('Generator is already executing.');for (;a;) try {
              if (o = 1, r && (s = 2 & t[0] ? r.return : t[0] ? r.throw || ((s = r.return) && s.call(r), 0) : r.next) && !(s = s.call(r, t[1])).done) return s;switch (r = 0, (t = s ? [2 & t[0], s.value] : t)[0]) {
                case 0:case 1:s = t;break;case 4:return a.label++, { value: t[1], done: !1 };case 5:a.label++, r = t[1], t = [0];continue;case 7:t = a.ops.pop(), a.trys.pop();continue;default:if (!((s = 0 < (s = a.trys).length && s[s.length - 1]) || 6 !== t[0] && 2 !== t[0])) {
                  a = 0;continue;
                } if (3 === t[0] && (!s || t[1] > s[0] && t[1] < s[3])) {
                    a.label = t[1];break;
                  } if (6 === t[0] && a.label < s[1]) {
                    a.label = s[1], s = t;break;
                  } if (s && a.label < s[2]) {
                    a.label = s[2], a.ops.push(t);break;
                  }s[2] && a.ops.pop(), a.trys.pop();continue;
              }t = i.call(n, a);
            } catch (e) {
              t = [6, e], r = 0;
            } finally {
              o = s = 0;
            } if (5 & t[0]) throw t[1];return { value: t[0] ? t[1] : void 0, done: !0 };
          }([t, e]));
        };
      } let n; let i; let o; let r; let s; let a; let t;
    }, new (a = (a = s = void 0) || Promise)((n, t) => {
      function i(e) {
        try {
          r(u.next(e));
        } catch (e) {
          t(e);
        }
      } function o(e) {
        try {
          r(u.throw(e));
        } catch (e) {
          t(e);
        }
      } function r(e) {
        let t;e.done ? n(e.value) : ((t = e.value) instanceof a ? t : new a((e) => {
          e(t);
        })).then(i, o);
      }r((u = u.apply(e, s || [])).next());
    });let e; let s; let a; let u;
  }, setSystemInfo(s) {
    const a = this;try {
      L('getSystemInfo') && H.getSystemInfo({ success(e) {
        const t = e.platform; const n = e.model; const i = e.windowHeight; const o = e.windowWidth; const r = e.screenWidth; var e = e.screenHeight;s.extendBean('platform', a.getPlatFormType(t)), s.extendBean('model', n), s.extendBean('vp', `${o} * ${i}`), s.extendBean('sr', `${r} * ${e}`);
      } });
    } catch (s) {}
  }, getPlatFormType(e) {
    for (var t, n = { android: /android/i, ios: /ios/i, windows: /windows/i, macos: /mac/i, devtools: /devtools/i }, i = p.other, o = 0;o < Object.keys(n).length;o++) {
      const r = Object.keys(n)[o];if (null !== (t = n[r]) && void 0 !== t && t.test(e)) {
        i = p[r];break;
      }
    } return i;
  }, setNetworkChange(t) {
    L('onNetworkStatusChange') && H.onNetworkStatusChange((e) => {
      e = C(e.networkType);t.extendBean('netType', e);
    });
  }, setNetworkType(t) {
    L('getNetworkType') && H.getNetworkType({ success(e) {
      e = C(e.networkType);t.extendBean('netType', e);
    } });
  }, refreshNetwork(e) {
    const t = this;this.timer && clearTimeout(this.timer), this.setNetworkType(e), this.timer = setTimeout(() => {
      t.refreshNetwork(e);
    }, 1e4);
  } }); const J = H.request; var W = (e(oe, j = F), Object.defineProperty(oe.prototype, 'getBean', { get() {
    const t = this;return this.bean ? `${Object.getOwnPropertyNames(this.bean).map(e => `${e}=${t.bean[e]}`)
      .join('&')}&from=${encodeURIComponent(T())}` : `from=${encodeURIComponent(T())}`;
  }, enumerable: !1, configurable: !0 }), oe.prototype.initOfflineLog = function () {
    oe.use(M);
  }, oe.prototype.uploadLogs = function (e, t) {
    this.lifeCycle.emit('uploadLogs', e = void 0 === e ? {} : e, t = void 0 === t ? {} : t);
  }, oe.prototype.reportPv = function (e) {
    let t; const n = this;e && (t = `${Object.getOwnPropertyNames(this.bean).filter(e => 'id' !== e)
      .map(e => `${e}=${n.bean[e]}`)
      .join('&')}&from=${encodeURIComponent(T())}`, this.send({ url: `${this.config.url}/${e}?${t}`, addBean: !1, type: m.CUSTOM_PV, log: m.CUSTOM_PV }, () => {}, () => {}));
  }, oe.sessionID = `session-${Date.now()}`, oe.asyncPluginIndex = 0, oe); var G = new D({ name: 'aid', onNewAegis(t) {
    this.initAid((e) => {
      t.bean.aid = e, t.config.aid = e;
    });
  }, initAid(t) {
    H.getStorage({ key: 'AEGIS_ID', success(e) {
      t(e.data);
    }, fail() {
      const e = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (e) => {
        const t = 16 * Math.random() | 0;return ('x' === e ? t : 3 & t | 8).toString(16);
      });H.setStorage({ key: 'AEGIS_ID', data: e, success() {
        t(e);
      } });
    } });
  } }); var $ = (ie.prototype.addCallback = function (e) {
    e && this.callbacks.push(e);
  }, ie.prototype.prefixHandler = function (e) {
    e.aegisRequestStartTime = Date.now();
  }, ie.prototype.successHandler = function (n, i) {
    let e;this.callbacks.forEach((e) => {
      let t;try {
        null === (t = e.success) || void 0 === t || t.call(e, n, i);
      } catch (e) {}
    }), null === (e = i.success) || void 0 === e || e.call(i, n, i);
  }, ie.prototype.failHandler = function (n, i) {
    let e;this.callbacks.forEach((e) => {
      let t;try {
        null === (t = e.fail) || void 0 === t || t.call(e, n, i);
      } catch (e) {}
    }), null === (e = i.fail) || void 0 === e || e.call(i, n, i);
  }, ie.prototype.completeHandler = function (n, i) {
    let e;this.callbacks.forEach((e) => {
      let t;try {
        null === (t = e.complete) || void 0 === t || t.call(e, n, i);
      } catch (e) {}
    }), null === (e = i.complete) || void 0 === e || e.call(i, n, i);
  }, ie.prototype.override = function () {
    try {
      this.defineApiProperty();
    } catch (e) {
      console.warn(`cannot override \`${this.apiName}\`, error is: ${e}`);
    } finally {
      this.isOverride = !0;
    }
  }, ie); const K = wx || qq; const Q = K.request; var X = (e(ne, U = $), ne.prototype.defineApiProperty = function () {
    const e = this;Object.defineProperty(K, 'request', { get() {
      return e.hackHandler.bind(e);
    } });
  }, ne.prototype.hackHandler = function (i) {
    const o = this;return this.prefixHandler(i), new Promise((t, n) => {
      Q(a(a({}, i), { success(e) {
        o.successHandler(e, i), t(e);
      }, fail(e) {
        o.failHandler(e, i), n(e);
      }, complete(e) {
        o.completeHandler(e, i);
      } }));
    });
  }, ne); const z = wx || qq; const Y = null === (ee = z.cloud) || void 0 === ee ? void 0 : ee.callFunction; const Z = (e(te, N = $), te.prototype.defineApiProperty = function () {
    const e = this;z.cloud && z.cloud.callFunction && Object.defineProperty(z.cloud, 'callFunction', { get() {
      return e.hackHandler.bind(e);
    } });
  }, te.prototype.hackHandler = function (i) {
    const o = this;return this.prefixHandler(i), new Promise((t, n) => {
      Y(a(a({}, i), { success(e) {
        o.successHandler(e, i), t(e);
      }, fail(e) {
        o.failHandler(e, i), n(e);
      }, complete(e) {
        o.completeHandler(e, i);
      } }));
    });
  }, te); var F = new D({ name: 'reportApiSpeed', override: !1, onNewAegis(e) {
    this.override || (this.override = !0, this.hackRequest(e.config), this.overrideCallFunction(e.config));
  }, hackRequest(o) {
    const r = this;k({ success(e, t) {
      const n = { method: t.method || 'get', url: l(t.url), duration: Date.now() - t.aegisRequestStartTime, status: e.statusCode || 0, isHttps: u(t.url), type: 'fetch' }; var i = null === (i = o.api) || void 0 === i ? void 0 : i.apiDetail; var i = `req url: ${n.url} \n                        \nreq method: ${n.method} \n                        \nreq param: ${i ? b(t.data) : ''} \n                        \nres duration: ${n.duration} \n                        \nres status: ${e.statusCode || 0} \n                        \nres data: ${i ? f(e.data) : ''}`;r.publishNormalLog({ msg: i, level: g.API_RESPONSE });t = c(e.data, o.api, { url: t.url, ctx: e }) || {}, e = t.code, t = t.isErr;n.ret = e, n.isErr = +t, r.publishSpeedLog(n), t && r.publishNormalLog({ msg: i, level: g.RET_ERROR });
    }, fail(e, t) {
      t = { method: t.method || 'get', url: l(t.url), duration: Date.now() - t.aegisRequestStartTime, status: 0, isHttps: u(t.url), type: 'fetch' };r.publishSpeedLog(t);
    } });
  }, overrideCallFunction(l) {
    const u = this;new Z({ success(e, t) {
      const n = { method: 'call', url: `wx.cloud.callFunction.${t.name}`, duration: Date.now() - t.aegisRequestStartTime, status: 200, type: 'fetch', errMsg: e.errMsg, isHttps: !0 }; let i = null === (a = l.api) || void 0 === a ? void 0 : a.apiDetail; const o = `req url: ${n.url}\n                        \nreq type: ${n.type}\n                        \nres duration: ${n.duration}\n                        \nres errMsg: ${n.errMsg}\n                        \nres data: ${i ? f(e.result) : ''}\n                        `;u.publishNormalLog({ msg: o, level: g.API_RESPONSE });let r; let s; var a = !1; var a = (s = 'function' === typeof (null === (i = l.api) || void 0 === i ? void 0 : i.retCodeCloudFunctionHandler) ? (r = (t = l.api.retCodeCloudFunctionHandler(e.result, t.name, t, e) || {}).code, void 0 !== (t = t.isErr) && t) : (r = (s = c(e.result, l.api, { url: n.url, ctx: e }) || {}).code, s.isErr), n.ret = r, s);n.isErr = +a, u.publishSpeedLog(n), a && u.publishNormalLog({ msg: o, level: g.RET_ERROR });
    }, fail(e, t) {
      e = { method: 'call', url: `wx.cloud.callFunction.${t.name}`, duration: Date.now() - t.aegisRequestStartTime, status: 0, type: 'fetch', errMsg: e.errMsg, isHttps: !0 };u.publishSpeedLog(e);
    } });
  }, publishSpeedLog(t) {
    this.$walk((e) => {
      e.speedLogPipeline(t);
    });
  }, publishNormalLog(t) {
    this.$walk((e) => {
      e.normalLogPipeline(t);
    });
  } }); var ee = new D({ name: 'onError', onNewAegis(e) {
    e = e.config;this.listenError(), this.hackRequest(e);
  }, listenError() {
    const t = this;H.onError((e) => {
      e && t.publishErrorLog({ msg: e, level: g.ERROR });
    }), L('onUnhandledRejection') && H.onUnhandledRejection((e) => {
      e = e.reason;e && t.publishErrorLog({ msg: e, level: g.PROMISE_ERROR });
    });
  }, publishErrorLog(t) {
    this.$walk((e) => {
      e.normalLogPipeline(t);
    });
  }, hackRequest(s) {
    const a = this;k({ complete(e, t) {
      let n; const i = e.errMsg; const o = e.statusCode; const r = e.data; var e = null === (e = s.api) || void 0 === e ? void 0 : e.apiDetail;s.hostUrl && -1 < (null === (n = t.url) || void 0 === n ? void 0 : n.indexOf(s.hostUrl)) || (n = '', -1 < i.indexOf('timeout') ? n = 'timeout' : -1 < i.indexOf('fail') || !o || o < 0 ? n = 'failed' : 400 <= o && (n = 'error'), n && a.publishErrorLog({ msg: `AJAX_ERROR: request ${n}\n                  \nres status: ${o || 0}\n                  \nres duration: ${Date.now() - t.aegisRequestStartTime}\n                  \nres data: ${e ? b(r) : ''}\n                  \nreq url: ${t.url}\n                  \nreq method: ${t.method || 'get'}\n                  \nreq param: ${e ? b(t.data) : ''}\n                  \nerrMsg: ${i.slice(0, 1e3)}`, level: g.AJAX_ERROR }));
    } });
  } }); var $ = new D({ name: 'reportAssetSpeed', isStart: !1, onNewAegis(e) {
    this.isStart || (this.isStart = !0, this.start(e));
  }, start() {
    const t = this;H.getPerformance && H.getPerformance().createObserver((e) => {
      e.getEntries().forEach((e) => {
        !e.duration || e.duration <= 0 || 'script' === e.entryType && t.publishAssetLog(e);
      });
    })
      .observe({ entryTypes: ['script'] });
  }, generateLog(e) {
    return { url: `${l(e.path || e.moduleName)}js`, method: 'get', duration: Number(e.duration.toFixed(2)), status: 200, type: 'static', isHttps: !0, urlQuery: '', domainLookup: 0, connectTime: 0 };
  }, publishAssetLog(t) {
    const n = this;this.$walk((e) => {
      e.speedLogPipeline(n.generateLog(t));
    });
  } }); var D = new D({ name: 'pagePerformance', onNewAegis(e) {
    try {
      L('getPerformance') && this.reportPerformance(e), this.setPagePV(e), this.reportSetDataTiming(e);
    } catch (e) {}
  }, reportPerformance(r) {
    const s = this; var e = H.getPerformance(); var e = null == e ? void 0 : e.createObserver((e) => {
      var t = e.getEntries(); const n = {}; const i = t.find(e => 'appLaunch' === e.name && 0 < e.duration); const o = t.find(e => 'firstRender' === e.name && 0 < e.duration); var e = t.find(e => 'evaluateScript' === e.name && 0 < e.duration); var t = t.find(e => 'route' === e.name && 0 < e.duration);i && (n.appLaunch = i.duration), o && (n.firstScreenTiming = o.duration), e && (n.scriptEvaluateTiming = e.duration), t && (n.pageRouteTiming = t.duration), s.publish(n, r);
    });null == e || e.observe({ entryTypes: ['navigation', 'render', 'script'] });
  }, publish(t, n) {
    let e; let i; const o = []; const r = this.$getConfig(n); const s = -1 === (null === (e = n.config.performanceUrl) || void 0 === e ? void 0 : e.indexOf('?')) ? '?' : '&';for (i in t)o.push(`${i}=${t[i]}`);'function' === typeof r.urlHandler ? this.$walk((e) => {
      e.send({ url: `${n.config.performanceUrl + s + o.join('&')}&from=${encodeURIComponent(r.urlHandler()) || window.location.href}`, beanFilter: ['from'], type: m.PERFORMANCE, log: t });
    }) : this.$walk((e) => {
      e.send({ url: n.config.performanceUrl + s + o.join('&'), type: m.PERFORMANCE, log: t });
    });
  }, setPagePV(e) {
    const t = this;H.onAppRoute && H.onAppRoute((e) => {
      'appLaunch' !== e.openType && t.$walk((e) => {
        e.send({ url: `${e.config.pvUrl}`, type: m.PV });
      });
    });
  }, reportSetDataTiming(t) {
    function o(e, t) {
      var n = t.updateStartTimestamp; const i = t.updateEndTimestamp; var t = void 0 === (t = t.dataPaths) ? [] : t; var n = i - n;isNaN(n) || n < l || (n = { from: e.is, duration: n }, a && 0 < t.length && Object.assign(n, { dataPaths: t.slice(0, 30) }), r(n));
    } let e; var r = S([w(t, 5), function (e) {
      e = e.map(e => ({ component: e.from, duration: e.duration, fields: e.dataPaths && e.dataPaths.length ? e.dataPaths.sort().join(';') : void 0 }));t.send({ url: `${t.config.customTimeUrl}?payload=${encodeURIComponent(JSON.stringify({ miniProgramData: e }))}`, type: m.CUSTOM, log: e });
    }]); const i = Page; const s = Component; var n = null === (e = null === (n = t.config) || void 0 === n ? void 0 : n.setDataReportConfig) || void 0 === e ? void 0 : e.timeThreshold; var a = !1 !== (null === (e = null === (e = t.config) || void 0 === e ? void 0 : e.setDataReportConfig) || void 0 === e ? void 0 : e.withDataPaths); var l = Boolean(n && !isNaN(+n) && 5 < n) ? +n : 5;Page = function (e) {
      const n = e.onReady;return e.onReady = function () {
        const t = this;return 'function' === typeof this.setUpdatePerformanceListener && this.setUpdatePerformanceListener({ withDataPaths: a }, (e) => {
          o(t, e);
        }), null == n ? void 0 : n.call(this);
      }, i(e);
    }, Component = function (e) {
      let n; let i;return e.lifetimes && e.lifetimes.attached ? (n = e.lifetimes.attached, e.lifetimes.attached = function () {
        const t = this;return 'function' === typeof this.setUpdatePerformanceListener && this.setUpdatePerformanceListener({ withDataPaths: a }, (e) => {
          o(t, e);
        }), null == n ? void 0 : n.call(this);
      }) : (i = e.attached, e.attached = function () {
        const t = this;return 'function' === typeof this.setUpdatePerformanceListener && this.setUpdatePerformanceListener({ withDataPaths: a }, (e) => {
          o(t, e);
        }), null == i ? void 0 : i.call(this);
      }), s(e);
    };
  } });function te() {
    return null !== N && N.apply(this, arguments) || this;
  } function ne() {
    return null !== U && U.apply(this, arguments) || this;
  } function ie(e) {
    this.callbacks = [], this.isOverride = !1, this.isOverride || this.override(), this.callbacks.push(e);
  } function oe(e) {
    let i; let o; let r; const c = j.call(this, e) || this;c.originRequest = J, c.speedLogPipeline = S([(o = c.config, r = {}, function (e, t) {
      let n; let i;o.speedSample ? (i = 'object' === typeof o.repeat ? o.repeat : { repeat: o.repeat }, n = +i.speed || +i.repeat || 5, Array.isArray(e) ? (i = e.filter((e) => {
        const t = !r[e.url] || r[e.url] < n;return r[e.url] = 1 + ~~r[e.url], t;
      })).length && t(i) : (!r[e.url] || r[e.url] < n) && (r[e.url] = 1 + ~~r[e.url], t(e))) : t(e);
    }), w(c), function (t, n) {
      L('getNetworkType') ? H.getNetworkType({ success(e) {
        e = C(e.networkType);i.extendBean('netType', e), n(t);
      } }) : n(t);
    }, function (e, t) {
      c.lifeCycle.emit('beforeReportSpeed', e);const n = c.config.beforeReportSpeed;if ((e = 'function' === typeof n ? e.filter(e => !1 !== n(e)) : e).length) return t(e);
    }, R(i = c, m.SPEED), function (e) {
      let t; let n; let i; let o;c.send({ url: `${c.config.speedUrl}`, method: 'post', data: (t = e, n = c.bean, i = { fetch: [], static: [] }, o = {}, Array.isArray(t) ? t.forEach((e) => {
        let t;null === (t = i[e.type]) || void 0 === t || t.push(e);
      }) : null === (e = i[t.type]) || void 0 === e || e.push(t), o.payload = JSON.stringify(a({ duration: i }, n)), o) });
    }]), c.requestQueue = [], c.requesting = !1, c.request = function (e, t, n) {
      if (e.url && c.bean.id) if (/^\w{8}-\w{4}-\w{4}-\w{4}-\w{12}$/.test(String(c.bean.aid))) {
        if (!(c.requesting || L('getNetworkType') && void 0 === c.bean.netType)) {
          c.requesting = !0;let i; let o = e.url;c.config.whiteListUrl === o && (i = t, t = function (e) {
            null == i || i(JSON.stringify(e.data));
          }), !1 !== e.addBean && (o = o + (-1 === o.indexOf('?') ? '?' : '&') + c.getBean);const r = e.method || 'get'; const s = function () {
            c.requesting = !1;const e = c.requestQueue.shift();e && c.request(e.options, e.success, e.fail);
          }; let a = e; const l = c.config.onBeforeRequest;if (!(a = l ? l(e, c) : a) || !a.url) {
            var u = '';return a || (u = 'Sending request blocked', console.log(u)), a.url || (u = 'Please handle the parameters reasonably, options.url is necessary', console.warn(u)), null == n || n(u), s(), !1;
          }u = c.config.enableHttp2 || !1;return 'get' === r ? (o = (function (e, n) {
            if ('string' !== typeof e) return '';if ('object' === typeof n && n) {
              const t = Object.getOwnPropertyNames(n).map((e) => {
                const t = n[e];return `${e}=${'string' === typeof t ? encodeURIComponent(t) : encodeURIComponent(JSON.stringify(t))}`;
              })
                .join('&')
                .replace(/eval/gi, 'evaI');return e + (-1 === e.indexOf('?') ? '?' : '&') + t;
            } return e;
          }(o, a.data)), c.originRequest({ url: o, enableHttp2: u, success: t, fail: n, complete: s })) : ('string' === typeof a.data && (a.data = a.data.replace(/eval/gi, 'evaI')), c.originRequest({ url: o, enableHttp2: u, header: a.contentType ? { 'content-type': a.contentType } : void 0, method: 'POST', data: a.data, success: t, fail: n, complete: s })), !0;
        }c.requestQueue.push({ options: e, success: t, fail: n });
      } else c.requestQueue.push({ options: e, success: t, fail: n });
    };try {
      e.offlineLog && c.initOfflineLog(), c.init(e), c.extendBean('sessionId', oe.sessionID), c.extendBean('referer', (L('getLaunchOptionsSync') ? H.getLaunchOptionsSync() : { scene: '' }).scene || '');
    } catch (e) {
      console.warn(e), console.log('%cThe above error occurred in the process of initializing Aegis, which will affect your normal use of Aegis.\nIt is recommended that you contact us for feedback and thank you for your support.', 'color: red'), c.sendSDKError(e);
    } return c;
  } function re(e) {
    let o; let r; const s = this; var t = void 0 === e ? {} : e; var e = t.path; var e = void 0 === e ? '/.aegis.offline.log' : e; var t = t.limit; var t = void 0 === t ? 2e4 : t;this.offlineBuffer = [], this.insertLog = (o = null, r = [], function (e) {
      r = r.concat(e), o = o || setTimeout(() => {
        o = null;let e; const t = s.fileSystem; const n = s.filePath; const i = `${r.map(e => JSON.stringify(e)).join('\n')}\n`;i && (e = function (e) {
          e ? s.checkLimit(i, () => {
            r = [];
          }) : t.writeFile({ data: i, filePath: n, encoding: 'utf8', fail(e) {
            console.error(e);
          }, success() {
            r = [];
          } });
        }, t.access({ path: n, success() {
          e(!0);
        }, fail() {
          e();
        } }));
      }, 2e3);
    }), this.ready = function (e) {
      s.fileSystem ? setTimeout(() => {
        e(null);
      }, 0) : (e(new Error('getFileSystemManager file')), s.offlineLog = !1);
    }, this.clearLogs = function () {
      const e = s.fileSystem; const t = s.filePath;e.writeFile({ filePath: t, data: '', fail() {
        e.unlinkSync(t);
      } });
    }, this.save2Offline = function (e, t) {
      e = (e = !Array.isArray(e) ? [e] : e).map(e => ('string' === typeof e && (e = { msg: e }), (function () {
        for (var e = [], t = 0;t < arguments.length;t++)e[t] = arguments[t];if (0 === e.length) throw new TypeError('Cannot convert undefined or null to object');for (var n = Object(e[0]), i = 1;i < e.length;i++) {
          const o = e[i];if (null !== o) for (const r in o)Object.prototype.hasOwnProperty.call(o, r) && (n[r] = o[r]);
        } return n;
      }({ id: t.id, uin: t.uin, time: +Date.now(), version: t.version, from: T() }, e))));s.fileSystem ? s.insertLog(e) : (s.fileSystem || s.offlineBuffer.length || s.ready((e) => {
        e ? console.error(e) : s.offlineBuffer.length && (s.addLogs(s.offlineBuffer), s.offlineBuffer = []);
      }), s.offlineBuffer = s.offlineBuffer.concat(e));
    }, this.addLogs = function (e) {
      s.fileSystem && s.insertLog(e);
    }, this.filePath = H.env.USER_DATA_PATH + e, this.fileSystem = H.getFileSystemManager(), this.limitSize = t;
  } function se(e) {
    this.aegisPlugin = !0, this.name = '', this.instances = [], this.inited = !1, e.$walk = this.walk.bind(this), e.$getConfig = this.getConfig.bind(this), this.option = e, this.name = e.name;
  } function ae(e) {
    let i; let t; let s; let n; let a; let l; let o; let u; let r; let c; let f; let p; const d = this;this.isGetSample = !1, this.isHidden = !1, this.config = { version: 0, delay: 1e3, onError: !0, repeat: 5, random: 1, aid: !0, device: !0, pagePerformance: !0, webVitals: !0, speedSample: !0, hostUrl: 'https://aegis.qq.com', env: 'production', url: '', offlineUrl: '', whiteListUrl: '', pvUrl: '', speedUrl: '', customTimeUrl: '', performanceUrl: '', webVitalsUrl: '', eventUrl: '' }, this.isWhiteList = !1, this.lifeCycle = new h, this.bean = {}, this.normalLogPipeline = S([w(this, 5), O, (f = this.config, p = {}, function (e, t) {
      const n = 'number' === typeof f.repeat ? f.repeat : 5;if (0 === n) return t(e);t(e.filter(e => e.level !== g.ERROR && e.level !== g.PROMISE_ERROR && e.level !== g.AJAX_ERROR && e.level !== g.SCRIPT_ERROR && e.level !== g.IMAGE_ERROR && e.level !== g.CSS_ERROR && e.level !== g.MEDIA_ERROR || (p[e.msg] = p[e.msg] || 0, p[e.msg] += 1, !(p[e.msg] > n))));
    }), (r = this.lifeCycle.emit, c = this.config, function (e, t) {
      const n = c.logCreated;if ('function' !== typeof n) return r('beforeWrite', e), t(e);e = e.filter(e => !1 !== n(e));return r('beforeWrite', e), t(e);
    }), (i = this, setTimeout(() => {
      const e = i.config.pvUrl; const n = void 0 === e ? '' : e;n && i.sendPipeline([function (e, t) {
        t({ url: n, type: m.PV, fail(e) {
          '403 forbidden' === e && i.destroy();
        } });
      }], m.PV)(null);
    }, 100), function (e, t) {
      t(e);
    }), (o = l = a = !1, u = [], (s = this).lifeCycle.on('onConfigChange', () => {
      n && clearTimeout(n), n = setTimeout(() => {
        let e; let n;!o && s.config && (o = !0, e = s.config.whiteListUrl, (n = void 0 === e ? '' : e) && s.sendPipeline([function (e, t) {
          t({ url: n, type: m.WHITE_LIST, success(e) {
            l = !0;try {
              const t = e.data || JSON.parse(e); const n = t.retcode; const i = t.result; const o = void 0 === i ? {} : i;if (0 === n) {
                if (a = o.is_in_white_list, s.isWhiteList = a, o.shutdown) return void s.destroy();0 <= o.rate && o.rate <= 1 && (s.config.random = o.rate, s.isGetSample = !1);
              }s.isWhiteList && u.length ? _(s)(u.splice(0), () => {}) : !s.isWhiteList && u.length && (u.length = 0);const r = s.config.onWhitelist;'function' === typeof r && r(a);
            } catch (e) {}
          }, fail(e) {
            '403 forbidden' === e && s.destroy(), l = !0;
          } });
        }], m.WHITE_LIST)(null), o = !1);
      }, s.config.uin ? 50 : 500);
    }), s.lifeCycle.on('destroy', () => {
      u.length = 0;
    }), function (e, t) {
      let n;a || null !== (n = null === (n = s.config) || void 0 === n ? void 0 : n.api) && void 0 !== n && n.reportRequst ? t(e.concat(u.splice(0)).map(e => (I(e), e))) : (e = e.filter(e => (e.level !== g.INFO && e.level !== g.API_RESPONSE ? (I(e), !0) : (l || (u.push(e), 200 <= u.length && (u.length = 200)), !1)))).length && t(e);
    }), function (e, t) {
      const n = JSON.parse(JSON.stringify(e));d.lifeCycle.emit('beforeReport', n);const i = d.config.beforeReport;(e = 'function' === typeof i ? e.filter(e => !1 !== i(e)) : e).length && t(e);
    }, _(this)]), this.eventPipeline = S([w(this, 5), function (e) {
      d.sendPipeline([function (e, t) {
        const n = e.map(e => ({ name: e.name, ext1: e.ext1 || d.config.ext1 || '', ext2: e.ext2 || d.config.ext2 || '', ext3: e.ext3 || d.config.ext3 || '' }));t({ url: `${d.config.eventUrl}?payload=${encodeURIComponent(JSON.stringify(n))}`, type: m.EVENT, log: e, fail(e) {
          '403 forbidden' === e && d.destroy();
        } });
      }], m.EVENT)(e);
    }]), this.timeMap = {}, this.customTimePipeline = S([w(this, 5), function (e) {
      return d.sendPipeline([function (e, t) {
        t({ url: `${d.config.customTimeUrl}?payload=${encodeURIComponent(JSON.stringify({ custom: e }))}`, type: m.CUSTOM, log: e, fail(e) {
          '403 forbidden' === e && d.destroy();
        } });
      }], m.CUSTOM)(e);
    }]), this.config = (t = this.config, void 0 === (e = e.hostUrl) && (e = 'https://aegis.qq.com'), t.url = t.url || `${e}/collect`, t.offlineUrl = t.offlineUrl || `${e}/offline`, t.whiteListUrl = t.whiteListUrl || `${e}/collect/whitelist`, t.pvUrl = t.pvUrl || `${e}/collect/pv`, t.eventUrl = t.eventUrl || `${e}/collect/events`, t.speedUrl = t.speedUrl || `${e}/speed`, t.customTimeUrl = t.customTimeUrl || `${e}/speed/custom`, t.performanceUrl = t.performanceUrl || `${e}/speed/performance`, t.webVitalsUrl = t.webVitalsUrl || `${e}/speed/webvitals`, t), ae.instances.push(this);
  } return W.use(ee), W.use(F), W.use(G), W.use($), W.use(D), W.use(V), W;
}));
