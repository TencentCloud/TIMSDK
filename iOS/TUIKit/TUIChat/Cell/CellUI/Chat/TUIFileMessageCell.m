//
//  TFileMessageCell.m
//  UIKit
//
//  Created by annidyfeng on 2019/5/30.
//

#import "TUIFileMessageCell.h"
#import "TUIDefine.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "TUIThemeManager.h"
#import "TUIMessageProgressManager.h"

@interface TUIFileMessageCell () <V2TIMSDKListener, TUIMessageProgressManagerDelegate>

@property (nonatomic, strong) CAShapeLayer *maskLayer;
@property (nonatomic, strong) CAShapeLayer *borderLayer;
@property (nonatomic, strong) UIView *progressView;
@property (nonatomic, strong) UIView *fileContainer;

@property (nonatomic, strong) UIView *animateHighlightView;


@end

@implementation TUIFileMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.container addSubview:self.fileContainer];
        self.fileContainer.backgroundColor = TUIChatDynamicColor(@"chat_file_message_bg_color", @"#FFFFFF");
        [self.fileContainer addSubview:self.progressView];

        _fileName = [[UILabel alloc] init];
        _fileName.font = [UIFont systemFontOfSize:15];
        _fileName.textColor = TUIChatDynamicColor(@"chat_file_message_title_color", @"#000000");
        [self.fileContainer addSubview:_fileName];

        _length = [[UILabel alloc] init];
        _length.font = [UIFont systemFontOfSize:12];
        _length.textColor = TUIChatDynamicColor(@"chat_file_message_subtitle_color", @"#888888");
        [self.fileContainer addSubview:_length];

        _image = [[UIImageView alloc] init];
        _image.image = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"msg_file")];
        _image.contentMode = UIViewContentModeScaleAspectFit;
        [self.fileContainer addSubview:_image];
        
        [self.fileContainer.layer insertSublayer:self.borderLayer atIndex:0];
        [self.fileContainer.layer setMask:self.maskLayer];
        
        [self prepareReactTagUI:self.container];
        [V2TIMManager.sharedInstance addIMSDKListener:self];
        [TUIMessageProgressManager.shareManager addDelegate:self];
    }
    return self;
}

- (void)fillWithData:(TUIFileMessageCellData *)data
{
    //set data
    [super fillWithData:data];
    self.fileData = data;
    _fileName.text = data.fileName;
    _length.text = [self formatLength:data.length];

    @weakify(self)
    
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self)
        NSInteger progress = self.fileData.direction == MsgDirectionIncoming?self.fileData.downladProgress:self.fileData.uploadProgress;
        [self updateProgress:(int)progress];
    });
}

- (void)onProgress:(NSString *)msgID progress:(NSInteger)progress
{
    if (![msgID isEqualToString:self.fileData.msgID]) {
        return;
    }
    
    if (self.fileData.direction == MsgDirectionIncoming) {
        self.fileData.downladProgress = progress;
    } else {
        self.fileData.uploadProgress = progress;
    }
    [self updateProgress:(int)progress];
}

- (void)updateProgress:(int)progress
{
    [self.indicator startAnimating];
    self.progressView.hidden = YES;
    self.length.text = [self formatLength:self.fileData.length];
    
    if (progress >= 100 || progress == 0) {
        [self.indicator stopAnimating];
        return;
    }
    
    if(self.fileData.direction == MsgDirectionOutgoing &&
       self.fileData.status != Msg_Status_Sending &&
       self.fileData.status != Msg_Status_Sending_2) {
        [self.indicator stopAnimating];
        return;
    }
    
    if (self.fileData.direction == MsgDirectionIncoming &&
        self.fileData.path.length) {
        [self.indicator stopAnimating];
        return;
    }
    
    self.progressView.hidden = NO;
    self.progressView.frame = CGRectMake(0, 0, self.progressView.mm_w?:1, self.fileContainer.mm_h);
    [UIView animateWithDuration:0.25 animations:^{
        self.progressView.mm_x = 0;
        self.progressView.mm_y = 0;
        self.progressView.mm_h = self.fileContainer.mm_h;
        self.progressView.mm_w = self.fileContainer.mm_w * progress / 100.0;
    } completion:^(BOOL finished) {
        if (progress == 0 || progress >= 100) {
            self.progressView.hidden = YES;
            [self.indicator stopAnimating];
            self.length.text = [self formatLength:self.fileData.length];
        }
    }];
    
    self.length.text = [self formatLength:self.fileData.length];
}

- (NSString *)formatLength:(long)length
{
    // 默认显示文件大小
    double len = length;
    NSArray *array = [NSArray arrayWithObjects:@"Bytes", @"K", @"M", @"G", @"T", nil];
    int factor = 0;
    while (len > 1024) {
        len /= 1024;
        factor++;
        if(factor >= 4){
            break;
        }
    }
    NSString *str = [NSString stringWithFormat:@"%4.2f%@", len, array[factor]];
    
    // 格式化显示字符
    if (self.fileData.direction == MsgDirectionOutgoing) {
        if (length == 0 && (self.fileData.status == Msg_Status_Sending || self.fileData.status == Msg_Status_Sending_2)) {
            // 发送中 && 当前文件大小位置
            str = [NSString stringWithFormat:@"%zd%%", self.fileData.direction == MsgDirectionIncoming?self.fileData.downladProgress:self.fileData.uploadProgress];
        }
    } else {
        if (!self.fileData.isLocalExist && !self.fileData.isDownloading) {
            // 未下载
            str = [NSString stringWithFormat:@"%@ %@", str, TUIKitLocalizableString(TUIKitNotDownload)];
        }
    }
    
    return str;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGSize containerSize = [self.fileData contentSize];
    self.fileContainer.frame = CGRectMake(0, 0, containerSize.width, containerSize.height);
    CGFloat imageHeight = containerSize.height - 2 * TFileMessageCell_Margin;
    CGFloat imageWidth = imageHeight;
    _image.frame = CGRectMake(containerSize.width - TFileMessageCell_Margin - imageWidth, TFileMessageCell_Margin, imageWidth, imageHeight);
    CGFloat textWidth = _image.frame.origin.x - 2 * TFileMessageCell_Margin;
    CGSize nameSize = [_fileName sizeThatFits:containerSize];
    _fileName.frame = CGRectMake(TFileMessageCell_Margin, TFileMessageCell_Margin, textWidth, nameSize.height);
    CGSize lengthSize = [_length sizeThatFits:containerSize];
    _length.frame = CGRectMake(TFileMessageCell_Margin, _fileName.frame.origin.y + nameSize.height + TFileMessageCell_Margin * 0.5, textWidth, lengthSize.height);
      
    if (self.messageData.messageModifyReactsSize.height > 0) {
        self.fileContainer.frame = CGRectMake(0, 0, self.container.frame.size.width, self.container.frame.size.height );
        if (self.tagView) {
            self.tagView.frame = CGRectMake(0, TFileMessageCell_Margin + imageHeight  , self.fileContainer.frame.size.width, self.messageData.messageModifyReactsSize.height);
        }
        self.bubble.hidden = NO;
    }
    else {
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
}

- (CAShapeLayer *)maskLayer
{
    if (_maskLayer == nil) {
        _maskLayer = [CAShapeLayer layer];
    }
    return _maskLayer;
}

- (CAShapeLayer *)borderLayer
{
    if (_borderLayer == nil) {
        _borderLayer = [CAShapeLayer layer];
        _borderLayer.lineWidth = 0.5f;
        _borderLayer.strokeColor = [UIColor colorWithRed:221/255.0 green:221/255.0 blue:221/255.0 alpha:1.0].CGColor;
        _borderLayer.fillColor = [UIColor clearColor].CGColor;
    }
    return _borderLayer;
}

- (UIView *)progressView
{
    if (_progressView == nil) {
        _progressView = [[UIView alloc] init];
        _progressView.backgroundColor = [UIColor colorWithRed:208/255.0 green:228/255.0 blue:255/255.0 alpha:1/1.0];
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

- (void)onConnectSuccess
{
    // 重新赋值
    [self fillWithData:self.fileData];
}


- (void)highlightWhenMatchKeyword:(NSString *)keyword
{
    // 默认高亮效果，闪烁
    if (keyword) {
        // 显示高亮动画
        if (self.highlightAnimating) {
            return;
        }
        [self animate:3];
    }
}

// 默认高亮动画
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
    [self.fileContainer addSubview:self.animateHighlightView];
    [UIView animateWithDuration:0.25 animations:^{
        self.animateHighlightView.alpha = 0.5;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.25 animations:^{
            self.animateHighlightView.alpha = 0.1;
        } completion:^(BOOL finished) {
            if (!self.messageData.highlightKeyword) {
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
@end
