import React, { useState} from 'react';

import { Text, View, StyleSheet } from 'react-native';
import { TouchableOpacity } from 'react-native-gesture-handler';
import { TencentImSDKPlugin } from 'react-native-tim-js';
import UserInputComponent from '../commonComponents/UserInputComponent';
import CommonButton from '../commonComponents/CommonButton';
import CheckBoxModalComponent from '../commonComponents/CheckboxModalComponent';
import SDKResponseView from '../sdkResponseView';
import mystylesheet from '../../stylesheets';
const SendC2CTextMessageComponent = () => {
    const [visible, setVisible] = useState<boolean>(false)
    const [input,setInput]=useState<string>('')
    const [userName, setUserName] = useState<string>('未选择')

    const sendC2CTextMessage = async () => {
        const text = input;
        const userID = userName;
        const res = await TencentImSDKPlugin.v2TIMManager.sendC2CTextMessage(userID, text);
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
                <UserInputComponent content={'发送文本'} placeholdercontent={'发送文本'} getContent={setInput}/>
            </View>
            <View style={styles.selectContainer}>
                <TouchableOpacity onPress={() => { setVisible(true) }}>
                    <View style={mystylesheet.buttonView}>
                        <Text style={mystylesheet.buttonText}>选择好友</Text>
                    </View>
                </TouchableOpacity>
                <Text style={mystylesheet.selectedText}>{userName}</Text>
            </View>
            <CheckBoxModalComponent visible={visible} getVisible={setVisible} getUsername={setUserName} type={'friend'}/>
            <CommonButton handler={() => sendC2CTextMessage()} content={'发送C2C文本消息'}></CommonButton>
            <CodeComponent></CodeComponent>
        </View>
    )
}

export default SendC2CTextMessageComponent

const styles = StyleSheet.create({
    container: {
        margin: 10
    },
    selectContainer: {
        flexDirection: 'row',
        marginLeft:10,
        marginRight:10
    }
})

