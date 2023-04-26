//
//  TUIChatConfig.h
//  TUIChat
//
//  Created by wyl on 2022/6/10.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TUIImageType) {
    TImage_Type_Thumb,
    TImage_Type_Large,
    TImage_Type_Origin,
};

/////////////////////////////////////////////////////////////////////////////////
//
//                             TUIImageItem
//
/////////////////////////////////////////////////////////////////////////////////
@interface TUIImageItem : NSObject

/**
 *  图片 ID，内部标识，可用于外部缓存key
 *
 *  The inner ID for the image, can be used for external cache key
 */
@property (nonatomic, strong) NSString *uuid;

@property (nonatomic, strong) NSString *url;

@property (nonatomic, assign) CGSize size;

@property (nonatomic, assign) TUIImageType type;
@end

/////////////////////////////////////////////////////////////////////////////////
//
//                             TUIVideoItem
//
/////////////////////////////////////////////////////////////////////////////////
///
@interface TUIVideoItem : NSObject

/**
 *  视频消息内部 ID，不用设置，通过 SDK 拉取的视频实例中获取。
 *  The internal ID of the video message, which does not need to be set, is obtained from the video instance pulled by the SDK.
 */
@property (nonatomic, strong) NSString *uuid;

/**
 *  视频类型，即后缀格式，发送消息时设置。比如“mp4”。
 *  The video type - the suffix of the video file - is set when sending a message. For example "mp4".
 */
@property (nonatomic, strong) NSString *type;

/**
 *  视频体积大小，无需设置，通过 SDK 拉取的实例中获取。
 *  The video size, no need to set, is obtained from the instance pulled by the SDK.
 */
@property (nonatomic, assign) NSInteger length;

/**
 *  视频时长
 *  video duration
 */
@property (nonatomic, assign) NSInteger duration;
@end

/////////////////////////////////////////////////////////////////////////////////
//
//                            TUISnapshotItem
//
/////////////////////////////////////////////////////////////////////////////////

@interface TUISnapshotItem : NSObject

/**
 *  图片 ID，内部标识，可用于外部缓存key
 *  Image ID, internal identifier, can be used for external cache key
 */
@property (nonatomic, strong) NSString *uuid;

/**
 *  封面图片
 *  Cover image type
 */
@property (nonatomic, strong) NSString *type;

/**
 *  封面在 UI 上的大小。
 *  The size of the cover on the UI.
 */
@property (nonatomic, assign) CGSize size;

@property (nonatomic, assign) NSInteger length;
@end
NS_ASSUME_NONNULL_END
