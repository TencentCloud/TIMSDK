import * as React from 'react';

import { Text, View } from 'react-native';
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
                (<Text>{JSON.stringify(res, null, 2)}</Text>) : null
        );
    }
    return (
        <View style={{height: '100%'}}>
            <CommonButton handler={() => unInitSDK()} content={'unInitSDK'}></CommonButton>
            <CodeComponent></CodeComponent>
        </View>
    )
}

export default UninitSDKComponent