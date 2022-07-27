import React, { useState } from 'react';

import { Text, View, StyleSheet } from 'react-native';
import { TouchableOpacity } from 'react-native-gesture-handler';
import { TencentImSDKPlugin } from 'react-native-tim-js';
import CommonButton from '../commonComponents/CommonButton';
import MultiCheckBoxModalComponent from '../commonComponents/MultiCheckboxModalComponent';
import SDKResponseView from '../sdkResponseView';
import CheckBoxModalComponent from '../commonComponents/CheckboxModalComponent';
import mystylesheet from '../../stylesheets';
const AddFriendToFriendGroupComponent = () => {
    const [groupName, setGroupName] = useState<string>('未选择')
    const [userName, setUserName] = useState<string>('未选择')
    const [userList, setUserList] = useState<any>([])
    const getUsersHandler = (userList) => {
        setUserName('[' + userList.join(',') + ']')
        setUserList(userList)
    }

    const addFriendsToFriendGroup = async () => {
        const res = await TencentImSDKPlugin.v2TIMManager.getFriendshipManager().addFriendsToFriendGroup(groupName, userList)
        setRes(res);
    }

    const [res, setRes] = React.useState<any>({})
    const CodeComponent = () => {
        return (
            res.code !== undefined ?
                (<SDKResponseView codeString={JSON.stringify(res, null, 2)} />) : null
        );
    }

    const FriendSelectComponent = () => {
        const [visible, setVisible] = useState<boolean>(false)
        return (
            <>
                <View style={styles.selectContainer}>
                    <TouchableOpacity onPress={() => { setVisible(true) }}>
                        <View style={mystylesheet.buttonView}>
                            <Text style={mystylesheet.buttonText}>选择好友</Text>
                        </View>
                    </TouchableOpacity>
                    <Text style={mystylesheet.selectedText}>{userName}</Text>
                </View>
                <MultiCheckBoxModalComponent visible={visible} getVisible={setVisible} getUsername={getUsersHandler} type={'friend'} />
            </>
        )

    }

    const GroupSelectComponent = () => {
        const [visible, setVisible] = useState<boolean>(false)
        return (
            <>
                <View style={styles.selectContainer}>
                    <TouchableOpacity onPress={() => { setVisible(true) }}>
                        <View style={mystylesheet.buttonView}>
                            <Text style={mystylesheet.buttonText}>选择分组</Text>
                        </View>
                    </TouchableOpacity>
                    <Text style={mystylesheet.selectedText}>{groupName}</Text>
                </View>
                <CheckBoxModalComponent visible={visible} getVisible={setVisible} getUsername={setGroupName} type={'selectgroup'} />
            </>
        )

    }
    return (
        <View style={{height: '100%'}}>
            <FriendSelectComponent />
            <GroupSelectComponent />
            <CommonButton handler={() => addFriendsToFriendGroup()} content={'添加好友到分组'}></CommonButton>
            <CodeComponent></CodeComponent>
        </View>
    )
}

export default AddFriendToFriendGroupComponent

const styles = StyleSheet.create({
    selectContainer: {
        flexDirection: 'row',
        marginTop: 10,
        marginLeft: 10,
        marginRight: 10
    }
})

