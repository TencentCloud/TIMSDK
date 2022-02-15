let global; let factory;global = this, factory = function () {
  function e(t) {
    return (e = 'function' === typeof Symbol && 'symbol' === typeof Symbol.iterator ? function (e) {
      return typeof e
    } : function (e) {
      return e && 'function' === typeof Symbol && e.constructor === Symbol && e !== Symbol.prototype ? 'symbol' : typeof e
    })(t)
  } function t(e, t) {
    if (!(e instanceof t)) throw new TypeError('Cannot call a class as a function')
  } function r(e, t) {
    for (let r = 0;r < t.length;r++) {
      const o = t[r];o.enumerable = o.enumerable || !1, o.configurable = !0, 'value' in o && (o.writable = !0), Object.defineProperty(e, o.key, o)
    }
  } function o(e, t, o) {
    return t && r(e.prototype, t), o && r(e, o), e
  } function n(e, t, r) {
    return t in e ? Object.defineProperty(e, t, { value: r, enumerable: !0, configurable: !0, writable: !0 }) : e[t] = r, e
  } function a(e, t) {
    const r = Object.keys(e);if (Object.getOwnPropertySymbols) {
      let o = Object.getOwnPropertySymbols(e);t && (o = o.filter(((t) => Object.getOwnPropertyDescriptor(e, t).enumerable))), r.push.apply(r, o)
    } return r
  } function s(e) {
    for (let t = 1;t < arguments.length;t++) {
      var r = null != arguments[t] ? arguments[t] : {};t % 2 ? a(Object(r), !0).forEach(((t) => {
        n(e, t, r[t])
      })) : Object.getOwnPropertyDescriptors ? Object.defineProperties(e, Object.getOwnPropertyDescriptors(r)) : a(Object(r)).forEach(((t) => {
        Object.defineProperty(e, t, Object.getOwnPropertyDescriptor(r, t))
      }))
    } return e
  } function i(e, t) {
    if (null == e) return {};let r; let o; const n = (function (e, t) {
      if (null == e) return {};let r; let o; const n = {}; const a = Object.keys(e);for (o = 0;o < a.length;o++)r = a[o], t.indexOf(r) >= 0 || (n[r] = e[r]);return n
    }(e, t));if (Object.getOwnPropertySymbols) {
      const a = Object.getOwnPropertySymbols(e);for (o = 0;o < a.length;o++)r = a[o], t.indexOf(r) >= 0 || Object.prototype.propertyIsEnumerable.call(e, r) && (n[r] = e[r])
    } return n
  } const u = 'undefined' !== typeof wx && 'function' === typeof wx.getSystemInfoSync; const f = 'undefined' !== typeof qq && 'function' === typeof qq.getSystemInfoSync; const l = 'undefined' !== typeof tt && 'function' === typeof tt.getSystemInfoSync; const c = 'undefined' !== typeof swan && 'function' === typeof swan.getSystemInfoSync; const y = 'undefined' !== typeof my && 'function' === typeof my.getSystemInfoSync; const d = u || f || l || c || y; const p = f ? qq : l ? tt : c ? swan : y ? my : u ? wx : {}; const h = function (t) {
    if ('object' !== e(t) || null === t) return !1;const r = Object.getPrototypeOf(t);if (null === r) return !0;for (var o = r;null !== Object.getPrototypeOf(o);)o = Object.getPrototypeOf(o);return r === o
  };function v(e) {
    if (null == e) return !0;if ('boolean' === typeof e) return !1;if ('number' === typeof e) return 0 === e;if ('string' === typeof e) return 0 === e.length;if ('function' === typeof e) return 0 === e.length;if (Array.isArray(e)) return 0 === e.length;if (e instanceof Error) return '' === e.message;if (h(e)) {
      for (const t in e) if (Object.prototype.hasOwnProperty.call(e, t)) return !1;return !0
    } return !1
  } const m = (function () {
    function e() {
      t(this, e), this.downloadUrl = ''
    } return o(e, [{ key: 'request', value(e, t) {
      const r = this;this.downloadUrl = e.downloadUrl || '';const o = (e.method || 'PUT').toUpperCase(); let n = e.url;if (e.qs) {
        const a = (function (e) {
          const t = arguments.length > 1 && void 0 !== arguments[1] ? arguments[1] : '&'; const r = arguments.length > 2 && void 0 !== arguments[2] ? arguments[2] : '=';return v(e) ? '' : h(e) ? Object.keys(e).map(((o) => {
            const n = encodeURIComponent(o) + r;return Array.isArray(e[o]) ? e[o].map(((e) => n + encodeURIComponent(e))).join(t) : n + encodeURIComponent(e[o])
          }))
            .filter(Boolean)
            .join(t) : void 0
        }(e.qs));a && (n += ''.concat(-1 === n.indexOf('?') ? '?' : '&').concat(a))
      } const s = new XMLHttpRequest;s.open(o, n, !0), s.responseType = e.dataType || 'text';const i = e.headers || {};if (!v(i)) for (const u in i)i.hasOwnProperty(u) && 'content-length' !== u.toLowerCase() && 'user-agent' !== u.toLowerCase() && 'origin' !== u.toLowerCase() && 'host' !== u.toLowerCase() && s.setRequestHeader(u, i[u]);return s.onload = function () {
        t(null, r._xhrRes(s, r._xhrBody(s)))
      }, s.onerror = function (e) {
        const o = r._xhrBody(s);if (o)t(e, r._xhrRes(s, o));else {
          let n = s.statusText;n || 0 !== s.status || (n = 'CORS blocked or network error'), t(n, r._xhrRes(s, o))
        }
      }, e.onProgress && s.upload && (s.upload.onprogress = function (t) {
        const r = t.total; const o = t.loaded; const n = Math.floor(100 * o / r);e.onProgress({ total: r, loaded: o, percent: (n >= 100 ? 100 : n) / 100 })
      }), s.send(e.resources), s
    } }, { key: '_xhrRes', value(e, t) {
      const r = {};return e.getAllResponseHeaders().trim()
        .split('\n')
        .forEach(((e) => {
          if (e) {
            const t = e.indexOf(':'); const o = e.substr(0, t).trim()
              .toLowerCase(); const n = e.substr(t + 1).trim();r[o] = n
          }
        })), { statusCode: e.status, statusMessage: e.statusText, headers: r, data: t }
    } }, { key: '_xhrBody', value(e) {
      return 200 === e.status && e.responseURL && this.downloadUrl ? { location: this.downloadUrl } : { response: e.responseText }
    } }]), e
  }()); const b = ['unknown', 'image', 'video', 'audio', 'log']; const g = (function () {
    function e() {
      t(this, e), this.downloadUrl = ''
    } return o(e, [{ key: 'request', value(e, t) {
      const r = this; const o = e.resources; const n = void 0 === o ? '' : o; const a = e.headers; const u = void 0 === a ? {} : a; const f = e.url; const l = e.downloadUrl; const c = void 0 === l ? '' : l;this.downloadUrl = c;let d = null; let h = ''; const v = c.match(/^(https?:\/\/[^/]+\/)([^/]*\/?)(.*)$/);h = (h = decodeURIComponent(v[3])).indexOf('?') > -1 ? h.split('?')[0] : h, u['Content-Type'] = 'multipart/form-data';let m = { url: f, header: u, name: 'file', filePath: n, formData: { key: h, success_action_status: 200, 'Content-Type': '' }, timeout: e.timeout || 3e5 };if (y) {
        const g = m;g.name, m = s(s({}, i(g, ['name'])), {}, { fileName: 'file', fileType: b[e.fileType] })
      } return (d = p.uploadFile(s(s({}, m), {}, { success(e) {
        r._handleResponse(e, t)
      }, fail(e) {
        r._handleResponse(e, t)
      } }))).onProgressUpdate(((t) => {
        e.onProgress && e.onProgress({ total: t.totalBytesExpectedToSend, loaded: t.totalBytesSent, percent: Math.floor(t.progress) / 100 })
      })), d
    } }, { key: '_handleResponse', value(e, t) {
      const r = e.header; const o = {};if (r) for (const n in r)r.hasOwnProperty(n) && (o[n.toLowerCase()] = r[n]);const a = +e.statusCode;200 === a ? t(null, { statusCode: a, headers: o, data: s(s({}, e.data), {}, { location: this.downloadUrl }) }) : t(e, { statusCode: a, headers: o, data: void 0 })
    } }]), e
  }());return (function () {
    function e() {
      t(this, e), console.log('TIMUploadPlugin.VERSION: '.concat('1.0.1')), this.retry = 1, this.tryCount = 0, this.systemClockOffset = 0, this.httpRequest = d ? new g : new m
    } return o(e, [{ key: 'uploadFile', value(e, t) {
      const r = this;return this.httpRequest.request(e, ((o, n) => {
        o && r.tryCount < r.retry && r.allowRetry(o) ? (r.tryCount++, r.uploadFile(e, t)) : (r.tryCount = 0, t(o, n))
      }))
    } }, { key: 'allowRetry', value(e) {
      let t = !1; let r = !1;if (e) {
        const o = e.headers && (e.headers.date || e.headers.Date) || e.error && e.error.ServerTime;try {
          const n = e.error && e.error.Code; const a = e.error && e.error.Message;('RequestTimeTooSkewed' === n || 'AccessDenied' === n && 'Request has expired' === a) && (r = !0)
        } catch (u) {} if (r && o) {
          const s = Date.now(); const i = Date.parse(o);Math.abs(s + this.systemClockOffset - i) >= 3e4 && (this.systemClockOffset = i - s, t = !0)
        } else 5 === Math.floor(e.statusCode / 100) && (t = !0)
      } return t
    } }]), e
  }())
}, 'object' === typeof exports && 'undefined' !== typeof module ? module.exports = factory() : 'function' === typeof define && define.amd ? define(factory) : (global = global || self).TIMUploadPlugin = factory()
