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
    const [priorityEnum,setPriorityEnum]= useState<number>(2)
    const CodeComponent = () => {
        return (
            res.code !== undefined ?
                (<SDKResponseView codeString={JSON.stringify(res, null, 2)}/>) : null
        );
    }
    const getSelectedHandle = (seleted)=>{
        setPriority(seleted.name)
        setPriorityEnum(seleted.id)
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
                            <Text style={styles.prioritySelectText}>{`已选：${priority}`}</Text>
                        </View>
                    </View>
                </View>
                <BottomModalComponent type='friendpriorityselect' visible={visible} getSelected={getSelectedHandle} getVisible={setVisible} />
            </>
        )
    }
    return (
        <View style={{height: '100%'}}>
            <View style={mystylesheet.userInputcontainer}>
                <UserInputComponent content='被添加好友ID' placeholdercontent='被添加好友ID' getContent={setFriendID}/>
            </View>
            <View style={mystylesheet.userInputcontainer}>
                <UserInputComponent content='好友备注' placeholdercontent='好友备注' getContent={setFriendRemark}/>
            </View>
            <View style={mystylesheet.userInputcontainer}> 
                <UserInputComponent content='好友分组' placeholdercontent='好友分组' getContent={setFriendGrouping}/>
            </View>
            <View style={mystylesheet.userInputcontainer}>
                <UserInputComponent content='添加简述' placeholdercontent='添加简述' getContent={setBriefly}/>
            </View>
            <PriorityComponent />
            <CommonButton handler={() => addFriend()} content={'添加好友'}></CommonButton>
            <CodeComponent></CodeComponent>
        </View>
    )
}

export default AddFriendComponent
const styles = StyleSheet.create({
    prioritySelectView: {
        flexDirection: 'row',
    },
    prioritySelectText: {
        marginTop: 5,
        fontSize: 14,
        marginLeft: 5
    },    
})