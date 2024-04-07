//
//  TUIMediaCollectionCell.h
//  TUIChat
//
//  Created by xiangzhang on 2021/11/22.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import <Photos/Photos.h>
#import <TIMCommon/TUIMessageCellData.h>
#import <UIKit/UIKit.h>

@class TUIMediaCollectionCell;

NS_ASSUME_NONNULL_BEGIN

/////////////////////////////////////////////////////////////////////////////////
//
//                              TUIMediaCollectionCellDelegate
//
/////////////////////////////////////////////////////////////////////////////////

@protocol TUIMediaCollectionCellDelegate <NSObject>
/**
 *  meida cell 
 */
- (void)onCloseMedia:(TUIMediaCollectionCell *)cell;
@end

@interface TUIMediaCollectionCell : UICollectionViewCell

@property(nonatomic, strong) UIImageView *imageView;
@property(nonatomic, strong) UIButton *downloadBtn;

@property(nonatomic, weak) id<TUIMediaCollectionCellDelegate> delegate;
- (void)fillWithData:(TUIMessageCellData *)data;
@end

NS_ASSUME_NONNULL_END
