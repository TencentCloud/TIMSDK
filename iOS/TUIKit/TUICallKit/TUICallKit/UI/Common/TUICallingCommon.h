//
//  TUICallingCommon.h
//  TUICalling
//
//  Created by noah on 2022/5/31.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "TUICallEngineHeader.h"

@class V2TIMUserFullInfo, CallingUserModel;

#define kControlBtnSize CGSizeMake(100, 92)
#define kBtnLargeSize CGSizeMake(64, 64)
#define kBtnSmallSize CGSizeMake(52, 52)

#ifndef dispatch_callkit_main_async_safe
#define dispatch_callkit_main_async_safe(block)\
if (dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL) == dispatch_queue_get_label(dispatch_get_main_queue())) {\
block();\
} else {\
dispatch_async(dispatch_get_main_queue(), block);\
}
#endif

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, AuthorizationDeniedType ) {
    AuthorizationDeniedTypeAudio,
    AuthorizationDeniedTypeVideo,
};

@interface TUICallingCommon : NSObject

+ (NSBundle *)callingBundle;

+ (UIImage *)getBundleImageWithName:(NSString *)name;

+ (UIWindow *)getKeyWindow;

+ (CGFloat)getStatusBarHeight;

+ (BOOL)checkDictionaryValid:(id)data;

+ (BOOL)checkArrayValid:(id)data;

+ (id)fetchModelWithIndex:(NSInteger)index dataArray:(NSArray *)dataArray;

+ (NSInteger)fetchIndexWithModel:(id)model dataArray:(NSArray *)dataArray;

+ (BOOL)checkIndexInRangeWith:(NSInteger)index dataArray:(NSArray *)dataArray;

+ (CallingUserModel *)covertUser:(V2TIMUserFullInfo *)user;

+ (CallingUserModel *)covertUser:(V2TIMUserFullInfo *)user isEnter:(BOOL)isEnter;

+ (CallingUserModel *)convertUser:(V2TIMUserFullInfo *)user volume:(NSUInteger)volume isEnter:(BOOL)isEnter;

+ (BOOL)checkAuthorizationStatusIsDenied:(TUICallMediaType)callMediaType;

+ (void)showAuthorizationAlert:(AuthorizationDeniedType)deniedType
            openSettingHandler:(void(^)(void))openSettingHandler
                 cancelHandler:(void(^)(void))cancelHandler;
@end

NS_ASSUME_NONNULL_END
