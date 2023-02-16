"use strict";

Object.defineProperty(exports, "__esModule", {
  value: true
});

var _electron = require("electron");

let captureWins = [];
let captureWinIds = [];
let displays = [];
let displayHash = {};
let command = 'screencapture -x ';
let deletecommand = 'rm -rf ';
const path = require('os').homedir() + `/Download/`;
const captureURL = `file://${require('path').join(__dirname, '../renderer/index.html')}`;

const platform = require('os').platform();

let hotKey = 'shift+option+a';

const {
  exec
} = require('child_process');

const fs = require('fs');

let state = fs.existsSync(require('os').homedir() + `/Download`);
let captureView = {};
exports.default = {
  startScreenshot,
  useCapture,
  updateShortCutKey
};

function useCapture(options) {
  captureView = options;
  hotKey = captureView.globalShortCut ? captureView.globalShortCut : hotKey;

  _electron.globalShortcut.register(hotKey, () => {
    if (typeof captureView.onShowByShortCut === 'function') {
      captureView.onShowByShortCut();
    }

    startScreenshot();
  });

  createCaptureWins();
  initListern();
  return captureWins;
}

function updateShortCutKey(newHotKey) {
  _electron.globalShortcut.unregister(hotKey);

  hotKey = newHotKey;

  _electron.globalShortcut.register(hotKey, () => {
    startScreenshot();
  });
}

function createCaptureBrowserWindow(display) {
  let captureWin = new _electron.BrowserWindow({
    width: display ? display.bounds.width : 0,
    height: display ? display.bounds.height : 0,
    x: display ? display.bounds.x : 0,
    y: display ? display.bounds.y : 0,
    webPreferences: {
      webviewTag: true,
      webSecurity: process.env.NODE_ENV === 'production',
      nodeIntegration: true,
      nodeIntegrationInWorker: true,
      enableRemoteModule: true,
      contextIsolation: false,
    },
    fullscreen: platform === 'win32' || undefined,
    resizable: false,
    enableLargerThanScreen: true,
    skipTaskbar: true,
    show: false,
    movable: false,
    frame: false,
    transparent: true,
    focusable: true,
  });
  captureWin.setAlwaysOnTop(true, 'screen-saver');
  captureWin.setVisibleOnAllWorkspaces(true);
  captureWin.setFullScreenable(true);
  captureWin.hide();
  captureWin.loadURL(captureURL);
  captureWin.on('ready-to-show', () => {
    captureWin.hide();
  });
  captureWin.on('show', () => {
    _electron.globalShortcut.register('Esc', () => {
      reset();
    });
  });
  captureWin.on('closed', () => {
    _electron.globalShortcut.unregister('Esc');

    captureWin = null;
  });
  return captureWin;
}

function setScreenInfo(displays) {
  if (!state) {
    fs.mkdirSync(require('os').homedir() + `/Download`);
  }

  displays.forEach(display => {
    displayHash[display.id] = display.id + '_' + new Date().getTime();
    command = command + path + displayHash[display.id] + '.png ';
    deletecommand = deletecommand + path + displayHash[display.id] + '.png ';
  });
  console.log('setScreenInfo', command);
}

function createCaptureWins() {
  if (captureWins.length) {
    console.log('The screenshot window already exists and will not be recreated');
    return;
  }
  const {
    screen
  } = require('electron');

  displays = screen.getAllDisplays();
  if (platform !== 'darwin' || !captureView.multiScreen) {
    captureWins[0] = createCaptureBrowserWindow()
    setScreenInfo(displays)
    console.log('Do not turn on extended screenshots')
  } else {
    setScreenInfo(displays)
    captureWins = displays.map((display) => {
      return createCaptureBrowserWindow(display)
    })
  }

  if (captureView.devTools) {
    captureWins.forEach(d => {
      d.webContents.openDevTools();
    });
  } else {
    captureWins.forEach(d => {
      d.webContents.closeDevTools();
    });
  }

  return captureWins;
}

function initListern() {
  const {
    screen
  } = require('electron');

  screen.on('display-added', () => {
    console.log('display-added');
    reset();
  });
  screen.on('display-removed', () => {
    console.log('display-removed');
    reset();
  });

  _electron.ipcMain.on('SCREENSHOT::CLOSE', () => {
    reset();
  });

  _electron.ipcMain.on('SCREENSHOT::HIDE', () => {
    if (captureWins) {
      captureWins.forEach(win => win.hide());
    }
  });

  _electron.ipcMain.on('SCREENSHOT::CREATE', () => {
    createCaptureWins();
  });

  _electron.ipcMain.on('SCREENSHOT::START', () => {
    console.log('IpcMain...... SCREENSHOT::START', captureWins.length);
    startScreenshot();
  });

  _electron.globalShortcut.register(hotKey, () => {
    startScreenshot();
  });
}

function reset() {
  if (typeof captureView.onClose === 'function') {
    captureView.onClose();
  }

  if (captureWins) {
    captureWins.forEach(win => {
      win.close();
      win = null;
    });
    displayHash = {};
    captureWins = [];
    displays = [];
    captureWinIds = [];
  }

  if (platform === 'darwin') {
    exec(deletecommand, (error, stdout, stderr) => {
      if (error) throw error;
      deletecommand = 'rm -rf ';
      command = 'screencapture -x ';
      state = fs.existsSync(require('os').homedir() + `/Desktop`);
      createCaptureWins();
    });
  } else {
    createCaptureWins();
  }
}

function startScreenshot() {
  if (typeof captureView.onShow === 'function') {
    console.log(captureView.onShow.toString());
    captureView.onShow();
  }

  if (platform === 'darwin') {
    startMacScreenshot();
  } else {
    startLinuxScreenshot();
  }
}

function startMacScreenshot() {
  state = fs.existsSync(require('os').homedir() + `/Desktop`);

  if (!state) {
    fs.mkdirSync(require('os').homedir() + `/Desktop`);
  }

  exec(command, (error, stdout, stderr) => {
    if (error) throw error;

    if (captureView.multiScreen) {
      captureWins.forEach(captureWin => {
        const _win = displays.filter(d => d.bounds.x === captureWin.getBounds().x && d.bounds.y === captureWin.getBounds().y)[0];
        captureWin.setSize(_win.bounds.width, _win.bounds.height);
        captureWin.webContents.send('SCREENSHOT::OPEN_MAC', _win.bounds.width, _win.bounds.height, _win.scaleFactor, displayHash[_win.id],         {
          tools: captureView.tools,
          fileprefix: captureView.fileprefix
        });
      });
    } else {
      const {
        screen
      } = require('electron');

      const cursor = screen.getCursorScreenPoint();
      const display = screen.getDisplayNearestPoint(cursor)
      const captureWin = captureWins[0]
      captureWin.setSize(display.bounds.width, display.bounds.height)
      captureWin.setPosition(display.bounds.x, display.bounds.y)
      captureWin.webContents.send('SCREENSHOT::OPEN_MAC', display.bounds.width, display.bounds.height, display.scaleFactor, displayHash[display.id], {
        tools: captureView.tools,
        fileprefix: captureView.fileprefix
      });
    }
  });
}

function startLinuxScreenshot() {
  const { screen } = require('electron')
  const cursor = screen.getCursorScreenPoint()
  const display = screen.getDisplayNearestPoint(cursor)
  const captureWin = captureWins[0]
  captureWin.setBounds(display.bounds.width, display.bounds.height)
  captureWin.setPosition(display.bounds.x, display.bounds.y)
  captureWin.webContents.send('SCREENSHOT::OPEN_Linux', {
    tools: captureView.tools,
    fileprefix: captureView.fileprefix
  });
}
