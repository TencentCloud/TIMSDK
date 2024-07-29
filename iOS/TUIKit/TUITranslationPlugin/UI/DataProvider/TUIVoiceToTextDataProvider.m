//
//  TUIVoiceToTextDataProvider.m
//  TUIVoiceToText
//
//  Created by xia on 2023/8/17.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIVoiceToTextDataProvider.h"
#import <TIMCommon/NSString+TUIEmoji.h>
#import <TUICore/TUICore.h>
#import <TUICore/TUILogin.h>
#import "TUIVoiceToTextConfig.h"

#pragma GCC diagnostic ignored "-Wundeclared-selector"

static NSString *const kKeyVoiceToText = @"voice_to_text";
static NSString *const kKeyVoiceToTextViewStatus = @"voice_to_text_view_status";

@interface TUIVoiceToTextDataProvider () <TUINotificationProtocol, V2TIMAdvancedMsgListener>

@end

@implementation TUIVoiceToTextDataProvider
#pragma mark - Public
+ (void)convertMessage:(TUIMessageCellData *)data completion:(TUIVoiceToTextCompletion _Nullable)completion {
    V2TIMMessage *msg = data.innerMessage;
    if (msg.elemType != V2TIM_ELEM_TYPE_SOUND) {
        if (completion) {
            completion(-1, @"element is not sound type", data, TUIVoiceToTextViewStatusHidden, @"");
        }
        return;
    }
    if (msg.status != V2TIM_MSG_STATUS_SEND_SUCC) {
        if (completion) {
            completion(-2, @"sound message is not sent successfully", data, TUIVoiceToTextViewStatusHidden, @"");
        }
        return;
    }
    
    V2TIMSoundElem *soundElem = msg.soundElem;
    if (soundElem == nil) {
        if (completion) {
            completion(-3, @"soundElem is nil", data, TUIVoiceToTextViewStatusHidden, @"");
        }
        return;
    }
    
    // Loading converted text from localCustomData firstly.
    NSString *convertedText = [self getConvertedText:msg];
    if (convertedText.length > 0) {
        [self saveConvertedResult:msg text:convertedText status:TUIVoiceToTextViewStatusShown];
        if (completion) {
            completion(0, @"", data, TUIVoiceToTextViewStatusShown, convertedText);
        }
        return;
    }
    
    // Try to request from server secondly.
    [self saveConvertedResult:msg text:@"" status:TUIVoiceToTextViewStatusLoading];
    if (completion) {
        completion(0, @"", data, TUIVoiceToTextViewStatusLoading, @"");
    }
    
    [soundElem convertVoiceToText:@""
                       completion:^(int code, NSString *desc, NSString *result) {
        TUIVoiceToTextViewStatus status;
        if (code == 0 && result.length > 0) {
            status = TUIVoiceToTextViewStatusShown;
        } else {
            status = TUIVoiceToTextViewStatusHidden;
        }
        [self saveConvertedResult:msg text:result status:status];
        if (completion) {
            completion(code, desc, data, status, result);
        }
    }];
}

+ (void)saveConvertedResult:(V2TIMMessage *)message text:(NSString *)text status:(TUIVoiceToTextViewStatus)status {
    if (text.length > 0) {
        [self saveToLocalCustomDataOfMessage:message key:kKeyVoiceToText value:text];
    }
    [self saveToLocalCustomDataOfMessage:message key:kKeyVoiceToTextViewStatus value:@(status)];
}

+ (void)saveToLocalCustomDataOfMessage:(V2TIMMessage *)message key:(NSString *)key value:(id)value {
    if (key.length == 0 || value == nil) {
        return;
    }
    NSData *customData = message.localCustomData;
    NSMutableDictionary *dict = [[TUITool jsonData2Dictionary:customData] mutableCopy];
    if (dict == nil) {
        dict = [[NSMutableDictionary alloc] init];
    }
    dict[key] = value;
    [message setLocalCustomData:[TUITool dictionary2JsonData:dict]];
}

+ (BOOL)shouldShowConvertedText:(V2TIMMessage *)message {
    if (message.localCustomData.length == 0) {
        return NO;
    }
    NSDictionary *dict = [TUITool jsonData2Dictionary:message.localCustomData];
    TUIVoiceToTextViewStatus status;
    if ([dict.allKeys containsObject:kKeyVoiceToTextViewStatus]) {
        status = [dict[kKeyVoiceToTextViewStatus] integerValue];
    } else {
        status = TUIVoiceToTextViewStatusHidden;
    }
    NSArray *hiddenStatus = @[ @(TUIVoiceToTextViewStatusUnknown), @(TUIVoiceToTextViewStatusHidden) ];
    return ![hiddenStatus containsObject:@(status)] || status == TUIVoiceToTextViewStatusLoading;
}

+ (NSString *)getConvertedText:(V2TIMMessage *)message {
    BOOL hasRiskContent = message.hasRiskContent;
    if (hasRiskContent){
        return TIMCommonLocalizableString(TUIKitMessageTypeSecurityStrikeTranslate);
    }
    if (message.localCustomData.length == 0) {
        return nil;
    }
    NSDictionary *dict = [TUITool jsonData2Dictionary:message.localCustomData];
    if ([dict.allKeys containsObject:kKeyVoiceToText]) {
        return dict[kKeyVoiceToText];
    }
    return nil;
}

+ (TUIVoiceToTextViewStatus)getConvertedTextStatus:(V2TIMMessage *)message {
    BOOL hasRiskContent = message.hasRiskContent;
    if (hasRiskContent){
        return TUIVoiceToTextViewStatusSecurityStrike;
    }

    if (message.localCustomData.length == 0) {
        return TUIVoiceToTextViewStatusUnknown;
    }
    NSDictionary *dict = [TUITool jsonData2Dictionary:message.localCustomData];
    if ([dict.allKeys containsObject:kKeyVoiceToTextViewStatus]) {
        return [dict[kKeyVoiceToTextViewStatus] integerValue];
    }
    return TUIVoiceToTextViewStatusUnknown;
}

@end
