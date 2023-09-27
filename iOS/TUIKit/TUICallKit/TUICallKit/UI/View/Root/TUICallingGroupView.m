//
//  TUICallingGroupView.m
//  TUICalling
//
//  Created by noah on 2022/5/16.
//  Copyright © 2022 Tencent. All rights reserved
//

#import "TUICallingGroupView.h"
#import "TUICallingUserView.h"
#import "TUICallingGroupDelegateManager.h"
#import "TUIDefine.h"
#import "Masonry.h"
#import "TUILogin.h"
#import "TUICallEngineHeader.h"
#import "TUICallingUserModel.h"
#import "TUICallingStatusManager.h"

@interface TUICallingGroupView ()

@property (nonatomic, strong) TUICallingGroupDelegateManager *delegateManager;
@property (nonatomic, strong) UICollectionView *groupCollectionView;
@property (nonatomic, strong) NSMutableArray<CallingUserModel *> *userList;
/// Calling Media Type
@property (nonatomic, assign) TUICallMediaType callType;
/// Calling Role
@property (nonatomic, assign) TUICallRole callRole;
@property (nonatomic, assign) BOOL isCloseCamera;
@property (nonatomic, strong) TUICallingVideoRenderView *localPreView;

@end

@implementation TUICallingGroupView

- (instancetype)initWithFrame:(CGRect)frame localPreView:(TUICallingVideoRenderView *)localPreView {
    self = [super initWithFrame:[UIScreen mainScreen].bounds];
    if (self) {
        self.userList = [NSMutableArray array];
        self.localPreView = localPreView;
        [self setupCallingGroupUI];
    }
    return self;
}

- (void)setupCallingGroupUI {
    self.backgroundColor = [UIColor t_colorWithHexString:@"#242424"];
    [self addSubview:self.groupCollectionView];
    self.localPreView.hidden = NO;
    
    [self.groupCollectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(StatusBar_Height + 38);
        make.centerX.equalTo(self);
        make.width.height.mas_equalTo(self.bounds.size.width);
    }];
    
    for (int i = 0; i < 9; i++) {
        [self.groupCollectionView registerClass:NSClassFromString(@"TUICallingGroupCell") forCellWithReuseIdentifier:[NSString stringWithFormat:@"TUICallingGroupCell_%d", i]];
    }
}

#pragma mark - BaseCallViewProtocol

- (void)updateViewWithUserList:(NSArray<CallingUserModel *> *)userList
                       sponsor:(CallingUserModel *)sponsor
                      callType:(TUICallMediaType)callType
                      callRole:(TUICallRole)callRole {
    if (userList) {
        [self.userList removeAllObjects];
        [self.userList addObjectsFromArray:userList];
    }
    
    self.callType = callType;
    self.callRole = callRole;
    
    [self.delegateManager reloadCallingGroupWithModel:self.userList];
    [self.groupCollectionView reloadData];
    [self.groupCollectionView layoutIfNeeded];
    
    [self handleLocalRenderView];
}

- (void)userAdd:(CallingUserModel *)userModel {
    [self userAdd:userModel succ:nil];
}

- (void)userAdd:(CallingUserModel *)userModel succ:(TUICallSucc)succ {
    if (!userModel) {
        return;
    }
    NSInteger index = self.userList.count;
    [self.groupCollectionView performBatchUpdates:^{
        [self.userList insertObject:userModel atIndex:index];
        [self.groupCollectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
        [self.delegateManager reloadCallingGroupWithModel:self.userList];
        if (succ) {
            succ();
        }
    } completion:^(BOOL finished) {
        [self handleLocalRenderView];
    }];
}

- (void)userEnter:(CallingUserModel *)userModel {
    if (!userModel) {
        return;
    }
    __block NSInteger index = [self getIndexForUser:userModel.userId];
    if (index < 0) {
        __weak typeof(self) weakSelf = self;
        [self userAdd:userModel succ:^{
            __strong typeof(self) strongSelf = weakSelf;
            index = strongSelf.userList.count - 1;
            [strongSelf reloadGroupCell:userModel index:index];
        }];
        return;
    }
    [self reloadGroupCell:userModel index:index];
}

- (void)reloadGroupCell:(CallingUserModel *)userModel index:(NSInteger)index {
    userModel.isEnter = YES;
    self.userList[index] = userModel;
    [self.delegateManager reloadCallingGroupWithModel:self.userList];
    [self.delegateManager reloadGroupCellWithIndex:index];
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView *renderView = [self.delegateManager getRenderViewFromUser:userModel.userId];
        [self startRemoteView:userModel.userId view:renderView];
        [self handleLocalRenderView];
    });
}

- (void)userLeave:(CallingUserModel *)userModel {
    NSInteger index = [self getIndexForUser:userModel.userId];
    if (index < 0) {
        return;
    }
    
    if (self.callType == TUICallMediaTypeVideo) {
        [self stopRemoteView:userModel.userId];
    }
    
    [self.groupCollectionView performBatchUpdates:^{
        [self.groupCollectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
        [self.userList removeObjectAtIndex:index];
        [self.delegateManager reloadCallingGroupWithModel:self.userList];
    } completion:^(BOOL finished) {
        [self handleLocalRenderView];
    }];
}

- (void)updateUserInfo:(CallingUserModel *)userModel {
    NSInteger index = [self getIndexForUser:userModel.userId];
    if (index < 0) {
        return;
    }
    
    self.userList[index] = userModel;
    [self.delegateManager reloadCallingGroupWithModel:self.userList];
    [self.delegateManager reloadGroupCellWithIndex:index];
}

- (void)updateCameraOpenStatus:(BOOL)isOpen {
    BOOL isCloseCamera = !isOpen;
    
    if (_isCloseCamera != isCloseCamera) {
        _isCloseCamera = isCloseCamera;
        [self handleLocalRenderView];
    }
}

#pragma mark - Action Event

- (void)startRemoteView:(NSString *)userId view:(UIView *)view {
    if (self.callType != TUICallMediaTypeVideo) {
        return;
    }
    [TUICallingAction startRemoteView:userId videoView:view onPlaying:nil onLoading:nil onError:nil];
}

- (void)stopRemoteView:(NSString *)userId {
    [TUICallingAction stopRemoteView:userId];
}

#pragma mark - Private

- (void)handleLocalRenderView {
    if ((self.callType != TUICallMediaTypeVideo) || (TUICallStatusNone == [TUICallingStatusManager shareInstance].callStatus)) {
        return;
    }
    
    NSInteger index = [self getIndexForUser:[TUILogin getUserID]];
    if (index >= 0) {
        CallingUserModel *currentUser = self.userList[index];
        TUIVideoView *localRenderView = [self.delegateManager getRenderViewFromUser:[TUILogin getUserID]];
        self.localPreView.frame = localRenderView.frame;
        [localRenderView addSubview:self.localPreView];
        if (!self.isCloseCamera && localRenderView != nil) {
            [TUICallingAction openCamera:TUICameraFront videoView:self.localPreView];
        }
        
        currentUser.isVideoAvailable = !self.isCloseCamera;
        currentUser.isEnter = YES;
        currentUser.isAudioAvailable = YES;
        [self updateUserInfo:currentUser];
    }
}

- (NSInteger)getIndexForUser:(NSString *)userId {
    if (!(userId && [userId isKindOfClass:NSString.class])) {
        return -1;
    }
    
    __block NSInteger index = -1;
    [self.userList enumerateObjectsUsingBlock:^(CallingUserModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.userId isEqualToString:userId]) {
            index = idx;
            *stop = YES;
        }
    }];
    return index;
}

#pragma mark - Lazy

- (TUICallingGroupDelegateManager *)delegateManager {
    if (!_delegateManager) {
        _delegateManager = [[TUICallingGroupDelegateManager alloc] init];
    }
    return _delegateManager;
}

- (UICollectionView *)groupCollectionView {
    if (!_groupCollectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = 0;
        flowLayout.minimumInteritemSpacing = 0;
        _groupCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _groupCollectionView.delegate = self.delegateManager;
        _groupCollectionView.dataSource = self.delegateManager;
        self.delegateManager.collectionView = _groupCollectionView;
        _groupCollectionView.showsVerticalScrollIndicator = NO;
        _groupCollectionView.showsHorizontalScrollIndicator = NO;
        _groupCollectionView.backgroundColor = [UIColor clearColor];
    }
    return _groupCollectionView;
}

- (void)dealloc {
    NSLog(@"%s",__func__);
}

@end
