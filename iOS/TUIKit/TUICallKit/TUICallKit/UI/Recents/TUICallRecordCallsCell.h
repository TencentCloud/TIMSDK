//
//  TUICallRecordCallsCell.h
//  TUICallKit
//
//  Created by noah on 2023/2/28.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TUICallRecordCallsCell, TUICallRecordCallsCellViewModel;

NS_ASSUME_NONNULL_BEGIN

typedef void(^TUICallRecordCallsCellMoreBtnClickedHandler)(TUICallRecordCallsCell *recordCallsCell);

@interface TUICallRecordCallsCell : UITableViewCell

@property (nonatomic, readwrite, copy) TUICallRecordCallsCellMoreBtnClickedHandler moreBtnClickedHandler;

- (void)bindViewModel:(TUICallRecordCallsCellViewModel *)viewModel;

@end

NS_ASSUME_NONNULL_END
