//
//  TUISearchResultListController.h
//  Pods
//
//  Created by harvy on 2020/12/25.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TUISearchDataProvider.h"
@class TUISearchResultCellModel;

NS_ASSUME_NONNULL_BEGIN

@interface TUISearchResultListController_Minimalist : UIViewController

- (instancetype)initWithResults:(NSArray<TUISearchResultCellModel *> *__nullable)results
                        keyword:(NSString *__nullable)keyword
                         module:(TUISearchResultModule)module
                          param:(NSDictionary<TUISearchParamKey, id> *__nullable)param;

@property(nonatomic, copy) NSString *headerConversationShowName;
@property(nonatomic, copy) NSString *headerConversationURL;
@property(nonatomic, strong) UIImage *headerConversationAvatar;
@end

NS_ASSUME_NONNULL_END
