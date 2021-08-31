//
//  ViewController.m
//  TUIKitDemo
//
//  Created by xiang zhang on 2019/1/22.
//  Copyright © 2019 lynxzhang. All rights reserved.
//

#import "LoginViewController.h"
#import "ConversationController.h"
#import "AppDelegate.h"
#import "ImSDK.h"
#import "GenerateTestUserSig.h"

@interface LoginViewController()<TIMConnListener,TIMUserStatusListener,TIMRefreshListener>
@property (weak) IBOutlet NSTextField *userNameField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    TIMSdkConfig *sdkConfig = [[TIMSdkConfig alloc] init];
    sdkConfig.sdkAppId = SDKAPPID;
    sdkConfig.connListener = self;
    [[TIMManager sharedInstance] initSdk:sdkConfig];
    
    NSString *version = [[TIMManager sharedInstance] GetVersion];
    NSLog(@"sdk version is  %@",version);
}

- (IBAction)login:(NSButton *)sender {
    if ([[_userNameField stringValue] isEqualToString:@""]) {
        [self alert:@"账号错误！" informativeText:@"请输入账号"];
        return;
    }
    TIMLoginParam *param = [[TIMLoginParam alloc] init];
    param.identifier = [_userNameField stringValue];
    //genTestUserSig 方法仅用于本地测试，请不要将如下代码发布到您的线上正式版本的 App 中，原因如下：
    /*
     *  本文件中的代码虽然能够正确计算出 UserSig，但仅适合快速调通 SDK 的基本功能，不适合线上产品，
     *  这是因为客户端代码中的 SECRETKEY 很容易被反编译逆向破解，尤其是 Web 端的代码被破解的难度几乎为零。
     *  一旦您的密钥泄露，攻击者就可以计算出正确的 UserSig 来盗用您的腾讯云流量。
     *
     *  正确的做法是将 UserSig 的计算代码和加密密钥放在您的业务服务器上，然后由 App 按需向您的服务器获取实时算出的 UserSig。
     *  由于破解服务器的成本要高于破解客户端 App，所以服务器计算的方案能够更好地保护您的加密密钥。
     */
    param.userSig = [GenerateTestUserSig genTestUserSig:[_userNameField stringValue]];
    __weak typeof(self) ws = self;
    [[TIMManager sharedInstance] login:param succ:^{
        ConversationController *vc = [[ConversationController alloc] initWithNibName:@"ConversationController" bundle:nil];
        [ws presentViewControllerAsModalWindow:vc];
    } fail:^(int code, NSString *msg) {
        [ws alert:@"登录失败！" informativeText:[NSString stringWithFormat:@"code:%d msg:%@ ,请检查sdkAppId 和 userSig 是否正确配置",code,msg]];
    }];
}

- (void)alert:(NSString *)text informativeText:(NSString *)informativeText{
    NSAlert *alert = [NSAlert new];
    [alert addButtonWithTitle:@"知道了"];
    [alert setMessageText:text];
    [alert setInformativeText:informativeText];
    [alert beginSheetModalForWindow:[self.view window] completionHandler:^(NSModalResponse returnCode) {
        //to do
    }];
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
}

- (void)getUserSig:(NSString *)user callback:(void (^)(NSString *sig))callback
{
    NSURL *url = [NSURL URLWithString:@""];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
    request.HTTPMethod = @"POST";
    NSDictionary *param = @{@"cmd":@"open_account_svc", @"sub_cmd":@"fetch_sig", @"id":user};
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil];
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        int code = [[result objectForKey:@"error_code"] intValue];
        NSString *sig = nil;
        if(code == 0){
            sig = [result objectForKey:@"user_sig"];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(sig);
        });
    }];
    [task resume];
}

@end

