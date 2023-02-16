export const SET_UNREAD_COUNT = 'SET_UNREAD_COUNT';
export const UPDATE_CONVERSATIONLIST = 'UPDATE_CONVERSATIONLIST'
export const UPDATE_CURRENT_SELECTED_CONVERSATION = 'UPDATE_CURRENT_SELECTED_CONVERSATION'
export const REPLACE_CONV_LIST = 'REPLACE_CONV_LIST'
export const MARK_CONV_LAST_MSG_IS_READED = 'MARK_CONV_LAST_MSG_IS_READED'
export const CLEAR_CONVERSATION = 'CLEAR_CONVERSATION'
export const UPDATE_CONVERSATION_LOADING = 'UPDATE_CONVERSATION_LOADING'
export const setUnreadCount = (payload: number) : State.actcionType<number> => ({
    type: SET_UNREAD_COUNT,
    payload
})
export const updateConversationList = (payload:Array<State.conversationItem>):State.actcionType<Array<State.conversationItem>> => ({
    type: UPDATE_CONVERSATIONLIST,
    payload
})


export const updateCurrentSelectedConversation = (payload :State.conversationItem) :State.actcionType<State.conversationItem> => ({
    type: UPDATE_CURRENT_SELECTED_CONVERSATION,
    payload
})

export const replaceConversaionList = (payload:Array<State.conversationItem>):State.actcionType<Array<State.conversationItem>> => ({
    type: REPLACE_CONV_LIST,
    payload
})

export const markConvLastMsgIsReaded = (payload: Array<State.MessageReceipt>) : State.actcionType<Array<State.MessageReceipt>> => ({
    type: MARK_CONV_LAST_MSG_IS_READED,
    payload
})

export const clearConversation = ()  => ({
    type: CLEAR_CONVERSATION,
})

export const updateLoadingConversation = (payload: {isLoading: boolean }) :  State.actcionType<{isLoading: boolean }> => ({
    type: UPDATE_CONVERSATION_LOADING,
    payload,
})