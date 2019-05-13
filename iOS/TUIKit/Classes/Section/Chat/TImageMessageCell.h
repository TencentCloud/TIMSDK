//
//  TImageMessageCell.h
//  UIKit
//
//  Created by kennethmiao on 2018/9/17.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TMessageCell.h"


typedef NS_ENUM(NSInteger, TImageType)
{
    TImage_Type_Thumb,
    TImage_Type_Large,
    TImage_Type_Origin,
};

@interface TImageItem : NSObject
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSString *url;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) TImageType type;
@end

@interface TImageMessageCellData : TMessageCellData
@property (nonatomic, strong) UIImage *thumbImage;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, assign) NSInteger length;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, assign) int uploadProgress;
- (void)downloadImage:(TImageType)type progress:(TDownloadProgress)progress response:(TDownloadResponse)response;
- (NSString *)getImagePath:(TImageType)type isExist:(BOOL *)isExist;
@end

@interface TImageMessageCell : TMessageCell
@property (nonatomic, strong) UIImageView *thumb;
@property (nonatomic, strong) UILabel *uploadProgress;
@end
