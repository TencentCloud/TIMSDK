import React, { useEffect, useRef, useState } from "react"
import { useDispatch, useSelector } from "react-redux";
import { message } from "tea-component";
import timRenderInstance from "../../../utils/timRenderInstance";
import trtcCheck from '../../../utils/trtcCheck';
import { generateRoomID } from "../../../utils/tools";
import { updateCallingStatus } from "../../../store/actions/ui";
import { getGroupMemberList, getUserInfoList } from "../../../api";
import { openCallWindow } from '../../../utils/callWindowTools';
import { MessageInput } from "./MessageInput";
import { GroupMemberSelector } from "./groupMemberSelector";
type Info = {
    faceUrl: string;
    nickName: string;
    id: string;
};

export const ConversationMessageInput = (props: { currentSelectedConversation }): JSX.Element => {
    const { currentSelectedConversation } = props;
    const { conv_id: convId,  conv_type:convType, conv_profile:convProfile, conv_draft: draftMsg } = currentSelectedConversation;
    const { callingStatus: { callingId, callingType } } = useSelector(
        (state: State.RootState) => state.ui
    );
    const { userId, userSig } = useSelector((state: State.RootState) => state.userInfo)
    const groupMemberSelectorRef = useRef(null)
    const [callInfo, setCallInfo] = useState({
        callType: 0,
        convType: 0
    })
    const dispatch = useDispatch();
    const handleOpenCallWindow = async (callType, convType) => {
        if (callingId) {
            message.warning({ content: '正在通话中' });
            return;
        }

        if (!trtcCheck.isCameraReady() && !trtcCheck.isMicReady()) {
            message.warning({ content: '找不到可用的摄像头和麦克风。请安装摄像头和麦克风后再试' });
            return;
        }

        setCallInfo({
            callType,
            convType
        })
    }
    const isShutUpAll = convType === 2 && convProfile?.group_detial_info_is_shutup_all;
    const getDisplayConvInfo = () => {
        const info: Info = {
            faceUrl: "",
            nickName: "",
            id: "",
        };

        if (convType === 1) {
            info.faceUrl = currentSelectedConversation?.conv_profile?.user_profile_face_url;
            info.nickName = currentSelectedConversation.conv_profile.user_profile_nick_name;
            info.id = currentSelectedConversation.conv_profile.user_profile_identifier;
        }

        if (convType === 2) {
            info.faceUrl = currentSelectedConversation?.conv_profile?.group_detial_info_face_url;
            info.nickName = currentSelectedConversation?.conv_profile?.group_detial_info_group_name;
            info.id = currentSelectedConversation.conv_profile.group_detial_info_group_id;
        }
        return info;
    };
    const inviteC2C = async () => {
        const roomId = generateRoomID();
        const { callType } = callInfo
        const data = await timRenderInstance.TIMInvite({
            userID: convId,
            senderID: userId,
            data: JSON.stringify({ "businessID": "av_call", "call_type": Number(callType), "room_id": roomId, "version": 4 })
        })
        const { data: { code, json_params } } = data;
        if (code === 0) {
            const customerData = JSON.parse(json_params)?.message_elem_array[0].custom_elem_data;
            const inviteId = JSON.parse(customerData)?.inviteID;
            openLocalCallWindow(callType, roomId, [convId], inviteId)
        }
    }
    const openLocalCallWindow = async (callType, roomId, userList, inviteId) => {
        dispatch(updateCallingStatus({
            callingId: convId,
            callingType: convType,
            inviteeList: [userId, ...userList],
            callType: callType
        }));
        const { faceUrl, nickName, id } = getDisplayConvInfo();
        const inviteListWithInfo = await getUserInfoList([userId, ...userList]);
        openCallWindow({
            windowType: 'callWindow',
            callType,
            convId: convId,
            convInfo: {
                faceUrl: faceUrl,
                nickName: nickName,
                convType: convType,
                id: id
            },
            roomId,
            inviteID: inviteId,
            userID: userId,
            userSig: userSig,
            inviteList: [userId, ...userList],
            inviteListWithInfo,
            isInviter: true,
        });
    }
    const openGroupMemberSelector = async () => {
        const { group_get_memeber_info_list_result_info_array } = await getGroupMemberList({
            groupId: convId,
            nextSeq: 0,
        })
        groupMemberSelectorRef.current.open({
            groupId: convId,
            userList: group_get_memeber_info_list_result_info_array.filter(item => item.group_member_info_identifier !== userId)
        })
    }
    const inviteInGourp = async (groupMember) => {
        const { callType } = callInfo
        const roomId = generateRoomID();
        console.log('roomId', roomId)
        const userList = groupMember.map((v) => v.group_member_info_identifier)
        const data = await timRenderInstance.TIMInviteInGroup({
            userIDs: userList,
            groupID: convId,
            senderID: userId,
            data: JSON.stringify({ "businessID": "av_call", "call_type": Number(callType), "room_id": roomId, "version": 4 }),
        });
        const { data: { code, json_params } } = data;
        if (code === 0) {
            const customerData = JSON.parse(json_params)?.message_elem_array[0].custom_elem_data;
            const inviteId = JSON.parse(customerData)?.inviteID;
            openLocalCallWindow(callType, roomId, userList, inviteId)
        }
    }
    useEffect(() => {
        const { callType, convType } = callInfo
        if (callType !== 0 && convType !== 0) {
            if (convType == 1) {
                inviteC2C()
            } else if (convType === 2) {
                openGroupMemberSelector()
            }
        }
    }, [callInfo])
    return (
        <div className="message-info-view__content--input">
            <MessageInput
                convId={convId}
                convType={convType}
                isShutUpAll={isShutUpAll}
                draftMsg = {draftMsg}
                handleOpenCallWindow={handleOpenCallWindow}
            />
            <GroupMemberSelector dialogRef={groupMemberSelectorRef}
                onSuccess={(data) => {
                    inviteInGourp(data)
                }} />
        </div>
    )
}