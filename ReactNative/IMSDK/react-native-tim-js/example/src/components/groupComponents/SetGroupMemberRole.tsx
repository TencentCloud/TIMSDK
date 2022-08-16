import React,{useState} from 'react';
import { Text, View, StyleSheet, TouchableOpacity, } from 'react-native';
import { TencentImSDKPlugin } from 'react-native-tim-js';
import CommonButton from '../commonComponents/CommonButton';
import SDKResponseView from '../sdkResponseView';
import CheckBoxModalComponent from '../commonComponents/CheckboxModalComponent';
import BottomModalComponent from '../commonComponents/BottomModalComponent';
import mystylesheet from '../../stylesheets';
const SetGroupMemberRoleComponent = () => {
    const [groupID, setGroupID] = useState<string>('未选择')
    const [res, setRes] = useState<any>({});
    const [memberName,setMemberName] = useState<string>('');
    const [role,setRole] = useState<string>('V2TIM_GROUP_MEMBER_UNDEFINED')
    const [roleEnum,setRoleEnum] = useState<number>(0)

    const setGroupMemberRole = async()=>{
        const res = await TencentImSDKPlugin.v2TIMManager.getGroupManager().setGroupMemberRole(groupID,memberName,roleEnum)
        setRes(res)
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
    };
    const RoleComponent = () => {
        const [visible, setVisible] = useState(false)
        const getSelectedHandler = (selected) => {
            setRole(selected.name)
            setRoleEnum(selected.id)
        }
        return (
            <>
                <View style={mystylesheet.userInputcontainer}>
                    <View style={mystylesheet.itemContainergray}>
                        <View style={styles.selectView}>
                            <TouchableOpacity onPress={() => { setVisible(true) }}>
                                <View style={mystylesheet.buttonView}>
                                    <Text style={mystylesheet.buttonText}>选择群角色</Text>
                                </View>
                            </TouchableOpacity>
                            <Text style={styles.selectText}>{`已选：${role}`}</Text>
                        </View>
                    </View>
                </View>
                <BottomModalComponent type='roleselect' visible={visible} getSelected={getSelectedHandler} getVisible={setVisible} />
            </>
        )
    };
    return (
        <View style={{height: '100%'}}>
            <GroupSelectComponent/>
            <MembersSelectComponent/>
            <RoleComponent/>
            <CommonButton
                handler={() => setGroupMemberRole()}
                content={'设置群成员角色'}
            ></CommonButton>
            <CodeComponent></CodeComponent>
        </View>
    );
};

export default SetGroupMemberRoleComponent;

const styles = StyleSheet.create({
    container: {
        marginLeft: 10,
    },
    selectView: {
        flexDirection: 'row',
    },
    selectText: {
        marginLeft: 10,
        lineHeight: 35,
        fontSize: 14,
    },
    selectContainer: {
        flexDirection: 'row',
        marginTop: 10
    },
})