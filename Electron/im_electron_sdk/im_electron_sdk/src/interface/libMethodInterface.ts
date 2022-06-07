import { TIMConvType, TIMReceiveMessageOpt } from "../enum";

interface TIMInitFun {
    (sdkappid: number, sdkconfig: string): number;
}

interface TIMUninitFun {
    (): number;
}

interface TIMLoginFun {
    (
        user_id: string,
        user_sig: string,
        callback: Buffer,
        user_data?: string
    ): number;
}
interface TIMLogoutFun {
    (callback: Buffer, user_data?: string): number;
}

interface TIMGetLoginStatusFun {
    (): number;
}

interface TIMGetSDKVersionFun {
    (): Buffer;
}

interface TIMGetServerTimeFun {
    (): number;
}
interface TIMGetLoginUserIDFun {
    (user_id?: Buffer): number;
}

interface TIMSetNetworkStatusListenerCallbackFun {
    (callback: Buffer, user_data?: string): number;
}

interface TIMSetKickedOfflineCallbackFun {
    (callback: Buffer, user_data?: string): number;
}
interface TIMSetUserSigExpiredCallbackFun {
    (callback: Buffer, user_data?: string): number;
}

// ==========Interface For Conversation Start===========
interface TIMConvCreateFun {
    (
        conv_id: string,
        conv_type: number,
        callback: Buffer,
        user_data?: string
    ): number;
}
interface TIMConvGetConvListFun {
    (callback: Buffer, user_data?: string): number;
}
interface TIMConvSetDraftFun {
    (conv_id: string, conv_type: number, json_draft_param: string): number;
}
interface TIMConvCancelDraftFun {
    (conv_id: string, conv_type: number): number;
}
interface TIMConvDeleteFun extends TIMConvCreateFun {}
interface TIMConvGetConvInfoFun {
    (
        json_get_conv_list_param: string,
        callback: Buffer,
        user_data?: string
    ): number;
}
interface TIMConvPinConversationFun {
    (
        conv_id: string,
        conv_type: number,
        is_pinned: boolean,
        callback: Buffer,
        user_data?: string
    ): number;
}
interface TIMConvGetTotalUnreadMessageCountFun {
    (callback: Buffer, user_data?: string): number;
}
interface TIMSetConvEventCallbackFun {
    (callback: Buffer, user_data?: string): number;
}
interface TIMSetConvTotalUnreadMessageCountChangedCallbackFun {
    (callback: Buffer, user_data?: string): number;
}
// ==========Interface For Conversation End===========
// ==========Interface For Group Start===========
interface TIMGroupCreateFun {
    (params: string, callback?: Buffer, user_data?: string): number;
}

interface TIMGroupDeleteFun {
    (groupId: string, callback?: Buffer, user_data?: string): number;
}

interface TIMGroupJoinFun {
    (
        groupId: string,
        hello_msg: string,
        callback?: Buffer,
        user_data?: string
    ): number;
}

interface TIMGroupQuitFun extends TIMGroupDeleteFun {}

interface TIMGroupInviteMemberFun extends TIMGroupCreateFun {}

interface TIMGroupDeleteMemberFun extends TIMGroupCreateFun {}

interface TIMGroupGetJoinedGroupListFun {
    (callback?: Buffer, user_data?: string): number;
}

interface TIMGroupGetGroupInfoListFun extends TIMGroupCreateFun {}

interface TIMGroupModifyGroupInfoFun extends TIMGroupCreateFun {}

interface TIMGroupGetMemberInfoListFun extends TIMGroupCreateFun {}

interface TIMGroupModifyMemberInfoFun extends TIMGroupCreateFun {}

interface TIMGroupGetPendencyListFun extends TIMGroupCreateFun {}

interface TIMGroupReportPendencyReadedFun {
    (timeStamp: number, callback?: Buffer, user_data?: string): number;
}

interface TIMGroupHandlePendencyFun extends TIMGroupCreateFun {}

interface TIMGroupGetOnlineMemberCountFun extends TIMGroupDeleteFun {}

interface TIMGroupSearchGroupsFun extends TIMGroupCreateFun {}

interface TIMGroupSearchGroupMembersFun extends TIMGroupCreateFun {}

interface TIMGroupInitGroupAttributesFun {
    (
        groupId: string,
        params: string,
        callback?: Buffer,
        user_data?: string
    ): number;
}

interface TIMGroupSetGroupAttributesFun
    extends TIMGroupInitGroupAttributesFun {}

interface TIMGroupDeleteGroupAttributesFun
    extends TIMGroupInitGroupAttributesFun {}

interface TIMGroupGetGroupAttributesFun
    extends TIMGroupInitGroupAttributesFun {}

interface TIMSetGroupTipsEventCallbackFun {
    (callback: Buffer, user_data?: string): void;
}

interface TIMSetGroupAttributeChangedCallbackFun {
    (callback: Buffer, user_data?: string): void;
}

// ==========Interface For Group End===========
// ==========Interface For friendship begin===========
interface TIMFriendshipGetFriendProfileListFun {
    (callback?: Buffer, user_data?: string): number;
}
interface TIMFriendshipAddFriendFun {
    (
        json_add_friend_param?: string,
        callback?: Buffer,
        user_data?: string
    ): number;
}
interface TIMFriendshipHandleFriendAddRequestFun {
    (
        json_add_friend_param?: string,
        callback?: Buffer,
        user_data?: string
    ): number;
}
interface TIMFriendshipModifyFriendProfileFun {
    (
        json_modify_friend_info_param?: string,
        callback?: Buffer,
        user_data?: string
    ): number;
}
interface TIMFriendshipDeleteFriendFun {
    (
        json_delete_friend_param?: string,
        callback?: Buffer,
        user_data?: string
    ): number;
}
interface TIMFriendshipCheckFriendTypeFun {
    (
        json_check_friend_list_param?: string,
        callback?: Buffer,
        user_data?: string
    ): number;
}
interface TIMFriendshipCreateFriendGroupFun {
    (
        json_create_friend_group_param?: string,
        callback?: Buffer,
        user_data?: string
    ): number;
}
interface TIMFriendshipGetFriendGroupListFun {
    (
        json_get_friend_group_list_param?: string,
        callback?: Buffer,
        user_data?: string
    ): number;
}
interface TIMFriendshipModifyFriendGroupFun {
    (
        json_modify_friend_group_param?: string,
        callback?: Buffer,
        user_data?: string
    ): number;
}
interface TIMFriendshipDeleteFriendGroupFun {
    (
        json_delete_friend_group_param?: string,
        callback?: Buffer,
        user_data?: string
    ): number;
}
interface TIMFriendshipAddToBlackListFun {
    (
        json_add_to_blacklist_param?: string,
        callback?: Buffer,
        user_data?: string
    ): number;
}
interface TIMFriendshipGetBlackListFun {
    (callback?: Buffer, user_data?: string): number;
}
interface TIMFriendshipDeleteFromBlackListFun {
    (
        json_delete_from_blacklist_param?: string,
        callback?: Buffer,
        user_data?: string
    ): number;
}
interface TIMFriendshipGetPendencyListFun {
    (
        json_get_pendency_list_param?: string,
        callback?: Buffer,
        user_data?: string
    ): number;
}
interface TIMFriendshipDeletePendencyFun {
    (
        json_delete_pendency_param?: string,
        callback?: Buffer,
        user_data?: string
    ): number;
}
interface TIMFriendshipReportPendencyReadedFun {
    (time_stamp?: number, callback?: Buffer, user_data?: string): number;
}
interface TIMFriendshipSearchFriendsFun {
    (
        json_search_friends_param?: string,
        callback?: Buffer,
        user_data?: string
    ): number;
}
interface TIMFriendshipGetFriendsInfoFun {
    (
        json_get_friends_info_param?: string,
        callback?: Buffer,
        user_data?: string
    ): number;
}
interface TIMMsgSendMessageFun {
    (
        conv_id?: string,
        conv_type?: TIMConvType,
        json_add_friend_param?: string,
        message_id_buffer?: ArrayBuffer,
        callback?: Buffer,
        user_data?: string
    ): number;
}
interface TIMMsgCancelSendFun {
    (
        conv_id?: string,
        conv_type?: TIMConvType,
        message_id?: string,
        callback?: Buffer,
        user_data?: string
    ): number;
}
interface TIMMsgFindMessagesFun {
    (
        json_message_id_array: string,
        callback: Buffer,
        user_data?: string
    ): number;
}
interface TIMMsgReportReadedFun {
    (
        conv_id: string,
        conv_type: TIMConvType,
        json_msg_param: string,
        callback: Buffer,
        user_data?: string
    ): number;
}
interface TIMMsgRevokeFun {
    (
        conv_id?: string,
        conv_type?: TIMConvType,
        json_msg_param?: string,
        callback?: Buffer,
        user_data?: string
    ): number;
}
interface TIMMsgFindByMsgLocatorListFun {
    (
        conv_id?: string,
        conv_type?: TIMConvType,
        json_msg_Locator_array?: string,
        callback?: Buffer,
        user_data?: string
    ): number;
}
interface TIMMsgImportMsgListFun {
    (
        conv_id?: string,
        conv_type?: TIMConvType,
        json_msg_array?: string,
        callback?: Buffer,
        user_data?: string
    ): number;
}
interface TIMMsgSaveMsgFun {
    (
        conv_id?: string,
        conv_type?: TIMConvType,
        json_msg_param?: string,
        callback?: Buffer,
        user_data?: string
    ): number;
}
interface TIMMsgGetMsgListFun {
    (
        conv_id?: string,
        conv_type?: TIMConvType,
        json_get_msg_param?: string,
        callback?: Buffer,
        user_data?: string
    ): number;
}
interface TIMMsgDeleteFun {
    (
        conv_id?: string,
        conv_type?: TIMConvType,
        json_msgdel_param?: string,
        callback?: Buffer,
        user_data?: string
    ): number;
}
interface TIMMsgListDeleteFun {
    (
        conv_id?: string,
        conv_type?: TIMConvType,
        json_msg_array?: string,
        callback?: Buffer,
        user_data?: string
    ): number;
}
interface TIMMsgClearHistoryMessageFun {
    (
        conv_id?: string,
        conv_type?: TIMConvType,
        callback?: Buffer,
        user_data?: string
    ): number;
}
interface TIMMsgSetC2CReceiveMessageOptFun {
    (
        json_identifier_array?: string,
        opt?: TIMReceiveMessageOpt,
        callback?: Buffer,
        user_data?: string
    ): number;
}
interface TIMMsgGetC2CReceiveMessageOptFun {
    (
        json_identifier_array: string,
        callback: Buffer,
        user_data?: string
    ): number;
}
interface TIMMsgSetGroupReceiveMessageOptFun {
    (
        group_id: string,
        opt: number,
        callback?: Buffer,
        user_data?: string
    ): number;
}
interface TIMMsgDownloadElemToPathFun {
    (
        json_download_elem_param: string,
        path: string,
        callback: Buffer,
        user_data?: string
    ): number;
}
interface TIMMsgDownloadMergerMessageFun {
    (json_single_msg: string, callback: Buffer, user_data?: string): number;
}
interface TIMMsgBatchSendFun {
    (
        json_batch_send_param: string,
        callback: Buffer,
        user_data?: string
    ): number;
}
interface TIMMsgSearchLocalMessagesFun {
    (
        json_search_message_param: string,
        callback: Buffer,
        user_data?: string
    ): number;
}
interface TIMAddRecvNewMsgCallbackFun {
    (callback: Buffer, user_data?: string): void;
}
interface TIMRemoveRecvNewMsgCallbackFun {
    (callback: Buffer, user_data?: string): void;
}
interface TIMSetMsgReadedReceiptCallbackFun {
    (callback: Buffer, user_data?: string): void;
}
interface TIMSetMsgRevokeCallbackFun {
    (callback: Buffer, user_data?: string): void;
}
interface TIMSetMsgElemUploadProgressCallbackFun {
    (callback: Buffer, user_data?: string): void;
}
interface TIMSetOnAddFriendCallbackFun {
    (callback: Buffer, user_data?: string): void;
}
interface TIMSetOnDeleteFriendCallbackFun {
    (callback: Buffer, user_data?: string): void;
}
interface TIMSetUpdateFriendProfileCallbackFun {
    (callback: Buffer, user_data?: string): void;
}
interface TIMSetFriendAddRequestCallbackFun {
    (callback: Buffer, user_data?: string): void;
}
interface TIMSetFriendApplicationListDeletedCallbackFun {
    (callback: Buffer, user_data?: string): void;
}
interface TIMSetFriendApplicationListReadCallbackFun {
    (callback: Buffer, user_data?: string): void;
}
interface TIMSetFriendBlackListAddedCallbackFun {
    (callback: Buffer, user_data?: string): void;
}
interface TIMSetFriendBlackListDeletedCallbackFun {
    (callback: Buffer, user_data?: string): void;
}
interface TIMSetMsgUpdateCallbackFun {
    (callback: Buffer, user_data?: string): void;
}
interface TIMSetLogCallbackLibFun {
    (callback: Buffer, user_data?: string): void;
}
interface TIMSetConfigLibFun {
    (json_config: string, callback: Buffer, user_data: string): number;
}
interface callExperimentalAPIFun {
    (json_param: string, callback: Buffer, user_data: string): number;
}
interface TIMProfileGetUserProfileListFun {
    (json_param: string, callback: Buffer, user_data: string): number;
}

interface TIMProfileModifySelfUserProfileFun {
    (json_param: string, callback: Buffer, user_data: string): number;
}
// ==========Interface For friendship End===========

interface TIMMsgSendMessageReadReceiptsFun {
    (json_param: string, callback: Buffer, user_data: string): number;
}
interface TIMMsgGetMessageReadReceiptsFun {
    (json_param: string, callback: Buffer, user_data: string): number;
}
interface TIMMsgGetGroupMessageReadMemberListFun {
    (
        json_param: string,
        filter: number,
        next_seq: string,
        count: number,
        callback: Buffer,
        user_data: string
    ): number;
}

interface libMethods {
    // timbase start
    TIMInit: TIMInitFun;
    TIMLogin: TIMLoginFun;
    TIMUninit: TIMUninitFun;
    TIMGetSDKVersion: TIMGetSDKVersionFun;
    TIMGetServerTime: TIMGetServerTimeFun;
    TIMLogout: TIMLogoutFun;
    TIMGetLoginStatus: TIMGetLoginStatusFun;
    TIMGetLoginUserID: TIMGetLoginUserIDFun;
    TIMSetNetworkStatusListenerCallback: TIMSetNetworkStatusListenerCallbackFun;
    TIMSetKickedOfflineCallback: TIMSetKickedOfflineCallbackFun;
    TIMSetUserSigExpiredCallback: TIMSetUserSigExpiredCallbackFun;
    TIMSetLogCallback: TIMSetLogCallbackLibFun;
    TIMSetConfig: TIMSetConfigLibFun;
    callExperimentalAPI: callExperimentalAPIFun;
    TIMProfileGetUserProfileList: TIMProfileGetUserProfileListFun;
    TIMProfileModifySelfUserProfile: TIMProfileModifySelfUserProfileFun;
    // timbase end

    // conversation start
    TIMConvCreate: TIMConvCreateFun;
    TIMConvGetConvList: TIMConvGetConvListFun;
    TIMConvDelete: TIMConvDeleteFun;
    TIMConvSetDraft: TIMConvSetDraftFun;
    TIMConvCancelDraft: TIMConvCancelDraftFun;
    TIMConvGetConvInfo: TIMConvGetConvInfoFun;
    TIMConvPinConversation: TIMConvPinConversationFun;
    TIMConvGetTotalUnreadMessageCount: TIMConvGetTotalUnreadMessageCountFun;
    TIMSetConvEventCallback: TIMSetConvEventCallbackFun;
    TIMSetConvTotalUnreadMessageCountChangedCallback: TIMSetConvTotalUnreadMessageCountChangedCallbackFun;
    // converastion end
    // friendship start
    TIMFriendshipGetFriendProfileList: TIMFriendshipGetFriendProfileListFun;
    TIMFriendshipAddFriend: TIMFriendshipAddFriendFun;
    TIMFriendshipHandleFriendAddRequest: TIMFriendshipHandleFriendAddRequestFun;
    TIMFriendshipModifyFriendProfile: TIMFriendshipModifyFriendProfileFun;
    TIMFriendshipDeleteFriend: TIMFriendshipDeleteFriendFun;
    TIMFriendshipCheckFriendType: TIMFriendshipCheckFriendTypeFun;
    TIMFriendshipCreateFriendGroup: TIMFriendshipCreateFriendGroupFun;
    TIMFriendshipGetFriendGroupList: TIMFriendshipGetFriendGroupListFun;
    TIMFriendshipModifyFriendGroup: TIMFriendshipModifyFriendGroupFun;
    TIMFriendshipDeleteFriendGroup: TIMFriendshipDeleteFriendGroupFun;
    TIMFriendshipAddToBlackList: TIMFriendshipAddToBlackListFun;
    TIMFriendshipGetBlackList: TIMFriendshipGetBlackListFun;
    TIMFriendshipDeleteFromBlackList: TIMFriendshipDeleteFromBlackListFun;
    TIMFriendshipGetPendencyList: TIMFriendshipGetPendencyListFun;
    TIMFriendshipDeletePendency: TIMFriendshipDeletePendencyFun;
    TIMFriendshipReportPendencyReaded: TIMFriendshipReportPendencyReadedFun;
    TIMFriendshipSearchFriends: TIMFriendshipSearchFriendsFun;
    TIMFriendshipGetFriendsInfo: TIMFriendshipGetFriendsInfoFun;
    TIMMsgSendMessage: TIMMsgSendMessageFun;
    TIMMsgCancelSend: TIMMsgCancelSendFun;
    TIMMsgFindMessages: TIMMsgFindMessagesFun;
    TIMMsgReportReaded: TIMMsgReportReadedFun;
    TIMMsgRevoke: TIMMsgRevokeFun;
    TIMMsgFindByMsgLocatorList: TIMMsgFindByMsgLocatorListFun;
    TIMMsgImportMsgList: TIMMsgImportMsgListFun;
    TIMMsgSaveMsg: TIMMsgSaveMsgFun;
    TIMMsgGetMsgList: TIMMsgGetMsgListFun;
    TIMMsgDelete: TIMMsgDeleteFun;
    TIMMsgListDelete: TIMMsgListDeleteFun;
    TIMMsgClearHistoryMessage: TIMMsgClearHistoryMessageFun;
    TIMMsgSetC2CReceiveMessageOpt: TIMMsgSetC2CReceiveMessageOptFun;
    TIMMsgGetC2CReceiveMessageOpt: TIMMsgGetC2CReceiveMessageOptFun;
    TIMMsgSetGroupReceiveMessageOpt: TIMMsgSetGroupReceiveMessageOptFun;
    TIMMsgDownloadElemToPath: TIMMsgDownloadElemToPathFun;
    TIMMsgDownloadMergerMessage: TIMMsgDownloadMergerMessageFun;
    TIMMsgBatchSend: TIMMsgBatchSendFun;
    TIMMsgSearchLocalMessages: TIMMsgSearchLocalMessagesFun;
    TIMAddRecvNewMsgCallback: TIMAddRecvNewMsgCallbackFun;
    TIMRemoveRecvNewMsgCallback: TIMRemoveRecvNewMsgCallbackFun;
    TIMSetMsgReadedReceiptCallback: TIMSetMsgReadedReceiptCallbackFun;
    TIMSetMsgRevokeCallback: TIMSetMsgRevokeCallbackFun;
    TIMSetMsgElemUploadProgressCallback: TIMSetMsgElemUploadProgressCallbackFun;
    TIMSetOnAddFriendCallback: TIMSetOnAddFriendCallbackFun;
    TIMSetOnDeleteFriendCallback: TIMSetOnDeleteFriendCallbackFun;
    TIMSetUpdateFriendProfileCallback: TIMSetUpdateFriendProfileCallbackFun;
    TIMSetFriendAddRequestCallback: TIMSetFriendAddRequestCallbackFun;
    TIMSetFriendApplicationListDeletedCallback: TIMSetFriendApplicationListDeletedCallbackFun;
    TIMSetFriendApplicationListReadCallback: TIMSetFriendApplicationListReadCallbackFun;
    TIMSetFriendBlackListAddedCallback: TIMSetFriendBlackListAddedCallbackFun;
    TIMSetFriendBlackListDeletedCallback: TIMSetFriendBlackListDeletedCallbackFun;
    TIMSetMsgUpdateCallback: TIMSetMsgUpdateCallbackFun;
    // friendship end

    // group start
    TIMMsgSendMessageReadReceipts: TIMMsgSendMessageReadReceiptsFun;
    TIMMsgGetMessageReadReceipts: TIMMsgGetMessageReadReceiptsFun;
    TIMMsgGetGroupMessageReadMemberList: TIMMsgGetGroupMessageReadMemberListFun;
    TIMGroupCreate: TIMGroupCreateFun;
    TIMGroupDelete: TIMGroupDeleteFun;
    TIMGroupJoin: TIMGroupJoinFun;
    TIMGroupQuit: TIMGroupQuitFun;
    TIMGroupInviteMember: TIMGroupInviteMemberFun;
    TIMGroupDeleteMember: TIMGroupDeleteMemberFun;
    TIMGroupGetJoinedGroupList: TIMGroupGetJoinedGroupListFun;
    TIMGroupGetGroupInfoList: TIMGroupGetGroupInfoListFun;
    TIMGroupModifyGroupInfo: TIMGroupModifyGroupInfoFun;
    TIMGroupGetMemberInfoList: TIMGroupGetMemberInfoListFun;
    TIMGroupModifyMemberInfo: TIMGroupModifyMemberInfoFun;
    TIMGroupGetPendencyList: TIMGroupGetPendencyListFun;
    TIMGroupReportPendencyReaded: TIMGroupReportPendencyReadedFun;
    TIMGroupHandlePendency: TIMGroupHandlePendencyFun;
    TIMGroupGetOnlineMemberCount: TIMGroupGetOnlineMemberCountFun;
    TIMGroupSearchGroups: TIMGroupSearchGroupsFun;
    TIMGroupSearchGroupMembers: TIMGroupSearchGroupMembersFun;
    TIMGroupInitGroupAttributes: TIMGroupInitGroupAttributesFun;
    TIMGroupSetGroupAttributes: TIMGroupSetGroupAttributesFun;
    TIMGroupDeleteGroupAttributes: TIMGroupDeleteGroupAttributesFun;
    TIMGroupGetGroupAttributes: TIMGroupGetGroupAttributesFun;
    TIMSetGroupTipsEventCallback: TIMSetGroupTipsEventCallbackFun;
    TIMSetGroupAttributeChangedCallback: TIMSetGroupAttributeChangedCallbackFun;
    // group end
}

export { libMethods };
