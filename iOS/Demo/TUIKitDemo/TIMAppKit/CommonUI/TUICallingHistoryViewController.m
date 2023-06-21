//
//  TUICallingHistoryViewController.m
//  TIMAppKit
//
//  Created by harvy on 2023/3/30.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUICallingHistoryViewController.h"
#import <TUICore/TUICore.h>
#import <TUICore/TUIDefine.h>

@interface TUICallingHistoryViewController ()
@property(nonatomic, strong) UIViewController *settingCallsVc;
@end

@implementation TUICallingHistoryViewController

+ (nullable instancetype)createCallingHistoryViewController:(BOOL)isMimimalist {
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if (isMimimalist) {
        param[TUICore_TUICallingObjectFactory_RecordCallsVC_UIStyle] = TUICore_TUICallingObjectFactory_RecordCallsVC_UIStyle_Minimalist;
    } else {
        param[TUICore_TUICallingObjectFactory_RecordCallsVC_UIStyle] = TUICore_TUICallingObjectFactory_RecordCallsVC_UIStyle_Classic;
    }
    UIViewController *settingCallsVc = [TUICore createObject:TUICore_TUICallingObjectFactory key:TUICore_TUICallingObjectFactory_RecordCallsVC param:param];
    if (settingCallsVc) {
        return [[TUICallingHistoryViewController alloc] initWithCallsVC:settingCallsVc isMimimalist:isMimimalist];
    } else {
        return nil;
    }
}

- (instancetype)initWithCallsVC:(UIViewController *)callsVC isMimimalist:(BOOL)isMimimalist {
    TUICallingHistoryViewController *vc = [[TUICallingHistoryViewController alloc] init];
    vc.settingCallsVc = callsVC;
    vc.isMimimalist = isMimimalist;
    return vc;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
    if (self.viewWillAppear) {
        self.viewWillAppear(NO);
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.viewWillAppear) {
        self.viewWillAppear(YES);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.settingCallsVc) {
        self.callsVC = self.settingCallsVc;
        [self addChildViewController:self.callsVC];
        [self.view addSubview:self.callsVC.view];
    }
}

@end
