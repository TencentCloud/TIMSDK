//
//  TUIVideoReplyQuoteViewData_Minimalist.m
//  TUIChat
//
//  Created by harvy on 2021/11/25.
//

#import "TUIVideoReplyQuoteViewData_Minimalist.h"
#import "TUIVideoMessageCellData_Minimalist.h"

@implementation TUIVideoReplyQuoteViewData_Minimalist

+ (instancetype)getReplyQuoteViewData:(TUIMessageCellData *)originCellData
{
    if (originCellData == nil) {
        return nil;
    }
    
    if (![originCellData isKindOfClass:TUIVideoMessageCellData_Minimalist.class]) {
        return nil;
    }
    
    TUIVideoReplyQuoteViewData_Minimalist *myData = [[TUIVideoReplyQuoteViewData_Minimalist alloc] init];
    CGSize snapSize = CGSizeMake(originCellData.innerMessage.videoElem?originCellData.innerMessage.videoElem.snapshotWidth:0,
                                 originCellData.innerMessage.videoElem?originCellData.innerMessage.videoElem.snapshotHeight:0);
    myData.imageSize = [TUIVideoReplyQuoteViewData_Minimalist displaySizeWithOriginSize:snapSize];
    myData.originCellData = originCellData;
    return myData;
}

- (void)downloadImage
{
    [super downloadImage];
    
    @weakify(self)
    if ([self.originCellData isKindOfClass:TUIVideoMessageCellData_Minimalist.class]) {
        TUIVideoMessageCellData_Minimalist *videoData = (TUIVideoMessageCellData_Minimalist *)self.originCellData;
        [videoData downloadThumb:^{
            @strongify(self)
            self.image = videoData.thumbImage;
            if (self.onFinish) {
                self.onFinish();
            }
        }];
    }
}

@end
