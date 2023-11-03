//
//  THelper.m
//  TUIKit
//
//  Created by kennethmiao on 2018/11/1.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <SDWebImage/SDImageCoderHelper.h>
#import "TUILogin.h"
#import "TUIGlobalization.h"
#import "TUIWeakProxy.h"
#import "TUIDefine.h"
#import "UIView+TUIToast.h"

@import ImSDK_Plus;

@implementation TUITool

static NSMutableDictionary * gIMErrorMsgMap = nil;

+ (void)initialize {
    [self setupIMErrorMap];
}
+ (void)configIMErrorMap {
    [self.class setupIMErrorMap];
}
+ (void)setupIMErrorMap {
    NSMutableDictionary *map = [NSMutableDictionary dictionary];
    gIMErrorMsgMap = map;
    
    /////////////////////////////////////////////////////////////////////////////////
    //
    //                      （一）IM SDK 的错误码
    //
    /////////////////////////////////////////////////////////////////////////////////

    // 通用错误码
    [map setObject:TUIKitLocalizableString(TUIKitErrorInProcess) forKey:@(ERR_IN_PROGESS)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorInvalidParameters) forKey:@(ERR_INVALID_PARAMETERS)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorIOOperateFaild) forKey:@(ERR_IO_OPERATION_FAILED)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorInvalidJson) forKey:@(ERR_INVALID_JSON)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorOutOfMemory) forKey:@(ERR_OUT_OF_MEMORY)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorParseResponseFaild) forKey:@(ERR_PARSE_RESPONSE_FAILED)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSerializeReqFaild) forKey:@(ERR_SERIALIZE_REQ_FAILED)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSDKNotInit) forKey:@(ERR_SDK_NOT_INITIALIZED)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorLoadMsgFailed) forKey:@(ERR_LOADMSG_FAILED)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorDatabaseOperateFailed) forKey:@(ERR_DATABASE_OPERATE_FAILED)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorCrossThread) forKey:@(ERR_SDK_COMM_CROSS_THREAD)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorTinyIdEmpty) forKey:@(ERR_SDK_COMM_TINYID_EMPTY)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorInvalidIdentifier) forKey:@(ERR_SDK_COMM_INVALID_IDENTIFIER)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorFileNotFound) forKey:@(ERR_SDK_COMM_FILE_NOT_FOUND)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorFileTooLarge) forKey:@(ERR_SDK_COMM_FILE_TOO_LARGE)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorEmptyFile) forKey:@(ERR_SDK_COMM_FILE_SIZE_EMPTY)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorFileOpenFailed) forKey:@(ERR_SDK_COMM_FILE_OPEN_FAILED)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorUnsupporInterface) forKey:@(ERR_SDK_INTERFACE_NOT_SUPPORT)];
    
    // Account
    [map setObject:TUIKitLocalizableString(TUIKitErrorNotLogin) forKey:@(ERR_SDK_NOT_LOGGED_IN)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorNoPreviousLogin) forKey:@(ERR_NO_PREVIOUS_LOGIN)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorUserSigExpired) forKey:@(ERR_USER_SIG_EXPIRED)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorLoginKickedOffByOther) forKey:@(ERR_LOGIN_KICKED_OFF_BY_OTHER)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorTLSSDKInit) forKey:@(ERR_SDK_ACCOUNT_TLS_INIT_FAILED)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorTLSSDKUninit) forKey:@(ERR_SDK_ACCOUNT_TLS_NOT_INITIALIZED)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorTLSSDKTRANSPackageFormat) forKey:@(ERR_SDK_ACCOUNT_TLS_TRANSPKG_ERROR)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorTLSDecrypt) forKey:@(ERR_SDK_ACCOUNT_TLS_DECRYPT_FAILED)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorTLSSDKRequest) forKey:@(ERR_SDK_ACCOUNT_TLS_REQUEST_FAILED)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorTLSSDKRequestTimeout) forKey:@(ERR_SDK_ACCOUNT_TLS_REQUEST_TIMEOUT)];
    
    // Message
    [map setObject:TUIKitLocalizableString(TUIKitErrorInvalidConveration) forKey:@(ERR_INVALID_CONVERSATION)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorFileTransAuthFailed) forKey:@(ERR_FILE_TRANS_AUTH_FAILED)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorFileTransNoServer) forKey:@(ERR_FILE_TRANS_NO_SERVER)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorFileTransUploadFailed) forKey:@(ERR_FILE_TRANS_UPLOAD_FAILED)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorFileTransUploadFailedNotImage) forKey:@(ERR_IMAGE_UPLOAD_FAILED_NOTIMAGE)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorFileTransDownloadFailed) forKey:@(ERR_FILE_TRANS_DOWNLOAD_FAILED)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorHTTPRequestFailed) forKey:@(ERR_HTTP_REQ_FAILED)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorInvalidMsgElem) forKey:@(ERR_INVALID_MSG_ELEM)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorInvalidSDKObject) forKey:@(ERR_INVALID_SDK_OBJECT)];
    [map setObject:TUIKitLocalizableString(TUIKitSDKMsgBodySizeLimit) forKey:@(ERR_SDK_MSG_BODY_SIZE_LIMIT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSDKMsgKeyReqDifferRsp) forKey:@(ERR_SDK_MSG_KEY_REQ_DIFFER_RSP)];
    
    // Group
    [map setObject:TUIKitLocalizableString(TUIKitErrorSDKGroupInvalidID) forKey:@(ERR_SDK_GROUP_INVALID_ID)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSDKGroupInvalidName) forKey:@(ERR_SDK_GROUP_INVALID_NAME)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSDKGroupInvalidIntroduction) forKey:@(ERR_SDK_GROUP_INVALID_INTRODUCTION)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSDKGroupInvalidNotification) forKey:@(ERR_SDK_GROUP_INVALID_NOTIFICATION)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSDKGroupInvalidFaceURL) forKey:@(ERR_SDK_GROUP_INVALID_FACE_URL)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSDKGroupInvalidNameCard) forKey:@(ERR_SDK_GROUP_INVALID_NAME_CARD)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSDKGroupMemberCountLimit) forKey:@(ERR_SDK_GROUP_MEMBER_COUNT_LIMIT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSDKGroupJoinPrivateGroupDeny) forKey:@(ERR_SDK_GROUP_JOIN_PRIVATE_GROUP_DENY)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSDKGroupInviteSuperDeny) forKey:@(ERR_SDK_GROUP_INVITE_SUPER_DENY)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSDKGroupInviteNoMember) forKey:@(ERR_SDK_GROUP_INVITE_NO_MEMBER)];
    
    // Relationship
    [map setObject:TUIKitLocalizableString(TUIKitErrorSDKFriendShipInvalidProfileKey) forKey:@(ERR_SDK_FRIENDSHIP_INVALID_PROFILE_KEY)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSDKFriendshipInvalidAddRemark) forKey:@(ERR_SDK_FRIENDSHIP_INVALID_ADD_REMARK)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSDKFriendshipInvalidAddWording) forKey:@(ERR_SDK_FRIENDSHIP_INVALID_ADD_WORDING)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSDKFriendshipInvalidAddSource) forKey:@(ERR_SDK_FRIENDSHIP_INVALID_ADD_SOURCE)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSDKFriendshipFriendGroupEmpty) forKey:@(ERR_SDK_FRIENDSHIP_FRIEND_GROUP_EMPTY)];
    
    // Network
    [map setObject:TUIKitLocalizableString(TUIKitErrorSDKNetEncodeFailed) forKey:@(ERR_SDK_NET_ENCODE_FAILED)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSDKNetDecodeFailed) forKey:@(ERR_SDK_NET_DECODE_FAILED)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSDKNetAuthInvalid) forKey:@(ERR_SDK_NET_AUTH_INVALID)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSDKNetCompressFailed) forKey:@(ERR_SDK_NET_COMPRESS_FAILED)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSDKNetUncompressFaile) forKey:@(ERR_SDK_NET_UNCOMPRESS_FAILED)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSDKNetFreqLimit) forKey:@(ERR_SDK_NET_FREQ_LIMIT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSDKnetReqCountLimit) forKey:@(ERR_SDK_NET_REQ_COUNT_LIMIT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSDKNetDisconnect) forKey:@(ERR_SDK_NET_DISCONNECT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSDKNetAllreadyConn) forKey:@(ERR_SDK_NET_ALLREADY_CONN)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSDKNetConnTimeout) forKey:@(ERR_SDK_NET_CONN_TIMEOUT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSDKNetConnRefuse) forKey:@(ERR_SDK_NET_CONN_REFUSE)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSDKNetNetUnreach) forKey:@(ERR_SDK_NET_NET_UNREACH)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSDKNetSocketNoBuff) forKey:@(ERR_SDK_NET_SOCKET_NO_BUFF)];
    [map setObject:TUIKitLocalizableString(TUIKitERRORSDKNetResetByPeer) forKey:@(ERR_SDK_NET_RESET_BY_PEER)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSDKNetSOcketInvalid) forKey:@(ERR_SDK_NET_SOCKET_INVALID)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSDKNetHostGetAddressFailed) forKey:@(ERR_SDK_NET_HOST_GETADDRINFO_FAILED)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSDKNetConnectReset) forKey:@(ERR_SDK_NET_CONNECT_RESET)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSDKNetWaitInQueueTimeout) forKey:@(ERR_SDK_NET_WAIT_INQUEUE_TIMEOUT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSDKNetWaitSendTimeout) forKey:@(ERR_SDK_NET_WAIT_SEND_TIMEOUT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSDKNetWaitAckTimeut) forKey:@(ERR_SDK_NET_WAIT_ACK_TIMEOUT)];
    
    /////////////////////////////////////////////////////////////////////////////////
    //
    //                      （二）Server
    //
    /////////////////////////////////////////////////////////////////////////////////

    // SSO
    [map setObject:TUIKitLocalizableString(TUIKitErrorSDKSVRSSOConnectLimit) forKey:@(ERR_SVR_SSO_CONNECT_LIMIT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSDKSVRSSOVCode) forKey:@(ERR_SVR_SSO_VCODE)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRSSOEmpeyKey) forKey:@(ERR_SVR_SSO_EMPTY_KEY)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRSSOUinInvalid) forKey:@(ERR_SVR_SSO_UIN_INVALID)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRSSOVCodeTimeout) forKey:@(ERR_SVR_SSO_VCODE_TIMEOUT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRSSOCookieInvalid) forKey:@(ERR_SVR_SSO_COOKIE_INVALID)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRSSODownTips) forKey:@(ERR_SVR_SSO_DOWN_TIP)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRSSODisconnect) forKey:@(ERR_SVR_SSO_DISCONNECT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRSSOIdentifierInvalid) forKey:@(ERR_SVR_SSO_IDENTIFIER_INVALID)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRSSOClientClose) forKey:@(ERR_SVR_SSO_CLIENT_CLOSE)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRSSOMSFSDKQuit) forKey:@(ERR_SVR_SSO_MSFSDK_QUIT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRSSOUnsupport) forKey:@(ERR_SVR_SSO_UNSURPPORT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRSSOPrepaidArrears) forKey:@(ERR_SVR_SSO_PREPAID_ARREARS)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRSSOPacketWrong) forKey:@(ERR_SVR_SSO_PACKET_WRONG)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRSSOAppidBlackList) forKey:@(ERR_SVR_SSO_APPID_BLACK_LIST)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRSSOCmdBlackList) forKey:@(ERR_SVR_SSO_CMD_BLACK_LIST)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRSSOAppidWithoutUsing) forKey:@(ERR_SVR_SSO_APPID_WITHOUT_USING)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRSSOFreqLimit) forKey:@(ERR_SVR_SSO_FREQ_LIMIT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRSSOOverload) forKey:@(ERR_SVR_SSO_OVERLOAD)];
    
    // Resource
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRResNotFound) forKey:@(ERR_SVR_RES_NOT_FOUND)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRResAccessDeny) forKey:@(ERR_SVR_RES_ACCESS_DENY)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRResSizeLimit) forKey:@(ERR_SVR_RES_SIZE_LIMIT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRResSendCancel) forKey:@(ERR_SVR_RES_SEND_CANCEL)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRResReadFailed) forKey:@(ERR_SVR_RES_READ_FAILED)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRResTransferTimeout) forKey:@(ERR_SVR_RES_TRANSFER_TIMEOUT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRResInvalidParameters) forKey:@(ERR_SVR_RES_INVALID_PARAMETERS)];
    
    // Common
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRCommonInvalidHttpUrl) forKey:@(ERR_SVR_COMM_INVALID_HTTP_URL)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRCommomReqJsonParseFailed) forKey:@(ERR_SVR_COMM_REQ_JSON_PARSE_FAILED)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRCommonInvalidAccount) forKey:@(ERR_SVR_COMM_INVALID_ACCOUNT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRCommonInvalidAccount) forKey:@(ERR_SVR_COMM_INVALID_ACCOUNT_EX)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRCommonInvalidSdkappid) forKey:@(ERR_SVR_COMM_INVALID_SDKAPPID)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRCommonRestFreqLimit) forKey:@(ERR_SVR_COMM_REST_FREQ_LIMIT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRCommonRequestTimeout) forKey:@(ERR_SVR_COMM_REQUEST_TIMEOUT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRCommonInvalidRes) forKey:@(ERR_SVR_COMM_INVALID_RES)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRCommonIDNotAdmin) forKey:@(ERR_SVR_COMM_ID_NOT_ADMIN)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRCommonSdkappidFreqLimit) forKey:@(ERR_SVR_COMM_SDKAPPID_FREQ_LIMIT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRCommonSdkappidMiss) forKey:@(ERR_SVR_COMM_SDKAPPID_MISS)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRCommonRspJsonParseFailed) forKey:@(ERR_SVR_COMM_RSP_JSON_PARSE_FAILED)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRCommonExchangeAccountTimeout) forKey:@(ERR_SVR_COMM_EXCHANGE_ACCOUNT_TIMEUT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRCommonInvalidIdFormat) forKey:@(ERR_SVR_COMM_INVALID_ID_FORMAT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRCommonSDkappidForbidden) forKey:@(ERR_SVR_COMM_SDKAPPID_FORBIDDEN)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRCommonReqForbidden) forKey:@(ERR_SVR_COMM_REQ_FORBIDDEN)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRCommonReqFreqLimit) forKey:@(ERR_SVR_COMM_REQ_FREQ_LIMIT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRCommonReqFreqLimit) forKey:@(ERR_SVR_COMM_REQ_FREQ_LIMIT_EX)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRCommonInvalidService) forKey:@(ERR_SVR_COMM_INVALID_SERVICE)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRCommonSensitiveText) forKey:@(ERR_SVR_COMM_SENSITIVE_TEXT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRCommonBodySizeLimit) forKey:@(ERR_SVR_COMM_BODY_SIZE_LIMIT)];
    
    // Account
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRAccountUserSigExpired) forKey:@(ERR_SVR_ACCOUNT_USERSIG_EXPIRED)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRAccountUserSigEmpty) forKey:@(ERR_SVR_ACCOUNT_USERSIG_EMPTY)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRAccountUserSigCheckFailed) forKey:@(ERR_SVR_ACCOUNT_USERSIG_CHECK_FAILED)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRAccountUserSigCheckFailed) forKey:@(ERR_SVR_ACCOUNT_USERSIG_CHECK_FAILED_EX)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRAccountUserSigMismatchPublicKey) forKey:@(ERR_SVR_ACCOUNT_USERSIG_MISMATCH_PUBLICKEY)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRAccountUserSigMismatchId) forKey:@(ERR_SVR_ACCOUNT_USERSIG_MISMATCH_ID)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRAccountUserSigMismatchSdkAppid) forKey:@(ERR_SVR_ACCOUNT_USERSIG_MISMATCH_SDKAPPID)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRAccountUserSigPublicKeyNotFound) forKey:@(ERR_SVR_ACCOUNT_USERSIG_PUBLICKEY_NOT_FOUND)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRAccountUserSigSdkAppidNotFount) forKey:@(ERR_SVR_ACCOUNT_SDKAPPID_NOT_FOUND)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRAccountInvalidUserSig) forKey:@(ERR_SVR_ACCOUNT_INVALID_USERSIG)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRAccountNotFound) forKey:@(ERR_SVR_ACCOUNT_NOT_FOUND)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRAccountSecRstr) forKey:@(ERR_SVR_ACCOUNT_SEC_RSTR)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRAccountInternalTimeout) forKey:@(ERR_SVR_ACCOUNT_INTERNAL_TIMEOUT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRAccountInvalidCount) forKey:@(ERR_SVR_ACCOUNT_INVALID_COUNT)];
    [map setObject:TUIKitLocalizableString(TUIkitErrorSVRAccountINvalidParameters) forKey:@(ERR_SVR_ACCOUNT_INVALID_PARAMETERS)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRAccountAdminRequired) forKey:@(ERR_SVR_ACCOUNT_ADMIN_REQUIRED)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRAccountLowSDKVersion) forKey:@(ERR_SVR_ACCOUNT_LOW_SDK_VERSION)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRAccountFreqLimit) forKey:@(ERR_SVR_ACCOUNT_FREQ_LIMIT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRAccountBlackList) forKey:@(ERR_SVR_ACCOUNT_BLACKLIST)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRAccountCountLimit) forKey:@(ERR_SVR_ACCOUNT_COUNT_LIMIT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRAccountInternalError) forKey:@(ERR_SVR_ACCOUNT_INTERNAL_ERROR)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorEnableUserStatusOnConsole) forKey:@(ERR_SVR_ACCOUNT_USER_STATUS_DISABLED)];
    
    // Profile
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRProfileInvalidParameters) forKey:@(ERR_SVR_PROFILE_INVALID_PARAMETERS)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRProfileAccountMiss) forKey:@(ERR_SVR_PROFILE_ACCOUNT_MISS)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRProfileAccountNotFound) forKey:@(ERR_SVR_PROFILE_ACCOUNT_NOT_FOUND)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRProfileAdminRequired) forKey:@(ERR_SVR_PROFILE_ADMIN_REQUIRED)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRProfileSensitiveText) forKey:@(ERR_SVR_PROFILE_SENSITIVE_TEXT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRProfileInternalError) forKey:@(ERR_SVR_PROFILE_INTERNAL_ERROR)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRProfileReadWritePermissionRequired) forKey:@(ERR_SVR_PROFILE_READ_PERMISSION_REQUIRED)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRProfileReadWritePermissionRequired) forKey:@(ERR_SVR_PROFILE_WRITE_PERMISSION_REQUIRED)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRProfileTagNotFound) forKey:@(ERR_SVR_PROFILE_TAG_NOT_FOUND)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRProfileSizeLimit) forKey:@(ERR_SVR_PROFILE_SIZE_LIMIT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRProfileValueError) forKey:@(ERR_SVR_PROFILE_VALUE_ERROR)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRProfileInvalidValueFormat) forKey:@(ERR_SVR_PROFILE_INVALID_VALUE_FORMAT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRFriendshipInvalidParameters) forKey:@(ERR_SVR_FRIENDSHIP_INVALID_PARAMETERS)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRFriendshipInvalidSdkAppid) forKey:@(ERR_SVR_FRIENDSHIP_INVALID_SDKAPPID)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRFriendshipAccountNotFound) forKey:@(ERR_SVR_FRIENDSHIP_ACCOUNT_NOT_FOUND)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRFriendshipAdminRequired) forKey:@(ERR_SVR_FRIENDSHIP_ADMIN_REQUIRED)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRFriendshipSensitiveText) forKey:@(ERR_SVR_FRIENDSHIP_SENSITIVE_TEXT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRAccountInternalError) forKey:@(ERR_SVR_FRIENDSHIP_INTERNAL_ERROR)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRFriendshipNetTimeout) forKey:@(ERR_SVR_FRIENDSHIP_NET_TIMEOUT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRFriendshipWriteConflict) forKey:@(ERR_SVR_FRIENDSHIP_WRITE_CONFLICT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRFriendshipAddFriendDeny) forKey:@(ERR_SVR_FRIENDSHIP_ADD_FRIEND_DENY)];
    [map setObject:TUIKitLocalizableString(TUIkitErrorSVRFriendshipCountLimit) forKey:@(ERR_SVR_FRIENDSHIP_COUNT_LIMIT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRFriendshipGroupCountLimit) forKey:@(ERR_SVR_FRIENDSHIP_GROUP_COUNT_LIMIT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRFriendshipPendencyLimit) forKey:@(ERR_SVR_FRIENDSHIP_PENDENCY_LIMIT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRFriendshipBlacklistLimit) forKey:@(ERR_SVR_FRIENDSHIP_BLACKLIST_LIMIT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRFriendshipPeerFriendLimit) forKey:@(ERR_SVR_FRIENDSHIP_PEER_FRIEND_LIMIT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRFriendshipInSelfBlacklist) forKey:@(ERR_SVR_FRIENDSHIP_IN_SELF_BLACKLIST)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRFriendshipAllowTypeDenyAny) forKey:@(ERR_SVR_FRIENDSHIP_ALLOW_TYPE_DENY_ANY)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRFriendshipInPeerBlackList) forKey:@(ERR_SVR_FRIENDSHIP_IN_PEER_BLACKLIST)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRFriendshipAllowTypeNeedConfirm) forKey:@(ERR_SVR_FRIENDSHIP_ALLOW_TYPE_NEED_CONFIRM)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRFriendshipAddFriendSecRstr) forKey:@(ERR_SVR_FRIENDSHIP_ADD_FRIEND_SEC_RSTR)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRFriendshipPendencyNotFound) forKey:@(ERR_SVR_FRIENDSHIP_PENDENCY_NOT_FOUND)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRFriendshipDelFriendSecRstr) forKey:@(ERR_SVR_FRIENDSHIP_DEL_FRIEND_SEC_RSTR)];
    [map setObject:TUIKitLocalizableString(TUIKirErrorSVRFriendAccountNotFoundEx) forKey:@(ERR_SVR_FRIENDSHIP_ACCOUNT_NOT_FOUND_EX)];
    // Conversation
    [map setObject:TUIKitLocalizableString(TUIKirErrorSVRFriendAccountNotFoundEx) forKey:@(ERR_SVR_CONV_ACCOUNT_NOT_FOUND)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRFriendshipInvalidParameters) forKey:@(ERR_SVR_CONV_INVALID_PARAMETERS)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRFriendshipAdminRequired) forKey:@(ERR_SVR_CONV_ADMIN_REQUIRED)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRAccountInternalError) forKey:@(ERR_SVR_CONV_INTERNAL_ERROR)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRFriendshipNetTimeout) forKey:@(ERR_SVR_CONV_NET_TIMEOUT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRConvGroupNameLengthLimit) forKey:@(ERR_SVR_CONV_CONV_GROUP_NAME_EXCEED_LENGTH)];
    
    // Message
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRMsgPkgParseFailed) forKey:@(ERR_SVR_MSG_PKG_PARSE_FAILED)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRMsgInternalAuthFailed) forKey:@(ERR_SVR_MSG_INTERNAL_AUTH_FAILED)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRMsgInvalidId) forKey:@(ERR_SVR_MSG_INVALID_ID)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRMsgNetError) forKey:@(ERR_SVR_MSG_NET_ERROR)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRMsgPushDeny) forKey:@(ERR_SVR_MSG_PUSH_DENY)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRMsgInPeerBlackList) forKey:@(ERR_SVR_MSG_IN_PEER_BLACKLIST)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRMsgBothNotFriend) forKey:@(ERR_SVR_MSG_BOTH_NOT_FRIEND)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRMsgNotPeerFriend) forKey:@(ERR_SVR_MSG_NOT_PEER_FRIEND)];
    [map setObject:TUIKitLocalizableString(TUIkitErrorSVRMsgNotSelfFriend) forKey:@(ERR_SVR_MSG_NOT_SELF_FRIEND)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRMsgShutupDeny) forKey:@(ERR_SVR_MSG_SHUTUP_DENY)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRMsgRevokeTimeLimit) forKey:@(ERR_SVR_MSG_REVOKE_TIME_LIMIT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRMsgDelRambleInternalError) forKey:@(ERR_SVR_MSG_DEL_RAMBLE_INTERNAL_ERROR)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRMsgJsonParseFailed) forKey:@(ERR_SVR_MSG_JSON_PARSE_FAILED)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRMsgInvalidJsonBodyFormat) forKey:@(ERR_SVR_MSG_INVALID_JSON_BODY_FORMAT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRMsgInvalidToAccount) forKey:@(ERR_SVR_MSG_INVALID_TO_ACCOUNT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRMsgInvalidRand) forKey:@(ERR_SVR_MSG_INVALID_RAND)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRMsgInvalidTimestamp) forKey:@(ERR_SVR_MSG_INVALID_TIMESTAMP)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRMsgBodyNotArray) forKey:@(ERR_SVR_MSG_BODY_NOT_ARRAY)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRAccountAdminRequired) forKey:@(ERR_SVR_MSG_ADMIN_REQUIRED)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRMsgInvalidJsonFormat) forKey:@(ERR_SVR_MSG_INVALID_JSON_FORMAT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRMsgToAccountCountLimit) forKey:@(ERR_SVR_MSG_TO_ACCOUNT_COUNT_LIMIT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRMsgToAccountNotFound) forKey:@(ERR_SVR_MSG_TO_ACCOUNT_NOT_FOUND)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRMsgTimeLimit) forKey:@(ERR_SVR_MSG_TIME_LIMIT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRMsgInvalidSyncOtherMachine) forKey:@(ERR_SVR_MSG_INVALID_SYNCOTHERMACHINE)];
    [map setObject:TUIKitLocalizableString(TUIkitErrorSVRMsgInvalidMsgLifeTime) forKey:@(ERR_SVR_MSG_INVALID_MSGLIFETIME)];
    [map setObject:TUIKitLocalizableString(TUIKirErrorSVRFriendAccountNotFoundEx) forKey:@(ERR_SVR_MSG_ACCOUNT_NOT_FOUND)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRMsgBodySizeLimit) forKey:@(ERR_SVR_MSG_BODY_SIZE_LIMIT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRmsgLongPollingCountLimit) forKey:@(ERR_SVR_MSG_LONGPOLLING_COUNT_LIMIT)];
    
    // Group
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRAccountInternalError) forKey:@(ERR_SVR_GROUP_INTERNAL_ERROR)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRGroupApiNameError) forKey:@(ERR_SVR_GROUP_API_NAME_ERROR)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRResInvalidParameters) forKey:@(ERR_SVR_GROUP_INVALID_PARAMETERS)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRGroupAccountCountLimit) forKey:@(ERR_SVR_GROUP_ACOUNT_COUNT_LIMIT)];
    [map setObject:TUIKitLocalizableString(TUIkitErrorSVRGroupFreqLimit) forKey:@(ERR_SVR_GROUP_FREQ_LIMIT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRGroupPermissionDeny) forKey:@(ERR_SVR_GROUP_PERMISSION_DENY)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRGroupInvalidReq) forKey:@(ERR_SVR_GROUP_INVALID_REQ)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRGroupSuperNotAllowQuit) forKey:@(ERR_SVR_GROUP_SUPER_NOT_ALLOW_QUIT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRGroupNotFound) forKey:@(ERR_SVR_GROUP_NOT_FOUND)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRGroupJsonParseFailed) forKey:@(ERR_SVR_GROUP_JSON_PARSE_FAILED)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRGroupInvalidId) forKey:@(ERR_SVR_GROUP_INVALID_ID)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRGroupAllreadyMember) forKey:@(ERR_SVR_GROUP_ALLREADY_MEMBER)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRGroupFullMemberCount) forKey:@(ERR_SVR_GROUP_FULL_MEMBER_COUNT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRGroupInvalidGroupId) forKey:@(ERR_SVR_GROUP_INVALID_GROUPID)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRGroupRejectFromThirdParty) forKey:@(ERR_SVR_GROUP_REJECT_FROM_THIRDPARTY)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRGroupShutDeny) forKey:@(ERR_SVR_GROUP_SHUTUP_DENY)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRGroupRspSizeLimit) forKey:@(ERR_SVR_GROUP_RSP_SIZE_LIMIT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRGroupAccountNotFound) forKey:@(ERR_SVR_GROUP_ACCOUNT_NOT_FOUND)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRGroupGroupIdInUse) forKey:@(ERR_SVR_GROUP_GROUPID_IN_USED)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRGroupSendMsgFreqLimit) forKey:@(ERR_SVR_GROUP_SEND_MSG_FREQ_LIMIT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRGroupReqAllreadyBeenProcessed) forKey:@(ERR_SVR_GROUP_REQ_ALLREADY_BEEN_PROCESSED)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRGroupGroupIdUserdForSuper) forKey:@(ERR_SVR_GROUP_GROUPID_IN_USED_FOR_SUPER)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRGroupSDkAppidDeny) forKey:@(ERR_SVR_GROUP_SDKAPPID_DENY)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRGroupRevokeMsgNotFound) forKey:@(ERR_SVR_GROUP_REVOKE_MSG_NOT_FOUND)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRGroupRevokeMsgTimeLimit) forKey:@(ERR_SVR_GROUP_REVOKE_MSG_TIME_LIMIT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRGroupRevokeMsgDeny) forKey:@(ERR_SVR_GROUP_REVOKE_MSG_DENY)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRGroupNotAllowRevokeMsg) forKey:@(ERR_SVR_GROUP_NOT_ALLOW_REVOKE_MSG)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRGroupRemoveMsgDeny) forKey:@(ERR_SVR_GROUP_REMOVE_MSG_DENY)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRGroupNotAllowRemoveMsg) forKey:@(ERR_SVR_GROUP_NOT_ALLOW_REMOVE_MSG)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRGroupAvchatRoomCountLimit) forKey:@(ERR_SVR_GROUP_AVCHATROOM_COUNT_LIMIT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRGroupCountLimit) forKey:@(ERR_SVR_GROUP_COUNT_LIMIT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRGroupMemberCountLimit) forKey:@(ERR_SVR_GROUP_MEMBER_COUNT_LIMIT)];
    
    /////////////////////////////////////////////////////////////////////////////////
    //
    //                      （三）Version 3 deprecated
    //
    /////////////////////////////////////////////////////////////////////////////////
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRNoSuccessResult) forKey:@(ERR_NO_SUCC_RESULT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRToUserInvalid) forKey:@(ERR_TO_USER_INVALID)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRInitCoreFail) forKey:@(ERR_INIT_CORE_FAIL)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorExpiredSessionNode) forKey:@(ERR_EXPIRED_SESSION_NODE)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorLoggedOutBeforeLoginFinished) forKey:@(ERR_LOGGED_OUT_BEFORE_LOGIN_FINISHED)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorTLSSDKNotInitialized) forKey:@(ERR_TLSSDK_NOT_INITIALIZED)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorTLSSDKUserNotFound) forKey:@(ERR_TLSSDK_USER_NOT_FOUND)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorBindFaildRegTimeout) forKey:@(ERR_BIND_FAIL_REG_TIMEOUT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorBindFaildIsBinding) forKey:@(ERR_BIND_FAIL_ISBINDING)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorPacketFailUnknown) forKey:@(ERR_PACKET_FAIL_UNKNOWN)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorPacketFailReqNoNet) forKey:@(ERR_PACKET_FAIL_REQ_NO_NET)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorPacketFailRespNoNet) forKey:@(ERR_PACKET_FAIL_RESP_NO_NET)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorPacketFailReqNoAuth) forKey:@(ERR_PACKET_FAIL_REQ_NO_AUTH)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorPacketFailSSOErr) forKey:@(ERR_PACKET_FAIL_SSO_ERR)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSVRRequestTimeout) forKey:@(ERR_PACKET_FAIL_REQ_TIMEOUT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorPacketFailRespTimeout) forKey:@(ERR_PACKET_FAIL_RESP_TIMEOUT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorFriendshipProxySyncing) forKey:@(ERR_FRIENDSHIP_PROXY_SYNCING)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorFriendshipProxySyncedFail) forKey:@(ERR_FRIENDSHIP_PROXY_SYNCED_FAIL)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorFriendshipProxyLocalCheckErr) forKey:@(ERR_FRIENDSHIP_PROXY_LOCAL_CHECK_ERR)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorGroupInvalidField) forKey:@(ERR_GROUP_INVALID_FIELD)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorGroupStoreageDisabled) forKey:@(ERR_GROUP_STORAGE_DISABLED)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorLoadGrpInfoFailed) forKey:@(ERR_LOADGRPINFO_FAILED)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorReqNoNetOnReq) forKey:@(ERR_REQ_NO_NET_ON_REQ)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorReqNoNetOnResp) forKey:@(ERR_REQ_NO_NET_ON_RSP)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorServiceNotReady) forKey:@(ERR_SERIVCE_NOT_READY)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorLoginAuthFailed) forKey:@(ERR_LOGIN_AUTH_FAILED)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorNeverConnectAfterLaunch) forKey:@(ERR_NEVER_CONNECT_AFTER_LAUNCH)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorReqFailed) forKey:@(ERR_REQ_FAILED)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorReqInvaidReq) forKey:@(ERR_REQ_INVALID_REQ)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorReqOnverLoaded) forKey:@(ERR_REQ_OVERLOADED)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorReqKickOff) forKey:@(ERR_REQ_KICK_OFF)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorReqServiceSuspend) forKey:@(ERR_REQ_SERVICE_SUSPEND)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorReqInvalidSign) forKey:@(ERR_REQ_INVALID_SIGN)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorReqInvalidCookie) forKey:@(ERR_REQ_INVALID_COOKIE)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorLoginTlsRspParseFailed) forKey:@(ERR_LOGIN_TLS_RSP_PARSE_FAILED)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorLoginOpenMsgTimeout) forKey:@(ERR_LOGIN_OPENMSG_TIMEOUT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorLoginOpenMsgRspParseFailed) forKey:@(ERR_LOGIN_OPENMSG_RSP_PARSE_FAILED)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorLoginTslDecryptFailed) forKey:@(ERR_LOGIN_TLS_DECRYPT_FAILED)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorWifiNeedAuth) forKey:@(ERR_WIFI_NEED_AUTH)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorUserCanceled) forKey:@(ERR_USER_CANCELED)];
    [map setObject:TUIKitLocalizableString(TUIkitErrorRevokeTimeLimitExceed) forKey:@(ERR_REVOKE_TIME_LIMIT_EXCEED)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorLackUGExt) forKey:@(ERR_LACK_UGC_EXT)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorAutoLoginNeedUserSig) forKey:@(ERR_AUTOLOGIN_NEED_USERSIG)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorQALNoShortConneAvailable) forKey:@(ERR_QAL_NO_SHORT_CONN_AVAILABLE)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorReqContentAttach) forKey:@(ERR_REQ_CONTENT_ATTACK)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorLoginSigExpire) forKey:@(ERR_LOGIN_SIG_EXPIRE)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorSDKHadInit) forKey:@(ERR_SDK_HAD_INITIALIZED)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorOpenBDHBase) forKey:@(ERR_OPENBDH_BASE)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorRequestNoNetOnReq) forKey:@(ERR_REQUEST_NO_NET_ONREQ)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorRequestNoNetOnRsp) forKey:@(ERR_REQUEST_NO_NET_ONRSP)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorRequestOnverLoaded) forKey:@(ERR_REQUEST_OVERLOADED)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorReqKickOff) forKey:@(ERR_REQUEST_KICK_OFF)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorReqServiceSuspend) forKey:@(ERR_REQUEST_SERVICE_SUSPEND)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorReqInvalidSign) forKey:@(ERR_REQUEST_INVALID_SIGN)];
    [map setObject:TUIKitLocalizableString(TUIKitErrorReqInvalidCookie) forKey:@(ERR_REQUEST_INVALID_COOKIE)];
}
+ (NSData *)dictionary2JsonData:(NSDictionary *)dict {
    if ([NSJSONSerialization isValidJSONObject:dict]) {
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
        if (error) {
            NSLog(@"[%@] Post Json Error", [self class]);
        }
        return data;
    } else {
        NSLog(@"[%@] Post Json is not valid", [self class]);
    }
    return nil;
}

+ (NSString *)dictionary2JsonStr:(NSDictionary *)dict {
    return [[NSString alloc] initWithData:[self dictionary2JsonData:dict] encoding:NSUTF8StringEncoding];
    ;
}

+ (NSDictionary *)jsonSring2Dictionary:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&err];
    if (err || ![dic isKindOfClass:[NSDictionary class]]) {
        NSLog(@"Json parse failed: %@", jsonString);
        return nil;
    }
    return dic;
}

+ (NSDictionary *)jsonData2Dictionary:(NSData *)jsonData {
    if (jsonData == nil) {
        return nil;
    }
    NSError *err = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if (err || ![dic isKindOfClass:[NSDictionary class]]) {
        NSLog(@"Json parse failed");
        return nil;
    }
    return dic;
}

+ (void)asyncDecodeImage:(NSString *)path complete:(TAsyncImageComplete)complete {
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      queue = dispatch_queue_create("com.tuikit.asyncDecodeImage", DISPATCH_QUEUE_SERIAL);
    });

    // callback on main thread
    void (^callback)(NSString *, UIImage *) = ^(NSString *path, UIImage *image) {
      if (complete == nil) {
          return;
      }
      dispatch_async(dispatch_get_main_queue(), ^{
        complete(path, image);
      });
    };

    if (path == nil) {
        callback(nil, nil);
        return;
    }

    dispatch_async(queue, ^{
      // gif
      if ([path containsString:@".gif"]) {
          UIImage *image = [UIImage sd_imageWithGIFData:[NSData dataWithContentsOfFile:path]];
          callback(path, image);
          return;
      }

      // load origin image
      UIImage *image = [UIImage imageNamed:path];
      if (image == nil) {
          image = [UIImage imageWithContentsOfFile:path];
      }

      if (image == nil) {
          callback(path, image);
          return;
      }

      // SDWebImage is priority
      UIImage *decodeImage = [SDImageCoderHelper decodedImageWithImage:image];
      if (decodeImage) {
          callback(path, decodeImage);
          return;
      }

      // Bitmap
      CGImageRef cgImage = image.CGImage;
      if (cgImage) {
          CGImageAlphaInfo alphaInfo = CGImageGetAlphaInfo(cgImage) & kCGBitmapAlphaInfoMask;
          BOOL hasAlpha = NO;
          if (alphaInfo == kCGImageAlphaPremultipliedLast || alphaInfo == kCGImageAlphaPremultipliedFirst || alphaInfo == kCGImageAlphaLast ||
              alphaInfo == kCGImageAlphaFirst) {
              hasAlpha = YES;
          }
          CGBitmapInfo bitmapInfo = kCGBitmapByteOrder32Host;
          bitmapInfo |= hasAlpha ? kCGImageAlphaPremultipliedFirst : kCGImageAlphaNoneSkipFirst;
          size_t width = CGImageGetWidth(cgImage);
          size_t height = CGImageGetHeight(cgImage);
          CGContextRef context = CGBitmapContextCreate(NULL, width, height, 8, 0, CGColorSpaceCreateDeviceRGB(), bitmapInfo);
          if (context) {
              CGContextDrawImage(context, CGRectMake(0, 0, width, height), cgImage);
              cgImage = CGBitmapContextCreateImage(context);
              decodeImage = [UIImage imageWithCGImage:cgImage scale:image.scale orientation:image.imageOrientation];
              CGContextRelease(context);
              CGImageRelease(cgImage);
          }
      }
      callback(path, decodeImage);
    });
}

+ (void)makeToast:(NSString *)str {
    if ([TUIConfig defaultConfig].enableToast) {
        [[UIApplication sharedApplication].keyWindow makeToast:str];
    }
}

+ (void)makeToast:(NSString *)str duration:(NSTimeInterval)duration {
    if ([TUIConfig defaultConfig].enableToast) {
        [[UIApplication sharedApplication].keyWindow makeToast:str duration:duration];
    }
}

+ (void)makeToast:(NSString *)str duration:(NSTimeInterval)duration position:(CGPoint)position {
    if ([TUIConfig defaultConfig].enableToast) {
        [[UIApplication sharedApplication].keyWindow makeToast:str duration:duration position:[NSValue valueWithCGPoint:position]];
    }
}

+ (void)makeToast:(NSString *)str duration:(NSTimeInterval)duration idposition:(id)position {
    if ([TUIConfig defaultConfig].enableToast) {
        [[UIApplication sharedApplication].keyWindow makeToast:str duration:duration position:position];
    }
}

+ (void)makeToastError:(NSInteger)error msg:(NSString *)msg {
    if ([TUIConfig defaultConfig].enableToast) {
        [[UIApplication sharedApplication].keyWindow makeToast:[self convertIMError:error msg:msg]];
    }
}

+ (void)hideToast {
    if ([TUIConfig defaultConfig].enableToast) {
        [[UIApplication sharedApplication].keyWindow hideToast];
    }
}

+ (void)makeToastActivity {
    if ([TUIConfig defaultConfig].enableToast) {
        [[UIApplication sharedApplication].keyWindow makeToastActivity:TUICSToastPositionCenter];
    }
}

+ (void)hideToastActivity {
    if ([TUIConfig defaultConfig].enableToast) {
        [[UIApplication sharedApplication].keyWindow hideToastActivity];
    }
}

+ (NSString *)convertDateToStr:(NSDate *)date {
    if (!date) {
        return nil;
    }

    if ([date isEqualToDate:[NSDate distantPast]]) {
        return @"";
    }

    static NSDateFormatter *dateFmt = nil;
    if (dateFmt == nil) {
        dateFmt = [[NSDateFormatter alloc] init];
    }
    dateFmt.locale = nil;

    NSCalendar *calendar = [NSCalendar currentCalendar];
    calendar.firstWeekday = 7;
    NSDateComponents *nowComponent = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitWeekOfMonth
                                                 fromDate:NSDate.new];
    NSDateComponents *dateCompoent = [calendar components:NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear | NSCalendarUnitWeekOfMonth
                                                 fromDate:date];

    if (nowComponent.year == dateCompoent.year) {
        // Same year
        if (nowComponent.month == dateCompoent.month) {
            // Same month
            if (nowComponent.weekOfMonth == dateCompoent.weekOfMonth) {
                // Same week
                if (nowComponent.day == dateCompoent.day) {
                    // Same day
                    dateFmt.dateFormat = @"HH:mm";
                } else {
                    // Not same day
                    dateFmt.dateFormat = @"EEEE";
                    NSString *identifer = [TUIGlobalization getPreferredLanguage];
                    dateFmt.locale = [NSLocale localeWithLocaleIdentifier:identifer];
                }
            } else {
                // Not same weeek
                dateFmt.dateFormat = @"MM/dd";
            }
        } else {
            // Not same month
            dateFmt.dateFormat = @"MM/dd";
        }
    } else {
        // Not same year
        dateFmt.dateFormat = @"yyyy/MM/dd";
    }

    NSString *str = [dateFmt stringFromDate:date];
    return str;
}

+ (NSString *)convertDateToHMStr:(NSDate *)date {
    if (!date) {
        return nil;
    }

    if ([date isEqualToDate:[NSDate distantPast]]) {
        return @"";
    }

    NSDateFormatter *dateFmt = [[NSDateFormatter alloc] init];
    dateFmt.dateFormat = @"HH:mm";
    NSString *str = [dateFmt stringFromDate:date];
    return str;
}

+ (NSString *)convertIMError:(NSInteger)code msg:(NSString *)msg {
    NSString  *resultMsg = @"";
    resultMsg = gIMErrorMsgMap[@(code)];
    if (resultMsg.length > 0) {
        return resultMsg;
    }
    return msg;
}

+ (void)dispatchMainAsync:(dispatch_block_t)block {
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

+ (NSString *)genImageName:(NSString *)uuid {
    NSString *identifier = [[V2TIMManager sharedInstance] getLoginUser];
    if (uuid == nil) {
        int value = arc4random() % 1000;
        uuid = [NSString stringWithFormat:@"%ld_%d", (long)[[NSDate date] timeIntervalSince1970], value];
    }

    NSString *name = [NSString stringWithFormat:@"%d_%@_image_%@", [TUILogin getSdkAppID], identifier, uuid];
    return name;
}

+ (NSString *)genSnapshotName:(NSString *)uuid {
    NSString *identifier = [[V2TIMManager sharedInstance] getLoginUser];
    if (uuid == nil) {
        uuid = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    }
    NSString *name = [NSString stringWithFormat:@"%d_%@_snapshot_%@", [TUILogin getSdkAppID], identifier, uuid];
    return name;
}

+ (NSString *)genVideoName:(NSString *)uuid {
    NSString *identifier = [[V2TIMManager sharedInstance] getLoginUser];
    if (uuid == nil) {
        uuid = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    }
    NSString *name = [NSString stringWithFormat:@"%d_%@_video_%@", [TUILogin getSdkAppID], identifier, uuid];
    return name;
}

+ (NSString *)genVoiceName:(NSString *)uuid withExtension:(NSString *)extent {
    NSString *identifier = [[V2TIMManager sharedInstance] getLoginUser];
    if (uuid == nil) {
        uuid = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    }
    NSString *name = [NSString stringWithFormat:@"%d_%@_voice_%@.%@", [TUILogin getSdkAppID], identifier, uuid, extent];
    return name;
}

+ (NSString *)genFileName:(NSString *)uuid {
    NSString *identifier = [[V2TIMManager sharedInstance] getLoginUser];
    if (uuid == nil) {
        uuid = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    }
    NSString *name = [NSString stringWithFormat:@"%d_%@_file_%@", [TUILogin getSdkAppID], identifier, uuid];
    return name;
}

+ (NSString *)deviceModel {
    static NSString *deviceModel;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      deviceModel = [[UIDevice currentDevice] model];
    });
    return deviceModel;
}

+ (NSString *)deviceVersion {
    static NSString *deviceVersion;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      deviceVersion = [[UIDevice currentDevice] systemVersion];
    });
    return deviceVersion;
}

+ (NSString *)deviceName {
    static NSString *deviceName;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      deviceName = [[UIDevice currentDevice] name];
    });
    return deviceName;
}

+ (void)openLinkWithURL:(NSURL *)url {
    if (@available(iOS 10.0, *)) {
        [[UIApplication sharedApplication] openURL:url
                                           options:@{}
                                 completionHandler:^(BOOL success) {
                                   if (success) {
                                       NSLog(@"Opened url");
                                   }
                                 }];
    } else {
        [[UIApplication sharedApplication] openURL:url];
    }
}

+ (void)addUnsupportNotificationInVC:(UIViewController *)vc {
    [self addUnsupportNotificationInVC:vc debugOnly:YES];
}

+ (void)addUnsupportNotificationInVC:(UIViewController *)vc debugOnly:(BOOL)debugOnly {
    BOOL enable = YES;
    if (debugOnly) {
#if DEBUG
        enable = YES;
#else
        enable = NO;
#endif
    }

    if (!enable) {
        return;
    }
    TUIWeakProxy *weakVC = [TUIWeakProxy proxyWithTarget:vc];
    [[NSNotificationCenter defaultCenter] addObserverForName:TUIKitNotification_onReceivedUnsupportInterfaceError
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *_Nonnull note) {
                                                    NSDictionary *userInfo = note.userInfo;
                                                    NSString *service = [userInfo objectForKey:@"service"];
                                                    NSString *serviceDesc = [userInfo objectForKey:@"serviceDesc"];
                                                    if (weakVC.target) {
                                                        [TUITool showUnsupportAlertOfService:service serviceDesc:serviceDesc onVC:weakVC.target];
                                                    }
                                                  }];
}

+ (void)postUnsupportNotificationOfService:(NSString *)service {
    [self postUnsupportNotificationOfService:service serviceDesc:nil debugOnly:YES];
}

+ (void)postUnsupportNotificationOfService:(NSString *)service serviceDesc:(NSString *)serviceDesc debugOnly:(BOOL)debugOnly {
    BOOL enable = YES;
    if (debugOnly) {
#if DEBUG
        enable = YES;
#else
        enable = NO;
#endif
    }

    if (!enable) {
        return;
    }

    if (!service) {
        NSLog(@"postNotificationOfService, service is nil");
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:TUIKitNotification_onReceivedUnsupportInterfaceError
                                                        object:nil
                                                      userInfo:@{@"service" : service ?: @"", @"serviceDesc" : serviceDesc ?: @""}];
}

+ (void)showUnsupportAlertOfService:(NSString *)service serviceDesc:(NSString *)serviceDesc onVC:(UIViewController *)vc {
    NSString *key = [NSString stringWithFormat:@"show_unsupport_alert_%@", service];
    BOOL isShown = [[NSUserDefaults standardUserDefaults] boolForKey:key];
    if (isShown) {
        return;
    }
    NSString *desc = [NSString stringWithFormat:@"%@%@%@", service, TUIKitLocalizableString(TUIKitErrorUnsupportIntefaceDesc), serviceDesc ?: @""];
    NSArray *buttons = @[ TUIKitLocalizableString(TUIKitErrorUnsupportIntefaceIGotIt), TUIKitLocalizableString(TUIKitErrorUnsupportIntefaceNoMoreAlert) ];
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:TUIKitLocalizableString(TUIKitErrorUnsupportIntefaceTitle)
                                                                             message:desc
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:desc];
    [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, desc.length)];
    [attrStr addAttribute:NSLinkAttributeName value:@"https://" range:[desc rangeOfString:TUIKitLocalizableString(TUIKitErrorUnsupportIntefaceGuidelines)]];
    [alertController setValue:attrStr forKey:@"attributedMessage"];
    UILabel *msgLabel = [TUITool messageLabelInAlertController:alertController];
    msgLabel.userInteractionEnabled = YES;
    msgLabel.textAlignment = NSTextAlignmentLeft;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:TUITool.class action:@selector(onTapLabel:)];
    [msgLabel addGestureRecognizer:tap];

    UIAlertAction *left = [UIAlertAction actionWithTitle:buttons[0]
                                                   style:UIAlertActionStyleDefault
                                                 handler:^(UIAlertAction *_Nonnull action){
                                                 }];
    UIAlertAction *right = [UIAlertAction actionWithTitle:buttons[1]
                                                    style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction *_Nonnull action) {
                                                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:key];
                                                    [[NSUserDefaults standardUserDefaults] synchronize];
                                                  }];
    [alertController tuitheme_addAction:left];
    [alertController tuitheme_addAction:right];
    [vc presentViewController:alertController animated:NO completion:nil];
}

+ (void)onTapLabel:(UIGestureRecognizer *)ges {
    NSString *chinesePurchase = @"https://cloud.tencent.com/document/product/269/11673#.E5.9F.BA.E7.A1.80.E6.9C.8D.E5.8A.A1.E8.AF.A6.E6.83.85";
    NSString *englishPurchase = @"https://intl.cloud.tencent.com/document/product/1047/36021?lang=en&pg=#changing-configuration";
    NSString *language = [TUIGlobalization tk_localizableLanguageKey];
    NSURL *url = [NSURL URLWithString:chinesePurchase];
    if (![language containsString:@"zh-"]) {
        url = [NSURL URLWithString:englishPurchase];
    }
    [TUITool openLinkWithURL:url];
}

+ (void)addValueAddedUnsupportNeedContactNotificationInVC:(UIViewController *)vc debugOnly:(BOOL)debugOnly {
    BOOL enable = YES;
    if (debugOnly) {
#if DEBUG
        enable = YES;
#else
        enable = NO;
#endif
    }
    if (!enable) {
        return;
    }

    [[NSNotificationCenter defaultCenter] addObserverForName:TUIKitNotification_onReceivedValueAddedUnsupportContactNeededError
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *_Nonnull note) {
        NSDictionary *userInfo = note.userInfo;
        NSString *service = [userInfo objectForKey:@"service"];
        [TUITool showValueAddedUnsupportNeedContactAlertOfService:service onVC:vc];
    }];
}

+ (void)addValueAddedUnsupportNeedPurchaseNotificationInVC:(UIViewController *)vc debugOnly:(BOOL)debugOnly {
    BOOL enable = YES;
    if (debugOnly) {
#if DEBUG
        enable = YES;
#else
        enable = NO;
#endif
    }
    if (!enable) {
        return;
    }

    [[NSNotificationCenter defaultCenter] addObserverForName:TUIKitNotification_onReceivedValueAddedUnsupportPurchaseNeededError
                                                      object:nil
                                                       queue:nil
                                                  usingBlock:^(NSNotification *_Nonnull note) {
        NSDictionary *userInfo = note.userInfo;
        NSString *service = [userInfo objectForKey:@"service"];
        [TUITool showValueAddedUnsupportNeedPurchaseAlertOfService:service onVC:vc];
    }];
}

+ (void)postValueAddedUnsupportNeedContactNotification:(NSString *)service {
    [self postValueAddedUnsupportNotification:TUIKitNotification_onReceivedValueAddedUnsupportContactNeededError
                                      service:service
                                  serviceDesc:nil
                                    debugOnly:YES];
}

+ (void)postValueAddedUnsupportNeedPurchaseNotification:(NSString *)service {
    [self postValueAddedUnsupportNotification:TUIKitNotification_onReceivedValueAddedUnsupportPurchaseNeededError
                                      service:service
                                  serviceDesc:nil
                                    debugOnly:YES];
}

+ (void)postValueAddedUnsupportNotification:(NSString *)notification service:(NSString *)service serviceDesc:(NSString *)serviceDesc debugOnly:(BOOL)debugOnly {
    BOOL enable = YES;
    if (debugOnly) {
#if DEBUG
        enable = YES;
#else
        enable = NO;
#endif
    }

    if (!enable) {
        return;
    }

    if (!service) {
        NSLog(@"postNotificationOfService, service is nil");
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:notification
                                                        object:nil
                                                      userInfo:@{@"service" : service ?: @"",
                                                                 @"serviceDesc" : serviceDesc ?: @""}];
}

+ (void)showValueAddedUnsupportNeedContactAlertOfService:(NSString *)service onVC:(UIViewController *)vc {
    [self showValueAddedUnsupportAlertOfService:service
                                    serviceDesc:TUIKitLocalizableString(TUIKitErrorValueAddedUnsupportIntefaceContactDesc)
                                           onVC:vc
                                  highlightText:TUIKitLocalizableString(TUIKitErrorValueAddedUnsupportIntefaceContactDescHighlight)
                                            sel:@selector(onTapValueAddedContactLabel)];
}

+ (void)showValueAddedUnsupportNeedPurchaseAlertOfService:(NSString *)service onVC:(UIViewController *)vc {
    [self showValueAddedUnsupportAlertOfService:service
                                    serviceDesc:TUIKitLocalizableString(TUIKitErrorValueAddedUnsupportIntefacePurchaseDesc)
                                           onVC:vc
                                  highlightText:TUIKitLocalizableString(TUIKitErrorValueAddedUnsupportIntefacePurchaseDescHighlight)
                                            sel:@selector(onTapValueAddedPurchaseLabel)];
}

+ (void)showValueAddedUnsupportAlertOfService:(NSString *)service serviceDesc:(NSString *)serviceDesc onVC:(UIViewController *)vc 
                                highlightText:(NSString *)text sel:(SEL)selector {
    NSString *desc = [NSString stringWithFormat:@"%@%@", service, serviceDesc ?: @""];
    NSString *button = TUIKitLocalizableString(TUIKitErrorUnsupportIntefaceIGotIt);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:TUIKitLocalizableString(TUIKitErrorUnsupportIntefaceTitle)
                                                                             message:desc
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:desc];
    [attrStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:14] range:NSMakeRange(0, desc.length)];
    [attrStr addAttribute:NSLinkAttributeName value:@"https://" range:[desc rangeOfString:text]];
    [alertController setValue:attrStr forKey:@"attributedMessage"];
    
    UILabel *msgLabel = [TUITool messageLabelInAlertController:alertController];
    msgLabel.userInteractionEnabled = YES;
    msgLabel.textAlignment = NSTextAlignmentLeft;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:TUITool.class action:selector];
    [msgLabel addGestureRecognizer:tap];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:button
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *_Nonnull action){
                                               }];
    [alertController tuitheme_addAction:ok];
    [vc presentViewController:alertController animated:NO completion:nil];
}

+ (void)onTapValueAddedContactLabel {
    NSURL *url = [NSURL URLWithString:@"https://zhiliao.qq.com"];
    [TUITool openLinkWithURL:url];
}

+ (void)onTapValueAddedPurchaseLabel {
    NSURL *url = [NSURL URLWithString:@"https://buy.cloud.tencent.com/avc?activeId=plugin&regionId=1"];
    [TUITool openLinkWithURL:url];
}

+ (void)checkCommercialAbility:(long long)param succ:(void (^)(BOOL enabled))succ fail:(void (^)(int code, NSString *desc))fail {
    NSLog(@"checkCommercialAbility param: %lld", param);
    dispatch_async(dispatch_get_main_queue(), ^{
      NSNumber *paramNum = [NSNumber numberWithLongLong:param];
      [[V2TIMManager sharedInstance] callExperimentalAPI:@"isCommercialAbilityEnabled"
          param:paramNum
          succ:^(NSObject *result) {
            dispatch_async(dispatch_get_main_queue(), ^{
              BOOL isEnabled = [(NSNumber *)result boolValue];
              NSLog(@"checkCommercialAbility enabled: %d", isEnabled);
              if (succ) {
                  succ(isEnabled);
              }
            });
          }
          fail:^(int code, NSString *desc) {
            dispatch_async(dispatch_get_main_queue(), ^{
              NSLog(@"checkCommercialAbility error, code:%d, desc:%@", code, desc);
              if (fail) {
                  fail(code, desc);
              }
            });
          }];
    });
}

+ (UILabel *)messageLabelInAlertController:(UIAlertController *)alert {
    UIView *target = [TUITool targetSubviewInAlertController:alert];
    NSArray *subviews = [target subviews];
    if (subviews.count == 0) {
        return nil;
    }
    for (UIView *view in subviews) {
        if ([view isKindOfClass:UILabel.class]) {
            UILabel *label = (UILabel *)view;
            if (label.text.length > 10) {
                return label;
            }
        }
    }
    return nil;
}

+ (UIView *)targetSubviewInAlertController:(UIAlertController *)alert {
    UIView *view = alert.view;
    for (int i = 0; i < 5; i++) {
        view = view.subviews.firstObject;
    }
    return view;
}

+ (UIWindow *)applicationKeywindow {
    UIWindow *keywindow = UIApplication.sharedApplication.keyWindow;
    if (keywindow == nil) {
        if (@available(iOS 13.0, *)) {
            for (UIWindowScene *scene in UIApplication.sharedApplication.connectedScenes) {
                if (scene.activationState == UISceneActivationStateForegroundActive) {
                    UIWindow *tmpWindow = nil;
                    if (@available(iOS 15.0, *)) {
                        tmpWindow = scene.keyWindow;
                    }
                    if (tmpWindow == nil) {
                        for (UIWindow *window in scene.windows) {
                            if (window.windowLevel == UIWindowLevelNormal && window.hidden == NO &&
                                CGRectEqualToRect(window.bounds, UIScreen.mainScreen.bounds)) {
                                tmpWindow = window;
                                break;
                            }
                        }
                    }
                }
            }
        }
    }
    if (keywindow == nil) {
        for (UIWindow *window in UIApplication.sharedApplication.windows) {
            if (window.windowLevel == UIWindowLevelNormal && window.hidden == NO && CGRectEqualToRect(window.bounds, UIScreen.mainScreen.bounds)) {
                keywindow = window;
                break;
            }
        }
    }
    return keywindow;
}

@end
