//
//  TUICallingAudioPlayer.h
//  TUICalling
//
//  Created by gg on 2021/9/2.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    CallingAudioTypeHangup,     // 挂断
    CallingAudioTypeCalled,     // 被动呼叫
    CallingAudioTypeDial,       // 主动呼叫
} CallingAudioType;

extern BOOL playAudioWithFilePath(NSString *filePath);

extern BOOL playAudio(CallingAudioType type);

extern void stopAudio(void);
