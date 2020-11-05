// Copyright (c) 2019 Tencent. All rights reserved.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSString * TCFilterIdentifier NS_STRING_ENUM;

extern TCFilterIdentifier const TCFilterIdentifierNone;
extern TCFilterIdentifier const TCFilterIdentifierBaiXi;
extern TCFilterIdentifier const TCFilterIdentifierNormal;
extern TCFilterIdentifier const TCFilterIdentifierZiRan;
extern TCFilterIdentifier const TCFilterIdentifierYinghong;
extern TCFilterIdentifier const TCFilterIdentifierYunshang;
extern TCFilterIdentifier const TCFilterIdentifierChunzhen;
extern TCFilterIdentifier const TCFilterIdentifierBailan;
extern TCFilterIdentifier const TCFilterIdentifierYuanqi;
extern TCFilterIdentifier const TCFilterIdentifierChaotuo;
extern TCFilterIdentifier const TCFilterIdentifierXiangfen;
extern TCFilterIdentifier const TCFilterIdentifierWhite;
extern TCFilterIdentifier const TCFilterIdentifierLangman;
extern TCFilterIdentifier const TCFilterIdentifierQingxin;
extern TCFilterIdentifier const TCFilterIdentifierWeimei;
extern TCFilterIdentifier const TCFilterIdentifierFennen;
extern TCFilterIdentifier const TCFilterIdentifierHuaijiu;
extern TCFilterIdentifier const TCFilterIdentifierLandiao;
extern TCFilterIdentifier const TCFilterIdentifierQingliang;
extern TCFilterIdentifier const TCFilterIdentifierRixi;

@interface TCFilter : NSObject
@property (readonly, nonatomic) TCFilterIdentifier identifier;
@property (readonly, nonatomic) NSString *lookupImagePath;
@end

@interface TCFilterManager : NSObject
+ (instancetype)defaultManager;
@property (readonly, nonatomic) NSArray<TCFilter *> *allFilters;
- (TCFilter *)filterWithIdentifier:(TCFilterIdentifier)identifier;
@end

NS_ASSUME_NONNULL_END
