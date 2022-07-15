import React, { useState } from 'react';
import { View, StyleSheet, Text, TouchableOpacity } from 'react-native';
import { TencentImSDKPlugin } from 'react-native-tim-js';
import CommonButton from '../commonComponents/CommonButton';
import SDKResponseView from '../sdkResponseView';
import UserInputComponent from '../commonComponents/UserInputComponent';
import CheckBoxModalComponent from '../commonComponents/CheckboxModalComponent';
const SearchLocalMessageComponent = () => {
    const searchLocalMessage = async () => {
        const keywordList = keywords.split(' ');
        const res = await TencentImSDKPlugin.v2TIMManager.getMessageManager().searchLocalMessages({
            conversationID:conversationID,
            keywordList:keywordList,
            type:0,
        })
        setRes(res)
    }

    const [res, setRes] = useState<any>({})
    const [keywords, setKeywords] = useState<string>('')
    const [conversationID, setConversationID] = useState<string>('未选择')
    const CodeComponent = () => {
        return (
            res.code !== undefined ?
                (<SDKResponseView codeString={JSON.stringify(res)} />) : null
        );
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
            <View style={styles.userInputcontainer}>
                <UserInputComponent content='搜索关键词列表，最多支持5个' placeholdercontent='关键词(example只有设置了一个关键词)' getContent={setKeywords} />
            </View>
            <ConversationSelectComponent/>
            <CommonButton handler={() => searchLocalMessage()} content={'查询本地消息（不指定不返回messageList）'}></CommonButton>
            <CodeComponent></CodeComponent>
        </>
    )
}

export default SearchLocalMessageComponent

const styles = StyleSheet.create({
    userInputcontainer: {
        margin: 10,
        marginBottom: 0,
        marginTop: 1,
        justifyContent: 'center'
    },
    friendgroupview: {
        marginTop: 10
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
})