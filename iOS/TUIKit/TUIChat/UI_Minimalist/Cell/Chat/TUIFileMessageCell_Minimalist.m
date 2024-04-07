//
//  TUIFileMessageCell_Minimalist.m
//  UIKit
//
//  Created by annidyfeng on 2019/5/30.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIFileMessageCell_Minimalist.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIThemeManager.h>
#import "ReactiveObjC/ReactiveObjC.h"
#import "TUIMessageProgressManager.h"

@interface TUIFileMessageCell_Minimalist () <V2TIMSDKListener, TUIMessageProgressManagerDelegate>
@property(nonatomic, strong) UIView *fileContainer;
@property(nonatomic, strong) UIView *animateHighlightView;
@property(nonatomic, strong) UIView *progressView;
@end

@implementation TUIFileMessageCell_Minimalist

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.bubbleView addSubview:self.fileContainer];
        [self.fileContainer addSubview:self.progressView];

        _fileImage = [[UIImageView alloc] init];
        _fileImage.image = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"msg_file")];
        _fileImage.contentMode = UIViewContentModeScaleAspectFit;
        [self.fileContainer addSubview:_fileImage];

        _fileName = [[UILabel alloc] init];
        _fileName.font = [UIFont systemFontOfSize:14];
        _fileName.textColor = [UIColor blackColor];
        [self.fileContainer addSubview:_fileName];

        _length = [[UILabel alloc] init];
        _length.font = [UIFont systemFontOfSize:12];
        _length.textColor = RGBA(122, 122, 122, 1);
        [self.bubbleView addSubview:_length];

        _downloadImage = [[UIImageView alloc] init];
        _downloadImage.image = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath_Minimalist(@"file_download")];
        _downloadImage.contentMode = UIViewContentModeScaleAspectFit;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(downloadClick)];
        [_downloadImage addGestureRecognizer:tap];
        [_downloadImage setUserInteractionEnabled:YES];
        [self.contentView addSubview:_downloadImage];

        [V2TIMManager.sharedInstance addIMSDKListener:self];
        [TUIMessageProgressManager.shareManager addDelegate:self];
    }
    return self;
}

- (void)downloadClick {
    _downloadImage.frame = CGRectZero;
    if (self.delegate && [self.delegate respondsToSelector:@selector(onSelectMessage:)]) {
        [self.delegate onSelectMessage:self];
    }
}

- (void)fillWithData:(TUIFileMessageCellData *)data {
    // set data
    [super fillWithData:data];
    self.fileData = data;
    _fileName.text = data.fileName;
    _length.text = [self formatLength:data.length];

    @weakify(self);

    dispatch_async(dispatch_get_main_queue(), ^{
      @strongify(self);
        NSInteger uploadProgress = [TUIMessageProgressManager.shareManager uploadProgressForMessage:self.fileData.msgID];
        NSInteger downloadProgress = [TUIMessageProgressManager.shareManager downloadProgressForMessage:self.fileData.msgID];
        [self onUploadProgress:self.fileData.msgID progress:uploadProgress];
        [self onDownloadProgress:self.fileData.msgID progress:downloadProgress];
        
    });
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
    
    CGSize containerSize = [self.class getContentSize:self.fileData];
    [self.fileContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(containerSize.width - kScale390(32));
        make.height.mas_equalTo(48);
        make.leading.mas_equalTo(kScale390(16));
        make.top.mas_equalTo(self.bubbleView).mas_offset(8);
    }];


    CGFloat fileImageSize = 24;
    
    [self.fileImage mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.container.mas_leading).mas_offset(kScale390(17));
        make.top.mas_equalTo(self.container.mas_top).mas_offset(kScale390(12));
        make.size.mas_equalTo(fileImageSize);
    }];

    [self.fileName mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.fileImage.mas_trailing).mas_offset(kScale390(8));
        make.top.mas_equalTo(15);
        make.trailing.mas_equalTo(self.container.mas_trailing).mas_offset(- kScale390(12));
        make.height.mas_equalTo(17);
    }];

    [self.length mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.container).mas_offset(kScale390(22));
        make.bottom.mas_equalTo(self.container.mas_bottom).mas_offset(- 11);
        make.size.mas_equalTo(CGSizeMake(150, 14));
    }];

    if (!self.fileData.isLocalExist && !self.fileData.isDownloading) {
        CGFloat downloadSize = 16;
        [self.downloadImage mas_remakeConstraints:^(MASConstraintMaker *make) {
            if (self.fileData.direction == MsgDirectionIncoming) {
                make.leading.mas_equalTo(self.bubbleView.mas_trailing).mas_offset(kScale390(8));
            } else {
                make.trailing.mas_equalTo(self.bubbleView.mas_leading).mas_offset(- kScale390(8));
            }
            make.centerY.mas_equalTo(self.length.mas_centerY);
            make.height.width.mas_equalTo(downloadSize);
        }];
    } else {
        _downloadImage.frame = CGRectZero;
    }
    [self.progressView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.width.mas_equalTo(self.progressView.mm_w ?: 1);
        make.height.mas_equalTo(self.fileContainer.mm_h);
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

#pragma mark - TUIMessageProgressManagerDelegate
- (void)onUploadProgress:(NSString *)msgID progress:(NSInteger)progress {
    if (![msgID isEqualToString:self.fileData.msgID]) {
        return;
    }

    self.fileData.uploadProgress = progress;
    [self updateUploadProgress:(int)progress];
}

- (void)onDownloadProgress:(NSString *)msgID progress:(NSInteger)progress {
    if (![msgID isEqualToString:self.fileData.msgID]) {
        return;
    }
    self.fileData.downladProgress = progress;
    [self updateDownloadProgress:(int)progress];
}

- (void)updateUploadProgress:(int)progress {
    [self.indicator startAnimating];
    self.progressView.hidden = YES;
    self.length.text = [self formatLength:self.fileData.length];
    NSLog(@"updateProgress:%ld,isLocalExist:%@,isDownloading:%@", (long)progress, self.fileData.isLocalExist ? @"YES" : @"NO",
          self.fileData.isDownloading ? @"YES" : @"NO");
    if (progress >= 100 || progress == 0) {
        [self.indicator stopAnimating];
        return;
    }
    [self showProgressLoadingAnimation:progress];
}
- (void)updateDownloadProgress:(int)progress {
    [self.indicator startAnimating];
    self.progressView.hidden = YES;
    self.length.text = [self formatLength:self.fileData.length];
    if (!self.fileData.isLocalExist && !self.fileData.isDownloading) {
        _downloadImage.hidden = NO;
    } else {
        _downloadImage.hidden = YES;
    }
    
    if (progress >= 100 || progress == 0) {
        [self.indicator stopAnimating];
        return;
    }
    
    [self showProgressLoadingAnimation:progress];
}

- (void)showProgressLoadingAnimation:(NSInteger)progress {
    self.progressView.hidden = NO;
    NSLog(@"showProgressLodingAnimation:%ld", (long)progress);
    [UIView animateWithDuration:0.25
        animations:^{
        [self.progressView mas_updateConstraints:^(MASConstraintMaker *make) {
          make.width.mas_equalTo(self.fileContainer.mm_w * progress / 100.0);
        }];
    }
        completion:^(BOOL finished) {
        if (progress == 0 || progress >= 100) {
            self.progressView.hidden = YES;
            [self.indicator stopAnimating];
            self.length.text = [self formatLength:self.fileData.length];
            self.downloadImage.hidden = YES;
        }
    }];

    self.length.text = [self formatLength:self.fileData.length];
}

- (NSString *)formatLength:(long)length {
    /**
     * 
     * Display file size by default
     */
    double len = length;
    NSArray *array = [NSArray arrayWithObjects:@"Bytes", @"K", @"M", @"G", @"T", nil];
    int factor = 0;
    while (len > 1024) {
        len /= 1024;
        factor++;
        if (factor >= 4) {
            break;
        }
    }
    NSString *str = [NSString stringWithFormat:@"%4.2f%@", len, array[factor]];

    /**
     * 
     * Formatted display characters
     */
    if (self.fileData.isDownloading || (length == 0 && (self.fileData.status == Msg_Status_Sending || self.fileData.status == Msg_Status_Sending_2))) {
        str = [NSString
            stringWithFormat:@"%zd%%", self.fileData.direction == MsgDirectionIncoming ? self.fileData.downladProgress : self.fileData.uploadProgress];
    }
    return str;
}


- (UIView *)progressView {
    if (_progressView == nil) {
        _progressView = [[UIView alloc] init];
        _progressView.backgroundColor = [UIColor colorWithRed:208 / 255.0 green:228 / 255.0 blue:255 / 255.0 alpha:1 / 1.0];
    }
    return _progressView;
}

- (UIView *)fileContainer {
    if (_fileContainer == nil) {
        _fileContainer = [[UIView alloc] init];
        _fileContainer.backgroundColor = [UIColor whiteColor];
        _fileContainer.layer.cornerRadius = 16;
        _fileContainer.layer.masksToBounds = YES;
    }
    return _fileContainer;
}

- (void)onConnectSuccess {
    [self fillWithData:self.fileData];
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
    self.animateHighlightView.frame = self.bubbleView.bounds;
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
                if (!self.messageData.highlightKeyword) {
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
        _animateHighlightView.layer.cornerRadius = 12;
        _animateHighlightView.layer.masksToBounds = YES;
    }
    return _animateHighlightView;
}

#pragma mark - TUIMessageCellProtocol
+ (CGSize)getContentSize:(TUIMessageCellData *)data {
    CGSize size = CGSizeMake(kScale390(250), 90);
    return size;
}

@end
