import React, { useEffect, useRef, useState } from 'react';
import { useSelector } from 'react-redux';
import { Avatar } from '../../components/avatar/avatar';
import { Input, message } from 'tea-component';
import {
    TRTCVideoRotation,
    TRTCVideoFillMode,
    TRTCRenderParams
} from "trtc-electron-sdk/liteav/trtc_define";

import trtcInstance from "../../utils/trtcInstance";
import { MeetingModalFooter } from "./MeetingModalFooter";
import { createGroup, joinGroup } from "../../api";
import { generateGroupId, generateMeetingId } from "./meeting-util";

export const MettingModalBody = (props) => {
    const { type, onSuccess } = props;
    const videoRef = useRef<HTMLDivElement>();
    const avatarRef =  useRef<HTMLDivElement>();
    const [joinMeetingId, setJoinMeetingId] = useState<string>("");
    const { nickName, userId, faceUrl } = useSelector(
        (state: State.RootState) => state.userInfo
    );

    const setVideoParams = () => {
        const currentCamera = trtcInstance.getCurrentCameraDevice();
        const { deviceId } = currentCamera;
        trtcInstance.setCurrentCameraDevice(deviceId);
        trtcInstance.startLocalPreview(videoRef.current);
        const params = new TRTCRenderParams(TRTCVideoRotation.TRTCVideoRotation0, TRTCVideoFillMode.TRTCVideoFillMode_Fill);
        trtcInstance.setLocalRenderParams(params);
    }

    const handleMeetingIdChange = (value) => {
        const formatedValue = value.replace(/\s+/g, "").replace(/(.{3})/g,'$1 ');
        setJoinMeetingId(formatedValue.trim());
    }

    const getHeader = () => {
        if(type === 'createMeeting') {
            return <span>
                {nickName || userId}创建的会议
            </span>
        }

        return <Input maxLength={11} placeholder="请输入会议ID" value={joinMeetingId} onChange={handleMeetingIdChange} />
    }

    const handleVideoMute = isMute => {
        if(!isMute) {
            avatarRef.current.style.display = 'none';
            videoRef.current.getElementsByTagName('canvas')[0].style.display = 'block';
        } else {
            avatarRef.current.style.display = 'block';
            videoRef.current.getElementsByTagName('canvas')[0].style.display = 'none';
        }
    };

    const handleStartMeeting = async (params) => {
        if(type === 'createMeeting') {
            createNewMeeting(params);
        } else {
            joinMeeting(params);
        }
    };

    const joinMeeting = async (params) => {
        const formatedGroupId = generateGroupId(joinMeetingId);
        const { code } = await joinGroup({
            groupId: formatedGroupId
        });
        if(code !== 0) {
            message.warning({content: '会议id不合法或不存在, 请重新输入'})
        } else {
            onSuccess({
                meetingId: joinMeetingId,
                ...params
            });
        }
    }

    const createNewMeeting = async (params) => {
        const meetingId = generateMeetingId();
        const groupId = generateGroupId(meetingId);
        const groupParams = {
            groupName: `${nickName || userId}的会议`,
            groupMember:  userId,
            groupType: '2',
            joinGroupMode: '2',
            groupId: groupId,
            groupAnnouncement: '会议'
        }
        try {
            await createGroup(groupParams);
            onSuccess({
                meetingId,
                ...params
            });
        } catch (e) {
            console.log('error', e);
        }
    }

    useEffect(() => {
        setVideoParams();
        return () => {
            trtcInstance.stopLocalPreview();
        }
    },[]);

    return (
        <div className="meeting-modal-body">
            <header className="meeting-modal-body__header">{getHeader()}</header>
            <section  className="meeting-modal-body__view">
                <div ref={videoRef}  className="content" />
                <div ref={avatarRef} className="profile" style={{display: 'none'}}>
                    <Avatar url={faceUrl} userID={userId} />
                </div>
            </section>
            <MeetingModalFooter type={type} handleStartMeeting={handleStartMeeting} handleVideoMute={handleVideoMute} />
        </div>
    )
}