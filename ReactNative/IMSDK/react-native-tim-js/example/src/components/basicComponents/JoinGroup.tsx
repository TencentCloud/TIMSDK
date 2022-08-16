import React, { useState } from 'react';
import { TencentImSDKPlugin } from 'react-native-tim-js';
import CommonButton from '../commonComponents/CommonButton';
import {View} from 'react-native';

import SDKResponseView from '../sdkResponseView';
import UserInputComponent from '../commonComponents/UserInputComponent';
import mystylesheet from '../../stylesheets';
const JoinGroupComponent = () => {

    const [res, setRes] = useState<any>({});
    const [groupID,setGroupID] = useState<string>('');
    const [message,setMessage] = useState<string>('');


    const joinGoup = async () => {
        const groupid = groupID
        const sayhimessage = message
        const res = await TencentImSDKPlugin.v2TIMManager.joinGroup(
            groupid,
            sayhimessage
        )
        setRes(res);
    };

    const CodeComponent = () => {
        return res.code !== undefined ? (
            <SDKResponseView codeString={JSON.stringify(res, null, 2)} />
        ) : null;
    };
    return (
        <View style={{height: '100%'}}>
            <View style={mystylesheet.userInputcontainer}>
                <UserInputComponent content={'群ID'} placeholdercontent={'群ID'} getContent={setGroupID} />
            </View>
            <View style={mystylesheet.userInputcontainer}>
                <UserInputComponent content={'进群打招呼Message'} placeholdercontent={'进群打招呼Message'} getContent={setMessage} />
            </View>
            <CommonButton
                handler={() => joinGoup()}
                content={'加入群组'}
            ></CommonButton>
            <CodeComponent></CodeComponent>
        </View>
    );
};

export default JoinGroupComponent;

