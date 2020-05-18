"use strict";

var _core = _interopRequireDefault(require('./../vendor.js')(2));

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { "default": obj }; }

_core["default"].component({
  props: {
    isTimReady: false
  },
  data: {
    text: '',
    displayInputShow: 'none',
    displayInputBottom: '0px'
  },
  methods: {
    bindblur: function bindblur() {
      this.displayInputShow = 'none';
    },
    bindkeyboardheightchange: function bindkeyboardheightchange(event) {
      var _this = this;

      this.displayInputShow = 'none';
      var _event$$wx$detail = event.$wx.detail,
          height = _event$$wx$detail.height,
          duration = _event$$wx$detail.duration;
      this.displayInputBottom = height + 'px';

      if (height > 0) {
        setTimeout(function () {
          _this.displayInputShow = 'block';
        }, duration * 1000);
      }
    },
    textInput: function textInput(data) {
      this.text = data.$wx.detail.value;
    },
    confirm: function confirm() {
      this.$emit('send-message', this.text);
      this.text = '';
    }
  },
  computed: {}
}, {info: {"components":{},"on":{}}, handlers: {'24-0': {"confirm": function proxy () {
    var $event = arguments[arguments.length - 1];
    var _vm=this;
      return (function () {
        _vm.confirm($event);
      })();
    
  }, "input": function proxy () {
    var $event = arguments[arguments.length - 1];
    var _vm=this;
      return (function () {
        _vm.textInput($event);
      })();
    
  }, "keyboardheightchange": function proxy () {
    var $event = arguments[arguments.length - 1];
    var _vm=this;
      return (function () {
        _vm.bindkeyboardheightchange($event);
      })();
    
  }, "blur": function proxy () {
    var $event = arguments[arguments.length - 1];
    var _vm=this;
      return (function () {
        _vm.bindblur($event);
      })();
    
  }}}, models: {}, refs: undefined });