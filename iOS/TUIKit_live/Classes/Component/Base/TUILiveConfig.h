//
//  TUILiveConfig.h
//  TXIMSDK_TUIKit_live_iOS
//
//  Created by coddyliu on 2020/9/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUILiveConfig : NSObject
/// 【字段含义】观众端使用CDN播放
/// 【特殊说明】true: 默认进房使用CDN播放 false: 使用低延时播放
@property (nonatomic, assign) BOOL useCDNFirst;
/// 【字段含义】CDN播放的域名地址
@property(nonatomic, strong, nullable) NSString *cdnPlayDomain;

@end



NS_ASSUME_NONNULL_END
