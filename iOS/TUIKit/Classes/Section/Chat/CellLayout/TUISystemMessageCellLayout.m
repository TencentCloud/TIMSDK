#import "TUISystemMessageCellLayout.h"

@implementation TUISystemMessageCellLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.messageInsets = (UIEdgeInsets){.top = 5, .bottom = 5};
    }
    return self;
}

@end
