//
//  TFileMessageCell.h
//  UIKit
//
//  Created by kennethmiao on 2018/9/17.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TMessageCell.h"



@interface TFileMessageCellData: TMessageCellData
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, assign) int length;
@property (nonatomic, assign) int uploadProgress;
@property (nonatomic, assign) BOOL isDownloading;
- (void)downloadFile:(TDownloadProgress)progress response:(TDownloadResponse)response;
- (NSString *)getFilePath:(BOOL *)isExist;
@end


@interface TFileMessageCell : TMessageCell
@property (nonatomic, strong) UIImageView *bubble;
@property (nonatomic, strong) UILabel *fileName;
@property (nonatomic, strong) UILabel *length;
@property (nonatomic, strong) UILabel *uploadProgress;
@property (nonatomic, strong) UIImageView *image;
@end
