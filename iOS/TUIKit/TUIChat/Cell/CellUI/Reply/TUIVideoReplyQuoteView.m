//
//  TUIVideoReplyQuoteView.m
//  TUIChat
//
//  Created by harvy on 2021/11/25.
//

#import "TUIVideoReplyQuoteView.h"
#import "TUIDarkModel.h"
#import "TUIDefine.h"
#import "TUIVideoReplyQuoteViewData.h"

@implementation TUIVideoReplyQuoteView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _playView = [[UIImageView alloc] init];
        _playView.image = [UIImage d_imageNamed:@"play_normal" bundle:TUIChatBundle];
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

- (void)fillWithData:(TUIReplyQuoteViewData *)data
{
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
