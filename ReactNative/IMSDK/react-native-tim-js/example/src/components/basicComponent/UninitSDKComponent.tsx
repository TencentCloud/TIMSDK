import * as React from 'react';

import { Text } from 'react-native';
import { TencentImSDKPlugin } from 'react-native-tim-js';
import CommonButton from '../commonComponents/CommonButton';

const UninitSDKComponent = () => {
    const unInitSDK = async () => {
        const res = await TencentImSDKPlugin.v2TIMManager.unInitSDK();
        console.log(res)
        setRes(res)
    }
    const [res, setRes] = React.useState<any>({})
    const CodeComponent = () => {
        return (
            res.code !== undefined?
                (<Text>{JSON.stringify(res)}</Text>) : null
        );
    }
    return (
        <>
            <CommonButton handler={() => unInitSDK()} content={'unInitSDK'}></CommonButton>
            <CodeComponent></CodeComponent>
        </>
    )
}

export default UninitSDKComponent