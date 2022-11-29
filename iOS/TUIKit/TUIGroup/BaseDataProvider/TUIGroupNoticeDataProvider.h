//
//  TUIGroupNoticeDataProvider.h
//  TUIGroup
//
//  Created by harvy on 2022/1/12.
//

#import <Foundation/Foundation.h>
#import <ImSDK_Plus/ImSDK_Plus.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIGroupNoticeDataProvider : NSObject

@property (nonatomic, strong, readonly) V2TIMGroupInfo *groupInfo;
@property (nonatomic, copy) NSString *groupID;

- (void)getGroupInfo:(dispatch_block_t)callback;
- (BOOL)canEditNotice;
- (void)updateNotice:(NSString *)notice callback:(void(^)(int, NSString *))callback;

@end

NS_ASSUME_NONNULL_END
