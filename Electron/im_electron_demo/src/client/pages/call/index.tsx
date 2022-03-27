import React, { useEffect } from 'react';
import "tea-component/dist/tea.css";
import { useCallData } from './useCallData';
import { CallContent } from './callContent/CallContent';
import { Notification } from './notification/index';
import { Meeting } from './meeting';


export const Call = () => {
    const { 
        windowType,
        userID,
        convInfo, 
        roomId, 
        callType, 
        inviteID, 
        inviteList, 
        userSig, 
        sdkAppid, 
        inviteListWithInfo, 
        isInviter,
        isVideoOpen,
        isVoiceOpen
    } = useCallData();

    const getCompByWindowType = () => {
        switch(windowType) {
            case 'callWindow':
                return (
                    <CallContent 
                        userId={userID} 
                        convInfo={convInfo} 
                        roomId={roomId}  
                        inviteID={inviteID} 
                        inviteList={inviteList} 
                        userSig={userSig} 
                        sdkAppid={sdkAppid} 
                        callType={callType}
                        inviteListWithInfo={inviteListWithInfo}
                        isInviter={isInviter}
                />);
            case 'notificationWindow':
                return (
                    <Notification 
                    convInfo={convInfo} 
                    callType={callType}
                    inviteID={inviteID} 
                />)
            case 'meetingWindow':
                return (
                    <Meeting 
                        roomId={roomId}
                        isVideoOpen={isVideoOpen}
                        isVoiceOpen={isVoiceOpen}
                        userSig={userSig}
                        sdkAppid={sdkAppid}
                        userId={userID}
                    />
                );
            default:
                return null;

        }
    };

    if(roomId === 0) {
        return null
    }
    return (
        <div>
            {
                getCompByWindowType()
            }
        </div>
    )
};