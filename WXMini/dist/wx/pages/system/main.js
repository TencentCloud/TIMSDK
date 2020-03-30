require("../../common/manifest.js")
require("../../common/vendor.js")
global.webpackJsonpMpvue([4],{

/***/ 207:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_vue__ = __webpack_require__(0);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_vue___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_0_vue__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__index__ = __webpack_require__(208);



var app = new __WEBPACK_IMPORTED_MODULE_0_vue___default.a(__WEBPACK_IMPORTED_MODULE_1__index__["a" /* default */]);
app.$mount();

/***/ }),

/***/ 208:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__babel_loader_node_modules_mpvue_loader_lib_selector_type_script_index_0_index_vue__ = __webpack_require__(210);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__node_modules_mpvue_loader_lib_template_compiler_index_id_data_v_5e5810f9_hasScoped_true_transformToRequire_video_src_source_src_img_src_image_xlink_href_fileExt_template_wxml_script_js_style_wxss_platform_wx_node_modules_mpvue_loader_lib_selector_type_template_index_0_index_vue__ = __webpack_require__(211);
var disposed = false
function injectStyle (ssrContext) {
  if (disposed) return
  __webpack_require__(209)
}
var normalizeComponent = __webpack_require__(1)
/* script */

/* template */

/* styles */
var __vue_styles__ = injectStyle
/* scopeId */
var __vue_scopeId__ = "data-v-5e5810f9"
/* moduleIdentifier (server only) */
var __vue_module_identifier__ = null
var Component = normalizeComponent(
  __WEBPACK_IMPORTED_MODULE_0__babel_loader_node_modules_mpvue_loader_lib_selector_type_script_index_0_index_vue__["a" /* default */],
  __WEBPACK_IMPORTED_MODULE_1__node_modules_mpvue_loader_lib_template_compiler_index_id_data_v_5e5810f9_hasScoped_true_transformToRequire_video_src_source_src_img_src_image_xlink_href_fileExt_template_wxml_script_js_style_wxss_platform_wx_node_modules_mpvue_loader_lib_selector_type_template_index_0_index_vue__["a" /* default */],
  __vue_styles__,
  __vue_scopeId__,
  __vue_module_identifier__
)
Component.options.__file = "src\\pages\\system\\index.vue"
if (Component.esModule && Object.keys(Component.esModule).some(function (key) {return key !== "default" && key.substr(0, 2) !== "__"})) {console.error("named exports are not supported in *.vue files.")}
if (Component.options.functional) {console.error("[vue-loader] index.vue: functional components are not supported with templates, they should use render functions.")}

/* hot reload */
if (false) {(function () {
  var hotAPI = require("vue-hot-reload-api")
  hotAPI.install(require("vue"), false)
  if (!hotAPI.compatible) return
  module.hot.accept()
  if (!module.hot.data) {
    hotAPI.createRecord("data-v-5e5810f9", Component.options)
  } else {
    hotAPI.reload("data-v-5e5810f9", Component.options)
  }
  module.hot.dispose(function (data) {
    disposed = true
  })
})()}

/* harmony default export */ __webpack_exports__["a"] = (Component.exports);


/***/ }),

/***/ 209:
/***/ (function(module, exports) {

// removed by extract-text-webpack-plugin

/***/ }),

/***/ 210:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_babel_runtime_helpers_toConsumableArray__ = __webpack_require__(31);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_babel_runtime_helpers_toConsumableArray___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_0_babel_runtime_helpers_toConsumableArray__);
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


/* harmony default export */ __webpack_exports__["a"] = ({
  onUnload: function onUnload() {
    this.$store.commit('resetCurrentConversation');
    this.$store.commit('resetGroup');
  },

  computed: __WEBPACK_IMPORTED_MODULE_1_babel_runtime_helpers_extends___default()({}, Object(__WEBPACK_IMPORTED_MODULE_2_vuex__["c" /* mapState */])({
    currentMessageList: function currentMessageList(state) {
      return [].concat(__WEBPACK_IMPORTED_MODULE_0_babel_runtime_helpers_toConsumableArray___default()(state.conversation.currentMessageList)).reverse();
    }
  })),
  onShow: function onShow() {
    var _this = this;

    var interval = setInterval(function () {
      if (_this.currentMessageList.length !== 0) {
        wx.pageScrollTo({
          scrollTop: 99999
        });
        clearInterval(interval);
      }
    }, 600);
  },

  methods: {
    handleClick: function handleClick(message) {
      var _this2 = this;

      wx.showActionSheet({
        itemList: ['同意', '拒绝'],
        success: function success(res) {
          var option = {
            handleAction: 'Agree',
            handleMessage: '欢迎进群',
            message: message
          };
          if (res.tapIndex === 1) {
            option.handleAction = 'Reject';
            option.handleMessage = '拒绝申请';
          }
          wx.$app.handleGroupApplication(option).then(function () {
            wx.showToast({ title: option.handleAction === 'Agree' ? '已同意申请' : '已拒绝申请' });
            _this2.$store.commit('removeMessage', message);
          }).catch(function (error) {
            wx.showToast({
              title: error.message || '处理失败',
              icon: 'none'
            });
          });
        }
      });
    }
  }
});

/***/ }),

/***/ 211:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
var render = function () {var _vm=this;var _h=_vm.$createElement;var _c=_vm._self._c||_h;
  return _c('div', {
    staticClass: "container"
  }, [(_vm.currentMessageList.length === 0) ? _c('div', [_c('div', {
    staticClass: "card"
  }, [_vm._v("\n      暂无系统消息\n    ")])]) : _vm._e(), _vm._v(" "), _vm._l((_vm.currentMessageList), function(message, index) {
    return _c('div', {
      key: message.ID
    }, [(message.payload.operationType === 1) ? _c('div', {
      staticClass: "card handle"
    }, [_c('div', [_c('div', {
      staticClass: "time"
    }, [_vm._v(_vm._s(message.newtime))]), _vm._v("\n        " + _vm._s(message.virtualDom[0].text) + "\n      ")]), _vm._v(" "), _c('div', {
      staticClass: "choose"
    }, [_c('button', {
      staticClass: "button",
      attrs: {
        "type": "button",
        "eventid": '0_' + index
      },
      on: {
        "click": function($event) {
          _vm.handleClick(message)
        }
      }
    }, [_vm._v("处理")])], 1)]) : _c('div', {
      staticClass: "card"
    }, [_c('div', {
      staticClass: "time"
    }, [_vm._v(_vm._s(message.newtime))]), _vm._v("\n      " + _vm._s(message.virtualDom[0].text) + "\n    ")])])
  })], 2)
}
var staticRenderFns = []
render._withStripped = true
var esExports = { render: render, staticRenderFns: staticRenderFns }
/* harmony default export */ __webpack_exports__["a"] = (esExports);
if (false) {
  module.hot.accept()
  if (module.hot.data) {
     require("vue-hot-reload-api").rerender("data-v-5e5810f9", esExports)
  }
}

/***/ })

},[207]);