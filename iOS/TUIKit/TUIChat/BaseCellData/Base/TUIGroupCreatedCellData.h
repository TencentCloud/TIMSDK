
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
/**
 *
 *  This file declares the data source for TUIGroupCreatedCell
 */

#import <TIMCommon/TUISystemMessageCellData.h>

@interface TUIGroupCreatedCellData : TUISystemMessageCellData

@property(nonatomic, copy) NSString *opUser;
@property(nonatomic, strong) NSNumber *cmd;

@end
