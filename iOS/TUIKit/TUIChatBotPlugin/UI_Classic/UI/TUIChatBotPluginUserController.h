//
//  TUIChatBotPluginUserController.h
//  TUIChatBotPlugin
//
//  Created by lynx on 2023/10/30.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class V2TIMUserInfo;

@interface TUIChatBotPluginUserController : UITableViewController

- (instancetype)initWithUserInfo:(V2TIMUserInfo *)userInfo;

@end

NS_ASSUME_NONNULL_END
