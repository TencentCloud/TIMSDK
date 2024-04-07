//
//  TUISystemMessageCellData.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/21.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUISystemMessageCellData.h"
#import <TIMCommon/TIMDefine.h>


@implementation TUISystemMessageCellData

- (instancetype)initWithDirection:(TMsgDirection)direction {
    self = [super initWithDirection:direction];
    if (self) {
        self.showAvatar = NO;
        _contentFont = [UIFont systemFontOfSize:13];
        _contentColor = [UIColor d_systemGrayColor];
        self.cellLayout = [TUIMessageCellLayout systemMessageLayout];
    }
    return self;
}

- (NSMutableAttributedString *)attributedString {
    if (_attributedString == nil && self.content.length > 0) {
        NSMutableAttributedString *attributeString = [[NSMutableAttributedString alloc] initWithString:self.content];
        NSDictionary *attributeDict = @{NSForegroundColorAttributeName : [UIColor d_systemGrayColor]};
        [attributeString setAttributes:attributeDict range:NSMakeRange(0, attributeString.length)];
        if (self.supportReEdit) {
            NSString *reEditStr = TIMCommonLocalizableString(TUIKitMessageTipsReEditMessage);
            [attributeString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@", reEditStr]]];
            NSDictionary *attributeDict = @{NSForegroundColorAttributeName : [UIColor d_systemBlueColor]};
            [attributeString setAttributes:attributeDict range:NSMakeRange(self.content.length + 1, reEditStr.length)];
            [attributeString addAttribute:NSUnderlineStyleAttributeName
                                    value:[NSNumber numberWithInteger:NSUnderlineStyleNone]
                                    range:NSMakeRange(self.content.length + 1, reEditStr.length)];
        }
        _attributedString = attributeString;
    }
    return _attributedString;
}

@end
