require("../../common/manifest.js")
require("../../common/vendor.js")
global.webpackJsonpMpvue([2],{

/***/ 217:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_vue__ = __webpack_require__(0);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_vue___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_0_vue__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__index__ = __webpack_require__(218);



var app = new __WEBPACK_IMPORTED_MODULE_0_vue___default.a(__WEBPACK_IMPORTED_MODULE_1__index__["a" /* default */]);
app.$mount();

/***/ }),

/***/ 218:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__babel_loader_node_modules_mpvue_loader_lib_selector_type_script_index_0_index_vue__ = __webpack_require__(220);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__node_modules_mpvue_loader_lib_template_compiler_index_id_data_v_7bf83731_hasScoped_false_transformToRequire_video_src_source_src_img_src_image_xlink_href_fileExt_template_wxml_script_js_style_wxss_platform_wx_node_modules_mpvue_loader_lib_selector_type_template_index_0_index_vue__ = __webpack_require__(221);
var disposed = false
function injectStyle (ssrContext) {
  if (disposed) return
  __webpack_require__(219)
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
  __WEBPACK_IMPORTED_MODULE_1__node_modules_mpvue_loader_lib_template_compiler_index_id_data_v_7bf83731_hasScoped_false_transformToRequire_video_src_source_src_img_src_image_xlink_href_fileExt_template_wxml_script_js_style_wxss_platform_wx_node_modules_mpvue_loader_lib_selector_type_template_index_0_index_vue__["a" /* default */],
  __vue_styles__,
  __vue_scopeId__,
  __vue_module_identifier__
)
Component.options.__file = "src\\pages\\user-profile\\index.vue"
if (Component.esModule && Object.keys(Component.esModule).some(function (key) {return key !== "default" && key.substr(0, 2) !== "__"})) {console.error("named exports are not supported in *.vue files.")}
if (Component.options.functional) {console.error("[vue-loader] index.vue: functional components are not supported with templates, they should use render functions.")}

/* hot reload */
if (false) {(function () {
  var hotAPI = require("vue-hot-reload-api")
  hotAPI.install(require("vue"), false)
  if (!hotAPI.compatible) return
  module.hot.accept()
  if (!module.hot.data) {
    hotAPI.createRecord("data-v-7bf83731", Component.options)
  } else {
    hotAPI.reload("data-v-7bf83731", Component.options)
  }
  module.hot.dispose(function (data) {
    disposed = true
  })
})()}

/* harmony default export */ __webpack_exports__["a"] = (Component.exports);


/***/ }),

/***/ 219:
/***/ (function(module, exports) {

// removed by extract-text-webpack-plugin

/***/ }),

/***/ 220:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_babel_runtime_core_js_json_stringify__ = __webpack_require__(54);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_babel_runtime_core_js_json_stringify___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_0_babel_runtime_core_js_json_stringify__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1_babel_runtime_helpers_extends__ = __webpack_require__(4);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1_babel_runtime_helpers_extends___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_1_babel_runtime_helpers_extends__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2_vuex__ = __webpack_require__(2);


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
      userProfile: {},
      isInBlacklist: false
    };
  },

  computed: __WEBPACK_IMPORTED_MODULE_1_babel_runtime_helpers_extends___default()({}, Object(__WEBPACK_IMPORTED_MODULE_2_vuex__["c" /* mapState */])({
    blacklist: function blacklist(state) {
      return state.user.blacklist;
    }
  }), Object(__WEBPACK_IMPORTED_MODULE_2_vuex__["b" /* mapGetters */])(['isIphoneX'])),
  onLoad: function onLoad(_ref) {
    var _this = this;

    var userID = _ref.userID,
        groupID = _ref.groupID;

    if (userID) {
      if (this.blacklist.indexOf(userID) > -1) {
        this.isInBlacklist = true;
      }
      wx.$app.getUserProfile({ userIDList: [userID] }).then(function (res) {
        _this.userProfile = res.data[0];
      });
    }
  },
  onUnload: function onUnload() {
    this.userProfile = {};
    this.isInBlacklist = false;
  },

  methods: {
    getRandomInt: function getRandomInt(min, max) {
      min = Math.ceil(min);
      max = Math.floor(max);
      return Math.floor(Math.random() * (max - min)) + min;
    },
    videoCall: function videoCall() {
      var options = {
        call_id: '',
        version: 3,
        room_id: this.getRandomInt(0, 42949),
        action: 0,
        duration: 0,
        invited_list: []
      };
      var args = __WEBPACK_IMPORTED_MODULE_0_babel_runtime_core_js_json_stringify___default()(options);
      var message = wx.$app.createCustomMessage({
        to: this.userProfile.userID,
        conversationType: 'C2C',
        payload: {
          data: args,
          description: '',
          extension: ''
        }
      });
      this.$store.commit('sendMessage', message);
      wx.$app.sendMessage(message);
      var url = '../call/main?args=' + args + '&&from=' + message.from + '&&to=' + message.to;
      wx.navigateTo({ url: url });
    },
    sendMessage: function sendMessage() {
      this.$store.dispatch('checkoutConversation', 'C2C' + this.userProfile.userID);
    },
    handleSwitch: function handleSwitch(event) {
      if (event.mp.detail.value) {
        this.addBlackList();
      } else {
        this.deleteBlackList();
      }
    },

    // 拉黑好友
    addBlackList: function addBlackList() {
      var _this2 = this;

      wx.$app.addToBlacklist({ userIDList: [this.userProfile.userID] }).then(function (res) {
        _this2.$store.commit('showToast', {
          title: '拉黑成功',
          icon: 'none',
          duration: 1500
        });
        _this2.isInBlacklist = true;
        _this2.$store.commit('setBlacklist', res.data);
      }).catch(function () {
        _this2.$store.commit('showToast', {
          title: '拉黑失败',
          icon: 'none',
          duration: 1500
        });
      });
    },

    // 取消拉黑
    deleteBlackList: function deleteBlackList() {
      var _this3 = this;

      wx.$app.removeFromBlacklist({ userIDList: [this.userProfile.userID] }).then(function (res) {
        _this3.$store.commit('showToast', {
          title: '取消拉黑成功',
          icon: 'none',
          duration: 1500
        });
        _this3.$store.commit('setBlacklist', res.data);
        _this3.isInBlacklist = false;
      }).catch(function () {
        _this3.$store.commit('showToast', {
          title: '取消拉黑失败',
          icon: 'none',
          duration: 1500
        });
      });
    }
  }
});

/***/ }),

/***/ 221:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
var render = function () {var _vm=this;var _h=_vm.$createElement;var _c=_vm._self._c||_h;
  return _c('div', {
    staticClass: "container"
  }, [_c('div', {
    staticClass: "info-card"
  }, [_c('i-avatar', {
    attrs: {
      "i-class": "avatar",
      "src": _vm.userProfile.avatar,
      "mpcomid": '0'
    }
  }), _vm._v(" "), _c('div', {
    staticClass: "basic"
  }, [_c('div', {
    staticClass: "username"
  }, [_vm._v(_vm._s(_vm.userProfile.nick || '未设置'))]), _vm._v(" "), _c('div', {
    staticClass: "user-id"
  }, [_vm._v("用户ID：" + _vm._s(_vm.userProfile.userID))])])], 1), _vm._v(" "), _c('i-cell-group', {
    attrs: {
      "i-class": "cell-group",
      "mpcomid": '2'
    }
  }, [_c('i-cell', {
    attrs: {
      "title": "个性签名",
      "mpcomid": '1'
    }
  }, [_c('div', {
    staticClass: "signature",
    slot: "footer"
  }, [_vm._v("\n        " + _vm._s(_vm.userProfile.selfSignature || '暂无') + "\n      ")])])], 1), _vm._v(" "), _c('i-cell-group', {
    attrs: {
      "i-class": "cell-group",
      "mpcomid": '4'
    }
  }, [_c('i-cell', {
    attrs: {
      "title": "加入黑名单",
      "mpcomid": '3'
    }
  }, [_c('switch', {
    attrs: {
      "color": "#006fff",
      "checked": _vm.isInBlacklist,
      "eventid": '0'
    },
    on: {
      "change": _vm.handleSwitch
    },
    slot: "footer"
  })])], 1), _vm._v(" "), _c('div', {
    staticClass: "action-list",
    style: ({
      'margin-bottom': _vm.isIphoneX ? '34px' : 0
    })
  }, [_c('button', {
    staticClass: "video-call",
    attrs: {
      "eventid": '1'
    },
    on: {
      "click": _vm.videoCall
    }
  }, [_vm._v("\n      音视频通话\n      "), _c('div', {
    staticClass: "new-badge"
  }, [_vm._v("NEW")])]), _vm._v(" "), _c('button', {
    staticClass: "send-messsage",
    attrs: {
      "eventid": '2'
    },
    on: {
      "click": _vm.sendMessage
    }
  }, [_vm._v("发送消息")])], 1)], 1)
}
var staticRenderFns = []
render._withStripped = true
var esExports = { render: render, staticRenderFns: staticRenderFns }
/* harmony default export */ __webpack_exports__["a"] = (esExports);
if (false) {
  module.hot.accept()
  if (module.hot.data) {
     require("vue-hot-reload-api").rerender("data-v-7bf83731", esExports)
  }
}

/***/ })

},[217]);