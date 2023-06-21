
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import <Foundation/Foundation.h>
#import <TIMCommon/TIMCommonModel.h>
#import <TUICore/TUICore.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIGroupService : NSObject <TUIServiceProtocol>

+ (TUIGroupService *)shareInstance;

@end

NS_ASSUME_NONNULL_END
