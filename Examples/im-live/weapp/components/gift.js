"use strict";

var _core = _interopRequireDefault(require('./../vendor.js')(2));

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { "default": obj }; }

_core["default"].component({
  props: {},
  data: {},
  methods: {
    showgift: function showgift() {
      this.$emit('showGift');
    }
  },
  computed: {}
}, {info: {"components":{},"on":{}}, handlers: {'25-0': {"tap": function proxy () {
    var $event = arguments[arguments.length - 1];
    var _vm=this;
      return (function () {
        _vm.showgift($event);
      })();
    
  }}}, models: {}, refs: undefined });