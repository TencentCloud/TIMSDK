import React, { useState } from 'react';

import { TencentImSDKPlugin } from 'react-native-tim-js';
import { Text, View, TouchableOpacity, StyleSheet } from 'react-native';
import CommonButton from '../commonComponents/CommonButton';
import mystylesheet from '../../stylesheets';
import SDKResponseView from '../sdkResponseView';
import CheckBoxModalComponent from '../commonComponents/CheckboxModalComponent';
import BottomModalComponent from '../commonComponents/BottomModalComponent';
import stylesheet from '../../stylesheets';
const RefuseFriendApplicationStateComponent = () => {
    const [visible, setVisible] = useState<boolean>(false)
    const [userName, setUserName] = useState<string>('未选择')
    const [checkType, setCheckType] = useState<number>(1)
    const [type, setType] = useState<string>('别人发给我的加好友请求')

    const getSelectedHandle = (selected) => {
        setCheckType(selected.id)
        setType(selected.name)
    }
    // deleteType未处理
    const refuseFriendApplication = async () => {
        const res = await TencentImSDKPlugin.v2TIMManager.getFriendshipManager().refuseFriendApplication(checkType, userName)
        setRes(res)
    }

    const [res, setRes] = React.useState<any>({})
    const CodeComponent = () => {
        return (
            res.code !== undefined ?
                (<SDKResponseView codeString={JSON.stringify(res, null, 2)} />) : null
        );
    }

    const PriorityComponent = () => {
        const [visible, setVisible] = useState<boolean>(false)
        return (
            <>
                <View style={stylesheet.userInputcontainer}>
                    <View style={mystylesheet.itemContainergray}>
                        <View style={styles.prioritySelectView}>
                            <TouchableOpacity onPress={() => { setVisible(true) }}>
                                <View style={styles.deletebuttonView}>
                                    <Text style={styles.deletebuttonText}>选择类型</Text>
                                </View>
                            </TouchableOpacity>
                            <Text style={styles.prioritySelectText}>{`已选：${type}`}</Text>
                        </View>
                    </View>
                </View>
                <BottomModalComponent type='refusefriendselect' visible={visible} getSelected={getSelectedHandle} getVisible={setVisible} />
            </>
        )
    }
    return (
        <View style={{height: '100%'}}>
            <View style={styles.container}>
                <View style={mystylesheet.selectContainer}>
                    <TouchableOpacity onPress={() => { setVisible(true) }}>
                        <View style={mystylesheet.buttonView}>
                            <Text style={mystylesheet.buttonText}>选择好友申请</Text>
                        </View>
                    </TouchableOpacity>
                    <Text style={mystylesheet.selectedText}>{userName}</Text>
                </View>
                <CheckBoxModalComponent visible={visible} getVisible={setVisible} getUsername={setUserName} type={'friendapplication'} />
            </View>
            <PriorityComponent />
            <CommonButton handler={() => refuseFriendApplication()} content={'拒绝申请'}></CommonButton>
            <CodeComponent></CodeComponent>
        </View>

    )
}

export default RefuseFriendApplicationStateComponent

const styles = StyleSheet.create({
    container: {
        margin: 10,
        marginBottom: 0
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
    prioritySelectView: {
        flexDirection: 'row',
    },
    prioritySelectText: {
        marginTop: 5,
        fontSize: 14,
        marginLeft: 5
    },
})