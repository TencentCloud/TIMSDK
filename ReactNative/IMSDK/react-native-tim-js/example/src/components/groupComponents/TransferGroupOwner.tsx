import React,{useState} from 'react';
import { Text, View, StyleSheet, TouchableOpacity, } from 'react-native';
import { TencentImSDKPlugin } from 'react-native-tim-js';
import CommonButton from '../commonComponents/CommonButton';
import SDKResponseView from '../sdkResponseView';
import CheckBoxModalComponent from '../commonComponents/CheckboxModalComponent';
import mystylesheet from '../../stylesheets';
const TransferGroupOwnerComponent = () => {
    const [groupID, setGroupID] = useState<string>('未选择')
    const [res, setRes] = useState<any>({});
    const [userID,setuserID] = useState('');

    const transferGroupOwner = async()=>{
        const res = await TencentImSDKPlugin.v2TIMManager.getGroupManager().transferGroupOwner(groupID,userID)
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
                    <Text style={mystylesheet.selectedText}>{userID}</Text>
                </View>
                <CheckBoxModalComponent visible={visible} getVisible={setVisible} getUsername={setuserID} type={'member'} groupID={groupID} />
            </View>
        )
    }
    return (
        <View style={{height: '100%'}}>
            <GroupSelectComponent/>
            <MembersSelectComponent/>
            <CommonButton
                handler={() => transferGroupOwner()}
                content={'转移群主'}
            ></CommonButton>
            <CodeComponent></CodeComponent>
        </View>
    );
};

export default TransferGroupOwnerComponent;

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