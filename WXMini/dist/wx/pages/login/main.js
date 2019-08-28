require("../../common/manifest.js")
require("../../debug/GenerateTestUserSig.js")
require("../../common/vendor.js")
global.webpackJsonpMpvue([7],{

/***/ "GG4c":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_babel_runtime_helpers_extends__ = __webpack_require__("Dd8w");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_babel_runtime_helpers_extends___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_0_babel_runtime_helpers_extends__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1_vuex__ = __webpack_require__("NYxO");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2__static_debug_GenerateTestUserSig__ = __webpack_require__("fUtS");

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
      userID: 'user0',
      password: '',
      selected: false
    };
  },

  computed: __WEBPACK_IMPORTED_MODULE_0_babel_runtime_helpers_extends___default()({}, Object(__WEBPACK_IMPORTED_MODULE_1_vuex__["b" /* mapState */])({
    isSdkReady: function isSdkReady(state) {
      return state.global.isSdkReady;
    }
  })),
  methods: {
    // 点击登录进行初始化
    handleLogin: function handleLogin() {
      var options = Object(__WEBPACK_IMPORTED_MODULE_2__static_debug_GenerateTestUserSig__["b" /* genTestUserSig */])(this.userID);
      options.runLoopNetType = 0;
      if (options) {
        wx.$app.login({
          userID: this.userID,
          userSig: options.userSig
        }).then(function () {
          wx.showLoading({
            title: '登录成功'
          });
          wx.$app.ready(function () {
            wx.hideLoading();
            wx.switchTab({
              url: '../index/main'
            });
          });
        });
      }
    },
    choose: function choose() {
      this.selected = !this.selected;
    },
    select: function select(e) {
      this.userID = e.target.id;
      this.choose();
    }
  }
});

/***/ }),

/***/ "IOAW":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
var render = function () {var _vm=this;var _h=_vm.$createElement;var _c=_vm._self._c||_h;
  return _c('div', {
    staticClass: "counter-warp"
  }, [_c('div', {
    staticStyle: {
      "margin-bottom": "20px"
    }
  }, [_c('i-avatar', {
    attrs: {
      "src": "../../../static/images/launch.png",
      "size": "large",
      "shape": "square",
      "mpcomid": '0'
    }
  })], 1), _vm._v(" "), _c('div', {
    staticClass: "login"
  }, [_c('div', {
    staticClass: "select-wrapper",
    attrs: {
      "eventid": '0'
    },
    on: {
      "click": _vm.choose
    }
  }, [_c('div', {
    staticClass: "show"
  }, [_vm._v(_vm._s(_vm.userID))]), _vm._v(" "), _vm._m(0)]), _vm._v(" "), (_vm.selected) ? _c('div', {
    staticClass: "select-list",
    attrs: {
      "eventid": '1'
    },
    on: {
      "click": _vm.select
    }
  }, [_c('div', {
    staticClass: "select",
    attrs: {
      "id": "user0"
    }
  }, [_vm._v("user0")]), _vm._v(" "), _c('div', {
    staticClass: "select",
    attrs: {
      "id": "user1"
    }
  }, [_vm._v("user1")]), _vm._v(" "), _c('div', {
    staticClass: "select",
    attrs: {
      "id": "user2"
    }
  }, [_vm._v("user2")]), _vm._v(" "), _c('div', {
    staticClass: "select",
    attrs: {
      "id": "user3"
    }
  }, [_vm._v("user3")]), _vm._v(" "), _c('div', {
    staticClass: "select",
    attrs: {
      "id": "user4"
    }
  }, [_vm._v("user4")]), _vm._v(" "), _c('div', {
    staticClass: "select",
    attrs: {
      "id": "user5"
    }
  }, [_vm._v("user5")]), _vm._v(" "), _c('div', {
    staticClass: "select",
    attrs: {
      "id": "user6"
    }
  }, [_vm._v("user6")]), _vm._v(" "), _c('div', {
    staticClass: "select",
    attrs: {
      "id": "user7"
    }
  }, [_vm._v("user7")]), _vm._v(" "), _c('div', {
    staticClass: "select",
    attrs: {
      "id": "user8"
    }
  }, [_vm._v("user8")]), _vm._v(" "), _c('div', {
    staticClass: "select",
    attrs: {
      "id": "user9"
    }
  }, [_vm._v("user9")]), _vm._v(" "), _c('div', {
    staticClass: "select",
    attrs: {
      "id": "user10"
    }
  }, [_vm._v("user10")]), _vm._v(" "), _c('div', {
    staticClass: "select",
    attrs: {
      "id": "user11"
    }
  }, [_vm._v("user11")]), _vm._v(" "), _c('div', {
    staticClass: "select",
    attrs: {
      "id": "user12"
    }
  }, [_vm._v("user12")]), _vm._v(" "), _c('div', {
    staticClass: "select",
    attrs: {
      "id": "user13"
    }
  }, [_vm._v("user13")]), _vm._v(" "), _c('div', {
    staticClass: "select",
    attrs: {
      "id": "user14"
    }
  }, [_vm._v("user14")]), _vm._v(" "), _c('div', {
    staticClass: "select",
    attrs: {
      "id": "user15"
    }
  }, [_vm._v("user15")]), _vm._v(" "), _c('div', {
    staticClass: "select",
    attrs: {
      "id": "user16"
    }
  }, [_vm._v("user16")]), _vm._v(" "), _c('div', {
    staticClass: "select",
    attrs: {
      "id": "user17"
    }
  }, [_vm._v("user17")]), _vm._v(" "), _c('div', {
    staticClass: "select",
    attrs: {
      "id": "user18"
    }
  }, [_vm._v("user18")]), _vm._v(" "), _c('div', {
    staticClass: "select",
    attrs: {
      "id": "user19"
    }
  }, [_vm._v("user19")]), _vm._v(" "), _c('div', {
    staticClass: "select",
    attrs: {
      "id": "user20"
    }
  }, [_vm._v("user20")])]) : _vm._e()]), _vm._v(" "), _c('div', {
    staticClass: "login-button"
  }, [_c('i-button', {
    attrs: {
      "type": "primary",
      "shape": "circle",
      "eventid": '2',
      "mpcomid": '1'
    },
    on: {
      "click": _vm.handleLogin
    }
  }, [_vm._v("登录")])], 1)])
}
var staticRenderFns = [function () {var _vm=this;var _h=_vm.$createElement;var _c=_vm._self._c||_h;
  return _c('div', {
    staticClass: "down"
  }, [_c('div', {
    staticClass: "inside"
  })])
}]
var esExports = { render: render, staticRenderFns: staticRenderFns }
/* harmony default export */ __webpack_exports__["a"] = (esExports);

/***/ }),

/***/ "jT7l":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__babel_loader_node_modules_mpvue_loader_lib_selector_type_script_index_0_index_vue__ = __webpack_require__("GG4c");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__node_modules_mpvue_loader_lib_template_compiler_index_id_data_v_1532f6f5_hasScoped_true_transformToRequire_video_src_source_src_img_src_image_xlink_href_fileExt_template_wxml_script_js_style_wxss_platform_wx_node_modules_mpvue_loader_lib_selector_type_template_index_0_index_vue__ = __webpack_require__("IOAW");
function injectStyle (ssrContext) {
  __webpack_require__("sxIp")
}
var normalizeComponent = __webpack_require__("ybqe")
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

/* harmony default export */ __webpack_exports__["a"] = (Component.exports);


/***/ }),

/***/ "sxIp":
/***/ (function(module, exports) {

// removed by extract-text-webpack-plugin

/***/ }),

/***/ "uvAE":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_vue__ = __webpack_require__("5nAL");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_vue___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_0_vue__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__index__ = __webpack_require__("jT7l");



var app = new __WEBPACK_IMPORTED_MODULE_0_vue___default.a(__WEBPACK_IMPORTED_MODULE_1__index__["a" /* default */]);
app.$mount();

/***/ })

},["uvAE"]);