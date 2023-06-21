//
//  TUITranslationDataProvider.m
//  TUITranslation
//
//  Created by xia on 2023/3/21.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUITranslationDataProvider.h"
#import <TIMCommon/NSString+TUIEmoji.h>
#import <TUICore/TUICore.h>
#import <TUICore/TUILogin.h>
#import "TUITranslationConfig.h"

#pragma GCC diagnostic ignored "-Wundeclared-selector"

static NSString *const kKeyTranslationText = @"translation";
static NSString *const kKeyTranslationViewStatus = @"translation_view_status";

@interface TUITranslationDataProvider () <TUINotificationProtocol, V2TIMAdvancedMsgListener>

@end

@implementation TUITranslationDataProvider
#pragma mark - Public
+ (void)translateMessage:(TUIMessageCellData *)data completion:(TUITranslateMessageCompletion)completion {
    V2TIMMessage *msg = data.innerMessage;
    if (msg.elemType != V2TIM_ELEM_TYPE_TEXT) {
        return;
    }
    V2TIMTextElem *textElem = msg.textElem;
    if (textElem == nil) {
        return;
    }

    /// Get at user's nickname by userID
    NSMutableArray *atUserIDs = [msg.groupAtUserList mutableCopy];
    if (atUserIDs.count == 0) {
        /// There's no any @user info.
        [self translateMessage:data atUsers:nil completion:completion];
        return;
    }

    /// Find @All info.
    NSMutableArray *atUserIDsExcludingAtAll = [NSMutableArray new];
    NSMutableIndexSet *atAllIndex = [NSMutableIndexSet new];
    for (int i = 0; i < atUserIDs.count; i++) {
        NSString *userID = atUserIDs[i];
        if (![userID isEqualToString:kImSDK_MesssageAtALL]) {
            /// Exclude @All.
            [atUserIDsExcludingAtAll addObject:userID];
        } else {
            /// Record @All's location for later restore.
            [atAllIndex addIndex:i];
        }
    }
    if (atUserIDsExcludingAtAll.count == 0) {
        /// There's only @All info.
        NSMutableArray *atAllNames = [NSMutableArray new];
        for (int i = 0; i < atAllIndex.count; i++) {
            [atAllNames addObject:TIMCommonLocalizableString(All)];
        }
        [self translateMessage:data atUsers:atAllNames completion:completion];
        return;
    }
    [[V2TIMManager sharedInstance] getUsersInfo:atUserIDsExcludingAtAll
        succ:^(NSArray<V2TIMUserFullInfo *> *infoList) {
          NSMutableArray *atUserNames = [NSMutableArray new];
          for (NSString *userID in atUserIDsExcludingAtAll) {
              for (V2TIMUserFullInfo *user in infoList) {
                  if ([userID isEqualToString:user.userID]) {
                      [atUserNames addObject:user.nickName ?: user.userID];
                      break;
                  }
              }
          }

          // Restore @All.
          if (atAllIndex.count > 0) {
              [atAllIndex enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *_Nonnull stop) {
                [atUserNames insertObject:TIMCommonLocalizableString(All) atIndex:idx];
              }];
          }
          [self translateMessage:data atUsers:atUserNames completion:completion];
        }
        fail:^(int code, NSString *desc) {
          [self translateMessage:data atUsers:atUserIDs completion:completion];
        }];
}

+ (void)translateMessage:(TUIMessageCellData *)data atUsers:(NSArray *)atUsers completion:(TUITranslateMessageCompletion)completion {
    V2TIMMessage *msg = data.innerMessage;
    V2TIMTextElem *textElem = msg.textElem;

    NSString *target = [TUITranslationConfig defaultConfig].targetLanguageCode;
    NSDictionary *splitResult = [textElem.text splitTextByEmojiAndAtUsers:atUsers];
    NSArray *textArray = splitResult[kSplitStringTextKey];

    if (textArray.count == 0) {
        /// Nothing need to be translated.
        [self saveTranslationResult:msg text:textElem.text status:TUITranslationViewStatusShown];
        if (completion) {
            completion(0, @"", data, TUITranslationViewStatusShown, textElem.text);
        }
        return;
    }

    NSDictionary *dict = [TUITool jsonData2Dictionary:msg.localCustomData];
    NSString *translatedText = nil;
    if ([dict.allKeys containsObject:kKeyTranslationText]) {
        translatedText = dict[kKeyTranslationText];
    }

    if (translatedText.length > 0) {
        [self saveTranslationResult:msg text:translatedText status:TUITranslationViewStatusShown];
        if (completion) {
            completion(0, @"", data, TUITranslationViewStatusShown, translatedText);
        }
    } else {
        [self saveTranslationResult:msg text:@"" status:TUITranslationViewStatusLoading];
        if (completion) {
            completion(0, @"", data, TUITranslationViewStatusLoading, @"");
        }
    }

    /// Send translate request.
    @weakify(self);
    [[V2TIMManager sharedInstance] translateText:textArray
                                  sourceLanguage:nil
                                  targetLanguage:target
                                      completion:^(int code, NSString *desc, NSDictionary<NSString *, NSString *> *result) {
                                        @strongify(self);
                                        /// Translate failed.
                                        if (code != 0 || result.count == 0) {
                                            if (code == 30007) {
                                                [TUITool makeToast:TIMCommonLocalizableString(TranslateLanguageNotSupport)];
                                            } else {
                                                [TUITool makeToastError:code msg:desc];
                                            }

                                            [self saveTranslationResult:msg text:@"" status:TUITranslationViewStatusHidden];
                                            if (completion) {
                                                completion(code, desc, data, TUITranslationViewStatusHidden, @"");
                                            }
                                            return;
                                        }

                                        /// Translate succeeded.
                                        NSString *text = [NSString replacedStringWithArray:splitResult[kSplitStringResultKey]
                                                                                     index:splitResult[kSplitStringTextIndexKey]
                                                                               replaceDict:result];
                                        [self saveTranslationResult:msg text:text status:TUITranslationViewStatusShown];

                                        if (completion) {
                                            completion(0, @"", data, TUITranslationViewStatusShown, text);
                                        }
                                      }];
}

+ (void)saveTranslationResult:(V2TIMMessage *)message text:(NSString *)text status:(TUITranslationViewStatus)status {
    if (text.length > 0) {
        [self saveToLocalCustomDataOfMessage:message key:kKeyTranslationText value:text];
    }
    [self saveToLocalCustomDataOfMessage:message key:kKeyTranslationViewStatus value:@(status)];
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

+ (BOOL)shouldShowTranslation:(V2TIMMessage *)message {
    if (message.localCustomData.length == 0) {
        return NO;
    }
    NSDictionary *dict = [TUITool jsonData2Dictionary:message.localCustomData];
    TUITranslationViewStatus status;
    if ([dict.allKeys containsObject:kKeyTranslationViewStatus]) {
        status = [dict[kKeyTranslationViewStatus] integerValue];
    } else {
        status = TUITranslationViewStatusHidden;
    }
    NSArray *hiddenStatus = @[ @(TUITranslationViewStatusUnknown), @(TUITranslationViewStatusHidden) ];
    return ![hiddenStatus containsObject:@(status)] || status == TUITranslationViewStatusLoading;
}

+ (NSString *)getTranslationText:(V2TIMMessage *)message {
    if (message.localCustomData.length == 0) {
        return nil;
    }
    NSDictionary *dict = [TUITool jsonData2Dictionary:message.localCustomData];
    if ([dict.allKeys containsObject:kKeyTranslationText]) {
        return dict[kKeyTranslationText];
    }
    return nil;
}

+ (TUITranslationViewStatus)getTranslationStatus:(V2TIMMessage *)message {
    if (message.localCustomData.length == 0) {
        return TUITranslationViewStatusUnknown;
    }
    NSDictionary *dict = [TUITool jsonData2Dictionary:message.localCustomData];
    if ([dict.allKeys containsObject:kKeyTranslationViewStatus]) {
        return [dict[kKeyTranslationViewStatus] integerValue];
    }
    return TUITranslationViewStatusUnknown;
}

@end
