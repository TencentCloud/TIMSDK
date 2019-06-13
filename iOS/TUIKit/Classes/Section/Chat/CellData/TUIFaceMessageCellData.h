//
//  TFaceMessageCellData.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/21.
//

#import "TUIMessageCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIFaceMessageCellData : TUIMessageCellData

@property (nonatomic, assign) NSInteger groupIndex;
@property (nonatomic, strong) NSString *path;
@property (nonatomic, strong) NSString *faceName;

@end

NS_ASSUME_NONNULL_END
