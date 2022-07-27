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
const SendGroupTextMessageComponent = () => {
    const [visible, setVisible] = useState<boolean>(false)
    const [input, setInput] = useState<string>('')
    const [groupID, setGroupID] = useState<string>('未选择')
    const [priority, setPriority] = useState<number>(0)
    const [priorityType, setPriorityType]= useState<string>('')
    const sendGroupTextMessage = async () => {
        if(priority!==undefined){
            const groupid = groupID==='未选择'?'':groupID
            const res = await TencentImSDKPlugin.v2TIMManager.sendGroupTextMessage(groupid, input, priority);
            setRes(res);
        }

    }
    const setPriorityHandle = (selected)=>{
        setPriority(selected.id)
        setPriorityType(selected.name)
    }
    const [res, setRes] = React.useState<any>({})
    const CodeComponent = () => {
        return (
            res.code !== undefined ?
                (<SDKResponseView codeString={JSON.stringify(res, null, 2)} />) : null
        );
    }

    const PriorityComponent = () => {
        const [visible, setVisible] = useState<boolean>(false)
        return (
            <>
                <View style={mystylesheet.userInputcontainer}>
                    <View style={mystylesheet.itemContainergray}>
                        <Image style={mystylesheet.userIcon} source={require('../../icon/persongray.png')} />
                        <View style={styles.prioritySelectView}>
                            <TouchableOpacity onPress={() => { setVisible(true) }}>
                                <View style={mystylesheet.buttonView}>
                                    <Text style={mystylesheet.buttonText}>选择优先级</Text>
                                </View>
                            </TouchableOpacity>
                            <Text style={styles.prioritySelectText}>{`已选：${priorityType}`}</Text>
                        </View>
                    </View>
                </View>
                <BottomModalComponent type='priorityselect' visible={visible} getSelected={setPriorityHandle} getVisible={setVisible} />
            </>
        )
    }

    return (
        <View style={{height: '100%'}}>
            <View style={styles.container}>
                <UserInputComponent content={'发送文本'} placeholdercontent={'发送文本'} getContent={setInput} />
            </View>
            <PriorityComponent />
            <View style={styles.selectContainer}>
                <TouchableOpacity onPress={() => { setVisible(true) }}>
                    <View style={mystylesheet.buttonView}>
                        <Text style={mystylesheet.buttonText}>选择群组</Text>
                    </View>
                </TouchableOpacity>
                <Text style={mystylesheet.selectedText}>{groupID}</Text>
            </View>
            <CheckBoxModalComponent visible={visible} getVisible={setVisible} getUsername={setGroupID} type={'group'} />
            <CommonButton handler={() => sendGroupTextMessage()} content={'发送Group文本消息'}></CommonButton>
            <CodeComponent></CodeComponent>
        </View>
    )
}

export default SendGroupTextMessageComponent

const styles = StyleSheet.create({
    container: {
        margin: 10,
        marginBottom: 0
    },
    selectContainer: {
        flexDirection: 'row',
        marginTop:8,
        marginLeft: 10,
        marginRight: 10,
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