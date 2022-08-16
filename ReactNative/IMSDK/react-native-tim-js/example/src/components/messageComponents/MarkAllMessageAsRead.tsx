import * as React from 'react';

import { Text, View } from 'react-native';
import { TencentImSDKPlugin } from 'react-native-tim-js';
import CommonButton from '../commonComponents/CommonButton';

const MarkAllMessageAsReadComponent = () => {
    const markAllMessageAsRead= async () => {
        const res = await TencentImSDKPlugin.v2TIMManager.getMessageManager().markAllMessageAsRead()
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
            <CommonButton handler={() => markAllMessageAsRead()} content={'标记所有消息已读'}></CommonButton>
            <CodeComponent></CodeComponent>
        </View>
    )
}

export default MarkAllMessageAsReadComponent