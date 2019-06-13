//
//  TUIMessageCell.h
//  UIKit
//
//  Created by kennethmiao on 2018/9/17.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TUIMessageCellData.h"

typedef void (^TDownloadProgress)(NSInteger curSize, NSInteger totalSize);
typedef void (^TDownloadResponse)(int code, NSString *desc, NSString *path);



@class TUIMessageCell;
@protocol TMessageCellDelegate <NSObject>
- (void)onLongPressMessage:(TUIMessageCell *)cell;
- (void)onRetryMessage:(TUIMessageCell *)cell;
- (void)onSelectMessage:(TUIMessageCell *)cell;
@end

@interface TUIMessageCell : TCommonTableViewCell
@property (nonatomic, strong) UIImageView *avatarView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, strong) UIImageView *retryView;
@property (readonly) TUIMessageCellData *messageData;
@property (nonatomic, weak) id<TMessageCellDelegate> delegate;

- (void)fillWithData:(TCommonCellData *)data;
@end
