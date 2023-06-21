//
//  TUIVideoReplyQuoteView.m
//  TUIChat
//
//  Created by harvy on 2021/11/25.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIVideoReplyQuoteView.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIDarkModel.h>
#import "TUIVideoReplyQuoteViewData.h"

@implementation TUIVideoReplyQuoteView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        _playView = [[UIImageView alloc] init];
        _playView.image = TUIChatCommonBundleImage(@"play_normal");
        _playView.frame = CGRectMake(0, 0, 30, 30);
        [self addSubview:_playView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.playView.center = self.imageView.center;
}

- (void)fillWithData:(TUIReplyQuoteViewData *)data {
    [super fillWithData:data];

    if (![data isKindOfClass:TUIVideoReplyQuoteViewData.class]) {
        return;
    }
    TUIVideoReplyQuoteViewData *myData = (TUIVideoReplyQuoteViewData *)data;
    self.imageView.image = myData.image;
    if (myData.image == nil) {
        [myData downloadImage];
    }
    self.imageView.frame = CGRectMake(0, 0, myData.imageSize.width, myData.imageSize.height);
}

@end
