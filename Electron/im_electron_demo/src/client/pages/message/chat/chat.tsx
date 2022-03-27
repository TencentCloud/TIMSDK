import React, { Fragment, ReactNode } from "react"
import { useSelector } from "react-redux";
import { ConversationContent } from "../conversationContent/conversationContent";
import { EmptyResult } from "../../../components/emptyResult";
import { MessageLoader } from "../../../components/skeleton";

export const Chat = (): JSX.Element=> {
    const currentSelectedConversation = useSelector((state: State.RootState) => state.conversation.currentSelectedConversation);
    const isLoadingConversation = useSelector((state: State.RootState) => state.conversation.isLoading);
    if(isLoadingConversation) {
        return <MessageLoader />
    }
    const hasConv = !!(currentSelectedConversation && currentSelectedConversation.conv_id);

    return <Fragment>
        <EmptyResult
            isEmpty={!hasConv}
            contentText="暂无历史消息"
        >
            <ConversationContent currentSelectedConversation={currentSelectedConversation} /> 
        </EmptyResult>
    </Fragment>
}