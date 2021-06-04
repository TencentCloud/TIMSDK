//
//  TUISearchDataProvider.h
//  Pods
//
//  Created by harvy on 2020/12/28.
//

#import <Foundation/Foundation.h>
#import "NSBundle+TUIKIT.h"
@class TUISearchResultCellModel;

NS_ASSUME_NONNULL_BEGIN

#ifndef __TUISearchDataProvider_H__
#define __TUISearchDataProvider_H__

#define kSearchChatHistoryConversationId   @"Id"
#define kSearchChatHistoryConverationInfo  @"conversation"
#define kSearchChatHistoryConversationMsgs @"msgs"

///////////////////////////////////////////////////////////////////// 新增模块 以及 模块配置信息 /////////////////////////////////////////////////////////////////

// 每个模块默认显示最多的个数，等于或超过之后显示「 查看更多*** 」
#define kMaxNumOfPerModule 3

// 枚举名称代表搜索的模块，枚举值代表模块之间的顺序
typedef NS_ENUM(NSInteger, TUISearchResultModule) {
    TUISearchResultModuleAll           = 1 << 0,        // 所有模块
    TUISearchResultModuleContact       = 1 << 1,        // 联系人模块
    TUISearchResultModuleGroup         = 1 << 2,        // 群聊模块
    TUISearchResultModuleChatHistory   = 1 << 3,        // 聊天记录,结果显示会话
};

// 搜索附加条件的 key
typedef NSString * TUISearchParamKey;
FOUNDATION_EXTERN TUISearchParamKey TUISearchChatHistoryParamKeyConversationId; // 以会话id作为条件搜索历史聊天记录
FOUNDATION_EXTERN TUISearchParamKey TUISearchChatHistoryParamKeyCount;          // 以个数作为条件搜索历史聊天记录
FOUNDATION_EXPORT TUISearchParamKey TUISearchChatHistoryParamKeyPage;           // 以页码作为条件搜索历史聊天记录
FOUNDATION_EXTERN NSUInteger TUISearchDefaultPageSize;                          // 搜索时分页的大小，默认是 20

// 模块对应的名称
static inline NSString *titleForModule(TUISearchResultModule module, BOOL isHeader)
{
    NSString *headerTitle = @"";
    NSString *footerTitle = @"";
    switch (module) {
        case TUISearchResultModuleContact:
            headerTitle = TUILocalizableString(TUIKitSearchItemHeaderTitleContact); // @"联系人";
            footerTitle = TUILocalizableString(TUIKitSearchItemFooterTitleContact); // @"查看更多联系人";
            break;
        case TUISearchResultModuleGroup:
            headerTitle = TUILocalizableString(TUIKitSearchItemHeaderTitleGroup); // @"群聊";
            footerTitle = TUILocalizableString(TUIKitSearchItemFooterTitleGroup); // @"查看更多群聊";
            break;
        case TUISearchResultModuleChatHistory:
            headerTitle = TUILocalizableString(TUIkitSearchItemHeaderTitleChatHistory); // @"聊天记录";
            footerTitle = TUILocalizableString(TUIKitSearchItemFooterTitleChatHistory); // @"查看更多聊天记录";
            break;
        default:
            break;
    }
    return isHeader ? headerTitle : footerTitle;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#endif

@protocol TUISearchResultDelegate <NSObject>

/**
 * 搜索成功后的回调
 * @param results 搜索完成后的结果集，也可以通过 TUISearchDataProvider 的 resultSet 属性来获取。属性的 key 以及 value 取值见 TUISearchDataProvider 的 @resultSet 属性
 * @param modules 当前搜索的模块，与调用 searchForKeyword:forModules: 方法时传入的 modules 一致
 */
- (void)onSearchResults:(NSDictionary<NSNumber *, NSArray<TUISearchResultCellModel *> *> *)results forModules:(TUISearchResultModule)modules;

/**
 * 搜索失败后的回调
 * @param errMsg 失败的描述
 */
- (void)onSearchError:(NSString *)errMsg;

@end

@interface TUISearchDataProvider : NSObject

@property (nonatomic, weak) id<TUISearchResultDelegate> delegate;

/**
 * 搜索后的数据源，字典形式
 * key : 模块类型的枚举值，例如 @(TUISearchResultModuleContact)，不支持 TUISearchResultModuleAll
 * value: 表示当前模块对应的TUISearchResultCellModel类型的数组
 */
@property (nonatomic, strong, readonly) NSMutableDictionary<NSNumber *, NSArray<TUISearchResultCellModel *> *> *resultSet;

/**
 * 按模块模糊搜索，搜索完成后回触发 TUISearchResultDelegate 回调
 * @param keyword 搜索的关键词
 * @param modules 搜索的模块，支持单模块搜索，组合搜索以及全模块搜索。
 * @param param 搜索条件, key 取值见 @TUISearchParamKey
 *
 * @note modules 的传值示例以及搜索结果集 resultSet 示例如下：
 * ① 单模块搜索，例如传入 TUISearchResultModuleContact, 则搜索联系人完成后回调 resultSet 中，通过@(TUISearchResultModuleContact)的 key 来获取对应的联系人列表
 * ② 组合搜索，例如传入 TUISearchResultModuleContact|TUISearchResultModuleGroup，TUIKit会搜索联系人以及群组，搜索完成之后，可以分别通过@(TUISearchResultModuleContact)和
 *   @(TUISearchResultModuleGroup)来获取对应的联系人和群组列表
 * ③ 全模块搜索，例如传入 TUISearchResultModuleAll，TUIKit 会搜索所有支持的模块，并返回所有结果。通过具体的枚举值来获取对应列表
 */
- (void)searchForKeyword:(NSString *)keyword forModules:(TUISearchResultModule)modules param:(NSDictionary<TUISearchParamKey, id> * __nullable)param;

+ (NSAttributedString *)attributeStringWithText:(NSString * __nullable)text key:(NSString * __nullable)key;
+ (NSString *)matchedTextForMessage:(V2TIMMessage *)msg withKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
