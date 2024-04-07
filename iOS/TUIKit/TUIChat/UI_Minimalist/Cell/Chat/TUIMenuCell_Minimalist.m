//
//  InputMenuCell.m
//  UIKit
//
//  Created by kennethmiao on 2018/9/20.
//  Copyright © 2018 Tencent. All rights reserved.
//

#import "TUIMenuCell_Minimalist.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/TUIThemeManager.h>

@implementation TUIMenuCell_Minimalist
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupViews];
        [self defaultLayout];
    }
    return self;
}

- (void)setupViews {
    self.backgroundColor = TUIChatDynamicColor(@"chat_controller_bg_color", @"#EBF0F6");
    _menu = [[UIImageView alloc] init];
    _menu.backgroundColor = [UIColor clearColor];
    [self addSubview:_menu];
}

- (void)defaultLayout {
}

- (void)setData:(TUIMenuCellData *)data {
    // set data
    _menu.image = [[TUIImageCache sharedInstance] getFaceFromCache:data.path];
    if (data.isSelected) {
        self.backgroundColor = TUIChatDynamicColor(@"chat_face_menu_select_color", @"#FFFFFF");
    } else {
        self.backgroundColor = TUIChatDynamicColor(@"chat_input_controller_bg_color", @"#EBF0F6");
    }
    // update layout
    CGSize size = self.frame.size;
    _menu.frame = CGRectMake(TMenuCell_Margin, TMenuCell_Margin, size.width - 2 * TMenuCell_Margin, size.height - 2 * TMenuCell_Margin);
    _menu.contentMode = UIViewContentModeScaleAspectFit;
}
@end
