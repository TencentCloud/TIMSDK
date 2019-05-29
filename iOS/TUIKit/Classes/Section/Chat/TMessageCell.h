//
//  TMessageCell.h
//  UIKit
//
//  Created by kennethmiao on 2018/9/17.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^TDownloadProgress)(NSInteger curSize, NSInteger totalSize);
typedef void (^TDownloadResponse)(int code, NSString *desc, NSString *path);

typedef NS_ENUM(NSUInteger, TMsgStatus) {
    Msg_Status_Sending,
    Msg_Status_Sending_2,
    Msg_Status_Succ,
    Msg_Status_Fail,
};

@interface TMessageCellData : NSObject
@property (nonatomic, strong) NSString *head;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) BOOL showName;
@property (nonatomic, assign) BOOL isSelf;
@property (nonatomic, assign) TMsgStatus status;
@property (nonatomic, strong) id custom;
@end

@class TMessageCell;
@protocol TMessageCellDelegate <NSObject>
- (void)didLongPressMessage:(TMessageCellData *)data inView:(UIView *)view;
- (void)didReSendMessage:(TMessageCellData *)data;
- (void)didSelectMessage:(TMessageCellData *)data;
- (void)needReloadMessage:(TMessageCellData *)data;
@end

@interface TMessageCell : UITableViewCell
@property (nonatomic, strong) UIImageView *head;
@property (nonatomic, strong) UILabel *name;
@property (nonatomic, strong) UIView *container;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, strong) UIImageView *error;
@property (nonatomic, strong, readonly) TMessageCellData *data;
@property (nonatomic, weak) id<TMessageCellDelegate> delegate;
- (CGFloat)getHeight:(TMessageCellData *)data;
- (CGSize)getContainerSize:(TMessageCellData *)data;
- (void)setData:(TMessageCellData *)data;
- (void)setupViews;
@end
