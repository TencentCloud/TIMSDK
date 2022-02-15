!(function (t, e) {
  'object' === typeof exports && 'undefined' !== typeof module ? module.exports = e() : 'function' === typeof define && define.amd ? define(e) : (t = 'undefined' !== typeof globalThis ? globalThis : t || self).dayjs = e();
}(this, (() => {
  'use strict';const t = 1e3; const e = 6e4; const n = 36e5; const r = 'millisecond'; const i = 'second'; const s = 'minute'; const u = 'hour'; const a = 'day'; const o = 'week'; const f = 'month'; const h = 'quarter'; const c = 'year'; const d = 'date'; const $ = 'Invalid Date'; const l = /^(\d{4})[-/]?(\d{1,2})?[-/]?(\d{0,2})[Tt\s]*(\d{1,2})?:?(\d{1,2})?:?(\d{1,2})?[.:]?(\d+)?$/; const y = /\[([^\]]+)]|Y{1,4}|M{1,4}|D{1,2}|d{1,4}|H{1,2}|h{1,2}|a|A|m{1,2}|s{1,2}|Z{1,2}|SSS/g; const M = { name: 'en', weekdays: 'Sunday_Monday_Tuesday_Wednesday_Thursday_Friday_Saturday'.split('_'), months: 'January_February_March_April_May_June_July_August_September_October_November_December'.split('_') }; const m = function (t, e, n) {
    const r = String(t);return !r || r.length >= e ? t : `${Array(e + 1 - r.length).join(n)}${t}`;
  }; const g = { s: m, z(t) {
    const e = -t.utcOffset(); const n = Math.abs(e); const r = Math.floor(n / 60); const i = n % 60;return `${(e <= 0 ? '+' : '-') + m(r, 2, '0')}:${m(i, 2, '0')}`;
  }, m: function t(e, n) {
    if (e.date() < n.date()) return -t(n, e);const r = 12 * (n.year() - e.year()) + (n.month() - e.month()); const i = e.clone().add(r, f); const s = n - i < 0; const u = e.clone().add(r + (s ? -1 : 1), f);return +(-(r + (n - i) / (s ? i - u : u - i)) || 0);
  }, a(t) {
    return t < 0 ? Math.ceil(t) || 0 : Math.floor(t);
  }, p(t) {
    return { M: f, y: c, w: o, d: a, D: d, h: u, m: s, s: i, ms: r, Q: h }[t] || String(t || '').toLowerCase()
      .replace(/s$/, '');
  }, u(t) {
    return void 0 === t;
  } }; let D = 'en'; const v = {};v[D] = M;const p = function (t) {
    return t instanceof _;
  }; const S = function (t, e, n) {
    let r;if (!t) return D;if ('string' === typeof t)v[t] && (r = t), e && (v[t] = e, r = t);else {
      const i = t.name;v[i] = t, r = i;
    } return !n && r && (D = r), r || !n && D;
  }; const w = function (t, e) {
    if (p(t)) return t.clone();const n = 'object' === typeof e ? e : {};return n.date = t, n.args = arguments, new _(n);
  }; const O = g;O.l = S, O.i = p, O.w = function (t, e) {
    return w(t, { locale: e.$L, utc: e.$u, x: e.$x, $offset: e.$offset });
  };
  var _ = (function () {
    function M(t) {
      this.$L = S(t.locale, null, !0), this.parse(t);
    } const m = M.prototype;return m.parse = function (t) {
      this.$d = (function (t) {
        const e = t.date; const n = t.utc;if (null === e) return new Date(NaN);if (O.u(e)) return new Date;if (e instanceof Date) return new Date(e);if ('string' === typeof e && !/Z$/i.test(e)) {
          const r = e.match(l);if (r) {
            const i = r[2] - 1 || 0; const s = (r[7] || '0').substring(0, 3);return n ? new Date(Date.UTC(r[1], i, r[3] || 1, r[4] || 0, r[5] || 0, r[6] || 0, s)) : new Date(r[1], i, r[3] || 1, r[4] || 0, r[5] || 0, r[6] || 0, s);
          }
        } return new Date(e);
      }(t)), this.$x = t.x || {}, this.init();
    }, m.init = function () {
      const t = this.$d;this.$y = t.getFullYear(), this.$M = t.getMonth(), this.$D = t.getDate(), this.$W = t.getDay(), this.$H = t.getHours(), this.$m = t.getMinutes(), this.$s = t.getSeconds(), this.$ms = t.getMilliseconds();
    }, m.$utils = function () {
      return O;
    }, m.isValid = function () {
      return !(this.$d.toString() === $);
    }, m.isSame = function (t, e) {
      const n = w(t);return this.startOf(e) <= n && n <= this.endOf(e);
    }, m.isAfter = function (t, e) {
      return w(t) < this.startOf(e);
    }, m.isBefore = function (t, e) {
      return this.endOf(e) < w(t);
    }, m.$g = function (t, e, n) {
      return O.u(t) ? this[e] : this.set(n, t);
    }, m.unix = function () {
      return Math.floor(this.valueOf() / 1e3);
    }, m.valueOf = function () {
      return this.$d.getTime();
    }, m.startOf = function (t, e) {
      const n = this; const r = !!O.u(e) || e; const h = O.p(t); const $ = function (t, e) {
        const i = O.w(n.$u ? Date.UTC(n.$y, e, t) : new Date(n.$y, e, t), n);return r ? i : i.endOf(a);
      }; const l = function (t, e) {
        return O.w(n.toDate()[t].apply(n.toDate('s'), (r ? [0, 0, 0, 0] : [23, 59, 59, 999]).slice(e)), n);
      }; const y = this.$W; const M = this.$M; const m = this.$D; const g = `set${this.$u ? 'UTC' : ''}`;switch (h) {
        // eslint-disable-next-line no-var
        case c:return r ? $(1, 0) : $(31, 11);case f:return r ? $(1, M) : $(0, M + 1);case o:var D = this.$locale().weekStart || 0; var v = (y < D ? y + 7 : y) - D;return $(r ? m - v : m + (6 - v), M);case a:case d:return l(`${g}Hours`, 0);case u:return l(`${g}Minutes`, 1);case s:return l(`${g}Seconds`, 2);case i:return l(`${g}Milliseconds`, 3);default:return this.clone();
      }
    }, m.endOf = function (t) {
      return this.startOf(t, !1);
    }, m.$set = function (t, e) {
      let n; const o = O.p(t); const h = `set${this.$u ? 'UTC' : ''}`; const $ = (n = {}, n[a] = `${h}Date`, n[d] = `${h}Date`, n[f] = `${h}Month`, n[c] = `${h}FullYear`, n[u] = `${h}Hours`, n[s] = `${h}Minutes`, n[i] = `${h}Seconds`, n[r] = `${h}Milliseconds`, n)[o]; const l = o === a ? this.$D + (e - this.$W) : e;if (o === f || o === c) {
        const y = this.clone().set(d, 1);y.$d[$](l), y.init(), this.$d = y.set(d, Math.min(this.$D, y.daysInMonth())).$d;
      } else $ && this.$d[$](l);return this.init(), this;
    }, m.set = function (t, e) {
      return this.clone().$set(t, e);
    }, m.get = function (t) {
      return this[O.p(t)]();
    }, m.add = function (r, h) {
      let d; const $ = this;r = Number(r);const l = O.p(h); const y = function (t) {
        const e = w($);return O.w(e.date(e.date() + Math.round(t * r)), $);
      };if (l === f) return this.set(f, this.$M + r);if (l === c) return this.set(c, this.$y + r);if (l === a) return y(1);if (l === o) return y(7);const M = (d = {}, d[s] = e, d[u] = n, d[i] = t, d)[l] || 1; const m = this.$d.getTime() + r * M;return O.w(m, this);
    }, m.subtract = function (t, e) {
      return this.add(-1 * t, e);
    }, m.format = function (t) {
      const e = this; const n = this.$locale();if (!this.isValid()) return n.invalidDate || $;const r = t || 'YYYY-MM-DDTHH:mm:ssZ'; const i = O.z(this); const s = this.$H; const u = this.$m; const a = this.$M; const o = n.weekdays; const f = n.months; const h = function (t, n, i, s) {
        return t && (t[n] || t(e, r)) || i[n].substr(0, s);
      }; const c = function (t) {
        return O.s(s % 12 || 12, t, '0');
      }; const d = n.meridiem || function (t, _e, n) {
        const r = t < 12 ? 'AM' : 'PM';return n ? r.toLowerCase() : r;
      }; const l = { YY: String(this.$y).slice(-2), YYYY: this.$y, M: a + 1, MM: O.s(a + 1, 2, '0'), MMM: h(n.monthsShort, a, f, 3), MMMM: h(f, a), D: this.$D, DD: O.s(this.$D, 2, '0'), d: String(this.$W), dd: h(n.weekdaysMin, this.$W, o, 2), ddd: h(n.weekdaysShort, this.$W, o, 3), dddd: o[this.$W], H: String(s), HH: O.s(s, 2, '0'), h: c(1), hh: c(2), a: d(s, u, !0), A: d(s, u, !1), m: String(u), mm: O.s(u, 2, '0'), s: String(this.$s), ss: O.s(this.$s, 2, '0'), SSS: O.s(this.$ms, 3, '0'), Z: i };return r.replace(y, ((t, e) => e || l[t] || i.replace(':', '')));
    }, m.utcOffset = function () {
      return 15 * -Math.round(this.$d.getTimezoneOffset() / 15);
    }, m.diff = function (r, d, $) {
      let l; const y = O.p(d); const M = w(r); const m = (M.utcOffset() - this.utcOffset()) * e; const g = this - M; let D = O.m(this, M);return D = (l = {}, l[c] = D / 12, l[f] = D, l[h] = D / 3, l[o] = (g - m) / 6048e5, l[a] = (g - m) / 864e5, l[u] = g / n, l[s] = g / e, l[i] = g / t, l)[y] || g, $ ? D : O.a(D);
    }, m.daysInMonth = function () {
      return this.endOf(f).$D;
    }, m.$locale = function () {
      return v[this.$L];
    }, m.locale = function (t, e) {
      if (!t) return this.$L;const n = this.clone(); const r = S(t, e, !0);return r && (n.$L = r), n;
    }, m.clone = function () {
      return O.w(this.$d, this);
    }, m.toDate = function () {
      return new Date(this.valueOf());
    }, m.toJSON = function () {
      return this.isValid() ? this.toISOString() : null;
    }, m.toISOString = function () {
      return this.$d.toISOString();
    }, m.toString = function () {
      return this.$d.toUTCString();
    }, M;
  }()); const b = _.prototype;return w.prototype = b, [['$ms', r], ['$s', i], ['$m', s], ['$H', u], ['$W', a], ['$M', f], ['$y', c], ['$D', d]].forEach(((t) => {
    b[t[1]] = function (e) {
      return this.$g(e, t[0], t[1]);
    };
  })), w.extend = function (t, e) {
    return t.$i || (t(e, _, w), t.$i = !0), w;
  }, w.locale = S, w.isDayjs = p, w.unix = function (t) {
    return w(1e3 * t);
  }, w.en = v[D], w.Ls = v, w.p = {}, w;
})));
