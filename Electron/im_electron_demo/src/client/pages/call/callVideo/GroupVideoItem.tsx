import React from 'react';

type Props = {
    userNickName: string;
    setRef: (userId) => React.RefObject<HTMLDivElement>;
    hasFaceUrl: boolean;
    userId: string;
    isEntering: boolean;
    isMicAvailable: boolean;
}

const GroupVideoItem = (props: Props) => {
    const {setRef, hasFaceUrl, userNickName, userId, isEntering, isMicAvailable } = props;
    console.log('groupVideoitem render');
    return (
        <React.Fragment>
            <div ref={setRef(userId)} style={{ position: 'relative', width: '100%', height: '100%' }}>
                {
                    !isEntering && <span className="group-video-content__page-item--loading">正在等待对方接受邀请...</span>
                }
                {
                    hasFaceUrl && <span>{userNickName}</span>
                }
            </div>
            <span className="group-video-content__page-item--user-id">{userNickName}</span>
            {
                isEntering && <span className={`group-video-content__page-item--mic-status ${!isMicAvailable ? 'not-active' : ''}`} />
            }
        </React.Fragment>
    )
}

const areEqual = (prev, next) => 
     prev.hasFaceUrl === next.hasFaceUrl 
     && prev.userNickName === next.userNickName 
     && prev.userId === next.userId 
     && prev.isEntering === next.isEntering
     && prev.isMicAvailable === next.isMicAvailable

export default React.memo(GroupVideoItem, areEqual)