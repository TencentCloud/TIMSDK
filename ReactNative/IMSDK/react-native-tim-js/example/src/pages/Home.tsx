import React, { useState } from 'react';

import {
    StyleSheet,
    View,
    Text,
    SectionList,
    TouchableOpacity,
} from 'react-native';
// import { TouchableOpacity } from 'react-native-gesture-handler';

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
                id:'deleteFriendsFromFriendGroup',
                name: '从分组中删除好友'
            },
            {
                id:'searchFriends',
                name:'搜索好友'
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

    return (
        <View style={styles.container}>
            <SectionList
                renderItem={renderItemHandler}
                sections={dataArr}
                renderSectionHeader={renderSectionHeaderHandler}
                keyExtractor={(item, index) => item.id + index}
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
});
