!(function (e, t) {
  'object' === typeof exports && 'undefined' !== typeof module ? module.exports = t() : 'function' === typeof define && define.amd ? define(t) : (e = e || self).TIM = t()
}(this, (() => {
  function e(e, t) {
    const n = Object.keys(e);if (Object.getOwnPropertySymbols) {
      let o = Object.getOwnPropertySymbols(e);t && (o = o.filter(((t) => Object.getOwnPropertyDescriptor(e, t).enumerable))), n.push.apply(n, o)
    } return n
  } function t(t) {
    for (let n = 1;n < arguments.length;n++) {
      var o = null != arguments[n] ? arguments[n] : {};n % 2 ? e(Object(o), !0).forEach(((e) => {
        r(t, e, o[e])
      })) : Object.getOwnPropertyDescriptors ? Object.defineProperties(t, Object.getOwnPropertyDescriptors(o)) : e(Object(o)).forEach(((e) => {
        Object.defineProperty(t, e, Object.getOwnPropertyDescriptor(o, e))
      }))
    } return t
  } function n(e) {
    return (n = 'function' === typeof Symbol && 'symbol' === typeof Symbol.iterator ? function (e) {
      return typeof e
    } : function (e) {
      return e && 'function' === typeof Symbol && e.constructor === Symbol && e !== Symbol.prototype ? 'symbol' : typeof e
    })(e)
  } function o(e, t) {
    if (!(e instanceof t)) throw new TypeError('Cannot call a class as a function')
  } function a(e, t) {
    for (let n = 0;n < t.length;n++) {
      const o = t[n];o.enumerable = o.enumerable || !1, o.configurable = !0, 'value' in o && (o.writable = !0), Object.defineProperty(e, o.key, o)
    }
  } function s(e, t, n) {
    return t && a(e.prototype, t), n && a(e, n), e
  } function r(e, t, n) {
    return t in e ? Object.defineProperty(e, t, { value: n, enumerable: !0, configurable: !0, writable: !0 }) : e[t] = n, e
  } function i(e, t) {
    if ('function' !== typeof t && null !== t) throw new TypeError('Super expression must either be null or a function');e.prototype = Object.create(t && t.prototype, { constructor: { value: e, writable: !0, configurable: !0 } }), t && u(e, t)
  } function c(e) {
    return (c = Object.setPrototypeOf ? Object.getPrototypeOf : function (e) {
      return e.__proto__ || Object.getPrototypeOf(e)
    })(e)
  } function u(e, t) {
    return (u = Object.setPrototypeOf || function (e, t) {
      return e.__proto__ = t, e
    })(e, t)
  } function l() {
    if ('undefined' === typeof Reflect || !Reflect.construct) return !1;if (Reflect.construct.sham) return !1;if ('function' === typeof Proxy) return !0;try {
      return Boolean.prototype.valueOf.call(Reflect.construct(Boolean, [], (() => {}))), !0
    } catch (e) {
      return !1
    }
  } function d(e, t, n) {
    return (d = l() ? Reflect.construct : function (e, t, n) {
      const o = [null];o.push.apply(o, t);const a = new(Function.bind.apply(e, o));return n && u(a, n.prototype), a
    }).apply(null, arguments)
  } function g(e) {
    const t = 'function' === typeof Map ? new Map : void 0;return (g = function (e) {
      if (null === e || (n = e, -1 === Function.toString.call(n).indexOf('[native code]'))) return e;let n;if ('function' !== typeof e) throw new TypeError('Super expression must either be null or a function');if (void 0 !== t) {
        if (t.has(e)) return t.get(e);t.set(e, o)
      } function o() {
        return d(e, arguments, c(this).constructor)
      } return o.prototype = Object.create(e.prototype, { constructor: { value: o, enumerable: !1, writable: !0, configurable: !0 } }), u(o, e)
    })(e)
  } function p(e, t) {
    if (null == e) return {};let n; let o; const a = (function (e, t) {
      if (null == e) return {};let n; let o; const a = {}; const s = Object.keys(e);for (o = 0;o < s.length;o++)n = s[o], t.indexOf(n) >= 0 || (a[n] = e[n]);return a
    }(e, t));if (Object.getOwnPropertySymbols) {
      const s = Object.getOwnPropertySymbols(e);for (o = 0;o < s.length;o++)n = s[o], t.indexOf(n) >= 0 || Object.prototype.propertyIsEnumerable.call(e, n) && (a[n] = e[n])
    } return a
  } function h(e) {
    if (void 0 === e) throw new ReferenceError('this hasn\'t been initialised - super() hasn\'t been called');return e
  } function _(e, t) {
    return !t || 'object' !== typeof t && 'function' !== typeof t ? h(e) : t
  } function f(e) {
    const t = l();return function () {
      let n; const o = c(e);if (t) {
        const a = c(this).constructor;n = Reflect.construct(o, arguments, a)
      } else n = o.apply(this, arguments);return _(this, n)
    }
  } function m(e, t) {
    return v(e) || (function (e, t) {
      let n = null == e ? null : 'undefined' !== typeof Symbol && e[Symbol.iterator] || e['@@iterator'];if (null == n) return;let o; let a; const s = []; let r = !0; let i = !1;try {
        for (n = n.call(e);!(r = (o = n.next()).done) && (s.push(o.value), !t || s.length !== t);r = !0);
      } catch (c) {
        i = !0, a = c
      } finally {
        try {
          r || null == n.return || n.return()
        } finally {
          if (i) throw a
        }
      } return s
    }(e, t)) || I(e, t) || T()
  } function M(e) {
    return (function (e) {
      if (Array.isArray(e)) return D(e)
    }(e)) || y(e) || I(e) || (function () {
      throw new TypeError('Invalid attempt to spread non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method.')
    }())
  } function v(e) {
    if (Array.isArray(e)) return e
  } function y(e) {
    if ('undefined' !== typeof Symbol && null != e[Symbol.iterator] || null != e['@@iterator']) return Array.from(e)
  } function I(e, t) {
    if (e) {
      if ('string' === typeof e) return D(e, t);let n = Object.prototype.toString.call(e).slice(8, -1);return 'Object' === n && e.constructor && (n = e.constructor.name), 'Map' === n || 'Set' === n ? Array.from(e) : 'Arguments' === n || /^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n) ? D(e, t) : void 0
    }
  } function D(e, t) {
    (null == t || t > e.length) && (t = e.length);for (var n = 0, o = new Array(t);n < t;n++)o[n] = e[n];return o
  } function T() {
    throw new TypeError('Invalid attempt to destructure non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method.')
  } function S(e, t) {
    let n = 'undefined' !== typeof Symbol && e[Symbol.iterator] || e['@@iterator'];if (!n) {
      if (Array.isArray(e) || (n = I(e)) || t && e && 'number' === typeof e.length) {
        n && (e = n);let o = 0; const a = function () {};return { s: a, n() {
          return o >= e.length ? { done: !0 } : { done: !1, value: e[o++] }
        }, e(e) {
          throw e
        }, f: a }
      } throw new TypeError('Invalid attempt to iterate non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method.')
    } let s; let r = !0; let i = !1;return { s() {
      n = n.call(e)
    }, n() {
      const e = n.next();return r = e.done, e
    }, e(e) {
      i = !0, s = e
    }, f() {
      try {
        r || null == n.return || n.return()
      } finally {
        if (i) throw s
      }
    } }
  } const E = { SDK_READY: 'sdkStateReady', SDK_NOT_READY: 'sdkStateNotReady', SDK_DESTROY: 'sdkDestroy', MESSAGE_RECEIVED: 'onMessageReceived', MESSAGE_MODIFIED: 'onMessageModified', MESSAGE_REVOKED: 'onMessageRevoked', MESSAGE_READ_BY_PEER: 'onMessageReadByPeer', CONVERSATION_LIST_UPDATED: 'onConversationListUpdated', GROUP_LIST_UPDATED: 'onGroupListUpdated', GROUP_SYSTEM_NOTICE_RECEIVED: 'receiveGroupSystemNotice', PROFILE_UPDATED: 'onProfileUpdated', BLACKLIST_UPDATED: 'blacklistUpdated', FRIEND_LIST_UPDATED: 'onFriendListUpdated', FRIEND_GROUP_LIST_UPDATED: 'onFriendGroupListUpdated', FRIEND_APPLICATION_LIST_UPDATED: 'onFriendApplicationListUpdated', KICKED_OUT: 'kickedOut', ERROR: 'error', NET_STATE_CHANGE: 'netStateChange', SDK_RELOAD: 'sdkReload' }; const k = { MSG_TEXT: 'TIMTextElem', MSG_IMAGE: 'TIMImageElem', MSG_SOUND: 'TIMSoundElem', MSG_AUDIO: 'TIMSoundElem', MSG_FILE: 'TIMFileElem', MSG_FACE: 'TIMFaceElem', MSG_VIDEO: 'TIMVideoFileElem', MSG_GEO: 'TIMLocationElem', MSG_GRP_TIP: 'TIMGroupTipElem', MSG_GRP_SYS_NOTICE: 'TIMGroupSystemNoticeElem', MSG_CUSTOM: 'TIMCustomElem', MSG_MERGER: 'TIMRelayElem', MSG_PRIORITY_HIGH: 'High', MSG_PRIORITY_NORMAL: 'Normal', MSG_PRIORITY_LOW: 'Low', MSG_PRIORITY_LOWEST: 'Lowest', CONV_C2C: 'C2C', CONV_GROUP: 'GROUP', CONV_SYSTEM: '@TIM#SYSTEM', CONV_AT_ME: 1, CONV_AT_ALL: 2, CONV_AT_ALL_AT_ME: 3, GRP_PRIVATE: 'Private', GRP_WORK: 'Private', GRP_PUBLIC: 'Public', GRP_CHATROOM: 'ChatRoom', GRP_MEETING: 'ChatRoom', GRP_AVCHATROOM: 'AVChatRoom', GRP_MBR_ROLE_OWNER: 'Owner', GRP_MBR_ROLE_ADMIN: 'Admin', GRP_MBR_ROLE_MEMBER: 'Member', GRP_TIP_MBR_JOIN: 1, GRP_TIP_MBR_QUIT: 2, GRP_TIP_MBR_KICKED_OUT: 3, GRP_TIP_MBR_SET_ADMIN: 4, GRP_TIP_MBR_CANCELED_ADMIN: 5, GRP_TIP_GRP_PROFILE_UPDATED: 6, GRP_TIP_MBR_PROFILE_UPDATED: 7, MSG_REMIND_ACPT_AND_NOTE: 'AcceptAndNotify', MSG_REMIND_ACPT_NOT_NOTE: 'AcceptNotNotify', MSG_REMIND_DISCARD: 'Discard', GENDER_UNKNOWN: 'Gender_Type_Unknown', GENDER_FEMALE: 'Gender_Type_Female', GENDER_MALE: 'Gender_Type_Male', KICKED_OUT_MULT_ACCOUNT: 'multipleAccount', KICKED_OUT_MULT_DEVICE: 'multipleDevice', KICKED_OUT_USERSIG_EXPIRED: 'userSigExpired', ALLOW_TYPE_ALLOW_ANY: 'AllowType_Type_AllowAny', ALLOW_TYPE_NEED_CONFIRM: 'AllowType_Type_NeedConfirm', ALLOW_TYPE_DENY_ANY: 'AllowType_Type_DenyAny', FORBID_TYPE_NONE: 'AdminForbid_Type_None', FORBID_TYPE_SEND_OUT: 'AdminForbid_Type_SendOut', JOIN_OPTIONS_FREE_ACCESS: 'FreeAccess', JOIN_OPTIONS_NEED_PERMISSION: 'NeedPermission', JOIN_OPTIONS_DISABLE_APPLY: 'DisableApply', JOIN_STATUS_SUCCESS: 'JoinedSuccess', JOIN_STATUS_ALREADY_IN_GROUP: 'AlreadyInGroup', JOIN_STATUS_WAIT_APPROVAL: 'WaitAdminApproval', GRP_PROFILE_OWNER_ID: 'ownerID', GRP_PROFILE_CREATE_TIME: 'createTime', GRP_PROFILE_LAST_INFO_TIME: 'lastInfoTime', GRP_PROFILE_MEMBER_NUM: 'memberNum', GRP_PROFILE_MAX_MEMBER_NUM: 'maxMemberNum', GRP_PROFILE_JOIN_OPTION: 'joinOption', GRP_PROFILE_INTRODUCTION: 'introduction', GRP_PROFILE_NOTIFICATION: 'notification', GRP_PROFILE_MUTE_ALL_MBRS: 'muteAllMembers', SNS_ADD_TYPE_SINGLE: 'Add_Type_Single', SNS_ADD_TYPE_BOTH: 'Add_Type_Both', SNS_DELETE_TYPE_SINGLE: 'Delete_Type_Single', SNS_DELETE_TYPE_BOTH: 'Delete_Type_Both', SNS_APPLICATION_TYPE_BOTH: 'Pendency_Type_Both', SNS_APPLICATION_SENT_TO_ME: 'Pendency_Type_ComeIn', SNS_APPLICATION_SENT_BY_ME: 'Pendency_Type_SendOut', SNS_APPLICATION_AGREE: 'Response_Action_Agree', SNS_APPLICATION_AGREE_AND_ADD: 'Response_Action_AgreeAndAdd', SNS_CHECK_TYPE_BOTH: 'CheckResult_Type_Both', SNS_CHECK_TYPE_SINGLE: 'CheckResult_Type_Single', SNS_TYPE_NO_RELATION: 'CheckResult_Type_NoRelation', SNS_TYPE_A_WITH_B: 'CheckResult_Type_AWithB', SNS_TYPE_B_WITH_A: 'CheckResult_Type_BWithA', SNS_TYPE_BOTH_WAY: 'CheckResult_Type_BothWay', NET_STATE_CONNECTED: 'connected', NET_STATE_CONNECTING: 'connecting', NET_STATE_DISCONNECTED: 'disconnected', MSG_AT_ALL: '__kImSDK_MesssageAtALL__' }; const C = (function () {
    function e() {
      o(this, e), this.cache = [], this.options = null
    } return s(e, [{ key: 'use', value(e) {
      if ('function' !== typeof e) throw 'middleware must be a function';return this.cache.push(e), this
    } }, { key: 'next', value(e) {
      if (this.middlewares && this.middlewares.length > 0) return this.middlewares.shift().call(this, this.options, this.next.bind(this))
    } }, { key: 'run', value(e) {
      return this.middlewares = this.cache.map(((e) => e)), this.options = e, this.next()
    } }]), e
  }()); const N = 'undefined' !== typeof globalThis ? globalThis : 'undefined' !== typeof window ? window : 'undefined' !== typeof global ? global : 'undefined' !== typeof self ? self : {};function A(e, t) {
    return e(t = { exports: {} }, t.exports), t.exports
  } const O = A(((e, t) => {
    let n; let o; let a; let s; let r; let i; let c; let u; let l; let d; let g; let p; let h; let _; let f; let m; let M; let v;e.exports = (n = 'function' === typeof Promise, o = 'object' === typeof self ? self : N, a = 'undefined' !== typeof Symbol, s = 'undefined' !== typeof Map, r = 'undefined' !== typeof Set, i = 'undefined' !== typeof WeakMap, c = 'undefined' !== typeof WeakSet, u = 'undefined' !== typeof DataView, l = a && void 0 !== Symbol.iterator, d = a && void 0 !== Symbol.toStringTag, g = r && 'function' === typeof Set.prototype.entries, p = s && 'function' === typeof Map.prototype.entries, h = g && Object.getPrototypeOf((new Set).entries()), _ = p && Object.getPrototypeOf((new Map).entries()), f = l && 'function' === typeof Array.prototype[Symbol.iterator], m = f && Object.getPrototypeOf([][Symbol.iterator]()), M = l && 'function' === typeof String.prototype[Symbol.iterator], v = M && Object.getPrototypeOf(''[Symbol.iterator]()), function (e) {
      const t = typeof e;if ('object' !== t) return t;if (null === e) return 'null';if (e === o) return 'global';if (Array.isArray(e) && (!1 === d || !(Symbol.toStringTag in e))) return 'Array';if ('object' === typeof window && null !== window) {
        if ('object' === typeof window.location && e === window.location) return 'Location';if ('object' === typeof window.document && e === window.document) return 'Document';if ('object' === typeof window.navigator) {
          if ('object' === typeof window.navigator.mimeTypes && e === window.navigator.mimeTypes) return 'MimeTypeArray';if ('object' === typeof window.navigator.plugins && e === window.navigator.plugins) return 'PluginArray'
        } if (('function' === typeof window.HTMLElement || 'object' === typeof window.HTMLElement) && e instanceof window.HTMLElement) {
          if ('BLOCKQUOTE' === e.tagName) return 'HTMLQuoteElement';if ('TD' === e.tagName) return 'HTMLTableDataCellElement';if ('TH' === e.tagName) return 'HTMLTableHeaderCellElement'
        }
      } const a = d && e[Symbol.toStringTag];if ('string' === typeof a) return a;const l = Object.getPrototypeOf(e);return l === RegExp.prototype ? 'RegExp' : l === Date.prototype ? 'Date' : n && l === Promise.prototype ? 'Promise' : r && l === Set.prototype ? 'Set' : s && l === Map.prototype ? 'Map' : c && l === WeakSet.prototype ? 'WeakSet' : i && l === WeakMap.prototype ? 'WeakMap' : u && l === DataView.prototype ? 'DataView' : s && l === _ ? 'Map Iterator' : r && l === h ? 'Set Iterator' : f && l === m ? 'Array Iterator' : M && l === v ? 'String Iterator' : null === l ? 'Object' : Object.prototype.toString.call(e).slice(8, -1)
    })
  })); const L = { WEB: 7, WX_MP: 8, QQ_MP: 9, TT_MP: 10, BAIDU_MP: 11, ALI_MP: 12, UNI_NATIVE_APP: 14 }; const R = '1.7.3'; const G = 537048168; const w = 1; const P = 2; const b = 3; const U = { HOST: { CURRENT: { DEFAULT: '', BACKUP: '' }, TEST: { DEFAULT: 'wss://wss-dev.tim.qq.com', BACKUP: 'wss://wss-dev.tim.qq.com' }, PRODUCTION: { DEFAULT: 'wss://wss.im.qcloud.com', BACKUP: 'wss://wss.tim.qq.com' }, OVERSEA_PRODUCTION: { DEFAULT: 'wss://wss.im.qcloud.com', BACKUP: 'wss://wss.im.qcloud.com' }, setCurrent() {
    const e = arguments.length > 0 && void 0 !== arguments[0] ? arguments[0] : 2;e === w ? this.CURRENT = this.TEST : e === P ? this.CURRENT = this.PRODUCTION : e === b && (this.CURRENT = this.OVERSEA_PRODUCTION)
  } }, NAME: { OPEN_IM: 'openim', GROUP: 'group_open_http_svc', FRIEND: 'sns', PROFILE: 'profile', RECENT_CONTACT: 'recentcontact', PIC: 'openpic', BIG_GROUP_NO_AUTH: 'group_open_http_noauth_svc', BIG_GROUP_LONG_POLLING: 'group_open_long_polling_http_svc', BIG_GROUP_LONG_POLLING_NO_AUTH: 'group_open_long_polling_http_noauth_svc', IM_OPEN_STAT: 'imopenstat', WEB_IM: 'webim', IM_COS_SIGN: 'im_cos_sign_svr', CUSTOM_UPLOAD: 'im_cos_msg', HEARTBEAT: 'heartbeat', IM_OPEN_PUSH: 'im_open_push', IM_OPEN_STATUS: 'im_open_status', IM_LONG_MESSAGE: 'im_long_msg', CLOUD_CONTROL: 'im_sdk_config_mgr' }, CMD: { ACCESS_LAYER: 'accesslayer', LOGIN: 'wslogin', LOGOUT_LONG_POLL: 'longpollinglogout', LOGOUT: 'wslogout', HELLO: 'wshello', PORTRAIT_GET: 'portrait_get_all', PORTRAIT_SET: 'portrait_set', GET_LONG_POLL_ID: 'getlongpollingid', LONG_POLL: 'longpolling', AVCHATROOM_LONG_POLL: 'get_msg', ADD_FRIEND: 'friend_add', UPDATE_FRIEND: 'friend_update', GET_FRIEND_LIST: 'friend_get', GET_FRIEND_PROFILE: 'friend_get_list', DELETE_FRIEND: 'friend_delete', CHECK_FRIEND: 'friend_check', GET_FRIEND_GROUP_LIST: 'group_get', RESPOND_FRIEND_APPLICATION: 'friend_response', GET_FRIEND_APPLICATION_LIST: 'pendency_get', DELETE_FRIEND_APPLICATION: 'pendency_delete', REPORT_FRIEND_APPLICATION: 'pendency_report', GET_GROUP_APPLICATION: 'get_pendency', CREATE_FRIEND_GROUP: 'group_add', DELETE_FRIEND_GROUP: 'group_delete', UPDATE_FRIEND_GROUP: 'group_update', GET_BLACKLIST: 'black_list_get', ADD_BLACKLIST: 'black_list_add', DELETE_BLACKLIST: 'black_list_delete', CREATE_GROUP: 'create_group', GET_JOINED_GROUPS: 'get_joined_group_list', SEND_MESSAGE: 'sendmsg', REVOKE_C2C_MESSAGE: 'msgwithdraw', DELETE_C2C_MESSAGE: 'delete_c2c_msg_ramble', SEND_GROUP_MESSAGE: 'send_group_msg', REVOKE_GROUP_MESSAGE: 'group_msg_recall', DELETE_GROUP_MESSAGE: 'delete_group_ramble_msg_by_seq', GET_GROUP_INFO: 'get_group_info', GET_GROUP_MEMBER_INFO: 'get_specified_group_member_info', GET_GROUP_MEMBER_LIST: 'get_group_member_info', QUIT_GROUP: 'quit_group', CHANGE_GROUP_OWNER: 'change_group_owner', DESTROY_GROUP: 'destroy_group', ADD_GROUP_MEMBER: 'add_group_member', DELETE_GROUP_MEMBER: 'delete_group_member', SEARCH_GROUP_BY_ID: 'get_group_public_info', APPLY_JOIN_GROUP: 'apply_join_group', HANDLE_APPLY_JOIN_GROUP: 'handle_apply_join_group', HANDLE_GROUP_INVITATION: 'handle_invite_join_group', MODIFY_GROUP_INFO: 'modify_group_base_info', MODIFY_GROUP_MEMBER_INFO: 'modify_group_member_info', DELETE_GROUP_SYSTEM_MESSAGE: 'deletemsg', DELETE_GROUP_AT_TIPS: 'deletemsg', GET_CONVERSATION_LIST: 'get', PAGING_GET_CONVERSATION_LIST: 'page_get', DELETE_CONVERSATION: 'delete', GET_MESSAGES: 'getmsg', GET_C2C_ROAM_MESSAGES: 'getroammsg', GET_GROUP_ROAM_MESSAGES: 'group_msg_get', SET_C2C_MESSAGE_READ: 'msgreaded', GET_PEER_READ_TIME: 'get_peer_read_time', SET_GROUP_MESSAGE_READ: 'msg_read_report', FILE_READ_AND_WRITE_AUTHKEY: 'authkey', FILE_UPLOAD: 'pic_up', COS_SIGN: 'cos', COS_PRE_SIG: 'pre_sig', TIM_WEB_REPORT_V2: 'tim_web_report_v2', BIG_DATA_HALLWAY_AUTH_KEY: 'authkey', GET_ONLINE_MEMBER_NUM: 'get_online_member_num', ALIVE: 'alive', MESSAGE_PUSH: 'msg_push', MESSAGE_PUSH_ACK: 'ws_msg_push_ack', STATUS_FORCEOFFLINE: 'stat_forceoffline', DOWNLOAD_MERGER_MESSAGE: 'get_relay_json_msg', UPLOAD_MERGER_MESSAGE: 'save_relay_json_msg', FETCH_CLOUD_CONTROL_CONFIG: 'fetch_config', PUSHED_CLOUD_CONTROL_CONFIG: 'push_configv2' }, CHANNEL: { SOCKET: 1, XHR: 2, AUTO: 0 }, NAME_VERSION: { openim: 'v4', group_open_http_svc: 'v4', sns: 'v4', profile: 'v4', recentcontact: 'v4', openpic: 'v4', group_open_http_noauth_svc: 'v4', group_open_long_polling_http_svc: 'v4', group_open_long_polling_http_noauth_svc: 'v4', imopenstat: 'v4', im_cos_sign_svr: 'v4', im_cos_msg: 'v4', webim: 'v4', im_open_push: 'v4', im_open_status: 'v4' } };U.HOST.setCurrent(P);let F; let q; let V; let K; const x = 'undefined' !== typeof wx && 'function' === typeof wx.getSystemInfoSync && Boolean(wx.getSystemInfoSync().fontSizeSetting); const B = 'undefined' !== typeof qq && 'function' === typeof qq.getSystemInfoSync && Boolean(qq.getSystemInfoSync().fontSizeSetting); const H = 'undefined' !== typeof tt && 'function' === typeof tt.getSystemInfoSync && Boolean(tt.getSystemInfoSync().fontSizeSetting); const j = 'undefined' !== typeof swan && 'function' === typeof swan.getSystemInfoSync && Boolean(swan.getSystemInfoSync().fontSizeSetting); const $ = 'undefined' !== typeof my && 'function' === typeof my.getSystemInfoSync && Boolean(my.getSystemInfoSync().fontSizeSetting); const Y = 'undefined' !== typeof uni && 'undefined' === typeof window; const z = x || B || H || j || $ || Y; const W = ('undefined' !== typeof uni || 'undefined' !== typeof window) && !z; const J = B ? qq : H ? tt : j ? swan : $ ? my : x ? wx : Y ? uni : {}; const X = (F = 'WEB', de ? F = 'WEB' : B ? F = 'QQ_MP' : H ? F = 'TT_MP' : j ? F = 'BAIDU_MP' : $ ? F = 'ALI_MP' : x ? F = 'WX_MP' : Y && (F = 'UNI_NATIVE_APP'), L[F]); const Q = W && window && window.navigator && window.navigator.userAgent || ''; const Z = /AppleWebKit\/([\d.]+)/i.exec(Q); const ee = (Z && parseFloat(Z.pop()), /iPad/i.test(Q)); const te = /iPhone/i.test(Q) && !ee; const ne = /iPod/i.test(Q); const oe = te || ee || ne; const ae = ((q = Q.match(/OS (\d+)_/i)) && q[1] && q[1], /Android/i.test(Q)); const se = (function () {
    const e = Q.match(/Android (\d+)(?:\.(\d+))?(?:\.(\d+))*/i);if (!e) return null;const t = e[1] && parseFloat(e[1]); const n = e[2] && parseFloat(e[2]);return t && n ? parseFloat(`${e[1]}.${e[2]}`) : t || null
  }()); const re = (ae && /webkit/i.test(Q), /Firefox/i.test(Q), /Edge/i.test(Q)); const ie = !re && /Chrome/i.test(Q); const ce = ((function () {
    const e = Q.match(/Chrome\/(\d+)/);e && e[1] && parseFloat(e[1])
  }()), /MSIE/.test(Q)); const ue = (/MSIE\s8\.0/.test(Q), (function () {
    const e = /MSIE\s(\d+)\.\d/.exec(Q); let t = e && parseFloat(e[1]);return !t && /Trident\/7.0/i.test(Q) && /rv:11.0/.test(Q) && (t = 11), t
  }())); const le = (/Safari/i.test(Q), /TBS\/\d+/i.test(Q)); var de = ((function () {
    const e = Q.match(/TBS\/(\d+)/i);if (e && e[1])e[1]
  }()), !le && /MQQBrowser\/\d+/i.test(Q), !le && / QQBrowser\/\d+/i.test(Q), /(micromessenger|webbrowser)/i.test(Q)); const ge = /Windows/i.test(Q); const pe = /MAC OS X/i.test(Q); const he = (/MicroMessenger/i.test(Q), 'undefined' !== typeof global ? global : 'undefined' !== typeof self ? self : 'undefined' !== typeof window ? window : {});V = 'undefined' !== typeof console ? console : void 0 !== he && he.console ? he.console : 'undefined' !== typeof window && window.console ? window.console : {};for (var _e = function () {}, fe = ['assert', 'clear', 'count', 'debug', 'dir', 'dirxml', 'error', 'exception', 'group', 'groupCollapsed', 'groupEnd', 'info', 'log', 'markTimeline', 'profile', 'profileEnd', 'table', 'time', 'timeEnd', 'timeStamp', 'trace', 'warn'], me = fe.length;me--;)K = fe[me], console[K] || (V[K] = _e);V.methods = fe;const Me = V; let ve = 0; const ye = function () {
    return (new Date).getTime() + ve
  }; const Ie = function () {
    ve = 0
  }; let De = 0; const Te = new Map;function Se() {
    let e; const t = ((e = new Date).setTime(ye()), e);return `TIM ${t.toLocaleTimeString('en-US', { hour12: !1 })}.${(function (e) {
      let t;switch (e.toString().length) {
        case 1:t = `00${e}`;break;case 2:t = `0${e}`;break;default:t = e
      } return t
    }(t.getMilliseconds()))}:`
  } const Ee = { arguments2String(e) {
    let t;if (1 === e.length)t = Se() + e[0];else {
      t = Se();for (let n = 0, o = e.length;n < o;n++)we(e[n]) ? be(e[n]) ? t += xe(e[n]) : t += JSON.stringify(e[n]) : t += e[n], t += ' '
    } return t
  }, debug() {
    if (De <= -1) {
      const e = this.arguments2String(arguments);Me.debug(e)
    }
  }, log() {
    if (De <= 0) {
      const e = this.arguments2String(arguments);Me.log(e)
    }
  }, info() {
    if (De <= 1) {
      const e = this.arguments2String(arguments);Me.info(e)
    }
  }, warn() {
    if (De <= 2) {
      const e = this.arguments2String(arguments);Me.warn(e)
    }
  }, error() {
    if (De <= 3) {
      const e = this.arguments2String(arguments);Me.error(e)
    }
  }, time(e) {
    Te.set(e, Ve.now())
  }, timeEnd(e) {
    if (Te.has(e)) {
      const t = Ve.now() - Te.get(e);return Te.delete(e), t
    } return Me.warn('未找到对应label: '.concat(e, ', 请在调用 logger.timeEnd 前，调用 logger.time')), 0
  }, setLevel(e) {
    e < 4 && Me.log(`${Se()}set level from ${De} to ${e}`), De = e
  }, getLevel() {
    return De
  } }; const ke = ['url']; const Ce = function (e) {
    return 'file' === Ue(e)
  }; const Ne = function (e) {
    return null !== e && ('number' === typeof e && !isNaN(e - 0) || 'object' === n(e) && e.constructor === Number)
  }; const Ae = function (e) {
    return 'string' === typeof e
  }; const Oe = function (e) {
    return null !== e && 'object' === n(e)
  }; const Le = function (e) {
    if ('object' !== n(e) || null === e) return !1;const t = Object.getPrototypeOf(e);if (null === t) return !0;for (var o = t;null !== Object.getPrototypeOf(o);)o = Object.getPrototypeOf(o);return t === o
  }; const Re = function (e) {
    return 'function' === typeof Array.isArray ? Array.isArray(e) : 'array' === Ue(e)
  }; const Ge = function (e) {
    return void 0 === e
  }; var we = function (e) {
    return Re(e) || Oe(e)
  }; const Pe = function (e) {
    return 'function' === typeof e
  }; var be = function (e) {
    return e instanceof Error
  }; var Ue = function (e) {
    return Object.prototype.toString.call(e).match(/^\[object (.*)\]$/)[1].toLowerCase()
  }; const Fe = function (e) {
    if ('string' !== typeof e) return !1;const t = e[0];return !/[^a-zA-Z0-9]/.test(t)
  }; let qe = 0;Date.now || (Date.now = function () {
    return (new Date).getTime()
  });var Ve = { now() {
    0 === qe && (qe = Date.now() - 1);const e = Date.now() - qe;return e > 4294967295 ? (qe += 4294967295, Date.now() - qe) : e
  }, utc() {
    return Math.round(Date.now() / 1e3)
  } }; const Ke = function e(t, n, o, a) {
    if (!we(t) || !we(n)) return 0;for (var s, r = 0, i = Object.keys(n), c = 0, u = i.length;c < u;c++) if (s = i[c], !(Ge(n[s]) || o && o.includes(s))) if (we(t[s]) && we(n[s]))r += e(t[s], n[s], o, a);else {
      if (a && a.includes(n[s])) continue;t[s] !== n[s] && (t[s] = n[s], r += 1)
    } return r
  }; var xe = function (e) {
    return JSON.stringify(e, ['message', 'code'])
  }; const Be = function (e) {
    if (0 === e.length) return 0;for (var t = 0, n = 0, o = 'undefined' !== typeof document && void 0 !== document.characterSet ? document.characterSet : 'UTF-8';void 0 !== e[t];)n += e[t++].charCodeAt[t] <= 255 ? 1 : !1 === o ? 3 : 2;return n
  }; const He = function (e) {
    const t = e || 99999999;return Math.round(Math.random() * t)
  }; const je = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'; const $e = je.length; const Ye = function (e, t) {
    for (const n in e) if (e[n] === t) return !0;return !1
  }; const ze = {}; const We = function () {
    if (z) return 'https:';if (W && 'undefined' === typeof window) return 'https:';let e = window.location.protocol;return ['http:', 'https:'].indexOf(e) < 0 && (e = 'http:'), e
  }; const Je = function (e) {
    return -1 === e.indexOf('http://') || -1 === e.indexOf('https://') ? `https://${e}` : e.replace(/https|http/, 'https')
  }; const Xe = function e(t) {
    if (0 === Object.getOwnPropertyNames(t).length) return Object.create(null);const o = Array.isArray(t) ? [] : Object.create(null); let a = '';for (const s in t)null !== t[s] ? void 0 !== t[s] ? (a = n(t[s]), ['string', 'number', 'function', 'boolean'].indexOf(a) >= 0 ? o[s] = t[s] : o[s] = e(t[s])) : o[s] = void 0 : o[s] = null;return o
  };function Qe(e, t) {
    Re(e) && Re(t) ? t.forEach(((t) => {
      const n = t.key; const o = t.value; const a = e.find(((e) => e.key === n));a ? a.value = o : e.push({ key: n, value: o })
    })) : Ee.warn('updateCustomField target 或 source 不是数组，忽略此次更新。')
  } const Ze = function (e) {
    return e === k.GRP_PUBLIC
  }; const et = function (e) {
    return e === k.GRP_AVCHATROOM
  }; const nt = function (e) {
    return Ae(e) && e === k.CONV_SYSTEM
  };function ot(e, t) {
    const n = {};return Object.keys(e).forEach(((o) => {
      n[o] = t(e[o], o)
    })), n
  } function at() {
    function e() {
      return (65536 * (1 + Math.random()) | 0).toString(16).substring(1)
    } return ''.concat(e() + e()).concat(e())
      .concat(e())
      .concat(e())
      .concat(e())
      .concat(e())
      .concat(e())
  } function st() {
    let e = 'unknown';if (pe && (e = 'mac'), ge && (e = 'windows'), oe && (e = 'ios'), ae && (e = 'android'), z) try {
      const t = J.getSystemInfoSync().platform;void 0 !== t && (e = t)
    } catch (n) {} return e
  } function rt(e) {
    const t = e.originUrl; const n = void 0 === t ? void 0 : t; const o = e.originWidth; const a = e.originHeight; const s = e.min; const r = void 0 === s ? 198 : s; const i = parseInt(o); const c = parseInt(a); const u = { url: void 0, width: 0, height: 0 };return (i <= c ? i : c) <= r ? (u.url = n, u.width = i, u.height = c) : (c <= i ? (u.width = Math.ceil(i * r / c), u.height = r) : (u.width = r, u.height = Math.ceil(c * r / i)), u.url = ''.concat(n, 198 === r ? '?imageView2/3/w/198/h/198' : '?imageView2/3/w/720/h/720')), Ge(n) ? p(u, ke) : u
  } function it(e) {
    const t = e[2];e[2] = e[1], e[1] = t;for (let n = 0;n < e.length;n++)e[n].setType(n)
  } function ct(e) {
    const t = e.servcmd;return t.slice(t.indexOf('.') + 1)
  } function ut(e, t) {
    return Math.round(Number(e) * Math.pow(10, t)) / Math.pow(10, t)
  } const lt = Object.prototype.hasOwnProperty;function dt(e) {
    if (null == e) return !0;if ('boolean' === typeof e) return !1;if ('number' === typeof e) return 0 === e;if ('string' === typeof e) return 0 === e.length;if ('function' === typeof e) return 0 === e.length;if (Array.isArray(e)) return 0 === e.length;if (e instanceof Error) return '' === e.message;if (Le(e)) {
      for (const t in e) if (lt.call(e, t)) return !1;return !0
    } return !('map' !== Ue(e) && !(function (e) {
      return 'set' === Ue(e)
    }(e)) && !Ce(e)) && 0 === e.size
  } function gt(e, t, n) {
    if (void 0 === t) return !0;let o = !0;if ('object' === O(t).toLowerCase())Object.keys(t).forEach(((a) => {
      const s = 1 === e.length ? e[0][a] : void 0;o = !!pt(s, t[a], n, a) && o
    }));else if ('array' === O(t).toLowerCase()) for (let a = 0;a < t.length;a++)o = !!pt(e[a], t[a], n, t[a].name) && o;if (o) return o;throw new Error('Params validate failed.')
  } function pt(e, t, n, o) {
    if (void 0 === t) return !0;let a = !0;return t.required && dt(e) && (Me.error('TIM ['.concat(n, '] Missing required params: "').concat(o, '".')), a = !1), dt(e) || O(e).toLowerCase() === t.type.toLowerCase() || (Me.error('TIM ['.concat(n, '] Invalid params: type check failed for "').concat(o, '".Expected ')
      .concat(t.type, '.')), a = !1), t.validator && !t.validator(e) && (Me.error('TIM ['.concat(n, '] Invalid params: custom validator check failed for params.')), a = !1), a
  } let ht; const _t = { UNSEND: 'unSend', SUCCESS: 'success', FAIL: 'fail' }; const ft = { NOT_START: 'notStart', PENDING: 'pengding', RESOLVED: 'resolved', REJECTED: 'rejected' }; const mt = function (e) {
    return !!e && (!!((function (e) {
      return Ae(e) && e.slice(0, 3) === k.CONV_C2C
    }(e)) || (function (e) {
      return Ae(e) && e.slice(0, 5) === k.CONV_GROUP
    }(e)) || nt(e)) || (console.warn('非法的会话 ID:'.concat(e, '。会话 ID 组成方式：C2C + userID（单聊）GROUP + groupID（群聊）@TIM#SYSTEM（系统通知会话）')), !1))
  }; const Mt = '请参考 https://web.sdk.qcloud.com/im/doc/zh-cn/SDK.html#'; const vt = function (e) {
    return e.param ? ''.concat(e.api, ' ').concat(e.param, ' ')
      .concat(e.desc, '。')
      .concat(Mt)
      .concat(e.api) : ''.concat(e.api, ' ').concat(e.desc, '。')
      .concat(Mt)
      .concat(e.api)
  }; const yt = { type: 'String', required: !0 }; const It = { type: 'Array', required: !0 }; const Dt = { type: 'Object', required: !0 }; const Tt = { login: { userID: yt, userSig: yt }, addToBlacklist: { userIDList: It }, on: [{ name: 'eventName', type: 'String', validator(e) {
    return 'string' === typeof e && 0 !== e.length || (console.warn(vt({ api: 'on', param: 'eventName', desc: '类型必须为 String，且不能为空' })), !1)
  } }, { name: 'handler', type: 'Function', validator(e) {
    return 'function' !== typeof e ? (console.warn(vt({ api: 'on', param: 'handler', desc: '参数必须为 Function' })), !1) : ('' === e.name && console.warn('on 接口的 handler 参数推荐使用具名函数。具名函数可以使用 off 接口取消订阅，匿名函数无法取消订阅。'), !0)
  } }], once: [{ name: 'eventName', type: 'String', validator(e) {
    return 'string' === typeof e && 0 !== e.length || (console.warn(vt({ api: 'once', param: 'eventName', desc: '类型必须为 String，且不能为空' })), !1)
  } }, { name: 'handler', type: 'Function', validator(e) {
    return 'function' !== typeof e ? (console.warn(vt({ api: 'once', param: 'handler', desc: '参数必须为 Function' })), !1) : ('' === e.name && console.warn('once 接口的 handler 参数推荐使用具名函数。'), !0)
  } }], off: [{ name: 'eventName', type: 'String', validator(e) {
    return 'string' === typeof e && 0 !== e.length || (console.warn(vt({ api: 'off', param: 'eventName', desc: '类型必须为 String，且不能为空' })), !1)
  } }, { name: 'handler', type: 'Function', validator(e) {
    return 'function' !== typeof e ? (console.warn(vt({ api: 'off', param: 'handler', desc: '参数必须为 Function' })), !1) : ('' === e.name && console.warn('off 接口无法为匿名函数取消监听事件。'), !0)
  } }], sendMessage: [t({ name: 'message' }, Dt)], getMessageList: { conversationID: t(t({}, yt), {}, { validator(e) {
    return mt(e)
  } }), nextReqMessageID: { type: 'String' }, count: { type: 'Number', validator(e) {
    return !(!Ge(e) && !/^[1-9][0-9]*$/.test(e)) || (console.warn(vt({ api: 'getMessageList', param: 'count', desc: '必须为正整数' })), !1)
  } } }, setMessageRead: { conversationID: t(t({}, yt), {}, { validator(e) {
    return mt(e)
  } }) }, getConversationProfile: [t(t({ name: 'conversationID' }, yt), {}, { validator(e) {
    return mt(e)
  } })], deleteConversation: [t(t({ name: 'conversationID' }, yt), {}, { validator(e) {
    return mt(e)
  } })], getGroupList: { groupProfileFilter: { type: 'Array' } }, getGroupProfile: { groupID: yt, groupCustomFieldFilter: { type: 'Array' }, memberCustomFieldFilter: { type: 'Array' } }, getGroupProfileAdvance: { groupIDList: It }, createGroup: { name: yt }, joinGroup: { groupID: yt, type: { type: 'String' }, applyMessage: { type: 'String' } }, quitGroup: [t({ name: 'groupID' }, yt)], handleApplication: { message: Dt, handleAction: yt, handleMessage: { type: 'String' } }, changeGroupOwner: { groupID: yt, newOwnerID: yt }, updateGroupProfile: { groupID: yt, muteAllMembers: { type: 'Boolean' } }, dismissGroup: [t({ name: 'groupID' }, yt)], searchGroupByID: [t({ name: 'groupID' }, yt)], getGroupMemberList: { groupID: yt, offset: { type: 'Number' }, count: { type: 'Number' } }, getGroupMemberProfile: { groupID: yt, userIDList: It, memberCustomFieldFilter: { type: 'Array' } }, addGroupMember: { groupID: yt, userIDList: It }, setGroupMemberRole: { groupID: yt, userID: yt, role: yt }, setGroupMemberMuteTime: { groupID: yt, userID: yt, muteTime: { type: 'Number', validator(e) {
    return e >= 0
  } } }, setGroupMemberNameCard: { groupID: yt, userID: { type: 'String' }, nameCard: t(t({}, yt), {}, { validator(e) {
    return !0 !== /^\s+$/.test(e)
  } }) }, setMessageRemindType: { groupID: yt, messageRemindType: yt }, setGroupMemberCustomField: { groupID: yt, userID: { type: 'String' }, memberCustomField: It }, deleteGroupMember: { groupID: yt }, createTextMessage: { to: yt, conversationType: yt, payload: t(t({}, Dt), {}, { validator(e) {
    return Le(e) ? Ae(e.text) ? 0 !== e.text.length || (console.warn(vt({ api: 'createTextMessage', desc: '消息内容不能为空' })), !1) : (console.warn(vt({ api: 'createTextMessage', param: 'payload.text', desc: '类型必须为 String' })), !1) : (console.warn(vt({ api: 'createTextMessage', param: 'payload', desc: '类型必须为 plain object' })), !1)
  } }) }, createTextAtMessage: { to: yt, conversationType: yt, payload: t(t({}, Dt), {}, { validator(e) {
    return Le(e) ? Ae(e.text) ? 0 === e.text.length ? (console.warn(vt({ api: 'createTextAtMessage', desc: '消息内容不能为空' })), !1) : !(e.atUserList && !Re(e.atUserList)) || (console.warn(vt({ api: 'createTextAtMessage', desc: 'payload.atUserList 类型必须为数组' })), !1) : (console.warn(vt({ api: 'createTextAtMessage', param: 'payload.text', desc: '类型必须为 String' })), !1) : (console.warn(vt({ api: 'createTextAtMessage', param: 'payload', desc: '类型必须为 plain object' })), !1)
  } }) }, createCustomMessage: { to: yt, conversationType: yt, payload: t(t({}, Dt), {}, { validator(e) {
    return Le(e) ? e.data && !Ae(e.data) ? (console.warn(vt({ api: 'createCustomMessage', param: 'payload.data', desc: '类型必须为 String' })), !1) : e.description && !Ae(e.description) ? (console.warn(vt({ api: 'createCustomMessage', param: 'payload.description', desc: '类型必须为 String' })), !1) : !(e.extension && !Ae(e.extension)) || (console.warn(vt({ api: 'createCustomMessage', param: 'payload.extension', desc: '类型必须为 String' })), !1) : (console.warn(vt({ api: 'createCustomMessage', param: 'payload', desc: '类型必须为 plain object' })), !1)
  } }) }, createImageMessage: { to: yt, conversationType: yt, payload: t(t({}, Dt), {}, { validator(e) {
    if (!Le(e)) return console.warn(vt({ api: 'createImageMessage', param: 'payload', desc: '类型必须为 plain object' })), !1;if (Ge(e.file)) return console.warn(vt({ api: 'createImageMessage', param: 'payload.file', desc: '不能为 undefined' })), !1;if (W) {
      if (!(e.file instanceof HTMLInputElement || Ce(e.file))) return Le(e.file) && 'undefined' !== typeof uni ? 0 !== e.file.tempFilePaths.length && 0 !== e.file.tempFiles.length || (console.warn(vt({ api: 'createImageMessage', param: 'payload.file', desc: '您没有选择文件，无法发送' })), !1) : (console.warn(vt({ api: 'createImageMessage', param: 'payload.file', desc: '类型必须是 HTMLInputElement 或 File' })), !1);if (e.file instanceof HTMLInputElement && 0 === e.file.files.length) return console.warn(vt({ api: 'createImageMessage', param: 'payload.file', desc: '您没有选择文件，无法发送' })), !1
    } return !0
  }, onProgress: { type: 'Function', required: !1, validator(e) {
    return Ge(e) && console.warn(vt({ api: 'createImageMessage', desc: '没有 onProgress 回调，您将无法获取上传进度' })), !0
  } } }) }, createAudioMessage: { to: yt, conversationType: yt, payload: t(t({}, Dt), {}, { validator(e) {
    return !!Le(e) || (console.warn(vt({ api: 'createAudioMessage', param: 'payload', desc: '类型必须为 plain object' })), !1)
  } }), onProgress: { type: 'Function', required: !1, validator(e) {
    return Ge(e) && console.warn(vt({ api: 'createAudioMessage', desc: '没有 onProgress 回调，您将无法获取上传进度' })), !0
  } } }, createVideoMessage: { to: yt, conversationType: yt, payload: t(t({}, Dt), {}, { validator(e) {
    if (!Le(e)) return console.warn(vt({ api: 'createVideoMessage', param: 'payload', desc: '类型必须为 plain object' })), !1;if (Ge(e.file)) return console.warn(vt({ api: 'createVideoMessage', param: 'payload.file', desc: '不能为 undefined' })), !1;if (W) {
      if (!(e.file instanceof HTMLInputElement || Ce(e.file))) return Le(e.file) && 'undefined' !== typeof uni ? !!Ce(e.file.tempFile) || (console.warn(vt({ api: 'createVideoMessage', param: 'payload.file', desc: '您没有选择文件，无法发送' })), !1) : (console.warn(vt({ api: 'createVideoMessage', param: 'payload.file', desc: '类型必须是 HTMLInputElement 或 File' })), !1);if (e.file instanceof HTMLInputElement && 0 === e.file.files.length) return console.warn(vt({ api: 'createVideoMessage', param: 'payload.file', desc: '您没有选择文件，无法发送' })), !1
    } return !0
  } }), onProgress: { type: 'Function', required: !1, validator(e) {
    return Ge(e) && console.warn(vt({ api: 'createVideoMessage', desc: '没有 onProgress 回调，您将无法获取上传进度' })), !0
  } } }, createFaceMessage: { to: yt, conversationType: yt, payload: t(t({}, Dt), {}, { validator(e) {
    return Le(e) ? Ne(e.index) ? !!Ae(e.data) || (console.warn(vt({ api: 'createFaceMessage', param: 'payload.data', desc: '类型必须为 String' })), !1) : (console.warn(vt({ api: 'createFaceMessage', param: 'payload.index', desc: '类型必须为 Number' })), !1) : (console.warn(vt({ api: 'createFaceMessage', param: 'payload', desc: '类型必须为 plain object' })), !1)
  } }) }, createFileMessage: { to: yt, conversationType: yt, payload: t(t({}, Dt), {}, { validator(e) {
    if (!Le(e)) return console.warn(vt({ api: 'createFileMessage', param: 'payload', desc: '类型必须为 plain object' })), !1;if (Ge(e.file)) return console.warn(vt({ api: 'createFileMessage', param: 'payload.file', desc: '不能为 undefined' })), !1;if (W) {
      if (!(e.file instanceof HTMLInputElement || Ce(e.file))) return Le(e.file) && 'undefined' !== typeof uni ? 0 !== e.file.tempFilePaths.length && 0 !== e.file.tempFiles.length || (console.warn(vt({ api: 'createFileMessage', param: 'payload.file', desc: '您没有选择文件，无法发送' })), !1) : (console.warn(vt({ api: 'createFileMessage', param: 'payload.file', desc: '类型必须是 HTMLInputElement 或 File' })), !1);if (e.file instanceof HTMLInputElement && 0 === e.file.files.length) return console.warn(vt({ api: 'createFileMessage', desc: '您没有选择文件，无法发送' })), !1
    } return !0
  } }), onProgress: { type: 'Function', required: !1, validator(e) {
    return Ge(e) && console.warn(vt({ api: 'createFileMessage', desc: '没有 onProgress 回调，您将无法获取上传进度' })), !0
  } } }, createMergerMessage: { to: yt, conversationType: yt, payload: t(t({}, Dt), {}, { validator(e) {
    if (dt(e.messageList)) return console.warn(vt({ api: 'createMergerMessage', desc: '不能为空数组' })), !1;if (dt(e.compatibleText)) return console.warn(vt({ api: 'createMergerMessage', desc: '类型必须为 String，且不能为空' })), !1;let t = !1;return e.messageList.forEach(((e) => {
      e.status === _t.FAIL && (t = !0)
    })), !t || (console.warn(vt({ api: 'createMergerMessage', desc: '不支持合并已发送失败的消息' })), !1)
  } }) }, revokeMessage: [t(t({ name: 'message' }, Dt), {}, { validator(e) {
    return dt(e) ? (console.warn('revokeMessage 请传入消息（Message）实例'), !1) : e.conversationType === k.CONV_SYSTEM ? (console.warn('revokeMessage 不能撤回系统会话消息，只能撤回单聊消息或群消息'), !1) : !0 !== e.isRevoked || (console.warn('revokeMessage 消息已经被撤回，请勿重复操作'), !1)
  } })], deleteMessage: [t(t({ name: 'messageList' }, It), {}, { validator(e) {
    return !dt(e) || (console.warn(vt({ api: 'deleteMessage', param: 'messageList', desc: '不能为空数组' })), !1)
  } })], getUserProfile: { userIDList: { type: 'Array', validator(e) {
    return Re(e) ? (0 === e.length && console.warn(vt({ api: 'getUserProfile', param: 'userIDList', desc: '不能为空数组' })), !0) : (console.warn(vt({ api: 'getUserProfile', param: 'userIDList', desc: '必须为数组' })), !1)
  } } }, updateMyProfile: { profileCustomField: { type: 'Array', validator(e) {
    return !!Ge(e) || (!!Re(e) || (console.warn(vt({ api: 'updateMyProfile', param: 'profileCustomField', desc: '必须为数组' })), !1))
  } } }, addFriend: { to: yt, source: { type: 'String', required: !0, validator(e) {
    return !!e && (e.startsWith('AddSource_Type_') ? !(e.replace('AddSource_Type_', '').length > 8) || (console.warn(vt({ api: 'addFriend', desc: '加好友来源字段的关键字长度不得超过8字节' })), !1) : (console.warn(vt({ api: 'addFriend', desc: '加好友来源字段的前缀必须是：AddSource_Type_' })), !1))
  } }, remark: { type: 'String', required: !1, validator(e) {
    return !(Ae(e) && e.length > 96) || (console.warn(vt({ api: 'updateFriend', desc: ' 备注长度最长不得超过 96 个字节' })), !1)
  } } }, deleteFriend: { userIDList: It }, checkFriend: { userIDList: It }, getFriendProfile: { userIDList: It }, updateFriend: { userID: yt, remark: { type: 'String', required: !1, validator(e) {
    return !(Ae(e) && e.length > 96) || (console.warn(vt({ api: 'updateFriend', desc: ' 备注长度最长不得超过 96 个字节' })), !1)
  } }, friendCustomField: { type: 'Array', required: !1, validator(e) {
    if (e) {
      if (!Re(e)) return console.warn(vt({ api: 'updateFriend', param: 'friendCustomField', desc: '必须为数组' })), !1;let t = !0;return e.forEach(((e) => (Ae(e.key) && -1 !== e.key.indexOf('Tag_SNS_Custom') ? Ae(e.value) ? e.value.length > 8 ? (console.warn(vt({ api: 'updateFriend', desc: '好友自定义字段的关键字长度不得超过8字节' })), t = !1) : void 0 : (console.warn(vt({ api: 'updateFriend', desc: '类型必须为 String' })), t = !1) : (console.warn(vt({ api: 'updateFriend', desc: '好友自定义字段的前缀必须是 Tag_SNS_Custom' })), t = !1)))), t
    } return !0
  } } }, acceptFriendApplication: { userID: yt }, refuseFriendApplication: { userID: yt }, deleteFriendApplication: { userID: yt }, createFriendGroup: { name: yt }, deleteFriendGroup: { name: yt }, addToFriendGroup: { name: yt, userIDList: It }, removeFromFriendGroup: { name: yt, userIDList: It }, renameFriendGroup: { oldName: yt, newName: yt } }; const St = { login: 'login', logout: 'logout', on: 'on', once: 'once', off: 'off', setLogLevel: 'setLogLevel', registerPlugin: 'registerPlugin', destroy: 'destroy', createTextMessage: 'createTextMessage', createTextAtMessage: 'createTextAtMessage', createImageMessage: 'createImageMessage', createAudioMessage: 'createAudioMessage', createVideoMessage: 'createVideoMessage', createCustomMessage: 'createCustomMessage', createFaceMessage: 'createFaceMessage', createFileMessage: 'createFileMessage', createMergerMessage: 'createMergerMessage', downloadMergerMessage: 'downloadMergerMessage', createForwardMessage: 'createForwardMessage', sendMessage: 'sendMessage', resendMessage: 'resendMessage', getMessageList: 'getMessageList', setMessageRead: 'setMessageRead', revokeMessage: 'revokeMessage', deleteMessage: 'deleteMessage', getConversationList: 'getConversationList', getConversationProfile: 'getConversationProfile', deleteConversation: 'deleteConversation', getGroupList: 'getGroupList', getGroupProfile: 'getGroupProfile', createGroup: 'createGroup', joinGroup: 'joinGroup', updateGroupProfile: 'updateGroupProfile', quitGroup: 'quitGroup', dismissGroup: 'dismissGroup', changeGroupOwner: 'changeGroupOwner', searchGroupByID: 'searchGroupByID', setMessageRemindType: 'setMessageRemindType', handleGroupApplication: 'handleGroupApplication', getGroupMemberProfile: 'getGroupMemberProfile', getGroupMemberList: 'getGroupMemberList', addGroupMember: 'addGroupMember', deleteGroupMember: 'deleteGroupMember', setGroupMemberNameCard: 'setGroupMemberNameCard', setGroupMemberMuteTime: 'setGroupMemberMuteTime', setGroupMemberRole: 'setGroupMemberRole', setGroupMemberCustomField: 'setGroupMemberCustomField', getGroupOnlineMemberCount: 'getGroupOnlineMemberCount', getMyProfile: 'getMyProfile', getUserProfile: 'getUserProfile', updateMyProfile: 'updateMyProfile', getBlacklist: 'getBlacklist', addToBlacklist: 'addToBlacklist', removeFromBlacklist: 'removeFromBlacklist', getFriendList: 'getFriendList', addFriend: 'addFriend', deleteFriend: 'deleteFriend', checkFriend: 'checkFriend', updateFriend: 'updateFriend', getFriendProfile: 'getFriendProfile', getFriendApplicationList: 'getFriendApplicationList', refuseFriendApplication: 'refuseFriendApplication', deleteFriendApplication: 'deleteFriendApplication', acceptFriendApplication: 'acceptFriendApplication', setFriendApplicationRead: 'setFriendApplicationRead', getFriendGroupList: 'getFriendGroupList', createFriendGroup: 'createFriendGroup', renameFriendGroup: 'renameFriendGroup', deleteFriendGroup: 'deleteFriendGroup', addToFriendGroup: 'addToFriendGroup', removeFromFriendGroup: 'removeFromFriendGroup', callExperimentalAPI: 'callExperimentalAPI' }; const Et = 'sign'; const kt = 'message'; const Ct = 'user'; const Nt = 'c2c'; const At = 'group'; const Ot = 'sns'; const Lt = 'groupMember'; const Rt = 'conversation'; const Gt = 'context'; const wt = 'storage'; const Pt = 'eventStat'; const bt = 'netMonitor'; const Ut = 'bigDataChannel'; const Ft = 'upload'; const qt = 'plugin'; const Vt = 'syncUnreadMessage'; const Kt = 'session'; const xt = 'channel'; const Bt = 'message_loss_detection'; const Ht = 'cloudControl'; const jt = 'pullGroupMessage'; const $t = 'qualityStat'; const Yt = (function () {
    function e(t) {
      o(this, e), this._moduleManager = t, this._className = ''
    } return s(e, [{ key: 'isLoggedIn', value() {
      return this._moduleManager.getModule(Gt).isLoggedIn()
    } }, { key: 'isOversea', value() {
      return this._moduleManager.getModule(Gt).isOversea()
    } }, { key: 'getMyUserID', value() {
      return this._moduleManager.getModule(Gt).getUserID()
    } }, { key: 'getModule', value(e) {
      return this._moduleManager.getModule(e)
    } }, { key: 'getPlatform', value() {
      return X
    } }, { key: 'getNetworkType', value() {
      return this._moduleManager.getModule(bt).getNetworkType()
    } }, { key: 'probeNetwork', value() {
      return this._moduleManager.getModule(bt).probe()
    } }, { key: 'getCloudConfig', value(e) {
      return this._moduleManager.getModule(Ht).getCloudConfig(e)
    } }, { key: 'emitOuterEvent', value(e, t) {
      this._moduleManager.getOuterEmitterInstance().emit(e, t)
    } }, { key: 'emitInnerEvent', value(e, t) {
      this._moduleManager.getInnerEmitterInstance().emit(e, t)
    } }, { key: 'getInnerEmitterInstance', value() {
      return this._moduleManager.getInnerEmitterInstance()
    } }, { key: 'generateTjgID', value(e) {
      return `${this._moduleManager.getModule(Gt).getTinyID()}-${e.random}`
    } }, { key: 'filterModifiedMessage', value(e) {
      if (!dt(e)) {
        const t = e.filter(((e) => !0 === e.isModified));t.length > 0 && this.emitOuterEvent(E.MESSAGE_MODIFIED, t)
      }
    } }, { key: 'filterUnmodifiedMessage', value(e) {
      return dt(e) ? [] : e.filter(((e) => !1 === e.isModified))
    } }, { key: 'request', value(e) {
      return this._moduleManager.getModule(Kt).request(e)
    } }]), e
  }()); const zt = 'wslogin'; const Wt = 'wslogout'; const Jt = 'wshello'; const Xt = 'getmsg'; const Qt = 'authkey'; const Zt = 'sendmsg'; const en = 'send_group_msg'; const tn = 'portrait_get_all'; const nn = 'portrait_set'; const on = 'black_list_get'; const an = 'black_list_add'; const sn = 'black_list_delete'; const rn = 'msgwithdraw'; const cn = 'msgreaded'; const un = 'getroammsg'; const ln = 'get_peer_read_time'; const dn = 'delete_c2c_msg_ramble'; const gn = 'page_get'; const pn = 'get'; const hn = 'delete'; const _n = 'deletemsg'; const fn = 'get_joined_group_list'; const mn = 'get_group_info'; const Mn = 'create_group'; const vn = 'destroy_group'; const yn = 'modify_group_base_info'; const In = 'apply_join_group'; const Dn = 'apply_join_group_noauth'; const Tn = 'quit_group'; const Sn = 'get_group_public_info'; const En = 'change_group_owner'; const kn = 'handle_apply_join_group'; const Cn = 'handle_invite_join_group'; const Nn = 'group_msg_recall'; const An = 'msg_read_report'; const On = 'group_msg_get'; const Ln = 'get_pendency'; const Rn = 'deletemsg'; const Gn = 'get_msg'; const wn = 'get_msg_noauth'; const Pn = 'get_online_member_num'; const bn = 'delete_group_ramble_msg_by_seq'; const Un = 'get_group_member_info'; const Fn = 'get_specified_group_member_info'; const qn = 'add_group_member'; const Vn = 'delete_group_member'; const Kn = 'modify_group_member_info'; const xn = 'cos'; const Bn = 'pre_sig'; const Hn = 'tim_web_report_v2'; const jn = 'alive'; const $n = 'msg_push'; const Yn = 'ws_msg_push_ack'; const zn = 'stat_forceoffline'; const Wn = 'save_relay_json_msg'; const Jn = 'get_relay_json_msg'; const Xn = 'fetch_config'; const Qn = 'push_configv2'; const Zn = { NO_SDKAPPID: 2e3, NO_ACCOUNT_TYPE: 2001, NO_IDENTIFIER: 2002, NO_USERSIG: 2003, NO_TINYID: 2022, NO_A2KEY: 2023, USER_NOT_LOGGED_IN: 2024, COS_UNDETECTED: 2040, COS_GET_SIG_FAIL: 2041, MESSAGE_SEND_FAIL: 2100, MESSAGE_LIST_CONSTRUCTOR_NEED_OPTIONS: 2103, MESSAGE_SEND_NEED_MESSAGE_INSTANCE: 2105, MESSAGE_SEND_INVALID_CONVERSATION_TYPE: 2106, MESSAGE_FILE_IS_EMPTY: 2108, MESSAGE_ONPROGRESS_FUNCTION_ERROR: 2109, MESSAGE_REVOKE_FAIL: 2110, MESSAGE_DELETE_FAIL: 2111, MESSAGE_IMAGE_SELECT_FILE_FIRST: 2251, MESSAGE_IMAGE_TYPES_LIMIT: 2252, MESSAGE_IMAGE_SIZE_LIMIT: 2253, MESSAGE_AUDIO_UPLOAD_FAIL: 2300, MESSAGE_AUDIO_SIZE_LIMIT: 2301, MESSAGE_VIDEO_UPLOAD_FAIL: 2350, MESSAGE_VIDEO_SIZE_LIMIT: 2351, MESSAGE_VIDEO_TYPES_LIMIT: 2352, MESSAGE_FILE_UPLOAD_FAIL: 2400, MESSAGE_FILE_SELECT_FILE_FIRST: 2401, MESSAGE_FILE_SIZE_LIMIT: 2402, MESSAGE_FILE_URL_IS_EMPTY: 2403, MESSAGE_MERGER_TYPE_INVALID: 2450, MESSAGE_MERGER_KEY_INVALID: 2451, MESSAGE_MERGER_DOWNLOAD_FAIL: 2452, MESSAGE_FORWARD_TYPE_INVALID: 2453, CONVERSATION_NOT_FOUND: 2500, USER_OR_GROUP_NOT_FOUND: 2501, CONVERSATION_UN_RECORDED_TYPE: 2502, ILLEGAL_GROUP_TYPE: 2600, CANNOT_JOIN_WORK: 2601, CANNOT_CHANGE_OWNER_IN_AVCHATROOM: 2620, CANNOT_CHANGE_OWNER_TO_SELF: 2621, CANNOT_DISMISS_Work: 2622, MEMBER_NOT_IN_GROUP: 2623, JOIN_GROUP_FAIL: 2660, CANNOT_ADD_MEMBER_IN_AVCHATROOM: 2661, CANNOT_JOIN_NON_AVCHATROOM_WITHOUT_LOGIN: 2662, CANNOT_KICK_MEMBER_IN_AVCHATROOM: 2680, NOT_OWNER: 2681, CANNOT_SET_MEMBER_ROLE_IN_WORK_AND_AVCHATROOM: 2682, INVALID_MEMBER_ROLE: 2683, CANNOT_SET_SELF_MEMBER_ROLE: 2684, CANNOT_MUTE_SELF: 2685, NOT_MY_FRIEND: 2700, ALREADY_MY_FRIEND: 2701, FRIEND_GROUP_EXISTED: 2710, FRIEND_GROUP_NOT_EXIST: 2711, FRIEND_APPLICATION_NOT_EXIST: 2716, UPDATE_PROFILE_INVALID_PARAM: 2721, UPDATE_PROFILE_NO_KEY: 2722, ADD_BLACKLIST_INVALID_PARAM: 2740, DEL_BLACKLIST_INVALID_PARAM: 2741, CANNOT_ADD_SELF_TO_BLACKLIST: 2742, ADD_FRIEND_INVALID_PARAM: 2760, NETWORK_ERROR: 2800, NETWORK_TIMEOUT: 2801, NETWORK_BASE_OPTIONS_NO_URL: 2802, NETWORK_UNDEFINED_SERVER_NAME: 2803, NETWORK_PACKAGE_UNDEFINED: 2804, NO_NETWORK: 2805, CONVERTOR_IRREGULAR_PARAMS: 2900, NOTICE_RUNLOOP_UNEXPECTED_CONDITION: 2901, NOTICE_RUNLOOP_OFFSET_LOST: 2902, UNCAUGHT_ERROR: 2903, GET_LONGPOLL_ID_FAILED: 2904, INVALID_OPERATION: 2905, CANNOT_FIND_PROTOCOL: 2997, CANNOT_FIND_MODULE: 2998, SDK_IS_NOT_READY: 2999, LONG_POLL_KICK_OUT: 91101, MESSAGE_A2KEY_EXPIRED: 20002, ACCOUNT_A2KEY_EXPIRED: 70001, LONG_POLL_API_PARAM_ERROR: 90001, HELLO_ANSWER_KICKED_OUT: 1002 }; const eo = '无 SDKAppID'; const to = '无 userID'; const no = '无 userSig'; const oo = '无 tinyID'; const ao = '无 a2key'; const so = '用户未登录'; const ro = '未检测到 COS 上传插件'; const io = '获取 COS 预签名 URL 失败'; const co = '消息发送失败'; const uo = '需要 Message 的实例'; const lo = 'Message.conversationType 只能为 "C2C" 或 "GROUP"'; const go = '无法发送空文件'; const po = '回调函数运行时遇到错误，请检查接入侧代码'; const ho = '消息撤回失败'; const _o = '消息删除失败'; const fo = '请先选择一个图片'; const mo = '只允许上传 jpg png jpeg gif bmp格式的图片'; const Mo = '图片大小超过20M，无法发送'; const vo = '语音上传失败'; const yo = '语音大小大于20M，无法发送'; const Io = '视频上传失败'; const Do = '视频大小超过100M，无法发送'; const To = '只允许上传 mp4 格式的视频'; const So = '文件上传失败'; const Eo = '请先选择一个文件'; const ko = '文件大小超过100M，无法发送 '; const Co = '缺少必要的参数文件 URL'; const No = '非合并消息'; const Ao = '合并消息的 messageKey 无效'; const Oo = '下载合并消息失败'; const Lo = '选择的消息类型（如群提示消息）不可以转发'; const Ro = '没有找到相应的会话，请检查传入参数'; const Go = '没有找到相应的用户或群组，请检查传入参数'; const wo = '未记录的会话类型'; const Po = '非法的群类型，请检查传入参数'; const bo = '不能加入 Work 类型的群组'; const Uo = 'AVChatRoom 类型的群组不能转让群主'; const Fo = '不能把群主转让给自己'; const qo = '不能解散 Work 类型的群组'; const Vo = '用户不在该群组内'; const Ko = '加群失败，请检查传入参数或重试'; const xo = 'AVChatRoom 类型的群不支持邀请群成员'; const Bo = '非 AVChatRoom 类型的群组不允许匿名加群，请先登录后再加群'; const Ho = '不能在 AVChatRoom 类型的群组踢人'; const jo = '你不是群主，只有群主才有权限操作'; const $o = '不能在 Work / AVChatRoom 类型的群中设置群成员身份'; const Yo = '不合法的群成员身份，请检查传入参数'; const zo = '不能设置自己的群成员身份，请检查传入参数'; const Wo = '不能将自己禁言，请检查传入参数'; const Jo = '传入 updateMyProfile 接口的参数无效'; const Xo = 'updateMyProfile 无标配资料字段或自定义资料字段'; const Qo = '传入 addToBlacklist 接口的参数无效'; const Zo = '传入 removeFromBlacklist 接口的参数无效'; const ea = '不能拉黑自己'; const ta = '网络错误'; const na = '请求超时'; const oa = '未连接到网络'; const aa = '无效操作，如调用了未定义或者未实现的方法等'; const sa = '无法找到协议'; const ra = '无法找到模块'; const ia = '接口需要 SDK 处于 ready 状态后才能调用'; const ca = 'upload'; const ua = 'networkRTT'; const la = 'messageE2EDelay'; const da = 'sendMessageC2C'; const ga = 'sendMessageGroup'; const pa = 'sendMessageGroupAV'; const ha = 'sendMessageRichMedia'; const _a = 'cosUpload'; const fa = 'messageReceivedGroup'; const ma = 'messageReceivedGroupAVPush'; const Ma = 'messageReceivedGroupAVPull'; const va = (r(ht = {}, ua, 2), r(ht, la, 3), r(ht, da, 4), r(ht, ga, 5), r(ht, pa, 6), r(ht, ha, 7), r(ht, fa, 8), r(ht, ma, 9), r(ht, Ma, 10), r(ht, _a, 11), ht); const ya = { info: 4, warning: 5, error: 6 }; const Ia = { wifi: 1, '2g': 2, '3g': 3, '4g': 4, '5g': 5, unknown: 6, none: 7, online: 8 }; const Da = (function () {
    function e(t) {
      o(this, e), this.eventType = 0, this.timestamp = 0, this.networkType = 8, this.code = 0, this.message = '', this.moreMessage = '', this.extension = t, this.costTime = 0, this.duplicate = !1, this.level = 4, this._sentFlag = !1, this._startts = ye()
    } return s(e, [{ key: 'updateTimeStamp', value() {
      this.timestamp = ye()
    } }, { key: 'start', value(e) {
      return this._startts = e, this
    } }, { key: 'end', value() {
      const e = this; const t = arguments.length > 0 && void 0 !== arguments[0] && arguments[0];if (!this._sentFlag) {
        const n = ye();this.costTime = n - this._startts, this.setMoreMessage('host:'.concat(st(), ' startts:').concat(this._startts, ' endts:')
          .concat(n)), t ? (this._sentFlag = !0, this._eventStatModule && this._eventStatModule.pushIn(this)) : setTimeout((() => {
          e._sentFlag = !0, e._eventStatModule && e._eventStatModule.pushIn(e)
        }), 0)
      }
    } }, { key: 'setError', value(e, t, n) {
      return e instanceof Error ? (this._sentFlag || (this.setNetworkType(n), t ? (e.code && this.setCode(e.code), e.message && this.setMoreMessage(e.message)) : (this.setCode(Zn.NO_NETWORK), this.setMoreMessage(oa)), this.setLevel('error')), this) : (Ee.warn('SSOLogData.setError value not instanceof Error, please check!'), this)
    } }, { key: 'setCode', value(e) {
      return Ge(e) || this._sentFlag || ('ECONNABORTED' === e && (this.code = 103), Ne(e) ? this.code = e : Ee.warn('SSOLogData.setCode value not a number, please check!', e, n(e))), this
    } }, { key: 'setMessage', value(e) {
      return Ge(e) || this._sentFlag || (Ne(e) && (this.message = e.toString()), Ae(e) && (this.message = e)), this
    } }, { key: 'setLevel', value(e) {
      return Ge(e) || this._sentFlag || (this.level = ya[e]), this
    } }, { key: 'setMoreMessage', value(e) {
      return dt(this.moreMessage) ? this.moreMessage = ''.concat(e) : this.moreMessage += ' '.concat(e), this
    } }, { key: 'setNetworkType', value(e) {
      return Ge(e) || Ge(Ia[e]) ? Ee.warn('SSOLogData.setNetworkType value is undefined, please check!') : this.networkType = Ia[e], this
    } }, { key: 'getStartTs', value() {
      return this._startts
    } }], [{ key: 'bindEventStatModule', value(t) {
      e.prototype._eventStatModule = t
    } }]), e
  }()); const Ta = 'sdkConstruct'; const Sa = 'sdkReady'; const Ea = 'login'; const ka = 'logout'; const Ca = 'kickedOut'; const Na = 'registerPlugin'; const Aa = 'wsConnect'; const Oa = 'wsOnOpen'; const La = 'wsOnClose'; const Ra = 'wsOnError'; const Ga = 'getCosAuthKey'; const wa = 'getCosPreSigUrl'; const Pa = 'upload'; const ba = 'sendMessage'; const Ua = 'getC2CRoamingMessages'; const Fa = 'getGroupRoamingMessages'; const qa = 'revokeMessage'; const Va = 'deleteMessage'; const Ka = 'setC2CMessageRead'; const xa = 'setGroupMessageRead'; const Ba = 'emptyMessageBody'; const Ha = 'getPeerReadTime'; const ja = 'uploadMergerMessage'; const $a = 'downloadMergerMessage'; const Ya = 'jsonParseError'; const za = 'messageE2EDelayException'; const Wa = 'getConversationList'; const Ja = 'getConversationProfile'; const Xa = 'deleteConversation'; const Qa = 'getConversationListInStorage'; const Za = 'syncConversationList'; const es = 'createGroup'; const ts = 'applyJoinGroup'; const ns = 'quitGroup'; const os = 'searchGroupByID'; const as = 'changeGroupOwner'; const ss = 'handleGroupApplication'; const rs = 'handleGroupInvitation'; const is = 'setMessageRemindType'; const cs = 'dismissGroup'; const us = 'updateGroupProfile'; const ls = 'getGroupList'; const ds = 'getGroupProfile'; const gs = 'getGroupListInStorage'; const ps = 'getGroupLastSequence'; const hs = 'getGroupMissingMessage'; const _s = 'pagingGetGroupList'; const fs = 'getGroupSimplifiedInfo'; const ms = 'joinWithoutAuth'; const Ms = 'getGroupMemberList'; const vs = 'getGroupMemberProfile'; const ys = 'addGroupMember'; const Is = 'deleteGroupMember'; const Ds = 'setGroupMemberMuteTime'; const Ts = 'setGroupMemberNameCard'; const Ss = 'setGroupMemberRole'; const Es = 'setGroupMemberCustomField'; const ks = 'getGroupOnlineMemberCount'; const Cs = 'longPollingAVError'; const Ns = 'messageLoss'; const As = 'messageStacked'; const Os = 'getUserProfile'; const Ls = 'updateMyProfile'; const Rs = 'getBlacklist'; const Gs = 'addToBlacklist'; const ws = 'removeFromBlacklist'; const Ps = 'callbackFunctionError'; const bs = 'fetchCloudControlConfig'; const Us = 'pushedCloudControlConfig'; const Fs = 'error'; const qs = (function () {
    function e(t) {
      o(this, e), this.type = k.MSG_TEXT, this.content = { text: t.text || '' }
    } return s(e, [{ key: 'setText', value(e) {
      this.content.text = e
    } }, { key: 'sendable', value() {
      return 0 !== this.content.text.length
    } }]), e
  }()); const Vs = { JSON: { TYPE: { C2C: { NOTICE: 1, COMMON: 9, EVENT: 10 }, GROUP: { COMMON: 3, TIP: 4, SYSTEM: 5, TIP2: 6 }, FRIEND: { NOTICE: 7 }, PROFILE: { NOTICE: 8 } }, SUBTYPE: { C2C: { COMMON: 0, READED: 92, KICKEDOUT: 96 }, GROUP: { COMMON: 0, LOVEMESSAGE: 1, TIP: 2, REDPACKET: 3 } }, OPTIONS: { GROUP: { JOIN: 1, QUIT: 2, KICK: 3, SET_ADMIN: 4, CANCEL_ADMIN: 5, MODIFY_GROUP_INFO: 6, MODIFY_MEMBER_INFO: 7 } } }, PROTOBUF: {}, IMAGE_TYPES: { ORIGIN: 1, LARGE: 2, SMALL: 3 }, IMAGE_FORMAT: { JPG: 1, JPEG: 1, GIF: 2, PNG: 3, BMP: 4, UNKNOWN: 255 } }; const Ks = { NICK: 'Tag_Profile_IM_Nick', GENDER: 'Tag_Profile_IM_Gender', BIRTHDAY: 'Tag_Profile_IM_BirthDay', LOCATION: 'Tag_Profile_IM_Location', SELFSIGNATURE: 'Tag_Profile_IM_SelfSignature', ALLOWTYPE: 'Tag_Profile_IM_AllowType', LANGUAGE: 'Tag_Profile_IM_Language', AVATAR: 'Tag_Profile_IM_Image', MESSAGESETTINGS: 'Tag_Profile_IM_MsgSettings', ADMINFORBIDTYPE: 'Tag_Profile_IM_AdminForbidType', LEVEL: 'Tag_Profile_IM_Level', ROLE: 'Tag_Profile_IM_Role' }; const xs = { UNKNOWN: 'Gender_Type_Unknown', FEMALE: 'Gender_Type_Female', MALE: 'Gender_Type_Male' }; const Bs = { NONE: 'AdminForbid_Type_None', SEND_OUT: 'AdminForbid_Type_SendOut' }; const Hs = { NEED_CONFIRM: 'AllowType_Type_NeedConfirm', ALLOW_ANY: 'AllowType_Type_AllowAny', DENY_ANY: 'AllowType_Type_DenyAny' }; const js = 'JoinedSuccess'; const $s = 'WaitAdminApproval'; const Ys = (function () {
    function e(t) {
      o(this, e), this._imageMemoryURL = '', z ? this.createImageDataASURLInWXMiniApp(t.file) : this.createImageDataASURLInWeb(t.file), this._initImageInfoModel(), this.type = k.MSG_IMAGE, this._percent = 0, this.content = { imageFormat: t.imageFormat || Vs.IMAGE_FORMAT.UNKNOWN, uuid: t.uuid, imageInfoArray: [] }, this.initImageInfoArray(t.imageInfoArray), this._defaultImage = 'http://imgcache.qq.com/open/qcloud/video/act/webim-images/default.jpg', this._autoFixUrl()
    } return s(e, [{ key: '_initImageInfoModel', value() {
      const e = this;this._ImageInfoModel = function (t) {
        this.instanceID = He(9999999), this.sizeType = t.type || 0, this.type = 0, this.size = t.size || 0, this.width = t.width || 0, this.height = t.height || 0, this.imageUrl = t.url || '', this.url = t.url || e._imageMemoryURL || e._defaultImage
      }, this._ImageInfoModel.prototype = { setSizeType(e) {
        this.sizeType = e
      }, setType(e) {
        this.type = e
      }, setImageUrl(e) {
        e && (this.imageUrl = e)
      }, getImageUrl() {
        return this.imageUrl
      } }
    } }, { key: 'initImageInfoArray', value(e) {
      for (let t = 0, n = null, o = null;t <= 2;)o = Ge(e) || Ge(e[t]) ? { type: 0, size: 0, width: 0, height: 0, url: '' } : e[t], (n = new this._ImageInfoModel(o)).setSizeType(t + 1), n.setType(t), this.addImageInfo(n), t++;this.updateAccessSideImageInfoArray()
    } }, { key: 'updateImageInfoArray', value(e) {
      for (var t, n = this.content.imageInfoArray.length, o = 0;o < n;o++)t = this.content.imageInfoArray[o], e[o].size && (t.size = e[o].size), e[o].url && t.setImageUrl(e[o].url), e[o].width && (t.width = e[o].width), e[o].height && (t.height = e[o].height)
    } }, { key: '_autoFixUrl', value() {
      for (let e = this.content.imageInfoArray.length, t = '', n = '', o = ['http', 'https'], a = null, s = 0;s < e;s++) this.content.imageInfoArray[s].url && '' !== (a = this.content.imageInfoArray[s]).imageUrl && (n = a.imageUrl.slice(0, a.imageUrl.indexOf('://') + 1), t = a.imageUrl.slice(a.imageUrl.indexOf('://') + 1), o.indexOf(n) < 0 && (n = 'https:'), this.content.imageInfoArray[s].setImageUrl([n, t].join('')))
    } }, { key: 'updatePercent', value(e) {
      this._percent = e, this._percent > 1 && (this._percent = 1)
    } }, { key: 'updateImageFormat', value(e) {
      this.content.imageFormat = Vs.IMAGE_FORMAT[e.toUpperCase()] || Vs.IMAGE_FORMAT.UNKNOWN
    } }, { key: 'createImageDataASURLInWeb', value(e) {
      void 0 !== e && e.files.length > 0 && (this._imageMemoryURL = window.URL.createObjectURL(e.files[0]))
    } }, { key: 'createImageDataASURLInWXMiniApp', value(e) {
      e && e.url && (this._imageMemoryURL = e.url)
    } }, { key: 'replaceImageInfo', value(e, t) {
      this.content.imageInfoArray[t] instanceof this._ImageInfoModel || (this.content.imageInfoArray[t] = e)
    } }, { key: 'addImageInfo', value(e) {
      this.content.imageInfoArray.length >= 3 || this.content.imageInfoArray.push(e)
    } }, { key: 'updateAccessSideImageInfoArray', value() {
      const e = this.content.imageInfoArray; const t = e[0]; const n = t.width; const o = void 0 === n ? 0 : n; const a = t.height; const s = void 0 === a ? 0 : a;0 !== o && 0 !== s && (it(e), Object.assign(e[2], rt({ originWidth: o, originHeight: s, min: 720 })))
    } }, { key: 'sendable', value() {
      return 0 !== this.content.imageInfoArray.length && ('' !== this.content.imageInfoArray[0].imageUrl && 0 !== this.content.imageInfoArray[0].size)
    } }]), e
  }()); const zs = (function () {
    function e(t) {
      o(this, e), this.type = k.MSG_FACE, this.content = t || null
    } return s(e, [{ key: 'sendable', value() {
      return null !== this.content
    } }]), e
  }()); const Ws = (function () {
    function e(t) {
      o(this, e), this.type = k.MSG_AUDIO, this._percent = 0, this.content = { downloadFlag: 2, second: t.second, size: t.size, url: t.url, remoteAudioUrl: t.url || '', uuid: t.uuid }
    } return s(e, [{ key: 'updatePercent', value(e) {
      this._percent = e, this._percent > 1 && (this._percent = 1)
    } }, { key: 'updateAudioUrl', value(e) {
      this.content.remoteAudioUrl = e
    } }, { key: 'sendable', value() {
      return '' !== this.content.remoteAudioUrl
    } }]), e
  }()); const Js = { from: !0, groupID: !0, groupName: !0, to: !0 }; const Xs = (function () {
    function e(t) {
      o(this, e), this.type = k.MSG_GRP_TIP, this.content = {}, this._initContent(t)
    } return s(e, [{ key: '_initContent', value(e) {
      const t = this;Object.keys(e).forEach(((n) => {
        switch (n) {
          case 'remarkInfo':break;case 'groupProfile':t.content.groupProfile = {}, t._initGroupProfile(e[n]);break;case 'operatorInfo':case 'memberInfoList':break;case 'msgMemberInfo':t.content.memberList = e[n], Object.defineProperty(t.content, 'msgMemberInfo', { get() {
            return Ee.warn('!!! 禁言的群提示消息中的 payload.msgMemberInfo 属性即将废弃，请使用 payload.memberList 属性替代。 \n', 'msgMemberInfo 中的 shutupTime 属性对应更改为 memberList 中的 muteTime 属性，表示禁言时长。 \n', '参考：群提示消息 https://web.sdk.qcloud.com/im/doc/zh-cn/Message.html#.GroupTipPayload'), t.content.memberList.map(((e) => ({ userID: e.userID, shutupTime: e.muteTime })))
          } });break;case 'onlineMemberInfo':break;case 'memberNum':t.content[n] = e[n], t.content.memberCount = e[n];break;default:t.content[n] = e[n]
        }
      })), this.content.userIDList || (this.content.userIDList = [this.content.operatorID])
    } }, { key: '_initGroupProfile', value(e) {
      for (let t = Object.keys(e), n = 0;n < t.length;n++) {
        const o = t[n];Js[o] && (this.content.groupProfile[o] = e[o])
      }
    } }]), e
  }()); const Qs = { from: !0, groupID: !0, groupName: !0, to: !0 }; const Zs = (function () {
    function e(t) {
      o(this, e), this.type = k.MSG_GRP_SYS_NOTICE, this.content = {}, this._initContent(t)
    } return s(e, [{ key: '_initContent', value(e) {
      const t = this;Object.keys(e).forEach(((n) => {
        switch (n) {
          case 'memberInfoList':break;case 'remarkInfo':t.content.handleMessage = e[n];break;case 'groupProfile':t.content.groupProfile = {}, t._initGroupProfile(e[n]);break;default:t.content[n] = e[n]
        }
      }))
    } }, { key: '_initGroupProfile', value(e) {
      for (let t = Object.keys(e), n = 0;n < t.length;n++) {
        const o = t[n];Qs[o] && ('groupName' === o ? this.content.groupProfile.name = e[o] : this.content.groupProfile[o] = e[o])
      }
    } }]), e
  }()); const er = (function () {
    function e(t) {
      o(this, e), this.type = k.MSG_FILE, this._percent = 0;const n = this._getFileInfo(t);this.content = { downloadFlag: 2, fileUrl: t.url || '', uuid: t.uuid, fileName: n.name || '', fileSize: n.size || 0 }
    } return s(e, [{ key: '_getFileInfo', value(e) {
      if (e.fileName && e.fileSize) return { size: e.fileSize, name: e.fileName };if (z) return {};const t = e.file.files[0];return { size: t.size, name: t.name, type: t.type.slice(t.type.lastIndexOf('/') + 1).toLowerCase() }
    } }, { key: 'updatePercent', value(e) {
      this._percent = e, this._percent > 1 && (this._percent = 1)
    } }, { key: 'updateFileUrl', value(e) {
      this.content.fileUrl = e
    } }, { key: 'sendable', value() {
      return '' !== this.content.fileUrl && ('' !== this.content.fileName && 0 !== this.content.fileSize)
    } }]), e
  }()); const tr = (function () {
    function e(t) {
      o(this, e), this.type = k.MSG_CUSTOM, this.content = { data: t.data || '', description: t.description || '', extension: t.extension || '' }
    } return s(e, [{ key: 'setData', value(e) {
      return this.content.data = e, this
    } }, { key: 'setDescription', value(e) {
      return this.content.description = e, this
    } }, { key: 'setExtension', value(e) {
      return this.content.extension = e, this
    } }, { key: 'sendable', value() {
      return 0 !== this.content.data.length || 0 !== this.content.description.length || 0 !== this.content.extension.length
    } }]), e
  }()); const nr = (function () {
    function e(t) {
      o(this, e), this.type = k.MSG_VIDEO, this._percent = 0, this.content = { remoteVideoUrl: t.remoteVideoUrl || t.videoUrl || '', videoFormat: t.videoFormat, videoSecond: parseInt(t.videoSecond, 10), videoSize: t.videoSize, videoUrl: t.videoUrl, videoDownloadFlag: 2, videoUUID: t.videoUUID, thumbUUID: t.thumbUUID, thumbFormat: t.thumbFormat, thumbWidth: t.thumbWidth, thumbHeight: t.thumbHeight, thumbSize: t.thumbSize, thumbDownloadFlag: 2, thumbUrl: t.thumbUrl }
    } return s(e, [{ key: 'updatePercent', value(e) {
      this._percent = e, this._percent > 1 && (this._percent = 1)
    } }, { key: 'updateVideoUrl', value(e) {
      e && (this.content.remoteVideoUrl = e)
    } }, { key: 'sendable', value() {
      return '' !== this.content.remoteVideoUrl
    } }]), e
  }()); const or = function e(t) {
    o(this, e), this.type = k.MSG_GEO, this.content = t
  }; const ar = (function () {
    function e(t) {
      if (o(this, e), this.from = t.from, this.messageSender = t.from, this.time = t.time, this.messageSequence = t.sequence, this.clientSequence = t.clientSequence || t.sequence, this.messageRandom = t.random, this.cloudCustomData = t.cloudCustomData || '', t.ID) this.nick = t.nick || '', this.avatar = t.avatar || '', this.messageBody = [{ type: t.type, payload: t.payload }], t.conversationType.startsWith(k.CONV_C2C) ? this.receiverUserID = t.to : t.conversationType.startsWith(k.CONV_GROUP) && (this.receiverGroupID = t.to), this.messageReceiver = t.to;else {
        this.nick = t.nick || '', this.avatar = t.avatar || '', this.messageBody = [];const n = t.elements[0].type; const a = t.elements[0].content;this._patchRichMediaPayload(n, a), n === k.MSG_MERGER ? this.messageBody.push({ type: n, payload: new sr(a).content }) : this.messageBody.push({ type: n, payload: a }), t.groupID && (this.receiverGroupID = t.groupID, this.messageReceiver = t.groupID), t.to && (this.receiverUserID = t.to, this.messageReceiver = t.to)
      }
    } return s(e, [{ key: '_patchRichMediaPayload', value(e, t) {
      e === k.MSG_IMAGE ? t.imageInfoArray.forEach(((e) => {
        !e.imageUrl && e.url && (e.imageUrl = e.url, e.sizeType = e.type, 1 === e.type ? e.type = 0 : 3 === e.type && (e.type = 1))
      })) : e === k.MSG_VIDEO ? !t.remoteVideoUrl && t.videoUrl && (t.remoteVideoUrl = t.videoUrl) : e === k.MSG_AUDIO ? !t.remoteAudioUrl && t.url && (t.remoteAudioUrl = t.url) : e === k.MSG_FILE && !t.fileUrl && t.url && (t.fileUrl = t.url, t.url = void 0)
    } }]), e
  }()); var sr = (function () {
    function e(t) {
      if (o(this, e), this.type = k.MSG_MERGER, this.content = { downloadKey: '', pbDownloadKey: '', messageList: [], title: '', abstractList: [], compatibleText: '', version: 0, layersOverLimit: !1 }, t.downloadKey) {
        const n = t.downloadKey; const a = t.pbDownloadKey; const s = t.title; const r = t.abstractList; const i = t.compatibleText; const c = t.version;this.content.downloadKey = n, this.content.pbDownloadKey = a, this.content.title = s, this.content.abstractList = r, this.content.compatibleText = i, this.content.version = c || 0
      } else if (dt(t.messageList))1 === t.layersOverLimit && (this.content.layersOverLimit = !0);else {
        const u = t.messageList; const l = t.title; const d = t.abstractList; const g = t.compatibleText; const p = t.version; const h = [];u.forEach(((e) => {
          if (!dt(e)) {
            const t = new ar(e);h.push(t)
          }
        })), this.content.messageList = h, this.content.title = l, this.content.abstractList = d, this.content.compatibleText = g, this.content.version = p || 0
      }Ee.debug('MergerElement.content:', this.content)
    } return s(e, [{ key: 'sendable', value() {
      return !dt(this.content.messageList) || !dt(this.content.downloadKey)
    } }]), e
  }()); const rr = { 1: k.MSG_PRIORITY_HIGH, 2: k.MSG_PRIORITY_NORMAL, 3: k.MSG_PRIORITY_LOW, 4: k.MSG_PRIORITY_LOWEST }; const ir = (function () {
    function e(t) {
      o(this, e), this.ID = '', this.conversationID = t.conversationID || null, this.conversationType = t.conversationType || k.CONV_C2C, this.conversationSubType = t.conversationSubType, this.time = t.time || Math.ceil(Date.now() / 1e3), this.sequence = t.sequence || 0, this.clientSequence = t.clientSequence || t.sequence || 0, this.random = t.random || 0 === t.random ? t.random : He(), this.priority = this._computePriority(t.priority), this.nick = t.nick || '', this.avatar = t.avatar || '', this.isPeerRead = !1, this.nameCard = '', this._elements = [], this.isPlaceMessage = t.isPlaceMessage || 0, this.isRevoked = 2 === t.isPlaceMessage || 8 === t.msgFlagBits, this.geo = {}, this.from = t.from || null, this.to = t.to || null, this.flow = '', this.isSystemMessage = t.isSystemMessage || !1, this.protocol = t.protocol || 'JSON', this.isResend = !1, this.isRead = !1, this.status = t.status || _t.SUCCESS, this._onlineOnlyFlag = !1, this._groupAtInfoList = [], this._relayFlag = !1, this.atUserList = [], this.cloudCustomData = t.cloudCustomData || '', this.isDeleted = !1, this.isModified = !1, this.reInitialize(t.currentUser), this.extractGroupInfo(t.groupProfile || null), this.handleGroupAtInfo(t)
    } return s(e, [{ key: 'elements', get() {
      return Ee.warn('！！！Message 实例的 elements 属性即将废弃，请尽快修改。使用 type 和 payload 属性处理单条消息，兼容组合消息使用 _elements 属性！！！'), this._elements
    } }, { key: 'getElements', value() {
      return this._elements
    } }, { key: 'extractGroupInfo', value(e) {
      if (null !== e) {
        Ae(e.nick) && (this.nick = e.nick), Ae(e.avatar) && (this.avatar = e.avatar);const t = e.messageFromAccountExtraInformation;Le(t) && Ae(t.nameCard) && (this.nameCard = t.nameCard)
      }
    } }, { key: 'handleGroupAtInfo', value(e) {
      const t = this;e.payload && e.payload.atUserList && e.payload.atUserList.forEach(((e) => {
        e !== k.MSG_AT_ALL ? (t._groupAtInfoList.push({ groupAtAllFlag: 0, groupAtUserID: e }), t.atUserList.push(e)) : (t._groupAtInfoList.push({ groupAtAllFlag: 1 }), t.atUserList.push(k.MSG_AT_ALL))
      })), Re(e.groupAtInfo) && e.groupAtInfo.forEach(((e) => {
        1 === e.groupAtAllFlag ? t.atUserList.push(e.groupAtUserID) : 2 === e.groupAtAllFlag && t.atUserList.push(k.MSG_AT_ALL)
      }))
    } }, { key: 'getGroupAtInfoList', value() {
      return this._groupAtInfoList
    } }, { key: '_initProxy', value() {
      this._elements[0] && (this.payload = this._elements[0].content, this.type = this._elements[0].type)
    } }, { key: 'reInitialize', value(e) {
      e && (this.status = this.from ? _t.SUCCESS : _t.UNSEND, !this.from && (this.from = e)), this._initFlow(e), this._initSequence(e), this._concatConversationID(e), this.generateMessageID(e)
    } }, { key: 'isSendable', value() {
      return 0 !== this._elements.length && ('function' !== typeof this._elements[0].sendable ? (Ee.warn(''.concat(this._elements[0].type, ' need "boolean : sendable()" method')), !1) : this._elements[0].sendable())
    } }, { key: '_initTo', value(e) {
      this.conversationType === k.CONV_GROUP && (this.to = e.groupID)
    } }, { key: '_initSequence', value(e) {
      0 === this.clientSequence && e && (this.clientSequence = (function (e) {
        if (!e) return Ee.error('autoIncrementIndex(string: key) need key parameter'), !1;if (void 0 === ze[e]) {
          const t = new Date; let n = '3'.concat(t.getHours()).slice(-2); let o = '0'.concat(t.getMinutes()).slice(-2); let a = '0'.concat(t.getSeconds()).slice(-2);ze[e] = parseInt([n, o, a, '0001'].join('')), n = null, o = null, a = null, Ee.log('autoIncrementIndex start index:'.concat(ze[e]))
        } return ze[e]++
      }(e))), 0 === this.sequence && this.conversationType === k.CONV_C2C && (this.sequence = this.clientSequence)
    } }, { key: 'generateMessageID', value(e) {
      const t = e === this.from ? 1 : 0; const n = this.sequence > 0 ? this.sequence : this.clientSequence;this.ID = ''.concat(this.conversationID, '-').concat(n, '-')
        .concat(this.random, '-')
        .concat(t)
    } }, { key: '_initFlow', value(e) {
      '' !== e && (e === this.from ? (this.flow = 'out', this.isRead = !0) : this.flow = 'in')
    } }, { key: '_concatConversationID', value(e) {
      const t = this.to; let n = ''; const o = this.conversationType;o !== k.CONV_SYSTEM ? (n = o === k.CONV_C2C ? e === this.from ? t : this.from : this.to, this.conversationID = ''.concat(o).concat(n)) : this.conversationID = k.CONV_SYSTEM
    } }, { key: 'isElement', value(e) {
      return e instanceof qs || e instanceof Ys || e instanceof zs || e instanceof Ws || e instanceof er || e instanceof nr || e instanceof Xs || e instanceof Zs || e instanceof tr || e instanceof or || e instanceof sr
    } }, { key: 'setElement', value(e) {
      const t = this;if (this.isElement(e)) return this._elements = [e], void this._initProxy();const n = function (e) {
        if (e.type && e.content) switch (e.type) {
          case k.MSG_TEXT:t.setTextElement(e.content);break;case k.MSG_IMAGE:t.setImageElement(e.content);break;case k.MSG_AUDIO:t.setAudioElement(e.content);break;case k.MSG_FILE:t.setFileElement(e.content);break;case k.MSG_VIDEO:t.setVideoElement(e.content);break;case k.MSG_CUSTOM:t.setCustomElement(e.content);break;case k.MSG_GEO:t.setGEOElement(e.content);break;case k.MSG_GRP_TIP:t.setGroupTipElement(e.content);break;case k.MSG_GRP_SYS_NOTICE:t.setGroupSystemNoticeElement(e.content);break;case k.MSG_FACE:t.setFaceElement(e.content);break;case k.MSG_MERGER:t.setMergerElement(e.content);break;default:Ee.warn(e.type, e.content, 'no operation......')
        }
      };if (Re(e)) for (let o = 0;o < e.length;o++)n(e[o]);else n(e);this._initProxy()
    } }, { key: 'clearElement', value() {
      this._elements.length = 0
    } }, { key: 'setTextElement', value(e) {
      const t = 'string' === typeof e ? e : e.text; const n = new qs({ text: t });this._elements.push(n)
    } }, { key: 'setImageElement', value(e) {
      const t = new Ys(e);this._elements.push(t)
    } }, { key: 'setAudioElement', value(e) {
      const t = new Ws(e);this._elements.push(t)
    } }, { key: 'setFileElement', value(e) {
      const t = new er(e);this._elements.push(t)
    } }, { key: 'setVideoElement', value(e) {
      const t = new nr(e);this._elements.push(t)
    } }, { key: 'setGEOElement', value(e) {
      const t = new or(e);this._elements.push(t)
    } }, { key: 'setCustomElement', value(e) {
      const t = new tr(e);this._elements.push(t)
    } }, { key: 'setGroupTipElement', value(e) {
      let t = {}; const n = e.operationType;dt(e.memberInfoList) ? e.operatorInfo && (t = e.operatorInfo) : n !== k.GRP_TIP_MBR_JOIN && n !== k.GRP_TIP_MBR_KICKED_OUT && n !== k.GRP_TIP_MBR_SET_ADMIN && n !== k.GRP_TIP_MBR_CANCELED_ADMIN || (t = e.memberInfoList[0]);const o = t; const a = o.nick; const s = o.avatar;Ae(a) && (this.nick = a), Ae(s) && (this.avatar = s);const r = new Xs(e);this._elements.push(r)
    } }, { key: 'setGroupSystemNoticeElement', value(e) {
      const t = new Zs(e);this._elements.push(t)
    } }, { key: 'setFaceElement', value(e) {
      const t = new zs(e);this._elements.push(t)
    } }, { key: 'setMergerElement', value(e) {
      const t = new sr(e);this._elements.push(t)
    } }, { key: 'setIsRead', value(e) {
      this.isRead = e
    } }, { key: 'setRelayFlag', value(e) {
      this._relayFlag = e
    } }, { key: 'getRelayFlag', value() {
      return this._relayFlag
    } }, { key: 'setOnlineOnlyFlag', value(e) {
      this._onlineOnlyFlag = e
    } }, { key: 'getOnlineOnlyFlag', value() {
      return this._onlineOnlyFlag
    } }, { key: '_computePriority', value(e) {
      if (Ge(e)) return k.MSG_PRIORITY_NORMAL;if (Ae(e) && -1 !== Object.values(rr).indexOf(e)) return e;if (Ne(e)) {
        const t = `${e}`;if (-1 !== Object.keys(rr).indexOf(t)) return rr[t]
      } return k.MSG_PRIORITY_NORMAL
    } }, { key: 'setNickAndAvatar', value(e) {
      const t = e.nick; const n = e.avatar;Ae(t) && (this.nick = t), Ae(n) && (this.avatar = n)
    } }]), e
  }()); const cr = function (e) {
    return { code: 0, data: e || {} }
  }; const ur = 'https://cloud.tencent.com/document/product/'; const lr = '您可以在即时通信 IM 控制台的【开发辅助工具(https://console.cloud.tencent.com/im-detail/tool-usersig)】页面校验 UserSig。'; const dr = 'UserSig 非法，请使用官网提供的 API 重新生成 UserSig('.concat(ur, '269/32688)。'); const gr = '#.E6.B6.88.E6.81.AF.E5.85.83.E7.B4.A0-timmsgelement'; const pr = { 70001: 'UserSig 已过期，请重新生成。建议 UserSig 有效期设置不小于24小时。', 70002: 'UserSig 长度为0，请检查传入的 UserSig 是否正确。', 70003: dr, 70005: dr, 70009: 'UserSig 验证失败，可能因为生成 UserSig 时混用了其他 SDKAppID 的私钥或密钥导致，请使用对应 SDKAppID 下的私钥或密钥重新生成 UserSig('.concat(ur, '269/32688)。'), 70013: '请求中的 UserID 与生成 UserSig 时使用的 UserID 不匹配。'.concat(lr), 70014: '请求中的 SDKAppID 与生成 UserSig 时使用的 SDKAppID 不匹配。'.concat(lr), 70016: '密钥不存在，UserSig 验证失败，请在即时通信 IM 控制台获取密钥('.concat(ur, '269/32578#.E8.8E.B7.E5.8F.96.E5.AF.86.E9.92.A5)。'), 70020: 'SDKAppID 未找到，请在即时通信 IM 控制台确认应用信息。', 70050: 'UserSig 验证次数过于频繁。请检查 UserSig 是否正确，并于1分钟后重新验证。'.concat(lr), 70051: '帐号被拉入黑名单。', 70052: 'UserSig 已经失效，请重新生成，再次尝试。', 70107: '因安全原因被限制登录，请不要频繁登录。', 70169: '请求的用户帐号不存在。', 70114: ''.concat('服务端内部超时，请稍后重试。'), 70202: ''.concat('服务端内部超时，请稍后重试。'), 70206: '请求中批量数量不合法。', 70402: '参数非法，请检查必填字段是否填充，或者字段的填充是否满足协议要求。', 70403: '请求失败，需要 App 管理员权限。', 70398: '帐号数超限。如需创建多于100个帐号，请将应用升级为专业版，具体操作指引请参见购买指引('.concat(ur, '269/32458)。'), 70500: ''.concat('服务端内部错误，请重试。'), 71e3: '删除帐号失败。仅支持删除体验版帐号，您当前应用为专业版，暂不支持帐号删除。', 20001: '请求包非法。', 20002: 'UserSig 或 A2 失效。', 20003: '消息发送方或接收方 UserID 无效或不存在，请检查 UserID 是否已导入即时通信 IM。', 20004: '网络异常，请重试。', 20005: ''.concat('服务端内部错误，请重试。'), 20006: '触发发送'.concat('单聊消息', '之前回调，App 后台返回禁止下发该消息。'), 20007: '发送'.concat('单聊消息', '，被对方拉黑，禁止发送。消息发送状态默认展示为失败，您可以登录控制台修改该场景下的消息发送状态展示结果，具体操作请参见消息保留设置(').concat(ur, '269/38656)。'), 20009: '消息发送双方互相不是好友，禁止发送（配置'.concat('单聊消息', '校验好友关系才会出现）。'), 20010: '发送'.concat('单聊消息', '，自己不是对方的好友（单向关系），禁止发送。'), 20011: '发送'.concat('单聊消息', '，对方不是自己的好友（单向关系），禁止发送。'), 20012: '发送方被禁言，该条消息被禁止发送。', 20016: '消息撤回超过了时间限制（默认2分钟）。', 20018: '删除漫游内部错误。', 90001: 'JSON 格式解析失败，请检查请求包是否符合 JSON 规范。', 90002: ''.concat('JSON 格式请求包体', '中 MsgBody 不符合消息格式描述，或者 MsgBody 不是 Array 类型，请参考 TIMMsgElement 对象的定义(').concat(ur, '269/2720')
    .concat(gr, ')。'), 90003: ''.concat('JSON 格式请求包体', '中缺少 To_Account 字段或者 To_Account 帐号不存在。'), 90005: ''.concat('JSON 格式请求包体', '中缺少 MsgRandom 字段或者 MsgRandom 字段不是 Integer 类型。'), 90006: ''.concat('JSON 格式请求包体', '中缺少 MsgTimeStamp 字段或者 MsgTimeStamp 字段不是 Integer 类型。'), 90007: ''.concat('JSON 格式请求包体', '中 MsgBody 类型不是 Array 类型，请将其修改为 Array 类型。'), 90008: ''.concat('JSON 格式请求包体', '中缺少 From_Account 字段或者 From_Account 帐号不存在。'), 90009: '请求需要 App 管理员权限。', 90010: ''.concat('JSON 格式请求包体', '不符合消息格式描述，请参考 TIMMsgElement 对象的定义(').concat(ur, '269/2720')
    .concat(gr, ')。'), 90011: '批量发消息目标帐号超过500，请减少 To_Account 中目标帐号数量。', 90012: 'To_Account 没有注册或不存在，请确认 To_Account 是否导入即时通信 IM 或者是否拼写错误。', 90026: '消息离线存储时间错误（最多不能超过7天）。', 90031: ''.concat('JSON 格式请求包体', '中 SyncOtherMachine 字段不是 Integer 类型。'), 90044: ''.concat('JSON 格式请求包体', '中 MsgLifeTime 字段不是 Integer 类型。'), 90048: '请求的用户帐号不存在。', 90054: '撤回请求中的 MsgKey 不合法。', 90994: ''.concat('服务端内部错误，请重试。'), 90995: ''.concat('服务端内部错误，请重试。'), 91e3: ''.concat('服务端内部错误，请重试。'), 90992: ''.concat('服务端内部错误，请重试。', '如果所有请求都返回该错误码，且 App 配置了第三方回调，请检查 App 服务端是否正常向即时通信 IM 后台服务端返回回调结果。'), 93e3: 'JSON 数据包超长，消息包体请不要超过8k。', 91101: 'Web 端长轮询被踢（Web 端同时在线实例个数超出限制）。', 10002: ''.concat('服务端内部错误，请重试。'), 10003: '请求中的接口名称错误，请核对接口名称并重试。', 10004: '参数非法，请根据错误描述检查请求是否正确。', 10005: '请求包体中携带的帐号数量过多。', 10006: '操作频率限制，请尝试降低调用的频率。', 10007: '操作权限不足，例如 Work '.concat('群组', '中普通成员尝试执行踢人操作，但只有 App 管理员才有权限。'), 10008: '请求非法，可能是请求中携带的签名信息验证不正确，请再次尝试。', 10009: '该群不允许群主主动退出。', 10010: ''.concat('群组', '不存在，或者曾经存在过，但是目前已经被解散。'), 10011: '解析 JSON 包体失败，请检查包体的格式是否符合 JSON 格式。', 10012: '发起操作的 UserID 非法，请检查发起操作的用户 UserID 是否填写正确。', 10013: '被邀请加入的用户已经是群成员。', 10014: '群已满员，无法将请求中的用户加入'.concat('群组', '，如果是批量加人，可以尝试减少加入用户的数量。'), 10015: '找不到指定 ID 的'.concat('群组', '。'), 10016: 'App 后台通过第三方回调拒绝本次操作。', 10017: '因被禁言而不能发送消息，请检查发送者是否被设置禁言。', 10018: '应答包长度超过最大包长（1MB），请求的内容过多，请尝试减少单次请求的数据量。', 10019: '请求的用户帐号不存在。', 10021: ''.concat('群组', ' ID 已被使用，请选择其他的').concat('群组', ' ID。'), 10023: '发消息的频率超限，请延长两次发消息时间的间隔。', 10024: '此邀请或者申请请求已经被处理。', 10025: ''.concat('群组', ' ID 已被使用，并且操作者为群主，可以直接使用。'), 10026: '该 SDKAppID 请求的命令字已被禁用。', 10030: '请求撤回的消息不存在。', 10031: '消息撤回超过了时间限制（默认2分钟）。', 10032: '请求撤回的消息不支持撤回操作。', 10033: ''.concat('群组', '类型不支持消息撤回操作。'), 10034: '该消息类型不支持删除操作。', 10035: '直播群和在线成员广播大群不支持删除消息。', 10036: '直播群创建数量超过了限制，请参考价格说明('.concat(ur, '269/11673)购买预付费套餐“IM直播群”。'), 10037: '单个用户可创建和加入的'.concat('群组', '数量超过了限制，请参考价格说明(').concat(ur, '269/11673)购买或升级预付费套餐“单人可创建与加入')
    .concat('群组', '数”。'), 10038: '群成员数量超过限制，请参考价格说明('.concat(ur, '269/11673)购买或升级预付费套餐“扩展群人数上限”。'), 10041: '该应用（SDKAppID）已配置不支持群消息撤回。', 30001: '请求参数错误，请根据错误描述检查请求参数', 30002: 'SDKAppID 不匹配', 30003: '请求的用户帐号不存在', 30004: '请求需要 App 管理员权限', 30005: '关系链字段中包含敏感词', 30006: ''.concat('服务端内部错误，请重试。'), 30007: ''.concat('网络超时，请稍后重试. '), 30008: '并发写导致写冲突，建议使用批量方式', 30009: '后台禁止该用户发起加好友请求', 30010: '自己的好友数已达系统上限', 30011: '分组已达系统上限', 30012: '未决数已达系统上限', 30014: '对方的好友数已达系统上限', 30515: '请求添加好友时，对方在自己的黑名单中，不允许加好友', 30516: '请求添加好友时，对方的加好友验证方式是不允许任何人添加自己为好友', 30525: '请求添加好友时，自己在对方的黑名单中，不允许加好友', 30539: '等待对方同意', 30540: '添加好友请求被安全策略打击，请勿频繁发起添加好友请求', 31704: '与请求删除的帐号之间不存在好友关系', 31707: '删除好友请求被安全策略打击，请勿频繁发起删除好友请求' }; const hr = (function (e) {
    i(n, e);const t = f(n);function n(e) {
      let a;return o(this, n), (a = t.call(this)).code = e.code, a.message = pr[e.code] || e.message, a.data = e.data || {}, a
    } return n
  }(g(Error))); let _r = null; const fr = function (e) {
    _r = e
  }; const mr = function (e) {
    return Promise.resolve(cr(e))
  }; const Mr = function (e) {
    const t = arguments.length > 1 && void 0 !== arguments[1] && arguments[1];if (e instanceof hr) return t && null !== _r && _r.emit(E.ERROR, e), Promise.reject(e);if (e instanceof Error) {
      const n = new hr({ code: Zn.UNCAUGHT_ERROR, message: e.message });return t && null !== _r && _r.emit(E.ERROR, n), Promise.reject(n)
    } if (Ge(e) || Ge(e.code) || Ge(e.message))Ee.error('IMPromise.reject 必须指定code(错误码)和message(错误信息)!!!');else {
      if (Ne(e.code) && Ae(e.message)) {
        const o = new hr(e);return t && null !== _r && _r.emit(E.ERROR, o), Promise.reject(o)
      }Ee.error('IMPromise.reject code(错误码)必须为数字，message(错误信息)必须为字符串!!!')
    }
  }; const vr = (function (e) {
    i(n, e);const t = f(n);function n(e) {
      let a;return o(this, n), (a = t.call(this, e))._className = 'C2CModule', a
    } return s(n, [{ key: 'onNewC2CMessage', value(e) {
      const t = e.dataList; const n = e.isInstantMessage; const o = e.C2CRemainingUnreadList;Ee.debug(''.concat(this._className, '.onNewC2CMessage count:').concat(t.length, ' isInstantMessage:')
        .concat(n));const a = this._newC2CMessageStoredAndSummary({ dataList: t, C2CRemainingUnreadList: o, isInstantMessage: n }); const s = a.conversationOptionsList; const r = a.messageList;(this.filterModifiedMessage(r), s.length > 0) && this.getModule(Rt).onNewMessage({ conversationOptionsList: s, isInstantMessage: n });const i = this.filterUnmodifiedMessage(r);n && i.length > 0 && this.emitOuterEvent(E.MESSAGE_RECEIVED, i), r.length = 0
    } }, { key: '_newC2CMessageStoredAndSummary', value(e) {
      for (var t = e.dataList, n = e.C2CRemainingUnreadList, o = e.isInstantMessage, a = null, s = [], r = [], i = {}, c = this.getModule(Ut), u = 0, l = t.length;u < l;u++) {
        const d = t[u];d.currentUser = this.getMyUserID(), d.conversationType = k.CONV_C2C, d.isSystemMessage = !!d.isSystemMessage, a = new ir(d), d.elements = c.parseElements(d.elements, d.from), a.setElement(d.elements), a.setNickAndAvatar({ nick: d.nick, avatar: d.avatar });const g = a.conversationID;if (o) {
          let p = !1; const h = this.getModule(Rt);if (a.from !== this.getMyUserID()) {
            const _ = h.getLatestMessageSentByPeer(g);if (_) {
              const f = _.nick; const m = _.avatar;f === a.nick && m === a.avatar || (p = !0)
            }
          } else {
            const M = h.getLatestMessageSentByMe(g);if (M) {
              const v = M.nick; const y = M.avatar;v === a.nick && y === a.avatar || h.modifyMessageSentByMe({ conversationID: g, latestNick: a.nick, latestAvatar: a.avatar })
            }
          } let I = 1 === t[u].isModified;if (h.isMessageSentByCurrentInstance(a) ? a.isModified = I : I = !1, 0 === d.msgLifeTime)a.setOnlineOnlyFlag(!0), r.push(a);else {
            if (!h.pushIntoMessageList(r, a, I)) continue;p && (h.modifyMessageSentByPeer(g), h.updateUserProfileSpecifiedKey({ conversationID: g, nick: a.nick, avatar: a.avatar }))
          } this.getModule($t).addMessageDelay({ currentTime: Date.now(), time: a.time })
        } if (0 !== d.msgLifeTime) {
          if (!1 === a.getOnlineOnlyFlag()) if (Ge(i[g]))i[g] = s.push({ conversationID: g, unreadCount: 'out' === a.flow ? 0 : 1, type: a.conversationType, subType: a.conversationSubType, lastMessage: a }) - 1;else {
            const D = i[g];s[D].type = a.conversationType, s[D].subType = a.conversationSubType, s[D].lastMessage = a, 'in' === a.flow && s[D].unreadCount++
          }
        } else a.setOnlineOnlyFlag(!0)
      } if (Re(n)) for (let T = function (e, t) {
          const o = s.find(((t) => t.conversationID === 'C2C'.concat(n[e].from)));o ? o.unreadCount += n[e].count : s.push({ conversationID: 'C2C'.concat(n[e].from), unreadCount: n[e].count, type: k.CONV_C2C, lastMsgTime: n[e].lastMsgTime })
        }, S = 0, E = n.length;S < E;S++)T(S);return { conversationOptionsList: s, messageList: r }
    } }, { key: 'onC2CMessageRevoked', value(e) {
      const t = this;Ee.debug(''.concat(this._className, '.onC2CMessageRevoked count:').concat(e.dataList.length));const n = this.getModule(Rt); const o = []; let a = null;e.dataList.forEach(((e) => {
        if (e.c2cMessageRevokedNotify) {
          const s = e.c2cMessageRevokedNotify.revokedInfos;Ge(s) || s.forEach(((e) => {
            const s = t.getMyUserID() === e.from ? ''.concat(k.CONV_C2C).concat(e.to) : ''.concat(k.CONV_C2C).concat(e.from);(a = n.revoke(s, e.sequence, e.random)) && o.push(a)
          }))
        }
      })), 0 !== o.length && (n.onMessageRevoked(o), this.emitOuterEvent(E.MESSAGE_REVOKED, o))
    } }, { key: 'onC2CMessageReadReceipt', value(e) {
      const t = this;e.dataList.forEach(((e) => {
        if (!dt(e.c2cMessageReadReceipt)) {
          const n = e.c2cMessageReadReceipt.to;e.c2cMessageReadReceipt.uinPairReadArray.forEach(((e) => {
            const o = e.peerReadTime;Ee.debug(''.concat(t._className, '._onC2CMessageReadReceipt to:').concat(n, ' peerReadTime:')
              .concat(o));const a = ''.concat(k.CONV_C2C).concat(n); const s = t.getModule(Rt);s.recordPeerReadTime(a, o), s.updateMessageIsPeerReadProperty(a, o)
          }))
        }
      }))
    } }, { key: 'onC2CMessageReadNotice', value(e) {
      const t = this;e.dataList.forEach(((e) => {
        if (!dt(e.c2cMessageReadNotice)) {
          const n = t.getModule(Rt);e.c2cMessageReadNotice.uinPairReadArray.forEach(((e) => {
            const o = e.from; const a = e.peerReadTime;Ee.debug(''.concat(t._className, '.onC2CMessageReadNotice from:').concat(o, ' lastReadTime:')
              .concat(a));const s = ''.concat(k.CONV_C2C).concat(o);n.updateIsReadAfterReadReport({ conversationID: s, lastMessageTime: a }), n.updateUnreadCount(s)
          }))
        }
      }))
    } }, { key: 'sendMessage', value(e, t) {
      const n = this._createC2CMessagePack(e, t);return this.request(n)
    } }, { key: '_createC2CMessagePack', value(e, t) {
      let n = null;t && (t.offlinePushInfo && (n = t.offlinePushInfo), !0 === t.onlineUserOnly && (n ? n.disablePush = !0 : n = { disablePush: !0 }));let o = '';return Ae(e.cloudCustomData) && e.cloudCustomData.length > 0 && (o = e.cloudCustomData), { protocolName: Zt, tjgID: this.generateTjgID(e), requestData: { fromAccount: this.getMyUserID(), toAccount: e.to, msgTimeStamp: Math.ceil(Date.now() / 1e3), msgBody: e.getElements(), cloudCustomData: o, msgSeq: e.sequence, msgRandom: e.random, msgLifeTime: this.isOnlineMessage(e, t) ? 0 : void 0, nick: e.nick, avatar: e.avatar, offlinePushInfo: n ? { pushFlag: !0 === n.disablePush ? 1 : 0, title: n.title || '', desc: n.description || '', ext: n.extension || '', apnsInfo: { badgeMode: !0 === n.ignoreIOSBadge ? 1 : 0 }, androidInfo: { OPPOChannelID: n.androidOPPOChannelID || '' } } : void 0 } }
    } }, { key: 'isOnlineMessage', value(e, t) {
      return !(!t || !0 !== t.onlineUserOnly)
    } }, { key: 'revokeMessage', value(e) {
      return this.request({ protocolName: rn, requestData: { msgInfo: { fromAccount: e.from, toAccount: e.to, msgSeq: e.sequence, msgRandom: e.random, msgTimeStamp: e.time } } })
    } }, { key: 'deleteMessage', value(e) {
      const t = e.to; const n = e.keyList;return Ee.log(''.concat(this._className, '.deleteMessage toAccount:').concat(t, ' count:')
        .concat(n.length)), this.request({ protocolName: dn, requestData: { fromAccount: this.getMyUserID(), to: t, keyList: n } })
    } }, { key: 'setMessageRead', value(e) {
      const t = this; const n = e.conversationID; const o = e.lastMessageTime; const a = ''.concat(this._className, '.setMessageRead');Ee.log(''.concat(a, ' conversationID:').concat(n, ' lastMessageTime:')
        .concat(o)), Ne(o) || Ee.warn(''.concat(a, ' 请勿修改 Conversation.lastMessage.lastTime，否则可能会导致已读上报结果不准确'));const s = new Da(Ka);return s.setMessage('conversationID:'.concat(n, ' lastMessageTime:').concat(o)), this.request({ protocolName: cn, requestData: { C2CMsgReaded: { cookie: '', C2CMsgReadedItem: [{ toAccount: n.replace('C2C', ''), lastMessageTime: o, receipt: 1 }] } } }).then((() => {
        s.setNetworkType(t.getNetworkType()).end(), Ee.log(''.concat(a, ' ok'));const e = t.getModule(Rt);return e.updateIsReadAfterReadReport({ conversationID: n, lastMessageTime: o }), e.updateUnreadCount(n), cr()
      }))
        .catch(((e) => (t.probeNetwork().then(((t) => {
          const n = m(t, 2); const o = n[0]; const a = n[1];s.setError(e, o, a).end()
        })), Ee.log(''.concat(a, ' failed. error:'), e), Mr(e))))
    } }, { key: 'getRoamingMessage', value(e) {
      const t = this; const n = ''.concat(this._className, '.getRoamingMessage'); const o = e.peerAccount; const a = e.conversationID; const s = e.count; const r = e.lastMessageTime; const i = e.messageKey; const c = 'peerAccount:'.concat(o, ' count:').concat(s || 15, ' lastMessageTime:')
        .concat(r || 0, ' messageKey:')
        .concat(i);Ee.log(''.concat(n, ' ').concat(c));const u = new Da(Ua);return this.request({ protocolName: un, requestData: { peerAccount: o, count: s || 15, lastMessageTime: r || 0, messageKey: i } }).then(((e) => {
        const o = e.data; const s = o.complete; const r = o.messageList; const i = o.messageKey;Ge(r) ? Ee.log(''.concat(n, ' ok. complete:').concat(s, ' but messageList is undefined!')) : Ee.log(''.concat(n, ' ok. complete:').concat(s, ' count:')
          .concat(r.length)), u.setNetworkType(t.getNetworkType()).setMessage(''.concat(c, ' complete:').concat(s, ' length:')
          .concat(r.length))
          .end();const l = t.getModule(Rt);1 === s && l.setCompleted(a);const d = l.storeRoamingMessage(r, a);l.modifyMessageList(a), l.updateIsRead(a), l.updateRoamingMessageKey(a, i);const g = l.getPeerReadTime(a);if (Ee.log(''.concat(n, ' update isPeerRead property. conversationID:').concat(a, ' peerReadTime:')
          .concat(g)), g)l.updateMessageIsPeerReadProperty(a, g);else {
          const p = a.replace(k.CONV_C2C, '');t.getRemotePeerReadTime([p]).then((() => {
            l.updateMessageIsPeerReadProperty(a, l.getPeerReadTime(a))
          }))
        } return d
      }))
        .catch(((e) => (t.probeNetwork().then(((t) => {
          const n = m(t, 2); const o = n[0]; const a = n[1];u.setMessage(c).setError(e, o, a)
            .end()
        })), Ee.warn(''.concat(n, ' failed. error:'), e), Mr(e))))
    } }, { key: 'getRemotePeerReadTime', value(e) {
      const t = this; const n = ''.concat(this._className, '.getRemotePeerReadTime');if (dt(e)) return Ee.warn(''.concat(n, ' userIDList is empty!')), Promise.resolve();const o = new Da(Ha);return Ee.log(''.concat(n, ' userIDList:').concat(e)), this.request({ protocolName: ln, requestData: { userIDList: e } }).then(((a) => {
        const s = a.data.peerReadTimeList;Ee.log(''.concat(n, ' ok. peerReadTimeList:').concat(s));for (var r = '', i = t.getModule(Rt), c = 0;c < e.length;c++)r += ''.concat(e[c], '-').concat(s[c], ' '), s[c] > 0 && i.recordPeerReadTime('C2C'.concat(e[c]), s[c]);o.setNetworkType(t.getNetworkType()).setMessage(r)
          .end()
      }))
        .catch(((e) => {
          t.probeNetwork().then(((t) => {
            const n = m(t, 2); const a = n[0]; const s = n[1];o.setError(e, a, s).end()
          })), Ee.warn(''.concat(n, ' failed. error:'), e)
        }))
    } }]), n
  }(Yt)); const yr = (function () {
    function e(t) {
      o(this, e), this.list = new Map, this._className = 'MessageListHandler', this._latestMessageSentByPeerMap = new Map, this._latestMessageSentByMeMap = new Map, this._groupLocalLastMessageSequenceMap = new Map
    } return s(e, [{ key: 'getLocalOldestMessageByConversationID', value(e) {
      if (!e) return null;if (!this.list.has(e)) return null;const t = this.list.get(e).values();return t ? t.next().value : null
    } }, { key: 'pushIn', value(e) {
      const t = arguments.length > 1 && void 0 !== arguments[1] && arguments[1]; const n = e.conversationID; const o = e.ID; let a = !0;this.list.has(n) || this.list.set(n, new Map);const s = this.list.get(n).has(o);if (s) {
        const r = this.list.get(n).get(o);if (!t || !0 === r.isModified) return a = !1
      } return this.list.get(n).set(o, e), this._setLatestMessageSentByPeer(n, e), this._setLatestMessageSentByMe(n, e), this._setGroupLocalLastMessageSequence(n, e), a
    } }, { key: 'unshift', value(e) {
      let t;if (Re(e)) {
        if (e.length > 0) {
          t = e[0].conversationID;const n = e.length;this._unshiftMultipleMessages(e), this._setGroupLocalLastMessageSequence(t, e[n - 1])
        }
      } else t = e.conversationID, this._unshiftSingleMessage(e), this._setGroupLocalLastMessageSequence(t, e);if (t && t.startsWith(k.CONV_C2C)) {
        const o = Array.from(this.list.get(t).values()); const a = o.length;if (0 === a) return;for (let s = a - 1;s >= 0;s--) if ('out' === o[s].flow) {
          this._setLatestMessageSentByMe(t, o[s]);break
        } for (let r = a - 1;r >= 0;r--) if ('in' === o[r].flow) {
          this._setLatestMessageSentByPeer(t, o[r]);break
        }
      }
    } }, { key: '_unshiftSingleMessage', value(e) {
      const t = e.conversationID; const n = e.ID;if (!this.list.has(t)) return this.list.set(t, new Map), void this.list.get(t).set(n, e);const o = Array.from(this.list.get(t));o.unshift([n, e]), this.list.set(t, new Map(o))
    } }, { key: '_unshiftMultipleMessages', value(e) {
      for (var t = e.length, n = [], o = e[0].conversationID, a = this.list.has(o) ? Array.from(this.list.get(o)) : [], s = 0;s < t;s++)n.push([e[s].ID, e[s]]);this.list.set(o, new Map(n.concat(a)))
    } }, { key: 'remove', value(e) {
      const t = e.conversationID; const n = e.ID;this.list.has(t) && this.list.get(t).delete(n)
    } }, { key: 'revoke', value(e, t, n) {
      if (Ee.debug('revoke message', e, t, n), this.list.has(e)) {
        let o; const a = S(this.list.get(e));try {
          for (a.s();!(o = a.n()).done;) {
            const s = m(o.value, 2)[1];if (s.sequence === t && !s.isRevoked && (Ge(n) || s.random === n)) return s.isRevoked = !0, s
          }
        } catch (r) {
          a.e(r)
        } finally {
          a.f()
        }
      } return null
    } }, { key: 'removeByConversationID', value(e) {
      this.list.has(e) && (this.list.delete(e), this._latestMessageSentByPeerMap.delete(e), this._latestMessageSentByMeMap.delete(e))
    } }, { key: 'updateMessageIsPeerReadProperty', value(e, t) {
      const n = [];if (this.list.has(e)) {
        let o; const a = S(this.list.get(e));try {
          for (a.s();!(o = a.n()).done;) {
            const s = m(o.value, 2)[1];s.time <= t && !s.isPeerRead && 'out' === s.flow && (s.isPeerRead = !0, n.push(s))
          }
        } catch (r) {
          a.e(r)
        } finally {
          a.f()
        }Ee.log(''.concat(this._className, '.updateMessageIsPeerReadProperty conversationID:').concat(e, ' peerReadTime:')
          .concat(t, ' count:')
          .concat(n.length))
      } return n
    } }, { key: 'updateMessageIsModifiedProperty', value(e) {
      const t = e.conversationID; const n = e.ID;if (this.list.has(t)) {
        const o = this.list.get(t).get(n);o && (o.isModified = !0)
      }
    } }, { key: 'hasLocalMessageList', value(e) {
      return this.list.has(e)
    } }, { key: 'getLocalMessageList', value(e) {
      return this.hasLocalMessageList(e) ? M(this.list.get(e).values()) : []
    } }, { key: 'hasLocalMessage', value(e, t) {
      return !!this.hasLocalMessageList(e) && this.list.get(e).has(t)
    } }, { key: 'getLocalMessage', value(e, t) {
      return this.hasLocalMessage(e, t) ? this.list.get(e).get(t) : null
    } }, { key: '_setLatestMessageSentByPeer', value(e, t) {
      e.startsWith(k.CONV_C2C) && 'in' === t.flow && this._latestMessageSentByPeerMap.set(e, t)
    } }, { key: '_setLatestMessageSentByMe', value(e, t) {
      e.startsWith(k.CONV_C2C) && 'out' === t.flow && this._latestMessageSentByMeMap.set(e, t)
    } }, { key: '_setGroupLocalLastMessageSequence', value(e, t) {
      e.startsWith(k.CONV_GROUP) && this._groupLocalLastMessageSequenceMap.set(e, t.sequence)
    } }, { key: 'getLatestMessageSentByPeer', value(e) {
      return this._latestMessageSentByPeerMap.get(e)
    } }, { key: 'getLatestMessageSentByMe', value(e) {
      return this._latestMessageSentByMeMap.get(e)
    } }, { key: 'getGroupLocalLastMessageSequence', value(e) {
      return this._groupLocalLastMessageSequenceMap.get(e) || 0
    } }, { key: 'modifyMessageSentByPeer', value(e, t) {
      const n = this.list.get(e);if (!dt(n)) {
        const o = Array.from(n.values()); const a = o.length;if (0 !== a) {
          let s = null; let r = null;t && (r = t);for (var i = 0, c = !1, u = a - 1;u >= 0;u--)'in' === o[u].flow && (null === r ? r = o[u] : ((s = o[u]).nick !== r.nick && (s.setNickAndAvatar({ nick: r.nick }), c = !0), s.avatar !== r.avatar && (s.setNickAndAvatar({ avatar: r.avatar }), c = !0), c && (i += 1)));Ee.log(''.concat(this._className, '.modifyMessageSentByPeer conversationID:').concat(e, ' count:')
            .concat(i))
        }
      }
    } }, { key: 'modifyMessageSentByMe', value(e) {
      const t = e.conversationID; const n = e.latestNick; const o = e.latestAvatar; const a = this.list.get(t);if (!dt(a)) {
        const s = Array.from(a.values()); const r = s.length;if (0 !== r) {
          for (var i = null, c = 0, u = !1, l = r - 1;l >= 0;l--)'out' === s[l].flow && ((i = s[l]).nick !== n && (i.setNickAndAvatar({ nick: n }), u = !0), i.avatar !== o && (i.setNickAndAvatar({ avatar: o }), u = !0), u && (c += 1));Ee.log(''.concat(this._className, '.modifyMessageSentByMe conversationID:').concat(t, ' count:')
            .concat(c))
        }
      }
    } }, { key: 'traversal', value() {
      if (0 !== this.list.size && -1 === Ee.getLevel()) {
        console.group('conversationID-messageCount');let e; const t = S(this.list);try {
          for (t.s();!(e = t.n()).done;) {
            const n = m(e.value, 2); const o = n[0]; const a = n[1];console.log(''.concat(o, '-').concat(a.size))
          }
        } catch (s) {
          t.e(s)
        } finally {
          t.f()
        }console.groupEnd()
      }
    } }, { key: 'reset', value() {
      this.list.clear(), this._latestMessageSentByPeerMap.clear(), this._latestMessageSentByMeMap.clear(), this._groupLocalLastMessageSequenceMap.clear()
    } }]), e
  }()); const Ir = { CONTEXT_A2KEY_AND_TINYID_UPDATED: '_a2KeyAndTinyIDUpdated', CLOUD_CONFIG_UPDATED: '_cloudConfigUpdated' };function Dr(e) {
    this.mixin(e)
  }Dr.mixin = function (e) {
    const t = e.prototype || e;t._isReady = !1, t.ready = function (e) {
      const t = arguments.length > 1 && void 0 !== arguments[1] && arguments[1];if (e) return this._isReady ? void(t ? e.call(this) : setTimeout(e, 1)) : (this._readyQueue = this._readyQueue || [], void this._readyQueue.push(e))
    }, t.triggerReady = function () {
      const e = this;this._isReady = !0, setTimeout((() => {
        const t = e._readyQueue;e._readyQueue = [], t && t.length > 0 && t.forEach((function (e) {
          e.call(this)
        }), e)
      }), 1)
    }, t.resetReady = function () {
      this._isReady = !1, this._readyQueue = []
    }, t.isReady = function () {
      return this._isReady
    }
  };const Tr = ['jpg', 'jpeg', 'gif', 'png', 'bmp']; const Sr = ['mp4']; const Er = 1; const kr = 2; const Cr = 3; const Nr = 255; const Ar = (function () {
    function e(t) {
      const n = this;o(this, e), dt(t) || (this.userID = t.userID || '', this.nick = t.nick || '', this.gender = t.gender || '', this.birthday = t.birthday || 0, this.location = t.location || '', this.selfSignature = t.selfSignature || '', this.allowType = t.allowType || k.ALLOW_TYPE_ALLOW_ANY, this.language = t.language || 0, this.avatar = t.avatar || '', this.messageSettings = t.messageSettings || 0, this.adminForbidType = t.adminForbidType || k.FORBID_TYPE_NONE, this.level = t.level || 0, this.role = t.role || 0, this.lastUpdatedTime = 0, this.profileCustomField = [], dt(t.profileCustomField) || t.profileCustomField.forEach(((e) => {
        n.profileCustomField.push({ key: e.key, value: e.value })
      })))
    } return s(e, [{ key: 'validate', value(e) {
      let t = !0; let n = '';if (dt(e)) return { valid: !1, tips: 'empty options' };if (e.profileCustomField) for (let o = e.profileCustomField.length, a = null, s = 0;s < o;s++) {
        if (a = e.profileCustomField[s], !Ae(a.key) || -1 === a.key.indexOf('Tag_Profile_Custom')) return { valid: !1, tips: '自定义资料字段的前缀必须是 Tag_Profile_Custom' };if (!Ae(a.value)) return { valid: !1, tips: '自定义资料字段的 value 必须是字符串' }
      } for (const r in e) if (Object.prototype.hasOwnProperty.call(e, r)) {
        if ('profileCustomField' === r) continue;if (dt(e[r]) && !Ae(e[r]) && !Ne(e[r])) {
          n = `key:${r}, invalid value:${e[r]}`, t = !1;continue
        } switch (r) {
          case 'nick':Ae(e[r]) || (n = 'nick should be a string', t = !1), Be(e[r]) > 500 && (n = 'nick name limited: must less than or equal to '.concat(500, ' bytes, current size: ').concat(Be(e[r]), ' bytes'), t = !1);break;case 'gender':Ye(xs, e.gender) || (n = `key:gender, invalid value:${e.gender}`, t = !1);break;case 'birthday':Ne(e.birthday) || (n = 'birthday should be a number', t = !1);break;case 'location':Ae(e.location) || (n = 'location should be a string', t = !1);break;case 'selfSignature':Ae(e.selfSignature) || (n = 'selfSignature should be a string', t = !1);break;case 'allowType':Ye(Hs, e.allowType) || (n = `key:allowType, invalid value:${e.allowType}`, t = !1);break;case 'language':Ne(e.language) || (n = 'language should be a number', t = !1);break;case 'avatar':Ae(e.avatar) || (n = 'avatar should be a string', t = !1);break;case 'messageSettings':0 !== e.messageSettings && 1 !== e.messageSettings && (n = 'messageSettings should be 0 or 1', t = !1);break;case 'adminForbidType':Ye(Bs, e.adminForbidType) || (n = `key:adminForbidType, invalid value:${e.adminForbidType}`, t = !1);break;case 'level':Ne(e.level) || (n = 'level should be a number', t = !1);break;case 'role':Ne(e.role) || (n = 'role should be a number', t = !1);break;default:n = `unknown key:${r}  ${e[r]}`, t = !1
        }
      } return { valid: t, tips: n }
    } }]), e
  }()); const Or = function e(t) {
    o(this, e), this.value = t, this.next = null
  }; const Lr = (function () {
    function e(t) {
      o(this, e), this.MAX_LENGTH = t, this.pTail = null, this.pNodeToDel = null, this.map = new Map, Ee.debug('SinglyLinkedList init MAX_LENGTH:'.concat(this.MAX_LENGTH))
    } return s(e, [{ key: 'set', value(e) {
      const t = new Or(e);if (this.map.size < this.MAX_LENGTH)null === this.pTail ? (this.pTail = t, this.pNodeToDel = t) : (this.pTail.next = t, this.pTail = t), this.map.set(e, 1);else {
        let n = this.pNodeToDel;this.pNodeToDel = this.pNodeToDel.next, this.map.delete(n.value), n.next = null, n = null, this.pTail.next = t, this.pTail = t, this.map.set(e, 1)
      }
    } }, { key: 'has', value(e) {
      return this.map.has(e)
    } }, { key: 'delete', value(e) {
      this.has(e) && this.map.delete(e)
    } }, { key: 'tail', value() {
      return this.pTail
    } }, { key: 'size', value() {
      return this.map.size
    } }, { key: 'data', value() {
      return Array.from(this.map.keys())
    } }, { key: 'reset', value() {
      for (var e;null !== this.pNodeToDel;)e = this.pNodeToDel, this.pNodeToDel = this.pNodeToDel.next, e.next = null, e = null;this.pTail = null, this.map.clear()
    } }]), e
  }()); const Rr = ['groupID', 'name', 'avatar', 'type', 'introduction', 'notification', 'ownerID', 'selfInfo', 'createTime', 'infoSequence', 'lastInfoTime', 'lastMessage', 'nextMessageSeq', 'memberNum', 'maxMemberNum', 'memberList', 'joinOption', 'groupCustomField', 'muteAllMembers']; const Gr = (function () {
    function e(t) {
      o(this, e), this.groupID = '', this.name = '', this.avatar = '', this.type = '', this.introduction = '', this.notification = '', this.ownerID = '', this.createTime = '', this.infoSequence = '', this.lastInfoTime = '', this.selfInfo = { messageRemindType: '', joinTime: '', nameCard: '', role: '' }, this.lastMessage = { lastTime: '', lastSequence: '', fromAccount: '', messageForShow: '' }, this.nextMessageSeq = '', this.memberNum = '', this.memberCount = '', this.maxMemberNum = '', this.maxMemberCount = '', this.joinOption = '', this.groupCustomField = [], this.muteAllMembers = void 0, this._initGroup(t)
    } return s(e, [{ key: 'memberNum', get() {
      return Ee.warn('！！！v2.8.0起弃用memberNum，请使用 memberCount'), this.memberCount
    }, set(e) {} }, { key: 'maxMemberNum', get() {
      return Ee.warn('！！！v2.8.0起弃用maxMemberNum，请使用 maxMemberCount'), this.maxMemberCount
    }, set(e) {} }, { key: '_initGroup', value(e) {
      for (const t in e)Rr.indexOf(t) < 0 || ('selfInfo' !== t ? ('memberNum' === t && (this.memberCount = e[t]), 'maxMemberNum' === t && (this.maxMemberCount = e[t]), this[t] = e[t]) : this.updateSelfInfo(e[t]))
    } }, { key: 'updateGroup', value(e) {
      const t = JSON.parse(JSON.stringify(e));t.lastMsgTime && (this.lastMessage.lastTime = t.lastMsgTime), Ge(t.muteAllMembers) || ('On' === t.muteAllMembers ? t.muteAllMembers = !0 : t.muteAllMembers = !1), t.groupCustomField && Qe(this.groupCustomField, t.groupCustomField), Ge(t.memberNum) || (this.memberCount = t.memberNum), Ge(t.maxMemberNum) || (this.maxMemberCount = t.maxMemberNum), Ke(this, t, ['members', 'errorCode', 'lastMsgTime', 'groupCustomField', 'memberNum', 'maxMemberNum'])
    } }, { key: 'updateSelfInfo', value(e) {
      const t = e.nameCard; const n = e.joinTime; const o = e.role; const a = e.messageRemindType;Ke(this.selfInfo, { nameCard: t, joinTime: n, role: o, messageRemindType: a }, [], ['', null, void 0, 0, NaN])
    } }, { key: 'setSelfNameCard', value(e) {
      this.selfInfo.nameCard = e
    } }]), e
  }()); const wr = function (e, t) {
    if (Ge(t)) return '';switch (e) {
      case k.MSG_TEXT:return t.text;case k.MSG_IMAGE:return '[图片]';case k.MSG_GEO:return '[位置]';case k.MSG_AUDIO:return '[语音]';case k.MSG_VIDEO:return '[视频]';case k.MSG_FILE:return '[文件]';case k.MSG_CUSTOM:return '[自定义消息]';case k.MSG_GRP_TIP:return '[群提示消息]';case k.MSG_GRP_SYS_NOTICE:return '[群系统通知]';case k.MSG_FACE:return '[动画表情]';case k.MSG_MERGER:return '[聊天记录]';default:return ''
    }
  }; const Pr = function (e) {
    return Ge(e) ? { lastTime: 0, lastSequence: 0, fromAccount: 0, messageForShow: '', payload: null, type: '', isRevoked: !1, cloudCustomData: '', onlineOnlyFlag: !1 } : e instanceof ir ? { lastTime: e.time || 0, lastSequence: e.sequence || 0, fromAccount: e.from || '', messageForShow: wr(e.type, e.payload), payload: e.payload || null, type: e.type || null, isRevoked: e.isRevoked || !1, cloudCustomData: e.cloudCustomData || '', onlineOnlyFlag: !!Pe(e.getOnlineOnlyFlag) && e.getOnlineOnlyFlag() } : t(t({}, e), {}, { messageForShow: wr(e.type, e.payload) })
  }; const br = (function () {
    function e(t) {
      o(this, e), this.conversationID = t.conversationID || '', this.unreadCount = t.unreadCount || 0, this.type = t.type || '', this.lastMessage = Pr(t.lastMessage), t.lastMsgTime && (this.lastMessage.lastTime = t.lastMsgTime), this._isInfoCompleted = !1, this.peerReadTime = t.peerReadTime || 0, this.groupAtInfoList = [], this.remark = '', this._initProfile(t)
    } return s(e, [{ key: 'toAccount', get() {
      return this.conversationID.replace('C2C', '').replace('GROUP', '')
    } }, { key: 'subType', get() {
      return this.groupProfile ? this.groupProfile.type : ''
    } }, { key: '_initProfile', value(e) {
      const t = this;Object.keys(e).forEach(((n) => {
        switch (n) {
          case 'userProfile':t.userProfile = e.userProfile;break;case 'groupProfile':t.groupProfile = e.groupProfile
        }
      })), Ge(this.userProfile) && this.type === k.CONV_C2C ? this.userProfile = new Ar({ userID: e.conversationID.replace('C2C', '') }) : Ge(this.groupProfile) && this.type === k.CONV_GROUP && (this.groupProfile = new Gr({ groupID: e.conversationID.replace('GROUP', '') }))
    } }, { key: 'updateUnreadCount', value(e, t) {
      Ge(e) || (et(this.subType) ? this.unreadCount = 0 : t && this.type === k.CONV_GROUP ? this.unreadCount = e : this.unreadCount = this.unreadCount + e)
    } }, { key: 'updateLastMessage', value(e) {
      this.lastMessage = Pr(e)
    } }, { key: 'updateGroupAtInfoList', value(e) {
      let t; let n = (v(t = e.groupAtType) || y(t) || I(t) || T()).slice(0);-1 !== n.indexOf(k.CONV_AT_ME) && -1 !== n.indexOf(k.CONV_AT_ALL) && (n = [k.CONV_AT_ALL_AT_ME]);const o = { from: e.from, groupID: e.groupID, messageSequence: e.sequence, atTypeArray: n, __random: e.__random, __sequence: e.__sequence };this.groupAtInfoList.push(o), Ee.debug('Conversation.updateGroupAtInfoList conversationID:'.concat(this.conversationID), this.groupAtInfoList)
    } }, { key: 'clearGroupAtInfoList', value() {
      this.groupAtInfoList.length = 0
    } }, { key: 'reduceUnreadCount', value() {
      this.unreadCount >= 1 && (this.unreadCount -= 1)
    } }, { key: 'isLastMessageRevoked', value(e) {
      const t = e.sequence; const n = e.time;return this.type === k.CONV_C2C && t === this.lastMessage.lastSequence && n === this.lastMessage.lastTime || this.type === k.CONV_GROUP && t === this.lastMessage.lastSequence
    } }, { key: 'setLastMessageRevoked', value(e) {
      this.lastMessage.isRevoked = e
    } }]), e
  }()); const Ur = (function (e) {
    i(a, e);const n = f(a);function a(e) {
      let t;return o(this, a), (t = n.call(this, e))._className = 'ConversationModule', Dr.mixin(h(t)), t._messageListHandler = new yr, t.singlyLinkedList = new Lr(100), t._pagingStatus = ft.NOT_START, t._pagingTimeStamp = 0, t._conversationMap = new Map, t._tmpGroupList = [], t._tmpGroupAtTipsList = [], t._peerReadTimeMap = new Map, t._completedMap = new Map, t._roamingMessageKeyMap = new Map, t._initListeners(), t
    } return s(a, [{ key: '_initListeners', value() {
      this.getInnerEmitterInstance().on(Ir.CONTEXT_A2KEY_AND_TINYID_UPDATED, this._initLocalConversationList, this)
    } }, { key: 'onCheckTimer', value(e) {
      e % 60 == 0 && this._messageListHandler.traversal()
    } }, { key: '_initLocalConversationList', value() {
      const e = this; const t = new Da(Qa);Ee.log(''.concat(this._className, '._initLocalConversationList.'));let n = ''; const o = this._getStorageConversationList();if (o) {
        for (var a = o.length, s = 0;s < a;s++) {
          const r = o[s];if (r && r.groupProfile) {
            const i = r.groupProfile.type;if (et(i)) continue
          } this._conversationMap.set(o[s].conversationID, new br(o[s]))
        } this._emitConversationUpdate(!0, !1), n = 'count:'.concat(a)
      } else n = 'count:0';t.setNetworkType(this.getNetworkType()).setMessage(n)
        .end(), this.getModule(Nt) || this.triggerReady(), this.ready((() => {
        e._tmpGroupList.length > 0 && (e.updateConversationGroupProfile(e._tmpGroupList), e._tmpGroupList.length = 0)
      })), this._syncConversationList()
    } }, { key: 'onMessageSent', value(e) {
      this._onSendOrReceiveMessage(e.conversationOptionsList, !0)
    } }, { key: 'onNewMessage', value(e) {
      this._onSendOrReceiveMessage(e.conversationOptionsList, e.isInstantMessage)
    } }, { key: '_onSendOrReceiveMessage', value(e) {
      const t = this; const n = !(arguments.length > 1 && void 0 !== arguments[1]) || arguments[1];this._isReady ? 0 !== e.length && (this._getC2CPeerReadTime(e), this._updateLocalConversationList(e, !1, n), this._setStorageConversationList(), this._emitConversationUpdate()) : this.ready((() => {
        t._onSendOrReceiveMessage(e, n)
      }))
    } }, { key: 'updateConversationGroupProfile', value(e) {
      const t = this;Re(e) && 0 === e.length || (0 !== this._conversationMap.size ? (e.forEach(((e) => {
        const n = 'GROUP'.concat(e.groupID);if (t._conversationMap.has(n)) {
          const o = t._conversationMap.get(n);o.groupProfile = e, o.lastMessage.lastSequence < e.nextMessageSeq && (o.lastMessage.lastSequence = e.nextMessageSeq - 1), o.subType || (o.subType = e.type)
        }
      })), this._emitConversationUpdate(!0, !1)) : this._tmpGroupList = e)
    } }, { key: '_updateConversationUserProfile', value(e) {
      const t = this;e.data.forEach(((e) => {
        const n = 'C2C'.concat(e.userID);t._conversationMap.has(n) && (t._conversationMap.get(n).userProfile = e)
      })), this._emitConversationUpdate(!0, !1)
    } }, { key: 'onMessageRevoked', value(e) {
      const t = this;if (0 !== e.length) {
        let n = null; let o = !1;e.forEach(((e) => {
          (n = t._conversationMap.get(e.conversationID)) && n.isLastMessageRevoked(e) && (o = !0, n.setLastMessageRevoked(!0))
        })), o && this._emitConversationUpdate(!0, !1)
      }
    } }, { key: 'onMessageDeleted', value(e) {
      if (0 !== e.length) {
        e.forEach(((e) => {
          e.isDeleted = !0
        }));for (var t = e[0].conversationID, n = this._messageListHandler.getLocalMessageList(t), o = {}, a = n.length - 1;a > 0;a--) if (!n[a].isDeleted) {
          o = n[a];break
        } const s = this._conversationMap.get(t);if (s) {
          let r = !1;s.lastMessage.lastSequence !== o.sequence && s.lastMessage.lastTime !== o.time && (s.updateLastMessage(o), r = !0, Ee.log(''.concat(this._className, '.onMessageDeleted. update conversationID:').concat(t, ' with lastMessage:'), s.lastMessage)), t.startsWith(k.CONV_C2C) && this.updateUnreadCount(t), r && this._emitConversationUpdate(!0, !1)
        }
      }
    } }, { key: 'onNewGroupAtTips', value(e) {
      const t = this; const n = e.dataList; let o = null;n.forEach(((e) => {
        e.groupAtTips ? o = e.groupAtTips : e.elements && (o = e.elements), o.__random = e.random, o.__sequence = e.clientSequence, t._tmpGroupAtTipsList.push(o)
      })), Ee.debug(''.concat(this._className, '.onNewGroupAtTips isReady:').concat(this._isReady), this._tmpGroupAtTipsList), this._isReady && this._handleGroupAtTipsList()
    } }, { key: '_handleGroupAtTipsList', value() {
      const e = this;if (0 !== this._tmpGroupAtTipsList.length) {
        let t = !1;this._tmpGroupAtTipsList.forEach(((n) => {
          const o = n.groupID;if (n.from !== e.getMyUserID()) {
            const a = e._conversationMap.get(''.concat(k.CONV_GROUP).concat(o));a && (a.updateGroupAtInfoList(n), t = !0)
          }
        })), t && this._emitConversationUpdate(!0, !1), this._tmpGroupAtTipsList.length = 0
      }
    } }, { key: '_getC2CPeerReadTime', value(e) {
      const t = this; const n = [];if (e.forEach(((e) => {
        t._conversationMap.has(e.conversationID) || e.type !== k.CONV_C2C || n.push(e.conversationID.replace(k.CONV_C2C, ''))
      })), n.length > 0) {
        Ee.debug(''.concat(this._className, '._getC2CPeerReadTime userIDList:').concat(n));const o = this.getModule(Nt);o && o.getRemotePeerReadTime(n)
      }
    } }, { key: '_getStorageConversationList', value() {
      return this.getModule(wt).getItem('conversationMap')
    } }, { key: '_setStorageConversationList', value() {
      const e = this.getLocalConversationList().slice(0, 20)
        .map(((e) => ({ conversationID: e.conversationID, type: e.type, subType: e.subType, lastMessage: e.lastMessage, groupProfile: e.groupProfile, userProfile: e.userProfile })));this.getModule(wt).setItem('conversationMap', e)
    } }, { key: '_emitConversationUpdate', value() {
      const e = !(arguments.length > 0 && void 0 !== arguments[0]) || arguments[0]; const t = !(arguments.length > 1 && void 0 !== arguments[1]) || arguments[1]; const n = M(this._conversationMap.values());if (t) {
        const o = this.getModule(At);o && o.updateGroupLastMessage(n)
      }e && this.emitOuterEvent(E.CONVERSATION_LIST_UPDATED, n)
    } }, { key: 'getLocalConversationList', value() {
      return M(this._conversationMap.values())
    } }, { key: 'getLocalConversation', value(e) {
      return this._conversationMap.get(e)
    } }, { key: '_syncConversationList', value() {
      const e = this; const t = new Da(Za);return this._pagingStatus === ft.NOT_START && this._conversationMap.clear(), this._pagingGetConversationList().then(((n) => (e._pagingStatus = ft.RESOLVED, e._setStorageConversationList(), e._handleC2CPeerReadTime(), e.checkAndPatchRemark(), t.setMessage(e._conversationMap.size).setNetworkType(e.getNetworkType())
        .end(), n)))
        .catch(((n) => (e._pagingStatus = ft.REJECTED, t.setMessage(e._pagingTimeStamp), e.probeNetwork().then(((e) => {
          const o = m(e, 2); const a = o[0]; const s = o[1];t.setError(n, a, s).end()
        })), Mr(n))))
    } }, { key: '_pagingGetConversationList', value() {
      const e = this; const t = ''.concat(this._className, '._pagingGetConversationList');return this._pagingStatus = ft.PENDING, this.request({ protocolName: gn, requestData: { fromAccount: this.getMyUserID(), timeStamp: this._pagingTimeStamp, orderType: 1, messageAssistFlags: 4 } }).then(((n) => {
        const o = n.data; const a = o.completeFlag; const s = o.conversations; const r = void 0 === s ? [] : s; const i = o.timeStamp;if (Ee.log(''.concat(t, ' completeFlag:').concat(a, ' count:')
          .concat(r.length)), r.length > 0) {
          const c = e._getConversationOptions(r);e._updateLocalConversationList(c, !0)
        } if (e._isReady)e._emitConversationUpdate();else {
          if (!e.isLoggedIn()) return mr();e.triggerReady()
        } return e._pagingTimeStamp = i, 1 !== a ? e._pagingGetConversationList() : (e._handleGroupAtTipsList(), mr())
      }))
        .catch(((n) => {
          throw e.isLoggedIn() && (e._isReady || (Ee.warn(''.concat(t, ' failed. error:'), n), e.triggerReady())), n
        }))
    } }, { key: '_updateLocalConversationList', value(e, t, n) {
      let o; const a = Date.now();o = this._getTmpConversationListMapping(e, t, n), this._conversationMap = new Map(this._sortConversationList([].concat(M(o.toBeUpdatedConversationList), M(this._conversationMap)))), t || this._updateUserOrGroupProfile(o.newConversationList), Ee.debug(''.concat(this._className, '._updateLocalConversationList cost ').concat(Date.now() - a, ' ms'))
    } }, { key: '_getTmpConversationListMapping', value(e, t, n) {
      for (var o = [], a = [], s = this.getModule(At), r = this.getModule(Ot), i = 0, c = e.length;i < c;i++) {
        const u = new br(e[i]); const l = u.conversationID;if (this._conversationMap.has(l)) {
          const d = this._conversationMap.get(l); const g = ['unreadCount', 'allowType', 'adminForbidType', 'payload'];n || g.push('lastMessage'), Ke(d, u, g, [null, void 0, '', 0, NaN]), d.updateUnreadCount(u.unreadCount, t), n && (d.lastMessage.payload = e[i].lastMessage.payload), e[i].lastMessage && d.lastMessage.cloudCustomData !== e[i].lastMessage.cloudCustomData && (d.lastMessage.cloudCustomData = e[i].lastMessage.cloudCustomData || ''), this._conversationMap.delete(l), o.push([l, d])
        } else {
          if (u.type === k.CONV_GROUP && s) {
            const p = u.groupProfile.groupID; const h = s.getLocalGroupProfile(p);h && (u.groupProfile = h, u.updateUnreadCount(0))
          } else if (u.type === k.CONV_C2C) {
            const _ = l.replace(k.CONV_C2C, '');r && r.isMyFriend(_) && (u.remark = r.getFriendRemark(_))
          }a.push(u), o.push([l, u])
        }
      } return { toBeUpdatedConversationList: o, newConversationList: a }
    } }, { key: '_sortConversationList', value(e) {
      return e.sort(((e, t) => t[1].lastMessage.lastTime - e[1].lastMessage.lastTime))
    } }, { key: '_updateUserOrGroupProfile', value(e) {
      const t = this;if (0 !== e.length) {
        const n = []; const o = []; const a = this.getModule(Ct); const s = this.getModule(At);e.forEach(((e) => {
          if (e.type === k.CONV_C2C)n.push(e.toAccount);else if (e.type === k.CONV_GROUP) {
            const t = e.toAccount;s.hasLocalGroup(t) ? e.groupProfile = s.getLocalGroupProfile(t) : o.push(t)
          }
        })), Ee.log(''.concat(this._className, '._updateUserOrGroupProfile c2cUserIDList:').concat(n, ' groupIDList:')
          .concat(o)), n.length > 0 && a.getUserProfile({ userIDList: n }).then(((e) => {
          const n = e.data;Re(n) ? n.forEach(((e) => {
            t._conversationMap.get('C2C'.concat(e.userID)).userProfile = e
          })) : t._conversationMap.get('C2C'.concat(n.userID)).userProfile = n
        })), o.length > 0 && s.getGroupProfileAdvance({ groupIDList: o, responseFilter: { groupBaseInfoFilter: ['Type', 'Name', 'FaceUrl'] } }).then(((e) => {
          e.data.successGroupList.forEach(((e) => {
            const n = 'GROUP'.concat(e.groupID);if (t._conversationMap.has(n)) {
              const o = t._conversationMap.get(n);Ke(o.groupProfile, e, [], [null, void 0, '', 0, NaN]), !o.subType && e.type && (o.subType = e.type)
            }
          }))
        }))
      }
    } }, { key: '_getConversationOptions', value(e) {
      const t = []; const n = e.filter(((e) => {
        const t = e.lastMsg;return Le(t)
      })).map(((e) => {
        if (1 === e.type) {
          const n = { userID: e.userID, nick: e.c2CNick, avatar: e.c2CImage };return t.push(n), { conversationID: 'C2C'.concat(e.userID), type: 'C2C', lastMessage: { lastTime: e.time, lastSequence: e.sequence, fromAccount: e.lastC2CMsgFromAccount, messageForShow: e.messageShow, type: e.lastMsg.elements[0] ? e.lastMsg.elements[0].type : null, payload: e.lastMsg.elements[0] ? e.lastMsg.elements[0].content : null, cloudCustomData: e.cloudCustomData || '', isRevoked: 8 === e.lastMessageFlag, onlineOnlyFlag: !1 }, userProfile: new Ar(n), peerReadTime: e.c2cPeerReadTime }
        } return { conversationID: 'GROUP'.concat(e.groupID), type: 'GROUP', lastMessage: { lastTime: e.time, lastSequence: e.messageReadSeq + e.unreadCount, fromAccount: e.msgGroupFromAccount, messageForShow: e.messageShow, type: e.lastMsg.elements[0] ? e.lastMsg.elements[0].type : null, payload: e.lastMsg.elements[0] ? e.lastMsg.elements[0].content : null, cloudCustomData: e.cloudCustomData || '', isRevoked: 2 === e.lastMessageFlag, onlineOnlyFlag: !1 }, groupProfile: new Gr({ groupID: e.groupID, name: e.groupNick, avatar: e.groupImage }), unreadCount: e.unreadCount, peerReadTime: 0 }
      }));t.length > 0 && this.getModule(Ct).onConversationsProfileUpdated(t);return n
    } }, { key: 'getLocalMessageList', value(e) {
      return this._messageListHandler.getLocalMessageList(e)
    } }, { key: 'deleteLocalMessage', value(e) {
      e instanceof ir && this._messageListHandler.remove(e)
    } }, { key: 'getMessageList', value(e) {
      const t = this; const n = e.conversationID; const o = e.nextReqMessageID; let a = e.count; const s = ''.concat(this._className, '.getMessageList'); const r = this.getLocalConversation(n); let i = '';if (r && r.groupProfile && (i = r.groupProfile.type), et(i)) return Ee.log(''.concat(s, ' not available in avchatroom. conversationID:').concat(n)), mr({ messageList: [], nextReqMessageID: '', isCompleted: !0 });(Ge(a) || a > 15) && (a = 15);let c = this._computeLeftCount({ conversationID: n, nextReqMessageID: o });return Ee.log(''.concat(s, ' conversationID:').concat(n, ' leftCount:')
        .concat(c, ' count:')
        .concat(a, ' nextReqMessageID:')
        .concat(o)), this._needGetHistory({ conversationID: n, leftCount: c, count: a }) ? this.getHistoryMessages({ conversationID: n, nextReqMessageID: o, count: 20 }).then((() => (c = t._computeLeftCount({ conversationID: n, nextReqMessageID: o }), cr(t._computeResult({ conversationID: n, nextReqMessageID: o, count: a, leftCount: c }))))) : (Ee.log(''.concat(s, '.getMessageList get message list from memory')), this.modifyMessageList(n), mr(this._computeResult({ conversationID: n, nextReqMessageID: o, count: a, leftCount: c })))
    } }, { key: '_computeLeftCount', value(e) {
      const t = e.conversationID; const n = e.nextReqMessageID;return n ? this._messageListHandler.getLocalMessageList(t).findIndex(((e) => e.ID === n)) : this._getMessageListSize(t)
    } }, { key: '_getMessageListSize', value(e) {
      return this._messageListHandler.getLocalMessageList(e).length
    } }, { key: '_needGetHistory', value(e) {
      const t = e.conversationID; const n = e.leftCount; const o = e.count; const a = this.getLocalConversation(t); let s = '';return a && a.groupProfile && (s = a.groupProfile.type), !nt(t) && !et(s) && (n < o && !this._completedMap.has(t))
    } }, { key: '_computeResult', value(e) {
      const t = e.conversationID; const n = e.nextReqMessageID; const o = e.count; const a = e.leftCount; const s = this._computeMessageList({ conversationID: t, nextReqMessageID: n, count: o }); const r = this._computeIsCompleted({ conversationID: t, leftCount: a, count: o }); const i = this._computeNextReqMessageID({ messageList: s, isCompleted: r, conversationID: t }); const c = ''.concat(this._className, '._computeResult. conversationID:').concat(t);return Ee.log(''.concat(c, ' leftCount:').concat(a, ' count:')
        .concat(o, ' nextReqMessageID:')
        .concat(i, ' isCompleted:')
        .concat(r)), { messageList: s, nextReqMessageID: i, isCompleted: r }
    } }, { key: '_computeMessageList', value(e) {
      const t = e.conversationID; const n = e.nextReqMessageID; const o = e.count; const a = this._messageListHandler.getLocalMessageList(t); const s = this._computeIndexEnd({ nextReqMessageID: n, messageList: a }); const r = this._computeIndexStart({ indexEnd: s, count: o });return a.slice(r, s)
    } }, { key: '_computeNextReqMessageID', value(e) {
      const t = e.messageList; const n = e.isCompleted; const o = e.conversationID;if (!n) return 0 === t.length ? '' : t[0].ID;const a = this._messageListHandler.getLocalMessageList(o);return 0 === a.length ? '' : a[0].ID
    } }, { key: '_computeIndexEnd', value(e) {
      const t = e.messageList; const n = void 0 === t ? [] : t; const o = e.nextReqMessageID;return o ? n.findIndex(((e) => e.ID === o)) : n.length
    } }, { key: '_computeIndexStart', value(e) {
      const t = e.indexEnd; const n = e.count;return t > n ? t - n : 0
    } }, { key: '_computeIsCompleted', value(e) {
      const t = e.conversationID;return !!(e.leftCount <= e.count && this._completedMap.has(t))
    } }, { key: 'getHistoryMessages', value(e) {
      const t = e.conversationID; const n = e.nextReqMessageID;if (t === k.CONV_SYSTEM) return mr();e.count ? e.count > 20 && (e.count = 20) : e.count = 15;let o = this._messageListHandler.getLocalOldestMessageByConversationID(t);o || ((o = {}).time = 0, o.sequence = 0, 0 === t.indexOf(k.CONV_C2C) ? (o.to = t.replace(k.CONV_C2C, ''), o.conversationType = k.CONV_C2C) : 0 === t.indexOf(k.CONV_GROUP) && (o.to = t.replace(k.CONV_GROUP, ''), o.conversationType = k.CONV_GROUP));let a = ''; let s = null;switch (o.conversationType) {
        case k.CONV_C2C:return a = t.replace(k.CONV_C2C, ''), (s = this.getModule(Nt)) ? s.getRoamingMessage({ conversationID: e.conversationID, peerAccount: a, count: e.count, lastMessageTime: this._roamingMessageKeyMap.has(t) ? o.time : 0, messageKey: this._roamingMessageKeyMap.get(t) }) : Mr({ code: Zn.CANNOT_FIND_MODULE, message: ra });case k.CONV_GROUP:return (s = this.getModule(At)) ? s.getRoamingMessage({ conversationID: e.conversationID, groupID: o.to, count: e.count, sequence: n && !1 === o.getOnlineOnlyFlag() ? o.sequence - 1 : o.sequence }) : Mr({ code: Zn.CANNOT_FIND_MODULE, message: ra });default:return mr()
      }
    } }, { key: 'patchConversationLastMessage', value(e) {
      const t = this.getLocalConversation(e);if (t) {
        const n = t.lastMessage; const o = n.messageForShow; const a = n.payload;if (dt(o) || dt(a)) {
          const s = this._messageListHandler.getLocalMessageList(e);if (0 === s.length) return;const r = s[s.length - 1];Ee.log(''.concat(this._className, '.patchConversationLastMessage conversationID:').concat(e, ' payload:'), r.payload), t.updateLastMessage(r)
        }
      }
    } }, { key: 'storeRoamingMessage', value() {
      const e = arguments.length > 0 && void 0 !== arguments[0] ? arguments[0] : []; const n = arguments.length > 1 ? arguments[1] : void 0; const o = n.startsWith(k.CONV_C2C) ? k.CONV_C2C : k.CONV_GROUP; let a = null; const s = []; let r = 0; let i = e.length; let c = null; const u = o === k.CONV_GROUP; const l = this.getModule(Ut); let d = function () {
        r = u ? e.length - 1 : 0, i = u ? 0 : e.length
      }; let g = function () {
        u ? --r : ++r
      }; let p = function () {
        return u ? r >= i : r < i
      };for (d();p();g()) if (u && 1 === e[r].sequence && this.setCompleted(n), 1 !== e[r].isPlaceMessage) if ((a = new ir(e[r])).to = e[r].to, a.isSystemMessage = !!e[r].isSystemMessage, a.conversationType = o, 4 === e[r].event ? c = { type: k.MSG_GRP_TIP, content: t(t({}, e[r].elements), {}, { groupProfile: e[r].groupProfile }) } : (e[r].elements = l.parseElements(e[r].elements, e[r].from), c = e[r].elements), u || a.setNickAndAvatar({ nick: e[r].nick, avatar: e[r].avatar }), dt(c)) {
        const h = new Da(Ba);h.setMessage('from:'.concat(a.from, ' to:').concat(a.to, ' sequence:')
          .concat(a.sequence, ' event:')
          .concat(e[r].event)), h.setNetworkType(this.getNetworkType()).setLevel('warning')
          .end()
      } else a.setElement(c), a.reInitialize(this.getMyUserID()), s.push(a);return this._messageListHandler.unshift(s), d = g = p = null, s
    } }, { key: 'setMessageRead', value(e) {
      const t = e.conversationID; const n = e.messageID; const o = this.getLocalConversation(t);if (Ee.log(''.concat(this._className, '.setMessageRead conversationID:').concat(t, ' unreadCount:')
        .concat(o ? o.unreadCount : 0)), !o) return mr();if (o.type !== k.CONV_GROUP || dt(o.groupAtInfoList) || this.deleteGroupAtTips(t), 0 === o.unreadCount) return mr();const a = this._messageListHandler.getLocalMessage(t, n); let s = null;switch (o.type) {
        case k.CONV_C2C:return (s = this.getModule(Nt)) ? s.setMessageRead({ conversationID: t, lastMessageTime: a ? a.time : o.lastMessage.lastTime }) : Mr({ code: Zn.CANNOT_FIND_MODULE, message: ra });case k.CONV_GROUP:return (s = this._moduleManager.getModule(At)) ? s.setMessageRead({ conversationID: t, lastMessageSeq: a ? a.sequence : o.lastMessage.lastSequence }) : Mr({ code: Zn.CANNOT_FIND_MODULE, message: ra });case k.CONV_SYSTEM:return o.unreadCount = 0, this._emitConversationUpdate(!0, !1), mr();default:return mr()
      }
    } }, { key: 'updateIsReadAfterReadReport', value(e) {
      const t = e.conversationID; const n = e.lastMessageSeq; const o = e.lastMessageTime; const a = this._messageListHandler.getLocalMessageList(t);if (0 !== a.length) for (var s, r = a.length - 1;r >= 0;r--) if (s = a[r], !(o && s.time > o || n && s.sequence > n)) {
        if ('in' === s.flow && s.isRead) break;s.setIsRead(!0)
      }
    } }, { key: 'updateUnreadCount', value(e) {
      const t = this.getLocalConversation(e); const n = this._messageListHandler.getLocalMessageList(e);if (t) {
        const o = t.unreadCount; const a = n.filter(((e) => !e.isRead && !e.getOnlineOnlyFlag() && !e.isDeleted)).length;o !== a && (t.unreadCount = a, Ee.log(''.concat(this._className, '.updateUnreadCount from ').concat(o, ' to ')
          .concat(a, ', conversationID:')
          .concat(e)), this._emitConversationUpdate(!0, !1))
      }
    } }, { key: 'updateIsRead', value(e) {
      const t = this.getLocalConversation(e); const n = this.getLocalMessageList(e);if (t && 0 !== n.length && !nt(t.type)) {
        for (var o = [], a = 0, s = n.length;a < s;a++)'in' !== n[a].flow ? 'out' !== n[a].flow || n[a].isRead || n[a].setIsRead(!0) : o.push(n[a]);let r = 0;if (t.type === k.CONV_C2C) {
          const i = o.slice(-t.unreadCount).filter(((e) => e.isRevoked)).length;r = o.length - t.unreadCount - i
        } else r = o.length - t.unreadCount;for (let c = 0;c < r && !o[c].isRead;c++)o[c].setIsRead(!0)
      }
    } }, { key: 'deleteGroupAtTips', value(e) {
      const t = ''.concat(this._className, '.deleteGroupAtTips');Ee.log(''.concat(t));const n = this._conversationMap.get(e);if (!n) return Promise.resolve();const o = n.groupAtInfoList;if (0 === o.length) return Promise.resolve();const a = this.getMyUserID();return this.request({ protocolName: _n, requestData: { messageListToDelete: o.map(((e) => ({ from: e.from, to: a, messageSeq: e.__sequence, messageRandom: e.__random, groupID: e.groupID }))) } }).then((() => (Ee.log(''.concat(t, ' ok. count:').concat(o.length)), n.clearGroupAtInfoList(), Promise.resolve())))
        .catch(((e) => (Ee.error(''.concat(t, ' failed. error:'), e), Mr(e))))
    } }, { key: 'appendToMessageList', value(e) {
      this._messageListHandler.pushIn(e)
    } }, { key: 'setMessageRandom', value(e) {
      this.singlyLinkedList.set(e.random)
    } }, { key: 'deleteMessageRandom', value(e) {
      this.singlyLinkedList.delete(e.random)
    } }, { key: 'pushIntoMessageList', value(e, t, n) {
      return !(!this._messageListHandler.pushIn(t, n) || this._isMessageFromCurrentInstance(t) && !n) && (e.push(t), !0)
    } }, { key: '_isMessageFromCurrentInstance', value(e) {
      return this.singlyLinkedList.has(e.random)
    } }, { key: 'revoke', value(e, t, n) {
      return this._messageListHandler.revoke(e, t, n)
    } }, { key: 'getPeerReadTime', value(e) {
      return this._peerReadTimeMap.get(e)
    } }, { key: 'recordPeerReadTime', value(e, t) {
      this._peerReadTimeMap.has(e) ? this._peerReadTimeMap.get(e) < t && this._peerReadTimeMap.set(e, t) : this._peerReadTimeMap.set(e, t)
    } }, { key: 'updateMessageIsPeerReadProperty', value(e, t) {
      if (e.startsWith(k.CONV_C2C) && t > 0) {
        const n = this._messageListHandler.updateMessageIsPeerReadProperty(e, t);n.length > 0 && this.emitOuterEvent(E.MESSAGE_READ_BY_PEER, n)
      }
    } }, { key: 'updateMessageIsReadProperty', value(e) {
      const t = this.getLocalConversation(e); const n = this._messageListHandler.getLocalMessageList(e);if (t && 0 !== n.length && !nt(t.type)) {
        for (var o = [], a = 0;a < n.length;a++)'in' !== n[a].flow ? 'out' !== n[a].flow || n[a].isRead || n[a].setIsRead(!0) : o.push(n[a]);let s = 0;if (t.type === k.CONV_C2C) {
          const r = o.slice(-t.unreadCount).filter(((e) => e.isRevoked)).length;s = o.length - t.unreadCount - r
        } else s = o.length - t.unreadCount;for (let i = 0;i < s && !o[i].isRead;i++)o[i].setIsRead(!0)
      }
    } }, { key: 'updateMessageIsModifiedProperty', value(e) {
      this._messageListHandler.updateMessageIsModifiedProperty(e)
    } }, { key: 'setCompleted', value(e) {
      Ee.log(''.concat(this._className, '.setCompleted. conversationID:').concat(e)), this._completedMap.set(e, !0)
    } }, { key: 'updateRoamingMessageKey', value(e, t) {
      this._roamingMessageKeyMap.set(e, t)
    } }, { key: 'getConversationList', value() {
      const e = this; const t = ''.concat(this._className, '.getConversationList');Ee.log(t), this._pagingStatus === ft.REJECTED && (Ee.log(''.concat(t, '. continue to sync conversationList')), this._syncConversationList());const n = new Da(Wa);return this.request({ protocolName: pn, requestData: { fromAccount: this.getMyUserID() } }).then(((o) => {
        const a = o.data.conversations; const s = void 0 === a ? [] : a; const r = e._getConversationOptions(s);return e._updateLocalConversationList(r, !0), e._setStorageConversationList(), e._handleC2CPeerReadTime(), n.setMessage('conversation count: '.concat(s.length)).setNetworkType(e.getNetworkType())
          .end(), Ee.log(''.concat(t, ' ok')), mr({ conversationList: e.getLocalConversationList() })
      }))
        .catch(((o) => (e.probeNetwork().then(((e) => {
          const t = m(e, 2); const a = t[0]; const s = t[1];n.setError(o, a, s).end()
        })), Ee.error(''.concat(t, ' failed. error:'), o), Mr(o))))
    } }, { key: '_handleC2CPeerReadTime', value() {
      let e; const t = S(this._conversationMap);try {
        for (t.s();!(e = t.n()).done;) {
          const n = m(e.value, 2); const o = n[0]; const a = n[1];a.type === k.CONV_C2C && (Ee.debug(''.concat(this._className, '._handleC2CPeerReadTime conversationID:').concat(o, ' peerReadTime:')
            .concat(a.peerReadTime)), this.recordPeerReadTime(o, a.peerReadTime))
        }
      } catch (s) {
        t.e(s)
      } finally {
        t.f()
      }
    } }, { key: 'getConversationProfile', value(e) {
      let t; const n = this;if ((t = this._conversationMap.has(e) ? this._conversationMap.get(e) : new br({ conversationID: e, type: e.slice(0, 3) === k.CONV_C2C ? k.CONV_C2C : k.CONV_GROUP }))._isInfoCompleted || t.type === k.CONV_SYSTEM) return mr({ conversation: t });const o = new Da(Ja); const a = ''.concat(this._className, '.getConversationProfile');return Ee.log(''.concat(a, '. conversationID:').concat(e, ' remark:')
        .concat(t.remark, ' lastMessage:'), t.lastMessage), this._updateUserOrGroupProfileCompletely(t).then(((s) => {
        o.setNetworkType(n.getNetworkType()).setMessage('conversationID:'.concat(e, ' unreadCount:').concat(s.data.conversation.unreadCount))
          .end();const r = n.getModule(Ot);if (r && t.type === k.CONV_C2C) {
          const i = e.replace(k.CONV_C2C, '');if (r.isMyFriend(i)) {
            const c = r.getFriendRemark(i);t.remark !== c && (t.remark = c, Ee.log(''.concat(a, '. conversationID:').concat(e, ' patch remark:')
              .concat(t.remark)))
          }
        } return Ee.log(''.concat(a, ' ok. conversationID:').concat(e)), s
      }))
        .catch(((t) => (n.probeNetwork().then(((n) => {
          const a = m(n, 2); const s = a[0]; const r = a[1];o.setError(t, s, r).setMessage('conversationID:'.concat(e))
            .end()
        })), Ee.error(''.concat(a, ' failed. error:'), t), Mr(t))))
    } }, { key: '_updateUserOrGroupProfileCompletely', value(e) {
      const t = this;return e.type === k.CONV_C2C ? this.getModule(Ct).getUserProfile({ userIDList: [e.toAccount] })
        .then(((n) => {
          const o = n.data;return 0 === o.length ? Mr(new hr({ code: Zn.USER_OR_GROUP_NOT_FOUND, message: Go })) : (e.userProfile = o[0], e._isInfoCompleted = !0, t._unshiftConversation(e), mr({ conversation: e }))
        })) : this.getModule(At).getGroupProfile({ groupID: e.toAccount })
        .then(((n) => (e.groupProfile = n.data.group, e._isInfoCompleted = !0, t._unshiftConversation(e), mr({ conversation: e }))))
    } }, { key: '_unshiftConversation', value(e) {
      e instanceof br && !this._conversationMap.has(e.conversationID) && (this._conversationMap = new Map([[e.conversationID, e]].concat(M(this._conversationMap))), this._setStorageConversationList(), this._emitConversationUpdate(!0, !1))
    } }, { key: 'deleteConversation', value(e) {
      const t = this; const n = { fromAccount: this.getMyUserID(), toAccount: void 0, type: void 0 };if (!this._conversationMap.has(e)) {
        const o = new hr({ code: Zn.CONVERSATION_NOT_FOUND, message: Ro });return Mr(o)
      } switch (this._conversationMap.get(e).type) {
        case k.CONV_C2C:n.type = 1, n.toAccount = e.replace(k.CONV_C2C, '');break;case k.CONV_GROUP:n.type = 2, n.toGroupID = e.replace(k.CONV_GROUP, '');break;case k.CONV_SYSTEM:return this.getModule(At).deleteGroupSystemNotice({ messageList: this._messageListHandler.getLocalMessageList(e) }), this.deleteLocalConversation(e), mr({ conversationID: e });default:var a = new hr({ code: Zn.CONVERSATION_UN_RECORDED_TYPE, message: wo });return Mr(a)
      } const s = new Da(Xa);s.setMessage('conversationID:'.concat(e));const r = ''.concat(this._className, '.deleteConversation');return Ee.log(''.concat(r, '. conversationID:').concat(e)), this.setMessageRead({ conversationID: e }).then((() => t.request({ protocolName: hn, requestData: n })))
        .then((() => (s.setNetworkType(t.getNetworkType()).end(), Ee.log(''.concat(r, ' ok')), t.deleteLocalConversation(e), mr({ conversationID: e }))))
        .catch(((e) => (t.probeNetwork().then(((t) => {
          const n = m(t, 2); const o = n[0]; const a = n[1];s.setError(e, o, a).end()
        })), Ee.error(''.concat(r, ' failed. error:'), e), Mr(e))))
    } }, { key: 'deleteLocalConversation', value(e) {
      this._conversationMap.delete(e), this._setStorageConversationList(), this._messageListHandler.removeByConversationID(e), this._completedMap.delete(e), this._emitConversationUpdate(!0, !1)
    } }, { key: 'isMessageSentByCurrentInstance', value(e) {
      return !(!this._messageListHandler.hasLocalMessage(e.conversationID, e.ID) && !this.singlyLinkedList.has(e.random))
    } }, { key: 'modifyMessageList', value(e) {
      if (e.startsWith(k.CONV_C2C)) {
        const t = Date.now();this._messageListHandler.modifyMessageSentByPeer(e);const n = this.getModule(Ct).getNickAndAvatarByUserID(this.getMyUserID());this._messageListHandler.modifyMessageSentByMe({ conversationID: e, latestNick: n.nick, latestAvatar: n.avatar }), Ee.log(''.concat(this._className, '.modifyMessageList conversationID:').concat(e, ' cost ')
          .concat(Date.now() - t, ' ms'))
      }
    } }, { key: 'updateUserProfileSpecifiedKey', value(e) {
      Ee.log(''.concat(this._className, '.updateUserProfileSpecifiedKey options:'), e);const t = e.conversationID; const n = e.nick; const o = e.avatar;if (this._conversationMap.has(t)) {
        const a = this._conversationMap.get(t).userProfile;Ae(n) && a.nick !== n && (a.nick = n), Ae(o) && a.avatar !== o && (a.avatar = o), this._emitConversationUpdate(!0, !1)
      }
    } }, { key: 'onMyProfileModified', value(e) {
      const n = this; const o = this.getLocalConversationList(); const a = Date.now();o.forEach(((o) => {
        n.modifyMessageSentByMe(t({ conversationID: o.conversationID }, e))
      })), Ee.log(''.concat(this._className, '.onMyProfileModified. modify all messages sent by me, cost ').concat(Date.now() - a, ' ms'))
    } }, { key: 'modifyMessageSentByMe', value(e) {
      this._messageListHandler.modifyMessageSentByMe(e)
    } }, { key: 'getLatestMessageSentByMe', value(e) {
      return this._messageListHandler.getLatestMessageSentByMe(e)
    } }, { key: 'modifyMessageSentByPeer', value(e, t) {
      this._messageListHandler.modifyMessageSentByPeer(e, t)
    } }, { key: 'getLatestMessageSentByPeer', value(e) {
      return this._messageListHandler.getLatestMessageSentByPeer(e)
    } }, { key: 'pushIntoNoticeResult', value(e, t) {
      return !(!this._messageListHandler.pushIn(t) || this.singlyLinkedList.has(t.random)) && (e.push(t), !0)
    } }, { key: 'getGroupLocalLastMessageSequence', value(e) {
      return this._messageListHandler.getGroupLocalLastMessageSequence(e)
    } }, { key: 'checkAndPatchRemark', value() {
      if (0 !== this._conversationMap.size) {
        const e = this.getModule(Ot);if (e) {
          const t = M(this._conversationMap.values()).filter(((e) => e.type === k.CONV_C2C));if (0 !== t.length) {
            let n = !1; let o = 0;t.forEach(((t) => {
              const a = t.conversationID.replace(k.CONV_C2C, '');if (e.isMyFriend(a)) {
                const s = e.getFriendRemark(a);t.remark !== s && (t.remark = s, o += 1, n = !0)
              }
            })), Ee.log(''.concat(this._className, '.checkAndPatchRemark. c2c conversation count:').concat(t.length, ', patched count:')
              .concat(o)), n && this._emitConversationUpdate(!0, !1)
          }
        }
      }
    } }, { key: 'reset', value() {
      Ee.log(''.concat(this._className, '.reset')), this._pagingStatus = ft.NOT_START, this._messageListHandler.reset(), this._roamingMessageKeyMap.clear(), this.singlyLinkedList.reset(), this._peerReadTimeMap.clear(), this._completedMap.clear(), this._conversationMap.clear(), this._pagingTimeStamp = 0, this.resetReady()
    } }]), a
  }(Yt)); const Fr = (function () {
    function e(t) {
      o(this, e), this._groupModule = t, this._className = 'GroupTipsHandler', this._cachedGroupTipsMap = new Map, this._checkCountMap = new Map, this.MAX_CHECK_COUNT = 4
    } return s(e, [{ key: 'onCheckTimer', value(e) {
      e % 1 == 0 && this._cachedGroupTipsMap.size > 0 && this._checkCachedGroupTips()
    } }, { key: '_checkCachedGroupTips', value() {
      const e = this;this._cachedGroupTipsMap.forEach(((t, n) => {
        let o = e._checkCountMap.get(n); const a = e._groupModule.hasLocalGroup(n);Ee.log(''.concat(e._className, '._checkCachedGroupTips groupID:').concat(n, ' hasLocalGroup:')
          .concat(a, ' checkCount:')
          .concat(o)), a ? (e._notifyCachedGroupTips(n), e._checkCountMap.delete(n), e._groupModule.deleteUnjoinedAVChatRoom(n)) : o >= e.MAX_CHECK_COUNT ? (e._deleteCachedGroupTips(n), e._checkCountMap.delete(n)) : (o++, e._checkCountMap.set(n, o))
      }))
    } }, { key: 'onNewGroupTips', value(e) {
      Ee.debug(''.concat(this._className, '.onReceiveGroupTips count:').concat(e.dataList.length));const t = this.newGroupTipsStoredAndSummary(e); const n = t.eventDataList; const o = t.result; const a = t.AVChatRoomMessageList;(a.length > 0 && this._groupModule.onAVChatRoomMessage(a), n.length > 0) && (this._groupModule.getModule(Rt).onNewMessage({ conversationOptionsList: n, isInstantMessage: !0 }), this._groupModule.updateNextMessageSeq(n));o.length > 0 && (this._groupModule.emitOuterEvent(E.MESSAGE_RECEIVED, o), this.handleMessageList(o))
    } }, { key: 'newGroupTipsStoredAndSummary', value(e) {
      for (var n = e.event, o = e.dataList, a = null, s = [], r = [], i = {}, c = [], u = 0, l = o.length;u < l;u++) {
        const d = o[u]; const g = d.groupProfile.groupID; const p = this._groupModule.hasLocalGroup(g);if (p || !this._groupModule.isUnjoinedAVChatRoom(g)) if (p) if (this._groupModule.isMessageFromAVChatroom(g)) {
          const h = Xe(d);h.event = n, c.push(h)
        } else {
          d.currentUser = this._groupModule.getMyUserID(), d.conversationType = k.CONV_GROUP, (a = new ir(d)).setElement({ type: k.MSG_GRP_TIP, content: t(t({}, d.elements), {}, { groupProfile: d.groupProfile }) }), a.isSystemMessage = !1;const _ = this._groupModule.getModule(Rt); const f = a.conversationID;if (6 === n)a.setOnlineOnlyFlag(!0), r.push(a);else if (!_.pushIntoNoticeResult(r, a)) continue;if (6 !== n || !_.getLocalConversation(f)) {
            if (6 !== n) this._groupModule.getModule($t).addMessageSequence({ key: fa, message: a });if (Ge(i[f]))i[f] = s.push({ conversationID: f, unreadCount: 'in' === a.flow && a.getOnlineOnlyFlag() ? 0 : 1, type: a.conversationType, subType: a.conversationSubType, lastMessage: a }) - 1;else {
              const m = i[f];s[m].type = a.conversationType, s[m].subType = a.conversationSubType, s[m].lastMessage = a, 'in' !== a.flow || a.getOnlineOnlyFlag() || s[m].unreadCount++
            }
          }
        } else this._cacheGroupTipsAndProbe({ groupID: g, event: n, item: d })
      } return { eventDataList: s, result: r, AVChatRoomMessageList: c }
    } }, { key: 'handleMessageList', value(e) {
      const t = this;e.forEach(((e) => {
        switch (e.payload.operationType) {
          case 1:t._onNewMemberComeIn(e);break;case 2:t._onMemberQuit(e);break;case 3:t._onMemberKickedOut(e);break;case 4:t._onMemberSetAdmin(e);break;case 5:t._onMemberCancelledAdmin(e);break;case 6:t._onGroupProfileModified(e);break;case 7:t._onMemberInfoModified(e);break;default:Ee.warn(''.concat(t._className, '.handleMessageList unknown operationType:').concat(e.payload.operationType))
        }
      }))
    } }, { key: '_onNewMemberComeIn', value(e) {
      const t = e.payload; const n = t.memberNum; const o = t.groupProfile.groupID; const a = this._groupModule.getLocalGroupProfile(o);a && Ne(n) && (a.memberNum = n)
    } }, { key: '_onMemberQuit', value(e) {
      const t = e.payload; const n = t.memberNum; const o = t.groupProfile.groupID; const a = this._groupModule.getLocalGroupProfile(o);a && Ne(n) && (a.memberNum = n), this._groupModule.deleteLocalGroupMembers(o, e.payload.userIDList)
    } }, { key: '_onMemberKickedOut', value(e) {
      const t = e.payload; const n = t.memberNum; const o = t.groupProfile.groupID; const a = this._groupModule.getLocalGroupProfile(o);a && Ne(n) && (a.memberNum = n), this._groupModule.deleteLocalGroupMembers(o, e.payload.userIDList)
    } }, { key: '_onMemberSetAdmin', value(e) {
      const t = e.payload.groupProfile.groupID; const n = e.payload.userIDList; const o = this._groupModule.getModule(Lt);n.forEach(((e) => {
        const n = o.getLocalGroupMemberInfo(t, e);n && n.updateRole(k.GRP_MBR_ROLE_ADMIN)
      }))
    } }, { key: '_onMemberCancelledAdmin', value(e) {
      const t = e.payload.groupProfile.groupID; const n = e.payload.userIDList; const o = this._groupModule.getModule(Lt);n.forEach(((e) => {
        const n = o.getLocalGroupMemberInfo(t, e);n && n.updateRole(k.GRP_MBR_ROLE_MEMBER)
      }))
    } }, { key: '_onGroupProfileModified', value(e) {
      const t = this; const n = e.payload.newGroupProfile; const o = e.payload.groupProfile.groupID; const a = this._groupModule.getLocalGroupProfile(o);Object.keys(n).forEach(((e) => {
        switch (e) {
          case 'ownerID':t._ownerChanged(a, n);break;default:a[e] = n[e]
        }
      })), this._groupModule.emitGroupListUpdate(!0, !0)
    } }, { key: '_ownerChanged', value(e, t) {
      const n = e.groupID; const o = this._groupModule.getLocalGroupProfile(n); const a = this.tim.context.identifier;if (a === t.ownerID) {
        o.updateGroup({ selfInfo: { role: k.GRP_MBR_ROLE_OWNER } });const s = this._groupModule.getModule(Lt); const r = s.getLocalGroupMemberInfo(n, a); const i = this._groupModule.getLocalGroupProfile(n).ownerID; const c = s.getLocalGroupMemberInfo(n, i);r && r.updateRole(k.GRP_MBR_ROLE_OWNER), c && c.updateRole(k.GRP_MBR_ROLE_MEMBER)
      }
    } }, { key: '_onMemberInfoModified', value(e) {
      const t = e.payload.groupProfile.groupID; const n = this._groupModule.getModule(Lt);e.payload.memberList.forEach(((e) => {
        const o = n.getLocalGroupMemberInfo(t, e.userID);o && e.muteTime && o.updateMuteUntil(e.muteTime)
      }))
    } }, { key: '_cacheGroupTips', value(e, t) {
      this._cachedGroupTipsMap.has(e) || this._cachedGroupTipsMap.set(e, []), this._cachedGroupTipsMap.get(e).push(t)
    } }, { key: '_deleteCachedGroupTips', value(e) {
      this._cachedGroupTipsMap.has(e) && this._cachedGroupTipsMap.delete(e)
    } }, { key: '_notifyCachedGroupTips', value(e) {
      const t = this; const n = this._cachedGroupTipsMap.get(e) || [];n.forEach(((e) => {
        t.onNewGroupTips(e)
      })), this._deleteCachedGroupTips(e), Ee.log(''.concat(this._className, '._notifyCachedGroupTips groupID:').concat(e, ' count:')
        .concat(n.length))
    } }, { key: '_cacheGroupTipsAndProbe', value(e) {
      const t = this; const n = e.groupID; const o = e.event; const a = e.item;this._cacheGroupTips(n, { event: o, dataList: [a] }), this._groupModule.getGroupSimplifiedInfo(n).then(((e) => {
        e.type === k.GRP_AVCHATROOM ? t._groupModule.hasLocalGroup(n) ? t._notifyCachedGroupTips(n) : t._groupModule.setUnjoinedAVChatRoom(n) : (t._groupModule.updateGroupMap([e]), t._notifyCachedGroupTips(n))
      })), this._checkCountMap.has(n) || this._checkCountMap.set(n, 0), Ee.log(''.concat(this._className, '._cacheGroupTipsAndProbe groupID:').concat(n))
    } }, { key: 'reset', value() {
      this._cachedGroupTipsMap.clear(), this._checkCountMap.clear()
    } }]), e
  }()); const qr = (function () {
    function e(t) {
      o(this, e), this._groupModule = t, this._className = 'CommonGroupHandler', this.tempConversationList = null, this._cachedGroupMessageMap = new Map, this._checkCountMap = new Map, this.MAX_CHECK_COUNT = 4, t.getInnerEmitterInstance().once(Ir.CONTEXT_A2KEY_AND_TINYID_UPDATED, this._initGroupList, this)
    } return s(e, [{ key: 'onCheckTimer', value(e) {
      e % 1 == 0 && this._cachedGroupMessageMap.size > 0 && this._checkCachedGroupMessage()
    } }, { key: '_checkCachedGroupMessage', value() {
      const e = this;this._cachedGroupMessageMap.forEach(((t, n) => {
        let o = e._checkCountMap.get(n); const a = e._groupModule.hasLocalGroup(n);Ee.log(''.concat(e._className, '._checkCachedGroupMessage groupID:').concat(n, ' hasLocalGroup:')
          .concat(a, ' checkCount:')
          .concat(o)), a ? (e._notifyCachedGroupMessage(n), e._checkCountMap.delete(n), e._groupModule.deleteUnjoinedAVChatRoom(n)) : o >= e.MAX_CHECK_COUNT ? (e._deleteCachedGroupMessage(n), e._checkCountMap.delete(n)) : (o++, e._checkCountMap.set(n, o))
      }))
    } }, { key: '_initGroupList', value() {
      const e = this;Ee.log(''.concat(this._className, '._initGroupList'));const t = new Da(gs); const n = this._groupModule.getStorageGroupList();if (Re(n) && n.length > 0) {
        n.forEach(((t) => {
          e._groupModule.initGroupMap(t)
        })), this._groupModule.emitGroupListUpdate(!0, !1);const o = this._groupModule.getLocalGroupList().length;t.setNetworkType(this._groupModule.getNetworkType()).setMessage('group count:'.concat(o))
          .end()
      } else t.setNetworkType(this._groupModule.getNetworkType()).setMessage('group count:0')
        .end();Ee.log(''.concat(this._className, '._initGroupList ok')), this.getGroupList()
    } }, { key: 'handleUpdateGroupLastMessage', value(e) {
      const t = ''.concat(this._className, '.handleUpdateGroupLastMessage');if (Ee.debug(''.concat(t, ' conversation count:').concat(e.length, ', local group count:')
        .concat(this._groupModule.getLocalGroupList().length)), 0 !== this._groupModule.getGroupMap().size) {
        for (var n, o, a, s = !1, r = 0, i = e.length;r < i;r++)(n = e[r]).type === k.CONV_GROUP && (o = n.conversationID.split(/^GROUP/)[1], (a = this._groupModule.getLocalGroupProfile(o)) && (a.lastMessage = n.lastMessage, s = !0));s && (this._groupModule.sortLocalGroupList(), this._groupModule.emitGroupListUpdate(!0, !1))
      } else this.tempConversationList = e
    } }, { key: 'onNewGroupMessage', value(e) {
      Ee.debug(''.concat(this._className, '.onNewGroupMessage count:').concat(e.dataList.length));const t = this._newGroupMessageStoredAndSummary(e); const n = t.conversationOptionsList; const o = t.messageList; const a = t.AVChatRoomMessageList;(a.length > 0 && this._groupModule.onAVChatRoomMessage(a), this._groupModule.filterModifiedMessage(o), n.length > 0) && (this._groupModule.getModule(Rt).onNewMessage({ conversationOptionsList: n, isInstantMessage: !0 }), this._groupModule.updateNextMessageSeq(n));const s = this._groupModule.filterUnmodifiedMessage(o);s.length > 0 && this._groupModule.emitOuterEvent(E.MESSAGE_RECEIVED, s), o.length = 0
    } }, { key: '_newGroupMessageStoredAndSummary', value(e) {
      const t = e.dataList; const n = e.event; const o = e.isInstantMessage; let a = null; const s = []; const r = []; const i = []; const c = {}; const u = k.CONV_GROUP; const l = this._groupModule.getModule(Ut); const d = t.length;d > 1 && t.sort(((e, t) => e.sequence - t.sequence));for (let g = 0;g < d;g++) {
        const p = t[g]; const h = p.groupProfile.groupID; const _ = this._groupModule.hasLocalGroup(h);if (_ || !this._groupModule.isUnjoinedAVChatRoom(h)) if (_) if (this._groupModule.isMessageFromAVChatroom(h)) {
          const f = Xe(p);f.event = n, i.push(f)
        } else {
          p.currentUser = this._groupModule.getMyUserID(), p.conversationType = u, p.isSystemMessage = !!p.isSystemMessage, a = new ir(p), p.elements = l.parseElements(p.elements, p.from), a.setElement(p.elements);let m = 1 === t[g].isModified; const M = this._groupModule.getModule(Rt);M.isMessageSentByCurrentInstance(a) ? a.isModified = m : m = !1;const v = this._groupModule.getModule($t);if (o && v.addMessageDelay({ currentTime: Date.now(), time: a.time }), 1 === p.onlineOnlyFlag)a.setOnlineOnlyFlag(!0), r.push(a);else {
            if (!M.pushIntoMessageList(r, a, m)) continue;v.addMessageSequence({ key: fa, message: a });const y = a.conversationID;if (Ge(c[y]))c[y] = s.push({ conversationID: y, unreadCount: 'out' === a.flow ? 0 : 1, type: a.conversationType, subType: a.conversationSubType, lastMessage: a }) - 1;else {
              const I = c[y];s[I].type = a.conversationType, s[I].subType = a.conversationSubType, s[I].lastMessage = a, 'in' === a.flow && s[I].unreadCount++
            }
          }
        } else this._cacheGroupMessageAndProbe({ groupID: h, event: n, item: p })
      } return { conversationOptionsList: s, messageList: r, AVChatRoomMessageList: i }
    } }, { key: 'onGroupMessageRevoked', value(e) {
      Ee.debug(''.concat(this._className, '.onGroupMessageRevoked nums:').concat(e.dataList.length));const t = this._groupModule.getModule(Rt); const n = []; let o = null;e.dataList.forEach(((e) => {
        const a = e.elements.revokedInfos;Ge(a) || a.forEach(((e) => {
          (o = t.revoke('GROUP'.concat(e.groupID), e.sequence, e.random)) && n.push(o)
        }))
      })), 0 !== n.length && (t.onMessageRevoked(n), this._groupModule.emitOuterEvent(E.MESSAGE_REVOKED, n))
    } }, { key: '_groupListTreeShaking', value(e) {
      for (var t = new Map(M(this._groupModule.getGroupMap())), n = 0, o = e.length;n < o;n++)t.delete(e[n].groupID);this._groupModule.hasJoinedAVChatRoom() && this._groupModule.getJoinedAVChatRoom().forEach(((e) => {
        t.delete(e)
      }));for (let a = M(t.keys()), s = 0, r = a.length;s < r;s++) this._groupModule.deleteGroup(a[s])
    } }, { key: 'getGroupList', value(e) {
      const t = this; const n = ''.concat(this._className, '.getGroupList'); const o = new Da(ls);Ee.log(''.concat(n));const a = { introduction: 'Introduction', notification: 'Notification', createTime: 'CreateTime', ownerID: 'Owner_Account', lastInfoTime: 'LastInfoTime', memberNum: 'MemberNum', maxMemberNum: 'MaxMemberNum', joinOption: 'ApplyJoinOption', muteAllMembers: 'ShutUpAllMember' }; const s = ['Type', 'Name', 'FaceUrl', 'NextMsgSeq', 'LastMsgTime']; const r = [];return e && e.groupProfileFilter && e.groupProfileFilter.forEach(((e) => {
        a[e] && s.push(a[e])
      })), this._pagingGetGroupList({ limit: 50, offset: 0, groupBaseInfoFilter: s, groupList: r }).then((() => {
        Ee.log(''.concat(n, ' ok. count:').concat(r.length)), t._groupListTreeShaking(r), t._groupModule.updateGroupMap(r);const e = t._groupModule.getLocalGroupList().length;return o.setNetworkType(t._groupModule.getNetworkType()).setMessage('remote count:'.concat(r.length, ', after tree shaking, local count:').concat(e))
          .end(), t.tempConversationList && (Ee.log(''.concat(n, ' update last message with tempConversationList, count:').concat(t.tempConversationList.length)), t.handleUpdateGroupLastMessage({ data: t.tempConversationList }), t.tempConversationList = null), t._groupModule.emitGroupListUpdate(), cr({ groupList: t._groupModule.getLocalGroupList() })
      }))
        .catch(((e) => (t._groupModule.probeNetwork().then(((t) => {
          const n = m(t, 2); const a = n[0]; const s = n[1];o.setError(e, a, s).end()
        })), Ee.error(''.concat(n, ' failed. error:'), e), Mr(e))))
    } }, { key: '_pagingGetGroupList', value(e) {
      const t = this; const n = ''.concat(this._className, '._pagingGetGroupList'); const o = e.limit; let a = e.offset; const s = e.groupBaseInfoFilter; const r = e.groupList; const i = new Da(_s);return this._groupModule.request({ protocolName: fn, requestData: { memberAccount: this._groupModule.getMyUserID(), limit: o, offset: a, responseFilter: { groupBaseInfoFilter: s, selfInfoFilter: ['Role', 'JoinTime', 'MsgFlag'] } } }).then(((e) => {
        const c = e.data; const u = c.groups; const l = c.totalCount;r.push.apply(r, M(u));const d = a + o; const g = !(l > d);return i.setNetworkType(t._groupModule.getNetworkType()).setMessage('offset:'.concat(a, ' totalCount:').concat(l, ' isCompleted:')
          .concat(g, ' currentCount:')
          .concat(r.length))
          .end(), g ? (Ee.log(''.concat(n, ' ok. totalCount:').concat(l)), cr({ groupList: r })) : (a = d, t._pagingGetGroupList({ limit: o, offset: a, groupBaseInfoFilter: s, groupList: r }))
      }))
        .catch(((e) => (t._groupModule.probeNetwork().then(((t) => {
          const n = m(t, 2); const o = n[0]; const a = n[1];i.setError(e, o, a).end()
        })), Mr(e))))
    } }, { key: '_cacheGroupMessage', value(e, t) {
      this._cachedGroupMessageMap.has(e) || this._cachedGroupMessageMap.set(e, []), this._cachedGroupMessageMap.get(e).push(t)
    } }, { key: '_deleteCachedGroupMessage', value(e) {
      this._cachedGroupMessageMap.has(e) && this._cachedGroupMessageMap.delete(e)
    } }, { key: '_notifyCachedGroupMessage', value(e) {
      const t = this; const n = this._cachedGroupMessageMap.get(e) || [];n.forEach(((e) => {
        t.onNewGroupMessage(e)
      })), this._deleteCachedGroupMessage(e), Ee.log(''.concat(this._className, '._notifyCachedGroupMessage groupID:').concat(e, ' count:')
        .concat(n.length))
    } }, { key: '_cacheGroupMessageAndProbe', value(e) {
      const t = this; const n = e.groupID; const o = e.event; const a = e.item;this._cacheGroupMessage(n, { event: o, dataList: [a] }), this._groupModule.getGroupSimplifiedInfo(n).then(((e) => {
        e.type === k.GRP_AVCHATROOM ? t._groupModule.hasLocalGroup(n) ? t._notifyCachedGroupMessage(n) : t._groupModule.setUnjoinedAVChatRoom(n) : (t._groupModule.updateGroupMap([e]), t._notifyCachedGroupMessage(n))
      })), this._checkCountMap.has(n) || this._checkCountMap.set(n, 0), Ee.log(''.concat(this._className, '._cacheGroupMessageAndProbe groupID:').concat(n))
    } }, { key: 'reset', value() {
      this._cachedGroupMessageMap.clear(), this._checkCountMap.clear(), this._groupModule.getInnerEmitterInstance().once(Ir.CONTEXT_A2KEY_AND_TINYID_UPDATED, this._initGroupList, this)
    } }]), e
  }()); const Vr = (function () {
    function e(t) {
      o(this, e);const n = t.groupModule; const a = t.groupID; const s = t.onInit; const r = t.onSuccess; const i = t.onFail;this._groupModule = n, this._className = 'Polling', this._onInit = s, this._onSuccess = r, this._onFail = i, this._groupID = a, this._timeoutID = -1, this._isRunning = !1, this._pollingInterval = 0, this.MAX_POLLING_INTERVAL = 2e3
    } return s(e, [{ key: 'start', value() {
      Ee.log(''.concat(this._className, '.start')), this._isRunning = !0, this._request()
    } }, { key: 'isRunning', value() {
      return this._isRunning
    } }, { key: '_request', value() {
      const e = this; const t = this._onInit(this._groupID); let n = Gn;this._groupModule.isLoggedIn() || (n = wn), this._groupModule.request({ protocolName: n, requestData: t }).then(((t) => {
        e._onSuccess(e._groupID, t), e.isRunning() && (clearTimeout(e._timeoutID), e._timeoutID = setTimeout(e._request.bind(e), 0))
      }))
        .catch(((t) => {
          e._onFail(e._groupID, t), e.isRunning() && (clearTimeout(e._timeoutID), e._timeoutID = setTimeout(e._request.bind(e), e.MAX_POLLING_INTERVAL))
        }))
    } }, { key: 'stop', value() {
      Ee.log(''.concat(this._className, '.stop')), this._timeoutID > 0 && (clearTimeout(this._timeoutID), this._timeoutID = -1, this._pollingInterval = 0), this._isRunning = !1
    } }]), e
  }()); const Kr = { 3: !0, 4: !0, 5: !0, 6: !0 }; const xr = (function () {
    function e(t) {
      o(this, e), this._groupModule = t, this._className = 'AVChatRoomHandler', this._joinedGroupMap = new Map, this._pollingRequestInfoMap = new Map, this._pollingInstanceMap = new Map, this.sequencesLinkedList = new Lr(100), this.messageIDLinkedList = new Lr(100), this.receivedMessageCount = 0, this._reportMessageStackedCount = 0, this._onlineMemberCountMap = new Map, this.DEFAULT_EXPIRE_TIME = 60
    } return s(e, [{ key: 'hasJoinedAVChatRoom', value() {
      return this._joinedGroupMap.size > 0
    } }, { key: 'checkJoinedAVChatRoomByID', value(e) {
      return this._joinedGroupMap.has(e)
    } }, { key: 'getJoinedAVChatRoom', value() {
      return this._joinedGroupMap.size > 0 ? M(this._joinedGroupMap.keys()) : null
    } }, { key: '_updateRequestData', value(e) {
      return t({}, this._pollingRequestInfoMap.get(e))
    } }, { key: '_handleSuccess', value(e, t) {
      const n = t.data; const o = n.key; const a = n.nextSeq; const s = n.rspMsgList;if (0 !== n.errorCode) {
        const r = this._pollingRequestInfoMap.get(e); const i = new Da(Cs); const c = r ? ''.concat(r.key, '-').concat(r.startSeq) : 'requestInfo is undefined';i.setMessage(''.concat(e, '-').concat(c, '-')
          .concat(t.errorInfo)).setCode(t.errorCode)
          .setNetworkType(this._groupModule.getNetworkType())
          .end(!0)
      } else {
        if (!this.checkJoinedAVChatRoomByID(e)) return;Ae(o) && Ne(a) && this._pollingRequestInfoMap.set(e, { key: o, startSeq: a }), Re(s) && s.length > 0 && (s.forEach(((e) => {
          e.to = e.groupID
        })), this.onMessage(s))
      }
    } }, { key: '_handleFailure', value(e, t) {} }, { key: 'onMessage', value(e) {
      if (Re(e) && 0 !== e.length) {
        let t = null; const n = []; const o = this._getModule(Rt); const a = e.length;a > 1 && e.sort(((e, t) => e.sequence - t.sequence));for (let s = this._getModule(Gt), r = 0;r < a;r++) if (Kr[e[r].event]) {
          this.receivedMessageCount += 1, t = this.packMessage(e[r], e[r].event);const i = 1 === e[r].isModified;if ((s.isUnlimitedAVChatRoom() || !this.sequencesLinkedList.has(t.sequence)) && !this.messageIDLinkedList.has(t.ID)) {
            const c = t.conversationID;if (this.receivedMessageCount % 40 == 0 && this._getModule(Bt).detectMessageLoss(c, this.sequencesLinkedList.data()), null !== this.sequencesLinkedList.tail()) {
              const u = this.sequencesLinkedList.tail().value; const l = t.sequence - u;l > 1 && l <= 20 ? this._getModule(Bt).onMessageMaybeLost(c, u + 1, l - 1) : l < -1 && l >= -20 && this._getModule(Bt).onMessageMaybeLost(c, t.sequence + 1, Math.abs(l) - 1)
            } this.sequencesLinkedList.set(t.sequence), this.messageIDLinkedList.set(t.ID);let d = !1;if (this._isMessageSentByCurrentInstance(t) ? i && (d = !0, t.isModified = i, o.updateMessageIsModifiedProperty(t)) : d = !0, d) {
              if (t.conversationType, k.CONV_SYSTEM, t.conversationType !== k.CONV_SYSTEM) {
                const g = this._getModule($t); const p = t.conversationID.replace(k.CONV_GROUP, '');this._pollingInstanceMap.has(p) ? g.addMessageSequence({ key: Ma, message: t }) : (t.type !== k.MSG_GRP_TIP && g.addMessageDelay({ currentTime: Date.now(), time: t.time }), g.addMessageSequence({ key: ma, message: t }))
              }n.push(t)
            }
          }
        } else Ee.warn(''.concat(this._className, '.onMessage 未处理的 event 类型: ').concat(e[r].event));if (0 !== n.length) {
          this._groupModule.filterModifiedMessage(n);const h = this.packConversationOption(n);if (h.length > 0) this._getModule(Rt).onNewMessage({ conversationOptionsList: h, isInstantMessage: !0 });Ee.debug(''.concat(this._className, '.onMessage count:').concat(n.length)), this._checkMessageStacked(n);const _ = this._groupModule.filterUnmodifiedMessage(n);_.length > 0 && this._groupModule.emitOuterEvent(E.MESSAGE_RECEIVED, _), n.length = 0
        }
      }
    } }, { key: '_checkMessageStacked', value(e) {
      const t = e.length;t >= 100 && (Ee.warn(''.concat(this._className, '._checkMessageStacked 直播群消息堆积数:').concat(e.length, '！可能会导致微信小程序渲染时遇到 "Dom limit exceeded" 的错误，建议接入侧此时只渲染最近的10条消息')), this._reportMessageStackedCount < 5 && (new Da(As).setNetworkType(this._groupModule.getNetworkType())
        .setMessage('count:'.concat(t, ' groupID:').concat(M(this._joinedGroupMap.keys())))
        .setLevel('warning')
        .end(), this._reportMessageStackedCount += 1))
    } }, { key: '_isMessageSentByCurrentInstance', value(e) {
      return !!this._getModule(Rt).isMessageSentByCurrentInstance(e)
    } }, { key: 'packMessage', value(e, t) {
      e.currentUser = this._groupModule.getMyUserID(), e.conversationType = 5 === t ? k.CONV_SYSTEM : k.CONV_GROUP, e.isSystemMessage = !!e.isSystemMessage;const n = new ir(e); const o = this.packElements(e, t);return n.setElement(o), n
    } }, { key: 'packElements', value(e, n) {
      return 4 === n || 6 === n ? (this._updateMemberCountByGroupTips(e), { type: k.MSG_GRP_TIP, content: t(t({}, e.elements), {}, { groupProfile: e.groupProfile }) }) : 5 === n ? { type: k.MSG_GRP_SYS_NOTICE, content: t(t({}, e.elements), {}, { groupProfile: e.groupProfile }) } : this._getModule(Ut).parseElements(e.elements, e.from)
    } }, { key: 'packConversationOption', value(e) {
      for (var t = new Map, n = 0;n < e.length;n++) {
        const o = e[n]; const a = o.conversationID;if (t.has(a)) {
          const s = t.get(a);s.lastMessage = o, 'in' === o.flow && s.unreadCount++
        } else t.set(a, { conversationID: o.conversationID, unreadCount: 'out' === o.flow ? 0 : 1, type: o.conversationType, subType: o.conversationSubType, lastMessage: o })
      } return M(t.values())
    } }, { key: '_updateMemberCountByGroupTips', value(e) {
      const t = e.groupProfile.groupID; const n = e.elements.onlineMemberInfo; const o = void 0 === n ? void 0 : n;if (!dt(o)) {
        const a = o.onlineMemberNum; const s = void 0 === a ? 0 : a; const r = o.expireTime; const i = void 0 === r ? this.DEFAULT_EXPIRE_TIME : r; const c = this._onlineMemberCountMap.get(t) || {}; const u = Date.now();dt(c) ? Object.assign(c, { lastReqTime: 0, lastSyncTime: 0, latestUpdateTime: u, memberCount: s, expireTime: i }) : (c.latestUpdateTime = u, c.memberCount = s), Ee.debug(''.concat(this._className, '._updateMemberCountByGroupTips info:'), c), this._onlineMemberCountMap.set(t, c)
      }
    } }, { key: 'start', value(e) {
      if (this._pollingInstanceMap.has(e)) {
        const t = this._pollingInstanceMap.get(e);t.isRunning() || t.start()
      } else {
        const n = new Vr({ groupModule: this._groupModule, groupID: e, onInit: this._updateRequestData.bind(this), onSuccess: this._handleSuccess.bind(this), onFail: this._handleFailure.bind(this) });n.start(), this._pollingInstanceMap.set(e, n), Ee.log(''.concat(this._className, '.start groupID:').concat(e))
      }
    } }, { key: 'handleJoinResult', value(e) {
      const t = this;return this._preCheck().then((() => {
        const n = e.longPollingKey; const o = e.group; const a = o.groupID;return t._joinedGroupMap.set(a, o), t._groupModule.updateGroupMap([o]), t._groupModule.deleteUnjoinedAVChatRoom(a), t._groupModule.emitGroupListUpdate(!0, !1), Ge(n) ? mr({ status: js, group: o }) : Promise.resolve()
      }))
    } }, { key: 'startRunLoop', value(e) {
      const t = this;return this.handleJoinResult(e).then((() => {
        const n = e.longPollingKey; const o = e.group; const a = o.groupID;return t._pollingRequestInfoMap.set(a, { key: n, startSeq: 0 }), t.start(a), t._groupModule.isLoggedIn() ? mr({ status: js, group: o }) : mr({ status: js })
      }))
    } }, { key: '_preCheck', value() {
      if (this._getModule(Gt).isUnlimitedAVChatRoom()) return Promise.resolve();if (!this.hasJoinedAVChatRoom()) return Promise.resolve();const e = m(this._joinedGroupMap.entries().next().value, 2); const t = e[0]; const n = e[1];if (this._groupModule.isLoggedIn()) {
        if (!(n.selfInfo.role === k.GRP_MBR_ROLE_OWNER || n.ownerID === this._groupModule.getMyUserID())) return this._groupModule.quitGroup(t);this._groupModule.deleteLocalGroupAndConversation(t)
      } else this._groupModule.deleteLocalGroupAndConversation(t);return this.reset(t), Promise.resolve()
    } }, { key: 'joinWithoutAuth', value(e) {
      const t = this; const n = e.groupID; const o = ''.concat(this._className, '.joinWithoutAuth'); const a = new Da(ms);return this._groupModule.request({ protocolName: Dn, requestData: e }).then(((e) => {
        const s = e.data.longPollingKey;if (a.setNetworkType(t._groupModule.getNetworkType()).setMessage('groupID:'.concat(n, ' longPollingKey:').concat(s))
          .end(!0), Ge(s)) return Mr(new hr({ code: Zn.CANNOT_JOIN_NON_AVCHATROOM_WITHOUT_LOGIN, message: Bo }));Ee.log(''.concat(o, ' ok. groupID:').concat(n)), t._getModule(Rt).setCompleted(''.concat(k.CONV_GROUP).concat(n));const r = new Gr({ groupID: n });return t.startRunLoop({ group: r, longPollingKey: s }), cr({ status: js })
      }))
        .catch(((e) => (Ee.error(''.concat(o, ' failed. groupID:').concat(n, ' error:'), e), t._groupModule.probeNetwork().then(((t) => {
          const o = m(t, 2); const s = o[0]; const r = o[1];a.setError(e, s, r).setMessage('groupID:'.concat(n))
            .end(!0)
        })), Mr(e))))
        .finally((() => {
          t._groupModule.getModule(Pt).reportAtOnce()
        }))
    } }, { key: 'getGroupOnlineMemberCount', value(e) {
      const t = this._onlineMemberCountMap.get(e) || {}; const n = Date.now();return dt(t) || n - t.lastSyncTime > 1e3 * t.expireTime && n - t.latestUpdateTime > 1e4 && n - t.lastReqTime > 3e3 ? (t.lastReqTime = n, this._onlineMemberCountMap.set(e, t), this._getGroupOnlineMemberCount(e).then(((e) => cr({ memberCount: e.memberCount })))
        .catch(((e) => Mr(e)))) : mr({ memberCount: t.memberCount })
    } }, { key: '_getGroupOnlineMemberCount', value(e) {
      const t = this; const n = ''.concat(this._className, '._getGroupOnlineMemberCount');return this._groupModule.request({ protocolName: Pn, requestData: { groupID: e } }).then(((o) => {
        const a = t._onlineMemberCountMap.get(e) || {}; const s = o.data; const r = s.onlineMemberNum; const i = void 0 === r ? 0 : r; const c = s.expireTime; const u = void 0 === c ? t.DEFAULT_EXPIRE_TIME : c;Ee.log(''.concat(n, ' ok. groupID:').concat(e, ' memberCount:')
          .concat(i, ' expireTime:')
          .concat(u));const l = Date.now();return dt(a) && (a.lastReqTime = l), t._onlineMemberCountMap.set(e, Object.assign(a, { lastSyncTime: l, latestUpdateTime: l, memberCount: i, expireTime: u })), { memberCount: i }
      }))
        .catch(((o) => (Ee.warn(''.concat(n, ' failed. error:'), o), new Da(ks).setCode(o.code)
          .setMessage('groupID:'.concat(e, ' error:').concat(JSON.stringify(o)))
          .setNetworkType(t._groupModule.getNetworkType())
          .end(), Promise.reject(o))))
    } }, { key: '_getModule', value(e) {
      return this._groupModule.getModule(e)
    } }, { key: 'reset', value(e) {
      if (e) {
        Ee.log(''.concat(this._className, '.reset groupID:').concat(e));const t = this._pollingInstanceMap.get(e);t && t.stop(), this._pollingInstanceMap.delete(e), this._joinedGroupMap.delete(e), this._pollingRequestInfoMap.delete(e), this._onlineMemberCountMap.delete(e)
      } else {
        Ee.log(''.concat(this._className, '.reset all'));let n; const o = S(this._pollingInstanceMap.values());try {
          for (o.s();!(n = o.n()).done;) {
            n.value.stop()
          }
        } catch (a) {
          o.e(a)
        } finally {
          o.f()
        } this._pollingInstanceMap.clear(), this._joinedGroupMap.clear(), this._pollingRequestInfoMap.clear(), this._onlineMemberCountMap.clear()
      } this.sequencesLinkedList.reset(), this.messageIDLinkedList.reset(), this.receivedMessageCount = 0, this._reportMessageStackedCount = 0
    } }]), e
  }()); const Br = 1; const Hr = 15; const jr = (function () {
    function e(t) {
      o(this, e), this._groupModule = t, this._className = 'GroupSystemNoticeHandler', this.pendencyMap = new Map
    } return s(e, [{ key: 'onNewGroupSystemNotice', value(e) {
      const t = e.dataList; const n = e.isSyncingEnded; const o = e.isInstantMessage;Ee.debug(''.concat(this._className, '.onReceiveSystemNotice count:').concat(t.length));const a = this.newSystemNoticeStoredAndSummary({ notifiesList: t, isInstantMessage: o }); const s = a.eventDataList; const r = a.result;s.length > 0 && (this._groupModule.getModule(Rt).onNewMessage({ conversationOptionsList: s, isInstantMessage: o }), this._onReceivedGroupSystemNotice({ result: r, isInstantMessage: o }));o ? r.length > 0 && this._groupModule.emitOuterEvent(E.MESSAGE_RECEIVED, r) : !0 === n && this._clearGroupSystemNotice()
    } }, { key: 'newSystemNoticeStoredAndSummary', value(e) {
      const n = e.notifiesList; const o = e.isInstantMessage; let a = null; const s = n.length; let r = 0; const i = []; const c = { conversationID: k.CONV_SYSTEM, unreadCount: 0, type: k.CONV_SYSTEM, subType: null, lastMessage: null };for (r = 0;r < s;r++) {
        const u = n[r];if (u.elements.operationType !== Hr)u.currentUser = this._groupModule.getMyUserID(), u.conversationType = k.CONV_SYSTEM, u.conversationID = k.CONV_SYSTEM, (a = new ir(u)).setElement({ type: k.MSG_GRP_SYS_NOTICE, content: t(t({}, u.elements), {}, { groupProfile: u.groupProfile }) }), a.isSystemMessage = !0, (1 === a.sequence && 1 === a.random || 2 === a.sequence && 2 === a.random) && (a.sequence = He(), a.random = He(), a.generateMessageID(u.currentUser), Ee.log(''.concat(this._className, '.newSystemNoticeStoredAndSummary sequence and random maybe duplicated, regenerate. ID:').concat(a.ID))), this._groupModule.getModule(Rt).pushIntoNoticeResult(i, a) && (o ? c.unreadCount++ : a.setIsRead(!0), c.subType = a.conversationSubType)
      } return c.lastMessage = i[i.length - 1], { eventDataList: i.length > 0 ? [c] : [], result: i }
    } }, { key: '_clearGroupSystemNotice', value() {
      const e = this;this.getPendencyList().then(((t) => {
        t.forEach(((t) => {
          e.pendencyMap.set(''.concat(t.from, '_').concat(t.groupID, '_')
            .concat(t.to), t)
        }));const n = e._groupModule.getModule(Rt).getLocalMessageList(k.CONV_SYSTEM); const o = [];n.forEach(((t) => {
          const n = t.payload; const a = n.operatorID; const s = n.operationType; const r = n.groupProfile;if (s === Br) {
            const i = ''.concat(a, '_').concat(r.groupID, '_')
              .concat(r.to); const c = e.pendencyMap.get(i);c && Ne(c.handled) && 0 !== c.handled && o.push(t)
          }
        })), e.deleteGroupSystemNotice({ messageList: o })
      }))
    } }, { key: 'deleteGroupSystemNotice', value(e) {
      const t = this; const n = ''.concat(this._className, '.deleteGroupSystemNotice');return Re(e.messageList) && 0 !== e.messageList.length ? (Ee.log(''.concat(n) + e.messageList.map(((e) => e.ID))), this._groupModule.request({ protocolName: Rn, requestData: { messageListToDelete: e.messageList.map(((e) => ({ from: k.CONV_SYSTEM, messageSeq: e.clientSequence, messageRandom: e.random }))) } }).then((() => {
        Ee.log(''.concat(n, ' ok'));const o = t._groupModule.getModule(Rt);return e.messageList.forEach(((e) => {
          o.deleteLocalMessage(e)
        })), cr()
      }))
        .catch(((e) => (Ee.error(''.concat(n, ' error:'), e), Mr(e))))) : mr()
    } }, { key: 'getPendencyList', value(e) {
      const t = this;return this._groupModule.request({ protocolName: Ln, requestData: { startTime: e && e.startTime ? e.startTime : 0, limit: e && e.limit ? e.limit : 10, handleAccount: this._groupModule.getMyUserID() } }).then(((e) => {
        const n = e.data.pendencyList;return 0 !== e.data.nextStartTime ? t.getPendencyList({ startTime: e.data.nextStartTime }).then(((e) => [].concat(M(n), M(e)))) : n
      }))
    } }, { key: '_onReceivedGroupSystemNotice', value(e) {
      const t = this; const n = e.result;e.isInstantMessage && n.forEach(((e) => {
        switch (e.payload.operationType) {
          case 1:break;case 2:t._onApplyGroupRequestAgreed(e);break;case 3:break;case 4:t._onMemberKicked(e);break;case 5:t._onGroupDismissed(e);break;case 6:break;case 7:t._onInviteGroup(e);break;case 8:t._onQuitGroup(e);break;case 9:t._onSetManager(e);break;case 10:t._onDeleteManager(e)
        }
      }))
    } }, { key: '_onApplyGroupRequestAgreed', value(e) {
      const t = this; const n = e.payload.groupProfile.groupID;this._groupModule.hasLocalGroup(n) || this._groupModule.getGroupProfile({ groupID: n }).then(((e) => {
        const n = e.data.group;n && (t._groupModule.updateGroupMap([n]), t._groupModule.emitGroupListUpdate())
      }))
    } }, { key: '_onMemberKicked', value(e) {
      const t = e.payload.groupProfile.groupID;this._groupModule.hasLocalGroup(t) && this._groupModule.deleteLocalGroupAndConversation(t)
    } }, { key: '_onGroupDismissed', value(e) {
      const t = e.payload.groupProfile.groupID;this._groupModule.hasLocalGroup(t) && this._groupModule.deleteLocalGroupAndConversation(t);const n = this._groupModule._AVChatRoomHandler;n && n.checkJoinedAVChatRoomByID(t) && n.reset(t)
    } }, { key: '_onInviteGroup', value(e) {
      const t = this; const n = e.payload.groupProfile.groupID;this._groupModule.hasLocalGroup(n) || this._groupModule.getGroupProfile({ groupID: n }).then(((e) => {
        const n = e.data.group;n && (t._groupModule.updateGroupMap([n]), t._groupModule.emitGroupListUpdate())
      }))
    } }, { key: '_onQuitGroup', value(e) {
      const t = e.payload.groupProfile.groupID;this._groupModule.hasLocalGroup(t) && this._groupModule.deleteLocalGroupAndConversation(t)
    } }, { key: '_onSetManager', value(e) {
      const t = e.payload.groupProfile; const n = t.to; const o = t.groupID; const a = this._groupModule.getModule(Lt).getLocalGroupMemberInfo(o, n);a && a.updateRole(k.GRP_MBR_ROLE_ADMIN)
    } }, { key: '_onDeleteManager', value(e) {
      const t = e.payload.groupProfile; const n = t.to; const o = t.groupID; const a = this._groupModule.getModule(Lt).getLocalGroupMemberInfo(o, n);a && a.updateRole(k.GRP_MBR_ROLE_MEMBER)
    } }, { key: 'reset', value() {
      this.pendencyMap.clear()
    } }]), e
  }()); const $r = (function (e) {
    i(a, e);const n = f(a);function a(e) {
      let t;return o(this, a), (t = n.call(this, e))._className = 'GroupModule', t._commonGroupHandler = null, t._AVChatRoomHandler = null, t._groupSystemNoticeHandler = null, t._commonGroupHandler = new qr(h(t)), t._AVChatRoomHandler = new xr(h(t)), t._groupTipsHandler = new Fr(h(t)), t._groupSystemNoticeHandler = new jr(h(t)), t.groupMap = new Map, t._unjoinedAVChatRoomList = new Map, t
    } return s(a, [{ key: 'onCheckTimer', value(e) {
      this.isLoggedIn() && (this._commonGroupHandler.onCheckTimer(e), this._groupTipsHandler.onCheckTimer(e))
    } }, { key: 'guardForAVChatRoom', value(e) {
      const t = this;if (e.conversationType === k.CONV_GROUP) {
        const n = e.to;return this.hasLocalGroup(n) ? mr() : this.getGroupProfile({ groupID: n }).then(((o) => {
          const a = o.data.group.type;if (Ee.log(''.concat(t._className, '.guardForAVChatRoom. groupID:').concat(n, ' type:')
            .concat(a)), a === k.GRP_AVCHATROOM) {
            const s = 'userId:'.concat(e.from, ' 未加入群 groupID:').concat(n, '。发消息前先使用 joinGroup 接口申请加群，详细请参考 https://web.sdk.qcloud.com/im/doc/zh-cn/SDK.html#joinGroup');return Ee.warn(''.concat(t._className, '.guardForAVChatRoom sendMessage not allowed. ').concat(s)), Mr(new hr({ code: Zn.MESSAGE_SEND_FAIL, message: s, data: { message: e } }))
          } return mr()
        }))
      } return mr()
    } }, { key: 'checkJoinedAVChatRoomByID', value(e) {
      return !!this._AVChatRoomHandler && this._AVChatRoomHandler.checkJoinedAVChatRoomByID(e)
    } }, { key: 'onNewGroupMessage', value(e) {
      this._commonGroupHandler && this._commonGroupHandler.onNewGroupMessage(e)
    } }, { key: 'updateNextMessageSeq', value(e) {
      const t = this;Re(e) && e.forEach(((e) => {
        const n = e.conversationID.replace(k.CONV_GROUP, '');t.groupMap.has(n) && (t.groupMap.get(n).nextMessageSeq = e.lastMessage.sequence + 1)
      }))
    } }, { key: 'onNewGroupTips', value(e) {
      this._groupTipsHandler && this._groupTipsHandler.onNewGroupTips(e)
    } }, { key: 'onGroupMessageRevoked', value(e) {
      this._commonGroupHandler && this._commonGroupHandler.onGroupMessageRevoked(e)
    } }, { key: 'onNewGroupSystemNotice', value(e) {
      this._groupSystemNoticeHandler && this._groupSystemNoticeHandler.onNewGroupSystemNotice(e)
    } }, { key: 'onGroupMessageReadNotice', value(e) {
      const t = this;e.dataList.forEach(((e) => {
        const n = e.elements.groupMessageReadNotice;if (!Ge(n)) {
          const o = t.getModule(Rt);n.forEach(((e) => {
            const n = e.groupID; const a = e.lastMessageSeq;Ee.debug(''.concat(t._className, '.onGroupMessageReadNotice groupID:').concat(n, ' lastMessageSeq:')
              .concat(a));const s = ''.concat(k.CONV_GROUP).concat(n);o.updateIsReadAfterReadReport({ conversationID: s, lastMessageSeq: a }), o.updateUnreadCount(s)
          }))
        }
      }))
    } }, { key: 'deleteGroupSystemNotice', value(e) {
      this._groupSystemNoticeHandler && this._groupSystemNoticeHandler.deleteGroupSystemNotice(e)
    } }, { key: 'initGroupMap', value(e) {
      this.groupMap.set(e.groupID, new Gr(e))
    } }, { key: 'deleteGroup', value(e) {
      this.groupMap.delete(e)
    } }, { key: 'updateGroupMap', value(e) {
      const t = this;e.forEach(((e) => {
        t.groupMap.has(e.groupID) ? t.groupMap.get(e.groupID).updateGroup(e) : t.groupMap.set(e.groupID, new Gr(e))
      })), this._setStorageGroupList()
    } }, { key: 'getStorageGroupList', value() {
      return this.getModule(wt).getItem('groupMap')
    } }, { key: '_setStorageGroupList', value() {
      const e = this.getLocalGroupList().filter(((e) => {
        const t = e.type;return !et(t)
      }))
        .slice(0, 20)
        .map(((e) => ({ groupID: e.groupID, name: e.name, avatar: e.avatar, type: e.type })));this.getModule(wt).setItem('groupMap', e)
    } }, { key: 'getGroupMap', value() {
      return this.groupMap
    } }, { key: 'getLocalGroupList', value() {
      return M(this.groupMap.values())
    } }, { key: 'getLocalGroupProfile', value(e) {
      return this.groupMap.get(e)
    } }, { key: 'sortLocalGroupList', value() {
      const e = M(this.groupMap).filter(((e) => {
        const t = m(e, 2);t[0];return !dt(t[1].lastMessage)
      }));e.sort(((e, t) => t[1].lastMessage.lastTime - e[1].lastMessage.lastTime)), this.groupMap = new Map(M(e))
    } }, { key: 'updateGroupLastMessage', value(e) {
      this._commonGroupHandler && this._commonGroupHandler.handleUpdateGroupLastMessage(e)
    } }, { key: 'emitGroupListUpdate', value() {
      const e = !(arguments.length > 0 && void 0 !== arguments[0]) || arguments[0]; const t = !(arguments.length > 1 && void 0 !== arguments[1]) || arguments[1]; const n = this.getLocalGroupList();if (e && this.emitOuterEvent(E.GROUP_LIST_UPDATED, n), t) {
        const o = JSON.parse(JSON.stringify(n)); const a = this.getModule(Rt);a.updateConversationGroupProfile(o)
      }
    } }, { key: 'getGroupList', value(e) {
      return this._commonGroupHandler ? this._commonGroupHandler.getGroupList(e) : mr()
    } }, { key: 'getGroupProfile', value(e) {
      const t = this; const n = new Da(ds); const o = ''.concat(this._className, '.getGroupProfile'); const a = e.groupID; const s = e.groupCustomFieldFilter;Ee.log(''.concat(o, ' groupID:').concat(a));const r = { groupIDList: [a], responseFilter: { groupBaseInfoFilter: ['Type', 'Name', 'Introduction', 'Notification', 'FaceUrl', 'Owner_Account', 'CreateTime', 'InfoSeq', 'LastInfoTime', 'LastMsgTime', 'MemberNum', 'MaxMemberNum', 'ApplyJoinOption', 'NextMsgSeq', 'ShutUpAllMember'], groupCustomFieldFilter: s } };return this.getGroupProfileAdvance(r).then(((e) => {
        let s; const r = e.data; const i = r.successGroupList; const c = r.failureGroupList;return Ee.log(''.concat(o, ' ok')), c.length > 0 ? Mr(c[0]) : (et(i[0].type) && !t.hasLocalGroup(a) ? s = new Gr(i[0]) : (t.updateGroupMap(i), s = t.getLocalGroupProfile(a)), n.setNetworkType(t.getNetworkType()).setMessage('groupID:'.concat(a, ' type:').concat(s.type, ' muteAllMembers:')
          .concat(s.muteAllMembers, ' ownerID:')
          .concat(s.ownerID))
          .end(), s && s.selfInfo && !s.selfInfo.nameCard ? t.updateSelfInfo(s).then(((e) => cr({ group: e }))) : cr({ group: s }))
      }))
        .catch(((a) => (t.probeNetwork().then(((t) => {
          const o = m(t, 2); const s = o[0]; const r = o[1];n.setError(a, s, r).setMessage('groupID:'.concat(e.groupID))
            .end()
        })), Ee.error(''.concat(o, ' failed. error:'), a), Mr(a))))
    } }, { key: 'getGroupProfileAdvance', value(e) {
      const t = ''.concat(this._className, '.getGroupProfileAdvance');return Re(e.groupIDList) && e.groupIDList.length > 50 && (Ee.warn(''.concat(t, ' 获取群资料的数量不能超过50个')), e.groupIDList.length = 50), Ee.log(''.concat(t, ' groupIDList:').concat(e.groupIDList)), this.request({ protocolName: mn, requestData: e }).then(((e) => {
        Ee.log(''.concat(t, ' ok'));const n = e.data.groups; const o = n.filter(((e) => Ge(e.errorCode) || 0 === e.errorCode)); const a = n.filter(((e) => e.errorCode && 0 !== e.errorCode)).map(((e) => new hr({ code: e.errorCode, message: e.errorInfo, data: { groupID: e.groupID } })));return cr({ successGroupList: o, failureGroupList: a })
      }))
        .catch(((e) => (Ee.error(''.concat(t, ' failed. error:'), e), Mr(e))))
    } }, { key: 'updateSelfInfo', value(e) {
      const t = ''.concat(this._className, '.updateSelfInfo'); const n = e.groupID;return Ee.log(''.concat(t, ' groupID:').concat(n)), this.getModule(Lt).getGroupMemberProfile({ groupID: n, userIDList: [this.getMyUserID()] })
        .then(((n) => {
          const o = n.data.memberList;return Ee.log(''.concat(t, ' ok')), e && 0 !== o.length && e.updateSelfInfo(o[0]), e
        }))
    } }, { key: 'createGroup', value(e) {
      const n = this; const o = ''.concat(this._className, '.createGroup');if (!['Public', 'Private', 'ChatRoom', 'AVChatRoom'].includes(e.type)) {
        const a = new hr({ code: Zn.ILLEGAL_GROUP_TYPE, message: Po });return Mr(a)
      }et(e.type) && !Ge(e.memberList) && e.memberList.length > 0 && (Ee.warn(''.concat(o, ' 创建 AVChatRoom 时不能添加群成员，自动忽略该字段')), e.memberList = void 0), Ze(e.type) || Ge(e.joinOption) || (Ee.warn(''.concat(o, ' 创建 Work/Meeting/AVChatRoom 群时不能设置字段 joinOption，自动忽略该字段')), e.joinOption = void 0);const s = new Da(es);Ee.log(''.concat(o, ' options:'), e);let r = [];return this.request({ protocolName: Mn, requestData: t(t({}, e), {}, { ownerID: this.getMyUserID(), webPushFlag: 1 }) }).then(((a) => {
        const i = a.data; const c = i.groupID; const u = i.overLimitUserIDList; const l = void 0 === u ? [] : u;if (r = l, s.setNetworkType(n.getNetworkType()).setMessage('groupType:'.concat(e.type, ' groupID:').concat(c, ' overLimitUserIDList=')
          .concat(l))
          .end(), Ee.log(''.concat(o, ' ok groupID:').concat(c, ' overLimitUserIDList:'), l), e.type === k.GRP_AVCHATROOM) return n.getGroupProfile({ groupID: c });dt(e.memberList) || dt(l) || (e.memberList = e.memberList.filter(((e) => -1 === l.indexOf(e.userID)))), n.updateGroupMap([t(t({}, e), {}, { groupID: c })]);const d = n.getModule(kt); const g = d.createCustomMessage({ to: c, conversationType: k.CONV_GROUP, payload: { data: 'group_create', extension: ''.concat(n.getMyUserID(), '创建群组') } });return d.sendMessageInstance(g), n.emitGroupListUpdate(), n.getGroupProfile({ groupID: c })
      }))
        .then(((e) => {
          const t = e.data.group; const n = t.selfInfo; const o = n.nameCard; const a = n.joinTime;return t.updateSelfInfo({ nameCard: o, joinTime: a, messageRemindType: k.MSG_REMIND_ACPT_AND_NOTE, role: k.GRP_MBR_ROLE_OWNER }), cr({ group: t, overLimitUserIDList: r })
        }))
        .catch(((t) => (s.setMessage('groupType:'.concat(e.type)), n.probeNetwork().then(((e) => {
          const n = m(e, 2); const o = n[0]; const a = n[1];s.setError(t, o, a).end()
        })), Ee.error(''.concat(o, ' failed. error:'), t), Mr(t))))
    } }, { key: 'dismissGroup', value(e) {
      const t = this; const n = ''.concat(this._className, '.dismissGroup');if (this.hasLocalGroup(e) && this.getLocalGroupProfile(e).type === k.GRP_WORK) return Mr(new hr({ code: Zn.CANNOT_DISMISS_WORK, message: qo }));const o = new Da(cs);return o.setMessage('groupID:'.concat(e)), Ee.log(''.concat(n, ' groupID:').concat(e)), this.request({ protocolName: vn, requestData: { groupID: e } }).then((() => (o.setNetworkType(t.getNetworkType()).end(), Ee.log(''.concat(n, ' ok')), t.deleteLocalGroupAndConversation(e), t.checkJoinedAVChatRoomByID(e) && t._AVChatRoomHandler.reset(e), cr({ groupID: e }))))
        .catch(((e) => (t.probeNetwork().then(((t) => {
          const n = m(t, 2); const a = n[0]; const s = n[1];o.setError(e, a, s).end()
        })), Ee.error(''.concat(n, ' failed. error:'), e), Mr(e))))
    } }, { key: 'updateGroupProfile', value(e) {
      const t = this; const n = ''.concat(this._className, '.updateGroupProfile');!this.hasLocalGroup(e.groupID) || Ze(this.getLocalGroupProfile(e.groupID).type) || Ge(e.joinOption) || (Ee.warn(''.concat(n, ' Work/Meeting/AVChatRoom 群不能设置字段 joinOption，自动忽略该字段')), e.joinOption = void 0), Ge(e.muteAllMembers) || (e.muteAllMembers ? e.muteAllMembers = 'On' : e.muteAllMembers = 'Off');const o = new Da(us);return o.setMessage(JSON.stringify(e)), Ee.log(''.concat(n, ' groupID:').concat(e.groupID)), this.request({ protocolName: yn, requestData: e }).then((() => {
        (o.setNetworkType(t.getNetworkType()).end(), Ee.log(''.concat(n, ' ok')), t.hasLocalGroup(e.groupID)) && (t.groupMap.get(e.groupID).updateGroup(e), t._setStorageGroupList());return cr({ group: t.groupMap.get(e.groupID) })
      }))
        .catch(((e) => (t.probeNetwork().then(((t) => {
          const n = m(t, 2); const a = n[0]; const s = n[1];o.setError(e, a, s).end()
        })), Ee.log(''.concat(n, ' failed. error:'), e), Mr(e))))
    } }, { key: 'joinGroup', value(e) {
      const t = this; const n = e.groupID; const o = e.type; const a = ''.concat(this._className, '.joinGroup');if (o === k.GRP_WORK) {
        const s = new hr({ code: Zn.CANNOT_JOIN_WORK, message: bo });return Mr(s)
      } if (this.deleteUnjoinedAVChatRoom(n), this.hasLocalGroup(n)) {
        if (!this.isLoggedIn()) return mr({ status: k.JOIN_STATUS_ALREADY_IN_GROUP });const r = new Da(ts);return this.getGroupProfile({ groupID: n }).then((() => (r.setNetworkType(t.getNetworkType()).setMessage('groupID:'.concat(n, ' joinedStatus:').concat(k.JOIN_STATUS_ALREADY_IN_GROUP))
          .end(), mr({ status: k.JOIN_STATUS_ALREADY_IN_GROUP }))))
          .catch(((o) => (r.setNetworkType(t.getNetworkType()).setMessage('groupID:'.concat(n, ' unjoined'))
            .end(), Ee.warn(''.concat(a, ' ').concat(n, ' was unjoined, now join!')), t.groupMap.delete(n), t.applyJoinGroup(e))))
      } return Ee.log(''.concat(a, ' groupID:').concat(n)), this.isLoggedIn() ? this.applyJoinGroup(e) : this._AVChatRoomHandler.joinWithoutAuth(e)
    } }, { key: 'applyJoinGroup', value(e) {
      const t = this; const n = ''.concat(this._className, '.applyJoinGroup'); const o = e.groupID; const a = new Da(ts);return this.request({ protocolName: In, requestData: e }).then(((e) => {
        const s = e.data; const r = s.joinedStatus; const i = s.longPollingKey; const c = s.avChatRoomFlag; const u = 'groupID:'.concat(o, ' joinedStatus:').concat(r, ' longPollingKey:')
          .concat(i, ' avChatRoomFlag:')
          .concat(c);switch (a.setNetworkType(t.getNetworkType()).setMessage(''.concat(u))
          .end(), Ee.log(''.concat(n, ' ok. ').concat(u)), r) {
          case $s:return cr({ status: $s });case js:return t.getGroupProfile({ groupID: o }).then(((e) => {
            const n = e.data.group; const a = { status: js, group: n };return 1 === c ? (t.getModule(Rt).setCompleted(''.concat(k.CONV_GROUP).concat(o)), Ge(i) ? t._AVChatRoomHandler.handleJoinResult({ group: n }) : t._AVChatRoomHandler.startRunLoop({ longPollingKey: i, group: n })) : (t.emitGroupListUpdate(!0, !1), cr(a))
          }));default:var l = new hr({ code: Zn.JOIN_GROUP_FAIL, message: Ko });return Ee.error(''.concat(n, ' error:'), l), Mr(l)
        }
      }))
        .catch(((o) => (a.setMessage('groupID:'.concat(e.groupID)), t.probeNetwork().then(((e) => {
          const t = m(e, 2); const n = t[0]; const s = t[1];a.setError(o, n, s).end()
        })), Ee.error(''.concat(n, ' error:'), o), Mr(o))))
    } }, { key: 'quitGroup', value(e) {
      const t = this; const n = ''.concat(this._className, '.quitGroup');Ee.log(''.concat(n, ' groupID:').concat(e));const o = this.checkJoinedAVChatRoomByID(e);if (!o && !this.hasLocalGroup(e)) {
        const a = new hr({ code: Zn.MEMBER_NOT_IN_GROUP, message: Vo });return Mr(a)
      } if (o && !this.isLoggedIn()) return Ee.log(''.concat(n, ' anonymously ok. groupID:').concat(e)), this.deleteLocalGroupAndConversation(e), this._AVChatRoomHandler.reset(e), mr({ groupID: e });const s = new Da(ns);return s.setMessage('groupID:'.concat(e)), this.request({ protocolName: Tn, requestData: { groupID: e } }).then((() => (s.setNetworkType(t.getNetworkType()).end(), Ee.log(''.concat(n, ' ok')), o && t._AVChatRoomHandler.reset(e), t.deleteLocalGroupAndConversation(e), cr({ groupID: e }))))
        .catch(((e) => (t.probeNetwork().then(((t) => {
          const n = m(t, 2); const o = n[0]; const a = n[1];s.setError(e, o, a).end()
        })), Ee.error(''.concat(n, ' failed. error:'), e), Mr(e))))
    } }, { key: 'searchGroupByID', value(e) {
      const t = this; const n = ''.concat(this._className, '.searchGroupByID'); const o = { groupIDList: [e] }; const a = new Da(os);return a.setMessage('groupID:'.concat(e)), Ee.log(''.concat(n, ' groupID:').concat(e)), this.request({ protocolName: Sn, requestData: o }).then(((e) => {
        const o = e.data.groupProfile;if (0 !== o[0].errorCode) throw new hr({ code: o[0].errorCode, message: o[0].errorInfo });return a.setNetworkType(t.getNetworkType()).end(), Ee.log(''.concat(n, ' ok')), cr({ group: new Gr(o[0]) })
      }))
        .catch(((e) => (t.probeNetwork().then(((t) => {
          const n = m(t, 2); const o = n[0]; const s = n[1];a.setError(e, o, s).end()
        })), Ee.warn(''.concat(n, ' failed. error:'), e), Mr(e))))
    } }, { key: 'changeGroupOwner', value(e) {
      const t = this; const n = ''.concat(this._className, '.changeGroupOwner');if (this.hasLocalGroup(e.groupID) && this.getLocalGroupProfile(e.groupID).type === k.GRP_AVCHATROOM) return Mr(new hr({ code: Zn.CANNOT_CHANGE_OWNER_IN_AVCHATROOM, message: Uo }));if (e.newOwnerID === this.getMyUserID()) return Mr(new hr({ code: Zn.CANNOT_CHANGE_OWNER_TO_SELF, message: Fo }));const o = new Da(as);return o.setMessage('groupID:'.concat(e.groupID, ' newOwnerID:').concat(e.newOwnerID)), Ee.log(''.concat(n, ' groupID:').concat(e.groupID)), this.request({ protocolName: En, requestData: e }).then((() => {
        o.setNetworkType(t.getNetworkType()).end(), Ee.log(''.concat(n, ' ok'));const a = e.groupID; const s = e.newOwnerID;t.groupMap.get(a).ownerID = s;const r = t.getModule(Lt).getLocalGroupMemberList(a);if (r instanceof Map) {
          const i = r.get(t.getMyUserID());Ge(i) || (i.updateRole('Member'), t.groupMap.get(a).selfInfo.role = 'Member');const c = r.get(s);Ge(c) || c.updateRole('Owner')
        } return t.emitGroupListUpdate(!0, !1), cr({ group: t.groupMap.get(a) })
      }))
        .catch(((e) => (t.probeNetwork().then(((t) => {
          const n = m(t, 2); const a = n[0]; const s = n[1];o.setError(e, a, s).end()
        })), Ee.error(''.concat(n, ' failed. error:'), e), Mr(e))))
    } }, { key: 'handleGroupApplication', value(e) {
      const n = this; const o = ''.concat(this._className, '.handleGroupApplication'); const a = e.message.payload; const s = a.groupProfile.groupID; const r = a.authentication; const i = a.messageKey; const c = a.operatorID; const u = new Da(ss);return u.setMessage('groupID:'.concat(s)), Ee.log(''.concat(o, ' groupID:').concat(s)), this.request({ protocolName: kn, requestData: t(t({}, e), {}, { applicant: c, groupID: s, authentication: r, messageKey: i }) }).then((() => (u.setNetworkType(n.getNetworkType()).end(), Ee.log(''.concat(o, ' ok')), n._groupSystemNoticeHandler.deleteGroupSystemNotice({ messageList: [e.message] }), cr({ group: n.getLocalGroupProfile(s) }))))
        .catch(((e) => (n.probeNetwork().then(((t) => {
          const n = m(t, 2); const o = n[0]; const a = n[1];u.setError(e, o, a).end()
        })), Ee.error(''.concat(o, ' failed. error'), e), Mr(e))))
    } }, { key: 'handleGroupInvitation', value(e) {
      const n = this; const o = ''.concat(this._className, '.handleGroupInvitation'); const a = e.message.payload; const s = a.groupProfile.groupID; const r = a.authentication; const i = a.messageKey; const c = a.operatorID; const u = e.handleAction; const l = new Da(rs);return l.setMessage('groupID:'.concat(s, ' inviter:').concat(c, ' handleAction:')
        .concat(u)), Ee.log(''.concat(o, ' groupID:').concat(s, ' inviter:')
        .concat(c, ' handleAction:')
        .concat(u)), this.request({ protocolName: Cn, requestData: t(t({}, e), {}, { inviter: c, groupID: s, authentication: r, messageKey: i }) }).then((() => (l.setNetworkType(n.getNetworkType()).end(), Ee.log(''.concat(o, ' ok')), n._groupSystemNoticeHandler.deleteGroupSystemNotice({ messageList: [e.message] }), cr({ group: n.getLocalGroupProfile(s) }))))
        .catch(((e) => (n.probeNetwork().then(((t) => {
          const n = m(t, 2); const o = n[0]; const a = n[1];l.setError(e, o, a).end()
        })), Ee.error(''.concat(o, ' failed. error'), e), Mr(e))))
    } }, { key: 'getGroupOnlineMemberCount', value(e) {
      return this._AVChatRoomHandler ? this._AVChatRoomHandler.checkJoinedAVChatRoomByID(e) ? this._AVChatRoomHandler.getGroupOnlineMemberCount(e) : mr({ memberCount: 0 }) : Mr({ code: Zn.CANNOT_FIND_MODULE, message: ra })
    } }, { key: 'hasLocalGroup', value(e) {
      return this.groupMap.has(e)
    } }, { key: 'deleteLocalGroupAndConversation', value(e) {
      this._deleteLocalGroup(e), this.getModule(Rt).deleteLocalConversation('GROUP'.concat(e)), this.emitGroupListUpdate(!0, !1)
    } }, { key: '_deleteLocalGroup', value(e) {
      this.groupMap.delete(e), this.getModule(Lt).deleteGroupMemberList(e), this._setStorageGroupList()
    } }, { key: 'sendMessage', value(e, t) {
      const n = this.createGroupMessagePack(e, t);return this.request(n)
    } }, { key: 'createGroupMessagePack', value(e, t) {
      let n = null;t && t.offlinePushInfo && (n = t.offlinePushInfo);let o = '';Ae(e.cloudCustomData) && e.cloudCustomData.length > 0 && (o = e.cloudCustomData);const a = e.getGroupAtInfoList();return { protocolName: en, tjgID: this.generateTjgID(e), requestData: { fromAccount: this.getMyUserID(), groupID: e.to, msgBody: e.getElements(), cloudCustomData: o, random: e.random, priority: e.priority, clientSequence: e.clientSequence, groupAtInfo: e.type !== k.MSG_TEXT || dt(a) ? void 0 : a, onlineOnlyFlag: this.isOnlineMessage(e, t) ? 1 : 0, offlinePushInfo: n ? { pushFlag: !0 === n.disablePush ? 1 : 0, title: n.title || '', desc: n.description || '', ext: n.extension || '', apnsInfo: { badgeMode: !0 === n.ignoreIOSBadge ? 1 : 0 }, androidInfo: { OPPOChannelID: n.androidOPPOChannelID || '' } } : void 0 } }
    } }, { key: 'revokeMessage', value(e) {
      return this.request({ protocolName: Nn, requestData: { to: e.to, msgSeqList: [{ msgSeq: e.sequence }] } })
    } }, { key: 'deleteMessage', value(e) {
      const t = e.to; const n = e.keyList;return Ee.log(''.concat(this._className, '.deleteMessage groupID:').concat(t, ' count:')
        .concat(n.length)), this.request({ protocolName: bn, requestData: { groupID: t, deleter: this.getMyUserID(), keyList: n } })
    } }, { key: 'getRoamingMessage', value(e) {
      const t = this; const n = ''.concat(this._className, '.getRoamingMessage'); const o = new Da(Fa); let a = 0;return this._computeLastSequence(e).then(((n) => (a = n, Ee.log(''.concat(t._className, '.getRoamingMessage groupID:').concat(e.groupID, ' lastSequence:')
        .concat(a)), t.request({ protocolName: On, requestData: { groupID: e.groupID, count: 21, sequence: a } }))))
        .then(((s) => {
          const r = s.data; const i = r.messageList; const c = r.complete;Ge(i) ? Ee.log(''.concat(n, ' ok. complete:').concat(c, ' but messageList is undefined!')) : Ee.log(''.concat(n, ' ok. complete:').concat(c, ' count:')
            .concat(i.length)), o.setNetworkType(t.getNetworkType()).setMessage('groupID:'.concat(e.groupID, ' lastSequence:').concat(a, ' complete:')
            .concat(c, ' count:')
            .concat(i ? i.length : 'undefined'))
            .end();const u = 'GROUP'.concat(e.groupID); const l = t.getModule(Rt);if (2 === c || dt(i)) return l.setCompleted(u), [];const d = l.storeRoamingMessage(i, u);return l.updateIsRead(u), l.patchConversationLastMessage(u), d
        }))
        .catch(((s) => (t.probeNetwork().then(((t) => {
          const n = m(t, 2); const r = n[0]; const i = n[1];o.setError(s, r, i).setMessage('groupID:'.concat(e.groupID, ' lastSequence:').concat(a))
            .end()
        })), Ee.warn(''.concat(n, ' failed. error:'), s), Mr(s))))
    } }, { key: 'setMessageRead', value(e) {
      const t = this; const n = e.conversationID; const o = e.lastMessageSeq; const a = ''.concat(this._className, '.setMessageRead');Ee.log(''.concat(a, ' conversationID:').concat(n, ' lastMessageSeq:')
        .concat(o)), Ne(o) || Ee.warn(''.concat(a, ' 请勿修改 Conversation.lastMessage.lastSequence，否则可能会导致已读上报结果不准确'));const s = new Da(xa);return s.setMessage(''.concat(n, '-').concat(o)), this.request({ protocolName: An, requestData: { groupID: n.replace('GROUP', ''), messageReadSeq: o } }).then((() => {
        s.setNetworkType(t.getNetworkType()).end(), Ee.log(''.concat(a, ' ok.'));const e = t.getModule(Rt);return e.updateIsReadAfterReadReport({ conversationID: n, lastMessageSeq: o }), e.updateUnreadCount(n), cr()
      }))
        .catch(((e) => (t.probeNetwork().then(((t) => {
          const n = m(t, 2); const o = n[0]; const a = n[1];s.setError(e, o, a).end()
        })), Ee.log(''.concat(a, ' failed. error:'), e), Mr(e))))
    } }, { key: '_computeLastSequence', value(e) {
      return e.sequence > 0 ? Promise.resolve(e.sequence) : this.getGroupLastSequence(e.groupID)
    } }, { key: 'getGroupLastSequence', value(e) {
      const t = this; const n = ''.concat(this._className, '.getGroupLastSequence'); const o = new Da(ps); let a = 0; let s = '';if (this.hasLocalGroup(e)) {
        const r = this.getLocalGroupProfile(e); const i = r.lastMessage;if (i.lastSequence > 0 && !1 === i.onlineOnlyFlag) return a = i.lastSequence, s = 'got lastSequence:'.concat(a, ' from local group profile[lastMessage.lastSequence]. groupID:').concat(e), Ee.log(''.concat(n, ' ').concat(s)), o.setNetworkType(this.getNetworkType()).setMessage(''.concat(s))
          .end(), Promise.resolve(a);if (r.nextMessageSeq > 1) return a = r.nextMessageSeq - 1, s = 'got lastSequence:'.concat(a, ' from local group profile[nextMessageSeq]. groupID:').concat(e), Ee.log(''.concat(n, ' ').concat(s)), o.setNetworkType(this.getNetworkType()).setMessage(''.concat(s))
          .end(), Promise.resolve(a)
      } const c = 'GROUP'.concat(e); const u = this.getModule(Rt).getLocalConversation(c);if (u && u.lastMessage.lastSequence && !1 === u.lastMessage.onlineOnlyFlag) return a = u.lastMessage.lastSequence, s = 'got lastSequence:'.concat(a, ' from local conversation profile[lastMessage.lastSequence]. groupID:').concat(e), Ee.log(''.concat(n, ' ').concat(s)), o.setNetworkType(this.getNetworkType()).setMessage(''.concat(s))
        .end(), Promise.resolve(a);const l = { groupIDList: [e], responseFilter: { groupBaseInfoFilter: ['NextMsgSeq'] } };return this.getGroupProfileAdvance(l).then(((r) => {
        const i = r.data.successGroupList;return dt(i) ? Ee.log(''.concat(n, ' successGroupList is empty. groupID:').concat(e)) : (a = i[0].nextMessageSeq - 1, s = 'got lastSequence:'.concat(a, ' from getGroupProfileAdvance. groupID:').concat(e), Ee.log(''.concat(n, ' ').concat(s))), o.setNetworkType(t.getNetworkType()).setMessage(''.concat(s))
          .end(), a
      }))
        .catch(((a) => (t.probeNetwork().then(((t) => {
          const n = m(t, 2); const s = n[0]; const r = n[1];o.setError(a, s, r).setMessage('get lastSequence failed from getGroupProfileAdvance. groupID:'.concat(e))
            .end()
        })), Ee.warn(''.concat(n, ' failed. error:'), a), Mr(a))))
    } }, { key: 'isMessageFromAVChatroom', value(e) {
      return !!this._AVChatRoomHandler && this._AVChatRoomHandler.checkJoinedAVChatRoomByID(e)
    } }, { key: 'hasJoinedAVChatRoom', value() {
      return this._AVChatRoomHandler ? this._AVChatRoomHandler.hasJoinedAVChatRoom() : 0
    } }, { key: 'getJoinedAVChatRoom', value() {
      return this._AVChatRoomHandler ? this._AVChatRoomHandler.getJoinedAVChatRoom() : []
    } }, { key: 'isOnlineMessage', value(e, t) {
      return !(!this._canIUseOnlineOnlyFlag(e) || !t || !0 !== t.onlineUserOnly)
    } }, { key: '_canIUseOnlineOnlyFlag', value(e) {
      const t = this.getJoinedAVChatRoom();return !t || !t.includes(e.to) || e.conversationType !== k.CONV_GROUP
    } }, { key: 'deleteLocalGroupMembers', value(e, t) {
      this.getModule(Lt).deleteLocalGroupMembers(e, t)
    } }, { key: 'onAVChatRoomMessage', value(e) {
      this._AVChatRoomHandler && this._AVChatRoomHandler.onMessage(e)
    } }, { key: 'getGroupSimplifiedInfo', value(e) {
      const t = this; const n = new Da(fs); const o = { groupIDList: [e], responseFilter: { groupBaseInfoFilter: ['Type', 'Name'] } };return this.getGroupProfileAdvance(o).then(((o) => {
        const a = o.data.successGroupList;return n.setNetworkType(t.getNetworkType()).setMessage('groupID:'.concat(e, ' type:').concat(a[0].type))
          .end(), a[0]
      }))
        .catch(((o) => {
          t.probeNetwork().then(((t) => {
            const a = m(t, 2); const s = a[0]; const r = a[1];n.setError(o, s, r).setMessage('groupID:'.concat(e))
              .end()
          }))
        }))
    } }, { key: 'setUnjoinedAVChatRoom', value(e) {
      this._unjoinedAVChatRoomList.set(e, 1)
    } }, { key: 'deleteUnjoinedAVChatRoom', value(e) {
      this._unjoinedAVChatRoomList.has(e) && this._unjoinedAVChatRoomList.delete(e)
    } }, { key: 'isUnjoinedAVChatRoom', value(e) {
      return this._unjoinedAVChatRoomList.has(e)
    } }, { key: 'reset', value() {
      this.groupMap.clear(), this._unjoinedAVChatRoomList.clear(), this._commonGroupHandler.reset(), this._groupSystemNoticeHandler.reset(), this._groupTipsHandler.reset(), this._AVChatRoomHandler && this._AVChatRoomHandler.reset()
    } }]), a
  }(Yt)); const Yr = (function () {
    function e(t) {
      o(this, e), this.userID = '', this.avatar = '', this.nick = '', this.role = '', this.joinTime = '', this.lastSendMsgTime = '', this.nameCard = '', this.muteUntil = 0, this.memberCustomField = [], this._initMember(t)
    } return s(e, [{ key: '_initMember', value(e) {
      this.updateMember(e)
    } }, { key: 'updateMember', value(e) {
      const t = [null, void 0, '', 0, NaN];e.memberCustomField && Qe(this.memberCustomField, e.memberCustomField), Ke(this, e, ['memberCustomField'], t)
    } }, { key: 'updateRole', value(e) {
      ['Owner', 'Admin', 'Member'].indexOf(e) < 0 || (this.role = e)
    } }, { key: 'updateMuteUntil', value(e) {
      Ge(e) || (this.muteUntil = Math.floor((Date.now() + 1e3 * e) / 1e3))
    } }, { key: 'updateNameCard', value(e) {
      Ge(e) || (this.nameCard = e)
    } }, { key: 'updateMemberCustomField', value(e) {
      e && Qe(this.memberCustomField, e)
    } }]), e
  }()); const zr = (function (e) {
    i(a, e);const n = f(a);function a(e) {
      let t;return o(this, a), (t = n.call(this, e))._className = 'GroupMemberModule', t.groupMemberListMap = new Map, t.getInnerEmitterInstance().on(Ir.PROFILE_UPDATED, t._onProfileUpdated, h(t)), t
    } return s(a, [{ key: '_onProfileUpdated', value(e) {
      for (var t = this, n = e.data, o = function (e) {
          const o = n[e];t.groupMemberListMap.forEach(((e) => {
            e.has(o.userID) && e.get(o.userID).updateMember({ nick: o.nick, avatar: o.avatar })
          }))
        }, a = 0;a < n.length;a++)o(a)
    } }, { key: 'deleteGroupMemberList', value(e) {
      this.groupMemberListMap.delete(e)
    } }, { key: 'getGroupMemberList', value(e) {
      const t = this; const n = e.groupID; const o = e.offset; const a = void 0 === o ? 0 : o; const s = e.count; const r = void 0 === s ? 15 : s; const i = ''.concat(this._className, '.getGroupMemberList'); const c = new Da(Ms);Ee.log(''.concat(i, ' groupID:').concat(n, ' offset:')
        .concat(a, ' count:')
        .concat(r));let u = [];return this.request({ protocolName: Un, requestData: { groupID: n, offset: a, limit: r > 100 ? 100 : r } }).then(((e) => {
        const o = e.data; const a = o.members; const s = o.memberNum;if (!Re(a) || 0 === a.length) return Promise.resolve([]);const r = t.getModule(At);return r.hasLocalGroup(n) && (r.getLocalGroupProfile(n).memberNum = s), u = t._updateLocalGroupMemberMap(n, a), t.getModule(Ct).getUserProfile({ userIDList: a.map(((e) => e.userID)), tagList: [Ks.NICK, Ks.AVATAR] })
      }))
        .then(((e) => {
          const o = e.data;if (!Re(o) || 0 === o.length) return mr({ memberList: [] });const s = o.map(((e) => ({ userID: e.userID, nick: e.nick, avatar: e.avatar })));return t._updateLocalGroupMemberMap(n, s), c.setNetworkType(t.getNetworkType()).setMessage('groupID:'.concat(n, ' offset:').concat(a, ' count:')
            .concat(r))
            .end(), Ee.log(''.concat(i, ' ok.')), cr({ memberList: u })
        }))
        .catch(((e) => (t.probeNetwork().then(((t) => {
          const n = m(t, 2); const o = n[0]; const a = n[1];c.setError(e, o, a).end()
        })), Ee.error(''.concat(i, ' failed. error:'), e), Mr(e))))
    } }, { key: 'getGroupMemberProfile', value(e) {
      const n = this; const o = ''.concat(this._className, '.getGroupMemberProfile'); const a = new Da(vs);a.setMessage(e.userIDList.length > 5 ? 'userIDList.length:'.concat(e.userIDList.length) : 'userIDList:'.concat(e.userIDList)), Ee.log(''.concat(o, ' groupID:').concat(e.groupID, ' userIDList:')
        .concat(e.userIDList.join(','))), e.userIDList.length > 50 && (e.userIDList = e.userIDList.slice(0, 50));const s = e.groupID; const r = e.userIDList;return this._getGroupMemberProfileAdvance(t(t({}, e), {}, { userIDList: r })).then(((e) => {
        const t = e.data.members;return Re(t) && 0 !== t.length ? (n._updateLocalGroupMemberMap(s, t), n.getModule(Ct).getUserProfile({ userIDList: t.map(((e) => e.userID)), tagList: [Ks.NICK, Ks.AVATAR] })) : mr([])
      }))
        .then(((e) => {
          const t = e.data.map(((e) => ({ userID: e.userID, nick: e.nick, avatar: e.avatar })));n._updateLocalGroupMemberMap(s, t);const o = r.filter(((e) => n.hasLocalGroupMember(s, e))).map(((e) => n.getLocalGroupMemberInfo(s, e)));return a.setNetworkType(n.getNetworkType()).end(), cr({ memberList: o })
        }))
    } }, { key: 'addGroupMember', value(e) {
      const t = this; const n = ''.concat(this._className, '.addGroupMember'); const o = e.groupID; const a = this.getModule(At).getLocalGroupProfile(o); const s = a.type; const r = new Da(ys);if (r.setMessage('groupID:'.concat(o, ' groupType:').concat(s)), et(s)) {
        const i = new hr({ code: Zn.CANNOT_ADD_MEMBER_IN_AVCHATROOM, message: xo });return r.setCode(Zn.CANNOT_ADD_MEMBER_IN_AVCHATROOM).setError(xo)
          .setNetworkType(this.getNetworkType())
          .end(), Mr(i)
      } return e.userIDList = e.userIDList.map(((e) => ({ userID: e }))), Ee.log(''.concat(n, ' groupID:').concat(o)), this.request({ protocolName: qn, requestData: e }).then(((o) => {
        const s = o.data.members;Ee.log(''.concat(n, ' ok'));const i = s.filter(((e) => 1 === e.result)).map(((e) => e.userID)); const c = s.filter(((e) => 0 === e.result)).map(((e) => e.userID)); const u = s.filter(((e) => 2 === e.result)).map(((e) => e.userID)); const l = s.filter(((e) => 4 === e.result)).map(((e) => e.userID)); const d = 'groupID:'.concat(e.groupID, ', ') + 'successUserIDList:'.concat(i, ', ') + 'failureUserIDList:'.concat(c, ', ') + 'existedUserIDList:'.concat(u, ', ') + 'overLimitUserIDList:'.concat(l);return r.setNetworkType(t.getNetworkType()).setMoreMessage(d)
          .end(), 0 === i.length ? cr({ successUserIDList: i, failureUserIDList: c, existedUserIDList: u, overLimitUserIDList: l }) : (a.memberNum += i.length, cr({ successUserIDList: i, failureUserIDList: c, existedUserIDList: u, overLimitUserIDList: l, group: a }))
      }))
        .catch(((e) => (t.probeNetwork().then(((t) => {
          const n = m(t, 2); const o = n[0]; const a = n[1];r.setError(e, o, a).end()
        })), Ee.error(''.concat(n, ' failed. error:'), e), Mr(e))))
    } }, { key: 'deleteGroupMember', value(e) {
      const t = this; const n = ''.concat(this._className, '.deleteGroupMember'); const o = e.groupID; const a = e.userIDList; const s = new Da(Is); const r = 'groupID:'.concat(o, ' ').concat(a.length > 5 ? 'userIDList.length:'.concat(a.length) : 'userIDList:'.concat(a));s.setMessage(r), Ee.log(''.concat(n, ' groupID:').concat(o, ' userIDList:'), a);const i = this.getModule(At).getLocalGroupProfile(o);return et(i.type) ? Mr(new hr({ code: Zn.CANNOT_KICK_MEMBER_IN_AVCHATROOM, message: Ho })) : this.request({ protocolName: Vn, requestData: e }).then((() => (s.setNetworkType(t.getNetworkType()).end(), Ee.log(''.concat(n, ' ok')), i.memberNum--, t.deleteLocalGroupMembers(o, a), cr({ group: i, userIDList: a }))))
        .catch(((e) => (t.probeNetwork().then(((t) => {
          const n = m(t, 2); const o = n[0]; const a = n[1];s.setError(e, o, a).end()
        })), Ee.error(''.concat(n, ' failed. error:'), e), Mr(e))))
    } }, { key: 'setGroupMemberMuteTime', value(e) {
      const t = this; const n = e.groupID; const o = e.userID; const a = e.muteTime; const s = ''.concat(this._className, '.setGroupMemberMuteTime');if (o === this.getMyUserID()) return Mr(new hr({ code: Zn.CANNOT_MUTE_SELF, message: Wo }));Ee.log(''.concat(s, ' groupID:').concat(n, ' userID:')
        .concat(o));const r = new Da(Ds);return r.setMessage('groupID:'.concat(n, ' userID:').concat(o, ' muteTime:')
        .concat(a)), this._modifyGroupMemberInfo({ groupID: n, userID: o, muteTime: a }).then(((e) => {
        r.setNetworkType(t.getNetworkType()).end(), Ee.log(''.concat(s, ' ok'));const o = t.getModule(At);return cr({ group: o.getLocalGroupProfile(n), member: e })
      }))
        .catch(((e) => (t.probeNetwork().then(((t) => {
          const n = m(t, 2); const o = n[0]; const a = n[1];r.setError(e, o, a).end()
        })), Ee.error(''.concat(s, ' failed. error:'), e), Mr(e))))
    } }, { key: 'setGroupMemberRole', value(e) {
      const t = this; const n = ''.concat(this._className, '.setGroupMemberRole'); const o = e.groupID; const a = e.userID; const s = e.role; const r = this.getModule(At).getLocalGroupProfile(o);if (r.selfInfo.role !== k.GRP_MBR_ROLE_OWNER) return Mr(new hr({ code: Zn.NOT_OWNER, message: jo }));if ([k.GRP_WORK, k.GRP_AVCHATROOM].includes(r.type)) return Mr(new hr({ code: Zn.CANNOT_SET_MEMBER_ROLE_IN_WORK_AND_AVCHATROOM, message: $o }));if ([k.GRP_MBR_ROLE_ADMIN, k.GRP_MBR_ROLE_MEMBER].indexOf(s) < 0) return Mr(new hr({ code: Zn.INVALID_MEMBER_ROLE, message: Yo }));if (a === this.getMyUserID()) return Mr(new hr({ code: Zn.CANNOT_SET_SELF_MEMBER_ROLE, message: zo }));const i = new Da(Ss);return i.setMessage('groupID:'.concat(o, ' userID:').concat(a, ' role:')
        .concat(s)), Ee.log(''.concat(n, ' groupID:').concat(o, ' userID:')
        .concat(a)), this._modifyGroupMemberInfo({ groupID: o, userID: a, role: s }).then(((e) => (i.setNetworkType(t.getNetworkType()).end(), Ee.log(''.concat(n, ' ok')), cr({ group: r, member: e }))))
        .catch(((e) => (t.probeNetwork().then(((t) => {
          const n = m(t, 2); const o = n[0]; const a = n[1];i.setError(e, o, a).end()
        })), Ee.error(''.concat(n, ' failed. error:'), e), Mr(e))))
    } }, { key: 'setGroupMemberNameCard', value(e) {
      const t = this; const n = ''.concat(this._className, '.setGroupMemberNameCard'); const o = e.groupID; const a = e.userID; const s = void 0 === a ? this.getMyUserID() : a; const r = e.nameCard;Ee.log(''.concat(n, ' groupID:').concat(o, ' userID:')
        .concat(s));const i = new Da(Ts);return i.setMessage('groupID:'.concat(o, ' userID:').concat(s, ' nameCard:')
        .concat(r)), this._modifyGroupMemberInfo({ groupID: o, userID: s, nameCard: r }).then(((e) => {
        Ee.log(''.concat(n, ' ok')), i.setNetworkType(t.getNetworkType()).end();const a = t.getModule(At).getLocalGroupProfile(o);return s === t.getMyUserID() && a && a.setSelfNameCard(r), cr({ group: a, member: e })
      }))
        .catch(((e) => (t.probeNetwork().then(((t) => {
          const n = m(t, 2); const o = n[0]; const a = n[1];i.setError(e, o, a).end()
        })), Ee.error(''.concat(n, ' failed. error:'), e), Mr(e))))
    } }, { key: 'setGroupMemberCustomField', value(e) {
      const t = this; const n = ''.concat(this._className, '.setGroupMemberCustomField'); const o = e.groupID; const a = e.userID; const s = void 0 === a ? this.getMyUserID() : a; const r = e.memberCustomField;Ee.log(''.concat(n, ' groupID:').concat(o, ' userID:')
        .concat(s));const i = new Da(Es);return i.setMessage('groupID:'.concat(o, ' userID:').concat(s, ' memberCustomField:')
        .concat(JSON.stringify(r))), this._modifyGroupMemberInfo({ groupID: o, userID: s, memberCustomField: r }).then(((e) => {
        i.setNetworkType(t.getNetworkType()).end(), Ee.log(''.concat(n, ' ok'));const a = t.getModule(At).getLocalGroupProfile(o);return cr({ group: a, member: e })
      }))
        .catch(((e) => (t.probeNetwork().then(((t) => {
          const n = m(t, 2); const o = n[0]; const a = n[1];i.setError(e, o, a).end()
        })), Ee.error(''.concat(n, ' failed. error:'), e), Mr(e))))
    } }, { key: 'setMessageRemindType', value(e) {
      const t = this; const n = ''.concat(this._className, '.setMessageRemindType'); const o = new Da(is);o.setMessage('groupID:'.concat(e.groupID)), Ee.log(''.concat(n, ' groupID:').concat(e.groupID));const a = e.groupID; const s = e.messageRemindType;return this._modifyGroupMemberInfo({ groupID: a, messageRemindType: s, userID: this.getMyUserID() }).then((() => {
        o.setNetworkType(t.getNetworkType()).end(), Ee.log(''.concat(n, ' ok. groupID:').concat(e.groupID));const a = t.getModule(At).getLocalGroupProfile(e.groupID);return a && (a.selfInfo.messageRemindType = s), cr({ group: a })
      }))
        .catch(((e) => (t.probeNetwork().then(((t) => {
          const n = m(t, 2); const a = n[0]; const s = n[1];o.setError(e, a, s).end()
        })), Ee.error(''.concat(n, ' failed. error:'), e), Mr(e))))
    } }, { key: '_modifyGroupMemberInfo', value(e) {
      const t = this; const n = e.groupID; const o = e.userID;return this.request({ protocolName: Kn, requestData: e }).then((() => {
        if (t.hasLocalGroupMember(n, o)) {
          const a = t.getLocalGroupMemberInfo(n, o);return Ge(e.muteTime) || a.updateMuteUntil(e.muteTime), Ge(e.role) || a.updateRole(e.role), Ge(e.nameCard) || a.updateNameCard(e.nameCard), Ge(e.memberCustomField) || a.updateMemberCustomField(e.memberCustomField), a
        } return t.getGroupMemberProfile({ groupID: n, userIDList: [o] }).then(((e) => m(e.data.memberList, 1)[0]))
      }))
    } }, { key: '_getGroupMemberProfileAdvance', value(e) {
      return this.request({ protocolName: Fn, requestData: t(t({}, e), {}, { memberInfoFilter: e.memberInfoFilter ? e.memberInfoFilter : ['Role', 'JoinTime', 'NameCard', 'ShutUpUntil'] }) })
    } }, { key: '_updateLocalGroupMemberMap', value(e, t) {
      const n = this;return Re(t) && 0 !== t.length ? t.map(((t) => (n.hasLocalGroupMember(e, t.userID) ? n.getLocalGroupMemberInfo(e, t.userID).updateMember(t) : n.setLocalGroupMember(e, new Yr(t)), n.getLocalGroupMemberInfo(e, t.userID)))) : []
    } }, { key: 'deleteLocalGroupMembers', value(e, t) {
      const n = this.groupMemberListMap.get(e);n && t.forEach(((e) => {
        n.delete(e)
      }))
    } }, { key: 'getLocalGroupMemberInfo', value(e, t) {
      return this.groupMemberListMap.has(e) ? this.groupMemberListMap.get(e).get(t) : null
    } }, { key: 'setLocalGroupMember', value(e, t) {
      if (this.groupMemberListMap.has(e)) this.groupMemberListMap.get(e).set(t.userID, t);else {
        const n = (new Map).set(t.userID, t);this.groupMemberListMap.set(e, n)
      }
    } }, { key: 'getLocalGroupMemberList', value(e) {
      return this.groupMemberListMap.get(e)
    } }, { key: 'hasLocalGroupMember', value(e, t) {
      return this.groupMemberListMap.has(e) && this.groupMemberListMap.get(e).has(t)
    } }, { key: 'hasLocalGroupMemberMap', value(e) {
      return this.groupMemberListMap.has(e)
    } }, { key: 'reset', value() {
      this.groupMemberListMap.clear()
    } }]), a
  }(Yt)); const Wr = (function () {
    function e(t) {
      o(this, e), this._userModule = t, this._className = 'ProfileHandler', this.TAG = 'profile', this.accountProfileMap = new Map, this.expirationTime = 864e5
    } return s(e, [{ key: 'setExpirationTime', value(e) {
      this.expirationTime = e
    } }, { key: 'getUserProfile', value(e) {
      const t = this; const n = e.userIDList;e.fromAccount = this._userModule.getMyAccount(), n.length > 100 && (Ee.warn(''.concat(this._className, '.getUserProfile 获取用户资料人数不能超过100人')), n.length = 100);for (var o, a = [], s = [], r = 0, i = n.length;r < i;r++)o = n[r], this._userModule.isMyFriend(o) && this._containsAccount(o) ? s.push(this._getProfileFromMap(o)) : a.push(o);if (0 === a.length) return mr(s);e.toAccount = a;const c = e.bFromGetMyProfile || !1; const u = [];e.toAccount.forEach(((e) => {
        u.push({ toAccount: e, standardSequence: 0, customSequence: 0 })
      })), e.userItem = u;const l = new Da(Os);return l.setMessage(n.length > 5 ? 'userIDList.length:'.concat(n.length) : 'userIDList:'.concat(n)), this._userModule.request({ protocolName: tn, requestData: e }).then(((e) => {
        l.setNetworkType(t._userModule.getNetworkType()).end(), Ee.info(''.concat(t._className, '.getUserProfile ok'));const n = t._handleResponse(e).concat(s);return cr(c ? n[0] : n)
      }))
        .catch(((e) => (t._userModule.probeNetwork().then(((t) => {
          const n = m(t, 2); const o = n[0]; const a = n[1];l.setError(e, o, a).end()
        })), Ee.error(''.concat(t._className, '.getUserProfile failed. error:'), e), Mr(e))))
    } }, { key: 'getMyProfile', value() {
      const e = this._userModule.getMyAccount();if (Ee.log(''.concat(this._className, '.getMyProfile myAccount:').concat(e)), this._fillMap(), this._containsAccount(e)) {
        const t = this._getProfileFromMap(e);return Ee.debug(''.concat(this._className, '.getMyProfile from cache, myProfile:') + JSON.stringify(t)), mr(t)
      } return this.getUserProfile({ fromAccount: e, userIDList: [e], bFromGetMyProfile: !0 })
    } }, { key: '_handleResponse', value(e) {
      for (var t, n, o = Ve.now(), a = e.data.userProfileItem, s = [], r = 0, i = a.length;r < i;r++)'@TLS#NOT_FOUND' !== a[r].to && '' !== a[r].to && (t = a[r].to, n = this._updateMap(t, this._getLatestProfileFromResponse(t, a[r].profileItem)), s.push(n));return Ee.log(''.concat(this._className, '._handleResponse cost ').concat(Ve.now() - o, ' ms')), s
    } }, { key: '_getLatestProfileFromResponse', value(e, t) {
      const n = {};if (n.userID = e, n.profileCustomField = [], !dt(t)) for (let o = 0, a = t.length;o < a;o++) if (t[o].tag.indexOf('Tag_Profile_Custom') > -1)n.profileCustomField.push({ key: t[o].tag, value: t[o].value });else switch (t[o].tag) {
        case Ks.NICK:n.nick = t[o].value;break;case Ks.GENDER:n.gender = t[o].value;break;case Ks.BIRTHDAY:n.birthday = t[o].value;break;case Ks.LOCATION:n.location = t[o].value;break;case Ks.SELFSIGNATURE:n.selfSignature = t[o].value;break;case Ks.ALLOWTYPE:n.allowType = t[o].value;break;case Ks.LANGUAGE:n.language = t[o].value;break;case Ks.AVATAR:n.avatar = t[o].value;break;case Ks.MESSAGESETTINGS:n.messageSettings = t[o].value;break;case Ks.ADMINFORBIDTYPE:n.adminForbidType = t[o].value;break;case Ks.LEVEL:n.level = t[o].value;break;case Ks.ROLE:n.role = t[o].value;break;default:Ee.warn(''.concat(this._className, '._handleResponse unknown tag:'), t[o].tag, t[o].value)
      } return n
    } }, { key: 'updateMyProfile', value(e) {
      const t = this; const n = ''.concat(this._className, '.updateMyProfile'); const o = new Da(Ls);o.setMessage(JSON.stringify(e));const a = (new Ar).validate(e);if (!a.valid) return o.setCode(Zn.UPDATE_PROFILE_INVALID_PARAM).setMoreMessage(''.concat(n, ' info:').concat(a.tips))
        .setNetworkType(this._userModule.getNetworkType())
        .end(), Ee.error(''.concat(n, ' info:').concat(a.tips, '，请参考 https://web.sdk.qcloud.com/im/doc/zh-cn/SDK.html#updateMyProfile')), Mr({ code: Zn.UPDATE_PROFILE_INVALID_PARAM, message: Jo });const s = [];for (const r in e)Object.prototype.hasOwnProperty.call(e, r) && ('profileCustomField' === r ? e.profileCustomField.forEach(((e) => {
        s.push({ tag: e.key, value: e.value })
      })) : s.push({ tag: Ks[r.toUpperCase()], value: e[r] }));return 0 === s.length ? (o.setCode(Zn.UPDATE_PROFILE_NO_KEY).setMoreMessage(Xo)
        .setNetworkType(this._userModule.getNetworkType())
        .end(), Ee.error(''.concat(n, ' info:').concat(Xo, '，请参考 https://web.sdk.qcloud.com/im/doc/zh-cn/SDK.html#updateMyProfile')), Mr({ code: Zn.UPDATE_PROFILE_NO_KEY, message: Xo })) : this._userModule.request({ protocolName: nn, requestData: { fromAccount: this._userModule.getMyAccount(), profileItem: s } }).then(((a) => {
        o.setNetworkType(t._userModule.getNetworkType()).end(), Ee.info(''.concat(n, ' ok'));const s = t._updateMap(t._userModule.getMyAccount(), e);return t._userModule.emitOuterEvent(E.PROFILE_UPDATED, [s]), mr(s)
      }))
        .catch(((e) => (t._userModule.probeNetwork().then(((t) => {
          const n = m(t, 2); const a = n[0]; const s = n[1];o.setError(e, a, s).end()
        })), Ee.error(''.concat(n, ' failed. error:'), e), Mr(e))))
    } }, { key: 'onProfileModified', value(e) {
      const t = e.dataList;if (!dt(t)) {
        let n; let o; const a = t.length;Ee.info(''.concat(this._className, '.onProfileModified count:').concat(a));for (var s = [], r = this._userModule.getModule(Rt), i = 0;i < a;i++)n = t[i].userID, o = this._updateMap(n, this._getLatestProfileFromResponse(n, t[i].profileList)), s.push(o), n === this._userModule.getMyAccount() && r.onMyProfileModified({ latestNick: o.nick, latestAvatar: o.avatar });this._userModule.emitInnerEvent(Ir.PROFILE_UPDATED, s), this._userModule.emitOuterEvent(E.PROFILE_UPDATED, s)
      }
    } }, { key: '_fillMap', value() {
      if (0 === this.accountProfileMap.size) {
        for (let e = this._getCachedProfiles(), t = Date.now(), n = 0, o = e.length;n < o;n++)t - e[n].lastUpdatedTime < this.expirationTime && this.accountProfileMap.set(e[n].userID, e[n]);Ee.log(''.concat(this._className, '._fillMap from cache, map.size:').concat(this.accountProfileMap.size))
      }
    } }, { key: '_updateMap', value(e, t) {
      let n; const o = Date.now();return this._containsAccount(e) ? (n = this._getProfileFromMap(e), t.profileCustomField && Qe(n.profileCustomField, t.profileCustomField), Ke(n, t, ['profileCustomField']), n.lastUpdatedTime = o) : (n = new Ar(t), (this._userModule.isMyFriend(e) || e === this._userModule.getMyAccount()) && (n.lastUpdatedTime = o, this.accountProfileMap.set(e, n))), this._flushMap(e === this._userModule.getMyAccount()), n
    } }, { key: '_flushMap', value(e) {
      const t = M(this.accountProfileMap.values()); const n = this._userModule.getStorageModule();Ee.debug(''.concat(this._className, '._flushMap length:').concat(t.length, ' flushAtOnce:')
        .concat(e)), n.setItem(this.TAG, t, e)
    } }, { key: '_containsAccount', value(e) {
      return this.accountProfileMap.has(e)
    } }, { key: '_getProfileFromMap', value(e) {
      return this.accountProfileMap.get(e)
    } }, { key: '_getCachedProfiles', value() {
      const e = this._userModule.getStorageModule().getItem(this.TAG);return dt(e) ? [] : e
    } }, { key: 'onConversationsProfileUpdated', value(e) {
      for (var t, n, o, a = [], s = 0, r = e.length;s < r;s++)n = (t = e[s]).userID, this._userModule.isMyFriend(n) || (this._containsAccount(n) ? (o = this._getProfileFromMap(n), Ke(o, t) > 0 && a.push(n)) : a.push(t.userID));0 !== a.length && (Ee.info(''.concat(this._className, '.onConversationsProfileUpdated toAccountList:').concat(a)), this.getUserProfile({ userIDList: a }))
    } }, { key: 'getNickAndAvatarByUserID', value(e) {
      if (this._containsAccount(e)) {
        const t = this._getProfileFromMap(e);return { nick: t.nick, avatar: t.avatar }
      } return { nick: '', avatar: '' }
    } }, { key: 'reset', value() {
      this._flushMap(!0), this.accountProfileMap.clear()
    } }]), e
  }()); const Jr = function e(t) {
    o(this, e), dt || (this.userID = t.userID || '', this.timeStamp = t.timeStamp || 0)
  }; const Xr = (function () {
    function e(t) {
      o(this, e), this._userModule = t, this._className = 'BlacklistHandler', this._blacklistMap = new Map, this.startIndex = 0, this.maxLimited = 100, this.currentSequence = 0
    } return s(e, [{ key: 'getLocalBlacklist', value() {
      return M(this._blacklistMap.keys())
    } }, { key: 'getBlacklist', value() {
      const e = this; const t = ''.concat(this._className, '.getBlacklist'); const n = { fromAccount: this._userModule.getMyAccount(), maxLimited: this.maxLimited, startIndex: 0, lastSequence: this.currentSequence }; const o = new Da(Rs);return this._userModule.request({ protocolName: on, requestData: n }).then(((n) => {
        const a = n.data; const s = a.blackListItem; const r = a.currentSequence; const i = dt(s) ? 0 : s.length;o.setNetworkType(e._userModule.getNetworkType()).setMessage('blackList count:'.concat(i))
          .end(), Ee.info(''.concat(t, ' ok')), e.currentSequence = r, e._handleResponse(s, !0), e._userModule.emitOuterEvent(E.BLACKLIST_UPDATED, M(e._blacklistMap.keys()))
      }))
        .catch(((n) => (e._userModule.probeNetwork().then(((e) => {
          const t = m(e, 2); const a = t[0]; const s = t[1];o.setError(n, a, s).end()
        })), Ee.error(''.concat(t, ' failed. error:'), n), Mr(n))))
    } }, { key: 'addBlacklist', value(e) {
      const t = this; const n = ''.concat(this._className, '.addBlacklist'); const o = new Da(Gs);if (!Re(e.userIDList)) return o.setCode(Zn.ADD_BLACKLIST_INVALID_PARAM).setMessage(Qo)
        .setNetworkType(this._userModule.getNetworkType())
        .end(), Ee.error(''.concat(n, ' options.userIDList 必需是数组')), Mr({ code: Zn.ADD_BLACKLIST_INVALID_PARAM, message: Qo });const a = this._userModule.getMyAccount();return 1 === e.userIDList.length && e.userIDList[0] === a ? (o.setCode(Zn.CANNOT_ADD_SELF_TO_BLACKLIST).setMessage(ea)
        .setNetworkType(this._userModule.getNetworkType())
        .end(), Ee.error(''.concat(n, ' 不能把自己拉黑')), Mr({ code: Zn.CANNOT_ADD_SELF_TO_BLACKLIST, message: ea })) : (e.userIDList.includes(a) && (e.userIDList = e.userIDList.filter(((e) => e !== a)), Ee.warn(''.concat(n, ' 不能把自己拉黑，已过滤'))), e.fromAccount = this._userModule.getMyAccount(), e.toAccount = e.userIDList, this._userModule.request({ protocolName: an, requestData: e }).then(((a) => (o.setNetworkType(t._userModule.getNetworkType()).setMessage(e.userIDList.length > 5 ? 'userIDList.length:'.concat(e.userIDList.length) : 'userIDList:'.concat(e.userIDList))
        .end(), Ee.info(''.concat(n, ' ok')), t._handleResponse(a.resultItem, !0), cr(M(t._blacklistMap.keys())))))
        .catch(((e) => (t._userModule.probeNetwork().then(((t) => {
          const n = m(t, 2); const a = n[0]; const s = n[1];o.setError(e, a, s).end()
        })), Ee.error(''.concat(n, ' failed. error:'), e), Mr(e)))))
    } }, { key: '_handleResponse', value(e, t) {
      if (!dt(e)) for (var n, o, a, s = 0, r = e.length;s < r;s++)o = e[s].to, a = e[s].resultCode, (Ge(a) || 0 === a) && (t ? ((n = this._blacklistMap.has(o) ? this._blacklistMap.get(o) : new Jr).userID = o, !dt(e[s].addBlackTimeStamp) && (n.timeStamp = e[s].addBlackTimeStamp), this._blacklistMap.set(o, n)) : this._blacklistMap.has(o) && (n = this._blacklistMap.get(o), this._blacklistMap.delete(o)));Ee.log(''.concat(this._className, '._handleResponse total:').concat(this._blacklistMap.size, ' bAdd:')
        .concat(t))
    } }, { key: 'deleteBlacklist', value(e) {
      const t = this; const n = ''.concat(this._className, '.deleteBlacklist'); const o = new Da(ws);return Re(e.userIDList) ? (e.fromAccount = this._userModule.getMyAccount(), e.toAccount = e.userIDList, this._userModule.request({ protocolName: sn, requestData: e }).then(((a) => (o.setNetworkType(t._userModule.getNetworkType()).setMessage(e.userIDList.length > 5 ? 'userIDList.length:'.concat(e.userIDList.length) : 'userIDList:'.concat(e.userIDList))
        .end(), Ee.info(''.concat(n, ' ok')), t._handleResponse(a.data.resultItem, !1), cr(M(t._blacklistMap.keys())))))
        .catch(((e) => (t._userModule.probeNetwork().then(((t) => {
          const n = m(t, 2); const a = n[0]; const s = n[1];o.setError(e, a, s).end()
        })), Ee.error(''.concat(n, ' failed. error:'), e), Mr(e))))) : (o.setCode(Zn.DEL_BLACKLIST_INVALID_PARAM).setMessage(Zo)
        .setNetworkType(this._userModule.getNetworkType())
        .end(), Ee.error(''.concat(n, ' options.userIDList 必需是数组')), Mr({ code: Zn.DEL_BLACKLIST_INVALID_PARAM, message: Zo }))
    } }, { key: 'onAccountDeleted', value(e) {
      for (var t, n = [], o = 0, a = e.length;o < a;o++)t = e[o], this._blacklistMap.has(t) && (this._blacklistMap.delete(t), n.push(t));n.length > 0 && (Ee.log(''.concat(this._className, '.onAccountDeleted count:').concat(n.length, ' userIDList:'), n), this._userModule.emitOuterEvent(E.BLACKLIST_UPDATED, M(this._blacklistMap.keys())))
    } }, { key: 'onAccountAdded', value(e) {
      for (var t, n = [], o = 0, a = e.length;o < a;o++)t = e[o], this._blacklistMap.has(t) || (this._blacklistMap.set(t, new Jr({ userID: t })), n.push(t));n.length > 0 && (Ee.log(''.concat(this._className, '.onAccountAdded count:').concat(n.length, ' userIDList:'), n), this._userModule.emitOuterEvent(E.BLACKLIST_UPDATED, M(this._blacklistMap.keys())))
    } }, { key: 'reset', value() {
      this._blacklistMap.clear(), this.startIndex = 0, this.maxLimited = 100, this.currentSequence = 0
    } }]), e
  }()); const Qr = (function (e) {
    i(n, e);const t = f(n);function n(e) {
      let a;return o(this, n), (a = t.call(this, e))._className = 'UserModule', a._profileHandler = new Wr(h(a)), a._blacklistHandler = new Xr(h(a)), a.getInnerEmitterInstance().on(Ir.CONTEXT_A2KEY_AND_TINYID_UPDATED, a.onContextUpdated, h(a)), a
    } return s(n, [{ key: 'onContextUpdated', value(e) {
      this._profileHandler.getMyProfile(), this._blacklistHandler.getBlacklist()
    } }, { key: 'onProfileModified', value(e) {
      this._profileHandler.onProfileModified(e)
    } }, { key: 'onRelationChainModified', value(e) {
      const t = e.dataList;if (!dt(t)) {
        const n = [];t.forEach(((e) => {
          e.blackListDelAccount && n.push.apply(n, M(e.blackListDelAccount))
        })), n.length > 0 && this._blacklistHandler.onAccountDeleted(n);const o = [];t.forEach(((e) => {
          e.blackListAddAccount && o.push.apply(o, M(e.blackListAddAccount))
        })), o.length > 0 && this._blacklistHandler.onAccountAdded(o)
      }
    } }, { key: 'onConversationsProfileUpdated', value(e) {
      this._profileHandler.onConversationsProfileUpdated(e)
    } }, { key: 'getMyAccount', value() {
      return this.getMyUserID()
    } }, { key: 'getMyProfile', value() {
      return this._profileHandler.getMyProfile()
    } }, { key: 'getStorageModule', value() {
      return this.getModule(wt)
    } }, { key: 'isMyFriend', value(e) {
      const t = this.getModule(Ot);return !!t && t.isMyFriend(e)
    } }, { key: 'getUserProfile', value(e) {
      return this._profileHandler.getUserProfile(e)
    } }, { key: 'updateMyProfile', value(e) {
      return this._profileHandler.updateMyProfile(e)
    } }, { key: 'getNickAndAvatarByUserID', value(e) {
      return this._profileHandler.getNickAndAvatarByUserID(e)
    } }, { key: 'getLocalBlacklist', value() {
      const e = this._blacklistHandler.getLocalBlacklist();return mr(e)
    } }, { key: 'addBlacklist', value(e) {
      return this._blacklistHandler.addBlacklist(e)
    } }, { key: 'deleteBlacklist', value(e) {
      return this._blacklistHandler.deleteBlacklist(e)
    } }, { key: 'reset', value() {
      Ee.log(''.concat(this._className, '.reset')), this._profileHandler.reset(), this._blacklistHandler.reset()
    } }]), n
  }(Yt)); const Zr = (function () {
    function e(t, n) {
      o(this, e), this._moduleManager = t, this._isLoggedIn = !1, this._SDKAppID = n.SDKAppID, this._userID = n.userID || '', this._userSig = n.userSig || '', this._version = '2.12.2', this._a2Key = '', this._tinyID = '', this._contentType = 'json', this._unlimitedAVChatRoom = n.unlimitedAVChatRoom, this._scene = n.scene, this._oversea = n.oversea, this._instanceID = n.instanceID, this._statusInstanceID = 0
    } return s(e, [{ key: 'isLoggedIn', value() {
      return this._isLoggedIn
    } }, { key: 'isOversea', value() {
      return this._oversea
    } }, { key: 'isUnlimitedAVChatRoom', value() {
      return this._unlimitedAVChatRoom
    } }, { key: 'getUserID', value() {
      return this._userID
    } }, { key: 'setUserID', value(e) {
      this._userID = e
    } }, { key: 'setUserSig', value(e) {
      this._userSig = e
    } }, { key: 'getUserSig', value() {
      return this._userSig
    } }, { key: 'getSDKAppID', value() {
      return this._SDKAppID
    } }, { key: 'getTinyID', value() {
      return this._tinyID
    } }, { key: 'setTinyID', value(e) {
      this._tinyID = e, this._isLoggedIn = !0
    } }, { key: 'getScene', value() {
      return this._scene
    } }, { key: 'getInstanceID', value() {
      return this._instanceID
    } }, { key: 'getStatusInstanceID', value() {
      return this._statusInstanceID
    } }, { key: 'setStatusInstanceID', value(e) {
      this._statusInstanceID = e
    } }, { key: 'getVersion', value() {
      return this._version
    } }, { key: 'getA2Key', value() {
      return this._a2Key
    } }, { key: 'setA2Key', value(e) {
      this._a2Key = e
    } }, { key: 'getContentType', value() {
      return this._contentType
    } }, { key: 'reset', value() {
      this._isLoggedIn = !1, this._userSig = '', this._a2Key = '', this._tinyID = '', this._statusInstanceID = 0
    } }]), e
  }()); const ei = (function (e) {
    i(n, e);const t = f(n);function n(e) {
      let a;return o(this, n), (a = t.call(this, e))._className = 'SignModule', a._helloInterval = 120, Dr.mixin(h(a)), a
    } return s(n, [{ key: 'onCheckTimer', value(e) {
      this.isLoggedIn() && e % this._helloInterval == 0 && this._hello()
    } }, { key: 'login', value(e) {
      if (this.isLoggedIn()) {
        const t = '您已经登录账号'.concat(e.userID, '！如需切换账号登录，请先调用 logout 接口登出，再调用 login 接口登录。');return Ee.warn(t), mr({ actionStatus: 'OK', errorCode: 0, errorInfo: t, repeatLogin: !0 })
      }Ee.log(''.concat(this._className, '.login userID:').concat(e.userID));const n = this._checkLoginInfo(e);if (0 !== n.code) return Mr(n);const o = this.getModule(Gt); const a = e.userID; const s = e.userSig;return o.setUserID(a), o.setUserSig(s), this.getModule(Kt).updateProtocolConfig(), this._login()
    } }, { key: '_login', value() {
      const e = this; const t = this.getModule(Gt); const n = new Da(Ea);return n.setMessage(''.concat(t.getScene())).setMoreMessage('identifier:'.concat(this.getMyUserID())), this.request({ protocolName: zt }).then(((o) => {
        const a = Date.now(); let s = null; const r = o.data; const i = r.a2Key; const c = r.tinyID; const u = r.helloInterval; const l = r.instanceID; const d = r.timeStamp;Ee.log(''.concat(e._className, '.login ok. helloInterval:').concat(u, ' instanceID:')
          .concat(l, ' timeStamp:')
          .concat(d));const g = 1e3 * d; const p = a - n.getStartTs(); const h = g + parseInt(p / 2) - a; const _ = n.getStartTs() + h;if (n.start(_), (function (e, t) {
          ve = t;const n = new Date;n.setTime(e), Ee.info('baseTime from server: '.concat(n, ' offset: ').concat(ve))
        }(g, h)), !c) throw s = new hr({ code: Zn.NO_TINYID, message: oo }), n.setError(s, !0, e.getNetworkType()).end(), s;if (!i) throw s = new hr({ code: Zn.NO_A2KEY, message: ao }), n.setError(s, !0, e.getNetworkType()).end(), s;return n.setNetworkType(e.getNetworkType()).setMoreMessage('helloInterval:'.concat(u, ' instanceID:').concat(l, ' offset:')
          .concat(h))
          .end(), t.setA2Key(i), t.setTinyID(c), t.setStatusInstanceID(l), e.getModule(Kt).updateProtocolConfig(), e.emitInnerEvent(Ir.CONTEXT_A2KEY_AND_TINYID_UPDATED), e._helloInterval = u, e.triggerReady(), e._fetchCloudControlConfig(), o
      }))
        .catch(((t) => (e.probeNetwork().then(((e) => {
          const o = m(e, 2); const a = o[0]; const s = o[1];n.setError(t, a, s).end(!0)
        })), Ee.error(''.concat(e._className, '.login failed. error:'), t), e._moduleManager.onLoginFailed(), Mr(t))))
    } }, { key: 'logout', value() {
      const e = this;return this.isLoggedIn() ? (new Da(ka).setNetworkType(this.getNetworkType())
        .setMessage('identifier:'.concat(this.getMyUserID()))
        .end(!0), Ee.info(''.concat(this._className, '.logout')), this.request({ protocolName: Wt }).then((() => (e.resetReady(), mr({}))))
        .catch(((t) => (Ee.error(''.concat(e._className, '._logout error:'), t), e.resetReady(), mr({}))))) : Mr({ code: Zn.USER_NOT_LOGGED_IN, message: so })
    } }, { key: '_fetchCloudControlConfig', value() {
      this.getModule(Ht).fetchConfig()
    } }, { key: '_hello', value() {
      const e = this;this.request({ protocolName: Jt }).catch(((t) => {
        Ee.warn(''.concat(e._className, '._hello error:'), t)
      }))
    } }, { key: '_checkLoginInfo', value(e) {
      let t = 0; let n = '';return dt(this.getModule(Gt).getSDKAppID()) ? (t = Zn.NO_SDKAPPID, n = eo) : dt(e.userID) ? (t = Zn.NO_IDENTIFIER, n = to) : dt(e.userSig) && (t = Zn.NO_USERSIG, n = no), { code: t, message: n }
    } }, { key: 'onMultipleAccountKickedOut', value(e) {
      const t = this;new Da(Ca).setNetworkType(this.getNetworkType())
        .setMessage('type:'.concat(k.KICKED_OUT_MULT_ACCOUNT, ' newInstanceInfo:').concat(JSON.stringify(e)))
        .end(!0), Ee.warn(''.concat(this._className, '.onMultipleAccountKickedOut userID:').concat(this.getMyUserID(), ' newInstanceInfo:'), e), this.logout().then((() => {
        t.emitOuterEvent(E.KICKED_OUT, { type: k.KICKED_OUT_MULT_ACCOUNT }), t._moduleManager.reset()
      }))
    } }, { key: 'onMultipleDeviceKickedOut', value(e) {
      const t = this;new Da(Ca).setNetworkType(this.getNetworkType())
        .setMessage('type:'.concat(k.KICKED_OUT_MULT_DEVICE, ' newInstanceInfo:').concat(JSON.stringify(e)))
        .end(!0), Ee.warn(''.concat(this._className, '.onMultipleDeviceKickedOut userID:').concat(this.getMyUserID(), ' newInstanceInfo:'), e), this.logout().then((() => {
        t.emitOuterEvent(E.KICKED_OUT, { type: k.KICKED_OUT_MULT_DEVICE }), t._moduleManager.reset()
      }))
    } }, { key: 'onUserSigExpired', value() {
      new Da(Ca).setNetworkType(this.getNetworkType())
        .setMessage(k.KICKED_OUT_USERSIG_EXPIRED)
        .end(!0), Ee.warn(''.concat(this._className, '.onUserSigExpired: userSig 签名过期被踢下线')), 0 !== this.getModule(Gt).getStatusInstanceID() && (this.emitOuterEvent(E.KICKED_OUT, { type: k.KICKED_OUT_USERSIG_EXPIRED }), this._moduleManager.reset())
    } }, { key: 'reset', value() {
      Ee.log(''.concat(this._className, '.reset')), this.resetReady(), this._helloInterval = 120
    } }]), n
  }(Yt));function ti() {
    return null
  } const ni = (function () {
    function e(t) {
      o(this, e), this._moduleManager = t, this._className = 'StorageModule', this._storageQueue = new Map, this._errorTolerantHandle()
    } return s(e, [{ key: '_errorTolerantHandle', value() {
      z || !Ge(window) && !Ge(window.localStorage) || (this.getItem = ti, this.setItem = ti, this.removeItem = ti, this.clear = ti)
    } }, { key: 'onCheckTimer', value(e) {
      if (e % 20 == 0) {
        if (0 === this._storageQueue.size) return;this._doFlush()
      }
    } }, { key: '_doFlush', value() {
      try {
        let e; const t = S(this._storageQueue);try {
          for (t.s();!(e = t.n()).done;) {
            const n = m(e.value, 2); const o = n[0]; const a = n[1];this._setStorageSync(this._getKey(o), a)
          }
        } catch (s) {
          t.e(s)
        } finally {
          t.f()
        } this._storageQueue.clear()
      } catch (r) {
        Ee.warn(''.concat(this._className, '._doFlush error:'), r)
      }
    } }, { key: '_getPrefix', value() {
      const e = this._moduleManager.getModule(Gt);return 'TIM_'.concat(e.getSDKAppID(), '_').concat(e.getUserID(), '_')
    } }, { key: '_getKey', value(e) {
      return ''.concat(this._getPrefix()).concat(e)
    } }, { key: 'getItem', value(e) {
      const t = !(arguments.length > 1 && void 0 !== arguments[1]) || arguments[1];try {
        const n = t ? this._getKey(e) : e;return this._getStorageSync(n)
      } catch (o) {
        return Ee.warn(''.concat(this._className, '.getItem error:'), o), {}
      }
    } }, { key: 'setItem', value(e, t) {
      const n = arguments.length > 2 && void 0 !== arguments[2] && arguments[2]; const o = !(arguments.length > 3 && void 0 !== arguments[3]) || arguments[3];if (n) {
        const a = o ? this._getKey(e) : e;this._setStorageSync(a, t)
      } else this._storageQueue.set(e, t)
    } }, { key: 'clear', value() {
      try {
        z ? J.clearStorageSync() : localStorage && localStorage.clear()
      } catch (e) {
        Ee.warn(''.concat(this._className, '.clear error:'), e)
      }
    } }, { key: 'removeItem', value(e) {
      const t = !(arguments.length > 1 && void 0 !== arguments[1]) || arguments[1];try {
        const n = t ? this._getKey(e) : e;this._removeStorageSync(n)
      } catch (o) {
        Ee.warn(''.concat(this._className, '.removeItem error:'), o)
      }
    } }, { key: 'getSize', value(e) {
      const t = this; const n = arguments.length > 1 && void 0 !== arguments[1] ? arguments[1] : 'b';try {
        const o = { size: 0, limitSize: 5242880, unit: n };if (Object.defineProperty(o, 'leftSize', { enumerable: !0, get() {
          return o.limitSize - o.size
        } }), z && (o.limitSize = 1024 * J.getStorageInfoSync().limitSize), e)o.size = JSON.stringify(this.getItem(e)).length + this._getKey(e).length;else if (z) {
          const a = J.getStorageInfoSync(); const s = a.keys;s.forEach(((e) => {
            o.size += JSON.stringify(t._getStorageSync(e)).length + t._getKey(e).length
          }))
        } else if (localStorage) for (const r in localStorage)localStorage.hasOwnProperty(r) && (o.size += localStorage.getItem(r).length + r.length);return this._convertUnit(o)
      } catch (i) {
        Ee.warn(''.concat(this._className, ' error:'), i)
      }
    } }, { key: '_convertUnit', value(e) {
      const t = {}; const n = e.unit;for (const o in t.unit = n, e)'number' === typeof e[o] && ('kb' === n.toLowerCase() ? t[o] = Math.round(e[o] / 1024) : 'mb' === n.toLowerCase() ? t[o] = Math.round(e[o] / 1024 / 1024) : t[o] = e[o]);return t
    } }, { key: '_setStorageSync', value(e, t) {
      z ? $ ? my.setStorageSync({ key: e, data: t }) : J.setStorageSync(e, t) : localStorage && localStorage.setItem(e, JSON.stringify(t))
    } }, { key: '_getStorageSync', value(e) {
      return z ? $ ? my.getStorageSync({ key: e }).data : J.getStorageSync(e) : localStorage ? JSON.parse(localStorage.getItem(e)) : {}
    } }, { key: '_removeStorageSync', value(e) {
      z ? $ ? my.removeStorageSync({ key: e }) : J.removeStorageSync(e) : localStorage && localStorage.removeItem(e)
    } }, { key: 'reset', value() {
      Ee.log(''.concat(this._className, '.reset')), this._doFlush()
    } }]), e
  }()); const oi = (function () {
    function e(t) {
      o(this, e), this._className = 'SSOLogBody', this._report = []
    } return s(e, [{ key: 'pushIn', value(e) {
      Ee.debug(''.concat(this._className, '.pushIn'), this._report.length, e), this._report.push(e)
    } }, { key: 'backfill', value(e) {
      let t;Re(e) && 0 !== e.length && (Ee.debug(''.concat(this._className, '.backfill'), this._report.length, e.length), (t = this._report).unshift.apply(t, M(e)))
    } }, { key: 'getLogsNumInMemory', value() {
      return this._report.length
    } }, { key: 'isEmpty', value() {
      return 0 === this._report.length
    } }, { key: '_reset', value() {
      this._report.length = 0, this._report = []
    } }, { key: 'getLogsInMemory', value() {
      const e = this._report.slice();return this._reset(), e
    } }]), e
  }()); const ai = function (e) {
    const t = e.getModule(Gt);return { SDKType: 10, SDKAppID: t.getSDKAppID(), SDKVersion: t.getVersion(), tinyID: Number(t.getTinyID()), userID: t.getUserID(), platform: e.getPlatform(), instanceID: t.getInstanceID(), traceID: ye() }
  }; const si = (function (e) {
    i(a, e);const n = f(a);function a(e) {
      let t;o(this, a), (t = n.call(this, e))._className = 'EventStatModule', t.TAG = 'im-ssolog-event', t._reportBody = new oi, t.MIN_THRESHOLD = 20, t.MAX_THRESHOLD = 100, t.WAITING_TIME = 6e4, t.REPORT_LEVEL = [4, 5, 6], t._lastReportTime = Date.now();const s = t.getInnerEmitterInstance();return s.on(Ir.CONTEXT_A2KEY_AND_TINYID_UPDATED, t._onLoginSuccess, h(t)), s.on(Ir.CLOUD_CONFIG_UPDATED, t._onCloudConfigUpdate, h(t)), t
    } return s(a, [{ key: 'reportAtOnce', value() {
      Ee.debug(''.concat(this._className, '.reportAtOnce')), this._report()
    } }, { key: '_onLoginSuccess', value() {
      const e = this; const t = this.getModule(wt); const n = t.getItem(this.TAG, !1);!dt(n) && Pe(n.forEach) && (Ee.log(''.concat(this._className, '._onLoginSuccess get ssolog in storage, count:').concat(n.length)), n.forEach(((t) => {
        e._reportBody.pushIn(t)
      })), t.removeItem(this.TAG, !1))
    } }, { key: '_onCloudConfigUpdate', value() {
      const e = this.getCloudConfig('report_threshold_event'); const t = this.getCloudConfig('report_waiting_event'); const n = this.getCloudConfig('report_level_event');Ge(e) || (this.MIN_THRESHOLD = Number(e)), Ge(t) || (this.WAITING_TIME = Number(t)), Ge(n) || (this.REPORT_LEVEL = n.split(',').map(((e) => Number(e))))
    } }, { key: 'pushIn', value(e) {
      e instanceof Da && (e.updateTimeStamp(), this._reportBody.pushIn(e), this._reportBody.getLogsNumInMemory() >= this.MIN_THRESHOLD && this._report())
    } }, { key: 'onCheckTimer', value() {
      Date.now() < this._lastReportTime + this.WAITING_TIME || this._reportBody.isEmpty() || this._report()
    } }, { key: '_filterLogs', value(e) {
      const t = this;return e.filter(((e) => t.REPORT_LEVEL.includes(e.level)))
    } }, { key: '_report', value() {
      const e = this;if (!this._reportBody.isEmpty()) {
        const n = this._reportBody.getLogsInMemory(); const o = this._filterLogs(n);if (0 !== o.length) {
          const a = { header: ai(this), event: o };this.request({ protocolName: Hn, requestData: t({}, a) }).then((() => {
            e._lastReportTime = Date.now()
          }))
            .catch(((t) => {
              Ee.warn(''.concat(e._className, '.report failed. networkType:').concat(e.getNetworkType(), ' error:'), t), e._reportBody.backfill(n), e._reportBody.getLogsNumInMemory() > e.MAX_THRESHOLD && e._flushAtOnce()
            }))
        } else this._lastReportTime = Date.now()
      }
    } }, { key: '_flushAtOnce', value() {
      const e = this.getModule(wt); const t = e.getItem(this.TAG, !1); const n = this._reportBody.getLogsInMemory();if (dt(t))Ee.log(''.concat(this._className, '._flushAtOnce count:').concat(n.length)), e.setItem(this.TAG, n, !0, !1);else {
        let o = n.concat(t);o.length > this.MAX_THRESHOLD && (o = o.slice(0, this.MAX_THRESHOLD)), Ee.log(''.concat(this._className, '._flushAtOnce count:').concat(o.length)), e.setItem(this.TAG, o, !0, !1)
      }
    } }, { key: 'reset', value() {
      Ee.log(''.concat(this._className, '.reset')), this._lastReportTime = 0, this._report()
    } }]), a
  }(Yt)); const ri = 'none'; const ii = 'online'; const ci = (function () {
    function e(t) {
      o(this, e), this._moduleManager = t, this._networkType = '', this._className = 'NetMonitorModule', this.MAX_WAIT_TIME = 3e3
    } return s(e, [{ key: 'start', value() {
      const e = this;if (z) {
        J.getNetworkType({ success(t) {
          e._networkType = t.networkType, t.networkType === ri ? Ee.warn(''.concat(e._className, '.start no network, please check!')) : Ee.info(''.concat(e._className, '.start networkType:').concat(t.networkType))
        } });const t = this._onNetworkStatusChange.bind(this);J.offNetworkStatusChange && (Y || H ? J.offNetworkStatusChange(t) : J.offNetworkStatusChange()), J.onNetworkStatusChange(t)
      } else this._networkType = ii
    } }, { key: '_onNetworkStatusChange', value(e) {
      e.isConnected ? (Ee.info(''.concat(this._className, '._onNetworkStatusChange previousNetworkType:').concat(this._networkType, ' currentNetworkType:')
        .concat(e.networkType)), this._networkType !== e.networkType && this._moduleManager.getModule(xt).reConnect()) : Ee.warn(''.concat(this._className, '._onNetworkStatusChange no network, please check!'));this._networkType = e.networkType
    } }, { key: 'probe', value() {
      const e = this;return new Promise(((t, n) => {
        if (z)J.getNetworkType({ success(n) {
          e._networkType = n.networkType, n.networkType === ri ? (Ee.warn(''.concat(e._className, '.probe no network, please check!')), t([!1, n.networkType])) : (Ee.info(''.concat(e._className, '.probe networkType:').concat(n.networkType)), t([!0, n.networkType]))
        } });else if (window && window.fetch)fetch(''.concat(We(), '//web.sdk.qcloud.com/im/assets/speed.xml?random=').concat(Math.random())).then(((e) => {
          e.ok ? t([!0, ii]) : t([!1, ri])
        }))
          .catch(((e) => {
            t([!1, ri])
          }));else {
          const o = new XMLHttpRequest; const a = setTimeout((() => {
            Ee.warn(''.concat(e._className, '.probe fetch timeout. Probably no network, please check!')), o.abort(), e._networkType = ri, t([!1, ri])
          }), e.MAX_WAIT_TIME);o.onreadystatechange = function () {
            4 === o.readyState && (clearTimeout(a), 200 === o.status || 304 === o.status ? (this._networkType = ii, t([!0, ii])) : (Ee.warn(''.concat(this.className, '.probe fetch status:').concat(o.status, '. Probably no network, please check!')), this._networkType = ri, t([!1, ri])))
          }, o.open('GET', ''.concat(We(), '//web.sdk.qcloud.com/im/assets/speed.xml?random=').concat(Math.random())), o.send()
        }
      }))
    } }, { key: 'getNetworkType', value() {
      return this._networkType
    } }]), e
  }()); const ui = A(((e) => {
    const t = Object.prototype.hasOwnProperty; let n = '~';function o() {} function a(e, t, n) {
      this.fn = e, this.context = t, this.once = n || !1
    } function s(e, t, o, s, r) {
      if ('function' !== typeof o) throw new TypeError('The listener must be a function');const i = new a(o, s || e, r); const c = n ? n + t : t;return e._events[c] ? e._events[c].fn ? e._events[c] = [e._events[c], i] : e._events[c].push(i) : (e._events[c] = i, e._eventsCount++), e
    } function r(e, t) {
      0 == --e._eventsCount ? e._events = new o : delete e._events[t]
    } function i() {
      this._events = new o, this._eventsCount = 0
    }Object.create && (o.prototype = Object.create(null), (new o).__proto__ || (n = !1)), i.prototype.eventNames = function () {
      let e; let o; const a = [];if (0 === this._eventsCount) return a;for (o in e = this._events)t.call(e, o) && a.push(n ? o.slice(1) : o);return Object.getOwnPropertySymbols ? a.concat(Object.getOwnPropertySymbols(e)) : a
    }, i.prototype.listeners = function (e) {
      const t = n ? n + e : e; const o = this._events[t];if (!o) return [];if (o.fn) return [o.fn];for (var a = 0, s = o.length, r = new Array(s);a < s;a++)r[a] = o[a].fn;return r
    }, i.prototype.listenerCount = function (e) {
      const t = n ? n + e : e; const o = this._events[t];return o ? o.fn ? 1 : o.length : 0
    }, i.prototype.emit = function (e, t, o, a, s, r) {
      const i = n ? n + e : e;if (!this._events[i]) return !1;let c; let u; const l = this._events[i]; const d = arguments.length;if (l.fn) {
        switch (l.once && this.removeListener(e, l.fn, void 0, !0), d) {
          case 1:return l.fn.call(l.context), !0;case 2:return l.fn.call(l.context, t), !0;case 3:return l.fn.call(l.context, t, o), !0;case 4:return l.fn.call(l.context, t, o, a), !0;case 5:return l.fn.call(l.context, t, o, a, s), !0;case 6:return l.fn.call(l.context, t, o, a, s, r), !0
        } for (u = 1, c = new Array(d - 1);u < d;u++)c[u - 1] = arguments[u];l.fn.apply(l.context, c)
      } else {
        let g; const p = l.length;for (u = 0;u < p;u++) switch (l[u].once && this.removeListener(e, l[u].fn, void 0, !0), d) {
          case 1:l[u].fn.call(l[u].context);break;case 2:l[u].fn.call(l[u].context, t);break;case 3:l[u].fn.call(l[u].context, t, o);break;case 4:l[u].fn.call(l[u].context, t, o, a);break;default:if (!c) for (g = 1, c = new Array(d - 1);g < d;g++)c[g - 1] = arguments[g];l[u].fn.apply(l[u].context, c)
        }
      } return !0
    }, i.prototype.on = function (e, t, n) {
      return s(this, e, t, n, !1)
    }, i.prototype.once = function (e, t, n) {
      return s(this, e, t, n, !0)
    }, i.prototype.removeListener = function (e, t, o, a) {
      const s = n ? n + e : e;if (!this._events[s]) return this;if (!t) return r(this, s), this;const i = this._events[s];if (i.fn)i.fn !== t || a && !i.once || o && i.context !== o || r(this, s);else {
        for (var c = 0, u = [], l = i.length;c < l;c++)(i[c].fn !== t || a && !i[c].once || o && i[c].context !== o) && u.push(i[c]);u.length ? this._events[s] = 1 === u.length ? u[0] : u : r(this, s)
      } return this
    }, i.prototype.removeAllListeners = function (e) {
      let t;return e ? (t = n ? n + e : e, this._events[t] && r(this, t)) : (this._events = new o, this._eventsCount = 0), this
    }, i.prototype.off = i.prototype.removeListener, i.prototype.addListener = i.prototype.on, i.prefixed = n, i.EventEmitter = i, e.exports = i
  })); const li = (function (e) {
    i(n, e);const t = f(n);function n(e) {
      let a;return o(this, n), (a = t.call(this, e))._className = 'BigDataChannelModule', a.FILETYPE = { SOUND: 2106, FILE: 2107, VIDEO: 2113 }, a._bdh_download_server = 'grouptalk.c2c.qq.com', a._BDHBizID = 10001, a._authKey = '', a._expireTime = 0, a.getInnerEmitterInstance().on(Ir.CONTEXT_A2KEY_AND_TINYID_UPDATED, a._getAuthKey, h(a)), a
    } return s(n, [{ key: '_getAuthKey', value() {
      const e = this;this.request({ protocolName: Qt }).then(((t) => {
        t.data.authKey && (e._authKey = t.data.authKey, e._expireTime = parseInt(t.data.expireTime))
      }))
    } }, { key: '_isFromOlderVersion', value(e) {
      return !(!e.content || 2 === e.content.downloadFlag)
    } }, { key: 'parseElements', value(e, t) {
      if (!Re(e) || !t) return [];for (var n = [], o = null, a = 0;a < e.length;a++)o = e[a], this._needParse(o) ? n.push(this._parseElement(o, t)) : n.push(e[a]);return n
    } }, { key: '_needParse', value(e) {
      return !e.cloudCustomData && !(!this._isFromOlderVersion(e) || e.type !== k.MSG_AUDIO && e.type !== k.MSG_FILE && e.type !== k.MSG_VIDEO)
    } }, { key: '_parseElement', value(e, t) {
      switch (e.type) {
        case k.MSG_AUDIO:return this._parseAudioElement(e, t);case k.MSG_FILE:return this._parseFileElement(e, t);case k.MSG_VIDEO:return this._parseVideoElement(e, t)
      }
    } }, { key: '_parseAudioElement', value(e, t) {
      return e.content.url = this._genAudioUrl(e.content.uuid, t), e
    } }, { key: '_parseFileElement', value(e, t) {
      return e.content.url = this._genFileUrl(e.content.uuid, t, e.content.fileName), e
    } }, { key: '_parseVideoElement', value(e, t) {
      return e.content.url = this._genVideoUrl(e.content.uuid, t), e
    } }, { key: '_genAudioUrl', value(e, t) {
      if ('' === this._authKey) return Ee.warn(''.concat(this._className, '._genAudioUrl no authKey!')), '';const n = this.getModule(Gt).getSDKAppID();return 'https://'.concat(this._bdh_download_server, '/asn.com/stddownload_common_file?authkey=').concat(this._authKey, '&bid=')
        .concat(this._BDHBizID, '&subbid=')
        .concat(n, '&fileid=')
        .concat(e, '&filetype=')
        .concat(this.FILETYPE.SOUND, '&openid=')
        .concat(t, '&ver=0')
    } }, { key: '_genFileUrl', value(e, t, n) {
      if ('' === this._authKey) return Ee.warn(''.concat(this._className, '._genFileUrl no authKey!')), '';n || (n = ''.concat(Math.floor(1e5 * Math.random()), '-').concat(Date.now()));const o = this.getModule(Gt).getSDKAppID();return 'https://'.concat(this._bdh_download_server, '/asn.com/stddownload_common_file?authkey=').concat(this._authKey, '&bid=')
        .concat(this._BDHBizID, '&subbid=')
        .concat(o, '&fileid=')
        .concat(e, '&filetype=')
        .concat(this.FILETYPE.FILE, '&openid=')
        .concat(t, '&ver=0&filename=')
        .concat(encodeURIComponent(n))
    } }, { key: '_genVideoUrl', value(e, t) {
      if ('' === this._authKey) return Ee.warn(''.concat(this._className, '._genVideoUrl no authKey!')), '';const n = this.getModule(Gt).getSDKAppID();return 'https://'.concat(this._bdh_download_server, '/asn.com/stddownload_common_file?authkey=').concat(this._authKey, '&bid=')
        .concat(this._BDHBizID, '&subbid=')
        .concat(n, '&fileid=')
        .concat(e, '&filetype=')
        .concat(this.FILETYPE.VIDEO, '&openid=')
        .concat(t, '&ver=0')
    } }, { key: 'reset', value() {
      Ee.log(''.concat(this._className, '.reset')), this._authKey = '', this.expireTime = 0
    } }]), n
  }(Yt)); const di = (function (e) {
    i(a, e);const n = f(a);function a(e) {
      let t;return o(this, a), (t = n.call(this, e))._className = 'UploadModule', t.TIMUploadPlugin = null, t.timUploadPlugin = null, t.COSSDK = null, t._cosUploadMethod = null, t.expiredTimeLimit = 600, t.appid = 0, t.bucketName = '', t.ciUrl = '', t.directory = '', t.downloadUrl = '', t.uploadUrl = '', t.region = 'ap-shanghai', t.cos = null, t.cosOptions = { secretId: '', secretKey: '', sessionToken: '', expiredTime: 0 }, t.uploadFileType = '', t.duration = 900, t.tryCount = 0, t.getInnerEmitterInstance().on(Ir.CONTEXT_A2KEY_AND_TINYID_UPDATED, t._init, h(t)), t
    } return s(a, [{ key: '_init', value() {
      const e = ''.concat(this._className, '._init'); const t = this.getModule(qt);if (this.TIMUploadPlugin = t.getPlugin('tim-upload-plugin'), this.TIMUploadPlugin) this._initUploaderMethod();else {
        const n = z ? 'cos-wx-sdk' : 'cos-js-sdk';this.COSSDK = t.getPlugin(n), this.COSSDK ? (this._getAuthorizationKey(), Ee.warn(''.concat(e, ' v2.9.2起推荐使用 tim-upload-plugin 代替 ').concat(n, '，上传更快更安全。详细请参考 https://web.sdk.qcloud.com/im/doc/zh-cn/SDK.html#registerPlugin'))) : Ee.warn(''.concat(e, ' 没有检测到上传插件，将无法发送图片、音频、视频、文件等类型的消息。详细请参考 https://web.sdk.qcloud.com/im/doc/zh-cn/SDK.html#registerPlugin'))
      }
    } }, { key: '_getAuthorizationKey', value() {
      const e = this; const t = new Da(Ga); const n = Math.ceil(Date.now() / 1e3);this.request({ protocolName: xn, requestData: { duration: this.expiredTimeLimit } }).then(((o) => {
        const a = o.data;Ee.log(''.concat(e._className, '._getAuthorizationKey ok. data:'), a);const s = a.expiredTime - n;t.setMessage('requestId:'.concat(a.requestId, ' requestTime:').concat(n, ' expiredTime:')
          .concat(a.expiredTime, ' diff:')
          .concat(s, 's')).setNetworkType(e.getNetworkType())
          .end(), !z && a.region && (e.region = a.region), e.appid = a.appid, e.bucketName = a.bucketName, e.ciUrl = a.ciUrl, e.directory = a.directory, e.downloadUrl = a.downloadUrl, e.uploadUrl = a.uploadUrl, e.cosOptions = { secretId: a.secretId, secretKey: a.secretKey, sessionToken: a.sessionToken, expiredTime: a.expiredTime }, Ee.log(''.concat(e._className, '._getAuthorizationKey ok. region:').concat(e.region, ' bucketName:')
          .concat(e.bucketName)), e._initUploaderMethod()
      }))
        .catch(((n) => {
          e.probeNetwork().then(((e) => {
            const o = m(e, 2); const a = o[0]; const s = o[1];t.setError(n, a, s).end()
          })), Ee.warn(''.concat(e._className, '._getAuthorizationKey failed. error:'), n)
        }))
    } }, { key: '_getCosPreSigUrl', value(e) {
      const t = this; const n = ''.concat(this._className, '._getCosPreSigUrl'); const o = Math.ceil(Date.now() / 1e3); const a = new Da(wa);return this.request({ protocolName: Bn, requestData: { fileType: e.fileType, fileName: e.fileName, uploadMethod: e.uploadMethod, duration: e.duration } }).then(((e) => {
        t.tryCount = 0;const s = e.data || {}; const r = s.expiredTime - o;return Ee.log(''.concat(n, ' ok. data:'), s), a.setMessage('requestId:'.concat(s.requestId, ' expiredTime:').concat(s.expiredTime, ' diff:')
          .concat(r, 's')).setNetworkType(t.getNetworkType())
          .end(), s
      }))
        .catch(((o) => (-1 === o.code && (o.code = Zn.COS_GET_SIG_FAIL), t.probeNetwork().then(((e) => {
          const t = m(e, 2); const n = t[0]; const s = t[1];a.setError(o, n, s).end()
        })), Ee.warn(''.concat(n, ' failed. error:'), o), t.tryCount < 1 ? (t.tryCount++, t._getCosPreSigUrl(e)) : (t.tryCount = 0, Mr({ code: Zn.COS_GET_SIG_FAIL, message: io })))))
    } }, { key: '_initUploaderMethod', value() {
      const e = this;if (this.TIMUploadPlugin) return this.timUploadPlugin = new this.TIMUploadPlugin, void(this._cosUploadMethod = function (t, n) {
        e.timUploadPlugin.uploadFile(t, n)
      });this.appid && (this.cos = z ? new this.COSSDK({ ForcePathStyle: !0, getAuthorization: this._getAuthorization.bind(this) }) : new this.COSSDK({ getAuthorization: this._getAuthorization.bind(this) }), this._cosUploadMethod = z ? function (t, n) {
        e.cos.postObject(t, n)
      } : function (t, n) {
        e.cos.uploadFiles(t, n)
      })
    } }, { key: 'onCheckTimer', value(e) {
      this.COSSDK && (this.TIMUploadPlugin || this.isLoggedIn() && e % 60 == 0 && Math.ceil(Date.now() / 1e3) >= this.cosOptions.expiredTime - 120 && this._getAuthorizationKey())
    } }, { key: '_getAuthorization', value(e, t) {
      t({ TmpSecretId: this.cosOptions.secretId, TmpSecretKey: this.cosOptions.secretKey, XCosSecurityToken: this.cosOptions.sessionToken, ExpiredTime: this.cosOptions.expiredTime })
    } }, { key: 'upload', value(e) {
      if (!0 === e.getRelayFlag()) return Promise.resolve();const t = this.getModule($t);switch (e.type) {
        case k.MSG_IMAGE:return t.addTotalCount(_a), this._uploadImage(e);case k.MSG_FILE:return t.addTotalCount(_a), this._uploadFile(e);case k.MSG_AUDIO:return t.addTotalCount(_a), this._uploadAudio(e);case k.MSG_VIDEO:return t.addTotalCount(_a), this._uploadVideo(e);default:return Promise.resolve()
      }
    } }, { key: '_uploadImage', value(e) {
      const n = this.getModule(kt); const o = e.getElements()[0]; const a = n.getMessageOptionByID(e.ID);return this.doUploadImage({ file: a.payload.file, to: a.to, onProgress(e) {
        if (o.updatePercent(e), Pe(a.onProgress)) try {
          a.onProgress(e)
        } catch (t) {
          return Mr({ code: Zn.MESSAGE_ONPROGRESS_FUNCTION_ERROR, message: po })
        }
      } }).then(((n) => {
        const a = n.location; const s = n.fileType; const r = n.fileSize; const i = n.width; const c = n.height; const u = Je(a);o.updateImageFormat(s);const l = rt({ originUrl: u, originWidth: i, originHeight: c, min: 198 }); const d = rt({ originUrl: u, originWidth: i, originHeight: c, min: 720 });return o.updateImageInfoArray([{ size: r, url: u, width: i, height: c }, t({}, d), t({}, l)]), e
      }))
    } }, { key: '_uploadFile', value(e) {
      const t = this.getModule(kt); const n = e.getElements()[0]; const o = t.getMessageOptionByID(e.ID);return this.doUploadFile({ file: o.payload.file, to: o.to, onProgress(e) {
        if (n.updatePercent(e), Pe(o.onProgress)) try {
          o.onProgress(e)
        } catch (t) {
          return Mr({ code: Zn.MESSAGE_ONPROGRESS_FUNCTION_ERROR, message: po })
        }
      } }).then(((t) => {
        const o = t.location; const a = Je(o);return n.updateFileUrl(a), e
      }))
    } }, { key: '_uploadAudio', value(e) {
      const t = this.getModule(kt); const n = e.getElements()[0]; const o = t.getMessageOptionByID(e.ID);return this.doUploadAudio({ file: o.payload.file, to: o.to, onProgress(e) {
        if (n.updatePercent(e), Pe(o.onProgress)) try {
          o.onProgress(e)
        } catch (t) {
          return Mr({ code: Zn.MESSAGE_ONPROGRESS_FUNCTION_ERROR, message: po })
        }
      } }).then(((t) => {
        const o = t.location; const a = Je(o);return n.updateAudioUrl(a), e
      }))
    } }, { key: '_uploadVideo', value(e) {
      const t = this.getModule(kt); const n = e.getElements()[0]; const o = t.getMessageOptionByID(e.ID);return this.doUploadVideo({ file: o.payload.file, to: o.to, onProgress(e) {
        if (n.updatePercent(e), Pe(o.onProgress)) try {
          o.onProgress(e)
        } catch (t) {
          return Mr({ code: Zn.MESSAGE_ONPROGRESS_FUNCTION_ERROR, message: po })
        }
      } }).then(((t) => {
        const o = Je(t.location);return n.updateVideoUrl(o), e
      }))
    } }, { key: 'doUploadImage', value(e) {
      if (!e.file) return Mr({ code: Zn.MESSAGE_IMAGE_SELECT_FILE_FIRST, message: fo });const t = this._checkImageType(e.file);if (!0 !== t) return t;const n = this._checkImageSize(e.file);if (!0 !== n) return n;let o = null;return this._setUploadFileType(Er), this.uploadByCOS(e).then(((e) => {
        return o = e, t = 'https://'.concat(e.location), z ? new Promise(((e, n) => {
          J.getImageInfo({ src: t, success(t) {
            e({ width: t.width, height: t.height })
          }, fail() {
            e({ width: 0, height: 0 })
          } })
        })) : ce && 9 === ue ? Promise.resolve({ width: 0, height: 0 }) : new Promise(((e, n) => {
          let o = new Image;o.onload = function () {
            e({ width: this.width, height: this.height }), o = null
          }, o.onerror = function () {
            e({ width: 0, height: 0 }), o = null
          }, o.src = t
        }));let t
      }))
        .then(((e) => (o.width = e.width, o.height = e.height, Promise.resolve(o))))
    } }, { key: '_checkImageType', value(e) {
      let t = '';return t = z ? e.url.slice(e.url.lastIndexOf('.') + 1) : e.files[0].name.slice(e.files[0].name.lastIndexOf('.') + 1), Tr.indexOf(t.toLowerCase()) >= 0 || Mr({ code: Zn.MESSAGE_IMAGE_TYPES_LIMIT, message: mo })
    } }, { key: '_checkImageSize', value(e) {
      let t = 0;return 0 === (t = z ? e.size : e.files[0].size) ? Mr({ code: Zn.MESSAGE_FILE_IS_EMPTY, message: ''.concat(go) }) : t < 20971520 || Mr({ code: Zn.MESSAGE_IMAGE_SIZE_LIMIT, message: ''.concat(Mo) })
    } }, { key: 'doUploadFile', value(e) {
      let t = null;return e.file ? e.file.files[0].size > 104857600 ? Mr(t = { code: Zn.MESSAGE_FILE_SIZE_LIMIT, message: ko }) : 0 === e.file.files[0].size ? (t = { code: Zn.MESSAGE_FILE_IS_EMPTY, message: ''.concat(go) }, Mr(t)) : (this._setUploadFileType(Nr), this.uploadByCOS(e)) : Mr(t = { code: Zn.MESSAGE_FILE_SELECT_FILE_FIRST, message: Eo })
    } }, { key: 'doUploadVideo', value(e) {
      return e.file.videoFile.size > 104857600 ? Mr({ code: Zn.MESSAGE_VIDEO_SIZE_LIMIT, message: ''.concat(Do) }) : 0 === e.file.videoFile.size ? Mr({ code: Zn.MESSAGE_FILE_IS_EMPTY, message: ''.concat(go) }) : -1 === Sr.indexOf(e.file.videoFile.type) ? Mr({ code: Zn.MESSAGE_VIDEO_TYPES_LIMIT, message: ''.concat(To) }) : (this._setUploadFileType(kr), z ? this.handleVideoUpload({ file: e.file.videoFile, onProgress: e.onProgress }) : W ? this.handleVideoUpload(e) : void 0)
    } }, { key: 'handleVideoUpload', value(e) {
      const t = this;return new Promise(((n, o) => {
        t.uploadByCOS(e).then(((e) => {
          n(e)
        }))
          .catch((() => {
            t.uploadByCOS(e).then(((e) => {
              n(e)
            }))
              .catch((() => {
                o(new hr({ code: Zn.MESSAGE_VIDEO_UPLOAD_FAIL, message: Io }))
              }))
          }))
      }))
    } }, { key: 'doUploadAudio', value(e) {
      return e.file ? e.file.size > 20971520 ? Mr(new hr({ code: Zn.MESSAGE_AUDIO_SIZE_LIMIT, message: ''.concat(yo) })) : 0 === e.file.size ? Mr(new hr({ code: Zn.MESSAGE_FILE_IS_EMPTY, message: ''.concat(go) })) : (this._setUploadFileType(Cr), this.uploadByCOS(e)) : Mr(new hr({ code: Zn.MESSAGE_AUDIO_UPLOAD_FAIL, message: vo }))
    } }, { key: 'uploadByCOS', value(e) {
      const t = this; const n = ''.concat(this._className, '.uploadByCOS');if (!Pe(this._cosUploadMethod)) return Ee.warn(''.concat(n, ' 没有检测到上传插件，将无法发送图片、音频、视频、文件等类型的消息。详细请参考 https://web.sdk.qcloud.com/im/doc/zh-cn/SDK.html#registerPlugin')), Mr({ code: Zn.COS_UNDETECTED, message: ro });if (this.timUploadPlugin) return this._uploadWithPreSigUrl(e);const o = new Da(Pa); const a = Date.now(); const s = z ? e.file : e.file.files[0];return new Promise(((r, i) => {
        const c = z ? t._createCosOptionsWXMiniApp(e) : t._createCosOptionsWeb(e); const u = t;t._cosUploadMethod(c, ((e, c) => {
          const l = Object.create(null);if (c) {
            if (e || Re(c.files) && c.files[0].error) {
              const d = new hr({ code: Zn.MESSAGE_FILE_UPLOAD_FAIL, message: So });return o.setError(d, !0, t.getNetworkType()).end(), Ee.log(''.concat(n, ' failed. error:'), c.files[0].error), 403 === c.files[0].error.statusCode && (Ee.warn(''.concat(n, ' failed. cos AccessKeyId was invalid, regain auth key!')), t._getAuthorizationKey()), void i(d)
            }l.fileName = s.name, l.fileSize = s.size, l.fileType = s.type.slice(s.type.indexOf('/') + 1).toLowerCase(), l.location = z ? c.Location : c.files[0].data.Location;const g = Date.now() - a; const p = u._formatFileSize(s.size); const h = u._formatSpeed(1e3 * s.size / g); const _ = 'size:'.concat(p, ' time:').concat(g, 'ms speed:')
              .concat(h);Ee.log(''.concat(n, ' success. name:').concat(s.name, ' ')
              .concat(_)), r(l);const f = t.getModule($t);return f.addCost(_a, g), f.addFileSize(_a, s.size), void o.setNetworkType(t.getNetworkType()).setMessage(_)
              .end()
          } const m = new hr({ code: Zn.MESSAGE_FILE_UPLOAD_FAIL, message: So });o.setError(m, !0, u.getNetworkType()).end(), Ee.warn(''.concat(n, ' failed. error:'), e), 403 === e.statusCode && (Ee.warn(''.concat(n, ' failed. cos AccessKeyId was invalid, regain auth key!')), t._getAuthorizationKey()), i(m)
        }))
      }))
    } }, { key: '_uploadWithPreSigUrl', value(e) {
      const t = this; const n = ''.concat(this._className, '._uploadWithPreSigUrl'); const o = z ? e.file : e.file.files[0];return this._createCosOptionsPreSigUrl(e).then(((e) => new Promise(((a, s) => {
        const r = new Da(Pa);Ee.time(ca), t._cosUploadMethod(e, ((e, i) => {
          const c = Object.create(null);if (e || 403 === i.statusCode) {
            const u = new hr({ code: Zn.MESSAGE_FILE_UPLOAD_FAIL, message: So });return r.setError(u, !0, t.getNetworkType()).end(), Ee.log(''.concat(n, ' failed, error:'), e), void s(u)
          } let l = i.data.location || '';0 !== l.indexOf('https://') && 0 !== l.indexOf('http://') || (l = l.split('//')[1]), c.fileName = o.name, c.fileSize = o.size, c.fileType = o.type.slice(o.type.indexOf('/') + 1).toLowerCase(), c.location = l;const d = Ee.timeEnd(ca); const g = t._formatFileSize(o.size); const p = t._formatSpeed(1e3 * o.size / d); const h = 'size:'.concat(g, ',time:').concat(d, 'ms,speed:')
            .concat(p);Ee.log(''.concat(n, ' success name:').concat(o.name, ',')
            .concat(h)), r.setNetworkType(t.getNetworkType()).setMessage(h)
            .end();const _ = t.getModule($t);_.addCost(_a, d), _.addFileSize(_a, o.size), a(c)
        }))
      }))))
    } }, { key: '_formatFileSize', value(e) {
      return e < 1024 ? `${e}B` : e < 1048576 ? `${Math.floor(e / 1024)}KB` : `${Math.floor(e / 1048576)}MB`
    } }, { key: '_formatSpeed', value(e) {
      return e <= 1048576 ? `${ut(e / 1024, 1)}KB/s` : `${ut(e / 1048576, 1)}MB/s`
    } }, { key: '_createCosOptionsWeb', value(e) {
      const t = this.getMyUserID(); const n = this._genFileName(t, e.to, e.file.files[0].name);return { files: [{ Bucket: ''.concat(this.bucketName, '-').concat(this.appid), Region: this.region, Key: ''.concat(this.directory, '/').concat(n), Body: e.file.files[0] }], SliceSize: 1048576, onProgress(t) {
        if ('function' === typeof e.onProgress) try {
          e.onProgress(t.percent)
        } catch (n) {
          Ee.warn('onProgress callback error:', n)
        }
      }, onFileFinish(e, t, n) {} }
    } }, { key: '_createCosOptionsWXMiniApp', value(e) {
      const t = this.getMyUserID(); const n = this._genFileName(t, e.to, e.file.name); const o = e.file.url;return { Bucket: ''.concat(this.bucketName, '-').concat(this.appid), Region: this.region, Key: ''.concat(this.directory, '/').concat(n), FilePath: o, onProgress(t) {
        if (Ee.log(JSON.stringify(t)), 'function' === typeof e.onProgress) try {
          e.onProgress(t.percent)
        } catch (n) {
          Ee.warn('onProgress callback error:', n)
        }
      } }
    } }, { key: '_createCosOptionsPreSigUrl', value(e) {
      const t = this; let n = ''; let o = ''; let a = 0;return z ? (n = this._genFileName(e.file.name), o = e.file.url, a = 1) : (n = this._genFileName(''.concat(He(999999))), o = e.file.files[0], a = 0), this._getCosPreSigUrl({ fileType: this.uploadFileType, fileName: n, uploadMethod: a, duration: this.duration }).then(((a) => {
        const s = a.uploadUrl; const r = a.downloadUrl;return { url: s, fileType: t.uploadFileType, fileName: n, resources: o, downloadUrl: r, onProgress(t) {
          if ('function' === typeof e.onProgress) try {
            e.onProgress(t.percent)
          } catch (n) {
            Ee.warn('onProgress callback error:', n), Ee.error(n)
          }
        } }
      }))
    } }, { key: '_genFileName', value(e) {
      return ''.concat(at(), '-').concat(e)
    } }, { key: '_setUploadFileType', value(e) {
      this.uploadFileType = e
    } }, { key: 'reset', value() {
      Ee.log(''.concat(this._className, '.reset'))
    } }]), a
  }(Yt)); const gi = ['downloadKey', 'pbDownloadKey', 'messageList']; const pi = (function () {
    function e(t) {
      o(this, e), this._className = 'MergerMessageHandler', this._messageModule = t
    } return s(e, [{ key: 'uploadMergerMessage', value(e, t) {
      const n = this;Ee.debug(''.concat(this._className, '.uploadMergerMessage message:'), e, 'messageBytes:'.concat(t));const o = e.payload.messageList; const a = o.length; const s = new Da(ja);return this._messageModule.request({ protocolName: Wn, requestData: { messageList: o } }).then(((e) => {
        Ee.debug(''.concat(n._className, '.uploadMergerMessage ok. response:'), e.data);const o = e.data; const r = o.pbDownloadKey; const i = o.downloadKey; const c = { pbDownloadKey: r, downloadKey: i, messageNumber: a };return s.setNetworkType(n._messageModule.getNetworkType()).setMessage(''.concat(a, '-').concat(t, '-')
          .concat(i))
          .end(), c
      }))
        .catch(((e) => {
          throw Ee.warn(''.concat(n._className, '.uploadMergerMessage failed. error:'), e), n._messageModule.probeNetwork().then(((t) => {
            const n = m(t, 2); const o = n[0]; const a = n[1];s.setError(e, o, a).end()
          })), e
        }))
    } }, { key: 'downloadMergerMessage', value(e) {
      const n = this;Ee.debug(''.concat(this._className, '.downloadMergerMessage message:'), e);const o = e.payload.downloadKey; const a = new Da($a);return a.setMessage('downloadKey:'.concat(o)), this._messageModule.request({ protocolName: Jn, requestData: { downloadKey: o } }).then(((o) => {
        if (Ee.debug(''.concat(n._className, '.downloadMergerMessage ok. response:'), o.data), Pe(e.clearElement)) {
          const s = e.payload; const r = (s.downloadKey, s.pbDownloadKey, s.messageList, p(s, gi));e.clearElement(), e.setElement({ type: e.type, content: t({ messageList: o.data.messageList }, r) })
        } else {
          const i = [];o.data.messageList.forEach(((e) => {
            if (!dt(e)) {
              const t = new ar(e);i.push(t)
            }
          })), e.payload.messageList = i, e.payload.downloadKey = '', e.payload.pbDownloadKey = ''
        } return a.setNetworkType(n._messageModule.getNetworkType()).end(), e
      }))
        .catch(((e) => {
          throw Ee.warn(''.concat(n._className, '.downloadMergerMessage failed. key:').concat(o, ' error:'), e), n._messageModule.probeNetwork().then(((t) => {
            const n = m(t, 2); const o = n[0]; const s = n[1];a.setError(e, o, s).end()
          })), e
        }))
    } }, { key: 'createMergerMessagePack', value(e, t, n) {
      return e.conversationType === k.CONV_C2C ? this._createC2CMergerMessagePack(e, t, n) : this._createGroupMergerMessagePack(e, t, n)
    } }, { key: '_createC2CMergerMessagePack', value(e, t, n) {
      let o = null;t && (t.offlinePushInfo && (o = t.offlinePushInfo), !0 === t.onlineUserOnly && (o ? o.disablePush = !0 : o = { disablePush: !0 }));let a = '';Ae(e.cloudCustomData) && e.cloudCustomData.length > 0 && (a = e.cloudCustomData);const s = n.pbDownloadKey; const r = n.downloadKey; const i = n.messageNumber; const c = e.payload; const u = c.title; const l = c.abstractList; const d = c.compatibleText; const g = this._messageModule.getModule(Nt);return { protocolName: Zt, tjgID: this._messageModule.generateTjgID(e), requestData: { fromAccount: this._messageModule.getMyUserID(), toAccount: e.to, msgBody: [{ msgType: e.type, msgContent: { pbDownloadKey: s, downloadKey: r, title: u, abstractList: l, compatibleText: d, messageNumber: i } }], cloudCustomData: a, msgSeq: e.sequence, msgRandom: e.random, msgLifeTime: g && g.isOnlineMessage(e, t) ? 0 : void 0, offlinePushInfo: o ? { pushFlag: !0 === o.disablePush ? 1 : 0, title: o.title || '', desc: o.description || '', ext: o.extension || '', apnsInfo: { badgeMode: !0 === o.ignoreIOSBadge ? 1 : 0 }, androidInfo: { OPPOChannelID: o.androidOPPOChannelID || '' } } : void 0 } }
    } }, { key: '_createGroupMergerMessagePack', value(e, t, n) {
      let o = null;t && t.offlinePushInfo && (o = t.offlinePushInfo);let a = '';Ae(e.cloudCustomData) && e.cloudCustomData.length > 0 && (a = e.cloudCustomData);const s = n.pbDownloadKey; const r = n.downloadKey; const i = n.messageNumber; const c = e.payload; const u = c.title; const l = c.abstractList; const d = c.compatibleText; const g = this._messageModule.getModule(At);return { protocolName: en, tjgID: this._messageModule.generateTjgID(e), requestData: { fromAccount: this._messageModule.getMyUserID(), groupID: e.to, msgBody: [{ msgType: e.type, msgContent: { pbDownloadKey: s, downloadKey: r, title: u, abstractList: l, compatibleText: d, messageNumber: i } }], random: e.random, priority: e.priority, clientSequence: e.clientSequence, groupAtInfo: void 0, cloudCustomData: a, onlineOnlyFlag: g && g.isOnlineMessage(e, t) ? 1 : 0, offlinePushInfo: o ? { pushFlag: !0 === o.disablePush ? 1 : 0, title: o.title || '', desc: o.description || '', ext: o.extension || '', apnsInfo: { badgeMode: !0 === o.ignoreIOSBadge ? 1 : 0 }, androidInfo: { OPPOChannelID: o.androidOPPOChannelID || '' } } : void 0 } }
    } }]), e
  }()); const hi = { ERR_SVR_COMM_SENSITIVE_TEXT: 80001, ERR_SVR_COMM_BODY_SIZE_LIMIT: 80002, ERR_SVR_MSG_PKG_PARSE_FAILED: 20001, ERR_SVR_MSG_INTERNAL_AUTH_FAILED: 20002, ERR_SVR_MSG_INVALID_ID: 20003, ERR_SVR_MSG_PUSH_DENY: 20006, ERR_SVR_MSG_IN_PEER_BLACKLIST: 20007, ERR_SVR_MSG_BOTH_NOT_FRIEND: 20009, ERR_SVR_MSG_NOT_PEER_FRIEND: 20010, ERR_SVR_MSG_NOT_SELF_FRIEND: 20011, ERR_SVR_MSG_SHUTUP_DENY: 20012, ERR_SVR_GROUP_INVALID_PARAMETERS: 10004, ERR_SVR_GROUP_PERMISSION_DENY: 10007, ERR_SVR_GROUP_NOT_FOUND: 10010, ERR_SVR_GROUP_INVALID_GROUPID: 10015, ERR_SVR_GROUP_REJECT_FROM_THIRDPARTY: 10016, ERR_SVR_GROUP_SHUTUP_DENY: 10017, MESSAGE_SEND_FAIL: 2100 }; const _i = [Zn.MESSAGE_ONPROGRESS_FUNCTION_ERROR, Zn.MESSAGE_IMAGE_SELECT_FILE_FIRST, Zn.MESSAGE_IMAGE_TYPES_LIMIT, Zn.MESSAGE_FILE_IS_EMPTY, Zn.MESSAGE_IMAGE_SIZE_LIMIT, Zn.MESSAGE_FILE_SELECT_FILE_FIRST, Zn.MESSAGE_FILE_SIZE_LIMIT, Zn.MESSAGE_VIDEO_SIZE_LIMIT, Zn.MESSAGE_VIDEO_TYPES_LIMIT, Zn.MESSAGE_AUDIO_UPLOAD_FAIL, Zn.MESSAGE_AUDIO_SIZE_LIMIT, Zn.COS_UNDETECTED];const fi = (function (e) {
    i(n, e);const t = f(n);function n(e) {
      let a;return o(this, n), (a = t.call(this, e))._className = 'MessageModule', a._messageOptionsMap = new Map, a._mergerMessageHandler = new pi(h(a)), a
    } return s(n, [{ key: 'createTextMessage', value(e) {
      const t = this.getMyUserID();e.currentUser = t;const n = new ir(e); const o = 'string' === typeof e.payload ? e.payload : e.payload.text; const a = new qs({ text: o }); const s = this._getNickAndAvatarByUserID(t);return n.setElement(a), n.setNickAndAvatar(s), n
    } }, { key: 'createImageMessage', value(e) {
      const t = this.getMyUserID();e.currentUser = t;const n = new ir(e);if (z) {
        const o = e.payload.file;if (Ce(o)) return void Ee.warn('小程序环境下调用 createImageMessage 接口时，payload.file 不支持传入 File 对象');const a = o.tempFilePaths[0]; const s = { url: a, name: a.slice(a.lastIndexOf('/') + 1), size: o.tempFiles && o.tempFiles[0].size || 1, type: a.slice(a.lastIndexOf('.') + 1).toLowerCase() };e.payload.file = s
      } else if (W) if (Ce(e.payload.file)) {
        const r = e.payload.file;e.payload.file = { files: [r] }
      } else if (Le(e.payload.file) && 'undefined' !== typeof uni) {
        const i = e.payload.file.tempFiles[0];e.payload.file = { files: [i] }
      } const c = new Ys({ imageFormat: Vs.IMAGE_FORMAT.UNKNOWN, uuid: this._generateUUID(), file: e.payload.file }); const u = this._getNickAndAvatarByUserID(t);return n.setElement(c), n.setNickAndAvatar(u), this._messageOptionsMap.set(n.ID, e), n
    } }, { key: 'createAudioMessage', value(e) {
      if (z) {
        const t = e.payload.file;if (z) {
          const n = { url: t.tempFilePath, name: t.tempFilePath.slice(t.tempFilePath.lastIndexOf('/') + 1), size: t.fileSize, second: parseInt(t.duration) / 1e3, type: t.tempFilePath.slice(t.tempFilePath.lastIndexOf('.') + 1).toLowerCase() };e.payload.file = n
        } const o = this.getMyUserID();e.currentUser = o;const a = new ir(e); const s = new Ws({ second: Math.floor(t.duration / 1e3), size: t.fileSize, url: t.tempFilePath, uuid: this._generateUUID() }); const r = this._getNickAndAvatarByUserID(o);return a.setElement(s), a.setNickAndAvatar(r), this._messageOptionsMap.set(a.ID, e), a
      }Ee.warn('createAudioMessage 目前只支持小程序环境下发语音消息')
    } }, { key: 'createVideoMessage', value(e) {
      const t = this.getMyUserID();e.currentUser = t, e.payload.file.thumbUrl = 'https://web.sdk.qcloud.com/im/assets/images/transparent.png', e.payload.file.thumbSize = 1668;const n = {};if (z) {
        if ($) return void Ee.warn('createVideoMessage 不支持在支付宝小程序环境下使用');if (Ce(e.payload.file)) return void Ee.warn('小程序环境下调用 createVideoMessage 接口时，payload.file 不支持传入 File 对象');const o = e.payload.file;n.url = o.tempFilePath, n.name = o.tempFilePath.slice(o.tempFilePath.lastIndexOf('/') + 1), n.size = o.size, n.second = o.duration, n.type = o.tempFilePath.slice(o.tempFilePath.lastIndexOf('.') + 1).toLowerCase()
      } else if (W) {
        if (Ce(e.payload.file)) {
          const a = e.payload.file;e.payload.file.files = [a]
        } else if (Le(e.payload.file) && 'undefined' !== typeof uni) {
          const s = e.payload.file.tempFile;e.payload.file.files = [s]
        } const r = e.payload.file;n.url = window.URL.createObjectURL(r.files[0]), n.name = r.files[0].name, n.size = r.files[0].size, n.second = r.files[0].duration || 0, n.type = r.files[0].type.split('/')[1]
      }e.payload.file.videoFile = n;const i = new ir(e); const c = new nr({ videoFormat: n.type, videoSecond: ut(n.second, 0), videoSize: n.size, remoteVideoUrl: '', videoUrl: n.url, videoUUID: this._generateUUID(), thumbUUID: this._generateUUID(), thumbWidth: e.payload.file.width || 200, thumbHeight: e.payload.file.height || 200, thumbUrl: e.payload.file.thumbUrl, thumbSize: e.payload.file.thumbSize, thumbFormat: e.payload.file.thumbUrl.slice(e.payload.file.thumbUrl.lastIndexOf('.') + 1).toLowerCase() }); const u = this._getNickAndAvatarByUserID(t);return i.setElement(c), i.setNickAndAvatar(u), this._messageOptionsMap.set(i.ID, e), i
    } }, { key: 'createCustomMessage', value(e) {
      const t = this.getMyUserID();e.currentUser = t;const n = new ir(e); const o = new tr({ data: e.payload.data, description: e.payload.description, extension: e.payload.extension }); const a = this._getNickAndAvatarByUserID(t);return n.setElement(o), n.setNickAndAvatar(a), n
    } }, { key: 'createFaceMessage', value(e) {
      const t = this.getMyUserID();e.currentUser = t;const n = new ir(e); const o = new zs(e.payload); const a = this._getNickAndAvatarByUserID(t);return n.setElement(o), n.setNickAndAvatar(a), n
    } }, { key: 'createMergerMessage', value(e) {
      const t = this.getMyUserID();e.currentUser = t;const n = this._getNickAndAvatarByUserID(t); const o = new ir(e); const a = new sr(e.payload);return o.setElement(a), o.setNickAndAvatar(n), o.setRelayFlag(!0), o
    } }, { key: 'createForwardMessage', value(e) {
      const t = e.to; const n = e.conversationType; const o = e.priority; const a = e.payload; const s = this.getMyUserID(); const r = this._getNickAndAvatarByUserID(s);if (a.type === k.MSG_GRP_TIP) return Mr(new hr({ code: Zn.MESSAGE_FORWARD_TYPE_INVALID, message: Lo }));const i = { to: t, conversationType: n, conversationID: ''.concat(n).concat(t), priority: o, isPlaceMessage: 0, status: _t.UNSEND, currentUser: s, cloudCustomData: e.cloudCustomData || a.cloudCustomData || '' }; const c = new ir(i);return c.setElement(a.getElements()[0]), c.setNickAndAvatar(r), c.setRelayFlag(!0), c
    } }, { key: 'downloadMergerMessage', value(e) {
      return this._mergerMessageHandler.downloadMergerMessage(e)
    } }, { key: 'createFileMessage', value(e) {
      if (!z) {
        if (W) if (Ce(e.payload.file)) {
          const t = e.payload.file;e.payload.file = { files: [t] }
        } else if (Le(e.payload.file) && 'undefined' !== typeof uni) {
          const n = e.payload.file.tempFiles[0];e.payload.file = { files: [n] }
        } const o = this.getMyUserID();e.currentUser = o;const a = new ir(e); const s = new er({ uuid: this._generateUUID(), file: e.payload.file }); const r = this._getNickAndAvatarByUserID(o);return a.setElement(s), a.setNickAndAvatar(r), this._messageOptionsMap.set(a.ID, e), a
      }Ee.warn('小程序目前不支持选择文件， createFileMessage 接口不可用！')
    } }, { key: '_onCannotFindModule', value() {
      return Mr({ code: Zn.CANNOT_FIND_MODULE, message: ra })
    } }, { key: 'sendMessageInstance', value(e, t) {
      let n; const o = this; let a = null;switch (e.conversationType) {
        case k.CONV_C2C:if (!(a = this.getModule(Nt))) return this._onCannotFindModule();break;case k.CONV_GROUP:if (!(a = this.getModule(At))) return this._onCannotFindModule();break;default:return Mr({ code: Zn.MESSAGE_SEND_INVALID_CONVERSATION_TYPE, message: lo })
      } const s = this.getModule(Ft); const r = this.getModule(At);return s.upload(e).then((() => {
        o._getSendMessageSpecifiedKey(e) === ha && o.getModule($t).addSuccessCount(_a);return r.guardForAVChatRoom(e).then((() => {
          if (!e.isSendable()) return Mr({ code: Zn.MESSAGE_FILE_URL_IS_EMPTY, message: Co });o._addSendMessageTotalCount(e), n = Date.now();const s = (function (e) {
            let t = 'utf-8';W && document && (t = document.charset.toLowerCase());let n; let o; let a = 0;if (o = e.length, 'utf-8' === t || 'utf8' === t) for (let s = 0;s < o;s++)(n = e.codePointAt(s)) <= 127 ? a += 1 : n <= 2047 ? a += 2 : n <= 65535 ? a += 3 : (a += 4, s++);else if ('utf-16' === t || 'utf16' === t) for (let r = 0;r < o;r++)(n = e.codePointAt(r)) <= 65535 ? a += 2 : (a += 4, r++);else a = e.replace(/[^\x00-\xff]/g, 'aa').length;return a
          }(JSON.stringify(e)));return e.type === k.MSG_MERGER && s > 7e3 ? o._mergerMessageHandler.uploadMergerMessage(e, s).then(((n) => {
            const a = o._mergerMessageHandler.createMergerMessagePack(e, t, n);return o.request(a)
          })) : (o.getModule(Rt).setMessageRandom(e), e.conversationType === k.CONV_C2C || e.conversationType === k.CONV_GROUP ? a.sendMessage(e, t) : void 0)
        }))
          .then(((s) => {
            const r = s.data; const i = r.time; const c = r.sequence;o._addSendMessageSuccessCount(e, n), o._messageOptionsMap.delete(e.ID);const u = o.getModule(Rt);e.status = _t.SUCCESS, e.time = i;let l = !1;if (e.conversationType === k.CONV_GROUP)e.sequence = c, e.generateMessageID(o.getMyUserID());else if (e.conversationType === k.CONV_C2C) {
              const d = u.getLatestMessageSentByMe(e.conversationID);if (d) {
                const g = d.nick; const p = d.avatar;g === e.nick && p === e.avatar || (l = !0)
              }
            } return u.appendToMessageList(e), l && u.modifyMessageSentByMe({ conversationID: e.conversationID, latestNick: e.nick, latestAvatar: e.avatar }), a.isOnlineMessage(e, t) ? e.setOnlineOnlyFlag(!0) : u.onMessageSent({ conversationOptionsList: [{ conversationID: e.conversationID, unreadCount: 0, type: e.conversationType, subType: e.conversationSubType, lastMessage: e }] }), e.getRelayFlag() || 'TIMImageElem' !== e.type || it(e.payload.imageInfoArray), cr({ message: e })
          }))
      }))
        .catch(((t) => o._onSendMessageFailed(e, t)))
    } }, { key: '_onSendMessageFailed', value(e, t) {
      e.status = _t.FAIL, this.getModule(Rt).deleteMessageRandom(e), this._addSendMessageFailCountOnUser(e, t);const n = new Da(ba);return n.setMessage('tjg_id:'.concat(this.generateTjgID(e), ' type:').concat(e.type, ' from:')
        .concat(e.from, ' to:')
        .concat(e.to)), this.probeNetwork().then(((e) => {
        const o = m(e, 2); const a = o[0]; const s = o[1];n.setError(t, a, s).end()
      })), Ee.error(''.concat(this._className, '._onSendMessageFailed error:'), t), Mr(new hr({ code: t && t.code ? t.code : Zn.MESSAGE_SEND_FAIL, message: t && t.message ? t.message : co, data: { message: e } }))
    } }, { key: '_getSendMessageSpecifiedKey', value(e) {
      if ([k.MSG_IMAGE, k.MSG_AUDIO, k.MSG_VIDEO, k.MSG_FILE].includes(e.type)) return ha;if (e.conversationType === k.CONV_C2C) return da;if (e.conversationType === k.CONV_GROUP) {
        const t = this.getModule(At).getLocalGroupProfile(e.to);if (!t) return;const n = t.type;return et(n) ? pa : ga
      }
    } }, { key: '_addSendMessageTotalCount', value(e) {
      const t = this._getSendMessageSpecifiedKey(e);t && this.getModule($t).addTotalCount(t)
    } }, { key: '_addSendMessageSuccessCount', value(e, t) {
      const n = Math.abs(Date.now() - t); const o = this._getSendMessageSpecifiedKey(e);if (o) {
        const a = this.getModule($t);a.addSuccessCount(o), a.addCost(o, n)
      }
    } }, { key: '_addSendMessageFailCountOnUser', value(e, t) {
      let n; let o; const a = t.code; const s = void 0 === a ? -1 : a; const r = this.getModule($t); const i = this._getSendMessageSpecifiedKey(e);i === ha && (n = s, o = !1, _i.includes(n) && (o = !0), o) ? r.addFailedCountOfUserSide(_a) : (function (e) {
        let t = !1;return Object.values(hi).includes(e) && (t = !0), (e >= 120001 && e <= 13e4 || e >= 10100 && e <= 10200) && (t = !0), t
      }(s)) && i && r.addFailedCountOfUserSide(i)
    } }, { key: 'resendMessage', value(e) {
      return e.isResend = !0, e.status = _t.UNSEND, this.sendMessageInstance(e)
    } }, { key: 'revokeMessage', value(e) {
      const t = this; let n = null;if (e.conversationType === k.CONV_C2C) {
        if (!(n = this.getModule(Nt))) return this._onCannotFindModule()
      } else if (e.conversationType === k.CONV_GROUP && !(n = this.getModule(At))) return this._onCannotFindModule();const o = new Da(qa);return o.setMessage('tjg_id:'.concat(this.generateTjgID(e), ' type:').concat(e.type, ' from:')
        .concat(e.from, ' to:')
        .concat(e.to)), n.revokeMessage(e).then(((n) => {
        const a = n.data.recallRetList;if (!dt(a) && 0 !== a[0].retCode) {
          const s = new hr({ code: a[0].retCode, message: pr[a[0].retCode] || ho, data: { message: e } });return o.setCode(s.code).setMoreMessage(s.message)
            .end(), Mr(s)
        } return Ee.info(''.concat(t._className, '.revokeMessage ok. ID:').concat(e.ID)), e.isRevoked = !0, o.end(), t.getModule(Rt).onMessageRevoked([e]), cr({ message: e })
      }))
        .catch(((n) => {
          t.probeNetwork().then(((e) => {
            const t = m(e, 2); const a = t[0]; const s = t[1];o.setError(n, a, s).end()
          }));const a = new hr({ code: n && n.code ? n.code : Zn.MESSAGE_REVOKE_FAIL, message: n && n.message ? n.message : ho, data: { message: e } });return Ee.warn(''.concat(t._className, '.revokeMessage failed. error:'), n), Mr(a)
        }))
    } }, { key: 'deleteMessage', value(e) {
      const t = this; let n = null; const o = e[0]; const a = o.conversationID; let s = ''; let r = []; let i = [];if (o.conversationType === k.CONV_C2C ? (n = this.getModule(Nt), s = a.replace(k.CONV_C2C, ''), e.forEach(((e) => {
        e && e.status === _t.SUCCESS && e.conversationID === a && (e.getOnlineOnlyFlag() || r.push(''.concat(e.sequence, '_').concat(e.random, '_')
          .concat(e.time)), i.push(e))
      }))) : o.conversationType === k.CONV_GROUP && (n = this.getModule(At), s = a.replace(k.CONV_GROUP, ''), e.forEach(((e) => {
        e && e.status === _t.SUCCESS && e.conversationID === a && (e.getOnlineOnlyFlag() || r.push(''.concat(e.sequence)), i.push(e))
      }))), !n) return this._onCannotFindModule();if (0 === r.length) return this._onMessageDeleted(i);r.length > 30 && (r = r.slice(0, 30), i = i.slice(0, 30));const c = new Da(Va);return c.setMessage('to:'.concat(s, ' count:').concat(r.length)), n.deleteMessage({ to: s, keyList: r }).then(((e) => (c.end(), Ee.info(''.concat(t._className, '.deleteMessage ok')), t._onMessageDeleted(i))))
        .catch(((e) => {
          t.probeNetwork().then(((t) => {
            const n = m(t, 2); const o = n[0]; const a = n[1];c.setError(e, o, a).end()
          })), Ee.warn(''.concat(t._className, '.deleteMessage failed. error:'), e);const n = new hr({ code: e && e.code ? e.code : Zn.MESSAGE_DELETE_FAIL, message: e && e.message ? e.message : _o });return Mr(n)
        }))
    } }, { key: '_onMessageDeleted', value(e) {
      return this.getModule(Rt).onMessageDeleted(e), mr({ messageList: e })
    } }, { key: '_generateUUID', value() {
      const e = this.getModule(Gt);return ''.concat(e.getSDKAppID(), '-').concat(e.getUserID(), '-')
        .concat(function () {
          for (var e = '', t = 32;t > 0;--t)e += je[Math.floor(Math.random() * $e)];return e
        }())
    } }, { key: 'getMessageOptionByID', value(e) {
      return this._messageOptionsMap.get(e)
    } }, { key: '_getNickAndAvatarByUserID', value(e) {
      return this.getModule(Ct).getNickAndAvatarByUserID(e)
    } }, { key: 'reset', value() {
      Ee.log(''.concat(this._className, '.reset')), this._messageOptionsMap.clear()
    } }]), n
  }(Yt)); const mi = (function (e) {
    i(n, e);const t = f(n);function n(e) {
      let a;return o(this, n), (a = t.call(this, e))._className = 'PluginModule', a.plugins = {}, a
    } return s(n, [{ key: 'registerPlugin', value(e) {
      const t = this;Object.keys(e).forEach(((n) => {
        t.plugins[n] = e[n]
      })), new Da(Na).setMessage('key='.concat(Object.keys(e)))
        .end()
    } }, { key: 'getPlugin', value(e) {
      return this.plugins[e]
    } }, { key: 'reset', value() {
      Ee.log(''.concat(this._className, '.reset'))
    } }]), n
  }(Yt)); const Mi = (function (e) {
    i(n, e);const t = f(n);function n(e) {
      let a;return o(this, n), (a = t.call(this, e))._className = 'SyncUnreadMessageModule', a._cookie = '', a._onlineSyncFlag = !1, a.getInnerEmitterInstance().on(Ir.CONTEXT_A2KEY_AND_TINYID_UPDATED, a._onLoginSuccess, h(a)), a
    } return s(n, [{ key: '_onLoginSuccess', value(e) {
      this._startSync({ cookie: this._cookie, syncFlag: 0, isOnlineSync: 0 })
    } }, { key: '_startSync', value(e) {
      const t = this; const n = e.cookie; const o = e.syncFlag; const a = e.isOnlineSync;Ee.log(''.concat(this._className, '._startSync cookie:').concat(n, ' syncFlag:')
        .concat(o, ' isOnlineSync:')
        .concat(a)), this.request({ protocolName: Xt, requestData: { cookie: n, syncFlag: o, isOnlineSync: a } }).then(((e) => {
        const n = e.data; const o = n.cookie; const a = n.syncFlag; const s = n.eventArray; const r = n.messageList; const i = n.C2CRemainingUnreadList;if (t._cookie = o, dt(o));else if (0 === a || 1 === a) {
          if (s)t.getModule(Kt).onMessage({ head: {}, body: { eventArray: s, isInstantMessage: t._onlineSyncFlag, isSyncingEnded: !1 } });t.getModule(Nt).onNewC2CMessage({ dataList: r, isInstantMessage: !1, C2CRemainingUnreadList: i }), t._startSync({ cookie: o, syncFlag: a, isOnlineSync: 0 })
        } else if (2 === a) {
          if (s)t.getModule(Kt).onMessage({ head: {}, body: { eventArray: s, isInstantMessage: t._onlineSyncFlag, isSyncingEnded: !0 } });t.getModule(Nt).onNewC2CMessage({ dataList: r, isInstantMessage: t._onlineSyncFlag, C2CRemainingUnreadList: i })
        }
      }))
        .catch(((e) => {
          Ee.error(''.concat(t._className, '._startSync failed. error:'), e)
        }))
    } }, { key: 'startOnlineSync', value() {
      Ee.log(''.concat(this._className, '.startOnlineSync')), this._onlineSyncFlag = !0, this._startSync({ cookie: this._cookie, syncFlag: 0, isOnlineSync: 1 })
    } }, { key: 'reset', value() {
      Ee.log(''.concat(this._className, '.reset')), this._onlineSyncFlag = !1, this._cookie = ''
    } }]), n
  }(Yt)); const vi = { request: { toAccount: 'To_Account', fromAccount: 'From_Account', to: 'To_Account', from: 'From_Account', groupID: 'GroupId', groupAtUserID: 'GroupAt_Account', extension: 'Ext', data: 'Data', description: 'Desc', elements: 'MsgBody', sizeType: 'Type', downloadFlag: 'Download_Flag', thumbUUID: 'ThumbUUID', videoUUID: 'VideoUUID', remoteAudioUrl: 'Url', remoteVideoUrl: 'VideoUrl', videoUrl: '', imageUrl: 'URL', fileUrl: 'Url', uuid: 'UUID', priority: 'MsgPriority', receiverUserID: 'To_Account', receiverGroupID: 'GroupId', messageSender: 'SenderId', messageReceiver: 'ReceiverId', nick: 'From_AccountNick', avatar: 'From_AccountHeadurl', messageNumber: 'MsgNum', pbDownloadKey: 'PbMsgKey', downloadKey: 'JsonMsgKey', applicationType: 'PendencyType', userIDList: 'To_Account', groupNameList: 'GroupName', userID: 'To_Account' }, response: { MsgPriority: 'priority', ThumbUUID: 'thumbUUID', VideoUUID: 'videoUUID', Download_Flag: 'downloadFlag', GroupId: 'groupID', Member_Account: 'userID', MsgList: 'messageList', SyncFlag: 'syncFlag', To_Account: 'to', From_Account: 'from', MsgSeq: 'sequence', MsgRandom: 'random', MsgTime: 'time', MsgTimeStamp: 'time', MsgContent: 'content', MsgBody: 'elements', From_AccountNick: 'nick', From_AccountHeadurl: 'avatar', GroupWithdrawInfoArray: 'revokedInfos', GroupReadInfoArray: 'groupMessageReadNotice', LastReadMsgSeq: 'lastMessageSeq', WithdrawC2cMsgNotify: 'c2cMessageRevokedNotify', C2cWithdrawInfoArray: 'revokedInfos', C2cReadedReceipt: 'c2cMessageReadReceipt', ReadC2cMsgNotify: 'c2cMessageReadNotice', LastReadTime: 'peerReadTime', MsgRand: 'random', MsgType: 'type', MsgShow: 'messageShow', NextMsgSeq: 'nextMessageSeq', FaceUrl: 'avatar', ProfileDataMod: 'profileModify', Profile_Account: 'userID', ValueBytes: 'value', ValueNum: 'value', NoticeSeq: 'noticeSequence', NotifySeq: 'notifySequence', MsgFrom_AccountExtraInfo: 'messageFromAccountExtraInformation', Operator_Account: 'operatorID', OpType: 'operationType', ReportType: 'operationType', UserId: 'userID', User_Account: 'userID', List_Account: 'userIDList', MsgOperatorMemberExtraInfo: 'operatorInfo', MsgMemberExtraInfo: 'memberInfoList', ImageUrl: 'avatar', NickName: 'nick', MsgGroupNewInfo: 'newGroupProfile', MsgAppDefinedData: 'groupCustomField', Owner_Account: 'ownerID', GroupFaceUrl: 'avatar', GroupIntroduction: 'introduction', GroupNotification: 'notification', GroupApplyJoinOption: 'joinOption', MsgKey: 'messageKey', GroupInfo: 'groupProfile', ShutupTime: 'muteTime', Desc: 'description', Ext: 'extension', GroupAt_Account: 'groupAtUserID', MsgNum: 'messageNumber', PbMsgKey: 'pbDownloadKey', JsonMsgKey: 'downloadKey', MsgModifiedFlag: 'isModified', PendencyItem: 'applicationItem', PendencyType: 'applicationType', AddTime: 'time', AddSource: 'source', AddWording: 'wording', ProfileImImage: 'avatar', PendencyAdd: 'friendApplicationAdded', FrienPencydDel_Account: 'friendApplicationDeletedUserIDList' }, ignoreKeyWord: ['C2C', 'ID', 'USP'] };function yi(e, t) {
    if ('string' !== typeof e && !Array.isArray(e)) throw new TypeError('Expected the input to be `string | string[]`');t = Object.assign({ pascalCase: !1 }, t);let n;return 0 === (e = Array.isArray(e) ? e.map(((e) => e.trim())).filter(((e) => e.length))
      .join('-') : e.trim()).length ? '' : 1 === e.length ? t.pascalCase ? e.toUpperCase() : e.toLowerCase() : (e !== e.toLowerCase() && (e = Ii(e)), e = e.replace(/^[_.\- ]+/, '').toLowerCase()
        .replace(/[_.\- ]+(\w|$)/g, ((e, t) => t.toUpperCase()))
        .replace(/\d+(\w|$)/g, ((e) => e.toUpperCase())), n = e, t.pascalCase ? n.charAt(0).toUpperCase() + n.slice(1) : n)
  } var Ii = function (e) {
    for (let t = !1, n = !1, o = !1, a = 0;a < e.length;a++) {
      const s = e[a];t && /[a-zA-Z]/.test(s) && s.toUpperCase() === s ? (e = `${e.slice(0, a)}-${e.slice(a)}`, t = !1, o = n, n = !0, a++) : n && o && /[a-zA-Z]/.test(s) && s.toLowerCase() === s ? (e = `${e.slice(0, a - 1)}-${e.slice(a - 1)}`, o = n, n = !1, t = !0) : (t = s.toLowerCase() === s && s.toUpperCase() !== s, o = n, n = s.toUpperCase() === s && s.toLowerCase() !== s)
    } return e
  };function Di(e, t) {
    let n = 0;return (function e(t, o) {
      if (++n > 100) return n--, t;if (Re(t)) {
        const a = t.map(((t) => (Oe(t) ? e(t, o) : t)));return n--, a
      } if (Oe(t)) {
        let s = (r = t, i = function (e, t) {
          if (!Fe(t)) return !1;if ((a = t) !== yi(a)) for (let n = 0;n < vi.ignoreKeyWord.length && !t.includes(vi.ignoreKeyWord[n]);n++);let a;return Ge(o[t]) ? (function (e) {
            return 'OPPOChannelID' === e ? e : e[0].toUpperCase() + yi(e).slice(1)
          }(t)) : o[t]
        }, c = Object.create(null), Object.keys(r).forEach(((e) => {
          const t = i(r[e], e);t && (c[t] = r[e])
        })), c);return s = ot(s, ((t, n) => (Re(t) || Oe(t) ? e(t, o) : t))), n--, s
      } let r; let i; let c
    }(e, t))
  } function Ti(e, t) {
    if (Re(e)) return e.map(((e) => (Oe(e) ? Ti(e, t) : e)));if (Oe(e)) {
      let n = (o = e, a = function (e, n) {
        return Ge(t[n]) ? yi(n) : t[n]
      }, s = {}, Object.keys(o).forEach(((e) => {
        s[a(o[e], e)] = o[e]
      })), s);return n = ot(n, ((e) => (Re(e) || Oe(e) ? Ti(e, t) : e)))
    } let o; let a; let s
  } const Si = (function () {
    function e(t) {
      o(this, e), this._handler = t;const n = t.getURL();this._socket = null, this._id = He(), z ? $ ? (J.connectSocket({ url: n, header: { 'content-type': 'application/json' } }), J.onSocketClose(this._onClose.bind(this)), J.onSocketOpen(this._onOpen.bind(this)), J.onSocketMessage(this._onMessage.bind(this)), J.onSocketError(this._onError.bind(this))) : (this._socket = J.connectSocket({ url: n, header: { 'content-type': 'application/json' }, complete() {} }), this._socket.onClose(this._onClose.bind(this)), this._socket.onOpen(this._onOpen.bind(this)), this._socket.onMessage(this._onMessage.bind(this)), this._socket.onError(this._onError.bind(this))) : W && (this._socket = new WebSocket(n), this._socket.onopen = this._onOpen.bind(this), this._socket.onmessage = this._onMessage.bind(this), this._socket.onclose = this._onClose.bind(this), this._socket.onerror = this._onError.bind(this))
    } return s(e, [{ key: 'getID', value() {
      return this._id
    } }, { key: '_onOpen', value() {
      this._handler.onOpen({ id: this._id })
    } }, { key: '_onClose', value(e) {
      this._handler.onClose({ id: this._id, e })
    } }, { key: '_onMessage', value(e) {
      this._handler.onMessage(e)
    } }, { key: '_onError', value(e) {
      this._handler.onError({ id: this._id, e })
    } }, { key: 'close', value(e) {
      if ($) return J.offSocketClose(), J.offSocketMessage(), J.offSocketOpen(), J.offSocketError(), void J.closeSocket();this._socket && (z ? (this._socket.onClose((() => {})), this._socket.onOpen((() => {})), this._socket.onMessage((() => {})), this._socket.onError((() => {}))) : W && (this._socket.onopen = null, this._socket.onmessage = null, this._socket.onclose = null, this._socket.onerror = null), j ? this._socket.close({ code: e }) : this._socket.close(e), this._socket = null)
    } }, { key: 'send', value(e) {
      $ ? J.sendSocketMessage({ data: e.data, fail() {
        e.fail && e.requestID && e.fail(e.requestID)
      } }) : this._socket && (z ? this._socket.send({ data: e.data, fail() {
        e.fail && e.requestID && e.fail(e.requestID)
      } }) : W && this._socket.send(e.data))
    } }]), e
  }()); const Ei = 4e3; const ki = 4001; const Ci = ['keyMap']; const Ni = ['keyMap']; const Ai = 'connected'; const Oi = 'connecting'; const Li = 'disconnected'; const Ri = (function () {
    function e(t) {
      o(this, e), this._channelModule = t, this._className = 'SocketHandler', this._promiseMap = new Map, this._readyState = Li, this._simpleRequestMap = new Map, this.MAX_SIZE = 100, this._startSequence = He(), this._startTs = 0, this._reConnectFlag = !1, this._nextPingTs = 0, this._reConnectCount = 0, this.MAX_RECONNECT_COUNT = 3, this._socketID = -1, this._random = 0, this._socket = null, this._url = '', this._onOpenTs = 0, this._setOverseaHost(), this._initConnection()
    } return s(e, [{ key: '_setOverseaHost', value() {
      this._channelModule.isOversea() && U.HOST.setCurrent(b)
    } }, { key: '_initConnection', value() {
      '' === this._url ? this._url = U.HOST.CURRENT.DEFAULT : this._url === U.HOST.CURRENT.DEFAULT ? this._url = U.HOST.CURRENT.BACKUP : this._url === U.HOST.CURRENT.BACKUP && (this._url = U.HOST.CURRENT.DEFAULT), this._connect(), this._nextPingTs = 0
    } }, { key: 'onCheckTimer', value(e) {
      e % 1 == 0 && this._checkPromiseMap()
    } }, { key: '_checkPromiseMap', value() {
      const e = this;0 !== this._promiseMap.size && this._promiseMap.forEach(((t, n) => {
        const o = t.reject; const a = t.timestamp;Date.now() - a >= 15e3 && (Ee.log(''.concat(e._className, '._checkPromiseMap request timeout, delete requestID:').concat(n)), e._promiseMap.delete(n), o(new hr({ code: Zn.NETWORK_TIMEOUT, message: na })), e._channelModule.onRequestTimeout(n))
      }))
    } }, { key: 'onOpen', value(e) {
      this._onOpenTs = Date.now();const t = e.id;this._socketID = t, new Da(Oa).setMessage(n)
        .setMessage('socketID:'.concat(t))
        .end();var n = Date.now() - this._startTs;Ee.log(''.concat(this._className, '._onOpen cost ').concat(n, ' ms. socketID:')
        .concat(t)), e.id === this._socketID && (this._readyState = Ai, this._reConnectCount = 0, this._resend(), !0 === this._reConnectFlag && (this._channelModule.onReconnected(), this._reConnectFlag = !1), this._channelModule.onOpen())
    } }, { key: 'onClose', value(e) {
      const t = new Da(La); const n = e.id; const o = e.e; const a = 'sourceSocketID:'.concat(n, ' currentSocketID:').concat(this._socketID); let s = 0;0 !== this._onOpenTs && (s = Date.now() - this._onOpenTs), t.setMessage(s).setMoreMessage(a)
        .setCode(o.code)
        .end(), Ee.log(''.concat(this._className, '._onClose code:').concat(o.code, ' reason:')
        .concat(o.reason, ' ')
        .concat(a)), n === this._socketID && (this._readyState = Li, s < 1e3 ? this._channelModule.onReconnectFailed() : this._channelModule.onClose())
    } }, { key: 'onError', value(e) {
      const t = e.id; const n = e.e; const o = 'sourceSocketID:'.concat(t, ' currentSocketID:').concat(this._socketID);new Da(Ra).setMessage(n.errMsg || xe(n))
        .setMoreMessage(o)
        .setLevel('error')
        .end(), Ee.warn(''.concat(this._className, '._onError'), n, o), t === this._socketID && (this._readyState = '', this._channelModule.onError())
    } }, { key: 'onMessage', value(e) {
      let t;try {
        t = JSON.parse(e.data)
      } catch (u) {
        new Da(Ya).setMessage(e.data)
          .end()
      } if (t && t.head) {
        const n = this._getRequestIDFromHead(t.head); const o = ct(t.head); const a = Ti(t.body, this._getResponseKeyMap(o));if (Ee.debug(''.concat(this._className, '.onMessage ret:').concat(JSON.stringify(a), ' requestID:')
          .concat(n, ' has:')
          .concat(this._promiseMap.has(n))), this._setNextPingTs(), this._promiseMap.has(n)) {
          const s = this._promiseMap.get(n); const r = s.resolve; const i = s.reject; const c = s.timestamp;return this._promiseMap.delete(n), this._calcRTT(c), void(a.errorCode && 0 !== a.errorCode ? (this._channelModule.onErrorCodeNotZero(a), i(new hr({ code: a.errorCode, message: a.errorInfo || '' }))) : r(cr(a)))
        } this._channelModule.onMessage({ head: t.head, body: a })
      }
    } }, { key: '_calcRTT', value(e) {
      const t = Date.now() - e;this._channelModule.getModule($t).addRTT(t)
    } }, { key: '_connect', value() {
      new Da(Aa).setMessage('url:'.concat(this.getURL()))
        .end(), this._startTs = Date.now(), this._socket = new Si(this), this._socketID = this._socket.getID(), this._readyState = Oi
    } }, { key: 'getURL', value() {
      const e = this._channelModule.getModule(Gt);return ''.concat(this._url, '/info?sdkappid=').concat(e.getSDKAppID(), '&instanceid=')
        .concat(e.getInstanceID(), '&random=')
        .concat(this._getRandom())
    } }, { key: '_closeConnection', value(e) {
      this._socket && (this._socket.close(e), this._socketID = -1, this._socket = null, this._readyState = Li)
    } }, { key: '_resend', value() {
      const e = this;if (Ee.log(''.concat(this._className, '._resend reConnectFlag:').concat(this._reConnectFlag), 'promiseMap.size:'.concat(this._promiseMap.size, ' simpleRequestMap.size:').concat(this._simpleRequestMap.size)), this._promiseMap.size > 0 && this._promiseMap.forEach(((t, n) => {
        const o = t.uplinkData; const a = t.resolve; const s = t.reject;e._promiseMap.set(n, { resolve: a, reject: s, timestamp: Date.now(), uplinkData: o }), e._execute(n, o)
      })), this._simpleRequestMap.size > 0) {
        let t; const n = S(this._simpleRequestMap);try {
          for (n.s();!(t = n.n()).done;) {
            const o = m(t.value, 2); const a = o[0]; const s = o[1];this._execute(a, s)
          }
        } catch (r) {
          n.e(r)
        } finally {
          n.f()
        } this._simpleRequestMap.clear()
      }
    } }, { key: 'send', value(e) {
      const t = this;e.head.seq = this._getSequence(), e.head.reqtime = Math.floor(Date.now() / 1e3);e.keyMap;const n = p(e, Ci); const o = this._getRequestIDFromHead(e.head); const a = JSON.stringify(n);return new Promise(((e, s) => {
        (t._promiseMap.set(o, { resolve: e, reject: s, timestamp: Date.now(), uplinkData: a }), Ee.debug(''.concat(t._className, '.send uplinkData:').concat(JSON.stringify(n), ' requestID:')
          .concat(o, ' readyState:')
          .concat(t._readyState)), t._readyState !== Ai) ? t._reConnect() : (t._execute(o, a), t._channelModule.getModule($t).addRequestCount())
      }))
    } }, { key: 'simplySend', value(e) {
      e.head.seq = this._getSequence(), e.head.reqtime = Math.floor(Date.now() / 1e3);e.keyMap;const t = p(e, Ni); const n = this._getRequestIDFromHead(e.head); const o = JSON.stringify(t);this._readyState !== Ai ? (this._simpleRequestMap.size < this.MAX_SIZE ? this._simpleRequestMap.set(n, o) : Ee.log(''.concat(this._className, '.simplySend. simpleRequestMap is full, drop request!')), this._reConnect()) : this._execute(n, o)
    } }, { key: '_execute', value(e, t) {
      this._socket.send({ data: t, fail: z ? this._onSendFail.bind(this) : void 0, requestID: e })
    } }, { key: '_onSendFail', value(e) {
      Ee.log(''.concat(this._className, '._onSendFail requestID:').concat(e))
    } }, { key: '_getSequence', value() {
      let e;if (this._startSequence < 2415919103) return e = this._startSequence, this._startSequence += 1, 2415919103 === this._startSequence && (this._startSequence = He()), e
    } }, { key: '_getRequestIDFromHead', value(e) {
      return e.servcmd + e.seq
    } }, { key: '_getResponseKeyMap', value(e) {
      const n = this._channelModule.getKeyMap(e);return t(t({}, vi.response), n.response)
    } }, { key: '_reConnect', value() {
      this._readyState !== Ai && this._readyState !== Oi && this.forcedReconnect()
    } }, { key: 'forcedReconnect', value() {
      const e = this;Ee.log(''.concat(this._className, '.forcedReconnect count:').concat(this._reConnectCount, ' readyState:')
        .concat(this._readyState)), this._reConnectFlag = !0, this._resetRandom(), this._reConnectCount < this.MAX_RECONNECT_COUNT ? (this._reConnectCount += 1, this._closeConnection(ki), this._initConnection()) : this._channelModule.probeNetwork().then(((t) => {
        const n = m(t, 2); const o = n[0];n[1];o ? (Ee.warn(''.concat(e._className, '.forcedReconnect disconnected from wsserver but network is ok, continue...')), e._reConnectCount = 0, e._closeConnection(ki), e._initConnection()) : e._channelModule.onReconnectFailed()
      }))
    } }, { key: 'getReconnectFlag', value() {
      return this._reConnectFlag
    } }, { key: '_setNextPingTs', value() {
      this._nextPingTs = Date.now() + 1e4
    } }, { key: 'getNextPingTs', value() {
      return this._nextPingTs
    } }, { key: 'isConnected', value() {
      return this._readyState === Ai
    } }, { key: '_getRandom', value() {
      return 0 === this._random && (this._random = Math.random()), this._random
    } }, { key: '_resetRandom', value() {
      this._random = 0
    } }, { key: 'close', value() {
      Ee.log(''.concat(this._className, '.close')), this._closeConnection(Ei), this._promiseMap.clear(), this._startSequence = He(), this._readyState = Li, this._simpleRequestMap.clear(), this._reConnectFlag = !1, this._reConnectCount = 0, this._onOpenTs = 0, this._url = '', this._random = 0
    } }]), e
  }()); const Gi = (function (e) {
    i(n, e);const t = f(n);function n(e) {
      let a;if (o(this, n), (a = t.call(this, e))._className = 'ChannelModule', a._socketHandler = new Ri(h(a)), a._probing = !1, a._isAppShowing = !0, a._previousState = k.NET_STATE_CONNECTED, z && 'function' === typeof J.onAppShow && 'function' === typeof J.onAppHide) {
        const s = a._onAppHide.bind(h(a)); const r = a._onAppShow.bind(h(a));'function' === typeof J.offAppHide && J.offAppHide(s), 'function' === typeof J.offAppShow && J.offAppShow(r), J.onAppHide(s), J.onAppShow(r)
      } return a._timerForNotLoggedIn = -1, a._timerForNotLoggedIn = setInterval(a.onCheckTimer.bind(h(a)), 1e3), a._fatalErrorFlag = !1, a
    } return s(n, [{ key: 'onCheckTimer', value(e) {
      this._socketHandler && (this.isLoggedIn() ? (this._timerForNotLoggedIn > 0 && (clearInterval(this._timerForNotLoggedIn), this._timerForNotLoggedIn = -1), this._socketHandler.onCheckTimer(e)) : this._socketHandler.onCheckTimer(1), this._checkNextPing())
    } }, { key: 'onErrorCodeNotZero', value(e) {
      this.getModule(Kt).onErrorCodeNotZero(e)
    } }, { key: 'onMessage', value(e) {
      this.getModule(Kt).onMessage(e)
    } }, { key: 'send', value(e) {
      return this._previousState !== k.NET_STATE_CONNECTED && e.head.servcmd.includes(Hn) ? this._sendLogViaHTTP(e) : this._socketHandler.send(e)
    } }, { key: '_sendLogViaHTTP', value(e) {
      return new Promise(((t, n) => {
        const o = 'https://webim.tim.qq.com/v4/imopenstat/tim_web_report_v2?sdkappid='.concat(e.head.sdkappid, '&reqtime=').concat(Date.now()); const a = JSON.stringify(e.body); const s = 'application/x-www-form-urlencoded;charset=UTF-8';if (z)J.request({ url: o, data: a, method: 'POST', timeout: 3e3, header: { 'content-type': s }, success() {
          t()
        }, fail() {
          n(new hr({ code: Zn.NETWORK_ERROR, message: ta }))
        } });else {
          const r = new XMLHttpRequest; const i = setTimeout((() => {
            r.abort(), n(new hr({ code: Zn.NETWORK_TIMEOUT, message: na }))
          }), 3e3);r.onreadystatechange = function () {
            4 === r.readyState && (clearTimeout(i), 200 === r.status || 304 === r.status ? t() : n(new hr({ code: Zn.NETWORK_ERROR, message: ta })))
          }, r.open('POST', o, !0), r.setRequestHeader('Content-type', s), r.send(a)
        }
      }))
    } }, { key: 'simplySend', value(e) {
      return this._socketHandler.simplySend(e)
    } }, { key: 'onOpen', value() {
      this._ping()
    } }, { key: 'onClose', value() {
      this.reConnect()
    } }, { key: 'onError', value() {
      Ee.error(''.concat(this._className, '.onError 从v2.11.2起，SDK 支持了 WebSocket，如您未添加相关受信域名，请先添加！升级指引: https://web.sdk.qcloud.com/im/doc/zh-cn/tutorial-02-upgradeguideline.html'))
    } }, { key: 'getKeyMap', value(e) {
      return this.getModule(Kt).getKeyMap(e)
    } }, { key: '_onAppHide', value() {
      this._isAppShowing = !1
    } }, { key: '_onAppShow', value() {
      this._isAppShowing = !0
    } }, { key: 'onRequestTimeout', value(e) {} }, { key: 'onReconnected', value() {
      Ee.log(''.concat(this._className, '.onReconnected')), this.getModule(Kt).onReconnected(), this._emitNetStateChangeEvent(k.NET_STATE_CONNECTED)
    } }, { key: 'onReconnectFailed', value() {
      Ee.log(''.concat(this._className, '.onReconnectFailed')), this._emitNetStateChangeEvent(k.NET_STATE_DISCONNECTED)
    } }, { key: 'reConnect', value() {
      if (!this._fatalErrorFlag && this._socketHandler) {
        const e = this._socketHandler.getReconnectFlag();if (Ee.log(''.concat(this._className, '.reConnect state:').concat(this._previousState, ' reconnectFlag:')
          .concat(e)), this._previousState === k.NET_STATE_CONNECTING && e) return;this._socketHandler.forcedReconnect(), this._emitNetStateChangeEvent(k.NET_STATE_CONNECTING)
      }
    } }, { key: '_emitNetStateChangeEvent', value(e) {
      this._previousState !== e && (this._previousState = e, this.emitOuterEvent(E.NET_STATE_CHANGE, { state: e }))
    } }, { key: '_ping', value() {
      const e = this;if (!0 !== this._probing) {
        this._probing = !0;const t = this.getModule(Kt).getProtocolData({ protocolName: jn });this.send(t).then((() => {
          e._probing = !1
        }))
          .catch(((t) => {
            if (Ee.warn(''.concat(e._className, '._ping failed. error:'), t), e._probing = !1, t && 60002 === t.code) return new Da(Fs).setMessage('code:'.concat(t.code, ' message:').concat(t.message))
              .setNetworkType(e.getModule(bt).getNetworkType())
              .end(), e._fatalErrorFlag = !0, void e.emitOuterEvent(E.NET_STATE_CHANGE, k.NET_STATE_DISCONNECTED);e.probeNetwork().then(((t) => {
              const n = m(t, 2); const o = n[0]; const a = n[1];Ee.log(''.concat(e._className, '._ping failed. isAppShowing:').concat(e._isAppShowing, ' online:')
                .concat(o, ' networkType:')
                .concat(a)), o ? e.reConnect() : e.emitOuterEvent(E.NET_STATE_CHANGE, k.NET_STATE_DISCONNECTED)
            }))
          }))
      }
    } }, { key: '_checkNextPing', value() {
      this._socketHandler.isConnected() && (Date.now() >= this._socketHandler.getNextPingTs() && this._ping())
    } }, { key: 'dealloc', value() {
      this._socketHandler && (this._socketHandler.close(), this._socketHandler = null), this._timerForNotLoggedIn > -1 && clearInterval(this._timerForNotLoggedIn)
    } }, { key: 'reset', value() {
      Ee.log(''.concat(this._className, '.reset')), this._previousState = k.NET_STATE_CONNECTED, this._probing = !1, this._fatalErrorFlag = !1, this._timerForNotLoggedIn = setInterval(this.onCheckTimer.bind(this), 1e3)
    } }]), n
  }(Yt)); const wi = ['a2', 'tinyid']; const Pi = ['a2', 'tinyid']; const bi = (function () {
    function e(t) {
      o(this, e), this._className = 'ProtocolHandler', this._sessionModule = t, this._configMap = new Map, this._fillConfigMap()
    } return s(e, [{ key: '_fillConfigMap', value() {
      this._configMap.clear();const e = this._sessionModule.genCommonHead(); const n = this._sessionModule.genCosSpecifiedHead(); const o = this._sessionModule.genSSOReportHead();this._configMap.set(zt, (function (e) {
        return { head: t(t({}, e), {}, { servcmd: ''.concat(U.NAME.IM_OPEN_STATUS, '.').concat(U.CMD.LOGIN) }), body: { state: 'Online' }, keyMap: { response: { TinyId: 'tinyID', InstId: 'instanceID', HelloInterval: 'helloInterval' } } }
      }(e))), this._configMap.set(Wt, (function (e) {
        return { head: t(t({}, e), {}, { servcmd: ''.concat(U.NAME.IM_OPEN_STATUS, '.').concat(U.CMD.LOGOUT) }), body: {} }
      }(e))), this._configMap.set(Jt, (function (e) {
        return { head: t(t({}, e), {}, { servcmd: ''.concat(U.NAME.IM_OPEN_STATUS, '.').concat(U.CMD.HELLO) }), body: {}, keyMap: { response: { NewInstInfo: 'newInstanceInfo' } } }
      }(e))), this._configMap.set(xn, (function (e) {
        return { head: t(t({}, e), {}, { servcmd: ''.concat(U.NAME.IM_COS_SIGN, '.').concat(U.CMD.COS_SIGN) }), body: { cmd: 'open_im_cos_svc', subCmd: 'get_cos_token', duration: 300, version: 2 }, keyMap: { request: { userSig: 'usersig', subCmd: 'sub_cmd', cmd: 'cmd', duration: 'duration', version: 'version' }, response: { expired_time: 'expiredTime', bucket_name: 'bucketName', session_token: 'sessionToken', tmp_secret_id: 'secretId', tmp_secret_key: 'secretKey' } } }
      }(n))), this._configMap.set(Bn, (function (e) {
        return { head: t(t({}, e), {}, { servcmd: ''.concat(U.NAME.CUSTOM_UPLOAD, '.').concat(U.CMD.COS_PRE_SIG) }), body: { fileType: void 0, fileName: void 0, uploadMethod: 0, duration: 900 }, keyMap: { request: { userSig: 'usersig', fileType: 'file_type', fileName: 'file_name', uploadMethod: 'upload_method' }, response: { expired_time: 'expiredTime', request_id: 'requestId', head_url: 'headUrl', upload_url: 'uploadUrl', download_url: 'downloadUrl', ci_url: 'ciUrl' } } }
      }(n))), this._configMap.set(Xn, (function (e) {
        return { head: t(t({}, e), {}, { servcmd: ''.concat(U.NAME.CLOUD_CONTROL, '.').concat(U.CMD.FETCH_CLOUD_CONTROL_CONFIG) }), body: { SDKAppID: 0, version: 0 }, keyMap: { request: { SDKAppID: 'uint32_sdkappid', version: 'uint64_version' }, response: { int32_error_code: 'errorCode', str_error_message: 'errorMessage', str_json_config: 'cloudControlConfig', uint32_expired_time: 'expiredTime', uint32_sdkappid: 'SDKAppID', uint64_version: 'version' } } }
      }(e))), this._configMap.set(Qn, (function (e) {
        return { head: t(t({}, e), {}, { servcmd: ''.concat(U.NAME.CLOUD_CONTROL, '.').concat(U.CMD.PUSHED_CLOUD_CONTROL_CONFIG) }), body: {}, keyMap: { response: { int32_error_code: 'errorCode', str_error_message: 'errorMessage', str_json_config: 'cloudControlConfig', uint32_expired_time: 'expiredTime', uint32_sdkappid: 'SDKAppID', uint64_version: 'version' } } }
      }(e))), this._configMap.set(Xt, (function (e) {
        return { head: t(t({}, e), {}, { servcmd: ''.concat(U.NAME.OPEN_IM, '.').concat(U.CMD.GET_MESSAGES) }), body: { cookie: '', syncFlag: 0, needAbstract: 1, isOnlineSync: 0 }, keyMap: { request: { fromAccount: 'From_Account', toAccount: 'To_Account', from: 'From_Account', to: 'To_Account', time: 'MsgTimeStamp', sequence: 'MsgSeq', random: 'MsgRandom', elements: 'MsgBody' }, response: { MsgList: 'messageList', SyncFlag: 'syncFlag', To_Account: 'to', From_Account: 'from', ClientSeq: 'clientSequence', MsgSeq: 'sequence', NoticeSeq: 'noticeSequence', NotifySeq: 'notifySequence', MsgRandom: 'random', MsgTimeStamp: 'time', MsgContent: 'content', ToGroupId: 'groupID', MsgKey: 'messageKey', GroupTips: 'groupTips', MsgBody: 'elements', MsgType: 'type', C2CRemainingUnreadCount: 'C2CRemainingUnreadList', C2CPairUnreadCount: 'C2CPairUnreadList' } } }
      }(e))), this._configMap.set(Qt, (function (e) {
        return { head: t(t({}, e), {}, { servcmd: ''.concat(U.NAME.OPEN_IM, '.').concat(U.CMD.BIG_DATA_HALLWAY_AUTH_KEY) }), body: {} }
      }(e))), this._configMap.set(Zt, (function (e) {
        return { head: t(t({}, e), {}, { servcmd: ''.concat(U.NAME.OPEN_IM, '.').concat(U.CMD.SEND_MESSAGE) }), body: { fromAccount: '', toAccount: '', msgTimeStamp: void 0, msgSeq: 0, msgRandom: 0, msgBody: [], cloudCustomData: void 0, nick: '', avatar: '', msgLifeTime: void 0, offlinePushInfo: { pushFlag: 0, title: '', desc: '', ext: '', apnsInfo: { badgeMode: 0 }, androidInfo: { OPPOChannelID: '' } } }, keyMap: { request: { fromAccount: 'From_Account', toAccount: 'To_Account', msgTimeStamp: 'MsgTimeStamp', msgSeq: 'MsgSeq', msgRandom: 'MsgRandom', msgBody: 'MsgBody', count: 'MaxCnt', lastMessageTime: 'LastMsgTime', messageKey: 'MsgKey', peerAccount: 'Peer_Account', data: 'Data', description: 'Desc', extension: 'Ext', type: 'MsgType', content: 'MsgContent', sizeType: 'Type', uuid: 'UUID', url: '', imageUrl: 'URL', fileUrl: 'Url', remoteAudioUrl: 'Url', remoteVideoUrl: 'VideoUrl', thumbUUID: 'ThumbUUID', videoUUID: 'VideoUUID', videoUrl: '', downloadFlag: 'Download_Flag', nick: 'From_AccountNick', avatar: 'From_AccountHeadurl', from: 'From_Account', time: 'MsgTimeStamp', messageRandom: 'MsgRandom', messageSequence: 'MsgSeq', elements: 'MsgBody', clientSequence: 'ClientSeq', payload: 'MsgContent', messageList: 'MsgList', messageNumber: 'MsgNum', abstractList: 'AbstractList', messageBody: 'MsgBody' } } }
      }(e))), this._configMap.set(en, (function (e) {
        return { head: t(t({}, e), {}, { servcmd: ''.concat(U.NAME.GROUP, '.').concat(U.CMD.SEND_GROUP_MESSAGE) }), body: { fromAccount: '', groupID: '', random: 0, clientSequence: 0, priority: '', msgBody: [], cloudCustomData: void 0, onlineOnlyFlag: 0, offlinePushInfo: { pushFlag: 0, title: '', desc: '', ext: '', apnsInfo: { badgeMode: 0 }, androidInfo: { OPPOChannelID: '' } }, groupAtInfo: [] }, keyMap: { request: { to: 'GroupId', extension: 'Ext', data: 'Data', description: 'Desc', random: 'Random', sequence: 'ReqMsgSeq', count: 'ReqMsgNumber', type: 'MsgType', priority: 'MsgPriority', content: 'MsgContent', elements: 'MsgBody', sizeType: 'Type', uuid: 'UUID', url: '', imageUrl: 'URL', fileUrl: 'Url', remoteAudioUrl: 'Url', remoteVideoUrl: 'VideoUrl', thumbUUID: 'ThumbUUID', videoUUID: 'VideoUUID', videoUrl: '', downloadFlag: 'Download_Flag', clientSequence: 'ClientSeq', from: 'From_Account', time: 'MsgTimeStamp', messageRandom: 'MsgRandom', messageSequence: 'MsgSeq', payload: 'MsgContent', messageList: 'MsgList', messageNumber: 'MsgNum', abstractList: 'AbstractList', messageBody: 'MsgBody' }, response: { MsgTime: 'time', MsgSeq: 'sequence' } } }
      }(e))), this._configMap.set(rn, (function (e) {
        return { head: t(t({}, e), {}, { servcmd: ''.concat(U.NAME.OPEN_IM, '.').concat(U.CMD.REVOKE_C2C_MESSAGE) }), body: { msgInfo: { fromAccount: '', toAccount: '', msgTimeStamp: 0, msgSeq: 0, msgRandom: 0 } }, keyMap: { request: { msgInfo: 'MsgInfo', msgTimeStamp: 'MsgTimeStamp', msgSeq: 'MsgSeq', msgRandom: 'MsgRandom' } } }
      }(e))), this._configMap.set(Nn, (function (e) {
        return { head: t(t({}, e), {}, { servcmd: ''.concat(U.NAME.GROUP, '.').concat(U.CMD.REVOKE_GROUP_MESSAGE) }), body: { to: '', msgSeqList: void 0 }, keyMap: { request: { to: 'GroupId', msgSeqList: 'MsgSeqList', msgSeq: 'MsgSeq' } } }
      }(e))), this._configMap.set(un, (function (e) {
        return { head: t(t({}, e), {}, { servcmd: ''.concat(U.NAME.OPEN_IM, '.').concat(U.CMD.GET_C2C_ROAM_MESSAGES) }), body: { peerAccount: '', count: 15, lastMessageTime: 0, messageKey: '', withRecalledMessage: 1 }, keyMap: { request: { messageKey: 'MsgKey', peerAccount: 'Peer_Account', count: 'MaxCnt', lastMessageTime: 'LastMsgTime', withRecalledMessage: 'WithRecalledMsg' } } }
      }(e))), this._configMap.set(On, (function (e) {
        return { head: t(t({}, e), {}, { servcmd: ''.concat(U.NAME.GROUP, '.').concat(U.CMD.GET_GROUP_ROAM_MESSAGES) }), body: { withRecalledMsg: 1, groupID: '', count: 15, sequence: '' }, keyMap: { request: { sequence: 'ReqMsgSeq', count: 'ReqMsgNumber', withRecalledMessage: 'WithRecalledMsg' }, response: { Random: 'random', MsgTime: 'time', MsgSeq: 'sequence', ReqMsgSeq: 'sequence', RspMsgList: 'messageList', IsPlaceMsg: 'isPlaceMessage', IsSystemMsg: 'isSystemMessage', ToGroupId: 'to', EnumFrom_AccountType: 'fromAccountType', EnumTo_AccountType: 'toAccountType', GroupCode: 'groupCode', MsgPriority: 'priority', MsgBody: 'elements', MsgType: 'type', MsgContent: 'content', IsFinished: 'complete', Download_Flag: 'downloadFlag', ClientSeq: 'clientSequence', ThumbUUID: 'thumbUUID', VideoUUID: 'videoUUID' } } }
      }(e))), this._configMap.set(cn, (function (e) {
        return { head: t(t({}, e), {}, { servcmd: ''.concat(U.NAME.OPEN_IM, '.').concat(U.CMD.SET_C2C_MESSAGE_READ) }), body: { C2CMsgReaded: void 0 }, keyMap: { request: { lastMessageTime: 'LastedMsgTime' } } }
      }(e))), this._configMap.set(An, (function (e) {
        return { head: t(t({}, e), {}, { servcmd: ''.concat(U.NAME.GROUP, '.').concat(U.CMD.SET_GROUP_MESSAGE_READ) }), body: { groupID: void 0, messageReadSeq: void 0 }, keyMap: { request: { messageReadSeq: 'MsgReadedSeq' } } }
      }(e))), this._configMap.set(dn, (function (e) {
        return { head: t(t({}, e), {}, { servcmd: ''.concat(U.NAME.OPEN_IM, '.').concat(U.CMD.DELETE_C2C_MESSAGE) }), body: { fromAccount: '', to: '', keyList: void 0 }, keyMap: { request: { keyList: 'MsgKeyList' } } }
      }(e))), this._configMap.set(bn, (function (e) {
        return { head: t(t({}, e), {}, { servcmd: ''.concat(U.NAME.GROUP, '.').concat(U.CMD.DELETE_GROUP_MESSAGE) }), body: { groupID: '', deleter: '', keyList: void 0 }, keyMap: { request: { deleter: 'Deleter_Account', keyList: 'Seqs' } } }
      }(e))), this._configMap.set(ln, (function (e) {
        return { head: t(t({}, e), {}, { servcmd: ''.concat(U.NAME.OPEN_IM, '.').concat(U.CMD.GET_PEER_READ_TIME) }), body: { userIDList: void 0 }, keyMap: { request: { userIDList: 'To_Account' }, response: { ReadTime: 'peerReadTimeList' } } }
      }(e))), this._configMap.set(pn, (function (e) {
        return { head: t(t({}, e), {}, { servcmd: ''.concat(U.NAME.RECENT_CONTACT, '.').concat(U.CMD.GET_CONVERSATION_LIST) }), body: { fromAccount: void 0, count: 0 }, keyMap: { request: {}, response: { SessionItem: 'conversations', ToAccount: 'groupID', To_Account: 'userID', UnreadMsgCount: 'unreadCount', MsgGroupReadedSeq: 'messageReadSeq', C2cPeerReadTime: 'c2cPeerReadTime' } } }
      }(e))), this._configMap.set(gn, (function (e) {
        return { head: t(t({}, e), {}, { servcmd: ''.concat(U.NAME.RECENT_CONTACT, '.').concat(U.CMD.PAGING_GET_CONVERSATION_LIST) }), body: { fromAccount: void 0, timeStamp: void 0, orderType: void 0, messageAssistFlag: 4 }, keyMap: { request: { messageAssistFlag: 'MsgAssistFlags' }, response: { SessionItem: 'conversations', ToAccount: 'groupID', To_Account: 'userID', UnreadMsgCount: 'unreadCount', MsgGroupReadedSeq: 'messageReadSeq', C2cPeerReadTime: 'c2cPeerReadTime', LastMsgFlags: 'lastMessageFlag' } } }
      }(e))), this._configMap.set(hn, (function (e) {
        return { head: t(t({}, e), {}, { servcmd: ''.concat(U.NAME.RECENT_CONTACT, '.').concat(U.CMD.DELETE_CONVERSATION) }), body: { fromAccount: '', toAccount: void 0, type: 1, toGroupID: void 0 }, keyMap: { request: { toGroupID: 'ToGroupid' } } }
      }(e))), this._configMap.set(_n, (function (e) {
        return { head: t(t({}, e), {}, { servcmd: ''.concat(U.NAME.OPEN_IM, '.').concat(U.CMD.DELETE_GROUP_AT_TIPS) }), body: { messageListToDelete: void 0 }, keyMap: { request: { messageListToDelete: 'DelMsgList', messageSeq: 'MsgSeq', messageRandom: 'MsgRandom' } } }
      }(e))), this._configMap.set(tn, (function (e) {
        return { head: t(t({}, e), {}, { servcmd: ''.concat(U.NAME.PROFILE, '.').concat(U.CMD.PORTRAIT_GET) }), body: { fromAccount: '', userItem: [] }, keyMap: { request: { toAccount: 'To_Account', standardSequence: 'StandardSequence', customSequence: 'CustomSequence' } } }
      }(e))), this._configMap.set(nn, (function (e) {
        return { head: t(t({}, e), {}, { servcmd: ''.concat(U.NAME.PROFILE, '.').concat(U.CMD.PORTRAIT_SET) }), body: { fromAccount: '', profileItem: [{ tag: Ks.NICK, value: '' }, { tag: Ks.GENDER, value: '' }, { tag: Ks.ALLOWTYPE, value: '' }, { tag: Ks.AVATAR, value: '' }] }, keyMap: { request: { toAccount: 'To_Account', standardSequence: 'StandardSequence', customSequence: 'CustomSequence' } } }
      }(e))), this._configMap.set(on, (function (e) {
        return { head: t(t({}, e), {}, { servcmd: ''.concat(U.NAME.FRIEND, '.').concat(U.CMD.GET_BLACKLIST) }), body: { fromAccount: '', startIndex: 0, maxLimited: 30, lastSequence: 0 }, keyMap: { response: { CurruentSequence: 'currentSequence' } } }
      }(e))), this._configMap.set(an, (function (e) {
        return { head: t(t({}, e), {}, { servcmd: ''.concat(U.NAME.FRIEND, '.').concat(U.CMD.ADD_BLACKLIST) }), body: { fromAccount: '', toAccount: [] } }
      }(e))), this._configMap.set(sn, (function (e) {
        return { head: t(t({}, e), {}, { servcmd: ''.concat(U.NAME.FRIEND, '.').concat(U.CMD.DELETE_BLACKLIST) }), body: { fromAccount: '', toAccount: [] } }
      }(e))), this._configMap.set(fn, (function (e) {
        return { head: t(t({}, e), {}, { servcmd: ''.concat(U.NAME.GROUP, '.').concat(U.CMD.GET_JOINED_GROUPS) }), body: { memberAccount: '', limit: void 0, offset: void 0, groupType: void 0, responseFilter: { groupBaseInfoFilter: void 0, selfInfoFilter: void 0 } }, keyMap: { request: { memberAccount: 'Member_Account' }, response: { GroupIdList: 'groups', MsgFlag: 'messageRemindType' } } }
      }(e))), this._configMap.set(mn, (function (e) {
        return { head: t(t({}, e), {}, { servcmd: ''.concat(U.NAME.GROUP, '.').concat(U.CMD.GET_GROUP_INFO) }), body: { groupIDList: void 0, responseFilter: { groupBaseInfoFilter: ['Type', 'Name', 'Introduction', 'Notification', 'FaceUrl', 'Owner_Account', 'CreateTime', 'InfoSeq', 'LastInfoTime', 'LastMsgTime', 'MemberNum', 'MaxMemberNum', 'ApplyJoinOption', 'NextMsgSeq', 'ShutUpAllMember'], groupCustomFieldFilter: void 0, memberInfoFilter: void 0, memberCustomFieldFilter: void 0 } }, keyMap: { request: { groupIDList: 'GroupIdList', groupCustomField: 'AppDefinedData', memberCustomField: 'AppMemberDefinedData', groupCustomFieldFilter: 'AppDefinedDataFilter_Group', memberCustomFieldFilter: 'AppDefinedDataFilter_GroupMember' }, response: { GroupIdList: 'groups', MsgFlag: 'messageRemindType', AppDefinedData: 'groupCustomField', AppMemberDefinedData: 'memberCustomField', AppDefinedDataFilter_Group: 'groupCustomFieldFilter', AppDefinedDataFilter_GroupMember: 'memberCustomFieldFilter', InfoSeq: 'infoSequence', MemberList: 'members', GroupInfo: 'groups', ShutUpUntil: 'muteUntil', ShutUpAllMember: 'muteAllMembers', ApplyJoinOption: 'joinOption' } } }
      }(e))), this._configMap.set(Mn, (function (e) {
        return { head: t(t({}, e), {}, { servcmd: ''.concat(U.NAME.GROUP, '.').concat(U.CMD.CREATE_GROUP) }), body: { type: void 0, name: void 0, groupID: void 0, ownerID: void 0, introduction: void 0, notification: void 0, maxMemberNum: void 0, joinOption: void 0, memberList: void 0, groupCustomField: void 0, memberCustomField: void 0, webPushFlag: 1, avatar: 'FaceUrl' }, keyMap: { request: { ownerID: 'Owner_Account', userID: 'Member_Account', avatar: 'FaceUrl', maxMemberNum: 'MaxMemberCount', joinOption: 'ApplyJoinOption', groupCustomField: 'AppDefinedData', memberCustomField: 'AppMemberDefinedData' }, response: { HugeGroupFlag: 'avChatRoomFlag', OverJoinedGroupLimit_Account: 'overLimitUserIDList' } } }
      }(e))), this._configMap.set(vn, (function (e) {
        return { head: t(t({}, e), {}, { servcmd: ''.concat(U.NAME.GROUP, '.').concat(U.CMD.DESTROY_GROUP) }), body: { groupID: void 0 } }
      }(e))), this._configMap.set(yn, (function (e) {
        return { head: t(t({}, e), {}, { servcmd: ''.concat(U.NAME.GROUP, '.').concat(U.CMD.MODIFY_GROUP_INFO) }), body: { groupID: void 0, name: void 0, introduction: void 0, notification: void 0, avatar: void 0, maxMemberNum: void 0, joinOption: void 0, groupCustomField: void 0, muteAllMembers: void 0 }, keyMap: { request: { maxMemberNum: 'MaxMemberCount', groupCustomField: 'AppDefinedData', muteAllMembers: 'ShutUpAllMember', joinOption: 'ApplyJoinOption', avatar: 'FaceUrl' }, response: { AppDefinedData: 'groupCustomField', ShutUpAllMember: 'muteAllMembers', ApplyJoinOption: 'joinOption' } } }
      }(e))), this._configMap.set(In, (function (e) {
        return { head: t(t({}, e), {}, { servcmd: ''.concat(U.NAME.GROUP, '.').concat(U.CMD.APPLY_JOIN_GROUP) }), body: { groupID: void 0, applyMessage: void 0, userDefinedField: void 0, webPushFlag: 1 }, keyMap: { response: { HugeGroupFlag: 'avChatRoomFlag' } } }
      }(e))), this._configMap.set(Dn, (function (e) {
        e.a2, e.tinyid;return { head: t(t({}, p(e, wi)), {}, { servcmd: ''.concat(U.NAME.BIG_GROUP_NO_AUTH, '.').concat(U.CMD.APPLY_JOIN_GROUP) }), body: { groupID: void 0, applyMessage: void 0, userDefinedField: void 0, webPushFlag: 1 }, keyMap: { response: { HugeGroupFlag: 'avChatRoomFlag' } } }
      }(e))), this._configMap.set(Tn, (function (e) {
        return { head: t(t({}, e), {}, { servcmd: ''.concat(U.NAME.GROUP, '.').concat(U.CMD.QUIT_GROUP) }), body: { groupID: void 0 } }
      }(e))), this._configMap.set(Sn, (function (e) {
        return { head: t(t({}, e), {}, { servcmd: ''.concat(U.NAME.GROUP, '.').concat(U.CMD.SEARCH_GROUP_BY_ID) }), body: { groupIDList: void 0, responseFilter: { groupBasePublicInfoFilter: ['Type', 'Name', 'Introduction', 'Notification', 'FaceUrl', 'CreateTime', 'Owner_Account', 'LastInfoTime', 'LastMsgTime', 'NextMsgSeq', 'MemberNum', 'MaxMemberNum', 'ApplyJoinOption'] } }, keyMap: { response: { ApplyJoinOption: 'joinOption' } } }
      }(e))), this._configMap.set(En, (function (e) {
        return { head: t(t({}, e), {}, { servcmd: ''.concat(U.NAME.GROUP, '.').concat(U.CMD.CHANGE_GROUP_OWNER) }), body: { groupID: void 0, newOwnerID: void 0 }, keyMap: { request: { newOwnerID: 'NewOwner_Account' } } }
      }(e))), this._configMap.set(kn, (function (e) {
        return { head: t(t({}, e), {}, { servcmd: ''.concat(U.NAME.GROUP, '.').concat(U.CMD.HANDLE_APPLY_JOIN_GROUP) }), body: { groupID: void 0, applicant: void 0, handleAction: void 0, handleMessage: void 0, authentication: void 0, messageKey: void 0, userDefinedField: void 0 }, keyMap: { request: { applicant: 'Applicant_Account', handleAction: 'HandleMsg', handleMessage: 'ApprovalMsg', messageKey: 'MsgKey' } } }
      }(e))), this._configMap.set(Cn, (function (e) {
        return { head: t(t({}, e), {}, { servcmd: ''.concat(U.NAME.GROUP, '.').concat(U.CMD.HANDLE_GROUP_INVITATION) }), body: { groupID: void 0, inviter: void 0, handleAction: void 0, handleMessage: void 0, authentication: void 0, messageKey: void 0, userDefinedField: void 0 }, keyMap: { request: { inviter: 'Inviter_Account', handleAction: 'HandleMsg', handleMessage: 'ApprovalMsg', messageKey: 'MsgKey' } } }
      }(e))), this._configMap.set(Ln, (function (e) {
        return { head: t(t({}, e), {}, { servcmd: ''.concat(U.NAME.GROUP, '.').concat(U.CMD.GET_GROUP_APPLICATION) }), body: { startTime: void 0, limit: void 0, handleAccount: void 0 }, keyMap: { request: { handleAccount: 'Handle_Account' } } }
      }(e))), this._configMap.set(Rn, (function (e) {
        return { head: t(t({}, e), {}, { servcmd: ''.concat(U.NAME.OPEN_IM, '.').concat(U.CMD.DELETE_GROUP_SYSTEM_MESSAGE) }), body: { messageListToDelete: void 0 }, keyMap: { request: { messageListToDelete: 'DelMsgList', messageSeq: 'MsgSeq', messageRandom: 'MsgRandom' } } }
      }(e))), this._configMap.set(Gn, (function (e) {
        return { head: t(t({}, e), {}, { servcmd: ''.concat(U.NAME.BIG_GROUP_LONG_POLLING, '.').concat(U.CMD.AVCHATROOM_LONG_POLL) }), body: { USP: 1, startSeq: 1, holdTime: 90, key: void 0 }, keyMap: { request: { USP: 'USP' }, response: { ToGroupId: 'groupID' } } }
      }(e))), this._configMap.set(wn, (function (e) {
        e.a2, e.tinyid;return { head: t(t({}, p(e, Pi)), {}, { servcmd: ''.concat(U.NAME.BIG_GROUP_LONG_POLLING_NO_AUTH, '.').concat(U.CMD.AVCHATROOM_LONG_POLL) }), body: { USP: 1, startSeq: 1, holdTime: 90, key: void 0 }, keyMap: { request: { USP: 'USP' }, response: { ToGroupId: 'groupID' } } }
      }(e))), this._configMap.set(Pn, (function (e) {
        return { head: t(t({}, e), {}, { servcmd: ''.concat(U.NAME.GROUP, '.').concat(U.CMD.GET_ONLINE_MEMBER_NUM) }), body: { groupID: void 0 } }
      }(e))), this._configMap.set(Un, (function (e) {
        return { head: t(t({}, e), {}, { servcmd: ''.concat(U.NAME.GROUP, '.').concat(U.CMD.GET_GROUP_MEMBER_LIST) }), body: { groupID: void 0, limit: 0, offset: 0, memberRoleFilter: void 0, memberInfoFilter: ['Role', 'NameCard', 'ShutUpUntil', 'JoinTime'], memberCustomFieldFilter: void 0 }, keyMap: { request: { memberCustomFieldFilter: 'AppDefinedDataFilter_GroupMember' }, response: { AppMemberDefinedData: 'memberCustomField', AppDefinedDataFilter_GroupMember: 'memberCustomFieldFilter', MemberList: 'members' } } }
      }(e))), this._configMap.set(Fn, (function (e) {
        return { head: t(t({}, e), {}, { servcmd: ''.concat(U.NAME.GROUP, '.').concat(U.CMD.GET_GROUP_MEMBER_INFO) }), body: { groupID: void 0, userIDList: void 0, memberInfoFilter: void 0, memberCustomFieldFilter: void 0 }, keyMap: { request: { userIDList: 'Member_List_Account', memberCustomFieldFilter: 'AppDefinedDataFilter_GroupMember' }, response: { MemberList: 'members', ShutUpUntil: 'muteUntil', AppDefinedDataFilter_GroupMember: 'memberCustomFieldFilter', AppMemberDefinedData: 'memberCustomField' } } }
      }(e))), this._configMap.set(qn, (function (e) {
        return { head: t(t({}, e), {}, { servcmd: ''.concat(U.NAME.GROUP, '.').concat(U.CMD.ADD_GROUP_MEMBER) }), body: { groupID: void 0, silence: void 0, userIDList: void 0 }, keyMap: { request: { userID: 'Member_Account', userIDList: 'MemberList' }, response: { MemberList: 'members' } } }
      }(e))), this._configMap.set(Vn, (function (e) {
        return { head: t(t({}, e), {}, { servcmd: ''.concat(U.NAME.GROUP, '.').concat(U.CMD.DELETE_GROUP_MEMBER) }), body: { groupID: void 0, userIDList: void 0, reason: void 0 }, keyMap: { request: { userIDList: 'MemberToDel_Account' } } }
      }(e))), this._configMap.set(Kn, (function (e) {
        return { head: t(t({}, e), {}, { servcmd: ''.concat(U.NAME.GROUP, '.').concat(U.CMD.MODIFY_GROUP_MEMBER_INFO) }), body: { groupID: void 0, userID: void 0, messageRemindType: void 0, nameCard: void 0, role: void 0, memberCustomField: void 0, muteTime: void 0 }, keyMap: { request: { userID: 'Member_Account', memberCustomField: 'AppMemberDefinedData', muteTime: 'ShutUpTime', messageRemindType: 'MsgFlag' } } }
      }(e))), this._configMap.set(Hn, (function (e) {
        return { head: t(t({}, e), {}, { servcmd: ''.concat(U.NAME.IM_OPEN_STAT, '.').concat(U.CMD.TIM_WEB_REPORT_V2) }), body: { header: {}, event: [], quality: [] }, keyMap: { request: { SDKType: 'sdk_type', SDKVersion: 'sdk_version', deviceType: 'device_type', platform: 'platform', instanceID: 'instance_id', traceID: 'trace_id', SDKAppID: 'sdk_app_id', userID: 'user_id', tinyID: 'tiny_id', extension: 'extension', timestamp: 'timestamp', networkType: 'network_type', eventType: 'event_type', code: 'error_code', message: 'error_message', moreMessage: 'more_message', duplicate: 'duplicate', costTime: 'cost_time', level: 'level', qualityType: 'quality_type', reportIndex: 'report_index', wholePeriod: 'whole_period', totalCount: 'total_count', rttCount: 'success_count_business', successRateOfRequest: 'percent_business', countLessThan1Second: 'success_count_business', percentOfCountLessThan1Second: 'percent_business', countLessThan3Second: 'success_count_platform', percentOfCountLessThan3Second: 'percent_platform', successCountOfBusiness: 'success_count_business', successRateOfBusiness: 'percent_business', successCountOfPlatform: 'success_count_platform', successRateOfPlatform: 'percent_platform', successCountOfMessageReceived: 'success_count_business', successRateOfMessageReceived: 'percent_business', avgRTT: 'average_value', avgDelay: 'average_value', avgValue: 'average_value' } } }
      }(o))), this._configMap.set(jn, (function (e) {
        return { head: t(t({}, e), {}, { servcmd: ''.concat(U.NAME.HEARTBEAT, '.').concat(U.CMD.ALIVE) }), body: {} }
      }(e))), this._configMap.set($n, (function (e) {
        return { head: t(t({}, e), {}, { servcmd: ''.concat(U.NAME.IM_OPEN_PUSH, '.').concat(U.CMD.MESSAGE_PUSH) }), body: {}, keyMap: { response: { C2cMsgArray: 'C2CMessageArray', GroupMsgArray: 'groupMessageArray', GroupTips: 'groupTips', C2cNotifyMsgArray: 'C2CNotifyMessageArray', ClientSeq: 'clientSequence', MsgPriority: 'priority', NoticeSeq: 'noticeSequence', MsgContent: 'content', MsgType: 'type', MsgBody: 'elements', ToGroupId: 'to', Desc: 'description', Ext: 'extension', IsSyncMsg: 'isSyncMessage', Flag: 'needSync', NeedAck: 'needAck', PendencyAdd_Account: 'userID', ProfileImNick: 'nick', PendencyType: 'applicationType' } } }
      }(e))), this._configMap.set(Yn, (function (e) {
        return { head: t(t({}, e), {}, { servcmd: ''.concat(U.NAME.OPEN_IM, '.').concat(U.CMD.MESSAGE_PUSH_ACK) }), body: { sessionData: void 0 }, keyMap: { request: { sessionData: 'SessionData' } } }
      }(e))), this._configMap.set(zn, (function (e) {
        return { head: t(t({}, e), {}, { servcmd: ''.concat(U.NAME.IM_OPEN_STATUS, '.').concat(U.CMD.STATUS_FORCEOFFLINE) }), body: {}, keyMap: { response: { C2cNotifyMsgArray: 'C2CNotifyMessageArray', NoticeSeq: 'noticeSequence', KickoutMsgNotify: 'kickoutMsgNotify', NewInstInfo: 'newInstanceInfo' } } }
      }(e))), this._configMap.set(Jn, (function (e) {
        return { head: t(t({}, e), {}, { servcmd: ''.concat(U.NAME.IM_LONG_MESSAGE, '.').concat(U.CMD.DOWNLOAD_MERGER_MESSAGE) }), body: { downloadKey: '' }, keyMap: { response: { Data: 'data', Desc: 'description', Ext: 'extension', Download_Flag: 'downloadFlag', ThumbUUID: 'thumbUUID', VideoUUID: 'videoUUID' } } }
      }(e))), this._configMap.set(Wn, (function (e) {
        return { head: t(t({}, e), {}, { servcmd: ''.concat(U.NAME.IM_LONG_MESSAGE, '.').concat(U.CMD.UPLOAD_MERGER_MESSAGE) }), body: { messageList: [] }, keyMap: { request: { fromAccount: 'From_Account', toAccount: 'To_Account', msgTimeStamp: 'MsgTimeStamp', msgSeq: 'MsgSeq', msgRandom: 'MsgRandom', msgBody: 'MsgBody', type: 'MsgType', content: 'MsgContent', data: 'Data', description: 'Desc', extension: 'Ext', sizeType: 'Type', uuid: 'UUID', url: '', imageUrl: 'URL', fileUrl: 'Url', remoteAudioUrl: 'Url', remoteVideoUrl: 'VideoUrl', thumbUUID: 'ThumbUUID', videoUUID: 'VideoUUID', videoUrl: '', downloadFlag: 'Download_Flag', from: 'From_Account', time: 'MsgTimeStamp', messageRandom: 'MsgRandom', messageSequence: 'MsgSeq', elements: 'MsgBody', clientSequence: 'ClientSeq', payload: 'MsgContent', messageList: 'MsgList', messageNumber: 'MsgNum', abstractList: 'AbstractList', messageBody: 'MsgBody' } } }
      }(e)))
    } }, { key: 'has', value(e) {
      return this._configMap.has(e)
    } }, { key: 'get', value(e) {
      return this._configMap.get(e)
    } }, { key: 'update', value() {
      this._fillConfigMap()
    } }, { key: 'getKeyMap', value(e) {
      return this.has(e) ? this.get(e).keyMap || {} : (Ee.warn(''.concat(this._className, '.getKeyMap unknown protocolName:').concat(e)), {})
    } }, { key: 'getProtocolData', value(e) {
      const t = e.protocolName; const n = e.requestData; const o = this.get(t); let a = null;if (n) {
        const s = this._simpleDeepCopy(o); const r = s.body; const i = Object.create(null);for (const c in r) if (Object.prototype.hasOwnProperty.call(r, c)) {
          if (i[c] = r[c], void 0 === n[c]) continue;i[c] = n[c]
        }s.body = i, a = this._getUplinkData(s)
      } else a = this._getUplinkData(o);return a
    } }, { key: '_getUplinkData', value(e) {
      const t = this._requestDataCleaner(e); const n = ct(t.head); const o = Di(t.body, this._getRequestKeyMap(n));return t.body = o, t
    } }, { key: '_getRequestKeyMap', value(e) {
      const n = this.getKeyMap(e);return t(t({}, vi.request), n.request)
    } }, { key: '_requestDataCleaner', value(e) {
      const t = Array.isArray(e) ? [] : Object.create(null);for (const o in e)Object.prototype.hasOwnProperty.call(e, o) && Fe(o) && null !== e[o] && void 0 !== e[o] && ('object' !== n(e[o]) ? t[o] = e[o] : t[o] = this._requestDataCleaner.bind(this)(e[o]));return t
    } }, { key: '_simpleDeepCopy', value(e) {
      for (var t, n = Object.keys(e), o = {}, a = 0, s = n.length;a < s;a++)t = n[a], Re(e[t]) ? o[t] = Array.from(e[t]) : Oe(e[t]) ? o[t] = this._simpleDeepCopy(e[t]) : o[t] = e[t];return o
    } }]), e
  }()); const Ui = [Yn]; const Fi = (function () {
    function e(t) {
      o(this, e), this._sessionModule = t, this._className = 'DownlinkHandler', this._eventHandlerMap = new Map, this._eventHandlerMap.set('C2CMessageArray', this._c2cMessageArrayHandler.bind(this)), this._eventHandlerMap.set('groupMessageArray', this._groupMessageArrayHandler.bind(this)), this._eventHandlerMap.set('groupTips', this._groupTipsHandler.bind(this)), this._eventHandlerMap.set('C2CNotifyMessageArray', this._C2CNotifyMessageArrayHandler.bind(this)), this._eventHandlerMap.set('profileModify', this._profileHandler.bind(this)), this._eventHandlerMap.set('friendListMod', this._relationChainHandler.bind(this)), this._keys = M(this._eventHandlerMap.keys())
    } return s(e, [{ key: '_c2cMessageArrayHandler', value(e) {
      const t = this._sessionModule.getModule(Nt);if (t) {
        if (e.dataList.forEach(((e) => {
          if (1 === e.isSyncMessage) {
            const t = e.from;e.from = e.to, e.to = t
          }
        })), 1 === e.needSync) this._sessionModule.getModule(Vt).startOnlineSync();t.onNewC2CMessage({ dataList: e.dataList, isInstantMessage: !0 })
      }
    } }, { key: '_groupMessageArrayHandler', value(e) {
      const t = this._sessionModule.getModule(At);t && t.onNewGroupMessage({ event: e.event, dataList: e.dataList, isInstantMessage: !0 })
    } }, { key: '_groupTipsHandler', value(e) {
      const t = this._sessionModule.getModule(At);if (t) {
        const n = e.event; const o = e.dataList; const a = e.isInstantMessage; const s = void 0 === a || a; const r = e.isSyncingEnded;switch (n) {
          case 4:case 6:t.onNewGroupTips({ event: n, dataList: o });break;case 5:o.forEach(((e) => {
            Re(e.elements.revokedInfos) ? t.onGroupMessageRevoked({ dataList: o }) : Re(e.elements.groupMessageReadNotice) ? t.onGroupMessageReadNotice({ dataList: o }) : t.onNewGroupSystemNotice({ dataList: o, isInstantMessage: s, isSyncingEnded: r })
          }));break;case 12:this._sessionModule.getModule(Rt).onNewGroupAtTips({ dataList: o });break;default:Ee.log(''.concat(this._className, '._groupTipsHandler unknown event:').concat(n, ' dataList:'), o)
        }
      }
    } }, { key: '_C2CNotifyMessageArrayHandler', value(e) {
      const t = this; const n = e.dataList;if (Re(n)) {
        const o = this._sessionModule.getModule(Nt);n.forEach(((e) => {
          if (Le(e)) if (e.hasOwnProperty('kickoutMsgNotify')) {
            const a = e.kickoutMsgNotify; const s = a.kickType; const r = a.newInstanceInfo; const i = void 0 === r ? {} : r;1 === s ? t._sessionModule.onMultipleAccountKickedOut(i) : 2 === s && t._sessionModule.onMultipleDeviceKickedOut(i)
          } else e.hasOwnProperty('c2cMessageRevokedNotify') ? o && o.onC2CMessageRevoked({ dataList: n }) : e.hasOwnProperty('c2cMessageReadReceipt') ? o && o.onC2CMessageReadReceipt({ dataList: n }) : e.hasOwnProperty('c2cMessageReadNotice') && o && o.onC2CMessageReadNotice({ dataList: n })
        }))
      }
    } }, { key: '_profileHandler', value(e) {
      this._sessionModule.getModule(Ct).onProfileModified({ dataList: e.dataList });const t = this._sessionModule.getModule(Ot);t && t.onFriendProfileModified({ dataList: e.dataList })
    } }, { key: '_relationChainHandler', value(e) {
      this._sessionModule.getModule(Ct).onRelationChainModified({ dataList: e.dataList });const t = this._sessionModule.getModule(Ot);t && t.onRelationChainModified({ dataList: e.dataList })
    } }, { key: '_cloudControlConfigHandler', value(e) {
      this._sessionModule.getModule(Ht).onPushedCloudControlConfig(e)
    } }, { key: 'onMessage', value(e) {
      const t = this; const n = e.head; const o = e.body;if (this._isPushedCloudControlConfig(n)) this._cloudControlConfigHandler(o);else {
        const a = o.eventArray; const s = o.isInstantMessage; const r = o.isSyncingEnded; const i = o.needSync;if (Re(a)) for (let c = null, u = null, l = 0, d = 0, g = a.length;d < g;d++) {
          l = (c = a[d]).event;const p = Object.keys(c).find(((e) => -1 !== t._keys.indexOf(e)));p ? (u = c[p], this._eventHandlerMap.get(p)({ event: l, dataList: u, isInstantMessage: s, isSyncingEnded: r, needSync: i })) : Ee.log(''.concat(this._className, '.onMessage unknown eventItem:').concat(c))
        }
      }
    } }, { key: '_isPushedCloudControlConfig', value(e) {
      return e.servcmd && e.servcmd.includes(Qn)
    } }]), e
  }()); const qi = (function (e) {
    i(n, e);const t = f(n);function n(e) {
      let a;return o(this, n), (a = t.call(this, e))._className = 'SessionModule', a._platform = a.getPlatform(), a._protocolHandler = new bi(h(a)), a._messageDispatcher = new Fi(h(a)), a
    } return s(n, [{ key: 'updateProtocolConfig', value() {
      this._protocolHandler.update()
    } }, { key: 'request', value(e) {
      Ee.debug(''.concat(this._className, '.request options:'), e);const t = e.protocolName; const n = e.tjgID;if (!this._protocolHandler.has(t)) return Ee.warn(''.concat(this._className, '.request unknown protocol:').concat(t)), Mr({ code: Zn.CANNOT_FIND_PROTOCOL, message: sa });const o = this.getProtocolData(e);dt(n) || (o.head.tjgID = n);const a = this.getModule(xt);return Ui.includes(t) ? a.simplySend(o) : a.send(o)
    } }, { key: 'getKeyMap', value(e) {
      return this._protocolHandler.getKeyMap(e)
    } }, { key: 'genCommonHead', value() {
      const e = this.getModule(Gt);return { ver: 'v4', platform: this._platform, websdkappid: G, websdkversion: R, a2: e.getA2Key() || void 0, tinyid: e.getTinyID() || void 0, status_instid: e.getStatusInstanceID(), sdkappid: e.getSDKAppID(), contenttype: e.getContentType(), reqtime: 0, identifier: e.getA2Key() ? void 0 : e.getUserID(), usersig: e.getA2Key() ? void 0 : e.getUserSig(), sdkability: 2, tjgID: '' }
    } }, { key: 'genCosSpecifiedHead', value() {
      const e = this.getModule(Gt);return { ver: 'v4', platform: this._platform, websdkappid: G, websdkversion: R, sdkappid: e.getSDKAppID(), contenttype: e.getContentType(), reqtime: 0, identifier: e.getUserID(), usersig: e.getUserSig(), status_instid: e.getStatusInstanceID(), sdkability: 2 }
    } }, { key: 'genSSOReportHead', value() {
      const e = this.getModule(Gt);return { ver: 'v4', platform: this._platform, websdkappid: G, websdkversion: R, sdkappid: e.getSDKAppID(), contenttype: '', reqtime: 0, identifier: '', usersig: '', status_instid: e.getStatusInstanceID(), sdkability: 2 }
    } }, { key: 'getProtocolData', value(e) {
      return this._protocolHandler.getProtocolData(e)
    } }, { key: 'onErrorCodeNotZero', value(e) {
      const t = e.errorCode;if (t === Zn.HELLO_ANSWER_KICKED_OUT) {
        const n = e.kickType; const o = e.newInstanceInfo; const a = void 0 === o ? {} : o;1 === n ? this.onMultipleAccountKickedOut(a) : 2 === n && this.onMultipleDeviceKickedOut(a)
      }t !== Zn.MESSAGE_A2KEY_EXPIRED && t !== Zn.ACCOUNT_A2KEY_EXPIRED || (this._onUserSigExpired(), this.getModule(xt).reConnect())
    } }, { key: 'onMessage', value(e) {
      const t = e.body; const n = t.needAck; const o = void 0 === n ? 0 : n; const a = t.sessionData;1 === o && this._sendACK(a), this._messageDispatcher.onMessage(e)
    } }, { key: 'onReconnected', value() {
      const e = this;this.isLoggedIn() && this.request({ protocolName: zt }).then(((t) => {
        const n = t.data.instanceID;e.getModule(Gt).setStatusInstanceID(n), e.getModule(jt).startPull()
      }))
    } }, { key: 'onMultipleAccountKickedOut', value(e) {
      this.getModule(Et).onMultipleAccountKickedOut(e)
    } }, { key: 'onMultipleDeviceKickedOut', value(e) {
      this.getModule(Et).onMultipleDeviceKickedOut(e)
    } }, { key: '_onUserSigExpired', value() {
      this.getModule(Et).onUserSigExpired()
    } }, { key: '_sendACK', value(e) {
      this.request({ protocolName: Yn, requestData: { sessionData: e } })
    } }]), n
  }(Yt)); const Vi = (function (e) {
    i(n, e);const t = f(n);function n(e) {
      let a;return o(this, n), (a = t.call(this, e))._className = 'MessageLossDetectionModule', a._maybeLostSequencesMap = new Map, a
    } return s(n, [{ key: 'onMessageMaybeLost', value(e, t, n) {
      this._maybeLostSequencesMap.has(e) || this._maybeLostSequencesMap.set(e, []);for (var o = this._maybeLostSequencesMap.get(e), a = 0;a < n;a++)o.push(t + a);Ee.debug(''.concat(this._className, '.onMessageMaybeLost. maybeLostSequences:').concat(o))
    } }, { key: 'detectMessageLoss', value(e, t) {
      const n = this._maybeLostSequencesMap.get(e);if (!dt(n) && !dt(t)) {
        const o = t.filter(((e) => -1 !== n.indexOf(e)));if (Ee.debug(''.concat(this._className, '.detectMessageLoss. matchedSequences:').concat(o)), n.length === o.length)Ee.info(''.concat(this._className, '.detectMessageLoss no message loss. conversationID:').concat(e));else {
          let a; const s = n.filter(((e) => -1 === o.indexOf(e))); const r = s.length;r <= 5 ? a = `${e}-${s.join('-')}` : (s.sort(((e, t) => e - t)), a = `${e} start:${s[0]} end:${s[r - 1]} count:${r}`), new Da(Ns).setMessage(a)
            .setNetworkType(this.getNetworkType())
            .setLevel('warning')
            .end(), Ee.warn(''.concat(this._className, '.detectMessageLoss message loss detected. conversationID:').concat(e, ' lostSequences:')
            .concat(s))
        }n.length = 0
      }
    } }, { key: 'reset', value() {
      Ee.log(''.concat(this._className, '.reset')), this._maybeLostSequencesMap.clear()
    } }]), n
  }(Yt)); const Ki = (function (e) {
    i(n, e);const t = f(n);function n(e) {
      let a;return o(this, n), (a = t.call(this, e))._className = 'CloudControlModule', a._cloudConfig = new Map, a._expiredTime = 0, a._version = 0, a._isFetching = !1, a
    } return s(n, [{ key: 'getCloudConfig', value(e) {
      return Ge(e) ? this._cloudConfig : this._cloudConfig.has(e) ? this._cloudConfig.get(e) : void 0
    } }, { key: '_canFetchConfig', value() {
      return this.isLoggedIn() && !this._isFetching && Date.now() >= this._expiredTime
    } }, { key: 'fetchConfig', value() {
      const e = this; const t = this._canFetchConfig();if (Ee.log(''.concat(this._className, '.fetchConfig canFetchConfig:').concat(t)), t) {
        const n = new Da(bs); const o = this.getModule(Gt).getSDKAppID();this._isFetching = !0, this.request({ protocolName: Xn, requestData: { SDKAppID: o, version: this._version } }).then(((t) => {
          e._isFetching = !1, n.setMessage('version:'.concat(e._version, ' newVersion:').concat(t.data.version, ' config:')
            .concat(t.data.cloudControlConfig)).setNetworkType(e.getNetworkType())
            .end(), Ee.log(''.concat(e._className, '.fetchConfig ok')), e._parseCloudControlConfig(t.data)
        }))
          .catch(((t) => {
            e._isFetching = !1, e.probeNetwork().then(((e) => {
              const o = m(e, 2); const a = o[0]; const s = o[1];n.setError(t, a, s).end()
            })), Ee.log(''.concat(e._className, '.fetchConfig failed. error:'), t), e._setExpiredTimeOnResponseError(12e4)
          }))
      }
    } }, { key: 'onPushedCloudControlConfig', value(e) {
      Ee.log(''.concat(this._className, '.onPushedCloudControlConfig')), new Da(Us).setNetworkType(this.getNetworkType())
        .setMessage('newVersion:'.concat(e.version, ' config:').concat(e.cloudControlConfig))
        .end(), this._parseCloudControlConfig(e)
    } }, { key: 'onCheckTimer', value(e) {
      this._canFetchConfig() && this.fetchConfig()
    } }, { key: '_parseCloudControlConfig', value(e) {
      const t = this; const n = ''.concat(this._className, '._parseCloudControlConfig'); const o = e.errorCode; const a = e.errorMessage; const s = e.cloudControlConfig; const r = e.version; const i = e.expiredTime;if (0 === o) {
        if (this._version !== r) {
          let c = null;try {
            c = JSON.parse(s)
          } catch (u) {
            Ee.error(''.concat(n, ' JSON parse error:').concat(s))
          }c && (this._cloudConfig.clear(), Object.keys(c).forEach(((e) => {
            t._cloudConfig.set(e, c[e])
          })), this._version = r, this.emitInnerEvent(Ir.CLOUD_CONFIG_UPDATED))
        } this._expiredTime = Date.now() + 1e3 * i
      } else Ge(o) ? (Ee.log(''.concat(n, ' failed. Invalid message format:'), e), this._setExpiredTimeOnResponseError(36e5)) : (Ee.error(''.concat(n, ' errorCode:').concat(o, ' errorMessage:')
        .concat(a)), this._setExpiredTimeOnResponseError(12e4))
    } }, { key: '_setExpiredTimeOnResponseError', value(e) {
      this._expiredTime = Date.now() + e
    } }, { key: 'reset', value() {
      Ee.log(''.concat(this._className, '.reset')), this._cloudConfig.clear(), this._expiredTime = 0, this._version = 0, this._isFetching = !1
    } }]), n
  }(Yt)); const xi = (function (e) {
    i(n, e);const t = f(n);function n(e) {
      let a;return o(this, n), (a = t.call(this, e))._className = 'PullGroupMessageModule', a._remoteLastMessageSequenceMap = new Map, a.PULL_LIMIT_COUNT = 15, a
    } return s(n, [{ key: 'startPull', value() {
      const e = this; const t = this._getNeedPullConversationList();this._getRemoteLastMessageSequenceList().then((() => {
        const n = e.getModule(Rt);t.forEach(((t) => {
          const o = t.conversationID; const a = o.replace(k.CONV_GROUP, ''); const s = n.getGroupLocalLastMessageSequence(o); const r = e._remoteLastMessageSequenceMap.get(a) || 0; const i = r - s;Ee.log(''.concat(e._className, '.startPull groupID:').concat(a, ' localLastMessageSequence:')
            .concat(s, ' ') + 'remoteLastMessageSequence:'.concat(r, ' diff:').concat(i)), s > 0 && i > 1 && i < 300 && e._pullMissingMessage({ groupID: a, localLastMessageSequence: s, remoteLastMessageSequence: r, diff: i })
        }))
      }))
    } }, { key: '_getNeedPullConversationList', value() {
      return this.getModule(Rt).getLocalConversationList()
        .filter(((e) => e.type === k.CONV_GROUP && e.groupProfile.type !== k.GRP_AVCHATROOM))
    } }, { key: '_getRemoteLastMessageSequenceList', value() {
      const e = this;return this.getModule(At).getGroupList()
        .then(((t) => {
          for (let n = t.data.groupList, o = void 0 === n ? [] : n, a = 0;a < o.length;a++) {
            const s = o[a]; const r = s.groupID; const i = s.nextMessageSeq;if (s.type !== k.GRP_AVCHATROOM) {
              const c = i - 1;e._remoteLastMessageSequenceMap.set(r, c)
            }
          }
        }))
    } }, { key: '_pullMissingMessage', value(e) {
      const t = this; const n = e.localLastMessageSequence; const o = e.remoteLastMessageSequence; const a = e.diff;e.count = a > this.PULL_LIMIT_COUNT ? this.PULL_LIMIT_COUNT : a, e.sequence = a > this.PULL_LIMIT_COUNT ? n + this.PULL_LIMIT_COUNT : n + a, this._getGroupMissingMessage(e).then(((s) => {
        s.length > 0 && (s[0].sequence + 1 <= o && (e.localLastMessageSequence = n + t.PULL_LIMIT_COUNT, e.diff = a - t.PULL_LIMIT_COUNT, t._pullMissingMessage(e)), t.getModule(At).onNewGroupMessage({ dataList: s, isInstantMessage: !1 }))
      }))
    } }, { key: '_getGroupMissingMessage', value(e) {
      const t = this; const n = new Da(hs);return this.request({ protocolName: On, requestData: { groupID: e.groupID, count: e.count, sequence: e.sequence } }).then(((o) => {
        const a = o.data.messageList; const s = void 0 === a ? [] : a;return n.setNetworkType(t.getNetworkType()).setMessage('groupID:'.concat(e.groupID, ' count:').concat(e.count, ' sequence:')
          .concat(e.sequence, ' messageList length:')
          .concat(s.length))
          .end(), s
      }))
        .catch(((e) => {
          t.probeNetwork().then(((t) => {
            const o = m(t, 2); const a = o[0]; const s = o[1];n.setError(e, a, s).end()
          }))
        }))
    } }, { key: 'reset', value() {
      Ee.log(''.concat(this._className, '.reset')), this._remoteLastMessageSequenceMap.clear()
    } }]), n
  }(Yt)); const Bi = (function () {
    function e() {
      o(this, e), this._className = 'AvgE2EDelay', this._e2eDelayArray = []
    } return s(e, [{ key: 'addMessageDelay', value(e) {
      const t = ut(e.currentTime / 1e3 - e.time, 2);this._e2eDelayArray.push(t)
    } }, { key: '_calcAvg', value(e, t) {
      if (0 === t) return 0;let n = 0;return e.forEach(((e) => {
        n += e
      })), ut(n / t, 1)
    } }, { key: '_calcTotalCount', value() {
      return this._e2eDelayArray.length
    } }, { key: '_calcCountWithLimit', value(e) {
      const t = e.e2eDelayArray; const n = e.min; const o = e.max;return t.filter(((e) => n < e && e <= o)).length
    } }, { key: '_calcPercent', value(e, t) {
      let n = ut(e / t * 100, 2);return n > 100 && (n = 100), n
    } }, { key: '_checkE2EDelayException', value(e, t) {
      const n = e.filter(((e) => e > t));if (n.length > 0) {
        const o = n.length; const a = Math.min.apply(Math, M(n)); const s = Math.max.apply(Math, M(n)); const r = this._calcAvg(n, o); const i = ut(o / e.length * 100, 2);new Da(za).setMessage('message e2e delay exception. count:'.concat(o, ' min:').concat(a, ' max:')
          .concat(s, ' avg:')
          .concat(r, ' percent:')
          .concat(i))
          .setLevel('warning')
          .end()
      }
    } }, { key: 'getStatResult', value() {
      const e = this._calcTotalCount();if (0 === e) return null;const t = M(this._e2eDelayArray); const n = this._calcCountWithLimit({ e2eDelayArray: t, min: 0, max: 1 }); const o = this._calcCountWithLimit({ e2eDelayArray: t, min: 1, max: 3 }); const a = this._calcPercent(n, e); const s = this._calcPercent(o, e); const r = this._calcAvg(t, e);return this._checkE2EDelayException(t, 3), this.reset(), { totalCount: e, countLessThan1Second: n, percentOfCountLessThan1Second: a, countLessThan3Second: o, percentOfCountLessThan3Second: s, avgDelay: r }
    } }, { key: 'reset', value() {
      this._e2eDelayArray.length = 0
    } }]), e
  }()); const Hi = (function () {
    function e() {
      o(this, e), this._className = 'AvgRTT', this._requestCount = 0, this._rttArray = []
    } return s(e, [{ key: 'addRequestCount', value() {
      this._requestCount += 1
    } }, { key: 'addRTT', value(e) {
      this._rttArray.push(e)
    } }, { key: '_calcTotalCount', value() {
      return this._requestCount
    } }, { key: '_calcRTTCount', value(e) {
      return e.length
    } }, { key: '_calcSuccessRateOfRequest', value(e, t) {
      if (0 === t) return 0;let n = ut(e / t * 100, 2);return n > 100 && (n = 100), n
    } }, { key: '_calcAvg', value(e, t) {
      if (0 === t) return 0;let n = 0;return e.forEach(((e) => {
        n += e
      })), parseInt(n / t)
    } }, { key: '_calcMax', value() {
      return Math.max.apply(Math, M(this._rttArray))
    } }, { key: '_calcMin', value() {
      return Math.min.apply(Math, M(this._rttArray))
    } }, { key: 'getStatResult', value() {
      const e = this._calcTotalCount(); const t = M(this._rttArray);if (0 === e) return null;const n = this._calcRTTCount(t); const o = this._calcSuccessRateOfRequest(n, e); const a = this._calcAvg(t, n);return Ee.log(''.concat(this._className, '.getStatResult max:').concat(this._calcMax(), ' min:')
        .concat(this._calcMin(), ' avg:')
        .concat(a)), this.reset(), { totalCount: e, rttCount: n, successRateOfRequest: o, avgRTT: a }
    } }, { key: 'reset', value() {
      this._requestCount = 0, this._rttArray.length = 0
    } }]), e
  }()); const ji = (function () {
    function e(t) {
      const n = this;o(this, e), this._map = new Map, t.forEach(((e) => {
        n._map.set(e, { totalCount: 0, successCount: 0, failedCountOfUserSide: 0, costArray: [], fileSizeArray: [] })
      }))
    } return s(e, [{ key: 'addTotalCount', value(e) {
      return !(Ge(e) || !this._map.has(e)) && (this._map.get(e).totalCount += 1, !0)
    } }, { key: 'addSuccessCount', value(e) {
      return !(Ge(e) || !this._map.has(e)) && (this._map.get(e).successCount += 1, !0)
    } }, { key: 'addFailedCountOfUserSide', value(e) {
      return !(Ge(e) || !this._map.has(e)) && (this._map.get(e).failedCountOfUserSide += 1, !0)
    } }, { key: 'addCost', value(e, t) {
      return !(Ge(e) || !this._map.has(e)) && (this._map.get(e).costArray.push(t), !0)
    } }, { key: 'addFileSize', value(e, t) {
      return !(Ge(e) || !this._map.has(e)) && (this._map.get(e).fileSizeArray.push(t), !0)
    } }, { key: '_calcSuccessRateOfBusiness', value(e) {
      if (Ge(e) || !this._map.has(e)) return -1;const t = this._map.get(e); let n = ut(t.successCount / t.totalCount * 100, 2);return n > 100 && (n = 100), n
    } }, { key: '_calcSuccessRateOfPlatform', value(e) {
      if (Ge(e) || !this._map.has(e)) return -1;const t = this._map.get(e); let n = this._calcSuccessCountOfPlatform(e) / t.totalCount * 100;return (n = ut(n, 2)) > 100 && (n = 100), n
    } }, { key: '_calcTotalCount', value(e) {
      return Ge(e) || !this._map.has(e) ? -1 : this._map.get(e).totalCount
    } }, { key: '_calcSuccessCountOfBusiness', value(e) {
      return Ge(e) || !this._map.has(e) ? -1 : this._map.get(e).successCount
    } }, { key: '_calcSuccessCountOfPlatform', value(e) {
      if (Ge(e) || !this._map.has(e)) return -1;const t = this._map.get(e);return t.successCount + t.failedCountOfUserSide
    } }, { key: '_calcAvg', value(e) {
      return Ge(e) || !this._map.has(e) ? -1 : e === _a ? this._calcAvgSpeed(e) : this._calcAvgCost(e)
    } }, { key: '_calcAvgCost', value(e) {
      const t = this._map.get(e).costArray.length;if (0 === t) return 0;let n = 0;return this._map.get(e).costArray.forEach(((e) => {
        n += e
      })), parseInt(n / t)
    } }, { key: '_calcAvgSpeed', value(e) {
      let t = 0; let n = 0;return this._map.get(e).costArray.forEach(((e) => {
        t += e
      })), this._map.get(e).fileSizeArray.forEach(((e) => {
        n += e
      })), parseInt(1e3 * n / t)
    } }, { key: 'getStatResult', value(e) {
      const t = this._calcTotalCount(e);if (0 === t) return null;const n = this._calcSuccessCountOfBusiness(e); const o = this._calcSuccessRateOfBusiness(e); const a = this._calcSuccessCountOfPlatform(e); const s = this._calcSuccessRateOfPlatform(e); const r = this._calcAvg(e);return this.reset(e), { totalCount: t, successCountOfBusiness: n, successRateOfBusiness: o, successCountOfPlatform: a, successRateOfPlatform: s, avgValue: r }
    } }, { key: 'reset', value(e) {
      Ge(e) ? this._map.clear() : this._map.set(e, { totalCount: 0, successCount: 0, failedCountOfUserSide: 0, costArray: [], fileSizeArray: [] })
    } }]), e
  }()); const $i = (function () {
    function e(t) {
      const n = this;o(this, e), this._lastMap = new Map, this._currentMap = new Map, t.forEach(((e) => {
        n._lastMap.set(e, new Map), n._currentMap.set(e, new Map)
      }))
    } return s(e, [{ key: 'addMessageSequence', value(e) {
      const t = e.key; const n = e.message;if (Ge(t) || !this._lastMap.has(t) || !this._currentMap.has(t)) return !1;const o = n.conversationID; const a = n.sequence; const s = o.replace(k.CONV_GROUP, '');if (0 === this._lastMap.get(t).size) this._addCurrentMap(e);else if (this._lastMap.get(t).has(s)) {
        const r = this._lastMap.get(t).get(s); const i = r.length - 1;a > r[0] && a < r[i] ? (r.push(a), r.sort(), this._lastMap.get(t).set(s, r)) : this._addCurrentMap(e)
      } else this._addCurrentMap(e);return !0
    } }, { key: '_addCurrentMap', value(e) {
      const t = e.key; const n = e.message; const o = n.conversationID; const a = n.sequence; const s = o.replace(k.CONV_GROUP, '');this._currentMap.get(t).has(s) || this._currentMap.get(t).set(s, []), this._currentMap.get(t).get(s)
        .push(a)
    } }, { key: '_copyData', value(e) {
      if (!Ge(e)) {
        this._lastMap.set(e, new Map);let t; let n = this._lastMap.get(e); const o = S(this._currentMap.get(e));try {
          for (o.s();!(t = o.n()).done;) {
            const a = m(t.value, 2); const s = a[0]; const r = a[1];n.set(s, r)
          }
        } catch (i) {
          o.e(i)
        } finally {
          o.f()
        }n = null, this._currentMap.set(e, new Map)
      }
    } }, { key: 'getStatResult', value(e) {
      if (Ge(this._currentMap.get(e)) || Ge(this._lastMap.get(e))) return null;if (0 === this._lastMap.get(e).size) return this._copyData(e), null;let t = 0; let n = 0;if (this._lastMap.get(e).forEach(((e, o) => {
        const a = M(e.values()); const s = a.length; const r = a[s - 1] - a[0] + 1;t += r, n += s
      })), 0 === t) return null;let o = ut(n / t * 100, 2);return o > 100 && (o = 100), this._copyData(e), { totalCount: t, successCountOfMessageReceived: n, successRateOfMessageReceived: o }
    } }, { key: 'reset', value() {
      this._currentMap.clear(), this._lastMap.clear()
    } }]), e
  }()); const Yi = (function (e) {
    i(a, e);const n = f(a);function a(e) {
      let t;o(this, a), (t = n.call(this, e))._className = 'QualityStatModule', t.TAG = 'im-ssolog-quality-stat', t.reportIndex = 0, t.wholePeriod = !1, t._qualityItems = [ua, la, da, ga, pa, ha, _a, fa, ma, Ma], t.REPORT_INTERVAL = 120, t._statInfoArr = [], t._avgRTT = new Hi, t._avgE2EDelay = new Bi;const s = [da, ga, pa, ha, _a];t._rateMessageSend = new ji(s);const r = [fa, ma, Ma];t._rateMessageReceived = new $i(r);const i = t.getInnerEmitterInstance();return i.on(Ir.CONTEXT_A2KEY_AND_TINYID_UPDATED, t._onLoginSuccess, h(t)), i.on(Ir.CLOUD_CONFIG_UPDATED, t._onCloudConfigUpdate, h(t)), t
    } return s(a, [{ key: '_onLoginSuccess', value() {
      const e = this; const t = this.getModule(wt); const n = t.getItem(this.TAG, !1);!dt(n) && Pe(n.forEach) && (Ee.log(''.concat(this._className, '._onLoginSuccess.get quality stat log in storage, nums=').concat(n.length)), n.forEach(((t) => {
        e._statInfoArr.push(t)
      })), t.removeItem(this.TAG, !1))
    } }, { key: '_onCloudConfigUpdate', value() {
      const e = this.getCloudConfig('report_interval_quality');Ge(e) || (this.REPORT_INTERVAL = Number(e))
    } }, { key: 'onCheckTimer', value(e) {
      this.isLoggedIn() && e % this.REPORT_INTERVAL == 0 && (this.wholePeriod = !0, this._report())
    } }, { key: 'addRequestCount', value() {
      this._avgRTT.addRequestCount()
    } }, { key: 'addRTT', value(e) {
      this._avgRTT.addRTT(e)
    } }, { key: 'addMessageDelay', value(e) {
      this._avgE2EDelay.addMessageDelay(e)
    } }, { key: 'addTotalCount', value(e) {
      this._rateMessageSend.addTotalCount(e) || Ee.warn(''.concat(this._className, '.addTotalCount invalid key:'), e)
    } }, { key: 'addSuccessCount', value(e) {
      this._rateMessageSend.addSuccessCount(e) || Ee.warn(''.concat(this._className, '.addSuccessCount invalid key:'), e)
    } }, { key: 'addFailedCountOfUserSide', value(e) {
      this._rateMessageSend.addFailedCountOfUserSide(e) || Ee.warn(''.concat(this._className, '.addFailedCountOfUserSide invalid key:'), e)
    } }, { key: 'addCost', value(e, t) {
      this._rateMessageSend.addCost(e, t) || Ee.warn(''.concat(this._className, '.addCost invalid key or cost:'), e, t)
    } }, { key: 'addFileSize', value(e, t) {
      this._rateMessageSend.addFileSize(e, t) || Ee.warn(''.concat(this._className, '.addFileSize invalid key or size:'), e, t)
    } }, { key: 'addMessageSequence', value(e) {
      this._rateMessageReceived.addMessageSequence(e) || Ee.warn(''.concat(this._className, '.addMessageSequence invalid key:'), e.key)
    } }, { key: '_getQualityItem', value(e) {
      let n = {}; let o = Ia[this.getNetworkType()];Ge(o) && (o = 8);const a = { qualityType: va[e], timestamp: ye(), networkType: o, extension: '' };switch (e) {
        case ua:n = this._avgRTT.getStatResult();break;case la:n = this._avgE2EDelay.getStatResult();break;case da:case ga:case pa:case ha:case _a:n = this._rateMessageSend.getStatResult(e);break;case fa:case ma:case Ma:n = this._rateMessageReceived.getStatResult(e)
      } return null === n ? null : t(t({}, a), n)
    } }, { key: '_report', value(e) {
      const t = this; let n = []; let o = null;Ge(e) ? this._qualityItems.forEach(((e) => {
        null !== (o = t._getQualityItem(e)) && (o.reportIndex = t.reportIndex, o.wholePeriod = t.wholePeriod, n.push(o))
      })) : null !== (o = this._getQualityItem(e)) && (o.reportIndex = this.reportIndex, o.wholePeriod = this.wholePeriod, n.push(o)), Ee.debug(''.concat(this._className, '._report'), n), this._statInfoArr.length > 0 && (n = n.concat(this._statInfoArr), this._statInfoArr = []), n.length > 0 && this._doReport(n)
    } }, { key: '_doReport', value(e) {
      const n = this; const o = { header: ai(this), quality: e };this.request({ protocolName: Hn, requestData: t({}, o) }).then((() => {
        n.reportIndex++, n.wholePeriod = !1
      }))
        .catch(((t) => {
          Ee.warn(''.concat(n._className, '._doReport, online:').concat(n.getNetworkType(), ' error:'), t), n._statInfoArr = n._statInfoArr.concat(e), n._flushAtOnce()
        }))
    } }, { key: '_flushAtOnce', value() {
      const e = this.getModule(wt); const t = e.getItem(this.TAG, !1); const n = this._statInfoArr;if (dt(t))Ee.log(''.concat(this._className, '._flushAtOnce count:').concat(n.length)), e.setItem(this.TAG, n, !0, !1);else {
        let o = n.concat(t);o.length > 10 && (o = o.slice(0, 10)), Ee.log(''.concat(this.className, '._flushAtOnce count:').concat(o.length)), e.setItem(this.TAG, o, !0, !1)
      } this._statInfoArr = []
    } }, { key: 'reset', value() {
      Ee.log(''.concat(this._className, '.reset')), this._report(), this.reportIndex = 0, this.wholePeriod = !1, this._avgRTT.reset(), this._avgE2EDelay.reset(), this._rateMessageSend.reset(), this._rateMessageReceived.reset()
    } }]), a
  }(Yt)); const zi = (function () {
    function e(t) {
      o(this, e);const n = new Da(Ta);this._className = 'ModuleManager', this._isReady = !1, this._startLoginTs = 0, this._moduleMap = new Map, this._innerEmitter = null, this._outerEmitter = null, this._checkCount = 0, this._checkTimer = -1, this._moduleMap.set(Gt, new Zr(this, t)), this._moduleMap.set(Ht, new Ki(this)), this._moduleMap.set($t, new Yi(this)), this._moduleMap.set(xt, new Gi(this)), this._moduleMap.set(Kt, new qi(this)), this._moduleMap.set(Et, new ei(this)), this._moduleMap.set(kt, new fi(this)), this._moduleMap.set(Ct, new Qr(this)), this._moduleMap.set(Nt, new vr(this)), this._moduleMap.set(Rt, new Ur(this)), this._moduleMap.set(At, new $r(this)), this._moduleMap.set(Lt, new zr(this)), this._moduleMap.set(wt, new ni(this)), this._moduleMap.set(Pt, new si(this)), this._moduleMap.set(bt, new ci(this)), this._moduleMap.set(Ut, new li(this)), this._moduleMap.set(Ft, new di(this)), this._moduleMap.set(qt, new mi(this)), this._moduleMap.set(Vt, new Mi(this)), this._moduleMap.set(Bt, new Vi(this)), this._moduleMap.set(jt, new xi(this));const a = t.instanceID; const s = t.oversea; const r = t.SDKAppID; const i = 'instanceID:'.concat(a, ' oversea:').concat(s, ' host:')
        .concat(st(), ' ') + 'inBrowser:'.concat(W, ' inMiniApp:').concat(z, ' SDKAppID:')
        .concat(r, ' UserAgent:')
        .concat(Q);Da.bindEventStatModule(this._moduleMap.get(Pt)), n.setMessage(''.concat(i)).end(), Ee.info('SDK '.concat(i)), this._readyList = void 0, this._ssoLogForReady = null, this._initReadyList()
    } return s(e, [{ key: '_startTimer', value() {
      this._checkTimer < 0 && (this._checkTimer = setInterval(this._onCheckTimer.bind(this), 1e3))
    } }, { key: 'stopTimer', value() {
      this._checkTimer > 0 && (clearInterval(this._checkTimer), this._checkTimer = -1, this._checkCount = 0)
    } }, { key: '_onCheckTimer', value() {
      this._checkCount += 1;let e; const t = S(this._moduleMap);try {
        for (t.s();!(e = t.n()).done;) {
          const n = m(e.value, 2)[1];n.onCheckTimer && n.onCheckTimer(this._checkCount)
        }
      } catch (o) {
        t.e(o)
      } finally {
        t.f()
      }
    } }, { key: '_initReadyList', value() {
      const e = this;this._readyList = [this._moduleMap.get(Et), this._moduleMap.get(Rt)], this._readyList.forEach(((t) => {
        t.ready((() => e._onModuleReady()))
      }))
    } }, { key: '_onModuleReady', value() {
      let e = !0;if (this._readyList.forEach(((t) => {
        t.isReady() || (e = !1)
      })), e && !this._isReady) {
        this._isReady = !0, this._outerEmitter.emit(E.SDK_READY);const t = Date.now() - this._startLoginTs;Ee.warn('SDK is ready. cost '.concat(t, ' ms')), this._startLoginTs = Date.now();const n = this._moduleMap.get(bt).getNetworkType(); const o = this._ssoLogForReady.getStartTs() + ve;this._ssoLogForReady.setNetworkType(n).setMessage(t)
          .start(o)
          .end()
      }
    } }, { key: 'login', value() {
      0 === this._startLoginTs && (Ie(), this._startLoginTs = Date.now(), this._startTimer(), this._moduleMap.get(bt).start(), this._ssoLogForReady = new Da(Sa))
    } }, { key: 'onLoginFailed', value() {
      this._startLoginTs = 0
    } }, { key: 'getOuterEmitterInstance', value() {
      return null === this._outerEmitter && (this._outerEmitter = new ui, fr(this._outerEmitter), this._outerEmitter._emit = this._outerEmitter.emit, this._outerEmitter.emit = function (e, t) {
        const n = arguments[0]; const o = [n, { name: arguments[0], data: arguments[1] }];this._outerEmitter._emit.apply(this._outerEmitter, o)
      }.bind(this)), this._outerEmitter
    } }, { key: 'getInnerEmitterInstance', value() {
      return null === this._innerEmitter && (this._innerEmitter = new ui, this._innerEmitter._emit = this._innerEmitter.emit, this._innerEmitter.emit = function (e, t) {
        let n;Le(arguments[1]) && arguments[1].data ? (Ee.warn('inner eventData has data property, please check!'), n = [e, { name: arguments[0], data: arguments[1].data }]) : n = [e, { name: arguments[0], data: arguments[1] }], this._innerEmitter._emit.apply(this._innerEmitter, n)
      }.bind(this)), this._innerEmitter
    } }, { key: 'hasModule', value(e) {
      return this._moduleMap.has(e)
    } }, { key: 'getModule', value(e) {
      return this._moduleMap.get(e)
    } }, { key: 'isReady', value() {
      return this._isReady
    } }, { key: 'onError', value(e) {
      Ee.warn('Oops! code:'.concat(e.code, ' message:').concat(e.message)), new Da(Fs).setMessage('code:'.concat(e.code, ' message:').concat(e.message))
        .setNetworkType(this.getModule(bt).getNetworkType())
        .setLevel('error')
        .end(), this.getOuterEmitterInstance().emit(E.ERROR, e)
    } }, { key: 'reset', value() {
      Ee.log(''.concat(this._className, '.reset')), Ie();let e; const t = S(this._moduleMap);try {
        for (t.s();!(e = t.n()).done;) {
          const n = m(e.value, 2)[1];n.reset && n.reset()
        }
      } catch (o) {
        t.e(o)
      } finally {
        t.f()
      } this._startLoginTs = 0, this._initReadyList(), this._isReady = !1, this.stopTimer(), this._outerEmitter.emit(E.SDK_NOT_READY)
    } }]), e
  }()); const Wi = (function () {
    function e() {
      o(this, e), this._funcMap = new Map
    } return s(e, [{ key: 'defense', value(e, t) {
      const n = arguments.length > 2 && void 0 !== arguments[2] ? arguments[2] : void 0;if ('string' !== typeof e) return null;if (0 === e.length) return null;if ('function' !== typeof t) return null;if (this._funcMap.has(e) && this._funcMap.get(e).has(t)) return this._funcMap.get(e).get(t);this._funcMap.has(e) || this._funcMap.set(e, new Map);let o = null;return this._funcMap.get(e).has(t) ? o = this._funcMap.get(e).get(t) : (o = this._pack(e, t, n), this._funcMap.get(e).set(t, o)), o
    } }, { key: 'defenseOnce', value(e, t) {
      const n = arguments.length > 2 && void 0 !== arguments[2] ? arguments[2] : void 0;return 'function' !== typeof t ? null : this._pack(e, t, n)
    } }, { key: 'find', value(e, t) {
      return 'string' !== typeof e || 0 === e.length || 'function' !== typeof t ? null : this._funcMap.has(e) ? this._funcMap.get(e).has(t) ? this._funcMap.get(e).get(t) : (Ee.log('SafetyCallback.find: 找不到 func —— '.concat(e, '/').concat('' !== t.name ? t.name : '[anonymous]')), null) : (Ee.log('SafetyCallback.find: 找不到 eventName-'.concat(e, ' 对应的 func')), null)
    } }, { key: 'delete', value(e, t) {
      return 'function' === typeof t && (!!this._funcMap.has(e) && (!!this._funcMap.get(e).has(t) && (this._funcMap.get(e).delete(t), 0 === this._funcMap.get(e).size && this._funcMap.delete(e), !0)))
    } }, { key: '_pack', value(e, t, n) {
      return function () {
        try {
          t.apply(n, Array.from(arguments))
        } catch (r) {
          const o = Object.values(E).indexOf(e);if (-1 !== o) {
            const a = Object.keys(E)[o];Ee.warn('接入侧事件 TIM.EVENT.'.concat(a, ' 对应的回调函数逻辑存在问题，请检查！'), r)
          } const s = new Da(Ps);s.setMessage('eventName:'.concat(e)).setMoreMessage(r.message)
            .end()
        }
      }
    } }]), e
  }()); const Ji = (function () {
    function e(t) {
      o(this, e);const n = { SDKAppID: t.SDKAppID, unlimitedAVChatRoom: t.unlimitedAVChatRoom || !1, scene: t.scene || '', oversea: t.oversea || !1, instanceID: at() };this._moduleManager = new zi(n), this._safetyCallbackFactory = new Wi
    } return s(e, [{ key: 'isReady', value() {
      return this._moduleManager.isReady()
    } }, { key: 'onError', value(e) {
      this._moduleManager.onError(e)
    } }, { key: 'login', value(e) {
      return this._moduleManager.login(), this._moduleManager.getModule(Et).login(e)
    } }, { key: 'logout', value() {
      const e = this;return this._moduleManager.getModule(Et).logout()
        .then(((t) => (e._moduleManager.reset(), t)))
    } }, { key: 'destroy', value() {
      const e = this;return this.logout().finally((() => {
        e._moduleManager.stopTimer(), e._moduleManager.getModule(xt).dealloc();const t = e._moduleManager.getOuterEmitterInstance(); const n = e._moduleManager.getModule(Gt);t.emit(E.SDK_DESTROY, { SDKAppID: n.getSDKAppID() })
      }))
    } }, { key: 'on', value(e, t, n) {
      e === E.GROUP_SYSTEM_NOTICE_RECEIVED && Ee.warn('！！！TIM.EVENT.GROUP_SYSTEM_NOTICE_RECEIVED v2.6.0起弃用，为了更好的体验，请在 TIM.EVENT.MESSAGE_RECEIVED 事件回调内接收处理群系统通知，详细请参考：https://web.sdk.qcloud.com/im/doc/zh-cn/Message.html#.GroupSystemNoticePayload'), Ee.debug('on', 'eventName:'.concat(e)), this._moduleManager.getOuterEmitterInstance().on(e, this._safetyCallbackFactory.defense(e, t, n), n)
    } }, { key: 'once', value(e, t, n) {
      Ee.debug('once', 'eventName:'.concat(e)), this._moduleManager.getOuterEmitterInstance().once(e, this._safetyCallbackFactory.defenseOnce(e, t, n), n || this)
    } }, { key: 'off', value(e, t, n, o) {
      Ee.debug('off', 'eventName:'.concat(e));const a = this._safetyCallbackFactory.find(e, t);null !== a && (this._moduleManager.getOuterEmitterInstance().off(e, a, n, o), this._safetyCallbackFactory.delete(e, t))
    } }, { key: 'registerPlugin', value(e) {
      this._moduleManager.getModule(qt).registerPlugin(e)
    } }, { key: 'setLogLevel', value(e) {
      if (e <= 0) {
        console.log(['', ' ________  ______  __       __  __       __  ________  _______', '|        \\|      \\|  \\     /  \\|  \\  _  |  \\|        \\|       \\', ' \\$$$$$$$$ \\$$$$$$| $$\\   /  $$| $$ / \\ | $$| $$$$$$$$| $$$$$$$\\', '   | $$     | $$  | $$$\\ /  $$$| $$/  $\\| $$| $$__    | $$__/ $$', '   | $$     | $$  | $$$$\\  $$$$| $$  $$$\\ $$| $$  \\   | $$    $$', '   | $$     | $$  | $$\\$$ $$ $$| $$ $$\\$$\\$$| $$$$$   | $$$$$$$\\', '   | $$    _| $$_ | $$ \\$$$| $$| $$$$  \\$$$$| $$_____ | $$__/ $$', '   | $$   |   $$ \\| $$  \\$ | $$| $$$    \\$$$| $$     \\| $$    $$', '    \\$$    \\$$$$$$ \\$$      \\$$ \\$$      \\$$ \\$$$$$$$$ \\$$$$$$$', '', ''].join('\n')), console.log('%cIM 智能客服，随时随地解决您的问题 →_→ https://cloud.tencent.com/act/event/smarty-service?from=im-doc', 'color:#006eff'), console.log('%c从v2.11.2起，SDK 支持了 WebSocket，小程序需要添加受信域名！升级指引: https://web.sdk.qcloud.com/im/doc/zh-cn/tutorial-02-upgradeguideline.html', 'color:#ff0000');console.log(['', '参考以下文档，会更快解决问题哦！(#^.^#)\n', 'SDK 更新日志: https://cloud.tencent.com/document/product/269/38492\n', 'SDK 接口文档: https://web.sdk.qcloud.com/im/doc/zh-cn/SDK.html\n', '常见问题: https://web.sdk.qcloud.com/im/doc/zh-cn/tutorial-01-faq.html\n', '反馈问题？戳我提 issue: https://github.com/tencentyun/TIMSDK/issues\n', '如果您需要在生产环境关闭上面的日志，请 tim.setLogLevel(1)\n'].join('\n'))
      }Ee.setLevel(e)
    } }, { key: 'createTextMessage', value(e) {
      return this._moduleManager.getModule(kt).createTextMessage(e)
    } }, { key: 'createTextAtMessage', value(e) {
      return this._moduleManager.getModule(kt).createTextMessage(e)
    } }, { key: 'createImageMessage', value(e) {
      return this._moduleManager.getModule(kt).createImageMessage(e)
    } }, { key: 'createAudioMessage', value(e) {
      return this._moduleManager.getModule(kt).createAudioMessage(e)
    } }, { key: 'createVideoMessage', value(e) {
      return this._moduleManager.getModule(kt).createVideoMessage(e)
    } }, { key: 'createCustomMessage', value(e) {
      return this._moduleManager.getModule(kt).createCustomMessage(e)
    } }, { key: 'createFaceMessage', value(e) {
      return this._moduleManager.getModule(kt).createFaceMessage(e)
    } }, { key: 'createFileMessage', value(e) {
      return this._moduleManager.getModule(kt).createFileMessage(e)
    } }, { key: 'createMergerMessage', value(e) {
      return this._moduleManager.getModule(kt).createMergerMessage(e)
    } }, { key: 'downloadMergerMessage', value(e) {
      return e.type !== k.MSG_MERGER ? Mr(new hr({ code: Zn.MESSAGE_MERGER_TYPE_INVALID, message: No })) : dt(e.payload.downloadKey) ? Mr(new hr({ code: Zn.MESSAGE_MERGER_KEY_INVALID, message: Ao })) : this._moduleManager.getModule(kt).downloadMergerMessage(e)
        .catch(((e) => Mr(new hr({ code: Zn.MESSAGE_MERGER_DOWNLOAD_FAIL, message: Oo }))))
    } }, { key: 'createForwardMessage', value(e) {
      return this._moduleManager.getModule(kt).createForwardMessage(e)
    } }, { key: 'sendMessage', value(e, t) {
      return e instanceof ir ? this._moduleManager.getModule(kt).sendMessageInstance(e, t) : Mr(new hr({ code: Zn.MESSAGE_SEND_NEED_MESSAGE_INSTANCE, message: uo }))
    } }, { key: 'callExperimentalAPI', value(e, t) {
      return 'handleGroupInvitation' === e ? this._moduleManager.getModule(At).handleGroupInvitation(t) : Mr(new hr({ code: Zn.INVALID_OPERATION, message: aa }))
    } }, { key: 'revokeMessage', value(e) {
      return this._moduleManager.getModule(kt).revokeMessage(e)
    } }, { key: 'resendMessage', value(e) {
      return this._moduleManager.getModule(kt).resendMessage(e)
    } }, { key: 'deleteMessage', value(e) {
      return this._moduleManager.getModule(kt).deleteMessage(e)
    } }, { key: 'getMessageList', value(e) {
      return this._moduleManager.getModule(Rt).getMessageList(e)
    } }, { key: 'setMessageRead', value(e) {
      return this._moduleManager.getModule(Rt).setMessageRead(e)
    } }, { key: 'getConversationList', value() {
      return this._moduleManager.getModule(Rt).getConversationList()
    } }, { key: 'getConversationProfile', value(e) {
      return this._moduleManager.getModule(Rt).getConversationProfile(e)
    } }, { key: 'deleteConversation', value(e) {
      return this._moduleManager.getModule(Rt).deleteConversation(e)
    } }, { key: 'getMyProfile', value() {
      return this._moduleManager.getModule(Ct).getMyProfile()
    } }, { key: 'getUserProfile', value(e) {
      return this._moduleManager.getModule(Ct).getUserProfile(e)
    } }, { key: 'updateMyProfile', value(e) {
      return this._moduleManager.getModule(Ct).updateMyProfile(e)
    } }, { key: 'getBlacklist', value() {
      return this._moduleManager.getModule(Ct).getLocalBlacklist()
    } }, { key: 'addToBlacklist', value(e) {
      return this._moduleManager.getModule(Ct).addBlacklist(e)
    } }, { key: 'removeFromBlacklist', value(e) {
      return this._moduleManager.getModule(Ct).deleteBlacklist(e)
    } }, { key: 'getFriendList', value() {
      const e = this._moduleManager.getModule(Ot);return e ? e.getLocalFriendList() : Mr({ code: Zn.CANNOT_FIND_MODULE, message: ra })
    } }, { key: 'addFriend', value(e) {
      const t = this._moduleManager.getModule(Ot);return t ? t.addFriend(e) : Mr({ code: Zn.CANNOT_FIND_MODULE, message: ra })
    } }, { key: 'deleteFriend', value(e) {
      const t = this._moduleManager.getModule(Ot);return t ? t.deleteFriend(e) : Mr({ code: Zn.CANNOT_FIND_MODULE, message: ra })
    } }, { key: 'checkFriend', value(e) {
      const t = this._moduleManager.getModule(Ot);return t ? t.checkFriend(e) : Mr({ code: Zn.CANNOT_FIND_MODULE, message: ra })
    } }, { key: 'getFriendProfile', value(e) {
      const t = this._moduleManager.getModule(Ot);return t ? t.getFriendProfile(e) : Mr({ code: Zn.CANNOT_FIND_MODULE, message: ra })
    } }, { key: 'updateFriend', value(e) {
      const t = this._moduleManager.getModule(Ot);return t ? t.updateFriend(e) : Mr({ code: Zn.CANNOT_FIND_MODULE, message: ra })
    } }, { key: 'getFriendApplicationList', value() {
      const e = this._moduleManager.getModule(Ot);return e ? e.getLocalFriendApplicationList() : Mr({ code: Zn.CANNOT_FIND_MODULE, message: ra })
    } }, { key: 'acceptFriendApplication', value(e) {
      const t = this._moduleManager.getModule(Ot);return t ? t.acceptFriendApplication(e) : Mr({ code: Zn.CANNOT_FIND_MODULE, message: ra })
    } }, { key: 'refuseFriendApplication', value(e) {
      const t = this._moduleManager.getModule(Ot);return t ? t.refuseFriendApplication(e) : Mr({ code: Zn.CANNOT_FIND_MODULE, message: ra })
    } }, { key: 'deleteFriendApplication', value(e) {
      const t = this._moduleManager.getModule(Ot);return t ? t.deleteFriendApplication(e) : Mr({ code: Zn.CANNOT_FIND_MODULE, message: ra })
    } }, { key: 'setFriendApplicationRead', value() {
      const e = this._moduleManager.getModule(Ot);return e ? e.setFriendApplicationRead() : Mr({ code: Zn.CANNOT_FIND_MODULE, message: ra })
    } }, { key: 'getFriendGroupList', value() {
      const e = this._moduleManager.getModule(Ot);return e ? e.getLocalFriendGroupList() : Mr({ code: Zn.CANNOT_FIND_MODULE, message: ra })
    } }, { key: 'createFriendGroup', value(e) {
      const t = this._moduleManager.getModule(Ot);return t ? t.createFriendGroup(e) : Mr({ code: Zn.CANNOT_FIND_MODULE, message: ra })
    } }, { key: 'deleteFriendGroup', value(e) {
      const t = this._moduleManager.getModule(Ot);return t ? t.deleteFriendGroup(e) : Mr({ code: Zn.CANNOT_FIND_MODULE, message: ra })
    } }, { key: 'addToFriendGroup', value(e) {
      const t = this._moduleManager.getModule(Ot);return t ? t.addToFriendGroup(e) : Mr({ code: Zn.CANNOT_FIND_MODULE, message: ra })
    } }, { key: 'removeFromFriendGroup', value(e) {
      const t = this._moduleManager.getModule(Ot);return t ? t.removeFromFriendGroup(e) : Mr({ code: Zn.CANNOT_FIND_MODULE, message: ra })
    } }, { key: 'renameFriendGroup', value(e) {
      const t = this._moduleManager.getModule(Ot);return t ? t.renameFriendGroup(e) : Mr({ code: Zn.CANNOT_FIND_MODULE, message: ra })
    } }, { key: 'getGroupList', value(e) {
      return this._moduleManager.getModule(At).getGroupList(e)
    } }, { key: 'getGroupProfile', value(e) {
      return this._moduleManager.getModule(At).getGroupProfile(e)
    } }, { key: 'createGroup', value(e) {
      return this._moduleManager.getModule(At).createGroup(e)
    } }, { key: 'dismissGroup', value(e) {
      return this._moduleManager.getModule(At).dismissGroup(e)
    } }, { key: 'updateGroupProfile', value(e) {
      return this._moduleManager.getModule(At).updateGroupProfile(e)
    } }, { key: 'joinGroup', value(e) {
      return this._moduleManager.getModule(At).joinGroup(e)
    } }, { key: 'quitGroup', value(e) {
      return this._moduleManager.getModule(At).quitGroup(e)
    } }, { key: 'searchGroupByID', value(e) {
      return this._moduleManager.getModule(At).searchGroupByID(e)
    } }, { key: 'getGroupOnlineMemberCount', value(e) {
      return this._moduleManager.getModule(At).getGroupOnlineMemberCount(e)
    } }, { key: 'changeGroupOwner', value(e) {
      return this._moduleManager.getModule(At).changeGroupOwner(e)
    } }, { key: 'handleGroupApplication', value(e) {
      return this._moduleManager.getModule(At).handleGroupApplication(e)
    } }, { key: 'getGroupMemberList', value(e) {
      return this._moduleManager.getModule(Lt).getGroupMemberList(e)
    } }, { key: 'getGroupMemberProfile', value(e) {
      return this._moduleManager.getModule(Lt).getGroupMemberProfile(e)
    } }, { key: 'addGroupMember', value(e) {
      return this._moduleManager.getModule(Lt).addGroupMember(e)
    } }, { key: 'deleteGroupMember', value(e) {
      return this._moduleManager.getModule(Lt).deleteGroupMember(e)
    } }, { key: 'setGroupMemberMuteTime', value(e) {
      return this._moduleManager.getModule(Lt).setGroupMemberMuteTime(e)
    } }, { key: 'setGroupMemberRole', value(e) {
      return this._moduleManager.getModule(Lt).setGroupMemberRole(e)
    } }, { key: 'setGroupMemberNameCard', value(e) {
      return this._moduleManager.getModule(Lt).setGroupMemberNameCard(e)
    } }, { key: 'setGroupMemberCustomField', value(e) {
      return this._moduleManager.getModule(Lt).setGroupMemberCustomField(e)
    } }, { key: 'setMessageRemindType', value(e) {
      return this._moduleManager.getModule(Lt).setMessageRemindType(e)
    } }]), e
  }()); const Xi = { login: 'login', logout: 'logout', destroy: 'destroy', on: 'on', off: 'off', ready: 'ready', setLogLevel: 'setLogLevel', joinGroup: 'joinGroup', quitGroup: 'quitGroup', registerPlugin: 'registerPlugin', getGroupOnlineMemberCount: 'getGroupOnlineMemberCount' };function Qi(e, t) {
    if (e.isReady() || void 0 !== Xi[t]) return !0;const n = new hr({ code: Zn.SDK_IS_NOT_READY, message: ''.concat(t, ' ').concat(ia, '，请参考 https://web.sdk.qcloud.com/im/doc/zh-cn/module-EVENT.html#.SDK_READY') });return e.onError(n), !1
  } const Zi = {}; const ec = {};return ec.create = function (e) {
    let n = 0;if (Ne(e.SDKAppID))n = e.SDKAppID;else if (Ee.warn('TIM.create SDKAppID 的类型应该为 Number，请修改！'), n = parseInt(e.SDKAppID), isNaN(n)) return Ee.error('TIM.create failed. 解析 SDKAppID 失败，请检查传参！'), null;if (n && Zi[n]) return Zi[n];Ee.log('TIM.create');const o = new Ji(t(t({}, e), {}, { SDKAppID: n }));o.on(E.SDK_DESTROY, ((e) => {
      Zi[e.data.SDKAppID] = null, delete Zi[e.data.SDKAppID]
    }));const a = (function (e) {
      const t = Object.create(null);return Object.keys(St).forEach(((n) => {
        if (e[n]) {
          const o = St[n]; const a = new C;t[o] = function () {
            const t = Array.from(arguments);return a.use(((t, o) => (Qi(e, n) ? o() : Mr(new hr({ code: Zn.SDK_IS_NOT_READY, message: ''.concat(n, ' ').concat(ia, '。') }))))).use(((e, t) => {
              if (!0 === gt(e, Tt[n], o)) return t()
            }))
              .use(((t, o) => e[n].apply(e, t))), a.run(t)
          }
        }
      })), t
    }(o));return Zi[n] = a, Ee.log('TIM.create ok'), a
  }, ec.TYPES = k, ec.EVENT = E, ec.VERSION = '2.12.2', Ee.log('TIM.VERSION: '.concat(ec.VERSION)), ec
})))
