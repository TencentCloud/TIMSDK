import React,{useState} from 'react';

import {View,StyleSheet} from 'react-native';
import { TencentImSDKPlugin } from 'react-native-tim-js';
import CommonButton from '../commonComponents/CommonButton';
import UserInputComponent from '../commonComponents/UserInputComponent';
import SDKResponseView from '../sdkResponseView';
const RenameFriendGroupComponent = () => {
    // addType未处理
    const renameFriendGroup = async () => {
        const res = await TencentImSDKPlugin.v2TIMManager.getFriendshipManager().renameFriendGroup(oldGroup,newGroup)
        setRes(res)
    }
    const [oldGroup,setOldGroup] = useState<string>('')
    const [newGroup,setNewGroup] = useState<string>('')

    const [res, setRes] = useState<any>({})

    const CodeComponent = () => {
        return (
            res.code !== undefined ?
                (<SDKResponseView codeString={JSON.stringify(res, null, 2)}/>) : null
        );
    }

    return (
        <View style={{height: '100%'}}>
            <View style={styles.userInputcontainer}>
                <UserInputComponent content='旧分组名' placeholdercontent='旧分组名' getContent={setOldGroup}/>
            </View>
            <View style={styles.userInputcontainer}>
                <UserInputComponent content='新分组名' placeholdercontent='新分组名' getContent={setNewGroup}/>
            </View>
            <CommonButton handler={() => renameFriendGroup()} content={'重命名好友分组'}></CommonButton>
            <CodeComponent></CodeComponent>
        </View>
    )
}

export default RenameFriendGroupComponent

const styles = StyleSheet.create({
    userInputcontainer: {
        margin: 10,
        marginBottom: 0,
        marginTop: 1,
        justifyContent: 'center'
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