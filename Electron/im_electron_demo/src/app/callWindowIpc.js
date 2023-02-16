const { ipcMain, BrowserWindow, screen } = require('electron');
const path = require('path')
const url = require('url');
const log = require('electron-log');

const { OPEN_CALL_WINDOW, CLOSE_CALL_WINDOW, END_CALL_WINDOW, CALL_WINDOW_CLOSE_REPLY, SDK_APP_ID } = require("./const/const");


const getSrceenSize = () => {
    const display = screen.getPrimaryDisplay();
    return display.size;
}

class CallWindowIpc {
    callWindow = null;
    imWindow = global.WIN;
    readyToShowWindow = false;
    timMianInstance = null;
    constructor(timInstance) {
        this.timMianInstance = timInstance;
        this.mount();
    }

    mount() {
        this.createWindow();
        this.addEventListiner();
    }

    destroy() {
        this.offEventListiner();
        this.addEventListiner();
    }

    createWindow() {
        this.callWindow = null;
        const { NODE_ENV, HUARUN_ENV } = process.env;
        const isDev = NODE_ENV?.trim() === 'development';
        const callWindow = new BrowserWindow({
            height: 600,
            width: 800,
            show: false,
            frame: false,
            resizable: false,
            webPreferences: {
                parent: this.win,
                webSecurity: true,
                nodeIntegration: true,
                nodeIntegrationInWorker: true,
                enableRemoteModule: true,
                contextIsolation: false,
            },
        });
        this.timMianInstance.enable(callWindow.webContents)
        callWindow.removeMenu();
        if (isDev) {
            callWindow.loadURL(`http://localhost:3000/call.html`);
            callWindow.webContents.openDevTools(); // Formal production does not need to be turned on
        } else {
            
            callWindow.loadURL(
                url.format({
                    pathname: path.join(__dirname, `../../bundle/call.html`),
                    protocol: 'file:',
                    slashes: true
                })
            );
        }

        callWindow.on('ready-to-show', () => {
            this.readyToShowWindow = true;  
        });

        this.readyToShowWindow = false;

        this.callWindow = callWindow;
    }

    addEventListiner() {
        const { NODE_ENV } = process.env;
        const isDev = NODE_ENV?.trim() === 'development';
        const screenSize = getSrceenSize();
        // As the recipient, after accepting the call, change the window size.
        ipcMain.on('change-window-size', (event, acceptParams) => {
            // Communicate to the chat window
            const { isVoiceCall } = acceptParams;
            const windowWidth = isVoiceCall ? 400 : 800;
            const windowHeight = isVoiceCall ? 650 : 600;

            const positionX = Math.floor((screenSize.width - windowWidth) / 2);
            const positionY = Math.floor((screenSize.height - windowHeight) / 2);

            this.callWindow.setSize(windowWidth, windowHeight);
            this.callWindow.setPosition(positionX, positionY);
        });

        ipcMain.on('accept-call', (event, inviteID) => {
            this.callWindow.setAlwaysOnTop(false);
            this.imWindow.webContents.send('accept-call-reply', inviteID);
        })

        // As the receiver, hang up and close the window
        ipcMain.on('refuse-call', (event, inviteID) => {
            this.callWindow.close();
            // Communicate to the chat window
            this.imWindow.webContents.send('refuse-call-reply', inviteID);
        });

        // When the recipient rejects the call, call this method to close the window and exit the room
        ipcMain.on(CLOSE_CALL_WINDOW, () => {
            this.callWindow.webContents.send('exit-room');
        });

        ipcMain.on(END_CALL_WINDOW, () => {
            this.callWindow.close()
        })
        // remote user access
        ipcMain.on('remote-user-join', (event, userId) => {
            this.imWindow.webContents.send('remote-user-join-reply', userId)
        });

        // Remote user leaves
        ipcMain.on('remote-user-exit', (event, userId) => {
            this.imWindow.webContents.send('remote-user-exit-reply', userId)
        });

        // Cancel call invitation
        ipcMain.on('cancel-call-invite', (event, data) => {
            this.imWindow.webContents.send('cancel-call-invite-reply', data);
        });

        // Update the invitation list (when the user rejects the invitation, the call window needs to be notified)
        ipcMain.on('update-invite-list', (event, inviteList) => {
            this.callWindow.webContents.send('update-invite-list', inviteList);
        });

        ipcMain.on(OPEN_CALL_WINDOW, (event, data) => {
            const addSdkAppid = {
                ...data,
                sdkAppid: SDK_APP_ID
            };
            const convType = data?.convInfo?.convType;
            const callType = data?.callType;
            const params = JSON.stringify(addSdkAppid);
            if (data.windowType === 'notificationWindow') {
                this.callWindow.setMinimumSize(320, 150);
                this.callWindow.setSize(320, 150);
                this.callWindow.setPosition(screenSize.width - 340, screenSize.height - 200);
                this.callWindow.setAlwaysOnTop(true);
            } else if (convType === 1 && Number(callType) === 1) {
                this.callWindow.setMinimumSize(400, 650);
                this.callWindow.setSize(400, 650);
                this.callWindow.setPosition(Math.floor((screenSize.width - 400) / 2), Math.floor((screenSize.height - 650) / 2));
            }

            if(data.windowType === 'meetingWindow') {
                this.callWindow.setMinimumSize(1240, 640);
                this.callWindow.setSize(1240, 640);
                this.callWindow.setResizable(true);
                this.callWindow.setPosition(Math.floor((screenSize.width - 1240) / 2), Math.floor((screenSize.height - 640) / 2));
            }

            const showWindow = (timer) => {
                this.callWindow.show();
                this.callWindow.webContents.send('pass-call-data', params);
                isDev && this.callWindow.webContents.openDevTools();
                timer && clearInterval(timer);
            }

            if(this.readyToShowWindow) {
                showWindow();
            } else {
                const timer = setInterval(() => {
                    if(this.readyToShowWindow) {
                        showWindow(timer);
                    }
                }, 10);

            }
        });

        this.callWindow.on('close', () => {
            try {
                this.createWindow()
            } catch(err) {
                console.log(err);
            }
        });

        this.callWindow.on('closed', () => {
            try {
                this.imWindow?.webContents.send(CALL_WINDOW_CLOSE_REPLY);
                this.destroy();
            } catch (err) {
                console.log(err);
            }
        });
    }

    offEventListiner() {
        ipcMain.removeAllListeners(OPEN_CALL_WINDOW);
        ipcMain.removeAllListeners('change-window-size');

        ipcMain.removeAllListeners('accept-call')

        // As the receiver, hang up and close the window
        ipcMain.removeAllListeners('refuse-call');

        // When the recipient rejects the call, call this method to close the window and exit the room
        ipcMain.removeAllListeners(CLOSE_CALL_WINDOW);

        ipcMain.removeAllListeners(END_CALL_WINDOW)
        // remote user access
        ipcMain.removeAllListeners('remote-user-join');

        // Remote user leaves
        ipcMain.removeAllListeners('remote-user-exit');

        // Cancel call invitation
        ipcMain.removeAllListeners('cancel-call-invite');

        // Update the invitation list (when the user rejects the invitation, the call window needs to be notified)
        ipcMain.removeAllListeners('update-invite-list');
    }
};

module.exports = CallWindowIpc;