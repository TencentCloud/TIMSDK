import React, { useState, useEffect } from 'react';
import { debounce } from 'lodash';
import { message } from 'tea-component';

import event from '../event';

import './call-footer.scss';

type Props = {
    toggleVoice: (mute: boolean) => void,
    toggleVideo: (mute: boolean) => void,
    exitRoom: () => void,
    isVideoCall: boolean,
    isVideoOpen?: boolean,
    isVoiceOpen?: boolean,
    buttonText?: string,
    showScreenShare?: boolean,
    handleScreenShareClick?: () => void,
}

const CallFooter = (props: Props) : JSX.Element => {
    const {
        toggleVoice,
        toggleVideo,
        exitRoom,
        isVideoCall,
        isVideoOpen = true,
        isVoiceOpen = true,
        buttonText = '挂断',
        showScreenShare = false,
        handleScreenShareClick
    } = props;
    const [isOpenMic, setMute] = useState<boolean>(isVoiceOpen);
    const [isOpenCamera, setOpenCamera ] = useState<boolean>(isVideoOpen);
    const [isMuteAll, setMuteAll ] = useState<boolean>(false);

    const handleToggleVideo = () => {
        toggleVideo(isOpenCamera);
        setOpenCamera(!isOpenCamera);
    };

    const handleToggleVoice = () => {
        if(isMuteAll) {
            return message.warning({
                content: "管理员已禁言"
            });
        }
        toggleVoice(isOpenMic);
        setMute(!isOpenMic);
    };

    const muteAllChange = isMute => {
        setMuteAll(isMute);
        if(isMute) {
            toggleVoice(isMute);
            setMute(false);
            message.warning({
                content: "管理员已禁言"
            });
        } else {
            message.warning({
                content: "管理员已解除禁言"
            });
        }
    }

    useEffect(() => {
        event.on('muteAllChange', muteAllChange)
    }, []);

    return (
        <div className="call-footer">
            <div className="call-footer__control-btn">
                <span className={`voice ${isOpenMic ? 'is-active' : '' }`} onClick={debounce(handleToggleVoice, 300)}></span>
                {
                    isVideoCall && <span className={`video ${!isOpenCamera ? 'is-active' : '' }`} onClick={debounce(handleToggleVideo, 300)}></span>
                }
                {   showScreenShare && <span className='screen-share' onClick={debounce(handleScreenShareClick, 300)}></span> }
            </div>
            <div className="call-footer__end-btn">
                <button onClick={exitRoom}>{buttonText}</button>
            </div>
        </div>
    )
};

const shouldRender = (prevProps, nextProps) => {
    return prevProps.isStart === nextProps.isStart &&
     prevProps.buttonText === nextProps.buttonText &&
     prevProps.isVideoOpen === nextProps.isVideoOpen &&
     prevProps.isVoiceOpen === nextProps.isVoiceOpen &&
     prevProps.isVideoCall === nextProps.isVideoCall &&
     prevProps.showScreenShare === nextProps.showScreenShare
}

export default React.memo(CallFooter, shouldRender);