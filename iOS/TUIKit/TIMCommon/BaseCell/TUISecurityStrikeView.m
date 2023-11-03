//
//  TUISecurityStrikeView.m
//  TIMCommon
//
//  Created by wyl on 2023/10/11.
//  Copyright © 2023 Tencent. All rights reserved.

#import "TUISecurityStrikeView.h"
#import <TIMCommon/TIMDefine.h>

@implementation TUISecurityStrikeView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self){
        [self setupView];
    }
    return self;
}
+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

- (void)setupView {
    self.topLine = [[UIView alloc] initWithFrame:CGRectZero];
    self.topLine.backgroundColor = TUIDynamicColor(@"", TUIThemeModuleTIMCommon, @"#E5C7C7");
    [self addSubview:self.topLine];
    
    self.textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    [self addSubview:self.textLabel];
    self.textLabel.font = [UIFont systemFontOfSize:14];
    self.textLabel.text = TIMCommonLocalizableString(TUIKitMessageTypeSecurityStrike);
    self.textLabel.textColor = TUIDynamicColor(@"", TUIThemeModuleTIMCommon, @"#DA2222");
    self.textLabel.numberOfLines = 0;
    self.textLabel.textAlignment = isRTL()?NSTextAlignmentRight:NSTextAlignmentLeft;

}
// this is Apple's recommended place for adding/updating constraints
- (void)updateConstraints {
    [super updateConstraints];
    [self.topLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(kTUISecurityStrikeViewTopLineMargin);
        make.leading.mas_equalTo(10);
        make.trailing.mas_equalTo(-10);
        make.height.mas_equalTo(0.5);
    }];
    
    [self.textLabel sizeToFit];
    [self.textLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(10);
        make.bottom.mas_equalTo(-11);
        make.width.mas_equalTo(self);
    }];

}

+ (UIImage *)changeImageColorWith:(UIColor *)color image:(UIImage *)image alpha:(CGFloat)alpha {
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetAlpha(context, alpha);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    CGContextClipToMask(context, rect, image.CGImage);
    [color setFill];
    CGContextFillRect(context, rect);
    UIImage*newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
@end

