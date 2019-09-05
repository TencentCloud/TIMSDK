require("../../common/manifest.js")
require("../../debug/GenerateTestUserSig.js")
require("../../common/vendor.js")
global.webpackJsonpMpvue([10],{

/***/ "3g6o":
/***/ (function(module, exports) {

// removed by extract-text-webpack-plugin

/***/ }),

/***/ "JAZu":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_vue__ = __webpack_require__("5nAL");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_vue___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_0_vue__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__index__ = __webpack_require__("whLq");



var app = new __WEBPACK_IMPORTED_MODULE_0_vue___default.a(__WEBPACK_IMPORTED_MODULE_1__index__["a" /* default */]);
app.$mount();

/***/ }),

/***/ "QaIq":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
var render = function () {var _vm=this;var _h=_vm.$createElement;var _c=_vm._self._c||_h;
  return _c('div', {
    staticClass: "bg"
  }, [_c('i-modal', {
    attrs: {
      "title": "添加的用户ID",
      "visible": _vm.addModalVisible,
      "eventid": '1',
      "mpcomid": '0'
    },
    on: {
      "ok": _vm.handleAdd,
      "cancel": _vm.handleModalShow
    }
  }, [_c('div', {
    staticClass: "input-wrapper"
  }, [_c('input', {
    directives: [{
      name: "model",
      rawName: "v-model.lazy:value",
      value: (_vm.addUserId),
      expression: "addUserId",
      modifiers: {
        "lazy:value": true
      }
    }],
    staticClass: "input",
    attrs: {
      "type": "text",
      "eventid": '0'
    },
    domProps: {
      "value": (_vm.addUserId)
    },
    on: {
      "input": function($event) {
        if ($event.target.composing) { return; }
        _vm.addUserId = $event.target.value
      }
    }
  })])]), _vm._v(" "), _c('i-modal', {
    attrs: {
      "title": "转让群组",
      "visible": _vm.changeOwnerModal,
      "eventid": '3',
      "mpcomid": '3'
    },
    on: {
      "ok": _vm.handleChangeOwner,
      "cancel": _vm.changeGroupOwner
    }
  }, [_c('div', {
    staticClass: "input-wrapper"
  }, [_c('i-radio-group', {
    attrs: {
      "current": _vm.current,
      "eventid": '2',
      "mpcomid": '2'
    },
    on: {
      "change": _vm.handleChange
    }
  }, _vm._l((_vm.groupProfile.memberList), function(item, index) {
    return _c('i-radio', {
      key: item.userID,
      attrs: {
        "position": "left",
        "value": item.userID,
        "mpcomid": '1_' + index
      }
    }, [_vm._v(_vm._s(item.userID) + "\n        ")])
  }))], 1)]), _vm._v(" "), _c('div', {
    staticClass: "card"
  }, [_c('i-row', {
    attrs: {
      "mpcomid": '6'
    }
  }, [_c('i-col', {
    attrs: {
      "span": "8",
      "mpcomid": '4'
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
      "src": _vm.groupProfile.avatar || '/static/images/groups.png'
    }
  })])]), _vm._v(" "), _c('i-col', {
    attrs: {
      "span": "16",
      "mpcomid": '5'
    }
  }, [_c('div', {
    staticClass: "right"
  }, [_c('div', {
    staticClass: "username"
  }, [_vm._v(_vm._s(_vm.groupProfile.name))]), _vm._v(" "), _c('div', {
    staticClass: "account"
  }, [_vm._v("群ID：" + _vm._s(_vm.groupProfile.groupID))])])])], 1)], 1), _vm._v(" "), _c('div', {
    staticClass: "card",
    staticStyle: {
      "margin-top": "10px",
      "padding-left": "20px",
      "padding-right": "20px"
    }
  }, [_c('i-row', {
    attrs: {
      "mpcomid": '9'
    }
  }, [_c('i-col', {
    attrs: {
      "span": "22",
      "mpcomid": '7'
    }
  }, [_c('div', {
    staticClass: "member"
  }, [_c('div', {
    staticClass: "member-list"
  }, [_vm._v("\n            群成员\n          ")]), _vm._v(" "), (_vm.currentGroupProfile.type === 'Private') ? _c('div', {
    staticStyle: {
      "padding-left": "10px"
    },
    attrs: {
      "eventid": '4'
    },
    on: {
      "click": function($event) {
        _vm.handleModalShow()
      }
    }
  }, [_c('image', {
    staticStyle: {
      "width": "20px",
      "height": "20px",
      "border-radius": "50%"
    },
    attrs: {
      "src": "/static/images/more.png"
    }
  })]) : _vm._e()])]), _vm._v(" "), _c('i-col', {
    attrs: {
      "span": "2",
      "mpcomid": '8'
    }
  }, [_c('div', {
    staticClass: "member",
    attrs: {
      "eventid": '5'
    },
    on: {
      "click": function($event) {
        _vm.allMember()
      }
    }
  }, [_c('image', {
    staticStyle: {
      "width": "20px",
      "height": "20px",
      "border-radius": "50%"
    },
    attrs: {
      "src": "/static/images/right.png"
    }
  })])])], 1)], 1), _vm._v(" "), _c('div', {
    staticClass: "card"
  }, [_c('div', {
    staticClass: "item"
  }, [_c('div', {
    staticClass: "key"
  }, [_vm._v("群介绍")]), _vm._v(" "), _c('div', {
    staticClass: "value"
  }, [_vm._v(_vm._s(_vm.groupProfile.introduction || '未设置'))])])]), _vm._v(" "), _c('div', {
    staticClass: "card"
  }, [_c('div', {
    staticClass: "item"
  }, [_c('div', {
    staticClass: "key"
  }, [_vm._v("群公告")]), _vm._v(" "), _c('div', {
    staticClass: "value"
  }, [_vm._v(_vm._s(_vm.groupProfile.notification || '未设置'))])])]), _vm._v(" "), _c('div', {
    staticClass: "card"
  }, [_c('div', {
    staticClass: "item"
  }, [_c('div', {
    staticClass: "key"
  }, [_vm._v("群类型")]), _vm._v(" "), _c('div', {
    staticClass: "value"
  }, [_vm._v(_vm._s(_vm.groupProfile.type))])])]), _vm._v(" "), (_vm.isOwner && _vm.groupProfile.type !== 'AVChatRoom') ? _c('div', {
    staticClass: "revise"
  }, [_c('button', {
    staticClass: "btn delete",
    attrs: {
      "eventid": '6'
    },
    on: {
      "click": _vm.changeGroupOwner
    }
  }, [_vm._v("转让群组")])], 1) : _vm._e(), _vm._v(" "), (_vm.groupProfile.type !== 'Public') ? _c('div', {
    staticClass: "revise"
  }, [_c('button', {
    staticClass: "btn delete",
    attrs: {
      "eventid": '7'
    },
    on: {
      "click": _vm.quitGroup
    }
  }, [_vm._v("退出群组")])], 1) : _vm._e(), _vm._v(" "), (_vm.isOwner && _vm.groupProfile.type !== 'Private') ? _c('div', {
    staticClass: "revise"
  }, [_c('button', {
    staticClass: "btn delete",
    attrs: {
      "eventid": '8'
    },
    on: {
      "click": _vm.dismissGroup
    }
  }, [_vm._v("解散群组")])], 1) : _vm._e()], 1)
}
var staticRenderFns = []
var esExports = { render: render, staticRenderFns: staticRenderFns }
/* harmony default export */ __webpack_exports__["a"] = (esExports);

/***/ }),

/***/ "mvpX":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_babel_runtime_helpers_extends__ = __webpack_require__("Dd8w");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_babel_runtime_helpers_extends___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_0_babel_runtime_helpers_extends__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1_vuex__ = __webpack_require__("NYxO");

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
      groupProfile: {},
      addModalVisible: false,
      isInBlacklist: false,
      changeOwnerModal: false,
      list: [],
      current: ''
    };
  },

  // 退出聊天页面的时候所有状态清空
  onUnload: function onUnload() {
    this.groupProfile = {};
  },

  computed: __WEBPACK_IMPORTED_MODULE_0_babel_runtime_helpers_extends___default()({}, Object(__WEBPACK_IMPORTED_MODULE_1_vuex__["b" /* mapState */])({
    currentGroupProfile: function currentGroupProfile(state) {
      return state.group.currentGroupProfile;
    }
  }), {
    isMyRoleOwner: function isMyRoleOwner() {
      return this.currentGroupProfile.selfInfo.role === this.$type.GRP_MBR_ROLE_OWNER;
    },
    isMyRoleAdmin: function isMyRoleAdmin() {
      return this.currentGroupProfile.selfInfo.role === this.$type.GRP_MBR_ROLE_ADMIN;
    }
  }),
  onShow: function onShow() {
    this.getBlacklist();
    this.groupProfile = this.$store.state.group.currentGroupProfile;
  },

  methods: {
    dismissGroup: function dismissGroup() {
      var _this = this;

      wx.$app.dismissGroup(this.groupProfile.groupID).then(function (_ref) {
        var groupID = _ref.data;

        _this.$store.commit('showToast', {
          title: '\u7FA4\uFF1A' + (_this.groupProfile.name || _this.groupProfile.groupID) + '\u89E3\u6563\u6210\u529F\uFF01',
          type: 'success'
        });
        _this.$store.commit('resetCurrentConversation');
        _this.$store.commit('resetGroup');
        wx.switchTab({
          url: '../index/main'
        });
      });
    },
    changeGroupOwner: function changeGroupOwner() {
      this.changeOwnerModal = !this.changeOwnerModal;
    },
    handleChange: function handleChange(e) {
      this.current = e.target.value;
    },
    handleChangeOwner: function handleChangeOwner() {
      var _this2 = this;

      wx.$app.changeGroupOwner({
        groupID: this.groupProfile.groupID,
        newOwnerID: this.current
      }).then(function () {
        _this2.$store.commit('showToast', {
          title: '转让群组成功'
        });
        _this2.changeGroupOwner();
      });
    },

    // 获取黑名单
    getBlacklist: function getBlacklist() {
      var _this3 = this;

      wx.$app.getBlacklist().then(function (res) {
        _this3.$store.commit('setBlacklist', res.data);
      });
    },

    // 所有成员页
    allMember: function allMember() {
      var _this4 = this;

      var count = this.$store.state.group.count;
      wx.$app.getGroupMemberList({
        groupID: this.currentGroupProfile.groupID,
        offset: 0,
        count: count
      }).then(function (res) {
        _this4.$store.commit('updateCurrentGroupMemberList', res.data.memberList);
        _this4.$store.commit('updateOffset');
        var url = '../members/main';
        wx.navigateTo({ url: url });
      });
    },

    // 退出群聊
    quitGroup: function quitGroup() {
      var _this5 = this;

      wx.$app.quitGroup(this.groupProfile.groupID).then(function () {
        _this5.$store.commit('showToast', {
          title: '退出成功',
          icon: 'success',
          duration: 1500
        });
        _this5.$store.commit('resetCurrentConversation');
        _this5.$store.commit('resetGroup');
        wx.switchTab({
          url: '../index/main'
        });
      }).catch(function (err) {
        console.warn('quitGroupFail', err);
        _this5.$store.commit('showToast', {
          title: '退出失败',
          icon: 'none',
          duration: 1500
        });
      });
    },

    // 群组详情页，添加群成员modal是否出现
    handleModalShow: function handleModalShow() {
      this.addModalVisible = !this.addModalVisible;
    },

    // 群组详情页，添加群成员
    handleAdd: function handleAdd() {
      var _this6 = this;

      var conversationID = this.$store.state.conversation.currentConversationID;
      wx.$app.getUserProfile({
        userIDList: [this.addUserId]
      }).then(function () {
        wx.$app.addGroupMember({
          groupID: conversationID.replace(_this6.TIM.TYPES.CONV_GROUP, ''),
          userIDList: [_this6.addUserId]
        }).then(function (res) {
          _this6.addUserId = '';
          _this6.handleModalShow();
          var fails = res.data.failureUserIDList;
          var existed = res.data.existedUserIDList;
          var success = res.data.successUserIDList;
          if (fails.length > 0) {
            _this6.$store.commit('showToast', {
              title: '添加失败!再试试吧',
              icon: 'none',
              duration: 1500
            });
          }
          if (existed.length > 0) {
            _this6.$store.commit('showToast', {
              title: '已经在群里',
              icon: 'none',
              duration: 1500
            });
          }
          if (success.length > 0) {
            _this6.$store.commit('showToast', {
              title: '添加成功',
              icon: 'none',
              duration: 1500
            });
          }
        });
      }).catch(function () {
        _this6.$store.commit('showToast', {
          title: '没有找到该用户',
          icon: 'none',
          duration: 1500
        });
      });
    }
  },
  destory: function destory() {}
});

/***/ }),

/***/ "whLq":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__babel_loader_node_modules_mpvue_loader_lib_selector_type_script_index_0_index_vue__ = __webpack_require__("mvpX");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__node_modules_mpvue_loader_lib_template_compiler_index_id_data_v_536d31bc_hasScoped_true_transformToRequire_video_src_source_src_img_src_image_xlink_href_fileExt_template_wxml_script_js_style_wxss_platform_wx_node_modules_mpvue_loader_lib_selector_type_template_index_0_index_vue__ = __webpack_require__("QaIq");
function injectStyle (ssrContext) {
  __webpack_require__("3g6o")
}
var normalizeComponent = __webpack_require__("ybqe")
/* script */

/* template */

/* styles */
var __vue_styles__ = injectStyle
/* scopeId */
var __vue_scopeId__ = "data-v-536d31bc"
/* moduleIdentifier (server only) */
var __vue_module_identifier__ = null
var Component = normalizeComponent(
  __WEBPACK_IMPORTED_MODULE_0__babel_loader_node_modules_mpvue_loader_lib_selector_type_script_index_0_index_vue__["a" /* default */],
  __WEBPACK_IMPORTED_MODULE_1__node_modules_mpvue_loader_lib_template_compiler_index_id_data_v_536d31bc_hasScoped_true_transformToRequire_video_src_source_src_img_src_image_xlink_href_fileExt_template_wxml_script_js_style_wxss_platform_wx_node_modules_mpvue_loader_lib_selector_type_template_index_0_index_vue__["a" /* default */],
  __vue_styles__,
  __vue_scopeId__,
  __vue_module_identifier__
)

/* harmony default export */ __webpack_exports__["a"] = (Component.exports);


/***/ })

},["JAZu"]);