import * as React from 'react';

import { TencentImSDKPlugin } from 'react-native-tim-js';
import CommonButton from '../commonComponents/CommonButton';
import SDKResponseView from '../sdkResponseView';
const GetGroupApplicationListComponent = () => {
    const getGroupApplicationList = async () => {
        const res = await TencentImSDKPlugin.v2TIMManager.getGroupManager().getGroupApplicationList()
        setRes(res)
    }

    const [res, setRes] = React.useState<any>({})
    const CodeComponent = () => {
        return (
            res.code !== undefined ?
                (<SDKResponseView codeString={JSON.stringify(res)}/>) : null
        );
    }
    return (
        <>
            <CommonButton handler={() => getGroupApplicationList()} content={'获取群申请列表'}></CommonButton>
            <CodeComponent></CodeComponent>
        </>
    )
}

export default GetGroupApplicationListComponent