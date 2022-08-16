import React, { useState } from 'react';

import { TencentImSDKPlugin } from 'react-native-tim-js';
import { Text, View, TouchableOpacity, StyleSheet} from 'react-native';
import CommonButton from '../commonComponents/CommonButton';
import mystylesheet from '../../stylesheets';
import SDKResponseView from '../sdkResponseView';
import MultiCheckBoxModalComponent from '../commonComponents/MultiCheckboxModalComponent';
import BottomModalComponent from '../commonComponents/BottomModalComponent';
const DeleteFromFriendListComponent = () => {
    const [visible, setVisible] = useState<boolean>(false)
    const [userName, setUserName] = useState<string>('未选择')
    const [userList, setUserList] = useState<any>([])
    const [deleteType, setDeleteType] = useState<number>(2)
    const [priority, setPriority] = useState<string>('双向好友')
    const getUsersHandler = (userList) => {
        setUserName('[' + userList.join(',') + ']')
        setUserList(userList)
    }
    // deleteType未处理
    const deleteFromFriendList = async () => {
        const res = await TencentImSDKPlugin.v2TIMManager.getFriendshipManager().deleteFromFriendList(userList, deleteType)
        setRes(res)
    }
    const getSelectedHandle = (selected)=>{
        setDeleteType(selected.id)
        setPriority(selected.name)
    }
    const [res, setRes] = React.useState<any>({})
    const CodeComponent = () => {
        return (
            res.code !== undefined ?
                (<SDKResponseView codeString={JSON.stringify(res, null, 2)} />) : null
        );
    }

    const PriorityComponent = () => {
        const [visible, setVisible] = useState<boolean>(false)
        return (
            <>
                <View style={mystylesheet.userInputcontainer}>
                    <View style={mystylesheet.itemContainergray}>
                        <View style={styles.prioritySelectView}>
                            <TouchableOpacity onPress={() => { setVisible(true) }}>
                                <View style={styles.deletebuttonView}>
                                    <Text style={styles.deletebuttonText}>选择删除优先级</Text>
                                </View>
                            </TouchableOpacity>
                            <Text style={styles.prioritySelectText}>{`已选：${priority}`}</Text>
                        </View>
                    </View>
                </View>
                <BottomModalComponent type='deletefriendtypeselect' visible={visible} getSelected={getSelectedHandle} getVisible={setVisible} />
            </>
        )
    }
    return (
        <View style={styles.container}>
            <View style={mystylesheet.selectContainer}>
                <TouchableOpacity onPress={() => { setVisible(true) }}>
                    <View style={styles.buttonView}>
                        <Text style={styles.buttonText}>选择好友</Text>
                    </View>
                </TouchableOpacity>
                <Text style={mystylesheet.selectedText}>{userName}</Text>
            </View>
            <MultiCheckBoxModalComponent visible={visible} getVisible={setVisible} getUsername={getUsersHandler} type={'friend'} />
            <PriorityComponent/>
            <CommonButton handler={() => deleteFromFriendList()} content={'删除好友'}></CommonButton>
            <CodeComponent></CodeComponent>
        </View>
    )
}

export default DeleteFromFriendListComponent

const styles = StyleSheet.create({
    container: {
        margin: 10,
        marginBottom: 0
    },

    buttonView: {
        backgroundColor: '#2F80ED',
        borderRadius: 3,
        width: 100,
        height: 35,
        marginLeft: 10
    },
    buttonText: {
        color: '#FFFFFF',
        fontSize: 14,
        textAlign: 'center',
        textAlignVertical: 'center',
        lineHeight: 35
    },    
    deletebuttonView: {
        backgroundColor: '#2F80ED',
        borderRadius: 3,
        width: 150,
        height: 35,
    },
    deletebuttonText: {
        color: '#FFFFFF',
        fontSize: 14,
        textAlign: 'center',
        textAlignVertical: 'center',
        lineHeight: 35
    },
    prioritySelectView: {
        flexDirection: 'row',
    },
    prioritySelectText: {
        marginTop: 5,
        fontSize: 14,
        marginLeft: 5
    },
})