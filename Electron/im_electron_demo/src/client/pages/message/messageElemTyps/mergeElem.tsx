import React, { useState, useEffect } from "react";
import { Avatar } from '../../../components/avatar/avatar';
import { Modal } from 'tea-component';
import formateTime from '../../../utils/timeFormat';
import { downloadMergedMsg } from '../../../api';
import { displayDiffMessage } from "../conversationContent/MessageView";
import withMemo from "../../../utils/componentWithMemo";

const MergeElem = (props: any): JSX.Element => {
    const [showModal, setShowModal ] = useState(false);
    const [ mergedMsg, setMergedMsg ] = useState([]); 
    const showMergeDitail = async () => {
        if(props.merge_elem_message_array) {
            setMergedMsg(props.merge_elem_message_array);
        } else {
            const { data: {code, json_params} } = await downloadMergedMsg(props.message);
            const mergedMsg = JSON.parse(json_params);
            setMergedMsg(mergedMsg);
        }
        setShowModal(true);
     }
     

     const handleModalClose = () => {
         setShowModal(false);
     }


    const item = (props) => {
        return (
            <div className="message-view__item--merge right-menu-item" onClick={showMergeDitail} >
                {/* 标题 */}
                <div className="message-view__item--merge___title" >{props.merge_elem_title}</div>
                {/* 消息摘要 */}
                {
                    props.merge_elem_abstract_array && props.merge_elem_abstract_array.map((item, index) => {
                        return <div key={index} className="message-view__item--merge___abst">{item}</div>
                    })
                }
                <Modal 
                    className="message-info-modal" 
                    disableEscape 
                    visible={showModal} 
                    size="85%"
                    onClose={handleModalClose}
                >
                    <Modal.Body>
                        <div>
                            <header className="merge-mesage-header">{props.merge_elem_title}</header>
                            <div className="merge-message-content customize-scroll-style">
                                {
                                    mergedMsg.length > 0 && mergedMsg.reverse().map((item: State.message,index) => {
                                        const previousMessage = mergedMsg[index -1];
                                        const previousMessageSender = previousMessage?.message_sender_profile?.user_profile_identifier;
                                        const { message_sender_profile, message_elem_array, message_client_time } = item;
                                        const { user_profile_face_url, user_profile_nick_name, user_profile_identifier } = message_sender_profile;
                                        const shouldShowAvatar = previousMessageSender !== user_profile_identifier;
                                        const displayText = `${user_profile_nick_name || user_profile_identifier} ${formateTime(message_client_time * 1000, true)}`;

                                        return (
                                            <div key={index} className="merge-message-item">
                                                <div className="message-view__item--avatar face-url">
                                                    {
                                                        shouldShowAvatar && <Avatar url={user_profile_face_url} size="small" nickName={user_profile_nick_name} userID={user_profile_identifier} />
                                                    }
                                                </div>
                                                <div className="merge-message-item__message">
                                                    {shouldShowAvatar &&  <span className="merge-message-item__nick-name">{displayText}</span> }
                                                    {
                                                    message_elem_array && message_elem_array.length && message_elem_array.map((elment, index) => {
                                                        return (
                                                            <div className="message-view__item--element" key={index} >
                                                                {
                                                                    displayDiffMessage(item, elment, index)
                                                                }
                                                            </div>
                                                            )
                                                        })
                                                    }
                                                </div>
                                                
                                            </ div>
                                        )

                                    })
                                }
                            </div>
                        </div>
                    </Modal.Body>
                </Modal>
            </div>
        )
    };
    return item(props);
}

export default withMemo(MergeElem);