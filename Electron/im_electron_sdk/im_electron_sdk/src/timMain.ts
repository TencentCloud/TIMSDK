import { ipcMain, BrowserWindow } from "electron";

import { TIMIPCLISTENR, CONSOLETAG } from "./const/const";
import { initConfig } from "./interface";
import { ipcData } from "./interface/ipcInterface";
import TIM from "./tim";
import path from "path";
import os from "os";
import { escapeUnicode, mkdirsSync } from "./utils/utils";
// import log from "./utils/log";
const log = {
    info: function (...args: any) {},
    error: function (...args: any) {},
};
const recvNewMsgCallback = null;

class Callback {
    private requestData;
    private tim;
    private ipcEvent;
    constructor(request: any, timInstance: any, event: any) {
        this.requestData = request;
        this.tim = timInstance;
        this.ipcEvent = event;
    }

    private getManager() {
        const { manager } = this.requestData;
        let timManager;
        switch (manager) {
            case "timBaseManager":
                timManager = this.tim.getTimbaseManager();
                break;
            case "advanceMessageManager":
                timManager = this.tim.getAdvanceMessageManager();
                break;
            case "conversationManager":
                timManager = this.tim.getConversationManager();
                break;
            case "friendshipManager":
                timManager = this.tim.getFriendshipManager();
                break;
            case "groupManager":
                timManager = this.tim.getGroupManager();
                break;
            default:
                throw new Error("no such manager,check and try again.");
        }
        return timManager;
    }

    async getResponse(cb?: Function) {
        const startTime = Date.now();
        const { method, param, callback } = this.requestData;
        console.log("requestData:", this.requestData);
        const timManager = this.getManager();
        if (timManager && timManager[method]) {
            try {
                let responseData;
                if (callback) {
                    console.log(
                        "===========add callback successfully=========="
                    );
                    //@ts-ignore
                    if (param) {
                        param.callback = cb;
                    }
                }
                try {
                    log.info(`${method} 入参:`, param);
                    param
                        ? (responseData = await timManager[method](param))
                        : (responseData = await timManager[method]());
                } catch (err) {
                    log.info(`${method} error:`, err);
                    responseData = err;
                }

                console.log(
                    `${CONSOLETAG}${method} is called . use ${
                        Date.now() - startTime
                    } ms.`,
                    `param：${param}`,
                    `data：${responseData}`
                );
                // if (responseData) {
                //     if (responseData.json_param) {
                //         responseData.json_param = escapeUnicode(
                //             responseData.json_param
                //         );
                //     }
                //     if (responseData.json_params) {
                //         responseData.json_params = escapeUnicode(
                //             responseData.json_params
                //         );
                //     }
                // }
                return JSON.stringify({ callback, data: responseData });
            } catch (error) {
                console.log("some errors", error);
            }
        }
        throw new Error("no such method , check and try again.");
    }
}

class TimMain {
    private isLisened = false;
    static _callback: Map<string, Function> = new Map();
    static event: Map<string, any> = new Map();
    static _callingInfo: Map<string, any> = new Map();
    private _tim: TIM;

    constructor(config: initConfig) {
        this._tim = new TIM({
            sdkappid: config.sdkappid,
        });

        try {
            require("@electron/remote/main").initialize();
        } catch (err) {}

        mkdirsSync(path.resolve(os.homedir(), ".tencent-im"));
        //建立ipc通信通道
        if (!this.isLisened) {
            ipcMain.handle(TIMIPCLISTENR, async (event, data: ipcData<any>) => {
                const requestData = JSON.parse(data as unknown as string);
                const { callback, method, windowID = 1 } = requestData;
                let cb;
                if (callback) {
                    const cbs = TimMain.event.get(callback);

                    if (!cbs) {
                        const cbsObj: any = {};
                        cbsObj[windowID] = event;
                        TimMain.event.set(callback, cbsObj);
                    } else {
                        cbs[windowID] = event;
                        TimMain.event.set(callback, cbs);
                    }

                    cb = (...args: any) => {
                        console.log("callback-response", method);
                        if (TimMain.event.get(callback)) {
                            try {
                                const replayCbs = TimMain.event.get(callback);
                                Object.keys(replayCbs).map(item => {
                                    log.info(
                                        `${callback} window ${item} replay`
                                    );
                                    console.log(
                                        `${callback} window ${item} replay`
                                    );
                                    // if (args && args.length) {
                                    //     for (let i = 0; i < args.length; i++) {
                                    //         if (args[i].json_param) {
                                    //             args[i].json_param =
                                    //                 escapeUnicode(
                                    //                     args[i].json_param
                                    //                 );
                                    //         }
                                    //         if (args[i].json_params) {
                                    //             args[i].json_params =
                                    //                 escapeUnicode(
                                    //                     args[i].json_params
                                    //                 );
                                    //         }
                                    //     }
                                    // }
                                    try {
                                        replayCbs[item]?.sender?.send(
                                            `global-callback-reply`,
                                            JSON.stringify({
                                                callbackKey: callback,
                                                responseData: args,
                                            })
                                        );
                                    } catch (err) {
                                        log.error("渲染进程丢失", err);
                                    }
                                });
                            } catch (err) {
                                log.error("主渲染窗口事件绑定丢失", err);
                            }
                        } else {
                            log.error("主渲染窗口事件绑定丢失");
                        }
                    };
                    if (!TimMain._callback.has(callback)) {
                        TimMain._callback.set(callback, cb);
                    }
                }
                const requestInstance = new Callback(
                    requestData,
                    this._tim,
                    event
                );
                const response = await requestInstance.getResponse(
                    callback ? TimMain._callback.get(callback) : () => {}
                );
                return response;
            });
            ipcMain.handle("_setCallInfo", (event, data) => {
                try {
                    const { inviteID, data: callInfo } = JSON.parse(data);
                    this._setCallInfo(inviteID, callInfo);
                } catch (err) {
                    log.info(`_setCallInfo error ${data}`);
                }
            });
            ipcMain.handle("_getCallInfo", (event, data) => {
                try {
                    const { inviteID } = JSON.parse(data);
                    return this._getCallInfo(inviteID);
                } catch (err) {
                    log.info(`_getCallInfo error ${data}`);
                }
            });
            ipcMain.handle("_deleteCallInfo", (event, data) => {
                try {
                    const { inviteID } = JSON.parse(data);
                    return this._deleteCallInfo(inviteID);
                } catch (err) {
                    log.info(`_deleteCallInfo error ${data}`);
                }
            });
            this.isLisened = true;
        }
    }
    private _setCallInfo(inviteID: string, data: object) {
        TimMain._callingInfo.set(inviteID, data);
    }
    private _getCallInfo(inviteID: string): string {
        return JSON.stringify(TimMain._callingInfo.get(inviteID));
    }
    private _deleteCallInfo(inviteID: string) {
        TimMain._callingInfo.delete(inviteID);
    }
    destroy() {
        ipcMain.removeHandler(TIMIPCLISTENR);
        ipcMain.removeHandler("_setCallInfo");
        ipcMain.removeHandler("_getCallInfo");
        ipcMain.removeHandler("_deleteCallInfo");
        this._tim.getAdvanceMessageManager().TIMRemoveRecvNewMsgCallback();
        this._tim.getTimbaseManager().TIMUninit();
    }
    enable(webContents: any) {
        require("@electron/remote/main").enable(webContents);
    }
    setSDKAPPID(sdkappid: number) {
        console.log(`更新sdkappid ${sdkappid}`);
        this._tim.setSDKAPPID(sdkappid);
        this._tim.getAdvanceMessageManager().setSDKAPPID(sdkappid);
        this._tim.getConversationManager().setSDKAPPID(sdkappid);
        this._tim.getFriendshipManager().setSDKAPPID(sdkappid);
        this._tim.getTimbaseManager().setSDKAPPID(sdkappid);
    }
}
export default TimMain;
