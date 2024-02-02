//
//  TUIReactUtil.h
//  Masonry
//
//  Created by cologne on 2023/12/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@import ImSDK_Plus;
static const long long TUIReactCommercialAbility = 1LL << 48;

@interface TUIReactUtil : NSObject
+ (void)checkCommercialAbility;
@end

NS_ASSUME_NONNULL_END
