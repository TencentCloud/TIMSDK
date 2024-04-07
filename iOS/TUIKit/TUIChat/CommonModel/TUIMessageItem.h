//
//  TUIChatConfig.h
//  TUIChat
//
//  Created by wyl on 2022/6/10.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, TUIImageType) {
    TImage_Type_Origin = 1,
    TImage_Type_Thumb = 2,
    TImage_Type_Large = 4,
};

/////////////////////////////////////////////////////////////////////////////////
//
//                             TUIImageItem
//
/////////////////////////////////////////////////////////////////////////////////
@interface TUIImageItem : NSObject

/**
 *  The inner ID for the image, can be used for external cache key
 */
@property(nonatomic, strong) NSString *uuid;

@property(nonatomic, strong) NSString *url;

@property(nonatomic, assign) CGSize size;

@property(nonatomic, assign) TUIImageType type;
@end

/////////////////////////////////////////////////////////////////////////////////
//
//                             TUIVideoItem
//
/////////////////////////////////////////////////////////////////////////////////
///
@interface TUIVideoItem : NSObject

/**
 *  The internal ID of the video message, which does not need to be set, is obtained from the video instance pulled by the SDK.
 */
@property(nonatomic, strong) NSString *uuid;

/**
 *  The video type - the suffix of the video file - is set when sending a message. For example "mp4".
 */
@property(nonatomic, strong) NSString *type;

/**
 *  The video size, no need to set, is obtained from the instance pulled by the SDK.
 */
@property(nonatomic, assign) NSInteger length;

/**
 *  video duration
 */
@property(nonatomic, assign) NSInteger duration;
@end

/////////////////////////////////////////////////////////////////////////////////
//
//                            TUISnapshotItem
//
/////////////////////////////////////////////////////////////////////////////////

@interface TUISnapshotItem : NSObject

/**
 *  Image ID, internal identifier, can be used for external cache key
 */
@property(nonatomic, strong) NSString *uuid;

/**
 *  Cover image type
 */
@property(nonatomic, strong) NSString *type;

/**
 *  The size of the cover on the UI.
 */
@property(nonatomic, assign) CGSize size;

@property(nonatomic, assign) NSInteger length;
@end
NS_ASSUME_NONNULL_END
