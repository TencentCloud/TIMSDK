import React from 'react';

import { MeetingFeatureList } from './MettingFeatureList';
import { MeetingHistory  } from "./MeetingHistory";

import './meeting.scss';

export const Meeting = () => {
    return <div className="meeting">
        <MeetingFeatureList />
        <MeetingHistory />
    </div>
};