import React, { useState, useEffect } from 'react';

import { TencentImSDKPlugin } from 'react-native-tim-js';
import genTestUserSig from '../../utils/generateTestUserSig';
import CommonButton from '../commonComponents/CommonButton';
import storage from '../../storage/Storage';
import SDKResponseView from '../sdkResponseView';
import { View } from 'react-native';

const LoginComponent = () => {
    const [sdkInfo, setSDKInfo] = useState<{
        userID: string;
        secret: string;
        sdkappid: string;
    }>({
        userID: '',
        secret: '',
        sdkappid: '',
    });
    const [res, setRes] = React.useState<any>({});

    useEffect(() => {
        Promise.all([
            storage.load({ key: 'userID' }),
            storage.load({ key: 'secret' }),
            storage.load({ key: 'sdkappid' }),
        ])
            .then((res) => {
                setSDKInfo({
                    userID: res[0],
                    secret: res[1],
                    sdkappid: res[2],
                });
            })
            .catch((reason) => {
                console.log(reason);
            });
    }, []);

    const login = async () => {
        const { userID, secret, sdkappid } = sdkInfo;
        const { userSig } = genTestUserSig(userID, parseInt(sdkappid), secret);
        const res = await TencentImSDKPlugin.v2TIMManager.login(
            userID,
            userSig
        );
        setRes(res);
    };

    const CodeComponent = () => {
        return res.code !== undefined ? (
            <SDKResponseView codeString={JSON.stringify(res, null, 2)} />
        ) : null;
    };
    return (
        <View style={{height: '100%'}}>
            <CommonButton
                handler={() => login()}
                content={'登录'}
            ></CommonButton>
            <CodeComponent></CodeComponent>
        </View>
    );
};

export default LoginComponent;
