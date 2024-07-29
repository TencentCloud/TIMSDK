//
//  TUIReplyQuoteViewData.h
//  TUIChat
//
//  Created by harvy on 2021/11/25.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TUIChatDefine.h"

@class TUIMessageCellData;

NS_ASSUME_NONNULL_BEGIN

@interface TUIReplyQuoteViewData : NSObject

+ (instancetype)getReplyQuoteViewData:(TUIMessageCellData *)originCellData;

- (CGSize)contentSize:(CGFloat)maxWidth;

/**
 * If you want to download the custom reply content asynchronously, you need to call the callback after the download is complete, and the TUI will be
 * automatically refreshed.
 */
@property(nonatomic, copy) TUIReplyQuoteAsyncLoadFinish onFinish;

@property(nonatomic, strong) TUIMessageCellData *originCellData;

@property(nonatomic, assign) BOOL supportForReply;

@property(nonatomic, assign) BOOL showRevokedOriginMessage;

@end

NS_ASSUME_NONNULL_END
