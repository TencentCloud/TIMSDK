import React,{useState} from 'react';
import { Text, View, StyleSheet, TouchableOpacity, } from 'react-native';
import { TencentImSDKPlugin } from 'react-native-tim-js';
import CommonButton from '../commonComponents/CommonButton';
import SDKResponseView from '../sdkResponseView';
import CheckBoxModalComponent from '../commonComponents/CheckboxModalComponent';

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
            <SDKResponseView codeString={JSON.stringify(res)} />
        ) : null;
    };
    const FriendComponent = () => {
        const [visible, setVisible] = useState<boolean>(false)

        return (
            <View style={styles.friendgroupview}>
                <View style={styles.selectContainer}>
                    <TouchableOpacity onPress={() => { setVisible(true) }}>
                        <View style={styles.buttonView}>
                            <Text style={styles.buttonText}>选择好友</Text>
                        </View>
                    </TouchableOpacity>
                    <Text style={styles.selectedText}>{`消息接收者：${userID}`}</Text>
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
                        <View style={styles.buttonView}>
                            <Text style={styles.buttonText}>选择好友</Text>
                        </View>
                    </TouchableOpacity>
                    <Text style={styles.selectedText}>{`消息发送者：${senderID}`}</Text>
                </View>
                <CheckBoxModalComponent visible={visible} getVisible={setVisible} getUsername={setSenderID} type={'friend'} />
            </View>
        )

    };


    return (
        <>
            <FriendComponent/>
            <SenderComponent/>
            <CommonButton
                handler={() => insertC2CMessageToLocalStorage()}
                content={'向c2c会话中插入一条本地信息'}
            ></CommonButton>
            <CodeComponent></CodeComponent>
        </>
    );
};

export default InsertC2CMessageToLocalStorageComponent;

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
    friendgroupview: {
        marginLeft: 10,
        marginRight: 10,
    },
})