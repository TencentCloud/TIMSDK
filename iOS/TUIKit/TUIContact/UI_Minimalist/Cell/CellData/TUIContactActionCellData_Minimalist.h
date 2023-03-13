//
//  TUIContactActionCellData_Minimalist.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/6/21.
//

#import "TUICommonModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIContactActionCellData_Minimalist : TUICommonCellData

@property NSString *title;
@property UIImage *icon;
@property NSInteger readNum;

@property (nonatomic,assign) BOOL needBottomLine;

@end

NS_ASSUME_NONNULL_END
