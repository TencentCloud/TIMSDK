//
//  TUIImageMessageCell.h
//  UIKit
//
//  Created by annidyfeng on 2019/5/30.
//

#import "TUIMessageCell.h"
#import "TUIImageMessageCellData.h"

@interface TUIImageMessageCell : TUIMessageCell
@property (nonatomic, strong) UIImageView *thumb;
@property (nonatomic, strong) UILabel *progress;
@property TUIImageMessageCellData *imageData;
- (void)fillWithData:(TUIImageMessageCellData *)data;
@end
