import React, { useState, useEffect } from 'react';
import { Alert, View } from 'react-native';
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
        if(sdkInfo.sdkappid){
            const res = await TencentImSDKPlugin.v2TIMManager.initSDK(
                parseInt(sdkInfo.sdkappid),
                3
            );
            setRes(res);
        }else{
            Alert.alert('请在配置页面完成配置')
        }

    };
    const [res, setRes] = React.useState<any>({});
    const CodeComponent = () => {
        return res.code !== undefined ? (
            <SDKResponseView codeString={JSON.stringify(res, null, 2)} />
        ) : null;
    };
    return (
        <View style={{height: '100%'}}>
            <CommonButton
                handler={() => initSDK()}
                content={'初始化'}
            ></CommonButton>
            <CodeComponent></CodeComponent>
        </View>
    );
};

export default InitSDKComponent;
