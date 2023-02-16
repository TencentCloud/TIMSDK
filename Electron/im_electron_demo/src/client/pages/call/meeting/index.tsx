import React, { useEffect, useState } from 'react';
import { message } from 'tea-component';

import { MeetingHeader  } from "./MeetingHeader";
import { MeetingContent } from "./MeetingContent";
import { MeetingFooter } from "./MeetingFooter";
import { MeetingMemberList } from "./MeetingMemberList";
import { getGroupInfoList } from "../../../api";
import { generateGroupId } from "../../meeting/meeting-util";
import { LoadingContainer } from "../../../components/loadingContainer"
import timRenderInstance from '../../../utils/timRenderInstance';
import './index.scss';

type Props = {
    roomId: number;
    isVideoOpen: boolean;
    isVoiceOpen: boolean;
    userSig: string;
    sdkAppid: number;
    userId: string;
}

export const Meeting = (props: Props) => {
    const { roomId, isVideoOpen, isVoiceOpen, userId} = props;
    const [ isLoading, setLoading ] = useState(true);
    const [ groupInfo, setGroupInfo ] = useState({
        groupOwner: '',
        groupName: ''
    });
    const groupId = generateGroupId(roomId);

    useEffect(() => {
        const getGroupInfo = async () => {
            const groupInfo = await getGroupInfoList([groupId]);
            setGroupInfo({
                groupOwner: groupInfo[0].group_detial_info_owener_identifier,
                groupName: groupInfo[0].group_base_info_group_name
            });
            setLoading(false);
        };
        getGroupInfo();

        timRenderInstance.TIMSetGroupTipsEventCallback({
            callback:(args)=>{
                groupInfoChangeCallback(JSON.parse(args[0]))
            },
            user_data: "test"
        });
    }, []);

    const groupInfoChangeCallback = (data) => {
        const { group_tips_elem_group_id = "", group_tips_elem_group_change_info_array = [], group_tips_elem_changed_group_memberinfo_array = [] } = data;
        const { group_tips_group_change_info_flag = 0,  group_tips_group_change_info_value = ""} = group_tips_elem_group_change_info_array[0];
        const isOwnerChange = group_tips_elem_group_id.includes('meeting-group') && group_tips_group_change_info_flag === 5;
        const { group_member_info_nick_name , group_member_info_identifier } = group_tips_elem_changed_group_memberinfo_array[0]
        if(isOwnerChange) {
            setGroupInfo(prev => ({
                ...prev,
                groupOwner: group_tips_group_change_info_value
            }));
            if(group_tips_group_change_info_value === userId) {
                message.success({
                    content: '您成为新的主持人'
                });
            } else {
                message.success({
                    content: `${group_member_info_nick_name || group_member_info_identifier} 成为新的主持人`
                })
            }
        }
    }
    return (
        <React.Fragment>
            {
                isLoading ?
                <LoadingContainer loading={true} style={{height:'100vh'}}>{}</LoadingContainer>
                :
                <div className="meeting">
                    <MeetingHeader roomId={roomId} groupName={groupInfo.groupName} />
                    <div className="meeting-body">
                        <div className="meeting-left">
                            <MeetingContent {...props} />
                            <MeetingFooter userId={userId} groupId={groupId} groupOwner={groupInfo.groupOwner} isGroupOwner={groupInfo.groupOwner === userId} isVideoOpen={isVideoOpen} isVoiceOpen={isVoiceOpen} />
                        </div>
                        <MeetingMemberList userId={userId} groupId={groupId} groupOwner={groupInfo.groupOwner} />
                    </div>
                </div>
            }
        </React.Fragment>
    )
};