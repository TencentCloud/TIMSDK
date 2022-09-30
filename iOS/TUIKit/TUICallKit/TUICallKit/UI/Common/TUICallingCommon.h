//
//  TUICallingCommon.h
//  TUICalling
//
//  Created by noah on 2022/5/31.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class V2TIMUserFullInfo, CallingUserModel;

#define kControlBtnSize CGSizeMake(100, 92)
#define kBtnLargeSize CGSizeMake(64, 64)
#define kBtnSmallSize CGSizeMake(52, 52)

NS_ASSUME_NONNULL_BEGIN

static NSString * const TUI_CALL_DEFAULT_AVATAR = @"https://imgcache.qq.com/qcloud/public/static//avatar1_100.20191230.png";

typedef NS_ENUM(NSUInteger, AuthorizationDeniedType ) {
    AuthorizationDeniedTypeAudio,
    AuthorizationDeniedTypeVideo,
};

@interface TUICallingCommon : NSObject

+ (NSBundle *)callingBundle;

+ (UIImage *)getBundleImageWithName:(NSString *)name;

+ (UIWindow *)getKeyWindow;

+ (BOOL)checkDictionaryValid:(id)data;

+ (BOOL)checkArrayValid:(id)data;

+ (id)fetchModelWithIndex:(NSInteger)index dataArray:(NSArray *)dataArray;

+ (NSInteger)fetchIndexWithModel:(id)model dataArray:(NSArray *)dataArray;

+ (BOOL)checkIndexInRangeWith:(NSInteger)index dataArray:(NSArray *)dataArray;

+ (CallingUserModel *)covertUser:(V2TIMUserFullInfo *)user;

+ (CallingUserModel *)covertUser:(V2TIMUserFullInfo *)user isEnter:(BOOL)isEnter;

+ (CallingUserModel *)convertUser:(V2TIMUserFullInfo *)user volume:(NSUInteger)volume isEnter:(BOOL)isEnter;

+ (void)showAuthorizationAlert:(AuthorizationDeniedType)deniedType;

@end

NS_ASSUME_NONNULL_END
