require("../../common/manifest.js")
require("../../common/vendor.js")
global.webpackJsonpMpvue([9],{

/***/ 182:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_vue__ = __webpack_require__(0);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_vue___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_0_vue__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__index__ = __webpack_require__(183);



var app = new __WEBPACK_IMPORTED_MODULE_0_vue___default.a(__WEBPACK_IMPORTED_MODULE_1__index__["a" /* default */]);
app.$mount();

/***/ }),

/***/ 183:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__babel_loader_node_modules_mpvue_loader_lib_selector_type_script_index_0_index_vue__ = __webpack_require__(185);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__node_modules_mpvue_loader_lib_template_compiler_index_id_data_v_1532f6f5_hasScoped_true_transformToRequire_video_src_source_src_img_src_image_xlink_href_fileExt_template_wxml_script_js_style_wxss_platform_wx_node_modules_mpvue_loader_lib_selector_type_template_index_0_index_vue__ = __webpack_require__(186);
var disposed = false
function injectStyle (ssrContext) {
  if (disposed) return
  __webpack_require__(184)
}
var normalizeComponent = __webpack_require__(1)
/* script */

/* template */

/* styles */
var __vue_styles__ = injectStyle
/* scopeId */
var __vue_scopeId__ = "data-v-1532f6f5"
/* moduleIdentifier (server only) */
var __vue_module_identifier__ = null
var Component = normalizeComponent(
  __WEBPACK_IMPORTED_MODULE_0__babel_loader_node_modules_mpvue_loader_lib_selector_type_script_index_0_index_vue__["a" /* default */],
  __WEBPACK_IMPORTED_MODULE_1__node_modules_mpvue_loader_lib_template_compiler_index_id_data_v_1532f6f5_hasScoped_true_transformToRequire_video_src_source_src_img_src_image_xlink_href_fileExt_template_wxml_script_js_style_wxss_platform_wx_node_modules_mpvue_loader_lib_selector_type_template_index_0_index_vue__["a" /* default */],
  __vue_styles__,
  __vue_scopeId__,
  __vue_module_identifier__
)
Component.options.__file = "src\\pages\\login\\index.vue"
if (Component.esModule && Object.keys(Component.esModule).some(function (key) {return key !== "default" && key.substr(0, 2) !== "__"})) {console.error("named exports are not supported in *.vue files.")}
if (Component.options.functional) {console.error("[vue-loader] index.vue: functional components are not supported with templates, they should use render functions.")}

/* hot reload */
if (false) {(function () {
  var hotAPI = require("vue-hot-reload-api")
  hotAPI.install(require("vue"), false)
  if (!hotAPI.compatible) return
  module.hot.accept()
  if (!module.hot.data) {
    hotAPI.createRecord("data-v-1532f6f5", Component.options)
  } else {
    hotAPI.reload("data-v-1532f6f5", Component.options)
  }
  module.hot.dispose(function (data) {
    disposed = true
  })
})()}

/* harmony default export */ __webpack_exports__["a"] = (Component.exports);


/***/ }),

/***/ 184:
/***/ (function(module, exports) {

// removed by extract-text-webpack-plugin

/***/ }),

/***/ 185:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_babel_runtime_helpers_extends__ = __webpack_require__(6);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_babel_runtime_helpers_extends___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_0_babel_runtime_helpers_extends__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1_vuex__ = __webpack_require__(4);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2__static_utils_GenerateTestUserSig__ = __webpack_require__(53);

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
      password: '',
      userIDList: new Array(30).fill().map(function (item, idx) {
        return 'user' + idx;
      }),
      selectedIndex: 1,
      loading: false
    };
  },

  computed: __WEBPACK_IMPORTED_MODULE_0_babel_runtime_helpers_extends___default()({}, Object(__WEBPACK_IMPORTED_MODULE_1_vuex__["c" /* mapState */])({
    myInfo: function myInfo(state) {
      return state.user.myInfo;
    }
  })),
  onUnload: function onUnload() {
    this.loading = false;
  },

  methods: {
    // 点击登录进行初始化
    handleLogin: function handleLogin() {
      var _this = this;

      var userID = this.userIDList[this.selectedIndex];
      // case1: 要登录的用户是当前已登录的用户，则直接跳转即可
      if (this.myInfo.userID && userID === this.myInfo.userID) {
        wx.switchTab({ url: '../index/main' });
        return;
      }

      this.loading = true;
      // case2: 当前已经登录了用户，但是和即将登录的用户不一致，则先登出当前登录的用户，再登录
      if (this.myInfo.userID) {
        this.$store.dispatch('resetStore');
        wx.$app.logout().then(function () {
          _this.login(userID);
        });
        return;
      }
      // case3: 正常登录流程
      this.login(userID);
    },
    login: function login(userID) {
      var _this2 = this;

      wx.$app.login({
        userID: userID,
        userSig: Object(__WEBPACK_IMPORTED_MODULE_2__static_utils_GenerateTestUserSig__["b" /* genTestUserSig */])(this.userIDList[this.selectedIndex]).userSig
      }).then(function () {
        wx.switchTab({ url: '../index/main' });
      }).catch(function () {
        _this2.loading = false;
      });
    },
    choose: function choose(event) {
      this.selectedIndex = Number(event.mp.detail.value);
    }
  }
});

/***/ }),

/***/ 186:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
var render = function () {var _vm=this;var _h=_vm.$createElement;var _c=_vm._self._c||_h;
  return _c('div', {
    staticClass: "counter-warp"
  }, [_vm._m(0), _vm._v(" "), _c('picker', {
    staticClass: "picker",
    attrs: {
      "range": _vm.userIDList,
      "value": _vm.selectedIndex,
      "eventid": '0'
    },
    on: {
      "change": _vm.choose
    }
  }, [_c('div', {
    staticClass: "cell"
  }, [_c('div', {
    staticClass: "choose"
  }, [_vm._v("用户")]), _vm._v(" "), _c('div', [_vm._v("\n        " + _vm._s(_vm.userIDList[_vm.selectedIndex]) + "\n        "), _c('i-icon', {
    attrs: {
      "type": "enter",
      "mpcomid": '0'
    }
  })], 1)])]), _vm._v(" "), _c('button', {
    staticClass: "login-button",
    attrs: {
      "hover-class": "clicked",
      "loading": _vm.loading,
      "eventid": '1'
    },
    on: {
      "click": _vm.handleLogin
    }
  }, [_vm._v("登录")])], 1)
}
var staticRenderFns = [function () {var _vm=this;var _h=_vm.$createElement;var _c=_vm._self._c||_h;
  return _c('div', {
    staticClass: "header"
  }, [_c('div', {
    staticClass: "header-content"
  }, [_c('img', {
    staticClass: "icon",
    attrs: {
      "src": "../../../static/images/im.png"
    }
  }), _vm._v(" "), _c('div', {
    staticClass: "text"
  }, [_c('div', {
    staticClass: "text-header"
  }, [_vm._v("登录 · 即时通信")]), _vm._v(" "), _c('div', {
    staticClass: "text-content"
  }, [_vm._v("体验群组聊天，视频对话等IM功能")])])])])
}]
render._withStripped = true
var esExports = { render: render, staticRenderFns: staticRenderFns }
/* harmony default export */ __webpack_exports__["a"] = (esExports);
if (false) {
  module.hot.accept()
  if (module.hot.data) {
     require("vue-hot-reload-api").rerender("data-v-1532f6f5", esExports)
  }
}

/***/ })

},[182]);