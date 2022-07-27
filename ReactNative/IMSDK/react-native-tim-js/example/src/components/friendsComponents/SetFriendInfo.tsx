import React, { useState } from 'react';

import { Text, View, TouchableOpacity, StyleSheet, Image, FlatList } from 'react-native';
import { TencentImSDKPlugin } from 'react-native-tim-js';
import CommonButton from '../commonComponents/CommonButton';
import CheckBoxModalComponent from '../commonComponents/CheckboxModalComponent';
import UserInputComponent from '../commonComponents/UserInputComponent';
import AddFieldModalComponent from '../commonComponents/AddFieldModalComponent';
import mystylesheet from '../../stylesheets';
const map = new Map()
const SetFriendInfoComponent = () => {
    const setFriendInfo = async () => {
        const customInfo = [...map.entries()].reduce((customInfo, [key, value]) => (customInfo[key] = value, customInfo), {})
        const res = await TencentImSDKPlugin.v2TIMManager.getFriendshipManager().setFriendInfo(
            userName,
            nickName,
            customInfo
        )
        setRes(res)
    }

    const [res, setRes] = useState<any>({})
    const [userName, setUserName] = useState<string>('未选择')
    const [visible, setVisible] = useState<boolean>(false)
    const [nickName, setNickname] = useState<string>('')
    const CodeComponent = () => {
        return (
            res.code !== undefined ?
                (<Text>{JSON.stringify(res, null, 2)}</Text>) : null
        );
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
            <View style={styles.selectContainer}>
                <TouchableOpacity onPress={() => { setVisible(true) }}>
                    <View style={mystylesheet.buttonView}>
                        <Text style={mystylesheet.buttonText}>选择好友</Text>
                    </View>
                </TouchableOpacity>
                <Text style={mystylesheet.selectedText}>{userName}</Text>
            </View>
            <View style={styles.container}>
                <UserInputComponent content='好友备注' placeholdercontent='好友备注' getContent={setNickname} />
            </View>
            <AddFieldsComponent />
            <CommonButton handler={() => setFriendInfo()} content={'设置好友信息'}></CommonButton>
            <CheckBoxModalComponent visible={visible} getVisible={setVisible} getUsername={setUserName} type={'friend'} />
            <CodeComponent></CodeComponent>
        </View>
    )
}

export default SetFriendInfoComponent

const styles = StyleSheet.create({
    container: {
        margin: 10,
        marginBottom: 0
    },
    selectContainer: {
        flexDirection: 'row',
        alignItems: 'center',
        width: '100%',
        overflow: 'hidden',
        marginTop: 10,
        marginLeft: 10,
        marginRight: 10
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
    selectView: {
        flexDirection: 'row',
    },
    selectText: {
        marginTop: 5,
        fontSize: 14,
    },
    fieldContainer: {
        marginTop: 8,
        marginBottom: 8
    },
})