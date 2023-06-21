//
//  TIMInputViewMoreActionProtocol.h
//  TIMCommon
//
//  Created by wyl on 2023/5/5.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol TIMInputViewMoreActionProtocol <NSObject>

- (void)sendMessage:(V2TIMMessage *)message;

@end

NS_ASSUME_NONNULL_END
