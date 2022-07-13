import React, { useState } from 'react';

import { Text,View,TouchableOpacity,StyleSheet} from 'react-native';
import { TencentImSDKPlugin } from 'react-native-tim-js';
import CommonButton from '../commonComponents/CommonButton';
import SDKResponseView from '../sdkResponseView';
import MultiCheckBoxModalComponent from '../commonComponents/MultiCheckboxModalComponent';

const GetGroupsInfoComponent = () => {

    const [res, setRes] = React.useState<any>({});
    const [visible, setVisible] = useState<boolean>(false)
    const [groupName, setGroupName] = useState<string>('未选择')
    const [groupList, setGroupList] = useState<any>([])

    const getGroupsInfo = async() =>{
        console.log(groupList)
        const res = await TencentImSDKPlugin.v2TIMManager.getGroupManager().getGroupsInfo(groupList)
        setRes(res)
    }
    const getGroupsHandler = (groupList)=>{
        setGroupName('['+groupList.join(',')+']')
        setGroupList(groupList)
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
                <MultiCheckBoxModalComponent visible={visible} getVisible={setVisible} getUsername={getGroupsHandler} type={'group'}/>
                <CommonButton handler={() => getGroupsInfo()} content={'获取群组信息'}></CommonButton>
                <CodeComponent></CodeComponent>
            </View>
        </>
    );
};

export default GetGroupsInfoComponent;

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