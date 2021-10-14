#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "CallingLocalized.h"
#import "TRTCCalling+Signal.h"
#import "TRTCCallingHeader.h"
#import "TRTCCallingModel.h"
#import "TRTCCallingUtils.h"
#import "TRTCSignalFactory.h"
#import "TRTCCalling.h"
#import "TRTCCallingDelegate.h"
#import "TUICallingManager.h"
#import "TUICallingService.h"
#import "TUICallingBaseView.h"
#import "TRTCGCDTimer.h"
#import "TUICallingAudioPlayer.h"
#import "TUICommonUtil.h"
#import "TUIGradientView.h"
#import "UIButton+TUIImageTitleSpacing.h"
#import "UIColor+TUIHex.h"
#import "UIView+TUIEX.h"
#import "TUICalleeDelegateManager.h"
#import "TUICallingDelegateManager.h"
#import "TUICallingActionProtocol.h"
#import "TUIInvitedActionProtocal.h"
#import "TUICallingView.h"
#import "TUIGroupCallingView.h"
#import "TUIAudioUserContainerView.h"
#import "TUICalleeGroupCell.h"
#import "TUICallingControlButton.h"
#import "TUICallingGroupCell.h"
#import "TUICallingVideoRenderView.h"
#import "TUIInvitedContainerView.h"
#import "TUIVideoUserContainerView.h"
#import "TUICallingKit.h"

FOUNDATION_EXPORT double TUICallingVersionNumber;
FOUNDATION_EXPORT const unsigned char TUICallingVersionString[];

