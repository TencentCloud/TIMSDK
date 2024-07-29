//
//  TUIVoiceToTextDataProvider.h
//  TUIVoiceToText
//
//  Created by xia on 2023/8/17.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TIMCommon/TUIMessageCellData.h>
#import <TUICore/TUIDefine.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TUIVoiceToTextViewStatus) {
    TUIVoiceToTextViewStatusUnknown = 0,
    TUIVoiceToTextViewStatusHidden = 1,
    TUIVoiceToTextViewStatusLoading = 2,
    TUIVoiceToTextViewStatusShown = 3,
    TUIVoiceToTextViewStatusSecurityStrike = 4,
};

typedef void (^TUIVoiceToTextCompletion)(NSInteger code, NSString *desc, TUIMessageCellData *data, NSInteger status, NSString *text);

@interface TUIVoiceToTextDataProvider : NSObject

+ (void)convertMessage:(TUIMessageCellData *)data completion:(TUIVoiceToTextCompletion _Nullable)completion;

+ (void)saveConvertedResult:(V2TIMMessage *)message text:(NSString *)text status:(TUIVoiceToTextViewStatus)status;

+ (BOOL)shouldShowConvertedText:(V2TIMMessage *)message;
+ (NSString *)getConvertedText:(V2TIMMessage *)message;
+ (TUIVoiceToTextViewStatus)getConvertedTextStatus:(V2TIMMessage *)message;

@end

NS_ASSUME_NONNULL_END
