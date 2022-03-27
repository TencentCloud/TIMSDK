import { getCurrentWindow } from '@electron/remote';
import timRenderInstance from "../../utils/timRenderInstance";
import initListeners from "../../imLiseners";
import store from "../../store";
import { openCallWindow, closeCallWindow, remoteUserExit, remoteUserJoin, acceptCallListiner, refuseCallListiner, callWindowCloseListiner, cancelCallInvite, updateInviteList } from "../../utils/callWindowTools";
import { updateCallingStatus } from "../../store/actions/ui";
import {
    reciMessage,
    markeMessageAsRevoke,
    markMessageAsReaded,
    updateMessages,
    updateMessageElemProgress,
} from "../../store/actions/message";
import { setIsLogInAction, userLogout } from "../../store/actions/login";
import {
    addProfileForConversition,
    getConversionList,
} from "../../api";
import {
    setUnreadCount,
    updateConversationList,
    markConvLastMsgIsReaded,
    updateCurrentSelectedConversation,
} from "../../store/actions/conversation";
import { notification } from "tea-component/lib/notification/Notification";
import { AddFriendsNotification } from '../../components/addFriendsNotification/addFriendsNotification'
import React from "react";
import { message } from 'tea-component';

let isInited = false;
let joinedUserList = [];
let history = null;
let jumpToMsgPage;

const getState = (): State.RootState => store.getState();

const getCallingStatus = () => getState().ui.callingStatus;

const getUserInfo = () => getState().userInfo;

const getSettingConfig = () => getState().settingConfig;

const getConversationList = () => getState().conversation;

const getLoginInfo = () => getState().login;

const dispatch = store.dispatch;

const currentWindow = getCurrentWindow();

let shouldShowNotify = true;

const windowListiner = () => {
    currentWindow.on('focus', () => {
        shouldShowNotify = false;
    });

    currentWindow.on('blur', () => {
        shouldShowNotify = true;
    });

    currentWindow.on('minimize', () => {
        shouldShowNotify = true;
    });

    currentWindow.on('maximize', () => {
        shouldShowNotify = true;
    });
}

const initSdk = async (directToMsgPage, routeHistory, forceUpdate = false) => {
    history = routeHistory;
    jumpToMsgPage = directToMsgPage;
    windowListiner();
    if (!isInited || forceUpdate) {
        console.log('=====init sdk=====');
        const { addressIp, port, publicKey } = getSettingConfig();
        if (addressIp && port && publicKey) {
            const privite = await timRenderInstance.callExperimentalAPI({
                json_param: {
                    request_internal_operation: 'internal_operation_set_custom_server_info',
                    request_set_custom_server_info_param: {
                        longconnection_address_array: [{
                            server_address_ip: addressIp,// ip
                            server_address_port: port// 端口
                        }],
                        server_public_key: publicKey// 公钥
                    }
                }
            })
            console.log('私有化', privite);
        }
        timRenderInstance.TIMInit().then(async ({ data }) => {
            if (data === 0) {
                isInited = true;
                console.log("初始化成功");
                initListeners((callback) => {
                    const { data, type } = callback;
                    console.info(
                        "======================== 接收到IM事件 start =============================="
                    );
                    console.log("类型：", type);
                    console.log("数据：", data);
                    console.info(
                        "======================== 接收到IM事件 end =============================="
                    );
                    switch (type) {
                        /**
                         * 处理收到消息逻辑
                         */
                        case "TIMAddRecvNewMsgCallback":
                            _handeMessage(data);
                            break;
                        /**
                         * 会话改变
                         */
                        case "TIMSetConvEventCallback":
                            _handleConversaion(data);
                            break;
                        /**
                         * 未读数改变
                         */
                        case "TIMSetConvTotalUnreadMessageCountChangedCallback":
                            _handleUnreadChange(data);
                            break;
                        /**
                         * 消息撤回
                         */
                        case "TIMSetMsgRevokeCallback":
                            _handleMessageRevoked(data);
                            break;
                        case "TIMSetMsgReadedReceiptCallback":
                            _handleMessageReaded(data);
                            break;
                        /**
                         * 群组系统消息回调
                         */
                        case "TIMSetGroupTipsEventCallback":
                            _handleGroupInfoModify(data);
                            break;
                        /**
                         * 元素上传进度回调
                         */
                        case "TIMSetMsgElemUploadProgressCallback":
                            _handleElemUploadProgres(data);
                            break;
                        /**
                         * 被挤下线
                         */
                        case "TIMSetKickedOfflineCallback":
                            _handleKickedout();
                            break;
                        /**
                         * 收到音视频邀请
                         */
                        case "TIMOnInvited":
                            _onInvited(data)
                            break;
                        /**
                         * 自己的邀请被拒绝
                         */
                        case "TIMOnRejected":
                            _onRejected(data)
                            break;
                        /**
                         * 自己的邀请被接收
                         */
                        case "TIMOnAccepted":
                            _onAccepted(data)
                            break;
                        /**
                         * 收到的音视频邀请被取消
                         */
                        case "TIMOnCanceled":
                            _onCanceled(data)
                            break;
                        /**
                         * 收到的音视频邀请已經超时
                         */
                        case "TIMOnTimeout":
                            _onTimeout(data)
                            break;
                        case "TIMSetFriendAddRequestCallback":
                            _TIMSetFriendAddRequestCallback(data);
                    }
                });
            }
        });
    }
};

const destroyCache = {}

const destroyCacheMethod = (userid,destroy)=>{
    destroyCache[userid] = destroy
}

const notifiClick = (userID,isAccept) =>{
    try{
        if(isAccept){
            message.success({
                content: "添加好友成功，请在好友列表中查看"
            })
        }
        destroyCache[userID] && destroyCache[userID]()
        delete destroyCache[userID]
    }catch(err){

    }
}

/**
 * 被添加为好友
 * @param data 
 */
const _TIMSetFriendAddRequestCallback = (data) => {
    for (let i = 0; i < data.length; i++) {
        const { friend_add_pendency_identifier, friend_add_pendency_nick_name, friend_add_pendency_add_wording } = data[i];
        const { destroy } = notification.success({
            title: "通知",
            description: `${friend_add_pendency_nick_name ? friend_add_pendency_nick_name : friend_add_pendency_identifier}请求加您为好友，附言：${friend_add_pendency_add_wording ? friend_add_pendency_add_wording : "无"}`,
            footer: React.createElement(
                AddFriendsNotification,
                { userID: friend_add_pendency_identifier, onClick: notifiClick },
            ),
            unique: true
        })
        destroyCacheMethod(friend_add_pendency_identifier,destroy)
    }

}
const _onInvited = (data) => {
    // actionType: 1
    // businessID: 1
    // data: "{\"version\":0,\"call_type\":1,\"room_id\":30714513}"
    // groupID: ""
    // inviteID: "19455b33-c8fc-4fef-ab60-9347ebea78cc"
    // inviteeList: ["3708"]
    // inviter: "109442"
    // timeout: 30

    const formatedData = JSON.parse(JSON.parse(data)[0].message_elem_array[0].custom_elem_data)
    const { room_id, call_type, call_end } = JSON.parse(formatedData.data)
    const { inviter, groupID, inviteID, inviteeList } = formatedData;
    const { callingId, callType } = getCallingStatus();
    // 如果正在通话，拒绝对方通话。
    if (callingId) {
        timRenderInstance.TIMRejectInvite({
            inviteID: inviteID,
            data: JSON.stringify({ "version": 4, "businessID": "av_call", "call_type": callType })
        });
        return;
    }
    if (call_end >= 0) {
        return
    }
    timRenderInstance.TIMProfileGetUserProfileList({
        json_get_user_profile_list_param: {
            friendship_getprofilelist_param_identifier_array: [inviter, ...inviteeList],
            friendship_getprofilelist_param_force_update: false
        }
    }).then(async (data) => {
        const { userId, userSig } = getUserInfo();
        if (!userId) {
            return
        }
        const { data: { code, json_param } } = data;
        if (code === 0) {
            const inviteListWithInfo = JSON.parse(json_param);
            const inviterInfo = inviteListWithInfo.find(item => item.user_profile_identifier === inviter);
            dispatch(updateCallingStatus({
                callingId: groupID ? groupID : inviter, //
                callingType: groupID ? 2 : 1,
                inviteeList: [inviter, ...inviteeList],
                callType: call_type
            }))
            openCallWindow({
                windowType: 'notificationWindow',
                callType: call_type + '',
                convId: groupID ? groupID : inviter,
                convInfo: {
                    faceUrl: inviterInfo.user_profile_face_url,
                    nickName: inviterInfo.user_profile_nick_name || inviter,
                    convType: groupID ? 2 : 1,
                    id: inviter
                },
                roomId: room_id,
                inviteID,
                userID: userId,
                inviteList: [inviter, ...inviteeList],
                inviteListWithInfo: [...inviteListWithInfo],
                userSig: userSig,
                isInviter: false
            });
        }
    })

}

const _onRejected = (data) => {
    data && _handleRemoteUserReject(JSON.parse(data)[0]);
}

const _onAccepted = (data) => {
    console.log('============accept call=======', data);
}

const _onCanceled = (data) => {
    // 关闭通知窗口
    closeCallWindow();
    clearCallStore();
}

const _onTimeout = (data) => {
    if (data) {
        const parsedData = JSON.parse(data);
        const params = Array.isArray(parsedData) ? parsedData[0] : parsedData;
        _handleRemoteUserTimeOut(params);
    }
}

const _handleRemoteUserTimeOut = (message) => {
    const timeOutList = JSON.parse(message.message_elem_array[0].custom_elem_data)?.inviteeList;
    console.warn('====timeout params=====', timeOutList);
    if (timeOutList) {
        const { callingId, callingType, inviteeList, callType } = getCallingStatus();
        const { userId } = getUserInfo();
        const newList = inviteeList.filter(item => !timeOutList.includes(item));
        const isEmpty = newList.filter(item => item !== userId).length === 0;
        dispatch(updateCallingStatus({
            callingId,
            callingType,
            inviteeList: newList,
            callType
        }));
        if (isEmpty) {
            closeCallWindow();
        } else {
            updateInviteList(newList); //向通话窗口通信
        }
    }
}

const _handleRemoteUserReject = (message) => {
    const { message_sender } = message;
    const { callingId, callingType, inviteeList, callType } = getCallingStatus();
    const { userId } = getUserInfo();
    if (inviteeList.includes(message_sender)) {
        const newInviteeList = inviteeList.filter(item => item !== message_sender);
        const isEmpty = newInviteeList.filter(item => item !== userId).length === 0;
        dispatch(updateCallingStatus({
            callingId,
            callingType,
            inviteeList: newInviteeList,
            callType
        }));
        if (isEmpty) {
            closeCallWindow();
        } else {
            updateInviteList(newInviteeList); //向通话窗口通信
        }
    }
}

const _handleElemUploadProgres = ({ message, index, cur_size, total_size, user_data }) => {
    dispatch(updateMessageElemProgress({
        messageId: message.message_msg_id,
        index,
        cur_size,
        total_size
    }));
}

const _handleKickedout = async () => {
    dispatch(userLogout());
    history.replace("/login");
    dispatch(setIsLogInAction(false));
};

const _handleGroupInfoModify = async (data) => {
    const response = await getConversionList();
    dispatch(updateConversationList(response));
    if (response?.length) {
        const newConversaionItem = response.find(
            (v) => v.conv_id === data.group_tips_elem_group_id
        );
        if (newConversaionItem) {
            dispatch(updateCurrentSelectedConversation(newConversaionItem));
        }
    }
};
const handleMessageSendFailed = (convList) => {
    const failedList = convList.reduce((acc, cur) => {
        if (cur.conv_last_msg && cur?.conv_last_msg.message_status === 3) {
            const key = cur.conv_id;
            const value = acc[key] ? acc[key].push(cur.conv_last_msg) : [cur.conv_last_msg];
            return {
                ...acc,
                [key]: value,
            };
        }
    }, {});

    if (!failedList) return;
    for (const i in failedList) {
        dispatch(
            updateMessages({
                convId: i,
                message: failedList[i][0],
            })
        );
    }
};

// body: messages[0].message_elem_array[0].text_elem_content.length > 9 ? messages[0].message_elem_array[0].text_elem_content.substring(0, 10) : messages[0].message_elem_array[0].text_elem_content

const _handleUnreadChange = (unreadCount) => {
    dispatch(setUnreadCount(unreadCount));
};

const handleNotify = (messages: State.message[]) => {
    const { isLogIn }  = getLoginInfo();
    if(!isLogIn || !shouldShowNotify) {
        return;
    }
    const { message_conv_id, message_elem_array, message_conv_type } = messages[0];
    const conversationList = getConversationList().conversationList;
    const convProfile = conversationList.find(item => item.conv_id === message_conv_id).conv_profile;
    const nickName = convProfile.user_profile_nick_name ?? convProfile.group_detial_info_group_name;
    const firstMsg = message_elem_array[0] || {};
    const displayTextMsg = firstMsg && firstMsg.text_elem_content;

    const displayMsg = {
        '0': displayTextMsg,
        '1': '[图片]',
        '2': '[声音]',
        '3': '[自定义消息]',
        '4': '[文件消息]',
        '5': '[群组系统消息]',
        '6': '[表情消息]',
        '7': '[位置消息]',
        '8': '[群组系统通知]',
        '9': '[视频消息]',
        '10': '[关系]',
        '11': '[资料]',
        '12': '[合并消息]',
    }[firstMsg.elem_type];

    const notificationBody = displayMsg.substring(0, 10)
    const notificationInstance = new window.Notification(nickName, {
        body: notificationBody
    });

    notificationInstance.onclick = () =>
        jumpToMsgPage({
            profile: convProfile,
            convType: message_conv_type
        });
};

const _handeMessage = (messages: State.message[]) => {
    // 收到新消息，如果正在聊天，更新历史记录，并设置已读，其他情况没必要处理
    const obj = {};
    const formatedMessages = messages.filter(item => !item.message_conv_id.includes('meeting-group'));
    for (let i = 0; i < formatedMessages.length; i++) {
        if (!obj[formatedMessages[i].message_conv_id]) {
            obj[formatedMessages[i].message_conv_id] = [];
        }
        obj[formatedMessages[i].message_conv_id].push(formatedMessages[i]);
    }
    for (const i in obj) {
        dispatch(
            reciMessage({
                convId: i,
                messages: obj[i],
            })
        );
    }

    try {
        handleNotify(formatedMessages)
    } catch (err) {
        console.log(err);
    }
};
const _handleConversaion = (conv) => {
    const { type, data } = conv;
    switch (type) {
        /**
         * 新增会话
         */
        case 0:
            console.log("新增会话");
            _updateConversation(data);
            break;
        /**
         * 删除会话
         */
        case 1:
            console.log("删除会话");
            break;
        /**
         * 会话同步完成
         */
        case 2:
            console.log("同步会话完成");
            _updateConversation(data);
            break;
        /**
         * 会话开始同步
         */
        case 3:
            console.log("开始同步会话");
            break;
        /**
         * 会话更新
         */
        case 4:
            console.log("会话更新");
            break;
    }
};
const _updateConversation = async (
    conversationList: Array<State.conversationItem>
) => {
    if (conversationList.length) {
        const formatedConv = conversationList.filter(item => !item.conv_id.includes('meeting-group'));
        const convList = await addProfileForConversition(formatedConv);
        dispatch(updateConversationList(convList));
        // 更新失败消息上屏
        try {
            handleMessageSendFailed(convList);
        } catch (err) {
            console.error(err)
        }
        // if (conversationList[0]?.conv_last_msg?.message_status === 1) {
        const elemType = formatedConv[0]?.conv_last_msg?.message_elem_array?.[0]?.elem_type;
        if (elemType === 3) {
            dispatch(updateMessages({
                convId: formatedConv[0].conv_id,
                message: formatedConv[0].conv_last_msg
            }))
        }
        // }
    }
};

const _handleMessageRevoked = (data) => {
    data.forEach((item) => {
        const {
            message_locator_conv_id: convId,
            message_locator_unique_id: messageId,
        } = item;
        dispatch(
            markeMessageAsRevoke({
                convId,
                messageId,
            })
        );
    });
};

const clearCallStore = () => {
    dispatch(updateCallingStatus({
        callingId: '',
        callingType: 0,
        inviteeList: [],
        callType: 0
    }));
    joinedUserList = [];
}

const _handleMessageReaded = (data) => {
    const c2cDdata = data.filter((item) => item.msg_receipt_conv_type === 1);
    const convIds = c2cDdata.map((item) => item.msg_receipt_conv_id);
    if (c2cDdata.length > 0) {
        dispatch(markConvLastMsgIsReaded(c2cDdata));
        dispatch(markMessageAsReaded({ convIds }));
    }
};

const callWindowLisitiner = () => {
    acceptCallListiner((inviteID) => {
        const { callType } = getCallingStatus();
        timRenderInstance.TIMAcceptInvite({
            inviteID: inviteID,
            data: JSON.stringify({ "version": 4, "businessID": "av_call", "call_type": callType })
        }).then(data => {
            console.log('接收返回', data)
        })
    });
    refuseCallListiner((inviteID) => {
        const { callType } = getCallingStatus();
        timRenderInstance.TIMRejectInvite({
            inviteID: inviteID,
            data: JSON.stringify({ "version": 4, "businessID": "av_call", "call_type": callType })
        }).then(data => {
            console.log('接收返回', data)
        });
    });
    callWindowCloseListiner(clearCallStore);
    cancelCallInvite(({ inviteId, realCallTime }) => {
        if (!inviteId) {
            return;
        }
        const { callingId, inviteeList, callType, callingType } = getCallingStatus();
        const { userId } = getUserInfo();
        const callingUserList = joinedUserList.filter(item => item !== userId);
        const isAllUserRejectOrTimeout = inviteeList.filter(item => item !== userId).length === 0;
        if (realCallTime === 0) {
            // 如果点击挂断，此时没有用户接听，需要取消邀请
            if (!isAllUserRejectOrTimeout) {
                timRenderInstance.TIMCancelInvite({
                    inviteID: inviteId,
                    data: JSON.stringify({ "version": 4, "businessID": "av_call", "call_type": callingType })
                }).then(data => {
                    console.log('关闭邀请===', data)
                })
            }
        } else {
            // 如果自己是最后一个挂断电话的需要发送通话时长
            if (callingUserList.length === 0) {
                if (callingType === 1) {
                    timRenderInstance.TIMInvite({
                        userID: callingId,
                        timeout: 0,
                        senderID: userId,
                        data: JSON.stringify({ "businessID": "av_call", "call_end": realCallTime, "call_type": Number(callType), "version": 4 })
                    })
                } else {
                    timRenderInstance.TIMInviteInGroup({
                        userIDs: callingUserList,
                        groupID: callingId,
                        timeout: 0,
                        senderID: userId,
                        data: JSON.stringify({ "businessID": "av_call", "call_end": realCallTime, "call_type": Number(callType), "version": 4 }),
                    }).then(() => {
                        console.log('===========data======');
                    })
                }
            }
        }
    });

    remoteUserExit((userId) => {
        const { callingId, callingType, inviteeList, callType } = getCallingStatus();
        const { userId: catchUserId } = getUserInfo();
        const newList = inviteeList.filter(item => item !== userId);
        const isEmpty = newList.filter(item => item !== catchUserId).length === 0;
        joinedUserList = [...newList];
        if (isEmpty) {
            closeCallWindow();
            return;
        }
        dispatch(updateCallingStatus({
            callingId,
            callingType,
            inviteeList: newList,
            callType
        }));
    });

    remoteUserJoin((userId) => {
        joinedUserList.push(userId);
    });
}

export {
    callWindowLisitiner,
    initSdk
}