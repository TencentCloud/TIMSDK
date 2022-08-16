//
//  BaseFunctionViewProtocol.h
//  TUICalling
//
//  Created by noah on 2022/5/17.
//  Copyright © 2022 Tencent. All rights reserved
//

#import <Foundation/Foundation.h>
#import "TUICallingControlButton.h"
#import "CallingLocalized.h"
#import "UIColor+TUICallingHex.h"
#import "TUICallingCommon.h"
#import "TUICallingAction.h"
#import "TUICallingVideoRenderView.h"
#import "TUICallingStatusManager.h"

NS_ASSUME_NONNULL_BEGIN

@protocol BaseFunctionViewProtocol <NSObject>

@optional

@property (nonatomic, strong) TUICallingVideoRenderView *localPreView;

- (void)updateTextColor:(UIColor *)textColor;

- (void)updateMicMuteStatus;

- (void)updateCameraOpenStatus;

- (void)updateHandsFreeStatus;

@end

NS_ASSUME_NONNULL_END
