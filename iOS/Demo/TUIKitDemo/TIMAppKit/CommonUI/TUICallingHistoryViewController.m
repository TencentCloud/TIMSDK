//
//  TUICallingHistoryViewController.m
//  TIMAppKit
//
//  Created by harvy on 2023/3/30.
//

#import "TUICallingHistoryViewController.h"
#import <TUICore/TUICore.h>
#import <TUICore/TUIDefine.h>

@interface TUICallingHistoryViewController ()

@property (nonatomic, strong) UIViewController *callsVC;

@end

@implementation TUICallingHistoryViewController

+ (nullable instancetype)createCallingHistoryViewController:(BOOL)isMimimalist {
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    if (isMimimalist) {
        param[TUICore_TUICallingObjectFactory_RecordCallsVC_UIStyle] = TUICore_TUICallingObjectFactory_RecordCallsVC_UIStyle_Minimalist;
    } else {
        param[TUICore_TUICallingObjectFactory_RecordCallsVC_UIStyle] = TUICore_TUICallingObjectFactory_RecordCallsVC_UIStyle_Classic;
    }
    UIViewController *callsVc = [TUICore createObject:TUICore_TUICallingObjectFactory key:TUICore_TUICallingObjectFactory_RecordCallsVC param:param];
    if (callsVc) {
        return [[TUICallingHistoryViewController alloc] initWithCallsVC:callsVc];
    } else {
        return nil;
    }
}

- (instancetype)initWithCallsVC:(UIViewController *)callsVC {
    TUICallingHistoryViewController *vc = [[TUICallingHistoryViewController alloc] init];
    vc.callsVC = callsVC;
    return vc;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (self.callsVC) {
        [self addChildViewController:self.callsVC];
        [self.view addSubview:self.callsVC.view];
    }
}

@end
