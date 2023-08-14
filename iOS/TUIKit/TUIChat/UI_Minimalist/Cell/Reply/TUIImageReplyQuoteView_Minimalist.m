//
//  TUIImageReplyQuoteView_Minimalist.m
//  TUIChat
//
//  Created by harvy on 2021/11/25.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIImageReplyQuoteView_Minimalist.h"
#import "TUIImageReplyQuoteViewData.h"

@implementation TUIImageReplyQuoteView_Minimalist

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _imageView = [[UIImageView alloc] init];
        _imageView.frame = CGRectMake(0, 0, 60, 60);
        [self addSubview:_imageView];
    }
    return self;
}

- (void)fillWithData:(TUIReplyQuoteViewData *)data {
    [super fillWithData:data];

    if (![data isKindOfClass:TUIImageReplyQuoteViewData.class]) {
        return;
    }
    TUIImageReplyQuoteViewData *myData = (TUIImageReplyQuoteViewData *)data;
    self.imageView.image = myData.image;
    if (myData.image == nil) {
        [myData downloadImage];
    }
    self.imageView.frame = CGRectMake(0, 0, myData.imageSize.width, myData.imageSize.height);
}

- (void)reset {
    [super reset];
    self.imageView.image = nil;
    self.imageView.frame = CGRectMake(0, 0, 60, 60);
}

@end
