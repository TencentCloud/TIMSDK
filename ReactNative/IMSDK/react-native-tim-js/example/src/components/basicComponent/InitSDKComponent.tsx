import React, { useState, useEffect } from 'react';

import { TencentImSDKPlugin } from 'react-native-tim-js';
import CommonButton from '../commonComponents/CommonButton';
import storage from '../../storage/Storage';
import SDKResponseView from '../sdkResponseView';

const InitSDKComponent = () => {
    const [sdkInfo, setSDKInfo] = useState<any>({
        sdkappid: undefined,
        secret: undefined,
    });

    useEffect(() => {
        Promise.all([
            storage.load({ key: 'sdkappid' }),
            storage.load({ key: 'secret' }),
        ])
            .then((res) => {
                setSDKInfo({
                    sdkappid: res[0],
                    secret: res[1],
                });
            })
            .catch((reason) => {
                console.log(reason);
            });
    }, []);

    const initSDK = async () => {
        const res = await TencentImSDKPlugin.v2TIMManager.initSDK(
            parseInt(sdkInfo.sdkappid),
            3
        );
        setRes(res);
    };
    const [res, setRes] = React.useState<any>({});
    const CodeComponent = () => {
        return res.code !== undefined ? (
            <SDKResponseView codeString={JSON.stringify(res)} />
        ) : null;
    };
    return (
        <>
            <CommonButton
                handler={() => initSDK()}
                content={'初始化'}
            ></CommonButton>
            <CodeComponent></CodeComponent>
        </>
    );
};

export default InitSDKComponent;
