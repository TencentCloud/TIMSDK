//
//  TUIGroupNoteContainerCell.m
//  TUIChat
//
//  Created by xia on 2023/1/5.
//

#import "TUIGroupNoteContainerCell.h"

@interface TUIGroupNoteContainerCell()

@property (nonatomic, strong) UIView *customView;

@end

@implementation TUIGroupNoteContainerCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)fillWithData:(TUIGroupNoteContainerCellData *)data {
    [super fillWithData:data];
    self.customData = data;
    
    if ([data.businessID isEqualToString:@"group_note"])  {
        self.customView = nil;
        for (UIViewController *vc in self.mm_viewController.childViewControllers) {
            if ([vc isKindOfClass:NSClassFromString(@"TUIGroupNotePreviewViewController")]
                && [self.container.subviews containsObject:vc.view]) {
                [vc willMoveToParentViewController:self.mm_viewController];
                [vc.view removeFromSuperview];
                [vc removeFromParentViewController];
                break;
            }
        }
        UIViewController *vc = self.customData.childViewController;
        if (vc) {
            self.customView = vc.view;
            [self.mm_viewController addChildViewController:vc];
            [self.container addSubview:self.customView];
            [vc didMoveToParentViewController:self.mm_viewController];
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];

    if (self.customView) {
        self.customView
            .mm_top(0)
            .mm_left(0)
            .mm_height(self.customData.cachedSize.height)
            .mm_width(self.customData.cachedSize.width);
    }
}

@end
