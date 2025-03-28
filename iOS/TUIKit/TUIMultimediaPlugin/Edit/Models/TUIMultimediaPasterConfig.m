// Copyright (c) 2024 Tencent. All rights reserved.
// Author: eddardliu

#import "TUIMultimediaPasterConfig.h"
#import "TUIMultimediaPlugin/NSArray+Functional.h"
#import "TUIMultimediaPlugin/TUIMultimediaCommon.h"
#import "TUIMultimediaPlugin/TUIMultimediaConfig.h"
#import "TUIMultimediaPlugin/TUIMultimediaPersistence.h"

static NSString *const FileCustomPasterConfig = @"liteav_multimedia_paster_config";
static NSString *const PathCustomPasters = @"liteav_multimedia_pasters";

@implementation TUIMultimediaPasterConfig
- (instancetype)init {
    self = [super init];
    _groups = @[];
    return self;
}
+ (TUIMultimediaPasterItemConfig *)loadItemFromJsonDict:(NSDictionary *)groupData {
    NSString *iconPath = groupData[@"item_icon_path"];
    NSString *imagePath = groupData[@"item_image_path"];
    NSNumber *isAddButton = groupData[@"item_is_file_selector"];
    TUIMultimediaPasterItemConfig *item = [[TUIMultimediaPasterItemConfig alloc] init];
    item.iconUrl = [TUIMultimediaCommon getURLByResourcePath:iconPath];
    item.imageUrl = [TUIMultimediaCommon getURLByResourcePath:imagePath];
    item.isAddButton = isAddButton != nil && [isAddButton boolValue];
    item.isUserAdded = NO;
    return item;
}
+ (TUIMultimediaPasterGroupConfig *)loadGroupFromJsonDict:(NSDictionary *)groupData {
    NSString *name = groupData[@"type_name"];
    NSString *iconPath = groupData[@"type_icon_path"];
    NSURL *iconUrl = [TUIMultimediaCommon getURLByResourcePath:iconPath];
    BOOL customizable = NO;
    NSMutableArray<TUIMultimediaPasterItemConfig *> *pasterList = [NSMutableArray array];
    NSArray *itemDataList = groupData[@"paster_item_list"];
    for (NSDictionary *itemData in itemDataList) {
        TUIMultimediaPasterItemConfig *item = [self loadItemFromJsonDict:itemData];
        if (item.isAddButton) {
            customizable = YES;
        }
        [pasterList addObject:item];
    }
    return [[TUIMultimediaPasterGroupConfig alloc] initWithName:name iconUrl:iconUrl itemList:pasterList customizable:customizable];
}
+ (void)loadCustomPasterTo:(TUIMultimediaPasterConfig *)config {
    NSError *err;
    NSString *path = [TUIMultimediaPersistence.basePath stringByAppendingPathComponent:FileCustomPasterConfig];
    NSData *data = [TUIMultimediaPersistence loadDataFromFile:path error:&err];
    NSMutableArray<NSMutableArray<TUIMultimediaPasterItemConfig *> *> *saveList =
        [NSKeyedUnarchiver unarchivedObjectOfClasses:[NSSet setWithArray:@[ NSArray.class, TUIMultimediaPasterItemConfig.class ]] fromData:data error:&err];
    for (int i = 0; i < config.groups.count; i++) {
        NSMutableArray<TUIMultimediaPasterItemConfig *> *itemList = [NSMutableArray arrayWithArray:config.groups[i].itemList];
        [itemList addObjectsFromArray:saveList[i]];
        config.groups[i].itemList = itemList;
    }
}
+ (TUIMultimediaPasterConfig *)loadConfig {
    NSData *jsonData = [NSData dataWithContentsOfFile:[TUIMultimediaCommon.bundle pathForResource:[[TUIMultimediaConfig sharedInstance] getPicturePasterConfigFilePath] ofType:@"json"]];
    NSError *err = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if (err || ![dic isKindOfClass:[NSDictionary class]]) {
        NSLog(@"[TUIMultimedia] Json parse failed: %@", err);
        return nil;
    }
    NSArray *groupListData = dic[@"paster_type_list"];
    NSMutableArray<TUIMultimediaPasterGroupConfig *> *groups = [NSMutableArray array];
    for (NSDictionary *jsonGroup in groupListData) {
        [groups addObject:[self loadGroupFromJsonDict:jsonGroup]];
    }
    TUIMultimediaPasterConfig *config = [[TUIMultimediaPasterConfig alloc] init];
    config.groups = groups;
    [self loadCustomPasterTo:config];
    return config;
}

+ (void)saveConfig:(TUIMultimediaPasterConfig *)config {
    NSMutableArray<NSMutableArray<TUIMultimediaPasterItemConfig *> *> *saveList = [NSMutableArray array];
    for (TUIMultimediaPasterGroupConfig *g in config.groups) {
        NSMutableArray<TUIMultimediaPasterItemConfig *> *list = [NSMutableArray array];
        [saveList addObject:list];
        if (g.customizable) {
            for (TUIMultimediaPasterItemConfig *item in g.itemList) {
                if (item.isUserAdded) {
                    [list addObject:item];
                }
            }
        }
    }
    NSError *err;
    NSString *path = [TUIMultimediaPersistence.basePath stringByAppendingPathComponent:FileCustomPasterConfig];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:saveList requiringSecureCoding:YES error:&err];
    [TUIMultimediaPersistence saveData:data toFile:path error:nil];
}

+ (NSURL *)saveCustomPaster:(UIImage *)img {
    NSString *pastersDir = [TUIMultimediaPersistence.basePath stringByAppendingPathComponent:PathCustomPasters];
    NSString *file = [pastersDir stringByAppendingPathComponent:[NSUUID UUID].UUIDString];
    [TUIMultimediaPersistence saveData:UIImagePNGRepresentation(img) toFile:file error:nil];
    return [NSURL fileURLWithPath:file];
}

+ (void)removeCustomPaster:(TUIMultimediaPasterItemConfig *)paster {
    if (!paster.isUserAdded) {
        return;
    }
    if (paster.iconUrl != nil && ![paster.iconUrl.absoluteString containsString:TUIMultimediaCommon.bundle.resourceURL.absoluteString]) {
        [NSFileManager.defaultManager removeItemAtURL:paster.iconUrl error:nil];
    }
    if (paster.imageUrl != nil && ![paster.imageUrl.absoluteString containsString:TUIMultimediaCommon.bundle.resourceURL.absoluteString]) {
        [NSFileManager.defaultManager removeItemAtURL:paster.imageUrl error:nil];
    }
}

@end

@interface TUIMultimediaPasterGroupConfig () {
    UIImage *_cachedIcon;
}
@end

@implementation TUIMultimediaPasterGroupConfig
- (instancetype)initWithName:(NSString *)name
                     iconUrl:(nullable NSURL *)iconUrl
                    itemList:(NSArray<TUIMultimediaPasterItemConfig *> *)itemList
                customizable:(BOOL)customizable {
    self = [super init];
    _name = name;
    _iconUrl = iconUrl;
    _itemList = itemList;
    _customizable = customizable;
    return self;
}
- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_name forKey:@"name"];
    [coder encodeObject:_iconUrl forKey:@"iconUrl"];
    [coder encodeObject:_itemList forKey:@"itemList"];
    [coder encodeBool:_customizable forKey:@"customizable"];
}
- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    _name = [coder decodeObjectOfClass:NSString.class forKey:@"name"];
    _iconUrl = [coder decodeObjectOfClass:NSURL.class forKey:@"iconUrl"];
    _itemList = [coder decodeObjectOfClasses:[NSSet setWithObjects:NSArray.class, TUIMultimediaPasterItemConfig.class, nil] forKey:@"itemList"];
    _customizable = [coder decodeBoolForKey:@"customizable"];
    return self;
}
+ (BOOL)supportsSecureCoding {
    return YES;
}
- (UIImage *)loadIcon {
    if (_cachedIcon != nil) {
        return _cachedIcon;
    }
    _cachedIcon = [UIImage imageWithData:[NSData dataWithContentsOfURL:_iconUrl]];
    return _cachedIcon;
}
@end

@interface TUIMultimediaPasterItemConfig () {
    UIImage *_cachedImage;
    UIImage *_cachedIcon;
}
@end
@implementation TUIMultimediaPasterItemConfig

- (UIImage *)loadImage {
    if (_cachedImage != nil) {
        return _cachedImage;
    }
    _cachedImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:_imageUrl]];
    return _cachedImage;
}
- (UIImage *)loadIcon {
    if (_iconUrl == nil) {
        return [self loadImage];
    }
    if (_cachedIcon != nil) {
        return _cachedIcon;
    }
    _cachedIcon = [UIImage imageWithData:[NSData dataWithContentsOfURL:_iconUrl]];
    return _cachedIcon;
}
- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:_imageUrl forKey:@"imageUrl"];
    [coder encodeObject:_iconUrl forKey:@"iconUrl"];
    [coder encodeBool:_isUserAdded forKey:@"isUserAdded"];
    [coder encodeBool:_isAddButton forKey:@"isAddButton"];
}
- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    _imageUrl = [coder decodeObjectOfClass:NSURL.class forKey:@"imageUrl"];
    _iconUrl = [coder decodeObjectOfClass:NSURL.class forKey:@"iconUrl"];
    _isUserAdded = [coder decodeBoolForKey:@"isUserAdded"];
    _isAddButton = [coder decodeBoolForKey:@"isAddButton"];
    return self;
}
+ (BOOL)supportsSecureCoding {
    return YES;
}
@end
