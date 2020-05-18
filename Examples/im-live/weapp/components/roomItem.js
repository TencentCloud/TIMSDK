"use strict";

var _core = _interopRequireDefault(require('./../vendor.js')(2));

var _qs = _interopRequireDefault(require('./../vendor.js')(8));

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { "default": obj }; }

_core["default"].component({
  props: {
    item: {}
  },
  data: {},
  methods: {
    clickitem: function clickitem(event) {
      var roomid = this.item.im_id;
      wx.navigateTo({
        url: "/pages/room/index?".concat(_qs["default"].stringify(this.item, {
          encode: false
        })),
        events: {},
        success: function success(res) {// 通过eventChannel向被打开页面传送数据
        }
      });
    }
  },
  computed: {},
  mounted: function mounted() {}
}, {info: {"components":{},"on":{}}, handlers: {'20-0': {"tap": function proxy () {
    var $event = arguments[arguments.length - 1];
    var _vm=this;
      return (function () {
        _vm.clickitem($event);
      })();
    
  }}}, models: {}, refs: undefined });