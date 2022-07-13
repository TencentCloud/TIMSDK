import React, { useState } from 'react';
import { TencentImSDKPlugin } from 'react-native-tim-js';
import CommonButton from '../commonComponents/CommonButton';
import {View, StyleSheet } from 'react-native';

import SDKResponseView from '../sdkResponseView';
import UserInputComponent from '../commonComponents/UserInputComponent';

const JoinGroupComponent = () => {

    const [res, setRes] = useState<any>({});
    const [groupID,setGroupID] = useState<string>('');
    const [message,setMessage] = useState<string>('');


    const joinGoup = async () => {
        const groupid = groupID
        const sayhimessage = message
        const res = await TencentImSDKPlugin.v2TIMManager.joinGroup(
            groupid,
            sayhimessage
        )
        setRes(res);
    };

    const CodeComponent = () => {
        return res.code !== undefined ? (
            <SDKResponseView codeString={JSON.stringify(res)} />
        ) : null;
    };
    return (
        <>
            <View style={styles.userInputcontainer}>
                <UserInputComponent content={'群ID'} placeholdercontent={'群ID'} getContent={setGroupID} />
            </View>
            <View style={styles.userInputcontainer}>
                <UserInputComponent content={'进群打招呼Message'} placeholdercontent={'进群打招呼Message'} getContent={setMessage} />
            </View>
            <CommonButton
                handler={() => joinGoup()}
                content={'加入群组'}
            ></CommonButton>
            <CodeComponent></CodeComponent>
        </>
    );
};

export default JoinGroupComponent;

const styles = StyleSheet.create({
    userInputcontainer: {
        margin: 10,
        marginBottom: 0,
        marginTop: 1,
        justifyContent: 'center'
    }
})