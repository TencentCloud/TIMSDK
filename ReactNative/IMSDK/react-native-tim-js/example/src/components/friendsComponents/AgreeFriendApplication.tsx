import React, { useState } from 'react';

import { TencentImSDKPlugin } from 'react-native-tim-js';
import { Text, View, TouchableOpacity, StyleSheet} from 'react-native';
import CommonButton from '../commonComponents/CommonButton';
import mystylesheet from '../../stylesheets';
import SDKResponseView from '../sdkResponseView';
import CheckBoxModalComponent from '../commonComponents/CheckboxModalComponent';
import BottomModalComponent from '../commonComponents/BottomModalComponent';
const AgreeFriendApplicationComponent = () => {
    const [visible, setVisible] = useState<boolean>(false)
    const [userName, setUserName] = useState<string>('未选择')
    const [checkType, setCheckType] = useState<number>(0)
    const [priority, setPriority] = useState<string>('双向好友')
    let type = 0;
    const getSelectedHandle = (selected)=>{
        setCheckType(selected.id)
        setPriority(selected.name)
    }
    // deleteType未处理
    const agreeFriendApplication = async () => {
        const res = await TencentImSDKPlugin.v2TIMManager.getFriendshipManager().acceptFriendApplication(checkType,type,userName)
        setRes(res)
    }

    const [res, setRes] = React.useState<any>({})
    const CodeComponent = () => {
        return (
            res.code !== undefined ?
                (<SDKResponseView codeString={JSON.stringify(res)} />) : null
        );
    }

    const PriorityComponent = () => {
        const [visible, setVisible] = useState<boolean>(false)
        return (
            <>
                <View style={styles.userInputcontainer}>
                    <View style={mystylesheet.itemContainergray}>
                        <View style={styles.prioritySelectView}>
                            <TouchableOpacity onPress={() => { setVisible(true) }}>
                                <View style={styles.deletebuttonView}>
                                    <Text style={styles.deletebuttonText}>选择同意类型</Text>
                                </View>
                            </TouchableOpacity>
                            <Text style={styles.prioritySelectText}>{`已选：${priority}`}</Text>
                        </View>
                    </View>
                </View>
                <BottomModalComponent type='checkfriendtypeselect' visible={visible} getSelected={getSelectedHandle} getVisible={setVisible} />
            </>
        )
    }
    return (
        <View style={styles.container}>
            <View style={styles.selectContainer}>
                <TouchableOpacity onPress={() => { setVisible(true) }}>
                    <View style={styles.buttonView}>
                        <Text style={styles.buttonText}>选择好友申请</Text>
                    </View>
                </TouchableOpacity>
                <Text style={styles.selectedText}>{userName}</Text>
            </View>
            <CheckBoxModalComponent visible={visible} getVisible={setVisible} getUsername={setUserName} type={'friendapplication'} getType={(val)=>{type=val}}/>
            <PriorityComponent/>
            <CommonButton handler={() => agreeFriendApplication()} content={'同意申请'}></CommonButton>
            <CodeComponent></CodeComponent>
        </View>
    )
}

export default AgreeFriendApplicationComponent

const styles = StyleSheet.create({
    container: {
        margin: 10,
        marginBottom: 0
    },

    buttonView: {
        backgroundColor: '#2F80ED',
        borderRadius: 3,
        width: 100,
        height: 35,
        marginLeft: 10
    },
    buttonText: {
        color: '#FFFFFF',
        fontSize: 14,
        textAlign: 'center',
        textAlignVertical: 'center',
        lineHeight: 35
    },    
    deletebuttonView: {
        backgroundColor: '#2F80ED',
        borderRadius: 3,
        width: 150,
        height: 35,
    },
    deletebuttonText: {
        color: '#FFFFFF',
        fontSize: 14,
        textAlign: 'center',
        textAlignVertical: 'center',
        lineHeight: 35
    },
    selectContainer: {
        flexDirection: 'row',
        alignItems: 'center',
        width: '100%',
        overflow: 'hidden'
    },
    selectedText: {
        marginLeft: 10,
        fontSize: 14,
        textAlignVertical: 'center',
        lineHeight: 35
    },
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
})