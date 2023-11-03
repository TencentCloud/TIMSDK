//
//  TUIVideoMessageCellData.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/21.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIVideoMessageCellData.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/NSString+TUIUtil.h>
#import <TUICore/TUILogin.h>

#define TVideo_Block_Progress @"TVideo_Block_Progress";
#define TVideo_Block_Response @"TVideo_Block_Response";

@interface TUIVideoMessageCellData ()
@property(nonatomic, strong) NSString *videoUrl;
@property(nonatomic, assign) BOOL isDownloadingSnapshot;
@property(nonatomic, assign) BOOL isDownloadingVideo;
@property(nonatomic, copy) TUIVideoMessageDownloadCallback onFinish;
@end

@implementation TUIVideoMessageCellData

+ (TUIMessageCellData *)getCellData:(V2TIMMessage *)message {
    V2TIMVideoElem *elem = message.videoElem;
    TUIVideoMessageCellData *videoData = [[TUIVideoMessageCellData alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
    videoData.videoPath = [elem.videoPath safePathString];
    videoData.snapshotPath = [elem.snapshotPath safePathString];

    videoData.videoItem = [[TUIVideoItem alloc] init];
    videoData.videoItem.uuid = elem.videoUUID;
    videoData.videoItem.type = elem.videoType;
    videoData.videoItem.length = elem.videoSize;
    videoData.videoItem.duration = elem.duration;

    videoData.snapshotItem = [[TUISnapshotItem alloc] init];
    videoData.snapshotItem.uuid = elem.snapshotUUID;
    //    videoData.snapshotItem.type = elem.snaps;
    videoData.snapshotItem.length = elem.snapshotSize;
    videoData.snapshotItem.size = CGSizeMake(elem.snapshotWidth, elem.snapshotHeight);
    videoData.reuseId = TVideoMessageCell_ReuseId;
    return videoData;
}

+ (TUIMessageCellData *)placeholderCellDataWithSnapshotUrl:(NSString *)snapshotUrl thubImage:(UIImage *)thubImage {
    TUIVideoMessageCellData *videoData = [[TUIVideoMessageCellData alloc] initWithDirection:(MsgDirectionOutgoing)];
    videoData.thumbImage = thubImage;
    videoData.snapshotPath = [snapshotUrl safePathString];
    videoData.videoItem = [[TUIVideoItem alloc] init];
    videoData.snapshotItem = [[TUISnapshotItem alloc] init];
    videoData.snapshotItem.size = CGSizeEqualToSize(thubImage.size, CGSizeZero) ? CGSizeMake(kScale375(100), kScale375(100)) : thubImage.size;
    videoData.reuseId = TVideoMessageCell_ReuseId;
    videoData.avatarUrl = [NSURL URLWithString:[TUILogin getFaceUrl]];
    videoData.isPlaceHolderCellData = YES;
    return videoData;
}

+ (NSString *)getDisplayString:(V2TIMMessage *)message {
    return TIMCommonLocalizableString(TUIkitMessageTypeVideo);
}

- (Class)getReplyQuoteViewDataClass {
    return NSClassFromString(@"TUIVideoReplyQuoteViewData");
}

- (Class)getReplyQuoteViewClass {
    return NSClassFromString(@"TUIVideoReplyQuoteView");
}

- (instancetype)initWithDirection:(TMsgDirection)direction {
    self = [super initWithDirection:direction];
    if (self) {
        _uploadProgress = 100;
        _isDownloadingVideo = NO;
        _isDownloadingSnapshot = NO;
        if (direction == MsgDirectionIncoming) {
            self.cellLayout = [TUIMessageCellLayout incommingVideoMessageLayout];
        } else {
            self.cellLayout = [TUIMessageCellLayout outgoingVideoMessageLayout];
        }
    }
    return self;
}

- (void)downloadThumb:(TUIVideoMessageDownloadCallback)finish {
    self.onFinish = finish;
    [self downloadThumb];
}

- (void)downloadThumb {
    BOOL isExist = NO;
    NSString *path = [self getSnapshotPath:&isExist];
    if (isExist) {
        [self decodeThumb];
        return;
    }

    if (self.isDownloadingSnapshot) {
        return;
    }
    self.isDownloadingSnapshot = YES;

    @weakify(self);
    V2TIMMessage *imMsg = self.innerMessage;
    if (imMsg.elemType == V2TIM_ELEM_TYPE_VIDEO) {
        // Avoid large files that slow down callback progress.
        [self updateThumbProgress:1];
        [imMsg.videoElem downloadSnapshot:path
            progress:^(NSInteger curSize, NSInteger totalSize) {
              [self updateThumbProgress:MAX(1, curSize * 100 / totalSize)];
            }
            succ:^{
              @strongify(self);
              self.isDownloadingSnapshot = NO;
              [self updateThumbProgress:100];
              [self decodeThumb];
            }
            fail:^(int code, NSString *msg) {
              @strongify(self);
              self.isDownloadingSnapshot = NO;
            }];
    }
}

- (void)updateThumbProgress:(NSUInteger)progress {
    dispatch_async(dispatch_get_main_queue(), ^{
      self.thumbProgress = progress;
    });
}

- (void)decodeThumb {
    BOOL isExist = NO;
    NSString *path = [self getSnapshotPath:&isExist];
    if (!isExist) {
        return;
    }
    @weakify(self);
    [TUITool asyncDecodeImage:path
                     complete:^(NSString *path, UIImage *image) {
                       @strongify(self);
                       @weakify(self);
                       dispatch_async(dispatch_get_main_queue(), ^{
                         @strongify(self);
                         self.thumbImage = image;
                         self.thumbProgress = 100;
                         if (self.onFinish) {
                             self.onFinish();
                         }
                       });
                     }];
}

- (void)downloadVideo {
    BOOL isExist = NO;
    NSString *path = [self getVideoPath:&isExist];
    if (isExist) {
        return;
    }

    if (self.isDownloadingVideo) {
        return;
    }
    self.isDownloadingVideo = YES;

    @weakify(self);
    V2TIMMessage *imMsg = self.innerMessage;
    if (imMsg.elemType == V2TIM_ELEM_TYPE_VIDEO) {
        [imMsg.videoElem downloadVideo:path
            progress:^(NSInteger curSize, NSInteger totalSize) {
              @strongify(self);
              [self updateVideoProgress:curSize * 100 / totalSize];
            }
            succ:^{
              @strongify(self);
              self.isDownloadingVideo = NO;
              [self updateVideoProgress:100];
              dispatch_async(dispatch_get_main_queue(), ^{
                self.videoPath = path;
              });
            }
            fail:^(int code, NSString *msg) {
              @strongify(self);
              self.isDownloadingVideo = NO;
            }];
    }
}

- (void)updateVideoProgress:(NSUInteger)progress {
    dispatch_async(dispatch_get_main_queue(), ^{
      self.videoProgress = progress;
    });
}

- (void)getVideoUrl:(void (^)(NSString *url))urlCallBack {
    if (!urlCallBack) {
        return;
    }
    if (self.videoUrl) {
        urlCallBack(self.videoUrl);
    }
    @weakify(self);
    V2TIMMessage *imMsg = self.innerMessage;
    if (imMsg.elemType == V2TIM_ELEM_TYPE_VIDEO) {
        [imMsg.videoElem getVideoUrl:^(NSString *url) {
          @strongify(self);
          self.videoUrl = url;
          urlCallBack(self.videoUrl);
        }];
    }
}

- (BOOL)isVideoExist {
    BOOL isExist;
    [self getVideoPath:&isExist];
    return isExist;
}

- (NSString *)getVideoPath:(BOOL *)isExist {
    NSString *path = nil;
    BOOL isDir = NO;
    *isExist = NO;
    if (_videoPath && _videoPath.lastPathComponent.length) {
        path = [NSString stringWithFormat:@"%@%@", TUIKit_Video_Path, _videoPath.lastPathComponent];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]) {
            if (!isDir) {
                *isExist = YES;
            }
        }
    }

    if (!*isExist) {
        if (_videoItem) {
            if (_videoItem.uuid && _videoItem.uuid.length && _videoItem.type && _videoItem.type.length) {
                path = [NSString stringWithFormat:@"%@%@.%@", TUIKit_Video_Path, _videoItem.uuid, _videoItem.type];
                if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]) {
                    if (!isDir) {
                        *isExist = YES;
                    }
                }
            }
        }
    }
    if (*isExist) {
        _videoPath = path;
    }

    return path;
}

- (NSString *)getSnapshotPath:(BOOL *)isExist {
    NSString *path = nil;
    BOOL isDir = NO;
    *isExist = NO;
    if (_snapshotPath && _snapshotPath.length) {
        path = [NSString stringWithFormat:@"%@%@", TUIKit_Video_Path, _snapshotPath.lastPathComponent];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]) {
            if (!isDir) {
                *isExist = YES;
            }
        }
    }

    if (!*isExist) {
        if (_snapshotItem) {
            if (_snapshotItem.uuid && _snapshotItem.uuid.length) {
                path = [NSString stringWithFormat:@"%@%@", TUIKit_Video_Path, _snapshotItem.uuid];
                path = [TUIKit_Video_Path stringByAppendingString:_snapshotItem.uuid];
                if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]) {
                    if (!isDir) {
                        *isExist = YES;
                    }
                }
            }
        }
    }

    return path;
}

@end
