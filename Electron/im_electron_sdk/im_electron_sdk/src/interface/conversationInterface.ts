import { TIMConvType, TIMElemType } from "../enum";

/**
 * * @brief 创建会话
 * @param conv_id    conv_id 会话的ID
 * @param conv_type  conv_type 会话类型，请参考[TIMConvType](../enums/enum.timconvtype.html)
 * @param user_data  user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
 */
interface convCreate {
    convId: string;
    convType: TIMConvType;
    userData?: string;
}
/**
 * @param conv_id    conv_id 会话的ID
 * @param conv_type  conv_type 会话类型，请参考[TIMConvType](../enums/enum.timconvtype.html)
 * @param user_data  user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
 */
interface convDelete extends convCreate {}
/**
 * @brief 获取最近联系人的会话列表
 *
 * @param user_data  user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
 *
 */
interface getConvList {
    userData?: string;
}
/**
 * @param conv_id   conv_id 会话的ID
 * @param convType  convType请参考[TIMConvType](../enums/enum.timconvtype.html)
 * @param draftParams draftParams 草稿参数
 */
interface convSetDrat {
    convId: string;
    convType: TIMConvType;
    draftParam: draftParams;
}
/**
 * @param message_elem_array message_elem_array: 消息内元素列表
 */
interface draftMessage {
    message_elem_array: Array<messageElem>;
}
/**
 * @param draft_edit_time   draft_edit_time: 草稿最新编辑时间
 * @param draft_msg  draft_msg: 草稿内的消息
 * @param draft_user_define draft_user_define: 用户自定义数据
 */
interface draftParams {
    draft_edit_time: number;
    draft_msg: draftMessage;
    draft_user_define: string;
}
/**
 * @param TIMElemType TIMElemType: 元素类型
 * @param text_elem_content text_elem_content: 文本内容
 */
interface messageElem {
    elem_type: TIMElemType;
    text_elem_content: string;
}
/**
 * @param conv_id   conv_id 会话的ID
 * @param convType  convType参考[TIMConvType](../enums/enum.timconvtype.html)
 */
interface convCancelDraft {
    convId: string;
    convType: TIMConvType;
}
/**
 * @param get_conversation_list_param_conv_id get_conversation_list_param_conv_id: 会话ID
 * @param get_conversation_list_param_conv_type get_conversation_list_param_conv_type: 会话类型[TIMConvType](../enums/enum.timconvtype.html)
 */
interface convItem {
    get_conversation_list_param_conv_id: string;
    get_conversation_list_param_conv_type: string;
}
/**
 * @param json_get_conv_list_param   json_get_conv_list_param 会话唯一 ID 列表和会话类型的列表
 * @param user_data  user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
 */
interface convGetConvInfo {
    json_get_conv_list_param: Array<convItem>;
    user_data?: string;
}
/**
 * @param conv_id  conv_id 会话 ID
 * @param conv_type  conv_type 会话类型，请参考[TIMConvType](../enums/enum.timconvtype.html)
 * @param is_pinned is_pinned是否置顶会话
 * @param user_data  user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
 */
interface convPinConversation {
    convId: string;
    convType: TIMConvType;
    isPinned: boolean;
    user_data?: string;
}
/**
 * @param user_data  user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
 */
interface convGetTotalUnreadMessageCount {
    user_data?: string;
}

/**
 * @brief 设置会话事件回调
 * @param callback  callback 会话事件回调，请参考convEventCallback
 * @param user_data  user_data用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
 */
interface setConvEventCallback {
    callback: convEventCallback;
    user_data?: string;
}
/**
 * @brief 设置会话未读消息总数变更的回调
 * @param callback  callback：convTotalUnreadMessageCountChangedCallback
 * @param user_data  user_data 用户自定义数据，ImSDK只负责传回给回调函数cb，不做任何处理
 *
 */
interface convTotalUnreadMessageCountChangedCallbackParam {
    callback: convTotalUnreadMessageCountChangedCallback;
    user_data?: string;
}
/**
 * @param conv_event  conv_event 会话事件类型
 * @param json_conv_array  json_conv_array: 会话信息列表
 * @param user_data user_data: ImSDK负责透传的用户自定义数据，未做任何处理
 *
 */
// TODO json_conv_array写错了应该是Array类型
interface convEventCallback {
    (conv_event: number, json_conv_array: string, user_data: string): void;
}
/**
 * @param total_unread_count total_unread_count：未读的消息总数
 * @param user_data user_data：ImSDK负责透传的用户自定义数据，未做任何处理
 */
interface convTotalUnreadMessageCountChangedCallback {
    (total_unread_count: number, user_data: string): void;
}

export {
    convCreate,
    getConvList,
    convDelete,
    convSetDrat,
    draftParams,
    draftMessage,
    messageElem,
    convCancelDraft,
    convGetConvInfo,
    convItem,
    convPinConversation,
    convGetTotalUnreadMessageCount,
    setConvEventCallback,
    convEventCallback,
    convTotalUnreadMessageCountChangedCallback,
    convTotalUnreadMessageCountChangedCallbackParam,
};
