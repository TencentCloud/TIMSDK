//
//  TUIVideoReplyQuoteViewData.m
//  TUIChat
//
//  Created by harvy on 2021/11/25.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIVideoReplyQuoteViewData.h"
#import "TUIVideoMessageCellData.h"

@implementation TUIVideoReplyQuoteViewData

+ (instancetype)getReplyQuoteViewData:(TUIMessageCellData *)originCellData {
    if (originCellData == nil) {
        return nil;
    }

    if (![originCellData isKindOfClass:TUIVideoMessageCellData.class]) {
        return nil;
    }

    TUIVideoReplyQuoteViewData *myData = [[TUIVideoReplyQuoteViewData alloc] init];
    CGSize snapSize = CGSizeMake(originCellData.innerMessage.videoElem ? originCellData.innerMessage.videoElem.snapshotWidth : 0,
                                 originCellData.innerMessage.videoElem ? originCellData.innerMessage.videoElem.snapshotHeight : 0);
    myData.imageSize = [TUIVideoReplyQuoteViewData displaySizeWithOriginSize:snapSize];
    myData.originCellData = originCellData;
    return myData;
}

- (void)downloadImage {
    [super downloadImage];

    @weakify(self);
    if ([self.originCellData isKindOfClass:TUIVideoMessageCellData.class]) {
        TUIVideoMessageCellData *videoData = (TUIVideoMessageCellData *)self.originCellData;
        [videoData downloadThumb:^{
          @strongify(self);
          self.image = videoData.thumbImage;
          if (self.onFinish) {
              self.onFinish();
          }
        }];
    }
}

@end
