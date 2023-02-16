import React, { Fragment, useEffect, useRef, useState } from "react";
// import { message } from 'tea-component';

// import { Avatar } from "../../../components/avatar/avatar";
// import { getGroupMemberList, getMsgList, markMessageAsRead, getUserInfoList } from "../api";
// import { MessageInput } from "../MessageInput";
// import { MessageView } from "../MessageView";

import "../scss/message-info.scss";
import { useDispatch } from "react-redux";
import {
    changeDrawersVisible,
    changeToolsTab,
} from "../../../store/actions/groupDrawer";
import { GroupToolBar } from "./GroupToolBar";
import { ConversationContentHeader } from "./conversationContentHeader";
import { HistoryMessageList } from "./historyList";
import { ConversationMessageInput } from "./conversaionMessageInput";


export const ConversationContent = (props: {
    currentSelectedConversation
}): JSX.Element => {

    const { currentSelectedConversation } = props

    const dispatch = useDispatch();
    const { conv_type } = currentSelectedConversation || {};


    // 设置群信息相关
    const handleClick = (id: string) => dispatch(changeToolsTab(id));

    const handleShow = () => dispatch(changeDrawersVisible(true));
    const handleClose = () => dispatch(changeDrawersVisible(false));


    return (
        <Fragment>
            <div className="message-info-view" id="messageInfo">
                <ConversationContentHeader currentSelectedConversation={currentSelectedConversation} />
                <section className="message-info-view__content">
                    {/* 历史消息 */}
                    <HistoryMessageList currentSelectedConversation={currentSelectedConversation} />
                    {/* 输入框 */}
                    <ConversationMessageInput currentSelectedConversation={currentSelectedConversation} />
                </section>
            </div>
            {/* 群组快捷操作面板 */}
            {conv_type === 2 ? (
                <GroupToolBar
                    onActive={handleClick}
                    onShow={handleShow}
                    onClose={handleClose}
                />
            ) : null}

        </Fragment>
    );
};