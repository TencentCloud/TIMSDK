#import "TPush/TPush.h"
#import "UnityAppController.h"

@interface UnityAppController (ThirdPartyExtension) <TIMPushDelegate>
- (int)businessID;

- (NSString *)applicationGroupID;
@end

@implementation UnityAppController (ThirdPartyExtension)

#pragma mark - TIMPush
- (int)businessID {
  return 12345;
}

- (NSString *)applicationGroupID {
  return @"group.com.tencent.tuikit.demo.xa";
}
@end
