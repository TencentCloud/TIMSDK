"use strict";

var _core = _interopRequireDefault(require('./../vendor.js')(2));

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { "default": obj }; }

_core["default"].component({
  props: {
    userInfo: {},
    groupinfo: {},
    ownerInfo: {}
  },
  data: {
    attention: false,
    fans: '0'
  },
  methods: {
    coupon: function coupon() {
      this.$emit('coupon');
    },
    _getVarsByKey: function _getVarsByKey(arr, key) {
      var res;

      for (var i = 0; i < arr.length; i++) {
        if (arr[i].key === key) {
          res = arr[i].value;
          break;
        }
      }

      return res;
    },
    attentionBtn: function attentionBtn() {
      if (!this.attention) {
        this.$emit('attention');
      }
    }
  },
  computed: {},
  watch: {
    groupinfo: function groupinfo(nexto, pre) {
      if (nexto.groupCustomField) {
        this.fans = this._getVarsByKey(nexto.groupCustomField, 'attent') || '0';
      }
    },
    userInfo: function userInfo(nexto, pre) {
      var at = false;

      if (nexto.userID) {
        var profileCustomField = nexto.profileCustomField;
        var profile = JSON.parse(this._getVarsByKey(profileCustomField, "Tag_Profile_Custom_avlist") || "[]");

        for (var i in profile) {
          if (profile[i].ownerid === this.ownerInfo.userID) {
            at = true;
            break;
          }
        }
      }

      this.attention = at;
    }
  },
  created: function created() {// this.profileCustomField = this.userInfo.profileCustomField
  }
}, {info: {"components":{},"on":{}}, handlers: {'11-0': {"tap": function proxy () {
    var $event = arguments[arguments.length - 1];
    var _vm=this;
      return (function () {
        _vm.attentionBtn($event);
      })();
    
  }},'11-1': {"tap": function proxy () {
    var $event = arguments[arguments.length - 1];
    var _vm=this;
      return (function () {
        _vm.coupon($event);
      })();
    
  }}}, models: {}, refs: undefined });