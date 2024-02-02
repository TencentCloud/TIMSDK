//
//  TUIImageMessageCell.m
//  UIKit
//
//  Created by annidyfeng on 2019/5/30.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIImageMessageCell.h"
#import <TIMCommon/TIMDefine.h>

@interface TUIImageMessageCell ()

@property(nonatomic, strong) UIView *animateHighlightView;

@end

@implementation TUIImageMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _thumb = [[UIImageView alloc] init];
        _thumb.layer.cornerRadius = 5.0;
        [_thumb.layer setMasksToBounds:YES];
        _thumb.contentMode = UIViewContentModeScaleAspectFit;
        _thumb.backgroundColor = [UIColor clearColor];        
        [self.container addSubview:_thumb];
        _progress = [[UILabel alloc] init];
        _progress.textColor = [UIColor whiteColor];
        _progress.font = [UIFont systemFontOfSize:15];
        _progress.textAlignment = NSTextAlignmentCenter;
        _progress.layer.cornerRadius = 5.0;
        _progress.hidden = YES;
        _progress.backgroundColor = TImageMessageCell_Progress_Color;
        [_progress.layer setMasksToBounds:YES];
        [self.container addSubview:_progress];
        [self makeConstraints];
    }
    return self;
}

- (void)fillWithData:(TUIImageMessageCellData *)data;
{
    // set data
    [super fillWithData:data];
    self.imageData = data;
    _thumb.image = nil;
    BOOL hasRiskContent = self.messageData.innerMessage.hasRiskContent;
    if (hasRiskContent) {
        self.thumb.image = TIMCommonBundleThemeImage(@"", @"icon_security_strike");
        self.securityStrikeView.textLabel.text = TIMCommonLocalizableString(TUIKitMessageTypeSecurityStrikeImage);
        self.progress.hidden = YES;
        return;
    }
    if (data.thumbImage == nil) {
        [data downloadImage:TImage_Type_Thumb];
    }

    @weakify(self);
    [[RACObserve(data, thumbImage) takeUntil:self.rac_prepareForReuseSignal] subscribeNext:^(UIImage *thumbImage) {
        @strongify(self);
        if (thumbImage) {
            self.thumb.image = thumbImage;
        }
    }];

    [[[RACObserve(data, thumbProgress) takeUntil:self.rac_prepareForReuseSignal] distinctUntilChanged] subscribeNext:^(NSNumber *x) {
      @strongify(self);
      int progress = [x intValue];
      self.progress.text = [NSString stringWithFormat:@"%d%%", progress];
      self.progress.hidden = (progress >= 100 || progress == 0);
    }];
     
    // tell constraints they need updating
    [self setNeedsUpdateConstraints];

    // update constraints now so we can animate the change
    [self updateConstraintsIfNeeded];

    [self layoutIfNeeded];

}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)makeConstraints {
    [self.thumb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.bubbleView);
        make.width.mas_equalTo(self.bubbleView);
        make.top.mas_equalTo(self.bubbleView);
        make.leading.mas_equalTo(self.bubbleView);
    }];
    
    [self.progress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.bubbleView);
    }];
}
// this is Apple's recommended place for adding/updating constraints
- (void)updateConstraints {

    [super updateConstraints];

    if (self.imageData.isSuperLongImage) {
        self.thumb.contentMode = UIViewContentModeScaleToFill;
    }
    else {
        self.thumb.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    CGFloat topMargin = 0;
    CGFloat height = self.bubbleView.mm_h;
    if (self.messageData.messageContainerAppendSize.height > 0) {
        topMargin = 10;
        CGFloat tagViewTopMargin = 6;
        height = self.bubbleView.mm_h - topMargin - self.messageData.messageContainerAppendSize.height - tagViewTopMargin;
        [self.thumb mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(height);
            make.width.mas_equalTo(self.bubbleView.mas_width);
            make.top.mas_equalTo(self.bubbleView).mas_offset(topMargin);
            make.leading.mas_equalTo(self.bubbleView);
        }];
    } else {
        [self.thumb mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.bubbleView).mas_offset(self.messageData.cellLayout.bubbleInsets.top);
            make.bottom.mas_equalTo(self.bubbleView).mas_offset(-self.messageData.cellLayout.bubbleInsets.bottom);
            make.leading.mas_equalTo(self.bubbleView).mas_offset(self.messageData.cellLayout.bubbleInsets.left);
            make.trailing.mas_equalTo(self.bubbleView).mas_offset(-self.messageData.cellLayout.bubbleInsets.right);
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
            make.bottom.mas_equalTo(self.container).mas_offset(- self.messageData.messageContainerAppendSize.height);
        }];
    }

    [self.progress mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.bubbleView);
    }];
    [self.selectedView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];
    [self.selectedIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.contentView.mas_leading).mas_offset(3);
        make.top.mas_equalTo(self.avatarView.mas_centerY).mas_offset(-10);
        if (self.messageData.showCheckBox) {
            make.width.mas_equalTo(20);
            make.height.mas_equalTo(20);
        } else {
            make.size.mas_equalTo(CGSizeZero);
        }
    }];

    [self.timeLabel sizeToFit];
    [self.timeLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.contentView.mas_trailing).mas_offset(-10);
        make.top.mas_equalTo(self.avatarView);
        if (self.messageData.showMessageTime) {
            make.width.mas_equalTo(self.timeLabel.frame.size.width);
            make.height.mas_equalTo(self.timeLabel.frame.size.height);
        } else {
            make.width.mas_equalTo(0);
            make.height.mas_equalTo(0);
        }
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
                if (!self.imageData.highlightKeyword) {
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

#pragma mark - TUIMessageCellProtocol
+ (CGFloat)getEstimatedHeight:(TUIMessageCellData *)data {
    return 186.f;
}

+ (CGSize)getContentSize:(TUIMessageCellData *)data {
    NSAssert([data isKindOfClass:TUIImageMessageCellData.class], @"data must be kind of TUIImageMessageCellData");
    TUIImageMessageCellData *imageCellData = (TUIImageMessageCellData *)data;
    CGSize size = CGSizeZero;
    BOOL isDir = NO;
    if (![imageCellData.path isEqualToString:@""] && [[NSFileManager defaultManager] fileExistsAtPath:imageCellData.path isDirectory:&isDir]) {
        if (!isDir) {
            size = [UIImage imageWithContentsOfFile:imageCellData.path].size;
        }
    }

    if (CGSizeEqualToSize(size, CGSizeZero)) {
        for (TUIImageItem *item in imageCellData.items) {
            if (item.type == TImage_Type_Thumb) {
                size = item.size;
            }
        }
    }
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        for (TUIImageItem *item in imageCellData.items) {
            if (item.type == TImage_Type_Large) {
                size = item.size;
            }
        }
    }
    if (CGSizeEqualToSize(size, CGSizeZero)) {
        for (TUIImageItem *item in imageCellData.items) {
            if (item.type == TImage_Type_Origin) {
                size = item.size;
            }
        }
    }

    if (CGSizeEqualToSize(size, CGSizeZero)) {
        return size;
    }
    if (size.height > size.width) {
        if (size.height > 5* size.width) {
            size.width = TImageMessageCell_Image_Width_Max;
            size.height = TImageMessageCell_Image_Height_Max;
            imageCellData.isSuperLongImage = YES;
        }
        else {
            size.width = size.width / size.height * TImageMessageCell_Image_Height_Max;
            size.height = TImageMessageCell_Image_Height_Max;
        }
    } else {
        size.height = size.height / size.width * TImageMessageCell_Image_Width_Max;
        size.width = TImageMessageCell_Image_Width_Max;
    }
    
    BOOL hasRiskContent = imageCellData.innerMessage.hasRiskContent;
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
