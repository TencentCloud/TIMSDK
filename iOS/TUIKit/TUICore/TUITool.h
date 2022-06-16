
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#define IS_NOT_EMPTY_NSSTRING(__X__)            (__X__ && [__X__ isKindOfClass:[NSString class]] && ![__X__ isEqualToString:@""])

typedef void (^TAsyncImageComplete)(NSString *path, UIImage *image);

@interface TUITool : NSObject
// json & str & data
+ (NSData *)dictionary2JsonData:(NSDictionary *)dict;
+ (NSString *)dictionary2JsonStr:(NSDictionary *)dict;
+ (NSDictionary *)jsonSring2Dictionary:(NSString *)jsonString;
+ (NSDictionary *)jsonData2Dictionary:(NSData *)jsonData;

// toast
+ (void)makeToast:(NSString *)str;
+ (void)makeToast:(NSString *)str duration:(NSTimeInterval)duration;
+ (void)makeToast:(NSString *)str duration:(NSTimeInterval)duration position:(CGPoint)position;
+ (void)makeToast:(NSString *)str duration:(NSTimeInterval)duration idposition:(id)position;
+ (void)makeToastError:(NSInteger)error msg:(NSString *)msg;
+ (void)hideToast;
+ (void)makeToastActivity;
+ (void)hideToastActivity;

// 切换主线程
+(void)dispatchMainAsync:(dispatch_block_t) block;

// date
+ (NSString *)convertDateToStr:(NSDate *)date;

// msg code convert
+ (NSString *)convertIMError:(NSInteger)code msg:(NSString *)msg;

// 富媒体
+ (NSString *)genImageName:(NSString *)uuid;
+ (NSString *)genSnapshotName:(NSString *)uuid;
+ (NSString *)genVideoName:(NSString *)uuid;
+ (NSString *)genFileName:(NSString *)uuid;
+ (NSString *)genVoiceName:(NSString *)uuid withExtension:(NSString *)extent;
+ (void)asyncDecodeImage:(NSString *)path complete:(TAsyncImageComplete)complete;
+ (NSString *)randAvatarUrl;

// 设备
+ (NSString *)deviceModel;
+ (NSString *)deviceVersion;
+ (NSString *)deviceName;

// 跳转浏览器打开
+ (void)openLinkWithURL:(NSURL *)url;

// 套餐包不支持功能弹框
+ (void)showUnsupportAlertOfService:(NSString *)service onVC:(UIViewController *)vc;
// 套餐包不支持通知
+ (void)postUnsupportNotificationOfService:(NSString *)service;
+ (void)addUnsupportNotificationInVC:(UIViewController *)vc;

@end
