import React, { useEffect, useState } from 'react';
import {
    TRTCVideoFillMode,
    TRTCVideoRotation,
    TRTCRenderParams,
    TRTCVideoStreamType
} from "trtc-electron-sdk/liteav/trtc_define";

import useDynamicRef from '../../../utils/react-use/useDynamicRef';
import event from '../event';
import useUserList from '../useUserList';
import { GroupVideoCall } from './GroupVideoCall';
import { getUserInfoList } from '../../../api';

let isOpenedLocalPreview = false;

export const GroupVideo = (props) => {
    const { trtcInstance, inviteList, userId, isVideoCall, isVideoOpen = true, isVoiceOpen = true, isMeetingModal = false } = props;
    const [groupSplit, deleteUser, setUserEntering, setUserAudioAvailable, setUserSpeaking, setUserOrder, setUserCamera] = useUserList(inviteList);
    const [enteringUser, setEnteringUser] = useState('');
    const [setRef, getRef] = useDynamicRef<HTMLDivElement>();

    useEffect(() => {
        event.on('toggleVideo', onVideoChanged);
        event.on('toggleVoice', onVoiceChanged);
        trtcInstance.on('onEnterRoom', onEnterRoom);
        trtcInstance.on('onRemoteUserLeaveRoom', onRemoteUserLeaveRoom);
        trtcInstance.on('onRemoteUserEnterRoom', onRemoteUserEnterRoom);
        isVideoCall && trtcInstance.on('onUserVideoAvailable', onUserVideoAvailable);
        trtcInstance.on('onUserAudioAvailable', onUserAudioAvailable);
        trtcInstance.on('onUserVoiceVolume', onUserVoiceVolume);
        trtcInstance.on('onUserSubStreamAvailable', onUserSubStreamAvailable);
    }, []);

    useEffect(() => {
        if (enteringUser) {
            const ref = getRef(enteringUser);
            if (enteringUser === userId) {
                setUserCamera(userId, isVideoOpen);
                setUserAudioAvailable(userId, isVoiceOpen);
                isVoiceOpen && startLocalAudio();
                trtcInstance.enableAudioVolumeEvaluation(300);
                isVideoCall && isVideoOpen && openLocalVideo(ref);
                return;
            }
        }
    }, [enteringUser]);

    const startLocalAudio = () => {
        trtcInstance.startLocalAudio();
    }

    const onVideoChanged = (shouldShow) => {
        const selfViewRef = getRef(userId);
        if(!isOpenedLocalPreview) {
            openLocalVideo(selfViewRef);
        } else {
            selfViewRef.current.getElementsByTagName('canvas')[0].style.display = shouldShow ? 'block' : 'none';
        }

        setUserCamera(userId, shouldShow);
    }

    const onVoiceChanged = (isAvailable) => setUserAudioAvailable(userId, isAvailable);

    const openLocalVideo = (selfViewRef) => {
        trtcInstance.startLocalPreview(selfViewRef.current);
        const params = new TRTCRenderParams(TRTCVideoRotation.TRTCVideoRotation0, TRTCVideoFillMode.TRTCVideoFillMode_Fill);
        trtcInstance.setLocalRenderParams(params);
        trtcInstance.muteLocalVideo(false);
        isOpenedLocalPreview = true;
    };

    const onEnterRoom = (result) => {
        if (result > 0) {
            setUserOrder(userId, true); // 自己始终在第一位
            setUserEntering(userId);
            setEnteringUser(userId);
        };
    };

    const onRemoteUserEnterRoom = async (userId) => {
        const isInvitemember = inviteList.includes(userId);
        if(!isInvitemember) {
            const userInfo = await getUserInfoList([userId]);
            setUserEntering(userId, userInfo[0]);
        } else {
            setUserEntering(userId);
        }
        setEnteringUser(userId);
    }

    const onUserVoiceVolume = (params) => {
        const speakingList = params.map(item => {
            const speakingUid = item.userId === "" ? userId : item.userId;
            if(item.volume >= 5) {
                return speakingUid
            }
        });
        setUserSpeaking(speakingList);
    }

    const onRemoteUserLeaveRoom = (userId) => deleteUser(userId);

    const onUserVideoAvailable = (uid, available) => {
        setTimeout(() => {
            const ref = getRef(uid);
            const isOpenCamera = available === 1;
            const isOpenStream = !!ref.current.getElementsByTagName('canvas')[0];
            if (isOpenCamera) {
                if(!isOpenStream) {
                    trtcInstance.startRemoteView(uid, ref.current);
                    trtcInstance.setRemoteViewFillMode(uid, TRTCVideoFillMode.TRTCVideoFillMode_Fill);
                }
                ref.current.style.display = 'block';
            } else {
                ref.current.style.display = 'none';
            }

            // setUserOrder(uid, isOpenCamera);
            setUserCamera(uid, isOpenCamera)
        }, 300);
    }

    const onUserAudioAvailable = (uid, available) => setUserAudioAvailable(uid, available === 1);

    const onUserSubStreamAvailable = (uid, available) => {
        const shareScreenRef = getRef('share-screen');
        const videoScreenRef = getRef('video');

        if( available === 1) {
            videoScreenRef.current.style.display = 'none';
            trtcInstance.startRemoteView(uid, shareScreenRef.current, TRTCVideoStreamType.TRTCVideoStreamTypeSub);
            trtcInstance.setRemoteViewFillMode(uid, TRTCVideoFillMode.TRTCVideoFillMode_Fill);
            shareScreenRef.current.style.display = 'block';
        } else {
            trtcInstance.stopRemoteView(uid, TRTCVideoStreamType.TRTCVideoStreamTypeSub);
            shareScreenRef.current.style.display = 'none';
            videoScreenRef.current.style.display = 'block';
        }
    }


    return (
        <>
            <div className="group-video-content">
                <div className="group-video-content__video" ref={setRef('video')}>
                    {
                        !isMeetingModal && <GroupVideoCall setRef={setRef} groupSplit={groupSplit} />
                    }
                </div>
                <div className="group-video-content__share-screen" ref={setRef('share-screen')} />
            </div>
        </>

    )
};