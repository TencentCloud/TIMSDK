using com.tencent.imsdk.unity.types;
using com.tencent.imsdk.unity.enums;
using System.Runtime.InteropServices;
using System.Collections.Generic;
using System;

namespace com.tencent.imsdk.unity.callback
{

    /// <summary>
    /// 异步方法回调
    /// </summary>
    [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
    public delegate void ValueCallback(int code, string desc, string data, string user_data);

    /// <summary>
    /// 新消息回调
    /// </summary>
    [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
    public delegate void RecvNewMsgCallback(string message, string user_data);

    /// <summary>
    /// 消息已读回调
    /// </summary>
    [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
    public delegate void MsgReadedReceiptCallback(string message_receipt, string user_data);

    /// <summary>
    /// 消息被撤回回调
    /// </summary>
    [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
    public delegate void MsgRevokeCallback(string msg_locator, string user_data);

    /// <summary>
    /// 消息被撤回回调
    /// </summary>
    [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
    public delegate void MsgElemUploadProgressCallback(string message, int index, int cur_size, int total_size, string user_data);

    /// <summary>
    /// 群tips
    /// </summary>
    [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
    public delegate void GroupTipsEventCallback(string message, string user_data);

    /// <summary>
    /// 群属性改变
    /// </summary>
    [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
    public delegate void GroupAttributeChangedCallback(string group_id, string group_attributes, string user_data);

    /// <summary>
    /// 会话信息回调
    /// </summary>
    [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
    public delegate void ConvEventCallback(TIMConvEvent conv_event, string conv_list, string user_data);

    /// <summary>
    /// 全部未读数改变
    /// </summary>
    [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
    public delegate void ConvTotalUnreadMessageCountChangedCallback(int total_unread_count, string user_data);

    /// <summary>
    /// 网络改变
    /// </summary>
    [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
    public delegate void NetworkStatusListenerCallback(TIMNetworkStatus status, int code, string desc, string user_data);

    /// <summary>
    /// 被踢下线回调
    /// </summary>
    [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
    public delegate void KickedOfflineCallback(string user_data);

    /// <summary>
    /// 登录票据过期回调
    /// </summary>
    [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
    public delegate void UserSigExpiredCallback(string user_data);

    /// <summary>
    /// 添加好友回调
    /// </summary>
    [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
    public delegate void OnAddFriendCallback(string userids, string user_data);

    /// <summary>
    /// 删除好友回调
    /// </summary>
    [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
    public delegate void OnDeleteFriendCallback(string userids, string user_data);

    /// <summary>
    /// 好友资料改变回调
    /// </summary>
    [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
    public delegate void UpdateFriendProfileCallback(string friend_profile_update_array, string user_data);

    /// <summary>
    /// 申请加好友回调
    /// </summary>
    [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
    public delegate void FriendAddRequestCallback(string friend_add_request_pendency_array, string user_data);

    /// <summary>
    /// 好友申请被删除回调
    /// </summary>
    [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
    public delegate void FriendApplicationListDeletedCallback(string userids, string user_data);

    /// <summary>
    /// 好友申请已读回调
    /// </summary>
    [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
    public delegate void FriendApplicationListReadCallback(string user_data);

    /// <summary>
    /// 黑名单添加回调
    /// </summary>
    [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
    public delegate void FriendBlackListAddedCallback(string friend_black_added_array, string user_data);

    /// <summary>
    /// 黑名单删除回调
    /// </summary>
    [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
    public delegate void FriendBlackListDeletedCallback(string userids, string user_data);

    /// <summary>
    /// 日志回调
    /// </summary>
    [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
    public delegate void LogCallback(TIMLogLevel log_level, string log, string user_data);

    /// <summary>
    /// 消息被修改回调
    /// </summary>
    [UnmanagedFunctionPointer(CallingConvention.Cdecl)]
    public delegate void MsgUpdateCallback(string message_list, string user_data);

}