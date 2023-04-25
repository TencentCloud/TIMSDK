//
//  ConversationController_Minimalist.h
//  TUIKitDemo
//
//  Created by wyl on 2022/10/12.
//  Copyright © 2022 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TUIConversationListController_Minimalist;

NS_ASSUME_NONNULL_BEGIN

typedef NSUInteger(^GetUnReadCount)(void);
typedef void(^ClearUnreadMessage)(void);

typedef NS_ENUM(NSInteger, UIBarButtonItemType) {
    UIBarButtonItemType_Edit,
    UIBarButtonItemType_More,
    UIBarButtonItemType_Done,
};

@interface ConversationController_Minimalist : UIViewController
@property(nonatomic, strong) TUIConversationListController_Minimalist *conv;
@property(nonatomic, strong) NSMutableArray<UIBarButtonItem *> *showLeftBarButtonItems;
@property(nonatomic, strong) NSArray<UIBarButtonItem *> *rightBarButtonItems;
@property(nonatomic, strong) NSMutableArray<UIBarButtonItem *> *showRightBarButtonItems;
@property(nonatomic, assign) CGFloat leftSpaceWidth;
@property(nonatomic, copy) GetUnReadCount getUnReadCount;
@property(nonatomic, copy) ClearUnreadMessage clearUnreadMessage;
@property(nonatomic, copy) void(^viewWillAppear)(BOOL isAppear);

- (void)pushToChatViewController:(NSString *)groupID userID:(NSString *)userID;

@end

NS_ASSUME_NONNULL_END
