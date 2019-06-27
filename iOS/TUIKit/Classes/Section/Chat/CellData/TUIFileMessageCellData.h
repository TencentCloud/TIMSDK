//
//  TUIFileMessageCellData.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/21.
//

#import "TUIMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIFileMessageCellData : TUIMessageCellData

@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *fileName;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, assign) int length;
@property (nonatomic, assign) NSUInteger uploadProgress;
@property (nonatomic, assign) NSUInteger downladProgress;
@property (nonatomic, assign) BOOL isDownloading;
- (void)downloadFile;
- (BOOL)isLocalExist;

- (NSString *)getFilePath:(BOOL *)isExist;

@end

NS_ASSUME_NONNULL_END
