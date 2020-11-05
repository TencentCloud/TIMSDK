//
//  TUIAnchorInfo.h
//  TUIKitDemo
//
//  Created by coddyliu on 2020/9/7.
//  Copyright © 2020 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUILiveAnchorInfo : NSObject
@property(nonatomic, strong) NSString *avatarUrl;
@property(nonatomic, strong) NSString *nickName;
@property(nonatomic, assign) float weightValue;
@property(nonatomic, strong) NSString *userId;

@property(nonatomic, strong) NSString *weightTagName;
@end

NS_ASSUME_NONNULL_END
