//
//  petInfoViewController.h
//  FeedIoT
//
//  Created by Robert on 3/13/16.
//

#import <UIKit/UIKit.h>
#import "FirstViewController.h"
#import "AppDelegate.h"
#import "TextFieldValidator.h"
#import "httpVC.h"
#import "MBProgressHUD.h"


@interface petInfoViewController : UIViewController
{
    FirstViewController *fc;
    BOOL changef,keyboardIsShown ;
    CGFloat animatedDistance;
    AppDelegate *appDelegate;
    NSString *mis;
    NSMutableString *answer;
    NSIndexSet *selectedIndices;
    NSMutableArray *selectedItemsArray;
    NSArray *wifis;
    httpVC *comm;
    UIView *backGroundBlurr;
    NSMutableString *ap;
    MBProgressHUD *hud;

}

@property (strong) IBOutlet TextFieldValidator *petName,*phone,*email,*watts,*kwh,*galons,*volts,*water,*group;
@property (strong) IBOutlet UIImageView *bffIcon;
@property (strong) IBOutlet UISwitch *offline,*limit;
@property (strong) IBOutlet UITableView *bjTable;
@property (strong) IBOutlet UILabel *bfname,*vetphone,*emaill,*birth,*opmode;
@property (strong) IBOutlet UISegmentedControl *transport,*whichMeter;
@end
