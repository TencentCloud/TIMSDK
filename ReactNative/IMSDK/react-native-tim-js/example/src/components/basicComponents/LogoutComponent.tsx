import * as React from 'react';

import { TencentImSDKPlugin } from 'react-native-tim-js';
import CommonButton from '../commonComponents/CommonButton';

const LogoutComponent = () => {
    const logout = async () => {
        const res = await TencentImSDKPlugin.v2TIMManager.logout();
        console.log(res);
    }


    return (
        <>
            <CommonButton handler={() =>logout()} content={'登出'}></CommonButton>
        </>
    )
}

export default LogoutComponent
