import React, { useState } from 'react';

import {
    StyleSheet,
    View,
    Text,
    SectionList,
    TouchableOpacity,
    Image
} from 'react-native';
import ActionButton from 'react-native-action-button';


const DATA = [
    {
        title: '基础模块',
        id: 1,
        show: false,
        data: [
            {
                id: 'initSDK',
                name: '初始化SDK',
            },
            {
                id: 'addEventListener',
                name: '添加事件监听',
            },
            {
                id: 'login',
                name: '登录',
            },
            {
                id: 'unInitSDK',
                name: 'unInitSDK',
            },
            {
                id: 'logout',
                name: '登出',
            },
            {
                id: 'getLoginUser',
                name: '获取当前登录用户',
            },
            {
                id: 'getVersion',
                name: '获取SDK版本',
            },
            {
                id: 'getServerTime',
                name: '获得服务端时间',
            },
            {
                id: 'sendC2CTextMessage',
                name: '发送C2C文本消息',
            },
            {
                id: 'sendC2CCustomMessage',
                name: '发送C2C自定义消息',
            },
            {
                id: 'sendGroupTextMessage',
                name: '发送Group文本消息'
            },
            {
                id: 'sendGroupCustomMessage',
                name: '发送Group自定义消息'
            },
            {
                id: 'getUsersInfo',
                name: '获取用户信息',
            },
            {
                id: 'createGroup',
                name: '创建群聊',
            },
            {
                id: 'joinGroup',
                name: '加入群聊',
            },
            {
                id: 'quitGroup',
                name: '退出群聊',
            },
            {
                id: 'dismissGroup',
                name: '解散群聊',
            },
            {
                id: 'callExperimentalAPI',
                name: '试验性接口',
            },
            {
                id: 'setSelfInfo',
                name: '设置个人信息',
            },
        ],
    },
    {
        title: '群组模块',
        id: 2,
        show: false,
        data: [
            {
                id: 'getGroupsInfo',
                name: '获取群信息',
            },
            {
                id: 'getJoinedGroupList',
                name: '获取加群列表',
            },
            {
                id: 'createSuperGroup',
                name: '高级创建群组',
            },
            {
                id: 'setGroupInfo',
                name: '设置群信息'
            },
            {
                id: 'getGroupOnlineMemberCount',
                name: '获取群在线人数'
            },
            {
                id: 'getGroupMemberList',
                name: '获取群成员列表'
            },
            {
                id: 'getGroupMembersInfo',
                name: '获得群成员信息'
            },
            {
                id: 'setGroupMemberInfo',
                name: '设置群成员信息'
            },
            {
                id: 'muteGroupMember',
                name: '禁言群成员'
            },
            {
                id: 'inviteUserToGroup',
                name: '邀请好友进群'
            },
            {
                id: 'kickGroupMember',
                name: '踢人出群'
            },
            {
                id: 'setGroupMemberRole',
                name: '设置群角色'
            },
            {
                id: 'transferGroupOwner',
                name: '转移群主'
            },
            {
                id: 'searchGroups',
                name: '搜索群列表'
            },
            {
                id: 'searchGroupMembers',
                name: '搜索群成员'
            }
        ],
    },
    {
        title: '好友关系链模块',
        id: 3,
        show: false,
        data: [
            {
                id: 'getFriendList',
                name: '获取好友列表',
            },
            {
                id: 'getFriendsInfo',
                name: '获取好友信息',
            },
            {
                id: 'addFriend',
                name: '添加好友'
            },
            {
                id: 'setFriendInfo',
                name: '设置好友信息'
            },
            {
                id: 'deleteFromFriendList',
                name: '删除好友'
            },
            {
                id: 'checkFriend',
                name: '检测好友'
            },
            {
                id: 'getFriendApplicationList',
                name: '获得好友申请列表'
            },
            {
                id: 'agreeFriendApplication',
                name: '同意好友申请'
            },
            {
                id: 'refuseFriendApplicationState',
                name: '拒绝好友申请'
            },
            {
                id: 'getBlackList',
                name: '获取黑名单列表'
            },
            {
                id: 'addToBlackList',
                name: '添加到黑名单'
            },
            {
                id: 'deleteFromBlackList',
                name: '从黑名单移除'
            },
            {
                id: 'createFriendGroup',
                name: '创建好友分组'
            },
            {
                id: 'getFriendGroups',
                name: '获取好友分组'
            },
            {
                id: 'deleteFriendGroup',
                name: '删除好友分组'
            },
            {
                id: 'renameFriendGroup',
                name: '重命名好友分组'
            },
            {
                id: 'addFriendsToFriendGroup',
                name: '添加好友到分组'
            },
            {
                id: 'deleteFriendsFromFriendGroup',
                name: '从分组中删除好友'
            },
            {
                id: 'searchFriends',
                name: '搜索好友'
            }

        ],
    },
    {
        title: '消息模块',
        id: 4,
        show: false,
        data: [
            {
                id: 'sendTextMessage',
                name: '发送文本消息',
            },
            {
                id: 'sendCustomMessage',
                name: '发送自定义消息',
            },
            {
                id: 'sendImageMessage',
                name: '发送图片消息',
            },
            {
                id: 'sendVideoMessage',
                name: '发送视频消息',
            },
            {
                id: 'sendFileMessage',
                name: '发送文件消息',
            },
            {
                id: 'sendSoundMessage',
                name: '发送录音消息',
            },
            {
                id: 'sendTextAtMessage',
                name: '发送文本At消息',
            },
            {
                id: 'sendLocationMessage',
                name: '发送地理信息'
            },
            {
                id: 'sendFaceMessage',
                name: '发送表情消息'
            },
            {
                id: 'sendMergerMessage',
                name: '发送合并消息'
            },
            {
                id: 'sendForwardMessage',
                name: '发送转发消息'
            },
            {
                id: 'reSendMessage',
                name: '重发消息'
            },
            {
                id: 'setLocalCustomData',
                name: '修改本地消息（String）'
            },
            {
                id: 'setLocalCustomInt',
                name: '修改本地消息（Int）'
            },
            {
                id: 'getC2CHistoryMessageList',
                name: '获得C2C历史消息'
            },
            {
                id: 'getGroupHistoryMessageList',
                name: '获得Group历史消息'
            },
            {
                id: 'getHistoryMessageList',
                name: '获得历史消息高级接口'
            },
            {
                id: 'revokeMessage',
                name: '撤回消息'
            },
            {
                id: 'markC2CMessageAsRead',
                name: '标记C2C会话已读'
            },
            {
                id: 'markGroupMessageAsRead',
                name: '标记Group会话已读'
            },
            {
                id: 'markAllMessageAsRead',
                name: '标记所有消息已读'
            },
            {
                id: 'deleteMessageFromLocalStorage',
                name: '删除本地消息'
            },
            {
                id: 'deleteMessage',
                name: '删除消息'
            },
            {
                id: 'insertGroupMessageToLocalStorage',
                name: '向Group中插入一条本地消息'
            },
            {
                id: 'insertC2CMessageToLocalStorage',
                name: '向C2C会话中插入一条本地消息'
            },
            {
                id: 'clearC2CHistoryMessage',
                name: '清空单聊本地及云端的消息'
            },
            {
                id: 'getC2CReceiveMessageOpt',
                name: '获取用户消息接受选项'
            },
            {
                id: 'clearGroupHistoryMessage',
                name: '清空群组单聊本地及云端的消息'
            },
            {
                id: 'searchLocalMessage',
                name: '搜索本地消息'
            },
            {
                id: 'findMessage',
                name: '查询指定会话中的本地消息'
            }

        ],
    },
    {
        title: '会话模块',
        id: 5,
        show: false,
        data: [
            {
                id: 'getConversationList',
                name: '获取会话列表',
            },
            {
                id: 'getConversationListByConversationIDs',
                name: '获取会话列表通过会话ID',
            },
            {
                id: 'pinConversation',
                name: '会话置顶',
            },
            {
                id: 'getTotalUnreadMessageCount',
                name: '获取会话未读总数',
            },
            {
                id: 'getConversation',
                name: '获取指定会话',
            },
            {
                id: 'deleteConversation',
                name: '删除指定会话',
            },
            {
                id: 'setConversationDraft',
                name: '设置会话草稿',
            },
        ],
    },
    {
        title: '信令模块',
        id: 6,
        show: false,
        data: [
            {
                id: 'invite',
                name: '发起邀请',
            },
            {
                id: 'inviteInGroup',
                name: '在群组中发起邀请',
            },
            {
                id: 'getSignallingInfo',
                name: '获取信令信息',
            },
            {
                id: 'addInvitedSignaling',
                name: '添加邀请信令',
            },
        ],
    },
];

const HomeScreen = (props) => {
    const [dataArr, setdataArr] = useState(DATA);

    const onRouteTo = (id: String, name: String) => {
        props.navigation.navigate('Details', { idStr: id, nameStr: name });
    };

    const Item = ({ name, id }: { name: String; id: String }) => {
        return (
            <TouchableOpacity
                onPress={() => onRouteTo(id, name)}
                style={styles.item}
            >
                <Text style={styles.itemTitle}>{`${id} ${name}`}</Text>
            </TouchableOpacity>
        );
    };

    const renderSectionHeaderHandler = (item) => {
        return (
            <TouchableOpacity
                onPress={() => sectionHandler(item)}
                style={styles.header}
            >
                <Text style={styles.headerText}>{item.section.title}</Text>
            </TouchableOpacity>
        );
    };

    const renderItemHandler = (info) => {
        return info.section.show ? (
            <Item name={info.item.name} id={info.item.id}></Item>
        ) : null;
    };

    const sectionHandler = (info) => {
        const newDataArr = dataArr.map((item) => {
            if (item.id === info.section.id) {
                item.show = !item.show;
            }
            return item;
        });

        setdataArr(newDataArr);
    };

    const renderIcon = ()=>{
        return (
            <Image source={require('../icon/icon.png')} style={styles.icon}/>
        )
    }
    return (
        <View style={styles.container}>
            <SectionList
                renderItem={renderItemHandler}
                sections={dataArr}
                renderSectionHeader={renderSectionHeaderHandler}
                keyExtractor={(item, index) => item.id + index}
            />
            <ActionButton
                buttonColor="rgba(221,160,221,0.8)"
                onPress={() => { props.navigation.navigate('CallBack'); }}
                renderIcon={renderIcon} 
            />
        </View>
    );
};

export default HomeScreen;

const styles = StyleSheet.create({
    container: {
        flex: 1,
    },
    header: {
        margin: 8,
        borderRadius: 3,
        backgroundColor: 'white',
        height: 40,
        marginBottom: 0,
    },
    headerText: {
        marginVertical: 10,
        marginHorizontal: 10,
        fontSize: 14,
        color: '#333',
        fontWeight: 'bold',
        textAlignVertical: 'center',
    },
    box: {
        width: 60,
        height: 60,
        marginVertical: 20,
    },
    appbarColor: {
        backgroundColor: '#2F80ED',
    },
    textHeader: {
        padding: 10,
    },
    title: {
        fontSize: 12,
    },
    item: {
        backgroundColor: 'white',
        padding: 10,
        marginLeft: 8,
        marginRight: 8,
        borderBottomWidth: StyleSheet.hairlineWidth,
        borderBottomColor: '#c0c0c0',
        borderRadius: 3,
    },
    itemTitle: {
        color: '#808a87',
    },
    icon:{
        width:40,
        height:40
    }
});
