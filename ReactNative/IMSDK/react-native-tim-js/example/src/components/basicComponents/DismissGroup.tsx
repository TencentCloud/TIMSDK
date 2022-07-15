import React, { useState} from 'react';

import { Text,View,TouchableOpacity,StyleSheet} from 'react-native';
import { TencentImSDKPlugin } from 'react-native-tim-js';
import CommonButton from '../commonComponents/CommonButton';
import SDKResponseView from '../sdkResponseView';
import CheckBoxModalComponent from '../commonComponents/CheckboxModalComponent';
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
            <SDKResponseView codeString={JSON.stringify(res)} />
        ) : null;
    };
    return (
        <>
            <View style={styles.container}>
                <View style={styles.selectContainer}>
                    <TouchableOpacity onPress={() => { setVisible(true) }}>
                        <View style={styles.buttonView}>
                            <Text style={styles.buttonText}>选择群组</Text>
                        </View>
                    </TouchableOpacity>
                    <Text style={styles.selectedText}>{groupName}</Text>
                </View>
                <CheckBoxModalComponent visible={visible} getVisible={setVisible} getUsername={setGroupName} type={'group'}/>
                <CommonButton handler={() => dismissGroup()} content={'解散群组'}></CommonButton>
            </View>
            <CodeComponent></CodeComponent>
        </>
    );
};

export default DismissGroupComponent;

const styles = StyleSheet.create({
    container: {
        margin: 10,
        marginBottom: 0
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