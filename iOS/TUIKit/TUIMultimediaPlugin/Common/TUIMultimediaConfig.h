// Copyright (c) 2024 Tencent. All rights reserved.
// Created by eddardliu on 2024/10/21.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIMultimediaConfig : NSObject
+ (instancetype)sharedInstance;
- (void)setConfig:(NSString*)jsonString;
- (BOOL)isSupportRecordBeauty;
- (BOOL)isSupportRecordAspect;
- (BOOL)isSupportRecordTorch;
- (BOOL)isSupportRecordScrollFilter;
- (BOOL)isSupportVideoEditGraffiti;
- (BOOL)isSupportVideoEditPaster;
- (BOOL)isSupportVideoEditSubtitle;
- (BOOL)isSupportVideoEditBGM;
- (BOOL)isSupportPictureEditMosaic;
- (BOOL)isSupportPictureEditGraffiti;
- (BOOL)isSupportPictureEditPaster;
- (BOOL)isSupportPictureEditSubtitle;
- (BOOL)isSupportPictureEditCrop;
- (UIColor*)getThemeColor;
- (int)getMaxRecordDurationMs;
- (int)getMinRecordDurationMs;
- (int)getVideoQuality;
- (NSString *)getPicturePasterConfigFilePath;
- (NSString *)getBGMConfigFilePath;
@end

NS_ASSUME_NONNULL_END
