import * as React from 'react';
import { View } from 'react-native';

import { TencentImSDKPlugin } from 'react-native-tim-js';
import CommonButton from '../commonComponents/CommonButton';

const LogoutComponent = () => {
    const logout = async () => {
        const res = await TencentImSDKPlugin.v2TIMManager.logout();
        console.log(res);
    }


    return (
        <View style={{height: '100%'}}>
            <CommonButton handler={() =>logout()} content={'登出'}></CommonButton>
        </View>
    )
}

export default LogoutComponent
