//
//  TUIWarningView.m
//
//  Created by summeryxia on 2022/7/19.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIWarningView.h"
#import <TIMCommon/TIMDefine.h>
#import <TIMCommon/TUIAttributedLabel.h>

@interface TUIWarningView ()<TUIAttributedLabelDelegate>
@property(nonatomic, strong) UIImageView *tipsIcon;
@property(nonatomic, strong) TUIAttributedLabel *tipsLabel;
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
        self.backgroundColor = [UIColor tui_colorWithHex:@"FFE8D5" alpha:1];

        self.tipsIcon = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.tipsIcon];
        self.tipsIcon.image = [UIImage imageNamed:TIMCommonImagePath(@"icon_secure_info_img")];        
        if (tips.length > 0) {
            self.tipsLabel = [[TUIAttributedLabel alloc] initWithFrame:CGRectZero];
            self.tipsLabel.numberOfLines = 0;
            self.tipsLabel.userInteractionEnabled = YES;
            self.tipsLabel.delegate = self;
            self.tipsLabel.textAlignment = isRTL()?NSTextAlignmentRight:NSTextAlignmentLeft;
            [self addSubview:self.tipsLabel];
        
            NSMutableParagraphStyle  *paragraphStyle = [self.class customParagraphStyle];
            NSString *contentString = [tips stringByAppendingString:buttonTitle];
            NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:contentString];
            [mutableAttributedString addAttribute:NSParagraphStyleAttributeName 
                                            value:paragraphStyle 
                                            range:[contentString rangeOfString:contentString]];
            [mutableAttributedString addAttribute:NSForegroundColorAttributeName
                                            value:[UIColor tui_colorWithHex:@"A02800"]
                                            range:[contentString rangeOfString:contentString]];
            [mutableAttributedString addAttribute:NSStrokeColorAttributeName
                                            value:[UIColor tui_colorWithHex:@"A02800"]
                                            range:[contentString rangeOfString:contentString]];
            [mutableAttributedString addAttribute:NSFontAttributeName
                                            value:[UIFont systemFontOfSize:14]
                                            range:[contentString rangeOfString:contentString]];
            [mutableAttributedString addAttribute:NSStrokeWidthAttributeName value:@0 range:[contentString rangeOfString:contentString]];
            [self.tipsLabel setText:mutableAttributedString];
            self.tipsLabel.linkAttributes = @{(NSString *)kCTForegroundColorAttributeName:[UIColor systemBlueColor],
                                          (NSString *)kCTUnderlineStyleAttributeName:[NSNumber numberWithBool:NO]};

            [self.tipsLabel addLinkToURL:[NSURL URLWithString:@"click"] withRange:[contentString rangeOfString:buttonTitle]];

            CGFloat maxWidth = self.mm_w - 92;
            CGRect rect =
            [mutableAttributedString boundingRectWithSize:CGSizeMake(maxWidth, MAXFLOAT)
                                                  options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
            CGFloat margin = isRTL()?5:0;
            self.mm_height(ceil(rect.size.height) + 32 + margin);
        }
        
        if (gotButtonTitle.length > 0) {
            self.gotButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.gotButton setImage:[UIImage imageNamed:TIMCommonImagePath(@"icon_secure_cancel_img")] forState:UIControlStateNormal];
            [self addSubview:self.gotButton];
            [self.gotButton addTarget:self action:@selector(onGotButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
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

+ (NSMutableParagraphStyle *)customParagraphStyle {
    NSMutableParagraphStyle  *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    if (@available(iOS 9.0, *)) {
        paragraphStyle.allowsDefaultTighteningForTruncation = YES;
    }
    if (isRTL()) {
        [paragraphStyle setLineBreakMode:NSLineBreakByCharWrapping];
        paragraphStyle.alignment = NSTextAlignmentRight ;
        paragraphStyle.minimumLineHeight = 18;
        [paragraphStyle setLineSpacing:11];
    }
    else {
        [paragraphStyle setLineBreakMode:NSLineBreakByCharWrapping];
        paragraphStyle.alignment = NSTextAlignmentLeft ;
        paragraphStyle.minimumLineHeight = 11;
        [paragraphStyle setLineSpacing:4];
    }
    
    return paragraphStyle;
}


+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

// this is Apple's recommended place for adding/updating constraints
- (void)updateConstraints {
    [super updateConstraints];

    [self.tipsIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(16);
        make.leading.mas_equalTo(20);
        make.width.height.mas_equalTo(16);
    }];
    
    [self.tipsLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(16);
        make.leading.mas_equalTo(self.tipsIcon.mas_trailing).mas_offset(10);
        make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-46);
        make.bottom.mas_equalTo(-16);
    }];
    
    [self.gotButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(16);
        make.trailing.mas_equalTo(-20);
        make.width.height.mas_equalTo(16);
    }];
}

#pragma mark - TUIAttributedLabelDelegate
- (void)attributedLabel:(TUIAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url{
    if (self.buttonAction) {
        self.buttonAction();
    }
}
@end
