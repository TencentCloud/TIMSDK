import React, { useState} from 'react';

import { Text, View, StyleSheet } from 'react-native';
import { TouchableOpacity } from 'react-native-gesture-handler';
import { TencentImSDKPlugin } from 'react-native-tim-js';

import CommonButton from '../commonComponents/CommonButton';
import CheckBoxModalComponent from '../commonComponents/CheckboxModalComponent';
import SDKResponseView from '../sdkResponseView';
const ClearC2CHistoryMessageComponent = () => {
    const [visible, setVisible] = useState<boolean>(false)
    const [userName, setUserName] = useState<string>('未选择')
    const clearC2CHistoryMessage = async () => {
        const userID = userName;
        const res = await TencentImSDKPlugin.v2TIMManager.getMessageManager().clearC2CHistoryMessage(userID)
        setRes(res);
        console.log(res)
    }

    const [res, setRes] = React.useState<any>({})
    const CodeComponent = () => {
        return (
            res.code !== undefined?
                (<SDKResponseView codeString={JSON.stringify(res)} />) : null
        );
    }


    return (
        <>
            <View style={styles.selectContainer}>
                <TouchableOpacity onPress={() => { setVisible(true) }}>
                    <View style={styles.buttonView}>
                        <Text style={styles.buttonText}>选择好友</Text>
                    </View>
                </TouchableOpacity>
                <Text style={styles.selectedText}>{userName}</Text>
            </View>
            <CheckBoxModalComponent visible={visible} getVisible={setVisible} getUsername={setUserName} type={'friend'}/>
            <CommonButton handler={() => clearC2CHistoryMessage()} content={'清空单聊本地及云端的消息（不删除会话）'}></CommonButton>
            <CodeComponent></CodeComponent>
        </>
    )
}

export default ClearC2CHistoryMessageComponent

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
        flexDirection: 'row',
        marginTop:10,
    },
    selectedText: {
        marginLeft: 10,
        fontSize: 14,
        textAlignVertical: 'center',
        lineHeight: 35
    }
})

