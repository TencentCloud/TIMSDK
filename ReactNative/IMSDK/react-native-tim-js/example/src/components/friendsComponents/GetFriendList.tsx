import * as React from 'react';

import { TencentImSDKPlugin } from 'react-native-tim-js';
import CommonButton from '../commonComponents/CommonButton';
import SDKResponseView from '../sdkResponseView';
const GetFriendListComponent = () => {
    const getFriendList = async () => {
        const res = await TencentImSDKPlugin.v2TIMManager.getFriendshipManager().getFriendList()
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
            <CommonButton handler={() => getFriendList()} content={'获取好友列表'}></CommonButton>
            <CodeComponent></CodeComponent>
        </>
    )
}

export default GetFriendListComponent