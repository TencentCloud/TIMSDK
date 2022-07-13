import React, { useState } from 'react';

import { Text, View, StyleSheet, Image, TouchableOpacity } from 'react-native';
import { TencentImSDKPlugin } from 'react-native-tim-js';
import CommonButton from '../commonComponents/CommonButton';
import UserInputComponent from '../commonComponents/UserInputComponent';
import mystylesheet from '../../stylesheets';
import BottomModalComponent from '../commonComponents/BottomModalComponent';
import SDKResponseView from '../sdkResponseView';
const CreateGroupComponent = () => {
    const [groupType, setgroupType] = useState<String>('')
    const [visible, setVisible] = useState<boolean>(false)
    const [groupID,setGroupID] = useState<String>('')
    const [groupName,setGroupName] = useState<String>('')

    const createGroup = async () => {
        const groupname = groupName
        const groupid = groupID
        const grouptype = groupType
        const res = await TencentImSDKPlugin.v2TIMManager.createGroup(
            groupname,
            grouptype,
            groupid,
            
        );
        setRes(res)
        console.log(res)
    };

    const [res, setRes] = React.useState<any>({})
    const CodeComponent = () => {
        return (
            res.code !== undefined ?
                (<SDKResponseView codeString={JSON.stringify(res)}/>) : null
        );
    }
    return (
        <View>
            <View style={styles.userInputcontainer}>
                <UserInputComponent content='群ID' placeholdercontent={'选填（如填，则自定义群ID）'} getContent={setGroupID}/>
            </View>
            <View style={styles.userInputcontainer}>
                <UserInputComponent content='群名称' placeholdercontent={'群名称'} getContent={setGroupName}/>
            </View>
            <View style={styles.userInputcontainer}>
                <View style={mystylesheet.itemContainergray}>
                    <Image style={mystylesheet.userIcon} source={require('../../icon/persongray.png')} />
                    <View style={styles.groupSelectView}>
                        <TouchableOpacity onPress={() => {setVisible(true)}}>
                            <View style={styles.buttonView}>
                                <Text style={styles.buttonText}>选择群类型</Text>
                            </View>
                        </TouchableOpacity>
                        <Text style={styles.groupSelectText}>{`已选：${groupType}`}</Text>
                    </View>
                </View>
            </View>
            <CommonButton handler={() => createGroup()} content={'创建群'}></CommonButton>
            <CodeComponent></CodeComponent>
            <BottomModalComponent visible={visible} getSelected={setgroupType} getVisible={setVisible} type='groupselect'/>
        </View>
    )
}

export default CreateGroupComponent

const styles = StyleSheet.create({
    userInputcontainer: {
        margin: 10,
        marginBottom: 0,
        marginTop: 1,
        justifyContent: 'center'
    },
    buttonView: {
        backgroundColor: '#2F80ED',
        borderRadius: 3,
        width: 100,
        height: 35,
        marginTop: -5,
        marginRight: 10
    },
    buttonText: {
        color: '#FFFFFF',
        fontSize: 14,
        textAlign: 'center',
        textAlignVertical: 'center',
        lineHeight: 35
    },
    groupSelectView: {
        flexDirection: 'row',
    },
    groupSelectText: {
        marginTop: 5,
        fontSize: 14
    }
})