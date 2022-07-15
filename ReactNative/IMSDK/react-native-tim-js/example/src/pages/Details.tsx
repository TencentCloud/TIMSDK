import * as React from 'react';

import { StyleSheet, View, Image } from 'react-native';
import ActionButton from 'react-native-action-button';
import InitSDKComponent from '../components/basicComponents/InitSDKComponent';
import UninitSDKComponent from '../components/basicComponents/UninitSDKComponent';
import LoginComponent from '../components/basicComponents/LoginComponent';
import LogoutComponent from '../components/basicComponents/LogoutComponent';
import GetVersionComponent from '../components/basicComponents/GetVersionComponent';
import GetLoginUserComponent from '../components/basicComponents/GetLoginUser';
import GetServerTimeComponent from '../components/basicComponents/GetServerTimeComponent';
import SendC2CTextMessageComponent from '../components/basicComponents/SendC2CTextMessage';
import SendC2CCustomMessageComponent from '../components/basicComponents/SendC2CCustomMessage';
import GetUsersInfoComponent from '../components/basicComponents/GetUsersInfoComponent';
import GetFriendListComponent from '../components/friendsComponents/GetFriendList';
import GetFriendsInfoComponent from '../components/friendsComponents/GetFriendsInfo';
import CreateGroupComponent from '../components/basicComponents/CreateGroup';
import { GetConversationList } from '../components/conversationComponents/getConversationList';
import { GetConversationListByConversationIDs } from '../components/conversationComponents/getConversationListByConversaionIds';
import JoinGroupComponent from '../components/basicComponents/JoinGroup';
import GetGroupsInfoComponent from '../components/groupComponents/GetGroupsInfo';
import GetJoinedGroupListComponent from '../components/groupComponents/GetJoinedGroupList';
import QuitGroupComponent from '../components/basicComponents/QuitGroup';
import DismissGroupComponent from '../components/basicComponents/DismissGroup';
import CallExperimentalAPIComponent from '../components/basicComponents/CallExperimentalAPI';
import SetSelfInfoComponent from '../components/basicComponents/SetSelfInfo';
import SendTextMessageComponent from '../components/messageComponents/SendTextMessage';
import SendCustomMessageComponent from '../components/messageComponents/SendCustomMessage';
import SendImageMessageComponent from '../components/messageComponents/SendImageMessage';
import SendVideoMessageComponent from '../components/messageComponents/SendVideoMessage';
import SendGroupTextMessageComponent from '../components/basicComponents/SendGroupTextMessage';
import SendGroupCustomMessageComponent from '../components/basicComponents/SendGroupCustomMessage';
import AddFriendComponent from '../components/friendsComponents/AddFriend';
import SetFriendInfoComponent from '../components/friendsComponents/SetFriendInfo';
import DeleteFromFriendListComponent from '../components/friendsComponents/DeleteFromFriendList';
import CheckFriendComponent from '../components/friendsComponents/CheckFriend';
import GetFriendApplicationListComponent from '../components/friendsComponents/GetFriendApplicationList';
import AgreeFriendApplicationComponent from '../components/friendsComponents/AgreeFriendApplication';
import RefuseFriendApplicationStateComponent from '../components/friendsComponents/RefuseFriendApplicationState';
import GetBlackListComponent from '../components/friendsComponents/GetBlackList';
import AddToBlackListComponent from '../components/friendsComponents/AddToBlackList';
import DeleteFromBlackListComponent from '../components/friendsComponents/DeleteFromBlackList';
import CreateFriendGroupComponent from '../components/friendsComponents/CreateFriendGroup';
import GetFriendGroupsComponent from '../components/friendsComponents/GetFriendGroups';
import DeleteFriendGroupComponent from '../components/friendsComponents/DeleteFriendGroup';
import RenameFriendGroupComponent from '../components/friendsComponents/RenameFriendGroup';
import AddFriendToFriendGroupComponent from '../components/friendsComponents/AddFriendsToFriendGroup';
import DeleteFriendFromFriendGroupComponent from '../components/friendsComponents/DeleteFriendsFromFriendGroup';
import SearchFriendsComponent from '../components/friendsComponents/SearchFriends';
import CreateSuperGroupComponent from '../components/groupComponents/CreateGroup';
import SetGroupInfoComponent from '../components/groupComponents/SetGroupInfo';
import GetGroupOnlineMemberCountComponent from '../components/groupComponents/GetGroupOnlineMemberCount';
import GetGroupMemberListComponent from '../components/groupComponents/GetGroupMemberList';
import GetGroupMembersInfoComponent from '../components/groupComponents/GetGroupMembersInfo';
import SetGroupMemberInfoComponent from '../components/groupComponents/SetGroupMemberInfo';
import MuteGroupMemberComponent from '../components/groupComponents/MuteGroupMember';
import InviteUserToGroupComponent from '../components/groupComponents/InviteUserToGroup';
import KickGroupMemberComponent from '../components/groupComponents/KickGroupMember';
import SetGroupMemberRoleComponent from '../components/groupComponents/SetGroupMemberRole';
import TransferGroupOwnerComponent from '../components/groupComponents/TransferGroupOwner';
import SearchGroupsComponent from '../components/groupComponents/SearchGroups';
import SearchGroupMembersComponent from '../components/groupComponents/SearchGroupMembers';
import SendFileMessageComponent from '../components/messageComponents/SendFileMessage';
import SendSoundMessageComponent from '../components/messageComponents/SendSoundMessage';
import SendTextAtMessageComponent from '../components/messageComponents/SendTextAtMessage';
import SendLocationMessageComponent from '../components/messageComponents/SendLocationMessage';
import SendFaceMessageComponent from '../components/messageComponents/SendFaceMessage';
import SendMergerMessageComponent from '../components/messageComponents/SendMergerMessage';
import SendForwardMessageComponent from '../components/messageComponents/SendForwardMessage';
import ReSendMessageComponent from '../components/messageComponents/ReSendMessage';
import SetLocalCustomDataComponent from '../components/messageComponents/SetLocalCustomData';
import SetLocalCustomIntComponent from '../components/messageComponents/SetLocalCustomInt';
import GetC2CHistoryMessageListComponent from '../components/messageComponents/GetC2CHistoryMessageList';
import GetGroupHistoryMessageListComponent from '../components/messageComponents/GetGroupHistoryMessageList';
import RevokeMessageComponent from '../components/messageComponents/RevokeMessage';
import MarkC2CMessageAsReadComponent from '../components/messageComponents/MarkC2CMessageAsRead';
import MarkGroupMessageAsReadComponent from '../components/messageComponents/MarkGroupMessageAsRead';
import MarkAllMessageAsReadComponent from '../components/messageComponents/MarkAllMessageAsRead';
import DeleteMessageFromLocalCStorageComponent from '../components/messageComponents/DeleteMessageFromLocalStorage';
import DeleteMessageComponent from '../components/messageComponents/DeleteMessage';
import ClearC2CHistoryMessageComponent from '../components/messageComponents/ClearC2CHistoryMessage';
import GetC2CReceiveMessageOptComponent from '../components/messageComponents/GetC2CReceiveMessageOpt';
import ClearGroupHistoryMessageComponent from '../components/messageComponents/ClearGroupHistoryMessage';
import SearchLocalMessageComponent from '../components/messageComponents/SearchLocalMessage';
import FindMessageComponent from '../components/messageComponents/FindMessage';
import InsertGroupMessageToLocalStorageComponent from '../components/messageComponents/InsertGroupMessageToLocalStorage';
import InsertC2CMessageToLocalStorageComponent from '../components/messageComponents/InsertC2CMessageToLocalStorage';
import GetHistoryMessageListComponent from '../components/messageComponents/GetHistoryMessageList';
import AddEventListenerComponent from '../components/basicComponents/AddEventListener';
import InviteComponent from '../components/signalingComponents/Invite';
import InviteInGroupComponent from '../components/signalingComponents/InviteInGroup';
import GetSignallingInfoComponent from '../components/signalingComponents/GetSignallingInfo';
import { PinConversation } from '../components/conversationComponents/pinConversation';
import { GetTotalUnreadMessageCount } from '../components/conversationComponents/getTotalUnreadMessageCount';
import { GetConversation } from '../components/conversationComponents/getConversation';
import { DeleteConversation } from '../components/conversationComponents/deleteConversation';
import { SetConversationDraft } from '../components/conversationComponents/setConversationDraft';
const DetailsScreen = ({ navigation }) => {
    const id = navigation.state.params.idStr;
    const renderIcon = () => {
        return (
            <Image source={require('../icon/icon.png')} style={styles.icon} />
        )
    }
    return (
        <>
            <View style={styles.detail}>
                {(() => {
                    switch (id) {
                        case 'initSDK':
                            return <InitSDKComponent />;
                        case 'login':
                            return <LoginComponent />;
                        case 'unInitSDK':
                            return <UninitSDKComponent />;
                        case 'logout':
                            return <LogoutComponent />;
                        case 'getLoginUser':
                            return <GetLoginUserComponent />;
                        case 'getVersion':
                            return <GetVersionComponent />;
                        case 'getServerTime':
                            return <GetServerTimeComponent />;
                        case 'sendC2CTextMessage':
                            return <SendC2CTextMessageComponent />;
                        case 'sendC2CCustomMessage':
                            return <SendC2CCustomMessageComponent />;
                        case 'sendGroupTextMessage':
                            return <SendGroupTextMessageComponent />;
                        case 'sendGroupCustomMessage':
                            return <SendGroupCustomMessageComponent />
                        case 'getUsersInfo':
                            return <GetUsersInfoComponent />;
                        case 'getFriendList':
                            return <GetFriendListComponent />;
                        case 'getFriendsInfo':
                            return <GetFriendsInfoComponent />;
                        case 'createGroup':
                            return <CreateGroupComponent />;
                        case 'getConversationList':
                            return <GetConversationList />;
                        case 'getConversationListByConversationIDs':
                            return <GetConversationListByConversationIDs />;
                        case 'pinConversation':
                            return <PinConversation />;
                        case 'getTotalUnreadMessageCount':
                            return <GetTotalUnreadMessageCount />;
                        case 'getConversation':
                            return <GetConversation />;
                        case 'deleteConversation':
                            return <DeleteConversation />;
                        case 'setConversationDraft':
                            return <SetConversationDraft />;
                        case 'joinGroup':
                            return <JoinGroupComponent />;
                        case 'getGroupsInfo':
                            return <GetGroupsInfoComponent />;
                        case 'getJoinedGroupList':
                            return <GetJoinedGroupListComponent />;
                        case 'quitGroup':
                            return <QuitGroupComponent />;
                        case 'dismissGroup':
                            return <DismissGroupComponent />;
                        case 'callExperimentalAPI':
                            return <CallExperimentalAPIComponent />;
                        case 'setSelfInfo':
                            return <SetSelfInfoComponent />;
                        case 'sendTextMessage':
                            return <SendTextMessageComponent />;
                        case 'sendCustomMessage':
                            return <SendCustomMessageComponent />;
                        case 'sendImageMessage':
                            return <SendImageMessageComponent />;
                        case 'sendVideoMessage':
                            return <SendVideoMessageComponent />;
                        case 'addFriend':
                            return <AddFriendComponent />;
                        case 'setFriendInfo':
                            return <SetFriendInfoComponent />;
                        case 'deleteFromFriendList':
                            return <DeleteFromFriendListComponent />;
                        case 'checkFriend':
                            return <CheckFriendComponent />;
                        case 'getFriendApplicationList':
                            return <GetFriendApplicationListComponent />;
                        case 'agreeFriendApplication':
                            return <AgreeFriendApplicationComponent />;
                        case 'refuseFriendApplicationState':
                            return <RefuseFriendApplicationStateComponent />;
                        case 'getBlackList':
                            return <GetBlackListComponent />;
                        case 'addToBlackList':
                            return <AddToBlackListComponent />;
                        case 'deleteFromBlackList':
                            return <DeleteFromBlackListComponent />;
                        case 'createFriendGroup':
                            return <CreateFriendGroupComponent />;
                        case 'getFriendGroups':
                            return <GetFriendGroupsComponent />;
                        case 'deleteFriendGroup':
                            return <DeleteFriendGroupComponent />;
                        case 'renameFriendGroup':
                            return <RenameFriendGroupComponent />;
                        case 'addFriendsToFriendGroup':
                            return <AddFriendToFriendGroupComponent />;
                        case 'deleteFriendsFromFriendGroup':
                            return <DeleteFriendFromFriendGroupComponent />;
                        case 'searchFriends':
                            return <SearchFriendsComponent />;
                        case 'createSuperGroup':
                            return <CreateSuperGroupComponent />;
                        case 'setGroupInfo':
                            return <SetGroupInfoComponent />;
                        case 'getGroupOnlineMemberCount':
                            return <GetGroupOnlineMemberCountComponent />;
                        case 'getGroupMemberList':
                            return <GetGroupMemberListComponent />;
                        case 'getGroupMembersInfo':
                            return <GetGroupMembersInfoComponent />;
                        case 'setGroupMemberInfo':
                            return <SetGroupMemberInfoComponent />;
                        case 'muteGroupMember':
                            return <MuteGroupMemberComponent />;
                        case 'inviteUserToGroup':
                            return <InviteUserToGroupComponent />;
                        case 'kickGroupMember':
                            return <KickGroupMemberComponent />;
                        case 'setGroupMemberRole':
                            return <SetGroupMemberRoleComponent />;
                        case 'transferGroupOwner':
                            return <TransferGroupOwnerComponent />;
                        case 'searchGroups':
                            return <SearchGroupsComponent />;
                        case 'searchGroupMembers':
                            return <SearchGroupMembersComponent />;
                        case 'sendFileMessage':
                            return <SendFileMessageComponent />;
                        case 'sendSoundMessage':
                            return <SendSoundMessageComponent />;
                        case 'sendTextAtMessage':
                            return <SendTextAtMessageComponent />;
                        case 'sendLocationMessage':
                            return <SendLocationMessageComponent />;
                        case 'sendFaceMessage':
                            return <SendFaceMessageComponent />;
                        case 'sendMergerMessage':
                            return <SendMergerMessageComponent />;
                        case 'sendForwardMessage':
                            return <SendForwardMessageComponent />;
                        case 'reSendMessage':
                            return <ReSendMessageComponent />;
                        case 'setLocalCustomData':
                            return <SetLocalCustomDataComponent />;
                        case 'setLocalCustomInt':
                            return <SetLocalCustomIntComponent />;
                        case 'getC2CHistoryMessageList':
                            return <GetC2CHistoryMessageListComponent />;
                        case 'getGroupHistoryMessageList':
                            return <GetGroupHistoryMessageListComponent />;
                        case 'revokeMessage':
                            return <RevokeMessageComponent />;
                        case 'markC2CMessageAsRead':
                            return <MarkC2CMessageAsReadComponent />;
                        case 'markGroupMessageAsRead':
                            return <MarkGroupMessageAsReadComponent />;
                        case 'markAllMessageAsRead':
                            return <MarkAllMessageAsReadComponent />;
                        case 'deleteMessageFromLocalStorage':
                            return <DeleteMessageFromLocalCStorageComponent />;
                        case 'deleteMessage':
                            return <DeleteMessageComponent />;
                        case 'clearC2CHistoryMessage':
                            return <ClearC2CHistoryMessageComponent />;
                        case 'getC2CReceiveMessageOpt':
                            return <GetC2CReceiveMessageOptComponent />;
                        case 'clearGroupHistoryMessage':
                            return <ClearGroupHistoryMessageComponent />;
                        case 'searchLocalMessage':
                            return <SearchLocalMessageComponent />;
                        case 'findMessage':
                            return <FindMessageComponent />;
                        case 'insertGroupMessageToLocalStorage':
                            return <InsertGroupMessageToLocalStorageComponent />;
                        case 'insertC2CMessageToLocalStorage':
                            return <InsertC2CMessageToLocalStorageComponent />;
                        case 'getHistoryMessageList':
                            return <GetHistoryMessageListComponent />;
                        case 'addEventListener':
                            return <AddEventListenerComponent />;
                        case 'invite':
                            return <InviteComponent />;
                        case 'inviteInGroup':
                            return <InviteInGroupComponent />;
                        case 'getSignallingInfo':
                            return <GetSignallingInfoComponent />;
                        case 'addInvitedSignaling':
                            return <></>;
                        default:
                            return <></>;
                    }
                })()}
            </View>
            <ActionButton
                buttonColor="rgba(221,160,221,0.8)"
                onPress={() => { navigation.navigate('CallBack'); }}
                renderIcon={renderIcon}
            />
        </>

    );
};
export default DetailsScreen;

const styles = StyleSheet.create({
    detail: {
        backgroundColor: '#fff',
        borderRadius: 3,
        margin: 10,
    },
    detailButton: {
        backgroundColor: '#2F80ED',
        color: '#fff',
        margin: 10,
        fontSize: 14,
        lineHeight: 28,
        textAlign: 'center',
    },
    icon: {
        width: 40,
        height: 40
    }
});
