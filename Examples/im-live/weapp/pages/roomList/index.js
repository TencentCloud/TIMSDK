"use strict";

var _regeneratorRuntime2 = _interopRequireDefault(require('./../../vendor.js')(0));

var _core = _interopRequireDefault(require('./../../vendor.js')(2));

var _const = _interopRequireDefault(require('./../../common/const.js'));

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { "default": obj }; }

function asyncGeneratorStep(gen, resolve, reject, _next, _throw, key, arg) { try { var info = gen[key](arg); var value = info.value; } catch (error) { reject(error); return; } if (info.done) { resolve(value); } else { Promise.resolve(value).then(_next, _throw); } }

function _asyncToGenerator(fn) { return function () { var self = this, args = arguments; return new Promise(function (resolve, reject) { var gen = fn.apply(self, args); function _next(value) { asyncGeneratorStep(gen, resolve, reject, _next, _throw, "next", value); } function _throw(err) { asyncGeneratorStep(gen, resolve, reject, _next, _throw, "throw", err); } _next(undefined); }); }; }

var app = getApp();

_core["default"].page({
  data: {
    room: [],
    btn: [],
    userData: {},
    userSig: '',
    isLogin: true,
    loading: true
  },
  mixins: [],
  computed: {},
  methods: {
    loginSuccess: function loginSuccess() {
      this.isLogin = true;
      this.auth();
    },
    getRoomList: function getRoomList() {
      var _this = this;

      wx.request({
        url: "".concat(_const["default"].HOST, "/release/getRoomList"),
        method: 'GET',
        header: {
          "content-type": "application/x-www-form-urlencoded"
        },
        success: function success(data) {
          _this.room = data.data;
        },
        fail: function fail() {}
      });
    },
    auth: function auth() {
      var _this2 = this;

      wx.login({
        success: function success(data) {
          _this2.loading = true;
          wx.request({
            url: "".concat(_const["default"].HOST, "/release/getUser"),
            method: 'POST',
            header: {
              "content-type": "application/x-www-form-urlencoded"
            },
            data: {
              code: data.code
            },
            success: function success(data) {
              if (data.data.code == -2) {
                _this2.isLogin = false;
              } else {
                app.userData = data.data;
                var userData = data.data;
                _this2.userData = userData;
              }
            },
            fail: function fail() {},
            complete: function complete() {
              _this2.loading = false;
            }
          });
        }
      });
    }
  },
  events: {},
  onShow: function onShow() {
    if (!this.userData.id) {
      this.auth();
    }
  },
  created: function created() {
    var _this3 = this;

    return _asyncToGenerator( /*#__PURE__*/_regeneratorRuntime2["default"].mark(function _callee() {
      return _regeneratorRuntime2["default"].wrap(function _callee$(_context) {
        while (1) {
          switch (_context.prev = _context.next) {
            case 0:
              _this3.getRoomList();

            case 1:
            case "end":
              return _context.stop();
          }
        }
      }, _callee);
    }))();
  }
}, {info: {"components":{"roomlists":{"path":"./../../components/roomLists"},"login":{"path":"./../../components/login"}},"on":{"4-0":["loginSuccess"]}}, handlers: {'4-0': {"loginSuccess": function proxy () {
    var $event = arguments[arguments.length - 1];
    var _vm=this;
      return (function () {
        _vm.loginSuccess($event);
      })();
    
  }}}, models: {}, refs: undefined });