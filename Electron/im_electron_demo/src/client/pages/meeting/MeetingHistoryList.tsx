import React, { useEffect } from 'react';
import Store from 'electron-store';
import { useSelector } from 'react-redux';

import { generateStoreKey } from './meeting-util';
import { EmptyResult } from '../../components/emptyResult';
import timeFormat from '../../utils/timeFormat';

const store = new Store();

export const MeetingHistoryList = () => {
    const { userId, sdkappId } = useSelector((state: State.RootState) => state.settingConfig);
    const storeKey = generateStoreKey(userId, sdkappId);
    const historyList = store.get(storeKey) as {
        list: [{
            meetingName: string,
            meetingTime: number
        }]
    };

    const isEmpty = historyList === undefined || historyList.list.length <= 0;

    return (
        <div className="meeting-history-list">
            <EmptyResult isEmpty={isEmpty} contentText="暂无历史会议">
                {
                    historyList && historyList.list.map(item => {
                        return <div className="meeting-history-list__item" key={item.meetingTime}>
                            <span className="meeting-history-list__item--meeting-name">{item.meetingName}</span>
                            <span className="meeting-history-list__item--meeting-time">{timeFormat(item.meetingTime, false)}</span>
                        </div>
                    })
                }
            </EmptyResult>
        </div>
    )
}