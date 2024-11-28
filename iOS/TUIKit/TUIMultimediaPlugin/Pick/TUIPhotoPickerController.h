//
//  TUIPhotoPickerController.h
//  TUIPhotoPickerController
//
//  Created by lynx on 2024/8/21.
//  Copyright © 2024 Tencent. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <TUIMultimediaCore/TUIAssetModel.h>
@interface TUIPhotoPickerController : UIViewController

@property (nonatomic, assign) BOOL isFirstAppear;
@property (nonatomic, assign) NSInteger columnNumber;
@property (nonatomic, strong) TUIAlbumModel *albumModel;//默认选中的类别 bucket
@property (nonatomic, strong) NSMutableArray *assetModels;//该类别下所有的照片
@end
