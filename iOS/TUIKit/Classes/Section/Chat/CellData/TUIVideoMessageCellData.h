//
//  TUIVideoMessageCellData.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/21.
//

#import "TUIMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIVideoItem : NSObject
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, assign) NSInteger length;
@property (nonatomic, assign) NSInteger duration;
@end

@interface TUISnapshotItem : NSObject
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) NSInteger length;
@end

@interface TUIVideoMessageCellData : TUIMessageCellData

@property (nonatomic, strong) UIImage *thumbImage;
@property (nonatomic, strong) NSString *videoPath;
@property (nonatomic, strong) NSString *snapshotPath;

@property (nonatomic, strong) TUIVideoItem *videoItem;
@property (nonatomic, strong) TUISnapshotItem *snapshotItem;

@property (nonatomic, assign) NSUInteger uploadProgress;
@property (nonatomic, assign) NSUInteger thumbProgress;
@property (nonatomic, assign) NSUInteger videoProgress;

- (void)downloadThumb;
- (void)downloadVideo;

- (BOOL)isVideoExist;

@end

NS_ASSUME_NONNULL_END
