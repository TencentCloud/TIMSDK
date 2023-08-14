
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.

#import <TIMCommon/TIMCommonModel.h>

NS_ASSUME_NONNULL_BEGIN

@class TUIMemberCellData;
@interface TUIMemberCell : TUICommonTableViewCell

- (void)fillWithData:(TUIMemberCellData *)cellData;

@end

NS_ASSUME_NONNULL_END
