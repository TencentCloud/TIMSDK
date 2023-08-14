//
//  TUIImageReplyQuoteViewData.h
//  TUIChat
//
//  Created by harvy on 2021/11/25.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIReplyMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIImageReplyQuoteViewData : TUIReplyQuoteViewData

@property(nonatomic, strong) UIImage *image;

@property(nonatomic, assign) CGSize imageSize;

+ (CGSize)displaySizeWithOriginSize:(CGSize)originSize;
- (void)downloadImage;

@end

NS_ASSUME_NONNULL_END
