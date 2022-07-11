'use strict';!(function (e, t) {
  'object' === typeof exports && 'undefined' !== typeof module ? module.exports = t() : 'function' === typeof define && define.amd ? define(t) : (e = e || self).TIM = t();
}(this, (() => {
  function e(t) {
    return (e = 'function' === typeof Symbol && 'symbol' === typeof Symbol.iterator ? function (e) {
      return typeof e;
    } : function (e) {
      return e && 'function' === typeof Symbol && e.constructor === Symbol && e !== Symbol.prototype ? 'symbol' : typeof e;
    })(t);
  } function t(e, t) {
    if (!(e instanceof t)) throw new TypeError('Cannot call a class as a function');
  } function n(e, t) {
    for (let n = 0;n < t.length;n++) {
      const o = t[n];o.enumerable = o.enumerable || !1, o.configurable = !0, 'value' in o && (o.writable = !0), Object.defineProperty(e, o.key, o);
    }
  } function o(e, t, o) {
    return t && n(e.prototype, t), o && n(e, o), e;
  } function a(e, t, n) {
    return t in e ? Object.defineProperty(e, t, { value: n, enumerable: !0, configurable: !0, writable: !0 }) : e[t] = n, e;
  } function s(e, t) {
    const n = Object.keys(e);if (Object.getOwnPropertySymbols) {
      let o = Object.getOwnPropertySymbols(e);t && (o = o.filter((t => Object.getOwnPropertyDescriptor(e, t).enumerable))), n.push.apply(n, o);
    } return n;
  } function r(e) {
    for (let t = 1;t < arguments.length;t++) {
      var n = null != arguments[t] ? arguments[t] : {};t % 2 ? s(Object(n), !0).forEach(((t) => {
        a(e, t, n[t]);
      })) : Object.getOwnPropertyDescriptors ? Object.defineProperties(e, Object.getOwnPropertyDescriptors(n)) : s(Object(n)).forEach(((t) => {
        Object.defineProperty(e, t, Object.getOwnPropertyDescriptor(n, t));
      }));
    } return e;
  } function i(e, t) {
    if ('function' !== typeof t && null !== t) throw new TypeError('Super expression must either be null or a function');e.prototype = Object.create(t && t.prototype, { constructor: { value: e, writable: !0, configurable: !0 } }), t && u(e, t);
  } function c(e) {
    return (c = Object.setPrototypeOf ? Object.getPrototypeOf : function (e) {
      return e.__proto__ || Object.getPrototypeOf(e);
    })(e);
  } function u(e, t) {
    return (u = Object.setPrototypeOf || function (e, t) {
      return e.__proto__ = t, e;
    })(e, t);
  } function l() {
    if ('undefined' === typeof Reflect || !Reflect.construct) return !1;if (Reflect.construct.sham) return !1;if ('function' === typeof Proxy) return !0;try {
      return Date.prototype.toString.call(Reflect.construct(Date, [], (() => {}))), !0;
    } catch (e) {
      return !1;
    }
  } function d(e, t, n) {
    return (d = l() ? Reflect.construct : function (e, t, n) {
      const o = [null];o.push.apply(o, t);const a = new (Function.bind.apply(e, o));return n && u(a, n.prototype), a;
    }).apply(null, arguments);
  } function p(e) {
    const t = 'function' === typeof Map ? new Map : void 0;return (p = function (e) {
      if (null === e || (n = e, -1 === Function.toString.call(n).indexOf('[native code]'))) return e;let n;if ('function' !== typeof e) throw new TypeError('Super expression must either be null or a function');if (void 0 !== t) {
        if (t.has(e)) return t.get(e);t.set(e, o);
      } function o() {
        return d(e, arguments, c(this).constructor);
      } return o.prototype = Object.create(e.prototype, { constructor: { value: o, enumerable: !1, writable: !0, configurable: !0 } }), u(o, e);
    })(e);
  } function g(e, t) {
    if (null == e) return {};let n; let o; const a = (function (e, t) {
      if (null == e) return {};let n; let o; const a = {}; const s = Object.keys(e);for (o = 0;o < s.length;o++)n = s[o], t.indexOf(n) >= 0 || (a[n] = e[n]);return a;
    }(e, t));if (Object.getOwnPropertySymbols) {
      const s = Object.getOwnPropertySymbols(e);for (o = 0;o < s.length;o++)n = s[o], t.indexOf(n) >= 0 || Object.prototype.propertyIsEnumerable.call(e, n) && (a[n] = e[n]);
    } return a;
  } function h(e) {
    if (void 0 === e) throw new ReferenceError('this hasn\'t been initialised - super() hasn\'t been called');return e;
  } function _(e, t) {
    return !t || 'object' !== typeof t && 'function' !== typeof t ? h(e) : t;
  } function f(e) {
    const t = l();return function () {
      let n; const o = c(e);if (t) {
        const a = c(this).constructor;n = Reflect.construct(o, arguments, a);
      } else n = o.apply(this, arguments);return _(this, n);
    };
  } function m(e, t) {
    return v(e) || (function (e, t) {
      if ('undefined' === typeof Symbol || !(Symbol.iterator in Object(e))) return;const n = []; let o = !0; let a = !1; let s = void 0;try {
        for (var r, i = e[Symbol.iterator]();!(o = (r = i.next()).done) && (n.push(r.value), !t || n.length !== t);o = !0);
      } catch (c) {
        a = !0, s = c;
      } finally {
        try {
          o || null == i.return || i.return();
        } finally {
          if (a) throw s;
        }
      } return n;
    }(e, t)) || I(e, t) || T();
  } function M(e) {
    return (function (e) {
      if (Array.isArray(e)) return C(e);
    }(e)) || y(e) || I(e) || (function () {
      throw new TypeError('Invalid attempt to spread non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method.');
    }());
  } function v(e) {
    if (Array.isArray(e)) return e;
  } function y(e) {
    if ('undefined' !== typeof Symbol && Symbol.iterator in Object(e)) return Array.from(e);
  } function I(e, t) {
    if (e) {
      if ('string' === typeof e) return C(e, t);let n = Object.prototype.toString.call(e).slice(8, -1);return 'Object' === n && e.constructor && (n = e.constructor.name), 'Map' === n || 'Set' === n ? Array.from(e) : 'Arguments' === n || /^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n) ? C(e, t) : void 0;
    }
  } function C(e, t) {
    (null == t || t > e.length) && (t = e.length);for (var n = 0, o = new Array(t);n < t;n++)o[n] = e[n];return o;
  } function T() {
    throw new TypeError('Invalid attempt to destructure non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method.');
  } function S(e, t) {
    let n;if ('undefined' === typeof Symbol || null == e[Symbol.iterator]) {
      if (Array.isArray(e) || (n = I(e)) || t && e && 'number' === typeof e.length) {
        n && (e = n);let o = 0; const a = function () {};return { s: a, n() {
          return o >= e.length ? { done: !0 } : { done: !1, value: e[o++] };
        }, e(e) {
          throw e;
        }, f: a };
      } throw new TypeError('Invalid attempt to iterate non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method.');
    } let s; let r = !0; let i = !1;return { s() {
      n = e[Symbol.iterator]();
    }, n() {
      const e = n.next();return r = e.done, e;
    }, e(e) {
      i = !0, s = e;
    }, f() {
      try {
        r || null == n.return || n.return();
      } finally {
        if (i) throw s;
      }
    } };
  } const D = { SDK_READY: 'sdkStateReady', SDK_NOT_READY: 'sdkStateNotReady', SDK_DESTROY: 'sdkDestroy', MESSAGE_RECEIVED: 'onMessageReceived', MESSAGE_MODIFIED: 'onMessageModified', MESSAGE_REVOKED: 'onMessageRevoked', MESSAGE_READ_BY_PEER: 'onMessageReadByPeer', CONVERSATION_LIST_UPDATED: 'onConversationListUpdated', GROUP_LIST_UPDATED: 'onGroupListUpdated', GROUP_SYSTEM_NOTICE_RECEIVED: 'receiveGroupSystemNotice', GROUP_ATTRIBUTES_UPDATED: 'groupAttributesUpdated', PROFILE_UPDATED: 'onProfileUpdated', BLACKLIST_UPDATED: 'blacklistUpdated', FRIEND_LIST_UPDATED: 'onFriendListUpdated', FRIEND_GROUP_LIST_UPDATED: 'onFriendGroupListUpdated', FRIEND_APPLICATION_LIST_UPDATED: 'onFriendApplicationListUpdated', KICKED_OUT: 'kickedOut', ERROR: 'error', NET_STATE_CHANGE: 'netStateChange', SDK_RELOAD: 'sdkReload' }; const k = { MSG_TEXT: 'TIMTextElem', MSG_IMAGE: 'TIMImageElem', MSG_SOUND: 'TIMSoundElem', MSG_AUDIO: 'TIMSoundElem', MSG_FILE: 'TIMFileElem', MSG_FACE: 'TIMFaceElem', MSG_VIDEO: 'TIMVideoFileElem', MSG_GEO: 'TIMLocationElem', MSG_LOCATION: 'TIMLocationElem', MSG_GRP_TIP: 'TIMGroupTipElem', MSG_GRP_SYS_NOTICE: 'TIMGroupSystemNoticeElem', MSG_CUSTOM: 'TIMCustomElem', MSG_MERGER: 'TIMRelayElem', MSG_PRIORITY_HIGH: 'High', MSG_PRIORITY_NORMAL: 'Normal', MSG_PRIORITY_LOW: 'Low', MSG_PRIORITY_LOWEST: 'Lowest', CONV_C2C: 'C2C', CONV_GROUP: 'GROUP', CONV_SYSTEM: '@TIM#SYSTEM', CONV_AT_ME: 1, CONV_AT_ALL: 2, CONV_AT_ALL_AT_ME: 3, GRP_PRIVATE: 'Private', GRP_WORK: 'Private', GRP_PUBLIC: 'Public', GRP_CHATROOM: 'ChatRoom', GRP_MEETING: 'ChatRoom', GRP_AVCHATROOM: 'AVChatRoom', GRP_MBR_ROLE_OWNER: 'Owner', GRP_MBR_ROLE_ADMIN: 'Admin', GRP_MBR_ROLE_MEMBER: 'Member', GRP_TIP_MBR_JOIN: 1, GRP_TIP_MBR_QUIT: 2, GRP_TIP_MBR_KICKED_OUT: 3, GRP_TIP_MBR_SET_ADMIN: 4, GRP_TIP_MBR_CANCELED_ADMIN: 5, GRP_TIP_GRP_PROFILE_UPDATED: 6, GRP_TIP_MBR_PROFILE_UPDATED: 7, MSG_REMIND_ACPT_AND_NOTE: 'AcceptAndNotify', MSG_REMIND_ACPT_NOT_NOTE: 'AcceptNotNotify', MSG_REMIND_DISCARD: 'Discard', GENDER_UNKNOWN: 'Gender_Type_Unknown', GENDER_FEMALE: 'Gender_Type_Female', GENDER_MALE: 'Gender_Type_Male', KICKED_OUT_MULT_ACCOUNT: 'multipleAccount', KICKED_OUT_MULT_DEVICE: 'multipleDevice', KICKED_OUT_USERSIG_EXPIRED: 'userSigExpired', ALLOW_TYPE_ALLOW_ANY: 'AllowType_Type_AllowAny', ALLOW_TYPE_NEED_CONFIRM: 'AllowType_Type_NeedConfirm', ALLOW_TYPE_DENY_ANY: 'AllowType_Type_DenyAny', FORBID_TYPE_NONE: 'AdminForbid_Type_None', FORBID_TYPE_SEND_OUT: 'AdminForbid_Type_SendOut', JOIN_OPTIONS_FREE_ACCESS: 'FreeAccess', JOIN_OPTIONS_NEED_PERMISSION: 'NeedPermission', JOIN_OPTIONS_DISABLE_APPLY: 'DisableApply', JOIN_STATUS_SUCCESS: 'JoinedSuccess', JOIN_STATUS_ALREADY_IN_GROUP: 'AlreadyInGroup', JOIN_STATUS_WAIT_APPROVAL: 'WaitAdminApproval', GRP_PROFILE_OWNER_ID: 'ownerID', GRP_PROFILE_CREATE_TIME: 'createTime', GRP_PROFILE_LAST_INFO_TIME: 'lastInfoTime', GRP_PROFILE_MEMBER_NUM: 'memberNum', GRP_PROFILE_MAX_MEMBER_NUM: 'maxMemberNum', GRP_PROFILE_JOIN_OPTION: 'joinOption', GRP_PROFILE_INTRODUCTION: 'introduction', GRP_PROFILE_NOTIFICATION: 'notification', GRP_PROFILE_MUTE_ALL_MBRS: 'muteAllMembers', SNS_ADD_TYPE_SINGLE: 'Add_Type_Single', SNS_ADD_TYPE_BOTH: 'Add_Type_Both', SNS_DELETE_TYPE_SINGLE: 'Delete_Type_Single', SNS_DELETE_TYPE_BOTH: 'Delete_Type_Both', SNS_APPLICATION_TYPE_BOTH: 'Pendency_Type_Both', SNS_APPLICATION_SENT_TO_ME: 'Pendency_Type_ComeIn', SNS_APPLICATION_SENT_BY_ME: 'Pendency_Type_SendOut', SNS_APPLICATION_AGREE: 'Response_Action_Agree', SNS_APPLICATION_AGREE_AND_ADD: 'Response_Action_AgreeAndAdd', SNS_CHECK_TYPE_BOTH: 'CheckResult_Type_Both', SNS_CHECK_TYPE_SINGLE: 'CheckResult_Type_Single', SNS_TYPE_NO_RELATION: 'CheckResult_Type_NoRelation', SNS_TYPE_A_WITH_B: 'CheckResult_Type_AWithB', SNS_TYPE_B_WITH_A: 'CheckResult_Type_BWithA', SNS_TYPE_BOTH_WAY: 'CheckResult_Type_BothWay', NET_STATE_CONNECTED: 'connected', NET_STATE_CONNECTING: 'connecting', NET_STATE_DISCONNECTED: 'disconnected', MSG_AT_ALL: '__kImSDK_MesssageAtALL__', READ_ALL_C2C_MSG: 'readAllC2CMessage', READ_ALL_GROUP_MSG: 'readAllGroupMessage', READ_ALL_MSG: 'readAllMessage' }; const E = (function () {
    function e() {
      t(this, e), this.cache = [], this.options = null;
    } return o(e, [{ key: 'use', value(e) {
      if ('function' !== typeof e) throw 'middleware must be a function';return this.cache.push(e), this;
    } }, { key: 'next', value(e) {
      if (this.middlewares && this.middlewares.length > 0) return this.middlewares.shift().call(this, this.options, this.next.bind(this));
    } }, { key: 'run', value(e) {
      return this.middlewares = this.cache.map((e => e)), this.options = e, this.next();
    } }]), e;
  }()); const A = 'undefined' !== typeof globalThis ? globalThis : 'undefined' !== typeof window ? window : 'undefined' !== typeof global ? global : 'undefined' !== typeof self ? self : {};function N(e, t) {
    return e(t = { exports: {} }, t.exports), t.exports;
  } const L = N(((e, t) => {
    let n; let o; let a; let s; let r; let i; let c; let u; let l; let d; let p; let g; let h; let _; let f; let m; let M; let v;e.exports = (n = 'function' === typeof Promise, o = 'object' === typeof self ? self : A, a = 'undefined' !== typeof Symbol, s = 'undefined' !== typeof Map, r = 'undefined' !== typeof Set, i = 'undefined' !== typeof WeakMap, c = 'undefined' !== typeof WeakSet, u = 'undefined' !== typeof DataView, l = a && void 0 !== Symbol.iterator, d = a && void 0 !== Symbol.toStringTag, p = r && 'function' === typeof Set.prototype.entries, g = s && 'function' === typeof Map.prototype.entries, h = p && Object.getPrototypeOf((new Set).entries()), _ = g && Object.getPrototypeOf((new Map).entries()), f = l && 'function' === typeof Array.prototype[Symbol.iterator], m = f && Object.getPrototypeOf([][Symbol.iterator]()), M = l && 'function' === typeof String.prototype[Symbol.iterator], v = M && Object.getPrototypeOf(''[Symbol.iterator]()), function (e) {
      const t = typeof e;if ('object' !== t) return t;if (null === e) return 'null';if (e === o) return 'global';if (Array.isArray(e) && (!1 === d || !(Symbol.toStringTag in e))) return 'Array';if ('object' === typeof window && null !== window) {
        if ('object' === typeof window.location && e === window.location) return 'Location';if ('object' === typeof window.document && e === window.document) return 'Document';if ('object' === typeof window.navigator) {
          if ('object' === typeof window.navigator.mimeTypes && e === window.navigator.mimeTypes) return 'MimeTypeArray';if ('object' === typeof window.navigator.plugins && e === window.navigator.plugins) return 'PluginArray';
        } if (('function' === typeof window.HTMLElement || 'object' === typeof window.HTMLElement) && e instanceof window.HTMLElement) {
          if ('BLOCKQUOTE' === e.tagName) return 'HTMLQuoteElement';if ('TD' === e.tagName) return 'HTMLTableDataCellElement';if ('TH' === e.tagName) return 'HTMLTableHeaderCellElement';
        }
      } const a = d && e[Symbol.toStringTag];if ('string' === typeof a) return a;const l = Object.getPrototypeOf(e);return l === RegExp.prototype ? 'RegExp' : l === Date.prototype ? 'Date' : n && l === Promise.prototype ? 'Promise' : r && l === Set.prototype ? 'Set' : s && l === Map.prototype ? 'Map' : c && l === WeakSet.prototype ? 'WeakSet' : i && l === WeakMap.prototype ? 'WeakMap' : u && l === DataView.prototype ? 'DataView' : s && l === _ ? 'Map Iterator' : r && l === h ? 'Set Iterator' : f && l === m ? 'Array Iterator' : M && l === v ? 'String Iterator' : null === l ? 'Object' : Object.prototype.toString.call(e).slice(8, -1);
    });
  })); const R = (function () {
    function e() {
      const n = arguments.length > 0 && void 0 !== arguments[0] ? arguments[0] : 0; const o = arguments.length > 1 && void 0 !== arguments[1] ? arguments[1] : 0;t(this, e), this.high = n, this.low = o;
    } return o(e, [{ key: 'equal', value(e) {
      return null !== e && (this.low === e.low && this.high === e.high);
    } }, { key: 'toString', value() {
      const e = Number(this.high).toString(16); let t = Number(this.low).toString(16);if (t.length < 8) for (let n = 8 - t.length;n;)t = `0${t}`, n--;return e + t;
    } }]), e;
  }()); const O = { TEST: { CHINA: { DEFAULT: 'wss://wss-dev.tim.qq.com' }, OVERSEA: { DEFAULT: 'wss://wss-dev.tim.qq.com' }, SINGAPORE: { DEFAULT: 'wss://wsssgp-dev.im.qcloud.com' }, KOREA: { DEFAULT: 'wss://wsskr-dev.im.qcloud.com' }, GERMANY: { DEFAULT: 'wss://wssger-dev.im.qcloud.com' }, IND: { DEFAULT: 'wss://wssind-dev.im.qcloud.com' } }, PRODUCTION: { CHINA: { DEFAULT: 'wss://wss.im.qcloud.com', BACKUP: 'wss://wss.tim.qq.com', STAT: 'https://api.im.qcloud.com' }, OVERSEA: { DEFAULT: 'wss://wss.im.qcloud.com', STAT: 'https://api.im.qcloud.com' }, SINGAPORE: { DEFAULT: 'wss://wsssgp.im.qcloud.com', STAT: 'https://apisgp.im.qcloud.com' }, KOREA: { DEFAULT: 'wss://wsskr.im.qcloud.com', STAT: 'https://apiskr.im.qcloud.com' }, GERMANY: { DEFAULT: 'wss://wssger.im.qcloud.com', STAT: 'https://apiger.im.qcloud.com' }, IND: { DEFAULT: 'wss://wssind.im.qcloud.com', STAT: 'https://apiind.im.qcloud.com' } } }; const G = { WEB: 7, WX_MP: 8, QQ_MP: 9, TT_MP: 10, BAIDU_MP: 11, ALI_MP: 12, UNI_NATIVE_APP: 15 }; const w = '1.7.3'; const b = 537048168; const P = 'CHINA'; const U = 'OVERSEA'; const F = 'SINGAPORE'; const q = 'KOREA'; const V = 'GERMANY'; const K = 'IND'; const x = { HOST: { CURRENT: { DEFAULT: 'wss://wss.im.qcloud.com', STAT: 'https://api.im.qcloud.com' }, setCurrent() {
    const e = arguments.length > 0 && void 0 !== arguments[0] ? arguments[0] : P;this.CURRENT = O.PRODUCTION[e];
  } }, NAME: { OPEN_IM: 'openim', GROUP: 'group_open_http_svc', GROUP_ATTR: 'group_open_attr_http_svc', FRIEND: 'sns', PROFILE: 'profile', RECENT_CONTACT: 'recentcontact', PIC: 'openpic', BIG_GROUP_NO_AUTH: 'group_open_http_noauth_svc', BIG_GROUP_LONG_POLLING: 'group_open_long_polling_http_svc', BIG_GROUP_LONG_POLLING_NO_AUTH: 'group_open_long_polling_http_noauth_svc', IM_OPEN_STAT: 'imopenstat', WEB_IM: 'webim', IM_COS_SIGN: 'im_cos_sign_svr', CUSTOM_UPLOAD: 'im_cos_msg', HEARTBEAT: 'heartbeat', IM_OPEN_PUSH: 'im_open_push', IM_OPEN_STATUS: 'im_open_status', IM_LONG_MESSAGE: 'im_long_msg', IM_CONFIG_MANAGER: 'im_sdk_config_mgr', STAT_SERVICE: 'StatSvc', OVERLOAD_PUSH: 'OverLoadPush' }, CMD: { ACCESS_LAYER: 'accesslayer', LOGIN: 'wslogin', LOGOUT_LONG_POLL: 'longpollinglogout', LOGOUT: 'wslogout', HELLO: 'wshello', PORTRAIT_GET: 'portrait_get_all', PORTRAIT_SET: 'portrait_set', GET_LONG_POLL_ID: 'getlongpollingid', LONG_POLL: 'longpolling', AVCHATROOM_LONG_POLL: 'get_msg', ADD_FRIEND: 'friend_add', UPDATE_FRIEND: 'friend_update', GET_FRIEND_LIST: 'friend_get', GET_FRIEND_PROFILE: 'friend_get_list', DELETE_FRIEND: 'friend_delete', CHECK_FRIEND: 'friend_check', GET_FRIEND_GROUP_LIST: 'group_get', RESPOND_FRIEND_APPLICATION: 'friend_response', GET_FRIEND_APPLICATION_LIST: 'pendency_get', DELETE_FRIEND_APPLICATION: 'pendency_delete', REPORT_FRIEND_APPLICATION: 'pendency_report', GET_GROUP_APPLICATION: 'get_pendency', CREATE_FRIEND_GROUP: 'group_add', DELETE_FRIEND_GROUP: 'group_delete', UPDATE_FRIEND_GROUP: 'group_update', GET_BLACKLIST: 'black_list_get', ADD_BLACKLIST: 'black_list_add', DELETE_BLACKLIST: 'black_list_delete', CREATE_GROUP: 'create_group', GET_JOINED_GROUPS: 'get_joined_group_list', SET_GROUP_ATTRIBUTES: 'set_group_attr', MODIFY_GROUP_ATTRIBUTES: 'modify_group_attr', DELETE_GROUP_ATTRIBUTES: 'delete_group_attr', CLEAR_GROUP_ATTRIBUTES: 'clear_group_attr', GET_GROUP_ATTRIBUTES: 'get_group_attr', SEND_MESSAGE: 'sendmsg', REVOKE_C2C_MESSAGE: 'msgwithdraw', DELETE_C2C_MESSAGE: 'delete_c2c_msg_ramble', SEND_GROUP_MESSAGE: 'send_group_msg', REVOKE_GROUP_MESSAGE: 'group_msg_recall', DELETE_GROUP_MESSAGE: 'delete_group_ramble_msg_by_seq', GET_GROUP_INFO: 'get_group_self_member_info', GET_GROUP_MEMBER_INFO: 'get_specified_group_member_info', GET_GROUP_MEMBER_LIST: 'get_group_member_info', QUIT_GROUP: 'quit_group', CHANGE_GROUP_OWNER: 'change_group_owner', DESTROY_GROUP: 'destroy_group', ADD_GROUP_MEMBER: 'add_group_member', DELETE_GROUP_MEMBER: 'delete_group_member', SEARCH_GROUP_BY_ID: 'get_group_public_info', APPLY_JOIN_GROUP: 'apply_join_group', HANDLE_APPLY_JOIN_GROUP: 'handle_apply_join_group', HANDLE_GROUP_INVITATION: 'handle_invite_join_group', MODIFY_GROUP_INFO: 'modify_group_base_info', MODIFY_GROUP_MEMBER_INFO: 'modify_group_member_info', DELETE_GROUP_SYSTEM_MESSAGE: 'deletemsg', DELETE_GROUP_AT_TIPS: 'deletemsg', GET_CONVERSATION_LIST: 'get', PAGING_GET_CONVERSATION_LIST: 'page_get', DELETE_CONVERSATION: 'delete', PIN_CONVERSATION: 'top', GET_MESSAGES: 'getmsg', GET_C2C_ROAM_MESSAGES: 'getroammsg', SET_C2C_PEER_MUTE_NOTIFICATIONS: 'set_c2c_peer_mute_notifications', GET_C2C_PEER_MUTE_NOTIFICATIONS: 'get_c2c_peer_mute_notifications', GET_GROUP_ROAM_MESSAGES: 'group_msg_get', SET_C2C_MESSAGE_READ: 'msgreaded', GET_PEER_READ_TIME: 'get_peer_read_time', SET_GROUP_MESSAGE_READ: 'msg_read_report', FILE_READ_AND_WRITE_AUTHKEY: 'authkey', FILE_UPLOAD: 'pic_up', COS_SIGN: 'cos', COS_PRE_SIG: 'pre_sig', TIM_WEB_REPORT_V2: 'tim_web_report_v2', BIG_DATA_HALLWAY_AUTH_KEY: 'authkey', GET_ONLINE_MEMBER_NUM: 'get_online_member_num', ALIVE: 'alive', MESSAGE_PUSH: 'msg_push', MESSAGE_PUSH_ACK: 'ws_msg_push_ack', STATUS_FORCEOFFLINE: 'stat_forceoffline', DOWNLOAD_MERGER_MESSAGE: 'get_relay_json_msg', UPLOAD_MERGER_MESSAGE: 'save_relay_json_msg', FETCH_CLOUD_CONTROL_CONFIG: 'fetch_config', PUSHED_CLOUD_CONTROL_CONFIG: 'push_configv2', FETCH_COMMERCIAL_CONFIG: 'fetch_imsdk_purchase_bitsv2', PUSHED_COMMERCIAL_CONFIG: 'push_imsdk_purchase_bitsv2', KICK_OTHER: 'KickOther', OVERLOAD_NOTIFY: 'notify2', SET_ALL_MESSAGE_READ: 'read_all_unread_msg' }, CHANNEL: { SOCKET: 1, XHR: 2, AUTO: 0 }, NAME_VERSION: { openim: 'v4', group_open_http_svc: 'v4', sns: 'v4', profile: 'v4', recentcontact: 'v4', openpic: 'v4', group_open_http_noauth_svc: 'v4', group_open_long_polling_http_svc: 'v4', group_open_long_polling_http_noauth_svc: 'v4', imopenstat: 'v4', im_cos_sign_svr: 'v4', im_cos_msg: 'v4', webim: 'v4', im_open_push: 'v4', im_open_status: 'v4' } }; const B = { SEARCH_MSG: new R(0, Math.pow(2, 0)).toString(), SEARCH_GRP_SNS: new R(0, Math.pow(2, 1)).toString(), AVCHATROOM_HISTORY_MSG: new R(0, Math.pow(2, 2)).toString(), GRP_COMMUNITY: new R(0, Math.pow(2, 3)).toString(), MSG_TO_SPECIFIED_GRP_MBR: new R(0, Math.pow(2, 4)).toString() };x.HOST.setCurrent(P);let H; let j; let W; let Y; const $ = 'undefined' !== typeof wx && 'function' === typeof wx.getSystemInfoSync && Boolean(wx.getSystemInfoSync().fontSizeSetting); const z = 'undefined' !== typeof qq && 'function' === typeof qq.getSystemInfoSync && Boolean(qq.getSystemInfoSync().fontSizeSetting); const J = 'undefined' !== typeof tt && 'function' === typeof tt.getSystemInfoSync && Boolean(tt.getSystemInfoSync().fontSizeSetting); const X = 'undefined' !== typeof swan && 'function' === typeof swan.getSystemInfoSync && Boolean(swan.getSystemInfoSync().fontSizeSetting); const Q = 'undefined' !== typeof my && 'function' === typeof my.getSystemInfoSync && Boolean(my.getSystemInfoSync().fontSizeSetting); const Z = 'undefined' !== typeof uni && 'undefined' === typeof window; const ee = $ || z || J || X || Q || Z; const te = ('undefined' !== typeof uni || 'undefined' !== typeof window) && !ee; const ne = z ? qq : J ? tt : X ? swan : Q ? my : $ ? wx : Z ? uni : {}; const oe = (H = 'WEB', me ? H = 'WEB' : z ? H = 'QQ_MP' : J ? H = 'TT_MP' : X ? H = 'BAIDU_MP' : Q ? H = 'ALI_MP' : $ ? H = 'WX_MP' : Z && (H = 'UNI_NATIVE_APP'), G[H]); const ae = te && window && window.navigator && window.navigator.userAgent || ''; const se = /AppleWebKit\/([\d.]+)/i.exec(ae); const re = (se && parseFloat(se.pop()), /iPad/i.test(ae)); const ie = /iPhone/i.test(ae) && !re; const ce = /iPod/i.test(ae); const ue = ie || re || ce; const le = ((j = ae.match(/OS (\d+)_/i)) && j[1] && j[1], /Android/i.test(ae)); const de = (function () {
    const e = ae.match(/Android (\d+)(?:\.(\d+))?(?:\.(\d+))*/i);if (!e) return null;const t = e[1] && parseFloat(e[1]); const n = e[2] && parseFloat(e[2]);return t && n ? parseFloat(`${e[1]}.${e[2]}`) : t || null;
  }()); const pe = (le && /webkit/i.test(ae), /Firefox/i.test(ae), /Edge/i.test(ae)); const ge = !pe && /Chrome/i.test(ae); const he = ((function () {
    const e = ae.match(/Chrome\/(\d+)/);e && e[1] && parseFloat(e[1]);
  }()), /MSIE/.test(ae)); const _e = (/MSIE\s8\.0/.test(ae), (function () {
    const e = /MSIE\s(\d+)\.\d/.exec(ae); let t = e && parseFloat(e[1]);return !t && /Trident\/7.0/i.test(ae) && /rv:11.0/.test(ae) && (t = 11), t;
  }())); const fe = (/Safari/i.test(ae), /TBS\/\d+/i.test(ae)); var me = ((function () {
    const e = ae.match(/TBS\/(\d+)/i);if (e && e[1])e[1];
  }()), !fe && /MQQBrowser\/\d+/i.test(ae), !fe && / QQBrowser\/\d+/i.test(ae), /(micromessenger|webbrowser)/i.test(ae)); const Me = /Windows/i.test(ae); const ve = /MAC OS X/i.test(ae); const ye = (/MicroMessenger/i.test(ae), te && 'undefined' !== typeof Worker); const Ie = 'undefined' !== typeof global ? global : 'undefined' !== typeof self ? self : 'undefined' !== typeof window ? window : {};W = 'undefined' !== typeof console ? console : void 0 !== Ie && Ie.console ? Ie.console : 'undefined' !== typeof window && window.console ? window.console : {};for (var Ce = function () {}, Te = ['assert', 'clear', 'count', 'debug', 'dir', 'dirxml', 'error', 'exception', 'group', 'groupCollapsed', 'groupEnd', 'info', 'log', 'markTimeline', 'profile', 'profileEnd', 'table', 'time', 'timeEnd', 'timeStamp', 'trace', 'warn'], Se = Te.length;Se--;)Y = Te[Se], console[Y] || (W[Y] = Ce);W.methods = Te;const De = W; let ke = 0; const Ee = function () {
    return (new Date).getTime() + ke;
  }; const Ae = function () {
    ke = 0;
  }; let Ne = 0; const Le = new Map;function Re() {
    let e; const t = ((e = new Date).setTime(Ee()), e);return `TIM ${t.toLocaleTimeString('en-US', { hour12: !1 })}.${(function (e) {
      let t;switch (e.toString().length) {
        case 1:t = `00${e}`;break;case 2:t = `0${e}`;break;default:t = e;
      } return t;
    }(t.getMilliseconds()))}:`;
  } const Oe = { arguments2String(e) {
    let t;if (1 === e.length)t = Re() + e[0];else {
      t = Re();for (let n = 0, o = e.length;n < o;n++)Ve(e[n]) ? xe(e[n]) ? t += $e(e[n]) : t += JSON.stringify(e[n]) : t += e[n], t += ' ';
    } return t;
  }, debug() {
    if (Ne <= -1) {
      const e = this.arguments2String(arguments);De.debug(e);
    }
  }, log() {
    if (Ne <= 0) {
      const e = this.arguments2String(arguments);De.log(e);
    }
  }, info() {
    if (Ne <= 1) {
      const e = this.arguments2String(arguments);De.info(e);
    }
  }, warn() {
    if (Ne <= 2) {
      const e = this.arguments2String(arguments);De.warn(e);
    }
  }, error() {
    if (Ne <= 3) {
      const e = this.arguments2String(arguments);De.error(e);
    }
  }, time(e) {
    Le.set(e, We.now());
  }, timeEnd(e) {
    if (Le.has(e)) {
      const t = We.now() - Le.get(e);return Le.delete(e), t;
    } return De.warn('未找到对应label: '.concat(e, ', 请在调用 logger.timeEnd 前，调用 logger.time')), 0;
  }, setLevel(e) {
    e < 4 && De.log(`${Re()}set level from ${Ne} to ${e}`), Ne = e;
  }, getLevel() {
    return Ne;
  } }; const Ge = function (e) {
    return 'file' === Be(e);
  }; const we = function (t) {
    return null !== t && ('number' === typeof t && !isNaN(t - 0) || 'object' === e(t) && t.constructor === Number);
  }; const be = function (e) {
    return 'string' === typeof e;
  }; const Pe = function (t) {
    return null !== t && 'object' === e(t);
  }; const Ue = function (t) {
    if ('object' !== e(t) || null === t) return !1;const n = Object.getPrototypeOf(t);if (null === n) return !0;for (var o = n;null !== Object.getPrototypeOf(o);)o = Object.getPrototypeOf(o);return n === o;
  }; const Fe = function (e) {
    return 'function' === typeof Array.isArray ? Array.isArray(e) : 'array' === Be(e);
  }; const qe = function (e) {
    return void 0 === e;
  }; var Ve = function (e) {
    return Fe(e) || Pe(e);
  }; const Ke = function (e) {
    return 'function' === typeof e;
  }; var xe = function (e) {
    return e instanceof Error;
  }; var Be = function (e) {
    return Object.prototype.toString.call(e).match(/^\[object (.*)\]$/)[1].toLowerCase();
  }; const He = function (e) {
    if ('string' !== typeof e) return !1;const t = e[0];return !/[^a-zA-Z0-9]/.test(t);
  }; let je = 0;Date.now || (Date.now = function () {
    return (new Date).getTime();
  });var We = { now() {
    0 === je && (je = Date.now() - 1);const e = Date.now() - je;return e > 4294967295 ? (je += 4294967295, Date.now() - je) : e;
  }, utc() {
    return Math.round(Date.now() / 1e3);
  } }; const Ye = function e(t, n, o, a) {
    if (!Ve(t) || !Ve(n)) return 0;for (var s, r = 0, i = Object.keys(n), c = 0, u = i.length;c < u;c++) if (s = i[c], !(qe(n[s]) || o && o.includes(s))) if (Ve(t[s]) && Ve(n[s]))r += e(t[s], n[s], o, a);else {
      if (a && a.includes(n[s])) continue;t[s] !== n[s] && (t[s] = n[s], r += 1);
    } return r;
  }; var $e = function (e) {
    return JSON.stringify(e, ['message', 'code']);
  }; const ze = function (e) {
    if (0 === e.length) return 0;for (var t = 0, n = 0, o = 'undefined' !== typeof document && void 0 !== document.characterSet ? document.characterSet : 'UTF-8';void 0 !== e[t];)n += e[t++].charCodeAt[t] <= 255 ? 1 : !1 === o ? 3 : 2;return n;
  }; const Je = function (e) {
    const t = e || 99999999;return Math.round(Math.random() * t);
  }; const Xe = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'; const Qe = Xe.length; const Ze = function (e, t) {
    for (const n in e) if (e[n] === t) return !0;return !1;
  }; const et = {}; const nt = function () {
    if (ee) return 'https:';if (te && 'undefined' === typeof window) return 'https:';let e = window.location.protocol;return ['http:', 'https:'].indexOf(e) < 0 && (e = 'http:'), e;
  }; const ot = function (e) {
    return -1 === e.indexOf('http://') || -1 === e.indexOf('https://') ? `https://${e}` : e.replace(/https|http/, 'https');
  }; const at = function t(n) {
    if (0 === Object.getOwnPropertyNames(n).length) return Object.create(null);const o = Array.isArray(n) ? [] : Object.create(null); let a = '';for (const s in n)null !== n[s] ? void 0 !== n[s] ? (a = e(n[s]), ['string', 'number', 'function', 'boolean'].indexOf(a) >= 0 ? o[s] = n[s] : o[s] = t(n[s])) : o[s] = void 0 : o[s] = null;return o;
  };function st(e, t) {
    Fe(e) && Fe(t) ? t.forEach(((t) => {
      const n = t.key; const o = t.value; const a = e.find((e => e.key === n));a ? a.value = o : e.push({ key: n, value: o });
    })) : Oe.warn('updateCustomField target 或 source 不是数组，忽略此次更新。');
  } const rt = function (e) {
    return e === k.GRP_PUBLIC;
  }; const it = function (e) {
    return e === k.GRP_AVCHATROOM;
  }; const ct = function (e) {
    return be(e) && e.slice(0, 3) === k.CONV_C2C;
  }; const ut = function (e) {
    return be(e) && e.slice(0, 5) === k.CONV_GROUP;
  }; const lt = function (e) {
    return be(e) && e === k.CONV_SYSTEM;
  };function dt(e, t) {
    const n = {};return Object.keys(e).forEach(((o) => {
      n[o] = t(e[o], o);
    })), n;
  } function pt() {
    function e() {
      return (65536 * (1 + Math.random()) | 0).toString(16).substring(1);
    } return ''.concat(e() + e()).concat(e())
      .concat(e())
      .concat(e())
      .concat(e())
      .concat(e())
      .concat(e());
  } function gt() {
    let e = 'unknown';if (ve && (e = 'mac'), Me && (e = 'windows'), ue && (e = 'ios'), le && (e = 'android'), ee) try {
      const t = ne.getSystemInfoSync().platform;void 0 !== t && (e = t);
    } catch (n) {} return e;
  } function ht(e) {
    const t = e.originUrl; const n = void 0 === t ? void 0 : t; const o = e.originWidth; const a = e.originHeight; const s = e.min; const r = void 0 === s ? 198 : s; const i = parseInt(o); const c = parseInt(a); const u = { url: void 0, width: 0, height: 0 };if ((i <= c ? i : c) <= r)u.url = n, u.width = i, u.height = c;else {
      c <= i ? (u.width = Math.ceil(i * r / c), u.height = r) : (u.width = r, u.height = Math.ceil(c * r / i));const l = n && n.indexOf('?') > -1 ? ''.concat(n, '&') : ''.concat(n, '?');u.url = ''.concat(l, 198 === r ? 'imageView2/3/w/198/h/198' : 'imageView2/3/w/720/h/720');
    } return qe(n) ? g(u, ['url']) : u;
  } function _t(e) {
    const t = e[2];e[2] = e[1], e[1] = t;for (let n = 0;n < e.length;n++)e[n].setType(n);
  } function ft(e) {
    const t = e.servcmd;return t.slice(t.indexOf('.') + 1);
  } function mt(e, t) {
    return Math.round(Number(e) * Math.pow(10, t)) / Math.pow(10, t);
  } function Mt(e, t) {
    return e.includes(t);
  } function vt(e, t) {
    return e.includes(t);
  } const yt = Object.prototype.hasOwnProperty;function It(e) {
    if (null == e) return !0;if ('boolean' === typeof e) return !1;if ('number' === typeof e) return 0 === e;if ('string' === typeof e) return 0 === e.length;if ('function' === typeof e) return 0 === e.length;if (Array.isArray(e)) return 0 === e.length;if (e instanceof Error) return '' === e.message;if (Ue(e)) {
      for (const t in e) if (yt.call(e, t)) return !1;return !0;
    } return !('map' !== Be(e) && !(function (e) {
      return 'set' === Be(e);
    }(e)) && !Ge(e)) && 0 === e.size;
  } function Ct(e, t, n) {
    if (void 0 === t) return !0;let o = !0;if ('object' === L(t).toLowerCase())Object.keys(t).forEach(((a) => {
      const s = 1 === e.length ? e[0][a] : void 0;o = !!Tt(s, t[a], n, a) && o;
    }));else if ('array' === L(t).toLowerCase()) for (let a = 0;a < t.length;a++)o = !!Tt(e[a], t[a], n, t[a].name) && o;if (o) return o;throw new Error('Params validate failed.');
  } function Tt(e, t, n, o) {
    if (void 0 === t) return !0;let a = !0;return t.required && It(e) && (De.error('TIM ['.concat(n, '] Missing required params: "').concat(o, '".')), a = !1), It(e) || L(e).toLowerCase() === t.type.toLowerCase() || (De.error('TIM ['.concat(n, '] Invalid params: type check failed for "').concat(o, '".Expected ')
      .concat(t.type, '.')), a = !1), t.validator && !t.validator(e) && (De.error('TIM ['.concat(n, '] Invalid params: custom validator check failed for params.')), a = !1), a;
  } let St; const Dt = { UNSEND: 'unSend', SUCCESS: 'success', FAIL: 'fail' }; const kt = { NOT_START: 'notStart', PENDING: 'pengding', RESOLVED: 'resolved', REJECTED: 'rejected' }; const Et = function (e) {
    return !!e && (!!(ct(e) || ut(e) || lt(e)) || (console.warn('非法的会话 ID:'.concat(e, '。会话 ID 组成方式：C2C + userID（单聊）GROUP + groupID（群聊）@TIM#SYSTEM（系统通知会话）')), !1));
  }; const At = '请参考 https://web.sdk.qcloud.com/im/doc/zh-cn/SDK.html#'; const Nt = function (e) {
    return e.param ? ''.concat(e.api, ' ').concat(e.param, ' ')
      .concat(e.desc, '。')
      .concat(At)
      .concat(e.api) : ''.concat(e.api, ' ').concat(e.desc, '。')
      .concat(At)
      .concat(e.api);
  }; const Lt = { type: 'String', required: !0 }; const Rt = { type: 'Array', required: !0 }; const Ot = { type: 'Object', required: !0 }; const Gt = { login: { userID: Lt, userSig: Lt }, addToBlacklist: { userIDList: Rt }, on: [{ name: 'eventName', type: 'String', validator(e) {
    return 'string' === typeof e && 0 !== e.length || (console.warn(Nt({ api: 'on', param: 'eventName', desc: '类型必须为 String，且不能为空' })), !1);
  } }, { name: 'handler', type: 'Function', validator(e) {
    return 'function' !== typeof e ? (console.warn(Nt({ api: 'on', param: 'handler', desc: '参数必须为 Function' })), !1) : ('' === e.name && console.warn('on 接口的 handler 参数推荐使用具名函数。具名函数可以使用 off 接口取消订阅，匿名函数无法取消订阅。'), !0);
  } }], once: [{ name: 'eventName', type: 'String', validator(e) {
    return 'string' === typeof e && 0 !== e.length || (console.warn(Nt({ api: 'once', param: 'eventName', desc: '类型必须为 String，且不能为空' })), !1);
  } }, { name: 'handler', type: 'Function', validator(e) {
    return 'function' !== typeof e ? (console.warn(Nt({ api: 'once', param: 'handler', desc: '参数必须为 Function' })), !1) : ('' === e.name && console.warn('once 接口的 handler 参数推荐使用具名函数。'), !0);
  } }], off: [{ name: 'eventName', type: 'String', validator(e) {
    return 'string' === typeof e && 0 !== e.length || (console.warn(Nt({ api: 'off', param: 'eventName', desc: '类型必须为 String，且不能为空' })), !1);
  } }, { name: 'handler', type: 'Function', validator(e) {
    return 'function' !== typeof e ? (console.warn(Nt({ api: 'off', param: 'handler', desc: '参数必须为 Function' })), !1) : ('' === e.name && console.warn('off 接口无法为匿名函数取消监听事件。'), !0);
  } }], sendMessage: [r({ name: 'message' }, Ot)], getMessageList: { conversationID: r(r({}, Lt), {}, { validator(e) {
    return Et(e);
  } }), nextReqMessageID: { type: 'String' }, count: { type: 'Number', validator(e) {
    return !(!qe(e) && !/^[1-9][0-9]*$/.test(e)) || (console.warn(Nt({ api: 'getMessageList', param: 'count', desc: '必须为正整数' })), !1);
  } } }, setMessageRead: { conversationID: r(r({}, Lt), {}, { validator(e) {
    return Et(e);
  } }) }, setAllMessageRead: { scope: { type: 'String', required: !1, validator(e) {
    return !e || -1 !== [k.READ_ALL_C2C_MSG, k.READ_ALL_GROUP_MSG, k.READ_ALL_MSG].indexOf(e) || (console.warn(Nt({ api: 'setAllMessageRead', param: 'scope', desc: '取值必须为 TIM.TYPES.READ_ALL_C2C_MSG, TIM.TYPES.READ_ALL_GROUP_MSG 或 TIM.TYPES.READ_ALL_MSG' })), !1);
  } } }, getConversationProfile: [r(r({ name: 'conversationID' }, Lt), {}, { validator(e) {
    return Et(e);
  } })], deleteConversation: [r(r({ name: 'conversationID' }, Lt), {}, { validator(e) {
    return Et(e);
  } })], pinConversation: { conversationID: r(r({}, Lt), {}, { validator(e) {
    return Et(e);
  } }), isPinned: r({}, { type: 'Boolean', required: !0 }) }, getConversationList: [{ name: 'options', type: 'Array', validator(e) {
    return !!qe(e) || (0 !== e.length || (console.warn(Nt({ api: 'getConversationList', desc: '获取指定会话时不能传入空数组' })), !1));
  } }], getGroupList: { groupProfileFilter: { type: 'Array' } }, getGroupProfile: { groupID: Lt, groupCustomFieldFilter: { type: 'Array' }, memberCustomFieldFilter: { type: 'Array' } }, getGroupProfileAdvance: { groupIDList: Rt }, createGroup: { name: Lt }, joinGroup: { groupID: Lt, type: { type: 'String' }, applyMessage: { type: 'String' } }, quitGroup: [r({ name: 'groupID' }, Lt)], handleApplication: { message: Ot, handleAction: Lt, handleMessage: { type: 'String' } }, changeGroupOwner: { groupID: Lt, newOwnerID: Lt }, updateGroupProfile: { groupID: Lt, muteAllMembers: { type: 'Boolean' } }, dismissGroup: [r({ name: 'groupID' }, Lt)], searchGroupByID: [r({ name: 'groupID' }, Lt)], initGroupAttributes: { groupID: Lt, groupAttributes: r(r({}, Ot), {}, { validator(e) {
    let t = !0;return Object.keys(e).forEach(((n) => {
      if (!be(e[n])) return console.warn(Nt({ api: 'initGroupAttributes', desc: '群属性 value 必须是字符串' })), t = !1;
    })), t;
  } }) }, setGroupAttributes: { groupID: Lt, groupAttributes: r(r({}, Ot), {}, { validator(e) {
    let t = !0;return Object.keys(e).forEach(((n) => {
      if (!be(e[n])) return console.warn(Nt({ api: 'setGroupAttributes', desc: '群属性 value 必须是字符串' })), t = !1;
    })), t;
  } }) }, deleteGroupAttributes: { groupID: Lt, keyList: { type: 'Array', validator(e) {
    if (qe(e)) return console.warn(Nt({ api: 'deleteGroupAttributes', desc: '缺少必填参数：keyList' })), !1;if (!Fe(e)) return !1;if (!It(e)) {
      let t = !0;return e.forEach(((e) => {
        if (!be(e)) return console.warn(Nt({ api: 'deleteGroupAttributes', desc: '群属性 key 必须是字符串' })), t = !1;
      })), t;
    } return !0;
  } } }, getGroupAttributes: { groupID: Lt, keyList: { type: 'Array', validator(e) {
    if (qe(e)) return console.warn(Nt({ api: 'getGroupAttributes', desc: '缺少必填参数：keyList' })), !1;if (!Fe(e)) return !1;if (!It(e)) {
      let t = !0;return e.forEach(((e) => {
        if (!be(e)) return console.warn(Nt({ api: 'getGroupAttributes', desc: '群属性 key 必须是字符串' })), t = !1;
      })), t;
    } return !0;
  } } }, getGroupMemberList: { groupID: Lt, offset: { type: 'Number' }, count: { type: 'Number' } }, getGroupMemberProfile: { groupID: Lt, userIDList: Rt, memberCustomFieldFilter: { type: 'Array' } }, addGroupMember: { groupID: Lt, userIDList: Rt }, setGroupMemberRole: { groupID: Lt, userID: Lt, role: Lt }, setGroupMemberMuteTime: { groupID: Lt, userID: Lt, muteTime: { type: 'Number', validator(e) {
    return e >= 0;
  } } }, setGroupMemberNameCard: { groupID: Lt, userID: { type: 'String' }, nameCard: { type: 'String', validator(e) {
    return be(e) ? (e.length, !0) : (console.warn(Nt({ api: 'setGroupMemberNameCard', param: 'nameCard', desc: '类型必须为 String' })), !1);
  } } }, setGroupMemberCustomField: { groupID: Lt, userID: { type: 'String' }, memberCustomField: Rt }, deleteGroupMember: { groupID: Lt }, createTextMessage: { to: Lt, conversationType: Lt, payload: r(r({}, Ot), {}, { validator(e) {
    return Ue(e) ? be(e.text) ? 0 !== e.text.length || (console.warn(Nt({ api: 'createTextMessage', desc: '消息内容不能为空' })), !1) : (console.warn(Nt({ api: 'createTextMessage', param: 'payload.text', desc: '类型必须为 String' })), !1) : (console.warn(Nt({ api: 'createTextMessage', param: 'payload', desc: '类型必须为 plain object' })), !1);
  } }) }, createTextAtMessage: { to: Lt, conversationType: Lt, payload: r(r({}, Ot), {}, { validator(e) {
    return Ue(e) ? be(e.text) ? 0 === e.text.length ? (console.warn(Nt({ api: 'createTextAtMessage', desc: '消息内容不能为空' })), !1) : !(e.atUserList && !Fe(e.atUserList)) || (console.warn(Nt({ api: 'createTextAtMessage', desc: 'payload.atUserList 类型必须为数组' })), !1) : (console.warn(Nt({ api: 'createTextAtMessage', param: 'payload.text', desc: '类型必须为 String' })), !1) : (console.warn(Nt({ api: 'createTextAtMessage', param: 'payload', desc: '类型必须为 plain object' })), !1);
  } }) }, createCustomMessage: { to: Lt, conversationType: Lt, payload: r(r({}, Ot), {}, { validator(e) {
    return Ue(e) ? e.data && !be(e.data) ? (console.warn(Nt({ api: 'createCustomMessage', param: 'payload.data', desc: '类型必须为 String' })), !1) : e.description && !be(e.description) ? (console.warn(Nt({ api: 'createCustomMessage', param: 'payload.description', desc: '类型必须为 String' })), !1) : !(e.extension && !be(e.extension)) || (console.warn(Nt({ api: 'createCustomMessage', param: 'payload.extension', desc: '类型必须为 String' })), !1) : (console.warn(Nt({ api: 'createCustomMessage', param: 'payload', desc: '类型必须为 plain object' })), !1);
  } }) }, createImageMessage: { to: Lt, conversationType: Lt, payload: r(r({}, Ot), {}, { validator(e) {
    if (!Ue(e)) return console.warn(Nt({ api: 'createImageMessage', param: 'payload', desc: '类型必须为 plain object' })), !1;if (qe(e.file)) return console.warn(Nt({ api: 'createImageMessage', param: 'payload.file', desc: '不能为 undefined' })), !1;if (te) {
      if (!(e.file instanceof HTMLInputElement || Ge(e.file))) return Ue(e.file) && 'undefined' !== typeof uni ? 0 !== e.file.tempFilePaths.length && 0 !== e.file.tempFiles.length || (console.warn(Nt({ api: 'createImageMessage', param: 'payload.file', desc: '您没有选择文件，无法发送' })), !1) : (console.warn(Nt({ api: 'createImageMessage', param: 'payload.file', desc: '类型必须是 HTMLInputElement 或 File' })), !1);if (e.file instanceof HTMLInputElement && 0 === e.file.files.length) return console.warn(Nt({ api: 'createImageMessage', param: 'payload.file', desc: '您没有选择文件，无法发送' })), !1;
    } return !0;
  }, onProgress: { type: 'Function', required: !1, validator(e) {
    return qe(e) && console.warn(Nt({ api: 'createImageMessage', desc: '没有 onProgress 回调，您将无法获取上传进度' })), !0;
  } } }) }, createAudioMessage: { to: Lt, conversationType: Lt, payload: r(r({}, Ot), {}, { validator(e) {
    return !!Ue(e) || (console.warn(Nt({ api: 'createAudioMessage', param: 'payload', desc: '类型必须为 plain object' })), !1);
  } }), onProgress: { type: 'Function', required: !1, validator(e) {
    return qe(e) && console.warn(Nt({ api: 'createAudioMessage', desc: '没有 onProgress 回调，您将无法获取上传进度' })), !0;
  } } }, createVideoMessage: { to: Lt, conversationType: Lt, payload: r(r({}, Ot), {}, { validator(e) {
    if (!Ue(e)) return console.warn(Nt({ api: 'createVideoMessage', param: 'payload', desc: '类型必须为 plain object' })), !1;if (qe(e.file)) return console.warn(Nt({ api: 'createVideoMessage', param: 'payload.file', desc: '不能为 undefined' })), !1;if (te) {
      if (!(e.file instanceof HTMLInputElement || Ge(e.file))) return Ue(e.file) && 'undefined' !== typeof uni ? !!Ge(e.file.tempFile) || (console.warn(Nt({ api: 'createVideoMessage', param: 'payload.file', desc: '您没有选择文件，无法发送' })), !1) : (console.warn(Nt({ api: 'createVideoMessage', param: 'payload.file', desc: '类型必须是 HTMLInputElement 或 File' })), !1);if (e.file instanceof HTMLInputElement && 0 === e.file.files.length) return console.warn(Nt({ api: 'createVideoMessage', param: 'payload.file', desc: '您没有选择文件，无法发送' })), !1;
    } return !0;
  } }), onProgress: { type: 'Function', required: !1, validator(e) {
    return qe(e) && console.warn(Nt({ api: 'createVideoMessage', desc: '没有 onProgress 回调，您将无法获取上传进度' })), !0;
  } } }, createFaceMessage: { to: Lt, conversationType: Lt, payload: r(r({}, Ot), {}, { validator(e) {
    return Ue(e) ? we(e.index) ? !!be(e.data) || (console.warn(Nt({ api: 'createFaceMessage', param: 'payload.data', desc: '类型必须为 String' })), !1) : (console.warn(Nt({ api: 'createFaceMessage', param: 'payload.index', desc: '类型必须为 Number' })), !1) : (console.warn(Nt({ api: 'createFaceMessage', param: 'payload', desc: '类型必须为 plain object' })), !1);
  } }) }, createFileMessage: { to: Lt, conversationType: Lt, payload: r(r({}, Ot), {}, { validator(e) {
    if (!Ue(e)) return console.warn(Nt({ api: 'createFileMessage', param: 'payload', desc: '类型必须为 plain object' })), !1;if (qe(e.file)) return console.warn(Nt({ api: 'createFileMessage', param: 'payload.file', desc: '不能为 undefined' })), !1;if (te) {
      if (!(e.file instanceof HTMLInputElement || Ge(e.file))) return Ue(e.file) && 'undefined' !== typeof uni ? 0 !== e.file.tempFilePaths.length && 0 !== e.file.tempFiles.length || (console.warn(Nt({ api: 'createFileMessage', param: 'payload.file', desc: '您没有选择文件，无法发送' })), !1) : (console.warn(Nt({ api: 'createFileMessage', param: 'payload.file', desc: '类型必须是 HTMLInputElement 或 File' })), !1);if (e.file instanceof HTMLInputElement && 0 === e.file.files.length) return console.warn(Nt({ api: 'createFileMessage', desc: '您没有选择文件，无法发送' })), !1;
    } return !0;
  } }), onProgress: { type: 'Function', required: !1, validator(e) {
    return qe(e) && console.warn(Nt({ api: 'createFileMessage', desc: '没有 onProgress 回调，您将无法获取上传进度' })), !0;
  } } }, createLocationMessage: { to: Lt, conversationType: Lt, payload: r(r({}, Ot), {}, { validator(e) {
    return Ue(e) ? be(e.description) ? we(e.longitude) ? !!we(e.latitude) || (console.warn(Nt({ api: 'createLocationMessage', param: 'payload.latitude', desc: '类型必须为 Number' })), !1) : (console.warn(Nt({ api: 'createLocationMessage', param: 'payload.longitude', desc: '类型必须为 Number' })), !1) : (console.warn(Nt({ api: 'createLocationMessage', param: 'payload.description', desc: '类型必须为 String' })), !1) : (console.warn(Nt({ api: 'createLocationMessage', param: 'payload', desc: '类型必须为 plain object' })), !1);
  } }) }, createMergerMessage: { to: Lt, conversationType: Lt, payload: r(r({}, Ot), {}, { validator(e) {
    if (It(e.messageList)) return console.warn(Nt({ api: 'createMergerMessage', desc: '不能为空数组' })), !1;if (It(e.compatibleText)) return console.warn(Nt({ api: 'createMergerMessage', desc: '类型必须为 String，且不能为空' })), !1;let t = !1;return e.messageList.forEach(((e) => {
      e.status === Dt.FAIL && (t = !0);
    })), !t || (console.warn(Nt({ api: 'createMergerMessage', desc: '不支持合并已发送失败的消息' })), !1);
  } }) }, revokeMessage: [r(r({ name: 'message' }, Ot), {}, { validator(e) {
    return It(e) ? (console.warn('revokeMessage 请传入消息（Message）实例'), !1) : e.conversationType === k.CONV_SYSTEM ? (console.warn('revokeMessage 不能撤回系统会话消息，只能撤回单聊消息或群消息'), !1) : !0 !== e.isRevoked || (console.warn('revokeMessage 消息已经被撤回，请勿重复操作'), !1);
  } })], deleteMessage: [r(r({ name: 'messageList' }, Rt), {}, { validator(e) {
    return !It(e) || (console.warn(Nt({ api: 'deleteMessage', param: 'messageList', desc: '不能为空数组' })), !1);
  } })], getUserProfile: { userIDList: { type: 'Array', validator(e) {
    return Fe(e) ? (0 === e.length && console.warn(Nt({ api: 'getUserProfile', param: 'userIDList', desc: '不能为空数组' })), !0) : (console.warn(Nt({ api: 'getUserProfile', param: 'userIDList', desc: '必须为数组' })), !1);
  } } }, updateMyProfile: { profileCustomField: { type: 'Array', validator(e) {
    return !!qe(e) || (!!Fe(e) || (console.warn(Nt({ api: 'updateMyProfile', param: 'profileCustomField', desc: '必须为数组' })), !1));
  } } }, addFriend: { to: Lt, source: { type: 'String', required: !0, validator(e) {
    return !!e && (e.startsWith('AddSource_Type_') ? !(e.replace('AddSource_Type_', '').length > 8) || (console.warn(Nt({ api: 'addFriend', desc: '加好友来源字段的关键字长度不得超过8字节' })), !1) : (console.warn(Nt({ api: 'addFriend', desc: '加好友来源字段的前缀必须是：AddSource_Type_' })), !1));
  } }, remark: { type: 'String', required: !1, validator(e) {
    return !(be(e) && e.length > 96) || (console.warn(Nt({ api: 'updateFriend', desc: ' 备注长度最长不得超过 96 个字节' })), !1);
  } } }, deleteFriend: { userIDList: Rt }, checkFriend: { userIDList: Rt }, getFriendProfile: { userIDList: Rt }, updateFriend: { userID: Lt, remark: { type: 'String', required: !1, validator(e) {
    return !(be(e) && e.length > 96) || (console.warn(Nt({ api: 'updateFriend', desc: ' 备注长度最长不得超过 96 个字节' })), !1);
  } }, friendCustomField: { type: 'Array', required: !1, validator(e) {
    if (e) {
      if (!Fe(e)) return console.warn(Nt({ api: 'updateFriend', param: 'friendCustomField', desc: '必须为数组' })), !1;let t = !0;return e.forEach((e => (be(e.key) && -1 !== e.key.indexOf('Tag_SNS_Custom') ? be(e.value) ? e.value.length > 8 ? (console.warn(Nt({ api: 'updateFriend', desc: '好友自定义字段的关键字长度不得超过8字节' })), t = !1) : void 0 : (console.warn(Nt({ api: 'updateFriend', desc: '类型必须为 String' })), t = !1) : (console.warn(Nt({ api: 'updateFriend', desc: '好友自定义字段的前缀必须是 Tag_SNS_Custom' })), t = !1)))), t;
    } return !0;
  } } }, acceptFriendApplication: { userID: Lt }, refuseFriendApplication: { userID: Lt }, deleteFriendApplication: { userID: Lt }, createFriendGroup: { name: Lt }, deleteFriendGroup: { name: Lt }, addToFriendGroup: { name: Lt, userIDList: Rt }, removeFromFriendGroup: { name: Lt, userIDList: Rt }, renameFriendGroup: { oldName: Lt, newName: Lt } }; const wt = { login: 'login', logout: 'logout', on: 'on', once: 'once', off: 'off', setLogLevel: 'setLogLevel', registerPlugin: 'registerPlugin', destroy: 'destroy', createTextMessage: 'createTextMessage', createTextAtMessage: 'createTextAtMessage', createImageMessage: 'createImageMessage', createAudioMessage: 'createAudioMessage', createVideoMessage: 'createVideoMessage', createCustomMessage: 'createCustomMessage', createFaceMessage: 'createFaceMessage', createFileMessage: 'createFileMessage', createLocationMessage: 'createLocationMessage', createMergerMessage: 'createMergerMessage', downloadMergerMessage: 'downloadMergerMessage', createForwardMessage: 'createForwardMessage', sendMessage: 'sendMessage', resendMessage: 'resendMessage', revokeMessage: 'revokeMessage', deleteMessage: 'deleteMessage', getMessageList: 'getMessageList', setMessageRead: 'setMessageRead', setAllMessageRead: 'setAllMessageRead', getConversationList: 'getConversationList', getConversationProfile: 'getConversationProfile', deleteConversation: 'deleteConversation', pinConversation: 'pinConversation', getGroupList: 'getGroupList', getGroupProfile: 'getGroupProfile', createGroup: 'createGroup', joinGroup: 'joinGroup', updateGroupProfile: 'updateGroupProfile', quitGroup: 'quitGroup', dismissGroup: 'dismissGroup', changeGroupOwner: 'changeGroupOwner', searchGroupByID: 'searchGroupByID', setMessageRemindType: 'setMessageRemindType', handleGroupApplication: 'handleGroupApplication', initGroupAttributes: 'initGroupAttributes', setGroupAttributes: 'setGroupAttributes', deleteGroupAttributes: 'deleteGroupAttributes', getGroupAttributes: 'getGroupAttributes', getGroupMemberProfile: 'getGroupMemberProfile', getGroupMemberList: 'getGroupMemberList', addGroupMember: 'addGroupMember', deleteGroupMember: 'deleteGroupMember', setGroupMemberNameCard: 'setGroupMemberNameCard', setGroupMemberMuteTime: 'setGroupMemberMuteTime', setGroupMemberRole: 'setGroupMemberRole', setGroupMemberCustomField: 'setGroupMemberCustomField', getGroupOnlineMemberCount: 'getGroupOnlineMemberCount', getMyProfile: 'getMyProfile', getUserProfile: 'getUserProfile', updateMyProfile: 'updateMyProfile', getBlacklist: 'getBlacklist', addToBlacklist: 'addToBlacklist', removeFromBlacklist: 'removeFromBlacklist', getFriendList: 'getFriendList', addFriend: 'addFriend', deleteFriend: 'deleteFriend', checkFriend: 'checkFriend', updateFriend: 'updateFriend', getFriendProfile: 'getFriendProfile', getFriendApplicationList: 'getFriendApplicationList', refuseFriendApplication: 'refuseFriendApplication', deleteFriendApplication: 'deleteFriendApplication', acceptFriendApplication: 'acceptFriendApplication', setFriendApplicationRead: 'setFriendApplicationRead', getFriendGroupList: 'getFriendGroupList', createFriendGroup: 'createFriendGroup', renameFriendGroup: 'renameFriendGroup', deleteFriendGroup: 'deleteFriendGroup', addToFriendGroup: 'addToFriendGroup', removeFromFriendGroup: 'removeFromFriendGroup', callExperimentalAPI: 'callExperimentalAPI' }; const bt = 'sign'; const Pt = 'message'; const Ut = 'user'; const Ft = 'c2c'; const qt = 'group'; const Vt = 'sns'; const Kt = 'groupMember'; const xt = 'conversation'; const Bt = 'context'; const Ht = 'storage'; const jt = 'eventStat'; const Wt = 'netMonitor'; const Yt = 'bigDataChannel'; const $t = 'upload'; const zt = 'plugin'; const Jt = 'syncUnreadMessage'; const Xt = 'session'; const Qt = 'channel'; const Zt = 'message_loss_detection'; const en = 'cloudControl'; const tn = 'worker'; const nn = 'pullGroupMessage'; const on = 'qualityStat'; const an = 'commercialConfig'; const sn = (function () {
    function e(n) {
      t(this, e), this._moduleManager = n, this._className = '';
    } return o(e, [{ key: 'isLoggedIn', value() {
      return this._moduleManager.getModule(Bt).isLoggedIn();
    } }, { key: 'isOversea', value() {
      return this._moduleManager.getModule(Bt).isOversea();
    } }, { key: 'getMyUserID', value() {
      return this._moduleManager.getModule(Bt).getUserID();
    } }, { key: 'getModule', value(e) {
      return this._moduleManager.getModule(e);
    } }, { key: 'getPlatform', value() {
      return oe;
    } }, { key: 'getNetworkType', value() {
      return this._moduleManager.getModule(Wt).getNetworkType();
    } }, { key: 'probeNetwork', value() {
      return this._moduleManager.getModule(Wt).probe();
    } }, { key: 'getCloudConfig', value(e) {
      return this._moduleManager.getModule(en).getCloudConfig(e);
    } }, { key: 'emitOuterEvent', value(e, t) {
      this._moduleManager.getOuterEmitterInstance().emit(e, t);
    } }, { key: 'emitInnerEvent', value(e, t) {
      this._moduleManager.getInnerEmitterInstance().emit(e, t);
    } }, { key: 'getInnerEmitterInstance', value() {
      return this._moduleManager.getInnerEmitterInstance();
    } }, { key: 'generateTjgID', value(e) {
      return `${this._moduleManager.getModule(Bt).getTinyID()}-${e.random}`;
    } }, { key: 'filterModifiedMessage', value(e) {
      if (!It(e)) {
        const t = e.filter((e => !0 === e.isModified));t.length > 0 && this.emitOuterEvent(D.MESSAGE_MODIFIED, t);
      }
    } }, { key: 'filterUnmodifiedMessage', value(e) {
      return It(e) ? [] : e.filter((e => !1 === e.isModified));
    } }, { key: 'request', value(e) {
      return this._moduleManager.getModule(Xt).request(e);
    } }, { key: 'canIUse', value(e) {
      return this._moduleManager.getModule(an).hasPurchasedFeature(e);
    } }]), e;
  }()); const rn = 'wslogin'; const cn = 'wslogout'; const un = 'wshello'; const ln = 'KickOther'; const dn = 'getmsg'; const pn = 'authkey'; const gn = 'sendmsg'; const hn = 'send_group_msg'; const _n = 'portrait_get_all'; const fn = 'portrait_set'; const mn = 'black_list_get'; const Mn = 'black_list_add'; const vn = 'black_list_delete'; const yn = 'msgwithdraw'; const In = 'msgreaded'; const Cn = 'set_c2c_peer_mute_notifications'; const Tn = 'get_c2c_peer_mute_notifications'; const Sn = 'getroammsg'; const Dn = 'get_peer_read_time'; const kn = 'delete_c2c_msg_ramble'; const En = 'page_get'; const An = 'get'; const Nn = 'delete'; const Ln = 'top'; const Rn = 'deletemsg'; const On = 'get_joined_group_list'; const Gn = 'get_group_self_member_info'; const wn = 'create_group'; const bn = 'destroy_group'; const Pn = 'modify_group_base_info'; const Un = 'apply_join_group'; const Fn = 'apply_join_group_noauth'; const qn = 'quit_group'; const Vn = 'get_group_public_info'; const Kn = 'change_group_owner'; const xn = 'handle_apply_join_group'; const Bn = 'handle_invite_join_group'; const Hn = 'group_msg_recall'; const jn = 'msg_read_report'; const Wn = 'read_all_unread_msg'; const Yn = 'group_msg_get'; const $n = 'get_pendency'; const zn = 'deletemsg'; const Jn = 'get_msg'; const Xn = 'get_msg_noauth'; const Qn = 'get_online_member_num'; const Zn = 'delete_group_ramble_msg_by_seq'; const eo = 'set_group_attr'; const to = 'modify_group_attr'; const no = 'delete_group_attr'; const oo = 'clear_group_attr'; const ao = 'get_group_attr'; const so = 'get_group_member_info'; const ro = 'get_specified_group_member_info'; const io = 'add_group_member'; const co = 'delete_group_member'; const uo = 'modify_group_member_info'; const lo = 'cos'; const po = 'pre_sig'; const go = 'tim_web_report_v2'; const ho = 'alive'; const _o = 'msg_push'; const fo = 'ws_msg_push_ack'; const mo = 'stat_forceoffline'; const Mo = 'save_relay_json_msg'; const vo = 'get_relay_json_msg'; const yo = 'fetch_config'; const Io = 'push_configv2'; const Co = 'fetch_imsdk_purchase_bitsv2'; const To = 'push_imsdk_purchase_bitsv2'; const So = 'notify2'; const Do = { NO_SDKAPPID: 2e3, NO_ACCOUNT_TYPE: 2001, NO_IDENTIFIER: 2002, NO_USERSIG: 2003, NO_TINYID: 2022, NO_A2KEY: 2023, USER_NOT_LOGGED_IN: 2024, REPEAT_LOGIN: 2025, COS_UNDETECTED: 2040, COS_GET_SIG_FAIL: 2041, MESSAGE_SEND_FAIL: 2100, MESSAGE_LIST_CONSTRUCTOR_NEED_OPTIONS: 2103, MESSAGE_SEND_NEED_MESSAGE_INSTANCE: 2105, MESSAGE_SEND_INVALID_CONVERSATION_TYPE: 2106, MESSAGE_FILE_IS_EMPTY: 2108, MESSAGE_ONPROGRESS_FUNCTION_ERROR: 2109, MESSAGE_REVOKE_FAIL: 2110, MESSAGE_DELETE_FAIL: 2111, MESSAGE_UNREAD_ALL_FAIL: 2112, MESSAGE_IMAGE_SELECT_FILE_FIRST: 2251, MESSAGE_IMAGE_TYPES_LIMIT: 2252, MESSAGE_IMAGE_SIZE_LIMIT: 2253, MESSAGE_AUDIO_UPLOAD_FAIL: 2300, MESSAGE_AUDIO_SIZE_LIMIT: 2301, MESSAGE_VIDEO_UPLOAD_FAIL: 2350, MESSAGE_VIDEO_SIZE_LIMIT: 2351, MESSAGE_VIDEO_TYPES_LIMIT: 2352, MESSAGE_FILE_UPLOAD_FAIL: 2400, MESSAGE_FILE_SELECT_FILE_FIRST: 2401, MESSAGE_FILE_SIZE_LIMIT: 2402, MESSAGE_FILE_URL_IS_EMPTY: 2403, MESSAGE_MERGER_TYPE_INVALID: 2450, MESSAGE_MERGER_KEY_INVALID: 2451, MESSAGE_MERGER_DOWNLOAD_FAIL: 2452, MESSAGE_FORWARD_TYPE_INVALID: 2453, CONVERSATION_NOT_FOUND: 2500, USER_OR_GROUP_NOT_FOUND: 2501, CONVERSATION_UN_RECORDED_TYPE: 2502, ILLEGAL_GROUP_TYPE: 2600, CANNOT_JOIN_WORK: 2601, CANNOT_CHANGE_OWNER_IN_AVCHATROOM: 2620, CANNOT_CHANGE_OWNER_TO_SELF: 2621, CANNOT_DISMISS_Work: 2622, MEMBER_NOT_IN_GROUP: 2623, CANNOT_USE_GRP_ATTR_NOT_AVCHATROOM: 2641, CANNOT_USE_GRP_ATTR_AVCHATROOM_UNJOIN: 2642, JOIN_GROUP_FAIL: 2660, CANNOT_ADD_MEMBER_IN_AVCHATROOM: 2661, CANNOT_JOIN_NON_AVCHATROOM_WITHOUT_LOGIN: 2662, CANNOT_KICK_MEMBER_IN_AVCHATROOM: 2680, NOT_OWNER: 2681, CANNOT_SET_MEMBER_ROLE_IN_WORK_AND_AVCHATROOM: 2682, INVALID_MEMBER_ROLE: 2683, CANNOT_SET_SELF_MEMBER_ROLE: 2684, CANNOT_MUTE_SELF: 2685, NOT_MY_FRIEND: 2700, ALREADY_MY_FRIEND: 2701, FRIEND_GROUP_EXISTED: 2710, FRIEND_GROUP_NOT_EXIST: 2711, FRIEND_APPLICATION_NOT_EXIST: 2716, UPDATE_PROFILE_INVALID_PARAM: 2721, UPDATE_PROFILE_NO_KEY: 2722, ADD_BLACKLIST_INVALID_PARAM: 2740, DEL_BLACKLIST_INVALID_PARAM: 2741, CANNOT_ADD_SELF_TO_BLACKLIST: 2742, ADD_FRIEND_INVALID_PARAM: 2760, NETWORK_ERROR: 2800, NETWORK_TIMEOUT: 2801, NETWORK_BASE_OPTIONS_NO_URL: 2802, NETWORK_UNDEFINED_SERVER_NAME: 2803, NETWORK_PACKAGE_UNDEFINED: 2804, NO_NETWORK: 2805, CONVERTOR_IRREGULAR_PARAMS: 2900, NOTICE_RUNLOOP_UNEXPECTED_CONDITION: 2901, NOTICE_RUNLOOP_OFFSET_LOST: 2902, UNCAUGHT_ERROR: 2903, GET_LONGPOLL_ID_FAILED: 2904, INVALID_OPERATION: 2905, OVER_FREQUENCY_LIMIT: 2996, CANNOT_FIND_PROTOCOL: 2997, CANNOT_FIND_MODULE: 2998, SDK_IS_NOT_READY: 2999, LONG_POLL_KICK_OUT: 91101, MESSAGE_A2KEY_EXPIRED: 20002, ACCOUNT_A2KEY_EXPIRED: 70001, LONG_POLL_API_PARAM_ERROR: 90001, HELLO_ANSWER_KICKED_OUT: 1002, OPEN_SERVICE_OVERLOAD_ERROR: 60022 }; const ko = '无 SDKAppID'; const Eo = '无 userID'; const Ao = '无 userSig'; const No = '无 tinyID'; const Lo = '无 a2key'; const Ro = '用户未登录'; const Oo = '重复登录'; const Go = '未检测到 COS 上传插件'; const wo = '获取 COS 预签名 URL 失败'; const bo = '消息发送失败'; const Po = '需要 Message 的实例'; const Uo = 'Message.conversationType 只能为 "C2C" 或 "GROUP"'; const Fo = '无法发送空文件'; const qo = '回调函数运行时遇到错误，请检查接入侧代码'; const Vo = '消息撤回失败'; const Ko = '消息删除失败'; const xo = '设置所有未读消息为已读处理失败'; const Bo = '请先选择一个图片'; const Ho = '只允许上传 jpg png jpeg gif bmp image 格式的图片'; const jo = '图片大小超过20M，无法发送'; const Wo = '语音上传失败'; const Yo = '语音大小大于20M，无法发送'; const $o = '视频上传失败'; const zo = '视频大小超过100M，无法发送'; const Jo = '只允许上传 mp4 格式的视频'; const Xo = '文件上传失败'; const Qo = '请先选择一个文件'; const Zo = '文件大小超过100M，无法发送 '; const ea = '缺少必要的参数文件 URL'; const ta = '非合并消息'; const na = '合并消息的 messageKey 无效'; const oa = '下载合并消息失败'; const aa = '选择的消息类型（如群提示消息）不可以转发'; const sa = '没有找到相应的会话，请检查传入参数'; const ra = '没有找到相应的用户或群组，请检查传入参数'; const ia = '未记录的会话类型'; const ca = '非法的群类型，请检查传入参数'; const ua = '不能加入 Work 类型的群组'; const la = 'AVChatRoom 类型的群组不能转让群主'; const da = '不能把群主转让给自己'; const pa = '不能解散 Work 类型的群组'; const ga = '用户不在该群组内'; const ha = '加群失败，请检查传入参数或重试'; const _a = 'AVChatRoom 类型的群不支持邀请群成员'; const fa = '非 AVChatRoom 类型的群组不允许匿名加群，请先登录后再加群'; const ma = '不能在 AVChatRoom 类型的群组踢人'; const Ma = '你不是群主，只有群主才有权限操作'; const va = '不能在 Work / AVChatRoom 类型的群中设置群成员身份'; const ya = '不合法的群成员身份，请检查传入参数'; const Ia = '不能设置自己的群成员身份，请检查传入参数'; const Ca = '不能将自己禁言，请检查传入参数'; const Ta = '传入 updateMyProfile 接口的参数无效'; const Sa = 'updateMyProfile 无标配资料字段或自定义资料字段'; const Da = '传入 addToBlacklist 接口的参数无效'; const ka = '传入 removeFromBlacklist 接口的参数无效'; const Ea = '不能拉黑自己'; const Aa = '网络错误'; const Na = '请求超时'; const La = '未连接到网络'; const Ra = '无效操作，如调用了未定义或者未实现的方法等'; const Oa = '无法找到协议'; const Ga = '无法找到模块'; const wa = '接口需要 SDK 处于 ready 状态后才能调用'; const ba = '超出 SDK 频率控制'; const Pa = '后台服务正忙，请稍后再试'; const Ua = 'networkRTT'; const Fa = 'messageE2EDelay'; const qa = 'sendMessageC2C'; const Va = 'sendMessageGroup'; const Ka = 'sendMessageGroupAV'; const xa = 'sendMessageRichMedia'; const Ba = 'cosUpload'; const Ha = 'messageReceivedGroup'; const ja = 'messageReceivedGroupAVPush'; const Wa = 'messageReceivedGroupAVPull'; const Ya = (a(St = {}, Ua, 2), a(St, Fa, 3), a(St, qa, 4), a(St, Va, 5), a(St, Ka, 6), a(St, xa, 7), a(St, Ha, 8), a(St, ja, 9), a(St, Wa, 10), a(St, Ba, 11), St); const $a = { info: 4, warning: 5, error: 6 }; const za = { wifi: 1, '2g': 2, '3g': 3, '4g': 4, '5g': 5, unknown: 6, none: 7, online: 8 }; const Ja = { login: 4 }; const Xa = (function () {
    function n(e) {
      t(this, n), this.eventType = Ja[e] || 0, this.timestamp = 0, this.networkType = 8, this.code = 0, this.message = '', this.moreMessage = '', this.extension = e, this.costTime = 0, this.duplicate = !1, this.level = 4, this._sentFlag = !1, this._startts = Ee();
    } return o(n, [{ key: 'updateTimeStamp', value() {
      this.timestamp = Ee();
    } }, { key: 'start', value(e) {
      return this._startts = e, this;
    } }, { key: 'end', value() {
      const e = this; const t = arguments.length > 0 && void 0 !== arguments[0] && arguments[0];if (!this._sentFlag) {
        const n = Ee();0 === this.costTime && (this.costTime = n - this._startts), this.setMoreMessage('startts:'.concat(this._startts, ' endts:').concat(n)), t ? (this._sentFlag = !0, this._eventStatModule && this._eventStatModule.pushIn(this)) : setTimeout((() => {
          e._sentFlag = !0, e._eventStatModule && e._eventStatModule.pushIn(e);
        }), 0);
      }
    } }, { key: 'setError', value(e, t, n) {
      return e instanceof Error ? (this._sentFlag || (this.setNetworkType(n), t ? (e.code && this.setCode(e.code), e.message && this.setMoreMessage(e.message)) : (this.setCode(Do.NO_NETWORK), this.setMoreMessage(La)), this.setLevel('error')), this) : (Oe.warn('SSOLogData.setError value not instanceof Error, please check!'), this);
    } }, { key: 'setCode', value(t) {
      return qe(t) || this._sentFlag || ('ECONNABORTED' === t && (this.code = 103), we(t) ? this.code = t : Oe.warn('SSOLogData.setCode value not a number, please check!', t, e(t))), this;
    } }, { key: 'setMessage', value(e) {
      return qe(e) || this._sentFlag || (we(e) && (this.message = e.toString()), be(e) && (this.message = e)), this;
    } }, { key: 'setCostTime', value(e) {
      return this.costTime = e, this;
    } }, { key: 'setLevel', value(e) {
      return qe(e) || this._sentFlag || (this.level = $a[e]), this;
    } }, { key: 'setMoreMessage', value(e) {
      return It(this.moreMessage) ? this.moreMessage = ''.concat(e) : this.moreMessage += ' '.concat(e), this;
    } }, { key: 'setNetworkType', value(e) {
      if (qe(e))Oe.warn('SSOLogData.setNetworkType value is undefined, please check!');else {
        const t = za[e.toLowerCase()];qe(t) || (this.networkType = t);
      } return this;
    } }, { key: 'getStartTs', value() {
      return this._startts;
    } }], [{ key: 'bindEventStatModule', value(e) {
      n.prototype._eventStatModule = e;
    } }]), n;
  }()); const Qa = 'sdkConstruct'; const Za = 'sdkReady'; const es = 'login'; const ts = 'logout'; const ns = 'kickedOut'; const os = 'registerPlugin'; const as = 'kickOther'; const ss = 'wsConnect'; const rs = 'wsOnOpen'; const is = 'wsOnClose'; const cs = 'wsOnError'; const us = 'networkChange'; const ls = 'getCosAuthKey'; const ds = 'getCosPreSigUrl'; const ps = 'upload'; const gs = 'sendMessage'; const hs = 'getC2CRoamingMessages'; const _s = 'getGroupRoamingMessages'; const fs = 'revokeMessage'; const ms = 'deleteMessage'; const Ms = 'setC2CMessageRead'; const vs = 'setGroupMessageRead'; const ys = 'emptyMessageBody'; const Is = 'getPeerReadTime'; const Cs = 'uploadMergerMessage'; const Ts = 'downloadMergerMessage'; const Ss = 'jsonParseError'; const Ds = 'messageE2EDelayException'; const ks = 'getConversationList'; const Es = 'getConversationProfile'; const As = 'deleteConversation'; const Ns = 'pinConversation'; const Ls = 'getConversationListInStorage'; const Rs = 'syncConversationList'; const Os = 'setAllMessageRead'; const Gs = 'createGroup'; const ws = 'applyJoinGroup'; const bs = 'quitGroup'; const Ps = 'searchGroupByID'; const Us = 'changeGroupOwner'; const Fs = 'handleGroupApplication'; const qs = 'handleGroupInvitation'; const Vs = 'setMessageRemindType'; const Ks = 'dismissGroup'; const xs = 'updateGroupProfile'; const Bs = 'getGroupList'; const Hs = 'getGroupProfile'; const js = 'getGroupListInStorage'; const Ws = 'getGroupLastSequence'; const Ys = 'getGroupMissingMessage'; const $s = 'pagingGetGroupList'; const zs = 'getGroupSimplifiedInfo'; const Js = 'joinWithoutAuth'; const Xs = 'initGroupAttributes'; const Qs = 'setGroupAttributes'; const Zs = 'deleteGroupAttributes'; const er = 'getGroupAttributes'; const tr = 'getGroupMemberList'; const nr = 'getGroupMemberProfile'; const or = 'addGroupMember'; const ar = 'deleteGroupMember'; const sr = 'setGroupMemberMuteTime'; const rr = 'setGroupMemberNameCard'; const ir = 'setGroupMemberRole'; const cr = 'setGroupMemberCustomField'; const ur = 'getGroupOnlineMemberCount'; const lr = 'longPollingAVError'; const dr = 'messageLoss'; const pr = 'messageStacked'; const gr = 'getUserProfile'; const hr = 'updateMyProfile'; const _r = 'getBlacklist'; const fr = 'addToBlacklist'; const mr = 'removeFromBlacklist'; const Mr = 'callbackFunctionError'; const vr = 'fetchCloudControlConfig'; const yr = 'pushedCloudControlConfig'; const Ir = 'fetchCommercialConfig'; const Cr = 'pushedCommercialConfig'; const Tr = 'error'; const Sr = 'lastMessageNotExist'; const Dr = (function () {
    function e(n) {
      t(this, e), this.type = k.MSG_TEXT, this.content = { text: n.text || '' };
    } return o(e, [{ key: 'setText', value(e) {
      this.content.text = e;
    } }, { key: 'sendable', value() {
      return 0 !== this.content.text.length;
    } }]), e;
  }()); const kr = { JSON: { TYPE: { C2C: { NOTICE: 1, COMMON: 9, EVENT: 10 }, GROUP: { COMMON: 3, TIP: 4, SYSTEM: 5, TIP2: 6 }, FRIEND: { NOTICE: 7 }, PROFILE: { NOTICE: 8 } }, SUBTYPE: { C2C: { COMMON: 0, READED: 92, KICKEDOUT: 96 }, GROUP: { COMMON: 0, LOVEMESSAGE: 1, TIP: 2, REDPACKET: 3 } }, OPTIONS: { GROUP: { JOIN: 1, QUIT: 2, KICK: 3, SET_ADMIN: 4, CANCEL_ADMIN: 5, MODIFY_GROUP_INFO: 6, MODIFY_MEMBER_INFO: 7 } } }, PROTOBUF: {}, IMAGE_TYPES: { ORIGIN: 1, LARGE: 2, SMALL: 3 }, IMAGE_FORMAT: { JPG: 1, JPEG: 1, GIF: 2, PNG: 3, BMP: 4, UNKNOWN: 255 } }; const Er = { NICK: 'Tag_Profile_IM_Nick', GENDER: 'Tag_Profile_IM_Gender', BIRTHDAY: 'Tag_Profile_IM_BirthDay', LOCATION: 'Tag_Profile_IM_Location', SELFSIGNATURE: 'Tag_Profile_IM_SelfSignature', ALLOWTYPE: 'Tag_Profile_IM_AllowType', LANGUAGE: 'Tag_Profile_IM_Language', AVATAR: 'Tag_Profile_IM_Image', MESSAGESETTINGS: 'Tag_Profile_IM_MsgSettings', ADMINFORBIDTYPE: 'Tag_Profile_IM_AdminForbidType', LEVEL: 'Tag_Profile_IM_Level', ROLE: 'Tag_Profile_IM_Role' }; const Ar = { UNKNOWN: 'Gender_Type_Unknown', FEMALE: 'Gender_Type_Female', MALE: 'Gender_Type_Male' }; const Nr = { NONE: 'AdminForbid_Type_None', SEND_OUT: 'AdminForbid_Type_SendOut' }; const Lr = { NEED_CONFIRM: 'AllowType_Type_NeedConfirm', ALLOW_ANY: 'AllowType_Type_AllowAny', DENY_ANY: 'AllowType_Type_DenyAny' }; const Rr = 'JoinedSuccess'; const Or = 'WaitAdminApproval'; const Gr = (function () {
    function e(n) {
      t(this, e), this._imageMemoryURL = '', ee ? this.createImageDataASURLInWXMiniApp(n.file) : this.createImageDataASURLInWeb(n.file), this._initImageInfoModel(), this.type = k.MSG_IMAGE, this._percent = 0, this.content = { imageFormat: n.imageFormat || kr.IMAGE_FORMAT.UNKNOWN, uuid: n.uuid, imageInfoArray: [] }, this.initImageInfoArray(n.imageInfoArray), this._defaultImage = 'http://imgcache.qq.com/open/qcloud/video/act/webim-images/default.jpg', this._autoFixUrl();
    } return o(e, [{ key: '_initImageInfoModel', value() {
      const e = this;this._ImageInfoModel = function (t) {
        this.instanceID = Je(9999999), this.sizeType = t.type || 0, this.type = 0, this.size = t.size || 0, this.width = t.width || 0, this.height = t.height || 0, this.imageUrl = t.url || '', this.url = t.url || e._imageMemoryURL || e._defaultImage;
      }, this._ImageInfoModel.prototype = { setSizeType(e) {
        this.sizeType = e;
      }, setType(e) {
        this.type = e;
      }, setImageUrl(e) {
        e && (this.imageUrl = e);
      }, getImageUrl() {
        return this.imageUrl;
      } };
    } }, { key: 'initImageInfoArray', value(e) {
      for (let t = 0, n = null, o = null;t <= 2;)o = qe(e) || qe(e[t]) ? { type: 0, size: 0, width: 0, height: 0, url: '' } : e[t], (n = new this._ImageInfoModel(o)).setSizeType(t + 1), n.setType(t), this.addImageInfo(n), t++;this.updateAccessSideImageInfoArray();
    } }, { key: 'updateImageInfoArray', value(e) {
      for (var t, n = this.content.imageInfoArray.length, o = 0;o < n;o++)t = this.content.imageInfoArray[o], e[o].size && (t.size = e[o].size), e[o].url && t.setImageUrl(e[o].url), e[o].width && (t.width = e[o].width), e[o].height && (t.height = e[o].height);
    } }, { key: '_autoFixUrl', value() {
      for (let e = this.content.imageInfoArray.length, t = '', n = '', o = ['http', 'https'], a = null, s = 0;s < e;s++) this.content.imageInfoArray[s].url && '' !== (a = this.content.imageInfoArray[s]).imageUrl && (n = a.imageUrl.slice(0, a.imageUrl.indexOf('://') + 1), t = a.imageUrl.slice(a.imageUrl.indexOf('://') + 1), o.indexOf(n) < 0 && (n = 'https:'), this.content.imageInfoArray[s].setImageUrl([n, t].join('')));
    } }, { key: 'updatePercent', value(e) {
      this._percent = e, this._percent > 1 && (this._percent = 1);
    } }, { key: 'updateImageFormat', value(e) {
      this.content.imageFormat = kr.IMAGE_FORMAT[e.toUpperCase()] || kr.IMAGE_FORMAT.UNKNOWN;
    } }, { key: 'createImageDataASURLInWeb', value(e) {
      void 0 !== e && e.files.length > 0 && (this._imageMemoryURL = window.URL.createObjectURL(e.files[0]));
    } }, { key: 'createImageDataASURLInWXMiniApp', value(e) {
      e && e.url && (this._imageMemoryURL = e.url);
    } }, { key: 'replaceImageInfo', value(e, t) {
      this.content.imageInfoArray[t] instanceof this._ImageInfoModel || (this.content.imageInfoArray[t] = e);
    } }, { key: 'addImageInfo', value(e) {
      this.content.imageInfoArray.length >= 3 || this.content.imageInfoArray.push(e);
    } }, { key: 'updateAccessSideImageInfoArray', value() {
      const e = this.content.imageInfoArray; const t = e[0]; const n = t.width; const o = void 0 === n ? 0 : n; const a = t.height; const s = void 0 === a ? 0 : a;0 !== o && 0 !== s && (_t(e), Object.assign(e[2], ht({ originWidth: o, originHeight: s, min: 720 })));
    } }, { key: 'sendable', value() {
      return 0 !== this.content.imageInfoArray.length && ('' !== this.content.imageInfoArray[0].imageUrl && 0 !== this.content.imageInfoArray[0].size);
    } }]), e;
  }()); const wr = (function () {
    function e(n) {
      t(this, e), this.type = k.MSG_FACE, this.content = n || null;
    } return o(e, [{ key: 'sendable', value() {
      return null !== this.content;
    } }]), e;
  }()); const br = (function () {
    function e(n) {
      t(this, e), this.type = k.MSG_AUDIO, this._percent = 0, this.content = { downloadFlag: 2, second: n.second, size: n.size, url: n.url, remoteAudioUrl: n.url || '', uuid: n.uuid };
    } return o(e, [{ key: 'updatePercent', value(e) {
      this._percent = e, this._percent > 1 && (this._percent = 1);
    } }, { key: 'updateAudioUrl', value(e) {
      this.content.remoteAudioUrl = e;
    } }, { key: 'sendable', value() {
      return '' !== this.content.remoteAudioUrl;
    } }]), e;
  }()); const Pr = { from: !0, groupID: !0, groupName: !0, to: !0 }; const Ur = (function () {
    function e(n) {
      t(this, e), this.type = k.MSG_GRP_TIP, this.content = {}, this._initContent(n);
    } return o(e, [{ key: '_initContent', value(e) {
      const t = this;Object.keys(e).forEach(((n) => {
        switch (n) {
          case 'remarkInfo':break;case 'groupProfile':t.content.groupProfile = {}, t._initGroupProfile(e[n]);break;case 'operatorInfo':case 'memberInfoList':break;case 'msgMemberInfo':t.content.memberList = e[n], Object.defineProperty(t.content, 'msgMemberInfo', { get() {
            return Oe.warn('!!! 禁言的群提示消息中的 payload.msgMemberInfo 属性即将废弃，请使用 payload.memberList 属性替代。 \n', 'msgMemberInfo 中的 shutupTime 属性对应更改为 memberList 中的 muteTime 属性，表示禁言时长。 \n', '参考：群提示消息 https://web.sdk.qcloud.com/im/doc/zh-cn/Message.html#.GroupTipPayload'), t.content.memberList.map((e => ({ userID: e.userID, shutupTime: e.muteTime })));
          } });break;case 'onlineMemberInfo':break;case 'memberNum':t.content[n] = e[n], t.content.memberCount = e[n];break;default:t.content[n] = e[n];
        }
      })), this.content.userIDList || (this.content.userIDList = [this.content.operatorID]);
    } }, { key: '_initGroupProfile', value(e) {
      for (let t = Object.keys(e), n = 0;n < t.length;n++) {
        const o = t[n];Pr[o] && (this.content.groupProfile[o] = e[o]);
      }
    } }]), e;
  }()); const Fr = { from: !0, groupID: !0, groupName: !0, to: !0 }; const qr = (function () {
    function e(n) {
      t(this, e), this.type = k.MSG_GRP_SYS_NOTICE, this.content = {}, this._initContent(n);
    } return o(e, [{ key: '_initContent', value(e) {
      const t = this;Object.keys(e).forEach(((n) => {
        switch (n) {
          case 'memberInfoList':break;case 'remarkInfo':t.content.handleMessage = e[n];break;case 'groupProfile':t.content.groupProfile = {}, t._initGroupProfile(e[n]);break;default:t.content[n] = e[n];
        }
      }));
    } }, { key: '_initGroupProfile', value(e) {
      for (let t = Object.keys(e), n = 0;n < t.length;n++) {
        const o = t[n];Fr[o] && ('groupName' === o ? this.content.groupProfile.name = e[o] : this.content.groupProfile[o] = e[o]);
      }
    } }]), e;
  }()); const Vr = (function () {
    function e(n) {
      t(this, e), this.type = k.MSG_FILE, this._percent = 0;const o = this._getFileInfo(n);this.content = { downloadFlag: 2, fileUrl: n.url || '', uuid: n.uuid, fileName: o.name || '', fileSize: o.size || 0 };
    } return o(e, [{ key: '_getFileInfo', value(e) {
      if (!qe(e.fileName) && !qe(e.fileSize)) return { size: e.fileSize, name: e.fileName };const t = e.file.files[0];if (Z) {
        if (t.path && -1 !== t.path.indexOf('.')) {
          const n = t.path.slice(t.path.lastIndexOf('.') + 1).toLowerCase();t.type = n, t.name || (t.name = ''.concat(Je(999999), '.').concat(n));
        }t.name || (t.type = '', t.name = t.path.slice(t.path.lastIndexOf('/') + 1).toLowerCase()), t.suffix && (t.type = t.suffix), t.url || (t.url = t.path);
      } return { size: t.size, name: t.name };
    } }, { key: 'updatePercent', value(e) {
      this._percent = e, this._percent > 1 && (this._percent = 1);
    } }, { key: 'updateFileUrl', value(e) {
      this.content.fileUrl = e;
    } }, { key: 'sendable', value() {
      return '' !== this.content.fileUrl && ('' !== this.content.fileName && 0 !== this.content.fileSize);
    } }]), e;
  }()); const Kr = (function () {
    function e(n) {
      t(this, e), this.type = k.MSG_CUSTOM, this.content = { data: n.data || '', description: n.description || '', extension: n.extension || '' };
    } return o(e, [{ key: 'setData', value(e) {
      return this.content.data = e, this;
    } }, { key: 'setDescription', value(e) {
      return this.content.description = e, this;
    } }, { key: 'setExtension', value(e) {
      return this.content.extension = e, this;
    } }, { key: 'sendable', value() {
      return 0 !== this.content.data.length || 0 !== this.content.description.length || 0 !== this.content.extension.length;
    } }]), e;
  }()); const xr = (function () {
    function e(n) {
      t(this, e), this.type = k.MSG_VIDEO, this._percent = 0, this.content = { remoteVideoUrl: n.remoteVideoUrl || n.videoUrl || '', videoFormat: n.videoFormat, videoSecond: parseInt(n.videoSecond, 10), videoSize: n.videoSize, videoUrl: n.videoUrl, videoDownloadFlag: 2, videoUUID: n.videoUUID, thumbUUID: n.thumbUUID, thumbFormat: n.thumbFormat, thumbWidth: n.thumbWidth, thumbHeight: n.thumbHeight, thumbSize: n.thumbSize, thumbDownloadFlag: 2, thumbUrl: n.thumbUrl };
    } return o(e, [{ key: 'updatePercent', value(e) {
      this._percent = e, this._percent > 1 && (this._percent = 1);
    } }, { key: 'updateVideoUrl', value(e) {
      e && (this.content.remoteVideoUrl = e);
    } }, { key: 'sendable', value() {
      return '' !== this.content.remoteVideoUrl;
    } }]), e;
  }()); const Br = (function () {
    function e(n) {
      t(this, e), this.type = k.MSG_LOCATION;const o = n.description; const a = n.longitude; const s = n.latitude;this.content = { description: o, longitude: a, latitude: s };
    } return o(e, [{ key: 'sendable', value() {
      return !0;
    } }]), e;
  }()); const Hr = (function () {
    function e(n) {
      if (t(this, e), this.from = n.from, this.messageSender = n.from, this.time = n.time, this.messageSequence = n.sequence, this.clientSequence = n.clientSequence || n.sequence, this.messageRandom = n.random, this.cloudCustomData = n.cloudCustomData || '', n.ID) this.nick = n.nick || '', this.avatar = n.avatar || '', this.messageBody = [{ type: n.type, payload: n.payload }], n.conversationType.startsWith(k.CONV_C2C) ? this.receiverUserID = n.to : n.conversationType.startsWith(k.CONV_GROUP) && (this.receiverGroupID = n.to), this.messageReceiver = n.to;else {
        this.nick = n.nick || '', this.avatar = n.avatar || '', this.messageBody = [];const o = n.elements[0].type; const a = n.elements[0].content;this._patchRichMediaPayload(o, a), o === k.MSG_MERGER ? this.messageBody.push({ type: o, payload: new jr(a).content }) : this.messageBody.push({ type: o, payload: a }), n.groupID && (this.receiverGroupID = n.groupID, this.messageReceiver = n.groupID), n.to && (this.receiverUserID = n.to, this.messageReceiver = n.to);
      }
    } return o(e, [{ key: '_patchRichMediaPayload', value(e, t) {
      e === k.MSG_IMAGE ? t.imageInfoArray.forEach(((e) => {
        !e.imageUrl && e.url && (e.imageUrl = e.url, e.sizeType = e.type, 1 === e.type ? e.type = 0 : 3 === e.type && (e.type = 1));
      })) : e === k.MSG_VIDEO ? !t.remoteVideoUrl && t.videoUrl && (t.remoteVideoUrl = t.videoUrl) : e === k.MSG_AUDIO ? !t.remoteAudioUrl && t.url && (t.remoteAudioUrl = t.url) : e === k.MSG_FILE && !t.fileUrl && t.url && (t.fileUrl = t.url, t.url = void 0);
    } }]), e;
  }()); var jr = (function () {
    function e(n) {
      if (t(this, e), this.type = k.MSG_MERGER, this.content = { downloadKey: '', pbDownloadKey: '', messageList: [], title: '', abstractList: [], compatibleText: '', version: 0, layersOverLimit: !1 }, n.downloadKey) {
        const o = n.downloadKey; const a = n.pbDownloadKey; const s = n.title; const r = n.abstractList; const i = n.compatibleText; const c = n.version;this.content.downloadKey = o, this.content.pbDownloadKey = a, this.content.title = s, this.content.abstractList = r, this.content.compatibleText = i, this.content.version = c || 0;
      } else if (It(n.messageList))1 === n.layersOverLimit && (this.content.layersOverLimit = !0);else {
        const u = n.messageList; const l = n.title; const d = n.abstractList; const p = n.compatibleText; const g = n.version; const h = [];u.forEach(((e) => {
          if (!It(e)) {
            const t = new Hr(e);h.push(t);
          }
        })), this.content.messageList = h, this.content.title = l, this.content.abstractList = d, this.content.compatibleText = p, this.content.version = g || 0;
      }Oe.debug('MergerElement.content:', this.content);
    } return o(e, [{ key: 'sendable', value() {
      return !It(this.content.messageList) || !It(this.content.downloadKey);
    } }]), e;
  }()); const Wr = { 1: k.MSG_PRIORITY_HIGH, 2: k.MSG_PRIORITY_NORMAL, 3: k.MSG_PRIORITY_LOW, 4: k.MSG_PRIORITY_LOWEST }; const Yr = (function () {
    function e(n) {
      t(this, e), this.ID = '', this.conversationID = n.conversationID || null, this.conversationType = n.conversationType || k.CONV_C2C, this.conversationSubType = n.conversationSubType, this.time = n.time || Math.ceil(Date.now() / 1e3), this.sequence = n.sequence || 0, this.clientSequence = n.clientSequence || n.sequence || 0, this.random = n.random || 0 === n.random ? n.random : Je(), this.priority = this._computePriority(n.priority), this.nick = n.nick || '', this.avatar = n.avatar || '', this.isPeerRead = !1, this.nameCard = '', this._elements = [], this.isPlaceMessage = n.isPlaceMessage || 0, this.isRevoked = 2 === n.isPlaceMessage || 8 === n.msgFlagBits, this.from = n.from || null, this.to = n.to || null, this.flow = '', this.isSystemMessage = n.isSystemMessage || !1, this.protocol = n.protocol || 'JSON', this.isResend = !1, this.isRead = !1, this.status = n.status || Dt.SUCCESS, this._onlineOnlyFlag = !1, this._groupAtInfoList = [], this._relayFlag = !1, this.atUserList = [], this.cloudCustomData = n.cloudCustomData || '', this.isDeleted = !1, this.isModified = !1, this._isExcludedFromUnreadCount = !(!n.messageControlInfo || 1 !== n.messageControlInfo.excludedFromUnreadCount), this._isExcludedFromLastMessage = !(!n.messageControlInfo || 1 !== n.messageControlInfo.excludedFromLastMessage), this.reInitialize(n.currentUser), this.extractGroupInfo(n.groupProfile || null), this.handleGroupAtInfo(n);
    } return o(e, [{ key: 'getElements', value() {
      return this._elements;
    } }, { key: 'extractGroupInfo', value(e) {
      if (null !== e) {
        be(e.nick) && (this.nick = e.nick), be(e.avatar) && (this.avatar = e.avatar);const t = e.messageFromAccountExtraInformation;Ue(t) && be(t.nameCard) && (this.nameCard = t.nameCard);
      }
    } }, { key: 'handleGroupAtInfo', value(e) {
      const t = this;e.payload && e.payload.atUserList && e.payload.atUserList.forEach(((e) => {
        e !== k.MSG_AT_ALL ? (t._groupAtInfoList.push({ groupAtAllFlag: 0, groupAtUserID: e }), t.atUserList.push(e)) : (t._groupAtInfoList.push({ groupAtAllFlag: 1 }), t.atUserList.push(k.MSG_AT_ALL));
      })), Fe(e.groupAtInfo) && e.groupAtInfo.forEach(((e) => {
        0 === e.groupAtAllFlag ? t.atUserList.push(e.groupAtUserID) : 1 === e.groupAtAllFlag && t.atUserList.push(k.MSG_AT_ALL);
      }));
    } }, { key: 'getGroupAtInfoList', value() {
      return this._groupAtInfoList;
    } }, { key: '_initProxy', value() {
      this._elements[0] && (this.payload = this._elements[0].content, this.type = this._elements[0].type);
    } }, { key: 'reInitialize', value(e) {
      e && (this.status = this.from ? Dt.SUCCESS : Dt.UNSEND, !this.from && (this.from = e)), this._initFlow(e), this._initSequence(e), this._concatConversationID(e), this.generateMessageID(e);
    } }, { key: 'isSendable', value() {
      return 0 !== this._elements.length && ('function' !== typeof this._elements[0].sendable ? (Oe.warn(''.concat(this._elements[0].type, ' need "boolean : sendable()" method')), !1) : this._elements[0].sendable());
    } }, { key: '_initTo', value(e) {
      this.conversationType === k.CONV_GROUP && (this.to = e.groupID);
    } }, { key: '_initSequence', value(e) {
      0 === this.clientSequence && e && (this.clientSequence = (function (e) {
        if (!e) return Oe.error('autoIncrementIndex(string: key) need key parameter'), !1;if (void 0 === et[e]) {
          const t = new Date; let n = '3'.concat(t.getHours()).slice(-2); let o = '0'.concat(t.getMinutes()).slice(-2); let a = '0'.concat(t.getSeconds()).slice(-2);et[e] = parseInt([n, o, a, '0001'].join('')), n = null, o = null, a = null, Oe.log('autoIncrementIndex start index:'.concat(et[e]));
        } return et[e]++;
      }(e))), 0 === this.sequence && this.conversationType === k.CONV_C2C && (this.sequence = this.clientSequence);
    } }, { key: 'generateMessageID', value(e) {
      const t = e === this.from ? 1 : 0; const n = this.sequence > 0 ? this.sequence : this.clientSequence;this.ID = ''.concat(this.conversationID, '-').concat(n, '-')
        .concat(this.random, '-')
        .concat(t);
    } }, { key: '_initFlow', value(e) {
      '' !== e && (e === this.from ? (this.flow = 'out', this.isRead = !0) : this.flow = 'in');
    } }, { key: '_concatConversationID', value(e) {
      const t = this.to; let n = ''; const o = this.conversationType;o !== k.CONV_SYSTEM ? (n = o === k.CONV_C2C ? e === this.from ? t : this.from : this.to, this.conversationID = ''.concat(o).concat(n)) : this.conversationID = k.CONV_SYSTEM;
    } }, { key: 'isElement', value(e) {
      return e instanceof Dr || e instanceof Gr || e instanceof wr || e instanceof br || e instanceof Vr || e instanceof xr || e instanceof Ur || e instanceof qr || e instanceof Kr || e instanceof Br || e instanceof jr;
    } }, { key: 'setElement', value(e) {
      const t = this;if (this.isElement(e)) return this._elements = [e], void this._initProxy();const n = function (e) {
        if (e.type && e.content) switch (e.type) {
          case k.MSG_TEXT:t.setTextElement(e.content);break;case k.MSG_IMAGE:t.setImageElement(e.content);break;case k.MSG_AUDIO:t.setAudioElement(e.content);break;case k.MSG_FILE:t.setFileElement(e.content);break;case k.MSG_VIDEO:t.setVideoElement(e.content);break;case k.MSG_CUSTOM:t.setCustomElement(e.content);break;case k.MSG_LOCATION:t.setLocationElement(e.content);break;case k.MSG_GRP_TIP:t.setGroupTipElement(e.content);break;case k.MSG_GRP_SYS_NOTICE:t.setGroupSystemNoticeElement(e.content);break;case k.MSG_FACE:t.setFaceElement(e.content);break;case k.MSG_MERGER:t.setMergerElement(e.content);break;default:Oe.warn(e.type, e.content, 'no operation......');
        }
      };if (Fe(e)) for (let o = 0;o < e.length;o++)n(e[o]);else n(e);this._initProxy();
    } }, { key: 'clearElement', value() {
      this._elements.length = 0;
    } }, { key: 'setTextElement', value(e) {
      const t = 'string' === typeof e ? e : e.text; const n = new Dr({ text: t });this._elements.push(n);
    } }, { key: 'setImageElement', value(e) {
      const t = new Gr(e);this._elements.push(t);
    } }, { key: 'setAudioElement', value(e) {
      const t = new br(e);this._elements.push(t);
    } }, { key: 'setFileElement', value(e) {
      const t = new Vr(e);this._elements.push(t);
    } }, { key: 'setVideoElement', value(e) {
      const t = new xr(e);this._elements.push(t);
    } }, { key: 'setLocationElement', value(e) {
      const t = new Br(e);this._elements.push(t);
    } }, { key: 'setCustomElement', value(e) {
      const t = new Kr(e);this._elements.push(t);
    } }, { key: 'setGroupTipElement', value(e) {
      let t = {}; const n = e.operationType;It(e.memberInfoList) ? e.operatorInfo && (t = e.operatorInfo) : n !== k.GRP_TIP_MBR_JOIN && n !== k.GRP_TIP_MBR_KICKED_OUT && n !== k.GRP_TIP_MBR_SET_ADMIN && n !== k.GRP_TIP_MBR_CANCELED_ADMIN || (t = e.memberInfoList[0]);const o = t; const a = o.nick; const s = o.avatar;be(a) && (this.nick = a), be(s) && (this.avatar = s);const r = new Ur(e);this._elements.push(r);
    } }, { key: 'setGroupSystemNoticeElement', value(e) {
      const t = new qr(e);this._elements.push(t);
    } }, { key: 'setFaceElement', value(e) {
      const t = new wr(e);this._elements.push(t);
    } }, { key: 'setMergerElement', value(e) {
      const t = new jr(e);this._elements.push(t);
    } }, { key: 'setIsRead', value(e) {
      this.isRead = e;
    } }, { key: 'setRelayFlag', value(e) {
      this._relayFlag = e;
    } }, { key: 'getRelayFlag', value() {
      return this._relayFlag;
    } }, { key: '_computePriority', value(e) {
      if (qe(e)) return k.MSG_PRIORITY_NORMAL;if (be(e) && -1 !== Object.values(Wr).indexOf(e)) return e;if (we(e)) {
        const t = `${e}`;if (-1 !== Object.keys(Wr).indexOf(t)) return Wr[t];
      } return k.MSG_PRIORITY_NORMAL;
    } }, { key: 'setNickAndAvatar', value(e) {
      const t = e.nick; const n = e.avatar;be(t) && (this.nick = t), be(n) && (this.avatar = n);
    } }, { key: 'setNameCard', value(e) {
      be(e) && (this.nameCard = e);
    } }, { key: 'elements', get() {
      return Oe.warn('！！！Message 实例的 elements 属性即将废弃，请尽快修改。使用 type 和 payload 属性处理单条消息，兼容组合消息使用 _elements 属性！！！'), this._elements;
    } }]), e;
  }()); const $r = function (e) {
    return { code: 0, data: e || {} };
  }; const zr = 'https://cloud.tencent.com/document/product/'; const Jr = '您可以在即时通信 IM 控制台的【开发辅助工具(https://console.cloud.tencent.com/im-detail/tool-usersig)】页面校验 UserSig。'; const Xr = 'UserSig 非法，请使用官网提供的 API 重新生成 UserSig('.concat(zr, '269/32688)。'); const Qr = '#.E6.B6.88.E6.81.AF.E5.85.83.E7.B4.A0-timmsgelement'; const Zr = { 70001: 'UserSig 已过期，请重新生成。建议 UserSig 有效期设置不小于24小时。', 70002: 'UserSig 长度为0，请检查传入的 UserSig 是否正确。', 70003: Xr, 70005: Xr, 70009: 'UserSig 验证失败，可能因为生成 UserSig 时混用了其他 SDKAppID 的私钥或密钥导致，请使用对应 SDKAppID 下的私钥或密钥重新生成 UserSig('.concat(zr, '269/32688)。'), 70013: '请求中的 UserID 与生成 UserSig 时使用的 UserID 不匹配。'.concat(Jr), 70014: '请求中的 SDKAppID 与生成 UserSig 时使用的 SDKAppID 不匹配。'.concat(Jr), 70016: '密钥不存在，UserSig 验证失败，请在即时通信 IM 控制台获取密钥('.concat(zr, '269/32578#.E8.8E.B7.E5.8F.96.E5.AF.86.E9.92.A5)。'), 70020: 'SDKAppID 未找到，请在即时通信 IM 控制台确认应用信息。', 70050: 'UserSig 验证次数过于频繁。请检查 UserSig 是否正确，并于1分钟后重新验证。'.concat(Jr), 70051: '帐号被拉入黑名单。', 70052: 'UserSig 已经失效，请重新生成，再次尝试。', 70107: '因安全原因被限制登录，请不要频繁登录。', 70169: '请求的用户帐号不存在。', 70114: ''.concat('服务端内部超时，请稍后重试。'), 70202: ''.concat('服务端内部超时，请稍后重试。'), 70206: '请求中批量数量不合法。', 70402: '参数非法，请检查必填字段是否填充，或者字段的填充是否满足协议要求。', 70403: '请求失败，需要 App 管理员权限。', 70398: '帐号数超限。如需创建多于100个帐号，请将应用升级为专业版，具体操作指引请参见购买指引('.concat(zr, '269/32458)。'), 70500: ''.concat('服务端内部错误，请重试。'), 71e3: '删除帐号失败。仅支持删除体验版帐号，您当前应用为专业版，暂不支持帐号删除。', 20001: '请求包非法。', 20002: 'UserSig 或 A2 失效。', 20003: '消息发送方或接收方 UserID 无效或不存在，请检查 UserID 是否已导入即时通信 IM。', 20004: '网络异常，请重试。', 20005: ''.concat('服务端内部错误，请重试。'), 20006: '触发发送'.concat('单聊消息', '之前回调，App 后台返回禁止下发该消息。'), 20007: '发送'.concat('单聊消息', '，被对方拉黑，禁止发送。消息发送状态默认展示为失败，您可以登录控制台修改该场景下的消息发送状态展示结果，具体操作请参见消息保留设置(').concat(zr, '269/38656)。'), 20009: '消息发送双方互相不是好友，禁止发送（配置'.concat('单聊消息', '校验好友关系才会出现）。'), 20010: '发送'.concat('单聊消息', '，自己不是对方的好友（单向关系），禁止发送。'), 20011: '发送'.concat('单聊消息', '，对方不是自己的好友（单向关系），禁止发送。'), 20012: '发送方被禁言，该条消息被禁止发送。', 20016: '消息撤回超过了时间限制（默认2分钟）。', 20018: '删除漫游内部错误。', 90001: 'JSON 格式解析失败，请检查请求包是否符合 JSON 规范。', 90002: ''.concat('JSON 格式请求包体', '中 MsgBody 不符合消息格式描述，或者 MsgBody 不是 Array 类型，请参考 TIMMsgElement 对象的定义(').concat(zr, '269/2720')
    .concat(Qr, ')。'), 90003: ''.concat('JSON 格式请求包体', '中缺少 To_Account 字段或者 To_Account 帐号不存在。'), 90005: ''.concat('JSON 格式请求包体', '中缺少 MsgRandom 字段或者 MsgRandom 字段不是 Integer 类型。'), 90006: ''.concat('JSON 格式请求包体', '中缺少 MsgTimeStamp 字段或者 MsgTimeStamp 字段不是 Integer 类型。'), 90007: ''.concat('JSON 格式请求包体', '中 MsgBody 类型不是 Array 类型，请将其修改为 Array 类型。'), 90008: ''.concat('JSON 格式请求包体', '中缺少 From_Account 字段或者 From_Account 帐号不存在。'), 90009: '请求需要 App 管理员权限。', 90010: ''.concat('JSON 格式请求包体', '不符合消息格式描述，请参考 TIMMsgElement 对象的定义(').concat(zr, '269/2720')
    .concat(Qr, ')。'), 90011: '批量发消息目标帐号超过500，请减少 To_Account 中目标帐号数量。', 90012: 'To_Account 没有注册或不存在，请确认 To_Account 是否导入即时通信 IM 或者是否拼写错误。', 90026: '消息离线存储时间错误（最多不能超过7天）。', 90031: ''.concat('JSON 格式请求包体', '中 SyncOtherMachine 字段不是 Integer 类型。'), 90044: ''.concat('JSON 格式请求包体', '中 MsgLifeTime 字段不是 Integer 类型。'), 90048: '请求的用户帐号不存在。', 90054: '撤回请求中的 MsgKey 不合法。', 90994: ''.concat('服务端内部错误，请重试。'), 90995: ''.concat('服务端内部错误，请重试。'), 91e3: ''.concat('服务端内部错误，请重试。'), 90992: ''.concat('服务端内部错误，请重试。', '如果所有请求都返回该错误码，且 App 配置了第三方回调，请检查 App 服务端是否正常向即时通信 IM 后台服务端返回回调结果。'), 93e3: 'JSON 数据包超长，消息包体请不要超过8k。', 91101: 'Web 端长轮询被踢（Web 端同时在线实例个数超出限制）。', 10002: ''.concat('服务端内部错误，请重试。'), 10003: '请求中的接口名称错误，请核对接口名称并重试。', 10004: '参数非法，请根据错误描述检查请求是否正确。', 10005: '请求包体中携带的帐号数量过多。', 10006: '操作频率限制，请尝试降低调用的频率。', 10007: '操作权限不足，例如 Work '.concat('群组', '中普通成员尝试执行踢人操作，但只有 App 管理员才有权限。'), 10008: '请求非法，可能是请求中携带的签名信息验证不正确，请再次尝试。', 10009: '该群不允许群主主动退出。', 10010: ''.concat('群组', '不存在，或者曾经存在过，但是目前已经被解散。'), 10011: '解析 JSON 包体失败，请检查包体的格式是否符合 JSON 格式。', 10012: '发起操作的 UserID 非法，请检查发起操作的用户 UserID 是否填写正确。', 10013: '被邀请加入的用户已经是群成员。', 10014: '群已满员，无法将请求中的用户加入'.concat('群组', '，如果是批量加人，可以尝试减少加入用户的数量。'), 10015: '找不到指定 ID 的'.concat('群组', '。'), 10016: 'App 后台通过第三方回调拒绝本次操作。', 10017: '因被禁言而不能发送消息，请检查发送者是否被设置禁言。', 10018: '应答包长度超过最大包长（1MB），请求的内容过多，请尝试减少单次请求的数据量。', 10019: '请求的用户帐号不存在。', 10021: ''.concat('群组', ' ID 已被使用，请选择其他的').concat('群组', ' ID。'), 10023: '发消息的频率超限，请延长两次发消息时间的间隔。', 10024: '此邀请或者申请请求已经被处理。', 10025: ''.concat('群组', ' ID 已被使用，并且操作者为群主，可以直接使用。'), 10026: '该 SDKAppID 请求的命令字已被禁用。', 10030: '请求撤回的消息不存在。', 10031: '消息撤回超过了时间限制（默认2分钟）。', 10032: '请求撤回的消息不支持撤回操作。', 10033: ''.concat('群组', '类型不支持消息撤回操作。'), 10034: '该消息类型不支持删除操作。', 10035: '直播群和在线成员广播大群不支持删除消息。', 10036: '直播群创建数量超过了限制，请参考价格说明('.concat(zr, '269/11673)购买预付费套餐“IM直播群”。'), 10037: '单个用户可创建和加入的'.concat('群组', '数量超过了限制，请参考价格说明(').concat(zr, '269/11673)购买或升级预付费套餐“单人可创建与加入')
    .concat('群组', '数”。'), 10038: '群成员数量超过限制，请参考价格说明('.concat(zr, '269/11673)购买或升级预付费套餐“扩展群人数上限”。'), 10041: '该应用（SDKAppID）已配置不支持群消息撤回。', 10050: '群属性 key 不存在', 10056: '请在写入群属性前先使用 getGroupAttributes 接口更新本地群属性，避免冲突。', 30001: '请求参数错误，请根据错误描述检查请求参数', 30002: 'SDKAppID 不匹配', 30003: '请求的用户帐号不存在', 30004: '请求需要 App 管理员权限', 30005: '关系链字段中包含敏感词', 30006: ''.concat('服务端内部错误，请重试。'), 30007: ''.concat('网络超时，请稍后重试. '), 30008: '并发写导致写冲突，建议使用批量方式', 30009: '后台禁止该用户发起加好友请求', 30010: '自己的好友数已达系统上限', 30011: '分组已达系统上限', 30012: '未决数已达系统上限', 30014: '对方的好友数已达系统上限', 30515: '请求添加好友时，对方在自己的黑名单中，不允许加好友', 30516: '请求添加好友时，对方的加好友验证方式是不允许任何人添加自己为好友', 30525: '请求添加好友时，自己在对方的黑名单中，不允许加好友', 30539: '等待对方同意', 30540: '添加好友请求被安全策略打击，请勿频繁发起添加好友请求', 31704: '与请求删除的帐号之间不存在好友关系', 31707: '删除好友请求被安全策略打击，请勿频繁发起删除好友请求' }; const ei = (function (e) {
    i(o, e);const n = f(o);function o(e) {
      let a;return t(this, o), (a = n.call(this)).code = e.code, a.message = Zr[e.code] || e.message, a.data = e.data || {}, a;
    } return o;
  }(p(Error))); let ti = null; const ni = function (e) {
    ti = e;
  }; const oi = function (e) {
    return Promise.resolve($r(e));
  }; const ai = function (e) {
    const t = arguments.length > 1 && void 0 !== arguments[1] && arguments[1];if (e instanceof ei) return t && null !== ti && ti.emit(D.ERROR, e), Promise.reject(e);if (e instanceof Error) {
      const n = new ei({ code: Do.UNCAUGHT_ERROR, message: e.message });return t && null !== ti && ti.emit(D.ERROR, n), Promise.reject(n);
    } if (qe(e) || qe(e.code) || qe(e.message))Oe.error('IMPromise.reject 必须指定code(错误码)和message(错误信息)!!!');else {
      if (we(e.code) && be(e.message)) {
        const o = new ei(e);return t && null !== ti && ti.emit(D.ERROR, o), Promise.reject(o);
      }Oe.error('IMPromise.reject code(错误码)必须为数字，message(错误信息)必须为字符串!!!');
    }
  }; const si = (function (e) {
    i(a, e);const n = f(a);function a(e) {
      let o;return t(this, a), (o = n.call(this, e))._className = 'C2CModule', o;
    } return o(a, [{ key: 'onNewC2CMessage', value(e) {
      const t = e.dataList; const n = e.isInstantMessage; const o = e.C2CRemainingUnreadList; const a = e.C2CPairUnreadList;Oe.debug(''.concat(this._className, '.onNewC2CMessage count:').concat(t.length, ' isInstantMessage:')
        .concat(n));const s = this._newC2CMessageStoredAndSummary({ dataList: t, C2CRemainingUnreadList: o, C2CPairUnreadList: a, isInstantMessage: n }); const r = s.conversationOptionsList; const i = s.messageList; const c = s.isUnreadC2CMessage;(this.filterModifiedMessage(i), r.length > 0) && this.getModule(xt).onNewMessage({ conversationOptionsList: r, isInstantMessage: n, isUnreadC2CMessage: c });const u = this.filterUnmodifiedMessage(i);n && u.length > 0 && this.emitOuterEvent(D.MESSAGE_RECEIVED, u), i.length = 0;
    } }, { key: '_newC2CMessageStoredAndSummary', value(e) {
      for (var t = e.dataList, n = e.C2CRemainingUnreadList, o = e.C2CPairUnreadList, a = e.isInstantMessage, s = null, r = [], i = [], c = {}, u = this.getModule(Yt), l = !1, d = 0, p = t.length;d < p;d++) {
        const g = t[d];g.currentUser = this.getMyUserID(), g.conversationType = k.CONV_C2C, g.isSystemMessage = !!g.isSystemMessage, (qe(g.nick) || qe(g.avatar)) && (l = !0, Oe.debug(''.concat(this._className, '._newC2CMessageStoredAndSummary nick or avatar missing!'))), s = new Yr(g), g.elements = u.parseElements(g.elements, g.from), s.setElement(g.elements), s.setNickAndAvatar({ nick: g.nick, avatar: g.avatar });const h = s.conversationID;if (a) {
          let _ = !1; const f = this.getModule(xt);if (s.from !== this.getMyUserID()) {
            const m = f.getLatestMessageSentByPeer(h);if (m) {
              const M = m.nick; const v = m.avatar;l ? s.setNickAndAvatar({ nick: M, avatar: v }) : M === s.nick && v === s.avatar || (_ = !0);
            }
          } else {
            const y = f.getLatestMessageSentByMe(h);if (y) {
              const I = y.nick; const C = y.avatar;I === s.nick && C === s.avatar || f.modifyMessageSentByMe({ conversationID: h, latestNick: s.nick, latestAvatar: s.avatar });
            }
          } let T = 1 === t[d].isModified;if (f.isMessageSentByCurrentInstance(s) ? s.isModified = T : T = !1, 0 === g.msgLifeTime)s._onlineOnlyFlag = !0, i.push(s);else {
            if (!f.pushIntoMessageList(i, s, T)) continue;_ && (f.modifyMessageSentByPeer({ conversationID: h, latestNick: s.nick, latestAvatar: s.avatar }), f.updateUserProfileSpecifiedKey({ conversationID: h, nick: s.nick, avatar: s.avatar }));
          } this.getModule(on).addMessageDelay({ currentTime: Date.now(), time: s.time });
        } if (0 !== g.msgLifeTime) {
          if (!1 === s._onlineOnlyFlag) if (qe(c[h])) {
            let S = 0;'in' === s.flow && (s._isExcludedFromUnreadCount || (S = 1)), c[h] = r.push({ conversationID: h, unreadCount: S, type: s.conversationType, subType: s.conversationSubType, lastMessage: s._isExcludedFromLastMessage ? '' : s }) - 1;
          } else {
            const D = c[h];r[D].type = s.conversationType, r[D].subType = s.conversationSubType, r[D].lastMessage = s._isExcludedFromLastMessage ? '' : s, 'in' === s.flow && (s._isExcludedFromUnreadCount || r[D].unreadCount++);
          }
        } else s._onlineOnlyFlag = !0;
      } let E = !1;if (Fe(o)) for (let A = function (e, t) {
          if (o[e].unreadCount > 0) {
            E = !0;const n = r.find((t => t.conversationID === 'C2C'.concat(o[e].from)));n ? n.unreadCount = o[e].unreadCount : r.push({ conversationID: 'C2C'.concat(o[e].from), unreadCount: o[e].unreadCount, type: k.CONV_C2C });
          }
        }, N = 0, L = o.length;N < L;N++)A(N);if (Fe(n)) for (let R = function (e, t) {
          r.find((t => t.conversationID === 'C2C'.concat(n[e].from))) || r.push({ conversationID: 'C2C'.concat(n[e].from), type: k.CONV_C2C, lastMsgTime: n[e].lastMsgTime });
        }, O = 0, G = n.length;O < G;O++)R(O);return { conversationOptionsList: r, messageList: i, isUnreadC2CMessage: E };
    } }, { key: 'onC2CMessageRevoked', value(e) {
      const t = this;Oe.debug(''.concat(this._className, '.onC2CMessageRevoked count:').concat(e.dataList.length));const n = this.getModule(xt); const o = []; let a = null;e.dataList.forEach(((e) => {
        if (e.c2cMessageRevokedNotify) {
          const s = e.c2cMessageRevokedNotify.revokedInfos;qe(s) || s.forEach(((e) => {
            const s = t.getMyUserID() === e.from ? ''.concat(k.CONV_C2C).concat(e.to) : ''.concat(k.CONV_C2C).concat(e.from);(a = n.revoke(s, e.sequence, e.random)) && o.push(a);
          }));
        }
      })), 0 !== o.length && (n.onMessageRevoked(o), this.emitOuterEvent(D.MESSAGE_REVOKED, o));
    } }, { key: 'onC2CMessageReadReceipt', value(e) {
      const t = this;e.dataList.forEach(((e) => {
        if (!It(e.c2cMessageReadReceipt)) {
          const n = e.c2cMessageReadReceipt.to;e.c2cMessageReadReceipt.uinPairReadArray.forEach(((e) => {
            const o = e.peerReadTime;Oe.debug(''.concat(t._className, '._onC2CMessageReadReceipt to:').concat(n, ' peerReadTime:')
              .concat(o));const a = ''.concat(k.CONV_C2C).concat(n); const s = t.getModule(xt);s.recordPeerReadTime(a, o), s.updateMessageIsPeerReadProperty(a, o);
          }));
        }
      }));
    } }, { key: 'onC2CMessageReadNotice', value(e) {
      const t = this;e.dataList.forEach(((e) => {
        if (!It(e.c2cMessageReadNotice)) {
          const n = t.getModule(xt);e.c2cMessageReadNotice.uinPairReadArray.forEach(((e) => {
            const o = e.from; const a = e.peerReadTime;Oe.debug(''.concat(t._className, '.onC2CMessageReadNotice from:').concat(o, ' lastReadTime:')
              .concat(a));const s = ''.concat(k.CONV_C2C).concat(o);n.updateIsReadAfterReadReport({ conversationID: s, lastMessageTime: a }), n.updateUnreadCount(s);
          }));
        }
      }));
    } }, { key: 'sendMessage', value(e, t) {
      const n = this._createC2CMessagePack(e, t);return this.request(n);
    } }, { key: '_createC2CMessagePack', value(e, t) {
      let n = null;t && (t.offlinePushInfo && (n = t.offlinePushInfo), !0 === t.onlineUserOnly && (n ? n.disablePush = !0 : n = { disablePush: !0 }));let o = '';be(e.cloudCustomData) && e.cloudCustomData.length > 0 && (o = e.cloudCustomData);const a = [];if (Ue(t) && Ue(t.messageControlInfo)) {
        const s = t.messageControlInfo; const r = s.excludedFromUnreadCount; const i = s.excludedFromLastMessage;!0 === r && a.push('NoUnread'), !0 === i && a.push('NoLastMsg');
      } return { protocolName: gn, tjgID: this.generateTjgID(e), requestData: { fromAccount: this.getMyUserID(), toAccount: e.to, msgTimeStamp: Math.ceil(Date.now() / 1e3), msgBody: e.getElements(), cloudCustomData: o, msgSeq: e.sequence, msgRandom: e.random, msgLifeTime: this.isOnlineMessage(e, t) ? 0 : void 0, nick: e.nick, avatar: e.avatar, offlinePushInfo: n ? { pushFlag: !0 === n.disablePush ? 1 : 0, title: n.title || '', desc: n.description || '', ext: n.extension || '', apnsInfo: { badgeMode: !0 === n.ignoreIOSBadge ? 1 : 0 }, androidInfo: { OPPOChannelID: n.androidOPPOChannelID || '' } } : void 0, messageControlInfo: a } };
    } }, { key: 'isOnlineMessage', value(e, t) {
      return !(!t || !0 !== t.onlineUserOnly);
    } }, { key: 'revokeMessage', value(e) {
      return this.request({ protocolName: yn, requestData: { msgInfo: { fromAccount: e.from, toAccount: e.to, msgSeq: e.sequence, msgRandom: e.random, msgTimeStamp: e.time } } });
    } }, { key: 'deleteMessage', value(e) {
      const t = e.to; const n = e.keyList;return Oe.log(''.concat(this._className, '.deleteMessage toAccount:').concat(t, ' count:')
        .concat(n.length)), this.request({ protocolName: kn, requestData: { fromAccount: this.getMyUserID(), to: t, keyList: n } });
    } }, { key: 'setMessageRead', value(e) {
      const t = this; const n = e.conversationID; const o = e.lastMessageTime; const a = ''.concat(this._className, '.setMessageRead');Oe.log(''.concat(a, ' conversationID:').concat(n, ' lastMessageTime:')
        .concat(o)), we(o) || Oe.warn(''.concat(a, ' 请勿修改 Conversation.lastMessage.lastTime，否则可能会导致已读上报结果不准确'));const s = new Xa(Ms);return s.setMessage('conversationID:'.concat(n, ' lastMessageTime:').concat(o)), this.request({ protocolName: In, requestData: { C2CMsgReaded: { cookie: '', C2CMsgReadedItem: [{ toAccount: n.replace('C2C', ''), lastMessageTime: o, receipt: 1 }] } } }).then((() => {
        s.setNetworkType(t.getNetworkType()).end(), Oe.log(''.concat(a, ' ok'));const e = t.getModule(xt);return e.updateIsReadAfterReadReport({ conversationID: n, lastMessageTime: o }), e.updateUnreadCount(n), $r();
      }))
        .catch((e => (t.probeNetwork().then(((t) => {
          const n = m(t, 2); const o = n[0]; const a = n[1];s.setError(e, o, a).end();
        })), Oe.log(''.concat(a, ' failed. error:'), e), ai(e))));
    } }, { key: 'getRoamingMessage', value(e) {
      const t = this; const n = ''.concat(this._className, '.getRoamingMessage'); const o = e.peerAccount; const a = e.conversationID; const s = e.count; const r = e.lastMessageTime; const i = e.messageKey; const c = 'peerAccount:'.concat(o, ' count:').concat(s || 15, ' lastMessageTime:')
        .concat(r || 0, ' messageKey:')
        .concat(i);Oe.log(''.concat(n, ' ').concat(c));const u = new Xa(hs);return this.request({ protocolName: Sn, requestData: { peerAccount: o, count: s || 15, lastMessageTime: r || 0, messageKey: i } }).then(((e) => {
        const o = e.data; const s = o.complete; const r = o.messageList; const i = o.messageKey; const l = o.lastMessageTime;qe(r) ? Oe.log(''.concat(n, ' ok. complete:').concat(s, ' but messageList is undefined!')) : Oe.log(''.concat(n, ' ok. complete:').concat(s, ' count:')
          .concat(r.length)), u.setNetworkType(t.getNetworkType()).setMessage(''.concat(c, ' complete:').concat(s, ' length:')
          .concat(r.length))
          .end();const d = t.getModule(xt);1 === s && d.setCompleted(a);const p = d.storeRoamingMessage(r, a);d.modifyMessageList(a), d.updateIsRead(a), d.updateRoamingMessageKeyAndTime(a, i, l);const g = d.getPeerReadTime(a);if (Oe.log(''.concat(n, ' update isPeerRead property. conversationID:').concat(a, ' peerReadTime:')
          .concat(g)), g)d.updateMessageIsPeerReadProperty(a, g);else {
          const h = a.replace(k.CONV_C2C, '');t.getRemotePeerReadTime([h]).then((() => {
            d.updateMessageIsPeerReadProperty(a, d.getPeerReadTime(a));
          }));
        } return p;
      }))
        .catch((e => (t.probeNetwork().then(((t) => {
          const n = m(t, 2); const o = n[0]; const a = n[1];u.setMessage(c).setError(e, o, a)
            .end();
        })), Oe.warn(''.concat(n, ' failed. error:'), e), ai(e))));
    } }, { key: 'getRemotePeerReadTime', value(e) {
      const t = this; const n = ''.concat(this._className, '.getRemotePeerReadTime');if (It(e)) return Oe.warn(''.concat(n, ' userIDList is empty!')), Promise.resolve();const o = new Xa(Is);return Oe.log(''.concat(n, ' userIDList:').concat(e)), this.request({ protocolName: Dn, requestData: { userIDList: e } }).then(((a) => {
        const s = a.data.peerReadTimeList;Oe.log(''.concat(n, ' ok. peerReadTimeList:').concat(s));for (var r = '', i = t.getModule(xt), c = 0;c < e.length;c++)r += ''.concat(e[c], '-').concat(s[c], ' '), s[c] > 0 && i.recordPeerReadTime('C2C'.concat(e[c]), s[c]);o.setNetworkType(t.getNetworkType()).setMessage(r)
          .end();
      }))
        .catch(((e) => {
          t.probeNetwork().then(((t) => {
            const n = m(t, 2); const a = n[0]; const s = n[1];o.setError(e, a, s).end();
          })), Oe.warn(''.concat(n, ' failed. error:'), e);
        }));
    } }]), a;
  }(sn)); const ri = (function () {
    function e(n) {
      t(this, e), this.list = new Map, this._className = 'MessageListHandler', this._latestMessageSentByPeerMap = new Map, this._latestMessageSentByMeMap = new Map, this._groupLocalLastMessageSequenceMap = new Map;
    } return o(e, [{ key: 'getLocalOldestMessageByConversationID', value(e) {
      if (!e) return null;if (!this.list.has(e)) return null;const t = this.list.get(e).values();return t ? t.next().value : null;
    } }, { key: 'pushIn', value(e) {
      const t = arguments.length > 1 && void 0 !== arguments[1] && arguments[1]; const n = e.conversationID; const o = e.ID; let a = !0;this.list.has(n) || this.list.set(n, new Map);const s = this.list.get(n).has(o);if (s) {
        const r = this.list.get(n).get(o);if (!t || !0 === r.isModified) return a = !1;
      } return this.list.get(n).set(o, e), this._setLatestMessageSentByPeer(n, e), this._setLatestMessageSentByMe(n, e), this._setGroupLocalLastMessageSequence(n, e), a;
    } }, { key: 'unshift', value(e) {
      let t;if (Fe(e)) {
        if (e.length > 0) {
          t = e[0].conversationID;const n = e.length;this._unshiftMultipleMessages(e), this._setGroupLocalLastMessageSequence(t, e[n - 1]);
        }
      } else t = e.conversationID, this._unshiftSingleMessage(e), this._setGroupLocalLastMessageSequence(t, e);if (t && t.startsWith(k.CONV_C2C)) {
        const o = Array.from(this.list.get(t).values()); const a = o.length;if (0 === a) return;for (let s = a - 1;s >= 0;s--) if ('out' === o[s].flow) {
          this._setLatestMessageSentByMe(t, o[s]);break;
        } for (let r = a - 1;r >= 0;r--) if ('in' === o[r].flow) {
          this._setLatestMessageSentByPeer(t, o[r]);break;
        }
      }
    } }, { key: '_unshiftSingleMessage', value(e) {
      const t = e.conversationID; const n = e.ID;if (!this.list.has(t)) return this.list.set(t, new Map), void this.list.get(t).set(n, e);const o = Array.from(this.list.get(t));o.unshift([n, e]), this.list.set(t, new Map(o));
    } }, { key: '_unshiftMultipleMessages', value(e) {
      for (var t = e.length, n = [], o = e[0].conversationID, a = this.list.has(o) ? Array.from(this.list.get(o)) : [], s = 0;s < t;s++)n.push([e[s].ID, e[s]]);this.list.set(o, new Map(n.concat(a)));
    } }, { key: 'remove', value(e) {
      const t = e.conversationID; const n = e.ID;this.list.has(t) && this.list.get(t).delete(n);
    } }, { key: 'revoke', value(e, t, n) {
      if (Oe.debug('revoke message', e, t, n), this.list.has(e)) {
        let o; const a = S(this.list.get(e));try {
          for (a.s();!(o = a.n()).done;) {
            const s = m(o.value, 2)[1];if (s.sequence === t && !s.isRevoked && (qe(n) || s.random === n)) return s.isRevoked = !0, s;
          }
        } catch (r) {
          a.e(r);
        } finally {
          a.f();
        }
      } return null;
    } }, { key: 'removeByConversationID', value(e) {
      this.list.has(e) && (this.list.delete(e), this._latestMessageSentByPeerMap.delete(e), this._latestMessageSentByMeMap.delete(e));
    } }, { key: 'updateMessageIsPeerReadProperty', value(e, t) {
      const n = [];if (this.list.has(e)) {
        let o; const a = S(this.list.get(e));try {
          for (a.s();!(o = a.n()).done;) {
            const s = m(o.value, 2)[1];s.time <= t && !s.isPeerRead && 'out' === s.flow && (s.isPeerRead = !0, n.push(s));
          }
        } catch (r) {
          a.e(r);
        } finally {
          a.f();
        }Oe.log(''.concat(this._className, '.updateMessageIsPeerReadProperty conversationID:').concat(e, ' peerReadTime:')
          .concat(t, ' count:')
          .concat(n.length));
      } return n;
    } }, { key: 'updateMessageIsModifiedProperty', value(e) {
      const t = e.conversationID; const n = e.ID;if (this.list.has(t)) {
        const o = this.list.get(t).get(n);o && (o.isModified = !0);
      }
    } }, { key: 'hasLocalMessageList', value(e) {
      return this.list.has(e);
    } }, { key: 'getLocalMessageList', value(e) {
      return this.hasLocalMessageList(e) ? M(this.list.get(e).values()) : [];
    } }, { key: 'hasLocalMessage', value(e, t) {
      return !!this.hasLocalMessageList(e) && this.list.get(e).has(t);
    } }, { key: 'getLocalMessage', value(e, t) {
      return this.hasLocalMessage(e, t) ? this.list.get(e).get(t) : null;
    } }, { key: 'getLocalLastMessage', value(e) {
      const t = this.getLocalMessageList(e);return t[t.length - 1];
    } }, { key: '_setLatestMessageSentByPeer', value(e, t) {
      e.startsWith(k.CONV_C2C) && 'in' === t.flow && this._latestMessageSentByPeerMap.set(e, t);
    } }, { key: '_setLatestMessageSentByMe', value(e, t) {
      e.startsWith(k.CONV_C2C) && 'out' === t.flow && this._latestMessageSentByMeMap.set(e, t);
    } }, { key: '_setGroupLocalLastMessageSequence', value(e, t) {
      e.startsWith(k.CONV_GROUP) && this._groupLocalLastMessageSequenceMap.set(e, t.sequence);
    } }, { key: 'getLatestMessageSentByPeer', value(e) {
      return this._latestMessageSentByPeerMap.get(e);
    } }, { key: 'getLatestMessageSentByMe', value(e) {
      return this._latestMessageSentByMeMap.get(e);
    } }, { key: 'getGroupLocalLastMessageSequence', value(e) {
      return this._groupLocalLastMessageSequenceMap.get(e) || 0;
    } }, { key: 'modifyMessageSentByPeer', value(e) {
      const t = e.conversationID; const n = e.latestNick; const o = e.latestAvatar; const a = this.list.get(t);if (!It(a)) {
        const s = Array.from(a.values()); const r = s.length;if (0 !== r) {
          for (var i = null, c = 0, u = !1, l = r - 1;l >= 0;l--)'in' === s[l].flow && ((i = s[l]).nick !== n && (i.setNickAndAvatar({ nick: n }), u = !0), i.avatar !== o && (i.setNickAndAvatar({ avatar: o }), u = !0), u && (c += 1));Oe.log(''.concat(this._className, '.modifyMessageSentByPeer conversationID:').concat(t, ' count:')
            .concat(c));
        }
      }
    } }, { key: 'modifyMessageSentByMe', value(e) {
      const t = e.conversationID; const n = e.latestNick; const o = e.latestAvatar; const a = this.list.get(t);if (!It(a)) {
        const s = Array.from(a.values()); const r = s.length;if (0 !== r) {
          for (var i = null, c = 0, u = !1, l = r - 1;l >= 0;l--)'out' === s[l].flow && ((i = s[l]).nick !== n && (i.setNickAndAvatar({ nick: n }), u = !0), i.avatar !== o && (i.setNickAndAvatar({ avatar: o }), u = !0), u && (c += 1));Oe.log(''.concat(this._className, '.modifyMessageSentByMe conversationID:').concat(t, ' count:')
            .concat(c));
        }
      }
    } }, { key: 'traversal', value() {
      if (0 !== this.list.size && -1 === Oe.getLevel()) {
        console.group('conversationID-messageCount');let e; const t = S(this.list);try {
          for (t.s();!(e = t.n()).done;) {
            const n = m(e.value, 2); const o = n[0]; const a = n[1];console.log(''.concat(o, '-').concat(a.size));
          }
        } catch (s) {
          t.e(s);
        } finally {
          t.f();
        }console.groupEnd();
      }
    } }, { key: 'reset', value() {
      this.list.clear(), this._latestMessageSentByPeerMap.clear(), this._latestMessageSentByMeMap.clear(), this._groupLocalLastMessageSequenceMap.clear();
    } }]), e;
  }()); const ii = '_a2KeyAndTinyIDUpdated'; const ci = '_cloudConfigUpdated'; const ui = '_profileUpdated';function li(e) {
    this.mixin(e);
  }li.mixin = function (e) {
    const t = e.prototype || e;t._isReady = !1, t.ready = function (e) {
      const t = arguments.length > 1 && void 0 !== arguments[1] && arguments[1];if (e) return this._isReady ? void (t ? e.call(this) : setTimeout(e, 1)) : (this._readyQueue = this._readyQueue || [], void this._readyQueue.push(e));
    }, t.triggerReady = function () {
      const e = this;this._isReady = !0, setTimeout((() => {
        const t = e._readyQueue;e._readyQueue = [], t && t.length > 0 && t.forEach((function (e) {
          e.call(this);
        }), e);
      }), 1);
    }, t.resetReady = function () {
      this._isReady = !1, this._readyQueue = [];
    }, t.isReady = function () {
      return this._isReady;
    };
  };const di = ['jpg', 'jpeg', 'gif', 'png', 'bmp', 'image']; const pi = ['mp4']; const gi = 1; const hi = 2; const _i = 3; const fi = 255; const mi = (function () {
    function e(n) {
      const o = this;t(this, e), It(n) || (this.userID = n.userID || '', this.nick = n.nick || '', this.gender = n.gender || '', this.birthday = n.birthday || 0, this.location = n.location || '', this.selfSignature = n.selfSignature || '', this.allowType = n.allowType || k.ALLOW_TYPE_ALLOW_ANY, this.language = n.language || 0, this.avatar = n.avatar || '', this.messageSettings = n.messageSettings || 0, this.adminForbidType = n.adminForbidType || k.FORBID_TYPE_NONE, this.level = n.level || 0, this.role = n.role || 0, this.lastUpdatedTime = 0, this.profileCustomField = [], It(n.profileCustomField) || n.profileCustomField.forEach(((e) => {
        o.profileCustomField.push({ key: e.key, value: e.value });
      })));
    } return o(e, [{ key: 'validate', value(e) {
      let t = !0; let n = '';if (It(e)) return { valid: !1, tips: 'empty options' };if (e.profileCustomField) for (let o = e.profileCustomField.length, a = null, s = 0;s < o;s++) {
        if (a = e.profileCustomField[s], !be(a.key) || -1 === a.key.indexOf('Tag_Profile_Custom')) return { valid: !1, tips: '自定义资料字段的前缀必须是 Tag_Profile_Custom' };if (!be(a.value)) return { valid: !1, tips: '自定义资料字段的 value 必须是字符串' };
      } for (const r in e) if (Object.prototype.hasOwnProperty.call(e, r)) {
        if ('profileCustomField' === r) continue;if (It(e[r]) && !be(e[r]) && !we(e[r])) {
          n = `key:${r}, invalid value:${e[r]}`, t = !1;continue;
        } switch (r) {
          case 'nick':be(e[r]) || (n = 'nick should be a string', t = !1), ze(e[r]) > 500 && (n = 'nick name limited: must less than or equal to '.concat(500, ' bytes, current size: ').concat(ze(e[r]), ' bytes'), t = !1);break;case 'gender':Ze(Ar, e.gender) || (n = `key:gender, invalid value:${e.gender}`, t = !1);break;case 'birthday':we(e.birthday) || (n = 'birthday should be a number', t = !1);break;case 'location':be(e.location) || (n = 'location should be a string', t = !1);break;case 'selfSignature':be(e.selfSignature) || (n = 'selfSignature should be a string', t = !1);break;case 'allowType':Ze(Lr, e.allowType) || (n = `key:allowType, invalid value:${e.allowType}`, t = !1);break;case 'language':we(e.language) || (n = 'language should be a number', t = !1);break;case 'avatar':be(e.avatar) || (n = 'avatar should be a string', t = !1);break;case 'messageSettings':0 !== e.messageSettings && 1 !== e.messageSettings && (n = 'messageSettings should be 0 or 1', t = !1);break;case 'adminForbidType':Ze(Nr, e.adminForbidType) || (n = `key:adminForbidType, invalid value:${e.adminForbidType}`, t = !1);break;case 'level':we(e.level) || (n = 'level should be a number', t = !1);break;case 'role':we(e.role) || (n = 'role should be a number', t = !1);break;default:n = `unknown key:${r}  ${e[r]}`, t = !1;
        }
      } return { valid: t, tips: n };
    } }]), e;
  }()); const Mi = function e(n) {
    t(this, e), this.value = n, this.next = null;
  }; const vi = (function () {
    function e(n) {
      t(this, e), this.MAX_LENGTH = n, this.pTail = null, this.pNodeToDel = null, this.map = new Map, Oe.debug('SinglyLinkedList init MAX_LENGTH:'.concat(this.MAX_LENGTH));
    } return o(e, [{ key: 'set', value(e) {
      const t = new Mi(e);if (this.map.size < this.MAX_LENGTH)null === this.pTail ? (this.pTail = t, this.pNodeToDel = t) : (this.pTail.next = t, this.pTail = t), this.map.set(e, 1);else {
        let n = this.pNodeToDel;this.pNodeToDel = this.pNodeToDel.next, this.map.delete(n.value), n.next = null, n = null, this.pTail.next = t, this.pTail = t, this.map.set(e, 1);
      }
    } }, { key: 'has', value(e) {
      return this.map.has(e);
    } }, { key: 'delete', value(e) {
      this.has(e) && this.map.delete(e);
    } }, { key: 'tail', value() {
      return this.pTail;
    } }, { key: 'size', value() {
      return this.map.size;
    } }, { key: 'data', value() {
      return Array.from(this.map.keys());
    } }, { key: 'reset', value() {
      for (var e;null !== this.pNodeToDel;)e = this.pNodeToDel, this.pNodeToDel = this.pNodeToDel.next, e.next = null, e = null;this.pTail = null, this.map.clear();
    } }]), e;
  }()); const yi = ['groupID', 'name', 'avatar', 'type', 'introduction', 'notification', 'ownerID', 'selfInfo', 'createTime', 'infoSequence', 'lastInfoTime', 'lastMessage', 'nextMessageSeq', 'memberNum', 'maxMemberNum', 'memberList', 'joinOption', 'groupCustomField', 'muteAllMembers']; const Ii = (function () {
    function e(n) {
      t(this, e), this.groupID = '', this.name = '', this.avatar = '', this.type = '', this.introduction = '', this.notification = '', this.ownerID = '', this.createTime = '', this.infoSequence = '', this.lastInfoTime = '', this.selfInfo = { messageRemindType: '', joinTime: '', nameCard: '', role: '', userID: '', memberCustomField: void 0, readedSequence: 0, excludedUnreadSequenceList: void 0 }, this.lastMessage = { lastTime: '', lastSequence: '', fromAccount: '', messageForShow: '' }, this.nextMessageSeq = '', this.memberNum = '', this.memberCount = '', this.maxMemberNum = '', this.maxMemberCount = '', this.joinOption = '', this.groupCustomField = [], this.muteAllMembers = void 0, this._initGroup(n);
    } return o(e, [{ key: '_initGroup', value(e) {
      for (const t in e)yi.indexOf(t) < 0 || ('selfInfo' !== t ? ('memberNum' === t && (this.memberCount = e[t]), 'maxMemberNum' === t && (this.maxMemberCount = e[t]), this[t] = e[t]) : this.updateSelfInfo(e[t]));
    } }, { key: 'updateGroup', value(e) {
      const t = this; const n = JSON.parse(JSON.stringify(e));n.lastMsgTime && (this.lastMessage.lastTime = n.lastMsgTime), qe(n.muteAllMembers) || ('On' === n.muteAllMembers ? n.muteAllMembers = !0 : n.muteAllMembers = !1), n.groupCustomField && st(this.groupCustomField, n.groupCustomField), qe(n.memberNum) || (this.memberCount = n.memberNum), qe(n.maxMemberNum) || (this.maxMemberCount = n.maxMemberNum), Ye(this, n, ['members', 'errorCode', 'lastMsgTime', 'groupCustomField', 'memberNum', 'maxMemberNum']), Fe(n.members) && n.members.length > 0 && n.members.forEach(((e) => {
        e.userID === t.selfInfo.userID && Ye(t.selfInfo, e, ['sequence']);
      }));
    } }, { key: 'updateSelfInfo', value(e) {
      const t = e.nameCard; const n = e.joinTime; const o = e.role; const a = e.messageRemindType; const s = e.readedSequence; const r = e.excludedUnreadSequenceList;Ye(this.selfInfo, { nameCard: t, joinTime: n, role: o, messageRemindType: a, readedSequence: s, excludedUnreadSequenceList: r }, [], ['', null, void 0, 0, NaN]);
    } }, { key: 'setSelfNameCard', value(e) {
      this.selfInfo.nameCard = e;
    } }, { key: 'memberNum', set(e) {}, get() {
      return Oe.warn('！！！v2.8.0起弃用memberNum，请使用 memberCount'), this.memberCount;
    } }, { key: 'maxMemberNum', set(e) {}, get() {
      return Oe.warn('！！！v2.8.0起弃用maxMemberNum，请使用 maxMemberCount'), this.maxMemberCount;
    } }]), e;
  }()); const Ci = function (e, t) {
    if (qe(t)) return '';switch (e) {
      case k.MSG_TEXT:return t.text;case k.MSG_IMAGE:return '[图片]';case k.MSG_LOCATION:return '[位置]';case k.MSG_AUDIO:return '[语音]';case k.MSG_VIDEO:return '[视频]';case k.MSG_FILE:return '[文件]';case k.MSG_CUSTOM:return '[自定义消息]';case k.MSG_GRP_TIP:return '[群提示消息]';case k.MSG_GRP_SYS_NOTICE:return '[群系统通知]';case k.MSG_FACE:return '[动画表情]';case k.MSG_MERGER:return '[聊天记录]';default:return '';
    }
  }; const Ti = function (e) {
    return qe(e) ? { lastTime: 0, lastSequence: 0, fromAccount: 0, messageForShow: '', payload: null, type: '', isRevoked: !1, cloudCustomData: '', onlineOnlyFlag: !1, nick: '', nameCard: '' } : e instanceof Yr ? { lastTime: e.time || 0, lastSequence: e.sequence || 0, fromAccount: e.from || '', messageForShow: Ci(e.type, e.payload), payload: e.payload || null, type: e.type || null, isRevoked: e.isRevoked || !1, cloudCustomData: e.cloudCustomData || '', onlineOnlyFlag: e._onlineOnlyFlag || !1, nick: e.nick || '', nameCard: e.nameCard || '' } : r(r({}, e), {}, { messageForShow: Ci(e.type, e.payload) });
  }; const Si = (function () {
    function e(n) {
      t(this, e), this.conversationID = n.conversationID || '', this.unreadCount = n.unreadCount || 0, this.type = n.type || '', this.lastMessage = Ti(n.lastMessage), n.lastMsgTime && (this.lastMessage.lastTime = n.lastMsgTime), this._isInfoCompleted = !1, this.peerReadTime = n.peerReadTime || 0, this.groupAtInfoList = [], this.remark = '', this.isPinned = n.isPinned || !1, this.messageRemindType = '', this._initProfile(n);
    } return o(e, [{ key: '_initProfile', value(e) {
      const t = this;Object.keys(e).forEach(((n) => {
        switch (n) {
          case 'userProfile':t.userProfile = e.userProfile;break;case 'groupProfile':t.groupProfile = e.groupProfile;
        }
      })), qe(this.userProfile) && this.type === k.CONV_C2C ? this.userProfile = new mi({ userID: e.conversationID.replace('C2C', '') }) : qe(this.groupProfile) && this.type === k.CONV_GROUP && (this.groupProfile = new Ii({ groupID: e.conversationID.replace('GROUP', '') }));
    } }, { key: 'updateUnreadCount', value(e) {
      const t = e.nextUnreadCount; const n = e.isFromGetConversationList; const o = e.isUnreadC2CMessage;qe(t) || (it(this.subType) ? this.unreadCount = 0 : n && this.type === k.CONV_GROUP || o && this.type === k.CONV_C2C ? this.unreadCount = t : this.unreadCount = this.unreadCount + t);
    } }, { key: 'updateLastMessage', value(e) {
      this.lastMessage = Ti(e);
    } }, { key: 'updateGroupAtInfoList', value(e) {
      let t; let n = (v(t = e.groupAtType) || y(t) || I(t) || T()).slice(0);-1 !== n.indexOf(k.CONV_AT_ME) && -1 !== n.indexOf(k.CONV_AT_ALL) && (n = [k.CONV_AT_ALL_AT_ME]);const o = { from: e.from, groupID: e.groupID, messageSequence: e.sequence, atTypeArray: n, __random: e.__random, __sequence: e.__sequence };this.groupAtInfoList.push(o), Oe.debug('Conversation.updateGroupAtInfoList conversationID:'.concat(this.conversationID), this.groupAtInfoList);
    } }, { key: 'clearGroupAtInfoList', value() {
      this.groupAtInfoList.length = 0;
    } }, { key: 'reduceUnreadCount', value() {
      this.unreadCount >= 1 && (this.unreadCount -= 1);
    } }, { key: 'isLastMessageRevoked', value(e) {
      const t = e.sequence; const n = e.time;return this.type === k.CONV_C2C && t === this.lastMessage.lastSequence && n === this.lastMessage.lastTime || this.type === k.CONV_GROUP && t === this.lastMessage.lastSequence;
    } }, { key: 'setLastMessageRevoked', value(e) {
      this.lastMessage.isRevoked = e;
    } }, { key: 'toAccount', get() {
      return this.conversationID.startsWith(k.CONV_C2C) ? this.conversationID.replace(k.CONV_C2C, '') : this.conversationID.startsWith(k.CONV_GROUP) ? this.conversationID.replace(k.CONV_GROUP, '') : '';
    } }, { key: 'subType', get() {
      return this.groupProfile ? this.groupProfile.type : '';
    } }]), e;
  }()); const Di = (function () {
    function e(n) {
      t(this, e), this._conversationModule = n, this._className = 'MessageRemindHandler', this._updateSequence = 0;
    } return o(e, [{ key: 'getC2CMessageRemindType', value() {
      const e = this; const t = ''.concat(this._className, '.getC2CMessageRemindType');return this._conversationModule.request({ protocolName: Tn, updateSequence: this._updateSequence }).then(((n) => {
        Oe.log(''.concat(t, ' ok'));const o = n.data; const a = o.updateSequence; const s = o.muteFlagList;e._updateSequence = a, e._patchC2CMessageRemindType(s);
      }))
        .catch(((e) => {
          Oe.error(''.concat(t, ' failed. error:'), e);
        }));
    } }, { key: '_patchC2CMessageRemindType', value(e) {
      const t = this; let n = 0; let o = '';Fe(e) && e.length > 0 && e.forEach(((e) => {
        const a = e.userID; const s = e.muteFlag;0 === s ? o = k.MSG_REMIND_ACPT_AND_NOTE : 1 === s ? o = k.MSG_REMIND_DISCARD : 2 === s && (o = k.MSG_REMIND_ACPT_NOT_NOTE), !0 === t._conversationModule.patchMessageRemindType({ ID: a, isC2CConversation: !0, messageRemindType: o }) && (n += 1);
      })), Oe.log(''.concat(this._className, '._patchC2CMessageRemindType count:').concat(n));
    } }, { key: 'set', value(e) {
      return e.groupID ? this._setGroupMessageRemindType(e) : Fe(e.userIDList) ? this._setC2CMessageRemindType(e) : void 0;
    } }, { key: '_setGroupMessageRemindType', value(e) {
      const t = this; const n = ''.concat(this._className, '._setGroupMessageRemindType'); const o = e.groupID; const a = e.messageRemindType; const s = 'groupID:'.concat(o, ' messageRemindType:').concat(a); const r = new Xa(Vs);return r.setMessage(s), this._getModule(Kt).modifyGroupMemberInfo({ groupID: o, messageRemindType: a, userID: this._conversationModule.getMyUserID() })
        .then((() => {
          r.setNetworkType(t._conversationModule.getNetworkType()).end(), Oe.log(''.concat(n, ' ok. ').concat(s));const e = t._getModule(qt).getLocalGroupProfile(o);return e && (e.selfInfo.messageRemindType = a), t._conversationModule.patchMessageRemindType({ ID: o, isC2CConversation: !1, messageRemindType: a }) && t._emitConversationUpdate(), $r({ group: e });
        }))
        .catch((e => (t._conversationModule.probeNetwork().then(((t) => {
          const n = m(t, 2); const o = n[0]; const a = n[1];r.setError(e, o, a).end();
        })), Oe.error(''.concat(n, ' failed. error:'), e), ai(e))));
    } }, { key: '_setC2CMessageRemindType', value(e) {
      const t = this; const n = ''.concat(this._className, '._setC2CMessageRemindType'); const o = e.userIDList; const a = e.messageRemindType; const s = o.slice(0, 30); let r = 0;a === k.MSG_REMIND_DISCARD ? r = 1 : a === k.MSG_REMIND_ACPT_NOT_NOTE && (r = 2);const i = 'userIDList:'.concat(s, ' messageRemindType:').concat(a); const c = new Xa(Vs);return c.setMessage(i), this._conversationModule.request({ protocolName: Cn, requestData: { userIDList: s, muteFlag: r } }).then(((e) => {
        c.setNetworkType(t._conversationModule.getNetworkType()).end();const o = e.data; const r = o.updateSequence; const i = o.errorList;t._updateSequence = r;const u = []; const l = [];Fe(i) && i.forEach(((e) => {
          u.push(e.userID), l.push({ userID: e.userID, code: e.errorCode });
        }));const d = s.filter((e => -1 === u.indexOf(e)));Oe.log(''.concat(n, ' ok. successUserIDList:').concat(d, ' failureUserIDList:')
          .concat(JSON.stringify(l)));let p = 0;return d.forEach(((e) => {
          t._conversationModule.patchMessageRemindType({ ID: e, isC2CConversation: !0, messageRemindType: a }) && (p += 1);
        })), p >= 1 && t._emitConversationUpdate(), s.length = u.length = 0, oi({ successUserIDList: d.map((e => ({ userID: e }))), failureUserIDList: l });
      }))
        .catch((e => (t._conversationModule.probeNetwork().then(((t) => {
          const n = m(t, 2); const o = n[0]; const a = n[1];c.setError(e, o, a).end();
        })), Oe.error(''.concat(n, ' failed. error:'), e), ai(e))));
    } }, { key: '_getModule', value(e) {
      return this._conversationModule.getModule(e);
    } }, { key: '_emitConversationUpdate', value() {
      this._conversationModule.emitConversationUpdate(!0, !1);
    } }, { key: 'setUpdateSequence', value(e) {
      this._updateSequence = e;
    } }, { key: 'reset', value() {
      Oe.log(''.concat(this._className, '.reset')), this._updateSequence = 0;
    } }]), e;
  }()); const ki = (function (e) {
    i(a, e);const n = f(a);function a(e) {
      let o;return t(this, a), (o = n.call(this, e))._className = 'ConversationModule', li.mixin(h(o)), o._messageListHandler = new ri, o._messageRemindHandler = new Di(h(o)), o.singlyLinkedList = new vi(100), o._pagingStatus = kt.NOT_START, o._pagingTimeStamp = 0, o._pagingStartIndex = 0, o._pagingPinnedTimeStamp = 0, o._pagingPinnedStartIndex = 0, o._conversationMap = new Map, o._tmpGroupList = [], o._tmpGroupAtTipsList = [], o._peerReadTimeMap = new Map, o._completedMap = new Map, o._roamingMessageKeyAndTimeMap = new Map, o._remoteGroupReadSequenceMap = new Map, o._initListeners(), o;
    } return o(a, [{ key: '_initListeners', value() {
      const e = this.getInnerEmitterInstance();e.on(ii, this._initLocalConversationList, this), e.on(ui, this._onProfileUpdated, this);
    } }, { key: 'onCheckTimer', value(e) {
      e % 60 == 0 && this._messageListHandler.traversal();
    } }, { key: '_initLocalConversationList', value() {
      const e = this; const t = new Xa(Ls);Oe.log(''.concat(this._className, '._initLocalConversationList.'));let n = ''; const o = this._getStorageConversationList();if (o) {
        for (var a = o.length, s = 0;s < a;s++) {
          const r = o[s];if (r) {
            if (r.conversationID === ''.concat(k.CONV_C2C, '@TLS#ERROR') || r.conversationID === ''.concat(k.CONV_C2C, '@TLS#NOT_FOUND')) continue;if (r.groupProfile) {
              const i = r.groupProfile.type;if (it(i)) continue;
            }
          } this._conversationMap.set(o[s].conversationID, new Si(o[s]));
        } this.emitConversationUpdate(!0, !1), n = 'count:'.concat(a);
      } else n = 'count:0';t.setNetworkType(this.getNetworkType()).setMessage(n)
        .end(), this.getModule(Ft) || this.triggerReady(), this.ready((() => {
        e._tmpGroupList.length > 0 && (e.updateConversationGroupProfile(e._tmpGroupList), e._tmpGroupList.length = 0);
      })), this._syncConversationList();
    } }, { key: 'onMessageSent', value(e) {
      this._onSendOrReceiveMessage({ conversationOptionsList: e.conversationOptionsList, isInstantMessage: !0 });
    } }, { key: 'onNewMessage', value(e) {
      this._onSendOrReceiveMessage(e);
    } }, { key: '_onSendOrReceiveMessage', value(e) {
      const t = this; const n = e.conversationOptionsList; const o = e.isInstantMessage; const a = void 0 === o || o; const s = e.isUnreadC2CMessage; const r = void 0 !== s && s;this._isReady ? 0 !== n.length && (this._getC2CPeerReadTime(n), this._updateLocalConversationList({ conversationOptionsList: n, isInstantMessage: a, isUnreadC2CMessage: r, isFromGetConversations: !1 }), this._setStorageConversationList(), this.emitConversationUpdate()) : this.ready((() => {
        t._onSendOrReceiveMessage(e);
      }));
    } }, { key: 'updateConversationGroupProfile', value(e) {
      const t = this;Fe(e) && 0 === e.length || (0 !== this._conversationMap.size ? (e.forEach(((e) => {
        const n = 'GROUP'.concat(e.groupID);if (t._conversationMap.has(n)) {
          const o = t._conversationMap.get(n);o.groupProfile = e, o.lastMessage.lastSequence < e.nextMessageSeq && (o.lastMessage.lastSequence = e.nextMessageSeq - 1), o.subType || (o.subType = e.type);
        }
      })), this.emitConversationUpdate(!0, !1)) : this._tmpGroupList = e);
    } }, { key: '_updateConversationUserProfile', value(e) {
      const t = this;e.data.forEach(((e) => {
        const n = 'C2C'.concat(e.userID);t._conversationMap.has(n) && (t._conversationMap.get(n).userProfile = e);
      })), this.emitConversationUpdate(!0, !1);
    } }, { key: 'onMessageRevoked', value(e) {
      const t = this;if (0 !== e.length) {
        let n = null; let o = !1;e.forEach(((e) => {
          (n = t._conversationMap.get(e.conversationID)) && n.isLastMessageRevoked(e) && (o = !0, n.setLastMessageRevoked(!0));
        })), o && this.emitConversationUpdate(!0, !1);
      }
    } }, { key: 'onMessageDeleted', value(e) {
      if (0 !== e.length) {
        e.forEach(((e) => {
          e.isDeleted = !0;
        }));for (var t = e[0].conversationID, n = this._messageListHandler.getLocalMessageList(t), o = {}, a = n.length - 1;a >= 0;a--) if (!n[a].isDeleted) {
          o = n[a];break;
        } const s = this._conversationMap.get(t);if (s) {
          let r = !1;s.lastMessage.lastSequence === o.sequence && s.lastMessage.lastTime === o.time || (It(o) && (o = void 0), s.updateLastMessage(o), r = !0, Oe.log(''.concat(this._className, '.onMessageDeleted. update conversationID:').concat(t, ' with lastMessage:'), s.lastMessage)), t.startsWith(k.CONV_C2C) && this.updateUnreadCount(t), r && this.emitConversationUpdate(!0, !1);
        }
      }
    } }, { key: 'onNewGroupAtTips', value(e) {
      const t = this; const n = e.dataList; let o = null;n.forEach(((e) => {
        e.groupAtTips ? o = e.groupAtTips : e.elements && (o = e.elements), o.__random = e.random, o.__sequence = e.clientSequence, t._tmpGroupAtTipsList.push(o);
      })), Oe.debug(''.concat(this._className, '.onNewGroupAtTips isReady:').concat(this._isReady), this._tmpGroupAtTipsList), this._isReady && this._handleGroupAtTipsList();
    } }, { key: '_handleGroupAtTipsList', value() {
      const e = this;if (0 !== this._tmpGroupAtTipsList.length) {
        let t = !1;this._tmpGroupAtTipsList.forEach(((n) => {
          const o = n.groupID;if (n.from !== e.getMyUserID()) {
            const a = e._conversationMap.get(''.concat(k.CONV_GROUP).concat(o));a && (a.updateGroupAtInfoList(n), t = !0);
          }
        })), t && this.emitConversationUpdate(!0, !1), this._tmpGroupAtTipsList.length = 0;
      }
    } }, { key: '_getC2CPeerReadTime', value(e) {
      const t = this; const n = [];if (e.forEach(((e) => {
        t._conversationMap.has(e.conversationID) || e.type !== k.CONV_C2C || n.push(e.conversationID.replace(k.CONV_C2C, ''));
      })), n.length > 0) {
        Oe.debug(''.concat(this._className, '._getC2CPeerReadTime userIDList:').concat(n));const o = this.getModule(Ft);o && o.getRemotePeerReadTime(n);
      }
    } }, { key: '_getStorageConversationList', value() {
      return this.getModule(Ht).getItem('conversationMap');
    } }, { key: '_setStorageConversationList', value() {
      const e = this.getLocalConversationList().slice(0, 20)
        .map((e => ({ conversationID: e.conversationID, type: e.type, subType: e.subType, lastMessage: e.lastMessage, groupProfile: e.groupProfile, userProfile: e.userProfile })));this.getModule(Ht).setItem('conversationMap', e);
    } }, { key: 'emitConversationUpdate', value() {
      const e = !(arguments.length > 0 && void 0 !== arguments[0]) || arguments[0]; const t = !(arguments.length > 1 && void 0 !== arguments[1]) || arguments[1]; const n = M(this._conversationMap.values());if (t) {
        const o = this.getModule(qt);o && o.updateGroupLastMessage(n);
      }e && this.emitOuterEvent(D.CONVERSATION_LIST_UPDATED, n);
    } }, { key: 'getLocalConversationList', value() {
      return M(this._conversationMap.values());
    } }, { key: 'getLocalConversation', value(e) {
      return this._conversationMap.get(e);
    } }, { key: '_syncConversationList', value() {
      const e = this; const t = new Xa(Rs);return this._pagingStatus === kt.NOT_START && this._conversationMap.clear(), this._pagingGetConversationList().then((n => (e._pagingStatus = kt.RESOLVED, e._setStorageConversationList(), e._handleC2CPeerReadTime(), e._patchConversationProperties(), t.setMessage(e._conversationMap.size).setNetworkType(e.getNetworkType())
        .end(), n)))
        .catch((n => (e._pagingStatus = kt.REJECTED, t.setMessage(e._pagingTimeStamp), e.probeNetwork().then(((e) => {
          const o = m(e, 2); const a = o[0]; const s = o[1];t.setError(n, a, s).end();
        })), ai(n))));
    } }, { key: '_patchConversationProperties', value() {
      const e = this; const t = Date.now(); const n = this.checkAndPatchRemark(); const o = this._messageRemindHandler.getC2CMessageRemindType(); const a = this.getModule(qt).getGroupList();Promise.all([n, o, a]).then((() => {
        const n = Date.now() - t;Oe.log(''.concat(e._className, '._patchConversationProperties ok. cost ').concat(n, ' ms')), e.emitConversationUpdate(!0, !1);
      }));
    } }, { key: '_pagingGetConversationList', value() {
      const e = this; const t = ''.concat(this._className, '._pagingGetConversationList');return Oe.log(''.concat(t, ' timeStamp:').concat(this._pagingTimeStamp, ' startIndex:')
        .concat(this._pagingStartIndex) + ' pinnedTimeStamp:'.concat(this._pagingPinnedTimeStamp, ' pinnedStartIndex:').concat(this._pagingPinnedStartIndex)), this._pagingStatus = kt.PENDING, this.request({ protocolName: En, requestData: { fromAccount: this.getMyUserID(), timeStamp: this._pagingTimeStamp, startIndex: this._pagingStartIndex, pinnedTimeStamp: this._pagingPinnedTimeStamp, pinnedStartIndex: this._pagingStartIndex, orderType: 1 } }).then(((n) => {
        const o = n.data; const a = o.completeFlag; const s = o.conversations; const r = void 0 === s ? [] : s; const i = o.timeStamp; const c = o.startIndex; const u = o.pinnedTimeStamp; const l = o.pinnedStartIndex;if (Oe.log(''.concat(t, ' ok. completeFlag:').concat(a, ' count:')
          .concat(r.length, ' isReady:')
          .concat(e._isReady)), r.length > 0) {
          const d = e._getConversationOptions(r);e._updateLocalConversationList({ conversationOptionsList: d, isFromGetConversations: !0 }), e.isLoggedIn() && e.emitConversationUpdate();
        } if (!e._isReady) {
          if (!e.isLoggedIn()) return oi();e.triggerReady();
        } return e._pagingTimeStamp = i, e._pagingStartIndex = c, e._pagingPinnedTimeStamp = u, e._pagingPinnedStartIndex = l, 1 !== a ? e._pagingGetConversationList() : (e._handleGroupAtTipsList(), oi());
      }))
        .catch(((n) => {
          throw e.isLoggedIn() && (e._isReady || (Oe.warn(''.concat(t, ' failed. error:'), n), e.triggerReady())), n;
        }));
    } }, { key: '_updateLocalConversationList', value(e) {
      let t; const n = e.isFromGetConversations; const o = Date.now();t = this._getTmpConversationListMapping(e), this._conversationMap = new Map(this._sortConversationList([].concat(M(t.toBeUpdatedConversationList), M(this._conversationMap)))), n || this._updateUserOrGroupProfile(t.newConversationList), Oe.debug(''.concat(this._className, '._updateLocalConversationList cost ').concat(Date.now() - o, ' ms'));
    } }, { key: '_getTmpConversationListMapping', value(e) {
      for (var t = e.conversationOptionsList, n = e.isFromGetConversations, o = e.isInstantMessage, a = e.isUnreadC2CMessage, s = void 0 !== a && a, r = [], i = [], c = this.getModule(qt), u = this.getModule(Vt), l = 0, d = t.length;l < d;l++) {
        const p = new Si(t[l]); const g = p.conversationID;if (g !== ''.concat(k.CONV_C2C, '@TLS#ERROR') && g !== ''.concat(k.CONV_C2C, '@TLS#NOT_FOUND')) if (this._conversationMap.has(g)) {
          const h = this._conversationMap.get(g); const _ = ['unreadCount', 'allowType', 'adminForbidType', 'payload', 'isPinned'];!1 === o && _.push('lastMessage');const f = t[l].lastMessage; const m = !qe(f);m || this._onLastMessageNotExist(t[l]), qe(o) && m && null === h.lastMessage.payload && (h.lastMessage.payload = f.payload), Ye(h, p, _, [null, void 0, '', 0, NaN]), h.updateUnreadCount({ nextUnreadCount: p.unreadCount, isFromGetConversations: n, isUnreadC2CMessage: s }), o && m && (h.lastMessage.payload = f.payload, h.type === k.CONV_GROUP && (h.lastMessage.nameCard = f.nameCard, h.lastMessage.nick = f.nick)), m && h.lastMessage.cloudCustomData !== f.cloudCustomData && (h.lastMessage.cloudCustomData = f.cloudCustomData || ''), this._conversationMap.delete(g), r.push([g, h]);
        } else {
          if (p.type === k.CONV_GROUP && c) {
            const M = p.groupProfile.groupID; const v = c.getLocalGroupProfile(M);v && (p.groupProfile = v, p.updateUnreadCount({ nextUnreadCount: 0 }));
          } else if (p.type === k.CONV_C2C) {
            const y = g.replace(k.CONV_C2C, '');u && u.isMyFriend(y) && (p.remark = u.getFriendRemark(y));
          }i.push(p), r.push([g, p]);
        }
      } return { toBeUpdatedConversationList: r, newConversationList: i };
    } }, { key: '_onLastMessageNotExist', value(e) {
      new Xa(Sr).setMessage(''.concat(JSON.stringify(e)))
        .setNetworkType(this.getNetworkType())
        .end();
    } }, { key: '_sortConversationList', value(e) {
      const t = []; const n = [];return e.forEach(((e) => {
        !0 === e[1].isPinned ? t.push(e) : n.push(e);
      })), t.sort(((e, t) => t[1].lastMessage.lastTime - e[1].lastMessage.lastTime)).concat(n.sort(((e, t) => t[1].lastMessage.lastTime - e[1].lastMessage.lastTime)));
    } }, { key: '_sortConversationListAndEmitEvent', value() {
      this._conversationMap = new Map(this._sortConversationList(M(this._conversationMap))), this.emitConversationUpdate(!0, !1);
    } }, { key: '_updateUserOrGroupProfile', value(e) {
      const t = this;if (0 !== e.length) {
        const n = []; const o = []; const a = this.getModule(Ut); const s = this.getModule(qt);e.forEach(((e) => {
          if (e.type === k.CONV_C2C)n.push(e.toAccount);else if (e.type === k.CONV_GROUP) {
            const t = e.toAccount;s.hasLocalGroup(t) ? e.groupProfile = s.getLocalGroupProfile(t) : o.push(t);
          }
        })), Oe.log(''.concat(this._className, '._updateUserOrGroupProfile c2cUserIDList:').concat(n, ' groupIDList:')
          .concat(o)), n.length > 0 && a.getUserProfile({ userIDList: n }).then(((e) => {
          const n = e.data;Fe(n) ? n.forEach(((e) => {
            t._conversationMap.get('C2C'.concat(e.userID)).userProfile = e;
          })) : t._conversationMap.get('C2C'.concat(n.userID)).userProfile = n;
        })), o.length > 0 && s.getGroupProfileAdvance({ groupIDList: o, responseFilter: { groupBaseInfoFilter: ['Type', 'Name', 'FaceUrl'] } }).then(((e) => {
          e.data.successGroupList.forEach(((e) => {
            const n = 'GROUP'.concat(e.groupID);if (t._conversationMap.has(n)) {
              const o = t._conversationMap.get(n);Ye(o.groupProfile, e, [], [null, void 0, '', 0, NaN]), !o.subType && e.type && (o.subType = e.type);
            }
          }));
        }));
      }
    } }, { key: '_getConversationOptions', value(e) {
      const t = []; const n = e.filter(((e) => {
        const t = e.lastMsg;return Ue(t);
      })).filter(((e) => {
        const t = e.type; const n = e.userID;return 1 === t && '@TLS#NOT_FOUND' !== n && '@TLS#ERROR' !== n || 2 === t;
      }))
        .map(((e) => {
          if (1 === e.type) {
            const n = { userID: e.userID, nick: e.peerNick, avatar: e.peerAvatar };return t.push(n), { conversationID: 'C2C'.concat(e.userID), type: 'C2C', lastMessage: { lastTime: e.time, lastSequence: e.sequence, fromAccount: e.lastC2CMsgFromAccount, messageForShow: e.messageShow, type: e.lastMsg.elements[0] ? e.lastMsg.elements[0].type : null, payload: e.lastMsg.elements[0] ? e.lastMsg.elements[0].content : null, cloudCustomData: e.cloudCustomData || '', isRevoked: 8 === e.lastMessageFlag, onlineOnlyFlag: !1, nick: '', nameCard: '' }, userProfile: new mi(n), peerReadTime: e.c2cPeerReadTime, isPinned: 1 === e.isPinned, messageRemindType: '' };
          } return { conversationID: 'GROUP'.concat(e.groupID), type: 'GROUP', lastMessage: { lastTime: e.time, lastSequence: e.messageReadSeq + e.unreadCount, fromAccount: e.msgGroupFromAccount, messageForShow: e.messageShow, type: e.lastMsg.elements[0] ? e.lastMsg.elements[0].type : null, payload: e.lastMsg.elements[0] ? e.lastMsg.elements[0].content : null, cloudCustomData: e.cloudCustomData || '', isRevoked: 2 === e.lastMessageFlag, onlineOnlyFlag: !1, nick: e.senderNick || '', nameCard: e.senderNameCard || '' }, groupProfile: new Ii({ groupID: e.groupID, name: e.groupNick, avatar: e.groupImage }), unreadCount: e.unreadCount, peerReadTime: 0, isPinned: 1 === e.isPinned, messageRemindType: '' };
        }));t.length > 0 && this.getModule(Ut).onConversationsProfileUpdated(t);return n;
    } }, { key: 'getLocalMessageList', value(e) {
      return this._messageListHandler.getLocalMessageList(e);
    } }, { key: 'deleteLocalMessage', value(e) {
      e instanceof Yr && this._messageListHandler.remove(e);
    } }, { key: 'onConversationDeleted', value(e) {
      const t = this;Oe.log(''.concat(this._className, '.onConversationDeleted')), Fe(e) && e.forEach(((e) => {
        const n = e.type; const o = e.userID; const a = e.groupID; let s = '';1 === n ? s = ''.concat(k.CONV_C2C).concat(o) : 2 === n && (s = ''.concat(k.CONV_GROUP).concat(a)), t.deleteLocalConversation(s);
      }));
    } }, { key: 'onConversationPinned', value(e) {
      const t = this;if (Fe(e)) {
        let n = !1;e.forEach(((e) => {
          let o; const a = e.type; const s = e.userID; const r = e.groupID;1 === a ? o = t.getLocalConversation(''.concat(k.CONV_C2C).concat(s)) : 2 === a && (o = t.getLocalConversation(''.concat(k.CONV_GROUP).concat(r))), o && (Oe.log(''.concat(t._className, '.onConversationPinned conversationID:').concat(o.conversationID, ' isPinned:')
            .concat(o.isPinned)), o.isPinned || (o.isPinned = !0, n = !0));
        })), n && this._sortConversationListAndEmitEvent();
      }
    } }, { key: 'onConversationUnpinned', value(e) {
      const t = this;if (Fe(e)) {
        let n = !1;e.forEach(((e) => {
          let o; const a = e.type; const s = e.userID; const r = e.groupID;1 === a ? o = t.getLocalConversation(''.concat(k.CONV_C2C).concat(s)) : 2 === a && (o = t.getLocalConversation(''.concat(k.CONV_GROUP).concat(r))), o && (Oe.log(''.concat(t._className, '.onConversationUnpinned conversationID:').concat(o.conversationID, ' isPinned:')
            .concat(o.isPinned)), o.isPinned && (o.isPinned = !1, n = !0));
        })), n && this._sortConversationListAndEmitEvent();
      }
    } }, { key: 'getMessageList', value(e) {
      const t = this; const n = e.conversationID; const o = e.nextReqMessageID; let a = e.count; const s = ''.concat(this._className, '.getMessageList'); const r = this.getLocalConversation(n); let i = '';if (r && r.groupProfile && (i = r.groupProfile.type), it(i)) return Oe.log(''.concat(s, ' not available in avchatroom. conversationID:').concat(n)), oi({ messageList: [], nextReqMessageID: '', isCompleted: !0 });(qe(a) || a > 15) && (a = 15);let c = this._computeLeftCount({ conversationID: n, nextReqMessageID: o });return Oe.log(''.concat(s, ' conversationID:').concat(n, ' leftCount:')
        .concat(c, ' count:')
        .concat(a, ' nextReqMessageID:')
        .concat(o)), this._needGetHistory({ conversationID: n, leftCount: c, count: a }) ? this.getHistoryMessages({ conversationID: n, nextReqMessageID: o, count: 20 }).then((() => (c = t._computeLeftCount({ conversationID: n, nextReqMessageID: o }), $r(t._computeResult({ conversationID: n, nextReqMessageID: o, count: a, leftCount: c }))))) : (Oe.log(''.concat(s, '.getMessageList get message list from memory')), this.modifyMessageList(n), oi(this._computeResult({ conversationID: n, nextReqMessageID: o, count: a, leftCount: c })));
    } }, { key: '_computeLeftCount', value(e) {
      const t = e.conversationID; const n = e.nextReqMessageID;return n ? this._messageListHandler.getLocalMessageList(t).findIndex((e => e.ID === n)) : this._getMessageListSize(t);
    } }, { key: '_getMessageListSize', value(e) {
      return this._messageListHandler.getLocalMessageList(e).length;
    } }, { key: '_needGetHistory', value(e) {
      const t = e.conversationID; const n = e.leftCount; const o = e.count; const a = this.getLocalConversation(t); let s = '';return a && a.groupProfile && (s = a.groupProfile.type), !lt(t) && !it(s) && (n < o && !this._completedMap.has(t));
    } }, { key: '_computeResult', value(e) {
      const t = e.conversationID; const n = e.nextReqMessageID; const o = e.count; const a = e.leftCount; const s = this._computeMessageList({ conversationID: t, nextReqMessageID: n, count: o }); const r = this._computeIsCompleted({ conversationID: t, leftCount: a, count: o }); const i = this._computeNextReqMessageID({ messageList: s, isCompleted: r, conversationID: t }); const c = ''.concat(this._className, '._computeResult. conversationID:').concat(t);return Oe.log(''.concat(c, ' leftCount:').concat(a, ' count:')
        .concat(o, ' nextReqMessageID:')
        .concat(i, ' isCompleted:')
        .concat(r)), { messageList: s, nextReqMessageID: i, isCompleted: r };
    } }, { key: '_computeMessageList', value(e) {
      const t = e.conversationID; const n = e.nextReqMessageID; const o = e.count; const a = this._messageListHandler.getLocalMessageList(t); const s = this._computeIndexEnd({ nextReqMessageID: n, messageList: a }); const r = this._computeIndexStart({ indexEnd: s, count: o });return a.slice(r, s);
    } }, { key: '_computeNextReqMessageID', value(e) {
      const t = e.messageList; const n = e.isCompleted; const o = e.conversationID;if (!n) return 0 === t.length ? '' : t[0].ID;const a = this._messageListHandler.getLocalMessageList(o);return 0 === a.length ? '' : a[0].ID;
    } }, { key: '_computeIndexEnd', value(e) {
      const t = e.messageList; const n = void 0 === t ? [] : t; const o = e.nextReqMessageID;return o ? n.findIndex((e => e.ID === o)) : n.length;
    } }, { key: '_computeIndexStart', value(e) {
      const t = e.indexEnd; const n = e.count;return t > n ? t - n : 0;
    } }, { key: '_computeIsCompleted', value(e) {
      const t = e.conversationID;return !!(e.leftCount <= e.count && this._completedMap.has(t));
    } }, { key: 'getHistoryMessages', value(e) {
      const t = e.conversationID; const n = e.nextReqMessageID;if (t === k.CONV_SYSTEM) return oi();e.count ? e.count > 20 && (e.count = 20) : e.count = 15;let o = this._messageListHandler.getLocalOldestMessageByConversationID(t);o || ((o = {}).time = 0, o.sequence = 0, 0 === t.indexOf(k.CONV_C2C) ? (o.to = t.replace(k.CONV_C2C, ''), o.conversationType = k.CONV_C2C) : 0 === t.indexOf(k.CONV_GROUP) && (o.to = t.replace(k.CONV_GROUP, ''), o.conversationType = k.CONV_GROUP));let a = ''; let s = null; const r = this._roamingMessageKeyAndTimeMap.has(t);switch (o.conversationType) {
        case k.CONV_C2C:return a = t.replace(k.CONV_C2C, ''), (s = this.getModule(Ft)) ? s.getRoamingMessage({ conversationID: e.conversationID, peerAccount: a, count: e.count, lastMessageTime: r ? this._roamingMessageKeyAndTimeMap.get(t).lastMessageTime : 0, messageKey: r ? this._roamingMessageKeyAndTimeMap.get(t).messageKey : '' }) : ai({ code: Do.CANNOT_FIND_MODULE, message: Ga });case k.CONV_GROUP:return (s = this.getModule(qt)) ? s.getRoamingMessage({ conversationID: e.conversationID, groupID: o.to, count: e.count, sequence: n && !1 === o._onlineOnlyFlag ? o.sequence - 1 : o.sequence }) : ai({ code: Do.CANNOT_FIND_MODULE, message: Ga });default:return oi();
      }
    } }, { key: 'patchConversationLastMessage', value(e) {
      const t = this.getLocalConversation(e);if (t) {
        const n = t.lastMessage; const o = n.messageForShow; const a = n.payload;if (It(o) || It(a)) {
          const s = this._messageListHandler.getLocalMessageList(e);if (0 === s.length) return;const r = s[s.length - 1];Oe.log(''.concat(this._className, '.patchConversationLastMessage conversationID:').concat(e, ' payload:'), r.payload), t.updateLastMessage(r);
        }
      }
    } }, { key: 'storeRoamingMessage', value() {
      const e = arguments.length > 0 && void 0 !== arguments[0] ? arguments[0] : []; const t = arguments.length > 1 ? arguments[1] : void 0; const n = t.startsWith(k.CONV_C2C) ? k.CONV_C2C : k.CONV_GROUP; let o = null; const a = []; let s = 0; let i = e.length; let c = null; const u = n === k.CONV_GROUP; const l = this.getModule(Yt); let d = function () {
        s = u ? e.length - 1 : 0, i = u ? 0 : e.length;
      }; let p = function () {
        u ? --s : ++s;
      }; let g = function () {
        return u ? s >= i : s < i;
      };for (d();g();p()) if (u && 1 === e[s].sequence && this.setCompleted(t), 1 !== e[s].isPlaceMessage) if ((o = new Yr(e[s])).to = e[s].to, o.isSystemMessage = !!e[s].isSystemMessage, o.conversationType = n, 4 === e[s].event ? c = { type: k.MSG_GRP_TIP, content: r(r({}, e[s].elements), {}, { groupProfile: e[s].groupProfile }) } : (e[s].elements = l.parseElements(e[s].elements, e[s].from), c = e[s].elements), u || o.setNickAndAvatar({ nick: e[s].nick, avatar: e[s].avatar }), It(c)) {
        const h = new Xa(ys);h.setMessage('from:'.concat(o.from, ' to:').concat(o.to, ' sequence:')
          .concat(o.sequence, ' event:')
          .concat(e[s].event)), h.setNetworkType(this.getNetworkType()).setLevel('warning')
          .end();
      } else o.setElement(c), o.reInitialize(this.getMyUserID()), a.push(o);return this._messageListHandler.unshift(a), d = p = g = null, a;
    } }, { key: 'setMessageRead', value(e) {
      const t = e.conversationID; const n = (e.messageID, this.getLocalConversation(t));if (Oe.log(''.concat(this._className, '.setMessageRead conversationID:').concat(t, ' unreadCount:')
        .concat(n ? n.unreadCount : 0)), !n) return oi();if (n.type !== k.CONV_GROUP || It(n.groupAtInfoList) || this.deleteGroupAtTips(t), 0 === n.unreadCount) return oi();const o = this._messageListHandler.getLocalLastMessage(t); let a = n.lastMessage.lastTime;o && a < o.time && (a = o.time);let s = n.lastMessage.lastSequence;o && s < o.sequence && (s = o.sequence);let r = null;switch (n.type) {
        case k.CONV_C2C:return (r = this.getModule(Ft)) ? r.setMessageRead({ conversationID: t, lastMessageTime: a }) : ai({ code: Do.CANNOT_FIND_MODULE, message: Ga });case k.CONV_GROUP:return (r = this._moduleManager.getModule(qt)) ? r.setMessageRead({ conversationID: t, lastMessageSeq: s }) : ai({ code: Do.CANNOT_FIND_MODULE, message: Ga });case k.CONV_SYSTEM:return n.unreadCount = 0, this.emitConversationUpdate(!0, !1), oi();default:return oi();
      }
    } }, { key: 'setAllMessageRead', value() {
      const e = this; const t = arguments.length > 0 && void 0 !== arguments[0] ? arguments[0] : {}; const n = ''.concat(this._className, '.setAllMessageRead');t.scope || (t.scope = k.READ_ALL_MSG), Oe.log(''.concat(n, ' options:'), t);const o = this._createSetAllMessageReadPack(t);if (0 === o.readAllC2CMessage && 0 === o.groupMessageReadInfoList.length) return oi();const a = new Xa(Os);return this.request({ protocolName: Wn, requestData: o }).then(((n) => {
        const o = n.data; const s = e._handleAllMessageRead(o);return a.setMessage('scope:'.concat(t.scope, ' failureGroups:').concat(JSON.stringify(s))).setNetworkType(e.getNetworkType())
          .end(), oi();
      }))
        .catch((t => (e.probeNetwork().then(((e) => {
          const n = m(e, 2); const o = n[0]; const s = n[1];a.setError(t, o, s).end();
        })), Oe.warn(''.concat(n, ' failed. error:'), t), ai({ code: t && t.code ? t.code : Do.MESSAGE_UNREAD_ALL_FAIL, message: t && t.message ? t.message : xo }))));
    } }, { key: '_getConversationLastMessageSequence', value(e) {
      const t = this._messageListHandler.getLocalLastMessage(e.conversationID); let n = e.lastMessage.lastSequence;return t && n < t.sequence && (n = t.sequence), n;
    } }, { key: '_getConversationLastMessageTime', value(e) {
      const t = this._messageListHandler.getLocalLastMessage(e.conversationID); let n = e.lastMessage.lastTime;return t && n < t.time && (n = t.time), n;
    } }, { key: '_createSetAllMessageReadPack', value(e) {
      let t; const n = { readAllC2CMessage: 0, groupMessageReadInfoList: [] }; const o = e.scope; const a = S(this._conversationMap);try {
        for (a.s();!(t = a.n()).done;) {
          const s = m(t.value, 2)[1];if (s.unreadCount > 0) if (s.type === k.CONV_C2C && 0 === n.readAllC2CMessage) {
            if (o === k.READ_ALL_MSG)n.readAllC2CMessage = 1;else if (o === k.READ_ALL_C2C_MSG) {
              n.readAllC2CMessage = 1;break;
            }
          } else if (s.type === k.CONV_GROUP && (o === k.READ_ALL_GROUP_MSG || o === k.READ_ALL_MSG)) {
            const r = this._getConversationLastMessageSequence(s);n.groupMessageReadInfoList.push({ groupID: s.groupProfile.groupID, messageSequence: r });
          }
        }
      } catch (i) {
        a.e(i);
      } finally {
        a.f();
      } return n;
    } }, { key: 'onPushedAllMessageRead', value(e) {
      this._handleAllMessageRead(e);
    } }, { key: '_handleAllMessageRead', value(e) {
      const t = e.groupMessageReadInfoList; const n = e.readAllC2CMessage; const o = this._parseGroupReadInfo(t);return this._updateAllConversationUnreadCount({ readAllC2CMessage: n }) >= 1 && this.emitConversationUpdate(!0, !1), o;
    } }, { key: '_parseGroupReadInfo', value(e) {
      const t = [];if (e && e.length) for (let n = 0, o = e.length;n < o;n++) {
        const a = e[n]; const s = a.groupID; const r = a.sequence; const i = a.retCode; const c = a.lastMessageSeq;qe(i) ? this._remoteGroupReadSequenceMap.set(s, c) : (this._remoteGroupReadSequenceMap.set(s, r), 0 !== i && t.push(''.concat(s, '-').concat(r, '-')
          .concat(i)));
      } return t;
    } }, { key: '_updateAllConversationUnreadCount', value(e) {
      let t; const n = e.readAllC2CMessage; let o = 0; const a = S(this._conversationMap);try {
        for (a.s();!(t = a.n()).done;) {
          const s = m(t.value, 2); const r = s[0]; const i = s[1];if (i.unreadCount >= 1) {
            if (1 === n && i.type === k.CONV_C2C) {
              const c = this._getConversationLastMessageTime(i);this.updateIsReadAfterReadReport({ conversationID: r, lastMessageTime: c });
            } else if (i.type === k.CONV_GROUP) {
              const u = r.replace(k.CONV_GROUP, '');if (this._remoteGroupReadSequenceMap.has(u)) {
                const l = this._remoteGroupReadSequenceMap.get(u); const d = this._getConversationLastMessageSequence(i);this.updateIsReadAfterReadReport({ conversationID: r, remoteReadSequence: l }), d >= l && this._remoteGroupReadSequenceMap.delete(u);
              }
            } this.updateUnreadCount(r, !1) && (o += 1);
          }
        }
      } catch (p) {
        a.e(p);
      } finally {
        a.f();
      } return o;
    } }, { key: 'isRemoteRead', value(e) {
      const t = e.conversationID; const n = e.sequence; const o = t.replace(k.CONV_GROUP, ''); let a = !1;if (this._remoteGroupReadSequenceMap.has(o)) {
        const s = this._remoteGroupReadSequenceMap.get(o);n <= s && (a = !0, Oe.log(''.concat(this._className, '.isRemoteRead conversationID:').concat(t, ' messageSequence:')
          .concat(n, ' remoteReadSequence:')
          .concat(s))), n >= s + 10 && this._remoteGroupReadSequenceMap.delete(o);
      } return a;
    } }, { key: 'updateIsReadAfterReadReport', value(e) {
      const t = e.conversationID; const n = e.lastMessageSeq; const o = e.lastMessageTime; const a = this._messageListHandler.getLocalMessageList(t);if (0 !== a.length) for (var s, r = a.length - 1;r >= 0;r--) if (s = a[r], !(o && s.time > o || n && s.sequence > n)) {
        if ('in' === s.flow && s.isRead) break;s.setIsRead(!0);
      }
    } }, { key: 'updateUnreadCount', value(e) {
      const t = !(arguments.length > 1 && void 0 !== arguments[1]) || arguments[1]; let n = !1; const o = this.getLocalConversation(e); const a = this._messageListHandler.getLocalMessageList(e);if (o) {
        const s = o.unreadCount; const r = a.filter((e => !e.isRead && !e._onlineOnlyFlag && !e.isDeleted)).length;return s !== r && (o.unreadCount = r, n = !0, Oe.log(''.concat(this._className, '.updateUnreadCount from ').concat(s, ' to ')
          .concat(r, ', conversationID:')
          .concat(e)), !0 === t && this.emitConversationUpdate(!0, !1)), n;
      }
    } }, { key: 'recomputeGroupUnreadCount', value(e) {
      const t = e.conversationID; const n = e.count; const o = this.getLocalConversation(t);if (o) {
        const a = o.unreadCount; let s = a - n;s < 0 && (s = 0), o.unreadCount = s, Oe.log(''.concat(this._className, '.recomputeGroupUnreadCount from ').concat(a, ' to ')
          .concat(s, ', conversationID:')
          .concat(t));
      }
    } }, { key: 'updateIsRead', value(e) {
      const t = this.getLocalConversation(e); const n = this.getLocalMessageList(e);if (t && 0 !== n.length && !lt(t.type)) {
        for (var o = [], a = 0, s = n.length;a < s;a++)'in' !== n[a].flow ? 'out' !== n[a].flow || n[a].isRead || n[a].setIsRead(!0) : o.push(n[a]);let r = 0;if (t.type === k.CONV_C2C) {
          const i = o.slice(-t.unreadCount).filter((e => e.isRevoked)).length;r = o.length - t.unreadCount - i;
        } else r = o.length - t.unreadCount;for (let c = 0;c < r && !o[c].isRead;c++)o[c].setIsRead(!0);
      }
    } }, { key: 'deleteGroupAtTips', value(e) {
      const t = ''.concat(this._className, '.deleteGroupAtTips');Oe.log(''.concat(t));const n = this._conversationMap.get(e);if (!n) return Promise.resolve();const o = n.groupAtInfoList;if (0 === o.length) return Promise.resolve();const a = this.getMyUserID();return this.request({ protocolName: Rn, requestData: { messageListToDelete: o.map((e => ({ from: e.from, to: a, messageSeq: e.__sequence, messageRandom: e.__random, groupID: e.groupID }))) } }).then((() => (Oe.log(''.concat(t, ' ok. count:').concat(o.length)), n.clearGroupAtInfoList(), Promise.resolve())))
        .catch((e => (Oe.error(''.concat(t, ' failed. error:'), e), ai(e))));
    } }, { key: 'appendToMessageList', value(e) {
      this._messageListHandler.pushIn(e);
    } }, { key: 'setMessageRandom', value(e) {
      this.singlyLinkedList.set(e.random);
    } }, { key: 'deleteMessageRandom', value(e) {
      this.singlyLinkedList.delete(e.random);
    } }, { key: 'pushIntoMessageList', value(e, t, n) {
      return !(!this._messageListHandler.pushIn(t, n) || this._isMessageFromCurrentInstance(t) && !n) && (e.push(t), !0);
    } }, { key: '_isMessageFromCurrentInstance', value(e) {
      return this.singlyLinkedList.has(e.random);
    } }, { key: 'revoke', value(e, t, n) {
      return this._messageListHandler.revoke(e, t, n);
    } }, { key: 'getPeerReadTime', value(e) {
      return this._peerReadTimeMap.get(e);
    } }, { key: 'recordPeerReadTime', value(e, t) {
      this._peerReadTimeMap.has(e) ? this._peerReadTimeMap.get(e) < t && this._peerReadTimeMap.set(e, t) : this._peerReadTimeMap.set(e, t);
    } }, { key: 'updateMessageIsPeerReadProperty', value(e, t) {
      if (e.startsWith(k.CONV_C2C) && t > 0) {
        const n = this._messageListHandler.updateMessageIsPeerReadProperty(e, t);n.length > 0 && this.emitOuterEvent(D.MESSAGE_READ_BY_PEER, n);
      }
    } }, { key: 'updateMessageIsModifiedProperty', value(e) {
      this._messageListHandler.updateMessageIsModifiedProperty(e);
    } }, { key: 'setCompleted', value(e) {
      Oe.log(''.concat(this._className, '.setCompleted. conversationID:').concat(e)), this._completedMap.set(e, !0);
    } }, { key: 'updateRoamingMessageKeyAndTime', value(e, t, n) {
      this._roamingMessageKeyAndTimeMap.set(e, { messageKey: t, lastMessageTime: n });
    } }, { key: 'getConversationList', value(e) {
      const t = this; const n = ''.concat(this._className, '.getConversationList'); const o = 'pagingStatus:'.concat(this._pagingStatus, ', local conversation count:').concat(this._conversationMap.size, ', options:')
        .concat(e);if (Oe.log(''.concat(n, '. ').concat(o)), this._pagingStatus === kt.REJECTED) {
        const a = new Xa(ks);return a.setMessage(o), this._syncConversationList().then((() => {
          a.setNetworkType(t.getNetworkType()).end();const n = t._getConversationList(e);return $r({ conversationList: n });
        }))
          .catch((e => (t.probeNetwork().then(((t) => {
            const n = m(t, 2); const o = n[0]; const s = n[1];a.setError(e, o, s).end();
          })), Oe.error(''.concat(n, ' failed. error:'), e), ai(e))));
      } if (0 === this._conversationMap.size) {
        const s = new Xa(ks);return s.setMessage(o), this._syncConversationList().then((() => {
          s.setNetworkType(t.getNetworkType()).end();const n = t._getConversationList(e);return $r({ conversationList: n });
        }))
          .catch((e => (t.probeNetwork().then(((t) => {
            const n = m(t, 2); const o = n[0]; const a = n[1];s.setError(e, o, a).end();
          })), Oe.error(''.concat(n, ' failed. error:'), e), ai(e))));
      } const r = this._getConversationList(e);return Oe.log(''.concat(n, '. returned conversation count:').concat(r.length)), oi({ conversationList: r });
    } }, { key: '_getConversationList', value(e) {
      const t = this;if (qe(e)) return this.getLocalConversationList();if (Fe(e)) {
        const n = [];return e.forEach(((e) => {
          if (t._conversationMap.has(e)) {
            const o = t.getLocalConversation(e);n.push(o);
          }
        })), n;
      }
    } }, { key: '_handleC2CPeerReadTime', value() {
      let e; const t = S(this._conversationMap);try {
        for (t.s();!(e = t.n()).done;) {
          const n = m(e.value, 2); const o = n[0]; const a = n[1];a.type === k.CONV_C2C && (Oe.debug(''.concat(this._className, '._handleC2CPeerReadTime conversationID:').concat(o, ' peerReadTime:')
            .concat(a.peerReadTime)), this.recordPeerReadTime(o, a.peerReadTime));
        }
      } catch (s) {
        t.e(s);
      } finally {
        t.f();
      }
    } }, { key: 'getConversationProfile', value(e) {
      let t; const n = this;if ((t = this._conversationMap.has(e) ? this._conversationMap.get(e) : new Si({ conversationID: e, type: e.slice(0, 3) === k.CONV_C2C ? k.CONV_C2C : k.CONV_GROUP }))._isInfoCompleted || t.type === k.CONV_SYSTEM) return oi({ conversation: t });const o = new Xa(Es); const a = ''.concat(this._className, '.getConversationProfile');return Oe.log(''.concat(a, '. conversationID:').concat(e, ' remark:')
        .concat(t.remark, ' lastMessage:'), t.lastMessage), this._updateUserOrGroupProfileCompletely(t).then(((s) => {
        o.setNetworkType(n.getNetworkType()).setMessage('conversationID:'.concat(e, ' unreadCount:').concat(s.data.conversation.unreadCount))
          .end();const r = n.getModule(Vt);if (r && t.type === k.CONV_C2C) {
          const i = e.replace(k.CONV_C2C, '');if (r.isMyFriend(i)) {
            const c = r.getFriendRemark(i);t.remark !== c && (t.remark = c, Oe.log(''.concat(a, '. conversationID:').concat(e, ' patch remark:')
              .concat(t.remark)));
          }
        } return Oe.log(''.concat(a, ' ok. conversationID:').concat(e)), s;
      }))
        .catch((t => (n.probeNetwork().then(((n) => {
          const a = m(n, 2); const s = a[0]; const r = a[1];o.setError(t, s, r).setMessage('conversationID:'.concat(e))
            .end();
        })), Oe.error(''.concat(a, ' failed. error:'), t), ai(t))));
    } }, { key: '_updateUserOrGroupProfileCompletely', value(e) {
      const t = this;return e.type === k.CONV_C2C ? this.getModule(Ut).getUserProfile({ userIDList: [e.toAccount] })
        .then(((n) => {
          const o = n.data;return 0 === o.length ? ai(new ei({ code: Do.USER_OR_GROUP_NOT_FOUND, message: ra })) : (e.userProfile = o[0], e._isInfoCompleted = !0, t._unshiftConversation(e), oi({ conversation: e }));
        })) : this.getModule(qt).getGroupProfile({ groupID: e.toAccount })
        .then((n => (e.groupProfile = n.data.group, e._isInfoCompleted = !0, t._unshiftConversation(e), oi({ conversation: e }))));
    } }, { key: '_unshiftConversation', value(e) {
      e instanceof Si && !this._conversationMap.has(e.conversationID) && (this._conversationMap = new Map([[e.conversationID, e]].concat(M(this._conversationMap))), this._setStorageConversationList(), this.emitConversationUpdate(!0, !1));
    } }, { key: '_onProfileUpdated', value(e) {
      const t = this;e.data.forEach(((e) => {
        const n = e.userID;if (n === t.getMyUserID())t._onMyProfileModified({ latestNick: e.nick, latestAvatar: e.avatar });else {
          const o = t._conversationMap.get(''.concat(k.CONV_C2C).concat(n));o && (o.userProfile = e);
        }
      }));
    } }, { key: 'deleteConversation', value(e) {
      const t = this; const n = { fromAccount: this.getMyUserID(), toAccount: void 0, type: void 0 };if (!this._conversationMap.has(e)) {
        const o = new ei({ code: Do.CONVERSATION_NOT_FOUND, message: sa });return ai(o);
      } switch (this._conversationMap.get(e).type) {
        case k.CONV_C2C:n.type = 1, n.toAccount = e.replace(k.CONV_C2C, '');break;case k.CONV_GROUP:n.type = 2, n.toGroupID = e.replace(k.CONV_GROUP, '');break;case k.CONV_SYSTEM:return this.getModule(qt).deleteGroupSystemNotice({ messageList: this._messageListHandler.getLocalMessageList(e) }), this.deleteLocalConversation(e), oi({ conversationID: e });default:var a = new ei({ code: Do.CONVERSATION_UN_RECORDED_TYPE, message: ia });return ai(a);
      } const s = new Xa(As);s.setMessage('conversationID:'.concat(e));const r = ''.concat(this._className, '.deleteConversation');return Oe.log(''.concat(r, '. conversationID:').concat(e)), this.setMessageRead({ conversationID: e }).then((() => t.request({ protocolName: Nn, requestData: n })))
        .then((() => (s.setNetworkType(t.getNetworkType()).end(), Oe.log(''.concat(r, ' ok')), t.deleteLocalConversation(e), oi({ conversationID: e }))))
        .catch((e => (t.probeNetwork().then(((t) => {
          const n = m(t, 2); const o = n[0]; const a = n[1];s.setError(e, o, a).end();
        })), Oe.error(''.concat(r, ' failed. error:'), e), ai(e))));
    } }, { key: 'pinConversation', value(e) {
      const t = this; const n = e.conversationID; const o = e.isPinned;if (!this._conversationMap.has(n)) return ai({ code: Do.CONVERSATION_NOT_FOUND, message: sa });const a = this.getLocalConversation(n);if (a.isPinned === o) return oi({ conversationID: n });const s = new Xa(Ns);s.setMessage('conversationID:'.concat(n, ' isPinned:').concat(o));const r = ''.concat(this._className, '.pinConversation');Oe.log(''.concat(r, '. conversationID:').concat(n, ' isPinned:')
        .concat(o));let i = null;return ct(n) ? i = { type: 1, toAccount: n.replace(k.CONV_C2C, '') } : ut(n) && (i = { type: 2, groupID: n.replace(k.CONV_GROUP, '') }), this.request({ protocolName: Ln, requestData: { fromAccount: this.getMyUserID(), operationType: !0 === o ? 1 : 2, itemList: [i] } }).then((() => (s.setNetworkType(t.getNetworkType()).end(), Oe.log(''.concat(r, ' ok')), a.isPinned !== o && (a.isPinned = o, t._sortConversationListAndEmitEvent()), $r({ conversationID: n }))))
        .catch((e => (t.probeNetwork().then(((t) => {
          const n = m(t, 2); const o = n[0]; const a = n[1];s.setError(e, o, a).end();
        })), Oe.error(''.concat(r, ' failed. error:'), e), ai(e))));
    } }, { key: 'setMessageRemindType', value(e) {
      return this._messageRemindHandler.set(e);
    } }, { key: 'patchMessageRemindType', value(e) {
      const t = e.ID; const n = e.isC2CConversation; const o = e.messageRemindType; let a = !1; const s = this.getLocalConversation(n ? ''.concat(k.CONV_C2C).concat(t) : ''.concat(k.CONV_GROUP).concat(t));return s && s.messageRemindType !== o && (s.messageRemindType = o, a = !0), a;
    } }, { key: 'onC2CMessageRemindTypeSynced', value(e) {
      const t = this;Oe.debug(''.concat(this._className, '.onC2CMessageRemindTypeSynced options:'), e), e.dataList.forEach(((e) => {
        if (!It(e.muteNotificationsSync)) {
          let n; const o = e.muteNotificationsSync; const a = o.to; const s = o.updateSequence; const r = o.muteFlag;t._messageRemindHandler.setUpdateSequence(s), 0 === r ? n = k.MSG_REMIND_ACPT_AND_NOTE : 1 === r ? n = k.MSG_REMIND_DISCARD : 2 === r && (n = k.MSG_REMIND_ACPT_NOT_NOTE);let i = 0;t.patchMessageRemindType({ ID: a, isC2CConversation: !0, messageRemindType: n }) && (i += 1), Oe.log(''.concat(t._className, '.onC2CMessageRemindTypeSynced updateCount:').concat(i)), i >= 1 && t.emitConversationUpdate(!0, !1);
        }
      }));
    } }, { key: 'deleteLocalConversation', value(e) {
      const t = this._conversationMap.has(e);Oe.log(''.concat(this._className, '.deleteLocalConversation conversationID:').concat(e, ' has:')
        .concat(t)), t && (this._conversationMap.delete(e), this._roamingMessageKeyAndTimeMap.delete(e), this._setStorageConversationList(), this._messageListHandler.removeByConversationID(e), this._completedMap.delete(e), this.emitConversationUpdate(!0, !1));
    } }, { key: 'isMessageSentByCurrentInstance', value(e) {
      return !(!this._messageListHandler.hasLocalMessage(e.conversationID, e.ID) && !this.singlyLinkedList.has(e.random));
    } }, { key: 'modifyMessageList', value(e) {
      if (e.startsWith(k.CONV_C2C) && this._conversationMap.has(e)) {
        const t = this._conversationMap.get(e); const n = Date.now();this._messageListHandler.modifyMessageSentByPeer({ conversationID: e, latestNick: t.userProfile.nick, latestAvatar: t.userProfile.avatar });const o = this.getModule(Ut).getNickAndAvatarByUserID(this.getMyUserID());this._messageListHandler.modifyMessageSentByMe({ conversationID: e, latestNick: o.nick, latestAvatar: o.avatar }), Oe.log(''.concat(this._className, '.modifyMessageList conversationID:').concat(e, ' cost ')
          .concat(Date.now() - n, ' ms'));
      }
    } }, { key: 'updateUserProfileSpecifiedKey', value(e) {
      Oe.log(''.concat(this._className, '.updateUserProfileSpecifiedKey options:'), e);const t = e.conversationID; const n = e.nick; const o = e.avatar;if (this._conversationMap.has(t)) {
        const a = this._conversationMap.get(t).userProfile;be(n) && a.nick !== n && (a.nick = n), be(o) && a.avatar !== o && (a.avatar = o), this.emitConversationUpdate(!0, !1);
      }
    } }, { key: '_onMyProfileModified', value(e) {
      const t = this; const n = this.getLocalConversationList(); const o = Date.now();n.forEach(((n) => {
        t.modifyMessageSentByMe(r({ conversationID: n.conversationID }, e));
      })), Oe.log(''.concat(this._className, '._onMyProfileModified. modify all messages sent by me, cost ').concat(Date.now() - o, ' ms'));
    } }, { key: 'modifyMessageSentByMe', value(e) {
      this._messageListHandler.modifyMessageSentByMe(e);
    } }, { key: 'getLatestMessageSentByMe', value(e) {
      return this._messageListHandler.getLatestMessageSentByMe(e);
    } }, { key: 'modifyMessageSentByPeer', value(e) {
      this._messageListHandler.modifyMessageSentByPeer(e);
    } }, { key: 'getLatestMessageSentByPeer', value(e) {
      return this._messageListHandler.getLatestMessageSentByPeer(e);
    } }, { key: 'pushIntoNoticeResult', value(e, t) {
      return !(!this._messageListHandler.pushIn(t) || this.singlyLinkedList.has(t.random)) && (e.push(t), !0);
    } }, { key: 'getGroupLocalLastMessageSequence', value(e) {
      return this._messageListHandler.getGroupLocalLastMessageSequence(e);
    } }, { key: 'checkAndPatchRemark', value() {
      const e = Promise.resolve();if (0 === this._conversationMap.size) return e;const t = this.getModule(Vt);if (!t) return e;const n = M(this._conversationMap.values()).filter((e => e.type === k.CONV_C2C));if (0 === n.length) return e;let o = 0;return n.forEach(((e) => {
        const n = e.conversationID.replace(k.CONV_C2C, '');if (t.isMyFriend(n)) {
          const a = t.getFriendRemark(n);e.remark !== a && (e.remark = a, o += 1);
        }
      })), Oe.log(''.concat(this._className, '.checkAndPatchRemark. c2c conversation count:').concat(n.length, ', patched count:')
        .concat(o)), e;
    } }, { key: 'reset', value() {
      Oe.log(''.concat(this._className, '.reset')), this._pagingStatus = kt.NOT_START, this._messageListHandler.reset(), this._messageRemindHandler.reset(), this._roamingMessageKeyAndTimeMap.clear(), this.singlyLinkedList.reset(), this._peerReadTimeMap.clear(), this._completedMap.clear(), this._conversationMap.clear(), this._pagingTimeStamp = 0, this._pagingStartIndex = 0, this._pagingPinnedTimeStamp = 0, this._pagingPinnedStartIndex = 0, this._remoteGroupReadSequenceMap.clear(), this.resetReady();
    } }]), a;
  }(sn)); const Ei = (function () {
    function e(n) {
      t(this, e), this._groupModule = n, this._className = 'GroupTipsHandler', this._cachedGroupTipsMap = new Map, this._checkCountMap = new Map, this.MAX_CHECK_COUNT = 4;
    } return o(e, [{ key: 'onCheckTimer', value(e) {
      e % 1 == 0 && this._cachedGroupTipsMap.size > 0 && this._checkCachedGroupTips();
    } }, { key: '_checkCachedGroupTips', value() {
      const e = this;this._cachedGroupTipsMap.forEach(((t, n) => {
        let o = e._checkCountMap.get(n); const a = e._groupModule.hasLocalGroup(n);Oe.log(''.concat(e._className, '._checkCachedGroupTips groupID:').concat(n, ' hasLocalGroup:')
          .concat(a, ' checkCount:')
          .concat(o)), a ? (e._notifyCachedGroupTips(n), e._checkCountMap.delete(n), e._groupModule.deleteUnjoinedAVChatRoom(n)) : o >= e.MAX_CHECK_COUNT ? (e._deleteCachedGroupTips(n), e._checkCountMap.delete(n)) : (o++, e._checkCountMap.set(n, o));
      }));
    } }, { key: 'onNewGroupTips', value(e) {
      Oe.debug(''.concat(this._className, '.onReceiveGroupTips count:').concat(e.dataList.length));const t = this.newGroupTipsStoredAndSummary(e); const n = t.eventDataList; const o = t.result; const a = t.AVChatRoomMessageList;(a.length > 0 && this._groupModule.onAVChatRoomMessage(a), n.length > 0) && (this._groupModule.getModule(xt).onNewMessage({ conversationOptionsList: n, isInstantMessage: !0 }), this._groupModule.updateNextMessageSeq(n));o.length > 0 && (this._groupModule.emitOuterEvent(D.MESSAGE_RECEIVED, o), this.handleMessageList(o));
    } }, { key: 'newGroupTipsStoredAndSummary', value(e) {
      for (var t = e.event, n = e.dataList, o = null, a = [], s = [], i = {}, c = [], u = 0, l = n.length;u < l;u++) {
        const d = n[u]; const p = d.groupProfile.groupID; const g = this._groupModule.hasLocalGroup(p);if (g || !this._groupModule.isUnjoinedAVChatRoom(p)) if (g) if (this._groupModule.isMessageFromAVChatroom(p)) {
          const h = at(d);h.event = t, c.push(h);
        } else {
          d.currentUser = this._groupModule.getMyUserID(), d.conversationType = k.CONV_GROUP, (o = new Yr(d)).setElement({ type: k.MSG_GRP_TIP, content: r(r({}, d.elements), {}, { groupProfile: d.groupProfile }) }), o.isSystemMessage = !1;const _ = this._groupModule.getModule(xt); const f = o; const m = f.conversationID; const M = f.sequence;if (6 === t)o._onlineOnlyFlag = !0, s.push(o);else if (!_.pushIntoNoticeResult(s, o)) continue;if (6 !== t || !_.getLocalConversation(m)) {
            if (6 !== t) this._groupModule.getModule(on).addMessageSequence({ key: Ha, message: o });const v = _.isRemoteRead({ conversationID: m, sequence: M });if (qe(i[m]))i[m] = a.push({ conversationID: m, unreadCount: 'in' !== o.flow || o._onlineOnlyFlag || v ? 0 : 1, type: o.conversationType, subType: o.conversationSubType, lastMessage: o }) - 1;else {
              const y = i[m];a[y].type = o.conversationType, a[y].subType = o.conversationSubType, a[y].lastMessage = o, 'in' !== o.flow || o._onlineOnlyFlag || v || a[y].unreadCount++;
            }
          }
        } else this._cacheGroupTipsAndProbe({ groupID: p, event: t, item: d });
      } return { eventDataList: a, result: s, AVChatRoomMessageList: c };
    } }, { key: 'handleMessageList', value(e) {
      const t = this;e.forEach(((e) => {
        switch (e.payload.operationType) {
          case 1:t._onNewMemberComeIn(e);break;case 2:t._onMemberQuit(e);break;case 3:t._onMemberKickedOut(e);break;case 4:t._onMemberSetAdmin(e);break;case 5:t._onMemberCancelledAdmin(e);break;case 6:t._onGroupProfileModified(e);break;case 7:t._onMemberInfoModified(e);break;default:Oe.warn(''.concat(t._className, '.handleMessageList unknown operationType:').concat(e.payload.operationType));
        }
      }));
    } }, { key: '_onNewMemberComeIn', value(e) {
      const t = e.payload; const n = t.memberNum; const o = t.groupProfile.groupID; const a = this._groupModule.getLocalGroupProfile(o);a && we(n) && (a.memberNum = n);
    } }, { key: '_onMemberQuit', value(e) {
      const t = e.payload; const n = t.memberNum; const o = t.groupProfile.groupID; const a = this._groupModule.getLocalGroupProfile(o);a && we(n) && (a.memberNum = n), this._groupModule.deleteLocalGroupMembers(o, e.payload.userIDList);
    } }, { key: '_onMemberKickedOut', value(e) {
      const t = e.payload; const n = t.memberNum; const o = t.groupProfile.groupID; const a = this._groupModule.getLocalGroupProfile(o);a && we(n) && (a.memberNum = n), this._groupModule.deleteLocalGroupMembers(o, e.payload.userIDList);
    } }, { key: '_onMemberSetAdmin', value(e) {
      const t = e.payload.groupProfile.groupID; const n = e.payload.userIDList; const o = this._groupModule.getModule(Kt);n.forEach(((e) => {
        const n = o.getLocalGroupMemberInfo(t, e);n && n.updateRole(k.GRP_MBR_ROLE_ADMIN);
      }));
    } }, { key: '_onMemberCancelledAdmin', value(e) {
      const t = e.payload.groupProfile.groupID; const n = e.payload.userIDList; const o = this._groupModule.getModule(Kt);n.forEach(((e) => {
        const n = o.getLocalGroupMemberInfo(t, e);n && n.updateRole(k.GRP_MBR_ROLE_MEMBER);
      }));
    } }, { key: '_onGroupProfileModified', value(e) {
      const t = this; const n = e.payload; const o = n.newGroupProfile; const a = n.groupProfile.groupID; const s = this._groupModule.getLocalGroupProfile(a);Object.keys(o).forEach(((e) => {
        switch (e) {
          case 'ownerID':t._ownerChanged(s, o);break;default:s[e] = o[e];
        }
      })), this._groupModule.emitGroupListUpdate(!0, !0);
    } }, { key: '_ownerChanged', value(e, t) {
      const n = e.groupID; const o = this._groupModule.getLocalGroupProfile(n); const a = this._groupModule.getMyUserID();if (a === t.ownerID) {
        o.updateGroup({ selfInfo: { role: k.GRP_MBR_ROLE_OWNER } });const s = this._groupModule.getModule(Kt); const r = s.getLocalGroupMemberInfo(n, a); const i = this._groupModule.getLocalGroupProfile(n).ownerID; const c = s.getLocalGroupMemberInfo(n, i);r && r.updateRole(k.GRP_MBR_ROLE_OWNER), c && c.updateRole(k.GRP_MBR_ROLE_MEMBER);
      }
    } }, { key: '_onMemberInfoModified', value(e) {
      const t = e.payload.groupProfile.groupID; const n = this._groupModule.getModule(Kt);e.payload.memberList.forEach(((e) => {
        const o = n.getLocalGroupMemberInfo(t, e.userID);o && e.muteTime && o.updateMuteUntil(e.muteTime);
      }));
    } }, { key: '_cacheGroupTips', value(e, t) {
      this._cachedGroupTipsMap.has(e) || this._cachedGroupTipsMap.set(e, []), this._cachedGroupTipsMap.get(e).push(t);
    } }, { key: '_deleteCachedGroupTips', value(e) {
      this._cachedGroupTipsMap.has(e) && this._cachedGroupTipsMap.delete(e);
    } }, { key: '_notifyCachedGroupTips', value(e) {
      const t = this; const n = this._cachedGroupTipsMap.get(e) || [];n.forEach(((e) => {
        t.onNewGroupTips(e);
      })), this._deleteCachedGroupTips(e), Oe.log(''.concat(this._className, '._notifyCachedGroupTips groupID:').concat(e, ' count:')
        .concat(n.length));
    } }, { key: '_cacheGroupTipsAndProbe', value(e) {
      const t = this; const n = e.groupID; const o = e.event; const a = e.item;this._cacheGroupTips(n, { event: o, dataList: [a] }), this._groupModule.getGroupSimplifiedInfo(n).then(((e) => {
        e.type === k.GRP_AVCHATROOM ? t._groupModule.hasLocalGroup(n) ? t._notifyCachedGroupTips(n) : t._groupModule.setUnjoinedAVChatRoom(n) : (t._groupModule.updateGroupMap([e]), t._notifyCachedGroupTips(n));
      })), this._checkCountMap.has(n) || this._checkCountMap.set(n, 0), Oe.log(''.concat(this._className, '._cacheGroupTipsAndProbe groupID:').concat(n));
    } }, { key: 'reset', value() {
      this._cachedGroupTipsMap.clear(), this._checkCountMap.clear();
    } }]), e;
  }()); const Ai = (function () {
    function e(n) {
      t(this, e), this._groupModule = n, this._className = 'CommonGroupHandler', this.tempConversationList = null, this._cachedGroupMessageMap = new Map, this._checkCountMap = new Map, this.MAX_CHECK_COUNT = 4, n.getInnerEmitterInstance().once(ii, this._initGroupList, this);
    } return o(e, [{ key: 'onCheckTimer', value(e) {
      e % 1 == 0 && this._cachedGroupMessageMap.size > 0 && this._checkCachedGroupMessage();
    } }, { key: '_checkCachedGroupMessage', value() {
      const e = this;this._cachedGroupMessageMap.forEach(((t, n) => {
        let o = e._checkCountMap.get(n); const a = e._groupModule.hasLocalGroup(n);Oe.log(''.concat(e._className, '._checkCachedGroupMessage groupID:').concat(n, ' hasLocalGroup:')
          .concat(a, ' checkCount:')
          .concat(o)), a ? (e._notifyCachedGroupMessage(n), e._checkCountMap.delete(n), e._groupModule.deleteUnjoinedAVChatRoom(n)) : o >= e.MAX_CHECK_COUNT ? (e._deleteCachedGroupMessage(n), e._checkCountMap.delete(n)) : (o++, e._checkCountMap.set(n, o));
      }));
    } }, { key: '_initGroupList', value() {
      const e = this;Oe.log(''.concat(this._className, '._initGroupList'));const t = new Xa(js); const n = this._groupModule.getStorageGroupList();if (Fe(n) && n.length > 0) {
        n.forEach(((t) => {
          e._groupModule.initGroupMap(t);
        })), this._groupModule.emitGroupListUpdate(!0, !1);const o = this._groupModule.getLocalGroupList().length;t.setNetworkType(this._groupModule.getNetworkType()).setMessage('group count:'.concat(o))
          .end();
      } else t.setNetworkType(this._groupModule.getNetworkType()).setMessage('group count:0')
        .end();Oe.log(''.concat(this._className, '._initGroupList ok'));
    } }, { key: 'handleUpdateGroupLastMessage', value(e) {
      const t = ''.concat(this._className, '.handleUpdateGroupLastMessage');if (Oe.debug(''.concat(t, ' conversation count:').concat(e.length, ', local group count:')
        .concat(this._groupModule.getLocalGroupList().length)), 0 !== this._groupModule.getGroupMap().size) {
        for (var n, o, a, s = !1, r = 0, i = e.length;r < i;r++)(n = e[r]).type === k.CONV_GROUP && (o = n.conversationID.split(/^GROUP/)[1], (a = this._groupModule.getLocalGroupProfile(o)) && (a.lastMessage = n.lastMessage, s = !0));s && (this._groupModule.sortLocalGroupList(), this._groupModule.emitGroupListUpdate(!0, !1));
      } else this.tempConversationList = e;
    } }, { key: 'onNewGroupMessage', value(e) {
      Oe.debug(''.concat(this._className, '.onNewGroupMessage count:').concat(e.dataList.length));const t = this._newGroupMessageStoredAndSummary(e); const n = t.conversationOptionsList; const o = t.messageList; const a = t.AVChatRoomMessageList;(a.length > 0 && this._groupModule.onAVChatRoomMessage(a), this._groupModule.filterModifiedMessage(o), n.length > 0) && (this._groupModule.getModule(xt).onNewMessage({ conversationOptionsList: n, isInstantMessage: !0 }), this._groupModule.updateNextMessageSeq(n));const s = this._groupModule.filterUnmodifiedMessage(o);s.length > 0 && this._groupModule.emitOuterEvent(D.MESSAGE_RECEIVED, s), o.length = 0;
    } }, { key: '_newGroupMessageStoredAndSummary', value(e) {
      const t = e.dataList; const n = e.event; const o = e.isInstantMessage; let a = null; const s = []; const r = []; const i = []; const c = {}; const u = k.CONV_GROUP; const l = this._groupModule.getModule(Yt); const d = t.length;d > 1 && t.sort(((e, t) => e.sequence - t.sequence));for (let p = 0;p < d;p++) {
        const g = t[p]; const h = g.groupProfile.groupID; const _ = this._groupModule.hasLocalGroup(h);if (_ || !this._groupModule.isUnjoinedAVChatRoom(h)) if (_) if (this._groupModule.isMessageFromAVChatroom(h)) {
          const f = at(g);f.event = n, i.push(f);
        } else {
          g.currentUser = this._groupModule.getMyUserID(), g.conversationType = u, g.isSystemMessage = !!g.isSystemMessage, a = new Yr(g), g.elements = l.parseElements(g.elements, g.from), a.setElement(g.elements);let m = 1 === t[p].isModified; const M = this._groupModule.getModule(xt);M.isMessageSentByCurrentInstance(a) ? a.isModified = m : m = !1;const v = this._groupModule.getModule(on);if (o && v.addMessageDelay({ currentTime: Date.now(), time: a.time }), 1 === g.onlineOnlyFlag)a._onlineOnlyFlag = !0, r.push(a);else {
            if (!M.pushIntoMessageList(r, a, m)) continue;v.addMessageSequence({ key: Ha, message: a });const y = a; const I = y.conversationID; const C = y.sequence; const T = M.isRemoteRead({ conversationID: I, sequence: C });if (qe(c[I])) {
              let S = 0;'in' === a.flow && (a._isExcludedFromUnreadCount || T || (S = 1)), c[I] = s.push({ conversationID: I, unreadCount: S, type: a.conversationType, subType: a.conversationSubType, lastMessage: a._isExcludedFromLastMessage ? '' : a }) - 1;
            } else {
              const D = c[I];s[D].type = a.conversationType, s[D].subType = a.conversationSubType, s[D].lastMessage = a._isExcludedFromLastMessage ? '' : a, 'in' === a.flow && (a._isExcludedFromUnreadCount || T || s[D].unreadCount++);
            }
          }
        } else this._cacheGroupMessageAndProbe({ groupID: h, event: n, item: g });
      } return { conversationOptionsList: s, messageList: r, AVChatRoomMessageList: i };
    } }, { key: 'onGroupMessageRevoked', value(e) {
      Oe.debug(''.concat(this._className, '.onGroupMessageRevoked nums:').concat(e.dataList.length));const t = this._groupModule.getModule(xt); const n = []; let o = null;e.dataList.forEach(((e) => {
        const a = e.elements.revokedInfos;qe(a) || a.forEach(((e) => {
          (o = t.revoke('GROUP'.concat(e.groupID), e.sequence, e.random)) && n.push(o);
        }));
      })), 0 !== n.length && (t.onMessageRevoked(n), this._groupModule.emitOuterEvent(D.MESSAGE_REVOKED, n));
    } }, { key: '_groupListTreeShaking', value(e) {
      for (var t = new Map(M(this._groupModule.getGroupMap())), n = 0, o = e.length;n < o;n++)t.delete(e[n].groupID);this._groupModule.hasJoinedAVChatRoom() && this._groupModule.getJoinedAVChatRoom().forEach(((e) => {
        t.delete(e);
      }));for (let a = M(t.keys()), s = 0, r = a.length;s < r;s++) this._groupModule.deleteGroup(a[s]);
    } }, { key: 'getGroupList', value(e) {
      const t = this; const n = ''.concat(this._className, '.getGroupList'); const o = new Xa(Bs);Oe.log(''.concat(n));const a = { introduction: 'Introduction', notification: 'Notification', createTime: 'CreateTime', ownerID: 'Owner_Account', lastInfoTime: 'LastInfoTime', memberNum: 'MemberNum', maxMemberNum: 'MaxMemberNum', joinOption: 'ApplyJoinOption', muteAllMembers: 'ShutUpAllMember' }; const s = ['Type', 'Name', 'FaceUrl', 'NextMsgSeq', 'LastMsgTime']; const r = [];return e && e.groupProfileFilter && e.groupProfileFilter.forEach(((e) => {
        a[e] && s.push(a[e]);
      })), this._pagingGetGroupList({ limit: 50, offset: 0, groupBaseInfoFilter: s, groupList: r }).then((() => {
        Oe.log(''.concat(n, ' ok. count:').concat(r.length)), t._groupListTreeShaking(r), t._groupModule.updateGroupMap(r);const e = t._groupModule.getLocalGroupList().length;return o.setNetworkType(t._groupModule.getNetworkType()).setMessage('remote count:'.concat(r.length, ', after tree shaking, local count:').concat(e))
          .end(), t.tempConversationList && (Oe.log(''.concat(n, ' update last message with tempConversationList, count:').concat(t.tempConversationList.length)), t.handleUpdateGroupLastMessage({ data: t.tempConversationList }), t.tempConversationList = null), t._groupModule.emitGroupListUpdate(), t._groupModule.patchGroupMessageRemindType(), t._groupModule.recomputeUnreadCount(), $r({ groupList: t._groupModule.getLocalGroupList() });
      }))
        .catch((e => (t._groupModule.probeNetwork().then(((t) => {
          const n = m(t, 2); const a = n[0]; const s = n[1];o.setError(e, a, s).end();
        })), Oe.error(''.concat(n, ' failed. error:'), e), ai(e))));
    } }, { key: '_pagingGetGroupList', value(e) {
      const t = this; const n = ''.concat(this._className, '._pagingGetGroupList'); const o = e.limit; let a = e.offset; const s = e.groupBaseInfoFilter; const r = e.groupList; const i = new Xa($s);return this._groupModule.request({ protocolName: On, requestData: { memberAccount: this._groupModule.getMyUserID(), limit: o, offset: a, responseFilter: { groupBaseInfoFilter: s, selfInfoFilter: ['Role', 'JoinTime', 'MsgFlag', 'MsgSeq'] } } }).then(((e) => {
        const c = e.data; const u = c.groups; const l = c.totalCount;r.push.apply(r, M(u));const d = a + o; const p = !(l > d);return i.setNetworkType(t._groupModule.getNetworkType()).setMessage('offset:'.concat(a, ' totalCount:').concat(l, ' isCompleted:')
          .concat(p, ' currentCount:')
          .concat(r.length))
          .end(), p ? (Oe.log(''.concat(n, ' ok. totalCount:').concat(l)), $r({ groupList: r })) : (a = d, t._pagingGetGroupList({ limit: o, offset: a, groupBaseInfoFilter: s, groupList: r }));
      }))
        .catch((e => (t._groupModule.probeNetwork().then(((t) => {
          const n = m(t, 2); const o = n[0]; const a = n[1];i.setError(e, o, a).end();
        })), ai(e))));
    } }, { key: '_cacheGroupMessage', value(e, t) {
      this._cachedGroupMessageMap.has(e) || this._cachedGroupMessageMap.set(e, []), this._cachedGroupMessageMap.get(e).push(t);
    } }, { key: '_deleteCachedGroupMessage', value(e) {
      this._cachedGroupMessageMap.has(e) && this._cachedGroupMessageMap.delete(e);
    } }, { key: '_notifyCachedGroupMessage', value(e) {
      const t = this; const n = this._cachedGroupMessageMap.get(e) || [];n.forEach(((e) => {
        t.onNewGroupMessage(e);
      })), this._deleteCachedGroupMessage(e), Oe.log(''.concat(this._className, '._notifyCachedGroupMessage groupID:').concat(e, ' count:')
        .concat(n.length));
    } }, { key: '_cacheGroupMessageAndProbe', value(e) {
      const t = this; const n = e.groupID; const o = e.event; const a = e.item;this._cacheGroupMessage(n, { event: o, dataList: [a] }), this._groupModule.getGroupSimplifiedInfo(n).then(((e) => {
        e.type === k.GRP_AVCHATROOM ? t._groupModule.hasLocalGroup(n) ? t._notifyCachedGroupMessage(n) : t._groupModule.setUnjoinedAVChatRoom(n) : (t._groupModule.updateGroupMap([e]), t._notifyCachedGroupMessage(n));
      })), this._checkCountMap.has(n) || this._checkCountMap.set(n, 0), Oe.log(''.concat(this._className, '._cacheGroupMessageAndProbe groupID:').concat(n));
    } }, { key: 'reset', value() {
      this._cachedGroupMessageMap.clear(), this._checkCountMap.clear(), this._groupModule.getInnerEmitterInstance().once(ii, this._initGroupList, this);
    } }]), e;
  }()); const Ni = { 1: 'init', 2: 'modify', 3: 'clear', 4: 'delete' }; const Li = (function () {
    function e(n) {
      t(this, e), this._groupModule = n, this._className = 'GroupAttributesHandler', this._groupAttributesMap = new Map, this.CACHE_EXPIRE_TIME = 3e4, this._groupModule.getInnerEmitterInstance().on(ci, this._onCloudConfigUpdated, this);
    } return o(e, [{ key: '_onCloudConfigUpdated', value() {
      const e = this._groupModule.getCloudConfig('grp_attr_cache_time');qe(e) || (this.CACHE_EXPIRE_TIME = Number(e));
    } }, { key: 'updateLocalMainSequenceOnReconnected', value() {
      this._groupAttributesMap.forEach(((e) => {
        e.localMainSequence = 0;
      }));
    } }, { key: 'onGroupAttributesUpdated', value(e) {
      const t = this; const n = e.groupID; const o = e.groupAttributeOption; const a = o.mainSequence; const s = o.hasChangedAttributeInfo; const r = o.groupAttributeList; let i = void 0 === r ? [] : r; const c = o.operationType;if (Oe.log(''.concat(this._className, '.onGroupAttributesUpdated. hasChangedAttributeInfo:').concat(s, ' operationType:')
        .concat(c)), !qe(c)) {
        if (1 === s) {
          if (4 === c) {
            let u = [];i.forEach(((e) => {
              u.push(e.key);
            })), i = M(u), u = null;
          } return this._refreshCachedGroupAttributes({ groupID: n, remoteMainSequence: a, groupAttributeList: i, operationType: Ni[c] }), void this._emitGroupAttributesUpdated(n);
        } if (this._groupAttributesMap.has(n)) {
          const l = this._groupAttributesMap.get(n).avChatRoomKey;this._getGroupAttributes({ groupID: n, avChatRoomKey: l }).then((() => {
            t._emitGroupAttributesUpdated(n);
          }));
        }
      }
    } }, { key: 'initGroupAttributesCache', value(e) {
      const t = e.groupID; const n = e.avChatRoomKey;this._groupAttributesMap.set(t, { lastUpdateTime: 0, localMainSequence: 0, remoteMainSequence: 0, attributes: new Map, avChatRoomKey: n }), Oe.log(''.concat(this._className, '.initGroupAttributesCache groupID:').concat(t, ' avChatRoomKey:')
        .concat(n));
    } }, { key: 'initGroupAttributes', value(e) {
      const t = this; const n = e.groupID; const o = e.groupAttributes; const a = this._checkCachedGroupAttributes({ groupID: n, funcName: 'initGroupAttributes' });if (!0 !== a) return ai(a);const s = this._groupAttributesMap.get(n); const r = s.remoteMainSequence; const i = s.avChatRoomKey; const c = new Xa(Xs);return c.setMessage('groupID:'.concat(n, ' mainSequence:').concat(r, ' groupAttributes:')
        .concat(JSON.stringify(o))), this._groupModule.request({ protocolName: eo, requestData: { groupID: n, avChatRoomKey: i, mainSequence: r, groupAttributeList: this._transformGroupAttributes(o) } }).then(((e) => {
        const a = e.data; const s = a.mainSequence; const r = M(a.groupAttributeList);return r.forEach(((e) => {
          e.value = o[e.key];
        })), t._refreshCachedGroupAttributes({ groupID: n, remoteMainSequence: s, groupAttributeList: r, operationType: 'init' }), c.setNetworkType(t._groupModule.getNetworkType()).end(), Oe.log(''.concat(t._className, '.initGroupAttributes ok. groupID:').concat(n)), $r({ groupAttributes: o });
      }))
        .catch((e => (t._groupModule.probeNetwork().then(((t) => {
          const n = m(t, 2); const o = n[0]; const a = n[1];c.setError(e, o, a).end();
        })), ai(e))));
    } }, { key: 'setGroupAttributes', value(e) {
      const t = this; const n = e.groupID; const o = e.groupAttributes; const a = this._checkCachedGroupAttributes({ groupID: n, funcName: 'setGroupAttributes' });if (!0 !== a) return ai(a);const s = this._groupAttributesMap.get(n); const r = s.remoteMainSequence; const i = s.avChatRoomKey; const c = s.attributes; const u = this._transformGroupAttributes(o);u.forEach(((e) => {
        const t = e.key;e.sequence = 0, c.has(t) && (e.sequence = c.get(t).sequence);
      }));const l = new Xa(Qs);return l.setMessage('groupID:'.concat(n, ' mainSequence:').concat(r, ' groupAttributes:')
        .concat(JSON.stringify(o))), this._groupModule.request({ protocolName: to, requestData: { groupID: n, avChatRoomKey: i, mainSequence: r, groupAttributeList: u } }).then(((e) => {
        const a = e.data; const s = a.mainSequence; const r = M(a.groupAttributeList);return r.forEach(((e) => {
          e.value = o[e.key];
        })), t._refreshCachedGroupAttributes({ groupID: n, remoteMainSequence: s, groupAttributeList: r, operationType: 'modify' }), l.setNetworkType(t._groupModule.getNetworkType()).end(), Oe.log(''.concat(t._className, '.setGroupAttributes ok. groupID:').concat(n)), $r({ groupAttributes: o });
      }))
        .catch((e => (t._groupModule.probeNetwork().then(((t) => {
          const n = m(t, 2); const o = n[0]; const a = n[1];l.setError(e, o, a).end();
        })), ai(e))));
    } }, { key: 'deleteGroupAttributes', value(e) {
      const t = this; const n = e.groupID; const o = e.keyList; const a = void 0 === o ? [] : o; const s = this._checkCachedGroupAttributes({ groupID: n, funcName: 'deleteGroupAttributes' });if (!0 !== s) return ai(s);const r = this._groupAttributesMap.get(n); const i = r.remoteMainSequence; const c = r.avChatRoomKey; const u = r.attributes; let l = M(u.keys()); let d = oo; let p = 'clear'; const g = { groupID: n, avChatRoomKey: c, mainSequence: i };if (a.length > 0) {
        const h = [];l = [], d = no, p = 'delete', a.forEach(((e) => {
          let t = 0;u.has(e) && (t = u.get(e).sequence, l.push(e)), h.push({ key: e, sequence: t });
        })), g.groupAttributeList = h;
      } const _ = new Xa(Zs);return _.setMessage('groupID:'.concat(n, ' mainSequence:').concat(i, ' keyList:')
        .concat(a, ' protocolName:')
        .concat(d)), this._groupModule.request({ protocolName: d, requestData: g }).then(((e) => {
        const o = e.data.mainSequence;return t._refreshCachedGroupAttributes({ groupID: n, remoteMainSequence: o, groupAttributeList: a, operationType: p }), _.setNetworkType(t._groupModule.getNetworkType()).end(), Oe.log(''.concat(t._className, '.deleteGroupAttributes ok. groupID:').concat(n)), $r({ keyList: l });
      }))
        .catch((e => (t._groupModule.probeNetwork().then(((t) => {
          const n = m(t, 2); const o = n[0]; const a = n[1];_.setError(e, o, a).end();
        })), ai(e))));
    } }, { key: 'getGroupAttributes', value(e) {
      const t = this; const n = e.groupID; const o = this._checkCachedGroupAttributes({ groupID: n, funcName: 'getGroupAttributes' });if (!0 !== o) return ai(o);const a = this._groupAttributesMap.get(n); const s = a.avChatRoomKey; const r = a.lastUpdateTime; const i = a.localMainSequence; const c = a.remoteMainSequence; const u = new Xa(er);if (u.setMessage('groupID:'.concat(n, ' localMainSequence:').concat(i, ' remoteMainSequence:')
        .concat(c, ' keyList:')
        .concat(e.keyList)), Date.now() - r >= this.CACHE_EXPIRE_TIME || i < c) return this._getGroupAttributes({ groupID: n, avChatRoomKey: s }).then(((o) => {
        u.setMoreMessage('get attributes from remote. count:'.concat(o.length)).setNetworkType(t._groupModule.getNetworkType())
          .end(), Oe.log(''.concat(t._className, '.getGroupAttributes from remote. groupID:').concat(n));const a = t._getLocalGroupAttributes(e);return $r({ groupAttributes: a });
      }))
        .catch((e => (t._groupModule.probeNetwork().then(((t) => {
          const n = m(t, 2); const o = n[0]; const a = n[1];u.setError(e, o, a).end();
        })), ai(e))));u.setMoreMessage('get attributes from cache').setNetworkType(this._groupModule.getNetworkType())
        .end(), Oe.log(''.concat(this._className, '.getGroupAttributes from cache. groupID:').concat(n));const l = this._getLocalGroupAttributes(e);return oi({ groupAttributes: l });
    } }, { key: '_getGroupAttributes', value(e) {
      const t = this;return this._groupModule.request({ protocolName: ao, requestData: r({}, e) }).then(((n) => {
        const o = n.data; const a = o.mainSequence; const s = o.groupAttributeList; const r = M(s);return qe(a) || t._refreshCachedGroupAttributes({ groupID: e.groupID, remoteMainSequence: a, groupAttributeList: r, operationType: 'get' }), Oe.log(''.concat(t._className, '._getGroupAttributes ok. groupID:').concat(e.groupID)), s;
      }))
        .catch((e => ai(e)));
    } }, { key: '_getLocalGroupAttributes', value(e) {
      const t = e.groupID; const n = e.keyList; const o = void 0 === n ? [] : n; const a = {};if (!this._groupAttributesMap.has(t)) return a;const s = this._groupAttributesMap.get(t).attributes;if (o.length > 0)o.forEach(((e) => {
        s.has(e) && (a[e] = s.get(e).value);
      }));else {
        let r; const i = S(s.keys());try {
          for (i.s();!(r = i.n()).done;) {
            const c = r.value;a[c] = s.get(c).value;
          }
        } catch (u) {
          i.e(u);
        } finally {
          i.f();
        }
      } return a;
    } }, { key: '_refreshCachedGroupAttributes', value(e) {
      const t = e.groupID; const n = e.remoteMainSequence; const o = e.groupAttributeList; const a = e.operationType;if (this._groupAttributesMap.has(t)) {
        const s = this._groupAttributesMap.get(t); const r = s.localMainSequence;if ('get' === a || n - r == 1)s.remoteMainSequence = n, s.localMainSequence = n, s.lastUpdateTime = Date.now(), this._updateCachedAttributes({ groupAttributes: s, groupAttributeList: o, operationType: a });else {
          if (r === n) return;s.remoteMainSequence = n;
        } this._groupAttributesMap.set(t, s);const i = 'operationType:'.concat(a, ' localMainSequence:').concat(r, ' remoteMainSequence:')
          .concat(n);Oe.log(''.concat(this._className, '._refreshCachedGroupAttributes. ').concat(i));
      }
    } }, { key: '_updateCachedAttributes', value(e) {
      const t = e.groupAttributes; const n = e.groupAttributeList; const o = e.operationType;'clear' !== o ? 'delete' !== o ? ('init' === o && t.attributes.clear(), n.forEach(((e) => {
        const n = e.key; const o = e.value; const a = e.sequence;t.attributes.set(n, { value: o, sequence: a });
      }))) : n.forEach(((e) => {
        t.attributes.delete(e);
      })) : t.attributes.clear();
    } }, { key: '_checkCachedGroupAttributes', value(e) {
      const t = e.groupID; const n = e.funcName;if (this._groupModule.hasLocalGroup(t) && this._groupModule.getLocalGroupProfile(t).type !== k.GRP_AVCHATROOM) {
        return Oe.warn(''.concat(this._className, '._checkCachedGroupAttributes. ').concat('非直播群不能使用群属性 API')), new ei({ code: Do.CANNOT_USE_GRP_ATTR_NOT_AVCHATROOM, message: '非直播群不能使用群属性 API' });
      } const o = this._groupAttributesMap.get(t);if (qe(o)) {
        const a = '如果 groupID:'.concat(t, ' 是直播群，使用 ').concat(n, ' 前先使用 joinGroup 接口申请加入群组，详细请参考 https://web.sdk.qcloud.com/im/doc/zh-cn/SDK.html#joinGroup');return Oe.warn(''.concat(this._className, '._checkCachedGroupAttributes. ').concat(a)), new ei({ code: Do.CANNOT_USE_GRP_ATTR_AVCHATROOM_UNJOIN, message: a });
      } return !0;
    } }, { key: '_transformGroupAttributes', value(e) {
      const t = [];return Object.keys(e).forEach(((n) => {
        t.push({ key: n, value: e[n] });
      })), t;
    } }, { key: '_emitGroupAttributesUpdated', value(e) {
      const t = this._getLocalGroupAttributes({ groupID: e });this._groupModule.emitOuterEvent(D.GROUP_ATTRIBUTES_UPDATED, { groupID: e, groupAttributes: t });
    } }, { key: 'reset', value() {
      this._groupAttributesMap.clear(), this.CACHE_EXPIRE_TIME = 3e4;
    } }]), e;
  }()); const Ri = (function () {
    function e(n) {
      t(this, e);const o = n.manager; const a = n.groupID; const s = n.onInit; const r = n.onSuccess; const i = n.onFail;this._className = 'Polling', this._manager = o, this._groupModule = o._groupModule, this._onInit = s, this._onSuccess = r, this._onFail = i, this._groupID = a, this._timeoutID = -1, this._isRunning = !1, this._protocolName = Jn;
    } return o(e, [{ key: 'start', value() {
      const e = this._groupModule.isLoggedIn();e || (this._protocolName = Xn), Oe.log(''.concat(this._className, '.start pollingInterval:').concat(this._manager.getPollingInterval(), ' isLoggedIn:')
        .concat(e)), this._isRunning = !0, this._request();
    } }, { key: 'isRunning', value() {
      return this._isRunning;
    } }, { key: '_request', value() {
      const e = this; const t = this._onInit(this._groupID);this._groupModule.request({ protocolName: this._protocolName, requestData: t }).then(((t) => {
        e._onSuccess(e._groupID, t), e.isRunning() && (clearTimeout(e._timeoutID), e._timeoutID = setTimeout(e._request.bind(e), e._manager.getPollingInterval()));
      }))
        .catch(((t) => {
          e._onFail(e._groupID, t), e.isRunning() && (clearTimeout(e._timeoutID), e._timeoutID = setTimeout(e._request.bind(e), e._manager.MAX_POLLING_INTERVAL));
        }));
    } }, { key: 'stop', value() {
      Oe.log(''.concat(this._className, '.stop')), this._timeoutID > 0 && (clearTimeout(this._timeoutID), this._timeoutID = -1), this._isRunning = !1;
    } }]), e;
  }()); const Oi = { 3: !0, 4: !0, 5: !0, 6: !0 }; const Gi = (function () {
    function e(n) {
      t(this, e), this._groupModule = n, this._className = 'AVChatRoomHandler', this._joinedGroupMap = new Map, this._pollingRequestInfoMap = new Map, this._pollingInstanceMap = new Map, this.sequencesLinkedList = new vi(100), this.messageIDLinkedList = new vi(100), this.receivedMessageCount = 0, this._reportMessageStackedCount = 0, this._onlineMemberCountMap = new Map, this.DEFAULT_EXPIRE_TIME = 60, this.DEFAULT_POLLING_INTERVAL = 300, this.MAX_POLLING_INTERVAL = 2e3, this._pollingInterval = this.DEFAULT_POLLING_INTERVAL;
    } return o(e, [{ key: 'hasJoinedAVChatRoom', value() {
      return this._joinedGroupMap.size > 0;
    } }, { key: 'checkJoinedAVChatRoomByID', value(e) {
      return this._joinedGroupMap.has(e);
    } }, { key: 'getJoinedAVChatRoom', value() {
      return this._joinedGroupMap.size > 0 ? M(this._joinedGroupMap.keys()) : null;
    } }, { key: '_updateRequestData', value(e) {
      return r({}, this._pollingRequestInfoMap.get(e));
    } }, { key: '_handleSuccess', value(e, t) {
      const n = t.data; const o = n.key; const a = n.nextSeq; const s = n.rspMsgList;if (0 !== n.errorCode) {
        const r = this._pollingRequestInfoMap.get(e); const i = new Xa(lr); const c = r ? ''.concat(r.key, '-').concat(r.startSeq) : 'requestInfo is undefined';i.setMessage(''.concat(e, '-').concat(c, '-')
          .concat(t.errorInfo)).setCode(t.errorCode)
          .setNetworkType(this._groupModule.getNetworkType())
          .end(!0);
      } else {
        if (!this.checkJoinedAVChatRoomByID(e)) return;be(o) && we(a) && this._pollingRequestInfoMap.set(e, { key: o, startSeq: a }), Fe(s) && s.length > 0 && (s.forEach(((e) => {
          e.to = e.groupID;
        })), this.onMessage(s));
      }
    } }, { key: '_handleFailure', value(e, t) {} }, { key: 'onMessage', value(e) {
      if (Fe(e) && 0 !== e.length) {
        let t = null; const n = []; const o = this._getModule(xt); const a = e.length;a > 1 && e.sort(((e, t) => e.sequence - t.sequence));for (let s = this._getModule(Bt), r = 0;r < a;r++) if (Oi[e[r].event]) {
          this.receivedMessageCount += 1, t = this.packMessage(e[r], e[r].event);const i = 1 === e[r].isModified; const c = 1 === e[r].isHistoryMessage;if ((s.isUnlimitedAVChatRoom() || !this.sequencesLinkedList.has(t.sequence)) && !this.messageIDLinkedList.has(t.ID)) {
            const u = t.conversationID;if (this.receivedMessageCount % 40 == 0 && this._getModule(Zt).detectMessageLoss(u, this.sequencesLinkedList.data()), null !== this.sequencesLinkedList.tail()) {
              const l = this.sequencesLinkedList.tail().value; const d = t.sequence - l;d > 1 && d <= 20 ? this._getModule(Zt).onMessageMaybeLost(u, l + 1, d - 1) : d < -1 && d >= -20 && this._getModule(Zt).onMessageMaybeLost(u, t.sequence + 1, Math.abs(d) - 1);
            } this.sequencesLinkedList.set(t.sequence), this.messageIDLinkedList.set(t.ID);let p = !1;if (this._isMessageSentByCurrentInstance(t) ? i && (p = !0, t.isModified = i, o.updateMessageIsModifiedProperty(t)) : p = !0, p) {
              if (t.conversationType, k.CONV_SYSTEM, !c && t.conversationType !== k.CONV_SYSTEM) {
                const g = this._getModule(on); const h = t.conversationID.replace(k.CONV_GROUP, '');this._pollingInstanceMap.has(h) ? g.addMessageSequence({ key: Wa, message: t }) : (t.type !== k.MSG_GRP_TIP && g.addMessageDelay({ currentTime: Date.now(), time: t.time }), g.addMessageSequence({ key: ja, message: t }));
              }n.push(t);
            }
          }
        } else Oe.warn(''.concat(this._className, '.onMessage 未处理的 event 类型: ').concat(e[r].event));if (0 !== n.length) {
          this._groupModule.filterModifiedMessage(n);const _ = this.packConversationOption(n);if (_.length > 0) this._getModule(xt).onNewMessage({ conversationOptionsList: _, isInstantMessage: !0 });Oe.debug(''.concat(this._className, '.onMessage count:').concat(n.length)), this._checkMessageStacked(n);const f = this._groupModule.filterUnmodifiedMessage(n);f.length > 0 && this._groupModule.emitOuterEvent(D.MESSAGE_RECEIVED, f), n.length = 0;
        }
      }
    } }, { key: '_checkMessageStacked', value(e) {
      const t = e.length;t >= 100 && (Oe.warn(''.concat(this._className, '._checkMessageStacked 直播群消息堆积数:').concat(e.length, '！可能会导致微信小程序渲染时遇到 "Dom limit exceeded" 的错误，建议接入侧此时只渲染最近的10条消息')), this._reportMessageStackedCount < 5 && (new Xa(pr).setNetworkType(this._groupModule.getNetworkType())
        .setMessage('count:'.concat(t, ' groupID:').concat(M(this._joinedGroupMap.keys())))
        .setLevel('warning')
        .end(), this._reportMessageStackedCount += 1));
    } }, { key: '_isMessageSentByCurrentInstance', value(e) {
      return !!this._getModule(xt).isMessageSentByCurrentInstance(e);
    } }, { key: 'packMessage', value(e, t) {
      e.currentUser = this._groupModule.getMyUserID(), e.conversationType = 5 === t ? k.CONV_SYSTEM : k.CONV_GROUP, e.isSystemMessage = !!e.isSystemMessage;const n = new Yr(e); const o = this.packElements(e, t);return n.setElement(o), n;
    } }, { key: 'packElements', value(e, t) {
      return 4 === t || 6 === t ? (this._updateMemberCountByGroupTips(e), this._onGroupAttributesUpdated(e), { type: k.MSG_GRP_TIP, content: r(r({}, e.elements), {}, { groupProfile: e.groupProfile }) }) : 5 === t ? { type: k.MSG_GRP_SYS_NOTICE, content: r(r({}, e.elements), {}, { groupProfile: e.groupProfile }) } : this._getModule(Yt).parseElements(e.elements, e.from);
    } }, { key: 'packConversationOption', value(e) {
      for (var t = new Map, n = 0;n < e.length;n++) {
        const o = e[n]; const a = o.conversationID;if (t.has(a)) {
          const s = t.get(a);s.lastMessage = o, 'in' === o.flow && s.unreadCount++;
        } else t.set(a, { conversationID: o.conversationID, unreadCount: 'out' === o.flow ? 0 : 1, type: o.conversationType, subType: o.conversationSubType, lastMessage: o });
      } return M(t.values());
    } }, { key: '_updateMemberCountByGroupTips', value(e) {
      const t = e.groupProfile.groupID; const n = e.elements.onlineMemberInfo; const o = void 0 === n ? void 0 : n;if (!It(o)) {
        const a = o.onlineMemberNum; const s = void 0 === a ? 0 : a; const r = o.expireTime; const i = void 0 === r ? this.DEFAULT_EXPIRE_TIME : r; const c = this._onlineMemberCountMap.get(t) || {}; const u = Date.now();It(c) ? Object.assign(c, { lastReqTime: 0, lastSyncTime: 0, latestUpdateTime: u, memberCount: s, expireTime: i }) : (c.latestUpdateTime = u, c.memberCount = s), Oe.debug(''.concat(this._className, '._updateMemberCountByGroupTips info:'), c), this._onlineMemberCountMap.set(t, c);
      }
    } }, { key: 'start', value(e) {
      if (this._pollingInstanceMap.has(e)) {
        const t = this._pollingInstanceMap.get(e);t.isRunning() || t.start();
      } else {
        const n = new Ri({ manager: this, groupID: e, onInit: this._updateRequestData.bind(this), onSuccess: this._handleSuccess.bind(this), onFail: this._handleFailure.bind(this) });n.start(), this._pollingInstanceMap.set(e, n), Oe.log(''.concat(this._className, '.start groupID:').concat(e));
      }
    } }, { key: 'handleJoinResult', value(e) {
      const t = this;return this._preCheck().then((() => {
        const n = e.longPollingKey; const o = e.group; const a = o.groupID;return t._joinedGroupMap.set(a, o), t._groupModule.updateGroupMap([o]), t._groupModule.deleteUnjoinedAVChatRoom(a), t._groupModule.emitGroupListUpdate(!0, !1), qe(n) ? oi({ status: Rr, group: o }) : Promise.resolve();
      }));
    } }, { key: 'startRunLoop', value(e) {
      const t = this;return this.handleJoinResult(e).then((() => {
        const n = e.longPollingKey; const o = e.group; const a = o.groupID;return t._pollingRequestInfoMap.set(a, { key: n, startSeq: 0 }), t.start(a), t._groupModule.isLoggedIn() ? oi({ status: Rr, group: o }) : oi({ status: Rr });
      }));
    } }, { key: '_preCheck', value() {
      if (this._getModule(Bt).isUnlimitedAVChatRoom()) return Promise.resolve();if (!this.hasJoinedAVChatRoom()) return Promise.resolve();const e = m(this._joinedGroupMap.entries().next().value, 2); const t = e[0]; const n = e[1];if (this._groupModule.isLoggedIn()) {
        if (!(n.selfInfo.role === k.GRP_MBR_ROLE_OWNER || n.ownerID === this._groupModule.getMyUserID())) return this._groupModule.quitGroup(t);this._groupModule.deleteLocalGroupAndConversation(t);
      } else this._groupModule.deleteLocalGroupAndConversation(t);return this.reset(t), Promise.resolve();
    } }, { key: 'joinWithoutAuth', value(e) {
      const t = this; const n = e.groupID; const o = ''.concat(this._className, '.joinWithoutAuth'); const a = new Xa(Js);return this._groupModule.request({ protocolName: Fn, requestData: e }).then(((e) => {
        const s = e.data.longPollingKey;if (t._groupModule.probeNetwork().then(((e) => {
          const t = m(e, 2); const o = (t[0], t[1]);a.setNetworkType(o).setMessage('groupID:'.concat(n, ' longPollingKey:').concat(s))
            .end(!0);
        })), qe(s)) return ai(new ei({ code: Do.CANNOT_JOIN_NON_AVCHATROOM_WITHOUT_LOGIN, message: fa }));Oe.log(''.concat(o, ' ok. groupID:').concat(n)), t._getModule(xt).setCompleted(''.concat(k.CONV_GROUP).concat(n));const r = new Ii({ groupID: n });return t.startRunLoop({ group: r, longPollingKey: s }), $r({ status: Rr });
      }))
        .catch((e => (Oe.error(''.concat(o, ' failed. groupID:').concat(n, ' error:'), e), t._groupModule.probeNetwork().then(((t) => {
          const o = m(t, 2); const s = o[0]; const r = o[1];a.setError(e, s, r).setMessage('groupID:'.concat(n))
            .end(!0);
        })), ai(e))))
        .finally((() => {
          t._groupModule.getModule(jt).reportAtOnce();
        }));
    } }, { key: 'getGroupOnlineMemberCount', value(e) {
      const t = this._onlineMemberCountMap.get(e) || {}; const n = Date.now();return It(t) || n - t.lastSyncTime > 1e3 * t.expireTime && n - t.latestUpdateTime > 1e4 && n - t.lastReqTime > 3e3 ? (t.lastReqTime = n, this._onlineMemberCountMap.set(e, t), this._getGroupOnlineMemberCount(e).then((e => $r({ memberCount: e.memberCount })))
        .catch((e => ai(e)))) : oi({ memberCount: t.memberCount });
    } }, { key: '_getGroupOnlineMemberCount', value(e) {
      const t = this; const n = ''.concat(this._className, '._getGroupOnlineMemberCount');return this._groupModule.request({ protocolName: Qn, requestData: { groupID: e } }).then(((o) => {
        const a = t._onlineMemberCountMap.get(e) || {}; const s = o.data; const r = s.onlineMemberNum; const i = void 0 === r ? 0 : r; const c = s.expireTime; const u = void 0 === c ? t.DEFAULT_EXPIRE_TIME : c;Oe.log(''.concat(n, ' ok. groupID:').concat(e, ' memberCount:')
          .concat(i, ' expireTime:')
          .concat(u));const l = Date.now();return It(a) && (a.lastReqTime = l), t._onlineMemberCountMap.set(e, Object.assign(a, { lastSyncTime: l, latestUpdateTime: l, memberCount: i, expireTime: u })), { memberCount: i };
      }))
        .catch((o => (Oe.warn(''.concat(n, ' failed. error:'), o), new Xa(ur).setCode(o.code)
          .setMessage('groupID:'.concat(e, ' error:').concat(JSON.stringify(o)))
          .setNetworkType(t._groupModule.getNetworkType())
          .end(), Promise.reject(o))));
    } }, { key: '_onGroupAttributesUpdated', value(e) {
      const t = e.groupProfile.groupID; const n = e.elements; const o = n.operationType; const a = n.newGroupProfile;if (6 === o) {
        const s = (void 0 === a ? void 0 : a).groupAttributeOption;It(s) || this._groupModule.onGroupAttributesUpdated({ groupID: t, groupAttributeOption: s });
      }
    } }, { key: '_getModule', value(e) {
      return this._groupModule.getModule(e);
    } }, { key: 'setPollingInterval', value(e) {
      qe(e) || we(e) || (this._pollingInterval = parseInt(e, 10), Oe.log(''.concat(this._className, '.setPollingInterval value:').concat(this._pollingInterval)));
    } }, { key: 'getPollingInterval', value() {
      return this._pollingInterval;
    } }, { key: 'reset', value(e) {
      if (e) {
        Oe.log(''.concat(this._className, '.reset groupID:').concat(e));const t = this._pollingInstanceMap.get(e);t && t.stop(), this._pollingInstanceMap.delete(e), this._joinedGroupMap.delete(e), this._pollingRequestInfoMap.delete(e), this._onlineMemberCountMap.delete(e);
      } else {
        Oe.log(''.concat(this._className, '.reset all'));let n; const o = S(this._pollingInstanceMap.values());try {
          for (o.s();!(n = o.n()).done;) {
            n.value.stop();
          }
        } catch (a) {
          o.e(a);
        } finally {
          o.f();
        } this._pollingInstanceMap.clear(), this._joinedGroupMap.clear(), this._pollingRequestInfoMap.clear(), this._onlineMemberCountMap.clear();
      } this.sequencesLinkedList.reset(), this.messageIDLinkedList.reset(), this.receivedMessageCount = 0, this._reportMessageStackedCount = 0, this._pollingInterval = this.DEFAULT_POLLING_INTERVAL;
    } }]), e;
  }()); const wi = 1; const bi = 15; const Pi = (function () {
    function e(n) {
      t(this, e), this._groupModule = n, this._className = 'GroupSystemNoticeHandler', this.pendencyMap = new Map;
    } return o(e, [{ key: 'onNewGroupSystemNotice', value(e) {
      const t = e.dataList; const n = e.isSyncingEnded; const o = e.isInstantMessage;Oe.debug(''.concat(this._className, '.onReceiveSystemNotice count:').concat(t.length));const a = this.newSystemNoticeStoredAndSummary({ notifiesList: t, isInstantMessage: o }); const s = a.eventDataList; const r = a.result;s.length > 0 && (this._groupModule.getModule(xt).onNewMessage({ conversationOptionsList: s, isInstantMessage: o }), this._onReceivedGroupSystemNotice({ result: r, isInstantMessage: o }));o ? r.length > 0 && this._groupModule.emitOuterEvent(D.MESSAGE_RECEIVED, r) : !0 === n && this._clearGroupSystemNotice();
    } }, { key: 'newSystemNoticeStoredAndSummary', value(e) {
      const t = e.notifiesList; const n = e.isInstantMessage; let o = null; const a = t.length; let s = 0; const i = []; const c = { conversationID: k.CONV_SYSTEM, unreadCount: 0, type: k.CONV_SYSTEM, subType: null, lastMessage: null };for (s = 0;s < a;s++) {
        const u = t[s];if (u.elements.operationType !== bi)u.currentUser = this._groupModule.getMyUserID(), u.conversationType = k.CONV_SYSTEM, u.conversationID = k.CONV_SYSTEM, (o = new Yr(u)).setElement({ type: k.MSG_GRP_SYS_NOTICE, content: r(r({}, u.elements), {}, { groupProfile: u.groupProfile }) }), o.isSystemMessage = !0, (1 === o.sequence && 1 === o.random || 2 === o.sequence && 2 === o.random) && (o.sequence = Je(), o.random = Je(), o.generateMessageID(u.currentUser), Oe.log(''.concat(this._className, '.newSystemNoticeStoredAndSummary sequence and random maybe duplicated, regenerate. ID:').concat(o.ID))), this._groupModule.getModule(xt).pushIntoNoticeResult(i, o) && (n ? c.unreadCount++ : o.setIsRead(!0), c.subType = o.conversationSubType);
      } return c.lastMessage = i[i.length - 1], { eventDataList: i.length > 0 ? [c] : [], result: i };
    } }, { key: '_clearGroupSystemNotice', value() {
      const e = this;this.getPendencyList().then(((t) => {
        t.forEach(((t) => {
          e.pendencyMap.set(''.concat(t.from, '_').concat(t.groupID, '_')
            .concat(t.to), t);
        }));const n = e._groupModule.getModule(xt).getLocalMessageList(k.CONV_SYSTEM); const o = [];n.forEach(((t) => {
          const n = t.payload; const a = n.operatorID; const s = n.operationType; const r = n.groupProfile;if (s === wi) {
            const i = ''.concat(a, '_').concat(r.groupID, '_')
              .concat(r.to); const c = e.pendencyMap.get(i);c && we(c.handled) && 0 !== c.handled && o.push(t);
          }
        })), e.deleteGroupSystemNotice({ messageList: o });
      }));
    } }, { key: 'deleteGroupSystemNotice', value(e) {
      const t = this; const n = ''.concat(this._className, '.deleteGroupSystemNotice');return Fe(e.messageList) && 0 !== e.messageList.length ? (Oe.log(''.concat(n) + e.messageList.map((e => e.ID))), this._groupModule.request({ protocolName: zn, requestData: { messageListToDelete: e.messageList.map((e => ({ from: k.CONV_SYSTEM, messageSeq: e.clientSequence, messageRandom: e.random }))) } }).then((() => {
        Oe.log(''.concat(n, ' ok'));const o = t._groupModule.getModule(xt);return e.messageList.forEach(((e) => {
          o.deleteLocalMessage(e);
        })), $r();
      }))
        .catch((e => (Oe.error(''.concat(n, ' error:'), e), ai(e))))) : oi();
    } }, { key: 'getPendencyList', value(e) {
      const t = this;return this._groupModule.request({ protocolName: $n, requestData: { startTime: e && e.startTime ? e.startTime : 0, limit: e && e.limit ? e.limit : 10, handleAccount: this._groupModule.getMyUserID() } }).then(((e) => {
        const n = e.data.pendencyList;return 0 !== e.data.nextStartTime ? t.getPendencyList({ startTime: e.data.nextStartTime }).then((e => [].concat(M(n), M(e)))) : n;
      }));
    } }, { key: '_onReceivedGroupSystemNotice', value(e) {
      const t = this; const n = e.result;e.isInstantMessage && n.forEach(((e) => {
        switch (e.payload.operationType) {
          case 1:break;case 2:t._onApplyGroupRequestAgreed(e);break;case 3:break;case 4:t._onMemberKicked(e);break;case 5:t._onGroupDismissed(e);break;case 6:break;case 7:t._onInviteGroup(e);break;case 8:t._onQuitGroup(e);break;case 9:t._onSetManager(e);break;case 10:t._onDeleteManager(e);
        }
      }));
    } }, { key: '_onApplyGroupRequestAgreed', value(e) {
      const t = this; const n = e.payload.groupProfile.groupID;this._groupModule.hasLocalGroup(n) || this._groupModule.getGroupProfile({ groupID: n }).then(((e) => {
        const n = e.data.group;n && (t._groupModule.updateGroupMap([n]), t._groupModule.emitGroupListUpdate());
      }));
    } }, { key: '_onMemberKicked', value(e) {
      const t = e.payload.groupProfile.groupID;this._groupModule.hasLocalGroup(t) && this._groupModule.deleteLocalGroupAndConversation(t);
    } }, { key: '_onGroupDismissed', value(e) {
      const t = e.payload.groupProfile.groupID;this._groupModule.hasLocalGroup(t) && this._groupModule.deleteLocalGroupAndConversation(t);const n = this._groupModule._AVChatRoomHandler;n && n.checkJoinedAVChatRoomByID(t) && n.reset(t);
    } }, { key: '_onInviteGroup', value(e) {
      const t = this; const n = e.payload.groupProfile.groupID;this._groupModule.hasLocalGroup(n) || this._groupModule.getGroupProfile({ groupID: n }).then(((e) => {
        const n = e.data.group;n && (t._groupModule.updateGroupMap([n]), t._groupModule.emitGroupListUpdate());
      }));
    } }, { key: '_onQuitGroup', value(e) {
      const t = e.payload.groupProfile.groupID;this._groupModule.hasLocalGroup(t) && this._groupModule.deleteLocalGroupAndConversation(t);
    } }, { key: '_onSetManager', value(e) {
      const t = e.payload.groupProfile; const n = t.to; const o = t.groupID; const a = this._groupModule.getModule(Kt).getLocalGroupMemberInfo(o, n);a && a.updateRole(k.GRP_MBR_ROLE_ADMIN);
    } }, { key: '_onDeleteManager', value(e) {
      const t = e.payload.groupProfile; const n = t.to; const o = t.groupID; const a = this._groupModule.getModule(Kt).getLocalGroupMemberInfo(o, n);a && a.updateRole(k.GRP_MBR_ROLE_MEMBER);
    } }, { key: 'reset', value() {
      this.pendencyMap.clear();
    } }]), e;
  }()); const Ui = (function (e) {
    i(a, e);const n = f(a);function a(e) {
      let o;return t(this, a), (o = n.call(this, e))._className = 'GroupModule', o._commonGroupHandler = null, o._AVChatRoomHandler = null, o._groupSystemNoticeHandler = null, o._commonGroupHandler = new Ai(h(o)), o._groupAttributesHandler = new Li(h(o)), o._AVChatRoomHandler = new Gi(h(o)), o._groupTipsHandler = new Ei(h(o)), o._groupSystemNoticeHandler = new Pi(h(o)), o.groupMap = new Map, o._unjoinedAVChatRoomList = new Map, o.getInnerEmitterInstance().on(ci, o._onCloudConfigUpdated, h(o)), o;
    } return o(a, [{ key: '_onCloudConfigUpdated', value() {
      const e = this.getCloudConfig('polling_interval');this._AVChatRoomHandler && this._AVChatRoomHandler.setPollingInterval(e);
    } }, { key: 'onCheckTimer', value(e) {
      this.isLoggedIn() && (this._commonGroupHandler.onCheckTimer(e), this._groupTipsHandler.onCheckTimer(e));
    } }, { key: 'guardForAVChatRoom', value(e) {
      const t = this;if (e.conversationType === k.CONV_GROUP) {
        const n = e.to;return this.hasLocalGroup(n) ? oi() : this.getGroupProfile({ groupID: n }).then(((o) => {
          const a = o.data.group.type;if (Oe.log(''.concat(t._className, '.guardForAVChatRoom. groupID:').concat(n, ' type:')
            .concat(a)), a === k.GRP_AVCHATROOM) {
            const s = 'userId:'.concat(e.from, ' 未加入群 groupID:').concat(n, '。发消息前先使用 joinGroup 接口申请加群，详细请参考 https://web.sdk.qcloud.com/im/doc/zh-cn/SDK.html#joinGroup');return Oe.warn(''.concat(t._className, '.guardForAVChatRoom sendMessage not allowed. ').concat(s)), ai(new ei({ code: Do.MESSAGE_SEND_FAIL, message: s, data: { message: e } }));
          } return oi();
        }));
      } return oi();
    } }, { key: 'checkJoinedAVChatRoomByID', value(e) {
      return !!this._AVChatRoomHandler && this._AVChatRoomHandler.checkJoinedAVChatRoomByID(e);
    } }, { key: 'onNewGroupMessage', value(e) {
      this._commonGroupHandler && this._commonGroupHandler.onNewGroupMessage(e);
    } }, { key: 'updateNextMessageSeq', value(e) {
      const t = this;Fe(e) && e.forEach(((e) => {
        const n = e.conversationID.replace(k.CONV_GROUP, '');t.groupMap.has(n) && (t.groupMap.get(n).nextMessageSeq = e.lastMessage.sequence + 1);
      }));
    } }, { key: 'onNewGroupTips', value(e) {
      this._groupTipsHandler && this._groupTipsHandler.onNewGroupTips(e);
    } }, { key: 'onGroupMessageRevoked', value(e) {
      this._commonGroupHandler && this._commonGroupHandler.onGroupMessageRevoked(e);
    } }, { key: 'onNewGroupSystemNotice', value(e) {
      this._groupSystemNoticeHandler && this._groupSystemNoticeHandler.onNewGroupSystemNotice(e);
    } }, { key: 'onGroupMessageReadNotice', value(e) {
      const t = this;e.dataList.forEach(((e) => {
        const n = e.elements.groupMessageReadNotice;if (!qe(n)) {
          const o = t.getModule(xt);n.forEach(((e) => {
            const n = e.groupID; const a = e.lastMessageSeq;Oe.debug(''.concat(t._className, '.onGroupMessageReadNotice groupID:').concat(n, ' lastMessageSeq:')
              .concat(a));const s = ''.concat(k.CONV_GROUP).concat(n);o.updateIsReadAfterReadReport({ conversationID: s, lastMessageSeq: a }), o.updateUnreadCount(s);
          }));
        }
      }));
    } }, { key: 'deleteGroupSystemNotice', value(e) {
      this._groupSystemNoticeHandler && this._groupSystemNoticeHandler.deleteGroupSystemNotice(e);
    } }, { key: 'initGroupMap', value(e) {
      this.groupMap.set(e.groupID, new Ii(e));
    } }, { key: 'deleteGroup', value(e) {
      this.groupMap.delete(e);
    } }, { key: 'updateGroupMap', value(e) {
      const t = this;e.forEach(((e) => {
        t.groupMap.has(e.groupID) ? t.groupMap.get(e.groupID).updateGroup(e) : t.groupMap.set(e.groupID, new Ii(e));
      }));let n; const o = this.getMyUserID(); const a = S(this.groupMap);try {
        for (a.s();!(n = a.n()).done;) {
          m(n.value, 2)[1].selfInfo.userID = o;
        }
      } catch (s) {
        a.e(s);
      } finally {
        a.f();
      } this._setStorageGroupList();
    } }, { key: 'getStorageGroupList', value() {
      return this.getModule(Ht).getItem('groupMap');
    } }, { key: '_setStorageGroupList', value() {
      const e = this.getLocalGroupList().filter(((e) => {
        const t = e.type;return !it(t);
      }))
        .slice(0, 20)
        .map((e => ({ groupID: e.groupID, name: e.name, avatar: e.avatar, type: e.type })));this.getModule(Ht).setItem('groupMap', e);
    } }, { key: 'getGroupMap', value() {
      return this.groupMap;
    } }, { key: 'getLocalGroupList', value() {
      return M(this.groupMap.values());
    } }, { key: 'getLocalGroupProfile', value(e) {
      return this.groupMap.get(e);
    } }, { key: 'sortLocalGroupList', value() {
      const e = M(this.groupMap).filter(((e) => {
        const t = m(e, 2);t[0];return !It(t[1].lastMessage);
      }));e.sort(((e, t) => t[1].lastMessage.lastTime - e[1].lastMessage.lastTime)), this.groupMap = new Map(M(e));
    } }, { key: 'updateGroupLastMessage', value(e) {
      this._commonGroupHandler && this._commonGroupHandler.handleUpdateGroupLastMessage(e);
    } }, { key: 'emitGroupListUpdate', value() {
      const e = !(arguments.length > 0 && void 0 !== arguments[0]) || arguments[0]; const t = !(arguments.length > 1 && void 0 !== arguments[1]) || arguments[1]; const n = this.getLocalGroupList();if (e && this.emitOuterEvent(D.GROUP_LIST_UPDATED, n), t) {
        const o = JSON.parse(JSON.stringify(n)); const a = this.getModule(xt);a.updateConversationGroupProfile(o);
      }
    } }, { key: 'patchGroupMessageRemindType', value() {
      const e = this.getLocalGroupList(); const t = this.getModule(xt); let n = 0;e.forEach(((e) => {
        !0 === t.patchMessageRemindType({ ID: e.groupID, isC2CConversation: !1, messageRemindType: e.selfInfo.messageRemindType }) && (n += 1);
      })), Oe.log(''.concat(this._className, '.patchGroupMessageRemindType count:').concat(n));
    } }, { key: 'recomputeUnreadCount', value() {
      const e = this.getLocalGroupList(); const t = this.getModule(xt);e.forEach(((e) => {
        const n = e.groupID; const o = e.selfInfo; const a = o.excludedUnreadSequenceList; const s = o.readedSequence;if (Fe(a)) {
          let r = 0;a.forEach(((t) => {
            t >= s && t <= e.nextMessageSeq - 1 && (r += 1);
          })), r >= 1 && t.recomputeGroupUnreadCount({ conversationID: ''.concat(k.CONV_GROUP).concat(n), count: r });
        }
      }));
    } }, { key: 'getMyNameCardByGroupID', value(e) {
      const t = this.getLocalGroupProfile(e);return t ? t.selfInfo.nameCard : '';
    } }, { key: 'getGroupList', value(e) {
      return this._commonGroupHandler ? this._commonGroupHandler.getGroupList(e) : oi();
    } }, { key: 'getGroupProfile', value(e) {
      const t = this; const n = new Xa(Hs); const o = ''.concat(this._className, '.getGroupProfile'); const a = e.groupID; const s = e.groupCustomFieldFilter;Oe.log(''.concat(o, ' groupID:').concat(a));const r = { groupIDList: [a], responseFilter: { groupBaseInfoFilter: ['Type', 'Name', 'Introduction', 'Notification', 'FaceUrl', 'Owner_Account', 'CreateTime', 'InfoSeq', 'LastInfoTime', 'LastMsgTime', 'MemberNum', 'MaxMemberNum', 'ApplyJoinOption', 'NextMsgSeq', 'ShutUpAllMember'], groupCustomFieldFilter: s, memberInfoFilter: ['Role', 'JoinTime', 'MsgSeq', 'MsgFlag', 'NameCard'] } };return this.getGroupProfileAdvance(r).then(((e) => {
        let s; const r = e.data; const i = r.successGroupList; const c = r.failureGroupList;return Oe.log(''.concat(o, ' ok')), c.length > 0 ? ai(c[0]) : (it(i[0].type) && !t.hasLocalGroup(a) ? s = new Ii(i[0]) : (t.updateGroupMap(i), s = t.getLocalGroupProfile(a)), n.setNetworkType(t.getNetworkType()).setMessage('groupID:'.concat(a, ' type:').concat(s.type, ' muteAllMembers:')
          .concat(s.muteAllMembers, ' ownerID:')
          .concat(s.ownerID))
          .end(), $r({ group: s }));
      }))
        .catch((a => (t.probeNetwork().then(((t) => {
          const o = m(t, 2); const s = o[0]; const r = o[1];n.setError(a, s, r).setMessage('groupID:'.concat(e.groupID))
            .end();
        })), Oe.error(''.concat(o, ' failed. error:'), a), ai(a))));
    } }, { key: 'getGroupProfileAdvance', value(e) {
      const t = ''.concat(this._className, '.getGroupProfileAdvance');return Fe(e.groupIDList) && e.groupIDList.length > 50 && (Oe.warn(''.concat(t, ' 获取群资料的数量不能超过50个')), e.groupIDList.length = 50), Oe.log(''.concat(t, ' groupIDList:').concat(e.groupIDList)), this.request({ protocolName: Gn, requestData: e }).then(((e) => {
        Oe.log(''.concat(t, ' ok'));const n = e.data.groups; const o = n.filter((e => qe(e.errorCode) || 0 === e.errorCode)); const a = n.filter((e => e.errorCode && 0 !== e.errorCode)).map((e => new ei({ code: e.errorCode, message: e.errorInfo, data: { groupID: e.groupID } })));return $r({ successGroupList: o, failureGroupList: a });
      }))
        .catch((e => (Oe.error(''.concat(t, ' failed. error:'), e), ai(e))));
    } }, { key: 'createGroup', value(e) {
      const t = this; const n = ''.concat(this._className, '.createGroup');if (!['Public', 'Private', 'ChatRoom', 'AVChatRoom'].includes(e.type)) {
        const o = new ei({ code: Do.ILLEGAL_GROUP_TYPE, message: ca });return ai(o);
      }it(e.type) && !qe(e.memberList) && e.memberList.length > 0 && (Oe.warn(''.concat(n, ' 创建 AVChatRoom 时不能添加群成员，自动忽略该字段')), e.memberList = void 0), rt(e.type) || qe(e.joinOption) || (Oe.warn(''.concat(n, ' 创建 Work/Meeting/AVChatRoom 群时不能设置字段 joinOption，自动忽略该字段')), e.joinOption = void 0);const a = new Xa(Gs);Oe.log(''.concat(n, ' options:'), e);let s = [];return this.request({ protocolName: wn, requestData: r(r({}, e), {}, { ownerID: this.getMyUserID(), webPushFlag: 1 }) }).then(((o) => {
        const i = o.data; const c = i.groupID; const u = i.overLimitUserIDList; const l = void 0 === u ? [] : u;if (s = l, a.setNetworkType(t.getNetworkType()).setMessage('groupType:'.concat(e.type, ' groupID:').concat(c, ' overLimitUserIDList=')
          .concat(l))
          .end(), Oe.log(''.concat(n, ' ok groupID:').concat(c, ' overLimitUserIDList:'), l), e.type === k.GRP_AVCHATROOM) return t.getGroupProfile({ groupID: c });It(e.memberList) || It(l) || (e.memberList = e.memberList.filter((e => -1 === l.indexOf(e.userID)))), t.updateGroupMap([r(r({}, e), {}, { groupID: c })]);const d = t.getModule(Pt); const p = d.createCustomMessage({ to: c, conversationType: k.CONV_GROUP, payload: { data: 'group_create', extension: ''.concat(t.getMyUserID(), '创建群组') } });return d.sendMessageInstance(p), t.emitGroupListUpdate(), t.getGroupProfile({ groupID: c });
      }))
        .then(((e) => {
          const t = e.data.group; const n = t.selfInfo; const o = n.nameCard; const a = n.joinTime;return t.updateSelfInfo({ nameCard: o, joinTime: a, messageRemindType: k.MSG_REMIND_ACPT_AND_NOTE, role: k.GRP_MBR_ROLE_OWNER }), $r({ group: t, overLimitUserIDList: s });
        }))
        .catch((o => (a.setMessage('groupType:'.concat(e.type)), t.probeNetwork().then(((e) => {
          const t = m(e, 2); const n = t[0]; const s = t[1];a.setError(o, n, s).end();
        })), Oe.error(''.concat(n, ' failed. error:'), o), ai(o))));
    } }, { key: 'dismissGroup', value(e) {
      const t = this; const n = ''.concat(this._className, '.dismissGroup');if (this.hasLocalGroup(e) && this.getLocalGroupProfile(e).type === k.GRP_WORK) return ai(new ei({ code: Do.CANNOT_DISMISS_WORK, message: pa }));const o = new Xa(Ks);return o.setMessage('groupID:'.concat(e)), Oe.log(''.concat(n, ' groupID:').concat(e)), this.request({ protocolName: bn, requestData: { groupID: e } }).then((() => (o.setNetworkType(t.getNetworkType()).end(), Oe.log(''.concat(n, ' ok')), t.deleteLocalGroupAndConversation(e), t.checkJoinedAVChatRoomByID(e) && t._AVChatRoomHandler.reset(e), $r({ groupID: e }))))
        .catch((e => (t.probeNetwork().then(((t) => {
          const n = m(t, 2); const a = n[0]; const s = n[1];o.setError(e, a, s).end();
        })), Oe.error(''.concat(n, ' failed. error:'), e), ai(e))));
    } }, { key: 'updateGroupProfile', value(e) {
      const t = this; const n = ''.concat(this._className, '.updateGroupProfile');!this.hasLocalGroup(e.groupID) || rt(this.getLocalGroupProfile(e.groupID).type) || qe(e.joinOption) || (Oe.warn(''.concat(n, ' Work/Meeting/AVChatRoom 群不能设置字段 joinOption，自动忽略该字段')), e.joinOption = void 0), qe(e.muteAllMembers) || (e.muteAllMembers ? e.muteAllMembers = 'On' : e.muteAllMembers = 'Off');const o = new Xa(xs);return o.setMessage(JSON.stringify(e)), Oe.log(''.concat(n, ' groupID:').concat(e.groupID)), this.request({ protocolName: Pn, requestData: e }).then((() => {
        (o.setNetworkType(t.getNetworkType()).end(), Oe.log(''.concat(n, ' ok')), t.hasLocalGroup(e.groupID)) && (t.groupMap.get(e.groupID).updateGroup(e), t._setStorageGroupList());return $r({ group: t.groupMap.get(e.groupID) });
      }))
        .catch((e => (t.probeNetwork().then(((t) => {
          const n = m(t, 2); const a = n[0]; const s = n[1];o.setError(e, a, s).end();
        })), Oe.log(''.concat(n, ' failed. error:'), e), ai(e))));
    } }, { key: 'joinGroup', value(e) {
      const t = this; const n = e.groupID; const o = e.type; const a = ''.concat(this._className, '.joinGroup');if (o === k.GRP_WORK) {
        const s = new ei({ code: Do.CANNOT_JOIN_WORK, message: ua });return ai(s);
      } if (this.deleteUnjoinedAVChatRoom(n), this.hasLocalGroup(n)) {
        if (!this.isLoggedIn()) return oi({ status: k.JOIN_STATUS_ALREADY_IN_GROUP });const r = new Xa(ws);return this.getGroupProfile({ groupID: n }).then((() => (r.setNetworkType(t.getNetworkType()).setMessage('groupID:'.concat(n, ' joinedStatus:').concat(k.JOIN_STATUS_ALREADY_IN_GROUP))
          .end(), oi({ status: k.JOIN_STATUS_ALREADY_IN_GROUP }))))
          .catch((o => (r.setNetworkType(t.getNetworkType()).setMessage('groupID:'.concat(n, ' unjoined'))
            .end(), Oe.warn(''.concat(a, ' ').concat(n, ' was unjoined, now join!')), t.groupMap.delete(n), t.applyJoinGroup(e))));
      } return Oe.log(''.concat(a, ' groupID:').concat(n)), this.isLoggedIn() ? this.applyJoinGroup(e) : this._AVChatRoomHandler.joinWithoutAuth(e);
    } }, { key: 'applyJoinGroup', value(e) {
      const t = this; const n = ''.concat(this._className, '.applyJoinGroup'); const o = e.groupID; const a = new Xa(ws); const s = r({}, e); const i = this.canIUse(B.AVCHATROOM_HISTORY_MSG);return i && (s.historyMessageFlag = 1), this.request({ protocolName: Un, requestData: s }).then(((e) => {
        const s = e.data; const r = s.joinedStatus; const c = s.longPollingKey; const u = s.avChatRoomFlag; const l = s.avChatRoomKey; const d = s.messageList; const p = 'groupID:'.concat(o, ' joinedStatus:').concat(r, ' longPollingKey:')
          .concat(c) + ' avChatRoomFlag:'.concat(u, ' canGetAVChatRoomHistoryMessage:').concat(i);switch (a.setNetworkType(t.getNetworkType()).setMessage(''.concat(p))
          .end(), Oe.log(''.concat(n, ' ok. ').concat(p)), r) {
          case Or:return $r({ status: Or });case Rr:return t.getGroupProfile({ groupID: o }).then(((e) => {
            let n; const a = e.data.group; const s = { status: Rr, group: a };return 1 === u ? (t.getModule(xt).setCompleted(''.concat(k.CONV_GROUP).concat(o)), t._groupAttributesHandler.initGroupAttributesCache({ groupID: o, avChatRoomKey: l }), (n = qe(c) ? t._AVChatRoomHandler.handleJoinResult({ group: a }) : t._AVChatRoomHandler.startRunLoop({ longPollingKey: c, group: a })).then((() => {
              t._onAVChatRoomHistoryMessage(d);
            })), n) : (t.emitGroupListUpdate(!0, !1), $r(s));
          }));default:var g = new ei({ code: Do.JOIN_GROUP_FAIL, message: ha });return Oe.error(''.concat(n, ' error:'), g), ai(g);
        }
      }))
        .catch((o => (a.setMessage('groupID:'.concat(e.groupID)), t.probeNetwork().then(((e) => {
          const t = m(e, 2); const n = t[0]; const s = t[1];a.setError(o, n, s).end();
        })), Oe.error(''.concat(n, ' error:'), o), ai(o))));
    } }, { key: 'quitGroup', value(e) {
      const t = this; const n = ''.concat(this._className, '.quitGroup');Oe.log(''.concat(n, ' groupID:').concat(e));const o = this.checkJoinedAVChatRoomByID(e);if (!o && !this.hasLocalGroup(e)) {
        const a = new ei({ code: Do.MEMBER_NOT_IN_GROUP, message: ga });return ai(a);
      } if (o && !this.isLoggedIn()) return Oe.log(''.concat(n, ' anonymously ok. groupID:').concat(e)), this.deleteLocalGroupAndConversation(e), this._AVChatRoomHandler.reset(e), oi({ groupID: e });const s = new Xa(bs);return s.setMessage('groupID:'.concat(e)), this.request({ protocolName: qn, requestData: { groupID: e } }).then((() => (s.setNetworkType(t.getNetworkType()).end(), Oe.log(''.concat(n, ' ok')), o && t._AVChatRoomHandler.reset(e), t.deleteLocalGroupAndConversation(e), $r({ groupID: e }))))
        .catch((e => (t.probeNetwork().then(((t) => {
          const n = m(t, 2); const o = n[0]; const a = n[1];s.setError(e, o, a).end();
        })), Oe.error(''.concat(n, ' failed. error:'), e), ai(e))));
    } }, { key: 'searchGroupByID', value(e) {
      const t = this; const n = ''.concat(this._className, '.searchGroupByID'); const o = { groupIDList: [e] }; const a = new Xa(Ps);return a.setMessage('groupID:'.concat(e)), Oe.log(''.concat(n, ' groupID:').concat(e)), this.request({ protocolName: Vn, requestData: o }).then(((e) => {
        const o = e.data.groupProfile;if (0 !== o[0].errorCode) throw new ei({ code: o[0].errorCode, message: o[0].errorInfo });return a.setNetworkType(t.getNetworkType()).end(), Oe.log(''.concat(n, ' ok')), $r({ group: new Ii(o[0]) });
      }))
        .catch((e => (t.probeNetwork().then(((t) => {
          const n = m(t, 2); const o = n[0]; const s = n[1];a.setError(e, o, s).end();
        })), Oe.warn(''.concat(n, ' failed. error:'), e), ai(e))));
    } }, { key: 'changeGroupOwner', value(e) {
      const t = this; const n = ''.concat(this._className, '.changeGroupOwner');if (this.hasLocalGroup(e.groupID) && this.getLocalGroupProfile(e.groupID).type === k.GRP_AVCHATROOM) return ai(new ei({ code: Do.CANNOT_CHANGE_OWNER_IN_AVCHATROOM, message: la }));if (e.newOwnerID === this.getMyUserID()) return ai(new ei({ code: Do.CANNOT_CHANGE_OWNER_TO_SELF, message: da }));const o = new Xa(Us);return o.setMessage('groupID:'.concat(e.groupID, ' newOwnerID:').concat(e.newOwnerID)), Oe.log(''.concat(n, ' groupID:').concat(e.groupID)), this.request({ protocolName: Kn, requestData: e }).then((() => {
        o.setNetworkType(t.getNetworkType()).end(), Oe.log(''.concat(n, ' ok'));const a = e.groupID; const s = e.newOwnerID;t.groupMap.get(a).ownerID = s;const r = t.getModule(Kt).getLocalGroupMemberList(a);if (r instanceof Map) {
          const i = r.get(t.getMyUserID());qe(i) || (i.updateRole('Member'), t.groupMap.get(a).selfInfo.role = 'Member');const c = r.get(s);qe(c) || c.updateRole('Owner');
        } return t.emitGroupListUpdate(!0, !1), $r({ group: t.groupMap.get(a) });
      }))
        .catch((e => (t.probeNetwork().then(((t) => {
          const n = m(t, 2); const a = n[0]; const s = n[1];o.setError(e, a, s).end();
        })), Oe.error(''.concat(n, ' failed. error:'), e), ai(e))));
    } }, { key: 'handleGroupApplication', value(e) {
      const t = this; const n = ''.concat(this._className, '.handleGroupApplication'); const o = e.message.payload; const a = o.groupProfile.groupID; const s = o.authentication; const i = o.messageKey; const c = o.operatorID; const u = new Xa(Fs);return u.setMessage('groupID:'.concat(a)), Oe.log(''.concat(n, ' groupID:').concat(a)), this.request({ protocolName: xn, requestData: r(r({}, e), {}, { applicant: c, groupID: a, authentication: s, messageKey: i }) }).then((() => (u.setNetworkType(t.getNetworkType()).end(), Oe.log(''.concat(n, ' ok')), t._groupSystemNoticeHandler.deleteGroupSystemNotice({ messageList: [e.message] }), $r({ group: t.getLocalGroupProfile(a) }))))
        .catch((e => (t.probeNetwork().then(((t) => {
          const n = m(t, 2); const o = n[0]; const a = n[1];u.setError(e, o, a).end();
        })), Oe.error(''.concat(n, ' failed. error'), e), ai(e))));
    } }, { key: 'handleGroupInvitation', value(e) {
      const t = this; const n = ''.concat(this._className, '.handleGroupInvitation'); const o = e.message.payload; const a = o.groupProfile.groupID; const s = o.authentication; const i = o.messageKey; const c = o.operatorID; const u = e.handleAction; const l = new Xa(qs);return l.setMessage('groupID:'.concat(a, ' inviter:').concat(c, ' handleAction:')
        .concat(u)), Oe.log(''.concat(n, ' groupID:').concat(a, ' inviter:')
        .concat(c, ' handleAction:')
        .concat(u)), this.request({ protocolName: Bn, requestData: r(r({}, e), {}, { inviter: c, groupID: a, authentication: s, messageKey: i }) }).then((() => (l.setNetworkType(t.getNetworkType()).end(), Oe.log(''.concat(n, ' ok')), t._groupSystemNoticeHandler.deleteGroupSystemNotice({ messageList: [e.message] }), $r({ group: t.getLocalGroupProfile(a) }))))
        .catch((e => (t.probeNetwork().then(((t) => {
          const n = m(t, 2); const o = n[0]; const a = n[1];l.setError(e, o, a).end();
        })), Oe.error(''.concat(n, ' failed. error'), e), ai(e))));
    } }, { key: 'getGroupOnlineMemberCount', value(e) {
      return this._AVChatRoomHandler ? this._AVChatRoomHandler.checkJoinedAVChatRoomByID(e) ? this._AVChatRoomHandler.getGroupOnlineMemberCount(e) : oi({ memberCount: 0 }) : ai({ code: Do.CANNOT_FIND_MODULE, message: Ga });
    } }, { key: 'hasLocalGroup', value(e) {
      return this.groupMap.has(e);
    } }, { key: 'deleteLocalGroupAndConversation', value(e) {
      this._deleteLocalGroup(e), this.getModule(xt).deleteLocalConversation('GROUP'.concat(e)), this.emitGroupListUpdate(!0, !1);
    } }, { key: '_deleteLocalGroup', value(e) {
      this.groupMap.delete(e), this.getModule(Kt).deleteGroupMemberList(e), this._setStorageGroupList();
    } }, { key: 'sendMessage', value(e, t) {
      const n = this.createGroupMessagePack(e, t);return this.request(n);
    } }, { key: 'createGroupMessagePack', value(e, t) {
      let n = null;t && t.offlinePushInfo && (n = t.offlinePushInfo);let o = '';be(e.cloudCustomData) && e.cloudCustomData.length > 0 && (o = e.cloudCustomData);const a = [];if (Ue(t) && Ue(t.messageControlInfo)) {
        const s = t.messageControlInfo; const r = s.excludedFromUnreadCount; const i = s.excludedFromLastMessage;!0 === r && a.push('NoUnread'), !0 === i && a.push('NoLastMsg');
      } const c = e.getGroupAtInfoList();return { protocolName: hn, tjgID: this.generateTjgID(e), requestData: { fromAccount: this.getMyUserID(), groupID: e.to, msgBody: e.getElements(), cloudCustomData: o, random: e.random, priority: e.priority, clientSequence: e.clientSequence, groupAtInfo: e.type !== k.MSG_TEXT || It(c) ? void 0 : c, onlineOnlyFlag: this.isOnlineMessage(e, t) ? 1 : 0, offlinePushInfo: n ? { pushFlag: !0 === n.disablePush ? 1 : 0, title: n.title || '', desc: n.description || '', ext: n.extension || '', apnsInfo: { badgeMode: !0 === n.ignoreIOSBadge ? 1 : 0 }, androidInfo: { OPPOChannelID: n.androidOPPOChannelID || '' } } : void 0, messageControlInfo: a } };
    } }, { key: 'revokeMessage', value(e) {
      return this.request({ protocolName: Hn, requestData: { to: e.to, msgSeqList: [{ msgSeq: e.sequence }] } });
    } }, { key: 'deleteMessage', value(e) {
      const t = e.to; const n = e.keyList;return Oe.log(''.concat(this._className, '.deleteMessage groupID:').concat(t, ' count:')
        .concat(n.length)), this.request({ protocolName: Zn, requestData: { groupID: t, deleter: this.getMyUserID(), keyList: n } });
    } }, { key: 'getRoamingMessage', value(e) {
      const t = this; const n = ''.concat(this._className, '.getRoamingMessage'); const o = new Xa(_s); let a = 0;return this._computeLastSequence(e).then((n => (a = n, Oe.log(''.concat(t._className, '.getRoamingMessage groupID:').concat(e.groupID, ' lastSequence:')
        .concat(a)), t.request({ protocolName: Yn, requestData: { groupID: e.groupID, count: 21, sequence: a } }))))
        .then(((s) => {
          const r = s.data; const i = r.messageList; const c = r.complete;qe(i) ? Oe.log(''.concat(n, ' ok. complete:').concat(c, ' but messageList is undefined!')) : Oe.log(''.concat(n, ' ok. complete:').concat(c, ' count:')
            .concat(i.length)), o.setNetworkType(t.getNetworkType()).setMessage('groupID:'.concat(e.groupID, ' lastSequence:').concat(a, ' complete:')
            .concat(c, ' count:')
            .concat(i ? i.length : 'undefined'))
            .end();const u = 'GROUP'.concat(e.groupID); const l = t.getModule(xt);if (2 === c || It(i)) return l.setCompleted(u), [];const d = l.storeRoamingMessage(i, u);return l.updateIsRead(u), l.patchConversationLastMessage(u), d;
        }))
        .catch((s => (t.probeNetwork().then(((t) => {
          const n = m(t, 2); const r = n[0]; const i = n[1];o.setError(s, r, i).setMessage('groupID:'.concat(e.groupID, ' lastSequence:').concat(a))
            .end();
        })), Oe.warn(''.concat(n, ' failed. error:'), s), ai(s))));
    } }, { key: 'setMessageRead', value(e) {
      const t = this; const n = e.conversationID; const o = e.lastMessageSeq; const a = ''.concat(this._className, '.setMessageRead');Oe.log(''.concat(a, ' conversationID:').concat(n, ' lastMessageSeq:')
        .concat(o)), we(o) || Oe.warn(''.concat(a, ' 请勿修改 Conversation.lastMessage.lastSequence，否则可能会导致已读上报结果不准确'));const s = new Xa(vs);return s.setMessage(''.concat(n, '-').concat(o)), this.request({ protocolName: jn, requestData: { groupID: n.replace('GROUP', ''), messageReadSeq: o } }).then((() => {
        s.setNetworkType(t.getNetworkType()).end(), Oe.log(''.concat(a, ' ok.'));const e = t.getModule(xt);return e.updateIsReadAfterReadReport({ conversationID: n, lastMessageSeq: o }), e.updateUnreadCount(n), $r();
      }))
        .catch((e => (t.probeNetwork().then(((t) => {
          const n = m(t, 2); const o = n[0]; const a = n[1];s.setError(e, o, a).end();
        })), Oe.log(''.concat(a, ' failed. error:'), e), ai(e))));
    } }, { key: '_computeLastSequence', value(e) {
      return e.sequence > 0 ? Promise.resolve(e.sequence) : this.getGroupLastSequence(e.groupID);
    } }, { key: 'getGroupLastSequence', value(e) {
      const t = this; const n = ''.concat(this._className, '.getGroupLastSequence'); const o = new Xa(Ws); let a = 0; let s = '';if (this.hasLocalGroup(e)) {
        const r = this.getLocalGroupProfile(e); const i = r.lastMessage;if (i.lastSequence > 0 && !1 === i.onlineOnlyFlag) return a = i.lastSequence, s = 'got lastSequence:'.concat(a, ' from local group profile[lastMessage.lastSequence]. groupID:').concat(e), Oe.log(''.concat(n, ' ').concat(s)), o.setNetworkType(this.getNetworkType()).setMessage(''.concat(s))
          .end(), Promise.resolve(a);if (r.nextMessageSeq > 1) return a = r.nextMessageSeq - 1, s = 'got lastSequence:'.concat(a, ' from local group profile[nextMessageSeq]. groupID:').concat(e), Oe.log(''.concat(n, ' ').concat(s)), o.setNetworkType(this.getNetworkType()).setMessage(''.concat(s))
          .end(), Promise.resolve(a);
      } const c = 'GROUP'.concat(e); const u = this.getModule(xt).getLocalConversation(c);if (u && u.lastMessage.lastSequence && !1 === u.lastMessage.onlineOnlyFlag) return a = u.lastMessage.lastSequence, s = 'got lastSequence:'.concat(a, ' from local conversation profile[lastMessage.lastSequence]. groupID:').concat(e), Oe.log(''.concat(n, ' ').concat(s)), o.setNetworkType(this.getNetworkType()).setMessage(''.concat(s))
        .end(), Promise.resolve(a);const l = { groupIDList: [e], responseFilter: { groupBaseInfoFilter: ['NextMsgSeq'] } };return this.getGroupProfileAdvance(l).then(((r) => {
        const i = r.data.successGroupList;return It(i) ? Oe.log(''.concat(n, ' successGroupList is empty. groupID:').concat(e)) : (a = i[0].nextMessageSeq - 1, s = 'got lastSequence:'.concat(a, ' from getGroupProfileAdvance. groupID:').concat(e), Oe.log(''.concat(n, ' ').concat(s))), o.setNetworkType(t.getNetworkType()).setMessage(''.concat(s))
          .end(), a;
      }))
        .catch((a => (t.probeNetwork().then(((t) => {
          const n = m(t, 2); const s = n[0]; const r = n[1];o.setError(a, s, r).setMessage('get lastSequence failed from getGroupProfileAdvance. groupID:'.concat(e))
            .end();
        })), Oe.warn(''.concat(n, ' failed. error:'), a), ai(a))));
    } }, { key: 'isMessageFromAVChatroom', value(e) {
      return !!this._AVChatRoomHandler && this._AVChatRoomHandler.checkJoinedAVChatRoomByID(e);
    } }, { key: 'hasJoinedAVChatRoom', value() {
      return this._AVChatRoomHandler ? this._AVChatRoomHandler.hasJoinedAVChatRoom() : 0;
    } }, { key: 'getJoinedAVChatRoom', value() {
      return this._AVChatRoomHandler ? this._AVChatRoomHandler.getJoinedAVChatRoom() : [];
    } }, { key: 'isOnlineMessage', value(e, t) {
      return !(!this._canIUseOnlineOnlyFlag(e) || !t || !0 !== t.onlineUserOnly);
    } }, { key: '_canIUseOnlineOnlyFlag', value(e) {
      const t = this.getJoinedAVChatRoom();return !t || !t.includes(e.to) || e.conversationType !== k.CONV_GROUP;
    } }, { key: 'deleteLocalGroupMembers', value(e, t) {
      this.getModule(Kt).deleteLocalGroupMembers(e, t);
    } }, { key: '_onAVChatRoomHistoryMessage', value(e) {
      if (!It(e)) {
        Oe.log(''.concat(this._className, '._onAVChatRoomHistoryMessage count:').concat(e.length));const t = [];e.forEach(((e) => {
          t.push(r(r({}, e), {}, { isHistoryMessage: 1 }));
        })), this.onAVChatRoomMessage(t);
      }
    } }, { key: 'onAVChatRoomMessage', value(e) {
      this._AVChatRoomHandler && this._AVChatRoomHandler.onMessage(e);
    } }, { key: 'getGroupSimplifiedInfo', value(e) {
      const t = this; const n = new Xa(zs); const o = { groupIDList: [e], responseFilter: { groupBaseInfoFilter: ['Type', 'Name'] } };return this.getGroupProfileAdvance(o).then(((o) => {
        const a = o.data.successGroupList;return n.setNetworkType(t.getNetworkType()).setMessage('groupID:'.concat(e, ' type:').concat(a[0].type))
          .end(), a[0];
      }))
        .catch(((o) => {
          t.probeNetwork().then(((t) => {
            const a = m(t, 2); const s = a[0]; const r = a[1];n.setError(o, s, r).setMessage('groupID:'.concat(e))
              .end();
          }));
        }));
    } }, { key: 'setUnjoinedAVChatRoom', value(e) {
      this._unjoinedAVChatRoomList.set(e, 1);
    } }, { key: 'deleteUnjoinedAVChatRoom', value(e) {
      this._unjoinedAVChatRoomList.has(e) && this._unjoinedAVChatRoomList.delete(e);
    } }, { key: 'isUnjoinedAVChatRoom', value(e) {
      return this._unjoinedAVChatRoomList.has(e);
    } }, { key: 'onGroupAttributesUpdated', value(e) {
      this._groupAttributesHandler && this._groupAttributesHandler.onGroupAttributesUpdated(e);
    } }, { key: 'updateLocalMainSequenceOnReconnected', value() {
      this._groupAttributesHandler && this._groupAttributesHandler.updateLocalMainSequenceOnReconnected();
    } }, { key: 'initGroupAttributes', value(e) {
      return this._groupAttributesHandler.initGroupAttributes(e);
    } }, { key: 'setGroupAttributes', value(e) {
      return this._groupAttributesHandler.setGroupAttributes(e);
    } }, { key: 'deleteGroupAttributes', value(e) {
      return this._groupAttributesHandler.deleteGroupAttributes(e);
    } }, { key: 'getGroupAttributes', value(e) {
      return this._groupAttributesHandler.getGroupAttributes(e);
    } }, { key: 'reset', value() {
      this.groupMap.clear(), this._unjoinedAVChatRoomList.clear(), this._commonGroupHandler.reset(), this._groupSystemNoticeHandler.reset(), this._groupTipsHandler.reset(), this._AVChatRoomHandler && this._AVChatRoomHandler.reset();
    } }]), a;
  }(sn)); const Fi = (function () {
    function e(n) {
      t(this, e), this.userID = '', this.avatar = '', this.nick = '', this.role = '', this.joinTime = '', this.lastSendMsgTime = '', this.nameCard = '', this.muteUntil = 0, this.memberCustomField = [], this._initMember(n);
    } return o(e, [{ key: '_initMember', value(e) {
      this.updateMember(e);
    } }, { key: 'updateMember', value(e) {
      const t = [null, void 0, '', 0, NaN];e.memberCustomField && st(this.memberCustomField, e.memberCustomField), Ye(this, e, ['memberCustomField'], t);
    } }, { key: 'updateRole', value(e) {
      ['Owner', 'Admin', 'Member'].indexOf(e) < 0 || (this.role = e);
    } }, { key: 'updateMuteUntil', value(e) {
      qe(e) || (this.muteUntil = Math.floor((Date.now() + 1e3 * e) / 1e3));
    } }, { key: 'updateNameCard', value(e) {
      qe(e) || (this.nameCard = e);
    } }, { key: 'updateMemberCustomField', value(e) {
      e && st(this.memberCustomField, e);
    } }]), e;
  }()); const qi = (function (e) {
    i(a, e);const n = f(a);function a(e) {
      let o;return t(this, a), (o = n.call(this, e))._className = 'GroupMemberModule', o.groupMemberListMap = new Map, o.getInnerEmitterInstance().on(ui, o._onProfileUpdated, h(o)), o;
    } return o(a, [{ key: '_onProfileUpdated', value(e) {
      for (var t = this, n = e.data, o = function (e) {
          const o = n[e];t.groupMemberListMap.forEach(((e) => {
            e.has(o.userID) && e.get(o.userID).updateMember({ nick: o.nick, avatar: o.avatar });
          }));
        }, a = 0;a < n.length;a++)o(a);
    } }, { key: 'deleteGroupMemberList', value(e) {
      this.groupMemberListMap.delete(e);
    } }, { key: 'getGroupMemberList', value(e) {
      const t = this; const n = e.groupID; const o = e.offset; const a = void 0 === o ? 0 : o; const s = e.count; const r = void 0 === s ? 15 : s; const i = ''.concat(this._className, '.getGroupMemberList'); const c = new Xa(tr);Oe.log(''.concat(i, ' groupID:').concat(n, ' offset:')
        .concat(a, ' count:')
        .concat(r));let u = [];return this.request({ protocolName: so, requestData: { groupID: n, offset: a, limit: r > 100 ? 100 : r } }).then(((e) => {
        const o = e.data; const a = o.members; const s = o.memberNum;if (!Fe(a) || 0 === a.length) return Promise.resolve([]);const r = t.getModule(qt);return r.hasLocalGroup(n) && (r.getLocalGroupProfile(n).memberNum = s), u = t._updateLocalGroupMemberMap(n, a), t.getModule(Ut).getUserProfile({ userIDList: a.map((e => e.userID)), tagList: [Er.NICK, Er.AVATAR] });
      }))
        .then(((e) => {
          const o = e.data;if (!Fe(o) || 0 === o.length) return oi({ memberList: [] });const s = o.map((e => ({ userID: e.userID, nick: e.nick, avatar: e.avatar })));return t._updateLocalGroupMemberMap(n, s), c.setNetworkType(t.getNetworkType()).setMessage('groupID:'.concat(n, ' offset:').concat(a, ' count:')
            .concat(r))
            .end(), Oe.log(''.concat(i, ' ok.')), $r({ memberList: u });
        }))
        .catch((e => (t.probeNetwork().then(((t) => {
          const n = m(t, 2); const o = n[0]; const a = n[1];c.setError(e, o, a).end();
        })), Oe.error(''.concat(i, ' failed. error:'), e), ai(e))));
    } }, { key: 'getGroupMemberProfile', value(e) {
      const t = this; const n = ''.concat(this._className, '.getGroupMemberProfile'); const o = new Xa(nr);o.setMessage(e.userIDList.length > 5 ? 'userIDList.length:'.concat(e.userIDList.length) : 'userIDList:'.concat(e.userIDList)), Oe.log(''.concat(n, ' groupID:').concat(e.groupID, ' userIDList:')
        .concat(e.userIDList.join(','))), e.userIDList.length > 50 && (e.userIDList = e.userIDList.slice(0, 50));const a = e.groupID; const s = e.userIDList;return this._getGroupMemberProfileAdvance(r(r({}, e), {}, { userIDList: s })).then(((e) => {
        const n = e.data.members;return Fe(n) && 0 !== n.length ? (t._updateLocalGroupMemberMap(a, n), t.getModule(Ut).getUserProfile({ userIDList: n.map((e => e.userID)), tagList: [Er.NICK, Er.AVATAR] })) : oi([]);
      }))
        .then(((e) => {
          const n = e.data.map((e => ({ userID: e.userID, nick: e.nick, avatar: e.avatar })));t._updateLocalGroupMemberMap(a, n);const r = s.filter((e => t.hasLocalGroupMember(a, e))).map((e => t.getLocalGroupMemberInfo(a, e)));return o.setNetworkType(t.getNetworkType()).end(), $r({ memberList: r });
        }));
    } }, { key: 'addGroupMember', value(e) {
      const t = this; const n = ''.concat(this._className, '.addGroupMember'); const o = e.groupID; const a = this.getModule(qt).getLocalGroupProfile(o); const s = a.type; const r = new Xa(or);if (r.setMessage('groupID:'.concat(o, ' groupType:').concat(s)), it(s)) {
        const i = new ei({ code: Do.CANNOT_ADD_MEMBER_IN_AVCHATROOM, message: _a });return r.setCode(Do.CANNOT_ADD_MEMBER_IN_AVCHATROOM).setError(_a)
          .setNetworkType(this.getNetworkType())
          .end(), ai(i);
      } return e.userIDList = e.userIDList.map((e => ({ userID: e }))), Oe.log(''.concat(n, ' groupID:').concat(o)), this.request({ protocolName: io, requestData: e }).then(((o) => {
        const s = o.data.members;Oe.log(''.concat(n, ' ok'));const i = s.filter((e => 1 === e.result)).map((e => e.userID)); const c = s.filter((e => 0 === e.result)).map((e => e.userID)); const u = s.filter((e => 2 === e.result)).map((e => e.userID)); const l = s.filter((e => 4 === e.result)).map((e => e.userID)); const d = 'groupID:'.concat(e.groupID, ', ') + 'successUserIDList:'.concat(i, ', ') + 'failureUserIDList:'.concat(c, ', ') + 'existedUserIDList:'.concat(u, ', ') + 'overLimitUserIDList:'.concat(l);return r.setNetworkType(t.getNetworkType()).setMoreMessage(d)
          .end(), 0 === i.length ? $r({ successUserIDList: i, failureUserIDList: c, existedUserIDList: u, overLimitUserIDList: l }) : (a.memberNum += i.length, $r({ successUserIDList: i, failureUserIDList: c, existedUserIDList: u, overLimitUserIDList: l, group: a }));
      }))
        .catch((e => (t.probeNetwork().then(((t) => {
          const n = m(t, 2); const o = n[0]; const a = n[1];r.setError(e, o, a).end();
        })), Oe.error(''.concat(n, ' failed. error:'), e), ai(e))));
    } }, { key: 'deleteGroupMember', value(e) {
      const t = this; const n = ''.concat(this._className, '.deleteGroupMember'); const o = e.groupID; const a = e.userIDList; const s = new Xa(ar); const r = 'groupID:'.concat(o, ' ').concat(a.length > 5 ? 'userIDList.length:'.concat(a.length) : 'userIDList:'.concat(a));s.setMessage(r), Oe.log(''.concat(n, ' groupID:').concat(o, ' userIDList:'), a);const i = this.getModule(qt).getLocalGroupProfile(o);return it(i.type) ? ai(new ei({ code: Do.CANNOT_KICK_MEMBER_IN_AVCHATROOM, message: ma })) : this.request({ protocolName: co, requestData: e }).then((() => (s.setNetworkType(t.getNetworkType()).end(), Oe.log(''.concat(n, ' ok')), i.memberNum--, t.deleteLocalGroupMembers(o, a), $r({ group: i, userIDList: a }))))
        .catch((e => (t.probeNetwork().then(((t) => {
          const n = m(t, 2); const o = n[0]; const a = n[1];s.setError(e, o, a).end();
        })), Oe.error(''.concat(n, ' failed. error:'), e), ai(e))));
    } }, { key: 'setGroupMemberMuteTime', value(e) {
      const t = this; const n = e.groupID; const o = e.userID; const a = e.muteTime; const s = ''.concat(this._className, '.setGroupMemberMuteTime');if (o === this.getMyUserID()) return ai(new ei({ code: Do.CANNOT_MUTE_SELF, message: Ca }));Oe.log(''.concat(s, ' groupID:').concat(n, ' userID:')
        .concat(o));const r = new Xa(sr);return r.setMessage('groupID:'.concat(n, ' userID:').concat(o, ' muteTime:')
        .concat(a)), this.modifyGroupMemberInfo({ groupID: n, userID: o, muteTime: a }).then(((e) => {
        r.setNetworkType(t.getNetworkType()).end(), Oe.log(''.concat(s, ' ok'));const o = t.getModule(qt);return $r({ group: o.getLocalGroupProfile(n), member: e });
      }))
        .catch((e => (t.probeNetwork().then(((t) => {
          const n = m(t, 2); const o = n[0]; const a = n[1];r.setError(e, o, a).end();
        })), Oe.error(''.concat(s, ' failed. error:'), e), ai(e))));
    } }, { key: 'setGroupMemberRole', value(e) {
      const t = this; const n = ''.concat(this._className, '.setGroupMemberRole'); const o = e.groupID; const a = e.userID; const s = e.role; const r = this.getModule(qt).getLocalGroupProfile(o);if (r.selfInfo.role !== k.GRP_MBR_ROLE_OWNER) return ai(new ei({ code: Do.NOT_OWNER, message: Ma }));if ([k.GRP_WORK, k.GRP_AVCHATROOM].includes(r.type)) return ai(new ei({ code: Do.CANNOT_SET_MEMBER_ROLE_IN_WORK_AND_AVCHATROOM, message: va }));if ([k.GRP_MBR_ROLE_ADMIN, k.GRP_MBR_ROLE_MEMBER].indexOf(s) < 0) return ai(new ei({ code: Do.INVALID_MEMBER_ROLE, message: ya }));if (a === this.getMyUserID()) return ai(new ei({ code: Do.CANNOT_SET_SELF_MEMBER_ROLE, message: Ia }));const i = new Xa(ir);return i.setMessage('groupID:'.concat(o, ' userID:').concat(a, ' role:')
        .concat(s)), Oe.log(''.concat(n, ' groupID:').concat(o, ' userID:')
        .concat(a)), this.modifyGroupMemberInfo({ groupID: o, userID: a, role: s }).then((e => (i.setNetworkType(t.getNetworkType()).end(), Oe.log(''.concat(n, ' ok')), $r({ group: r, member: e }))))
        .catch((e => (t.probeNetwork().then(((t) => {
          const n = m(t, 2); const o = n[0]; const a = n[1];i.setError(e, o, a).end();
        })), Oe.error(''.concat(n, ' failed. error:'), e), ai(e))));
    } }, { key: 'setGroupMemberNameCard', value(e) {
      const t = this; const n = ''.concat(this._className, '.setGroupMemberNameCard'); const o = e.groupID; const a = e.userID; const s = void 0 === a ? this.getMyUserID() : a; const r = e.nameCard;Oe.log(''.concat(n, ' groupID:').concat(o, ' userID:')
        .concat(s));const i = new Xa(rr);return i.setMessage('groupID:'.concat(o, ' userID:').concat(s, ' nameCard:')
        .concat(r)), this.modifyGroupMemberInfo({ groupID: o, userID: s, nameCard: r }).then(((e) => {
        Oe.log(''.concat(n, ' ok')), i.setNetworkType(t.getNetworkType()).end();const a = t.getModule(qt).getLocalGroupProfile(o);return s === t.getMyUserID() && a && a.setSelfNameCard(r), $r({ group: a, member: e });
      }))
        .catch((e => (t.probeNetwork().then(((t) => {
          const n = m(t, 2); const o = n[0]; const a = n[1];i.setError(e, o, a).end();
        })), Oe.error(''.concat(n, ' failed. error:'), e), ai(e))));
    } }, { key: 'setGroupMemberCustomField', value(e) {
      const t = this; const n = ''.concat(this._className, '.setGroupMemberCustomField'); const o = e.groupID; const a = e.userID; const s = void 0 === a ? this.getMyUserID() : a; const r = e.memberCustomField;Oe.log(''.concat(n, ' groupID:').concat(o, ' userID:')
        .concat(s));const i = new Xa(cr);return i.setMessage('groupID:'.concat(o, ' userID:').concat(s, ' memberCustomField:')
        .concat(JSON.stringify(r))), this.modifyGroupMemberInfo({ groupID: o, userID: s, memberCustomField: r }).then(((e) => {
        i.setNetworkType(t.getNetworkType()).end(), Oe.log(''.concat(n, ' ok'));const a = t.getModule(qt).getLocalGroupProfile(o);return $r({ group: a, member: e });
      }))
        .catch((e => (t.probeNetwork().then(((t) => {
          const n = m(t, 2); const o = n[0]; const a = n[1];i.setError(e, o, a).end();
        })), Oe.error(''.concat(n, ' failed. error:'), e), ai(e))));
    } }, { key: 'modifyGroupMemberInfo', value(e) {
      const t = this; const n = e.groupID; const o = e.userID;return this.request({ protocolName: uo, requestData: e }).then((() => {
        if (t.hasLocalGroupMember(n, o)) {
          const a = t.getLocalGroupMemberInfo(n, o);return qe(e.muteTime) || a.updateMuteUntil(e.muteTime), qe(e.role) || a.updateRole(e.role), qe(e.nameCard) || a.updateNameCard(e.nameCard), qe(e.memberCustomField) || a.updateMemberCustomField(e.memberCustomField), a;
        } return t.getGroupMemberProfile({ groupID: n, userIDList: [o] }).then((e => m(e.data.memberList, 1)[0]));
      }));
    } }, { key: '_getGroupMemberProfileAdvance', value(e) {
      return this.request({ protocolName: ro, requestData: r(r({}, e), {}, { memberInfoFilter: e.memberInfoFilter ? e.memberInfoFilter : ['Role', 'JoinTime', 'NameCard', 'ShutUpUntil'] }) });
    } }, { key: '_updateLocalGroupMemberMap', value(e, t) {
      const n = this;return Fe(t) && 0 !== t.length ? t.map((t => (n.hasLocalGroupMember(e, t.userID) ? n.getLocalGroupMemberInfo(e, t.userID).updateMember(t) : n.setLocalGroupMember(e, new Fi(t)), n.getLocalGroupMemberInfo(e, t.userID)))) : [];
    } }, { key: 'deleteLocalGroupMembers', value(e, t) {
      const n = this.groupMemberListMap.get(e);n && t.forEach(((e) => {
        n.delete(e);
      }));
    } }, { key: 'getLocalGroupMemberInfo', value(e, t) {
      return this.groupMemberListMap.has(e) ? this.groupMemberListMap.get(e).get(t) : null;
    } }, { key: 'setLocalGroupMember', value(e, t) {
      if (this.groupMemberListMap.has(e)) this.groupMemberListMap.get(e).set(t.userID, t);else {
        const n = (new Map).set(t.userID, t);this.groupMemberListMap.set(e, n);
      }
    } }, { key: 'getLocalGroupMemberList', value(e) {
      return this.groupMemberListMap.get(e);
    } }, { key: 'hasLocalGroupMember', value(e, t) {
      return this.groupMemberListMap.has(e) && this.groupMemberListMap.get(e).has(t);
    } }, { key: 'hasLocalGroupMemberMap', value(e) {
      return this.groupMemberListMap.has(e);
    } }, { key: 'reset', value() {
      this.groupMemberListMap.clear();
    } }]), a;
  }(sn)); const Vi = (function () {
    function e(n) {
      t(this, e), this._userModule = n, this._className = 'ProfileHandler', this.TAG = 'profile', this.accountProfileMap = new Map, this.expirationTime = 864e5;
    } return o(e, [{ key: 'setExpirationTime', value(e) {
      this.expirationTime = e;
    } }, { key: 'getUserProfile', value(e) {
      const t = this; const n = e.userIDList;e.fromAccount = this._userModule.getMyAccount(), n.length > 100 && (Oe.warn(''.concat(this._className, '.getUserProfile 获取用户资料人数不能超过100人')), n.length = 100);for (var o, a = [], s = [], r = 0, i = n.length;r < i;r++)o = n[r], this._userModule.isMyFriend(o) && this._containsAccount(o) ? s.push(this._getProfileFromMap(o)) : a.push(o);if (0 === a.length) return oi(s);e.toAccount = a;const c = e.bFromGetMyProfile || !1; const u = [];e.toAccount.forEach(((e) => {
        u.push({ toAccount: e, standardSequence: 0, customSequence: 0 });
      })), e.userItem = u;const l = new Xa(gr);return l.setMessage(n.length > 5 ? 'userIDList.length:'.concat(n.length) : 'userIDList:'.concat(n)), this._userModule.request({ protocolName: _n, requestData: e }).then(((e) => {
        l.setNetworkType(t._userModule.getNetworkType()).end(), Oe.info(''.concat(t._className, '.getUserProfile ok'));const n = t._handleResponse(e).concat(s);return $r(c ? n[0] : n);
      }))
        .catch((e => (t._userModule.probeNetwork().then(((t) => {
          const n = m(t, 2); const o = n[0]; const a = n[1];l.setError(e, o, a).end();
        })), Oe.error(''.concat(t._className, '.getUserProfile failed. error:'), e), ai(e))));
    } }, { key: 'getMyProfile', value() {
      const e = this._userModule.getMyAccount();if (Oe.log(''.concat(this._className, '.getMyProfile myAccount:').concat(e)), this._fillMap(), this._containsAccount(e)) {
        const t = this._getProfileFromMap(e);return Oe.debug(''.concat(this._className, '.getMyProfile from cache, myProfile:') + JSON.stringify(t)), oi(t);
      } return this.getUserProfile({ fromAccount: e, userIDList: [e], bFromGetMyProfile: !0 });
    } }, { key: '_handleResponse', value(e) {
      for (var t, n, o = We.now(), a = e.data.userProfileItem, s = [], r = 0, i = a.length;r < i;r++)'@TLS#NOT_FOUND' !== a[r].to && '' !== a[r].to && (t = a[r].to, n = this._updateMap(t, this._getLatestProfileFromResponse(t, a[r].profileItem)), s.push(n));return Oe.log(''.concat(this._className, '._handleResponse cost ').concat(We.now() - o, ' ms')), s;
    } }, { key: '_getLatestProfileFromResponse', value(e, t) {
      const n = {};if (n.userID = e, n.profileCustomField = [], !It(t)) for (let o = 0, a = t.length;o < a;o++) if (t[o].tag.indexOf('Tag_Profile_Custom') > -1)n.profileCustomField.push({ key: t[o].tag, value: t[o].value });else switch (t[o].tag) {
        case Er.NICK:n.nick = t[o].value;break;case Er.GENDER:n.gender = t[o].value;break;case Er.BIRTHDAY:n.birthday = t[o].value;break;case Er.LOCATION:n.location = t[o].value;break;case Er.SELFSIGNATURE:n.selfSignature = t[o].value;break;case Er.ALLOWTYPE:n.allowType = t[o].value;break;case Er.LANGUAGE:n.language = t[o].value;break;case Er.AVATAR:n.avatar = t[o].value;break;case Er.MESSAGESETTINGS:n.messageSettings = t[o].value;break;case Er.ADMINFORBIDTYPE:n.adminForbidType = t[o].value;break;case Er.LEVEL:n.level = t[o].value;break;case Er.ROLE:n.role = t[o].value;break;default:Oe.warn(''.concat(this._className, '._handleResponse unknown tag:'), t[o].tag, t[o].value);
      } return n;
    } }, { key: 'updateMyProfile', value(e) {
      const t = this; const n = ''.concat(this._className, '.updateMyProfile'); const o = new Xa(hr);o.setMessage(JSON.stringify(e));const a = (new mi).validate(e);if (!a.valid) return o.setCode(Do.UPDATE_PROFILE_INVALID_PARAM).setMoreMessage(''.concat(n, ' info:').concat(a.tips))
        .setNetworkType(this._userModule.getNetworkType())
        .end(), Oe.error(''.concat(n, ' info:').concat(a.tips, '，请参考 https://web.sdk.qcloud.com/im/doc/zh-cn/SDK.html#updateMyProfile')), ai({ code: Do.UPDATE_PROFILE_INVALID_PARAM, message: Ta });const s = [];for (const r in e)Object.prototype.hasOwnProperty.call(e, r) && ('profileCustomField' === r ? e.profileCustomField.forEach(((e) => {
        s.push({ tag: e.key, value: e.value });
      })) : s.push({ tag: Er[r.toUpperCase()], value: e[r] }));return 0 === s.length ? (o.setCode(Do.UPDATE_PROFILE_NO_KEY).setMoreMessage(Sa)
        .setNetworkType(this._userModule.getNetworkType())
        .end(), Oe.error(''.concat(n, ' info:').concat(Sa, '，请参考 https://web.sdk.qcloud.com/im/doc/zh-cn/SDK.html#updateMyProfile')), ai({ code: Do.UPDATE_PROFILE_NO_KEY, message: Sa })) : this._userModule.request({ protocolName: fn, requestData: { fromAccount: this._userModule.getMyAccount(), profileItem: s } }).then(((a) => {
        o.setNetworkType(t._userModule.getNetworkType()).end(), Oe.info(''.concat(n, ' ok'));const s = t._updateMap(t._userModule.getMyAccount(), e);return t._userModule.emitOuterEvent(D.PROFILE_UPDATED, [s]), oi(s);
      }))
        .catch((e => (t._userModule.probeNetwork().then(((t) => {
          const n = m(t, 2); const a = n[0]; const s = n[1];o.setError(e, a, s).end();
        })), Oe.error(''.concat(n, ' failed. error:'), e), ai(e))));
    } }, { key: 'onProfileModified', value(e) {
      const t = e.dataList;if (!It(t)) {
        let n; let o; const a = t.length;Oe.debug(''.concat(this._className, '.onProfileModified count:').concat(a, ' dataList:'), e.dataList);for (var s = [], r = 0;r < a;r++)n = t[r].userID, o = this._updateMap(n, this._getLatestProfileFromResponse(n, t[r].profileList)), s.push(o);s.length > 0 && (this._userModule.emitInnerEvent(ui, s), this._userModule.emitOuterEvent(D.PROFILE_UPDATED, s));
      }
    } }, { key: '_fillMap', value() {
      if (0 === this.accountProfileMap.size) {
        for (let e = this._getCachedProfiles(), t = Date.now(), n = 0, o = e.length;n < o;n++)t - e[n].lastUpdatedTime < this.expirationTime && this.accountProfileMap.set(e[n].userID, e[n]);Oe.log(''.concat(this._className, '._fillMap from cache, map.size:').concat(this.accountProfileMap.size));
      }
    } }, { key: '_updateMap', value(e, t) {
      let n; const o = Date.now();return this._containsAccount(e) ? (n = this._getProfileFromMap(e), t.profileCustomField && st(n.profileCustomField, t.profileCustomField), Ye(n, t, ['profileCustomField']), n.lastUpdatedTime = o) : (n = new mi(t), (this._userModule.isMyFriend(e) || e === this._userModule.getMyAccount()) && (n.lastUpdatedTime = o, this.accountProfileMap.set(e, n))), this._flushMap(e === this._userModule.getMyAccount()), n;
    } }, { key: '_flushMap', value(e) {
      const t = M(this.accountProfileMap.values()); const n = this._userModule.getStorageModule();Oe.debug(''.concat(this._className, '._flushMap length:').concat(t.length, ' flushAtOnce:')
        .concat(e)), n.setItem(this.TAG, t, e);
    } }, { key: '_containsAccount', value(e) {
      return this.accountProfileMap.has(e);
    } }, { key: '_getProfileFromMap', value(e) {
      return this.accountProfileMap.get(e);
    } }, { key: '_getCachedProfiles', value() {
      const e = this._userModule.getStorageModule().getItem(this.TAG);return It(e) ? [] : e;
    } }, { key: 'onConversationsProfileUpdated', value(e) {
      for (var t, n, o, a = [], s = 0, r = e.length;s < r;s++)n = (t = e[s]).userID, this._userModule.isMyFriend(n) || (this._containsAccount(n) ? (o = this._getProfileFromMap(n), Ye(o, t) > 0 && a.push(n)) : a.push(t.userID));0 !== a.length && (Oe.info(''.concat(this._className, '.onConversationsProfileUpdated toAccountList:').concat(a)), this.getUserProfile({ userIDList: a }));
    } }, { key: 'getNickAndAvatarByUserID', value(e) {
      if (this._containsAccount(e)) {
        const t = this._getProfileFromMap(e);return { nick: t.nick, avatar: t.avatar };
      } return { nick: '', avatar: '' };
    } }, { key: 'reset', value() {
      this._flushMap(!0), this.accountProfileMap.clear();
    } }]), e;
  }()); const Ki = function e(n) {
    t(this, e), It || (this.userID = n.userID || '', this.timeStamp = n.timeStamp || 0);
  }; const xi = (function () {
    function e(n) {
      t(this, e), this._userModule = n, this._className = 'BlacklistHandler', this._blacklistMap = new Map, this.startIndex = 0, this.maxLimited = 100, this.currentSequence = 0;
    } return o(e, [{ key: 'getLocalBlacklist', value() {
      return M(this._blacklistMap.keys());
    } }, { key: 'getBlacklist', value() {
      const e = this; const t = ''.concat(this._className, '.getBlacklist'); const n = { fromAccount: this._userModule.getMyAccount(), maxLimited: this.maxLimited, startIndex: 0, lastSequence: this.currentSequence }; const o = new Xa(_r);return this._userModule.request({ protocolName: mn, requestData: n }).then(((n) => {
        const a = n.data; const s = a.blackListItem; const r = a.currentSequence; const i = It(s) ? 0 : s.length;o.setNetworkType(e._userModule.getNetworkType()).setMessage('blackList count:'.concat(i))
          .end(), Oe.info(''.concat(t, ' ok')), e.currentSequence = r, e._handleResponse(s, !0), e._userModule.emitOuterEvent(D.BLACKLIST_UPDATED, M(e._blacklistMap.keys()));
      }))
        .catch((n => (e._userModule.probeNetwork().then(((e) => {
          const t = m(e, 2); const a = t[0]; const s = t[1];o.setError(n, a, s).end();
        })), Oe.error(''.concat(t, ' failed. error:'), n), ai(n))));
    } }, { key: 'addBlacklist', value(e) {
      const t = this; const n = ''.concat(this._className, '.addBlacklist'); const o = new Xa(fr);if (!Fe(e.userIDList)) return o.setCode(Do.ADD_BLACKLIST_INVALID_PARAM).setMessage(Da)
        .setNetworkType(this._userModule.getNetworkType())
        .end(), Oe.error(''.concat(n, ' options.userIDList 必需是数组')), ai({ code: Do.ADD_BLACKLIST_INVALID_PARAM, message: Da });const a = this._userModule.getMyAccount();return 1 === e.userIDList.length && e.userIDList[0] === a ? (o.setCode(Do.CANNOT_ADD_SELF_TO_BLACKLIST).setMessage(Ea)
        .setNetworkType(this._userModule.getNetworkType())
        .end(), Oe.error(''.concat(n, ' 不能把自己拉黑')), ai({ code: Do.CANNOT_ADD_SELF_TO_BLACKLIST, message: Ea })) : (e.userIDList.includes(a) && (e.userIDList = e.userIDList.filter((e => e !== a)), Oe.warn(''.concat(n, ' 不能把自己拉黑，已过滤'))), e.fromAccount = this._userModule.getMyAccount(), e.toAccount = e.userIDList, this._userModule.request({ protocolName: Mn, requestData: e }).then((a => (o.setNetworkType(t._userModule.getNetworkType()).setMessage(e.userIDList.length > 5 ? 'userIDList.length:'.concat(e.userIDList.length) : 'userIDList:'.concat(e.userIDList))
        .end(), Oe.info(''.concat(n, ' ok')), t._handleResponse(a.resultItem, !0), $r(M(t._blacklistMap.keys())))))
        .catch((e => (t._userModule.probeNetwork().then(((t) => {
          const n = m(t, 2); const a = n[0]; const s = n[1];o.setError(e, a, s).end();
        })), Oe.error(''.concat(n, ' failed. error:'), e), ai(e)))));
    } }, { key: '_handleResponse', value(e, t) {
      if (!It(e)) for (var n, o, a, s = 0, r = e.length;s < r;s++)o = e[s].to, a = e[s].resultCode, (qe(a) || 0 === a) && (t ? ((n = this._blacklistMap.has(o) ? this._blacklistMap.get(o) : new Ki).userID = o, !It(e[s].addBlackTimeStamp) && (n.timeStamp = e[s].addBlackTimeStamp), this._blacklistMap.set(o, n)) : this._blacklistMap.has(o) && (n = this._blacklistMap.get(o), this._blacklistMap.delete(o)));Oe.log(''.concat(this._className, '._handleResponse total:').concat(this._blacklistMap.size, ' bAdd:')
        .concat(t));
    } }, { key: 'deleteBlacklist', value(e) {
      const t = this; const n = ''.concat(this._className, '.deleteBlacklist'); const o = new Xa(mr);return Fe(e.userIDList) ? (e.fromAccount = this._userModule.getMyAccount(), e.toAccount = e.userIDList, this._userModule.request({ protocolName: vn, requestData: e }).then((a => (o.setNetworkType(t._userModule.getNetworkType()).setMessage(e.userIDList.length > 5 ? 'userIDList.length:'.concat(e.userIDList.length) : 'userIDList:'.concat(e.userIDList))
        .end(), Oe.info(''.concat(n, ' ok')), t._handleResponse(a.data.resultItem, !1), $r(M(t._blacklistMap.keys())))))
        .catch((e => (t._userModule.probeNetwork().then(((t) => {
          const n = m(t, 2); const a = n[0]; const s = n[1];o.setError(e, a, s).end();
        })), Oe.error(''.concat(n, ' failed. error:'), e), ai(e))))) : (o.setCode(Do.DEL_BLACKLIST_INVALID_PARAM).setMessage(ka)
        .setNetworkType(this._userModule.getNetworkType())
        .end(), Oe.error(''.concat(n, ' options.userIDList 必需是数组')), ai({ code: Do.DEL_BLACKLIST_INVALID_PARAM, message: ka }));
    } }, { key: 'onAccountDeleted', value(e) {
      for (var t, n = [], o = 0, a = e.length;o < a;o++)t = e[o], this._blacklistMap.has(t) && (this._blacklistMap.delete(t), n.push(t));n.length > 0 && (Oe.log(''.concat(this._className, '.onAccountDeleted count:').concat(n.length, ' userIDList:'), n), this._userModule.emitOuterEvent(D.BLACKLIST_UPDATED, M(this._blacklistMap.keys())));
    } }, { key: 'onAccountAdded', value(e) {
      for (var t, n = [], o = 0, a = e.length;o < a;o++)t = e[o], this._blacklistMap.has(t) || (this._blacklistMap.set(t, new Ki({ userID: t })), n.push(t));n.length > 0 && (Oe.log(''.concat(this._className, '.onAccountAdded count:').concat(n.length, ' userIDList:'), n), this._userModule.emitOuterEvent(D.BLACKLIST_UPDATED, M(this._blacklistMap.keys())));
    } }, { key: 'reset', value() {
      this._blacklistMap.clear(), this.startIndex = 0, this.maxLimited = 100, this.currentSequence = 0;
    } }]), e;
  }()); const Bi = (function (e) {
    i(a, e);const n = f(a);function a(e) {
      let o;return t(this, a), (o = n.call(this, e))._className = 'UserModule', o._profileHandler = new Vi(h(o)), o._blacklistHandler = new xi(h(o)), o.getInnerEmitterInstance().on(ii, o.onContextUpdated, h(o)), o;
    } return o(a, [{ key: 'onContextUpdated', value(e) {
      this._profileHandler.getMyProfile(), this._blacklistHandler.getBlacklist();
    } }, { key: 'onProfileModified', value(e) {
      this._profileHandler.onProfileModified(e);
    } }, { key: 'onRelationChainModified', value(e) {
      const t = e.dataList;if (!It(t)) {
        const n = [];t.forEach(((e) => {
          e.blackListDelAccount && n.push.apply(n, M(e.blackListDelAccount));
        })), n.length > 0 && this._blacklistHandler.onAccountDeleted(n);const o = [];t.forEach(((e) => {
          e.blackListAddAccount && o.push.apply(o, M(e.blackListAddAccount));
        })), o.length > 0 && this._blacklistHandler.onAccountAdded(o);
      }
    } }, { key: 'onConversationsProfileUpdated', value(e) {
      this._profileHandler.onConversationsProfileUpdated(e);
    } }, { key: 'getMyAccount', value() {
      return this.getMyUserID();
    } }, { key: 'getMyProfile', value() {
      return this._profileHandler.getMyProfile();
    } }, { key: 'getStorageModule', value() {
      return this.getModule(Ht);
    } }, { key: 'isMyFriend', value(e) {
      const t = this.getModule(Vt);return !!t && t.isMyFriend(e);
    } }, { key: 'getUserProfile', value(e) {
      return this._profileHandler.getUserProfile(e);
    } }, { key: 'updateMyProfile', value(e) {
      return this._profileHandler.updateMyProfile(e);
    } }, { key: 'getNickAndAvatarByUserID', value(e) {
      return this._profileHandler.getNickAndAvatarByUserID(e);
    } }, { key: 'getLocalBlacklist', value() {
      const e = this._blacklistHandler.getLocalBlacklist();return oi(e);
    } }, { key: 'addBlacklist', value(e) {
      return this._blacklistHandler.addBlacklist(e);
    } }, { key: 'deleteBlacklist', value(e) {
      return this._blacklistHandler.deleteBlacklist(e);
    } }, { key: 'reset', value() {
      Oe.log(''.concat(this._className, '.reset')), this._profileHandler.reset(), this._blacklistHandler.reset();
    } }]), a;
  }(sn)); const Hi = (function () {
    function e(n, o) {
      t(this, e), this._moduleManager = n, this._isLoggedIn = !1, this._SDKAppID = o.SDKAppID, this._userID = o.userID || '', this._userSig = o.userSig || '', this._version = '2.16.3', this._a2Key = '', this._tinyID = '', this._contentType = 'json', this._unlimitedAVChatRoom = o.unlimitedAVChatRoom, this._scene = o.scene || '', this._oversea = o.oversea, this._instanceID = o.instanceID, this._statusInstanceID = 0, this._isDevMode = o.devMode, this._proxyServer = o.proxyServer;
    } return o(e, [{ key: 'isLoggedIn', value() {
      return this._isLoggedIn;
    } }, { key: 'isOversea', value() {
      return this._oversea;
    } }, { key: 'isDevMode', value() {
      return this._isDevMode;
    } }, { key: 'isSingaporeSite', value() {
      return this._SDKAppID >= 2e7 && this._SDKAppID < 3e7;
    } }, { key: 'isKoreaSite', value() {
      return this._SDKAppID >= 3e7 && this._SDKAppID < 4e7;
    } }, { key: 'isGermanySite', value() {
      return this._SDKAppID >= 4e7 && this._SDKAppID < 5e7;
    } }, { key: 'isIndiaSite', value() {
      return this._SDKAppID >= 5e7 && this._SDKAppID < 6e7;
    } }, { key: 'isUnlimitedAVChatRoom', value() {
      return this._unlimitedAVChatRoom;
    } }, { key: 'getUserID', value() {
      return this._userID;
    } }, { key: 'setUserID', value(e) {
      this._userID = e;
    } }, { key: 'setUserSig', value(e) {
      this._userSig = e;
    } }, { key: 'getUserSig', value() {
      return this._userSig;
    } }, { key: 'getSDKAppID', value() {
      return this._SDKAppID;
    } }, { key: 'getTinyID', value() {
      return this._tinyID;
    } }, { key: 'setTinyID', value(e) {
      this._tinyID = e, this._isLoggedIn = !0;
    } }, { key: 'getScene', value() {
      return this._isTUIKit() ? 'tuikit' : this._scene;
    } }, { key: 'getInstanceID', value() {
      return this._instanceID;
    } }, { key: 'getStatusInstanceID', value() {
      return this._statusInstanceID;
    } }, { key: 'setStatusInstanceID', value(e) {
      this._statusInstanceID = e;
    } }, { key: 'getVersion', value() {
      return this._version;
    } }, { key: 'getA2Key', value() {
      return this._a2Key;
    } }, { key: 'setA2Key', value(e) {
      this._a2Key = e;
    } }, { key: 'getContentType', value() {
      return this._contentType;
    } }, { key: 'getProxyServer', value() {
      return this._proxyServer;
    } }, { key: '_isTUIKit', value() {
      let e = !1; let t = !1; let n = !1; let o = !1; let a = [];ee && (a = Object.keys(ne)), te && (a = Object.keys(window));for (let s = 0, r = a.length;s < r;s++) if (a[s].toLowerCase().includes('uikit')) {
        e = !0;break;
      } if (a = null, ee && Ke(getApp)) {
        const i = getApp().globalData;Ue(i) && !0 === i.isTUIKit && (t = !0);
      }!0 === this._moduleManager.getModule(Ht).getStorageSync('TIM_'.concat(this._SDKAppID, '_isTUIKit')) && (n = !0);let c = null;if ($ && 'undefined' === typeof uni && __wxConfig && (c = __wxConfig.pages), z && 'undefined' === typeof uni && __qqConfig && (c = __qqConfig.pages), Fe(c) && c.length > 0) {
        for (let u = 0, l = c.length;u < l;u++) if (c[u].toLowerCase().includes('tui')) {
          o = !0;break;
        }c = null;
      } return e || t || n || o;
    } }, { key: 'reset', value() {
      this._isLoggedIn = !1, this._userSig = '', this._a2Key = '', this._tinyID = '', this._statusInstanceID = 0;
    } }]), e;
  }()); const ji = (function (e) {
    i(a, e);const n = f(a);function a(e) {
      let o;return t(this, a), (o = n.call(this, e))._className = 'SignModule', o._helloInterval = 120, o._lastLoginTs = 0, o._lastWsHelloTs = 0, li.mixin(h(o)), o;
    } return o(a, [{ key: 'onCheckTimer', value(e) {
      this.isLoggedIn() && e % this._helloInterval == 0 && this._hello();
    } }, { key: 'login', value(e) {
      if (this.isLoggedIn()) {
        const t = '您已经登录账号'.concat(e.userID, '！如需切换账号登录，请先调用 logout 接口登出，再调用 login 接口登录。');return Oe.warn(t), oi({ actionStatus: 'OK', errorCode: 0, errorInfo: t, repeatLogin: !0 });
      } if (Date.now() - this._lastLoginTs <= 15e3) return Oe.warn('您正在尝试登录账号'.concat(e.userID, '！请勿重复登录。')), ai({ code: Do.REPEAT_LOGIN, message: Oo });Oe.log(''.concat(this._className, '.login userID:').concat(e.userID));const n = this._checkLoginInfo(e);if (0 !== n.code) return ai(n);const o = this.getModule(Bt); const a = e.userID; const s = e.userSig;return o.setUserID(a), o.setUserSig(s), this.getModule(Xt).updateProtocolConfig(), this._login();
    } }, { key: '_login', value() {
      const e = this; const t = this.getModule(Bt); const n = t.getScene(); const o = new Xa(es);return o.setMessage(''.concat(n)).setMoreMessage('identifier:'.concat(this.getMyUserID())), this._lastLoginTs = Date.now(), this.request({ protocolName: rn }).then(((a) => {
        e._lastLoginTs = 0;const s = Date.now(); let r = null; const i = a.data; const c = i.a2Key; const u = i.tinyID; const l = i.helloInterval; const d = i.instanceID; const p = i.timeStamp;Oe.log(''.concat(e._className, '.login ok. scene:').concat(n, ' helloInterval:')
          .concat(l, ' instanceID:')
          .concat(d, ' timeStamp:')
          .concat(p));const g = 1e3 * p; const h = s - o.getStartTs(); const _ = g + parseInt(h / 2) - s; const f = o.getStartTs() + _;if (o.start(f), (function (e, t) {
          ke = t;const n = new Date;n.setTime(e), Oe.info('baseTime from server: '.concat(n, ' offset: ').concat(ke));
        }(g, _)), !u) throw r = new ei({ code: Do.NO_TINYID, message: No }), o.setError(r, !0, e.getNetworkType()).end(), r;if (!c) throw r = new ei({ code: Do.NO_A2KEY, message: Lo }), o.setError(r, !0, e.getNetworkType()).end(), r;return o.setNetworkType(e.getNetworkType()).setMoreMessage('helloInterval:'.concat(l, ' instanceID:').concat(d, ' offset:')
          .concat(_))
          .end(), t.setA2Key(c), t.setTinyID(u), t.setStatusInstanceID(d), e.getModule(Xt).updateProtocolConfig(), e.emitInnerEvent(ii), e._helloInterval = l, e.triggerReady(), e._fetchCloudControlConfig(), a;
      }))
        .catch((t => (e.probeNetwork().then(((e) => {
          const n = m(e, 2); const a = n[0]; const s = n[1];o.setError(t, a, s).end(!0);
        })), Oe.error(''.concat(e._className, '.login failed. error:'), t), e._moduleManager.onLoginFailed(), ai(t))));
    } }, { key: 'logout', value() {
      const e = this; const t = arguments.length > 0 && void 0 !== arguments[0] ? arguments[0] : 0;if (!this.isLoggedIn()) return ai({ code: Do.USER_NOT_LOGGED_IN, message: Ro });const n = new Xa(ts);return n.setNetworkType(this.getNetworkType()).setMessage('identifier:'.concat(this.getMyUserID()))
        .end(!0), Oe.info(''.concat(this._className, '.logout type:').concat(t)), this.request({ protocolName: cn, requestData: { type: t } }).then((() => (e.resetReady(), oi({}))))
        .catch((t => (Oe.error(''.concat(e._className, '._logout error:'), t), e.resetReady(), oi({}))));
    } }, { key: '_fetchCloudControlConfig', value() {
      this.getModule(en).fetchConfig();
    } }, { key: '_hello', value() {
      const e = this;this._lastWsHelloTs = Date.now(), this.request({ protocolName: un }).catch(((t) => {
        Oe.warn(''.concat(e._className, '._hello error:'), t);
      }));
    } }, { key: 'getLastWsHelloTs', value() {
      return this._lastWsHelloTs;
    } }, { key: '_checkLoginInfo', value(e) {
      let t = 0; let n = '';return It(this.getModule(Bt).getSDKAppID()) ? (t = Do.NO_SDKAPPID, n = ko) : It(e.userID) ? (t = Do.NO_IDENTIFIER, n = Eo) : It(e.userSig) && (t = Do.NO_USERSIG, n = Ao), { code: t, message: n };
    } }, { key: 'onMultipleAccountKickedOut', value(e) {
      const t = this;new Xa(ns).setNetworkType(this.getNetworkType())
        .setMessage('type:'.concat(k.KICKED_OUT_MULT_ACCOUNT, ' newInstanceInfo:').concat(JSON.stringify(e)))
        .end(!0), Oe.warn(''.concat(this._className, '.onMultipleAccountKickedOut userID:').concat(this.getMyUserID(), ' newInstanceInfo:'), e), this.logout(1).then((() => {
        t.emitOuterEvent(D.KICKED_OUT, { type: k.KICKED_OUT_MULT_ACCOUNT }), t._moduleManager.reset();
      }));
    } }, { key: 'onMultipleDeviceKickedOut', value(e) {
      const t = this;new Xa(ns).setNetworkType(this.getNetworkType())
        .setMessage('type:'.concat(k.KICKED_OUT_MULT_DEVICE, ' newInstanceInfo:').concat(JSON.stringify(e)))
        .end(!0), Oe.warn(''.concat(this._className, '.onMultipleDeviceKickedOut userID:').concat(this.getMyUserID(), ' newInstanceInfo:'), e), this.logout(1).then((() => {
        t.emitOuterEvent(D.KICKED_OUT, { type: k.KICKED_OUT_MULT_DEVICE }), t._moduleManager.reset();
      }));
    } }, { key: 'onUserSigExpired', value() {
      new Xa(ns).setNetworkType(this.getNetworkType())
        .setMessage(k.KICKED_OUT_USERSIG_EXPIRED)
        .end(!0), Oe.warn(''.concat(this._className, '.onUserSigExpired: userSig 签名过期被踢下线')), 0 !== this.getModule(Bt).getStatusInstanceID() && (this.emitOuterEvent(D.KICKED_OUT, { type: k.KICKED_OUT_USERSIG_EXPIRED }), this._moduleManager.reset());
    } }, { key: 'reset', value() {
      Oe.log(''.concat(this._className, '.reset')), this.resetReady(), this._helloInterval = 120, this._lastLoginTs = 0, this._lastWsHelloTs = 0;
    } }]), a;
  }(sn));function Wi() {
    return null;
  } const Yi = (function () {
    function e(n) {
      t(this, e), this._moduleManager = n, this._className = 'StorageModule', this._storageQueue = new Map, this._errorTolerantHandle();
    } return o(e, [{ key: '_errorTolerantHandle', value() {
      ee || !qe(window) && !qe(window.localStorage) || (this.getItem = Wi, this.setItem = Wi, this.removeItem = Wi, this.clear = Wi);
    } }, { key: 'onCheckTimer', value(e) {
      if (e % 20 == 0) {
        if (0 === this._storageQueue.size) return;this._doFlush();
      }
    } }, { key: '_doFlush', value() {
      try {
        let e; const t = S(this._storageQueue);try {
          for (t.s();!(e = t.n()).done;) {
            const n = m(e.value, 2); const o = n[0]; const a = n[1];this._setStorageSync(this._getKey(o), a);
          }
        } catch (s) {
          t.e(s);
        } finally {
          t.f();
        } this._storageQueue.clear();
      } catch (r) {
        Oe.warn(''.concat(this._className, '._doFlush error:'), r);
      }
    } }, { key: '_getPrefix', value() {
      const e = this._moduleManager.getModule(Bt);return 'TIM_'.concat(e.getSDKAppID(), '_').concat(e.getUserID(), '_');
    } }, { key: '_getKey', value(e) {
      return ''.concat(this._getPrefix()).concat(e);
    } }, { key: 'getItem', value(e) {
      const t = !(arguments.length > 1 && void 0 !== arguments[1]) || arguments[1];try {
        const n = t ? this._getKey(e) : e;return this.getStorageSync(n);
      } catch (o) {
        return Oe.warn(''.concat(this._className, '.getItem error:'), o), {};
      }
    } }, { key: 'setItem', value(e, t) {
      const n = arguments.length > 2 && void 0 !== arguments[2] && arguments[2]; const o = !(arguments.length > 3 && void 0 !== arguments[3]) || arguments[3];if (n) {
        const a = o ? this._getKey(e) : e;this._setStorageSync(a, t);
      } else this._storageQueue.set(e, t);
    } }, { key: 'clear', value() {
      try {
        ee ? ne.clearStorageSync() : localStorage && localStorage.clear();
      } catch (e) {
        Oe.warn(''.concat(this._className, '.clear error:'), e);
      }
    } }, { key: 'removeItem', value(e) {
      const t = !(arguments.length > 1 && void 0 !== arguments[1]) || arguments[1];try {
        const n = t ? this._getKey(e) : e;this._removeStorageSync(n);
      } catch (o) {
        Oe.warn(''.concat(this._className, '.removeItem error:'), o);
      }
    } }, { key: 'getSize', value(e) {
      const t = this; const n = arguments.length > 1 && void 0 !== arguments[1] ? arguments[1] : 'b';try {
        const o = { size: 0, limitSize: 5242880, unit: n };if (Object.defineProperty(o, 'leftSize', { enumerable: !0, get() {
          return o.limitSize - o.size;
        } }), ee && (o.limitSize = 1024 * ne.getStorageInfoSync().limitSize), e)o.size = JSON.stringify(this.getItem(e)).length + this._getKey(e).length;else if (ee) {
          const a = ne.getStorageInfoSync(); const s = a.keys;s.forEach(((e) => {
            o.size += JSON.stringify(t.getStorageSync(e)).length + t._getKey(e).length;
          }));
        } else if (localStorage) for (const r in localStorage)localStorage.hasOwnProperty(r) && (o.size += localStorage.getItem(r).length + r.length);return this._convertUnit(o);
      } catch (i) {
        Oe.warn(''.concat(this._className, ' error:'), i);
      }
    } }, { key: '_convertUnit', value(e) {
      const t = {}; const n = e.unit;for (const o in t.unit = n, e)'number' === typeof e[o] && ('kb' === n.toLowerCase() ? t[o] = Math.round(e[o] / 1024) : 'mb' === n.toLowerCase() ? t[o] = Math.round(e[o] / 1024 / 1024) : t[o] = e[o]);return t;
    } }, { key: '_setStorageSync', value(e, t) {
      ee ? Q ? my.setStorageSync({ key: e, data: t }) : ne.setStorageSync(e, t) : localStorage && localStorage.setItem(e, JSON.stringify(t));
    } }, { key: 'getStorageSync', value(e) {
      return ee ? Q ? my.getStorageSync({ key: e }).data : ne.getStorageSync(e) : localStorage ? JSON.parse(localStorage.getItem(e)) : {};
    } }, { key: '_removeStorageSync', value(e) {
      ee ? Q ? my.removeStorageSync({ key: e }) : ne.removeStorageSync(e) : localStorage && localStorage.removeItem(e);
    } }, { key: 'reset', value() {
      Oe.log(''.concat(this._className, '.reset')), this._doFlush();
    } }]), e;
  }()); const $i = (function () {
    function e(n) {
      t(this, e), this._className = 'SSOLogBody', this._report = [];
    } return o(e, [{ key: 'pushIn', value(e) {
      Oe.debug(''.concat(this._className, '.pushIn'), this._report.length, e), this._report.push(e);
    } }, { key: 'backfill', value(e) {
      let t;Fe(e) && 0 !== e.length && (Oe.debug(''.concat(this._className, '.backfill'), this._report.length, e.length), (t = this._report).unshift.apply(t, M(e)));
    } }, { key: 'getLogsNumInMemory', value() {
      return this._report.length;
    } }, { key: 'isEmpty', value() {
      return 0 === this._report.length;
    } }, { key: '_reset', value() {
      this._report.length = 0, this._report = [];
    } }, { key: 'getLogsInMemory', value() {
      const e = this._report.slice();return this._reset(), e;
    } }]), e;
  }()); const zi = function (e) {
    const t = e.getModule(Bt);return { SDKType: 10, SDKAppID: t.getSDKAppID(), SDKVersion: t.getVersion(), tinyID: Number(t.getTinyID()), userID: t.getUserID(), platform: e.getPlatform(), instanceID: t.getInstanceID(), traceID: Ee() };
  }; const Ji = (function (e) {
    i(a, e);const n = f(a);function a(e) {
      let o;t(this, a), (o = n.call(this, e))._className = 'EventStatModule', o.TAG = 'im-ssolog-event', o._reportBody = new $i, o.MIN_THRESHOLD = 20, o.MAX_THRESHOLD = 100, o.WAITING_TIME = 6e4, o.REPORT_LEVEL = [4, 5, 6], o.REPORT_SDKAPPID_BLACKLIST = [], o.REPORT_TINYID_WHITELIST = [], o._lastReportTime = Date.now();const s = o.getInnerEmitterInstance();return s.on(ii, o._onLoginSuccess, h(o)), s.on(ci, o._onCloudConfigUpdated, h(o)), o;
    } return o(a, [{ key: 'reportAtOnce', value() {
      Oe.debug(''.concat(this._className, '.reportAtOnce')), this._report();
    } }, { key: '_onLoginSuccess', value() {
      const e = this; const t = this.getModule(Ht); const n = t.getItem(this.TAG, !1);!It(n) && Ke(n.forEach) && (Oe.log(''.concat(this._className, '._onLoginSuccess get ssolog in storage, count:').concat(n.length)), n.forEach(((t) => {
        e._reportBody.pushIn(t);
      })), t.removeItem(this.TAG, !1));
    } }, { key: '_onCloudConfigUpdated', value() {
      const e = this.getCloudConfig('evt_rpt_threshold'); const t = this.getCloudConfig('evt_rpt_waiting'); const n = this.getCloudConfig('evt_rpt_level'); const o = this.getCloudConfig('evt_rpt_sdkappid_bl'); const a = this.getCloudConfig('evt_rpt_tinyid_wl');qe(e) || (this.MIN_THRESHOLD = Number(e)), qe(t) || (this.WAITING_TIME = Number(t)), qe(n) || (this.REPORT_LEVEL = n.split(',').map((e => Number(e)))), qe(o) || (this.REPORT_SDKAPPID_BLACKLIST = o.split(',').map((e => Number(e)))), qe(a) || (this.REPORT_TINYID_WHITELIST = a.split(','));
    } }, { key: 'pushIn', value(e) {
      e instanceof Xa && (e.updateTimeStamp(), this._reportBody.pushIn(e), this._reportBody.getLogsNumInMemory() >= this.MIN_THRESHOLD && this._report());
    } }, { key: 'onCheckTimer', value() {
      Date.now() < this._lastReportTime + this.WAITING_TIME || this._reportBody.isEmpty() || this._report();
    } }, { key: '_filterLogs', value(e) {
      const t = this; const n = this.getModule(Bt); const o = n.getSDKAppID(); const a = n.getTinyID();return Mt(this.REPORT_SDKAPPID_BLACKLIST, o) && !vt(this.REPORT_TINYID_WHITELIST, a) ? [] : e.filter((e => t.REPORT_LEVEL.includes(e.level)));
    } }, { key: '_report', value() {
      const e = this;if (!this._reportBody.isEmpty()) {
        const t = this._reportBody.getLogsInMemory(); const n = this._filterLogs(t);if (0 !== n.length) {
          const o = { header: zi(this), event: n };this.request({ protocolName: go, requestData: r({}, o) }).then((() => {
            e._lastReportTime = Date.now();
          }))
            .catch(((n) => {
              Oe.warn(''.concat(e._className, '.report failed. networkType:').concat(e.getNetworkType(), ' error:'), n), e._reportBody.backfill(t), e._reportBody.getLogsNumInMemory() > e.MAX_THRESHOLD && e._flushAtOnce();
            }));
        } else this._lastReportTime = Date.now();
      }
    } }, { key: '_flushAtOnce', value() {
      const e = this.getModule(Ht); const t = e.getItem(this.TAG, !1); const n = this._reportBody.getLogsInMemory();if (It(t))Oe.log(''.concat(this._className, '._flushAtOnce count:').concat(n.length)), e.setItem(this.TAG, n, !0, !1);else {
        let o = n.concat(t);o.length > this.MAX_THRESHOLD && (o = o.slice(0, this.MAX_THRESHOLD)), Oe.log(''.concat(this._className, '._flushAtOnce count:').concat(o.length)), e.setItem(this.TAG, o, !0, !1);
      }
    } }, { key: 'reset', value() {
      Oe.log(''.concat(this._className, '.reset')), this._lastReportTime = 0, this._report(), this.REPORT_SDKAPPID_BLACKLIST = [], this.REPORT_TINYID_WHITELIST = [];
    } }]), a;
  }(sn)); const Xi = 'none'; const Qi = 'online'; const Zi = (function () {
    function e(n) {
      t(this, e), this._moduleManager = n, this._networkType = '', this._className = 'NetMonitorModule', this.MAX_WAIT_TIME = 3e3, this._mpNetworkStatusCallback = null, this._webOnlineCallback = null, this._webOfflineCallback = null;
    } return o(e, [{ key: 'start', value() {
      const e = this;ee ? (ne.getNetworkType({ success(t) {
        e._networkType = t.networkType, t.networkType === Xi ? Oe.warn(''.concat(e._className, '.start no network, please check!')) : Oe.info(''.concat(e._className, '.start networkType:').concat(t.networkType));
      } }), this._mpNetworkStatusCallback = this._onNetworkStatusChange.bind(this), ne.onNetworkStatusChange(this._mpNetworkStatusCallback)) : (this._networkType = Qi, this._webOnlineCallback = this._onWebOnline.bind(this), this._webOfflineCallback = this._onWebOffline.bind(this), window && (window.addEventListener('online', this._webOnlineCallback), window.addEventListener('offline', this._webOfflineCallback)));
    } }, { key: '_onWebOnline', value() {
      this._onNetworkStatusChange({ isConnected: !0, networkType: Qi });
    } }, { key: '_onWebOffline', value() {
      this._onNetworkStatusChange({ isConnected: !1, networkType: Xi });
    } }, { key: '_onNetworkStatusChange', value(e) {
      const t = e.isConnected; const n = e.networkType; let o = !1;t ? (Oe.info(''.concat(this._className, '._onNetworkStatusChange previousNetworkType:').concat(this._networkType, ' currentNetworkType:')
        .concat(n)), this._networkType !== n && (o = !0, this._moduleManager.getModule(Qt).reConnect(!0))) : this._networkType !== n && (o = !0, Oe.warn(''.concat(this._className, '._onNetworkStatusChange no network, please check!')));o && (new Xa(us).setMessage('isConnected:'.concat(t, ' previousNetworkType:').concat(this._networkType, ' networkType:')
        .concat(n))
        .end(), this._networkType = n);
    } }, { key: 'probe', value() {
      const e = this;return new Promise(((t, n) => {
        if (ee)ne.getNetworkType({ success(n) {
          e._networkType = n.networkType, n.networkType === Xi ? (Oe.warn(''.concat(e._className, '.probe no network, please check!')), t([!1, n.networkType])) : (Oe.info(''.concat(e._className, '.probe networkType:').concat(n.networkType)), t([!0, n.networkType]));
        } });else if (window && window.fetch)fetch(''.concat(nt(), '//web.sdk.qcloud.com/im/assets/speed.xml?random=').concat(Math.random())).then(((e) => {
          e.ok ? t([!0, Qi]) : t([!1, Xi]);
        }))
          .catch(((e) => {
            t([!1, Xi]);
          }));else {
          const o = new XMLHttpRequest; const a = setTimeout((() => {
            Oe.warn(''.concat(e._className, '.probe fetch timeout. Probably no network, please check!')), o.abort(), e._networkType = Xi, t([!1, Xi]);
          }), e.MAX_WAIT_TIME);o.onreadystatechange = function () {
            4 === o.readyState && (clearTimeout(a), 200 === o.status || 304 === o.status ? (this._networkType = Qi, t([!0, Qi])) : (Oe.warn(''.concat(this.className, '.probe fetch status:').concat(o.status, '. Probably no network, please check!')), this._networkType = Xi, t([!1, Xi])));
          }, o.open('GET', ''.concat(nt(), '//web.sdk.qcloud.com/im/assets/speed.xml?random=').concat(Math.random())), o.send();
        }
      }));
    } }, { key: 'getNetworkType', value() {
      return this._networkType;
    } }, { key: 'reset', value() {
      Oe.log(''.concat(this._className, '.reset')), ee ? null !== this._mpNetworkStatusCallback && (ne.offNetworkStatusChange && (Z || J ? ne.offNetworkStatusChange(this._mpNetworkStatusCallback) : ne.offNetworkStatusChange()), this._mpNetworkStatusCallback = null) : window && (null !== this._webOnlineCallback && (window.removeEventListener('online', this._webOnlineCallback), this._webOnlineCallback = null), null !== this._onWebOffline && (window.removeEventListener('offline', this._webOfflineCallback), this._webOfflineCallback = null));
    } }]), e;
  }()); const ec = N(((e) => {
    const t = Object.prototype.hasOwnProperty; let n = '~';function o() {} function a(e, t, n) {
      this.fn = e, this.context = t, this.once = n || !1;
    } function s(e, t, o, s, r) {
      if ('function' !== typeof o) throw new TypeError('The listener must be a function');const i = new a(o, s || e, r); const c = n ? n + t : t;return e._events[c] ? e._events[c].fn ? e._events[c] = [e._events[c], i] : e._events[c].push(i) : (e._events[c] = i, e._eventsCount++), e;
    } function r(e, t) {
      0 == --e._eventsCount ? e._events = new o : delete e._events[t];
    } function i() {
      this._events = new o, this._eventsCount = 0;
    }Object.create && (o.prototype = Object.create(null), (new o).__proto__ || (n = !1)), i.prototype.eventNames = function () {
      let e; let o; const a = [];if (0 === this._eventsCount) return a;for (o in e = this._events)t.call(e, o) && a.push(n ? o.slice(1) : o);return Object.getOwnPropertySymbols ? a.concat(Object.getOwnPropertySymbols(e)) : a;
    }, i.prototype.listeners = function (e) {
      const t = n ? n + e : e; const o = this._events[t];if (!o) return [];if (o.fn) return [o.fn];for (var a = 0, s = o.length, r = new Array(s);a < s;a++)r[a] = o[a].fn;return r;
    }, i.prototype.listenerCount = function (e) {
      const t = n ? n + e : e; const o = this._events[t];return o ? o.fn ? 1 : o.length : 0;
    }, i.prototype.emit = function (e, t, o, a, s, r) {
      const i = n ? n + e : e;if (!this._events[i]) return !1;let c; let u; const l = this._events[i]; const d = arguments.length;if (l.fn) {
        switch (l.once && this.removeListener(e, l.fn, void 0, !0), d) {
          case 1:return l.fn.call(l.context), !0;case 2:return l.fn.call(l.context, t), !0;case 3:return l.fn.call(l.context, t, o), !0;case 4:return l.fn.call(l.context, t, o, a), !0;case 5:return l.fn.call(l.context, t, o, a, s), !0;case 6:return l.fn.call(l.context, t, o, a, s, r), !0;
        } for (u = 1, c = new Array(d - 1);u < d;u++)c[u - 1] = arguments[u];l.fn.apply(l.context, c);
      } else {
        let p; const g = l.length;for (u = 0;u < g;u++) switch (l[u].once && this.removeListener(e, l[u].fn, void 0, !0), d) {
          case 1:l[u].fn.call(l[u].context);break;case 2:l[u].fn.call(l[u].context, t);break;case 3:l[u].fn.call(l[u].context, t, o);break;case 4:l[u].fn.call(l[u].context, t, o, a);break;default:if (!c) for (p = 1, c = new Array(d - 1);p < d;p++)c[p - 1] = arguments[p];l[u].fn.apply(l[u].context, c);
        }
      } return !0;
    }, i.prototype.on = function (e, t, n) {
      return s(this, e, t, n, !1);
    }, i.prototype.once = function (e, t, n) {
      return s(this, e, t, n, !0);
    }, i.prototype.removeListener = function (e, t, o, a) {
      const s = n ? n + e : e;if (!this._events[s]) return this;if (!t) return r(this, s), this;const i = this._events[s];if (i.fn)i.fn !== t || a && !i.once || o && i.context !== o || r(this, s);else {
        for (var c = 0, u = [], l = i.length;c < l;c++)(i[c].fn !== t || a && !i[c].once || o && i[c].context !== o) && u.push(i[c]);u.length ? this._events[s] = 1 === u.length ? u[0] : u : r(this, s);
      } return this;
    }, i.prototype.removeAllListeners = function (e) {
      let t;return e ? (t = n ? n + e : e, this._events[t] && r(this, t)) : (this._events = new o, this._eventsCount = 0), this;
    }, i.prototype.off = i.prototype.removeListener, i.prototype.addListener = i.prototype.on, i.prefixed = n, i.EventEmitter = i, e.exports = i;
  })); const tc = (function (e) {
    i(a, e);const n = f(a);function a(e) {
      let o;return t(this, a), (o = n.call(this, e))._className = 'BigDataChannelModule', o.FILETYPE = { SOUND: 2106, FILE: 2107, VIDEO: 2113 }, o._bdh_download_server = 'grouptalk.c2c.qq.com', o._BDHBizID = 10001, o._authKey = '', o._expireTime = 0, o.getInnerEmitterInstance().on(ii, o._getAuthKey, h(o)), o;
    } return o(a, [{ key: '_getAuthKey', value() {
      const e = this;this.request({ protocolName: pn }).then(((t) => {
        t.data.authKey && (e._authKey = t.data.authKey, e._expireTime = parseInt(t.data.expireTime));
      }));
    } }, { key: '_isFromOlderVersion', value(e) {
      return !(!e.content || 2 === e.content.downloadFlag);
    } }, { key: 'parseElements', value(e, t) {
      if (!Fe(e) || !t) return [];for (var n = [], o = null, a = 0;a < e.length;a++)o = e[a], this._needParse(o) ? n.push(this._parseElement(o, t)) : n.push(e[a]);return n;
    } }, { key: '_needParse', value(e) {
      return !e.cloudCustomData && !(!this._isFromOlderVersion(e) || e.type !== k.MSG_AUDIO && e.type !== k.MSG_FILE && e.type !== k.MSG_VIDEO);
    } }, { key: '_parseElement', value(e, t) {
      switch (e.type) {
        case k.MSG_AUDIO:return this._parseAudioElement(e, t);case k.MSG_FILE:return this._parseFileElement(e, t);case k.MSG_VIDEO:return this._parseVideoElement(e, t);
      }
    } }, { key: '_parseAudioElement', value(e, t) {
      return e.content.url = this._genAudioUrl(e.content.uuid, t), e;
    } }, { key: '_parseFileElement', value(e, t) {
      return e.content.url = this._genFileUrl(e.content.uuid, t, e.content.fileName), e;
    } }, { key: '_parseVideoElement', value(e, t) {
      return e.content.url = this._genVideoUrl(e.content.uuid, t), e;
    } }, { key: '_genAudioUrl', value(e, t) {
      if ('' === this._authKey) return Oe.warn(''.concat(this._className, '._genAudioUrl no authKey!')), '';const n = this.getModule(Bt).getSDKAppID();return 'https://'.concat(this._bdh_download_server, '/asn.com/stddownload_common_file?authkey=').concat(this._authKey, '&bid=')
        .concat(this._BDHBizID, '&subbid=')
        .concat(n, '&fileid=')
        .concat(e, '&filetype=')
        .concat(this.FILETYPE.SOUND, '&openid=')
        .concat(t, '&ver=0');
    } }, { key: '_genFileUrl', value(e, t, n) {
      if ('' === this._authKey) return Oe.warn(''.concat(this._className, '._genFileUrl no authKey!')), '';n || (n = ''.concat(Math.floor(1e5 * Math.random()), '-').concat(Date.now()));const o = this.getModule(Bt).getSDKAppID();return 'https://'.concat(this._bdh_download_server, '/asn.com/stddownload_common_file?authkey=').concat(this._authKey, '&bid=')
        .concat(this._BDHBizID, '&subbid=')
        .concat(o, '&fileid=')
        .concat(e, '&filetype=')
        .concat(this.FILETYPE.FILE, '&openid=')
        .concat(t, '&ver=0&filename=')
        .concat(encodeURIComponent(n));
    } }, { key: '_genVideoUrl', value(e, t) {
      if ('' === this._authKey) return Oe.warn(''.concat(this._className, '._genVideoUrl no authKey!')), '';const n = this.getModule(Bt).getSDKAppID();return 'https://'.concat(this._bdh_download_server, '/asn.com/stddownload_common_file?authkey=').concat(this._authKey, '&bid=')
        .concat(this._BDHBizID, '&subbid=')
        .concat(n, '&fileid=')
        .concat(e, '&filetype=')
        .concat(this.FILETYPE.VIDEO, '&openid=')
        .concat(t, '&ver=0');
    } }, { key: 'reset', value() {
      Oe.log(''.concat(this._className, '.reset')), this._authKey = '', this.expireTime = 0;
    } }]), a;
  }(sn)); const nc = (function (e) {
    i(a, e);const n = f(a);function a(e) {
      let o;return t(this, a), (o = n.call(this, e))._className = 'UploadModule', o.TIMUploadPlugin = null, o.timUploadPlugin = null, o.COSSDK = null, o._cosUploadMethod = null, o.expiredTimeLimit = 600, o.appid = 0, o.bucketName = '', o.ciUrl = '', o.directory = '', o.downloadUrl = '', o.uploadUrl = '', o.region = 'ap-shanghai', o.cos = null, o.cosOptions = { secretId: '', secretKey: '', sessionToken: '', expiredTime: 0 }, o.uploadFileType = '', o.duration = 900, o.tryCount = 0, o.getInnerEmitterInstance().on(ii, o._init, h(o)), o;
    } return o(a, [{ key: '_init', value() {
      const e = ''.concat(this._className, '._init'); const t = this.getModule(zt);if (this.TIMUploadPlugin = t.getPlugin('tim-upload-plugin'), this.TIMUploadPlugin) this._initUploaderMethod();else {
        const n = ee ? 'cos-wx-sdk' : 'cos-js-sdk';this.COSSDK = t.getPlugin(n), this.COSSDK ? (this._getAuthorizationKey(), Oe.warn(''.concat(e, ' v2.9.2起推荐使用 tim-upload-plugin 代替 ').concat(n, '，上传更快更安全。详细请参考 https://web.sdk.qcloud.com/im/doc/zh-cn/SDK.html#registerPlugin'))) : Oe.warn(''.concat(e, ' 没有检测到上传插件，将无法发送图片、音频、视频、文件等类型的消息。详细请参考 https://web.sdk.qcloud.com/im/doc/zh-cn/SDK.html#registerPlugin'));
      }
    } }, { key: '_getAuthorizationKey', value() {
      const e = this; const t = new Xa(ls); const n = Math.ceil(Date.now() / 1e3);this.request({ protocolName: lo, requestData: { duration: this.expiredTimeLimit } }).then(((o) => {
        const a = o.data;Oe.log(''.concat(e._className, '._getAuthorizationKey ok. data:'), a);const s = a.expiredTime - n;t.setMessage('requestId:'.concat(a.requestId, ' requestTime:').concat(n, ' expiredTime:')
          .concat(a.expiredTime, ' diff:')
          .concat(s, 's')).setNetworkType(e.getNetworkType())
          .end(), !ee && a.region && (e.region = a.region), e.appid = a.appid, e.bucketName = a.bucketName, e.ciUrl = a.ciUrl, e.directory = a.directory, e.downloadUrl = a.downloadUrl, e.uploadUrl = a.uploadUrl, e.cosOptions = { secretId: a.secretId, secretKey: a.secretKey, sessionToken: a.sessionToken, expiredTime: a.expiredTime }, Oe.log(''.concat(e._className, '._getAuthorizationKey ok. region:').concat(e.region, ' bucketName:')
          .concat(e.bucketName)), e._initUploaderMethod();
      }))
        .catch(((n) => {
          e.probeNetwork().then(((e) => {
            const o = m(e, 2); const a = o[0]; const s = o[1];t.setError(n, a, s).end();
          })), Oe.warn(''.concat(e._className, '._getAuthorizationKey failed. error:'), n);
        }));
    } }, { key: '_getCosPreSigUrl', value(e) {
      const t = this; const n = ''.concat(this._className, '._getCosPreSigUrl'); const o = Math.ceil(Date.now() / 1e3); const a = new Xa(ds);return this.request({ protocolName: po, requestData: { fileType: e.fileType, fileName: e.fileName, uploadMethod: e.uploadMethod, duration: e.duration } }).then(((e) => {
        t.tryCount = 0;const s = e.data || {}; const r = s.expiredTime - o;return Oe.log(''.concat(n, ' ok. data:'), s), a.setMessage('requestId:'.concat(s.requestId, ' expiredTime:').concat(s.expiredTime, ' diff:')
          .concat(r, 's')).setNetworkType(t.getNetworkType())
          .end(), s;
      }))
        .catch((o => (-1 === o.code && (o.code = Do.COS_GET_SIG_FAIL), t.probeNetwork().then(((e) => {
          const t = m(e, 2); const n = t[0]; const s = t[1];a.setError(o, n, s).end();
        })), Oe.warn(''.concat(n, ' failed. error:'), o), t.tryCount < 1 ? (t.tryCount++, t._getCosPreSigUrl(e)) : (t.tryCount = 0, ai({ code: Do.COS_GET_SIG_FAIL, message: wo })))));
    } }, { key: '_initUploaderMethod', value() {
      const e = this;if (this.TIMUploadPlugin) return this.timUploadPlugin = new this.TIMUploadPlugin, void (this._cosUploadMethod = function (t, n) {
        e.timUploadPlugin.uploadFile(t, n);
      });this.appid && (this.cos = ee ? new this.COSSDK({ ForcePathStyle: !0, getAuthorization: this._getAuthorization.bind(this) }) : new this.COSSDK({ getAuthorization: this._getAuthorization.bind(this) }), this._cosUploadMethod = ee ? function (t, n) {
        e.cos.postObject(t, n);
      } : function (t, n) {
        e.cos.uploadFiles(t, n);
      });
    } }, { key: 'onCheckTimer', value(e) {
      this.COSSDK && (this.TIMUploadPlugin || this.isLoggedIn() && e % 60 == 0 && Math.ceil(Date.now() / 1e3) >= this.cosOptions.expiredTime - 120 && this._getAuthorizationKey());
    } }, { key: '_getAuthorization', value(e, t) {
      t({ TmpSecretId: this.cosOptions.secretId, TmpSecretKey: this.cosOptions.secretKey, XCosSecurityToken: this.cosOptions.sessionToken, ExpiredTime: this.cosOptions.expiredTime });
    } }, { key: 'upload', value(e) {
      if (!0 === e.getRelayFlag()) return Promise.resolve();const t = this.getModule(on);switch (e.type) {
        case k.MSG_IMAGE:return t.addTotalCount(Ba), this._uploadImage(e);case k.MSG_FILE:return t.addTotalCount(Ba), this._uploadFile(e);case k.MSG_AUDIO:return t.addTotalCount(Ba), this._uploadAudio(e);case k.MSG_VIDEO:return t.addTotalCount(Ba), this._uploadVideo(e);default:return Promise.resolve();
      }
    } }, { key: '_uploadImage', value(e) {
      const t = this.getModule(Pt); const n = e.getElements()[0]; const o = t.getMessageOptionByID(e.ID);return this.doUploadImage({ file: o.payload.file, to: o.to, onProgress(e) {
        if (n.updatePercent(e), Ke(o.onProgress)) try {
          o.onProgress(e);
        } catch (t) {
          return ai({ code: Do.MESSAGE_ONPROGRESS_FUNCTION_ERROR, message: qo });
        }
      } }).then(((t) => {
        const o = t.location; const a = t.fileType; const s = t.fileSize; const i = t.width; const c = t.height; const u = ot(o);n.updateImageFormat(a);const l = ht({ originUrl: u, originWidth: i, originHeight: c, min: 198 }); const d = ht({ originUrl: u, originWidth: i, originHeight: c, min: 720 });return n.updateImageInfoArray([{ size: s, url: u, width: i, height: c }, r({}, d), r({}, l)]), e;
      }));
    } }, { key: '_uploadFile', value(e) {
      const t = this.getModule(Pt); const n = e.getElements()[0]; const o = t.getMessageOptionByID(e.ID);return this.doUploadFile({ file: o.payload.file, to: o.to, onProgress(e) {
        if (n.updatePercent(e), Ke(o.onProgress)) try {
          o.onProgress(e);
        } catch (t) {
          return ai({ code: Do.MESSAGE_ONPROGRESS_FUNCTION_ERROR, message: qo });
        }
      } }).then(((t) => {
        const o = t.location; const a = ot(o);return n.updateFileUrl(a), e;
      }));
    } }, { key: '_uploadAudio', value(e) {
      const t = this.getModule(Pt); const n = e.getElements()[0]; const o = t.getMessageOptionByID(e.ID);return this.doUploadAudio({ file: o.payload.file, to: o.to, onProgress(e) {
        if (n.updatePercent(e), Ke(o.onProgress)) try {
          o.onProgress(e);
        } catch (t) {
          return ai({ code: Do.MESSAGE_ONPROGRESS_FUNCTION_ERROR, message: qo });
        }
      } }).then(((t) => {
        const o = t.location; const a = ot(o);return n.updateAudioUrl(a), e;
      }));
    } }, { key: '_uploadVideo', value(e) {
      const t = this.getModule(Pt); const n = e.getElements()[0]; const o = t.getMessageOptionByID(e.ID);return this.doUploadVideo({ file: o.payload.file, to: o.to, onProgress(e) {
        if (n.updatePercent(e), Ke(o.onProgress)) try {
          o.onProgress(e);
        } catch (t) {
          return ai({ code: Do.MESSAGE_ONPROGRESS_FUNCTION_ERROR, message: qo });
        }
      } }).then(((t) => {
        const o = ot(t.location);return n.updateVideoUrl(o), e;
      }));
    } }, { key: 'doUploadImage', value(e) {
      if (!e.file) return ai({ code: Do.MESSAGE_IMAGE_SELECT_FILE_FIRST, message: Bo });let t = this._checkImageType(e.file);if (!0 !== t) return t;const n = this._checkImageSize(e.file);if (!0 !== n) return n;let o = null;return this._setUploadFileType(gi), this.uploadByCOS(e).then((e => (o = e, t = 'https://'.concat(e.location), ee ? new Promise(((e, n) => {
        ne.getImageInfo({ src: t, success(t) {
          e({ width: t.width, height: t.height });
        }, fail() {
          e({ width: 0, height: 0 });
        } });
      })) : he && 9 === _e ? Promise.resolve({ width: 0, height: 0 }) : new Promise(((e, n) => {
        let o = new Image;o.onload = function () {
          e({ width: this.width, height: this.height }), o = null;
        }, o.onerror = function () {
          e({ width: 0, height: 0 }), o = null;
        }, o.src = t;
      })))))
        .then((e => (o.width = e.width, o.height = e.height, Promise.resolve(o))));
    } }, { key: '_checkImageType', value(e) {
      let t = '';return t = ee ? e.url.slice(e.url.lastIndexOf('.') + 1) : e.files[0].name.slice(e.files[0].name.lastIndexOf('.') + 1), di.indexOf(t.toLowerCase()) >= 0 || ai({ code: Do.MESSAGE_IMAGE_TYPES_LIMIT, message: Ho });
    } }, { key: '_checkImageSize', value(e) {
      let t = 0;return 0 === (t = ee ? e.size : e.files[0].size) ? ai({ code: Do.MESSAGE_FILE_IS_EMPTY, message: ''.concat(Fo) }) : t < 20971520 || ai({ code: Do.MESSAGE_IMAGE_SIZE_LIMIT, message: ''.concat(jo) });
    } }, { key: 'doUploadFile', value(e) {
      let t = null;return e.file ? e.file.files[0].size > 104857600 ? ai(t = { code: Do.MESSAGE_FILE_SIZE_LIMIT, message: Zo }) : 0 === e.file.files[0].size ? (t = { code: Do.MESSAGE_FILE_IS_EMPTY, message: ''.concat(Fo) }, ai(t)) : (this._setUploadFileType(fi), this.uploadByCOS(e)) : ai(t = { code: Do.MESSAGE_FILE_SELECT_FILE_FIRST, message: Qo });
    } }, { key: 'doUploadVideo', value(e) {
      return e.file.videoFile.size > 104857600 ? ai({ code: Do.MESSAGE_VIDEO_SIZE_LIMIT, message: ''.concat(zo) }) : 0 === e.file.videoFile.size ? ai({ code: Do.MESSAGE_FILE_IS_EMPTY, message: ''.concat(Fo) }) : -1 === pi.indexOf(e.file.videoFile.type) ? ai({ code: Do.MESSAGE_VIDEO_TYPES_LIMIT, message: ''.concat(Jo) }) : (this._setUploadFileType(hi), ee ? this.handleVideoUpload({ file: e.file.videoFile, onProgress: e.onProgress }) : te ? this.handleVideoUpload(e) : void 0);
    } }, { key: 'handleVideoUpload', value(e) {
      const t = this;return new Promise(((n, o) => {
        t.uploadByCOS(e).then(((e) => {
          n(e);
        }))
          .catch((() => {
            t.uploadByCOS(e).then(((e) => {
              n(e);
            }))
              .catch((() => {
                o(new ei({ code: Do.MESSAGE_VIDEO_UPLOAD_FAIL, message: $o }));
              }));
          }));
      }));
    } }, { key: 'doUploadAudio', value(e) {
      return e.file ? e.file.size > 20971520 ? ai(new ei({ code: Do.MESSAGE_AUDIO_SIZE_LIMIT, message: ''.concat(Yo) })) : 0 === e.file.size ? ai(new ei({ code: Do.MESSAGE_FILE_IS_EMPTY, message: ''.concat(Fo) })) : (this._setUploadFileType(_i), this.uploadByCOS(e)) : ai(new ei({ code: Do.MESSAGE_AUDIO_UPLOAD_FAIL, message: Wo }));
    } }, { key: 'uploadByCOS', value(e) {
      const t = this; const n = ''.concat(this._className, '.uploadByCOS');if (!Ke(this._cosUploadMethod)) return Oe.warn(''.concat(n, ' 没有检测到上传插件，将无法发送图片、音频、视频、文件等类型的消息。详细请参考 https://web.sdk.qcloud.com/im/doc/zh-cn/SDK.html#registerPlugin')), ai({ code: Do.COS_UNDETECTED, message: Go });if (this.timUploadPlugin) return this._uploadWithPreSigUrl(e);const o = new Xa(ps); const a = Date.now(); const s = this._getFile(e);return new Promise(((r, i) => {
        const c = ee ? t._createCosOptionsWXMiniApp(e) : t._createCosOptionsWeb(e); const u = t;t._cosUploadMethod(c, ((e, c) => {
          const l = Object.create(null);if (c) {
            if (e || Fe(c.files) && c.files[0].error) {
              const d = new ei({ code: Do.MESSAGE_FILE_UPLOAD_FAIL, message: Xo });return o.setError(d, !0, t.getNetworkType()).end(), Oe.log(''.concat(n, ' failed. error:'), c.files[0].error), 403 === c.files[0].error.statusCode && (Oe.warn(''.concat(n, ' failed. cos AccessKeyId was invalid, regain auth key!')), t._getAuthorizationKey()), void i(d);
            }l.fileName = s.name, l.fileSize = s.size, l.fileType = s.type.slice(s.type.indexOf('/') + 1).toLowerCase(), l.location = ee ? c.Location : c.files[0].data.Location;const p = Date.now() - a; const g = u._formatFileSize(s.size); const h = u._formatSpeed(1e3 * s.size / p); const _ = 'size:'.concat(g, ' time:').concat(p, 'ms speed:')
              .concat(h);Oe.log(''.concat(n, ' success. name:').concat(s.name, ' ')
              .concat(_)), r(l);const f = t.getModule(on);return f.addCost(Ba, p), f.addFileSize(Ba, s.size), void o.setNetworkType(t.getNetworkType()).setMessage(_)
              .end();
          } const m = new ei({ code: Do.MESSAGE_FILE_UPLOAD_FAIL, message: Xo });o.setError(m, !0, u.getNetworkType()).end(), Oe.warn(''.concat(n, ' failed. error:'), e), 403 === e.statusCode && (Oe.warn(''.concat(n, ' failed. cos AccessKeyId was invalid, regain auth key!')), t._getAuthorizationKey()), i(m);
        }));
      }));
    } }, { key: '_uploadWithPreSigUrl', value(e) {
      const t = this; const n = ''.concat(this._className, '._uploadWithPreSigUrl'); const o = this._getFile(e);return this._createCosOptionsPreSigUrl(e).then((e => new Promise(((a, s) => {
        const r = new Xa(ps); const i = Date.now();t._cosUploadMethod(e, ((e, c) => {
          const u = Object.create(null);if (e || 403 === c.statusCode) {
            const l = new ei({ code: Do.MESSAGE_FILE_UPLOAD_FAIL, message: Xo });return r.setError(l, !0, t.getNetworkType()).end(), Oe.log(''.concat(n, ' failed, error:'), e), void s(l);
          } let d = c.data.location || '';0 !== d.indexOf('https://') && 0 !== d.indexOf('http://') || (d = d.split('//')[1]), u.fileName = o.name, u.fileSize = o.size, u.fileType = o.type.slice(o.type.indexOf('/') + 1).toLowerCase(), u.location = d;const p = Date.now() - i; const g = t._formatFileSize(o.size); const h = t._formatSpeed(1e3 * o.size / p); const _ = 'size:'.concat(g, ',time:').concat(p, 'ms,speed:')
            .concat(h, ' res:')
            .concat(JSON.stringify(c.data));Oe.log(''.concat(n, ' success name:').concat(o.name, ',')
            .concat(_)), r.setNetworkType(t.getNetworkType()).setMessage(_)
            .end();const f = t.getModule(on);f.addCost(Ba, p), f.addFileSize(Ba, o.size), a(u);
        }));
      }))));
    } }, { key: '_getFile', value(e) {
      let t = null;return ee ? t = Z && Fe(e.file.files) ? e.file.files[0] : e.file : te && (t = e.file.files[0]), t;
    } }, { key: '_formatFileSize', value(e) {
      return e < 1024 ? `${e}B` : e < 1048576 ? `${Math.floor(e / 1024)}KB` : `${Math.floor(e / 1048576)}MB`;
    } }, { key: '_formatSpeed', value(e) {
      return e <= 1048576 ? `${mt(e / 1024, 1)}KB/s` : `${mt(e / 1048576, 1)}MB/s`;
    } }, { key: '_createCosOptionsWeb', value(e) {
      const t = e.file.files[0].name; const n = t.slice(t.lastIndexOf('.')); const o = this._genFileName(''.concat(Je(999999)).concat(n));return { files: [{ Bucket: ''.concat(this.bucketName, '-').concat(this.appid), Region: this.region, Key: ''.concat(this.directory, '/').concat(o), Body: e.file.files[0] }], SliceSize: 1048576, onProgress(t) {
        if ('function' === typeof e.onProgress) try {
          e.onProgress(t.percent);
        } catch (n) {
          Oe.warn('onProgress callback error:', n);
        }
      }, onFileFinish(e, t, n) {} };
    } }, { key: '_createCosOptionsWXMiniApp', value(e) {
      const t = this._getFile(e); const n = this._genFileName(t.name); const o = t.url;return { Bucket: ''.concat(this.bucketName, '-').concat(this.appid), Region: this.region, Key: ''.concat(this.directory, '/').concat(n), FilePath: o, onProgress(t) {
        if (Oe.log(JSON.stringify(t)), 'function' === typeof e.onProgress) try {
          e.onProgress(t.percent);
        } catch (n) {
          Oe.warn('onProgress callback error:', n);
        }
      } };
    } }, { key: '_createCosOptionsPreSigUrl', value(e) {
      const t = this; let n = ''; let o = ''; let a = 0;if (ee) {
        const s = this._getFile(e);n = this._genFileName(s.name), o = s.url, a = 1;
      } else {
        const r = e.file.files[0].name; const i = r.slice(r.lastIndexOf('.'));n = this._genFileName(''.concat(Je(999999)).concat(i)), o = e.file.files[0], a = 0;
      } return this._getCosPreSigUrl({ fileType: this.uploadFileType, fileName: n, uploadMethod: a, duration: this.duration }).then(((a) => {
        const s = a.uploadUrl; const r = a.downloadUrl;return { url: s, fileType: t.uploadFileType, fileName: n, resources: o, downloadUrl: r, onProgress(t) {
          if ('function' === typeof e.onProgress) try {
            e.onProgress(t.percent);
          } catch (n) {
            Oe.warn('onProgress callback error:', n), Oe.error(n);
          }
        } };
      }));
    } }, { key: '_genFileName', value(e) {
      return ''.concat(pt(), '-').concat(e);
    } }, { key: '_setUploadFileType', value(e) {
      this.uploadFileType = e;
    } }, { key: 'reset', value() {
      Oe.log(''.concat(this._className, '.reset'));
    } }]), a;
  }(sn)); const oc = (function () {
    function e(n) {
      t(this, e), this._className = 'MergerMessageHandler', this._messageModule = n;
    } return o(e, [{ key: 'uploadMergerMessage', value(e, t) {
      const n = this;Oe.debug(''.concat(this._className, '.uploadMergerMessage message:'), e, 'messageBytes:'.concat(t));const o = e.payload.messageList; const a = o.length; const s = new Xa(Cs);return this._messageModule.request({ protocolName: Mo, requestData: { messageList: o } }).then(((e) => {
        Oe.debug(''.concat(n._className, '.uploadMergerMessage ok. response:'), e.data);const o = e.data; const r = o.pbDownloadKey; const i = o.downloadKey; const c = { pbDownloadKey: r, downloadKey: i, messageNumber: a };return s.setNetworkType(n._messageModule.getNetworkType()).setMessage(''.concat(a, '-').concat(t, '-')
          .concat(i))
          .end(), c;
      }))
        .catch(((e) => {
          throw Oe.warn(''.concat(n._className, '.uploadMergerMessage failed. error:'), e), n._messageModule.probeNetwork().then(((t) => {
            const n = m(t, 2); const o = n[0]; const a = n[1];s.setError(e, o, a).end();
          })), e;
        }));
    } }, { key: 'downloadMergerMessage', value(e) {
      const t = this;Oe.debug(''.concat(this._className, '.downloadMergerMessage message:'), e);const n = e.payload.downloadKey; const o = new Xa(Ts);return o.setMessage('downloadKey:'.concat(n)), this._messageModule.request({ protocolName: vo, requestData: { downloadKey: n } }).then(((n) => {
        if (Oe.debug(''.concat(t._className, '.downloadMergerMessage ok. response:'), n.data), Ke(e.clearElement)) {
          const a = e.payload; const s = (a.downloadKey, a.pbDownloadKey, a.messageList, g(a, ['downloadKey', 'pbDownloadKey', 'messageList']));e.clearElement(), e.setElement({ type: e.type, content: r({ messageList: n.data.messageList }, s) });
        } else {
          const i = [];n.data.messageList.forEach(((e) => {
            if (!It(e)) {
              const t = new Hr(e);i.push(t);
            }
          })), e.payload.messageList = i, e.payload.downloadKey = '', e.payload.pbDownloadKey = '';
        } return o.setNetworkType(t._messageModule.getNetworkType()).end(), e;
      }))
        .catch(((e) => {
          throw Oe.warn(''.concat(t._className, '.downloadMergerMessage failed. key:').concat(n, ' error:'), e), t._messageModule.probeNetwork().then(((t) => {
            const n = m(t, 2); const a = n[0]; const s = n[1];o.setError(e, a, s).end();
          })), e;
        }));
    } }, { key: 'createMergerMessagePack', value(e, t, n) {
      return e.conversationType === k.CONV_C2C ? this._createC2CMergerMessagePack(e, t, n) : this._createGroupMergerMessagePack(e, t, n);
    } }, { key: '_createC2CMergerMessagePack', value(e, t, n) {
      let o = null;t && (t.offlinePushInfo && (o = t.offlinePushInfo), !0 === t.onlineUserOnly && (o ? o.disablePush = !0 : o = { disablePush: !0 }));let a = '';be(e.cloudCustomData) && e.cloudCustomData.length > 0 && (a = e.cloudCustomData);const s = n.pbDownloadKey; const r = n.downloadKey; const i = n.messageNumber; const c = e.payload; const u = c.title; const l = c.abstractList; const d = c.compatibleText; const p = this._messageModule.getModule(Ft);return { protocolName: gn, tjgID: this._messageModule.generateTjgID(e), requestData: { fromAccount: this._messageModule.getMyUserID(), toAccount: e.to, msgBody: [{ msgType: e.type, msgContent: { pbDownloadKey: s, downloadKey: r, title: u, abstractList: l, compatibleText: d, messageNumber: i } }], cloudCustomData: a, msgSeq: e.sequence, msgRandom: e.random, msgLifeTime: p && p.isOnlineMessage(e, t) ? 0 : void 0, offlinePushInfo: o ? { pushFlag: !0 === o.disablePush ? 1 : 0, title: o.title || '', desc: o.description || '', ext: o.extension || '', apnsInfo: { badgeMode: !0 === o.ignoreIOSBadge ? 1 : 0 }, androidInfo: { OPPOChannelID: o.androidOPPOChannelID || '' } } : void 0 } };
    } }, { key: '_createGroupMergerMessagePack', value(e, t, n) {
      let o = null;t && t.offlinePushInfo && (o = t.offlinePushInfo);let a = '';be(e.cloudCustomData) && e.cloudCustomData.length > 0 && (a = e.cloudCustomData);const s = n.pbDownloadKey; const r = n.downloadKey; const i = n.messageNumber; const c = e.payload; const u = c.title; const l = c.abstractList; const d = c.compatibleText; const p = this._messageModule.getModule(qt);return { protocolName: hn, tjgID: this._messageModule.generateTjgID(e), requestData: { fromAccount: this._messageModule.getMyUserID(), groupID: e.to, msgBody: [{ msgType: e.type, msgContent: { pbDownloadKey: s, downloadKey: r, title: u, abstractList: l, compatibleText: d, messageNumber: i } }], random: e.random, priority: e.priority, clientSequence: e.clientSequence, groupAtInfo: void 0, cloudCustomData: a, onlineOnlyFlag: p && p.isOnlineMessage(e, t) ? 1 : 0, offlinePushInfo: o ? { pushFlag: !0 === o.disablePush ? 1 : 0, title: o.title || '', desc: o.description || '', ext: o.extension || '', apnsInfo: { badgeMode: !0 === o.ignoreIOSBadge ? 1 : 0 }, androidInfo: { OPPOChannelID: o.androidOPPOChannelID || '' } } : void 0 } };
    } }]), e;
  }()); const ac = { ERR_SVR_COMM_SENSITIVE_TEXT: 80001, ERR_SVR_COMM_BODY_SIZE_LIMIT: 80002, OPEN_SERVICE_OVERLOAD_ERROR: 60022, ERR_SVR_MSG_PKG_PARSE_FAILED: 20001, ERR_SVR_MSG_INTERNAL_AUTH_FAILED: 20002, ERR_SVR_MSG_INVALID_ID: 20003, ERR_SVR_MSG_PUSH_DENY: 20006, ERR_SVR_MSG_IN_PEER_BLACKLIST: 20007, ERR_SVR_MSG_BOTH_NOT_FRIEND: 20009, ERR_SVR_MSG_NOT_PEER_FRIEND: 20010, ERR_SVR_MSG_NOT_SELF_FRIEND: 20011, ERR_SVR_MSG_SHUTUP_DENY: 20012, ERR_SVR_GROUP_INVALID_PARAMETERS: 10004, ERR_SVR_GROUP_PERMISSION_DENY: 10007, ERR_SVR_GROUP_NOT_FOUND: 10010, ERR_SVR_GROUP_INVALID_GROUPID: 10015, ERR_SVR_GROUP_REJECT_FROM_THIRDPARTY: 10016, ERR_SVR_GROUP_SHUTUP_DENY: 10017, MESSAGE_SEND_FAIL: 2100, OVER_FREQUENCY_LIMIT: 2996 }; const sc = [Do.MESSAGE_ONPROGRESS_FUNCTION_ERROR, Do.MESSAGE_IMAGE_SELECT_FILE_FIRST, Do.MESSAGE_IMAGE_TYPES_LIMIT, Do.MESSAGE_FILE_IS_EMPTY, Do.MESSAGE_IMAGE_SIZE_LIMIT, Do.MESSAGE_FILE_SELECT_FILE_FIRST, Do.MESSAGE_FILE_SIZE_LIMIT, Do.MESSAGE_VIDEO_SIZE_LIMIT, Do.MESSAGE_VIDEO_TYPES_LIMIT, Do.MESSAGE_AUDIO_UPLOAD_FAIL, Do.MESSAGE_AUDIO_SIZE_LIMIT, Do.COS_UNDETECTED];const rc = (function (e) {
    i(a, e);const n = f(a);function a(e) {
      let o;return t(this, a), (o = n.call(this, e))._className = 'MessageModule', o._messageOptionsMap = new Map, o._mergerMessageHandler = new oc(h(o)), o;
    } return o(a, [{ key: 'createTextMessage', value(e) {
      const t = this.getMyUserID();e.currentUser = t;const n = new Yr(e); const o = 'string' === typeof e.payload ? e.payload : e.payload.text; const a = new Dr({ text: o }); const s = this._getNickAndAvatarByUserID(t);return n.setElement(a), n.setNickAndAvatar(s), n.setNameCard(this._getNameCardByGroupID(n)), n;
    } }, { key: 'createImageMessage', value(e) {
      const t = this.getMyUserID();e.currentUser = t;const n = new Yr(e);if (ee) {
        const o = e.payload.file;if (Ge(o)) return void Oe.warn('小程序环境下调用 createImageMessage 接口时，payload.file 不支持传入 File 对象');const a = o.tempFilePaths[0]; const s = { url: a, name: a.slice(a.lastIndexOf('/') + 1), size: o.tempFiles && o.tempFiles[0].size || 1, type: a.slice(a.lastIndexOf('.') + 1).toLowerCase() };e.payload.file = s;
      } else if (te) if (Ge(e.payload.file)) {
        const r = e.payload.file;e.payload.file = { files: [r] };
      } else if (Ue(e.payload.file) && 'undefined' !== typeof uni) {
        const i = e.payload.file.tempFiles[0];e.payload.file = { files: [i] };
      } const c = new Gr({ imageFormat: kr.IMAGE_FORMAT.UNKNOWN, uuid: this._generateUUID(), file: e.payload.file }); const u = this._getNickAndAvatarByUserID(t);return n.setElement(c), n.setNickAndAvatar(u), n.setNameCard(this._getNameCardByGroupID(n)), this._messageOptionsMap.set(n.ID, e), n;
    } }, { key: 'createAudioMessage', value(e) {
      if (ee) {
        const t = e.payload.file;if (ee) {
          const n = { url: t.tempFilePath, name: t.tempFilePath.slice(t.tempFilePath.lastIndexOf('/') + 1), size: t.fileSize, second: parseInt(t.duration) / 1e3, type: t.tempFilePath.slice(t.tempFilePath.lastIndexOf('.') + 1).toLowerCase() };e.payload.file = n;
        } const o = this.getMyUserID();e.currentUser = o;const a = new Yr(e); const s = new br({ second: Math.floor(t.duration / 1e3), size: t.fileSize, url: t.tempFilePath, uuid: this._generateUUID() }); const r = this._getNickAndAvatarByUserID(o);return a.setElement(s), a.setNickAndAvatar(r), a.setNameCard(this._getNameCardByGroupID(a)), this._messageOptionsMap.set(a.ID, e), a;
      }Oe.warn('createAudioMessage 目前只支持小程序环境下发语音消息');
    } }, { key: 'createVideoMessage', value(e) {
      const t = this.getMyUserID();e.currentUser = t, e.payload.file.thumbUrl = 'https://web.sdk.qcloud.com/im/assets/images/transparent.png', e.payload.file.thumbSize = 1668;const n = {};if (ee) {
        if (Q) return void Oe.warn('createVideoMessage 不支持在支付宝小程序环境下使用');if (Ge(e.payload.file)) return void Oe.warn('小程序环境下调用 createVideoMessage 接口时，payload.file 不支持传入 File 对象');const o = e.payload.file;n.url = o.tempFilePath, n.name = o.tempFilePath.slice(o.tempFilePath.lastIndexOf('/') + 1), n.size = o.size, n.second = o.duration, n.type = o.tempFilePath.slice(o.tempFilePath.lastIndexOf('.') + 1).toLowerCase();
      } else if (te) {
        if (Ge(e.payload.file)) {
          const a = e.payload.file;e.payload.file.files = [a];
        } else if (Ue(e.payload.file) && 'undefined' !== typeof uni) {
          const s = e.payload.file.tempFile;e.payload.file.files = [s];
        } const r = e.payload.file;n.url = window.URL.createObjectURL(r.files[0]), n.name = r.files[0].name, n.size = r.files[0].size, n.second = r.files[0].duration || 0, n.type = r.files[0].type.split('/')[1];
      }e.payload.file.videoFile = n;const i = new Yr(e); const c = new xr({ videoFormat: n.type, videoSecond: mt(n.second, 0), videoSize: n.size, remoteVideoUrl: '', videoUrl: n.url, videoUUID: this._generateUUID(), thumbUUID: this._generateUUID(), thumbWidth: e.payload.file.width || 200, thumbHeight: e.payload.file.height || 200, thumbUrl: e.payload.file.thumbUrl, thumbSize: e.payload.file.thumbSize, thumbFormat: e.payload.file.thumbUrl.slice(e.payload.file.thumbUrl.lastIndexOf('.') + 1).toLowerCase() }); const u = this._getNickAndAvatarByUserID(t);return i.setElement(c), i.setNickAndAvatar(u), i.setNameCard(this._getNameCardByGroupID(i)), this._messageOptionsMap.set(i.ID, e), i;
    } }, { key: 'createCustomMessage', value(e) {
      const t = this.getMyUserID();e.currentUser = t;const n = new Yr(e); const o = new Kr({ data: e.payload.data, description: e.payload.description, extension: e.payload.extension }); const a = this._getNickAndAvatarByUserID(t);return n.setElement(o), n.setNickAndAvatar(a), n.setNameCard(this._getNameCardByGroupID(n)), n;
    } }, { key: 'createFaceMessage', value(e) {
      const t = this.getMyUserID();e.currentUser = t;const n = new Yr(e); const o = new wr(e.payload); const a = this._getNickAndAvatarByUserID(t);return n.setElement(o), n.setNickAndAvatar(a), n.setNameCard(this._getNameCardByGroupID(n)), n;
    } }, { key: 'createMergerMessage', value(e) {
      const t = this.getMyUserID();e.currentUser = t;const n = this._getNickAndAvatarByUserID(t); const o = new Yr(e); const a = new jr(e.payload);return o.setElement(a), o.setNickAndAvatar(n), o.setNameCard(this._getNameCardByGroupID(o)), o.setRelayFlag(!0), o;
    } }, { key: 'createForwardMessage', value(e) {
      const t = e.to; const n = e.conversationType; const o = e.priority; const a = e.payload; const s = this.getMyUserID(); const r = this._getNickAndAvatarByUserID(s);if (a.type === k.MSG_GRP_TIP) return ai(new ei({ code: Do.MESSAGE_FORWARD_TYPE_INVALID, message: aa }));const i = { to: t, conversationType: n, conversationID: ''.concat(n).concat(t), priority: o, isPlaceMessage: 0, status: Dt.UNSEND, currentUser: s, cloudCustomData: e.cloudCustomData || a.cloudCustomData || '' }; const c = new Yr(i);return c.setElement(a.getElements()[0]), c.setNickAndAvatar(r), c.setNameCard(this._getNameCardByGroupID(a)), c.setRelayFlag(!0), c;
    } }, { key: 'downloadMergerMessage', value(e) {
      return this._mergerMessageHandler.downloadMergerMessage(e);
    } }, { key: 'createFileMessage', value(e) {
      if (!ee || Z) {
        if (te || Z) if (Ge(e.payload.file)) {
          const t = e.payload.file;e.payload.file = { files: [t] };
        } else if (Ue(e.payload.file) && 'undefined' !== typeof uni) {
          const n = e.payload.file; const o = n.tempFiles; const a = n.files; let s = null;Fe(o) ? s = o[0] : Fe(a) && (s = a[0]), e.payload.file = { files: [s] };
        } const r = this.getMyUserID();e.currentUser = r;const i = new Yr(e); const c = new Vr({ uuid: this._generateUUID(), file: e.payload.file }); const u = this._getNickAndAvatarByUserID(r);return i.setElement(c), i.setNickAndAvatar(u), i.setNameCard(this._getNameCardByGroupID(i)), this._messageOptionsMap.set(i.ID, e), i;
      }Oe.warn('小程序目前不支持选择文件， createFileMessage 接口不可用！');
    } }, { key: 'createLocationMessage', value(e) {
      const t = this.getMyUserID();e.currentUser = t;const n = new Yr(e); const o = new Br(e.payload); const a = this._getNickAndAvatarByUserID(t);return n.setElement(o), n.setNickAndAvatar(a), n.setNameCard(this._getNameCardByGroupID(n)), this._messageOptionsMap.set(n.ID, e), n;
    } }, { key: '_onCannotFindModule', value() {
      return ai({ code: Do.CANNOT_FIND_MODULE, message: Ga });
    } }, { key: 'sendMessageInstance', value(e, t) {
      let n; const o = this; let a = null;switch (e.conversationType) {
        case k.CONV_C2C:if (!(a = this.getModule(Ft))) return this._onCannotFindModule();break;case k.CONV_GROUP:if (!(a = this.getModule(qt))) return this._onCannotFindModule();break;default:return ai({ code: Do.MESSAGE_SEND_INVALID_CONVERSATION_TYPE, message: Uo });
      } const s = this.getModule($t); const r = this.getModule(qt);return s.upload(e).then((() => {
        o._getSendMessageSpecifiedKey(e) === xa && o.getModule(on).addSuccessCount(Ba);return r.guardForAVChatRoom(e).then((() => {
          if (!e.isSendable()) return ai({ code: Do.MESSAGE_FILE_URL_IS_EMPTY, message: ea });o._addSendMessageTotalCount(e), n = Date.now();const s = (function (e) {
            let t = 'utf-8';te && document && (t = document.charset.toLowerCase());let n; let o; let a = 0;if (o = e.length, 'utf-8' === t || 'utf8' === t) for (let s = 0;s < o;s++)(n = e.codePointAt(s)) <= 127 ? a += 1 : n <= 2047 ? a += 2 : n <= 65535 ? a += 3 : (a += 4, s++);else if ('utf-16' === t || 'utf16' === t) for (let r = 0;r < o;r++)(n = e.codePointAt(r)) <= 65535 ? a += 2 : (a += 4, r++);else a = e.replace(/[^\x00-\xff]/g, 'aa').length;return a;
          }(JSON.stringify(e)));return e.type === k.MSG_MERGER && s > 7e3 ? o._mergerMessageHandler.uploadMergerMessage(e, s).then(((n) => {
            const a = o._mergerMessageHandler.createMergerMessagePack(e, t, n);return o.request(a);
          })) : (o.getModule(xt).setMessageRandom(e), e.conversationType === k.CONV_C2C || e.conversationType === k.CONV_GROUP ? a.sendMessage(e, t) : void 0);
        }))
          .then(((s) => {
            const r = s.data; const i = r.time; const c = r.sequence;o._addSendMessageSuccessCount(e, n), o._messageOptionsMap.delete(e.ID);const u = o.getModule(xt);e.status = Dt.SUCCESS, e.time = i;let l = !1;if (e.conversationType === k.CONV_GROUP)e.sequence = c, e.generateMessageID(o.getMyUserID());else if (e.conversationType === k.CONV_C2C) {
              const d = u.getLatestMessageSentByMe(e.conversationID);if (d) {
                const p = d.nick; const g = d.avatar;p === e.nick && g === e.avatar || (l = !0);
              }
            } if (u.appendToMessageList(e), l && u.modifyMessageSentByMe({ conversationID: e.conversationID, latestNick: e.nick, latestAvatar: e.avatar }), a.isOnlineMessage(e, t))e._onlineOnlyFlag = !0;else {
              let h = e;Ue(t) && Ue(t.messageControlInfo) && (!0 === t.messageControlInfo.excludedFromLastMessage && (e._isExcludedFromLastMessage = !0, h = ''), !0 === t.messageControlInfo.excludedFromUnreadCount && (e._isExcludedFromUnreadCount = !0)), u.onMessageSent({ conversationOptionsList: [{ conversationID: e.conversationID, unreadCount: 0, type: e.conversationType, subType: e.conversationSubType, lastMessage: h }] });
            } return e.getRelayFlag() || 'TIMImageElem' !== e.type || _t(e.payload.imageInfoArray), $r({ message: e });
          }));
      }))
        .catch((t => o._onSendMessageFailed(e, t)));
    } }, { key: '_onSendMessageFailed', value(e, t) {
      e.status = Dt.FAIL, this.getModule(xt).deleteMessageRandom(e), this._addSendMessageFailCountOnUser(e, t);const n = new Xa(gs);return n.setMessage('tjg_id:'.concat(this.generateTjgID(e), ' type:').concat(e.type, ' from:')
        .concat(e.from, ' to:')
        .concat(e.to)), this.probeNetwork().then(((e) => {
        const o = m(e, 2); const a = o[0]; const s = o[1];n.setError(t, a, s).end();
      })), Oe.error(''.concat(this._className, '._onSendMessageFailed error:'), t), ai(new ei({ code: t && t.code ? t.code : Do.MESSAGE_SEND_FAIL, message: t && t.message ? t.message : bo, data: { message: e } }));
    } }, { key: '_getSendMessageSpecifiedKey', value(e) {
      if ([k.MSG_IMAGE, k.MSG_AUDIO, k.MSG_VIDEO, k.MSG_FILE].includes(e.type)) return xa;if (e.conversationType === k.CONV_C2C) return qa;if (e.conversationType === k.CONV_GROUP) {
        const t = this.getModule(qt).getLocalGroupProfile(e.to);if (!t) return;const n = t.type;return it(n) ? Ka : Va;
      }
    } }, { key: '_addSendMessageTotalCount', value(e) {
      const t = this._getSendMessageSpecifiedKey(e);t && this.getModule(on).addTotalCount(t);
    } }, { key: '_addSendMessageSuccessCount', value(e, t) {
      const n = Math.abs(Date.now() - t); const o = this._getSendMessageSpecifiedKey(e);if (o) {
        const a = this.getModule(on);a.addSuccessCount(o), a.addCost(o, n);
      }
    } }, { key: '_addSendMessageFailCountOnUser', value(e, t) {
      let n; let o; const a = t.code; const s = void 0 === a ? -1 : a; const r = this.getModule(on); const i = this._getSendMessageSpecifiedKey(e);i === xa && (n = s, o = !1, sc.includes(n) && (o = !0), o) ? r.addFailedCountOfUserSide(Ba) : (function (e) {
        let t = !1;return Object.values(ac).includes(e) && (t = !0), (e >= 120001 && e <= 13e4 || e >= 10100 && e <= 10200) && (t = !0), t;
      }(s)) && i && r.addFailedCountOfUserSide(i);
    } }, { key: 'resendMessage', value(e) {
      return e.isResend = !0, e.status = Dt.UNSEND, e.random = Je(), e.generateMessageID(this.getMyUserID()), this.sendMessageInstance(e);
    } }, { key: 'revokeMessage', value(e) {
      const t = this; let n = null;if (e.conversationType === k.CONV_C2C) {
        if (!(n = this.getModule(Ft))) return this._onCannotFindModule();
      } else if (e.conversationType === k.CONV_GROUP && !(n = this.getModule(qt))) return this._onCannotFindModule();const o = new Xa(fs);return o.setMessage('tjg_id:'.concat(this.generateTjgID(e), ' type:').concat(e.type, ' from:')
        .concat(e.from, ' to:')
        .concat(e.to)), n.revokeMessage(e).then(((n) => {
        const a = n.data.recallRetList;if (!It(a) && 0 !== a[0].retCode) {
          const s = new ei({ code: a[0].retCode, message: Zr[a[0].retCode] || Vo, data: { message: e } });return o.setCode(s.code).setMoreMessage(s.message)
            .end(), ai(s);
        } return Oe.info(''.concat(t._className, '.revokeMessage ok. ID:').concat(e.ID)), e.isRevoked = !0, o.end(), t.getModule(xt).onMessageRevoked([e]), $r({ message: e });
      }))
        .catch(((n) => {
          t.probeNetwork().then(((e) => {
            const t = m(e, 2); const a = t[0]; const s = t[1];o.setError(n, a, s).end();
          }));const a = new ei({ code: n && n.code ? n.code : Do.MESSAGE_REVOKE_FAIL, message: n && n.message ? n.message : Vo, data: { message: e } });return Oe.warn(''.concat(t._className, '.revokeMessage failed. error:'), n), ai(a);
        }));
    } }, { key: 'deleteMessage', value(e) {
      const t = this; let n = null; const o = e[0]; const a = o.conversationID; let s = ''; let r = []; let i = [];if (o.conversationType === k.CONV_C2C ? (n = this.getModule(Ft), s = a.replace(k.CONV_C2C, ''), e.forEach(((e) => {
        e && e.status === Dt.SUCCESS && e.conversationID === a && (e._onlineOnlyFlag || r.push(''.concat(e.sequence, '_').concat(e.random, '_')
          .concat(e.time)), i.push(e));
      }))) : o.conversationType === k.CONV_GROUP && (n = this.getModule(qt), s = a.replace(k.CONV_GROUP, ''), e.forEach(((e) => {
        e && e.status === Dt.SUCCESS && e.conversationID === a && (e._onlineOnlyFlag || r.push(''.concat(e.sequence)), i.push(e));
      }))), !n) return this._onCannotFindModule();if (0 === r.length) return this._onMessageDeleted(i);r.length > 30 && (r = r.slice(0, 30), i = i.slice(0, 30));const c = new Xa(ms);return c.setMessage('to:'.concat(s, ' count:').concat(r.length)), n.deleteMessage({ to: s, keyList: r }).then((e => (c.end(), Oe.info(''.concat(t._className, '.deleteMessage ok')), t._onMessageDeleted(i))))
        .catch(((e) => {
          t.probeNetwork().then(((t) => {
            const n = m(t, 2); const o = n[0]; const a = n[1];c.setError(e, o, a).end();
          })), Oe.warn(''.concat(t._className, '.deleteMessage failed. error:'), e);const n = new ei({ code: e && e.code ? e.code : Do.MESSAGE_DELETE_FAIL, message: e && e.message ? e.message : Ko });return ai(n);
        }));
    } }, { key: '_onMessageDeleted', value(e) {
      return this.getModule(xt).onMessageDeleted(e), oi({ messageList: e });
    } }, { key: '_generateUUID', value() {
      const e = this.getModule(Bt);return ''.concat(e.getSDKAppID(), '-').concat(e.getUserID(), '-')
        .concat(function () {
          for (var e = '', t = 32;t > 0;--t)e += Xe[Math.floor(Math.random() * Qe)];return e;
        }());
    } }, { key: 'getMessageOptionByID', value(e) {
      return this._messageOptionsMap.get(e);
    } }, { key: '_getNickAndAvatarByUserID', value(e) {
      return this.getModule(Ut).getNickAndAvatarByUserID(e);
    } }, { key: '_getNameCardByGroupID', value(e) {
      if (e.conversationType === k.CONV_GROUP) {
        const t = this.getModule(qt);if (t) return t.getMyNameCardByGroupID(e.to);
      } return '';
    } }, { key: 'reset', value() {
      Oe.log(''.concat(this._className, '.reset')), this._messageOptionsMap.clear();
    } }]), a;
  }(sn)); const ic = (function (e) {
    i(a, e);const n = f(a);function a(e) {
      let o;return t(this, a), (o = n.call(this, e))._className = 'PluginModule', o.plugins = {}, o;
    } return o(a, [{ key: 'registerPlugin', value(e) {
      const t = this;Object.keys(e).forEach(((n) => {
        t.plugins[n] = e[n];
      })), new Xa(os).setMessage('key='.concat(Object.keys(e)))
        .end();
    } }, { key: 'getPlugin', value(e) {
      return this.plugins[e];
    } }, { key: 'reset', value() {
      Oe.log(''.concat(this._className, '.reset'));
    } }]), a;
  }(sn)); const cc = (function (e) {
    i(a, e);const n = f(a);function a(e) {
      let o;return t(this, a), (o = n.call(this, e))._className = 'SyncUnreadMessageModule', o._cookie = '', o._onlineSyncFlag = !1, o.getInnerEmitterInstance().on(ii, o._onLoginSuccess, h(o)), o;
    } return o(a, [{ key: '_onLoginSuccess', value(e) {
      this._startSync({ cookie: this._cookie, syncFlag: 0, isOnlineSync: 0 });
    } }, { key: '_startSync', value(e) {
      const t = this; const n = e.cookie; const o = e.syncFlag; const a = e.isOnlineSync;Oe.log(''.concat(this._className, '._startSync cookie:').concat(n, ' syncFlag:')
        .concat(o, ' isOnlineSync:')
        .concat(a)), this.request({ protocolName: dn, requestData: { cookie: n, syncFlag: o, isOnlineSync: a } }).then(((e) => {
        const n = e.data; const o = n.cookie; const a = n.syncFlag; const s = n.eventArray; const r = n.messageList; const i = n.C2CRemainingUnreadList; const c = n.C2CPairUnreadList;if (t._cookie = o, It(o));else if (0 === a || 1 === a) {
          if (s)t.getModule(Xt).onMessage({ head: {}, body: { eventArray: s, isInstantMessage: t._onlineSyncFlag, isSyncingEnded: !1 } });t.getModule(Ft).onNewC2CMessage({ dataList: r, isInstantMessage: !1, C2CRemainingUnreadList: i, C2CPairUnreadList: c }), t._startSync({ cookie: o, syncFlag: a, isOnlineSync: 0 });
        } else if (2 === a) {
          if (s)t.getModule(Xt).onMessage({ head: {}, body: { eventArray: s, isInstantMessage: t._onlineSyncFlag, isSyncingEnded: !0 } });t.getModule(Ft).onNewC2CMessage({ dataList: r, isInstantMessage: t._onlineSyncFlag, C2CRemainingUnreadList: i, C2CPairUnreadList: c });
        }
      }))
        .catch(((e) => {
          Oe.error(''.concat(t._className, '._startSync failed. error:'), e);
        }));
    } }, { key: 'startOnlineSync', value() {
      Oe.log(''.concat(this._className, '.startOnlineSync')), this._onlineSyncFlag = !0, this._startSync({ cookie: this._cookie, syncFlag: 0, isOnlineSync: 1 });
    } }, { key: 'startSyncOnReconnected', value() {
      Oe.log(''.concat(this._className, '.startSyncOnReconnected.')), this._onlineSyncFlag = !0, this._startSync({ cookie: this._cookie, syncFlag: 0, isOnlineSync: 0 });
    } }, { key: 'reset', value() {
      Oe.log(''.concat(this._className, '.reset')), this._onlineSyncFlag = !1, this._cookie = '';
    } }]), a;
  }(sn)); const uc = { request: { toAccount: 'To_Account', fromAccount: 'From_Account', to: 'To_Account', from: 'From_Account', groupID: 'GroupId', groupAtUserID: 'GroupAt_Account', extension: 'Ext', data: 'Data', description: 'Desc', elements: 'MsgBody', sizeType: 'Type', downloadFlag: 'Download_Flag', thumbUUID: 'ThumbUUID', videoUUID: 'VideoUUID', remoteAudioUrl: 'Url', remoteVideoUrl: 'VideoUrl', videoUrl: '', imageUrl: 'URL', fileUrl: 'Url', uuid: 'UUID', priority: 'MsgPriority', receiverUserID: 'To_Account', receiverGroupID: 'GroupId', messageSender: 'SenderId', messageReceiver: 'ReceiverId', nick: 'From_AccountNick', avatar: 'From_AccountHeadurl', messageNumber: 'MsgNum', pbDownloadKey: 'PbMsgKey', downloadKey: 'JsonMsgKey', applicationType: 'PendencyType', userIDList: 'To_Account', groupNameList: 'GroupName', userID: 'To_Account', groupAttributeList: 'GroupAttr', mainSequence: 'AttrMainSeq', avChatRoomKey: 'BytesKey', attributeControl: 'AttrControl', sequence: 'seq', messageControlInfo: 'SendMsgControl', updateSequence: 'UpdateSeq' }, response: { MsgPriority: 'priority', ThumbUUID: 'thumbUUID', VideoUUID: 'videoUUID', Download_Flag: 'downloadFlag', GroupId: 'groupID', Member_Account: 'userID', MsgList: 'messageList', SyncFlag: 'syncFlag', To_Account: 'to', From_Account: 'from', MsgSeq: 'sequence', MsgRandom: 'random', MsgTime: 'time', MsgTimeStamp: 'time', MsgContent: 'content', MsgBody: 'elements', From_AccountNick: 'nick', From_AccountHeadurl: 'avatar', GroupWithdrawInfoArray: 'revokedInfos', GroupReadInfoArray: 'groupMessageReadNotice', LastReadMsgSeq: 'lastMessageSeq', WithdrawC2cMsgNotify: 'c2cMessageRevokedNotify', C2cWithdrawInfoArray: 'revokedInfos', C2cReadedReceipt: 'c2cMessageReadReceipt', ReadC2cMsgNotify: 'c2cMessageReadNotice', LastReadTime: 'peerReadTime', MsgRand: 'random', MsgType: 'type', MsgShow: 'messageShow', NextMsgSeq: 'nextMessageSeq', FaceUrl: 'avatar', ProfileDataMod: 'profileModify', Profile_Account: 'userID', ValueBytes: 'value', ValueNum: 'value', NoticeSeq: 'noticeSequence', NotifySeq: 'notifySequence', MsgFrom_AccountExtraInfo: 'messageFromAccountExtraInformation', Operator_Account: 'operatorID', OpType: 'operationType', ReportType: 'operationType', UserId: 'userID', User_Account: 'userID', List_Account: 'userIDList', MsgOperatorMemberExtraInfo: 'operatorInfo', MsgMemberExtraInfo: 'memberInfoList', ImageUrl: 'avatar', NickName: 'nick', MsgGroupNewInfo: 'newGroupProfile', MsgAppDefinedData: 'groupCustomField', Owner_Account: 'ownerID', GroupFaceUrl: 'avatar', GroupIntroduction: 'introduction', GroupNotification: 'notification', GroupApplyJoinOption: 'joinOption', MsgKey: 'messageKey', GroupInfo: 'groupProfile', ShutupTime: 'muteTime', Desc: 'description', Ext: 'extension', GroupAt_Account: 'groupAtUserID', MsgNum: 'messageNumber', PbMsgKey: 'pbDownloadKey', JsonMsgKey: 'downloadKey', MsgModifiedFlag: 'isModified', PendencyItem: 'applicationItem', PendencyType: 'applicationType', AddTime: 'time', AddSource: 'source', AddWording: 'wording', ProfileImImage: 'avatar', PendencyAdd: 'friendApplicationAdded', FrienPencydDel_Account: 'friendApplicationDeletedUserIDList', Peer_Account: 'userID', GroupAttr: 'groupAttributeList', GroupAttrAry: 'groupAttributeList', AttrMainSeq: 'mainSequence', seq: 'sequence', GroupAttrOption: 'groupAttributeOption', BytesChangedKeys: 'changedKeyList', GroupAttrInfo: 'groupAttributeList', GroupAttrSeq: 'mainSequence', PushChangedAttrValFlag: 'hasChangedAttributeInfo', SubKeySeq: 'sequence', Val: 'value', MsgGroupFromCardName: 'senderNameCard', MsgGroupFromNickName: 'senderNick', C2cNick: 'peerNick', C2cImage: 'peerAvatar', SendMsgControl: 'messageControlInfo', NoLastMsg: 'excludedFromLastMessage', NoUnread: 'excludedFromUnreadCount', UpdateSeq: 'updateSequence', MuteNotifications: 'muteFlag' }, ignoreKeyWord: ['C2C', 'ID', 'USP'] };function lc(e, t) {
    if ('string' !== typeof e && !Array.isArray(e)) throw new TypeError('Expected the input to be `string | string[]`');t = Object.assign({ pascalCase: !1 }, t);let n;return 0 === (e = Array.isArray(e) ? e.map((e => e.trim())).filter((e => e.length))
      .join('-') : e.trim()).length ? '' : 1 === e.length ? t.pascalCase ? e.toUpperCase() : e.toLowerCase() : (e !== e.toLowerCase() && (e = dc(e)), e = e.replace(/^[_.\- ]+/, '').toLowerCase()
        .replace(/[_.\- ]+(\w|$)/g, ((e, t) => t.toUpperCase()))
        .replace(/\d+(\w|$)/g, (e => e.toUpperCase())), n = e, t.pascalCase ? n.charAt(0).toUpperCase() + n.slice(1) : n);
  } var dc = function (e) {
    for (let t = !1, n = !1, o = !1, a = 0;a < e.length;a++) {
      const s = e[a];t && /[a-zA-Z]/.test(s) && s.toUpperCase() === s ? (e = `${e.slice(0, a)}-${e.slice(a)}`, t = !1, o = n, n = !0, a++) : n && o && /[a-zA-Z]/.test(s) && s.toLowerCase() === s ? (e = `${e.slice(0, a - 1)}-${e.slice(a - 1)}`, o = n, n = !1, t = !0) : (t = s.toLowerCase() === s && s.toUpperCase() !== s, o = n, n = s.toUpperCase() === s && s.toLowerCase() !== s);
    } return e;
  };function pc(e, t) {
    let n = 0;return (function e(t, o) {
      if (++n > 100) return n--, t;if (Fe(t)) {
        const a = t.map((t => (Pe(t) ? e(t, o) : t)));return n--, a;
      } if (Pe(t)) {
        let s = (r = t, i = function (e, t) {
          if (!He(t)) return !1;if ((a = t) !== lc(a)) for (let n = 0;n < uc.ignoreKeyWord.length && !t.includes(uc.ignoreKeyWord[n]);n++);let a;return qe(o[t]) ? (function (e) {
            return 'OPPOChannelID' === e ? e : e[0].toUpperCase() + lc(e).slice(1);
          }(t)) : o[t];
        }, c = Object.create(null), Object.keys(r).forEach(((e) => {
          const t = i(r[e], e);t && (c[t] = r[e]);
        })), c);return s = dt(s, ((t, n) => (Fe(t) || Pe(t) ? e(t, o) : t))), n--, s;
      } let r; let i; let c;
    }(e, t));
  } function gc(e, t) {
    if (Fe(e)) return e.map((e => (Pe(e) ? gc(e, t) : e)));if (Pe(e)) {
      let n = (o = e, a = function (e, n) {
        return qe(t[n]) ? lc(n) : t[n];
      }, s = {}, Object.keys(o).forEach(((e) => {
        s[a(o[e], e)] = o[e];
      })), s);return n = dt(n, (e => (Fe(e) || Pe(e) ? gc(e, t) : e)));
    } let o; let a; let s;
  } const hc = String.fromCharCode; const _c = function (e) {
    let t = 0 | e.charCodeAt(0);if (55296 <= t) if (t < 56320) {
      const n = 0 | e.charCodeAt(1);if (56320 <= n && n <= 57343) {
        if ((t = (t << 10) + n - 56613888 | 0) > 65535) return hc(240 | t >>> 18, 128 | t >>> 12 & 63, 128 | t >>> 6 & 63, 128 | 63 & t);
      } else t = 65533;
    } else t <= 57343 && (t = 65533);return t <= 2047 ? hc(192 | t >>> 6, 128 | 63 & t) : hc(224 | t >>> 12, 128 | t >>> 6 & 63, 128 | 63 & t);
  }; const fc = function (e) {
    for (var t = void 0 === e ? '' : (`${e}`).replace(/[\x80-\uD7ff\uDC00-\uFFFF]|[\uD800-\uDBFF][\uDC00-\uDFFF]?/g, _c), n = 0 | t.length, o = new Uint8Array(n), a = 0;a < n;a = a + 1 | 0)o[a] = 0 | t.charCodeAt(a);return o;
  }; const mc = function (e) {
    for (var t = new Uint8Array(e), n = '', o = 0, a = t.length;o < a;) {
      let s = t[o]; let r = 0; let i = 0;if (s <= 127 ? (r = 0, i = 255 & s) : s <= 223 ? (r = 1, i = 31 & s) : s <= 239 ? (r = 2, i = 15 & s) : s <= 244 && (r = 3, i = 7 & s), a - o - r > 0) for (let c = 0;c < r;)i = i << 6 | 63 & (s = t[o + c + 1]), c += 1;else i = 65533, r = a - o;n += String.fromCodePoint(i), o += r + 1;
    } return n;
  }; const Mc = (function () {
    function e(n) {
      t(this, e), this._handler = n;const o = n.getURL();this._socket = null, this._id = Je(), ee ? Q ? (ne.connectSocket({ url: o, header: { 'content-type': 'application/json' } }), ne.onSocketClose(this._onClose.bind(this)), ne.onSocketOpen(this._onOpen.bind(this)), ne.onSocketMessage(this._onMessage.bind(this)), ne.onSocketError(this._onError.bind(this))) : (this._socket = ne.connectSocket({ url: o, header: { 'content-type': 'application/json' }, complete() {} }), this._socket.onClose(this._onClose.bind(this)), this._socket.onOpen(this._onOpen.bind(this)), this._socket.onMessage(this._onMessage.bind(this)), this._socket.onError(this._onError.bind(this))) : te && (this._socket = new WebSocket(o), this._socket.binaryType = 'arraybuffer', this._socket.onopen = this._onOpen.bind(this), this._socket.onmessage = this._onMessage.bind(this), this._socket.onclose = this._onClose.bind(this), this._socket.onerror = this._onError.bind(this));
    } return o(e, [{ key: 'getID', value() {
      return this._id;
    } }, { key: '_onOpen', value() {
      this._handler.onOpen({ id: this._id });
    } }, { key: '_onClose', value(e) {
      this._handler.onClose({ id: this._id, e });
    } }, { key: '_onMessage', value(e) {
      this._handler.onMessage({ data: this._handler.canIUseBinaryFrame() ? mc(e.data) : e.data });
    } }, { key: '_onError', value(e) {
      this._handler.onError({ id: this._id, e });
    } }, { key: 'close', value(e) {
      if (Q) return ne.offSocketClose(), ne.offSocketMessage(), ne.offSocketOpen(), ne.offSocketError(), void ne.closeSocket();this._socket && (ee ? (this._socket.onClose((() => {})), this._socket.onOpen((() => {})), this._socket.onMessage((() => {})), this._socket.onError((() => {}))) : te && (this._socket.onopen = null, this._socket.onmessage = null, this._socket.onclose = null, this._socket.onerror = null), X ? this._socket.close({ code: e }) : this._socket.close(e), this._socket = null);
    } }, { key: 'send', value(e) {
      Q ? ne.sendSocketMessage({ data: e.data, fail() {
        e.fail && e.requestID && e.fail(e.requestID);
      } }) : this._socket && (ee ? this._socket.send({ data: this._handler.canIUseBinaryFrame() ? fc(e.data).buffer : e.data, fail() {
        e.fail && e.requestID && e.fail(e.requestID);
      } }) : te && this._socket.send(this._handler.canIUseBinaryFrame() ? fc(e.data).buffer : e.data));
    } }]), e;
  }()); const vc = 4e3; const yc = 4001; const Ic = 'connected'; const Cc = 'connecting'; const Tc = 'disconnected'; const Sc = (function () {
    function e(n) {
      t(this, e), this._channelModule = n, this._className = 'SocketHandler', this._promiseMap = new Map, this._readyState = Tc, this._simpleRequestMap = new Map, this.MAX_SIZE = 100, this._startSequence = Je(), this._startTs = 0, this._reConnectFlag = !1, this._nextPingTs = 0, this._reConnectCount = 0, this.MAX_RECONNECT_COUNT = 3, this._socketID = -1, this._random = 0, this._socket = null, this._url = '', this._onOpenTs = 0, this._canIUseBinaryFrame = !0, this._setWebsocketHost(), this._initConnection();
    } return o(e, [{ key: '_setWebsocketHost', value() {
      const e = this._channelModule.getModule(Bt); let t = P;this._channelModule.isOversea() && (t = U), e.isSingaporeSite() ? t = F : e.isKoreaSite() ? t = q : e.isGermanySite() ? t = V : e.isIndiaSite() && (t = K), x.HOST.setCurrent(t);
    } }, { key: '_initConnection', value() {
      qe(x.HOST.CURRENT.BACKUP) || '' === this._url ? this._url = x.HOST.CURRENT.DEFAULT : this._url === x.HOST.CURRENT.DEFAULT ? this._url = x.HOST.CURRENT.BACKUP : this._url === x.HOST.CURRENT.BACKUP && (this._url = x.HOST.CURRENT.DEFAULT);const e = this._channelModule.getModule(Bt).getProxyServer();It(e) || (this._url = e), this._connect(), this._nextPingTs = 0;
    } }, { key: 'onCheckTimer', value(e) {
      e % 1 == 0 && this._checkPromiseMap();
    } }, { key: '_checkPromiseMap', value() {
      const e = this;0 !== this._promiseMap.size && this._promiseMap.forEach(((t, n) => {
        const o = t.reject; const a = t.timestamp;Date.now() - a >= 15e3 && (Oe.log(''.concat(e._className, '._checkPromiseMap request timeout, delete requestID:').concat(n)), e._promiseMap.delete(n), o(new ei({ code: Do.NETWORK_TIMEOUT, message: Na })), e._channelModule.onRequestTimeout(n));
      }));
    } }, { key: 'onOpen', value(e) {
      this._onOpenTs = Date.now();const t = e.id;this._socketID = t;const n = Date.now() - this._startTs;Oe.log(''.concat(this._className, '._onOpen cost ').concat(n, ' ms. socketID:')
        .concat(t)), new Xa(rs).setMessage(n)
        .setCostTime(n)
        .setMoreMessage('socketID:'.concat(t))
        .end(), e.id === this._socketID && (this._readyState = Ic, this._reConnectCount = 0, this._resend(), !0 === this._reConnectFlag && (this._channelModule.onReconnected(), this._reConnectFlag = !1), this._channelModule.onOpen());
    } }, { key: 'onClose', value(e) {
      const t = new Xa(is); const n = e.id; const o = e.e; const a = 'sourceSocketID:'.concat(n, ' currentSocketID:').concat(this._socketID, ' code:')
        .concat(o.code, ' reason:')
        .concat(o.reason); let s = 0;0 !== this._onOpenTs && (s = Date.now() - this._onOpenTs), t.setMessage(s).setCostTime(s)
        .setMoreMessage(a)
        .setCode(o.code)
        .end(), Oe.log(''.concat(this._className, '._onClose ').concat(a, ' onlineTime:')
        .concat(s)), n === this._socketID && (this._readyState = Tc, s < 1e3 ? this._channelModule.onReconnectFailed() : this._channelModule.onClose());
    } }, { key: 'onError', value(e) {
      const t = e.id; const n = e.e; const o = 'sourceSocketID:'.concat(t, ' currentSocketID:').concat(this._socketID);new Xa(cs).setMessage(n.errMsg || $e(n))
        .setMoreMessage(o)
        .setLevel('error')
        .end(), Oe.warn(''.concat(this._className, '._onError'), n, o), t === this._socketID && (this._readyState = '', this._channelModule.onError());
    } }, { key: 'onMessage', value(e) {
      let t;try {
        t = JSON.parse(e.data);
      } catch (u) {
        new Xa(Ss).setMessage(e.data)
          .end();
      } if (t && t.head) {
        const n = this._getRequestIDFromHead(t.head); const o = ft(t.head); const a = gc(t.body, this._getResponseKeyMap(o));if (Oe.debug(''.concat(this._className, '.onMessage ret:').concat(JSON.stringify(a), ' requestID:')
          .concat(n, ' has:')
          .concat(this._promiseMap.has(n))), this._setNextPingTs(), this._promiseMap.has(n)) {
          const s = this._promiseMap.get(n); const r = s.resolve; const i = s.reject; const c = s.timestamp;return this._promiseMap.delete(n), this._calcRTT(c), void (a.errorCode && 0 !== a.errorCode ? (this._channelModule.onErrorCodeNotZero(a), i(new ei({ code: a.errorCode, message: a.errorInfo || '' }))) : r($r(a)));
        } this._channelModule.onMessage({ head: t.head, body: a });
      }
    } }, { key: '_calcRTT', value(e) {
      const t = Date.now() - e;this._channelModule.getModule(on).addRTT(t);
    } }, { key: '_connect', value() {
      this._startTs = Date.now(), this._onOpenTs = 0, this._socket = new Mc(this), this._socketID = this._socket.getID(), this._readyState = Cc, Oe.log(''.concat(this._className, '._connect socketID:').concat(this._socketID, ' url:')
        .concat(this.getURL())), new Xa(ss).setMessage('socketID:'.concat(this._socketID, ' url:').concat(this.getURL()))
        .end();
    } }, { key: 'getURL', value() {
      const e = this._channelModule.getModule(Bt);return e.isDevMode() && (this._canIUseBinaryFrame = !1), (Q || $ && 'windows' === gt() || Z) && (this._canIUseBinaryFrame = !1), this._canIUseBinaryFrame ? ''.concat(this._url, '/binfo?sdkappid=').concat(e.getSDKAppID(), '&instanceid=')
        .concat(e.getInstanceID(), '&random=')
        .concat(this._getRandom()) : ''.concat(this._url, '/info?sdkappid=').concat(e.getSDKAppID(), '&instanceid=')
        .concat(e.getInstanceID(), '&random=')
        .concat(this._getRandom());
    } }, { key: '_closeConnection', value(e) {
      Oe.log(''.concat(this._className, '._closeConnection')), this._socket && (this._socket.close(e), this._socketID = -1, this._socket = null, this._readyState = Tc);
    } }, { key: '_resend', value() {
      const e = this;if (Oe.log(''.concat(this._className, '._resend reConnectFlag:').concat(this._reConnectFlag), 'promiseMap.size:'.concat(this._promiseMap.size, ' simpleRequestMap.size:').concat(this._simpleRequestMap.size)), this._promiseMap.size > 0 && this._promiseMap.forEach(((t, n) => {
        const o = t.uplinkData; const a = t.resolve; const s = t.reject;e._promiseMap.set(n, { resolve: a, reject: s, timestamp: Date.now(), uplinkData: o }), e._execute(n, o);
      })), this._simpleRequestMap.size > 0) {
        let t; const n = S(this._simpleRequestMap);try {
          for (n.s();!(t = n.n()).done;) {
            const o = m(t.value, 2); const a = o[0]; const s = o[1];this._execute(a, s);
          }
        } catch (r) {
          n.e(r);
        } finally {
          n.f();
        } this._simpleRequestMap.clear();
      }
    } }, { key: 'send', value(e) {
      const t = this;e.head.seq = this._getSequence(), e.head.reqtime = Math.floor(Date.now() / 1e3);e.keyMap;const n = g(e, ['keyMap']); const o = this._getRequestIDFromHead(e.head); const a = JSON.stringify(n);return new Promise(((e, s) => {
        (t._promiseMap.set(o, { resolve: e, reject: s, timestamp: Date.now(), uplinkData: a }), Oe.debug(''.concat(t._className, '.send uplinkData:').concat(JSON.stringify(n), ' requestID:')
          .concat(o, ' readyState:')
          .concat(t._readyState)), t._readyState !== Ic) ? t._reConnect() : (t._execute(o, a), t._channelModule.getModule(on).addRequestCount());
      }));
    } }, { key: 'simplySend', value(e) {
      e.head.seq = this._getSequence(), e.head.reqtime = Math.floor(Date.now() / 1e3);e.keyMap;const t = g(e, ['keyMap']); const n = this._getRequestIDFromHead(e.head); const o = JSON.stringify(t);this._readyState !== Ic ? (this._simpleRequestMap.size < this.MAX_SIZE ? this._simpleRequestMap.set(n, o) : Oe.log(''.concat(this._className, '.simplySend. simpleRequestMap is full, drop request!')), this._reConnect()) : this._execute(n, o);
    } }, { key: '_execute', value(e, t) {
      this._socket.send({ data: t, fail: ee ? this._onSendFail.bind(this) : void 0, requestID: e });
    } }, { key: '_onSendFail', value(e) {
      Oe.log(''.concat(this._className, '._onSendFail requestID:').concat(e));
    } }, { key: '_getSequence', value() {
      let e;if (this._startSequence < 2415919103) return e = this._startSequence, this._startSequence += 1, 2415919103 === this._startSequence && (this._startSequence = Je()), e;
    } }, { key: '_getRequestIDFromHead', value(e) {
      return e.servcmd + e.seq;
    } }, { key: '_getResponseKeyMap', value(e) {
      const t = this._channelModule.getKeyMap(e);return r(r({}, uc.response), t.response);
    } }, { key: '_reConnect', value() {
      this._readyState !== Ic && this._readyState !== Cc && this.forcedReconnect();
    } }, { key: 'forcedReconnect', value() {
      const e = this;Oe.log(''.concat(this._className, '.forcedReconnect count:').concat(this._reConnectCount, ' readyState:')
        .concat(this._readyState)), this._reConnectFlag = !0, this._resetRandom(), this._reConnectCount < this.MAX_RECONNECT_COUNT ? (this._reConnectCount += 1, this._closeConnection(yc), this._initConnection()) : (this._reConnectCount = 0, this._channelModule.probeNetwork().then(((t) => {
        const n = m(t, 2); const o = n[0];n[1];o ? (Oe.warn(''.concat(e._className, '.forcedReconnect disconnected from wsserver but network is ok, continue...')), e._closeConnection(yc), e._initConnection()) : e._channelModule.onReconnectFailed();
      })));
    } }, { key: 'getReconnectFlag', value() {
      return this._reConnectFlag;
    } }, { key: '_setNextPingTs', value() {
      this._nextPingTs = Date.now() + 1e4;
    } }, { key: 'getNextPingTs', value() {
      return this._nextPingTs;
    } }, { key: 'isConnected', value() {
      return this._readyState === Ic;
    } }, { key: 'canIUseBinaryFrame', value() {
      return this._canIUseBinaryFrame;
    } }, { key: '_getRandom', value() {
      return 0 === this._random && (this._random = Math.random()), this._random;
    } }, { key: '_resetRandom', value() {
      this._random = 0;
    } }, { key: 'close', value() {
      Oe.log(''.concat(this._className, '.close')), this._closeConnection(vc), this._promiseMap.clear(), this._startSequence = Je(), this._readyState = Tc, this._simpleRequestMap.clear(), this._reConnectFlag = !1, this._reConnectCount = 0, this._onOpenTs = 0, this._url = '', this._random = 0, this._canIUseBinaryFrame = !0;
    } }]), e;
  }()); const Dc = (function (e) {
    i(a, e);const n = f(a);function a(e) {
      let o;if (t(this, a), (o = n.call(this, e))._className = 'ChannelModule', o._socketHandler = new Sc(h(o)), o._probing = !1, o._isAppShowing = !0, o._previousState = k.NET_STATE_CONNECTED, ee && 'function' === typeof ne.onAppShow && 'function' === typeof ne.onAppHide) {
        const s = o._onAppHide.bind(h(o)); const r = o._onAppShow.bind(h(o));'function' === typeof ne.offAppHide && ne.offAppHide(s), 'function' === typeof ne.offAppShow && ne.offAppShow(r), ne.onAppHide(s), ne.onAppShow(r);
      } return o._timerForNotLoggedIn = -1, o._timerForNotLoggedIn = setInterval(o.onCheckTimer.bind(h(o)), 1e3), o._fatalErrorFlag = !1, o;
    } return o(a, [{ key: 'onCheckTimer', value(e) {
      this._socketHandler && (this.isLoggedIn() ? (this._timerForNotLoggedIn > 0 && (clearInterval(this._timerForNotLoggedIn), this._timerForNotLoggedIn = -1), this._socketHandler.onCheckTimer(e)) : this._socketHandler.onCheckTimer(1), this._checkNextPing());
    } }, { key: 'onErrorCodeNotZero', value(e) {
      this.getModule(Xt).onErrorCodeNotZero(e);
    } }, { key: 'onMessage', value(e) {
      this.getModule(Xt).onMessage(e);
    } }, { key: 'send', value(e) {
      return this._socketHandler ? this._previousState !== k.NET_STATE_CONNECTED && e.head.servcmd.includes(go) ? (this.reConnect(), this._sendLogViaHTTP(e)) : this._socketHandler.send(e) : Promise.reject();
    } }, { key: '_sendLogViaHTTP', value(e) {
      const t = x.HOST.CURRENT.STAT;return new Promise(((n, o) => {
        const a = ''.concat(t, '/v4/imopenstat/tim_web_report_v2?sdkappid=').concat(e.head.sdkappid, '&reqtime=')
          .concat(Date.now()); const s = JSON.stringify(e.body); const r = 'application/x-www-form-urlencoded;charset=UTF-8';if (ee)ne.request({ url: a, data: s, method: 'POST', timeout: 3e3, header: { 'content-type': r }, success() {
          n();
        }, fail() {
          o(new ei({ code: Do.NETWORK_ERROR, message: Aa }));
        } });else {
          const i = new XMLHttpRequest; const c = setTimeout((() => {
            i.abort(), o(new ei({ code: Do.NETWORK_TIMEOUT, message: Na }));
          }), 3e3);i.onreadystatechange = function () {
            4 === i.readyState && (clearTimeout(c), 200 === i.status || 304 === i.status ? n() : o(new ei({ code: Do.NETWORK_ERROR, message: Aa })));
          }, i.open('POST', a, !0), i.setRequestHeader('Content-type', r), i.send(s);
        }
      }));
    } }, { key: 'simplySend', value(e) {
      return this._socketHandler ? this._socketHandler.simplySend(e) : Promise.reject();
    } }, { key: 'onOpen', value() {
      this._ping();
    } }, { key: 'onClose', value() {
      this._socketHandler && (this._socketHandler.getReconnectFlag() && this._emitNetStateChangeEvent(k.NET_STATE_DISCONNECTED));this.reConnect();
    } }, { key: 'onError', value() {
      ee && Oe.error(''.concat(this._className, '.onError 从v2.11.2起，SDK 支持了 WebSocket，如您未添加相关受信域名，请先添加！升级指引: https://web.sdk.qcloud.com/im/doc/zh-cn/tutorial-02-upgradeguideline.html'));
    } }, { key: 'getKeyMap', value(e) {
      return this.getModule(Xt).getKeyMap(e);
    } }, { key: '_onAppHide', value() {
      this._isAppShowing = !1;
    } }, { key: '_onAppShow', value() {
      this._isAppShowing = !0;
    } }, { key: 'onRequestTimeout', value(e) {} }, { key: 'onReconnected', value() {
      Oe.log(''.concat(this._className, '.onReconnected')), this.getModule(Xt).onReconnected(), this._emitNetStateChangeEvent(k.NET_STATE_CONNECTED);
    } }, { key: 'onReconnectFailed', value() {
      Oe.log(''.concat(this._className, '.onReconnectFailed')), this._emitNetStateChangeEvent(k.NET_STATE_DISCONNECTED);
    } }, { key: 'reConnect', value() {
      const e = arguments.length > 0 && void 0 !== arguments[0] && arguments[0]; let t = !1;this._socketHandler && (t = this._socketHandler.getReconnectFlag());const n = 'forcedFlag:'.concat(e, ' fatalErrorFlag:').concat(this._fatalErrorFlag, ' previousState:')
        .concat(this._previousState, ' reconnectFlag:')
        .concat(t);if (Oe.log(''.concat(this._className, '.reConnect ').concat(n)), !this._fatalErrorFlag && this._socketHandler) {
        if (!0 === e) this._socketHandler.forcedReconnect();else {
          if (this._previousState === k.NET_STATE_CONNECTING && t) return;this._socketHandler.forcedReconnect();
        } this._emitNetStateChangeEvent(k.NET_STATE_CONNECTING);
      }
    } }, { key: '_emitNetStateChangeEvent', value(e) {
      this._previousState !== e && (Oe.log(''.concat(this._className, '._emitNetStateChangeEvent from ').concat(this._previousState, ' to ')
        .concat(e)), this._previousState = e, this.emitOuterEvent(D.NET_STATE_CHANGE, { state: e }));
    } }, { key: '_ping', value() {
      const e = this;if (!0 !== this._probing) {
        this._probing = !0;const t = this.getModule(Xt).getProtocolData({ protocolName: ho });this.send(t).then((() => {
          e._probing = !1;
        }))
          .catch(((t) => {
            if (Oe.warn(''.concat(e._className, '._ping failed. error:'), t), e._probing = !1, t && 60002 === t.code) return new Xa(Tr).setMessage('code:'.concat(t.code, ' message:').concat(t.message))
              .setNetworkType(e.getModule(Wt).getNetworkType())
              .end(), e._fatalErrorFlag = !0, void e._emitNetStateChangeEvent(k.NET_STATE_DISCONNECTED);e.probeNetwork().then(((t) => {
              const n = m(t, 2); const o = n[0]; const a = n[1];Oe.log(''.concat(e._className, '._ping failed. probe network, isAppShowing:').concat(e._isAppShowing, ' online:')
                .concat(o, ' networkType:')
                .concat(a)), o ? e.reConnect() : e._emitNetStateChangeEvent(k.NET_STATE_DISCONNECTED);
            }));
          }));
      }
    } }, { key: '_checkNextPing', value() {
      this._socketHandler && (this._socketHandler.isConnected() && Date.now() >= this._socketHandler.getNextPingTs() && this._ping());
    } }, { key: 'dealloc', value() {
      this._socketHandler && (this._socketHandler.close(), this._socketHandler = null), this._timerForNotLoggedIn > -1 && clearInterval(this._timerForNotLoggedIn);
    } }, { key: 'reset', value() {
      Oe.log(''.concat(this._className, '.reset')), this._previousState = k.NET_STATE_CONNECTED, this._probing = !1, this._fatalErrorFlag = !1, this._timerForNotLoggedIn = setInterval(this.onCheckTimer.bind(this), 1e3);
    } }]), a;
  }(sn)); const kc = (function () {
    function n(e) {
      t(this, n), this._className = 'ProtocolHandler', this._sessionModule = e, this._configMap = new Map, this._fillConfigMap();
    } return o(n, [{ key: '_fillConfigMap', value() {
      this._configMap.clear();const e = this._sessionModule.genCommonHead(); const t = this._sessionModule.genCosSpecifiedHead(); const n = this._sessionModule.genSSOReportHead();this._configMap.set(rn, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.IM_OPEN_STATUS, '.').concat(x.CMD.LOGIN) }), body: { state: 'Online' }, keyMap: { response: { TinyId: 'tinyID', InstId: 'instanceID', HelloInterval: 'helloInterval' } } };
      }(e))), this._configMap.set(cn, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.IM_OPEN_STATUS, '.').concat(x.CMD.LOGOUT) }), body: { type: 0 }, keyMap: { request: { type: 'wslogout_type' } } };
      }(e))), this._configMap.set(un, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.IM_OPEN_STATUS, '.').concat(x.CMD.HELLO) }), body: {}, keyMap: { response: { NewInstInfo: 'newInstanceInfo' } } };
      }(e))), this._configMap.set(ln, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.STAT_SERVICE, '.').concat(x.CMD.KICK_OTHER) }), body: {} };
      }(e))), this._configMap.set(lo, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.IM_COS_SIGN, '.').concat(x.CMD.COS_SIGN) }), body: { cmd: 'open_im_cos_svc', subCmd: 'get_cos_token', duration: 300, version: 2 }, keyMap: { request: { userSig: 'usersig', subCmd: 'sub_cmd', cmd: 'cmd', duration: 'duration', version: 'version' }, response: { expired_time: 'expiredTime', bucket_name: 'bucketName', session_token: 'sessionToken', tmp_secret_id: 'secretId', tmp_secret_key: 'secretKey' } } };
      }(t))), this._configMap.set(po, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.CUSTOM_UPLOAD, '.').concat(x.CMD.COS_PRE_SIG) }), body: { fileType: void 0, fileName: void 0, uploadMethod: 0, duration: 900 }, keyMap: { request: { userSig: 'usersig', fileType: 'file_type', fileName: 'file_name', uploadMethod: 'upload_method' }, response: { expired_time: 'expiredTime', request_id: 'requestId', head_url: 'headUrl', upload_url: 'uploadUrl', download_url: 'downloadUrl', ci_url: 'ciUrl' } } };
      }(t))), this._configMap.set(Co, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.IM_CONFIG_MANAGER, '.').concat(x.CMD.FETCH_COMMERCIAL_CONFIG) }), body: { SDKAppID: 0 }, keyMap: { request: { SDKAppID: 'uint32_sdkappid' }, response: { int32_error_code: 'errorCode', str_error_message: 'errorMessage', str_purchase_bits: 'purchaseBits', uint32_expired_time: 'expiredTime' } } };
      }(e))), this._configMap.set(To, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.IM_CONFIG_MANAGER, '.').concat(x.CMD.PUSHED_COMMERCIAL_CONFIG) }), body: {}, keyMap: { response: { int32_error_code: 'errorCode', str_error_message: 'errorMessage', str_purchase_bits: 'purchaseBits', uint32_expired_time: 'expiredTime' } } };
      }(e))), this._configMap.set(yo, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.IM_CONFIG_MANAGER, '.').concat(x.CMD.FETCH_CLOUD_CONTROL_CONFIG) }), body: { SDKAppID: 0, version: 0 }, keyMap: { request: { SDKAppID: 'uint32_sdkappid', version: 'uint64_version' }, response: { int32_error_code: 'errorCode', str_error_message: 'errorMessage', str_json_config: 'cloudControlConfig', uint32_expired_time: 'expiredTime', uint32_sdkappid: 'SDKAppID', uint64_version: 'version' } } };
      }(e))), this._configMap.set(Io, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.IM_CONFIG_MANAGER, '.').concat(x.CMD.PUSHED_CLOUD_CONTROL_CONFIG) }), body: {}, keyMap: { response: { int32_error_code: 'errorCode', str_error_message: 'errorMessage', str_json_config: 'cloudControlConfig', uint32_expired_time: 'expiredTime', uint32_sdkappid: 'SDKAppID', uint64_version: 'version' } } };
      }(e))), this._configMap.set(So, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.OVERLOAD_PUSH, '.').concat(x.CMD.OVERLOAD_NOTIFY) }), body: {}, keyMap: { response: { OverLoadServCmd: 'overloadCommand', DelaySecs: 'waitingTime' } } };
      }(e))), this._configMap.set(dn, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.OPEN_IM, '.').concat(x.CMD.GET_MESSAGES) }), body: { cookie: '', syncFlag: 0, needAbstract: 1, isOnlineSync: 0 }, keyMap: { request: { fromAccount: 'From_Account', toAccount: 'To_Account', from: 'From_Account', to: 'To_Account', time: 'MsgTimeStamp', sequence: 'MsgSeq', random: 'MsgRandom', elements: 'MsgBody' }, response: { MsgList: 'messageList', SyncFlag: 'syncFlag', To_Account: 'to', From_Account: 'from', ClientSeq: 'clientSequence', MsgSeq: 'sequence', NoticeSeq: 'noticeSequence', NotifySeq: 'notifySequence', MsgRandom: 'random', MsgTimeStamp: 'time', MsgContent: 'content', ToGroupId: 'groupID', MsgKey: 'messageKey', GroupTips: 'groupTips', MsgBody: 'elements', MsgType: 'type', C2CRemainingUnreadCount: 'C2CRemainingUnreadList', C2CPairUnreadCount: 'C2CPairUnreadList' } } };
      }(e))), this._configMap.set(pn, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.OPEN_IM, '.').concat(x.CMD.BIG_DATA_HALLWAY_AUTH_KEY) }), body: {} };
      }(e))), this._configMap.set(gn, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.OPEN_IM, '.').concat(x.CMD.SEND_MESSAGE) }), body: { fromAccount: '', toAccount: '', msgTimeStamp: void 0, msgSeq: 0, msgRandom: 0, msgBody: [], cloudCustomData: void 0, nick: '', avatar: '', msgLifeTime: void 0, offlinePushInfo: { pushFlag: 0, title: '', desc: '', ext: '', apnsInfo: { badgeMode: 0 }, androidInfo: { OPPOChannelID: '' } }, messageControlInfo: void 0 }, keyMap: { request: { fromAccount: 'From_Account', toAccount: 'To_Account', msgTimeStamp: 'MsgTimeStamp', msgSeq: 'MsgSeq', msgRandom: 'MsgRandom', msgBody: 'MsgBody', count: 'MaxCnt', lastMessageTime: 'LastMsgTime', messageKey: 'MsgKey', peerAccount: 'Peer_Account', data: 'Data', description: 'Desc', extension: 'Ext', type: 'MsgType', content: 'MsgContent', sizeType: 'Type', uuid: 'UUID', url: '', imageUrl: 'URL', fileUrl: 'Url', remoteAudioUrl: 'Url', remoteVideoUrl: 'VideoUrl', thumbUUID: 'ThumbUUID', videoUUID: 'VideoUUID', videoUrl: '', downloadFlag: 'Download_Flag', nick: 'From_AccountNick', avatar: 'From_AccountHeadurl', from: 'From_Account', time: 'MsgTimeStamp', messageRandom: 'MsgRandom', messageSequence: 'MsgSeq', elements: 'MsgBody', clientSequence: 'ClientSeq', payload: 'MsgContent', messageList: 'MsgList', messageNumber: 'MsgNum', abstractList: 'AbstractList', messageBody: 'MsgBody' } } };
      }(e))), this._configMap.set(hn, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.GROUP, '.').concat(x.CMD.SEND_GROUP_MESSAGE) }), body: { fromAccount: '', groupID: '', random: 0, clientSequence: 0, priority: '', msgBody: [], cloudCustomData: void 0, onlineOnlyFlag: 0, offlinePushInfo: { pushFlag: 0, title: '', desc: '', ext: '', apnsInfo: { badgeMode: 0 }, androidInfo: { OPPOChannelID: '' } }, groupAtInfo: [], messageControlInfo: void 0 }, keyMap: { request: { to: 'GroupId', extension: 'Ext', data: 'Data', description: 'Desc', random: 'Random', sequence: 'ReqMsgSeq', count: 'ReqMsgNumber', type: 'MsgType', priority: 'MsgPriority', content: 'MsgContent', elements: 'MsgBody', sizeType: 'Type', uuid: 'UUID', url: '', imageUrl: 'URL', fileUrl: 'Url', remoteAudioUrl: 'Url', remoteVideoUrl: 'VideoUrl', thumbUUID: 'ThumbUUID', videoUUID: 'VideoUUID', videoUrl: '', downloadFlag: 'Download_Flag', clientSequence: 'ClientSeq', from: 'From_Account', time: 'MsgTimeStamp', messageRandom: 'MsgRandom', messageSequence: 'MsgSeq', payload: 'MsgContent', messageList: 'MsgList', messageNumber: 'MsgNum', abstractList: 'AbstractList', messageBody: 'MsgBody' }, response: { MsgTime: 'time', MsgSeq: 'sequence' } } };
      }(e))), this._configMap.set(yn, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.OPEN_IM, '.').concat(x.CMD.REVOKE_C2C_MESSAGE) }), body: { msgInfo: { fromAccount: '', toAccount: '', msgTimeStamp: 0, msgSeq: 0, msgRandom: 0 } }, keyMap: { request: { msgInfo: 'MsgInfo', msgTimeStamp: 'MsgTimeStamp', msgSeq: 'MsgSeq', msgRandom: 'MsgRandom' } } };
      }(e))), this._configMap.set(Hn, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.GROUP, '.').concat(x.CMD.REVOKE_GROUP_MESSAGE) }), body: { to: '', msgSeqList: void 0 }, keyMap: { request: { to: 'GroupId', msgSeqList: 'MsgSeqList', msgSeq: 'MsgSeq' } } };
      }(e))), this._configMap.set(Sn, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.OPEN_IM, '.').concat(x.CMD.GET_C2C_ROAM_MESSAGES) }), body: { peerAccount: '', count: 15, lastMessageTime: 0, messageKey: '', withRecalledMessage: 1 }, keyMap: { request: { messageKey: 'MsgKey', peerAccount: 'Peer_Account', count: 'MaxCnt', lastMessageTime: 'LastMsgTime', withRecalledMessage: 'WithRecalledMsg' }, response: { LastMsgTime: 'lastMessageTime' } } };
      }(e))), this._configMap.set(Yn, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.GROUP, '.').concat(x.CMD.GET_GROUP_ROAM_MESSAGES) }), body: { withRecalledMsg: 1, groupID: '', count: 15, sequence: '' }, keyMap: { request: { sequence: 'ReqMsgSeq', count: 'ReqMsgNumber', withRecalledMessage: 'WithRecalledMsg' }, response: { Random: 'random', MsgTime: 'time', MsgSeq: 'sequence', ReqMsgSeq: 'sequence', RspMsgList: 'messageList', IsPlaceMsg: 'isPlaceMessage', IsSystemMsg: 'isSystemMessage', ToGroupId: 'to', EnumFrom_AccountType: 'fromAccountType', EnumTo_AccountType: 'toAccountType', GroupCode: 'groupCode', MsgPriority: 'priority', MsgBody: 'elements', MsgType: 'type', MsgContent: 'content', IsFinished: 'complete', Download_Flag: 'downloadFlag', ClientSeq: 'clientSequence', ThumbUUID: 'thumbUUID', VideoUUID: 'videoUUID' } } };
      }(e))), this._configMap.set(In, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.OPEN_IM, '.').concat(x.CMD.SET_C2C_MESSAGE_READ) }), body: { C2CMsgReaded: void 0 }, keyMap: { request: { lastMessageTime: 'LastedMsgTime' } } };
      }(e))), this._configMap.set(Cn, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.OPEN_IM, '.').concat(x.CMD.SET_C2C_PEER_MUTE_NOTIFICATIONS) }), body: { userIDList: void 0, muteFlag: 0 }, keyMap: { request: { userIDList: 'Peer_Account', muteFlag: 'Mute_Notifications' } } };
      }(e))), this._configMap.set(Tn, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.OPEN_IM, '.').concat(x.CMD.GET_C2C_PEER_MUTE_NOTIFICATIONS) }), body: { updateSequence: 0 }, keyMap: { response: { MuteNotificationsList: 'muteFlagList' } } };
      }(e))), this._configMap.set(jn, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.GROUP, '.').concat(x.CMD.SET_GROUP_MESSAGE_READ) }), body: { groupID: void 0, messageReadSeq: void 0 }, keyMap: { request: { messageReadSeq: 'MsgReadedSeq' } } };
      }(e))), this._configMap.set(Wn, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.OPEN_IM, '.').concat(x.CMD.SET_ALL_MESSAGE_READ) }), body: { readAllC2CMessage: 0, groupMessageReadInfoList: [] }, keyMap: { request: { readAllC2CMessage: 'C2CReadAllMsg', groupMessageReadInfoList: 'GroupReadInfo', messageSequence: 'MsgSeq' }, response: { C2CReadAllMsg: 'readAllC2CMessage', GroupReadInfoArray: 'groupMessageReadInfoList' } } };
      }(e))), this._configMap.set(kn, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.OPEN_IM, '.').concat(x.CMD.DELETE_C2C_MESSAGE) }), body: { fromAccount: '', to: '', keyList: void 0 }, keyMap: { request: { keyList: 'MsgKeyList' } } };
      }(e))), this._configMap.set(Zn, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.GROUP, '.').concat(x.CMD.DELETE_GROUP_MESSAGE) }), body: { groupID: '', deleter: '', keyList: void 0 }, keyMap: { request: { deleter: 'Deleter_Account', keyList: 'Seqs' } } };
      }(e))), this._configMap.set(Dn, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.OPEN_IM, '.').concat(x.CMD.GET_PEER_READ_TIME) }), body: { userIDList: void 0 }, keyMap: { request: { userIDList: 'To_Account' }, response: { ReadTime: 'peerReadTimeList' } } };
      }(e))), this._configMap.set(An, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.RECENT_CONTACT, '.').concat(x.CMD.GET_CONVERSATION_LIST) }), body: { fromAccount: void 0, count: 0 }, keyMap: { request: {}, response: { SessionItem: 'conversations', ToAccount: 'groupID', To_Account: 'userID', UnreadMsgCount: 'unreadCount', MsgGroupReadedSeq: 'messageReadSeq', C2cPeerReadTime: 'c2cPeerReadTime' } } };
      }(e))), this._configMap.set(En, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.RECENT_CONTACT, '.').concat(x.CMD.PAGING_GET_CONVERSATION_LIST) }), body: { fromAccount: void 0, timeStamp: void 0, startIndex: void 0, pinnedTimeStamp: void 0, pinnedStartIndex: void 0, orderType: void 0, messageAssistFlag: 4, assistFlag: 7 }, keyMap: { request: { messageAssistFlag: 'MsgAssistFlags', assistFlag: 'AssistFlags', pinnedTimeStamp: 'TopTimeStamp', pinnedStartIndex: 'TopStartIndex' }, response: { SessionItem: 'conversations', ToAccount: 'groupID', To_Account: 'userID', UnreadMsgCount: 'unreadCount', MsgGroupReadedSeq: 'messageReadSeq', C2cPeerReadTime: 'c2cPeerReadTime', LastMsgFlags: 'lastMessageFlag', TopFlags: 'isPinned', TopTimeStamp: 'pinnedTimeStamp', TopStartIndex: 'pinnedStartIndex' } } };
      }(e))), this._configMap.set(Nn, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.RECENT_CONTACT, '.').concat(x.CMD.DELETE_CONVERSATION) }), body: { fromAccount: '', toAccount: void 0, type: 1, toGroupID: void 0, clearHistoryMessage: 1 }, keyMap: { request: { toGroupID: 'ToGroupid', clearHistoryMessage: 'ClearRamble' } } };
      }(e))), this._configMap.set(Ln, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.RECENT_CONTACT, '.').concat(x.CMD.PIN_CONVERSATION) }), body: { fromAccount: '', operationType: 1, itemList: void 0 }, keyMap: { request: { itemList: 'RecentContactItem' } } };
      }(e))), this._configMap.set(Rn, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.OPEN_IM, '.').concat(x.CMD.DELETE_GROUP_AT_TIPS) }), body: { messageListToDelete: void 0 }, keyMap: { request: { messageListToDelete: 'DelMsgList', messageSeq: 'MsgSeq', messageRandom: 'MsgRandom' } } };
      }(e))), this._configMap.set(_n, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.PROFILE, '.').concat(x.CMD.PORTRAIT_GET) }), body: { fromAccount: '', userItem: [] }, keyMap: { request: { toAccount: 'To_Account', standardSequence: 'StandardSequence', customSequence: 'CustomSequence' } } };
      }(e))), this._configMap.set(fn, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.PROFILE, '.').concat(x.CMD.PORTRAIT_SET) }), body: { fromAccount: '', profileItem: [{ tag: Er.NICK, value: '' }, { tag: Er.GENDER, value: '' }, { tag: Er.ALLOWTYPE, value: '' }, { tag: Er.AVATAR, value: '' }] }, keyMap: { request: { toAccount: 'To_Account', standardSequence: 'StandardSequence', customSequence: 'CustomSequence' } } };
      }(e))), this._configMap.set(mn, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.FRIEND, '.').concat(x.CMD.GET_BLACKLIST) }), body: { fromAccount: '', startIndex: 0, maxLimited: 30, lastSequence: 0 }, keyMap: { response: { CurruentSequence: 'currentSequence' } } };
      }(e))), this._configMap.set(Mn, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.FRIEND, '.').concat(x.CMD.ADD_BLACKLIST) }), body: { fromAccount: '', toAccount: [] } };
      }(e))), this._configMap.set(vn, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.FRIEND, '.').concat(x.CMD.DELETE_BLACKLIST) }), body: { fromAccount: '', toAccount: [] } };
      }(e))), this._configMap.set(On, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.GROUP, '.').concat(x.CMD.GET_JOINED_GROUPS) }), body: { memberAccount: '', limit: void 0, offset: void 0, groupType: void 0, responseFilter: { groupBaseInfoFilter: void 0, selfInfoFilter: void 0 } }, keyMap: { request: { memberAccount: 'Member_Account' }, response: { GroupIdList: 'groups', MsgFlag: 'messageRemindType', NoUnreadSeqList: 'excludedUnreadSequenceList', MsgSeq: 'readedSequence' } } };
      }(e))), this._configMap.set(Gn, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.GROUP, '.').concat(x.CMD.GET_GROUP_INFO) }), body: { groupIDList: void 0, responseFilter: { groupBaseInfoFilter: ['Type', 'Name', 'Introduction', 'Notification', 'FaceUrl', 'Owner_Account', 'CreateTime', 'InfoSeq', 'LastInfoTime', 'LastMsgTime', 'MemberNum', 'MaxMemberNum', 'ApplyJoinOption', 'NextMsgSeq', 'ShutUpAllMember'], groupCustomFieldFilter: void 0, memberInfoFilter: void 0, memberCustomFieldFilter: void 0 } }, keyMap: { request: { groupIDList: 'GroupIdList', groupCustomField: 'AppDefinedData', memberCustomField: 'AppMemberDefinedData', groupCustomFieldFilter: 'AppDefinedDataFilter_Group', memberCustomFieldFilter: 'AppDefinedDataFilter_GroupMember' }, response: { GroupIdList: 'groups', MsgFlag: 'messageRemindType', AppDefinedData: 'groupCustomField', AppMemberDefinedData: 'memberCustomField', AppDefinedDataFilter_Group: 'groupCustomFieldFilter', AppDefinedDataFilter_GroupMember: 'memberCustomFieldFilter', InfoSeq: 'infoSequence', MemberList: 'members', GroupInfo: 'groups', ShutUpUntil: 'muteUntil', ShutUpAllMember: 'muteAllMembers', ApplyJoinOption: 'joinOption' } } };
      }(e))), this._configMap.set(wn, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.GROUP, '.').concat(x.CMD.CREATE_GROUP) }), body: { type: void 0, name: void 0, groupID: void 0, ownerID: void 0, introduction: void 0, notification: void 0, maxMemberNum: void 0, joinOption: void 0, memberList: void 0, groupCustomField: void 0, memberCustomField: void 0, webPushFlag: 1, avatar: 'FaceUrl' }, keyMap: { request: { ownerID: 'Owner_Account', userID: 'Member_Account', avatar: 'FaceUrl', maxMemberNum: 'MaxMemberCount', joinOption: 'ApplyJoinOption', groupCustomField: 'AppDefinedData', memberCustomField: 'AppMemberDefinedData' }, response: { HugeGroupFlag: 'avChatRoomFlag', OverJoinedGroupLimit_Account: 'overLimitUserIDList' } } };
      }(e))), this._configMap.set(bn, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.GROUP, '.').concat(x.CMD.DESTROY_GROUP) }), body: { groupID: void 0 } };
      }(e))), this._configMap.set(Pn, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.GROUP, '.').concat(x.CMD.MODIFY_GROUP_INFO) }), body: { groupID: void 0, name: void 0, introduction: void 0, notification: void 0, avatar: void 0, maxMemberNum: void 0, joinOption: void 0, groupCustomField: void 0, muteAllMembers: void 0 }, keyMap: { request: { maxMemberNum: 'MaxMemberCount', groupCustomField: 'AppDefinedData', muteAllMembers: 'ShutUpAllMember', joinOption: 'ApplyJoinOption', avatar: 'FaceUrl' }, response: { AppDefinedData: 'groupCustomField', ShutUpAllMember: 'muteAllMembers', ApplyJoinOption: 'joinOption' } } };
      }(e))), this._configMap.set(Un, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.GROUP, '.').concat(x.CMD.APPLY_JOIN_GROUP) }), body: { groupID: void 0, applyMessage: void 0, userDefinedField: void 0, webPushFlag: 1, historyMessageFlag: void 0 }, keyMap: { request: { applyMessage: 'ApplyMsg', historyMessageFlag: 'HugeGroupHistoryMsgFlag' }, response: { HugeGroupFlag: 'avChatRoomFlag', AVChatRoomKey: 'avChatRoomKey', RspMsgList: 'messageList', ToGroupId: 'to' } } };
      }(e))), this._configMap.set(Fn, (function (e) {
        e.a2, e.tinyid;return { head: r(r({}, g(e, ['a2', 'tinyid'])), {}, { servcmd: ''.concat(x.NAME.BIG_GROUP_NO_AUTH, '.').concat(x.CMD.APPLY_JOIN_GROUP) }), body: { groupID: void 0, applyMessage: void 0, userDefinedField: void 0, webPushFlag: 1 }, keyMap: { request: { applyMessage: 'ApplyMsg' }, response: { HugeGroupFlag: 'avChatRoomFlag' } } };
      }(e))), this._configMap.set(qn, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.GROUP, '.').concat(x.CMD.QUIT_GROUP) }), body: { groupID: void 0 } };
      }(e))), this._configMap.set(Vn, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.GROUP, '.').concat(x.CMD.SEARCH_GROUP_BY_ID) }), body: { groupIDList: void 0, responseFilter: { groupBasePublicInfoFilter: ['Type', 'Name', 'Introduction', 'Notification', 'FaceUrl', 'CreateTime', 'Owner_Account', 'LastInfoTime', 'LastMsgTime', 'NextMsgSeq', 'MemberNum', 'MaxMemberNum', 'ApplyJoinOption'] } }, keyMap: { response: { ApplyJoinOption: 'joinOption' } } };
      }(e))), this._configMap.set(Kn, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.GROUP, '.').concat(x.CMD.CHANGE_GROUP_OWNER) }), body: { groupID: void 0, newOwnerID: void 0 }, keyMap: { request: { newOwnerID: 'NewOwner_Account' } } };
      }(e))), this._configMap.set(xn, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.GROUP, '.').concat(x.CMD.HANDLE_APPLY_JOIN_GROUP) }), body: { groupID: void 0, applicant: void 0, handleAction: void 0, handleMessage: void 0, authentication: void 0, messageKey: void 0, userDefinedField: void 0 }, keyMap: { request: { applicant: 'Applicant_Account', handleAction: 'HandleMsg', handleMessage: 'ApprovalMsg', messageKey: 'MsgKey' } } };
      }(e))), this._configMap.set(Bn, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.GROUP, '.').concat(x.CMD.HANDLE_GROUP_INVITATION) }), body: { groupID: void 0, inviter: void 0, handleAction: void 0, handleMessage: void 0, authentication: void 0, messageKey: void 0, userDefinedField: void 0 }, keyMap: { request: { inviter: 'Inviter_Account', handleAction: 'HandleMsg', handleMessage: 'ApprovalMsg', messageKey: 'MsgKey' } } };
      }(e))), this._configMap.set($n, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.GROUP, '.').concat(x.CMD.GET_GROUP_APPLICATION) }), body: { startTime: void 0, limit: void 0, handleAccount: void 0 }, keyMap: { request: { handleAccount: 'Handle_Account' } } };
      }(e))), this._configMap.set(zn, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.OPEN_IM, '.').concat(x.CMD.DELETE_GROUP_SYSTEM_MESSAGE) }), body: { messageListToDelete: void 0 }, keyMap: { request: { messageListToDelete: 'DelMsgList', messageSeq: 'MsgSeq', messageRandom: 'MsgRandom' } } };
      }(e))), this._configMap.set(Jn, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.BIG_GROUP_LONG_POLLING, '.').concat(x.CMD.AVCHATROOM_LONG_POLL) }), body: { USP: 1, startSeq: 1, holdTime: 90, key: void 0 }, keyMap: { request: { USP: 'USP' }, response: { ToGroupId: 'groupID' } } };
      }(e))), this._configMap.set(Xn, (function (e) {
        e.a2, e.tinyid;return { head: r(r({}, g(e, ['a2', 'tinyid'])), {}, { servcmd: ''.concat(x.NAME.BIG_GROUP_LONG_POLLING_NO_AUTH, '.').concat(x.CMD.AVCHATROOM_LONG_POLL) }), body: { USP: 1, startSeq: 1, holdTime: 90, key: void 0 }, keyMap: { request: { USP: 'USP' }, response: { ToGroupId: 'groupID' } } };
      }(e))), this._configMap.set(Qn, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.GROUP, '.').concat(x.CMD.GET_ONLINE_MEMBER_NUM) }), body: { groupID: void 0 } };
      }(e))), this._configMap.set(eo, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.GROUP, '.').concat(x.CMD.SET_GROUP_ATTRIBUTES) }), body: { groupID: void 0, groupAttributeList: void 0, mainSequence: void 0, avChatRoomKey: void 0, attributeControl: ['RaceConflict'] }, keyMap: { request: { key: 'key', value: 'value' } } };
      }(e))), this._configMap.set(to, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.GROUP, '.').concat(x.CMD.MODIFY_GROUP_ATTRIBUTES) }), body: { groupID: void 0, groupAttributeList: void 0, mainSequence: void 0, avChatRoomKey: void 0, attributeControl: ['RaceConflict'] }, keyMap: { request: { key: 'key', value: 'value' } } };
      }(e))), this._configMap.set(no, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.GROUP, '.').concat(x.CMD.DELETE_GROUP_ATTRIBUTES) }), body: { groupID: void 0, groupAttributeList: void 0, mainSequence: void 0, avChatRoomKey: void 0, attributeControl: ['RaceConflict'] }, keyMap: { request: { key: 'key' } } };
      }(e))), this._configMap.set(oo, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.GROUP, '.').concat(x.CMD.CLEAR_GROUP_ATTRIBUTES) }), body: { groupID: void 0, mainSequence: void 0, avChatRoomKey: void 0, attributeControl: ['RaceConflict'] } };
      }(e))), this._configMap.set(ao, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.GROUP_ATTR, '.').concat(x.CMD.GET_GROUP_ATTRIBUTES) }), body: { groupID: void 0, avChatRoomKey: void 0, groupType: 1 }, keyMap: { request: { avChatRoomKey: 'Key', groupType: 'GroupType' } } };
      }(e))), this._configMap.set(so, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.GROUP, '.').concat(x.CMD.GET_GROUP_MEMBER_LIST) }), body: { groupID: void 0, limit: 0, offset: 0, memberRoleFilter: void 0, memberInfoFilter: ['Role', 'NameCard', 'ShutUpUntil', 'JoinTime'], memberCustomFieldFilter: void 0 }, keyMap: { request: { memberCustomFieldFilter: 'AppDefinedDataFilter_GroupMember' }, response: { AppMemberDefinedData: 'memberCustomField', AppDefinedDataFilter_GroupMember: 'memberCustomFieldFilter', MemberList: 'members', ShutUpUntil: 'muteUntil' } } };
      }(e))), this._configMap.set(ro, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.GROUP, '.').concat(x.CMD.GET_GROUP_MEMBER_INFO) }), body: { groupID: void 0, userIDList: void 0, memberInfoFilter: void 0, memberCustomFieldFilter: void 0 }, keyMap: { request: { userIDList: 'Member_List_Account', memberCustomFieldFilter: 'AppDefinedDataFilter_GroupMember' }, response: { MemberList: 'members', ShutUpUntil: 'muteUntil', AppDefinedDataFilter_GroupMember: 'memberCustomFieldFilter', AppMemberDefinedData: 'memberCustomField' } } };
      }(e))), this._configMap.set(io, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.GROUP, '.').concat(x.CMD.ADD_GROUP_MEMBER) }), body: { groupID: void 0, silence: void 0, userIDList: void 0 }, keyMap: { request: { userID: 'Member_Account', userIDList: 'MemberList' }, response: { MemberList: 'members' } } };
      }(e))), this._configMap.set(co, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.GROUP, '.').concat(x.CMD.DELETE_GROUP_MEMBER) }), body: { groupID: void 0, userIDList: void 0, reason: void 0 }, keyMap: { request: { userIDList: 'MemberToDel_Account' } } };
      }(e))), this._configMap.set(uo, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.GROUP, '.').concat(x.CMD.MODIFY_GROUP_MEMBER_INFO) }), body: { groupID: void 0, userID: void 0, messageRemindType: void 0, nameCard: void 0, role: void 0, memberCustomField: void 0, muteTime: void 0 }, keyMap: { request: { userID: 'Member_Account', memberCustomField: 'AppMemberDefinedData', muteTime: 'ShutUpTime', messageRemindType: 'MsgFlag' } } };
      }(e))), this._configMap.set(go, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.IM_OPEN_STAT, '.').concat(x.CMD.TIM_WEB_REPORT_V2) }), body: { header: {}, event: [], quality: [] }, keyMap: { request: { SDKType: 'sdk_type', SDKVersion: 'sdk_version', deviceType: 'device_type', platform: 'platform', instanceID: 'instance_id', traceID: 'trace_id', SDKAppID: 'sdk_app_id', userID: 'user_id', tinyID: 'tiny_id', extension: 'extension', timestamp: 'timestamp', networkType: 'network_type', eventType: 'event_type', code: 'error_code', message: 'error_message', moreMessage: 'more_message', duplicate: 'duplicate', costTime: 'cost_time', level: 'level', qualityType: 'quality_type', reportIndex: 'report_index', wholePeriod: 'whole_period', totalCount: 'total_count', rttCount: 'success_count_business', successRateOfRequest: 'percent_business', countLessThan1Second: 'success_count_business', percentOfCountLessThan1Second: 'percent_business', countLessThan3Second: 'success_count_platform', percentOfCountLessThan3Second: 'percent_platform', successCountOfBusiness: 'success_count_business', successRateOfBusiness: 'percent_business', successCountOfPlatform: 'success_count_platform', successRateOfPlatform: 'percent_platform', successCountOfMessageReceived: 'success_count_business', successRateOfMessageReceived: 'percent_business', avgRTT: 'average_value', avgDelay: 'average_value', avgValue: 'average_value' } } };
      }(n))), this._configMap.set(ho, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.HEARTBEAT, '.').concat(x.CMD.ALIVE) }), body: {} };
      }(e))), this._configMap.set(_o, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.IM_OPEN_PUSH, '.').concat(x.CMD.MESSAGE_PUSH) }), body: {}, keyMap: { response: { C2cMsgArray: 'C2CMessageArray', GroupMsgArray: 'groupMessageArray', GroupTips: 'groupTips', C2cNotifyMsgArray: 'C2CNotifyMessageArray', ClientSeq: 'clientSequence', MsgPriority: 'priority', NoticeSeq: 'noticeSequence', MsgContent: 'content', MsgType: 'type', MsgBody: 'elements', ToGroupId: 'to', Desc: 'description', Ext: 'extension', IsSyncMsg: 'isSyncMessage', Flag: 'needSync', NeedAck: 'needAck', PendencyAdd_Account: 'userID', ProfileImNick: 'nick', PendencyType: 'applicationType', C2CReadAllMsg: 'readAllC2CMessage' } } };
      }(e))), this._configMap.set(fo, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.OPEN_IM, '.').concat(x.CMD.MESSAGE_PUSH_ACK) }), body: { sessionData: void 0 }, keyMap: { request: { sessionData: 'SessionData' } } };
      }(e))), this._configMap.set(mo, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.IM_OPEN_STATUS, '.').concat(x.CMD.STATUS_FORCEOFFLINE) }), body: {}, keyMap: { response: { C2cNotifyMsgArray: 'C2CNotifyMessageArray', NoticeSeq: 'noticeSequence', KickoutMsgNotify: 'kickoutMsgNotify', NewInstInfo: 'newInstanceInfo' } } };
      }(e))), this._configMap.set(vo, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.IM_LONG_MESSAGE, '.').concat(x.CMD.DOWNLOAD_MERGER_MESSAGE) }), body: { downloadKey: '' }, keyMap: { response: { Data: 'data', Desc: 'description', Ext: 'extension', Download_Flag: 'downloadFlag', ThumbUUID: 'thumbUUID', VideoUUID: 'videoUUID' } } };
      }(e))), this._configMap.set(Mo, (function (e) {
        return { head: r(r({}, e), {}, { servcmd: ''.concat(x.NAME.IM_LONG_MESSAGE, '.').concat(x.CMD.UPLOAD_MERGER_MESSAGE) }), body: { messageList: [] }, keyMap: { request: { fromAccount: 'From_Account', toAccount: 'To_Account', msgTimeStamp: 'MsgTimeStamp', msgSeq: 'MsgSeq', msgRandom: 'MsgRandom', msgBody: 'MsgBody', type: 'MsgType', content: 'MsgContent', data: 'Data', description: 'Desc', extension: 'Ext', sizeType: 'Type', uuid: 'UUID', url: '', imageUrl: 'URL', fileUrl: 'Url', remoteAudioUrl: 'Url', remoteVideoUrl: 'VideoUrl', thumbUUID: 'ThumbUUID', videoUUID: 'VideoUUID', videoUrl: '', downloadFlag: 'Download_Flag', from: 'From_Account', time: 'MsgTimeStamp', messageRandom: 'MsgRandom', messageSequence: 'MsgSeq', elements: 'MsgBody', clientSequence: 'ClientSeq', payload: 'MsgContent', messageList: 'MsgList', messageNumber: 'MsgNum', abstractList: 'AbstractList', messageBody: 'MsgBody' } } };
      }(e)));
    } }, { key: 'has', value(e) {
      return this._configMap.has(e);
    } }, { key: 'get', value(e) {
      return this._configMap.get(e);
    } }, { key: 'update', value() {
      this._fillConfigMap();
    } }, { key: 'getKeyMap', value(e) {
      return this.has(e) ? this.get(e).keyMap || {} : (Oe.warn(''.concat(this._className, '.getKeyMap unknown protocolName:').concat(e)), {});
    } }, { key: 'getProtocolData', value(e) {
      const t = e.protocolName; const n = e.requestData; const o = this.get(t); let a = null;if (n) {
        const s = this._simpleDeepCopy(o); const r = s.body; const i = Object.create(null);for (const c in r) if (Object.prototype.hasOwnProperty.call(r, c)) {
          if (i[c] = r[c], void 0 === n[c]) continue;i[c] = n[c];
        }s.body = i, a = this._getUplinkData(s);
      } else a = this._getUplinkData(o);return a;
    } }, { key: '_getUplinkData', value(e) {
      const t = this._requestDataCleaner(e); const n = ft(t.head); const o = pc(t.body, this._getRequestKeyMap(n));return t.body = o, t;
    } }, { key: '_getRequestKeyMap', value(e) {
      const t = this.getKeyMap(e);return r(r({}, uc.request), t.request);
    } }, { key: '_requestDataCleaner', value(t) {
      const n = Array.isArray(t) ? [] : Object.create(null);for (const o in t)Object.prototype.hasOwnProperty.call(t, o) && He(o) && null !== t[o] && void 0 !== t[o] && ('object' !== e(t[o]) ? n[o] = t[o] : n[o] = this._requestDataCleaner.bind(this)(t[o]));return n;
    } }, { key: '_simpleDeepCopy', value(e) {
      for (var t, n = Object.keys(e), o = {}, a = 0, s = n.length;a < s;a++)t = n[a], Fe(e[t]) ? o[t] = Array.from(e[t]) : Pe(e[t]) ? o[t] = this._simpleDeepCopy(e[t]) : o[t] = e[t];return o;
    } }]), n;
  }()); const Ec = [fo]; const Ac = (function () {
    function e(n) {
      t(this, e), this._sessionModule = n, this._className = 'DownlinkHandler', this._eventHandlerMap = new Map, this._eventHandlerMap.set('C2CMessageArray', this._c2cMessageArrayHandler.bind(this)), this._eventHandlerMap.set('groupMessageArray', this._groupMessageArrayHandler.bind(this)), this._eventHandlerMap.set('groupTips', this._groupTipsHandler.bind(this)), this._eventHandlerMap.set('C2CNotifyMessageArray', this._C2CNotifyMessageArrayHandler.bind(this)), this._eventHandlerMap.set('profileModify', this._profileHandler.bind(this)), this._eventHandlerMap.set('friendListMod', this._relationChainHandler.bind(this)), this._eventHandlerMap.set('recentContactMod', this._recentContactHandler.bind(this)), this._eventHandlerMap.set('readAllC2CMessage', this._allMessageReadHandler.bind(this)), this._keys = M(this._eventHandlerMap.keys());
    } return o(e, [{ key: '_c2cMessageArrayHandler', value(e) {
      const t = this._sessionModule.getModule(Ft);if (t) {
        if (e.dataList.forEach(((e) => {
          if (1 === e.isSyncMessage) {
            const t = e.from;e.from = e.to, e.to = t;
          }
        })), 1 === e.needSync) this._sessionModule.getModule(Jt).startOnlineSync();t.onNewC2CMessage({ dataList: e.dataList, isInstantMessage: !0 });
      }
    } }, { key: '_groupMessageArrayHandler', value(e) {
      const t = this._sessionModule.getModule(qt);t && t.onNewGroupMessage({ event: e.event, dataList: e.dataList, isInstantMessage: !0 });
    } }, { key: '_groupTipsHandler', value(e) {
      const t = this._sessionModule.getModule(qt);if (t) {
        const n = e.event; const o = e.dataList; const a = e.isInstantMessage; const s = void 0 === a || a; const r = e.isSyncingEnded;switch (n) {
          case 4:case 6:t.onNewGroupTips({ event: n, dataList: o });break;case 5:o.forEach(((e) => {
            Fe(e.elements.revokedInfos) ? t.onGroupMessageRevoked({ dataList: o }) : Fe(e.elements.groupMessageReadNotice) ? t.onGroupMessageReadNotice({ dataList: o }) : t.onNewGroupSystemNotice({ dataList: o, isInstantMessage: s, isSyncingEnded: r });
          }));break;case 12:this._sessionModule.getModule(xt).onNewGroupAtTips({ dataList: o });break;default:Oe.log(''.concat(this._className, '._groupTipsHandler unknown event:').concat(n, ' dataList:'), o);
        }
      }
    } }, { key: '_C2CNotifyMessageArrayHandler', value(e) {
      const t = this; const n = e.dataList;if (Fe(n)) {
        const o = this._sessionModule.getModule(Ft);n.forEach(((e) => {
          if (Ue(e)) if (e.hasOwnProperty('kickoutMsgNotify')) {
            const a = e.kickoutMsgNotify; const s = a.kickType; const r = a.newInstanceInfo; const i = void 0 === r ? {} : r;1 === s ? t._sessionModule.onMultipleAccountKickedOut(i) : 2 === s && t._sessionModule.onMultipleDeviceKickedOut(i);
          } else if (e.hasOwnProperty('c2cMessageRevokedNotify'))o && o.onC2CMessageRevoked({ dataList: n });else if (e.hasOwnProperty('c2cMessageReadReceipt'))o && o.onC2CMessageReadReceipt({ dataList: n });else if (e.hasOwnProperty('c2cMessageReadNotice'))o && o.onC2CMessageReadNotice({ dataList: n });else if (e.hasOwnProperty('muteNotificationsSync')) {
            t._sessionModule.getModule(xt).onC2CMessageRemindTypeSynced({ dataList: n });
          }
        }));
      }
    } }, { key: '_profileHandler', value(e) {
      this._sessionModule.getModule(Ut).onProfileModified({ dataList: e.dataList });const t = this._sessionModule.getModule(Vt);t && t.onFriendProfileModified({ dataList: e.dataList });
    } }, { key: '_relationChainHandler', value(e) {
      this._sessionModule.getModule(Ut).onRelationChainModified({ dataList: e.dataList });const t = this._sessionModule.getModule(Vt);t && t.onRelationChainModified({ dataList: e.dataList });
    } }, { key: '_recentContactHandler', value(e) {
      const t = e.dataList;if (Fe(t)) {
        const n = this._sessionModule.getModule(xt);n && t.forEach(((e) => {
          const t = e.pushType; const o = e.recentContactTopItem; const a = e.recentContactDeleteItem;1 === t ? n.onConversationDeleted(a.recentContactList) : 2 === t ? n.onConversationPinned(o.recentContactList) : 3 === t && n.onConversationUnpinned(o.recentContactList);
        }));
      }
    } }, { key: '_allMessageReadHandler', value(e) {
      const t = e.dataList; const n = this._sessionModule.getModule(xt);n && n.onPushedAllMessageRead(t);
    } }, { key: 'onMessage', value(e) {
      const t = this; const n = e.body;if (this._filterMessageFromIMOpenPush(e)) {
        const o = n.eventArray; const a = n.isInstantMessage; const s = n.isSyncingEnded; const r = n.needSync;if (Fe(o)) for (let i = null, c = null, u = 0, l = 0, d = o.length;l < d;l++) {
          u = (i = o[l]).event;const p = Object.keys(i).find((e => -1 !== t._keys.indexOf(e)));p ? (c = 14 !== u ? i[p] : { readAllC2CMessage: i[p], groupMessageReadInfoList: i.groupMessageReadNotice || [] }, this._eventHandlerMap.get(p)({ event: u, dataList: c, isInstantMessage: a, isSyncingEnded: s, needSync: r })) : Oe.log(''.concat(this._className, '.onMessage unknown eventItem:').concat(i));
        }
      }
    } }, { key: '_filterMessageFromIMOpenPush', value(e) {
      const t = e.head; const n = e.body; const o = t.servcmd; let a = !1;if (qe(o) || (a = o.includes(x.NAME.IM_CONFIG_MANAGER) || o.includes(x.NAME.OVERLOAD_PUSH) || o.includes(x.NAME.STAT_SERVICE)), !a) return !0;if (o.includes(x.CMD.PUSHED_CLOUD_CONTROL_CONFIG)) this._sessionModule.getModule(en).onPushedCloudControlConfig(n);else if (o.includes(x.CMD.PUSHED_COMMERCIAL_CONFIG)) {
        this._sessionModule.getModule(an).onPushedConfig(n);
      } else if (o.includes(x.CMD.OVERLOAD_NOTIFY)) this._sessionModule.onPushedServerOverload(n);else if (o.includes(x.CMD.KICK_OTHER)) {
        const s = Date.now();this._sessionModule.reLoginOnKickOther();const r = new Xa(as); const i = this._sessionModule.getModule(bt).getLastWsHelloTs(); const c = s - i;r.setMessage('last wshello time:'.concat(i, ' diff:').concat(c, 'ms')).setNetworkType(this._sessionModule.getNetworkType())
          .end();
      } return !1;
    } }]), e;
  }()); const Nc = [{ cmd: x.CMD.GET_GROUP_INFO, interval: 1, count: 20 }, { cmd: x.CMD.SET_GROUP_ATTRIBUTES, interval: 5, count: 10 }, { cmd: x.CMD.MODIFY_GROUP_ATTRIBUTES, interval: 5, count: 10 }, { cmd: x.CMD.DELETE_GROUP_ATTRIBUTES, interval: 5, count: 10 }, { cmd: x.CMD.CLEAR_GROUP_ATTRIBUTES, interval: 5, count: 10 }, { cmd: x.CMD.GET_GROUP_ATTRIBUTES, interval: 5, count: 20 }, { cmd: x.CMD.SET_ALL_MESSAGE_READ, interval: 1, count: 1 }]; const Lc = (function (e) {
    i(a, e);const n = f(a);function a(e) {
      let o;return t(this, a), (o = n.call(this, e))._className = 'SessionModule', o._platform = o.getPlatform(), o._protocolHandler = new kc(h(o)), o._messageDispatcher = new Ac(h(o)), o._commandFrequencyLimitMap = new Map, o._commandRequestInfoMap = new Map, o._serverOverloadInfoMap = new Map, o._init(), o.getInnerEmitterInstance().on(ci, o._onCloudConfigUpdated, h(o)), o;
    } return o(a, [{ key: '_init', value() {
      this._updateCommandFrequencyLimitMap(Nc);
    } }, { key: '_onCloudConfigUpdated', value() {
      let e = this.getCloudConfig('cmd_frequency_limit');qe(e) || (e = JSON.parse(e), this._updateCommandFrequencyLimitMap(e));
    } }, { key: '_updateCommandFrequencyLimitMap', value(e) {
      const t = this;e.forEach(((e) => {
        t._commandFrequencyLimitMap.set(e.cmd, { interval: e.interval, count: e.count });
      }));
    } }, { key: 'updateProtocolConfig', value() {
      this._protocolHandler.update();
    } }, { key: 'request', value(e) {
      Oe.debug(''.concat(this._className, '.request options:'), e);const t = e.protocolName; const n = e.tjgID;if (!this._protocolHandler.has(t)) return Oe.warn(''.concat(this._className, '.request unknown protocol:').concat(t)), ai({ code: Do.CANNOT_FIND_PROTOCOL, message: Oa });const o = this.getProtocolData(e); const a = o.head.servcmd;if (this._isFrequencyOverLimit(a)) return ai({ code: Do.OVER_FREQUENCY_LIMIT, message: ba });if (this._isServerOverload(a)) return ai({ code: Do.OPEN_SERVICE_OVERLOAD_ERROR, message: Pa });It(n) || (o.head.tjgID = n);const s = this.getModule(Qt);return Ec.includes(t) ? s.simplySend(o) : s.send(o);
    } }, { key: 'getKeyMap', value(e) {
      return this._protocolHandler.getKeyMap(e);
    } }, { key: 'genCommonHead', value() {
      const e = this.getModule(Bt);return { ver: 'v4', platform: this._platform, websdkappid: b, websdkversion: w, a2: e.getA2Key() || void 0, tinyid: e.getTinyID() || void 0, status_instid: e.getStatusInstanceID(), sdkappid: e.getSDKAppID(), contenttype: e.getContentType(), reqtime: 0, identifier: e.getA2Key() ? void 0 : e.getUserID(), usersig: e.getA2Key() ? void 0 : e.getUserSig(), sdkability: 35, tjgID: '' };
    } }, { key: 'genCosSpecifiedHead', value() {
      const e = this.getModule(Bt);return { ver: 'v4', platform: this._platform, websdkappid: b, websdkversion: w, sdkappid: e.getSDKAppID(), contenttype: e.getContentType(), reqtime: 0, identifier: e.getUserID(), usersig: e.getUserSig(), status_instid: e.getStatusInstanceID(), sdkability: 35 };
    } }, { key: 'genSSOReportHead', value() {
      const e = this.getModule(Bt);return { ver: 'v4', platform: this._platform, websdkappid: b, websdkversion: w, sdkappid: e.getSDKAppID(), contenttype: '', reqtime: 0, identifier: '', usersig: '', status_instid: e.getStatusInstanceID(), sdkability: 35 };
    } }, { key: 'getProtocolData', value(e) {
      return this._protocolHandler.getProtocolData(e);
    } }, { key: 'onErrorCodeNotZero', value(e) {
      const t = e.errorCode;if (t === Do.HELLO_ANSWER_KICKED_OUT) {
        const n = e.kickType; const o = e.newInstanceInfo; const a = void 0 === o ? {} : o;1 === n ? this.onMultipleAccountKickedOut(a) : 2 === n && this.onMultipleDeviceKickedOut(a);
      }t !== Do.MESSAGE_A2KEY_EXPIRED && t !== Do.ACCOUNT_A2KEY_EXPIRED || (this._onUserSigExpired(), this.getModule(Qt).reConnect());
    } }, { key: 'onMessage', value(e) {
      const t = e.body; const n = t.needAck; const o = void 0 === n ? 0 : n; const a = t.sessionData;1 === o && this._sendACK(a), this._messageDispatcher.onMessage(e);
    } }, { key: 'onReconnected', value() {
      this._reLoginOnReconnected();
    } }, { key: 'reLoginOnKickOther', value() {
      Oe.log(''.concat(this._className, '.reLoginOnKickOther.')), this._reLogin();
    } }, { key: '_reLoginOnReconnected', value() {
      Oe.log(''.concat(this._className, '._reLoginOnReconnected.')), this._reLogin();
    } }, { key: '_reLogin', value() {
      const e = this;this.isLoggedIn() && this.request({ protocolName: rn }).then(((t) => {
        const n = t.data.instanceID;e.getModule(Bt).setStatusInstanceID(n), Oe.log(''.concat(e._className, '._reLogin ok. start to sync unread messages.')), e.getModule(Jt).startSyncOnReconnected(), e.getModule(nn).startPull(), e.getModule(qt).updateLocalMainSequenceOnReconnected();
      }));
    } }, { key: 'onMultipleAccountKickedOut', value(e) {
      this.getModule(bt).onMultipleAccountKickedOut(e);
    } }, { key: 'onMultipleDeviceKickedOut', value(e) {
      this.getModule(bt).onMultipleDeviceKickedOut(e);
    } }, { key: '_onUserSigExpired', value() {
      this.getModule(bt).onUserSigExpired();
    } }, { key: '_sendACK', value(e) {
      this.request({ protocolName: fo, requestData: { sessionData: e } });
    } }, { key: '_isFrequencyOverLimit', value(e) {
      const t = e.split('.')[1];if (!this._commandFrequencyLimitMap.has(t)) return !1;if (!this._commandRequestInfoMap.has(t)) return this._commandRequestInfoMap.set(t, { startTime: Date.now(), requestCount: 1 }), !1;const n = this._commandFrequencyLimitMap.get(t); const o = n.count; const a = n.interval; const s = this._commandRequestInfoMap.get(t); const r = s.startTime; let i = s.requestCount;if (Date.now() - r > 1e3 * a) return this._commandRequestInfoMap.set(t, { startTime: Date.now(), requestCount: 1 }), !1;i += 1, this._commandRequestInfoMap.set(t, { startTime: r, requestCount: i });let c = !1;return i > o && (c = !0), c;
    } }, { key: '_isServerOverload', value(e) {
      if (!this._serverOverloadInfoMap.has(e)) return !1;const t = this._serverOverloadInfoMap.get(e); const n = t.overloadTime; const o = t.waitingTime; let a = !1;return Date.now() - n <= 1e3 * o ? a = !0 : (this._serverOverloadInfoMap.delete(e), a = !1), a;
    } }, { key: 'onPushedServerOverload', value(e) {
      const t = e.overloadCommand; const n = e.waitingTime;this._serverOverloadInfoMap.set(t, { overloadTime: Date.now(), waitingTime: n }), Oe.warn(''.concat(this._className, '.onPushedServerOverload waitingTime:').concat(n, 's'));
    } }, { key: 'reset', value() {
      Oe.log(''.concat(this._className, '.reset')), this._updateCommandFrequencyLimitMap(Nc), this._commandRequestInfoMap.clear(), this._serverOverloadInfoMap.clear();
    } }]), a;
  }(sn)); const Rc = (function (e) {
    i(a, e);const n = f(a);function a(e) {
      let o;return t(this, a), (o = n.call(this, e))._className = 'MessageLossDetectionModule', o._maybeLostSequencesMap = new Map, o;
    } return o(a, [{ key: 'onMessageMaybeLost', value(e, t, n) {
      this._maybeLostSequencesMap.has(e) || this._maybeLostSequencesMap.set(e, []);for (var o = this._maybeLostSequencesMap.get(e), a = 0;a < n;a++)o.push(t + a);Oe.debug(''.concat(this._className, '.onMessageMaybeLost. maybeLostSequences:').concat(o));
    } }, { key: 'detectMessageLoss', value(e, t) {
      const n = this._maybeLostSequencesMap.get(e);if (!It(n) && !It(t)) {
        const o = t.filter((e => -1 !== n.indexOf(e)));if (Oe.debug(''.concat(this._className, '.detectMessageLoss. matchedSequences:').concat(o)), n.length === o.length)Oe.info(''.concat(this._className, '.detectMessageLoss no message loss. conversationID:').concat(e));else {
          let a; const s = n.filter((e => -1 === o.indexOf(e))); const r = s.length;r <= 5 ? a = `${e}-${s.join('-')}` : (s.sort(((e, t) => e - t)), a = `${e} start:${s[0]} end:${s[r - 1]} count:${r}`), new Xa(dr).setMessage(a)
            .setNetworkType(this.getNetworkType())
            .setLevel('warning')
            .end(), Oe.warn(''.concat(this._className, '.detectMessageLoss message loss detected. conversationID:').concat(e, ' lostSequences:')
            .concat(s));
        }n.length = 0;
      }
    } }, { key: 'reset', value() {
      Oe.log(''.concat(this._className, '.reset')), this._maybeLostSequencesMap.clear();
    } }]), a;
  }(sn)); const Oc = (function (e) {
    i(a, e);const n = f(a);function a(e) {
      let o;return t(this, a), (o = n.call(this, e))._className = 'CloudControlModule', o._cloudConfig = new Map, o._expiredTime = 0, o._version = 0, o._isFetching = !1, o;
    } return o(a, [{ key: 'getCloudConfig', value(e) {
      return qe(e) ? this._cloudConfig : this._cloudConfig.has(e) ? this._cloudConfig.get(e) : void 0;
    } }, { key: '_canFetchConfig', value() {
      return this.isLoggedIn() && !this._isFetching && Date.now() >= this._expiredTime;
    } }, { key: 'fetchConfig', value() {
      const e = this; const t = this._canFetchConfig();if (Oe.log(''.concat(this._className, '.fetchConfig canFetchConfig:').concat(t)), t) {
        const n = new Xa(vr); const o = this.getModule(Bt).getSDKAppID();this._isFetching = !0, this.request({ protocolName: yo, requestData: { SDKAppID: o, version: this._version } }).then(((t) => {
          e._isFetching = !1, n.setMessage('version:'.concat(e._version, ' newVersion:').concat(t.data.version, ' config:')
            .concat(t.data.cloudControlConfig)).setNetworkType(e.getNetworkType())
            .end(), Oe.log(''.concat(e._className, '.fetchConfig ok')), e._parseCloudControlConfig(t.data);
        }))
          .catch(((t) => {
            e._isFetching = !1, e.probeNetwork().then(((e) => {
              const o = m(e, 2); const a = o[0]; const s = o[1];n.setError(t, a, s).end();
            })), Oe.log(''.concat(e._className, '.fetchConfig failed. error:'), t), e._setExpiredTimeOnResponseError(12e4);
          }));
      }
    } }, { key: 'onPushedCloudControlConfig', value(e) {
      Oe.log(''.concat(this._className, '.onPushedCloudControlConfig')), new Xa(yr).setNetworkType(this.getNetworkType())
        .setMessage('newVersion:'.concat(e.version, ' config:').concat(e.cloudControlConfig))
        .end(), this._parseCloudControlConfig(e);
    } }, { key: 'onCheckTimer', value(e) {
      this._canFetchConfig() && this.fetchConfig();
    } }, { key: '_parseCloudControlConfig', value(e) {
      const t = this; const n = ''.concat(this._className, '._parseCloudControlConfig'); const o = e.errorCode; const a = e.errorMessage; const s = e.cloudControlConfig; const r = e.version; const i = e.expiredTime;if (0 === o) {
        if (this._version !== r) {
          let c = null;try {
            c = JSON.parse(s);
          } catch (u) {
            Oe.error(''.concat(n, ' JSON parse error:').concat(s));
          }c && (this._cloudConfig.clear(), Object.keys(c).forEach(((e) => {
            t._cloudConfig.set(e, c[e]);
          })), this._version = r, this.emitInnerEvent(ci));
        } this._expiredTime = Date.now() + 1e3 * i;
      } else qe(o) ? (Oe.log(''.concat(n, ' failed. Invalid message format:'), e), this._setExpiredTimeOnResponseError(36e5)) : (Oe.error(''.concat(n, ' errorCode:').concat(o, ' errorMessage:')
        .concat(a)), this._setExpiredTimeOnResponseError(12e4));
    } }, { key: '_setExpiredTimeOnResponseError', value(e) {
      this._expiredTime = Date.now() + e;
    } }, { key: 'reset', value() {
      Oe.log(''.concat(this._className, '.reset')), this._cloudConfig.clear(), this._expiredTime = 0, this._version = 0, this._isFetching = !1;
    } }]), a;
  }(sn)); const Gc = (function (e) {
    i(a, e);const n = f(a);function a(e) {
      let o;return t(this, a), (o = n.call(this, e))._className = 'PullGroupMessageModule', o._remoteLastMessageSequenceMap = new Map, o.PULL_LIMIT_COUNT = 15, o;
    } return o(a, [{ key: 'startPull', value() {
      const e = this; const t = this._getNeedPullConversationList();this._getRemoteLastMessageSequenceList().then((() => {
        const n = e.getModule(xt);t.forEach(((t) => {
          const o = t.conversationID; const a = o.replace(k.CONV_GROUP, ''); const s = n.getGroupLocalLastMessageSequence(o); const r = e._remoteLastMessageSequenceMap.get(a) || 0; const i = r - s;Oe.log(''.concat(e._className, '.startPull groupID:').concat(a, ' localLastMessageSequence:')
            .concat(s, ' ') + 'remoteLastMessageSequence:'.concat(r, ' diff:').concat(i)), s > 0 && i >= 1 && i < 300 && e._pullMissingMessage({ groupID: a, localLastMessageSequence: s, remoteLastMessageSequence: r, diff: i });
        }));
      }));
    } }, { key: '_getNeedPullConversationList', value() {
      return this.getModule(xt).getLocalConversationList()
        .filter((e => e.type === k.CONV_GROUP && e.groupProfile.type !== k.GRP_AVCHATROOM));
    } }, { key: '_getRemoteLastMessageSequenceList', value() {
      const e = this;return this.getModule(qt).getGroupList()
        .then(((t) => {
          for (let n = t.data.groupList, o = void 0 === n ? [] : n, a = 0;a < o.length;a++) {
            const s = o[a]; const r = s.groupID; const i = s.nextMessageSeq;if (s.type !== k.GRP_AVCHATROOM) {
              const c = i - 1;e._remoteLastMessageSequenceMap.set(r, c);
            }
          }
        }));
    } }, { key: '_pullMissingMessage', value(e) {
      const t = this; const n = e.localLastMessageSequence; const o = e.remoteLastMessageSequence; const a = e.diff;e.count = a > this.PULL_LIMIT_COUNT ? this.PULL_LIMIT_COUNT : a, e.sequence = a > this.PULL_LIMIT_COUNT ? n + this.PULL_LIMIT_COUNT : n + a, this._getGroupMissingMessage(e).then(((s) => {
        s.length > 0 && (s[0].sequence + 1 <= o && (e.localLastMessageSequence = n + t.PULL_LIMIT_COUNT, e.diff = a - t.PULL_LIMIT_COUNT, t._pullMissingMessage(e)), t.getModule(qt).onNewGroupMessage({ dataList: s, isInstantMessage: !1 }));
      }));
    } }, { key: '_getGroupMissingMessage', value(e) {
      const t = this; const n = new Xa(Ys);return this.request({ protocolName: Yn, requestData: { groupID: e.groupID, count: e.count, sequence: e.sequence } }).then(((o) => {
        const a = o.data.messageList; const s = void 0 === a ? [] : a;return n.setNetworkType(t.getNetworkType()).setMessage('groupID:'.concat(e.groupID, ' count:').concat(e.count, ' sequence:')
          .concat(e.sequence, ' messageList length:')
          .concat(s.length))
          .end(), s;
      }))
        .catch(((e) => {
          t.probeNetwork().then(((t) => {
            const o = m(t, 2); const a = o[0]; const s = o[1];n.setError(e, a, s).end();
          }));
        }));
    } }, { key: 'reset', value() {
      Oe.log(''.concat(this._className, '.reset')), this._remoteLastMessageSequenceMap.clear();
    } }]), a;
  }(sn)); const wc = (function () {
    function e() {
      t(this, e), this._className = 'AvgE2EDelay', this._e2eDelayArray = [];
    } return o(e, [{ key: 'addMessageDelay', value(e) {
      const t = mt(e.currentTime / 1e3 - e.time, 2);this._e2eDelayArray.push(t);
    } }, { key: '_calcAvg', value(e, t) {
      if (0 === t) return 0;let n = 0;return e.forEach(((e) => {
        n += e;
      })), mt(n / t, 1);
    } }, { key: '_calcTotalCount', value() {
      return this._e2eDelayArray.length;
    } }, { key: '_calcCountWithLimit', value(e) {
      const t = e.e2eDelayArray; const n = e.min; const o = e.max;return t.filter((e => n < e && e <= o)).length;
    } }, { key: '_calcPercent', value(e, t) {
      let n = mt(e / t * 100, 2);return n > 100 && (n = 100), n;
    } }, { key: '_checkE2EDelayException', value(e, t) {
      const n = e.filter((e => e > t));if (n.length > 0) {
        const o = n.length; const a = Math.min.apply(Math, M(n)); const s = Math.max.apply(Math, M(n)); const r = this._calcAvg(n, o); const i = mt(o / e.length * 100, 2);new Xa(Ds).setMessage('message e2e delay exception. count:'.concat(o, ' min:').concat(a, ' max:')
          .concat(s, ' avg:')
          .concat(r, ' percent:')
          .concat(i))
          .setLevel('warning')
          .end();
      }
    } }, { key: 'getStatResult', value() {
      const e = this._calcTotalCount();if (0 === e) return null;const t = M(this._e2eDelayArray); const n = this._calcCountWithLimit({ e2eDelayArray: t, min: 0, max: 1 }); const o = this._calcCountWithLimit({ e2eDelayArray: t, min: 1, max: 3 }); const a = this._calcPercent(n, e); const s = this._calcPercent(o, e); const r = this._calcAvg(t, e);return this._checkE2EDelayException(t, 3), this.reset(), { totalCount: e, countLessThan1Second: n, percentOfCountLessThan1Second: a, countLessThan3Second: o, percentOfCountLessThan3Second: s, avgDelay: r };
    } }, { key: 'reset', value() {
      this._e2eDelayArray.length = 0;
    } }]), e;
  }()); const bc = (function () {
    function e() {
      t(this, e), this._className = 'AvgRTT', this._requestCount = 0, this._rttArray = [];
    } return o(e, [{ key: 'addRequestCount', value() {
      this._requestCount += 1;
    } }, { key: 'addRTT', value(e) {
      this._rttArray.push(e);
    } }, { key: '_calcTotalCount', value() {
      return this._requestCount;
    } }, { key: '_calcRTTCount', value(e) {
      return e.length;
    } }, { key: '_calcSuccessRateOfRequest', value(e, t) {
      if (0 === t) return 0;let n = mt(e / t * 100, 2);return n > 100 && (n = 100), n;
    } }, { key: '_calcAvg', value(e, t) {
      if (0 === t) return 0;let n = 0;return e.forEach(((e) => {
        n += e;
      })), parseInt(n / t);
    } }, { key: '_calcMax', value() {
      return Math.max.apply(Math, M(this._rttArray));
    } }, { key: '_calcMin', value() {
      return Math.min.apply(Math, M(this._rttArray));
    } }, { key: 'getStatResult', value() {
      const e = this._calcTotalCount(); const t = M(this._rttArray);if (0 === e) return null;const n = this._calcRTTCount(t); const o = this._calcSuccessRateOfRequest(n, e); const a = this._calcAvg(t, n);return Oe.log(''.concat(this._className, '.getStatResult max:').concat(this._calcMax(), ' min:')
        .concat(this._calcMin(), ' avg:')
        .concat(a)), this.reset(), { totalCount: e, rttCount: n, successRateOfRequest: o, avgRTT: a };
    } }, { key: 'reset', value() {
      this._requestCount = 0, this._rttArray.length = 0;
    } }]), e;
  }()); const Pc = (function () {
    function e() {
      t(this, e), this._map = new Map;
    } return o(e, [{ key: 'initMap', value(e) {
      const t = this;e.forEach(((e) => {
        t._map.set(e, { totalCount: 0, successCount: 0, failedCountOfUserSide: 0, costArray: [], fileSizeArray: [] });
      }));
    } }, { key: 'addTotalCount', value(e) {
      return !(qe(e) || !this._map.has(e)) && (this._map.get(e).totalCount += 1, !0);
    } }, { key: 'addSuccessCount', value(e) {
      return !(qe(e) || !this._map.has(e)) && (this._map.get(e).successCount += 1, !0);
    } }, { key: 'addFailedCountOfUserSide', value(e) {
      return !(qe(e) || !this._map.has(e)) && (this._map.get(e).failedCountOfUserSide += 1, !0);
    } }, { key: 'addCost', value(e, t) {
      return !(qe(e) || !this._map.has(e)) && (this._map.get(e).costArray.push(t), !0);
    } }, { key: 'addFileSize', value(e, t) {
      return !(qe(e) || !this._map.has(e)) && (this._map.get(e).fileSizeArray.push(t), !0);
    } }, { key: '_calcSuccessRateOfBusiness', value(e) {
      if (qe(e) || !this._map.has(e)) return -1;const t = this._map.get(e); let n = mt(t.successCount / t.totalCount * 100, 2);return n > 100 && (n = 100), n;
    } }, { key: '_calcSuccessRateOfPlatform', value(e) {
      if (qe(e) || !this._map.has(e)) return -1;const t = this._map.get(e); let n = this._calcSuccessCountOfPlatform(e) / t.totalCount * 100;return (n = mt(n, 2)) > 100 && (n = 100), n;
    } }, { key: '_calcTotalCount', value(e) {
      return qe(e) || !this._map.has(e) ? -1 : this._map.get(e).totalCount;
    } }, { key: '_calcSuccessCountOfBusiness', value(e) {
      return qe(e) || !this._map.has(e) ? -1 : this._map.get(e).successCount;
    } }, { key: '_calcSuccessCountOfPlatform', value(e) {
      if (qe(e) || !this._map.has(e)) return -1;const t = this._map.get(e);return t.successCount + t.failedCountOfUserSide;
    } }, { key: '_calcAvg', value(e) {
      return qe(e) || !this._map.has(e) ? -1 : e === Ba ? this._calcAvgSpeed(e) : this._calcAvgCost(e);
    } }, { key: '_calcAvgCost', value(e) {
      const t = this._map.get(e).costArray.length;if (0 === t) return 0;let n = 0;return this._map.get(e).costArray.forEach(((e) => {
        n += e;
      })), parseInt(n / t);
    } }, { key: '_calcAvgSpeed', value(e) {
      let t = 0; let n = 0;return this._map.get(e).costArray.forEach(((e) => {
        t += e;
      })), this._map.get(e).fileSizeArray.forEach(((e) => {
        n += e;
      })), parseInt(1e3 * n / t);
    } }, { key: 'getStatResult', value(e) {
      const t = this._calcTotalCount(e);if (0 === t) return null;const n = this._calcSuccessCountOfBusiness(e); const o = this._calcSuccessRateOfBusiness(e); const a = this._calcSuccessCountOfPlatform(e); const s = this._calcSuccessRateOfPlatform(e); const r = this._calcAvg(e);return this.reset(e), { totalCount: t, successCountOfBusiness: n, successRateOfBusiness: o, successCountOfPlatform: a, successRateOfPlatform: s, avgValue: r };
    } }, { key: 'reset', value(e) {
      qe(e) ? this._map.clear() : this._map.set(e, { totalCount: 0, successCount: 0, failedCountOfUserSide: 0, costArray: [], fileSizeArray: [] });
    } }]), e;
  }()); const Uc = (function () {
    function e() {
      t(this, e), this._lastMap = new Map, this._currentMap = new Map;
    } return o(e, [{ key: 'initMap', value(e) {
      const t = this;e.forEach(((e) => {
        t._lastMap.set(e, new Map), t._currentMap.set(e, new Map);
      }));
    } }, { key: 'addMessageSequence', value(e) {
      const t = e.key; const n = e.message;if (qe(t) || !this._lastMap.has(t) || !this._currentMap.has(t)) return !1;const o = n.conversationID; const a = n.sequence; const s = o.replace(k.CONV_GROUP, '');if (0 === this._lastMap.get(t).size) this._addCurrentMap(e);else if (this._lastMap.get(t).has(s)) {
        const r = this._lastMap.get(t).get(s); const i = r.length - 1;a > r[0] && a < r[i] ? (r.push(a), r.sort(), this._lastMap.get(t).set(s, r)) : this._addCurrentMap(e);
      } else this._addCurrentMap(e);return !0;
    } }, { key: '_addCurrentMap', value(e) {
      const t = e.key; const n = e.message; const o = n.conversationID; const a = n.sequence; const s = o.replace(k.CONV_GROUP, '');this._currentMap.get(t).has(s) || this._currentMap.get(t).set(s, []), this._currentMap.get(t).get(s)
        .push(a);
    } }, { key: '_copyData', value(e) {
      if (!qe(e)) {
        this._lastMap.set(e, new Map);let t; let n = this._lastMap.get(e); const o = S(this._currentMap.get(e));try {
          for (o.s();!(t = o.n()).done;) {
            const a = m(t.value, 2); const s = a[0]; const r = a[1];n.set(s, r);
          }
        } catch (i) {
          o.e(i);
        } finally {
          o.f();
        }n = null, this._currentMap.set(e, new Map);
      }
    } }, { key: 'getStatResult', value(e) {
      if (qe(this._currentMap.get(e)) || qe(this._lastMap.get(e))) return null;if (0 === this._lastMap.get(e).size) return this._copyData(e), null;let t = 0; let n = 0;if (this._lastMap.get(e).forEach(((e, o) => {
        const a = M(e.values()); const s = a.length; const r = a[s - 1] - a[0] + 1;t += r, n += s;
      })), 0 === t) return null;let o = mt(n / t * 100, 2);return o > 100 && (o = 100), this._copyData(e), { totalCount: t, successCountOfMessageReceived: n, successRateOfMessageReceived: o };
    } }, { key: 'reset', value() {
      this._currentMap.clear(), this._lastMap.clear();
    } }]), e;
  }()); const Fc = (function (e) {
    i(a, e);const n = f(a);function a(e) {
      let o;t(this, a), (o = n.call(this, e))._className = 'QualityStatModule', o.TAG = 'im-ssolog-quality-stat', o.reportIndex = 0, o.wholePeriod = !1, o._qualityItems = [Ua, Fa, qa, Va, Ka, xa, Ba, Ha, ja, Wa], o._messageSentItems = [qa, Va, Ka, xa, Ba], o._messageReceivedItems = [Ha, ja, Wa], o.REPORT_INTERVAL = 120, o.REPORT_SDKAPPID_BLACKLIST = [], o.REPORT_TINYID_WHITELIST = [], o._statInfoArr = [], o._avgRTT = new bc, o._avgE2EDelay = new wc, o._rateMessageSent = new Pc, o._rateMessageReceived = new Uc;const s = o.getInnerEmitterInstance();return s.on(ii, o._onLoginSuccess, h(o)), s.on(ci, o._onCloudConfigUpdated, h(o)), o;
    } return o(a, [{ key: '_onLoginSuccess', value() {
      const e = this;this._rateMessageSent.initMap(this._messageSentItems), this._rateMessageReceived.initMap(this._messageReceivedItems);const t = this.getModule(Ht); const n = t.getItem(this.TAG, !1);!It(n) && Ke(n.forEach) && (Oe.log(''.concat(this._className, '._onLoginSuccess.get quality stat log in storage, nums=').concat(n.length)), n.forEach(((t) => {
        e._statInfoArr.push(t);
      })), t.removeItem(this.TAG, !1));
    } }, { key: '_onCloudConfigUpdated', value() {
      const e = this.getCloudConfig('q_rpt_interval'); const t = this.getCloudConfig('q_rpt_sdkappid_bl'); const n = this.getCloudConfig('q_rpt_tinyid_wl');qe(e) || (this.REPORT_INTERVAL = Number(e)), qe(t) || (this.REPORT_SDKAPPID_BLACKLIST = t.split(',').map((e => Number(e)))), qe(n) || (this.REPORT_TINYID_WHITELIST = n.split(','));
    } }, { key: 'onCheckTimer', value(e) {
      this.isLoggedIn() && e % this.REPORT_INTERVAL == 0 && (this.wholePeriod = !0, this._report());
    } }, { key: 'addRequestCount', value() {
      this._avgRTT.addRequestCount();
    } }, { key: 'addRTT', value(e) {
      this._avgRTT.addRTT(e);
    } }, { key: 'addMessageDelay', value(e) {
      this._avgE2EDelay.addMessageDelay(e);
    } }, { key: 'addTotalCount', value(e) {
      this._rateMessageSent.addTotalCount(e) || Oe.warn(''.concat(this._className, '.addTotalCount invalid key:'), e);
    } }, { key: 'addSuccessCount', value(e) {
      this._rateMessageSent.addSuccessCount(e) || Oe.warn(''.concat(this._className, '.addSuccessCount invalid key:'), e);
    } }, { key: 'addFailedCountOfUserSide', value(e) {
      this._rateMessageSent.addFailedCountOfUserSide(e) || Oe.warn(''.concat(this._className, '.addFailedCountOfUserSide invalid key:'), e);
    } }, { key: 'addCost', value(e, t) {
      this._rateMessageSent.addCost(e, t) || Oe.warn(''.concat(this._className, '.addCost invalid key or cost:'), e, t);
    } }, { key: 'addFileSize', value(e, t) {
      this._rateMessageSent.addFileSize(e, t) || Oe.warn(''.concat(this._className, '.addFileSize invalid key or size:'), e, t);
    } }, { key: 'addMessageSequence', value(e) {
      this._rateMessageReceived.addMessageSequence(e) || Oe.warn(''.concat(this._className, '.addMessageSequence invalid key:'), e.key);
    } }, { key: '_getQualityItem', value(e) {
      let t = {}; let n = za[this.getNetworkType()];qe(n) && (n = 8);const o = { qualityType: Ya[e], timestamp: Ee(), networkType: n, extension: '' };switch (e) {
        case Ua:t = this._avgRTT.getStatResult();break;case Fa:t = this._avgE2EDelay.getStatResult();break;case qa:case Va:case Ka:case xa:case Ba:t = this._rateMessageSent.getStatResult(e);break;case Ha:case ja:case Wa:t = this._rateMessageReceived.getStatResult(e);
      } return null === t ? null : r(r({}, o), t);
    } }, { key: '_report', value(e) {
      const t = this; let n = []; let o = null;qe(e) ? this._qualityItems.forEach(((e) => {
        null !== (o = t._getQualityItem(e)) && (o.reportIndex = t.reportIndex, o.wholePeriod = t.wholePeriod, n.push(o));
      })) : null !== (o = this._getQualityItem(e)) && (o.reportIndex = this.reportIndex, o.wholePeriod = this.wholePeriod, n.push(o)), Oe.debug(''.concat(this._className, '._report'), n), this._statInfoArr.length > 0 && (n = n.concat(this._statInfoArr), this._statInfoArr = []);const a = this.getModule(Bt); const s = a.getSDKAppID(); const r = a.getTinyID();Mt(this.REPORT_SDKAPPID_BLACKLIST, s) && !vt(this.REPORT_TINYID_WHITELIST, r) && (n = []), n.length > 0 && this._doReport(n);
    } }, { key: '_doReport', value(e) {
      const t = this; const n = { header: zi(this), quality: e };this.request({ protocolName: go, requestData: r({}, n) }).then((() => {
        t.reportIndex++, t.wholePeriod = !1;
      }))
        .catch(((n) => {
          Oe.warn(''.concat(t._className, '._doReport, online:').concat(t.getNetworkType(), ' error:'), n), t._statInfoArr = t._statInfoArr.concat(e), t._flushAtOnce();
        }));
    } }, { key: '_flushAtOnce', value() {
      const e = this.getModule(Ht); const t = e.getItem(this.TAG, !1); const n = this._statInfoArr;if (It(t))Oe.log(''.concat(this._className, '._flushAtOnce count:').concat(n.length)), e.setItem(this.TAG, n, !0, !1);else {
        let o = n.concat(t);o.length > 10 && (o = o.slice(0, 10)), Oe.log(''.concat(this.className, '._flushAtOnce count:').concat(o.length)), e.setItem(this.TAG, o, !0, !1);
      } this._statInfoArr = [];
    } }, { key: 'reset', value() {
      Oe.log(''.concat(this._className, '.reset')), this._report(), this.reportIndex = 0, this.wholePeriod = !1, this.REPORT_SDKAPPID_BLACKLIST = [], this.REPORT_TINYID_WHITELIST = [], this._avgRTT.reset(), this._avgE2EDelay.reset(), this._rateMessageSent.reset(), this._rateMessageReceived.reset();
    } }]), a;
  }(sn)); const qc = (function (e) {
    i(a, e);const n = f(a);function a(e) {
      let o;return t(this, a), (o = n.call(this, e))._className = 'WorkerModule', o._isWorkerEnabled = !1, o._workerTimer = null, o._init(), o.getInnerEmitterInstance().on(ci, o._onCloudConfigUpdated, h(o)), o;
    } return o(a, [{ key: 'isWorkerEnabled', value() {
      return this._isWorkerEnabled && ye && this._workerTimer;
    } }, { key: 'startWorkerTimer', value() {
      Oe.log(''.concat(this._className, '.startWorkerTimer')), this._workerTimer && this._workerTimer.postMessage('start');
    } }, { key: 'stopWorkerTimer', value() {
      Oe.log(''.concat(this._className, '.stopWorkerTimer')), this._workerTimer && this._workerTimer.postMessage('stop');
    } }, { key: '_init', value() {
      if (ye) {
        const e = URL.createObjectURL(new Blob(['let interval = -1;onmessage = function(event) {  if (event.data === "start") {    if (interval > 0) {      clearInterval(interval);    }    interval = setInterval(() => {      postMessage("");    }, 1000)  } else if (event.data === "stop") {    clearInterval(interval);    interval = -1;  }};'], { type: 'application/javascript; charset=utf-8' }));this._workerTimer = new Worker(e);const t = this;this._workerTimer.onmessage = function () {
          t._moduleManager.onCheckTimer();
        };
      }
    } }, { key: '_onCloudConfigUpdated', value() {
      '1' === this.getCloudConfig('enable_worker') ? !this._isWorkerEnabled && ye && (this._isWorkerEnabled = !0, this.startWorkerTimer(), this._moduleManager.onWorkerTimerEnabled()) : this._isWorkerEnabled && ye && (this._isWorkerEnabled = !1, this.stopWorkerTimer(), this._moduleManager.onWorkerTimerDisabled());
    } }, { key: 'terminate', value() {
      Oe.log(''.concat(this._className, '.terminate')), this._workerTimer && (this._workerTimer.terminate(), this._workerTimer = null);
    } }, { key: 'reset', value() {
      Oe.log(''.concat(this._className, '.reset'));
    } }]), a;
  }(sn)); const Vc = (function () {
    function e() {
      t(this, e), this._className = 'PurchasedFeatureHandler', this._purchasedFeatureMap = new Map;
    } return o(e, [{ key: 'isValidPurchaseBits', value(e) {
      return e && 'string' === typeof e && e.length >= 1 && e.length <= 64 && /[01]{1,64}/.test(e);
    } }, { key: 'parsePurchaseBits', value(e) {
      const t = ''.concat(this._className, '.parsePurchaseBits');if (this.isValidPurchaseBits(e)) {
        this._purchasedFeatureMap.clear();for (let n = Object.values(B), o = null, a = e.length - 1, s = 0;a >= 0;a--, s++)o = s < 32 ? new R(0, Math.pow(2, s)).toString() : new R(Math.pow(2, s - 32), 0).toString(), -1 !== n.indexOf(o) && ('1' === e[a] ? this._purchasedFeatureMap.set(o, !0) : this._purchasedFeatureMap.set(o, !1));
      } else Oe.warn(''.concat(t, ' invalid purchase bits:').concat(e));
    } }, { key: 'hasPurchasedFeature', value(e) {
      return !!this._purchasedFeatureMap.get(e);
    } }, { key: 'clear', value() {
      this._purchasedFeatureMap.clear();
    } }]), e;
  }()); const Kc = (function (e) {
    i(a, e);const n = f(a);function a(e) {
      let o;return t(this, a), (o = n.call(this, e))._className = 'CommercialConfigModule', o._expiredTime = 0, o._isFetching = !1, o._purchasedFeatureHandler = new Vc, o;
    } return o(a, [{ key: '_canFetch', value() {
      return this.isLoggedIn() ? !this._isFetching && Date.now() >= this._expiredTime : (this._expiredTime = Date.now() + 2e3, !1);
    } }, { key: 'onCheckTimer', value(e) {
      this._canFetch() && this.fetchConfig();
    } }, { key: 'fetchConfig', value() {
      const e = this; const t = this._canFetch(); const n = ''.concat(this._className, '.fetchConfig');if (Oe.log(''.concat(n, ' canFetch:').concat(t)), t) {
        const o = new Xa(Ir);o.setNetworkType(this.getNetworkType());const a = this.getModule(Bt).getSDKAppID();this._isFetching = !0, this.request({ protocolName: Co, requestData: { SDKAppID: a } }).then(((t) => {
          o.setMessage('purchaseBits:'.concat(t.data.purchaseBits)).end(), Oe.log(''.concat(n, ' ok.')), e._parseConfig(t.data), e._isFetching = !1;
        }))
          .catch(((t) => {
            e.probeNetwork().then(((e) => {
              const n = m(e, 2); const a = n[0]; const s = n[1];o.setError(t, a, s).end();
            })), e._isFetching = !1;
          }));
      }
    } }, { key: 'onPushedConfig', value(e) {
      const t = ''.concat(this._className, '.onPushedConfig');Oe.log(''.concat(t)), new Xa(Cr).setNetworkType(this.getNetworkType())
        .setMessage('purchaseBits:'.concat(e.purchaseBits))
        .end(), this._parseConfig(e);
    } }, { key: '_parseConfig', value(e) {
      const t = ''.concat(this._className, '._parseConfig'); const n = e.errorCode; const o = e.errorMessage; const a = e.purchaseBits; const s = e.expiredTime;0 === n ? (this._purchasedFeatureHandler.parsePurchaseBits(a), this._expiredTime = Date.now() + 1e3 * s) : qe(n) ? (Oe.log(''.concat(t, ' failed. Invalid message format:'), e), this._setExpiredTimeOnResponseError(36e5)) : (Oe.error(''.concat(t, ' errorCode:').concat(n, ' errorMessage:')
        .concat(o)), this._setExpiredTimeOnResponseError(12e4));
    } }, { key: '_setExpiredTimeOnResponseError', value(e) {
      this._expiredTime = Date.now() + e;
    } }, { key: 'hasPurchasedFeature', value(e) {
      return this._purchasedFeatureHandler.hasPurchasedFeature(e);
    } }, { key: 'reset', value() {
      Oe.log(''.concat(this._className, '.reset')), this._expiredTime = 0, this._isFetching = !1, this._purchasedFeatureHandler.clear();
    } }]), a;
  }(sn)); const xc = (function () {
    function e(n) {
      t(this, e);const o = new Xa(Qa);this._className = 'ModuleManager', this._isReady = !1, this._startLoginTs = 0, this._moduleMap = new Map, this._innerEmitter = null, this._outerEmitter = null, this._checkCount = 0, this._checkTimer = -1, this._moduleMap.set(Bt, new Hi(this, n)), this._moduleMap.set(an, new Kc(this)), this._moduleMap.set(en, new Oc(this)), this._moduleMap.set(tn, new qc(this)), this._moduleMap.set(on, new Fc(this)), this._moduleMap.set(Qt, new Dc(this)), this._moduleMap.set(Xt, new Lc(this)), this._moduleMap.set(bt, new ji(this)), this._moduleMap.set(Pt, new rc(this)), this._moduleMap.set(Ut, new Bi(this)), this._moduleMap.set(Ft, new si(this)), this._moduleMap.set(xt, new ki(this)), this._moduleMap.set(qt, new Ui(this)), this._moduleMap.set(Kt, new qi(this)), this._moduleMap.set(Ht, new Yi(this)), this._moduleMap.set(jt, new Ji(this)), this._moduleMap.set(Wt, new Zi(this)), this._moduleMap.set(Yt, new tc(this)), this._moduleMap.set($t, new nc(this)), this._moduleMap.set(zt, new ic(this)), this._moduleMap.set(Jt, new cc(this)), this._moduleMap.set(Zt, new Rc(this)), this._moduleMap.set(nn, new Gc(this));const a = n.instanceID; const s = n.oversea; const r = n.SDKAppID; const i = 'instanceID:'.concat(a, ' SDKAppID:').concat(r, ' host:')
        .concat(gt(), ' oversea:')
        .concat(s, ' inBrowser:')
        .concat(te, ' inMiniApp:')
        .concat(ee) + ' workerAvailable:'.concat(ye, ' UserAgent:').concat(ae);Xa.bindEventStatModule(this._moduleMap.get(jt)), o.setMessage(''.concat(i, ' ').concat(function () {
        let e = '';if (ee) try {
          const t = ne.getSystemInfoSync(); const n = t.model; const o = t.version; const a = t.system; const s = t.platform; const r = t.SDKVersion;e = 'model:'.concat(n, ' version:').concat(o, ' system:')
            .concat(a, ' platform:')
            .concat(s, ' SDKVersion:')
            .concat(r);
        } catch (i) {
          e = '';
        } return e;
      }())).end(), Oe.info('SDK '.concat(i)), this._readyList = void 0, this._ssoLogForReady = null, this._initReadyList();
    } return o(e, [{ key: '_startTimer', value() {
      const e = this._moduleMap.get(tn).isWorkerEnabled();Oe.log(''.concat(this._className, '.startTimer isWorkerEnabled:').concat(e, ' seed:')
        .concat(this._checkTimer)), e ? this._moduleMap.get(tn).startWorkerTimer() : this._startMainThreadTimer();
    } }, { key: '_startMainThreadTimer', value() {
      Oe.log(''.concat(this._className, '._startMainThreadTimer')), this._checkTimer < 0 && (this._checkTimer = setInterval(this.onCheckTimer.bind(this), 1e3));
    } }, { key: 'stopTimer', value() {
      const e = this._moduleMap.get(tn).isWorkerEnabled();Oe.log(''.concat(this._className, '.stopTimer isWorkerEnabled:').concat(e, ' seed:')
        .concat(this._checkTimer)), e ? this._moduleMap.get(tn).stopWorkerTimer() : this._stopMainThreadTimer();
    } }, { key: '_stopMainThreadTimer', value() {
      Oe.log(''.concat(this._className, '._stopMainThreadTimer')), this._checkTimer > 0 && (clearInterval(this._checkTimer), this._checkTimer = -1, this._checkCount = 0);
    } }, { key: 'onWorkerTimerEnabled', value() {
      Oe.log(''.concat(this._className, '.onWorkerTimerEnabled, disable main thread timer')), this._stopMainThreadTimer();
    } }, { key: 'onWorkerTimerDisabled', value() {
      Oe.log(''.concat(this._className, '.onWorkerTimerDisabled, enable main thread timer')), this._startMainThreadTimer();
    } }, { key: 'onCheckTimer', value() {
      this._checkCount += 1;let e; const t = S(this._moduleMap);try {
        for (t.s();!(e = t.n()).done;) {
          const n = m(e.value, 2)[1];n.onCheckTimer && n.onCheckTimer(this._checkCount);
        }
      } catch (o) {
        t.e(o);
      } finally {
        t.f();
      }
    } }, { key: '_initReadyList', value() {
      const e = this;this._readyList = [this._moduleMap.get(bt), this._moduleMap.get(xt)], this._readyList.forEach(((t) => {
        t.ready((() => e._onModuleReady()));
      }));
    } }, { key: '_onModuleReady', value() {
      let e = !0;if (this._readyList.forEach(((t) => {
        t.isReady() || (e = !1);
      })), e && !this._isReady) {
        this._isReady = !0, this._outerEmitter.emit(D.SDK_READY);const t = Date.now() - this._startLoginTs;Oe.warn('SDK is ready. cost '.concat(t, ' ms')), this._startLoginTs = Date.now();const n = this._moduleMap.get(Wt).getNetworkType(); const o = this._ssoLogForReady.getStartTs() + ke;this._ssoLogForReady.setNetworkType(n).setMessage(t)
          .start(o)
          .end();
      }
    } }, { key: 'login', value() {
      0 === this._startLoginTs && (Ae(), this._startLoginTs = Date.now(), this._startTimer(), this._moduleMap.get(Wt).start(), this._ssoLogForReady = new Xa(Za));
    } }, { key: 'onLoginFailed', value() {
      this._startLoginTs = 0;
    } }, { key: 'getOuterEmitterInstance', value() {
      return null === this._outerEmitter && (this._outerEmitter = new ec, ni(this._outerEmitter), this._outerEmitter._emit = this._outerEmitter.emit, this._outerEmitter.emit = function (e, t) {
        const n = arguments[0]; const o = [n, { name: arguments[0], data: arguments[1] }];this._outerEmitter._emit.apply(this._outerEmitter, o);
      }.bind(this)), this._outerEmitter;
    } }, { key: 'getInnerEmitterInstance', value() {
      return null === this._innerEmitter && (this._innerEmitter = new ec, this._innerEmitter._emit = this._innerEmitter.emit, this._innerEmitter.emit = function (e, t) {
        let n;Ue(arguments[1]) && arguments[1].data ? (Oe.warn('inner eventData has data property, please check!'), n = [e, { name: arguments[0], data: arguments[1].data }]) : n = [e, { name: arguments[0], data: arguments[1] }], this._innerEmitter._emit.apply(this._innerEmitter, n);
      }.bind(this)), this._innerEmitter;
    } }, { key: 'hasModule', value(e) {
      return this._moduleMap.has(e);
    } }, { key: 'getModule', value(e) {
      return this._moduleMap.get(e);
    } }, { key: 'isReady', value() {
      return this._isReady;
    } }, { key: 'onError', value(e) {
      Oe.warn('Oops! code:'.concat(e.code, ' message:').concat(e.message)), new Xa(Tr).setMessage('code:'.concat(e.code, ' message:').concat(e.message))
        .setNetworkType(this.getModule(Wt).getNetworkType())
        .setLevel('error')
        .end(), this.getOuterEmitterInstance().emit(D.ERROR, e);
    } }, { key: 'reset', value() {
      Oe.log(''.concat(this._className, '.reset')), Ae();let e; const t = S(this._moduleMap);try {
        for (t.s();!(e = t.n()).done;) {
          const n = m(e.value, 2)[1];n.reset && n.reset();
        }
      } catch (o) {
        t.e(o);
      } finally {
        t.f();
      } this._startLoginTs = 0, this._initReadyList(), this._isReady = !1, this.stopTimer(), this._outerEmitter.emit(D.SDK_NOT_READY);
    } }]), e;
  }()); const Bc = (function () {
    function e() {
      t(this, e), this._funcMap = new Map;
    } return o(e, [{ key: 'defense', value(e, t) {
      const n = arguments.length > 2 && void 0 !== arguments[2] ? arguments[2] : void 0;if ('string' !== typeof e) return null;if (0 === e.length) return null;if ('function' !== typeof t) return null;if (this._funcMap.has(e) && this._funcMap.get(e).has(t)) return this._funcMap.get(e).get(t);this._funcMap.has(e) || this._funcMap.set(e, new Map);let o = null;return this._funcMap.get(e).has(t) ? o = this._funcMap.get(e).get(t) : (o = this._pack(e, t, n), this._funcMap.get(e).set(t, o)), o;
    } }, { key: 'defenseOnce', value(e, t) {
      const n = arguments.length > 2 && void 0 !== arguments[2] ? arguments[2] : void 0;return 'function' !== typeof t ? null : this._pack(e, t, n);
    } }, { key: 'find', value(e, t) {
      return 'string' !== typeof e || 0 === e.length || 'function' !== typeof t ? null : this._funcMap.has(e) ? this._funcMap.get(e).has(t) ? this._funcMap.get(e).get(t) : (Oe.log('SafetyCallback.find: 找不到 func —— '.concat(e, '/').concat('' !== t.name ? t.name : '[anonymous]')), null) : (Oe.log('SafetyCallback.find: 找不到 eventName-'.concat(e, ' 对应的 func')), null);
    } }, { key: 'delete', value(e, t) {
      return 'function' === typeof t && (!!this._funcMap.has(e) && (!!this._funcMap.get(e).has(t) && (this._funcMap.get(e).delete(t), 0 === this._funcMap.get(e).size && this._funcMap.delete(e), !0)));
    } }, { key: '_pack', value(e, t, n) {
      return function () {
        try {
          t.apply(n, Array.from(arguments));
        } catch (r) {
          const o = Object.values(D).indexOf(e);if (-1 !== o) {
            const a = Object.keys(D)[o];Oe.warn('接入侧事件 TIM.EVENT.'.concat(a, ' 对应的回调函数逻辑存在问题，请检查！'), r);
          } const s = new Xa(Mr);s.setMessage('eventName:'.concat(e)).setMoreMessage(r.message)
            .end();
        }
      };
    } }]), e;
  }()); const Hc = (function () {
    function e(n) {
      t(this, e);const o = { SDKAppID: n.SDKAppID, unlimitedAVChatRoom: n.unlimitedAVChatRoom || !1, scene: n.scene || '', oversea: n.oversea || !1, instanceID: pt(), devMode: n.devMode || !1, proxyServer: n.proxyServer || void 0 };this._moduleManager = new xc(o), this._safetyCallbackFactory = new Bc;
    } return o(e, [{ key: 'isReady', value() {
      return this._moduleManager.isReady();
    } }, { key: 'onError', value(e) {
      this._moduleManager.onError(e);
    } }, { key: 'login', value(e) {
      return this._moduleManager.login(), this._moduleManager.getModule(bt).login(e);
    } }, { key: 'logout', value() {
      const e = this;return this._moduleManager.getModule(bt).logout()
        .then((t => (e._moduleManager.reset(), t)));
    } }, { key: 'destroy', value() {
      const e = this;return this.logout().finally((() => {
        e._moduleManager.stopTimer(), e._moduleManager.getModule(tn).terminate(), e._moduleManager.getModule(Qt).dealloc();const t = e._moduleManager.getOuterEmitterInstance(); const n = e._moduleManager.getModule(Bt);t.emit(D.SDK_DESTROY, { SDKAppID: n.getSDKAppID() });
      }));
    } }, { key: 'on', value(e, t, n) {
      e === D.GROUP_SYSTEM_NOTICE_RECEIVED && Oe.warn('！！！TIM.EVENT.GROUP_SYSTEM_NOTICE_RECEIVED v2.6.0起弃用，为了更好的体验，请在 TIM.EVENT.MESSAGE_RECEIVED 事件回调内接收处理群系统通知，详细请参考：https://web.sdk.qcloud.com/im/doc/zh-cn/Message.html#.GroupSystemNoticePayload'), Oe.debug('on', 'eventName:'.concat(e)), this._moduleManager.getOuterEmitterInstance().on(e, this._safetyCallbackFactory.defense(e, t, n), n);
    } }, { key: 'once', value(e, t, n) {
      Oe.debug('once', 'eventName:'.concat(e)), this._moduleManager.getOuterEmitterInstance().once(e, this._safetyCallbackFactory.defenseOnce(e, t, n), n || this);
    } }, { key: 'off', value(e, t, n, o) {
      Oe.debug('off', 'eventName:'.concat(e));const a = this._safetyCallbackFactory.find(e, t);null !== a && (this._moduleManager.getOuterEmitterInstance().off(e, a, n, o), this._safetyCallbackFactory.delete(e, t));
    } }, { key: 'registerPlugin', value(e) {
      this._moduleManager.getModule(zt).registerPlugin(e);
    } }, { key: 'setLogLevel', value(e) {
      if (e <= 0) {
        console.log(['', ' ________  ______  __       __  __       __  ________  _______', '|        \\|      \\|  \\     /  \\|  \\  _  |  \\|        \\|       \\', ' \\$$$$$$$$ \\$$$$$$| $$\\   /  $$| $$ / \\ | $$| $$$$$$$$| $$$$$$$\\', '   | $$     | $$  | $$$\\ /  $$$| $$/  $\\| $$| $$__    | $$__/ $$', '   | $$     | $$  | $$$$\\  $$$$| $$  $$$\\ $$| $$  \\   | $$    $$', '   | $$     | $$  | $$\\$$ $$ $$| $$ $$\\$$\\$$| $$$$$   | $$$$$$$\\', '   | $$    _| $$_ | $$ \\$$$| $$| $$$$  \\$$$$| $$_____ | $$__/ $$', '   | $$   |   $$ \\| $$  \\$ | $$| $$$    \\$$$| $$     \\| $$    $$', '    \\$$    \\$$$$$$ \\$$      \\$$ \\$$      \\$$ \\$$$$$$$$ \\$$$$$$$', '', ''].join('\n')), console.log('%cIM 智能客服，随时随地解决您的问题 →_→ https://cloud.tencent.com/act/event/smarty-service?from=im-doc', 'color:#006eff'), console.log('%c从v2.11.2起，SDK 支持了 WebSocket，小程序需要添加受信域名！升级指引: https://web.sdk.qcloud.com/im/doc/zh-cn/tutorial-02-upgradeguideline.html', 'color:#ff0000');console.log(['', '参考以下文档，会更快解决问题哦！(#^.^#)\n', 'SDK 更新日志: https://cloud.tencent.com/document/product/269/38492\n', 'SDK 接口文档: https://web.sdk.qcloud.com/im/doc/zh-cn/SDK.html\n', '常见问题: https://web.sdk.qcloud.com/im/doc/zh-cn/tutorial-01-faq.html\n', '反馈问题？戳我提 issue: https://github.com/tencentyun/TIMSDK/issues\n', '如果您需要在生产环境关闭上面的日志，请 tim.setLogLevel(1)\n'].join('\n'));
      }Oe.setLevel(e);
    } }, { key: 'createTextMessage', value(e) {
      return this._moduleManager.getModule(Pt).createTextMessage(e);
    } }, { key: 'createTextAtMessage', value(e) {
      return this._moduleManager.getModule(Pt).createTextMessage(e);
    } }, { key: 'createImageMessage', value(e) {
      return this._moduleManager.getModule(Pt).createImageMessage(e);
    } }, { key: 'createAudioMessage', value(e) {
      return this._moduleManager.getModule(Pt).createAudioMessage(e);
    } }, { key: 'createVideoMessage', value(e) {
      return this._moduleManager.getModule(Pt).createVideoMessage(e);
    } }, { key: 'createCustomMessage', value(e) {
      return this._moduleManager.getModule(Pt).createCustomMessage(e);
    } }, { key: 'createFaceMessage', value(e) {
      return this._moduleManager.getModule(Pt).createFaceMessage(e);
    } }, { key: 'createFileMessage', value(e) {
      return this._moduleManager.getModule(Pt).createFileMessage(e);
    } }, { key: 'createLocationMessage', value(e) {
      return this._moduleManager.getModule(Pt).createLocationMessage(e);
    } }, { key: 'createMergerMessage', value(e) {
      return this._moduleManager.getModule(Pt).createMergerMessage(e);
    } }, { key: 'downloadMergerMessage', value(e) {
      return e.type !== k.MSG_MERGER ? ai(new ei({ code: Do.MESSAGE_MERGER_TYPE_INVALID, message: ta })) : It(e.payload.downloadKey) ? ai(new ei({ code: Do.MESSAGE_MERGER_KEY_INVALID, message: na })) : this._moduleManager.getModule(Pt).downloadMergerMessage(e)
        .catch((e => ai(new ei({ code: Do.MESSAGE_MERGER_DOWNLOAD_FAIL, message: oa }))));
    } }, { key: 'createForwardMessage', value(e) {
      return this._moduleManager.getModule(Pt).createForwardMessage(e);
    } }, { key: 'sendMessage', value(e, t) {
      return e instanceof Yr ? this._moduleManager.getModule(Pt).sendMessageInstance(e, t) : ai(new ei({ code: Do.MESSAGE_SEND_NEED_MESSAGE_INSTANCE, message: Po }));
    } }, { key: 'callExperimentalAPI', value(e, t) {
      return 'handleGroupInvitation' === e ? this._moduleManager.getModule(qt).handleGroupInvitation(t) : ai(new ei({ code: Do.INVALID_OPERATION, message: Ra }));
    } }, { key: 'revokeMessage', value(e) {
      return this._moduleManager.getModule(Pt).revokeMessage(e);
    } }, { key: 'resendMessage', value(e) {
      return this._moduleManager.getModule(Pt).resendMessage(e);
    } }, { key: 'deleteMessage', value(e) {
      return this._moduleManager.getModule(Pt).deleteMessage(e);
    } }, { key: 'getMessageList', value(e) {
      return this._moduleManager.getModule(xt).getMessageList(e);
    } }, { key: 'setMessageRead', value(e) {
      return this._moduleManager.getModule(xt).setMessageRead(e);
    } }, { key: 'getConversationList', value(e) {
      return this._moduleManager.getModule(xt).getConversationList(e);
    } }, { key: 'getConversationProfile', value(e) {
      return this._moduleManager.getModule(xt).getConversationProfile(e);
    } }, { key: 'deleteConversation', value(e) {
      return this._moduleManager.getModule(xt).deleteConversation(e);
    } }, { key: 'pinConversation', value(e) {
      return this._moduleManager.getModule(xt).pinConversation(e);
    } }, { key: 'setAllMessageRead', value(e) {
      return this._moduleManager.getModule(xt).setAllMessageRead(e);
    } }, { key: 'setMessageRemindType', value(e) {
      return this._moduleManager.getModule(xt).setMessageRemindType(e);
    } }, { key: 'getMyProfile', value() {
      return this._moduleManager.getModule(Ut).getMyProfile();
    } }, { key: 'getUserProfile', value(e) {
      return this._moduleManager.getModule(Ut).getUserProfile(e);
    } }, { key: 'updateMyProfile', value(e) {
      return this._moduleManager.getModule(Ut).updateMyProfile(e);
    } }, { key: 'getBlacklist', value() {
      return this._moduleManager.getModule(Ut).getLocalBlacklist();
    } }, { key: 'addToBlacklist', value(e) {
      return this._moduleManager.getModule(Ut).addBlacklist(e);
    } }, { key: 'removeFromBlacklist', value(e) {
      return this._moduleManager.getModule(Ut).deleteBlacklist(e);
    } }, { key: 'getFriendList', value() {
      const e = this._moduleManager.getModule(Vt);return e ? e.getLocalFriendList() : ai({ code: Do.CANNOT_FIND_MODULE, message: Ga });
    } }, { key: 'addFriend', value(e) {
      const t = this._moduleManager.getModule(Vt);return t ? t.addFriend(e) : ai({ code: Do.CANNOT_FIND_MODULE, message: Ga });
    } }, { key: 'deleteFriend', value(e) {
      const t = this._moduleManager.getModule(Vt);return t ? t.deleteFriend(e) : ai({ code: Do.CANNOT_FIND_MODULE, message: Ga });
    } }, { key: 'checkFriend', value(e) {
      const t = this._moduleManager.getModule(Vt);return t ? t.checkFriend(e) : ai({ code: Do.CANNOT_FIND_MODULE, message: Ga });
    } }, { key: 'getFriendProfile', value(e) {
      const t = this._moduleManager.getModule(Vt);return t ? t.getFriendProfile(e) : ai({ code: Do.CANNOT_FIND_MODULE, message: Ga });
    } }, { key: 'updateFriend', value(e) {
      const t = this._moduleManager.getModule(Vt);return t ? t.updateFriend(e) : ai({ code: Do.CANNOT_FIND_MODULE, message: Ga });
    } }, { key: 'getFriendApplicationList', value() {
      const e = this._moduleManager.getModule(Vt);return e ? e.getLocalFriendApplicationList() : ai({ code: Do.CANNOT_FIND_MODULE, message: Ga });
    } }, { key: 'acceptFriendApplication', value(e) {
      const t = this._moduleManager.getModule(Vt);return t ? t.acceptFriendApplication(e) : ai({ code: Do.CANNOT_FIND_MODULE, message: Ga });
    } }, { key: 'refuseFriendApplication', value(e) {
      const t = this._moduleManager.getModule(Vt);return t ? t.refuseFriendApplication(e) : ai({ code: Do.CANNOT_FIND_MODULE, message: Ga });
    } }, { key: 'deleteFriendApplication', value(e) {
      const t = this._moduleManager.getModule(Vt);return t ? t.deleteFriendApplication(e) : ai({ code: Do.CANNOT_FIND_MODULE, message: Ga });
    } }, { key: 'setFriendApplicationRead', value() {
      const e = this._moduleManager.getModule(Vt);return e ? e.setFriendApplicationRead() : ai({ code: Do.CANNOT_FIND_MODULE, message: Ga });
    } }, { key: 'getFriendGroupList', value() {
      const e = this._moduleManager.getModule(Vt);return e ? e.getLocalFriendGroupList() : ai({ code: Do.CANNOT_FIND_MODULE, message: Ga });
    } }, { key: 'createFriendGroup', value(e) {
      const t = this._moduleManager.getModule(Vt);return t ? t.createFriendGroup(e) : ai({ code: Do.CANNOT_FIND_MODULE, message: Ga });
    } }, { key: 'deleteFriendGroup', value(e) {
      const t = this._moduleManager.getModule(Vt);return t ? t.deleteFriendGroup(e) : ai({ code: Do.CANNOT_FIND_MODULE, message: Ga });
    } }, { key: 'addToFriendGroup', value(e) {
      const t = this._moduleManager.getModule(Vt);return t ? t.addToFriendGroup(e) : ai({ code: Do.CANNOT_FIND_MODULE, message: Ga });
    } }, { key: 'removeFromFriendGroup', value(e) {
      const t = this._moduleManager.getModule(Vt);return t ? t.removeFromFriendGroup(e) : ai({ code: Do.CANNOT_FIND_MODULE, message: Ga });
    } }, { key: 'renameFriendGroup', value(e) {
      const t = this._moduleManager.getModule(Vt);return t ? t.renameFriendGroup(e) : ai({ code: Do.CANNOT_FIND_MODULE, message: Ga });
    } }, { key: 'getGroupList', value(e) {
      return this._moduleManager.getModule(qt).getGroupList(e);
    } }, { key: 'getGroupProfile', value(e) {
      return this._moduleManager.getModule(qt).getGroupProfile(e);
    } }, { key: 'createGroup', value(e) {
      return this._moduleManager.getModule(qt).createGroup(e);
    } }, { key: 'dismissGroup', value(e) {
      return this._moduleManager.getModule(qt).dismissGroup(e);
    } }, { key: 'updateGroupProfile', value(e) {
      return this._moduleManager.getModule(qt).updateGroupProfile(e);
    } }, { key: 'joinGroup', value(e) {
      return this._moduleManager.getModule(qt).joinGroup(e);
    } }, { key: 'quitGroup', value(e) {
      return this._moduleManager.getModule(qt).quitGroup(e);
    } }, { key: 'searchGroupByID', value(e) {
      return this._moduleManager.getModule(qt).searchGroupByID(e);
    } }, { key: 'getGroupOnlineMemberCount', value(e) {
      return this._moduleManager.getModule(qt).getGroupOnlineMemberCount(e);
    } }, { key: 'changeGroupOwner', value(e) {
      return this._moduleManager.getModule(qt).changeGroupOwner(e);
    } }, { key: 'handleGroupApplication', value(e) {
      return this._moduleManager.getModule(qt).handleGroupApplication(e);
    } }, { key: 'initGroupAttributes', value(e) {
      return this._moduleManager.getModule(qt).initGroupAttributes(e);
    } }, { key: 'setGroupAttributes', value(e) {
      return this._moduleManager.getModule(qt).setGroupAttributes(e);
    } }, { key: 'deleteGroupAttributes', value(e) {
      return this._moduleManager.getModule(qt).deleteGroupAttributes(e);
    } }, { key: 'getGroupAttributes', value(e) {
      return this._moduleManager.getModule(qt).getGroupAttributes(e);
    } }, { key: 'getGroupMemberList', value(e) {
      return this._moduleManager.getModule(Kt).getGroupMemberList(e);
    } }, { key: 'getGroupMemberProfile', value(e) {
      return this._moduleManager.getModule(Kt).getGroupMemberProfile(e);
    } }, { key: 'addGroupMember', value(e) {
      return this._moduleManager.getModule(Kt).addGroupMember(e);
    } }, { key: 'deleteGroupMember', value(e) {
      return this._moduleManager.getModule(Kt).deleteGroupMember(e);
    } }, { key: 'setGroupMemberMuteTime', value(e) {
      return this._moduleManager.getModule(Kt).setGroupMemberMuteTime(e);
    } }, { key: 'setGroupMemberRole', value(e) {
      return this._moduleManager.getModule(Kt).setGroupMemberRole(e);
    } }, { key: 'setGroupMemberNameCard', value(e) {
      return this._moduleManager.getModule(Kt).setGroupMemberNameCard(e);
    } }, { key: 'setGroupMemberCustomField', value(e) {
      return this._moduleManager.getModule(Kt).setGroupMemberCustomField(e);
    } }]), e;
  }()); const jc = { login: 'login', logout: 'logout', destroy: 'destroy', on: 'on', off: 'off', ready: 'ready', setLogLevel: 'setLogLevel', joinGroup: 'joinGroup', quitGroup: 'quitGroup', registerPlugin: 'registerPlugin', getGroupOnlineMemberCount: 'getGroupOnlineMemberCount' };function Wc(e, t) {
    if (e.isReady() || void 0 !== jc[t]) return !0;const n = new ei({ code: Do.SDK_IS_NOT_READY, message: ''.concat(t, ' ').concat(wa, '，请参考 https://web.sdk.qcloud.com/im/doc/zh-cn/module-EVENT.html#.SDK_READY') });return e.onError(n), !1;
  } const Yc = {}; const $c = {};return $c.create = function (e) {
    let t = 0;if (we(e.SDKAppID))t = e.SDKAppID;else if (Oe.warn('TIM.create SDKAppID 的类型应该为 Number，请修改！'), t = parseInt(e.SDKAppID), isNaN(t)) return Oe.error('TIM.create failed. 解析 SDKAppID 失败，请检查传参！'), null;if (t && Yc[t]) return Yc[t];Oe.log('TIM.create');const n = new Hc(r(r({}, e), {}, { SDKAppID: t }));n.on(D.SDK_DESTROY, ((e) => {
      Yc[e.data.SDKAppID] = null, delete Yc[e.data.SDKAppID];
    }));const o = (function (e) {
      const t = Object.create(null);return Object.keys(wt).forEach(((n) => {
        if (e[n]) {
          const o = wt[n]; const a = new E;t[o] = function () {
            const t = Array.from(arguments);return a.use(((t, o) => (Wc(e, n) ? o() : ai(new ei({ code: Do.SDK_IS_NOT_READY, message: ''.concat(n, ' ').concat(wa, '。') }))))).use(((e, t) => {
              if (!0 === Ct(e, Gt[n], o)) return t();
            }))
              .use(((t, o) => e[n].apply(e, t))), a.run(t);
          };
        }
      })), t;
    }(n));return Yc[t] = o, Oe.log('TIM.create ok'), o;
  }, $c.TYPES = k, $c.EVENT = D, $c.VERSION = '2.16.3', Oe.log('TIM.VERSION: '.concat($c.VERSION)), $c;
})));
