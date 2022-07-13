import React,{useState} from 'react';

import { Text ,View,StyleSheet,Image,TouchableOpacity} from 'react-native';
import { TencentImSDKPlugin } from 'react-native-tim-js';
import CommonButton from '../commonComponents/CommonButton';
import UserInputComponent from '../commonComponents/UserInputComponent';
import mystylesheet from '../../stylesheets';
import BottomModalComponent from '../commonComponents/BottomModalComponent';
import SDKResponseView from '../sdkResponseView';
const AddFriendComponent = () => {
    // addType未处理
    const addFriend = async () => {
        const res = await TencentImSDKPlugin.v2TIMManager.getFriendshipManager().addFriend(
            friendID,
            priorityEnum,
            friendRemark,
            friendGrouping,
            briefly
        )
        setRes(res)
    }
    const [friendID,setFriendID] = useState<string>('')
    const [friendRemark,setFriendRemark] = useState<string>('')
    const [friendGrouping,setFriendGrouping] = useState<string>('')
    const [briefly,setBriefly] = useState<string>('')
    const [priority, setPriority] = useState<string>('双向好友')
    const [res, setRes] = useState<any>({})
    let priorityEnum = 0
    const CodeComponent = () => {
        return (
            res.code !== undefined ?
                (<SDKResponseView codeString={JSON.stringify(res)}/>) : null
        );
    }
    const getSelectedHandle = (seleted)=>{
        setPriority(seleted.name)
        priorityEnum=seleted.id
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
                <BottomModalComponent type='friendpriorityselect' visible={visible} getSelected={getSelectedHandle} getVisible={setVisible} />
            </>
        )
    }
    return (
        <>
            <View style={styles.userInputcontainer}>
                <UserInputComponent content='被添加好友ID' placeholdercontent='被添加好友ID' getContent={setFriendID}/>
            </View>
            <View style={styles.userInputcontainer}>
                <UserInputComponent content='好友备注' placeholdercontent='好友备注' getContent={setFriendRemark}/>
            </View>
            <View style={styles.userInputcontainer}> 
                <UserInputComponent content='好友分组' placeholdercontent='好友分组' getContent={setFriendGrouping}/>
            </View>
            <View style={styles.userInputcontainer}>
                <UserInputComponent content='添加简述' placeholdercontent='添加简述' getContent={setBriefly}/>
            </View>
            <PriorityComponent />
            <CommonButton handler={() => addFriend()} content={'添加好友'}></CommonButton>
            <CodeComponent></CodeComponent>
        </>
    )
}

export default AddFriendComponent
const styles = StyleSheet.create({
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
})