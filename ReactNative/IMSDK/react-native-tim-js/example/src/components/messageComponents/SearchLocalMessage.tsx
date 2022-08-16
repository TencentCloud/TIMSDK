import React, { useState } from 'react';
import { View, StyleSheet, Text, TouchableOpacity } from 'react-native';
import { TencentImSDKPlugin } from 'react-native-tim-js';
import CommonButton from '../commonComponents/CommonButton';
import SDKResponseView from '../sdkResponseView';
import UserInputComponent from '../commonComponents/UserInputComponent';
import CheckBoxModalComponent from '../commonComponents/CheckboxModalComponent';
import mystylesheet from '../../stylesheets';
const SearchLocalMessageComponent = () => {
    const searchLocalMessage = async () => {
        const keywordList = keywords.split(' ');
        const res = await TencentImSDKPlugin.v2TIMManager.getMessageManager().searchLocalMessages({
            conversationID: conversationID,
            keywordList: keywordList,
            type: 0,
        })
        setRes(res)
    }

    const [res, setRes] = useState<any>({})
    const [keywords, setKeywords] = useState<string>('')
    const [conversationID, setConversationID] = useState<string>('未选择')
    const CodeComponent = () => {
        return (
            res.code !== undefined ?
                (<SDKResponseView codeString={JSON.stringify(res, null, 2)} />) : null
        );
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
            <View style={mystylesheet.userInputcontainer}>
                <UserInputComponent content='搜索关键词列表，最多支持5个' placeholdercontent='关键词(example只有设置了一个关键词)' getContent={setKeywords} />
            </View>
            <ConversationSelectComponent />
            <CommonButton handler={() => searchLocalMessage()} content={'查询本地消息（不指定不返回messageList）'}></CommonButton>
            <CodeComponent></CodeComponent>
        </View>
    )
}

export default SearchLocalMessageComponent

const styles = StyleSheet.create({
    friendgroupview: {
        marginTop: 10
    },
    selectContainer: {
        flexDirection: 'row',
        marginLeft: 10,
        marginRight: 10
    },
})