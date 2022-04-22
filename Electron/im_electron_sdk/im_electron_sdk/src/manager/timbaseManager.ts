/**
 * 基础接口，包括基本的登陆，发送简单消息，回调等功能
 * @module TimbaseManager(基础接口)
 */
import {
    cache,
    callExperimentalAPIParam,
    CommonCallbackFun,
    commonResponse,
    getLoginUserIDParam,
    loginParam,
    logoutParam,
    sdkconfig,
    TIMProfileGetUserProfileListParam,
    TIMProfileModifySelfUserProfileParam,
    TIMSetConfigParam,
    TIMSetKickedOfflineCallbackParam,
    TIMSetLogCallbackParam,
    TIMSetNetworkStatusListenerCallbackParam,
    TIMSetUserSigExpiredCallbackParam,
} from "../interface";
import { initParam } from "../interface/basicInterface";
import path from "path";
import {
    jsFuncToFFIFun,
    jsFunToFFITIMSetKickedOfflineCallback,
    jsFunToFFITIMSetNetworkStatusListenerCallback,
    jsFunToFFITIMSetUserSigExpiredCallback,
    nodeStrigToCString,
    randomString,
    transferTIMLogCallbackFun,
} from "../utils/utils";
import { TIMInternalOperation, TIMLoginStatus } from "../enum";
import os from "os";
import fs from "fs";
// import log from "../utils/log";
const ffi = require("ffi-napi");
const voidPtrType = function () {
    return ffi.types.CString;
};
const charPtrType = function () {
    return ffi.types.CString;
};
const int32Type = function () {
    return ffi.types.int32;
};
const voidType = function () {
    return ffi.types.void;
};
const log = {
    info: function (...args: any) {},
    error: function (...args: any) {},
};
class TimbaseManager {
    private _sdkconfig: sdkconfig;
    private _callback: Map<String, Function> = new Map();
    private _ffiCallback: Map<String, Buffer> = new Map();
    private _cache: Map<String, Map<string, cache>> = new Map();
    /** @internal */
    constructor(config: sdkconfig) {
        this._sdkconfig = config;
    }
    /**
     * @brief ImSDK初始化
     * @category SDK相关(如初始化)
     * 
     * @return  {number}  返回 TIM_SUCC的枚举值 表示接口调用成功，其他值表示接口调用失败。每个返回值的定义请参见[枚举TIMResult](../../doc/enums/timresult.html)
     * @note 
     * 在使用ImSDK进一步操作之前，需要先初始化ImSDK

     */
    TIMInit(initParams?: initParam): Promise<number> {
        let sdkconfig: string;
        const { config_path } = initParams || {};
        if (config_path) {
            const res = fs.statSync(config_path);
            if (!res.isDirectory()) {
                log.info(`${config_path} is not a validate directory`);
                return Promise.resolve(-1);
            }
        }
        sdkconfig = JSON.stringify({
            sdk_config_log_file_path: config_path
                ? path.resolve(config_path, "sdk-log")
                : path.resolve(os.homedir(), ".tencent-im/sdk-log"),
            sdk_config_config_file_path: config_path
                ? path.resolve(config_path, "sdk-config")
                : path.resolve(os.homedir(), ".tencent-im/sdk-config"),
        });
        return new Promise(async resolve => {
            const data = await this.callExperimentalAPI({
                json_param: {
                    request_internal_operation:
                        TIMInternalOperation.kTIMInternalOperationSetUIPlatform,
                    request_set_ui_platform_param: "electron",
                },
            });
            console.log(data, this._sdkconfig.sdkappid);
            const res: number = this._sdkconfig.Imsdklib.TIMInit(
                this._sdkconfig.sdkappid,
                nodeStrigToCString(sdkconfig)
            );
            resolve(res);
        });
    }
    setSDKAPPID(sdkappid: number) {
        this._sdkconfig.sdkappid = sdkappid;
    }
    /**
     * ### ImSDK卸载
     * @category SDK相关(如初始化)
     * @return  {number}  返回 TIM_SUCC的枚举值 表示接口调用成功，其他值表示接口调用失败。每个返回值的定义请参见[枚举TIMResult](../../doc/enums/timresult.html)
     * @note
     * 卸载DLL或退出进程前需要此接口卸载ImSDK，清理ImSDK相关资源
     */
    TIMUninit(): number {
        return this._sdkconfig.Imsdklib.TIMUninit();
    }
    /**
     * @brief 获取ImSDK版本号
     * @category SDK相关(如初始化)
     * @return  String 返回ImSDK的版本号
     */
    TIMGetSDKVersion(): Buffer {
        return this._sdkconfig.Imsdklib.TIMGetSDKVersion();
    }

    /**
     * @brief  获取服务器当前时间
     * @return {number} 服务器时间
     * @category SDK相关(如初始化)
     * @note
     * 可用于信令离线推送场景下超时判断
     */
    TIMGetServerTime(): number {
        return this._sdkconfig.Imsdklib.TIMGetServerTime();
    }
    /**
     * ### 登录
     * @category 登录相关
     * @param loginParam 用户的UserID
     * @return  {Promise<commonResponse>} Promise的response返回值为：{ code, desc, json_params, user_data }
     *
     * @note
     * 用户登录腾讯后台服务器后才能正常收发消息，登录需要用户提供UserID、UserSig等信息，具体含义请参考[登录鉴权](https://cloud.tencent.com/document/product/269/31999)
     */
    TIMLogin(param: loginParam): Promise<commonResponse> {
        const userID = nodeStrigToCString(param.userID);
        const userSig = nodeStrigToCString(param.userSig);
        const userData = param.userData
            ? nodeStrigToCString(param.userData)
            : nodeStrigToCString("");

        return new Promise((resolve, reject) => {
            const code: number = this._sdkconfig.Imsdklib.TIMLogin(
                userID,
                userSig,
                this.jsFuncToFFIFun(resolve, reject),
                userData
            );
            code !== 0 && reject({ code });
        });
    }
    jsFuncToFFIFun(resolve: any, reject: any) {
        return ffi.Callback(
            voidType(),
            [int32Type(), charPtrType(), charPtrType(), voidPtrType()],
            function (
                code: number,
                desc: string,
                json_param: string,
                user_data?: any
            ) {
                if (code === 0) {
                    resolve({ code, desc, json_param, user_data });
                } else {
                    reject({ code, desc, json_param, user_data });
                }
            }
        );
    }
    /**
     * @brief  登出
     * @category 登录相关
     * @param logoutParam
     * @return  {Promise<commonResponse>} Promise的response返回值为：{ code, desc, json_params, user_data }
     * @note
     * 如用户主动登出或需要进行用户的切换，则需要调用登出操作
     */
    TIMLogout(param: logoutParam): Promise<commonResponse> {
        const userData = param.userData
            ? nodeStrigToCString(param.userData)
            : nodeStrigToCString("");
        return new Promise((resolve, reject) => {
            const now = `${Date.now()}${randomString()}`;
            const cb: CommonCallbackFun = (
                code,
                desc,
                json_param,
                user_data
            ) => {
                if (code === 0) {
                    resolve({ code, desc, json_param, user_data });
                } else {
                    reject({ code, desc, json_param, user_data });
                }
                this._cache.get("TIMLogout")?.delete(now);
            };
            const callback = jsFuncToFFIFun(cb);
            let cacheMap = this._cache.get("TIMLogout");
            if (cacheMap === undefined) {
                cacheMap = new Map();
            }
            cacheMap.set(now, {
                cb: cb,
                callback: callback,
            });
            this._cache.set("TIMLogout", cacheMap);
            const code = this._sdkconfig.Imsdklib.TIMLogout(
                this._cache.get("TIMLogout")?.get(now)?.callback,
                userData
            );
            code !== 0 && reject({ code });
        });
    }
    /**
     * @brief  获取登录状态
     * @category 登录相关
     * @param logoutParam
     * @return  {number} TIMLoginStatus 每个返回值的定义请参考 [TIMLoginStatus](../../doc/enums/enum.timloginstatus.html)
     * @note
     * 如果用户已经处于已登录和登录中状态，请勿再频繁调用登录接口登录
     */
    TIMGetLoginStatus(): TIMLoginStatus {
        return this._sdkconfig.Imsdklib.TIMGetLoginStatus();
    }
    /**
     * @brief 获取登陆用户的 userid
     * @category 登录相关
     * @param getLoginUserIDParam
     * @return  {Promise<commonResponse>} Promise的response返回值为：{ code, desc, json_params（登录用户的 userid）, user_data }
     *
     */
    TIMGetLoginUserID(): Promise<commonResponse> {
        return new Promise((resolve, reject) => {
            const user_id_buffer = Buffer.alloc(128);
            const code =
                this._sdkconfig.Imsdklib.TIMGetLoginUserID(user_id_buffer);
            code !== 0 && reject({ code });
            resolve({
                code,
                json_param: user_id_buffer.toString().split("\u0000")[0],
                desc: "",
                user_data: "",
            });
        });
    }
    private networkStatusListenerCallback(
        status: number,
        code: number,
        desc: string,
        user_data: string
    ) {
        const fn = this._callback.get("TIMSetNetworkStatusListenerCallback");
        fn && fn(status, code, desc, user_data);
    }
    private kickedOfflineCallback(user_data: string) {
        const fn = this._callback.get("TIMSetKickedOfflineCallback");
        fn && fn(user_data);
    }
    private userSigExpiredCallback(user_data: string) {
        const fn = this._callback.get("TIMSetUserSigExpiredCallback");
        fn && fn(user_data);
    }
    private logCallback(level: number, log: string, user_data: string) {
        const fn = this._callback.get("TIMSetLogCallback");
        fn && fn(level, log, user_data);
    }
    /**
     * ### 设置网络连接状态监听回调
     * @param TIMSetNetworkStatusListenerCallbackParam
     * @category 基础接口相关回调(callback)
     * @note
     * &emsp;
     * > 当调用接口 [TIMInit](./manager_timbasemanager.default.html#timinit) 时，ImSDK会去连接云后台。此接口设置的回调用于监听网络连接的状态。
     * > 网络连接状态包含四个：正在连接、连接失败、连接成功、已连接。这里的网络事件不表示用户本地网络状态，仅指明ImSDK是否与即时通信IM云Server连接状态。
     * > 可选设置，如果要用户感知是否已经连接服务器，需要设置此回调，用于通知调用者跟通讯后台链接的连接和断开事件，另外，如果断开网络，等网络恢复后会自动重连，自动拉取消息通知用户，用户无需关心网络状态，仅作通知之用
     * > 只要用户处于登录状态，ImSDK内部会进行断网重连，用户无需关心。
     */
    TIMSetNetworkStatusListenerCallback(
        param: TIMSetNetworkStatusListenerCallbackParam
    ) {
        const userData = param.userData
            ? nodeStrigToCString(param.userData)
            : nodeStrigToCString("");
        const c_callback = jsFunToFFITIMSetNetworkStatusListenerCallback(
            this.networkStatusListenerCallback.bind(this)
        );
        this._callback.set(
            "TIMSetNetworkStatusListenerCallback",
            param.callback
        );
        this._ffiCallback.set(
            "TIMSetNetworkStatusListenerCallback",
            c_callback
        );
        this._sdkconfig.Imsdklib.TIMSetNetworkStatusListenerCallback(
            this._ffiCallback.get(
                "TIMSetNetworkStatusListenerCallback"
            ) as Buffer,
            userData
        );
    }
    /**
     *  ### 设置被踢下线通知回调
     * @param TIMSetKickedOfflineCallbackParam
     * @category 基础接口相关回调(callback)
     * @note
     * &emsp;
     * > 用户如果在其他终端登录，会被踢下线，这时会收到用户被踢下线的通知，出现这种情况常规的做法是提示用户进行操作（退出，或者再次把对方踢下线）。
     * > 用户如果在离线状态下被踢，下次登录将会失败，可以给用户一个非常强的提醒（登录错误码ERR_IMSDK_KICKED_BY_OTHERS：6208），开发者也可以选择忽略这次错误，再次登录即可。
     * > 用户在线情况下的互踢情况：
     * +  用户在设备1登录，保持在线状态下，该用户又在设备2登录，这时用户会在设备1上强制下线，收到 TIMKickedOfflineCallback 回调。
     *    用户在设备1上收到回调后，提示用户，可继续调用login上线，强制设备2下线。这里是在线情况下互踢过程。
     * > 用户离线状态互踢:
     * +  用户在设备1登录，没有进行logout情况下进程退出。该用户在设备2登录，此时由于用户不在线，无法感知此事件，
     *    为了显式提醒用户，避免无感知的互踢，用户在设备1重新登录时，会返回（ERR_IMSDK_KICKED_BY_OTHERS：6208）错误码，表明之前被踢，是否需要把对方踢下线。
     *    如果需要，则再次调用login强制上线，设备2的登录的实例将会收到 TIMKickedOfflineCallback 回调。
     */
    TIMSetKickedOfflineCallback(param: TIMSetKickedOfflineCallbackParam) {
        const userData = param.userData
            ? nodeStrigToCString(param.userData)
            : nodeStrigToCString("");
        const c_callback = jsFunToFFITIMSetKickedOfflineCallback(
            this.kickedOfflineCallback.bind(this)
        );
        this._callback.set("TIMSetKickedOfflineCallback", param.callback);
        this._ffiCallback.set("TIMSetKickedOfflineCallback", c_callback);
        this._sdkconfig.Imsdklib.TIMSetKickedOfflineCallback(
            this._ffiCallback.get("TIMSetKickedOfflineCallback") as Buffer,
            userData
        );
    }

    /**
     * @brief 设置票据过期回调
     * @param TIMSetUserSigExpiredCallbackParam
     * @category 基础接口相关回调(callback)
     * @note
     * 用户票据，可能会存在过期的情况，如果用户票据过期，此接口设置的回调会调用。
     * [TIMLogin](./manager_timbasemanager.default.html#timlogin)也将会返回70001错误码。开发者可根据错误码或者票据过期回调进行票据更换
     */
    TIMSetUserSigExpiredCallback(param: TIMSetUserSigExpiredCallbackParam) {
        const userData = param.userData
            ? nodeStrigToCString(param.userData)
            : nodeStrigToCString("");
        const c_callback = jsFunToFFITIMSetUserSigExpiredCallback(
            this.userSigExpiredCallback.bind(this)
        );
        this._callback.set("TIMSetUserSigExpiredCallback", param.callback);
        this._ffiCallback.set("TIMSetUserSigExpiredCallback", c_callback);
        this._sdkconfig.Imsdklib.TIMSetUserSigExpiredCallback(
            this._ffiCallback.get("TIMSetUserSigExpiredCallback") as Buffer,
            userData
        );
    }
    /**
     * ### 设置日志回调
     * @param TIMSetLogCallbackParam TIMSetLogCallbackParam
     * @category 基础接口相关回调(callback)
     * @note
     * 设置日志监听的回调之后，ImSDK内部的日志会回传到此接口设置的回调。
     * 开发者可以通过接口[SetConfig](./manager_timbasemanager.default.html#timsetconfig)配置哪些日志级别的日志回传到回调函数。
     */
    // doc TODO 文档还需测试
    TIMSetLogCallback(param: TIMSetLogCallbackParam) {
        const user_data = param.user_data
            ? nodeStrigToCString(param.user_data)
            : nodeStrigToCString("");
        const c_callback = transferTIMLogCallbackFun(
            this.logCallback.bind(this)
        );
        this._callback.set("TIMSetLogCallback", param.callback);
        this._ffiCallback.set("TIMSetLogCallback", c_callback);
        this._sdkconfig.Imsdklib.TIMSetLogCallback(
            this._ffiCallback.get("TIMSetLogCallback") as Buffer,
            user_data
        );
    }
    /**
     * @brief  设置额外的用户配置
     * @param TIMSetConfigParam
     * @category 配置相关
     * @return  {Promise<commonResponse>} Promise的response返回值为：{ code, desc, json_params, user_data }
     * @note
     * 目前支持设置的配置有http代理的IP和端口、socks5代理的IP和端口、输出日志的级别、获取群信息/群成员信息的默认选项、是否接受消息已读回执事件等。
     * http代理的IP和端口、socks5代理的IP和端口建议调用[TIMInit](./manager_timbasemanager.default.html#timinit)之前配置。
     * 每项配置可以单独设置，也可以一起配置,详情请参考 [SetConfig](./manager_timbasemanager.default.html#timsetconfig)。
     */
    TIMSetConfig(param: TIMSetConfigParam) {
        const user_data = param.user_data
            ? nodeStrigToCString(param.user_data)
            : nodeStrigToCString("");
        const json_config = nodeStrigToCString(
            JSON.stringify(param.json_config)
        );
        return new Promise((resolve, reject) => {
            const now = `${Date.now()}${randomString()}`;

            const cb: CommonCallbackFun = (
                code,
                desc,
                json_param,
                user_data
            ) => {
                if (code === 0) {
                    resolve({ code, desc, json_param, user_data });
                } else {
                    reject({ code, desc, json_param, user_data });
                }
                this._cache.get("TIMSetConfig")?.delete(now);
            };
            const callback = jsFuncToFFIFun(cb);
            let cacheMap = this._cache.get("TIMSetConfig");
            if (cacheMap === undefined) {
                cacheMap = new Map();
            }
            cacheMap.set(now, {
                cb: cb,
                callback: callback,
            });
            this._cache.set("TIMSetConfig", cacheMap);
            const code = this._sdkconfig.Imsdklib.TIMSetConfig(
                json_config,
                this._cache.get("TIMSetConfig")?.get(now)?.callback,
                user_data
            );
            code !== 0 && reject({ code });
        });
    }
    /**
     * @brief  实验性接口
     * @param  callExperimentalAPIParam
     * @category 实验接口
     * @return {Promise<commonResponse>} Promise的response返回值为：{ code, desc, json_params, user_data }
     */
    callExperimentalAPI(
        param: callExperimentalAPIParam
    ): Promise<commonResponse> {
        const user_data = param.user_data
            ? nodeStrigToCString(param.user_data)
            : nodeStrigToCString("");
        const json_param = nodeStrigToCString(JSON.stringify(param.json_param));
        console.log(json_param);
        return new Promise(resolve => {
            const now = `${Date.now()}${randomString()}`;

            const cb: CommonCallbackFun = (
                code,
                desc,
                json_param,
                user_data
            ) => {
                if (code === 0) {
                    resolve({ code, desc, json_param, user_data });
                } else {
                    resolve({ code, desc, json_param, user_data });
                }
                this._cache.get("callExperimentalAPI")?.delete(now);
            };
            const callback = jsFuncToFFIFun(cb);
            let cacheMap = this._cache.get("callExperimentalAPI");
            if (cacheMap === undefined) {
                cacheMap = new Map();
            }
            cacheMap.set(now, {
                cb: cb,
                callback: callback,
            });
            this._cache.set("callExperimentalAPI", cacheMap);
            const code = this._sdkconfig.Imsdklib.callExperimentalAPI(
                json_param,
                this._cache.get("callExperimentalAPI")?.get(now)?.callback,
                user_data
            );
            code !== 0 && resolve({ code });
            code === 0 && resolve({ code });
        });
    }
    /**
     * @brief 获取指定用户列表的个人资料
     * @param TIMProfileGetUserProfileListParam
     * @category 资料相关接口
     * @return {Promise<commonResponse>} Promise的response返回值为：{ code, desc, json_params, user_data }
     * @note
     * 可以通过该接口获取任何人的个人资料，包括自己的个人资料。
     * PS:用户资料相关接口 [资料系统简介](https://cloud.tencent.com/document/product/269/1500#.E8.B5.84.E6.96.99.E7.B3.BB.E7.BB.9F.E7.AE.80.E4.BB.8B)
     */
    TIMProfileGetUserProfileList(
        param: TIMProfileGetUserProfileListParam
    ): Promise<commonResponse> {
        const userData = param.user_data
            ? nodeStrigToCString(param.user_data)
            : nodeStrigToCString("");
        const json_param = nodeStrigToCString(
            JSON.stringify(param.json_get_user_profile_list_param)
        );

        return new Promise((resolve, reject) => {
            const now = `${Date.now()}${randomString()}`;

            const cb: CommonCallbackFun = (
                code,
                desc,
                json_param,
                user_data
            ) => {
                if (code === 0) {
                    resolve({ code, desc, json_param, user_data });
                } else {
                    reject({ code, desc, json_param, user_data });
                }
                this._cache.get("TIMProfileGetUserProfileList")?.delete(now);
            };
            const callback = jsFuncToFFIFun(cb);
            let cacheMap = this._cache.get("TIMProfileGetUserProfileList");
            if (cacheMap === undefined) {
                cacheMap = new Map();
            }
            cacheMap.set(now, {
                cb: cb,
                callback: callback,
            });
            this._cache.set("TIMProfileGetUserProfileList", cacheMap);
            const code = this._sdkconfig.Imsdklib.TIMProfileGetUserProfileList(
                json_param,
                this._cache.get("TIMProfileGetUserProfileList")?.get(now)
                    ?.callback,
                userData
            );
            code !== 0 && reject({ code });
        });
    }
    /**
     * @brief 修改自己的个人资料
     * @param  TIMProfileModifySelfUserProfileParam
     * @category 资料相关接口
     * @return {Promise<commonResponse>} json_param 返回TIM_SUCC表示接口调用成功（接口只有返回TIM_SUCC，回调cb才会被调用），其他值表示接口调用失败。每个返回值的定义请参考 [TIMResult](../../doc/enums/timresult.html)
     */
    TIMProfileModifySelfUserProfile(
        param: TIMProfileModifySelfUserProfileParam
    ): Promise<commonResponse> {
        const userData = param.user_data
            ? nodeStrigToCString(param.user_data)
            : nodeStrigToCString("");
        const json_param = nodeStrigToCString(
            JSON.stringify(param.json_modify_self_user_profile_param)
        );

        return new Promise((resolve, reject) => {
            const now = `${Date.now()}${randomString()}`;

            const cb: CommonCallbackFun = (
                code,
                desc,
                json_param,
                user_data
            ) => {
                if (code === 0) {
                    resolve({ code, desc, json_param, user_data });
                } else {
                    reject({ code, desc, json_param, user_data });
                }
                this._cache.get("TIMProfileModifySelfUserProfile")?.delete(now);
            };
            const callback = jsFuncToFFIFun(cb);
            let cacheMap = this._cache.get("TIMProfileModifySelfUserProfile");
            if (cacheMap === undefined) {
                cacheMap = new Map();
            }
            cacheMap.set(now, {
                cb: cb,
                callback: callback,
            });
            this._cache.set("TIMProfileModifySelfUserProfile", cacheMap);
            const code =
                this._sdkconfig.Imsdklib.TIMProfileModifySelfUserProfile(
                    json_param,
                    this._cache.get("TIMProfileModifySelfUserProfile")?.get(now)
                        ?.callback,
                    userData
                );
            code !== 0 && reject({ code });
        });
    }
}
export default TimbaseManager;
