require("../../common/manifest.js")
require("../../common/vendor.js")
global.webpackJsonpMpvue([6],{

/***/ 204:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_vue__ = __webpack_require__(0);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_vue___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_0_vue__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__index__ = __webpack_require__(205);



var app = new __WEBPACK_IMPORTED_MODULE_0_vue___default.a(__WEBPACK_IMPORTED_MODULE_1__index__["a" /* default */]);
app.$mount();

/***/ }),

/***/ 205:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__babel_loader_node_modules_mpvue_loader_lib_selector_type_script_index_0_index_vue__ = __webpack_require__(207);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__node_modules_mpvue_loader_lib_template_compiler_index_id_data_v_0cbdecad_hasScoped_false_transformToRequire_video_src_source_src_img_src_image_xlink_href_fileExt_template_wxml_script_js_style_wxss_platform_wx_node_modules_mpvue_loader_lib_selector_type_template_index_0_index_vue__ = __webpack_require__(208);
var disposed = false
function injectStyle (ssrContext) {
  if (disposed) return
  __webpack_require__(206)
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
  __WEBPACK_IMPORTED_MODULE_1__node_modules_mpvue_loader_lib_template_compiler_index_id_data_v_0cbdecad_hasScoped_false_transformToRequire_video_src_source_src_img_src_image_xlink_href_fileExt_template_wxml_script_js_style_wxss_platform_wx_node_modules_mpvue_loader_lib_selector_type_template_index_0_index_vue__["a" /* default */],
  __vue_styles__,
  __vue_scopeId__,
  __vue_module_identifier__
)
Component.options.__file = "src\\pages\\register\\index.vue"
if (Component.esModule && Object.keys(Component.esModule).some(function (key) {return key !== "default" && key.substr(0, 2) !== "__"})) {console.error("named exports are not supported in *.vue files.")}
if (Component.options.functional) {console.error("[vue-loader] index.vue: functional components are not supported with templates, they should use render functions.")}

/* hot reload */
if (false) {(function () {
  var hotAPI = require("vue-hot-reload-api")
  hotAPI.install(require("vue"), false)
  if (!hotAPI.compatible) return
  module.hot.accept()
  if (!module.hot.data) {
    hotAPI.createRecord("data-v-0cbdecad", Component.options)
  } else {
    hotAPI.reload("data-v-0cbdecad", Component.options)
  }
  module.hot.dispose(function (data) {
    disposed = true
  })
})()}

/* harmony default export */ __webpack_exports__["a"] = (Component.exports);


/***/ }),

/***/ 206:
/***/ (function(module, exports) {

// removed by extract-text-webpack-plugin

/***/ }),

/***/ 207:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_babel_runtime_core_js_promise__ = __webpack_require__(26);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_babel_runtime_core_js_promise___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_0_babel_runtime_core_js_promise__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1_babel_runtime_core_js_object_assign__ = __webpack_require__(54);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1_babel_runtime_core_js_object_assign___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_1_babel_runtime_core_js_object_assign__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2_babel_runtime_helpers_extends__ = __webpack_require__(2);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2_babel_runtime_helpers_extends___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_2_babel_runtime_helpers_extends__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3_md5__ = __webpack_require__(77);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3_md5___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_3_md5__);



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



var defaultData = {
  userID: '',
  password: '',
  userIDInputFocus: false,
  passwordInputFocus: false,
  loading: false
};
/* harmony default export */ __webpack_exports__["a"] = ({
  data: function data() {
    return __WEBPACK_IMPORTED_MODULE_2_babel_runtime_helpers_extends___default()({}, defaultData);
  },
  onUnload: function onUnload() {
    __WEBPACK_IMPORTED_MODULE_1_babel_runtime_core_js_object_assign___default()(this, defaultData);
  },

  computed: {
    disabled: function disabled() {
      if (/^[a-zA-Z][a-zA-Z0-9_]{3,23}$/g.test(this.userID) && this.password.length >= 6) {
        return false;
      }
      return true;
    }
  },
  methods: {
    handleRegister: function handleRegister() {
      var _this = this;

      this.loading = true;
      this.register().then(function (res) {
        var code = res.data.code;

        _this.loading = false;
        if (code === 200) {
          _this.$bus.$emit('registSuccess', { userID: _this.userID, password: _this.password });
          wx.showToast({ title: '注册成功', duration: 1000 });
          setTimeout(function () {
            wx.navigateBack();
          }, 1000);
        } else {
          _this.handleRegisterFail({ code: code });
        }
      }).catch(function (error) {
        _this.handleRegisterFail({ error: error });
      });
    },
    register: function register() {
      var _this2 = this;

      return new __WEBPACK_IMPORTED_MODULE_0_babel_runtime_core_js_promise___default.a(function (resolve, reject) {
        wx.request({
          url: 'https://im-demo.qcloud.com/register',
          method: 'post',
          data: {
            userid: _this2.userID,
            password: __WEBPACK_IMPORTED_MODULE_3_md5___default()(_this2.password)
          },
          success: resolve,
          failure: reject
        });
      });
    },
    handleRegisterFail: function handleRegisterFail(_ref) {
      var code = _ref.code,
          error = _ref.error;

      this.loading = false;
      var message = '';
      switch (code) {
        case 601:
          message = '用户名格式错误';
          break;
        case 602:
          message = '用户名或密码不合法';
          break;
        case 612:
          message = '用户已存在';
          break;
        case 500:
          message = '服务器错误';
          break;
        case 620:
          message = '密码错误';
          break;
        default:
          message = error ? error.message : '用户名或者密码不合法';
          break;
      }
      wx.showToast({ title: message, icon: 'none', duration: 1000 });
    }
  }
});

/***/ }),

/***/ 208:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
var render = function () {var _vm=this;var _h=_vm.$createElement;var _c=_vm._self._c||_h;
  return _c('div', {
    staticClass: "counter-warp"
  }, [_vm._m(0), _vm._v(" "), _c('div', {
    staticClass: "form"
  }, [_c('input', {
    directives: [{
      name: "model",
      rawName: "v-model",
      value: (_vm.userID),
      expression: "userID"
    }],
    class: {
      'input-focus': _vm.userIDInputFocus
    },
    attrs: {
      "placeholder": "userID",
      "eventid": '0'
    },
    domProps: {
      "value": (_vm.userID)
    },
    on: {
      "blur": function($event) {
        _vm.userIDInputFocus = false
      },
      "focus": function($event) {
        _vm.userIDInputFocus = true
      },
      "input": function($event) {
        if ($event.target.composing) { return; }
        _vm.userID = $event.target.value
      }
    }
  }), _vm._v(" "), _c('div', {
    staticClass: "tip"
  }, [_vm._v("以字母开头，可使用大小写字母及数字，长度4~24位")]), _vm._v(" "), _c('input', {
    directives: [{
      name: "model",
      rawName: "v-model",
      value: (_vm.password),
      expression: "password"
    }],
    class: {
      'input-focus': _vm.passwordInputFocus
    },
    attrs: {
      "placeholder": "密码",
      "type": "password",
      "eventid": '1'
    },
    domProps: {
      "value": (_vm.password)
    },
    on: {
      "blur": function($event) {
        _vm.passwordInputFocus = false
      },
      "focus": function($event) {
        _vm.passwordInputFocus = true
      },
      "input": function($event) {
        if ($event.target.composing) { return; }
        _vm.password = $event.target.value
      }
    }
  }), _vm._v(" "), _c('div', {
    staticClass: "tip"
  }, [_vm._v("最少6位")])]), _vm._v(" "), _c('button', {
    staticClass: "login-button",
    class: {
      'button-disabled': _vm.disabled
    },
    attrs: {
      "hover-class": "clicked",
      "loading": _vm.loading,
      "disabled": _vm.disabled,
      "eventid": '2'
    },
    on: {
      "click": _vm.handleRegister
    }
  }, [_vm._v("注册")])], 1)
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
  }, [_vm._v("注册 · 即时通信")]), _vm._v(" "), _c('div', {
    staticClass: "text-content"
  }, [_vm._v("体验群组聊天，视频对话等IM功能")])])])])
}]
render._withStripped = true
var esExports = { render: render, staticRenderFns: staticRenderFns }
/* harmony default export */ __webpack_exports__["a"] = (esExports);
if (false) {
  module.hot.accept()
  if (module.hot.data) {
     require("vue-hot-reload-api").rerender("data-v-0cbdecad", esExports)
  }
}

/***/ })

},[204]);