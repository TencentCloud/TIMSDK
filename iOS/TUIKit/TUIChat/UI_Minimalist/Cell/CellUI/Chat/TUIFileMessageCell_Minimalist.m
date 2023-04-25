//
//  TUIFileMessageCell_Minimalist.m
//  UIKit
//
//  Created by annidyfeng on 2019/5/30.
//

#import "TUIFileMessageCell_Minimalist.h"
#import "TUIMessageProgressManager.h"
#import <TUICore/TUIThemeManager.h>
#import <TIMCommon/TIMDefine.h>
#import "ReactiveObjC/ReactiveObjC.h"

@interface TUIFileMessageCell_Minimalist () <V2TIMSDKListener, TUIMessageProgressManagerDelegate>
@property (nonatomic, strong) UIView *fileContainer;
@property (nonatomic, strong) UIView *animateHighlightView;
@end

@implementation TUIFileMessageCell_Minimalist

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self.bubbleView addSubview:self.fileContainer];
        
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

- (void)fillWithData:(TUIFileMessageCellData_Minimalist *)data
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
    self.length.text = [self formatLength:self.fileData.length];
    
    if (progress >= 100 || progress == 0) {
        return;
    }
    
    self.length.text = [self formatLength:self.fileData.length];
}

- (NSString *)formatLength:(long)length
{
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
        if(factor >= 4){
            break;
        }
    }
    NSString *str = [NSString stringWithFormat:@"%4.2f%@", len, array[factor]];
    
    /**
     * 格式化显示字符
     * Formatted display characters
     */
    if (self.fileData.isDownloading || (length == 0 && (self.fileData.status == Msg_Status_Sending || self.fileData.status == Msg_Status_Sending_2))) {
        str = [NSString stringWithFormat:@"%zd%%", self.fileData.direction == MsgDirectionIncoming?self.fileData.downladProgress:self.fileData.uploadProgress];
    }
    return str;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGSize containerSize = [self.fileData contentSize];
    
    _fileContainer.mm_width(containerSize.width - kScale390(32)).mm_height(48).mm_left(kScale390(16)).mm_top(8);
    
    CGFloat fileImageSize = 24;
    _fileImage.mm_width(fileImageSize).mm_height(fileImageSize).mm_left(kScale390(12)).mm_top(12);
    
    CGFloat fileNameX = _fileImage.mm_maxX + kScale390(8);
    _fileName.mm_width(_fileContainer.mm_w - fileNameX - kScale390(12)).mm_height(17).mm_left(fileNameX).mm_top(15);
  
    _length.mm_width(150).mm_height(14).mm_left(kScale390(22)).mm_top(_fileContainer.mm_maxY + 11);
    
    if (!self.fileData.isLocalExist && !self.fileData.isDownloading) {
        CGFloat downloadSize = 16;
        CGFloat downloadX = 0;
        if (self.fileData.direction == MsgDirectionIncoming) {
            downloadX = self.container.mm_maxX + kScale390(8);
        } else {
            downloadX = self.container.mm_x - kScale390(8) - downloadSize;
        }
        _downloadImage.frame = CGRectMake(downloadX, self.fileContainer.mm_y + _fileName.mm_y, downloadSize, downloadSize);
    } else {
        _downloadImage.frame = CGRectZero;
    }
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

- (void)onConnectSuccess
{
    [self fillWithData:self.fileData];
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
    self.animateHighlightView.frame = self.bubbleView.bounds;
    self.animateHighlightView.alpha = 0.1;
    [self.container addSubview:self.animateHighlightView];
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
        _animateHighlightView.layer.cornerRadius = 12;
        _animateHighlightView.layer.masksToBounds = YES;
    }
    return _animateHighlightView;
}
@end
