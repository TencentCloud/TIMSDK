//
//  TUIVoiceMessageCellData_Minimalist.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/21.
//

#import "TUIVoiceMessageCellData_Minimalist.h"
#import "TUIMessageCellLayout.h"
#import "EMVoiceConverter.h"
#import "TUIThemeManager.h"
#import "TUIDefine.h"
@import AVFoundation;

@interface TUIVoiceMessageCellData_Minimalist ()<AVAudioPlayerDelegate>
@property AVAudioPlayer *audioPlayer;
@property NSString *wavPath;
@property(nonatomic,strong)NSTimer *timer;
@end

@implementation TUIVoiceMessageCellData_Minimalist

+ (TUIMessageCellData *)getCellData:(V2TIMMessage *)message {
    V2TIMSoundElem *elem = message.soundElem;
    TUIVoiceMessageCellData_Minimalist *soundData = [[TUIVoiceMessageCellData_Minimalist alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
    soundData.duration = elem.duration;
    soundData.length = elem.dataSize;
    soundData.uuid = elem.uuid;
    soundData.reuseId = TVoiceMessageCell_ReuseId;
    soundData.path = elem.path;
    return soundData;
}

+ (NSString *)getDisplayString:(V2TIMMessage *)message {
    return TUIKitLocalizableString(TUIKitMessageTypeVoice); // @"[语音]";
}

- (Class)getReplyQuoteViewDataClass
{
    return NSClassFromString(@"TUIVoiceReplyQuoteViewData_Minimalist");
}

- (Class)getReplyQuoteViewClass
{
    return NSClassFromString(@"TUIVoiceReplyQuoteView_Minimalist");
}

- (instancetype)initWithDirection:(TMsgDirection)direction
{
    self = [super initWithDirection:direction];
    if (self) {
        if (direction == MsgDirectionIncoming) {
            self.cellLayout = [TUIMessageCellLayout incommingVoiceMessageLayout];
            _voiceTop = [[self class] incommingVoiceTop];
        } else {
            self.cellLayout = [TUIMessageCellLayout outgoingVoiceMessageLayout];
            _voiceTop = [[self class] outgoingVoiceTop];
        }
        _voiceHeight = 21;
    }

    return self;
}

- (NSString *)getVoicePath:(BOOL *)isExist
{
    NSString *path = nil;
    BOOL isDir = false;
    *isExist = NO;
    if(self.direction == MsgDirectionOutgoing) {
        if (_path.length) {
            path = [NSString stringWithFormat:@"%@%@", TUIKit_Voice_Path, _path.lastPathComponent];
            if([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]){
                if(!isDir){
                    *isExist = YES;
                }
            }
        }
    }

    if(!*isExist) {
        if (_uuid.length) {
            path = [NSString stringWithFormat:@"%@%@.amr", TUIKit_Voice_Path, _uuid];
            if([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]){
                if(!isDir){
                    *isExist = YES;
                }
            }
        }
    }
    return path;
}

- (V2TIMSoundElem *)getIMSoundElem
{
    V2TIMMessage *imMsg = self.innerMessage;
    if (imMsg.elemType == V2TIM_ELEM_TYPE_SOUND) {
        return imMsg.soundElem;
    }
    return nil;
}

- (CGSize)contentSize
{
    return CGSizeMake((self.voiceHeight + kScale390(5)) * 6 + kScale390(82), _voiceHeight + self.voiceTop * 3 + self.msgStatusSize.height);
}

- (void)playVoiceMessage
{
    if (self.isPlaying) {
        [self stopVoiceMessage];
        return;
    }
    self.isPlaying = YES;
    
    if(self.innerMessage.localCustomInt == 0)
        self.innerMessage.localCustomInt = 1;

    V2TIMSoundElem *imSound = [self getIMSoundElem];
    BOOL isExist = NO;
    if (self.uuid.length == 0) {
        self.uuid = imSound.uuid;
    }
    NSString *path = [self getVoicePath:&isExist];
    if(isExist) {
        [self playInternal:path];
    } else {
        if(self.isDownloading) {
            return;
        }
        //网络下载
        self.isDownloading = YES;
        @weakify(self)
        [imSound downloadSound:path progress:^(NSInteger curSize, NSInteger totalSize) {
            
        }  succ:^{
            @strongify(self)
            self.isDownloading = NO;
            [self playInternal:path];
        } fail:^(int code, NSString *msg) {
            @strongify(self)
            self.isDownloading= NO;
            [self stopVoiceMessage];
        }];
    }
}

- (void)playInternal:(NSString *)path
{
    if (!self.isPlaying)
        return;
    //play current
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    NSURL *url = [NSURL fileURLWithPath:path];
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    self.audioPlayer.delegate = self;
    bool result = [self.audioPlayer play];
    if (!result) {
        self.wavPath = [[path stringByDeletingPathExtension] stringByAppendingString:@".wav"];
        [EMVoiceConverter amrToWav:path wavSavePath:self.wavPath];
        NSURL *url = [NSURL fileURLWithPath:self.wavPath];
        [self.audioPlayer stop];
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        self.audioPlayer.delegate = self;
        [self.audioPlayer play];
    }
    
   @weakify(self)
   if (@available(iOS 10.0, *)) {
       self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
           @strongify(self)
           [self updateProgress];
       }];
   } else {
       // Fallback on earlier versions
   }
}

- (void)updateProgress {
    @weakify(self)
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self)
        if (self.playTime) {
            self.playTime(self.audioPlayer.currentTime);
        }
    });
}

- (void)stopVoiceMessage
{
    if ([self.audioPlayer isPlaying]) {
        [self.audioPlayer stop];
        self.audioPlayer = nil;
    }
    if (self.timer ) {
        [self.timer invalidate];
        self.timer = nil;
    }
    self.isPlaying = NO;
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag;
{
    [self stopVoiceMessage];
    [[NSFileManager defaultManager] removeItemAtPath:self.wavPath error:nil];
}


static CGFloat s_incommingVoiceTop = 8;

+ (void)setIncommingVoiceTop:(CGFloat)incommingVoiceTop
{
    s_incommingVoiceTop = incommingVoiceTop;
}

+ (CGFloat)incommingVoiceTop
{
    return s_incommingVoiceTop;
}

static CGFloat s_outgoingVoiceTop = 8;

+ (void)setOutgoingVoiceTop:(CGFloat)outgoingVoiceTop
{
    s_outgoingVoiceTop = outgoingVoiceTop;
}

+ (CGFloat)outgoingVoiceTop
{
    return s_outgoingVoiceTop;
}

@end
