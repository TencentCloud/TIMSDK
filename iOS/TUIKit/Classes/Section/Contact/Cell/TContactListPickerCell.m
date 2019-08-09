//
//  TContactListPickerCell.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/13.
//

#import "TContactListPickerCell.h"
#import "MMLayout/UIView+MMLayout.h"

#define AVATAR_WIDTH 35

@implementation TContactListPickerCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _avatar = [[UIImageView alloc] initWithFrame:CGRectZero];
        [self.contentView addSubview:_avatar];
        _avatar.mm_width(AVATAR_WIDTH).mm_height(AVATAR_WIDTH).mm_center();
        _avatar.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
    }
    return self;
}

@end
