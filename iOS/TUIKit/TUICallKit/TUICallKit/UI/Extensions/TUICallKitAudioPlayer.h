//
//  TUICallKitAudioPlayer.h
//  TUICalling
//
//  Created by gg on 2021/9/2.
//  Copyright © 2021 Tencent. All rights reserved
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    CallingAudioTypeHangup,
    CallingAudioTypeCalled,
    CallingAudioTypeDial,
} CallingAudioType;

extern BOOL playAudioWithFilePath(NSString *filePath);

extern void playAudio(CallingAudioType type);

extern void stopAudio(void);
