import { TIMIPCLISTENR } from "./const/const";
import { v4 as uuidv4 } from "uuid";
import {
    loginParam,
    CreateGroupParams,
    commonResponse,
    logoutParam,
    getLoginUserIDParam,
    GroupAttributeCallbackParams,
    InitGroupAttributeParams,
    DeleteAttributeParams,
    GroupTipsCallbackParams,
    TIMSetNetworkStatusListenerCallbackParam,
    DeleteGroupParams,
    DeleteMemberParams,
    GetGroupListParams,
    GetGroupMemberInfoParams,
    GetOnlineMemberCountParams,
    GetPendencyListParams,
    HandlePendencyParams,
    InviteMemberParams,
    // JoinGroupParams,
    ModifyGroupParams,
    ModifyMemberInfoParams,
    QuitGroupParams,
    ReportParams,
    SearchGroupParams,
    SearchMemberParams,
    GetFriendProfileListParams,
    AddFriendParams,
    DeleteFriendParams,
    ModifyFriendProfileParams,
    CheckFriendTypeParams,
    CreateFriendGroupParams,
    FriendshipStringArrayParams,
    GetBlackListParams,
    HandleFriendAddParams,
    ModifyFriendGroupParams,
    FriendshipGetPendencyListParams,
    DeletePendencyParams,
    ReportPendencyReadedParams,
    SearchFriendsParams,
    TIMSetUserSigExpiredCallbackParam,
    TIMSetKickedOfflineCallbackParam,
    TIMOnAddFriendCallbackParams,
    TIMOnDeleteFriendCallbackParams,
    TIMUpdateFriendProfileCallbackParams,
    TIMFriendAddRequestCallbackParams,
    TIMFriendApplicationListDeletedCallbackParams,
    TIMFriendApplicationListReadCallbackParams,
    TIMFriendBlackListAddedCallbackParams,
    TIMFriendBlackListDeletedCallbackParams,
    MsgSendMessageParams,
    MsgSendMessageParamsV2,
    MsgCancelSendParams,
    MsgFindMessagesParams,
    MsgReportReadedParams,
    MsgRevokeParams,
    MsgFindByMsgLocatorListParams,
    MsgImportMsgListParams,
    MsgSaveMsgParams,
    MsgGetMsgListParams,
    MsgDeleteParams,
    MsgListDeleteParams,
    MsgClearHistoryMessageParams,
    MsgSetC2CReceiveMessageOptParams,
    MsgGetC2CReceiveMessageOptParams,
    MsgSetGroupReceiveMessageOptParams,
    MsgDownloadElemToPathParams,
    MsgDownloadMergerMessageParams,
    MsgBatchSendParams,
    MsgSearchLocalMessagesParams,
    TIMRecvNewMsgCallbackParams,
    TIMMsgReadedReceiptCallbackParams,
    TIMMsgRevokeCallbackParams,
    TIMMsgElemUploadProgressCallbackParams,
    TIMMsgUpdateCallbackParams,
    TIMSetConfigParam,
    TIMSetLogCallbackParam,
    callExperimentalAPIParam,
    TIMProfileModifySelfUserProfileParam,
    TIMProfileGetUserProfileListParam,
    convCancelDraft,
    convCreate,
    convDelete,
    convGetConvInfo,
    convGetTotalUnreadMessageCount,
    convPinConversation,
    convSetDrat,
    convTotalUnreadMessageCountChangedCallbackParam,
    getConvList,
    setConvEventCallback,
    ActionType,
    customDataTpl,
    handleParam,
    signalCallback,
    TRTCCallingCallGroupParam,
    TRTCCallingCallParam,
    initParam,
    MsgSendReplyMessage,
    MsgSendGroupMessageReceiptsParam,
    MsgGetGroupMessageReceiptsParam,
    MsgGetGroupMessageReadMembersParam,
    MsgGroupMessageReceiptCallbackParam,
} from "./interface";
import { ipcData, Managers } from "./interface/ipcInterface";
import { ipcRenderer } from "electron";
import { TIMConvType } from "./enum";
import log from "./utils/log";
import { getCurrentWindow } from "@electron/remote";

const deepClone = (obj: object) => {
    if (!obj) {
        return false;
    }
    // 先简单实现
    return JSON.parse(JSON.stringify(obj));
};

interface JoinGroupParams {
    groupId: string;
    helloMsg?: string;
    data?: string;
}

interface TestInterface {
    a: string;
    b: string;
}

export default class TimRender {
    static runtime: Map<string, Function> = new Map();
    static isListened = false;
    private _currentWindowID = getCurrentWindow().id;

    constructor() {
        if (!TimRender.isListened) {
            ipcRenderer.on(`global-callback-reply`, (e: any, res: any) => {
                try {
                    const { callbackKey, responseData } = JSON.parse(res);
                    log.info("事件回调返回渲染进程", JSON.parse(res));
                    if (this._getCallback(callbackKey)) {
                        //@ts-ignore
                        this._getCallback(callbackKey)(responseData);

                        // 处理信令的逻辑

                        if (callbackKey === "TIMAddRecvNewMsgCallback") {
                            //收到消息
                            this._handleMessage(responseData[0]);
                        }
                    }
                } catch (err) {
                    console.error("全局回调异常", err);
                }
            });

            TimRender.isListened = true;
        }
    }
    private async _handleMessage(message: any) {
        if (message) {
            try {
                const messageItems = JSON.parse(message);
                console.log("收到消息", messageItems);

                for (let j = 0; j < messageItems.length; j++) {
                    const { message_elem_array } = messageItems[j];
                    for (let i = 0; i < message_elem_array.length; i++) {
                        const { elem_type } = message_elem_array[i];
                        if (elem_type === 3) {
                            // 自定义消息
                            const { custom_elem_data } = message_elem_array[i];
                            try {
                                const parasedData =
                                    JSON.parse(custom_elem_data);
                                if (parasedData) {
                                    const { inviteID, actionType } =
                                        parasedData;
                                    if (inviteID) {
                                        // 是信令消息
                                        switch (actionType) {
                                            case ActionType.INVITE:
                                                this._onInvited(
                                                    inviteID,
                                                    parasedData,
                                                    message
                                                );
                                                break;
                                            case ActionType.ACCEPT_INVITE:
                                                this._onAccepted(
                                                    inviteID,
                                                    parasedData,
                                                    message
                                                );
                                                break;
                                            case ActionType.CANCEL_INVITE:
                                                this._onCanceled(
                                                    inviteID,
                                                    parasedData,
                                                    message
                                                );
                                                break;
                                            case ActionType.INVITE_TIMEOUT:
                                                this._onTimeouted(
                                                    inviteID,
                                                    parasedData,
                                                    message
                                                );
                                                break;
                                            case ActionType.REJECT_INVITE:
                                                this._onRejected(
                                                    inviteID,
                                                    parasedData,
                                                    message
                                                );
                                                break;
                                        }
                                    }
                                }
                            } catch (err) {
                                log.error(
                                    "IM_ELECTRON_SDK:尝试解析信令失败，业务可不关注"
                                );
                                console.log(
                                    "IM_ELECTRON_SDK:尝试解析信令失败，业务可不关注"
                                );
                            }
                        }
                    }
                }
            } catch (err) {
                log.error("解析消息失败：", err);
                console.error("解析消息失败：", err);
            }
        }
    }
    private async _call(data: any): Promise<commonResponse> {
        const response = await ipcRenderer.invoke(
            TIMIPCLISTENR,
            JSON.stringify(data)
        );
        return JSON.parse(response);
    }

    private async _getCallInfo(inviteID: string): Promise<object> {
        const resStrng = await ipcRenderer.invoke(
            "_getCallInfo",
            JSON.stringify({ inviteID })
        );
        return resStrng ? JSON.parse(resStrng) : "";
    }
    private async _setCallInfo(inviteID: string, data: object) {
        await ipcRenderer.invoke(
            "_setCallInfo",
            JSON.stringify({
                inviteID,
                data,
            })
        );
    }
    private async _deleteCallInfo(inviteID: string) {
        await ipcRenderer.invoke(
            "_deleteCallInfo",
            JSON.stringify({
                inviteID,
            })
        );
    }
    testDoc(param: TestInterface) {}

    private getAbstractMsgText(message: any): string {
        const displayTextMsg = message && message.text_elem_content;
        const displayFileMsg = message && message.file_elem_file_name;
        const displayContent = {
            "0": displayTextMsg,
            "1": "[图片]",
            "2": "[声音]",
            "3": "[自定义消息]",
            "4": `[${displayFileMsg}]`,
            "5": "[群组系统消息]",
            "6": "[表情]",
            "7": "[位置]",
            "8": "[群组系统通知]",
            "9": "[视频]",
            "10": "[关系]",
            "11": "[资料]",
            "12": "[合并消息]",
        }[message.elem_type as number];
        return displayContent;
    }

    private async _onInvited(inviteID: string, parsedData: any, message: any) {
        try {
            //@ts-ignore
            const { data: serverTime } = await this.TIMGetServerTime();
            const msg = JSON.parse(message)[0];
            const { message_server_time } = msg;
            const { timeout } = parsedData;

            if (timeout > 0 && serverTime - message_server_time > timeout) {
                console.log(
                    `signaling receive invitation but ignore to callback because timeInterval:${
                        serverTime - message_server_time
                    } > timeout: ${timeout}`
                );
                return null;
            }
            //@ts-ignore
            const userID = (await this.TIMGetLoginUserID({})).data.json_param;
            const { inviteeList } = parsedData;
            if (
                inviteeList &&
                inviteeList.length &&
                inviteeList.includes(userID)
            ) {
                if (this._getCallback("TIMOnInvited")) {
                    await this._setCallInfo(inviteID, deepClone(parsedData));
                    //@ts-ignore
                    this._getCallback("TIMOnInvited")(message);
                    // 开始倒计时计算超时
                    if (timeout > 0) {
                        const { inviteID } = parsedData;
                        this._setCallingTimeout(inviteID, true, msg);
                    }
                }
            }
        } catch (err) {
            console.error(err);
        }
    }
    private async _onRejected(inviteID: string, parsedData: any, message: any) {
        const callInfo = deepClone(await this._getCallInfo(inviteID));
        if (callInfo) {
            //@ts-ignore
            const { inviteeList: rejectList } = parsedData;

            if (rejectList && rejectList.length) {
                const accepter = rejectList[0];
                if (this._getCallback("TIMOnRejected")) {
                    // 收到拒绝，要把人从inviteList里去掉
                    const { inviteeList } = callInfo;
                    const newInviteeList =
                        inviteeList?.filter(
                            (item: string) => item !== accepter
                        ) || [];

                    log.info(
                        `acceptList ${rejectList},newInviteeList :${newInviteeList}`
                    );
                    if (newInviteeList.length > 0) {
                        callInfo.inviteeList = newInviteeList;
                        await this._setCallInfo(inviteID, callInfo);
                    } else {
                        await this._deleteCallInfo(inviteID);
                    }
                    //@ts-ignore
                    this._getCallback("TIMOnRejected")(message);
                }
            }
        }
    }
    private async _onAccepted(inviteID: string, parsedData: any, message: any) {
        const callInfo = deepClone(await this._getCallInfo(inviteID));
        if (callInfo) {
            //@ts-ignore
            const { inviteeList: acceptList } = parsedData;

            if (acceptList && acceptList.length) {
                const accepter = acceptList[0];

                if (this._getCallback("TIMOnAccepted")) {
                    // 收到拒绝，要把人从inviteList里去掉
                    const { inviteeList } = callInfo;
                    const newInviteeList =
                        inviteeList?.filter(
                            (item: string) => item !== accepter
                        ) || [];
                    log.info(
                        `acceptList ${acceptList},newInviteeList :${newInviteeList}`
                    );
                    if (newInviteeList?.length > 0) {
                        callInfo.inviteeList = newInviteeList;
                        await this._setCallInfo(inviteID, callInfo);
                    } else {
                        await this._deleteCallInfo(inviteID);
                    }
                    //@ts-ignore
                    this._getCallback("TIMOnAccepted")(message);
                }
            }
        }
    }
    private async _onCanceled(inviteID: string, parsedData: any, message: any) {
        const callInfo = deepClone(await this._getCallInfo(inviteID));
        if (callInfo) {
            if (this._getCallback("TIMOnCanceled")) {
                await this._deleteCallInfo(inviteID);
                //@ts-ignore
                this._getCallback("TIMOnCanceled")(message);
            }
        }
    }
    private async _onTimeouted(
        inviteID: string,
        parsedData: any,
        message: any
    ) {
        //@ts-ignore
        const { inviteeList: timeouter } = parsedData;
        const handler = timeouter[0];
        if (timeouter && timeouter.length) {
            if (this._getCallback("TIMOnTimeout")) {
                const callInfo = deepClone(await this._getCallInfo(inviteID));
                const { inviteeList } = callInfo;
                const newInviteeList =
                    inviteeList?.filter((item: any) => item !== handler) || [];
                if (newInviteeList.length > 0) {
                    parsedData.inviteeList = newInviteeList;
                    await this._setCallInfo(inviteID, parsedData);
                } else {
                    await this._deleteCallInfo(inviteID);
                }
                //@ts-ignore

                this._getCallback("TIMOnTimeout")(message);
            }
        }
    }
    private _setCallback(key: string, callback: Function) {
        TimRender.runtime.set(`${key}_${this._currentWindowID}`, callback);
    }
    private _getCallback(key: string) {
        return TimRender.runtime.get(`${key}_${this._currentWindowID}`);
    }
    /**
     * Example
     *
     * ```typescript
     * import TimRender from "im_electron_sdk/dist/renderer";
     * // 初始化TimeRender 示例
     * const timRenderInstance = new TimRender();
     *
     * const callback = (data) => console.log(data);
     * timRenderInstance.TIMOnInvited(callback)
     * ```
     */
    TIMOnInvited(param: signalCallback) {
        return new Promise(resolve => {
            this._setCallback("TIMOnInvited", param.callback);
            resolve({});
        });
    }
    /**
     * Example
     *
     * ```typescript
     * import TimRender from "im_electron_sdk/dist/renderer";
     * // 初始化TimeRender 示例
     * const timRenderInstance = new TimRender();
     *
     * const callback = (data) => console.log(data);
     * timRenderInstance.TIMOnRejected(callback)
     * ```
     */
    TIMOnRejected(param: signalCallback) {
        return new Promise(resolve => {
            this._setCallback("TIMOnRejected", param.callback);
            resolve({});
        });
    }
    /**
     * Example
     *
     * ```typescript
     * import TimRender from "im_electron_sdk/dist/renderer";
     * // 初始化TimeRender 示例
     * const timRenderInstance = new TimRender();
     *
     * const callback = (data) => console.log(data);
     * timRenderInstance.TIMOnAccepted(callback)
     * ```
     */
    TIMOnAccepted(param: signalCallback) {
        return new Promise(resolve => {
            this._setCallback("TIMOnAccepted", param.callback);
            resolve({});
        });
    }
    /**
     * Example
     *
     * ```typescript
     * import TimRender from "im_electron_sdk/dist/renderer";
     * // 初始化TimeRender 示例
     * const timRenderInstance = new TimRender();
     *
     * const callback = (data) => console.log(data);
     * timRenderInstance.TIMOnCanceled(callback)
     * ```
     */
    TIMOnCanceled(param: signalCallback) {
        return new Promise(resolve => {
            this._setCallback("TIMOnCanceled", param.callback);
            resolve({});
        });
    }
    /**
     * Example
     *
     * ```typescript
     * import TimRender from "im_electron_sdk/dist/renderer";
     * // 初始化TimeRender 示例
     * const timRenderInstance = new TimRender();
     *
     * const callback = (data) => console.log(data);
     * timRenderInstance.TIMOnTimeout(callback)
     * ```
     */
    TIMOnTimeout(param: signalCallback) {
        return new Promise(resolve => {
            this._setCallback("TIMOnTimeout", param.callback);
            resolve({});
        });
    }
    TIMConvGetTotalUnreadMessageCount(param: convGetTotalUnreadMessageCount) {
        const formatedData = {
            method: "TIMConvGetTotalUnreadMessageCount",
            manager: Managers.conversationManager,
            param: param,
        };
        return this._call(formatedData);
    }
    TIMConvPinConversation(param: convPinConversation) {
        const formatedData = {
            method: "TIMConvPinConversation",
            manager: Managers.conversationManager,
            param: param,
        };
        return this._call(formatedData);
    }
    TIMConvGetConvInfo(param: convGetConvInfo) {
        const formatedData = {
            method: "TIMConvGetConvInfo",
            manager: Managers.conversationManager,
            param: param,
        };
        return this._call(formatedData);
    }
    TIMConvCancelDraft(param: convCancelDraft) {
        const formatedData = {
            method: "TIMConvCancelDraft",
            manager: Managers.conversationManager,
            param: param,
        };
        return this._call(formatedData);
    }
    TIMConvSetDraft(param: convSetDrat) {
        const formatedData = {
            method: "TIMConvSetDraft",
            manager: Managers.conversationManager,
            param: param,
        };
        return this._call(formatedData);
    }
    TIMConvGetConvList(param: getConvList) {
        const formatedData = {
            method: "TIMConvGetConvList",
            manager: Managers.conversationManager,
            param: param,
        };
        return this._call(formatedData);
    }
    TIMConvDelete(param: convDelete) {
        const formatedData = {
            method: "TIMConvDelete",
            manager: Managers.conversationManager,
            param: param,
        };
        return this._call(formatedData);
    }
    TIMConvCreate(param: convCreate) {
        const formatedData = {
            method: "TIMConvCreate",
            manager: Managers.conversationManager,
            param: param,
        };
        return this._call(formatedData);
    }
    TIMSetConvTotalUnreadMessageCountChangedCallback(
        param: convTotalUnreadMessageCountChangedCallbackParam
    ) {
        const callback = `TIMSetConvTotalUnreadMessageCountChangedCallback`;
        this._setCallback(callback, param.callback);
        //@ts-ignore
        param.callback = callback;
        const formatedData = {
            method: "TIMSetConvTotalUnreadMessageCountChangedCallback",
            manager: Managers.conversationManager,
            callback,
            windowID: this._currentWindowID,
            param: param,
        };
        return this._call(formatedData);
    }
    TIMSetConvEventCallback(param: setConvEventCallback) {
        const callback = `TIMSetConvEventCallback`;
        this._setCallback(callback, param.callback);
        //@ts-ignore
        param.callback = callback;
        const formatedData = {
            method: "TIMSetConvEventCallback",
            manager: Managers.conversationManager,
            callback,
            windowID: this._currentWindowID,
            param: param,
        };
        return this._call(formatedData);
    }
    TIMSetUserSigExpiredCallback(param: TIMSetUserSigExpiredCallbackParam) {
        const callback = `TIMSetUserSigExpiredCallback`;
        this._setCallback(callback, param.callback);
        //@ts-ignore
        param.callback = callback;
        const formatedData = {
            method: "TIMSetUserSigExpiredCallback",
            manager: Managers.timBaseManager,
            callback,
            windowID: this._currentWindowID,
            param: param,
        };
        return this._call(formatedData);
    }
    TIMSetKickedOfflineCallback(param: TIMSetKickedOfflineCallbackParam) {
        const callback = `TIMSetKickedOfflineCallback`;
        this._setCallback(callback, param.callback);
        //@ts-ignore
        param.callback = callback;
        const formatedData = {
            method: "TIMSetKickedOfflineCallback",
            manager: Managers.timBaseManager,
            callback,
            windowID: this._currentWindowID,
            param: param,
        };
        return this._call(formatedData);
    }
    TIMSetNetworkStatusListenerCallback(
        param: TIMSetNetworkStatusListenerCallbackParam
    ) {
        const callback = `TIMSetNetworkStatusListenerCallback`;
        this._setCallback(callback, param.callback);
        //@ts-ignore
        param.callback = callback;
        const formatedData = {
            method: "TIMSetNetworkStatusListenerCallback",
            manager: Managers.timBaseManager,
            callback,
            windowID: this._currentWindowID,
            param: param,
        };
        return this._call(formatedData);
    }
    TIMSetLogCallback(param: TIMSetLogCallbackParam) {
        const callback = `TIMSetLogCallback`;
        this._setCallback(callback, param.callback);
        //@ts-ignore
        param.callback = callback;
        const formatedData = {
            method: "TIMSetLogCallback",
            manager: Managers.timBaseManager,
            callback,
            windowID: this._currentWindowID,
            param: param,
        };
        return this._call(formatedData);
    }
    TIMUninit() {
        const formatedData = {
            method: "TIMUninit",
            manager: Managers.timBaseManager,
        };
        return this._call(formatedData);
    }
    TIMSetConfig(param: TIMSetConfigParam) {
        const formatedData = {
            method: "TIMSetConfig",
            manager: Managers.timBaseManager,
            param: param,
        };
        return this._call(formatedData);
    }
    TIMGetSDKVersion() {
        const formatedData = {
            method: "TIMGetSDKVersion",
            manager: Managers.timBaseManager,
        };
        return this._call(formatedData);
    }
    TIMGetServerTime() {
        const formatedData = {
            method: "TIMGetServerTime",
            manager: Managers.timBaseManager,
        };
        return this._call(formatedData);
    }
    TIMLogout(param: logoutParam) {
        const formatedData = {
            method: "TIMLogout",
            manager: Managers.timBaseManager,
            param: param,
        };
        return this._call(formatedData);
    }
    TIMInit(param?: initParam) {
        return this._call({
            method: "TIMInit",
            manager: Managers.timBaseManager,
            param: param,
        });
    }
    TIMGetLoginStatus() {
        const formatedData = {
            method: "TIMGetLoginStatus",
            manager: Managers.timBaseManager,
        };
        return this._call(formatedData);
    }
    TIMGetLoginUserID() {
        const formatedData = {
            method: "TIMGetLoginUserID",
            manager: Managers.timBaseManager,
            param: {},
        };
        return this._call(formatedData);
    }
    callExperimentalAPI(param: callExperimentalAPIParam) {
        const formatedData = {
            method: "callExperimentalAPI",
            manager: Managers.timBaseManager,
            param: param,
        };
        return this._call(formatedData);
    }
    TIMLogin(data: loginParam) {
        const formatedData = {
            method: "TIMLogin",
            manager: Managers.timBaseManager,
            param: data,
        };
        return this._call(formatedData);
    }
    TIMProfileGetUserProfileList(param: TIMProfileGetUserProfileListParam) {
        const formatedData = {
            method: "TIMProfileGetUserProfileList",
            manager: Managers.timBaseManager,
            param: param,
        };
        return this._call(formatedData);
    }
    TIMProfileModifySelfUserProfile(
        param: TIMProfileModifySelfUserProfileParam
    ) {
        const formatedData = {
            method: "TIMProfileModifySelfUserProfile",
            manager: Managers.timBaseManager,
            param: param,
        };
        return this._call(formatedData);
    }
    /**
     * @param data  Comment for parameter ´text´.
     */

    TIMGroupCreate(data: CreateGroupParams) {
        const formatedData: ipcData<CreateGroupParams> = {
            method: "TIMGroupCreate",
            manager: Managers.groupManager,
            param: data,
        };
        return this._call(formatedData);
    }

    TIMGroupInitGroupAttributes(
        initAttributesParams: InitGroupAttributeParams
    ) {
        const formatedData = {
            method: "TIMGroupInitGroupAttributes",
            manager: Managers.groupManager,
            param: initAttributesParams,
        };
        return this._call(formatedData);
    }

    TIMGroupSetGroupAttributes(setAttributesParams: InitGroupAttributeParams) {
        const formatedData = {
            method: "TIMGroupSetGroupAttributes",
            manager: Managers.groupManager,
            param: setAttributesParams,
        };
        return this._call(formatedData);
    }

    TIMGroupDeleteGroupAttributes(
        deleteAttributesParams: DeleteAttributeParams
    ) {
        const formatedData = {
            method: "TIMGroupDeleteGroupAttributes",
            manager: Managers.groupManager,
            param: deleteAttributesParams,
        };
        return this._call(formatedData);
    }

    TIMGroupGetGroupAttributes(getAttributeParams: DeleteAttributeParams) {
        const formatedData = {
            method: "TIMGroupGetGroupAttributes",
            manager: Managers.groupManager,
            param: getAttributeParams,
        };
        return this._call(formatedData);
    }

    TIMSetGroupAttributeChangedCallback(data: GroupAttributeCallbackParams) {
        const callback = "TIMSetGroupAttributeChangedCallback";
        const formatedData = {
            method: "TIMSetGroupAttributeChangedCallback",
            manager: Managers.groupManager,
            callback,
            windowID: this._currentWindowID,
            param: data,
        };

        this._setCallback(callback, data.callback as unknown as Function);
        return this._call(formatedData);
    }

    TIMSetGroupTipsEventCallback(data: GroupTipsCallbackParams) {
        const callback = "TIMSetGroupTipsEventCallback";
        const formatedData = {
            method: "TIMSetGroupTipsEventCallback",
            manager: Managers.groupManager,
            callback,
            windowID: this._currentWindowID,
            param: data,
        };

        this._setCallback(callback, data.callback as unknown as Function);
        return this._call(formatedData);
    }

    TIMGroupDelete(data: DeleteGroupParams) {
        const formatedData = {
            method: "TIMGroupDelete",
            manager: Managers.groupManager,
            param: data,
        };

        return this._call(formatedData);
    }

    TIMGroupJoin(joinGroupParams: JoinGroupParams) {
        const formatedData = {
            method: "TIMGroupJoin",
            manager: Managers.groupManager,
            param: joinGroupParams,
        };

        return this._call(formatedData);
    }

    TIMGroupQuit(quitGroupParams: QuitGroupParams) {
        const formatedData = {
            method: "TIMGroupQuit",
            manager: Managers.groupManager,
            param: quitGroupParams,
        };

        return this._call(formatedData);
    }

    TIMGroupInviteMember(inviteMemberParams: InviteMemberParams) {
        const formatedData = {
            method: "TIMGroupInviteMember",
            manager: Managers.groupManager,
            param: inviteMemberParams,
        };

        return this._call(formatedData);
    }

    TIMGroupDeleteMember(deleteMemberParams: DeleteMemberParams) {
        const formatedData = {
            method: "TIMGroupDeleteMember",
            manager: Managers.groupManager,
            param: deleteMemberParams,
        };

        return this._call(formatedData);
    }

    TIMGroupGetJoinedGroupList(data?: string) {
        const formatedData = {
            method: "TIMGroupGetJoinedGroupList",
            manager: Managers.groupManager,
            param: data,
        };

        return this._call(formatedData);
    }

    TIMGroupGetGroupInfoList(getGroupListParams: GetGroupListParams) {
        const formatedData = {
            method: "TIMGroupGetGroupInfoList",
            manager: Managers.groupManager,
            param: getGroupListParams,
        };

        return this._call(formatedData);
    }
    TIMMsgSendGroupMessageReceipts(
        msgSendGroupMessageReceipts: MsgSendGroupMessageReceiptsParam
    ) {
        const formatedData = {
            method: "TIMMsgSendGroupMessageReceipts",
            manager: Managers.groupManager,
            param: msgSendGroupMessageReceipts,
        };

        return this._call(formatedData);
    }
    TIMMsgGetGroupMessageReceipts(
        msgGetGroupMessageReceipts: MsgGetGroupMessageReceiptsParam
    ) {
        const formatedData = {
            method: "TIMMsgGetGroupMessageReceipts",
            manager: Managers.groupManager,
            param: msgGetGroupMessageReceipts,
        };

        return this._call(formatedData);
    }
    TIMMsgGetGroupMessageReadMembers(
        msgGetGroupMessageReadMembers: MsgGetGroupMessageReadMembersParam
    ) {
        const formatedData = {
            method: "TIMMsgGetGroupMessageReadMembers",
            manager: Managers.groupManager,
            param: msgGetGroupMessageReadMembers,
        };

        return this._call(formatedData);
    }

    TIMGroupModifyGroupInfo(modifyGroupParams: ModifyGroupParams) {
        const formatedData = {
            method: "TIMGroupModifyGroupInfo",
            manager: Managers.groupManager,
            param: modifyGroupParams,
        };

        return this._call(formatedData);
    }

    TIMGroupGetMemberInfoList(
        getGroupMemberInfoParams: GetGroupMemberInfoParams
    ) {
        const formatedData = {
            method: "TIMGroupGetMemberInfoList",
            manager: Managers.groupManager,
            param: getGroupMemberInfoParams,
        };

        return this._call(formatedData);
    }

    TIMGroupModifyMemberInfo(modifyMemberInfoParams: ModifyMemberInfoParams) {
        const formatedData = {
            method: "TIMGroupModifyMemberInfo",
            manager: Managers.groupManager,
            param: modifyMemberInfoParams,
        };

        return this._call(formatedData);
    }

    TIMGroupGetPendencyList(getPendencyListParams: GetPendencyListParams) {
        const formatedData = {
            method: "TIMGroupGetPendencyList",
            manager: Managers.groupManager,
            param: getPendencyListParams,
        };

        return this._call(formatedData);
    }

    TIMGroupReportPendencyReaded(reportParams: ReportParams) {
        const formatedData = {
            method: "TIMGroupReportPendencyReaded",
            manager: Managers.groupManager,
            param: reportParams,
        };

        return this._call(formatedData);
    }

    TIMGroupHandlePendency(handlePendencyParams: HandlePendencyParams) {
        const formatedData = {
            method: "TIMGroupHandlePendency",
            manager: Managers.groupManager,
            param: handlePendencyParams,
        };

        return this._call(formatedData);
    }

    TIMGroupGetOnlineMemberCount(params: GetOnlineMemberCountParams) {
        const formatedData = {
            method: "TIMGroupGetOnlineMemberCount",
            manager: Managers.groupManager,
            param: params,
        };

        return this._call(formatedData);
    }

    TIMGroupSearchGroups(searchGroupsParams: SearchGroupParams) {
        const formatedData = {
            method: "TIMGroupSearchGroups",
            manager: Managers.groupManager,
            param: searchGroupsParams,
        };

        return this._call(formatedData);
    }

    TIMGroupSearchGroupMembers(searchMemberParams: SearchMemberParams) {
        const formatedData = {
            method: "TIMGroupSearchGroupMembers",
            manager: Managers.groupManager,
            param: searchMemberParams,
        };

        return this._call(formatedData);
    }

    TIMFriendshipGetFriendProfileList(
        getFriendProfileListParams: GetFriendProfileListParams
    ) {
        const formatedData = {
            method: "TIMFriendshipGetFriendProfileList",
            manager: Managers.friendshipManager,
            param: getFriendProfileListParams,
        };

        return this._call(formatedData);
    }

    TIMFriendshipAddFriend(addFriendParams: AddFriendParams) {
        const formatedData = {
            method: "TIMFriendshipAddFriend",
            manager: Managers.friendshipManager,
            param: addFriendParams,
        };

        return this._call(formatedData);
    }

    TIMFriendshipHandleFriendAddRequest(
        handleFriendAddParams: HandleFriendAddParams
    ) {
        const formatedData = {
            method: "TIMFriendshipHandleFriendAddRequest",
            manager: Managers.friendshipManager,
            param: handleFriendAddParams,
        };

        return this._call(formatedData);
    }

    TIMFriendshipModifyFriendProfile(
        modifyFriendProfileParams: ModifyFriendProfileParams
    ) {
        const formatedData = {
            method: "TIMFriendshipModifyFriendProfile",
            manager: Managers.friendshipManager,
            param: modifyFriendProfileParams,
        };

        return this._call(formatedData);
    }

    TIMFriendshipDeleteFriend(deleteFriendParams: DeleteFriendParams) {
        const formatedData = {
            method: "TIMFriendshipDeleteFriend",
            manager: Managers.friendshipManager,
            param: deleteFriendParams,
        };

        return this._call(formatedData);
    }

    TIMFriendshipCheckFriendType(checkFriendTypeParams: CheckFriendTypeParams) {
        const formatedData = {
            method: "TIMFriendshipCheckFriendType",
            manager: Managers.friendshipManager,
            param: checkFriendTypeParams,
        };

        return this._call(formatedData);
    }

    TIMFriendshipCreateFriendGroup(
        createFriendGroupParams: CreateFriendGroupParams
    ) {
        const formatedData = {
            method: "TIMFriendshipCreateFriendGroup",
            manager: Managers.friendshipManager,
            param: createFriendGroupParams,
        };

        return this._call(formatedData);
    }

    TIMFriendshipGetFriendGroupList(
        friendshipStringArrayParams: FriendshipStringArrayParams
    ) {
        const formatedData = {
            method: "TIMFriendshipGetFriendGroupList",
            manager: Managers.friendshipManager,
            param: friendshipStringArrayParams,
        };

        return this._call(formatedData);
    }

    TIMFriendshipModifyFriendGroup(
        modifyFriendGroupParams: ModifyFriendGroupParams
    ) {
        const formatedData = {
            method: "TIMFriendshipModifyFriendGroup",
            manager: Managers.friendshipManager,
            param: modifyFriendGroupParams,
        };

        return this._call(formatedData);
    }

    TIMFriendshipDeleteFriendGroup(
        friendshipStringArrayParams: FriendshipStringArrayParams
    ) {
        const formatedData = {
            method: "TIMFriendshipDeleteFriendGroup",
            manager: Managers.friendshipManager,
            param: friendshipStringArrayParams,
        };

        return this._call(formatedData);
    }

    TIMFriendshipAddToBlackList(
        friendshipStringArrayParams: FriendshipStringArrayParams
    ) {
        const formatedData = {
            method: "TIMFriendshipAddToBlackList",
            manager: Managers.friendshipManager,
            param: friendshipStringArrayParams,
        };

        return this._call(formatedData);
    }

    TIMFriendshipGetBlackList(getBlackListParams: GetBlackListParams) {
        const formatedData = {
            method: "TIMFriendshipGetBlackList",
            manager: Managers.friendshipManager,
            param: getBlackListParams,
        };

        return this._call(formatedData);
    }

    TIMFriendshipDeleteFromBlackList(
        friendshipStringArrayParams: FriendshipStringArrayParams
    ) {
        const formatedData = {
            method: "TIMFriendshipDeleteFromBlackList",
            manager: Managers.friendshipManager,
            param: friendshipStringArrayParams,
        };

        return this._call(formatedData);
    }

    TIMFriendshipGetPendencyList(
        friendshipGetPendencyListParams: FriendshipGetPendencyListParams
    ) {
        const formatedData = {
            method: "TIMFriendshipGetPendencyList",
            manager: Managers.friendshipManager,
            param: friendshipGetPendencyListParams,
        };

        return this._call(formatedData);
    }

    TIMFriendshipDeletePendency(deletePendencyParams: DeletePendencyParams) {
        const formatedData = {
            method: "TIMFriendshipDeletePendency",
            manager: Managers.friendshipManager,
            param: deletePendencyParams,
        };

        return this._call(formatedData);
    }

    TIMFriendshipReportPendencyReaded(
        reportPendencyReadedParams: ReportPendencyReadedParams
    ) {
        const formatedData = {
            method: "TIMFriendshipReportPendencyReaded",
            manager: Managers.friendshipManager,
            param: reportPendencyReadedParams,
        };

        return this._call(formatedData);
    }

    TIMFriendshipSearchFriends(searchFriendsParams: SearchFriendsParams) {
        const formatedData = {
            method: "TIMFriendshipSearchFriends",
            manager: Managers.friendshipManager,
            param: searchFriendsParams,
        };

        return this._call(formatedData);
    }

    TIMFriendshipGetFriendsInfo(
        friendshipStringArrayParams: FriendshipStringArrayParams
    ) {
        const formatedData = {
            method: "TIMFriendshipGetFriendsInfo",
            manager: Managers.friendshipManager,
            param: friendshipStringArrayParams,
        };

        return this._call(formatedData);
    }

    TIMSetOnAddFriendCallback(params: TIMOnAddFriendCallbackParams) {
        const callback = "TIMSetOnAddFriendCallback";
        const formatedData = {
            method: "TIMSetOnAddFriendCallback",
            manager: Managers.friendshipManager,
            callback,
            windowID: this._currentWindowID,
            param: params,
        };

        this._setCallback(callback, params.callback);

        return this._call(formatedData);
    }

    TIMSetOnDeleteFriendCallback(params: TIMOnDeleteFriendCallbackParams) {
        const callback = "TIMSetOnDeleteFriendCallback";
        const formatedData = {
            method: "TIMSetOnDeleteFriendCallback",
            manager: Managers.friendshipManager,
            callback,
            windowID: this._currentWindowID,
            param: params,
        };

        this._setCallback(callback, params.callback);

        return this._call(formatedData);
    }

    TIMSetUpdateFriendProfileCallback(
        params: TIMUpdateFriendProfileCallbackParams
    ) {
        const callback = "TIMSetUpdateFriendProfileCallback";
        const formatedData = {
            method: "TIMSetUpdateFriendProfileCallback",
            manager: Managers.friendshipManager,
            callback,
            windowID: this._currentWindowID,
            param: params,
        };

        this._setCallback(callback, params.callback);

        return this._call(formatedData);
    }

    TIMSetFriendAddRequestCallback(params: TIMFriendAddRequestCallbackParams) {
        const callback = "TIMSetFriendAddRequestCallback";
        const formatedData = {
            method: "TIMSetFriendAddRequestCallback",
            manager: Managers.friendshipManager,
            callback,
            windowID: this._currentWindowID,
            param: params,
        };

        this._setCallback(callback, params.callback);

        return this._call(formatedData);
    }

    TIMSetFriendApplicationListDeletedCallback(
        params: TIMFriendApplicationListDeletedCallbackParams
    ) {
        const callback = "TIMSetFriendApplicationListDeletedCallback";
        const formatedData = {
            method: "TIMSetFriendApplicationListDeletedCallback",
            manager: Managers.friendshipManager,
            callback,
            windowID: this._currentWindowID,
            param: params,
        };

        this._setCallback(callback, params.callback);
        return this._call(formatedData);
    }

    TIMSetFriendApplicationListReadCallback(
        params: TIMFriendApplicationListReadCallbackParams
    ) {
        const callback = "TIMSetFriendApplicationListReadCallback";
        const formatedData = {
            method: "TIMSetFriendApplicationListReadCallback",
            manager: Managers.friendshipManager,
            callback,
            windowID: this._currentWindowID,
            param: params,
        };

        this._setCallback(callback, params.callback);
        return this._call(formatedData);
    }

    TIMSetFriendBlackListAddedCallback(
        params: TIMFriendBlackListAddedCallbackParams
    ) {
        const callback = "TIMSetFriendBlackListAddedCallback";
        const formatedData = {
            method: "TIMSetFriendBlackListAddedCallback",
            manager: Managers.friendshipManager,
            callback,
            windowID: this._currentWindowID,
            param: params,
        };

        this._setCallback(callback, params.callback);
        return this._call(formatedData);
    }

    TIMSetFriendBlackListDeletedCallback(
        params: TIMFriendBlackListDeletedCallbackParams
    ) {
        const callback = "TIMSetFriendBlackListDeletedCallback";
        const formatedData = {
            method: "TIMSetFriendBlackListDeletedCallback",
            manager: Managers.friendshipManager,
            callback,
            windowID: this._currentWindowID,
            param: params,
        };

        this._setCallback(callback, params.callback);
        return this._call(formatedData);
    }

    TIMSetMsgGroupMessageReceiptCallback(
        params: MsgGroupMessageReceiptCallbackParam
    ) {
        const callback = "TIMSetMsgGroupMessageReceiptCallback";
        const formatedData = {
            method: "TIMSetMsgGroupMessageReceiptCallback",
            manager: Managers.groupManager,
            callback,
            windowID: this._currentWindowID,
            param: params,
        };

        this._setCallback(callback, params.callback);
        return this._call(formatedData);
    }

    TIMMsgSendMessage(msgSendMessageParams: MsgSendMessageParams) {
        const formatedData = {
            method: "TIMMsgSendMessage",
            manager: Managers.advanceMessageManager,
            param: msgSendMessageParams,
        };

        return this._call(formatedData);
    }

    TIMMsgSendMessageV2(msgSendMessageParams: MsgSendMessageParamsV2) {
        const callback = "TIMMsgSendMessageV2";
        const formatedData = {
            method: "TIMMsgSendMessageV2",
            manager: Managers.advanceMessageManager,
            callback,
            windowID: this._currentWindowID,
            param: msgSendMessageParams,
        };

        this._setCallback(callback, msgSendMessageParams.callback);
        return this._call(formatedData);
    }

    TIMMsgSendReplyMessage(msgSendReplyMessage: MsgSendReplyMessage) {
        const repliedMsg = msgSendReplyMessage.replyMsg;
        if (!repliedMsg) {
            throw Error("Need pass the reply msg");
        }
        const replyMsgContent = {
            messageReply: {
                messageID: repliedMsg.message_msg_id,
                messageAbstract: this.getAbstractMsgText(
                    repliedMsg.message_elem_array![0]
                ),
                messageSender:
                    repliedMsg.message_sender_profile?.user_profile_nick_name ||
                    repliedMsg.message_sender_profile?.user_profile_identifier,
                messageType: repliedMsg.message_elem_array![0].elem_type,
                version: "1",
            },
        };

        return this.TIMMsgSendMessageV2({
            conv_id: msgSendReplyMessage.conv_id,
            conv_type: msgSendReplyMessage.conv_type,
            params: {
                ...msgSendReplyMessage.params,
                message_cloud_custom_str: JSON.stringify(replyMsgContent),
            },
            callback: msgSendReplyMessage.callback,
            user_data: msgSendReplyMessage.user_data,
        });
    }

    TIMMsgCancelSend(msgCancelSendParams: MsgCancelSendParams) {
        const formatedData = {
            method: "TIMMsgCancelSend",
            manager: Managers.advanceMessageManager,
            param: msgCancelSendParams,
        };

        return this._call(formatedData);
    }

    TIMMsgFindMessages(msgFindMessagesParams: MsgFindMessagesParams) {
        const formatedData = {
            method: "TIMMsgFindMessages",
            manager: Managers.advanceMessageManager,
            param: msgFindMessagesParams,
        };

        return this._call(formatedData);
    }

    TIMMsgReportReaded(msgReportReadedParams: MsgReportReadedParams) {
        const formatedData = {
            method: "TIMMsgReportReaded",
            manager: Managers.advanceMessageManager,
            param: msgReportReadedParams,
        };

        return this._call(formatedData);
    }

    TIMMsgRevoke(msgRevokeParams: MsgRevokeParams) {
        const formatedData = {
            method: "TIMMsgRevoke",
            manager: Managers.advanceMessageManager,
            param: msgRevokeParams,
        };

        return this._call(formatedData);
    }

    TIMMsgFindByMsgLocatorList(
        msgFindByMsgLocatorListParams: MsgFindByMsgLocatorListParams
    ) {
        const formatedData = {
            method: "TIMMsgFindByMsgLocatorList",
            manager: Managers.advanceMessageManager,
            param: msgFindByMsgLocatorListParams,
        };

        return this._call(formatedData);
    }

    TIMMsgImportMsgList(msgImportMsgListParams: MsgImportMsgListParams) {
        const formatedData = {
            method: "TIMMsgImportMsgList",
            manager: Managers.advanceMessageManager,
            param: msgImportMsgListParams,
        };

        return this._call(formatedData);
    }

    TIMMsgSaveMsg(msgSaveMsgParams: MsgSaveMsgParams) {
        const formatedData = {
            method: "TIMMsgSaveMsg",
            manager: Managers.advanceMessageManager,
            param: msgSaveMsgParams,
        };

        return this._call(formatedData);
    }

    TIMMsgGetMsgList(msgGetMsgListParams: MsgGetMsgListParams) {
        const formatedData = {
            method: "TIMMsgGetMsgList",
            manager: Managers.advanceMessageManager,
            param: msgGetMsgListParams,
        };

        return this._call(formatedData);
    }

    TIMMsgDelete(msgDeleteParams: MsgDeleteParams) {
        const formatedData = {
            method: "TIMMsgDelete",
            manager: Managers.advanceMessageManager,
            param: msgDeleteParams,
        };

        return this._call(formatedData);
    }

    TIMMsgListDelete(msgListDeleteParams: MsgListDeleteParams) {
        const formatedData = {
            method: "TIMMsgListDelete",
            manager: Managers.advanceMessageManager,
            param: msgListDeleteParams,
        };

        return this._call(formatedData);
    }

    TIMMsgClearHistoryMessage(
        msgClearHistoryMessageParams: MsgClearHistoryMessageParams
    ) {
        const formatedData = {
            method: "TIMMsgClearHistoryMessage",
            manager: Managers.advanceMessageManager,
            param: msgClearHistoryMessageParams,
        };

        return this._call(formatedData);
    }

    TIMMsgSetC2CReceiveMessageOpt(
        msgSetC2CReceiveMessageOptParams: MsgSetC2CReceiveMessageOptParams
    ) {
        const formatedData = {
            method: "TIMMsgSetC2CReceiveMessageOpt",
            manager: Managers.advanceMessageManager,
            param: msgSetC2CReceiveMessageOptParams,
        };

        return this._call(formatedData);
    }

    TIMMsgGetC2CReceiveMessageOpt(
        msgGetC2CReceiveMessageOptParams: MsgGetC2CReceiveMessageOptParams
    ) {
        const formatedData = {
            method: "TIMMsgGetC2CReceiveMessageOpt",
            manager: Managers.advanceMessageManager,
            param: msgGetC2CReceiveMessageOptParams,
        };

        return this._call(formatedData);
    }

    TIMMsgSetGroupReceiveMessageOpt(
        msgSetGroupReceiveMessageOptParams: MsgSetGroupReceiveMessageOptParams
    ) {
        const formatedData = {
            method: "TIMMsgSetGroupReceiveMessageOpt",
            manager: Managers.advanceMessageManager,
            param: msgSetGroupReceiveMessageOptParams,
        };

        return this._call(formatedData);
    }

    TIMMsgDownloadElemToPath(
        msgDownloadElemToPathParams: MsgDownloadElemToPathParams
    ) {
        const formatedData = {
            method: "TIMMsgDownloadElemToPath",
            manager: Managers.advanceMessageManager,
            param: msgDownloadElemToPathParams,
        };

        return this._call(formatedData);
    }

    TIMMsgDownloadMergerMessage(
        msgDownloadMergerMessageParams: MsgDownloadMergerMessageParams
    ) {
        const formatedData = {
            method: "TIMMsgDownloadMergerMessage",
            manager: Managers.advanceMessageManager,
            param: msgDownloadMergerMessageParams,
        };

        return this._call(formatedData);
    }

    TIMMsgBatchSend(msgBatchSendParams: MsgBatchSendParams) {
        const formatedData = {
            method: "TIMMsgBatchSend",
            manager: Managers.advanceMessageManager,
            param: msgBatchSendParams,
        };

        return this._call(formatedData);
    }

    TIMMsgSearchLocalMessages(
        msgSearchLocalMessagesParams: MsgSearchLocalMessagesParams
    ) {
        const formatedData = {
            method: "TIMMsgSearchLocalMessages",
            manager: Managers.advanceMessageManager,
            param: msgSearchLocalMessagesParams,
        };

        return this._call(formatedData);
    }

    TIMAddRecvNewMsgCallback(params: TIMRecvNewMsgCallbackParams) {
        const callback = "TIMAddRecvNewMsgCallback";
        const formatedData = {
            method: "TIMAddRecvNewMsgCallback",
            manager: Managers.advanceMessageManager,
            callback,
            windowID: this._currentWindowID,
            param: params,
        };

        this._setCallback(callback, params.callback);
        return this._call(formatedData);
    }

    TIMRemoveRecvNewMsgCallback() {
        const callback = "TIMRemoveRecvNewMsgCallback";
        const formatedData = {
            method: "TIMRemoveRecvNewMsgCallback",
            manager: Managers.advanceMessageManager,
            callback,
            windowID: this._currentWindowID,
        };

        return this._call(formatedData);
    }

    TIMSetMsgReadedReceiptCallback(params: TIMMsgReadedReceiptCallbackParams) {
        const callback = "TIMSetMsgReadedReceiptCallback";
        const formatedData = {
            method: "TIMSetMsgReadedReceiptCallback",
            manager: Managers.advanceMessageManager,
            callback,
            windowID: this._currentWindowID,
            param: params,
        };

        this._setCallback(callback, params.callback);
        return this._call(formatedData);
    }

    TIMSetMsgRevokeCallback(params: TIMMsgRevokeCallbackParams) {
        const callback = "TIMSetMsgRevokeCallback";
        const formatedData = {
            method: "TIMSetMsgRevokeCallback",
            manager: Managers.advanceMessageManager,
            callback,
            windowID: this._currentWindowID,
            param: params,
        };

        this._setCallback(callback, params.callback);
        return this._call(formatedData);
    }

    TIMSetMsgElemUploadProgressCallback(
        params: TIMMsgElemUploadProgressCallbackParams
    ) {
        const callback = "TIMSetMsgElemUploadProgressCallback";
        const formatedData = {
            method: "TIMSetMsgElemUploadProgressCallback",
            manager: Managers.advanceMessageManager,
            callback,
            windowID: this._currentWindowID,
            param: params,
        };

        this._setCallback(callback, params.callback);
        return this._call(formatedData);
    }

    TIMSetMsgUpdateCallback(params: TIMMsgUpdateCallbackParams) {
        const callback = "TIMSetMsgUpdateCallback";
        const formatedData = {
            method: "TIMSetMsgUpdateCallback",
            manager: Managers.advanceMessageManager,
            callback,
            param: params,
        };

        this._setCallback(callback, params.callback);
        return this._call(formatedData);
    }
    private _getSignalCustomData(param: customDataTpl) {
        const {
            inviter,
            inviteID,
            actionType,
            inviteeList,
            timeout = 30,
            groupID = "",
            data,
        } = param;
        const tpl = {
            onlineUserOnly: false,
            businessID: 1,
            inviteID: inviteID,
            inviter: inviter,
            actionType: actionType,
            inviteeList: inviteeList,
            data: data,
            timeout: timeout,
            groupID: groupID,
        };
        return tpl;
    }
    private async _setCallingTimeout(
        inviteID: string,
        isRec: boolean,
        message: any
    ) {
        const callInfo = deepClone(await this._getCallInfo(inviteID));

        if (callInfo) {
            const { message_server_time } = message;
            const { timeout } = callInfo;
            if (timeout && timeout > 0) {
                const interVal = setInterval(async () => {
                    const startTime = new Date().getTime();
                    //@ts-ignore
                    const { data: currentServerTime } =
                        await this.TIMGetServerTime();

                    const endTime = new Date().getTime();
                    const diffTime = endTime - startTime;
                    const isTimeout =
                        currentServerTime * 1000 -
                            diffTime -
                            message_server_time * 1000 >=
                        timeout * 1000;

                    if (isTimeout) {
                        this._timeout(inviteID, isRec);
                        clearInterval(interVal);
                    }
                }, 600);
            }
        }
    }
    private async _timeout(inviteID: string, isRec: boolean) {
        const callInfo = deepClone(await this._getCallInfo(inviteID));
        if (callInfo) {
            const { inviteeList, groupID, inviter } = callInfo;
            callInfo.actionType = ActionType.INVITE_TIMEOUT;
            // @ts-ignore
            const senderID = (await this.TIMGetLoginUserID({})).data.json_param;

            if (inviteeList.length > 0) {
                if (isRec) {
                    if (inviteeList.includes(senderID)) {
                        callInfo.inviteeList = [senderID];
                    } else {
                        return;
                    }
                }
                const {
                    //@ts-ignore
                    data: { code, json_params },
                } = await this._sendCumtomMessage(
                    groupID
                        ? groupID
                        : inviter === senderID
                        ? inviteeList[0]
                        : inviter,
                    senderID,
                    callInfo,
                    groupID ? true : false
                );
                if (code === 0) {
                    this._onTimeouted(inviteID, callInfo, json_params); // 让自己也知道超时了
                    await this._deleteCallInfo(inviteID);
                }
            }
        }
    }
    private async _sendCumtomMessage(
        userID: string,
        senderID: string,
        customData: object,
        isGroup?: boolean
    ) {
        return this.TIMMsgSendMessage({
            conv_id: userID,
            conv_type: isGroup
                ? TIMConvType.kTIMConv_Group
                : TIMConvType.kTIMConv_C2C,
            params: {
                message_elem_array: [
                    {
                        elem_type: 3, // 自定义消息
                        custom_elem_data: JSON.stringify(customData),
                        custom_elem_desc: "",
                        custom_elem_ext: "",
                        custom_elem_sound: "",
                    },
                ],
                message_sender: senderID,
            },
        });
    }
    // TRTCCalling start
    TIMInvite(param: TRTCCallingCallParam) {
        return new Promise(async (resolve, reject) => {
            const {
                userID,
                senderID,
                timeout = 30,
                data = JSON.stringify({}),
            } = param;
            const inviteID = uuidv4();
            const customData = this._getSignalCustomData({
                inviter: senderID,
                inviteeList: [userID],
                actionType: ActionType.INVITE,
                inviteID,
                timeout,
                data,
            });
            const res = await this._sendCumtomMessage(
                userID,
                senderID,
                customData
            );
            console.log(res);
            // @ts-ignore
            const { code, json_params } = res.data;
            if (code === 0) {
                const message = JSON.parse(json_params);
                await this._setCallInfo(inviteID, customData);
                if (timeout > 0) {
                    this._setCallingTimeout(inviteID, false, message);
                }
                resolve({
                    inviteID,
                    ...res,
                });
            } else {
                reject(res);
            }
        });
    }

    TIMInviteInGroup(param: TRTCCallingCallGroupParam) {
        return new Promise(async (resolve, reject) => {
            const { userIDs, senderID, timeout = 30, groupID, data } = param;
            const inviteID = uuidv4();
            const customData = this._getSignalCustomData({
                inviter: senderID,
                inviteeList: userIDs,
                actionType: ActionType.INVITE,
                inviteID,
                timeout,
                groupID,
                data,
            });
            const res = await this._sendCumtomMessage(
                groupID,
                senderID,
                customData,
                true
            );
            // @ts-ignore
            const { code, json_params } = res.data;

            if (code === 0) {
                const message = JSON.parse(json_params);
                await this._setCallInfo(inviteID, customData);
                if (timeout > 0) {
                    this._setCallingTimeout(inviteID, false, message);
                }
                resolve({
                    inviteID,
                    ...res,
                });
            } else {
                reject(res);
            }
        });
    }

    TIMAcceptInvite(param: handleParam) {
        return new Promise(async (resolve, reject) => {
            const { inviteID, data } = param;
            const callInfo = deepClone(await this._getCallInfo(inviteID));
            if (callInfo) {
                const { groupID, inviter } = callInfo;
                callInfo.actionType = ActionType.ACCEPT_INVITE;
                callInfo.data = data;
                // @ts-ignore
                const senderID = (await this.TIMGetLoginUserID({})).data
                    .json_param;
                callInfo.inviteeList = [senderID];
                const res = await this._sendCumtomMessage(
                    groupID ? groupID : inviter,
                    senderID,
                    callInfo,
                    groupID ? true : false
                );
                // @ts-ignore
                const { code } = res.data;
                if (code === 0) {
                    // 如果没人了，移除本地维护的数据
                    const localInfo = deepClone(
                        await this._getCallInfo(inviteID)
                    );
                    //@ts-ignore
                    const { inviteeList: localInviteeList } = localInfo;
                    const newInviteeList =
                        localInviteeList?.filter(
                            (item: any) => item !== senderID
                        ) || [];
                    log.info(
                        `info: ${JSON.stringify(localInfo)},${newInviteeList}`
                    );
                    if (newInviteeList.length > 0) {
                        // @ts-ignore
                        localInfo.inviteeList = newInviteeList;
                        await this._setCallInfo(inviteID, localInfo);
                    } else {
                        await this._deleteCallInfo(inviteID);
                    }
                    resolve({
                        inviteID,
                        ...res,
                    });
                } else {
                    reject(res);
                }
            } else {
                reject({
                    code: 8010,
                    desc: "inviteID is invalid or invitation has been processed",
                });
            }
        });
    }
    TIMRejectInvite(param: handleParam) {
        return new Promise(async (resolve, reject) => {
            const { inviteID, data } = param;
            const callInfo = deepClone(await this._getCallInfo(inviteID));
            if (callInfo) {
                const { groupID, inviter } = callInfo;
                callInfo.actionType = ActionType.REJECT_INVITE;
                callInfo.data = data;
                // @ts-ignore
                const sendID = (await this.TIMGetLoginUserID({})).data
                    .json_param;
                callInfo.inviteeList = [sendID];
                const res = await this._sendCumtomMessage(
                    groupID ? groupID : inviter,
                    sendID,
                    callInfo,
                    groupID ? true : false
                );
                // @ts-ignore
                const { code } = res.data;
                if (code === 0) {
                    // 如果没人了，移除本地维护的数据
                    // @ts-ignore
                    const { inviteeList: localInviteeList } =
                        await this._getCallInfo(inviteID);
                    const newInviteeList = localInviteeList?.filter(
                        (item: any) => item !== sendID
                    );
                    if (newInviteeList.length > 0) {
                        callInfo.inviteeList = newInviteeList;
                        await this._setCallInfo(inviteID, callInfo);
                    } else {
                        await this._deleteCallInfo(inviteID);
                    }
                    resolve({
                        inviteID,
                        ...res,
                    });
                } else {
                    reject(res);
                }
            } else {
                reject({
                    code: 8010,
                    desc: "inviteID is invalid or invitation has been processed",
                });
            }
        });
    }
    TIMCancelInvite(param: handleParam) {
        return new Promise(async (resolve, reject) => {
            const { inviteID, data } = param;
            const callInfo = deepClone(await this._getCallInfo(inviteID));
            if (callInfo) {
                const { inviteeList, groupID } = callInfo;
                callInfo.actionType = ActionType.CANCEL_INVITE;
                callInfo.data = data;
                // @ts-ignore
                const senderID = (await this.TIMGetLoginUserID({})).data
                    .json_param;

                const res = await this._sendCumtomMessage(
                    groupID ? groupID : inviteeList[0],
                    senderID,
                    callInfo,
                    groupID ? true : false
                );
                // @ts-ignore
                const { code } = res.data;
                if (code === 0) {
                    await this._deleteCallInfo(inviteID);
                    resolve({
                        inviteID,
                        ...res,
                    });
                } else {
                    reject(res);
                }
            } else {
                reject({
                    code: 8010,
                    desc: "inviteID is invalid or invitation has been processed",
                });
            }
        });
    }
}
