//
//  TabBarViewController.m
//  TabBarDemo
//

//
#define CUAL CEFlipAnimationController
#define IMPORT
#import "TabBarViewController.h"
#import "CEFlipAnimationController.h"
#import "CEHorizontalSwipeInteractionController.h"

@interface TabBarViewController () <UITabBarControllerDelegate>

@end

@implementation TabBarViewController {
    CUAL *_animationController;
    CEHorizontalSwipeInteractionController *_swipeInteractionController;
}
/*
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController

{
    NSLog(@"selectedtab");
    if([tabBarController selectedIndex] == 0)
    {
        [viewController.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"folder.png"]withFinishedUnselectedImage:[UIImage imageNamed:@"clock.png"]];
    }
}
*/
//
//- (id)initWithCoder:(NSCoder *)aDecoder {
//    if (self = [super initWithCoder:aDecoder]) {
//        self.delegate = self;
//
//        // create the interaction / animation controllers
//        _swipeInteractionController = [CEHorizontalSwipeInteractionController new];
//        _animationController = [CUAL new];
//     //   _animationController.folds = 3;
//
//        // observe changes in the currently presented view controller
////        [self addObserver:self
////               forKeyPath:@"selectedViewController"
////                  options:NSKeyValueObservingOptionNew
////                  context:nil];
////    }
//    return self;
//}
//
//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
//                        change:(NSDictionary *)change
//                       context:(void *)context
//{
//    if ([keyPath isEqualToString:@"selectedViewController"] )
//    {
//        // wire the interaction controller to the view controller
//        [_swipeInteractionController wireToViewController:self.selectedViewController
//                                             forOperation:CEInteractionOperationTab];
//    }
//}
//
//
//
//- (id <UIViewControllerAnimatedTransitioning>)tabBarController:(UITabBarController *)tabBarController
//            animationControllerForTransitionFromViewController:(UIViewController *)fromVC
//                                              toViewController:(UIViewController *)toVC {
//
//    NSUInteger fromVCIndex = [tabBarController.viewControllers indexOfObject:fromVC];
//    NSUInteger toVCIndex = [tabBarController.viewControllers indexOfObject:toVC];
//
//    _animationController.reverse = fromVCIndex < toVCIndex;
//    return _animationController;
//}
//
//-(id<UIViewControllerInteractiveTransitioning>)tabBarController:(UITabBarController *)tabBarController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController
//{
//    return _swipeInteractionController.interactionInProgress ? _swipeInteractionController : nil;
//}

@end
