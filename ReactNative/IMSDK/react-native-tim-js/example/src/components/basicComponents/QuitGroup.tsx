import React, { useState } from 'react';

import { Text,View,TouchableOpacity,StyleSheet} from 'react-native';
import { TencentImSDKPlugin } from 'react-native-tim-js';
import CommonButton from '../commonComponents/CommonButton';
import SDKResponseView from '../sdkResponseView';
import CheckBoxModalComponent from '../commonComponents/CheckboxModalComponent';
import mystylesheet from '../../stylesheets';
const QuitGroupComponent = () => {

    const [res, setRes] = React.useState<any>({});
    const [visible, setVisible] = useState<boolean>(false)
    const [groupName, setGroupName] = useState<string>('未选择')

    const quitGroup = async()=>{
        const res = await TencentImSDKPlugin.v2TIMManager.quitGroup(groupName)
        setRes(res)
    }

    const CodeComponent = () => {
        return res.code !== undefined ? (
            <SDKResponseView codeString={JSON.stringify(res, null, 2)} />
        ) : null;
    };
    return (
        <View style={{height: '100%'}}>
            <View style={styles.container}>
                <View style={styles.selectContainer}>
                    <TouchableOpacity onPress={() => { setVisible(true) }}>
                        <View style={mystylesheet.buttonView}>
                            <Text style={mystylesheet.buttonText}>选择群组</Text>
                        </View>
                    </TouchableOpacity>
                    <Text style={styles.selectedText}>{groupName}</Text>
                </View>
                <CheckBoxModalComponent visible={visible} getVisible={setVisible} getUsername={setGroupName} type={'group'}/>               
            </View>
            <CommonButton handler={() => quitGroup()} content={'退出群组'}></CommonButton>
            <CodeComponent></CodeComponent>
        </View>
    );
};

export default QuitGroupComponent;

const styles = StyleSheet.create({
    container: {
        margin: 10,
        marginBottom: 0
    },
    selectContainer: {
        flexDirection: 'row',
        alignItems:'center',
        width:'100%',
        overflow:'hidden'
    },
    selectedText: {
        marginLeft: 10,
        fontSize: 14,
        textAlignVertical: 'center',
        lineHeight: 35
    }
})