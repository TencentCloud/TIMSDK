//
//  TUIVoiceMessageCellData.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/21.
//

#import "TUIMessageCellData.h"
#import "TUIBubbleMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIVoiceMessageCellData : TUIBubbleMessageCellData

@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, assign) int duration;
@property (nonatomic, assign) int length;
@property (nonatomic, assign) BOOL isDownloading;
@property (nonatomic, assign) BOOL isPlaying;
@property NSArray<UIImage *> *voiceAnimationImages;
@property UIImage *voiceImage;
@property (nonatomic, assign) CGFloat voiceTop;

@property (nonatomic, class) CGFloat incommingVoiceTop;
@property (nonatomic, class) CGFloat outgoingVoiceTop;

- (void)stopVoiceMessage;
- (void)playVoiceMessage;

@end

NS_ASSUME_NONNULL_END
