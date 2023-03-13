//
//  THelper.m
//  TUIKit
//
//  Created by kennethmiao on 2018/11/1.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TUIDefine.h"
#import "TUILogin.h"
#import "UIView+TUIToast.h"
#import "TUIGlobalization.h"
#import <SDWebImage/SDImageCoderHelper.h>

@import ImSDK_Plus;

@implementation TUITool

+ (NSData *)dictionary2JsonData:(NSDictionary *)dict
{
    if ([NSJSONSerialization isValidJSONObject:dict])
    {
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
        if(error)
        {
            NSLog(@"[%@] Post Json Error", [self class]);
        }
        return data;
    }
    else
    {
        NSLog(@"[%@] Post Json is not valid", [self class]);
    }
    return nil;
}

+ (NSString *)dictionary2JsonStr:(NSDictionary *)dict {
    return [[NSString alloc] initWithData:[self dictionary2JsonData:dict] encoding:NSUTF8StringEncoding];;
}

+ (NSDictionary *)jsonSring2Dictionary:(NSString *)jsonString
{
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

+ (NSDictionary *)jsonData2Dictionary:(NSData *)jsonData
{
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

+ (void)asyncDecodeImage:(NSString *)path complete:(TAsyncImageComplete)complete
{
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
    
    if(path == nil){
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
            if (alphaInfo == kCGImageAlphaPremultipliedLast ||
                alphaInfo == kCGImageAlphaPremultipliedFirst ||
                alphaInfo == kCGImageAlphaLast ||
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


+ (void)makeToast:(NSString *)str
{
    if ([TUIConfig defaultConfig].enableToast) {
        [[UIApplication sharedApplication].keyWindow makeToast:str];
    }
}

+ (void)makeToast:(NSString *)str duration:(NSTimeInterval)duration {
    if ([TUIConfig defaultConfig].enableToast) {
        [[UIApplication sharedApplication].keyWindow makeToast:str duration:duration];
    }
}

+ (void)makeToast:(NSString *)str duration:(NSTimeInterval)duration position:(CGPoint)position
{
    if ([TUIConfig defaultConfig].enableToast) {
        [[UIApplication sharedApplication].keyWindow makeToast:str duration:duration position:[NSValue valueWithCGPoint:position]];
    }
}

+ (void)makeToast:(NSString *)str duration:(NSTimeInterval)duration idposition:(id)position
{
    if ([TUIConfig defaultConfig].enableToast) {
        [[UIApplication sharedApplication].keyWindow makeToast:str duration:duration position:position];
    }
}

+ (void)makeToastError:(NSInteger)error msg:(NSString *)msg
{
    if ([TUIConfig defaultConfig].enableToast) {
        [[UIApplication sharedApplication].keyWindow makeToast:[self convertIMError:error msg:msg]];
    }
}

+ (void)hideToast {
    if ([TUIConfig defaultConfig].enableToast) {
        [[UIApplication sharedApplication].keyWindow hideToast];
    }
}

+ (void)makeToastActivity
{
    if ([TUIConfig defaultConfig].enableToast) {
        [[UIApplication sharedApplication].keyWindow makeToastActivity:TUICSToastPositionCenter];
    }
}

+ (void)hideToastActivity
{
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
    NSString *identifer = [TUIGlobalization tk_localizableLanguageKey];
    dateFmt.locale = [NSLocale localeWithLocaleIdentifier:identifer];

    NSCalendar *calendar = [NSCalendar currentCalendar];
    calendar.firstWeekday = 7;
    NSDateComponents *nowComponent = [calendar components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear|NSCalendarUnitWeekOfMonth fromDate:NSDate.new];
    NSDateComponents *dateCompoent = [calendar components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear|NSCalendarUnitWeekOfMonth fromDate:date];
    
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

+ (NSString *)convertIMError:(NSInteger)code msg:(NSString *)msg{
    switch (code) {
        case ERR_IN_PROGESS:
            return TUIKitLocalizableString(TUIKitErrorInProcess);
        case ERR_INVALID_PARAMETERS:
            return TUIKitLocalizableString(TUIKitErrorInvalidParameters);
        case ERR_IO_OPERATION_FAILED:
            return TUIKitLocalizableString(TUIKitErrorIOOperateFaild);
        case ERR_INVALID_JSON:
            return TUIKitLocalizableString(TUIKitErrorInvalidJson);
        case ERR_OUT_OF_MEMORY:
            return TUIKitLocalizableString(TUIKitErrorOutOfMemory);
        case ERR_PARSE_RESPONSE_FAILED:
            return TUIKitLocalizableString(TUIKitErrorParseResponseFaild);
        case ERR_SERIALIZE_REQ_FAILED:
            return TUIKitLocalizableString(TUIKitErrorSerializeReqFaild);
        case ERR_SDK_NOT_INITIALIZED:
            return TUIKitLocalizableString(TUIKitErrorSDKNotInit);
        case ERR_LOADMSG_FAILED:
            return TUIKitLocalizableString(TUIKitErrorLoadMsgFailed);
        case ERR_DATABASE_OPERATE_FAILED:
            return TUIKitLocalizableString(TUIKitErrorDatabaseOperateFailed);
        case ERR_SDK_COMM_CROSS_THREAD:
            return TUIKitLocalizableString(TUIKitErrorCrossThread);
        case ERR_SDK_COMM_TINYID_EMPTY:
            return TUIKitLocalizableString(TUIKitErrorTinyIdEmpty);
        case ERR_SDK_COMM_INVALID_IDENTIFIER:
            return TUIKitLocalizableString(TUIKitErrorInvalidIdentifier);
        case ERR_SDK_COMM_FILE_NOT_FOUND:
            return TUIKitLocalizableString(TUIKitErrorFileNotFound);
        case ERR_SDK_COMM_FILE_TOO_LARGE:
            return TUIKitLocalizableString(TUIKitErrorFileTooLarge);
        case ERR_SDK_COMM_FILE_SIZE_EMPTY:
            return TUIKitLocalizableString(TUIKitErrorEmptyFile);
        case ERR_SDK_COMM_FILE_OPEN_FAILED:
            return TUIKitLocalizableString(TUIKitErrorFileOpenFailed);
        case ERR_SDK_INTERFACE_NOT_SUPPORT:
            return TUIKitLocalizableString(TUIKitErrorUnsupporInterface);

            // Account

        case ERR_SDK_NOT_LOGGED_IN:
            return TUIKitLocalizableString(TUIKitErrorNotLogin);
        case ERR_NO_PREVIOUS_LOGIN:
            return TUIKitLocalizableString(TUIKitErrorNoPreviousLogin);
        case ERR_USER_SIG_EXPIRED:
            return TUIKitLocalizableString(TUIKitErrorUserSigExpired);
        case ERR_LOGIN_KICKED_OFF_BY_OTHER:
            return TUIKitLocalizableString(TUIKitErrorLoginKickedOffByOther);
        case ERR_SDK_ACCOUNT_TLS_INIT_FAILED:
            return TUIKitLocalizableString(TUIKitErrorTLSSDKInit);
        case ERR_SDK_ACCOUNT_TLS_NOT_INITIALIZED:
            return TUIKitLocalizableString(TUIKitErrorTLSSDKUninit);
        case ERR_SDK_ACCOUNT_TLS_TRANSPKG_ERROR:
            return TUIKitLocalizableString(TUIKitErrorTLSSDKTRANSPackageFormat);
        case ERR_SDK_ACCOUNT_TLS_DECRYPT_FAILED:
            return TUIKitLocalizableString(TUIKitErrorTLSDecrypt);
        case ERR_SDK_ACCOUNT_TLS_REQUEST_FAILED:
            return TUIKitLocalizableString(TUIKitErrorTLSSDKRequest);
        case ERR_SDK_ACCOUNT_TLS_REQUEST_TIMEOUT:
            return TUIKitLocalizableString(TUIKitErrorTLSSDKRequestTimeout);

            // Message

        case ERR_INVALID_CONVERSATION:
            return TUIKitLocalizableString(TUIKitErrorInvalidConveration);
        case ERR_FILE_TRANS_AUTH_FAILED:
            return TUIKitLocalizableString(TUIKitErrorFileTransAuthFailed);
        case ERR_FILE_TRANS_NO_SERVER:
            return TUIKitLocalizableString(TUIKitErrorFileTransNoServer);
        case ERR_FILE_TRANS_UPLOAD_FAILED:
            return TUIKitLocalizableString(TUIKitErrorFileTransUploadFailed);
        case ERR_IMAGE_UPLOAD_FAILED_NOTIMAGE:
            return TUIKitLocalizableString(TUIKitErrorFileTransUploadFailedNotImage);
        case ERR_FILE_TRANS_DOWNLOAD_FAILED:
            return TUIKitLocalizableString(TUIKitErrorFileTransDownloadFailed);
        case ERR_HTTP_REQ_FAILED:
            return TUIKitLocalizableString(TUIKitErrorHTTPRequestFailed);
        case ERR_INVALID_MSG_ELEM:
            return TUIKitLocalizableString(TUIKitErrorInvalidMsgElem);
        case ERR_INVALID_SDK_OBJECT:
            return TUIKitLocalizableString(TUIKitErrorInvalidSDKObject);
        case ERR_SDK_MSG_BODY_SIZE_LIMIT:
            return TUIKitLocalizableString(TUIKitSDKMsgBodySizeLimit);
        case ERR_SDK_MSG_KEY_REQ_DIFFER_RSP:
            return TUIKitLocalizableString(TUIKitErrorSDKMsgKeyReqDifferRsp);

            // Group

        case ERR_SDK_GROUP_INVALID_ID:
            return TUIKitLocalizableString(TUIKitErrorSDKGroupInvalidID);
        case ERR_SDK_GROUP_INVALID_NAME:
            return TUIKitLocalizableString(TUIKitErrorSDKGroupInvalidName);
        case ERR_SDK_GROUP_INVALID_INTRODUCTION:
            return TUIKitLocalizableString(TUIKitErrorSDKGroupInvalidIntroduction);
        case ERR_SDK_GROUP_INVALID_NOTIFICATION:
            return TUIKitLocalizableString(TUIKitErrorSDKGroupInvalidNotification);
        case ERR_SDK_GROUP_INVALID_FACE_URL:
            return TUIKitLocalizableString(TUIKitErrorSDKGroupInvalidFaceURL);
        case ERR_SDK_GROUP_INVALID_NAME_CARD:
            return TUIKitLocalizableString(TUIKitErrorSDKGroupInvalidNameCard);
        case ERR_SDK_GROUP_MEMBER_COUNT_LIMIT:
            return TUIKitLocalizableString(TUIKitErrorSDKGroupMemberCountLimit);
        case ERR_SDK_GROUP_JOIN_PRIVATE_GROUP_DENY:
            return TUIKitLocalizableString(TUIKitErrorSDKGroupJoinPrivateGroupDeny);
        case ERR_SDK_GROUP_INVITE_SUPER_DENY:
            return TUIKitLocalizableString(TUIKitErrorSDKGroupInviteSuperDeny);
        case ERR_SDK_GROUP_INVITE_NO_MEMBER:
            return TUIKitLocalizableString(TUIKitErrorSDKGroupInviteNoMember);

            // Relationship

        case ERR_SDK_FRIENDSHIP_INVALID_PROFILE_KEY:
            return TUIKitLocalizableString(TUIKitErrorSDKFriendShipInvalidProfileKey);
        case ERR_SDK_FRIENDSHIP_INVALID_ADD_REMARK:
            return TUIKitLocalizableString(TUIKitErrorSDKFriendshipInvalidAddRemark);
        case ERR_SDK_FRIENDSHIP_INVALID_ADD_WORDING:
            return TUIKitLocalizableString(TUIKitErrorSDKFriendshipInvalidAddWording);
        case ERR_SDK_FRIENDSHIP_INVALID_ADD_SOURCE:
            return TUIKitLocalizableString(TUIKitErrorSDKFriendshipInvalidAddSource);
        case ERR_SDK_FRIENDSHIP_FRIEND_GROUP_EMPTY:
            return TUIKitLocalizableString(TUIKitErrorSDKFriendshipFriendGroupEmpty);

            // Network

        case ERR_SDK_NET_ENCODE_FAILED:
            return TUIKitLocalizableString(TUIKitErrorSDKNetEncodeFailed);
        case ERR_SDK_NET_DECODE_FAILED:
            return TUIKitLocalizableString(TUIKitErrorSDKNetDecodeFailed);
        case ERR_SDK_NET_AUTH_INVALID:
            return TUIKitLocalizableString(TUIKitErrorSDKNetAuthInvalid);
        case ERR_SDK_NET_COMPRESS_FAILED:
            return TUIKitLocalizableString(TUIKitErrorSDKNetCompressFailed);
        case ERR_SDK_NET_UNCOMPRESS_FAILED:
            return TUIKitLocalizableString(TUIKitErrorSDKNetUncompressFaile);
        case ERR_SDK_NET_FREQ_LIMIT:
            return TUIKitLocalizableString(TUIKitErrorSDKNetFreqLimit);
        case ERR_SDK_NET_REQ_COUNT_LIMIT:
            return TUIKitLocalizableString(TUIKitErrorSDKnetReqCountLimit);
        case ERR_SDK_NET_DISCONNECT:
            return TUIKitLocalizableString(TUIKitErrorSDKNetDisconnect);
        case ERR_SDK_NET_ALLREADY_CONN:
            return TUIKitLocalizableString(TUIKitErrorSDKNetAllreadyConn);
        case ERR_SDK_NET_CONN_TIMEOUT:
            return TUIKitLocalizableString(TUIKitErrorSDKNetConnTimeout);
        case ERR_SDK_NET_CONN_REFUSE:
            return TUIKitLocalizableString(TUIKitErrorSDKNetConnRefuse);
        case ERR_SDK_NET_NET_UNREACH:
            return TUIKitLocalizableString(TUIKitErrorSDKNetNetUnreach);
        case ERR_SDK_NET_SOCKET_NO_BUFF:
            return TUIKitLocalizableString(TUIKitErrorSDKNetSocketNoBuff);
        case ERR_SDK_NET_RESET_BY_PEER:
            return TUIKitLocalizableString(TUIKitERRORSDKNetResetByPeer);
        case ERR_SDK_NET_SOCKET_INVALID:
            return TUIKitLocalizableString(TUIKitErrorSDKNetSOcketInvalid);
        case ERR_SDK_NET_HOST_GETADDRINFO_FAILED:
            return TUIKitLocalizableString(TUIKitErrorSDKNetHostGetAddressFailed);
        case ERR_SDK_NET_CONNECT_RESET:
            return TUIKitLocalizableString(TUIKitErrorSDKNetConnectReset);
        case ERR_SDK_NET_WAIT_INQUEUE_TIMEOUT:
            return TUIKitLocalizableString(TUIKitErrorSDKNetWaitInQueueTimeout);
        case ERR_SDK_NET_WAIT_SEND_TIMEOUT:
            return TUIKitLocalizableString(TUIKitErrorSDKNetWaitSendTimeout);
        case ERR_SDK_NET_WAIT_ACK_TIMEOUT:
            return TUIKitLocalizableString(TUIKitErrorSDKNetWaitAckTimeut);

            /////////////////////////////////////////////////////////////////////////////////
            //
            //                      （二）Server
            //
            /////////////////////////////////////////////////////////////////////////////////

            // SSO

        case ERR_SVR_SSO_CONNECT_LIMIT:
            return TUIKitLocalizableString(TUIKitErrorSDKSVRSSOConnectLimit);
        case ERR_SVR_SSO_VCODE:
            return TUIKitLocalizableString(TUIKitErrorSDKSVRSSOVCode);
        case ERR_SVR_SSO_D2_EXPIRED:
            return TUIKitLocalizableString(TUIKitErrorSVRSSOD2Expired);
        case ERR_SVR_SSO_A2_UP_INVALID:
            return TUIKitLocalizableString(TUIKitErrorSVRA2UpInvalid);
        case ERR_SVR_SSO_A2_DOWN_INVALID:
            return TUIKitLocalizableString(TUIKitErrorSVRA2DownInvalid);
        case ERR_SVR_SSO_EMPTY_KEY:
            return TUIKitLocalizableString(TUIKitErrorSVRSSOEmpeyKey);
        case ERR_SVR_SSO_UIN_INVALID:
            return TUIKitLocalizableString(TUIKitErrorSVRSSOUinInvalid);
        case ERR_SVR_SSO_VCODE_TIMEOUT:
            return TUIKitLocalizableString(TUIKitErrorSVRSSOVCodeTimeout);
        case ERR_SVR_SSO_NO_IMEI_AND_A2:
            return TUIKitLocalizableString(TUIKitErrorSVRSSONoImeiAndA2);
        case ERR_SVR_SSO_COOKIE_INVALID:
            return TUIKitLocalizableString(TUIKitErrorSVRSSOCookieInvalid);
        case ERR_SVR_SSO_DOWN_TIP:
            return TUIKitLocalizableString(TUIKitErrorSVRSSODownTips);
        case ERR_SVR_SSO_DISCONNECT:
            return TUIKitLocalizableString(TUIKitErrorSVRSSODisconnect);
        case ERR_SVR_SSO_IDENTIFIER_INVALID:
            return TUIKitLocalizableString(TUIKitErrorSVRSSOIdentifierInvalid);
        case ERR_SVR_SSO_CLIENT_CLOSE:
            return TUIKitLocalizableString(TUIKitErrorSVRSSOClientClose);
        case ERR_SVR_SSO_MSFSDK_QUIT:
            return TUIKitLocalizableString(TUIKitErrorSVRSSOMSFSDKQuit);
        case ERR_SVR_SSO_D2KEY_WRONG:
            return TUIKitLocalizableString(TUIKitErrorSVRSSOD2KeyWrong);
        case ERR_SVR_SSO_UNSURPPORT:
            return TUIKitLocalizableString(TUIKitErrorSVRSSOUnsupport);
        case ERR_SVR_SSO_PREPAID_ARREARS:
            return TUIKitLocalizableString(TUIKitErrorSVRSSOPrepaidArrears);
        case ERR_SVR_SSO_PACKET_WRONG:
            return TUIKitLocalizableString(TUIKitErrorSVRSSOPacketWrong);
        case ERR_SVR_SSO_APPID_BLACK_LIST:
            return TUIKitLocalizableString(TUIKitErrorSVRSSOAppidBlackList);
        case ERR_SVR_SSO_CMD_BLACK_LIST:
            return TUIKitLocalizableString(TUIKitErrorSVRSSOCmdBlackList);
        case ERR_SVR_SSO_APPID_WITHOUT_USING:
            return TUIKitLocalizableString(TUIKitErrorSVRSSOAppidWithoutUsing);
        case ERR_SVR_SSO_FREQ_LIMIT:
            return TUIKitLocalizableString(TUIKitErrorSVRSSOFreqLimit);
        case ERR_SVR_SSO_OVERLOAD:
            return TUIKitLocalizableString(TUIKitErrorSVRSSOOverload);

            // Resource

        case ERR_SVR_RES_NOT_FOUND:
            return TUIKitLocalizableString(TUIKitErrorSVRResNotFound);
        case ERR_SVR_RES_ACCESS_DENY:
            return TUIKitLocalizableString(TUIKitErrorSVRResAccessDeny);
        case ERR_SVR_RES_SIZE_LIMIT:
            return TUIKitLocalizableString(TUIKitErrorSVRResSizeLimit);
        case ERR_SVR_RES_SEND_CANCEL:
            return TUIKitLocalizableString(TUIKitErrorSVRResSendCancel);
        case ERR_SVR_RES_READ_FAILED:
            return TUIKitLocalizableString(TUIKitErrorSVRResReadFailed);
        case ERR_SVR_RES_TRANSFER_TIMEOUT:
            return TUIKitLocalizableString(TUIKitErrorSVRResTransferTimeout);
        case ERR_SVR_RES_INVALID_PARAMETERS:
            return TUIKitLocalizableString(TUIKitErrorSVRResInvalidParameters);
        case ERR_SVR_RES_INVALID_FILE_MD5:
            return TUIKitLocalizableString(TUIKitErrorSVRResInvalidFileMd5);
        case ERR_SVR_RES_INVALID_PART_MD5:
            return TUIKitLocalizableString(TUIKitErrorSVRResInvalidPartMd5);

            // Common

        case ERR_SVR_COMM_INVALID_HTTP_URL:
            return TUIKitLocalizableString(TUIKitErrorSVRCommonInvalidHttpUrl);
        case ERR_SVR_COMM_REQ_JSON_PARSE_FAILED:
            return TUIKitLocalizableString(TUIKitErrorSVRCommomReqJsonParseFailed);
        case ERR_SVR_COMM_INVALID_ACCOUNT:
            return TUIKitLocalizableString(TUIKitErrorSVRCommonInvalidAccount);
        case ERR_SVR_COMM_INVALID_ACCOUNT_EX:
            return TUIKitLocalizableString(TUIKitErrorSVRCommonInvalidAccount);
        case ERR_SVR_COMM_INVALID_SDKAPPID:
            return TUIKitLocalizableString(TUIKitErrorSVRCommonInvalidSdkappid);
        case ERR_SVR_COMM_REST_FREQ_LIMIT:
            return TUIKitLocalizableString(TUIKitErrorSVRCommonRestFreqLimit);
        case ERR_SVR_COMM_REQUEST_TIMEOUT:
            return TUIKitLocalizableString(TUIKitErrorSVRCommonRequestTimeout);
        case ERR_SVR_COMM_INVALID_RES:
            return TUIKitLocalizableString(TUIKitErrorSVRCommonInvalidRes);
        case ERR_SVR_COMM_ID_NOT_ADMIN:
            return TUIKitLocalizableString(TUIKitErrorSVRCommonIDNotAdmin);
        case ERR_SVR_COMM_SDKAPPID_FREQ_LIMIT:
            return TUIKitLocalizableString(TUIKitErrorSVRCommonSdkappidFreqLimit);
        case ERR_SVR_COMM_SDKAPPID_MISS:
            return TUIKitLocalizableString(TUIKitErrorSVRCommonSdkappidMiss);
        case ERR_SVR_COMM_RSP_JSON_PARSE_FAILED:
            return TUIKitLocalizableString(TUIKitErrorSVRCommonRspJsonParseFailed);
        case ERR_SVR_COMM_EXCHANGE_ACCOUNT_TIMEUT:
            return TUIKitLocalizableString(TUIKitErrorSVRCommonExchangeAccountTimeout);
        case ERR_SVR_COMM_INVALID_ID_FORMAT:
            return TUIKitLocalizableString(TUIKitErrorSVRCommonInvalidIdFormat);
        case ERR_SVR_COMM_SDKAPPID_FORBIDDEN:
            return TUIKitLocalizableString(TUIKitErrorSVRCommonSDkappidForbidden);
        case ERR_SVR_COMM_REQ_FORBIDDEN:
            return TUIKitLocalizableString(TUIKitErrorSVRCommonReqForbidden);
        case ERR_SVR_COMM_REQ_FREQ_LIMIT:
            return TUIKitLocalizableString(TUIKitErrorSVRCommonReqFreqLimit);
        case ERR_SVR_COMM_REQ_FREQ_LIMIT_EX:
            return TUIKitLocalizableString(TUIKitErrorSVRCommonReqFreqLimit);
        case ERR_SVR_COMM_INVALID_SERVICE:
            return TUIKitLocalizableString(TUIKitErrorSVRCommonInvalidService);
        case ERR_SVR_COMM_SENSITIVE_TEXT:
            return TUIKitLocalizableString(TUIKitErrorSVRCommonSensitiveText);
        case ERR_SVR_COMM_BODY_SIZE_LIMIT:
            return TUIKitLocalizableString(TUIKitErrorSVRCommonBodySizeLimit);

            // Account

        case ERR_SVR_ACCOUNT_USERSIG_EXPIRED:
            return TUIKitLocalizableString(TUIKitErrorSVRAccountUserSigExpired);
        case ERR_SVR_ACCOUNT_USERSIG_EMPTY:
            return TUIKitLocalizableString(TUIKitErrorSVRAccountUserSigEmpty);
        case ERR_SVR_ACCOUNT_USERSIG_CHECK_FAILED:
            return TUIKitLocalizableString(TUIKitErrorSVRAccountUserSigCheckFailed);
        case ERR_SVR_ACCOUNT_USERSIG_CHECK_FAILED_EX:
            return TUIKitLocalizableString(TUIKitErrorSVRAccountUserSigCheckFailed);
        case ERR_SVR_ACCOUNT_USERSIG_MISMATCH_PUBLICKEY:
            return TUIKitLocalizableString(TUIKitErrorSVRAccountUserSigMismatchPublicKey);
        case ERR_SVR_ACCOUNT_USERSIG_MISMATCH_ID:
            return TUIKitLocalizableString(TUIKitErrorSVRAccountUserSigMismatchId);
        case ERR_SVR_ACCOUNT_USERSIG_MISMATCH_SDKAPPID:
            return TUIKitLocalizableString(TUIKitErrorSVRAccountUserSigMismatchSdkAppid);
        case ERR_SVR_ACCOUNT_USERSIG_PUBLICKEY_NOT_FOUND:
            return TUIKitLocalizableString(TUIKitErrorSVRAccountUserSigPublicKeyNotFound);
        case ERR_SVR_ACCOUNT_SDKAPPID_NOT_FOUND:
            return TUIKitLocalizableString(TUIKitErrorSVRAccountUserSigSdkAppidNotFount);
        case ERR_SVR_ACCOUNT_INVALID_USERSIG:
            return TUIKitLocalizableString(TUIKitErrorSVRAccountInvalidUserSig);
        case ERR_SVR_ACCOUNT_NOT_FOUND:
            return TUIKitLocalizableString(TUIKitErrorSVRAccountNotFound);
        case ERR_SVR_ACCOUNT_SEC_RSTR:
            return TUIKitLocalizableString(TUIKitErrorSVRAccountSecRstr);
        case ERR_SVR_ACCOUNT_INTERNAL_TIMEOUT:
            return TUIKitLocalizableString(TUIKitErrorSVRAccountInternalTimeout);
        case ERR_SVR_ACCOUNT_INVALID_COUNT:
            return TUIKitLocalizableString(TUIKitErrorSVRAccountInvalidCount);
        case ERR_SVR_ACCOUNT_INVALID_PARAMETERS:
            return TUIKitLocalizableString(TUIkitErrorSVRAccountINvalidParameters);
        case ERR_SVR_ACCOUNT_ADMIN_REQUIRED:
            return TUIKitLocalizableString(TUIKitErrorSVRAccountAdminRequired);
        case ERR_SVR_ACCOUNT_FREQ_LIMIT:
            return TUIKitLocalizableString(TUIKitErrorSVRAccountFreqLimit);
        case ERR_SVR_ACCOUNT_BLACKLIST:
            return TUIKitLocalizableString(TUIKitErrorSVRAccountBlackList);
        case ERR_SVR_ACCOUNT_COUNT_LIMIT:
            return TUIKitLocalizableString(TUIKitErrorSVRAccountCountLimit);
        case ERR_SVR_ACCOUNT_INTERNAL_ERROR:
            return TUIKitLocalizableString(TUIKitErrorSVRAccountInternalError);
        case ERR_SVR_ACCOUNT_USER_STATUS_DISABLED:
            return TUIKitLocalizableString(TUIKitErrorEnableUserStatusOnConsole);

            // Profile

        case ERR_SVR_PROFILE_INVALID_PARAMETERS:
            return TUIKitLocalizableString(TUIKitErrorSVRProfileInvalidParameters);
        case ERR_SVR_PROFILE_ACCOUNT_MISS:
            return TUIKitLocalizableString(TUIKitErrorSVRProfileAccountMiss);
        case ERR_SVR_PROFILE_ACCOUNT_NOT_FOUND:
            return TUIKitLocalizableString(TUIKitErrorSVRProfileAccountNotFound);
        case ERR_SVR_PROFILE_ADMIN_REQUIRED:
            return TUIKitLocalizableString(TUIKitErrorSVRProfileAdminRequired);
        case ERR_SVR_PROFILE_SENSITIVE_TEXT:
            return TUIKitLocalizableString(TUIKitErrorSVRProfileSensitiveText);
        case ERR_SVR_PROFILE_INTERNAL_ERROR:
            return TUIKitLocalizableString(TUIKitErrorSVRProfileInternalError);
        case ERR_SVR_PROFILE_READ_PERMISSION_REQUIRED:
            return TUIKitLocalizableString(TUIKitErrorSVRProfileReadWritePermissionRequired);
        case ERR_SVR_PROFILE_WRITE_PERMISSION_REQUIRED:
            return TUIKitLocalizableString(TUIKitErrorSVRProfileReadWritePermissionRequired);
        case ERR_SVR_PROFILE_TAG_NOT_FOUND:
            return TUIKitLocalizableString(TUIKitErrorSVRProfileTagNotFound);
        case ERR_SVR_PROFILE_SIZE_LIMIT:
            return TUIKitLocalizableString(TUIKitErrorSVRProfileSizeLimit);
        case ERR_SVR_PROFILE_VALUE_ERROR:
            return TUIKitLocalizableString(TUIKitErrorSVRProfileValueError);
        case ERR_SVR_PROFILE_INVALID_VALUE_FORMAT:
            return TUIKitLocalizableString(TUIKitErrorSVRProfileInvalidValueFormat);

            // FRIENDSHIP

        case ERR_SVR_FRIENDSHIP_INVALID_PARAMETERS:
            return TUIKitLocalizableString(TUIKitErrorSVRFriendshipInvalidParameters);
        case ERR_SVR_FRIENDSHIP_INVALID_SDKAPPID:
            return TUIKitLocalizableString(TUIKitErrorSVRFriendshipInvalidSdkAppid);
        case ERR_SVR_FRIENDSHIP_ACCOUNT_NOT_FOUND:
            return TUIKitLocalizableString(TUIKitErrorSVRFriendshipAccountNotFound);
        case ERR_SVR_FRIENDSHIP_ADMIN_REQUIRED:
            return TUIKitLocalizableString(TUIKitErrorSVRFriendshipAdminRequired);
        case ERR_SVR_FRIENDSHIP_SENSITIVE_TEXT:
            return TUIKitLocalizableString(TUIKitErrorSVRFriendshipSensitiveText);
        case ERR_SVR_FRIENDSHIP_INTERNAL_ERROR:
            return TUIKitLocalizableString(TUIKitErrorSVRAccountInternalError);
        case ERR_SVR_FRIENDSHIP_NET_TIMEOUT:
            return TUIKitLocalizableString(TUIKitErrorSVRFriendshipNetTimeout);
        case ERR_SVR_FRIENDSHIP_WRITE_CONFLICT:
            return TUIKitLocalizableString(TUIKitErrorSVRFriendshipWriteConflict);
        case ERR_SVR_FRIENDSHIP_ADD_FRIEND_DENY:
            return TUIKitLocalizableString(TUIKitErrorSVRFriendshipAddFriendDeny);
        case ERR_SVR_FRIENDSHIP_COUNT_LIMIT:
            return TUIKitLocalizableString(TUIkitErrorSVRFriendshipCountLimit);
        case ERR_SVR_FRIENDSHIP_GROUP_COUNT_LIMIT:
            return TUIKitLocalizableString(TUIKitErrorSVRFriendshipGroupCountLimit);
        case ERR_SVR_FRIENDSHIP_PENDENCY_LIMIT:
            return TUIKitLocalizableString(TUIKitErrorSVRFriendshipPendencyLimit);
        case ERR_SVR_FRIENDSHIP_BLACKLIST_LIMIT:
            return TUIKitLocalizableString(TUIKitErrorSVRFriendshipBlacklistLimit);
        case ERR_SVR_FRIENDSHIP_PEER_FRIEND_LIMIT:
            return TUIKitLocalizableString(TUIKitErrorSVRFriendshipPeerFriendLimit);
        case ERR_SVR_FRIENDSHIP_IN_SELF_BLACKLIST:
            return TUIKitLocalizableString(TUIKitErrorSVRFriendshipInSelfBlacklist);
        case ERR_SVR_FRIENDSHIP_ALLOW_TYPE_DENY_ANY:
            return TUIKitLocalizableString(TUIKitErrorSVRFriendshipAllowTypeDenyAny);
        case ERR_SVR_FRIENDSHIP_IN_PEER_BLACKLIST:
            return TUIKitLocalizableString(TUIKitErrorSVRFriendshipInPeerBlackList);
        case ERR_SVR_FRIENDSHIP_ALLOW_TYPE_NEED_CONFIRM:
            return TUIKitLocalizableString(TUIKitErrorSVRFriendshipAllowTypeNeedConfirm);
        case ERR_SVR_FRIENDSHIP_ADD_FRIEND_SEC_RSTR:
            return TUIKitLocalizableString(TUIKitErrorSVRFriendshipAddFriendSecRstr);
        case ERR_SVR_FRIENDSHIP_PENDENCY_NOT_FOUND:
            return TUIKitLocalizableString(TUIKitErrorSVRFriendshipPendencyNotFound);
        case ERR_SVR_FRIENDSHIP_DEL_FRIEND_SEC_RSTR:
            return TUIKitLocalizableString(TUIKitErrorSVRFriendshipDelFriendSecRstr);
        case ERR_SVR_FRIENDSHIP_ACCOUNT_NOT_FOUND_EX:
            return TUIKitLocalizableString(TUIKirErrorSVRFriendAccountNotFoundEx);

            // Conversation

        case ERR_SVR_CONV_ACCOUNT_NOT_FOUND:
            return TUIKitLocalizableString(TUIKirErrorSVRFriendAccountNotFoundEx);
        case ERR_SVR_CONV_INVALID_PARAMETERS:
            return TUIKitLocalizableString(TUIKitErrorSVRFriendshipInvalidParameters);
        case ERR_SVR_CONV_ADMIN_REQUIRED:
            return TUIKitLocalizableString(TUIKitErrorSVRFriendshipAdminRequired);
        case ERR_SVR_CONV_INTERNAL_ERROR:
            return TUIKitLocalizableString(TUIKitErrorSVRAccountInternalError);
        case ERR_SVR_CONV_NET_TIMEOUT:
            return TUIKitLocalizableString(TUIKitErrorSVRFriendshipNetTimeout);

            // Message

        case ERR_SVR_MSG_PKG_PARSE_FAILED:
            return TUIKitLocalizableString(TUIKitErrorSVRMsgPkgParseFailed);
        case ERR_SVR_MSG_INTERNAL_AUTH_FAILED:
            return TUIKitLocalizableString(TUIKitErrorSVRMsgInternalAuthFailed);
        case ERR_SVR_MSG_INVALID_ID:
            return TUIKitLocalizableString(TUIKitErrorSVRMsgInvalidId);
        case ERR_SVR_MSG_NET_ERROR:
            return TUIKitLocalizableString(TUIKitErrorSVRMsgNetError);
        case ERR_SVR_MSG_INTERNAL_ERROR1:
            return TUIKitLocalizableString(TUIKitErrorSVRAccountInternalError);
        case ERR_SVR_MSG_PUSH_DENY:
            return TUIKitLocalizableString(TUIKitErrorSVRMsgPushDeny);
        case ERR_SVR_MSG_IN_PEER_BLACKLIST:
            return TUIKitLocalizableString(TUIKitErrorSVRMsgInPeerBlackList);
        case ERR_SVR_MSG_BOTH_NOT_FRIEND:
            return TUIKitLocalizableString(TUIKitErrorSVRMsgBothNotFriend);
        case ERR_SVR_MSG_NOT_PEER_FRIEND:
            return TUIKitLocalizableString(TUIKitErrorSVRMsgNotPeerFriend);
        case ERR_SVR_MSG_NOT_SELF_FRIEND:
            return TUIKitLocalizableString(TUIkitErrorSVRMsgNotSelfFriend);
        case ERR_SVR_MSG_SHUTUP_DENY:
            return TUIKitLocalizableString(TUIKitErrorSVRMsgShutupDeny);
        case ERR_SVR_MSG_REVOKE_TIME_LIMIT:
            return TUIKitLocalizableString(TUIKitErrorSVRMsgRevokeTimeLimit);
        case ERR_SVR_MSG_DEL_RAMBLE_INTERNAL_ERROR:
            return TUIKitLocalizableString(TUIKitErrorSVRMsgDelRambleInternalError);
        case ERR_SVR_MSG_JSON_PARSE_FAILED:
            return TUIKitLocalizableString(TUIKitErrorSVRMsgJsonParseFailed);
        case ERR_SVR_MSG_INVALID_JSON_BODY_FORMAT:
            return TUIKitLocalizableString(TUIKitErrorSVRMsgInvalidJsonBodyFormat);
        case ERR_SVR_MSG_INVALID_TO_ACCOUNT:
            return TUIKitLocalizableString(TUIKitErrorSVRMsgInvalidToAccount);
        case ERR_SVR_MSG_INVALID_RAND:
            return TUIKitLocalizableString(TUIKitErrorSVRMsgInvalidRand);
        case ERR_SVR_MSG_INVALID_TIMESTAMP:
            return TUIKitLocalizableString(TUIKitErrorSVRMsgInvalidTimestamp);
        case ERR_SVR_MSG_BODY_NOT_ARRAY:
            return TUIKitLocalizableString(TUIKitErrorSVRMsgBodyNotArray);
        case ERR_SVR_MSG_ADMIN_REQUIRED:
            return TUIKitLocalizableString(TUIKitErrorSVRAccountAdminRequired);
        case ERR_SVR_MSG_INVALID_JSON_FORMAT:
            return TUIKitLocalizableString(TUIKitErrorSVRMsgInvalidJsonFormat);
        case ERR_SVR_MSG_TO_ACCOUNT_COUNT_LIMIT:
            return TUIKitLocalizableString(TUIKitErrorSVRMsgToAccountCountLimit);
        case ERR_SVR_MSG_TO_ACCOUNT_NOT_FOUND:
            return TUIKitLocalizableString(TUIKitErrorSVRMsgToAccountNotFound);
        case ERR_SVR_MSG_TIME_LIMIT:
            return TUIKitLocalizableString(TUIKitErrorSVRMsgTimeLimit);
        case ERR_SVR_MSG_INVALID_SYNCOTHERMACHINE:
            return TUIKitLocalizableString(TUIKitErrorSVRMsgInvalidSyncOtherMachine);
        case ERR_SVR_MSG_INVALID_MSGLIFETIME:
            return TUIKitLocalizableString(TUIkitErrorSVRMsgInvalidMsgLifeTime);
        case ERR_SVR_MSG_ACCOUNT_NOT_FOUND:
            return TUIKitLocalizableString(TUIKirErrorSVRFriendAccountNotFoundEx);
        case ERR_SVR_MSG_INTERNAL_ERROR2:
            return TUIKitLocalizableString(TUIKitErrorSVRAccountInternalError);
        case ERR_SVR_MSG_INTERNAL_ERROR3:
            return TUIKitLocalizableString(TUIKitErrorSVRAccountInternalError);
        case ERR_SVR_MSG_INTERNAL_ERROR4:
            return TUIKitLocalizableString(TUIKitErrorSVRAccountInternalError);
        case ERR_SVR_MSG_INTERNAL_ERROR5:
            return TUIKitLocalizableString(TUIKitErrorSVRAccountInternalError);
        case ERR_SVR_MSG_BODY_SIZE_LIMIT:
            return TUIKitLocalizableString(TUIKitErrorSVRMsgBodySizeLimit);
        case ERR_SVR_MSG_LONGPOLLING_COUNT_LIMIT:
            return TUIKitLocalizableString(TUIKitErrorSVRmsgLongPollingCountLimit);


            // Group

        case ERR_SVR_GROUP_INTERNAL_ERROR:
            return TUIKitLocalizableString(TUIKitErrorSVRAccountInternalError);
        case ERR_SVR_GROUP_API_NAME_ERROR:
            return TUIKitLocalizableString(TUIKitErrorSVRGroupApiNameError);
        case ERR_SVR_GROUP_INVALID_PARAMETERS:
            return TUIKitLocalizableString(TUIKitErrorSVRResInvalidParameters);
        case ERR_SVR_GROUP_ACOUNT_COUNT_LIMIT:
            return TUIKitLocalizableString(TUIKitErrorSVRGroupAccountCountLimit);
        case ERR_SVR_GROUP_FREQ_LIMIT:
            return TUIKitLocalizableString(TUIkitErrorSVRGroupFreqLimit);
        case ERR_SVR_GROUP_PERMISSION_DENY:
            return TUIKitLocalizableString(TUIKitErrorSVRGroupPermissionDeny);
        case ERR_SVR_GROUP_INVALID_REQ:
            return TUIKitLocalizableString(TUIKitErrorSVRGroupInvalidReq);
        case ERR_SVR_GROUP_SUPER_NOT_ALLOW_QUIT:
            return TUIKitLocalizableString(TUIKitErrorSVRGroupSuperNotAllowQuit);
        case ERR_SVR_GROUP_NOT_FOUND:
            return TUIKitLocalizableString(TUIKitErrorSVRGroupNotFound);
        case ERR_SVR_GROUP_JSON_PARSE_FAILED:
            return TUIKitLocalizableString(TUIKitErrorSVRGroupJsonParseFailed);
        case ERR_SVR_GROUP_INVALID_ID:
            return TUIKitLocalizableString(TUIKitErrorSVRGroupInvalidId);
        case ERR_SVR_GROUP_ALLREADY_MEMBER:
            return TUIKitLocalizableString(TUIKitErrorSVRGroupAllreadyMember);
        case ERR_SVR_GROUP_FULL_MEMBER_COUNT:
            return TUIKitLocalizableString(TUIKitErrorSVRGroupFullMemberCount);
        case ERR_SVR_GROUP_INVALID_GROUPID:
            return TUIKitLocalizableString(TUIKitErrorSVRGroupInvalidGroupId);
        case ERR_SVR_GROUP_REJECT_FROM_THIRDPARTY:
            return TUIKitLocalizableString(TUIKitErrorSVRGroupRejectFromThirdParty);
        case ERR_SVR_GROUP_SHUTUP_DENY:
            return TUIKitLocalizableString(TUIKitErrorSVRGroupShutDeny);
        case ERR_SVR_GROUP_RSP_SIZE_LIMIT:
            return TUIKitLocalizableString(TUIKitErrorSVRGroupRspSizeLimit);
        case ERR_SVR_GROUP_ACCOUNT_NOT_FOUND:
            return TUIKitLocalizableString(TUIKitErrorSVRGroupAccountNotFound);
        case ERR_SVR_GROUP_GROUPID_IN_USED:
            return TUIKitLocalizableString(TUIKitErrorSVRGroupGroupIdInUse);
        case ERR_SVR_GROUP_SEND_MSG_FREQ_LIMIT:
            return TUIKitLocalizableString(TUIKitErrorSVRGroupSendMsgFreqLimit);
        case ERR_SVR_GROUP_REQ_ALLREADY_BEEN_PROCESSED:
            return TUIKitLocalizableString(TUIKitErrorSVRGroupReqAllreadyBeenProcessed);
        case ERR_SVR_GROUP_GROUPID_IN_USED_FOR_SUPER:
            return TUIKitLocalizableString(TUIKitErrorSVRGroupGroupIdUserdForSuper);
        case ERR_SVR_GROUP_SDKAPPID_DENY:
            return TUIKitLocalizableString(TUIKitErrorSVRGroupSDkAppidDeny);
        case ERR_SVR_GROUP_REVOKE_MSG_NOT_FOUND:
            return TUIKitLocalizableString(TUIKitErrorSVRGroupRevokeMsgNotFound);
        case ERR_SVR_GROUP_REVOKE_MSG_TIME_LIMIT:
            return TUIKitLocalizableString(TUIKitErrorSVRGroupRevokeMsgTimeLimit);
        case ERR_SVR_GROUP_REVOKE_MSG_DENY:
            return TUIKitLocalizableString(TUIKitErrorSVRGroupRevokeMsgDeny);
        case ERR_SVR_GROUP_NOT_ALLOW_REVOKE_MSG:
            return TUIKitLocalizableString(TUIKitErrorSVRGroupNotAllowRevokeMsg);
        case ERR_SVR_GROUP_REMOVE_MSG_DENY:
            return TUIKitLocalizableString(TUIKitErrorSVRGroupRemoveMsgDeny);
        case ERR_SVR_GROUP_NOT_ALLOW_REMOVE_MSG:
            return TUIKitLocalizableString(TUIKitErrorSVRGroupNotAllowRemoveMsg);
        case ERR_SVR_GROUP_AVCHATROOM_COUNT_LIMIT:
            return TUIKitLocalizableString(TUIKitErrorSVRGroupAvchatRoomCountLimit);
        case ERR_SVR_GROUP_COUNT_LIMIT:
            return TUIKitLocalizableString(TUIKitErrorSVRGroupCountLimit);
        case ERR_SVR_GROUP_MEMBER_COUNT_LIMIT:
            return TUIKitLocalizableString(TUIKitErrorSVRGroupMemberCountLimit);

            /////////////////////////////////////////////////////////////////////////////////
            //
            //                      （三）Version 3 deprecated
            //
            /////////////////////////////////////////////////////////////////////////////////

        case ERR_NO_SUCC_RESULT:
            return TUIKitLocalizableString(TUIKitErrorSVRNoSuccessResult);
        case ERR_TO_USER_INVALID:
            return TUIKitLocalizableString(TUIKitErrorSVRToUserInvalid);
        case ERR_INIT_CORE_FAIL:
            return TUIKitLocalizableString(TUIKitErrorSVRInitCoreFail);
        case ERR_EXPIRED_SESSION_NODE:
            return TUIKitLocalizableString(TUIKitErrorExpiredSessionNode);
        case ERR_LOGGED_OUT_BEFORE_LOGIN_FINISHED:
            return TUIKitLocalizableString(TUIKitErrorLoggedOutBeforeLoginFinished);
        case ERR_TLSSDK_NOT_INITIALIZED:
            return TUIKitLocalizableString(TUIKitErrorTLSSDKNotInitialized);
        case ERR_TLSSDK_USER_NOT_FOUND:
            return TUIKitLocalizableString(TUIKitErrorTLSSDKUserNotFound);
        case ERR_BIND_FAIL_REG_TIMEOUT:
            return TUIKitLocalizableString(TUIKitErrorBindFaildRegTimeout);
        case ERR_BIND_FAIL_ISBINDING:
            return TUIKitLocalizableString(TUIKitErrorBindFaildIsBinding);
        case ERR_PACKET_FAIL_UNKNOWN:
            return TUIKitLocalizableString(TUIKitErrorPacketFailUnknown);
        case ERR_PACKET_FAIL_REQ_NO_NET:
            return TUIKitLocalizableString(TUIKitErrorPacketFailReqNoNet);
        case ERR_PACKET_FAIL_RESP_NO_NET:
            return TUIKitLocalizableString(TUIKitErrorPacketFailRespNoNet);
        case ERR_PACKET_FAIL_REQ_NO_AUTH:
            return TUIKitLocalizableString(TUIKitErrorPacketFailReqNoAuth);
        case ERR_PACKET_FAIL_SSO_ERR:
            return TUIKitLocalizableString(TUIKitErrorPacketFailSSOErr);
        case ERR_PACKET_FAIL_REQ_TIMEOUT:
            return TUIKitLocalizableString(TUIKitErrorSVRRequestTimeout);
        case ERR_PACKET_FAIL_RESP_TIMEOUT:
            return TUIKitLocalizableString(TUIKitErrorPacketFailRespTimeout);

            // case ERR_PACKET_FAIL_REQ_ON_RESEND:
            // case ERR_PACKET_FAIL_RESP_NO_RESEND:
            // case ERR_PACKET_FAIL_FLOW_SAVE_FILTERED:
            // case ERR_PACKET_FAIL_REQ_OVER_LOAD:
            // case ERR_PACKET_FAIL_LOGIC_ERR:
            // case ERR_FRIENDSHIP_PROXY_NOT_SYNCED:

            return TUIKitLocalizableString(TUIKitErrorFriendshipProxySyncing);
        case ERR_FRIENDSHIP_PROXY_SYNCING:
            return TUIKitLocalizableString(TUIKitErrorFriendshipProxySyncing);
        case ERR_FRIENDSHIP_PROXY_SYNCED_FAIL:
            return TUIKitLocalizableString(TUIKitErrorFriendshipProxySyncedFail);
        case ERR_FRIENDSHIP_PROXY_LOCAL_CHECK_ERR:
            return TUIKitLocalizableString(TUIKitErrorFriendshipProxyLocalCheckErr);
        case ERR_GROUP_INVALID_FIELD:
            return TUIKitLocalizableString(TUIKitErrorGroupInvalidField);
        case ERR_GROUP_STORAGE_DISABLED:
            return TUIKitLocalizableString(TUIKitErrorGroupStoreageDisabled);
        case ERR_LOADGRPINFO_FAILED:
            return TUIKitLocalizableString(TUIKitErrorLoadGrpInfoFailed);
        case ERR_REQ_NO_NET_ON_REQ:
            return TUIKitLocalizableString(TUIKitErrorReqNoNetOnReq);
        case ERR_REQ_NO_NET_ON_RSP:
            return TUIKitLocalizableString(TUIKitErrorReqNoNetOnResp);
        case ERR_SERIVCE_NOT_READY:
            return TUIKitLocalizableString(TUIKitErrorServiceNotReady);
        case ERR_LOGIN_AUTH_FAILED:
            return TUIKitLocalizableString(TUIKitErrorLoginAuthFailed);
        case ERR_NEVER_CONNECT_AFTER_LAUNCH:
            return TUIKitLocalizableString(TUIKitErrorNeverConnectAfterLaunch);
        case ERR_REQ_FAILED:
            return TUIKitLocalizableString(TUIKitErrorReqFailed);
        case ERR_REQ_INVALID_REQ:
            return TUIKitLocalizableString(TUIKitErrorReqInvaidReq);
        case ERR_REQ_OVERLOADED:
            return TUIKitLocalizableString(TUIKitErrorReqOnverLoaded);
        case ERR_REQ_KICK_OFF:
            return TUIKitLocalizableString(TUIKitErrorReqKickOff);
        case ERR_REQ_SERVICE_SUSPEND:
            return TUIKitLocalizableString(TUIKitErrorReqServiceSuspend);
        case ERR_REQ_INVALID_SIGN:
            return TUIKitLocalizableString(TUIKitErrorReqInvalidSign);
        case ERR_REQ_INVALID_COOKIE:
            return TUIKitLocalizableString(TUIKitErrorReqInvalidCookie);
        case ERR_LOGIN_TLS_RSP_PARSE_FAILED:
            return TUIKitLocalizableString(TUIKitErrorLoginTlsRspParseFailed);
        case ERR_LOGIN_OPENMSG_TIMEOUT:
            return TUIKitLocalizableString(TUIKitErrorLoginOpenMsgTimeout);
        case ERR_LOGIN_OPENMSG_RSP_PARSE_FAILED:
            return TUIKitLocalizableString(TUIKitErrorLoginOpenMsgRspParseFailed);
        case ERR_LOGIN_TLS_DECRYPT_FAILED:
            return TUIKitLocalizableString(TUIKitErrorLoginTslDecryptFailed);
        case ERR_WIFI_NEED_AUTH:
            return TUIKitLocalizableString(TUIKitErrorWifiNeedAuth);
        case ERR_USER_CANCELED:
            return TUIKitLocalizableString(TUIKitErrorUserCanceled);
        case ERR_REVOKE_TIME_LIMIT_EXCEED:
            return TUIKitLocalizableString(TUIkitErrorRevokeTimeLimitExceed);
        case ERR_LACK_UGC_EXT:
            return TUIKitLocalizableString(TUIKitErrorLackUGExt);
        case ERR_AUTOLOGIN_NEED_USERSIG:
            return TUIKitLocalizableString(TUIKitErrorAutoLoginNeedUserSig);
        case ERR_QAL_NO_SHORT_CONN_AVAILABLE:
            return TUIKitLocalizableString(TUIKitErrorQALNoShortConneAvailable);
        case ERR_REQ_CONTENT_ATTACK:
            return TUIKitLocalizableString(TUIKitErrorReqContentAttach);
        case ERR_LOGIN_SIG_EXPIRE:
            return TUIKitLocalizableString(TUIKitErrorLoginSigExpire);
        case ERR_SDK_HAD_INITIALIZED:
            return TUIKitLocalizableString(TUIKitErrorSDKHadInit);
        case ERR_OPENBDH_BASE:
            return TUIKitLocalizableString(TUIKitErrorOpenBDHBase);
        case ERR_REQUEST_NO_NET_ONREQ:
            return TUIKitLocalizableString(TUIKitErrorRequestNoNetOnReq);
        case ERR_REQUEST_NO_NET_ONRSP:
            return TUIKitLocalizableString(TUIKitErrorRequestNoNetOnRsp);
        case ERR_REQUEST_OVERLOADED:
            return TUIKitLocalizableString(TUIKitErrorRequestOnverLoaded);
        case ERR_REQUEST_KICK_OFF:
            return TUIKitLocalizableString(TUIKitErrorReqKickOff);
        case ERR_REQUEST_SERVICE_SUSPEND:
            return TUIKitLocalizableString(TUIKitErrorReqServiceSuspend);
        case ERR_REQUEST_INVALID_SIGN:
            return TUIKitLocalizableString(TUIKitErrorReqInvalidSign);
        case ERR_REQUEST_INVALID_COOKIE:
            return TUIKitLocalizableString(TUIKitErrorReqInvalidCookie);

        default:
            break;
    }
    return msg;
}

+(void)dispatchMainAsync:(dispatch_block_t) block {
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

+ (NSString *)genImageName:(NSString *)uuid
{
    NSString *identifier = [[V2TIMManager sharedInstance] getLoginUser];
    if(uuid == nil){
        int value = arc4random() % 1000;
        uuid = [NSString stringWithFormat:@"%ld_%d", (long)[[NSDate date] timeIntervalSince1970], value];
    }
    
    NSString *name = [NSString stringWithFormat:@"%d_%@_image_%@", [TUILogin getSdkAppID], identifier, uuid];
    return name;
}

+ (NSString *)genSnapshotName:(NSString *)uuid
{
    NSString *identifier = [[V2TIMManager sharedInstance] getLoginUser];
    if(uuid == nil){
        uuid = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    }
    NSString *name = [NSString stringWithFormat:@"%d_%@_snapshot_%@", [TUILogin getSdkAppID], identifier, uuid];
    return name;
}

+ (NSString *)genVideoName:(NSString *)uuid
{
    NSString *identifier = [[V2TIMManager sharedInstance] getLoginUser];
    if(uuid == nil){
        uuid = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    }
    NSString *name = [NSString stringWithFormat:@"%d_%@_video_%@", [TUILogin getSdkAppID], identifier, uuid];
    return name;
}


+ (NSString *)genVoiceName:(NSString *)uuid withExtension:(NSString *)extent
{
    NSString *identifier = [[V2TIMManager sharedInstance] getLoginUser];
    if(uuid == nil){
        uuid = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
    }
    NSString *name = [NSString stringWithFormat:@"%d_%@_voice_%@.%@", [TUILogin getSdkAppID], identifier, uuid, extent];
    return name;
}

+ (NSString *)genFileName:(NSString *)uuid
{
    NSString *identifier = [[V2TIMManager sharedInstance] getLoginUser];
    if(uuid == nil){
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
    
    @weakify(vc);
    [[NSNotificationCenter defaultCenter] addObserverForName:TUIKitNotification_onReceivedUnsupportInterfaceError object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        @strongify(vc);
        NSDictionary *userInfo = note.userInfo;
        NSString *service = [userInfo objectForKey:@"service"];
        NSString *serviceDesc = [userInfo objectForKey:@"serviceDesc"];
        [TUITool showUnsupportAlertOfService:service serviceDesc:serviceDesc onVC:vc];
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
                                                      userInfo:@{@"service": service?:@"", @"serviceDesc":serviceDesc?:@""}];
}

+ (void)showUnsupportAlertOfService:(NSString *)service serviceDesc:(NSString *)serviceDesc onVC:(UIViewController *)vc {
    NSString *key = [NSString stringWithFormat:@"show_unsupport_alert_%@", service];
    BOOL isShown = [[NSUserDefaults standardUserDefaults] boolForKey:key];
    if (isShown) {
        return;
    }
    NSString *desc = [NSString stringWithFormat:@"%@%@%@", service, TUIKitLocalizableString(TUIKitErrorUnsupportIntefaceDesc), serviceDesc?:@""];
    NSArray *buttons = @[TUIKitLocalizableString(TUIKitErrorUnsupportIntefaceIGotIt), TUIKitLocalizableString(TUIKitErrorUnsupportIntefaceNoMoreAlert)];
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

    UIAlertAction *left = [UIAlertAction actionWithTitle:buttons[0] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    UIAlertAction *right = [UIAlertAction actionWithTitle:buttons[1] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
    [alertController tuitheme_addAction:left];
    [alertController tuitheme_addAction:right];
    [vc presentViewController:alertController animated:NO completion:nil];
}

+ (void)addValueAddedUnsupportNotificationInVC:(UIViewController *)vc {
    [self addValueAddedUnsupportNotificationInVC:vc debugOnly:YES];
}

+ (void)addValueAddedUnsupportNotificationInVC:(UIViewController *)vc debugOnly:(BOOL)debugOnly {
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
    
    @weakify(vc);
    [[NSNotificationCenter defaultCenter] addObserverForName:TUIKitNotification_onReceivedValueAddedUnsupportInterfaceError object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        @strongify(vc);
        NSDictionary *userInfo = note.userInfo;
        NSString *service = [userInfo objectForKey:@"service"];
        NSString *serviceDesc = [userInfo objectForKey:@"serviceDesc"];
        [TUITool showValueAddedUnsupportAlertOfService:service serviceDesc:serviceDesc onVC:vc];
    }];
}

+ (void)postValueAddedUnsupportNotificationOfService:(NSString *)service {
    [self postValueAddedUnsupportNotificationOfService:service serviceDesc:nil debugOnly:YES];
}

+ (void)postValueAddedUnsupportNotificationOfService:(NSString *)service serviceDesc:(NSString *)serviceDesc debugOnly:(BOOL)debugOnly {
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
    [[NSNotificationCenter defaultCenter] postNotificationName:TUIKitNotification_onReceivedValueAddedUnsupportInterfaceError
                                                        object:nil
                                                      userInfo:@{@"service": service?:@"", @"serviceDesc":serviceDesc?:@""}];
}

+ (void)showValueAddedUnsupportAlertOfService:(NSString *)service serviceDesc:(NSString *)serviceDesc onVC:(UIViewController *)vc {
    NSString *desc = [NSString stringWithFormat:@"%@%@%@", service, TUIKitLocalizableString(TUIKitErrorValueAddedUnsupportIntefaceDesc), serviceDesc?:@""];
    NSString *button = TUIKitLocalizableString(TUIKitErrorUnsupportIntefaceIGotIt);
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:TUIKitLocalizableString(TUIKitErrorUnsupportIntefaceTitle)
                                                                             message:desc
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:button style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertController tuitheme_addAction:ok];
    [vc presentViewController:alertController animated:NO completion:nil];
}

+ (void)checkCommercialAbility:(long long)param succ:(void(^)(BOOL enabled))succ fail:(void(^)(int code, NSString *desc))fail {
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
        } fail:^(int code, NSString *desc) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"checkCommercialAbility error, code:%d, desc:%@", code, desc);
                if (fail) {
                    fail(code, desc);
                }
            });
        }];
    });
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
                            if (window.windowLevel == UIWindowLevelNormal && window.hidden == NO && CGRectEqualToRect(window.bounds, UIScreen.mainScreen.bounds)) {
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
