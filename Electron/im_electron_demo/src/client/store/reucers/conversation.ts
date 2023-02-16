import { REPLACE_CONV_LIST, SET_UNREAD_COUNT, UPDATE_CONVERSATIONLIST, UPDATE_CURRENT_SELECTED_CONVERSATION, MARK_CONV_LAST_MSG_IS_READED, CLEAR_CONVERSATION, UPDATE_CONVERSATION_LOADING } from '../actions/conversation';

const initState = {
    unreadCount: 0,
    conversationList:[],
    currentSelectedConversation: null,
    isLoading: true
}
const getTime = (item) => {
    if (item ) {
        const { message_server_time, message_client_time } = item;
        return message_server_time === 0 ? message_client_time : message_server_time;
    }
    return 0;
}


const sortByPindAndTime = (conversationList: Array<State.conversationItem>): Array<State.conversationItem> => {
    const pinnedConversation = conversationList.filter(item => item.conv_is_pinned);
    const normalConversation = conversationList.filter(item => !item.conv_is_pinned);
    const sortPined = pinnedConversation.sort((pre, next) => (next.conv_is_has_draft ? next.conv_draft.draft_edit_time : getTime(next.conv_last_msg))  - (pre.conv_is_has_draft ? pre.conv_draft.draft_edit_time : getTime(pre.conv_last_msg)));
    const sortNormal = normalConversation.sort((pre, next) => (next.conv_is_has_draft ? next.conv_draft.draft_edit_time : getTime(next.conv_last_msg))  - (pre.conv_is_has_draft ? pre.conv_draft.draft_edit_time : getTime(pre.conv_last_msg)));
    return [...sortPined, ...sortNormal];
}

const conversationReducer = (state = initState, action: { type: any; payload: any }) => {
    switch (action.type) {
        case SET_UNREAD_COUNT:
          return {
              ...state,
              unreadCount: action.payload
          }
        case UPDATE_CONVERSATIONLIST: {
            // 会话按是否置顶、时间排序
            const listCopy = [...state.conversationList]
            for(let i = 0;i<action.payload.length;i++){
                const { conv_id } = action.payload[i];
                const conv_index = listCopy.findIndex((item)=>{return item.conv_id === conv_id})
                if(conv_index>-1){
                    console.log('更新会话')
                    // 存在，直接更新
                    listCopy[conv_index] = action.payload[i]
                } else {
                    console.log('添加会话')
                    // 不存在，添加
                    listCopy.unshift(action.payload[i])
                }
                console.log(listCopy.length)
            }
            return {
                ...state,
                conversationList: sortByPindAndTime(listCopy)
            }
        }
        case UPDATE_CURRENT_SELECTED_CONVERSATION:
            return {
                ...state,
                currentSelectedConversation: action.payload
            }
        case REPLACE_CONV_LIST:
            return {
                ...state,
                conversationList: sortByPindAndTime(action.payload)
            }

        case MARK_CONV_LAST_MSG_IS_READED: 
            const catchList = [...state.conversationList];
            const { payload  } = action;
            const convIds = payload.map((element : State.MessageReceipt)  => element.msg_receipt_conv_id);
            catchList.forEach(item => {
                if(convIds.includes(item.conv_id)) {
                    item.conv_last_msg.message_is_peer_read = true;
                }
            })

            return {
                ...state,
                conversationList: catchList
            }
        case CLEAR_CONVERSATION:
            return {
                unreadCount: 0,
                conversationList:[],
                currentSelectedConversation: null,
                isLoading: true
            }
        case UPDATE_CONVERSATION_LOADING:
            return {
                ...state,
                isLoading: action.payload.isLoading
            }
        default:
          return state;
    }
}

export default conversationReducer;