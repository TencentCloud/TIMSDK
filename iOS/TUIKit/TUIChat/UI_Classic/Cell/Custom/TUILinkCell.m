//
//  MyCustomCell.m
//  TUIKitDemo
//
//  Created by annidyfeng on 2019/6/10.
//  Copyright © 2019 Tencent. All rights reserved.
//

#import "TUILinkCell.h"
#import <TUICore/TUIGlobalization.h>
#import <TUICore/TUIThemeManager.h>

@implementation TUILinkCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _myTextLabel = [[UILabel alloc] init];
        _myTextLabel.numberOfLines = 0;
        _myTextLabel.font = [UIFont systemFontOfSize:15];
        _myTextLabel.textAlignment = isRTL()?NSTextAlignmentRight:NSTextAlignmentLeft;
        _myTextLabel.textColor = TUIChatDynamicColor(@"chat_link_message_title_color", @"#000000");
        [self.container addSubview:_myTextLabel];

        _myLinkLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _myLinkLabel.text = TIMCommonLocalizableString(TUIKitMoreLinkDetails);
        _myLinkLabel.font = [UIFont systemFontOfSize:15];
        _myLinkLabel.textAlignment = isRTL()?NSTextAlignmentRight:NSTextAlignmentLeft;
        _myLinkLabel.textColor = TUIChatDynamicColor(@"chat_link_message_subtitle_color", @"#0000FF");
        [self.container addSubview:_myLinkLabel];
    }
    return self;
}

- (void)fillWithData:(TUILinkCellData *)data;
{
    [super fillWithData:data];
    self.customData = data;
    self.myTextLabel.text = data.text;
    
    // tell constraints they need updating
    [self setNeedsUpdateConstraints];

    // update constraints now so we can animate the change
    [self updateConstraintsIfNeeded];

    [self layoutIfNeeded];
}


+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

// this is Apple's recommended place for adding/updating constraints
- (void)updateConstraints {
     
    [super updateConstraints];
    CGRect rect = [self.myTextLabel.text boundingRectWithSize:CGSizeMake(245, MAXFLOAT)
                                                      options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                   attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]}
                                                      context:nil];
    [self.myTextLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(10);
        make.leading.mas_equalTo(10);
        make.width.mas_equalTo(245);
        make.height.mas_equalTo(rect.size.height);
    }];
    [self.myLinkLabel sizeToFit];
    [self.myLinkLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.myTextLabel.mas_bottom).mas_offset(15);
        make.leading.mas_equalTo(10);
        make.width.mas_equalTo(self.myLinkLabel.frame.size.width);
        make.height.mas_equalTo(self.myLinkLabel.frame.size.height);
    }];
}
- (void)layoutSubviews {
    [super layoutSubviews];
}

#pragma mark - TUIMessageCellProtocol
+ (CGSize)getContentSize:(TUIMessageCellData *)data {
    NSAssert([data isKindOfClass:TUILinkCellData.class], @"data must be kind of TUILinkCellData");
    TUILinkCellData *linkCellData = (TUILinkCellData *)data;
    
    CGFloat textMaxWidth = 245.f;
    CGRect rect = [linkCellData.text boundingRectWithSize:CGSizeMake(textMaxWidth, MAXFLOAT)
                                                  options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                               attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:15]}
                                                  context:nil];
    CGSize size = CGSizeMake(textMaxWidth + 15, rect.size.height + 56);
    return size;
}

@end
