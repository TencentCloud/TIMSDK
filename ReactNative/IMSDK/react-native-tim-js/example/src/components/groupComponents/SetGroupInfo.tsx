import React, { useState } from 'react';

import { Text, View, StyleSheet, Image, TouchableOpacity, Switch ,FlatList} from 'react-native';
import { TencentImSDKPlugin } from 'react-native-tim-js';
import CommonButton from '../commonComponents/CommonButton';
import UserInputComponent from '../commonComponents/UserInputComponent';
import mystylesheet from '../../stylesheets';
import BottomModalComponent from '../commonComponents/BottomModalComponent';
import SDKResponseView from '../sdkResponseView';
import AddFieldModalComponent from '../commonComponents/AddFieldModalComponent';
import CheckBoxModalComponent from '../commonComponents/CheckboxModalComponent';
const map = new Map()
const SetGroupInfoComponent = () => {
    // addType未处理
    const setGroupInfo = async () => {
        const customInfo = [...map.entries()].reduce((customInfo, [key, value]) => (customInfo[key] = value, customInfo), {})
        const res = await TencentImSDKPlugin.v2TIMManager.getGroupManager().setGroupInfo({
            groupID:groupID,
            groupType:groupType,
            groupName:groupName,
            notification:notice,
            introduction:briefly,
            faceUrl:imageurl,
            isAllMuted:isAllMuted,
            groupAddOpt:groupAddEnum,
            customInfo:customInfo
        })
        setRes(res)
    }
    const [groupID, setGroupID] = useState<string>('未选择')
    const [groupName, setGroupName] = useState<string>('')
    const [notice, setNotice] = useState<string>('')
    const [briefly, setBriefly] = useState<string>('')
    const [isAllMuted, setIsAllMuted] = useState<boolean>(false)
    const [groupType, setGroupType] = useState<string>('Work')
    const [groupAddType, setGroupAddType] = useState<string>('V2TIM_GROUP_ADD_FORBID')
    const [imageurl, setImageUrl] = useState<string>()
    const [groupAddEnum ,setGroupAddEnum] = useState<number>(0)

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
    const GroupSelectComponent = () => {
        const [visible, setVisible] = useState<boolean>(false)
        return (
            <View style={styles.container}>
                <View style={styles.selectContainer}>
                    <TouchableOpacity onPress={() => { setVisible(true) }}>
                        <View style={mystylesheet.buttonView}>
                            <Text style={mystylesheet.buttonText}>选择群组</Text>
                        </View>
                    </TouchableOpacity>
                    <Text style={mystylesheet.selectedText}>{groupID}</Text>
                </View>
                <CheckBoxModalComponent visible={visible} getVisible={setVisible} getUsername={setGroupID} type={'group'} />
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
    const GroupAddTypeSelectComponent = () => {
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
    const AddFieldsComponent = () => {
        const [visible, setVisible] = useState(false)
        const [data, setData] = useState<any>([])
        const getKeyValueHandler = (field) => {
            if (!map.has(field.key)) {
                map.set(field.key, field.val)
                setData([...data, { key: field.key, val: field.val }])
            } else {
                const dataArr: Object[] = []
                map.set(field.key, field.val)
                map.forEach((v, k) => {
                    dataArr.push({
                        key: k,
                        val: v
                    })
                })
                setData(dataArr)
            }
        }
        const deleteHandler = (key) => {
            map.delete(key)
            const dataArr: Object[] = []
            map.forEach((v, k) => {
                dataArr.push({
                    key: k,
                    val: v
                })
            })
            setData(dataArr)
        }
        const renderItem = ({ item }) => {
            return (
                <View style={styles.fieldItemContainer}>
                    <Text style={styles.fieldItemText}>{`${item.key}:${item.val}`}</Text>
                    <TouchableOpacity onPress={() => { deleteHandler(item.key) }}>
                        <Image style={styles.deleteIcon} source={require('../../icon/delete.png')} />
                    </TouchableOpacity>
                </View>
            )
        }
        return (
            <>
                <View style={mystylesheet.userInputcontainer}>
                    <View style={styles.containerGray}>
                        <View style={styles.addFieldsButtonContainer}>
                            <Image style={styles.userIcon} source={require('../../icon/persongray.png')} />
                            <View style={styles.selectView}>
                                <TouchableOpacity onPress={() => { setVisible(true) }}>
                                    <View style={mystylesheet.buttonView}>
                                        <Text style={mystylesheet.buttonText}>添加字段</Text>
                                    </View>
                                </TouchableOpacity>
                            </View>
                        </View>
                        <View style={styles.fieldContainer}>
                            <Text>已设置字段</Text>
                            <FlatList
                                data={data}
                                renderItem={renderItem}
                                extraData={(item, index) => item.key + index}
                            />
                        </View>
    
                    </View>
                </View>
                <AddFieldModalComponent visible={visible} getVisible={setVisible} getKeyValue={getKeyValueHandler} type={'field'}/>
            </>
        )
    }
    return (
        <View style={{height: '100%'}}>
            <GroupSelectComponent/>
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
            <GroupTypeSelectComponent />
            <GroupAddTypeSelectComponent />
            <AddFieldsComponent/>
            <CommonButton handler={() => setGroupInfo()} content={'设置群信息'}></CommonButton>
            <CodeComponent></CodeComponent>
        </View>
    )
}

export default SetGroupInfoComponent
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
    },
    fieldItemContainer: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignContent: 'center'
    },
    fieldItemText: {
        textAlignVertical: 'center',
        lineHeight: 30
    },
    containerGray: {
        borderBottomWidth: StyleSheet.hairlineWidth,
        borderBottomColor: "#c0c0c0",
        paddingTop: 15,
    },
    deleteIcon: {
        width: 30,
        height: 30,
        marginRight: 10
    },
    addFieldsButtonContainer: {
        flexDirection: 'row',
    },
    userIcon: {
        width: 30,
        height: 30,
        marginRight: 15,
        marginLeft: 15
    },
    fieldContainer: {
        marginTop: 8,
        marginBottom: 8
    },
})