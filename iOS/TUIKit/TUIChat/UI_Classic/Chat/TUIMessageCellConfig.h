//  Created by Tencent on 2023/07/20.
//  Copyright © 2023 Tencent. All rights reserved.

#import <UIKit/UIKit.h>

@class TUIMessageCellData;

typedef NSString * TUICellDataClassName;
typedef NSString * TUICellClassName;
typedef NSString * TUIBusinessID;

NS_ASSUME_NONNULL_BEGIN

@interface TUIMessageCellConfig : NSObject
/**
 * 1.
 *   Bind the message tableView, and TUIMessageCellConfig will perform built-in and customized cell bindings for the tableView internally.
 */
- (void)bindTableView:(UITableView *)tableView;

/**
 * 2.
 *   Bind cell and cellData to the tableView, and the binding can be called externally.
 */
- (void)bindMessageCellClass:(Class)cellClass cellDataClass:(Class)cellDataClass reuseID:(NSString *)reuseID;

@end


@interface TUIMessageCellConfig (MessageCellWidth)
+ (void)setMaxTextSize:(CGSize)maxTextSz;
@end

@interface TUIMessageCellConfig (MessageCellHeight)

/**
 * Get key of cache
 */
- (NSString *)getHeightCacheKey:(TUIMessageCellData *)msg;

/**
 * Get the height, and the cache will be queried first.
 *
 */
- (CGFloat)getHeightFromMessageCellData:(TUIMessageCellData *)cellData;

/**
 * Get the estimated height, and the cache will be queried first.
 */
- (CGFloat)getEstimatedHeightFromMessageCellData:(TUIMessageCellData *)cellData;

/**
 * Remove cache
 */
- (void)removeHeightCacheOfMessageCellData:(TUIMessageCellData *)cellData;

@end


@interface TUIMessageCellConfig (CustomMessageRegister)

/**
 * Register custom message
 *
 * @param messageCellName  cell 
 * @param messageCellDataName  cellData 
 * @param businessID 
 */
+ (void)registerCustomMessageCell:(TUICellClassName)messageCellName
                  messageCellData:(TUICellDataClassName)messageCellDataName
                    forBusinessID:(TUIBusinessID)businessID;

/**
 * Register custom message （This is for internal use of TUIKit plugin, please use registerCustomMessageCell:messageCellData:forBusinessID: instead.）
 *
 * @param messageCellName          (custom message cell name)
 * @param messageCellDataName  (custom message cell data)
 * @param businessID   (custom message businessID)
 * @param isPlugin   (From Plugin)
 */
+ (void)registerCustomMessageCell:(TUICellClassName)messageCellName
                  messageCellData:(TUICellDataClassName)messageCellDataName
                    forBusinessID:(TUIBusinessID)businessID
                         isPlugin:(BOOL)isPlugin;

/**
 * Get all custom message UI with enumeration
 */
+ (void)enumerateCustomMessageInfo:(void(^)(NSString *messageCellName,
                                            NSString *messageCellDataName,
                                            NSString *businessID,
                                            BOOL isPlugin))callback;

/**
 * Get the class of custom message cellData based on businessID
 */
+ (nullable Class)getCustomMessageCellDataClass:(NSString *)businessID;

/**
 * Whether the custom message cell data is defined in plugin
 */
+ (BOOL)isPluginCustomMessageCellData:(TUIMessageCellData *)data;

@end

NS_ASSUME_NONNULL_END
