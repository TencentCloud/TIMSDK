import { TencentImSDKPlugin } from 'react-native-tim-js';
import React, { useState } from 'react';
import CommonButton from '../commonComponents/CommonButton';
import SDKResponseView from '../sdkResponseView';

export const GetConversationList = () => {
    const [res, setRes] = useState<any>({});
    const [nextSeq, setNextSeq] = useState<String>('0');

    const CodeComponent = () => {
        return res.code !== undefined ? (
            <SDKResponseView codeString={JSON.stringify(res)} />
        ) : null;
    };

    const getConversationList = async () => {
        const res = await TencentImSDKPlugin.v2TIMManager
            .getConversationManager()
            .getConversationList(10, nextSeq);
        setRes(res);
        if (res.code == 0) {
            setNextSeq(res.data?.nextSeq ?? '0');
        }
    };
    return (
        <>
            <CommonButton
                handler={getConversationList}
                content={'获取会话列表'}
            ></CommonButton>
            <CodeComponent></CodeComponent>
        </>
    );
};
