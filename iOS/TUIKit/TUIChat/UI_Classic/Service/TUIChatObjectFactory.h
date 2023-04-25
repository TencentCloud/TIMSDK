//
//  TUIChatObjectFactory.h
//  TUIChat
//
//  Created by wyl on 2023/3/20.
//

#import <Foundation/Foundation.h>
#import <TUICore/TUICore.h>
#import <TIMCommon/TIMDefine.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIChatObjectFactory : NSObject
+ (TUIChatObjectFactory *)shareInstance;
@end

NS_ASSUME_NONNULL_END
