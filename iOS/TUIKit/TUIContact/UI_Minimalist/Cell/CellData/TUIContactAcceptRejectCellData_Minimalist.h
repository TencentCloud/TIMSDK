//
//  TUIContactAcceptRejectCellData_Minimalist.h
//  TUIContact
//
//  Created by wyl on 2023/1/5.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIContactAcceptRejectCellData_Minimalist : TUICommonCellData
@property(nonatomic, copy) void (^agreeClickCallback)(void);
@property(nonatomic, copy) void (^rejectClickCallback)(void);
@property(nonatomic, assign) BOOL isAccepted;
@property(nonatomic, assign) BOOL isRejected;

@end

NS_ASSUME_NONNULL_END
