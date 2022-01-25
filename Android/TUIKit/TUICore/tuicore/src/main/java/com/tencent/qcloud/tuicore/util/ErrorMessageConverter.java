package com.tencent.qcloud.tuicore.util;

import com.tencent.imsdk.BaseConstants;
import com.tencent.qcloud.tuicore.R;
import com.tencent.qcloud.tuicore.TUIConfig;

public class ErrorMessageConverter {

    public static String convertIMError(int code, String msg) {
        switch (code) {
            case BaseConstants.ERR_IN_PROGESS:
                return getLocalizedString(R.string.TUIKitErrorInProcess); // @"执行中";
            case BaseConstants.ERR_INVALID_PARAMETERS:
                return getLocalizedString(R.string.TUIKitErrorInvalidParameters);// @"参数无效";
            case BaseConstants.ERR_IO_OPERATION_FAILED:
                return getLocalizedString(R.string.TUIKitErrorIOOperateFaild); // @"操作本地 IO 错误";
            case BaseConstants.ERR_INVALID_JSON:
                return getLocalizedString(R.string.TUIKitErrorInvalidJson); // @"错误的 JSON 格式";
            case BaseConstants.ERR_OUT_OF_MEMORY:
                return getLocalizedString(R.string.TUIKitErrorOutOfMemory); // @"内存不足";
            case BaseConstants.ERR_PARSE_RESPONSE_FAILED:
                return getLocalizedString(R.string.TUIKitErrorParseResponseFaild); // @"PB 解析失败";
            case BaseConstants.ERR_SERIALIZE_REQ_FAILED:
                return getLocalizedString(R.string.TUIKitErrorSerializeReqFaild); // @"PB 序列化失败";
            case BaseConstants.ERR_SDK_NOT_INITIALIZED:
                return getLocalizedString(R.string.TUIKitErrorSDKNotInit); // @"IM SDK 未初始化";
            case BaseConstants.ERR_LOADMSG_FAILED:
                return getLocalizedString(R.string.TUIKitErrorLoadMsgFailed); // @"加载本地数据库操作失败";
            case BaseConstants.ERR_DATABASE_OPERATE_FAILED:
                return getLocalizedString(R.string.TUIKitErrorDatabaseOperateFailed); // @"本地数据库操作失败";
            case BaseConstants.ERR_SDK_COMM_CROSS_THREAD:
                return getLocalizedString(R.string.TUIKitErrorCrossThread); // @"跨线程错误";
            case BaseConstants.ERR_SDK_COMM_TINYID_EMPTY:
                return getLocalizedString(R.string.TUIKitErrorTinyIdEmpty); // @"TinyId 为空";
            case BaseConstants.ERR_SDK_COMM_INVALID_IDENTIFIER:
                return getLocalizedString(R.string.TUIKitErrorInvalidIdentifier); // @"Identifier 非法";
            case BaseConstants.ERR_SDK_COMM_FILE_NOT_FOUND:
                return getLocalizedString(R.string.TUIKitErrorFileNotFound); // @"文件不存在";
            case BaseConstants.ERR_SDK_COMM_FILE_TOO_LARGE:
                return getLocalizedString(R.string.TUIKitErrorFileTooLarge); // @"文件大小超出了限制";
            case BaseConstants.ERR_SDK_COMM_FILE_SIZE_EMPTY:
                return getLocalizedString(R.string.TUIKitErrorEmptyFile); // @"空文件";
            case BaseConstants.ERR_SDK_COMM_FILE_OPEN_FAILED:
                return getLocalizedString(R.string.TUIKitErrorFileOpenFailed); // @"文件打开失败";

            // 帐号错误码

            case BaseConstants.ERR_SDK_NOT_LOGGED_IN:
                return getLocalizedString(R.string.TUIKitErrorNotLogin); // @"IM SDK 未登录";
            case BaseConstants.ERR_NO_PREVIOUS_LOGIN:
                return getLocalizedString(R.string.TUIKitErrorNoPreviousLogin); // @"并没有登录过该用户";
            case BaseConstants.ERR_USER_SIG_EXPIRED:
                return getLocalizedString(R.string.TUIKitErrorUserSigExpired); // @"UserSig 过期";
            case BaseConstants.ERR_LOGIN_KICKED_OFF_BY_OTHER:
                return getLocalizedString(R.string.TUIKitErrorLoginKickedOffByOther); // @"其他终端登录同一个帐号";
//        case BaseConstants.ERR_LOGIN_IN_PROCESS:
//            return @"登录正在执行中";
//        case BaseConstants.ERR_LOGOUT_IN_PROCESS:
//            return @"登出正在执行中";
            case BaseConstants.ERR_SDK_ACCOUNT_TLS_INIT_FAILED:
                return getLocalizedString(R.string.TUIKitErrorTLSSDKInit); // @"TLS SDK 初始化失败";
            case BaseConstants.ERR_SDK_ACCOUNT_TLS_NOT_INITIALIZED:
                return getLocalizedString(R.string.TUIKitErrorTLSSDKUninit); // @"TLS SDK 未初始化";
            case BaseConstants.ERR_SDK_ACCOUNT_TLS_TRANSPKG_ERROR:
                return getLocalizedString(R.string.TUIKitErrorTLSSDKTRANSPackageFormat); // @"TLS SDK TRANS 包格式错误";
            case BaseConstants.ERR_SDK_ACCOUNT_TLS_DECRYPT_FAILED:
                return getLocalizedString(R.string.TUIKitErrorTLSDecrypt); // @"TLS SDK 解密失败";
            case BaseConstants.ERR_SDK_ACCOUNT_TLS_REQUEST_FAILED:
                return getLocalizedString(R.string.TUIKitErrorTLSSDKRequest); // @"TLS SDK 请求失败";
            case BaseConstants.ERR_SDK_ACCOUNT_TLS_REQUEST_TIMEOUT:
                return getLocalizedString(R.string.TUIKitErrorTLSSDKRequestTimeout); // @"TLS SDK 请求超时";

            // 消息错误码

            case BaseConstants.ERR_INVALID_CONVERSATION:
                return getLocalizedString(R.string.TUIKitErrorInvalidConveration); // @"会话无效";
            case BaseConstants.ERR_FILE_TRANS_AUTH_FAILED:
                return getLocalizedString(R.string.TUIKitErrorFileTransAuthFailed); // @"文件传输鉴权失败";
            case BaseConstants.ERR_FILE_TRANS_NO_SERVER:
                return getLocalizedString(R.string.TUIKitErrorFileTransNoServer); // @"文件传输获取 Server 列表失败";
            case BaseConstants.ERR_FILE_TRANS_UPLOAD_FAILED:
                return getLocalizedString(R.string.TUIKitErrorFileTransUploadFailed); // @"文件传输上传失败，请检查网络是否连接";
//            case BaseConstants.ERR_IMAGE_UPLOAD_FAILED_NOTIMAGE:
//                return TUIKitLocalizableString(R.string.TUIKitErrorFileTransUploadFailedNotImage); // @"文件传输上传失败，请检查上传的图片是否能够正常打开";
            case BaseConstants.ERR_FILE_TRANS_DOWNLOAD_FAILED:
                return getLocalizedString(R.string.TUIKitErrorFileTransDownloadFailed); // @"文件传输下载失败，请检查网络，或者文件、语音是否已经过期";
            case BaseConstants.ERR_HTTP_REQ_FAILED:
                return getLocalizedString(R.string.TUIKitErrorHTTPRequestFailed); // @"HTTP 请求失败";
            case BaseConstants.ERR_INVALID_MSG_ELEM:
                return getLocalizedString(R.string.TUIKitErrorInvalidMsgElem); // @"IM SDK 无效消息 elem";
            case BaseConstants.ERR_INVALID_SDK_OBJECT:
                return getLocalizedString(R.string.TUIKitErrorInvalidSDKObject); // @"无效的对象";
            case BaseConstants.ERR_SDK_MSG_BODY_SIZE_LIMIT:
                return getLocalizedString(R.string.TUIKitSDKMsgBodySizeLimit); // @"消息长度超出限制";
            case BaseConstants.ERR_SDK_MSG_KEY_REQ_DIFFER_RSP:
                return getLocalizedString(R.string.TUIKitErrorSDKMsgKeyReqDifferRsp); // @"消息 KEY 错误";

            // 群组错误码

            case BaseConstants.ERR_SDK_GROUP_INVALID_ID:
                return getLocalizedString(R.string.TUIKitErrorSDKGroupInvalidID); // @"群组 ID 非法，自定义群组 ID 必须为可打印 ASCII 字符（0x20-0x7e），最长48个字节，且前缀不能为 @TGS#";
            case BaseConstants.ERR_SDK_GROUP_INVALID_NAME:
                return getLocalizedString(R.string.TUIKitErrorSDKGroupInvalidName); // @"群名称非法，群名称最长30字节";
            case BaseConstants.ERR_SDK_GROUP_INVALID_INTRODUCTION:
                return getLocalizedString(R.string.TUIKitErrorSDKGroupInvalidIntroduction); // @"群简介非法，群简介最长240字节";
            case BaseConstants.ERR_SDK_GROUP_INVALID_NOTIFICATION:
                return getLocalizedString(R.string.TUIKitErrorSDKGroupInvalidNotification); // @"群公告非法，群公告最长300字节";
            case BaseConstants.ERR_SDK_GROUP_INVALID_FACE_URL:
                return getLocalizedString(R.string.TUIKitErrorSDKGroupInvalidFaceURL); // @"群头像 URL 非法，群头像 URL 最长100字节";
            case BaseConstants.ERR_SDK_GROUP_INVALID_NAME_CARD:
                return getLocalizedString(R.string.TUIKitErrorSDKGroupInvalidNameCard); // @"群名片非法，群名片最长50字节";
            case BaseConstants.ERR_SDK_GROUP_MEMBER_COUNT_LIMIT:
                return getLocalizedString(R.string.TUIKitErrorSDKGroupMemberCountLimit); // @"超过群组成员数的限制";
            case BaseConstants.ERR_SDK_GROUP_JOIN_PRIVATE_GROUP_DENY:
                return getLocalizedString(R.string.TUIKitErrorSDKGroupJoinPrivateGroupDeny); // @"不允许申请加入 Private 群组";
            case BaseConstants.ERR_SDK_GROUP_INVITE_SUPER_DENY:
                return getLocalizedString(R.string.TUIKitErrorSDKGroupInviteSuperDeny); // @"不允许邀请角色为群主的成员";
            case BaseConstants.ERR_SDK_GROUP_INVITE_NO_MEMBER:
                return getLocalizedString(R.string.TUIKitErrorSDKGroupInviteNoMember); // @"不允许邀请0个成员";

            // 关系链错误码

            case BaseConstants.ERR_SDK_FRIENDSHIP_INVALID_PROFILE_KEY:
                return getLocalizedString(R.string.TUIKitErrorSDKFriendShipInvalidProfileKey); // @"资料字段非法";
            case BaseConstants.ERR_SDK_FRIENDSHIP_INVALID_ADD_REMARK:
                return getLocalizedString(R.string.TUIKitErrorSDKFriendshipInvalidAddRemark); // @"备注字段非法，最大96字节";
            case BaseConstants.ERR_SDK_FRIENDSHIP_INVALID_ADD_WORDING:
                return getLocalizedString(R.string.TUIKitErrorSDKFriendshipInvalidAddWording); // @"请求添加好友的请求说明字段非法，最大120字节";
            case BaseConstants.ERR_SDK_FRIENDSHIP_INVALID_ADD_SOURCE:
                return getLocalizedString(R.string.TUIKitErrorSDKFriendshipInvalidAddSource); // @"请求添加好友的添加来源字段非法，来源需要添加“AddSource_Type_”前缀。";
            case BaseConstants.ERR_SDK_FRIENDSHIP_FRIEND_GROUP_EMPTY:
                return getLocalizedString(R.string.TUIKitErrorSDKFriendshipFriendGroupEmpty); // @"好友分组字段非法，必须不为空，每个分组的名称最长30字节";

            // 网络

            case BaseConstants.ERR_SDK_NET_ENCODE_FAILED:
                return getLocalizedString(R.string.TUIKitErrorSDKNetEncodeFailed); // @"SSO 加密失败";
            case BaseConstants.ERR_SDK_NET_DECODE_FAILED:
                return getLocalizedString(R.string.TUIKitErrorSDKNetDecodeFailed); // @"SSO 解密失败";
            case BaseConstants.ERR_SDK_NET_AUTH_INVALID:
                return getLocalizedString(R.string.TUIKitErrorSDKNetAuthInvalid); // @"SSO 未完成鉴权";
            case BaseConstants.ERR_SDK_NET_COMPRESS_FAILED:
                return getLocalizedString(R.string.TUIKitErrorSDKNetCompressFailed); // @"数据包压缩失败";
            case BaseConstants.ERR_SDK_NET_UNCOMPRESS_FAILED:
                return getLocalizedString(R.string.TUIKitErrorSDKNetUncompressFaile); // @"数据包解压失败";
            case BaseConstants.ERR_SDK_NET_FREQ_LIMIT:
                return getLocalizedString(R.string.TUIKitErrorSDKNetFreqLimit); // @"调用频率限制，最大每秒发起 5 次请求。";
            case BaseConstants.ERR_SDK_NET_REQ_COUNT_LIMIT:
                return getLocalizedString(R.string.TUIKitErrorSDKnetReqCountLimit); // @"请求队列満，超过同时请求的数量限制，最大同时发起1000个请求。";
            case BaseConstants.ERR_SDK_NET_DISCONNECT:
                return getLocalizedString(R.string.TUIKitErrorSDKNetDisconnect); // @"网络已断开，未建立连接，或者建立 socket 连接时，检测到无网络。";
            case BaseConstants.ERR_SDK_NET_ALLREADY_CONN:
                return getLocalizedString(R.string.TUIKitErrorSDKNetAllreadyConn); // @"网络连接已建立，重复创建连接";
            case BaseConstants.ERR_SDK_NET_CONN_TIMEOUT:
                return getLocalizedString(R.string.TUIKitErrorSDKNetConnTimeout); // @"建立网络连接超时，请等网络恢复后重试。";
            case BaseConstants.ERR_SDK_NET_CONN_REFUSE:
                return getLocalizedString(R.string.TUIKitErrorSDKNetConnRefuse); // @"网络连接已被拒绝，请求过于频繁，服务端拒绝服务。";
            case BaseConstants.ERR_SDK_NET_NET_UNREACH:
                return getLocalizedString(R.string.TUIKitErrorSDKNetNetUnreach); // @"没有到达网络的可用路由，请等网络恢复后重试。";
            case BaseConstants.ERR_SDK_NET_SOCKET_NO_BUFF:
                return getLocalizedString(R.string.TUIKitErrorSDKNetSocketNoBuff); // @"系统中没有足够的缓冲区空间资源可用来完成调用，系统过于繁忙，内部错误。";
            case BaseConstants.ERR_SDK_NET_RESET_BY_PEER:
                return getLocalizedString(R.string.TUIKitERRORSDKNetResetByPeer); // @"对端重置了连接";
            case BaseConstants.ERR_SDK_NET_SOCKET_INVALID:
                return getLocalizedString(R.string.TUIKitErrorSDKNetSOcketInvalid); // @"socket 套接字无效";
            case BaseConstants.ERR_SDK_NET_HOST_GETADDRINFO_FAILED:
                return getLocalizedString(R.string.TUIKitErrorSDKNetHostGetAddressFailed); // @"IP 地址解析失败";
            case BaseConstants.ERR_SDK_NET_CONNECT_RESET:
                return getLocalizedString(R.string.TUIKitErrorSDKNetConnectReset); // @"网络连接到中间节点或服务端重置";
            case BaseConstants.ERR_SDK_NET_WAIT_INQUEUE_TIMEOUT:
                return getLocalizedString(R.string.TUIKitErrorSDKNetWaitInQueueTimeout); // @"请求包等待进入待发送队列超时";
            case BaseConstants.ERR_SDK_NET_WAIT_SEND_TIMEOUT:
                return getLocalizedString(R.string.TUIKitErrorSDKNetWaitSendTimeout); // @"请求包已进入待发送队列，等待进入系统的网络 buffer 超时";
            case BaseConstants.ERR_SDK_NET_WAIT_ACK_TIMEOUT:
                return getLocalizedString(R.string.TUIKitErrorSDKNetWaitAckTimeut); // @"请求包已进入系统的网络 buffer ，等待服务端回包超时";

            /////////////////////////////////////////////////////////////////////////////////
            //
            //                      （二）服务端
            //
            /////////////////////////////////////////////////////////////////////////////////

            // SSO

            case BaseConstants.ERR_SVR_SSO_CONNECT_LIMIT:
                return getLocalizedString(R.string.TUIKitErrorSDKSVRSSOConnectLimit); // @"SSO 的连接数量超出限制，服务端拒绝服务。";
            case BaseConstants.ERR_SVR_SSO_VCODE:
                return getLocalizedString(R.string.TUIKitErrorSDKSVRSSOVCode); // @"下发验证码标志错误。";
            case BaseConstants.ERR_SVR_SSO_D2_EXPIRED:
                return getLocalizedString(R.string.TUIKitErrorSVRSSOD2Expired); // @"D2 过期";
            case BaseConstants.ERR_SVR_SSO_A2_UP_INVALID:
                return getLocalizedString(R.string.TUIKitErrorSVRA2UpInvalid); // @"A2 校验失败";
            case BaseConstants.ERR_SVR_SSO_A2_DOWN_INVALID:
                return getLocalizedString(R.string.TUIKitErrorSVRA2DownInvalid); // @"处理下行包时发现 A2 验证没通过或者被安全打击。";
            case BaseConstants.ERR_SVR_SSO_EMPTY_KEY:
                return getLocalizedString(R.string.TUIKitErrorSVRSSOEmpeyKey); // @"不允许空 D2Key 加密。";
            case BaseConstants.ERR_SVR_SSO_UIN_INVALID:
                return getLocalizedString(R.string.TUIKitErrorSVRSSOUinInvalid); // @"D2 中的 uin 和 SSO 包头的 uin 不匹配。";
            case BaseConstants.ERR_SVR_SSO_VCODE_TIMEOUT:
                return getLocalizedString(R.string.TUIKitErrorSVRSSOVCodeTimeout); // @"验证码下发超时。";
            case BaseConstants.ERR_SVR_SSO_NO_IMEI_AND_A2:
                return getLocalizedString(R.string.TUIKitErrorSVRSSONoImeiAndA2); // @"需要带上 IMEI 和 A2 。";
            case BaseConstants.ERR_SVR_SSO_COOKIE_INVALID:
                return getLocalizedString(R.string.TUIKitErrorSVRSSOCookieInvalid); // @"Cookie 非法。";
            case BaseConstants.ERR_SVR_SSO_DOWN_TIP:
                return getLocalizedString(R.string.TUIKitErrorSVRSSODownTips); // @"下发提示语，D2 过期。";
            case BaseConstants.ERR_SVR_SSO_DISCONNECT:
                return getLocalizedString(R.string.TUIKitErrorSVRSSODisconnect); // @"断链锁屏。";
            case BaseConstants.ERR_SVR_SSO_IDENTIFIER_INVALID:
                return getLocalizedString(R.string.TUIKitErrorSVRSSOIdentifierInvalid); // @"失效身份。";
            case BaseConstants.ERR_SVR_SSO_CLIENT_CLOSE:
                return getLocalizedString(R.string.TUIKitErrorSVRSSOClientClose); // @"终端自动退出。";
            case BaseConstants.ERR_SVR_SSO_MSFSDK_QUIT:
                return getLocalizedString(R.string.TUIKitErrorSVRSSOMSFSDKQuit); // @"MSFSDK 自动退出。";
            case BaseConstants.ERR_SVR_SSO_D2KEY_WRONG:
                return getLocalizedString(R.string.TUIKitErrorSVRSSOD2KeyWrong); // @"SSO D2key 解密失败次数太多，通知终端需要重置，重新刷新 D2 。";
            case BaseConstants.ERR_SVR_SSO_UNSURPPORT:
                return getLocalizedString(R.string.TUIKitErrorSVRSSOUnsupport); // @"不支持聚合，给终端返回统一的错误码。终端在该 TCP 长连接上停止聚合。";
            case BaseConstants.ERR_SVR_SSO_PREPAID_ARREARS:
                return getLocalizedString(R.string.TUIKitErrorSVRSSOPrepaidArrears); // @"预付费欠费。";
            case BaseConstants.ERR_SVR_SSO_PACKET_WRONG:
                return getLocalizedString(R.string.TUIKitErrorSVRSSOPacketWrong); // @"请求包格式错误。";
            case BaseConstants.ERR_SVR_SSO_APPID_BLACK_LIST:
                return getLocalizedString(R.string.TUIKitErrorSVRSSOAppidBlackList); // @"SDKAppID 黑名单。";
            case BaseConstants.ERR_SVR_SSO_CMD_BLACK_LIST:
                return getLocalizedString(R.string.TUIKitErrorSVRSSOCmdBlackList); // @"SDKAppID 设置 service cmd 黑名单。";
            case BaseConstants.ERR_SVR_SSO_APPID_WITHOUT_USING:
                return getLocalizedString(R.string.TUIKitErrorSVRSSOAppidWithoutUsing); // @"SDKAppID 停用。";
            case BaseConstants.ERR_SVR_SSO_FREQ_LIMIT:
                return getLocalizedString(R.string.TUIKitErrorSVRSSOFreqLimit); // @"频率限制(用户)，频率限制是设置针对某一个协议的每秒请求数的限制。";
            case BaseConstants.ERR_SVR_SSO_OVERLOAD:
                return getLocalizedString(R.string.TUIKitErrorSVRSSOOverload); // @"过载丢包(系统)，连接的服务端处理过多请求，处理不过来，拒绝服务。";

            // 资源文件错误码

            case BaseConstants.ERR_SVR_RES_NOT_FOUND:
                return getLocalizedString(R.string.TUIKitErrorSVRResNotFound); // @"要发送的资源文件不存在。";
            case BaseConstants.ERR_SVR_RES_ACCESS_DENY:
                return getLocalizedString(R.string.TUIKitErrorSVRResAccessDeny); // @"要发送的资源文件不允许访问。";
            case BaseConstants.ERR_SVR_RES_SIZE_LIMIT:
                return getLocalizedString(R.string.TUIKitErrorSVRResSizeLimit); // @"文件大小超过限制。";
            case BaseConstants.ERR_SVR_RES_SEND_CANCEL:
                return getLocalizedString(R.string.TUIKitErrorSVRResSendCancel); // @"用户取消发送，如发送过程中登出等原因。";
            case BaseConstants.ERR_SVR_RES_READ_FAILED:
                return getLocalizedString(R.string.TUIKitErrorSVRResReadFailed); // @"读取文件内容失败。";
            case BaseConstants.ERR_SVR_RES_TRANSFER_TIMEOUT:
                return getLocalizedString(R.string.TUIKitErrorSVRResTransferTimeout); // @"资源文件传输超时";
            case BaseConstants.ERR_SVR_RES_INVALID_PARAMETERS:
                return getLocalizedString(R.string.TUIKitErrorSVRResInvalidParameters); // @"参数非法。";
            case BaseConstants.ERR_SVR_RES_INVALID_FILE_MD5:
                return getLocalizedString(R.string.TUIKitErrorSVRResInvalidFileMd5); // @"文件 MD5 校验失败。";
            case BaseConstants.ERR_SVR_RES_INVALID_PART_MD5:
                return getLocalizedString(R.string.TUIKitErrorSVRResInvalidPartMd5); // @"分片 MD5 校验失败。";

            // 后台公共错误码

            case BaseConstants.ERR_SVR_COMM_INVALID_HTTP_URL:
                return getLocalizedString(R.string.TUIKitErrorSVRCommonInvalidHttpUrl); // @"HTTP 解析错误 ，请检查 HTTP 请求 URL 格式。";
            case BaseConstants.ERR_SVR_COMM_REQ_JSON_PARSE_FAILED:
                return getLocalizedString(R.string.TUIKitErrorSVRCommomReqJsonParseFailed); // @"HTTP 请求 JSON 解析错误，请检查 JSON 格式。";
            case BaseConstants.ERR_SVR_COMM_INVALID_ACCOUNT:
                return getLocalizedString(R.string.TUIKitErrorSVRCommonInvalidAccount); // @"请求 URI 或 JSON 包体中 Identifier 或 UserSig 错误。";
            case BaseConstants.ERR_SVR_COMM_INVALID_ACCOUNT_EX:
                return getLocalizedString(R.string.TUIKitErrorSVRCommonInvalidAccount); // @"请求 URI 或 JSON 包体中 Identifier 或 UserSig 错误。";
            case BaseConstants.ERR_SVR_COMM_INVALID_SDKAPPID:
                return getLocalizedString(R.string.TUIKitErrorSVRCommonInvalidSdkappid); // @"SDKAppID 失效，请核对 SDKAppID 有效性。";
            case BaseConstants.ERR_SVR_COMM_REST_FREQ_LIMIT:
                return getLocalizedString(R.string.TUIKitErrorSVRCommonRestFreqLimit); // @"REST 接口调用频率超过限制，请降低请求频率。";
            case BaseConstants.ERR_SVR_COMM_REQUEST_TIMEOUT:
                return getLocalizedString(R.string.TUIKitErrorSVRCommonRequestTimeout); // @"服务请求超时或 HTTP 请求格式错误，请检查并重试。";
            case BaseConstants.ERR_SVR_COMM_INVALID_RES:
                return getLocalizedString(R.string.TUIKitErrorSVRCommonInvalidRes); // @"请求资源错误，请检查请求 URL。";
            case BaseConstants.ERR_SVR_COMM_ID_NOT_ADMIN:
                return getLocalizedString(R.string.TUIKitErrorSVRCommonIDNotAdmin); // @"REST API 请求的 Identifier 字段请填写 App 管理员帐号。";
            case BaseConstants.ERR_SVR_COMM_SDKAPPID_FREQ_LIMIT:
                return getLocalizedString(R.string.TUIKitErrorSVRCommonSdkappidFreqLimit); // @"SDKAppID 请求频率超限，请降低请求频率。";
            case BaseConstants.ERR_SVR_COMM_SDKAPPID_MISS:
                return getLocalizedString(R.string.TUIKitErrorSVRCommonSdkappidMiss); // @"REST 接口需要带 SDKAppID，请检查请求 URL 中的 SDKAppID。";
            case BaseConstants.ERR_SVR_COMM_RSP_JSON_PARSE_FAILED:
                return getLocalizedString(R.string.TUIKitErrorSVRCommonRspJsonParseFailed); // @"HTTP 响应包 JSON 解析错误。";
            case BaseConstants.ERR_SVR_COMM_EXCHANGE_ACCOUNT_TIMEUT:
                return getLocalizedString(R.string.TUIKitErrorSVRCommonExchangeAccountTimeout); // @"置换帐号超时。";
            case BaseConstants.ERR_SVR_COMM_INVALID_ID_FORMAT:
                return getLocalizedString(R.string.TUIKitErrorSVRCommonInvalidIdFormat); // @"请求包体 Identifier 类型错误，请确认 Identifier 为字符串格式。";
            case BaseConstants.ERR_SVR_COMM_SDKAPPID_FORBIDDEN:
                return getLocalizedString(R.string.TUIKitErrorSVRCommonSDkappidForbidden); // @"SDKAppID 被禁用";
            case BaseConstants.ERR_SVR_COMM_REQ_FORBIDDEN:
                return getLocalizedString(R.string.TUIKitErrorSVRCommonReqForbidden); // @"请求被禁用";
            case BaseConstants.ERR_SVR_COMM_REQ_FREQ_LIMIT:
                return getLocalizedString(R.string.TUIKitErrorSVRCommonReqFreqLimit); // @"请求过于频繁，请稍后重试。";
            case BaseConstants.ERR_SVR_COMM_REQ_FREQ_LIMIT_EX:
                return getLocalizedString(R.string.TUIKitErrorSVRCommonReqFreqLimit);  // @"请求过于频繁，请稍后重试。";
            case BaseConstants.ERR_SVR_COMM_INVALID_SERVICE:
                return getLocalizedString(R.string.TUIKitErrorSVRCommonInvalidService); // @"未购买套餐包或购买的套餐包正在配置中暂未生效，请五分钟后再次尝试。";
            case BaseConstants.ERR_SVR_COMM_SENSITIVE_TEXT:
                return getLocalizedString(R.string.TUIKitErrorSVRCommonSensitiveText); // @"文本安全打击，文本中可能包含敏感词汇。";
            case BaseConstants.ERR_SVR_COMM_BODY_SIZE_LIMIT:
                return getLocalizedString(R.string.TUIKitErrorSVRCommonBodySizeLimit); // @"发消息包体过长";

            // 帐号错误码

            case BaseConstants.ERR_SVR_ACCOUNT_USERSIG_EXPIRED:
                return getLocalizedString(R.string.TUIKitErrorSVRAccountUserSigExpired); // @"UserSig 已过期，请重新生成 UserSig";
            case BaseConstants.ERR_SVR_ACCOUNT_USERSIG_EMPTY:
                return getLocalizedString(R.string.TUIKitErrorSVRAccountUserSigEmpty); // @"UserSig 长度为0";
            case BaseConstants.ERR_SVR_ACCOUNT_USERSIG_CHECK_FAILED:
                return getLocalizedString(R.string.TUIKitErrorSVRAccountUserSigCheckFailed); // @"UserSig 校验失败";
            case BaseConstants.ERR_SVR_ACCOUNT_USERSIG_CHECK_FAILED_EX:
                return getLocalizedString(R.string.TUIKitErrorSVRAccountUserSigCheckFailed); // @"UserSig 校验失败";
            case BaseConstants.ERR_SVR_ACCOUNT_USERSIG_MISMATCH_PUBLICKEY:
                return getLocalizedString(R.string.TUIKitErrorSVRAccountUserSigMismatchPublicKey); // @"用公钥验证 UserSig 失败";
            case BaseConstants.ERR_SVR_ACCOUNT_USERSIG_MISMATCH_ID:
                return getLocalizedString(R.string.TUIKitErrorSVRAccountUserSigMismatchId); // @"请求的 Identifier 与生成 UserSig 的 Identifier 不匹配。";
            case BaseConstants.ERR_SVR_ACCOUNT_USERSIG_MISMATCH_SDKAPPID:
                return getLocalizedString(R.string.TUIKitErrorSVRAccountUserSigMismatchSdkAppid); // @"请求的 SDKAppID 与生成 UserSig 的 SDKAppID 不匹配。";
            case BaseConstants.ERR_SVR_ACCOUNT_USERSIG_PUBLICKEY_NOT_FOUND:
                return getLocalizedString(R.string.TUIKitErrorSVRAccountUserSigPublicKeyNotFound); // @"验证 UserSig 时公钥不存在";
            case BaseConstants.ERR_SVR_ACCOUNT_SDKAPPID_NOT_FOUND:
                return getLocalizedString(R.string.TUIKitErrorSVRAccountUserSigSdkAppidNotFount); // @"SDKAppID 未找到，请在云通信 IM 控制台确认应用信息。";
            case BaseConstants.ERR_SVR_ACCOUNT_INVALID_USERSIG:
                return getLocalizedString(R.string.TUIKitErrorSVRAccountInvalidUserSig); // @"UserSig 已经失效，请重新生成，再次尝试。";
            case BaseConstants.ERR_SVR_ACCOUNT_NOT_FOUND:
                return getLocalizedString(R.string.TUIKitErrorSVRAccountNotFound); // @"请求的用户帐号不存在。";
            case BaseConstants.ERR_SVR_ACCOUNT_SEC_RSTR:
                return getLocalizedString(R.string.TUIKitErrorSVRAccountSecRstr); // @"安全原因被限制。";
            case BaseConstants.ERR_SVR_ACCOUNT_INTERNAL_TIMEOUT:
                return getLocalizedString(R.string.TUIKitErrorSVRAccountInternalTimeout); // @"服务端内部超时，请重试。";
            case BaseConstants.ERR_SVR_ACCOUNT_INVALID_COUNT:
                return getLocalizedString(R.string.TUIKitErrorSVRAccountInvalidCount); // @"请求中批量数量不合法。";
            case BaseConstants.ERR_SVR_ACCOUNT_INVALID_PARAMETERS:
                return getLocalizedString(R.string.TUIkitErrorSVRAccountINvalidParameters); // @"参数非法，请检查必填字段是否填充，或者字段的填充是否满足协议要求。";
            case BaseConstants.ERR_SVR_ACCOUNT_ADMIN_REQUIRED:
                return getLocalizedString(R.string.TUIKitErrorSVRAccountAdminRequired); // @"请求需要 App 管理员权限。";
            case BaseConstants.ERR_SVR_ACCOUNT_FREQ_LIMIT:
                return getLocalizedString(R.string.TUIKitErrorSVRAccountFreqLimit); // @"因失败且重试次数过多导致被限制，请检查 UserSig 是否正确，一分钟之后再试。";
            case BaseConstants.ERR_SVR_ACCOUNT_BLACKLIST:
                return getLocalizedString(R.string.TUIKitErrorSVRAccountBlackList); // @"帐号被拉入黑名单。";
            case BaseConstants.ERR_SVR_ACCOUNT_COUNT_LIMIT:
                return getLocalizedString(R.string.TUIKitErrorSVRAccountCountLimit); // @"创建帐号数量超过免费体验版数量限制，请升级为专业版。";
            case BaseConstants.ERR_SVR_ACCOUNT_INTERNAL_ERROR:
                return getLocalizedString(R.string.TUIKitErrorSVRAccountInternalError); // @"服务端内部错误，请重试。";

            // 资料错误码

            case BaseConstants.ERR_SVR_PROFILE_INVALID_PARAMETERS:
                return getLocalizedString(R.string.TUIKitErrorSVRProfileInvalidParameters); // @"请求参数错误，请根据错误描述检查请求是否正确。";
            case BaseConstants.ERR_SVR_PROFILE_ACCOUNT_MISS:
                return getLocalizedString(R.string.TUIKitErrorSVRProfileAccountMiss); // @"请求参数错误，没有指定需要拉取资料的用户帐号。";
            case BaseConstants.ERR_SVR_PROFILE_ACCOUNT_NOT_FOUND:
                return getLocalizedString(R.string.TUIKitErrorSVRProfileAccountNotFound); // @"请求的用户帐号不存在。";
            case BaseConstants.ERR_SVR_PROFILE_ADMIN_REQUIRED:
                return getLocalizedString(R.string.TUIKitErrorSVRProfileAdminRequired); // @"请求需要 App 管理员权限。";
            case BaseConstants.ERR_SVR_PROFILE_SENSITIVE_TEXT:
                return getLocalizedString(R.string.TUIKitErrorSVRProfileSensitiveText); // @"资料字段中包含敏感词。";
            case BaseConstants.ERR_SVR_PROFILE_INTERNAL_ERROR:
                return getLocalizedString(R.string.TUIKitErrorSVRProfileInternalError); // @"服务端内部错误，请稍后重试。";
            case BaseConstants.ERR_SVR_PROFILE_READ_PERMISSION_REQUIRED:
                return getLocalizedString(R.string.TUIKitErrorSVRProfileReadWritePermissionRequired); // @"没有资料字段的读权限，详情可参见 资料字段。";
            case BaseConstants.ERR_SVR_PROFILE_WRITE_PERMISSION_REQUIRED:
                return getLocalizedString(R.string.TUIKitErrorSVRProfileReadWritePermissionRequired); // @"没有资料字段的写权限，详情可参见 资料字段。";
            case BaseConstants.ERR_SVR_PROFILE_TAG_NOT_FOUND:
                return getLocalizedString(R.string.TUIKitErrorSVRProfileTagNotFound); // @"资料字段的 Tag 不存在。";
            case BaseConstants.ERR_SVR_PROFILE_SIZE_LIMIT:
                return getLocalizedString(R.string.TUIKitErrorSVRProfileSizeLimit); // @"资料字段的 Value 长度超过500字节。";
            case BaseConstants.ERR_SVR_PROFILE_VALUE_ERROR:
                return getLocalizedString(R.string.TUIKitErrorSVRProfileValueError); // @"标配资料字段的 Value 错误，详情可参见 标配资料字段。";
            case BaseConstants.ERR_SVR_PROFILE_INVALID_VALUE_FORMAT:
                return getLocalizedString(R.string.TUIKitErrorSVRProfileInvalidValueFormat); // @"资料字段的 Value 类型不匹配，详情可参见 标配资料字段。";

            // 关系链错误码

            case BaseConstants.ERR_SVR_FRIENDSHIP_INVALID_PARAMETERS:
                return getLocalizedString(R.string.TUIKitErrorSVRFriendshipInvalidParameters); // @"请求参数错误，请根据错误描述检查请求是否正确。";
            case BaseConstants.ERR_SVR_FRIENDSHIP_INVALID_SDKAPPID:
                return getLocalizedString(R.string.TUIKitErrorSVRFriendshipInvalidSdkAppid); // @"SDKAppID 不匹配。";
            case BaseConstants.ERR_SVR_FRIENDSHIP_ACCOUNT_NOT_FOUND:
                return getLocalizedString(R.string.TUIKitErrorSVRFriendshipAccountNotFound); // @"请求的用户帐号不存在。";
            case BaseConstants.ERR_SVR_FRIENDSHIP_ADMIN_REQUIRED:
                return getLocalizedString(R.string.TUIKitErrorSVRFriendshipAdminRequired); // @"请求需要 App 管理员权限。";
            case BaseConstants.ERR_SVR_FRIENDSHIP_SENSITIVE_TEXT:
                return getLocalizedString(R.string.TUIKitErrorSVRFriendshipSensitiveText); // @"关系链字段中包含敏感词。";
            case BaseConstants.ERR_SVR_FRIENDSHIP_INTERNAL_ERROR:
                return getLocalizedString(R.string.TUIKitErrorSVRAccountInternalError); // @"服务端内部错误，请重试。";
            case BaseConstants.ERR_SVR_FRIENDSHIP_NET_TIMEOUT:
                return getLocalizedString(R.string.TUIKitErrorSVRFriendshipNetTimeout); // @"网络超时，请稍后重试。";
            case BaseConstants.ERR_SVR_FRIENDSHIP_WRITE_CONFLICT:
                return getLocalizedString(R.string.TUIKitErrorSVRFriendshipWriteConflict); // @"并发写导致写冲突，建议使用批量方式。";
            case BaseConstants.ERR_SVR_FRIENDSHIP_ADD_FRIEND_DENY:
                return getLocalizedString(R.string.TUIKitErrorSVRFriendshipAddFriendDeny); // @"后台禁止该用户发起加好友请求。";
            case BaseConstants.ERR_SVR_FRIENDSHIP_COUNT_LIMIT:
                return getLocalizedString(R.string.TUIkitErrorSVRFriendshipCountLimit); // @"自己的好友数已达系统上限。";
            case BaseConstants.ERR_SVR_FRIENDSHIP_GROUP_COUNT_LIMIT:
                return getLocalizedString(R.string.TUIKitErrorSVRFriendshipGroupCountLimit); // @"分组已达系统上限。";
            case BaseConstants.ERR_SVR_FRIENDSHIP_PENDENCY_LIMIT:
                return getLocalizedString(R.string.TUIKitErrorSVRFriendshipPendencyLimit); // @"未决数已达系统上限。";
            case BaseConstants.ERR_SVR_FRIENDSHIP_BLACKLIST_LIMIT:
                return getLocalizedString(R.string.TUIKitErrorSVRFriendshipBlacklistLimit); // @"黑名单数已达系统上限。";
            case BaseConstants.ERR_SVR_FRIENDSHIP_PEER_FRIEND_LIMIT:
                return getLocalizedString(R.string.TUIKitErrorSVRFriendshipPeerFriendLimit); // @"对方的好友数已达系统上限。";
            case BaseConstants.ERR_SVR_FRIENDSHIP_IN_SELF_BLACKLIST:
                return getLocalizedString(R.string.TUIKitErrorSVRFriendshipInSelfBlacklist); // @"对方在自己的黑名单中，不允许加好友。";
            case BaseConstants.ERR_SVR_FRIENDSHIP_ALLOW_TYPE_DENY_ANY:
                return getLocalizedString(R.string.TUIKitErrorSVRFriendshipAllowTypeDenyAny); // @"对方的加好友验证方式是不允许任何人添加自己为好友。";
            case BaseConstants.ERR_SVR_FRIENDSHIP_IN_PEER_BLACKLIST:
                return getLocalizedString(R.string.TUIKitErrorSVRFriendshipInPeerBlackList); // @"自己在对方的黑名单中，不允许加好友。";
            case BaseConstants.ERR_SVR_FRIENDSHIP_ALLOW_TYPE_NEED_CONFIRM:
                return getLocalizedString(R.string.TUIKitErrorSVRFriendshipAllowTypeNeedConfirm); // @"请求已发送，等待对方同意";
            case BaseConstants.ERR_SVR_FRIENDSHIP_ADD_FRIEND_SEC_RSTR:
                return getLocalizedString(R.string.TUIKitErrorSVRFriendshipAddFriendSecRstr); // @"添加好友请求被安全策略打击，请勿频繁发起添加好友请求。";
            case BaseConstants.ERR_SVR_FRIENDSHIP_PENDENCY_NOT_FOUND:
                return getLocalizedString(R.string.TUIKitErrorSVRFriendshipPendencyNotFound); // @"请求的未决不存在。";
            case BaseConstants.ERR_SVR_FRIENDSHIP_DEL_FRIEND_SEC_RSTR:
                return getLocalizedString(R.string.TUIKitErrorSVRFriendshipDelFriendSecRstr); // @"删除好友请求被安全策略打击，请勿频繁发起删除好友请求。";
            case BaseConstants.ERR_SVR_FRIENDSHIP_ACCOUNT_NOT_FOUND_EX:
                return getLocalizedString(R.string.TUIKirErrorSVRFriendAccountNotFoundEx); // @"请求的用户帐号不存在。";

            // 最近联系人错误码

            case BaseConstants.ERR_SVR_CONV_ACCOUNT_NOT_FOUND:
                return getLocalizedString(R.string.TUIKirErrorSVRFriendAccountNotFoundEx); // @"请求的用户帐号不存在。";
            case BaseConstants.ERR_SVR_CONV_INVALID_PARAMETERS:
                return getLocalizedString(R.string.TUIKitErrorSVRFriendshipInvalidParameters); // @"请求参数错误，请根据错误描述检查请求是否正确。";
            case BaseConstants.ERR_SVR_CONV_ADMIN_REQUIRED:
                return getLocalizedString(R.string.TUIKitErrorSVRFriendshipAdminRequired); // @"请求需要 App 管理员权限。";
            case BaseConstants.ERR_SVR_CONV_INTERNAL_ERROR:
                return getLocalizedString(R.string.TUIKitErrorSVRAccountInternalError); // @"服务端内部错误，请重试。";
            case BaseConstants.ERR_SVR_CONV_NET_TIMEOUT:
                return getLocalizedString(R.string.TUIKitErrorSVRFriendshipNetTimeout); // @"网络超时，请稍后重试。";

            // 消息错误码

            case BaseConstants.ERR_SVR_MSG_PKG_PARSE_FAILED:
                return getLocalizedString(R.string.TUIKitErrorSVRMsgPkgParseFailed); // @"解析请求包失败。";
            case BaseConstants.ERR_SVR_MSG_INTERNAL_AUTH_FAILED:
                return getLocalizedString(R.string.TUIKitErrorSVRMsgInternalAuthFailed); // @"内部鉴权失败。";
            case BaseConstants.ERR_SVR_MSG_INVALID_ID:
                return getLocalizedString(R.string.TUIKitErrorSVRMsgInvalidId); // @"Identifier 无效";
            case BaseConstants.ERR_SVR_MSG_NET_ERROR:
                return getLocalizedString(R.string.TUIKitErrorSVRMsgNetError); // @"网络异常，请重试。";
            case BaseConstants.ERR_SVR_MSG_INTERNAL_ERROR1:
                return getLocalizedString(R.string.TUIKitErrorSVRAccountInternalError); // @"服务端内部错误，请重试。";
            case BaseConstants.ERR_SVR_MSG_PUSH_DENY:
                return getLocalizedString(R.string.TUIKitErrorSVRMsgPushDeny); //  @"触发发送单聊消息之前回调，App 后台返回禁止下发该消息。";
            case BaseConstants.ERR_SVR_MSG_IN_PEER_BLACKLIST:
                return getLocalizedString(R.string.TUIKitErrorSVRMsgInPeerBlackList); // @"发送单聊消息，被对方拉黑，禁止发送。";
            case BaseConstants.ERR_SVR_MSG_BOTH_NOT_FRIEND:
                return getLocalizedString(R.string.TUIKitErrorSVRMsgBothNotFriend); // @"消息发送双方互相不是好友，禁止发送。";
            case BaseConstants.ERR_SVR_MSG_NOT_PEER_FRIEND:
                return getLocalizedString(R.string.TUIKitErrorSVRMsgNotPeerFriend); // @"发送单聊消息，自己不是对方的好友（单向关系），禁止发送。";
            case BaseConstants.ERR_SVR_MSG_NOT_SELF_FRIEND:
                return getLocalizedString(R.string.TUIkitErrorSVRMsgNotSelfFriend); // @"发送单聊消息，对方不是自己的好友（单向关系），禁止发送。";
            case BaseConstants.ERR_SVR_MSG_SHUTUP_DENY:
                return getLocalizedString(R.string.TUIKitErrorSVRMsgShutupDeny); // @"因禁言，禁止发送消息。";
            case BaseConstants.ERR_SVR_MSG_REVOKE_TIME_LIMIT:
                return getLocalizedString(R.string.TUIKitErrorSVRMsgRevokeTimeLimit); // @"消息撤回超过了时间限制（默认2分钟）。";
            case BaseConstants.ERR_SVR_MSG_DEL_RAMBLE_INTERNAL_ERROR:
                return getLocalizedString(R.string.TUIKitErrorSVRMsgDelRambleInternalError); // @"删除漫游内部错误。";
            case BaseConstants.ERR_SVR_MSG_JSON_PARSE_FAILED:
                return getLocalizedString(R.string.TUIKitErrorSVRMsgJsonParseFailed); // @"JSON 格式解析失败，请检查请求包是否符合 JSON 规范。";
            case BaseConstants.ERR_SVR_MSG_INVALID_JSON_BODY_FORMAT:
                return getLocalizedString(R.string.TUIKitErrorSVRMsgInvalidJsonBodyFormat); // @"JSON 格式请求包中 MsgBody 不符合消息格式描述";
            case BaseConstants.ERR_SVR_MSG_INVALID_TO_ACCOUNT:
                return getLocalizedString(R.string.TUIKitErrorSVRMsgInvalidToAccount); // @"JSON 格式请求包体中缺少 To_Account 字段或者 To_Account 字段不是 Integer 类型";
            case BaseConstants.ERR_SVR_MSG_INVALID_RAND:
                return getLocalizedString(R.string.TUIKitErrorSVRMsgInvalidRand); // @"JSON 格式请求包体中缺少 MsgRandom 字段或者 MsgRandom 字段不是 Integer 类型";
            case BaseConstants.ERR_SVR_MSG_INVALID_TIMESTAMP:
                return getLocalizedString(R.string.TUIKitErrorSVRMsgInvalidTimestamp); // @"JSON 格式请求包体中缺少 MsgTimeStamp 字段或者 MsgTimeStamp 字段不是 Integer 类型";
            case BaseConstants.ERR_SVR_MSG_BODY_NOT_ARRAY:
                return getLocalizedString(R.string.TUIKitErrorSVRMsgBodyNotArray); // @"JSON 格式请求包体中 MsgBody 类型不是 Array 类型";
            case BaseConstants.ERR_SVR_MSG_ADMIN_REQUIRED:
                return getLocalizedString(R.string.TUIKitErrorSVRAccountAdminRequired); // @"请求需要 App 管理员权限。";
            case BaseConstants.ERR_SVR_MSG_INVALID_JSON_FORMAT:
                return getLocalizedString(R.string.TUIKitErrorSVRMsgInvalidJsonFormat); // @"JSON 格式请求包不符合消息格式描述";
            case BaseConstants.ERR_SVR_MSG_TO_ACCOUNT_COUNT_LIMIT:
                return getLocalizedString(R.string.TUIKitErrorSVRMsgToAccountCountLimit); // @"批量发消息目标帐号超过500";
            case BaseConstants.ERR_SVR_MSG_TO_ACCOUNT_NOT_FOUND:
                return getLocalizedString(R.string.TUIKitErrorSVRMsgToAccountNotFound); // @"To_Account 没有注册或不存在";
            case BaseConstants.ERR_SVR_MSG_TIME_LIMIT:
                return getLocalizedString(R.string.TUIKitErrorSVRMsgTimeLimit); // @"消息离线存储时间错误（最多不能超过7天）。";
            case BaseConstants.ERR_SVR_MSG_INVALID_SYNCOTHERMACHINE:
                return getLocalizedString(R.string.TUIKitErrorSVRMsgInvalidSyncOtherMachine); // @"JSON 格式请求包体中 SyncOtherMachine 字段不是 Integer 类型";
            case BaseConstants.ERR_SVR_MSG_INVALID_MSGLIFETIME:
                return getLocalizedString(R.string.TUIkitErrorSVRMsgInvalidMsgLifeTime); //  @"JSON 格式请求包体中 MsgLifeTime 字段不是 Integer 类型";
            case BaseConstants.ERR_SVR_MSG_ACCOUNT_NOT_FOUND:
                return getLocalizedString(R.string.TUIKirErrorSVRFriendAccountNotFoundEx); // @"请求的用户帐号不存在。";
            case BaseConstants.ERR_SVR_MSG_INTERNAL_ERROR2:
                return getLocalizedString(R.string.TUIKitErrorSVRAccountInternalError); // @"服务内部错误，请重试";
            case BaseConstants.ERR_SVR_MSG_INTERNAL_ERROR3:
                return getLocalizedString(R.string.TUIKitErrorSVRAccountInternalError); // @"服务内部错误，请重试";
            case BaseConstants.ERR_SVR_MSG_INTERNAL_ERROR4:
                return getLocalizedString(R.string.TUIKitErrorSVRAccountInternalError); // @"服务内部错误，请重试";
            case BaseConstants.ERR_SVR_MSG_INTERNAL_ERROR5:
                return getLocalizedString(R.string.TUIKitErrorSVRAccountInternalError); // @"服务内部错误，请重试";
            case BaseConstants.ERR_SVR_MSG_BODY_SIZE_LIMIT:
                return getLocalizedString(R.string.TUIKitErrorSVRMsgBodySizeLimit); // @"JSON 数据包超长，消息包体请不要超过8k。";
            case BaseConstants.ERR_SVR_MSG_LONGPOLLING_COUNT_LIMIT:
                return getLocalizedString(R.string.TUIKitErrorSVRmsgLongPollingCountLimit); // @"Web 端长轮询被踢（Web 端同时在线实例个数超出限制）。";


            // 群组错误码

            case BaseConstants.ERR_SVR_GROUP_INTERNAL_ERROR:
                return getLocalizedString(R.string.TUIKitErrorSVRAccountInternalError); // @"服务端内部错误，请重试。";
            case BaseConstants.ERR_SVR_GROUP_API_NAME_ERROR:
                return getLocalizedString(R.string.TUIKitErrorSVRGroupApiNameError); // @"请求中的接口名称错误";
            case BaseConstants.ERR_SVR_GROUP_INVALID_PARAMETERS:
                return getLocalizedString(R.string.TUIKitErrorSVRResInvalidParameters); // @"参数非法";
            case BaseConstants.ERR_SVR_GROUP_ACOUNT_COUNT_LIMIT:
                return getLocalizedString(R.string.TUIKitErrorSVRGroupAccountCountLimit); // @"请求包体中携带的帐号数量过多。";
            case BaseConstants.ERR_SVR_GROUP_FREQ_LIMIT:
                return getLocalizedString(R.string.TUIkitErrorSVRGroupFreqLimit); // @"操作频率限制，请尝试降低调用的频率。";
            case BaseConstants.ERR_SVR_GROUP_PERMISSION_DENY:
                return getLocalizedString(R.string.TUIKitErrorSVRGroupPermissionDeny); // @"操作权限不足";
            case BaseConstants.ERR_SVR_GROUP_INVALID_REQ:
                return getLocalizedString(R.string.TUIKitErrorSVRGroupInvalidReq); // @"请求非法";
            case BaseConstants.ERR_SVR_GROUP_SUPER_NOT_ALLOW_QUIT:
                return getLocalizedString(R.string.TUIKitErrorSVRGroupSuperNotAllowQuit); // @"该群不允许群主主动退出。";
            case BaseConstants.ERR_SVR_GROUP_NOT_FOUND:
                return getLocalizedString(R.string.TUIKitErrorSVRGroupNotFound); // @"群组不存在";
            case BaseConstants.ERR_SVR_GROUP_JSON_PARSE_FAILED:
                return getLocalizedString(R.string.TUIKitErrorSVRGroupJsonParseFailed); // @"解析 JSON 包体失败，请检查包体的格式是否符合 JSON 格式。";
            case BaseConstants.ERR_SVR_GROUP_INVALID_ID:
                return getLocalizedString(R.string.TUIKitErrorSVRGroupInvalidId); // @"发起操作的 Identifier 非法，请检查发起操作的用户 Identifier 是否填写正确。";
            case BaseConstants.ERR_SVR_GROUP_ALLREADY_MEMBER:
                return getLocalizedString(R.string.TUIKitErrorSVRGroupAllreadyMember); // @"被邀请加入的用户已经是群成员。";
            case BaseConstants.ERR_SVR_GROUP_FULL_MEMBER_COUNT:
                return getLocalizedString(R.string.TUIKitErrorSVRGroupFullMemberCount); //  @"群已满员，无法将请求中的用户加入群组";
            case BaseConstants.ERR_SVR_GROUP_INVALID_GROUPID:
                return getLocalizedString(R.string.TUIKitErrorSVRGroupInvalidGroupId); // @"群组 ID 非法，请检查群组 ID 是否填写正确。";
            case BaseConstants.ERR_SVR_GROUP_REJECT_FROM_THIRDPARTY:
                return getLocalizedString(R.string.TUIKitErrorSVRGroupRejectFromThirdParty); // @"App 后台通过第三方回调拒绝本次操作。";
            case BaseConstants.ERR_SVR_GROUP_SHUTUP_DENY:
                return getLocalizedString(R.string.TUIKitErrorSVRGroupShutDeny); // @"因被禁言而不能发送消息，请检查发送者是否被设置禁言。";
            case BaseConstants.ERR_SVR_GROUP_RSP_SIZE_LIMIT:
                return getLocalizedString(R.string.TUIKitErrorSVRGroupRspSizeLimit); // @"应答包长度超过最大包长";
            case BaseConstants.ERR_SVR_GROUP_ACCOUNT_NOT_FOUND:
                return getLocalizedString(R.string.TUIKitErrorSVRGroupAccountNotFound); // @"请求的用户帐号不存在。";
            case BaseConstants.ERR_SVR_GROUP_GROUPID_IN_USED:
                return getLocalizedString(R.string.TUIKitErrorSVRGroupGroupIdInUse); // @"群组 ID 已被使用，请选择其他的群组 ID。";
            case BaseConstants.ERR_SVR_GROUP_SEND_MSG_FREQ_LIMIT:
                return getLocalizedString(R.string.TUIKitErrorSVRGroupSendMsgFreqLimit); // @"发消息的频率超限，请延长两次发消息时间的间隔。";
            case BaseConstants.ERR_SVR_GROUP_REQ_ALLREADY_BEEN_PROCESSED:
                return getLocalizedString(R.string.TUIKitErrorSVRGroupReqAllreadyBeenProcessed); // @"此邀请或者申请请求已经被处理。";
            case BaseConstants.ERR_SVR_GROUP_GROUPID_IN_USED_FOR_SUPER:
                return getLocalizedString(R.string.TUIKitErrorSVRGroupGroupIdUserdForSuper); // @"群组 ID 已被使用，并且操作者为群主，可以直接使用。";
            case BaseConstants.ERR_SVR_GROUP_SDKAPPID_DENY:
                return getLocalizedString(R.string.TUIKitErrorSVRGroupSDkAppidDeny); // @"该 SDKAppID 请求的命令字已被禁用";
            case BaseConstants.ERR_SVR_GROUP_REVOKE_MSG_NOT_FOUND:
                return getLocalizedString(R.string.TUIKitErrorSVRGroupRevokeMsgNotFound); // @"请求撤回的消息不存在。";
            case BaseConstants.ERR_SVR_GROUP_REVOKE_MSG_TIME_LIMIT:
                return getLocalizedString(R.string.TUIKitErrorSVRGroupRevokeMsgTimeLimit); // @"消息撤回超过了时间限制（默认2分钟）。";
            case BaseConstants.ERR_SVR_GROUP_REVOKE_MSG_DENY:
                return getLocalizedString(R.string.TUIKitErrorSVRGroupRevokeMsgDeny); // @"请求撤回的消息不支持撤回操作。";
            case BaseConstants.ERR_SVR_GROUP_NOT_ALLOW_REVOKE_MSG:
                return getLocalizedString(R.string.TUIKitErrorSVRGroupNotAllowRevokeMsg); // @"群组类型不支持消息撤回操作。";
            case BaseConstants.ERR_SVR_GROUP_REMOVE_MSG_DENY:
                return getLocalizedString(R.string.TUIKitErrorSVRGroupRemoveMsgDeny); // @"该消息类型不支持删除操作。";
            case BaseConstants.ERR_SVR_GROUP_NOT_ALLOW_REMOVE_MSG:
                return getLocalizedString(R.string.TUIKitErrorSVRGroupNotAllowRemoveMsg); // @"音视频聊天室和在线成员广播大群不支持删除消息。";
            case BaseConstants.ERR_SVR_GROUP_AVCHATROOM_COUNT_LIMIT:
                return getLocalizedString(R.string.TUIKitErrorSVRGroupAvchatRoomCountLimit); // @"音视频聊天室创建数量超过了限制";
            case BaseConstants.ERR_SVR_GROUP_COUNT_LIMIT:
                return getLocalizedString(R.string.TUIKitErrorSVRGroupCountLimit); // @"单个用户可创建和加入的群组数量超过了限制”。";
            case BaseConstants.ERR_SVR_GROUP_MEMBER_COUNT_LIMIT:
                return getLocalizedString(R.string.TUIKitErrorSVRGroupMemberCountLimit); // @"群成员数量超过限制";

            /////////////////////////////////////////////////////////////////////////////////
            //
            //                      （三）V3版本错误码，待废弃
            //
            /////////////////////////////////////////////////////////////////////////////////

            case BaseConstants.ERR_NO_SUCC_RESULT:
                return getLocalizedString(R.string.TUIKitErrorSVRNoSuccessResult); // @"批量操作无成功结果";
            case BaseConstants.ERR_TO_USER_INVALID:
                return getLocalizedString(R.string.TUIKitErrorSVRToUserInvalid); // @"IM: 无效接收方";
            case BaseConstants.ERR_REQUEST_TIMEOUT:
                return getLocalizedString(R.string.TUIKitErrorSVRRequestTimeout); // @"请求超时";
            case BaseConstants.ERR_INIT_CORE_FAIL:
                return getLocalizedString(R.string.TUIKitErrorSVRInitCoreFail); // @"INIT CORE模块失败";
            case BaseConstants.ERR_EXPIRED_SESSION_NODE:
                return getLocalizedString(R.string.TUIKitErrorExpiredSessionNode); // @"SessionNode为null";
            case BaseConstants.ERR_LOGGED_OUT_BEFORE_LOGIN_FINISHED:
                return getLocalizedString(R.string.TUIKitErrorLoggedOutBeforeLoginFinished); // @"在登录完成前进行了登出（在登录时返回）";
            case BaseConstants.ERR_TLSSDK_NOT_INITIALIZED:
                return getLocalizedString(R.string.TUIKitErrorTLSSDKNotInitialized); // @"tlssdk未初始化";
            case BaseConstants.ERR_TLSSDK_USER_NOT_FOUND:
                return getLocalizedString(R.string.TUIKitErrorTLSSDKUserNotFound); // @"TLSSDK没有找到相应的用户信息";
//        case BaseConstants.ERR_BIND_FAIL_UNKNOWN:
//            return @"QALSDK未知原因BIND失败";
//        case BaseConstants.ERR_BIND_FAIL_NO_SSOTICKET:
//            return @"缺少SSO票据";
//        case BaseConstants.ERR_BIND_FAIL_REPEATD_BIND:
//            return @"重复BIND";
//        case BaseConstants.ERR_BIND_FAIL_TINYID_NULL:
//            return @"tiny为空";
//        case BaseConstants.ERR_BIND_FAIL_GUID_NULL:
//            return @"guid为空";
//        case BaseConstants.ERR_BIND_FAIL_UNPACK_REGPACK_FAILED:
//            return @"解注册包失败";
            case BaseConstants.ERR_BIND_FAIL_REG_TIMEOUT:
                return getLocalizedString(R.string.TUIKitErrorBindFaildRegTimeout); // @"注册超时";
            case BaseConstants.ERR_BIND_FAIL_ISBINDING:
                return getLocalizedString(R.string.TUIKitErrorBindFaildIsBinding); // @"正在bind操作中";
            case BaseConstants.ERR_PACKET_FAIL_UNKNOWN:
                return getLocalizedString(R.string.TUIKitErrorPacketFailUnknown); // @"发包未知错误";
            case BaseConstants.ERR_PACKET_FAIL_REQ_NO_NET:
                return getLocalizedString(R.string.TUIKitErrorPacketFailReqNoNet); // @"发送请求包时没有网络,处理时转换成case BaseConstants.ERR_REQ_NO_NET_ON_REQ:";
            case BaseConstants.ERR_PACKET_FAIL_RESP_NO_NET:
                return getLocalizedString(R.string.TUIKitErrorPacketFailRespNoNet); // @"发送回复包时没有网络,处理时转换成case BaseConstants.ERR_REQ_NO_NET_ON_RSP:";
            case BaseConstants.ERR_PACKET_FAIL_REQ_NO_AUTH:
                return getLocalizedString(R.string.TUIKitErrorPacketFailReqNoAuth); // @"发送请求包时没有权限";
            case BaseConstants.ERR_PACKET_FAIL_SSO_ERR:
                return getLocalizedString(R.string.TUIKitErrorPacketFailSSOErr); // @"SSO错误";
            case BaseConstants.ERR_PACKET_FAIL_REQ_TIMEOUT:
                return getLocalizedString(R.string.TUIKitErrorSVRRequestTimeout); // @"请求超时";
            case BaseConstants.ERR_PACKET_FAIL_RESP_TIMEOUT:
                return getLocalizedString(R.string.TUIKitErrorPacketFailRespTimeout); // @"回复超时";

            // case BaseConstants.ERR_PACKET_FAIL_REQ_ON_RESEND:
            // case BaseConstants.ERR_PACKET_FAIL_RESP_NO_RESEND:
            // case BaseConstants.ERR_PACKET_FAIL_FLOW_SAVE_FILTERED:
            // case BaseConstants.ERR_PACKET_FAIL_REQ_OVER_LOAD:
            // case BaseConstants.ERR_PACKET_FAIL_LOGIC_ERR:
            case BaseConstants.ERR_FRIENDSHIP_PROXY_NOT_SYNCED:
                return getLocalizedString(R.string.TUIKitErrorFriendshipProxySyncing); // @"proxy_manager没有完成svr数据同步";
            case BaseConstants.ERR_FRIENDSHIP_PROXY_SYNCING:
                return getLocalizedString(R.string.TUIKitErrorFriendshipProxySyncing); // @"proxy_manager正在进行svr数据同步";
            case BaseConstants.ERR_FRIENDSHIP_PROXY_SYNCED_FAIL:
                return getLocalizedString(R.string.TUIKitErrorFriendshipProxySyncedFail); // @"proxy_manager同步失败";
            case BaseConstants.ERR_FRIENDSHIP_PROXY_LOCAL_CHECK_ERR:
                return getLocalizedString(R.string.TUIKitErrorFriendshipProxyLocalCheckErr); // @"proxy_manager请求参数，在本地检查不合法";
            case BaseConstants.ERR_GROUP_INVALID_FIELD:
                return getLocalizedString(R.string.TUIKitErrorGroupInvalidField); // @"group assistant请求字段中包含非预设字段";
            case BaseConstants.ERR_GROUP_STORAGE_DISABLED:
                return getLocalizedString(R.string.TUIKitErrorGroupStoreageDisabled); // @"group assistant群资料本地存储没有开启";
            case BaseConstants.ERR_LOADGRPINFO_FAILED:
                return getLocalizedString(R.string.TUIKitErrorLoadGrpInfoFailed); // @"failed to load groupinfo from storage";
            case BaseConstants.ERR_REQ_NO_NET_ON_REQ:
                return getLocalizedString(R.string.TUIKitErrorReqNoNetOnReq); // @"请求的时候没有网络";
            case BaseConstants.ERR_REQ_NO_NET_ON_RSP:
                return getLocalizedString(R.string.TUIKitErrorReqNoNetOnResp); // @"响应的时候没有网络";
            case BaseConstants.ERR_SERIVCE_NOT_READY:
                return getLocalizedString(R.string.TUIKitErrorServiceNotReady); // @"QALSDK服务未就绪";
            case BaseConstants.ERR_LOGIN_AUTH_FAILED:
                return getLocalizedString(R.string.TUIKitErrorLoginAuthFailed); // @"账号认证失败（tinyid转换失败）";
            case BaseConstants.ERR_NEVER_CONNECT_AFTER_LAUNCH:
                return getLocalizedString(R.string.TUIKitErrorNeverConnectAfterLaunch); // @"在应用启动后没有尝试联网";
            case BaseConstants.ERR_REQ_FAILED:
                return getLocalizedString(R.string.TUIKitErrorReqFailed); // @"QAL执行失败";
            case BaseConstants.ERR_REQ_INVALID_REQ:
                return getLocalizedString(R.string.TUIKitErrorReqInvaidReq); // @"请求非法，toMsgService非法";
            case BaseConstants.ERR_REQ_OVERLOADED:
                return getLocalizedString(R.string.TUIKitErrorReqOnverLoaded); // @"请求队列満";
            case BaseConstants.ERR_REQ_KICK_OFF:
                return getLocalizedString(R.string.TUIKitErrorReqKickOff); // @"已经被其他终端踢了";
            case BaseConstants.ERR_REQ_SERVICE_SUSPEND:
                return getLocalizedString(R.string.TUIKitErrorReqServiceSuspend); // @"服务被暂停";
            case BaseConstants.ERR_REQ_INVALID_SIGN:
                return getLocalizedString(R.string.TUIKitErrorReqInvalidSign); // @"SSO签名错误";
            case BaseConstants.ERR_REQ_INVALID_COOKIE:
                return getLocalizedString(R.string.TUIKitErrorReqInvalidCookie); // @"SSO cookie无效";
            case BaseConstants.ERR_LOGIN_TLS_RSP_PARSE_FAILED:
                return getLocalizedString(R.string.TUIKitErrorLoginTlsRspParseFailed); // @"登录时TLS回包校验，包体长度错误";
            case BaseConstants.ERR_LOGIN_OPENMSG_TIMEOUT:
                return getLocalizedString(R.string.TUIKitErrorLoginOpenMsgTimeout); // @"登录时OPENSTATSVC向OPENMSG上报状态超时";
            case BaseConstants.ERR_LOGIN_OPENMSG_RSP_PARSE_FAILED:
                return getLocalizedString(R.string.TUIKitErrorLoginOpenMsgRspParseFailed); // @"登录时OPENSTATSVC向OPENMSG上报状态时解析回包失败";
            case BaseConstants.ERR_LOGIN_TLS_DECRYPT_FAILED:
                return getLocalizedString(R.string.TUIKitErrorLoginTslDecryptFailed); // @"登录时TLS解密失败";
            case BaseConstants.ERR_WIFI_NEED_AUTH:
                return getLocalizedString(R.string.TUIKitErrorWifiNeedAuth); // @"wifi需要认证";
            case BaseConstants.ERR_USER_CANCELED:
                return getLocalizedString(R.string.TUIKitErrorUserCanceled); // @"用户已取消";
            case BaseConstants.ERR_REVOKE_TIME_LIMIT_EXCEED:
                return getLocalizedString(R.string.TUIkitErrorRevokeTimeLimitExceed); // @"消息撤回超过了时间限制（默认2分钟）";
            case BaseConstants.ERR_LACK_UGC_EXT:
                return getLocalizedString(R.string.TUIKitErrorLackUGExt); // @"缺少UGC扩展包";
            case BaseConstants.ERR_AUTOLOGIN_NEED_USERSIG:
                return getLocalizedString(R.string.TUIKitErrorAutoLoginNeedUserSig); // @"自动登录，本地票据过期，需要userSig手动登录";
            case BaseConstants.ERR_QAL_NO_SHORT_CONN_AVAILABLE:
                return getLocalizedString(R.string.TUIKitErrorQALNoShortConneAvailable); // @"没有可用的短连接sso";
            case BaseConstants.ERR_REQ_CONTENT_ATTACK:
                return getLocalizedString(R.string.TUIKitErrorReqContentAttach); // @"消息内容安全打击";
            case BaseConstants.ERR_LOGIN_SIG_EXPIRE:
                return getLocalizedString(R.string.TUIKitErrorLoginSigExpire); // @"登录返回，票据过期";
            case BaseConstants.ERR_SDK_HAD_INITIALIZED:
                return getLocalizedString(R.string.TUIKitErrorSDKHadInit); // @"SDK 已经初始化无需重复初始化";
            case BaseConstants.ERR_OPENBDH_BASE:
                return getLocalizedString(R.string.TUIKitErrorOpenBDHBase); // @"openbdh 错误码基";
            case BaseConstants.ERR_REQUEST_NO_NET_ONREQ:
                return getLocalizedString(R.string.TUIKitErrorRequestNoNetOnReq); // @"请求时没有网络，请等网络恢复后重试";
            case BaseConstants.ERR_REQUEST_NO_NET_ONRSP:
                return getLocalizedString(R.string.TUIKitErrorRequestNoNetOnRsp); // @"响应时没有网络，请等网络恢复后重试";
//        case BaseConstants.ERR_REQUEST_FAILED:
//            return @"QAL执行失败";
//        case BaseConstants.ERR_REQUEST_INVALID_REQ:
//            return @"请求非法，toMsgService非法";
            case BaseConstants.ERR_REQUEST_OVERLOADED:
                return getLocalizedString(R.string.TUIKitErrorRequestOnverLoaded); // @"请求队列満";
            case BaseConstants.ERR_REQUEST_KICK_OFF:
                return getLocalizedString(R.string.TUIKitErrorReqKickOff); // @"已经被其他终端踢了";
            case BaseConstants.ERR_REQUEST_SERVICE_SUSPEND:
                return getLocalizedString(R.string.TUIKitErrorReqServiceSuspend); // @"服务被暂停";
            case BaseConstants.ERR_REQUEST_INVALID_SIGN:
                return getLocalizedString(R.string.TUIKitErrorReqInvalidSign); // @"SSO签名错误";
            case BaseConstants.ERR_REQUEST_INVALID_COOKIE:
                return getLocalizedString(R.string.TUIKitErrorReqInvalidCookie); // @"SSO cookie无效";

            default:
                break;
        }
        return msg;
    }

    private static String getLocalizedString(int errStringId) {
        return TUIConfig.getAppContext().getString(errStringId);
    }
}
