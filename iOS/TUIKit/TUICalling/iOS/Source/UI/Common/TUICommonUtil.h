//
//  TUICommonUtil.h
//  TUICalling
//
//  Created by noah on 2021/8/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUICommonUtil : NSObject

+ (NSBundle *)callingBundle;

+ (UIImage *)getBundleImageWithName:(NSString *)name;

+ (UIWindow *)getRootWindow;

/// 获取topViewController
+ (UIViewController *)getTopViewController;

/// 检查字典数据是否合法
/// @param data 传入参数
+ (BOOL)checkDictionaryValid:(id)data;

/// 检查数组是否合法
/// @param data 传入参数
+ (BOOL)checkArrayValid:(id)data;

/// 获取对应索引的数据
/// @param index 索引值
/// @param dataArray 数组
+ (id)fetchModelWithIndex:(NSInteger)index
                dataArray:(NSArray *)dataArray;

/// 获取对应数据的索引
/// @param model 数据
/// @param dataArray 数组
+ (NSInteger)fetchIndexWithModel:(id)model
                       dataArray:(NSArray *)dataArray;

/// 检查索引是否在合法范围内
/// @param index 索引值
/// @param dataArray 数组
+ (BOOL)checkIndexInRangeWith:(NSInteger)index
                    dataArray:(NSArray *)dataArray;

/// 根据字体，计算文本宽度
/// @param text 文本
/// @param font 字体
+ (CGFloat)calculateTextWidth:(NSString *)text
                         font:(UIFont *)font;

/// 根据字体、指定宽度，计算字符串size
/// @param text 文本
/// @param font 字体
/// @param targetWidth 指定宽度
+ (CGSize)calculateTextSize:(NSString *)text
                       font:(UIFont *)font
                targetWidth:(CGFloat)targetWidth;

@end

NS_ASSUME_NONNULL_END
