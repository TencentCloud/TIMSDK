//
//  UIAlertController+TUICustomStyle.m
//  TUIChat
//
//  Created by wyl on 2022/10/20.
//

#import "UIAlertController+TUICustomStyle.h"
#import <objc/runtime.h>
#import "TUIDefine.h"

@implementation TUICustomActionSheetItem

- (instancetype)initWithTitle:(NSString *)title leftMark:(UIImage *)leftMark withActionHandler:(void (^)(UIAlertAction *action)) actionHandler {
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

- (void)configItems:(NSArray<TUICustomActionSheetItem *> *)Items{
    CGFloat alertVCWidth = self.view.frame.size.width - 2 * padding;

    if (Items.count > 0) {
        for (int i = 0; i< Items.count; i++) {
            UIView *ItemView =[[UIView alloc] init];
            ItemView.frame = CGRectMake(padding, (itemHeight+lineHeight)*i, alertVCWidth - 2 * padding, itemHeight);
            ItemView.userInteractionEnabled = NO;
            [self.view addSubview:ItemView];
            
            UIImageView *icon = [[UIImageView alloc] init];
            [ItemView addSubview:icon];
            icon.contentMode = UIViewContentModeScaleAspectFit;
            icon.frame = CGRectMake(kScale390(20), itemHeight *0.5 - kScale390(30) *0.5 , kScale390(30), kScale390(30));
            icon.image = Items[i].leftMark;
        
            UILabel *l = [[UILabel alloc] init];
            l.frame = CGRectMake( icon.frame.origin.x +icon.frame.size.width + padding + kScale390(15) , 0, alertVCWidth *0.5, itemHeight);
            l.text = Items[i].title;
            l.font = [UIFont systemFontOfSize:17];
            l.textAlignment = NSTextAlignmentLeft;
            l.textColor = [UIColor systemBlueColor];
            l.userInteractionEnabled = false;
            [ItemView addSubview:l];
        }
    }
    
    // actions
    if (Items.count > 0) {
        for (int i = 0; i< Items.count; i++) {
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"" style:Items[i].actionStyle handler: Items[i].actionHandler];
            [self addAction: action];
        }
    }
}

@end
