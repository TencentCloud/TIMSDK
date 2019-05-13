//
//  TImageMessageCell.m
//  UIKit
//
//  Created by kennethmiao on 2018/9/17.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TImageMessageCell.h"
#import "THeader.h"
#import "THelper.h"
@import ImSDK;

@implementation TImageItem
@end

@interface TImageMessageCellData ()
@property (nonatomic, assign) BOOL isDownloading;
@property (nonatomic, strong) NSMutableArray *thumbProgressBlocks;
@property (nonatomic, strong) NSMutableArray *thumbResponseBlocks;
@property (nonatomic, strong) NSMutableArray *originProgressBlocks;
@property (nonatomic, strong) NSMutableArray *originResponseBlocks;
@end

@implementation TImageMessageCellData
- (id)init
{
    self = [super init];
    if(self){
        _uploadProgress = 100;
        _isDownloading = NO;
        _thumbProgressBlocks = [NSMutableArray array];
        _thumbResponseBlocks = [NSMutableArray array];
        _originProgressBlocks = [NSMutableArray array];
        _originResponseBlocks = [NSMutableArray array];
    }
    return self;
}

- (NSString *)getImagePath:(TImageType)type isExist:(BOOL *)isExist
{
    NSString *path = nil;
    BOOL isDir = NO;
    *isExist = NO;
    if(super.isSelf){
        //上传方本地原图是否有效
        path = [NSString stringWithFormat:@"%@%@", TUIKit_Image_Path, _path.lastPathComponent];
        if([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]){
            if(!isDir){
                *isExist = YES;
            }
        }
    }
    
    if(!*isExist){
        //查看本地是否存在
        TImageItem *tImageItem = [self getTImageItem:type];
        path = [NSString stringWithFormat:@"%@%@", TUIKit_Image_Path, tImageItem.uuid];
        if([[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir]){
            if(!isDir){
                *isExist = YES;
            }
        }
    }
    
    return path;
}

- (void)downloadImage:(TImageType)type progress:(TDownloadProgress)progress response:(TDownloadResponse)response
{
    BOOL isExist = NO;
    NSString *path = [self getImagePath:type isExist:&isExist];
    if(isExist){
        if(response){
            response(0, nil, path);
        }
    }
    else{
        if(progress){
            if(type == TImage_Type_Thumb){
                [_thumbProgressBlocks addObject:progress];
            }
            else if(type == TImage_Type_Origin){
                [_originProgressBlocks addObject:progress];
            }
        }
        if(response){
            if(type == TImage_Type_Thumb){
                [_thumbResponseBlocks addObject:response];
            }
            else if(type == TImage_Type_Origin){
                [_originResponseBlocks addObject:response];
            }
        }
        
        if(_isDownloading){
            return;
        }
        
        //网络下载
        TIMImage *imImage = [self getIMImage:type];
        _isDownloading = YES;
        __weak typeof(self) ws = self;
        void (^completeBlock)(int, NSString *, NSString *) = ^(int code, NSString *msg, NSString *path){
            ws.isDownloading = NO;
            dispatch_async(dispatch_get_main_queue(), ^{
                NSMutableArray *array = nil;
                if(type == TImage_Type_Thumb){
                    array = ws.thumbResponseBlocks;
                }
                else if(type == TImage_Type_Origin){
                    array = ws.originResponseBlocks;
                }
                if(array.count != 0){
                    for (TDownloadResponse response in array) {
                        if(response){
                            response(code, msg, path);
                        }
                    }
                }
                [array removeAllObjects];
            });
        };
        
        [imImage getImage:path progress:^(NSInteger curSize, NSInteger totalSize) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSMutableArray *array = nil;
                if(type == TImage_Type_Thumb){
                    array = ws.thumbProgressBlocks;
                }
                else if(type == TImage_Type_Origin){
                    array = ws.originProgressBlocks;
                }
                if(array.count != 0){
                    for (TDownloadProgress progress in array) {
                        if(progress){
                            progress(curSize, totalSize);
                        }
                    }
                }
                if(curSize == totalSize){
                    [array removeAllObjects];
                }
            });
        } succ:^{
            completeBlock(0, nil, path);
        } fail:^(int code, NSString *msg) {
            completeBlock(code, msg, nil);
        }];
    }
}

- (TImageItem *)getTImageItem:(TImageType)type
{
    for (TImageItem *item in self.items) {
        if(item.type == type){
            return item;
        }
    }
    return nil;
}

- (TIMImage *)getIMImage:(TImageType)type
{
    TIMMessage *imMsg = self.custom;
    for (int i = 0; i < imMsg.elemCount; ++i) {
        TIMElem *imElem = [imMsg getElem:i];
        if([imElem isKindOfClass:[TIMImageElem class]]){
            TIMImageElem *imImageElem = (TIMImageElem *)imElem;
            for (TIMImage *imImage in imImageElem.imageList) {
                if(type == TImage_Type_Thumb && imImage.type == TIM_IMAGE_TYPE_THUMB){
                    return imImage;
                }
                else if(type == TImage_Type_Origin && imImage.type == TIM_IMAGE_TYPE_ORIGIN){
                    return imImage;
                }
                else if(type == TImage_Type_Large && imImage.type == TIM_IMAGE_TYPE_LARGE){
                    return imImage;
                }
            }
            break;
        }
    }
    return nil;
}
@end

@implementation TImageMessageCell

- (CGSize)getContainerSize:(TImageMessageCellData *)data
{
    CGSize size = CGSizeZero;
    BOOL isDir = NO;
    if(![data.path isEqualToString:@""] &&
       [[NSFileManager defaultManager] fileExistsAtPath:data.path isDirectory:&isDir]){
        if(!isDir){
            size = [UIImage imageWithContentsOfFile:data.path].size;
        }
    }
    else{
        for (TImageItem *item in data.items) {
            if(item.type == TImage_Type_Thumb){
                size = item.size;
            }
        }
    }
    if(CGSizeEqualToSize(size, CGSizeZero)){
        return size;
    }
    if(size.height > size.width){
        size.width = size.width / size.height * TImageMessageCell_Image_Height_Max;
        size.height = TImageMessageCell_Image_Height_Max;
    }
    else{
        size.height = size.height / size.width * TImageMessageCell_Image_Width_Max;
        size.width = TImageMessageCell_Image_Width_Max;
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
    
    _uploadProgress = [[UILabel alloc] init];
    _uploadProgress.textColor = [UIColor whiteColor];
    _uploadProgress.font = [UIFont systemFontOfSize:15];
    _uploadProgress.textAlignment = NSTextAlignmentCenter;
    _uploadProgress.layer.cornerRadius = 5.0;
    _uploadProgress.hidden = YES;
    _uploadProgress.backgroundColor = TImageMessageCell_Progress_Color;
    [_uploadProgress.layer setMasksToBounds:YES];
    [super.container addSubview:_uploadProgress];

}

- (void)setData:(TImageMessageCellData *)data;
{
    //set data
    [super setData:data];
    _thumb.image = nil;
    if(data.thumbImage){
        _thumb.image = data.thumbImage;
    }
    else{
        [data downloadImage:TImage_Type_Thumb progress:^(NSInteger curSize, NSInteger totalSize) {
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
    
    //update layout
    _thumb.frame = super.container.bounds;
    _uploadProgress.frame = super.container.bounds;
    //update progress
    _uploadProgress.text = [NSString stringWithFormat:@"%d%%", data.uploadProgress];
    if(data.uploadProgress < 100){
        _uploadProgress.hidden = NO;
    }
    else{
        _uploadProgress.hidden = YES;
    }
}
@end
