import React, { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { addMoreMessage } from '../../../store/actions/message';
import { addTimeDivider } from '../../../utils/addTimeDivider';
import { findMsg, getMsgList} from '../../../api'
import { displayDiffMessage } from '../conversationContent/MessageView';
import withMemo from '../../../utils/componentWithMemo';
import { message } from 'tea-component';

let shouldScrollMsg;

const ReplyElem = (props: any) : JSX.Element => {
    const { originalMsg, getRef, convId, convType } = props;
    const {messageReply} = originalMsg;
    const [messageDetail, setMessage] = useState<State.message>();
    const messageList  = useSelector(
        (state: State.RootState) => state.historyMessage.historyMessageList.get(convId)
    );
    const dispatch = useDispatch();

    useEffect(() => {
        const findMessage = async (messageReply) => {
            const res = await findMsg({msgIdArray: [messageReply.messageID]});
            setMessage(res[0]);
        }
        findMessage(messageReply);
    }, [messageReply]);

    const getMsgListBetweenTwoMsg = async (beginMsgId, targetMsgId) => {
        let responseMsgList;
        const messageRes = await getMsgList(convId, convType, beginMsgId, true, 20);
        responseMsgList = messageRes;
        const index = messageRes.findIndex(item => item.message_msg_id === targetMsgId);
        if (index !== -1 ) {
            return responseMsgList.splice(0, index);
        } else {
          const res = await getMsgListBetweenTwoMsg(messageRes[messageRes.length -1].message_msg_id, targetMsgId);
          return [...responseMsgList, ...res];
        }
    }

    const scrollToDomPostion = (ref) => {
        const dom = ref.current;
        dom.scrollIntoView({ behavior: 'smooth', block: 'center' });
        dom.classList.add('shrink-style');
        setTimeout(() => 
        {
            dom.classList.remove('shrink-style');
        }, 2000);
    }

    const hanldeItemClick = async () => {
        if(messageDetail) {
            const ref = getRef(messageDetail.message_msg_id);
            if(ref?.current) {
                scrollToDomPostion(ref);
            } else {
                const messageListWithoutTimeDivider = messageList.filter(item => !item.isTimeDivider);
                const beginMsgId = messageDetail.message_msg_id;
                const targetMsgId = messageListWithoutTimeDivider[messageListWithoutTimeDivider.length -1].message_msg_id;
                const messageRes = await getMsgListBetweenTwoMsg(beginMsgId, targetMsgId);
                const addTimeDividerResponse = addTimeDivider([messageDetail, ...messageRes]);
                const payload = {
                    convId: convId,
                    messages: addTimeDividerResponse.reverse(),
                };
                shouldScrollMsg = true;
                dispatch(addMoreMessage(payload));
            }
        } else {
            message.error({
                content: "无法定位到原消息"
            })
        }
    }

    useEffect(() => {
        if(shouldScrollMsg) {
            const ref = getRef(messageDetail.message_msg_id);
            setTimeout(() => {
                scrollToDomPostion(ref);
            }, 0)
            shouldScrollMsg = false;
        }
    }, [messageList]);

    return <div className='reply-msg-content' >
        <div className='reply-msg-content__sender'>{messageReply.messageSender}:</div>
        <div className='reply-msg-content__content'>{messageDetail ? displayDiffMessage(messageDetail, messageDetail.message_elem_array[0], 0) :  messageReply.messageAbstract}</div>
        <div className='reply-msg-content__mask' onClick={hanldeItemClick}></div> 
    </div>
    
}

export default withMemo(ReplyElem);