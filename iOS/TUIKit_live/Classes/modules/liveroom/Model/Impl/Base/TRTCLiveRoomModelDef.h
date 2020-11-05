//
//  TRTCLiveRoomModelDef.h
//  TRTCVoiceRoomOCDemo
//
//  Created by abyyxwang on 2020/7/12.
//  Copyright © 2020 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TRTCPKAnchorInfo : NSObject

@property (nonatomic, copy, nullable) NSString *userId;
@property (nonatomic, copy, nullable) NSString *roomId;
@property (nonatomic, assign) BOOL isResponsed;
@property (nonatomic, copy) NSString *uuid;

- (void)reset;

@end

@interface TRTCJoinAnchorInfo : NSObject

@property (nonatomic, copy, nullable) NSString *userId;
@property (nonatomic, copy) NSString *uuid;
@property (nonatomic, assign) BOOL isResponsed;

- (void)reset;

@end

NS_ASSUME_NONNULL_END
