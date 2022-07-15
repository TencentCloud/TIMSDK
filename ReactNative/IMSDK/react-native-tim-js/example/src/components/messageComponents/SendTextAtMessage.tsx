import React,{useState} from 'react';
import { Text, View, StyleSheet, TouchableOpacity,Switch} from 'react-native';
import { TencentImSDKPlugin } from 'react-native-tim-js';
import CommonButton from '../commonComponents/CommonButton';
import SDKResponseView from '../sdkResponseView';
import CheckBoxModalComponent from '../commonComponents/CheckboxModalComponent';
import MultiCheckBoxModalComponent from '../commonComponents/MultiCheckboxModalComponent';
import mystylesheet from '../../stylesheets';
import BottomModalComponent from '../commonComponents/BottomModalComponent';
const SendTextAtMessageComponent = () => {
    const [groupID, setGroupID] = useState<string>('未选择')
    const [res, setRes] = useState<any>({});
    const [membersName,setMembersName] = useState('[]');
    const [membersList,setMembersList] = useState([]);
    const [priority, setPriority] = useState<string>('');
    const [isonlineUserOnly, setIsonlineUserOnly] = useState(false);
    const [isExcludedFromUnreadCount, setIsExcludedFromUnreadCount] = useState(false);
    const receiveOnlineUserstoggle = () => setIsonlineUserOnly(previousState => !previousState);
    const unreadCounttoggle = () => setIsExcludedFromUnreadCount(previousState => !previousState);
    const sendTextAtMessage = async()=>{
        const messageRes = await TencentImSDKPlugin.v2TIMManager.getMessageManager().createTextAtMessage('',membersList)
        const id = messageRes.data?.id
        if (id !== undefined) {
            const res = await TencentImSDKPlugin.v2TIMManager.getMessageManager().sendMessage({
                id: id.toString(),
                receiver: '',
                groupID: groupID,
                onlineUserOnly: isonlineUserOnly,
                isExcludedFromUnreadCount: isExcludedFromUnreadCount,
            })
            setRes(res)
        }
    }
    const getMembersHandler = (memberslist)=>{
        setMembersName('['+memberslist.join(',')+']')
        setMembersList(memberslist)
    }
    const CodeComponent = () => {
        return res.code !== undefined ? (
            <SDKResponseView codeString={JSON.stringify(res)} />
        ) : null;
    };

    const GroupSelectComponent = () => {
        const [visible, setVisible] = useState<boolean>(false)
        return (
            <View style={styles.container}>
                <View style={styles.selectContainer}>
                    <TouchableOpacity onPress={() => { setVisible(true) }}>
                        <View style={styles.buttonView}>
                            <Text style={styles.buttonText}>选择群组</Text>
                        </View>
                    </TouchableOpacity>
                    <Text style={styles.selectedText}>{groupID}</Text>
                </View>
                <CheckBoxModalComponent visible={visible} getVisible={setVisible} getUsername={setGroupID} type={'group'} />
            </View>
        )
    };
    const MembersSelectComponent = ()=>{
        const [visible, setVisible] = useState<boolean>(false)
        return (
            <View style={styles.container}>
                <View style={styles.selectContainer}>
                    <TouchableOpacity onPress={() => { setVisible(true) }}>
                        <View style={styles.buttonView}>
                            <Text style={styles.buttonText}>选择群成员</Text>
                        </View>
                    </TouchableOpacity>
                    <Text style={styles.selectedText}>{membersName}</Text>
                </View>
                <MultiCheckBoxModalComponent visible={visible} getVisible={setVisible} getUsername={getMembersHandler} type={'member'} groupID={groupID}/>
            </View>
        )
    }
    const PriorityComponent = () => {
        const [visible, setVisible] = useState(false)
        const getSelectedHandler = (selected) => {
            setPriority(selected.name)
        }
        return (
            <>
                <View style={styles.userInputcontainer}>
                    <View style={mystylesheet.itemContainergray}>
                        <View style={styles.selectView}>
                            <TouchableOpacity onPress={() => { setVisible(true) }}>
                                <View style={styles.buttonView}>
                                    <Text style={styles.buttonText}>选择优先级</Text>
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
        <>
            <GroupSelectComponent/>
            <MembersSelectComponent/>
            <PriorityComponent/>
            <View style={styles.switchcontainer}>
                <Text style={styles.switchtext}>是否仅在线用户接受到消息</Text>
                <Switch
                    trackColor={{ false: "#c0c0c0", true: "#81b0ff" }}
                    thumbColor={isonlineUserOnly ? "#2F80ED" : "#f4f3f4"}
                    ios_backgroundColor="#3e3e3e"
                    onValueChange={receiveOnlineUserstoggle}
                    value={isonlineUserOnly}
                />
            </View>
            <View style={styles.switchcontainer}>
                <Text style={styles.switchtext}>发送消息是否不计入未读数</Text>
                <Switch
                    trackColor={{ false: "#c0c0c0", true: "#81b0ff" }}
                    thumbColor={isExcludedFromUnreadCount ? "#2F80ED" : "#f4f3f4"}
                    ios_backgroundColor="#3e3e3e"
                    onValueChange={unreadCounttoggle}
                    value={isExcludedFromUnreadCount}
                />
            </View>
            <CommonButton
                handler={() => sendTextAtMessage()}
                content={'发送文本At消息'}
            ></CommonButton>
            <CodeComponent></CodeComponent>
        </>
    );
};

export default SendTextAtMessageComponent;

const styles = StyleSheet.create({
    container: {
        marginLeft: 10,
    },
    userInputcontainer: {
        marginLeft: 10,
        marginRight: 10,
        justifyContent: 'center'
    },
    buttonView: {
        backgroundColor: '#2F80ED',
        borderRadius: 3,
        width: 100,
        height: 35,
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
    selectContainer: {
        flexDirection: 'row',
        marginTop: 10
    },
    selectedText: {
        marginLeft: 10,
        fontSize: 14,
        textAlignVertical: 'center',
        lineHeight: 35
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