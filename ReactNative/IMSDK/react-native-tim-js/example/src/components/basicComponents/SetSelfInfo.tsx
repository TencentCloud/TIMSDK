import React, { useState, useEffect } from 'react';

import { View, StyleSheet, Image, TouchableOpacity, Text, FlatList } from 'react-native';
import { TencentImSDKPlugin } from 'react-native-tim-js';
import CommonButton from '../commonComponents/CommonButton';
import SDKResponseView from '../sdkResponseView';
import UserInputComponent from '../commonComponents/UserInputComponent';
import mystylesheet from '../../stylesheets';
import BottomModalComponent from '../commonComponents/BottomModalComponent';
import AddFieldModalComponent from '../commonComponents/AddFieldModalComponent';
import storage from '../../storage/Storage';

const GenderSelectComponent = (props) => {
    const [visible, setVisible] = useState(false)
    const [gender, setGender] = useState<string>('')
    const { getGender } = props
    const getSelectedHandler = (val) => {
        setGender(val)
        if (val === '男')
            getGender(1)
        if (val === '女')
            getGender(2)
    }
    return (
        <>
            <View style={mystylesheet.userInputcontainer}>
                <View style={mystylesheet.itemContainergray}>
                    <Image style={mystylesheet.userIcon} source={require('../../icon/persongray.png')} />
                    <View style={styles.selectView}>
                        <TouchableOpacity onPress={() => { setVisible(true) }}>
                            <View style={styles.buttonView}>
                                <Text style={mystylesheet.buttonText}>选择性别</Text>
                            </View>
                        </TouchableOpacity>
                        <Text style={styles.selectText}>{`已选：${gender}`}</Text>
                    </View>
                </View>
            </View>
            <BottomModalComponent type='genderselect' visible={visible} getSelected={getSelectedHandler} getVisible={setVisible} />
        </>
    )
}
const FriendSelectComponent = (props) => {
    const [visible, setVisible] = useState(false)
    const [method, setMethod] = useState<string>('')
    const { getMethod } = props
    const getSelectedHandler = (val) => {
        setMethod(val)
        if (val === '允许所有人加我好友')
            getMethod(0)
        if (val === '加好友需我确认')
            getMethod(1)
        if (val === '不允许所有人加我好友')
            getMethod(2)
    }
    return (
        <>
            <View style={mystylesheet.userInputcontainer}>
                <View style={mystylesheet.itemContainergray}>
                    <Image style={mystylesheet.userIcon} source={require('../../icon/persongray.png')} />
                    <View style={styles.selectView}>
                        <TouchableOpacity onPress={() => { setVisible(true) }}>
                            <View style={styles.buttonView}>
                                <Text style={mystylesheet.buttonText}>加好友验证方式</Text>
                            </View>
                        </TouchableOpacity>
                        <Text style={styles.selectText}>{`已选：${method}`}</Text>
                    </View>
                </View>
            </View>
            <BottomModalComponent type='friendverificationselect' visible={visible} getSelected={getSelectedHandler} getVisible={setVisible} />
        </>
    )
}
const ImageSelectComponent = (props) => {
    const [visible, setVisible] = useState(false)
    const [imageurl, setImageUrl] = useState<string>()
    const { getImage } = props
    const getSelectedHandler = (val) => {
        setImageUrl(val)
        getImage(val)
    }
    return (
        <>
            <View style={mystylesheet.userInputcontainer}>
                <View style={mystylesheet.itemContainergray}>
                    <Image style={mystylesheet.userIcon} source={require('../../icon/persongray.png')} />
                    <View style={styles.selectView}>
                        <TouchableOpacity onPress={() => { setVisible(true) }}>
                            <View style={styles.buttonView}>
                                <Text style={mystylesheet.buttonText}>选择头像</Text>
                            </View>
                        </TouchableOpacity>
                        <Image style={styles.faceUrl} source={{ uri: imageurl }} />
                    </View>
                </View>
            </View>
            <BottomModalComponent type='imageselect' visible={visible} getSelected={getSelectedHandler} getVisible={setVisible} />
        </>
    )
}
const map = new Map()
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
                                <View style={styles.buttonView}>
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


const SetSelfInfoComponent = () => {
    const [res, setRes] = useState<any>({});
    const [gender, setGender] = useState<number>();
    const [method, setMethod] = useState<number>();
    const [imageurl, setImageurl] = useState<string>('');
    const [nickname, setNickname] = useState<string>('');
    const [sig, setSig] = useState<string>('');
    const [birthday, setBirthday] = useState<number>();
    const [userID, setUserID] = useState<string>();
    useEffect(() => {
        storage.load({ key: 'userID' }).then(res => setUserID(res)).catch(reason => console.log(reason))
    }, [])
    const setSelfInfo = async () => {
        const customInfo = [...map.entries()].reduce((customInfo, [key, value]) => (customInfo[key] = value, customInfo), {})
        const res = await TencentImSDKPlugin.v2TIMManager.setSelfInfo(
            {
                userID: userID,
                nickName: nickname,
                selfSignature: sig,
                birthday: birthday,
                gender: gender,
                allowType: method,
                customInfo: customInfo,
                faceUrl:`"${imageurl}"`
            }
        )
        setRes(res)

    };
    const CodeComponent = () => {
        return res.code !== undefined ? (
            <SDKResponseView codeString={JSON.stringify(res, null, 2)} />
        ) : null;
    };
    return (
        <View style={{height: '100%'}}>
            <View style={mystylesheet.userInputcontainer}>
                <UserInputComponent content='昵称' placeholdercontent='昵称' getContent={setNickname} />
            </View>
            <View style={mystylesheet.userInputcontainer}>
                <UserInputComponent content='签名' placeholdercontent='签名' getContent={setSig} />
            </View>
            <View style={mystylesheet.userInputcontainer}>
                <UserInputComponent content='生日' placeholdercontent='int类型，不要输入字符串' getContent={(val) => setBirthday(parseInt(val))} />
            </View>
            <GenderSelectComponent getGender={setGender} />
            <FriendSelectComponent getMethod={setMethod} />
            <ImageSelectComponent getImage={setImageurl} />
            <AddFieldsComponent />
            <CommonButton
                handler={() => { setSelfInfo() }}
                content={'设置个人信息'}
            ></CommonButton>
            <CodeComponent></CodeComponent>
        </View>
    );
};

export default SetSelfInfoComponent;
const styles = StyleSheet.create({
    buttonView: {
        backgroundColor: '#2F80ED',
        borderRadius: 3,
        width: 130,
        height: 35,
        marginTop: -5,
        marginRight: 10,
    },
    selectView: {
        flexDirection: 'row',
    },
    selectText: {
        marginTop: 5,
        fontSize: 14,
    },
    containerGray: {
        borderBottomWidth: StyleSheet.hairlineWidth,
        borderBottomColor: "#c0c0c0",
        paddingTop: 15,
    },
    userIcon: {
        width: 30,
        height: 30,
        marginRight: 15,
        marginLeft: 15
    },
    addFieldsButtonContainer: {
        flexDirection: 'row',
    },
    fieldContainer: {
        marginTop: 8,
        marginBottom: 8
    },
    deleteIcon: {
        width: 30,
        height: 30,
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
    faceUrl: {
        width: 45,
        height: 45,
        marginTop: -10,
    }
})

