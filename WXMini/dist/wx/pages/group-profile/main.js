require("../../common/manifest.js")
require("../../common/vendor.js")
global.webpackJsonpMpvue([12],{

/***/ 167:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_vue__ = __webpack_require__(0);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_vue___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_0_vue__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__index__ = __webpack_require__(168);



var app = new __WEBPACK_IMPORTED_MODULE_0_vue___default.a(__WEBPACK_IMPORTED_MODULE_1__index__["a" /* default */]);
app.$mount();

/***/ }),

/***/ 168:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__babel_loader_node_modules_mpvue_loader_lib_selector_type_script_index_0_index_vue__ = __webpack_require__(170);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__node_modules_mpvue_loader_lib_template_compiler_index_id_data_v_46c79732_hasScoped_false_transformToRequire_video_src_source_src_img_src_image_xlink_href_fileExt_template_wxml_script_js_style_wxss_platform_wx_node_modules_mpvue_loader_lib_selector_type_template_index_0_index_vue__ = __webpack_require__(171);
var disposed = false
function injectStyle (ssrContext) {
  if (disposed) return
  __webpack_require__(169)
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
  __WEBPACK_IMPORTED_MODULE_1__node_modules_mpvue_loader_lib_template_compiler_index_id_data_v_46c79732_hasScoped_false_transformToRequire_video_src_source_src_img_src_image_xlink_href_fileExt_template_wxml_script_js_style_wxss_platform_wx_node_modules_mpvue_loader_lib_selector_type_template_index_0_index_vue__["a" /* default */],
  __vue_styles__,
  __vue_scopeId__,
  __vue_module_identifier__
)
Component.options.__file = "src\\pages\\group-profile\\index.vue"
if (Component.esModule && Object.keys(Component.esModule).some(function (key) {return key !== "default" && key.substr(0, 2) !== "__"})) {console.error("named exports are not supported in *.vue files.")}
if (Component.options.functional) {console.error("[vue-loader] index.vue: functional components are not supported with templates, they should use render functions.")}

/* hot reload */
if (false) {(function () {
  var hotAPI = require("vue-hot-reload-api")
  hotAPI.install(require("vue"), false)
  if (!hotAPI.compatible) return
  module.hot.accept()
  if (!module.hot.data) {
    hotAPI.createRecord("data-v-46c79732", Component.options)
  } else {
    hotAPI.reload("data-v-46c79732", Component.options)
  }
  module.hot.dispose(function (data) {
    disposed = true
  })
})()}

/* harmony default export */ __webpack_exports__["a"] = (Component.exports);


/***/ }),

/***/ 169:
/***/ (function(module, exports) {

// removed by extract-text-webpack-plugin

/***/ }),

/***/ 170:
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
      addMemberModalVisible: false,
      inputFocus: false,
      userID: ''
    };
  },
  onLoad: function onLoad() {
    var _this = this;

    wx.$app.getGroupMemberList({ groupID: this.groupProfile.groupID }).then(function (_ref) {
      var memberList = _ref.data.memberList;

      _this.$store.commit('updateCurrentGroupMemberList', memberList);
    });
  },
  onUnload: function onUnload() {
    this.userID = '';
    this.addMemberModalVisible = false;
    this.$store.commit('resetCurrentMemberList');
  },

  computed: __WEBPACK_IMPORTED_MODULE_0_babel_runtime_helpers_extends___default()({}, Object(__WEBPACK_IMPORTED_MODULE_1_vuex__["c" /* mapState */])({
    groupProfile: function groupProfile(state) {
      return state.conversation.currentConversation.groupProfile;
    },
    memberList: function memberList(state) {
      return state.group.currentGroupMemberList.slice(0, 12);
    }
  }), {
    // 私有群才能添加群成员
    addMemberButtonVisible: function addMemberButtonVisible() {
      if (this.groupProfile) {
        return this.groupProfile.type === 'Private';
      }
      return false;
    },
    quitText: function quitText() {
      if (this.groupProfile && this.groupProfile.type !== wx.TIM.TYPES.GRP_PRIVATE && this.groupProfile.selfInfo && this.groupProfile.selfInfo.role === 'Owner') {
        return '退出并解散群聊';
      }
      return '退出群聊';
    },
    isAdminOrOwner: function isAdminOrOwner() {
      if (this.groupProfile && this.groupProfile.selfInfo) {
        return this.groupProfile.selfInfo.role !== 'Member';
      }
      return false;
    },
    canIEditGroupProfile: function canIEditGroupProfile() {
      if (!this.groupProfile || !this.groupProfile.selfInfo) {
        return false;
      }
      // 任何成员都可修改私有群的群资料
      if (this.groupProfile.type === this.TIM.TYPES.GRP_PRIVATE) {
        return true;
      }
      // 其他类型的群组只有管理员以上身份可以修改
      if (this.isAdminOrOwner) {
        return true;
      }
      return false;
    }
  }),
  methods: {
    toAllMemberList: function toAllMemberList() {
      wx.navigateTo({ url: '../members/main' });
    },
    toUserProfile: function toUserProfile(member) {
      wx.navigateTo({ url: '../user-profile/main?userID=' + member.userID });
    },
    handleQuit: function handleQuit() {
      var _this2 = this;

      wx.showModal({
        title: '提示',
        content: '是否确定退出群聊？',
        success: function success(res) {
          if (res.confirm) {
            // 解散群聊
            if (_this2.groupProfile.type !== wx.TIM.TYPES.GRP_PRIVATE && _this2.groupProfile.selfInfo.role === 'Owner') {
              wx.$app.dismissGroup(_this2.groupProfile.groupID).then(function () {
                wx.showToast({ title: '解散成功', duration: 800 });
                setTimeout(function () {
                  wx.switchTab({ url: '../index/main' });
                }, 800);
              }).catch(function (error) {
                wx.showToast({ title: error.message, icon: 'none' });
              });
            } else {
              // 退出群聊
              wx.$app.quitGroup(_this2.groupProfile.groupID).then(function () {
                wx.showToast({ title: '退群成功', duration: 800 });
                setTimeout(function () {
                  wx.switchTab({ url: '../index/main' });
                }, 800);
              }).catch(function (error) {
                wx.showToast({ title: error.message, icon: 'none' });
              });
            }
          }
        }
      });
    },
    handleOk: function handleOk() {
      var _this3 = this;

      if (this.userID === '') {
        wx.showToast({ title: '请输入userID', icon: 'none', duration: 800 });
      }
      wx.$app.addGroupMember({
        groupID: this.groupProfile.groupID,
        userIDList: [this.userID]
      }).then(function (res) {
        if (res.data.successUserIDList.length > 0) {
          wx.showToast({ title: '添加成功', duration: 800 });
          _this3.userID = '';
          _this3.addMemberModalVisible = false;
        }
        if (res.data.existedUserIDList.length > 0) {
          wx.showToast({ title: '该用户已在群中', duration: 800, icon: 'none' });
        }
        if (res.data.failureUserIDList.length > 0) {
          wx.showToast({ title: '添加失败，请确保该用户存在', duration: 800, icon: 'none' });
        }
      }).catch(function (error) {
        wx.showToast({ title: error.message, duration: 800, icon: 'none' });
      });
    }
  }
});

/***/ }),

/***/ 171:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
var render = function () {var _vm=this;var _h=_vm.$createElement;var _c=_vm._self._c||_h;
  return (_vm.groupProfile) ? _c('div', {
    staticClass: "group-detail-wrapper"
  }, [_c('div', {
    staticClass: "header"
  }, [_vm._l((_vm.memberList), function(member, index) {
    return [_c('div', {
      key: member.userID,
      staticClass: "member",
      attrs: {
        "eventid": '0_' + index
      },
      on: {
        "click": function($event) {
          _vm.toUserProfile(member)
        }
      }
    }, [_c('i-avatar', {
      attrs: {
        "i-class": "avatar",
        "src": member.avatar || '/static/images/avatar.png',
        "defaultAvatar": "'/static/images/avatar.png'",
        "shape": "square",
        "mpcomid": '0_' + index
      }
    }), _vm._v(" "), _c('div', {
      staticClass: "name"
    }, [_vm._v("\n          " + _vm._s(member.nameCard || member.nick || member.userID) + "\n        ")])], 1)]
  }), _vm._v(" "), _c('div', {
    staticClass: "show-more-btn",
    attrs: {
      "eventid": '1'
    },
    on: {
      "click": _vm.toAllMemberList
    }
  }, [_c('icon', {
    attrs: {
      "size": 40,
      "src": "/static/images/show-more.png"
    }
  }), _vm._v(" "), _c('div', {
    staticClass: "name"
  }, [_vm._v("\n        查看全部\n      ")])], 1), _vm._v(" "), (_vm.addMemberButtonVisible) ? _c('div', {
    staticClass: "add-member-btn",
    attrs: {
      "eventid": '2'
    },
    on: {
      "click": function($event) {
        _vm.addMemberModalVisible = true
      }
    }
  }, [_c('icon', {
    attrs: {
      "size": 40,
      "src": "/static/images/add-group-member.png"
    }
  }), _vm._v(" "), _c('div', {
    staticClass: "name"
  }, [_vm._v("\n        添加\n      ")])], 1) : _vm._e()], 2), _vm._v(" "), _c('i-cell-group', {
    attrs: {
      "mpcomid": '6'
    }
  }, [_c('i-cell', {
    attrs: {
      "title": "群ID",
      "value-class": "cell-value",
      "value": _vm.groupProfile.groupID,
      "mpcomid": '2'
    }
  }), _vm._v(" "), _c('i-cell', {
    attrs: {
      "title": "群名称",
      "value-class": "cell-value",
      "is-link": _vm.canIEditGroupProfile,
      "value": _vm.groupProfile.name,
      "url": '../update-profile/main?type=group&key=name&groupID=' + _vm.groupProfile.groupID,
      "mpcomid": '3'
    }
  }), _vm._v(" "), _c('i-cell', {
    attrs: {
      "title": "群公告",
      "value-class": "cell-value",
      "is-link": _vm.canIEditGroupProfile,
      "value": _vm.groupProfile.notification,
      "url": '../update-profile/main?type=group&key=notification&groupID=' + _vm.groupProfile.groupID,
      "mpcomid": '4'
    }
  }), _vm._v(" "), _c('i-cell', {
    attrs: {
      "title": "我在本群的昵称",
      "value-class": "cell-value",
      "is-link": "",
      "value": _vm.groupProfile.selfInfo.nameCard,
      "url": '../update-profile/main?type=group&key=nameCard&groupID=' + _vm.groupProfile.groupID,
      "mpcomid": '5'
    }
  })], 1), _vm._v(" "), _c('i-cell-group', {
    attrs: {
      "i-class": "group-action",
      "mpcomid": '8'
    }
  }, [_c('i-cell', {
    attrs: {
      "i-class": "quit",
      "title": _vm.quitText,
      "is-link": "",
      "eventid": '3',
      "mpcomid": '7'
    },
    on: {
      "click": _vm.handleQuit
    }
  })], 1), _vm._v(" "), _c('i-modal', {
    attrs: {
      "i-class": _vm.inputFocus ? 'add-member-modal-on-focus add-member-modal' : 'add-member-modal',
      "title": "添加群成员",
      "visible": _vm.addMemberModalVisible,
      "eventid": '5',
      "mpcomid": '9'
    },
    on: {
      "ok": _vm.handleOk,
      "cancel": function($event) {
        _vm.addMemberModalVisible = false
      }
    }
  }, [_c('input', {
    directives: [{
      name: "model",
      rawName: "v-model",
      value: (_vm.userID),
      expression: "userID"
    }],
    staticClass: "user-id-input",
    attrs: {
      "focus": _vm.addMemberModalVisible,
      "placeholder": "请输入 userID",
      "eventid": '4'
    },
    domProps: {
      "value": (_vm.userID)
    },
    on: {
      "focus": function($event) {
        _vm.inputFocus = true
      },
      "blur": function($event) {
        _vm.inputFocus = false
      },
      "input": function($event) {
        if ($event.target.composing) { return; }
        _vm.userID = $event.target.value
      }
    }
  })])], 1) : _vm._e()
}
var staticRenderFns = []
render._withStripped = true
var esExports = { render: render, staticRenderFns: staticRenderFns }
/* harmony default export */ __webpack_exports__["a"] = (esExports);
if (false) {
  module.hot.accept()
  if (module.hot.data) {
     require("vue-hot-reload-api").rerender("data-v-46c79732", esExports)
  }
}

/***/ })

},[167]);