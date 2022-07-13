import { TencentImSDKPlugin } from 'react-native-tim-js';
import React, { useState } from 'react';
import CommonButton from '../commonComponents/CommonButton';
import SDKResponseView from '../sdkResponseView';

export const GetConversationListByConversationIDs = () => {
    const [res, setRes] = useState<any>({});

    const CodeComponent = () => {
        return res.code !== undefined ? (
            <SDKResponseView codeString={JSON.stringify(res)} />
        ) : null;
    };

    const getConversationList = async () => {
        // const res = await TencentImSDKPlugin.v2TIMManager
        //     .getConversationManager()
        //     .getConversationListByConversaionIds(['c2c_121405', 'c2c_940928']);
        // const res = await TencentImSDKPlugin.v2TIMManager
        //     .getConversationManager()
        //     .pinConversation('c2c_121405', true);
        // const res = await TencentImSDKPlugin.v2TIMManager
        //     .getConversationManager()
        //     .getTotalUnreadMessageCount();
        // const res = await TencentImSDKPlugin.v2TIMManager
        //     .getConversationManager()
        //     .getConversation('c2c_121405');
        // const res = await TencentImSDKPlugin.v2TIMManager
        //     .getConversationManager()
        //     .deleteConversation('c2c_121405');
        const res = await TencentImSDKPlugin.v2TIMManager
            .getConversationManager()
            .setConversationDraft('c2c_109442', 'test draft');
        setRes(res);
        TencentImSDKPlugin.v2TIMManager
            .getConversationManager()
            .addConversationListener({
                onConversationChanged: (conversationList) => {
                    console.log('conversationList', conversationList);
                },
                onNewConversation: (conversationList) => {
                    console.log('conversationList', conversationList);
                },
            });
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
