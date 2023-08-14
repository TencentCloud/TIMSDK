//  Created by Tencent on 2023/07/20.
//  Copyright © 2023 Tencent. All rights reserved.

#import <UIKit/UIKit.h>

@class TUIMessageCellData;

typedef NSString * TUICellDataClassName;
typedef NSString * TUICellClassName;
typedef NSString * TUIBusinessID;

NS_ASSUME_NONNULL_BEGIN

@interface TUIMessageCellConfig_Minimalist : NSObject
/**
 * 1. 绑定消息 tableView，TUIMessageCellConfig 内部会对 tableView 做内置 cell 及自定义 cell 的绑定操作
 *   Bind the message tableView, and TUIMessageCellConfig will perform built-in and customized cell bindings for the tableView internally.
 */
- (void)bindTableView:(UITableView *)tableView;

/**
 * 2. 给 tableView 绑定 cell 和 cellData，外部可调用绑定
 *   Bind cell and cellData to the tableView, and the binding can be called externally.
 */
- (void)bindMessageCellClass:(Class)cellClass cellDataClass:(Class)cellDataClass reuseID:(NSString *)reuseID;

@end


@interface TUIMessageCellConfig_Minimalist (MessageCellHeight)

/**
 * 获取缓存的 key
 * Get key of cache
 */
- (NSString *)getHeightCacheKey:(TUIMessageCellData *)msg;

/**
 * 获取高度，内部会查询缓存
 * Get the height, and the cache will be queried first.
 *
 */
- (CGFloat)getHeightFromMessageCellData:(TUIMessageCellData *)cellData;

/**
 * 获取预估高度，内部会查询缓存
 * Get the estimated height, and the cache will be queried first.
 */
- (CGFloat)getEstimatedHeightFromMessageCellData:(TUIMessageCellData *)cellData;

/**
 * 移除缓存
 * Remove cache
 */
- (void)removeHeightCacheOfMessageCellData:(TUIMessageCellData *)cellData;

@end


@interface TUIMessageCellConfig_Minimalist (CustomMessageRegister)

/**
 * 注册自定义消息
 * Register custom message
 *
 * @param messageCellName 消息 cell 类的名称
 * @param messageCellDataName 消息 cellData 类的名称
 * @param businessID 业务标识
 */
+ (void)registerCustomMessageCell:(TUICellClassName)messageCellName
                  messageCellData:(TUICellDataClassName)messageCellDataName
                    forBusinessID:(TUIBusinessID)businessID;

/**
 * 注册自定义消息 （TUIKit 插件内部使用， 请您使用 registerCustomMessageCell:messageCellData:forBusinessID: 代替）
 * Register custom message （This is for internal use of TUIKit plugin, please use registerCustomMessageCell:messageCellData:forBusinessID: instead.）
 *
 * @param messageCellName 消息 cell 类的名称
 * @param messageCellDataName 消息 cellData 类的名称
 * @param businessID 业务标识
 * @param isPlugin 是否插件消息（投票、接龙、快速会议等），仅供 TUIKit 内部使用
 */
+ (void)registerCustomMessageCell:(TUICellClassName)messageCellName
                  messageCellData:(TUICellDataClassName)messageCellDataName
                    forBusinessID:(TUIBusinessID)businessID
                         isPlugin:(BOOL)isPlugin;

/**
 * 枚举遍历获取注册的自定义消息的 UI 信息
 * Get all custom message UI with enumeration
 */
+ (void)enumerateCustomMessageInfo:(void(^)(NSString *messageCellName,
                                            NSString *messageCellDataName,
                                            NSString *businessID,
                                            BOOL isPlugin))callback;

/**
 * 根据 businessID 获取自定义消息 cellData 的类
 * Get the class of custom message cellData based on businessID
 */
+ (nullable Class)getCustomMessageCellDataClass:(NSString *)businessID;

/**
 * 是否为插件中定义的自定义消息
 * Whether the custom message cell data is defined in plugin
 */
+ (BOOL)isPluginCustomMessageCellData:(TUIMessageCellData *)data;

@end

NS_ASSUME_NONNULL_END
