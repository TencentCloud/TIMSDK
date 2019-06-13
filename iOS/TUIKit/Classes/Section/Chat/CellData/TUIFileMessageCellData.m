//
//  TUIFileMessageCellData.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/21.
//

#import "TUIFileMessageCellData.h"
#import "THeader.h"
#import "TUIKit.h"
@import ImSDK;

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
        _isDownloading = NO;
        _progressBlocks = [NSMutableArray array];
        _responseBlocks = [NSMutableArray array];
    }
    return self;
}

- (void)downloadFile:(TDownloadProgress)progress response:(TDownloadResponse)response
{
    
    BOOL isExist = NO;
    NSString *path = [self getFilePath:&isExist];
    if(isExist){
        if(response){
            response(0, nil, path);
        }
        return;
    }
    else{
        if(progress){
            [_progressBlocks addObject:progress];
        }
        if(response){
            [_responseBlocks addObject:response];
        }
        if(_isDownloading){
            return;
        }
        
        //网络下载
        TIMFileElem *imFile = [self getIMFileElem];
        _isDownloading = YES;
        __weak typeof(self) ws = self;
        void (^completeBlock)(int, NSString *, NSString *) = ^(int code, NSString *msg, NSString *path){
            ws.isDownloading = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                if(ws.responseBlocks.count != 0){
                    for (TDownloadResponse response in ws.responseBlocks) {
                        if(response){
                            response(code, msg, path);
                        }
                    }
                    [ws.responseBlocks removeAllObjects];
                }
            });
        };
        
        [imFile getFile:path progress:^(NSInteger curSize, NSInteger totalSize) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(ws.progressBlocks.count != 0){
                    for (TDownloadProgress progress in ws.progressBlocks) {
                        if(progress){
                            progress(curSize, totalSize);
                        }
                    }
                }
                if(curSize == totalSize){
                    [ws.progressBlocks removeAllObjects];
                }
            });
        } succ:^{
            completeBlock(0, nil, path);
        } fail:^(int code, NSString *msg) {
            completeBlock(code, msg, nil);
        }];
    }
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
    
    return path;
}

- (TIMFileElem *)getIMFileElem
{
    TIMMessage *imMsg = self.innerMessage;
    for (int i = 0; i < imMsg.elemCount; ++i) {
        TIMElem *imElem = [imMsg getElem:i];
        if([imElem isKindOfClass:[TIMFileElem class]]){
            TIMFileElem *imFileElem = (TIMFileElem *)imElem;
            return imFileElem;
        }
    }
    return nil;
}

- (CGSize)contentSize
{
    return TFileMessageCell_Container_Size;
}
@end

