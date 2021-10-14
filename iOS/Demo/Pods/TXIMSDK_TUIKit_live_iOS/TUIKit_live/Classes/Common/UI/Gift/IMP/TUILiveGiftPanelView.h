//
//  TUILiveGiftPannelView.h
//  Pods
//
//  Created by harvy on 2020/9/16.
//

#import <UIKit/UIKit.h>
#import "TUILivePopupView.h"
#import "TUILiveGiftPanelDelegate.h"
#import "TUILiveGiftPanelViewProtocol.h"

@protocol TUILiveGiftDataSource;

NS_ASSUME_NONNULL_BEGIN

@interface TUILiveGiftPanelView : TUILivePopupView <TUILiveGiftPanelViewProtocol>

@end

NS_ASSUME_NONNULL_END
