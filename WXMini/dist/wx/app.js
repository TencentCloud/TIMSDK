require("./common/manifest.js")
require("./common/vendor.js")
global.webpackJsonpMpvue([1],{

/***/ 116:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony export (immutable) */ __webpack_exports__["a"] = decodeElement;
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__emojiMap__ = __webpack_require__(73);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__index__ = __webpack_require__(17);


/** 传入message.element（群系统消息SystemMessage，群提示消息GroupTip除外）
 * content = {
 *  type: 'TIMTextElem',
 *  content: {
 *    text: 'AAA[龇牙]AAA[龇牙]AAA[龇牙AAA]'
 *  }
 *}
 **/

// 群提示消息的含义 (opType)
var GROUP_TIP_TYPE = {
  MEMBER_JOIN: 1,
  MEMBER_QUIT: 2,
  MEMBER_KICKED_OUT: 3,
  MEMBER_SET_ADMIN: 4, // 被设置为管理员
  MEMBER_CANCELED_ADMIN: 5, // 被取消管理员
  GROUP_INFO_MODIFIED: 6, // 修改群资料，转让群组为该类型，msgBody.msgGroupNewInfo.ownerAccount表示新群主的ID
  MEMBER_INFO_MODIFIED: 7 // 修改群成员信息


  // 解析小程序text, 表情信息也是[嘻嘻]文本
};function parseText(message) {
  var renderDom = [];
  var temp = message.payload.text;
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
// 解析群系统消息
function parseGroupSystemNotice(message) {
  var payload = message.payload;
  var groupName = payload.groupProfile.name || payload.groupProfile.groupID;
  var text = void 0;
  switch (payload.operationType) {
    case 1:
      text = payload.operatorID + ' \u7533\u8BF7\u52A0\u5165\u7FA4\u7EC4\uFF1A' + groupName;
      break;
    case 2:
      text = '\u6210\u529F\u52A0\u5165\u7FA4\u7EC4\uFF1A' + groupName;
      break;
    case 3:
      text = '\u7533\u8BF7\u52A0\u5165\u7FA4\u7EC4\uFF1A' + groupName + '\u88AB\u62D2\u7EDD';
      break;
    case 4:
      text = '\u88AB\u7BA1\u7406\u5458' + payload.operatorID + '\u8E22\u51FA\u7FA4\u7EC4\uFF1A' + groupName;
      break;
    case 5:
      text = '\u7FA4\uFF1A' + groupName + ' \u5DF2\u88AB' + payload.operatorID + '\u89E3\u6563';
      break;
    case 6:
      text = payload.operatorID + '\u521B\u5EFA\u7FA4\uFF1A' + groupName;
      break;
    case 7:
      text = payload.operatorID + '\u9080\u8BF7\u4F60\u52A0\u7FA4\uFF1A' + groupName;
      break;
    case 8:
      text = '\u4F60\u9000\u51FA\u7FA4\u7EC4\uFF1A' + groupName;
      break;
    case 9:
      text = '\u4F60\u88AB' + payload.operatorID + '\u8BBE\u7F6E\u4E3A\u7FA4\uFF1A' + groupName + '\u7684\u7BA1\u7406\u5458';
      break;
    case 10:
      text = '\u4F60\u88AB' + payload.operatorID + '\u64A4\u9500\u7FA4\uFF1A' + groupName + '\u7684\u7BA1\u7406\u5458\u8EAB\u4EFD';
      break;
    case 255:
      text = '自定义群系统通知: ' + payload.userDefinedField;
      break;
  }
  return [{
    name: 'system',
    text: text
  }];
}
// 解析群提示消息
function parseGroupTip(message) {
  var payload = message.payload;
  var tip = void 0;
  switch (payload.operationType) {
    case GROUP_TIP_TYPE.MEMBER_JOIN:
      tip = '\u65B0\u6210\u5458\u52A0\u5165\uFF1A' + payload.userIDList.join(',');
      break;
    case GROUP_TIP_TYPE.MEMBER_QUIT:
      tip = '\u7FA4\u6210\u5458\u9000\u7FA4\uFF1A' + payload.userIDList.join(',');
      break;
    case GROUP_TIP_TYPE.MEMBER_KICKED_OUT:
      tip = '\u7FA4\u6210\u5458\u88AB\u8E22\uFF1A' + payload.userIDList.join(',');
      break;
    case GROUP_TIP_TYPE.MEMBER_SET_ADMIN:
      tip = payload.operatorID + '\u5C06' + payload.userIDList.join(',') + '\u8BBE\u7F6E\u4E3A\u7BA1\u7406\u5458';
      break;
    case GROUP_TIP_TYPE.MEMBER_CANCELED_ADMIN:
      tip = payload.operatorID + '\u5C06' + payload.userIDList.join(',') + '\u53D6\u6D88\u4F5C\u4E3A\u7BA1\u7406\u5458';
      break;
    case GROUP_TIP_TYPE.GROUP_INFO_MODIFIED:
      tip = '群资料修改';
      break;
    case GROUP_TIP_TYPE.MEMBER_INFO_MODIFIED:
      tip = '群成员资料修改';
      if (payload.msgMemberInfo[0].hasOwnProperty('shutupTime')) {
        var time = (payload.msgMemberInfo[0].shutupTime / 60).toFixed(0);
        tip = payload.operatorID + '\u5C06' + payload.msgMemberInfo[0].userID + '\u7981\u8A00' + time + '\u5206\u949F';
      }
      break;
  }
  return [{
    name: 'groupTip',
    text: tip
  }];
}
// 解析自定义消息
function parseCustom(message) {
  var data = message.payload.data;
  if (Object(__WEBPACK_IMPORTED_MODULE_1__index__["c" /* isJSON */])(data)) {
    data = JSON.parse(data);
    if (data.hasOwnProperty('version') && data.version === 3) {
      var tip = void 0;
      var time = Object(__WEBPACK_IMPORTED_MODULE_1__index__["a" /* formatDuration */])(data.duration);
      switch (data.action) {
        case -2:
          tip = '异常挂断';
          break;
        case 0:
          tip = '请求通话';
          break;
        case 1:
          tip = '取消通话';
          break;
        case 2:
          tip = '拒绝通话';
          break;
        case 3:
          tip = '无应答';
          break;
        case 4:
          tip = '开始通话';
          break;
        case 5:
          if (data.duration === 0) {
            tip = '结束通话';
          } else {
            tip = '\u7ED3\u675F\u901A\u8BDD\uFF0C\u901A\u8BDD\u65F6\u957F' + time;
          }
          break;
        case 6:
          tip = '正在通话中';
          break;
      }
      return [{
        name: 'videoCall',
        text: tip
      }];
    }
  }
  return [{
    name: 'custom',
    text: data
  }];
}
// 解析message element
function decodeElement(message) {
  // renderDom是最终渲染的
  switch (message.type) {
    case 'TIMTextElem':
      return parseText(message);
    case 'TIMGroupSystemNoticeElem':
      return parseGroupSystemNotice(message);
    case 'TIMGroupTipElem':
      return parseGroupTip(message);
    case 'TIMCustomElem':
      return parseCustom(message);
    default:
      return [];
  }
}

/***/ }),

/***/ 117:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_babel_runtime_helpers_toConsumableArray__ = __webpack_require__(31);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_babel_runtime_helpers_toConsumableArray___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_0_babel_runtime_helpers_toConsumableArray__);

var groupModules = {
  state: {
    groupList: [],
    currentGroupMemberList: [],
    count: 15,
    isLoading: false
  },
  getters: {
    hasGroupList: function hasGroupList(state) {
      return state.groupList.length > 0;
    }
  },
  mutations: {
    updateGroupList: function updateGroupList(state, groupList) {
      state.groupList = groupList;
    },
    updateCurrentGroupMemberList: function updateCurrentGroupMemberList(state, groupMemberList) {
      state.currentGroupMemberList = [].concat(__WEBPACK_IMPORTED_MODULE_0_babel_runtime_helpers_toConsumableArray___default()(state.currentGroupMemberList), __WEBPACK_IMPORTED_MODULE_0_babel_runtime_helpers_toConsumableArray___default()(groupMemberList));
    },
    resetGroup: function resetGroup(state) {
      state.groupList = [];
      state.currentGroupProfile = {};
      state.currentGroupMemberList = [];
    },
    resetCurrentMemberList: function resetCurrentMemberList(state) {
      state.currentGroupMemberList = [];
    }
  },
  actions: {
    getGroupMemberList: function getGroupMemberList(context) {
      var _context$rootState$co = context.rootState.conversation.currentConversation.groupProfile,
          memberNum = _context$rootState$co.memberNum,
          groupID = _context$rootState$co.groupID;
      var _context$state = context.state,
          count = _context$state.count,
          isLoading = _context$state.isLoading;

      var offset = context.state.currentGroupMemberList.length;
      var notCompleted = offset < memberNum;
      if (notCompleted) {
        if (!isLoading) {
          context.state.isLoading = true;
          wx.$app.getGroupMemberList({ groupID: groupID, offset: offset, count: count }).then(function (res) {
            context.commit('updateCurrentGroupMemberList', res.data.memberList);
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

/***/ }),

/***/ 118:
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

/***/ 119:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
var globalModules = {
  state: {
    isSdkReady: false,
    isCalling: false,
    systemInfo: null
  },
  getters: {
    isSdkReady: function isSdkReady(state) {
      return state.isSdkReady;
    },
    isCalling: function isCalling(state) {
      return state.isCalling;
    },
    isIphoneX: function isIphoneX(state) {
      return state.systemInfo && state.systemInfo.model.indexOf('iPhone X') > -1;
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
    },
    setCalling: function setCalling(state, payload) {
      state.isCalling = payload;
    },
    setSystemInfo: function setSystemInfo(state, payload) {
      state.systemInfo = payload;
    }
  },
  actions: {
    resetStore: function resetStore(context) {
      context.commit('resetGroup');
      context.commit('resetUser');
      context.commit('resetCurrentConversation');
      context.commit('resetAllConversation');
    }
  }
};

/* harmony default export */ __webpack_exports__["a"] = (globalModules);

/***/ }),

/***/ 78:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_mpvue__ = __webpack_require__(0);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_mpvue___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_0_mpvue__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__App__ = __webpack_require__(79);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2_tim_wx_sdk__ = __webpack_require__(55);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2_tim_wx_sdk___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_2_tim_wx_sdk__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3__store_index__ = __webpack_require__(83);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_4_dayjs__ = __webpack_require__(74);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_4_dayjs___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_4_dayjs__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_5_dayjs_locale_zh_cn__ = __webpack_require__(120);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_5_dayjs_locale_zh_cn___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_5_dayjs_locale_zh_cn__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_6__utils__ = __webpack_require__(17);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_7_cos_wx_sdk_v5__ = __webpack_require__(121);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_7_cos_wx_sdk_v5___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_7_cos_wx_sdk_v5__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_8__static_utils_GenerateTestUserSig__ = __webpack_require__(53);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_9__utils_types__ = __webpack_require__(75);











var tim = __WEBPACK_IMPORTED_MODULE_2_tim_wx_sdk___default.a.create({
  SDKAppID: __WEBPACK_IMPORTED_MODULE_8__static_utils_GenerateTestUserSig__["a" /* SDKAPPID */]
});
tim.setLogLevel(0);
wx.$app = tim;
wx.$app.registerPlugin({ 'cos-wx-sdk': __WEBPACK_IMPORTED_MODULE_7_cos_wx_sdk_v5___default.a });
wx.store = __WEBPACK_IMPORTED_MODULE_3__store_index__["a" /* default */];
wx.TIM = __WEBPACK_IMPORTED_MODULE_2_tim_wx_sdk___default.a;
wx.dayjs = __WEBPACK_IMPORTED_MODULE_4_dayjs___default.a;
__WEBPACK_IMPORTED_MODULE_4_dayjs___default.a.locale('zh-cn');

var $bus = new __WEBPACK_IMPORTED_MODULE_0_mpvue___default.a();
__WEBPACK_IMPORTED_MODULE_0_mpvue___default.a.prototype.TIM = __WEBPACK_IMPORTED_MODULE_2_tim_wx_sdk___default.a;
__WEBPACK_IMPORTED_MODULE_0_mpvue___default.a.prototype.$type = __WEBPACK_IMPORTED_MODULE_9__utils_types__["a" /* default */];
__WEBPACK_IMPORTED_MODULE_0_mpvue___default.a.prototype.$store = __WEBPACK_IMPORTED_MODULE_3__store_index__["a" /* default */];
__WEBPACK_IMPORTED_MODULE_0_mpvue___default.a.prototype.$bus = $bus;

tim.on(__WEBPACK_IMPORTED_MODULE_2_tim_wx_sdk___default.a.EVENT.SDK_READY, onReadyStateUpdate, this);
tim.on(__WEBPACK_IMPORTED_MODULE_2_tim_wx_sdk___default.a.EVENT.SDK_NOT_READY, onReadyStateUpdate, this);

tim.on(__WEBPACK_IMPORTED_MODULE_2_tim_wx_sdk___default.a.EVENT.KICKED_OUT, kickOut, this);
// 出错统一处理
tim.on(__WEBPACK_IMPORTED_MODULE_2_tim_wx_sdk___default.a.EVENT.ERROR, onError, this);

tim.on(__WEBPACK_IMPORTED_MODULE_2_tim_wx_sdk___default.a.EVENT.MESSAGE_RECEIVED, messageReceived, this);
tim.on(__WEBPACK_IMPORTED_MODULE_2_tim_wx_sdk___default.a.EVENT.CONVERSATION_LIST_UPDATED, convListUpdate, this);
tim.on(__WEBPACK_IMPORTED_MODULE_2_tim_wx_sdk___default.a.EVENT.GROUP_LIST_UPDATED, groupListUpdate, this);
tim.on(__WEBPACK_IMPORTED_MODULE_2_tim_wx_sdk___default.a.EVENT.BLACKLIST_UPDATED, blackListUpdate, this);
tim.on(__WEBPACK_IMPORTED_MODULE_2_tim_wx_sdk___default.a.EVENT.MESSAGE_RECEIVED, groupSystemNoticeUpdate, this);

function onReadyStateUpdate(_ref) {
  var name = _ref.name;

  var isSDKReady = name === __WEBPACK_IMPORTED_MODULE_2_tim_wx_sdk___default.a.EVENT.SDK_READY;
  if (isSDKReady) {
    wx.$app.getMyProfile().then(function (res) {
      __WEBPACK_IMPORTED_MODULE_3__store_index__["a" /* default */].commit('updateMyInfo', res.data);
    });
    wx.$app.getBlacklist().then(function (res) {
      __WEBPACK_IMPORTED_MODULE_3__store_index__["a" /* default */].commit('setBlacklist', res.data);
    });
  }
  __WEBPACK_IMPORTED_MODULE_3__store_index__["a" /* default */].commit('setSdkReady', isSDKReady);
}

function kickOut(event) {
  __WEBPACK_IMPORTED_MODULE_3__store_index__["a" /* default */].dispatch('resetStore');
  wx.showToast({
    title: '你已被踢下线',
    icon: 'none',
    duration: 1500
  });
  setTimeout(function () {
    wx.reLaunch({
      url: '../login/main'
    });
  }, 500);
}

function onError(event) {
  // 网络错误不弹toast && sdk未初始化完全报错
  if (event.data.message && event.data.code && event.data.code !== 2800 && event.data.code !== 2999) {
    __WEBPACK_IMPORTED_MODULE_3__store_index__["a" /* default */].commit('showToast', {
      title: event.data.message,
      duration: 2000
    });
  }
}

function messageReceived(event) {
  for (var i = 0; i < event.data.length; i++) {
    var item = event.data[i];
    if (item.type === __WEBPACK_IMPORTED_MODULE_9__utils_types__["a" /* default */].MSG_GRP_TIP) {
      if (item.payload.operationType) {
        $bus.$emit('groupNameUpdate', item.payload);
      }
    }
    if (item.type === __WEBPACK_IMPORTED_MODULE_9__utils_types__["a" /* default */].MSG_CUSTOM) {
      if (Object(__WEBPACK_IMPORTED_MODULE_6__utils__["c" /* isJSON */])(item.payload.data)) {
        var videoCustom = JSON.parse(item.payload.data);
        if (videoCustom.version === 3) {
          switch (videoCustom.action) {
            // 对方呼叫我
            case 0:
              if (!__WEBPACK_IMPORTED_MODULE_3__store_index__["a" /* default */].getters.isCalling) {
                var url = '../call/main?args=' + item.payload.data + '&&from=' + item.from + '&&to=' + item.to;
                wx.navigateTo({ url: url });
              } else {
                $bus.$emit('isCalling', item);
              }
              break;
            // 对方取消
            case 1:
              wx.navigateBack({
                delta: 1
              });
              break;
            // 对方拒绝
            case 2:
              $bus.$emit('onRefuse');
              break;
            // 对方不接1min
            case 3:
              wx.navigateBack({
                delta: 1
              });
              break;
            // 对方接听
            case 4:
              $bus.$emit('onCall', videoCustom);
              break;
            // 对方挂断
            case 5:
              $bus.$emit('onClose');
              break;
            // 对方正在通话中
            case 6:
              $bus.$emit('onBusy');
              break;
            default:
              break;
          }
        }
      }
    }
  }
  __WEBPACK_IMPORTED_MODULE_3__store_index__["a" /* default */].dispatch('onMessageEvent', event);
}

function convListUpdate(event) {
  __WEBPACK_IMPORTED_MODULE_3__store_index__["a" /* default */].commit('updateAllConversation', event.data);
}

function groupListUpdate(event) {
  __WEBPACK_IMPORTED_MODULE_3__store_index__["a" /* default */].commit('updateGroupList', event.data);
}

function blackListUpdate(event) {
  __WEBPACK_IMPORTED_MODULE_3__store_index__["a" /* default */].commit('updateBlacklist', event.data);
}

function groupSystemNoticeUpdate(event) {
  console.log('system message', event);
}

// 获取系统信息
var sysInfo = wx.getSystemInfoSync();
__WEBPACK_IMPORTED_MODULE_3__store_index__["a" /* default */].commit('setSystemInfo', sysInfo);

new __WEBPACK_IMPORTED_MODULE_0_mpvue___default.a({
  TIMApp: __WEBPACK_IMPORTED_MODULE_1__App__["a" /* default */]
}).$mount();

/***/ }),

/***/ 79:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__babel_loader_node_modules_mpvue_loader_lib_selector_type_script_index_0_App_vue__ = __webpack_require__(82);
var disposed = false
function injectStyle (ssrContext) {
  if (disposed) return
  __webpack_require__(80)
}
var normalizeComponent = __webpack_require__(1)
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
Component.options.__file = "src\\App.vue"
if (Component.esModule && Object.keys(Component.esModule).some(function (key) {return key !== "default" && key.substr(0, 2) !== "__"})) {console.error("named exports are not supported in *.vue files.")}

/* hot reload */
if (false) {(function () {
  var hotAPI = require("vue-hot-reload-api")
  hotAPI.install(require("vue"), false)
  if (!hotAPI.compatible) return
  module.hot.accept()
  if (!module.hot.data) {
    hotAPI.createRecord("data-v-46e12115", Component.options)
  } else {
    hotAPI.reload("data-v-46e12115", Component.options)
  }
  module.hot.dispose(function (data) {
    disposed = true
  })
})()}

/* harmony default export */ __webpack_exports__["a"] = (Component.exports);


/***/ }),

/***/ 80:
/***/ (function(module, exports) {

// removed by extract-text-webpack-plugin

/***/ }),

/***/ 82:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";

/* harmony default export */ __webpack_exports__["a"] = ({
  created: function created() {}
});

/***/ }),

/***/ 83:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_vue__ = __webpack_require__(0);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_vue___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_0_vue__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1_vuex__ = __webpack_require__(2);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2__modules_conversation_js__ = __webpack_require__(84);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3__modules_group__ = __webpack_require__(117);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_4__modules_user__ = __webpack_require__(118);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_5__modules_global__ = __webpack_require__(119);






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

/***/ 84:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_babel_runtime_core_js_promise__ = __webpack_require__(56);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_babel_runtime_core_js_promise___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_0_babel_runtime_core_js_promise__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1_babel_runtime_helpers_toConsumableArray__ = __webpack_require__(31);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1_babel_runtime_helpers_toConsumableArray___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_1_babel_runtime_helpers_toConsumableArray__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2__utils_index__ = __webpack_require__(17);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3__utils_decodeElement__ = __webpack_require__(116);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_4_tim_wx_sdk__ = __webpack_require__(55);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_4_tim_wx_sdk___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_4_tim_wx_sdk__);






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
    },
    totalUnreadCount: function totalUnreadCount(state) {
      var result = state.allConversation.reduce(function (count, _ref) {
        var unreadCount = _ref.unreadCount;
        return count + unreadCount;
      }, 0);
      if (result === 0) {
        wx.removeTabBarBadge({ index: 0 });
      } else {
        wx.setTabBarBadge({ index: 0, text: result > 99 ? '99+' : String(result) });
      }
      return result;
    }
  },
  mutations: {
    // 历史头插消息列表
    // 小程序问题，在渲染的时候模板引擎不能处理函数，所以只能在渲染前处理好message的展示问题
    unshiftMessageList: function unshiftMessageList(state, messageList) {
      var list = [].concat(__WEBPACK_IMPORTED_MODULE_1_babel_runtime_helpers_toConsumableArray___default()(messageList));
      for (var i = 0; i < list.length; i++) {
        var message = list[i];
        list[i].virtualDom = Object(__WEBPACK_IMPORTED_MODULE_3__utils_decodeElement__["a" /* decodeElement */])(message);
        var date = new Date(message.time * 1000);
        list[i].newtime = Object(__WEBPACK_IMPORTED_MODULE_2__utils_index__["b" /* formatTime */])(date);
      }
      state.currentMessageList = [].concat(__WEBPACK_IMPORTED_MODULE_1_babel_runtime_helpers_toConsumableArray___default()(list), __WEBPACK_IMPORTED_MODULE_1_babel_runtime_helpers_toConsumableArray___default()(state.currentMessageList));
    },

    // 收到
    receiveMessage: function receiveMessage(state, messageList) {
      var list = [].concat(__WEBPACK_IMPORTED_MODULE_1_babel_runtime_helpers_toConsumableArray___default()(messageList));
      for (var i = 0; i < list.length; i++) {
        var message = list[i];
        list[i].virtualDom = Object(__WEBPACK_IMPORTED_MODULE_3__utils_decodeElement__["a" /* decodeElement */])(message);
        var date = new Date(message.time * 1000);
        list[i].newtime = Object(__WEBPACK_IMPORTED_MODULE_2__utils_index__["b" /* formatTime */])(date);
      }
      state.currentMessageList = [].concat(__WEBPACK_IMPORTED_MODULE_1_babel_runtime_helpers_toConsumableArray___default()(state.currentMessageList), __WEBPACK_IMPORTED_MODULE_1_babel_runtime_helpers_toConsumableArray___default()(list));
    },
    sendMessage: function sendMessage(state, message) {
      message.virtualDom = Object(__WEBPACK_IMPORTED_MODULE_3__utils_decodeElement__["a" /* decodeElement */])(message);
      var date = new Date(message.time * 1000);
      message.newtime = Object(__WEBPACK_IMPORTED_MODULE_2__utils_index__["b" /* formatTime */])(date);
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
          list[i].lastMessage._lastTime = Object(__WEBPACK_IMPORTED_MODULE_2__utils_index__["b" /* formatTime */])(date);
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
    }
  },
  actions: {
    // 消息事件
    onMessageEvent: function onMessageEvent(context, event) {
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
      // 判断是否拉完了，isCompleted 的话要报一下没有更多了

      if (!context.state.isCompleted) {
        // 如果请求还没回来，又拉，此时做一下防御
        if (!context.state.isLoading) {
          context.state.isLoading = true;
          wx.$app.getMessageList({ conversationID: currentConversationID, nextReqMessageID: nextReqMessageID, count: 15 }).then(function (res) {
            context.state.nextReqMessageID = res.data.nextReqMessageID;
            context.commit('unshiftMessageList', res.data.messageList);
            if (res.data.isCompleted) {
              context.state.isCompleted = true;
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
    },
    checkoutConversation: function checkoutConversation(context, conversationID) {
      context.commit('resetCurrentConversation');
      wx.$app.setMessageRead({ conversationID: conversationID });
      return wx.$app.getConversationProfile(conversationID).then(function (_ref2) {
        var conversation = _ref2.data.conversation;

        context.commit('updateCurrentConversation', conversation);
        context.dispatch('getMessageList');
        var name = '';
        switch (conversation.type) {
          case __WEBPACK_IMPORTED_MODULE_4_tim_wx_sdk___default.a.TYPES.CONV_C2C:
            name = conversation.userProfile.nick || conversation.userProfile.userID;
            break;
          case __WEBPACK_IMPORTED_MODULE_4_tim_wx_sdk___default.a.TYPES.CONV_GROUP:
            name = conversation.groupProfile.name || conversation.groupProfile.groupID;
            break;
          default:
            name = '系统通知';
        }
        wx.navigateTo({ url: '../chat/main?toAccount=' + name + '&type=' + conversation.type });
        return __WEBPACK_IMPORTED_MODULE_0_babel_runtime_core_js_promise___default.a.resolve();
      });
    }
  }
};

/* harmony default export */ __webpack_exports__["a"] = (conversationModules);

/***/ })

},[78]);