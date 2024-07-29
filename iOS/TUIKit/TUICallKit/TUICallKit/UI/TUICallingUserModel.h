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

@property (nonatomic, copy) NSString *userId;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *avatar;
@property (nonatomic, assign) TUICallRole role;
@property (nonatomic, assign) BOOL isEnter;
@property (nonatomic, assign) BOOL isAudioAvailable;
@property (nonatomic, assign) BOOL isVideoAvailable;
@property (nonatomic, assign) float volume;

@end

NS_ASSUME_NONNULL_END
