//
//  TUIContactActionCellData.h
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/6/21.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <TIMCommon/TIMCommonModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIContactActionCellData : TUICommonCellData

@property NSString *title;
@property UIImage *icon;
@property NSInteger readNum;

@end

NS_ASSUME_NONNULL_END
