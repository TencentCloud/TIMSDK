#import "LoginController.h"
#import <sys/sysctl.h>
#import <sys/utsname.h>
#import "TUIKit.h"
#import "AppDelegate.h"
#import "ImSDK.h"
#import "GenerateTestUserSig.h"

@interface LoginController ()
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextFeild;
@end

@implementation LoginController

- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    [self.view addGestureRecognizer:tap];
}

- (IBAction)login:(id)sender {
    __weak typeof(self) ws = self;
    if (SDKAPPID == 0 || [SECRETKEY isEqual: @""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Demo 尚未配置 sdkAppid 和加密密钥，请前往 GenerateTestUserSig.h 配置" message:nil delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alert show];
    }
    else if ([_userNameTextFeild.text isEqual: @""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请输入用户名！" message:nil delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
        [alert show];
    }
    else{
        TIMLoginParam *param = [[TIMLoginParam alloc] init];
        param.identifier = _userNameTextFeild.text;
        //genTestUserSig 方法仅用于本地测试，请不要将如下代码发布到您的线上正式版本的 App 中，原因如下：
        /*
        *  本文件中的代码虽然能够正确计算出 UserSig，但仅适合快速调通 SDK 的基本功能，不适合线上产品，
        *  这是因为客户端代码中的 SECRETKEY 很容易被反编译逆向破解，尤其是 Web 端的代码被破解的难度几乎为零。
        *  一旦您的密钥泄露，攻击者就可以计算出正确的 UserSig 来盗用您的腾讯云流量。
        *
        *  正确的做法是将 UserSig 的计算代码和加密密钥放在您的业务服务器上，然后由 App 按需向您的服务器获取实时算出的 UserSig。
        *  由于破解服务器的成本要高于破解客户端 App，所以服务器计算的方案能够更好地保护您的加密密钥。
        */
        param.userSig = [GenerateTestUserSig genTestUserSig:_userNameTextFeild.text];
        [[TIMManager sharedInstance] login:param succ:^{
            AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            NSData *deviceToken = delegate.deviceToken;
            if (deviceToken) {
                TIMTokenParam *param = [[TIMTokenParam alloc] init];
                /* 用户自己到苹果注册开发者证书，在开发者帐号中下载并生成证书(p12 文件)，将生成的 p12 文件传到腾讯证书管理控制台，控制台会自动生成一个证书 ID，将证书 ID 传入一下 busiId 参数中。*/
                //企业证书 ID
                param.busiId = sdkBusiId;
                [param setToken:deviceToken];
                [[TIMManager sharedInstance] setToken:param succ:^{
                    NSLog(@"-----> 上传 token 成功 ");
                    //推送声音的自定义化设置
                    TIMAPNSConfig *config = [[TIMAPNSConfig alloc] init];
                    config.openPush = 0;
                    config.c2cSound = @"00.caf";
                    config.groupSound = @"01.caf";
                    [[TIMManager sharedInstance] setAPNS:config succ:^{
                        NSLog(@"-----> 设置 APNS 成功");
                    } fail:^(int code, NSString *msg) {
                        NSLog(@"-----> 设置 APNS 失败");
                    }];
                } fail:^(int code, NSString *msg) {
                    NSLog(@"-----> 上传 token 失败 ");
                }];
            }
            [[NSUserDefaults standardUserDefaults] setObject:@(SDKAPPID) forKey:Key_UserInfo_Appid];
            [[NSUserDefaults standardUserDefaults] setObject:param.identifier forKey:Key_UserInfo_User];
            [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:Key_UserInfo_Pwd];
            [[NSUserDefaults standardUserDefaults] setObject:param.userSig forKey:Key_UserInfo_Sig];
            dispatch_async(dispatch_get_main_queue(), ^{
                [ws presentViewController:[((AppDelegate *)[UIApplication sharedApplication].delegate) getMainController] animated:YES completion:nil];
            });;
        } fail:^(int code, NSString *msg) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"code:%d msdg:%@ ,请检查 sdkappid,identifier,userSig 是否正确配置",code,msg] message:nil delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
            [alert show];
        }];
    }
}

- (void)onTap:(UIGestureRecognizer *)recognizer
{
    [_userNameTextFeild resignFirstResponder];
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
