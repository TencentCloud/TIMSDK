import React, { useState } from 'react';
import GroupVideoItem from './GroupVideoItem';

export const GroupVideoCall = ({groupSplit, setRef}) => {
    const [currentPage, setCurrentPage] = useState(0);
    const shouldShowPrevButton = currentPage >= 1;
    const shouldShowNextButton = groupSplit.length > 1 && currentPage < groupSplit.length - 1;

    const cacluateStyle = () => {
        const haveMultiPage = groupSplit.length > 1;
        const count = groupSplit[currentPage]?.length;
        if(haveMultiPage) {
            return {
                width: '33.3%',
                height: '33.3%'
            }
        } 

        if (count === 1) {
            return {
                width: '100%',
                height: '100%'
            }
        }

        if (count <= 2) {
            return {
                width: '50%',
                height: '100%'
            }
        }

        if (count <= 4) {
            return {
                width: '50%',
                height: '50%'
            }
        }

        if (count <= 6) {
            return {
                width: '33.3%',
                height: '50%'
            }
        }

        return {
            width: '33.3%',
            height: '33.3%'
        }

    };

    const handlePagePrev = () => setCurrentPage(prev => prev - 1);

    const handlePageNext = () => setCurrentPage(next => next + 1);

    const cacluatePageStyle = (index) => ({ display: index === currentPage ? 'flex' : 'none' });
    return <React.Fragment>
        {
            groupSplit.length > 0 && groupSplit.map((item, index) => {
                return <div className="group-video-content__page" style={cacluatePageStyle(index)} key={index}>
                    {
                        item.map((itemInfo) => {
                            const {userId, isEntering, isMicOpen, isSpeaking, order, user_profile_face_url, user_profile_nick_name, user_profile_identifier} = itemInfo;
                            const displayName = user_profile_nick_name || user_profile_identifier;
                            const hasFaceUrl = !user_profile_face_url;
                            return <div key={userId} className={`group-video-content__page-item ${isSpeaking ? 'is-speaking' : ''}`} style={{...cacluateStyle(), backgroundImage: `url(${user_profile_face_url})`, order}}>
                                <GroupVideoItem isMicAvailable={isMicOpen} isEntering={isEntering} setRef={setRef} userId={userId} userNickName={displayName} hasFaceUrl={hasFaceUrl} />
                            </div>
                        })
                    }
                </div>
            })
        }
        {
            shouldShowPrevButton && <span className="prev-button" onClick={handlePagePrev} />
        }
        {
            shouldShowNextButton && <span className="next-button" onClick={handlePageNext} />
        }
    </React.Fragment>
}