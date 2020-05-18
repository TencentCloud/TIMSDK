"use strict";

var _core = _interopRequireDefault(require('./../vendor.js')(2));

var _const = _interopRequireDefault(require('./../common/const.js'));

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { "default": obj }; }

_core["default"].component({
  props: {},
  data: {
    userData: {},
    seesionKey: '',
    loading: true
  },
  methods: {
    check: function check() {
      var _this = this;

      wx.login({
        success: function success(data) {
          wx.request({
            url: "".concat(_const["default"].HOST, "/release/getUser"),
            method: 'POST',
            header: {
              'content-type': 'application/x-www-form-urlencoded'
            },
            data: {
              code: data.code
            },
            success: function success(data) {
              if (data.data.code == -2) {
                _this.seesionKey = data.data.seesionKey;
              } else {
                _this.userData = data.data;
              }
            },
            fail: function fail() {},
            complete: function complete() {
              _this.loading = false;
            }
          });
        }
      });
    },
    getUserinfo: function getUserinfo(data) {
      var _this2 = this;

      wx.showLoading({
        mask: true
      });
      var encryptedData = data.$wx.detail.encryptedData;
      var iv = data.$wx.detail.iv;
      wx.request({
        url: "".concat(_const["default"].HOST, "/release/wxRegister"),
        method: 'POST',
        header: {
          'content-type': 'application/x-www-form-urlencoded'
        },
        data: {
          session_key: this.seesionKey,
          encryptedData: encryptedData,
          iv: iv
        },
        success: function success(data) {
          _this2.userData = data.data;

          _this2.$emit('loginSuccess');
        },
        fail: function fail() {},
        complete: function complete() {
          wx.hideLoading();
        }
      });
    }
  },
  computed: {},
  created: function created() {
    this.check();
  }
}, {info: {"components":{},"on":{}}, handlers: {'10-0': {"getuserinfo": function proxy () {
    var $event = arguments[arguments.length - 1];
    var _vm=this;
      return (function () {
        _vm.getUserinfo($event);
      })();
    
  }}}, models: {}, refs: undefined });