//
//  TUIWarningView.m
//
//  Created by summeryxia on 2022/7/19.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIWarningView.h"
#import <TIMCommon/TIMDefine.h>

@interface TUIWarningView ()

@property(nonatomic, strong) UILabel *tipsLabel;
@property(nonatomic, strong) UIButton *tipsButton;
@property(nonatomic, copy) void (^buttonAction)(void);
@property(nonatomic, strong) UIButton *gotButton;
@property(nonatomic, copy) void (^gotButtonAction)(void);
@end

@implementation TUIWarningView

- (instancetype)initWithFrame:(CGRect)frame tips:(NSString *)tips
                  buttonTitle:(NSString *)buttonTitle buttonAction:(void (^)(void))action 
                  gotButtonTitle:(NSString *)gotButtonTitle gotButtonAction:(void (^)(void))gotButtonAction {
    self = [super initWithFrame:frame];
    if (self) {
        self.buttonAction = action;
        self.gotButtonAction = gotButtonAction;
        self.backgroundColor = [UIColor tui_colorWithHex:@"FF9500" alpha:0.1];

        if (tips.length > 0) {
            self.tipsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
            [self addSubview:self.tipsLabel];
            self.tipsLabel.font = [UIFont systemFontOfSize:12];
            self.tipsLabel.numberOfLines = 0;
            self.tipsLabel.textColor = [UIColor tui_colorWithHex:@"FF8C39"];

            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
            paragraphStyle.minimumLineHeight = 18;
            [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];
            [paragraphStyle setAlignment:isRTL()?NSTextAlignmentRight:NSTextAlignmentLeft];
            NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:tips];
            [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [tips length])];
            self.tipsLabel.attributedText = attributedString;
            CGRect rect =
                [self.tipsLabel.text boundingRectWithSize:CGSizeMake(self.mm_w - 28, MAXFLOAT)
                                                  options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                               attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:12], NSParagraphStyleAttributeName : paragraphStyle}
                                                  context:nil];
            self.mm_height(rect.size.height + 32);
            self.tipsLabel.mm_width(rect.size.width).mm_height(rect.size.height).mm_top(16).mm_left(14);
            if (isRTL()) {
                [self.tipsLabel resetFrameToFitRTL];
            }
        }

        CGFloat btnMargin = 10;

        if (gotButtonTitle.length > 0) {
            self.gotButton = [UIButton buttonWithType:UIButtonTypeSystem];
            [self addSubview:self.gotButton];
            [self.gotButton setTitle:gotButtonTitle forState:UIControlStateNormal];
            [self.gotButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
            [self.gotButton setTitleColor:[UIColor tui_colorWithHex:@"006EFF"] forState:UIControlStateNormal];
            [self.gotButton addTarget:self action:@selector(onGotButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            self.gotButton.mm_sizeToFit().mm_right(btnMargin).mm_bottom(10);

        }
        
        if (buttonTitle.length > 0) {
            self.tipsButton = [UIButton buttonWithType:UIButtonTypeSystem];
            [self addSubview:self.tipsButton];
            [self.tipsButton setTitle:buttonTitle forState:UIControlStateNormal];
            [self.tipsButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
            [self.tipsButton setTitleColor:[UIColor tui_colorWithHex:@"006EFF"] forState:UIControlStateNormal];
            [self.tipsButton addTarget:self action:@selector(onButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            self.tipsButton.mm_sizeToFit();
            self.tipsButton.frame = CGRectMake(
                                               CGRectGetMinX(self.gotButton.frame) - self.tipsButton.frame.size.width - btnMargin,
                                               self.gotButton.frame.origin.y,
                                               self.tipsButton.frame.size.width,
                                               self.tipsButton.frame.size.height);
        }
        if (isRTL()) {
            
            if (gotButtonTitle.length > 0) {
                [self.gotButton resetFrameToFitRTL];
            }
            
            if (buttonTitle.length > 0) {
                [self.tipsButton resetFrameToFitRTL];
            }
        }
    }
    return self;
}

- (void)onButtonClicked:(UIButton *)sender {
    if (self.buttonAction) {
        self.buttonAction();
    }
}


- (void)onGotButtonClicked:(UIButton *)sender {
    if (self.gotButtonAction) {
        self.gotButtonAction();
    }
}

@end
