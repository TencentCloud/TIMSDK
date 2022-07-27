import React, { useState } from 'react';

import { Text, View, StyleSheet } from 'react-native';
import { TouchableOpacity } from 'react-native-gesture-handler';
import { TencentImSDKPlugin } from 'react-native-tim-js';
import CommonButton from '../commonComponents/CommonButton';
import MultiCheckBoxModalComponent from '../commonComponents/MultiCheckboxModalComponent';
import SDKResponseView from '../sdkResponseView';
import mystylesheet from '../../stylesheets';
const DeleteFriendGroupComponent = () => {
    const [visible, setVisible] = useState<boolean>(false)
    const [userName, setUserName] = useState<string>('未选择')
    const [userList, setUserList] = useState<any>([])
    const getUsersHandler = (userList) => {
        setUserName('[' + userList.join(',') + ']')
        setUserList(userList)
    }

    const deleteFriendGroup = async () => {
        const res = await TencentImSDKPlugin.v2TIMManager.getFriendshipManager().deleteFriendGroup(userList)
        setRes(res);
    }

    const [res, setRes] = React.useState<any>({})
    const CodeComponent = () => {
        return (
            res.code !== undefined ?
                (<SDKResponseView codeString={JSON.stringify(res, null, 2)} />) : null
        );
    }
    return (
        <View style={{height: '100%'}}>
            <View style={styles.selectContainer}>
                <TouchableOpacity onPress={() => { setVisible(true) }}>
                    <View style={styles.buttonView}>
                        <Text style={mystylesheet.buttonText}>选择分组</Text>
                    </View>
                </TouchableOpacity>
                <Text style={mystylesheet.selectedText}>{userName}</Text>
            </View>
            <MultiCheckBoxModalComponent visible={visible} getVisible={setVisible} getUsername={getUsersHandler} type={'selectgroup'} />
            <CommonButton handler={() => deleteFriendGroup()} content={'删除好友分组'}></CommonButton>
            <CodeComponent></CodeComponent>
        </View>
    )
}

export default DeleteFriendGroupComponent

const styles = StyleSheet.create({
    buttonView: {
        backgroundColor: '#2F80ED',
        borderRadius: 3,
        width: 100,
        height: 35,
        marginLeft: 10
    },
    selectContainer: {
        flexDirection: 'row',
        marginTop:10
    }
})

