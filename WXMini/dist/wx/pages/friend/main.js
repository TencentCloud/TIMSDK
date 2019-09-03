require("../../common/manifest.js")
require("../../debug/GenerateTestUserSig.js")
require("../../common/vendor.js")
global.webpackJsonpMpvue([11],{

/***/ "6Ti2":
/***/ (function(module, exports) {

// removed by extract-text-webpack-plugin

/***/ }),

/***/ "80jl":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_vue__ = __webpack_require__("5nAL");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_vue___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_0_vue__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__index__ = __webpack_require__("9pOB");



var app = new __WEBPACK_IMPORTED_MODULE_0_vue___default.a(__WEBPACK_IMPORTED_MODULE_1__index__["a" /* default */]);
app.$mount();

/***/ }),

/***/ "9pOB":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__babel_loader_node_modules_mpvue_loader_lib_selector_type_script_index_0_index_vue__ = __webpack_require__("Hw1X");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__node_modules_mpvue_loader_lib_template_compiler_index_id_data_v_9c65aab0_hasScoped_true_transformToRequire_video_src_source_src_img_src_image_xlink_href_fileExt_template_wxml_script_js_style_wxss_platform_wx_node_modules_mpvue_loader_lib_selector_type_template_index_0_index_vue__ = __webpack_require__("UTx8");
function injectStyle (ssrContext) {
  __webpack_require__("6Ti2")
}
var normalizeComponent = __webpack_require__("ybqe")
/* script */

/* template */

/* styles */
var __vue_styles__ = injectStyle
/* scopeId */
var __vue_scopeId__ = "data-v-9c65aab0"
/* moduleIdentifier (server only) */
var __vue_module_identifier__ = null
var Component = normalizeComponent(
  __WEBPACK_IMPORTED_MODULE_0__babel_loader_node_modules_mpvue_loader_lib_selector_type_script_index_0_index_vue__["a" /* default */],
  __WEBPACK_IMPORTED_MODULE_1__node_modules_mpvue_loader_lib_template_compiler_index_id_data_v_9c65aab0_hasScoped_true_transformToRequire_video_src_source_src_img_src_image_xlink_href_fileExt_template_wxml_script_js_style_wxss_platform_wx_node_modules_mpvue_loader_lib_selector_type_template_index_0_index_vue__["a" /* default */],
  __vue_styles__,
  __vue_scopeId__,
  __vue_module_identifier__
)

/* harmony default export */ __webpack_exports__["a"] = (Component.exports);


/***/ }),

/***/ "Hw1X":
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
      id: '',
      content: ''
    };
  },

  computed: {
    username: function username() {
      return this.$store.state.user.userProfile.to;
    }
  },
  methods: {
    // 发起会话
    createConversation: function createConversation() {
      var _this = this;

      if (this.content !== '' && this.id !== '') {
        var option = {
          userIDList: [this.id]
        };
        wx.$app.getUserProfile(option).then(function (res) {
          console.log(res);
          if (res.data.length > 0) {
            var message = wx.$app.createTextMessage({
              to: _this.id,
              conversationType: _this.TIM.TYPES.CONV_C2C,
              payload: { text: _this.content }
            });
            wx.$app.sendMessage(message).then(function () {
              var conversationID = _this.TIM.TYPES.CONV_C2C + _this.id;
              wx.$app.getConversationProfile(conversationID).then(function (res) {
                _this.$store.commit('resetCurrentConversation');
                _this.$store.commit('resetGroup');
                _this.$store.commit('updateCurrentConversation', res.data.conversation);
                _this.$store.dispatch('getMessageList', conversationID);
                _this.content = '';
                _this.id = '';
                var url = '../chat/main?toAccount=' + (res.data.conversation.userProfile.nick || res.data.conversation.userProfile.userID);
                wx.navigateTo({ url: url });
              }).catch(function (error) {
                console.log(error);
              });
            }).catch(function () {
              _this.$store.commit('showToast', {
                title: '输入内容有误',
                icon: 'none',
                duration: 1000
              });
            });
          } else {
            _this.$store.commit('showToast', {
              title: '用户不存在',
              icon: 'none',
              duration: 1000
            });
            _this.id = '';
            _this.content = '';
          }
        }).catch(function () {
          _this.$store.commit('showToast', {
            title: '用户不存在',
            icon: 'none',
            duration: 1000
          });
          _this.id = '';
          _this.content = '';
        });
      }
    }
  }
});

/***/ }),

/***/ "UTx8":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
var render = function () {var _vm=this;var _h=_vm.$createElement;var _c=_vm._self._c||_h;
  return _c('div', {
    staticClass: "container"
  }, [_c('div', {
    staticClass: "item"
  }, [_c('i-row', {
    attrs: {
      "mpcomid": '2'
    }
  }, [_c('i-col', {
    attrs: {
      "span": "7",
      "offset": "1",
      "mpcomid": '0'
    }
  }, [_c('div', {
    staticClass: "avatar"
  }, [_vm._v("\n            用户ID:\n          ")])]), _vm._v(" "), _c('i-col', {
    attrs: {
      "span": "15",
      "mpcomid": '1'
    }
  }, [_c('input', {
    directives: [{
      name: "model",
      rawName: "v-model",
      value: (_vm.id),
      expression: "id"
    }],
    staticClass: "input",
    attrs: {
      "type": "text",
      "placeholder": "输入接受者ID",
      "eventid": '0'
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
  })])], 1), _vm._v(" "), _c('i-row', {
    attrs: {
      "mpcomid": '5'
    }
  }, [_c('i-col', {
    attrs: {
      "span": "7",
      "offset": "1",
      "mpcomid": '3'
    }
  }, [_c('div', {
    staticClass: "avatar"
  }, [_vm._v("\n            内容：\n          ")])]), _vm._v(" "), _c('i-col', {
    attrs: {
      "span": "15",
      "mpcomid": '4'
    }
  }, [_c('input', {
    directives: [{
      name: "model",
      rawName: "v-model",
      value: (_vm.content),
      expression: "content"
    }],
    staticClass: "input",
    attrs: {
      "type": "text",
      "placeholder": "输入你要发送的内容",
      "eventid": '1'
    },
    domProps: {
      "value": (_vm.content)
    },
    on: {
      "input": function($event) {
        if ($event.target.composing) { return; }
        _vm.content = $event.target.value
      }
    }
  })])], 1), _vm._v(" "), _c('i-row', {
    attrs: {
      "mpcomid": '8'
    }
  }, [_c('i-col', {
    attrs: {
      "span": "16",
      "offset": "4",
      "mpcomid": '7'
    }
  }, [_c('i-button', {
    attrs: {
      "type": "primary",
      "long": "true",
      "shape": "circle",
      "eventid": '2',
      "mpcomid": '6'
    },
    on: {
      "click": function($event) {
        _vm.createConversation()
      }
    }
  }, [_vm._v("发起会话")])], 1)], 1)], 1)])
}
var staticRenderFns = []
var esExports = { render: render, staticRenderFns: staticRenderFns }
/* harmony default export */ __webpack_exports__["a"] = (esExports);

/***/ })

},["80jl"]);