import React, { useEffect, useState } from 'react';
import { Button } from 'tea-component';
import event from '../event';
import { Avatar } from '../../../components/avatar/avatar';
import { MeetingChat } from './MeetingChat';
import trtcInstance from '../../../utils/trtcInstance';
import { sendMsg } from '../../../api';

const Title = ({text}) => (
    <div className="member-list-title">
        {text}
    </div>
)

export const MeetingMemberList = (props) => {
    const { groupOwner, groupId, userId } = props;
    const [memberList, setMemberList] = useState([]);
    const [isMuteAll, setMuteALl ] = useState(false);
    const isAdmain = userId === groupOwner;

    const userListChangeCallback = (data) => {
        setMemberList(data);
    };

    const sendMuteAllMsg = (isMute) => {
        sendMsg({
            convId: groupId,
            convType: 2,
            messageElementArray: [{
                elem_type: 3,
                custom_elem_data: JSON.stringify({
                    muteAll: isMute
                }),
                custom_elem_desc: '',
                custom_elem_ext: '',
                custom_elem_sound: '',
            }],
            userId: userId
        });
    }

    const muteAllRemoteAudio = () => {
        trtcInstance.muteAllRemoteAudio(true);
        sendMuteAllMsg(true);
        setMuteALl(true);
    };

    const openAllRemoteAudio = () => {
        trtcInstance.muteAllRemoteAudio(false);
        sendMuteAllMsg(false);
        setMuteALl(false);
    }

    const getDisplayHeaderText = () => {
        const text = isAdmain ? '管理成员' : '成员';
        return `${text} (${memberList.length})`
    }

    const onRemoteUserEnterRoom = () => {
        if(isMuteAll) {
            sendMuteAllMsg(true);
        }
    };

    useEffect(() => {
        event.on('userListChange', userListChangeCallback);
        trtcInstance.on('onRemoteUserEnterRoom', onRemoteUserEnterRoom);
    }, []);

    return <div className="meeting-member-list">
        <Title text={getDisplayHeaderText()} />
        <div className="meeting-member-list__item-container customize-scroll-style">
            {
                memberList.map(item => {
                    const {userId, isMicOpen, isOpenCamera, isSpeaking, user_profile_face_url, user_profile_nick_name, user_profile_identifier} = item;
                    const isOwner = userId === groupOwner;

                    return <div className="meeting-member-list__item" key={userId}>
                        <div className="wrapper">
                            <Avatar
                                size="small"
                                url={user_profile_face_url}
                                nickName={user_profile_nick_name}
                                userID={userId}
                            />
                            <div className="meeting-member-list__item--text">
                                <span>{user_profile_nick_name}</span>
                                {
                                    isOwner && <span className="owner">主持人</span>
                                }
                            </div>
                        </div>
                        <div className="wrapper">
                            <span className={`meeting-member-list__item--mic ${isMicOpen ? 'mic-open' : ''}`}/>
                            <span className={`meeting-member-list__item--video ${isOpenCamera ? 'video-open' : ''}`} />
                        </div>
                    </div>
                })
            }
        </div>
        {
            isAdmain && <div className="meeting-member-list__mute-btn-group">
                <Button type="weak" onClick={muteAllRemoteAudio}>全员禁言</Button>
                <Button className="open-btn" type="weak" onClick={openAllRemoteAudio}>解除禁言</Button>
            </div>
        }
        <Title text="聊天 " />
        <MeetingChat userId={userId} groupId={groupId} />
    </div>
};