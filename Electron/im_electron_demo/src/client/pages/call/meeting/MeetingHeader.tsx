import React from 'react';
import { CallTime } from '../callContent/CallTime';
import { Mac } from '../../../components/toolsBar/mac';
import { Windows } from '../../../components/toolsBar/windows'
import { isWin, maxSizeWin, minSizeWin, closeWin } from '../../../utils/tools';
import event from '../event';

export const MeetingHeader = ({ roomId, groupName }) => {
    const prefix = `ID: ${roomId}  |  `;
    const isWindowsPlatform = isWin();
    const closeWindow = () => {
        event.emit('close-window')
    }

    return <div className="meeting-header">
        {!isWindowsPlatform && <Mac maxSizeWin ={maxSizeWin} minSizeWin={minSizeWin} closeWin={closeWindow} />}
        <div className="call-time-content">
            <CallTime isStart prefix={prefix} />
        </div>
        <span className="group-name"> {groupName} </span>
        {isWindowsPlatform && <Windows maxSizeWin ={maxSizeWin} minSizeWin={minSizeWin} closeWin={closeWindow} />} 
    </div>
}