//
//  TFileMessageCell.m
//  UIKit
//
//  Created by annidyfeng on 2019/5/30.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIFileMessageCell.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIThemeManager.h>
#import "ReactiveObjC/ReactiveObjC.h"
#import "TUIMessageProgressManager.h"
#import <TUICore/TUICore.h>

@interface TUIFileMessageCell () <V2TIMSDKListener, TUIMessageProgressManagerDelegate>

@property(nonatomic, strong) CAShapeLayer *maskLayer;
@property(nonatomic, strong) CAShapeLayer *borderLayer;
@property(nonatomic, strong) UIView *progressView;
@property(nonatomic, strong) UIView *fileContainer;

@property(nonatomic, strong) UIView *animateHighlightView;

@end

@implementation TUIFileMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.container addSubview:self.fileContainer];
        self.fileContainer.backgroundColor = TUIChatDynamicColor(@"chat_file_message_bg_color", @"#FFFFFF");
        [self.fileContainer addSubview:self.progressView];

        _fileName = [[UILabel alloc] init];
        _fileName.font = [UIFont boldSystemFontOfSize:15];
        _fileName.textColor = TUIChatDynamicColor(@"chat_file_message_title_color", @"#000000");
        [self.fileContainer addSubview:_fileName];

        _length = [[UILabel alloc] init];
        _length.font = [UIFont systemFontOfSize:12];
        _length.textColor = TUIChatDynamicColor(@"chat_file_message_subtitle_color", @"#888888");
        [self.fileContainer addSubview:_length];

        _image = [[UIImageView alloc] init];
        _image.image = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"msg_file_p")];
        _image.contentMode = UIViewContentModeScaleAspectFit;
        [self.fileContainer addSubview:_image];

        [self.fileContainer.layer insertSublayer:self.borderLayer atIndex:0];
        [self.fileContainer.layer setMask:self.maskLayer];

        [V2TIMManager.sharedInstance addIMSDKListener:self];
        [TUIMessageProgressManager.shareManager addDelegate:self];
    }
    return self;
}

- (void)fillWithData:(TUIFileMessageCellData *)data {
    // set data
    [super fillWithData:data];
    self.fileData = data;
    _fileName.text = data.fileName;
    _length.text = [self formatLength:data.length];
    _image.image = [[TUIImageCache sharedInstance] getResourceFromCache:[self getImagePathByCurrentFileType:data.fileName.pathExtension]];
    @weakify(self);
    [self prepareReactTagUI:self.container];

    dispatch_async(dispatch_get_main_queue(), ^{
      @strongify(self);
      NSInteger uploadProgress = [TUIMessageProgressManager.shareManager uploadProgressForMessage:self.fileData.msgID];
      NSInteger downloadProgress = [TUIMessageProgressManager.shareManager downloadProgressForMessage:self.fileData.msgID];
      [self onUploadProgress:self.fileData.msgID progress:uploadProgress];
      [self onDownloadProgress:self.fileData.msgID progress:downloadProgress];
        
      // tell constraints they need updating
      [self setNeedsUpdateConstraints];

      // update constraints now so we can animate the change
      [self updateConstraintsIfNeeded];

      [self layoutIfNeeded];

    });
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
    [self showProgressLodingAnimation:progress];
}
- (void)updateDownloadProgress:(int)progress {
    [self.indicator startAnimating];
    self.progressView.hidden = YES;
    self.length.text = [self formatLength:self.fileData.length];

    if (progress >= 100 || progress == 0) {
        [self.indicator stopAnimating];
        return;
    }

    [self showProgressLodingAnimation:progress];
}
- (void)showProgressLodingAnimation:(NSInteger)progress {
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
        }
    }];

    self.length.text = [self formatLength:self.fileData.length];
}
- (NSString *)formatLength:(long)length {
    /**
     * 默认显示文件大小
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
     * 格式化显示字符
     * Formatted display characters
     */
    if (self.fileData.direction == MsgDirectionOutgoing) {
        if (length == 0 && (self.fileData.status == Msg_Status_Sending || self.fileData.status == Msg_Status_Sending_2)) {
            str = [NSString
                stringWithFormat:@"%zd%%", self.fileData.direction == MsgDirectionIncoming ? self.fileData.downladProgress : self.fileData.uploadProgress];
        }
    } else {
        if (!self.fileData.isLocalExist && !self.fileData.isDownloading) {
            str = [NSString stringWithFormat:@"%@ %@", str, TIMCommonLocalizableString(TUIKitNotDownload)];
        }
    }

    return str;
}
- (NSString *)getImagePathByCurrentFileType:(NSString *)pathExtension {
    if (pathExtension.length > 0) {
        if ([pathExtension hasSuffix:@"ppt"] || [pathExtension hasSuffix:@"key"] || [pathExtension hasSuffix:@"pdf"]) {
            return TUIChatImagePath(@"msg_file_p");
        }
    }
    return TUIChatImagePath(@"msg_file");
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

// this is Apple's recommended place for adding/updating constraints
- (void)updateConstraints {
    [super updateConstraints];
    
    CGSize containerSize = [self.class getContentSize:self.fileData];
    [self.fileContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self.container);
        make.size.mas_equalTo(containerSize);
    }];
    
    CGFloat imageHeight = containerSize.height - 2 * TFileMessageCell_Margin;
    CGFloat imageWidth = imageHeight;
    [self.image mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.container.mas_leading).mas_offset(TFileMessageCell_Margin);
        make.top.mas_equalTo(self.container.mas_top).mas_offset(TFileMessageCell_Margin);
        make.size.mas_equalTo(CGSizeMake(imageWidth, imageHeight));
    }];

    CGFloat textWidth = containerSize.width - 2 * TFileMessageCell_Margin - imageWidth;
    CGSize nameSize = [_fileName sizeThatFits:containerSize];

    [self.fileName mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.image.mas_trailing).mas_offset(TFileMessageCell_Margin);
        make.top.mas_equalTo(self.image);
        make.size.mas_equalTo(CGSizeMake(textWidth, nameSize.height));
    }];

    CGSize lengthSize = [_length sizeThatFits:containerSize];
    [self.length mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.fileName);
        make.top.mas_equalTo(self.fileName.mas_bottom).mas_offset(TFileMessageCell_Margin * 0.5);
        make.size.mas_equalTo(CGSizeMake(textWidth, nameSize.height));
    }];
    
    
    if (self.messageData.messageContainerAppendSize.height > 0) {
        [self.fileContainer mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(self.container);
            make.size.mas_equalTo(self.container);
        }];
        self.bubble.hidden = NO;
    } else {
        self.bubble.hidden = YES;
    }

    self.maskLayer.frame = self.fileContainer.bounds;
    self.borderLayer.frame = self.fileContainer.bounds;

    UIRectCorner corner = UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerTopLeft;
    if (self.fileData.direction == MsgDirectionIncoming) {
        corner = UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerTopRight;
    }
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:self.fileContainer.bounds byRoundingCorners:corner cornerRadii:CGSizeMake(10, 10)];
    self.maskLayer.path = bezierPath.CGPath;
    self.borderLayer.path = bezierPath.CGPath;
    
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

- (CAShapeLayer *)maskLayer {
    if (_maskLayer == nil) {
        _maskLayer = [CAShapeLayer layer];
    }
    return _maskLayer;
}

- (CAShapeLayer *)borderLayer {
    if (_borderLayer == nil) {
        _borderLayer = [CAShapeLayer layer];
        _borderLayer.lineWidth = 0.5f;
        _borderLayer.strokeColor = [UIColor colorWithRed:221 / 255.0 green:221 / 255.0 blue:221 / 255.0 alpha:1.0].CGColor;
        _borderLayer.fillColor = [UIColor clearColor].CGColor;
    }
    return _borderLayer;
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
        _fileContainer.backgroundColor = TUIChatDynamicColor(@"chat_file_message_bg_color", @"#FFFFFF");
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
    self.animateHighlightView.frame = self.container.bounds;
    self.animateHighlightView.alpha = 0.1;
    [self.fileContainer addSubview:self.animateHighlightView];
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
    }
    return _animateHighlightView;
}

- (void)prepareReactTagUI:(UIView *)containerView {
    NSDictionary *param = @{TUICore_TUIChatExtension_ChatMessageReactPreview_Delegate: self};
    [TUICore raiseExtension:TUICore_TUIChatExtension_ChatMessageReactPreview_ClassicExtensionID parentView:containerView param:param];
}

#pragma mark - TUIMessageCellProtocol
+ (CGSize)getContentSize:(TUIMessageCellData *)data {
    return TFileMessageCell_Container_Size;
}

@end
