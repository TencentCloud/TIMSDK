import React, { useState } from 'react';

import { View, StyleSheet } from 'react-native';
import { TencentImSDKPlugin } from 'react-native-tim-js';
import CommonButton from '../commonComponents/CommonButton';
import SDKResponseView from '../sdkResponseView';
import UserInputComponent from '../commonComponents/UserInputComponent';

const CallExperimentalAPIComponent = () => {
    const [res] = useState<any>({});

    const callExperimentalAPI = async () => {
        const res = await TencentImSDKPlugin.v2TIMManager.callExperimentalAPI(
            '940928'
        );
        console.log(res);
        // setRes(res);
    };

    const CodeComponent = () => {
        return res.code !== undefined ? (
            <SDKResponseView codeString={JSON.stringify(res)} />
        ) : null;
    };
    return (
        <>
            <View style={styles.userInputcontainer}>
                <UserInputComponent
                    content="请输入用户名"
                    placeholdercontent="请输入用户名"
                    getContent={() => {}}
                />
            </View>
            <CommonButton
                handler={() => {
                    callExperimentalAPI();
                }}
                content={'调用实验性接口'}
            ></CommonButton>
            <CodeComponent></CodeComponent>
        </>
    );
};

export default CallExperimentalAPIComponent;
const styles = StyleSheet.create({
    userInputcontainer: {
        margin: 10,
        marginBottom: 0,
        marginTop: 1,
        justifyContent: 'center',
    },
});
