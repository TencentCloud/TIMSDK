//
//  TUIVideoReplyQuoteView_Minimalist.m
//  TUIChat
//
//  Created by harvy on 2021/11/25.
//

#import "TUIVideoReplyQuoteView_Minimalist.h"
#import "TUIVideoReplyQuoteViewData_Minimalist.h"
#import "TUIDarkModel.h"
#import "TUIDefine.h"

@implementation TUIVideoReplyQuoteView_Minimalist

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _playView = [[UIImageView alloc] init];
        _playView.image = TUIChatCommonBundleImage(@"play_normal");
        _playView.frame = CGRectMake(0, 0, 30, 30);
        [self addSubview:_playView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.playView.center = self.imageView.center;
}

- (void)fillWithData:(TUIReplyQuoteViewData_Minimalist *)data
{
    [super fillWithData:data];
    
    if (![data isKindOfClass:TUIVideoReplyQuoteViewData_Minimalist.class]) {
        return;
    }
    TUIVideoReplyQuoteViewData_Minimalist *myData = (TUIVideoReplyQuoteViewData_Minimalist *)data;
    self.imageView.image = myData.image;
    if (myData.image == nil) {
        [myData downloadImage];
    }
    self.imageView.frame = CGRectMake(0, 0, myData.imageSize.width, myData.imageSize.height);
}

@end
