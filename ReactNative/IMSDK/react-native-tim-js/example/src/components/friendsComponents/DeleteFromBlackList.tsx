import React, { useState } from 'react';

import { Text, View, TouchableOpacity, StyleSheet } from 'react-native';
import { TencentImSDKPlugin } from 'react-native-tim-js';
import CommonButton from '../commonComponents/CommonButton';
import MultiCheckBoxModalComponent from '../commonComponents/MultiCheckboxModalComponent';
import SDKResponseView from '../sdkResponseView';
import mystylesheet from '../../stylesheets';
const DeleteFromBlackListComponent = () => {
    const [visible, setVisible] = useState<boolean>(false)
    const [userName, setUserName] = useState<string>('未选择')
    const [userList, setUserList] = useState<any>([])
    const deleteFromBlackList = async () => {
        const res = await TencentImSDKPlugin.v2TIMManager.getFriendshipManager().deleteFromBlackList(userList)
        setRes(res)
    }
    const getUsersHandler = (userList) => {
        setUserName('[' + userList.join(',') + ']')
        setUserList(userList)
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
            <View style={styles.container}>
                <View style={styles.selectContainer}>
                    <TouchableOpacity onPress={() => { setVisible(true) }}>
                        <View style={mystylesheet.buttonView}>
                            <Text style={mystylesheet.buttonText}>选择好友</Text>
                        </View>
                    </TouchableOpacity>
                    <Text style={mystylesheet.selectedText}>{userName}</Text>
                </View>
                <MultiCheckBoxModalComponent visible={visible} getVisible={setVisible} getUsername={getUsersHandler} type={'black'} />
            </View>
            <CommonButton handler={() => deleteFromBlackList()} content={'从黑名单中移除'}></CommonButton>
            <CodeComponent></CodeComponent>
        </View>
    )
}

export default DeleteFromBlackListComponent

const styles = StyleSheet.create({
    container: {
        margin: 10,
        marginBottom: 0
    },
    selectContainer: {
        flexDirection: 'row',
        alignItems: 'center',
        width: '100%',
        overflow: 'hidden'
    }
})