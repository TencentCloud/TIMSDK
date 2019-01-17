//
//  TVoiceMessageCell.m
//  UIKit
//
//  Created by kennethmiao on 2018/9/17.
//  Copyright © 2018年 kennethmiao. All rights reserved.
//

#import "TVoiceMessageCell.h"
#import "THeader.h"
#import "TUIKit.h"
#import "IMMessageExt.h"

@implementation TVoiceMessageCellData
- (void)downloadVoice:(TDownloadProgress)progress response:(TDownloadResponse)response
{
    if(_isDownloading){
        if(response){
            response(-1, @"downloading, please wait", nil);
        }
        return;
    }
    
    BOOL isExist = NO;
    NSString *path = [self getVoicePath:&isExist];
    if(isExist){
        if(response){
            response(0, nil, path);
        }
    }
    else{
        //网络下载
        TIMSoundElem *imSound = [self getIMSoundElem];
        _isDownloading = YES;
        __weak typeof(self) ws = self;
        [imSound getSound:path succ:^{
            ws.isDownloading = NO;
            if(response){
                dispatch_async(dispatch_get_main_queue(), ^{
                    response(0, nil, path);
                });
            }
        } fail:^(int code, NSString *msg) {
            ws.isDownloading= NO;
            if(response){
                dispatch_async(dispatch_get_main_queue(), ^{
                    response(code, msg, nil);
                });
            }
        }];
    }
}

- (NSString *)getVoicePath:(BOOL *)isExist
{
    NSString *path = nil;
    BOOL isDir = false;
    *isExist = NO;
    if(super.isSelf){
        //上传方本地是否有效
        path = [NSString stringWithFormat:@"%@%@", TUIKit_Voice_Path, _path.lastPathComponent];
        if([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]){
            if(!isDir){
                *isExist = YES;
            }
        }
    }
    
    if(!*isExist){
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

- (TIMSoundElem *)getIMSoundElem
{
    TIMMessage *imMsg = self.custom;
    for (int i = 0; i < imMsg.elemCount; ++i) {
        TIMElem *imElem = [imMsg getElem:i];
        if([imElem isKindOfClass:[TIMSoundElem class]]){
            TIMSoundElem *imSoundElem = (TIMSoundElem *)imElem;
            return imSoundElem;
        }
    }
    return nil;
}
@end

@implementation TVoiceMessageCell

- (CGSize)getContainerSize:(TVoiceMessageCellData *)data
{
    CGFloat bubbleWidth = [self getBubbleWidth:data];
    CGFloat width = bubbleWidth + TVoiceMessageCell_Duration_Size.width;
    return CGSizeMake(width, TVoiceMessageCell_Height);
}

- (void)setupViews
{
    [super setupViews];
    
    _bubble = [[UIImageView alloc] init];
    [super.container addSubview:_bubble];
    
    _voice = [[UIImageView alloc] init];
    _voice.animationDuration = 1;
    [super.container addSubview:_voice];
    
    _duration = [[UILabel alloc] init];
    _duration.font = [UIFont systemFontOfSize:12];
    _duration.textColor = [UIColor grayColor];
    _duration.textAlignment = NSTextAlignmentCenter;
    [super.container addSubview:_duration];
    
}

- (CGFloat)getBubbleWidth:(TVoiceMessageCellData *)data
{
    CGFloat bubbleWidth = TVoiceMessageCell_Back_Width_Min + data.duration / TVoiceMessageCell_Max_Duration * Screen_Width;
    if(bubbleWidth > TVoiceMessageCell_Back_Width_Max){
        bubbleWidth = TVoiceMessageCell_Back_Width_Max;
    }
    return bubbleWidth;
}

- (void)setData:(TVoiceMessageCellData *)data;
{
    //set data
    [super setData:data];
    _duration.text = [NSString stringWithFormat:@"%ld\"", (long)data.duration];
    //update layout
    CGFloat bubbleWidth = [self getBubbleWidth:data];
    CGSize durationSize = TVoiceMessageCell_Duration_Size;
    CGFloat voiceWH = super.container.frame.size.height - 2 * TVoiceMessageCell_Margin;
    if(data.isSelf){
        __weak typeof(self) ws = self;
        _bubble.frame = CGRectMake(super.container.frame.size.width - bubbleWidth, 0, super.container.frame.size.width - durationSize.width, super.container.frame.size.height);
        
        _bubble.image = [[[[TUIKit sharedInstance] getConfig] getResourceFromCache:TUIKitResource(@"sender_text_normal")]
                         resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{18,25,17,25}")
                         resizingMode:UIImageResizingModeStretch];
        _bubble.highlightedImage = [[[[TUIKit sharedInstance] getConfig] getResourceFromCache:TUIKitResource(@"sender_text_pressed")]
                                    resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{18,25,17,25}")
                                    resizingMode:UIImageResizingModeStretch];
        
        _voice.frame = CGRectMake(super.container.frame.size.width - TVoiceMessageCell_Margin - voiceWH, TVoiceMessageCell_Margin, voiceWH, voiceWH);
        _voice.image = [[[TUIKit sharedInstance] getConfig] getResourceFromCache:TUIKitResource(@"sender_voice")];
        _voice.animationImages = [NSArray arrayWithObjects:
                                  [[[TUIKit sharedInstance] getConfig] getResourceFromCache:TUIKitResource(@"sender_voice_play_1")],
                                  [[[TUIKit sharedInstance] getConfig] getResourceFromCache:TUIKitResource(@"sender_voice_play_2")],
                                  [[[TUIKit sharedInstance] getConfig] getResourceFromCache:TUIKitResource(@"sender_voice_play_3")], nil];

        _duration.frame = CGRectMake(0, (super.container.frame.size.height - durationSize.height) * 0.5, durationSize.width, durationSize.height);
    }
    else{
        __weak typeof(self) ws = self;
        _bubble.frame = CGRectMake(0, 0, bubbleWidth, super.container.frame.size.height);
        _bubble.image = [[[[TUIKit sharedInstance] getConfig] getResourceFromCache:TUIKitResource(@"receiver_text_normal")]
                         resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{18,25,17,25}")
                         resizingMode:UIImageResizingModeStretch];
        _bubble.highlightedImage = [[[[TUIKit sharedInstance] getConfig] getResourceFromCache:TUIKitResource(@"receiver_text_pressed")]
                                    resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{18,25,17,25}")
                                    resizingMode:UIImageResizingModeStretch];

        
        _voice.frame = CGRectMake(TVoiceMessageCell_Margin, TVoiceMessageCell_Margin, voiceWH, voiceWH);
        _voice.image = [[[TUIKit sharedInstance] getConfig] getResourceFromCache:TUIKitResource(@"receiver_voice")];
        _voice.animationImages = [NSArray arrayWithObjects:
                                  [[[TUIKit sharedInstance] getConfig] getResourceFromCache:TUIKitResource(@"receiver_voice_play_1")],
                                  [[[TUIKit sharedInstance] getConfig] getResourceFromCache:TUIKitResource(@"receiver_voice_play_2")],
                                  [[[TUIKit sharedInstance] getConfig] getResourceFromCache:TUIKitResource(@"receiver_voice_play_3")], nil];
        
        _duration.frame = CGRectMake(_bubble.frame.origin.x + _bubble.frame.size.width, (super.container.frame.size.height - durationSize.height) * 0.5, durationSize.width, durationSize.height);
    }
    
    //animate
    if(data.isPlaying){
        [_voice startAnimating];
    }
    else{
        [_voice stopAnimating];
    }
}
@end
