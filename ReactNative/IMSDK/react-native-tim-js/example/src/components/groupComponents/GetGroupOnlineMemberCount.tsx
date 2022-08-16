import React,{useState} from 'react';
import { Text, View, StyleSheet, TouchableOpacity, } from 'react-native';
import { TencentImSDKPlugin } from 'react-native-tim-js';
import CommonButton from '../commonComponents/CommonButton';
import SDKResponseView from '../sdkResponseView';
import CheckBoxModalComponent from '../commonComponents/CheckboxModalComponent';
import mystylesheet from '../../stylesheets';
const GetGroupOnlineMemberCountComponent = () => {
    const [groupID, setGroupID] = useState<string>('未选择')
    const [res, setRes] = React.useState<any>({});
    const getGroupOnlineMemberCount = async()=>{
        const res = await TencentImSDKPlugin.v2TIMManager.getGroupManager().getGroupOnlineMemberCount(groupID)
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
    }
    return (
        <View style={{height: '100%'}}>
            <GroupSelectComponent/>
            <CommonButton
                handler={() => getGroupOnlineMemberCount()}
                content={'获取群在线人数'}
            ></CommonButton>
            <CodeComponent></CodeComponent>
        </View>
    );
};

export default GetGroupOnlineMemberCountComponent;

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