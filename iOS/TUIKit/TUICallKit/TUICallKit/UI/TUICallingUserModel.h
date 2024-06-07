//
//  TUICallingUserModel.h
//  TUICallKit
//
//  Created by noah on 2022/8/4.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TUICallEngineHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface CallingUserModel : NSObject<NSCopying>

/// 用户 ID
@property (nonatomic, copy) NSString *userId;
/// 用户昵称
@property (nonatomic, copy) NSString *name;
/// 用户头像
@property (nonatomic, copy) NSString *avatar;
/// 用户角色
@property (nonatomic, assign) TUICallRole role;
/// 用户是否进房
@property (nonatomic, assign) BOOL isEnter;
/// 用户音频是否打开
@property (nonatomic, assign) BOOL isAudioAvailable;
/// 用户视频是否打开
@property (nonatomic, assign) BOOL isVideoAvailable;
/// 声音大小
@property (nonatomic, assign) float volume;

@end

NS_ASSUME_NONNULL_END
