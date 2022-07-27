import { TencentImSDKPlugin } from 'react-native-tim-js';
import React, { useState } from 'react';
import CommonButton from '../commonComponents/CommonButton';
import SDKResponseView from '../sdkResponseView';
import { StyleSheet, Text, TouchableOpacity, View } from 'react-native';
import MultiCheckBoxModalComponent from '../commonComponents/MultiCheckboxModalComponent';
import UserInputComponent from '../commonComponents/UserInputComponent';
import mystylesheet from '../../stylesheets';

export const SetConversationDraft = () => {
    const [res, setRes] = useState<any>({});
    const [visible, setVisible] = useState<boolean>(false);
    const [userName, setUserName] = useState<string>('未选择');
    const [userList, setUserList] = useState<any>([]);
    const [draftText, setDraftText] = useState<string>();
    const getUsersHandler = (userList) => {
        setUserName('[' + userList.join(',') + ']');
        setUserList(userList);
    };

    const CodeComponent = () => {
        return res.code !== undefined ? (
            <SDKResponseView codeString={JSON.stringify(res, null, 2)} />
        ) : null;
    };

    const getConversationList = async () => {
        if (userList.length == 0) {
            return;
        }
        const res = await TencentImSDKPlugin.v2TIMManager
            .getConversationManager()
            .setConversationDraft(userList[0], draftText);
        setRes(res);
        TencentImSDKPlugin.v2TIMManager
            .getConversationManager()
            .addConversationListener({
                onConversationChanged: (conversationList) => {
                    console.log('conversationList', conversationList);
                },
                onNewConversation: (conversationList) => {
                    console.log('conversationList', conversationList);
                },
            });
    };
    return (
        <View style={{height: '100%'}}>
            <View style={styles.container}>
                <View style={styles.selectContainer}>
                    <TouchableOpacity
                        onPress={() => {
                            setVisible(true);
                        }}
                    >
                        <View style={styles.buttonView}>
                            <Text style={styles.buttonText}>选择会话</Text>
                        </View>
                    </TouchableOpacity>
                    <Text style={styles.selectedText}>{userName}</Text>
                </View>
                <MultiCheckBoxModalComponent
                    visible={visible}
                    getVisible={setVisible}
                    getUsername={getUsersHandler}
                    type={'conversation'}
                />
                <View style={mystylesheet.userInputcontainer}>
                    <UserInputComponent
                        content="请输入草稿"
                        placeholdercontent="请输入草稿"
                        getContent={setDraftText}
                    />
                </View>
            </View>
            <CommonButton
                handler={getConversationList}
                content={'设置会话草稿'}
            ></CommonButton>
            <CodeComponent></CodeComponent>
        </View>
    );
};

const styles = StyleSheet.create({
    container: {
        margin: 10,
        marginBottom: 0,
    },
    buttonView: {
        backgroundColor: '#2F80ED',
        borderRadius: 3,
        width: 100,
        height: 35,
        marginLeft: 10,
    },
    buttonText: {
        color: '#FFFFFF',
        fontSize: 14,
        textAlign: 'center',
        textAlignVertical: 'center',
        lineHeight: 35,
    },
    selectContainer: {
        flexDirection: 'row',
        alignItems: 'center',
        width: '100%',
        overflow: 'hidden',
    },
    selectedText: {
        marginLeft: 10,
        fontSize: 14,
        textAlignVertical: 'center',
        lineHeight: 35,
    },
});
