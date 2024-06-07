//
//  TUISystemMessageCellData.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/21.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUISystemMessageCellData.h"
#import <TIMCommon/TIMDefine.h>
#import "TUIRelationUserModel.h"


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
    __block BOOL forceRefresh = NO;
    [self.additionalUserInfoResult enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, TUIRelationUserModel * _Nonnull obj, BOOL * _Nonnull stop) {
      NSString *str = [NSString stringWithFormat:@"{%@}", key];
      NSString *showName = obj.userID;
      if (obj.nameCard.length > 0) {
          showName = obj.nameCard;
      } else if (obj.friendRemark.length > 0) {
          showName = obj.friendRemark;
      } else if (obj.nickName.length > 0) {
          showName = obj.nickName;
      }
      if ([self.content containsString:str]) {
        self.content = [self.content stringByReplacingOccurrencesOfString:str withString:showName];
        forceRefresh = YES;
      }
    }];
  
    if (forceRefresh || (_attributedString == nil && self.content.length > 0)) {
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

- (NSArray<NSString *> *)requestForAdditionalUserInfo {
  NSMutableArray *result = [NSMutableArray arrayWithArray:[super requestForAdditionalUserInfo]];
  
  if (self.replacedUserIDList) {
    [result addObjectsFromArray:self.replacedUserIDList];
  }
  return result;
}

@end
