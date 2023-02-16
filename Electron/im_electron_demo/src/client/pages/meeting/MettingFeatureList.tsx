import React from 'react';

import { MeetingModal } from './MeetingModal';
import { useDialogRef } from "../../utils/react-use/useDialog";

export const MeetingFeatureList = () => {
    const dialogRef = useDialogRef();
    const createMeeting = () => {
        dialogRef.current.open({ type: 'createMeeting' });
    };

    const joinMeeting = () => {
        dialogRef.current.open({ type: 'joinMeeting' });
    };
    
    return <div className="meeting-feature">
        <div className="meeting-feature__item" onClick={createMeeting}>
            <span className="meeting-feature__item--create-meeting"/>
            创建会议
        </div>
        <div className="meeting-feature__item" onClick={joinMeeting}>
            <span className="meeting-feature__item--join-meeting" />
            加入会议
        </div>
        <MeetingModal dialogRef={dialogRef} />
    </div>
};
