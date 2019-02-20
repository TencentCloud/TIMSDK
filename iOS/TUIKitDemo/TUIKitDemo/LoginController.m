//
//  LoginController.m
//  TUIKitDemo
//
//  Created by kennethmiao on 2018/10/10.
//  Copyright © 2018年 kennethmiao. All rights reserved.
//

#import "LoginController.h"
#import <sys/sysctl.h>
#import <sys/utsname.h>
//#import "ImSDK.h"
#import "TUIKit.h"
#import "TFaceCell.h"
#import "TMoreCell.h"
#import "TMenuCell.h"
#import "TFaceView.h"
#import "THeader.h"
#import "AppDelegate.h"
#import "UserSelectView.h"

@interface LoginController ()<UserSelectViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *userSig;
@end

@implementation LoginController
{
    NSArray  *_userNames;
    NSArray  *_userSigs;
    NSString *_userName;
    NSString *_userSig;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _userNames = @[identifier1,identifier2,identifier3,identifier4];
    _userSigs  = @[userSig1,userSig2,userSig3,userSig4];
    _userName  = _userNames[0];
    _userSig   = _userSigs[0];
    
    UserSelectView *view = [[UserSelectView alloc] initWithFrame:CGRectMake(self.userNameLabel.frame.origin.x + self.userNameLabel.frame.size.width + 15, [self isiPhoneX] ? self.userNameLabel.frame.origin.y + 20 : self.userNameLabel.frame.origin.y, 200, 30)];
    view.dataSource = _userNames;
    view.delegate = self;
    [self.view addSubview:view];
}

- (IBAction)login:(id)sender {
    __weak typeof(self) ws = self;
    //[self getUserSig:@"" callback:^(NSString *sig) {
    if ([_userName isEqual: @""] || [_userSig isEqual: @""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"当前用户未配置identifier 和 userSig，请前往IM控制台 -> 开发者辅助工具生成，在xcode工程 AppDelegate 头文件配置" message:nil delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alert show];
    }else{
        [[TUIKit sharedInstance] loginKit:_userName userSig:_userSig succ:^{
            [[NSUserDefaults standardUserDefaults] setObject:@(sdkAppid) forKey:Key_UserInfo_Appid];
            [[NSUserDefaults standardUserDefaults] setObject:ws.userName forKey:Key_UserInfo_User];
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:Key_UserInfo_Pwd];
            [[NSUserDefaults standardUserDefaults] setObject:ws.userSig forKey:Key_UserInfo_Sig];
            dispatch_async(dispatch_get_main_queue(), ^{
                [ws presentViewController:[((AppDelegate *)[UIApplication sharedApplication].delegate) getMainController] animated:YES completion:nil];
            });
        } fail:^(int code, NSString *msg) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"code:%d msdg:%@ ,请检查 sdkappid,identifier,userSig 是否正确配置",code,msg] message:nil delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
            [alert show];
        }];
    }
    //}];
}

- (void)getUserSig:(NSString *)user callback:(void (^)(NSString *sig))callback
{
//    url 填写自己业务服务器获取userSig的地址
//    NSURL *url = [NSURL URLWithString:@""];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:30];
//    request.HTTPMethod = @"POST";
//    NSDictionary *param = @{@"cmd":@"open_account_svc", @"sub_cmd":@"fetch_sig", @"id":user};
//    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:param options:NSJSONWritingPrettyPrinted error:nil];
//    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//    NSURLSession *session = [NSURLSession sharedSession];
//    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//        int code = [[result objectForKey:@"error_code"] intValue];
//        NSString *sig = nil;
//        if(code == 0){
//            sig = [result objectForKey:@"user_sig"];
//        }
//        dispatch_async(dispatch_get_main_queue(), ^{
//            callback(sig);
//        });
//    }];
//    [task resume];
}

- (void)optionView:(UserSelectView *)optionView selectedIndex:(NSInteger)selectedIndex
{
    _userName = _userNames[selectedIndex];
    _userSig = _userSigs[selectedIndex];
}

- (BOOL)isiPhoneX {
    static BOOL isiPhoneX = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
#if TARGET_IPHONE_SIMULATOR
        // 获取模拟器所对应的 device model
        NSString *model = NSProcessInfo.processInfo.environment[@"SIMULATOR_MODEL_IDENTIFIER"];
#else
        // 获取真机设备的 device model
        struct utsname systemInfo;
        uname(&systemInfo);
        NSString *model = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
#endif
        // 判断 device model 是否为 "iPhone10,3" 和 "iPhone10,6" 或者以 "iPhone11," 开头
        // 如果是，就认为是 iPhone X
        isiPhoneX = [model isEqualToString:@"iPhone10,3"] || [model isEqualToString:@"iPhone10,6"] || [model hasPrefix:@"iPhone11,"];
    });
    
    return isiPhoneX;
}
@end
