#import <UIKit/UIKit.h>

@class TTextEditController;

@interface TTextEditController : UIViewController
{

}


- (instancetype)initWithText:(NSString *)text;

@property UITextField *inputTextField;
@property NSString *textValue;

@end


