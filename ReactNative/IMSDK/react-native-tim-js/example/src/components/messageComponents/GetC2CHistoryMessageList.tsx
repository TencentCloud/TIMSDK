import React, { useState} from 'react';

import { Text, View, StyleSheet } from 'react-native';
import { TouchableOpacity } from 'react-native-gesture-handler';
import { TencentImSDKPlugin } from 'react-native-tim-js';
import mystylesheet from '../../stylesheets';
import CommonButton from '../commonComponents/CommonButton';
import CheckBoxModalComponent from '../commonComponents/CheckboxModalComponent';
import SDKResponseView from '../sdkResponseView';
const GetC2CHistoryMessageListComponent = () => {
    const [visible, setVisible] = useState<boolean>(false)
    const [userName, setUserName] = useState<string>('未选择')
    const [lastMessageID,setLastMessageID] = useState<string|undefined>()
    const getC2CHistoryMessageList = async () => {
        const userID = userName;
        const res = await TencentImSDKPlugin.v2TIMManager.getMessageManager().getC2CHistoryMessageList(userID,20,lastMessageID)
        setRes(res);
        if(res.data!.length>0){
            setLastMessageID(res.data![res.data!.length -1 ].msgID!.toString());
        }else{
            setLastMessageID(undefined)
        }
        
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
            <View style={styles.selectContainer}>
                <TouchableOpacity onPress={() => { setVisible(true) }}>
                    <View style={mystylesheet.buttonView}>
                        <Text style={mystylesheet.buttonText}>选择好友</Text>
                    </View>
                </TouchableOpacity>
                <Text style={mystylesheet.selectedText}>{userName}</Text>
            </View>
            <CheckBoxModalComponent visible={visible} getVisible={setVisible} getUsername={setUserName} type={'friend'}/>
            <Text>lastMessageID: {lastMessageID}</Text>
            <CommonButton handler={() => getC2CHistoryMessageList()} content={'获取C2C历史消息'}></CommonButton>
            <CodeComponent></CodeComponent>
        </View>
    )
}

export default GetC2CHistoryMessageListComponent

const styles = StyleSheet.create({
    container: {
        margin: 10
    },
    selectContainer: {
        flexDirection: 'row',
        margin:10
    },
})

