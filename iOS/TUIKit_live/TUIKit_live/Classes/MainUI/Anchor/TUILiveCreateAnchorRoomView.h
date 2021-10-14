//
//  TUILiveCreateAnchorRoomView.h
//  Masonry
//
//  Created by abyyxwang on 2020/9/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, TUILiveRoomAuidoQuality) {
    TUILiveRoomAuidoQualityStandard = 2,
    TUILiveRoomAuidoQualityMusic = 3,
};

@interface TUILiveRoomPublishParams : NSObject

@property(nonatomic, strong)NSString *roomName;
@property(nonatomic, assign)TUILiveRoomAuidoQuality audioQuality;

@end

/// 响应视图交互事件的代理
@protocol TUILiveCreateAnchorRoomViewDelegate <NSObject>

- (void)startPublish:(TUILiveRoomPublishParams *)roomParams;
- (void)switchCamera;
- (void)showBeautyPanel:(BOOL)isShow;
- (void)closeAction;

@end

@interface TUILiveCreateAnchorRoomView : UIView

@property(nonatomic, weak)id<TUILiveCreateAnchorRoomViewDelegate> viewPresenter;

@end

NS_ASSUME_NONNULL_END
