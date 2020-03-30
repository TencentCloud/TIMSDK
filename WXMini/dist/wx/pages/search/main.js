require("../../common/manifest.js")
require("../../common/vendor.js")
global.webpackJsonpMpvue([5],{

/***/ 202:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_vue__ = __webpack_require__(0);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_vue___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_0_vue__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__index__ = __webpack_require__(203);



var app = new __WEBPACK_IMPORTED_MODULE_0_vue___default.a(__WEBPACK_IMPORTED_MODULE_1__index__["a" /* default */]);
app.$mount();

/***/ }),

/***/ 203:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__babel_loader_node_modules_mpvue_loader_lib_selector_type_script_index_0_index_vue__ = __webpack_require__(205);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__node_modules_mpvue_loader_lib_template_compiler_index_id_data_v_ba8a7d9c_hasScoped_true_transformToRequire_video_src_source_src_img_src_image_xlink_href_fileExt_template_wxml_script_js_style_wxss_platform_wx_node_modules_mpvue_loader_lib_selector_type_template_index_0_index_vue__ = __webpack_require__(206);
var disposed = false
function injectStyle (ssrContext) {
  if (disposed) return
  __webpack_require__(204)
}
var normalizeComponent = __webpack_require__(1)
/* script */

/* template */

/* styles */
var __vue_styles__ = injectStyle
/* scopeId */
var __vue_scopeId__ = "data-v-ba8a7d9c"
/* moduleIdentifier (server only) */
var __vue_module_identifier__ = null
var Component = normalizeComponent(
  __WEBPACK_IMPORTED_MODULE_0__babel_loader_node_modules_mpvue_loader_lib_selector_type_script_index_0_index_vue__["a" /* default */],
  __WEBPACK_IMPORTED_MODULE_1__node_modules_mpvue_loader_lib_template_compiler_index_id_data_v_ba8a7d9c_hasScoped_true_transformToRequire_video_src_source_src_img_src_image_xlink_href_fileExt_template_wxml_script_js_style_wxss_platform_wx_node_modules_mpvue_loader_lib_selector_type_template_index_0_index_vue__["a" /* default */],
  __vue_styles__,
  __vue_scopeId__,
  __vue_module_identifier__
)
Component.options.__file = "src\\pages\\search\\index.vue"
if (Component.esModule && Object.keys(Component.esModule).some(function (key) {return key !== "default" && key.substr(0, 2) !== "__"})) {console.error("named exports are not supported in *.vue files.")}
if (Component.options.functional) {console.error("[vue-loader] index.vue: functional components are not supported with templates, they should use render functions.")}

/* hot reload */
if (false) {(function () {
  var hotAPI = require("vue-hot-reload-api")
  hotAPI.install(require("vue"), false)
  if (!hotAPI.compatible) return
  module.hot.accept()
  if (!module.hot.data) {
    hotAPI.createRecord("data-v-ba8a7d9c", Component.options)
  } else {
    hotAPI.reload("data-v-ba8a7d9c", Component.options)
  }
  module.hot.dispose(function (data) {
    disposed = true
  })
})()}

/* harmony default export */ __webpack_exports__["a"] = (Component.exports);


/***/ }),

/***/ 204:
/***/ (function(module, exports) {

// removed by extract-text-webpack-plugin

/***/ }),

/***/ 205:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_babel_runtime_helpers_extends__ = __webpack_require__(4);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_babel_runtime_helpers_extends___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_0_babel_runtime_helpers_extends__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1_vuex__ = __webpack_require__(2);

//
//
//
//
//
//
//
//
//
//


// 该页面用于：
// 1. 搜索用户>发起会话
// 2. 搜索群组>申请加群
/* harmony default export */ __webpack_exports__["a"] = ({
  data: function data() {
    return {
      type: '', // user / group
      ID: '',
      searchedID: '',
      searched: false,
      loading: false,
      buttonText: ''
    };
  },
  onLoad: function onLoad(_ref) {
    var type = _ref.type;

    this.type = type;
    if (type === 'user') {
      this.buttonText = '发起会话';
      wx.setNavigationBarTitle({ title: '发起会话' });
    } else {
      this.buttonText = '申请加群';
      wx.setNavigationBarTitle({ title: '加入群聊' });
    }
  },
  onUnload: function onUnload() {
    this.ID = '';
    this.searched = false;
    this.loading = false;
    this.type = '';
  },

  computed: __WEBPACK_IMPORTED_MODULE_0_babel_runtime_helpers_extends___default()({}, Object(__WEBPACK_IMPORTED_MODULE_1_vuex__["c" /* mapState */])({
    groupList: function groupList(state) {
      return state.group.groupList;
    }
  }), {
    placeholder: function placeholder() {
      if (this.type === 'user') {
        return '请输入userID';
      } else {
        return '请输入groupID';
      }
    }
  }),
  methods: {
    handleInput: function handleInput() {
      if (this.searchedID === '' || this.ID !== this.searchedID) {
        this.searched = false;
      }
    },
    search: function search() {
      if (this.ID === '') {
        return;
      }
      wx.showLoading({ title: '正在搜索' });
      if (this.type === 'user') {
        this.searchUser();
      } else {
        this.searchGroup();
      }
    },
    searchUser: function searchUser() {
      var _this = this;

      wx.$app.getUserProfile({ userIDList: [this.ID] }).then(function (_ref2) {
        var data = _ref2.data;

        wx.hideLoading();
        if (data.length === 0) {
          wx.showToast({ title: '未找到该用户', duration: 1000, icon: 'none' });
          return;
        }
        _this.searched = true;
        _this.searchedID = _this.ID;
      }).catch(function (error) {
        wx.hideLoading();
        wx.showToast({ title: error.message, duration: 1000, icon: 'none' });
      });
    },
    searchGroup: function searchGroup() {
      var _this2 = this;

      wx.$app.searchGroupByID(this.ID).then(function (_ref3) {
        var data = _ref3.data;

        wx.hideLoading();
        var isJoined = _this2.groupList.findIndex(function (group) {
          return group.groupID === _this2.ID;
        }) >= 0;
        if (isJoined || data.group.type === 'AVChatRoom') {
          _this2.buttonText = '进入群聊';
        } else {
          _this2.buttonText = '申请加群';
        }
        _this2.searched = true;
        _this2.searchedID = _this2.ID;
      }).catch(function (error) {
        wx.hideLoading();
        if (error.code === 10007) {
          wx.showToast({ title: '讨论组类型群组不允许申请加群', duration: 1000, icon: 'none' });
        } else {
          wx.showToast({ title: '未找到该群组', duration: 1000, icon: 'none' });
        }
      });
    },
    handleClick: function handleClick() {
      if (this.type === 'user') {
        this.createConversation();
      } else {
        this.joinGroup();
      }
    },

    // 发起会话
    createConversation: function createConversation() {
      var _this3 = this;

      this.loading = true;
      this.$store.dispatch('checkoutConversation', 'C2C' + this.ID).then(function () {
        _this3.loading = false;
      }).catch(function () {
        _this3.loading = false;
      });
    },

    // 申请加群
    joinGroup: function joinGroup() {
      var _this4 = this;

      this.loading = true;
      wx.$app.joinGroup({ groupID: this.ID, applyMessage: '我想申请加入贵群，望批准！' }).then(function () {
        _this4.loading = false;
        _this4.$store.dispatch('checkoutConversation', 'GROUP' + _this4.ID);
      }).catch(function () {
        _this4.loading = false;
      });
    }
  }
});

/***/ }),

/***/ 206:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
var render = function () {var _vm=this;var _h=_vm.$createElement;var _c=_vm._self._c||_h;
  return _c('div', {
    staticClass: "container"
  }, [_c('div', {
    staticClass: "search-bar"
  }, [_c('img', {
    attrs: {
      "src": "/static/images/search.png"
    }
  }), _vm._v(" "), _c('input', {
    directives: [{
      name: "model",
      rawName: "v-model",
      value: (_vm.ID),
      expression: "ID"
    }],
    attrs: {
      "focus": true,
      "confirm-type": "search",
      "placeholder": _vm.placeholder,
      "eventid": '0'
    },
    domProps: {
      "value": (_vm.ID)
    },
    on: {
      "confirm": _vm.search,
      "input": [function($event) {
        if ($event.target.composing) { return; }
        _vm.ID = $event.target.value
      }, _vm.handleInput]
    }
  })]), _vm._v(" "), _c('button', {
    directives: [{
      name: "show",
      rawName: "v-show",
      value: (_vm.searched),
      expression: "searched"
    }],
    attrs: {
      "loading": _vm.loading,
      "hover-class": "clicked",
      "eventid": '1'
    },
    on: {
      "click": _vm.handleClick
    }
  }, [_vm._v(_vm._s(_vm.buttonText))])], 1)
}
var staticRenderFns = []
render._withStripped = true
var esExports = { render: render, staticRenderFns: staticRenderFns }
/* harmony default export */ __webpack_exports__["a"] = (esExports);
if (false) {
  module.hot.accept()
  if (module.hot.data) {
     require("vue-hot-reload-api").rerender("data-v-ba8a7d9c", esExports)
  }
}

/***/ })

},[202]);