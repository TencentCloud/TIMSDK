#import <UIKit/UIKit.h>

#define Key_UserInfo_Appid @"Key_UserInfo_Appid"
#define Key_UserInfo_User  @"Key_UserInfo_User"
#define Key_UserInfo_Pwd   @"Key_UserInfo_Pwd"
#define Key_UserInfo_Sig   @"Key_UserInfo_Sig"

//apns (sdkBusiId 为证书上传控制台后生成，详情请参考文档[离线推送]（https://cloud.tencent.com/document/product/269/44517）)
#ifdef DEBUG
#define sdkBusiId 10000
#else
#define sdkBusiId 10000
#endif

//bugly
#define BUGLY_APP_ID      @"e965e5d928"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

+ (id)sharedInstance;

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) NSData *deviceToken;
- (UIViewController *)getLoginController;
- (UITabBarController *)getMainController;
@end

