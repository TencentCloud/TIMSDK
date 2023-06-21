//
//  TUIIMIntroductionViewController.m
//  TUIKitDemo
//
//  Created by lynxzhang on 2022/2/9.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import "TUIIMIntroductionViewController.h"
#import <TUICore/TUIThemeManager.h>
#import "TUIUtil.h"

@implementation TUIIMIntroductionViewController

// MARK: life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupView];
}

- (void)setupView {
    self.view.backgroundColor = [UIColor whiteColor];

    UIImageView *imLogo = [[UIImageView alloc] initWithFrame:CGRectMake(kScale375(34), 56, 62, 31)];
    imLogo.image = TUIDemoDynamicImage(@"", [UIImage imageNamed:TUIDemoImagePath(@"im_logo")]);
    [self.view addSubview:imLogo];

    UILabel *imLabel = [[UILabel alloc] initWithFrame:CGRectMake(imLogo.mm_x, imLogo.mm_maxY + 10, 100, 36)];
    imLabel.text = TIMCommonLocalizableString(TIMAppTencentCloudIM);
    imLabel.font = [UIFont systemFontOfSize:24];
    imLabel.textColor = [UIColor blackColor];
    [self.view addSubview:imLabel];

    UILabel *introductionLabel = [[UILabel alloc] initWithFrame:CGRectMake(kScale375(31), imLabel.mm_maxY + 32, self.view.mm_w - imLabel.mm_x * 2, 144)];
    introductionLabel.text = TIMCommonLocalizableString(TIMAppWelcomeToChatDetails);
    introductionLabel.numberOfLines = 0;
    introductionLabel.font = [UIFont systemFontOfSize:16];
    introductionLabel.textColor = RGB(51, 51, 51);
    [self.view addSubview:introductionLabel];

    CGFloat startX = kScale390(30);
    CGFloat startY = introductionLabel.mm_maxY + 30;
    CGFloat widthSpace = kScale390(10);
    CGFloat heightSpace = 10;
    CGFloat viewWidth = (Screen_Width - startX * 2 - widthSpace) / 2;
    CGFloat viewHeight = 82;
    for (int i = 0; i < 4; i++) {
        UIView *introductionView = [[UIView alloc]
            initWithFrame:CGRectMake(startX + (viewWidth + widthSpace) * (i % 2), startY + (viewHeight + heightSpace) * (i / 2), viewWidth, viewHeight)];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(kScale390(20), 14, introductionView.mm_w - kScale390(20) * 2, 35)];
        label.textColor = RGB(0, 110, 255);
        label.font = [UIFont systemFontOfSize:24];
        UILabel *subLabel = [[UILabel alloc] initWithFrame:CGRectMake(label.mm_x, label.mm_maxY + 3, label.mm_w, 24)];
        subLabel.textColor = RGB(0, 0, 0);
        subLabel.font = [UIFont systemFontOfSize:8];
        subLabel.numberOfLines = 0;
        if (i == 0) {
            label.text = TIMCommonLocalizableString(TIMApp1Minute);
            subLabel.text = TIMCommonLocalizableString(TIMAppRunDemo);
        } else if (i == 1) {
            label.text = TIMCommonLocalizableString(TIMApp10000 +);
            subLabel.text = TIMCommonLocalizableString(TIMAppCustomers);
        } else if (i == 2) {
            label.text = @"99.99%";
            subLabel.text = TIMCommonLocalizableString(TIMAppMessagingSuccess);
        } else if (i == 3) {
            label.text = TIMCommonLocalizableString(TIMApp1Billion +);
            subLabel.text = TIMCommonLocalizableString(TIMAppActiveUsers);
        }
        [introductionView addSubview:label];
        [introductionView addSubview:subLabel];
        [self.view addSubview:introductionView];
    }

    UIButton *understoodBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    understoodBtn.backgroundColor = RGB(16, 78, 245);
    CGFloat btnWidth = 202;
    CGFloat btnHeight = 42;
    understoodBtn.frame = CGRectMake((self.view.mm_w - btnWidth) / 2, self.view.mm_h - btnHeight - Bottom_SafeHeight - 100, btnWidth, btnHeight);
    [understoodBtn setTitle:TIMCommonLocalizableString(TIMAppOK) forState:UIControlStateNormal];
    [understoodBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    understoodBtn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    understoodBtn.layer.cornerRadius = btnHeight / 2;
    understoodBtn.layer.masksToBounds = YES;
    [understoodBtn addTarget:self action:@selector(understood) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:understoodBtn];
}

- (void)understood {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
