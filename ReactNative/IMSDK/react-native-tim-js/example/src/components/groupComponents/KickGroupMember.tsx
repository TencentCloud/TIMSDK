import React, { useState } from 'react';
import { Text, View, StyleSheet, TouchableOpacity, } from 'react-native';
import { TencentImSDKPlugin } from 'react-native-tim-js';
import CommonButton from '../commonComponents/CommonButton';
import SDKResponseView from '../sdkResponseView';
import CheckBoxModalComponent from '../commonComponents/CheckboxModalComponent';
import MultiCheckBoxModalComponent from '../commonComponents/MultiCheckboxModalComponent';
import UserInputComponent from '../commonComponents/UserInputComponent';
import mystylesheet from '../../stylesheets';
const KickGroupMemberComponent = () => {
    const [groupID, setGroupID] = useState<string>('未选择')
    const [res, setRes] = useState<any>({});
    const [membersName,setMembersName] = useState('');
    const [membersList,setMembersList] = useState([]);

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
            <SDKResponseView codeString={JSON.stringify(res, null, 2)} />
        ) : null;
    };

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
    };
    const MembersSelectComponent = () => {
        const [visible, setVisible] = useState<boolean>(false)
        return (
            <View style={styles.container}>
                <View style={styles.selectContainer}>
                    <TouchableOpacity onPress={() => { setVisible(true) }}>
                        <View style={mystylesheet.buttonView}>
                            <Text style={mystylesheet.buttonText}>选择群成员</Text>
                        </View>
                    </TouchableOpacity>
                    <Text style={mystylesheet.selectedText}>{membersName}</Text>
                </View>
                <MultiCheckBoxModalComponent visible={visible} getVisible={setVisible} getUsername={getMembersHandler} type={'member'} groupID={groupID} />
            </View>
        )
    }
    return (
        <View style={{height: '100%'}}>
            <GroupSelectComponent />
            <MembersSelectComponent />
            <View style={mystylesheet.userInputcontainer}>
                <UserInputComponent content='reason' placeholdercontent='reason' getContent={() => {}} />
            </View>
            <CommonButton
                handler={() => kickGroupMember()}
                content={'踢群成员出群'}
            ></CommonButton>
            <CodeComponent></CodeComponent>
        </View>
    );
};

export default KickGroupMemberComponent;

const styles = StyleSheet.create({
    container: {
        marginLeft: 10,
    },
    selectView: {
        flexDirection: 'row',
    },
    selectContainer: {
        flexDirection: 'row',
        marginTop: 10
    },
})