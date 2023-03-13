//
//  TUIGroupNoteTipsCellData.m
//  TUIChat
//
//  Created by xia on 2023/2/20.
//

#import "TUIGroupNoteTipsCellData.h"

@implementation TUIGroupNoteTipsCellData

+ (TUIGroupNoteTipsCellData *)getCellData:(V2TIMMessage *)message {
    NSDictionary *param = [NSJSONSerialization JSONObjectWithData:message.customElem.data
                                                          options:NSJSONReadingAllowFragments error:nil];
    if (param == nil) {
        return nil;
    }
    
    TUIGroupNoteTipsCellData *tipsData = [[TUIGroupNoteTipsCellData alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
    NSString *prefix = [NSString stringWithFormat:TUIKitLocalizableString(TUIGroupNoteTipsMessagePrefix), [TUIGroupNoteTipsCellData displayedNameOfInfo:message]];
    NSString *title = [NSString stringWithFormat:@" [%@]", param[@"title"]];
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:prefix];
    NSDictionary *attributeDict = @{NSForegroundColorAttributeName:[UIColor d_systemGrayColor]};
    [attrStr setAttributes:attributeDict range:NSMakeRange(0, attrStr.length)];
    
    [attrStr appendAttributedString:[[NSAttributedString alloc] initWithString:title]];
    attributeDict = @{NSForegroundColorAttributeName:[UIColor d_systemBlueColor]};
    [attrStr setAttributes:attributeDict range:NSMakeRange(prefix.length, title.length)];
    
    tipsData.attributedString = attrStr;
    return tipsData;
}

+ (NSString *)getDisplayString:(V2TIMMessage *)message {
    return TUIKitLocalizableString(TUIGroupNoteDisplayString);
}

+ (NSString *)displayedNameOfInfo:(V2TIMMessage *)message {
  if (message.nickName.length > 0) {
        return message.nickName;
    } else {
        return message.sender;
    }
}

@end
