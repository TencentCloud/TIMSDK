//
//  ConversationController_Minimalist.h
//  TUIKitDemo
//
//  Created by wyl on 2022/10/12.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ConversationController_Minimalist : UIViewController

- (void)pushToChatViewController:(NSString *)groupID userID:(NSString *)userID;

@end

NS_ASSUME_NONNULL_END
