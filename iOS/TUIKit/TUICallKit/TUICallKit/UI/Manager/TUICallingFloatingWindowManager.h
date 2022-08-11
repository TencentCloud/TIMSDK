//
//  TUICallingFloatingWindowManager.h
//  TUICalling
//
//  Created by noah on 2022/1/13.
//  Copyright © 2022 Tencent. All rights reserved
//

#import <Foundation/Foundation.h>
#import "TUICallEngineHeader.h"
#import "TUICallingVideoRenderView.h"
#import "TUICallingFloatingWindow.h"

@class TUICallingVideoRenderView;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TUICallingFloatingWindowType) {
    TUICallingFloatingWindowTypeAudio,
    TUICallingFloatingWindowTypeVideo,
};

@protocol TUICallingFloatingWindowManagerDelegate <NSObject>

- (void)floatingWindowDidClickView;

@end

@interface TUICallingFloatingWindowManager : NSObject

@property (nonatomic, assign) BOOL isFloating;
@property (nonatomic, strong) TUICallingFloatingWindow *floatWindow;

+ (instancetype)shareInstance;

- (void)setFloatingWindowManagerDelegate:(id<TUICallingFloatingWindowManagerDelegate>)delegagte;

- (void)showMicroFloatingWindowWithCallingWindow:(nullable UIWindow *)callingWindow VideoRenderView:(nullable TUICallingVideoRenderView *)renderView Completion:(void (^ __nullable)(BOOL finished))completion;

- (void)closeWindowCompletion:(void (^ __nullable)(BOOL finished))completion;

- (void)switchToAudioMicroWindowWith:(TUICallStatus)callStatus callRole:(TUICallRole)callRole;

- (void)updateMicroWindowText:(NSString *)textStr callStatus:(TUICallStatus)callStatus callRole:(TUICallRole)callRole;

- (void)updateMicroWindowRenderView:(TUICallingVideoRenderView *)renderView;

@end

NS_ASSUME_NONNULL_END
