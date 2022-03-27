import { ActionTypeEnum, Action } from "../actions/message";
import { addTimeDivider } from "../../utils/addTimeDivider";

const initState = {
  historyMessageList: new Map(),
  uploadProgressList: new Map(),
  currentReplyUser: null,
  currentReplyMsg: null,
}
const deduplicationMessages = (oldMessages:State.message[],messages:State.message[])=>{
  for(let i = 0;i<messages.length;i++){
    const { message_msg_id } = messages[i]
    for(let j = 0;j<oldMessages.length;j++){
      const {message_msg_id:old_msg_id} = oldMessages[j]
      if(message_msg_id === old_msg_id){
        //同一个消息
        
      }
    }
  }
}

const getBaseTime = messageList => messageList && messageList.length > 0 ?  messageList.find(item => item.isTimeDivider).time : 0;

const messageReducer = (state = initState, action: Action): State.historyMessage => {
  const { type, payload } = action;
  switch (type) {
    case ActionTypeEnum.ADD_MESSAGE: {
      return {
        ...state,
        historyMessageList: state.historyMessageList.set(payload.convId, payload.messages)
      }
    }
    case ActionTypeEnum.ADD_MORE_MESSAGE: {
      const originMessageList = state.historyMessageList.get(payload.convId);
      return {
        ...state,
        historyMessageList: state.historyMessageList.set(payload.convId, originMessageList.concat(payload.messages))
      }
    }
    case ActionTypeEnum.RECI_MESSAGE: {
      const history = state.historyMessageList.get(payload.convId);
      const baseTime =  getBaseTime(history);
      const timeDividerResult = addTimeDivider(payload.messages, baseTime).reverse();
       
      const ret = {
        ...state,
        historyMessageList: state.historyMessageList.set(payload.convId, timeDividerResult.concat(history))
      }
      return ret
    }

    case ActionTypeEnum.MARKE_MESSAGE_AS_REVOKED: {
      const { convId, messageId } = payload;
      const history = state.historyMessageList.get(convId);
      const replacedMessageList = history?.map(item => {
        if(!item || !item.message_msg_id){
          return item
        }
        if (item.message_msg_id === messageId || item.message_unique_id === messageId) {
          return {
            ...item,
            message_status: 6
          }
        }
        return item
      });
      return {
        ...state,
        historyMessageList: state.historyMessageList.set(convId, replacedMessageList)
      }
    }

    case ActionTypeEnum.DELETE_MESSAGE: {
      const { convId, messageIdArray } = payload;
      const history = state.historyMessageList.get(convId);
      const newHistory = history.filter(item => !item.isTimeDivider && !messageIdArray.includes(item.message_msg_id));
      const newHistoryList = addTimeDivider(newHistory.reverse()).reverse();
      return {
        ...state,
        historyMessageList: state.historyMessageList.set(convId, newHistoryList)
      }
    }

    case ActionTypeEnum.MARKE_MESSAGE_AS_READED: {
      const { convIds } = payload;

      convIds.forEach(convId => {
        const messageList = state.historyMessageList.get(convId);
        if (!messageList || messageList.length === 0) {
          return
        }
        messageList.forEach(item => {
          if (item?.message_is_from_self) {
            item.message_is_peer_read = true;
          }
        });
        state.historyMessageList.set(convId, messageList);
      });
      return state;
    }

    case ActionTypeEnum.UPDATE_MESSAGES: {
      let matched = false;
      const oldMessageList = state.historyMessageList.get(payload.convId) || [];
      const newMessageList = oldMessageList.map(oldMessage => {
          if(oldMessage?.message_msg_id && (oldMessage.message_msg_id === payload.message.message_msg_id)) {
            matched = true
            return payload.message
          } else {
            return oldMessage
          }
      });
      if(!matched) {
          const baseTime = getBaseTime(newMessageList);
          const timeDividerResult = addTimeDivider([payload.message], baseTime).reverse();
          newMessageList.unshift(...timeDividerResult);
      }
      
      return {
        ...state,
        historyMessageList: state.historyMessageList.set(payload.convId, newMessageList)
      }
    }

    case ActionTypeEnum.UPDATE_MESSAGE_ELEM_PROGRESS: {
      const { messageId, index, cur_size, total_size } = payload
      return {
        ...state,
        uploadProgressList: state.uploadProgressList.set(`${messageId}_${index}`, {cur_size, total_size})
      }
    }

    case ActionTypeEnum.INIT_MESSAGES: {
      return {
        ...state,
        historyMessageList: action.payload.historyMessage
      }
    }

    case ActionTypeEnum.SET_CURRENT_REPLY_USER: {
      return {
        ...state,
        currentReplyUser: payload.profile
      }
    }
    case ActionTypeEnum.CLEAR_HISTORY:
      return {
        historyMessageList: new Map(),
        uploadProgressList: new Map(),
        currentReplyUser: null,
        currentReplyMsg: null
      }
    case ActionTypeEnum.SET_CURRENT_REPLY_MSG: {
      return {
        ...state,
        currentReplyMsg: payload.message
      }
    }
    default:
      return state;
  }
}

export default messageReducer;