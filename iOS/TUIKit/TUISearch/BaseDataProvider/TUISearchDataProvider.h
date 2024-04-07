//
//  TUISearchDataProvider.h
//  Pods
//
//  Created by harvy on 2020/12/28.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TIMCommon/TIMDefine.h>
@class TUISearchResultCellModel;

NS_ASSUME_NONNULL_BEGIN

#ifndef __TUISearchDataProvider_H__
#define __TUISearchDataProvider_H__

#define kSearchChatHistoryConversationId @"Id"
#define kSearchChatHistoryConverationInfo @"conversation"
#define kSearchChatHistoryConversationMsgs @"msgs"

///////////////////////////////////////////////////////////////////// Configuration /////////////////////////////////////////////////////////////////

/**
 * The default maximum number of each module, if it is equal to or exceeds, it will display "View More***"
 */
#define kMaxNumOfPerModule 3

/**
 * The enumeration name represents the searched module, and the enumeration value represents the order between modules
 */
typedef NS_ENUM(NSInteger, TUISearchResultModule) {
    TUISearchResultModuleAll = 1 << 0,
    TUISearchResultModuleContact = 1 << 1,
    TUISearchResultModuleGroup = 1 << 2,
    TUISearchResultModuleChatHistory = 1 << 3,
};

typedef NSString *TUISearchParamKey;
FOUNDATION_EXTERN TUISearchParamKey TUISearchChatHistoryParamKeyConversationId;
FOUNDATION_EXTERN TUISearchParamKey TUISearchChatHistoryParamKeyCount;
FOUNDATION_EXPORT TUISearchParamKey TUISearchChatHistoryParamKeyPage;
FOUNDATION_EXTERN NSUInteger TUISearchDefaultPageSize;

static inline NSString *titleForModule(TUISearchResultModule module, BOOL isHeader) {
    NSString *headerTitle = @"";
    NSString *footerTitle = @"";
    switch (module) {
        case TUISearchResultModuleContact:
            headerTitle = TIMCommonLocalizableString(TUIKitSearchItemHeaderTitleContact);
            footerTitle = TIMCommonLocalizableString(TUIKitSearchItemFooterTitleContact);
            break;
        case TUISearchResultModuleGroup:
            headerTitle = TIMCommonLocalizableString(TUIKitSearchItemHeaderTitleGroup);
            footerTitle = TIMCommonLocalizableString(TUIKitSearchItemFooterTitleGroup);
            break;
        case TUISearchResultModuleChatHistory:
            headerTitle = TIMCommonLocalizableString(TUIkitSearchItemHeaderTitleChatHistory);
            footerTitle = TIMCommonLocalizableString(TUIKitSearchItemFooterTitleChatHistory);
            break;
        default:
            break;
    }
    return isHeader ? headerTitle : footerTitle;
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

#endif

@protocol TUISearchResultDelegate <NSObject>

- (void)onSearchResults:(NSDictionary<NSNumber *, NSArray<TUISearchResultCellModel *> *> *)results forModules:(TUISearchResultModule)modules;
- (void)onSearchError:(NSString *)errMsg;

@end

@interface TUISearchDataProvider : NSObject

@property(nonatomic, weak) id<TUISearchResultDelegate> delegate;

@property(nonatomic, strong, readonly) NSMutableDictionary<NSNumber *, NSArray<TUISearchResultCellModel *> *> *resultSet;

- (void)searchForKeyword:(NSString *)keyword forModules:(TUISearchResultModule)modules param:(NSDictionary<TUISearchParamKey, id> *__nullable)param;

+ (NSAttributedString *)attributeStringWithText:(NSString *__nullable)text key:(NSString *__nullable)key;
+ (NSString *)matchedTextForMessage:(V2TIMMessage *)msg withKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
