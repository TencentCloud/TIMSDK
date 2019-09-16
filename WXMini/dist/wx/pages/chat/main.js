require("../../common/manifest.js")
require("../../debug/GenerateTestUserSig.js")
require("../../common/vendor.js")
global.webpackJsonpMpvue([15],{

/***/ "4USg":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0__babel_loader_node_modules_mpvue_loader_lib_selector_type_script_index_0_index_vue__ = __webpack_require__("Bi6f");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__node_modules_mpvue_loader_lib_template_compiler_index_id_data_v_afeb3abc_hasScoped_true_transformToRequire_video_src_source_src_img_src_image_xlink_href_fileExt_template_wxml_script_js_style_wxss_platform_wx_node_modules_mpvue_loader_lib_selector_type_template_index_0_index_vue__ = __webpack_require__("xEbn");
function injectStyle (ssrContext) {
  __webpack_require__("tqfE")
}
var normalizeComponent = __webpack_require__("ybqe")
/* script */

/* template */

/* styles */
var __vue_styles__ = injectStyle
/* scopeId */
var __vue_scopeId__ = "data-v-afeb3abc"
/* moduleIdentifier (server only) */
var __vue_module_identifier__ = null
var Component = normalizeComponent(
  __WEBPACK_IMPORTED_MODULE_0__babel_loader_node_modules_mpvue_loader_lib_selector_type_script_index_0_index_vue__["a" /* default */],
  __WEBPACK_IMPORTED_MODULE_1__node_modules_mpvue_loader_lib_template_compiler_index_id_data_v_afeb3abc_hasScoped_true_transformToRequire_video_src_source_src_img_src_image_xlink_href_fileExt_template_wxml_script_js_style_wxss_platform_wx_node_modules_mpvue_loader_lib_selector_type_template_index_0_index_vue__["a" /* default */],
  __vue_styles__,
  __vue_scopeId__,
  __vue_module_identifier__
)

/* harmony default export */ __webpack_exports__["a"] = (Component.exports);


/***/ }),

/***/ "Bi6f":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_babel_runtime_helpers_extends__ = __webpack_require__("Dd8w");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_babel_runtime_helpers_extends___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_0_babel_runtime_helpers_extends__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1_vuex__ = __webpack_require__("NYxO");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_2__utils_emojiMap__ = __webpack_require__("lRgn");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_3__utils_index__ = __webpack_require__("0xDb");

//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//




var audioContext = wx.createInnerAudioContext();
var recorderManager = wx.getRecorderManager();
var recordOptions = {
  duration: 60000,
  sampleRate: 44100,
  numberOfChannels: 1,
  encodeBitRate: 192000,
  format: 'mp3'
};
/* harmony default export */ __webpack_exports__["a"] = ({
  data: function data() {
    return {
      messageContent: '',
      conversation: {},
      messageKey: '',
      lastMsgTime: '',
      count: 15,
      isEmojiOpen: false,
      isMoreOpen: false,
      isFocus: false,
      isGroup: false,
      messageList: [],
      emojiName: __WEBPACK_IMPORTED_MODULE_2__utils_emojiMap__["b" /* emojiName */],
      emojiMap: __WEBPACK_IMPORTED_MODULE_2__utils_emojiMap__["a" /* emojiMap */],
      emojiUrl: __WEBPACK_IMPORTED_MODULE_2__utils_emojiMap__["c" /* emojiUrl */],
      height: 0,
      modalVisible: false,
      downloadInfo: {},
      percent: 0,
      sysInfo: {},
      customModalVisible: false,
      customData: '',
      customDescription: '',
      customExtension: '',
      safeBottom: 34,
      isIpx: false,
      isRecord: false,
      isRecording: false
    };
  },
  onLoad: function onLoad(options) {
    var _this = this;

    this.set = options.toAccount;
    // 设置header——聊天对象昵称或群名
    wx.setNavigationBarTitle({
      title: this.set
    });
    var sysInfo = wx.getSystemInfoSync();
    this.sysInfo = sysInfo;
    this.height = sysInfo.windowHeight;
    this.isIpx = sysInfo.model.indexOf('iPhone X') > -1;
    var query = wx.createSelectorQuery();
    var that = this;
    wx.$app.on(this.TIM.EVENT.MESSAGE_RECEIVED, function () {
      query.select('#chat').boundingClientRect(function (res) {
        if (res.bottom - that.height < 150) {
          that.scrollToBottom();
        }
      }).exec();
    });
    var interval = setInterval(function () {
      if (_this.currentMessageList.length !== 0) {
        _this.scrollToBottom();
        clearInterval(interval);
      }
    }, 600);
    this.$bus.$off('atUser');
    this.$bus.$on('atUser', function (user) {
      _this.messageContent += user.userID;
      _this.messageContent += ' ';
    });
    recorderManager.onStart(function () {
      console.log('recorder start');
      wx.showLoading({
        title: '正在录音'
      });
    });
    recorderManager.onPause(function () {
      console.log('recorder pause');
    });
    recorderManager.onStop(function (res) {
      console.log('recorder stop', res);
      wx.hideLoading();
      var message = wx.$app.createSoundMessage({
        to: _this.$store.getters.toAccount,
        conversationType: _this.$store.getters.currentConversationType,
        payload: {
          file: res
        }
      });
      console.log(121212, message);
      wx.$app.sendMessage(message);
    });
  },

  // 退出聊天页面的时候所有状态清空
  onUnload: function onUnload() {
    wx.$app.setMessageRead({ conversationID: this.$store.state.conversation.currentConversationID });
    this.isEmojiOpen = false;
    this.isMoreOpen = false;
    this.messageContent = '';
    var unWatch = this.$watch('messageContent', function (e) {
      if (e.slice(-1) === '@') {
        var url = '../mention/main?';
        wx.navigateTo({ url: url });
      }
    });
    // app.$watch调用后会返回一个值，就是unWatch方法
    // 注销 watch 只要调用unWatch方法就可以了。
    unWatch(); // 手动注销watch
  },
  onPullDownRefresh: function onPullDownRefresh() {
    Object(__WEBPACK_IMPORTED_MODULE_3__utils_index__["b" /* throttle */])(this.getMessageList, 1000)();
  },

  computed: __WEBPACK_IMPORTED_MODULE_0_babel_runtime_helpers_extends___default()({}, Object(__WEBPACK_IMPORTED_MODULE_1_vuex__["b" /* mapState */])({
    currentMessageList: function currentMessageList(state) {
      return state.conversation.currentMessageList;
    }
  })),
  methods: {
    chooseRecord: function chooseRecord() {
      this.isRecord = !this.isRecord;
    },
    startRecording: function startRecording() {
      var _this2 = this;

      wx.getSetting({
        success: function success(res) {
          var auth = res.authSetting['scope.record'];
          if (auth === false) {
            // 已申请过授权，但是用户拒绝
            wx.openSetting({
              success: function success(res) {
                var auth = res.authSetting['scope.record'];
                if (auth === true) {
                  wx.showToast({
                    title: '授权成功',
                    icon: 'success',
                    duration: 1500
                  });
                } else {
                  wx.showToast({
                    title: '授权失败',
                    icon: 'none',
                    duration: 1500
                  });
                }
              }
            });
          } else if (auth === true) {
            // 用户已经同意授权
            _this2.isRecording = true;
            recorderManager.start(recordOptions);
          } else {
            // 第一次进来，未发起授权
            wx.authorize({
              scope: 'scope.record',
              success: function success() {
                wx.showToast({
                  title: '授权成功',
                  icon: 'success',
                  duration: 1500
                });
              }
            });
          }
        },
        fail: function fail() {
          wx.showToast({
            title: '授权失败',
            icon: 'none',
            duration: 1500
          });
        }
      });
    },
    stopRecording: function stopRecording() {
      this.isRecording = false;
      recorderManager.stop();
    },

    // 滚动到列表bottom
    scrollToBottom: function scrollToBottom() {
      wx.pageScrollTo({
        scrollTop: 99999
      });
    },
    customModal: function customModal() {
      this.customModalVisible = !this.customModalVisible;
    },
    sendCustomMessage: function sendCustomMessage() {
      if (this.customData.length === 0 && this.customDescription.length === 0 && this.customExtension.length === 0) {
        this.$store.commit('showToast', {
          title: '不能为空'
        });
        return;
      }
      var message = wx.$app.createCustomMessage({
        to: this.$store.getters.toAccount,
        conversationType: this.$store.getters.currentConversationType,
        payload: {
          data: this.customData,
          description: this.customDescription,
          extension: this.customExtension
        }
      });
      this.$store.commit('sendMessage', message);
      wx.$app.sendMessage(message);
      this.customModal();
      this.customData = '';
      this.customDescription = '';
      this.customExtension = '';
    },

    // 失去焦点
    loseFocus: function loseFocus() {
      this.handleClose();
    },

    // 下载文件模态框
    handleModalShow: function handleModalShow() {
      this.modalVisible = !this.modalVisible;
    },
    handleDownload: function handleDownload(message) {
      this.percent = 0;
      this.downloadInfo = message;
      this.handleModalShow();
    },
    download: function download() {
      var that = this;
      var downloadTask = wx.downloadFile({
        url: that.downloadInfo.fileUrl,
        success: function success(res) {
          console.log('start downloading: ', res);
        },
        fail: function fail(_ref) {
          var errMsg = _ref.errMsg;

          console.log('downloadFile fail, err is:', errMsg);
          that.$store.commit('showToast', {
            title: '文件下载出错',
            icon: 'none',
            duration: 1500
          });
          that.handleModalShow();
        },
        complete: function complete(res) {
          downloadTask = null;
          wx.openDocument({
            filePath: res.tempFilePath,
            success: function success(res) {
              console.log('open file fail', res);
              that.$store.commit('showToast', {
                title: '打开文档成功',
                icon: 'none',
                duration: 1000
              });
              that.percent = 0;
              that.handleModalShow();
            },
            fail: function fail(err) {
              console.log('open file fail', err);
              that.$store.commit('showToast', {
                title: '小程序不支持该文件预览哦',
                icon: 'none',
                duration: 2000
              });
              that.handleModalShow();
            }
          });
        }
      });
      downloadTask.onProgressUpdate(function (res) {
        that.percent = res.progress;
      });
    },

    // 群简介或者人简介
    toDetail: function toDetail() {
      var _this3 = this;

      var conversationID = this.$store.state.conversation.currentConversationID;
      this.isGroup = conversationID.indexOf(this.TIM.TYPES.CONV_GROUP) === 0;
      if (!this.isGroup) {
        var id = conversationID.substring(3);
        var option = {
          userIDList: [id]
        };
        wx.$app.getUserProfile(option).then(function (res) {
          var userProfile = res.data[0];
          switch (userProfile.gender) {
            case _this3.TIM.TYPES.GENDER_UNKNOWN:
              userProfile.gender = _this3.$type.GENDER_UNKNOWN;
              break;
            case _this3.TIM.TYPES.GENDER_MALE:
              userProfile.gender = _this3.$type.GENDER_MALE;
              break;
            case _this3.TIM.TYPES.GENDER_FEMALE:
              userProfile.gender = _this3.$type.GENDER_FEMALE;
              break;
          }
          _this3.$store.commit('updateUserProfile', userProfile);
          var url = '../detail/main';
          wx.navigateTo({ url: url });
        });
      } else {
        var url = '../groupDetail/main';
        wx.navigateTo({ url: url });
      }
    },

    // 获取消息
    getMessageList: function getMessageList() {
      this.$store.dispatch('getMessageList');
      wx.stopPullDownRefresh();
    },

    // 处理emoji选项卡
    handleEmoji: function handleEmoji() {
      if (this.isFocus) {
        this.isFocus = false;
        this.isEmojiOpen = true;
      } else {
        this.isEmojiOpen = !this.isEmojiOpen;
        this.isMoreOpen = false;
      }
    },

    // 处理更多选项卡
    handleMore: function handleMore() {
      if (this.isFocus) {
        this.isFocus = false;
        this.isMoreOpen = true;
      } else {
        this.isMoreOpen = !this.isMoreOpen;
        this.isEmojiOpen = false;
      }
    },

    // 选项卡关闭
    handleClose: function handleClose() {
      this.isFocus = false;
      this.isMoreOpen = false;
      this.isEmojiOpen = false;
    },
    isnull: function isnull(content) {
      if (content === '') {
        return true;
      }
      var reg = '^[ ]+$';
      var re = new RegExp(reg);
      return re.test(content);
    },

    // 发送text message 包含 emoji
    sendMessage: function sendMessage() {
      var _this4 = this;

      if (!this.isnull(this.messageContent)) {
        var message = wx.$app.createTextMessage({
          to: this.$store.getters.toAccount,
          conversationType: this.$store.getters.currentConversationType,
          payload: { text: this.messageContent }
        });
        var index = this.$store.state.conversation.currentMessageList.length;
        this.$store.commit('sendMessage', message);
        wx.$app.sendMessage(message).catch(function () {
          _this4.$store.commit('changeMessageStatus', index);
        });
        this.messageContent = '';
      } else {
        this.$store.commit('showToast', { title: '消息不能为空' });
      }
      this.isFocus = false;
      this.isEmojiOpen = false;
      this.isMoreOpen = false;
    },
    sendPhoto: function sendPhoto(name) {
      var self = this;
      if (name === 'album') {
        this.chooseImage(name);
      } else if (name === 'camera') {
        wx.getSetting({
          success: function success(res) {
            if (!res.authSetting['scope.camera']) {
              // 无权限，跳转设置权限页面
              wx.authorize({
                scope: 'scope.camera',
                success: function success() {
                  self.chooseImage(name);
                }
              });
            } else {
              self.chooseImage(name);
            }
          }
        });
      }
    },
    chooseImage: function chooseImage(name) {
      var self = this;
      var message = {};
      wx.chooseImage({
        sourceType: [name],
        count: 1,
        success: function success(res) {
          message = wx.$app.createImageMessage({
            to: self.$store.getters.toAccount,
            conversationType: self.$store.getters.currentConversationType,
            payload: {
              file: res
            },
            onProgress: function onProgress(percent) {
              self.percent = percent;
            }
          });
          self.$store.commit('sendMessage', message);
          wx.$app.sendMessage(message).then(function () {
            self.percent = 0;
          }).catch(function (err) {
            console.log(err);
          });
        }
      });
      this.handleClose();
    },
    previewImage: function previewImage(src) {
      wx.previewImage({
        current: src, // 当前显示图片的http链接
        urls: [src]
      });
    },

    // 发消息选中emoji
    chooseEmoji: function chooseEmoji(item) {
      this.messageContent += item;
    },

    // 重发消息
    handleResend: function handleResend(message) {
      if (message.status === 'fail') {
        wx.$app.resendMessage(message);
      }
    },

    // 掷骰子也是自定义消息
    dice: function dice() {
      var message = wx.$app.createCustomMessage({
        to: this.$store.getters.toAccount,
        conversationType: this.$store.getters.currentConversationType,
        payload: {
          data: 'dice',
          description: String((Math.random() * 10).toFixed(0) % 6 + 1),
          extension: ''
        }
      });
      this.$store.commit('sendMessage', message);
      wx.$app.sendMessage(message);
      this.handleClose();
    },

    // 播放音频
    openAudio: function openAudio(audio) {
      var that = this;
      audioContext.src = audio.url;
      audioContext.play();
      audioContext.onPlay(function () {});
      audioContext.onEnded(function () {
        wx.hideToast();
      });
      audioContext.onError(function () {
        that.$store.commit('showToast', {
          title: '小程序暂不支持播放该音频格式',
          icon: 'none',
          duration: 2000
        });
      });
    }
  },
  mounted: function mounted() {
    this.$watch('messageContent', function (e) {
      if (this.$store.state.conversation.currentConversation.type === this.TIM.TYPES.CONV_GROUP) {
        if (e.slice(-1) === '@') {
          var url = '../mention/main';
          wx.navigateTo({ url: url });
        }
      }
    });
  }
});

/***/ }),

/***/ "cSaW":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
Object.defineProperty(__webpack_exports__, "__esModule", { value: true });
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_vue__ = __webpack_require__("5nAL");
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_0_vue___default = __webpack_require__.n(__WEBPACK_IMPORTED_MODULE_0_vue__);
/* harmony import */ var __WEBPACK_IMPORTED_MODULE_1__index__ = __webpack_require__("4USg");



var app = new __WEBPACK_IMPORTED_MODULE_0_vue___default.a(__WEBPACK_IMPORTED_MODULE_1__index__["a" /* default */]);
app.$mount();

/***/ }),

/***/ "tqfE":
/***/ (function(module, exports) {

// removed by extract-text-webpack-plugin

/***/ }),

/***/ "xEbn":
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
var render = function () {var _vm=this;var _h=_vm.$createElement;var _c=_vm._self._c||_h;
  return _c('div', {
    staticClass: "chat",
    style: ({
      paddingBottom: _vm.isIpx ? (_vm.safeBottom + 40) + 'px' : '40px'
    }),
    attrs: {
      "id": "chat"
    }
  }, [_c('div', {
    staticClass: "nav",
    attrs: {
      "eventid": '0'
    },
    on: {
      "click": _vm.toDetail
    }
  }, [_vm._v("\n      查看资料\n    ")]), _vm._v(" "), _c('i-modal', {
    attrs: {
      "title": "确认下载？",
      "visible": _vm.modalVisible,
      "eventid": '1',
      "mpcomid": '0'
    },
    on: {
      "ok": _vm.download,
      "cancel": _vm.handleModalShow
    }
  }, [_c('div', {
    staticClass: "input-wrapper"
  }, [_vm._v("\n        进度" + _vm._s(_vm.percent) + "%\n      ")])]), _vm._v(" "), _c('i-modal', {
    attrs: {
      "title": "发送自定义消息",
      "i-class": "custom-modal",
      "visible": _vm.customModalVisible,
      "eventid": '5',
      "mpcomid": '1'
    },
    on: {
      "ok": _vm.sendCustomMessage,
      "cancel": _vm.customModal
    }
  }, [_c('div', {
    staticClass: "custom-wrapper"
  }, [_c('input', {
    directives: [{
      name: "model",
      rawName: "v-model.lazy:value",
      value: (_vm.customData),
      expression: "customData",
      modifiers: {
        "lazy:value": true
      }
    }],
    staticClass: "custom-input",
    attrs: {
      "type": "text",
      "placeholder": "输入数据",
      "eventid": '2'
    },
    domProps: {
      "value": (_vm.customData)
    },
    on: {
      "input": function($event) {
        if ($event.target.composing) { return; }
        _vm.customData = $event.target.value
      }
    }
  }), _vm._v(" "), _c('input', {
    directives: [{
      name: "model",
      rawName: "v-model.lazy:value",
      value: (_vm.customDescription),
      expression: "customDescription",
      modifiers: {
        "lazy:value": true
      }
    }],
    staticClass: "custom-input",
    attrs: {
      "type": "text",
      "placeholder": "输入描述",
      "eventid": '3'
    },
    domProps: {
      "value": (_vm.customDescription)
    },
    on: {
      "input": function($event) {
        if ($event.target.composing) { return; }
        _vm.customDescription = $event.target.value
      }
    }
  }), _vm._v(" "), _c('input', {
    directives: [{
      name: "model",
      rawName: "v-model.lazy:value",
      value: (_vm.customExtension),
      expression: "customExtension",
      modifiers: {
        "lazy:value": true
      }
    }],
    staticClass: "custom-input",
    attrs: {
      "type": "text",
      "placeholder": "输入其他",
      "eventid": '4'
    },
    domProps: {
      "value": (_vm.customExtension)
    },
    on: {
      "input": function($event) {
        if ($event.target.composing) { return; }
        _vm.customExtension = $event.target.value
      }
    }
  })])]), _vm._v(" "), _c('div', {
    attrs: {
      "id": "list",
      "eventid": '10'
    },
    on: {
      "click": _vm.loseFocus
    }
  }, _vm._l((_vm.currentMessageList), function(message, index) {
    return _c('li', {
      key: message.ID,
      attrs: {
        "id": message.ID
      }
    }, [(message.type === 'TIMGroupTipElem' || message.type === 'TIMGroupSystemNoticeElem') ? _c('div', {
      staticClass: "notice"
    }, [_c('div', {
      staticClass: "content"
    }, _vm._l((message.virtualDom), function(div, index1) {
      return _c('span', {
        key: message.ID + index1
      }, [(div.name === 'groupTip' || 'system') ? _c('span', [_vm._v(_vm._s(div.text))]) : _vm._e()])
    }))]) : _c('div', {
      class: (message.flow === 'out') ? 'item-right' : 'item-left'
    }, [_c('div', {
      staticClass: "load",
      attrs: {
        "eventid": '6_' + index
      },
      on: {
        "click": function($event) {
          _vm.handleResend(message)
        }
      }
    }, [_c('div', {
      class: message.status
    })]), _vm._v(" "), _c('div', {
      staticClass: "content"
    }, [_c('div', {
      staticClass: "name"
    }, [_vm._v("\n              " + _vm._s(message.nick || message.from) + "\n            ")]), _vm._v(" "), (message.type === 'TIMTextElem') ? _c('div', {
      staticClass: "message"
    }, [_c('div', {
      staticClass: "text-message"
    }, _vm._l((message.virtualDom), function(div, index2) {
      return _c('span', {
        key: message.ID + index2
      }, [(div.name === 'span') ? _c('span', [_vm._v(_vm._s(div.text))]) : _vm._e(), _vm._v(" "), (div.name === 'img') ? _c('image', {
        staticStyle: {
          "width": "20px",
          "height": "20px"
        },
        attrs: {
          "src": div.src
        }
      }) : _vm._e()])
    }))]) : (message.type === 'TIMImageElem') ? _c('div', {
      staticClass: "message",
      attrs: {
        "eventid": '7_' + index
      },
      on: {
        "click": function($event) {
          _vm.previewImage(message.payload.imageInfoArray[1].url)
        }
      }
    }, [_c('image', {
      staticClass: "img",
      staticStyle: {
        "max-width": "200px",
        "height": "150px"
      },
      attrs: {
        "src": message.payload.imageInfoArray[1].url,
        "mode": "aspectFit"
      }
    })]) : (message.type === 'TIMFileElem') ? _c('div', {
      staticClass: "message"
    }, [_c('div', {
      staticClass: "file",
      attrs: {
        "eventid": '8_' + index
      },
      on: {
        "click": function($event) {
          _vm.handleDownload(message.payload)
        }
      }
    }, [_c('i-avatar', {
      attrs: {
        "src": "../../../static/images/file.png",
        "size": "large",
        "shape": "square",
        "mpcomid": '2_' + index
      }
    }), _vm._v(" "), _c('div', [_vm._v(_vm._s(message.payload.fileName))])], 1)]) : (message.type === 'TIMCustomElem') ? _c('div', {
      staticClass: "message"
    }, [(message.payload.data === 'dice') ? _c('div', [_c('image', {
      staticStyle: {
        "height": "40px",
        "width": "40px"
      },
      attrs: {
        "src": '/static/images/dice' + message.payload.description + '.png'
      }
    })]) : _c('div', {
      staticClass: "custom-elem"
    }, [_vm._v("这是自定义消息")])]) : (message.type === 'TIMSoundElem') ? _c('div', {
      staticClass: "message",
      attrs: {
        "url": message.payload.url
      }
    }, [_c('div', {
      staticClass: "box",
      attrs: {
        "eventid": '9_' + index
      },
      on: {
        "click": function($event) {
          _vm.openAudio(message.payload)
        }
      }
    }, [_c('image', {
      staticStyle: {
        "height": "20px",
        "width": "14px"
      },
      attrs: {
        "src": "/static/images/audio.png"
      }
    }), _vm._v(" "), _c('div', {
      staticStyle: {
        "padding-left": "10px"
      }
    }, [_vm._v(_vm._s(message.payload.second) + "s")])])]) : (message.type === 'TIMFaceElem') ? _c('div', {
      staticClass: "message"
    }, [_c('div', {
      staticClass: "custom-elem"
    }, [_c('image', {
      staticStyle: {
        "height": "90px",
        "width": "90px"
      },
      attrs: {
        "src": 'https://imgcache.qq.com/open/qcloud/tim/assets/face-elem/' + message.payload.data + '.png'
      }
    })])]) : _vm._e()]), _vm._v(" "), _c('div', {
      staticClass: "avatar"
    }, [_c('i-avatar', {
      attrs: {
        "src": message.avatar || '../../../static/images/header.png',
        "shape": "square",
        "mpcomid": '3_' + index
      }
    })], 1)])])
  })), _vm._v(" "), _c('div', {
    staticClass: "bottom",
    style: ({
      paddingBottom: _vm.isIpx ? _vm.safeBottom + 'px' : ''
    })
  }, [_c('div', {
    staticClass: "bottom-div"
  }, [_c('div', {
    staticClass: "btn",
    attrs: {
      "eventid": '11'
    },
    on: {
      "click": _vm.chooseRecord
    }
  }, [_c('image', {
    staticClass: "btn-small",
    attrs: {
      "src": "/static/images/record.png"
    }
  })]), _vm._v(" "), (!_vm.isRecord) ? _c('div', {
    staticStyle: {
      "width": "80%"
    }
  }, [_c('input', {
    directives: [{
      name: "model",
      rawName: "v-model.lazy:value",
      value: (_vm.messageContent),
      expression: "messageContent",
      modifiers: {
        "lazy:value": true
      }
    }],
    staticClass: "input",
    attrs: {
      "type": "text",
      "confirm-type": "send",
      "focus": _vm.isFocus,
      "eventid": '12'
    },
    domProps: {
      "value": (_vm.messageContent)
    },
    on: {
      "confirm": _vm.sendMessage,
      "input": function($event) {
        if ($event.target.composing) { return; }
        _vm.messageContent = $event.target.value
      }
    }
  })]) : _vm._e(), _vm._v(" "), (_vm.isRecord && !_vm.isRecording) ? _c('div', {
    staticClass: "record",
    attrs: {
      "eventid": '13'
    },
    on: {
      "click": _vm.startRecording
    }
  }, [_vm._v("\n          点击进行录音\n        ")]) : _vm._e(), _vm._v(" "), (_vm.isRecord && _vm.isRecording) ? _c('div', {
    staticClass: "record",
    attrs: {
      "eventid": '14'
    },
    on: {
      "click": _vm.stopRecording
    }
  }, [_vm._v("\n          点击停止录音\n        ")]) : _vm._e(), _vm._v(" "), _c('div', {
    staticClass: "btn",
    attrs: {
      "eventid": '15'
    },
    on: {
      "click": function($event) {
        _vm.handleEmoji()
      }
    }
  }, [_c('image', {
    staticClass: "btn-small",
    attrs: {
      "src": "/static/images/emoji.png"
    }
  })]), _vm._v(" "), _c('div', {
    staticClass: "btn",
    attrs: {
      "eventid": '16'
    },
    on: {
      "click": function($event) {
        _vm.handleMore()
      }
    }
  }, [_c('image', {
    staticClass: "btn-small",
    attrs: {
      "src": "/static/images/plus.png"
    }
  })])]), _vm._v(" "), (_vm.isEmojiOpen) ? _c('div', {
    staticClass: "bottom-emoji"
  }, [_c('div', {
    staticClass: "emojis"
  }, _vm._l((_vm.emojiName), function(emojiItem, index3) {
    return _c('div', {
      key: emojiItem,
      staticClass: "emoji",
      attrs: {
        "eventid": '17_' + index3
      },
      on: {
        "click": function($event) {
          _vm.chooseEmoji(emojiItem)
        }
      }
    }, [_c('image', {
      staticStyle: {
        "width": "25px",
        "height": "25px"
      },
      attrs: {
        "src": _vm.emojiUrl + _vm.emojiMap[emojiItem]
      }
    })])
  })), _vm._v(" "), _c('div', {
    staticClass: "emoji-tab"
  }, [_c('i-row', {
    attrs: {
      "mpcomid": '6'
    }
  }, [_c('i-col', {
    attrs: {
      "span": "21",
      "mpcomid": '4'
    }
  }, [_c('div', {
    staticStyle: {
      "line-height": "26px"
    }
  }, [_vm._v("\n                😄\n              ")])]), _vm._v(" "), _c('i-col', {
    attrs: {
      "span": "3",
      "mpcomid": '5'
    }
  }, [_c('div', {
    staticClass: "sending",
    attrs: {
      "eventid": '18'
    },
    on: {
      "click": function($event) {
        _vm.sendMessage()
      }
    }
  }, [_vm._v("发送")])])], 1)], 1)]) : _vm._e(), _vm._v(" "), (_vm.isMoreOpen) ? _c('div', {
    staticClass: "bottom-image"
  }, [_c('div', {
    staticClass: "images"
  }, [_c('div', {
    staticClass: "block",
    attrs: {
      "eventid": '19'
    },
    on: {
      "click": function($event) {
        _vm.sendPhoto('album')
      }
    }
  }, [_vm._m(0), _vm._v(" "), _c('div', {
    staticClass: "name"
  }, [_vm._v("\n              图片\n            ")])]), _vm._v(" "), _c('div', {
    staticClass: "block",
    attrs: {
      "eventid": '20'
    },
    on: {
      "click": function($event) {
        _vm.sendPhoto('camera')
      }
    }
  }, [_vm._m(1), _vm._v(" "), _c('div', {
    staticClass: "name"
  }, [_vm._v("\n              拍照\n            ")])]), _vm._v(" "), _c('div', {
    staticClass: "block",
    attrs: {
      "eventid": '21'
    },
    on: {
      "click": function($event) {
        _vm.customModal()
      }
    }
  }, [_vm._m(2), _vm._v(" "), _c('div', {
    staticClass: "name"
  }, [_vm._v("\n              自定义消息\n            ")])]), _vm._v(" "), _c('div', {
    staticClass: "block",
    attrs: {
      "eventid": '22'
    },
    on: {
      "click": function($event) {
        _vm.dice()
      }
    }
  }, [_vm._m(3), _vm._v(" "), _c('div', {
    staticClass: "name"
  }, [_vm._v("\n              掷骰子\n            ")])])])]) : _vm._e()])], 1)
}
var staticRenderFns = [function () {var _vm=this;var _h=_vm.$createElement;var _c=_vm._self._c||_h;
  return _c('div', {
    staticClass: "image"
  }, [_c('image', {
    staticStyle: {
      "width": "30px",
      "height": "30px"
    },
    attrs: {
      "src": "/static/images/image.png"
    }
  })])
},function () {var _vm=this;var _h=_vm.$createElement;var _c=_vm._self._c||_h;
  return _c('div', {
    staticClass: "image"
  }, [_c('image', {
    staticStyle: {
      "width": "30px",
      "height": "30px"
    },
    attrs: {
      "src": "/static/images/photo.png"
    }
  })])
},function () {var _vm=this;var _h=_vm.$createElement;var _c=_vm._self._c||_h;
  return _c('div', {
    staticClass: "image"
  }, [_c('image', {
    staticStyle: {
      "width": "30px",
      "height": "30px"
    },
    attrs: {
      "src": "/static/images/define.png"
    }
  })])
},function () {var _vm=this;var _h=_vm.$createElement;var _c=_vm._self._c||_h;
  return _c('div', {
    staticClass: "image"
  }, [_c('image', {
    staticStyle: {
      "width": "30px",
      "height": "30px"
    },
    attrs: {
      "src": "/static/images/dice.png"
    }
  })])
}]
var esExports = { render: render, staticRenderFns: staticRenderFns }
/* harmony default export */ __webpack_exports__["a"] = (esExports);

/***/ })

},["cSaW"]);