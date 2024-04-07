//
//  TUIVideoReplyQuoteView_Minimalist.m
//  TUIChat
//
//  Created by harvy on 2021/11/25.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIVideoReplyQuoteView_Minimalist.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIDarkModel.h>
#import "TUIVideoReplyQuoteViewData.h"

@implementation TUIVideoReplyQuoteView_Minimalist

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
}
+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

// this is Apple's recommended place for adding/updating constraints
- (void)updateConstraints {
     
    [super updateConstraints];

    TUIVideoReplyQuoteViewData *myData = (TUIVideoReplyQuoteViewData *)self.data;

    [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
      make.leading.top.mas_equalTo(self);
      if (CGSizeEqualToSize(CGSizeZero, myData.imageSize)) {
         make.size.mas_equalTo(CGSizeMake(60, 60));
      }
      else {
          make.size.mas_equalTo(myData.imageSize);
      }
    }];
    
    [self.playView mas_remakeConstraints:^(MASConstraintMaker *make) {
      make.size.mas_equalTo(CGSizeMake(30, 30));
      make.center.mas_equalTo(self.imageView);
    }];
}

- (void)fillWithData:(TUIReplyQuoteViewData *)data {
    //TUIImageReplyQuoteView deal Image
    [super fillWithData:data];
}

@end
