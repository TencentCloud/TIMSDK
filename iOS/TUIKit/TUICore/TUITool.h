
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#define IS_NOT_EMPTY_NSSTRING(__X__) (__X__ && [__X__ isKindOfClass:[NSString class]] && ![__X__ isEqualToString:@""])

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

+ (void)dispatchMainAsync:(dispatch_block_t)block;

// date
+ (NSString *)convertDateToStr:(NSDate *)date;
+ (NSString *)convertDateToHMStr:(NSDate *)date;

// msg code convert
+ (NSString *)convertIMError:(NSInteger)code msg:(NSString *)msg;
+ (void)configIMErrorMap;

+ (NSString *)genImageName:(NSString *)uuid;
+ (NSString *)genSnapshotName:(NSString *)uuid;
+ (NSString *)genVideoName:(NSString *)uuid;
+ (NSString *)genFileName:(NSString *)uuid;
+ (NSString *)genVoiceName:(NSString *)uuid withExtension:(NSString *)extent;
+ (void)asyncDecodeImage:(NSString *)path complete:(TAsyncImageComplete)complete;

+ (NSString *)deviceModel;
+ (NSString *)deviceVersion;
+ (NSString *)deviceName;

+ (void)openLinkWithURL:(NSURL *)url;

+ (void)showUnsupportAlertOfService:(NSString *)service onVC:(UIViewController *)vc;
+ (void)postUnsupportNotificationOfService:(NSString *)service;
+ (void)postUnsupportNotificationOfService:(NSString *)service serviceDesc:(NSString *)serviceDesc debugOnly:(BOOL)debugOnly;
+ (void)addUnsupportNotificationInVC:(UIViewController *)vc;
+ (void)addUnsupportNotificationInVC:(UIViewController *)vc debugOnly:(BOOL)debugOnly;

+ (void)addValueAddedUnsupportNeedContactNotificationInVC:(UIViewController *)vc debugOnly:(BOOL)debugOnly;
+ (void)addValueAddedUnsupportNeedPurchaseNotificationInVC:(UIViewController *)vc debugOnly:(BOOL)debugOnly;
+ (void)postValueAddedUnsupportNeedContactNotification:(NSString *)service;
+ (void)postValueAddedUnsupportNeedPurchaseNotification:(NSString *)service;

+ (void)checkCommercialAbility:(long long)param succ:(void (^)(BOOL enabled))succ fail:(void (^)(int code, NSString *desc))fail;

+ (UIWindow *)applicationKeywindow;

@end
