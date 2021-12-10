//
//  TUIInputPreviewBar.h
//  TUIChat
//
//  Created by harvy on 2021/11/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

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

+ (NSString *)displayAbstract:(NSInteger)type abstract:(NSString *)abstract withFileName:(BOOL)withFilename;

@end

@interface TUIReplyPreviewBar : UIView

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, copy) TUIInputPreviewBarCallback onClose;

@property (nonatomic, strong) TUIReplyPreviewData *previewData;

@end

NS_ASSUME_NONNULL_END
