require("../../common/manifest.js")
require("../../common/vendor.js")
global.webpackJsonpMpvue([3],{

/***/ 212:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_vue__ = __webpack_require__(0);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_vue___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_0_vue__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__index__ = __webpack_require__(213);



var app = new __WEBPACK_IMPORTED_MODULE_0_vue___default.a(__WEBPACK_IMPORTED_MODULE_1__index__["a" /* default */]);
app.$mount();

/***/ }),

/***/ 213:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__babel_loader_node_modules_mpvue_loader_lib_selector_type_script_index_0_index_vue__ = __webpack_require__(215);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__node_modules_mpvue_loader_lib_template_compiler_index_id_data_v_290a70ef_hasScoped_true_transformToRequire_video_src_source_src_img_src_image_xlink_href_fileExt_template_wxml_script_js_style_wxss_platform_wx_node_modules_mpvue_loader_lib_selector_type_template_index_0_index_vue__ = __webpack_require__(216);
var disposed = false
function injectStyle (ssrContext) {
  if (disposed) return
  __webpack_require__(214)
}
var normalizeComponent = __webpack_require__(1)
/* script */

/* template */

/* styles */
var __vue_styles__ = injectStyle
/* scopeId */
var __vue_scopeId__ = "data-v-290a70ef"
/* moduleIdentifier (server only) */
var __vue_module_identifier__ = null
var Component = normalizeComponent(
  __WEBPACK_IMPORTED_MODULE_0__babel_loader_node_modules_mpvue_loader_lib_selector_type_script_index_0_index_vue__["a" /* default */],
  __WEBPACK_IMPORTED_MODULE_1__node_modules_mpvue_loader_lib_template_compiler_index_id_data_v_290a70ef_hasScoped_true_transformToRequire_video_src_source_src_img_src_image_xlink_href_fileExt_template_wxml_script_js_style_wxss_platform_wx_node_modules_mpvue_loader_lib_selector_type_template_index_0_index_vue__["a" /* default */],
  __vue_styles__,
  __vue_scopeId__,
  __vue_module_identifier__
)
Component.options.__file = "src\\pages\\update-profile\\index.vue"
if (Component.esModule && Object.keys(Component.esModule).some(function (key) {return key !== "default" && key.substr(0, 2) !== "__"})) {console.error("named exports are not supported in *.vue files.")}
if (Component.options.functional) {console.error("[vue-loader] index.vue: functional components are not supported with templates, they should use render functions.")}

/* hot reload */
if (false) {(function () {
  var hotAPI = require("vue-hot-reload-api")
  hotAPI.install(require("vue"), false)
  if (!hotAPI.compatible) return
  module.hot.accept()
  if (!module.hot.data) {
    hotAPI.createRecord("data-v-290a70ef", Component.options)
  } else {
    hotAPI.reload("data-v-290a70ef", Component.options)
  }
  module.hot.dispose(function (data) {
    disposed = true
  })
})()}

/* harmony default export */ __webpack_exports__["a"] = (Component.exports);


/***/ }),

/***/ 214:
/***/ (function(module, exports) {

// removed by extract-text-webpack-plugin

/***/ }),

/***/ 215:
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
//
//
//
//
//
//



// 修改资料页，支持修改个人资料和群组相关资料
/* harmony default export */ __webpack_exports__["a"] = ({
  data: function data() {
    return {
      type: 'user', // user / group
      key: '',
      groupID: '',
      value: '',
      focus: true
    };
  },

  computed: __WEBPACK_IMPORTED_MODULE_0_babel_runtime_helpers_extends___default()({}, Object(__WEBPACK_IMPORTED_MODULE_1_vuex__["c" /* mapState */])({
    myInfo: function myInfo(state) {
      return state.user.myInfo;
    },
    groupProfile: function groupProfile(state) {
      return state.conversation.currentConversation.groupProfile;
    }
  }), {
    disabled: function disabled() {
      switch (this.key) {
        case 'nick':
          if (this.value !== this.myInfo.nick) {
            return false;
          }
          break;
        case 'signature':
          if (this.value !== this.myInfo.selfSignature) {
            return false;
          }
          break;
        case 'nameCard':
          if (this.groupProfile && this.groupProfile.selfInfo && this.value !== this.groupProfile.selfInfo.nameCard) {
            return false;
          }
          break;
        case 'name':
          if (this.groupProfile && this.value !== this.groupProfile.name) {
            return false;
          }
          break;
        case 'notification':
          if (this.groupProfile && this.value !== this.groupProfile.notification) {
            return false;
          }
          break;
      }
      return true;
    },
    placeholder: function placeholder() {
      switch (this.key) {
        case 'nick':
          return '请输入昵称';
        case 'signature':
          return '请输入个性签名';
        case 'nameCard':
          return '请输入群名片';
      }
    }
  }),
  onLoad: function onLoad(_ref) {
    var type = _ref.type,
        key = _ref.key,
        groupID = _ref.groupID;

    this.type = type;
    this.key = key;
    if (groupID) {
      this.groupID = groupID;
    }
    var title = '';
    switch (key) {
      case 'nick':
        title = '修改昵称';
        this.value = this.myInfo.nick;
        break;
      case 'signature':
        title = '修改个性签名';
        this.value = this.myInfo.selfSignature;
        break;
      case 'nameCard':
        title = '修改群名片';
        this.value = this.groupProfile.selfInfo.nameCard;
        break;
      case 'name':
        title = '修改群名称';
        this.value = this.groupProfile.name;
        break;
      case 'notification':
        title = '修改群公告';
        this.value = this.groupProfile.notification;
        break;
    }
    wx.setNavigationBarTitle({ title: title });
  },

  methods: {
    handleClick: function handleClick() {
      if (this.type === 'user') {
        this.updateMyProfile();
      } else if (this.type === 'group') {
        this.updateGroupProfile();
      }
    },
    updateMyProfile: function updateMyProfile() {
      switch (this.key) {
        case 'nick':
          wx.$app.updateMyProfile({ nick: this.value }).then(this.handleResolve).catch(this.handleReject);
          break;
        case 'signature':
          wx.$app.updateMyProfile({ selfSignature: this.value }).then(this.handleResolve).catch(this.handleReject);
          break;
      }
    },
    updateGroupProfile: function updateGroupProfile() {
      switch (this.key) {
        case 'nameCard':
          wx.$app.setGroupMemberNameCard({
            groupID: this.groupID,
            nameCard: this.value
          }).then(this.handleResolve).catch(this.handleReject);
          break;
        case 'name':
          wx.$app.updateGroupProfile({
            groupID: this.groupID,
            name: this.value
          }).then(this.handleResolve).catch(this.handleReject);
          break;
        case 'notification':
          wx.$app.updateGroupProfile({
            groupID: this.groupID,
            notification: this.value
          }).then(this.handleResolve).catch(this.handleReject);
          break;
        default:
          break;
      }
    },
    handleResolve: function handleResolve() {
      wx.showToast({
        title: '修改成功',
        duration: 600
      });
      setTimeout(function () {
        wx.navigateBack();
      }, 600);
    },
    handleReject: function handleReject(error) {
      wx.showToast({ title: error.message, icon: 'none' });
    }
  }
});

/***/ }),

/***/ 216:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
var render = function () {var _vm=this;var _h=_vm.$createElement;var _c=_vm._self._c||_h;
  return _c('div', {
    staticClass: "update-profile-wrapper"
  }, [_c('input', {
    directives: [{
      name: "model",
      rawName: "v-model",
      value: (_vm.value),
      expression: "value"
    }],
    staticClass: "input",
    class: _vm.focus ? 'input-focus' : '',
    attrs: {
      "type": "text",
      "placeholder": _vm.placeholder,
      "focus": _vm.focus,
      "eventid": '0'
    },
    domProps: {
      "value": (_vm.value)
    },
    on: {
      "blur": function($event) {
        _vm.focus = false
      },
      "focus": function($event) {
        _vm.focus = true
      },
      "input": function($event) {
        if ($event.target.composing) { return; }
        _vm.value = $event.target.value
      }
    }
  }), _vm._v(" "), _c('button', {
    class: {
      'button-disabled': _vm.disabled
    },
    attrs: {
      "disabled": _vm.disabled,
      "eventid": '1'
    },
    on: {
      "click": _vm.handleClick
    }
  }, [_vm._v("确认修改")])], 1)
}
var staticRenderFns = []
render._withStripped = true
var esExports = { render: render, staticRenderFns: staticRenderFns }
/* harmony default export */ __webpack_exports__["a"] = (esExports);
if (false) {
  module.hot.accept()
  if (module.hot.data) {
     require("vue-hot-reload-api").rerender("data-v-290a70ef", esExports)
  }
}

/***/ })

},[212]);