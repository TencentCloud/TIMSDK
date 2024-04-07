//
//  TUIFileMessageCellData.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/21.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIFileMessageCellData.h"
#import <TIMCommon/TIMDefine.h>
#import <TUICore/NSString+TUIUtil.h>
#import "TUIMessageProgressManager.h"

@interface TUIFileMessageCellData ()
@property(nonatomic, strong) NSMutableArray *progressBlocks;
@property(nonatomic, strong) NSMutableArray *responseBlocks;
@end

@implementation TUIFileMessageCellData

+ (TUIMessageCellData *)getCellData:(V2TIMMessage *)message {
    V2TIMFileElem *elem = message.fileElem;
    TUIFileMessageCellData *fileData = [[TUIFileMessageCellData alloc] initWithDirection:(message.isSelf ? MsgDirectionOutgoing : MsgDirectionIncoming)];
    fileData.path = [elem.path safePathString];
    fileData.fileName = elem.filename;
    fileData.length = elem.fileSize;
    fileData.uuid = elem.uuid;
    fileData.reuseId = TFileMessageCell_ReuseId;
    return fileData;
}

+ (NSString *)getDisplayString:(V2TIMMessage *)message {
    return TIMCommonLocalizableString(TUIkitMessageTypeFile);  // @"[File]";
}

- (Class)getReplyQuoteViewDataClass {
    return NSClassFromString(@"TUIFileReplyQuoteViewData");
}

- (Class)getReplyQuoteViewClass {
    return NSClassFromString(@"TUIFileReplyQuoteView");
}

- (int)length {
    if (self.innerMessage) {
        _length = self.innerMessage.fileElem.fileSize;
    }
    return _length;
}

- (instancetype)initWithDirection:(TMsgDirection)direction {
    self = [super initWithDirection:direction];
    if (self) {
        _uploadProgress = 100;
        _downladProgress = 100;
        _isDownloading = NO;
        _progressBlocks = [NSMutableArray array];
        _responseBlocks = [NSMutableArray array];
    }
    return self;
}

- (void)downloadFile {
    BOOL isExist = NO;
    NSString *path = [self getFilePath:&isExist];
    if (isExist) {
        return;
    }

    NSInteger progress = [TUIMessageProgressManager.shareManager downloadProgressForMessage:self.msgID];
    if (progress != 0) {
        return;
    }

    if (self.isDownloading) return;
    self.isDownloading = YES;
    @weakify(self);
    if (self.innerMessage.elemType == V2TIM_ELEM_TYPE_FILE) {
        NSString *msgID = self.msgID;
        [self.innerMessage.fileElem downloadFile:path
            progress:^(NSInteger curSize, NSInteger totalSize) {
              @strongify(self);
              NSInteger progress = curSize * 100 / totalSize;
              [self updateDownalodProgress:MIN(progress, 99)];
              [TUIMessageProgressManager.shareManager appendDownloadProgress:msgID progress:MIN(progress, 99)];
            }
            succ:^{
              @strongify(self);
              dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                self.isDownloading = NO;
                [self updateDownalodProgress:100];
                [TUIMessageProgressManager.shareManager appendDownloadProgress:msgID progress:100];
                dispatch_async(dispatch_get_main_queue(), ^{
                  self.path = path;
                });
              });
            }
            fail:^(int code, NSString *msg) {
              @strongify(self);
              self.isDownloading = NO;
            }];
    }
}

- (void)updateDownalodProgress:(NSUInteger)progress {
    dispatch_async(dispatch_get_main_queue(), ^{
      self.downladProgress = progress;
    });
}

- (BOOL)isLocalExist {
    BOOL isExist;
    [self getFilePath:&isExist];
    return isExist;
}

- (NSString *)getFilePath:(BOOL *)isExist {
    NSString *path = nil;
    BOOL isDir = NO;
    *isExist = NO;
    if (self.direction == MsgDirectionOutgoing) {
        // The origin file path is valid when uploading
        path = [NSString stringWithFormat:@"%@%@", TUIKit_File_Path, _path.lastPathComponent];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]) {
            if (!isDir) {
                *isExist = YES;
            }
        }
    }

    if (!*isExist) {
        path = [NSString stringWithFormat:@"%@%@%@", TUIKit_File_Path,self.uuid, _fileName];
        if ([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]) {
            if (!isDir) {
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

@end
