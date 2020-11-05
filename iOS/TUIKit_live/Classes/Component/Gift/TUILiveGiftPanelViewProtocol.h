//
//  TUILiveGiftPannelViewProtocol.h
//  Pods
//
//  Created by harvy on 2020/9/22.
//

#import <Foundation/Foundation.h>
@class TUILiveGiftInfoDataHandler;
@protocol TUILiveGiftPanelDelegate;


NS_ASSUME_NONNULL_BEGIN

@protocol TUILiveGiftPanelViewProtocol <NSObject>

- (instancetype)initWithProvider:(TUILiveGiftInfoDataHandler *)dataProvider;
- (void)showInView:(UIView *)view;
- (void)hide;
- (void)setGiftPannelDelegate:(id<TUILiveGiftPanelDelegate>)delegate;

@end

NS_ASSUME_NONNULL_END
