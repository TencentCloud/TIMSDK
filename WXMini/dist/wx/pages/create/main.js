require("../../common/manifest.js")
require("../../common/vendor.js")
global.webpackJsonpMpvue([13],{

/***/ 162:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_vue__ = __webpack_require__(0);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_vue___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_0_vue__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__index__ = __webpack_require__(163);



var app = new __WEBPACK_IMPORTED_MODULE_0_vue___default.a(__WEBPACK_IMPORTED_MODULE_1__index__["a" /* default */]);
app.$mount();

/***/ }),

/***/ 163:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__babel_loader_node_modules_mpvue_loader_lib_selector_type_script_index_0_index_vue__ = __webpack_require__(165);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__node_modules_mpvue_loader_lib_template_compiler_index_id_data_v_e2ba38f4_hasScoped_false_transformToRequire_video_src_source_src_img_src_image_xlink_href_fileExt_template_wxml_script_js_style_wxss_platform_wx_node_modules_mpvue_loader_lib_selector_type_template_index_0_index_vue__ = __webpack_require__(166);
var disposed = false
function injectStyle (ssrContext) {
  if (disposed) return
  __webpack_require__(164)
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
  __WEBPACK_IMPORTED_MODULE_1__node_modules_mpvue_loader_lib_template_compiler_index_id_data_v_e2ba38f4_hasScoped_false_transformToRequire_video_src_source_src_img_src_image_xlink_href_fileExt_template_wxml_script_js_style_wxss_platform_wx_node_modules_mpvue_loader_lib_selector_type_template_index_0_index_vue__["a" /* default */],
  __vue_styles__,
  __vue_scopeId__,
  __vue_module_identifier__
)
Component.options.__file = "src\\pages\\create\\index.vue"
if (Component.esModule && Object.keys(Component.esModule).some(function (key) {return key !== "default" && key.substr(0, 2) !== "__"})) {console.error("named exports are not supported in *.vue files.")}
if (Component.options.functional) {console.error("[vue-loader] index.vue: functional components are not supported with templates, they should use render functions.")}

/* hot reload */
if (false) {(function () {
  var hotAPI = require("vue-hot-reload-api")
  hotAPI.install(require("vue"), false)
  if (!hotAPI.compatible) return
  module.hot.accept()
  if (!module.hot.data) {
    hotAPI.createRecord("data-v-e2ba38f4", Component.options)
  } else {
    hotAPI.reload("data-v-e2ba38f4", Component.options)
  }
  module.hot.dispose(function (data) {
    disposed = true
  })
})()}

/* harmony default export */ __webpack_exports__["a"] = (Component.exports);


/***/ }),

/***/ 164:
/***/ (function(module, exports) {

// removed by extract-text-webpack-plugin

/***/ }),

/***/ 165:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_babel_runtime_core_js_promise__ = __webpack_require__(56);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_babel_runtime_core_js_promise___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_0_babel_runtime_core_js_promise__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1_babel_runtime_core_js_object_assign__ = __webpack_require__(76);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1_babel_runtime_core_js_object_assign___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_1_babel_runtime_core_js_object_assign__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2_babel_runtime_helpers_extends__ = __webpack_require__(6);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2_babel_runtime_helpers_extends___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_2_babel_runtime_helpers_extends__);



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
  selectedIndex: 0,
  range: [{
    type: wx.TIM.TYPES.GRP_PRIVATE,
    name: '讨论组'
  }, {
    type: wx.TIM.TYPES.GRP_PUBLIC,
    name: '公开群'
  }, {
    type: wx.TIM.TYPES.GRP_CHATROOM,
    name: '聊天室'
  }, {
    type: wx.TIM.TYPES.GRP_AVCHATROOM,
    name: '音视频聊天室'
  }],
  groupName: '',
  groupID: '',
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
    isAVChatRoom: function isAVChatRoom() {
      return this.range[this.selectedIndex].type === wx.TIM.TYPES.GRP_AVCHATROOM;
    },
    disabled: function disabled() {
      if (this.groupName === '') {
        return true;
      }
      if (this.isAVChatRoom && this.groupID === '') {
        return true;
      }
      return false;
    }
  },
  methods: {
    choose: function choose(event) {
      this.selectedIndex = Number(event.mp.detail.value);
    },
    handleClick: function handleClick() {
      var _this = this;

      this.loading = true;
      wx.$app.createGroup({
        type: this.range[this.selectedIndex].type,
        groupID: this.groupID || undefined,
        name: this.groupName
      }).then(function (_ref) {
        var group = _ref.data.group;

        if (_this.isAVChatRoom) {
          return wx.$app.joinGroup({ groupID: group.groupID });
        }
        return __WEBPACK_IMPORTED_MODULE_0_babel_runtime_core_js_promise___default.a.resolve();
      }).then(this.handleResolved).catch(this.handleRejected);
    },
    handleResolved: function handleResolved() {
      this.loading = false;
      wx.showToast({
        title: '创建成功',
        duration: 1000
      });
      setTimeout(function () {
        wx.navigateBack();
      }, 1000);
    },
    handleRejected: function handleRejected() {
      this.loading = false;
      wx.showToast({
        title: '创建失败',
        icon: 'none',
        duration: 1000
      });
    },
    showInfo: function showInfo() {
      wx.showModal({
        title: '提示',
        content: '音视频聊天室常用于直播聊天场景，只有在主动加群（需要填写群ID）后才能收到消息，重新登录后需要重新加群。\n故在创建音视频聊天室时，必须填写群ID',
        showCancel: false,
        confirmText: '了解'
      });
    }
  }
});

/***/ }),

/***/ 166:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
var render = function () {var _vm=this;var _h=_vm.$createElement;var _c=_vm._self._c||_h;
  return _c('div', {
    staticClass: "container"
  }, [_c('div', {
    staticClass: "form-item"
  }, [_c('div', {
    staticClass: "label"
  }, [_vm._v("群类型")]), _vm._v(" "), _c('picker', {
    attrs: {
      "range": _vm.range,
      "range-key": "name",
      "value": _vm.selectedIndex,
      "eventid": '0'
    },
    on: {
      "change": _vm.choose
    }
  }, [_vm._v("\n      " + _vm._s(_vm.range[_vm.selectedIndex].name) + "\n      "), _c('i-icon', {
    attrs: {
      "type": "enter",
      "mpcomid": '0'
    }
  })], 1)], 1), _vm._v(" "), _c('div', {
    staticClass: "form-item",
    class: {
      'required': _vm.isAVChatRoom
    }
  }, [_c('div', {
    staticClass: "label"
  }, [_vm._v("\n      群ID\n      "), (_vm.isAVChatRoom) ? _c('i-icon', {
    attrs: {
      "type": "prompt",
      "eventid": '1',
      "mpcomid": '1'
    },
    on: {
      "click": _vm.showInfo
    }
  }) : _vm._e()], 1), _vm._v(" "), _c('input', {
    directives: [{
      name: "model",
      rawName: "v-model",
      value: (_vm.groupID),
      expression: "groupID"
    }],
    attrs: {
      "placeholder": "请输入群ID",
      "eventid": '2'
    },
    domProps: {
      "value": (_vm.groupID)
    },
    on: {
      "input": function($event) {
        if ($event.target.composing) { return; }
        _vm.groupID = $event.target.value
      }
    }
  })]), _vm._v(" "), _c('div', {
    staticClass: "form-item name required"
  }, [_c('div', {
    staticClass: "label"
  }, [_vm._v("\n      群名称\n    ")]), _vm._v(" "), _c('input', {
    directives: [{
      name: "model",
      rawName: "v-model",
      value: (_vm.groupName),
      expression: "groupName"
    }],
    attrs: {
      "placeholder": "请输入群名称",
      "eventid": '3'
    },
    domProps: {
      "value": (_vm.groupName)
    },
    on: {
      "input": function($event) {
        if ($event.target.composing) { return; }
        _vm.groupName = $event.target.value
      }
    }
  })]), _vm._v(" "), _c('button', {
    class: {
      'button-disabled': _vm.disabled
    },
    attrs: {
      "hover-class": "clicked",
      "loading": _vm.loading,
      "disabled": _vm.disabled,
      "eventid": '4'
    },
    on: {
      "click": _vm.handleClick
    }
  }, [_vm._v("创建群组")])], 1)
}
var staticRenderFns = []
render._withStripped = true
var esExports = { render: render, staticRenderFns: staticRenderFns }
/* harmony default export */ __webpack_exports__["a"] = (esExports);
if (false) {
  module.hot.accept()
  if (module.hot.data) {
     require("vue-hot-reload-api").rerender("data-v-e2ba38f4", esExports)
  }
}

/***/ })

},[162]);