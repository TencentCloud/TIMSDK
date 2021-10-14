//
//  UIASViewController+MASAdditions.m
//  Masonry
//
//  Created by Craig Siemens on 2015-06-23.
//
//

#import "ASViewController+MASAdditions.h"

#ifdef ASMAS_VIEW_CONTROLLER

@implementation ASMAS_VIEW_CONTROLLER (ASMASAdditions)

- (ASMASViewAttribute *)mas_topLayoutGuide {
    return [[ASMASViewAttribute alloc] initWithView:self.view item:self.topLayoutGuide layoutAttribute:NSLayoutAttributeBottom];
}
- (ASMASViewAttribute *)mas_topLayoutGuideTop {
    return [[ASMASViewAttribute alloc] initWithView:self.view item:self.topLayoutGuide layoutAttribute:NSLayoutAttributeTop];
}
- (ASMASViewAttribute *)mas_topLayoutGuideBottom {
    return [[ASMASViewAttribute alloc] initWithView:self.view item:self.topLayoutGuide layoutAttribute:NSLayoutAttributeBottom];
}

- (ASMASViewAttribute *)mas_bottomLayoutGuide {
    return [[ASMASViewAttribute alloc] initWithView:self.view item:self.bottomLayoutGuide layoutAttribute:NSLayoutAttributeTop];
}
- (ASMASViewAttribute *)mas_bottomLayoutGuideTop {
    return [[ASMASViewAttribute alloc] initWithView:self.view item:self.bottomLayoutGuide layoutAttribute:NSLayoutAttributeTop];
}
- (ASMASViewAttribute *)mas_bottomLayoutGuideBottom {
    return [[ASMASViewAttribute alloc] initWithView:self.view item:self.bottomLayoutGuide layoutAttribute:NSLayoutAttributeBottom];
}



@end

#endif
