"use strict";

var _core = _interopRequireDefault(require('./../vendor.js')(2));

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { "default": obj }; }

_core["default"].component({
  props: {},
  data: {},
  methods: {
    showgoods: function showgoods() {
      this.$emit('showgoods');
    },
    close: function close() {
      this.$emit('hidecoupon');
    },
    usecoupon: function usecoupon() {
      this.$emit('usecoupon');
    }
  },
  computed: {},
  created: function created() {}
}, {info: {"components":{},"on":{}}, handlers: {'15-0': {"tap": function proxy () {
    var $event = arguments[arguments.length - 1];
    var _vm=this;
      return (function () {
        _vm.usecoupon($event);
      })();
    
  }},'15-1': {"tap": function proxy () {
    var $event = arguments[arguments.length - 1];
    var _vm=this;
      return (function () {
        _vm.close($event);
      })();
    
  }}}, models: {}, refs: undefined });