//
//  TFaceView.h
//  UIKit
//
//  Created by kennethmiao on 2018/9/18.
//  Copyright © 2018年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TFaceView;
@protocol TFaceViewDelegate <NSObject>
- (void)faceView:(TFaceView *)faceView scrollToFaceGroupIndex:(NSInteger)index;
- (void)faceView:(TFaceView *)faceView didSelectItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)faceViewDidBackDelete:(TFaceView *)faceView;
@end

@interface TFaceGroup : NSObject
@property (nonatomic, assign) int groupIndex;
@property (nonatomic, strong) NSString *groupPath;
@property (nonatomic, assign) int rowCount;
@property (nonatomic, assign) int itemCountPerRow;
@property (nonatomic, strong) NSMutableArray *faces;
@property (nonatomic, assign) BOOL needBackDelete;
@property (nonatomic, strong) NSString *menuPath;
@end

@interface TFaceView : UIView
@property (nonatomic, strong) UIView *lineView;
@property (nonatomic, strong) UICollectionView *faceCollectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *faceFlowLayout;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, weak) id<TFaceViewDelegate> delegate;
- (void)scrollToFaceGroupIndex:(NSInteger)index;
- (void)setData:(NSMutableArray *)data;
@end
