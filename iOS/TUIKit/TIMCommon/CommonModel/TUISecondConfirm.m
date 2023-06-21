//
//  TUISecondConfirm.m
//  TIMCommon
//
//  Created by xiangzhang on 2023/5/15.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUISecondConfirm.h"
#import <TUICore/TUIDefine.h>
#import <TUICore/UIView+TUILayout.h>

@implementation TUISecondConfirmBtnInfo

@end

static UIWindow *gSecondWindow = nil;
static TUISecondConfirmBtnInfo *gCancelBtnInfo = nil;
static TUISecondConfirmBtnInfo *gConfirmBtnInfo = nil;

@implementation TUISecondConfirm

+ (void)show:(NSString *)title cancelBtnInfo:(TUISecondConfirmBtnInfo *)cancelBtnInfo confirmBtnInfo:(TUISecondConfirmBtnInfo *)confirmBtnInfo {
    gCancelBtnInfo = cancelBtnInfo;
    gConfirmBtnInfo = confirmBtnInfo;

    gSecondWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    gSecondWindow.windowLevel = UIWindowLevelAlert - 1;
    gSecondWindow.backgroundColor = [UIColor clearColor];
    gSecondWindow.hidden = NO;

    if (@available(iOS 13.0, *)) {
        for (UIWindowScene *windowScene in [UIApplication sharedApplication].connectedScenes) {
            if (windowScene.activationState == UISceneActivationStateForegroundActive) {
                gSecondWindow.windowScene = windowScene;
                break;
            }
        }
    }

    UIView *backgroupView = [[UIView alloc] initWithFrame:gSecondWindow.bounds];
    backgroupView.backgroundColor = RGBA(0, 0, 0, 0.4);
    [gSecondWindow addSubview:backgroupView];

    UIView *confimView = [[UIView alloc] init];
    confimView.backgroundColor = TIMCommonDynamicColor(@"second_confirm_bg_color", @"#FFFFFF");
    confimView.layer.cornerRadius = 13;
    confimView.layer.masksToBounds = YES;
    [gSecondWindow addSubview:confimView];
    confimView.mm_width(gSecondWindow.mm_w - kScale375(32) * 2).mm_height(183).mm__centerX(gSecondWindow.mm_centerX).mm__centerY(gSecondWindow.mm_h / 2);

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, confimView.mm_w, 123)];
    titleLabel.text = title;
    titleLabel.textColor = TIMCommonDynamicColor(@"second_confirm_title_color", @"#000000");
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:16];
    titleLabel.numberOfLines = 0;
    [confimView addSubview:titleLabel];

    UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(0, titleLabel.mm_maxY, titleLabel.mm_w, 0.5)];
    line1.backgroundColor = TIMCommonDynamicColor(@"second_confirm_line_color", @"#DDDDDD");
    [confimView addSubview:line1];

    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelBtn setFrame:CGRectMake(0, line1.mm_maxY, line1.mm_w / 2, confimView.mm_h - line1.mm_maxY)];
    [cancelBtn setTitle:gCancelBtnInfo.tile forState:UIControlStateNormal];
    [cancelBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [cancelBtn setTitleColor:TIMCommonDynamicColor(@"second_confirm_cancel_btn_title_color", @"#000000") forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(onCancelBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [confimView addSubview:cancelBtn];

    UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake(cancelBtn.mm_maxX, cancelBtn.mm_y, 0.5, cancelBtn.mm_h)];
    line2.backgroundColor = TIMCommonDynamicColor(@"second_confirm_line_color", @"#DDDDDD");
    [confimView addSubview:line2];

    UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [confirmBtn setFrame:CGRectMake(line2.mm_maxX, cancelBtn.mm_y, cancelBtn.mm_w, cancelBtn.mm_h)];
    [confirmBtn setTitle:gConfirmBtnInfo.tile forState:UIControlStateNormal];
    [confirmBtn.titleLabel setFont:[UIFont systemFontOfSize:16]];
    [confirmBtn setTitleColor:TIMCommonDynamicColor(@"second_confirm_confirm_btn_title_color", @"#FF584C") forState:UIControlStateNormal];
    [confirmBtn addTarget:self action:@selector(onConfirmBtnBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [confimView addSubview:confirmBtn];
}

+ (void)onCancelBtnClick {
    if (gCancelBtnInfo && gCancelBtnInfo.click) {
        gCancelBtnInfo.click();
    }
    [self dismiss];
}

+ (void)onConfirmBtnBtnClick {
    if (gConfirmBtnInfo && gConfirmBtnInfo.click) {
        gConfirmBtnInfo.click();
    }
    [self dismiss];
}

+ (void)dismiss {
    gSecondWindow = nil;
    gCancelBtnInfo = nil;
    gConfirmBtnInfo = nil;
}

@end
