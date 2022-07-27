import React, { useState} from 'react';

import { Text, View, StyleSheet } from 'react-native';
import { TouchableOpacity } from 'react-native-gesture-handler';
import { TencentImSDKPlugin } from 'react-native-tim-js';
import UserInputComponent from '../commonComponents/UserInputComponent';
import CommonButton from '../commonComponents/CommonButton';
import MultiCheckBoxModalComponent from '../commonComponents/MultiCheckboxModalComponent';
import SDKResponseView from '../sdkResponseView';
import mystylesheet from '../../stylesheets';
const CreateFriendGroupComponent = () => {
    const [visible, setVisible] = useState<boolean>(false)
    const [input,setInput]=useState<string>('')
    const [userName, setUserName] = useState<string>('未选择')
    const [userList, setUserList] = useState<any>([])
    const getUsersHandler = (userList)=>{
        setUserName('['+userList.join(',')+']')
        setUserList(userList)
    }
    
    const createFriendGroup = async () => {
        const res = await TencentImSDKPlugin.v2TIMManager.getFriendshipManager().createFriendGroup(input,userList)
        setRes(res);
    }

    const [res, setRes] = React.useState<any>({})
    const CodeComponent = () => {
        return (
            res.code !== undefined?
                (<SDKResponseView codeString={JSON.stringify(res, null, 2)} />) : null
        );
    }


    return (
        <View style={{height: '100%'}}>
            <View style={styles.container}>
                <UserInputComponent content={'分组名'} placeholdercontent={'分组名'} getContent={setInput}/>
            </View>
            <View style={styles.selectContainer}>
                <TouchableOpacity onPress={() => { setVisible(true) }}>
                    <View style={styles.buttonView}>
                        <Text style={mystylesheet.buttonText}>选择好友</Text>
                    </View>
                </TouchableOpacity>
                <Text style={mystylesheet.selectedText}>{userName}</Text>
            </View>
            <MultiCheckBoxModalComponent visible={visible} getVisible={setVisible} getUsername={getUsersHandler} type={'friend'} />
            <CommonButton handler={() => createFriendGroup()} content={'创建好友分组'}></CommonButton>
            <CodeComponent></CodeComponent>
        </View>
    )
}

export default CreateFriendGroupComponent

const styles = StyleSheet.create({
    container: {
        margin: 10
    },
    buttonView: {
        backgroundColor: '#2F80ED',
        borderRadius: 3,
        width: 100,
        height: 35,
        marginLeft: 10
    },
    selectContainer: {
        flexDirection: 'row'
    }
})

