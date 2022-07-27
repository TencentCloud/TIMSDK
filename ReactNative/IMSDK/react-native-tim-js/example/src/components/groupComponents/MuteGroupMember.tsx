import React,{useState} from 'react';
import { Text, View, StyleSheet, TouchableOpacity, } from 'react-native';
import { TencentImSDKPlugin } from 'react-native-tim-js';
import CommonButton from '../commonComponents/CommonButton';
import SDKResponseView from '../sdkResponseView';
import CheckBoxModalComponent from '../commonComponents/CheckboxModalComponent';
import UserInputComponent from '../commonComponents/UserInputComponent';
import mystylesheet from '../../stylesheets';
const MuteGroupMemberComponent = () => {
    const [groupID, setGroupID] = useState<string>('未选择')
    const [res, setRes] = useState<any>({});
    const [memberName,setMemberName] = useState<string>('');
    const [seconds,setSeconds] = useState<number>(0)

    const getGroupMembersInfo = async()=>{
        const res = await TencentImSDKPlugin.v2TIMManager.getGroupManager().muteGroupMember(groupID,memberName,seconds)
        setRes(res)
    }

    const CodeComponent = () => {
        return res.code !== undefined ? (
            <SDKResponseView codeString={JSON.stringify(res, null, 2)} />
        ) : null;
    };
    const setSecondsHandle = (sec)=>{
        setSeconds(parseInt(sec))
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
    };
    const MembersSelectComponent = ()=>{
        const [visible, setVisible] = useState<boolean>(false)
        return (
            <View style={styles.container}>
                <View style={styles.selectContainer}>
                    <TouchableOpacity onPress={() => { setVisible(true) }}>
                        <View style={mystylesheet.buttonView}>
                            <Text style={mystylesheet.buttonText}>选择群成员</Text>
                        </View>
                    </TouchableOpacity>
                    <Text style={mystylesheet.selectedText}>{memberName}</Text>
                </View>
                <CheckBoxModalComponent visible={visible} getVisible={setVisible} getUsername={setMemberName} type={'member'} groupID={groupID} />
            </View>
        )
    }
    return (
        <View style={{height: '100%'}}>
            <GroupSelectComponent/>
            <MembersSelectComponent/>
            <View style={mystylesheet.userInputcontainer}>
                <UserInputComponent content='seconds' placeholdercontent='seconds' getContent={setSecondsHandle} />
            </View>
            <CommonButton
                handler={() => getGroupMembersInfo()}
                content={'禁言群成员'}
            ></CommonButton>
            <CodeComponent></CodeComponent>
        </View>
    );
};

export default MuteGroupMemberComponent;

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