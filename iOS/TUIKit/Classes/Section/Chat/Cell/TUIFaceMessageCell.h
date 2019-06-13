//
//  TUIFaceMessageCell.h
//  UIKit
//
//  Created by annidyfeng on 2019/5/30.
//

#import "TUIMessageCell.h"
#import "TUIFaceMessageCellData.h"

@interface TUIFaceMessageCell : TUIMessageCell
@property (nonatomic, strong) UIImageView *face;
@property TUIFaceMessageCellData *faceData;
- (void)fillWithData:(TUIFaceMessageCellData *)data;
@end
