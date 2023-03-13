//
//  TUIGroupNoteTipsCell.h
//  TUIChat
//
//  Created by xia on 2023/2/20.
//

#import "TUISystemMessageCell.h"
#import "TUIGroupNoteTipsCellData.h"

NS_ASSUME_NONNULL_BEGIN

@interface TUIGroupNoteTipsCell : TUISystemMessageCell

- (void)fillWithData:(TUIGroupNoteTipsCellData *)data;

@end

NS_ASSUME_NONNULL_END
