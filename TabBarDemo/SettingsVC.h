//
//  SettingsVC.h
//  FeedIoT
//

#import <UIKit/UIKit.h>
#import "FirstViewController.h"
#import "AppDelegate.h"
#import "httpVC.h"

@interface SettingsVC : UIViewController
{
    FirstViewController *fc;
    BOOL syncf;
    NSString *mis;
    NSMutableString *answer;
    AppDelegate *appDelegate;
    httpVC *comm;
    NSString *picfilePath ;
    UIView *backGroundBlurr;
    CGFloat llevo;
    CAGradientLayer *gradient;
    NSTimer *theTimer;
    UIImage *passOn,*passOff;
}
@property (strong) IBOutlet UIButton *bsync,*passSW;
@property (strong) IBOutlet UILabel *tsync;
@property (strong) IBOutlet UIImageView *bffIcon;

@end
