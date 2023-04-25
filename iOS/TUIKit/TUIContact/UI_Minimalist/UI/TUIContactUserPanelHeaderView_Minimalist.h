//
//  TUIContactUserPanelHeaderView_Minimalist.h
//  TUIContact
//
//  Created by wyl on 2023/1/18.
//

#import <UIKit/UIKit.h>
#import <TIMCommon/TIMCommonModel.h>
#import <TIMCommon/TIMDefine.h>

NS_ASSUME_NONNULL_BEGIN

@interface TUIContactPanelCell_Minimalist : UICollectionViewCell
- (void)fillWithData:(TUICommonContactSelectCellData *)model;
@end

@interface TUIContactUserPanelHeaderView_Minimalist : UIView <UICollectionViewDelegate,UICollectionViewDataSource>
@property(nonatomic,strong) UICollectionView *userPanel;
@property (nonatomic,copy) void(^clickCallback)(void);
@property(nonatomic,strong) NSMutableArray <TUICommonContactSelectCellData *>*selectedUsers;
@property(nonatomic,assign) CGFloat topStartPosition;
@property(nonatomic,assign) CGFloat userPanelWidth;
@property(nonatomic,assign) CGFloat userPanelHeight;
@property(nonatomic,assign) CGFloat realSpacing;
@property(nonatomic,assign) NSInteger userPanelColumnCount;
@property(nonatomic,assign) NSInteger userPanelRowCount;

@end

NS_ASSUME_NONNULL_END
