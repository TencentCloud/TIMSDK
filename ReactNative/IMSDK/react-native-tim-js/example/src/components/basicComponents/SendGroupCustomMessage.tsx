import React, { useState } from 'react';

import { Text, View, StyleSheet, Image } from 'react-native';
import { TouchableOpacity } from 'react-native-gesture-handler';
import { TencentImSDKPlugin } from 'react-native-tim-js';
import UserInputComponent from '../commonComponents/UserInputComponent';
import CommonButton from '../commonComponents/CommonButton';
import CheckBoxModalComponent from '../commonComponents/CheckboxModalComponent';
import SDKResponseView from '../sdkResponseView';
import mystylesheet from '../../stylesheets';
import BottomModalComponent from '../commonComponents/BottomModalComponent';
const SendGroupCustomMessageComponent = () => {
    const [visible, setVisible] = useState<boolean>(false)
    const [input, setInput] = useState<string>('')
    const [groupID, setGroupID] = useState<string>('未选择')
    const [priority, setPriority] = useState<number>(0)
    const sendGroupCustomMessage = async () => {
        if(priority!==undefined){
            const groupid = groupID==='未选择'?'':groupID
            const res = await TencentImSDKPlugin.v2TIMManager.sendGroupCustomMessage(groupid, input, priority);
            setRes(res);
        } 
    }

    const [res, setRes] = React.useState<any>({})
    const CodeComponent = () => {
        return (
            res.code !== undefined ?
                (<SDKResponseView codeString={JSON.stringify(res)} />) : null
        );
    }

    const PriorityComponent = () => {
        const [visible, setVisible] = useState<boolean>(false)
        return (
            <>
                <View style={styles.userInputcontainer}>
                    <View style={mystylesheet.itemContainergray}>
                        <Image style={mystylesheet.userIcon} source={require('../../icon/persongray.png')} />
                        <View style={styles.prioritySelectView}>
                            <TouchableOpacity onPress={() => { setVisible(true) }}>
                                <View style={styles.buttonView}>
                                    <Text style={styles.buttonText}>选择优先级</Text>
                                </View>
                            </TouchableOpacity>
                            <Text style={styles.prioritySelectText}>{`已选：${priority}`}</Text>
                        </View>
                    </View>
                </View>
                <BottomModalComponent type='prioritynumberselect' visible={visible} getSelected={setPriority} getVisible={setVisible} />
            </>
        )
    }

    return (
        <>
            <View style={styles.container}>
                <UserInputComponent content={'发送自定义数据'} placeholdercontent={'发送自定义数据'} getContent={setInput} />
            </View>
            <PriorityComponent />
            <View style={styles.selectContainer}>
                <TouchableOpacity onPress={() => { setVisible(true) }}>
                    <View style={styles.buttonView}>
                        <Text style={styles.buttonText}>选择群组</Text>
                    </View>
                </TouchableOpacity>
                <Text style={styles.selectedText}>{groupID}</Text>
            </View>
            <CheckBoxModalComponent visible={visible} getVisible={setVisible} getUsername={setGroupID} type={'group'} />
            <CommonButton handler={() => sendGroupCustomMessage()} content={'发送Group自定义消息'}></CommonButton>
            <CodeComponent></CodeComponent>
        </>
    )
}

export default SendGroupCustomMessageComponent

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
        marginTop:8
    },
    selectedText: {
        marginLeft: 10,
        fontSize: 14,
        textAlignVertical: 'center',
        lineHeight: 35
    },
    userInputcontainer: {
        margin: 10,
        marginBottom: 0,
        marginTop: 1,
        justifyContent: 'center'
    },
    prioritySelectView: {
        flexDirection: 'row',
    },
    prioritySelectText: {
        marginTop: 5,
        fontSize: 14,
        marginLeft: 5
    }
})