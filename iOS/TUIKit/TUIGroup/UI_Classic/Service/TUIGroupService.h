
#import <Foundation/Foundation.h>
#import <TUICore/TUICore.h>
#import <TIMCommon/TIMCommonModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIGroupService : NSObject <TUIServiceProtocol>

+ (TUIGroupService *)shareInstance;

@end

NS_ASSUME_NONNULL_END
