package com.tencent.qcloud.tuicore.util;

import com.tencent.imsdk.BaseConstants;
import com.tencent.qcloud.tuicore.R;
import com.tencent.qcloud.tuicore.TUIConfig;
import java.util.HashMap;
import java.util.Map;

public class ErrorMessageConverter {
    public static final Map<Integer, Integer> ERROR_CODE_MAP = new HashMap<>();

    static {
        /////////////////////////////////////////////////////////////////////////////////
        //
        //                      （一）IM SDK 的错误码
        //                           IM SDK error codes
        //
        /////////////////////////////////////////////////////////////////////////////////
        // 通用错误码
        // Common error codes
        ERROR_CODE_MAP.put(BaseConstants.ERR_IN_PROGESS, R.string.TUIKitErrorInProcess);
        ERROR_CODE_MAP.put(BaseConstants.ERR_INVALID_PARAMETERS, R.string.TUIKitErrorInvalidParameters);
        ERROR_CODE_MAP.put(BaseConstants.ERR_IO_OPERATION_FAILED, R.string.TUIKitErrorIOOperateFaild);
        ERROR_CODE_MAP.put(BaseConstants.ERR_INVALID_JSON, R.string.TUIKitErrorInvalidJson);
        ERROR_CODE_MAP.put(BaseConstants.ERR_OUT_OF_MEMORY, R.string.TUIKitErrorOutOfMemory);
        ERROR_CODE_MAP.put(BaseConstants.ERR_PARSE_RESPONSE_FAILED, R.string.TUIKitErrorParseResponseFaild);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SERIALIZE_REQ_FAILED, R.string.TUIKitErrorSerializeReqFaild);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SDK_NOT_INITIALIZED, R.string.TUIKitErrorSDKNotInit);
        ERROR_CODE_MAP.put(BaseConstants.ERR_LOADMSG_FAILED, R.string.TUIKitErrorLoadMsgFailed);
        ERROR_CODE_MAP.put(BaseConstants.ERR_DATABASE_OPERATE_FAILED, R.string.TUIKitErrorDatabaseOperateFailed);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SDK_COMM_CROSS_THREAD, R.string.TUIKitErrorCrossThread);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SDK_COMM_TINYID_EMPTY, R.string.TUIKitErrorTinyIdEmpty);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SDK_COMM_INVALID_IDENTIFIER, R.string.TUIKitErrorInvalidIdentifier);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SDK_COMM_FILE_NOT_FOUND, R.string.TUIKitErrorFileNotFound);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SDK_COMM_FILE_TOO_LARGE, R.string.TUIKitErrorFileTooLarge);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SDK_COMM_FILE_SIZE_EMPTY, R.string.TUIKitErrorEmptyFile);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SDK_COMM_FILE_OPEN_FAILED, R.string.TUIKitErrorFileOpenFailed);

        // 账号错误码
        // Account error codes
        ERROR_CODE_MAP.put(BaseConstants.ERR_SDK_NOT_LOGGED_IN, R.string.TUIKitErrorNotLogin);
        ERROR_CODE_MAP.put(BaseConstants.ERR_NO_PREVIOUS_LOGIN, R.string.TUIKitErrorNoPreviousLogin);
        ERROR_CODE_MAP.put(BaseConstants.ERR_USER_SIG_EXPIRED, R.string.TUIKitErrorUserSigExpired);
        ERROR_CODE_MAP.put(BaseConstants.ERR_LOGIN_KICKED_OFF_BY_OTHER, R.string.TUIKitErrorLoginKickedOffByOther);
        //        errorCodeMap.put(BaseConstants.ERR_LOGIN_IN_PROCESS:
        //            return @"登录正在执行中";
        //        errorCodeMap.put(BaseConstants.ERR_LOGOUT_IN_PROCESS:
        //            return @"登出正在执行中";
        ERROR_CODE_MAP.put(BaseConstants.ERR_SDK_ACCOUNT_TLS_INIT_FAILED, R.string.TUIKitErrorTLSSDKInit);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SDK_ACCOUNT_TLS_NOT_INITIALIZED, R.string.TUIKitErrorTLSSDKUninit);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SDK_ACCOUNT_TLS_TRANSPKG_ERROR, R.string.TUIKitErrorTLSSDKTRANSPackageFormat);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SDK_ACCOUNT_TLS_DECRYPT_FAILED, R.string.TUIKitErrorTLSDecrypt);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SDK_ACCOUNT_TLS_REQUEST_FAILED, R.string.TUIKitErrorTLSSDKRequest);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SDK_ACCOUNT_TLS_REQUEST_TIMEOUT, R.string.TUIKitErrorTLSSDKRequestTimeout);

        // 消息错误码
        // Message error codes
        ERROR_CODE_MAP.put(BaseConstants.ERR_INVALID_CONVERSATION, R.string.TUIKitErrorInvalidConveration);
        ERROR_CODE_MAP.put(BaseConstants.ERR_FILE_TRANS_AUTH_FAILED, R.string.TUIKitErrorFileTransAuthFailed);
        ERROR_CODE_MAP.put(BaseConstants.ERR_FILE_TRANS_NO_SERVER, R.string.TUIKitErrorFileTransNoServer);
        ERROR_CODE_MAP.put(BaseConstants.ERR_FILE_TRANS_UPLOAD_FAILED, R.string.TUIKitErrorFileTransUploadFailed);
        //            errorCodeMap.put(BaseConstants.ERR_IMAGE_UPLOAD_FAILED_NOTIMAGE:
        //                return TUIKitLocalizableString(R.string.TUIKitErrorFileTransUploadFailedNotImage);
        ERROR_CODE_MAP.put(BaseConstants.ERR_FILE_TRANS_DOWNLOAD_FAILED, R.string.TUIKitErrorFileTransDownloadFailed);
        ERROR_CODE_MAP.put(BaseConstants.ERR_HTTP_REQ_FAILED, R.string.TUIKitErrorHTTPRequestFailed);
        ERROR_CODE_MAP.put(BaseConstants.ERR_INVALID_MSG_ELEM, R.string.TUIKitErrorInvalidMsgElem);
        ERROR_CODE_MAP.put(BaseConstants.ERR_INVALID_SDK_OBJECT, R.string.TUIKitErrorInvalidSDKObject);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SDK_MSG_BODY_SIZE_LIMIT, R.string.TUIKitSDKMsgBodySizeLimit);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SDK_MSG_KEY_REQ_DIFFER_RSP, R.string.TUIKitErrorSDKMsgKeyReqDifferRsp);

        // 群组错误码
        // Group error codes
        ERROR_CODE_MAP.put(BaseConstants.ERR_SDK_GROUP_INVALID_ID, R.string.TUIKitErrorSDKGroupInvalidID);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SDK_GROUP_INVALID_NAME, R.string.TUIKitErrorSDKGroupInvalidName);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SDK_GROUP_INVALID_INTRODUCTION, R.string.TUIKitErrorSDKGroupInvalidIntroduction);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SDK_GROUP_INVALID_NOTIFICATION, R.string.TUIKitErrorSDKGroupInvalidNotification);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SDK_GROUP_INVALID_FACE_URL, R.string.TUIKitErrorSDKGroupInvalidFaceURL);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SDK_GROUP_INVALID_NAME_CARD, R.string.TUIKitErrorSDKGroupInvalidNameCard);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SDK_GROUP_MEMBER_COUNT_LIMIT, R.string.TUIKitErrorSDKGroupMemberCountLimit);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SDK_GROUP_JOIN_PRIVATE_GROUP_DENY, R.string.TUIKitErrorSDKGroupJoinPrivateGroupDeny);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SDK_GROUP_INVITE_SUPER_DENY, R.string.TUIKitErrorSDKGroupInviteSuperDeny);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SDK_GROUP_INVITE_NO_MEMBER, R.string.TUIKitErrorSDKGroupInviteNoMember);

        // 关系链错误码
        // Relationship chain error codes
        ERROR_CODE_MAP.put(BaseConstants.ERR_SDK_FRIENDSHIP_INVALID_PROFILE_KEY, R.string.TUIKitErrorSDKFriendShipInvalidProfileKey);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SDK_FRIENDSHIP_INVALID_ADD_REMARK, R.string.TUIKitErrorSDKFriendshipInvalidAddRemark);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SDK_FRIENDSHIP_INVALID_ADD_WORDING, R.string.TUIKitErrorSDKFriendshipInvalidAddWording);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SDK_FRIENDSHIP_INVALID_ADD_SOURCE, R.string.TUIKitErrorSDKFriendshipInvalidAddSource);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SDK_FRIENDSHIP_FRIEND_GROUP_EMPTY, R.string.TUIKitErrorSDKFriendshipFriendGroupEmpty);

        // 网络错误码
        // Network error codes
        ERROR_CODE_MAP.put(BaseConstants.ERR_SDK_NET_ENCODE_FAILED, R.string.TUIKitErrorSDKNetEncodeFailed);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SDK_NET_DECODE_FAILED, R.string.TUIKitErrorSDKNetDecodeFailed);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SDK_NET_AUTH_INVALID, R.string.TUIKitErrorSDKNetAuthInvalid);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SDK_NET_COMPRESS_FAILED, R.string.TUIKitErrorSDKNetCompressFailed);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SDK_NET_UNCOMPRESS_FAILED, R.string.TUIKitErrorSDKNetUncompressFaile);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SDK_NET_FREQ_LIMIT, R.string.TUIKitErrorSDKNetFreqLimit);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SDK_NET_REQ_COUNT_LIMIT, R.string.TUIKitErrorSDKnetReqCountLimit);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SDK_NET_DISCONNECT, R.string.TUIKitErrorSDKNetDisconnect);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SDK_NET_ALLREADY_CONN, R.string.TUIKitErrorSDKNetAllreadyConn);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SDK_NET_CONN_TIMEOUT, R.string.TUIKitErrorSDKNetConnTimeout);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SDK_NET_CONN_REFUSE, R.string.TUIKitErrorSDKNetConnRefuse);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SDK_NET_NET_UNREACH, R.string.TUIKitErrorSDKNetNetUnreach);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SDK_NET_SOCKET_NO_BUFF, R.string.TUIKitErrorSDKNetSocketNoBuff);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SDK_NET_RESET_BY_PEER, R.string.TUIKitERRORSDKNetResetByPeer);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SDK_NET_SOCKET_INVALID, R.string.TUIKitErrorSDKNetSOcketInvalid);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SDK_NET_HOST_GETADDRINFO_FAILED, R.string.TUIKitErrorSDKNetHostGetAddressFailed);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SDK_NET_CONNECT_RESET, R.string.TUIKitErrorSDKNetConnectReset);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SDK_NET_WAIT_INQUEUE_TIMEOUT, R.string.TUIKitErrorSDKNetWaitInQueueTimeout);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SDK_NET_WAIT_SEND_TIMEOUT, R.string.TUIKitErrorSDKNetWaitSendTimeout);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SDK_NET_WAIT_ACK_TIMEOUT, R.string.TUIKitErrorSDKNetWaitAckTimeut);

        /////////////////////////////////////////////////////////////////////////////////
        //
        //                      （二）服务端
        //                           Server error codes
        //
        /////////////////////////////////////////////////////////////////////////////////

        // 网络接入层的错误码
        // Access layer error codes for network
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_SSO_CONNECT_LIMIT, R.string.TUIKitErrorSDKSVRSSOConnectLimit);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_SSO_VCODE, R.string.TUIKitErrorSDKSVRSSOVCode);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_SSO_D2_EXPIRED, R.string.TUIKitErrorSVRSSOD2Expired);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_SSO_A2_UP_INVALID, R.string.TUIKitErrorSVRA2UpInvalid);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_SSO_A2_DOWN_INVALID, R.string.TUIKitErrorSVRA2DownInvalid);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_SSO_EMPTY_KEY, R.string.TUIKitErrorSVRSSOEmpeyKey);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_SSO_UIN_INVALID, R.string.TUIKitErrorSVRSSOUinInvalid);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_SSO_VCODE_TIMEOUT, R.string.TUIKitErrorSVRSSOVCodeTimeout);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_SSO_NO_IMEI_AND_A2, R.string.TUIKitErrorSVRSSONoImeiAndA2);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_SSO_COOKIE_INVALID, R.string.TUIKitErrorSVRSSOCookieInvalid);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_SSO_DOWN_TIP, R.string.TUIKitErrorSVRSSODownTips);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_SSO_DISCONNECT, R.string.TUIKitErrorSVRSSODisconnect);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_SSO_IDENTIFIER_INVALID, R.string.TUIKitErrorSVRSSOIdentifierInvalid);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_SSO_CLIENT_CLOSE, R.string.TUIKitErrorSVRSSOClientClose);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_SSO_MSFSDK_QUIT, R.string.TUIKitErrorSVRSSOMSFSDKQuit);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_SSO_D2KEY_WRONG, R.string.TUIKitErrorSVRSSOD2KeyWrong);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_SSO_UNSURPPORT, R.string.TUIKitErrorSVRSSOUnsupport);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_SSO_PREPAID_ARREARS, R.string.TUIKitErrorSVRSSOPrepaidArrears);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_SSO_PACKET_WRONG, R.string.TUIKitErrorSVRSSOPacketWrong);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_SSO_APPID_BLACK_LIST, R.string.TUIKitErrorSVRSSOAppidBlackList);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_SSO_CMD_BLACK_LIST, R.string.TUIKitErrorSVRSSOCmdBlackList);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_SSO_APPID_WITHOUT_USING, R.string.TUIKitErrorSVRSSOAppidWithoutUsing);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_SSO_FREQ_LIMIT, R.string.TUIKitErrorSVRSSOFreqLimit);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_SSO_OVERLOAD, R.string.TUIKitErrorSVRSSOOverload);

        // 资源文件错误码
        // Resource file error codes
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_RES_NOT_FOUND, R.string.TUIKitErrorSVRResNotFound);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_RES_ACCESS_DENY, R.string.TUIKitErrorSVRResAccessDeny);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_RES_SIZE_LIMIT, R.string.TUIKitErrorSVRResSizeLimit);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_RES_SEND_CANCEL, R.string.TUIKitErrorSVRResSendCancel);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_RES_READ_FAILED, R.string.TUIKitErrorSVRResReadFailed);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_RES_TRANSFER_TIMEOUT, R.string.TUIKitErrorSVRResTransferTimeout);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_RES_INVALID_PARAMETERS, R.string.TUIKitErrorSVRResInvalidParameters);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_RES_INVALID_FILE_MD5, R.string.TUIKitErrorSVRResInvalidFileMd5);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_RES_INVALID_PART_MD5, R.string.TUIKitErrorSVRResInvalidPartMd5);

        // 后台公共错误码
        // Common backend error codes
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_COMM_INVALID_HTTP_URL, R.string.TUIKitErrorSVRCommonInvalidHttpUrl);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_COMM_REQ_JSON_PARSE_FAILED, R.string.TUIKitErrorSVRCommomReqJsonParseFailed);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_COMM_INVALID_ACCOUNT, R.string.TUIKitErrorSVRCommonInvalidAccount);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_COMM_INVALID_ACCOUNT_EX, R.string.TUIKitErrorSVRCommonInvalidAccount);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_COMM_INVALID_SDKAPPID, R.string.TUIKitErrorSVRCommonInvalidSdkappid);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_COMM_REST_FREQ_LIMIT, R.string.TUIKitErrorSVRCommonRestFreqLimit);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_COMM_REQUEST_TIMEOUT, R.string.TUIKitErrorSVRCommonRequestTimeout);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_COMM_INVALID_RES, R.string.TUIKitErrorSVRCommonInvalidRes);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_COMM_ID_NOT_ADMIN, R.string.TUIKitErrorSVRCommonIDNotAdmin);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_COMM_SDKAPPID_FREQ_LIMIT, R.string.TUIKitErrorSVRCommonSdkappidFreqLimit);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_COMM_SDKAPPID_MISS, R.string.TUIKitErrorSVRCommonSdkappidMiss);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_COMM_RSP_JSON_PARSE_FAILED, R.string.TUIKitErrorSVRCommonRspJsonParseFailed);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_COMM_EXCHANGE_ACCOUNT_TIMEUT, R.string.TUIKitErrorSVRCommonExchangeAccountTimeout);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_COMM_INVALID_ID_FORMAT, R.string.TUIKitErrorSVRCommonInvalidIdFormat);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_COMM_SDKAPPID_FORBIDDEN, R.string.TUIKitErrorSVRCommonSDkappidForbidden);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_COMM_REQ_FORBIDDEN, R.string.TUIKitErrorSVRCommonReqForbidden);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_COMM_REQ_FREQ_LIMIT, R.string.TUIKitErrorSVRCommonReqFreqLimit);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_COMM_REQ_FREQ_LIMIT_EX, R.string.TUIKitErrorSVRCommonReqFreqLimit);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_COMM_INVALID_SERVICE, R.string.TUIKitErrorSVRCommonInvalidService);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_COMM_SENSITIVE_TEXT, R.string.TUIKitErrorSVRCommonSensitiveText);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_COMM_BODY_SIZE_LIMIT, R.string.TUIKitErrorSVRCommonBodySizeLimit);

        // 账号错误码
        // Account error codes
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_ACCOUNT_USERSIG_EXPIRED, R.string.TUIKitErrorSVRAccountUserSigExpired);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_ACCOUNT_USERSIG_EMPTY, R.string.TUIKitErrorSVRAccountUserSigEmpty);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_ACCOUNT_USERSIG_CHECK_FAILED, R.string.TUIKitErrorSVRAccountUserSigCheckFailed);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_ACCOUNT_USERSIG_CHECK_FAILED_EX, R.string.TUIKitErrorSVRAccountUserSigCheckFailed);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_ACCOUNT_USERSIG_MISMATCH_PUBLICKEY, R.string.TUIKitErrorSVRAccountUserSigMismatchPublicKey);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_ACCOUNT_USERSIG_MISMATCH_ID, R.string.TUIKitErrorSVRAccountUserSigMismatchId);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_ACCOUNT_USERSIG_MISMATCH_SDKAPPID, R.string.TUIKitErrorSVRAccountUserSigMismatchSdkAppid);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_ACCOUNT_USERSIG_PUBLICKEY_NOT_FOUND, R.string.TUIKitErrorSVRAccountUserSigPublicKeyNotFound);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_ACCOUNT_SDKAPPID_NOT_FOUND, R.string.TUIKitErrorSVRAccountUserSigSdkAppidNotFount);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_ACCOUNT_INVALID_USERSIG, R.string.TUIKitErrorSVRAccountInvalidUserSig);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_ACCOUNT_NOT_FOUND, R.string.TUIKitErrorSVRAccountNotFound);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_ACCOUNT_SEC_RSTR, R.string.TUIKitErrorSVRAccountSecRstr);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_ACCOUNT_INTERNAL_TIMEOUT, R.string.TUIKitErrorSVRAccountInternalTimeout);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_ACCOUNT_INVALID_COUNT, R.string.TUIKitErrorSVRAccountInvalidCount);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_ACCOUNT_INVALID_PARAMETERS, R.string.TUIkitErrorSVRAccountINvalidParameters);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_ACCOUNT_ADMIN_REQUIRED, R.string.TUIKitErrorSVRAccountAdminRequired);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_ACCOUNT_LOW_SDK_VERSION, R.string.TUIKitErrorSVRAccountLowSDKVersion);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_ACCOUNT_FREQ_LIMIT, R.string.TUIKitErrorSVRAccountFreqLimit);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_ACCOUNT_BLACKLIST, R.string.TUIKitErrorSVRAccountBlackList);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_ACCOUNT_COUNT_LIMIT, R.string.TUIKitErrorSVRAccountCountLimit);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_ACCOUNT_INTERNAL_ERROR, R.string.TUIKitErrorSVRAccountInternalError);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_ACCOUNT_USER_STATUS_DISABLED, R.string.TUIKitErrorEnableUserStatusOnConsole);

        // 资料错误码
        // Profile error codes
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_PROFILE_INVALID_PARAMETERS, R.string.TUIKitErrorSVRProfileInvalidParameters);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_PROFILE_ACCOUNT_MISS, R.string.TUIKitErrorSVRProfileAccountMiss);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_PROFILE_ACCOUNT_NOT_FOUND, R.string.TUIKitErrorSVRProfileAccountNotFound);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_PROFILE_ADMIN_REQUIRED, R.string.TUIKitErrorSVRProfileAdminRequired);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_PROFILE_SENSITIVE_TEXT, R.string.TUIKitErrorSVRProfileSensitiveText);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_PROFILE_INTERNAL_ERROR, R.string.TUIKitErrorSVRProfileInternalError);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_PROFILE_READ_PERMISSION_REQUIRED, R.string.TUIKitErrorSVRProfileReadWritePermissionRequired);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_PROFILE_WRITE_PERMISSION_REQUIRED, R.string.TUIKitErrorSVRProfileReadWritePermissionRequired);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_PROFILE_TAG_NOT_FOUND, R.string.TUIKitErrorSVRProfileTagNotFound);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_PROFILE_SIZE_LIMIT, R.string.TUIKitErrorSVRProfileSizeLimit);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_PROFILE_VALUE_ERROR, R.string.TUIKitErrorSVRProfileValueError);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_PROFILE_INVALID_VALUE_FORMAT, R.string.TUIKitErrorSVRProfileInvalidValueFormat);

        // 关系链错误码
        // Relationship chain error codes
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_FRIENDSHIP_INVALID_PARAMETERS, R.string.TUIKitErrorSVRFriendshipInvalidParameters);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_FRIENDSHIP_INVALID_SDKAPPID, R.string.TUIKitErrorSVRFriendshipInvalidSdkAppid);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_FRIENDSHIP_ACCOUNT_NOT_FOUND, R.string.TUIKitErrorSVRFriendshipAccountNotFound);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_FRIENDSHIP_ADMIN_REQUIRED, R.string.TUIKitErrorSVRFriendshipAdminRequired);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_FRIENDSHIP_SENSITIVE_TEXT, R.string.TUIKitErrorSVRFriendshipSensitiveText);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_FRIENDSHIP_INTERNAL_ERROR, R.string.TUIKitErrorSVRAccountInternalError);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_FRIENDSHIP_NET_TIMEOUT, R.string.TUIKitErrorSVRFriendshipNetTimeout);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_FRIENDSHIP_WRITE_CONFLICT, R.string.TUIKitErrorSVRFriendshipWriteConflict);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_FRIENDSHIP_ADD_FRIEND_DENY, R.string.TUIKitErrorSVRFriendshipAddFriendDeny);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_FRIENDSHIP_COUNT_LIMIT, R.string.TUIkitErrorSVRFriendshipCountLimit);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_FRIENDSHIP_GROUP_COUNT_LIMIT, R.string.TUIKitErrorSVRFriendshipGroupCountLimit);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_FRIENDSHIP_PENDENCY_LIMIT, R.string.TUIKitErrorSVRFriendshipPendencyLimit);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_FRIENDSHIP_BLACKLIST_LIMIT, R.string.TUIKitErrorSVRFriendshipBlacklistLimit);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_FRIENDSHIP_PEER_FRIEND_LIMIT, R.string.TUIKitErrorSVRFriendshipPeerFriendLimit);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_FRIENDSHIP_IN_SELF_BLACKLIST, R.string.TUIKitErrorSVRFriendshipInSelfBlacklist);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_FRIENDSHIP_ALLOW_TYPE_DENY_ANY, R.string.TUIKitErrorSVRFriendshipAllowTypeDenyAny);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_FRIENDSHIP_IN_PEER_BLACKLIST, R.string.TUIKitErrorSVRFriendshipInPeerBlackList);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_FRIENDSHIP_ALLOW_TYPE_NEED_CONFIRM, R.string.TUIKitErrorSVRFriendshipAllowTypeNeedConfirm);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_FRIENDSHIP_ADD_FRIEND_SEC_RSTR, R.string.TUIKitErrorSVRFriendshipAddFriendSecRstr);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_FRIENDSHIP_PENDENCY_NOT_FOUND, R.string.TUIKitErrorSVRFriendshipPendencyNotFound);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_FRIENDSHIP_DEL_FRIEND_SEC_RSTR, R.string.TUIKitErrorSVRFriendshipDelFriendSecRstr);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_FRIENDSHIP_ACCOUNT_NOT_FOUND_EX, R.string.TUIKirErrorSVRFriendAccountNotFoundEx);

        // 最近联系人错误码
        // Error codes for recent contacts
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_CONV_ACCOUNT_NOT_FOUND, R.string.TUIKirErrorSVRFriendAccountNotFoundEx);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_CONV_INVALID_PARAMETERS, R.string.TUIKitErrorSVRFriendshipInvalidParameters);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_CONV_ADMIN_REQUIRED, R.string.TUIKitErrorSVRFriendshipAdminRequired);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_CONV_INTERNAL_ERROR, R.string.TUIKitErrorSVRAccountInternalError);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_CONV_NET_TIMEOUT, R.string.TUIKitErrorSVRFriendshipNetTimeout);

        // 消息错误码
        // Message error codes
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_MSG_PKG_PARSE_FAILED, R.string.TUIKitErrorSVRMsgPkgParseFailed);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_MSG_INTERNAL_AUTH_FAILED, R.string.TUIKitErrorSVRMsgInternalAuthFailed);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_MSG_INVALID_ID, R.string.TUIKitErrorSVRMsgInvalidId);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_MSG_NET_ERROR, R.string.TUIKitErrorSVRMsgNetError);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_MSG_INTERNAL_ERROR1, R.string.TUIKitErrorSVRAccountInternalError);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_MSG_PUSH_DENY, R.string.TUIKitErrorSVRMsgPushDeny);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_MSG_IN_PEER_BLACKLIST, R.string.TUIKitErrorSVRMsgInPeerBlackList);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_MSG_BOTH_NOT_FRIEND, R.string.TUIKitErrorSVRMsgBothNotFriend);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_MSG_NOT_PEER_FRIEND, R.string.TUIKitErrorSVRMsgNotPeerFriend);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_MSG_NOT_SELF_FRIEND, R.string.TUIkitErrorSVRMsgNotSelfFriend);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_MSG_SHUTUP_DENY, R.string.TUIKitErrorSVRMsgShutupDeny);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_MSG_REVOKE_TIME_LIMIT, R.string.TUIKitErrorSVRMsgRevokeTimeLimit);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_MSG_DEL_RAMBLE_INTERNAL_ERROR, R.string.TUIKitErrorSVRMsgDelRambleInternalError);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_MSG_JSON_PARSE_FAILED, R.string.TUIKitErrorSVRMsgJsonParseFailed);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_MSG_INVALID_JSON_BODY_FORMAT, R.string.TUIKitErrorSVRMsgInvalidJsonBodyFormat);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_MSG_INVALID_TO_ACCOUNT, R.string.TUIKitErrorSVRMsgInvalidToAccount);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_MSG_INVALID_RAND, R.string.TUIKitErrorSVRMsgInvalidRand);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_MSG_INVALID_TIMESTAMP, R.string.TUIKitErrorSVRMsgInvalidTimestamp);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_MSG_BODY_NOT_ARRAY, R.string.TUIKitErrorSVRMsgBodyNotArray);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_MSG_ADMIN_REQUIRED, R.string.TUIKitErrorSVRAccountAdminRequired);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_MSG_INVALID_JSON_FORMAT, R.string.TUIKitErrorSVRMsgInvalidJsonFormat);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_MSG_TO_ACCOUNT_COUNT_LIMIT, R.string.TUIKitErrorSVRMsgToAccountCountLimit);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_MSG_TO_ACCOUNT_NOT_FOUND, R.string.TUIKitErrorSVRMsgToAccountNotFound);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_MSG_TIME_LIMIT, R.string.TUIKitErrorSVRMsgTimeLimit);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_MSG_INVALID_SYNCOTHERMACHINE, R.string.TUIKitErrorSVRMsgInvalidSyncOtherMachine);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_MSG_INVALID_MSGLIFETIME, R.string.TUIkitErrorSVRMsgInvalidMsgLifeTime);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_MSG_ACCOUNT_NOT_FOUND, R.string.TUIKirErrorSVRFriendAccountNotFoundEx);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_MSG_INTERNAL_ERROR2, R.string.TUIKitErrorSVRAccountInternalError);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_MSG_INTERNAL_ERROR3, R.string.TUIKitErrorSVRAccountInternalError);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_MSG_INTERNAL_ERROR4, R.string.TUIKitErrorSVRAccountInternalError);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_MSG_INTERNAL_ERROR5, R.string.TUIKitErrorSVRAccountInternalError);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_MSG_BODY_SIZE_LIMIT, R.string.TUIKitErrorSVRMsgBodySizeLimit);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_MSG_LONGPOLLING_COUNT_LIMIT, R.string.TUIKitErrorSVRmsgLongPollingCountLimit);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SDK_INTERFACE_NOT_SUPPORT, R.string.TUIKitErrorUnsupporInterface);

        // 群组错误码
        // Group error codes
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_GROUP_INTERNAL_ERROR, R.string.TUIKitErrorSVRAccountInternalError);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_GROUP_API_NAME_ERROR, R.string.TUIKitErrorSVRGroupApiNameError);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_GROUP_INVALID_PARAMETERS, R.string.TUIKitErrorSVRResInvalidParameters);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_GROUP_ACOUNT_COUNT_LIMIT, R.string.TUIKitErrorSVRGroupAccountCountLimit);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_GROUP_FREQ_LIMIT, R.string.TUIkitErrorSVRGroupFreqLimit);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_GROUP_PERMISSION_DENY, R.string.TUIKitErrorSVRGroupPermissionDeny);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_GROUP_INVALID_REQ, R.string.TUIKitErrorSVRGroupInvalidReq);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_GROUP_SUPER_NOT_ALLOW_QUIT, R.string.TUIKitErrorSVRGroupSuperNotAllowQuit);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_GROUP_NOT_FOUND, R.string.TUIKitErrorSVRGroupNotFound);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_GROUP_JSON_PARSE_FAILED, R.string.TUIKitErrorSVRGroupJsonParseFailed);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_GROUP_INVALID_ID, R.string.TUIKitErrorSVRGroupInvalidId);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_GROUP_ALLREADY_MEMBER, R.string.TUIKitErrorSVRGroupAllreadyMember);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_GROUP_FULL_MEMBER_COUNT, R.string.TUIKitErrorSVRGroupFullMemberCount);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_GROUP_INVALID_GROUPID, R.string.TUIKitErrorSVRGroupInvalidGroupId);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_GROUP_REJECT_FROM_THIRDPARTY, R.string.TUIKitErrorSVRGroupRejectFromThirdParty);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_GROUP_SHUTUP_DENY, R.string.TUIKitErrorSVRGroupShutDeny);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_GROUP_RSP_SIZE_LIMIT, R.string.TUIKitErrorSVRGroupRspSizeLimit);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_GROUP_ACCOUNT_NOT_FOUND, R.string.TUIKitErrorSVRGroupAccountNotFound);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_GROUP_GROUPID_IN_USED, R.string.TUIKitErrorSVRGroupGroupIdInUse);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_GROUP_SEND_MSG_FREQ_LIMIT, R.string.TUIKitErrorSVRGroupSendMsgFreqLimit);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_GROUP_REQ_ALLREADY_BEEN_PROCESSED, R.string.TUIKitErrorSVRGroupReqAllreadyBeenProcessed);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_GROUP_GROUPID_IN_USED_FOR_SUPER, R.string.TUIKitErrorSVRGroupGroupIdUserdForSuper);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_GROUP_SDKAPPID_DENY, R.string.TUIKitErrorSVRGroupSDkAppidDeny);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_GROUP_REVOKE_MSG_NOT_FOUND, R.string.TUIKitErrorSVRGroupRevokeMsgNotFound);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_GROUP_REVOKE_MSG_TIME_LIMIT, R.string.TUIKitErrorSVRGroupRevokeMsgTimeLimit);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_GROUP_REVOKE_MSG_DENY, R.string.TUIKitErrorSVRGroupRevokeMsgDeny);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_GROUP_NOT_ALLOW_REVOKE_MSG, R.string.TUIKitErrorSVRGroupNotAllowRevokeMsg);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_GROUP_REMOVE_MSG_DENY, R.string.TUIKitErrorSVRGroupRemoveMsgDeny);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_GROUP_NOT_ALLOW_REMOVE_MSG, R.string.TUIKitErrorSVRGroupNotAllowRemoveMsg);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_GROUP_AVCHATROOM_COUNT_LIMIT, R.string.TUIKitErrorSVRGroupAvchatRoomCountLimit);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_GROUP_COUNT_LIMIT, R.string.TUIKitErrorSVRGroupCountLimit);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SVR_GROUP_MEMBER_COUNT_LIMIT, R.string.TUIKitErrorSVRGroupMemberCountLimit);

        /////////////////////////////////////////////////////////////////////////////////
        //
        //                      （三）V3版本错误码，待废弃
        //                           IM SDK V3 error codes,to be abandoned
        //
        /////////////////////////////////////////////////////////////////////////////////

        ERROR_CODE_MAP.put(BaseConstants.ERR_NO_SUCC_RESULT, R.string.TUIKitErrorSVRNoSuccessResult);
        ERROR_CODE_MAP.put(BaseConstants.ERR_TO_USER_INVALID, R.string.TUIKitErrorSVRToUserInvalid);
        ERROR_CODE_MAP.put(BaseConstants.ERR_INIT_CORE_FAIL, R.string.TUIKitErrorSVRInitCoreFail);
        ERROR_CODE_MAP.put(BaseConstants.ERR_EXPIRED_SESSION_NODE, R.string.TUIKitErrorExpiredSessionNode);
        ERROR_CODE_MAP.put(BaseConstants.ERR_LOGGED_OUT_BEFORE_LOGIN_FINISHED, R.string.TUIKitErrorLoggedOutBeforeLoginFinished);
        ERROR_CODE_MAP.put(BaseConstants.ERR_TLSSDK_NOT_INITIALIZED, R.string.TUIKitErrorTLSSDKNotInitialized);
        ERROR_CODE_MAP.put(BaseConstants.ERR_TLSSDK_USER_NOT_FOUND, R.string.TUIKitErrorTLSSDKUserNotFound);
        //        errorCodeMap.put(BaseConstants.ERR_BIND_FAIL_UNKNOWN:
        //            return @"QALSDK未知原因BIND失败";
        //        errorCodeMap.put(BaseConstants.ERR_BIND_FAIL_NO_SSOTICKET:
        //            return @"缺少SSO票据";
        //        errorCodeMap.put(BaseConstants.ERR_BIND_FAIL_REPEATD_BIND:
        //            return @"重复BIND";
        //        errorCodeMap.put(BaseConstants.ERR_BIND_FAIL_TINYID_NULL:
        //            return @"tiny为空";
        //        errorCodeMap.put(BaseConstants.ERR_BIND_FAIL_GUID_NULL:
        //            return @"guid为空";
        //        errorCodeMap.put(BaseConstants.ERR_BIND_FAIL_UNPACK_REGPACK_FAILED:
        //            return @"解注册包失败";
        ERROR_CODE_MAP.put(BaseConstants.ERR_BIND_FAIL_REG_TIMEOUT, R.string.TUIKitErrorBindFaildRegTimeout);
        ERROR_CODE_MAP.put(BaseConstants.ERR_BIND_FAIL_ISBINDING, R.string.TUIKitErrorBindFaildIsBinding);
        ERROR_CODE_MAP.put(BaseConstants.ERR_PACKET_FAIL_UNKNOWN, R.string.TUIKitErrorPacketFailUnknown);
        ERROR_CODE_MAP.put(BaseConstants.ERR_PACKET_FAIL_REQ_NO_NET, R.string.TUIKitErrorPacketFailReqNoNet);
        ERROR_CODE_MAP.put(BaseConstants.ERR_PACKET_FAIL_RESP_NO_NET, R.string.TUIKitErrorPacketFailRespNoNet);
        ERROR_CODE_MAP.put(BaseConstants.ERR_PACKET_FAIL_REQ_NO_AUTH, R.string.TUIKitErrorPacketFailReqNoAuth);
        ERROR_CODE_MAP.put(BaseConstants.ERR_PACKET_FAIL_SSO_ERR, R.string.TUIKitErrorPacketFailSSOErr);
        ERROR_CODE_MAP.put(BaseConstants.ERR_PACKET_FAIL_REQ_TIMEOUT, R.string.TUIKitErrorSVRRequestTimeout);
        ERROR_CODE_MAP.put(BaseConstants.ERR_PACKET_FAIL_RESP_TIMEOUT, R.string.TUIKitErrorPacketFailRespTimeout);

        // errorCodeMap.put(BaseConstants.ERR_PACKET_FAIL_REQ_ON_RESEND:
        // errorCodeMap.put(BaseConstants.ERR_PACKET_FAIL_RESP_NO_RESEND:
        // errorCodeMap.put(BaseConstants.ERR_PACKET_FAIL_FLOW_SAVE_FILTERED:
        // errorCodeMap.put(BaseConstants.ERR_PACKET_FAIL_REQ_OVER_LOAD:
        // errorCodeMap.put(BaseConstants.ERR_PACKET_FAIL_LOGIC_ERR:
        ERROR_CODE_MAP.put(BaseConstants.ERR_FRIENDSHIP_PROXY_NOT_SYNCED, R.string.TUIKitErrorFriendshipProxySyncing);
        ERROR_CODE_MAP.put(BaseConstants.ERR_FRIENDSHIP_PROXY_SYNCING, R.string.TUIKitErrorFriendshipProxySyncing);
        ERROR_CODE_MAP.put(BaseConstants.ERR_FRIENDSHIP_PROXY_SYNCED_FAIL, R.string.TUIKitErrorFriendshipProxySyncedFail);
        ERROR_CODE_MAP.put(BaseConstants.ERR_FRIENDSHIP_PROXY_LOCAL_CHECK_ERR, R.string.TUIKitErrorFriendshipProxyLocalCheckErr);
        ERROR_CODE_MAP.put(BaseConstants.ERR_GROUP_INVALID_FIELD, R.string.TUIKitErrorGroupInvalidField);
        ERROR_CODE_MAP.put(BaseConstants.ERR_GROUP_STORAGE_DISABLED, R.string.TUIKitErrorGroupStoreageDisabled);
        ERROR_CODE_MAP.put(BaseConstants.ERR_LOADGRPINFO_FAILED, R.string.TUIKitErrorLoadGrpInfoFailed);
        ERROR_CODE_MAP.put(BaseConstants.ERR_REQ_NO_NET_ON_REQ, R.string.TUIKitErrorReqNoNetOnReq);
        ERROR_CODE_MAP.put(BaseConstants.ERR_REQ_NO_NET_ON_RSP, R.string.TUIKitErrorReqNoNetOnResp);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SERIVCE_NOT_READY, R.string.TUIKitErrorServiceNotReady);
        ERROR_CODE_MAP.put(BaseConstants.ERR_LOGIN_AUTH_FAILED, R.string.TUIKitErrorLoginAuthFailed);
        ERROR_CODE_MAP.put(BaseConstants.ERR_NEVER_CONNECT_AFTER_LAUNCH, R.string.TUIKitErrorNeverConnectAfterLaunch);
        ERROR_CODE_MAP.put(BaseConstants.ERR_REQ_FAILED, R.string.TUIKitErrorReqFailed);
        ERROR_CODE_MAP.put(BaseConstants.ERR_REQ_INVALID_REQ, R.string.TUIKitErrorReqInvaidReq);
        ERROR_CODE_MAP.put(BaseConstants.ERR_REQ_OVERLOADED, R.string.TUIKitErrorReqOnverLoaded);
        ERROR_CODE_MAP.put(BaseConstants.ERR_REQ_KICK_OFF, R.string.TUIKitErrorReqKickOff);
        ERROR_CODE_MAP.put(BaseConstants.ERR_REQ_SERVICE_SUSPEND, R.string.TUIKitErrorReqServiceSuspend);
        ERROR_CODE_MAP.put(BaseConstants.ERR_REQ_INVALID_SIGN, R.string.TUIKitErrorReqInvalidSign);
        ERROR_CODE_MAP.put(BaseConstants.ERR_REQ_INVALID_COOKIE, R.string.TUIKitErrorReqInvalidCookie);
        ERROR_CODE_MAP.put(BaseConstants.ERR_LOGIN_TLS_RSP_PARSE_FAILED, R.string.TUIKitErrorLoginTlsRspParseFailed);
        ERROR_CODE_MAP.put(BaseConstants.ERR_LOGIN_OPENMSG_TIMEOUT, R.string.TUIKitErrorLoginOpenMsgTimeout);
        ERROR_CODE_MAP.put(BaseConstants.ERR_LOGIN_OPENMSG_RSP_PARSE_FAILED, R.string.TUIKitErrorLoginOpenMsgRspParseFailed);
        ERROR_CODE_MAP.put(BaseConstants.ERR_LOGIN_TLS_DECRYPT_FAILED, R.string.TUIKitErrorLoginTslDecryptFailed);
        ERROR_CODE_MAP.put(BaseConstants.ERR_WIFI_NEED_AUTH, R.string.TUIKitErrorWifiNeedAuth);
        ERROR_CODE_MAP.put(BaseConstants.ERR_USER_CANCELED, R.string.TUIKitErrorUserCanceled);
        ERROR_CODE_MAP.put(BaseConstants.ERR_REVOKE_TIME_LIMIT_EXCEED, R.string.TUIkitErrorRevokeTimeLimitExceed);
        ERROR_CODE_MAP.put(BaseConstants.ERR_LACK_UGC_EXT, R.string.TUIKitErrorLackUGExt);
        ERROR_CODE_MAP.put(BaseConstants.ERR_AUTOLOGIN_NEED_USERSIG, R.string.TUIKitErrorAutoLoginNeedUserSig);
        ERROR_CODE_MAP.put(BaseConstants.ERR_QAL_NO_SHORT_CONN_AVAILABLE, R.string.TUIKitErrorQALNoShortConneAvailable);
        ERROR_CODE_MAP.put(BaseConstants.ERR_REQ_CONTENT_ATTACK, R.string.TUIKitErrorReqContentAttach);
        ERROR_CODE_MAP.put(BaseConstants.ERR_LOGIN_SIG_EXPIRE, R.string.TUIKitErrorLoginSigExpire);
        ERROR_CODE_MAP.put(BaseConstants.ERR_SDK_HAD_INITIALIZED, R.string.TUIKitErrorSDKHadInit);
        ERROR_CODE_MAP.put(BaseConstants.ERR_OPENBDH_BASE, R.string.TUIKitErrorOpenBDHBase);
        ERROR_CODE_MAP.put(BaseConstants.ERR_REQUEST_NO_NET_ONREQ, R.string.TUIKitErrorRequestNoNetOnReq);
        ERROR_CODE_MAP.put(BaseConstants.ERR_REQUEST_NO_NET_ONRSP, R.string.TUIKitErrorRequestNoNetOnRsp);
        //        errorCodeMap.put(BaseConstants.ERR_REQUEST_FAILED:
        //            return @"QAL执行失败";
        //        errorCodeMap.put(BaseConstants.ERR_REQUEST_INVALID_REQ:
        //            return @"请求非法，toMsgService非法";
        ERROR_CODE_MAP.put(BaseConstants.ERR_REQUEST_OVERLOADED, R.string.TUIKitErrorRequestOnverLoaded);
        ERROR_CODE_MAP.put(BaseConstants.ERR_REQUEST_KICK_OFF, R.string.TUIKitErrorReqKickOff);
        ERROR_CODE_MAP.put(BaseConstants.ERR_REQUEST_SERVICE_SUSPEND, R.string.TUIKitErrorReqServiceSuspend);
        ERROR_CODE_MAP.put(BaseConstants.ERR_REQUEST_INVALID_SIGN, R.string.TUIKitErrorReqInvalidSign);
        ERROR_CODE_MAP.put(BaseConstants.ERR_REQUEST_INVALID_COOKIE, R.string.TUIKitErrorReqInvalidCookie);
    }

    public static String convertIMError(int code, String msg) {
        Integer errorStringId = ERROR_CODE_MAP.get(code);
        if (errorStringId != null) {
            return getLocalizedString(errorStringId);
        }
        return msg;
    }

    private static String getLocalizedString(int errStringId) {
        return TUIConfig.getAppContext().getString(errStringId);
    }
}
