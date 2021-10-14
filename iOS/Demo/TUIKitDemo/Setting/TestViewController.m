//
//  TestViewController.m
//  TUIKitDemo
//
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TestViewController.h"
#import "TUIKit.h"
#import "TestForHistoryMessageViewController.h"
#import "TestForSearchMessageViewController.h"
#import "TestForGroupAttributeViewController.h"
#import "GenerateTestUserSig.h"

@interface TestViewController () <UIScrollViewDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *serverAddressButton;

@property (weak, nonatomic) IBOutlet UITextField *customIPTextField;
@property (weak, nonatomic) IBOutlet UITextField *customPortTextField;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *customIPHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *customIPTopConstraint;


@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 服务器初始化
    [self.serverAddressButton setTitle:TUIDemoServerName(TUIDemoCurrentServer, TUIDemoIsTestEnvironment) forState:UIControlStateNormal];
    [self updateServerInfoWithType:TUIDemoCurrentServer];
    
    // 测试项
    // TODO: TUIKit更新
    self.ignoreMsgUnreadSwitch.on = TUIKit.sharedInstance.config.isExcludedFromUnreadCount;
    self.isExcludedFromLastMessageSwitch.on = TUIKit.sharedInstance.config.isExcludedFromLastMessage;
    
    // UI 初始化
    self.title = @"测试";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close" style:UIBarButtonItemStyleDone target:self action:@selector(doneClick)];
    self.scrollView.delegate = self;
    self.customIPTextField.delegate = self;
    self.customPortTextField.delegate = self;
}

- (void)doneClick {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)changeServerClick:(id)sender {
    __weak typeof(self) weakSelf = self;
    
    void(^onChangeServerCallback)(TUIDemoServerType, BOOL) = ^(TUIDemoServerType serverType, BOOL isTest){
        TUIDemoSwitchServer(serverType);
        TUIDemoSwitchTest(isTest);
        [weakSelf.serverAddressButton setTitle:TUIDemoServerName(serverType, isTest) forState:UIControlStateNormal];
        [weakSelf updateServerInfoWithType:serverType];
    };
    
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"选择服务器接入点" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alertVc addAction:[UIAlertAction actionWithTitle:TUIDemoServerName(TUIDemoServerTypePublic, NO) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        onChangeServerCallback(TUIDemoServerTypePublic, NO);
    }]];
    [alertVc addAction:[UIAlertAction actionWithTitle:TUIDemoServerName(TUIDemoServerTypePublic, YES) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        onChangeServerCallback(TUIDemoServerTypePublic, YES);
    }]];
    [alertVc addAction:[UIAlertAction actionWithTitle:TUIDemoServerName(TUIDemoServerTypePrivate, NO) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        onChangeServerCallback(TUIDemoServerTypePrivate, NO);
    }]];
    [alertVc addAction:[UIAlertAction actionWithTitle:TUIDemoServerName(TUIDemoServerTypePrivate, YES) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        onChangeServerCallback(TUIDemoServerTypePrivate, YES);
    }]];
    [alertVc addAction:[UIAlertAction actionWithTitle:TUIDemoServerName(TUIDemoServerTypeSingapore, NO) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        onChangeServerCallback(TUIDemoServerTypeSingapore, NO);
    }]];
    [alertVc addAction:[UIAlertAction actionWithTitle:TUIDemoServerName(TUIDemoServerTypeSingapore, YES) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        onChangeServerCallback(TUIDemoServerTypeSingapore, YES);
    }]];
    [alertVc addAction:[UIAlertAction actionWithTitle:TUIDemoServerName(TUIDemoServerTypeKorea, NO) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        onChangeServerCallback(TUIDemoServerTypeKorea, NO);
    }]];
    [alertVc addAction:[UIAlertAction actionWithTitle:TUIDemoServerName(TUIDemoServerTypeKorea, YES) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        onChangeServerCallback(TUIDemoServerTypeKorea, YES);
    }]];
    [alertVc addAction:[UIAlertAction actionWithTitle:TUIDemoServerName(TUIDemoServerTypeGermany, NO) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        onChangeServerCallback(TUIDemoServerTypeGermany, NO);
    }]];
    [alertVc addAction:[UIAlertAction actionWithTitle:TUIDemoServerName(TUIDemoServerTypeGermany, YES) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        onChangeServerCallback(TUIDemoServerTypeGermany, YES);
    }]];
    [alertVc addAction:[UIAlertAction actionWithTitle:TUIDemoServerName(TUIDemoServerTypeCustomPrivate, NO) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        onChangeServerCallback(TUIDemoServerTypeCustomPrivate, NO);
    }]];
    [alertVc addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [self presentViewController:alertVc animated:YES completion:nil];
}

- (void)updateServerInfoWithType:(TUIDemoServerType)type {
    BOOL showIPPort = (type == TUIDemoServerTypeCustomPrivate);
    self.customIPHeightConstraint.constant = showIPPort?34:1;
    self.customIPTopConstraint.constant = showIPPort?8:1;
    self.customIPTextField.hidden = !showIPPort;
    self.customPortTextField.hidden = !showIPPort;
    
    if (showIPPort) {
        self.customIPTextField.text = [GenerateTestUserSig customPrivateServer];
        self.customPortTextField.text = [NSString stringWithFormat:@"%zd", [GenerateTestUserSig customPrivatePort]];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if ([textField isEqual:self.customIPTextField]) {
        [GenerateTestUserSig setCustomPrivateServer:textField.text];
    } else if ([textField isEqual:self.customPortTextField]) {
        [GenerateTestUserSig setCustomPrivatePort:[textField.text integerValue]];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    return YES;
}

- (IBAction)ignoreMsgUnreadSwitchClick:(id)sender {
    UISwitch *sw = (UISwitch *)sender;
    [TUIKit sharedInstance].config.isExcludedFromUnreadCount = sw.isOn;
}


- (IBAction)actionNotAsLastMsgSwitch:(UISwitch *)switcher {
    [TUIKit sharedInstance].config.isExcludedFromLastMessage = switcher.isOn;
}

- (IBAction)gotoHistoryMessageTestPage:(id)sender {
    TestForHistoryMessageViewController *vc = [[TestForHistoryMessageViewController alloc] init];
    if (self.navigationController) {
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    [self dismissViewControllerAnimated:NO completion:^{
        [UIApplication.sharedApplication.keyWindow.rootViewController presentViewController:vc animated:YES completion:nil];
    }];
}

- (IBAction)testForSearch:(id)sender {
    TestForSearchMessageViewController *vc = [[TestForSearchMessageViewController alloc] init];
    if (self.navigationController) {
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    [self dismissViewControllerAnimated:NO completion:^{
        [UIApplication.sharedApplication.keyWindow.rootViewController presentViewController:vc animated:YES completion:nil];
    }];
}

- (IBAction)testForGroupAttribute:(id)sender {
    TestForGroupAttributeViewController *vc = [[TestForGroupAttributeViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}


- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

@end
