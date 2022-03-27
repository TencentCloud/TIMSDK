"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _events = require("./events");

var _events2 = _interopRequireDefault(_events);

function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { default: obj }; }

const platform = require('os').platform();

class captureView {
  constructor(options) {
    this.multiScreen = !!options ? !!options.multiScreen : false;
    this.globalShortCut = !!options ? options.globalShortCut || 'shift+option+A' : 'shift+option+A';
    this.devTools = !!options ? !!options.devTools : false;
    this.fileprefix = !!options ? options.fileprefix || 'screen_shot' : 'screen_shot';
    this.onClose = !!options ? options.onClose || null : null;
    this.onShow = !!options ? options.onShow || null : null;
    this.onShowByShortCut = !!options ? options.onShowByShortCut || null : null;
    this.tools = {
      mosaic: !!options ? !!options.mosaic : false,
      text: !!options ? !!options.text : false,
      curve: !!options ? !!options.curve : false,
    }
    this.useCapture();
  }

  useCapture() {
    global.captureView = this;
    this.captureWins = _events2.default.useCapture(this);
  }

  open() {
    _events2.default.startScreenshot();
  }

  close() {
    _events2.default.reset();
  }

  updateShortCutKey(newHotKey) {
    _events2.default.updateShortCutKey(newHotKey);
  }

  setMultiScreen(option) {
    this.multiScreen = option;
  }

}

exports.default = captureView;
