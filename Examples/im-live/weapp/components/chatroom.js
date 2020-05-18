"use strict";

var _core = _interopRequireDefault(require('./../vendor.js')(2));

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { "default": obj }; }

_core["default"].component({
  props: {
    message: []
  },
  data: {
    viewID: ""
  },
  methods: {},
  watch: {
    message: function message(nexto, preo) {
      if (nexto.length) {
        var last = nexto[nexto.length - 1];
        this.viewID = last.id; // 限制展示在页面上的消息条数
      }
    }
  },
  computed: {},
  created: function created() {}
}, {info: {"components":{"message-item":{"path":"./message-item"}},"on":{}}, handlers: {}, models: {}, refs: undefined });