//
//  TUIFileMessageCellData.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/21.
//

#import "TUIFileMessageCellData.h"
#import "TUIKit.h"
#import "ReactiveObjC/ReactiveObjC.h"

@interface TUIFileMessageCellData ()
@property (nonatomic, strong) NSMutableArray *progressBlocks;
@property (nonatomic, strong) NSMutableArray *responseBlocks;
@end

@implementation TUIFileMessageCellData
- (id)init
{
    self = [super init];
    if(self){
        _uploadProgress = 100;
        _downladProgress = 100;
        _isDownloading = NO;
        _progressBlocks = [NSMutableArray array];
        _responseBlocks = [NSMutableArray array];
    }
    return self;
}

- (void)downloadFile
{

    BOOL isExist = NO;
    NSString *path = [self getFilePath:&isExist];
    if(isExist){
        return;
    }
    if (self.isDownloading)
        return;
    self.isDownloading = YES;

    //网络下载
    @weakify(self)
    if (self.innerMessage.elemType == V2TIM_ELEM_TYPE_FILE) {
        [self.innerMessage.fileElem downloadFile:path progress:^(NSInteger curSize, NSInteger totalSize) {
            @strongify(self)
            [self updateDownalodProgress:curSize * 100 / totalSize];
        } succ:^{
            @strongify(self)
            self.isDownloading = NO;
            [self updateDownalodProgress:100];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.path = path;
            });
        } fail:^(int code, NSString *msg) {
            @strongify(self)
            self.isDownloading = NO;
        }];
    }
}

- (void)updateDownalodProgress:(NSUInteger)progress
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.downladProgress = progress;
    });
}


- (BOOL)isLocalExist
{
    BOOL isExist;
    [self getFilePath:&isExist];
    return isExist;
}

- (NSString *)getFilePath:(BOOL *)isExist
{
    NSString *path = nil;
    BOOL isDir = NO;
    *isExist = NO;
    if(self.direction == MsgDirectionOutgoing){
        //上传方本地原图是否有效
        path = [NSString stringWithFormat:@"%@%@", TUIKit_File_Path, _path.lastPathComponent];
        if([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]){
            if(!isDir){
                *isExist = YES;
            }
        }
    }

    if(!*isExist){
        //查看本地是否存在
        path = [NSString stringWithFormat:@"%@%@", TUIKit_File_Path, _fileName];
        if([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]){
            if(!isDir){
                *isExist = YES;
            }
        }
    }
    if (*isExist) {
        _path = path;
    }

    // TODO: uuid

    return path;
}

- (CGSize)contentSize
{
    return TFileMessageCell_Container_Size;
}
@end

