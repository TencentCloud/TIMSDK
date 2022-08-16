import React from 'react';
import { View } from 'react-native';

import { TencentImSDKPlugin } from 'react-native-tim-js';
import CommonButton from '../commonComponents/CommonButton';
import SDKResponseView from '../sdkResponseView';

const GetJoinedGroupListComponent = () => {

    const [res, setRes] = React.useState<any>({});
    const getJoinedGroupList = async()=>{
        const res = await TencentImSDKPlugin.v2TIMManager.getGroupManager().getJoinedGroupList()
        setRes(res)
    }
    const CodeComponent = () => {
        return res.code !== undefined ? (
            <SDKResponseView codeString={JSON.stringify(res, null, 2)} />
        ) : null;
    };
    return (
        <View style={{height: '100%'}}>
            <CommonButton
                handler={() => getJoinedGroupList()}
                content={'获取加群列表'}
            ></CommonButton>
            <CodeComponent></CodeComponent>
        </View>
    );
};

export default GetJoinedGroupListComponent;