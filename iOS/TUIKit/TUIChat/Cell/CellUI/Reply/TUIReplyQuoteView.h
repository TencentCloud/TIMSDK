//
//  TUIReplyQuoteView.h
//  TUIChat
//
//  Created by harvy on 2021/11/25.
//

#import <UIKit/UIKit.h>
@class TUIReplyQuoteViewData;

NS_ASSUME_NONNULL_BEGIN

@interface TUIReplyQuoteView : UIView

@property (nonatomic, strong) TUIReplyQuoteViewData *data;

- (void)fillWithData:(TUIReplyQuoteViewData *)data;
- (void)reset;

@end

NS_ASSUME_NONNULL_END
