//
//  TUIVideoMessageCell.m
//  UIKit
//
//  Created by annidyfeng on 2019/5/30.
//

#import "TUIVideoMessageCell_Minimalist.h"
#import <TIMCommon/TIMDefine.h>
#import "TUIMessageProgressManager.h"

@interface TUIVideoMessageCell_Minimalist ()<TUIMessageProgressManagerDelegate>

@property (nonatomic, strong) UIView *animateHighlightView;

@end

@implementation TUIVideoMessageCell_Minimalist


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _thumb = [[UIImageView alloc] init];
        _thumb.layer.cornerRadius = 5.0;
        [_thumb.layer setMasksToBounds:YES];
        _thumb.contentMode = UIViewContentModeScaleAspectFit;
        _thumb.backgroundColor = [UIColor clearColor];
        [self.container addSubview:_thumb];
        _thumb.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        CGSize playSize = TVideoMessageCell_Play_Size;
        _play = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, playSize.width, playSize.height)];
        _play.contentMode = UIViewContentModeScaleAspectFit;
        _play.image = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"play_normal")];
        [_thumb addSubview:_play];

        _progress = [[UILabel alloc] init];
        _progress.textColor = [UIColor whiteColor];
        _progress.font = [UIFont systemFontOfSize:15];
        _progress.textAlignment = NSTextAlignmentCenter;
        _progress.layer.cornerRadius = 5.0;
        _progress.hidden = YES;
        _progress.backgroundColor = TVideoMessageCell_Progress_Color;
        [_progress.layer setMasksToBounds:YES];
        [self.container addSubview:_progress];
        _progress.mm_fill();
        _progress.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        self.msgTimeLabel.textColor = RGB(255, 255, 255);
        [TUIMessageProgressManager.shareManager addDelegate:self];
    }
    return self;
}

- (void)fillWithData:(TUIVideoMessageCellData_Minimalist *)data;
{
    //set data
    [super fillWithData:data];
    self.videoData = data;
    _thumb.image = nil;
    if(data.thumbImage == nil){
        [data downloadThumb];
    }

    @weakify(self)
    [[RACObserve(data, thumbImage) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(UIImage *thumbImage) {
        @strongify(self)
        if (thumbImage) {
            self.thumb.image = thumbImage;
        }
    }];

    if (data.direction == MsgDirectionIncoming) {
        [[[RACObserve(data, thumbProgress) takeUntil:self.rac_prepareForReuseSignal] distinctUntilChanged] subscribeNext:^(NSNumber *x) {
            @strongify(self)
            int progress = [x intValue];
            self.progress.text = [NSString stringWithFormat:@"%d%%", progress];
            self.progress.hidden = (progress >= 100 || progress == 0);
            self.play.hidden = !self.progress.hidden;
        }];
    } else {
        [[[RACObserve(data, uploadProgress) takeUntil:self.rac_prepareForReuseSignal] distinctUntilChanged] subscribeNext:^(NSNumber *x) {
            @strongify(self)
            self.play.hidden = !self.progress.hidden;
        }];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGFloat topMargin = 0;
    CGFloat height = self.container.mm_h;
    
    if (self.messageData.messageModifyReactsSize.height > 0) {
        topMargin = 10;
        height = (self.container.mm_h - self.messageData.messageModifyReactsSize.height - topMargin);
    }
    
    _thumb.mm_height(height).mm_left(0).mm_top(topMargin).mm_width(self.container.mm_w);

    _play.mm_width(TVideoMessageCell_Play_Size.width).mm_height(TVideoMessageCell_Play_Size.height).tui_mm_center();
    
    self.msgStatusView.frame = CGRectOffset(self.msgStatusView.frame, kScale390(8), 0);
    self.msgTimeLabel.frame = CGRectOffset(self.msgTimeLabel.frame, kScale390(8), 0);
}

- (void)highlightWhenMatchKeyword:(NSString *)keyword
{
    if (keyword) {
        if (self.highlightAnimating) {
            return;
        }
        [self animate:3];
    }
}

- (void)animate:(int)times
{
    times--;
    if (times < 0) {
        [self.animateHighlightView removeFromSuperview];
        self.highlightAnimating = NO;
        return;
    }
    self.highlightAnimating = YES;
    self.animateHighlightView.frame = self.container.bounds;
    self.animateHighlightView.alpha = 0.1;
    [self.container addSubview:self.animateHighlightView];
    [UIView animateWithDuration:0.25 animations:^{
        self.animateHighlightView.alpha = 0.5;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.25 animations:^{
            self.animateHighlightView.alpha = 0.1;
        } completion:^(BOOL finished) {
            if (!self.videoData.highlightKeyword) {
                [self animate:0];
                return;
            }
            [self animate:times];
        }];
    }];
}

- (UIView *)animateHighlightView
{
    if (_animateHighlightView == nil) {
        _animateHighlightView = [[UIView alloc] init];
        _animateHighlightView.backgroundColor = [UIColor orangeColor];
    }
    return _animateHighlightView;
}
#pragma mark - TUIMessageProgressManagerDelegate
- (void)onProgress:(NSString *)msgID progress:(NSInteger)progress {
    if (![msgID isEqualToString:self.videoData.msgID]) {
        return;
    }
    if (self.videoData.direction == MsgDirectionOutgoing) {
        self.videoData.uploadProgress = progress;
    }
}

@end
