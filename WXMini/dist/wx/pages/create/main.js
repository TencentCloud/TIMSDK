require("../../common/manifest.js")
require("../../debug/GenerateTestUserSig.js")
require("../../common/vendor.js")
global.webpackJsonpMpvue([13],{

/***/ "GU/c":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
var render = function () {var _vm=this;var _h=_vm.$createElement;var _c=_vm._self._c||_h;
  return _c('div', {
    staticClass: "container"
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
    staticClass: "input border center",
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
  })])]), _vm._v(" "), _c('div', {
    staticClass: "title"
  }, [_vm._v("基础信息")]), _vm._v(" "), _c('div', {
    staticClass: "item"
  }, [_c('div', {
    staticClass: "label"
  }, [_vm._v("\n        群ID：\n      ")]), _vm._v(" "), _c('div', [_c('input', {
    directives: [{
      name: "model",
      rawName: "v-model.lazy:value",
      value: (_vm.id),
      expression: "id",
      modifiers: {
        "lazy:value": true
      }
    }],
    staticClass: "input",
    attrs: {
      "type": "text",
      "placeholder": "请输入群ID",
      "eventid": '2'
    },
    domProps: {
      "value": (_vm.id)
    },
    on: {
      "input": function($event) {
        if ($event.target.composing) { return; }
        _vm.id = $event.target.value
      }
    }
  })])]), _vm._v(" "), _c('div', {
    staticClass: "item"
  }, [_c('div', {
    staticClass: "label"
  }, [_vm._v("\n        群名：\n      ")]), _vm._v(" "), _c('div', [_c('input', {
    directives: [{
      name: "model",
      rawName: "v-model.lazy:value",
      value: (_vm.name),
      expression: "name",
      modifiers: {
        "lazy:value": true
      }
    }],
    staticClass: "input",
    attrs: {
      "type": "text",
      "placeholder": "请输入群名",
      "eventid": '3'
    },
    domProps: {
      "value": (_vm.name)
    },
    on: {
      "input": function($event) {
        if ($event.target.composing) { return; }
        _vm.name = $event.target.value
      }
    }
  })])]), _vm._v(" "), _c('div', {
    staticClass: "item"
  }, [_c('div', {
    staticClass: "label"
  }, [_vm._v("\n        群头像：\n      ")]), _vm._v(" "), _c('div', [_c('input', {
    directives: [{
      name: "model",
      rawName: "v-model.lazy:value",
      value: (_vm.avatar),
      expression: "avatar",
      modifiers: {
        "lazy:value": true
      }
    }],
    staticClass: "input",
    attrs: {
      "type": "text",
      "placeholder": "请输入群头像",
      "eventid": '4'
    },
    domProps: {
      "value": (_vm.avatar)
    },
    on: {
      "input": function($event) {
        if ($event.target.composing) { return; }
        _vm.avatar = $event.target.value
      }
    }
  })])]), _vm._v(" "), _c('div', {
    staticClass: "item"
  }, [_c('div', {
    staticClass: "label"
  }, [_vm._v("\n        群简介：\n      ")]), _vm._v(" "), _c('div', [_c('input', {
    directives: [{
      name: "model",
      rawName: "v-model.lazy:value",
      value: (_vm.introduction),
      expression: "introduction",
      modifiers: {
        "lazy:value": true
      }
    }],
    staticClass: "input",
    attrs: {
      "type": "text",
      "placeholder": "请输入群简介",
      "eventid": '5'
    },
    domProps: {
      "value": (_vm.introduction)
    },
    on: {
      "input": function($event) {
        if ($event.target.composing) { return; }
        _vm.introduction = $event.target.value
      }
    }
  })])]), _vm._v(" "), _c('div', {
    staticClass: "item"
  }, [_c('div', {
    staticClass: "label"
  }, [_vm._v("\n        群公告：\n      ")]), _vm._v(" "), _c('div', [_c('input', {
    directives: [{
      name: "model",
      rawName: "v-model.lazy:value",
      value: (_vm.notice),
      expression: "notice",
      modifiers: {
        "lazy:value": true
      }
    }],
    staticClass: "input",
    attrs: {
      "type": "text",
      "placeholder": "请输入群公告",
      "eventid": '6'
    },
    domProps: {
      "value": (_vm.notice)
    },
    on: {
      "input": function($event) {
        if ($event.target.composing) { return; }
        _vm.notice = $event.target.value
      }
    }
  })])]), _vm._v(" "), _c('div', {
    staticClass: "type"
  }, [_c('div', {
    staticClass: "title"
  }, [_vm._v("\n        群类型：\n      ")]), _vm._v(" "), _c('div', {
    staticClass: "choose"
  }, [_c('i-radio-group', {
    attrs: {
      "current": _vm.currentType,
      "eventid": '7',
      "mpcomid": '5'
    },
    on: {
      "change": _vm.handleTypeChange
    }
  }, [_c('i-radio', {
    attrs: {
      "value": "Private",
      "mpcomid": '1'
    }
  }), _vm._v(" "), _c('i-radio', {
    attrs: {
      "value": "Public",
      "mpcomid": '2'
    }
  }), _vm._v(" "), _c('i-radio', {
    attrs: {
      "value": "ChatRoom",
      "mpcomid": '3'
    }
  }), _vm._v(" "), _c('i-radio', {
    attrs: {
      "value": "AVChatRoom",
      "mpcomid": '4'
    }
  })], 1)], 1)]), _vm._v(" "), (_vm.currentType !== 'Private' && _vm.currentType !== 'AVChatRoom') ? _c('div', {
    staticClass: "type"
  }, [_c('div', {
    staticClass: "title"
  }, [_vm._v("\n        加群方式：\n      ")]), _vm._v(" "), _c('div', {
    staticClass: "choose"
  }, [_c('i-radio-group', {
    attrs: {
      "current": _vm.addType,
      "eventid": '8',
      "mpcomid": '9'
    },
    on: {
      "change": _vm.handleAddTypeChange
    }
  }, [_c('i-radio', {
    attrs: {
      "value": "自由加群",
      "mpcomid": '6'
    }
  }), _vm._v(" "), _c('i-radio', {
    attrs: {
      "value": "需要验证",
      "mpcomid": '7'
    }
  }), _vm._v(" "), _c('i-radio', {
    attrs: {
      "value": "禁止加群",
      "mpcomid": '8'
    }
  })], 1)], 1)]) : _vm._e(), _vm._v(" "), _c('div', {
    staticClass: "type"
  }, [_c('div', {
    staticClass: "title"
  }, [_vm._v("\n        群成员列表"), _c('span', {
    staticClass: "adding",
    attrs: {
      "eventid": '9'
    },
    on: {
      "click": _vm.handleModalShow
    }
  }, [_vm._v("添加成员")])])]), _vm._v(" "), (_vm.memberList.length === 0) ? _c('div', {
    staticClass: "temp"
  }) : _vm._e(), _vm._v(" "), _vm._l((_vm.memberList), function(item, index) {
    return _c('div', {
      key: item.userID,
      staticClass: "item"
    }, [_c('div', {
      staticClass: "add-label"
    }, [_vm._v("\n        " + _vm._s(item.nick || '无昵称') + "\n      ")]), _vm._v(" "), _c('div', {
      staticClass: "add-label"
    }, [_vm._v("\n        " + _vm._s(item.userID) + "\n      ")]), _vm._v(" "), _c('div', {
      staticClass: "delete",
      attrs: {
        "eventid": '10_' + index
      },
      on: {
        "click": function($event) {
          _vm.deleteMember(item)
        }
      }
    }, [_c('i-avatar', {
      attrs: {
        "src": "../../../static/images/delete.png",
        "mpcomid": '10_' + index
      }
    })], 1)])
  }), _vm._v(" "), _c('i-row', {
    attrs: {
      "mpcomid": '12'
    }
  }, [_c('i-col', {
    attrs: {
      "span": "24",
      "mpcomid": '11'
    }
  }, [_c('button', {
    staticClass: "button success",
    attrs: {
      "type": "button",
      "eventid": '11'
    },
    on: {
      "click": _vm.createGroup
    }
  }, [_vm._v("确定创建")]), _vm._v(" "), _c('button', {
    staticClass: "button fail",
    attrs: {
      "type": "button",
      "eventid": '12'
    },
    on: {
      "click": _vm.empty
    }
  }, [_vm._v("清空")])], 1)], 1)], 2)
}
var staticRenderFns = []
var esExports = { render: render, staticRenderFns: staticRenderFns }
/* harmony default export */ __webpack_exports__["a"] = (esExports);

/***/ }),

/***/ "TIXD":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_vue__ = __webpack_require__("5nAL");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_vue___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_0_vue__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__index__ = __webpack_require__("qy7V");



var app = new __WEBPACK_IMPORTED_MODULE_0_vue___default.a(__WEBPACK_IMPORTED_MODULE_1__index__["a" /* default */]);
app.$mount();

/***/ }),

/***/ "gQ1t":
/***/ (function(module, exports) {

// removed by extract-text-webpack-plugin

/***/ }),

/***/ "qy7V":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__babel_loader_node_modules_mpvue_loader_lib_selector_type_script_index_0_index_vue__ = __webpack_require__("xNvV");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__node_modules_mpvue_loader_lib_template_compiler_index_id_data_v_e2ba38f4_hasScoped_true_transformToRequire_video_src_source_src_img_src_image_xlink_href_fileExt_template_wxml_script_js_style_wxss_platform_wx_node_modules_mpvue_loader_lib_selector_type_template_index_0_index_vue__ = __webpack_require__("GU/c");
function injectStyle (ssrContext) {
  __webpack_require__("gQ1t")
}
var normalizeComponent = __webpack_require__("ybqe")
/* script */

/* template */

/* styles */
var __vue_styles__ = injectStyle
/* scopeId */
var __vue_scopeId__ = "data-v-e2ba38f4"
/* moduleIdentifier (server only) */
var __vue_module_identifier__ = null
var Component = normalizeComponent(
  __WEBPACK_IMPORTED_MODULE_0__babel_loader_node_modules_mpvue_loader_lib_selector_type_script_index_0_index_vue__["a" /* default */],
  __WEBPACK_IMPORTED_MODULE_1__node_modules_mpvue_loader_lib_template_compiler_index_id_data_v_e2ba38f4_hasScoped_true_transformToRequire_video_src_source_src_img_src_image_xlink_href_fileExt_template_wxml_script_js_style_wxss_platform_wx_node_modules_mpvue_loader_lib_selector_type_template_index_0_index_vue__["a" /* default */],
  __vue_styles__,
  __vue_scopeId__,
  __vue_module_identifier__
)

/* harmony default export */ __webpack_exports__["a"] = (Component.exports);


/***/ }),

/***/ "xNvV":
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

/* harmony default export */ __webpack_exports__["a"] = ({
  data: function data() {
    return {
      id: '',
      name: '',
      content: '',
      currentType: this.$type.GRP_PRIVATE,
      avatar: '',
      introduction: '',
      notice: '',
      addType: '自由加群',
      memberList: [],
      addModalVisible: false,
      addUserId: ''
    };
  },

  computed: {
    username: function username() {
      return this.$store.state.user.userProfile.to;
    }
  },
  methods: {
    // 创建群组
    createGroup: function createGroup() {
      var _this = this;

      if (this.name) {
        var list = this.memberList.map(function (userID) {
          return { userID: userID.userID };
        });
        var adding = void 0;
        switch (this.addType) {
          case '自由加群':
            adding = this.$type.JOIN_OPTIONS_FREE_ACCESS;
            break;
          case '禁止加群':
            adding = this.$type.JOIN_OPTIONS_DISABLE_APPLY;
            break;
          case '需要验证':
            adding = this.$type.JOIN_OPTIONS_NEED_PERMISSION;
            break;
        }
        var options = void 0;
        if (this.currentType !== this.TIM.TYPES.GRP_PRIVATE && this.currentType !== this.TIM.TYPES.GRP_AVCHATROOM) {
          adding = this.currentType === this.TIM.TYPES.GRP_AVCHATROOM ? this.$type.JOIN_OPTIONS_FREE_ACCESS : adding;
          options = {
            groupID: this.id,
            name: this.name,
            type: this.currentType,
            avatar: this.avatar,
            introduction: this.introduction,
            notification: this.notice,
            joinOption: adding,
            memberList: list
          };
        } else {
          options = {
            groupID: this.id,
            name: this.name,
            type: this.currentType,
            avatar: this.avatar,
            introduction: this.introduction,
            notification: this.notice,
            memberList: list
          };
        }
        wx.$app.createGroup(options).then(function () {
          _this.$store.commit('showToast', {
            title: '创建成功',
            icon: 'success',
            duration: 1500
          });
          _this.empty();
          wx.switchTab({
            url: '../index/main'
          });
        }).catch(function (err) {
          console.log(err);
        });
      } else {
        this.$store.commit('showToast', {
          title: '请输入群名'
        });
      }
    },
    handleTypeChange: function handleTypeChange(e) {
      this.currentType = e.target.value;
    },
    handleAddTypeChange: function handleAddTypeChange(e) {
      this.addType = e.target.value;
    },

    // 添加群成员modal
    handleModalShow: function handleModalShow() {
      this.addModalVisible = !this.addModalVisible;
    },

    // 添加群成员
    handleAdd: function handleAdd() {
      var _this2 = this;

      if (this.addUserId) {
        wx.$app.getUserProfile({
          userIDList: [this.addUserId]
        }).then(function (res) {
          _this2.addUserId = '';
          if (res.data.length > 0) {
            _this2.handleModalShow();
            _this2.memberList.push(res.data[0]);
            _this2.$store.commit('showToast', {
              title: '添加成功',
              icon: 'none',
              duration: 1500
            });
          } else {
            _this2.$store.commit('showToast', {
              title: '没有找到该用户',
              icon: 'none',
              duration: 1500
            });
          }
        }).catch(function () {
          _this2.$store.commit('showToast', {
            title: '没有找到该用户',
            icon: 'none',
            duration: 1500
          });
        });
      } else {
        this.$store.commit('showToast', {
          title: 'ID不能为空'
        });
      }
    },

    // 删除成员
    deleteMember: function deleteMember(item) {
      this.memberList = this.memberList.filter(function (member) {
        return member.userID !== item.userID;
      });
    },

    // 清空所有的信息
    empty: function empty() {
      this.id = '';
      this.name = '';
      this.currentType = '';
      this.avatar = '';
      this.introduction = '';
      this.notice = '';
      this.addType = '';
      this.memberList = [];
      this.addModalVisible = false;
    }
  }
});

/***/ })

},["TIXD"]);