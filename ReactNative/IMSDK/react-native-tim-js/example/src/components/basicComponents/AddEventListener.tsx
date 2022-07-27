import React, { useContext } from 'react';
import { TencentImSDKPlugin } from 'react-native-tim-js';
import CommonButton from '../commonComponents/CommonButton';
import {CallBackContext} from '../../useContext';

const AddEventListenerComponent = () => {
    const { setCallbackData } = useContext(CallBackContext)
    const simeMsgListenerObj = {
        onRecvC2CCustomMessage: (
            msgID,
            sender,
            customData
        ) => {
            const res = {
                type: 'onRecvC2CCustomMessage',
                data:{
                    msgID: msgID,
                    sender: sender,
                    customData: customData
                }
            }
            setCallbackData(res)
        },
        onRecvC2CTextMessage: (
            msgID,
            sender,
            text
        ) => {
            const res = {
                type: 'onRecvC2CTextMessage',
                data:{
                    msgID: msgID,
                    sender: sender,
                    text: text
                }
            }
            setCallbackData(res)
        },
        onRecvGroupCustomMessage: (
            msgID,
            groupID,
            sender,
            customData
        ) => {
            const res = {
                type: 'onRecvGroupCustomMessage',
                data:{
                    msgID: msgID,
                    groupID: groupID,
                    sender: sender,
                    customData: customData
                }
            }
            setCallbackData(res)
        },
        onRecvGroupTextMessage: (
            msgID,
            groupID,
            sender,
            text
        ) => {
            const res = {
                type: 'onRecvGroupTextMessage',
                data: {
                    msgID: msgID,
                    groupID: groupID,
                    sender: sender,
                    text: text
                }
            }
            setCallbackData(res)
        }
    };
    const groupListenerObj = {
        onMemberEnter: (groupID, memberList) => {
            const res = {
                type: 'onMemberEnter',
                data:{
                    groupID: groupID,
                    memberList: memberList
                }
            }
            setCallbackData(res)
        },
        onMemberLeave: (groupID, member) => {
            const res = {
                type: 'onMemberLeave',
                data:{
                    groupID: groupID,
                    member: member
                }
            }
            setCallbackData(res)
        },
        onMemberInvited: (groupID, opUser, memberList) => {
            const res = {
                type: 'onMemberInvited',
                data:{
                    groupID: groupID,
                    opUser: opUser,
                    member: memberList
                }
            }
            setCallbackData(res)
        },
        onMemberKicked: (
            groupID,
            opUser,
            memberList
        ) => {
            const res = {
                type: 'onMemberKicked',
                data: {
                    groupID: groupID,
                    opUser: opUser,
                    member: memberList
                }
            }
            setCallbackData(res)
        },
        onMemberInfoChanged: (
            groupID,
            groupMemberChangeInfoList
        ) => {
            const res = {
                type: 'onMemberInfoChanged',
                data:{
                    groupID: groupID,
                    groupMemberChangeInfoList: groupMemberChangeInfoList
                }
            }
            setCallbackData(res)
        },
        onGroupCreated: (groupID) => {
            const res = {
                type: 'onGroupCreated',
                data:{
                    groupID: groupID
                } 
            }
            setCallbackData(res)
        },
        onGroupDismissed: (groupID, opUser) => {
            const res = {
                type: 'onGroupDismissed',
                data:{
                    groupID: groupID,
                    opUser: opUser
                }
            }
            setCallbackData(res)
        },
        onGroupRecycled: (groupID, opUser) => {
            const res = {
                type: 'onGroupRecycled',
                data:{
                    groupID: groupID,
                    opUser: opUser
                }
            }
            setCallbackData(res)
        },
        onGroupInfoChanged: (groupID, changeInfos) => {
            const res = {
                type: 'onGroupInfoChanged',
                data:{
                    groupID: groupID,
                    changeInfos: changeInfos
                }
            }
            setCallbackData(res)
        },
        onReceiveJoinApplication: (
            groupID,
            member,
            opReason
        ) => {
            const res = {
                type: 'onReceiveJoinApplication',
                data: {
                    groupID: groupID,
                    member: member,
                    opReason: opReason
                }
            }
            setCallbackData(res)
        },
        onApplicationProcessed: (
            groupID,
            opUser,
            isAgreeJoin,
            opReason
        ) => {
            const res = {
                type: 'onApplicationProcessed',
                data: {
                    groupID: groupID,
                    opUser: opUser,
                    isAgreeJoin: isAgreeJoin,
                    opReason: opReason
                }
            }
            setCallbackData(res)
        },
        onGrantAdministrator: (
            groupID,
            opUser,
            memberList
        ) => {
            const res = {
                type: 'onGrantAdministrator',
                data: {
                    groupID: groupID,
                    opUser: opUser,
                    memberList: memberList
                }
            }
            setCallbackData(res)
        },
        onRevokeAdministrator: (
            groupID,
            opUser,
            memberList
        ) => {
            const res = {
                type: 'onRevokeAdministrator',
                data:{
                    groupID: groupID,
                    opUser: opUser,
                    memberList: memberList
                }
            }
            setCallbackData(res)
        },
        onQuitFromGroup: (groupID) => {
            const res = {
                type: 'onQuitFromGroup',
                data: {
                    groupID: groupID,
                }               
            }
            setCallbackData(res)
        },
        onReceiveRESTCustomData: (groupID, customData) => {
            const res = {
                type: 'onReceiveRESTCustomData',
                data:{
                    groupID: groupID,
                    customData: customData
                }
            }
            setCallbackData(res)
        },
        onGroupAttributeChanged: (
            groupID,
            groupAttribute
        ) => {
            const res = {
                type: 'onGroupAttributeChanged',
                data:{
                    groupID: groupID,
                    groupAttribute: groupAttribute
                }
            }
            setCallbackData(res)
        }
    };
    const FriendListenerObj = {
        onFriendApplicationListAdded: (
            applicationList
        ) => {
            const res = {
                type: 'onFriendApplicationListAdded',
                data: {
                    applicationList: applicationList
                }
            }
            setCallbackData(res)
        },
        onFriendApplicationListDeleted: (userIDList) => {
            const res = {
                type: 'onFriendApplicationListDeleted',
                data: {
                    userIDList: userIDList
                }
            }
            setCallbackData(res)
        },
        onFriendApplicationListRead: () => {
            const res = {
                type: 'onFriendApplicationListRead',
                data: {}
            }
            setCallbackData(res)
        },
        onFriendListAdded: (users) => {
            const res = {
                type: 'onFriendApplicationListRead',
                data: {
                    users: users
                }
            }
            setCallbackData(res)
        },
        onFriendListDeleted: (userList) => {
            const res = {
                type: 'onFriendListDeleted',
                data:{
                    userList: userList
                }
            }
            setCallbackData(res)
        },
        onBlackListAdd: (user) => {
            const res = {
                type: 'onBlackListAdd',
                data: {
                    user: user
                }
            }
            setCallbackData(res)
        },
        onBlackListDeleted: (userList) => {
            const res = {
                type: 'onBlackListDeleted',
                data:{
                    userList: userList
                }
            }
            setCallbackData(res)
        },
        onFriendInfoChanged: (users) => {
            const res = {
                type: 'onFriendInfoChanged',
                data:{
                    users: users
                }
            }
            setCallbackData(res)
        }
    };
    const advancedMsgListenerObj = {
        onRecvNewMessage: (message) => {
            const res = {
                type: 'onRecvNewMessage',
                data:{
                    message: message,
                }
            }
            setCallbackData(res)
        },
        onRecvMessageModified: (message) => {
            const res = {
                type: 'onRecvMessageModified',
                data:{
                    message: message,
                }
            }
            setCallbackData(res)
        },
        onSendMessageProgress: (message, progress) => {
            const res = {
                type: 'onSendMessageProgress',
                data: {
                    message: message,
                    progress: progress
                }
            }
            setCallbackData(res)
        },
        onRecvC2CReadReceipt: (receiptList) => {
            const res = {
                type: 'onRecvC2CReadReceipt',
                data:{
                    receiptList: receiptList,
                }
            }
            setCallbackData(res)
        },
        onRecvMessageRevoked: (msgID) => {
            const res = {
                type: 'onRecvMessageRevoked',
                data: {
                    msgID: msgID,
                }
            }
            setCallbackData(res)
        },
        onRecvMessageReadReceipts: (receiptList) => {
            const res = {
                type: 'onRecvMessageReadReceipts',
                data:{
                    receiptList: receiptList,
                }
            }
            setCallbackData(res)
        }

    };
    const conversationListenerObj = {
        onSyncServerStart: () => {
            const res = {
                type: 'onSyncServerStart',
                data:{}
            }
            setCallbackData(res)
        },
        onSyncServerFinish: () => {
            const res = {
                type: 'onSyncServerFinish',
                data:{}
            }
            setCallbackData(res)
        },
        onSyncServerFailed: () => {
            const res = {
                type: 'onSyncServerFailed',
                data:{}
            }
            setCallbackData(res)
        },
        onNewConversation: (conversationList) => {
            const res = {
                type: 'onNewConversation',
                data:{
                    conversationList: conversationList
                }
            }
            setCallbackData(res)
        },
        onTotalUnreadMessageCountChanged: (totalUnreadCount) => {
            const res = {
                type: 'onTotalUnreadMessageCountChanged',
                data:{
                    totalUnreadCount: totalUnreadCount
                }
            }
            setCallbackData(res)
        },
        onConversationChanged: (conversationList) => {
            const res = {
                type: 'onConversationChanged',
                data:{
                    conversationList: conversationList
                }
            }
            setCallbackData(res)
        }
    };
    const signalingListenerObj = {
        onReceiveNewInvitation: (
            inviteID,
            inviter,
            groupID,
            inviteeList,
            data
        ) => {
            const res = {
                type: 'onReceiveNewInvitation',
                data: {
                    inviteID,
                    inviter,
                    groupID,
                    inviteeList,
                    data
                }
            }
            setCallbackData(res)
        },
        onInviteeAccepted: (
            inviteID,
            invitee,
            data
        ) => {
            const res = {
                type: 'onInviteeAccepted',
                data:{
                    inviteID,
                    invitee,
                    data
                }
            }
            setCallbackData(res)
        },
        onInviteeRejected: (
            inviteID,
            invitee,
            data
        ) => {
            const res = {
                type: 'onInviteeRejected',
                data:{
                    inviteID,
                    invitee,
                    data
                }
            }
            setCallbackData(res)
        },
        onInvitationCancelled: (
            inviteID,
            inviter,
            data
        ) => {
            const res = {
                type: 'onInvitationCancelled',
                data:{
                    inviteID,
                    inviter,
                    data
                }
            }
            setCallbackData(res)
        },
        onInvitationTimeout: (
            inviteID,
            inviteeList
        ) => {
            const res = {
                type: 'onInvitationTimeout',
                data:{
                    inviteID,
                    inviteeList
                }
            }
            setCallbackData(res)
        }
    }
    const addEventListener = async () => {
        await TencentImSDKPlugin.v2TIMManager.addGroupListener(groupListenerObj)
        await TencentImSDKPlugin.v2TIMManager.addSimpleMsgListener(simeMsgListenerObj)
        await TencentImSDKPlugin.v2TIMManager.getFriendshipManager().addFriendListener(FriendListenerObj);
        await TencentImSDKPlugin.v2TIMManager.getMessageManager().addAdvancedMsgListener(advancedMsgListenerObj)
        await TencentImSDKPlugin.v2TIMManager.getConversationManager().addConversationListener(conversationListenerObj)
        await TencentImSDKPlugin.v2TIMManager.getSignalingManager().addSignalingListener(signalingListenerObj)
    }
    const removeSimpleMsgListener = () => {
        TencentImSDKPlugin.v2TIMManager.removeSimpleMsgListener(simeMsgListenerObj)
    }
    const removeAllSimpleMsgListener = () => {
        TencentImSDKPlugin.v2TIMManager.removeSimpleMsgListener()
    }
    const removeAdvanceMsgListener = () => {
        TencentImSDKPlugin.v2TIMManager.getMessageManager().removeAdvancedMsgListener(advancedMsgListenerObj)
    }
    const removeAllAdvanceMsgListener = () => {
        TencentImSDKPlugin.v2TIMManager.getMessageManager().removeAdvancedMsgListener()
    }
    const removeSignalingListener = () => {
        TencentImSDKPlugin.v2TIMManager.getSignalingManager().removeSignalingListener(signalingListenerObj)
    }
    const removeAllSignalingListener = () => {
        TencentImSDKPlugin.v2TIMManager.getSignalingManager().removeSignalingListener()
    }
    const removeFriendListener = ()=>{
        TencentImSDKPlugin.v2TIMManager.getFriendshipManager().removeFriendListener(FriendListenerObj)
    } 
    const removeAllFriendListener= () =>{
        TencentImSDKPlugin.v2TIMManager.getFriendshipManager().removeFriendListener()
    }
    const removeConversationListener = () =>{
        TencentImSDKPlugin.v2TIMManager.getConversationManager().removeConversationListener(conversationListenerObj)
    }
    const removeAllConversationListener = ()=>{
        TencentImSDKPlugin.v2TIMManager.getConversationManager().removeConversationListener()
    }

    return (
        <>
            <CommonButton
                handler={() => addEventListener()}
                content={'注册事件'}
            ></CommonButton>
            <CommonButton
                handler={() => removeSimpleMsgListener()}
                content={'注销simpleMsgListener'}
            ></CommonButton>
            <CommonButton
                handler={() => removeAllSimpleMsgListener()}
                content={'注销所有simpleMsgListener'}
            ></CommonButton>
            <CommonButton
                handler={() => removeAdvanceMsgListener()}
                content={'注销advanceMsgListener'}
            ></CommonButton>
            <CommonButton
                handler={() => removeAllAdvanceMsgListener()}
                content={'注销所有advanceMsgListener'}
            ></CommonButton>
            <CommonButton
                handler={() => removeSignalingListener()}
                content={'注销signalingListener'}
            ></CommonButton>
            <CommonButton
                handler={() => removeAllSignalingListener()}
                content={'注销所有signalingListener'}
            ></CommonButton>
            <CommonButton
                handler={() => removeFriendListener()}
                content={'注销所有friendListener'}
            ></CommonButton>
            <CommonButton
                handler={() => removeAllFriendListener()}
                content={'注销所有friendListener'}
            ></CommonButton>
            <CommonButton
                handler={() => removeConversationListener()}
                content={'注销所有conversationListener'}
            ></CommonButton>
            <CommonButton
                handler={() => removeAllConversationListener()}
                content={'注销所有conversationListener'}
            ></CommonButton>
        </>
    );
};

export default AddEventListenerComponent;
