//
//  TUIReactPopEmojiView.m
//  TUIChat
//
//  Created by wyl on 2022/4/20.
//  Copyright © 2023 Tencent. All rights reserved.
//

#import "TUIReactPopEmojiView.h"
#import <TIMCommon/NSString+TUIEmoji.h>
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>
#import <TUIChat/TUIChatPopMenu.h>
#import <TIMCommon/TIMCommonMediator.h>
#import <TIMCommon/TUIEmojiMeditorProtocol.h>
#import "TUIMessageCellData+Reaction.h"

@interface TUIReactPopEmojiView ()

@end
@implementation TUIReactPopEmojiView

- (CGSize)collectionView:(UICollectionView *)collectionView
                    layout:(UICollectionViewLayout *)collectionViewLayout
    sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    int groupIndex = [self.groupIndexInSection[indexPath.section] intValue];
    TUIFaceGroup *group = self.faceGroups[groupIndex];
    CGFloat width = (self.frame.size.width - TChatEmojiView_Padding * 2 - TChatEmojiView_Margin * (group.itemCountPerRow - 1)) / group.itemCountPerRow;

    CGFloat height = (collectionView.frame.size.height - TChatEmojiView_MarginTopBottom * (group.rowCount - 1)) / group.rowCount;
    return CGSizeMake(width, height);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self defaultLayout];
    [self updateFrame];
    [self updateCorner];
}

- (void)defaultLayout {
    self.faceFlowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self.faceFlowLayout.minimumLineSpacing = TChatEmojiView_Margin;
    self.faceFlowLayout.minimumInteritemSpacing = TChatEmojiView_MarginTopBottom;
    self.faceFlowLayout.sectionInset = UIEdgeInsetsMake(0, TChatEmojiView_Padding, 0, TChatEmojiView_Padding);
    self.faceCollectionView.collectionViewLayout = self.faceFlowLayout;
}

- (void)updateFrame {
    self.faceCollectionView.frame = CGRectMake(0, TChatEmojiView_CollectionOffsetY, self.frame.size.width, TChatEmojiView_CollectionHeight);
    self.pageControl.frame =
        CGRectMake(0, TChatEmojiView_CollectionOffsetY + self.faceCollectionView.frame.size.height, self.frame.size.width, TChatEmojiView_Page_Height);
}

- (void)updateCorner {
    UIRectCorner corner = UIRectCornerBottomLeft | UIRectCornerBottomRight;
    CGRect bounds = CGRectMake(self.bounds.origin.x, self.bounds.origin.y - 1, self.bounds.size.width, self.bounds.size.height);
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:bounds byRoundingCorners:corner cornerRadii:CGSizeMake(5, 5)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}
- (void)setData:(NSMutableArray *)data {
    [super setData:data];
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TUIFaceCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:TFaceCell_ReuseId forIndexPath:indexPath];
    cell.face.contentMode = UIViewContentModeScaleAspectFill;
    int groupIndex = [self.groupIndexInSection[indexPath.section] intValue];
    TUIFaceGroup *group = self.faceGroups[groupIndex];
    int itemCount = group.rowCount * group.itemCountPerRow;
    if (indexPath.row == itemCount - 1 && group.needBackDelete) {
        TUIFaceCellData *data = [[TUIFaceCellData alloc] init];
        data.path = TUIChatFaceImagePath(@"del_normal");
        [cell setData:data];
        cell.face.image  = [cell.face.image rtl_imageFlippedForRightToLeftLayoutDirection];
    } else {
        NSNumber *index = [self.itemIndexs objectForKey:indexPath];
        if (index.integerValue < group.faces.count) {
            TUIFaceCellData *data = group.faces[index.integerValue];
            [cell setData:data];
        } else {
            [cell setData:nil];
        }
    }
    cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, kTIMDefaultEmojiSize.width, kTIMDefaultEmojiSize.height);
    cell.face.frame = CGRectMake(cell.face.frame.origin.x, cell.face.frame.origin.y, kTIMDefaultEmojiSize.width, kTIMDefaultEmojiSize.height);;
    return cell;
}


- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    int groupIndex = [self.groupIndexInSection[indexPath.section] intValue];
    TUIFaceGroup *faces = self.faceGroups[groupIndex];
    int itemCount = faces.rowCount * faces.itemCountPerRow;
    NSNumber *index = [self.itemIndexs objectForKey:indexPath];
    if (index.integerValue < faces.faces.count) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index.integerValue inSection:groupIndex];
        [self faceView:self didSelectItemAtIndexPath:indexPath];
    }
}
- (void)faceView:(TUIFaceView *)faceView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    TUIFaceGroup *group = faceView.faceGroups[indexPath.section];
    TUIFaceCellData *face = group.faces[indexPath.row];
    if (indexPath.section == 0) {
        NSString *faceName = face.name;
        NSLog(@"FaceName:%@", faceName);
        [self updateRecentMenuQueue:faceName];
        [self updateReactClick:faceName];
        if (self.delegateView) {
            [self.delegateView hideWithAnimation];
        }
    }
}

- (void)updateRecentMenuQueue:(NSString *)faceName {
    id<TUIEmojiMeditorProtocol> service = [[TIMCommonMediator share] getObject:@protocol(TUIEmojiMeditorProtocol)];
    return [service updateRecentMenuQueue:faceName];
}

- (void)updateReactClick:(NSString *)faceName {
    if (self.delegateView.targetCellData) {
        [self.delegateView.targetCellData updateReactClick:faceName];
    }
}
@end
