//
//  TUILiveHitTestView.m
//  Pods
//
//  Created by harvy on 2020/9/18.
//

#import "TUILiveHitTestView.h"

@implementation TUILiveHitTestView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    id hitView = [super hitTest:point withEvent:event];
    if (hitView == self) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(hitTest:withEvent:view:)]) {
            [self.delegate hitTest:point withEvent:event view:self];
        }
        return nil;
    } else {
        return hitView;
    }
}


@end
