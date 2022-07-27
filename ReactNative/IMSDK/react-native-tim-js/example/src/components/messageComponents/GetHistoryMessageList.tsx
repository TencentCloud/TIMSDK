import React, { useState } from 'react';

import { Text, View, StyleSheet } from 'react-native';
import { TouchableOpacity } from 'react-native-gesture-handler';
import { TencentImSDKPlugin } from 'react-native-tim-js';
import mystylesheet from '../../stylesheets';
import CommonButton from '../commonComponents/CommonButton';
import CheckBoxModalComponent from '../commonComponents/CheckboxModalComponent';
import SDKResponseView from '../sdkResponseView';
import BottomModalComponent from '../commonComponents/BottomModalComponent';
const GetHistoryMessageListComponent = () => {

    const [groupName, setGroupName] = useState<string>('未选择')
    const [userName,setUserName] = useState<string>('未选择')
    const [typeName,setTypeName] = useState<string>('V2TIM_GET_CLOUD_NEWER_MSG')
    const [typeEnum,setTypeEnum] = useState<number>(2)
    const [lastMessageID,setLastMessageID] = useState<string|undefined>()
    const [lastMessageSeq,setLastMessageSeq] = useState<number|undefined>()
    const getHistoryMessageList = async () => {
        const receiver = userName==='未选择'?undefined:userName
        const groupID = groupName==='未选择'?undefined:groupName
        console.log(receiver,groupID)
        if((receiver && !groupID) || (!receiver && groupID)){
            const res = await TencentImSDKPlugin.v2TIMManager.getMessageManager().getHistoryMessageList(20,typeEnum,receiver,groupID,lastMessageSeq,lastMessageID)
            setRes(res);
            if(res.data!.length>0){
                setLastMessageID(res.data![res.data!.length -1 ].msgID!.toString());
                setLastMessageSeq(parseInt(res.data![res.data!.length -1 ].seq!.toString()))
            }else{
                setLastMessageID(undefined)
            }
            setRes(res);
        }
    }

    const [res, setRes] = React.useState<any>({})

    const getSelectedHandle = (selected)=>{
        setTypeEnum(selected.id)
        setTypeName(selected.name)
    }
    const CodeComponent = () => {
        return (
            res.code !== undefined ?
                (<SDKResponseView codeString={JSON.stringify(res, null, 2)} />) : null
        );
    }

    const GroupComponent = () => {
        const [visible, setVisible] = useState<boolean>(false)
        return (
            <>
                <View style={styles.selectContainer}>
                    <TouchableOpacity onPress={() => { setVisible(true) }}>
                        <View style={mystylesheet.buttonView}>
                            <Text style={mystylesheet.buttonText}>选择群组</Text>
                        </View>
                    </TouchableOpacity>
                    <Text style={mystylesheet.selectedText}>{groupName}</Text>
                </View>
                <CheckBoxModalComponent visible={visible} getVisible={setVisible} getUsername={setGroupName} type={'group'} />
            </>
        )
    }

    const FriendComponent = () => {
        const [visible, setVisible] = useState<boolean>(false)
        return (
            <>
                <View style={styles.selectContainer}>
                    <TouchableOpacity onPress={() => { setVisible(true) }}>
                        <View style={mystylesheet.buttonView}>
                            <Text style={mystylesheet.buttonText}>选择好友</Text>
                        </View>
                    </TouchableOpacity>
                    <Text style={mystylesheet.selectedText}>{userName}</Text>
                </View>
                <CheckBoxModalComponent visible={visible} getVisible={setVisible} getUsername={setUserName} type={'friend'} />
            </>
        )
    }

    const TypeSelectComponent=()=>{
        const [visible, setVisible] = useState<boolean>(false)
        return (
            <>
                <View style={styles.userInputcontainer}>
                    <View style={mystylesheet.itemContainergray}>
                        <View style={styles.prioritySelectView}>
                            <TouchableOpacity onPress={() => { setVisible(true) }}>
                                <View style={styles.deletebuttonView}>
                                    <Text style={styles.deletebuttonText}>选择type</Text>
                                </View>
                            </TouchableOpacity>
                            <Text style={styles.prioritySelectText}>{`已选：${typeName}`}</Text>
                        </View>
                    </View>
                </View>
                <BottomModalComponent type='historytypeselect' visible={visible} getSelected={getSelectedHandle} getVisible={setVisible} />
            </>
        )
    }

    return (
        <View style={{height: '100%'}}>
            <FriendComponent/>
            <GroupComponent/>
            <TypeSelectComponent/>
            <Text>lastMessageID: {lastMessageID}</Text>
            <CommonButton handler={() => getHistoryMessageList()} content={'获取历史消息高级接口'}></CommonButton>
            <CodeComponent></CodeComponent>
        </View>
    )
}

export default GetHistoryMessageListComponent

const styles = StyleSheet.create({
    container: {
        margin: 10
    },
    selectContainer: {
        flexDirection: 'row',
        marginTop: 10,
        marginLeft:10,
        marginRight:10
    },
    userInputcontainer: {
        margin: 10,
        marginBottom: 0,
        marginTop: 0,
        justifyContent: 'center'
    },
    prioritySelectView: {
        flexDirection: 'row',
    },
    deletebuttonView: {
        backgroundColor: '#2F80ED',
        borderRadius: 3,
        width: 100,
        height: 35,
    },
    deletebuttonText: {
        color: '#FFFFFF',
        fontSize: 14,
        textAlign: 'center',
        textAlignVertical: 'center',
        lineHeight: 35
    },
    prioritySelectText: {
        marginTop: 5,
        fontSize: 14,
        marginLeft: 5
    },
})

