//
//  TUIReplyPreviewData.h
//  TUIChat
//
//  Created by wyl on 2022/3/22.
//

#import <Foundation/Foundation.h>

@class V2TIMMessage;

typedef void(^TUIInputPreviewBarCallback)(void);

@interface TUIReplyPreviewData : NSObject

// 被回复的原始消息 ID
@property (nonatomic, copy) NSString *msgID;
// 被回复的原始消息的摘要
@property (nonatomic, copy) NSString *msgAbstract;
// 被回复的原始消息的发送者(昵称>userId)
@property (nonatomic, copy) NSString *sender;
// 被回复的原始消息的类型(类型详见 V2TIMElemType 的枚举值)
@property (nonatomic, assign) NSInteger type;

// 被回复的源消息
@property (nonatomic, strong) V2TIMMessage *originMessage;

//消息回复根RootID 【不一定是上面originMessage的msgID ，是最顶上被回复的消息ID】
// Message reply root RootID (not necessarily the msgID of the originMessage above, but the ID of the message at the top)
@property (nonatomic, copy) NSString *messageRootID;

+ (NSString *)displayAbstract:(NSInteger)type abstract:(NSString *)abstract withFileName:(BOOL)withFilename;

@end

@interface TUIReferencePreviewData : TUIReplyPreviewData

@end
