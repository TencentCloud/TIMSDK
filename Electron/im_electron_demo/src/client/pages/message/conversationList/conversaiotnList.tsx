import React, { useEffect, useState } from "react"
import { useDispatch, useSelector } from "react-redux";
import { Avatar } from "../../../components/avatar/avatar";
import { EmptyResult } from "../../../components/emptyResult";
import timeFormat from '../../../utils/timeFormat';
import {
    Menu,
    Item,
    contextMenu,
    theme,
    animation
} from 'react-contexify';
import 'react-contexify/dist/ReactContexify.min.css';
import { getConversionList, markMessageAsRead, TIMConvDelete, TIMConvPinConversation, TIMMsgClearHistoryMessage, TIMMsgSetC2CReceiveMessageOpt, TIMMsgSetGroupReceiveMessageOpt } from "../../../api";
import useDynamicRef from "../../../utils/react-use/useDynamicRef";
import { addMessage } from "../../../store/actions/message";
import { replaceConversaionList, updateCurrentSelectedConversation, updateLoadingConversation } from "../../../store/actions/conversation";
import { Myloader } from "../../../components/skeleton";
import { replaceRouter } from "../../../store/actions/ui";
import timRenderInstance from "../../../utils/timRenderInstance";

export const ConversationList = (): JSX.Element => {
    const convMenuID = "CONV_HANDLE"
    const convMenuItem = [
        {
            id: "pinged",
            text: "会话置顶"
        },
        {
            id: "unpinged",
            text: "取消置顶"
        },
        {
            id: "disable",
            text: "消息免打扰"
        },
        {
            id: "mark",
            text: "标记为已读"
        },
        {
            id: "undisable",
            text: "移除消息免打扰"
        },
        {
            id: "remove",
            text: "移除会话"
        },
        {
            id: "clean",
            text: "清除消息"
        }
    ]
    const [setRef, getRef] = useDynamicRef<HTMLDivElement>();
    const dispatch = useDispatch();
    const [isLoading, setLoadingStatus] = useState(false);
    const { conversationList, currentSelectedConversation } = useSelector((state: State.RootState) => state.conversation);
    const { replace_router } = useSelector((state: State.RootState) => state.ui)

    const getDisplayUnread = (count) => {
        return count > 99 ? '···' : count
    }
    const getLastMsgInfo = (lastMsg: State.message, conv_type, conv_group_at_info_array) => {
        const { message_elem_array, message_status, message_is_from_self, message_sender_profile, message_is_peer_read, message_is_read, message_conv_type } = lastMsg;
        const { user_profile_nick_name } = message_sender_profile;
        const revokedPerson = message_is_from_self ? '你' : user_profile_nick_name;
        const firstMsg = message_elem_array[0] || {};
        const revokeMsg = `${revokedPerson} 撤回了一条消息`;
        const displayTextMsg = firstMsg && firstMsg.text_elem_content;
        const displayLastMsg = {
            '0': displayTextMsg,
            '1': '[图片]',
            '2': '[声音]',
            '3': '[自定义消息]',
            '4': '[文件消息]',
            '5': '[群组系统消息]',
            '6': '[表情消息]',
            '7': '[位置消息]',
            '8': '[群组系统通知]',
            '9': '[视频消息]',
            '10': '[关系]',
            '11': '[资料]',
            '12': '[合并消息]',
        }[firstMsg.elem_type];
        const hasAtMessage = conv_group_at_info_array && conv_group_at_info_array.length;
        let atDisPlayMessage = ""
        if(hasAtMessage){
            const lastAt = conv_group_at_info_array[conv_group_at_info_array.length-1]
            if(lastAt.conv_group_at_info_at_type === 1){
                atDisPlayMessage = "@我"
            }else {
                atDisPlayMessage = "@所有人"
            }
        }
        // const isRead = message_is_from_self && message_is_peer_read || !message_is_from_self && message_is_read
        return <React.Fragment>

            {/* {
                message_conv_type === 1 ? <span className={`icon ${isRead ? 'is-read' : ''}`} /> : null
            } */}
            {
                conv_type && hasAtMessage ? <span className="at-msg">{atDisPlayMessage}</span> : null
            }
            <span className="text">{message_status === 6 ? revokeMsg : displayLastMsg}</span>
        </React.Fragment>;
    }

    const getDraftMsg = (draftMsg : {
        draft_msg: State.message;
        draft_user_define: String;
        draft_edit_time: number;
    }) => {
        const getMsg = (message) => {
            const displayTextMsg = message && message.text_elem_content;
            const displayLastMsg = {
                '0': displayTextMsg,
                '1': '[图片]',
                '2': '[声音]',
                '3': '[自定义消息]',
                '4': '[文件消息]',
                '5': '[群组系统消息]',
                '6': '[表情消息]',
                '7': '[位置消息]',
                '8': '[群组系统通知]',
                '9': '[视频消息]',
                '10': '[关系]',
                '11': '[资料]',
                '12': '[合并消息]',
            }[message.elem_type];
            return displayLastMsg;
        }
        
        const displayedText = draftMsg.draft_msg?.message_elem_array.map(item => getMsg(item)).join("");
        
        return <React.Fragment>
            <span className="at-msg">[草稿]&nbsp;</span>
            <span className="text">{displayedText}</span>
        </React.Fragment>;
    };

   const markMessageAsRead = (data:State.conversationItem)=>{
    const { conv_id, conv_type } = data;
        timRenderInstance.TIMMsgReportReaded({
            conv_id,
            conv_type,
        })
    }
    const handleClickMenuItem = (e, id) => {
        const { data } = e.props;
        switch (id) {
            case 'pinged':
                pingConv(data, true);
                break;
            case 'unpinged':
                pingConv(data, false);
                break;
            case 'remove':
                removeConv(data);
                break;
            case 'clean':
                cleanMessage(data);
                break;
            case 'disable':
                disableRecMsg(data, true);
                break;
            case 'undisable':
                disableRecMsg(data, false);
                break;
            case 'mark':
                markMessageAsRead(data);
                break;

        }
    }

    const getData = async () => {
        const response = await getConversionList();
        const formatedConv = response.filter(item => !item.conv_id.includes('meeting-group'));
        setLoadingStatus(false);
        dispatch(replaceConversaionList(formatedConv));
        dispatch(updateLoadingConversation({
            isLoading: false
        }));
        if (formatedConv.length) {
            if (currentSelectedConversation === null) {
                dispatch(updateCurrentSelectedConversation(formatedConv[0]))
            }
        } else {
            dispatch(updateCurrentSelectedConversation(null))
        }
    }
    const pingConv = (conv: State.conversationItem, isPinned: boolean) => {
        const { conv_id, conv_type, conv_is_pinned } = conv
        if (conv_is_pinned === isPinned) {
            if (isPinned) {
                console.log('会话已置顶')
                return;
            } else {
                console.log('会话未置顶')
                return
            }
        }
        TIMConvPinConversation(conv_id, conv_type, isPinned).then(data => {
            const { code } = data.data || {}
            if (code === 0) {
                console.log(!isPinned ? '取消置顶成功' : '置顶成功')
                getData()
            }
        }).catch(err => {

        })
    }

    const removeConv = (conv: State.conversationItem) => {
        const { conv_id, conv_type } = conv
        TIMConvDelete(conv_id, conv_type).then(data => {
            const { code } = data.data || {}
            if (code === 0) {
                console.log('删除会话成功')
                getData()
            }
        }).catch(err => {

        })
    }
    const cleanMessage = (conv: State.conversationItem) => {
        const { conv_id, conv_type } = conv
        TIMMsgClearHistoryMessage(conv_id, conv_type).then(data => {
            const { code } = data.data || {}
            if (code === 0) {
                console.log('删除消息成功')
                getData()
                // 清空消息
                dispatch(addMessage({
                    convId: conv_id,
                    messages: []
                }))
            }
        }).catch(err => {

        })
    }
    const handleContextMenuEvent = (e, conv: State.conversationItem) => {
        e.preventDefault()
        contextMenu.show({
            id: convMenuID,
            event: e,
            props: {
                data: conv
            }
        })
    }
    const handleConvListClick = convInfo => dispatch(updateCurrentSelectedConversation(convInfo));

    const disableRecMsg = async (conv: State.conversationItem, isDisable: boolean) => {
        const { conv_type, conv_id } = conv;
        let data;
        if (conv_type === 1) {
            data = await TIMMsgSetC2CReceiveMessageOpt(conv_id, isDisable ? 1 : 0)
        }
        if (conv_type === 2) {
            data = await TIMMsgSetGroupReceiveMessageOpt(conv_id, isDisable ? 1 : 0)
        }
        console.log(data)
    }

    useEffect(() => {
        if (currentSelectedConversation?.conv_id) {
            const ref = getRef(currentSelectedConversation.conv_id);
            // @ts-ignore
            ref?.current?.scrollIntoViewIfNeeded();
        }
    }, [currentSelectedConversation]);

    useEffect(() => {
        if (!replace_router) {
            conversationList.length === 0 && setLoadingStatus(true);
            getData();
        } else {
            dispatch(replaceRouter(false))
        }

    }, []);
    useEffect(() => {
        if (conversationList.length) {
            if (currentSelectedConversation !== null) {
                if ((conversationList.filter(item => item.conv_id == currentSelectedConversation.conv_id).length <= 0)) {
                    dispatch(updateCurrentSelectedConversation(conversationList[0]));
                } else {
                    const currentSelectedConvId = currentSelectedConversation.conv_id;
                    const currentSelectedConvsation = conversationList.find(item => item.conv_id === currentSelectedConvId);
                    dispatch(updateCurrentSelectedConversation(currentSelectedConvsation));
                }
            }
        }
    }, [conversationList])

    if (isLoading) {
        return <Myloader />
    }
    return (
        <div className="conversion-list">
            <EmptyResult isEmpty={conversationList.length === 0} contentText="暂无会话">
                {
                    conversationList.map((item) => {
                        const { conv_profile, conv_id, conv_last_msg, conv_unread_num, conv_type, conv_is_pinned, conv_group_at_info_array, conv_recv_opt, conv_is_has_draft, conv_draft } = item;
                        const faceUrl = conv_profile.user_profile_face_url ?? conv_profile.group_detial_info_face_url;
                        const nickName = conv_profile.user_profile_nick_name ?? conv_profile.group_detial_info_group_name;
                        return (
                            <div ref={setRef(conv_id)} className={`conversion-list__item ${conv_id === currentSelectedConversation?.conv_id ? 'is-active' : ''} ${conv_is_pinned ? 'is-pinned' : ''}`} key={conv_id} onClick={() => handleConvListClick(item)} onContextMenu={(e) => { handleContextMenuEvent(e, item) }}>
                                <div className="conversion-list__item--profile">
                                    {
                                        conv_unread_num > 0 ? <div className="conversion-list__item--profile___unread">{getDisplayUnread(conv_unread_num)}</div> : null
                                    }
                                    <Avatar url={faceUrl} nickName={nickName} userID={conv_id} groupID={conv_id} size='small' />

                                </div>
                                <div className="conversion-list__item--info">
                                    <div className="conversion-list__item--time-wrapper">
                                        <span className="conversion-list__item--nick-name">{nickName || conv_id}</span>
                                        {
                                            conv_last_msg && <span className="conversion-list__item--format-time">{timeFormat((conv_last_msg.message_server_time === 0 ? conv_last_msg.message_client_time : conv_last_msg.message_server_time) * 1000, false)}</span>
                                        }
                                    </div>
                                    {
                                         (conv_last_msg && conv_last_msg.message_elem_array || conv_is_has_draft)  ? <div className="conversion-list__item--last-message">{conv_is_has_draft ? getDraftMsg(conv_draft) : getLastMsgInfo(conv_last_msg, conv_type, conv_group_at_info_array)}</div> : null
                                    }
                                </div>
                                <span className="pinned-tag"></span>
                                {
                                    conv_recv_opt === 1 ? <span className="mute"></span> : null
                                }
                            </div>
                        )
                    })
                }
            </EmptyResult>
            <Menu
                id={convMenuID}
                theme={theme.light}
                animation={animation.fade}
                onShown={() => console.log('SHOWN')}
                onHidden={() => console.log('HIDDEN')}
            >
                {
                    convMenuItem.map(({ text, id }) => {
                        return <Item key={id} onClick={(e) => { handleClickMenuItem(e, id) }}>{text}</Item>
                    })
                }
            </Menu>
        </div>
    )
}