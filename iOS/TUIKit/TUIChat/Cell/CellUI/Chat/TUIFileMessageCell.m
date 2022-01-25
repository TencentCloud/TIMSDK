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

@end

@implementation TUIFileMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.container.backgroundColor = TUIChatDynamicColor(@"chat_file_message_bg_color", @"#FFFFFF");
        [self.container addSubview:self.progressView];

        _fileName = [[UILabel alloc] init];
        _fileName.font = [UIFont systemFontOfSize:15];
        _fileName.textColor = TUIChatDynamicColor(@"chat_file_message_title_color", @"#000000");
        [self.container addSubview:_fileName];

        _length = [[UILabel alloc] init];
        _length.font = [UIFont systemFontOfSize:12];
        _length.textColor = TUIChatDynamicColor(@"chat_file_message_subtitle_color", @"#888888");
        [self.container addSubview:_length];

        _image = [[UIImageView alloc] init];
        _image.image = [[TUIImageCache sharedInstance] getResourceFromCache:TUIChatImagePath(@"msg_file")];
        _image.contentMode = UIViewContentModeScaleAspectFit;
        [self.container addSubview:_image];
        
        [self.container.layer insertSublayer:self.borderLayer atIndex:0];
        [self.container.layer setMask:self.maskLayer];
        
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
    self.progressView.frame = CGRectMake(0, 0, self.progressView.mm_w?:1, self.container.mm_h);
    [UIView animateWithDuration:0.25 animations:^{
        self.progressView.mm_x = 0;
        self.progressView.mm_y = 0;
        self.progressView.mm_h = self.container.mm_h;
        self.progressView.mm_w = self.container.mm_w * progress / 100.0;
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
    CGFloat imageHeight = containerSize.height - 2 * TFileMessageCell_Margin;
    CGFloat imageWidth = imageHeight;
    _image.frame = CGRectMake(containerSize.width - TFileMessageCell_Margin - imageWidth, TFileMessageCell_Margin, imageWidth, imageHeight);
    CGFloat textWidth = _image.frame.origin.x - 2 * TFileMessageCell_Margin;
    CGSize nameSize = [_fileName sizeThatFits:containerSize];
    _fileName.frame = CGRectMake(TFileMessageCell_Margin, TFileMessageCell_Margin, textWidth, nameSize.height);
    CGSize lengthSize = [_length sizeThatFits:containerSize];
    _length.frame = CGRectMake(TFileMessageCell_Margin, _fileName.frame.origin.y + nameSize.height + TFileMessageCell_Margin * 0.5, textWidth, lengthSize.height);
    
    
    
    self.maskLayer.frame = self.container.bounds;
    self.borderLayer.frame = self.container.bounds;
    

    UIRectCorner corner = UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerTopLeft;
    if (self.fileData.direction == MsgDirectionIncoming) {
        corner = UIRectCornerBottomLeft | UIRectCornerBottomRight | UIRectCornerTopRight;
    }
    UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:self.container.bounds byRoundingCorners:corner cornerRadii:CGSizeMake(10, 10)];
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
        _borderLayer.lineWidth = 1.f;
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

- (void)onConnectSuccess
{
    // 重新赋值
    [self fillWithData:self.fileData];
}

@end
