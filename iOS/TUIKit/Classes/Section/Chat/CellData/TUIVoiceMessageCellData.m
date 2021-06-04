//
//  TUIVoiceMessageCellData.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/21.
//

#import "TUIVoiceMessageCellData.h"
#import "TUIKit.h"
#import "ReactiveObjC/ReactiveObjC.h"
@import AVFoundation;

@interface TUIVoiceMessageCellData ()<AVAudioPlayerDelegate>
@property AVAudioPlayer *audioPlayer;
@property NSString *wavPath;
@end

@implementation TUIVoiceMessageCellData

- (instancetype)initWithDirection:(TMsgDirection)direction
{
    self = [super initWithDirection:direction];
    if (self) {
        if (direction == MsgDirectionIncoming) {
            self.cellLayout = [TUIMessageCellLayout incommingVoiceMessageLayout];
            _voiceImage = [[TUIImageCache sharedInstance] getResourceFromCache:TUIKitResource(@"message_voice_receiver_normal")];
            _voiceAnimationImages = [NSArray arrayWithObjects:
                                      [[TUIImageCache sharedInstance] getResourceFromCache:TUIKitResource(@"message_voice_receiver_playing_1")],
                                      [[TUIImageCache sharedInstance] getResourceFromCache:TUIKitResource(@"message_voice_receiver_playing_2")],
                                      [[TUIImageCache sharedInstance] getResourceFromCache:TUIKitResource(@"message_voice_receiver_playing_3")], nil];
            _voiceTop = [[self class] incommingVoiceTop];
        } else {
            self.cellLayout = [TUIMessageCellLayout outgoingVoiceMessageLayout];
            _voiceImage = [[TUIImageCache sharedInstance] getResourceFromCache:TUIKitResource(@"message_voice_sender_normal")];
            _voiceAnimationImages = [NSArray arrayWithObjects:
                                      [[TUIImageCache sharedInstance] getResourceFromCache:TUIKitResource(@"message_voice_sender_playing_1")],
                                      [[TUIImageCache sharedInstance] getResourceFromCache:TUIKitResource(@"message_voice_sender_playing_2")],
                                      [[TUIImageCache sharedInstance] getResourceFromCache:TUIKitResource(@"message_voice_sender_playing_3")], nil];
            _voiceTop = [[self class] outgoingVoiceTop];
        }
    }

    return self;
}

- (NSString *)getVoicePath:(BOOL *)isExist
{
    NSString *path = nil;
    BOOL isDir = false;
    *isExist = NO;
    if(self.direction == MsgDirectionOutgoing) {
        //上传方本地是否有效
        path = [NSString stringWithFormat:@"%@%@", TUIKit_Voice_Path, _path.lastPathComponent];
        if([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]){
            if(!isDir){
                *isExist = YES;
            }
        }
    }

    if(!*isExist) {
        //查看本地是否存在
        path = [NSString stringWithFormat:@"%@%@.amr", TUIKit_Voice_Path, _uuid];
        if([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]){
            if(!isDir){
                *isExist = YES;
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
    CGFloat bubbleWidth = TVoiceMessageCell_Back_Width_Min + self.duration / TVoiceMessageCell_Max_Duration * Screen_Width;
    if(bubbleWidth > TVoiceMessageCell_Back_Width_Max){
        bubbleWidth = TVoiceMessageCell_Back_Width_Max;
    }

    CGFloat bubbleHeight = TVoiceMessageCell_Duration_Size.height;
    if (self.direction == MsgDirectionIncoming) {
        bubbleWidth = MAX(bubbleWidth, [TUIBubbleMessageCellData incommingBubble].size.width);
        bubbleHeight = [TUIBubbleMessageCellData incommingBubble].size.height;
    } else {
        bubbleWidth = MAX(bubbleWidth, [TUIBubbleMessageCellData outgoingBubble].size.width);
        bubbleHeight = [TUIBubbleMessageCellData outgoingBubble].size.height;
    }
    return CGSizeMake(bubbleWidth+TVoiceMessageCell_Duration_Size.width, bubbleHeight);
//    CGFloat width = bubbleWidth + TVoiceMessageCell_Duration_Size.width;
//    return CGSizeMake(width, TVoiceMessageCell_Duration_Size.height);
}

- (void)playVoiceMessage
{
    if (self.isPlaying) {
        return;
    }
    self.isPlaying = YES;
    
    if(self.innerMessage.localCustomInt == 0)
        self.innerMessage.localCustomInt = 1;

    BOOL isExist = NO;
    NSString *path = [self getVoicePath:&isExist];
    if(isExist) {
        [self playInternal:path];
    } else {
        if(self.isDownloading) {
            return;
        }
        //网络下载
        V2TIMSoundElem *imSound = [self getIMSoundElem];
        self.isDownloading = YES;
        @weakify(self)
        [imSound downloadSound:path progress:^(NSInteger curSize, NSInteger totalSize) {
            // 下载进度
        }  succ:^{
            @strongify(self)
            self.isDownloading = NO;
            [self playInternal:path];;
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
        [THelper convertAmr:path toWav:self.wavPath];
        NSURL *url = [NSURL fileURLWithPath:self.wavPath];
        [self.audioPlayer stop];
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        self.audioPlayer.delegate = self;
        [self.audioPlayer play];
    }
}

- (void)stopVoiceMessage
{
    if ([self.audioPlayer isPlaying]) {
        [self.audioPlayer stop];
        self.audioPlayer = nil;
    }
    self.isPlaying = NO;
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag;
{
    self.isPlaying = NO;
    [[NSFileManager defaultManager] removeItemAtPath:self.wavPath error:nil];
}

static CGFloat s_incommingVoiceTop = 12;

+ (void)setIncommingVoiceTop:(CGFloat)incommingVoiceTop
{
    s_incommingVoiceTop = incommingVoiceTop;
}

+ (CGFloat)incommingVoiceTop
{
    return s_incommingVoiceTop;
}

static CGFloat s_outgoingVoiceTop = 12;

+ (void)setOutgoingVoiceTop:(CGFloat)outgoingVoiceTop
{
    s_outgoingVoiceTop = outgoingVoiceTop;
}

+ (CGFloat)outgoingVoiceTop
{
    return s_outgoingVoiceTop;
}

@end
