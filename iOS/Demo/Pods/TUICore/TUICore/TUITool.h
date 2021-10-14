
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void (^TAsyncImageComplete)(NSString *path, UIImage *image);

@interface TUITool : NSObject
// json & str & data
+ (NSData *)dictionary2JsonData:(NSDictionary *)dict;
+ (NSString *)dictionary2JsonStr:(NSDictionary *)dict;
+ (NSDictionary *)jsonSring2Dictionary:(NSString *)jsonString;
+ (NSDictionary *)jsonData2Dictionary:(NSData *)jsonData;

// toast
+ (void)makeToast:(NSString *)str;
+ (void)makeToast:(NSString *)str duration:(NSTimeInterval)duration;
+ (void)makeToast:(NSString *)str duration:(NSTimeInterval)duration position:(CGPoint)position;
+ (void)makeToast:(NSString *)str duration:(NSTimeInterval)duration idposition:(id)position;
+ (void)makeToastError:(NSInteger)error msg:(NSString *)msg;
+ (void)makeToastActivity;
+ (void)hideToastActivity;

// 切换主线程
+(void)dispatchMainAsync:(dispatch_block_t) block;

// date
+ (NSString *)convertDateToStr:(NSDate *)date;

// msg code convert
+ (NSString *)convertIMError:(NSInteger)code msg:(NSString *)msg;

// 富媒体
+ (NSString *)genImageName:(NSString *)uuid;
+ (NSString *)genSnapshotName:(NSString *)uuid;
+ (NSString *)genVideoName:(NSString *)uuid;
+ (NSString *)genFileName:(NSString *)uuid;
+ (NSString *)genVoiceName:(NSString *)uuid withExtension:(NSString *)extent;
+ (void)asyncDecodeImage:(NSString *)path complete:(TAsyncImageComplete)complete;
+ (NSString *)randAvatarUrl;
@end
