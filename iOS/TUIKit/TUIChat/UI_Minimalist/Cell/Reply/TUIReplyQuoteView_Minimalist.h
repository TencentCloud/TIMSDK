//
//  TUIReplyQuoteView_Minimalist.h
//  TUIChat
//
//  Created by harvy on 2021/11/25.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TUIReplyQuoteViewData;

NS_ASSUME_NONNULL_BEGIN

@interface TUIReplyQuoteView_Minimalist : UIView

@property(nonatomic, strong) TUIReplyQuoteViewData *data;

- (void)fillWithData:(TUIReplyQuoteViewData *)data;
- (void)reset;

@end

NS_ASSUME_NONNULL_END
