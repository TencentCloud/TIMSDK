//
//  MyCustomCell.m
//  TUIKitDemo
//
//  Created by annidyfeng on 2019/6/10.
//  Copyright © 2019年 Tencent. All rights reserved.
//
/** 腾讯云IM Demo自定义气泡视图
 *  用于显示聊天气泡中的文本信息数据
 *
 */
#import "TUILinkCell.h"
#import "TUIGlobalization.h"
#import "TUIThemeManager.h"

@implementation TUILinkCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onThemeChanged) name:TUIDidApplyingThemeChangedNotfication object:nil];

        self.container.backgroundColor = TUIChatDynamicColor(@"chat_link_message_bg_color", @"#FFFFFF");
        
        _myTextLabel = [[UILabel alloc] init];
        _myTextLabel.numberOfLines = 0;
        _myTextLabel.font = [UIFont systemFontOfSize:15];
        _myTextLabel.textColor = TUIChatDynamicColor(@"chat_link_message_title_color", @"#888888");
        [self.container addSubview:_myTextLabel];

        _myLinkLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _myLinkLabel.text = TUIKitLocalizableString(TUIKitMoreLinkDetails); // @"查看详情>>";
        _myLinkLabel.font = [UIFont systemFontOfSize:15];
        _myLinkLabel.textColor = TUIChatDynamicColor(@"chat_link_message_subtitle_color", @"#0000FF");
        [self.container addSubview:_myLinkLabel];

        [self.container.layer setMasksToBounds:YES];
        [self.container.layer setBorderColor:TUICoreDynamicColor(@"separator_color", @"#DBDBDB").CGColor];
        [self.container.layer setBorderWidth:1];
        [self.container.layer setCornerRadius:5];
    }
    return self;
}

- (void)fillWithData:(TUILinkCellData *)data;
{
    [super fillWithData:data];
    self.customData = data;
    self.myTextLabel.text = data.text;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.myTextLabel.mm_top(10).mm_left(10).mm_flexToRight(10).mm_flexToBottom(50);
    self.myLinkLabel.mm_sizeToFit().mm_left(10).mm_bottom(10);
}

//MARK: ThemeChanged
- (void)applyBorderTheme {
    if (self.container) {
        [self.container.layer setBorderColor:TUICoreDynamicColor(@"separator_color", @"#DBDBDB").CGColor];
    }
}

- (void)onThemeChanged {
    [self applyBorderTheme];
}

@end
