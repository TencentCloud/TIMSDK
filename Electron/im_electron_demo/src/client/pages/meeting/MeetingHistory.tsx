import React from 'react';
import { MeetingHistoryList } from './MeetingHistoryList';

export const MeetingHistory = () => {
    return (
        <div className="meeting-history">
            <div className="meeting-history__header">
                <span className="meeting-history__header--icon"></span>
                <span className="meeting-history__header--text">会议记录</span>
            </div>
            <div className="meeting-history__content">
                <MeetingHistoryList />
            </div>
        </div>
    )
};