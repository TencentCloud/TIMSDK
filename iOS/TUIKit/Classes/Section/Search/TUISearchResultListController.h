//
//  TUISearchResultListController.h
//  Pods
//
//  Created by harvy on 2020/12/25.
//

#import <UIKit/UIKit.h>
#import "TUISearchDataProvider.h"
@class TUISearchResultCellModel;

NS_ASSUME_NONNULL_BEGIN

@interface TUISearchResultListController : UIViewController

- (instancetype)initWithResults:(NSArray<TUISearchResultCellModel *> * __nullable)results
                        keyword:(NSString * __nullable)keyword
                         module:(TUISearchResultModule)module
                          param:(NSDictionary<TUISearchParamKey, id> * __nullable)param;

@end

NS_ASSUME_NONNULL_END
