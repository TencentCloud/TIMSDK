import React, { useEffect, useState } from 'react';
import { TextArea, Button, message } from 'tea-component';
import timRenderInstance from '../../../utils/timRenderInstance';
import { sendMsg } from "../../../api";
import event from '../event';
import trtcInstance from '../../../utils/trtcInstance';

export const MeetingChat = ({groupId, userId}) => {
    const [text, setText] = useState("");
    const [messageList, setMessageList] = useState([]);

    useEffect(() => {
        timRenderInstance.TIMAddRecvNewMsgCallback({
            callback:(args)=>{
                reciveNewMsgCallback(JSON.parse(args[0]))
            },
            user_data: "test"
        });
    }, []);

    const reciveNewMsgCallback = (data) => {
        const messageInfo = data.find(item => item.message_conv_id === groupId);
        const { message_elem_array } = messageInfo || {};
        const isCustomMsg = message_elem_array[0]?.elem_type === 3;
        if(isCustomMsg) {
            const { muteAll, endMeeting } = JSON.parse(message_elem_array[0].custom_elem_data);
            if(endMeeting) {
                message.warning({
                    content: "主持人已结束会议"
                });
                setTimeout(() => {
                    trtcInstance.exitRoom();
                }, 300)
            } else {
                event.emit('muteAllChange', muteAll);
            }
        } else {
            messageInfo && setMessageList(prev => [...prev, messageInfo].reverse());
        }
    }

    const handleSendMsg = async () => {
        setText("");
        const { data: messageId } = await sendMsg({
            convId: groupId,
            convType: 2,
            messageElementArray: [{
                elem_type: 0,
                text_elem_content: text
            }],
            userId,
            callback: sendMsgSuccessCallback
        });
    }

    const sendMsgSuccessCallback = ([res, userData]) => {
        const { code, json_params, desc } = res;
        if (code === 0) {                
            setMessageList(prev => [...prev, JSON.parse(json_params)].reverse())
        }
    };

    const handleOnkeyDown = (e) => {
        if(e.keyCode === 13 || e.charCode === 13) {
            e.preventDefault();
            if(text !== '') {
                handleSendMsg();
            }
        }
    }

    return (
        <div className="meeting-chat">
            <div className="meeting-chat__content customize-scroll-style">
                {
                    messageList.length > 0 && messageList.map(item => {
                        const { message_is_from_self, message_msg_id, message_elem_array, message_sender_profile } = item;
                        return message_elem_array.map(message => {
                            if(message.elem_type !== 0) {
                                return null
                            }

                            return (<div className="meeting-chat__item" key={message_msg_id}>
                                <span className={`meeting-chat__item-name ${message_is_from_self ? 'is-self' : ''}`}>
                                    { message_sender_profile.user_profile_nick_name }:
                                </span>
                                <span className="meeting-chat__item-text">
                                    {message.text_elem_content}
                                </span>
                            </div>)
                        })
                    })
                }
            </div>
            <div onKeyDown={handleOnkeyDown}>
                <TextArea
                    showCount={false}
                    size='full'
                    value={text}
                    onChange={(value, context) => {
                        setText(value);
                    }}
                    placeholder="请输入消息..."
                />
                <Button onClick={handleSendMsg} disabled={text === ''} className="send-btn" type="primary">发送</Button>
            </div>
        </div>
    )
};