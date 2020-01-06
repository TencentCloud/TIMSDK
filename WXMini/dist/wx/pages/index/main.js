require("../../common/manifest.js")
require("../../common/vendor.js")
global.webpackJsonpMpvue([10],{

/***/ 177:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_vue__ = __webpack_require__(0);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_vue___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_0_vue__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__index__ = __webpack_require__(178);



// add this to handle exception
__WEBPACK_IMPORTED_MODULE_0_vue___default.a.config.errorHandler = function (err) {
  if (console && console.error) {
    console.error(err);
  }
};

var app = new __WEBPACK_IMPORTED_MODULE_0_vue___default.a(__WEBPACK_IMPORTED_MODULE_1__index__["a" /* default */]);
app.$mount();

/***/ }),

/***/ 178:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__babel_loader_node_modules_mpvue_loader_lib_selector_type_script_index_0_index_vue__ = __webpack_require__(180);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__node_modules_mpvue_loader_lib_template_compiler_index_id_data_v_0c62411e_hasScoped_false_transformToRequire_video_src_source_src_img_src_image_xlink_href_fileExt_template_wxml_script_js_style_wxss_platform_wx_node_modules_mpvue_loader_lib_selector_type_template_index_0_index_vue__ = __webpack_require__(181);
var disposed = false
function injectStyle (ssrContext) {
  if (disposed) return
  __webpack_require__(179)
}
var normalizeComponent = __webpack_require__(1)
/* script */

/* template */

/* styles */
var __vue_styles__ = injectStyle
/* scopeId */
var __vue_scopeId__ = null
/* moduleIdentifier (server only) */
var __vue_module_identifier__ = null
var Component = normalizeComponent(
  __WEBPACK_IMPORTED_MODULE_0__babel_loader_node_modules_mpvue_loader_lib_selector_type_script_index_0_index_vue__["a" /* default */],
  __WEBPACK_IMPORTED_MODULE_1__node_modules_mpvue_loader_lib_template_compiler_index_id_data_v_0c62411e_hasScoped_false_transformToRequire_video_src_source_src_img_src_image_xlink_href_fileExt_template_wxml_script_js_style_wxss_platform_wx_node_modules_mpvue_loader_lib_selector_type_template_index_0_index_vue__["a" /* default */],
  __vue_styles__,
  __vue_scopeId__,
  __vue_module_identifier__
)
Component.options.__file = "src\\pages\\index\\index.vue"
if (Component.esModule && Object.keys(Component.esModule).some(function (key) {return key !== "default" && key.substr(0, 2) !== "__"})) {console.error("named exports are not supported in *.vue files.")}
if (Component.options.functional) {console.error("[vue-loader] index.vue: functional components are not supported with templates, they should use render functions.")}

/* hot reload */
if (false) {(function () {
  var hotAPI = require("vue-hot-reload-api")
  hotAPI.install(require("vue"), false)
  if (!hotAPI.compatible) return
  module.hot.accept()
  if (!module.hot.data) {
    hotAPI.createRecord("data-v-0c62411e", Component.options)
  } else {
    hotAPI.reload("data-v-0c62411e", Component.options)
  }
  module.hot.dispose(function (data) {
    disposed = true
  })
})()}

/* harmony default export */ __webpack_exports__["a"] = (Component.exports);


/***/ }),

/***/ 179:
/***/ (function(module, exports) {

// removed by extract-text-webpack-plugin

/***/ }),

/***/ 180:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_babel_runtime_helpers_extends__ = __webpack_require__(6);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_babel_runtime_helpers_extends___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_0_babel_runtime_helpers_extends__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1_vuex__ = __webpack_require__(4);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2__utils_index__ = __webpack_require__(17);

//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//



/* harmony default export */ __webpack_exports__["a"] = ({
  data: function data() {
    return {
      modalVisible: false,
      conversation: {}
    };
  },

  computed: __WEBPACK_IMPORTED_MODULE_0_babel_runtime_helpers_extends___default()({}, Object(__WEBPACK_IMPORTED_MODULE_1_vuex__["c" /* mapState */])({
    allConversation: function allConversation(state) {
      return state.conversation.allConversation;
    },
    isSdkReady: function isSdkReady(state) {
      return state.global.isSdkReady;
    }
  }), Object(__WEBPACK_IMPORTED_MODULE_1_vuex__["b" /* mapGetters */])(['totalUnreadCount', 'myInfo'])),
  // 消息列表下拉
  onPullDownRefresh: function onPullDownRefresh() {
    Object(__WEBPACK_IMPORTED_MODULE_2__utils_index__["e" /* throttle */])(wx.$app.getConversationList(), 1000);
    wx.stopPullDownRefresh();
  },

  methods: {
    longTimePress: function longTimePress(item) {
      this.conversation = item;
      this.handleModalShow();
    },
    handleModalShow: function handleModalShow() {
      this.modalVisible = !this.modalVisible;
    },
    handleConfirm: function handleConfirm() {
      this.handleModalShow();
      this.deleteConversation(this.conversation);
    },

    // 将某会话设为已读
    setMessageRead: function setMessageRead(item) {
      if (item.unreadCount === 0) {
        return;
      }
      wx.$app.setMessageRead({
        conversationID: item.conversationID
      });
    },

    // 点击某会话
    checkoutConversation: function checkoutConversation(item, name) {
      this.$store.dispatch('checkoutConversation', item.conversationID);
    },

    // 点击系统通知时，处理notification
    checkoutNotification: function checkoutNotification(item) {
      var _this = this;

      this.$store.commit('resetCurrentConversation');
      this.$store.commit('resetGroup');
      this.setMessageRead(item);
      wx.$app.getConversationProfile(item.conversationID).then(function (res) {
        _this.$store.commit('updateCurrentConversation', res.data.conversation);
        _this.$store.dispatch('getMessageList');
      });
      var url = '../system/main';
      wx.navigateTo({ url: url });
    },

    // 删除会话
    deleteConversation: function deleteConversation(item) {
      wx.$app.deleteConversation(item.conversationID).then(function (res) {
        console.log('delete success', res);
      });
    },
    empty: function empty() {
      var url = '../search/main';
      wx.navigateTo({ url: url });
    }
  },
  onLoad: function onLoad() {
    if (!this.isSdkReady) {
      wx.showLoading({ title: '正在同步数据', mask: true });
    }
  },

  watch: {
    isSdkReady: function isSdkReady(newVal) {
      if (newVal) {
        wx.hideLoading();
      }
    }
  }
});

/***/ }),

/***/ 181:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
var render = function () {var _vm=this;var _h=_vm.$createElement;var _c=_vm._self._c||_h;
  return _c('div', {
    staticClass: "chat-container"
  }, [(_vm.allConversation.length === 0) ? _c('div', {
    staticClass: "empty"
  }, [_c('button', {
    staticClass: "empty-button",
    attrs: {
      "type": "button",
      "eventid": '0'
    },
    on: {
      "click": _vm.empty
    }
  }, [_vm._v("\n      发起一段对话吧\n    ")])], 1) : _vm._e(), _vm._v(" "), _c('i-modal', {
    attrs: {
      "title": "确认删除会话？",
      "visible": _vm.modalVisible,
      "eventid": '1',
      "mpcomid": '0'
    },
    on: {
      "ok": function($event) {
        _vm.handleConfirm()
      },
      "cancel": _vm.handleModalShow
    }
  }), _vm._v(" "), _vm._l((_vm.allConversation), function(item, index) {
    return [(item.type === 'C2C') ? _c('div', {
      key: item.conversationID,
      staticClass: "chat",
      attrs: {
        "eventid": '4_' + index
      },
      on: {
        "longpress": function($event) {
          _vm.longTimePress(item)
        },
        "click": function($event) {
          _vm.checkoutConversation(item, item.userProfile.nick || item.userProfile.userID)
        }
      }
    }, [_c('div', {
      staticClass: "avatar-container"
    }, [_c('i-avatar', {
      attrs: {
        "src": item.userProfile.avatar || '/static/images/avatar.png',
        "i-class": "avatar",
        "mpcomid": '1_' + index
      }
    })], 1), _vm._v(" "), _c('div', {
      staticClass: "right"
    }, [_c('div', {
      staticClass: "information"
    }, [_c('div', {
      staticClass: "username"
    }, [_vm._v(_vm._s(item.userProfile.nick || item.userProfile.userID))]), _vm._v(" "), (!item.lastMessage.isRevoked) ? _c('div', {
      staticClass: "content"
    }, [_vm._v(_vm._s(item.lastMessage.messageForShow))]) : _c('div', {
      staticClass: "content"
    }, [(_vm.myInfo.userID === item.lastMessage.fromAccount) ? [_vm._v("你撤回了一条消息")] : [_vm._v(_vm._s(item.lastMessage.fromAccount) + "撤回了一条消息")]], 2)]), _vm._v(" "), _c('div', {
      staticClass: "time"
    }, [_c('div', {
      staticClass: "last"
    }, [_vm._v(_vm._s(item.lastMessage._lastTime))]), _vm._v(" "), (item.unreadCount > 0) ? _c('div', {
      staticClass: "remain"
    }, [(item.unreadCount > 99) ? _c('span', {
      staticClass: "info"
    }, [_vm._v("99+")]) : _c('span', {
      staticClass: "info"
    }, [_vm._v(_vm._s(item.unreadCount))])]) : _vm._e()])])]) : (item.type === 'GROUP') ? _c('div', {
      key: item.conversationID,
      staticClass: "chat",
      attrs: {
        "eventid": '2_' + index
      },
      on: {
        "click": function($event) {
          _vm.checkoutConversation(item, item.groupProfile.name || item.groupProfile.ID)
        },
        "longpress": function($event) {
          _vm.longTimePress(item)
        }
      }
    }, [_c('div', {
      staticClass: "avatar-container"
    }, [_c('i-avatar', {
      attrs: {
        "src": item.groupProfile.avatar,
        "i-class": "avatar",
        "mpcomid": '4_' + index
      }
    })], 1), _vm._v(" "), _c('div', {
      staticClass: "right"
    }, [_c('div', {
      staticClass: "information"
    }, [_c('div', {
      staticClass: "username"
    }, [_vm._v(_vm._s(item.groupProfile.name || item.groupProfile.groupID))]), _vm._v(" "), (!item.lastMessage.isRevoked) ? _c('div', {
      staticClass: "content"
    }, [(item.lastMessage.fromAccount === '@TIM#SYSTEM') ? [_vm._v(_vm._s(item.lastMessage.messageForShow))] : [_vm._v(_vm._s(item.lastMessage.fromAccount) + "：" + _vm._s(item.lastMessage.messageForShow))]], 2) : _c('div', {
      staticClass: "content"
    }, [(_vm.myInfo.userID === item.lastMessage.fromAccount) ? [_vm._v("你撤回了一条消息")] : [_vm._v(_vm._s(item.lastMessage.fromAccount) + "撤回了一条消息")]], 2)]), _vm._v(" "), _c('div', {
      staticClass: "time"
    }, [_c('div', {
      staticClass: "last"
    }, [_vm._v(_vm._s(item.lastMessage._lastTime))]), _vm._v(" "), (item.unreadCount > 0) ? _c('div', {
      staticClass: "remain"
    }, [(item.unreadCount > 99) ? _c('span', {
      staticClass: "info"
    }, [_vm._v("99+")]) : _c('span', {
      staticClass: "info"
    }, [_vm._v(_vm._s(item.unreadCount))])]) : _vm._e()])])]) : (item.type === '@TIM#SYSTEM') ? _c('div', {
      key: item.conversationID,
      staticClass: "chat",
      attrs: {
        "eventid": '3_' + index
      },
      on: {
        "click": function($event) {
          _vm.checkoutNotification(item)
        },
        "longpress": function($event) {
          _vm.longTimePress(item)
        }
      }
    }, [_vm._m(0, true), _vm._v(" "), _c('div', {
      staticClass: "right"
    }, [_vm._m(1, true), _vm._v(" "), _c('div', {
      staticClass: "time"
    }, [_c('div', {
      staticClass: "last"
    }), _vm._v(" "), (item.unreadCount > 0) ? _c('div', {
      staticClass: "remain"
    }, [(item.unreadCount > 99) ? _c('span', {
      staticClass: "info"
    }, [_vm._v("99+")]) : _c('span', {
      staticClass: "info"
    }, [_vm._v(_vm._s(item.unreadCount))])]) : _vm._e()])])]) : _vm._e()]
  })], 2)
}
var staticRenderFns = [function () {var _vm=this;var _h=_vm.$createElement;var _c=_vm._self._c||_h;
  return _c('div', {
    staticClass: "avatar-container"
  }, [_c('image', {
    staticClass: "avatar",
    attrs: {
      "src": "/static/images/system.png"
    }
  })])
},function () {var _vm=this;var _h=_vm.$createElement;var _c=_vm._self._c||_h;
  return _c('div', {
    staticClass: "information"
  }, [_c('div', {
    staticClass: "username"
  }, [_vm._v("系统通知")]), _vm._v(" "), _c('div', {
    staticClass: "content"
  }, [_vm._v("点击查看")])])
}]
render._withStripped = true
var esExports = { render: render, staticRenderFns: staticRenderFns }
/* harmony default export */ __webpack_exports__["a"] = (esExports);
if (false) {
  module.hot.accept()
  if (module.hot.data) {
     require("vue-hot-reload-api").rerender("data-v-0c62411e", esExports)
  }
}

/***/ })

},[177]);