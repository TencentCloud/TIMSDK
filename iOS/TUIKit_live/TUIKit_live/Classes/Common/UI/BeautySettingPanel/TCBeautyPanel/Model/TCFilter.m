// Copyright (c) 2019 Tencent. All rights reserved.

#import "TCFilter.h"

TCFilterIdentifier const TCFilterIdentifierNone      = @"";
TCFilterIdentifier const TCFilterIdentifierBaiXi     = @"baixi";
TCFilterIdentifier const TCFilterIdentifierNormal    = @"normal";
TCFilterIdentifier const TCFilterIdentifierZiRan     = @"ziran";
TCFilterIdentifier const TCFilterIdentifierYinghong  = @"yinghong";
TCFilterIdentifier const TCFilterIdentifierYunshang  = @"yunshang";
TCFilterIdentifier const TCFilterIdentifierChunzhen  = @"chunzhen";
TCFilterIdentifier const TCFilterIdentifierBailan    = @"bailan";
TCFilterIdentifier const TCFilterIdentifierYuanqi    = @"yuanqi";
TCFilterIdentifier const TCFilterIdentifierChaotuo   = @"chaotuo";
TCFilterIdentifier const TCFilterIdentifierXiangfen  = @"xiangfen";
TCFilterIdentifier const TCFilterIdentifierWhite     = @"white";
TCFilterIdentifier const TCFilterIdentifierLangman   = @"langman";
TCFilterIdentifier const TCFilterIdentifierQingxin   = @"qingxin";
TCFilterIdentifier const TCFilterIdentifierWeimei    = @"weimei";
TCFilterIdentifier const TCFilterIdentifierFennen    = @"fennen";
TCFilterIdentifier const TCFilterIdentifierHuaijiu   = @"huaijiu";
TCFilterIdentifier const TCFilterIdentifierLandiao   = @"landiao";
TCFilterIdentifier const TCFilterIdentifierQingliang = @"qingliang";
TCFilterIdentifier const TCFilterIdentifierRixi      = @"rixi";

@implementation TCFilter

- (instancetype)initWithIdentifier:(TCFilterIdentifier)identifier
                   lookupImagePath:(NSString *)lookupImagePath
{
    if (self = [super init]) {
        _identifier = identifier;
        _lookupImagePath = lookupImagePath;
    }
    return self;
}
@end

@implementation TCFilterManager
{
    NSDictionary<TCFilterIdentifier, TCFilter*> *_filterDictionary;
}
+ (instancetype)defaultManager
{
    static TCFilterManager *defaultManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultManager = [[TCFilterManager alloc] init];
    });
    return defaultManager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSString *path = [bundle pathForResource:@"FilterResource" ofType:@"bundle"];
        NSFileManager *manager = [[NSFileManager alloc] init];
        if ([manager fileExistsAtPath:path]) {
            NSArray<TCFilterIdentifier> *availableFilters = @[
                TCFilterIdentifierBaiXi,
                TCFilterIdentifierNormal,
                TCFilterIdentifierZiRan,
                TCFilterIdentifierYinghong,
                TCFilterIdentifierYunshang,
                TCFilterIdentifierChunzhen,
                TCFilterIdentifierBailan,
                TCFilterIdentifierYuanqi,
                TCFilterIdentifierChaotuo,
                TCFilterIdentifierXiangfen,
                TCFilterIdentifierWhite,
                TCFilterIdentifierLangman,
                TCFilterIdentifierQingxin,
                TCFilterIdentifierWeimei,
                TCFilterIdentifierFennen,
                TCFilterIdentifierHuaijiu,
                TCFilterIdentifierLandiao,
                TCFilterIdentifierQingliang,
                TCFilterIdentifierRixi];
            NSMutableArray<TCFilter *> *filters = [[NSMutableArray alloc] initWithCapacity:availableFilters.count];
            NSMutableDictionary<TCFilterIdentifier, TCFilter*> *filterMap = [[NSMutableDictionary alloc] initWithCapacity:availableFilters.count];
            for (TCFilterIdentifier identifier in availableFilters) {
                NSString * itemPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", identifier]];
                if ([manager fileExistsAtPath:path]) {
                    TCFilter *filter = [[TCFilter alloc] initWithIdentifier:identifier lookupImagePath:itemPath];
                    [filters addObject:filter];
                    filterMap[identifier] = filter;
                }
            }
            _allFilters = filters;

        }
    }
    return self;
}

- (TCFilter *)filterWithIdentifier:(TCFilterIdentifier)identifier;
{
    return _filterDictionary[identifier];
}
@end
