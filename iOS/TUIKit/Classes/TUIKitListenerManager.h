//
//  TUIKitListenerManager.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2021/5/17.
//

#import <Foundation/Foundation.h>
#import "TUIChatController.h"
#import "TUIConversationListController.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIKitListenerManager : NSObject
/**
 *  获取 TUIKitListenerManager 管理器实例
 */
+ (instancetype)sharedInstance;

/**
 *  添加会话列表界面监听
 */
- (void)addConversationListControllerListener:(id<TUIConversationListControllerListener>)listener;

/**
 *  移除会话列表界面监听
 */
- (void)removeConversationListControllerListener:(id<TUIConversationListControllerListener>)listener;

/**
 *  添加聊天界面监听
 */
- (void)addChatControllerListener:(id<TUIChatControllerListener>)listener;

/**
 *  移除聊天界面监听
 */
- (void)removeChatControllerListener:(id<TUIChatControllerListener>)listener;

@property (nonatomic, readonly) NSHashTable<id<TUIConversationListControllerListener>>* convListeners;
@property (nonatomic, readonly) NSHashTable<id<TUIChatControllerListener>> *chatListeners;
@end

NS_ASSUME_NONNULL_END
