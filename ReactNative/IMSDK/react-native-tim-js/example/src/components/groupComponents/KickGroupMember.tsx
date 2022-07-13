import React, { useState } from 'react';
import { Text, View, StyleSheet, TouchableOpacity, } from 'react-native';
import { TencentImSDKPlugin } from 'react-native-tim-js';
import CommonButton from '../commonComponents/CommonButton';
import SDKResponseView from '../sdkResponseView';
import CheckBoxModalComponent from '../commonComponents/CheckboxModalComponent';
import MultiCheckBoxModalComponent from '../commonComponents/MultiCheckboxModalComponent';
import UserInputComponent from '../commonComponents/UserInputComponent';
const KickGroupMemberComponent = () => {
    const [groupID, setGroupID] = useState<string>('未选择')
    const [res, setRes] = useState<any>({});
    const [membersName,setMembersName] = useState('');
    const [membersList,setMembersList] = useState([]);
    // const [ setReason] = useState<string>('')

    const kickGroupMember = async () => {
        const res = await TencentImSDKPlugin.v2TIMManager.getGroupManager().kickGroupMember(groupID, membersList)
        setRes(res)
    }

    const getMembersHandler = (memberslist)=>{
        setMembersName('['+memberslist.join(',')+']')
        setMembersList(memberslist)
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
    const MembersSelectComponent = () => {
        const [visible, setVisible] = useState<boolean>(false)
        return (
            <View style={styles.container}>
                <View style={styles.selectContainer}>
                    <TouchableOpacity onPress={() => { setVisible(true) }}>
                        <View style={styles.buttonView}>
                            <Text style={styles.buttonText}>选择群成员</Text>
                        </View>
                    </TouchableOpacity>
                    <Text style={styles.selectedText}>{membersName}</Text>
                </View>
                <MultiCheckBoxModalComponent visible={visible} getVisible={setVisible} getUsername={getMembersHandler} type={'member'} groupID={groupID} />
            </View>
        )
    }
    return (
        <>
            <GroupSelectComponent />
            <MembersSelectComponent />
            <View style={styles.userInputcontainer}>
                <UserInputComponent content='reason' placeholdercontent='reason' getContent={() => {}} />
            </View>
            <CommonButton
                handler={() => kickGroupMember()}
                content={'踢群成员出群'}
            ></CommonButton>
            <CodeComponent></CodeComponent>
        </>
    );
};

export default KickGroupMemberComponent;

const styles = StyleSheet.create({
    container: {
        marginLeft: 10,
    },
    userInputcontainer: {
        margin: 10,
        marginBottom: 0,
        marginTop: 1,
        justifyContent: 'center'
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
    }
})