//
//  TelephoneAreaCodeDataProvider.m
//  TUIKitDemo
//
//  Created by harvy on 2021/12/14.
//  Copyright © 2021 Tencent. All rights reserved.
//

#import "TelephoneAreaCodeDataProvider.h"
#import "NSString+TUIUtil.h"

@implementation TelephoneAreaCode

- (id)copyWithZone:(NSZone *)zone
{
    TelephoneAreaCode *code = [[TelephoneAreaCode allocWithZone:zone] init];
    code.name = self.name;
    code.chineseName = self.chineseName;
    code.code = self.code;
    code.codeName = self.codeName;
    return code;
}

- (NSString *)displayName
{
    if (TelephoneAreaCode.isChinese) {
        return self.chineseName;
    } else {
        return self.name;
    }
}

+ (BOOL)isChinese
{
    NSString *language = [NSLocale preferredLanguages].firstObject;
    if ([language hasPrefix:@"zh"]) {
        return YES;
    }
    return NO;
}

@end


@interface TelephoneAreaCodeDataProvider ()

@property (nonatomic, strong) NSArray<TelephoneAreaCode *> *allInfos;
@property (nonatomic, strong) dispatch_queue_t queue;

// 索引
@property (nonatomic, strong) NSArray *indexs;
// 数据
@property (nonatomic, strong) NSDictionary<NSString *, NSArray<TelephoneAreaCode *> *> *datas;

// 首选国家/地区  -> 默认是中国
@property (nonatomic, strong) TelephoneAreaCode *preferenceAreaCode;

@end

@implementation TelephoneAreaCodeDataProvider

- (instancetype)init
{
    if (self = [super init]) {
        self.queue = dispatch_queue_create("area_code", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (void)getPreferencesAreaCode:(void(^)(TelephoneAreaCode *))callback
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.queue, ^{
        [weakSelf loadRourceIfNeeded];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callback) {
                callback(self.preferenceAreaCode);
            }
        });
    });
}

- (void)searchWithKeyword:(NSString *)keyword callback:(dispatch_block_t)callback
{
    __weak typeof(self) weakSelf = self;
    dispatch_async(self.queue, ^{
        [weakSelf doSearchWithKeyword:keyword callback:callback];
    });
}

- (void)doSearchWithKeyword:(NSString *)keyword callback:(dispatch_block_t)callback
{
    [self loadRourceIfNeeded];
    
    if (keyword == nil || keyword.length == 0) {
        [self sortResultsIfNeeded:self.allInfos];
        [self callback:callback];
        return;
    }
    
    NSMutableArray *searchResults = [NSMutableArray array];
    for (TelephoneAreaCode *code in self.allInfos) {
        if ([code.name.localizedLowercaseString containsString:keyword.localizedLowercaseString] ||
            [code.chineseName.localizedLowercaseString containsString:keyword.localizedLowercaseString]) {
            [searchResults addObject:[code copy]];
        }
    }
    
    [self sortResultsIfNeeded:searchResults];
    [self callback:callback];
}

- (void)loadRourceIfNeeded
{
    if (self.allInfos.count == 0) {
        NSString *path = [NSBundle.mainBundle pathForResource:@"telephone_area_code" ofType:@"json"];
        NSData *data = [NSData dataWithContentsOfFile:path];
        NSError *error = nil;
        NSArray *list = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        if (error || ![list isKindOfClass:NSArray.class]) {
            return;
        }
        NSMutableArray *arrayM = [NSMutableArray array];
        for (NSDictionary *dict in list) {
            if (![dict.allKeys containsObject:@"code"] ||
                ![dict.allKeys containsObject:@"name"] ||
                ![dict.allKeys containsObject:@"chineseName"] ||
                ![dict.allKeys containsObject:@"codeName"]) {
                continue;
            }
            TelephoneAreaCode *code = [[TelephoneAreaCode alloc] init];
            code.code = dict[@"code"];
            code.name = dict[@"name"];
            code.chineseName = dict[@"chineseName"];
            code.codeName = dict[@"codeName"];
            [arrayM addObject:code];
            
            if ([code.code isEqual:@"86"]) {
                self.preferenceAreaCode = [code copy];
            }
        }
        self.allInfos = [NSArray arrayWithArray:arrayM];
    }
}

- (void)sortResultsIfNeeded:(NSArray<TelephoneAreaCode *> *)results
{
    BOOL chinese = TelephoneAreaCode.isChinese;
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    for (TelephoneAreaCode *code in results) {
        NSString *indexString = chinese ? code.chineseName : code.name;
        NSString *firstLatter = [indexString.firstPinYin localizedUppercaseString];
        
        NSMutableArray *arrayM = [NSMutableArray array];
        if ([dict.allKeys containsObject:firstLatter]) {
            arrayM = [NSMutableArray arrayWithArray:dict[firstLatter]];
        }
        [arrayM addObject:code];
        
        dict[firstLatter] = [NSArray arrayWithArray:arrayM];
    }
    
    // 索引排序
    NSMutableArray *index = [NSMutableArray arrayWithArray:dict.allKeys];
    [index sortUsingSelector:@selector(localizedStandardCompare:)];

    self.datas = [NSDictionary dictionaryWithDictionary:dict];
    self.indexs = [NSArray arrayWithArray:index];
}


- (void)callback:(dispatch_block_t)block
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (block) {
            block();
        }
    });
}

@end
