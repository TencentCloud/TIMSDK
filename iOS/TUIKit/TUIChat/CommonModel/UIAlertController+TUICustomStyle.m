//
//  UIAlertController+TUICustomStyle.m
//  TUIChat
//
//  Created by wyl on 2022/10/20.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <TIMCommon/TIMDefine.h>
#import <objc/runtime.h>
#import "UIAlertController+TUICustomStyle.h"

@implementation TUICustomActionSheetItem

- (instancetype)initWithTitle:(NSString *)title leftMark:(UIImage *)leftMark withActionHandler:(void (^)(UIAlertAction *action))actionHandler {
    self = [super init];
    if (self) {
        _title = title;
        _leftMark = leftMark;
        _actionHandler = actionHandler;
    }
    return self;
}
@end

CGFloat padding = 10;
CGFloat itemHeight = 57;
CGFloat lineHeight = 0.5;
CGFloat itemCount = 2;

@interface UIAlertController ()

@end

@implementation UIAlertController (TUICustomStyle)

- (void)configItems:(NSArray<TUICustomActionSheetItem *> *)items {
    CGFloat alertVCWidth = self.view.frame.size.width - 2 * padding;

    if (items.count > 0) {
        for (int i = 0; i < items.count; i++) {
            UIView *itemView = [[UIView alloc] init];
            itemView.frame = CGRectMake(padding, (itemHeight + lineHeight) * i, alertVCWidth - 2 * padding, itemHeight);
            itemView.userInteractionEnabled = NO;
            [self.view addSubview:itemView];

            UIImageView *icon = [[UIImageView alloc] init];
            [itemView addSubview:icon];
            icon.contentMode = UIViewContentModeScaleAspectFit;
            icon.frame = CGRectMake(kScale390(20), itemHeight * 0.5 - kScale390(30) * 0.5, kScale390(30), kScale390(30));
            icon.image = items[i].leftMark;

            UILabel *l = [[UILabel alloc] init];
            l.frame = CGRectMake(icon.frame.origin.x + icon.frame.size.width + padding + kScale390(15), 0, alertVCWidth * 0.5, itemHeight);
            l.text = items[i].title;
            l.font = [UIFont systemFontOfSize:17];
            l.textAlignment = isRTL()? NSTextAlignmentRight:NSTextAlignmentLeft;
            l.textColor = [UIColor systemBlueColor];
            l.userInteractionEnabled = false;
            [itemView addSubview:l];
            
            if (isRTL()) {
                [icon resetFrameToFitRTL];
                [l resetFrameToFitRTL];
            }
        }
    }

    // actions
    if (items.count > 0) {
        for (int i = 0; i < items.count; i++) {
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"" style:items[i].actionStyle handler:items[i].actionHandler];
            [self addAction:action];
        }
    }
}

@end
