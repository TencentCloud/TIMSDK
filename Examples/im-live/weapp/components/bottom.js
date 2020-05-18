"use strict";

var _core = _interopRequireDefault(require('./../vendor.js')(2));

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { "default": obj }; }

_core["default"].component({
  props: {
    header: {},
    isTimReady: false
  },
  data: {},
  methods: {
    showgoods: function showgoods() {
      this.$emit('showgoods');
    },
    showGift: function showGift() {
      this.$emit('showGift');
    },
    quitGroup: function quitGroup() {
      this.$emit('quitGroup');
    },
    sendMessage: function sendMessage(data) {
      this.$emit('send-message', data);
    },
    like: function like() {
      this.$emit('like');
    }
  },
  created: function created() {},
  mounted: function mounted() {}
}, {info: {"components":{"back":{"path":"./back"},"goods":{"path":"./goods"},"like":{"path":"./like"},"message":{"path":"./message"},"gift":{"path":"./gift"}},"on":{"12-0":["showgoods"],"12-1":["send-message"],"12-2":["showGift"],"12-3":["like"],"12-4":["quitGroup"]}}, handlers: {'12-0': {"showgoods": function proxy () {
    var $event = arguments[arguments.length - 1];
    var _vm=this;
      return (function () {
        _vm.showgoods($event);
      })();
    
  }},'12-1': {"send-message": function proxy () {
    var $event = arguments[arguments.length - 1];
    var _vm=this;
      return (function () {
        _vm.sendMessage($event);
      })();
    
  }},'12-2': {"showGift": function proxy () {
    var $event = arguments[arguments.length - 1];
    var _vm=this;
      return (function () {
        _vm.showGift($event);
      })();
    
  }},'12-3': {"like": function proxy () {
    var $event = arguments[arguments.length - 1];
    var _vm=this;
      return (function () {
        _vm.like($event);
      })();
    
  }},'12-4': {"quitGroup": function proxy () {
    var $event = arguments[arguments.length - 1];
    var _vm=this;
      return (function () {
        _vm.quitGroup($event);
      })();
    
  }}}, models: {}, refs: undefined });