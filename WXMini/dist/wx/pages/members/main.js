require("../../common/manifest.js")
require("../../common/vendor.js")
global.webpackJsonpMpvue([8],{

/***/ 187:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_vue__ = __webpack_require__(0);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_vue___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_0_vue__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__index__ = __webpack_require__(188);



// add this to handle exception
__WEBPACK_IMPORTED_MODULE_0_vue___default.a.config.errorHandler = function (err) {
  if (console && console.error) {
    console.error(err);
  }
};

var app = new __WEBPACK_IMPORTED_MODULE_0_vue___default.a(__WEBPACK_IMPORTED_MODULE_1__index__["a" /* default */]);
app.$mount();

/***/ }),

/***/ 188:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__babel_loader_node_modules_mpvue_loader_lib_selector_type_script_index_0_index_vue__ = __webpack_require__(190);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__node_modules_mpvue_loader_lib_template_compiler_index_id_data_v_1f364c65_hasScoped_true_transformToRequire_video_src_source_src_img_src_image_xlink_href_fileExt_template_wxml_script_js_style_wxss_platform_wx_node_modules_mpvue_loader_lib_selector_type_template_index_0_index_vue__ = __webpack_require__(191);
var disposed = false
function injectStyle (ssrContext) {
  if (disposed) return
  __webpack_require__(189)
}
var normalizeComponent = __webpack_require__(1)
/* script */

/* template */

/* styles */
var __vue_styles__ = injectStyle
/* scopeId */
var __vue_scopeId__ = "data-v-1f364c65"
/* moduleIdentifier (server only) */
var __vue_module_identifier__ = null
var Component = normalizeComponent(
  __WEBPACK_IMPORTED_MODULE_0__babel_loader_node_modules_mpvue_loader_lib_selector_type_script_index_0_index_vue__["a" /* default */],
  __WEBPACK_IMPORTED_MODULE_1__node_modules_mpvue_loader_lib_template_compiler_index_id_data_v_1f364c65_hasScoped_true_transformToRequire_video_src_source_src_img_src_image_xlink_href_fileExt_template_wxml_script_js_style_wxss_platform_wx_node_modules_mpvue_loader_lib_selector_type_template_index_0_index_vue__["a" /* default */],
  __vue_styles__,
  __vue_scopeId__,
  __vue_module_identifier__
)
Component.options.__file = "src\\pages\\members\\index.vue"
if (Component.esModule && Object.keys(Component.esModule).some(function (key) {return key !== "default" && key.substr(0, 2) !== "__"})) {console.error("named exports are not supported in *.vue files.")}
if (Component.options.functional) {console.error("[vue-loader] index.vue: functional components are not supported with templates, they should use render functions.")}

/* hot reload */
if (false) {(function () {
  var hotAPI = require("vue-hot-reload-api")
  hotAPI.install(require("vue"), false)
  if (!hotAPI.compatible) return
  module.hot.accept()
  if (!module.hot.data) {
    hotAPI.createRecord("data-v-1f364c65", Component.options)
  } else {
    hotAPI.reload("data-v-1f364c65", Component.options)
  }
  module.hot.dispose(function (data) {
    disposed = true
  })
})()}

/* harmony default export */ __webpack_exports__["a"] = (Component.exports);


/***/ }),

/***/ 189:
/***/ (function(module, exports) {

// removed by extract-text-webpack-plugin

/***/ }),

/***/ 190:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_babel_runtime_helpers_extends__ = __webpack_require__(6);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_babel_runtime_helpers_extends___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_0_babel_runtime_helpers_extends__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1_vuex__ = __webpack_require__(4);

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
//
//


/* harmony default export */ __webpack_exports__["a"] = ({
  data: function data() {
    return {
      muteModal: false,
      member: {},
      muteTime: undefined,
      current: Date.now(),
      intervalID: ''
    };
  },

  computed: __WEBPACK_IMPORTED_MODULE_0_babel_runtime_helpers_extends___default()({}, Object(__WEBPACK_IMPORTED_MODULE_1_vuex__["c" /* mapState */])({
    currentGroupProfile: function currentGroupProfile(state) {
      return state.conversation.currentConversation.groupProfile;
    },
    currentGroupMemberList: function currentGroupMemberList(state) {
      return state.group.currentGroupMemberList;
    }
  }), {
    isMyRoleOwner: function isMyRoleOwner() {
      return this.currentGroupProfile.selfInfo.role === this.$type.GRP_MBR_ROLE_OWNER;
    },
    isMyRoleAdmin: function isMyRoleAdmin() {
      return this.currentGroupProfile.selfInfo.role === this.$type.GRP_MBR_ROLE_ADMIN;
    }
  }),
  onReachBottom: function onReachBottom() {
    // 若群成员列表未拉完，则触底时拉下一页
    if (this.currentGroupMemberList.length !== this.currentGroupProfile.memberNum) {
      this.getGroupMemberList();
    }
  },

  methods: {
    getGroupMemberList: function getGroupMemberList() {
      this.$store.dispatch('getGroupMemberList');
    },
    muteMember: function muteMember() {
      var _this = this;

      wx.$app.setGroupMemberMuteTime({
        groupID: this.currentGroupProfile.groupID,
        userID: this.member.userID,
        muteTime: Number(this.muteTime)
      }).then(function (res) {
        _this.$store.commit('showToast', {
          title: '设置禁言成功'
        });
        _this.muteTime = undefined;
        _this.cancelMuteModal();
      });
    },
    cancelMuteModal: function cancelMuteModal() {
      this.muteModal = false;
    },
    cancelMute: function cancelMute(item) {
      var _this2 = this;

      wx.$app.setGroupMemberMuteTime({
        groupID: this.currentGroupProfile.groupID,
        userID: item.userID,
        muteTime: Number(0)
      }).then(function () {
        _this2.$store.commit('showToast', {
          title: '禁言成功'
        });
      });
    },

    // 踢出群聊
    kick: function kick(item) {
      wx.$app.deleteGroupMember({
        groupID: this.currentGroupProfile.groupID,
        reason: '踢出群',
        userIDList: [item.userID]
      });
    },
    mute: function mute(item) {
      this.muteModal = true;
      this.member = item;
    },

    // 设置群角色——管理员Admin, 普通Member
    setRole: function setRole(item) {
      var _this3 = this;

      var role = 'Admin';
      if (item.role === 'Admin') {
        role = 'Member';
      }
      wx.$app.setGroupMemberRole({
        groupID: this.currentGroupProfile.groupID,
        userID: item.userID,
        role: role
      }).then(function () {
        _this3.$store.commit('showToast', {
          title: '设置成功',
          icon: 'success',
          duration: 1500
        });
      });
    }
  },
  mounted: function mounted() {
    var _this4 = this;

    this.intervalID = setInterval(function () {
      _this4.current = Date.now();
    }, 1000);
  },
  destory: function destory() {
    this.intervalID = '';
  }
});

/***/ }),

/***/ 191:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
var render = function () {var _vm=this;var _h=_vm.$createElement;var _c=_vm._self._c||_h;
  return _c('div', {
    staticClass: "chatting"
  }, [_c('i-modal', {
    attrs: {
      "title": "设置禁言时间",
      "visible": _vm.muteModal,
      "eventid": '1',
      "mpcomid": '0'
    },
    on: {
      "ok": _vm.muteMember,
      "cancel": _vm.cancelMuteModal
    }
  }, [_c('div', {
    staticClass: "input-wrapper"
  }, [_c('input', {
    directives: [{
      name: "model",
      rawName: "v-model.lazy:value",
      value: (_vm.muteTime),
      expression: "muteTime",
      modifiers: {
        "lazy:value": true
      }
    }],
    staticClass: "input",
    attrs: {
      "type": "number",
      "placeholder": "单位：秒",
      "eventid": '0'
    },
    domProps: {
      "value": (_vm.muteTime)
    },
    on: {
      "input": function($event) {
        if ($event.target.composing) { return; }
        _vm.muteTime = $event.target.value
      }
    }
  })])]), _vm._v(" "), _vm._l((_vm.currentGroupMemberList), function(item, index) {
    return _c('div', {
      key: item.userID,
      staticClass: "chat"
    }, [_c('i-row', {
      attrs: {
        "mpcomid": '8_' + index
      },
      slot: "content"
    }, [_c('i-col', {
      attrs: {
        "span": "1",
        "mpcomid": '1_' + index
      }
    }, [(item.role === 'Member') ? _c('div', {
      staticClass: "last"
    }, [_vm._v("普")]) : (item.role === 'Admin') ? _c('div', {
      staticClass: "last"
    }, [_vm._v("管")]) : (item.role === 'Owner') ? _c('div', {
      staticClass: "last"
    }, [_vm._v("主")]) : _vm._e()]), _vm._v(" "), _c('i-col', {
      attrs: {
        "span": "3",
        "mpcomid": '3_' + index
      }
    }, [_c('div', {
      staticClass: "avatar"
    }, [_c('i-avatar', {
      attrs: {
        "src": item.avatar || '/static/images/avatar.png',
        "mpcomid": '2_' + index
      }
    })], 1)]), _vm._v(" "), _c('i-col', {
      attrs: {
        "span": "7",
        "mpcomid": '4_' + index
      }
    }, [_c('div', {
      staticClass: "information"
    }, [_c('div', {
      staticClass: "username"
    }, [_vm._v(_vm._s(item.nick || item.userID))])])]), _vm._v(" "), (_vm.currentGroupProfile.type === 'Public' || _vm.currentGroupProfile.type === 'ChatRoom') ? _c('i-col', {
      attrs: {
        "span": "6",
        "mpcomid": '5_' + index
      }
    }, [_c('div', {
      staticClass: "information"
    }, [((_vm.isMyRoleOwner || _vm.isMyRoleAdmin) && item.role === 'Member') ? _c('a', {
      staticClass: "set",
      attrs: {
        "eventid": '2_' + index
      },
      on: {
        "click": function($event) {
          _vm.setRole(item)
        }
      }
    }, [_vm._v("设为管理员")]) : _vm._e(), _vm._v(" "), (_vm.isMyRoleOwner && item.role === 'Admin') ? _c('a', {
      staticClass: "set",
      attrs: {
        "eventid": '3_' + index
      },
      on: {
        "click": function($event) {
          _vm.setRole(item)
        }
      }
    }, [_vm._v("取消管理员")]) : _vm._e()])]) : _vm._e(), _vm._v(" "), _c('i-col', {
      attrs: {
        "span": "3",
        "mpcomid": '6_' + index
      }
    }, [_c('div', {
      staticClass: "information"
    }, [((_vm.isMyRoleOwner && item.role !== 'Owner' || _vm.isMyRoleAdmin && item.role === 'Member')) ? _c('a', {
      staticClass: "delete",
      attrs: {
        "eventid": '4_' + index
      },
      on: {
        "click": function($event) {
          _vm.kick(item)
        }
      }
    }, [_vm._v("删除")]) : _vm._e()])]), _vm._v(" "), _c('i-col', {
      attrs: {
        "span": "4",
        "mpcomid": '7_' + index
      }
    }, [(_vm.currentGroupProfile.type !== 'Private') ? _c('div', {
      staticClass: "information"
    }, [((_vm.isMyRoleOwner && (item.role === 'Member' || item.role === 'Admin')) || (_vm.isMyRoleAdmin && item.role === 'Member')) ? _c('div', [(item.muteUntil * 1000 > _vm.current) ? _c('span', [_c('a', {
      staticClass: "delete",
      attrs: {
        "eventid": '5_' + index
      },
      on: {
        "click": function($event) {
          _vm.cancelMute(item)
        }
      }
    }, [_vm._v("取消禁言")])]) : _c('span', [_c('a', {
      staticClass: "delete",
      attrs: {
        "eventid": '6_' + index
      },
      on: {
        "click": function($event) {
          _vm.mute(item)
        }
      }
    }, [_vm._v("禁言")])])]) : _vm._e()]) : _vm._e()])], 1)], 1)
  })], 2)
}
var staticRenderFns = []
render._withStripped = true
var esExports = { render: render, staticRenderFns: staticRenderFns }
/* harmony default export */ __webpack_exports__["a"] = (esExports);
if (false) {
  module.hot.accept()
  if (module.hot.data) {
     require("vue-hot-reload-api").rerender("data-v-1f364c65", esExports)
  }
}

/***/ })

},[187]);