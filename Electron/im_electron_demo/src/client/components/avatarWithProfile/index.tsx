import React, { useState, useRef } from 'react';
import { Avatar}  from '../avatar/avatar';
import { ProfilePannel } from '../profilePannel';

import "./index.scss";

type Props = {
    profile: State.userInfo
}

export const AvatarWithProfile = (props: Props): JSX.Element => {
    const { profile } = props;
    const { userId, faceUrl, nickName } = profile;
    const avatarRef = useRef<HTMLDivElement>();

    const [showProfile, setShowProfile] = useState(false);

    const cacluatePanelStyle = () => {
        if(avatarRef?.current) {
            const { x, y, width } = avatarRef.current.getBoundingClientRect();
            const windowWidth = window.innerWidth;
            const windowHeight = window.innerHeight;
            const isCanShowRight = windowWidth - (x + width + 20) > 274;
            const isCanShowBottom = windowHeight - y > 312;
            const offsetBottom = windowHeight - y - 312;
            const offsetTop = isCanShowBottom ? y : y + offsetBottom - 10;
            const offsetLeft = isCanShowRight ? x + width + 20 : x - 274 - 20;
            return {
                top: offsetTop,
                left: offsetLeft,
            }
        }
        return {}
    }

    const showUserProfile = (e)=> {
        setShowProfile(!showProfile)
    }

    return (
        <div className="avatar-profile" onClick={showUserProfile}>
            <div ref={avatarRef}>
                <Avatar
                    url={faceUrl}
                    nickName={nickName}
                    userID={userId}
                />
            </div>
            <div className="avatar-profile__profile-pannel" style={cacluatePanelStyle()}>
                {
                    showProfile && <ProfilePannel profile={profile} callback={()=>{setShowProfile(false)}}/>
                }
            </div>
            
        </div>
    )
}