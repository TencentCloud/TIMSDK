//
//  TFileMessageCell.m
//  UIKit
//
//  Created by kennethmiao on 2018/9/17.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TFileMessageCell.h"
#import "THeader.h"
#import "TUIKit.h"
@import ImSDK;

@interface TFileMessageCellData ()
@property (nonatomic, strong) NSMutableArray *progressBlocks;
@property (nonatomic, strong) NSMutableArray *responseBlocks;
@end

@implementation TFileMessageCellData
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
    if(super.isSelf){
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
    TIMMessage *imMsg = self.custom;
    for (int i = 0; i < imMsg.elemCount; ++i) {
        TIMElem *imElem = [imMsg getElem:i];
        if([imElem isKindOfClass:[TIMFileElem class]]){
            TIMFileElem *imFileElem = (TIMFileElem *)imElem;
            return imFileElem;
        }
    }
    return nil;
}
@end

@implementation TFileMessageCell

- (CGSize)getContainerSize:(TFileMessageCellData *)data
{
    return TFileMessageCell_Container_Size;
}

- (void)setupViews
{
    [super setupViews];
//    _bubble = [[UIImageView alloc] init];
//    [super.container addSubview:_bubble];
    
    super.container.backgroundColor = [UIColor whiteColor];
    super.container.layer.cornerRadius = 5;
    [super.container.layer setMasksToBounds:YES];
    
    
    _fileName = [[UILabel alloc] init];
    _fileName.font = [UIFont systemFontOfSize:15];
    _fileName.textColor = [UIColor blackColor];
    [super.container addSubview:_fileName];
    
    _length = [[UILabel alloc] init];
    _length.font = [UIFont systemFontOfSize:12];
    _length.textColor = [UIColor grayColor];
    [super.container addSubview:_length];
    
    _image = [[UIImageView alloc] init];
    _image.image = [[[TUIKit sharedInstance] getConfig] getResourceFromCache:TUIKitResource(@"msg_file")];
    _image.contentMode = UIViewContentModeScaleAspectFit;
    [super.container addSubview:_image];
    
    _uploadProgress = [[UILabel alloc] init];
    _uploadProgress.textColor = [UIColor whiteColor];
    _uploadProgress.font = [UIFont systemFontOfSize:15];
    _uploadProgress.textAlignment = NSTextAlignmentCenter;
    _uploadProgress.layer.cornerRadius = 5.0;
    _uploadProgress.hidden = YES;
    _uploadProgress.backgroundColor = TFileMessageCell_Progress_Color;
    [_uploadProgress.layer setMasksToBounds:YES];
    [super.container addSubview:_uploadProgress];
}

- (void)setData:(TFileMessageCellData *)data
{
    //set data
    [super setData:data];
    _fileName.text = data.fileName;
    _length.text = [self formatLength:data.length];
    
    //update layout
    CGSize containerSize = [self getContainerSize:data];
    CGFloat imageHeight = containerSize.height - 2 * TFileMessageCell_Margin;
    CGFloat imageWidth = imageHeight;
    _image.frame = CGRectMake(containerSize.width - TFileMessageCell_Margin - imageWidth, TFileMessageCell_Margin, imageWidth, imageHeight);
    CGFloat textWidth = _image.frame.origin.x - 2 * TFileMessageCell_Margin;
    CGSize nameSize = [_fileName sizeThatFits:containerSize];
    _fileName.frame = CGRectMake(TFileMessageCell_Margin, TFileMessageCell_Margin, textWidth, nameSize.height);
    CGSize lengthSize = [_length sizeThatFits:containerSize];
    _length.frame = CGRectMake(TFileMessageCell_Margin, _fileName.frame.origin.y + nameSize.height + TFileMessageCell_Margin * 0.5, textWidth, lengthSize.height);
    //update progress
    _uploadProgress.frame = super.container.bounds;
    _uploadProgress.text = [NSString stringWithFormat:@"%d%%", data.uploadProgress];
    if(data.uploadProgress < 100){
        _uploadProgress.hidden = NO;
    }
    else{
        _uploadProgress.hidden = YES;
    }
    
//    if(data.isSelf){
//        _bubble.image = [[UIImage imageNamed:TUIKitResource(@"sender_text_normal")] resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{18,25,17,25}") resizingMode:UIImageResizingModeStretch];
//        _bubble.highlightedImage = [[UIImage imageNamed:@"sender_text_pressed"] resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{18,25,17,25}") resizingMode:UIImageResizingModeStretch];
//    }
//    else{
//        _bubble.image = [[UIImage imageNamed:TUIKitResource(@"receiver_text_normal")] resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{18,25,17,25}") resizingMode:UIImageResizingModeStretch];
//        _bubble.highlightedImage = [[UIImage imageNamed:TUIKitResource(@"receiver_text_pressed")] resizableImageWithCapInsets:UIEdgeInsetsFromString(@"{18,25,17,25}") resizingMode:UIImageResizingModeStretch];
//    }
}

- (NSString *)formatLength:(long)length
{
    double len = length;
    NSArray *array = [NSArray arrayWithObjects:@"Bytes", @"K", @"M", @"G", @"T", nil];
    int factor = 0;
    while (len > 1024) {
        len /= 1024;
        factor++;
        if(factor >= 4){
            break;
        }
    }
    return [NSString stringWithFormat:@"%4.2f%@", len, array[factor]];
}
@end
