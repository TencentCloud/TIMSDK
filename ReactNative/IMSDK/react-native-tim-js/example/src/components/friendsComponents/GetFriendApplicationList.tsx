import * as React from 'react';

import { TencentImSDKPlugin } from 'react-native-tim-js';
import CommonButton from '../commonComponents/CommonButton';
import SDKResponseView from '../sdkResponseView';
const GetFriendApplicationListComponent = () => {
    const getFriendApplicationList = async () => {
        const res = await TencentImSDKPlugin.v2TIMManager.getFriendshipManager().getFriendApplicationList()
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
            <CommonButton handler={() => getFriendApplicationList()} content={'获取好友申请列表'}></CommonButton>
            <CodeComponent></CodeComponent>
        </>
    )
}

export default GetFriendApplicationListComponent