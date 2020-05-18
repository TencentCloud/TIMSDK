"use strict";

var _core = _interopRequireDefault(require('./../vendor.js')(2));

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { "default": obj }; }

_core["default"].component({
  props: {},
  data: {},
  methods: {
    hide: function hide() {
      this.$emit('hideGift');
    },
    sendgift: function sendgift() {
      this.$emit('sendgift');
    }
  },
  computed: {}
}, {info: {"components":{},"on":{}}, handlers: {'14-0': {"tap": function proxy () {
    var $event = arguments[arguments.length - 1];
    var _vm=this;
      return (function () {
        _vm.hide($event);
      })();
    
  }},'14-1': {"tap": function proxy () {
    var $event = arguments[arguments.length - 1];
    var _vm=this;
      return (function () {
        _vm.sendgift($event);
      })();
    
  }}}, models: {}, refs: undefined });