//
//  TUIChatObjectFactory.h
//  TUIChat
//
//  Created by wyl on 2023/3/20.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUICore.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIChatObjectFactory : NSObject
+ (TUIChatObjectFactory *)shareInstance;
@end

NS_ASSUME_NONNULL_END
