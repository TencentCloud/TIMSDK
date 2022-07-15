//
//  TUIChatModifyMessageHelper.h
//  TUIChat
//
//  Created by wyl on 2022/6/13.
//

#import <Foundation/Foundation.h>
@import ImSDK_Plus;

@interface TUIChatModifyMessageHelper : NSObject

+ (TUIChatModifyMessageHelper *)defaultHelper;


- (void)modifyMessage:(V2TIMMessage *)msg
           reactEmoji:(NSString *)emojiName;

- (void)modifyMessage:(V2TIMMessage *)msg
 simpleCurrentContent:(NSDictionary *)simpleCurrentContent;

- (void)modifyMessage:(V2TIMMessage *)msg
          revokeMsgID:(NSString *)revokeMsgID;

@end
