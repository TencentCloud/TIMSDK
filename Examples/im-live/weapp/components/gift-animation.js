"use strict";

var _core = _interopRequireDefault(require('./../vendor.js')(2));

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { "default": obj }; }

_core["default"].component({
  props: {
    nick: '',
    avatar: ''
  },
  data: {},
  methods: {
    showgift: function showgift() {
      this.$emit('showGift');
    }
  },
  computed: {},
  created: function created() {
    var _this = this;

    setTimeout(function () {
      _this.$emit('hideani');
    }, 1000);
  }
}, {info: {"components":{},"on":{}}, handlers: {}, models: {}, refs: undefined });