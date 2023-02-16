// Modules to control application life and create native browser window
const { app, BrowserWindow, ipcMain, dialog, crashReporter } = require('electron')
const path = require('path')
const url = require('url')
const TimMain = require('./im_electron_sdk/dist/main');
// const TimMain = require('im_electron_sdk/dist/main');
// const TIM = require('./im_electron_sdk/dist/tim')
const mainInstance = new TimMain({
  sdkappid: 1400597090
})
// const mainInstance = new TimMain({
//   sdkappid: 1400624899
// })
// const mainInstance = new TimMain({
//   sdkappid: 1400619962
// })
// const t = new TIM({
//   sdkappid: 1400187352
// })
function createWindow() {
  // Create the browser window.
  const mainWindow = new BrowserWindow({
    width: 960,
    height: 768,
    show: false,
    webPreferences: {
      webSecurity: false,
      nodeIntegration: true,
      nodeIntegrationInWorker: true,
      enableRemoteModule: true,
      contextIsolation: false,
      preload: path.join(__dirname, 'preload.js')
    }
  })
  mainInstance.enable(mainWindow.webContents);
  // and load the index.html of the app.
  // mainWindow.loadURL(
  //   url.format({
  //     pathname: path.join(__dirname, './client/build/index.html'),
  //     protocol: 'file:',
  //     slashes: true
  //   })
  // )

  mainWindow.loadURL('http://localhost:3000')

  // mainWindow.loadFile(path.resolve(__dirname,'./test.html'))

  mainWindow.once('ready-to-show', async () => {
    mainWindow.show();
    mainWindow.webContents.openDevTools()
    console.log(mainWindow.id,'窗口ID')
    // t.getTimbaseManager().TIMInit()
    // t.getTimbaseManager().TIMLogin({
    //   userID: "3708",
    //   userSig: "eJyrVgrxCdYrSy1SslIy0jNQ0gHzM1NS80oy0zLBwsbmBhZQ8eKU7MSCgswUJStDEwMDQwtzY1MjiExqRUFmUSpQ3NTU1MjAwAAiWpKZCxIzMzKxNDU3NjGDmpKZDjQ2LKnAz6Q0J9s3LdQsSrvA28kvKinY1LvIOdE9yDk13DEp0SIi2zWtND*53FapFgB-kjCC",
    //   userData: "xingchenhe-test",
    // }).then((data)=>{
    //   setTimeout(()=>{
    //     for(let i = 0;i<10;i++){
    //       t.getConversationManager().TIMConvGetConvList({
    //         user_data:'666'
    //       }).then(da=>{
    //         console.log('++++++++++++++++++++++++++++++',da.code)
    //       })
    //     }
    //   },2000)
    // })
  })

}
ipcMain.on("create_window",()=>{
  createWindow()
})
// This method will be called when Electron has finished
// initialization and is ready to create browser windows.
// Some APIs can only be used after this event occurs.
app.whenReady().then(() => {
  createWindow()

  app.on('activate', function () {
    // On macOS it's common to re-create a window in the app when the
    // dock icon is clicked and there are no other windows open.
    if (BrowserWindow.getAllWindows().length === 0) createWindow()
  })
})

// Quit when all windows are closed, except on macOS. There, it's common
// for applications and their menu bar to stay active until the user quits
// explicitly with Cmd + Q.
app.on('window-all-closed', function () {
  if (process.platform !== 'darwin') app.quit()
})

// 设置开机自启动

// app.setLoginItemSettings({
//   openAtLogin: true,
//   path: process.execPath
// })

// In this file you can include the rest of your app's specific main process
// code. You can also put them in separate files and require them here.
