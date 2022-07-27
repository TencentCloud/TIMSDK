import React, { useState } from 'react';
import { View, StyleSheet, TouchableOpacity, Text } from 'react-native';
import { TencentImSDKPlugin } from 'react-native-tim-js';
import CommonButton from '../commonComponents/CommonButton';
import SDKResponseView from '../sdkResponseView';
import MultiCheckBoxModalComponent from '../commonComponents/MultiCheckboxModalComponent';
import CheckBoxModalComponent from '../commonComponents/CheckboxModalComponent';
import mystylesheet from '../../stylesheets';
const DeleteMessageComponent = () => {
    const [res, setRes] = useState<any>({});
    const [conversationID, setConversationID] = useState<string>('未选择')
    const [messages, setMessages] = useState<string>('[]')
    const [messageList, setMessageList] = useState([])

    const deleteMessage = async () => {
        const res = await TencentImSDKPlugin.v2TIMManager.getMessageManager().deleteMessages(messageList)
        setRes(res)
    };
    const setMessagesHandle = (messagelist) => {
        setMessages('[' + messagelist.join(',') + ']')
        setMessageList(messagelist)
    }


    const CodeComponent = () => {
        return res.code !== undefined ? (
            <SDKResponseView codeString={JSON.stringify(res, null, 2)} />
        ) : null;
    };

    const MessageSelectComponent = () => {
        const [visible, setVisible] = useState<boolean>(false)
        return (
            <View style={styles.friendgroupview}>
                <View style={styles.selectContainer}>
                    <TouchableOpacity onPress={() => setVisible(true)}>
                        <View style={mystylesheet.buttonView}>
                            <Text style={mystylesheet.buttonText}>选择消息</Text>
                        </View>
                    </TouchableOpacity>
                    <Text style={mystylesheet.selectedText}>{messages}</Text>
                </View>
                <MultiCheckBoxModalComponent visible={visible} getVisible={setVisible} getUsername={setMessagesHandle} type={'message'} conversationID={conversationID} />
            </View>

        )
    }

    const ConversationSelectComponent = () => {
        const [visible, setVisible] = useState<boolean>(false)
        return (
            <View style={styles.friendgroupview}>
                <View style={styles.selectContainer}>
                    <TouchableOpacity onPress={() => setVisible(true)}>
                        <View style={mystylesheet.buttonView}>
                            <Text style={mystylesheet.buttonText}>选择会话</Text>
                        </View>
                    </TouchableOpacity>
                    <Text style={mystylesheet.selectedText}>{conversationID}</Text>
                </View>
                <CheckBoxModalComponent visible={visible} getVisible={setVisible} getUsername={setConversationID} type={'conversation'} />
            </View>

        )
    }




    return (
        <View style={{height: '100%'}}>
            <ConversationSelectComponent />
            <MessageSelectComponent />
            <CommonButton
                handler={() => { deleteMessage() }}
                content={'删除信息'}
            ></CommonButton>
            <CodeComponent></CodeComponent>
        </View>
    );
};

export default DeleteMessageComponent;
const styles = StyleSheet.create({
    selectContainer: {
        flexDirection: 'row',
        marginLeft: 10,
        marginRight: 10
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
})