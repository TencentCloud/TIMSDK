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
           reactEmoji:(NSString *)emojiName
 simpleCurrentContent:(NSDictionary *)simpleCurrentContent
          timeControl:(NSInteger)time;

@end
