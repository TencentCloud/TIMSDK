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
    int unit = NSCalendarUnitDay | NSCalendarUnitMonth |  NSCalendarUnitYear ;
    NSDateComponents *nowCmps = [calendar components:unit fromDate:[ NSDate date ]];
    NSDateComponents *myCmps = [calendar components:unit fromDate:self];
    NSDateFormatter *dateFmt = [[NSDateFormatter alloc ] init ];
    BOOL isYesterday = NO;
    if (nowCmps.year != myCmps.year) {
        dateFmt.dateFormat = @"yyyy/MM/dd";
    }
    else{
        if (nowCmps.day==myCmps.day) {
            dateFmt.dateFormat = @"HH:mm";
        } else if((nowCmps.day-myCmps.day)==1) {
            isYesterday = YES;
            dateFmt.AMSymbol = TUILocalizableString(am); //@"上午";
            dateFmt.PMSymbol = TUILocalizableString(pm); //@"下午";
            dateFmt.dateFormat = TUILocalizableString(YesterdayDateFormat);
        } else {
            if ((nowCmps.day-myCmps.day) <=7) {
                dateFmt.dateFormat = @"EEEE";
            }else {
                dateFmt.dateFormat = @"yyyy/MM/dd";
            }
        }
    }
    NSString *str = [dateFmt stringFromDate:self];
    if (isYesterday) {
        str = [NSString stringWithFormat:@"%@ %@", TUILocalizableString(Yesterday), str];
    }
    return str;
}
@end
