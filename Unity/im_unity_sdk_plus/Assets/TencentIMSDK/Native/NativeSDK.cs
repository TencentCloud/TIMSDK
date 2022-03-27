using com.tencent.imsdk.unity.utils;
using com.tencent.imsdk.unity.types;
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using com.tencent.imsdk.unity.enums;
using com.tencent.imsdk.unity.callback;
using Newtonsoft.Json;
using UnityEngine;
using AOT;
using System.Text;

namespace com.tencent.imsdk.unity.native
{
    public class IMNativeSDK
    {
        #region DllImport
#if UNITY_EDITOR
#if UNITY_EDITOR_OSX
                    public const string MyLibName = "ImSDKForMac";
#else
                    public const string MyLibName = "ImSDK";
#endif
#else
#if UNITY_IPHONE
                    public const string MyLibName = "__Internal";
#elif UNITY_ANDROID
                    public const string MyLibName = "ImSDK";
#elif UNITY_STANDALONE_WIN
                    public const string MyLibName = "ImSDK";
#elif UNITY_STANDALONE_OSX
                    public const string MyLibName = "ImSDKForMac";
#else
        public const string MyLibName = "ImSDK";
#endif
#endif

        #endregion


        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMLogin(IntPtr user_id, IntPtr user_sig, CommonValueCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMInit(long sdk_app_id, IntPtr json_sdk_config);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMUninit();

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern IntPtr TIMGetSDKVersion();

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMSetConfig(IntPtr json_config, CommonValueCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern long TIMGetServerTime();



        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMLogout(CommonValueCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMGetLoginStatus();

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMGetLoginUserID(StringBuilder user_id_buffer);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMConvGetConvList(CommonValueCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMConvDelete(IntPtr conv_id, int conv_type, CommonValueCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMConvGetConvInfo(IntPtr json_get_conv_list_param, CommonValueCallback cb, IntPtr user_data);
        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMConvSetDraft(string conv_id, int conv_type, IntPtr draft_param);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMConvCancelDraft(string conv_id, int conv_type);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMConvPinConversation(string conv_id, int conv_type, bool is_pinned, CommonValueCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMConvGetTotalUnreadMessageCount(CommonValueCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMMsgSendMessage(string conv_id, int conv_type, IntPtr message_param, StringBuilder message_id, CommonValueCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMMsgCancelSend(string conv_id, int conv_type, IntPtr message_id, CommonValueCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMMsgFindMessages(IntPtr message_id_array, CommonValueCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMMsgReportReaded(string conv_id, int conv_type, IntPtr message_param, CommonValueCallback cb, IntPtr user_data);


        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMMsgMarkAllMessageAsRead(CommonValueCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMMsgRevoke(string conv_id, int conv_type, IntPtr message_param, CommonValueCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMMsgFindByMsgLocatorList(string conv_id, int conv_type, IntPtr message_locator_param, CommonValueCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMMsgImportMsgList(string conv_id, int conv_type, IntPtr message_list_param, CommonValueCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMMsgSaveMsg(string conv_id, int conv_type, IntPtr message_param, CommonValueCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMMsgGetMsgList(string conv_id, int conv_type, IntPtr message_param, CommonValueCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMMsgDelete(string conv_id, int conv_type, IntPtr json_msgdel_param, CommonValueCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMMsgListDelete(string conv_id, int conv_type, IntPtr message_list, CommonValueCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMMsgClearHistoryMessage(string conv_id, int conv_type, CommonValueCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMMsgSetC2CReceiveMessageOpt(IntPtr json_identifier_array, int opt, CommonValueCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMMsgGetC2CReceiveMessageOpt(IntPtr json_identifier_array, CommonValueCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMMsgSetGroupReceiveMessageOpt(IntPtr group_id, int opt, CommonValueCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMMsgDownloadElemToPath(IntPtr json_download_elem_param, IntPtr path, CommonValueCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMMsgDownloadMergerMessage(IntPtr json_single_msg, CommonValueCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMMsgBatchSend(IntPtr json_batch_send_param, CommonValueCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMMsgSearchLocalMessages(IntPtr json_search_message_param, CommonValueCallback cb, IntPtr user_data);
        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMMsgSetLocalCustomData(IntPtr json_msg_param, CommonValueCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMGroupCreate(IntPtr json_group_create_param, CommonValueCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMGroupDelete(IntPtr group_id, CommonValueCallback cb, IntPtr user_data);



        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMGroupJoin(IntPtr group_id, IntPtr hello_message, CommonValueCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMGroupQuit(IntPtr group_id, CommonValueCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMGroupInviteMember(IntPtr json_group_invite_param, CommonValueCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMGroupDeleteMember(IntPtr json_group_delete_param, CommonValueCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMGroupGetJoinedGroupList(CommonValueCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMGroupGetGroupInfoList(IntPtr group_id_list, CommonValueCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]

        public static extern int TIMGroupModifyGroupInfo(IntPtr json_group_modifyinfo_param, CommonValueCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMGroupGetMemberInfoList(IntPtr json_group_getmeminfos_param, CommonValueCallback cb, IntPtr user_data);
        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMGroupModifyMemberInfo(IntPtr json_group_modifymeminfo_param, CommonValueCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMGroupGetPendencyList(IntPtr json_group_getpendence_list_param, CommonValueCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMGroupReportPendencyReaded(long time_stamp, CommonValueCallback cb, IntPtr user_data);
        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMGroupHandlePendency(IntPtr json_group_handle_pendency_param, CommonValueCallback cb, IntPtr user_data);


        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMGroupGetOnlineMemberCount(IntPtr group_id, CommonValueCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMGroupSearchGroups(IntPtr json_group_search_groups_param, CommonValueCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMGroupSearchGroupMembers(IntPtr json_group_search_group_members_param, CommonValueCallback cb, IntPtr user_data);
        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMGroupInitGroupAttributes(IntPtr group_id, IntPtr json_group_atrributes, CommonValueCallback cb, IntPtr user_data);
        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMGroupDeleteGroupAttributes(IntPtr group_id, IntPtr json_keys, CommonValueCallback cb, IntPtr user_data);
        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMGroupGetGroupAttributes(IntPtr group_id, IntPtr json_keys, CommonValueCallback cb, IntPtr user_data);
        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]


        public static extern int TIMProfileGetUserProfileList(IntPtr json_get_user_profile_list_param, CommonValueCallback cb, IntPtr user_data);
        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMProfileModifySelfUserProfile(IntPtr json_modify_self_user_profile_param, CommonValueCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMFriendshipGetFriendProfileList(CommonValueCallback cb, IntPtr user_data);
        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMFriendshipAddFriend(IntPtr json_add_friend_param, CommonValueCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMFriendshipHandleFriendAddRequest(IntPtr json_handle_friend_add_param, CommonValueCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMFriendshipModifyFriendProfile(IntPtr json_modify_friend_info_param, CommonValueCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMFriendshipDeleteFriend(IntPtr json_delete_friend_param, CommonValueCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMFriendshipCheckFriendType(IntPtr json_check_friend_list_param, CommonValueCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMFriendshipCreateFriendGroup(IntPtr json_create_friend_group_param, CommonValueCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMFriendshipGetFriendGroupList(IntPtr json_get_friend_group_list_param, CommonValueCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMFriendshipModifyFriendGroup(IntPtr json_modify_friend_group_param, CommonValueCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMFriendshipDeleteFriendGroup(IntPtr json_delete_friend_group_param, CommonValueCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMFriendshipAddToBlackList(IntPtr json_add_to_blacklist_param, CommonValueCallback cb, IntPtr user_data);


        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMFriendshipGetBlackList(CommonValueCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMFriendshipDeleteFromBlackList(IntPtr json_delete_from_blacklist_param, CommonValueCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMFriendshipGetPendencyList(IntPtr json_get_pendency_list_param, CommonValueCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMFriendshipDeletePendency(IntPtr json_delete_pendency_param, CommonValueCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMFriendshipReportPendencyReaded(long time_stamp, CommonValueCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMFriendshipSearchFriends(IntPtr json_search_friends_param, CommonValueCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int TIMFriendshipGetFriendsInfo(IntPtr json_get_friends_info_param, CommonValueCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern int callExperimentalAPI(IntPtr json_param, CommonValueCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern void TIMAddRecvNewMsgCallback(TIMRecvNewMsgCallback cb, IntPtr user_data);



        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern void TIMRemoveRecvNewMsgCallback(TIMRecvNewMsgCallback cb);


        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern void TIMSetMsgReadedReceiptCallback(TIMMsgReadedReceiptCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern void TIMSetMsgRevokeCallback(TIMMsgRevokeCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern void TIMSetMsgElemUploadProgressCallback(TIMMsgElemUploadProgressCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern void TIMSetGroupTipsEventCallback(TIMGroupTipsEventCallback cb, IntPtr user_data);
        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern void TIMSetGroupAttributeChangedCallback(TIMGroupAttributeChangedCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern void TIMSetConvEventCallback(TIMConvEventCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern void TIMSetConvTotalUnreadMessageCountChangedCallback(TIMConvTotalUnreadMessageCountChangedCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern void TIMSetNetworkStatusListenerCallback(TIMNetworkStatusListenerCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern void TIMSetKickedOfflineCallback(TIMKickedOfflineCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern void TIMSetUserSigExpiredCallback(TIMUserSigExpiredCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern void TIMSetOnAddFriendCallback(TIMOnAddFriendCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern void TIMSetOnDeleteFriendCallback(TIMOnDeleteFriendCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern void TIMSetUpdateFriendProfileCallback(TIMUpdateFriendProfileCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern void TIMSetFriendAddRequestCallback(TIMFriendAddRequestCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern void TIMSetFriendApplicationListDeletedCallback(TIMFriendApplicationListDeletedCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern void TIMSetFriendApplicationListReadCallback(TIMFriendApplicationListReadCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern void TIMSetFriendBlackListAddedCallback(TIMFriendBlackListAddedCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern void TIMSetFriendBlackListDeletedCallback(TIMFriendBlackListDeletedCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern void TIMSetLogCallback(TIMLogCallback cb, IntPtr user_data);

        [DllImport(MyLibName, CallingConvention = CallingConvention.Cdecl)]
        public static extern void TIMSetMsgUpdateCallback(TIMMsgUpdateCallback cb, IntPtr user_data);







        [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
        public delegate void CommonValueCallback(int code, IntPtr desc, IntPtr json_param, IntPtr user_data);

        [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
        public delegate void TIMRecvNewMsgCallback(IntPtr json_msg_array, IntPtr user_data);

        [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
        public delegate void TIMMsgReadedReceiptCallback(IntPtr json_msg_readed_receipt_array, IntPtr user_data);

        [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
        public delegate void TIMMsgRevokeCallback(IntPtr json_msg_locator_array, IntPtr user_data);

        [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
        public delegate void TIMMsgElemUploadProgressCallback(IntPtr json_msg, int index, int cur_size, int total_size, IntPtr user_data);

        [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
        public delegate void TIMGroupTipsEventCallback(IntPtr json_group_tip_array, IntPtr user_data);

        [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
        public delegate void TIMGroupAttributeChangedCallback(IntPtr group_id, IntPtr json_group_attibute_array, IntPtr user_data);

        [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
        public delegate void TIMConvEventCallback(int conv_event, IntPtr json_conv_array, IntPtr user_data);

        [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
        public delegate void TIMConvTotalUnreadMessageCountChangedCallback(int total_unread_count, IntPtr user_data);
        [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
        public delegate void TIMNetworkStatusListenerCallback(int status, int code, IntPtr desc, IntPtr user_data);

        [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
        public delegate void TIMKickedOfflineCallback(IntPtr user_data);

        [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
        public delegate void TIMUserSigExpiredCallback(IntPtr user_data);

        [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
        public delegate void TIMOnAddFriendCallback(IntPtr json_identifier_array, IntPtr user_data);

        [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
        public delegate void TIMOnDeleteFriendCallback(IntPtr json_identifier_array, IntPtr user_data);

        [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
        public delegate void TIMUpdateFriendProfileCallback(IntPtr json_friend_profile_update_array, IntPtr user_data);

        [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
        public delegate void TIMFriendAddRequestCallback(IntPtr json_friend_add_request_pendency_array, IntPtr user_data);
        [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
        public delegate void TIMFriendApplicationListDeletedCallback(IntPtr json_identifier_array, IntPtr user_data);

        [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
        public delegate void TIMFriendApplicationListReadCallback(IntPtr user_data);

        [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
        public delegate void TIMFriendBlackListAddedCallback(IntPtr json_friend_black_added_array, IntPtr user_data);

        [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
        public delegate void TIMFriendBlackListDeletedCallback(IntPtr json_identifier_array, IntPtr user_data);

        [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
        public delegate void TIMLogCallback(int level, IntPtr log, IntPtr user_data);
        [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
        public delegate void TIMMsgUpdateCallback(IntPtr json_msg_array, IntPtr user_data);

        [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
        public delegate void CommonCallback(int code, IntPtr user_data);


       
    }
}