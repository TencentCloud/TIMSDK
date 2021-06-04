//
//  TUISelectedUserCollectionViewCell.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by xiangzhang on 2020/7/6.
//

#import "TUIVideoCallUserCell.h"
#import "THeader.h"
#import "SDWebImage/UIImageView+WebCache.h"

@implementation TUIVideoCallUserCell

- (void)fillWithData:(CallUserModel *)model renderView:(TUIVideoRenderView *)renderView {
    BOOL noModel = (model.userId.length == 0);
    if (!noModel) {
        if (![model.userId isEqualToString:[TUICallUtils loginUser]]) {
            if (renderView) {
                if (![renderView.superview isEqual:self]) {
                    [renderView removeFromSuperview];
                    renderView.frame = self.bounds;
                    [self addSubview:renderView];
                    renderView.userModel = model;
                }
            } else {
                NSLog(@"renderView error");
            }
        }
    }
}

@end
