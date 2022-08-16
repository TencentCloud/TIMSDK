import React, { useState } from 'react';

import { Text, View, StyleSheet, Image, TouchableOpacity, Switch } from 'react-native';
import { TencentImSDKPlugin , V2TimGroupMember} from 'react-native-tim-js';
import CommonButton from '../commonComponents/CommonButton';
import UserInputComponent from '../commonComponents/UserInputComponent';
import mystylesheet from '../../stylesheets';
import BottomModalComponent from '../commonComponents/BottomModalComponent';
import SDKResponseView from '../sdkResponseView';
import MultiCheckBoxModalComponent from '../commonComponents/MultiCheckboxModalComponent';
const CreateSuperGroupComponent = () => {
    // addType未处理
    const createGroup = async () => {
        const res = await TencentImSDKPlugin.v2TIMManager.getGroupManager().createGroup(
            {
                groupType,
                groupName,
                groupID,
                notification: notice,
                introduction: briefly,
                faceUrl: imageurl,
                isAllMuted,
                isSupportTopic: false,
                addOpt: groupAddEnum,
                memberList: userList
            }
           )
        setRes(res)
    }
    const [groupID, setGroupID] = useState<string>('')
    const [groupName, setGroupName] = useState<string>('')
    const [notice, setNotice] = useState<string>('')
    const [briefly, setBriefly] = useState<string>('')
    const [isAllMuted, setIsAllMuted] = useState<boolean>(false)
    const [userName, setUserName] = useState<string>('未选择')
    const [groupType, setGroupType] = useState<string>('Work')
    const [groupAddType, setGroupAddType] = useState<string>('V2TIM_GROUP_ADD_FORBID')
    const [imageurl, setImageUrl] = useState<string>()
    const [userList, setUserList] = useState<[V2TimGroupMember]>([{
        userID: '',
        role: 1 }])
    const [groupAddEnum,setGroupAddEnum] = useState<number>(0)
    const getUsersHandler = (userList) => {
        setUserName('[' + userList.join(',') + ']')
        const dataArr: [V2TimGroupMember] = [{
            userID: '',
            role: 1 }]
        dataArr.pop()
        userList.forEach(ele => {
            dataArr.push({
                userID:ele,
                role:1
            })
        });
        console.log(userList)
        setUserList(dataArr)
    }
    const [res, setRes] = useState<any>({})
    const allMutedtoggle = () => { setIsAllMuted(previousState => !previousState); }
    const CodeComponent = () => {
        return (
            res.code !== undefined ?
                (<SDKResponseView codeString={JSON.stringify(res, null, 2)} />) : null
        );
    }
    const getSelectedHandle = (seleted) => {
        setGroupAddType(seleted.name)
        setGroupAddEnum(seleted.id)
    }
    const ImageSelectComponent = () => {
        const [visible, setVisible] = useState(false)
        return (
            <>
                <View style={mystylesheet.userInputcontainer}>
                    <View style={mystylesheet.itemContainergray}>
                        <Image style={mystylesheet.userIcon} source={require('../../icon/persongray.png')} />
                        <View style={styles.selectView}>
                            <TouchableOpacity onPress={() => { setVisible(true) }}>
                                <View style={styles.faceurlbuttonView}>
                                    <Text style={styles.faceurlbuttonText}>选择群头像</Text>
                                </View>
                            </TouchableOpacity>
                            <Image style={styles.faceUrl} source={{ uri: imageurl }} />
                        </View>
                    </View>
                </View>
                <BottomModalComponent type='imageselect' visible={visible} getSelected={setImageUrl} getVisible={setVisible} />
            </>
        )
    }
    const FriendSelectComponent = () => {
        const [visible, setVisible] = useState<boolean>(false)
        return (
            <View style={styles.container}>
                <View style={styles.selectContainer}>
                    <TouchableOpacity onPress={() => { setVisible(true) }}>
                        <View style={mystylesheet.buttonView}>
                            <Text style={mystylesheet.buttonText}>选择好友</Text>
                        </View>
                    </TouchableOpacity>
                    <Text style={mystylesheet.selectedText}>{userName}</Text>
                </View>
                <MultiCheckBoxModalComponent visible={visible} getVisible={setVisible} getUsername={getUsersHandler} type={'friend'} />
            </View>
        )

    }
    const GroupTypeSelectComponent = () => {
        const [visible, setVisible] = useState<boolean>(false)
        return (
            <>
                <View style={mystylesheet.userInputcontainer}>
                    <View style={mystylesheet.itemContainergray}>
                        <Image style={mystylesheet.userIcon} source={require('../../icon/persongray.png')} />
                        <View style={styles.groupSelectView}>
                            <TouchableOpacity onPress={() => { setVisible(true) }}>
                                <View style={mystylesheet.buttonView}>
                                    <Text style={mystylesheet.buttonText}>选择群类型</Text>
                                </View>
                            </TouchableOpacity>
                            <Text style={styles.groupSelectText}>{`已选：${groupType}`}</Text>
                        </View>
                    </View>
                </View>
                <BottomModalComponent visible={visible} getSelected={setGroupType} getVisible={setVisible} type='groupselect' />
            </>

        )

    }
    const GroupAddTypeSelectComponent =()=>{
        const [visible, setVisible] = useState<boolean>(false)
        return (
            <>
                <View style={mystylesheet.userInputcontainer}>
                    <View style={mystylesheet.itemContainergray}>
                        <Image style={mystylesheet.userIcon} source={require('../../icon/persongray.png')} />
                        <View style={styles.groupSelectView}>
                            <TouchableOpacity onPress={() => { setVisible(true) }}>
                                <View style={mystylesheet.buttonView}>
                                    <Text style={mystylesheet.buttonText}>选择加群类型</Text>
                                </View>
                            </TouchableOpacity>
                            <Text style={styles.groupSelectText}>{`已选：${groupAddType}`}</Text>
                        </View>
                    </View>
                </View>
                <BottomModalComponent visible={visible} getSelected={getSelectedHandle} getVisible={setVisible} type='grouptypeselect' />
            </>
        )
    }
    return (
        <View style={{height: '100%'}}>
            <View style={mystylesheet.userInputcontainer}>
                <UserInputComponent content='群ID' placeholdercontent='群ID' getContent={setGroupID} />
            </View>
            <View style={mystylesheet.userInputcontainer}>
                <UserInputComponent content='群名称' placeholdercontent='群名称' getContent={setGroupName} />
            </View>
            <View style={mystylesheet.userInputcontainer}>
                <UserInputComponent content='群通告' placeholdercontent='群通告' getContent={setNotice} />
            </View>
            <View style={mystylesheet.userInputcontainer}>
                <UserInputComponent content='群简介' placeholdercontent='群简介' getContent={setBriefly} />
            </View>
            <ImageSelectComponent />
            <View style={mystylesheet.switchcontainer}>
                <Text style={mystylesheet.switchtext}>是否全体禁言</Text>
                <Switch
                    trackColor={{ false: "#c0c0c0", true: "#81b0ff" }}
                    thumbColor={isAllMuted ? "#2F80ED" : "#f4f3f4"}
                    ios_backgroundColor="#3e3e3e"
                    onValueChange={allMutedtoggle}
                    value={isAllMuted}
                />
            </View>
            <FriendSelectComponent/>
            <GroupTypeSelectComponent />
            <GroupAddTypeSelectComponent/>
            <CommonButton handler={() => createGroup()} content={'高级创建群'}></CommonButton>
            <CodeComponent></CodeComponent>
        </View>
    )
}

export default CreateSuperGroupComponent
const styles = StyleSheet.create({
    container: {
        marginLeft: 10,
    },
    prioritySelectView: {
        flexDirection: 'row',
    },
    prioritySelectText: {
        marginTop: 5,
        fontSize: 14,
        marginLeft: 5
    },
    selectView: {
        flexDirection: 'row',
    },
    faceurlbuttonView: {
        backgroundColor: '#2F80ED',
        borderRadius: 3,
        width: 130,
        height: 35,
        marginTop: -5,
        marginRight: 10,
    },
    faceurlbuttonText: {
        color: '#FFFFFF',
        fontSize: 14,
        textAlign: 'center',
        textAlignVertical: 'center',
        lineHeight: 35,
    },
    faceUrl: {
        width: 45,
        height: 45,
        marginTop: -10,
    },
    selectContainer: {
        flexDirection: 'row',
        marginTop: 10
    },
    groupSelectView: {
        flexDirection: 'row',
    },
    groupSelectText: {
        marginTop: 5,
        fontSize: 14,
        marginLeft: 5
    }
})