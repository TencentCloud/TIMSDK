//
//  TUIReplyQuoteView_Minimalist.h
//  TUIChat
//
//  Created by harvy on 2021/11/25.
//

#import <UIKit/UIKit.h>
@class TUIReplyQuoteViewData_Minimalist;

NS_ASSUME_NONNULL_BEGIN

@interface TUIReplyQuoteView_Minimalist : UIView

@property (nonatomic, strong) TUIReplyQuoteViewData_Minimalist *data;

- (void)fillWithData:(TUIReplyQuoteViewData_Minimalist *)data;
- (void)reset;

@end

NS_ASSUME_NONNULL_END
