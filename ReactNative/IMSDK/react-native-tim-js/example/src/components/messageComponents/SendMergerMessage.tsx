import React, { useState } from 'react';
import { View, StyleSheet, TouchableOpacity, Text, Switch } from 'react-native';
import { TencentImSDKPlugin } from 'react-native-tim-js';
import CommonButton from '../commonComponents/CommonButton';
import SDKResponseView from '../sdkResponseView';
import CheckBoxModalComponent from '../commonComponents/CheckboxModalComponent';
import BottomModalComponent from '../commonComponents/BottomModalComponent';
import mystylesheet from '../../stylesheets';
import MultiCheckBoxModalComponent from '../commonComponents/MultiCheckboxModalComponent';

const SendMergerMessageComponent = () => {
    const [res, setRes] = useState<any>({});
    const [userName, setUserName] = useState<string>('未选择')
    const [groupName, setGroupName] = useState<string>('未选择')
    const [priority, setPriority] = useState<string>('V2TIM_PRIORITY_DEFAULT')
    const [priorityEnum,setPriorityEnum] = useState<number>(0)
    const [isonlineUserOnly, setIsonlineUserOnly] = useState(false);
    const [isExcludedFromUnreadCount, setIsExcludedFromUnreadCount] = useState(false);
    const receiveOnlineUserstoggle = () => setIsonlineUserOnly(previousState => !previousState);
    const unreadCounttoggle = () => setIsExcludedFromUnreadCount(previousState => !previousState);

    const [conversationID, setConversationID] = useState<string>('未选择')
    const [messages, setMessages] = useState<string>('[]')
    const [messageList,setMessageList] = useState<any>([])
    const sendMergerMessage = async () => {
        const messageRes = await TencentImSDKPlugin.v2TIMManager.getMessageManager().createMergerMessage(messageList,'xx与xx的会话',messageList,"低版本不支持会会收到文本消息")
        console.log(messageRes)
        const id = messageRes.data?.id
        const receiver = userName === '未选择' ? '' : userName
        const groupID = groupName === '未选择' ? '' : groupName
        if (id !== undefined) {
            const res = await TencentImSDKPlugin.v2TIMManager.getMessageManager().sendMessage({
                id:id.toString(),
                receiver: receiver,
                groupID: groupID,
                onlineUserOnly: isonlineUserOnly,
                isExcludedFromUnreadCount: isExcludedFromUnreadCount,
                priority:priorityEnum
            })
            console.log(res)
            setRes(res)
        }
    };

    const getMessagesHandler = (messagelist)=>{
        setMessages('['+messagelist.join(',')+']')
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
                    <TouchableOpacity onPress={()=>setVisible(true)}>
                        <View style={mystylesheet.buttonView}>
                            <Text style={mystylesheet.buttonText}>选择消息</Text>
                        </View>
                    </TouchableOpacity>
                    <Text style={mystylesheet.selectedText}>{messages}</Text>
                </View>
                <MultiCheckBoxModalComponent visible={visible} getVisible={setVisible} getUsername={getMessagesHandler} type={'message'} conversationID={conversationID}/>
            </View>
            
        )
    }

    const ConversationSelectComponent = () => {
        const [visible, setVisible] = useState<boolean>(false)
        return (
            <View style={styles.friendgroupview}>
                <View style={styles.selectContainer}>
                    <TouchableOpacity onPress={()=>setVisible(true)}>
                        <View style={mystylesheet.buttonView}>
                            <Text style={mystylesheet.buttonText}>选择会话</Text>
                        </View>
                    </TouchableOpacity>
                    <Text style={mystylesheet.selectedText}>{conversationID}</Text>
                </View>
                <CheckBoxModalComponent visible={visible} getVisible={setVisible} getUsername={setConversationID} type={'conversation'}/>
            </View>
            
        )
    }

    const FriendComponent = () => {
        const [visible, setVisible] = useState<boolean>(false)

        return (
            <View style={styles.friendgroupview}>
                <View style={styles.selectContainer}>
                    <TouchableOpacity onPress={() => { setVisible(true) }}>
                        <View style={mystylesheet.buttonView}>
                            <Text style={mystylesheet.buttonText}>选择好友</Text>
                        </View>
                    </TouchableOpacity>
                    <Text style={mystylesheet.selectedText}>{userName}</Text>
                </View>
                <CheckBoxModalComponent visible={visible} getVisible={setVisible} getUsername={setUserName} type={'friend'} />
            </View>
        )

    };

    const GroupComponent = () => {
        const [visible, setVisible] = useState<boolean>(false)

        return (
            <View style={styles.friendgroupview}>
                <View style={styles.selectContainer}>
                    <TouchableOpacity onPress={() => { setVisible(true) }}>
                        <View style={mystylesheet.buttonView}>
                            <Text style={mystylesheet.buttonText}>选择群组</Text>
                        </View>
                    </TouchableOpacity>
                    <Text style={mystylesheet.selectedText}>{groupName}</Text>
                </View>
                <CheckBoxModalComponent visible={visible} getVisible={setVisible} getUsername={setGroupName} type={'group'} />
            </View>

        )
    };

    const PriorityComponent = () => {
        const [visible, setVisible] = useState(false)
        const getSelectedHandler = (selected) => {
            setPriority(selected.name)
            setPriorityEnum(selected.id)
        }
        return (
            <>
                <View style={mystylesheet.userInputcontainer}>
                    <View style={mystylesheet.itemContainergray}>
                        <View style={styles.selectView}>
                            <TouchableOpacity onPress={() => { setVisible(true) }}>
                                <View style={mystylesheet.buttonView}>
                                    <Text style={mystylesheet.buttonText}>选择优先级</Text>
                                </View>
                            </TouchableOpacity>
                            <Text style={styles.selectText}>{`已选：${priority}`}</Text>
                        </View>
                    </View>
                </View>
                <BottomModalComponent type='priorityselect' visible={visible} getSelected={getSelectedHandler} getVisible={setVisible} />
            </>
        )
    };

    return (
        <View style={{height: '100%'}}>
            <ConversationSelectComponent />
            <MessageSelectComponent/>
            <FriendComponent />
            <GroupComponent />
            <PriorityComponent />
            <View style={mystylesheet.switchcontainer}>
                <Text style={mystylesheet.switchtext}>是否仅在线用户接受到消息</Text>
                <Switch
                    trackColor={{ false: "#c0c0c0", true: "#81b0ff" }}
                    thumbColor={isonlineUserOnly ? "#2F80ED" : "#f4f3f4"}
                    ios_backgroundColor="#3e3e3e"
                    onValueChange={receiveOnlineUserstoggle}
                    value={isonlineUserOnly}
                />
            </View>
            <View style={mystylesheet.switchcontainer}>
                <Text style={mystylesheet.switchtext}>发送消息是否不计入未读数</Text>
                <Switch
                    trackColor={{ false: "#c0c0c0", true: "#81b0ff" }}
                    thumbColor={isExcludedFromUnreadCount ? "#2F80ED" : "#f4f3f4"}
                    ios_backgroundColor="#3e3e3e"
                    onValueChange={unreadCounttoggle}
                    value={isExcludedFromUnreadCount}
                />
            </View>
            <CommonButton
                handler={() => { sendMergerMessage() }}
                content={'合并消息'}
            ></CommonButton>
            <CodeComponent></CodeComponent>
        </View>
    );
};

export default SendMergerMessageComponent;
const styles = StyleSheet.create({
    selectContainer: {
        flexDirection: 'row'
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
        marginLeft: 10,
        marginRight: 10,
        marginTop: 10
    },
})