"use strict";

var _core = _interopRequireDefault(require('./../vendor.js')(2));

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { "default": obj }; }

_core["default"].component({
  props: {
    goods: []
  },
  data: {},
  methods: {
    hide: function hide() {
      this.$emit('hidegoods');
    },
    sendgoods: function sendgoods(name) {
      var _this = this;

      wx.showModal({
        title: '提示',
        content: "确认购买该商品？",
        success: function success(data) {
          if (data.confirm) {
            _this.$emit('buy', {
              name: name
            });
          } else {
            console.log(data);
          }
        },
        fail: function fail(data) {
          console.log(data);
        }
      });
    }
  },
  computed: {}
}, {info: {"components":{},"on":{}}, handlers: {'17-0': {"tap": function proxy () {
    var $event = arguments[arguments.length - 1];
    var _vm=this;
      return (function () {
        _vm.hide($event);
      })();
    
  }},'17-1': {"tap": function proxy (item) {
    
    var _vm=this;
      return (function () {
        _vm.sendgoods(item.name);
      })();
    
  }},'17-2': {"tap": function proxy (item) {
    
    var _vm=this;
      return (function () {
        _vm.sendgoods(item.name);
      })();
    
  }}}, models: {}, refs: undefined });