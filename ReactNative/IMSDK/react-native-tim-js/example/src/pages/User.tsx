import * as React from 'react';

import { StyleSheet, View, Text, Image } from 'react-native';
import { TextInput, TouchableOpacity } from 'react-native-gesture-handler';

import storage from '../storage/Storage';

const DATA = [
    {
        id: 1,
        name: 'sdkappid',
        desc: '控制台去申请'
    },
    {
        id: 2,
        name: 'secret',
        desc: '控制台去申请'
    },
    {
        id: 3,
        name: 'userID',
        desc: '随便填'
    }
]

const Item = React.forwardRef(({ name, desc }: { name: string, desc: string }, ref) => {
    const [value, onChangeText] = React.useState('')
    const textInputref = React.useRef<TextInput>(null)
    const [styleState, setstyleState] = React.useState(false)

    React.useEffect(() => {
        storage.load({ key: name }).then(res => onChangeText(res)).catch(err=>console.log(err.message))
    }, [])

    React.useImperativeHandle(ref, () => ({
        setInfo: () => {
            itemBlue()
            storage.save({
                key: name,
                data: value,
                expires: null
            })
        },
        removeInfo: () => {
            storage.remove({ key: name })
            onChangeText('')
        }
    }))
    const itemBlue = () => {
        if (textInputref.current) textInputref.current.blur()
    }

    return (
        <TouchableOpacity style={styleState ? styles.itemContainerblue : styles.itemContainergray} onPress={() => { if (textInputref.current != null) textInputref.current.focus() }}>
            <Image style={styles.userIcon} source={styleState ? require('../icon/personblue.png') : require('../icon/persongray.png')} />
            <View>
                <Text style={styleState ? styles.userContentTitleblue : styles.userContentTitlegray}>{`${name},${desc}`}</Text>
                <TextInput ref={textInputref} onChangeText={text => onChangeText(text)} onFocus={() => setstyleState(!styleState)} onBlur={() => { setstyleState(!styleState) }} value={value}></TextInput>
            </View>
        </TouchableOpacity>
    )
})

const UserScreen = () => {
    const appidRef = React.useRef<any>()
    const secretRef = React.useRef<any>()
    const useridRef = React.useRef<any>()
    // const [torchable,setTourchable] =React.useState(true)

    const confirmSettings = () => {
        console.log("confirm")
        if (appidRef.current) appidRef.current.setInfo()
        if (secretRef.current) secretRef.current.setInfo()
        if (useridRef.current) useridRef.current.setInfo()
    }
    const cancelSettings = () => {
        console.log("cancel")
        if (appidRef.current) appidRef.current.removeInfo()
        if (secretRef.current) secretRef.current.removeInfo()
        if (useridRef.current) useridRef.current.removeInfo()
    }
    return (
        <>
            <View style={styles.container}>
                <Item ref={appidRef} name={DATA[0].name} desc={DATA[0].desc}></Item>
                <Item ref={secretRef} name={DATA[1].name} desc={DATA[1].desc}></Item>
                <Item ref={useridRef} name={DATA[2].name} desc={DATA[2].desc}></Item>
            </View>
            <View>
                <TouchableOpacity onPress={confirmSettings}>
                    <Text style={styles.buttonText}>确认设置</Text>
                </TouchableOpacity>
                <TouchableOpacity onPress={cancelSettings}>
                    <Text style={styles.buttonText}>清除所有设置</Text>
                </TouchableOpacity>
            </View>
        </>
    )
}

export default UserScreen
const styles = StyleSheet.create({
    container: {
        margin: 10
    },
    itemContainergray: {
        flexDirection: "row",
        borderBottomWidth: StyleSheet.hairlineWidth,
        borderBottomColor: "#c0c0c0",
        paddingTop: 15,
        height: 55
    },
    itemContainerblue: {
        flexDirection: "row",
        borderBottomWidth: StyleSheet.hairlineWidth,
        borderBottomColor: "#2F80ED",
        paddingTop: 15,
        height: 55
    },
    userIcon: {
        width: 30,
        height: 30,
        marginRight: 15,
        marginLeft: 15
    },
    userContentTitlegray: {
        fontSize: 11,
        color: '#808080'
    },
    userContentTitleblue: {
        fontSize: 11,
        color: '#2F80ED'
    },
    buttonText: {
        fontSize: 16,
        color: 'white',
        textAlign: 'center',
        textAlignVertical: 'center',
        backgroundColor: '#2F80ED',
        marginLeft: 10,
        marginRight: 10,
        marginBottom: 10,
        height: 40,
        lineHeight: 40,
        borderRadius: 5,
    }
})