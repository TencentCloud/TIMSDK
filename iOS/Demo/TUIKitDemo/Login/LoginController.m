//
//  LoginController.m
//  TUIKitDemo
//
//  Created by kennethmiao on 2018/10/10.
//  Copyright © 2018年 Tencent. All rights reserved.
//
/** 腾讯云IM Demo 登录界面
 *  本文件实现了Demo中的登录界面
 *  值得注意的是，实际登录模块与Demo中的登录模块有所不同。
 *  Demo中为了方便用户体验，只需在AppDelegate.h中填用户名和usersig即可（具体获得过程请参照https://github.com/tencentyun/TIMSDK/tree/master/iOS）
 *
 *  本类依赖于腾讯云 TUIKit和IMSDK 实现
 *
 */
#import <WebKit/WebKit.h>
#import "LoginController.h"
#import "TUIKit.h"
#import "TUICommonModel.h"
#import "TUIInputMoreCell.h"
#import "TUIMenuCell.h"
#import "TUIFaceView.h"
#import "TUIDefine.h"
#import "AppDelegate.h"
#import "TCLoginModel.h"
#import "ReactiveObjC/ReactiveObjC.h"
#import "UIView+TUILayout.h"
#import "TUITool.h"
#import "TUIDarkModel.h"
#import "GenerateTestUserSig.h"
#import "TestViewController.h"
#import "TUILoginCache.h"

@interface LoginController () <WKScriptMessageHandler>
@property (weak, nonatomic) IBOutlet UITextField *user;
@property (weak, nonatomic) IBOutlet UITextField *pwd;
@property (weak, nonatomic) IBOutlet UITextView *countryCode;
@property (weak, nonatomic) IBOutlet UIButton *treatyBtn;
@property (weak, nonatomic) IBOutlet UITextView *treatyTextView;
@property (weak, nonatomic) IBOutlet UIImageView *logImageView;
@property (weak, nonatomic) IBOutlet UILabel *loginIMShowLabel;
@property (weak, nonatomic) IBOutlet UIButton *directLoginBtn;


@property NSString *sessionId;
@property NSString *phone;
@property TCLoginModel *loginModel;
@property dispatch_source_t timer;
@property (nonatomic, strong) WKWebView *webView;

@property (nonatomic, assign) BOOL loginWithPhone;  // 是否手机号登录
@property (nonatomic, copy) NSString *username;     // 账号密码登录, 账号
@property (nonatomic, copy) NSString *password;     // 账号密码登录, 密码
@end

@implementation LoginController

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    [self.view addGestureRecognizer:tap];
    self.countryCode.text = @"86";
    self.loginModel = [TCLoginModel sharedInstance];
    
    self.treatyTextView.attributedText = ({
        
        
        NSString *str = [NSString stringWithFormat:NSLocalizedString(@"LoginAgreementFormat", nil),
                         NSLocalizedString(@"LoginAgreementParamPrivacy", nil),
                         NSLocalizedString(@"LoginAgreementParamUser", nil)];
        
        NSRange privacyRange = [str rangeOfString:NSLocalizedString(@"LoginAgreementParamPrivacy", nil)];
        NSRange userAgreementRange = [str rangeOfString:NSLocalizedString(@"LoginAgreementParamUser", nil)];
        
        
        NSMutableAttributedString *attributedMStr = [[NSMutableAttributedString alloc] initWithString:str];
        [attributedMStr addAttribute:NSLinkAttributeName
                               value:@"https://web.sdk.qcloud.com/document/Tencent-IM-Privacy-Protection-Guidelines.html"
                               range:privacyRange];
        [attributedMStr addAttribute:NSLinkAttributeName
                               value:@"https://web.sdk.qcloud.com/document/Tencent-IM-User-Agreement.html"
                               range:userAgreementRange];
        [attributedMStr addAttribute:NSForegroundColorAttributeName value:[UIColor d_systemGrayColor] range:NSMakeRange(0, str.length)];
        [attributedMStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12.0] range:NSMakeRange(0, str.length)];
        attributedMStr;
    });
    self.treatyTextView.textContainerInset = UIEdgeInsetsMake(2, 0, 0, 0);
    self.treatyTextView.linkTextAttributes = @{NSForegroundColorAttributeName:[UIColor d_systemBlueColor]};
    UITapGestureRecognizer *tapGesture1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapLogView)];
    tapGesture1.numberOfTapsRequired = 10;
    [self.logImageView addGestureRecognizer:tapGesture1];
    
    UITapGestureRecognizer *tapGesture2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapLoginIMLabel)];
    tapGesture2.numberOfTapsRequired = 10;
    self.loginIMShowLabel.userInteractionEnabled = YES;
    [self.loginIMShowLabel addGestureRecognizer:tapGesture2];
    
    self.coverView.hidden = YES;
    self.directLoginBtn.hidden = YES;
    
#if DEBUG
    self.directLoginBtn.hidden = NO;
#endif
    
#if PUBLISHGIT
    self.coverView.hidden = NO;
    self.directLoginBtn.hidden = NO;
    [self.directLoginBtn setTitle:@"登录" forState:UIControlStateNormal];
#endif
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark - Event Response
- (void)showImageVertifyUI {
    // 弹出图形验证码
    [self.webView removeFromSuperview];
    self.webView.bounds = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    self.webView.center = self.view.center;
    self.webView.opaque = NO;
    self.webView.backgroundColor = UIColor.clearColor;
    self.webView.scrollView.backgroundColor = UIColor.clearColor;
    [self.view addSubview:self.webView];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"verification.html" ofType:nil];
    NSString *htmlString = [[NSString alloc]initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    [self.webView loadHTMLString:htmlString baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
}

- (IBAction)getPassWord:(id)sender {
    if (self.user.text.length == 0) {
        [TUITool makeToast:NSLocalizedString(@"TipsPhoneNotNull", nil)];
        return;
    }
    [self.user resignFirstResponder];
    [self showImageVertifyUI];
    self.loginWithPhone = YES;
}

- (IBAction)treatyBtnClick:(UIButton *)sender {
    sender.selected = !sender.selected;
}

- (IBAction)login:(id)sender {
    
    [self.view endEditing:YES];
    
    if (self.user.text.length == 0 || self.pwd.text.length == 0) {
        [TUITool makeToast:NSLocalizedString(@"TipsPhoneCodeNotNull", nil)];
        return;
    }
    
    if (![[NSString stringWithFormat:@"%@%@",self.countryCode.text,self.user.text] isEqualToString:self.phone]) {
        [TUITool makeToast:NSLocalizedString(@"TipsPhoneNotMathc", nil)];
        return;
    }
    
    if (!self.treatyBtn.selected) {
        [TUITool makeToast:NSLocalizedString(@"TipsAgreementError", nil)];
        return;
    }
    
    if (self.sessionId.length > 0 && self.pwd.text.length > 0) {
        [TUITool makeToastActivity];
        @weakify(self)
        [self.loginModel smsRequest:RequestType_Smslogin param:@{@"phone":self.phone, @"sessionId":self.sessionId,@"code":self.pwd.text} succ:^(NSDictionary *smsParam) {
            @strongify(self)
            NSString *userId = smsParam[@"userId"];
            NSString *userSig = smsParam[@"userSig"];
            if (userId.length == 0 || userSig.length == 0) {
                [TUITool hideToastActivity];
                [self alertText:NSLocalizedString(@"TipsLoginErrorWithUserIdfailed", nil)];
            } else {
                [self loginIM:userId userSig:userSig];
            }
        } fail:^(int errCode, NSString *errMsg) {
            @strongify(self)
            [TUITool hideToastActivity];
            [self alertText:[NSString stringWithFormat:NSLocalizedString(@"TipsLoginErrorFormat", nil),errCode,errMsg]];
        }];
    }
}

- (void)loginIM:(NSString *)userId userSig:(NSString *)userSig {
    if (userId.length == 0 || userSig.length == 0) {
        [TUITool hideToastActivity];
        [self alertText:NSLocalizedString(@"TipsLoginErrorWithUserIdfailed", nil)];
        return;
    }
    [[TUILoginCache sharedInstance] saveLogin:userId withAppId:SDKAPPID withUserSig:userSig];
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    @weakify(self)
    [delegate login:userId userSig:userSig succ:^{
        [TUITool hideToastActivity];
    } fail:^(int code, NSString *msg) {
        @strongify(self)
        [TUITool hideToastActivity];
        [self alertText:[NSString stringWithFormat:NSLocalizedString(@"TipsLoginErrorFormat", nil),code,@"Please check whether the SDKAPPID and SECRETKEY are correctly configured (GenerateTestUserSig.h)"]];
    }];
}

- (IBAction)showLoginAlertView:(UIButton *)sender
{
    // 1.创建UIAlertController
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"TipsLoginWithAccountPassword", nil)
                                                                             message:NSLocalizedString(@"TipsOldVersionRegisterAccount", nil)
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    // 2.1 添加文本框
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = NSLocalizedString(@"ProfileAccount", nil); // @"账号";
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = NSLocalizedString(@"Password", nil); // @"密码";
        textField.secureTextEntry = YES;
    }];
    // 2.2  创建Cancel Login按钮
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Cancel Action");
    }];
    @weakify(self)
    UIAlertAction *loginAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"login", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        @strongify(self)
        UITextField *userName = alertController.textFields.firstObject;
        UITextField *password = alertController.textFields.lastObject;
        if (userName.text.length == 0) {
            [self alertText:NSLocalizedString(@"TipsInputAccount", nil)];
            return;
        }
        if (password.text.length == 0) {
            [self alertText:NSLocalizedString(@"tipsInputPassword", nil)];
            return;
        }
        
        // 弹出图形验证码
        self.username = userName.text;
        self.password = password.text;
        [self showImageVertifyUI];
        self.loginWithPhone = NO;
        
    }];
    // 2.3 添加按钮
    [alertController addAction:cancelAction];
    [alertController addAction:loginAction];
    // 3.显示警报控制器
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)loginWithoutPassword:(id)sender {
    // 1.创建UIAlertController
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"TipsLoginWithAccountDirectly", nil)
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    // 2.1 添加文本框
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = NSLocalizedString(@"ProfileAccount", nil); // @"账号";
    }];
    // 2.2  创建Cancel Login按钮
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"Cancel Action");
    }];
    @weakify(self)
    UIAlertAction *loginAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"login", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        @strongify(self)
        UITextField *userName = alertController.textFields.firstObject;
        if (userName.text.length == 0) {
            [self alertText:NSLocalizedString(@"TipsInputAccount", nil)];
            return;
        }
        
        [self loginIM:userName.text userSig:[GenerateTestUserSig genTestUserSig:userName.text]];
        
    }];
    // 2.3 添加按钮
    [alertController addAction:cancelAction];
    [alertController addAction:loginAction];
    // 3.显示警报控制器
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)visitOfficialWebsite
{
    if (@available(iOS 10.0, *)) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://cloud.tencent.com/product/im"]
                                           options:@{} completionHandler:^(BOOL success) {
                                               if (success) {
                                                   NSLog(@"Opened url");
                                               }
                                           }];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://cloud.tencent.com/product/im"]];
    }
}

- (void)tapLogView
{
    TestViewController *vc = [[TestViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)tapLoginIMLabel
{
    self.directLoginBtn.hidden = NO;
}

- (void)onTap:(UIGestureRecognizer *)recognizer
{
    [self.countryCode resignFirstResponder];
    [self.user resignFirstResponder];
    [self.pwd resignFirstResponder];
    [self.view endEditing:YES];
}

- (void)alertText:(NSString *)str
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:str message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"confirm", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

    }]];

    [self presentViewController:alert animated:YES completion:nil];
}

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    if([message.name isEqualToString:@"verifySuccess"]) {
        [self.webView removeFromSuperview];
        if (!self.loginWithPhone) {
            // 账号密码登录
            @weakify(self)
            [self.loginModel loginWithUsername:self.username password:self.password succ:^(NSString *sig, NSUInteger sdkAppId) {
                @strongify(self)
#ifdef DEBUG
                sig = [GenerateTestUserSig genTestUserSig:self.username];
#endif
                if (TUIDemoCurrentServer == TUIDemoServerTypeSingapore ||
                    TUIDemoCurrentServer == TUIDemoServerTypeKorea ||
                    TUIDemoCurrentServer == TUIDemoServerTypeGermany) {
                    // 新加坡+韩国+德国，直接本地生成usersig登录
                    sig = [GenerateTestUserSig genTestUserSig:self.username];
                }
                [self loginIM:self.username userSig:sig];
            } fail:^(int errCode, NSString *errMsg) {
                [self alertText:[NSString stringWithFormat:NSLocalizedString(@"TipsLoginErrorFormat", nil),errCode,errMsg]];
            }];
            return;
        }
        // 获取验证码
        NSString *body = message.body;
        if ([body isKindOfClass:NSString.class]) {
            NSDictionary *para = [NSJSONSerialization JSONObjectWithData:[body dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableLeaves error:nil];
            if (para && [para.allKeys containsObject:@"ticket"] && [para.allKeys containsObject:@"randstr"]) {
                NSString *randstr = para[@"randstr"];
                NSString *ticket = para[@"ticket"];
                [self getVerifyCode:ticket randstr:randstr];
            }
        }
    } else if ([message.name isEqualToString:@"verifyError"]) {
        [TUITool makeToast:[NSString stringWithFormat:NSLocalizedString(@"GetSmsErrorFormat", nil), message.body]];
        [self.webView removeFromSuperview];
    } else if ([message.name isEqualToString:@"verifyCancel"]) {
        [self.webView removeFromSuperview];
    }
}

- (void)getVerifyCode:(NSString *)ticket randstr:(NSString *)randstr
{
    self.phone = [NSString stringWithFormat:@"%@%@",self.countryCode.text,self.user.text];
    @weakify(self)
    [self.loginModel smsRequest:RequestType_GetSms param:@{@"phone":self.phone?:@"", @"ticket":ticket?:@"", @"randstr":randstr?:@""} succ:^(NSDictionary *smsParam) {
        @strongify(self)
        self.sessionId = smsParam[@"sessionId"];
        [self alertText:NSLocalizedString(@"TipsCheckCodeHasSent", nil)];
        __block int waitTime = 60;
        self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
        dispatch_source_set_timer(self.timer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
        UIColor *originColor = self.smsBtn.backgroundColor;
        dispatch_source_set_event_handler(self.timer, ^{
            if (waitTime >= 0) {
                [self.smsBtn setBackgroundColor:[UIColor d_systemGrayColor]];
                [self.smsBtn setTitle:[NSString stringWithFormat:@"%ds",waitTime] forState:UIControlStateNormal];
            } else {
                [self.smsBtn setBackgroundColor:originColor];
                [self.smsBtn setTitle:NSLocalizedString(@"TipsGetCheckcode", nil) forState:UIControlStateNormal];
                dispatch_cancel(self.timer);
            }
            waitTime --;
        });
        dispatch_resume(self.timer);
    } fail:^(int errCode, NSString *errMsg) {
        @strongify(self)
        [self alertText:[NSString stringWithFormat:NSLocalizedString(@"TipsCheckCodeFailedFormat", nil),errCode,errMsg]];
    }];
}

#pragma mark - Getters & Setters
- (WKWebView *)webView {
    if(_webView == nil){
        //创建网页配置对象
        WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
        // 创建设置对象
        WKPreferences *preference = [[WKPreferences alloc]init];
        //设置是否支持 javaScript 默认是支持的
        preference.javaScriptEnabled = YES;
        // 在 iOS 上默认为 NO，表示是否允许不经过用户交互由 javaScript 自动打开窗口
        preference.javaScriptCanOpenWindowsAutomatically = YES;
        config.preferences = preference;
        //这个类主要用来做 native 与 JavaScript 的交互管理
        WKUserContentController * wkUController = [[WKUserContentController alloc] init];
        //注册一个name为jsToOcNoPrams的js方法 设置处理接收JS方法的对象
        [wkUController addScriptMessageHandler:self name:@"verifySuccess"];
        [wkUController addScriptMessageHandler:self name:@"verifyError"];
        [wkUController addScriptMessageHandler:self name:@"verifyCancel"];
        config.userContentController = wkUController;
        _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height) configuration:config];
    }
    return _webView;
}


@end
