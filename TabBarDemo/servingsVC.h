//
//  servingsVC.h
//  FeedIoT
//

#import <UIKit/UIKit.h>
#import "FirstViewController.h"
#import "AppDelegate.h"
#import "httpVC.h"

@interface servingsVC : UIViewController
{
    FirstViewController *fc;
    BOOL changef,keyboardIsShown ;
    CGFloat animatedDistance;
    NSString *mis;
    NSMutableString *answer;
    AppDelegate *appDelegate;
    httpVC *comm;
}
@property (strong) IBOutlet UISlider * activate,*relay,*wait,*tx,*fault,*limbo;
@property (strong) IBOutlet UILabel *tactivate,*trelay,*twait,*ttx,*tfault,*tlimbo;
@property (strong) IBOutlet UIImageView *bffIcon;
@end
