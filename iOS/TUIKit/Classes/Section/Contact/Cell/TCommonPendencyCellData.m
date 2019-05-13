//
//  TCommonPendencyCellData.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/7.
//

#import "TCommonPendencyCellData.h"
#import "TIMUserProfile+DataProvider.h"

@implementation TCommonPendencyCellData

- (instancetype)initWithPendency:(TIMFriendPendencyItem *)args {
    self = [super init];
    
    _identifier = args.identifier;
    _title = args.identifier;
    if (args.addSource) {
        _addSource = [NSString stringWithFormat:@"来源: %@", [args.addSource substringFromIndex:@"AddSource_Type_".length]];
    }
    _addWording = args.addWording;
    _isAccepted = NO;

    return self;
}

@end
