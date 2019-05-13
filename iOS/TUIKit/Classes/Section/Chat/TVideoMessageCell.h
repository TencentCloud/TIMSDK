//
//  TVideoMessageCell.h
//  UIKit
//
//  Created by kennethmiao on 2018/10/9.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import "TMessageCell.h"



@interface TVideoItem : NSObject
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, assign) NSInteger length;
@property (nonatomic, assign) NSInteger duration;
@end

@interface TSnapshotItem : NSObject
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) NSInteger length;
@end

@interface TVideoMessageCellData : TMessageCellData
@property (nonatomic, strong) UIImage *thumbImage;
@property (nonatomic, strong) NSString *snapshotPath;
@property (nonatomic, strong) NSString *videoPath;
@property (nonatomic, strong) TVideoItem *videoItem;
@property (nonatomic, strong) TSnapshotItem *snapshotItem;
@property (nonatomic, assign) int uploadProgress;
- (void)downloadSnapshot:(TDownloadProgress)progress response:(TDownloadResponse)response;
- (void)downloadVideo:(TDownloadProgress)progress response:(TDownloadResponse)response;
- (NSString *)getVideoPath:(BOOL *)isExist;
- (NSString *)getSnapshotPath:(BOOL *)isExist;
@end

@interface TVideoMessageCell : TMessageCell
@property (nonatomic, strong) UIImageView *thumb;
@property (nonatomic, strong) UILabel *duration;
@property (nonatomic, strong) UIImageView *play;
@property (nonatomic, strong) UILabel *uploadProgress;
//@property (nonatomic, strong) UIActivityIndicatorView *videoIndicator;
@end
