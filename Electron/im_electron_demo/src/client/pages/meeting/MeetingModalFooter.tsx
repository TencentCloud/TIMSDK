import React, { useState } from 'react';

import { Button } from 'tea-component';

export const MeetingModalFooter = (props) => {
    const { handleVideoMute, handleStartMeeting, type } = props;
    const [ isVoiceOpen, setVoiceOpen ]  = useState(true);
    const [ isVideoOpen, setVideoOpen ]  = useState(true);
    const btnText = type === 'createMeeting' ? '开始会议' : '加入会议'

    const handleVideoOpen = () => {
        handleVideoMute(isVideoOpen)
        setVideoOpen(prev => !prev);
    };

    const handleVoiceOpen = () => {
        setVoiceOpen(prev => !prev);
    }

    const handleStart = () => 
        handleStartMeeting({
            isVoiceOpen,
            isVideoOpen
        });

    return (
        <footer className="meeting-modal-body__footer">
            <div className="meeting-modal-body__footer--btn">
                <span className={ `btn__voice ${!isVoiceOpen ? 'is-mute' : '' }`} onClick={handleVoiceOpen}></span>
                <span className={ `btn__video ${!isVideoOpen ? 'is-mute' : '' }`} onClick={handleVideoOpen}></span>
            </div>
            <Button type="primary" onClick={handleStart}>{btnText}</Button>
        </footer>
    )
};