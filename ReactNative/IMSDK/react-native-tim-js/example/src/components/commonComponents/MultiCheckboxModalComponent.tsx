import React, { useState, useEffect } from 'react';
import { StyleSheet, View, Modal, TouchableOpacity, FlatList } from 'react-native';
import { Text } from 'react-native-paper';
import MultiCheckboxComponent from './MultiCheckboxComponent';
import { TencentImSDKPlugin, V2TimConversation } from 'react-native-tim-js';

const MultiCheckBoxModalComponent = (props) => {
    const { visible, getVisible, getUsername, type, groupID, conversationID } = props
    const usersSet = new Set()
    const [res, setRes] = useState<any>({})
    const [content, setContent] = useState('')
    useEffect(() => {
        switch (type) {
            case 'friend':
                setContent('好友选择')
                getFriendList()
                break;
            case 'group':
                setContent('群组选择')
                getGroupList()
                break;
            case 'black':
                setContent('黑名单好友选择')
                getBlackList()
                break;
            case 'selectgroup':
                setContent('分组选择')
                getFriendGroupList()
                break;
            case 'member':
                setContent('选择群成员')
                getMemberList()
                break;
            case 'message':
                setContent('选择消息')
                getMessageList()
                break;
            case 'conversation':
                setContent('选择会话')
                getConversationList()
                break;
            default:
                break;
        }

    }, [])
    const getFriendList = async () => {
        const res = await TencentImSDKPlugin.v2TIMManager.getFriendshipManager().getFriendList()
        setRes(res)
    }
    const getGroupList = async () => {
        const res = await TencentImSDKPlugin.v2TIMManager.getGroupManager().getJoinedGroupList()
        setRes(res)
    }
    const getBlackList = async () => {
        const res = await TencentImSDKPlugin.v2TIMManager.getFriendshipManager().getBlackList()
        setRes(res)
    }
    const getFriendGroupList = async () => {
        const res = await TencentImSDKPlugin.v2TIMManager.getFriendshipManager().getFriendGroups()
        setRes(res)
    }
    const getMemberList = async () => {
        const res = await TencentImSDKPlugin.v2TIMManager.getGroupManager().getGroupMemberList(groupID, 0, '0')
        setRes(res)
    }
    const getMessageList = async () => {
        const res = await TencentImSDKPlugin.v2TIMManager.getConversationManager().getConversationListByConversaionIds([conversationID])
        setRes(res)

    }
    const closeHandler = (val: boolean) => {
        getVisible(val)
    }

    const confirmHandler = (val: boolean) => {
        const arr = [...usersSet]
        getUsername(arr)
        getVisible(val)
    }

    const getConversationList = async () => {
        const res = await TencentImSDKPlugin.v2TIMManager.getConversationManager().getConversationList(20, '');
        setRes(res);
    }

    const getUsersHandler = (isChecked, selectedname) => {
        if (isChecked) {
            if (!usersSet.has(selectedname)) {
                usersSet.add(selectedname)
            }
        } else {
            if (usersSet.has(selectedname)) {
                usersSet.delete(selectedname)
            }
        }

    }

    const renderItemfriend = ({ item }) => {
        return (
            <MultiCheckboxComponent text={item.userID} getSelectedUser={getUsersHandler} type={'friend'} />
        )
    }

    const renderItemgroup = ({ item }) => {
        return (
            <MultiCheckboxComponent text={item.groupID} getSelectedUser={getUsersHandler} type={'group'} />
        )
    }

    const renderItemblack = ({ item }) => {
        return (
            <MultiCheckboxComponent text={item.userID} getSelectedUser={getUsersHandler} type={'black'} />
        )
    }
    const renderItemselectgroup = ({ item }) => {
        return (
            <MultiCheckboxComponent text={item.name} getSelectedUser={getUsersHandler} type={'selectgroup'} />
        )
    }
    const renderItemselectmember = ({ item }) => {
        return (
            <MultiCheckboxComponent text={item.userID} getSelectedUser={getUsersHandler} type={'member'} />
        )
    }
    const renderItemselectmessage = ({ item }) => {
        return (
            item.lastMessage?(
                <MultiCheckboxComponent text={item.lastMessage.msgID} getSelectedUser={getUsersHandler} type={'message'} />
            ):null         
        )
    }

    const renderConversationItem = ({item}: {item: V2TimConversation})=>{
        return (
            <MultiCheckboxComponent text={item.conversationID} getSelectedUser={getUsersHandler} type={'conversation'} />
        )
    }

    return (
        <Modal
            visible={visible}
            transparent={true}
        >
            <View style={styles.container}>
                <View style={styles.showContainer}>
                    <Text style={styles.title}>{content}（多选）</Text>
                    {(() => {
                        switch (type) {
                            case 'friend':
                                return (
                                    <View style={styles.listContainer}>
                                        <FlatList
                                            data={res.data}
                                            renderItem={renderItemfriend}
                                            keyExtractor={(item, index) => item.userID + index}
                                        />
                                    </View>
                                );
                            case 'group':
                                return (
                                    <View style={styles.listContainer}>
                                        <FlatList
                                            data={res.data}
                                            renderItem={renderItemgroup}
                                            keyExtractor={(item, index) => item.groupID + index}
                                        />
                                    </View>
                                );
                            case 'black':
                                return (
                                    <View style={styles.listContainer}>
                                        <FlatList
                                            data={res.data}
                                            renderItem={renderItemblack}
                                            keyExtractor={(item, index) => item.userID + index}
                                        />
                                    </View>
                                );
                            case 'selectgroup':
                                return (
                                    <View style={styles.listContainer}>
                                        <FlatList
                                            data={res.data}
                                            renderItem={renderItemselectgroup}
                                            keyExtractor={(item, index) => item.name + index}
                                        />
                                    </View>
                                );
                            case 'member':
                                return (
                                    <View style={styles.listContainer}>
                                        <FlatList
                                            data={res.data?.memberInfoList}
                                            renderItem={renderItemselectmember}
                                            keyExtractor={(item, index) => item.userID + index}
                                        />
                                    </View>
                                );
                            case 'message':
                                return (
                                    <View style={styles.listContainer}>
                                        <FlatList
                                            data={res.data}
                                            renderItem={renderItemselectmessage}
                                            keyExtractor={(item, index) => item.lastMessage?item.lastMessage.msgID + index:index}
                                        />
                                    </View>
                                );
                            case 'conversation':
                                return (
                                    <View style={styles.listContainer}>
                                        <FlatList
                                            data={res.data?.conversationList}
                                            renderItem={renderConversationItem}
                                            keyExtractor={(item, index) => item.userID + index.toString()}
                                        />
                                    </View> 
                                )
                            default:
                                return <></>;
                        }
                    })()}

                    <View style={styles.buttonContainer}>
                        <TouchableOpacity onPress={() => confirmHandler(false)}>
                            <View style={styles.buttonView}>
                                <Text style={styles.buttonText}>确认</Text>
                            </View>
                        </TouchableOpacity>
                        <TouchableOpacity onPress={() => { closeHandler(false) }}>
                            <View style={styles.buttonView}>
                                <Text style={styles.buttonText}>取消</Text>
                            </View>
                        </TouchableOpacity>
                    </View>
                </View>
            </View>
        </Modal>
    )
}
export default MultiCheckBoxModalComponent

const styles = StyleSheet.create({
    container: {
        flex: 1,
        justifyContent: 'center',
        alignItems: 'center',
        backgroundColor: 'rgba(0,0,0,0.3)',
    },
    showContainer: {
        width: '80%',
        backgroundColor: 'white',
        borderRadius: 5
    },
    title: {
        fontSize: 20,
        marginTop: 20,
        marginLeft: 18,
        marginBottom: 10,
    },
    listContainer: {
        marginLeft: 15,
        overflow: 'scroll',
        maxHeight: 500
    },
    buttonContainer: {
        flexDirection: 'row',
        justifyContent: 'flex-end',
        marginBottom: 0
    },
    buttonView: {
        backgroundColor: '#2F80ED',
        borderRadius: 3,
        height: 35,
        width: 65,
        marginRight: 8,
        marginBottom: 10
    },
    buttonText: {
        color: '#FFFFFF',
        fontSize: 15,
        textAlign: 'center',
        textAlignVertical: 'center',
        lineHeight: 35
    }
})