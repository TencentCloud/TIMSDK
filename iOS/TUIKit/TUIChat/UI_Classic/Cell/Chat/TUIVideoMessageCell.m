//
//  TUIVideoMessageCell.m
//  UIKit
//
//  Created by annidyfeng on 2019/5/30.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIVideoMessageCell.h"
#import <TIMCommon/TIMDefine.h>
#import "TUICircleLodingView.h"
#import "TUIMessageProgressManager.h"

@interface TUIVideoMessageCell () <TUIMessageProgressManagerDelegate>

@property(nonatomic, strong) UIView *animateHighlightView;

@property(nonatomic, strong) TUICircleLodingView *animateCircleView;

@property(nonatomic, strong) UIImageView *downloadImage;

@end

@implementation TUIVideoMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _thumb = [[UIImageView alloc] init];
        _thumb.layer.cornerRadius = 5.0;
        [_thumb.layer setMasksToBounds:YES];
        _thumb.contentMode = UIViewContentModeScaleAspectFill;
        _thumb.backgroundColor = [UIColor clearColor];
        [self.bubbleView addSubview:_thumb];
        _thumb.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

        CGSize playSize = TVideoMessageCell_Play_Size;
        _play = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, playSize.width, playSize.height)];
        _play.contentMode = UIViewContentModeScaleAspectFit;
        _play.image = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"play_normal")];
        _play.hidden = YES;
        [_thumb addSubview:_play];

        _downloadImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, playSize.width, playSize.height)];
        _downloadImage.contentMode = UIViewContentModeScaleAspectFit;
        _downloadImage.image = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"download")];
        _downloadImage.hidden = YES;
        [_thumb addSubview:_downloadImage];

        _duration = [[UILabel alloc] init];
        _duration.textColor = [UIColor whiteColor];
        _duration.font = [UIFont systemFontOfSize:12];
        [_thumb addSubview:_duration];

        _animateCircleView = [[TUICircleLodingView alloc] initWithFrame:CGRectMake(0, 0, kScale390(40), kScale390(40))];
        _animateCircleView.progress = 0;
        [_thumb addSubview:_animateCircleView];
    
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
        [TUIMessageProgressManager.shareManager addDelegate:self];
    }
    return self;
}

- (void)fillWithData:(TUIVideoMessageCellData *)data;
{
    // set data
    [super fillWithData:data];
    self.videoData = data;
    _thumb.image = nil;
    
    BOOL hasRiskContent = self.messageData.innerMessage.hasRiskContent;
    if (hasRiskContent) {
        self.thumb.image = TIMCommonBundleThemeImage(@"", @"icon_security_strike");
        self.securityStrikeView.textLabel.text = TIMCommonLocalizableString(TUIKitMessageTypeSecurityStrikeImage);
        self.duration.text = @"";
        self.play.hidden = YES;
        self.downloadImage.hidden = YES;
        self.indicator.hidden = YES;
        self.animateCircleView.hidden = YES;
        return;
    }
    if (data.thumbImage == nil) {
        [data downloadThumb];
    }
    if (data.isPlaceHolderCellData) {
        //show placeHolder
        _thumb.backgroundColor = [UIColor grayColor];
        _animateCircleView.progress = (data.videoTranscodingProgress *100);
        self.duration.text = @"";
        self.play.hidden = YES;
        self.downloadImage.hidden = YES;
        self.indicator.hidden = YES;
        self.animateCircleView.hidden = NO;
        @weakify(self);
        [[RACObserve(data, videoTranscodingProgress) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(NSNumber *x) {
            // The transcoded animation can display up to 30% at maximum,
            // and the upload progress increases from 30% to 100%.
            @strongify(self);
            double progress = [x doubleValue];
            double factor  = 0.3;
            double resultProgress = (progress *100) * factor;
            self.animateCircleView.progress = resultProgress;
        }];
        if (data.thumbImage) {
            self.thumb.image = data.thumbImage;
        }
        // tell constraints they need updating
        [self setNeedsUpdateConstraints];

        // update constraints now so we can animate the change
        [self updateConstraintsIfNeeded];

        [self layoutIfNeeded];

        return;
    }

    @weakify(self);
    [[RACObserve(data, thumbImage) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(UIImage *thumbImage) {
      @strongify(self);
      if (thumbImage) {
          self.thumb.image = thumbImage;
      }
    }];

    _duration.text = [NSString stringWithFormat:@"%02ld:%02ld", (long)data.videoItem.duration / 60, (long)data.videoItem.duration % 60];

    self.play.hidden = YES;
    self.downloadImage.hidden = YES;
    self.indicator.hidden = YES;
    if (data.direction == MsgDirectionIncoming) {
        [[[RACObserve(data, thumbProgress) takeUntil:self.rac_prepareForReuseSignal] distinctUntilChanged] subscribeNext:^(NSNumber *x) {
          @strongify(self);
          // Cover download progress callback
          int progress = [x intValue];
          self.progress.text = [NSString stringWithFormat:@"%d%%", progress];
          self.progress.hidden = (progress >= 100 || progress == 0);
          self.animateCircleView.progress = progress;
          if (progress >= 100 || progress == 0) {
              // The progress of cover download is called back and the download video icon is displayed when the cover progress is 100.
              if ([data isVideoExist]) {
                  self.play.hidden = NO;
              } else {
                  self.downloadImage.hidden = NO;
              }
          } else {
              self.play.hidden = YES;
              self.downloadImage.hidden = YES;
          }
        }];

        // Video resource download progress callback
        [[[RACObserve(data, videoProgress) takeUntil:self.rac_prepareForReuseSignal] distinctUntilChanged] subscribeNext:^(NSNumber *x) {
          @strongify(self);
          int progress = [x intValue];
          self.animateCircleView.progress = progress;
          if (progress >= 100 || progress == 0) {
              self.play.hidden = NO;
              self.animateCircleView.hidden = YES;
          } else {
              self.play.hidden = YES;
              self.downloadImage.hidden = YES;
              self.animateCircleView.hidden = NO;
          }
        }];

    } else {
        if ([data isVideoExist]) {
            [[[RACObserve(data, uploadProgress) takeUntil:self.rac_prepareForReuseSignal] distinctUntilChanged] subscribeNext:^(NSNumber *x) {
              @strongify(self);
              int progress = [x intValue];
              if (data.placeHolderCellData.videoTranscodingProgress > 0) {
                  progress = MAX(progress, 30);//the upload progress increases from 30% to 100%.
              }
              self.animateCircleView.progress = progress;
              if (progress >= 100 || progress == 0) {
                  [self.indicator stopAnimating];
                  self.play.hidden = NO;
                  self.animateCircleView.hidden = YES;
              } else {
                  [self.indicator startAnimating];
                  self.play.hidden = YES;
                  self.animateCircleView.hidden = NO;
              }
            }];

        } else {
            [[[RACObserve(data, thumbProgress) takeUntil:self.rac_prepareForReuseSignal] distinctUntilChanged] subscribeNext:^(NSNumber *x) {
              @strongify(self);
              // Cover download progress callback
              int progress = [x intValue];
              self.progress.text = [NSString stringWithFormat:@"%d%%", progress];
              self.progress.hidden = (progress >= 100 || progress == 0);
              self.animateCircleView.progress = progress;
              if (progress >= 100 || progress == 0) {
                  // The download video icon is displayed when the cover progress reaches 100
                  if ([data isVideoExist]) {
                      self.play.hidden = NO;
                  } else {
                      self.downloadImage.hidden = NO;
                  }
              } else {
                  self.play.hidden = YES;
                  self.downloadImage.hidden = YES;
              }
            }];

            // Video resource download progress callback
            [[[RACObserve(data, videoProgress) takeUntil:self.rac_prepareForReuseSignal] distinctUntilChanged] subscribeNext:^(NSNumber *x) {
              @strongify(self);
              int progress = [x intValue];
              self.animateCircleView.progress = progress;
              if (progress >= 100 || progress == 0) {
                  self.play.hidden = NO;
                  self.animateCircleView.hidden = YES;
              } else {
                  self.play.hidden = YES;
                  self.downloadImage.hidden = YES;
                  self.animateCircleView.hidden = NO;
              }
            }];
        }
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
    if (self.messageData.messageContainerAppendSize.height > 0) {
        CGFloat topMargin = 10;
        CGFloat tagViewTopMargin = 6;
        CGFloat thumbHeight = self.bubbleView.mm_h - topMargin - self.messageData.messageContainerAppendSize.height - tagViewTopMargin;
        [self.thumb mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(thumbHeight);
            make.width.mas_equalTo(self.bubbleView).multipliedBy(0.7);
            make.centerX.mas_equalTo(self.bubbleView);
            make.top.mas_equalTo(self.container).mas_offset(topMargin);
        }];
        [self.duration mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.thumb.mas_trailing).mas_offset(-2);
            make.width.mas_greaterThanOrEqualTo(20);
            make.height.mas_equalTo(20);
            make.bottom.mas_equalTo(self.thumb.mas_bottom);
        }];
    } else {
        [self.thumb mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.bubbleView).mas_offset(self.messageData.cellLayout.bubbleInsets.top);
            make.bottom.mas_equalTo(self.bubbleView).mas_offset(- self.messageData.cellLayout.bubbleInsets.bottom);
            make.leading.mas_equalTo(self.bubbleView).mas_offset(self.messageData.cellLayout.bubbleInsets.left);
            make.trailing.mas_equalTo(self.bubbleView).mas_offset(- self.messageData.cellLayout.bubbleInsets.right);
        }];
        [self.duration mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.thumb.mas_trailing).mas_offset(-2);
            make.width.mas_greaterThanOrEqualTo(20);
            make.height.mas_equalTo(20);
            make.bottom.mas_equalTo(self.thumb.mas_bottom);
        }];
    }
    
    
    BOOL hasRiskContent = self.messageData.innerMessage.hasRiskContent;
    if (hasRiskContent ) {
        [self.thumb mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.bubbleView).mas_offset(12);
            make.size.mas_equalTo(CGSizeMake(150, 150));
            make.centerX.mas_equalTo(self.bubbleView);
        }];
        
        [self.securityStrikeView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.thumb.mas_bottom);
            make.width.mas_equalTo(self.bubbleView);
            if(self.messageData.messageContainerAppendSize.height>0) {
                make.bottom.mas_equalTo(self.container).mas_offset(-self.messageData.messageContainerAppendSize.height);
            }
            else {
                make.bottom.mas_equalTo(self.container).mas_offset(-12);
            }
        }];
    }

    [self.play mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(TVideoMessageCell_Play_Size);
        make.center.mas_equalTo(self.thumb);
    }];
    [self.downloadImage mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(TVideoMessageCell_Play_Size);
        make.center.mas_equalTo(self.thumb);
    }];

    [self.animateCircleView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.thumb);
        make.size.mas_equalTo(CGSizeMake(kScale390(40), kScale390(40)));
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)highlightWhenMatchKeyword:(NSString *)keyword {
    if (keyword) {
        if (self.highlightAnimating) {
            return;
        }
        [self animate:3];
    }
}

- (void)animate:(int)times {
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
    [UIView animateWithDuration:0.25
        animations:^{
          self.animateHighlightView.alpha = 0.5;
        }
        completion:^(BOOL finished) {
          [UIView animateWithDuration:0.25
              animations:^{
                self.animateHighlightView.alpha = 0.1;
              }
              completion:^(BOOL finished) {
                if (!self.videoData.highlightKeyword) {
                    [self animate:0];
                    return;
                }
                [self animate:times];
              }];
        }];
}

- (UIView *)animateHighlightView {
    if (_animateHighlightView == nil) {
        _animateHighlightView = [[UIView alloc] init];
        _animateHighlightView.backgroundColor = [UIColor orangeColor];
    }
    return _animateHighlightView;
}

#pragma mark - TUIMessageProgressManagerDelegate
- (void)onUploadProgress:(NSString *)msgID progress:(NSInteger)progress {
    if (![msgID isEqualToString:self.videoData.msgID]) {
        return;
    }
    if (self.videoData.direction == MsgDirectionOutgoing) {
        self.videoData.uploadProgress = progress;
    }
}

#pragma mark - TUIMessageCellProtocol
+ (CGSize)getContentSize:(TUIMessageCellData *)data {
    NSAssert([data isKindOfClass:TUIVideoMessageCellData.class], @"data must be kind of TUIVideoMessageCellData");
    TUIVideoMessageCellData *videoCellData = (TUIVideoMessageCellData *)data;
    CGSize size = CGSizeZero;
    BOOL isDir = NO;
    if (![videoCellData.snapshotPath isEqualToString:@""] && [[NSFileManager defaultManager] fileExistsAtPath:videoCellData.snapshotPath isDirectory:&isDir]) {
        if (!isDir) {
            size = [UIImage imageWithContentsOfFile:videoCellData.snapshotPath].size;
        }
    } else {
        size = videoCellData.snapshotItem.size;
    }
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        return size;
    }
    if (size.height > size.width) {
        size.width = size.width / size.height * TVideoMessageCell_Image_Height_Max;
        size.height = TVideoMessageCell_Image_Height_Max;
    } else {
        size.height = size.height / size.width * TVideoMessageCell_Image_Width_Max;
        size.width = TVideoMessageCell_Image_Width_Max;
    }
    BOOL hasRiskContent = videoCellData.innerMessage.hasRiskContent;
    if (hasRiskContent) {
        CGFloat bubbleTopMargin = 12;
        CGFloat bubbleBottomMargin = 12;
        size.height = MAX(size.height, 150);// width must more than  TIMCommonBundleThemeImage(@"", @"icon_security_strike");
        size.width = MAX(size.width, 200);// width must more than  TIMCommonLocalizableString(TUIKitMessageTypeSecurityStrike)
        size.height += bubbleTopMargin;
        size.height += kTUISecurityStrikeViewTopLineMargin;
        size.height += kTUISecurityStrikeViewTopLineToBottom;
        size.height += bubbleBottomMargin;
    }
    return size;
}

@end
