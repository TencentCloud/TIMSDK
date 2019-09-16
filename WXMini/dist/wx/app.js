require("./common/manifest.js")
require("./debug/GenerateTestUserSig.js")
require("./common/vendor.js")
global.webpackJsonpMpvue([1],{

/***/ "17x+":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
var globalModules = {
  state: {
    isSdkReady: false
  },
  getters: {
    isSdkReady: function isSdkReady(state) {
      return state.isSdkReady;
    }
  },
  mutations: {
    showToast: function showToast(state, payload) {
      wx.showToast({
        title: payload.title,
        icon: payload.icon || 'none',
        duration: payload.duration || 800
      });
    },
    setSdkReady: function setSdkReady(state, payload) {
      state.isSdkReady = payload;
    }
  },
  action: {
    kickedReset: function kickedReset(context) {
      context.commit('resetGroup');
      context.commit('resetUser');
      context.commit('resetCurrentConversation');
      context.commit('resetAllConversation');
    }
  }
};

/* harmony default export */ __webpack_exports__["a"] = (globalModules);

/***/ }),

/***/ "Bbwh":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/*eslint-disable*/
var TYPES = {
  // /**
  //  * 消息类型
  //  * @property {String} TEXT 文本
  //  * @property {String} IMAGE 图片
  //  * @property {String} SOUND 音频
  //  * @property {String} FILE 文件
  //  * @property {String} CUSTOM 自定义消息
  //  * @property {String} GROUP_TIP 群提示消息
  //  * @property {String} GROUP_SYSTEM_NOTICE 群系统消息
  //  * @memberOf module:TYPES
  //  */
  // MESSAGE_TYPES: MESSAGE.ELEMENT_TYPES,
  /**
   * @description 消息类型：文本消息
   * @memberof module:TYPES
   */
  MSG_TEXT: 'TIMTextElem',

  /**
   * @description 消息类型：图片消息
   * @memberof module:TYPES
   */
  MSG_IMAGE: 'TIMImageElem',

  /**
   * @description 消息类型：音频消息
   * @memberof module:TYPES
   */
  MSG_SOUND: 'TIMSoundElem',

  /**
   * @description 消息类型：文件消息
   * @memberof module:TYPES
   */
  MSG_FILE: 'TIMFileElem',

  /**
   * @private
   * @description 消息类型：表情消息
   * @memberof module:TYPES
   */
  MSG_FACE: 'TIMFaceElem',

  /**
   * @private
   * @description 消息类型：视频消息
   * @memberof module:TYPES
   */
  MSG_VIDEO: 'TIMVideoElem',

  /**
   * @private
   * @description 消息类型：位置消息
   * @memberof module:TYPES
   */
  MSG_GEO: 'TIMLocationElem',

  /**
   * @description 消息类型：群提示消息
   * @memberof module:TYPES
   */
  MSG_GRP_TIP: 'TIMGroupTipElem',

  /**
   * @description 消息类型：群系统通知消息
   * @memberof module:TYPES
   */
  MSG_GRP_SYS_NOTICE: 'TIMGroupSystemNoticeElem',

  /**
   * @description 消息类型：自定义消息
   * @memberof module:TYPES
   */
  MSG_CUSTOM: 'TIMCustomElem',

  // /**
  //  * 会话类型
  //  * @property {String} C2C C2C 会话类型
  //  * @property {String} GROUP 群组会话类型
  //  * @property {String} SYSTEM 系统会话类型
  //  * @memberOf module:TYPES
  //  */
  // // CONVERSATION_TYPES,
  /**
   * @description 会话类型：C2C(Client to Client, 端到端) 会话
   * @memberof module:TYPES
   */
  CONV_C2C: 'C2C',
  /**
   * @description 会话类型：GROUP(群组) 会话
   * @memberof module:TYPES
   */
  CONV_GROUP: 'GROUP',
  /**
   * @description 会话类型：SYSTEM(系统) 会话
   * @memberof module:TYPES
   */
  CONV_SYSTEM: '@TIM#SYSTEM',

  /**
   * 群组类型
   * @property {String} PRIVATE 私有群
   * @property {String} PUBLIC 公开群
   * @property {String} CHATROOM 聊天室
   * @property {String} AVCHATROOM 音视频聊天室
   * @memberOf module:TYPES
   */
  // GROUP_TYPES,
  /**
   * @description 群组类型：私有群
   * @memberof module:TYPES
   */
  GRP_PRIVATE: 'Private',

  /**
   * @description 群组类型：公开群
   * @memberof module:TYPES
   */
  GRP_PUBLIC: 'Public',

  /**
   * @description 群组类型：聊天室
   * @memberof module:TYPES
   */
  GRP_CHATROOM: 'ChatRoom',

  /**
   * @description 群组类型：音视频聊天室
   * @memberof module:TYPES
   */
  GRP_AVCHATROOM: 'AVChatRoom',

  /**
   * 群成员身份类型常量及含义
   * @property {String} OWNER 群主
   * @property {String} ADMIN 管理员
   * @property {String} MEMBER 普通群成员
   * @memberOf module:TYPES
   */
  // GROUP_MEMBER_ROLE_TYPES,

  /**
   * @description 群成员角色：群主
   * @memberof module:TYPES
   */
  GRP_MBR_ROLE_OWNER: 'Owner',

  /**
   * @description 群成员角色：管理员
   * @memberof module:TYPES
   */
  GRP_MBR_ROLE_ADMIN: 'Admin',

  /**
   * @description 群成员角色：普通群成员
   * @memberof module:TYPES
   */
  GRP_MBR_ROLE_MEMBER: 'Member',

  /**
   * 群提示消息类型常量含义
   * @property {Number} MEMBER_JOIN 有群成员加群
   * @property {Number} MEMBER_QUIT 有群成员退群
   * @property {Number} MEMBER_KICKED_OUT 有群成员被踢出群
   * @property {Number} MEMBER_SET_ADMIN 有群成员被设为管理员
   * @property {Number} MEMBER_CANCELED_ADMIN 有群成员被撤销管理员
   * @property {Number} GROUP_INFO_MODIFIED 群组资料变更
   * @property {Number} MEMBER_INFO_MODIFIED 群成员资料变更
   * @memberOf module:TYPES
   */
  // GROUP_TIP_TYPES,

  /**
   * @description 群提示：有成员加群
   * @memberof module:TYPES
   */
  GRP_TIP_MBR_JOIN: 1,

  /**
   * @description 群提示：有群成员退群
   * @memberof module:TYPES
   */
  GRP_TIP_MBR_QUIT: 2,

  /**
   * @description 群提示：有群成员被踢出群
   * @memberof module:TYPES
   */
  GRP_TIP_MBR_KICKED_OUT: 3,

  /**
   * @description 群提示：有群成员被设为管理员
   * @memberof module:TYPES
   */
  GRP_TIP_MBR_SET_ADMIN: 4, //被设置为管理员

  /**
   * @description 群提示：有群成员被撤销管理员
   * @memberof module:TYPES
   */
  GRP_TIP_MBR_CANCELED_ADMIN: 5, //被取消管理员

  /**
   * @description 群提示：群组资料变更
   * @memberof module:TYPES
   */
  GRP_TIP_GRP_PROFILE_UPDATED: 6, //修改群资料，转让群组为该类型，msgBody.msgGroupNewInfo.ownerAccount表示新群主的ID

  /**
   * @description 群提示：群成员资料变更
   * @memberof module:TYPES
   */
  GRP_TIP_MBR_PROFILE_UPDATED: 7, //修改群成员信息

  /**
   * 群系统通知类型常量及含义
   * @property {Number} JOIN_GROUP_REQUEST 有用户申请加群。群管理员/群主接收
   * @property {Number} JOIN_GROUP_ACCEPT 申请加群被同意。申请加群的用户接收
   * @property {Number} JOIN_GROUP_REFUSE 申请加群被拒绝。申请加群的用户接收
   * @property {Number} KICKED_OUT 被踢出群组。被踢出的用户接收
   * @property {Number} GROUP_DISMISSED 群组被解散。全体群成员接收
   * @property {Number} GROUP_CREATED 创建群组。创建者接收
   * @property {Number} QUIT 退群。退群者接收
   * @property {Number} SET_ADMIN 设置管理员。被设置方接收
   * @property {Number} CANCELED_ADMIN 取消管理员。被取消方接收
   * @property {Number} CUSTOM 自定义系统通知。全员接收
   * @memberOf module:TYPES
   */
  // GROUP_SYSTEM_NOTICE_TYPES,
  /**
   * @private
   * @description 有用户申请加群。群管理员/群主接收
   * @memberof module:TYPES
   */
  // GROUP_SYSTEM_NOTICE_JOIN_GROUP_REQUEST: 1, //申请加群请求（只有管理员会收到）

  /**
   * @private
   * @description 申请加群被同意。申请加群的用户接收
   * @memberof module:TYPES
   */
  // GROUP_SYSTEM_NOTICE_JOIN_GROUP_ACCEPT: 2, //申请加群被同意（只有申请人能够收到）

  /**
   * @private
   * @description 申请加群被拒绝。申请加群的用户接收
   * @memberof module:TYPES
   */
  // GROUP_SYSTEM_NOTICE_JOIN_GROUP_REFUSE: 3, //申请加群被拒绝（只有申请人能够收到）

  /**
   * @private
   * @description 被踢出群组。被踢出的用户接收
   * @memberof module:TYPES
   */
  // GROUP_SYSTEM_NOTICE_KICKED_OUT: 4, //被管理员踢出群(只有被踢者接收到)

  /**
   * @private
   * @description 群组被解散。全体群成员接收
   * @memberof module:TYPES
   */
  // GROUP_SYSTEM_NOTICE_GROUP_DISMISSED: 5, //群被解散(全员接收)

  /**
   * @private
   * @description 创建群组。创建者接收
   * @memberof module:TYPES
   */
  // GROUP_SYSTEM_NOTICE_GROUP_CREATED: 6, //创建群(创建者接收, 不展示)

  /**
   * @private
   * @description 邀请加群(被邀请者接收)
   * @memberof module:TYPES
   */
  // GROUP_SYSTEM_NOTICE_INVITED_JOIN_GROUP_REQUEST: 7, //邀请加群(被邀请者接收)。

  /**
   * @private
   * @description 退群。退群者接收
   * @memberof module:TYPES
   */
  // GROUP_SYSTEM_NOTICE_QUIT: 8, //主动退群(主动退出者接收, 不展示)

  /**
   * @private
   * @description 设置管理员。被设置方接收
   * @memberof module:TYPES
   */
  // GROUP_SYSTEM_NOTICE_SET_ADMIN: 9, //设置管理员(被设置者接收)

  /**
   * @private
   * @description 取消管理员。被取消方接收
   * @memberof module:TYPES
   */
  // GROUP_SYSTEM_NOTICE_CANCELED_ADMIN: 10, //取消管理员(被取消者接收)

  /**
   * @private
   * @description 群已被回收(全员接收, 不展示)
   * @memberof module:TYPES
   */
  // GROUP_SYSTEM_NOTICE_REVOKE: 11, //群已被回收(全员接收, 不展示)

  /**
   * @private
   * @description 邀请加群(被邀请者需同意)
   * @memberof module:TYPES
   */
  // GROUP_SYSTEM_NOTICE_INVITED_JOIN_GROUP_REQUEST_AGREE: 12, //邀请加群(被邀请者需同意)

  /**
   * @private
   * @description 群消息已读同步
   * @memberof module:TYPES
   */
  // GROUP_SYSTEM_NOTICE_READED: 15, //群消息已读同步

  /**
   * @private
   * @description 用户自定义通知(默认全员接收)
   * @memberof module:TYPES
   */
  // GROUP_SYSTEM_NOTICE_CUSTOM: 255, //用户自定义通知(默认全员接收)

  /**
   * 群消息提示类型常量及含义
   * @property {String} ACCEPT_AND_NOTIFY 通知并提示
   * @property {String} ACCEPT_NOT_NOTIFY 通知但不提示
   * @property {String} DISCARD 拒收消息
   * @memberOf module:TYPES
   */
  // MESSAGE_REMIND_TYPES,
  /**
   * @description 群消息提示类型：SDK 接收消息并通知接入侧，接入侧做提示
   * @memberof module:TYPES
   */
  MSG_REMIND_ACPT_AND_NOTE: 'AcceptAndNotify',

  /**
   * @description 群消息提示类型：SDK 接收消息并通知接入侧，接入侧不做提示
   * @memberof module:TYPES
   */
  MSG_REMIND_ACPT_NOT_NOTE: 'AcceptNotNotify',

  /**
   * @description 群消息提示类型：SDK 拒收消息
   * @memberof module:TYPES
   */
  MSG_REMIND_DISCARD: 'Discard',

  /**
   * 性别类型常量及含义
   * @property {String} MALE 男
   * @property {String} FEMALE 女
   * @property {String} UNKNOWN 未设置性别
   * @memberOf module:TYPES
   */
  // GENDER_TYPES,
  /**
   * @description 性别：未设置性别
   * @memberOf module:TYPES
   */
  GENDER_UNKNOWN: 'Gender_Type_Unknown',

  /**
   * @description 性别：女性
   * @memberOf module:TYPES
   */
  GENDER_FEMALE: 'Gender_Type_Female',

  /**
   * @description 性别：男性
   * @memberOf module:TYPES
   */
  GENDER_MALE: 'Gender_Type_Male',

  /**
   * 被踢类型常量及含义
   * @property {String} MUTIPLE_ACCOUNT 多账号登录被踢
   * @memberOf module:TYPES
   */
  // KICKED_OUT_TYPES,

  /**
   * @description 被踢类型：多账号登录被踢
   * @memberOf module:TYPES
   */
  KICKED_OUT_MULT_ACCOUNT: 'mutipleAccount',

  /**
   * @private
   */
  KICKED_OUT_MULT_DEVICE: 'mutipleDevice',

  /**
   * @description 当被人加好友时：允许任何人添加自己为好友
   * @memberOf module:TYPES
   */
  ALLOW_TYPE_ALLOW_ANY: 'AllowType_Type_AllowAny',

  /**
   * @description 当被人加好友时：需要经过自己确认才能添加自己为好友
   * @memberOf module:TYPES
   */
  ALLOW_TYPE_NEED_CONFIRM: 'AllowType_Type_NeedConfirm',

  /**
   * @description 当被人加好友时：不允许任何人添加自己为好友
   * @memberOf module:TYPES
   */
  ALLOW_TYPE_DENY_ANY: 'AllowType_Type_DenyAny',

  /**
   * @description 管理员禁止加好友标识：默认值，允许加好友
   * @memberOf module:TYPES
   */
  FORBID_TYPE_NONE: 'AdminForbid_Type_None',

  /**
   * @description 管理员禁止加好友标识：禁止该用户发起加好友请求
   * @memberOf module:TYPES
   */
  FORBID_TYPE_SEND_OUT: 'AdminForbid_Type_SendOut',

  /**
   * @description 加群选项：自由加入
   * @memberOf module:TYPES
   */
  JOIN_OPTIONS_FREE_ACCESS: 'FreeAccess',

  /**
   * @description 加群选项：需要管理员同意
   * @memberOf module:TYPES
   */
  JOIN_OPTIONS_NEED_PERMISSION: 'NeedPermission',

  /**
   * @description 加群选项：不允许加群
   * @memberOf module:TYPES
   */
  JOIN_OPTIONS_DISABLE_APPLY: 'DisableApply',

  /**
   * @description 加群申请状态：加群成功
   * @memberOf module:TYPES
   */
  JOIN_STATUS_SUCCESS: 'JoinedSuccess',

  /**
   * @description 加群申请状态：等待管理员同意
   * @memberOf module:TYPES
   */
  JOIN_STATUS_WAIT_APPROVAL: 'WaitAdminApproval'

};

/* harmony default export */ __webpack_exports__["a"] = (TYPES);

/***/ }),

/***/ "IcnI":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_vue__ = __webpack_require__("5nAL");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_vue___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_0_vue__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1_vuex__ = __webpack_require__("NYxO");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2__modules_conversation_js__ = __webpack_require__("tn05");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3__modules_group__ = __webpack_require__("xTcS");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_4__modules_user__ = __webpack_require__("bREw");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_5__modules_global__ = __webpack_require__("17x+");






__WEBPACK_IMPORTED_MODULE_0_vue___default.a.use(__WEBPACK_IMPORTED_MODULE_1_vuex__["a" /* default */]);

/* harmony default export */ __webpack_exports__["a"] = (new __WEBPACK_IMPORTED_MODULE_1_vuex__["a" /* default */].Store({
  modules: {
    conversation: __WEBPACK_IMPORTED_MODULE_2__modules_conversation_js__["a" /* default */],
    group: __WEBPACK_IMPORTED_MODULE_3__modules_group__["a" /* default */],
    user: __WEBPACK_IMPORTED_MODULE_4__modules_user__["a" /* default */],
    global: __WEBPACK_IMPORTED_MODULE_5__modules_global__["a" /* default */]
  }
}));

/***/ }),

/***/ "M93x":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__babel_loader_node_modules_mpvue_loader_lib_selector_type_script_index_0_App_vue__ = __webpack_require__("Mw+1");
function injectStyle (ssrContext) {
  __webpack_require__("OYdO")
}
var normalizeComponent = __webpack_require__("ybqe")
/* script */

/* template */
var __vue_template__ = null
/* styles */
var __vue_styles__ = injectStyle
/* scopeId */
var __vue_scopeId__ = null
/* moduleIdentifier (server only) */
var __vue_module_identifier__ = null
var Component = normalizeComponent(
  __WEBPACK_IMPORTED_MODULE_0__babel_loader_node_modules_mpvue_loader_lib_selector_type_script_index_0_App_vue__["a" /* default */],
  __vue_template__,
  __vue_styles__,
  __vue_scopeId__,
  __vue_module_identifier__
)

/* harmony default export */ __webpack_exports__["a"] = (Component.exports);


/***/ }),

/***/ "Mw+1":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";

/* harmony default export */ __webpack_exports__["a"] = ({
  created: function created() {}
});

/***/ }),

/***/ "NHnr":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_mpvue__ = __webpack_require__("5nAL");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_mpvue___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_0_mpvue__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__App__ = __webpack_require__("M93x");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2_tim_wx_sdk__ = __webpack_require__("PDEy");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2_tim_wx_sdk___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_2_tim_wx_sdk__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3__store_index__ = __webpack_require__("IcnI");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_4_cos_wx_sdk_v5__ = __webpack_require__("h1dT");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_4_cos_wx_sdk_v5___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_4_cos_wx_sdk_v5__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_5__static_utils_GenerateTestUserSig__ = __webpack_require__("dutN");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_6__utils_types__ = __webpack_require__("Bbwh");








var tim = __WEBPACK_IMPORTED_MODULE_2_tim_wx_sdk___default.a.create({
  SDKAppID: __WEBPACK_IMPORTED_MODULE_5__static_utils_GenerateTestUserSig__["a" /* SDKAPPID */]
});
tim.setLogLevel(0);
wx.$app = tim;
wx.$app.registerPlugin({ 'cos-wx-sdk': __WEBPACK_IMPORTED_MODULE_4_cos_wx_sdk_v5___default.a });

var $bus = new __WEBPACK_IMPORTED_MODULE_0_mpvue___default.a();
__WEBPACK_IMPORTED_MODULE_0_mpvue___default.a.prototype.TIM = __WEBPACK_IMPORTED_MODULE_2_tim_wx_sdk___default.a;
__WEBPACK_IMPORTED_MODULE_0_mpvue___default.a.prototype.$type = __WEBPACK_IMPORTED_MODULE_6__utils_types__["a" /* default */];
__WEBPACK_IMPORTED_MODULE_0_mpvue___default.a.prototype.$store = __WEBPACK_IMPORTED_MODULE_3__store_index__["a" /* default */];
__WEBPACK_IMPORTED_MODULE_0_mpvue___default.a.prototype.$bus = $bus;

tim.on(__WEBPACK_IMPORTED_MODULE_2_tim_wx_sdk___default.a.EVENT.SDK_READY, onReadyStateUpdate, this);
tim.on(__WEBPACK_IMPORTED_MODULE_2_tim_wx_sdk___default.a.EVENT.SDK_NOT_READY, onReadyStateUpdate, this);

tim.on(__WEBPACK_IMPORTED_MODULE_2_tim_wx_sdk___default.a.EVENT.KICKED_OUT, function (event) {
  __WEBPACK_IMPORTED_MODULE_3__store_index__["a" /* default */].commit('resetGroup');
  __WEBPACK_IMPORTED_MODULE_3__store_index__["a" /* default */].commit('resetUser');
  __WEBPACK_IMPORTED_MODULE_3__store_index__["a" /* default */].commit('resetCurrentConversation');
  __WEBPACK_IMPORTED_MODULE_3__store_index__["a" /* default */].commit('resetAllConversation');
  wx.showToast({
    title: '你已被踢下线',
    icon: 'none',
    duration: 1500
  });
  setTimeout(function () {
    wx.clearStorage();
    wx.reLaunch({
      url: '../login/main'
    });
  }, 1500);
});

// 出错统一处理
tim.on(__WEBPACK_IMPORTED_MODULE_2_tim_wx_sdk___default.a.EVENT.ERROR, function (event) {
  // 网络错误不弹toast && sdk未初始化完全报错
  if (event.data.code !== 2800 && event.data.code !== 2999) {
    __WEBPACK_IMPORTED_MODULE_3__store_index__["a" /* default */].commit('showToast', {
      title: event.data.message,
      duration: 2000
    });
  }
});

tim.on(__WEBPACK_IMPORTED_MODULE_2_tim_wx_sdk___default.a.EVENT.MESSAGE_RECEIVED, function (event) {
  wx.$app.ready(function () {
    __WEBPACK_IMPORTED_MODULE_3__store_index__["a" /* default */].dispatch('onMessageEvent', event);
  });
});
tim.on(__WEBPACK_IMPORTED_MODULE_2_tim_wx_sdk___default.a.EVENT.CONVERSATION_LIST_UPDATED, function (event) {
  __WEBPACK_IMPORTED_MODULE_3__store_index__["a" /* default */].commit('updateAllConversation', event.data);
});
tim.on(__WEBPACK_IMPORTED_MODULE_2_tim_wx_sdk___default.a.EVENT.GROUP_LIST_UPDATED, function (event) {
  __WEBPACK_IMPORTED_MODULE_3__store_index__["a" /* default */].commit('updateGroupList', event.data);
});
tim.on(__WEBPACK_IMPORTED_MODULE_2_tim_wx_sdk___default.a.EVENT.BLACKLIST_UPDATED, function (event) {
  __WEBPACK_IMPORTED_MODULE_3__store_index__["a" /* default */].commit('updateBlacklist', event.data);
});

tim.on(__WEBPACK_IMPORTED_MODULE_2_tim_wx_sdk___default.a.EVENT.GROUP_SYSTEM_NOTICE_RECERIVED, function (event) {
  console.log('system message', event);
});

function onReadyStateUpdate(_ref) {
  var name = _ref.name;

  var isSDKReady = name === __WEBPACK_IMPORTED_MODULE_2_tim_wx_sdk___default.a.EVENT.SDK_READY;
  __WEBPACK_IMPORTED_MODULE_3__store_index__["a" /* default */].commit('setSdkReady', isSDKReady);
}

new __WEBPACK_IMPORTED_MODULE_0_mpvue___default.a({
  TIMApp: __WEBPACK_IMPORTED_MODULE_1__App__["a" /* default */]
}).$mount();

/***/ }),

/***/ "OYdO":
/***/ (function(module, exports) {

// removed by extract-text-webpack-plugin

/***/ }),

/***/ "Srkd":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (immutable) */ __webpack_exports__["a"] = decodeElement;
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__emojiMap__ = __webpack_require__("lRgn");

/** 传入message.element（群系统消息SystemMessage，群提示消息GroupTip除外）
 * content = {
 *  type: 'TIMTextElem',
 *  content: {
 *    text: 'AAA[龇牙]AAA[龇牙]AAA[龇牙AAA]'
 *  }
 *}
 **/
var GROUP_SYSTEM_NOTICE_TYPE = {
  JOIN_GROUP_REQUEST: 1, // 申请加群请求（只有管理员会收到）
  JOIN_GROUP_ACCEPT: 2, // 申请加群被同意（只有申请人能够收到）
  JOIN_GROUP_REFUSE: 3, // 申请加群被拒绝（只有申请人能够收到）
  KICKED_OUT: 4, // 被管理员踢出群(只有被踢者接收到)
  GROUP_DISMISSED: 5, // 群被解散(全员接收)
  GROUP_CREATED: 6, // 创建群(创建者接收, 不展示)
  INVITED_JOIN_GROUP_REQUEST: 7, // 邀请加群(被邀请者接收)。对于被邀请者，表示被邀请进群。
  QUIT: 8, // 主动退群(主动退出者接收, 不展示)
  SET_ADMIN: 9, // 设置管理员(被设置者接收)
  CANCELED_ADMIN: 10, // 取消管理员(被取消者接收)
  REVOKE: 11, // 群已被回收(全员接收, 不展示)
  INVITED_JOIN_GROUP_REQUEST_AGREE: 12, // 邀请加群(被邀请者需同意)
  READED: 15, // 群消息已读同步
  CUSTOM: 255 // 用户自定义通知(默认全员接收)


  // 群提示消息的含义 (opType)
};var GROUP_TIP_TYPE = {
  MEMBER_JOIN: 1,
  MEMBER_QUIT: 2,
  MEMBER_KICKED_OUT: 3,
  MEMBER_SET_ADMIN: 4, // 被设置为管理员
  MEMBER_CANCELED_ADMIN: 5, // 被取消管理员
  GROUP_INFO_MODIFIED: 6, // 修改群资料，转让群组为该类型，msgBody.msgGroupNewInfo.ownerAccount表示新群主的ID
  MEMBER_INFO_MODIFIED: 7 // 修改群成员信息
};

function parseText(message) {
  var renderDom = [];
  var temp = message.content.text;
  var left = -1;
  var right = -1;
  while (temp !== '') {
    left = temp.indexOf('[');
    right = temp.indexOf(']');
    switch (left) {
      case 0:
        if (right === -1) {
          renderDom.push({
            name: 'span',
            text: temp
          });
          temp = '';
        } else {
          var _emoji = temp.slice(0, right + 1);
          if (__WEBPACK_IMPORTED_MODULE_0__emojiMap__["a" /* emojiMap */][_emoji]) {
            renderDom.push({
              name: 'img',
              src: __WEBPACK_IMPORTED_MODULE_0__emojiMap__["c" /* emojiUrl */] + __WEBPACK_IMPORTED_MODULE_0__emojiMap__["a" /* emojiMap */][_emoji]
            });
            temp = temp.substring(right + 1);
          } else {
            renderDom.push({
              name: 'span',
              text: '['
            });
            temp = temp.slice(1);
          }
        }
        break;
      case -1:
        renderDom.push({
          name: 'span',
          text: temp
        });
        temp = '';
        break;
      default:
        renderDom.push({
          name: 'span',
          text: temp.slice(0, left)
        });
        temp = temp.substring(left);
        break;
    }
  }
  return renderDom;
}
function parseGroupSystemNotice(message) {
  var element = message.content;
  var groupName = element.groupProfile.groupName || element.groupProfile.groupID;
  var text = void 0;
  switch (element.operationType) {
    case GROUP_SYSTEM_NOTICE_TYPE.JOIN_GROUP_REQUEST:
      text = element.operatorID + ' \u7533\u8BF7\u52A0\u5165\u7FA4\u7EC4\uFF1A' + groupName;
      break;
    case GROUP_SYSTEM_NOTICE_TYPE.JOIN_GROUP_ACCEPT:
      text = '\u6210\u529F\u52A0\u5165\u7FA4\u7EC4\uFF1A' + groupName;
      break;
    case GROUP_SYSTEM_NOTICE_TYPE.JOIN_GROUP_REFUSE:
      text = '\u7533\u8BF7\u52A0\u5165\u7FA4\u7EC4\uFF1A' + groupName + '\u88AB\u62D2\u7EDD';
      break;
    case GROUP_SYSTEM_NOTICE_TYPE.KICKED_OUT:
      text = '\u88AB\u7BA1\u7406\u5458' + element.operatorID + '\u8E22\u51FA\u7FA4\u7EC4\uFF1A' + groupName;
      break;
    case GROUP_SYSTEM_NOTICE_TYPE.GROUP_DISMISSED:
      text = '\u7FA4\uFF1A' + groupName + ' \u5DF2\u88AB' + element.operatorID + '\u89E3\u6563';
      break;
    case GROUP_SYSTEM_NOTICE_TYPE.GROUP_CREATED:
      text = element.operatorID + '\u521B\u5EFA\u7FA4\uFF1A' + groupName;
      break;
    case GROUP_SYSTEM_NOTICE_TYPE.INVITED_JOIN_GROUP_REQUEST:
      text = element.operatorID + '\u9080\u8BF7\u4F60\u52A0\u7FA4\uFF1A' + groupName;
      break;
    case GROUP_SYSTEM_NOTICE_TYPE.QUIT:
      text = '\u4F60\u9000\u51FA\u7FA4\u7EC4\uFF1A' + groupName;
      break;
    case GROUP_SYSTEM_NOTICE_TYPE.SET_ADMIN:
      text = '\u4F60\u88AB' + element.operatorID + '\u8BBE\u7F6E\u4E3A\u7FA4\uFF1A' + groupName + '\u7684\u7BA1\u7406\u5458';
      break;
    case GROUP_SYSTEM_NOTICE_TYPE.CANCELED_ADMIN:
      text = '\u4F60\u88AB' + element.operatorID + '\u64A4\u9500\u7FA4\uFF1A' + groupName + '\u7684\u7BA1\u7406\u5458\u8EAB\u4EFD';
      break;
    case GROUP_SYSTEM_NOTICE_TYPE.REVOKE:
      text = '\u7FA4\uFF1A' + groupName + '\u88AB' + element.operatorID + '\u56DE\u6536';
      break;
    case GROUP_SYSTEM_NOTICE_TYPE.INVITED_JOIN_GROUP_REQUEST_AGREE:
      text = element.operatorID + '\u540C\u610F\u5165\u7FA4\uFF1A' + groupName + '\u9080\u8BF7';
      break;
  }
  return [{
    name: 'system',
    text: text
  }];
}
function parseGroupTip(message) {
  var elem = message.content;
  var tip = void 0;
  switch (elem.operationType) {
    case GROUP_TIP_TYPE.MEMBER_JOIN:
      tip = '\u65B0\u6210\u5458\u52A0\u5165\uFF1A' + elem.userIDList.join(',');
      break;
    case GROUP_TIP_TYPE.MEMBER_QUIT:
      tip = '\u7FA4\u6210\u5458\u9000\u7FA4\uFF1A' + elem.userIDList.join(',');
      break;
    case GROUP_TIP_TYPE.MEMBER_KICKED_OUT:
      tip = '\u7FA4\u6210\u5458\u88AB\u8E22\uFF1A' + elem.userIDList.join(',');
      break;
    case GROUP_TIP_TYPE.MEMBER_SET_ADMIN:
      tip = elem.operatorID + '\u5C06' + elem.userIDList.join(',') + '\u8BBE\u7F6E\u4E3A\u7BA1\u7406\u5458';
      break;
    case GROUP_TIP_TYPE.MEMBER_CANCELED_ADMIN:
      tip = elem.operatorID + '\u5C06' + elem.userIDList.join(',') + '\u53D6\u6D88\u4F5C\u4E3A\u7BA1\u7406\u5458';
      break;
    case GROUP_TIP_TYPE.GROUP_INFO_MODIFIED:
      tip = '群资料修改';
      break;
    case GROUP_TIP_TYPE.MEMBER_INFO_MODIFIED:
      tip = '群成员资料修改';
      break;
  }
  return [{
    name: 'groupTip',
    text: tip
  }];
}
function decodeElement(message) {
  // renderDom是最终渲染的
  switch (message.type) {
    case 'TIMTextElem':
      return parseText(message);
    case 'TIMGroupSystemNoticeElem':
      return parseGroupSystemNotice(message);
    case 'TIMGroupTipElem':
      return parseGroupTip(message);
    default:
      return [];
  }
}

/***/ }),

/***/ "bREw":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
var userModules = {
  state: {
    myInfo: {},
    userProfile: {},
    blacklist: []
  },
  getters: {
    myInfo: function myInfo(state) {
      return state.myInfo;
    },
    userProfile: function userProfile(state) {
      return state.userProfile;
    }
  },
  mutations: {
    updateMyInfo: function updateMyInfo(state, myInfo) {
      state.myInfo = myInfo;
    },
    updateUserProfile: function updateUserProfile(state, userProfile) {
      state.userProfile = userProfile;
    },
    setBlacklist: function setBlacklist(state, blacklist) {
      state.blacklist = blacklist;
    },
    updateBlacklist: function updateBlacklist(state, blacklist) {
      state.blacklist.push(blacklist);
    },
    resetUser: function resetUser(state) {
      state.blacklist = [];
      state.userProfile = {};
      state.myInfo = {};
    }
  }
};

/* harmony default export */ __webpack_exports__["a"] = (userModules);

/***/ }),

/***/ "tn05":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_babel_runtime_helpers_toConsumableArray__ = __webpack_require__("Gu7T");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_babel_runtime_helpers_toConsumableArray___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_0_babel_runtime_helpers_toConsumableArray__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__utils_index__ = __webpack_require__("0xDb");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2__utils_decodeElement__ = __webpack_require__("Srkd");




var conversationModules = {
  state: {
    allConversation: [], // 所有的conversation
    currentConversationID: '', // 当前聊天对话ID
    currentConversation: {}, // 当前聊天对话信息
    currentMessageList: [], // 当前聊天消息列表
    nextReqMessageID: '', // 下一条消息标志
    isCompleted: false, // 当前会话消息是否已经请求完毕
    isLoading: false // 是否正在请求
  },
  getters: {
    allConversation: function allConversation(state) {
      return state.allConversation;
    },
    // 当前聊天对象的ID
    toAccount: function toAccount(state) {
      if (state.currentConversationID.indexOf('C2C') === 0) {
        return state.currentConversationID.substring(3);
      } else if (state.currentConversationID.indexOf('GROUP') === 0) {
        return state.currentConversationID.substring(5);
      }
    },
    // 当前聊天对象的昵称
    toName: function toName(state) {
      if (state.currentConversation.type === 'C2C') {
        return state.currentConversation.userProfile.userID;
      } else if (state.currentConversation.type === 'GROUP') {
        return state.currentConversation.groupProfile.name;
      }
    },
    // 当前聊天对话的Type
    currentConversationType: function currentConversationType(state) {
      if (state.currentConversationID.indexOf('C2C') === 0) {
        return 'C2C';
      }
      if (state.currentConversationID.indexOf('GROUP') === 0) {
        return 'GROUP';
      }
      return '';
    },
    currentConversation: function currentConversation(state) {
      return state.currentConversation;
    },
    currentMessageList: function currentMessageList(state) {
      return state.currentMessageList;
    }
  },
  mutations: {
    // 历史头插消息列表
    unshiftMessageList: function unshiftMessageList(state, messageList) {
      var list = [].concat(__WEBPACK_IMPORTED_MODULE_0_babel_runtime_helpers_toConsumableArray___default()(messageList));
      for (var i = 0; i < list.length; i++) {
        var message = list[i];
        list[i].virtualDom = Object(__WEBPACK_IMPORTED_MODULE_2__utils_decodeElement__["a" /* decodeElement */])(message.elements[0]);
        var date = new Date(message.time * 1000);
        list[i].newtime = Object(__WEBPACK_IMPORTED_MODULE_1__utils_index__["a" /* formatTime */])(date);
      }
      state.currentMessageList = [].concat(__WEBPACK_IMPORTED_MODULE_0_babel_runtime_helpers_toConsumableArray___default()(list), __WEBPACK_IMPORTED_MODULE_0_babel_runtime_helpers_toConsumableArray___default()(state.currentMessageList));
    },

    // 收到
    receiveMessage: function receiveMessage(state, messageList) {
      var list = [].concat(__WEBPACK_IMPORTED_MODULE_0_babel_runtime_helpers_toConsumableArray___default()(messageList));
      for (var i = 0; i < list.length; i++) {
        var item = list[i];
        list[i].virtualDom = Object(__WEBPACK_IMPORTED_MODULE_2__utils_decodeElement__["a" /* decodeElement */])(item.elements[0]);
        var date = new Date(item.time * 1000);
        list[i].newtime = Object(__WEBPACK_IMPORTED_MODULE_1__utils_index__["a" /* formatTime */])(date);
      }
      state.currentMessageList = [].concat(__WEBPACK_IMPORTED_MODULE_0_babel_runtime_helpers_toConsumableArray___default()(state.currentMessageList), __WEBPACK_IMPORTED_MODULE_0_babel_runtime_helpers_toConsumableArray___default()(list));
      setTimeout(function () {
        wx.pageScrollTo({
          scrollTop: 99999
        });
      }, 800);
    },
    sendMessage: function sendMessage(state, message) {
      message.virtualDom = Object(__WEBPACK_IMPORTED_MODULE_2__utils_decodeElement__["a" /* decodeElement */])(message.elements[0]);
      var date = new Date(message.time * 1000);
      message.newtime = Object(__WEBPACK_IMPORTED_MODULE_1__utils_index__["a" /* formatTime */])(date);
      state.currentMessageList.push(message);
      setTimeout(function () {
        wx.pageScrollTo({
          scrollTop: 99999
        });
      }, 800);
    },

    // 更新当前的会话
    updateCurrentConversation: function updateCurrentConversation(state, conversation) {
      state.currentConversation = conversation;
      state.currentConversationID = conversation.conversationID;
    },

    // 更新当前所有会话列表
    updateAllConversation: function updateAllConversation(state, list) {
      for (var i = 0; i < list.length; i++) {
        if (list[i].lastMessage && typeof list[i].lastMessage.lastTime === 'number') {
          var date = new Date(list[i].lastMessage.lastTime * 1000);
          list[i].lastMessage._lastTime = Object(__WEBPACK_IMPORTED_MODULE_1__utils_index__["a" /* formatTime */])(date);
        }
      }
      state.allConversation = list;
    },

    // 重置当前会话
    resetCurrentConversation: function resetCurrentConversation(state) {
      state.currentConversationID = ''; // 当前聊天对话ID
      state.currentConversation = {}; // 当前聊天对话信息
      state.currentMessageList = []; // 当前聊天消息列表
      state.nextReqMessageID = ''; // 下一条消息标志
      state.isCompleted = false; // 当前会话消息是否已经请求完毕
      state.isLoading = false; // 是否正在请求
    },
    resetAllConversation: function resetAllConversation(state) {
      state.allConversation = [];
    },
    removeMessage: function removeMessage(state, message) {
      state.currentMessageList.splice(state.currentMessageList.findIndex(function (item) {
        return item.ID === message.ID;
      }), 1);
    },
    changeMessageStatus: function changeMessageStatus(state, index) {
      state.currentMessageList[index].status = 'fail';
    },
    offAtRemind: function offAtRemind(state, conversation) {
      var item = state.allConversation.filter(function (item) {
        return item.conversationID === conversation.conversationID;
      })[0];
      item.lastMessage.at = false;
    }
  },
  actions: {
    // 消息事件
    onMessageEvent: function onMessageEvent(context, event) {
      var messageList = event.data;
      var atTextMessageList = messageList.filter(function (message) {
        return message.type === 'TIMTextElem' && message.payload.text.includes('@');
      });

      var _loop = function _loop(i) {
        var message = atTextMessageList[i];
        var matched = message.payload.text.match(/@\w+/g);
        if (!matched) {
          return 'continue';
        }
        // @ 我的
        if (matched.includes('@' + context.getters.myInfo.userID)) {
          // TODO: notification
          context.state.allConversation.filter(function (item) {
            if (item.conversationID === message.conversationID) {
              item.lastMessage.at = true;
            }
          });
        }
      };

      for (var i = 0; i < atTextMessageList.length; i++) {
        var _ret = _loop(i);

        if (_ret === 'continue') continue;
      }
      if (event.name === 'onMessageReceived') {
        var id = context.state.currentConversationID;
        if (!id) {
          return;
        }
        var list = [];
        event.data.forEach(function (item) {
          if (item.conversationID === id) {
            list.push(item);
          }
        });
        context.commit('receiveMessage', list);
      }
    },

    // 获取消息列表
    getMessageList: function getMessageList(context) {
      var _context$state = context.state,
          currentConversationID = _context$state.currentConversationID,
          nextReqMessageID = _context$state.nextReqMessageID;
      // 判断是否拉完了

      if (!context.state.isCompleted) {
        if (!context.state.isLoading) {
          context.state.isLoading = true;
          wx.$app.getMessageList({ conversationID: currentConversationID, nextReqMessageID: nextReqMessageID, count: 15 }).then(function (res) {
            context.state.nextReqMessageID = res.data.nextReqMessageID;
            context.commit('unshiftMessageList', res.data.messageList);
            if (res.data.isCompleted) {
              context.state.isCompleted = true;
              wx.showToast({
                title: '更新成功',
                icon: 'none',
                duration: 1500
              });
            }
            context.state.isLoading = false;
          }).catch(function (err) {
            console.log(err);
          });
        } else {
          wx.showToast({
            title: '你拉的太快了',
            icon: 'none',
            duration: 500
          });
        }
      } else {
        wx.showToast({
          title: '没有更多啦',
          icon: 'none',
          duration: 1500
        });
      }
    }
  }
};

/* harmony default export */ __webpack_exports__["a"] = (conversationModules);

/***/ }),

/***/ "xTcS":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_babel_runtime_helpers_toConsumableArray__ = __webpack_require__("Gu7T");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_babel_runtime_helpers_toConsumableArray___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_0_babel_runtime_helpers_toConsumableArray__);

var groupModules = {
  state: {
    groupList: [],
    currentGroupProfile: {},
    currentGroupMemberList: [],
    offset: 0,
    count: 15,
    isLoading: false
  },
  getters: {
    hasGroupList: function hasGroupList(state) {
      return state.groupList.length > 0;
    }
  },
  mutations: {
    updateOffset: function updateOffset(state) {
      state.offset += state.count;
    },
    updateGroupList: function updateGroupList(state, groupList) {
      state.groupList = groupList;
    },
    updateCurrentGroupMemberList: function updateCurrentGroupMemberList(state, groupMemberList) {
      state.currentGroupMemberList = [].concat(__WEBPACK_IMPORTED_MODULE_0_babel_runtime_helpers_toConsumableArray___default()(state.currentGroupMemberList), __WEBPACK_IMPORTED_MODULE_0_babel_runtime_helpers_toConsumableArray___default()(groupMemberList));
    },
    updateCurrentGroupProfile: function updateCurrentGroupProfile(state, groupProfile) {
      state.currentGroupProfile = groupProfile;
    },
    resetGroup: function resetGroup(state) {
      state.groupList = [];
      state.currentGroupProfile = {};
      state.currentGroupMemberList = [];
      state.offset = 0;
    }
  },
  actions: {
    getGroupMemberList: function getGroupMemberList(context) {
      var _context$state = context.state,
          offset = _context$state.offset,
          count = _context$state.count,
          isLoading = _context$state.isLoading,
          _context$state$curren = _context$state.currentGroupProfile,
          memberNum = _context$state$curren.memberNum,
          groupID = _context$state$curren.groupID;

      var notCompleted = offset < memberNum;
      if (notCompleted) {
        if (!isLoading) {
          context.state.isLoading = true;
          wx.$app.getGroupMemberList({ groupID: groupID, offset: offset, count: count }).then(function (res) {
            context.commit('updateCurrentGroupMemberList', res.data.memberList);
            context.commit('updateOffset');
            context.state.isLoading = false;
          }).catch(function (err) {
            console.log(err);
          });
        } else {
          wx.showToast({
            title: '你拉的太快了',
            icon: 'none',
            duration: 500
          });
        }
      } else {
        wx.showToast({
          title: '没有更多啦',
          icon: 'none',
          duration: 1500
        });
      }
    }
  }
};

/* harmony default export */ __webpack_exports__["a"] = (groupModules);

/***/ })

},["NHnr"]);