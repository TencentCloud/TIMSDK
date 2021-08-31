//
//  TUILiveRoomInfo.h
//  TUIKitDemo
//
//  Created by abyyxwang on 2020/9/8.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUILiveRoomInfo : NSObject

@property (nonatomic, assign) NSInteger roomID;
@property (nonatomic, strong) NSString *roomName;
@property (nonatomic, strong) NSString *coverUrl;
@property (nonatomic, strong) NSString *ownerId;
@property (nonatomic, strong) NSString *ownerName;
@property (nonatomic, assign) NSInteger memberCount;
@property (nonatomic, assign) BOOL needRequest;

/// 构造器
/// @param roomID 房间ID
/// @param ownerId 房主ID
/// @param memberCount 房间人数
-(instancetype)initWithRoomID:(NSInteger)roomID ownerId:(NSString *)ownerId memberCount:(NSInteger)memberCount;

@end

NS_ASSUME_NONNULL_END
