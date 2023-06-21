//
//  TUITranslationDataProvider.h
//  TUITranslation
//
//  Created by xia on 2023/3/21.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TIMCommon/TUIMessageCellData.h>
#import <TUICore/TUIDefine.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TUITranslationViewStatus) {
    TUITranslationViewStatusUnknown = 0,
    TUITranslationViewStatusHidden = 1,
    TUITranslationViewStatusLoading = 2,
    TUITranslationViewStatusShown = 3,
};

typedef void (^TUITranslateMessageCompletion)(NSInteger code, NSString *desc, TUIMessageCellData *data, NSInteger status, NSString *text);

@interface TUITranslationDataProvider : NSObject

+ (void)translateMessage:(TUIMessageCellData *)data completion:(TUITranslateMessageCompletion _Nullable)completion;

+ (void)saveTranslationResult:(V2TIMMessage *)message text:(NSString *)text status:(TUITranslationViewStatus)status;

+ (BOOL)shouldShowTranslation:(V2TIMMessage *)message;
+ (NSString *)getTranslationText:(V2TIMMessage *)message;
+ (TUITranslationViewStatus)getTranslationStatus:(V2TIMMessage *)message;

@end

NS_ASSUME_NONNULL_END
