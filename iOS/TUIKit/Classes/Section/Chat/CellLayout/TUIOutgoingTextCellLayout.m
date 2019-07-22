#import "TUIOutgoingTextCellLayout.h"

@implementation TUIOutgoingTextCellLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.bubbleInsets = (UIEdgeInsets){.top = 14, .bottom = 16, .left = 16, .right = 16};
    }
    return self;
}

@end
