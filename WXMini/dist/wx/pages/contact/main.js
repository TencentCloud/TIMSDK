require("../../common/manifest.js")
require("../../common/vendor.js")
global.webpackJsonpMpvue([13],{

/***/ 93:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_vue__ = __webpack_require__(0);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_vue___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_0_vue__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__index__ = __webpack_require__(94);



var app = new __WEBPACK_IMPORTED_MODULE_0_vue___default.a(__WEBPACK_IMPORTED_MODULE_1__index__["a" /* default */]);
app.$mount();

/***/ }),

/***/ 94:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__babel_loader_node_modules_mpvue_loader_lib_selector_type_script_index_0_index_vue__ = __webpack_require__(96);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__node_modules_mpvue_loader_lib_template_compiler_index_id_data_v_6b29caac_hasScoped_true_transformToRequire_video_src_source_src_img_src_image_xlink_href_fileExt_template_wxml_script_js_style_wxss_platform_wx_node_modules_mpvue_loader_lib_selector_type_template_index_0_index_vue__ = __webpack_require__(97);
var disposed = false
function injectStyle (ssrContext) {
  if (disposed) return
  __webpack_require__(95)
}
var normalizeComponent = __webpack_require__(1)
/* script */

/* template */

/* styles */
var __vue_styles__ = injectStyle
/* scopeId */
var __vue_scopeId__ = "data-v-6b29caac"
/* moduleIdentifier (server only) */
var __vue_module_identifier__ = null
var Component = normalizeComponent(
  __WEBPACK_IMPORTED_MODULE_0__babel_loader_node_modules_mpvue_loader_lib_selector_type_script_index_0_index_vue__["a" /* default */],
  __WEBPACK_IMPORTED_MODULE_1__node_modules_mpvue_loader_lib_template_compiler_index_id_data_v_6b29caac_hasScoped_true_transformToRequire_video_src_source_src_img_src_image_xlink_href_fileExt_template_wxml_script_js_style_wxss_platform_wx_node_modules_mpvue_loader_lib_selector_type_template_index_0_index_vue__["a" /* default */],
  __vue_styles__,
  __vue_scopeId__,
  __vue_module_identifier__
)
Component.options.__file = "src\\pages\\contact\\index.vue"
if (Component.esModule && Object.keys(Component.esModule).some(function (key) {return key !== "default" && key.substr(0, 2) !== "__"})) {console.error("named exports are not supported in *.vue files.")}
if (Component.options.functional) {console.error("[vue-loader] index.vue: functional components are not supported with templates, they should use render functions.")}

/* hot reload */
if (false) {(function () {
  var hotAPI = require("vue-hot-reload-api")
  hotAPI.install(require("vue"), false)
  if (!hotAPI.compatible) return
  module.hot.accept()
  if (!module.hot.data) {
    hotAPI.createRecord("data-v-6b29caac", Component.options)
  } else {
    hotAPI.reload("data-v-6b29caac", Component.options)
  }
  module.hot.dispose(function (data) {
    disposed = true
  })
})()}

/* harmony default export */ __webpack_exports__["a"] = (Component.exports);


/***/ }),

/***/ 95:
/***/ (function(module, exports) {

// removed by extract-text-webpack-plugin

/***/ }),

/***/ 96:
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
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
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
      search: '',
      friends: [],
      addModalVisible: false,
      addUserId: '',
      applyModalVisible: false,
      result: {}
    };
  },

  components: {},
  methods: {
    handleApply: function handleApply() {
      var _this = this;

      wx.$app.joinGroup({ groupID: this.result.groupID, type: this.result.type }).then(function (res) {
        if (res.data.status === 'JoinedSuccess') {
          _this.$store.commit('showToast', {
            title: '加群成功'
          });
          _this.search = '';
        } else {
          _this.$store.commit('showToast', {
            title: '申请成功，等待群管理员确认'
          });
        }
        _this.handleApplyModal();
      }).catch(function () {
        _this.$store.commit('showToast', {
          title: '加群失败'
        });
      });
    },
    handleApplyModal: function handleApplyModal() {
      this.applyModalVisible = !this.applyModalVisible;
    },

    // 软键盘点击搜索
    confirm: function confirm() {
      var _this2 = this;

      if (this.search !== '@TIM#SYSTEM') {
        wx.$app.searchGroupByID(this.search).then(function (res) {
          _this2.result = res.data.group;
          _this2.handleApplyModal();
        }).catch(function () {
          _this2.search = '';
          _this2.$store.commit('showToast', {
            title: '没有搜到群组'
          });
        });
      } else {
        this.$store.commit('showToast', {
          title: '没有搜到群组'
        });
      }
    },

    // 初始化朋友列表
    initFriendsList: function initFriendsList() {
      var _this3 = this;

      wx.$app.getFriendList({
        fromAccount: this.$store.state.user.userProfile.to
      }).then(function (res) {
        _this3.friends = res.data;
      });
    },

    // 去黑名单页面
    toBlacklist: function toBlacklist() {
      var url = '../blacklist/main';
      wx.navigateTo({ url: url });
    },

    // 去群组页面
    toGroupList: function toGroupList() {
      var url = '../groups/main';
      wx.navigateTo({ url: url });
    },

    // 点击朋友item, 开始聊天
    startConversation: function startConversation() {
      var url = '../friend/main';
      wx.navigateTo({ url: url });
    },

    // 模态框显示状态
    handleModalShow: function handleModalShow() {
      this.addModalVisible = !this.addModalVisible;
    },

    // 跳转到创建群组页面
    createGroup: function createGroup() {
      var url = '../create/main';
      wx.navigateTo({ url: url });
    },

    // 加好友
    // handleAdd () {
    //   if (this.addUserId !== '') {
    //     let option = {
    //       userIDList: [this.addUserId]
    //     }
    //     wx.$app.getUserProfile(option).then(res => {
    //       let userProfile = res.data[0]
    //       let options = {
    //         To_Account: userProfile.userID
    //       }
    //       wx.$app.applyAddFriend(options).then(() => {
    //         this.$store.commit('showToast', { title: '发送申请成功' })
    //         this.handleModalShow()
    //       }).catch(() => {
    //         this.$store.commit('showToast', { title: '发送申请失败' })
    //       })
    //     })
    //   }
    // },
    chatTo: function chatTo(item) {
      var _this4 = this;

      var conversationID = this.TIM.TYPES.CONV_C2C + item.userID;
      wx.$app.getConversationProfile(conversationID).then(function (res) {
        _this4.$store.commit('updateCurrentConversation', res.data.conversation);
        _this4.$store.state.conversation.currentMessageList = [];
        _this4.$store.dispatch('getMessageList', conversationID);
        _this4.content = '';
        _this4.id = '';
        var url = '../chat/main?toAccount=' + res.data.conversation.userProfile.nick;
        wx.navigateTo({ url: url });
      }).catch(function (error) {
        console.log(error);
      });
    }
  },
  mounted: function mounted() {
    // this.initFriendsList()
  }
});

/***/ }),

/***/ 97:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
var render = function () {var _vm=this;var _h=_vm.$createElement;var _c=_vm._self._c||_h;
  return _c('div', {
    staticClass: "container"
  }, [_c('i-modal', {
    attrs: {
      "title": "提示",
      "visible": _vm.applyModalVisible,
      "eventid": '0',
      "mpcomid": '0'
    },
    on: {
      "ok": _vm.handleApply,
      "cancel": _vm.handleApplyModal
    }
  }, [_c('div', {
    staticClass: "input-wrapper"
  }, [_vm._v("\n        确定要加入群" + _vm._s(_vm.search) + "吗？\n      ")])]), _vm._v(" "), _c('div', {
    staticClass: "methods"
  }, [_c('div', {
    staticClass: "search-wrapper"
  }, [_c('input', {
    directives: [{
      name: "model",
      rawName: "v-model.lazy:value",
      value: (_vm.search),
      expression: "search",
      modifiers: {
        "lazy:value": true
      }
    }],
    staticClass: "search",
    attrs: {
      "type": "text",
      "placeholder": "输入群ID进行搜索",
      "confirm-type": "search",
      "eventid": '1'
    },
    domProps: {
      "value": (_vm.search)
    },
    on: {
      "confirm": function($event) {
        _vm.confirm()
      },
      "input": function($event) {
        if ($event.target.composing) { return; }
        _vm.search = $event.target.value
      }
    }
  })]), _vm._v(" "), _c('div', {
    staticClass: "item",
    attrs: {
      "eventid": '2'
    },
    on: {
      "click": function($event) {
        _vm.startConversation()
      }
    }
  }, [_c('i-row', {
    attrs: {
      "mpcomid": '4'
    }
  }, [_c('i-col', {
    attrs: {
      "span": "4",
      "mpcomid": '2'
    }
  }, [_c('div', {
    staticStyle: {
      "padding": "10px"
    }
  }, [_c('i-avatar', {
    attrs: {
      "shape": "square",
      "size": "large",
      "src": "../../../static/images/start.png",
      "mpcomid": '1'
    }
  })], 1)]), _vm._v(" "), _c('i-col', {
    attrs: {
      "span": "20",
      "mpcomid": '3'
    }
  }, [_c('div', {
    staticClass: "right border-bottom"
  }, [_c('div', {
    staticClass: "information"
  }, [_vm._v("发起会话")])])])], 1)], 1), _vm._v(" "), _c('div', {
    staticClass: "item",
    attrs: {
      "eventid": '3'
    },
    on: {
      "click": function($event) {
        _vm.createGroup()
      }
    }
  }, [_c('i-row', {
    attrs: {
      "mpcomid": '8'
    }
  }, [_c('i-col', {
    attrs: {
      "span": "4",
      "mpcomid": '6'
    }
  }, [_c('div', {
    staticStyle: {
      "padding": "10px"
    }
  }, [_c('i-avatar', {
    attrs: {
      "shape": "square",
      "size": "large",
      "src": "../../../static/images/group.png",
      "mpcomid": '5'
    }
  })], 1)]), _vm._v(" "), _c('i-col', {
    attrs: {
      "span": "20",
      "mpcomid": '7'
    }
  }, [_c('div', {
    staticClass: "right border-bottom"
  }, [_c('div', {
    staticClass: "information"
  }, [_vm._v("新建群聊")])])])], 1)], 1), _vm._v(" "), _c('div', {
    staticClass: "item",
    attrs: {
      "eventid": '4'
    },
    on: {
      "click": function($event) {
        _vm.toBlacklist()
      }
    }
  }, [_c('i-row', {
    attrs: {
      "mpcomid": '12'
    }
  }, [_c('i-col', {
    attrs: {
      "span": "4",
      "mpcomid": '10'
    }
  }, [_c('div', {
    staticStyle: {
      "padding": "10px"
    }
  }, [_c('i-avatar', {
    attrs: {
      "shape": "square",
      "size": "large",
      "src": "../../../static/images/blacklist.png",
      "mpcomid": '9'
    }
  })], 1)]), _vm._v(" "), _c('i-col', {
    attrs: {
      "span": "20",
      "mpcomid": '11'
    }
  }, [_c('div', {
    staticClass: "right"
  }, [_c('div', {
    staticClass: "information border-bottom"
  }, [_vm._v("黑名单")])])])], 1)], 1), _vm._v(" "), _c('div', {
    staticClass: "item",
    attrs: {
      "eventid": '5'
    },
    on: {
      "click": function($event) {
        _vm.toGroupList()
      }
    }
  }, [_c('i-row', {
    staticStyle: {
      "border-bottom": "1px solid #e9eaec"
    },
    attrs: {
      "mpcomid": '16'
    }
  }, [_c('i-col', {
    attrs: {
      "span": "4",
      "mpcomid": '14'
    }
  }, [_c('div', {
    staticStyle: {
      "padding": "10px"
    }
  }, [_c('i-avatar', {
    attrs: {
      "shape": "square",
      "size": "large",
      "src": "../../../static/images/contact.png",
      "mpcomid": '13'
    }
  })], 1)]), _vm._v(" "), _c('i-col', {
    attrs: {
      "span": "20",
      "mpcomid": '15'
    }
  }, [_c('div', {
    staticClass: "right"
  }, [_c('div', {
    staticClass: "information  border-bottom"
  }, [_vm._v("我的群聊")])])])], 1)], 1)])], 1)
}
var staticRenderFns = []
render._withStripped = true
var esExports = { render: render, staticRenderFns: staticRenderFns }
/* harmony default export */ __webpack_exports__["a"] = (esExports);
if (false) {
  module.hot.accept()
  if (module.hot.data) {
     require("vue-hot-reload-api").rerender("data-v-6b29caac", esExports)
  }
}

/***/ })

},[93]);