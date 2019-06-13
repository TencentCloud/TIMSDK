//
//  TUIVideoMessageCell.h
//  UIKit
//
//  Created by annidyfeng on 2019/5/30.
//

#import "TUIMessageCell.h"
#import "TUIVideoMessageCellData.h"

@interface TUIVideoMessageCell : TUIMessageCell
@property (nonatomic, strong) UIImageView *thumb;
@property (nonatomic, strong) UILabel *duration;
@property (nonatomic, strong) UIImageView *play;
@property (nonatomic, strong) UILabel *progress;
//@property (nonatomic, strong) UIActivityIndicatorView *videoIndicator;
@property TUIVideoMessageCellData *videoData;
- (void)fillWithData:(TUIVideoMessageCellData *)data;
@end
