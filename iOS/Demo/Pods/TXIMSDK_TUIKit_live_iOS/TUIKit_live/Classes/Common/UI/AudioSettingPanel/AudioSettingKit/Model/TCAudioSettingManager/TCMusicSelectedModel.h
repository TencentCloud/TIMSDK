//
//  TCMusicSelectedModel.h
//  TCAudioSettingKit
//
//  Created by abyyxwang on 2020/5/28.
//  Copyright © 2020 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^MusicSelectAction)(BOOL);
@interface TCMusicSelectedModel : NSObject

@property (nonatomic, assign) uint32_t musicID;
@property (nonatomic, strong) NSString *musicName;
@property (nonatomic, strong) NSString *singerName;
@property (nonatomic, assign) BOOL isLocal;
@property (nonatomic, strong) NSString *resourceURL;

@property (nonatomic, copy) MusicSelectAction action;

@end

NS_ASSUME_NONNULL_END
