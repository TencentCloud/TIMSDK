import {
    CommonCallbackFun,
    GroupAttributeCallbackFun,
    GroupTipCallBackFun,
    TIMSetKickedOfflineCallback,
    TIMSetUserSigExpiredCallback,
    TIMSetNetworkStatusListenerCallback,
    TIMLogCallbackFun,
    GroupReadMembersCallback,
} from "../interface";
import {
    convEventCallback,
    convTotalUnreadMessageCountChangedCallback,
} from "../interface/conversationInterface";
import { app } from "electron";
const path = require("path");
const os = require("os");
const ffi = require("ffi-napi");
const fs = require("fs");
const voidPtrType = function () {
    return ffi.types.CString;
};
const charPtrType = function () {
    return ffi.types.CString;
};
const int32Type = function () {
    return ffi.types.int32;
};
const int64Type = function () {
    return ffi.types.uint64;
};
const voidType = function () {
    return ffi.types.void;
};
const intType = function () {
    return ffi.types.int;
};

const ffipaths: any = {
    linux: app.isPackaged
        ? path.resolve(process.resourcesPath, "linux/lib/libImSDK.so")
        : path.resolve(
              process.cwd(),
              "node_modules/im_electron_sdk/lib/linux/lib/libImSDK.so"
          ),
    x64: app.isPackaged
        ? path.resolve(process.resourcesPath, "windows/lib/Win64/ImSDK.dll")
        : path.resolve(
              process.cwd(),
              "node_modules/im_electron_sdk/lib/windows/lib/Win64/ImSDK.dll"
          ),
    ia32: app.isPackaged
        ? path.resolve(process.resourcesPath, "windows/lib/Win32/ImSDK.dll")
        : path.resolve(
              process.cwd(),
              "node_modules/im_electron_sdk/lib/windows/lib/Win32/ImSDK.dll"
          ),
    darwin: app.isPackaged
        ? path.resolve(process.resourcesPath, "mac/Versions/A/ImSDKForMac")
        : path.resolve(
              process.cwd(),
              "node_modules/im_electron_sdk/lib/mac/Versions/A/ImSDKForMac"
          ),
};
function mkdirsSync(dirname: string) {
    if (fs.existsSync(dirname)) {
        return true;
    } else {
        if (mkdirsSync(path.dirname(dirname))) {
            fs.mkdirSync(dirname);
            return true;
        }
    }
}
function randomString(e = 6) {
    const t = "ABCDEFGHJKMNPQRSTWXYZabcdefhijkmnprstwxyz2345678";
    const a = t.length;
    let n = "";
    for (let i = 0; i < e; i++) n += t.charAt(Math.floor(Math.random() * a));
    return n;
}
function getFFIPath() {
    let res = "";
    const platform = os.platform().toLowerCase();
    switch (platform) {
        case "linux":
            res = ffipaths[platform];
            break;
        case "win32":
            const cpu = os.arch();
            res = ffipaths[cpu];
            break;
        case "darwin":
            res = ffipaths[platform];
            break;
    }
    console.log("SDK路径", res);
    if (!res) {
        throw new Error(`tencent im sdk not support ${platform} os now.`);
        return;
    }
    return res;
}
function nodeStrigToCString(str: string): any {
    const buffer = Buffer.from(`${str}\0`, "utf8");
    return buffer;
}
function escapeUnicode(str: string) {
    return str.replace(
        /[\u0000\u00ad\u0600-\u0604\u070f\u17b4\u17b5\u200c-\u200f\u2028-\u202f\u2060-\u206f\ufeff\ufff0-\uffff]|[\u0001\u0002\u0003\u0004\u0005\u0006\u0007\u000b\u000e\u000f\u0010\u0011\u0012\u0013\u0014\u0015\u0016\u0017\u0018\u0019\u001a\u001b\u001c\u001d\u001e\u001f]/g,
        function (a) {
            return "\\u" + ("0000" + a.charCodeAt(0).toString(16)).slice(-4);
        }
    );
}

function jsFuncToFFIFun(fun: CommonCallbackFun) {
    const callback = ffi.Callback(
        voidType(),
        [int32Type(), charPtrType(), charPtrType(), voidPtrType()],
        function (
            code: number,
            desc: string,
            json_param: string,
            user_data?: any
        ) {
            fun(code, desc, json_param, user_data);
        }
    );
    return callback;
}
function jsFuncToFFIFunForGroupRead(fun: GroupReadMembersCallback) {
    const callback = ffi.Callback(
        voidType(),
        [charPtrType(), int64Type(), ffi.types.bool, voidPtrType()],
        function (
            json_group_member_array: string,
            next_seq: number,
            is_finished: boolean,
            user_data: any
        ) {
            fun(json_group_member_array, next_seq, is_finished, user_data);
        }
    );
    return callback;
}
function jsFuncToFFIConvEventCallback(fun: convEventCallback) {
    const callback = ffi.Callback(
        voidType(),
        [intType(), charPtrType(), voidPtrType()],
        function (
            conv_event: number,
            json_conv_array: string,
            user_data?: any
        ) {
            fun(conv_event, json_conv_array, user_data);
        }
    );
    return callback;
}

function jsFunToFFITIMSetConvTotalUnreadMessageCountChangedCallback(
    fun: convTotalUnreadMessageCountChangedCallback
) {
    const callback = ffi.Callback(
        voidType(),
        [intType(), voidPtrType()],
        function (total_unread_count: number, user_data?: any) {
            fun(total_unread_count, user_data);
        }
    );
    return callback;
}
function jsFunToFFITIMSetNetworkStatusListenerCallback(
    fun: TIMSetNetworkStatusListenerCallback
) {
    const callback = ffi.Callback(
        voidType(),
        [intType(), int32Type(), charPtrType(), voidPtrType()],
        function (
            status: number,
            code: number,
            desc: string,
            user_data?: string
        ) {
            fun(status, code, desc, user_data);
        }
    );
    return callback;
}

function jsFunToFFITIMSetKickedOfflineCallback(
    fun: TIMSetKickedOfflineCallback
) {
    const callback = ffi.Callback(
        voidType(),
        [voidPtrType()],
        function (user_data?: any) {
            fun(user_data);
        }
    );
    return callback;
}
function jsFunToFFITIMSetUserSigExpiredCallback(
    fun: TIMSetUserSigExpiredCallback
) {
    const callback = ffi.Callback(
        ffi.types.void,
        [voidPtrType()],
        function (user_data?: any) {
            fun(user_data);
        }
    );
    return callback;
}
function transformGroupTipFun(fun: GroupTipCallBackFun) {
    const callback = ffi.Callback(
        ffi.types.void,
        [charPtrType(), voidPtrType()],
        function (json_group_tip_array: string, user_data?: any) {
            fun(json_group_tip_array, user_data);
        }
    );
    return callback;
}

function transformGroupAttributeFun(fun: GroupAttributeCallbackFun) {
    const callback = ffi.Callback(
        ffi.types.void,
        [charPtrType(), charPtrType(), voidPtrType()],
        function (
            group_id: string,
            json_group_attibute_array: string,
            user_data?: any
        ) {
            fun(group_id, json_group_attibute_array, user_data);
        }
    );
    return callback;
}
function transferTIMLogCallbackFun(fun: TIMLogCallbackFun) {
    const callback = ffi.Callback(
        voidType(),
        [intType(), charPtrType(), voidPtrType()],
        function (level: number, log: string, user_data?: any) {
            fun(level, log, user_data);
        }
    );
    return callback;
}
export {
    getFFIPath,
    nodeStrigToCString,
    jsFuncToFFIFun,
    jsFuncToFFIConvEventCallback,
    jsFunToFFITIMSetConvTotalUnreadMessageCountChangedCallback,
    jsFunToFFITIMSetNetworkStatusListenerCallback,
    jsFunToFFITIMSetKickedOfflineCallback,
    jsFunToFFITIMSetUserSigExpiredCallback,
    transformGroupTipFun,
    transformGroupAttributeFun,
    transferTIMLogCallbackFun,
    randomString,
    mkdirsSync,
    escapeUnicode,
    jsFuncToFFIFunForGroupRead,
};
