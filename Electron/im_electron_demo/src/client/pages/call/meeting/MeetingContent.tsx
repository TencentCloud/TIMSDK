import React, { useEffect } from 'react';
import { getCurrentWindow } from '@electron/remote';
import {
    TRTCAppScene, 
    TRTCParams, 
    TRTCVideoEncParam,
    TRTCVideoResolution,
    TRTCVideoResolutionMode,
} from "trtc-electron-sdk/liteav/trtc_define";

import trtcInstance from '../../../utils/trtcInstance';

import { GroupVideo } from '../callVideo/GroupVideo';

type Props = {
    roomId: number;
    isVideoOpen: boolean;
    isVoiceOpen: boolean;
    userSig: string;
    sdkAppid: number;
    userId: string;
}

export const MeetingContent = (props: Props) => {
    const { roomId, sdkAppid, userId, userSig, isVideoOpen, isVoiceOpen } = props;

    useEffect(() => {
        trtcInstance.on('onExitRoom', onExitRoom);
        enterRoom();
        setVideoParams();
    }, [userId]);

    const onExitRoom = () => {
        const win = getCurrentWindow();
        win.close();
    }

    const enterRoom = () => {
        let param = new TRTCParams();
        param.sdkAppId = sdkAppid;
        param.userSig = userSig;
        param.roomId = 0;
        param.strRoomId = roomId + '';
        param.userId = userId;
        trtcInstance.enterRoom(param, TRTCAppScene.TRTCAppSceneVideoCall);
    }

    const setVideoParams = () => {
        const currentCamera = trtcInstance.getCurrentCameraDevice();
        const { deviceId } = currentCamera;
        trtcInstance.setCurrentCameraDevice(deviceId);

        let encParam = new TRTCVideoEncParam();
        encParam.videoResolution = TRTCVideoResolution.TRTCVideoResolution_640_360;
        encParam.resMode = TRTCVideoResolutionMode.TRTCVideoResolutionModeLandscape;
        encParam.videoFps = 25;
        encParam.videoBitrate = 600;
        encParam.enableAdjustRes = true;
        trtcInstance.setVideoEncoderParam(encParam);
    }

    return (
        <div className="meeting-content">
            <GroupVideo 
                isVideoCall
                inviteListWithInfo={[]}
                trtcInstance={trtcInstance}
                inviteList={[userId]}
                userId={userId}
                isVideoOpen={isVideoOpen}
                isVoiceOpen={isVoiceOpen}
            />
        </div>
    )
};