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

@class TUIMediaCollectionCell_Minimalist;

NS_ASSUME_NONNULL_BEGIN

/////////////////////////////////////////////////////////////////////////////////
//
//                   TUIMediaCollectionCellDelegate
//
/////////////////////////////////////////////////////////////////////////////////

@protocol TUIMediaCollectionCellDelegate_Minimalist <NSObject>
/**
 *  meida cell 
 */
- (void)onCloseMedia:(TUIMediaCollectionCell_Minimalist *)cell;
@end

@interface TUIMediaCollectionCell_Minimalist : UICollectionViewCell

@property(nonatomic, strong) UIImageView *imageView;
@property(nonatomic, strong) UIButton *downloadBtn;

@property(nonatomic, weak) id<TUIMediaCollectionCellDelegate_Minimalist> delegate;
- (void)fillWithData:(TUIMessageCellData *)data;
@end

NS_ASSUME_NONNULL_END
