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
    if (myData.image == nil && myData.imageStatus != TUIImageReplyQuoteStatusDownloading) {
        [myData downloadImage];
    }
    // tell constraints they need updating
    [self setNeedsUpdateConstraints];

    // update constraints now so we can animate the change
    [self updateConstraintsIfNeeded];

    [self layoutIfNeeded];
    
}
+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}
// this is Apple's recommended place for adding/updating constraints
- (void)updateConstraints {
     
    [super updateConstraints];
    TUIImageReplyQuoteViewData *myData = (TUIImageReplyQuoteViewData *)self.data;
    
    [self.imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self);
        make.top.mas_equalTo(self);
        make.size.mas_equalTo(myData.imageSize);
    }];
    
}

- (void)reset {
    [super reset];
    self.imageView.image = nil;
    self.imageView.frame = CGRectMake(self.imageView.frame.origin.x, self.imageView.frame.origin.y, 60, 60);
}

@end
