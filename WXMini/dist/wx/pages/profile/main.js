require("../../common/manifest.js")
require("../../common/vendor.js")
global.webpackJsonpMpvue([3],{

/***/ 148:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_vue__ = __webpack_require__(0);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_vue___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_0_vue__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__index__ = __webpack_require__(149);



var app = new __WEBPACK_IMPORTED_MODULE_0_vue___default.a(__WEBPACK_IMPORTED_MODULE_1__index__["a" /* default */]);
app.$mount();

/***/ }),

/***/ 149:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__babel_loader_node_modules_mpvue_loader_lib_selector_type_script_index_0_index_vue__ = __webpack_require__(151);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__node_modules_mpvue_loader_lib_template_compiler_index_id_data_v_5170593a_hasScoped_false_transformToRequire_video_src_source_src_img_src_image_xlink_href_fileExt_template_wxml_script_js_style_wxss_platform_wx_node_modules_mpvue_loader_lib_selector_type_template_index_0_index_vue__ = __webpack_require__(152);
var disposed = false
function injectStyle (ssrContext) {
  if (disposed) return
  __webpack_require__(150)
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
  __WEBPACK_IMPORTED_MODULE_1__node_modules_mpvue_loader_lib_template_compiler_index_id_data_v_5170593a_hasScoped_false_transformToRequire_video_src_source_src_img_src_image_xlink_href_fileExt_template_wxml_script_js_style_wxss_platform_wx_node_modules_mpvue_loader_lib_selector_type_template_index_0_index_vue__["a" /* default */],
  __vue_styles__,
  __vue_scopeId__,
  __vue_module_identifier__
)
Component.options.__file = "src\\pages\\profile\\index.vue"
if (Component.esModule && Object.keys(Component.esModule).some(function (key) {return key !== "default" && key.substr(0, 2) !== "__"})) {console.error("named exports are not supported in *.vue files.")}
if (Component.options.functional) {console.error("[vue-loader] index.vue: functional components are not supported with templates, they should use render functions.")}

/* hot reload */
if (false) {(function () {
  var hotAPI = require("vue-hot-reload-api")
  hotAPI.install(require("vue"), false)
  if (!hotAPI.compatible) return
  module.hot.accept()
  if (!module.hot.data) {
    hotAPI.createRecord("data-v-5170593a", Component.options)
  } else {
    hotAPI.reload("data-v-5170593a", Component.options)
  }
  module.hot.dispose(function (data) {
    disposed = true
  })
})()}

/* harmony default export */ __webpack_exports__["a"] = (Component.exports);


/***/ }),

/***/ 150:
/***/ (function(module, exports) {

// removed by extract-text-webpack-plugin

/***/ }),

/***/ 151:
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

/* harmony default export */ __webpack_exports__["a"] = ({
  data: function data() {
    return {
      nick: '',
      myInfo: {},
      gender: false,
      imgArr: ['http://imgcache.qq.com/open/qcloud/video/act/webim-avatar/avatar-1.png', 'http://imgcache.qq.com/open/qcloud/video/act/webim-avatar/avatar-2.png', 'http://imgcache.qq.com/open/qcloud/video/act/webim-avatar/avatar-3.png', 'http://imgcache.qq.com/open/qcloud/video/act/webim-avatar/avatar-4.png', 'http://imgcache.qq.com/open/qcloud/video/act/webim-avatar/avatar-5.png'],
      avatar: ''
    };
  },
  onShow: function onShow() {
    this.myInfo = this.$store.state.user.myInfo;
  },

  methods: {
    onChange: function onChange(e) {
      this.avatar = e.target.value;
    },

    // 更新个人信息，目前只有昵称和头像
    revise: function revise() {
      var _this = this;

      if (this.nick || this.avatar) {
        wx.$app.updateMyProfile({
          nick: this.nick || this.myInfo.nick,
          avatar: this.avatar || this.myInfo.avatar
        }).then(function (res) {
          _this.$store.commit('updateMyInfo', res.data);
          _this.$store.commit('showToast', {
            title: '修改成功',
            icon: 'success',
            duration: 1500
          });
          _this.nick = '';
          _this.avatar = '';
          wx.switchTab({
            url: '../own/main'
          });
        }).catch(function () {
          _this.$store.commit('showToast', {
            title: '修改失败',
            icon: 'none',
            duration: 1500
          });
        });
      } else {
        this.$store.commit('showToast', { title: '你什么都还没填哦！' });
      }
    }
  }
});

/***/ }),

/***/ 152:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
var render = function () {var _vm=this;var _h=_vm.$createElement;var _c=_vm._self._c||_h;
  return _c('div', {
    staticClass: "profile"
  }, [_c('div', {
    staticClass: "title"
  }, [_vm._v("个人信息")]), _vm._v(" "), _c('div', {
    staticClass: "item"
  }, [_c('div', {
    staticClass: "label"
  }, [_vm._v("\n      昵称：\n    ")]), _vm._v(" "), _c('div', [_c('input', {
    directives: [{
      name: "model",
      rawName: "v-model.lazy:value",
      value: (_vm.nick),
      expression: "nick",
      modifiers: {
        "lazy:value": true
      }
    }],
    staticClass: "input",
    attrs: {
      "type": "text",
      "placeholder": "请输入新昵称",
      "eventid": '0'
    },
    domProps: {
      "value": (_vm.nick)
    },
    on: {
      "input": function($event) {
        if ($event.target.composing) { return; }
        _vm.nick = $event.target.value
      }
    }
  })])]), _vm._v(" "), _c('div', {
    staticClass: "title"
  }, [_vm._v("头像")]), _vm._v(" "), _c('div', {
    staticClass: "avatar"
  }, [_c('radio-group', {
    staticClass: "group",
    attrs: {
      "eventid": '1',
      "mpcomid": '0'
    },
    on: {
      "change": _vm.onChange
    }
  }, _vm._l((_vm.imgArr), function(item, index) {
    return _c('label', {
      key: index,
      staticClass: "label"
    }, [_c('image', {
      staticStyle: {
        "width": "40px",
        "height": "40px",
        "border-radius": "8px"
      },
      attrs: {
        "src": item
      }
    }), _vm._v(" "), _c('div', {
      staticClass: "radio-wrapper"
    }, [_c('input', {
      attrs: {
        "type": "radio",
        "name": "list",
        "value": item,
        "checked": _vm.avatar === item
      }
    })])])
  }))], 1), _vm._v(" "), _c('i-row', {
    attrs: {
      "mpcomid": '3'
    }
  }, [_c('i-col', {
    attrs: {
      "span": "12",
      "offset": "6",
      "mpcomid": '2'
    }
  }, [_c('div', {
    staticStyle: {
      "padding": "20px 0"
    }
  }, [_c('i-button', {
    attrs: {
      "type": "primary",
      "long": "true",
      "shape": "circle",
      "eventid": '2',
      "mpcomid": '1'
    },
    on: {
      "click": _vm.revise
    }
  }, [_vm._v("修改资料")])], 1)])], 1)], 1)
}
var staticRenderFns = []
render._withStripped = true
var esExports = { render: render, staticRenderFns: staticRenderFns }
/* harmony default export */ __webpack_exports__["a"] = (esExports);
if (false) {
  module.hot.accept()
  if (module.hot.data) {
     require("vue-hot-reload-api").rerender("data-v-5170593a", esExports)
  }
}

/***/ })

},[148]);