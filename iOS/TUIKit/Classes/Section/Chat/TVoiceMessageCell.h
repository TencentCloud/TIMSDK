//
//  TVoiceMessageCell.h
//  UIKit
//
//  Created by kennethmiao on 2018/9/17.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TMessageCell.h"

@interface TVoiceMessageCellData : TMessageCellData
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, assign) int duration;
@property (nonatomic, assign) int length;
@property (nonatomic, assign) BOOL isDownloading;
@property (nonatomic, assign) BOOL isPlaying;
- (void)downloadVoice:(TDownloadProgress)progress response:(TDownloadResponse)response;
- (NSString *)getVoicePath:(BOOL *)isExist;
@end

@interface TVoiceMessageCell : TMessageCell
@property (nonatomic, strong) UIImageView *voice;
@property (nonatomic, strong) UIImageView *bubble;
@property (nonatomic, strong) UILabel *duration;
@end
