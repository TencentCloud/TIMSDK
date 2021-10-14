//
//  TCMusicSelectCell.h
//  TCAudioSettingKit
//
//  Created by abyyxwang on 2020/5/28.
//  Copyright © 2020 tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class TCMusicSelectedModel;
@interface TCMusicSelectCell : UITableViewCell

- (void)setupCellWithModel:(TCMusicSelectedModel *)model;

@end

NS_ASSUME_NONNULL_END
