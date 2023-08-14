//
//  TUIOrderCell_Minimalist.m
//  TUIChat
//
//  Created by xia on 2022/6/13.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIOrderCell_Minimalist.h"
#import <TUICore/TUIGlobalization.h>
#import <TUICore/TUIThemeManager.h>

@implementation TUIOrderCell_Minimalist

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont boldSystemFontOfSize:12];
        _titleLabel.textColor = TUIChatDynamicColor(@"chat_text_message_receive_text_color", @"#000000");
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.container addSubview:_titleLabel];

        _descLabel = [[UILabel alloc] init];
        _descLabel.font = [UIFont systemFontOfSize:12];
        _descLabel.numberOfLines = 1;
        _descLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _descLabel.textColor = TUIChatDynamicColor(@"chat_custom_order_message_desc_color", @"#999999");
        [self.container addSubview:_descLabel];

        _priceLabel = [[UILabel alloc] init];
        _priceLabel.font = [UIFont boldSystemFontOfSize:18];
        _priceLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _priceLabel.textColor = TUIChatDynamicColor(@"chat_custom_order_message_price_color", @"#FF7201");
        [self.container addSubview:_priceLabel];

        _iconView = [[UIImageView alloc] init];
        _iconView.layer.cornerRadius = 8.0;
        _iconView.layer.masksToBounds = YES;
        [self.container addSubview:_iconView];
    }
    return self;
}

- (void)fillWithData:(TUIOrderCellData *)data {
    [super fillWithData:data];

    self.customData = data;
    self.titleLabel.text = data.title;
    self.descLabel.text = data.desc;
    self.priceLabel.text = data.price;
    if (data.imageUrl == nil) {
        [self.iconView setImage:TUIChatBundleThemeImage(@"chat_custom_order_message_img", @"message_custom_order")];
    } else {
        [self.iconView setImage:[UIImage sd_imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:data.imageUrl]]]];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];

    self.iconView.mm_top(10).mm_left(12).mm_width(60).mm_height(60);
    self.titleLabel.mm_top(10).mm_left(80).mm_width(150).mm_height(17);
    self.descLabel.mm_top(30).mm_left(80).mm_width(150).mm_height(17);
    self.priceLabel.mm_top(49).mm_left(80).mm_width(150).mm_height(25);
}

#pragma mark - TUIMessageCellProtocol
+ (CGSize)getContentSize:(TUIMessageCellData *)data {
    return CGSizeMake(245, 80);
}

@end
