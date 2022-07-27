import * as React from 'react';
import { View } from 'react-native';

import { TencentImSDKPlugin } from 'react-native-tim-js';
import CommonButton from '../commonComponents/CommonButton';
import SDKResponseView from '../sdkResponseView';
const GetLoginUserComponent = () => {
    const getLoginUser = async () => {
        const res = await TencentImSDKPlugin.v2TIMManager.getLoginUser();
        setRes(res)
    }

    const [res, setRes] = React.useState<any>({})
    const CodeComponent = () => {
        return (
            res.code !== undefined ?
                <SDKResponseView codeString={JSON.stringify(res, null, 2)} /> : null
        );
    }
    return (
        <View style={{height: '100%'}}>
            <CommonButton handler={() => getLoginUser()} content={'获取当前登录用户'}></CommonButton>
            <CodeComponent></CodeComponent>
        </View>
    )
}

export default GetLoginUserComponent

