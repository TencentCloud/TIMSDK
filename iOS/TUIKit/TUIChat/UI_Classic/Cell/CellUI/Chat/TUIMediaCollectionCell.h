//
//  TUIMediaCollectionCell.h
//  TUIChat
//
//  Created by xiangzhang on 2021/11/22.
//

#import <UIKit/UIKit.h>
#import <TIMCommon/TUIMessageCellData.h>
#import <Photos/Photos.h>

@class TUIMediaCollectionCell;

NS_ASSUME_NONNULL_BEGIN

/////////////////////////////////////////////////////////////////////////////////
//
//                              TUIMediaCollectionCellDelegate
//
/////////////////////////////////////////////////////////////////////////////////

@protocol TUIMediaCollectionCellDelegate <NSObject>
/**
 *  meida cell 被点击回调
 */
- (void)onCloseMedia:(TUIMediaCollectionCell *)cell;
@end

@interface TUIMediaCollectionCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property(nonatomic,strong) UIButton *downloadBtn;

@property(nonatomic, weak) id<TUIMediaCollectionCellDelegate> delegate;
- (void)fillWithData:(TUIMessageCellData *)data;
@end

NS_ASSUME_NONNULL_END
