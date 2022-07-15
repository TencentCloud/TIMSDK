import * as React from 'react';

import { TencentImSDKPlugin } from 'react-native-tim-js';
import CommonButton from '../commonComponents/CommonButton';
import SDKResponseView from '../sdkResponseView';
const GetVersionComponent = () => {
    const getVersion = async () => {
        const res = await TencentImSDKPlugin.v2TIMManager.getVersion();
        setRes(res);
    }

    const [res, setRes] = React.useState<any>({})
    const CodeComponent = () => {
        return (
            res.code !== undefined?
                (<SDKResponseView codeString={JSON.stringify(res)} />) : null
        );
    }
    return (
        <>
            <CommonButton handler={() =>getVersion()} content={'获取native sdk版本号'}></CommonButton>
            <CodeComponent></CodeComponent>
        </>
    )
}

export default GetVersionComponent

