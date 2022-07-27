import React, { useState} from 'react';

import { Text,View,TouchableOpacity,StyleSheet} from 'react-native';
import { TencentImSDKPlugin } from 'react-native-tim-js';
import CommonButton from '../commonComponents/CommonButton';
import SDKResponseView from '../sdkResponseView';
import CheckBoxModalComponent from '../commonComponents/CheckboxModalComponent';
import mystylesheet from '../../stylesheets';
const DismissGroupComponent = () => {

    const [res, setRes] = React.useState<any>({});
    const [visible, setVisible] = useState<boolean>(false)
    const [groupName, setGroupName] = useState<string>('未选择')

    const dismissGroup = async()=>{
        const res = await TencentImSDKPlugin.v2TIMManager.dismissGroup(groupName)
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
                <View style={mystylesheet.selectContainer}>
                    <TouchableOpacity onPress={() => { setVisible(true) }}>
                        <View style={mystylesheet.buttonView}>
                            <Text style={mystylesheet.buttonText}>选择群组</Text>
                        </View>
                    </TouchableOpacity>
                    <Text style={mystylesheet.selectedText}>{groupName}</Text>
                </View>
                <CheckBoxModalComponent visible={visible} getVisible={setVisible} getUsername={setGroupName} type={'group'}/>  
            </View>
            <CommonButton handler={() => dismissGroup()} content={'解散群组'}></CommonButton>
            <CodeComponent></CodeComponent>
        </View>
    );
};

export default DismissGroupComponent;

const styles = StyleSheet.create({
    container: {
        margin: 10,
        marginBottom: 0
    },
})