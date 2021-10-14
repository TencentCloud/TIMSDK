//
//  TUILiveRoomAudienceViewController.h
//  TUILiveKit
//
//  Created by coddyliu on 2020/9/2.
//  Copyright © 2020 null. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TRTCLiveRoomDef.h"

NS_ASSUME_NONNULL_BEGIN
@class TRTCLiveRoomInfo;

@protocol TUILiveRoomAudienceDelegate <NSObject>

/// 观众间错误回调
/// @param roomInfo 主播间信息
/// @param errorCode 错误码
/// @param errorMessage 错误信息
- (void)onRoomError:(TRTCLiveRoomInfo *)roomInfo errorCode:(NSInteger)errorCode errorMessage:(NSString *)errorMessage;

@end

@class TUILiveAudienceVideoRenderView;
@interface TUILiveRoomAudienceViewController : UIViewController

@property (nonatomic, strong)TUILiveAudienceVideoRenderView *renderView;
@property (nonatomic, weak) id<TUILiveRoomAudienceDelegate> delegate;
/// 当前房间的状态
@property (nonatomic, assign, readonly) NSInteger roomStatus;
/// 初始化观众页
/// @param roomId 房间Id，必填
/// @param useCdn 是否使用CDN YES：使用 NO：不使用 默认：NO
/// @param anchorId 该直播间的主播userId，建议设置，选填
/// @param cdnUrl cdn拉流URL，选填
- (instancetype)initWithRoomId:(int)roomId
                      anchorId:(NSString * _Nullable)anchorId
                        useCdn:(BOOL)useCdn
                        cdnUrl:(NSString * _Nullable)cdnUrl;

@end

NS_ASSUME_NONNULL_END
