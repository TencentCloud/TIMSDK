import React, { useRef } from 'react';
import TRTCCloud from 'trtc-electron-sdk';

import { C2Cvideo } from './C2CVideo';
import { GroupVideo } from './GroupVideo';

import './call-video.scss';

type Props = {
    trtcInstance: TRTCCloud,
    userId: string,
    convInfo: {
        faceUrl: string,
        nickName: string,
        convType: number
    },
    inviteList: Array<State.userInfo>,
    isVideoCall: boolean,
    inviteListWithInfo: []
}

export const CallVideo = (props: Props): JSX.Element => {
    const videoRef = useRef(null);
    const { trtcInstance, convInfo, inviteList, userId, isVideoCall, inviteListWithInfo } = props;
    const convType = convInfo.convType;

    const isC2CCall = convType === 1;
    
    return (
        <div className="call-video" ref={videoRef}>
            {
                isC2CCall ? 
                <C2Cvideo 
                    isVideoCall={isVideoCall} 
                    convInfo={convInfo} 
                    trtcInstance={trtcInstance}
                /> : 
                <GroupVideo 
                    isVideoCall={isVideoCall}
                    inviteListWithInfo={inviteListWithInfo}
                    trtcInstance={trtcInstance} 
                    inviteList={inviteList} 
                    userId={userId} 
                />
            }
        </div>
    )
};