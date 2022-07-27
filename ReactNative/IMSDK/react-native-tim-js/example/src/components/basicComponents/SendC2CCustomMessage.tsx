import React, { useState } from 'react';

import { Text, View, StyleSheet } from 'react-native';
import { TouchableOpacity } from 'react-native-gesture-handler';
import { TencentImSDKPlugin } from 'react-native-tim-js';
import UserInputComponent from '../commonComponents/UserInputComponent';
import CommonButton from '../commonComponents/CommonButton';
import CheckBoxModalComponent from '../commonComponents/CheckboxModalComponent';
import SDKResponseView from '../sdkResponseView';
const SendC2CCustomMessageComponent = () => {
    const [visible, setVisible] = useState<boolean>(false)
    const [userName, setUserName] = useState<string>('未选择')
    const [input,setInput] = useState<string>('')

    const sendC2CCustomMessage = async () => {
        const customMessage = input;
        const userID = userName;
        const res = await TencentImSDKPlugin.v2TIMManager.sendC2CCustomMessage(userID, customMessage);
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
                <UserInputComponent content={'自定义数据'} placeholdercontent={'自定义数据'} getContent={setInput}/>
            </View>
            <View style={styles.selectContainer}>
                <TouchableOpacity onPress={() => { setVisible(true) }}>
                    <View style={styles.buttonView}>
                        <Text style={styles.buttonText}>选择好友</Text>
                    </View>
                </TouchableOpacity>
                <Text style={styles.selectedText}>{userName}</Text>
            </View>
            <CheckBoxModalComponent visible={visible} getVisible={setVisible} getUsername={setUserName} type={'friend'}/>
            <CommonButton handler={() => sendC2CCustomMessage()} content={'发送C2C自定义消息'}></CommonButton>
            <CodeComponent></CodeComponent>
        </View>
    )
}

export default SendC2CCustomMessageComponent

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
    buttonText: {
        color: '#FFFFFF',
        fontSize: 14,
        textAlign: 'center',
        textAlignVertical: 'center',
        lineHeight: 35
    },
    selectContainer: {
        flexDirection: 'row'
    },
    selectedText: {
        marginLeft: 10,
        fontSize: 14,
        textAlignVertical: 'center',
        lineHeight: 35
    }
})