require("../../common/manifest.js")
require("../../common/vendor.js")
global.webpackJsonpMpvue([6],{

/***/ 128:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_vue__ = __webpack_require__(0);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_vue___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_0_vue__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__index__ = __webpack_require__(129);



var app = new __WEBPACK_IMPORTED_MODULE_0_vue___default.a(__WEBPACK_IMPORTED_MODULE_1__index__["a" /* default */]);
app.$mount();

/***/ }),

/***/ 129:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__babel_loader_node_modules_mpvue_loader_lib_selector_type_script_index_0_index_vue__ = __webpack_require__(131);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__node_modules_mpvue_loader_lib_template_compiler_index_id_data_v_1532f6f5_hasScoped_true_transformToRequire_video_src_source_src_img_src_image_xlink_href_fileExt_template_wxml_script_js_style_wxss_platform_wx_node_modules_mpvue_loader_lib_selector_type_template_index_0_index_vue__ = __webpack_require__(132);
var disposed = false
function injectStyle (ssrContext) {
  if (disposed) return
  __webpack_require__(130)
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

/***/ 130:
/***/ (function(module, exports) {

// removed by extract-text-webpack-plugin

/***/ }),

/***/ 131:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_babel_runtime_helpers_extends__ = __webpack_require__(3);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_babel_runtime_helpers_extends___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_0_babel_runtime_helpers_extends__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1_vuex__ = __webpack_require__(2);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2__static_utils_GenerateTestUserSig__ = __webpack_require__(37);

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
      var options = Object(__WEBPACK_IMPORTED_MODULE_2__static_utils_GenerateTestUserSig__["b" /* genTestUserSig */])(this.userID);
      options.runLoopNetType = 0;
      if (options) {
        wx.$app.login({
          userID: this.userID,
          userSig: options.userSig
        }).then(function () {
          wx.showLoading({
            title: '登录成功'
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

/***/ 132:
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

},[128]);