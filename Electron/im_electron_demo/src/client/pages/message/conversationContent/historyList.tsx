import React, { useEffect, useState } from "react"
import { useDispatch, useSelector } from "react-redux";
import { addMessage } from "../../../store/actions/message";
import { addTimeDivider } from "../../../utils/addTimeDivider";
import { getMsgList, markMessageAsRead } from "../../../api";
import { MessageView } from "./MessageView"

export const HistoryMessageList = (props:{currentSelectedConversation}): JSX.Element => {
    const { currentSelectedConversation } = props
    const { conv_id: convId,  conv_type:convType, conv_profile:convProfile } = currentSelectedConversation;
    const { historyMessageList } = useSelector(
        (state: State.RootState) => state.historyMessage
    );
    const dispatch = useDispatch();
    const msgList = historyMessageList.get(convId || '');
    const {
        group_detial_info_group_type: groupType,
        group_detial_info_add_option: addOption,
    } = convProfile || {};

    
    const validatelastMessage = (messageList: State.message[]) => {
        let msg: State.message;
        for (let i = 0; i < messageList.length; i++) {
            // 筛选不是自己的且发送成功的消息
            if (
                messageList[i]?.message_msg_id &&
                messageList[i].message_status === 2
            ) {
                // 不能是群系统通知
                // const { elem_type } = messageList[i].message_elem_array[0] || {};
                // if (elem_type != 5 && elem_type != 8) {
                msg = messageList[i];
                break;
                // }
            }
        }
        return msg;
    };
    const getLastMessageId = () => {
        if (!msgList || msgList.length === 0) {
            return "";
        }
        const { message_msg_id } = validatelastMessage(msgList) || {};

        return message_msg_id;
    };
    const lastMessageId = getLastMessageId();
    const setMessageRead = (messageId) => {
        // 个人会话且未读数大于0才设置已读
        const handleMsgReaded = async () => {
            try {
                const { code, ...res } = await markMessageAsRead(
                    convId,
                    convType,
                    messageId
                );

                if (code === 0) {
                    console.log("设置会话已读成功");
                } else {
                    console.log("设置会话已读失败", code, res);
                }
            } catch (err) {
                console.log("设置会话已读失败", err);
            }
        };

        if (currentSelectedConversation.conv_unread_num > 0 && lastMessageId) {
            handleMsgReaded();
        }
    };

    useEffect(() => {
        const getMessageList = async () => {
            const messageResponse = await getMsgList(convId, convType);
            const addTimeDividerResponse = addTimeDivider(messageResponse.reverse());
            const payload = {
                convId: convId,
                messages: addTimeDividerResponse.reverse(),
            };
            dispatch(addMessage(payload));
        };
        if (convId) {
            getMessageList();
        }
    }, [convId]);

    useEffect(() => {
        if (currentSelectedConversation) {
            setMessageRead(lastMessageId);
        }
    }, [currentSelectedConversation?.conv_unread_num, lastMessageId]);
    return (
        <div className="message-info-view__content--view">
            <MessageView groupType={groupType} messageList={msgList || []} convId={convId} />
        </div>
    )
}