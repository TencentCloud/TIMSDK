//
//  TUICommonDefine.h
//  TUICallEngine
//
//  Created by noah on 2022/8/4.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TUILog.h"

/// 播放设备：听筒 或 麦克风
typedef NS_ENUM(NSUInteger, TUIAudioPlaybackDevice) {
    TUIAudioPlaybackDeviceSpeakerphone,
    TUIAudioPlaybackDeviceEarpiece,
};

/// 摄像头：前置 或 后置
typedef NS_ENUM(NSUInteger, TUICamera) {
    TUICameraFront,
    TUICameraBack,
};

/// 网络质量
typedef NS_ENUM(NSInteger, TUINetworkQuality) {
    TUINetworkQualityUnknown,
    TUINetworkQualityExcellent,
    TUINetworkQualityGood,
    TUINetworkQualityPoor,
    TUINetworkQualityBad,
    TUINetworkQualityVbad,
    TUINetworkQualityDown,
};

typedef NS_ENUM(NSInteger, TUIVideoRenderParamsFillMode) {
    
    /// 0, 填充模式：即将画面内容居中等比缩放以充满整个显示区域，超出显示区域的部分将会被裁剪掉，此模式下画面可能不完整。
    TUIVideoRenderParamsFillModeFill = 0,
    
    /// 1, 适应模式：即按画面长边进行缩放以适应显示区域，短边部分会被填充为黑色，此模式下图像完整但可能留有黑边。
    TUIVideoRenderParamsFillModeFit = 1,
    
};

typedef NS_ENUM(NSInteger, TUIVideoRenderParamsRotation) {
    
    /// 0, 不旋转。
    TUIVideoRenderParamsRotation_0 = 0,
    
    /// 1, 顺时针旋转90度。
    TUIVideoRenderParamsRotation_90 = 1,
    
    /// 2, 顺时针旋转180度。
    TUIVideoRenderParamsRotation_180 = 2,
    
    /// 3, 顺时针旋转270度。
    TUIVideoRenderParamsRotation_270 = 3,
    
};

typedef NS_ENUM(NSInteger, TUIVideoEncoderParamsResolutionMode) {
    
    /// 0, 横屏分辨率,例如：Resolution_640_360 + Landscape = 640x360。
    TUIVideoEncoderParamsResolutionModeLandscape = 0,
    
    /// 1, 竖屏分辨率,例如：Resolution_640_360 + Portrait = 360x640。
    TUIVideoEncoderParamsResolutionModePortrait = 1,
    
};

typedef NS_ENUM(NSInteger, TUIVideoEncoderParamsResolution) {
    
    /// 宽高比 4:3；分辨率 640x480；建议码率（VideoCall）600kbps。
    TUIVideoEncoderParamsResolution_640_480 = 62,
    
    /// 宽高比 4:3；分辨率 960x720；建议码率（VideoCall）1000kbps。
    TUIVideoEncoderParamsResolution_960_720 = 64,
    
    /// 宽高比 16:9；分辨率 640x360；建议码率（VideoCall）500kbps。
    TUIVideoEncoderParamsResolution_640_360 = 108,
    
    /// 宽高比 16:9；分辨率 960x540；建议码率（VideoCall）850kbps。
    TUIVideoEncoderParamsResolution_960_540 = 110,
    
    /// 宽高比 16:9；分辨率 1280x720；建议码率（VideoCall）1200kbps。
    TUIVideoEncoderParamsResolution_1280_720 = 112,
    
    /// 宽高比 16:9；分辨率 1920x1080；建议码率（VideoCall）2000kbps。
    TUIVideoEncoderParamsResolution_1920_1080 = 114,
    
};

NS_ASSUME_NONNULL_BEGIN

@interface TUIRoomId : NSObject

@property(nonatomic, assign) UInt32 intRoomId;

@end

@interface TUINetworkQualityInfo : NSObject

@property(nonatomic, copy, nullable) NSString *userId;

@property(nonatomic, assign) TUINetworkQuality quality;

@end

@interface TUIVideoView : UIView

@end

@interface TUIVideoRenderParams : NSObject

@property(nonatomic, assign) TUIVideoRenderParamsFillMode fillMode;

@property(nonatomic, assign) TUIVideoRenderParamsRotation rotation;

@end

@interface TUIVideoEncoderParams : NSObject

@property(nonatomic, assign) TUIVideoEncoderParamsResolution resolution;

@property(nonatomic, assign) TUIVideoEncoderParamsResolutionMode resolutionMode;

@end

NS_ASSUME_NONNULL_END
