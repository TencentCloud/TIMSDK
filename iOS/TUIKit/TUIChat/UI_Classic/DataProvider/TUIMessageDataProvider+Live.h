//
//  TUIMessageDataProvider+Live.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by kayev on 2021/8/10.
//

#import "TUIMessageDataProvider.h"
#import "TUIMessageCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIMessageDataProvider (Live)

+ (BOOL)isLiveMessage:(V2TIMMessage *)message;

+ (TUIMessageCellData *)getLiveCellData:(V2TIMMessage *)message;

+ (NSString *)getLiveMessageDisplayString:(V2TIMMessage *)message;
@end

NS_ASSUME_NONNULL_END
