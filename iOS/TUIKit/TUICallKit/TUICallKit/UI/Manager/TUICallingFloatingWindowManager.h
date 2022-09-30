//
//  TUICallingFloatingWindowManager.h
//  TUICalling
//
//  Created by noah on 2022/1/13.
//  Copyright © 2022 Tencent. All rights reserved
//

#import <Foundation/Foundation.h>
#import "TUICallEngineHeader.h"
#import "TUICallingFloatingWindow.h"

@class CallingUserModel, TUICallingVideoRenderView;

NS_ASSUME_NONNULL_BEGIN

@protocol TUICallingFloatingWindowManagerDelegate <NSObject>

- (void)floatingWindowDidClickView;

@end

@interface TUICallingFloatingWindowManager : NSObject

@property (nonatomic, assign) BOOL isFloating;
@property (nonatomic, strong) TUICallingFloatingWindow * _Nullable floatWindow;
@property (nonatomic, strong) TUICallingVideoRenderView * _Nullable renderView;

+ (instancetype)shareInstance;

- (void)setFloatingWindowManagerDelegate:(id<TUICallingFloatingWindowManagerDelegate>)delegate;

- (void)showMicroFloatingWindow:(void (^ __nullable)(BOOL finished))completion;

- (void)closeMicroFloatingWindow:(void (^ __nullable)(BOOL finished))completion;

- (void)updateDescribeText:(NSString *)textStr;

- (void)updateUserModel:(CallingUserModel *)userModel;

@end

NS_ASSUME_NONNULL_END
