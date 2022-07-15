import React, { useState } from 'react';
import { View, StyleSheet, TouchableOpacity, Text } from 'react-native';
import { TencentImSDKPlugin } from 'react-native-tim-js';
import CommonButton from '../commonComponents/CommonButton';
import SDKResponseView from '../sdkResponseView';
import CheckBoxModalComponent from '../commonComponents/CheckboxModalComponent';
import MultiCheckBoxModalComponent from '../commonComponents/MultiCheckboxModalComponent';
const FindMessageComponent = () => {
    const [res, setRes] = useState<any>({});
    const [conversationID, setConversationID] = useState<string>('未选择')
    const [messages, setMessages] = useState<string>('[]')
    const [messageList, setMessageList] = useState([])

    const findMessage = async () => {
        const res = await TencentImSDKPlugin.v2TIMManager.getMessageManager().findMessages(messageList)
        setRes(res)
    };

    const setMessagesHandle = (messagelist)=>{
        setMessages('['+messagelist.join(',')+']')
        setMessageList(messagelist)
    }

    const CodeComponent = () => {
        return res.code !== undefined ? (
            <SDKResponseView codeString={JSON.stringify(res)} />
        ) : null;
    };

    const MessageSelectComponent = () => {
        const [visible, setVisible] = useState<boolean>(false)
        return (
            <View style={styles.friendgroupview}>
                <View style={styles.selectContainer}>
                    <TouchableOpacity onPress={()=>setVisible(true)}>
                        <View style={styles.buttonView}>
                            <Text style={styles.buttonText}>选择消息</Text>
                        </View>
                    </TouchableOpacity>
                    <Text style={styles.selectedText}>{messages}</Text>
                </View>
                <MultiCheckBoxModalComponent visible={visible} getVisible={setVisible} getUsername={setMessagesHandle} type={'message'} conversationID={conversationID}/>
            </View>
            
        )
    }

    const ConversationSelectComponent = () => {
        const [visible, setVisible] = useState<boolean>(false)
        return (
            <View style={styles.friendgroupview}>
                <View style={styles.selectContainer}>
                    <TouchableOpacity onPress={()=>setVisible(true)}>
                        <View style={styles.buttonView}>
                            <Text style={styles.buttonText}>选择会话</Text>
                        </View>
                    </TouchableOpacity>
                    <Text style={styles.selectedText}>{conversationID}</Text>
                </View>
                <CheckBoxModalComponent visible={visible} getVisible={setVisible} getUsername={setConversationID} type={'conversation'}/>
            </View>
            
        )
    }




    return (
        <>
            <ConversationSelectComponent />
            <MessageSelectComponent/>
            <CommonButton
                handler={() => { findMessage() }}
                content={'查询指定会话中的本地消息'}
            ></CommonButton>
            <CodeComponent></CodeComponent>
        </>
    );
};

export default FindMessageComponent;
const styles = StyleSheet.create({
    userInputcontainer: {
        marginLeft: 10,
        marginRight: 10,
        justifyContent: 'center'
    },
    selectContainer: {
        flexDirection: 'row'
    },
    selectedText: {
        marginLeft: 10,
        fontSize: 14,
        textAlignVertical: 'center',
        lineHeight: 35
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
    selectView: {
        flexDirection: 'row',
    },
    selectText: {
        marginLeft: 10,
        lineHeight: 35,
        fontSize: 14,
    },
    friendgroupview: {
        marginTop: 10
    },
    switchcontainer: {
        flexDirection: 'row',
        margin: 10
    },
    switchtext: {
        lineHeight: 35,
        marginRight: 8
    }
})