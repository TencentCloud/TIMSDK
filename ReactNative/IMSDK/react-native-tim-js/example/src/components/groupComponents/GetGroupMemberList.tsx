import React, { useState } from 'react';
import { Text, View, StyleSheet, TouchableOpacity, } from 'react-native';
import { TencentImSDKPlugin } from 'react-native-tim-js';
import CommonButton from '../commonComponents/CommonButton';
import SDKResponseView from '../sdkResponseView';
import CheckBoxModalComponent from '../commonComponents/CheckboxModalComponent';
import BottomModalComponent from '../commonComponents/BottomModalComponent';
import mystylesheet from '../../stylesheets';
const GetGroupMemberListComponent = () => {
    const [groupID, setGroupID] = useState<string>('未选择')
    const [res, setRes] = React.useState<any>({});
    const [priority, setPriority] = useState<string>('V2TIM_GROUP_MEMBER_FILTER_OWNER')
    const [priorityEnum, setPriorityEnum] = useState<number>(0)

    const getGroupMemberList = async () => {
        const res = await TencentImSDKPlugin.v2TIMManager.getGroupManager().getGroupMemberList(groupID, priorityEnum, '0')
        setRes(res)
    }
    const CodeComponent = () => {
        return res.code !== undefined ? (
            <SDKResponseView codeString={JSON.stringify(res)} />
        ) : null;
    };
    const GroupSelectComponent = () => {
        const [visible, setVisible] = useState<boolean>(false)
        return (
            <View style={styles.container}>
                <View style={styles.selectContainer}>
                    <TouchableOpacity onPress={() => { setVisible(true) }}>
                        <View style={styles.buttonView}>
                            <Text style={styles.buttonText}>选择群组</Text>
                        </View>
                    </TouchableOpacity>
                    <Text style={styles.selectedText}>{groupID}</Text>
                </View>
                <CheckBoxModalComponent visible={visible} getVisible={setVisible} getUsername={setGroupID} type={'group'} />
            </View>
        )
    };
    const PriorityComponent = () => {
        const [visible, setVisible] = useState(false)
        const getSelectedHandler = (selected) => {
            setPriority(selected.name)
            setPriorityEnum(selected.id)
        }
        return (
            <>
                <View style={styles.userInputcontainer}>
                    <View style={mystylesheet.itemContainergray}>
                        <View style={styles.selectView}>
                            <TouchableOpacity onPress={() => { setVisible(true) }}>
                                <View style={styles.buttonView}>
                                    <Text style={styles.buttonText}>选择优先级</Text>
                                </View>
                            </TouchableOpacity>
                            <Text style={styles.selectText}>{`已选：${priority}`}</Text>
                        </View>
                    </View>
                </View>
                <BottomModalComponent type='grouppriorityselect' visible={visible} getSelected={getSelectedHandler} getVisible={setVisible} />
            </>
        )
    };
    return (
        <>
            <GroupSelectComponent />
            <PriorityComponent />
            <Text style={styles.nextseqstyle}>nextSeq 0</Text>
            <CommonButton
                handler={() => getGroupMemberList()}
                content={'获取群群成员列表'}
            ></CommonButton>
            <CodeComponent></CodeComponent>
        </>
    );
};

export default GetGroupMemberListComponent;

const styles = StyleSheet.create({
    container: {
        marginLeft: 10,
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
    selectView: {
        flexDirection: 'row',
    },
    selectContainer: {
        flexDirection: 'row',
        marginTop: 10
    },
    selectedText: {
        marginLeft: 10,
        fontSize: 14,
        textAlignVertical: 'center',
        lineHeight: 35
    },
    userInputcontainer: {
        marginLeft: 10,
        marginRight: 10,
        justifyContent: 'center'
    },
    selectText: {
        marginLeft: 10,
        lineHeight: 35,
        fontSize: 14,
    },
    nextseqstyle: {
        margin: 10
    }
})