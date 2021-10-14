//
//  TUILiveReport.h
//  Pods
//
//  Created by harvy on 2020/9/24.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUILiveReportController : NSObject

/// 举报用户
/// @param userId 用户id
- (void)reportUser:(NSString *)userId;

@end

NS_ASSUME_NONNULL_END
