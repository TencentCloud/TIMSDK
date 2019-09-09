require("../../common/manifest.js")
require("../../common/vendor.js")
global.webpackJsonpMpvue([2],{

/***/ "7uhd":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_md5__ = __webpack_require__("L6bb");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_md5___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_0_md5__);
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
      userID: '',
      password: ''
    };
  },

  methods: {
    // 点击登录进行初始化
    handleRegister: function handleRegister() {
      var that = this;
      if (/^[a-zA-Z][a-zA-Z0-9_]{3,23}$/g.test(this.userID) && this.password.length >= 6) {
        wx.request({
          url: 'https://im-demo.qcloud.com/register',
          method: 'post',
          data: {
            userid: that.userID,
            password: __WEBPACK_IMPORTED_MODULE_0_md5___default()(that.password)
          },
          success: function success(res) {
            var code = res.data.code;

            var message = '';
            if (code === 200) {
              that.$store.commit('showToast', {
                title: '注册成功'
              });
              var url = '../login/main';
              wx.navigateTo({ url: url });
              that.userID = '';
              that.password = '';
            } else {
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
                  break;
              }
              that.$store.commit('showToast', {
                title: message
              });
            }
          },
          fail: function fail() {
            that.$store.commit('showToast', {
              title: '出错了！请再试试'
            });
          }
        });
      } else {
        that.$store.commit('showToast', {
          title: '请按照格式设置哦！'
        });
      }
    }
  }
});

/***/ }),

/***/ "CGnD":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
var render = function () {var _vm=this;var _h=_vm.$createElement;var _c=_vm._self._c||_h;
  return _c('div', {
    staticClass: "counter-warp"
  }, [_c('div', {
    staticClass: "login"
  }, [_c('div', {
    staticClass: "register",
    staticStyle: {
      "margin-bottom": "20px"
    }
  }, [_vm._v("\n      注册\n    ")]), _vm._v(" "), _c('div', {
    staticClass: "item"
  }, [_c('div', {
    staticClass: "label"
  }, [_vm._v("\n        用户名：\n      ")]), _vm._v(" "), _c('div', [_c('input', {
    directives: [{
      name: "model",
      rawName: "v-model.lazy:value",
      value: (_vm.userID),
      expression: "userID",
      modifiers: {
        "lazy:value": true
      }
    }],
    staticClass: "input",
    attrs: {
      "type": "text",
      "placeholder": "请输入用户名",
      "eventid": '0'
    },
    domProps: {
      "value": (_vm.userID)
    },
    on: {
      "input": function($event) {
        if ($event.target.composing) { return; }
        _vm.userID = $event.target.value
      }
    }
  })])]), _vm._v(" "), _c('div', {
    staticClass: "tip"
  }, [_vm._v("由英文开始，可使用a~z,A~Z,0~9，长度4~24位")]), _vm._v(" "), _c('div', {
    staticClass: "item"
  }, [_c('div', {
    staticClass: "label"
  }, [_vm._v("\n        密码：\n      ")]), _vm._v(" "), _c('div', [_c('input', {
    directives: [{
      name: "model",
      rawName: "v-model.lazy:value",
      value: (_vm.password),
      expression: "password",
      modifiers: {
        "lazy:value": true
      }
    }],
    staticClass: "input",
    attrs: {
      "type": "password",
      "minlength": "6",
      "placeholder": "请输入密码",
      "eventid": '1'
    },
    domProps: {
      "value": (_vm.password)
    },
    on: {
      "input": function($event) {
        if ($event.target.composing) { return; }
        _vm.password = $event.target.value
      }
    }
  })])]), _vm._v(" "), _c('div', {
    staticClass: "tip"
  }, [_vm._v("最少6位")])]), _vm._v(" "), _c('div', {
    staticClass: "login-button"
  }, [_c('i-button', {
    attrs: {
      "type": "primary",
      "shape": "circle",
      "eventid": '2',
      "mpcomid": '0'
    },
    on: {
      "click": _vm.handleRegister
    }
  }, [_vm._v("注册")])], 1)])
}
var staticRenderFns = []
var esExports = { render: render, staticRenderFns: staticRenderFns }
/* harmony default export */ __webpack_exports__["a"] = (esExports);

/***/ }),

/***/ "P1qQ":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_vue__ = __webpack_require__("5nAL");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_vue___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_0_vue__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__index__ = __webpack_require__("TTwy");



var app = new __WEBPACK_IMPORTED_MODULE_0_vue___default.a(__WEBPACK_IMPORTED_MODULE_1__index__["a" /* default */]);
app.$mount();

/***/ }),

/***/ "TTwy":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__babel_loader_node_modules_mpvue_loader_lib_selector_type_script_index_0_index_vue__ = __webpack_require__("7uhd");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__node_modules_mpvue_loader_lib_template_compiler_index_id_data_v_0cbdecad_hasScoped_true_transformToRequire_video_src_source_src_img_src_image_xlink_href_fileExt_template_wxml_script_js_style_wxss_platform_wx_node_modules_mpvue_loader_lib_selector_type_template_index_0_index_vue__ = __webpack_require__("CGnD");
function injectStyle (ssrContext) {
  __webpack_require__("kf5B")
}
var normalizeComponent = __webpack_require__("ybqe")
/* script */

/* template */

/* styles */
var __vue_styles__ = injectStyle
/* scopeId */
var __vue_scopeId__ = "data-v-0cbdecad"
/* moduleIdentifier (server only) */
var __vue_module_identifier__ = null
var Component = normalizeComponent(
  __WEBPACK_IMPORTED_MODULE_0__babel_loader_node_modules_mpvue_loader_lib_selector_type_script_index_0_index_vue__["a" /* default */],
  __WEBPACK_IMPORTED_MODULE_1__node_modules_mpvue_loader_lib_template_compiler_index_id_data_v_0cbdecad_hasScoped_true_transformToRequire_video_src_source_src_img_src_image_xlink_href_fileExt_template_wxml_script_js_style_wxss_platform_wx_node_modules_mpvue_loader_lib_selector_type_template_index_0_index_vue__["a" /* default */],
  __vue_styles__,
  __vue_scopeId__,
  __vue_module_identifier__
)

/* harmony default export */ __webpack_exports__["a"] = (Component.exports);


/***/ }),

/***/ "kf5B":
/***/ (function(module, exports) {

// removed by extract-text-webpack-plugin

/***/ })

},["P1qQ"]);