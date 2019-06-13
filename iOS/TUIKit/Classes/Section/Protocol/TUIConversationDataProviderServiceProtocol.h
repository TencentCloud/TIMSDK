//
//  TUIConversationDataProviderServiceProtocol.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/6/11.
//

#import <Foundation/Foundation.h>
#import "ImSDK/TIMConversation.h"
@import UIKit;

@class TIMConversation;
NS_ASSUME_NONNULL_BEGIN

@protocol TUIConversationDataProviderServiceProtocol <NSObject>

- (int)getMessage:(TIMConversation *)conv count:(int)count last:(TIMMessage*)last succ:(TIMGetMsgSucc)succ fail:(TIMFail)fail;

@end

NS_ASSUME_NONNULL_END
