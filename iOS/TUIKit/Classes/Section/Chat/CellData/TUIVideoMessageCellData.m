//
//  TUIVideoMessageCellData.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/21.
//

#import "TUIVideoMessageCellData.h"
#import "TUIKit.h"
#import "ReactiveObjC/ReactiveObjC.h"

@implementation TUIVideoItem
@end

@implementation TUISnapshotItem
@end

#define TVideo_Block_Progress @"TVideo_Block_Progress";
#define TVideo_Block_Response @"TVideo_Block_Response";

@interface TUIVideoMessageCellData ()
@property (nonatomic, assign) BOOL isDownloadingSnapshot;
@property (nonatomic, assign) BOOL isDownloadingVideo;
@end

@implementation TUIVideoMessageCellData
- (id)init
{
    self = [super init];
    if(self){
        _uploadProgress = 100;
        _isDownloadingVideo = NO;
        _isDownloadingSnapshot = NO;
    }
    return self;
}

- (void)downloadThumb
{

    BOOL isExist = NO;
    NSString *path = [self getSnapshotPath:&isExist];
    if (isExist) {
        [self decodeThumb];
        return;
    }

    if(self.isDownloadingSnapshot) {
        return;
    }
    self.isDownloadingSnapshot = YES;


    //网络下载
    @weakify(self)
    V2TIMMessage *imMsg = self.innerMessage;
    if (imMsg.elemType == V2TIM_ELEM_TYPE_VIDEO) {
        [imMsg.videoElem downloadSnapshot:path progress:^(NSInteger curSize, NSInteger totalSize) {
            [self updateThumbProgress:curSize * 100 / totalSize];
        } succ:^{
            @strongify(self)
            self.isDownloadingSnapshot = NO;
            [self updateThumbProgress:100];
            [self decodeThumb];
        } fail:^(int code, NSString *msg) {
            @strongify(self)
            self.isDownloadingSnapshot = NO;
        }];
    }
}

- (void)updateThumbProgress:(NSUInteger)progress
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.thumbProgress = progress;
    });
}

- (void)decodeThumb
{
    BOOL isExist = NO;
    NSString *path = [self getSnapshotPath:&isExist];
    if (!isExist) {
        return;
    }
    [THelper asyncDecodeImage:path complete:^(NSString *path, UIImage *image) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.thumbImage = image;
            self.thumbProgress = 100;
        });
    }];
}

- (void)downloadVideo
{
    BOOL isExist = NO;
    NSString *path = [self getVideoPath:&isExist];
    if (isExist) {
        return;
    }

    if(self.isDownloadingVideo) {
        return;
    }
    self.isDownloadingVideo = YES;

    //网络下载
    @weakify(self)
    V2TIMMessage *imMsg = self.innerMessage;
    if (imMsg.elemType == V2TIM_ELEM_TYPE_VIDEO) {
        [imMsg.videoElem downloadVideo:path progress:^(NSInteger curSize, NSInteger totalSize) {
            @strongify(self)
            [self updateVideoProgress:curSize * 100 / totalSize];
        } succ:^{
            @strongify(self)
            self.isDownloadingVideo = NO;
            [self updateThumbProgress:100];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.videoPath = path;
            });
        } fail:^(int code, NSString *msg) {
            @strongify(self)
            self.isDownloadingVideo = NO;
        }];
    }
}

- (void)updateVideoProgress:(NSUInteger)progress
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.videoProgress = progress;
    });
}

- (BOOL)isVideoExist
{
    BOOL isExist;
    [self getVideoPath:&isExist];
    return isExist;
}

- (NSString *)getVideoPath:(BOOL *)isExist
{
    NSString *path = nil;
    BOOL isDir = NO;
    *isExist = NO;
    if(self.direction == MsgDirectionOutgoing){
        //上传方本地原图是否有效
        // fix: 如果videPath或者videoItem.uuid等信息为空，导致path即为TUIKit_Video_Path，此时会导致SDK内部下载时将video路径给删掉了
        if (_videoPath && _videoPath.lastPathComponent.length) {
            path = [NSString stringWithFormat:@"%@%@", TUIKit_Video_Path, _videoPath.lastPathComponent];
            if([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]){
                if(!isDir){
                    *isExist = YES;
                }
            }
        }
    }

    if(!*isExist){
        if(_videoItem){
            //查看本地是否存在
            // fix: 如果videPath或者videoItem.uuid等信息为空，导致path即为TUIKit_Video_Path，此时会导致SDK内部下载时将video路径给删掉了
            if (_videoItem.uuid && _videoItem.uuid.length && _videoItem.type && _videoItem.type.length) {
                path = [NSString stringWithFormat:@"%@%@.%@", TUIKit_Video_Path, _videoItem.uuid, _videoItem.type];
                if([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]){
                    if(!isDir){
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

- (NSString *)getSnapshotPath:(BOOL *)isExist
{
    NSString *path = nil;
    BOOL isDir = NO;
    *isExist = NO;
    if(self.direction == MsgDirectionOutgoing){
        //上传方本地是否有效
        if (_snapshotPath && _snapshotPath.length) {
            path = [NSString stringWithFormat:@"%@%@", TUIKit_Video_Path, _snapshotPath.lastPathComponent];
            if([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]){
                if(!isDir){
                    *isExist = YES;
                }
            }
        }
    }

    if(!*isExist){
        if(_snapshotItem){
            //查看本地是否存在
            if (_snapshotItem.uuid && _snapshotItem.uuid.length) {
                path = [NSString stringWithFormat:@"%@%@", TUIKit_Video_Path, _snapshotItem.uuid];
                path = [TUIKit_Video_Path stringByAppendingString:_snapshotItem.uuid];
                if([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]){
                    if(!isDir){
                        *isExist = YES;
                    }
                }
            }
        }
    }

    return path;
}

- (CGSize)contentSize
{
    CGSize size = CGSizeZero;
    BOOL isDir = NO;
    if(![self.snapshotPath isEqualToString:@""] &&
       [[NSFileManager defaultManager] fileExistsAtPath:self.snapshotPath isDirectory:&isDir]){
        if(!isDir){
            size = [UIImage imageWithContentsOfFile:self.snapshotPath].size;
        }
    }
    else{
        size = self.snapshotItem.size;
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


@end
