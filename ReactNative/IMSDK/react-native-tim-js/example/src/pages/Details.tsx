import * as React from 'react';

import { StyleSheet, View } from 'react-native';
import InitSDKComponent from '../components/basicComponent/InitSDKComponent';
import UninitSDKComponent from '../components/basicComponent/UninitSDKComponent';
import LoginComponent from '../components/basicComponent/LoginComponent';
import LogoutComponent from '../components/basicComponent/LogoutComponent';
import GetVersionComponent from '../components/basicComponent/GetVersionComponent';
import GetLoginUserComponent from '../components/basicComponent/GetLoginUser';
import GetServerTimeComponent from '../components/basicComponent/GetServerTimeComponent';
import SendC2CTextMessageComponent from '../components/basicComponent/SendC2CTextMessage';
import SendC2CCustomMessageComponent from '../components/basicComponent/SendC2CCustomMessage';
import GetUsersInfoComponent from '../components/basicComponent/GetUsersInfoComponent';
import GetFriendListComponent from '../components/friendsComponents/GetFriendList';
import GetFriendsInfoComponent from '../components/friendsComponents/GetFriendsInfo';
import CreateGroupComponent from '../components/basicComponent/CreateGroup';
import { GetConversationList } from '../components/conversationComponents/getConversationList';
import { GetConversationListByConversationIDs } from '../components/conversationComponents/getConversationListByConversaionIds';
import JoinGroupComponent from '../components/basicComponent/JoinGroup';
import GetGroupsInfoComponent from '../components/groupComponents/GetGroupsInfo';
import GetJoinedGroupListComponent from '../components/groupComponents/GetJoinedGroupList';
import QuitGroupComponent from '../components/basicComponent/QuitGroup';
import DismissGroupComponent from '../components/basicComponent/DismissGroup';
import CallExperimentalAPIComponent from '../components/basicComponent/CallExperimentalAPI';
import SetSelfInfoComponent from '../components/basicComponent/SetSelfInfo';
import SendTextMessageComponent from '../components/messageComponents/SendTextMessage';
import SendCustomMessageComponent from '../components/messageComponents/SendCustomMessage';
import SendImageMessageComponent from '../components/messageComponents/SendImageMessage';
import SendVideoMessageComponent from '../components/messageComponents/SendVideoMessage';
import SendGroupTextMessageComponent from '../components/basicComponent/SendGroupTextMessage';
import SendGroupCustomMessageComponent from '../components/basicComponent/SendGroupCustomMessage';
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
import { PinConversation } from '../components/conversationComponents/pinConversation';
import { GetTotalUnreadMessageCount } from '../components/conversationComponents/getTotalUnreadMessageCount';
import { GetConversation } from '../components/conversationComponents/getConversation';
import { DeleteConversation } from '../components/conversationComponents/deleteConversation';
import { SetConversationDraft } from '../components/conversationComponents/setConversationDraft';
const DetailsScreen = ({ navigation }) => {
    const id = navigation.state.params.idStr;
    return (
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
                        return <GetFriendApplicationListComponent/>;
                    case 'agreeFriendApplication':
                        return <AgreeFriendApplicationComponent/>;
                    case 'refuseFriendApplicationState':
                        return <RefuseFriendApplicationStateComponent/>;
                    case 'getBlackList':
                        return <GetBlackListComponent/>;
                    case 'addToBlackList':
                        return <AddToBlackListComponent/>;
                    case 'deleteFromBlackList':
                        return <DeleteFromBlackListComponent/>;
                    case 'createFriendGroup':
                        return <CreateFriendGroupComponent/>;
                    case 'getFriendGroups':
                        return <GetFriendGroupsComponent/>;
                    case 'deleteFriendGroup':
                        return <DeleteFriendGroupComponent/>;
                    case 'renameFriendGroup':
                        return <RenameFriendGroupComponent/>;
                    case 'addFriendsToFriendGroup':
                        return <AddFriendToFriendGroupComponent/>;
                    case 'deleteFriendsFromFriendGroup':
                        return <DeleteFriendFromFriendGroupComponent/>;
                    case 'searchFriends':
                        return <SearchFriendsComponent/>;
                    case 'createSuperGroup':
                        return <CreateSuperGroupComponent/>;
                    case 'setGroupInfo':
                        return <SetGroupInfoComponent/>;
                    case 'getGroupOnlineMemberCount':
                        return <GetGroupOnlineMemberCountComponent/>;
                    case 'getGroupMemberList':
                        return <GetGroupMemberListComponent/>;
                    case 'getGroupMembersInfo':
                        return <GetGroupMembersInfoComponent/>;
                    case 'setGroupMemberInfo':
                        return <SetGroupMemberInfoComponent/>;
                    case 'muteGroupMember':
                        return <MuteGroupMemberComponent/>;
                    case 'inviteUserToGroup':
                        return <InviteUserToGroupComponent/>;
                    case 'kickGroupMember':
                        return <KickGroupMemberComponent/>;
                    case 'setGroupMemberRole':
                        return <SetGroupMemberRoleComponent/>;
                    case 'transferGroupOwner':
                        return <TransferGroupOwnerComponent/>;
                    case 'searchGroups':
                        return <SearchGroupsComponent/>;
                    case 'searchGroupMembers':
                        return <SearchGroupMembersComponent/>
                    default:
                        return <></>;
                }
            })()}
        </View>
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
});
