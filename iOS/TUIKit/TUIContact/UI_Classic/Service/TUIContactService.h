//
//  TUIContactService.h
//  lottie-ios
//
//  Created by kayev on 2021/8/18.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUICore.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIContactService : NSObject <TUIServiceProtocol>

+ (TUIContactService *)shareInstance;

@end

NS_ASSUME_NONNULL_END
