#import <UIKit/UIKit.h>

@interface TResponderTextView : UITextView
@property (nonatomic, weak) UIResponder *overrideNextResponder;
@end
