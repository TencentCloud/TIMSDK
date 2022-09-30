package com.tencent.qcloud.tuicore.util;

import com.tencent.imsdk.BaseConstants;
import com.tencent.qcloud.tuicore.R;
import com.tencent.qcloud.tuicore.TUIConfig;

public class ErrorMessageConverter {

    public static String convertIMError(int code, String msg) {
        /////////////////////////////////////////////////////////////////////////////////
        //
        //                      （一）IM SDK 的错误码
        //                           IM SDK error codes
        //
        /////////////////////////////////////////////////////////////////////////////////
        switch (code) {
            // 通用错误码
            // Common error codes
            case BaseConstants.ERR_IN_PROGESS:
                return getLocalizedString(R.string.TUIKitErrorInProcess);
            case BaseConstants.ERR_INVALID_PARAMETERS:
                return getLocalizedString(R.string.TUIKitErrorInvalidParameters);
            case BaseConstants.ERR_IO_OPERATION_FAILED:
                return getLocalizedString(R.string.TUIKitErrorIOOperateFaild);
            case BaseConstants.ERR_INVALID_JSON:
                return getLocalizedString(R.string.TUIKitErrorInvalidJson);
            case BaseConstants.ERR_OUT_OF_MEMORY:
                return getLocalizedString(R.string.TUIKitErrorOutOfMemory);
            case BaseConstants.ERR_PARSE_RESPONSE_FAILED:
                return getLocalizedString(R.string.TUIKitErrorParseResponseFaild);
            case BaseConstants.ERR_SERIALIZE_REQ_FAILED:
                return getLocalizedString(R.string.TUIKitErrorSerializeReqFaild);
            case BaseConstants.ERR_SDK_NOT_INITIALIZED:
                return getLocalizedString(R.string.TUIKitErrorSDKNotInit);
            case BaseConstants.ERR_LOADMSG_FAILED:
                return getLocalizedString(R.string.TUIKitErrorLoadMsgFailed);
            case BaseConstants.ERR_DATABASE_OPERATE_FAILED:
                return getLocalizedString(R.string.TUIKitErrorDatabaseOperateFailed);
            case BaseConstants.ERR_SDK_COMM_CROSS_THREAD:
                return getLocalizedString(R.string.TUIKitErrorCrossThread);
            case BaseConstants.ERR_SDK_COMM_TINYID_EMPTY:
                return getLocalizedString(R.string.TUIKitErrorTinyIdEmpty);
            case BaseConstants.ERR_SDK_COMM_INVALID_IDENTIFIER:
                return getLocalizedString(R.string.TUIKitErrorInvalidIdentifier);
            case BaseConstants.ERR_SDK_COMM_FILE_NOT_FOUND:
                return getLocalizedString(R.string.TUIKitErrorFileNotFound);
            case BaseConstants.ERR_SDK_COMM_FILE_TOO_LARGE:
                return getLocalizedString(R.string.TUIKitErrorFileTooLarge);
            case BaseConstants.ERR_SDK_COMM_FILE_SIZE_EMPTY:
                return getLocalizedString(R.string.TUIKitErrorEmptyFile);
            case BaseConstants.ERR_SDK_COMM_FILE_OPEN_FAILED:
                return getLocalizedString(R.string.TUIKitErrorFileOpenFailed);

            // 帐号错误码
            // Account error codes
            case BaseConstants.ERR_SDK_NOT_LOGGED_IN:
                return getLocalizedString(R.string.TUIKitErrorNotLogin);
            case BaseConstants.ERR_NO_PREVIOUS_LOGIN:
                return getLocalizedString(R.string.TUIKitErrorNoPreviousLogin);
            case BaseConstants.ERR_USER_SIG_EXPIRED:
                return getLocalizedString(R.string.TUIKitErrorUserSigExpired);
            case BaseConstants.ERR_LOGIN_KICKED_OFF_BY_OTHER:
                return getLocalizedString(R.string.TUIKitErrorLoginKickedOffByOther);
//        case BaseConstants.ERR_LOGIN_IN_PROCESS:
//            return @"登录正在执行中";
//        case BaseConstants.ERR_LOGOUT_IN_PROCESS:
//            return @"登出正在执行中";
            case BaseConstants.ERR_SDK_ACCOUNT_TLS_INIT_FAILED:
                return getLocalizedString(R.string.TUIKitErrorTLSSDKInit);
            case BaseConstants.ERR_SDK_ACCOUNT_TLS_NOT_INITIALIZED:
                return getLocalizedString(R.string.TUIKitErrorTLSSDKUninit);
            case BaseConstants.ERR_SDK_ACCOUNT_TLS_TRANSPKG_ERROR:
                return getLocalizedString(R.string.TUIKitErrorTLSSDKTRANSPackageFormat);
            case BaseConstants.ERR_SDK_ACCOUNT_TLS_DECRYPT_FAILED:
                return getLocalizedString(R.string.TUIKitErrorTLSDecrypt);
            case BaseConstants.ERR_SDK_ACCOUNT_TLS_REQUEST_FAILED:
                return getLocalizedString(R.string.TUIKitErrorTLSSDKRequest);
            case BaseConstants.ERR_SDK_ACCOUNT_TLS_REQUEST_TIMEOUT:
                return getLocalizedString(R.string.TUIKitErrorTLSSDKRequestTimeout);

            // 消息错误码
            // Message error codes
            case BaseConstants.ERR_INVALID_CONVERSATION:
                return getLocalizedString(R.string.TUIKitErrorInvalidConveration);
            case BaseConstants.ERR_FILE_TRANS_AUTH_FAILED:
                return getLocalizedString(R.string.TUIKitErrorFileTransAuthFailed);
            case BaseConstants.ERR_FILE_TRANS_NO_SERVER:
                return getLocalizedString(R.string.TUIKitErrorFileTransNoServer);
            case BaseConstants.ERR_FILE_TRANS_UPLOAD_FAILED:
                return getLocalizedString(R.string.TUIKitErrorFileTransUploadFailed);
//            case BaseConstants.ERR_IMAGE_UPLOAD_FAILED_NOTIMAGE:
//                return TUIKitLocalizableString(R.string.TUIKitErrorFileTransUploadFailedNotImage);
            case BaseConstants.ERR_FILE_TRANS_DOWNLOAD_FAILED:
                return getLocalizedString(R.string.TUIKitErrorFileTransDownloadFailed);
            case BaseConstants.ERR_HTTP_REQ_FAILED:
                return getLocalizedString(R.string.TUIKitErrorHTTPRequestFailed);
            case BaseConstants.ERR_INVALID_MSG_ELEM:
                return getLocalizedString(R.string.TUIKitErrorInvalidMsgElem);
            case BaseConstants.ERR_INVALID_SDK_OBJECT:
                return getLocalizedString(R.string.TUIKitErrorInvalidSDKObject);
            case BaseConstants.ERR_SDK_MSG_BODY_SIZE_LIMIT:
                return getLocalizedString(R.string.TUIKitSDKMsgBodySizeLimit);
            case BaseConstants.ERR_SDK_MSG_KEY_REQ_DIFFER_RSP:
                return getLocalizedString(R.string.TUIKitErrorSDKMsgKeyReqDifferRsp);


            // 群组错误码
            // Group error codes
            case BaseConstants.ERR_SDK_GROUP_INVALID_ID:
                return getLocalizedString(R.string.TUIKitErrorSDKGroupInvalidID);
            case BaseConstants.ERR_SDK_GROUP_INVALID_NAME:
                return getLocalizedString(R.string.TUIKitErrorSDKGroupInvalidName);
            case BaseConstants.ERR_SDK_GROUP_INVALID_INTRODUCTION:
                return getLocalizedString(R.string.TUIKitErrorSDKGroupInvalidIntroduction);
            case BaseConstants.ERR_SDK_GROUP_INVALID_NOTIFICATION:
                return getLocalizedString(R.string.TUIKitErrorSDKGroupInvalidNotification);
            case BaseConstants.ERR_SDK_GROUP_INVALID_FACE_URL:
                return getLocalizedString(R.string.TUIKitErrorSDKGroupInvalidFaceURL);
            case BaseConstants.ERR_SDK_GROUP_INVALID_NAME_CARD:
                return getLocalizedString(R.string.TUIKitErrorSDKGroupInvalidNameCard);
            case BaseConstants.ERR_SDK_GROUP_MEMBER_COUNT_LIMIT:
                return getLocalizedString(R.string.TUIKitErrorSDKGroupMemberCountLimit);
            case BaseConstants.ERR_SDK_GROUP_JOIN_PRIVATE_GROUP_DENY:
                return getLocalizedString(R.string.TUIKitErrorSDKGroupJoinPrivateGroupDeny);
            case BaseConstants.ERR_SDK_GROUP_INVITE_SUPER_DENY:
                return getLocalizedString(R.string.TUIKitErrorSDKGroupInviteSuperDeny);
            case BaseConstants.ERR_SDK_GROUP_INVITE_NO_MEMBER:
                return getLocalizedString(R.string.TUIKitErrorSDKGroupInviteNoMember);


            // 关系链错误码
            // Relationship chain error codes
            case BaseConstants.ERR_SDK_FRIENDSHIP_INVALID_PROFILE_KEY:
                return getLocalizedString(R.string.TUIKitErrorSDKFriendShipInvalidProfileKey);
            case BaseConstants.ERR_SDK_FRIENDSHIP_INVALID_ADD_REMARK:
                return getLocalizedString(R.string.TUIKitErrorSDKFriendshipInvalidAddRemark);
            case BaseConstants.ERR_SDK_FRIENDSHIP_INVALID_ADD_WORDING:
                return getLocalizedString(R.string.TUIKitErrorSDKFriendshipInvalidAddWording);
            case BaseConstants.ERR_SDK_FRIENDSHIP_INVALID_ADD_SOURCE:
                return getLocalizedString(R.string.TUIKitErrorSDKFriendshipInvalidAddSource);
            case BaseConstants.ERR_SDK_FRIENDSHIP_FRIEND_GROUP_EMPTY:
                return getLocalizedString(R.string.TUIKitErrorSDKFriendshipFriendGroupEmpty);


            // 网络错误码
            // Network error codes
            case BaseConstants.ERR_SDK_NET_ENCODE_FAILED:
                return getLocalizedString(R.string.TUIKitErrorSDKNetEncodeFailed);
            case BaseConstants.ERR_SDK_NET_DECODE_FAILED:
                return getLocalizedString(R.string.TUIKitErrorSDKNetDecodeFailed);
            case BaseConstants.ERR_SDK_NET_AUTH_INVALID:
                return getLocalizedString(R.string.TUIKitErrorSDKNetAuthInvalid);
            case BaseConstants.ERR_SDK_NET_COMPRESS_FAILED:
                return getLocalizedString(R.string.TUIKitErrorSDKNetCompressFailed);
            case BaseConstants.ERR_SDK_NET_UNCOMPRESS_FAILED:
                return getLocalizedString(R.string.TUIKitErrorSDKNetUncompressFaile);
            case BaseConstants.ERR_SDK_NET_FREQ_LIMIT:
                return getLocalizedString(R.string.TUIKitErrorSDKNetFreqLimit);
            case BaseConstants.ERR_SDK_NET_REQ_COUNT_LIMIT:
                return getLocalizedString(R.string.TUIKitErrorSDKnetReqCountLimit);
            case BaseConstants.ERR_SDK_NET_DISCONNECT:
                return getLocalizedString(R.string.TUIKitErrorSDKNetDisconnect);
            case BaseConstants.ERR_SDK_NET_ALLREADY_CONN:
                return getLocalizedString(R.string.TUIKitErrorSDKNetAllreadyConn);
            case BaseConstants.ERR_SDK_NET_CONN_TIMEOUT:
                return getLocalizedString(R.string.TUIKitErrorSDKNetConnTimeout);
            case BaseConstants.ERR_SDK_NET_CONN_REFUSE:
                return getLocalizedString(R.string.TUIKitErrorSDKNetConnRefuse);
            case BaseConstants.ERR_SDK_NET_NET_UNREACH:
                return getLocalizedString(R.string.TUIKitErrorSDKNetNetUnreach);
            case BaseConstants.ERR_SDK_NET_SOCKET_NO_BUFF:
                return getLocalizedString(R.string.TUIKitErrorSDKNetSocketNoBuff);
            case BaseConstants.ERR_SDK_NET_RESET_BY_PEER:
                return getLocalizedString(R.string.TUIKitERRORSDKNetResetByPeer);
            case BaseConstants.ERR_SDK_NET_SOCKET_INVALID:
                return getLocalizedString(R.string.TUIKitErrorSDKNetSOcketInvalid);
            case BaseConstants.ERR_SDK_NET_HOST_GETADDRINFO_FAILED:
                return getLocalizedString(R.string.TUIKitErrorSDKNetHostGetAddressFailed);
            case BaseConstants.ERR_SDK_NET_CONNECT_RESET:
                return getLocalizedString(R.string.TUIKitErrorSDKNetConnectReset);
            case BaseConstants.ERR_SDK_NET_WAIT_INQUEUE_TIMEOUT:
                return getLocalizedString(R.string.TUIKitErrorSDKNetWaitInQueueTimeout);
            case BaseConstants.ERR_SDK_NET_WAIT_SEND_TIMEOUT:
                return getLocalizedString(R.string.TUIKitErrorSDKNetWaitSendTimeout);
            case BaseConstants.ERR_SDK_NET_WAIT_ACK_TIMEOUT:
                return getLocalizedString(R.string.TUIKitErrorSDKNetWaitAckTimeut);

            /////////////////////////////////////////////////////////////////////////////////
            //
            //                      （二）服务端
            //                           Server error codes
            //
            /////////////////////////////////////////////////////////////////////////////////

            // 网络接入层的错误码
            // Access layer error codes for network
            case BaseConstants.ERR_SVR_SSO_CONNECT_LIMIT:
                return getLocalizedString(R.string.TUIKitErrorSDKSVRSSOConnectLimit);
            case BaseConstants.ERR_SVR_SSO_VCODE:
                return getLocalizedString(R.string.TUIKitErrorSDKSVRSSOVCode);
            case BaseConstants.ERR_SVR_SSO_D2_EXPIRED:
                return getLocalizedString(R.string.TUIKitErrorSVRSSOD2Expired);
            case BaseConstants.ERR_SVR_SSO_A2_UP_INVALID:
                return getLocalizedString(R.string.TUIKitErrorSVRA2UpInvalid);
            case BaseConstants.ERR_SVR_SSO_A2_DOWN_INVALID:
                return getLocalizedString(R.string.TUIKitErrorSVRA2DownInvalid);
            case BaseConstants.ERR_SVR_SSO_EMPTY_KEY:
                return getLocalizedString(R.string.TUIKitErrorSVRSSOEmpeyKey);
            case BaseConstants.ERR_SVR_SSO_UIN_INVALID:
                return getLocalizedString(R.string.TUIKitErrorSVRSSOUinInvalid);
            case BaseConstants.ERR_SVR_SSO_VCODE_TIMEOUT:
                return getLocalizedString(R.string.TUIKitErrorSVRSSOVCodeTimeout);
            case BaseConstants.ERR_SVR_SSO_NO_IMEI_AND_A2:
                return getLocalizedString(R.string.TUIKitErrorSVRSSONoImeiAndA2);
            case BaseConstants.ERR_SVR_SSO_COOKIE_INVALID:
                return getLocalizedString(R.string.TUIKitErrorSVRSSOCookieInvalid);
            case BaseConstants.ERR_SVR_SSO_DOWN_TIP:
                return getLocalizedString(R.string.TUIKitErrorSVRSSODownTips);
            case BaseConstants.ERR_SVR_SSO_DISCONNECT:
                return getLocalizedString(R.string.TUIKitErrorSVRSSODisconnect);
            case BaseConstants.ERR_SVR_SSO_IDENTIFIER_INVALID:
                return getLocalizedString(R.string.TUIKitErrorSVRSSOIdentifierInvalid);
            case BaseConstants.ERR_SVR_SSO_CLIENT_CLOSE:
                return getLocalizedString(R.string.TUIKitErrorSVRSSOClientClose);
            case BaseConstants.ERR_SVR_SSO_MSFSDK_QUIT:
                return getLocalizedString(R.string.TUIKitErrorSVRSSOMSFSDKQuit);
            case BaseConstants.ERR_SVR_SSO_D2KEY_WRONG:
                return getLocalizedString(R.string.TUIKitErrorSVRSSOD2KeyWrong);
            case BaseConstants.ERR_SVR_SSO_UNSURPPORT:
                return getLocalizedString(R.string.TUIKitErrorSVRSSOUnsupport);
            case BaseConstants.ERR_SVR_SSO_PREPAID_ARREARS:
                return getLocalizedString(R.string.TUIKitErrorSVRSSOPrepaidArrears);
            case BaseConstants.ERR_SVR_SSO_PACKET_WRONG:
                return getLocalizedString(R.string.TUIKitErrorSVRSSOPacketWrong);
            case BaseConstants.ERR_SVR_SSO_APPID_BLACK_LIST:
                return getLocalizedString(R.string.TUIKitErrorSVRSSOAppidBlackList);
            case BaseConstants.ERR_SVR_SSO_CMD_BLACK_LIST:
                return getLocalizedString(R.string.TUIKitErrorSVRSSOCmdBlackList);
            case BaseConstants.ERR_SVR_SSO_APPID_WITHOUT_USING:
                return getLocalizedString(R.string.TUIKitErrorSVRSSOAppidWithoutUsing);
            case BaseConstants.ERR_SVR_SSO_FREQ_LIMIT:
                return getLocalizedString(R.string.TUIKitErrorSVRSSOFreqLimit);
            case BaseConstants.ERR_SVR_SSO_OVERLOAD:
                return getLocalizedString(R.string.TUIKitErrorSVRSSOOverload);

            // 资源文件错误码
            // Resource file error codes
            case BaseConstants.ERR_SVR_RES_NOT_FOUND:
                return getLocalizedString(R.string.TUIKitErrorSVRResNotFound);
            case BaseConstants.ERR_SVR_RES_ACCESS_DENY:
                return getLocalizedString(R.string.TUIKitErrorSVRResAccessDeny);
            case BaseConstants.ERR_SVR_RES_SIZE_LIMIT:
                return getLocalizedString(R.string.TUIKitErrorSVRResSizeLimit);
            case BaseConstants.ERR_SVR_RES_SEND_CANCEL:
                return getLocalizedString(R.string.TUIKitErrorSVRResSendCancel);
            case BaseConstants.ERR_SVR_RES_READ_FAILED:
                return getLocalizedString(R.string.TUIKitErrorSVRResReadFailed);
            case BaseConstants.ERR_SVR_RES_TRANSFER_TIMEOUT:
                return getLocalizedString(R.string.TUIKitErrorSVRResTransferTimeout);
            case BaseConstants.ERR_SVR_RES_INVALID_PARAMETERS:
                return getLocalizedString(R.string.TUIKitErrorSVRResInvalidParameters);
            case BaseConstants.ERR_SVR_RES_INVALID_FILE_MD5:
                return getLocalizedString(R.string.TUIKitErrorSVRResInvalidFileMd5);
            case BaseConstants.ERR_SVR_RES_INVALID_PART_MD5:
                return getLocalizedString(R.string.TUIKitErrorSVRResInvalidPartMd5);

            // 后台公共错误码
            // Common backend error codes
            case BaseConstants.ERR_SVR_COMM_INVALID_HTTP_URL:
                return getLocalizedString(R.string.TUIKitErrorSVRCommonInvalidHttpUrl);
            case BaseConstants.ERR_SVR_COMM_REQ_JSON_PARSE_FAILED:
                return getLocalizedString(R.string.TUIKitErrorSVRCommomReqJsonParseFailed);
            case BaseConstants.ERR_SVR_COMM_INVALID_ACCOUNT:
                return getLocalizedString(R.string.TUIKitErrorSVRCommonInvalidAccount);
            case BaseConstants.ERR_SVR_COMM_INVALID_ACCOUNT_EX:
                return getLocalizedString(R.string.TUIKitErrorSVRCommonInvalidAccount);
            case BaseConstants.ERR_SVR_COMM_INVALID_SDKAPPID:
                return getLocalizedString(R.string.TUIKitErrorSVRCommonInvalidSdkappid);
            case BaseConstants.ERR_SVR_COMM_REST_FREQ_LIMIT:
                return getLocalizedString(R.string.TUIKitErrorSVRCommonRestFreqLimit);
            case BaseConstants.ERR_SVR_COMM_REQUEST_TIMEOUT:
                return getLocalizedString(R.string.TUIKitErrorSVRCommonRequestTimeout);
            case BaseConstants.ERR_SVR_COMM_INVALID_RES:
                return getLocalizedString(R.string.TUIKitErrorSVRCommonInvalidRes);
            case BaseConstants.ERR_SVR_COMM_ID_NOT_ADMIN:
                return getLocalizedString(R.string.TUIKitErrorSVRCommonIDNotAdmin);
            case BaseConstants.ERR_SVR_COMM_SDKAPPID_FREQ_LIMIT:
                return getLocalizedString(R.string.TUIKitErrorSVRCommonSdkappidFreqLimit);
            case BaseConstants.ERR_SVR_COMM_SDKAPPID_MISS:
                return getLocalizedString(R.string.TUIKitErrorSVRCommonSdkappidMiss);
            case BaseConstants.ERR_SVR_COMM_RSP_JSON_PARSE_FAILED:
                return getLocalizedString(R.string.TUIKitErrorSVRCommonRspJsonParseFailed);
            case BaseConstants.ERR_SVR_COMM_EXCHANGE_ACCOUNT_TIMEUT:
                return getLocalizedString(R.string.TUIKitErrorSVRCommonExchangeAccountTimeout);
            case BaseConstants.ERR_SVR_COMM_INVALID_ID_FORMAT:
                return getLocalizedString(R.string.TUIKitErrorSVRCommonInvalidIdFormat);
            case BaseConstants.ERR_SVR_COMM_SDKAPPID_FORBIDDEN:
                return getLocalizedString(R.string.TUIKitErrorSVRCommonSDkappidForbidden);
            case BaseConstants.ERR_SVR_COMM_REQ_FORBIDDEN:
                return getLocalizedString(R.string.TUIKitErrorSVRCommonReqForbidden);
            case BaseConstants.ERR_SVR_COMM_REQ_FREQ_LIMIT:
                return getLocalizedString(R.string.TUIKitErrorSVRCommonReqFreqLimit);
            case BaseConstants.ERR_SVR_COMM_REQ_FREQ_LIMIT_EX:
                return getLocalizedString(R.string.TUIKitErrorSVRCommonReqFreqLimit);
            case BaseConstants.ERR_SVR_COMM_INVALID_SERVICE:
                return getLocalizedString(R.string.TUIKitErrorSVRCommonInvalidService);
            case BaseConstants.ERR_SVR_COMM_SENSITIVE_TEXT:
                return getLocalizedString(R.string.TUIKitErrorSVRCommonSensitiveText);
            case BaseConstants.ERR_SVR_COMM_BODY_SIZE_LIMIT:
                return getLocalizedString(R.string.TUIKitErrorSVRCommonBodySizeLimit);

            // 帐号错误码
            // Account error codes
            case BaseConstants.ERR_SVR_ACCOUNT_USERSIG_EXPIRED:
                return getLocalizedString(R.string.TUIKitErrorSVRAccountUserSigExpired);
            case BaseConstants.ERR_SVR_ACCOUNT_USERSIG_EMPTY:
                return getLocalizedString(R.string.TUIKitErrorSVRAccountUserSigEmpty);
            case BaseConstants.ERR_SVR_ACCOUNT_USERSIG_CHECK_FAILED:
                return getLocalizedString(R.string.TUIKitErrorSVRAccountUserSigCheckFailed);
            case BaseConstants.ERR_SVR_ACCOUNT_USERSIG_CHECK_FAILED_EX:
                return getLocalizedString(R.string.TUIKitErrorSVRAccountUserSigCheckFailed);
            case BaseConstants.ERR_SVR_ACCOUNT_USERSIG_MISMATCH_PUBLICKEY:
                return getLocalizedString(R.string.TUIKitErrorSVRAccountUserSigMismatchPublicKey);
            case BaseConstants.ERR_SVR_ACCOUNT_USERSIG_MISMATCH_ID:
                return getLocalizedString(R.string.TUIKitErrorSVRAccountUserSigMismatchId);
            case BaseConstants.ERR_SVR_ACCOUNT_USERSIG_MISMATCH_SDKAPPID:
                return getLocalizedString(R.string.TUIKitErrorSVRAccountUserSigMismatchSdkAppid);
            case BaseConstants.ERR_SVR_ACCOUNT_USERSIG_PUBLICKEY_NOT_FOUND:
                return getLocalizedString(R.string.TUIKitErrorSVRAccountUserSigPublicKeyNotFound);
            case BaseConstants.ERR_SVR_ACCOUNT_SDKAPPID_NOT_FOUND:
                return getLocalizedString(R.string.TUIKitErrorSVRAccountUserSigSdkAppidNotFount);
            case BaseConstants.ERR_SVR_ACCOUNT_INVALID_USERSIG:
                return getLocalizedString(R.string.TUIKitErrorSVRAccountInvalidUserSig);
            case BaseConstants.ERR_SVR_ACCOUNT_NOT_FOUND:
                return getLocalizedString(R.string.TUIKitErrorSVRAccountNotFound);
            case BaseConstants.ERR_SVR_ACCOUNT_SEC_RSTR:
                return getLocalizedString(R.string.TUIKitErrorSVRAccountSecRstr);
            case BaseConstants.ERR_SVR_ACCOUNT_INTERNAL_TIMEOUT:
                return getLocalizedString(R.string.TUIKitErrorSVRAccountInternalTimeout);
            case BaseConstants.ERR_SVR_ACCOUNT_INVALID_COUNT:
                return getLocalizedString(R.string.TUIKitErrorSVRAccountInvalidCount);
            case BaseConstants.ERR_SVR_ACCOUNT_INVALID_PARAMETERS:
                return getLocalizedString(R.string.TUIkitErrorSVRAccountINvalidParameters);
            case BaseConstants.ERR_SVR_ACCOUNT_ADMIN_REQUIRED:
                return getLocalizedString(R.string.TUIKitErrorSVRAccountAdminRequired);
            case BaseConstants.ERR_SVR_ACCOUNT_FREQ_LIMIT:
                return getLocalizedString(R.string.TUIKitErrorSVRAccountFreqLimit);
            case BaseConstants.ERR_SVR_ACCOUNT_BLACKLIST:
                return getLocalizedString(R.string.TUIKitErrorSVRAccountBlackList);
            case BaseConstants.ERR_SVR_ACCOUNT_COUNT_LIMIT:
                return getLocalizedString(R.string.TUIKitErrorSVRAccountCountLimit);
            case BaseConstants.ERR_SVR_ACCOUNT_INTERNAL_ERROR:
                return getLocalizedString(R.string.TUIKitErrorSVRAccountInternalError);
            case BaseConstants.ERR_SVR_ACCOUNT_USER_STATUS_DISABLED:
                return getLocalizedString(R.string.TUIKitErrorEnableUserStatusOnConsole);

            // 资料错误码
            // Profile error codes
            case BaseConstants.ERR_SVR_PROFILE_INVALID_PARAMETERS:
                return getLocalizedString(R.string.TUIKitErrorSVRProfileInvalidParameters);
            case BaseConstants.ERR_SVR_PROFILE_ACCOUNT_MISS:
                return getLocalizedString(R.string.TUIKitErrorSVRProfileAccountMiss);
            case BaseConstants.ERR_SVR_PROFILE_ACCOUNT_NOT_FOUND:
                return getLocalizedString(R.string.TUIKitErrorSVRProfileAccountNotFound);
            case BaseConstants.ERR_SVR_PROFILE_ADMIN_REQUIRED:
                return getLocalizedString(R.string.TUIKitErrorSVRProfileAdminRequired);
            case BaseConstants.ERR_SVR_PROFILE_SENSITIVE_TEXT:
                return getLocalizedString(R.string.TUIKitErrorSVRProfileSensitiveText);
            case BaseConstants.ERR_SVR_PROFILE_INTERNAL_ERROR:
                return getLocalizedString(R.string.TUIKitErrorSVRProfileInternalError);
            case BaseConstants.ERR_SVR_PROFILE_READ_PERMISSION_REQUIRED:
                return getLocalizedString(R.string.TUIKitErrorSVRProfileReadWritePermissionRequired);
            case BaseConstants.ERR_SVR_PROFILE_WRITE_PERMISSION_REQUIRED:
                return getLocalizedString(R.string.TUIKitErrorSVRProfileReadWritePermissionRequired);
            case BaseConstants.ERR_SVR_PROFILE_TAG_NOT_FOUND:
                return getLocalizedString(R.string.TUIKitErrorSVRProfileTagNotFound);
            case BaseConstants.ERR_SVR_PROFILE_SIZE_LIMIT:
                return getLocalizedString(R.string.TUIKitErrorSVRProfileSizeLimit);
            case BaseConstants.ERR_SVR_PROFILE_VALUE_ERROR:
                return getLocalizedString(R.string.TUIKitErrorSVRProfileValueError);
            case BaseConstants.ERR_SVR_PROFILE_INVALID_VALUE_FORMAT:
                return getLocalizedString(R.string.TUIKitErrorSVRProfileInvalidValueFormat);

            // 关系链错误码
            // Relationship chain error codes
            case BaseConstants.ERR_SVR_FRIENDSHIP_INVALID_PARAMETERS:
                return getLocalizedString(R.string.TUIKitErrorSVRFriendshipInvalidParameters);
            case BaseConstants.ERR_SVR_FRIENDSHIP_INVALID_SDKAPPID:
                return getLocalizedString(R.string.TUIKitErrorSVRFriendshipInvalidSdkAppid);
            case BaseConstants.ERR_SVR_FRIENDSHIP_ACCOUNT_NOT_FOUND:
                return getLocalizedString(R.string.TUIKitErrorSVRFriendshipAccountNotFound);
            case BaseConstants.ERR_SVR_FRIENDSHIP_ADMIN_REQUIRED:
                return getLocalizedString(R.string.TUIKitErrorSVRFriendshipAdminRequired);
            case BaseConstants.ERR_SVR_FRIENDSHIP_SENSITIVE_TEXT:
                return getLocalizedString(R.string.TUIKitErrorSVRFriendshipSensitiveText);
            case BaseConstants.ERR_SVR_FRIENDSHIP_INTERNAL_ERROR:
                return getLocalizedString(R.string.TUIKitErrorSVRAccountInternalError);
            case BaseConstants.ERR_SVR_FRIENDSHIP_NET_TIMEOUT:
                return getLocalizedString(R.string.TUIKitErrorSVRFriendshipNetTimeout);
            case BaseConstants.ERR_SVR_FRIENDSHIP_WRITE_CONFLICT:
                return getLocalizedString(R.string.TUIKitErrorSVRFriendshipWriteConflict);
            case BaseConstants.ERR_SVR_FRIENDSHIP_ADD_FRIEND_DENY:
                return getLocalizedString(R.string.TUIKitErrorSVRFriendshipAddFriendDeny);
            case BaseConstants.ERR_SVR_FRIENDSHIP_COUNT_LIMIT:
                return getLocalizedString(R.string.TUIkitErrorSVRFriendshipCountLimit);
            case BaseConstants.ERR_SVR_FRIENDSHIP_GROUP_COUNT_LIMIT:
                return getLocalizedString(R.string.TUIKitErrorSVRFriendshipGroupCountLimit);
            case BaseConstants.ERR_SVR_FRIENDSHIP_PENDENCY_LIMIT:
                return getLocalizedString(R.string.TUIKitErrorSVRFriendshipPendencyLimit);
            case BaseConstants.ERR_SVR_FRIENDSHIP_BLACKLIST_LIMIT:
                return getLocalizedString(R.string.TUIKitErrorSVRFriendshipBlacklistLimit);
            case BaseConstants.ERR_SVR_FRIENDSHIP_PEER_FRIEND_LIMIT:
                return getLocalizedString(R.string.TUIKitErrorSVRFriendshipPeerFriendLimit);
            case BaseConstants.ERR_SVR_FRIENDSHIP_IN_SELF_BLACKLIST:
                return getLocalizedString(R.string.TUIKitErrorSVRFriendshipInSelfBlacklist);
            case BaseConstants.ERR_SVR_FRIENDSHIP_ALLOW_TYPE_DENY_ANY:
                return getLocalizedString(R.string.TUIKitErrorSVRFriendshipAllowTypeDenyAny);
            case BaseConstants.ERR_SVR_FRIENDSHIP_IN_PEER_BLACKLIST:
                return getLocalizedString(R.string.TUIKitErrorSVRFriendshipInPeerBlackList);
            case BaseConstants.ERR_SVR_FRIENDSHIP_ALLOW_TYPE_NEED_CONFIRM:
                return getLocalizedString(R.string.TUIKitErrorSVRFriendshipAllowTypeNeedConfirm);
            case BaseConstants.ERR_SVR_FRIENDSHIP_ADD_FRIEND_SEC_RSTR:
                return getLocalizedString(R.string.TUIKitErrorSVRFriendshipAddFriendSecRstr);
            case BaseConstants.ERR_SVR_FRIENDSHIP_PENDENCY_NOT_FOUND:
                return getLocalizedString(R.string.TUIKitErrorSVRFriendshipPendencyNotFound);
            case BaseConstants.ERR_SVR_FRIENDSHIP_DEL_FRIEND_SEC_RSTR:
                return getLocalizedString(R.string.TUIKitErrorSVRFriendshipDelFriendSecRstr);
            case BaseConstants.ERR_SVR_FRIENDSHIP_ACCOUNT_NOT_FOUND_EX:
                return getLocalizedString(R.string.TUIKirErrorSVRFriendAccountNotFoundEx);

            // 最近联系人错误码
            // Error codes for recent contacts
            case BaseConstants.ERR_SVR_CONV_ACCOUNT_NOT_FOUND:
                return getLocalizedString(R.string.TUIKirErrorSVRFriendAccountNotFoundEx);
            case BaseConstants.ERR_SVR_CONV_INVALID_PARAMETERS:
                return getLocalizedString(R.string.TUIKitErrorSVRFriendshipInvalidParameters);
            case BaseConstants.ERR_SVR_CONV_ADMIN_REQUIRED:
                return getLocalizedString(R.string.TUIKitErrorSVRFriendshipAdminRequired);
            case BaseConstants.ERR_SVR_CONV_INTERNAL_ERROR:
                return getLocalizedString(R.string.TUIKitErrorSVRAccountInternalError);
            case BaseConstants.ERR_SVR_CONV_NET_TIMEOUT:
                return getLocalizedString(R.string.TUIKitErrorSVRFriendshipNetTimeout);

            // 消息错误码
            // Message error codes
            case BaseConstants.ERR_SVR_MSG_PKG_PARSE_FAILED:
                return getLocalizedString(R.string.TUIKitErrorSVRMsgPkgParseFailed);
            case BaseConstants.ERR_SVR_MSG_INTERNAL_AUTH_FAILED:
                return getLocalizedString(R.string.TUIKitErrorSVRMsgInternalAuthFailed);
            case BaseConstants.ERR_SVR_MSG_INVALID_ID:
                return getLocalizedString(R.string.TUIKitErrorSVRMsgInvalidId);
            case BaseConstants.ERR_SVR_MSG_NET_ERROR:
                return getLocalizedString(R.string.TUIKitErrorSVRMsgNetError);
            case BaseConstants.ERR_SVR_MSG_INTERNAL_ERROR1:
                return getLocalizedString(R.string.TUIKitErrorSVRAccountInternalError);
            case BaseConstants.ERR_SVR_MSG_PUSH_DENY:
                return getLocalizedString(R.string.TUIKitErrorSVRMsgPushDeny);
            case BaseConstants.ERR_SVR_MSG_IN_PEER_BLACKLIST:
                return getLocalizedString(R.string.TUIKitErrorSVRMsgInPeerBlackList);
            case BaseConstants.ERR_SVR_MSG_BOTH_NOT_FRIEND:
                return getLocalizedString(R.string.TUIKitErrorSVRMsgBothNotFriend);
            case BaseConstants.ERR_SVR_MSG_NOT_PEER_FRIEND:
                return getLocalizedString(R.string.TUIKitErrorSVRMsgNotPeerFriend);
            case BaseConstants.ERR_SVR_MSG_NOT_SELF_FRIEND:
                return getLocalizedString(R.string.TUIkitErrorSVRMsgNotSelfFriend);
            case BaseConstants.ERR_SVR_MSG_SHUTUP_DENY:
                return getLocalizedString(R.string.TUIKitErrorSVRMsgShutupDeny);
            case BaseConstants.ERR_SVR_MSG_REVOKE_TIME_LIMIT:
                return getLocalizedString(R.string.TUIKitErrorSVRMsgRevokeTimeLimit);
            case BaseConstants.ERR_SVR_MSG_DEL_RAMBLE_INTERNAL_ERROR:
                return getLocalizedString(R.string.TUIKitErrorSVRMsgDelRambleInternalError);
            case BaseConstants.ERR_SVR_MSG_JSON_PARSE_FAILED:
                return getLocalizedString(R.string.TUIKitErrorSVRMsgJsonParseFailed);
            case BaseConstants.ERR_SVR_MSG_INVALID_JSON_BODY_FORMAT:
                return getLocalizedString(R.string.TUIKitErrorSVRMsgInvalidJsonBodyFormat);
            case BaseConstants.ERR_SVR_MSG_INVALID_TO_ACCOUNT:
                return getLocalizedString(R.string.TUIKitErrorSVRMsgInvalidToAccount);
            case BaseConstants.ERR_SVR_MSG_INVALID_RAND:
                return getLocalizedString(R.string.TUIKitErrorSVRMsgInvalidRand);
            case BaseConstants.ERR_SVR_MSG_INVALID_TIMESTAMP:
                return getLocalizedString(R.string.TUIKitErrorSVRMsgInvalidTimestamp);
            case BaseConstants.ERR_SVR_MSG_BODY_NOT_ARRAY:
                return getLocalizedString(R.string.TUIKitErrorSVRMsgBodyNotArray);
            case BaseConstants.ERR_SVR_MSG_ADMIN_REQUIRED:
                return getLocalizedString(R.string.TUIKitErrorSVRAccountAdminRequired);
            case BaseConstants.ERR_SVR_MSG_INVALID_JSON_FORMAT:
                return getLocalizedString(R.string.TUIKitErrorSVRMsgInvalidJsonFormat);
            case BaseConstants.ERR_SVR_MSG_TO_ACCOUNT_COUNT_LIMIT:
                return getLocalizedString(R.string.TUIKitErrorSVRMsgToAccountCountLimit);
            case BaseConstants.ERR_SVR_MSG_TO_ACCOUNT_NOT_FOUND:
                return getLocalizedString(R.string.TUIKitErrorSVRMsgToAccountNotFound);
            case BaseConstants.ERR_SVR_MSG_TIME_LIMIT:
                return getLocalizedString(R.string.TUIKitErrorSVRMsgTimeLimit);
            case BaseConstants.ERR_SVR_MSG_INVALID_SYNCOTHERMACHINE:
                return getLocalizedString(R.string.TUIKitErrorSVRMsgInvalidSyncOtherMachine);
            case BaseConstants.ERR_SVR_MSG_INVALID_MSGLIFETIME:
                return getLocalizedString(R.string.TUIkitErrorSVRMsgInvalidMsgLifeTime);
            case BaseConstants.ERR_SVR_MSG_ACCOUNT_NOT_FOUND:
                return getLocalizedString(R.string.TUIKirErrorSVRFriendAccountNotFoundEx);
            case BaseConstants.ERR_SVR_MSG_INTERNAL_ERROR2:
                return getLocalizedString(R.string.TUIKitErrorSVRAccountInternalError);
            case BaseConstants.ERR_SVR_MSG_INTERNAL_ERROR3:
                return getLocalizedString(R.string.TUIKitErrorSVRAccountInternalError);
            case BaseConstants.ERR_SVR_MSG_INTERNAL_ERROR4:
                return getLocalizedString(R.string.TUIKitErrorSVRAccountInternalError);
            case BaseConstants.ERR_SVR_MSG_INTERNAL_ERROR5:
                return getLocalizedString(R.string.TUIKitErrorSVRAccountInternalError);
            case BaseConstants.ERR_SVR_MSG_BODY_SIZE_LIMIT:
                return getLocalizedString(R.string.TUIKitErrorSVRMsgBodySizeLimit);
            case BaseConstants.ERR_SVR_MSG_LONGPOLLING_COUNT_LIMIT:
                return getLocalizedString(R.string.TUIKitErrorSVRmsgLongPollingCountLimit);
            case BaseConstants.ERR_SDK_INTERFACE_NOT_SUPPORT:
                return getLocalizedString(R.string.TUIKitErrorUnsupporInterface);

            // 群组错误码
            // Group error codes
            case BaseConstants.ERR_SVR_GROUP_INTERNAL_ERROR:
                return getLocalizedString(R.string.TUIKitErrorSVRAccountInternalError);
            case BaseConstants.ERR_SVR_GROUP_API_NAME_ERROR:
                return getLocalizedString(R.string.TUIKitErrorSVRGroupApiNameError);
            case BaseConstants.ERR_SVR_GROUP_INVALID_PARAMETERS:
                return getLocalizedString(R.string.TUIKitErrorSVRResInvalidParameters);
            case BaseConstants.ERR_SVR_GROUP_ACOUNT_COUNT_LIMIT:
                return getLocalizedString(R.string.TUIKitErrorSVRGroupAccountCountLimit);
            case BaseConstants.ERR_SVR_GROUP_FREQ_LIMIT:
                return getLocalizedString(R.string.TUIkitErrorSVRGroupFreqLimit);
            case BaseConstants.ERR_SVR_GROUP_PERMISSION_DENY:
                return getLocalizedString(R.string.TUIKitErrorSVRGroupPermissionDeny);
            case BaseConstants.ERR_SVR_GROUP_INVALID_REQ:
                return getLocalizedString(R.string.TUIKitErrorSVRGroupInvalidReq);
            case BaseConstants.ERR_SVR_GROUP_SUPER_NOT_ALLOW_QUIT:
                return getLocalizedString(R.string.TUIKitErrorSVRGroupSuperNotAllowQuit);
            case BaseConstants.ERR_SVR_GROUP_NOT_FOUND:
                return getLocalizedString(R.string.TUIKitErrorSVRGroupNotFound);
            case BaseConstants.ERR_SVR_GROUP_JSON_PARSE_FAILED:
                return getLocalizedString(R.string.TUIKitErrorSVRGroupJsonParseFailed);
            case BaseConstants.ERR_SVR_GROUP_INVALID_ID:
                return getLocalizedString(R.string.TUIKitErrorSVRGroupInvalidId);
            case BaseConstants.ERR_SVR_GROUP_ALLREADY_MEMBER:
                return getLocalizedString(R.string.TUIKitErrorSVRGroupAllreadyMember);
            case BaseConstants.ERR_SVR_GROUP_FULL_MEMBER_COUNT:
                return getLocalizedString(R.string.TUIKitErrorSVRGroupFullMemberCount);
            case BaseConstants.ERR_SVR_GROUP_INVALID_GROUPID:
                return getLocalizedString(R.string.TUIKitErrorSVRGroupInvalidGroupId);
            case BaseConstants.ERR_SVR_GROUP_REJECT_FROM_THIRDPARTY:
                return getLocalizedString(R.string.TUIKitErrorSVRGroupRejectFromThirdParty);
            case BaseConstants.ERR_SVR_GROUP_SHUTUP_DENY:
                return getLocalizedString(R.string.TUIKitErrorSVRGroupShutDeny);
            case BaseConstants.ERR_SVR_GROUP_RSP_SIZE_LIMIT:
                return getLocalizedString(R.string.TUIKitErrorSVRGroupRspSizeLimit);
            case BaseConstants.ERR_SVR_GROUP_ACCOUNT_NOT_FOUND:
                return getLocalizedString(R.string.TUIKitErrorSVRGroupAccountNotFound);
            case BaseConstants.ERR_SVR_GROUP_GROUPID_IN_USED:
                return getLocalizedString(R.string.TUIKitErrorSVRGroupGroupIdInUse);
            case BaseConstants.ERR_SVR_GROUP_SEND_MSG_FREQ_LIMIT:
                return getLocalizedString(R.string.TUIKitErrorSVRGroupSendMsgFreqLimit);
            case BaseConstants.ERR_SVR_GROUP_REQ_ALLREADY_BEEN_PROCESSED:
                return getLocalizedString(R.string.TUIKitErrorSVRGroupReqAllreadyBeenProcessed);
            case BaseConstants.ERR_SVR_GROUP_GROUPID_IN_USED_FOR_SUPER:
                return getLocalizedString(R.string.TUIKitErrorSVRGroupGroupIdUserdForSuper);
            case BaseConstants.ERR_SVR_GROUP_SDKAPPID_DENY:
                return getLocalizedString(R.string.TUIKitErrorSVRGroupSDkAppidDeny);
            case BaseConstants.ERR_SVR_GROUP_REVOKE_MSG_NOT_FOUND:
                return getLocalizedString(R.string.TUIKitErrorSVRGroupRevokeMsgNotFound);
            case BaseConstants.ERR_SVR_GROUP_REVOKE_MSG_TIME_LIMIT:
                return getLocalizedString(R.string.TUIKitErrorSVRGroupRevokeMsgTimeLimit);
            case BaseConstants.ERR_SVR_GROUP_REVOKE_MSG_DENY:
                return getLocalizedString(R.string.TUIKitErrorSVRGroupRevokeMsgDeny);
            case BaseConstants.ERR_SVR_GROUP_NOT_ALLOW_REVOKE_MSG:
                return getLocalizedString(R.string.TUIKitErrorSVRGroupNotAllowRevokeMsg);
            case BaseConstants.ERR_SVR_GROUP_REMOVE_MSG_DENY:
                return getLocalizedString(R.string.TUIKitErrorSVRGroupRemoveMsgDeny);
            case BaseConstants.ERR_SVR_GROUP_NOT_ALLOW_REMOVE_MSG:
                return getLocalizedString(R.string.TUIKitErrorSVRGroupNotAllowRemoveMsg);
            case BaseConstants.ERR_SVR_GROUP_AVCHATROOM_COUNT_LIMIT:
                return getLocalizedString(R.string.TUIKitErrorSVRGroupAvchatRoomCountLimit);
            case BaseConstants.ERR_SVR_GROUP_COUNT_LIMIT:
                return getLocalizedString(R.string.TUIKitErrorSVRGroupCountLimit);
            case BaseConstants.ERR_SVR_GROUP_MEMBER_COUNT_LIMIT:
                return getLocalizedString(R.string.TUIKitErrorSVRGroupMemberCountLimit);

            /////////////////////////////////////////////////////////////////////////////////
            //
            //                      （三）V3版本错误码，待废弃
            //                           IM SDK V3 error codes,to be abandoned
            //
            /////////////////////////////////////////////////////////////////////////////////

            case BaseConstants.ERR_NO_SUCC_RESULT:
                return getLocalizedString(R.string.TUIKitErrorSVRNoSuccessResult);
            case BaseConstants.ERR_TO_USER_INVALID:
                return getLocalizedString(R.string.TUIKitErrorSVRToUserInvalid);
            case BaseConstants.ERR_INIT_CORE_FAIL:
                return getLocalizedString(R.string.TUIKitErrorSVRInitCoreFail);
            case BaseConstants.ERR_EXPIRED_SESSION_NODE:
                return getLocalizedString(R.string.TUIKitErrorExpiredSessionNode);
            case BaseConstants.ERR_LOGGED_OUT_BEFORE_LOGIN_FINISHED:
                return getLocalizedString(R.string.TUIKitErrorLoggedOutBeforeLoginFinished);
            case BaseConstants.ERR_TLSSDK_NOT_INITIALIZED:
                return getLocalizedString(R.string.TUIKitErrorTLSSDKNotInitialized);
            case BaseConstants.ERR_TLSSDK_USER_NOT_FOUND:
                return getLocalizedString(R.string.TUIKitErrorTLSSDKUserNotFound);
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
                return getLocalizedString(R.string.TUIKitErrorBindFaildRegTimeout);
            case BaseConstants.ERR_BIND_FAIL_ISBINDING:
                return getLocalizedString(R.string.TUIKitErrorBindFaildIsBinding);
            case BaseConstants.ERR_PACKET_FAIL_UNKNOWN:
                return getLocalizedString(R.string.TUIKitErrorPacketFailUnknown);
            case BaseConstants.ERR_PACKET_FAIL_REQ_NO_NET:
                return getLocalizedString(R.string.TUIKitErrorPacketFailReqNoNet);
            case BaseConstants.ERR_PACKET_FAIL_RESP_NO_NET:
                return getLocalizedString(R.string.TUIKitErrorPacketFailRespNoNet);
            case BaseConstants.ERR_PACKET_FAIL_REQ_NO_AUTH:
                return getLocalizedString(R.string.TUIKitErrorPacketFailReqNoAuth);
            case BaseConstants.ERR_PACKET_FAIL_SSO_ERR:
                return getLocalizedString(R.string.TUIKitErrorPacketFailSSOErr);
            case BaseConstants.ERR_PACKET_FAIL_REQ_TIMEOUT:
                return getLocalizedString(R.string.TUIKitErrorSVRRequestTimeout);
            case BaseConstants.ERR_PACKET_FAIL_RESP_TIMEOUT:
                return getLocalizedString(R.string.TUIKitErrorPacketFailRespTimeout);

            // case BaseConstants.ERR_PACKET_FAIL_REQ_ON_RESEND:
            // case BaseConstants.ERR_PACKET_FAIL_RESP_NO_RESEND:
            // case BaseConstants.ERR_PACKET_FAIL_FLOW_SAVE_FILTERED:
            // case BaseConstants.ERR_PACKET_FAIL_REQ_OVER_LOAD:
            // case BaseConstants.ERR_PACKET_FAIL_LOGIC_ERR:
            case BaseConstants.ERR_FRIENDSHIP_PROXY_NOT_SYNCED:
                return getLocalizedString(R.string.TUIKitErrorFriendshipProxySyncing);
            case BaseConstants.ERR_FRIENDSHIP_PROXY_SYNCING:
                return getLocalizedString(R.string.TUIKitErrorFriendshipProxySyncing);
            case BaseConstants.ERR_FRIENDSHIP_PROXY_SYNCED_FAIL:
                return getLocalizedString(R.string.TUIKitErrorFriendshipProxySyncedFail);
            case BaseConstants.ERR_FRIENDSHIP_PROXY_LOCAL_CHECK_ERR:
                return getLocalizedString(R.string.TUIKitErrorFriendshipProxyLocalCheckErr);
            case BaseConstants.ERR_GROUP_INVALID_FIELD:
                return getLocalizedString(R.string.TUIKitErrorGroupInvalidField);
            case BaseConstants.ERR_GROUP_STORAGE_DISABLED:
                return getLocalizedString(R.string.TUIKitErrorGroupStoreageDisabled);
            case BaseConstants.ERR_LOADGRPINFO_FAILED:
                return getLocalizedString(R.string.TUIKitErrorLoadGrpInfoFailed);
            case BaseConstants.ERR_REQ_NO_NET_ON_REQ:
                return getLocalizedString(R.string.TUIKitErrorReqNoNetOnReq);
            case BaseConstants.ERR_REQ_NO_NET_ON_RSP:
                return getLocalizedString(R.string.TUIKitErrorReqNoNetOnResp);
            case BaseConstants.ERR_SERIVCE_NOT_READY:
                return getLocalizedString(R.string.TUIKitErrorServiceNotReady);
            case BaseConstants.ERR_LOGIN_AUTH_FAILED:
                return getLocalizedString(R.string.TUIKitErrorLoginAuthFailed);
            case BaseConstants.ERR_NEVER_CONNECT_AFTER_LAUNCH:
                return getLocalizedString(R.string.TUIKitErrorNeverConnectAfterLaunch);
            case BaseConstants.ERR_REQ_FAILED:
                return getLocalizedString(R.string.TUIKitErrorReqFailed);
            case BaseConstants.ERR_REQ_INVALID_REQ:
                return getLocalizedString(R.string.TUIKitErrorReqInvaidReq);
            case BaseConstants.ERR_REQ_OVERLOADED:
                return getLocalizedString(R.string.TUIKitErrorReqOnverLoaded);
            case BaseConstants.ERR_REQ_KICK_OFF:
                return getLocalizedString(R.string.TUIKitErrorReqKickOff);
            case BaseConstants.ERR_REQ_SERVICE_SUSPEND:
                return getLocalizedString(R.string.TUIKitErrorReqServiceSuspend);
            case BaseConstants.ERR_REQ_INVALID_SIGN:
                return getLocalizedString(R.string.TUIKitErrorReqInvalidSign);
            case BaseConstants.ERR_REQ_INVALID_COOKIE:
                return getLocalizedString(R.string.TUIKitErrorReqInvalidCookie);
            case BaseConstants.ERR_LOGIN_TLS_RSP_PARSE_FAILED:
                return getLocalizedString(R.string.TUIKitErrorLoginTlsRspParseFailed);
            case BaseConstants.ERR_LOGIN_OPENMSG_TIMEOUT:
                return getLocalizedString(R.string.TUIKitErrorLoginOpenMsgTimeout);
            case BaseConstants.ERR_LOGIN_OPENMSG_RSP_PARSE_FAILED:
                return getLocalizedString(R.string.TUIKitErrorLoginOpenMsgRspParseFailed);
            case BaseConstants.ERR_LOGIN_TLS_DECRYPT_FAILED:
                return getLocalizedString(R.string.TUIKitErrorLoginTslDecryptFailed);
            case BaseConstants.ERR_WIFI_NEED_AUTH:
                return getLocalizedString(R.string.TUIKitErrorWifiNeedAuth);
            case BaseConstants.ERR_USER_CANCELED:
                return getLocalizedString(R.string.TUIKitErrorUserCanceled);
            case BaseConstants.ERR_REVOKE_TIME_LIMIT_EXCEED:
                return getLocalizedString(R.string.TUIkitErrorRevokeTimeLimitExceed);
            case BaseConstants.ERR_LACK_UGC_EXT:
                return getLocalizedString(R.string.TUIKitErrorLackUGExt);
            case BaseConstants.ERR_AUTOLOGIN_NEED_USERSIG:
                return getLocalizedString(R.string.TUIKitErrorAutoLoginNeedUserSig);
            case BaseConstants.ERR_QAL_NO_SHORT_CONN_AVAILABLE:
                return getLocalizedString(R.string.TUIKitErrorQALNoShortConneAvailable);
            case BaseConstants.ERR_REQ_CONTENT_ATTACK:
                return getLocalizedString(R.string.TUIKitErrorReqContentAttach);
            case BaseConstants.ERR_LOGIN_SIG_EXPIRE:
                return getLocalizedString(R.string.TUIKitErrorLoginSigExpire);
            case BaseConstants.ERR_SDK_HAD_INITIALIZED:
                return getLocalizedString(R.string.TUIKitErrorSDKHadInit);
            case BaseConstants.ERR_OPENBDH_BASE:
                return getLocalizedString(R.string.TUIKitErrorOpenBDHBase);
            case BaseConstants.ERR_REQUEST_NO_NET_ONREQ:
                return getLocalizedString(R.string.TUIKitErrorRequestNoNetOnReq);
            case BaseConstants.ERR_REQUEST_NO_NET_ONRSP:
                return getLocalizedString(R.string.TUIKitErrorRequestNoNetOnRsp);
//        case BaseConstants.ERR_REQUEST_FAILED:
//            return @"QAL执行失败";
//        case BaseConstants.ERR_REQUEST_INVALID_REQ:
//            return @"请求非法，toMsgService非法";
            case BaseConstants.ERR_REQUEST_OVERLOADED:
                return getLocalizedString(R.string.TUIKitErrorRequestOnverLoaded);
            case BaseConstants.ERR_REQUEST_KICK_OFF:
                return getLocalizedString(R.string.TUIKitErrorReqKickOff);
            case BaseConstants.ERR_REQUEST_SERVICE_SUSPEND:
                return getLocalizedString(R.string.TUIKitErrorReqServiceSuspend);
            case BaseConstants.ERR_REQUEST_INVALID_SIGN:
                return getLocalizedString(R.string.TUIKitErrorReqInvalidSign);
            case BaseConstants.ERR_REQUEST_INVALID_COOKIE:
                return getLocalizedString(R.string.TUIKitErrorReqInvalidCookie);

            default:
                break;
        }
        return msg;
    }

    private static String getLocalizedString(int errStringId) {
        return TUIConfig.getAppContext().getString(errStringId);
    }
}
