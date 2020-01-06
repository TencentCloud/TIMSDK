require("../../common/manifest.js")
require("../../common/vendor.js")
global.webpackJsonpMpvue([14],{

/***/ 142:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_vue__ = __webpack_require__(0);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_vue___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_0_vue__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__index__ = __webpack_require__(143);



var app = new __WEBPACK_IMPORTED_MODULE_0_vue___default.a(__WEBPACK_IMPORTED_MODULE_1__index__["a" /* default */]);
app.$mount();

/***/ }),

/***/ 143:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__babel_loader_node_modules_mpvue_loader_lib_selector_type_script_index_0_index_vue__ = __webpack_require__(145);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__node_modules_mpvue_loader_lib_template_compiler_index_id_data_v_6b29caac_hasScoped_false_transformToRequire_video_src_source_src_img_src_image_xlink_href_fileExt_template_wxml_script_js_style_wxss_platform_wx_node_modules_mpvue_loader_lib_selector_type_template_index_0_index_vue__ = __webpack_require__(161);
var disposed = false
function injectStyle (ssrContext) {
  if (disposed) return
  __webpack_require__(144)
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
  __WEBPACK_IMPORTED_MODULE_1__node_modules_mpvue_loader_lib_template_compiler_index_id_data_v_6b29caac_hasScoped_false_transformToRequire_video_src_source_src_img_src_image_xlink_href_fileExt_template_wxml_script_js_style_wxss_platform_wx_node_modules_mpvue_loader_lib_selector_type_template_index_0_index_vue__["a" /* default */],
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

/***/ 144:
/***/ (function(module, exports) {

// removed by extract-text-webpack-plugin

/***/ }),

/***/ 145:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_babel_runtime_core_js_map__ = __webpack_require__(146);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_babel_runtime_core_js_map___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_0_babel_runtime_core_js_map__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__utils_index__ = __webpack_require__(17);

//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
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
      groupedFriends: [],
      indexList: [],
      addUserId: '',
      result: {},
      scrollTop: 0
    };
  },
  onPageScroll: function onPageScroll(event) {
    this.scrollTop = event.scrollTop;
  },

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

    // 初始化朋友列表
    initFriendsList: function initFriendsList() {
      var _this2 = this;

      wx.$app.getFriendList({
        fromAccount: this.$store.state.user.userProfile.to
      }).then(function (res) {
        var groupedFriends = _this2.groupingFriendList(res.data);
        _this2.groupedFriends = groupedFriends;
        _this2.indexList = groupedFriends.map(function (item) {
          return item.key;
        });
      });
    },
    groupingFriendList: function groupingFriendList(friends) {
      var tempMap = new __WEBPACK_IMPORTED_MODULE_0_babel_runtime_core_js_map___default.a();
      var result = [];
      friends.forEach(function (friend) {
        var name = friend.profile.nick || friend.userID;
        var firstWord = Object(__WEBPACK_IMPORTED_MODULE_1__utils_index__["d" /* pinyin */])(name)[0].toUpperCase();
        if (tempMap.has(firstWord)) {
          tempMap.get(firstWord).push(friend);
        } else {
          tempMap.set(firstWord, [friend]);
        }
      });
      tempMap.forEach(function (friendList, key) {
        result.push({ key: key, friendList: friendList });
      });
      return result.sort(function (a, b) {
        return a.key > b.key ? 1 : -1;
      });
    },
    toProfile: function toProfile(userID) {
      wx.navigateTo({ url: '../user-profile/main?userID=' + userID });
    }
  },
  mounted: function mounted() {
    this.initFriendsList();
  }
});

/***/ }),

/***/ 161:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
var render = function () {var _vm=this;var _h=_vm.$createElement;var _c=_vm._self._c||_h;
  return _c('div', {
    staticClass: "container"
  }, [_c('div', {
    staticClass: "methods"
  }, [_c('i-cell-group', {
    attrs: {
      "mpcomid": '5'
    }
  }, [_c('i-cell', {
    attrs: {
      "title": "发起会话",
      "is-link": "",
      "url": "/pages/search/main?type=user",
      "mpcomid": '0'
    }
  }), _vm._v(" "), _c('i-cell', {
    attrs: {
      "title": "加入群聊",
      "is-link": "",
      "url": "/pages/search/main?type=group",
      "mpcomid": '1'
    }
  }), _vm._v(" "), _c('i-cell', {
    attrs: {
      "title": "新建群聊",
      "is-link": "",
      "url": "/pages/create/main",
      "mpcomid": '2'
    }
  }), _vm._v(" "), _c('i-cell', {
    attrs: {
      "title": "我的黑名单",
      "is-link": "",
      "url": "/pages/blacklist/main",
      "mpcomid": '3'
    }
  }), _vm._v(" "), _c('i-cell', {
    attrs: {
      "title": "我的群组",
      "is-link": "",
      "url": "/pages/groups/main",
      "mpcomid": '4'
    }
  })], 1)], 1), _vm._v(" "), _c('div', {
    staticClass: "friends"
  }, [_c('van-index-bar', {
    attrs: {
      "scroll-top": _vm.scrollTop,
      "index-list": _vm.indexList,
      "mpcomid": '8'
    }
  }, _vm._l((_vm.groupedFriends), function(item, index) {
    return _c('div', {
      key: item.key
    }, [_c('van-index-anchor', {
      attrs: {
        "index": item.key,
        "mpcomid": '6_' + index
      }
    }), _vm._v(" "), _vm._l((item.friendList), function(friend, idx2) {
      return _c('div', {
        key: friend.userID,
        staticClass: "friend-item",
        attrs: {
          "eventid": '0_' + index + '-' + idx2
        },
        on: {
          "click": function($event) {
            _vm.toProfile(friend.userID)
          }
        }
      }, [_c('i-avatar', {
        attrs: {
          "i-class": "avatar",
          "src": friend.profile.avatar,
          "mpcomid": '7_' + index + '-' + idx2
        }
      }), _vm._v(" "), _c('div', {
        staticClass: "username"
      }, [_vm._v(_vm._s(friend.profile.nick || friend.userID))])], 1)
    })], 2)
  }))], 1)])
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

},[142]);