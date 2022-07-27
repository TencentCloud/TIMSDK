import React, { useState} from 'react';

import { Text, View, StyleSheet } from 'react-native';
import { TouchableOpacity } from 'react-native-gesture-handler';
import { TencentImSDKPlugin } from 'react-native-tim-js';
import mystylesheet from '../../stylesheets';
import CommonButton from '../commonComponents/CommonButton';
import CheckBoxModalComponent from '../commonComponents/CheckboxModalComponent';
import SDKResponseView from '../sdkResponseView';
const GetGroupHistoryMessageListComponent = () => {
    const [visible, setVisible] = useState<boolean>(false)
    const [groupID, setGroupID] = useState<string>('未选择')
    const [lastMessageID,setLastMessageID] = useState<string|undefined>()
    const getGroupHistoryMessageList = async () => {
        const res = await TencentImSDKPlugin.v2TIMManager.getMessageManager().getGroupHistoryMessageList(groupID,20,lastMessageID)
        setRes(res);
        if(res.data!.length>0){
            setLastMessageID(res.data![res.data!.length -1 ].msgID!.toString());
        }else{
            setLastMessageID(undefined)
        }
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
            <View style={styles.selectContainer}>
                <TouchableOpacity onPress={() => { setVisible(true) }}>
                    <View style={mystylesheet.buttonView}>
                        <Text style={mystylesheet.buttonText}>选择群组</Text>
                    </View>
                </TouchableOpacity>
                <Text style={mystylesheet.selectedText}>{groupID}</Text>
            </View>
            <CheckBoxModalComponent visible={visible} getVisible={setVisible} getUsername={setGroupID} type={'group'}/>
            <Text>lastMessageID: {lastMessageID}</Text>
            <CommonButton handler={() => getGroupHistoryMessageList()} content={'获取Group历史消息'}></CommonButton>
            <CodeComponent></CodeComponent>
        </View>
    )
}

export default GetGroupHistoryMessageListComponent

const styles = StyleSheet.create({
    container: {
        margin: 10
    },
    selectContainer: {
        flexDirection: 'row',
        margin:10
    },
})

