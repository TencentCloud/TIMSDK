import React,{useState} from 'react';
import { Text, View, StyleSheet, TouchableOpacity, } from 'react-native';
import { TencentImSDKPlugin } from 'react-native-tim-js';
import CommonButton from '../commonComponents/CommonButton';
import SDKResponseView from '../sdkResponseView';
import CheckBoxModalComponent from '../commonComponents/CheckboxModalComponent';
import mystylesheet from '../../stylesheets';
const InsertC2CMessageToLocalStorageComponent = () => {
    const [userID, setUserID] = useState<string>('未选择')
    const [senderID, setSenderID] = useState<string>('未选择')
    const [res, setRes] = useState<any>({});

    const insertC2CMessageToLocalStorage = async()=>{
        const res = await TencentImSDKPlugin.v2TIMManager.getMessageManager().insertC2CMessageToLocalStorage('',userID,senderID)
        setRes(res)
    }

    const CodeComponent = () => {
        return res.code !== undefined ? (
            <SDKResponseView codeString={JSON.stringify(res, null, 2)} />
        ) : null;
    };
    const FriendComponent = () => {
        const [visible, setVisible] = useState<boolean>(false)

        return (
            <View style={styles.friendgroupview}>
                <View style={styles.selectContainer}>
                    <TouchableOpacity onPress={() => { setVisible(true) }}>
                        <View style={mystylesheet.buttonView}>
                            <Text style={mystylesheet.buttonText}>选择好友</Text>
                        </View>
                    </TouchableOpacity>
                    <Text style={mystylesheet.selectedText}>{`消息接收者：${userID}`}</Text>
                </View>
                <CheckBoxModalComponent visible={visible} getVisible={setVisible} getUsername={setUserID} type={'friend'} />
            </View>
        )

    };

    const SenderComponent = () => {
        const [visible, setVisible] = useState<boolean>(false)

        return (
            <View style={styles.friendgroupview}>
                <View style={styles.selectContainer}>
                    <TouchableOpacity onPress={() => { setVisible(true) }}>
                        <View style={mystylesheet.buttonView}>
                            <Text style={mystylesheet.buttonText}>选择好友</Text>
                        </View>
                    </TouchableOpacity>
                    <Text style={mystylesheet.selectedText}>{`消息发送者：${senderID}`}</Text>
                </View>
                <CheckBoxModalComponent visible={visible} getVisible={setVisible} getUsername={setSenderID} type={'friend'} />
            </View>
        )

    };


    return (
        <View style={{height: '100%'}}>
            <FriendComponent/>
            <SenderComponent/>
            <CommonButton
                handler={() => insertC2CMessageToLocalStorage()}
                content={'向c2c会话中插入一条本地信息'}
            ></CommonButton>
            <CodeComponent></CodeComponent>
        </View>
    );
};

export default InsertC2CMessageToLocalStorageComponent;

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
    friendgroupview: {
        marginLeft: 10,
        marginRight: 10,
    },
})