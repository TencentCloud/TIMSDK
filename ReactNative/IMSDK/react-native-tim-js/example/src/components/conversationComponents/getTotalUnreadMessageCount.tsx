import { TencentImSDKPlugin } from 'react-native-tim-js';
import React, { useState } from 'react';
import CommonButton from '../commonComponents/CommonButton';
import SDKResponseView from '../sdkResponseView';
import { View } from 'react-native';

export const GetTotalUnreadMessageCount = () => {
    const [res, setRes] = useState<any>({});

    const CodeComponent = () => {
        return res.code !== undefined ? (
            <SDKResponseView codeString={JSON.stringify(res, null, 2)} />
        ) : null;
    };

    const getConversationList = async () => {
        const res = await TencentImSDKPlugin.v2TIMManager
            .getConversationManager()
            .getTotalUnreadMessageCount();
        setRes(res);
    };
    return (
        <View style={{height: '100%'}}>
            <CommonButton
                handler={getConversationList}
                content={'获取会话未读总数'}
            ></CommonButton>
            <CodeComponent></CodeComponent>
        </View>
    );
};
