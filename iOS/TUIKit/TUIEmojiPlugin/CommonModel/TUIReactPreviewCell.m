//
//  TUIReactPreviewCell.m
//  TUIChat
//
//  Created by wyl on 2022/5/26.
//  Copyright © 2023 Tencent. All rights reserved.
//
#import "TUIReactPreviewCell.h"
#import <TIMCommon/TIMCommonModel.h>
#import "TUIAttributedLabel.h"
#import "TUIReactModel.h"

#define margin 8
#define rightMargin 8
#define maxItemWidth 107
@interface TUIReactPreviewCell () <TUIAttributedLabelDelegate>

@property(nonatomic, strong) UIButton *tagBtn;

@end

@implementation TUIReactPreviewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self prepareUI];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    if (self = [super initWithCoder:coder]) {
        [self prepareUI];
    }
    return self;
}

#pragma mark - UI
- (void)prepareUI {
    self.layer.cornerRadius = 12.0f;
    self.layer.masksToBounds = YES;
}

#pragma mark - Data
- (void)setModel:(TUIReactModel *)model {
    _model = model;
    self.backgroundColor = model.defaultColor;

    for (UIView *subView in self.subviews) {
        [subView removeFromSuperview];
    }

    NSString *text = [model descriptionFollowUserStr];

    CGFloat allWidth = 0;

    UIButton *emojiBtn = [[UIButton alloc] init];
    [emojiBtn addTarget:self action:@selector(emojiBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:emojiBtn];
    [emojiBtn setImage:[[TUIImageCache sharedInstance] getFaceFromCache:model.emojiPath] forState:UIControlStateNormal];
    emojiBtn.frame = CGRectMake(margin, 4, 18, 18);
    allWidth += (emojiBtn.frame.size.width);
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(emojiBtn.frame.origin.x + emojiBtn.frame.size.width + 4, (30 - 14) * 0.5, 1, 14)];
    line.backgroundColor = [UIColor colorWithRed:68 / 255.0 green:68 / 255.0 blue:68 / 255.0 alpha:0.2];
    [self addSubview:line];
    allWidth += line.frame.size.width;

    TUIAttributedLabel *label = [[TUIAttributedLabel alloc] initWithFrame:CGRectMake(line.frame.origin.x + 4, 8, self.frame.size.width, 30)];
    label.userInteractionEnabled = YES;
    [self addSubview:label];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onSelectUser)];
    [label addGestureRecognizer:tap];

    NSString *contentString = text;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:11];
    [paragraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
    NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:contentString];
    [mutableAttributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:[contentString rangeOfString:contentString]];
    [mutableAttributedString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:11] range:[contentString rangeOfString:contentString]];
    [mutableAttributedString addAttribute:NSStrokeWidthAttributeName value:@0 range:[contentString rangeOfString:contentString]];
    [label setText:mutableAttributedString];
    label.linkAttributes = @{(NSString *)kCTForegroundColorAttributeName:model.textColor,
                                  (NSString *)kCTUnderlineStyleAttributeName:[NSNumber numberWithBool:NO]};

    [label addLinkToURL:[NSURL URLWithString:@"click"] withRange:[contentString rangeOfString:contentString]];
    [label sizeToFit];
    label.textColor = model.textColor;

    CGFloat fitWidth = label.frame.size.width;

    if (fitWidth > (MaxTagSize - allWidth - 12 - 12 - 100)) {
        fitWidth = MaxTagSize - allWidth - 12 - 12 - 100;
    }
    //    label.textInsets =  UIEdgeInsetsMake(0, 0, 0, 0);
    label.frame = CGRectMake(label.frame.origin.x, label.frame.origin.y, fitWidth, label.frame.size.height);
    label.preferredMaxLayoutWidth = 10;
    // self.contentView.frame.size.width - 28 -16 -1
    label.font = [UIFont systemFontOfSize:11];
    label.numberOfLines = 1;
    label.delegate = (id)self;

    allWidth += label.frame.size.width;
    allWidth += margin;
    allWidth += rightMargin;
    allWidth += 8;
    self.ItemWidth = allWidth;
    
}
- (void)layoutSubviews {
    [super layoutSubviews];
    
    for (UIView *subView in self.subviews) {
        [subView resetFrameToFitRTL];
    }

}

- (void)emojiBtnClick {
    if (self.emojiClickCallback) {
        self.emojiClickCallback(self.model);
    }
}

- (void)onSelectUser {
    if (self.userClickCallback) {
        self.userClickCallback(self.model);
    }
}

@end
