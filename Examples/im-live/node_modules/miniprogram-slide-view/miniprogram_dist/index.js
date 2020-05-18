module.exports =
/******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};
/******/
/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {
/******/
/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId]) {
/******/ 			return installedModules[moduleId].exports;
/******/ 		}
/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			i: moduleId,
/******/ 			l: false,
/******/ 			exports: {}
/******/ 		};
/******/
/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);
/******/
/******/ 		// Flag the module as loaded
/******/ 		module.l = true;
/******/
/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}
/******/
/******/
/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;
/******/
/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;
/******/
/******/ 	// define getter function for harmony exports
/******/ 	__webpack_require__.d = function(exports, name, getter) {
/******/ 		if(!__webpack_require__.o(exports, name)) {
/******/ 			Object.defineProperty(exports, name, { enumerable: true, get: getter });
/******/ 		}
/******/ 	};
/******/
/******/ 	// define __esModule on exports
/******/ 	__webpack_require__.r = function(exports) {
/******/ 		if(typeof Symbol !== 'undefined' && Symbol.toStringTag) {
/******/ 			Object.defineProperty(exports, Symbol.toStringTag, { value: 'Module' });
/******/ 		}
/******/ 		Object.defineProperty(exports, '__esModule', { value: true });
/******/ 	};
/******/
/******/ 	// create a fake namespace object
/******/ 	// mode & 1: value is a module id, require it
/******/ 	// mode & 2: merge all properties of value into the ns
/******/ 	// mode & 4: return value when already ns object
/******/ 	// mode & 8|1: behave like require
/******/ 	__webpack_require__.t = function(value, mode) {
/******/ 		if(mode & 1) value = __webpack_require__(value);
/******/ 		if(mode & 8) return value;
/******/ 		if((mode & 4) && typeof value === 'object' && value && value.__esModule) return value;
/******/ 		var ns = Object.create(null);
/******/ 		__webpack_require__.r(ns);
/******/ 		Object.defineProperty(ns, 'default', { enumerable: true, value: value });
/******/ 		if(mode & 2 && typeof value != 'string') for(var key in value) __webpack_require__.d(ns, key, function(key) { return value[key]; }.bind(null, key));
/******/ 		return ns;
/******/ 	};
/******/
/******/ 	// getDefaultExport function for compatibility with non-harmony modules
/******/ 	__webpack_require__.n = function(module) {
/******/ 		var getter = module && module.__esModule ?
/******/ 			function getDefault() { return module['default']; } :
/******/ 			function getModuleExports() { return module; };
/******/ 		__webpack_require__.d(getter, 'a', getter);
/******/ 		return getter;
/******/ 	};
/******/
/******/ 	// Object.prototype.hasOwnProperty.call
/******/ 	__webpack_require__.o = function(object, property) { return Object.prototype.hasOwnProperty.call(object, property); };
/******/
/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";
/******/
/******/
/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(__webpack_require__.s = 0);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ (function(module, exports, __webpack_require__) {

"use strict";


// slide-view/slide-view.js
var _windowWidth = wx.getSystemInfoSync().windowWidth;
Component({
  /**
   * 组件的属性列表
   */
  options: {
    multipleSlots: true
  },
  properties: {
    //  组件显示区域的宽度
    width: {
      type: Number,
      value: _windowWidth
    },
    //  组件显示区域的高度
    height: {
      type: Number,
      value: 0
    },
    //  组件滑动显示区域的宽度
    slideWidth: {
      type: Number,
      value: 0
    }
  },

  /**
   * 组件的初始数据
   */
  data: {
    viewWidth: _windowWidth,
    //  movable-view偏移量
    x: 0,
    //  movable-view是否可以出界
    out: false
  },

  /**
   * 组件的方法列表
   */
  //    获取右侧滑动显示区域的宽度
  ready: function ready() {
    var that = this;
    var query = wx.createSelectorQuery().in(this);
    query.select('.right').boundingClientRect(function (res) {
      that._slideWidth = res.width;
      that._threshold = res.width / 2;
      that._viewWidth = that.data.width + res.width * (750 / _windowWidth);
      that.setData({
        viewWidth: that._viewWidth
      });
    }).exec();
  },

  methods: {
    onTouchStart: function onTouchStart(e) {
      this._startX = e.changedTouches[0].pageX;
    },

    //  当滑动范围超过阈值自动完成剩余滑动
    onTouchEnd: function onTouchEnd(e) {
      this._endX = e.changedTouches[0].pageX;
      var _endX = this._endX,
          _startX = this._startX,
          _threshold = this._threshold;

      if (_startX - _endX >= _threshold) {
        this.setData({
          x: -this._slideWidth
        });
      } else if (_startX - _endX < _threshold && _startX - _endX > 0) {
        this.setData({
          x: 0
        });
      } else if (_endX - _startX >= _threshold) {
        this.setData({
          x: 0
        });
      } else if (_endX - _startX < _threshold && _endX - _startX > 0) {
        this.setData({
          x: -this._slideWidth
        });
      }
    },

    //  根据滑动的范围设定是否允许movable-view出界
    onChange: function onChange(e) {
      if (!this.data.out && e.detail.x < -this._threshold) {
        this.setData({
          out: true
        });
      } else if (this.data.out && e.detail.x >= -this._threshold) {
        this.setData({
          out: false
        });
      }
    }
  }
});

/***/ })
/******/ ]);