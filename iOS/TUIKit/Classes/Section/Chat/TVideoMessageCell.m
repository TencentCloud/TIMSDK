//
//  TVideoMessageCell.m
//  UIKit
//
//  Created by kennethmiao on 2018/10/9.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TVideoMessageCell.h"
#import "THeader.h"
#import "THelper.h"
#import "TUIKit.h"
@import ImSDK;

@implementation TVideoItem
@end

@implementation TSnapshotItem
@end

#define TVideo_Block_Progress @"TVideo_Block_Progress";
#define TVideo_Block_Response @"TVideo_Block_Response";

@interface TVideoMessageCellData ()
@property (nonatomic, assign) BOOL isDownloadingSnapshot;
@property (nonatomic, assign) BOOL isDownloadingVideo;
@property (nonatomic, strong) NSMutableArray *snapshotProgressBlocks;
@property (nonatomic, strong) NSMutableArray *snapshotResponseBlocks;
@property (nonatomic, strong) NSMutableArray *videoProgressBlocks;
@property (nonatomic, strong) NSMutableArray *videoResponseBlocks;
@end

@implementation TVideoMessageCellData
- (id)init
{
    self = [super init];
    if(self){
        _uploadProgress = 100;
        _isDownloadingVideo = NO;
        _isDownloadingSnapshot = NO;
        _snapshotProgressBlocks = [NSMutableArray array];
        _snapshotResponseBlocks = [NSMutableArray array];
        _videoProgressBlocks = [NSMutableArray array];
        _videoResponseBlocks = [NSMutableArray array];
    }
    return self;
}

- (void)downloadSnapshot:(TDownloadProgress)progress response:(TDownloadResponse)response
{
    
    BOOL isExist = NO;
    NSString *path = [self getSnapshotPath:&isExist];
    if(isExist){
        if(response){
            response(0, nil, path);
        }
        return;
    }
    else{
        
        if(progress){
            [_snapshotProgressBlocks addObject:progress];
        }
        if(response){
            [_snapshotResponseBlocks addObject:response];
        }
        
        if(_isDownloadingSnapshot){
            return;
        }
        
        //网络下载
        TIMSnapshot *imSnapshot = [self getIMSnapshot];
        _isDownloadingSnapshot = YES;
        __weak typeof(self) ws = self;
        void (^completeBlock)(int, NSString *, NSString *) = ^(int code, NSString *msg, NSString *path){
            ws.isDownloadingSnapshot = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                if(ws.snapshotResponseBlocks.count != 0){
                    for (TDownloadResponse response in ws.snapshotResponseBlocks) {
                        if(response){
                            response(code, msg, path);
                        }
                    }
                    [ws.snapshotResponseBlocks removeAllObjects];
                }
            });
        };
        
        [imSnapshot getImage:path progress:^(NSInteger curSize, NSInteger totalSize) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(ws.snapshotProgressBlocks.count != 0){
                    for (TDownloadProgress progress in ws.snapshotProgressBlocks) {
                        if(progress){
                            progress(curSize, totalSize);
                        }
                    }
                }
                if(curSize == totalSize){
                    [ws.snapshotProgressBlocks removeAllObjects];
                }
            });
        } succ:^{
            completeBlock(0, nil, path);
        } fail:^(int code, NSString *msg) {
            completeBlock(code, msg, nil);
        }];
    }
}

- (void)downloadVideo:(TDownloadProgress)progress response:(TDownloadResponse)response
{
    
    BOOL isExist = NO;
    NSString *path = [self getVideoPath:&isExist];
    if(isExist){
        if(response){
            response(0, nil, path);
        }
    }
    else{
        
        if(progress){
            [_videoProgressBlocks addObject:progress];
        }
        if(response){
            [_videoResponseBlocks addObject:response];
        }
        
        if(_isDownloadingVideo){
            return;
        }
        
        //网络下载
        TIMVideo *imVideo = [self getIMVideo];
        _isDownloadingVideo = YES;
        __weak typeof(self) ws = self;
        void (^completeBlock)(int, NSString *, NSString *) = ^(int code, NSString *msg, NSString *path){
            ws.isDownloadingVideo = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                if(ws.videoResponseBlocks.count != 0){
                    for (TDownloadResponse response in ws.videoResponseBlocks) {
                        if(response){
                            response(code, msg, path);
                        }
                    }
                    [ws.videoResponseBlocks removeAllObjects];
                }
            });
        };
        
        [imVideo getVideo:path progress:^(NSInteger curSize, NSInteger totalSize) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(ws.videoProgressBlocks.count != 0){
                    for (TDownloadProgress progress in ws.videoProgressBlocks) {
                        if(progress){
                            progress(curSize, totalSize);
                        }
                    }
                }
                if(curSize == totalSize){
                    [ws.videoProgressBlocks removeAllObjects];
                }
            });
        } succ:^{
            completeBlock(0, nil, path);
        } fail:^(int code, NSString *msg) {
            completeBlock(code, msg, nil);
        }];
    }
}

- (NSString *)getVideoPath:(BOOL *)isExist
{
    NSString *path = nil;
    BOOL isDir = NO;
    *isExist = NO;
    if(super.isSelf){
        //上传方本地原图是否有效
        path = [NSString stringWithFormat:@"%@%@", TUIKit_Video_Path, _videoPath.lastPathComponent];
        if([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]){
            if(!isDir){
                *isExist = YES;
            }
        }
    }
    
    if(!*isExist){
        if(_videoItem){
            //查看本地是否存在
            path = [NSString stringWithFormat:@"%@%@.%@", TUIKit_Video_Path, _videoItem.uuid, _videoItem.type];
            if([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]){
                if(!isDir){
                    *isExist = YES;
                }
            }
        }
    }
    
    return path;
}

- (NSString *)getSnapshotPath:(BOOL *)isExist
{
    NSString *path = nil;
    BOOL isDir = NO;
    *isExist = NO;
    if(super.isSelf){
        //上传方本地是否有效
        path = [NSString stringWithFormat:@"%@%@", TUIKit_Video_Path, _snapshotPath.lastPathComponent];
        if([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]){
            if(!isDir){
                *isExist = YES;
            }
        }
    }

    if(!*isExist){
        if(_snapshotItem){
            //查看本地是否存在
            path = [NSString stringWithFormat:@"%@%@", TUIKit_Video_Path, _snapshotItem.uuid];
            path = [TUIKit_Video_Path stringByAppendingString:_snapshotItem.uuid];
            if([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]){
                if(!isDir){
                    *isExist = YES;
                }
            }
        }
    }
    
    return path;
}

- (TIMSnapshot *)getIMSnapshot
{
    TIMMessage *imMsg = self.custom;
    for (int i = 0; i < imMsg.elemCount; ++i) {
        TIMElem *imElem = [imMsg getElem:i];
        if([imElem isKindOfClass:[TIMVideoElem class]]){
            TIMVideoElem *imVideoElem = (TIMVideoElem *)imElem;
            return imVideoElem.snapshot;
        }
    }
    return nil;
}

- (TIMVideo *)getIMVideo
{
    TIMMessage *imMsg = self.custom;
    for (int i = 0; i < imMsg.elemCount; ++i) {
        TIMElem *imElem = [imMsg getElem:i];
        if([imElem isKindOfClass:[TIMVideoElem class]]){
            TIMVideoElem *imVideoElem = (TIMVideoElem *)imElem;
            return imVideoElem.video;
        }
    }
    return nil;
}
@end

@implementation TVideoMessageCell

- (CGSize)getContainerSize:(TVideoMessageCellData *)data
{
    CGSize size = CGSizeZero;
    BOOL isDir = NO;
    if(![data.snapshotPath isEqualToString:@""] &&
       [[NSFileManager defaultManager] fileExistsAtPath:data.snapshotPath isDirectory:&isDir]){
        if(!isDir){
            size = [UIImage imageWithContentsOfFile:data.snapshotPath].size;
        }
    }
    else{
        size = data.snapshotItem.size;
    }
    if(CGSizeEqualToSize(size, CGSizeZero)){
        return size;
    }
    if(size.height > size.width){
        size.width = size.width / size.height * TVideoMessageCell_Image_Height_Max;
        size.height = TVideoMessageCell_Image_Height_Max;
    }
    else{
        size.height = size.height / size.width * TVideoMessageCell_Image_Width_Max;
        size.width = TVideoMessageCell_Image_Width_Max;
    }
    return size;
}

- (void)setupViews
{
    [super setupViews];
    
    _thumb = [[UIImageView alloc] init];
    _thumb.layer.cornerRadius = 5.0;
    [_thumb.layer setMasksToBounds:YES];
    _thumb.contentMode = UIViewContentModeScaleAspectFit;
    _thumb.backgroundColor = [UIColor whiteColor];
    [super.container addSubview:_thumb];
    
    CGSize playSize = TVideoMessageCell_Play_Size;
    _play = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, playSize.width, playSize.height)];
    _play.contentMode = UIViewContentModeScaleAspectFit;
    _play.image = [[[TUIKit sharedInstance] getConfig] getResourceFromCache:TUIKitResource(@"play_normal")];
    [super.container addSubview:_play];
    
//    _videoIndicator = [[UIActivityIndicatorView alloc] init];
//    _videoIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
//    [super.container addSubview:_videoIndicator];
//    _videoIndicator.hidden = YES;
    
    _duration = [[UILabel alloc] init];
    _duration.textColor = [UIColor whiteColor];
    _duration.font = [UIFont systemFontOfSize:12];
    [super.container addSubview:_duration];
    
    
    _uploadProgress = [[UILabel alloc] init];
    _uploadProgress.textColor = [UIColor whiteColor];
    _uploadProgress.font = [UIFont systemFontOfSize:15];
    _uploadProgress.textAlignment = NSTextAlignmentCenter;
    _uploadProgress.layer.cornerRadius = 5.0;
    _uploadProgress.hidden = YES;
    _uploadProgress.backgroundColor = TVideoMessageCell_Progress_Color;
    [_uploadProgress.layer setMasksToBounds:YES];
    [super.container addSubview:_uploadProgress];
    
}


- (void)setData:(TVideoMessageCellData *)data;
{
    //set data
    [super setData:data];
    _thumb.image = nil;
    if(data.thumbImage){
        _thumb.image = data.thumbImage;
    }
    else{
        [data downloadSnapshot:^(NSInteger curSize, NSInteger totalSize) {
        } response:^(int code, NSString *desc, NSString *path) {
            if(code == 0){
                [THelper asyncDecodeImage:path queue:dispatch_get_global_queue(0, 0) complete:^(NSString *path, UIImage *image) {
                    data.thumbImage = image;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if(super.delegate && [super.delegate respondsToSelector:@selector(needReloadMessage:)]){
                            [super.delegate needReloadMessage:data];
                        }
                    });
                }];
            }
        }];
    }
    _duration.text = [NSString stringWithFormat:@"%02ld:%02ld", (long)data.videoItem.duration / 60, (long)data.videoItem.duration % 60];;

    //update layout
    _uploadProgress.frame = super.container.bounds;
    _thumb.frame = super.container.bounds;
    CGSize playSize = TVideoMessageCell_Play_Size;
    _play.frame = CGRectMake((super.container.frame.size.width - playSize.width) * 0.5, (super.container.frame.size.height - playSize.height) * 0.5, playSize.width, playSize.height);
//    _videoIndicator.frame = _play.frame;
    CGSize durationSize = [_duration sizeThatFits:super.container.frame.size];
    _duration.frame = CGRectMake(super.container.frame.size.width - TVideoMessageCell_Margin_3 - durationSize.width, super.container.frame.size.height - TVideoMessageCell_Margin_3 - durationSize.height, durationSize.width, durationSize.height);
    //update progress
    _uploadProgress.text = [NSString stringWithFormat:@"%d%%", data.uploadProgress];
    if(data.uploadProgress < 100){
        _uploadProgress.hidden = NO;
        _play.hidden = YES;
    }
    else{
        _uploadProgress.hidden = YES;
        _play.hidden = NO;
    }
    
//    if(data.isDownloadingVideo){
//        [self beginDownloadVideo];
//    }
//    else{
//        [self endDownloadVideo];
//    }
}

//- (void)beginDownloadVideo
//{
//    if(!_videoIndicator.animating){
//        _play.hidden = YES;
//        _videoIndicator.hidden = NO;
//        [_videoIndicator startAnimating];
//    }
//}
//
//- (void)endDownloadVideo
//{
//    if(_videoIndicator.animating){
//        _play.hidden = NO;
//        _videoIndicator.hidden = YES;
//        [_videoIndicator stopAnimating];
//    }
//}

@end
