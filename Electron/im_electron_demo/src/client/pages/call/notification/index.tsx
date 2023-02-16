import React, { useEffect } from 'react';

import './notification.scss';
import { eventListiner } from '../callIpc';
import event from '../event';
import { getCurrentWindow } from '@electron/remote';
export const Notification = (props) => {
    const { convInfo: { nickName, faceUrl, convType}, callType, inviteID } = props;
    const isVoiceCall = callType === 1;

    const accept = () => eventListiner.acceptCall({isVoiceCall: isVoiceCall && convType === 1});

    const refuse = () => eventListiner.refuseCall(inviteID);

    const getDisplayText = () => `邀请你进行${isVoiceCall ? '语音' : '视频'}通话`;

    const closeCallWIndow = () => {
        eventListiner.cancelCall(null, 0);
        const win =getCurrentWindow();
        win.close();
    }

    useEffect(()=>{
        event.on('exitRoom',()=>{
            // 如果没有接通，走这个退出逻辑
            closeCallWIndow();
        });

        let timer = setTimeout(() => {
            closeCallWIndow();
        }, 30 * 1000);

        return () => {
            clearTimeout(timer);
            event.off('exitRoom');
        }
    },[])

    return (
        <div className="notification">
            <div className="notification__title">
                <img src={faceUrl} className="notification__avatar"/>
                <span className="notification__title--nick-name">{nickName}</span><br></br>
                <span className="notification__title--text">{getDisplayText()}</span>
            </div>
            <div className="notification__btn">
                <div className="notification__btn--apply" onClick={accept}></div>
                <div className="notification__btn--refuse" onClick={refuse}></div>
            </div>
        </div>
    ) 
}