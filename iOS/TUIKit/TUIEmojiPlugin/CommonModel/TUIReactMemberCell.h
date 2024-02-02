//
//  TUIReactMemberCell.h
//  TUIChat
//
//  Created by wyl on 2022/5/26.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TUIReactMemberCellData;

NS_ASSUME_NONNULL_BEGIN

@interface TUIReactMemberCell : UITableViewCell

- (void)fillWithData:(TUIReactMemberCellData *)data;

@end

NS_ASSUME_NONNULL_END
