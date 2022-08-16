import React, { useState} from 'react';

import { Text, View, StyleSheet } from 'react-native';
import { TouchableOpacity } from 'react-native-gesture-handler';
import { TencentImSDKPlugin } from 'react-native-tim-js';
import mystylesheet from '../../stylesheets';
import CommonButton from '../commonComponents/CommonButton';
import CheckBoxModalComponent from '../commonComponents/CheckboxModalComponent';
import SDKResponseView from '../sdkResponseView';
const MarkGroupMessageAsReadComponent = () => {
    const [visible, setVisible] = useState<boolean>(false)
    const [groupID, setGroupID] = useState<string>('未选择')
    const markGroupMessageAsRead = async () => {
        const res = await TencentImSDKPlugin.v2TIMManager.getMessageManager().markGroupMessageAsRead(groupID)
        setRes(res);
        console.log(res)
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
            <CommonButton handler={() => markGroupMessageAsRead()} content={'标记Group会话已读'}></CommonButton>
            <CodeComponent></CodeComponent>
        </View>
    )
}

export default MarkGroupMessageAsReadComponent

const styles = StyleSheet.create({
    container: {
        margin: 10
    },
    selectContainer: {
        flexDirection: 'row',
        marginTop:10,
        marginLeft:10,
        marginRight:10
    },
})

