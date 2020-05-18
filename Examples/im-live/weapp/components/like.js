"use strict";

var _core = _interopRequireDefault(require('./../vendor.js')(2));

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { "default": obj }; }

_core["default"].component({
  props: {},
  data: {
    animation: false,
    aniUrl: ''
  },
  methods: {
    like: function like() {
      var _this = this;

      if (!this.animation) {
        this.aniUrl = '/static/images/gift-ani.gif';
        this.animation = true;
        var timmer = setTimeout(function () {
          clearTimeout(timmer);
          _this.aniUrl = '';
          _this.animation = false;
        }, 760);
        this.$emit('like');
      } else {}
    }
  },
  computed: {}
}, {info: {"components":{},"on":{}}, handlers: {'23-0': {"tap": function proxy () {
    var $event = arguments[arguments.length - 1];
    var _vm=this;
      return (function () {
        _vm.like($event);
      })();
    
  }}}, models: {}, refs: undefined });