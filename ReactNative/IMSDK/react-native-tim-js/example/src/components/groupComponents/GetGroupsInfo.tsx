import React, { useState } from 'react';

import { Text, View, TouchableOpacity, StyleSheet } from 'react-native';
import { TencentImSDKPlugin } from 'react-native-tim-js';
import CommonButton from '../commonComponents/CommonButton';
import SDKResponseView from '../sdkResponseView';
import MultiCheckBoxModalComponent from '../commonComponents/MultiCheckboxModalComponent';
import mystylesheet from '../../stylesheets';
const GetGroupsInfoComponent = () => {

    const [res, setRes] = React.useState<any>({});
    const [visible, setVisible] = useState<boolean>(false)
    const [groupName, setGroupName] = useState<string>('未选择')
    const [groupList, setGroupList] = useState<any>([])

    const getGroupsInfo = async () => {
        console.log(groupList)
        const res = await TencentImSDKPlugin.v2TIMManager.getGroupManager().getGroupsInfo(groupList)
        setRes(res)
    }
    const getGroupsHandler = (groupList) => {
        setGroupName('[' + groupList.join(',') + ']')
        setGroupList(groupList)
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
                <MultiCheckBoxModalComponent visible={visible} getVisible={setVisible} getUsername={getGroupsHandler} type={'group'} />
            </View>
            <CommonButton handler={() => getGroupsInfo()} content={'获取群组信息'}></CommonButton>
            <CodeComponent></CodeComponent>
        </View>
    );
};

export default GetGroupsInfoComponent;

const styles = StyleSheet.create({
    container: {
        margin: 10,
        marginBottom: 0
    },
})