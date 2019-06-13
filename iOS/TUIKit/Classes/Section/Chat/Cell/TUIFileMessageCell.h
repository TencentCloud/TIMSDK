//
//  TFileMessageCell.h
//  UIKit
//
//  Created by annidyfeng on 2019/5/30.
//

#import "TUIMessageCell.h"
#import "TUIFileMessageCellData.h"


@interface TUIFileMessageCell : TUIMessageCell
@property (nonatomic, strong) UIImageView *bubble;
@property (nonatomic, strong) UILabel *fileName;
@property (nonatomic, strong) UILabel *length;
@property (nonatomic, strong) UILabel *progress;
@property (nonatomic, strong) UIImageView *image;
@property TUIFileMessageCellData *fileData;
- (void)fillWithData:(TUIFileMessageCellData *)data;
@end
