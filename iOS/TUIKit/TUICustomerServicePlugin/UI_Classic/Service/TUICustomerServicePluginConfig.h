//
//  TUICustomerServicePluginConfig.h
//  TUICustomerServicePlugin
//
//  Created by xia on 2023/6/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class TUICustomerServicePluginConfig;
@class TUICustomerServicePluginMenuCellData;
@class TUICustomerServicePluginProductInfo;

@protocol TUICustomerServicePluginConfigDataSource <NSObject>

@optional
/**
 * 自定义修改浮层菜单的数据源。请在进入客服会话聊天界面前实现。
 * Customize or modify the data source of the floating menu. Please implement this method before entering the customer service conversation chat page.
 */
- (NSArray<TUICustomerServicePluginMenuCellData *> *)pluginConfig:(TUICustomerServicePluginConfig *)config shouldUpdateOldMenuItems:(NSArray *)oldItems;

/**
 * 自定义常用语。请在进入客服会话聊天界面前实现。
 * Customize or modify the common phrases. Please implement this method before entering the customer service conversation chat page.
 */
- (NSArray<NSString *> *)pluginConfig:(TUICustomerServicePluginConfig *)config shouldUpdateCommonPhrases:(NSArray *)oldItems;

/**
 * 自定义商品信息。请在进入客服会话聊天界面前实现。
 * Customize or modify the product infomation. Please implement this method before entering the customer service conversation chat page.
 */
- (TUICustomerServicePluginProductInfo *)pluginConfigShouldUpdateProductInfo:(TUICustomerServicePluginConfig *)config;

@end


@interface TUICustomerServicePluginConfig : NSObject

+ (TUICustomerServicePluginConfig *)sharedInstance;

@property (nonatomic, weak) id<TUICustomerServicePluginConfigDataSource> delegate;

/**
 * Set up customer service account list
 */
@property (nonatomic, copy) NSArray *customerServiceAccounts;

/**
 * 客服插件在消息列表底部的菜单浮层的数据源。
 * The data source of the customer service plugin in the floating layer of the menu at the bottom of the message list.
 */
@property (nonatomic, copy, readonly) NSArray *menuItems;

/**
 * 常用语
 * The common phrases.
 */
@property (nonatomic, copy, readonly) NSArray *commonPhrases;

/**
 * 商品信息
 * The product info.
 */
@property (nonatomic, copy, readonly) TUICustomerServicePluginProductInfo *productInfo;

@end

NS_ASSUME_NONNULL_END
