require("../../common/manifest.js")
require("../../common/vendor.js")
global.webpackJsonpMpvue([12],{

/***/ 103:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_vue__ = __webpack_require__(0);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_vue___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_0_vue__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__index__ = __webpack_require__(104);



var app = new __WEBPACK_IMPORTED_MODULE_0_vue___default.a(__WEBPACK_IMPORTED_MODULE_1__index__["a" /* default */]);
app.$mount();

/***/ }),

/***/ 104:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__babel_loader_node_modules_mpvue_loader_lib_selector_type_script_index_0_index_vue__ = __webpack_require__(106);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__node_modules_mpvue_loader_lib_template_compiler_index_id_data_v_31e8b46d_hasScoped_true_transformToRequire_video_src_source_src_img_src_image_xlink_href_fileExt_template_wxml_script_js_style_wxss_platform_wx_node_modules_mpvue_loader_lib_selector_type_template_index_0_index_vue__ = __webpack_require__(107);
var disposed = false
function injectStyle (ssrContext) {
  if (disposed) return
  __webpack_require__(105)
}
var normalizeComponent = __webpack_require__(1)
/* script */

/* template */

/* styles */
var __vue_styles__ = injectStyle
/* scopeId */
var __vue_scopeId__ = "data-v-31e8b46d"
/* moduleIdentifier (server only) */
var __vue_module_identifier__ = null
var Component = normalizeComponent(
  __WEBPACK_IMPORTED_MODULE_0__babel_loader_node_modules_mpvue_loader_lib_selector_type_script_index_0_index_vue__["a" /* default */],
  __WEBPACK_IMPORTED_MODULE_1__node_modules_mpvue_loader_lib_template_compiler_index_id_data_v_31e8b46d_hasScoped_true_transformToRequire_video_src_source_src_img_src_image_xlink_href_fileExt_template_wxml_script_js_style_wxss_platform_wx_node_modules_mpvue_loader_lib_selector_type_template_index_0_index_vue__["a" /* default */],
  __vue_styles__,
  __vue_scopeId__,
  __vue_module_identifier__
)
Component.options.__file = "src\\pages\\detail\\index.vue"
if (Component.esModule && Object.keys(Component.esModule).some(function (key) {return key !== "default" && key.substr(0, 2) !== "__"})) {console.error("named exports are not supported in *.vue files.")}
if (Component.options.functional) {console.error("[vue-loader] index.vue: functional components are not supported with templates, they should use render functions.")}

/* hot reload */
if (false) {(function () {
  var hotAPI = require("vue-hot-reload-api")
  hotAPI.install(require("vue"), false)
  if (!hotAPI.compatible) return
  module.hot.accept()
  if (!module.hot.data) {
    hotAPI.createRecord("data-v-31e8b46d", Component.options)
  } else {
    hotAPI.reload("data-v-31e8b46d", Component.options)
  }
  module.hot.dispose(function (data) {
    disposed = true
  })
})()}

/* harmony default export */ __webpack_exports__["a"] = (Component.exports);


/***/ }),

/***/ 105:
/***/ (function(module, exports) {

// removed by extract-text-webpack-plugin

/***/ }),

/***/ 106:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
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
      userProfile: {},
      isInBlacklist: false
    };
  },

  // 退出聊天页面的时候所有状态清空
  onUnload: function onUnload() {
    this.userProfile = {};
  },
  onShow: function onShow() {
    this.getBlacklist();
    this.userProfile = this.$store.state.user.userProfile;
    var blacklist = this.$store.state.user.blacklist;
    if (blacklist.indexOf(this.userProfile.userID) > -1) {
      this.isInBlacklist = true;
    }
  },

  methods: {
    // 获取黑名单
    getBlacklist: function getBlacklist() {
      var _this = this;

      wx.$app.getBlacklist().then(function (res) {
        _this.$store.commit('setBlacklist', res.data);
      });
    },

    // 删除好友
    // deleteFriend () {
    //   console.log('delete')
    // },
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
      this.userProfile = this.$store.state.user.userProfile;
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
      this.userProfile = this.$store.state.user.userProfile;
    }
  }
});

/***/ }),

/***/ 107:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
var render = function () {var _vm=this;var _h=_vm.$createElement;var _c=_vm._self._c||_h;
  return _c('div', {
    staticClass: "bg"
  }, [_c('div', {
    staticClass: "card"
  }, [_c('i-row', {
    attrs: {
      "mpcomid": '2'
    }
  }, [_c('i-col', {
    attrs: {
      "span": "8",
      "mpcomid": '0'
    }
  }, [_c('div', {
    staticClass: "avatar"
  }, [_c('image', {
    staticStyle: {
      "width": "80px",
      "height": "80px",
      "border-radius": "8px"
    },
    attrs: {
      "src": "/static/images/header.png"
    }
  })])]), _vm._v(" "), _c('i-col', {
    attrs: {
      "span": "16",
      "mpcomid": '1'
    }
  }, [_c('div', {
    staticClass: "right"
  }, [_c('div', {
    staticClass: "username"
  }, [_vm._v(_vm._s(_vm.userProfile.nick || '未设置'))]), _vm._v(" "), _c('div', {
    staticClass: "account"
  }, [_vm._v("账号：" + _vm._s(_vm.userProfile.userID))])])])], 1)], 1), _vm._v(" "), _c('div', {
    staticClass: "card",
    staticStyle: {
      "margin-top": "20px"
    }
  }, [_c('div', {
    staticClass: "item"
  }, [_c('div', {
    staticClass: "key"
  }, [_vm._v("性别")]), _vm._v(" "), _c('div', {
    attrs: {
      "clasa": "value"
    }
  }, [_vm._v(_vm._s(_vm.userProfile.gender || '未设置'))])]), _vm._v(" "), _c('div', {
    staticClass: "item"
  }, [_c('div', {
    staticClass: "key"
  }, [_vm._v("生日")]), _vm._v(" "), _c('div', {
    staticClass: "value"
  }, [_vm._v(_vm._s(_vm.userProfile.birthday || '未设置'))])]), _vm._v(" "), _c('div', {
    staticClass: "item"
  }, [_c('div', {
    staticClass: "key"
  }, [_vm._v("地址")]), _vm._v(" "), _c('div', {
    staticClass: "value"
  }, [_vm._v(_vm._s(_vm.userProfile.location || '未设置'))])]), _vm._v(" "), _c('div', {
    staticClass: "item"
  }, [_c('div', {
    staticClass: "key"
  }, [_vm._v("签名")]), _vm._v(" "), _c('div', {
    staticClass: "value"
  }, [_vm._v(_vm._s(_vm.userProfile.selfSignature || '未设置'))])])]), _vm._v(" "), _c('div', {
    staticClass: "revise"
  }, [(!_vm.isInBlacklist) ? _c('button', {
    staticClass: "btn delete",
    attrs: {
      "eventid": '0'
    },
    on: {
      "click": _vm.addBlackList
    }
  }, [_vm._v("拉黑")]) : _vm._e(), _vm._v(" "), (_vm.isInBlacklist) ? _c('button', {
    staticClass: "btn",
    attrs: {
      "eventid": '1'
    },
    on: {
      "click": _vm.deleteBlackList
    }
  }, [_vm._v("取消拉黑")]) : _vm._e()], 1)])
}
var staticRenderFns = []
render._withStripped = true
var esExports = { render: render, staticRenderFns: staticRenderFns }
/* harmony default export */ __webpack_exports__["a"] = (esExports);
if (false) {
  module.hot.accept()
  if (module.hot.data) {
     require("vue-hot-reload-api").rerender("data-v-31e8b46d", esExports)
  }
}

/***/ })

},[103]);