"use strict";

var _core = _interopRequireDefault(require('./../vendor.js')(2));

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { "default": obj }; }

_core["default"].component({
  props: {},
  data: {},
  methods: {
    showgoods: function showgoods() {
      this.$emit('showgoods');
    }
  },
  computed: {}
}, {info: {"components":{},"on":{}}, handlers: {'22-0': {"tap": function proxy () {
    var $event = arguments[arguments.length - 1];
    var _vm=this;
      return (function () {
        _vm.showgoods($event);
      })();
    
  }}}, models: {}, refs: undefined });