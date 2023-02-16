import React, { useState, useEffect } from 'react';
import { Button } from 'tea-component';
import { Avatar } from '../avatar/avatar';
import { EmptyResult } from '../emptyResult';
import { useMessageDirect } from '../../utils/react-use/useDirectMsgPage';
import { searchTextMessage } from '../../api';

import './style/message-result.scss';


const catchMessageList = new Map();

export const MessageResult = (props) => {
    const { result, keyWords, onClose } = props;
    const directToConv = useMessageDirect();
    const [activedItem, setActivedItem] = useState(result[0]);
    const regex = new RegExp(keyWords, "g");

    const hilightKeyWords = messageText => messageText.replace(regex, `<span class="highlight">${keyWords}</span>`);

    const handleItemClick = (item) => setActivedItem(item);

    const handleOpenConv = () => {
        directToConv({
            convType: activedItem.conv_type,
            profile: activedItem.conv_profile,
            beforeDirect: onClose
        })
    };

    useEffect(() => {
        setActivedItem(result[0]);
        catchMessageList.clear();
    }, [result]);

    useEffect(() => {
        const getMessageList = async () => {
            if(activedItem && !activedItem.messageArray) {
                const { conv_id, conv_type } = activedItem;
                const catchedElementArray = catchMessageList.get(conv_id);
                if(catchedElementArray) {
                    setActivedItem({
                        ...activedItem,
                        messageArray: catchedElementArray
                    });

                    return;
                }

                const { msg_search_result_item_array } = await searchTextMessage({
                    keyWords,
                    convType: conv_type,
                    convId: conv_id
                });

                const elementArray = msg_search_result_item_array[0].msg_search_result_item_message_array;

                catchMessageList.set(conv_id, elementArray);
                setActivedItem({
                    ...activedItem,
                    messageArray: elementArray
                })
            }
        }

        getMessageList();
    }, [activedItem]);

    return (
        <div className="message-result ">
            <EmptyResult isEmpty={result.length === 0} contentText="没有找到相关结果, 请重新输入">
            <div className="message-result__content">
                    <div className="message-result__content--item-content customize-scroll-style">
                        {
                            result.map((item, index) => {
                                const { conv_profile, conv_id, messageCount } = item;
                                const faceUrl = conv_profile.user_profile_face_url ?? conv_profile.group_detial_info_face_url;
                                const nickName = (conv_profile.user_profile_nick_name ?? conv_profile.group_detial_info_group_name)|| conv_id;
        
                                return (
                                    <div  key={index} className={`message-result__content-item ${activedItem?.conv_id === conv_id ? 'is-active' : ''}`} onClick={() => handleItemClick(item)}>
                                        <Avatar url={faceUrl}></Avatar>
                                        <div className="message-result__content-item--text">
                                            <span className="message-result__content-item--nick-name">{nickName}</span>
                                            <span className="message-result__content-item--msg-text" >{`共${messageCount}条结果`}</span>
                                        </div>
                                    </div>
                                )
                            })
                        }
                    </div>
                    <div className="message-result__content--message-list ">
                        <div className="message-result__content--message-list-content customize-scroll-style">
                            {
                            activedItem?.messageArray?.map((item, index) => {
                                const { message_elem_array, message_sender_profile: { user_profile_face_url, user_profile_nick_name} } = item as State.message;
                                return (
                                    <div key={index} className="message-result__content-item" >
                                            <Avatar url={user_profile_face_url}></Avatar>
                                            <div className="message-result__content-item--text">
                                                <span className="message-result__content-item--nick-name">{user_profile_nick_name}</span>
                                                <span className="message-result__content-item--msg-text" dangerouslySetInnerHTML={{__html: hilightKeyWords( message_elem_array[0].text_elem_content)}} ></span>
                                            </div>
                                        </div>
                                )
                                
                                })
                            }
                        </div>
                        <Button className="message-result__content--button" type="primary" onClick={handleOpenConv}>打开会话</Button>
                    </div>
                </div> 
            </EmptyResult>
        </div>
    )
}