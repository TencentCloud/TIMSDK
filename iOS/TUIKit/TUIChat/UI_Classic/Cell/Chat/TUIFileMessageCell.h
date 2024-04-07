
//  Created by Tencent on 2023/06/09.
//  Copyright © 2023 Tencent. All rights reserved.
#import <TIMCommon/TUIBubbleMessageCell.h>
#import <TIMCommon/TUIMessageCell.h>
#import "TUIFileMessageCellData.h"

@interface TUIFileMessageCell : TUIMessageCell

/**

 *  File bubble view, used to wrap messages on the UI
 */
@property(nonatomic, strong) UIImageView *bubble;

/**
 *  Label for displaying filename
 *  As the main label of the file message, it displays the file information (including the suffix).
 */
@property(nonatomic, strong) UILabel *fileName;

/**
 *  Label for displaying file size
 *  As the secondary label of the file message, it further displays the secondary information of the file.
 */
@property(nonatomic, strong) UILabel *length;

/**
 *  File icon
 */
@property(nonatomic, strong) UIImageView *image;

@property TUIFileMessageCellData *fileData;

- (void)fillWithData:(TUIFileMessageCellData *)data;
@end
