#import <Foundation/Foundation.h>

#define TLetter_Key @"key"
#define TLetter_Value @"value"

@interface TAddHelper : NSObject
+ (NSMutableArray *)arrayWithFirstLetterFormat:(NSArray *)array;
+ (NSString *)getFirstLetter:(NSString *)str;
@end
