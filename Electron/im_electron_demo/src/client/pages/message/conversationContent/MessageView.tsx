import React, { useState, useRef, useEffect } from 'react';
import { throttle } from 'lodash';
import { useDispatch } from 'react-redux';
import {
    Menu,
    Item,
    contextMenu,
    theme,
    animation
} from 'react-contexify';
import '../scss/message-view.scss';
import { revokeMsg, deleteMsg, sendMsg, getLoginUserID, sendMergeMsg,  getMsgList, deleteMsgList, sendForwardMessage } from '../../../api';
import { markeMessageAsRevoke, deleteMessage, reciMessage,  addMoreMessage, updateMessages } from '../../../store/actions/message';
import { 
    getMessageId,
    getConvId,
    getConvType,
    getMergeMessageTitle,
    getMergeMessageAbstactArray
} from '../../../utils/messageUtils'
import { Avatar } from '../../../components/avatar/avatar';
import { AvatarWithProfile } from '../../../components/avatarWithProfile';
import TextElemItem from '../messageElemTyps/textElemItem';
import PicElemItem  from '../messageElemTyps/picElemItem';
import CustomElem from '../messageElemTyps/customElem';
import VoiceElem from '../messageElemTyps/voiceElem';
import FileElem from '../messageElemTyps/fileElem';
import GroupTipsElemItem from '../messageElemTyps/grouptipsElem';
import  VideoElem from '../messageElemTyps/videoElem';
import MergeElem from '../messageElemTyps/mergeElem';
import { ForwardPopup } from '../components/forwardPopup';
import { Icon, message } from 'tea-component';
import formateTime, { _formatDate} from '../../../utils/timeFormat';
import { addTimeDivider } from '../../../utils/addTimeDivider';
import { HISTORY_MESSAGE_COUNT } from '../../../constants';
import GroupSysElm from '../messageElemTyps/groupSystemElem';
import { setReplyMsg } from '../../../store/actions/message'
import timRenderInstance from '../../../utils/timRenderInstance';
import ReplyElem from '../messageElemTyps/replyElem';
import useDynamicRef from '../../../utils/react-use/useDynamicRef';


const MESSAGE_MENU_ID = 'MESSAGE_MENU_ID';

type Props = {
    messageList: Array<State.message>
    groupType: number;
    convId: string;
}

const RIGHT_CLICK_MENU_LIST = [{
    id: 'revoke',
    text: '撤回'
},
{
    id: 'delete',
    text: '删除'
},
{
    id: 'transimit',
    text: '转发'
},
{
    id: 'reply',
    text: '回复'
},
{
    id: 'multiSelect',
    text: '多选'
}];

enum ForwardType {
    divide,
    combine
}

export const displayDiffMessage = (message, element, index) => {
   
    const { elem_type, ...res } = element;
    let resp
    switch (elem_type) {
        case 0:
            resp = <TextElemItem {...res} />
            break;
        case 1:
            resp = <PicElemItem { ...res }/>
            break;
        case 2:
            resp = <VoiceElem { ...res }/>
            break;
        case 3:
            // @ts-ignore
            resp = <CustomElem message={message}/>
            break;
        case 4:
            // @ts-ignore
            resp = <FileElem message={message} element={element} index={index}/>
            break;
        case 5:
            resp = <GroupTipsElemItem { ...res }/> 
            break;
        case 6:
            resp = <div>表情消息</div>
            break;
        case 7:
            resp = <div>位置消息</div>
            break;
        case 8:
            resp = <GroupSysElm { ...res }/>  
            break;
        case 9:
            resp =  <VideoElem message={message} { ...res }/>
            break;
        case 10:
            resp = <div>关系消息</div>
            break;
        case 11:
            resp = <div>资料消息</div>
            break;
        case 12:
            resp = <MergeElem { ...res } message={message}/>
            break;
        default:
            resp = null;
            break;
    }
    return resp;
}


export const MessageView = (props: Props): JSX.Element => {
    const { messageList, groupType, convId } = props;
    const [currServerTime, setCurServerTime] = useState(0);
    const messageViewRef = useRef(null);
    const [isTransimitPopup, setTransimitPopup] = useState(false);
    const [isMultiSelect, setMultiSelect] = useState(false);
    const [forwardType, setForwardType] = useState<ForwardType>(ForwardType.divide);
    const [seletedMessage, setSeletedMessage] = useState<State.message[]>([]);
    const [noMore,setNoMore] = useState(messageList.length < HISTORY_MESSAGE_COUNT ? true : false)
    const dispatch = useDispatch();
    const [anchor , setAnchor] = useState('');
    const [setRef, getRef] = useDynamicRef<HTMLDivElement>();

    const [rightClickMenuList, setRightClickMenuList] = useState(RIGHT_CLICK_MENU_LIST);
    
    useEffect(() => {
        if(!anchor){
            messageViewRef?.current?.firstChild?.scrollIntoViewIfNeeded?.();
        }
        setAnchor('')
        setNoMore(messageList.length < HISTORY_MESSAGE_COUNT ? true : false)
    }, [messageList.length])

    useEffect(() => {
        setSeletedMessage([]);
        if(isMultiSelect) {
            setMultiSelect(false);
        }
    }, [convId]);

    const handleRevokeMsg = async (params) => {
        const { convId, msgId, convType } = params;
        const code = await revokeMsg({
            convId,
            convType,
            msgId
        });
        if(code === 20016) {
            message.warning({content: '消息超出可撤回时间'})
        }
        code === 0 && dispatch(markeMessageAsRevoke({
            convId,
            messageId: msgId
        }));

    };

    const handleDeleteMsg = async (params) => {
        const { convId, msgId, convType } = params;
        const code = await deleteMsg({
            convId,
            convType,
            msgId
        });
        code === 0 && dispatch(deleteMessage({
            convId,
            messageIdArray: [msgId]
        }));
    };

    const handleTransimitMsg = (params) => {
        console.log(params)
        const { message } = params;
        setTransimitPopup(true)
        setSeletedMessage([message])
    }

    const handleReplyMsg = (params) => {
        const { message } = params;
        dispatch(setReplyMsg({
            message: message
        }));
    }

    const handleForwardPopupSuccess = async (convItemGroup) => {
        const userId = await getLoginUserID();
        const isDivideSending = forwardType === ForwardType.divide;
        const isCombineSending = !isDivideSending;
        const forwardMessage = seletedMessage.map((item) => ({
          ...item,
          message_is_forward_message: true,
        })).sort((a,b)=>{return Number(a.message_seq) - Number(b.message_seq)});
        convItemGroup.forEach(async (convItem, k) => {
          if (isDivideSending) {
            forwardMessage.forEach(async (message) => {
              const {
                data: { code, json_params },
              } = await sendForwardMessage({
                convId: getConvId(convItem),
                convType: getConvType(convItem),
                message: message,
                userId,
              });
              if (code === 0) {
                dispatch(
                  reciMessage({
                    convId: getConvId(convItem),
                    messages: [JSON.parse(json_params)],
                  })
                );
              }
            });
          } else if (isCombineSending) {
            console.warn("forwardMessage", forwardMessage);
            const {
              data: { code, json_params },
            } = await sendMergeMsg({
              convId: getConvId(convItem),
              convType: getConvType(convItem),
              messageElementArray: [
                {
                  elem_type: 12,
                  merge_elem_title: getMergeMessageTitle(forwardMessage[0]),
                  merge_elem_abstract_array:
                    getMergeMessageAbstactArray(forwardMessage),
                  merge_elem_compatible_text: "你的版本不支持此消息",
                  merge_elem_message_array: forwardMessage,
                },
              ],
              userId,
            });
            if (code === 0) {
              dispatch(
                reciMessage({
                  convId: getConvId(convItem),
                  messages: [JSON.parse(json_params)],
                })
              );
            }
          }
        });
        setForwardType(ForwardType.divide);
        setTransimitPopup(false);
        setSeletedMessage([]);
        setMultiSelect(false);
      };
    const handleForwardTypePopup = (type: ForwardType) => {
        if(!seletedMessage.length) return false;
        setTransimitPopup(true)
        setForwardType(type)
    }

    const deleteSelectedMessage = async () => {
        if(!seletedMessage.length) return;
        const { message_conv_id, message_conv_type} = seletedMessage[0];
        const messageList = seletedMessage.map(item => item.message_msg_id);
        const params = {
            convId: message_conv_id,
            convType: message_conv_type,
            messageList
        }
        const { data: {code} } = await deleteMsgList(params);

        if(code === 0) {
            dispatch(deleteMessage({
                convId: message_conv_id,
                messageIdArray: messageList
            }));
            setMultiSelect(false);
            setSeletedMessage([]);
        } else {
            message.warning({content: '删除消息失败'})
        }
    };

    const handleMultiSelectMsg = (params) => {
        setMultiSelect(true)
    }
    const handleSelectMessage = (message: State.message): void => {
        if(!isMultiSelect) {
            return;
        }
        const isMessageSelected = seletedMessage.findIndex(v => getMessageId(v) === getMessageId(message)) > -1 
        if(isMessageSelected) {
            const list = seletedMessage.filter(v => getMessageId(v) !== getMessageId(message))
            setSeletedMessage(list)
        } else {
            seletedMessage.push(message)
            setSeletedMessage(Array.from(seletedMessage))
        }
    }
    const handlRightClick = (e, id) => {
        const { data } = e.props;
        switch (id) {
            case 'revoke':
                handleRevokeMsg(data);
                break;
            case 'delete':
                handleDeleteMsg(data);
                break;
            case 'transimit':
                handleTransimitMsg(data);
                break;
            case 'reply':
                handleReplyMsg(data);
                break;
            case 'multiSelect':
                handleMultiSelectMsg(data);
                break;
        }
    }

    const cacluateRightMenuList = (message: State.message, element) => {
        const { elem_type } = element;
        const { message_is_from_self, message_server_time } = message;
        const isTips = [5,8].includes(elem_type);
        const isAvaChatRoom = groupType === 4;
        let formatedList = RIGHT_CLICK_MENU_LIST;

        if (elem_type === 3) {
            formatedList = formatedList.filter(item => item.id !== 'reply');
        }

        if(!message_is_from_self ||  currServerTime - message_server_time > 120) {
            formatedList = formatedList.filter(item => item.id !== 'revoke');
        }

        if(isTips) {
            formatedList = formatedList.filter(item => item.id !== 'reply' && item.id !== 'transimite' && item.id !== 'multiSelect'); //群系统消息 和 tips消息 不可转发
        } else if(isAvaChatRoom) {
            formatedList = formatedList.filter(item => item.id  !== 'multiSelect'); // 互动直播群不进行多选
        }

        return formatedList;

    };

    const handleContextMenuEvent = async (e, message: State.message, element) => {
        e.preventDefault();
        const { data: serverTime } = await timRenderInstance.TIMGetServerTime();
        setCurServerTime(serverTime);
        const rightMenuList = cacluateRightMenuList(message, element);

        setRightClickMenuList(rightMenuList);

        contextMenu.show({
            id: MESSAGE_MENU_ID,
            event: e,
            props: {
                data: {
                    convId: message.message_conv_id,
                    msgId: message.message_msg_id,
                    convType: message.message_conv_type,
                    message: message
                }
            }
        })
    }

    const handleMessageReSend =async (params) => {
        console.log(params)
        const {message_conv_id:conv_id,message_conv_type:conv_type} = params;
        const {data:{code,json_params}} = await timRenderInstance.TIMMsgSendMessage({
            conv_id,
            conv_type,
            params
        })
        if(code===0){
            dispatch(updateMessages({
                convId:conv_id,
                message:JSON.parse(json_params)
            }))
        }
    }

    
    const validatelastMessage = (messageList:State.message[])=>{
        let msg:State.message;
        for(let i = messageList.length-1;i>-1;i--){
            if(messageList[i].message_msg_id){
                msg = messageList[i];
                break;
            }
        }
        return msg;
    }
    const getMoreMsg = async () => {
        if(!noMore){
            
            const msg:State.message = validatelastMessage(messageList)
            if(!msg){
                return
            }
            const { message_conv_id,message_conv_type,message_msg_id  } = msg;
            const messageResponse = await getMsgList(message_conv_id, message_conv_type,message_msg_id);
            if(messageResponse.length>0){
                setAnchor(message_msg_id) 
            }else{
                setNoMore(true)
            }
            const addTimeDividerResponse = addTimeDivider(messageResponse.reverse());
            const payload = {
                convId: message_conv_id,
                messages: addTimeDividerResponse.reverse(),
            };
            dispatch(addMoreMessage(payload));
        }
    }

    const handleCloseForwardModal = () => {
        setMultiSelect(false);
        setSeletedMessage([]);
    }

    const onScroll = (e) => {
        if(!noMore) {
            const messageLastChild = messageViewRef?.current?.lastChild;
            const offsetTopScreen = messageLastChild.getBoundingClientRect().top;
            const canLoadData = offsetTopScreen > 50;
            canLoadData && getMoreMsg();
        }
    };
    const tryparse = (e)=>{
        let data = false;
        try {
            JSON.parse(e);
            data = true;
        } catch (error) {
            
        }
        return data
    }
    return (
        <div className="message-view" ref={messageViewRef} onScroll={throttle(onScroll, 300)}>
            {
               messageList && messageList.length > 0 &&
                messageList.map((item, index) => {
                    if(!item){
                        return null
                    }
                    if (item.isTimeDivider) {
                        return (
                            <div key={`${item.time}-${index}` } className="message-view__item--time-divider">{formateTime(item.time * 1000, true)}</div>
                        )
                    }
                    const { message_elem_array, message_client_time, message_sender_profile, message_msg_id, message_is_from_self ,message_status, message_is_peer_read, message_conv_type, message_conv_id } = item;
                    const { user_profile_face_url, user_profile_role, user_profile_nick_name, user_profile_add_permission, user_profile_identifier, user_profile_gender, user_profile_self_signature } = message_sender_profile;
                    const revokedPerson = message_is_from_self ? '你' : user_profile_nick_name;
                    const isMessageSendFailed = message_status === 3 && message_is_from_self;
                    const shouldShowPerReadIcon = message_conv_type === 1 && message_is_from_self && !isMessageSendFailed;
                    const seleted = seletedMessage.findIndex(i => getMessageId(i) === getMessageId(item)) > -1
                    const elemType = message_elem_array?.[0]?.elem_type; // 取message array的第一个判断消息类型
                    const isNotGroupSysAndGroupTipsMessage =  ![5,8].includes(elemType); // 5,8作为群系统消息 不需要多选转发
                    
                    const profile = {
                        userId: user_profile_identifier,
                        nickName: user_profile_nick_name,
                        faceUrl: user_profile_face_url,
                        gender: user_profile_gender,
                        signature: user_profile_self_signature,
                        role: user_profile_role,
                        addPermission: user_profile_add_permission
                    } as State.userInfo;

                    const getName = () => {
                        const { group_member_info_name_card, group_member_info_nick_name, group_member_info_identifier } = item?.message_sender_group_member_info || {};
                        const displayName = group_member_info_name_card || group_member_info_nick_name || user_profile_nick_name || group_member_info_identifier;
                        return displayName
                    }

                    return (
                        <React.Fragment key={index}>
                            {
                                message_status === 6 ? (
                                    <div className="message-view__item is-revoked" >
                                        { `${revokedPerson} 撤回了一条消息` }
                                    </div>
                                ) :
                                    <div key={index}  onClick={() => handleSelectMessage(item)} className={`message-view__item ${message_is_from_self ? 'is-self' : ''}`} >
                                        { isMultiSelect && isNotGroupSysAndGroupTipsMessage && (seleted ? 
                                            <Icon className="message-view__item--icon" type="success" /> : 
                                            <i className="message-view__item--icon-normal" ></i>)
                                        }
                                        <div className="message-view__item--avatar face-url">
                                            <AvatarWithProfile profile={profile}/>
                                        </div>
                                        <div className="message-view__item--message-content">
                                            <div className="message-view__item--message-header">
                                                {
                                                   message_conv_type === 2 && !message_is_from_self && <span className="message-view__nick_name">
                                                        {
                                                            getName()
                                                        }
                                                    </span>
                                                }
                                                <span className="message-view__item--element__time">{_formatDate(new Date(message_client_time * 1000), 'yyyy-MM-dd hh:mm')}</span>
                                            </div>
                                            <div className="message-view__item--message-text">
                                                {
                                                    message_elem_array && message_elem_array.length && message_elem_array.map((elment, index) => {
                                                        return (
                                                            <div ref={setRef(message_msg_id)} className="message-view__item--element" key={index} onContextMenu={(e) => { handleContextMenuEvent(e, item, elment) }}>
                                                                {
                                                                    //@ts-ignore
                                                                    item.message_cloud_custom_str !== "" && item.message_cloud_custom_str.includes("messageReply") && tryparse(item.message_cloud_custom_str) && <ReplyElem convId={message_conv_id} convType={message_conv_type} originalMsg={ JSON.parse(item.message_cloud_custom_str)} getRef={getRef} />
                                                                }
                                                                {
                                                                    displayDiffMessage(item, elment, index)
                                                                }
                                                            </div>
                                                        )
                                                    })
                                                }
                                                {
                                                    shouldShowPerReadIcon ? <span className={`message-view__item--element-icon ${message_is_peer_read ? 'is-read' : ''}`}></span> :
                                                    isMessageSendFailed &&  <Icon className="message-view__item--element-icon-error" type="error" onClick={() => handleMessageReSend(item)} />
                                                }
                                            </div>
                                            
                                        </div>
                                    </div>
                            }
                            <div className="message-view__item--blank"></div>
                        </React.Fragment>
                    )
                })
            }
            <Menu
                id={MESSAGE_MENU_ID}
                theme={theme.light}
                animation={animation.fade}
            >
                {
                    rightClickMenuList.map(({ id, text }) => {
                        return (
                            <Item  key={id} onClick={(e) => handlRightClick(e, id)}>
                                {text}
                            </Item>
                        )
                    })
                }
            </Menu>
            {
                isTransimitPopup && <ForwardPopup onSuccess={handleForwardPopupSuccess} onClose={() => {setTransimitPopup(false)}}/>
            }
            {
                isMultiSelect && 
                <div className="forward-type-popup">
                    <Icon type="close" className="forward-type-popup__close" onClick={handleCloseForwardModal} />
                    <div className="forward-type-popup__combine" onClick={() => handleForwardTypePopup(ForwardType.combine)}>
                        <p>合并转发</p>
                    </div>
                    <div className="forward-type-popup__divide" onClick={() => handleForwardTypePopup(ForwardType.divide)}>
                        <p>逐条转发</p>
                    </div>
                    <div className="forward-type-popup__delete" onClick={deleteSelectedMessage}>
                        <p>删除</p>
                    </div>
                </div>   
            }
            <div className={`showMore ${noMore ? 'no-more': 'loading-more'}`}>{noMore ? '没有更多了': '' }&nbsp;</div>
        </div>
    )
};