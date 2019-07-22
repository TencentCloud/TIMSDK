#import "TNavigationController.h"

@interface TNavigationController ()

@end

@implementation TNavigationController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    //push的时候隐藏底部tabbar
    if(self.viewControllers.count != 0){
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [super pushViewController:viewController animated:animated];
}
@end
