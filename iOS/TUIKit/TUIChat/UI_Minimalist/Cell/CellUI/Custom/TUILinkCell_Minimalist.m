//
//  TUILinkCell_Minimalist.m
//  TUIKitDemo
//
//  Created by annidyfeng on 2019/6/10.
//  Copyright © 2019年 Tencent. All rights reserved.
//
/** 腾讯云IM Demo自定义气泡视图
 *  用于显示聊天气泡中的文本信息数据
 *
 */
#import "TUILinkCell_Minimalist.h"
#import <TUICore/TUIGlobalization.h>
#import <TUICore/TUIThemeManager.h>

@implementation TUILinkCell_Minimalist

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _myTextLabel = [[UILabel alloc] init];
        _myTextLabel.numberOfLines = 0;
        _myTextLabel.font = [UIFont systemFontOfSize:15];
        _myTextLabel.textColor = TUIChatDynamicColor(@"chat_link_message_title_color", @"#000000");
        [self.container addSubview:_myTextLabel];

        _myLinkLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _myLinkLabel.text = TIMCommonLocalizableString(TUIKitMoreLinkDetails);
        _myLinkLabel.font = [UIFont systemFontOfSize:15];
        _myLinkLabel.textColor = TUIChatDynamicColor(@"chat_link_message_subtitle_color", @"#0000FF");
        [self.container addSubview:_myLinkLabel];
    }
    return self;
}

- (void)fillWithData:(TUILinkCellData_Minimalist *)data;
{
    [super fillWithData:data];
    self.customData = data;
    self.myTextLabel.text = data.text;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    CGRect rect = [self.myTextLabel.text boundingRectWithSize:CGSizeMake(245, MAXFLOAT)
                                                      options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                   attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]}
                                                      context:nil];
    self.myTextLabel.mm_top(10).mm_left(10).mm_width(245).mm_height(rect.size.height);
    self.myLinkLabel.mm_sizeToFit().mm_left(10).mm_top(self.myTextLabel.mm_y + self.myTextLabel.mm_h + 15);
}

@end
