//
//  TUIImageReplyQuoteViewData_Minimalist.h
//  TUIChat
//
//  Created by harvy on 2021/11/25.
//

#import "TUIReplyMessageCellData_Minimalist.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIImageReplyQuoteViewData_Minimalist : TUIReplyQuoteViewData_Minimalist

@property (nonatomic, strong) UIImage *image;

@property (nonatomic, assign) CGSize imageSize;

+ (CGSize)displaySizeWithOriginSize:(CGSize)originSize;
- (void)downloadImage;

@end

NS_ASSUME_NONNULL_END
