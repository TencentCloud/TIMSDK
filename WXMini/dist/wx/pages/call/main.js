require("../../common/manifest.js")
require("../../common/vendor.js")
global.webpackJsonpMpvue([16],{

/***/ 131:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_vue__ = __webpack_require__(0);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_vue___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_0_vue__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__index__ = __webpack_require__(132);



// add this to handle exception
__WEBPACK_IMPORTED_MODULE_0_vue___default.a.config.errorHandler = function (err) {
  if (console && console.error) {
    console.error(err);
  }
};

var app = new __WEBPACK_IMPORTED_MODULE_0_vue___default.a(__WEBPACK_IMPORTED_MODULE_1__index__["a" /* default */]);
app.$mount();

/***/ }),

/***/ 132:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__babel_loader_node_modules_mpvue_loader_lib_selector_type_script_index_0_index_vue__ = __webpack_require__(134);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__node_modules_mpvue_loader_lib_template_compiler_index_id_data_v_601c8bb0_hasScoped_true_transformToRequire_video_src_source_src_img_src_image_xlink_href_fileExt_template_wxml_script_js_style_wxss_platform_wx_node_modules_mpvue_loader_lib_selector_type_template_index_0_index_vue__ = __webpack_require__(136);
var disposed = false
function injectStyle (ssrContext) {
  if (disposed) return
  __webpack_require__(133)
}
var normalizeComponent = __webpack_require__(1)
/* script */

/* template */

/* styles */
var __vue_styles__ = injectStyle
/* scopeId */
var __vue_scopeId__ = "data-v-601c8bb0"
/* moduleIdentifier (server only) */
var __vue_module_identifier__ = null
var Component = normalizeComponent(
  __WEBPACK_IMPORTED_MODULE_0__babel_loader_node_modules_mpvue_loader_lib_selector_type_script_index_0_index_vue__["a" /* default */],
  __WEBPACK_IMPORTED_MODULE_1__node_modules_mpvue_loader_lib_template_compiler_index_id_data_v_601c8bb0_hasScoped_true_transformToRequire_video_src_source_src_img_src_image_xlink_href_fileExt_template_wxml_script_js_style_wxss_platform_wx_node_modules_mpvue_loader_lib_selector_type_template_index_0_index_vue__["a" /* default */],
  __vue_styles__,
  __vue_scopeId__,
  __vue_module_identifier__
)
Component.options.__file = "src\\pages\\call\\index.vue"
if (Component.esModule && Object.keys(Component.esModule).some(function (key) {return key !== "default" && key.substr(0, 2) !== "__"})) {console.error("named exports are not supported in *.vue files.")}
if (Component.options.functional) {console.error("[vue-loader] index.vue: functional components are not supported with templates, they should use render functions.")}

/* hot reload */
if (false) {(function () {
  var hotAPI = require("vue-hot-reload-api")
  hotAPI.install(require("vue"), false)
  if (!hotAPI.compatible) return
  module.hot.accept()
  if (!module.hot.data) {
    hotAPI.createRecord("data-v-601c8bb0", Component.options)
  } else {
    hotAPI.reload("data-v-601c8bb0", Component.options)
  }
  module.hot.dispose(function (data) {
    disposed = true
  })
})()}

/* harmony default export */ __webpack_exports__["a"] = (Component.exports);


/***/ }),

/***/ 133:
/***/ (function(module, exports) {

// removed by extract-text-webpack-plugin

/***/ }),

/***/ 134:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_babel_runtime_core_js_json_stringify__ = __webpack_require__(54);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_babel_runtime_core_js_json_stringify___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_0_babel_runtime_core_js_json_stringify__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__utils_types__ = __webpack_require__(75);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2__static_utils_GenerateTestUserSig__ = __webpack_require__(53);

//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//



var ERROR_OPEN_CAMERA = -4; // 打开摄像头失败
var ERROR_OPEN_MIC = -5; // 打开麦克风失败
var ERROR_PUSH_DISCONNECT = -6; // 推流连接断开
var ERROR_CAMERA_MIC_PERMISSION = -7; // 获取不到摄像头或者麦克风权限
var ERROR_EXCEEDS_THE_MAX_MEMBER = -8; // 超过最大成员数
var ERROR_REQUEST_ROOM_SIG = -9; // 获取房间SIG错误
var ERROR_JOIN_ROOM = -10; // 进房失败
/* harmony default export */ __webpack_exports__["a"] = ({
  data: function data() {
    return {
      args: {},
      closeFlag: false,
      refuseFlag: false,
      isPending: true,
      isCalling: false,
      frontCamera: false,
      beauty: 0,
      muted: false,
      timeStamp: 0,
      sdkAppID: 0,
      userSig: '',
      userID: '',
      roomID: 0,
      type: '',
      from: '',
      to: '',
      timeoutId: '',
      startTime: 0
    };
  },
  onShow: function onShow() {
    var _this = this;

    // 初始化参数
    var loginOptions = Object(__WEBPACK_IMPORTED_MODULE_2__static_utils_GenerateTestUserSig__["b" /* genTestUserSig */])(this.userID);
    this.userSig = loginOptions.userSig;
    this.sdkAppID = loginOptions.sdkappid;
    this.isCalling = false;
    this.isPending = true;
    // 发起方发起通话，1分钟超时时间
    if (this.userID === this.from) {
      this.timeoutId = setTimeout(function () {
        _this.timeout();
      }, 60000);
    }
    wx.setKeepScreenOn({
      keepScreenOn: true
    });
    this.$store.commit('setCalling', true);
  },
  onUnload: function onUnload() {
    if (!(this.refuseFlag || this.closeFlag)) {
      if (this.isCalling) {
        this.closeRoom();
      } else {
        if (this.type === 'call') {
          this.closeRoom();
        } else {
          this.refuse();
        }
      }
    }
    this.refuseFlag = false;
    this.closeFlag = false;
    this.isCalling = false;
    this.isPending = false;
    clearTimeout(this.timeoutId);
    this.$store.commit('setCalling', false);
  },
  onHide: function onHide() {
    this.isCalling = false;
    this.isPending = false;
    clearTimeout(this.timeoutId);
    this.closeRoom();
    this.$store.commit('setCalling', false);
    // 清理掉监听
    this.$bus.$off('onCall');
    this.$bus.$off('isCalling');
    this.$bus.$off('onClose');
    this.$bus.$off('onRefuse');
    this.$bus.$off('onBusy');
  },
  onLoad: function onLoad(options) {
    var _this2 = this;

    // onLoad的时候监听，在收到某些message的时候会触发的事件，可在main.js里查看事件 emit 条件
    console.log(options);
    this.args = JSON.parse(options.args);
    this.userID = this.$store.getters.myInfo.userID;
    this.from = options.from;
    this.to = options.to;
    this.type = this.userID === this.from ? 'call' : 'onCall';
    this.roomID = this.args.room_id;
    this.$bus.$on('onCall', function () {
      _this2.isCalling = true;
      _this2.isPending = false;
      _this2.startTime = new Date().getTime();
      clearTimeout(_this2.timeoutId);
      _this2.onCall();
    });
    this.$bus.$on('isCalling', function (message) {
      _this2.alreadyCalling(message);
    });
    this.$bus.$on('onClose', function () {
      _this2.closeFlag = true;
      wx.navigateBack({
        delta: 1
      });
    });
    this.$bus.$on('onRefuse', function () {
      _this2.closeFlag = true;
      wx.navigateBack({
        delta: 1
      });
    });
    this.$bus.$on('onBusy', function () {
      _this2.closeFlag = true;
      wx.navigateBack({
        delta: 1
      });
    });
  },

  methods: {
    onRoomEvent: function onRoomEvent(e) {
      if ([ERROR_OPEN_CAMERA, ERROR_OPEN_MIC, ERROR_PUSH_DISCONNECT, ERROR_CAMERA_MIC_PERMISSION, ERROR_EXCEEDS_THE_MAX_MEMBER, ERROR_REQUEST_ROOM_SIG, ERROR_JOIN_ROOM].includes(e.target.code)) {
        this.webrtcroomComponent = this.$mp.page.selectComponent('#webrtcroom');
        this.webrtcroomComponent.stop();
        this.args.action = -2;
        this.args.code = e.target.code;
        var data = __WEBPACK_IMPORTED_MODULE_0_babel_runtime_core_js_json_stringify___default()(this.args);
        // 对方发起视频，接通成功后如果是我挂断的，这时挂断消息应该发给视频发起方
        var to = this.to === this.$store.getters.myInfo.userID ? this.from : this.to;
        var message = wx.$app.createCustomMessage({
          to: to,
          conversationType: __WEBPACK_IMPORTED_MODULE_1__utils_types__["a" /* default */].CONV_C2C,
          payload: {
            data: data,
            description: '',
            extension: ''
          }
        });
        this.$store.commit('sendMessage', message);
        wx.$app.sendMessage(message);
        clearTimeout(this.timeoutId);
      }
      if (e.target.tag === 'error') {
        wx.showToast({
          title: e.target.detail,
          duration: 1000
        });
      }
    },
    handleCloseRoom: function handleCloseRoom() {
      this.closeFlag = true;
      this.closeRoom();
      wx.navigateBack({
        delta: 1
      });
    },
    handleRefuse: function handleRefuse() {
      this.refuseFlag = true;
      this.refuse();
      wx.navigateBack({
        delta: 1
      });
    },

    // 发起方等待时挂断
    closeRoom: function closeRoom() {
      this.webrtcroomComponent = this.$mp.page.selectComponent('#webrtcroom');
      this.webrtcroomComponent.stop();
      this.args.action = 5;
      if (this.startTime === 0) {
        this.args.action = 1;
      }
      if (this.startTime !== 0) {
        var endTime = new Date().getTime();
        this.args.duration = Math.round((endTime - this.startTime) / 1000);
        this.startTime = 0;
      }
      var data = __WEBPACK_IMPORTED_MODULE_0_babel_runtime_core_js_json_stringify___default()(this.args);
      // 对方发起视频，接通成功后如果是我挂断的，这时挂断消息应该发给视频发起方
      var to = this.to === this.$store.getters.myInfo.userID ? this.from : this.to;
      var message = wx.$app.createCustomMessage({
        to: to,
        conversationType: __WEBPACK_IMPORTED_MODULE_1__utils_types__["a" /* default */].CONV_C2C,
        payload: {
          data: data,
          description: '',
          extension: ''
        }
      });
      this.$store.commit('sendMessage', message);
      wx.$app.sendMessage(message);
      clearTimeout(this.timeoutId);
    },

    // 发起方等待接收方超过60s
    timeout: function timeout() {
      this.args.action = 3;
      var data = __WEBPACK_IMPORTED_MODULE_0_babel_runtime_core_js_json_stringify___default()(this.args);
      var message = wx.$app.createCustomMessage({
        to: this.to,
        conversationType: __WEBPACK_IMPORTED_MODULE_1__utils_types__["a" /* default */].CONV_C2C,
        payload: {
          data: data,
          description: '',
          extension: ''
        }
      });
      this.$store.commit('sendMessage', message);
      wx.$app.sendMessage(message);
      wx.navigateBack({
        delta: 1
      });
    },

    // 接受对方的请求
    receive: function receive() {
      this.args.action = 4;
      var data = __WEBPACK_IMPORTED_MODULE_0_babel_runtime_core_js_json_stringify___default()(this.args);
      this.startTime = new Date().getTime();
      var message = wx.$app.createCustomMessage({
        to: this.from,
        conversationType: __WEBPACK_IMPORTED_MODULE_1__utils_types__["a" /* default */].CONV_C2C,
        payload: {
          data: data,
          description: '',
          extension: ''
        }
      });
      this.$store.commit('sendMessage', message);
      wx.$app.sendMessage(message);
      clearTimeout(this.timeoutId);
      this.isCalling = true;
      this.isPending = false;
      this.webrtcroomComponent = this.$mp.page.selectComponent('#webrtcroom');
      this.webrtcroomComponent.start();
    },
    onCall: function onCall() {
      this.webrtcroomComponent = this.$mp.page.selectComponent('#webrtcroom');
      this.webrtcroomComponent.start();
    },

    // 拒绝
    refuse: function refuse() {
      this.args.action = 2;
      var data = __WEBPACK_IMPORTED_MODULE_0_babel_runtime_core_js_json_stringify___default()(this.args);
      var message = wx.$app.createCustomMessage({
        to: this.from,
        conversationType: __WEBPACK_IMPORTED_MODULE_1__utils_types__["a" /* default */].CONV_C2C,
        payload: {
          data: data,
          description: '',
          extension: ''
        }
      });
      this.$store.commit('sendMessage', message);
      this.$store.commit('setCalling', false);
      wx.$app.sendMessage(message);
      clearTimeout(this.timeoutId);
    },
    alreadyCalling: function alreadyCalling(item) {
      var options = JSON.parse(item.payload.data);
      options.action = 6;
      var message = wx.$app.createCustomMessage({
        to: item.from,
        conversationType: __WEBPACK_IMPORTED_MODULE_1__utils_types__["a" /* default */].CONV_C2C,
        payload: {
          data: __WEBPACK_IMPORTED_MODULE_0_babel_runtime_core_js_json_stringify___default()(options),
          description: '',
          extension: ''
        }
      });
      this.$store.commit('sendMessage', message);
      wx.$app.sendMessage(message);
    },
    microphone: function microphone() {
      this.muted = !this.muted;
    },
    monitor: function monitor() {
      this.webrtcroomComponent = this.$mp.page.selectComponent('#webrtcroom');
      this.webrtcroomComponent.switchCamera();
    }
  },
  destory: function destory() {}
});

/***/ }),

/***/ 136:
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
var render = function () {var _vm=this;var _h=_vm.$createElement;var _c=_vm._self._c||_h;
  return _c('div', {
    staticClass: "bg-logo"
  }, [_c('div', {
    staticClass: "bg"
  }, [(!_vm.isCalling) ? _c('div', {
    staticClass: "choose"
  }, [(_vm.type === 'call') ? [_c('div', {
    staticClass: "title"
  }, [_vm._v("呼叫" + _vm._s(_vm.to) + "中")]), _vm._v(" "), _c('div', {
    staticClass: "btn"
  }, [_c('div', {
    staticClass: "close",
    attrs: {
      "eventid": '0'
    },
    on: {
      "click": _vm.handleCloseRoom
    }
  }, [_c('image', {
    staticClass: "operation",
    attrs: {
      "src": "/static/images/close.png"
    }
  })])])] : _vm._e(), _vm._v(" "), (_vm.type === 'onCall') ? [_c('div', {
    staticClass: "title"
  }, [_vm._v(_vm._s(_vm.from) + "正在呼叫")]), _vm._v(" "), _c('div', {
    staticClass: "btn"
  }, [_c('div', {
    staticClass: "close answer",
    attrs: {
      "eventid": '1'
    },
    on: {
      "click": _vm.receive
    }
  }, [_c('image', {
    staticClass: "operation",
    attrs: {
      "src": "/static/images/call.png"
    }
  })]), _vm._v(" "), _c('div', {
    staticClass: "close",
    attrs: {
      "eventid": '2'
    },
    on: {
      "click": _vm.handleRefuse
    }
  }, [_c('image', {
    staticClass: "operation",
    attrs: {
      "src": "/static/images/close.png"
    }
  })])])] : _vm._e()], 2) : _vm._e(), _vm._v(" "), _c('div', {
    staticClass: "call",
    style: (_vm.isCalling ? {
      'display': 'flex',
      'height': '100vh',
      'width': '100vw'
    } : {
      'display': 'none'
    })
  }, [_c('div', {
    staticClass: "room"
  }, [_c('webrtc-room', {
    attrs: {
      "id": "webrtcroom",
      "autoplay": true,
      "enableCamera": true,
      "roomID": _vm.roomID,
      "userID": _vm.userID,
      "userSig": _vm.userSig,
      "sdkAppID": _vm.sdkAppID,
      "beauty": _vm.beauty,
      "muted": _vm.muted,
      "smallViewLeft": "calc(100vw - 30vw - 2vw)",
      "smallViewTop": "20vw",
      "smallViewWidth": "30vw",
      "smallViewHeight": "30vh",
      "eventid": '3',
      "mpcomid": '2'
    },
    on: {
      "RoomEvent": _vm.onRoomEvent
    }
  }), _vm._v(" "), _c('div', {
    staticClass: "panel"
  }, [_c('div', {
    staticClass: "close-btn"
  }, [_c('div', {
    staticClass: "normal",
    attrs: {
      "eventid": '4'
    },
    on: {
      "click": _vm.microphone
    }
  }, [(!_vm.muted) ? _c('image', {
    staticClass: "operation",
    attrs: {
      "src": "/static/images/voice.png"
    }
  }) : _c('image', {
    staticClass: "operation",
    attrs: {
      "src": "/static/images/voice-muted.png"
    }
  })]), _vm._v(" "), _c('div', {
    staticClass: "close",
    attrs: {
      "eventid": '5'
    },
    on: {
      "click": _vm.handleCloseRoom
    }
  }, [_c('image', {
    staticClass: "operation",
    attrs: {
      "src": "/static/images/close.png"
    }
  })]), _vm._v(" "), _c('div', {
    staticClass: "normal",
    attrs: {
      "eventid": '6'
    },
    on: {
      "click": _vm.monitor
    }
  }, [_c('image', {
    staticClass: "operation",
    attrs: {
      "src": "/static/images/monitor.png"
    }
  })])])])], 1)])])])
}
var staticRenderFns = []
render._withStripped = true
var esExports = { render: render, staticRenderFns: staticRenderFns }
/* harmony default export */ __webpack_exports__["a"] = (esExports);
if (false) {
  module.hot.accept()
  if (module.hot.data) {
     require("vue-hot-reload-api").rerender("data-v-601c8bb0", esExports)
  }
}

/***/ })

},[131]);