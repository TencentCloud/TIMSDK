import React, { useState, useEffect } from 'react';
import { message } from 'tea-component';
import {
    TRTCVideoResolutionMode,
    TRTCVideoResolution,
    TRTCVideoEncParam,
    TRTCVideoStreamType,
    Rect
} from "trtc-electron-sdk/liteav/trtc_define";

import CallFooter from "../callFooter/CallFooter";
import trtcInstance from '../../../utils/trtcInstance';
import event from '../event';
import { deleteGroup, quitGroup, modifyGroupOwner, sendMsg } from '../../../api';
import { ShareScreenSelectModal } from './ScreenSelectModal';
import { EndMeetingConfirmModal } from "./EndMeetingConfirmModal";

export const MeetingFooter = (props) => {
    const { isVideoOpen, isVoiceOpen, isGroupOwner, groupId, userId, groupOwner } = props;
    const [ isSharingScreen, setShareScreen] = useState(false);
    const [ showScreenSelect, setScreenSelect ] = useState(false);
    const [ isShowConfirmModal, setShowConfirmModal ] = useState(false);
    const [ meetingMember, setMeetingMember] = useState([]);
    const btnText = isGroupOwner ? '结束会议' : '离开会议';
    const toggleVideo = (isOpenCamera) => {
        trtcInstance.muteLocalVideo(isOpenCamera);
        event.emit('toggleVideo', !isOpenCamera);
    }

    const toggleVoice = (isMute) => {
        trtcInstance.muteLocalAudio(isMute);
        event.emit('toggleVoice', !isMute);
    }

    const closeWindow = async () => {
        if(isGroupOwner) {
            setShowConfirmModal(true);
        } else {
            await quitGroup(groupId);
            trtcInstance.exitRoom();
        }
    }

    const exitRoom = async () => {
        if(isSharingScreen) {
            trtcInstance.stopScreenCapture();
            setShareScreen(false);
            return;
        };
        closeWindow();
    }

    const handleScreenShareClick = () => {
        if(isSharingScreen) {
            message.warning({
                content: "正在分享屏幕"
            });
            return;
        }
        setScreenSelect(true);
    };

    const closeModal = () => setScreenSelect(false)

    const startShare = screen => {
        setShareScreen(true);
        closeModal();
        const { type, sourceId, sourceName } = screen;
        const selectRect = new Rect();
        const screenShareEncParam = new TRTCVideoEncParam(
            TRTCVideoResolution.TRTCVideoResolution_1280_720,
            TRTCVideoResolutionMode.TRTCVideoResolutionModeLandscape,
            15,
            1600,
            0,
            true,
        );
        trtcInstance.selectScreenCaptureTarget(type, sourceId, sourceName, selectRect, true, true);
        trtcInstance.startScreenCapture(null, TRTCVideoStreamType.TRTCVideoStreamTypeSub, screenShareEncParam)
    }

    const onUserSubStreamAvailable = (uid, available) => setShareScreen(available === 1);

    useEffect(() => {
        event.on('close-window',async () => {
            closeWindow();
        });
        event.on('userListChange', userListChangeCallback);
        trtcInstance.on('onUserSubStreamAvailable', onUserSubStreamAvailable);
    }, []);

    const userListChangeCallback = (data) => setMeetingMember(data);

    const endMeetingCallback = async () => {
        close();
        sendMsg({
            convId: groupId,
            convType: 2,
            messageElementArray: [{
                elem_type: 3,
                custom_elem_data: JSON.stringify({
                    endMeeting: true
                }),
                custom_elem_desc: '',
                custom_elem_ext: '',
                custom_elem_sound: '',
            }],
            userId: userId,
            callback: async () => {
                await deleteGroup(groupId);
                trtcInstance.exitRoom();
            }
        });
    };

    const close = () => setShowConfirmModal(false);

    const exitMeetingCallback = async () => {
        close();
        const newGroupOwner = meetingMember.filter(item => item.userId !== userId)[0];
        if(newGroupOwner) {
            await modifyGroupOwner({
                groupId: groupId,
                owner: newGroupOwner.userId
            });
            await quitGroup(groupId);
            trtcInstance.exitRoom();
        } else {
            endMeetingCallback();
        }
    }

    return (
        <div className="meeting-footer">
            <CallFooter 
                showScreenShare
                isVideoCall
                buttonText={isSharingScreen ? '结束共享' : btnText}
                handleScreenShareClick={handleScreenShareClick}
                isVideoOpen={isVideoOpen}
                isVoiceOpen={isVoiceOpen}
                toggleVideo={toggleVideo}
                toggleVoice={toggleVoice}
                exitRoom={exitRoom}
            />
            <ShareScreenSelectModal startShare={startShare} isShow={showScreenSelect} onClose={closeModal} />
            <EndMeetingConfirmModal isShow={isShowConfirmModal} endMeetingCallback={endMeetingCallback} close={close} exitMeetingCallback={exitMeetingCallback} />
        </div>
    )
};