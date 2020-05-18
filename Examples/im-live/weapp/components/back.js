"use strict";

var _core = _interopRequireDefault(require('./../vendor.js')(2));

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { "default": obj }; }

_core["default"].component({
  props: {},
  data: {},
  methods: {
    back: function back() {
      this.$emit('quitGroup');
    }
  },
  computed: {}
}, {info: {"components":{},"on":{}}, handlers: {'21-0': {"tap": function proxy () {
    var $event = arguments[arguments.length - 1];
    var _vm=this;
      return (function () {
        _vm.back($event);
      })();
    
  }}}, models: {}, refs: undefined });