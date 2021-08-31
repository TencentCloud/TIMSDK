//
//  NSDate+TUIKIT.m
//  TXIMSDK_TUIKit_iOS
//
//  Created by annidyfeng on 2019/5/20.
//

#import "NSDate+TUIKIT.h"
#import "NSBundle+TUIKIT.h"

@implementation NSDate (TUIKIT)

- (NSString *)tk_messageString
{
    NSCalendar *calendar = [ NSCalendar currentCalendar ];
    NSDateFormatter *dateFmt = [[NSDateFormatter alloc ] init ];
    BOOL isYesterday = NO;
    if ([calendar isDateInToday:self]) {
        // 今天
        dateFmt.dateFormat = @"HH:mm";
    } else if ([calendar isDateInYesterday:self]) {
        // 昨天
        isYesterday = YES;
        dateFmt.AMSymbol = TUILocalizableString(am); //@"上午";
        dateFmt.PMSymbol = TUILocalizableString(pm); //@"下午";
        dateFmt.dateFormat = TUILocalizableString(YesterdayDateFormat);
    } else if ([self isDateInWeekday:self]) {
        // 一周内
        dateFmt.dateFormat = @"EEEE";
    } else {
        // 其他
        dateFmt.dateFormat = @"yyyy/MM/dd";
    }
    
    
    NSString *str = [dateFmt stringFromDate:self];
    if (isYesterday) {
        str = [NSString stringWithFormat:@"%@ %@", TUILocalizableString(Yesterday), str];
    }
    return str;
}

- (BOOL)isDateInWeekday:(NSDate *)date {
    // 此处忽略了跨年的情况
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSInteger nowInteger = [calendar component:NSCalendarUnitWeekOfYear fromDate:[NSDate date]];
    NSInteger nowWeekDay = [calendar component:NSCalendarUnitWeekday fromDate:[NSDate date]];
    NSInteger beforeInteger = -1;
    if (date) {
        beforeInteger = [calendar component:NSCalendarUnitWeekOfYear fromDate:date];
    }

    if (nowInteger == beforeInteger) {
        // 在一周
        return YES;
    } else if (nowInteger - beforeInteger == 1 && nowWeekDay == 1) {
        // 西方一周的第一天从周日开始，所以需要判断当前是否为一周的第一天，如果是，则为同周
        return YES;
    } else {
        return NO;
    }
}
@end
