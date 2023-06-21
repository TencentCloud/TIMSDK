//
//  TUIImageReplyQuoteViewData_Minimalist.m
//  TUIChat
//
//  Created by harvy on 2021/11/25.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIImageReplyQuoteViewData_Minimalist.h"
#import "TUIImageMessageCellData_Minimalist.h"

@implementation TUIImageReplyQuoteViewData_Minimalist

+ (instancetype)getReplyQuoteViewData:(TUIMessageCellData *)originCellData {
    if (originCellData == nil) {
        return nil;
    }

    if (![originCellData isKindOfClass:TUIImageMessageCellData_Minimalist.class]) {
        return nil;
    }

    TUIImageReplyQuoteViewData_Minimalist *myData = [[TUIImageReplyQuoteViewData_Minimalist alloc] init];
    V2TIMImage *thumb = nil;
    for (V2TIMImage *image in originCellData.innerMessage.imageElem.imageList) {
        if (image.type == V2TIM_IMAGE_TYPE_THUMB) {
            thumb = image;
            break;
        }
    }
    myData.imageSize = [TUIImageReplyQuoteViewData_Minimalist displaySizeWithOriginSize:CGSizeMake(thumb ? thumb.width : 60, thumb ? thumb.height : 60)];
    myData.originCellData = originCellData;
    return myData;
}

- (CGSize)contentSize:(CGFloat)maxWidth {
    return self.imageSize;
}

+ (CGSize)displaySizeWithOriginSize:(CGSize)originSize {
    if (originSize.width == 0 || originSize.width == 0) {
        return CGSizeZero;
    }

    CGFloat max = 60;
    CGFloat w = 0, h = 0;
    if (originSize.width > originSize.height) {
        w = max;
        h = max * originSize.height / originSize.width;
    } else {
        w = max * originSize.width / originSize.height;
        h = max;
    }
    return CGSizeMake(w, h);
}

- (void)downloadImage {
    @weakify(self);
    if ([self.originCellData isKindOfClass:TUIImageMessageCellData_Minimalist.class]) {
        TUIImageMessageCellData_Minimalist *imageData = (TUIImageMessageCellData_Minimalist *)self.originCellData;
        [imageData downloadImage:TImage_Type_Thumb
                          finish:^{
                            @strongify(self);
                            self.image = imageData.thumbImage;
                            if (self.onFinish) {
                                self.onFinish();
                            }
                          }];
    }
}

@end
