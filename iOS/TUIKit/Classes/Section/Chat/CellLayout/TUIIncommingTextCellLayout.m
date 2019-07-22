#import "TUIIncommingTextCellLayout.h"

@implementation TUIIncommingTextCellLayout

- (instancetype)init
{
    self = [super init];
    if (self) {

        self.bubbleInsets = (UIEdgeInsets){.top = 14, .bottom = 16, .left = 16, .right = 16};
    }
    return self;
}

@end
